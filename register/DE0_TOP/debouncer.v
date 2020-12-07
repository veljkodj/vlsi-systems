`include "register.vh"

module debouncer
	(
		input async_reset,
		input clk,
		input signal_input,
		output reg signal_output
	);
	
	reg ff1_reg, ff1_next;
	reg ff2_reg, ff2_next;
	reg output_reg, output_next;
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] counter_ctrl;
	wire [19 : 0] counter_output;
	
	register 
		#(
			.WIDTH(20)
		)
	counter
		(
			.async_reset(async_reset),
			.clk(clk),
			.ctrl(counter_ctrl),
			.data_input({20{1'b0}}),
			.data_output(counter_output)
		);
		
	always @(negedge async_reset, posedge clk) begin
		if (!async_reset) begin
			output_reg <= 1'b0;
			ff1_reg <= 1'b0;
			ff2_reg <= 1'b0;
		end else begin
			output_reg <= output_next;
			ff1_reg <= ff1_next;
			ff2_reg <= ff2_next;
		end
	end
	
	always @(*) begin
		ff1_next <= signal_input;
		ff2_next <= ff1_reg;
		output_next <= output_reg;
		
		counter_ctrl <= `REG_CTRL_INC;
		
		if (ff1_reg ^ ff2_reg)
			counter_ctrl <= `REG_CTRL_LD;
		
		if (counter_output == 20'h7A120) begin
			counter_ctrl <= `REG_CTRL_NOP;
			output_next <= ff2_reg;
		end
	end
	
	always @(*) begin
		signal_output <= output_reg;
	end
	
endmodule