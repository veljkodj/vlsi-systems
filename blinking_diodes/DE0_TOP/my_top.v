module my_top
	(
		input async_reset,
		input clk,
		input [2 : 0] toggle_diode,
		output reg [2 : 0] blinking
	);
	
	wire [2 : 0] toggle_diode_red;
	
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
		end
	endgenerate
	
	localparam _1000ms = 28'h2FA_F080;
	localparam _500ms  = 28'h17D_7840;
	localparam _250ms  = 28'h0BE_BC20;
	
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
	
	reg [2 : 0] diode_reg, diode_next;
	
	always @(posedge clk, negedge async_reset) begin
		if (!async_reset)
			diode_reg <= 3'b000;
		else
			diode_reg <= diode_next;
	end
	
	localparam ACTIVE   = 1'b1;
	localparam INACTIVE = 1'b0;
	
	integer i;
	
	always @(*) begin
		
		diode_next <= diode_reg;
		cntr_ctrl <= `REG_CTRL_INC;
		blinking <= 3'b000;
		
		for (i = 0; i < 3; i = i + 1) 
			if (toggle_diode_red[i] == 1'b1) 
				diode_next[i] = diode_reg[i] == ACTIVE ? INACTIVE : ACTIVE;
		
		if (diode_reg[0] == ACTIVE && cntr_data_output % _250ms == 0)
			blinking[0] <= 1'b1;
			
		if (diode_reg[1] == ACTIVE && cntr_data_output % _500ms == 0)
			blinking[1] <= 1'b1;
			
		if (diode_reg[2] == ACTIVE && cntr_data_output % _1000ms == 0)
			blinking[2] <= 1'b1;
		
		if (cntr_data_output == _1000ms)
			cntr_ctrl <= `REG_CTRL_CLR;
		
	end
	
endmodule