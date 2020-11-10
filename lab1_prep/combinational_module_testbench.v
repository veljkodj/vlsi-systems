module combinational_module_testbench;

    reg [6 : 0] data_input;
    reg ctrl;
    wire [7 : 0] data_output;

    combinational_module combinational_module_instance
    (
        .data_input(data_input),
        .ctrl(ctrl),
        .data_output(data_output)
    );
    
    integer i;
    
    initial 
        for (i = 0; i < 2 ** 8; i = i + 1) begin
            {ctrl, data_input} = i;
            #5;
        end
    
    always @(data_output) begin
        $display("===============================");
        $display("time        = %d", $time);
        $display("ctrl        = %d", ctrl);
        $display("data_input  = %d", data_input);
        $display("data_output = %d", data_output);
    end
    

endmodule