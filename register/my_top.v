module my_top
	#(
		parameter WIDTH = 8
	)
	(
		input asynch_nreset,
		input clk,
		input ctrl_load,
		input ctrl_incr,
		input [WIDTH - 1 : 0] data_input,
		output [WIDTH - 1 : 0] data_output
	);
	
	wire ctrl_incr_deb;
	
	my_debouncer my_debouncer_instance
		(
			.asynch_nreset(asynch_nreset),
			.clk(clk),
			.signal_input(ctrl_incr),
			.signal_output(ctrl_incr_deb)
		);
	
	wire ctrl_incr_red;
	
	my_rising_edge_detector my_rising_edge_detector_instance
		(
			.asynch_nreset(asynch_nreset),
			.clk(clk),
			.signal_input(ctrl_incr_deb),
			.signal_output(ctrl_incr_red)
		);
	
	my_register
		#(
			.WIDTH(WIDTH)
		)
	my_register_instance
		(
			.asynch_nreset(asynch_nreset),
			.clk(clk),
			.ctrl_load(ctrl_load),
			.ctrl_incr(ctrl_incr_red),
			.data_input(data_input),
			.data_output(data_output)
		);

endmodule
