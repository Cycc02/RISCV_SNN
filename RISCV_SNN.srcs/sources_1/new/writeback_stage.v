`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.12.2025 16:04:33
// Design Name: 
// Module Name: writeback_stage
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


module writeback_stage(
    input [1:0] wb_src_i,
    input [31:0] wb_csr_o,
    input [31:0] wb_alu_result_o,
    input [31:0] wb_ld_o,
    input [31:0] wb_pc_plus4_o,
    
    output [31:0] wb_result_o
    );
      
    assign wb_result_o = wb_src_i[1] ? 
                        (wb_src_i[0] ? wb_ld_o : wb_pc_plus4_o) :
                        (wb_src_i[0] ? wb_alu_result_o : wb_csr_o);
                        
endmodule
