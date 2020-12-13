module my_top
	#(
		parameter SECONDS_WIDTH = 10,
		parameter NUM_OF_7SEGS = 4
	)
	(
		input async_reset,
		input clk,
		input continue_pause,
		output [(SECONDS_WIDTH - 1) : 0] seconds_passed_led,
		output [(NUM_OF_7SEGS * 8 - 1) : 0] seconds_passed_7segs
	);
	
	wire continue_pause_red;
	
	rising_edge_detector
	(
		.async_reset(async_reset),
		.clk(clk),
		.signal_input(continue_pause),
		.signal_output(continue_pause_red)
	);
	
	wire [(SECONDS_WIDTH - 1) : 0] stopwatch_instance_seconds_passed;
	
	stopwatch
		# (
			.SECONDS_WIDTH(SECONDS_WIDTH)
		)
	stopwatch_instance
		(
			.async_reset(async_reset),
			.clk(clk),
			.continue_pause(continue_pause_red),
			.seconds_passed(stopwatch_instance_seconds_passed)
		);
		
	assign seconds_passed_led = stopwatch_instance_seconds_passed;
		
	genvar i;
	generate
		for (i = 0; i < NUM_OF_7SEGS; i = i + 1) begin : generate_block
			wire [3 : 0] digit = (stopwatch_instance_seconds_passed / (10 ** i)) % 10;
			wire [7 : 0] digit_seven_seg = sevenseg(digit);
			assign seconds_passed_7segs[8 * (i+1) - 1 : 8 * i] = digit_seven_seg;
		end
	endgenerate
	
	
	function [7 : 0] sevenseg
	(
		input [3 : 0] digit
	);
	begin
		case (digit)
			4'b0000: sevenseg = 8'hC0;
			4'b0001: sevenseg = 8'hF9;
			4'b0010: sevenseg = 8'hA4;
			4'b0011: sevenseg = 8'hB0;
			4'b0100: sevenseg = 8'h99;
			4'b0101: sevenseg = 8'h92;
			4'b0110: sevenseg = 8'h82;
			4'b0111: sevenseg = 8'hF8;
			4'b1000: sevenseg = 8'h80;
			4'b1001: sevenseg = 8'h90;
		endcase
	end
	endfunction
	
endmodule 