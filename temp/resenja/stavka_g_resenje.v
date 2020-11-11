module stavka_g_resenje;
   
   reg dut_rst_n;
   reg dut_clk;
   reg [3:0] dut_data_in;
   reg [2:0] dut_control;
   wire [3:0] dut_data_out;
   
   stavka_v_resenje dut(dut_rst_n, dut_clk, dut_data_in, dut_control, dut_data_out);
      
   initial begin
      dut_rst_n = 1'b0;
      dut_clk = 1'b0;
      forever
         #5 dut_clk = ~dut_clk;
   end
   
   initial begin
      dut_data_in = 4'h0;
      dut_control = 3'o0;
      #7;
      dut_rst_n = 1'b1;
      repeat (100) begin
         #5;
         dut_data_in = $urandom % 16;
         dut_control = $urandom % 8;
      end
      $finish;
   end
   
   initial
      $monitor("time = %0d, dut_data_out = %b", $time, dut_data_out);
   
endmodule
