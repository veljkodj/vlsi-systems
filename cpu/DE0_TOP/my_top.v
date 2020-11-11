module my_top
    #(
        parameter FILE_NAME = "initial.mif",
        parameter DATA_WIDTH = 8,
        parameter ADDR_WIDTH = 8
    )
    (
        input rst,
        input clk,
        input trap_trigger,
        input [7 : 0] switches,
        output [7 : 0] leds
    );
    
    wire [(ADDR_WIDTH - 1) : 0] cpu_to_mem_addr;
    wire [(DATA_WIDTH - 1) : 0] cpu_to_mem_data_out;
    wire [(DATA_WIDTH - 1) : 0] cpu_to_mem_data_in;
    wire cpu_to_mem_ctrl_write;
    
    wire trap_trigger_red;
    
    wire [(DATA_WIDTH - 1) : 0] cpu_to_gpio_data_out;
    wire cpu_to_gpio_ctrl_write;
    
    my_memory 
        #(
            .FILE_NAME(FILE_NAME),
            .DATA_WIDTH(DATA_WIDTH),
            .ADDR_WIDTH(ADDR_WIDTH)
        )
    memory
        (
            .clk(clk),
            .ctrl_write(cpu_to_mem_ctrl_write),
            .addr_write(cpu_to_mem_addr),
            .data_in(cpu_to_mem_data_out),
            .addr_read(cpu_to_mem_addr),
            .data_out(cpu_to_mem_data_in)
        );
        
    my_rising_edge_detector my_rising_edge_detector_instance_1
        (
            .rst(rst),
            .clk(clk),
            .signal_in(trap_trigger),
            .signal_out(trap_trigger_red)
        );
        
    my_cpu cpu
        (
            .rst(rst),
            .clk(clk),
            .trap_trigger(trap_trigger_red),
            .gpio_ctrl_write(cpu_to_gpio_ctrl_write),
            .gpio_data_out(cpu_to_gpio_data_out),
            .gpio_data_in(switches),
            .mem_ctrl_write(cpu_to_mem_ctrl_write),
            .mem_addr_out(cpu_to_mem_addr),
            .mem_data_out(cpu_to_mem_data_out),
            .mem_data_in(cpu_to_mem_data_in)	
        );
        
    my_register
        #(
            .DATA_WIDTH(DATA_WIDTH)
        )
    gpio_led
        (
            .rst(rst),
            .clk(clk),
            .ctrl_load(cpu_to_gpio_ctrl_write),
            .ctrl_incr(1'b0),
            .data_in(cpu_to_gpio_data_out),
            .data_out(leds)
        );
    
endmodule
