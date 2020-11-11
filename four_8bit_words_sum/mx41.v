module mx41
	(
		input [7:0] I0,
		input [7:0] I1,
		input [7:0] I2,
		input [7:0] I3,
		input [1:0] S,
		output reg [7:0] Y
	);
	
	always @(*) begin
		case (S)
			2'b00: begin Y = I0; end
			2'b01: begin Y = I1; end
			2'b10: begin Y = I2; end
			2'b11: begin Y = I3; end
		endcase
	end
	
endmodule