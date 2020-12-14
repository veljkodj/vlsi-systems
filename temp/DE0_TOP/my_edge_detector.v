`include "my_edge_detector.vh"

module my_edge_detector
	#(
		parameter SIGNAL_NUMBER = 1,
		parameter TARGET_EDGE = 2'd0
	)
	(
		input clk,
		input rst,
		input [(SIGNAL_NUMBER - 1) : 0] signal_input,
		output reg [(SIGNAL_NUMBER - 1) : 0] signal_output
	);
	
	localparam RISING_EDGE = `MY_EDGE_DETECTOR_RISING_EDGE;
	localparam FALLING_EDGE = `MY_EDGE_DETECTOR_FALLING_EDGE;
	localparam BOTH_EDGES = `MY_EDGE_DETECTOR_BOTH_EDGES;
	
	reg [(SIGNAL_NUMBER - 1) : 0] ff_next [1 : 0], ff_reg [1 : 0];
	
	always @(posedge clk, negedge rst) begin : sequential_block
		integer i;
		if (!rst) begin
			for (i = 0; i < 2; i = i + 1) begin
				ff_reg[i] <= {SIGNAL_NUMBER{1'b0}};
			end
		end
		else begin
			for (i = 0; i < 2; i = i + 1) begin
				ff_reg[i] <= ff_next[i];
			end
		end
	end
	
	always @(*) begin : combinational_next_state_block
		ff_next[0] <= signal_input;
		ff_next[1] <= ff_reg[0];
	end
	
	always @(*) begin : combinational_output_block
		reg [(SIGNAL_NUMBER - 1) : 0] rising_edge, falling_edge;
		rising_edge = ff_reg[0] & ~ff_reg[1];
		falling_edge = ~ff_reg[0] & ff_reg[1];
		case (TARGET_EDGE)
			RISING_EDGE : begin
				signal_output <= rising_edge;
			end
			FALLING_EDGE : begin
				signal_output <= falling_edge;
			end
			BOTH_EDGES : begin
				signal_output <= rising_edge | falling_edge;
			end
			default : begin
				signal_output <= {SIGNAL_NUMBER{1'b0}};
			end
		endcase
	end
	
endmodule
