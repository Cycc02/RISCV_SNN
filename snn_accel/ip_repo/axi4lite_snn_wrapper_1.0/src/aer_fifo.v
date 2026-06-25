`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.04.2026 21:18:58
// Design Name: 
// Module Name: aer_fifo
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


module aer_fifo #(
    parameter DATA_WIDTH = 10,
    parameter DEPTH = 64 //64 Spike Address
 )(
    input clk_i,
    input rstn_i,
    input flush_i,

    input [DATA_WIDTH - 1:0] aer_data_i,
    input rd_en_i,
    input wr_en_i,
    
    output fifo_full_o,
    output fifo_empty_o,
    output reg [DATA_WIDTH - 1:0] aer_data_o
    );
   
    reg [DATA_WIDTH - 1 : 0] fifo_reg [0: DEPTH - 1];
    
    //log2(64) = 6 bits pointer
    reg [5:0] read_pointer;
    reg [5:0] write_pointer;
    reg [6:0] count;
    
    //Read
    always @ (posedge clk_i) begin
        if(rd_en_i && !fifo_empty_o) begin
            aer_data_o <= fifo_reg[read_pointer];
        end
    end

    //Write
    always @ (posedge clk_i) begin
        if(wr_en_i && !fifo_full_o) begin
            fifo_reg[write_pointer] <= aer_data_i;
        end
    end
    
    //Pointer and Counting Logic
    always @ (posedge clk_i or negedge rstn_i) begin
        if(~rstn_i || flush_i) begin
            read_pointer <= 6'b0;
            write_pointer <= 6'b0;
            count <= 7'b0;
        end
        else begin
            case({wr_en_i && !fifo_full_o, rd_en_i && !fifo_empty_o})
            2'b01: begin
                read_pointer <= read_pointer + 1;
                count <= count - 1;
            end
            2'b10: begin
                write_pointer <= write_pointer + 1;
                count <= count + 1;
            end
            2'b11: begin
                read_pointer <= read_pointer + 1;
                write_pointer <= write_pointer + 1;
            end
            default: ;
           endcase
        end
     end
     
     assign fifo_full_o = (count == DEPTH);
     assign fifo_empty_o = (count == 7'd0);
        
endmodule
