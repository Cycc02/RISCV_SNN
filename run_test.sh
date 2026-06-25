#!/bin/bash

TEST_DIR="/mnt/c/Users/Administrator/Documents/FYP_Docs/RISCV_SNN/riscv_test/isa/rv32ui"
SIM_DIR="/mnt/c/Users/Administrator/Documents/FYP_Docs/RISCV_SNN/RISCV_SNN.sim/sim_1/behav/xsim"

echo "=========================================="
echo "🚀 STARTING RISC-V AUTOMATED TEST SUITE"
echo "=========================================="

for FILE_PATH in "$TEST_DIR"/*.S; do

	if [ ! -f "$FILE_PATH" ]; then
		echo "[ERROR] No .S files found in $TEST_DIR"
		break
	fi

	FILE=$(basename "$FILE_PATH")

	TEST="${FILE%.S}"
	cp "$FILE_PATH" .

	./build_rv_test.sh "$TEST" 

	if [ $? -ne 0 ]; then
		echo -e "$TEST: \tCOMPILATION FAILED"
		rm -f "$FILE"
		continue
	fi

	cd "$SIM_DIR" || exit

	cmd.exe /c "simulate.bat" > /dev/null 2>&1

	if grep -q "\[PASS\]" simulate.log; then
		echo -e "$TEST: \tPASS"
	elif grep -q "\[FAIL\]" simulate.log; then
		FAIL_MSG=$(grep "\[FAIL\]" simulate.log | head -n 1)
		echo -e "$TEST: \t$FAIL_MSG"
	else
		echo -e " $TEST: \tUNKNOWN (Check Waveform)"
	fi

	cd - > /dev/null

	rm -f "$FILE"

done

echo "=========================================="
echo "🏁 TEST SUITE COMPLETE"
echo "=========================================="

