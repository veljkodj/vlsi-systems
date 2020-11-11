module my_register
    #(
        parameter DATA_WIDTH = 8
    )
    (
        input rst,
        input clk,
        input ctrl_load,
        input ctrl_incr,
        input [(DATA_WIDTH - 1) : 0] data_in,
        output [(DATA_WIDTH - 1) : 0] data_out
    );
    
    reg [(DATA_WIDTH - 1) : 0] data_reg, data_next;
    
    always @(posedge clk, negedge rst) begin : synchronous
        if(rst == 1'b0) begin
            data_reg <= {DATA_WIDTH{1'b0}};
        end
        else begin
            data_reg <= data_next;
        end
    end
    
    always @(*) begin : combinational
        data_next = data_reg;
        if(ctrl_load == 1'b1) begin
            data_next = data_in;
        end
        else if(ctrl_incr == 1'b1) begin
            data_next = data_reg + {{(DATA_WIDTH - 1){1'b0}}, 1'b1};
        end
    end
    
    assign data_out = data_reg;
    
endmodule
