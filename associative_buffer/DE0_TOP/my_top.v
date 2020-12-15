`include "register.vh"

module my_top
	#(
		parameter KEY_WIDTH = 4,
		parameter DATA_WIDTH = 2,
		parameter DATA_NUMBER_LOG2 = 3
	)
	(
		input clk,
		input async_reset,
		input [2 : 0] ctrl_input,
		input [(KEY_WIDTH - 1) : 0] key_input,
		input [(DATA_WIDTH - 1) : 0] data_input,
		output [(DATA_WIDTH - 1) : 0] data_output,
		output data_valid,
		input trigger_display
	);
	
	wire [2 : 0] ctrl_input_ed;
	
	genvar i;
	generate
		for (i = 0; i < 3; i = i + 1) begin : generate_edge_detectors_block
			edge_detector
			#(
				.EDGE_DETECTOR_TYPE(2'd0)
			)
			edge_detector_instance
			(
				.async_reset(async_reset),
				.clk(clk),
				.signal_input(ctrl_input[i]),
				.signal_output(ctrl_input_ed[i])
			);
		end
	endgenerate
	
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] ctrl;
	
	always @(*) begin
		ctrl <= `REG_CTRL_NOP;
		if (ctrl_input_ed[0] == 1'b1) 
			ctrl <= `REG_CTRL_LD;
		else if (ctrl_input_ed[1] == 1'b1)
			ctrl <= `REG_CTRL_INC;
		else if (ctrl_input_ed[2] == 1'b1) 
			ctrl <= `REG_CTRL_CLR;
	end
	
	associative_buffer
	#(
		.KEY_WIDTH(KEY_WIDTH),
		.DATA_WIDTH(DATA_WIDTH),
		.NUM_DATA_LOG2(DATA_NUMBER_LOG2)
	)
	associative_buffer_instance
	(
		.async_reset(async_reset),
		.clk(clk),
		.ctrl(ctrl),
		.data_input(data_input),
		.key_input(key_input),
		.trigger_read(trigger_display),
		.data_output(data_output),
		.data_valid_output(data_valid)
	);
	
endmodule