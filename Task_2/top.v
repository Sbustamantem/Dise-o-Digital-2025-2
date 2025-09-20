/*******************************************************************************
* File:   top.v
* Module: top
*
* Description:
*   Top-level module that integrates the baud_gen, sipo_reg, and detector
*   modules. It correctly handles clock domain crossing from the sipo_reg
*   (in the baud_tick domain) to the detector (in the system clk domain).
*******************************************************************************/
module top #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input wire clk,                  // High-frequency system clock
    input wire reset,                // Synchronous reset
    input wire rx_serial_in,         // The incoming UART serial data

    output wire pattern_match_pulse  // Final output pulse
);

    // -- State Machine Definition --
    localparam [1:0] IDLE        = 2'b00,
                     SAMPLING    = 2'b01,
                     STOP_BIT    = 2'b10;

    // -- Internal Signals and Wires --
    reg [1:0] state;
    reg [2:0] bit_counter;

    wire baud_tick;
    reg  shift_enable;

    reg  baud_tick_dly;
    wire baud_tick_rising_edge;

    wire [3:0] sipo_last_4_bits;

    // CDC: 2-Flop Synchronizer Registers
    reg [3:0] sipo_bits_sync_r1;
    reg [3:0] sipo_bits_sync_r2;


    // ----------- INSTANTIATE SUB-MODULES (with new names) -----------

    // 1. Baud Rate Generator
    baud_gen baud_gen_inst (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    // 2. SIPO Register
    sipo_reg sipo_inst (
        .clk(baud_tick),
        .reset(reset),
        .shift_en(shift_enable),
        .serial_in(rx_serial_in),
        .parallel_out_last_4_bits(sipo_last_4_bits),
        .parallel_out_full()
    );

    // 3. Pattern Detector
    detector detector_inst (
        .clk(clk),
        .reset(reset),
        .enable(baud_tick_rising_edge && shift_enable),
        .data_in(sipo_bits_sync_r2),
        .match_pulse(pattern_match_pulse)
    );


    // ----------- CDC AND FSM LOGIC (ALL IN SYSTEM CLOCK DOMAIN) -----------

    always @(posedge clk) begin
        baud_tick_dly <= baud_tick;
    end
    assign baud_tick_rising_edge = baud_tick && !baud_tick_dly;

    always @(posedge clk) begin
        if(reset) begin
            sipo_bits_sync_r1 <= 4'b0;
            sipo_bits_sync_r2 <= 4'b0;
        end else begin
            sipo_bits_sync_r1 <= sipo_last_4_bits;
            sipo_bits_sync_r2 <= sipo_bits_sync_r1;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            state        <= IDLE;
            bit_counter  <= 0;
            shift_enable <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    shift_enable <= 1'b0;
                    if (rx_serial_in == 1'b0) begin
                        shift_enable <= 1'b1;
                        state        <= SAMPLING;
                        bit_counter  <= 0;
                    end
                end

                SAMPLING: begin
                    shift_enable <= 1'b1;
                    if (baud_tick_rising_edge) begin
                        if (bit_counter == 3'd7) begin
                            state <= STOP_BIT;
                        end else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end
                end

                STOP_BIT: begin
                    shift_enable <= 1'b0;
                    if (baud_tick_rising_edge) begin
                        state <= IDLE;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule