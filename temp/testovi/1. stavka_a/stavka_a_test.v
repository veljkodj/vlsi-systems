// *** TEST MODULE ***
module stavka_a_test;
   
   reg [6:0]  dut_data_in;
   reg        dut_control;
   wire [7:0] dut_data_out;
   
   stavka_a_resenje dut(
      .data_in(dut_data_in),
      .control(dut_control),
      .data_out(dut_data_out));
   
   initial begin
      dut_data_in = 7'b0;
      dut_control = 1'b0;
      $display("TEST POVEZAN SA RESENJEM");
      $finish(0);
   end
   
endmodule
