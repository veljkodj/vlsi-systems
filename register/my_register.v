module my_register
	#(
		parameter WIDTH = 8
	)
	(
		input asynch_nreset,
		input clk,
		input ctrl_load,
		input ctrl_incr,
		input [WIDTH - 1 : 0] data_input,
		output reg [WIDTH - 1 : 0] data_output
	);
	
	reg [WIDTH - 1 : 0] data_next, data_reg;
	
	// Sequential logic block
	always @(negedge asynch_nreset, posedge clk) begin
		if (!asynch_nreset) begin
			data_reg <= { WIDTH{1'b0} };
		end
		else begin
			data_reg <= data_next;
		end
	end
	
	// Combinational logic block (next state)
	always @(*) begin
		data_next <= data_reg;
		if (ctrl_incr) begin
			data_next <= data_reg + { {(WIDTH - 1){1'b0}}, 1'b1 };
		end
		if (ctrl_load) begin
			data_next <= data_input;
		end
	end
	
	// Combinational logic block (output)
	always @(*) begin
		data_output <= data_reg;
	end
	
endmodule
