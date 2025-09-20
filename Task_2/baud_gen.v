// File: baud_gen.v

module baud_rate_generator (
    input  wire clk,
    input  wire reset,
    output wire baud_tick
);
    parameter CLK_FREQ = 25_000_000;
    parameter BAUD_RATE = 115_200;
    parameter ACC_WIDTH = 16;
    localparam BAUD_GENERATOR_INC = (BAUD_RATE << ACC_WIDTH) / CLK_FREQ;
    reg [ACC_WIDTH-1:0] accumulator;
    always @(posedge clk or posedge reset) begin
        if (reset) accumulator <= 0;
        else accumulator <= accumulator + BAUD_GENERATOR_INC;
    end
    assign baud_tick = accumulator[ACC_WIDTH-1];
endmodule