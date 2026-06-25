`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.04.2026 23:12:43
// Design Name: 
// Module Name: dual_port_RAM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dual_port_RAM #(
    parameter DATA_WIDTH = 64,
    parameter DEPTH = 6400, //Layer 1: 6272 words, Layer 2: 128 words (2 per L1 spike x 64)
    parameter ADDR_WIDTH = 13 //log2(DEPTH)
)(
input clk,

//Port A (Inference for Processing Elements)
//Weights read from hex file
input rd_en_a,
input [ADDR_WIDTH - 1 : 0] addr_a,
output reg [DATA_WIDTH - 1 : 0] dout_a,
//Port B (Learning Unit for Weights Calculation)
input rd_en_b,
input wr_en_b,
input [DATA_WIDTH - 1 : 0] din_b,
input [ADDR_WIDTH - 1 : 0] addr_b,
output reg [DATA_WIDTH - 1 : 0] dout_b
    );

reg [DATA_WIDTH - 1 : 0] mem [0 : DEPTH - 1];
    
    initial begin
        $readmemh("C:/Users/Administrator/Documents/FYP_Docs/RISCV_SNN/weights_combined.hex",mem);
    end
    
    always @ (posedge clk) begin
        if(rd_en_a) begin
            dout_a <= mem[addr_a];
        end
    end
    
    always @ (posedge clk) begin
        if(rd_en_b) begin
            dout_b <= mem[addr_b];
        end
        
        if (wr_en_b) begin
            mem[addr_b] <= din_b;
        end
    end
    
endmodule
