module my_cpu
    (
        input rst,
        input clk,
        input trap_trigger,
        output reg gpio_ctrl_write,
        output reg [7 : 0] gpio_data_out,
        input [7 : 0] gpio_data_in,
        output reg mem_ctrl_write,
        output reg [7 : 0] mem_addr_out,
        output reg [7 : 0] mem_data_out,
        input [7 : 0] mem_data_in
    );
    
    localparam ACC = 0;
    localparam PC = 1;
    localparam IR_LOW = 2;
    localparam IR_HIGH = 3;
    localparam PSR = 4;
    
    localparam FLAG_ZERO = 0;
    localparam FLAG_CARRY = 1;
    
    reg ctrl_load [4 : 0];
    reg ctrl_incr [4 : 0];
    reg [7 : 0] register_input [4 : 0];
    wire [7 : 0] register_output [4 : 0];
    
    genvar i;
    generate
        for (i = 0; i < 5; i = i + 1) begin : generate_block
            my_register
            #(
                .DATA_WIDTH(8)
            )
            register
            (
                .rst(rst),
                .clk(clk),
                .ctrl_load(ctrl_load[i]),
                .ctrl_incr(ctrl_incr[i]),
                .data_in(register_input[i]),
                .data_out(register_output[i])
            );
        end
    endgenerate
    
    wire [7 : 0] alu_result;
    wire alu_carry;
    reg [7 : 0] alu_operand_a;
    reg [7 : 0] alu_operand_b;
    reg alu_ctrl_operation;
    
    my_alu_unit
        #(
            .DATA_WIDTH(8)
        )
    alu_unit
        (
            .ctrl_operation(alu_ctrl_operation),
            .operand_a(alu_operand_a),
            .operand_b(alu_operand_b),
            .result(alu_result),
            .carry(alu_carry)
        );
    
    localparam IR_LOW_FETCH = 3'b000;
    localparam IR_LOW_LOAD = 3'b001;
    localparam IR_LOW_DECODE = 3'b010;
    localparam IR_HIGH_LOAD = 3'b011;
    localparam IR_HIGH_DECODE = 3'b100;
    localparam DATA_LOAD = 3'b101;
    localparam TRAPED = 3'b110;
    localparam UKNOWN_INSTR_CODE = 3'b111;
    
    reg [2 : 0] state_reg, state_next;
    
    always @(posedge clk, negedge rst) begin : synchronous_block
        if (rst == 1'b0) begin
            state_reg <= IR_LOW_FETCH;
        end
        else begin
            state_reg <= state_next;
        end
    end
    
    localparam LD = 4'b0000;
    localparam ST = 4'b0001;
    localparam IN = 4'b0010;
    localparam OUT = 4'b0011;
    localparam ADD = 4'b0100;
    localparam SUB = 4'b0101;
    localparam JZ = 4'b1000;
    localparam JNZ = 4'b1001;
    localparam JMP = 4'b1010;
    localparam TRAP = 4'b1111;
    
    integer j;
    always @(*) begin : finite_state_machine_block
        gpio_ctrl_write <= 1'b0;
        gpio_data_out <= 8'h00;
        mem_ctrl_write <= 1'b0;
        mem_addr_out <= 8'h00;
        mem_data_out <= 8'h00;
        alu_ctrl_operation <= 1'b0;
        alu_operand_a <= 8'h00;
        alu_operand_b <= 8'h00;
        state_next <= state_reg;
        for (j = 0; j < 5; j = j + 1) begin
            ctrl_load[j] <= 1'b0;
            ctrl_incr[j] <= 1'b0;
            register_input[j] <= register_output[j];
        end
        case (state_reg)
            ////////////////////////////////////////////////////////////////////////////////////////////
            IR_LOW_FETCH : begin
                mem_addr_out <= register_output[PC];
                ctrl_incr[PC] <= 1'b1;
                state_next <= IR_LOW_LOAD;
            end
            ////////////////////////////////////////////////////////////////////////////////////////////
            IR_LOW_LOAD : begin
                register_input[IR_LOW] <= mem_data_in;
                ctrl_load[IR_LOW] <= 1'b1;
                state_next <= IR_LOW_DECODE;
            end
            ////////////////////////////////////////////////////////////////////////////////////////////
            IR_LOW_DECODE : begin
                case (register_output[IR_LOW][7 : 4])
                    LD, ST, ADD, SUB, JZ, JNZ, JMP : begin
                        mem_addr_out <= register_output[PC];
                        ctrl_incr[PC] <= 1'b1;
                        state_next <= IR_HIGH_LOAD;
                    end
                    IN: begin
                        register_input[ACC] <= gpio_data_in;
                        ctrl_load[ACC] <= 1'b1;
                        state_next <= IR_LOW_FETCH;
                    end
                    OUT: begin
                        gpio_data_out <= register_output[ACC];
                        gpio_ctrl_write <= 1'b1;
                        state_next <= IR_LOW_FETCH;
                    end
                    TRAP : begin
                        state_next <= TRAPED;
                    end
                    default : begin
                        state_next <= UKNOWN_INSTR_CODE;
                    end
                endcase
            end
            ////////////////////////////////////////////////////////////////////////////////////////////
            IR_HIGH_LOAD : begin
                register_input[IR_HIGH] <= mem_data_in;
                ctrl_load[IR_HIGH] <= 1'b1;
                state_next <= IR_HIGH_DECODE;
            end
            ////////////////////////////////////////////////////////////////////////////////////////////
            IR_HIGH_DECODE : begin
                case (register_output[IR_LOW][7 : 4])
                    LD, ADD, SUB : begin
                        mem_addr_out <= register_output[IR_HIGH];
                        state_next <= DATA_LOAD;
                    end
                    ST : begin
                        mem_addr_out <= register_output[IR_HIGH];
                        mem_data_out <= register_output[ACC];
                        mem_ctrl_write <= 1'b1;
                        state_next <= IR_LOW_FETCH;
                    end
                    JZ : begin
                        if (register_output[PSR][FLAG_ZERO] == 1'b1) begin
                            register_input[PC] <= register_output[IR_HIGH];
                            ctrl_load[PC] <= 1'b1;
                        end
                        state_next <= IR_LOW_FETCH;
                    end
                    JNZ : begin
                        if (register_output[PSR][FLAG_ZERO] == 1'b0) begin
                            register_input[PC] <= register_output[IR_HIGH];
                            ctrl_load[PC] <= 1'b1;
                        end
                        state_next <= IR_LOW_FETCH;
                    end
                    JMP : begin
                        register_input[PC] <= register_output[IR_HIGH];
                        ctrl_load[PC] <= 1'b1;
                        state_next <= IR_LOW_FETCH;
                    end
                    default : begin
                        state_next <= UKNOWN_INSTR_CODE;
                    end
                endcase
            end
            ////////////////////////////////////////////////////////////////////////////////////////////
            DATA_LOAD : begin
                case (register_output[IR_LOW][7 : 4])
                    LD : begin
                        register_input[ACC] <= mem_data_in;
                        ctrl_load[ACC] <= 1'b1;
                        state_next <= IR_LOW_FETCH;
                    end
                    ADD, SUB : begin
                        alu_operand_a <= register_output[ACC];
                        alu_operand_b <= mem_data_in;
                        alu_ctrl_operation <= (register_output[IR_LOW][7 : 4] == ADD) ? 1'b0 : 1'b1;
                        register_input[ACC] <= alu_result;
                        ctrl_load[ACC] <= 1'b1;
                        register_input[PSR][FLAG_ZERO] <= (alu_result == 8'h00) ? 1'b1 : 1'b0;
                        register_input[PSR][FLAG_CARRY] <= alu_carry;
                        ctrl_load[PSR] <= 1'b1;
                        state_next <= IR_LOW_FETCH;
                    end
                    default : begin
                        state_next <= UKNOWN_INSTR_CODE;
                    end
                endcase
            end
            ////////////////////////////////////////////////////////////////////////////////////////////
            TRAPED : begin
                if (trap_trigger == 1'b1) begin
                    state_next <= IR_LOW_FETCH;
                end
            end
            ////////////////////////////////////////////////////////////////////////////////////////////
            UKNOWN_INSTR_CODE : begin
                //nothing
            end
        endcase
    end
    
endmodule
