`include "register.vh"

module stove
	(
		input async_reset,
		input clk,
		input power_toggle,
		input [1 : 0] surface_toggle,
		input power_level_inc,
		input power_level_dec,
		input three_seconds_push,
		output reg [15 : 0] power_level_7seg_output
	);
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] power_ctrl;
	reg power_data_input;
	wire power_data_output;
	
	register
		#(
			.WIDTH(1)
		)
	power
		(
			.async_reset(async_reset),
			.clk(clk),
			.ctrl(power_ctrl),
			.data_input(power_data_input),
			.data_output(power_data_output)
		);
		
	reg [(`REG_CTRL_WIDTH - 1) : 0] selected_surface_ctrl;
	reg [1 : 0] selected_surface_data_input;
	wire [1 : 0] selected_surface_data_output;
	
	register
		#(
			.WIDTH(2)
		)
	selected_surface
		(
			.async_reset(async_reset),
			.clk(clk),
			.ctrl(selected_surface_ctrl),
			.data_input(selected_surface_data_input),
			.data_output(selected_surface_data_output)
		);
		
	reg [(`REG_CTRL_WIDTH - 1) : 0] power_level_A_ctrl;
	reg [3 : 0] power_level_A_data_input;
	wire [3 : 0] power_level_A_data_output;
	
	register
		#(
			.WIDTH(4)
		)
	power_level_A
		(
			.async_reset(async_reset),
			.clk(clk),
			.ctrl(power_level_A_ctrl),
			.data_input(power_level_A_data_input),
			.data_output(power_level_A_data_output)
		);
		
	reg [(`REG_CTRL_WIDTH - 1) : 0] power_level_B_ctrl;
	reg [3 : 0] power_level_B_data_input; 
	wire [3 : 0] power_level_B_data_output;
	
	register
		#(
			.WIDTH(4)
		)
	power_level_B
		(
			.async_reset(async_reset),
			.clk(clk),
			.ctrl(power_level_B_ctrl),
			.data_input(power_level_B_data_input),
			.data_output(power_level_B_data_output)
		);
		
	reg [(`REG_CTRL_WIDTH - 1) : 0] security_lock_ctrl;
	reg security_lock_data_input; 
	wire security_lock_data_output;
	
	register
		#(
			.WIDTH(1)
		)
	security_lock
		(
			.async_reset(async_reset),
			.clk(clk),
			.ctrl(security_lock_ctrl),
			.data_input(security_lock_data_input),
			.data_output(security_lock_data_output)
		);
		
	localparam ONE_SECOND = 50_000_000;
		
	reg [(`REG_CTRL_WIDTH - 1) : 0] timer_ctrl;
	reg [27 : 0] timer_data_input; 
	wire [27 : 0] timer_data_output;
	
	register
		#(
			.WIDTH(28)
		)
	timer
		(
			.async_reset(async_reset),
			.clk(clk),
			.ctrl(timer_ctrl),
			.data_input(timer_data_input),
			.data_output(timer_data_output)
		);
		
	reg [(`REG_CTRL_WIDTH - 1) : 0] A_timer_ctrl;
	reg [31 : 0] A_timer_data_input; 
	wire [31 : 0] A_timer_data_output;
	
	register
		#(
			.WIDTH(32)
		)
	A_timer
		(
			.async_reset(async_reset),
			.clk(clk),
			.ctrl(A_timer_ctrl),
			.data_input(A_timer_data_input),
			.data_output(A_timer_data_output)
		);
		
	reg [(`REG_CTRL_WIDTH - 1) : 0] A_recently_on_ctrl;
	reg A_recently_on_data_input; 
	wire A_recently_on_data_output;
	
	register
		#(
			.WIDTH(1)
		)
	A_recently_on
		(
			.async_reset(async_reset),
			.clk(clk),
			.ctrl(A_recently_on_ctrl),
			.data_input(A_recently_on_data_input),
			.data_output(A_recently_on_data_output)
		);
		
	reg [(`REG_CTRL_WIDTH - 1) : 0] B_timer_ctrl;
	reg [31 : 0] B_timer_data_input; 
	wire [31 : 0] B_timer_data_output;
	
	register
		#(
			.WIDTH(32)
		)
	B_timer
		(
			.async_reset(async_reset),
			.clk(clk),
			.ctrl(B_timer_ctrl),
			.data_input(B_timer_data_input),
			.data_output(B_timer_data_output)
		);
		
	reg [(`REG_CTRL_WIDTH - 1) : 0] B_recently_on_ctrl;
	reg B_recently_on_data_input; 
	wire B_recently_on_data_output;
	
	register
		#(
			.WIDTH(1)
		)
	B_recently_on
		(
			.async_reset(async_reset),
			.clk(clk),
			.ctrl(B_recently_on_ctrl),
			.data_input(B_recently_on_data_input),
			.data_output(B_recently_on_data_output)
		);
		
	localparam STATE_POWER_OFF = 3'b000;
	localparam STATE_POWER_ON = 3'b001;
	localparam STATE_SECOND_STEP_TO_LOCK = 3'b010;
	localparam STATE_2SEC_LL = 3'b011;
	localparam STATE_SECOND_STEP_TO_UNLOCK = 3'b100;
	localparam STATE_10SEC_HH = 3'b101;
		
	reg [2 : 0] state_next, state_reg;
	
	always @(negedge async_reset, posedge clk) begin
		if (!async_reset) begin
			state_reg <= STATE_POWER_OFF;
		end else begin
			state_reg <= state_next;
		end
	end
		
	always @(*) begin
	
		power_data_input <= 1'b0;
		power_ctrl <= `REG_CTRL_NOP;
	
		selected_surface_data_input <= 2'b00;
		selected_surface_ctrl <= `REG_CTRL_NOP;
		
		power_level_A_data_input <= 4'b0000;
		power_level_A_ctrl <= `REG_CTRL_NOP;
		
		power_level_B_data_input <= 4'b0000;
		power_level_B_ctrl <= `REG_CTRL_NOP;
		
		security_lock_data_input <= 1'b0;
		security_lock_ctrl <= `REG_CTRL_NOP;
		
		timer_data_input <= {28{1'b0}};
		timer_ctrl <= `REG_CTRL_NOP;
		
		A_timer_data_input <= {32{1'b0}};
		A_timer_ctrl <= `REG_CTRL_NOP;
		
		A_recently_on_data_input <= 1'b0;
		A_recently_on_ctrl <= `REG_CTRL_NOP;
		
		B_timer_data_input <= {32{1'b0}};
		B_timer_ctrl <= `REG_CTRL_NOP;
		
		B_recently_on_data_input <= 1'b0;
		B_recently_on_ctrl <= `REG_CTRL_NOP;
	
		state_next <= state_reg;
	
		power_level_7seg_output <= 16'hFFFF;
		
		case (state_reg)
			STATE_POWER_OFF: begin
			
				if (power_toggle == 1'b1) begin
					selected_surface_data_input <= 2'b00;
					selected_surface_ctrl <= `REG_CTRL_LD;
					state_next <= STATE_POWER_ON;
				end
				
				power_level_7seg_output <= 16'hFFFF;
				
			end
			STATE_POWER_ON: begin
				
				if (surface_toggle[0] == 1'b1) begin // A
					if (selected_surface_data_output & 2'b01)
						selected_surface_data_input <= selected_surface_data_output & 2'b10;
					else 
						selected_surface_data_input <= selected_surface_data_output | 2'b01;
					selected_surface_ctrl <= `REG_CTRL_LD;
				end
				
				if (surface_toggle[1] == 1'b1) begin // B
					if (selected_surface_data_output & 2'b10)
						selected_surface_data_input <= selected_surface_data_output & 2'b01;
					else 
						selected_surface_data_input <= selected_surface_data_output | 2'b10;
					selected_surface_ctrl <= `REG_CTRL_LD;
				end
				
				if (security_lock_data_output == 1'b0 && power_level_inc == 1'b1) begin
					
					if (selected_surface_data_output & 2'b01 && power_level_A_data_output < 4'd9) begin
						power_level_A_ctrl <= `REG_CTRL_INC;
						A_recently_on_data_input <= 1'b0;
						A_recently_on_ctrl <= `REG_CTRL_LD;
						A_timer_ctrl <= `REG_CTRL_CLR;
					end
						
					if (selected_surface_data_output & 2'b10 && power_level_B_data_output < 4'd9) begin
						power_level_B_ctrl <= `REG_CTRL_INC;
						B_recently_on_data_input <= 1'b0;
						B_recently_on_ctrl <= `REG_CTRL_LD;
						B_timer_ctrl <= `REG_CTRL_CLR;
					end
					
				end
				
				if (security_lock_data_output == 1'b0 && power_level_dec == 1'b1) begin
					
					if (selected_surface_data_output & 2'b01 && power_level_A_data_output > 4'd0) begin
						power_level_A_ctrl <= `REG_CTRL_DEC;
						if (power_level_A_data_output == 4'd1) begin
							A_recently_on_data_input <= 1'b1;
							A_recently_on_ctrl <= `REG_CTRL_LD;
							A_timer_ctrl <= `REG_CTRL_CLR;
						end
					end
						
					if (selected_surface_data_output & 2'b10 && power_level_B_data_output > 4'd0) begin
						power_level_B_ctrl <= `REG_CTRL_DEC;
						if (power_level_B_data_output == 4'd1) begin
							B_recently_on_data_input <= 1'b1;
							B_recently_on_ctrl <= `REG_CTRL_LD;
							B_timer_ctrl <= `REG_CTRL_CLR;
						end
					end
					
				end
				
				if (A_recently_on_data_output == 1'b1) begin
					
					if (A_timer_data_output == 10  * ONE_SECOND) begin
						A_timer_ctrl <= `REG_CTRL_CLR;
						A_recently_on_data_input <= 1'b0;
						A_recently_on_ctrl <= `REG_CTRL_LD;
					end else begin
						A_timer_ctrl <= `REG_CTRL_INC;
					end
					
				end
				
				if (B_recently_on_data_output == 1'b1) begin
					
					if (B_timer_data_output == 10  * ONE_SECOND) begin
						B_timer_ctrl <= `REG_CTRL_CLR;
						B_recently_on_data_input <= 1'b0;
						B_recently_on_ctrl <= `REG_CTRL_LD;
					end else begin
						B_timer_ctrl <= `REG_CTRL_INC;
					end
					
				end
				
				if (selected_surface_data_output == 2'b00 && power_level_A_data_output == 4'b0000 && power_level_B_data_output == 4'b0000) begin
					if (security_lock_data_output == 1'b0 &&  three_seconds_push == 1'b1)
						state_next <= STATE_SECOND_STEP_TO_LOCK;
				end
				
				if (security_lock_data_output == 1'b1 && three_seconds_push == 1'b1) begin
					state_next <= STATE_SECOND_STEP_TO_UNLOCK;
				end
				
				if (power_toggle == 1'b1) begin
					if (A_recently_on_data_output == 1'b0 && B_recently_on_data_output == 1'b0) begin
						state_next <= STATE_POWER_OFF;
					end else begin
						timer_ctrl <= `REG_CTRL_CLR;
						state_next <= STATE_10SEC_HH;
					end
				end
				
				if (security_lock_data_output <= 1'b1) begin
					power_level_7seg_output <= 16'hC7C7;
				end else begin
					power_level_7seg_output <= {selected_surface_data_output & 2'b10 ? 1'b0 : 1'b1, encode(power_level_B_data_output), selected_surface_data_output & 2'b01 ? 1'b0 : 1'b1, encode(power_level_A_data_output)};
				end
				
			end
			
			STATE_SECOND_STEP_TO_LOCK: begin
			
				if (power_level_inc == 1'b1) begin
					security_lock_data_input <= 1'b1;
					security_lock_ctrl <= `REG_CTRL_LD;
					timer_ctrl <= `REG_CTRL_CLR;
					state_next <= STATE_2SEC_LL;
				end
			
			end
			
			STATE_2SEC_LL: begin
			
				if (timer_data_output == 2  * ONE_SECOND) begin
					timer_ctrl <= `REG_CTRL_CLR;
					state_next <= STATE_POWER_OFF;
				end else begin
					timer_ctrl <= `REG_CTRL_INC;
				end
				
				power_level_7seg_output <= 16'hC7C7;
			
			end
			
			STATE_SECOND_STEP_TO_UNLOCK: begin
			
				if (power_level_dec == 1'b1) begin
					security_lock_data_input <= 1'b0;
					security_lock_ctrl <= `REG_CTRL_LD;
					state_next <= STATE_POWER_ON;
				end
			
			end
			
			STATE_10SEC_HH: begin
				
				if (timer_data_output == 10  * ONE_SECOND) begin
					timer_ctrl <= `REG_CTRL_CLR;
					A_timer_ctrl <= `REG_CTRL_CLR;
					A_recently_on_ctrl <= `REG_CTRL_CLR;
					B_timer_ctrl <= `REG_CTRL_CLR;
					B_recently_on_ctrl <= `REG_CTRL_CLR;
					state_next <= STATE_POWER_OFF;
				end else begin
					timer_ctrl <= `REG_CTRL_INC;
				end
				
				power_level_7seg_output <= { B_recently_on_data_output == 1'b1 ? 8'h89 : 8'hFF, A_recently_on_data_output == 1'b1 ? 8'h89 : 8'hFF};
			
			end
			
		endcase
		
	end
	
	function automatic [6 : 0] encode
		(
			input [3 : 0] digit
		);
	begin
		case (digit)
			4'b0000: encode = 7'h40;
			4'b0001: encode = 7'h79;
			4'b0010: encode = 7'h24;
			4'b0011: encode = 7'h30;
			4'b0100: encode = 7'h19;
			4'b0101: encode = 7'h12;
			4'b0110: encode = 7'h02;
			4'b0111: encode = 7'h78;
			4'b1000: encode = 7'h00;
			4'b1001: encode = 7'h10;
		endcase
	end
	endfunction
	
endmodule