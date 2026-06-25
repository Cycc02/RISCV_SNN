
firmware.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	00500093          	li	ra,5
   4:	00a00113          	li	sp,10
   8:	002081b3          	add	gp,ra,sp
   c:	00118233          	add	tp,gp,ra
  10:	001202b3          	add	t0,tp,ra
  14:	00000033          	add	zero,zero,zero
  18:	00128333          	add	t1,t0,ra
  1c:	00100513          	li	a0,1
  20:	000105b7          	lui	a1,0x10
  24:	00a5a023          	sw	a0,0(a1) # 10000 <__bss_end>
  28:	0000006f          	j	28 <_start+0x28>
