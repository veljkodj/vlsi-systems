module stavka_a_resenje (
   input [6:0] data_in,
   input control,
   output reg [7:0] data_out
);
   
   integer i;
   integer ones_count;
   reg has_more_ones;
   reg info_bit;
   
   always @(*) begin
      ones_count = 0;
      for (i = 0; i < 7; i = i + 1)
         if (data_in[i] == 1'b1)
            ones_count = ones_count + 1;
      
      if (ones_count > 3)
         has_more_ones = 1'b1;
      else
         has_more_ones = 1'b0;
      
      if (control == 1'b1)
         info_bit = has_more_ones;
      else
         info_bit = ~has_more_ones;
      
      data_out = {data_in[6:4], info_bit, data_in[3:0]};
   end
   
endmodule
