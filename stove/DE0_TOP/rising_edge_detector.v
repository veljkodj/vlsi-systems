module rising_edge_detector
	(
		input async_reset,
		input clk,
		input signal_input,
		output reg signal_output
	);
	
	reg ff1_reg, ff1_next;
	reg ff2_reg, ff2_next;
	
	always @(negedge async_reset, posedge clk) begin
		if (!async_reset) begin
			ff1_reg <= 1'b0;
			ff2_reg <= 1'b0;
		end else begin
			ff1_reg <= ff1_next;
			ff2_reg <= ff2_next;
		end
	end
	
	always @(*) begin
		ff1_next <= signal_input;
		ff1_next <= ff1_reg;
	end
	
	always @(*) begin
		signal_output <= ff1_reg & ~ff2_reg;
	end
	
endmodule