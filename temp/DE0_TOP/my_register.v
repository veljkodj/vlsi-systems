`include "my_register.vh"

module my_register
	#(
		parameter DATA_WIDTH = 8,
		parameter CTRL_WIDTH = `MY_REGISTER_CTRL_WIDTH
	)
	(
		input rst,
		input clk,
		input [(CTRL_WIDTH - 1) : 0] ctrl,
		input [(DATA_WIDTH - 1) : 0] data_input,
		output [(DATA_WIDTH - 1) : 0] data_output
	);
	
	localparam CTRL_NOP = `MY_REGISTER_CTRL_NOP;
	localparam CTRL_CLR = `MY_REGISTER_CTRL_CLR;
	localparam CTRL_LOAD = `MY_REGISTER_CTRL_LOAD;
	localparam CTRL_INCR = `MY_REGISTER_CTRL_INCR;
	localparam CTRL_DECR = `MY_REGISTER_CTRL_DECR;
	
	reg [(DATA_WIDTH - 1) : 0]  data_reg, data_next;
	
	always @(posedge clk, negedge rst) begin : synchronous
		if (!rst) begin
			data_reg <= {DATA_WIDTH{1'b0}};
		end
		else begin
			data_reg <= data_next;
		end
	end
	
	always @(*) begin : combinational
		case (ctrl)
			CTRL_CLR : begin
				data_next <= {DATA_WIDTH{1'b0}};
			end
			CTRL_LOAD : begin
				data_next <= data_input;
			end
			CTRL_INCR : begin
				data_next <= data_reg + {{(DATA_WIDTH - 1){1'b0}}, 1'b1};
			end
			CTRL_DECR : begin
				data_next <= data_reg - {{(DATA_WIDTH - 1){1'b0}}, 1'b1};
			end
			default : begin
				data_next <= data_reg;
			end
		endcase
	end
	
	assign data_output = data_reg;
	
endmodule
