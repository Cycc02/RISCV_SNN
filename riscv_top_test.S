# riscv_top_test.S
# Integration test program for riscv_top_tb.sv
#
# Loads known values into x1-x6 using ADDI, then halts in an infinite loop.
# The testbench scoreboard reads these register values after 1000 clock cycles
# and checks them against the expected values below.
#
# Expected results:
#   x1 = 5,  x2 = 10, x3 = 15
#   x4 = 20, x5 = 25, x6 = 30
#
# Build:
#   riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -ffreestanding -nostdlib \
#       -T link.ld -o riscv_top_test.elf riscv_top_test.S
#   riscv64-unknown-elf-objcopy -O verilog --verilog-data-width=4 \
#       --only-section=.text riscv_top_test.elf itcm.hex
#
# Instruction encoding (I-type ADDI):
#   31      20 19  15 14 12 11   7 6      0
#   [ imm[11:0] | rs1  | 000 |  rd  | 0010011 ]
#
#   addi x1, x0,  5  -> 0x00500093
#   addi x2, x0, 10  -> 0x00A00113
#   addi x3, x0, 15  -> 0x00F00193
#   addi x4, x0, 20  -> 0x01400213
#   addi x5, x0, 25  -> 0x01900293
#   addi x6, x0, 30  -> 0x01E00313
#   jal  x0, 0       -> 0x0000006F  (infinite loop)

.section .text
.global _start

_start:
    addi x1, x0, 5      # x1 = 5
    addi x2, x0, 10     # x2 = 10
    addi x3, x0, 15     # x3 = 15
    addi x4, x0, 20     # x4 = 20
    addi x5, x0, 25     # x5 = 25
    addi x6, x0, 30     # x6 = 30

halt:
    j halt               # infinite loop — CPU idles here while testbench checks GPRs
