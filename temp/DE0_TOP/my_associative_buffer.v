`include "my_associative_buffer.vh"
`include "my_register.vh"

module my_associative_buffer
	#(
		parameter CTRL_WIDTH = `MY_ASSOCIATIVE_BUFFER_CTRL_WIDTH,
		parameter KEY_WIDTH = 8,
		parameter DATA_WIDTH = 8,
		parameter DATA_NUMBER_LOG2 = 3
	)
	(
		input clk,
		input rst,
		input [(CTRL_WIDTH - 1) : 0] ctrl,
		input [(KEY_WIDTH - 1) : 0] key_input,
		input [(DATA_WIDTH - 1) : 0] data_input,
		output reg [(DATA_WIDTH - 1) : 0] data_output,
		output reg data_valid,
		input trigger_display
	);
	
	localparam DATA_NUMBER = 2**DATA_NUMBER_LOG2;
	
	localparam CTRL_NOP = `MY_ASSOCIATIVE_BUFFER_CTRL_NOP;
	localparam CTRL_CLR = `MY_ASSOCIATIVE_BUFFER_CTRL_CLR;
	localparam CTRL_LOAD = `MY_ASSOCIATIVE_BUFFER_CTRL_LOAD;
	localparam CTRL_INCR = `MY_ASSOCIATIVE_BUFFER_CTRL_INCR;
	localparam CTRL_DECR = `MY_REGISTER_CTRL_DECR;
	
	reg [(CTRL_WIDTH - 1) : 0] valid_registers_ctrl [(DATA_NUMBER - 1) : 0];
	reg valid_registers_input [(DATA_NUMBER - 1) : 0];
	wire valid_registers_output [(DATA_NUMBER - 1) : 0];
	
	reg [(CTRL_WIDTH - 1) : 0] key_registers_ctrl [(DATA_NUMBER - 1) : 0];
	wire [(KEY_WIDTH - 1) : 0] key_registers_output [(DATA_NUMBER - 1) : 0];
	
	reg [(CTRL_WIDTH - 1) : 0] data_registers_ctrl [(DATA_NUMBER - 1) : 0];
	wire [(DATA_WIDTH - 1) : 0] data_registers_output [(DATA_NUMBER - 1) : 0];
	
	reg [(CTRL_WIDTH - 1) : 0] lru_registers_ctrl [(DATA_NUMBER - 1) : 0];
	reg [(DATA_NUMBER_LOG2 - 1) : 0] lru_registers_input [(DATA_NUMBER - 1) : 0];
	wire [(DATA_NUMBER_LOG2 - 1) : 0] lru_registers_output [(DATA_NUMBER - 1) : 0];
	
	wire key_comparators_output [(DATA_NUMBER - 1) : 0];
	reg hit_occurred;
	reg [(DATA_NUMBER_LOG2 - 1) : 0] hit_index;
	
	genvar i;
	
	generate
		for (i = 0; i < DATA_NUMBER; i = i + 1) begin : registers_generate_block
			my_register
				#(
					.DATA_WIDTH(1)
				)
			valid
				(
					.rst(rst),
					.clk(clk),
					.ctrl(valid_registers_ctrl[i]),
					.data_input(valid_registers_input[i]),
					.data_output(valid_registers_output[i])
				);
				
			my_register
				#(
					.DATA_WIDTH(KEY_WIDTH)
				)
			key
				(
					.rst(rst),
					.clk(clk),
					.ctrl(key_registers_ctrl[i]),
					.data_input(key_input),
					.data_output(key_registers_output[i])
				);
				
			assign key_comparators_output[i] = key_registers_output[i] == key_input;
				
			my_register
				#(
					.DATA_WIDTH(DATA_WIDTH)
				)
			data
				(
					.rst(rst),
					.clk(clk),
					.ctrl(data_registers_ctrl[i]),
					.data_input(data_input),
					.data_output(data_registers_output[i])
				);
				
			my_register
				#(
					.DATA_WIDTH(DATA_NUMBER_LOG2)
				)
			lru
				(
					.rst(rst),
					.clk(clk),
					.ctrl(lru_registers_ctrl[i]),
					.data_input(lru_registers_input[i]),
					.data_output(lru_registers_output[i])
				);
		end
	endgenerate
	
	// TIMER
	// ========================================================================================
	localparam TICK_NUM_1000_MS = 50_000_000;
	
	localparam TIMER_WIDTH = 28;
	
	reg [(CTRL_WIDTH - 1) : 0] timer_ctrl;
	wire [(TIMER_WIDTH - 1) : 0] timer_output;
	
	my_register
		#(
			.DATA_WIDTH(TIMER_WIDTH)
		)
	timer
		(
			.clk(clk),
			.rst(rst),
			.ctrl(timer_ctrl),
			.data_input({TIMER_WIDTH{1'b0}}),
			.data_output(timer_output)
		);
		
	// LAST DISPLAYED VALID VALUE INDEX 
	// ========================================================================================	
	reg [(CTRL_WIDTH - 1) : 0] last_index_ctrl;
	reg [(DATA_NUMBER_LOG2 - 1) : 0] last_index_input;
	wire [(DATA_NUMBER_LOG2 - 1) : 0] last_index_output;
	
	my_register
		#(
			.DATA_WIDTH(DATA_NUMBER_LOG2)
		)
	last_index
		(
			.clk(clk),
			.rst(rst),
			.ctrl(last_index_ctrl),
			.data_input(last_index_input),
			.data_output(last_index_output)
		);
	
	// FINITE STATE MACHINE
	// ========================================================================================
	localparam STATE_NORMAL = 1'b0;
	localparam STATE_DISPLAY = 1'b1;
	
	reg state_reg, state_next;
	
	always @(posedge clk, negedge rst) begin
		if (!rst) begin
			state_reg <= STATE_NORMAL;
		end
		else begin
			state_reg <= state_next;
		end
	end
	
	reg [(DATA_WIDTH - 1) : 0] data_output_normal, data_output_display;
	reg data_valid_normal, data_valid_display;
	
	always @(*) begin : finite_state_machine
		integer i;
		last_index_input <= {(DATA_NUMBER_LOG2 - 1){1'b0}};
		last_index_ctrl <= CTRL_NOP;
		timer_ctrl <= CTRL_NOP;
		data_output <= {DATA_WIDTH{1'b0}};
		data_valid <= 1'b0;
		state_next <= state_reg;
		case (state_reg)
			STATE_NORMAL : begin
				if (trigger_display) begin
					begin : find_first_valid
						for (i = 0; i < DATA_NUMBER; i = i + 1) begin
							if (valid_registers_output[i] == 1'b1) begin
								last_index_input <= i[(DATA_NUMBER_LOG2 - 1) : 0];
								last_index_ctrl <= CTRL_LOAD;
								disable find_first_valid;
							end
						end
					end
					timer_ctrl <= CTRL_CLR;
					state_next <= STATE_DISPLAY;
				end
				data_output <= data_output_normal;
				data_valid <= data_valid_normal;
			end
			STATE_DISPLAY : begin
				if (timer_output == TICK_NUM_1000_MS) begin : timer_overflow
					integer next_valid_exists;
					next_valid_exists = 0;
					begin : find_next_valid
						for (i = 0; i < DATA_NUMBER; i = i + 1) begin
							if (valid_registers_output[i] == 1'b1 && i > last_index_output) begin
								last_index_input <= i[(DATA_NUMBER_LOG2 - 1) : 0];
								last_index_ctrl <= CTRL_LOAD;
								next_valid_exists = 1;
								disable find_next_valid;
							end
						end
					end
					if (next_valid_exists) begin
						timer_ctrl <= CTRL_CLR;
					end
					else begin
						last_index_ctrl <= CTRL_CLR;
						state_next <= STATE_NORMAL;
					end
				end
				else begin
					timer_ctrl <= CTRL_INCR;
				end
				data_output <= data_output_display;
				data_valid <= data_valid_display;
			end
			default : begin
			end
		endcase
	end
	
	always @(*) begin : hit_block
		integer i;
		hit_occurred <= 1'b0;
		hit_index <= {DATA_NUMBER_LOG2{1'b0}};
		begin : check_hit_occurred
			for (i = 0; i < DATA_NUMBER; i = i + 1) begin
				if (valid_registers_output[i] == 1'b1 && key_comparators_output[i] == 1'b1) begin
					hit_occurred <= 1'b1;
					hit_index <= i[(DATA_NUMBER_LOG2 - 1) : 0];
					disable check_hit_occurred;
				end
			end
		end
	end
	
	always @(*) begin
		data_output_normal <= (hit_occurred == 1'b1) ? data_registers_output[hit_index] : {DATA_WIDTH{1'b0}};
		data_valid_normal <= (hit_occurred == 1'b1) ? 1'b1 : 1'b0;
	end
	
	always @(*) begin
		data_output_display <= data_registers_output[last_index_output];
		data_valid_display <= 1'b0;
	end
	
	always @(*) begin : update_block
		integer i;
		for (i = 0; i < DATA_NUMBER; i = i + 1) begin
			valid_registers_input[i] <= 1'b0;
			valid_registers_ctrl[i] <= CTRL_NOP;
			key_registers_ctrl[i] <= CTRL_NOP;
			data_registers_ctrl[i] <= CTRL_NOP;
			lru_registers_input[i] <= lru_registers_output[i];
			lru_registers_ctrl[i] <= CTRL_NOP;
		end
		if (ctrl != CTRL_NOP) begin
			if (hit_occurred == 1'b0) begin : hit_not_occurred_block
				integer lru_index;
				lru_index = 0;
				begin : find_lru_index
					for (i = 0; i < DATA_NUMBER; i = i + 1) begin
						if (lru_registers_output[i] == 0) begin
							lru_index = i;
							disable find_lru_index;
						end
					end
				end
				for (i = 0; i < DATA_NUMBER; i = i + 1) begin
					if (lru_registers_output[i] > lru_registers_output[lru_index]) begin
						lru_registers_ctrl[i] <= CTRL_DECR;
					end
				end
				lru_registers_input[lru_index] <= DATA_NUMBER[(DATA_NUMBER_LOG2 - 1) : 0] - {{(DATA_NUMBER_LOG2 - 1){1'b0}}, 1'b1};
				lru_registers_ctrl[lru_index] <= CTRL_LOAD;
				valid_registers_input[lru_index] <= 1'b1;
				valid_registers_ctrl[lru_index] <= CTRL_LOAD;
				key_registers_ctrl[lru_index] <= CTRL_LOAD;
				data_registers_ctrl[lru_index] <= ctrl;
			end
			else begin : hit_occurred_block
				for (i = 0; i < DATA_NUMBER; i = i + 1) begin
					if (lru_registers_output[i] > lru_registers_output[hit_index]) begin
						lru_registers_ctrl[i] <= CTRL_DECR;
					end
				end
				lru_registers_input[hit_index] <= DATA_NUMBER[(DATA_NUMBER_LOG2 - 1) : 0] - {{(DATA_NUMBER_LOG2 - 1){1'b0}}, 1'b1};
				lru_registers_ctrl[hit_index] <= CTRL_LOAD;
				data_registers_ctrl[hit_index] <= ctrl;
			end
		end
	end
	
endmodule
