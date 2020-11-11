// *** TEST MODULE ***
module stavka_v_test;
   
   reg        dut_rst_n;
   reg        dut_clk;
   reg [3:0]  dut_data_in;
   reg [2:0]  dut_control;
   wire [3:0] dut_data_out;
   
   stavka_v_resenje dut(
      .rst_n(dut_rst_n),
      .clk(dut_clk),
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
