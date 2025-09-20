// File: detector.v

module pattern_detector_pulse (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire [3:0] data_in,
    output reg match_pulse
);
    always @(posedge clk) begin
        if (reset) begin
            match_pulse <= 1'b0;
        end else begin
            match_pulse <= 1'b0;
            if (enable) begin
                if (data_in == 4'b1000) begin
                    match_pulse <= 1'b1;
                end
            end
        end
    end
endmodule