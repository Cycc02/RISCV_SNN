`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.12.2025 22:05:30
// Design Name: 
// Module Name: branchjumpunit
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


module branchjumpunit(
    input [31:0] pc_i,
    input [31:0] addr_imm_i,
    input [31:0] data_rs1_i,
    input [2:0] branch_sel_i,
    input jump_sel_i,
    input branch_en_i,
    input jump_en_i,
    input zero_i,
    input carry_i,
    input negative_i,
    input overflow_i,
    output pc_taken_o,
    output instr_mis_ex_o,
    output [31:0] pc_mask_o
    );
    
    `include "defs.v"
    
    wire [31:0] branch;
    wire [31:0] pc_o;
    reg         branch_met;
    reg  [31:0] addr_jump;

    always @ (*) begin
        branch_met = 1'b0;
        addr_jump   = 32'h0;
        if (branch_en_i) begin
            case (branch_sel_i) 
                `BREQ:      branch_met = zero_i;
                `BRNEQ:     branch_met = ~zero_i; 
                `BRLT:      branch_met = negative_i != overflow_i;
                `BRMTEQ:    branch_met = negative_i == overflow_i;
                `BRLTU:     branch_met = ~carry_i;
                `BRMTEQU:   branch_met = carry_i;
                default:  branch_met = 1'b0;
            endcase
        end
        else if (jump_en_i) begin
            if (jump_sel_i)
                addr_jump = branch;
            else
                addr_jump = (data_rs1_i + addr_imm_i) & ~32'h1;
         end
         else begin
            branch_met = 1'b0;
            addr_jump = 'h0;  
         end  
    end
    assign branch = (pc_i + addr_imm_i);
    assign pc_o = branch_met ? branch : ((jump_en_i) ? addr_jump : 32'h0);
    assign pc_taken_o = (jump_en_i || (branch_en_i && branch_met));
    assign instr_mis_ex_o = pc_taken_o && (pc_o [1:0] != 2'b00);
    assign pc_mask_o = pc_o;
    
endmodule
