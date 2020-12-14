`include "register.vh"

module my_top
	(
		input async_reset,
		input clk,
		input [2 : 0] toggle_diode,
		output reg [2 : 0] blinking
	);
	
	localparam _250ms  = 28'h0BE_BC20;
	
	wire [2 : 0] toggle_diode_red;
	
	reg [2 : 0] cntr_ctrl [2 : 0];
	wire [27 : 0] cntr_data_output [2 : 0];
	
	genvar j;
	generate 
		for (j = 0; j < 3; j = j + 1) begin : block_generate
		
			rising_edge_detector rising_edge_detector_instance
			(
				.async_reset(async_reset),
				.clk(clk),
				.signal_input(toggle_diode[j]),
				.signal_output(toggle_diode_red[j])
			);
			
			register
				#(
					.WIDTH(28)
				)
			cntr
				(
					.async_reset(async_reset),
					.clk(clk),
					.ctrl(cntr_ctrl[j]),
					.data_input({28{1'b0}}),
					.data_output(cntr_data_output[j])
				);
			
		end
	endgenerate
	
	reg [2 : 0] diode_state_reg, diode_state_next;
	reg [2 : 0] diode_should_blink_reg, diode_should_blink_next;
	
	always @(posedge clk, negedge async_reset) begin
		if (!async_reset) begin
			diode_state_reg <= 3'b000;
			diode_should_blink_reg <= 3'b000;
		end else begin
			diode_state_reg <= diode_state_next;
			diode_should_blink_reg <= diode_should_blink_next;
		end
	end
	
	localparam ACTIVE   = 1'b1;
	localparam INACTIVE = 1'b0;
	
	always @(*) begin
		integer i;
		
		/* default values */
		for (i = 0; i < 3; i = i + 1)
			cntr_ctrl[i] <= `REG_CTRL_INC;
		
		diode_state_next <= diode_state_reg;
		diode_should_blink_next <= diode_should_blink_reg;
		
		blinking <= 3'b000;
		/* default values */
		
		for (i = 0; i < 3; i = i + 1)
			if (toggle_diode_red[i] == 1'b1)
				diode_should_blink_next[i] <= diode_should_blink_reg[i] == ACTIVE ? INACTIVE : ACTIVE;
		
		for (i = 0; i < 3; i = i + 1)
			if (cntr_data_output[i] == (i + 1) * _250ms) begin
				cntr_ctrl[i] <= `REG_CTRL_CLR;
				if (diode_should_blink_reg[i] == ACTIVE) begin
					diode_state_next[i]  <= diode_state_reg[i] == ACTIVE ? INACTIVE : ACTIVE;
				end
			end
			
		blinking <= diode_state_reg;
		
	end
	
endmodule