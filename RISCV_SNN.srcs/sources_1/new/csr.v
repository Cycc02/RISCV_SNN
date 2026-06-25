`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.12.2025 17:33:59
// Design Name: 
// Module Name: csr
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


module csr(
    input clk_i,
    input rstn_i,
    input csr_rwe_i,
    input [11:0] csr_addr_i,
    input [4:0] rs1_i,
    input [31:0] rs1_data_i,
    input [31:0] pc_i,
    input mret_trigger_i,
    
    input [2:0] csr_ctrl_i,
    
    input timer_intrpt,
    input ext_intrpt,
    input illegal_instr_excp,
    input instr_mis_excp,
    input lsu_ld_mis_excp,
    input lsu_st_mis_excp,
    input ecall_excp,
    
    output [31:0] wb_csr_o,
    output [31:0] branch_csr_o,
    output trap_trigger_o,
    
    //SNN Interface
    output [11:0] snn_img_base_o,
    output        snn_kick_o,
    input         snn_done_i,
    input  [9:0]  snn_output_spike_i,
    input  [63:0] snn_hidden_spike_i
    );
    
    reg [31:0] csr_regfile_i;
    reg csr_we;
    
    wire [31:0] csr_regfile_o;
    
    csr_regfile csr_rf (
                .clk_i                  (clk_i),
                .rstn_i                 (rstn_i),
                .csr_we_i               (csr_we),
                .csr_i                  (csr_regfile_i),
                .csr_addr_i             (csr_addr_i),
                .csr_pc_i               (pc_i),
                .csr_mret_trigger_i     (mret_trigger_i),
                .csr_timer_intrpt_i     (timer_intrpt),
                .excp_illegal_instr_i   (illegal_instr_excp),
                .excp_instr_mis_i       (instr_mis_excp),
                .excp_lsu_ld_mis_i      (lsu_ld_mis_excp),
                .excp_lsu_st_mis_i      (lsu_st_mis_excp),
                .excp_ecall_i           (ecall_excp),
                .csr_ext_intrpt_i       (ext_intrpt),
                .csr_o                  (csr_regfile_o),
                .csr_trap_trigger_o     (trap_trigger_o),
                .csr_branch_o           (branch_csr_o),
                //SNN Interface
                .snn_img_base_o         (snn_img_base_o),
                .snn_kick_o             (snn_kick_o),
                .snn_done_i             (snn_done_i),
                .snn_output_spike_i     (snn_output_spike_i),
                .snn_hidden_spike_i     (snn_hidden_spike_i)
     );
     
     always @ (*) begin
        if(csr_ctrl_i != 3'b000) begin
            if((csr_ctrl_i == `CSRRW) || (csr_ctrl_i == `CSRRWI))begin
                csr_we = 1'b1;
            end
            else if(rs1_i != 5'b0) begin
                csr_we = 1'b1;
            end
            else
                csr_we = 1'b0;
        end
        else
            csr_we = 1'b0;
     end
     
     always @ (*) begin
        if(csr_rwe_i) begin
            case(csr_ctrl_i)
                `CSRRW:  csr_regfile_i = rs1_data_i;
                `CSRRS:  csr_regfile_i = csr_regfile_o | rs1_data_i;
                `CSRRC:  csr_regfile_i = csr_regfile_o & ~(rs1_data_i);
                `CSRRWI: csr_regfile_i = {27'b0,rs1_i};
                `CSRRSI: csr_regfile_i = csr_regfile_o | {27'b0,rs1_i};
                `CSRRCI: csr_regfile_i = csr_regfile_o & ~({27'b0,rs1_i});
                default: csr_regfile_i = 32'h0;
           endcase
        end
        else csr_regfile_i = 32'h0;
     end
     assign wb_csr_o = csr_regfile_o;            
endmodule
