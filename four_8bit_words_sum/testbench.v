module testbench;

	reg async_reset;
	reg clk;
	
	reg start_calculating;
	reg [31:0] data_to_calculate;
	
	wire valid_output;
	wire [9:0] data_output;

	my_device my_device 
	(
		.async_reset(async_reset),
		.clk(clk),
		.data_to_calculate(data_to_calculate),
		.start_calculating(start_calculating),
		.valid_output(valid_output),
		.data_output(data_output)
	);
	
	initial begin
		clk = 1'b0;
		forever begin
			#2 clk = ~clk;
		end
	end
	
	initial begin
		start_calculating = 1'b0;
		async_reset = 1'b0;
		#4;
		async_reset = 1'b1;
		#4;
		data_to_calculate = 32'h0302_0201;
		start_calculating = 1'b1;
		#30;
		start_calculating = 1'b0;
		#1000;
		$finish;
	end

endmodule