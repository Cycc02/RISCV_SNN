
/mnt/c/Users/Administrator/Documents/FYP_Docs/RISCV_SNN/snn_e2e.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	00000013          	nop
   4:	00014137          	lui	sp,0x14
   8:	00000013          	nop
   c:	00010113          	mv	sp,sp
  10:	000102b7          	lui	t0,0x10
  14:	00000013          	nop
  18:	19428293          	addi	t0,t0,404 # 10194 <__bss_end>
  1c:	00010337          	lui	t1,0x10
  20:	00000013          	nop
  24:	19430313          	addi	t1,t1,404 # 10194 <__bss_end>
  28:	00628863          	beq	t0,t1,38 <_start+0x38>
  2c:	0002a023          	sw	zero,0(t0)
  30:	00428293          	addi	t0,t0,4
  34:	fe62ece3          	bltu	t0,t1,2c <_start+0x2c>
  38:	00000297          	auipc	t0,0x0
  3c:	01828293          	addi	t0,t0,24 # 50 <end_loop>
  40:	00000013          	nop
  44:	00000013          	nop
  48:	30529073          	.word	0x30529073
  4c:	10c000ef          	jal	158 <main>

00000050 <end_loop>:
  50:	0000006f          	j	50 <end_loop>

00000054 <uart_put_hex32>:
  54:	000107b7          	lui	a5,0x10
  58:	03000713          	li	a4,48
  5c:	00078793          	mv	a5,a5
  60:	400006b7          	lui	a3,0x40000
  64:	00178793          	addi	a5,a5,1 # 10001 <__modsi3+0xfaf5>
  68:	00e6a023          	sw	a4,0(a3) # 40000000 <__stack_top+0x3ffec000>
  6c:	0007c703          	lbu	a4,0(a5)
  70:	fe071ae3          	bnez	a4,64 <uart_put_hex32+0x10>
  74:	01c00713          	li	a4,28
  78:	00900893          	li	a7,9
  7c:	40000837          	lui	a6,0x40000
  80:	ffc00593          	li	a1,-4
  84:	00e557b3          	srl	a5,a0,a4
  88:	00f7f613          	andi	a2,a5,15
  8c:	ffc70713          	addi	a4,a4,-4
  90:	03760693          	addi	a3,a2,55
  94:	00c8e463          	bltu	a7,a2,9c <uart_put_hex32+0x48>
  98:	03060693          	addi	a3,a2,48
  9c:	00d82023          	sw	a3,0(a6) # 40000000 <__stack_top+0x3ffec000>
  a0:	feb712e3          	bne	a4,a1,84 <uart_put_hex32+0x30>
  a4:	00008067          	ret

000000a8 <uart_put_dec.part.0>:
  a8:	0a050663          	beqz	a0,154 <uart_put_dec.part.0+0xac>
  ac:	fd010113          	addi	sp,sp,-48 # 13fd0 <__bss_end+0x3e3c>
  b0:	02812423          	sw	s0,40(sp)
  b4:	03212023          	sw	s2,32(sp)
  b8:	01312e23          	sw	s3,28(sp)
  bc:	01512a23          	sw	s5,20(sp)
  c0:	02112623          	sw	ra,44(sp)
  c4:	02912223          	sw	s1,36(sp)
  c8:	01412c23          	sw	s4,24(sp)
  cc:	00050413          	mv	s0,a0
  d0:	00000913          	li	s2,0
  d4:	00410993          	addi	s3,sp,4
  d8:	00900a93          	li	s5,9
  dc:	00a00593          	li	a1,10
  e0:	00040513          	mv	a0,s0
  e4:	3f4000ef          	jal	4d8 <__umodsi3>
  e8:	00090493          	mv	s1,s2
  ec:	00190913          	addi	s2,s2,1
  f0:	03050793          	addi	a5,a0,48
  f4:	01298a33          	add	s4,s3,s2
  f8:	00040513          	mv	a0,s0
  fc:	fefa0fa3          	sb	a5,-1(s4)
 100:	00a00593          	li	a1,10
 104:	00040a13          	mv	s4,s0
 108:	388000ef          	jal	490 <__hidden___udivsi3>
 10c:	00050413          	mv	s0,a0
 110:	fd4ae6e3          	bltu	s5,s4,dc <uart_put_dec.part.0+0x34>
 114:	009987b3          	add	a5,s3,s1
 118:	40000637          	lui	a2,0x40000
 11c:	0007c683          	lbu	a3,0(a5)
 120:	00078713          	mv	a4,a5
 124:	fff78793          	addi	a5,a5,-1
 128:	00d62023          	sw	a3,0(a2) # 40000000 <__stack_top+0x3ffec000>
 12c:	fee998e3          	bne	s3,a4,11c <uart_put_dec.part.0+0x74>
 130:	02c12083          	lw	ra,44(sp)
 134:	02812403          	lw	s0,40(sp)
 138:	02412483          	lw	s1,36(sp)
 13c:	02012903          	lw	s2,32(sp)
 140:	01c12983          	lw	s3,28(sp)
 144:	01812a03          	lw	s4,24(sp)
 148:	01412a83          	lw	s5,20(sp)
 14c:	03010113          	addi	sp,sp,48
 150:	00008067          	ret
 154:	00008067          	ret

00000158 <main>:
 158:	fd010113          	addi	sp,sp,-48
 15c:	02912223          	sw	s1,36(sp)
 160:	13000493          	li	s1,304
 164:	000107b7          	lui	a5,0x10
 168:	02112623          	sw	ra,44(sp)
 16c:	02812423          	sw	s0,40(sp)
 170:	03212023          	sw	s2,32(sp)
 174:	01312e23          	sw	s3,28(sp)
 178:	01412c23          	sw	s4,24(sp)
 17c:	01512a23          	sw	s5,20(sp)
 180:	01612823          	sw	s6,16(sp)
 184:	0024d493          	srli	s1,s1,0x2
 188:	00a00713          	li	a4,10
 18c:	00878793          	addi	a5,a5,8 # 10008 <__modsi3+0xfafc>
 190:	400006b7          	lui	a3,0x40000
 194:	00178793          	addi	a5,a5,1
 198:	00e6a023          	sw	a4,0(a3) # 40000000 <__stack_top+0x3ffec000>
 19c:	0007c703          	lbu	a4,0(a5)
 1a0:	fe071ae3          	bnez	a4,194 <main+0x3c>
 1a4:	000107b7          	lui	a5,0x10
 1a8:	04900713          	li	a4,73
 1ac:	02878793          	addi	a5,a5,40 # 10028 <__modsi3+0xfb1c>
 1b0:	400006b7          	lui	a3,0x40000
 1b4:	00178793          	addi	a5,a5,1
 1b8:	00e6a023          	sw	a4,0(a3) # 40000000 <__stack_top+0x3ffec000>
 1bc:	0007c703          	lbu	a4,0(a5)
 1c0:	fe071ae3          	bnez	a4,1b4 <main+0x5c>
 1c4:	00048513          	mv	a0,s1
 1c8:	e8dff0ef          	jal	54 <uart_put_hex32>
 1cc:	000107b7          	lui	a5,0x10
 1d0:	00a00713          	li	a4,10
 1d4:	04478793          	addi	a5,a5,68 # 10044 <__modsi3+0xfb38>
 1d8:	40000437          	lui	s0,0x40000
 1dc:	00178793          	addi	a5,a5,1
 1e0:	00e42023          	sw	a4,0(s0) # 40000000 <__stack_top+0x3ffec000>
 1e4:	0007c703          	lbu	a4,0(a5)
 1e8:	fe071ae3          	bnez	a4,1dc <main+0x84>
 1ec:	00300513          	li	a0,3
 1f0:	eb9ff0ef          	jal	a8 <uart_put_dec.part.0>
 1f4:	00a00793          	li	a5,10
 1f8:	00f42023          	sw	a5,0(s0)
 1fc:	c0002973          	rdcycle	s2
 200:	bc049073          	csrw	0xbc0,s1
 204:	00100793          	li	a5,1
 208:	bc279073          	csrw	0xbc2,a5
 20c:	00012623          	sw	zero,12(sp)
 210:	bc202473          	csrr	s0,0xbc2
 214:	04040663          	beqz	s0,260 <main+0x108>
 218:	9e378637          	lui	a2,0x9e378
 21c:	00000693          	li	a3,0
 220:	00000413          	li	s0,0
 224:	9b960613          	addi	a2,a2,-1607 # 9e3779b9 <__stack_top+0x9e3639b9>
 228:	00c12703          	lw	a4,12(sp)
 22c:	00d74733          	xor	a4,a4,a3
 230:	00d71793          	slli	a5,a4,0xd
 234:	00e7c7b3          	xor	a5,a5,a4
 238:	0117d713          	srli	a4,a5,0x11
 23c:	00f74733          	xor	a4,a4,a5
 240:	00571793          	slli	a5,a4,0x5
 244:	00e7c7b3          	xor	a5,a5,a4
 248:	008787b3          	add	a5,a5,s0
 24c:	00f12623          	sw	a5,12(sp)
 250:	00140413          	addi	s0,s0,1
 254:	bc2027f3          	csrr	a5,0xbc2
 258:	00c686b3          	add	a3,a3,a2
 25c:	fc0796e3          	bnez	a5,228 <main+0xd0>
 260:	c00029f3          	rdcycle	s3
 264:	bc3027f3          	csrr	a5,0xbc3
 268:	3ff7f513          	andi	a0,a5,1023
 26c:	bc402a73          	csrr	s4,0xbc4
 270:	bc502af3          	csrr	s5,0xbc5
 274:	0017f793          	andi	a5,a5,1
 278:	00000493          	li	s1,0
 27c:	02079463          	bnez	a5,2a4 <main+0x14c>
 280:	00a00693          	li	a3,10
 284:	00100713          	li	a4,1
 288:	0080006f          	j	290 <main+0x138>
 28c:	00079c63          	bnez	a5,2a4 <main+0x14c>
 290:	00148493          	addi	s1,s1,1
 294:	009717b3          	sll	a5,a4,s1
 298:	00a7f7b3          	and	a5,a5,a0
 29c:	fed498e3          	bne	s1,a3,28c <main+0x134>
 2a0:	fff00493          	li	s1,-1
 2a4:	000107b7          	lui	a5,0x10
 2a8:	00a00713          	li	a4,10
 2ac:	05478793          	addi	a5,a5,84 # 10054 <__modsi3+0xfb48>
 2b0:	400006b7          	lui	a3,0x40000
 2b4:	00178793          	addi	a5,a5,1
 2b8:	00e6a023          	sw	a4,0(a3) # 40000000 <__stack_top+0x3ffec000>
 2bc:	0007c703          	lbu	a4,0(a5)
 2c0:	fe071ae3          	bnez	a4,2b4 <main+0x15c>
 2c4:	000107b7          	lui	a5,0x10
 2c8:	04f00713          	li	a4,79
 2cc:	06c78793          	addi	a5,a5,108 # 1006c <__modsi3+0xfb60>
 2d0:	400006b7          	lui	a3,0x40000
 2d4:	00178793          	addi	a5,a5,1
 2d8:	00e6a023          	sw	a4,0(a3) # 40000000 <__stack_top+0x3ffec000>
 2dc:	0007c703          	lbu	a4,0(a5)
 2e0:	fe071ae3          	bnez	a4,2d4 <main+0x17c>
 2e4:	d71ff0ef          	jal	54 <uart_put_hex32>
 2e8:	000107b7          	lui	a5,0x10
 2ec:	00a00713          	li	a4,10
 2f0:	08478793          	addi	a5,a5,132 # 10084 <__modsi3+0xfb78>
 2f4:	40000b37          	lui	s6,0x40000
 2f8:	00178793          	addi	a5,a5,1
 2fc:	00eb2023          	sw	a4,0(s6) # 40000000 <__stack_top+0x3ffec000>
 300:	0007c703          	lbu	a4,0(a5)
 304:	fe071ae3          	bnez	a4,2f8 <main+0x1a0>
 308:	000a8513          	mv	a0,s5
 30c:	d49ff0ef          	jal	54 <uart_put_hex32>
 310:	02000793          	li	a5,32
 314:	00fb2023          	sw	a5,0(s6)
 318:	000a0513          	mv	a0,s4
 31c:	d39ff0ef          	jal	54 <uart_put_hex32>
 320:	000107b7          	lui	a5,0x10
 324:	00a00713          	li	a4,10
 328:	09c78793          	addi	a5,a5,156 # 1009c <__modsi3+0xfb90>
 32c:	400006b7          	lui	a3,0x40000
 330:	00178793          	addi	a5,a5,1
 334:	00e6a023          	sw	a4,0(a3) # 40000000 <__stack_top+0x3ffec000>
 338:	0007c703          	lbu	a4,0(a5)
 33c:	fe071ae3          	bnez	a4,330 <main+0x1d8>
 340:	fff00793          	li	a5,-1
 344:	10f48463          	beq	s1,a5,44c <main+0x2f4>
 348:	0e048c63          	beqz	s1,440 <main+0x2e8>
 34c:	00048513          	mv	a0,s1
 350:	d59ff0ef          	jal	a8 <uart_put_dec.part.0>
 354:	000107b7          	lui	a5,0x10
 358:	00a00713          	li	a4,10
 35c:	0b878793          	addi	a5,a5,184 # 100b8 <__modsi3+0xfbac>
 360:	400006b7          	lui	a3,0x40000
 364:	00178793          	addi	a5,a5,1
 368:	00e6a023          	sw	a4,0(a3) # 40000000 <__stack_top+0x3ffec000>
 36c:	0007c703          	lbu	a4,0(a5)
 370:	fe071ae3          	bnez	a4,364 <main+0x20c>
 374:	000107b7          	lui	a5,0x10
 378:	05300713          	li	a4,83
 37c:	0d478793          	addi	a5,a5,212 # 100d4 <__modsi3+0xfbc8>
 380:	400006b7          	lui	a3,0x40000
 384:	00178793          	addi	a5,a5,1
 388:	00e6a023          	sw	a4,0(a3) # 40000000 <__stack_top+0x3ffec000>
 38c:	0007c703          	lbu	a4,0(a5)
 390:	fe071ae3          	bnez	a4,384 <main+0x22c>
 394:	41298533          	sub	a0,s3,s2
 398:	0f298263          	beq	s3,s2,47c <main+0x324>
 39c:	d0dff0ef          	jal	a8 <uart_put_dec.part.0>
 3a0:	000107b7          	lui	a5,0x10
 3a4:	00a00713          	li	a4,10
 3a8:	0e878793          	addi	a5,a5,232 # 100e8 <__modsi3+0xfbdc>
 3ac:	400006b7          	lui	a3,0x40000
 3b0:	00178793          	addi	a5,a5,1
 3b4:	00e6a023          	sw	a4,0(a3) # 40000000 <__stack_top+0x3ffec000>
 3b8:	0007c703          	lbu	a4,0(a5)
 3bc:	fe071ae3          	bnez	a4,3b0 <main+0x258>
 3c0:	0a040863          	beqz	s0,470 <main+0x318>
 3c4:	00040513          	mv	a0,s0
 3c8:	ce1ff0ef          	jal	a8 <uart_put_dec.part.0>
 3cc:	000107b7          	lui	a5,0x10
 3d0:	00a00713          	li	a4,10
 3d4:	10078793          	addi	a5,a5,256 # 10100 <__modsi3+0xfbf4>
 3d8:	400006b7          	lui	a3,0x40000
 3dc:	00178793          	addi	a5,a5,1
 3e0:	00e6a023          	sw	a4,0(a3) # 40000000 <__stack_top+0x3ffec000>
 3e4:	0007c703          	lbu	a4,0(a5)
 3e8:	fe071ae3          	bnez	a4,3dc <main+0x284>
 3ec:	00c12503          	lw	a0,12(sp)
 3f0:	c65ff0ef          	jal	54 <uart_put_hex32>
 3f4:	000107b7          	lui	a5,0x10
 3f8:	00a00713          	li	a4,10
 3fc:	11878793          	addi	a5,a5,280 # 10118 <__modsi3+0xfc0c>
 400:	400006b7          	lui	a3,0x40000
 404:	00178793          	addi	a5,a5,1
 408:	00e6a023          	sw	a4,0(a3) # 40000000 <__stack_top+0x3ffec000>
 40c:	0007c703          	lbu	a4,0(a5)
 410:	fe071ae3          	bnez	a4,404 <main+0x2ac>
 414:	02c12083          	lw	ra,44(sp)
 418:	02812403          	lw	s0,40(sp)
 41c:	02412483          	lw	s1,36(sp)
 420:	02012903          	lw	s2,32(sp)
 424:	01c12983          	lw	s3,28(sp)
 428:	01812a03          	lw	s4,24(sp)
 42c:	01412a83          	lw	s5,20(sp)
 430:	01012b03          	lw	s6,16(sp)
 434:	00000513          	li	a0,0
 438:	03010113          	addi	sp,sp,48
 43c:	00008067          	ret
 440:	03000793          	li	a5,48
 444:	00f6a023          	sw	a5,0(a3)
 448:	f0dff06f          	j	354 <main+0x1fc>
 44c:	000107b7          	lui	a5,0x10
 450:	02800713          	li	a4,40
 454:	0b078793          	addi	a5,a5,176 # 100b0 <__modsi3+0xfba4>
 458:	400006b7          	lui	a3,0x40000
 45c:	00178793          	addi	a5,a5,1
 460:	00e6a023          	sw	a4,0(a3) # 40000000 <__stack_top+0x3ffec000>
 464:	0007c703          	lbu	a4,0(a5)
 468:	fe071ae3          	bnez	a4,45c <main+0x304>
 46c:	ee9ff06f          	j	354 <main+0x1fc>
 470:	03000793          	li	a5,48
 474:	00f6a023          	sw	a5,0(a3)
 478:	f55ff06f          	j	3cc <main+0x274>
 47c:	03000793          	li	a5,48
 480:	00f6a023          	sw	a5,0(a3)
 484:	f1dff06f          	j	3a0 <main+0x248>

00000488 <__divsi3>:
 488:	06054063          	bltz	a0,4e8 <__umodsi3+0x10>
 48c:	0605c663          	bltz	a1,4f8 <__umodsi3+0x20>

00000490 <__hidden___udivsi3>:
 490:	00058613          	mv	a2,a1
 494:	00050593          	mv	a1,a0
 498:	fff00513          	li	a0,-1
 49c:	02060c63          	beqz	a2,4d4 <__hidden___udivsi3+0x44>
 4a0:	00100693          	li	a3,1
 4a4:	00b67a63          	bgeu	a2,a1,4b8 <__hidden___udivsi3+0x28>
 4a8:	00c05863          	blez	a2,4b8 <__hidden___udivsi3+0x28>
 4ac:	00161613          	slli	a2,a2,0x1
 4b0:	00169693          	slli	a3,a3,0x1
 4b4:	feb66ae3          	bltu	a2,a1,4a8 <__hidden___udivsi3+0x18>
 4b8:	00000513          	li	a0,0
 4bc:	00c5e663          	bltu	a1,a2,4c8 <__hidden___udivsi3+0x38>
 4c0:	40c585b3          	sub	a1,a1,a2
 4c4:	00d56533          	or	a0,a0,a3
 4c8:	0016d693          	srli	a3,a3,0x1
 4cc:	00165613          	srli	a2,a2,0x1
 4d0:	fe0696e3          	bnez	a3,4bc <__hidden___udivsi3+0x2c>
 4d4:	00008067          	ret

000004d8 <__umodsi3>:
 4d8:	00008293          	mv	t0,ra
 4dc:	fb5ff0ef          	jal	490 <__hidden___udivsi3>
 4e0:	00058513          	mv	a0,a1
 4e4:	00028067          	jr	t0
 4e8:	40a00533          	neg	a0,a0
 4ec:	00b04863          	bgtz	a1,4fc <__umodsi3+0x24>
 4f0:	40b005b3          	neg	a1,a1
 4f4:	f9dff06f          	j	490 <__hidden___udivsi3>
 4f8:	40b005b3          	neg	a1,a1
 4fc:	00008293          	mv	t0,ra
 500:	f91ff0ef          	jal	490 <__hidden___udivsi3>
 504:	40a00533          	neg	a0,a0
 508:	00028067          	jr	t0

0000050c <__modsi3>:
 50c:	00008293          	mv	t0,ra
 510:	0005ca63          	bltz	a1,524 <__modsi3+0x18>
 514:	00054c63          	bltz	a0,52c <__modsi3+0x20>
 518:	f79ff0ef          	jal	490 <__hidden___udivsi3>
 51c:	00058513          	mv	a0,a1
 520:	00028067          	jr	t0
 524:	40b005b3          	neg	a1,a1
 528:	fe0558e3          	bgez	a0,518 <__modsi3+0xc>
 52c:	40a00533          	neg	a0,a0
 530:	f61ff0ef          	jal	490 <__hidden___udivsi3>
 534:	40b00533          	neg	a0,a1
 538:	00028067          	jr	t0
