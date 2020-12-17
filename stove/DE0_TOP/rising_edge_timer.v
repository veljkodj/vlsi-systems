module rising_edge_timer
	(
		input async_reset,
		input clk,
		input [1 : 0] signal_input,
		output reg signal_output
	);
	
	localparam ONE_SECOND = 50_000_000;
	
	reg [1 : 0] ff1_reg, ff1_next;
	reg [1 : 0] ff2_reg, ff2_next;
	integer timer_reg, timer_next;
	
	always @(negedge async_reset, posedge clk) begin
		if (!async_reset) begin
			ff1_reg <= 2'b00;
			ff2_reg <= 2'b00;
			timer_reg <= 0;
		end else begin
			ff1_reg <= ff1_next;
			ff2_reg <= ff2_next;
			timer_reg <= timer_next;
		end
	end
	
	always @(*) begin
		
		ff1_next <= signal_input;
		ff2_next <= ff1_reg;
		timer_next <= timer_reg;
	
		signal_output <= 1'b0;
	
		if (ff1_reg == 2'b11 && ff2_reg == 2'b11) begin
			timer_next <= timer_reg + 1;
		end 
		else if (ff1_reg == 2'b00 && ff2_reg == 2'b11) begin
			timer_next <= 0;
			if (timer_reg >= 3 * ONE_SECOND)
				signal_output <= 1'b1;
		end 
		
	end
	
endmodule