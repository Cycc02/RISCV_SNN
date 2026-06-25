#!/bin/bash
echo "RISC-V TEST"
TEST_NAME=$1

if [ -z "$TEST_NAME" ]; then
	echo "[ERROR] Provide test name"
	exit 1
fi

riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -ffreestanding -nostdlib -I. -T link.ld -o firmware.elf ${TEST_NAME}.S

if [ $? -ne 0 ]; then
	echo "[ERROR] GCC Compilation Failed"
	exit 1
fi

riscv64-unknown-elf-objcopy -O verilog --verilog-data-width=4 --only-section=.text --only-section=.init firmware.elf itcm.hex
riscv64-unknown-elf-objcopy -O verilog --verilog-data-width=4 --change-addresses -0x10000 --only-section=.data --only-section=.rodata --only-section=.bss firmware.elf dtcm.hex
riscv64-unknown-elf-objdump -d firmware.elf > firmware.asm

echo "[SUCCESS] itcm.hex, dtcm.hex and firmware.asm generated!"


