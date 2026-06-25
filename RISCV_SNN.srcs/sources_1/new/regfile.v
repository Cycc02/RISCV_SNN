`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.12.2025 22:10:58
// Design Name: 
// Module Name: regfile
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


module regfile(
    input clk_i,
    input rstn_i,
    input wr_en_i,
    input [4:0] rs1_i,
    input [4:0] rs2_i,
    input [4:0] rd_i,
    input [31:0] wb_data_i,
    output [31:0] dout1_o,
    output [31:0] dout2_o
    );
    
    reg [31:0] gpr [31:0];
    reg reg_write_en;
    integer i;
    
    //Synchronous Write
    always @ (posedge clk_i or negedge rstn_i)
    begin
        if (~rstn_i) begin
            for (i = 0; i < 32 ; i = i + 1) begin
                gpr[i] <= 32'h0;
            end
        end
        else begin
            if(wr_en_i && (rd_i != 5'b0)) begin
                gpr[rd_i] <= wb_data_i;
            end
            else begin
                gpr[rd_i] <= gpr[rd_i];
            end
        end
    end
    
    //Asynchronous Read with Internal Forwarding
    assign dout1_o = (rs1_i == 5'b0) ? 32'h0 : 
                     ((wr_en_i && rd_i == rs1_i) ? wb_data_i : gpr[rs1_i]);
    assign dout2_o = (rs2_i == 5'b0) ? 32'h0 : 
                     ((wr_en_i && rd_i == rs2_i) ? wb_data_i : gpr[rs2_i]);
    
endmodule

