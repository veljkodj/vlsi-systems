`include "register.vh"

module associative_buffer
	#(
		parameter KEY_WIDTH = 8,
		parameter DATA_WIDTH = 8,
		parameter NUM_DATA_LOG2 = 3
	)
	(
		input async_reset,
		input clk,
		input [(`REG_CTRL_WIDTH - 1) : 0] ctrl,
		input [(DATA_WIDTH - 1) : 0] data_input,
		input [(KEY_WIDTH - 1) : 0] key_input,
		input trigger_read,
		output reg [(DATA_WIDTH - 1) : 0] data_output,
		output reg data_valid_output
	);
	
	localparam NUM_DATA = 2 ** NUM_DATA_LOG2;
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] valid_ctrl [(NUM_DATA - 1) : 0];
	reg valid_data_input [(NUM_DATA - 1) : 0];
	wire valid_data_output [(NUM_DATA - 1) : 0]; 
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] key_ctrl [(NUM_DATA - 1) : 0];
	wire [(KEY_WIDTH - 1) : 0] key_data_output [(NUM_DATA - 1) : 0];
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] data_ctrl [(NUM_DATA - 1) : 0];
	wire [(DATA_WIDTH - 1) : 0] data_data_output [(NUM_DATA - 1) : 0];
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] lru_ctrl [(NUM_DATA - 1) : 0];
	reg [(NUM_DATA_LOG2 - 1) : 0] lru_data_input [(NUM_DATA - 1) : 0];
	wire [(NUM_DATA_LOG2 - 1) : 0] lru_data_output [(NUM_DATA - 1) : 0]; 
	
	wire [(NUM_DATA - 1) : 0] keys_compare_res;
	
	genvar i;
	generate 
		for (i = 0; i < NUM_DATA; i = i + 1) begin: generate_associative_buffer_block
		
			register
			#(
				.WIDTH(1)
			)
			valid
			(
				.async_reset(async_reset),
				.clk(clk),
				.ctrl(valid_ctrl[i]),
				.data_input(valid_data_input[i]),
				.data_output(valid_data_output[i])
			);
			
			register
			#(
				.WIDTH(KEY_WIDTH)
			)
			key
			(
				.async_reset(async_reset),
				.clk(clk),
				.ctrl(key_ctrl[i]),
				.data_input(key_input),
				.data_output(key_data_output[i])
			);
			
			assign keys_compare_res[i] = key_data_output[i] == key_input;
			
			register
			#(
				.WIDTH(DATA_WIDTH)
			)
			data
			(
				.async_reset(async_reset),
				.clk(clk),
				.ctrl(data_ctrl[i]),
				.data_input(data_input),
				.data_output(data_data_output[i])
			);
			
			register
			#(
				.WIDTH(NUM_DATA_LOG2)
			)
			lru
			(
				.async_reset(async_reset),
				.clk(clk),
				.ctrl(lru_ctrl[i]),
				.data_input(lru_data_input[i]),
				.data_output(lru_data_output[i])
			);
		
		end
	endgenerate
	
	localparam ONE_SECOND = 28'h2FA_F080;
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] timer_ctrl;
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
		.data_input({28{1'b0}}),
		.data_output(timer_data_output)
	);
	
	reg [(`REG_CTRL_WIDTH - 1) : 0] last_read_index_ctrl;
	reg [(NUM_DATA_LOG2 - 1) : 0] last_read_index_data_input; 
	wire [(NUM_DATA_LOG2 - 1) : 0] last_read_index_data_output; 
	
	register
	#(
		.WIDTH(NUM_DATA_LOG2)
	)
	last_read_index
	(
		.async_reset(async_reset),
		.clk(clk),
		.ctrl(last_read_index_ctrl),
		.data_input(last_read_index_data_input),
		.data_output(last_read_index_data_output)
	);
	
	
	localparam STATE_NORMAL = 1'b0;
	localparam STATE_READ = 1'b1;
	
	reg state_reg, state_next;
	
	always @(posedge clk, negedge async_reset) begin
		if (!async_reset) begin
			state_reg <= 1'b0;
		end else begin
			state_reg <= state_next;
		end
	end
	
	always @(*) begin
		
		integer i;
		reg hit_occured;
		reg [(NUM_DATA_LOG2 - 1) : 0] hit_index;
		
		reg [(NUM_DATA_LOG2 - 1) : 0] lru_index;
		
		reg valid_data_found;
		reg [(NUM_DATA_LOG2 - 1) : 0] valid_data_index;
		
		i = 0;
		hit_occured = 0;
		hit_index = {NUM_DATA_LOG2{1'b0}};
		
		lru_index = {NUM_DATA_LOG2{1'b0}};
		
		valid_data_found = 0;
		valid_data_index = {NUM_DATA_LOG2{1'b0}};
		
		
		/*default values*/
		for (i = 0; i < NUM_DATA; i = i + 1) begin
			valid_data_input[i] <= 1'b0;
			valid_ctrl[i] <= `REG_CTRL_NOP;
			key_ctrl[i] <= `REG_CTRL_NOP;
			data_ctrl[i] <= `REG_CTRL_NOP;
			lru_data_input[i] <= lru_data_output[i];
			lru_ctrl[i] <= `REG_CTRL_NOP;
		end
		timer_ctrl <= `REG_CTRL_NOP;
		state_next <= state_reg;
		last_read_index_ctrl <= `REG_CTRL_NOP;
		last_read_index_data_input <= {NUM_DATA_LOG2{1'b0}};
	
		data_output <= {DATA_WIDTH{1'b0}};
		data_valid_output <= 1'b0;
		/*default values*/
		
		
		case (state_reg)
		
		STATE_NORMAL: begin
	
			hit_occured = 0;
			hit_index = {NUM_DATA_LOG2{1'b0}};
			begin: check_if_hit_occured
			for (i = 0; i < NUM_DATA; i = i + 1) begin
				if (keys_compare_res[i] == 1'b1 && valid_data_output[i] == 1'b1) begin
					hit_occured = 1;
					hit_index = i[(NUM_DATA_LOG2 - 1) : 0];
					disable check_if_hit_occured;
				end
			end
			end
		
			if (hit_occured == 1'b1) begin
				
				for (i = 0; i < NUM_DATA; i = i + 1)
					if (lru_data_output[hit_index] > lru_data_output[i])
						lru_ctrl[i] <= `REG_CTRL_DEC;
							
				lru_data_input[hit_index] <= {(NUM_DATA_LOG2){1'b1}};
				lru_ctrl[hit_index] <= `REG_CTRL_LD;
				
				if (ctrl != `REG_CTRL_NOP)
					data_ctrl[hit_index] <= ctrl;
				data_output <= data_data_output[hit_index];
				data_valid_output <= 1'b1;
			
			end else begin // hit_occured == 1'b0
			
				begin: find_lru_index
				for (i = 0; i < NUM_DATA; i = i + 1)
					if (lru_data_output[i] == {NUM_DATA_LOG2{1'b0}}) begin
						lru_index = i[(NUM_DATA_LOG2 - 1) : 0];
						disable find_lru_index;
					end
				end;
			
				for (i = 0; i < NUM_DATA; i = i + 1)
					if (lru_data_output[i] > lru_data_output[lru_index]) 
						lru_ctrl[i] <= `REG_CTRL_DEC;
				
				valid_data_input[lru_index] <= 1'b1;
				valid_ctrl[lru_index] <= `REG_CTRL_LD;
				key_ctrl[lru_index] <= `REG_CTRL_LD;
				if (ctrl != `REG_CTRL_NOP)
					data_ctrl[lru_index] <= ctrl;
				lru_data_input[lru_index] <= {NUM_DATA_LOG2{1'b1}};
				lru_ctrl[lru_index] <= `REG_CTRL_LD;
				
			end
			
			if (trigger_read == 1'b1) begin
				
				valid_data_found = 0;
				valid_data_index = {NUM_DATA_LOG2{1'b0}};
				begin: check_if_valid_data_exist
				for (i = 0; i < NUM_DATA; i = i + 1) begin
					if (valid_data_output[i] == 1'b1) begin
						valid_data_found = 1;
						valid_data_index = i[(NUM_DATA_LOG2 - 1) : 0];
						disable check_if_valid_data_exist;
					end
				end
				end
				
				if (valid_data_found == 1) begin
					last_read_index_data_input <= valid_data_index;
					last_read_index_ctrl <= `REG_CTRL_LD;
					timer_ctrl <= `REG_CTRL_CLR;
					state_next <= STATE_READ;
				end 
				
			end
		
		end
		
		STATE_READ: begin
		
			if (timer_data_output == ONE_SECOND) begin
			
				timer_ctrl <= `REG_CTRL_CLR;
				
				valid_data_found = 0;
				valid_data_index = {NUM_DATA_LOG2{1'b0}};
				begin: check_if_more_valid_data_exist
				for (i = 0; i < NUM_DATA; i = i + 1) begin
					if (valid_data_output[i] == 1'b1 && i > last_read_index_data_output) begin
						valid_data_found = 1;
						valid_data_index = i[(NUM_DATA_LOG2 - 1) : 0];
						disable check_if_more_valid_data_exist;
					end
				end
				end
				
				if (valid_data_found == 1) begin
					last_read_index_data_input <= valid_data_index;
					last_read_index_ctrl <= `REG_CTRL_LD;
				end else begin
					state_next <= STATE_NORMAL;
				end
			
			end else begin
				timer_ctrl <= `REG_CTRL_INC;
			end
				
			data_output <= data_data_output[last_read_index_data_output];
			data_valid_output <= 1'b0;
		
		end
		
		endcase
		
	end
	
endmodule