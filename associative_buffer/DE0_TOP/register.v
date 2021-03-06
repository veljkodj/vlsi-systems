`include "register.vh"

module register
	#(
		parameter WIDTH = 8
	)
	(
		input async_reset,
		input clk,
		input [(`REG_CTRL_WIDTH - 1) : 0] ctrl,
		input [(WIDTH - 1) : 0] data_input,
		output reg [(WIDTH - 1) : 0] data_output
	);
	
	reg [(WIDTH - 1) : 0] data_next, data_reg;
	
	always @(posedge clk, negedge async_reset) begin
		if (!async_reset) begin
			data_reg <= {WIDTH{1'b0}};
		end else begin
			data_reg <= data_next;
		end
	end
	
	always @(*) begin
		case (ctrl)
			`REG_CTRL_LD: begin
				data_next <= data_input;
			end
			`REG_CTRL_INC: begin
				data_next <= data_reg + {{(WIDTH-1){1'b0}}, {1'b1}};
			end
			`REG_CTRL_DEC: begin
				data_next <= data_reg - {{(WIDTH-1){1'b0}}, {1'b1}};
			end
			`REG_CTRL_CLR: begin
				data_next <= {WIDTH{1'b0}};
			end
			default: begin
				data_next <= data_reg;
			end
		endcase
	end
	
	always @(*) begin
		data_output <= data_reg;
	end
	
endmodule