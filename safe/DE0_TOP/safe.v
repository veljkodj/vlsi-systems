`include "register.vh"

module safe
	(
		input async_reset,
		input clk,
		input short_button_push,
		input long_button_push,
		input [3 : 0] digit,
		output reg [7 : 0] seven_seg_output
	);
	
	localparam SAVED_DIGIT_0 = 0;
	localparam SAVED_DIGIT_1 = 1;
	localparam SAVED_DIGIT_2 = 2;
	localparam ENTERED_DIGIT_0 = 3;
	localparam ENTERED_DIGIT_1 = 4;
	localparam ENTERED_DIGIT_2 = 5;
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] register_ctrl [5 : 0];
	reg [3 : 0] register_data_input [5 : 0];
	wire [3 : 0] register_data_output [5 : 0];
	
	genvar i;
	generate
		for (i = 0; i < 6; i = i + 1) begin: generate_block
		
			register
			#(
				.WIDTH(4)
			)
			register
			(
				.async_reset(async_reset),
				.clk(clk),
				.ctrl(register_ctrl[i]),
				.data_input(register_data_input[i]),
				.data_output(register_data_output[i])
			);
		
		end
	endgenerate
	
	/* STATE UNLOCKED */
	
	localparam ONE_SECOND = 28'h2FAF080;
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] cntr_ctrl;
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
		
	reg [(`REG_CTRL_WIDTH - 1) : 0] round_ctrl;
	wire [1 : 0] round_data_output;
	
	register
		#(
			.WIDTH(2)
		)
	round
		(
			.async_reset(async_reset),
			.clk(clk),
			.ctrl(round_ctrl),
			.data_input({4{1'b0}}),
			.data_output(round_data_output)
		);
	
	/* STATE UNLOCKED */
	
	localparam PIN_SETUP = 2'b00;
	localparam LOCKED = 2'b01;
	localparam UNLOCKED = 2'b10;
	
	reg [1 : 0] state_reg, state_next;
	
	always @(posedge clk, negedge async_reset) begin
		if (!async_reset)
			state_reg <= PIN_SETUP;
		else
			state_reg <= state_next;
	end
	
	integer j;
	integer k;
	always @(*) begin
		
		for (j = 0; j < 6; j = j + 1) begin
			register_ctrl[j] <= `REG_CTRL_NOP;
			register_data_input[j] <= register_data_output[j];
		end
		
		cntr_ctrl <= `REG_CTRL_NOP;
		round_ctrl <= `REG_CTRL_NOP;
		
		state_next <= state_reg;
		
		seven_seg_output <= 8'hFF;
		
		case (state_reg)
		
			PIN_SETUP: begin
				
				if (short_button_push == 1'b1) begin
					
					for (k = 1; k < 3; k = k + 1) begin
						register_data_input[k-1] <= register_data_output[k];
						register_ctrl[k-1] <= `REG_CTRL_LD;
					end
					
					register_data_input[SAVED_DIGIT_2] <= digit;
					register_ctrl[SAVED_DIGIT_2] <= `REG_CTRL_LD;
					
				end
				
				if (long_button_push == 1'b1)
					state_next <= LOCKED;
					
				seven_seg_output <= seven_seg(register_data_output[SAVED_DIGIT_2]);
				
			end
		
			LOCKED: begin
			
				if (
					register_data_output[SAVED_DIGIT_0] == register_data_output[ENTERED_DIGIT_0] &&
					register_data_output[SAVED_DIGIT_1] == register_data_output[ENTERED_DIGIT_1] &&
					register_data_output[SAVED_DIGIT_2] == register_data_output[ENTERED_DIGIT_2]
				) 
					state_next <= UNLOCKED;
					
				if (short_button_push == 1'b1) begin
					
					for (k = 4; k < 6; k = k + 1) begin
						register_data_input[k-1] <= register_data_output[k];
						register_ctrl[k-1] <= `REG_CTRL_LD;
					end
					
					register_data_input[ENTERED_DIGIT_2] <= digit;
					register_ctrl[ENTERED_DIGIT_2] <= `REG_CTRL_LD;
					
				end
			
				seven_seg_output <= 8'hE3;
			
			end
			
			UNLOCKED: begin
			
				cntr_ctrl <= `REG_CTRL_INC;
				if (cntr_data_output >= 2 * ONE_SECOND) begin
					cntr_ctrl <= `REG_CTRL_CLR;
					if (round_data_output == 2'b10)
						round_ctrl <= `REG_CTRL_CLR;
					else 
						round_ctrl <= `REG_CTRL_INC;
				end
			
				if (short_button_push == 1'b1)
					state_next <= PIN_SETUP;
					
				if (long_button_push == 1'b1) begin
					for (k = 3; k < 6; k = k + 1)
						register_ctrl[k] <= `REG_CTRL_CLR;
					state_next <= LOCKED;
				end
				
				seven_seg_output <= seven_seg(register_data_output[round_data_output]);
			
			end
		
		endcase
		
	end
	
	function [7 : 0] seven_seg 
	(
		input [3 : 0] digit
	);
	begin
		case (digit)
			4'h0: seven_seg = 8'hC0;
			4'h1: seven_seg = 8'hF9;
			4'h2: seven_seg = 8'hA4;
			4'h3: seven_seg = 8'hB0;
			4'h4: seven_seg = 8'h99;
			4'h5: seven_seg = 8'h92;
			4'h6: seven_seg = 8'h82;
			4'h7: seven_seg = 8'hF8;
			4'h8: seven_seg = 8'h80;
			4'h9: seven_seg = 8'h90;
		endcase
	end
	endfunction
	
endmodule