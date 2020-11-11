module my_alu_unit
    #(
        parameter DATA_WIDTH = 8
    )
    (
        input ctrl_operation,
        input [(DATA_WIDTH - 1) : 0] operand_a,
        input [(DATA_WIDTH - 1) : 0] operand_b,
        output reg [(DATA_WIDTH - 1) : 0] result,
        output reg carry
    );
    
    always @(*) begin : combinational
        if(ctrl_operation == 1'b1) begin
            {carry, result} = operand_a - operand_b;
        end
        else begin
            {carry, result} = operand_a + operand_b;
        end
    end
    
endmodule
