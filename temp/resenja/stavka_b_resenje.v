module stavka_b_resenje;

   reg [6:0] dut_data_in;
   reg dut_control;
   wire [7:0] dut_data_out;

   stavka_a_resenje dut(dut_data_in, dut_control, dut_data_out);

   integer i;
   
   initial begin
      for (i = 0; i < 2**8; i = i + 1) begin
         {dut_data_in, dut_control} = i;
         #5;
      end
      $finish;
   end

   always @(dut_data_out)
      $display(
         "time = %0d, dut_data_in = %b, dut_control = %b, dut_data_out = %b",
         $time, dut_data_in, dut_control, dut_data_out
      );

endmodule
