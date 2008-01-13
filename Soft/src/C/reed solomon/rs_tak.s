	.file	1 "rs_tak.c"

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
	.sdata
	.align	0
	.align	2
lfsr_state:
	.size	lfsr_state,4
	.word	1
	.globl	Pp
	.data
	.align	0
	.align	2
Pp:
	.size	Pp,36
	.word	1
	.word	0
	.word	1
	.word	1
	.word	1
	.word	0
	.word	0
	.word	0
	.word	1
	.rdata
	.align	0
	.align	2
.LC0:
	.ascii	"It takes very long time for RTL Simulation.\000"
	.align	2
.LC1:
	.ascii	"Reed-Solomon code is \000"
	.align	2
.LC2:
	.ascii	" \000"
	.align	2
.LC3:
	.ascii	" over GF(\000"
	.align	2
.LC4:
	.ascii	")\n\000"
	.align	2
.LC5:
	.ascii	"i=\000"
	.align	2
.LC6:
	.ascii	"\n\000"
	.align	2
.LC7:
	.ascii	"test erasures: \000"
	.align	2
.LC8:
	.ascii	" errors  \000"
	.align	2
.LC9:
	.ascii	"Warning: \000"
	.align	2
.LC10:
	.ascii	"errors and \000"
	.align	2
.LC11:
	.ascii	"erasures exceeds the correction ability of the code\n\000"
	.align	2
.LC12:
	.ascii	"Init_RS Done\000"
	.align	2
.LC13:
	.ascii	"\n"
	.ascii	" Trial \000"
	.align	2
.LC14:
	.ascii	" erasing:\000"
	.align	2
.LC15:
	.ascii	" erroring:\000"
	.align	2
.LC16:
	.ascii	"errs + erasures corrected: \000"
	.align	2
.LC17:
	.ascii	"RS decoder detected failure\n\000"
	.align	2
.LC18:
	.ascii	" Undetected decoding failure!\n\000"
	.align	2
.LC19:
	.ascii	"Compare Done. Passed.\n\000"
	.align	2
.LC20:
	.ascii	"\n\n\n"
	.ascii	" Total Trials: \000"
	.align	2
.LC21:
	.ascii	" decoding failures: \000"
	.align	2
.LC22:
	.ascii	" not detected by decoder: \000"
	.align	2
.LC23:
	.ascii	"$finish\000"

	.comm	Alpha_to,1024

	.comm	Index_of,1024

	.comm	Gg,132

	.comm	data,255

	.comm	tdata,255

	.comm	ddata,255

	.comm	eras_pos,1020

	.text
	.text
	.align	2
	.globl	print_uart
	.ent	print_uart
print_uart:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lbu	$v0,0($a0)
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L3
	move	$v1,$v0
	.set	macro
	.set	reorder

	li	$a1,16777216			# 0x01000000
	move	$v0,$v1
.L6:
	#.set	volatile
	sb	$v0,0($a1)
	#.set	novolatile
	addu	$a0,$a0,1
	lbu	$v1,0($a0)
	.set	noreorder
	.set	nomacro
	bne	$v1,$zero,.L6
	move	$v0,$v1
	.set	macro
	.set	reorder

.L3:
	j	$ra
	.end	print_uart
	.size	print_uart,.-print_uart
	.align	2
	.globl	putc_uart
	.ent	putc_uart
putc_uart:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	andi	$a0,$a0,0x00ff
	li	$v0,16777216			# 0x01000000
	#.set	volatile
	sb	$a0,0($v0)
	#.set	novolatile
	j	$ra
	.end	putc_uart
	.size	putc_uart,.-putc_uart
	.align	2
	.globl	read_uart
	.ent	read_uart
read_uart:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	li	$v0,16777216			# 0x01000000
	#.set	volatile
	lw	$v0,0($v0)
	#.set	novolatile
	.set	noreorder
	.set	nomacro
	j	$ra
	andi	$v0,$v0,0x00ff
	.set	macro
	.set	reorder

	.end	read_uart
	.size	read_uart,.-read_uart
	.align	2
	.globl	print
	.ent	print
print:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lbu	$v0,0($a0)
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L11
	move	$v1,$v0
	.set	macro
	.set	reorder

	li	$a1,16777216			# 0x01000000
	move	$v0,$v1
.L14:
	#.set	volatile
	sb	$v0,0($a1)
	#.set	novolatile
	addu	$a0,$a0,1
	lbu	$v1,0($a0)
	.set	noreorder
	.set	nomacro
	bne	$v1,$zero,.L14
	move	$v0,$v1
	.set	macro
	.set	reorder

.L11:
	li	$v0,16777216			# 0x01000000
	#.set	volatile
	sb	$zero,0($v0)
	#.set	novolatile
	j	$ra
	.end	print
	.size	print,.-print
	.align	2
	.globl	print_char
	.ent	print_char
print_char:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	andi	$a0,$a0,0x00ff
	li	$v0,16777216			# 0x01000000
	#.set	volatile
	sb	$a0,0($v0)
	#.set	novolatile
	j	$ra
	.end	print_char
	.size	print_char,.-print_char
	.align	2
	.globl	print_uchar
	.ent	print_uchar
print_uchar:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	andi	$a0,$a0,0x00ff
	li	$v0,16777216			# 0x01000000
	#.set	volatile
	sb	$a0,0($v0)
	#.set	novolatile
	j	$ra
	.end	print_uchar
	.size	print_uchar,.-print_uchar
	.text
	.align	2
	.globl	random
	.ent	random
random:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lw	$v1,lfsr_state
	andi	$v0,$v1,0x0001
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L18
	srl	$v0,$v1,1
	.set	macro
	.set	reorder

	li	$v1,-2147483648			# 0x80000000
	ori	$v1,$v1,0x0057
	.set	noreorder
	.set	nomacro
	b	.L20
	xor	$v0,$v0,$v1
	.set	macro
	.set	reorder

.L18:
	lw	$v0,lfsr_state
	srl	$v0,$v0,1
.L20:
	sw	$v0,lfsr_state
	lw	$v0,lfsr_state
	j	$ra
	.end	random
	.size	random,.-random
	.align	2
	.globl	print_num
	.ent	print_num
print_num:
	.frame	$sp,40,$ra		# vars= 0, regs= 5/0, args= 16, extra= 0
	.mask	0x800f0000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,40
	sw	$ra,32($sp)
	sw	$s3,28($sp)
	sw	$s2,24($sp)
	sw	$s1,20($sp)
	sw	$s0,16($sp)
	move	$s2,$a0
	li	$s1,1000			# 0x000003e8
	li	$s3,-858993459			# 0xcccccccd
.L25:
	divu	$s0,$s2,$s1
	addu	$a0,$s0,48
	.set	noreorder
	.set	nomacro
	jal	putc_uart
	andi	$a0,$a0,0x00ff
	.set	macro
	.set	reorder

	mult	$s0,$s1
	mflo	$v0
	subu	$s2,$s2,$v0
	multu	$s1,$s3
	mfhi	$v0
	srl	$s1,$v0,3
	bne	$s1,$zero,.L25
	lw	$ra,32($sp)
	lw	$s3,28($sp)
	lw	$s2,24($sp)
	lw	$s1,20($sp)
	lw	$s0,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,40
	.set	macro
	.set	reorder

	.end	print_num
	.size	print_num,.-print_num
	.align	2
	.globl	memcpy
	.ent	memcpy
memcpy:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	beq	$a2,$zero,.L29
	move	$v1,$zero
	.set	macro
	.set	reorder

.L31:
	lbu	$v0,0($a1)
	sb	$v0,0($a0)
	addu	$a1,$a1,1
	addu	$v1,$v1,1
	sltu	$v0,$v1,$a2
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L31
	addu	$a0,$a0,1
	.set	macro
	.set	reorder

.L29:
	j	$ra
	.end	memcpy
	.size	memcpy,.-memcpy
	.align	2
	.globl	memcmp
	.ent	memcmp
memcmp:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	beq	$a2,$zero,.L35
	move	$a3,$zero
	.set	macro
	.set	reorder

.L37:
	lbu	$v1,0($a0)
	lbu	$v0,0($a1)
	addu	$a1,$a1,1
	.set	noreorder
	.set	nomacro
	beq	$v1,$v0,.L36
	addu	$a0,$a0,1
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	.L40
	li	$v0,1			# 0x00000001
	.set	macro
	.set	reorder

.L36:
	addu	$a3,$a3,1
	sltu	$v0,$a3,$a2
	bne	$v0,$zero,.L37
.L35:
	move	$v0,$zero
.L40:
	j	$ra
	.end	memcmp
	.size	memcmp,.-memcmp
	.text
	.align	2
	.ent	modnn
modnn:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	slt	$v0,$a0,255
	bne	$v0,$zero,.L43
	addu	$a0,$a0,-255
.L46:
	sra	$v0,$a0,8
	andi	$v1,$a0,0x00ff
	addu	$a0,$v0,$v1
	slt	$v0,$a0,255
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L46
	addu	$a0,$a0,-255
	.set	macro
	.set	reorder

	addu	$a0,$a0,255
.L43:
	.set	noreorder
	.set	nomacro
	j	$ra
	move	$v0,$a0
	.set	macro
	.set	reorder

	.end	modnn
	.size	modnn,.-modnn
	.align	2
	.globl	init_rs
	.ent	init_rs
init_rs:
	.frame	$sp,24,$ra		# vars= 0, regs= 1/0, args= 16, extra= 0
	.mask	0x80000000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	sw	$ra,16($sp)
	jal	generate_gf
	jal	gen_poly
	lw	$ra,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,24
	.set	macro
	.set	reorder

	.end	init_rs
	.size	init_rs,.-init_rs
	.align	2
	.globl	generate_gf
	.ent	generate_gf
generate_gf:
	.frame	$sp,0,$ra		# vars= 0, regs= 0/0, args= 0, extra= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	li	$a2,1			# 0x00000001
	lui	$v0,%hi(Alpha_to+32) # high
	sw	$zero,%lo(Alpha_to+32)($v0)
	move	$a1,$zero
	lui	$v0,%hi(Alpha_to) # high
	addiu	$a0,$v0,%lo(Alpha_to) # low
	lui	$v0,%hi(Index_of) # high
	addiu	$t0,$v0,%lo(Index_of) # low
	lui	$v0,%hi(Pp) # high
	addiu	$a3,$v0,%lo(Pp) # low
.L52:
	sll	$v1,$a1,2
	addu	$v0,$v1,$a0
	sw	$a2,0($v0)
	sll	$v0,$a2,2
	addu	$v0,$v0,$t0
	sw	$a1,0($v0)
	addu	$v1,$v1,$a3
	lw	$v0,0($v1)
	beq	$v0,$zero,.L53
	lw	$v0,32($a0)
	xor	$v0,$a2,$v0
	sw	$v0,32($a0)
.L53:
	addu	$a1,$a1,1
	slt	$v0,$a1,8
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L52
	sll	$a2,$a2,1
	.set	macro
	.set	reorder

	lui	$v1,%hi(Index_of) # high
	addiu	$v1,$v1,%lo(Index_of) # low
	lui	$v0,%hi(Alpha_to+32) # high
	lw	$v0,%lo(Alpha_to+32)($v0)
	sll	$v0,$v0,2
	addu	$v0,$v0,$v1
	li	$v1,8			# 0x00000008
	sw	$v1,0($v0)
	sra	$a2,$a2,1
	li	$a1,9			# 0x00000009
	lui	$v0,%hi(Alpha_to) # high
	addiu	$a3,$v0,%lo(Alpha_to) # low
	lui	$v0,%hi(Index_of) # high
	addiu	$t0,$v0,%lo(Index_of) # low
	addu	$v0,$a1,-1
.L63:
	sll	$v0,$v0,2
	addu	$v0,$v0,$a3
	lw	$v1,0($v0)
	slt	$v0,$v1,$a2
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L59
	sll	$v0,$a1,2
	.set	macro
	.set	reorder

	addu	$v0,$v0,$a3
	xor	$v1,$a2,$v1
	sll	$v1,$v1,1
	lw	$a0,32($a3)
	.set	noreorder
	.set	nomacro
	b	.L62
	xor	$v1,$v1,$a0
	.set	macro
	.set	reorder

.L59:
	addu	$v0,$v0,$a3
	addu	$v1,$a1,-1
	sll	$v1,$v1,2
	addu	$v1,$v1,$a3
	lw	$v1,0($v1)
	sll	$v1,$v1,1
.L62:
	sw	$v1,0($v0)
	sll	$v0,$a1,2
	addu	$v0,$v0,$a3
	lw	$v0,0($v0)
	sll	$v0,$v0,2
	addu	$v0,$v0,$t0
	sw	$a1,0($v0)
	addu	$a1,$a1,1
	slt	$v0,$a1,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L63
	addu	$v0,$a1,-1
	.set	macro
	.set	reorder

	lui	$v0,%hi(Index_of) # high
	li	$v1,255			# 0x000000ff
	sw	$v1,%lo(Index_of)($v0)
	lui	$v0,%hi(Alpha_to+1020) # high
	.set	noreorder
	.set	nomacro
	j	$ra
	sw	$zero,%lo(Alpha_to+1020)($v0)
	.set	macro
	.set	reorder

	.end	generate_gf
	.size	generate_gf,.-generate_gf
	.align	2
	.globl	gen_poly
	.ent	gen_poly
gen_poly:
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
	lui	$v1,%hi(Gg) # high
	addiu	$a0,$v1,%lo(Gg) # low
	lui	$v0,%hi(Alpha_to+4) # high
	lw	$v0,%lo(Alpha_to+4)($v0)
	sw	$v0,%lo(Gg)($v1)
	li	$v0,1			# 0x00000001
	sw	$v0,4($a0)
	li	$s2,2			# 0x00000002
	move	$s7,$v1
	move	$v0,$v1
	addiu	$s3,$v0,%lo(Gg) # low
	lui	$v0,%hi(Index_of) # high
	addiu	$s6,$v0,%lo(Index_of) # low
	lui	$v0,%hi(Alpha_to) # high
	addiu	$s5,$v0,%lo(Alpha_to) # low
	sll	$v0,$s2,2
.L83:
	addu	$v0,$v0,$s3
	li	$v1,1			# 0x00000001
	addu	$s0,$s2,-1
	.set	noreorder
	.set	nomacro
	blez	$s0,.L70
	sw	$v1,0($v0)
	.set	macro
	.set	reorder

	addu	$s4,$s2,1
	sll	$v0,$s0,2
.L82:
	addu	$s1,$v0,$s3
	lw	$v0,0($s1)
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L73
	sll	$v0,$v0,2
	.set	macro
	.set	reorder

	addu	$v0,$v0,$s6
	lw	$a0,0($v0)
	addu	$a0,$s4,$a0
	.set	noreorder
	.set	nomacro
	jal	modnn
	addu	$a0,$a0,-1
	.set	macro
	.set	reorder

	addu	$v1,$s0,-1
	sll	$v1,$v1,2
	addu	$v1,$v1,$s3
	sll	$v0,$v0,2
	addu	$v0,$v0,$s5
	lw	$v1,0($v1)
	lw	$v0,0($v0)
	xor	$v1,$v1,$v0
	.set	noreorder
	.set	nomacro
	b	.L71
	sw	$v1,0($s1)
	.set	macro
	.set	reorder

.L73:
	sll	$v0,$s0,2
	addu	$v0,$v0,$s3
	addu	$v1,$s0,-1
	sll	$v1,$v1,2
	addu	$v1,$v1,$s3
	lw	$v1,0($v1)
	sw	$v1,0($v0)
.L71:
	addu	$s0,$s0,-1
	.set	noreorder
	.set	nomacro
	bgtz	$s0,.L82
	sll	$v0,$s0,2
	.set	macro
	.set	reorder

.L70:
	lw	$v0,%lo(Gg)($s7)
	sll	$v0,$v0,2
	addu	$v0,$v0,$s6
	lw	$a0,0($v0)
	addu	$s0,$s2,1
	.set	noreorder
	.set	nomacro
	jal	modnn
	addu	$a0,$s2,$a0
	.set	macro
	.set	reorder

	sll	$v0,$v0,2
	addu	$v0,$v0,$s5
	lw	$v0,0($v0)
	sw	$v0,%lo(Gg)($s7)
	move	$s2,$s0
	slt	$v0,$s2,33
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L83
	sll	$v0,$s2,2
	.set	macro
	.set	reorder

	move	$s2,$zero
	lui	$v0,%hi(Gg) # high
	addiu	$a1,$v0,%lo(Gg) # low
	lui	$v0,%hi(Index_of) # high
	addiu	$a0,$v0,%lo(Index_of) # low
.L80:
	sll	$v1,$s2,2
	addu	$v1,$v1,$a1
	lw	$v0,0($v1)
	sll	$v0,$v0,2
	addu	$v0,$v0,$a0
	lw	$v0,0($v0)
	sw	$v0,0($v1)
	addu	$s2,$s2,1
	slt	$v0,$s2,33
	bne	$v0,$zero,.L80
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

	.end	gen_poly
	.size	gen_poly,.-gen_poly
	.align	2
	.globl	encode_rs
	.ent	encode_rs
encode_rs:
	.frame	$sp,56,$ra		# vars= 0, regs= 10/0, args= 16, extra= 0
	.mask	0xc0ff0000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,56
	sw	$ra,52($sp)
	sw	$fp,48($sp)
	sw	$s7,44($sp)
	sw	$s6,40($sp)
	sw	$s5,36($sp)
	sw	$s4,32($sp)
	sw	$s3,28($sp)
	sw	$s2,24($sp)
	sw	$s1,20($sp)
	sw	$s0,16($sp)
	sw	$a0,56($sp)
	move	$s2,$a1
	li	$v1,31			# 0x0000001f
.L88:
	addu	$v0,$s2,$v1
	addu	$v1,$v1,-1
	.set	noreorder
	.set	nomacro
	bgez	$v1,.L88
	sb	$zero,0($v0)
	.set	macro
	.set	reorder

	li	$s3,222			# 0x000000de
	lui	$v0,%hi(Index_of) # high
	addiu	$fp,$v0,%lo(Index_of) # low
	li	$s5,255			# 0x000000ff
	lui	$s7,%hi(Gg) # high
	move	$v0,$s7
	addiu	$s6,$v0,%lo(Gg) # low
	lui	$v0,%hi(Alpha_to) # high
	addiu	$s4,$v0,%lo(Alpha_to) # low
.L93:
	lw	$a2,56($sp)
	addu	$v0,$a2,$s3
	lbu	$v0,0($v0)
	lbu	$v1,31($s2)
	xor	$v0,$v0,$v1
	sll	$v0,$v0,2
	addu	$v0,$v0,$fp
	lw	$s1,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$s1,$s5,.L94
	li	$s0,31			# 0x0000001f
	.set	macro
	.set	reorder

	sll	$v0,$s0,2
.L109:
	addu	$v0,$v0,$s6
	lw	$v0,0($v0)
	beq	$v0,$s5,.L99
	.set	noreorder
	.set	nomacro
	jal	modnn
	addu	$a0,$s1,$v0
	.set	macro
	.set	reorder

	addu	$a0,$s2,$s0
	sll	$v0,$v0,2
	addu	$v0,$v0,$s4
	lbu	$v1,-1($a0)
	lbu	$v0,3($v0)
	xor	$v1,$v1,$v0
	.set	noreorder
	.set	nomacro
	b	.L97
	sb	$v1,0($a0)
	.set	macro
	.set	reorder

.L99:
	addu	$v0,$s2,$s0
	lbu	$v1,-1($v0)
	sb	$v1,0($v0)
.L97:
	addu	$s0,$s0,-1
	.set	noreorder
	.set	nomacro
	bgtz	$s0,.L109
	sll	$v0,$s0,2
	.set	macro
	.set	reorder

	lw	$a0,%lo(Gg)($s7)
	.set	noreorder
	.set	nomacro
	jal	modnn
	addu	$a0,$s1,$a0
	.set	macro
	.set	reorder

	sll	$v0,$v0,2
	addu	$v0,$v0,$s4
	lbu	$v0,3($v0)
	.set	noreorder
	.set	nomacro
	b	.L92
	sb	$v0,0($s2)
	.set	macro
	.set	reorder

.L94:
.L106:
	addu	$v0,$s2,$s0
	lbu	$v1,-1($v0)
	addu	$s0,$s0,-1
	.set	noreorder
	.set	nomacro
	bgtz	$s0,.L106
	sb	$v1,0($v0)
	.set	macro
	.set	reorder

	sb	$zero,0($s2)
.L92:
	addu	$s3,$s3,-1
	.set	noreorder
	.set	nomacro
	bgez	$s3,.L93
	move	$v0,$zero
	.set	macro
	.set	reorder

	lw	$ra,52($sp)
	lw	$fp,48($sp)
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

	.end	encode_rs
	.size	encode_rs,.-encode_rs
	.align	2
	.globl	eras_dec_rs
	.ent	eras_dec_rs
eras_dec_rs:
	.frame	$sp,2176,$ra		# vars= 2120, regs= 10/0, args= 16, extra= 0
	.mask	0xc0ff0000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,2176
	sw	$ra,2172($sp)
	sw	$fp,2168($sp)
	sw	$s7,2164($sp)
	sw	$s6,2160($sp)
	sw	$s5,2156($sp)
	sw	$s4,2152($sp)
	sw	$s3,2148($sp)
	sw	$s2,2144($sp)
	sw	$s1,2140($sp)
	sw	$s0,2136($sp)
	sw	$a0,2176($sp)
	move	$fp,$a1
	sw	$a2,2184($sp)
	li	$s0,254			# 0x000000fe
	addu	$a0,$sp,16
	lui	$v0,%hi(Index_of) # high
	addiu	$a1,$v0,%lo(Index_of) # low
.L114:
	sll	$v1,$s0,2
	addu	$v1,$a0,$v1
	lw	$a3,2176($sp)
	addu	$v0,$a3,$s0
	lbu	$v0,0($v0)
	sll	$v0,$v0,2
	addu	$v0,$v0,$a1
	lw	$v0,0($v0)
	addu	$s0,$s0,-1
	.set	noreorder
	.set	nomacro
	bgez	$s0,.L114
	sw	$v0,0($v1)
	.set	macro
	.set	reorder

	move	$s3,$zero
	li	$s0,1			# 0x00000001
	addu	$s4,$sp,16
	li	$s6,255			# 0x000000ff
	lui	$v0,%hi(Alpha_to) # high
	addiu	$s5,$v0,%lo(Alpha_to) # low
.L119:
	move	$s1,$zero
	move	$s2,$s1
	sll	$v0,$s2,2
.L257:
	addu	$v0,$s4,$v0
	lw	$v0,0($v0)
	beq	$v0,$s6,.L122
	mult	$s0,$s2
	mflo	$a3
	.set	noreorder
	.set	nomacro
	jal	modnn
	addu	$a0,$a3,$v0
	.set	macro
	.set	reorder

	sll	$v0,$v0,2
	addu	$v0,$v0,$s5
	lw	$v0,0($v0)
	xor	$s1,$s1,$v0
.L122:
	addu	$s2,$s2,1
	slt	$v0,$s2,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L257
	sll	$v0,$s2,2
	.set	macro
	.set	reorder

	sll	$v0,$s0,2
	addu	$a0,$sp,$v0
	lui	$v1,%hi(Index_of) # high
	addiu	$v1,$v1,%lo(Index_of) # low
	sll	$v0,$s1,2
	addu	$v0,$v0,$v1
	lw	$v0,0($v0)
	sw	$v0,1176($a0)
	addu	$s0,$s0,1
	slt	$v0,$s0,33
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L119
	or	$s3,$s3,$s1
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bne	$s3,$zero,.L127
	li	$v1,31			# 0x0000001f
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	.L251
	move	$v0,$zero
	.set	macro
	.set	reorder

.L127:
	addu	$a0,$sp,1044
.L131:
	sll	$v0,$v1,2
	addu	$v0,$a0,$v0
	addu	$v1,$v1,-1
	.set	noreorder
	.set	nomacro
	bgez	$v1,.L131
	sw	$zero,0($v0)
	.set	macro
	.set	reorder

	li	$v0,1			# 0x00000001
	sw	$v0,1040($sp)
	lw	$a3,2184($sp)
	.set	noreorder
	.set	nomacro
	blez	$a3,.L133
	lui	$v1,%hi(Alpha_to) # high
	.set	macro
	.set	reorder

	addiu	$v1,$v1,%lo(Alpha_to) # low
	lw	$v0,0($fp)
	sll	$v0,$v0,2
	addu	$v0,$v0,$v1
	lw	$v0,0($v0)
	sw	$v0,1044($sp)
	li	$s0,1			# 0x00000001
	slt	$v0,$s0,$a3
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L133
	lui	$v0,%hi(Index_of) # high
	.set	macro
	.set	reorder

	addiu	$s7,$v0,%lo(Index_of) # low
	addu	$s3,$sp,1040
	li	$s6,255			# 0x000000ff
	sll	$v0,$s0,2
.L259:
	addu	$v0,$v0,$fp
	lw	$s4,0($v0)
	addu	$s2,$s0,1
	.set	noreorder
	.set	nomacro
	blez	$s2,.L136
	lui	$v0,%hi(Alpha_to) # high
	.set	macro
	.set	reorder

	addiu	$s5,$v0,%lo(Alpha_to) # low
	addu	$v0,$s2,-1
.L258:
	sll	$v0,$v0,2
	addu	$v0,$s3,$v0
	lw	$v0,0($v0)
	sll	$v0,$v0,2
	addu	$v0,$v0,$s7
	lw	$s1,0($v0)
	beq	$s1,$s6,.L140
	.set	noreorder
	.set	nomacro
	jal	modnn
	addu	$a0,$s4,$s1
	.set	macro
	.set	reorder

	sll	$a0,$s2,2
	addu	$a0,$s3,$a0
	sll	$v0,$v0,2
	addu	$v0,$v0,$s5
	lw	$v1,0($a0)
	lw	$v0,0($v0)
	xor	$v1,$v1,$v0
	sw	$v1,0($a0)
.L140:
	addu	$s2,$s2,-1
	.set	noreorder
	.set	nomacro
	bgtz	$s2,.L258
	addu	$v0,$s2,-1
	.set	macro
	.set	reorder

.L136:
	addu	$s0,$s0,1
	lw	$a3,2184($sp)
	slt	$v0,$s0,$a3
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L259
	sll	$v0,$s0,2
	.set	macro
	.set	reorder

.L133:
	move	$s0,$zero
	addu	$a1,$sp,1312
	lui	$v0,%hi(Index_of) # high
	addiu	$a2,$v0,%lo(Index_of) # low
	addu	$a0,$sp,1040
	sll	$v0,$s0,2
.L260:
	addu	$v1,$a1,$v0
	addu	$v0,$a0,$v0
	lw	$v0,0($v0)
	sll	$v0,$v0,2
	addu	$v0,$v0,$a2
	lw	$v0,0($v0)
	sw	$v0,0($v1)
	addu	$s0,$s0,1
	slt	$v0,$s0,33
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L260
	sll	$v0,$s0,2
	.set	macro
	.set	reorder

	lw	$s3,2184($sp)
	sw	$s3,2112($sp)
	addu	$s3,$s3,1
	slt	$v0,$s3,33
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L151
	addu	$a3,$sp,1176
	.set	macro
	.set	reorder

	addu	$s5,$sp,1040
	sw	$a3,2124($sp)
	li	$s7,255			# 0x000000ff
	lui	$v0,%hi(Index_of) # high
	addiu	$fp,$v0,%lo(Index_of) # low
	move	$s1,$zero
.L264:
	.set	noreorder
	.set	nomacro
	blez	$s3,.L154
	move	$s0,$s1
	.set	macro
	.set	reorder

	lui	$v0,%hi(Alpha_to) # high
	addiu	$s2,$v0,%lo(Alpha_to) # low
	sll	$v0,$s0,2
.L261:
	addu	$v0,$s5,$v0
	lw	$a0,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$a0,$zero,.L155
	subu	$v0,$s3,$s0
	.set	macro
	.set	reorder

	sll	$v0,$v0,2
	lw	$a3,2124($sp)
	addu	$v0,$a3,$v0
	lw	$v1,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$v1,$s7,.L155
	sll	$v0,$a0,2
	.set	macro
	.set	reorder

	addu	$v0,$v0,$fp
	lw	$a0,0($v0)
	.set	noreorder
	.set	nomacro
	jal	modnn
	addu	$a0,$a0,$v1
	.set	macro
	.set	reorder

	sll	$v0,$v0,2
	addu	$v0,$v0,$s2
	lw	$v0,0($v0)
	xor	$s1,$s1,$v0
.L155:
	addu	$s0,$s0,1
	slt	$v0,$s0,$s3
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L261
	sll	$v0,$s0,2
	.set	macro
	.set	reorder

.L154:
	sll	$v0,$s1,2
	addu	$v0,$v0,$fp
	lw	$s1,0($v0)
	.set	noreorder
	.set	nomacro
	bne	$s1,$s7,.L159
	li	$a0,31			# 0x0000001f
	.set	macro
	.set	reorder

	addu	$a2,$sp,1316
	addu	$a1,$sp,1312
.L163:
	sll	$v0,$a0,2
	addu	$v1,$a2,$v0
	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	addu	$a0,$a0,-1
	.set	noreorder
	.set	nomacro
	bgez	$a0,.L163
	sw	$v0,0($v1)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	.L150
	sw	$s7,1312($sp)
	.set	macro
	.set	reorder

.L159:
	lw	$v0,1040($sp)
	sw	$v0,1448($sp)
	move	$s0,$zero
	addu	$s4,$sp,1312
	addu	$s2,$sp,1448
	lui	$v0,%hi(Alpha_to) # high
	addiu	$s6,$v0,%lo(Alpha_to) # low
	sll	$v0,$s0,2
.L262:
	addu	$v0,$s4,$v0
	lw	$v0,0($v0)
	beq	$v0,$s7,.L170
	.set	noreorder
	.set	nomacro
	jal	modnn
	addu	$a0,$s1,$v0
	.set	macro
	.set	reorder

	addu	$v1,$s0,1
	sll	$v1,$v1,2
	addu	$a0,$s2,$v1
	addu	$v1,$s5,$v1
	sll	$v0,$v0,2
	addu	$v0,$v0,$s6
	lw	$v1,0($v1)
	lw	$v0,0($v0)
	xor	$v1,$v1,$v0
	.set	noreorder
	.set	nomacro
	b	.L168
	sw	$v1,0($a0)
	.set	macro
	.set	reorder

.L170:
	addu	$v0,$s0,1
	sll	$v0,$v0,2
	addu	$v1,$s2,$v0
	addu	$v0,$s5,$v0
	lw	$v0,0($v0)
	sw	$v0,0($v1)
.L168:
	addu	$s0,$s0,1
	slt	$v0,$s0,32
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L262
	sll	$v0,$s0,2
	.set	macro
	.set	reorder

	lw	$a3,2112($sp)
	sll	$v1,$a3,1
	lw	$a3,2184($sp)
	addu	$a0,$s3,$a3
	addu	$v0,$a0,-1
	slt	$v0,$v0,$v1
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L173
	addu	$a2,$sp,1316
	.set	macro
	.set	reorder

	lw	$a3,2112($sp)
	subu	$a3,$a0,$a3
	sw	$a3,2112($sp)
	move	$s0,$zero
	addu	$s4,$sp,1312
	sll	$v0,$s0,2
.L263:
	addu	$s2,$s4,$v0
	addu	$v0,$s5,$v0
	lw	$v0,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L178
	sll	$v0,$v0,2
	.set	macro
	.set	reorder

	addu	$v0,$v0,$fp
	lw	$a0,0($v0)
	subu	$a0,$a0,$s1
	.set	noreorder
	.set	nomacro
	jal	modnn
	addu	$a0,$a0,255
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	.L255
	sw	$v0,0($s2)
	.set	macro
	.set	reorder

.L178:
	li	$v0,255			# 0x000000ff
	sw	$v0,0($s2)
.L255:
	addu	$s0,$s0,1
	slt	$v0,$s0,33
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L263
	sll	$v0,$s0,2
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	.L256
	li	$a0,32			# 0x00000020
	.set	macro
	.set	reorder

.L173:
	li	$a0,31			# 0x0000001f
	addu	$a1,$sp,1312
.L185:
	sll	$v0,$a0,2
	addu	$v1,$a2,$v0
	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	addu	$a0,$a0,-1
	.set	noreorder
	.set	nomacro
	bgez	$a0,.L185
	sw	$v0,0($v1)
	.set	macro
	.set	reorder

	sw	$s7,1312($sp)
	li	$a0,32			# 0x00000020
.L256:
	addu	$a1,$sp,1448
.L190:
	sll	$v0,$a0,2
	addu	$v1,$s5,$v0
	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	addu	$a0,$a0,-1
	.set	noreorder
	.set	nomacro
	bgez	$a0,.L190
	sw	$v0,0($v1)
	.set	macro
	.set	reorder

.L150:
	addu	$s3,$s3,1
	slt	$v0,$s3,33
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L264
	move	$s1,$zero
	.set	macro
	.set	reorder

.L151:
	move	$fp,$zero
	move	$s0,$fp
	addu	$a0,$sp,1040
	lui	$v0,%hi(Index_of) # high
	addiu	$a2,$v0,%lo(Index_of) # low
	li	$a1,255			# 0x000000ff
	sll	$v0,$s0,2
.L265:
	addu	$v0,$a0,$v0
	lw	$v1,0($v0)
	sll	$v1,$v1,2
	addu	$v1,$v1,$a2
	lw	$v1,0($v1)
	.set	noreorder
	.set	nomacro
	beq	$v1,$a1,.L195
	sw	$v1,0($v0)
	.set	macro
	.set	reorder

	move	$fp,$s0
.L195:
	addu	$s0,$s0,1
	slt	$v0,$s0,33
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L265
	sll	$v0,$s0,2
	.set	macro
	.set	reorder

	li	$a0,31			# 0x0000001f
	addu	$a2,$sp,1852
	addu	$a1,$sp,1044
.L202:
	sll	$v0,$a0,2
	addu	$v1,$a2,$v0
	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	addu	$a0,$a0,-1
	.set	noreorder
	.set	nomacro
	bgez	$a0,.L202
	sw	$v0,0($v1)
	.set	macro
	.set	reorder

	sw	$zero,2120($sp)
	li	$s0,1			# 0x00000001
	addu	$s4,$sp,1848
	li	$s5,255			# 0x000000ff
	lui	$v0,%hi(Alpha_to) # high
	addiu	$s6,$v0,%lo(Alpha_to) # low
.L207:
	move	$s2,$fp
	.set	noreorder
	.set	nomacro
	blez	$s2,.L209
	li	$s3,1			# 0x00000001
	.set	macro
	.set	reorder

	sll	$v0,$s2,2
.L266:
	addu	$s1,$s4,$v0
	lw	$v0,0($s1)
	beq	$v0,$s5,.L210
	.set	noreorder
	.set	nomacro
	jal	modnn
	addu	$a0,$s2,$v0
	.set	macro
	.set	reorder

	sw	$v0,0($s1)
	sll	$v0,$v0,2
	addu	$v0,$v0,$s6
	lw	$v0,0($v0)
	xor	$s3,$s3,$v0
.L210:
	addu	$s2,$s2,-1
	.set	noreorder
	.set	nomacro
	bgtz	$s2,.L266
	sll	$v0,$s2,2
	.set	macro
	.set	reorder

.L209:
	bne	$s3,$zero,.L206
	lw	$a3,2120($sp)
	sll	$v1,$a3,2
	addu	$v0,$sp,$v1
	sw	$s0,1720($v0)
	move	$v1,$v0
	subu	$v0,$s5,$s0
	sw	$v0,1984($v1)
	addu	$a3,$a3,1
	sw	$a3,2120($sp)
.L206:
	addu	$s0,$s0,1
	slt	$v0,$s0,256
	bne	$v0,$zero,.L207
	lw	$a3,2120($sp)
	.set	noreorder
	.set	nomacro
	beq	$fp,$a3,.L216
	move	$s0,$zero
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	b	.L251
	li	$v0,-1			# 0xffffffff
	.set	macro
	.set	reorder

.L216:
	sw	$zero,2116($sp)
	addu	$s4,$sp,1176
	li	$s5,255			# 0x000000ff
	addu	$s3,$sp,1040
	lui	$v0,%hi(Alpha_to) # high
	addiu	$s6,$v0,%lo(Alpha_to) # low
.L220:
	move	$s1,$zero
	slt	$v0,$fp,$s0
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L221
	move	$s2,$s0
	.set	macro
	.set	reorder

	move	$s2,$fp
.L221:
	.set	noreorder
	.set	nomacro
	bltz	$s2,.L252
	addu	$v0,$s2,-1
	.set	macro
	.set	reorder

.L267:
	subu	$v0,$s0,$v0
	sll	$v0,$v0,2
	addu	$v0,$s4,$v0
	lw	$a0,0($v0)
	.set	noreorder
	.set	nomacro
	beq	$a0,$s5,.L225
	sll	$v0,$s2,2
	.set	macro
	.set	reorder

	addu	$v0,$s3,$v0
	lw	$v0,0($v0)
	beq	$v0,$s5,.L225
	.set	noreorder
	.set	nomacro
	jal	modnn
	addu	$a0,$a0,$v0
	.set	macro
	.set	reorder

	sll	$v0,$v0,2
	addu	$v0,$v0,$s6
	lw	$v0,0($v0)
	xor	$s1,$s1,$v0
.L225:
	addu	$s2,$s2,-1
	.set	noreorder
	.set	nomacro
	bgez	$s2,.L267
	addu	$v0,$s2,-1
	.set	macro
	.set	reorder

.L252:
	.set	noreorder
	.set	nomacro
	beq	$s1,$zero,.L268
	sll	$v0,$s0,2
	.set	macro
	.set	reorder

	sw	$s0,2116($sp)
.L268:
	addu	$a0,$sp,$v0
	lui	$v1,%hi(Index_of) # high
	addiu	$v1,$v1,%lo(Index_of) # low
	sll	$v0,$s1,2
	addu	$v0,$v0,$v1
	lw	$v0,0($v0)
	sw	$v0,1584($a0)
	addu	$s0,$s0,1
	slt	$v0,$s0,32
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L220
	li	$v0,255			# 0x000000ff
	.set	macro
	.set	reorder

	sw	$v0,1712($sp)
	lw	$a3,2120($sp)
	addu	$s2,$a3,-1
	.set	noreorder
	.set	nomacro
	bltz	$s2,.L232
	addu	$a3,$sp,1584
	.set	macro
	.set	reorder

	sw	$a3,2128($sp)
	addu	$a3,$sp,1720
	sw	$a3,2132($sp)
	lui	$v0,%hi(Alpha_to) # high
	addiu	$s7,$v0,%lo(Alpha_to) # low
.L234:
	lw	$s0,2116($sp)
	.set	noreorder
	.set	nomacro
	bltz	$s0,.L236
	move	$s3,$zero
	.set	macro
	.set	reorder

	sll	$v0,$s2,2
	lw	$a3,2132($sp)
	addu	$s1,$a3,$v0
	sll	$v0,$s0,2
.L269:
	lw	$a3,2128($sp)
	addu	$v0,$a3,$v0
	lw	$v1,0($v0)
	li	$a3,255			# 0x000000ff
	beq	$v1,$a3,.L237
	lw	$v0,0($s1)
	mult	$s0,$v0
	mflo	$a3
	.set	noreorder
	.set	nomacro
	jal	modnn
	addu	$a0,$a3,$v1
	.set	macro
	.set	reorder

	sll	$v0,$v0,2
	addu	$v0,$v0,$s7
	lw	$v0,0($v0)
	xor	$s3,$s3,$v0
.L237:
	addu	$s0,$s0,-1
	.set	noreorder
	.set	nomacro
	bgez	$s0,.L269
	sll	$v0,$s0,2
	.set	macro
	.set	reorder

.L236:
	.set	noreorder
	.set	nomacro
	jal	modnn
	li	$a0,255			# 0x000000ff
	.set	macro
	.set	reorder

	sll	$v0,$v0,2
	addu	$v0,$v0,$s7
	lw	$s6,0($v0)
	move	$v1,$fp
	slt	$v0,$v1,32
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L241
	move	$s1,$zero
	.set	macro
	.set	reorder

	li	$v1,31			# 0x0000001f
.L241:
	li	$v0,-2			# 0xfffffffe
	and	$s0,$v1,$v0
	.set	noreorder
	.set	nomacro
	bltz	$s0,.L243
	sll	$v0,$s2,2
	.set	macro
	.set	reorder

	addu	$s5,$sp,1040
	lw	$a3,2132($sp)
	addu	$s4,$a3,$v0
	addu	$v0,$s0,1
.L270:
	sll	$v0,$v0,2
	addu	$v0,$s5,$v0
	lw	$v1,0($v0)
	li	$a3,255			# 0x000000ff
	beq	$v1,$a3,.L244
	lw	$v0,0($s4)
	mult	$s0,$v0
	mflo	$a3
	.set	noreorder
	.set	nomacro
	jal	modnn
	addu	$a0,$a3,$v1
	.set	macro
	.set	reorder

	sll	$v0,$v0,2
	addu	$v0,$v0,$s7
	lw	$v0,0($v0)
	xor	$s1,$s1,$v0
.L244:
	addu	$s0,$s0,-2
	.set	noreorder
	.set	nomacro
	bgez	$s0,.L270
	addu	$v0,$s0,1
	.set	macro
	.set	reorder

.L243:
	.set	noreorder
	.set	nomacro
	beq	$s1,$zero,.L251
	li	$v0,-1			# 0xffffffff
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$s3,$zero,.L233
	lui	$a0,%hi(Index_of) # high
	.set	macro
	.set	reorder

	addiu	$a0,$a0,%lo(Index_of) # low
	sll	$v1,$s3,2
	addu	$v1,$v1,$a0
	sll	$v0,$s6,2
	addu	$v0,$v0,$a0
	lw	$v1,0($v1)
	lw	$v0,0($v0)
	addu	$v1,$v1,$v0
	sll	$v0,$s1,2
	addu	$v0,$v0,$a0
	lw	$a0,0($v0)
	addu	$a0,$a0,-255
	.set	noreorder
	.set	nomacro
	jal	modnn
	subu	$a0,$v1,$a0
	.set	macro
	.set	reorder

	sll	$v1,$s2,2
	addu	$v1,$sp,$v1
	lw	$a0,1984($v1)
	lw	$a3,2176($sp)
	addu	$a0,$a3,$a0
	sll	$v0,$v0,2
	addu	$v0,$v0,$s7
	lbu	$v1,0($a0)
	lbu	$v0,3($v0)
	xor	$v1,$v1,$v0
	sb	$v1,0($a0)
.L233:
	addu	$s2,$s2,-1
	bgez	$s2,.L234
.L232:
	lw	$v0,2120($sp)
.L251:
	lw	$ra,2172($sp)
	lw	$fp,2168($sp)
	lw	$s7,2164($sp)
	lw	$s6,2160($sp)
	lw	$s5,2156($sp)
	lw	$s4,2152($sp)
	lw	$s3,2148($sp)
	lw	$s2,2144($sp)
	lw	$s1,2140($sp)
	lw	$s0,2136($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,2176
	.set	macro
	.set	reorder

	.end	eras_dec_rs
	.size	eras_dec_rs,.-eras_dec_rs
	.align	2
	.globl	fill_eras
	.ent	fill_eras
fill_eras:
	.frame	$sp,1064,$ra		# vars= 1024, regs= 5/0, args= 16, extra= 0
	.mask	0x800f0000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,1064
	sw	$ra,1056($sp)
	sw	$s3,1052($sp)
	sw	$s2,1048($sp)
	sw	$s1,1044($sp)
	sw	$s0,1040($sp)
	move	$s3,$a0
	move	$s2,$a1
	move	$a0,$zero
	addu	$v1,$sp,16
	sll	$v0,$a0,2
.L287:
	addu	$v0,$v1,$v0
	sw	$a0,0($v0)
	addu	$a0,$a0,1
	slt	$v0,$a0,255
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L287
	sll	$v0,$a0,2
	.set	macro
	.set	reorder

	li	$s0,254			# 0x000000fe
	addu	$s1,$sp,16
.L280:
	jal	random
	remu	$a0,$v0,$s0
	sll	$a0,$a0,2
	addu	$a0,$s1,$a0
	lw	$a1,0($a0)
	sll	$v1,$s0,2
	addu	$v1,$s1,$v1
	lw	$v0,0($v1)
	sw	$v0,0($a0)
	addu	$s0,$s0,-1
	.set	noreorder
	.set	nomacro
	bgtz	$s0,.L280
	sw	$a1,0($v1)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	blez	$s2,.L283
	move	$a0,$zero
	.set	macro
	.set	reorder

	addu	$a1,$sp,16
	sll	$v0,$a0,2
.L288:
	addu	$v1,$v0,$s3
	addu	$v0,$a1,$v0
	lw	$v0,0($v0)
	sw	$v0,0($v1)
	addu	$a0,$a0,1
	slt	$v0,$a0,$s2
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L288
	sll	$v0,$a0,2
	.set	macro
	.set	reorder

.L283:
	lw	$ra,1056($sp)
	lw	$s3,1052($sp)
	lw	$s2,1048($sp)
	lw	$s1,1044($sp)
	lw	$s0,1040($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,1064
	.set	macro
	.set	reorder

	.end	fill_eras
	.size	fill_eras,.-fill_eras
	.align	2
	.globl	randomnz
	.ent	randomnz
randomnz:
	.frame	$sp,24,$ra		# vars= 0, regs= 1/0, args= 16, extra= 0
	.mask	0x80000000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,24
	sw	$ra,16($sp)
.L290:
	jal	random
	andi	$v0,$v0,0x00ff
	beq	$v0,$zero,.L290
	lw	$ra,16($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,24
	.set	macro
	.set	reorder

	.end	randomnz
	.size	randomnz,.-randomnz
	.text
	.align	2
	.globl	main2
	.ent	main2
main2:
	.frame	$sp,72,$ra		# vars= 16, regs= 10/0, args= 16, extra= 0
	.mask	0xc0ff0000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,72
	sw	$ra,68($sp)
	sw	$fp,64($sp)
	sw	$s7,60($sp)
	sw	$s6,56($sp)
	sw	$s5,52($sp)
	sw	$s4,48($sp)
	sw	$s3,44($sp)
	sw	$s2,40($sp)
	sw	$s1,36($sp)
	sw	$s0,32($sp)
	li	$s6,11			# 0x0000000b
	li	$s3,10			# 0x0000000a
	lui	$a0,%hi(.LC0) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC0) # low
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC1) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC1) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	li	$a0,255			# 0x000000ff
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC2) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC2) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	li	$a0,223			# 0x000000df
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC3) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC3) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	li	$a0,256			# 0x00000100
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC4) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC4) # low
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC5) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC5) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	move	$a0,$zero
	.set	macro
	.set	reorder

	lui	$s0,%hi(.LC6) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$s0,%lo(.LC6) # low
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC7) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC7) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	move	$a0,$s3
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC8) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC8) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	move	$a0,$s6
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$s0,%lo(.LC6) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	init_rs
	move	$s4,$zero
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC12) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC12) # low
	.set	macro
	.set	reorder

	sw	$zero,16($sp)
	li	$a3,120			# 0x00000078
	.set	noreorder
	.set	nomacro
	beq	$a3,$zero,.L296
	sw	$zero,20($sp)
	.set	macro
	.set	reorder

	move	$s7,$s0
	lui	$v0,%hi(data) # high
	addiu	$fp,$v0,%lo(data) # low
	li	$a3,1			# 0x00000001
	sltu	$a3,$zero,$a3
	sw	$a3,24($sp)
	lui	$v0,%hi(eras_pos) # high
	addiu	$s5,$v0,%lo(eras_pos) # low
	li	$a3,1			# 0x00000001
.L333:
	.set	noreorder
	.set	nomacro
	beq	$a3,$zero,.L299
	lui	$a0,%hi(.LC13) # high
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC13) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	move	$a0,$s4
	.set	macro
	.set	reorder

.L299:
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$s7,%lo(.LC6) # low
	.set	macro
	.set	reorder

	move	$s0,$zero
.L303:
	jal	random
	addu	$v1,$s0,$fp
	sb	$v0,0($v1)
	addu	$s0,$s0,1
	slt	$v0,$s0,223
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L303
	move	$a0,$fp
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	encode_rs
	addu	$a1,$fp,223
	.set	macro
	.set	reorder

	lui	$a3,%hi(eras_pos) # high
	addiu	$a0,$a3,%lo(eras_pos) # low
	.set	noreorder
	.set	nomacro
	jal	fill_eras
	addu	$a1,$s3,$s6
	.set	macro
	.set	reorder

	sltu	$v0,$zero,$s3
	lw	$a3,24($sp)
	and	$v0,$a3,$v0
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L330
	sltu	$v0,$zero,$s6
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC14) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC14) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$s3,$zero,.L307
	move	$s0,$zero
	.set	macro
	.set	reorder

	lui	$a3,%hi(.LC2) # high
.L331:
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a3,%lo(.LC2) # low
	.set	macro
	.set	reorder

	sll	$v0,$s0,2
	addu	$v0,$v0,$s5
	lw	$a0,0($v0)
	.set	noreorder
	.set	nomacro
	jal	print_num
	addu	$s0,$s0,1
	.set	macro
	.set	reorder

	slt	$v0,$s0,$s3
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L331
	lui	$a3,%hi(.LC2) # high
	.set	macro
	.set	reorder

.L307:
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$s7,%lo(.LC6) # low
	.set	macro
	.set	reorder

	sltu	$v0,$zero,$s6
	lw	$a3,24($sp)
.L330:
	and	$v0,$a3,$v0
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L311
	lui	$a0,%hi(.LC15) # high
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC15) # low
	.set	macro
	.set	reorder

	move	$s0,$s3
	addu	$v0,$s0,$s6
	slt	$v0,$s0,$v0
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L313
	lui	$a3,%hi(.LC2) # high
	.set	macro
	.set	reorder

	addu	$s1,$s3,$s6
.L332:
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a3,%lo(.LC2) # low
	.set	macro
	.set	reorder

	sll	$v0,$s0,2
	addu	$v0,$v0,$s5
	lw	$a0,0($v0)
	.set	noreorder
	.set	nomacro
	jal	print_num
	addu	$s0,$s0,1
	.set	macro
	.set	reorder

	slt	$v0,$s0,$s1
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L332
	lui	$a3,%hi(.LC2) # high
	.set	macro
	.set	reorder

.L313:
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$s7,%lo(.LC6) # low
	.set	macro
	.set	reorder

.L311:
	lui	$a3,%hi(ddata) # high
	addiu	$a0,$a3,%lo(ddata) # low
	lui	$a3,%hi(data) # high
	addiu	$a1,$a3,%lo(data) # low
	.set	noreorder
	.set	nomacro
	jal	memcpy
	li	$a2,255			# 0x000000ff
	.set	macro
	.set	reorder

	addu	$v0,$s3,$s6
	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L319
	move	$s0,$zero
	.set	macro
	.set	reorder

	lui	$v0,%hi(ddata) # high
	addiu	$s2,$v0,%lo(ddata) # low
	addu	$s1,$s3,$s6
.L321:
	jal	randomnz
	sll	$v1,$s0,2
	addu	$v1,$v1,$s5
	lw	$a0,0($v1)
	addu	$a0,$a0,$s2
	lbu	$v1,0($a0)
	xor	$v1,$v1,$v0
	addu	$s0,$s0,1
	slt	$v0,$s0,$s1
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L321
	sb	$v1,0($a0)
	.set	macro
	.set	reorder

.L319:
	lui	$a3,%hi(ddata) # high
	addiu	$a0,$a3,%lo(ddata) # low
	lui	$a3,%hi(eras_pos) # high
	addiu	$a1,$a3,%lo(eras_pos) # low
	.set	noreorder
	.set	nomacro
	jal	eras_dec_rs
	move	$a2,$s3
	.set	macro
	.set	reorder

	li	$a3,1			# 0x00000001
	.set	noreorder
	.set	nomacro
	beq	$a3,$zero,.L323
	move	$s0,$v0
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC16) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC16) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	move	$a0,$s0
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$s7,%lo(.LC6) # low
	.set	macro
	.set	reorder

.L323:
	li	$v0,-1			# 0xffffffff
	.set	noreorder
	.set	nomacro
	bne	$s0,$v0,.L324
	lui	$a3,%hi(ddata) # high
	.set	macro
	.set	reorder

	lw	$a3,16($sp)
	addu	$a3,$a3,1
	sw	$a3,16($sp)
	lui	$a0,%hi(.LC17) # high
	.set	noreorder
	.set	nomacro
	b	.L329
	addiu	$a0,$a0,%lo(.LC17) # low
	.set	macro
	.set	reorder

.L324:
	addiu	$a0,$a3,%lo(ddata) # low
	lui	$a3,%hi(data) # high
	addiu	$a1,$a3,%lo(data) # low
	.set	noreorder
	.set	nomacro
	jal	memcmp
	li	$a2,255			# 0x000000ff
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$v0,$zero,.L326
	lui	$a0,%hi(.LC18) # high
	.set	macro
	.set	reorder

	lw	$a3,20($sp)
	addu	$a3,$a3,1
	sw	$a3,20($sp)
	.set	noreorder
	.set	nomacro
	b	.L329
	addiu	$a0,$a0,%lo(.LC18) # low
	.set	macro
	.set	reorder

.L326:
	lui	$a0,%hi(.LC19) # high
	addiu	$a0,$a0,%lo(.LC19) # low
.L329:
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addu	$s4,$s4,1
	.set	macro
	.set	reorder

	slt	$v0,$s4,120
	.set	noreorder
	.set	nomacro
	bne	$v0,$zero,.L333
	li	$a3,1			# 0x00000001
	.set	macro
	.set	reorder

.L296:
	lui	$a0,%hi(.LC20) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC20) # low
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	print_num
	li	$a0,120			# 0x00000078
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC21) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC21) # low
	.set	macro
	.set	reorder

	lw	$a0,16($sp)
	jal	print_num
	lui	$a0,%hi(.LC22) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC22) # low
	.set	macro
	.set	reorder

	lw	$a0,20($sp)
	jal	print_num
	lui	$a0,%hi(.LC6) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC6) # low
	.set	macro
	.set	reorder

	lui	$a0,%hi(.LC23) # high
	.set	noreorder
	.set	nomacro
	jal	print_uart
	addiu	$a0,$a0,%lo(.LC23) # low
	.set	macro
	.set	reorder

	move	$v0,$zero
	lw	$ra,68($sp)
	lw	$fp,64($sp)
	lw	$s7,60($sp)
	lw	$s6,56($sp)
	lw	$s5,52($sp)
	lw	$s4,48($sp)
	lw	$s3,44($sp)
	lw	$s2,40($sp)
	lw	$s1,36($sp)
	lw	$s0,32($sp)
	.set	noreorder
	.set	nomacro
	j	$ra
	addu	$sp,$sp,72
	.set	macro
	.set	reorder

	.end	main2
	.size	main2,.-main2
