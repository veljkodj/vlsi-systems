`include "register.vh"

module stove
	(
		input async_reset,
		input clk,
		input power_toggle,
		input [1 : 0] surface_toggle,
		input power_level_inc,
		input power_level_dec,
		output reg [15 : 0] power_level_7seg_output //
	);
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] power_ctrl; //
	reg power_data_input; //
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
		
	reg [(`REG_CTRL_WIDTH - 1) : 0] selected_surface_ctrl; //
	reg [1 : 0] selected_surface_data_input; //
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
		
	reg [(`REG_CTRL_WIDTH - 1) : 0] power_level_A_ctrl; //
	reg [3 : 0] power_level_A_data_input; //
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
		
	reg [(`REG_CTRL_WIDTH - 1) : 0] power_level_B_ctrl; //
	reg [3 : 0] power_level_B_data_input; //
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
		
	localparam STATE_POWER_OFF = 2'b00;
	localparam STATE_POWER_ON = 2'b01;
		
	reg [1 : 0] state_next, state_reg; //
	
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
				
				if (power_level_inc == 1'b1) begin
					
					if (selected_surface_data_output & 2'b01 && power_level_A_data_output < 4'd9)
						power_level_A_ctrl <= `REG_CTRL_INC;
						
					if (selected_surface_data_output & 2'b10 && power_level_B_data_output < 4'd9)
						power_level_B_ctrl <= `REG_CTRL_INC;
					
				end
				
				if (power_level_dec == 1'b1) begin
					
					if (selected_surface_data_output & 2'b01 && power_level_A_data_output > 4'd0)
						power_level_A_ctrl <= `REG_CTRL_DEC;
						
					if (selected_surface_data_output & 2'b10 && power_level_B_data_output > 4'd0)
						power_level_B_ctrl <= `REG_CTRL_DEC;
					
				end
				
				if (power_toggle == 1'b1) begin
					state_next <= STATE_POWER_OFF;
				end
				
				power_level_7seg_output <= 16'h0000;
				
				// power_level_7seg_output <= {selected_surface_data_output & 2'b10 ? 1'b0 : 1'b1, encode(power_level_B_data_output), selected_surface_data_output & 2'b01 ? 1'b0 : 1'b1, encode(power_level_A_data_output)};
				
			end
		endcase
		
	end
	
	function automatic [6 : 0] encode
		(
			input [3 : 0] digit
		);
	begin
		case (digit)
			4'b0000: encode = 7'hC0;
			4'b0001: encode = 7'hF9;
			4'b0010: encode = 7'hA4;
			4'b0011: encode = 7'hB0;
			4'b0100: encode = 7'h99;
			4'b0101: encode = 7'h92;
			4'b0110: encode = 7'h82;
			4'b0111: encode = 7'hF8;
			4'b1000: encode = 7'h80;
			4'b1001: encode = 7'h90;
		endcase
	end
	endfunction
	
endmodule