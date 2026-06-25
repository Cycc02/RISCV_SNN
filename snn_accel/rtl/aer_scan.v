`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2026 22:04:51
// Design Name: 
// Module Name: aer_scan
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


module aer_scan (
    input clk_i,
    input rstn_i,
    input snn_kick_i,
    
    input [31:0] chunk_i, //32-bit chunk input
    input chunk_valid_i,
    input fifo_full_i, //Pause scan if FIFO full
    
    output reg [9:0] aer_data_o, //Encoded Spike Triggering Signal
    output reg aer_valid_o,
    output reg scan_done_o,
    output reg chunk_req_o,
    output [4:0] chunk_num_o
    );
    
    reg [31:0] chunk_reg;
    reg [4:0] chunk_num;
    reg [4:0] first_idx;
    reg spike_found;
    reg is_scanning;
    
    wire [31:0] window;
        
    integer i;
    
    assign window = chunk_reg;
    
    always @ (*) begin
        first_idx = 5'b0;
        spike_found = 1'b0;
        for (i = 0; i < 32 ; i = i + 1) begin
            if(window[i] == 1'b1 && !spike_found) begin
                first_idx = i[4:0];
                spike_found = 1'b1;
            end
        end
    end
    
    always @ (posedge clk_i or negedge rstn_i) begin
        if(!rstn_i) begin
            chunk_reg   <= 'b0;
            chunk_num   <= 5'b0;
            is_scanning <= 'b0;
            aer_data_o  <= 'b0;
            aer_valid_o <= 1'b0;
            scan_done_o <= 1'b0;
            chunk_req_o <= 1'b0;
        end
        else begin
            aer_valid_o <= 1'b0;
            scan_done_o <= 1'b0;
            
            if(aer_valid_o && fifo_full_i) begin
                aer_valid_o <= 1'b1; //Check if FIFO took the data
            end
            else begin
                aer_valid_o <= 1'b0;
                if(snn_kick_i) begin
                    chunk_req_o <= 1'b1;
                    chunk_num <= 5'b0;
                    is_scanning <= 1'b1;
                end
                else if (is_scanning && chunk_valid_i && chunk_req_o) begin
                    chunk_req_o <= 1'b0;
                    chunk_reg <= chunk_i;
                end
                else if (is_scanning && !chunk_req_o && !fifo_full_i) begin
                     if (window == 32'b0) begin
                        if(chunk_num == 5'd24) begin
                            is_scanning <= 1'b0;
                            scan_done_o <= 1'b1;
                        end else begin
                            chunk_req_o <= 1'b1;
                            chunk_num <= chunk_num + 1;
                        end
                    end
                    else if (spike_found) begin
                        aer_data_o <= (chunk_num << 5) + first_idx;
                        aer_valid_o <= 1'b1;
                        chunk_reg[first_idx] <= 1'b0;
                    end
                end
            end
        end
    end   
    
    assign chunk_num_o = chunk_num;
    
endmodule
