	.file	1 "endian.c"

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
	.ascii	"Little endian\n\000"
	.align	2
.LC1:
	.ascii	"Big endian\n\000"
	.align	2
.LC2:
	.ascii	"Confused\n\000"

	.text
	.text
	.align	2
	.globl	main
	.ent	main
main:
	.frame	$sp,24,$ra		# vars= 0, regs= 1/0, args= 16, extra= 0
	.mask	0x80000000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	li	$v1,18			# 0x00000012
	move	$v0,$v1
	.set	noreorder
	.set	nomacro
	bne	$v1,$v0,.L4
	sw	$ra,16($sp)
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC1) # high
	.set	noreorder
	.set	nomacro
	b	.L6
	addiu	$a0,$a0,%lo(.LC1) # low
	.set	macro
	.set	reorder

.L4:
	lui	$a0,%hi(.LC2) # high
	addiu	$a0,$a0,%lo(.LC2) # low
.L6:
	jal	print_string
	move	$v0,$zero
	lw	$ra,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,24
	.set	macro
	.set	reorder

	.end	main
	.size	main,.-main
