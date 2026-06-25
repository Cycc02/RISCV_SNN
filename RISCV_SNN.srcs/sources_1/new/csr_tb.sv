`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.12.2025 15:53:28
// Design Name: 
// Module Name: csr_tb
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


module csr_tb();
reg         clk_i;
reg         rstn_i;

reg         csr_rwe_i;
reg [11:0]  csr_addr_i;
reg [4:0]   rs1_i;
reg [31:0]  rs1_data_i;
reg [31:0]  pc_i;
reg         mret_trigger_i;
reg [2:0]   csr_ctrl_i;

reg         timer_intrpt;
reg         ext_intrpt;
reg         illegal_instr_excp;
reg         instr_mis_excp;
reg         lsu_ld_mis_excp;
reg         lsu_st_mis_excp;
reg         ecall_excp;

wire [31:0] wb_csr_o;
wire [31:0] branch_csr_o;
wire        trap_trigger_o;

`include "defs.v"

csr dut_csr (
    .clk_i              (clk_i),
    .rstn_i             (rstn_i),
    .csr_rwe_i          (csr_rwe_i),
    .csr_addr_i         (csr_addr_i),
    .rs1_i              (rs1_i),
    .rs1_data_i         (rs1_data_i),
    .pc_i               (pc_i),
    .mret_trigger_i     (mret_trigger_i),
    .csr_ctrl_i         (csr_ctrl_i),
    .timer_intrpt       (timer_intrpt),
    .ext_intrpt         (ext_intrpt),
    .illegal_instr_excp (illegal_instr_excp),
    .instr_mis_excp     (instr_mis_excp),
    .lsu_ld_mis_excp    (lsu_ld_mis_excp),
    .lsu_st_mis_excp    (lsu_st_mis_excp),
    .ecall_excp         (ecall_excp),
    
    .wb_csr_o           (wb_csr_o),
    .branch_csr_o       (branch_csr_o),
    .trap_trigger_o     (trap_trigger_o)
);

int csr_op[] = '{`CSRRW, `CSRRS, `CSRRC, `CSRRWI, `CSRRSI, `CSRRCI};
int csr_addr[] = '{`MSTATUS, `MIE, `MCAUSE, `MTVEC, `MSCRATCH, `MEPC};

logic [31:0] shadow_map [logic [11:0]]; //For each CSR Address
logic csr_check_trig;
logic csr_out_err;
logic csr_addr_err;
logic csr_reg_err;
logic csr_trap_cause_err;
logic csr_trap_pc_err;
logic csr_trap_stat_err;
logic [31:0]expected_mcause;
logic [31:0]old_mstatus;
logic [6:0] csr_excp;
logic [31:0] old_val;
logic [31:0] target_data;

function logic [31:0] expected_out(input logic [11:0] addr);
    return shadow_map.exists(addr) ? shadow_map[addr] : 32'h0;
endfunction

function logic shadow_we(input logic [4:0] rs1_i, input logic [2:0] csr_ctrl_i);
    shadow_we = 1'b0;
    
    if(csr_ctrl_i !== 3'b0) begin
        if((csr_ctrl_i == `CSRRW) || (csr_ctrl_i == `CSRRWI)) begin
            shadow_we = 1'b1;
        end
        else if (rs1_i !== 5'b0) shadow_we = 1'b1;
        else shadow_we = 1'b0;
    end
    return shadow_we;
 endfunction
 
task validate_csr (input logic [11:0] addr, input logic [2:0] op, input logic [31:0] data, input logic [4:0] rs1_data);
    
    csr_addr_i = addr;
    csr_ctrl_i = op;
    rs1_data_i = data;
    rs1_i = rs1_data;
    
    #1;
    old_val = expected_out(addr); //Declare data from shadow_map

    csr_check_trig = 1'b0;
    csr_out_err = 1'b0;
    csr_reg_err = 1'b0;

    if(wb_csr_o !== old_val) begin
        csr_out_err = 1'b1;
        $error("Read Failed @ Address %h, Expected: %h | CSR: %h", addr, old_val, wb_csr_o);
    end
    else csr_out_err = 1'b0;
         
    case(csr_ctrl_i)
    `CSRRW: target_data = rs1_data_i;
    `CSRRS: target_data = old_val | rs1_data_i;
    `CSRRC:  target_data = old_val & ~(rs1_data_i);
    `CSRRWI: target_data = {27'b0, rs1_i};
    `CSRRSI: target_data = old_val | {27'b0, rs1_i};
    `CSRRCI: target_data = old_val & ~({27'b0, rs1_i});
    default: target_data = 32'h0;
    endcase
    
    csr_addr_err = 1'b0;
    
    if(shadow_we(rs1_data,op)) begin
        case(addr)
            `MSTATUS: begin
                shadow_map[addr][12:11] = 2'b11; //Machine Mode
                shadow_map[addr][7] = target_data[7];
                shadow_map[addr][3] = target_data[3];
            end
            `MIE: begin
                shadow_map[addr][11] = target_data[11];
                shadow_map[addr][7] = target_data[7];
            end
            `MCAUSE: shadow_map[addr] = target_data;
            `MTVEC: shadow_map[addr][31:2] = target_data[31:2];
            `MSCRATCH: shadow_map[addr] = target_data;
            `MEPC: shadow_map[addr][31:2] = target_data[31:2];
            default: begin
                shadow_map[addr] = 32'h0;
                csr_addr_err = 1'b1;
                $error("Invalid CSR Address: %h", addr);
            end
        endcase
    end
    
    repeat(3) @(posedge clk_i);
    
    //Final Bitwise Check
    #1;
    if (wb_csr_o !== shadow_map[addr]) begin
        csr_reg_err = 1'b1;
        $error("Write Error @ Address: %h, Expected: %h | CSR: %h", addr, shadow_map[addr], wb_csr_o);
    end 
    else begin
        csr_check_trig = 1'b1;
        csr_reg_err = 1'b0;
    end
         
 endtask

task validate_trap (logic [11:0] addr, logic [6:0] excp_vector);
    expected_mcause = 32'h0;
    csr_trap_cause_err = 1'b0;
    csr_trap_pc_err = 1'b0;
    csr_trap_stat_err = 1'b0;
    csr_reg_err = 1'b0;
    csr_addr_err = 1'b0;
    
    //Store old MSTATUS
    old_mstatus = shadow_map[`MSTATUS];
    #1;
    
    //Make sure the previous data is not written into register during exception
    if(wb_csr_o !== shadow_map[addr]) begin
        csr_reg_err = 1'b1;
        $error("Trap Error @ Address %h, Expected:%h | CSR: %h", addr, shadow_map[addr], wb_csr_o);
    end
    
    //Check if jumped to trap vector
    if(branch_csr_o !== shadow_map[`MTVEC]) begin
        csr_addr_err = 1'b1;
        $error("Trap Vector Error, Expected Branch: %h | CSR Branch: %h", shadow_map[`MTVEC],branch_csr_o);
    end
    
    //Check MCAUSE update
    case (excp_vector)
    7'h01: begin //ecall_excp
        expected_mcause[31] = 1'b0;
        expected_mcause[3:0] = 4'b1011;
    end  
    7'h02: begin //lsu_st_mis_excp
        expected_mcause[31] = 1'b0;
        expected_mcause[3:0] = 4'b0110;
    end
    7'h04: begin //lsu_ld_mis_excp
        expected_mcause[31] = 1'b0;
        expected_mcause[3:0] = 4'b0100;
    end
    7'h08: begin //instr_mis_excp
        expected_mcause[31] = 1'b0;
        expected_mcause[3:0] = 4'b0000;
    end
    7'h10: begin //illegal_instr_excp
        expected_mcause[31] = 1'b0;
        expected_mcause[3:0] = 4'b0010;
    end
    7'h20: begin // ext_intrpt
        expected_mcause[31] = 1'b1;
        expected_mcause[3:0] = 4'b1011;
    end
    7'h40: begin // timer_intrpt
        expected_mcause[31] = 1'b1;
        expected_mcause[3:0] = 4'b0111;
    end
    endcase
    
    //Tick Clock to Update Interrupt Triggered
    repeat(3)@(posedge clk_i);
    #1;
    
    //Check Cause
    if(dut_csr.csr_rf.reg_mcause !== expected_mcause) begin
        csr_trap_cause_err = 1'b1;
        $error("Trap Cause Error, Expected Cause: %h | CSR Cause: %h", expected_mcause, dut_csr.csr_rf.reg_mcause);
    end
    
    //Check PC Locked
    if(dut_csr.csr_rf.reg_mepc !== pc_i) begin
        csr_trap_pc_err = 1'b1;
        $error("Trap PC Error, Expected PC: %h | CSR PC: %h", pc_i , dut_csr.csr_rf.reg_mepc);
    end
    
    //Check Interrupt disabled
    if(dut_csr.csr_rf.reg_mstatus[3] !== 1'b0) begin
        csr_trap_stat_err = 1'b1;
        $error("Trap Status Error, Expected: %h | CSR: %h", 1'b0 , dut_csr.csr_rf.reg_mstatus[3]);
    end
    
    //Check Interrupt Preserved
    if(dut_csr.csr_rf.reg_mstatus[7] !== old_mstatus[3]) begin
        csr_trap_stat_err = 1'b1;
        $error("Trap Status Restore Error, Expected: %h | CSR: %h", old_mstatus[3], dut_csr.csr_rf.reg_mstatus[7]);
    end
    
    //Update shadow_map for next iteration
    shadow_map[`MSTATUS][7] = old_mstatus[3];
    shadow_map[`MSTATUS][3] = 1'b0;
    shadow_map[`MSTATUS][12:11] = 2'b11;
    shadow_map[`MEPC] = pc_i;
    shadow_map[`MCAUSE] = expected_mcause;
           
endtask
 
initial begin
    clk_i = 1'b0;
    forever #5 clk_i = ~clk_i;
end

initial begin
    rstn_i = 1'b0;
    csr_rwe_i = 1'b0;
    mret_trigger_i = 1'b0;
    csr_ctrl_i = 2'b0;
    rs1_i = 5'b0;
    pc_i = 32'h0;
    csr_out_err = 1'b0;
    csr_trap_stat_err = 1'b0;
    csr_excp = 7'b0;
    old_mstatus = 32'h0;
    expected_mcause = 32'h0;
    csr_trap_cause_err = 1'b0;
    csr_trap_pc_err = 1'b0;
    csr_trap_stat_err = 1'b0;
    shadow_map[`MSTATUS] = {19'b0, 2'b11, 11'b0};
    {timer_intrpt, ext_intrpt, illegal_instr_excp, instr_mis_excp, lsu_ld_mis_excp, lsu_st_mis_excp, ecall_excp} = 7'b0;
     
    #10 rstn_i = 1'b1;
    
    $display("=== Normal CSR Read/Write Tests ===");
    //Normal CSR Operation
    foreach (csr_addr[j]) begin
        #1 csr_addr_i = csr_addr[j];
        case(csr_addr[j])
            `MSTATUS:  $display("  Testing CSR: MSTATUS  (addr=0x%0h)", csr_addr[j]);
            `MIE:      $display("  Testing CSR: MIE      (addr=0x%0h)", csr_addr[j]);
            `MCAUSE:   $display("  Testing CSR: MCAUSE   (addr=0x%0h)", csr_addr[j]);
            `MTVEC:    $display("  Testing CSR: MTVEC    (addr=0x%0h)", csr_addr[j]);
            `MSCRATCH: $display("  Testing CSR: MSCRATCH (addr=0x%0h)", csr_addr[j]);
            `MEPC:     $display("  Testing CSR: MEPC     (addr=0x%0h)", csr_addr[j]);
            default:   $display("  Testing CSR: UNKNOWN  (addr=0x%0h)", csr_addr[j]);
        endcase
        foreach (csr_op[i]) begin
            csr_ctrl_i = csr_op[i]; //ReadWrite Operation
            csr_rwe_i = 1'b1;
            
            //check 3 propagations
            repeat(3) begin
                if((csr_addr_i !== `MTVEC) && (csr_addr_i !== `MEPC)) begin
                    validate_csr(csr_addr_i, csr_op[i], $urandom(), $urandom());
                end
                else begin
                    validate_csr(csr_addr_i, `CSRRW, 32'h0, 5'd1);
                end
                if(csr_check_trig)
                    $display("    [PASS] op=%3b | addr=0x%0h | written=0x%0h | readback=0x%0h",
                        csr_ctrl_i, csr_addr_i, target_data, wb_csr_o);
            end
        end
    end
    $display("Normal CSR Tests Complete");

    rstn_i = 1'b0;
    #20;           // Hold reset
    rstn_i = 1'b1; // Release reset
    #10;           // Wait for stability
    shadow_map.delete();
    shadow_map[`MSTATUS] = {19'b0, 2'b11, 11'b0};
    shadow_map[`MTVEC]    = 32'h0;             
    shadow_map[`MIE]      = 32'h0;
    shadow_map[`MCAUSE]   = 32'h0;
    shadow_map[`MSCRATCH] = 32'h0;
    shadow_map[`MEPC]     = 32'h0;
    
    $display("\n=== Exception and Trap Handling Tests ===");
    //Exeception CSR Operation
    foreach (csr_addr[j]) begin
        #1 csr_addr_i = csr_addr[j];
        foreach (csr_op[i]) begin
            //check 3 propagations
            repeat(3) begin
                csr_rwe_i = 1'b1;
                validate_csr(`MSTATUS, `CSRRSI, 32'd8, 5'd8); //CSRRSI (Set Immediate), Data/Zimm: 8 (Bit 3 for MIE)
                validate_csr(`MIE, `CSRRW, 32'hFFFF_FFFF, 5'd1); // Enable Individual interrupts
                csr_ctrl_i = 3'b000;
                csr_rwe_i = 1'b0;
                csr_excp = 1'b1 << $urandom_range(0,6);
                @(posedge clk_i);
                #1;

                case(csr_excp)
                    7'h01: $display("  Injecting Exception: ECALL");
                    7'h02: $display("  Injecting Exception: Store Address Misaligned");
                    7'h04: $display("  Injecting Exception: Load Address Misaligned");
                    7'h08: $display("  Injecting Exception: Instruction Misaligned");
                    7'h10: $display("  Injecting Exception: Illegal Instruction");
                    7'h20: $display("  Injecting Interrupt:  External Interrupt");
                    7'h40: $display("  Injecting Interrupt:  Timer Interrupt");
                endcase

                {timer_intrpt, ext_intrpt, illegal_instr_excp, instr_mis_excp, lsu_ld_mis_excp, lsu_st_mis_excp, ecall_excp} = csr_excp;
                if(timer_intrpt || ext_intrpt) begin
                    repeat(4)@(posedge clk_i);
                end
                else begin
                    @(posedge clk_i);
                end
                
                #1;
                {timer_intrpt, ext_intrpt, illegal_instr_excp, instr_mis_excp, lsu_ld_mis_excp, lsu_st_mis_excp, ecall_excp} = 7'h0;
                validate_trap(csr_addr_i, csr_excp);
                if(!csr_trap_cause_err && !csr_trap_pc_err && !csr_trap_stat_err)
                    $display("    [PASS] trap_trigger=%b | mcause=0x%0h | mepc=0x%0h | mstatus[MIE]=0b%b",
                        trap_trigger_o, dut_csr.csr_rf.reg_mcause, dut_csr.csr_rf.reg_mepc, dut_csr.csr_rf.reg_mstatus[3]);
                @(posedge clk_i);
            end
        end
    end
    $display("Exception Tests Complete");
    $display("CSR Validation Complete");
    #1 $finish;
end
endmodule
