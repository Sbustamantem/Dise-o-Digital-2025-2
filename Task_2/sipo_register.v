// File: sipo_register.v

module sipo_register (
    input wire clk,       // This will be connected to the baud_tick
    input wire reset,
    input wire serial_in,
    output wire [3:0] parallel_out_last_4_bits,
    output wire [7:0] parallel_out_full
);
    reg [7:0] shift_reg;
    always @(posedge clk) begin
        if (reset) shift_reg <= 8'b0;
        else shift_reg <= {shift_reg[6:0], serial_in};
    end
    assign parallel_out_last_4_bits = shift_reg[3:0];
    assign parallel_out_full = shift_reg;
endmodule