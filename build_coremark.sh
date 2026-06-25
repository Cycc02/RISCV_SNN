#!/bin/bash
# Build CoreMark for RISC-V bare-metal simulation
# Generates itcm.hex + dtcm.hex ready for Vivado simulation with coremark_tb.v
#
# Prerequisites:
#   riscv64-unknown-elf-gcc with RV32I multilib support
#
# Usage (from project root):
#   bash build_coremark.sh

set -e

PROJ_ROOT="$(cd "$(dirname "$0")" && pwd)"
COREMARK="${PROJ_ROOT}/coremark"
PORT="${COREMARK}/coremark-riscv"

CC="${RISCV_CC:-riscv64-unknown-elf-gcc}"
OBJCOPY="${RISCV_OBJCOPY:-riscv64-unknown-elf-objcopy}"
OBJDUMP="${RISCV_OBJDUMP:-riscv64-unknown-elf-objdump}"
SIZE="${RISCV_SIZE:-riscv64-unknown-elf-size}"

# Use arrays so paths with spaces are passed as single arguments
CFLAGS=(
    -march=rv32i -mabi=ilp32
    -O2
    -ffreestanding -nostdlib
    -DITERATIONS=2000
    -DHAS_FLOAT=0
    -DPERFORMANCE_RUN=1
    -DMAIN_HAS_NOARGC=1
    -DSEED_METHOD=2
    -DMEM_METHOD=2
    -DMULTITHREAD=1
    -DTOTAL_DATA_SIZE=2000
    "-I${PORT}"
    "-I${COREMARK}"
)

SRCS=(
    "${PROJ_ROOT}/crt0.S"
    "${COREMARK}/core_list_join.c"
    "${COREMARK}/core_matrix.c"
    "${COREMARK}/core_state.c"
    "${COREMARK}/core_util.c"
    "${COREMARK}/core_main.c"
    "${PORT}/core_portme.c"
)

echo "=== Building CoreMark for RV32I bare-metal ==="
echo "  CC       : $CC"
echo "  PROJ_ROOT: $PROJ_ROOT"
echo ""

"$CC" "${CFLAGS[@]}" -T "${PROJ_ROOT}/link.ld" \
    -o "${PROJ_ROOT}/coremark.elf" \
    "${SRCS[@]}" \
    -lgcc

echo "[OK] Compiled: coremark.elf"

# ITCM: .init + .text sections (instructions)
"$OBJCOPY" -O verilog --verilog-data-width=4 \
    --only-section=.init \
    --only-section=.text \
    "${PROJ_ROOT}/coremark.elf" "${PROJ_ROOT}/itcm.hex"

# DTCM: .data + .sdata + .rodata (addresses adjusted so DTCM starts at hex offset 0)
# .sdata is the RISC-V small-data section — contains seed4_volatile, seed3_volatile, etc.
"$OBJCOPY" -O verilog --verilog-data-width=4 \
    --change-addresses -0x10000 \
    --only-section=.data \
    --only-section=.sdata \
    --only-section=.rodata \
    "${PROJ_ROOT}/coremark.elf" "${PROJ_ROOT}/dtcm.hex"

# Disassembly for debugging
"$OBJDUMP" -d "${PROJ_ROOT}/coremark.elf" > "${PROJ_ROOT}/coremark.asm"

echo "[OK] Generated: itcm.hex  dtcm.hex  coremark.asm"
echo ""
"$SIZE" "${PROJ_ROOT}/coremark.elf"
echo ""

# Sanity: check .text fits in 32KB ITCM
TEXT_BYTES=$("$SIZE" "${PROJ_ROOT}/coremark.elf" | awk 'NR==2 {print $1}')
if [ "${TEXT_BYTES}" -gt 32768 ] 2>/dev/null; then
    echo "[WARNING] .text (${TEXT_BYTES} bytes) exceeds 32KB ITCM!"
    echo "          Try -Os instead of -O2, or increase ITCM_DEPTH in defs.v"
else
    echo "[OK] .text = ${TEXT_BYTES} bytes (fits in 32KB ITCM)"
fi

echo ""
echo "=== Next step: simulate coremark_tb.v in Vivado ==="
