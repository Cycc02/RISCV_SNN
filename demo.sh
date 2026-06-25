#!/usr/bin/env bash
# demo.sh <MNIST_INDEX>
#   1. rebuild snn_e2e firmware with the chosen MNIST image
#   2. rebuild bitstream  (~10 min — hex baked at synth)
#   3. program FPGA + capture UART via ILA
#   4. decode and print "Predicted class: N"
#
# Run from Git Bash on Windows (uses wsl for the RISC-V cross-compiler and
# the host vivado.bat for the FPGA flow).
set -euo pipefail

if [ -z "${1:-}" ]; then
    echo "Usage: $0 <MNIST_INDEX>  (0..9999)"
    exit 1
fi
IDX="$1"

PROJ_WIN="C:/Users/Administrator/Documents/FYP_Docs/RISCV_SNN"
PROJ_WSL="/mnt/c/Users/Administrator/Documents/FYP_Docs/RISCV_SNN"
VIVADO="C:/AMDDesignTools/2025.2/Vivado/bin/vivado.bat"

cd "$PROJ_WIN"

echo "=== [1/4] Build firmware for MNIST index $IDX ==="
wsl bash -c "cd $PROJ_WSL && bash build_snn_e2e.sh $IDX"

echo "=== [2/4] Rebuild bitstream (~10 min) ==="
"$VIVADO" -mode batch -source quick_build.tcl > "quick_build_idx${IDX}.log" 2>&1
echo "    bitstream OK -> RISCV_SNN.runs/impl_1/riscv_top.bit"

echo "=== [3/4] Program FPGA + capture UART (~5 min) ==="
"$VIVADO" -mode batch -source program_and_capture.tcl > "program_and_capture_idx${IDX}.log" 2>&1

echo "=== [4/4] Decode result ==="
TRUE_LABEL=$(grep -oE "Label: [0-9]+" mnist_img.h | head -1 | awk '{print $2}')
echo "MNIST index : $IDX"
echo "True label  : $TRUE_LABEL"
echo "--- UART output ---"
wsl bash -c "cd $PROJ_WSL && python decode_uart_csv.py"
echo
echo "=== Archive ==="
mkdir -p "_runs/idx${IDX}"
cp RISCV_SNN.runs/impl_1/riscv_top.bit "_runs/idx${IDX}/"
cp RISCV_SNN.runs/impl_1/riscv_top.ltx "_runs/idx${IDX}/"
cp itcm.hex dtcm.hex mnist_img.h        "_runs/idx${IDX}/"
cp ila_uart_chars.csv ila_uart_chars.ila "_runs/idx${IDX}/"
echo "    saved to _runs/idx${IDX}/"
