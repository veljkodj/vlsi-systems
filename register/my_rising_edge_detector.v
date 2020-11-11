module my_rising_edge_detector
	(
		input asynch_nreset,
		input clk,
		input signal_input,
		output reg signal_output
	);
	
	reg ff1_next, ff1_reg;
	reg ff2_next, ff2_reg;
	
	// Sequential logic block
	always @(negedge asynch_nreset, posedge clk) begin
		if (!asynch_nreset) begin
			ff1_reg <= 1'b0;
			ff2_reg <= 1'b0;
		end
		else begin
			ff1_reg <= ff1_next;
			ff2_reg <= ff2_next;
		end
	end
	
	// Combinational logic block (next state)
	always @(*) begin
		ff1_next <= signal_input;
		ff2_next <= ff1_reg;
	end
	
	// Combination logic block (output)
	always @(*) begin
		signal_output <= ff1_reg & ~ff2_reg;
	end
	
endmodule
