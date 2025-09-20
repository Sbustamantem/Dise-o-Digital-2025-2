// File: sipo_register_tb.v
`timescale 1ns / 1ps

module sipo_register_tb;

    // -- DUT Signals --
    reg clk;
    reg reset;
    reg serial_in;
    wire [3:0] parallel_out_last_4_bits;
    wire [7:0] parallel_out_full;

    // -- Test Parameters --
    parameter CLK_PERIOD = 100; // 100ns, an arbitrary period for simulation
    reg [7:0] test_vector = 8'b10110101; // Data to shift in (LSB first)

    // -- Instantiate the DUT --
    sipo_register dut (
        .clk(clk),
        .reset(reset),
        .serial_in(serial_in),
        .parallel_out_last_4_bits(parallel_out_last_4_bits),
        .parallel_out_full(parallel_out_full)
    );

    // -- Clock Generation --
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // -- Test Stimulus and Verification --
    initial begin
        integer i;
        integer errors = 0;

        $display("T=%0t: [INFO] Starting testbench...", $time);
        reset = 1;
        serial_in = 0;
        #(CLK_PERIOD * 2);
        reset = 0;

        $display("T=%0t: [INFO] Shifting in test vector: %b", $time, test_vector);
        for (i = 0; i < 8; i = i + 1) begin
            serial_in = test_vector[i];
            @(posedge clk);
            #1; // Allow combinational outputs to settle before displaying
            $display("T=%0t: Cycle %0d, serial_in=%b, full_out=%b",
                     $time, i+1, serial_in, parallel_out_full);
        end

        // Final check
        if (parallel_out_full !== test_vector) begin
            $display("T=%0t: [FAIL] Final parallel output mismatch!", $time);
            $display("         Expected: %b, Got: %b", test_vector, parallel_out_full);
            errors = errors + 1;
        end

        if (errors == 0) $display("\n****   TEST PASSED!   ****");
        else $display("\n!!!!    TEST FAILED! Found %0d errors.    !!!!", errors);

        $finish;
    end
endmodule