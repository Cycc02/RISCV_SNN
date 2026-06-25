OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
  ITCM (rx) : ORIGIN = 0x00000000, LENGTH = 32K
  DTCM (rw) : ORIGIN = 0x00010000, LENGTH = 16K
}

SECTIONS
{
  .text : {
    *(.init)
    *(.text*)
  } > ITCM

  .data : {
    *(.data*)
    *(.sdata*)
    *(.rodata*)
  } > DTCM

  .bss : {
    __bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(COMMON)
    __bss_end = .;
  } > DTCM

  __stack_top = ORIGIN(DTCM) + LENGTH(DTCM);
}



