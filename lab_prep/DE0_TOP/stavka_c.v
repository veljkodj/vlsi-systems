module stavka_c
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
	
	always @(negedge rst_n, posedge clk) begin
		integer i;
		if (!rst_n) begin
			for (i = 0; i < 3; i = i + 1)
				rounded_buffer_reg[i] <= 4'h0;
			write_pos_reg <= 0;
		end else begin
			for (i = 0; i < 3; i = i + 1)
				rounded_buffer_reg[i] <= rounded_buffer_next[i];
			write_pos_reg <= write_pos_next;
		end
	end
	
	always @(*) begin
		
		integer i;
		
		for (i = 0; i < 3; i = i + 1)
			rounded_buffer_next[i] <= rounded_buffer_reg[i];
		write_pos_next <= write_pos_reg;
		
		if (ld_red) begin
			rounded_buffer_next[write_pos_reg] <= data_in;
			write_pos_next <= write_pos_reg < 2 ? write_pos_reg + 1 : 0;
		end 
		else if (inc_red) begin
			write_pos_next <= write_pos_reg < 2 ? write_pos_reg + 1 : 0;
		end
		
	end
	
	always @(*) begin
		data_out <= rounded_buffer_reg[write_pos_reg];
	end

endmodule