#!/bin/bash
# Minimal UART test build — replaces CoreMark with a single uart_puts call.
# Generates itcm.hex + dtcm.hex ready for re-synthesis.
set -e

PROJ_ROOT="$(cd "$(dirname "$0")" && pwd)"
CC="${RISCV_CC:-riscv64-unknown-elf-gcc}"
OBJCOPY="${RISCV_OBJCOPY:-riscv64-unknown-elf-objcopy}"
OBJDUMP="${RISCV_OBJDUMP:-riscv64-unknown-elf-objdump}"

echo "=== Building minimal UART test for RV32I ==="

"$CC" -march=rv32i -mabi=ilp32 -O1 -ffreestanding -nostdlib \
    -T "${PROJ_ROOT}/link.ld" \
    -o "${PROJ_ROOT}/uart_test.elf" \
    "${PROJ_ROOT}/crt0.S" \
    "${PROJ_ROOT}/main.c"

echo "[OK] Compiled: uart_test.elf"

"$OBJCOPY" -O verilog --verilog-data-width=4 \
    --only-section=.init --only-section=.text \
    "${PROJ_ROOT}/uart_test.elf" "${PROJ_ROOT}/itcm.hex"

"$OBJCOPY" -O verilog --verilog-data-width=4 \
    --change-addresses -0x10000 \
    --only-section=.data --only-section=.sdata --only-section=.rodata \
    "${PROJ_ROOT}/uart_test.elf" "${PROJ_ROOT}/dtcm.hex"

"$OBJDUMP" -d "${PROJ_ROOT}/uart_test.elf" > "${PROJ_ROOT}/uart_test.asm"

echo "[OK] Generated: itcm.hex  dtcm.hex  uart_test.asm"
echo ""
echo "=== Next: re-run Synthesis in Vivado, then Implementation + Bitstream ==="
