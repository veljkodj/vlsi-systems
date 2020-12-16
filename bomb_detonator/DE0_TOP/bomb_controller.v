`include "register.vh"

module bomb_controller
	(
		input async_reset,
		input clk,
		input start_trigger,
		input [2 : 0] switches,
		input [2 : 0] buttons,
		output reg [31 : 0] sevenseg_output, 
		output reg [3 : 0] led_output 
	);
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] countdown_ctrl; 
	reg [15 : 0] countdown_data_input; 
	wire [15 : 0] countdown_data_output;
	
	register
	#(
		.WIDTH(16)
	)
	countdown
	(
		.async_reset(async_reset),
		.clk(clk),
		.ctrl(countdown_ctrl),
		.data_input(countdown_data_input),
		.data_output(countdown_data_output)
	);
	
	localparam _500ms = 28'h17D_7840;
	localparam _1000ms = 28'h2FA_F080;
	
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
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] active_digits_ctrl; 
	reg [3 : 0] active_digits_data_input; 
	wire [3 : 0] active_digits_data_output;
	
	register
	#(
		.WIDTH(4)
	)
	active_digits
	(
		.async_reset(async_reset),
		.clk(clk),
		.ctrl(active_digits_ctrl),
		.data_input(active_digits_data_input),
		.data_output(active_digits_data_output)
	);
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] led_ctrl; 
	reg [3 : 0] led_data_input; 
	wire [3 : 0] led_data_output;
	
	register
	#(
		.WIDTH(4)
	)
	led
	(
		.async_reset(async_reset),
		.clk(clk),
		.ctrl(led_ctrl),
		.data_input(led_data_input),
		.data_output(led_data_output)
	);
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] password_ctrl [7 : 0]; 
	reg [1 : 0] password_data_input [7 : 0]; 
	wire [1 : 0] password_data_output [7 : 0];
	
	genvar i;
	generate 
	for (i = 0; i < 8; i = i + 1) begin: password_block_generate
		register
		#(
			.WIDTH(2)
		)
		password
		(
			.async_reset(async_reset),
			.clk(clk),
			.ctrl(password_ctrl[i]),
			.data_input(password_data_input[i]),
			.data_output(password_data_output[i])
		);
	end
	endgenerate
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] pass_length_ctrl; 
	reg [3 : 0] pass_length_data_input; 
	wire [3 : 0] pass_length_data_output;
	
	register
	#(
		.WIDTH(4)
	)
	pass_length
	(
		.async_reset(async_reset),
		.clk(clk),
		.ctrl(pass_length_ctrl),
		.data_input(pass_length_data_input),
		.data_output(pass_length_data_output)
	);
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] try_ctrl [7 : 0]; 
	reg [1 : 0] try_data_input [7 : 0]; 
	wire [1 : 0] try_data_output [7 : 0];
	
	generate 
	for (i = 0; i < 8; i = i + 1) begin: try_block_generate
		register
		#(
			.WIDTH(2)
		)
		try
		(
			.async_reset(async_reset),
			.clk(clk),
			.ctrl(try_ctrl[i]),
			.data_input(try_data_input[i]),
			.data_output(try_data_output[i])
		);
	end
	endgenerate
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] try_length_ctrl; 
	reg [3 : 0] try_length_data_input; 
	wire [3 : 0] try_length_data_output;
	
	register
	#(
		.WIDTH(4)
	)
	try_length
	(
		.async_reset(async_reset),
		.clk(clk),
		.ctrl(try_length_ctrl),
		.data_input(try_length_data_input),
		.data_output(try_length_data_output)
	);
	
	localparam STATE_SETUP = 2'b00;
	localparam STATE_COUNTING = 2'b01;
	localparam STATE_BOOM = 2'b10;
	localparam STATE_FREEZE = 2'b11;
	
	reg [1 : 0] state_reg;
	reg [1 : 0] state_next; 
	
	always @(negedge async_reset, posedge clk) begin
		if (!async_reset) begin
			state_reg <= 2'b00;
		end else begin
			state_reg <= state_next;
		end
	end
	
	always @(*) begin
	
		integer i;
		integer password_match;
	
		countdown_ctrl <= `REG_CTRL_NOP;
		countdown_data_input <= {16{1'b0}};
		
		timer_ctrl <= `REG_CTRL_NOP;
		timer_data_input <= {28{1'b0}};
		
		active_digits_ctrl <= `REG_CTRL_NOP;
		active_digits_data_input <= {4{1'b0}};
		
		for (i = 0; i < 8; i = i + 1) begin
			password_data_input[i] <= 2'b00;
			password_ctrl[i] <= `REG_CTRL_NOP;
			try_data_input[i] <= 2'b00;
			try_ctrl[i] <= `REG_CTRL_NOP;
		end
		
		pass_length_data_input <= 4'b0000;
		pass_length_ctrl <= `REG_CTRL_NOP;
		
		try_length_data_input <= 4'b0000;
		try_length_ctrl <= `REG_CTRL_NOP;
		
		led_ctrl <= `REG_CTRL_NOP;
		led_data_input <= {4{1'b0}};
		
		state_next <= state_reg;
		
		led_output <= {4{1'b0}};
		sevenseg_output <= {32{1'b1}};
		
		case (state_reg)
		
			STATE_SETUP: begin
			
				if (buttons != 3'b000 && pass_length_data_output < 4'b1000) begin
				
					if (buttons[2] == 1'b1) begin
						password_data_input[pass_length_data_output] <= 2'b11;
					end else if (buttons[1] == 1'b1) begin
						password_data_input[pass_length_data_output] <= 2'b10;
					end else if (buttons[0] == 1'b1) begin
						password_data_input[pass_length_data_output] <= 2'b01;
					end 

					password_ctrl[pass_length_data_output] <= `REG_CTRL_LD;
					pass_length_ctrl <= `REG_CTRL_INC;
				
				end
				
				if (start_trigger == 1'b1) begin
					
					if (switches[2] == 1'b1) begin
						active_digits_data_input <= 4'b1111;
						countdown_data_input <= 16'd9999;
					end else if (switches[1] == 1'b1) begin
						active_digits_data_input <= 4'b0111;
						countdown_data_input <= 16'd999;
					end else if (switches[0] == 1'b1) begin
						active_digits_data_input <= 4'b0011;
						countdown_data_input <= 16'd99;
					end else begin
						active_digits_data_input <= 4'b0001;
						countdown_data_input <= 16'd9;
					end
					active_digits_ctrl <= `REG_CTRL_LD;
					countdown_ctrl <= `REG_CTRL_LD;
					
					timer_data_input <= {28{1'b0}};
					timer_ctrl <= `REG_CTRL_LD;
					
					state_next <= STATE_COUNTING;
				
				end
				
			end
			
			STATE_COUNTING: begin
			
				if (buttons != 0 && try_length_data_output < pass_length_data_output) begin
				
					if (buttons[2] == 1'b1) begin
						try_data_input[try_length_data_output] <= 2'b11;
					end else if (buttons[1] == 1'b1) begin
						try_data_input[try_length_data_output] <= 2'b10;
					end else if (buttons[0] == 1'b1) begin
						try_data_input[try_length_data_output] <= 2'b01;
					end 

					try_ctrl[try_length_data_output] <= `REG_CTRL_LD;
					try_length_ctrl <= `REG_CTRL_INC;
				
				end
				
				if (try_length_data_output == pass_length_data_output) begin
				
					password_match = 1;
					begin: do_passwords_match
					for (i = 0; i < 8; i = i + 1) begin
						if (i < pass_length_data_output && password_data_output[i] != try_data_output[i]) begin
							password_match = 0;
							disable do_passwords_match;
						end
					end
					end
					
					if (password_match == 1) begin
					
						state_next <= STATE_FREEZE;
					
					end else begin // (password_match == 0)
						
						led_data_input <= (led_data_output << 1) | 1;
						led_ctrl <= `REG_CTRL_LD;
						
						if (led_data_output == 4'h7) begin
						
							state_next <= STATE_BOOM;
						
						end else begin
							
							for (i = 0; i < 8; i = i + 1) begin
								try_data_input[i] <= 2'b00;
								try_ctrl[i] <= `REG_CTRL_LD;
							end
							
							try_length_data_input <= 4'b0000;
							try_length_ctrl <= `REG_CTRL_LD;
							
						end
						
					end
				
				end
			
				if (timer_data_output == _1000ms) begin
				
					timer_ctrl <= `REG_CTRL_CLR;
					countdown_ctrl <= `REG_CTRL_DEC;
					
					if (countdown_data_output == 0) begin
						countdown_ctrl <= `REG_CTRL_NOP;
						state_next <= STATE_BOOM;
					end
					
				end else begin
					timer_ctrl <= `REG_CTRL_INC;
				end
				
				for (i = 0; i < 4; i = i + 1) begin
					sevenseg_output[(i + 1) * 8 - 1 -: 8] <= active_digits_data_output & (1 << i) ? encode(countdown_data_output / (10 ** i) % 10) : 8'hFF;
				end
				
				led_output <= led_data_output;
				
			end
			
			STATE_BOOM: begin
			
				if (timer_data_output == _1000ms) begin
					timer_ctrl <= `REG_CTRL_CLR;
				end else begin
					timer_ctrl <= `REG_CTRL_INC;
				end
				
				for (i = 0; i < 4; i = i + 1) begin
					sevenseg_output[(i + 1) * 8 - 1 -: 8] <= active_digits_data_output & (1 << i) ? (timer_data_output <= _500ms ? 8'hBF : 8'hFF) : 8'hFF;
				end
				
				led_output <= led_data_output;
				
			end
			
			STATE_FREEZE: begin
				
				for (i = 0; i < 4; i = i + 1) begin
					sevenseg_output[(i + 1) * 8 - 1 -: 8] <= active_digits_data_output & (1 << i) ? encode(countdown_data_output / (10 ** i) % 10) : 8'hFF;
				end
				
				led_output <= led_data_output;
			
			end
		
		endcase
	
	end
	
	function automatic [7 : 0] encode 
		(
			input [3 : 0] dig
		);
	begin
		case (dig)
			4'b0000: encode = 8'hC0;
			4'b0001: encode = 8'hF9;
			4'b0010: encode = 8'hA4;
			4'b0011: encode = 8'hB0;
			4'b0100: encode = 8'h99;
			4'b0101: encode = 8'h92;
			4'b0110: encode = 8'h82;
			4'b0111: encode = 8'hF8;
			4'b1000: encode = 8'h80;
			4'b1001: encode = 8'h90;
		endcase
	end
	endfunction
	
endmodule