// File: baud_gen_tb.v
`timescale 1ns / 1ps

module baud_gen_tb;

    // -- Testbench Parameters --
    parameter CLK_FREQ    = 25_000_000;
    parameter BAUD_RATE   = 115_200;
    parameter CLK_PERIOD  = 1_000_000_000.0 / CLK_FREQ; // 40ns

    // -- DUT Signals --
    reg clk;
    reg reset;
    wire baud_tick;

    // -- Instantiate the DUT --
    baud_rate_generator dut (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    // -- Clock Generation --
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // -- Test Stimulus and Verification --
    initial begin
        real expected_period_ns = 1_000_000_000.0 / BAUD_RATE;
        real tolerance = expected_period_ns * 0.01; // 1% tolerance
        real start_time;
        real end_time;
        real avg_period;
        integer num_ticks_to_measure = 20;

        $display("T=%0t: [INFO] Starting testbench...", $time);
        $display("T=%0t: [INFO] Expected Period: ~%.2f ns", $time, expected_period_ns);

        // 1. Apply Reset
        reset = 1;
        #(CLK_PERIOD * 10);
        reset = 0;

        // 2. Wait for the first rising edge to start measurement
        @(posedge baud_tick);
        start_time = $time;
        $display("T=%0t: [INFO] First tick detected. Starting measurement.", $time);

        // 3. Count a number of ticks
        repeat (num_ticks_to_measure - 1) begin
            @(posedge baud_tick);
        end
        end_time = $time;
        $display("T=%0t: [INFO] Measured %0d ticks.", $time, num_ticks_to_measure);

        // 4. Calculate and verify the average period
        avg_period = (end_time - start_time) / (num_ticks_to_measure - 1);
        $display("T=%0t: [INFO] Measured average period: %.2f ns", $time, avg_period);

        if ((avg_period > (expected_period_ns - tolerance)) && (avg_period < (expected_period_ns + tolerance))) begin
            $display("\n**************************");
            $display("****   TEST PASSED!   ****");
            $display("**************************");
        end else begin
            $display("\n!!!!!!!!!!!!!!!!!!!!!!!!!!");
            $display("!!!!    TEST FAILED!    !!!!");
            $display("!!!!!!!!!!!!!!!!!!!!!!!!!!");
        end

        $finish;
    end
endmodule