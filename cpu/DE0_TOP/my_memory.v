module my_memory
    #(
        parameter FILE_NAME = "initial.mif",
        parameter DATA_WIDTH = 8,
        parameter ADDR_WIDTH = 8
    )
    (
        input clk,
        input ctrl_write,
        input [(ADDR_WIDTH - 1) : 0] addr_write,
        input [(DATA_WIDTH - 1) : 0] data_in,
        input [(ADDR_WIDTH - 1) : 0] addr_read,
        output reg [(DATA_WIDTH - 1) : 0] data_out
    );
    
    (* ram_init_file = FILE_NAME *) reg [(DATA_WIDTH - 1) : 0] memory [(2 ** ADDR_WIDTH - 1) : 0];
    
    always @(posedge clk) begin : synchronous
        if (ctrl_write) begin
            memory[addr_write] <= data_in;
        end
        data_out <= memory[addr_read];
    end
    
endmodule
