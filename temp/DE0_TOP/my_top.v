`include "my_associative_buffer.vh"
`include "my_edge_detector.vh"

module my_top
	#(
		parameter KEY_WIDTH = 4,
		parameter DATA_WIDTH = 2,
		parameter DATA_NUMBER_LOG2 = 3
	)
	(
		input clk,
		input rst,
		input [2 : 0] buttons,
		input [(KEY_WIDTH - 1) : 0] key_input,
		input [(DATA_WIDTH - 1) : 0] data_input,
		output [(DATA_WIDTH - 1) : 0] data_output,
		output data_valid,
		input trigger_display
	);
	
	wire [2 : 0] buttons_red;
	
	my_edge_detector
		#(
			.SIGNAL_NUMBER(3),
			.TARGET_EDGE(`MY_EDGE_DETECTOR_RISING_EDGE)
		)
	my_edge_detector_instance
		(
			.clk(clk),
			.rst(rst),
			.signal_input(buttons),
			.signal_output(buttons_red)
		);
		
	reg [2 : 0] ctrl;
	
	always @(*) begin
		ctrl <= `MY_ASSOCIATIVE_BUFFER_CTRL_NOP;
		if (buttons_red[0]) begin
			ctrl <= `MY_ASSOCIATIVE_BUFFER_CTRL_INCR;
		end
		if (buttons_red[1]) begin
			ctrl <= `MY_ASSOCIATIVE_BUFFER_CTRL_LOAD;
		end
		if (buttons_red[2]) begin
			ctrl <= `MY_ASSOCIATIVE_BUFFER_CTRL_CLR;
		end
	end
	
	my_associative_buffer
		#(
			.KEY_WIDTH(KEY_WIDTH),
			.DATA_WIDTH(DATA_WIDTH),
			.DATA_NUMBER_LOG2(DATA_NUMBER_LOG2)
		)
	my_associative_buffer_instance
		(
			.clk(clk),
			.rst(rst),
			.ctrl(ctrl),
			.key_input(key_input),
			.data_input(data_input),
			.data_output(data_output),
			.data_valid(data_valid),
			.trigger_display(trigger_display)
		);
	
endmodule
