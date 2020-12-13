`include "register.vh"

module stopwatch
	#(
		parameter SECONDS_WIDTH = 8
	)
	(
		input async_reset,
		input clk,
		input continue_pause,
		output reg [(SECONDS_WIDTH - 1) : 0] seconds_passed
	);
	
	localparam ONE_SECOND = 28'h2FA_F080;
	
	reg [2 : 0] cntr_ctrl;
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
			.data_input(28'h000_0000),
			.data_output(cntr_data_output)
		);
	
	reg [2 : 0] seconds_ctrl;
	wire [(SECONDS_WIDTH - 1) : 0] seconds_data_output;
	
	register
		#(
			.WIDTH(SECONDS_WIDTH)
		)
	seconds
		(
			.async_reset(async_reset),
			.clk(clk),
			.ctrl(seconds_ctrl),
			.data_input({SECONDS_WIDTH{1'b0}}),
			.data_output(seconds_data_output)
		);
	
	localparam WAITING  = 2'b00;
	localparam COUNTING = 2'b01;
	localparam PAUSED   = 2'b10;
	
	reg [1 : 0] state_reg, state_next;
	
	always @(negedge async_reset, posedge clk) begin
		if (!async_reset)
			state_reg <= 2'b0;
		else
			state_reg <= state_next;
	end
	
	always @(*) begin
	
		cntr_ctrl <= `REG_CTRL_NOP;
		seconds_ctrl <= `REG_CTRL_NOP;
		state_next <= state_reg;
		seconds_passed <= seconds_data_output;
		
		case (state_reg)
			WAITING: begin
				if (continue_pause == 1'b1)
					state_next <= COUNTING;
			end
			COUNTING: begin
				cntr_ctrl <= `REG_CTRL_INC;
				if (cntr_data_output == ONE_SECOND) begin
					cntr_ctrl <= `REG_CTRL_CLR;
					seconds_ctrl <= `REG_CTRL_INC;
				end
				if (continue_pause == 1'b1)
					state_next <= PAUSED;
			end
			PAUSED: begin
				if (continue_pause == 1'b1)
					state_next <= COUNTING;
			end
		endcase
	
	end
	
endmodule