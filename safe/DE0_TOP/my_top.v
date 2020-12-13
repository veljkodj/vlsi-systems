module my_top
	(
		input async_reset,
		input clk,
		input button_push,
		input [3 : 0] digit,
		output [7 : 0] seven_seg_output
	);
	
	wire pushed_button_duration_instance_short_push;
	wire pushed_button_duration_instance_long_push;
	
	pushed_button_duration pushed_button_duration_instance
	(
		.clk(clk),
		.async_reset(async_reset),
		.signal_input(button_push),
		.short_push(pushed_button_duration_instance_short_push),
		.long_push(pushed_button_duration_instance_long_push)
	);
	
	wire [7 : 0] safe_instance_seven_seg_output;
	
	safe safe_instance
	(
		.async_reset(async_reset),
		.clk(clk),
		.short_button_push(pushed_button_duration_instance_short_push),
		.long_button_push(pushed_button_duration_instance_long_push),
		.digit(digit),
		.seven_seg_output(safe_instance_seven_seg_output)
	);
	
	assign seven_seg_output = safe_instance_seven_seg_output;
	
endmodule