`timescale 1ns / 1ps
// UART TX serializer — 8-N-1, 115200 baud
// TX address  : 0x40000000 (CPU writes byte here)
// Status addr : 0x40000004 (bit 0 = busy; CPU polls before writing)

module uart_tx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 115_200
)(
    input        clk_i,
    input        rstn_i,
    input        valid_i,   // 1-cycle pulse: byte accepted only when !busy_o
    input  [7:0] data_i,
    output       tx_o,      // serial UART line (idle-high)
    output       busy_o
);
    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;  // 434 @ 50 MHz

    // frame = {stop(1), data[7:0], start(0)} — 10 bits, shifted out LSB-first
    reg [9:0]  frame;
    reg [3:0]  bit_cnt;   // counts down from 10 to 0
    reg [9:0]  baud_cnt;
    reg        busy;

    assign tx_o   = busy ? frame[0] : 1'b1;
    assign busy_o = busy;

    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            busy     <= 1'b0;
            baud_cnt <= 0;
            bit_cnt  <= 0;
            frame    <= 10'h3FF;
        end else if (!busy) begin
            if (valid_i) begin
                frame    <= {1'b1, data_i, 1'b0}; // stop + data[7:0] + start
                bit_cnt  <= 4'd10;
                baud_cnt <= BAUD_DIV - 1;
                busy     <= 1'b1;
            end
        end else begin
            if (baud_cnt != 0) begin
                baud_cnt <= baud_cnt - 1;
            end else begin
                frame    <= {1'b1, frame[9:1]}; // shift right, LSB first
                baud_cnt <= BAUD_DIV - 1;
                if (bit_cnt == 1)
                    busy <= 1'b0;
                bit_cnt <= bit_cnt - 1;
            end
        end
    end
endmodule
