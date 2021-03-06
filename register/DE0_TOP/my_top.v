`include "register.vh"

module my_top
	(
		input async_reset,
		input clk,
		input [7 : 0] data_input,
		input ctrl_inc,
		input ctrl_load,
		output [7 : 0] data_output_led,
		output [31 : 0] data_output_sevensegs
	);
	
	wire ctrl_inc_deb;
	
	debouncer debouncer_instance
		(
			.async_reset(async_reset),
			.clk(clk),
			.signal_input(ctrl_inc),
			.signal_output(ctrl_inc_deb)
		);
	
	wire ctrl_inc_red;
	
	rising_edge_detector rising_edge_detector_instance
		(
			.async_reset(async_reset),
			.clk(clk),
			.signal_input(ctrl_inc_deb),
			.signal_output(ctrl_inc_red)
		);
	
	// reg [(`REG_CTRL_WIDTH - 1) : 0] register_instance_ctrl;
	wire [7 : 0] register_instance_data_output;
	
	register
		#(
			.WIDTH(8)
		)
	register_instance
		(
			.async_reset(async_reset),
			.clk(clk),
			.ctrl(ctrl_load == 1'b1 ? `REG_CTRL_LD : (ctrl_inc_red == 1'b1 ? `REG_CTRL_INC : `REG_CTRL_NOP)),
			.data_input(data_input),
			.data_output(register_instance_data_output)
		);
		
	assign data_output_led = register_instance_data_output;
	
	wire [3:0] digit_ones, digit_tens, digit_hundreds, digit_thousands;
	
	assign digit_ones      = register_instance_data_output % 10;
	assign digit_tens      = register_instance_data_output / 10 % 10;
	assign digit_hundreds  = register_instance_data_output / 100 % 10;
	assign digit_thousands = register_instance_data_output / 1000 % 10;
	
	assign data_output_sevensegs = {sevenseg(digit_thousands), sevenseg(digit_hundreds), sevenseg(digit_tens), sevenseg(digit_ones)};
	
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