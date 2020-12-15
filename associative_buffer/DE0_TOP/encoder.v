module encoder
	(
		input [3 : 0] digit,
		output [7 : 0] encoded_digit
	);
	
	assign encoded_digit = encode(digit);
	
	function automatic [7 : 0] encode
		(
			input [3 : 0] dig
		);
	begin
		case (dig)
			4'b0000: encode = 8'hC0;
			4'b0001: encode = 8'hF9;
			4'b0010: encode = 8'hA4;
			4'b0011: encode = 8'hB0;
			4'b0100: encode = 8'h99;
			4'b0101: encode = 8'h92;
			4'b0110: encode = 8'h82;
			4'b0111: encode = 8'hF8;
			4'b1000: encode = 8'h80;
			4'b1001: encode = 8'h90;
		endcase
	end
	endfunction
	
endmodule