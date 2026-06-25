`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.04.2026 22:02:28
// Design Name: 
// Module Name: simd_8
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


module simd_8 #(
    parameter WEIGHT_WIDTH = 8,
    parameter LANE_COUNT = 8,
    parameter POT_WIDTH = 32,
    parameter THRESHOLD = 32'sd85
)(
    input clk_i,
    input rstn_i,
    input pe_en_i,
    input snn_en_i,
    input l2_en_i,
    input layer_sel_i,
    input spike_i,
    input [2:0] stp_idx_i,
    
    input signed [31:0] thresh_L1_i,
    input signed [31:0] thresh_L2_i,
    
    input [(WEIGHT_WIDTH*LANE_COUNT) - 1 : 0] weight_i,
    
    output [LANE_COUNT - 1 : 0] spike_o  
    );
    
    wire signed [31:0] current_thresh = layer_sel_i ? thresh_L2_i : thresh_L1_i;
    
    reg [2:0] stp_idx_delay;
    always @(posedge clk_i) begin
        stp_idx_delay <= stp_idx_i;
    end
    
    reg is_first_pixel;
    always @(posedge clk_i or negedge rstn_i) begin
        if(~rstn_i) begin
            is_first_pixel <= 1'b0;
        end else begin
            if(snn_en_i) begin
                is_first_pixel <= 1'b1;
            end else if (l2_en_i) begin
                // Inter-layer reset: scratchpad cleared, no leakage for L2
                is_first_pixel <= 1'b0;
            end else if (pe_en_i && stp_idx_i == 3'd7) begin
                is_first_pixel <= 1'b0;
            end
        end
    end       
    

    genvar i;
    generate
        for (i = 0; i < LANE_COUNT; i = i + 1) begin: snn_pe
            wire signed [WEIGHT_WIDTH - 1 : 0] local_weight;
            wire signed [POT_WIDTH - 1 : 0] current_potential;
            wire signed [POT_WIDTH - 1 : 0] next_potential;
            wire                            write_en;
            reg  signed [POT_WIDTH - 1 : 0] scratchpad [0: LANE_COUNT - 1]; 
            
            assign local_weight = weight_i[(i*WEIGHT_WIDTH) +: WEIGHT_WIDTH];
            assign current_potential = scratchpad[stp_idx_i];
            
            integer j, k;
            always @ (posedge clk_i or negedge rstn_i) begin
                if(!rstn_i) begin
                    for(j = 0 ; j < LANE_COUNT; j = j + 1) begin
                        scratchpad[j] <= 32'sd0;
                    end
                end else if (snn_en_i || l2_en_i) begin
                    for (k = 0; k < 8; k = k + 1) begin
                        scratchpad[k] <= 32'sd0;
                    end
                end else if (write_en) begin
                    scratchpad[stp_idx_delay] <= next_potential;
                end
            end
            
            snn_pe #(
                .WEIGHT_WIDTH(WEIGHT_WIDTH),
                .POTENTIAL_WIDTH(POT_WIDTH)
            ) proc (
                .clk_i(clk_i),
                .rstn_i(rstn_i),
                .pe_en_i(pe_en_i),
                .leak_en_i(is_first_pixel),
                
                .spike_i(spike_i),
                .threshold_i(current_thresh),
                .weight_i(local_weight),
                .acc_i(current_potential),
                
                .spike_o(spike_o[i]),
                .pcache_wr_o(write_en),
                .acc_o(next_potential)
                );
         end
     endgenerate  
endmodule
