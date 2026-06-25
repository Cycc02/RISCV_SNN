	.file	"main.c"
	.option nopic
	.attribute arch, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_zicsr2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.globl	result
	.section	.sbss,"aw",@nobits
	.align	2
	.type	result, @object
	.size	result, 4
result:
	.zero	4
	.globl	check_result
	.align	2
	.type	check_result, @object
	.size	check_result, 4
check_result:
	.zero	4
	.text
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sd	s0,24(sp)
	addi	s0,sp,32
	sw	zero,-20(s0)
	li	a5,10
	sw	a5,-24(s0)
	sw	zero,-28(s0)
	j	.L2
.L5:
	lw	a5,-20(s0)
	addiw	a5,a5,1
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	sext.w	a4,a5
	li	a5,5
	bne	a4,a5,.L3
	lw	a5,-24(s0)
	addiw	a5,a5,-5
	sw	a5,-24(s0)
	j	.L4
.L3:
	sw	zero,-24(s0)
.L4:
	lw	a5,-28(s0)
	addiw	a5,a5,1
	sw	a5,-28(s0)
.L2:
	lw	a5,-28(s0)
	sext.w	a4,a5
	li	a5,4
	ble	a4,a5,.L5
	lui	a5,%hi(result)
	lw	a4,-20(s0)
	sw	a4,%lo(result)(a5)
	lui	a5,%hi(check_result)
	lw	a4,-24(s0)
	sw	a4,%lo(check_result)(a5)
	li	a5,0
	mv	a0,a5
	ld	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.ident	"GCC: (13.2.0-11ubuntu1+12) 13.2.0"
