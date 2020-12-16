module my_top
	(
		input async_reset,
		input clk,
		input start_trigger,
		input [2 : 0] switches,
		input [2 : 0] buttons,
		output [31 : 0] sevenseg_output,
		output [3 : 0] led_output
	);
	
	wire [2 : 0] buttons_red;
	
	genvar i;
	generate
		for (i = 0; i < 3; i = i + 1) begin: rising_edge_detector_block_generate
			rising_edge_detector rising_edge_detector_instance
			(
				.async_reset(async_reset),
				.clk(clk),
				.signal_input(buttons[i]),
				.signal_output(buttons_red[i])
			);
		end
	endgenerate
	
	wire [31 : 0] bomb_controller_instance_sevenseg_output;
	wire [3 : 0] bomb_controller_instance_led_output;
	
	bomb_controller bomb_controller_instance
	(
		.async_reset(async_reset),
		.clk(clk),
		.start_trigger(start_trigger),
		.switches(switches),
		.buttons(buttons_red),
		.sevenseg_output(bomb_controller_instance_sevenseg_output),
		.led_output(bomb_controller_instance_led_output)
	);
	
	assign sevenseg_output = bomb_controller_instance_sevenseg_output;
	assign led_output = bomb_controller_instance_led_output;
	
endmodule