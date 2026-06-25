`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.12.2025 18:03:04
// Design Name: 
// Module Name: csr_regfile
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


module csr_regfile(
    input clk_i,
    input rstn_i,
    input csr_we_i,
    input csr_mret_trigger_i,
    input csr_timer_intrpt_i,
    input csr_ext_intrpt_i,
    input excp_illegal_instr_i,
    input excp_instr_mis_i,
    input excp_lsu_ld_mis_i,
    input excp_lsu_st_mis_i,
    input excp_ecall_i,
    input [11:0] csr_addr_i,
    input [31:0] csr_i,
    input [31:0] csr_pc_i,
    output csr_trap_trigger_o,
    output [31:0] csr_branch_o,
    output [31:0] csr_o,
    
    //SNN Interface
    output  [11:0] snn_img_base_o,
    output        snn_kick_o,
    input         snn_done_i,
    input  [9:0]  snn_output_spike_i,
    input  [63:0] snn_hidden_spike_i
    );
    
    //Only focus on Trap Setup and Trap Handling
    
    //Trap Setup
    reg [31:0] reg_mstatus;
    reg [31:0] reg_mie;
    reg [31:0] reg_mtvec;
    
    //Trap Handling
    reg [31:0] reg_mscratch;
    reg [31:0] reg_mepc;
    reg [31:0] reg_mcause;

    //Performance Counter (rdcycle support)
    reg [31:0] reg_mcycle;

    reg [31:0] reg_csr_wb;
    
    wire [31:0] reg_mip;
    
    //Synchronizer Wire
    wire timer_intrpt_sync_one;
    wire timer_intrpt_synced;
    wire ext_intrpt_sync_one;
    wire ext_intrpt_synced;
    
    //SNN Regs
    reg [11:0] reg_snn_img_base;
    reg        reg_snn_kick;   // one-cycle pulse to SNN (auto-clears)
    reg        reg_snn_busy;   // sticky: high from kick until done
    
    //Synchronizer for interrupt
    dff_sync d1(
             .clk_i(clk_i),
             .rstn_i(rstn_i),
             .d(csr_timer_intrpt_i),
             .q(timer_intrpt_sync_one));

    dff_sync d2 (
             .clk_i(clk_i),
             .rstn_i(rstn_i),
             .d(timer_intrpt_sync_one),
             .q(timer_intrpt_synced));

    dff_sync d3 (
             .clk_i(clk_i),
             .rstn_i(rstn_i),
             .d(csr_ext_intrpt_i),
             .q(ext_intrpt_sync_one));
             
    dff_sync d4 (
             .clk_i(clk_i),
             .rstn_i(rstn_i),
             .d(ext_intrpt_sync_one),
             .q(ext_intrpt_synced));
             
    // Free-running cycle counter incremented every clock
    always @ (posedge clk_i or negedge rstn_i)
    begin
        if (~rstn_i)
            reg_mcycle <= 32'h0;
        else
            reg_mcycle <= reg_mcycle + 1'b1;
    end
                    
    always @ (posedge clk_i or negedge rstn_i)
    begin
        if(~rstn_i) begin
            reg_mstatus     <= {19'b0,2'b11,11'b0}; //Hardwired to Machine Mode
            reg_mie         <= 32'h0;
            reg_mtvec       <= 32'h0; //Check boot ROM to ensure correct jump handler
            reg_mscratch    <= 32'h0;
            reg_mepc        <= 32'h0;
            reg_mcause      <= 32'h0;
            reg_snn_kick <= 1'b0;
            reg_snn_busy <= 1'b0;
            reg_snn_img_base <= 12'h0;
        end
        else begin
            // snn_kick is a single-cycle pulse: default low every cycle,
            // raised for exactly one cycle when the CPU writes SNN_KICK=1.
            reg_snn_kick <= 1'b0;
            // snn_busy is sticky: set by kick, cleared by SNN done_layer2.
            if(snn_done_i) reg_snn_busy <= 1'b0;

            if(csr_trap_trigger_o) begin
                reg_mepc       <= csr_pc_i;
                reg_mstatus[7] <= reg_mstatus[3];
                reg_mstatus[3] <= 1'b0;
                
                //Instruction Misalligned
                if (excp_instr_mis_i) begin
                    reg_mcause[31]  <= 1'b0;
                    reg_mcause[3:0] <= 4'h0;
                end
                //Illegal Instruction
                else if (excp_illegal_instr_i) begin
                    reg_mcause[31]  <= 1'b0;
                    reg_mcause[3:0] <= 4'h2;
                end
                //Load Misalligned
                else if (excp_lsu_ld_mis_i) begin
                    reg_mcause[31]  <= 1'b0;
                    reg_mcause[3:0] <= 4'h4;
                end
                //Store Misalligned
                else if (excp_lsu_st_mis_i) begin
                    reg_mcause[31]  <= 1'b0;
                    reg_mcause[3:0] <= 4'h6;
                end
                //Environment Call
                else if (excp_ecall_i) begin
                    reg_mcause[31]  <= 1'b0;
                    reg_mcause[3:0] <= 4'hB;
                end
                //Timer Interrupt
                else if(reg_mip[7] & reg_mie[7] & reg_mstatus[3]) begin
                    reg_mcause[31]  <= 1'b1;
                    reg_mcause[3:0] <= 4'h7;
                end
                //External Interrupt
                else if (reg_mip[11] & reg_mie[11] & reg_mstatus[3]) begin
                    reg_mcause[31]  <= 1'b1;
                    reg_mcause[3:0] <= 4'hB;
                end
                else
                    reg_mcause <= 32'h0;
           end
                
           else if (csr_mret_trigger_i) begin
                reg_mstatus[3] <= reg_mstatus[7]; //Restore previous interrupt config
                reg_mstatus[7]  <= 1'b1; //Enable Backup Global Interrupt Enable pi
           end
                    
           else if(csr_we_i) begin
                case(csr_addr_i)
                `MSTATUS: begin
                    reg_mstatus[7] <= csr_i[7]; //MIE backup 
                    reg_mstatus[3] <= csr_i[3]; //Enable Global Interrupt
                 end 
                `MIE: begin
                    reg_mie[11] <= csr_i[11]; //Enable External Interrupt
                    reg_mie[7]  <= csr_i[7]; //Enable Timer Interrupt
                end
                `MCAUSE:    reg_mcause          <= csr_i;
                `MTVEC:     reg_mtvec[31:2]     <= csr_i[31:2]; //Address that processor needs to jump during trap
                `MSCRATCH:  reg_mscratch[31:0]  <= csr_i[31:0]; //CSR Data Storage
                `MEPC:      reg_mepc[31:2]      <= csr_i[31:2]; //PC Address
                `SNN_IMG_BASE: reg_snn_img_base <= csr_i[11:0];
                `SNN_KICK: begin
                    reg_snn_kick <= csr_i[0];      // pulse for one cycle
                    if (csr_i[0]) reg_snn_busy <= 1'b1; // latch busy
                end
                endcase
           end
        end
     end
     
     //Combinational Logic                        
    always @ (*) begin
       case(csr_addr_i)
        `MSTATUS:   reg_csr_wb = reg_mstatus;
        `MIE:       reg_csr_wb = reg_mie;
        `MCAUSE:    reg_csr_wb = reg_mcause;
        `MISA:      reg_csr_wb = 32'h40000100;
        `MTVEC:     reg_csr_wb = reg_mtvec;
        `MSCRATCH:  reg_csr_wb = reg_mscratch;
        `MEPC:      reg_csr_wb = reg_mepc;
        `MIP:       reg_csr_wb = reg_mip;
        `MCYCLE:    reg_csr_wb = reg_mcycle; // rdcycle -> CSR 0xC00
        `SNN_IMG_BASE: reg_csr_wb = {20'b0, reg_snn_img_base};
        `SNN_KICK:  reg_csr_wb = {31'b0, reg_snn_busy}; // CPU polls busy
        `SNN_OUT:   reg_csr_wb = {22'b0, snn_output_spike_i};
        `SNN_HID_LO: reg_csr_wb = snn_hidden_spike_i[31:0];
        `SNN_HID_HI: reg_csr_wb = snn_hidden_spike_i[63:32];
        default:    reg_csr_wb = 32'h0;
       endcase
     end
     
    assign reg_mip = {20'b0,ext_intrpt_synced,3'b0,timer_intrpt_synced,7'b0}; //bit 12 and bit 8
    assign csr_trap_trigger_o = (((reg_mip[11] & reg_mie[11]) | 
                                (reg_mip[7] & reg_mie[7])) &
                                reg_mstatus[3]) |
                                excp_illegal_instr_i |
                                excp_instr_mis_i  |
                                excp_lsu_ld_mis_i |
                                excp_lsu_st_mis_i |
                                excp_ecall_i;
                                
    assign csr_branch_o = csr_trap_trigger_o ? reg_mtvec : 
                          csr_mret_trigger_i ? reg_mepc :
                          32'h0;
                          
    assign csr_o = reg_csr_wb;
    assign snn_img_base_o = reg_snn_img_base;
    assign snn_kick_o     = reg_snn_kick;
    
endmodule
