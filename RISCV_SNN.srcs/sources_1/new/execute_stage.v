`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.12.2025 13:10:59
// Design Name: 
// Module Name: execute_stage
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

// 
module execute_stage(
    input clk_i,
    input rstn_i,
    
    //Regfile Input
    input [31:0] data_rs1_i,
    input [31:0] data_rs2_i,
    
    //Control Unit Input
    input exec_branch_en_i, 
    input exec_jump_en_i, 
    input exec_jump_ctrl_i, 
    input exec_lsu_en_i,  
    input exec_alu_en_i,  
    input exec_csr_rwe_i,  
    input exec_mux_rs1_i, 
    input exec_mux_imm_i, 

    input [2:0] exec_branch_ctrl_i, 
    input [2:0] exec_csr_ctrl_i,  
    input [3:0] exec_lsu_ctrl_i,
    input [3:0] exec_alu_ctrl_i, 
    
    input exec_ecall_i, 
    input exec_mret_i, 
    input illegal_instr_i, 
    
    //Hazard Logic Unit Input
    input [1:0] mux_rs1_i,
    input [1:0] mux_rs2_i,
    
    //SignExtension Input
    input [31:0] signext_i,
    
    //Common Input
    input [4:0]  rs1_i,
    input [31:0] pc_i,
    input [31:0] pc_plus4_i,
    input [31:0] mem_result_i,
    input [31:0] wb_result_i,
    
    //Parsing Wire Input
    input exec_regfile_we_i,
    input [1:0] exec_wb_result_src_i,
    input [4:0] exec_rd_i,
    
    //BranchJump Unit Output
    output        pc_taken_o,
    output [31:0] pctarget_o,
    
    //ALU Output
    output [31:0] alu_result_o,
    
    //LSU Output
    output [31:0] dtcm_data_o,
    output [29:0] dtcm_addr_o,
    output [3:0]  mask_o,
    output [1:0] ld_ext_ctrl_o,
    output dtcm_rd_en_o,
    output dtcm_wr_en_o,
    output lh_cross_o,
    output sh_cross_o,
    
    //CSR Output
    output [31:0] wb_csr_o,
    output [31:0] branch_csr_o,
    output        trap_trigger_o,
    
    //Parsing Wires
    output          exec_regfile_we_o,
    output [1:0]    exec_wb_result_src_o,
    output [4:0]    exec_rd_o,
    output [31:0]   exec_pc_plus4_o,
    
    //SNN Output
    output [11:0] snn_img_base_o,
    output        snn_kick_o,
    input         snn_done_i,
    input  [9:0]  snn_output_spike_i,
    input  [63:0] snn_hidden_spike_i
    );
    
    `include "defs.v"
    
    wire [31:0] rs1_mux_in;
    wire [31:0] rs2_mux_in;
    wire [31:0] rs1_datapath;
    wire [31:0] rs2_datapath;
    wire [31:0] alu_result;
    wire zero_flag;
    wire negative_flag;
    wire carry_flag;
    wire overflow_flag;
    wire ld_addr_mis_ex;
    wire st_addr_mis_ex;
    wire instr_mis_ex;
    
    //Pre-processing  
    assign rs1_mux_in = mux_rs1_i[1] ? (mux_rs1_i[0] ? wb_result_i : mem_result_i) : data_rs1_i ;
    assign rs2_mux_in = mux_rs2_i[1] ? (mux_rs2_i[0] ? wb_result_i : mem_result_i) : data_rs2_i ;
    
    assign rs1_datapath = exec_mux_rs1_i ? pc_i : rs1_mux_in;
    assign rs2_datapath = exec_mux_imm_i ? signext_i : rs2_mux_in;
    
    //ALU
    ALU alu (
    .alu_en_i(exec_alu_en_i),
    .a_i(rs1_datapath),
    .b_i(rs2_datapath),
    .ctrl_i(exec_alu_ctrl_i),
    .result_o(alu_result),
    .zero_o(zero_flag),
    .negative_o(negative_flag),
    .carry_o(carry_flag),
    .overflow_o(overflow_flag)
    );
    
    //branchjump unit
    branchjumpunit bju (
    .pc_i(pc_i),
    .addr_imm_i(signext_i),
    .data_rs1_i(rs1_datapath),
    .branch_sel_i(exec_branch_ctrl_i),
    .jump_sel_i(exec_jump_ctrl_i),
    .branch_en_i(exec_branch_en_i),
    .jump_en_i(exec_jump_en_i),
    .zero_i(zero_flag),
    .carry_i(carry_flag),
    .negative_i(negative_flag),
    .overflow_i(overflow_flag),
    .pc_taken_o(pc_taken_o),
    .instr_mis_ex_o(instr_mis_ex),
    .pc_mask_o(pctarget_o)
    );
    
    //loadstore unit
    loadstoreunit lsu (
    .addr_i(alu_result),
    .data_rd2_i(rs2_mux_in),
    .lsu_ctrl_i(exec_lsu_ctrl_i),
    .lsu_en_i(exec_lsu_en_i),
    .dtcm_data_o(dtcm_data_o),
    .dtcm_addr_o(dtcm_addr_o),
    .mask_o(mask_o),
    .ld_ext_ctrl_o(ld_ext_ctrl_o),
    .dtcm_rd_en_o(dtcm_rd_en_o),
    .dtcm_wr_en_o(dtcm_wr_en_o),
    .lh_cross_o(lh_cross_o),
    .sh_cross_o(sh_cross_o),
    .ld_addr_mis_ex_o(ld_addr_mis_ex),
    .st_addr_mis_ex_o(st_addr_mis_ex)
    );
    
    //CSR
    csr csr(
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .csr_rwe_i(exec_csr_rwe_i),
    .csr_addr_i(signext_i[11:0]),
    .rs1_i(rs1_i),
    .rs1_data_i(rs1_datapath),
    .pc_i(pc_i),
    .mret_trigger_i(exec_mret_i),
    .timer_intrpt(1'b0),
    .ext_intrpt(1'b0),
    .csr_ctrl_i(exec_csr_ctrl_i),
    .illegal_instr_excp(illegal_instr_i),
    .instr_mis_excp(instr_mis_ex),
    .ecall_excp(exec_ecall_i),
    .lsu_ld_mis_excp(ld_addr_mis_ex),
    .lsu_st_mis_excp(st_addr_mis_ex),
    .wb_csr_o(wb_csr_o),
    .branch_csr_o(branch_csr_o),
    .trap_trigger_o(trap_trigger_o),
    .snn_img_base_o(snn_img_base_o),
    .snn_kick_o(snn_kick_o),
    .snn_done_i(snn_done_i),
    .snn_output_spike_i(snn_output_spike_i),
    .snn_hidden_spike_i(snn_hidden_spike_i)
    );

    assign alu_result_o = alu_result;
    
    //Parsing Wires
    assign exec_regfile_we_o = exec_regfile_we_i;
    assign exec_wb_result_src_o = exec_wb_result_src_i;
    assign exec_rd_o = exec_rd_i;
    assign exec_pc_plus4_o = pc_plus4_i;
    
endmodule
