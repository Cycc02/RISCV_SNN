#ifndef _ENV_PHYSICAL_SINGLE_CORE_H
#define _ENV_PHYSICAL_SINGLE_CORE_H

// Tell the test suite we are running standard 32-bit RISC-V
#define RVTEST_RV32U

// The official tests store the current Test Number in register x28 (t3)
#define TESTNUM x28

// --- THE BOOT CODE ---
// This replaces your crt0.S! It sets up the stack and starts the test.
#define RVTEST_CODE_BEGIN \
    .text; \
    .global _start; \
    _start: \
    auipc sp, 0x11; \
    mv sp, sp; 

// --- THE PASS CONDITION ---
// Write 1 to the 'tohost' symbol in DTCM, then loop forever.
#define RVTEST_PASS \
    la   a1, tohost; \
    li   a0, 1; \
    sw   a0, 0(a1); \
    1: j 1b;

// --- THE FAIL CONDITION ---
// Write the failing test number to 'tohost', then loop forever.
#define RVTEST_FAIL \
    la   a1, tohost; \
    sw   TESTNUM, 0(a1); \
    1: j 1b;

#define RVTEST_CODE_END

// Reserve the first word of .data as the tohost flag (testbench monitors this word).
// All test data arrays are placed after tohost.
#define RVTEST_DATA_BEGIN \
    .data; \
    .align 4; \
    .global tohost; \
    tohost: .word 0;

#define RVTEST_DATA_END

#endif
