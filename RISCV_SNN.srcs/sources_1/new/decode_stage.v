`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.12.2025 01:43:55
// Design Name: 
// Module Name: decode_stage
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


module decode_stage(
    input clk_i,
    input rstn_i,
    input wb_regfile_wr_en_i,
    input [4:0]  wb_rd_i,
    input [31:0] wb_mem_i,
    input [31:0] instr_i,
    input [31:0] pc_i,
    input [31:0] pc_plus4_i,
    
    //Register File Output
    output [31:0] data_rs1_o,
    output [31:0] data_rs2_o,
    
    //Control Unit Output
    output dec_regfile_we_o,
    output [1:0] wb_result_src_o,
    
    output exec_branch_en_o,
    output exec_jump_en_o,
    output exec_jump_ctrl_o,
    output exec_lsu_en_o,
    output exec_alu_en_o,
    output exec_csr_rwe_o,
    output exec_mux_rs1_o,
    output exec_mux_imm_o,

    output [2:0] exec_branch_ctrl_o,
    output [2:0] exec_csr_ctrl_o,
    output [3:0] exec_lsu_ctrl_o,
    output [3:0] exec_alu_ctrl_o,
    
    output exec_ecall_o,
    output exec_mret_o,
    output illegal_instr_o,
    
    //Sign Extension Output
    output [31:0] signext_o,
    
    //Parsing Wires
    output [4:0] rs1_o,
    output [4:0] rs2_o,
    output [4:0] rd_o,
    output [31:0] pc_o,
    output [31:0] pc_plus4_o
    );
    
    wire [2:0] signext_ctrl;
    
    regfile rf (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .wr_en_i(wb_regfile_wr_en_i),
    .rs1_i(instr_i[19:15]),
    .rs2_i(instr_i[24:20]),
    .rd_i(wb_rd_i),
    .wb_data_i(wb_mem_i),
    .dout1_o(data_rs1_o),
    .dout2_o(data_rs2_o)
    );
    
    controlunit cu (
    .opcode_i(instr_i[6:0]),
    .funct7_i(instr_i[31:25]),
    .funct3_i(instr_i[14:12]),
    .dec_regfile_we_o(dec_regfile_we_o),
    .dec_imm_src_o(signext_ctrl),
    .wb_result_src_o(wb_result_src_o),
    .exec_branch_en_o(exec_branch_en_o),
    .exec_jump_en_o(exec_jump_en_o),
    .exec_jump_ctrl_o(exec_jump_ctrl_o),
    .exec_lsu_en_o(exec_lsu_en_o),
    .exec_alu_en_o(exec_alu_en_o),
    .exec_csr_rwe_o(exec_csr_rwe_o),
    .exec_mux_rs1_o(exec_mux_rs1_o),
    .exec_mux_imm_o(exec_mux_imm_o),
    .exec_branch_ctrl_o(exec_branch_ctrl_o),
    .exec_csr_ctrl_o(exec_csr_ctrl_o),
    .exec_lsu_ctrl_o(exec_lsu_ctrl_o),
    .exec_alu_ctrl_o(exec_alu_ctrl_o),
    .exec_ecall_o(exec_ecall_o),
    .exec_mret_o(exec_mret_o),
    .illegal_instr_o(illegal_instr_o)
    );
    
    signext se (
    .instr_i(instr_i[31:7]),
    .ext_ctrl_i(signext_ctrl),
    .instr_o(signext_o)
    );
    
    assign rs1_o = instr_i[19:15];
    assign rs2_o = instr_i[24:20];
    assign rd_o  = instr_i[11:7];
    assign pc_o  = pc_i;
    assign pc_plus4_o = pc_plus4_i;
    
endmodule
