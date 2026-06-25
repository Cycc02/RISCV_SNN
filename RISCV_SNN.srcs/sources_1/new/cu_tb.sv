`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.01.2026 22:03:28
// Design Name: 
// Module Name: cu_tb
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


module cu_tb();
reg [6:0] opcode_i;
reg [6:0] funct7_i;
reg [2:0] funct3_i;

wire       dec_regfile_we_o;
wire [2:0] dec_imm_src_o;
wire [1:0] wb_result_src_o;    

wire       exec_branch_en_o;
wire       exec_jump_en_o;
wire       exec_jump_ctrl_o;
wire       exec_lsu_en_o;
wire       exec_alu_en_o;
wire       exec_csr_rwe_o;
wire       exec_mux_rs1_o;
wire       exec_mux_imm_o;

wire [2:0] exec_branch_ctrl_o;
wire [2:0] exec_csr_ctrl_o;
wire [3:0] exec_lsu_ctrl_o;
wire [3:0] exec_alu_ctrl_o;

wire       exec_ecall_o;
wire       exec_mret_o;
wire       illegal_instr_o;

`include "defs.v"
 
controlunit dut_cu (
    .opcode_i           (opcode_i),
    .funct7_i           (funct7_i),
    .funct3_i           (funct3_i),

    .dec_regfile_we_o   (dec_regfile_we_o),
    .dec_imm_src_o      (dec_imm_src_o),
    .wb_result_src_o    (wb_result_src_o),

    .exec_branch_en_o   (exec_branch_en_o),
    .exec_jump_en_o     (exec_jump_en_o),
    .exec_jump_ctrl_o   (exec_jump_ctrl_o),
    .exec_lsu_en_o      (exec_lsu_en_o),
    .exec_alu_en_o      (exec_alu_en_o),
    .exec_csr_rwe_o     (exec_csr_rwe_o),
    .exec_mux_rs1_o     (exec_mux_rs1_o),
    .exec_mux_imm_o     (exec_mux_imm_o),

    .exec_branch_ctrl_o (exec_branch_ctrl_o),
    .exec_csr_ctrl_o    (exec_csr_ctrl_o),
    .exec_lsu_ctrl_o    (exec_lsu_ctrl_o),
    .exec_alu_ctrl_o    (exec_alu_ctrl_o),

    .exec_ecall_o       (exec_ecall_o),
    .exec_mret_o        (exec_mret_o),
    .illegal_instr_o    (illegal_instr_o)
);

typedef struct packed {
        // Enable Signals
        logic       alu_en;
        logic       lsu_en;
        logic       regfile_we;
        logic       branch_en;
        logic       jump_en;
        logic       jump_ctrl;      // 0: JAL, 1: JALR
        logic       csr_rwe;

        // Control Signals
        logic [2:0] branch_ctrl;
        logic [3:0] alu_ctrl;
        logic [3:0] lsu_ctrl;
        logic [2:0] csr_ctrl;
        
        // Mux Selectors
        logic       op1_mux_sel;    // 0: Reg, 1: PC
        logic       op2_mux_sel;    // 0: Reg, 1: Imm
        logic [2:0] imm_src;        // ITYPE, STYPE, BTYPE, UTYPE, JTYPE
        logic [1:0] wb_src;         // 0: ALU, 1: MEM, 2: PC+4 (Check your defines)

        // System
        logic       ecall;
        logic       mret;
        logic       illegal_instr;
    } ctrl_signals_t;
    
ctrl_signals_t golden_ref [logic[6:0]];
logic err_sig;

task validate_output(input logic [6:0] op);
    ctrl_signals_t exp;
    err_sig = 1'b0;
    
    if (!golden_ref.exists(op)) begin
        $display("[SKIP] No golden rule defined for Opcode: %h", op);
        return;
    end
    
    exp = golden_ref[op];

    if (dec_regfile_we_o !== exp.regfile_we) begin
        err_sig = 1'b1; 
        $error("[FAIL] Op:%d | RegFile_WE Exp:%b Got:%b", op, exp.regfile_we, dec_regfile_we_o);
    end
        
    if (dec_imm_src_o !== exp.imm_src) begin
        err_sig = 1'b1;  
        $error("[FAIL] Op:%d | Imm_Src    Exp:%h Got:%h", op, exp.imm_src, dec_imm_src_o);
    end
    
    if (wb_result_src_o !== exp.wb_src) begin
        err_sig = 1'b1; 
        $error("[FAIL] Op:%d | WB_Src     Exp:%h Got:%h", op, exp.wb_src, wb_result_src_o);
    end
    
    if (exec_alu_en_o !== exp.alu_en) begin
        err_sig = 1'b1;
        $error("[FAIL] Op:%d | ALU_En     Exp:%b Got:%b", op, exp.alu_en, exec_alu_en_o);
    end
    
    if (exec_lsu_en_o !== exp.lsu_en) begin
        err_sig = 1'b1; 
        $error("[FAIL] Op:%d | LSU_En     Exp:%b Got:%b", op, exp.lsu_en, exec_lsu_en_o);
    end
    
    if (exec_branch_en_o !== exp.branch_en) begin
        err_sig = 1'b1;
        $error("[FAIL] Op:%d | Branch_En  Exp:%b Got:%b", op, exp.branch_en, exec_branch_en_o);
    end
    
    if (exec_jump_en_o !== exp.jump_en) begin
        err_sig = 1'b1;
        $error("[FAIL] Op:%d | Jump_En    Exp:%b Got:%b", op, exp.jump_en, exec_jump_en_o);
    end
    
    if (exec_jump_ctrl_o !== exp.jump_ctrl) begin
        err_sig = 1'b1;
        $error("[FAIL] Op:%d | Jump_Ctrl  Exp:%b Got:%b", op, exp.jump_ctrl, exec_jump_ctrl_o);
    end
    
    if (exec_csr_rwe_o !== exp.csr_rwe) begin
        err_sig = 1'b1;
        $error("[FAIL] Op:%d | CSR_WE     Exp:%b Got:%b", op, exp.csr_rwe, exec_csr_rwe_o);
    end

    if (exec_mux_rs1_o !== exp.op1_mux_sel) begin
        err_sig = 1'b1;
        $error("[FAIL] Op:%d | Mux_A (RS1) Exp:%b Got:%b", op, exp.op1_mux_sel, exec_mux_rs1_o);
    end

    if (exec_mux_imm_o !== exp.op2_mux_sel) begin
        err_sig = 1'b1;
        $error("[FAIL] Op:%d | Mux_B (Imm) Exp:%b Got:%b", op, exp.op2_mux_sel, exec_mux_imm_o);
    end

    if (exec_alu_ctrl_o !== exp.alu_ctrl) begin
        err_sig = 1'b1;
        $error("[FAIL] Op:%d | ALU_Ctrl   Exp:%h Got:%h", op, exp.alu_ctrl, exec_alu_ctrl_o);
    end

    if (exec_lsu_ctrl_o !== exp.lsu_ctrl) begin
        err_sig = 1'b1;
        $error("[FAIL] Op:%d | LSU_Ctrl   Exp:%h Got:%h", op, exp.lsu_ctrl, exec_lsu_ctrl_o);
    end

    if (exec_branch_ctrl_o !== exp.branch_ctrl) begin
        err_sig = 1'b1;
        $error("[FAIL] Op:%d | Branch_Ctrl Exp:%h Got:%h", op, exp.branch_ctrl, exec_branch_ctrl_o);
    end

    if (exec_csr_ctrl_o !== exp.csr_ctrl) begin
        err_sig = 1'b1;
        $error("[FAIL] Op:%d | CSR_Ctrl    Exp:%h Got:%h", op, exp.csr_ctrl, exec_csr_ctrl_o);
    end

    if (exec_ecall_o !== exp.ecall) begin
        err_sig = 1'b1;
        $error("[FAIL] Op:%d | ECALL      Exp:%b Got:%b", op, exp.ecall, exec_ecall_o);
    end

    if (exec_mret_o !== exp.mret) begin
        err_sig = 1'b1;
        $error("[FAIL] Op:%d | MRET       Exp:%b Got:%b", op, exp.mret, exec_mret_o);
    end

    if (illegal_instr_o !== exp.illegal_instr) begin
        err_sig = 1'b1;
        $error("[FAIL] Op:%d | Illegal    Exp:%b Got:%b", op, exp.illegal_instr, illegal_instr_o);
    end
endtask

task run_tests();
    opcode_i = `U_ISA_LD; 
    funct3_i = 0; funct7_i = 0; // Don't care
    #10; 
    validate_output(opcode_i);

    opcode_i = `U_ISA_ARTH; 
    #10; 
    validate_output(opcode_i);

    opcode_i = `J_ISA; 
    #10; 
    validate_output(opcode_i);

    opcode_i = `I_ISA_J; 
    funct3_i = 3'b000; // Standard JALR
    #10; 
    validate_output(opcode_i);

    opcode_i = `B_ISA; 
    funct3_i = `BREQ; 
    #10; 
    validate_output(opcode_i);

    opcode_i = `I_ISA_LD; 
    funct3_i = `LW; // 3'b010
    #10; 
    validate_output(opcode_i);

    opcode_i = `S_ISA_ST; 
    funct3_i = 3'b010; 
    #10; 
    validate_output(opcode_i);

    opcode_i = `I_ISA_ARTH;
    funct3_i = 3'b000; 
    #10; 
    validate_output(opcode_i);

    opcode_i = `R_ISA_ARTH; 
    funct3_i = 3'b000; 
    funct7_i = 7'b0000000; 
    #10; 
    validate_output(opcode_i);

    opcode_i = `I_ISA_CSR; 
    funct3_i = `CSRRW; // 3'b001
    funct7_i = 0;
    #10; 
    validate_output(opcode_i);

    $finish;
endtask

initial begin
    golden_ref[`I_ISA_LD] = '{
        alu_en: 1, lsu_en: 1, regfile_we: 1, branch_en: 0, jump_en: 0, jump_ctrl: 0,
        csr_rwe: 0, branch_ctrl: 0, alu_ctrl: `ALU_ADD, lsu_ctrl: `LW,
        csr_ctrl: 0, op1_mux_sel: 0, op2_mux_sel: 1, imm_src: `ITYPE, wb_src: `WB_LOAD_OUT,
        ecall: 0, mret: 0, illegal_instr: 0
    };
    
    golden_ref[`I_ISA_ARTH] = '{
        alu_en: 1, lsu_en: 0, regfile_we: 1, branch_en: 0, jump_en: 0, jump_ctrl: 0,
        csr_rwe: 0, branch_ctrl: 0, alu_ctrl: `ALU_ADD, lsu_ctrl: 0,
        csr_ctrl: 0, op1_mux_sel: 0, op2_mux_sel: 1, imm_src: `ITYPE, wb_src: `WB_ALU_RESULT,
        ecall: 0, mret: 0, illegal_instr: 0
    };
        
    golden_ref[`U_ISA_LD] = '{
            alu_en: 1, lsu_en: 0, regfile_we: 1, branch_en: 0, jump_en: 0, jump_ctrl: 0, csr_rwe: 0,
            branch_ctrl: 0, alu_ctrl: `ALU_PASS_B, lsu_ctrl: 0, csr_ctrl: 0,
            op1_mux_sel: 0, op2_mux_sel: 1, imm_src: `UTYPE, wb_src: `WB_ALU_RESULT,
            ecall: 0, mret: 0, illegal_instr: 0
    };

    golden_ref[`U_ISA_ARTH] = '{
        alu_en: 1, lsu_en: 0, regfile_we: 1, branch_en: 0, jump_en: 0, jump_ctrl: 0, csr_rwe: 0,
        branch_ctrl: 0, alu_ctrl: `ALU_ADD, lsu_ctrl: 0, csr_ctrl: 0,
        op1_mux_sel: 1, op2_mux_sel: 1, imm_src: `UTYPE, wb_src: `WB_ALU_RESULT,
        ecall: 0, mret: 0, illegal_instr: 0
    };

    golden_ref[`J_ISA] = '{
        alu_en: 1, lsu_en: 0, regfile_we: 1, branch_en: 0, jump_en: 1, jump_ctrl: 1, csr_rwe: 0,
        branch_ctrl: 0, alu_ctrl: `ALU_ADD, lsu_ctrl: 0, csr_ctrl: 0,
        op1_mux_sel: 1, op2_mux_sel: 0, imm_src: `JTYPE, wb_src: `WB_ALU_RESULT,
        ecall: 0, mret: 0, illegal_instr: 0
    };

    golden_ref[`I_ISA_J] = '{
        alu_en: 1, lsu_en: 0, regfile_we: 1, branch_en: 0, jump_en: 1, jump_ctrl: 0, csr_rwe: 0,
        branch_ctrl: 0, alu_ctrl: `ALU_ADD, lsu_ctrl: 0, csr_ctrl: 0,
        op1_mux_sel: 1, op2_mux_sel: 0, imm_src: `ITYPE, wb_src: `WB_ALU_RESULT,
        ecall: 0, mret: 0, illegal_instr: 0
    };

    golden_ref[`B_ISA] = '{
        alu_en: 1, lsu_en: 0, regfile_we: 0, branch_en: 1, jump_en: 0, jump_ctrl: 0, csr_rwe: 0,
        branch_ctrl: 3'b000, alu_ctrl: `ALU_SUB, lsu_ctrl: 0, csr_ctrl: 0,
        op1_mux_sel: 0, op2_mux_sel: 0, imm_src: `BTYPE, wb_src: `WB_PC_TARGET,
        ecall: 0, mret: 0, illegal_instr: 0
    };

    golden_ref[`S_ISA_ST] = '{
        alu_en: 1, lsu_en: 1, regfile_we: 0, branch_en: 0, jump_en: 0, jump_ctrl: 0, csr_rwe: 0,
        branch_ctrl: 0, alu_ctrl: `ALU_ADD, lsu_ctrl: 4'b1010, csr_ctrl: 0,
        op1_mux_sel: 0, op2_mux_sel: 1, imm_src: `STYPE, wb_src: `WB_ALU_RESULT,
        ecall: 0, mret: 0, illegal_instr: 0
    };

    golden_ref[`R_ISA_ARTH] = '{
        alu_en: 1, lsu_en: 0, regfile_we: 1, branch_en: 0, jump_en: 0, jump_ctrl: 0, csr_rwe: 0,
        branch_ctrl: 0, alu_ctrl: `ALU_ADD, lsu_ctrl: 0, csr_ctrl: 0,
        op1_mux_sel: 0, op2_mux_sel: 0, imm_src: `UTYPE, wb_src: `WB_ALU_RESULT,
        ecall: 0, mret: 0, illegal_instr: 0
    };

    golden_ref[`I_ISA_CSR] = '{
        alu_en: 0, lsu_en: 0, regfile_we: 1, branch_en: 0, jump_en: 0, jump_ctrl: 0, csr_rwe: 1,
        branch_ctrl: 0, alu_ctrl: 0, lsu_ctrl: 0, csr_ctrl: `CSRRW,
        op1_mux_sel: 0, op2_mux_sel: 0, imm_src: `ITYPE, wb_src: `WB_CSR,
        ecall: 0, mret: 0, illegal_instr: 0
    };
    
    run_tests();
end

endmodule
