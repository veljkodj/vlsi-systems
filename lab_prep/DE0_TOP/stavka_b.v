module stavka_b
	(
		input clk,
		input rst_n,
		input in,
		output reg out
	);
	
	reg ff1_reg, ff1_next;
	reg ff2_reg, ff2_next;
	reg output_reg, output_next;
	integer cntr_reg, cntr_next;
	
	always @(negedge rst_n, posedge clk) begin
		if (!rst_n) begin
			ff1_reg <= 1'b0;
			ff2_reg <= 1'b0;
			output_reg <= 1'b0;
			cntr_reg <= 1'b0;
		end else begin
			ff1_reg <= ff1_next;
			ff2_reg <= ff2_next;
			output_reg <= output_next;
			cntr_reg <= cntr_next;
		end
	end
	
	always @(*) begin

		ff1_next <= in;
		ff2_next <= ff1_reg;
		output_next <= output_reg;
		cntr_next <= cntr_reg + 1;
		
		if (ff1_reg ^ ff2_reg == 1'b1)
			cntr_next <= 0;
			
		if (cntr_reg == 256) begin
			cntr_next <= cntr_reg;
			output_next <= ff2_reg;
		end
		
		out <= output_reg;
		
	end

endmodule