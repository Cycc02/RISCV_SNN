`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.12.2025 15:45:14
// Design Name: 
// Module Name: defs
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

//NOP Instruction Operation Code
`define NOP         32'h00000013

//ALU OPERATIONS (Follow R-type encoding)
`define ALU_ADD     4'b0000
`define ALU_SUB     4'b1000
`define ALU_SLL     4'b0001
`define ALU_SLT     4'b0010
`define ALU_SLTU    4'b0011
`define ALU_XOR     4'b0100
`define ALU_SRL     4'b0101
`define ALU_SRA     4'b1101
`define ALU_OR      4'b0110
`define ALU_AND     4'b0111
`define ALU_PASS_B  4'b1111

//BRANCH OPERATIONS (Follow B-type encoding)
`define BREQ    3'b000
`define BRNEQ   3'b001
`define BRLT    3'b100
`define BRMTEQ  3'b101
`define BRLTU   3'b110
`define BRMTEQU 3'b111 


//EXTENSION UNIT (Follow Instruction Type)
`define ITYPE   3'b000
`define STYPE   3'b001
`define BTYPE   3'b010
`define UTYPE   3'b011
`define JTYPE   3'b100

//LOAD STORE OPERATIONS
`define LB  4'b0000
`define LH  4'b0001
`define LW  4'b0010
`define LBU 4'b0100
`define LHU 4'b0101
`define SB  4'b1000
`define SH  4'b1001
`define SW  4'b1010

//LOAD EXTENSION CONTROLS
`define ZEXT  2'b01
`define SEXT  2'b10

//CSR INSTRUCTIONS
`define CSRRW  3'b001 
`define CSRRS  3'b010
`define CSRRC  3'b011
`define CSRRWI 3'b101
`define CSRRSI 3'b110
`define CSRRCI 3'b111

//CSR Address
`define MSTATUS     12'h300
`define MISA        12'h301
`define MIE         12'h304
`define MTVEC       12'h305
`define MSCRATCH    12'h340
`define MEPC        12'h341
`define MCAUSE      12'h342 
`define MIP         12'h344

//OPCODE Instruction Type 
`define I_ISA_LD        7'd3
`define I_ISA_ARTH      7'd19
`define U_ISA_ARTH      7'd23
`define S_ISA_ST        7'd35
`define R_ISA_ARTH      7'd51
`define U_ISA_LD        7'd55
`define B_ISA           7'd99
`define I_ISA_J         7'd103
`define J_ISA           7'd111
`define I_ISA_CSR       7'd115

//WRITEBACK MUX
`define WB_CSR          2'b00
`define WB_ALU_RESULT   2'b01
`define WB_PC_TARGET    2'b10
`define WB_LOAD_OUT     2'b11

//PROGRAM COUNTER MUX
`define FE_PC_TARGET    2'b00
`define FE_BRANCH_CSR   2'b01
`define FE_PC_PLUS4     2'b10
 
 //MEMORY_DEPTH (legacy, kept for compatibility)
 `define MEM_DEPTH      'd4096
 //ITCM = 32KB, DTCM = 16KB to match link.ld
 `define ITCM_DEPTH     'd32768
 `define DTCM_DEPTH     'd16384

 //PERFORMANCE COUNTER CSR (rdcycle)
 `define MCYCLE         12'hC00

 //HAZARD LOGIC
 `define NORMAL_OP      2'b00
 `define FWD_MEM        2'b10
 `define FWD_WB         2'b11
 
 //SNN INTERFACE
 `define SNN_IMG_BASE   12'hBC0 //SNN CSR Base Address
 `define SNN_KICK       12'hBC2
 `define SNN_OUT        12'hBC3 //SNN classification result (output_spike_o, 10-bit)
 `define SNN_HID_LO     12'hBC4 //SNN hidden spike low word  (hidden_spike_o[31:0])
 `define SNN_HID_HI     12'hBC5 //SNN hidden spike high word (hidden_spike_o[63:32])