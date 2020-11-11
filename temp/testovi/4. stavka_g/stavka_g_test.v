// *** TEST MODULE ***
module stavka_v_resenje
   (
      input        rst_n,
      input        clk,
      input [3:0]  data_in,
      input [2:0]  control,
      output [3:0] data_out
   );

   initial begin
      $display("TEST POVEZAN SA RESENJEM");
      $finish(0);
   end
   
endmodule
