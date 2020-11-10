module sequential_module_testbench;

    reg async_reset;
    reg clk;
    reg [3 : 0] data_input;
    reg [2 : 0] ctrl;
    wire [3 : 0] data_output;

    sequential_module sequential_module_instance
        (
            .async_reset(async_reset),
            .clk(clk),
            .data_input(data_input),
            .ctrl(ctrl),
            .data_output(data_output)
        );
        
    initial begin
        clk = 1'b0;
        forever
            #2 clk = ~clk;
    end
    
    initial begin
        async_reset = 1'b0;
        data_input = 4'b0000;
        ctrl = 3'b000;
        #4;
        async_reset = 1'b1;
        repeat (100) begin
            data_input = {$random} % 16;
            ctrl = {$random} % 8;
            #8;
        end
        $finish;
    end
    
    initial
        $monitor("Time: %0d; data_output: %d", $time, data_output);

endmodule 