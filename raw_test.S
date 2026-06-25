.text
.global _start
_start:
	li x1, 5 	#x1 = 5
	li x2, 10	#x2 = 10

	#Hazard 1
	#EX-to-EX Forwarding (Take from MEM to EX)
	add x3, x1, x2 
	add x4, x3, x1

	#Hazard 2
	#MEM-to-EX Forwarding (Take from WB to EX)
	add x5, x4, x1
	add x0, x0, x0
	add x6, x5, x1

	# Signal PASS to testbench via tohost protocol
	li   a0, 1           # pass code = 1
	li   a1, 0x10000     # tohost address
	sw   a0, 0(a1)

	#Infinite Loop
	1: j 1b
