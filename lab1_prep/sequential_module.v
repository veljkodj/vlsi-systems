module sequential_module
    (
        input async_reset,
        input clk,
        input [3 : 0] data_input,
        input [2 : 0] ctrl,
        output reg [3 : 0] data_output
    );
    
    localparam enable    = 0;
    localparam double    = 1;
    localparam operation = 2;
    
    reg [3 : 0] data_reg, data_next;
    
    always @(negedge async_reset, posedge clk) begin
        if (!async_reset)
            data_reg <= 4'b0000;
        else 
            data_reg <= data_next;
    end
    
    reg [3 : 0] first_operand;
    
    always @(*) begin
        
        data_next <= data_reg;
    
        if (ctrl[enable] == 1'b1) begin
        
            if (ctrl[double] == 1'b1)
                first_operand <= data_input << 1;
            else
                first_operand <= data_input;
            
            if (ctrl[operation] == 1'b0)
                data_next <= first_operand;
            else
                data_next <= data_reg + {{3{1'b0}}, 1'b1};
            
        end
        
    end
    
    always @(*) begin
    
        data_output <= data_reg;
    
    end
    
endmodule