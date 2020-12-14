`include "my_encoder.vh"

module my_encoder
	#(
		parameter DECIMAL_DIGIT_WIDTH = `MY_ENCODER_DECIMAL_DIGIT_WIDTH,
		parameter ENCODING_WIDTH = `MY_ENCODER_ENCODING_WIDTH
	)
	(
		input [(DECIMAL_DIGIT_WIDTH - 1) : 0] decimal_digit,
		output [(ENCODING_WIDTH - 1) : 0] encoding
	);
	
	function automatic [(ENCODING_WIDTH - 1) : 0] encode
		(
			input [(DECIMAL_DIGIT_WIDTH - 1) : 0] decimal_digit
		);
	begin
		case (decimal_digit)
			4'd0 : encode = 8'hC0;
			4'd1 : encode = 8'hF9;
			4'd2 : encode = 8'hA4;
			4'd3 : encode = 8'hB0;
			4'd4 : encode = 8'h99;
			4'd5 : encode = 8'h92;
			4'd6 : encode = 8'h82;
			4'd7 : encode = 8'hF8;
			4'd8 : encode = 8'h80;
			4'd9 : encode = 8'h90;
			default : encode = 8'hFF;
		endcase
	end
	endfunction
	
	assign encoding = encode(decimal_digit);
	
endmodule
