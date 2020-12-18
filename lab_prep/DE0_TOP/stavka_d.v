module stavka_d
	(
		input clk,
		input rst_n,
		input [3 : 0] data_in,
		input inc,
		input ld,
		output reg [3 : 0] data_out
	);
	
	wire inc_red; //
	
	stavka_a red_inc
	(
		.clk(clk),
		.rst_n(rst_n),
		.in(inc),
		.out(inc_red)
	);
	
	wire ld_deb;
	
	stavka_b deb_ld
	(
		.clk(clk),
		.rst_n(rst_n),
		.in(ld),
		.out(ld_deb)
	);
	
	wire ld_red; //
	
	stavka_a red_ld
	(
		.clk(clk),
		.rst_n(rst_n),
		.in(ld_deb),
		.out(ld_red)
	);
	
	reg [3 : 0] rounded_buffer_reg [2 : 0];
	reg [3 : 0] rounded_buffer_next [2 : 0];
	integer write_pos_reg; 
	integer write_pos_next;
	
	reg [3 : 0] temp_reg;
	reg [3 : 0] temp_next;
	
	localparam STATE_A = 1'b0;
	localparam STATE_B = 1'b1;
	
	reg state_reg;
	reg state_next;
	
	always @(negedge rst_n, posedge clk) begin
		integer i;
		if (!rst_n) begin
			for (i = 0; i < 3; i = i + 1)
				rounded_buffer_reg[i] <= 4'h0;
			write_pos_reg <= 0;
			temp_reg <= 4'h0;
			state_reg <= STATE_A;
		end else begin
			for (i = 0; i < 3; i = i + 1)
				rounded_buffer_reg[i] <= rounded_buffer_next[i];
			write_pos_reg <= write_pos_next;
			temp_reg <= temp_next;
			state_reg <= state_next;
		end
	end
	
	always @(*) begin
		
		integer i;
		
		integer j;
		integer zero_found;
		
		for (i = 0; i < 3; i = i + 1)
			rounded_buffer_next[i] <= rounded_buffer_reg[i];
		write_pos_next <= write_pos_reg;
		temp_next <= temp_reg;
		state_next <= state_reg;
		
		case (state_reg)
		
			STATE_A: begin
			
				if (ld_red) begin
					rounded_buffer_next[write_pos_reg] <= data_in;
					write_pos_next <= write_pos_reg < 2 ? write_pos_reg + 1 : 0;
				end 
				else if (inc_red) begin
					write_pos_next <= write_pos_reg < 2 ? write_pos_reg + 1 : 0;
				end
				
				zero_found = 0;
				begin: find_one_zero
				for (j = 0; j < 3; j = j + 1) begin
					if (rounded_buffer_reg[j] == 4'h0) begin
						zero_found = 1;
						disable find_one_zero;
					end
				end
				end
				
				if (zero_found == 0)
					state_next <= STATE_B;
					
				data_out <= rounded_buffer_reg[write_pos_reg];
			
			end
			
			STATE_B: begin
		
				if (ld_red) begin // OR
					temp_next <= rounded_buffer_reg[0] | rounded_buffer_reg[1] | rounded_buffer_reg[2];
				end 
				else begin // AND
					temp_next <= rounded_buffer_reg[0] & rounded_buffer_reg[1] & rounded_buffer_reg[2];
				end
				
				if (inc_red) begin
					for (i = 0; i < 3; i = i + 1)
						rounded_buffer_next[i] <= 4'h0;
					state_next <= STATE_A;
				end
				
				data_out <= temp_reg;

			end
		
		endcase
		
	end
	
endmodule