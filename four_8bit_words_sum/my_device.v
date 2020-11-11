module my_device
	(
		input async_reset,
		input clk,
		input [31 : 0] data_to_calculate,
		input start_calculating,
		output reg valid_output,
		output reg [9 : 0] data_output
	);
	
	reg ctrl_load_A [3 : 0];
	reg ctrl_inc_A [3 : 0];
	wire [7 : 0] data_output_A [3 : 0];
	
	reg ctrl_load_result;
	reg ctrl_inc_result;
	wire [9:0] data_output_result;
	
	reg ctrl_load_cntr;
	reg ctrl_inc_cntr;
	wire [1:0] data_output_cntr;
	
	wire adder_carry;
	wire [9:0] adder_result;
	
	wire [7:0] mx41_Y;
	
	genvar i;
	generate
		for (i = 0; i < 4; i = i + 1) begin
			register
			#(
				.WIDTH(8)
			)
			A
			(
				.async_reset(async_reset),
				.clk(clk),
				.ctrl_load(ctrl_load_A[i]),
				.ctrl_inc(ctrl_inc_A[i]),
				.data_input(data_to_calculate[(i * 8 + 7) : (i * 8)]),
				.data_output(data_output_A[i])
			);
		end
	endgenerate
	
	register
	#(
		.WIDTH(2)
	)
	cntr
	(
		.async_reset(async_reset),
		.clk(clk),
		.ctrl_load(ctrl_load_cntr),
		.ctrl_inc(ctrl_inc_cntr),
		.data_input(2'b00),
		.data_output(data_output_cntr)
	);
	
	adder
	#(
		.WIDTH(10)
	)
	adder
	(
		.operand_A({2'b0, mx41_Y}),
		.operand_B(data_output_result),
		.carry(adder_carry),
		.result(adder_result)
	);
	
	register
	#(
		.WIDTH(10)
	)
	result
	(
		.async_reset(async_reset),
		.clk(clk),
		.ctrl_load(ctrl_load_result),
		.ctrl_inc(ctrl_inc_result),
		.data_input(adder_result),
		.data_output(data_output_result)
	);
	
	mx41 mx41(
		.I0(data_output_A[0]),
		.I1(data_output_A[1]),
		.I2(data_output_A[2]),
		.I3(data_output_A[3]),
		.S(data_output_cntr),
		.Y(mx41_Y)
	);
	
	localparam WAITING 		=	2'b00;
	localparam CALCULATING 	= 	2'b01;
	localparam SHOW_RESULTS = 	2'b10;
	
	reg [1:0] state_reg, state_next;
	
	always @(negedge async_reset, posedge clk) begin
		if (!async_reset) 
			state_reg <= WAITING;
		else 
			state_reg <= state_next;
	end
	
	integer j;
	
	always @(*) begin
		
		for (j = 0; j < 4; j = j + 1) begin
			ctrl_inc_A[j]  <= 1'b0;
			ctrl_load_A[j] <= 1'b0;
		end
		
		ctrl_inc_cntr  <= 1'b0;
		ctrl_load_cntr <= 1'b0;
		
		ctrl_inc_result  <= 1'b0;
		ctrl_load_result <= 1'b0;
		
		data_output <= 10'b00_0000_0000;
		valid_output <= 1'b0;
		
		state_next <= state_reg;
		
		case (state_reg)
			
			WAITING: begin
				if (start_calculating) begin
					for (j = 0; j < 4; j = j + 1)
						ctrl_load_A[j] <= 1'b1;
					state_next <= CALCULATING;
				end
			end
			
			CALCULATING: begin
				ctrl_inc_cntr <= 1'b1;
				ctrl_load_result <= 1'b1;
				
				if (data_output_cntr == 2'b11) begin
					ctrl_inc_cntr <= 1'b0;
					state_next <= SHOW_RESULTS;
				end
			end
			
			SHOW_RESULTS: begin
				data_output <= data_output_result;
				valid_output <= 1'b1;
				state_next <= WAITING;
			end
		
		endcase
		
	end
	
endmodule