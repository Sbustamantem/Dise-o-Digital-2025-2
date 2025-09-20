// File: uart_sampler_tb.v
`timescale 1ns / 1ps

module uart_sampler_tb;

    // -- Testbench Parameters --
    parameter CLK_FREQ    = 25_000_000;
    parameter BAUD_RATE   = 115_200;
    parameter CLK_PERIOD  = 1_000_000_000.0 / CLK_FREQ; // 40ns
    // Calculate how many clocks are needed to shift in 8 bits
    parameter CLOCKS_FOR_8_BITS = (CLK_FREQ / BAUD_RATE) * 8;

    // -- DUT Signals --
    reg clk_25mhz;
    reg reset;
    reg rx_data;
    wire [3:0] last_4_bits;
    wire sample_tick;

    // -- Instantiate the DUT --
    uart_sampler dut (
        .clk_25mhz(clk_25mhz),
        .reset(reset),
        .rx_data(rx_data),
        .last_4_bits(last_4_bits),
        .sample_tick(sample_tick)
    );

    // -- Clock Generation --
    initial begin
        clk_25mhz = 0;
        forever #(CLK_PERIOD / 2) clk_25mhz = ~clk_25mhz;
    end

    // -- Test Stimulus and Verification --
    initial begin
        integer errors = 0;
        $display("T=%0t: [INFO] Starting testbench...", $time);

        // 1. Reset
        reset = 1;
        rx_data = 1'b1;
        #(CLK_PERIOD * 10);
        reset = 0;
        #(CLK_PERIOD);

        // 2. Test with stable '1' input
        $display("T=%0t: [INFO] Holding rx_data to 1...", $time);
        rx_data = 1'b1;
        // Wait long enough for the SIPO to fill with 1s
        #(CLK_PERIOD * (CLOCKS_FOR_8_BITS + 100)); // Add a margin
        if (last_4_bits !== 4'b1111) begin
            $display("T=%0t: [FAIL] Expected 4'b1111, got %b", $time, last_4_bits);
            errors = errors + 1;
        end

        // 3. Test with stable '0' input
        $display("T=%0t: [INFO] Holding rx_data to 0...", $time);
        rx_data = 1'b0;
        // Wait long enough for the SIPO to fill with 0s
        #(CLK_PERIOD * (CLOCKS_FOR_8_BITS + 100));
        if (last_4_bits !== 4'b0000) begin
            $display("T=%0t: [FAIL] Expected 4'b0000, got %b", $time, last_4_bits);
            errors = errors + 1;
        end

        if (errors == 0) $display("\n****   TEST PASSED!   ****");
        else $display("\n!!!!    TEST FAILED! Found %0d errors.    !!!!", errors);

        $finish;
    end
endmodule