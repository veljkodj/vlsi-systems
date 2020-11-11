module adder
	#(
		parameter WIDTH = 8
	)
	(
		input [(WIDTH-1):0] operand_A,
		input [(WIDTH-1):0] operand_B,
		output reg carry,
		output reg [(WIDTH-1):0] result
	);
	
	always @(*) begin
		{ carry, result } <= operand_A + operand_B;
	end
	
endmodule