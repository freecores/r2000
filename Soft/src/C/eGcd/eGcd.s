	.file	1 "eGcd.c"

 # -G value = 8, Cpu = 3000, ISA = 1
 # GNU C version egcs-2.90.23 980102 (egcs-1.0.1 release) (sde) [AL 1.1, MM 40] Algorithmics SDE-MIPS v4.0.5 compiled by GNU C version egcs-2.91.57 19980901 (egcs-1.1 release).
 # options passed:  -O2 -O -Wall
 # options enabled:  -fdefer-pop -fomit-frame-pointer -fthread-jumps
 # -fpeephole -finline -fkeep-static-consts -fpcc-struct-return
 # -fdelayed-branch -fcommon -fverbose-asm -fgnu-linker -falias-check
 # -fargument-alias -msplit-addresses -mgas -mrnames -mgpOPT -mgpopt
 # -membedded-data -meb -mmad -marg32 -mdebugh -mdebugi -mmadd -mno-gpconst
 # -mcpu=3000

gcc2_compiled.:
	.rdata
	.align	0
	.align	2
.LC0:
	.ascii	"Calculate the Euclid GCD\n\000"
	.align	2
.LC1:
	.ascii	"eGCD(\000"
	.align	2
.LC2:
	.ascii	")=\000"
	.align	2
.LC3:
	.ascii	" \n\000"

	.text
	.text
	.align	2
	.globl	gcd
	.ent	gcd
gcd:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	beq	$a0,$a1,.L3
.L4:
	slt	$v0,$a1,$a0
	beq	$v0,$zero,.L5
	.set	noreorder
	.set	nomacro
	b	.L2
	subu	$a0,$a0,$a1
	.set	macro
	.set	reorder

.L5:
	subu	$a1,$a1,$a0
.L2:
	bne	$a0,$a1,.L4
.L3:
	.set	noreorder
	.set	nomacro
	j	$ra
	move	$v0,$a0
	.set	macro
	.set	reorder

	.end	gcd
	.size	gcd,.-gcd
	.text
	.align	2
	.globl	main
	.ent	main
main:
	.frame	$sp,56,$ra		# vars= 0, regs= 9/0, args= 16, extra= 0
	.mask	0x80ff0000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,56
	sw	$ra,48($sp)
	sw	$s7,44($sp)
	sw	$s6,40($sp)
	sw	$s5,36($sp)
	sw	$s4,32($sp)
	sw	$s3,28($sp)
	sw	$s2,24($sp)
	sw	$s1,20($sp)
	sw	$s0,16($sp)
	lui	$a0,%hi(.LC0) # high
	.set	noreorder
	.set	nomacro
	jal	print_string
	addiu	$a0,$a0,%lo(.LC0) # low
	.set	macro
	.set	reorder

	li	$s2,1			# 0x00000001
	lui	$s7,%hi(.LC1) # high
	li	$s6,536870912			# 0x20000000
	li	$s5,44			# 0x0000002c
	lui	$s4,%hi(.LC2) # high
	lui	$s3,%hi(.LC3) # high
	li	$s1,1			# 0x00000001
.L16:
	move	$a0,$s2
	.set	noreorder
	.set	nomacro
	jal	gcd
	move	$a1,$s1
	.set	macro
	.set	reorder

	move	$s0,$v0
	.set	noreorder
	.set	nomacro
	jal	print_string
	addiu	$a0,$s7,%lo(.LC1) # low
	.set	macro
	.set	reorder

	move	$a0,$s2
	li	$a1,10			# 0x0000000a
	.set	noreorder
	.set	nomacro
	jal	print
	move	$a2,$zero
	.set	macro
	.set	reorder

	#.set	volatile
	sb	$s5,0($s6)
	#.set	novolatile
	move	$a0,$s1
	li	$a1,10			# 0x0000000a
	.set	noreorder
	.set	nomacro
	jal	print
	move	$a2,$zero
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_string
	addiu	$a0,$s4,%lo(.LC2) # low
	.set	macro
	.set	reorder

	move	$a0,$s0
	li	$a1,10			# 0x0000000a
	.set	noreorder
	.set	nomacro
	jal	print
	move	$a2,$zero
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_string
	addiu	$a0,$s3,%lo(.LC3) # low
	.set	macro
	.set	reorder

	addu	$s1,$s1,1
	slt	$v0,$s1,5
	bne	$v0,$zero,.L16
	addu	$s2,$s2,1
	slt	$v0,$s2,5
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L16
	li	$s1,1			# 0x00000001
	.set	macro
	.set	reorder

	move	$v0,$zero
	lw	$ra,48($sp)
	lw	$s7,44($sp)
	lw	$s6,40($sp)
	lw	$s5,36($sp)
	lw	$s4,32($sp)
	lw	$s3,28($sp)
	lw	$s2,24($sp)
	lw	$s1,20($sp)
	lw	$s0,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,56
	.set	macro
	.set	reorder

	.end	main
	.size	main,.-main
