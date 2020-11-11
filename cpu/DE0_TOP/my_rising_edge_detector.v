module my_rising_edge_detector
    (
        input rst,
        input clk,
        input signal_in,
        output signal_out
    );
    
    reg [1 : 0] ff_reg;
    wire [1 : 0] ff_next;
    
    always @(posedge clk, negedge rst) begin
        if (rst == 1'b0) begin
            ff_reg <= 2'b00;
        end
        else begin
            ff_reg <= ff_next;
        end
    end
    
    assign ff_next = { ff_reg[0], signal_in };
    
    assign signal_out = ff_reg[0] & ~ff_reg[1];
    
endmodule
