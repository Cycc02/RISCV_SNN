.section .init
.global _start

_start:
    /* PC=0x0000 is skipped by fetch_stage on the first cycle after reset
     * (NBA/combinatorial scheduling in xsim causes the ITCM to output the
     * instruction at PC+4 instead of PC=0 on the very first fetch).
     * This sacrificial NOP absorbs the skip so all real instructions follow. */
    nop

    /* Stack pointer — use absolute lui+addi (not pc-relative auipc)
     * so we can safely insert a nop between the two without breaking
     * %pcrel_lo relocation pairing. The nop lets the lui result
     * propagate through the pipeline before the addi reads sp. */
    lui  sp, %hi(__stack_top)
    nop
    addi sp, sp, %lo(__stack_top)

    /* BSS start — same pattern */
    lui  t0, %hi(__bss_start)
    nop
    addi t0, t0, %lo(__bss_start)

    /* BSS end */
    lui  t1, %hi(__bss_end)
    nop
    addi t1, t1, %lo(__bss_end)

    beq t0, t1, 2f

1:
    sw   zero, 0(t0)
    addi t0, t0, 4
    bltu t0, t1, 1b

2:
    /* Point mtvec at end_loop so any trap (ebreak, ecall, misalign) halts
     * cleanly there instead of wrapping back to _start and looping forever.
     * Raw encoding of "csrw mtvec, t0" (CSR 0x305, rs1=x5, CSRRW):
     *   [31:20]=0x305 [19:15]=00101 [14:12]=001 [11:7]=00000 [6:0]=1110011 */
    la   t0, end_loop
    nop
    nop
    .word 0x30529073

    call main

end_loop:
    j end_loop
