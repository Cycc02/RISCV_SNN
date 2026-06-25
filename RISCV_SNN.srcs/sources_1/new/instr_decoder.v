`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.12.2025 11:32:17
// Design Name: 
// Module Name: instr_decoder
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


module controlunit(
    input [6:0] opcode_i,
    input [6:0] funct7_i,
    input [2:0] funct3_i,

    output       dec_regfile_we_o,
    output [2:0] dec_imm_src_o,
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
    output illegal_instr_o
);

    reg         reg_alu_en;
    reg         reg_lsu_en;
    reg         reg_regfile_we;
    reg         reg_branch_en;
    reg         reg_jump_en;
    reg         reg_jump_ctrl;
    reg         reg_csr_rd;
    reg [2:0]   reg_branch_ctrl;
    reg [3:0]   reg_alu_ctrl;
    reg [3:0]   reg_lsu_ctrl;
    reg [2:0]   reg_csr_ctrl;
    reg         reg_rs1_ctrl;
    reg         reg_imm_ctrl;
    reg [2:0]   reg_imm_src;
    reg [1:0]   reg_wb_result_src;
    
    reg         reg_ecall;
    reg         reg_mret;
    reg         reg_illegal_instr;
    
    always @ (*) begin
        reg_alu_en          = 1'b0;
        reg_lsu_en          = 1'b0;
        reg_regfile_we      = 1'b0;
        reg_branch_en       = 1'b0;
        reg_jump_en         = 1'b0;
        reg_jump_ctrl       = 1'b0;
        reg_csr_rd          = 1'b0;
        reg_branch_ctrl     = 3'h0;
        reg_alu_ctrl        = 4'h0;
        reg_lsu_ctrl        = 4'h0;
        reg_csr_ctrl        = 3'h0;
        reg_rs1_ctrl        = 1'b0; //default RD1E
        reg_imm_ctrl        = 1'b0; //default RD2E
        reg_imm_src         = `ITYPE;
        reg_wb_result_src   = `WB_ALU_RESULT;
        reg_ecall           = 1'b0;
        reg_mret            = 1'b0;
        reg_illegal_instr   = 1'b0;
        case(opcode_i)
        `I_ISA_LD: begin
            reg_alu_en  = 1'b1;
            reg_lsu_en   = 1'b1;
            reg_regfile_we = 1'b1; //Allow data to be saved into regfile
            reg_alu_ctrl = `ALU_ADD;
            reg_lsu_ctrl = {1'b0,funct3_i};
            reg_rs1_ctrl = 1'b0; //RD1E = 0, PC = 1
            reg_imm_ctrl = 1'b1; //RD2E = 0, Imm = 1
            reg_imm_src = `ITYPE;
            reg_wb_result_src = `WB_LOAD_OUT;
        end
        `I_ISA_ARTH: begin
            reg_rs1_ctrl = 1'b0;
            reg_imm_ctrl = 1'b1;
            reg_imm_src = `ITYPE;
            reg_regfile_we = 1'b1;
            reg_alu_en = 1'b1;
            reg_wb_result_src = `WB_ALU_RESULT;
            reg_alu_ctrl = (funct3_i == 3'b101 ? {funct7_i[5],funct3_i} : {1'b0,funct3_i});
        end
        `U_ISA_ARTH: begin
            reg_rs1_ctrl = 1'b1;
            reg_imm_ctrl = 1'b1;
            reg_imm_src = `UTYPE;
            reg_regfile_we = 1'b1;
            reg_alu_en = 1'b1;
            reg_alu_ctrl = `ALU_ADD;
            reg_wb_result_src = `WB_ALU_RESULT;
        end
        `S_ISA_ST: begin
            reg_imm_src = `STYPE;
            reg_imm_ctrl = 1'b1;
            reg_rs1_ctrl = 1'b0;
            reg_alu_en = 1'b1;
            reg_alu_ctrl = `ALU_ADD;
            reg_lsu_en = 1'b1;
            reg_lsu_ctrl = {1'b1,funct3_i};
            reg_wb_result_src = `WB_ALU_RESULT;
            reg_regfile_we = 1'b0;
        end
        `R_ISA_ARTH: begin
            reg_imm_src = `UTYPE; //Not used in RTYPE
            reg_imm_ctrl = 1'b0;
            reg_rs1_ctrl = 1'b0;
            reg_alu_en = 1'b1;
            reg_alu_ctrl = {funct7_i[5],funct3_i};
            reg_wb_result_src = `WB_ALU_RESULT;
            reg_regfile_we = 1'b1;
        end
        `U_ISA_LD: begin
            reg_imm_src = `UTYPE;
            reg_imm_ctrl = 1'b1;
            reg_rs1_ctrl = 1'b0; 
            reg_alu_en = 1'b1;
            reg_alu_ctrl = `ALU_PASS_B; //Direct pass RD2E to output
            reg_wb_result_src = `WB_ALU_RESULT;
            reg_regfile_we = 1'b1;
        end
        `B_ISA: begin
            reg_imm_src = `BTYPE;
            reg_imm_ctrl = 1'b0;
            reg_rs1_ctrl = 1'b0;
            reg_alu_en = 1'b1;
            reg_alu_ctrl = `ALU_SUB;
            reg_wb_result_src = `WB_PC_TARGET;
            reg_branch_en = 1'b1;
            reg_branch_ctrl = funct3_i;
        end
        `I_ISA_J: begin
            reg_imm_src = `ITYPE;
            reg_imm_ctrl = 1'b0; //Must let RD2E register value = 4
            reg_rs1_ctrl = 1'b0;
            reg_alu_en = 1'b1;
            reg_alu_ctrl = `ALU_ADD;
            // JALR link value: WB_ALU_RESULT wrote the jump TARGET to rd
            // (ALU computes rs1+imm here). Use pc_plus4 like JAL does.
            reg_wb_result_src = `WB_PC_TARGET;
            reg_jump_en = 1'b1;
            reg_jump_ctrl = 1'b0;
            reg_regfile_we = 1'b1;
        end
        `J_ISA: begin
            reg_imm_src = `JTYPE;
            reg_imm_ctrl = 1'b0; //RD2E = 4
            reg_rs1_ctrl = 1'b1;
            reg_alu_en = 1'b1;
            reg_alu_ctrl = `ALU_ADD;
            reg_wb_result_src = `WB_PC_TARGET;
            reg_jump_en = 1'b1;
            reg_jump_ctrl = 1'b1;
            reg_regfile_we = 1'b1;
        end
        `I_ISA_CSR: begin
            if(&(~funct3_i) && funct7_i == 7'b0) begin
                reg_ecall = 1'b1;
            end
            else if (&(~funct3_i) && funct7_i == 7'h18) begin
                reg_mret = 1'b1;
            end
            else begin
                reg_csr_rd = 1'b1;
                reg_wb_result_src = `WB_CSR;
                reg_csr_ctrl = funct3_i;
                reg_regfile_we = 1'b1;
            end
        end
        default: begin
            reg_illegal_instr = 1'b1;
        end
      endcase
     end
     
     //Combinational 
     assign exec_alu_en_o = reg_alu_en;          
     assign exec_lsu_en_o = reg_lsu_en;          
     assign exec_branch_en_o = reg_branch_en;     
     assign exec_jump_en_o = reg_jump_en;      
     assign exec_jump_ctrl_o = reg_jump_ctrl; 
     assign exec_csr_rwe_o = reg_csr_rd;     
     assign exec_branch_ctrl_o = reg_branch_ctrl;     
     assign exec_alu_ctrl_o = reg_alu_ctrl;       
     assign exec_lsu_ctrl_o = reg_lsu_ctrl;       
     assign exec_csr_ctrl_o = reg_csr_ctrl;        
     assign exec_mux_rs1_o = reg_rs1_ctrl;        
     assign exec_mux_imm_o = reg_imm_ctrl;
            
     assign dec_imm_src_o = reg_imm_src;
     assign dec_regfile_we_o = reg_regfile_we;          
     assign wb_result_src_o = reg_wb_result_src;   

     assign exec_ecall_o = reg_ecall;           
     assign exec_mret_o = reg_mret;  
     assign illegal_instr_o = reg_illegal_instr;                 
endmodule

