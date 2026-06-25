`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.12.2025 02:06:48
// Design Name: 
// Module Name: itcm
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


module itcm #(parameter MEM_DEPTH = `ITCM_DEPTH) //Number of Instructions DEPTH in bytes (default 32KB)
(
    input clk_i,
    input rstn_i,
    input [31:0] pc_i,
    output [31:0] instr_o
    );
    
    `include "defs.v"
    
    reg [31:0] reg_mem [0:(MEM_DEPTH/4)-1];
    reg [31:0] reg_instr; 
    
    initial begin
        $readmemh("C:/Users/Administrator/Documents/FYP_Docs/RISCV_SNN/itcm.hex",reg_mem);
    end
    
    always @ (*)
    begin
        if(~rstn_i)
            reg_instr = `NOP;
        else
            reg_instr = reg_mem[pc_i[14:2]]; // 13-bit word index for 32KB (8K words)
    end
    
    assign instr_o = reg_instr;
    
endmodule
