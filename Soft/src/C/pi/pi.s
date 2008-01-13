	.file	1 "pi.c"

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
	.globl	a
	.sdata
	.align	0
	.align	2
a:
	.size	a,4
	.word	10000
	.globl	c
	.align	2
c:
	.size	c,4
	.word	2800
	.rdata
	.align	0
	.align	2
.LC0:
	.ascii	"\n"
	.ascii	"Done.\000"

	.comm	b,4

	.comm	d,4

	.comm	e,4

	.comm	f,11204

	.comm	g,4

	.text
	.text
	.align	2
	.globl	main
	.ent	main
main:
	.frame	$sp,24,$ra		# vars= 0, regs= 2/0, args= 16, extra= 0
	.mask	0x80010000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	sw	$ra,20($sp)
	sw	$s0,16($sp)
	lw	$v0,a
	li	$v1,1717960704			# 0x66660000
	ori	$v1,$v1,0x6667
	mult	$v0,$v1
	mfhi	$t0
	sra	$v1,$t0,1
	sra	$v0,$v0,31
	subu	$a1,$v1,$v0
	lw	$v1,b
	lw	$v0,c
	.set	noreorder
	.set	nomacro
	beq	$v1,$v0,.L3
	lui	$v0,%hi(f) # high
	.set	macro
	.set	reorder

	addiu	$a2,$v0,%lo(f) # low
	lw	$a0,c
.L5:
	lw	$v1,b
	sll	$v0,$v1,2
	addu	$v0,$v0,$a2
	sw	$a1,0($v0)
	addu	$v1,$v1,1
	sw	$v1,b
	bne	$v1,$a0,.L5
.L3:
	sw	$zero,d
	lw	$v0,c
	sll	$v0,$v0,1
	sw	$v0,g
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L17
	lui	$v0,%hi(f) # high
	.set	macro
	.set	reorder

	addiu	$s0,$v0,%lo(f) # low
.L10:
	lw	$v0,c
	sw	$v0,b
	lw	$a3,a
	b	.L11
.L13:
	lw	$v1,d
	lw	$v0,b
	mult	$v1,$v0
	mflo	$t0
	sw	$t0,d
.L11:
	lw	$a2,b
	sll	$a1,$a2,2
	addu	$a1,$a1,$s0
	lw	$v0,0($a1)
	mult	$v0,$a3
	mflo	$t1
	lw	$v1,d
	addu	$v1,$t1,$v1
	sw	$v1,d
	lw	$a0,g
	addu	$v0,$a0,-1
	sw	$v0,g
	div	$v1,$v1,$v0
	mfhi	$v0
	sw	$v0,0($a1)
	sw	$v1,d
	addu	$a0,$a0,-2
	sw	$a0,g
	addu	$a2,$a2,-1
	sw	$a2,b
	bne	$a2,$zero,.L13
	lw	$v0,c
	addu	$v0,$v0,-14
	sw	$v0,c
	lw	$v0,a
	div	$v1,$v1,$v0
	lw	$a0,e
	.set	noreorder
	.set	nomacro
	jal	print_num
	addu	$a0,$v1,$a0
	.set	macro
	.set	reorder

	lw	$v1,d
	lw	$v0,a
	rem	$v0,$v1,$v0
	sw	$v0,e
	sw	$zero,d
	lw	$v0,c
	sll	$v0,$v0,1
	sw	$v0,g
	bne	$v0,$zero,.L10
.L17:
	lui	$a0,%hi(.LC0) # high
	.set	noreorder
	.set	nomacro
	jal	putchar
	addiu	$a0,$a0,%lo(.LC0) # low
	.set	macro
	.set	reorder

	move	$v0,$zero
	lw	$ra,20($sp)
	lw	$s0,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,24
	.set	macro
	.set	reorder

	.end	main
	.size	main,.-main
