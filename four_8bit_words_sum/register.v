module register
	#(
		parameter WIDTH = 8
	)
	(
		input async_reset,
		input clk,
		input ctrl_load,
		input ctrl_inc,
		input [(WIDTH-1):0] data_input,
		output reg [(WIDTH-1):0] data_output
	);
	
	reg [(WIDTH-1):0] data_reg, data_next;
	
	always @(negedge async_reset, posedge clk) begin
		if (!async_reset) begin
			data_reg <= {WIDTH{1'b0}};
		end else begin
			data_reg <= data_next;
		end
	end
	
	always @(*) begin
		data_next <= data_reg;
		if (ctrl_inc)
			data_next <= data_reg + {{(WIDTH-1){1'b0}}, {1'b1}};
		if (ctrl_load) 
			data_next <= data_input;
	end
	
	always @(*) begin
		data_output <= data_reg;
	end
	
endmodule
