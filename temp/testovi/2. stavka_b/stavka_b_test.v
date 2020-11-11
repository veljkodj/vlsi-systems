// *** TEST MODULE ***
module stavka_a_resenje
   (
      input [6:0]      data_in,
      input            control,
      output reg [7:0] data_out
   );
   
   initial begin
      data_out = 8'b0;
      $display("TEST POVEZAN SA RESENJEM");
      $finish(0);
   end
   
endmodule
