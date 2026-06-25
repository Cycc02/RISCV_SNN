`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2026 14:13:30
// Design Name: 
// Module Name: snn_pe
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


module snn_pe #(
    parameter WEIGHT_WIDTH = 8,
    parameter POTENTIAL_WIDTH = 32
    )(
    input clk_i,
    input rstn_i,
    input pe_en_i,
    input spike_i,
    input leak_en_i,
    
    input signed [31:0] threshold_i,
    input signed [WEIGHT_WIDTH - 1 : 0] weight_i,
    input signed [POTENTIAL_WIDTH - 1 : 0] acc_i,
    
    output reg spike_o,
    output reg pcache_wr_o,
    output reg signed [POTENTIAL_WIDTH - 1 : 0] acc_o
    );
    
    wire signed [POTENTIAL_WIDTH - 1 : 0] v_leaked;
    wire signed [POTENTIAL_WIDTH - 1 :0] add_w;
    wire spike_trig;
    
    assign v_leaked = leak_en_i ? (acc_i >>> 1'b1) : acc_i;
    assign add_w = v_leaked + (spike_i ? weight_i : 32'sd0);
    assign spike_trig = (add_w >= threshold_i);
    
    
    always @ (posedge clk_i or negedge rstn_i) begin
        if(!rstn_i) begin
            spike_o <= 1'b0;
            pcache_wr_o <= 1'b0;
            acc_o <= 'b0;
        end
        else if (pe_en_i) begin
            spike_o     <= spike_trig;
            pcache_wr_o <= 1'b1;
            acc_o       <= add_w;
        end else begin
            pcache_wr_o <= 1'b0;
        end
    end

endmodule
