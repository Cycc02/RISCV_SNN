#!/bin/bash
# Build the SNN end-to-end firmware (snn_e2e.c).
# Generates itcm.hex + dtcm.hex consumed by snn_e2e_tb.v in xsim.
#
# Prerequisites:
#   - riscv64-unknown-elf-gcc with RV32I multilib
#   - python (for gen_mnist_header.py, only needed if mnist_img.h is missing)
#
# Usage (from project root):
#   bash build_snn_e2e.sh [MNIST_INDEX]

set -e
PROJ_ROOT="$(cd "$(dirname "$0")" && pwd)"

CC="${RISCV_CC:-riscv64-unknown-elf-gcc}"
OBJCOPY="${RISCV_OBJCOPY:-riscv64-unknown-elf-objcopy}"
OBJDUMP="${RISCV_OBJDUMP:-riscv64-unknown-elf-objdump}"
SIZE="${RISCV_SIZE:-riscv64-unknown-elf-size}"

# Pick a Python interpreter (Windows installs typically expose `py` or `python3`).
PY="${PYTHON:-}"
if [ -z "$PY" ]; then
    for cand in python python3 py; do
        if command -v "$cand" >/dev/null 2>&1; then PY="$cand"; break; fi
    done
fi
if [ -z "$PY" ]; then
    echo "[ERROR] No Python interpreter found. Set PYTHON=... or install python." >&2
    exit 1
fi

# Regenerate the MNIST header if a specific index is requested or the file is missing.
if [ -n "$1" ] || [ ! -f "${PROJ_ROOT}/mnist_img.h" ]; then
    "$PY" "${PROJ_ROOT}/gen_mnist_header.py" ${1:-}
    # Visualize the exact image being tested (ASCII art + mnist_preview.png).
    "$PY" "${PROJ_ROOT}/visualize_mnist.py" ${1:-} || true
fi

CFLAGS=(
    -march=rv32i_zicsr -mabi=ilp32
    -O2
    -ffreestanding -nostdlib
    "-I${PROJ_ROOT}"
)

"$CC" "${CFLAGS[@]}" -T "${PROJ_ROOT}/link.ld" \
    -o "${PROJ_ROOT}/snn_e2e.elf" \
    "${PROJ_ROOT}/crt0.S" \
    "${PROJ_ROOT}/snn_e2e.c" \
    -lgcc

echo "[OK] Compiled: snn_e2e.elf"

"$OBJCOPY" -O verilog --verilog-data-width=4 \
    --only-section=.init \
    --only-section=.text \
    "${PROJ_ROOT}/snn_e2e.elf" "${PROJ_ROOT}/itcm.hex"

"$OBJCOPY" -O verilog --verilog-data-width=4 \
    --change-addresses -0x10000 \
    --only-section=.data \
    --only-section=.sdata \
    --only-section=.rodata \
    "${PROJ_ROOT}/snn_e2e.elf" "${PROJ_ROOT}/dtcm.hex"

"$OBJDUMP" -d "${PROJ_ROOT}/snn_e2e.elf" > "${PROJ_ROOT}/snn_e2e.asm"
echo "[OK] Generated: itcm.hex  dtcm.hex  snn_e2e.asm"
"$SIZE" "${PROJ_ROOT}/snn_e2e.elf"
