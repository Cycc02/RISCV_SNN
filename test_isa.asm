
test_isa.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	00000013          	nop
   4:	00014137          	lui	sp,0x14
   8:	00000013          	nop
   c:	00010113          	mv	sp,sp
  10:	000102b7          	lui	t0,0x10
  14:	00000013          	nop
  18:	1b028293          	addi	t0,t0,432 # 101b0 <h>
  1c:	00010337          	lui	t1,0x10
  20:	00000013          	nop
  24:	1dc30313          	addi	t1,t1,476 # 101dc <__bss_end>
  28:	00628863          	beq	t0,t1,38 <_start+0x38>
  2c:	0002a023          	sw	zero,0(t0)
  30:	00428293          	addi	t0,t0,4
  34:	fe62ece3          	bltu	t0,t1,2c <_start+0x2c>
  38:	00000297          	auipc	t0,0x0
  3c:	01828293          	addi	t0,t0,24 # 50 <end_loop>
  40:	00000013          	nop
  44:	00000013          	nop
  48:	30529073          	.word	0x30529073
  4c:	12c000ef          	jal	178 <main>

00000050 <end_loop>:
  50:	0000006f          	j	50 <end_loop>

00000054 <puts1>:
  54:	00054683          	lbu	a3,0(a0)
  58:	02068663          	beqz	a3,84 <puts1+0x30>
  5c:	40000737          	lui	a4,0x40000
  60:	40000637          	lui	a2,0x40000
  64:	00470713          	addi	a4,a4,4 # 40000004 <__stack_top+0x3ffec004>
  68:	00150513          	addi	a0,a0,1
  6c:	00072783          	lw	a5,0(a4)
  70:	0017f793          	andi	a5,a5,1
  74:	fe079ce3          	bnez	a5,6c <puts1+0x18>
  78:	00d62023          	sw	a3,0(a2) # 40000000 <__stack_top+0x3ffec000>
  7c:	00054683          	lbu	a3,0(a0)
  80:	fe0694e3          	bnez	a3,68 <puts1+0x14>
  84:	00008067          	ret

00000088 <puthex>:
  88:	40000737          	lui	a4,0x40000
  8c:	01c00693          	li	a3,28
  90:	00900313          	li	t1,9
  94:	400008b7          	lui	a7,0x40000
  98:	00470713          	addi	a4,a4,4 # 40000004 <__stack_top+0x3ffec004>
  9c:	ffc00813          	li	a6,-4
  a0:	00d557b3          	srl	a5,a0,a3
  a4:	00f7f593          	andi	a1,a5,15
  a8:	05758613          	addi	a2,a1,87
  ac:	00b36463          	bltu	t1,a1,b4 <puthex+0x2c>
  b0:	03058613          	addi	a2,a1,48
  b4:	00072783          	lw	a5,0(a4)
  b8:	0017f793          	andi	a5,a5,1
  bc:	fe079ce3          	bnez	a5,b4 <puthex+0x2c>
  c0:	00c8a023          	sw	a2,0(a7) # 40000000 <__stack_top+0x3ffec000>
  c4:	ffc68693          	addi	a3,a3,-4
  c8:	fd069ce3          	bne	a3,a6,a0 <puthex+0x18>
  cc:	00008067          	ret

000000d0 <check>:
  d0:	ff010113          	addi	sp,sp,-16 # 13ff0 <__bss_end+0x3e14>
  d4:	00812423          	sw	s0,8(sp)
  d8:	00912223          	sw	s1,4(sp)
  dc:	00060413          	mv	s0,a2
  e0:	00058493          	mv	s1,a1
  e4:	00112623          	sw	ra,12(sp)
  e8:	f6dff0ef          	jal	54 <puts1>
  ec:	06848863          	beq	s1,s0,15c <check+0x8c>
  f0:	00010537          	lui	a0,0x10
  f4:	01450513          	addi	a0,a0,20 # 10014 <uh+0x10>
  f8:	f5dff0ef          	jal	54 <puts1>
  fc:	00048513          	mv	a0,s1
 100:	f89ff0ef          	jal	88 <puthex>
 104:	00010537          	lui	a0,0x10
 108:	02050513          	addi	a0,a0,32 # 10020 <uh+0x1c>
 10c:	f49ff0ef          	jal	54 <puts1>
 110:	00040513          	mv	a0,s0
 114:	f75ff0ef          	jal	88 <puthex>
 118:	40000737          	lui	a4,0x40000
 11c:	00470713          	addi	a4,a4,4 # 40000004 <__stack_top+0x3ffec004>
 120:	00072783          	lw	a5,0(a4)
 124:	0017f793          	andi	a5,a5,1
 128:	fe079ce3          	bnez	a5,120 <check+0x50>
 12c:	400007b7          	lui	a5,0x40000
 130:	00a00713          	li	a4,10
 134:	00e7a023          	sw	a4,0(a5) # 40000000 <__stack_top+0x3ffec000>
 138:	00010737          	lui	a4,0x10
 13c:	1d872783          	lw	a5,472(a4) # 101d8 <fails>
 140:	00c12083          	lw	ra,12(sp)
 144:	00812403          	lw	s0,8(sp)
 148:	00178793          	addi	a5,a5,1
 14c:	1cf72c23          	sw	a5,472(a4)
 150:	00412483          	lw	s1,4(sp)
 154:	01010113          	addi	sp,sp,16
 158:	00008067          	ret
 15c:	00812403          	lw	s0,8(sp)
 160:	00c12083          	lw	ra,12(sp)
 164:	00412483          	lw	s1,4(sp)
 168:	00010537          	lui	a0,0x10
 16c:	00850513          	addi	a0,a0,8 # 10008 <uh+0x4>
 170:	01010113          	addi	sp,sp,16
 174:	ee1ff06f          	j	54 <puts1>

00000178 <main>:
 178:	fd010113          	addi	sp,sp,-48
 17c:	02812423          	sw	s0,40(sp)
 180:	fffff637          	lui	a2,0xfffff
 184:	00010437          	lui	s0,0x10
 188:	02112623          	sw	ra,44(sp)
 18c:	1b040413          	addi	s0,s0,432 # 101b0 <h>
 190:	02912223          	sw	s1,36(sp)
 194:	03212023          	sw	s2,32(sp)
 198:	01312e23          	sw	s3,28(sp)
 19c:	dcc60613          	addi	a2,a2,-564 # ffffedcc <__stack_top+0xfffeadcc>
 1a0:	000054b7          	lui	s1,0x5
 1a4:	00c41023          	sh	a2,0(s0)
 1a8:	67848493          	addi	s1,s1,1656 # 5678 <__mulsi3+0x517c>
 1ac:	00941123          	sh	s1,2(s0)
 1b0:	00045583          	lhu	a1,0(s0)
 1b4:	00010537          	lui	a0,0x10
 1b8:	06050513          	addi	a0,a0,96 # 10060 <uh+0x5c>
 1bc:	01059593          	slli	a1,a1,0x10
 1c0:	4105d593          	srai	a1,a1,0x10
 1c4:	f0dff0ef          	jal	d0 <check>
 1c8:	00245583          	lhu	a1,2(s0)
 1cc:	00010537          	lui	a0,0x10
 1d0:	00048613          	mv	a2,s1
 1d4:	01059593          	slli	a1,a1,0x10
 1d8:	4105d593          	srai	a1,a1,0x10
 1dc:	07050513          	addi	a0,a0,112 # 10070 <uh+0x6c>
 1e0:	ef1ff0ef          	jal	d0 <check>
 1e4:	000107b7          	lui	a5,0x10
 1e8:	0047a903          	lw	s2,4(a5) # 10004 <uh>
 1ec:	0000f637          	lui	a2,0xf
 1f0:	00010537          	lui	a0,0x10
 1f4:	00095583          	lhu	a1,0(s2)
 1f8:	dcc60613          	addi	a2,a2,-564 # edcc <__mulsi3+0xe8d0>
 1fc:	08050513          	addi	a0,a0,128 # 10080 <uh+0x7c>
 200:	ed1ff0ef          	jal	d0 <check>
 204:	00295583          	lhu	a1,2(s2)
 208:	00010537          	lui	a0,0x10
 20c:	00048613          	mv	a2,s1
 210:	09050513          	addi	a0,a0,144 # 10090 <uh+0x8c>
 214:	ebdff0ef          	jal	d0 <check>
 218:	11223937          	lui	s2,0x11223
 21c:	34490913          	addi	s2,s2,836 # 11223344 <__stack_top+0x1120f344>
 220:	ffffc7b7          	lui	a5,0xffffc
 224:	01242823          	sw	s2,16(s0)
 228:	eef78793          	addi	a5,a5,-273 # ffffbeef <__stack_top+0xfffe7eef>
 22c:	00f41823          	sh	a5,16(s0)
 230:	01042583          	lw	a1,16(s0)
 234:	1122c637          	lui	a2,0x1122c
 238:	00010537          	lui	a0,0x10
 23c:	eef60613          	addi	a2,a2,-273 # 1122beef <__stack_top+0x11217eef>
 240:	0a050513          	addi	a0,a0,160 # 100a0 <uh+0x9c>
 244:	e8dff0ef          	jal	d0 <check>
 248:	ffffe7b7          	lui	a5,0xffffe
 24c:	01242823          	sw	s2,16(s0)
 250:	ead78793          	addi	a5,a5,-339 # ffffdead <__stack_top+0xfffe9ead>
 254:	00f41923          	sh	a5,18(s0)
 258:	01042583          	lw	a1,16(s0)
 25c:	dead3637          	lui	a2,0xdead3
 260:	00010537          	lui	a0,0x10
 264:	34460613          	addi	a2,a2,836 # dead3344 <__stack_top+0xdeabf344>
 268:	0b050513          	addi	a0,a0,176 # 100b0 <uh+0xac>
 26c:	e65ff0ef          	jal	d0 <check>
 270:	000104b7          	lui	s1,0x10
 274:	1d048493          	addi	s1,s1,464 # 101d0 <b>
 278:	f8000793          	li	a5,-128
 27c:	00f48023          	sb	a5,0(s1)
 280:	07f00793          	li	a5,127
 284:	00f480a3          	sb	a5,1(s1)
 288:	fff00793          	li	a5,-1
 28c:	00f48123          	sb	a5,2(s1)
 290:	00100793          	li	a5,1
 294:	00f481a3          	sb	a5,3(s1)
 298:	0004c583          	lbu	a1,0(s1)
 29c:	00010537          	lui	a0,0x10
 2a0:	f8000613          	li	a2,-128
 2a4:	01859593          	slli	a1,a1,0x18
 2a8:	4185d593          	srai	a1,a1,0x18
 2ac:	0c050513          	addi	a0,a0,192 # 100c0 <uh+0xbc>
 2b0:	e21ff0ef          	jal	d0 <check>
 2b4:	0014c583          	lbu	a1,1(s1)
 2b8:	00010537          	lui	a0,0x10
 2bc:	07f00613          	li	a2,127
 2c0:	01859593          	slli	a1,a1,0x18
 2c4:	4185d593          	srai	a1,a1,0x18
 2c8:	0d050513          	addi	a0,a0,208 # 100d0 <uh+0xcc>
 2cc:	e05ff0ef          	jal	d0 <check>
 2d0:	0024c583          	lbu	a1,2(s1)
 2d4:	00010537          	lui	a0,0x10
 2d8:	fff00613          	li	a2,-1
 2dc:	01859593          	slli	a1,a1,0x18
 2e0:	4185d593          	srai	a1,a1,0x18
 2e4:	0e050513          	addi	a0,a0,224 # 100e0 <uh+0xdc>
 2e8:	de9ff0ef          	jal	d0 <check>
 2ec:	0034c583          	lbu	a1,3(s1)
 2f0:	00010537          	lui	a0,0x10
 2f4:	00100613          	li	a2,1
 2f8:	01859593          	slli	a1,a1,0x18
 2fc:	4185d593          	srai	a1,a1,0x18
 300:	0f050513          	addi	a0,a0,240 # 100f0 <uh+0xec>
 304:	dcdff0ef          	jal	d0 <check>
 308:	000107b7          	lui	a5,0x10
 30c:	0007a983          	lw	s3,0(a5) # 10000 <ub>
 310:	00010537          	lui	a0,0x10
 314:	08000613          	li	a2,128
 318:	0009c583          	lbu	a1,0(s3)
 31c:	10050513          	addi	a0,a0,256 # 10100 <uh+0xfc>
 320:	db1ff0ef          	jal	d0 <check>
 324:	0029c583          	lbu	a1,2(s3)
 328:	00010537          	lui	a0,0x10
 32c:	0ff00613          	li	a2,255
 330:	11050513          	addi	a0,a0,272 # 10110 <uh+0x10c>
 334:	d9dff0ef          	jal	d0 <check>
 338:	faa00793          	li	a5,-86
 33c:	01242a23          	sw	s2,20(s0)
 340:	00f40b23          	sb	a5,22(s0)
 344:	01442583          	lw	a1,20(s0)
 348:	11aa3637          	lui	a2,0x11aa3
 34c:	00010537          	lui	a0,0x10
 350:	34460613          	addi	a2,a2,836 # 11aa3344 <__stack_top+0x11a8f344>
 354:	12050513          	addi	a0,a0,288 # 10120 <uh+0x11c>
 358:	d79ff0ef          	jal	d0 <check>
 35c:	00008637          	lui	a2,0x8
 360:	bcd60613          	addi	a2,a2,-1075 # 7bcd <__mulsi3+0x76d1>
 364:	00c41423          	sh	a2,8(s0)
 368:	00845583          	lhu	a1,8(s0)
 36c:	00010537          	lui	a0,0x10
 370:	13050513          	addi	a0,a0,304 # 10130 <uh+0x12c>
 374:	01059593          	slli	a1,a1,0x10
 378:	4105d593          	srai	a1,a1,0x10
 37c:	d55ff0ef          	jal	d0 <check>
 380:	f9a00793          	li	a5,-102
 384:	00f482a3          	sb	a5,5(s1)
 388:	0054c583          	lbu	a1,5(s1)
 38c:	00010537          	lui	a0,0x10
 390:	f9a00613          	li	a2,-102
 394:	01859593          	slli	a1,a1,0x18
 398:	4185d593          	srai	a1,a1,0x18
 39c:	14050513          	addi	a0,a0,320 # 10140 <uh+0x13c>
 3a0:	d31ff0ef          	jal	d0 <check>
 3a4:	000017b7          	lui	a5,0x1
 3a8:	b2e00713          	li	a4,-1234
 3ac:	00e12223          	sw	a4,4(sp)
 3b0:	62e78793          	addi	a5,a5,1582 # 162e <__mulsi3+0x1132>
 3b4:	00f12423          	sw	a5,8(sp)
 3b8:	fce00793          	li	a5,-50
 3bc:	00f11023          	sh	a5,0(sp)
 3c0:	12c00793          	li	a5,300
 3c4:	00f11123          	sh	a5,2(sp)
 3c8:	00412503          	lw	a0,4(sp)
 3cc:	00812583          	lw	a1,8(sp)
 3d0:	00000793          	li	a5,0
 3d4:	00000413          	li	s0,0
 3d8:	02000613          	li	a2,32
 3dc:	40f5d733          	sra	a4,a1,a5
 3e0:	00177713          	andi	a4,a4,1
 3e4:	00f516b3          	sll	a3,a0,a5
 3e8:	00178793          	addi	a5,a5,1
 3ec:	00070463          	beqz	a4,3f4 <main+0x27c>
 3f0:	00d40433          	add	s0,s0,a3
 3f4:	fec794e3          	bne	a5,a2,3dc <main+0x264>
 3f8:	00412503          	lw	a0,4(sp)
 3fc:	00812583          	lw	a1,8(sp)
 400:	0fc000ef          	jal	4fc <__mulsi3>
 404:	00050593          	mv	a1,a0
 408:	00010537          	lui	a0,0x10
 40c:	00040613          	mv	a2,s0
 410:	15050513          	addi	a0,a0,336 # 10150 <uh+0x14c>
 414:	cbdff0ef          	jal	d0 <check>
 418:	00015503          	lhu	a0,0(sp)
 41c:	00215583          	lhu	a1,2(sp)
 420:	01051513          	slli	a0,a0,0x10
 424:	01059593          	slli	a1,a1,0x10
 428:	4105d593          	srai	a1,a1,0x10
 42c:	41055513          	srai	a0,a0,0x10
 430:	0cc000ef          	jal	4fc <__mulsi3>
 434:	00050593          	mv	a1,a0
 438:	ffffc637          	lui	a2,0xffffc
 43c:	00010537          	lui	a0,0x10
 440:	56860613          	addi	a2,a2,1384 # ffffc568 <__stack_top+0xfffe8568>
 444:	16050513          	addi	a0,a0,352 # 10160 <uh+0x15c>
 448:	c89ff0ef          	jal	d0 <check>
 44c:	ff800793          	li	a5,-8
 450:	00f12623          	sw	a5,12(sp)
 454:	00c12583          	lw	a1,12(sp)
 458:	00010537          	lui	a0,0x10
 45c:	ffe00613          	li	a2,-2
 460:	4025d593          	srai	a1,a1,0x2
 464:	17050513          	addi	a0,a0,368 # 10170 <uh+0x16c>
 468:	c69ff0ef          	jal	d0 <check>
 46c:	00c12583          	lw	a1,12(sp)
 470:	40000637          	lui	a2,0x40000
 474:	00010537          	lui	a0,0x10
 478:	ffd60613          	addi	a2,a2,-3 # 3ffffffd <__stack_top+0x3ffebffd>
 47c:	0025d593          	srli	a1,a1,0x2
 480:	18050513          	addi	a0,a0,384 # 10180 <uh+0x17c>
 484:	c4dff0ef          	jal	d0 <check>
 488:	00c12583          	lw	a1,12(sp)
 48c:	00010537          	lui	a0,0x10
 490:	00100613          	li	a2,1
 494:	0015a593          	slti	a1,a1,1
 498:	19050513          	addi	a0,a0,400 # 10190 <uh+0x18c>
 49c:	c35ff0ef          	jal	d0 <check>
 4a0:	00c12583          	lw	a1,12(sp)
 4a4:	00010537          	lui	a0,0x10
 4a8:	00000613          	li	a2,0
 4ac:	0015b593          	seqz	a1,a1
 4b0:	1a050513          	addi	a0,a0,416 # 101a0 <uh+0x19c>
 4b4:	c1dff0ef          	jal	d0 <check>
 4b8:	000107b7          	lui	a5,0x10
 4bc:	1d87a783          	lw	a5,472(a5) # 101d8 <fails>
 4c0:	02078863          	beqz	a5,4f0 <main+0x378>
 4c4:	00010537          	lui	a0,0x10
 4c8:	02850513          	addi	a0,a0,40 # 10028 <uh+0x24>
 4cc:	b89ff0ef          	jal	54 <puts1>
 4d0:	02c12083          	lw	ra,44(sp)
 4d4:	02812403          	lw	s0,40(sp)
 4d8:	02412483          	lw	s1,36(sp)
 4dc:	02012903          	lw	s2,32(sp)
 4e0:	01c12983          	lw	s3,28(sp)
 4e4:	00000513          	li	a0,0
 4e8:	03010113          	addi	sp,sp,48
 4ec:	00008067          	ret
 4f0:	00010537          	lui	a0,0x10
 4f4:	04450513          	addi	a0,a0,68 # 10044 <uh+0x40>
 4f8:	fd5ff06f          	j	4cc <main+0x354>

000004fc <__mulsi3>:
 4fc:	00050613          	mv	a2,a0
 500:	00000513          	li	a0,0
 504:	0015f693          	andi	a3,a1,1
 508:	00068463          	beqz	a3,510 <__mulsi3+0x14>
 50c:	00c50533          	add	a0,a0,a2
 510:	0015d593          	srli	a1,a1,0x1
 514:	00161613          	slli	a2,a2,0x1
 518:	fe0596e3          	bnez	a1,504 <__mulsi3+0x8>
 51c:	00008067          	ret
