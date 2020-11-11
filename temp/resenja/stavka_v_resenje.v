module stavka_v_resenje (
   input rst_n,
   input clk,
   input [3:0] data_in,
   input [2:0] control,
   output [3:0] data_out
);

   reg [3:0] data_out_reg, data_out_next;
   
   assign data_out = data_out_reg;

   always @(posedge clk, negedge rst_n)
      if (!rst_n)
         data_out_reg <= 4'h0;
      else
         data_out_reg <= data_out_next;

   always @(data_in, control, data_out_reg) begin
      data_out_next = data_out_reg;
      // enable: on
      if (control[0])
         // operation: data_out + 1
         if (control[2])
            data_out_next = data_out_reg + 1'b1;
         // operation: operand1
         else
            if (control[1])
               data_out_next = data_in * 2;
            else
               data_out_next = data_in;
   end
   
endmodule
