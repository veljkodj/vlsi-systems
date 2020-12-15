`include "edge_detector.vh"

module edge_detector
	#(
		parameter EDGE_DETECTOR_TYPE = 2'd0
	)
	(
		input async_reset,
		input clk,
		input signal_input,
		output reg signal_output
	);
	
	reg ff1_next, ff1_reg;
	reg ff2_next, ff2_reg;
	
	always @(posedge clk, negedge async_reset) begin
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
		ff2_next <= ff1_reg;
	end
	
	always @(*) begin
		case (EDGE_DETECTOR_TYPE)
			`DETECT_RISING_EDGE: begin
				signal_output <= ff1_reg & ~ff2_reg;
			end
			`DETECT_FALLING_EDGE: begin
				signal_output <= ~ff1_reg & ff2_reg;
			end
			`DETECT_BOTH_EDGES: begin
				signal_output <= (ff1_reg & ~ff2_reg) | (~ff1_reg & ff2_reg);
			end
		endcase
	end
	
endmodule