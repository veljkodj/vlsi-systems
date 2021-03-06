`include "register.vh"

module pushed_button_duration
	(
		input clk,
		input async_reset,
		input signal_input,
		output reg short_push,
		output reg long_push
	);
	
	localparam ONE_SECOND = 28'h2FAF080;
	
	reg [(`REG_CTRL_WIDTH - 1) : 0]  cntr_ctrl;
	wire [27 : 0] cntr_data_output;
	
	register
	#(
		.WIDTH(28)
	)
	cntr
	(
		.async_reset(async_reset),
		.clk(clk),
		.ctrl(cntr_ctrl),
		.data_input({28{1'b0}}),
		.data_output(cntr_data_output)
	);
	
	reg ff1_next, ff1_reg;
	reg ff2_next, ff2_reg;
	
	always @(negedge async_reset, posedge clk) begin
		if (~async_reset) begin
			ff1_reg <= 1'b0;
			ff2_reg <= 1'b0;
		end else begin
			ff1_reg <= ff1_next;
			ff2_reg <= ff2_next;
		end
	end
	
	always @(*) begin
		
		ff1_next <= signal_input;
		ff2_next <= ff1_reg;
		
		cntr_ctrl <= `REG_CTRL_NOP;
		
		short_push <= 1'b0;
		long_push <= 1'b0;
		
		if (ff2_reg == 1'b0 && ff1_reg == 1'b1) // rising edge
			cntr_ctrl <= `REG_CTRL_INC;
		else if (ff2_reg == 1'b1 && ff1_reg == 1'b1) // keep counting
			cntr_ctrl <= `REG_CTRL_INC;
		else if (ff2_reg == 1'b1 && ff1_reg == 1'b0) begin // falling edge
		
			if (cntr_data_output >= 3 * ONE_SECOND)
				long_push <= 1'b1;
			else 
				short_push <= 1'b1;
		
			cntr_ctrl <= `REG_CTRL_CLR;
			
		end
		
	end
	
endmodule