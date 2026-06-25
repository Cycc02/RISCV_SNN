
/mnt/c/Users/Administrator/Documents/FYP_Docs/RISCV_SNN/coremark.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
       0:	00000013          	nop
       4:	00014137          	lui	sp,0x14
       8:	00000013          	nop
       c:	00010113          	mv	sp,sp
      10:	000102b7          	lui	t0,0x10
      14:	00000013          	nop
      18:	71028293          	addi	t0,t0,1808 # 10710 <stop_cycles>
      1c:	00010337          	lui	t1,0x10
      20:	00000013          	nop
      24:	72430313          	addi	t1,t1,1828 # 10724 <__bss_end>
      28:	00628863          	beq	t0,t1,38 <_start+0x38>
      2c:	0002a023          	sw	zero,0(t0)
      30:	00428293          	addi	t0,t0,4
      34:	fe62ece3          	bltu	t0,t1,2c <_start+0x2c>
      38:	00000297          	auipc	t0,0x0
      3c:	01828293          	addi	t0,t0,24 # 50 <end_loop>
      40:	00000013          	nop
      44:	00000013          	nop
      48:	30529073          	.word	0x30529073
      4c:	581010ef          	jal	1dcc <main>

00000050 <end_loop>:
      50:	0000006f          	j	50 <end_loop>

00000054 <cmp_idx>:
      54:	00060a63          	beqz	a2,68 <cmp_idx+0x14>
      58:	00251503          	lh	a0,2(a0)
      5c:	00259783          	lh	a5,2(a1)
      60:	40f50533          	sub	a0,a0,a5
      64:	00008067          	ret
      68:	00051783          	lh	a5,0(a0)
      6c:	01079713          	slli	a4,a5,0x10
      70:	01075713          	srli	a4,a4,0x10
      74:	00875713          	srli	a4,a4,0x8
      78:	f007f793          	andi	a5,a5,-256
      7c:	00e7e7b3          	or	a5,a5,a4
      80:	00f51023          	sh	a5,0(a0)
      84:	00059783          	lh	a5,0(a1)
      88:	00251503          	lh	a0,2(a0)
      8c:	01079713          	slli	a4,a5,0x10
      90:	01075713          	srli	a4,a4,0x10
      94:	00875713          	srli	a4,a4,0x8
      98:	f007f793          	andi	a5,a5,-256
      9c:	00e7e7b3          	or	a5,a5,a4
      a0:	00f59023          	sh	a5,0(a1)
      a4:	00259783          	lh	a5,2(a1)
      a8:	40f50533          	sub	a0,a0,a5
      ac:	00008067          	ret

000000b0 <calc_func>:
      b0:	fe010113          	addi	sp,sp,-32 # 13fe0 <__bss_end+0x38bc>
      b4:	00812c23          	sw	s0,24(sp)
      b8:	00051403          	lh	s0,0(a0)
      bc:	00112e23          	sw	ra,28(sp)
      c0:	40745793          	srai	a5,s0,0x7
      c4:	0017f793          	andi	a5,a5,1
      c8:	00078c63          	beqz	a5,e0 <calc_func+0x30>
      cc:	01c12083          	lw	ra,28(sp)
      d0:	07f47513          	andi	a0,s0,127
      d4:	01812403          	lw	s0,24(sp)
      d8:	02010113          	addi	sp,sp,32
      dc:	00008067          	ret
      e0:	40345713          	srai	a4,s0,0x3
      e4:	00f77713          	andi	a4,a4,15
      e8:	00471693          	slli	a3,a4,0x4
      ec:	0385d783          	lhu	a5,56(a1)
      f0:	00912a23          	sw	s1,20(sp)
      f4:	01312623          	sw	s3,12(sp)
      f8:	00058493          	mv	s1,a1
      fc:	01212823          	sw	s2,16(sp)
     100:	00d705b3          	add	a1,a4,a3
     104:	00747613          	andi	a2,s0,7
     108:	00050993          	mv	s3,a0
     10c:	00058713          	mv	a4,a1
     110:	08060063          	beqz	a2,190 <calc_func+0xe0>
     114:	00100693          	li	a3,1
     118:	06d61463          	bne	a2,a3,180 <calc_func+0xd0>
     11c:	00078613          	mv	a2,a5
     120:	02848513          	addi	a0,s1,40
     124:	320010ef          	jal	1444 <core_bench_matrix>
     128:	03c4d783          	lhu	a5,60(s1)
     12c:	01051913          	slli	s2,a0,0x10
     130:	41095913          	srai	s2,s2,0x10
     134:	08079c63          	bnez	a5,1cc <calc_func+0x11c>
     138:	0384d783          	lhu	a5,56(s1)
     13c:	02a49e23          	sh	a0,60(s1)
     140:	00078593          	mv	a1,a5
     144:	1bd010ef          	jal	1b00 <crcu16>
     148:	00050793          	mv	a5,a0
     14c:	f0047413          	andi	s0,s0,-256
     150:	07f97513          	andi	a0,s2,127
     154:	00856433          	or	s0,a0,s0
     158:	02f49c23          	sh	a5,56(s1)
     15c:	08046413          	ori	s0,s0,128
     160:	00899023          	sh	s0,0(s3)
     164:	01c12083          	lw	ra,28(sp)
     168:	01812403          	lw	s0,24(sp)
     16c:	01412483          	lw	s1,20(sp)
     170:	01012903          	lw	s2,16(sp)
     174:	00c12983          	lw	s3,12(sp)
     178:	02010113          	addi	sp,sp,32
     17c:	00008067          	ret
     180:	01041513          	slli	a0,s0,0x10
     184:	01055513          	srli	a0,a0,0x10
     188:	00040913          	mv	s2,s0
     18c:	fb5ff06f          	j	140 <calc_func+0x90>
     190:	02100693          	li	a3,33
     194:	00b6e463          	bltu	a3,a1,19c <calc_func+0xec>
     198:	02200713          	li	a4,34
     19c:	00249683          	lh	a3,2(s1)
     1a0:	00049603          	lh	a2,0(s1)
     1a4:	0144a583          	lw	a1,20(s1)
     1a8:	0184a503          	lw	a0,24(s1)
     1ac:	708010ef          	jal	18b4 <core_bench_state>
     1b0:	03e4d783          	lhu	a5,62(s1)
     1b4:	01051913          	slli	s2,a0,0x10
     1b8:	41095913          	srai	s2,s2,0x10
     1bc:	00079863          	bnez	a5,1cc <calc_func+0x11c>
     1c0:	0384d783          	lhu	a5,56(s1)
     1c4:	02a49f23          	sh	a0,62(s1)
     1c8:	f79ff06f          	j	140 <calc_func+0x90>
     1cc:	0384d783          	lhu	a5,56(s1)
     1d0:	f71ff06f          	j	140 <calc_func+0x90>

000001d4 <cmp_complex>:
     1d4:	ff010113          	addi	sp,sp,-16
     1d8:	00912223          	sw	s1,4(sp)
     1dc:	00058493          	mv	s1,a1
     1e0:	00060593          	mv	a1,a2
     1e4:	00112623          	sw	ra,12(sp)
     1e8:	00812423          	sw	s0,8(sp)
     1ec:	00060413          	mv	s0,a2
     1f0:	ec1ff0ef          	jal	b0 <calc_func>
     1f4:	00050793          	mv	a5,a0
     1f8:	00040593          	mv	a1,s0
     1fc:	00048513          	mv	a0,s1
     200:	00078413          	mv	s0,a5
     204:	eadff0ef          	jal	b0 <calc_func>
     208:	00c12083          	lw	ra,12(sp)
     20c:	40a40533          	sub	a0,s0,a0
     210:	00812403          	lw	s0,8(sp)
     214:	00412483          	lw	s1,4(sp)
     218:	01010113          	addi	sp,sp,16
     21c:	00008067          	ret

00000220 <copy_info>:
     220:	00059703          	lh	a4,0(a1)
     224:	00259783          	lh	a5,2(a1)
     228:	00e51023          	sh	a4,0(a0)
     22c:	00f51123          	sh	a5,2(a0)
     230:	00008067          	ret

00000234 <core_list_insert_new>:
     234:	00062803          	lw	a6,0(a2)
     238:	00880893          	addi	a7,a6,8
     23c:	04e8f663          	bgeu	a7,a4,288 <core_list_insert_new+0x54>
     240:	0006a703          	lw	a4,0(a3)
     244:	00470313          	addi	t1,a4,4
     248:	04f37063          	bgeu	t1,a5,288 <core_list_insert_new+0x54>
     24c:	01162023          	sw	a7,0(a2)
     250:	00052783          	lw	a5,0(a0)
     254:	00059883          	lh	a7,0(a1)
     258:	00259603          	lh	a2,2(a1)
     25c:	00f82023          	sw	a5,0(a6)
     260:	01052023          	sw	a6,0(a0)
     264:	00e82223          	sw	a4,4(a6)
     268:	0006a783          	lw	a5,0(a3)
     26c:	00080513          	mv	a0,a6
     270:	00478793          	addi	a5,a5,4
     274:	00f6a023          	sw	a5,0(a3)
     278:	00482783          	lw	a5,4(a6)
     27c:	01179023          	sh	a7,0(a5)
     280:	00c79123          	sh	a2,2(a5)
     284:	00008067          	ret
     288:	00000813          	li	a6,0
     28c:	00080513          	mv	a0,a6
     290:	00008067          	ret

00000294 <core_list_remove>:
     294:	00050793          	mv	a5,a0
     298:	00052503          	lw	a0,0(a0)
     29c:	0047a683          	lw	a3,4(a5)
     2a0:	00452603          	lw	a2,4(a0)
     2a4:	00052703          	lw	a4,0(a0)
     2a8:	00c7a223          	sw	a2,4(a5)
     2ac:	00d52223          	sw	a3,4(a0)
     2b0:	00e7a023          	sw	a4,0(a5)
     2b4:	00052023          	sw	zero,0(a0)
     2b8:	00008067          	ret

000002bc <core_list_undo_remove>:
     2bc:	0045a603          	lw	a2,4(a1)
     2c0:	00452683          	lw	a3,4(a0)
     2c4:	0005a703          	lw	a4,0(a1)
     2c8:	00c52223          	sw	a2,4(a0)
     2cc:	00d5a223          	sw	a3,4(a1)
     2d0:	00e52023          	sw	a4,0(a0)
     2d4:	00a5a023          	sw	a0,0(a1)
     2d8:	00008067          	ret

000002dc <core_list_find>:
     2dc:	00259703          	lh	a4,2(a1)
     2e0:	02074263          	bltz	a4,304 <core_list_find+0x28>
     2e4:	00051863          	bnez	a0,2f4 <core_list_find+0x18>
     2e8:	00008067          	ret
     2ec:	00052503          	lw	a0,0(a0)
     2f0:	02050c63          	beqz	a0,328 <core_list_find+0x4c>
     2f4:	00452783          	lw	a5,4(a0)
     2f8:	00279783          	lh	a5,2(a5)
     2fc:	fee798e3          	bne	a5,a4,2ec <core_list_find+0x10>
     300:	00008067          	ret
     304:	02050263          	beqz	a0,328 <core_list_find+0x4c>
     308:	00059703          	lh	a4,0(a1)
     30c:	00c0006f          	j	318 <core_list_find+0x3c>
     310:	00052503          	lw	a0,0(a0)
     314:	00050c63          	beqz	a0,32c <core_list_find+0x50>
     318:	00452783          	lw	a5,4(a0)
     31c:	0007c783          	lbu	a5,0(a5)
     320:	fee798e3          	bne	a5,a4,310 <core_list_find+0x34>
     324:	00008067          	ret
     328:	00000513          	li	a0,0
     32c:	00008067          	ret

00000330 <core_list_reverse>:
     330:	02050063          	beqz	a0,350 <core_list_reverse+0x20>
     334:	00000713          	li	a4,0
     338:	0080006f          	j	340 <core_list_reverse+0x10>
     33c:	00078513          	mv	a0,a5
     340:	00052783          	lw	a5,0(a0)
     344:	00e52023          	sw	a4,0(a0)
     348:	00050713          	mv	a4,a0
     34c:	fe0798e3          	bnez	a5,33c <core_list_reverse+0xc>
     350:	00008067          	ret

00000354 <core_list_mergesort>:
     354:	fd010113          	addi	sp,sp,-48
     358:	01312e23          	sw	s3,28(sp)
     35c:	01512a23          	sw	s5,20(sp)
     360:	01712623          	sw	s7,12(sp)
     364:	01812423          	sw	s8,8(sp)
     368:	01a12023          	sw	s10,0(sp)
     36c:	02112623          	sw	ra,44(sp)
     370:	02812423          	sw	s0,40(sp)
     374:	02912223          	sw	s1,36(sp)
     378:	03212023          	sw	s2,32(sp)
     37c:	01412c23          	sw	s4,24(sp)
     380:	01612823          	sw	s6,16(sp)
     384:	01912223          	sw	s9,4(sp)
     388:	00050993          	mv	s3,a0
     38c:	00058c13          	mv	s8,a1
     390:	00060b93          	mv	s7,a2
     394:	00100a93          	li	s5,1
     398:	00100d13          	li	s10,1
     39c:	0c098263          	beqz	s3,460 <core_list_mergesort+0x10c>
     3a0:	00000c93          	li	s9,0
     3a4:	00000493          	li	s1,0
     3a8:	00000b13          	li	s6,0
     3ac:	001c8c93          	addi	s9,s9,1
     3b0:	00098793          	mv	a5,s3
     3b4:	00000413          	li	s0,0
     3b8:	01545863          	bge	s0,s5,3c8 <core_list_mergesort+0x74>
     3bc:	0007a783          	lw	a5,0(a5)
     3c0:	00140413          	addi	s0,s0,1
     3c4:	fe079ae3          	bnez	a5,3b8 <core_list_mergesort+0x64>
     3c8:	00098913          	mv	s2,s3
     3cc:	000a8a13          	mv	s4,s5
     3d0:	00078993          	mv	s3,a5
     3d4:	02805263          	blez	s0,3f8 <core_list_mergesort+0xa4>
     3d8:	040a1463          	bnez	s4,420 <core_list_mergesort+0xcc>
     3dc:	00090793          	mv	a5,s2
     3e0:	00092903          	lw	s2,0(s2)
     3e4:	fff40413          	addi	s0,s0,-1
     3e8:	02048663          	beqz	s1,414 <core_list_mergesort+0xc0>
     3ec:	00f4a023          	sw	a5,0(s1)
     3f0:	00078493          	mv	s1,a5
     3f4:	fe8042e3          	bgtz	s0,3d8 <core_list_mergesort+0x84>
     3f8:	05405863          	blez	s4,448 <core_list_mergesort+0xf4>
     3fc:	04098863          	beqz	s3,44c <core_list_mergesort+0xf8>
     400:	02041263          	bnez	s0,424 <core_list_mergesort+0xd0>
     404:	00098793          	mv	a5,s3
     408:	fffa0a13          	addi	s4,s4,-1
     40c:	0009a983          	lw	s3,0(s3)
     410:	fc049ee3          	bnez	s1,3ec <core_list_mergesort+0x98>
     414:	00078b13          	mv	s6,a5
     418:	00078493          	mv	s1,a5
     41c:	fd9ff06f          	j	3f4 <core_list_mergesort+0xa0>
     420:	fa098ee3          	beqz	s3,3dc <core_list_mergesort+0x88>
     424:	0049a583          	lw	a1,4(s3)
     428:	00492503          	lw	a0,4(s2)
     42c:	000b8613          	mv	a2,s7
     430:	000c00e7          	jalr	s8
     434:	faa054e3          	blez	a0,3dc <core_list_mergesort+0x88>
     438:	00098793          	mv	a5,s3
     43c:	fffa0a13          	addi	s4,s4,-1
     440:	0009a983          	lw	s3,0(s3)
     444:	fa5ff06f          	j	3e8 <core_list_mergesort+0x94>
     448:	f60992e3          	bnez	s3,3ac <core_list_mergesort+0x58>
     44c:	0004a023          	sw	zero,0(s1)
     450:	01ac8c63          	beq	s9,s10,468 <core_list_mergesort+0x114>
     454:	000b0993          	mv	s3,s6
     458:	001a9a93          	slli	s5,s5,0x1
     45c:	f40992e3          	bnez	s3,3a0 <core_list_mergesort+0x4c>
     460:	00002023          	sw	zero,0(zero) # 0 <_start>
     464:	00100073          	ebreak
     468:	02c12083          	lw	ra,44(sp)
     46c:	02812403          	lw	s0,40(sp)
     470:	02412483          	lw	s1,36(sp)
     474:	02012903          	lw	s2,32(sp)
     478:	01c12983          	lw	s3,28(sp)
     47c:	01812a03          	lw	s4,24(sp)
     480:	01412a83          	lw	s5,20(sp)
     484:	00c12b83          	lw	s7,12(sp)
     488:	00812c03          	lw	s8,8(sp)
     48c:	00412c83          	lw	s9,4(sp)
     490:	00012d03          	lw	s10,0(sp)
     494:	000b0513          	mv	a0,s6
     498:	01012b03          	lw	s6,16(sp)
     49c:	03010113          	addi	sp,sp,48
     4a0:	00008067          	ret

000004a4 <core_bench_list>:
     4a4:	00050613          	mv	a2,a0
     4a8:	00451503          	lh	a0,4(a0)
     4ac:	fe010113          	addi	sp,sp,-32
     4b0:	00812c23          	sw	s0,24(sp)
     4b4:	00912a23          	sw	s1,20(sp)
     4b8:	00112e23          	sw	ra,28(sp)
     4bc:	01212823          	sw	s2,16(sp)
     4c0:	01312623          	sw	s3,12(sp)
     4c4:	01412423          	sw	s4,8(sp)
     4c8:	01512223          	sw	s5,4(sp)
     4cc:	02462403          	lw	s0,36(a2)
     4d0:	00058493          	mv	s1,a1
     4d4:	26a05063          	blez	a0,734 <core_bench_list+0x290>
     4d8:	00000893          	li	a7,0
     4dc:	00000e13          	li	t3,0
     4e0:	00000313          	li	t1,0
     4e4:	00000813          	li	a6,0
     4e8:	0ff8fa13          	zext.b	s4,a7
     4ec:	1c04c863          	bltz	s1,6bc <core_bench_list+0x218>
     4f0:	24040863          	beqz	s0,740 <core_bench_list+0x29c>
     4f4:	00040793          	mv	a5,s0
     4f8:	00c0006f          	j	504 <core_bench_list+0x60>
     4fc:	0007a783          	lw	a5,0(a5)
     500:	00078863          	beqz	a5,510 <core_bench_list+0x6c>
     504:	0047a703          	lw	a4,4(a5)
     508:	00271703          	lh	a4,2(a4)
     50c:	fe9718e3          	bne	a4,s1,4fc <core_bench_list+0x58>
     510:	00000693          	li	a3,0
     514:	0080006f          	j	51c <core_bench_list+0x78>
     518:	00070413          	mv	s0,a4
     51c:	00042703          	lw	a4,0(s0)
     520:	00d42023          	sw	a3,0(s0)
     524:	00040693          	mv	a3,s0
     528:	fe0718e3          	bnez	a4,518 <core_bench_list+0x74>
     52c:	1a078a63          	beqz	a5,6e0 <core_bench_list+0x23c>
     530:	0047a703          	lw	a4,4(a5)
     534:	00071703          	lh	a4,0(a4)
     538:	00177693          	andi	a3,a4,1
     53c:	00068c63          	beqz	a3,554 <core_bench_list+0xb0>
     540:	40975713          	srai	a4,a4,0x9
     544:	00177713          	andi	a4,a4,1
     548:	00e80733          	add	a4,a6,a4
     54c:	01071813          	slli	a6,a4,0x10
     550:	01085813          	srli	a6,a6,0x10
     554:	0007a703          	lw	a4,0(a5)
     558:	00070c63          	beqz	a4,570 <core_bench_list+0xcc>
     55c:	00072683          	lw	a3,0(a4)
     560:	00d7a023          	sw	a3,0(a5)
     564:	00042783          	lw	a5,0(s0)
     568:	00f72023          	sw	a5,0(a4)
     56c:	00e42023          	sw	a4,0(s0)
     570:	00130313          	addi	t1,t1,1
     574:	01031313          	slli	t1,t1,0x10
     578:	01035313          	srli	t1,t1,0x10
     57c:	0004c863          	bltz	s1,58c <core_bench_list+0xe8>
     580:	00148493          	addi	s1,s1,1
     584:	01049493          	slli	s1,s1,0x10
     588:	4104d493          	srai	s1,s1,0x10
     58c:	00188793          	addi	a5,a7,1
     590:	01079893          	slli	a7,a5,0x10
     594:	4108d893          	srai	a7,a7,0x10
     598:	f51518e3          	bne	a0,a7,4e8 <core_bench_list+0x44>
     59c:	00231793          	slli	a5,t1,0x2
     5a0:	41c787b3          	sub	a5,a5,t3
     5a4:	00f80833          	add	a6,a6,a5
     5a8:	01081913          	slli	s2,a6,0x10
     5ac:	01095913          	srli	s2,s2,0x10
     5b0:	00b05a63          	blez	a1,5c4 <core_bench_list+0x120>
     5b4:	00040513          	mv	a0,s0
     5b8:	1d400593          	li	a1,468
     5bc:	d99ff0ef          	jal	354 <core_list_mergesort>
     5c0:	00050413          	mv	s0,a0
     5c4:	00042783          	lw	a5,0(s0)
     5c8:	00040993          	mv	s3,s0
     5cc:	0007aa83          	lw	s5,0(a5)
     5d0:	0047a703          	lw	a4,4(a5)
     5d4:	004aa603          	lw	a2,4(s5)
     5d8:	000aa683          	lw	a3,0(s5)
     5dc:	00c7a223          	sw	a2,4(a5)
     5e0:	00eaa223          	sw	a4,4(s5)
     5e4:	00d7a023          	sw	a3,0(a5)
     5e8:	000aa023          	sw	zero,0(s5)
     5ec:	0004d863          	bgez	s1,5fc <core_bench_list+0x158>
     5f0:	0bc0006f          	j	6ac <core_bench_list+0x208>
     5f4:	0009a983          	lw	s3,0(s3)
     5f8:	10098a63          	beqz	s3,70c <core_bench_list+0x268>
     5fc:	0049a783          	lw	a5,4(s3)
     600:	00279783          	lh	a5,2(a5)
     604:	fe9798e3          	bne	a5,s1,5f4 <core_bench_list+0x150>
     608:	00442783          	lw	a5,4(s0)
     60c:	00090593          	mv	a1,s2
     610:	00079503          	lh	a0,0(a5)
     614:	694010ef          	jal	1ca8 <crc16>
     618:	0009a983          	lw	s3,0(s3)
     61c:	00050913          	mv	s2,a0
     620:	fe0994e3          	bnez	s3,608 <core_bench_list+0x164>
     624:	00042983          	lw	s3,0(s0)
     628:	004aa703          	lw	a4,4(s5)
     62c:	0049a683          	lw	a3,4(s3)
     630:	0009a783          	lw	a5,0(s3)
     634:	00daa223          	sw	a3,4(s5)
     638:	00e9a223          	sw	a4,4(s3)
     63c:	00faa023          	sw	a5,0(s5)
     640:	00040513          	mv	a0,s0
     644:	0159a023          	sw	s5,0(s3)
     648:	00000613          	li	a2,0
     64c:	05400593          	li	a1,84
     650:	d05ff0ef          	jal	354 <core_list_mergesort>
     654:	00052403          	lw	s0,0(a0)
     658:	00050493          	mv	s1,a0
     65c:	02040063          	beqz	s0,67c <core_bench_list+0x1d8>
     660:	0044a783          	lw	a5,4(s1)
     664:	00090593          	mv	a1,s2
     668:	00079503          	lh	a0,0(a5)
     66c:	63c010ef          	jal	1ca8 <crc16>
     670:	00042403          	lw	s0,0(s0)
     674:	00050913          	mv	s2,a0
     678:	fe0414e3          	bnez	s0,660 <core_bench_list+0x1bc>
     67c:	01c12083          	lw	ra,28(sp)
     680:	01812403          	lw	s0,24(sp)
     684:	01412483          	lw	s1,20(sp)
     688:	00c12983          	lw	s3,12(sp)
     68c:	00812a03          	lw	s4,8(sp)
     690:	00412a83          	lw	s5,4(sp)
     694:	00090513          	mv	a0,s2
     698:	01012903          	lw	s2,16(sp)
     69c:	02010113          	addi	sp,sp,32
     6a0:	00008067          	ret
     6a4:	0009a983          	lw	s3,0(s3)
     6a8:	06098263          	beqz	s3,70c <core_bench_list+0x268>
     6ac:	0049a783          	lw	a5,4(s3)
     6b0:	0007c783          	lbu	a5,0(a5)
     6b4:	fefa18e3          	bne	s4,a5,6a4 <core_bench_list+0x200>
     6b8:	f51ff06f          	j	608 <core_bench_list+0x164>
     6bc:	08040263          	beqz	s0,740 <core_bench_list+0x29c>
     6c0:	00040793          	mv	a5,s0
     6c4:	00c0006f          	j	6d0 <core_bench_list+0x22c>
     6c8:	0007a783          	lw	a5,0(a5)
     6cc:	e40782e3          	beqz	a5,510 <core_bench_list+0x6c>
     6d0:	0047a703          	lw	a4,4(a5)
     6d4:	00074703          	lbu	a4,0(a4)
     6d8:	feea18e3          	bne	s4,a4,6c8 <core_bench_list+0x224>
     6dc:	e35ff06f          	j	510 <core_bench_list+0x6c>
     6e0:	00042783          	lw	a5,0(s0)
     6e4:	001e0e13          	addi	t3,t3,1
     6e8:	010e1e13          	slli	t3,t3,0x10
     6ec:	0047a783          	lw	a5,4(a5)
     6f0:	010e5e13          	srli	t3,t3,0x10
     6f4:	00178783          	lb	a5,1(a5)
     6f8:	0017f793          	andi	a5,a5,1
     6fc:	00f807b3          	add	a5,a6,a5
     700:	01079813          	slli	a6,a5,0x10
     704:	01085813          	srli	a6,a6,0x10
     708:	e75ff06f          	j	57c <core_bench_list+0xd8>
     70c:	00042983          	lw	s3,0(s0)
     710:	f0098ee3          	beqz	s3,62c <core_bench_list+0x188>
     714:	00442783          	lw	a5,4(s0)
     718:	00090593          	mv	a1,s2
     71c:	00079503          	lh	a0,0(a5)
     720:	588010ef          	jal	1ca8 <crc16>
     724:	0009a983          	lw	s3,0(s3)
     728:	00050913          	mv	s2,a0
     72c:	ec099ee3          	bnez	s3,608 <core_bench_list+0x164>
     730:	ef5ff06f          	j	624 <core_bench_list+0x180>
     734:	00000913          	li	s2,0
     738:	00000a13          	li	s4,0
     73c:	e75ff06f          	j	5b0 <core_bench_list+0x10c>
     740:	00002783          	lw	a5,0(zero) # 0 <_start>
     744:	00100073          	ebreak

00000748 <core_list_init>:
     748:	fe010113          	addi	sp,sp,-32
     74c:	01212823          	sw	s2,16(sp)
     750:	00058913          	mv	s2,a1
     754:	01400593          	li	a1,20
     758:	00812c23          	sw	s0,24(sp)
     75c:	01312623          	sw	s3,12(sp)
     760:	00112e23          	sw	ra,28(sp)
     764:	00060993          	mv	s3,a2
     768:	00912a23          	sw	s1,20(sp)
     76c:	161020ef          	jal	30cc <__hidden___udivsi3>
     770:	ffe50513          	addi	a0,a0,-2
     774:	00351613          	slli	a2,a0,0x3
     778:	00c90633          	add	a2,s2,a2
     77c:	ffff87b7          	lui	a5,0xffff8
     780:	00092023          	sw	zero,0(s2)
     784:	00c92223          	sw	a2,4(s2)
     788:	08078793          	addi	a5,a5,128 # ffff8080 <__stack_top+0xfffe4080>
     78c:	00251e13          	slli	t3,a0,0x2
     790:	00f61023          	sh	a5,0(a2)
     794:	00061123          	sh	zero,2(a2)
     798:	01090693          	addi	a3,s2,16
     79c:	01c60e33          	add	t3,a2,t3
     7a0:	00890413          	addi	s0,s2,8
     7a4:	00460793          	addi	a5,a2,4
     7a8:	14c6fc63          	bgeu	a3,a2,900 <core_list_init+0x1b8>
     7ac:	00860893          	addi	a7,a2,8
     7b0:	15c8f863          	bgeu	a7,t3,900 <core_list_init+0x1b8>
     7b4:	00f92623          	sw	a5,12(s2)
     7b8:	ffff87b7          	lui	a5,0xffff8
     7bc:	00092423          	sw	zero,8(s2)
     7c0:	00892023          	sw	s0,0(s2)
     7c4:	fff00713          	li	a4,-1
     7c8:	fff7c793          	not	a5,a5
     7cc:	00e61223          	sh	a4,4(a2)
     7d0:	00f61323          	sh	a5,6(a2)
     7d4:	06050a63          	beqz	a0,848 <core_list_init+0x100>
     7d8:	01099e93          	slli	t4,s3,0x10
     7dc:	ffff8f37          	lui	t5,0xffff8
     7e0:	010ede93          	srli	t4,t4,0x10
     7e4:	00000813          	li	a6,0
     7e8:	ffff4f13          	not	t5,t5
     7ec:	01081713          	slli	a4,a6,0x10
     7f0:	01075713          	srli	a4,a4,0x10
     7f4:	00eec7b3          	xor	a5,t4,a4
     7f8:	00379793          	slli	a5,a5,0x3
     7fc:	00777713          	andi	a4,a4,7
     800:	0787f793          	andi	a5,a5,120
     804:	00e7e7b3          	or	a5,a5,a4
     808:	00879593          	slli	a1,a5,0x8
     80c:	00868713          	addi	a4,a3,8
     810:	00180813          	addi	a6,a6,1
     814:	00488313          	addi	t1,a7,4
     818:	00b787b3          	add	a5,a5,a1
     81c:	02c77463          	bgeu	a4,a2,844 <core_list_init+0xfc>
     820:	03c37263          	bgeu	t1,t3,844 <core_list_init+0xfc>
     824:	0086a023          	sw	s0,0(a3)
     828:	00d92023          	sw	a3,0(s2)
     82c:	0116a223          	sw	a7,4(a3)
     830:	00f89023          	sh	a5,0(a7)
     834:	01e89123          	sh	t5,2(a7)
     838:	00068413          	mv	s0,a3
     83c:	00030893          	mv	a7,t1
     840:	00070693          	mv	a3,a4
     844:	fb0514e3          	bne	a0,a6,7ec <core_list_init+0xa4>
     848:	00042483          	lw	s1,0(s0)
     84c:	08048663          	beqz	s1,8d8 <core_list_init+0x190>
     850:	00500593          	li	a1,5
     854:	079020ef          	jal	30cc <__hidden___udivsi3>
     858:	000045b7          	lui	a1,0x4
     85c:	20000713          	li	a4,512
     860:	00100693          	li	a3,1
     864:	fff58593          	addi	a1,a1,-1 # 3fff <__modsi3+0xeb7>
     868:	0300006f          	j	898 <core_list_init+0x150>
     86c:	01069793          	slli	a5,a3,0x10
     870:	0004a803          	lw	a6,0(s1)
     874:	4107d793          	srai	a5,a5,0x10
     878:	10070713          	addi	a4,a4,256
     87c:	01071713          	slli	a4,a4,0x10
     880:	00f61123          	sh	a5,2(a2)
     884:	00048413          	mv	s0,s1
     888:	00168693          	addi	a3,a3,1
     88c:	01075713          	srli	a4,a4,0x10
     890:	04080463          	beqz	a6,8d8 <core_list_init+0x190>
     894:	00080493          	mv	s1,a6
     898:	00d9c633          	xor	a2,s3,a3
     89c:	70077793          	andi	a5,a4,1792
     8a0:	00c7e7b3          	or	a5,a5,a2
     8a4:	00b7f7b3          	and	a5,a5,a1
     8a8:	00442603          	lw	a2,4(s0)
     8ac:	fca6e0e3          	bltu	a3,a0,86c <core_list_init+0x124>
     8b0:	0004a803          	lw	a6,0(s1)
     8b4:	01079793          	slli	a5,a5,0x10
     8b8:	4107d793          	srai	a5,a5,0x10
     8bc:	10070713          	addi	a4,a4,256
     8c0:	01071713          	slli	a4,a4,0x10
     8c4:	00f61123          	sh	a5,2(a2)
     8c8:	00048413          	mv	s0,s1
     8cc:	00168693          	addi	a3,a3,1
     8d0:	01075713          	srli	a4,a4,0x10
     8d4:	fc0810e3          	bnez	a6,894 <core_list_init+0x14c>
     8d8:	01812403          	lw	s0,24(sp)
     8dc:	01c12083          	lw	ra,28(sp)
     8e0:	01412483          	lw	s1,20(sp)
     8e4:	00c12983          	lw	s3,12(sp)
     8e8:	00090513          	mv	a0,s2
     8ec:	01012903          	lw	s2,16(sp)
     8f0:	00000613          	li	a2,0
     8f4:	05400593          	li	a1,84
     8f8:	02010113          	addi	sp,sp,32
     8fc:	a59ff06f          	j	354 <core_list_mergesort>
     900:	00040693          	mv	a3,s0
     904:	00078893          	mv	a7,a5
     908:	00000413          	li	s0,0
     90c:	ec9ff06f          	j	7d4 <core_list_init+0x8c>

00000910 <core_init_matrix>:
     910:	fb010113          	addi	sp,sp,-80
     914:	04912223          	sw	s1,68(sp)
     918:	03712623          	sw	s7,44(sp)
     91c:	03a12023          	sw	s10,32(sp)
     920:	01b12e23          	sw	s11,28(sp)
     924:	04112623          	sw	ra,76(sp)
     928:	04812423          	sw	s0,72(sp)
     92c:	03312e23          	sw	s3,60(sp)
     930:	00050493          	mv	s1,a0
     934:	00058b93          	mv	s7,a1
     938:	00068d13          	mv	s10,a3
     93c:	00060d93          	mv	s11,a2
     940:	00061463          	bnez	a2,948 <core_init_matrix+0x38>
     944:	00100d93          	li	s11,1
     948:	00000413          	li	s0,0
     94c:	16048e63          	beqz	s1,ac8 <core_init_matrix+0x1b8>
     950:	00040993          	mv	s3,s0
     954:	00140413          	addi	s0,s0,1
     958:	00040593          	mv	a1,s0
     95c:	00040513          	mv	a0,s0
     960:	740020ef          	jal	30a0 <__mulsi3>
     964:	00351513          	slli	a0,a0,0x3
     968:	fe9564e3          	bltu	a0,s1,950 <core_init_matrix+0x40>
     96c:	00098593          	mv	a1,s3
     970:	00098513          	mv	a0,s3
     974:	72c020ef          	jal	30a0 <__mulsi3>
     978:	fffb8793          	addi	a5,s7,-1
     97c:	ffc7f793          	andi	a5,a5,-4
     980:	00478793          	addi	a5,a5,4 # ffff8004 <__stack_top+0xfffe4004>
     984:	00151713          	slli	a4,a0,0x1
     988:	00f12423          	sw	a5,8(sp)
     98c:	00078493          	mv	s1,a5
     990:	00e787b3          	add	a5,a5,a4
     994:	00e12223          	sw	a4,4(sp)
     998:	01312623          	sw	s3,12(sp)
     99c:	00f12023          	sw	a5,0(sp)
     9a0:	12098063          	beqz	s3,ac0 <core_init_matrix+0x1b0>
     9a4:	05212023          	sw	s2,64(sp)
     9a8:	03412c23          	sw	s4,56(sp)
     9ac:	03512a23          	sw	s5,52(sp)
     9b0:	03612823          	sw	s6,48(sp)
     9b4:	03812423          	sw	s8,40(sp)
     9b8:	03912223          	sw	s9,36(sp)
     9bc:	00012783          	lw	a5,0(sp)
     9c0:	00010937          	lui	s2,0x10
     9c4:	00198413          	addi	s0,s3,1
     9c8:	00199c93          	slli	s9,s3,0x1
     9cc:	00078a13          	mv	s4,a5
     9d0:	00000a93          	li	s5,0
     9d4:	00100c13          	li	s8,1
     9d8:	40f484b3          	sub	s1,s1,a5
     9dc:	fff90913          	addi	s2,s2,-1 # ffff <__modsi3+0xceb7>
     9e0:	000c0b13          	mv	s6,s8
     9e4:	000a0b93          	mv	s7,s4
     9e8:	000c0593          	mv	a1,s8
     9ec:	000d8513          	mv	a0,s11
     9f0:	6b0020ef          	jal	30a0 <__mulsi3>
     9f4:	41f55713          	srai	a4,a0,0x1f
     9f8:	01075713          	srli	a4,a4,0x10
     9fc:	00e50633          	add	a2,a0,a4
     a00:	010c1793          	slli	a5,s8,0x10
     a04:	01267633          	and	a2,a2,s2
     a08:	0107d793          	srli	a5,a5,0x10
     a0c:	40e60db3          	sub	s11,a2,a4
     a10:	01b78733          	add	a4,a5,s11
     a14:	01071713          	slli	a4,a4,0x10
     a18:	01075713          	srli	a4,a4,0x10
     a1c:	00f707b3          	add	a5,a4,a5
     a20:	00eb9023          	sh	a4,0(s7)
     a24:	0ff7f793          	zext.b	a5,a5
     a28:	01748733          	add	a4,s1,s7
     a2c:	00f71023          	sh	a5,0(a4)
     a30:	001c0c13          	addi	s8,s8,1
     a34:	002b8b93          	addi	s7,s7,2
     a38:	fa8c18e3          	bne	s8,s0,9e8 <core_init_matrix+0xd8>
     a3c:	001a8a93          	addi	s5,s5,1
     a40:	01698c33          	add	s8,s3,s6
     a44:	01340433          	add	s0,s0,s3
     a48:	019a0a33          	add	s4,s4,s9
     a4c:	f93a9ae3          	bne	s5,s3,9e0 <core_init_matrix+0xd0>
     a50:	04012903          	lw	s2,64(sp)
     a54:	03812a03          	lw	s4,56(sp)
     a58:	03412a83          	lw	s5,52(sp)
     a5c:	03012b03          	lw	s6,48(sp)
     a60:	02812c03          	lw	s8,40(sp)
     a64:	02412c83          	lw	s9,36(sp)
     a68:	00012703          	lw	a4,0(sp)
     a6c:	00412783          	lw	a5,4(sp)
     a70:	00812683          	lw	a3,8(sp)
     a74:	04c12083          	lw	ra,76(sp)
     a78:	00f707b3          	add	a5,a4,a5
     a7c:	fff78793          	addi	a5,a5,-1
     a80:	ffc7f793          	andi	a5,a5,-4
     a84:	00478793          	addi	a5,a5,4
     a88:	00fd2623          	sw	a5,12(s10)
     a8c:	00c12783          	lw	a5,12(sp)
     a90:	04812403          	lw	s0,72(sp)
     a94:	00dd2223          	sw	a3,4(s10)
     a98:	00ed2423          	sw	a4,8(s10)
     a9c:	00fd2023          	sw	a5,0(s10)
     aa0:	04412483          	lw	s1,68(sp)
     aa4:	02c12b83          	lw	s7,44(sp)
     aa8:	02012d03          	lw	s10,32(sp)
     aac:	01c12d83          	lw	s11,28(sp)
     ab0:	00098513          	mv	a0,s3
     ab4:	03c12983          	lw	s3,60(sp)
     ab8:	05010113          	addi	sp,sp,80
     abc:	00008067          	ret
     ac0:	00012223          	sw	zero,4(sp)
     ac4:	fa5ff06f          	j	a68 <core_init_matrix+0x158>
     ac8:	fffb8b93          	addi	s7,s7,-1
     acc:	ffcbfb93          	andi	s7,s7,-4
     ad0:	006b8793          	addi	a5,s7,6
     ad4:	00f12023          	sw	a5,0(sp)
     ad8:	fff00793          	li	a5,-1
     adc:	004b8493          	addi	s1,s7,4
     ae0:	00f12623          	sw	a5,12(sp)
     ae4:	00200793          	li	a5,2
     ae8:	05212023          	sw	s2,64(sp)
     aec:	03412c23          	sw	s4,56(sp)
     af0:	03512a23          	sw	s5,52(sp)
     af4:	03612823          	sw	s6,48(sp)
     af8:	03812423          	sw	s8,40(sp)
     afc:	03912223          	sw	s9,36(sp)
     b00:	00912423          	sw	s1,8(sp)
     b04:	00f12223          	sw	a5,4(sp)
     b08:	fff00993          	li	s3,-1
     b0c:	eb1ff06f          	j	9bc <core_init_matrix+0xac>

00000b10 <matrix_sum>:
     b10:	00050e93          	mv	t4,a0
     b14:	08050463          	beqz	a0,b9c <matrix_sum+0x8c>
     b18:	00251f93          	slli	t6,a0,0x2
     b1c:	40a00f33          	neg	t5,a0
     b20:	01f588b3          	add	a7,a1,t6
     b24:	00000e13          	li	t3,0
     b28:	00000513          	li	a0,0
     b2c:	00000713          	li	a4,0
     b30:	00000593          	li	a1,0
     b34:	003f1f13          	slli	t5,t5,0x3
     b38:	41f88333          	sub	t1,a7,t6
     b3c:	00030793          	mv	a5,t1
     b40:	0140006f          	j	b54 <matrix_sum+0x44>
     b44:	01051513          	slli	a0,a0,0x10
     b48:	00478793          	addi	a5,a5,4
     b4c:	41055513          	srai	a0,a0,0x10
     b50:	02f88e63          	beq	a7,a5,b8c <matrix_sum+0x7c>
     b54:	00070693          	mv	a3,a4
     b58:	0007a703          	lw	a4,0(a5)
     b5c:	01051513          	slli	a0,a0,0x10
     b60:	01055513          	srli	a0,a0,0x10
     b64:	00e6a6b3          	slt	a3,a3,a4
     b68:	00e585b3          	add	a1,a1,a4
     b6c:	00a50813          	addi	a6,a0,10
     b70:	00d50533          	add	a0,a0,a3
     b74:	fcb658e3          	bge	a2,a1,b44 <matrix_sum+0x34>
     b78:	01081513          	slli	a0,a6,0x10
     b7c:	00478793          	addi	a5,a5,4
     b80:	41055513          	srai	a0,a0,0x10
     b84:	00000593          	li	a1,0
     b88:	fcf896e3          	bne	a7,a5,b54 <matrix_sum+0x44>
     b8c:	001e0e13          	addi	t3,t3,1
     b90:	41e308b3          	sub	a7,t1,t5
     b94:	fbce92e3          	bne	t4,t3,b38 <matrix_sum+0x28>
     b98:	00008067          	ret
     b9c:	00000513          	li	a0,0
     ba0:	00008067          	ret

00000ba4 <matrix_mul_const>:
     ba4:	0c050863          	beqz	a0,c74 <matrix_mul_const+0xd0>
     ba8:	fd010113          	addi	sp,sp,-48
     bac:	01812423          	sw	s8,8(sp)
     bb0:	01a12023          	sw	s10,0(sp)
     bb4:	40a00c33          	neg	s8,a0
     bb8:	00151d13          	slli	s10,a0,0x1
     bbc:	03212023          	sw	s2,32(sp)
     bc0:	01312e23          	sw	s3,28(sp)
     bc4:	01512a23          	sw	s5,20(sp)
     bc8:	01612823          	sw	s6,16(sp)
     bcc:	01712623          	sw	s7,12(sp)
     bd0:	01912223          	sw	s9,4(sp)
     bd4:	02112623          	sw	ra,44(sp)
     bd8:	02812423          	sw	s0,40(sp)
     bdc:	02912223          	sw	s1,36(sp)
     be0:	01412c23          	sw	s4,24(sp)
     be4:	00050b93          	mv	s7,a0
     be8:	00058c93          	mv	s9,a1
     bec:	00068993          	mv	s3,a3
     bf0:	01a60933          	add	s2,a2,s10
     bf4:	00000a93          	li	s5,0
     bf8:	00000b13          	li	s6,0
     bfc:	002c1c13          	slli	s8,s8,0x2
     c00:	41a90a33          	sub	s4,s2,s10
     c04:	002a9493          	slli	s1,s5,0x2
     c08:	009c84b3          	add	s1,s9,s1
     c0c:	000a0413          	mv	s0,s4
     c10:	00041503          	lh	a0,0(s0)
     c14:	00098593          	mv	a1,s3
     c18:	00240413          	addi	s0,s0,2
     c1c:	484020ef          	jal	30a0 <__mulsi3>
     c20:	00a4a023          	sw	a0,0(s1)
     c24:	00448493          	addi	s1,s1,4
     c28:	ff2414e3          	bne	s0,s2,c10 <matrix_mul_const+0x6c>
     c2c:	001b0b13          	addi	s6,s6,1
     c30:	017a8ab3          	add	s5,s5,s7
     c34:	418a0933          	sub	s2,s4,s8
     c38:	fd6b94e3          	bne	s7,s6,c00 <matrix_mul_const+0x5c>
     c3c:	02c12083          	lw	ra,44(sp)
     c40:	02812403          	lw	s0,40(sp)
     c44:	02412483          	lw	s1,36(sp)
     c48:	02012903          	lw	s2,32(sp)
     c4c:	01c12983          	lw	s3,28(sp)
     c50:	01812a03          	lw	s4,24(sp)
     c54:	01412a83          	lw	s5,20(sp)
     c58:	01012b03          	lw	s6,16(sp)
     c5c:	00c12b83          	lw	s7,12(sp)
     c60:	00812c03          	lw	s8,8(sp)
     c64:	00412c83          	lw	s9,4(sp)
     c68:	00012d03          	lw	s10,0(sp)
     c6c:	03010113          	addi	sp,sp,48
     c70:	00008067          	ret
     c74:	00008067          	ret

00000c78 <matrix_add_const>:
     c78:	04050463          	beqz	a0,cc0 <matrix_add_const+0x48>
     c7c:	00151313          	slli	t1,a0,0x1
     c80:	40a008b3          	neg	a7,a0
     c84:	01061613          	slli	a2,a2,0x10
     c88:	01065613          	srli	a2,a2,0x10
     c8c:	006586b3          	add	a3,a1,t1
     c90:	00000813          	li	a6,0
     c94:	00289893          	slli	a7,a7,0x2
     c98:	406685b3          	sub	a1,a3,t1
     c9c:	00058793          	mv	a5,a1
     ca0:	0007d703          	lhu	a4,0(a5)
     ca4:	00278793          	addi	a5,a5,2
     ca8:	00e60733          	add	a4,a2,a4
     cac:	fee79f23          	sh	a4,-2(a5)
     cb0:	fef698e3          	bne	a3,a5,ca0 <matrix_add_const+0x28>
     cb4:	00180813          	addi	a6,a6,1
     cb8:	411586b3          	sub	a3,a1,a7
     cbc:	fd051ee3          	bne	a0,a6,c98 <matrix_add_const+0x20>
     cc0:	00008067          	ret

00000cc4 <matrix_mul_vect>:
     cc4:	0c050463          	beqz	a0,d8c <matrix_mul_vect+0xc8>
     cc8:	fd010113          	addi	sp,sp,-48
     ccc:	01312e23          	sw	s3,28(sp)
     cd0:	01712623          	sw	s7,12(sp)
     cd4:	00151993          	slli	s3,a0,0x1
     cd8:	00251b93          	slli	s7,a0,0x2
     cdc:	01412c23          	sw	s4,24(sp)
     ce0:	01512a23          	sw	s5,20(sp)
     ce4:	01612823          	sw	s6,16(sp)
     ce8:	01812423          	sw	s8,8(sp)
     cec:	01912223          	sw	s9,4(sp)
     cf0:	02112623          	sw	ra,44(sp)
     cf4:	02812423          	sw	s0,40(sp)
     cf8:	02912223          	sw	s1,36(sp)
     cfc:	03212023          	sw	s2,32(sp)
     d00:	00050a93          	mv	s5,a0
     d04:	00060c13          	mv	s8,a2
     d08:	00068b13          	mv	s6,a3
     d0c:	00058a13          	mv	s4,a1
     d10:	01758bb3          	add	s7,a1,s7
     d14:	013689b3          	add	s3,a3,s3
     d18:	00000c93          	li	s9,0
     d1c:	001c9493          	slli	s1,s9,0x1
     d20:	009c04b3          	add	s1,s8,s1
     d24:	000b0413          	mv	s0,s6
     d28:	00000913          	li	s2,0
     d2c:	00041583          	lh	a1,0(s0)
     d30:	00049503          	lh	a0,0(s1)
     d34:	00240413          	addi	s0,s0,2
     d38:	00248493          	addi	s1,s1,2
     d3c:	364020ef          	jal	30a0 <__mulsi3>
     d40:	00a90933          	add	s2,s2,a0
     d44:	fe8994e3          	bne	s3,s0,d2c <matrix_mul_vect+0x68>
     d48:	012a2023          	sw	s2,0(s4)
     d4c:	004a0a13          	addi	s4,s4,4
     d50:	015c8cb3          	add	s9,s9,s5
     d54:	fd4b94e3          	bne	s7,s4,d1c <matrix_mul_vect+0x58>
     d58:	02c12083          	lw	ra,44(sp)
     d5c:	02812403          	lw	s0,40(sp)
     d60:	02412483          	lw	s1,36(sp)
     d64:	02012903          	lw	s2,32(sp)
     d68:	01c12983          	lw	s3,28(sp)
     d6c:	01812a03          	lw	s4,24(sp)
     d70:	01412a83          	lw	s5,20(sp)
     d74:	01012b03          	lw	s6,16(sp)
     d78:	00c12b83          	lw	s7,12(sp)
     d7c:	00812c03          	lw	s8,8(sp)
     d80:	00412c83          	lw	s9,4(sp)
     d84:	03010113          	addi	sp,sp,48
     d88:	00008067          	ret
     d8c:	00008067          	ret

00000d90 <matrix_mul_matrix>:
     d90:	fb010113          	addi	sp,sp,-80
     d94:	04112623          	sw	ra,76(sp)
     d98:	00b12423          	sw	a1,8(sp)
     d9c:	00d12623          	sw	a3,12(sp)
     da0:	0e050863          	beqz	a0,e90 <matrix_mul_matrix+0x100>
     da4:	04912223          	sw	s1,68(sp)
     da8:	00151493          	slli	s1,a0,0x1
     dac:	05212023          	sw	s2,64(sp)
     db0:	03612823          	sw	s6,48(sp)
     db4:	03712623          	sw	s7,44(sp)
     db8:	03812423          	sw	s8,40(sp)
     dbc:	03912223          	sw	s9,36(sp)
     dc0:	04812423          	sw	s0,72(sp)
     dc4:	03312e23          	sw	s3,60(sp)
     dc8:	03412c23          	sw	s4,56(sp)
     dcc:	03512a23          	sw	s5,52(sp)
     dd0:	03a12023          	sw	s10,32(sp)
     dd4:	01b12e23          	sw	s11,28(sp)
     dd8:	00050b93          	mv	s7,a0
     ddc:	00060b13          	mv	s6,a2
     de0:	00960933          	add	s2,a2,s1
     de4:	00000c13          	li	s8,0
     de8:	00000c93          	li	s9,0
     dec:	00812783          	lw	a5,8(sp)
     df0:	00c12a03          	lw	s4,12(sp)
     df4:	002c1993          	slli	s3,s8,0x2
     df8:	013789b3          	add	s3,a5,s3
     dfc:	00000a93          	li	s5,0
     e00:	000a0d93          	mv	s11,s4
     e04:	000b0413          	mv	s0,s6
     e08:	00000d13          	li	s10,0
     e0c:	000d9583          	lh	a1,0(s11)
     e10:	00041503          	lh	a0,0(s0)
     e14:	00240413          	addi	s0,s0,2
     e18:	009d8db3          	add	s11,s11,s1
     e1c:	284020ef          	jal	30a0 <__mulsi3>
     e20:	00ad0d33          	add	s10,s10,a0
     e24:	fe8914e3          	bne	s2,s0,e0c <matrix_mul_matrix+0x7c>
     e28:	01a9a023          	sw	s10,0(s3)
     e2c:	001a8793          	addi	a5,s5,1
     e30:	00498993          	addi	s3,s3,4
     e34:	002a0a13          	addi	s4,s4,2
     e38:	00fb8663          	beq	s7,a5,e44 <matrix_mul_matrix+0xb4>
     e3c:	00078a93          	mv	s5,a5
     e40:	fc1ff06f          	j	e00 <matrix_mul_matrix+0x70>
     e44:	001c8793          	addi	a5,s9,1
     e48:	009b0b33          	add	s6,s6,s1
     e4c:	017c0c33          	add	s8,s8,s7
     e50:	00990933          	add	s2,s2,s1
     e54:	015c8663          	beq	s9,s5,e60 <matrix_mul_matrix+0xd0>
     e58:	00078c93          	mv	s9,a5
     e5c:	f91ff06f          	j	dec <matrix_mul_matrix+0x5c>
     e60:	04812403          	lw	s0,72(sp)
     e64:	04412483          	lw	s1,68(sp)
     e68:	04012903          	lw	s2,64(sp)
     e6c:	03c12983          	lw	s3,60(sp)
     e70:	03812a03          	lw	s4,56(sp)
     e74:	03412a83          	lw	s5,52(sp)
     e78:	03012b03          	lw	s6,48(sp)
     e7c:	02c12b83          	lw	s7,44(sp)
     e80:	02812c03          	lw	s8,40(sp)
     e84:	02412c83          	lw	s9,36(sp)
     e88:	02012d03          	lw	s10,32(sp)
     e8c:	01c12d83          	lw	s11,28(sp)
     e90:	04c12083          	lw	ra,76(sp)
     e94:	05010113          	addi	sp,sp,80
     e98:	00008067          	ret

00000e9c <matrix_mul_matrix_bitextract>:
     e9c:	fb010113          	addi	sp,sp,-80
     ea0:	04112623          	sw	ra,76(sp)
     ea4:	00b12423          	sw	a1,8(sp)
     ea8:	00d12623          	sw	a3,12(sp)
     eac:	10050263          	beqz	a0,fb0 <matrix_mul_matrix_bitextract+0x114>
     eb0:	04812423          	sw	s0,72(sp)
     eb4:	00151413          	slli	s0,a0,0x1
     eb8:	04912223          	sw	s1,68(sp)
     ebc:	03512a23          	sw	s5,52(sp)
     ec0:	03612823          	sw	s6,48(sp)
     ec4:	03712623          	sw	s7,44(sp)
     ec8:	03812423          	sw	s8,40(sp)
     ecc:	05212023          	sw	s2,64(sp)
     ed0:	03312e23          	sw	s3,60(sp)
     ed4:	03412c23          	sw	s4,56(sp)
     ed8:	03912223          	sw	s9,36(sp)
     edc:	03a12023          	sw	s10,32(sp)
     ee0:	01b12e23          	sw	s11,28(sp)
     ee4:	00050b13          	mv	s6,a0
     ee8:	00060a93          	mv	s5,a2
     eec:	008604b3          	add	s1,a2,s0
     ef0:	00000b93          	li	s7,0
     ef4:	00000c13          	li	s8,0
     ef8:	00812783          	lw	a5,8(sp)
     efc:	00c12983          	lw	s3,12(sp)
     f00:	002b9913          	slli	s2,s7,0x2
     f04:	01278933          	add	s2,a5,s2
     f08:	00000a13          	li	s4,0
     f0c:	00098d13          	mv	s10,s3
     f10:	000a8d93          	mv	s11,s5
     f14:	00000c93          	li	s9,0
     f18:	000d1583          	lh	a1,0(s10)
     f1c:	000d9503          	lh	a0,0(s11)
     f20:	002d8d93          	addi	s11,s11,2
     f24:	008d0d33          	add	s10,s10,s0
     f28:	178020ef          	jal	30a0 <__mulsi3>
     f2c:	40255693          	srai	a3,a0,0x2
     f30:	40555593          	srai	a1,a0,0x5
     f34:	07f5f593          	andi	a1,a1,127
     f38:	00f6f513          	andi	a0,a3,15
     f3c:	164020ef          	jal	30a0 <__mulsi3>
     f40:	00ac8cb3          	add	s9,s9,a0
     f44:	fdb49ae3          	bne	s1,s11,f18 <matrix_mul_matrix_bitextract+0x7c>
     f48:	01992023          	sw	s9,0(s2)
     f4c:	001a0793          	addi	a5,s4,1
     f50:	00490913          	addi	s2,s2,4
     f54:	00298993          	addi	s3,s3,2
     f58:	00fb0663          	beq	s6,a5,f64 <matrix_mul_matrix_bitextract+0xc8>
     f5c:	00078a13          	mv	s4,a5
     f60:	fadff06f          	j	f0c <matrix_mul_matrix_bitextract+0x70>
     f64:	001c0793          	addi	a5,s8,1
     f68:	008a8ab3          	add	s5,s5,s0
     f6c:	016b8bb3          	add	s7,s7,s6
     f70:	008484b3          	add	s1,s1,s0
     f74:	014c0663          	beq	s8,s4,f80 <matrix_mul_matrix_bitextract+0xe4>
     f78:	00078c13          	mv	s8,a5
     f7c:	f7dff06f          	j	ef8 <matrix_mul_matrix_bitextract+0x5c>
     f80:	04812403          	lw	s0,72(sp)
     f84:	04412483          	lw	s1,68(sp)
     f88:	04012903          	lw	s2,64(sp)
     f8c:	03c12983          	lw	s3,60(sp)
     f90:	03812a03          	lw	s4,56(sp)
     f94:	03412a83          	lw	s5,52(sp)
     f98:	03012b03          	lw	s6,48(sp)
     f9c:	02c12b83          	lw	s7,44(sp)
     fa0:	02812c03          	lw	s8,40(sp)
     fa4:	02412c83          	lw	s9,36(sp)
     fa8:	02012d03          	lw	s10,32(sp)
     fac:	01c12d83          	lw	s11,28(sp)
     fb0:	04c12083          	lw	ra,76(sp)
     fb4:	05010113          	addi	sp,sp,80
     fb8:	00008067          	ret

00000fbc <matrix_test>:
     fbc:	fa010113          	addi	sp,sp,-96
     fc0:	04112e23          	sw	ra,92(sp)
     fc4:	04812c23          	sw	s0,88(sp)
     fc8:	04912a23          	sw	s1,84(sp)
     fcc:	05212823          	sw	s2,80(sp)
     fd0:	05312623          	sw	s3,76(sp)
     fd4:	00b12823          	sw	a1,16(sp)
     fd8:	00c12a23          	sw	a2,20(sp)
     fdc:	00d12c23          	sw	a3,24(sp)
     fe0:	3e050063          	beqz	a0,13c0 <matrix_test+0x404>
     fe4:	00070913          	mv	s2,a4
     fe8:	00151713          	slli	a4,a0,0x1
     fec:	40a007b3          	neg	a5,a0
     ff0:	00e604b3          	add	s1,a2,a4
     ff4:	01091413          	slli	s0,s2,0x10
     ff8:	05412423          	sw	s4,72(sp)
     ffc:	05512223          	sw	s5,68(sp)
    1000:	03812c23          	sw	s8,56(sp)
    1004:	05612023          	sw	s6,64(sp)
    1008:	03712e23          	sw	s7,60(sp)
    100c:	03912a23          	sw	s9,52(sp)
    1010:	03a12823          	sw	s10,48(sp)
    1014:	03b12623          	sw	s11,44(sp)
    1018:	00050c13          	mv	s8,a0
    101c:	00e12623          	sw	a4,12(sp)
    1020:	00f12e23          	sw	a5,28(sp)
    1024:	01045413          	srli	s0,s0,0x10
    1028:	00048693          	mv	a3,s1
    102c:	00000a13          	li	s4,0
    1030:	00279a93          	slli	s5,a5,0x2
    1034:	00c12783          	lw	a5,12(sp)
    1038:	40f68633          	sub	a2,a3,a5
    103c:	00060793          	mv	a5,a2
    1040:	0007d703          	lhu	a4,0(a5)
    1044:	00278793          	addi	a5,a5,2
    1048:	00e40733          	add	a4,s0,a4
    104c:	fee79f23          	sh	a4,-2(a5)
    1050:	fed798e3          	bne	a5,a3,1040 <matrix_test+0x84>
    1054:	001a0993          	addi	s3,s4,1
    1058:	415606b3          	sub	a3,a2,s5
    105c:	013c0663          	beq	s8,s3,1068 <matrix_test+0xac>
    1060:	00098a13          	mv	s4,s3
    1064:	fd1ff06f          	j	1034 <matrix_test+0x78>
    1068:	00000b93          	li	s7,0
    106c:	00000c93          	li	s9,0
    1070:	00c12783          	lw	a5,12(sp)
    1074:	002b9713          	slli	a4,s7,0x2
    1078:	40f48b33          	sub	s6,s1,a5
    107c:	01012783          	lw	a5,16(sp)
    1080:	000b0d93          	mv	s11,s6
    1084:	00f70d33          	add	s10,a4,a5
    1088:	000d9503          	lh	a0,0(s11)
    108c:	00090593          	mv	a1,s2
    1090:	002d8d93          	addi	s11,s11,2
    1094:	00c020ef          	jal	30a0 <__mulsi3>
    1098:	00ad2023          	sw	a0,0(s10)
    109c:	004d0d13          	addi	s10,s10,4
    10a0:	fe9d94e3          	bne	s11,s1,1088 <matrix_test+0xcc>
    10a4:	001c8793          	addi	a5,s9,1
    10a8:	013b8bb3          	add	s7,s7,s3
    10ac:	415b04b3          	sub	s1,s6,s5
    10b0:	014c8663          	beq	s9,s4,10bc <matrix_test+0x100>
    10b4:	00078c93          	mv	s9,a5
    10b8:	fb9ff06f          	j	1070 <matrix_test+0xb4>
    10bc:	01012783          	lw	a5,16(sp)
    10c0:	41300e33          	neg	t3,s3
    10c4:	fffff4b7          	lui	s1,0xfffff
    10c8:	009964b3          	or	s1,s2,s1
    10cc:	41578833          	sub	a6,a5,s5
    10d0:	00000513          	li	a0,0
    10d4:	00000713          	li	a4,0
    10d8:	00000613          	li	a2,0
    10dc:	00000313          	li	t1,0
    10e0:	003e1e13          	slli	t3,t3,0x3
    10e4:	015808b3          	add	a7,a6,s5
    10e8:	00088793          	mv	a5,a7
    10ec:	0140006f          	j	1100 <matrix_test+0x144>
    10f0:	01051513          	slli	a0,a0,0x10
    10f4:	00478793          	addi	a5,a5,4
    10f8:	41055513          	srai	a0,a0,0x10
    10fc:	03078e63          	beq	a5,a6,1138 <matrix_test+0x17c>
    1100:	00070693          	mv	a3,a4
    1104:	0007a703          	lw	a4,0(a5)
    1108:	01051513          	slli	a0,a0,0x10
    110c:	01055513          	srli	a0,a0,0x10
    1110:	00e6a6b3          	slt	a3,a3,a4
    1114:	00e60633          	add	a2,a2,a4
    1118:	00a50593          	addi	a1,a0,10
    111c:	00d50533          	add	a0,a0,a3
    1120:	fcc4d8e3          	bge	s1,a2,10f0 <matrix_test+0x134>
    1124:	01059513          	slli	a0,a1,0x10
    1128:	00478793          	addi	a5,a5,4
    112c:	41055513          	srai	a0,a0,0x10
    1130:	00000613          	li	a2,0
    1134:	fd0796e3          	bne	a5,a6,1100 <matrix_test+0x144>
    1138:	00130793          	addi	a5,t1,1
    113c:	41c88833          	sub	a6,a7,t3
    1140:	006a0663          	beq	s4,t1,114c <matrix_test+0x190>
    1144:	00078313          	mv	t1,a5
    1148:	f9dff06f          	j	10e4 <matrix_test+0x128>
    114c:	00000593          	li	a1,0
    1150:	359000ef          	jal	1ca8 <crc16>
    1154:	01012903          	lw	s2,16(sp)
    1158:	01412603          	lw	a2,20(sp)
    115c:	01812683          	lw	a3,24(sp)
    1160:	00090593          	mv	a1,s2
    1164:	00050993          	mv	s3,a0
    1168:	000c0513          	mv	a0,s8
    116c:	b59ff0ef          	jal	cc4 <matrix_mul_vect>
    1170:	01c12783          	lw	a5,28(sp)
    1174:	002c1a93          	slli	s5,s8,0x2
    1178:	01590ab3          	add	s5,s2,s5
    117c:	00279a13          	slli	s4,a5,0x2
    1180:	000a8813          	mv	a6,s5
    1184:	00000513          	li	a0,0
    1188:	00000713          	li	a4,0
    118c:	00000613          	li	a2,0
    1190:	00000913          	li	s2,0
    1194:	00379b13          	slli	s6,a5,0x3
    1198:	010a08b3          	add	a7,s4,a6
    119c:	00088793          	mv	a5,a7
    11a0:	0140006f          	j	11b4 <matrix_test+0x1f8>
    11a4:	01051513          	slli	a0,a0,0x10
    11a8:	00478793          	addi	a5,a5,4
    11ac:	41055513          	srai	a0,a0,0x10
    11b0:	03078e63          	beq	a5,a6,11ec <matrix_test+0x230>
    11b4:	00070693          	mv	a3,a4
    11b8:	0007a703          	lw	a4,0(a5)
    11bc:	01051513          	slli	a0,a0,0x10
    11c0:	01055513          	srli	a0,a0,0x10
    11c4:	00e6a6b3          	slt	a3,a3,a4
    11c8:	00e60633          	add	a2,a2,a4
    11cc:	00a50593          	addi	a1,a0,10
    11d0:	00d50533          	add	a0,a0,a3
    11d4:	fcc4d8e3          	bge	s1,a2,11a4 <matrix_test+0x1e8>
    11d8:	01059513          	slli	a0,a1,0x10
    11dc:	00478793          	addi	a5,a5,4
    11e0:	41055513          	srai	a0,a0,0x10
    11e4:	00000613          	li	a2,0
    11e8:	fd0796e3          	bne	a5,a6,11b4 <matrix_test+0x1f8>
    11ec:	00190b93          	addi	s7,s2,1
    11f0:	41688833          	sub	a6,a7,s6
    11f4:	017c0663          	beq	s8,s7,1200 <matrix_test+0x244>
    11f8:	000b8913          	mv	s2,s7
    11fc:	f9dff06f          	j	1198 <matrix_test+0x1dc>
    1200:	00098593          	mv	a1,s3
    1204:	2a5000ef          	jal	1ca8 <crc16>
    1208:	01412603          	lw	a2,20(sp)
    120c:	01812683          	lw	a3,24(sp)
    1210:	01012583          	lw	a1,16(sp)
    1214:	00050993          	mv	s3,a0
    1218:	000b8513          	mv	a0,s7
    121c:	b75ff0ef          	jal	d90 <matrix_mul_matrix>
    1220:	000a8813          	mv	a6,s5
    1224:	00000513          	li	a0,0
    1228:	00000713          	li	a4,0
    122c:	00000613          	li	a2,0
    1230:	00000313          	li	t1,0
    1234:	014808b3          	add	a7,a6,s4
    1238:	00088793          	mv	a5,a7
    123c:	0140006f          	j	1250 <matrix_test+0x294>
    1240:	01051513          	slli	a0,a0,0x10
    1244:	00478793          	addi	a5,a5,4
    1248:	41055513          	srai	a0,a0,0x10
    124c:	02f80e63          	beq	a6,a5,1288 <matrix_test+0x2cc>
    1250:	00070693          	mv	a3,a4
    1254:	0007a703          	lw	a4,0(a5)
    1258:	01051513          	slli	a0,a0,0x10
    125c:	01055513          	srli	a0,a0,0x10
    1260:	00e6a6b3          	slt	a3,a3,a4
    1264:	00e60633          	add	a2,a2,a4
    1268:	00a50593          	addi	a1,a0,10
    126c:	00d50533          	add	a0,a0,a3
    1270:	fcc4d8e3          	bge	s1,a2,1240 <matrix_test+0x284>
    1274:	01059513          	slli	a0,a1,0x10
    1278:	00478793          	addi	a5,a5,4
    127c:	41055513          	srai	a0,a0,0x10
    1280:	00000613          	li	a2,0
    1284:	fcf816e3          	bne	a6,a5,1250 <matrix_test+0x294>
    1288:	00130793          	addi	a5,t1,1
    128c:	41688833          	sub	a6,a7,s6
    1290:	01230663          	beq	t1,s2,129c <matrix_test+0x2e0>
    1294:	00078313          	mv	t1,a5
    1298:	f9dff06f          	j	1234 <matrix_test+0x278>
    129c:	00098593          	mv	a1,s3
    12a0:	209000ef          	jal	1ca8 <crc16>
    12a4:	01412603          	lw	a2,20(sp)
    12a8:	01812683          	lw	a3,24(sp)
    12ac:	01012583          	lw	a1,16(sp)
    12b0:	00050993          	mv	s3,a0
    12b4:	000b8513          	mv	a0,s7
    12b8:	be5ff0ef          	jal	e9c <matrix_mul_matrix_bitextract>
    12bc:	00000513          	li	a0,0
    12c0:	00000713          	li	a4,0
    12c4:	00000613          	li	a2,0
    12c8:	00000893          	li	a7,0
    12cc:	015a0833          	add	a6,s4,s5
    12d0:	00080793          	mv	a5,a6
    12d4:	0140006f          	j	12e8 <matrix_test+0x32c>
    12d8:	01051513          	slli	a0,a0,0x10
    12dc:	00478793          	addi	a5,a5,4
    12e0:	41055513          	srai	a0,a0,0x10
    12e4:	02fa8e63          	beq	s5,a5,1320 <matrix_test+0x364>
    12e8:	00070693          	mv	a3,a4
    12ec:	0007a703          	lw	a4,0(a5)
    12f0:	01051513          	slli	a0,a0,0x10
    12f4:	01055513          	srli	a0,a0,0x10
    12f8:	00e6a6b3          	slt	a3,a3,a4
    12fc:	00e60633          	add	a2,a2,a4
    1300:	00a50593          	addi	a1,a0,10
    1304:	00d50533          	add	a0,a0,a3
    1308:	fcc4d8e3          	bge	s1,a2,12d8 <matrix_test+0x31c>
    130c:	01059513          	slli	a0,a1,0x10
    1310:	00478793          	addi	a5,a5,4
    1314:	41055513          	srai	a0,a0,0x10
    1318:	00000613          	li	a2,0
    131c:	fcfa96e3          	bne	s5,a5,12e8 <matrix_test+0x32c>
    1320:	00188793          	addi	a5,a7,1
    1324:	41680ab3          	sub	s5,a6,s6
    1328:	01288663          	beq	a7,s2,1334 <matrix_test+0x378>
    132c:	00078893          	mv	a7,a5
    1330:	f9dff06f          	j	12cc <matrix_test+0x310>
    1334:	00098593          	mv	a1,s3
    1338:	171000ef          	jal	1ca8 <crc16>
    133c:	01412783          	lw	a5,20(sp)
    1340:	001b9b93          	slli	s7,s7,0x1
    1344:	00000593          	li	a1,0
    1348:	017786b3          	add	a3,a5,s7
    134c:	41768633          	sub	a2,a3,s7
    1350:	00060793          	mv	a5,a2
    1354:	0007d703          	lhu	a4,0(a5)
    1358:	00278793          	addi	a5,a5,2
    135c:	40870733          	sub	a4,a4,s0
    1360:	fee79f23          	sh	a4,-2(a5)
    1364:	fed798e3          	bne	a5,a3,1354 <matrix_test+0x398>
    1368:	00158793          	addi	a5,a1,1
    136c:	414606b3          	sub	a3,a2,s4
    1370:	01258663          	beq	a1,s2,137c <matrix_test+0x3c0>
    1374:	00078593          	mv	a1,a5
    1378:	fd5ff06f          	j	134c <matrix_test+0x390>
    137c:	04812a03          	lw	s4,72(sp)
    1380:	04412a83          	lw	s5,68(sp)
    1384:	04012b03          	lw	s6,64(sp)
    1388:	03c12b83          	lw	s7,60(sp)
    138c:	03812c03          	lw	s8,56(sp)
    1390:	03412c83          	lw	s9,52(sp)
    1394:	03012d03          	lw	s10,48(sp)
    1398:	02c12d83          	lw	s11,44(sp)
    139c:	05c12083          	lw	ra,92(sp)
    13a0:	05812403          	lw	s0,88(sp)
    13a4:	01051513          	slli	a0,a0,0x10
    13a8:	05412483          	lw	s1,84(sp)
    13ac:	05012903          	lw	s2,80(sp)
    13b0:	04c12983          	lw	s3,76(sp)
    13b4:	41055513          	srai	a0,a0,0x10
    13b8:	06010113          	addi	sp,sp,96
    13bc:	00008067          	ret
    13c0:	00000593          	li	a1,0
    13c4:	0e5000ef          	jal	1ca8 <crc16>
    13c8:	01812983          	lw	s3,24(sp)
    13cc:	01412903          	lw	s2,20(sp)
    13d0:	01012483          	lw	s1,16(sp)
    13d4:	00098693          	mv	a3,s3
    13d8:	00090613          	mv	a2,s2
    13dc:	00050413          	mv	s0,a0
    13e0:	00048593          	mv	a1,s1
    13e4:	00000513          	li	a0,0
    13e8:	8ddff0ef          	jal	cc4 <matrix_mul_vect>
    13ec:	00040593          	mv	a1,s0
    13f0:	00000513          	li	a0,0
    13f4:	0b5000ef          	jal	1ca8 <crc16>
    13f8:	00098693          	mv	a3,s3
    13fc:	00090613          	mv	a2,s2
    1400:	00050413          	mv	s0,a0
    1404:	00048593          	mv	a1,s1
    1408:	00000513          	li	a0,0
    140c:	985ff0ef          	jal	d90 <matrix_mul_matrix>
    1410:	00040593          	mv	a1,s0
    1414:	00000513          	li	a0,0
    1418:	091000ef          	jal	1ca8 <crc16>
    141c:	00050413          	mv	s0,a0
    1420:	00048593          	mv	a1,s1
    1424:	00098693          	mv	a3,s3
    1428:	00090613          	mv	a2,s2
    142c:	00000513          	li	a0,0
    1430:	a6dff0ef          	jal	e9c <matrix_mul_matrix_bitextract>
    1434:	00040593          	mv	a1,s0
    1438:	00000513          	li	a0,0
    143c:	06d000ef          	jal	1ca8 <crc16>
    1440:	f5dff06f          	j	139c <matrix_test+0x3e0>

00001444 <core_bench_matrix>:
    1444:	ff010113          	addi	sp,sp,-16
    1448:	00812423          	sw	s0,8(sp)
    144c:	00852683          	lw	a3,8(a0)
    1450:	00060413          	mv	s0,a2
    1454:	00058713          	mv	a4,a1
    1458:	00452603          	lw	a2,4(a0)
    145c:	00c52583          	lw	a1,12(a0)
    1460:	00052503          	lw	a0,0(a0)
    1464:	00112623          	sw	ra,12(sp)
    1468:	b55ff0ef          	jal	fbc <matrix_test>
    146c:	00040593          	mv	a1,s0
    1470:	00812403          	lw	s0,8(sp)
    1474:	00c12083          	lw	ra,12(sp)
    1478:	01010113          	addi	sp,sp,16
    147c:	02d0006f          	j	1ca8 <crc16>

00001480 <core_init_state>:
    1480:	fff50893          	addi	a7,a0,-1
    1484:	00100793          	li	a5,1
    1488:	1317f063          	bgeu	a5,a7,15a8 <core_init_state+0x128>
    148c:	00158593          	addi	a1,a1,1
    1490:	01059593          	slli	a1,a1,0x10
    1494:	0105d593          	srli	a1,a1,0x10
    1498:	ff010113          	addi	sp,sp,-16
    149c:	00010837          	lui	a6,0x10
    14a0:	0035d793          	srli	a5,a1,0x3
    14a4:	00812623          	sw	s0,12(sp)
    14a8:	00700313          	li	t1,7
    14ac:	0075f693          	andi	a3,a1,7
    14b0:	00000713          	li	a4,0
    14b4:	54880813          	addi	a6,a6,1352 # 10548 <intpat>
    14b8:	00400e13          	li	t3,4
    14bc:	00100e93          	li	t4,1
    14c0:	02c00f13          	li	t5,44
    14c4:	0037f793          	andi	a5,a5,3
    14c8:	06668e63          	beq	a3,t1,1544 <core_init_state+0xc4>
    14cc:	0cde6463          	bltu	t3,a3,1594 <core_init_state+0x114>
    14d0:	ffd68693          	addi	a3,a3,-3
    14d4:	01069693          	slli	a3,a3,0x10
    14d8:	00279793          	slli	a5,a5,0x2
    14dc:	0106d693          	srli	a3,a3,0x10
    14e0:	00f807b3          	add	a5,a6,a5
    14e4:	0adee263          	bltu	t4,a3,1588 <core_init_state+0x108>
    14e8:	0107a783          	lw	a5,16(a5)
    14ec:	00800293          	li	t0,8
    14f0:	00170693          	addi	a3,a4,1
    14f4:	00568433          	add	s0,a3,t0
    14f8:	07147463          	bgeu	s0,a7,1560 <core_init_state+0xe0>
    14fc:	00e60733          	add	a4,a2,a4
    1500:	00070693          	mv	a3,a4
    1504:	005783b3          	add	t2,a5,t0
    1508:	0007cf83          	lbu	t6,0(a5)
    150c:	00178793          	addi	a5,a5,1
    1510:	00168693          	addi	a3,a3,1
    1514:	fff68fa3          	sb	t6,-1(a3)
    1518:	fef398e3          	bne	t2,a5,1508 <core_init_state+0x88>
    151c:	00158593          	addi	a1,a1,1
    1520:	01059593          	slli	a1,a1,0x10
    1524:	00570733          	add	a4,a4,t0
    1528:	0105d593          	srli	a1,a1,0x10
    152c:	01e70023          	sb	t5,0(a4)
    1530:	0035d793          	srli	a5,a1,0x3
    1534:	0075f693          	andi	a3,a1,7
    1538:	00040713          	mv	a4,s0
    153c:	0037f793          	andi	a5,a5,3
    1540:	f86696e3          	bne	a3,t1,14cc <core_init_state+0x4c>
    1544:	00279793          	slli	a5,a5,0x2
    1548:	00800293          	li	t0,8
    154c:	00170693          	addi	a3,a4,1
    1550:	00f807b3          	add	a5,a6,a5
    1554:	00568433          	add	s0,a3,t0
    1558:	0307a783          	lw	a5,48(a5)
    155c:	fb1460e3          	bltu	s0,a7,14fc <core_init_state+0x7c>
    1560:	00a76663          	bltu	a4,a0,156c <core_init_state+0xec>
    1564:	0180006f          	j	157c <core_init_state+0xfc>
    1568:	00168693          	addi	a3,a3,1
    156c:	00e60733          	add	a4,a2,a4
    1570:	00070023          	sb	zero,0(a4)
    1574:	00068713          	mv	a4,a3
    1578:	fea6e8e3          	bltu	a3,a0,1568 <core_init_state+0xe8>
    157c:	00c12403          	lw	s0,12(sp)
    1580:	01010113          	addi	sp,sp,16
    1584:	00008067          	ret
    1588:	0007a783          	lw	a5,0(a5)
    158c:	00400293          	li	t0,4
    1590:	f61ff06f          	j	14f0 <core_init_state+0x70>
    1594:	00279793          	slli	a5,a5,0x2
    1598:	00f807b3          	add	a5,a6,a5
    159c:	0207a783          	lw	a5,32(a5)
    15a0:	00800293          	li	t0,8
    15a4:	f4dff06f          	j	14f0 <core_init_state+0x70>
    15a8:	00000713          	li	a4,0
    15ac:	00100693          	li	a3,1
    15b0:	0080006f          	j	15b8 <core_init_state+0x138>
    15b4:	00168693          	addi	a3,a3,1
    15b8:	00e60733          	add	a4,a2,a4
    15bc:	00070023          	sb	zero,0(a4)
    15c0:	00068713          	mv	a4,a3
    15c4:	fea6e8e3          	bltu	a3,a0,15b4 <core_init_state+0x134>
    15c8:	00008067          	ret

000015cc <core_state_transition>:
    15cc:	00052783          	lw	a5,0(a0)
    15d0:	00050813          	mv	a6,a0
    15d4:	0007c703          	lbu	a4,0(a5)
    15d8:	28070263          	beqz	a4,185c <core_state_transition+0x290>
    15dc:	02c00693          	li	a3,44
    15e0:	00000513          	li	a0,0
    15e4:	20d70a63          	beq	a4,a3,17f8 <core_state_transition+0x22c>
    15e8:	02e00513          	li	a0,46
    15ec:	22a70663          	beq	a4,a0,1818 <core_state_transition+0x24c>
    15f0:	1ce56a63          	bltu	a0,a4,17c4 <core_state_transition+0x1f8>
    15f4:	fd570713          	addi	a4,a4,-43
    15f8:	0fd77713          	andi	a4,a4,253
    15fc:	02070663          	beqz	a4,1628 <core_state_transition+0x5c>
    1600:	0045a683          	lw	a3,4(a1)
    1604:	0005a703          	lw	a4,0(a1)
    1608:	00178793          	addi	a5,a5,1
    160c:	00168693          	addi	a3,a3,1
    1610:	00170713          	addi	a4,a4,1
    1614:	00d5a223          	sw	a3,4(a1)
    1618:	00e5a023          	sw	a4,0(a1)
    161c:	00100513          	li	a0,1
    1620:	00f82023          	sw	a5,0(a6)
    1624:	00008067          	ret
    1628:	0005a703          	lw	a4,0(a1)
    162c:	00178613          	addi	a2,a5,1
    1630:	00170713          	addi	a4,a4,1
    1634:	00e5a023          	sw	a4,0(a1)
    1638:	0017c883          	lbu	a7,1(a5)
    163c:	26088663          	beqz	a7,18a8 <core_state_transition+0x2dc>
    1640:	20d88663          	beq	a7,a3,184c <core_state_transition+0x280>
    1644:	0085a683          	lw	a3,8(a1)
    1648:	fd088713          	addi	a4,a7,-48
    164c:	0ff77713          	zext.b	a4,a4
    1650:	00900313          	li	t1,9
    1654:	00168693          	addi	a3,a3,1
    1658:	00e37e63          	bgeu	t1,a4,1674 <core_state_transition+0xa8>
    165c:	1ea88463          	beq	a7,a0,1844 <core_state_transition+0x278>
    1660:	00d5a423          	sw	a3,8(a1)
    1664:	00278793          	addi	a5,a5,2
    1668:	00100513          	li	a0,1
    166c:	00f82023          	sw	a5,0(a6)
    1670:	00008067          	ret
    1674:	00d5a423          	sw	a3,8(a1)
    1678:	00164783          	lbu	a5,1(a2)
    167c:	00160613          	addi	a2,a2,1
    1680:	1e078263          	beqz	a5,1864 <core_state_transition+0x298>
    1684:	02c00713          	li	a4,44
    1688:	16e78463          	beq	a5,a4,17f0 <core_state_transition+0x224>
    168c:	02e00713          	li	a4,46
    1690:	02e78863          	beq	a5,a4,16c0 <core_state_transition+0xf4>
    1694:	fd078793          	addi	a5,a5,-48
    1698:	0ff7f793          	zext.b	a5,a5
    169c:	00900713          	li	a4,9
    16a0:	fcf77ce3          	bgeu	a4,a5,1678 <core_state_transition+0xac>
    16a4:	0105a703          	lw	a4,16(a1)
    16a8:	00160793          	addi	a5,a2,1
    16ac:	00100513          	li	a0,1
    16b0:	00170713          	addi	a4,a4,1
    16b4:	00e5a823          	sw	a4,16(a1)
    16b8:	00f82023          	sw	a5,0(a6)
    16bc:	00008067          	ret
    16c0:	0105a783          	lw	a5,16(a1)
    16c4:	00178793          	addi	a5,a5,1
    16c8:	00f5a823          	sw	a5,16(a1)
    16cc:	0140006f          	j	16e0 <core_state_transition+0x114>
    16d0:	fd078793          	addi	a5,a5,-48
    16d4:	0ff7f793          	zext.b	a5,a5
    16d8:	00900713          	li	a4,9
    16dc:	12f76263          	bltu	a4,a5,1800 <core_state_transition+0x234>
    16e0:	00164783          	lbu	a5,1(a2)
    16e4:	00160613          	addi	a2,a2,1
    16e8:	1a078a63          	beqz	a5,189c <core_state_transition+0x2d0>
    16ec:	02c00713          	li	a4,44
    16f0:	14e78263          	beq	a5,a4,1834 <core_state_transition+0x268>
    16f4:	0df7f713          	andi	a4,a5,223
    16f8:	04500693          	li	a3,69
    16fc:	fcd71ae3          	bne	a4,a3,16d0 <core_state_transition+0x104>
    1700:	0145a703          	lw	a4,20(a1)
    1704:	00160793          	addi	a5,a2,1
    1708:	00300513          	li	a0,3
    170c:	00170713          	addi	a4,a4,1
    1710:	00e5aa23          	sw	a4,20(a1)
    1714:	00164703          	lbu	a4,1(a2)
    1718:	f00704e3          	beqz	a4,1620 <core_state_transition+0x54>
    171c:	02c00693          	li	a3,44
    1720:	14d70863          	beq	a4,a3,1870 <core_state_transition+0x2a4>
    1724:	00c5a783          	lw	a5,12(a1)
    1728:	fd570713          	addi	a4,a4,-43
    172c:	0fd77713          	andi	a4,a4,253
    1730:	00178793          	addi	a5,a5,1
    1734:	00f5a623          	sw	a5,12(a1)
    1738:	00100513          	li	a0,1
    173c:	00260793          	addi	a5,a2,2
    1740:	ee0710e3          	bnez	a4,1620 <core_state_transition+0x54>
    1744:	00264703          	lbu	a4,2(a2)
    1748:	00260793          	addi	a5,a2,2
    174c:	00600513          	li	a0,6
    1750:	ec0708e3          	beqz	a4,1620 <core_state_transition+0x54>
    1754:	12d70463          	beq	a4,a3,187c <core_state_transition+0x2b0>
    1758:	0185a683          	lw	a3,24(a1)
    175c:	fd070713          	addi	a4,a4,-48
    1760:	0ff77713          	zext.b	a4,a4
    1764:	00168693          	addi	a3,a3,1
    1768:	00900513          	li	a0,9
    176c:	00d5ac23          	sw	a3,24(a1)
    1770:	00e57a63          	bgeu	a0,a4,1784 <core_state_transition+0x1b8>
    1774:	00360793          	addi	a5,a2,3
    1778:	00100513          	li	a0,1
    177c:	00f82023          	sw	a5,0(a6)
    1780:	00008067          	ret
    1784:	00900613          	li	a2,9
    1788:	0017c683          	lbu	a3,1(a5)
    178c:	00078513          	mv	a0,a5
    1790:	02c00893          	li	a7,44
    1794:	fd068713          	addi	a4,a3,-48
    1798:	00178793          	addi	a5,a5,1
    179c:	0ff77713          	zext.b	a4,a4
    17a0:	0e068463          	beqz	a3,1888 <core_state_transition+0x2bc>
    17a4:	0f168663          	beq	a3,a7,1890 <core_state_transition+0x2c4>
    17a8:	fee670e3          	bgeu	a2,a4,1788 <core_state_transition+0x1bc>
    17ac:	0045a703          	lw	a4,4(a1)
    17b0:	00250793          	addi	a5,a0,2
    17b4:	00100513          	li	a0,1
    17b8:	00170713          	addi	a4,a4,1
    17bc:	00e5a223          	sw	a4,4(a1)
    17c0:	e61ff06f          	j	1620 <core_state_transition+0x54>
    17c4:	fd070713          	addi	a4,a4,-48
    17c8:	0ff77713          	zext.b	a4,a4
    17cc:	00900613          	li	a2,9
    17d0:	e2e668e3          	bltu	a2,a4,1600 <core_state_transition+0x34>
    17d4:	0005a703          	lw	a4,0(a1)
    17d8:	00178613          	addi	a2,a5,1
    17dc:	00170713          	addi	a4,a4,1
    17e0:	00e5a023          	sw	a4,0(a1)
    17e4:	0017c783          	lbu	a5,1(a5)
    17e8:	06078e63          	beqz	a5,1864 <core_state_transition+0x298>
    17ec:	ead790e3          	bne	a5,a3,168c <core_state_transition+0xc0>
    17f0:	00060793          	mv	a5,a2
    17f4:	00400513          	li	a0,4
    17f8:	00178793          	addi	a5,a5,1
    17fc:	e25ff06f          	j	1620 <core_state_transition+0x54>
    1800:	0145a703          	lw	a4,20(a1)
    1804:	00160793          	addi	a5,a2,1
    1808:	00100513          	li	a0,1
    180c:	00170713          	addi	a4,a4,1
    1810:	00e5aa23          	sw	a4,20(a1)
    1814:	e0dff06f          	j	1620 <core_state_transition+0x54>
    1818:	0005a703          	lw	a4,0(a1)
    181c:	00178613          	addi	a2,a5,1
    1820:	00170713          	addi	a4,a4,1
    1824:	00e5a023          	sw	a4,0(a1)
    1828:	0017c783          	lbu	a5,1(a5)
    182c:	06078863          	beqz	a5,189c <core_state_transition+0x2d0>
    1830:	ecd792e3          	bne	a5,a3,16f4 <core_state_transition+0x128>
    1834:	00060793          	mv	a5,a2
    1838:	00500513          	li	a0,5
    183c:	00178793          	addi	a5,a5,1
    1840:	de1ff06f          	j	1620 <core_state_transition+0x54>
    1844:	00d5a423          	sw	a3,8(a1)
    1848:	e99ff06f          	j	16e0 <core_state_transition+0x114>
    184c:	00060793          	mv	a5,a2
    1850:	00200513          	li	a0,2
    1854:	00178793          	addi	a5,a5,1
    1858:	dc9ff06f          	j	1620 <core_state_transition+0x54>
    185c:	00000513          	li	a0,0
    1860:	dc1ff06f          	j	1620 <core_state_transition+0x54>
    1864:	00060793          	mv	a5,a2
    1868:	00400513          	li	a0,4
    186c:	db5ff06f          	j	1620 <core_state_transition+0x54>
    1870:	00300513          	li	a0,3
    1874:	00178793          	addi	a5,a5,1
    1878:	da9ff06f          	j	1620 <core_state_transition+0x54>
    187c:	00600513          	li	a0,6
    1880:	00178793          	addi	a5,a5,1
    1884:	d9dff06f          	j	1620 <core_state_transition+0x54>
    1888:	00700513          	li	a0,7
    188c:	d95ff06f          	j	1620 <core_state_transition+0x54>
    1890:	00700513          	li	a0,7
    1894:	00178793          	addi	a5,a5,1
    1898:	d89ff06f          	j	1620 <core_state_transition+0x54>
    189c:	00060793          	mv	a5,a2
    18a0:	00500513          	li	a0,5
    18a4:	d7dff06f          	j	1620 <core_state_transition+0x54>
    18a8:	00060793          	mv	a5,a2
    18ac:	00200513          	li	a0,2
    18b0:	d71ff06f          	j	1620 <core_state_transition+0x54>

000018b4 <core_bench_state>:
    18b4:	f8010113          	addi	sp,sp,-128
    18b8:	06912a23          	sw	s1,116(sp)
    18bc:	07312623          	sw	s3,108(sp)
    18c0:	01010493          	addi	s1,sp,16
    18c4:	03010993          	addi	s3,sp,48
    18c8:	06812c23          	sw	s0,120(sp)
    18cc:	07212823          	sw	s2,112(sp)
    18d0:	07412423          	sw	s4,104(sp)
    18d4:	07612023          	sw	s6,96(sp)
    18d8:	05712e23          	sw	s7,92(sp)
    18dc:	05812c23          	sw	s8,88(sp)
    18e0:	00068b13          	mv	s6,a3
    18e4:	00070a13          	mv	s4,a4
    18e8:	00078913          	mv	s2,a5
    18ec:	06112e23          	sw	ra,124(sp)
    18f0:	07512223          	sw	s5,100(sp)
    18f4:	00058413          	mv	s0,a1
    18f8:	00050c13          	mv	s8,a0
    18fc:	00060b93          	mv	s7,a2
    1900:	00b12623          	sw	a1,12(sp)
    1904:	05010693          	addi	a3,sp,80
    1908:	00048713          	mv	a4,s1
    190c:	00098793          	mv	a5,s3
    1910:	0007a023          	sw	zero,0(a5)
    1914:	00072023          	sw	zero,0(a4)
    1918:	00478793          	addi	a5,a5,4
    191c:	00470713          	addi	a4,a4,4
    1920:	fed798e3          	bne	a5,a3,1910 <core_bench_state+0x5c>
    1924:	00044783          	lbu	a5,0(s0)
    1928:	00c10a93          	addi	s5,sp,12
    192c:	10078e63          	beqz	a5,1a48 <core_bench_state+0x194>
    1930:	03010593          	addi	a1,sp,48
    1934:	000a8513          	mv	a0,s5
    1938:	c95ff0ef          	jal	15cc <core_state_transition>
    193c:	00251813          	slli	a6,a0,0x2
    1940:	05080793          	addi	a5,a6,80
    1944:	00278833          	add	a6,a5,sp
    1948:	00c12703          	lw	a4,12(sp)
    194c:	fc082783          	lw	a5,-64(a6)
    1950:	00074703          	lbu	a4,0(a4)
    1954:	00178793          	addi	a5,a5,1
    1958:	fcf82023          	sw	a5,-64(a6)
    195c:	fc071ae3          	bnez	a4,1930 <core_bench_state+0x7c>
    1960:	00812623          	sw	s0,12(sp)
    1964:	01840c33          	add	s8,s0,s8
    1968:	03847863          	bgeu	s0,s8,1998 <core_bench_state+0xe4>
    196c:	00040793          	mv	a5,s0
    1970:	02c00613          	li	a2,44
    1974:	0007c703          	lbu	a4,0(a5)
    1978:	017746b3          	xor	a3,a4,s7
    197c:	00c70463          	beq	a4,a2,1984 <core_bench_state+0xd0>
    1980:	00d78023          	sb	a3,0(a5)
    1984:	014787b3          	add	a5,a5,s4
    1988:	ff87e6e3          	bltu	a5,s8,1974 <core_bench_state+0xc0>
    198c:	00044783          	lbu	a5,0(s0)
    1990:	00c10a93          	addi	s5,sp,12
    1994:	02078a63          	beqz	a5,19c8 <core_bench_state+0x114>
    1998:	03010593          	addi	a1,sp,48
    199c:	000a8513          	mv	a0,s5
    19a0:	c2dff0ef          	jal	15cc <core_state_transition>
    19a4:	00251613          	slli	a2,a0,0x2
    19a8:	05060793          	addi	a5,a2,80
    19ac:	00278633          	add	a2,a5,sp
    19b0:	00c12703          	lw	a4,12(sp)
    19b4:	fc062783          	lw	a5,-64(a2)
    19b8:	00074703          	lbu	a4,0(a4)
    19bc:	00178793          	addi	a5,a5,1
    19c0:	fcf62023          	sw	a5,-64(a2)
    19c4:	fc071ae3          	bnez	a4,1998 <core_bench_state+0xe4>
    19c8:	00812623          	sw	s0,12(sp)
    19cc:	02c00693          	li	a3,44
    19d0:	01847e63          	bgeu	s0,s8,19ec <core_bench_state+0x138>
    19d4:	00044783          	lbu	a5,0(s0)
    19d8:	0167c733          	xor	a4,a5,s6
    19dc:	00d78463          	beq	a5,a3,19e4 <core_bench_state+0x130>
    19e0:	00e40023          	sb	a4,0(s0)
    19e4:	01440433          	add	s0,s0,s4
    19e8:	ff8466e3          	bltu	s0,s8,19d4 <core_bench_state+0x120>
    19ec:	02048413          	addi	s0,s1,32 # fffff020 <__stack_top+0xfffeb020>
    19f0:	0004a503          	lw	a0,0(s1)
    19f4:	00090593          	mv	a1,s2
    19f8:	00448493          	addi	s1,s1,4
    19fc:	190000ef          	jal	1b8c <crcu32>
    1a00:	00050593          	mv	a1,a0
    1a04:	0009a503          	lw	a0,0(s3)
    1a08:	00498993          	addi	s3,s3,4
    1a0c:	180000ef          	jal	1b8c <crcu32>
    1a10:	00050913          	mv	s2,a0
    1a14:	fc941ee3          	bne	s0,s1,19f0 <core_bench_state+0x13c>
    1a18:	07c12083          	lw	ra,124(sp)
    1a1c:	07812403          	lw	s0,120(sp)
    1a20:	07412483          	lw	s1,116(sp)
    1a24:	07012903          	lw	s2,112(sp)
    1a28:	06c12983          	lw	s3,108(sp)
    1a2c:	06812a03          	lw	s4,104(sp)
    1a30:	06412a83          	lw	s5,100(sp)
    1a34:	06012b03          	lw	s6,96(sp)
    1a38:	05c12b83          	lw	s7,92(sp)
    1a3c:	05812c03          	lw	s8,88(sp)
    1a40:	08010113          	addi	sp,sp,128
    1a44:	00008067          	ret
    1a48:	01840c33          	add	s8,s0,s8
    1a4c:	f38460e3          	bltu	s0,s8,196c <core_bench_state+0xb8>
    1a50:	f9dff06f          	j	19ec <core_bench_state+0x138>

00001a54 <get_seed_32>:
    1a54:	00500793          	li	a5,5
    1a58:	04a7ec63          	bltu	a5,a0,1ab0 <get_seed_32+0x5c>
    1a5c:	000107b7          	lui	a5,0x10
    1a60:	58878793          	addi	a5,a5,1416 # 10588 <errpat+0x10>
    1a64:	00251513          	slli	a0,a0,0x2
    1a68:	00f50533          	add	a0,a0,a5
    1a6c:	00052783          	lw	a5,0(a0)
    1a70:	00078067          	jr	a5
    1a74:	000107b7          	lui	a5,0x10
    1a78:	7187a503          	lw	a0,1816(a5) # 10718 <seed5_volatile>
    1a7c:	00008067          	ret
    1a80:	000107b7          	lui	a5,0x10
    1a84:	7207a503          	lw	a0,1824(a5) # 10720 <seed1_volatile>
    1a88:	00008067          	ret
    1a8c:	000107b7          	lui	a5,0x10
    1a90:	71c7a503          	lw	a0,1820(a5) # 1071c <seed2_volatile>
    1a94:	00008067          	ret
    1a98:	000107b7          	lui	a5,0x10
    1a9c:	0147a503          	lw	a0,20(a5) # 10014 <seed3_volatile>
    1aa0:	00008067          	ret
    1aa4:	000107b7          	lui	a5,0x10
    1aa8:	0107a503          	lw	a0,16(a5) # 10010 <seed4_volatile>
    1aac:	00008067          	ret
    1ab0:	00000513          	li	a0,0
    1ab4:	00008067          	ret

00001ab8 <crcu8>:
    1ab8:	ffffa637          	lui	a2,0xffffa
    1abc:	00050693          	mv	a3,a0
    1ac0:	00800713          	li	a4,8
    1ac4:	00058513          	mv	a0,a1
    1ac8:	00160613          	addi	a2,a2,1 # ffffa001 <__stack_top+0xfffe6001>
    1acc:	00a6c7b3          	xor	a5,a3,a0
    1ad0:	0017f793          	andi	a5,a5,1
    1ad4:	40f007b3          	neg	a5,a5
    1ad8:	00155513          	srli	a0,a0,0x1
    1adc:	00c7f7b3          	and	a5,a5,a2
    1ae0:	fff70713          	addi	a4,a4,-1
    1ae4:	00a7c7b3          	xor	a5,a5,a0
    1ae8:	01079513          	slli	a0,a5,0x10
    1aec:	0ff77713          	zext.b	a4,a4
    1af0:	0016d693          	srli	a3,a3,0x1
    1af4:	01055513          	srli	a0,a0,0x10
    1af8:	fc071ae3          	bnez	a4,1acc <crcu8+0x14>
    1afc:	00008067          	ret

00001b00 <crcu16>:
    1b00:	00050693          	mv	a3,a0
    1b04:	ffffa837          	lui	a6,0xffffa
    1b08:	00058513          	mv	a0,a1
    1b0c:	0ff6f613          	zext.b	a2,a3
    1b10:	00800713          	li	a4,8
    1b14:	00180813          	addi	a6,a6,1 # ffffa001 <__stack_top+0xfffe6001>
    1b18:	00a647b3          	xor	a5,a2,a0
    1b1c:	0017f793          	andi	a5,a5,1
    1b20:	40f007b3          	neg	a5,a5
    1b24:	00155513          	srli	a0,a0,0x1
    1b28:	0107f7b3          	and	a5,a5,a6
    1b2c:	fff70713          	addi	a4,a4,-1
    1b30:	00a7c7b3          	xor	a5,a5,a0
    1b34:	01079513          	slli	a0,a5,0x10
    1b38:	0ff77713          	zext.b	a4,a4
    1b3c:	00165613          	srli	a2,a2,0x1
    1b40:	01055513          	srli	a0,a0,0x10
    1b44:	fc071ae3          	bnez	a4,1b18 <crcu16+0x18>
    1b48:	ffffa637          	lui	a2,0xffffa
    1b4c:	0086d693          	srli	a3,a3,0x8
    1b50:	00800713          	li	a4,8
    1b54:	00160613          	addi	a2,a2,1 # ffffa001 <__stack_top+0xfffe6001>
    1b58:	00a6c7b3          	xor	a5,a3,a0
    1b5c:	0017f793          	andi	a5,a5,1
    1b60:	40f007b3          	neg	a5,a5
    1b64:	00155513          	srli	a0,a0,0x1
    1b68:	00c7f7b3          	and	a5,a5,a2
    1b6c:	fff70713          	addi	a4,a4,-1
    1b70:	00a7c7b3          	xor	a5,a5,a0
    1b74:	01079513          	slli	a0,a5,0x10
    1b78:	0ff77713          	zext.b	a4,a4
    1b7c:	0016d693          	srli	a3,a3,0x1
    1b80:	01055513          	srli	a0,a0,0x10
    1b84:	fc071ae3          	bnez	a4,1b58 <crcu16+0x58>
    1b88:	00008067          	ret

00001b8c <crcu32>:
    1b8c:	00050693          	mv	a3,a0
    1b90:	ffffa837          	lui	a6,0xffffa
    1b94:	01069613          	slli	a2,a3,0x10
    1b98:	00058513          	mv	a0,a1
    1b9c:	01065613          	srli	a2,a2,0x10
    1ba0:	0ff6f593          	zext.b	a1,a3
    1ba4:	00800713          	li	a4,8
    1ba8:	00180813          	addi	a6,a6,1 # ffffa001 <__stack_top+0xfffe6001>
    1bac:	00a5c7b3          	xor	a5,a1,a0
    1bb0:	0017f793          	andi	a5,a5,1
    1bb4:	40f007b3          	neg	a5,a5
    1bb8:	00155513          	srli	a0,a0,0x1
    1bbc:	0107f7b3          	and	a5,a5,a6
    1bc0:	fff70713          	addi	a4,a4,-1
    1bc4:	00a7c7b3          	xor	a5,a5,a0
    1bc8:	01079513          	slli	a0,a5,0x10
    1bcc:	0ff77713          	zext.b	a4,a4
    1bd0:	0015d593          	srli	a1,a1,0x1
    1bd4:	01055513          	srli	a0,a0,0x10
    1bd8:	fc071ae3          	bnez	a4,1bac <crcu32+0x20>
    1bdc:	ffffa5b7          	lui	a1,0xffffa
    1be0:	00865613          	srli	a2,a2,0x8
    1be4:	00800713          	li	a4,8
    1be8:	00158593          	addi	a1,a1,1 # ffffa001 <__stack_top+0xfffe6001>
    1bec:	00a647b3          	xor	a5,a2,a0
    1bf0:	0017f793          	andi	a5,a5,1
    1bf4:	40f007b3          	neg	a5,a5
    1bf8:	00155513          	srli	a0,a0,0x1
    1bfc:	00b7f7b3          	and	a5,a5,a1
    1c00:	fff70713          	addi	a4,a4,-1
    1c04:	00a7c7b3          	xor	a5,a5,a0
    1c08:	01079513          	slli	a0,a5,0x10
    1c0c:	0ff77713          	zext.b	a4,a4
    1c10:	00165613          	srli	a2,a2,0x1
    1c14:	01055513          	srli	a0,a0,0x10
    1c18:	fc071ae3          	bnez	a4,1bec <crcu32+0x60>
    1c1c:	0106d613          	srli	a2,a3,0x10
    1c20:	ffffa5b7          	lui	a1,0xffffa
    1c24:	00060693          	mv	a3,a2
    1c28:	00800713          	li	a4,8
    1c2c:	0ff67613          	zext.b	a2,a2
    1c30:	00158593          	addi	a1,a1,1 # ffffa001 <__stack_top+0xfffe6001>
    1c34:	00a647b3          	xor	a5,a2,a0
    1c38:	0017f793          	andi	a5,a5,1
    1c3c:	40f007b3          	neg	a5,a5
    1c40:	00155513          	srli	a0,a0,0x1
    1c44:	00b7f7b3          	and	a5,a5,a1
    1c48:	fff70713          	addi	a4,a4,-1
    1c4c:	00a7c7b3          	xor	a5,a5,a0
    1c50:	01079513          	slli	a0,a5,0x10
    1c54:	0ff77713          	zext.b	a4,a4
    1c58:	00165613          	srli	a2,a2,0x1
    1c5c:	01055513          	srli	a0,a0,0x10
    1c60:	fc071ae3          	bnez	a4,1c34 <crcu32+0xa8>
    1c64:	ffffa637          	lui	a2,0xffffa
    1c68:	0086d693          	srli	a3,a3,0x8
    1c6c:	00800713          	li	a4,8
    1c70:	00160613          	addi	a2,a2,1 # ffffa001 <__stack_top+0xfffe6001>
    1c74:	00a6c7b3          	xor	a5,a3,a0
    1c78:	0017f793          	andi	a5,a5,1
    1c7c:	40f007b3          	neg	a5,a5
    1c80:	00155513          	srli	a0,a0,0x1
    1c84:	00c7f7b3          	and	a5,a5,a2
    1c88:	fff70713          	addi	a4,a4,-1
    1c8c:	00a7c7b3          	xor	a5,a5,a0
    1c90:	01079513          	slli	a0,a5,0x10
    1c94:	0ff77713          	zext.b	a4,a4
    1c98:	0016d693          	srli	a3,a3,0x1
    1c9c:	01055513          	srli	a0,a0,0x10
    1ca0:	fc071ae3          	bnez	a4,1c74 <crcu32+0xe8>
    1ca4:	00008067          	ret

00001ca8 <crc16>:
    1ca8:	00050693          	mv	a3,a0
    1cac:	01069613          	slli	a2,a3,0x10
    1cb0:	ffffa837          	lui	a6,0xffffa
    1cb4:	00058513          	mv	a0,a1
    1cb8:	01065613          	srli	a2,a2,0x10
    1cbc:	0ff6f693          	zext.b	a3,a3
    1cc0:	00800713          	li	a4,8
    1cc4:	00180813          	addi	a6,a6,1 # ffffa001 <__stack_top+0xfffe6001>
    1cc8:	00a6c7b3          	xor	a5,a3,a0
    1ccc:	0017f793          	andi	a5,a5,1
    1cd0:	40f007b3          	neg	a5,a5
    1cd4:	00155513          	srli	a0,a0,0x1
    1cd8:	0107f7b3          	and	a5,a5,a6
    1cdc:	fff70713          	addi	a4,a4,-1
    1ce0:	00a7c7b3          	xor	a5,a5,a0
    1ce4:	01079513          	slli	a0,a5,0x10
    1ce8:	0ff77713          	zext.b	a4,a4
    1cec:	0016d693          	srli	a3,a3,0x1
    1cf0:	01055513          	srli	a0,a0,0x10
    1cf4:	fc071ae3          	bnez	a4,1cc8 <crc16+0x20>
    1cf8:	ffffa5b7          	lui	a1,0xffffa
    1cfc:	00865693          	srli	a3,a2,0x8
    1d00:	00800713          	li	a4,8
    1d04:	00158593          	addi	a1,a1,1 # ffffa001 <__stack_top+0xfffe6001>
    1d08:	00a6c7b3          	xor	a5,a3,a0
    1d0c:	0017f793          	andi	a5,a5,1
    1d10:	40f007b3          	neg	a5,a5
    1d14:	00155513          	srli	a0,a0,0x1
    1d18:	00b7f7b3          	and	a5,a5,a1
    1d1c:	fff70713          	addi	a4,a4,-1
    1d20:	00a7c7b3          	xor	a5,a5,a0
    1d24:	01079513          	slli	a0,a5,0x10
    1d28:	0ff77713          	zext.b	a4,a4
    1d2c:	0016d693          	srli	a3,a3,0x1
    1d30:	01055513          	srli	a0,a0,0x10
    1d34:	fc071ae3          	bnez	a4,1d08 <crc16+0x60>
    1d38:	00008067          	ret

00001d3c <check_data_types>:
    1d3c:	00000513          	li	a0,0
    1d40:	00008067          	ret

00001d44 <iterate>:
    1d44:	ff010113          	addi	sp,sp,-16
    1d48:	01212023          	sw	s2,0(sp)
    1d4c:	01c52903          	lw	s2,28(a0)
    1d50:	00112623          	sw	ra,12(sp)
    1d54:	02052c23          	sw	zero,56(a0)
    1d58:	02052e23          	sw	zero,60(a0)
    1d5c:	04090e63          	beqz	s2,1db8 <iterate+0x74>
    1d60:	00812423          	sw	s0,8(sp)
    1d64:	00912223          	sw	s1,4(sp)
    1d68:	00050413          	mv	s0,a0
    1d6c:	00000493          	li	s1,0
    1d70:	00100593          	li	a1,1
    1d74:	00040513          	mv	a0,s0
    1d78:	f2cfe0ef          	jal	4a4 <core_bench_list>
    1d7c:	03845583          	lhu	a1,56(s0)
    1d80:	d81ff0ef          	jal	1b00 <crcu16>
    1d84:	02a41c23          	sh	a0,56(s0)
    1d88:	fff00593          	li	a1,-1
    1d8c:	00040513          	mv	a0,s0
    1d90:	f14fe0ef          	jal	4a4 <core_bench_list>
    1d94:	03845583          	lhu	a1,56(s0)
    1d98:	d69ff0ef          	jal	1b00 <crcu16>
    1d9c:	02a41c23          	sh	a0,56(s0)
    1da0:	00049463          	bnez	s1,1da8 <iterate+0x64>
    1da4:	02a41d23          	sh	a0,58(s0)
    1da8:	00148493          	addi	s1,s1,1
    1dac:	fc9912e3          	bne	s2,s1,1d70 <iterate+0x2c>
    1db0:	00812403          	lw	s0,8(sp)
    1db4:	00412483          	lw	s1,4(sp)
    1db8:	00c12083          	lw	ra,12(sp)
    1dbc:	00012903          	lw	s2,0(sp)
    1dc0:	00000513          	li	a0,0
    1dc4:	01010113          	addi	sp,sp,16
    1dc8:	00008067          	ret

00001dcc <main>:
    1dcc:	81010113          	addi	sp,sp,-2032
    1dd0:	00001737          	lui	a4,0x1
    1dd4:	7e112623          	sw	ra,2028(sp)
    1dd8:	7e812423          	sw	s0,2024(sp)
    1ddc:	82070693          	addi	a3,a4,-2016 # 820 <core_list_init+0xd8>
    1de0:	7e912223          	sw	s1,2020(sp)
    1de4:	7f212023          	sw	s2,2016(sp)
    1de8:	7d312e23          	sw	s3,2012(sp)
    1dec:	7d412c23          	sw	s4,2008(sp)
    1df0:	7d512a23          	sw	s5,2004(sp)
    1df4:	7d612823          	sw	s6,2000(sp)
    1df8:	7d712623          	sw	s7,1996(sp)
    1dfc:	7d812423          	sw	s8,1992(sp)
    1e00:	7d912223          	sw	s9,1988(sp)
    1e04:	7da12023          	sw	s10,1984(sp)
    1e08:	fffff7b7          	lui	a5,0xfffff
    1e0c:	f9010113          	addi	sp,sp,-112
    1e10:	00f686b3          	add	a3,a3,a5
    1e14:	01010793          	addi	a5,sp,16
    1e18:	00f687b3          	add	a5,a3,a5
    1e1c:	fffff637          	lui	a2,0xfffff
    1e20:	00f12623          	sw	a5,12(sp)
    1e24:	7e860613          	addi	a2,a2,2024 # fffff7e8 <__stack_top+0xfffeb7e8>
    1e28:	82070793          	addi	a5,a4,-2016
    1e2c:	01010693          	addi	a3,sp,16
    1e30:	00c787b3          	add	a5,a5,a2
    1e34:	fffff5b7          	lui	a1,0xfffff
    1e38:	00d78633          	add	a2,a5,a3
    1e3c:	7e458593          	addi	a1,a1,2020 # fffff7e4 <__stack_top+0xfffeb7e4>
    1e40:	82070793          	addi	a5,a4,-2016
    1e44:	00b787b3          	add	a5,a5,a1
    1e48:	00d785b3          	add	a1,a5,a3
    1e4c:	00c12783          	lw	a5,12(sp)
    1e50:	05e10513          	addi	a0,sp,94
    1e54:	00700413          	li	s0,7
    1e58:	7e07a223          	sw	zero,2020(a5) # fffff7e4 <__stack_top+0xfffeb7e4>
    1e5c:	45d000ef          	jal	2ab8 <portable_init>
    1e60:	00100513          	li	a0,1
    1e64:	bf1ff0ef          	jal	1a54 <get_seed_32>
    1e68:	00c12703          	lw	a4,12(sp)
    1e6c:	00050793          	mv	a5,a0
    1e70:	00200513          	li	a0,2
    1e74:	7ef71623          	sh	a5,2028(a4)
    1e78:	bddff0ef          	jal	1a54 <get_seed_32>
    1e7c:	00c12703          	lw	a4,12(sp)
    1e80:	00050793          	mv	a5,a0
    1e84:	00300513          	li	a0,3
    1e88:	7ef71723          	sh	a5,2030(a4)
    1e8c:	bc9ff0ef          	jal	1a54 <get_seed_32>
    1e90:	00c12703          	lw	a4,12(sp)
    1e94:	00050793          	mv	a5,a0
    1e98:	00400513          	li	a0,4
    1e9c:	7ef71823          	sh	a5,2032(a4)
    1ea0:	bb5ff0ef          	jal	1a54 <get_seed_32>
    1ea4:	00050793          	mv	a5,a0
    1ea8:	00500513          	li	a0,5
    1eac:	02f12c23          	sw	a5,56(sp)
    1eb0:	ba5ff0ef          	jal	1a54 <get_seed_32>
    1eb4:	00050463          	beqz	a0,1ebc <main+0xf0>
    1eb8:	00050413          	mv	s0,a0
    1ebc:	00001737          	lui	a4,0x1
    1ec0:	fffff7b7          	lui	a5,0xfffff
    1ec4:	82070713          	addi	a4,a4,-2016 # 820 <core_list_init+0xd8>
    1ec8:	00f70733          	add	a4,a4,a5
    1ecc:	01010793          	addi	a5,sp,16
    1ed0:	00f707b3          	add	a5,a4,a5
    1ed4:	00f12623          	sw	a5,12(sp)
    1ed8:	7ec7a783          	lw	a5,2028(a5) # fffff7ec <__stack_top+0xfffeb7ec>
    1edc:	02812e23          	sw	s0,60(sp)
    1ee0:	2c079c63          	bnez	a5,21b8 <main+0x3ec>
    1ee4:	00c12783          	lw	a5,12(sp)
    1ee8:	7f079783          	lh	a5,2032(a5)
    1eec:	48078063          	beqz	a5,236c <main+0x5a0>
    1ef0:	000016b7          	lui	a3,0x1
    1ef4:	fffff737          	lui	a4,0xfffff
    1ef8:	82068693          	addi	a3,a3,-2016 # 820 <core_list_init+0xd8>
    1efc:	00e686b3          	add	a3,a3,a4
    1f00:	01010713          	addi	a4,sp,16
    1f04:	00e68733          	add	a4,a3,a4
    1f08:	06010913          	addi	s2,sp,96
    1f0c:	00247793          	andi	a5,s0,2
    1f10:	00147593          	andi	a1,s0,1
    1f14:	00f037b3          	snez	a5,a5
    1f18:	00e12623          	sw	a4,12(sp)
    1f1c:	7f272a23          	sw	s2,2036(a4) # fffff7f4 <__stack_top+0xfffeb7f4>
    1f20:	04011e23          	sh	zero,92(sp)
    1f24:	00447713          	andi	a4,s0,4
    1f28:	00f585b3          	add	a1,a1,a5
    1f2c:	00070863          	beqz	a4,1f3c <main+0x170>
    1f30:	00158593          	addi	a1,a1,1
    1f34:	01059593          	slli	a1,a1,0x10
    1f38:	0105d593          	srli	a1,a1,0x10
    1f3c:	7d000513          	li	a0,2000
    1f40:	18c010ef          	jal	30cc <__hidden___udivsi3>
    1f44:	fffff7b7          	lui	a5,0xfffff
    1f48:	00001737          	lui	a4,0x1
    1f4c:	7ec78793          	addi	a5,a5,2028 # fffff7ec <__stack_top+0xfffeb7ec>
    1f50:	82070713          	addi	a4,a4,-2016 # 820 <core_list_init+0xd8>
    1f54:	00f70733          	add	a4,a4,a5
    1f58:	01010793          	addi	a5,sp,16
    1f5c:	00050a13          	mv	s4,a0
    1f60:	02a12a23          	sw	a0,52(sp)
    1f64:	00f704b3          	add	s1,a4,a5
    1f68:	00000993          	li	s3,0
    1f6c:	00000a93          	li	s5,0
    1f70:	00100b93          	li	s7,1
    1f74:	00300b13          	li	s6,3
    1f78:	013b97b3          	sll	a5,s7,s3
    1f7c:	0087f7b3          	and	a5,a5,s0
    1f80:	20079a63          	bnez	a5,2194 <main+0x3c8>
    1f84:	00198993          	addi	s3,s3,1
    1f88:	00448493          	addi	s1,s1,4
    1f8c:	ff6996e3          	bne	s3,s6,1f78 <main+0x1ac>
    1f90:	000016b7          	lui	a3,0x1
    1f94:	fffff737          	lui	a4,0xfffff
    1f98:	03c12783          	lw	a5,60(sp)
    1f9c:	82068693          	addi	a3,a3,-2016 # 820 <core_list_init+0xd8>
    1fa0:	00e686b3          	add	a3,a3,a4
    1fa4:	01010713          	addi	a4,sp,16
    1fa8:	00e68733          	add	a4,a3,a4
    1fac:	00e12623          	sw	a4,12(sp)
    1fb0:	0017f713          	andi	a4,a5,1
    1fb4:	02070063          	beqz	a4,1fd4 <main+0x208>
    1fb8:	00c12783          	lw	a5,12(sp)
    1fbc:	03412503          	lw	a0,52(sp)
    1fc0:	7ec79603          	lh	a2,2028(a5)
    1fc4:	7f87a583          	lw	a1,2040(a5)
    1fc8:	f80fe0ef          	jal	748 <core_list_init>
    1fcc:	03c12783          	lw	a5,60(sp)
    1fd0:	04a12023          	sw	a0,64(sp)
    1fd4:	0027f713          	andi	a4,a5,2
    1fd8:	16071a63          	bnez	a4,214c <main+0x380>
    1fdc:	0047f793          	andi	a5,a5,4
    1fe0:	02078863          	beqz	a5,2010 <main+0x244>
    1fe4:	00001737          	lui	a4,0x1
    1fe8:	fffff7b7          	lui	a5,0xfffff
    1fec:	82070713          	addi	a4,a4,-2016 # 820 <core_list_init+0xd8>
    1ff0:	00f70733          	add	a4,a4,a5
    1ff4:	01010793          	addi	a5,sp,16
    1ff8:	00f707b3          	add	a5,a4,a5
    1ffc:	03012603          	lw	a2,48(sp)
    2000:	7ec79583          	lh	a1,2028(a5) # fffff7ec <__stack_top+0xfffeb7ec>
    2004:	03412503          	lw	a0,52(sp)
    2008:	00f12623          	sw	a5,12(sp)
    200c:	c74ff0ef          	jal	1480 <core_init_state>
    2010:	03812783          	lw	a5,56(sp)
    2014:	06079c63          	bnez	a5,208c <main+0x2c0>
    2018:	00100713          	li	a4,1
    201c:	fffff7b7          	lui	a5,0xfffff
    2020:	02e12c23          	sw	a4,56(sp)
    2024:	00001737          	lui	a4,0x1
    2028:	7ec78793          	addi	a5,a5,2028 # fffff7ec <__stack_top+0xfffeb7ec>
    202c:	82070713          	addi	a4,a4,-2016 # 820 <core_list_init+0xd8>
    2030:	00f70733          	add	a4,a4,a5
    2034:	01010793          	addi	a5,sp,16
    2038:	00f707b3          	add	a5,a4,a5
    203c:	00f12623          	sw	a5,12(sp)
    2040:	03812703          	lw	a4,56(sp)
    2044:	00271793          	slli	a5,a4,0x2
    2048:	00e787b3          	add	a5,a5,a4
    204c:	00179793          	slli	a5,a5,0x1
    2050:	02f12c23          	sw	a5,56(sp)
    2054:	20d000ef          	jal	2a60 <start_time>
    2058:	00c12503          	lw	a0,12(sp)
    205c:	ce9ff0ef          	jal	1d44 <iterate>
    2060:	211000ef          	jal	2a70 <stop_time>
    2064:	21d000ef          	jal	2a80 <get_time>
    2068:	231000ef          	jal	2a98 <time_in_secs>
    206c:	fc050ae3          	beqz	a0,2040 <main+0x274>
    2070:	00050593          	mv	a1,a0
    2074:	00a00513          	li	a0,10
    2078:	054010ef          	jal	30cc <__hidden___udivsi3>
    207c:	03812583          	lw	a1,56(sp)
    2080:	00150513          	addi	a0,a0,1
    2084:	01c010ef          	jal	30a0 <__mulsi3>
    2088:	02a12c23          	sw	a0,56(sp)
    208c:	1d5000ef          	jal	2a60 <start_time>
    2090:	00001437          	lui	s0,0x1
    2094:	fffff537          	lui	a0,0xfffff
    2098:	7ec50513          	addi	a0,a0,2028 # fffff7ec <__stack_top+0xfffeb7ec>
    209c:	82040793          	addi	a5,s0,-2016 # 820 <core_list_init+0xd8>
    20a0:	00a787b3          	add	a5,a5,a0
    20a4:	01010713          	addi	a4,sp,16
    20a8:	00e78533          	add	a0,a5,a4
    20ac:	c99ff0ef          	jal	1d44 <iterate>
    20b0:	1c1000ef          	jal	2a70 <stop_time>
    20b4:	1cd000ef          	jal	2a80 <get_time>
    20b8:	fffff7b7          	lui	a5,0xfffff
    20bc:	82040713          	addi	a4,s0,-2016
    20c0:	00f70733          	add	a4,a4,a5
    20c4:	01010793          	addi	a5,sp,16
    20c8:	00f707b3          	add	a5,a4,a5
    20cc:	00050913          	mv	s2,a0
    20d0:	7ec79503          	lh	a0,2028(a5) # fffff7ec <__stack_top+0xfffeb7ec>
    20d4:	00000593          	li	a1,0
    20d8:	00f12623          	sw	a5,12(sp)
    20dc:	bcdff0ef          	jal	1ca8 <crc16>
    20e0:	00c12783          	lw	a5,12(sp)
    20e4:	00050593          	mv	a1,a0
    20e8:	7ee79503          	lh	a0,2030(a5)
    20ec:	bbdff0ef          	jal	1ca8 <crc16>
    20f0:	00c12783          	lw	a5,12(sp)
    20f4:	00050593          	mv	a1,a0
    20f8:	7f079503          	lh	a0,2032(a5)
    20fc:	badff0ef          	jal	1ca8 <crc16>
    2100:	00050593          	mv	a1,a0
    2104:	03411503          	lh	a0,52(sp)
    2108:	ba1ff0ef          	jal	1ca8 <crc16>
    210c:	000087b7          	lui	a5,0x8
    2110:	b0578793          	addi	a5,a5,-1275 # 7b05 <__modsi3+0x49bd>
    2114:	00050993          	mv	s3,a0
    2118:	60f50863          	beq	a0,a5,2728 <main+0x95c>
    211c:	0ca7f663          	bgeu	a5,a0,21e8 <main+0x41c>
    2120:	000097b7          	lui	a5,0x9
    2124:	a0278793          	addi	a5,a5,-1534 # 8a02 <__modsi3+0x58ba>
    2128:	5ef50663          	beq	a0,a5,2714 <main+0x948>
    212c:	0000f7b7          	lui	a5,0xf
    2130:	9f578793          	addi	a5,a5,-1547 # e9f5 <__modsi3+0xb8ad>
    2134:	24f51463          	bne	a0,a5,237c <main+0x5b0>
    2138:	00010537          	lui	a0,0x10
    213c:	15850513          	addi	a0,a0,344 # 10158 <seed3_volatile+0x144>
    2140:	1d1000ef          	jal	2b10 <ee_printf>
    2144:	00300793          	li	a5,3
    2148:	0c80006f          	j	2210 <main+0x444>
    214c:	00001737          	lui	a4,0x1
    2150:	fffff7b7          	lui	a5,0xfffff
    2154:	82070713          	addi	a4,a4,-2016 # 820 <core_list_init+0xd8>
    2158:	00f70733          	add	a4,a4,a5
    215c:	01010793          	addi	a5,sp,16
    2160:	00f707b3          	add	a5,a4,a5
    2164:	00f12623          	sw	a5,12(sp)
    2168:	00c12703          	lw	a4,12(sp)
    216c:	7ee79783          	lh	a5,2030(a5) # fffff7ee <__stack_top+0xfffeb7ee>
    2170:	03412503          	lw	a0,52(sp)
    2174:	7ec71603          	lh	a2,2028(a4)
    2178:	7fc72583          	lw	a1,2044(a4)
    217c:	01079793          	slli	a5,a5,0x10
    2180:	00c7e633          	or	a2,a5,a2
    2184:	04410693          	addi	a3,sp,68
    2188:	f88fe0ef          	jal	910 <core_init_matrix>
    218c:	03c12783          	lw	a5,60(sp)
    2190:	e4dff06f          	j	1fdc <main+0x210>
    2194:	000a8513          	mv	a0,s5
    2198:	000a0593          	mv	a1,s4
    219c:	705000ef          	jal	30a0 <__mulsi3>
    21a0:	001a8a93          	addi	s5,s5,1
    21a4:	00a90533          	add	a0,s2,a0
    21a8:	010a9a93          	slli	s5,s5,0x10
    21ac:	00a4a623          	sw	a0,12(s1)
    21b0:	010ada93          	srli	s5,s5,0x10
    21b4:	dd1ff06f          	j	1f84 <main+0x1b8>
    21b8:	00100713          	li	a4,1
    21bc:	d2e79ae3          	bne	a5,a4,1ef0 <main+0x124>
    21c0:	00c12783          	lw	a5,12(sp)
    21c4:	7f079783          	lh	a5,2032(a5)
    21c8:	d20794e3          	bnez	a5,1ef0 <main+0x124>
    21cc:	00c12703          	lw	a4,12(sp)
    21d0:	341537b7          	lui	a5,0x34153
    21d4:	41578793          	addi	a5,a5,1045 # 34153415 <__stack_top+0x3413f415>
    21d8:	7ef72623          	sw	a5,2028(a4)
    21dc:	06600793          	li	a5,102
    21e0:	7ef71823          	sh	a5,2032(a4)
    21e4:	d0dff06f          	j	1ef0 <main+0x124>
    21e8:	000027b7          	lui	a5,0x2
    21ec:	8f278793          	addi	a5,a5,-1806 # 18f2 <core_bench_state+0x3e>
    21f0:	54f50663          	beq	a0,a5,273c <main+0x970>
    21f4:	000057b7          	lui	a5,0x5
    21f8:	eaf78793          	addi	a5,a5,-337 # 4eaf <__modsi3+0x1d67>
    21fc:	18f51063          	bne	a0,a5,237c <main+0x5b0>
    2200:	00010537          	lui	a0,0x10
    2204:	12450513          	addi	a0,a0,292 # 10124 <seed3_volatile+0x110>
    2208:	109000ef          	jal	2b10 <ee_printf>
    220c:	00200793          	li	a5,2
    2210:	00010c37          	lui	s8,0x10
    2214:	00cc2703          	lw	a4,12(s8) # 1000c <default_num_contexts>
    2218:	52070c63          	beqz	a4,2750 <main+0x984>
    221c:	000016b7          	lui	a3,0x1
    2220:	fffff737          	lui	a4,0xfffff
    2224:	82068693          	addi	a3,a3,-2016 # 820 <core_list_init+0xd8>
    2228:	00e686b3          	add	a3,a3,a4
    222c:	00010cb7          	lui	s9,0x10
    2230:	01010713          	addi	a4,sp,16
    2234:	00179793          	slli	a5,a5,0x1
    2238:	00e68733          	add	a4,a3,a4
    223c:	5a0c8c93          	addi	s9,s9,1440 # 105a0 <list_known_crc>
    2240:	00000d13          	li	s10,0
    2244:	00000493          	li	s1,0
    2248:	00e12623          	sw	a4,12(sp)
    224c:	00fc8cb3          	add	s9,s9,a5
    2250:	00010b37          	lui	s6,0x10
    2254:	00010ab7          	lui	s5,0x10
    2258:	00010a37          	lui	s4,0x10
    225c:	0400006f          	j	229c <main+0x4d0>
    2260:	00c12783          	lw	a5,12(sp)
    2264:	00878433          	add	s0,a5,s0
    2268:	000017b7          	lui	a5,0x1
    226c:	008787b3          	add	a5,a5,s0
    2270:	82c7d783          	lhu	a5,-2004(a5) # 82c <core_list_init+0xe4>
    2274:	00148493          	addi	s1,s1,1
    2278:	00cc2703          	lw	a4,12(s8)
    227c:	01a787b3          	add	a5,a5,s10
    2280:	01049493          	slli	s1,s1,0x10
    2284:	01079413          	slli	s0,a5,0x10
    2288:	01079d13          	slli	s10,a5,0x10
    228c:	0104d493          	srli	s1,s1,0x10
    2290:	01045413          	srli	s0,s0,0x10
    2294:	410d5d13          	srai	s10,s10,0x10
    2298:	0ee4f863          	bgeu	s1,a4,2388 <main+0x5bc>
    229c:	00c12703          	lw	a4,12(sp)
    22a0:	00449413          	slli	s0,s1,0x4
    22a4:	009407b3          	add	a5,s0,s1
    22a8:	00279793          	slli	a5,a5,0x2
    22ac:	00f707b3          	add	a5,a4,a5
    22b0:	00001bb7          	lui	s7,0x1
    22b4:	00fb8bb3          	add	s7,s7,a5
    22b8:	80cba783          	lw	a5,-2036(s7) # 80c <core_list_init+0xc4>
    22bc:	820b9623          	sh	zero,-2004(s7)
    22c0:	0017f713          	andi	a4,a5,1
    22c4:	02070663          	beqz	a4,22f0 <main+0x524>
    22c8:	826bd603          	lhu	a2,-2010(s7)
    22cc:	000cd683          	lhu	a3,0(s9)
    22d0:	02d60063          	beq	a2,a3,22f0 <main+0x524>
    22d4:	00048593          	mv	a1,s1
    22d8:	1b4b0513          	addi	a0,s6,436 # 101b4 <seed3_volatile+0x1a0>
    22dc:	035000ef          	jal	2b10 <ee_printf>
    22e0:	82cbd703          	lhu	a4,-2004(s7)
    22e4:	80cba783          	lw	a5,-2036(s7)
    22e8:	00170713          	addi	a4,a4,1 # fffff001 <__stack_top+0xfffeb001>
    22ec:	82eb9623          	sh	a4,-2004(s7)
    22f0:	0027f713          	andi	a4,a5,2
    22f4:	04070263          	beqz	a4,2338 <main+0x56c>
    22f8:	00c12683          	lw	a3,12(sp)
    22fc:	00940733          	add	a4,s0,s1
    2300:	00271713          	slli	a4,a4,0x2
    2304:	00e68733          	add	a4,a3,a4
    2308:	00001bb7          	lui	s7,0x1
    230c:	00eb8bb3          	add	s7,s7,a4
    2310:	828bd603          	lhu	a2,-2008(s7) # 828 <core_list_init+0xe0>
    2314:	00ccd683          	lhu	a3,12(s9)
    2318:	02d60063          	beq	a2,a3,2338 <main+0x56c>
    231c:	00048593          	mv	a1,s1
    2320:	1e4a8513          	addi	a0,s5,484 # 101e4 <seed3_volatile+0x1d0>
    2324:	7ec000ef          	jal	2b10 <ee_printf>
    2328:	82cbd703          	lhu	a4,-2004(s7)
    232c:	80cba783          	lw	a5,-2036(s7)
    2330:	00170713          	addi	a4,a4,1
    2334:	82eb9623          	sh	a4,-2004(s7)
    2338:	00940433          	add	s0,s0,s1
    233c:	0047f793          	andi	a5,a5,4
    2340:	00241413          	slli	s0,s0,0x2
    2344:	f0078ee3          	beqz	a5,2260 <main+0x494>
    2348:	00c12783          	lw	a5,12(sp)
    234c:	018cd683          	lhu	a3,24(s9)
    2350:	00878433          	add	s0,a5,s0
    2354:	000017b7          	lui	a5,0x1
    2358:	00878433          	add	s0,a5,s0
    235c:	82a45603          	lhu	a2,-2006(s0)
    2360:	32d61263          	bne	a2,a3,2684 <main+0x8b8>
    2364:	82c45783          	lhu	a5,-2004(s0)
    2368:	f0dff06f          	j	2274 <main+0x4a8>
    236c:	00c12703          	lw	a4,12(sp)
    2370:	06600793          	li	a5,102
    2374:	7ef71823          	sh	a5,2032(a4)
    2378:	b79ff06f          	j	1ef0 <main+0x124>
    237c:	00010437          	lui	s0,0x10
    2380:	fff40413          	addi	s0,s0,-1 # ffff <__modsi3+0xceb7>
    2384:	00010c37          	lui	s8,0x10
    2388:	9b5ff0ef          	jal	1d3c <check_data_types>
    238c:	03412583          	lw	a1,52(sp)
    2390:	008504b3          	add	s1,a0,s0
    2394:	00010537          	lui	a0,0x10
    2398:	24850513          	addi	a0,a0,584 # 10248 <seed3_volatile+0x234>
    239c:	774000ef          	jal	2b10 <ee_printf>
    23a0:	00010537          	lui	a0,0x10
    23a4:	00090593          	mv	a1,s2
    23a8:	26050513          	addi	a0,a0,608 # 10260 <seed3_volatile+0x24c>
    23ac:	764000ef          	jal	2b10 <ee_printf>
    23b0:	00090513          	mv	a0,s2
    23b4:	6e4000ef          	jal	2a98 <time_in_secs>
    23b8:	00050593          	mv	a1,a0
    23bc:	00010537          	lui	a0,0x10
    23c0:	27850513          	addi	a0,a0,632 # 10278 <seed3_volatile+0x264>
    23c4:	74c000ef          	jal	2b10 <ee_printf>
    23c8:	01049493          	slli	s1,s1,0x10
    23cc:	00090513          	mv	a0,s2
    23d0:	0104d493          	srli	s1,s1,0x10
    23d4:	6c4000ef          	jal	2a98 <time_in_secs>
    23d8:	30051263          	bnez	a0,26dc <main+0x910>
    23dc:	00090513          	mv	a0,s2
    23e0:	6b8000ef          	jal	2a98 <time_in_secs>
    23e4:	00900793          	li	a5,9
    23e8:	2ea7f063          	bgeu	a5,a0,26c8 <main+0x8fc>
    23ec:	00cc2583          	lw	a1,12(s8) # 1000c <default_num_contexts>
    23f0:	03812503          	lw	a0,56(sp)
    23f4:	01049493          	slli	s1,s1,0x10
    23f8:	4104d493          	srai	s1,s1,0x10
    23fc:	4a5000ef          	jal	30a0 <__mulsi3>
    2400:	00050593          	mv	a1,a0
    2404:	00010537          	lui	a0,0x10
    2408:	2e850513          	addi	a0,a0,744 # 102e8 <seed3_volatile+0x2d4>
    240c:	704000ef          	jal	2b10 <ee_printf>
    2410:	000105b7          	lui	a1,0x10
    2414:	00010537          	lui	a0,0x10
    2418:	30058593          	addi	a1,a1,768 # 10300 <seed3_volatile+0x2ec>
    241c:	30c50513          	addi	a0,a0,780 # 1030c <seed3_volatile+0x2f8>
    2420:	6f0000ef          	jal	2b10 <ee_printf>
    2424:	000105b7          	lui	a1,0x10
    2428:	00010537          	lui	a0,0x10
    242c:	32458593          	addi	a1,a1,804 # 10324 <seed3_volatile+0x310>
    2430:	35050513          	addi	a0,a0,848 # 10350 <seed3_volatile+0x33c>
    2434:	6dc000ef          	jal	2b10 <ee_printf>
    2438:	000105b7          	lui	a1,0x10
    243c:	00010537          	lui	a0,0x10
    2440:	36858593          	addi	a1,a1,872 # 10368 <seed3_volatile+0x354>
    2444:	37050513          	addi	a0,a0,880 # 10370 <seed3_volatile+0x35c>
    2448:	6c8000ef          	jal	2b10 <ee_printf>
    244c:	00010537          	lui	a0,0x10
    2450:	00098593          	mv	a1,s3
    2454:	38850513          	addi	a0,a0,904 # 10388 <seed3_volatile+0x374>
    2458:	6b8000ef          	jal	2b10 <ee_printf>
    245c:	03c12783          	lw	a5,60(sp)
    2460:	0017f713          	andi	a4,a5,1
    2464:	06070a63          	beqz	a4,24d8 <main+0x70c>
    2468:	00cc2703          	lw	a4,12(s8)
    246c:	06070663          	beqz	a4,24d8 <main+0x70c>
    2470:	00001737          	lui	a4,0x1
    2474:	fffff7b7          	lui	a5,0xfffff
    2478:	82070713          	addi	a4,a4,-2016 # 820 <core_list_init+0xd8>
    247c:	00f70733          	add	a4,a4,a5
    2480:	01010793          	addi	a5,sp,16
    2484:	00f707b3          	add	a5,a4,a5
    2488:	00000413          	li	s0,0
    248c:	000109b7          	lui	s3,0x10
    2490:	00f12623          	sw	a5,12(sp)
    2494:	00001937          	lui	s2,0x1
    2498:	00c12703          	lw	a4,12(sp)
    249c:	00441793          	slli	a5,s0,0x4
    24a0:	008787b3          	add	a5,a5,s0
    24a4:	00279793          	slli	a5,a5,0x2
    24a8:	00f707b3          	add	a5,a4,a5
    24ac:	00f907b3          	add	a5,s2,a5
    24b0:	8267d603          	lhu	a2,-2010(a5) # ffffe826 <__stack_top+0xfffea826>
    24b4:	00040593          	mv	a1,s0
    24b8:	3a498513          	addi	a0,s3,932 # 103a4 <seed3_volatile+0x390>
    24bc:	654000ef          	jal	2b10 <ee_printf>
    24c0:	00140413          	addi	s0,s0,1
    24c4:	00cc2783          	lw	a5,12(s8)
    24c8:	01041413          	slli	s0,s0,0x10
    24cc:	01045413          	srli	s0,s0,0x10
    24d0:	fcf464e3          	bltu	s0,a5,2498 <main+0x6cc>
    24d4:	03c12783          	lw	a5,60(sp)
    24d8:	0027f713          	andi	a4,a5,2
    24dc:	06070a63          	beqz	a4,2550 <main+0x784>
    24e0:	00cc2703          	lw	a4,12(s8)
    24e4:	26070a63          	beqz	a4,2758 <main+0x98c>
    24e8:	00001737          	lui	a4,0x1
    24ec:	fffff7b7          	lui	a5,0xfffff
    24f0:	82070713          	addi	a4,a4,-2016 # 820 <core_list_init+0xd8>
    24f4:	00f70733          	add	a4,a4,a5
    24f8:	01010793          	addi	a5,sp,16
    24fc:	00f707b3          	add	a5,a4,a5
    2500:	00000413          	li	s0,0
    2504:	000109b7          	lui	s3,0x10
    2508:	00f12623          	sw	a5,12(sp)
    250c:	00001937          	lui	s2,0x1
    2510:	00c12703          	lw	a4,12(sp)
    2514:	00441793          	slli	a5,s0,0x4
    2518:	008787b3          	add	a5,a5,s0
    251c:	00279793          	slli	a5,a5,0x2
    2520:	00f707b3          	add	a5,a4,a5
    2524:	00f907b3          	add	a5,s2,a5
    2528:	8287d603          	lhu	a2,-2008(a5) # ffffe828 <__stack_top+0xfffea828>
    252c:	00040593          	mv	a1,s0
    2530:	3c098513          	addi	a0,s3,960 # 103c0 <seed3_volatile+0x3ac>
    2534:	5dc000ef          	jal	2b10 <ee_printf>
    2538:	00140413          	addi	s0,s0,1
    253c:	00cc2783          	lw	a5,12(s8)
    2540:	01041413          	slli	s0,s0,0x10
    2544:	01045413          	srli	s0,s0,0x10
    2548:	fcf464e3          	bltu	s0,a5,2510 <main+0x744>
    254c:	03c12783          	lw	a5,60(sp)
    2550:	0047f793          	andi	a5,a5,4
    2554:	00cc2703          	lw	a4,12(s8)
    2558:	06078663          	beqz	a5,25c4 <main+0x7f8>
    255c:	0c070663          	beqz	a4,2628 <main+0x85c>
    2560:	00001737          	lui	a4,0x1
    2564:	fffff7b7          	lui	a5,0xfffff
    2568:	82070713          	addi	a4,a4,-2016 # 820 <core_list_init+0xd8>
    256c:	00f70733          	add	a4,a4,a5
    2570:	01010793          	addi	a5,sp,16
    2574:	00f707b3          	add	a5,a4,a5
    2578:	00000413          	li	s0,0
    257c:	000109b7          	lui	s3,0x10
    2580:	00f12623          	sw	a5,12(sp)
    2584:	00001937          	lui	s2,0x1
    2588:	00c12703          	lw	a4,12(sp)
    258c:	00441793          	slli	a5,s0,0x4
    2590:	008787b3          	add	a5,a5,s0
    2594:	00279793          	slli	a5,a5,0x2
    2598:	00f707b3          	add	a5,a4,a5
    259c:	00f907b3          	add	a5,s2,a5
    25a0:	82a7d603          	lhu	a2,-2006(a5) # ffffe82a <__stack_top+0xfffea82a>
    25a4:	00040593          	mv	a1,s0
    25a8:	3dc98513          	addi	a0,s3,988 # 103dc <seed3_volatile+0x3c8>
    25ac:	564000ef          	jal	2b10 <ee_printf>
    25b0:	00140413          	addi	s0,s0,1
    25b4:	00cc2783          	lw	a5,12(s8)
    25b8:	01041413          	slli	s0,s0,0x10
    25bc:	01045413          	srli	s0,s0,0x10
    25c0:	fcf464e3          	bltu	s0,a5,2588 <main+0x7bc>
    25c4:	00001737          	lui	a4,0x1
    25c8:	00cc2783          	lw	a5,12(s8)
    25cc:	fffff937          	lui	s2,0xfffff
    25d0:	82070713          	addi	a4,a4,-2016 # 820 <core_list_init+0xd8>
    25d4:	01270733          	add	a4,a4,s2
    25d8:	01010693          	addi	a3,sp,16
    25dc:	00000413          	li	s0,0
    25e0:	00010a37          	lui	s4,0x10
    25e4:	00d70933          	add	s2,a4,a3
    25e8:	000019b7          	lui	s3,0x1
    25ec:	02078e63          	beqz	a5,2628 <main+0x85c>
    25f0:	00441793          	slli	a5,s0,0x4
    25f4:	008787b3          	add	a5,a5,s0
    25f8:	00279793          	slli	a5,a5,0x2
    25fc:	00f907b3          	add	a5,s2,a5
    2600:	00f987b3          	add	a5,s3,a5
    2604:	8247d603          	lhu	a2,-2012(a5)
    2608:	00040593          	mv	a1,s0
    260c:	3f8a0513          	addi	a0,s4,1016 # 103f8 <seed3_volatile+0x3e4>
    2610:	500000ef          	jal	2b10 <ee_printf>
    2614:	00140413          	addi	s0,s0,1
    2618:	00cc2783          	lw	a5,12(s8)
    261c:	01041413          	slli	s0,s0,0x10
    2620:	01045413          	srli	s0,s0,0x10
    2624:	fcf466e3          	bltu	s0,a5,25f0 <main+0x824>
    2628:	08048863          	beqz	s1,26b8 <main+0x8ec>
    262c:	06904e63          	bgtz	s1,26a8 <main+0x8dc>
    2630:	00010537          	lui	a0,0x10
    2634:	46050513          	addi	a0,a0,1120 # 10460 <seed3_volatile+0x44c>
    2638:	4d8000ef          	jal	2b10 <ee_printf>
    263c:	05e10513          	addi	a0,sp,94
    2640:	484000ef          	jal	2ac4 <portable_fini>
    2644:	07010113          	addi	sp,sp,112
    2648:	7ec12083          	lw	ra,2028(sp)
    264c:	7e812403          	lw	s0,2024(sp)
    2650:	7e412483          	lw	s1,2020(sp)
    2654:	7e012903          	lw	s2,2016(sp)
    2658:	7dc12983          	lw	s3,2012(sp)
    265c:	7d812a03          	lw	s4,2008(sp)
    2660:	7d412a83          	lw	s5,2004(sp)
    2664:	7d012b03          	lw	s6,2000(sp)
    2668:	7cc12b83          	lw	s7,1996(sp)
    266c:	7c812c03          	lw	s8,1992(sp)
    2670:	7c412c83          	lw	s9,1988(sp)
    2674:	7c012d03          	lw	s10,1984(sp)
    2678:	00000513          	li	a0,0
    267c:	7f010113          	addi	sp,sp,2032
    2680:	00008067          	ret
    2684:	00048593          	mv	a1,s1
    2688:	218a0513          	addi	a0,s4,536
    268c:	484000ef          	jal	2b10 <ee_printf>
    2690:	82c45783          	lhu	a5,-2004(s0)
    2694:	00178793          	addi	a5,a5,1
    2698:	01079793          	slli	a5,a5,0x10
    269c:	0107d793          	srli	a5,a5,0x10
    26a0:	82f41623          	sh	a5,-2004(s0)
    26a4:	bd1ff06f          	j	2274 <main+0x4a8>
    26a8:	00010537          	lui	a0,0x10
    26ac:	4c450513          	addi	a0,a0,1220 # 104c4 <seed3_volatile+0x4b0>
    26b0:	460000ef          	jal	2b10 <ee_printf>
    26b4:	f89ff06f          	j	263c <main+0x870>
    26b8:	00010537          	lui	a0,0x10
    26bc:	41450513          	addi	a0,a0,1044 # 10414 <seed3_volatile+0x400>
    26c0:	450000ef          	jal	2b10 <ee_printf>
    26c4:	f79ff06f          	j	263c <main+0x870>
    26c8:	00010537          	lui	a0,0x10
    26cc:	2a850513          	addi	a0,a0,680 # 102a8 <seed3_volatile+0x294>
    26d0:	440000ef          	jal	2b10 <ee_printf>
    26d4:	00148493          	addi	s1,s1,1
    26d8:	d15ff06f          	j	23ec <main+0x620>
    26dc:	00cc2583          	lw	a1,12(s8)
    26e0:	03812503          	lw	a0,56(sp)
    26e4:	1bd000ef          	jal	30a0 <__mulsi3>
    26e8:	00050413          	mv	s0,a0
    26ec:	00090513          	mv	a0,s2
    26f0:	3a8000ef          	jal	2a98 <time_in_secs>
    26f4:	00050593          	mv	a1,a0
    26f8:	00040513          	mv	a0,s0
    26fc:	1d1000ef          	jal	30cc <__hidden___udivsi3>
    2700:	00050593          	mv	a1,a0
    2704:	00010537          	lui	a0,0x10
    2708:	29050513          	addi	a0,a0,656 # 10290 <seed3_volatile+0x27c>
    270c:	404000ef          	jal	2b10 <ee_printf>
    2710:	ccdff06f          	j	23dc <main+0x610>
    2714:	00010537          	lui	a0,0x10
    2718:	0c850513          	addi	a0,a0,200 # 100c8 <seed3_volatile+0xb4>
    271c:	3f4000ef          	jal	2b10 <ee_printf>
    2720:	00000793          	li	a5,0
    2724:	aedff06f          	j	2210 <main+0x444>
    2728:	00010537          	lui	a0,0x10
    272c:	0f850513          	addi	a0,a0,248 # 100f8 <seed3_volatile+0xe4>
    2730:	3e0000ef          	jal	2b10 <ee_printf>
    2734:	00100793          	li	a5,1
    2738:	ad9ff06f          	j	2210 <main+0x444>
    273c:	00010537          	lui	a0,0x10
    2740:	18850513          	addi	a0,a0,392 # 10188 <seed3_volatile+0x174>
    2744:	3cc000ef          	jal	2b10 <ee_printf>
    2748:	00400793          	li	a5,4
    274c:	ac5ff06f          	j	2210 <main+0x444>
    2750:	00000413          	li	s0,0
    2754:	c35ff06f          	j	2388 <main+0x5bc>
    2758:	0047f793          	andi	a5,a5,4
    275c:	e60784e3          	beqz	a5,25c4 <main+0x7f8>
    2760:	ec9ff06f          	j	2628 <main+0x85c>

00002764 <number>:
    2764:	f6010113          	addi	sp,sp,-160
    2768:	08812c23          	sw	s0,152(sp)
    276c:	08912a23          	sw	s1,148(sp)
    2770:	09312623          	sw	s3,140(sp)
    2774:	07b12623          	sw	s11,108(sp)
    2778:	08112e23          	sw	ra,156(sp)
    277c:	09212823          	sw	s2,144(sp)
    2780:	09512223          	sw	s5,132(sp)
    2784:	09612023          	sw	s6,128(sp)
    2788:	07812c23          	sw	s8,120(sp)
    278c:	07912a23          	sw	s9,116(sp)
    2790:	07a12823          	sw	s10,112(sp)
    2794:	0407f813          	andi	a6,a5,64
    2798:	00e12423          	sw	a4,8(sp)
    279c:	00050413          	mv	s0,a0
    27a0:	00058d93          	mv	s11,a1
    27a4:	00060993          	mv	s3,a2
    27a8:	00068493          	mv	s1,a3
    27ac:	1a081863          	bnez	a6,295c <number+0x1f8>
    27b0:	00010ab7          	lui	s5,0x10
    27b4:	4f0a8a93          	addi	s5,s5,1264 # 104f0 <seed3_volatile+0x4dc>
    27b8:	0107fc93          	andi	s9,a5,16
    27bc:	160c8e63          	beqz	s9,2938 <number+0x1d4>
    27c0:	01000713          	li	a4,16
    27c4:	ffe7f793          	andi	a5,a5,-2
    27c8:	00e12223          	sw	a4,4(sp)
    27cc:	02000b13          	li	s6,32
    27d0:	0027f713          	andi	a4,a5,2
    27d4:	0207fc13          	andi	s8,a5,32
    27d8:	18070863          	beqz	a4,2968 <number+0x204>
    27dc:	200dc863          	bltz	s11,29ec <number+0x288>
    27e0:	0047f713          	andi	a4,a5,4
    27e4:	1e071063          	bnez	a4,29c4 <number+0x260>
    27e8:	0087f793          	andi	a5,a5,8
    27ec:	00012623          	sw	zero,12(sp)
    27f0:	00078863          	beqz	a5,2800 <number+0x9c>
    27f4:	02000793          	li	a5,32
    27f8:	fff48493          	addi	s1,s1,-1
    27fc:	00f12623          	sw	a5,12(sp)
    2800:	000c0e63          	beqz	s8,281c <number+0xb8>
    2804:	01000793          	li	a5,16
    2808:	20f98a63          	beq	s3,a5,2a1c <number+0x2b8>
    280c:	ff898793          	addi	a5,s3,-8 # ff8 <matrix_test+0x3c>
    2810:	0017b793          	seqz	a5,a5
    2814:	02000c13          	li	s8,32
    2818:	40f484b3          	sub	s1,s1,a5
    281c:	140d9a63          	bnez	s11,2970 <number+0x20c>
    2820:	03000793          	li	a5,48
    2824:	00f10e23          	sb	a5,28(sp)
    2828:	00100913          	li	s2,1
    282c:	01c10d13          	addi	s10,sp,28
    2830:	00812783          	lw	a5,8(sp)
    2834:	00090693          	mv	a3,s2
    2838:	00f95463          	bge	s2,a5,2840 <number+0xdc>
    283c:	00078693          	mv	a3,a5
    2840:	00412783          	lw	a5,4(sp)
    2844:	40d484b3          	sub	s1,s1,a3
    2848:	02079063          	bnez	a5,2868 <number+0x104>
    284c:	00940733          	add	a4,s0,s1
    2850:	02000793          	li	a5,32
    2854:	1e905863          	blez	s1,2a44 <number+0x2e0>
    2858:	00140413          	addi	s0,s0,1
    285c:	fef40fa3          	sb	a5,-1(s0)
    2860:	fe871ce3          	bne	a4,s0,2858 <number+0xf4>
    2864:	fff00493          	li	s1,-1
    2868:	00c12783          	lw	a5,12(sp)
    286c:	00078663          	beqz	a5,2878 <number+0x114>
    2870:	00f40023          	sb	a5,0(s0)
    2874:	00140413          	addi	s0,s0,1
    2878:	000c0a63          	beqz	s8,288c <number+0x128>
    287c:	00800793          	li	a5,8
    2880:	18f98663          	beq	s3,a5,2a0c <number+0x2a8>
    2884:	01000793          	li	a5,16
    2888:	14f98663          	beq	s3,a5,29d4 <number+0x270>
    288c:	000c9e63          	bnez	s9,28a8 <number+0x144>
    2890:	009407b3          	add	a5,s0,s1
    2894:	1a905c63          	blez	s1,2a4c <number+0x2e8>
    2898:	00140413          	addi	s0,s0,1
    289c:	ff640fa3          	sb	s6,-1(s0)
    28a0:	fef41ce3          	bne	s0,a5,2898 <number+0x134>
    28a4:	fff00493          	li	s1,-1
    28a8:	412687b3          	sub	a5,a3,s2
    28ac:	00f407b3          	add	a5,s0,a5
    28b0:	03000713          	li	a4,48
    28b4:	16d95e63          	bge	s2,a3,2a30 <number+0x2cc>
    28b8:	00140413          	addi	s0,s0,1
    28bc:	fee40fa3          	sb	a4,-1(s0)
    28c0:	fe879ce3          	bne	a5,s0,28b8 <number+0x154>
    28c4:	01bd0733          	add	a4,s10,s11
    28c8:	00078613          	mv	a2,a5
    28cc:	00074503          	lbu	a0,0(a4)
    28d0:	00070693          	mv	a3,a4
    28d4:	00160613          	addi	a2,a2,1
    28d8:	fea60fa3          	sb	a0,-1(a2)
    28dc:	fff70713          	addi	a4,a4,-1
    28e0:	fedd16e3          	bne	s10,a3,28cc <number+0x168>
    28e4:	001d8893          	addi	a7,s11,1
    28e8:	011785b3          	add	a1,a5,a7
    28ec:	12905e63          	blez	s1,2a28 <number+0x2c4>
    28f0:	00958533          	add	a0,a1,s1
    28f4:	02000793          	li	a5,32
    28f8:	00158593          	addi	a1,a1,1
    28fc:	fef58fa3          	sb	a5,-1(a1)
    2900:	feb51ce3          	bne	a0,a1,28f8 <number+0x194>
    2904:	09c12083          	lw	ra,156(sp)
    2908:	09812403          	lw	s0,152(sp)
    290c:	09412483          	lw	s1,148(sp)
    2910:	09012903          	lw	s2,144(sp)
    2914:	08c12983          	lw	s3,140(sp)
    2918:	08412a83          	lw	s5,132(sp)
    291c:	08012b03          	lw	s6,128(sp)
    2920:	07812c03          	lw	s8,120(sp)
    2924:	07412c83          	lw	s9,116(sp)
    2928:	07012d03          	lw	s10,112(sp)
    292c:	06c12d83          	lw	s11,108(sp)
    2930:	0a010113          	addi	sp,sp,160
    2934:	00008067          	ret
    2938:	0117f693          	andi	a3,a5,17
    293c:	0017f713          	andi	a4,a5,1
    2940:	00d12223          	sw	a3,4(sp)
    2944:	10070863          	beqz	a4,2a54 <number+0x2f0>
    2948:	0027f713          	andi	a4,a5,2
    294c:	03000b13          	li	s6,48
    2950:	0207fc13          	andi	s8,a5,32
    2954:	00070a63          	beqz	a4,2968 <number+0x204>
    2958:	e85ff06f          	j	27dc <number+0x78>
    295c:	00010ab7          	lui	s5,0x10
    2960:	518a8a93          	addi	s5,s5,1304 # 10518 <seed3_volatile+0x504>
    2964:	e55ff06f          	j	27b8 <number+0x54>
    2968:	00012623          	sw	zero,12(sp)
    296c:	e95ff06f          	j	2800 <number+0x9c>
    2970:	09412423          	sw	s4,136(sp)
    2974:	07712e23          	sw	s7,124(sp)
    2978:	000d8513          	mv	a0,s11
    297c:	00000913          	li	s2,0
    2980:	01c10d13          	addi	s10,sp,28
    2984:	00098593          	mv	a1,s3
    2988:	00050a13          	mv	s4,a0
    298c:	788000ef          	jal	3114 <__umodsi3>
    2990:	00aa8533          	add	a0,s5,a0
    2994:	00054703          	lbu	a4,0(a0)
    2998:	00090d93          	mv	s11,s2
    299c:	00190913          	addi	s2,s2,1 # fffff001 <__stack_top+0xfffeb001>
    29a0:	012d0bb3          	add	s7,s10,s2
    29a4:	00098593          	mv	a1,s3
    29a8:	000a0513          	mv	a0,s4
    29ac:	feeb8fa3          	sb	a4,-1(s7)
    29b0:	71c000ef          	jal	30cc <__hidden___udivsi3>
    29b4:	fd3a78e3          	bgeu	s4,s3,2984 <number+0x220>
    29b8:	08812a03          	lw	s4,136(sp)
    29bc:	07c12b83          	lw	s7,124(sp)
    29c0:	e71ff06f          	j	2830 <number+0xcc>
    29c4:	02b00793          	li	a5,43
    29c8:	fff48493          	addi	s1,s1,-1
    29cc:	00f12623          	sw	a5,12(sp)
    29d0:	e31ff06f          	j	2800 <number+0x9c>
    29d4:	03000793          	li	a5,48
    29d8:	00f40023          	sb	a5,0(s0)
    29dc:	07800793          	li	a5,120
    29e0:	00f400a3          	sb	a5,1(s0)
    29e4:	00240413          	addi	s0,s0,2
    29e8:	ea5ff06f          	j	288c <number+0x128>
    29ec:	41b00db3          	neg	s11,s11
    29f0:	fff48493          	addi	s1,s1,-1
    29f4:	040c1263          	bnez	s8,2a38 <number+0x2d4>
    29f8:	02d00793          	li	a5,45
    29fc:	09412423          	sw	s4,136(sp)
    2a00:	07712e23          	sw	s7,124(sp)
    2a04:	00f12623          	sw	a5,12(sp)
    2a08:	f71ff06f          	j	2978 <number+0x214>
    2a0c:	03000793          	li	a5,48
    2a10:	00f40023          	sb	a5,0(s0)
    2a14:	00140413          	addi	s0,s0,1
    2a18:	e75ff06f          	j	288c <number+0x128>
    2a1c:	ffe48493          	addi	s1,s1,-2
    2a20:	02000c13          	li	s8,32
    2a24:	df9ff06f          	j	281c <number+0xb8>
    2a28:	00058513          	mv	a0,a1
    2a2c:	ed9ff06f          	j	2904 <number+0x1a0>
    2a30:	00040793          	mv	a5,s0
    2a34:	e91ff06f          	j	28c4 <number+0x160>
    2a38:	02d00793          	li	a5,45
    2a3c:	00f12623          	sw	a5,12(sp)
    2a40:	dc5ff06f          	j	2804 <number+0xa0>
    2a44:	fff48493          	addi	s1,s1,-1
    2a48:	e21ff06f          	j	2868 <number+0x104>
    2a4c:	fff48493          	addi	s1,s1,-1
    2a50:	e59ff06f          	j	28a8 <number+0x144>
    2a54:	00012223          	sw	zero,4(sp)
    2a58:	02000b13          	li	s6,32
    2a5c:	d75ff06f          	j	27d0 <number+0x6c>

00002a60 <start_time>:
    2a60:	c0002773          	rdcycle	a4
    2a64:	000107b7          	lui	a5,0x10
    2a68:	70e7aa23          	sw	a4,1812(a5) # 10714 <start_cycles>
    2a6c:	00008067          	ret

00002a70 <stop_time>:
    2a70:	c0002773          	rdcycle	a4
    2a74:	000107b7          	lui	a5,0x10
    2a78:	70e7a823          	sw	a4,1808(a5) # 10710 <stop_cycles>
    2a7c:	00008067          	ret

00002a80 <get_time>:
    2a80:	000107b7          	lui	a5,0x10
    2a84:	7107a503          	lw	a0,1808(a5) # 10710 <stop_cycles>
    2a88:	000107b7          	lui	a5,0x10
    2a8c:	7147a783          	lw	a5,1812(a5) # 10714 <start_cycles>
    2a90:	40f50533          	sub	a0,a0,a5
    2a94:	00008067          	ret

00002a98 <time_in_secs>:
    2a98:	05f5e5b7          	lui	a1,0x5f5e
    2a9c:	ff010113          	addi	sp,sp,-16
    2aa0:	10058593          	addi	a1,a1,256 # 5f5e100 <__stack_top+0x5f4a100>
    2aa4:	00112623          	sw	ra,12(sp)
    2aa8:	624000ef          	jal	30cc <__hidden___udivsi3>
    2aac:	00c12083          	lw	ra,12(sp)
    2ab0:	01010113          	addi	sp,sp,16
    2ab4:	00008067          	ret

00002ab8 <portable_init>:
    2ab8:	00100793          	li	a5,1
    2abc:	00f50023          	sb	a5,0(a0)
    2ac0:	00008067          	ret

00002ac4 <portable_fini>:
    2ac4:	00050023          	sb	zero,0(a0)
    2ac8:	00008067          	ret

00002acc <memset>:
    2acc:	0ff5f593          	zext.b	a1,a1
    2ad0:	00c50733          	add	a4,a0,a2
    2ad4:	00050793          	mv	a5,a0
    2ad8:	00060863          	beqz	a2,2ae8 <memset+0x1c>
    2adc:	00178793          	addi	a5,a5,1
    2ae0:	feb78fa3          	sb	a1,-1(a5)
    2ae4:	fef71ce3          	bne	a4,a5,2adc <memset+0x10>
    2ae8:	00008067          	ret

00002aec <memcpy>:
    2aec:	02060063          	beqz	a2,2b0c <memcpy+0x20>
    2af0:	00c50633          	add	a2,a0,a2
    2af4:	00050793          	mv	a5,a0
    2af8:	0005c703          	lbu	a4,0(a1)
    2afc:	00178793          	addi	a5,a5,1
    2b00:	00158593          	addi	a1,a1,1
    2b04:	fee78fa3          	sb	a4,-1(a5)
    2b08:	fef618e3          	bne	a2,a5,2af8 <memcpy+0xc>
    2b0c:	00008067          	ret

00002b10 <ee_printf>:
    2b10:	da010113          	addi	sp,sp,-608
    2b14:	23312623          	sw	s3,556(sp)
    2b18:	22112e23          	sw	ra,572(sp)
    2b1c:	22912a23          	sw	s1,564(sp)
    2b20:	24b12223          	sw	a1,580(sp)
    2b24:	24c12423          	sw	a2,584(sp)
    2b28:	24d12623          	sw	a3,588(sp)
    2b2c:	24e12823          	sw	a4,592(sp)
    2b30:	24f12a23          	sw	a5,596(sp)
    2b34:	25012c23          	sw	a6,600(sp)
    2b38:	25112e23          	sw	a7,604(sp)
    2b3c:	00054783          	lbu	a5,0(a0)
    2b40:	24410993          	addi	s3,sp,580
    2b44:	01312623          	sw	s3,12(sp)
    2b48:	4c078a63          	beqz	a5,301c <ee_printf+0x50c>
    2b4c:	23412423          	sw	s4,552(sp)
    2b50:	01010493          	addi	s1,sp,16
    2b54:	00010a37          	lui	s4,0x10
    2b58:	23212823          	sw	s2,560(sp)
    2b5c:	23512223          	sw	s5,548(sp)
    2b60:	23612023          	sw	s6,544(sp)
    2b64:	21712e23          	sw	s7,540(sp)
    2b68:	21812c23          	sw	s8,536(sp)
    2b6c:	00050313          	mv	t1,a0
    2b70:	22812c23          	sw	s0,568(sp)
    2b74:	00048513          	mv	a0,s1
    2b78:	02500a93          	li	s5,37
    2b7c:	01000913          	li	s2,16
    2b80:	5c4a0a13          	addi	s4,s4,1476 # 105c4 <state_known_crc+0xc>
    2b84:	00900c13          	li	s8,9
    2b88:	02e00b93          	li	s7,46
    2b8c:	04c00b13          	li	s6,76
    2b90:	09578263          	beq	a5,s5,2c14 <ee_printf+0x104>
    2b94:	00f50023          	sb	a5,0(a0)
    2b98:	00134783          	lbu	a5,1(t1)
    2b9c:	00150513          	addi	a0,a0,1
    2ba0:	00130313          	addi	t1,t1,1
    2ba4:	fe0796e3          	bnez	a5,2b90 <ee_printf+0x80>
    2ba8:	23812403          	lw	s0,568(sp)
    2bac:	23012903          	lw	s2,560(sp)
    2bb0:	22812a03          	lw	s4,552(sp)
    2bb4:	22412a83          	lw	s5,548(sp)
    2bb8:	22012b03          	lw	s6,544(sp)
    2bbc:	21c12b83          	lw	s7,540(sp)
    2bc0:	21812c03          	lw	s8,536(sp)
    2bc4:	409505b3          	sub	a1,a0,s1
    2bc8:	00050023          	sb	zero,0(a0)
    2bcc:	01014683          	lbu	a3,16(sp)
    2bd0:	40000737          	lui	a4,0x40000
    2bd4:	40000637          	lui	a2,0x40000
    2bd8:	00470713          	addi	a4,a4,4 # 40000004 <__stack_top+0x3ffec004>
    2bdc:	02068063          	beqz	a3,2bfc <ee_printf+0xec>
    2be0:	00072783          	lw	a5,0(a4)
    2be4:	0017f793          	andi	a5,a5,1
    2be8:	fe079ce3          	bnez	a5,2be0 <ee_printf+0xd0>
    2bec:	00d62023          	sw	a3,0(a2) # 40000000 <__stack_top+0x3ffec000>
    2bf0:	0014c683          	lbu	a3,1(s1)
    2bf4:	00148493          	addi	s1,s1,1
    2bf8:	fe0694e3          	bnez	a3,2be0 <ee_printf+0xd0>
    2bfc:	23c12083          	lw	ra,572(sp)
    2c00:	23412483          	lw	s1,564(sp)
    2c04:	22c12983          	lw	s3,556(sp)
    2c08:	00058513          	mv	a0,a1
    2c0c:	26010113          	addi	sp,sp,608
    2c10:	00008067          	ret
    2c14:	00000793          	li	a5,0
    2c18:	00134603          	lbu	a2,1(t1)
    2c1c:	00130593          	addi	a1,t1,1
    2c20:	fe060713          	addi	a4,a2,-32
    2c24:	0ff77713          	zext.b	a4,a4
    2c28:	00e96a63          	bltu	s2,a4,2c3c <ee_printf+0x12c>
    2c2c:	00271713          	slli	a4,a4,0x2
    2c30:	01470733          	add	a4,a4,s4
    2c34:	00072703          	lw	a4,0(a4)
    2c38:	00070067          	jr	a4
    2c3c:	fd060713          	addi	a4,a2,-48
    2c40:	0ff77713          	zext.b	a4,a4
    2c44:	10ec7263          	bgeu	s8,a4,2d48 <ee_printf+0x238>
    2c48:	02a00713          	li	a4,42
    2c4c:	fff00693          	li	a3,-1
    2c50:	12e60663          	beq	a2,a4,2d7c <ee_printf+0x26c>
    2c54:	fff00713          	li	a4,-1
    2c58:	0d760263          	beq	a2,s7,2d1c <ee_printf+0x20c>
    2c5c:	0df67813          	andi	a6,a2,223
    2c60:	09680463          	beq	a6,s6,2ce8 <ee_printf+0x1d8>
    2c64:	fa860813          	addi	a6,a2,-88
    2c68:	0ff87813          	zext.b	a6,a6
    2c6c:	02000893          	li	a7,32
    2c70:	0508ec63          	bltu	a7,a6,2cc8 <ee_printf+0x1b8>
    2c74:	000108b7          	lui	a7,0x10
    2c78:	00281813          	slli	a6,a6,0x2
    2c7c:	60888893          	addi	a7,a7,1544 # 10608 <state_known_crc+0x50>
    2c80:	01180833          	add	a6,a6,a7
    2c84:	00082803          	lw	a6,0(a6)
    2c88:	00080067          	jr	a6
    2c8c:	0017e793          	ori	a5,a5,1
    2c90:	00058313          	mv	t1,a1
    2c94:	f85ff06f          	j	2c18 <ee_printf+0x108>
    2c98:	0107e793          	ori	a5,a5,16
    2c9c:	00058313          	mv	t1,a1
    2ca0:	f79ff06f          	j	2c18 <ee_printf+0x108>
    2ca4:	0047e793          	ori	a5,a5,4
    2ca8:	00058313          	mv	t1,a1
    2cac:	f6dff06f          	j	2c18 <ee_printf+0x108>
    2cb0:	0207e793          	ori	a5,a5,32
    2cb4:	00058313          	mv	t1,a1
    2cb8:	f61ff06f          	j	2c18 <ee_printf+0x108>
    2cbc:	0087e793          	ori	a5,a5,8
    2cc0:	00058313          	mv	t1,a1
    2cc4:	f55ff06f          	j	2c18 <ee_printf+0x108>
    2cc8:	00058413          	mv	s0,a1
    2ccc:	02500793          	li	a5,37
    2cd0:	26f60c63          	beq	a2,a5,2f48 <ee_printf+0x438>
    2cd4:	00f50023          	sb	a5,0(a0)
    2cd8:	00044783          	lbu	a5,0(s0)
    2cdc:	00150513          	addi	a0,a0,1
    2ce0:	ec0784e3          	beqz	a5,2ba8 <ee_printf+0x98>
    2ce4:	2680006f          	j	2f4c <ee_printf+0x43c>
    2ce8:	00060893          	mv	a7,a2
    2cec:	0015c603          	lbu	a2,1(a1)
    2cf0:	00158413          	addi	s0,a1,1
    2cf4:	02000813          	li	a6,32
    2cf8:	fa860593          	addi	a1,a2,-88
    2cfc:	0ff5f593          	zext.b	a1,a1
    2d00:	fcb866e3          	bltu	a6,a1,2ccc <ee_printf+0x1bc>
    2d04:	00010837          	lui	a6,0x10
    2d08:	00259593          	slli	a1,a1,0x2
    2d0c:	68c80813          	addi	a6,a6,1676 # 1068c <state_known_crc+0xd4>
    2d10:	010585b3          	add	a1,a1,a6
    2d14:	0005a583          	lw	a1,0(a1)
    2d18:	00058067          	jr	a1
    2d1c:	0015c603          	lbu	a2,1(a1)
    2d20:	00900893          	li	a7,9
    2d24:	00158813          	addi	a6,a1,1
    2d28:	fd060713          	addi	a4,a2,-48
    2d2c:	0ff77713          	zext.b	a4,a4
    2d30:	1ae8fa63          	bgeu	a7,a4,2ee4 <ee_printf+0x3d4>
    2d34:	02a00713          	li	a4,42
    2d38:	1ee60863          	beq	a2,a4,2f28 <ee_printf+0x418>
    2d3c:	00080593          	mv	a1,a6
    2d40:	00000713          	li	a4,0
    2d44:	f19ff06f          	j	2c5c <ee_printf+0x14c>
    2d48:	00000693          	li	a3,0
    2d4c:	00900813          	li	a6,9
    2d50:	00269713          	slli	a4,a3,0x2
    2d54:	00d70733          	add	a4,a4,a3
    2d58:	00158593          	addi	a1,a1,1
    2d5c:	00171713          	slli	a4,a4,0x1
    2d60:	00c70733          	add	a4,a4,a2
    2d64:	0005c603          	lbu	a2,0(a1)
    2d68:	fd070693          	addi	a3,a4,-48
    2d6c:	fd060713          	addi	a4,a2,-48
    2d70:	0ff77713          	zext.b	a4,a4
    2d74:	fce87ee3          	bgeu	a6,a4,2d50 <ee_printf+0x240>
    2d78:	eddff06f          	j	2c54 <ee_printf+0x144>
    2d7c:	0009a683          	lw	a3,0(s3)
    2d80:	00234603          	lbu	a2,2(t1)
    2d84:	00230593          	addi	a1,t1,2
    2d88:	00498993          	addi	s3,s3,4
    2d8c:	ec06d4e3          	bgez	a3,2c54 <ee_printf+0x144>
    2d90:	40d006b3          	neg	a3,a3
    2d94:	0107e793          	ori	a5,a5,16
    2d98:	ebdff06f          	j	2c54 <ee_printf+0x144>
    2d9c:	00058413          	mv	s0,a1
    2da0:	00a00613          	li	a2,10
    2da4:	0009a583          	lw	a1,0(s3)
    2da8:	00498993          	addi	s3,s3,4
    2dac:	9b9ff0ef          	jal	2764 <number>
    2db0:	00144783          	lbu	a5,1(s0)
    2db4:	00140313          	addi	t1,s0,1
    2db8:	dc079ce3          	bnez	a5,2b90 <ee_printf+0x80>
    2dbc:	dedff06f          	j	2ba8 <ee_printf+0x98>
    2dc0:	00058413          	mv	s0,a1
    2dc4:	01000613          	li	a2,16
    2dc8:	fddff06f          	j	2da4 <ee_printf+0x294>
    2dcc:	00058413          	mv	s0,a1
    2dd0:	0009a603          	lw	a2,0(s3)
    2dd4:	00498993          	addi	s3,s3,4
    2dd8:	1a060c63          	beqz	a2,2f90 <ee_printf+0x480>
    2ddc:	00064583          	lbu	a1,0(a2)
    2de0:	24058663          	beqz	a1,302c <ee_printf+0x51c>
    2de4:	24070463          	beqz	a4,302c <ee_printf+0x51c>
    2de8:	00060593          	mv	a1,a2
    2dec:	00c0006f          	j	2df8 <ee_printf+0x2e8>
    2df0:	40e58833          	sub	a6,a1,a4
    2df4:	00c80863          	beq	a6,a2,2e04 <ee_printf+0x2f4>
    2df8:	0015c803          	lbu	a6,1(a1)
    2dfc:	00158593          	addi	a1,a1,1
    2e00:	fe0818e3          	bnez	a6,2df0 <ee_printf+0x2e0>
    2e04:	0107f713          	andi	a4,a5,16
    2e08:	40c587b3          	sub	a5,a1,a2
    2e0c:	1a070c63          	beqz	a4,2fc4 <ee_printf+0x4b4>
    2e10:	26f05263          	blez	a5,3074 <ee_printf+0x564>
    2e14:	00f60833          	add	a6,a2,a5
    2e18:	00050713          	mv	a4,a0
    2e1c:	00064583          	lbu	a1,0(a2)
    2e20:	00160613          	addi	a2,a2,1
    2e24:	00170713          	addi	a4,a4,1
    2e28:	feb70fa3          	sb	a1,-1(a4)
    2e2c:	ff0618e3          	bne	a2,a6,2e1c <ee_printf+0x30c>
    2e30:	00f50733          	add	a4,a0,a5
    2e34:	40f68533          	sub	a0,a3,a5
    2e38:	00140313          	addi	t1,s0,1
    2e3c:	00a70533          	add	a0,a4,a0
    2e40:	02000613          	li	a2,32
    2e44:	20d7d663          	bge	a5,a3,3050 <ee_printf+0x540>
    2e48:	00170713          	addi	a4,a4,1
    2e4c:	fec70fa3          	sb	a2,-1(a4)
    2e50:	fea71ce3          	bne	a4,a0,2e48 <ee_printf+0x338>
    2e54:	00144783          	lbu	a5,1(s0)
    2e58:	d2079ce3          	bnez	a5,2b90 <ee_printf+0x80>
    2e5c:	d4dff06f          	j	2ba8 <ee_printf+0x98>
    2e60:	00058413          	mv	s0,a1
    2e64:	fff00613          	li	a2,-1
    2e68:	0ec68e63          	beq	a3,a2,2f64 <ee_printf+0x454>
    2e6c:	0009a583          	lw	a1,0(s3)
    2e70:	01000613          	li	a2,16
    2e74:	00498993          	addi	s3,s3,4
    2e78:	8edff0ef          	jal	2764 <number>
    2e7c:	00144783          	lbu	a5,1(s0)
    2e80:	00140313          	addi	t1,s0,1
    2e84:	d00796e3          	bnez	a5,2b90 <ee_printf+0x80>
    2e88:	d21ff06f          	j	2ba8 <ee_printf+0x98>
    2e8c:	00058413          	mv	s0,a1
    2e90:	0107f793          	andi	a5,a5,16
    2e94:	00498613          	addi	a2,s3,4
    2e98:	00140313          	addi	t1,s0,1
    2e9c:	10078063          	beqz	a5,2f9c <ee_printf+0x48c>
    2ea0:	0009a783          	lw	a5,0(s3)
    2ea4:	00100593          	li	a1,1
    2ea8:	00150713          	addi	a4,a0,1
    2eac:	00f50023          	sb	a5,0(a0)
    2eb0:	02000793          	li	a5,32
    2eb4:	00d50533          	add	a0,a0,a3
    2eb8:	1ad5d463          	bge	a1,a3,3060 <ee_printf+0x550>
    2ebc:	00170713          	addi	a4,a4,1
    2ec0:	fef70fa3          	sb	a5,-1(a4)
    2ec4:	fea71ce3          	bne	a4,a0,2ebc <ee_printf+0x3ac>
    2ec8:	00144783          	lbu	a5,1(s0)
    2ecc:	00060993          	mv	s3,a2
    2ed0:	cc0790e3          	bnez	a5,2b90 <ee_printf+0x80>
    2ed4:	cd5ff06f          	j	2ba8 <ee_printf+0x98>
    2ed8:	00058413          	mv	s0,a1
    2edc:	00800613          	li	a2,8
    2ee0:	ec5ff06f          	j	2da4 <ee_printf+0x294>
    2ee4:	00000893          	li	a7,0
    2ee8:	00900313          	li	t1,9
    2eec:	00289713          	slli	a4,a7,0x2
    2ef0:	01170733          	add	a4,a4,a7
    2ef4:	00180813          	addi	a6,a6,1
    2ef8:	00171713          	slli	a4,a4,0x1
    2efc:	00c70733          	add	a4,a4,a2
    2f00:	00084603          	lbu	a2,0(a6)
    2f04:	fd070893          	addi	a7,a4,-48
    2f08:	fd060593          	addi	a1,a2,-48
    2f0c:	0ff5f593          	zext.b	a1,a1
    2f10:	fcb37ee3          	bgeu	t1,a1,2eec <ee_printf+0x3dc>
    2f14:	fff8c713          	not	a4,a7
    2f18:	41f75713          	srai	a4,a4,0x1f
    2f1c:	00e8f733          	and	a4,a7,a4
    2f20:	00080593          	mv	a1,a6
    2f24:	d39ff06f          	j	2c5c <ee_printf+0x14c>
    2f28:	0009a703          	lw	a4,0(s3)
    2f2c:	0025c603          	lbu	a2,2(a1)
    2f30:	00498993          	addi	s3,s3,4
    2f34:	fff74813          	not	a6,a4
    2f38:	41f85813          	srai	a6,a6,0x1f
    2f3c:	01077733          	and	a4,a4,a6
    2f40:	00258593          	addi	a1,a1,2
    2f44:	d19ff06f          	j	2c5c <ee_printf+0x14c>
    2f48:	00044783          	lbu	a5,0(s0)
    2f4c:	00f50023          	sb	a5,0(a0)
    2f50:	00144783          	lbu	a5,1(s0)
    2f54:	00150513          	addi	a0,a0,1
    2f58:	00140313          	addi	t1,s0,1
    2f5c:	c2079ae3          	bnez	a5,2b90 <ee_printf+0x80>
    2f60:	c49ff06f          	j	2ba8 <ee_printf+0x98>
    2f64:	0017e793          	ori	a5,a5,1
    2f68:	00800693          	li	a3,8
    2f6c:	f01ff06f          	j	2e6c <ee_printf+0x35c>
    2f70:	06c00613          	li	a2,108
    2f74:	0027e793          	ori	a5,a5,2
    2f78:	00498813          	addi	a6,s3,4
    2f7c:	e2c882e3          	beq	a7,a2,2da0 <ee_printf+0x290>
    2f80:	0009a583          	lw	a1,0(s3)
    2f84:	00a00613          	li	a2,10
    2f88:	00080993          	mv	s3,a6
    2f8c:	e21ff06f          	j	2dac <ee_printf+0x29c>
    2f90:	00010637          	lui	a2,0x10
    2f94:	54060613          	addi	a2,a2,1344 # 10540 <seed3_volatile+0x52c>
    2f98:	e4dff06f          	j	2de4 <ee_printf+0x2d4>
    2f9c:	00100793          	li	a5,1
    2fa0:	0ed7d263          	bge	a5,a3,3084 <ee_printf+0x574>
    2fa4:	fff68793          	addi	a5,a3,-1
    2fa8:	00f507b3          	add	a5,a0,a5
    2fac:	02000713          	li	a4,32
    2fb0:	00150513          	addi	a0,a0,1
    2fb4:	fee50fa3          	sb	a4,-1(a0)
    2fb8:	fef51ce3          	bne	a0,a5,2fb0 <ee_printf+0x4a0>
    2fbc:	00000693          	li	a3,0
    2fc0:	ee1ff06f          	j	2ea0 <ee_printf+0x390>
    2fc4:	fff68813          	addi	a6,a3,-1
    2fc8:	0ad7da63          	bge	a5,a3,307c <ee_printf+0x56c>
    2fcc:	40f68733          	sub	a4,a3,a5
    2fd0:	00e50733          	add	a4,a0,a4
    2fd4:	02000593          	li	a1,32
    2fd8:	00150513          	addi	a0,a0,1
    2fdc:	feb50fa3          	sb	a1,-1(a0)
    2fe0:	fee51ce3          	bne	a0,a4,2fd8 <ee_printf+0x4c8>
    2fe4:	40d786b3          	sub	a3,a5,a3
    2fe8:	010686b3          	add	a3,a3,a6
    2fec:	e25ff06f          	j	2e10 <ee_printf+0x300>
    2ff0:	0027e793          	ori	a5,a5,2
    2ff4:	00498813          	addi	a6,s3,4
    2ff8:	00058413          	mv	s0,a1
    2ffc:	f85ff06f          	j	2f80 <ee_printf+0x470>
    3000:	0407e793          	ori	a5,a5,64
    3004:	01000613          	li	a2,16
    3008:	d9dff06f          	j	2da4 <ee_printf+0x294>
    300c:	0407e793          	ori	a5,a5,64
    3010:	00058413          	mv	s0,a1
    3014:	01000613          	li	a2,16
    3018:	d8dff06f          	j	2da4 <ee_printf+0x294>
    301c:	01010493          	addi	s1,sp,16
    3020:	00000593          	li	a1,0
    3024:	00048513          	mv	a0,s1
    3028:	ba1ff06f          	j	2bc8 <ee_printf+0xb8>
    302c:	0107f793          	andi	a5,a5,16
    3030:	00078863          	beqz	a5,3040 <ee_printf+0x530>
    3034:	00050713          	mv	a4,a0
    3038:	00000793          	li	a5,0
    303c:	df9ff06f          	j	2e34 <ee_printf+0x324>
    3040:	fff68813          	addi	a6,a3,-1
    3044:	f8d044e3          	bgtz	a3,2fcc <ee_printf+0x4bc>
    3048:	00140313          	addi	t1,s0,1
    304c:	00050713          	mv	a4,a0
    3050:	00144783          	lbu	a5,1(s0)
    3054:	00070513          	mv	a0,a4
    3058:	b2079ce3          	bnez	a5,2b90 <ee_printf+0x80>
    305c:	b4dff06f          	j	2ba8 <ee_printf+0x98>
    3060:	00144783          	lbu	a5,1(s0)
    3064:	00060993          	mv	s3,a2
    3068:	00070513          	mv	a0,a4
    306c:	b20792e3          	bnez	a5,2b90 <ee_printf+0x80>
    3070:	b39ff06f          	j	2ba8 <ee_printf+0x98>
    3074:	00050713          	mv	a4,a0
    3078:	dbdff06f          	j	2e34 <ee_printf+0x324>
    307c:	00080693          	mv	a3,a6
    3080:	d91ff06f          	j	2e10 <ee_printf+0x300>
    3084:	0009a783          	lw	a5,0(s3)
    3088:	00150513          	addi	a0,a0,1
    308c:	00060993          	mv	s3,a2
    3090:	fef50fa3          	sb	a5,-1(a0)
    3094:	00144783          	lbu	a5,1(s0)
    3098:	ae079ce3          	bnez	a5,2b90 <ee_printf+0x80>
    309c:	b0dff06f          	j	2ba8 <ee_printf+0x98>

000030a0 <__mulsi3>:
    30a0:	00050613          	mv	a2,a0
    30a4:	00000513          	li	a0,0
    30a8:	0015f693          	andi	a3,a1,1
    30ac:	00068463          	beqz	a3,30b4 <__mulsi3+0x14>
    30b0:	00c50533          	add	a0,a0,a2
    30b4:	0015d593          	srli	a1,a1,0x1
    30b8:	00161613          	slli	a2,a2,0x1
    30bc:	fe0596e3          	bnez	a1,30a8 <__mulsi3+0x8>
    30c0:	00008067          	ret

000030c4 <__divsi3>:
    30c4:	06054063          	bltz	a0,3124 <__umodsi3+0x10>
    30c8:	0605c663          	bltz	a1,3134 <__umodsi3+0x20>

000030cc <__hidden___udivsi3>:
    30cc:	00058613          	mv	a2,a1
    30d0:	00050593          	mv	a1,a0
    30d4:	fff00513          	li	a0,-1
    30d8:	02060c63          	beqz	a2,3110 <__hidden___udivsi3+0x44>
    30dc:	00100693          	li	a3,1
    30e0:	00b67a63          	bgeu	a2,a1,30f4 <__hidden___udivsi3+0x28>
    30e4:	00c05863          	blez	a2,30f4 <__hidden___udivsi3+0x28>
    30e8:	00161613          	slli	a2,a2,0x1
    30ec:	00169693          	slli	a3,a3,0x1
    30f0:	feb66ae3          	bltu	a2,a1,30e4 <__hidden___udivsi3+0x18>
    30f4:	00000513          	li	a0,0
    30f8:	00c5e663          	bltu	a1,a2,3104 <__hidden___udivsi3+0x38>
    30fc:	40c585b3          	sub	a1,a1,a2
    3100:	00d56533          	or	a0,a0,a3
    3104:	0016d693          	srli	a3,a3,0x1
    3108:	00165613          	srli	a2,a2,0x1
    310c:	fe0696e3          	bnez	a3,30f8 <__hidden___udivsi3+0x2c>
    3110:	00008067          	ret

00003114 <__umodsi3>:
    3114:	00008293          	mv	t0,ra
    3118:	fb5ff0ef          	jal	30cc <__hidden___udivsi3>
    311c:	00058513          	mv	a0,a1
    3120:	00028067          	jr	t0
    3124:	40a00533          	neg	a0,a0
    3128:	00b04863          	bgtz	a1,3138 <__umodsi3+0x24>
    312c:	40b005b3          	neg	a1,a1
    3130:	f9dff06f          	j	30cc <__hidden___udivsi3>
    3134:	40b005b3          	neg	a1,a1
    3138:	00008293          	mv	t0,ra
    313c:	f91ff0ef          	jal	30cc <__hidden___udivsi3>
    3140:	40a00533          	neg	a0,a0
    3144:	00028067          	jr	t0

00003148 <__modsi3>:
    3148:	00008293          	mv	t0,ra
    314c:	0005ca63          	bltz	a1,3160 <__modsi3+0x18>
    3150:	00054c63          	bltz	a0,3168 <__modsi3+0x20>
    3154:	f79ff0ef          	jal	30cc <__hidden___udivsi3>
    3158:	00058513          	mv	a0,a1
    315c:	00028067          	jr	t0
    3160:	40b005b3          	neg	a1,a1
    3164:	fe0558e3          	bgez	a0,3154 <__modsi3+0xc>
    3168:	40a00533          	neg	a0,a0
    316c:	f61ff0ef          	jal	30cc <__hidden___udivsi3>
    3170:	40b00533          	neg	a0,a1
    3174:	00028067          	jr	t0
