// File: uart_sampler.v

module uart_sampler (
    input wire clk_25mhz,
    input wire reset,
    input wire rx_data,
    output wire [3:0] last_4_bits,
    output wire sample_tick
);

    // 1. Instantiate the Baud Rate Generator. Its output is the 'sample_tick'.
    baud_rate_generator baud_gen (
        .clk(clk_25mhz),
        .reset(reset),
        .baud_tick(sample_tick)
    );

    // 2. Instantiate the SIPO Shift Register.
    sipo_register sipo_reg (
        // *** CRITICAL CONNECTION: The SIPO is clocked by the baud generator's output ***
        .clk(sample_tick),
        .reset(reset),
        .serial_in(rx_data),
        .parallel_out_last_4_bits(last_4_bits),
        .parallel_out_full()
    );

endmodule