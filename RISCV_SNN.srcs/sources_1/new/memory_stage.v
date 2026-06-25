`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.12.2025 15:25:30
// Design Name: 
// Module Name: memory_stage
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


module memory_stage(
    input clk_i,
    input rstn_i,
    
    //LSU Input
    input [31:0] dtcm_data_i,
    input [29:0] dtcm_addr_i,
    input [3:0] mask_i,
    input [1:0] ld_ext_ctrl_i,
    input dtcm_rd_en_i,
    input dtcm_wr_en_i,
    input lh_cross_i,
    
    //Parsing Wires Input
    input        mem_regfile_we_i,
    input [1:0]  mem_wb_result_src_i,
    input [4:0]  mem_rd_i,
    input [31:0] mem_pc_plus4_i,
    input [31:0] mem_alu_result_i,
    input [31:0] mem_pctarget_i,
    input [31:0] mem_wb_csr_i,
      
    //Memory Load Unit Output
    output [31:0] ld_data_o,
    
    //Parsing Wires Output
    output          mem_regfile_we_o,
    output [1:0]    mem_wb_result_src_o,
    output [4:0]    mem_rd_o,
    output [31:0]   mem_pc_plus4_o,
    output [31:0]   mem_alu_result_o,
    output [31:0]   mem_pctarget_o,
    output [31:0]   mem_wb_csr_o,
    
    //SNN Interface
    input           snn_rd_en_i,
    input  [11:0]   snn_addr_i,
    output [31:0]   snn_data_o
    );
    
    wire [31:0] ld_data;
    wire [31:0] ld_data2;
    wire [1:0]  ld_ext_ctrl;
    wire [3:0]  ld_mask;
    wire        ld_ack;

    wire [31:0] ld_data_mux;
    wire [3:0]  ld_mask_mux;

    
    dtcm #(`DTCM_DEPTH) dmem(
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .rd_en_i(dtcm_rd_en_i),
    .wr_en_i(dtcm_wr_en_i),
    .mask_i(mask_i),
    .dtcm_addr_i(dtcm_addr_i),
    .dtcm_data_i(dtcm_data_i),
    .dtcm_data_o(ld_data),
    .ld_ext_ctrl_i(ld_ext_ctrl_i),
    .ld_ext_ctrl_o(ld_ext_ctrl),
    .ld_ack_o(ld_ack),
    .ld_mask_o(ld_mask),
    .snn_rd_en_i(snn_rd_en_i),
    .snn_addr_i(snn_addr_i),
    .snn_data_o(snn_data_o),
    .dtcm_addr2_i(dtcm_addr_i + 30'd1),
    .dtcm_data2_o(ld_data2)
    );

    /* For lane=0b11 LH/LHU: halfword spans word N (bits[31:24]) and word N+1 (bits[7:0]).
     * Assemble as ld_data_i[15:0] = {word_N+1[7:0], word_N[31:24]} with mask=0011
     * so memloadunit sign/zero-extends bits[15:0] correctly. */
    assign ld_data_mux = lh_cross_i ? {16'b0, ld_data2[7:0], ld_data[31:24]} : ld_data;
    assign ld_mask_mux = lh_cross_i ? 4'b0011 : ld_mask;
    
    memloadunit lsu2 (
    .ld_data_i(ld_data_mux),
    .ld_mask_i(ld_mask_mux),
    .ld_ext_ctrl_i(ld_ext_ctrl),
    .ld_ack_i(ld_ack),
    .ld_data_o(ld_data_o)
    );
    
    //Parsing Wires
    assign mem_regfile_we_o = mem_regfile_we_i;
    assign mem_wb_result_src_o = mem_wb_result_src_i;
    assign mem_rd_o = mem_rd_i;
    assign mem_pc_plus4_o = mem_pc_plus4_i;
    assign mem_alu_result_o = mem_alu_result_i;
    assign mem_pctarget_o = mem_pctarget_i;
    assign mem_wb_csr_o = mem_wb_csr_i;
    
endmodule
