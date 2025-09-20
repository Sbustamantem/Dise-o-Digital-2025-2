// File: detector_tb.v
`timescale 1ns / 1ps

module detector_tb;

    // -- Testbench Parameters --
    parameter CLK_PERIOD = 10; // 10ns period for the fast system clock

    // -- DUT Signals --
    reg clk;
    reg reset;
    reg enable;
    reg [3:0] data_in;
    wire match_pulse;

    // -- Instantiate the DUT --
    pattern_detector_pulse dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .data_in(data_in),
        .match_pulse(match_pulse)
    );

    // -- Clock Generation --
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // -- Test Stimulus and Verification --
    initial begin
        integer errors = 0;

        // --- SCENARIO 1: Reset ---
        $display("T=%0t: [INFO] Starting testbench...", $time);
        reset = 1;
        enable = 0;
        data_in = 4'bxxxx;
        #(CLK_PERIOD * 5);
        reset = 0;
        #(CLK_PERIOD);

        // --- SCENARIO 2: Correct Sequence (Pattern Match) ---
        $display("T=%0t: [INFO] Testing correct sequence (1000)...", $time);
        data_in = 4'b1000;
        @(posedge clk);
        enable = 1'b1;
        @(posedge clk);
        enable = 1'b0;
        if (match_pulse !== 1'b1) errors = errors + 1;
        @(posedge clk);
        if (match_pulse !== 1'b0) errors = errors + 1;

        // --- SCENARIO 3: Wrong Sequence (No Match) ---
        $display("T=%0t: [INFO] Testing wrong sequence (1001)...", $time);
        data_in = 4'b1001;
        @(posedge clk);
        enable = 1'b1;
        @(posedge clk);
        enable = 1'b0;
        if (match_pulse !== 1'b0) errors = errors + 1;
        @(posedge clk);

        // --- SCENARIO 4: Correct Data, but No Enable Pulse ---
        $display("T=%0t: [INFO] Testing correct data without enable...", $time);
        data_in = 4'b1000;
        enable = 1'b0;
        @(posedge clk);
        if (match_pulse !== 1'b0) errors = errors + 1;

        if (errors == 0) $display("\n****   TEST PASSED!   ****");
        else $display("\n!!!!    TEST FAILED! Found %0d errors.    !!!!", errors);

        $finish;
    end
endmodule