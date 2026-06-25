
basic_test.elf:     file format elf32-littleriscv


Disassembly of section .text:

00010074 <_start>:
   10074:	00500093          	li	ra,5
   10078:	00a00113          	li	sp,10
   1007c:	002081b3          	add	gp,ra,sp
   10080:	00318213          	addi	tp,gp,3 # 1188b <__global_pointer$+0x3>

00010084 <end_loop>:
   10084:	0000006f          	j	10084 <end_loop>
