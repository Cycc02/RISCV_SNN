.section .text
.global _start

_start:
	addi x1, x0, 5
	addi x2, x0, 10
	add x3, x1, x2
	addi x4, x3, 3

end_loop:
	j end_loop


