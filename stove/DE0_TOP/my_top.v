module my_top
	(
		input async_reset,
		input clk,
		input power_toggle,
		input [1 : 0] surface_toggle,
		input power_level_inc,
		input power_level_dec,
		output [15 : 0] power_level_7seg_output
	);
	
	wire [1 : 0] surface_toggle_deb;
	
	debouncer debouncer_surface_toggle_0
	(
		.async_reset(async_reset),
		.clk(clk),
		.signal_input(surface_toggle[0]),
		.signal_output(surface_toggle_deb[0])
	);
	
	debouncer debouncer_surface_toggle_1
	(
		.async_reset(async_reset),
		.clk(clk),
		.signal_input(surface_toggle[1]),
		.signal_output(surface_toggle_deb[1])
	);
	
	wire [1 : 0] surface_toggle_red;
	
	rising_edge_detector rising_edge_detector_surface_toggle_0
		(
			.async_reset(async_reset),
			.clk(clk),
			.signal_input(surface_toggle_deb[0]),
			.signal_output(surface_toggle_red[0])
		);
		
	rising_edge_detector rising_edge_detector_surface_toggle_1
		(
			.async_reset(async_reset),
			.clk(clk),
			.signal_input(surface_toggle_deb[1]),
			.signal_output(surface_toggle_red[1])
		);
	
	wire power_toggle_red;
	
	rising_edge_detector rising_edge_detector_power_toggle
		(
			.async_reset(async_reset),
			.clk(clk),
			.signal_input(power_toggle),
			.signal_output(power_toggle_red)
		);
		
	wire power_level_inc_red;
	
	rising_edge_detector rising_edge_detector_power_level_inc
		(
			.async_reset(async_reset),
			.clk(clk),
			.signal_input(power_level_inc),
			.signal_output(power_level_inc_red)
		);
		
	wire power_level_dec_red;
	
	rising_edge_detector rising_edge_detector_power_level_dec
		(
			.async_reset(async_reset),
			.clk(clk),
			.signal_input(power_level_dec),
			.signal_output(power_level_dec_red)
		);
	
	wire [15 : 0] power_level_7seg_output_stove_instance;
	
	stove stove_instance
	(
		.async_reset(async_reset),
		.clk(clk),
		.power_toggle(power_toggle_red),
		.surface_toggle({surface_toggle_red[1], surface_toggle_red[0]}),
		.power_level_inc(power_level_inc_red),
		.power_level_dec(power_level_dec_red),
		.power_level_7seg_output(power_level_7seg_output_stove_instance)
	);
	
	assign power_level_7seg_output = power_level_7seg_output_stove_instance;
	
endmodule