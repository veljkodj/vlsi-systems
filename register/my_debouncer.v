module my_debouncer
	(
		input asynch_nreset,
		input clk,
		input signal_input,
		output reg signal_output
	);
	
	reg [1 : 0] ff_next, ff_reg;
	reg output_next, output_reg;
	
	// Sequential logic block
	always @(negedge asynch_nreset, posedge clk) begin
		if(!asynch_nreset) begin
			ff_reg <= 2'b0;
			output_reg <= 1'b0;
		end
		else begin
			ff_reg <= ff_next;
			output_reg <= output_next;
		end
	end
	
	reg ctrl_load, ctrl_incr;
	wire [19 : 0] data_output;
	
	my_register
		#(.WIDTH(20))
	my_register_instance_1
		(
			.asynch_nreset(asynch_nreset),
			.clk(clk),
			.ctrl_load(ctrl_load),
			.ctrl_incr(ctrl_incr),
			.data_input(20'b0),
			.data_output(data_output)
		);
	
	// Combinational logic block (next state)
	always @(*) begin
		ff_next[0] <= signal_input;
		ff_next[1] <= ff_reg[0];
		output_next <= output_reg;
		ctrl_load <= 1'b0;
		ctrl_incr <= 1'b1;
		
		if (ff_reg[0] ^ ff_reg[1]) begin
			ctrl_load <= 1'b1;
		end
		
		if (data_output == 20'h7_A120) begin
			ctrl_incr <= 1'b0;
			output_next <= ff_reg[1];
		end
	end
	
	// Combinational logic block (output)
	always @(*) begin
		signal_output <= output_reg;
	end
	
endmodule
