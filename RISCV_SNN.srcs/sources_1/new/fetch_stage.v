`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.12.2025 01:19:23
// Design Name: 
// Module Name: fetch_stage
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


module fetch_stage(
    input clk_i,
    input rstn_i,
    input pc_stall_i,
    input [1:0] pc_sel_i,
    input [31:0] pctarget_i,
    input [31:0] branch_csr_i,
    output [31:0] instr_o,
    output [31:0] pc_o,
    output [31:0] pc_plus4_o
    );
    
    `include "defs.v"
    
    reg  [31:0] reg_pc_in;
    reg  [31:0] reg_pc_out;
    
    itcm #(`ITCM_DEPTH) itcm(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .pc_i(reg_pc_out),
        .instr_o(instr_o)
    );
        
    always @ (posedge clk_i or negedge rstn_i) begin
        if(~rstn_i)
            reg_pc_out <= 32'h0;
        else
            reg_pc_out <= reg_pc_in;
    end
    
    always @ (*) begin
        if(~pc_stall_i) begin
            case(pc_sel_i)
            `FE_PC_TARGET: reg_pc_in = pctarget_i;
            `FE_BRANCH_CSR: reg_pc_in = branch_csr_i;
            `FE_PC_PLUS4: reg_pc_in = reg_pc_out + 4;
            default: reg_pc_in = 32'h0;
            endcase
        end
        else
            reg_pc_in = reg_pc_out;
   end
   
   //Combinational Assignment
   assign pc_o = reg_pc_out;
   assign pc_plus4_o = reg_pc_out + 4; 
    
endmodule
