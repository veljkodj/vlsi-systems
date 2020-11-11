module combinational_module
    (
        input [6 : 0] data_input,
        input ctrl,
        output reg [7 : 0] data_output
    );
    
    integer i;
    
    integer cntr_zeroes, cntr_ones;
    
    always @(*) begin
        
        cntr_zeroes = 0;
        cntr_ones = 0;
    
        for (i = 0; i < 7; i = i + 1) begin
            if (data_input[i] == 1'b1)
                cntr_ones = cntr_ones + 1;
            else
                cntr_zeroes = cntr_zeroes + 1;
        end
        
        if (ctrl == 1'b1)
            if (cntr_ones > cntr_zeroes)
                data_output <= { {data_input[6 : 3]}  ,{1'b1}, {data_input[2 : 0]}};
            else // cntr_ones < cntr_zeroes because of odd number of bits in data_input signal
                data_output <= { {data_input[6 : 3]}  ,{1'b0}, {data_input[2 : 0]}};
        else
            if (cntr_ones > cntr_zeroes)
                data_output <= { {data_input[6 : 3]}  ,{1'b0}, {data_input[2 : 0]}};
            else // cntr_ones < cntr_zeroes because of odd number of bits in data_input signal
                data_output <= { {data_input[6 : 3]}  ,{1'b1}, {data_input[2 : 0]}};
    
    end
    
endmodule