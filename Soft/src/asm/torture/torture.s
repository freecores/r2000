# MIPS program to stress-test simulators - version 4; tests 0-7 working.
# if all is well, $s0 = 0; $s1 = 1; $s2 = 2; $s3 = 3; $s4 = 4; $s5 = 5;
# $s6 = 6; $s7 = 7
#
# This version of torture.s is complete.
#
# This program tests all "required" instructions in the SPIM simulator
# project.  It does not test the syscall instruction.
#

	.data						# Begin data segment
var1:	.word 0					# first memory variable
var2:	.word 0					# second memory variable
var3:	.word 0,0				# make sure var3 holds two words
								#   consecutively
	.text						# Begin code segment
	.globl main2					# first instr must be global

###################### BEGIN  main #########################################

main2:	subu $sp,$sp,16			# set up main's stack frame:
								#   need room for two args, two 
								#   two callee save registers
	sw $ra,12($sp)				# save main's return address
	sw $fp,8($sp)				# save main's caller's frame pointer
	addu $fp,$sp,12				# establish main's frame pointer

# test 0: zero register; result should be 0 in the zero register; 
# $s0 = 0 if all is well at end of test

	addi $0,$0,1				# in this case, 0+1=0 if all is well!
	addi $s0,$0,0				# MOVE $0 TO $s0 ; should be 0
#	li $v0,4					# print string
#	la $a0,str0
#	syscall
#	li $v0,1					# print integer
#	move $a0,$0
#	syscall
#	jal NewLine					# print newline

# test 1: logical operations; 
# $s1 = 1 if all is well at end of test

	lui $t0,0x5555				# $t0 = 0x55555555
	ori $t0,$t0,0x5555
	lui $t1,0x0000				# $t1 = 0x00000000
	ori $t1,0x0000			
	nor $t0,$t1,$t0				# $t0 NOR $t1 = 0xAAAAAAAA
	lui $t2,0xCCCC				# $t2 = 0xCCCCCCCC
	ori $t2,$t2,0xCCCC
	or  $t0,$t2,$t0				# $t0 OR $t2  = 0xEEEEEEEE
	lui $t3,0x3333				# $t3 = 0x33333333
	ori $t3,$t3,0x3333
	and $t0,$t3,$t0				# $t0 AND $t3 = 0x22222222
	sll $t0,$t0,1				# $t0 = 0x44444444
	sra $t0,$t0,1				# $t0 = 0x22222222
	srl $t0,$t0,1				# $t0 = 0x11111111
	addi $t4,$0,3				# $t4 = 3
	sllv $t0,$t0,$t4			# $t0 = 0x88888888
	sra $t0,$t0,1				# $t0 = 0xC4444444
	lui $t5,0x8888				# $t5 = 0x88888888
	ori $t5,$t5,0x8888
	and $t0,$t5,$t0				# $t0 AND $t5 = 0x80000000
	lui $t6,0xFFFF				# $t6 = 0xFFFFFFFF
	ori $t6,$t6,0xFFFF
	xor $t0,$t6,$t0				# $t0 XOR $t6 = 0x7FFFFFFF

	addi $s1,$t0,0				# MOVE $t0 to $s1
	lui $t7,0x7FFF				# load expected answer into $t7
	ori $t7,0xFFFF
	bne $s1,$t0,wrong1			# check answer
	addi $s1,$0,1				#   if correct, set $s1 = 1
wrong1: add $0,$0,$0			# NOP: if incorrect, $s1 != 1

# test 2: load/store - simple lw/sw commands
# $s2 = 2 if all is well at end of test

# first store two numbers in memory
	lui $t0,0x7654				# $t0 = 0x76543210
	ori $t0,0x3210
	la $t1,var1					# $t1 = &var1 (pointer to var1)
	sw $t0,0($t1)				# var1 = $t0
	lui $t2,0x1234				# $t2 = 0x12345678
	xori $t2,0x5678
	la $t3,var2					# $t3 = &var2
	sw $t2,0($t3)				# var2 = $t3
# now retrieve the two numbers and add them
	lw $t4,0($t1)				# $t4 = var1
	lw $t5,0($t3)				# $t5 = var2
	addu $t6,$t4,$t5			# $t6 = $t4 + $t5
# nb add would cause overflow above!
	addu $s2,$t6,0				# set up flag value in $s2
	lui $t7,0x8888				# $t7 = 0x88888888 (correct answer)
	ori $t7,0x8888
	bne $s2,$t7,wrong2			# check answer
	addi $s2,$0,2				#   if correct, set $s2 = 2
#	addi $s2,$s2,131072			# 2^17, this is a pseudoinstruction
	andi $s2,$s2,0xffff			#   should set $s2 back to 2
wrong2: add $0,$0,$0			# NOP: if incorrect, $s2 != 2
		
# test 3: arithmetic
# $s3 = 3 if all is well at end of test

	add $t0,$0,$0				# clear $t0
	addi $t0,$t0,0xff			# $t0 = 255
	addi $t0,$t0,-240			# $t0 = 15
	addiu $t1,$0,15				# $t1 = 15 

# not required
	mult $t1,$t0				# $t2 = $t1*$t0 = 225
	mflo $t2			
	mfhi $t6					# $t6 should be 0
# replace
	sll $t2,$t1,4
	sub $t2,$t2,$t1
	sub $t6,$t0,$t0
	
	addi $t2,$t2,2				# $t2 = 225 + 2 = 227
	ori $t3,$0,0xa				# $t3 = 10
	sub $t4,$t1,$t3				# $t4 = $t1-$t3 = 5

# not required
	div $t2,$t4					# $t4 = $t2 / $t4 = 45 rem 2
	mflo $t4
	mfhi $t7					# $t7 is remainder; should be 2
#replace
	addi $t7,$t2,0x1d
	srl $t7,$t7,7
	addi $t4,$t4,0x28
			
	addu $t6,$t6,$t7			# $t6 = $t6 + $t7 = 2
	add $s3,$t7,$t4				# $s3 = 3 if all is well
	addi $s3,$s3,-44
		
# test 4: jumping
# $s4 = 4 if all is well at end of test

j_top:	add $s4,$0,$0			# clear $s4
	j j_skip1
j_bad1:	addi $s4,$s4,17			# should not happen!
j_skip1:addi $s4,$s4,1			# $s4 = 1 now if all is well
	la $t0,j_skip2				# $t0 is pointer to j_skip2
	jr $t0						# jump to j_skip2
j_bad2:	addi $s4,$s4,23			# should not happen!
j_skip2:addi $s4,$s4,1			# $s4 = 2 now if all is well
	jal inc_s4 					# $s4 = 3 now if all is well on return
#   jalr is not required  enable if you want to test jalr.
	la $t1,inc_s4				# $t1 is pointer to inc_s4
	jalr $t1					# $s4 = 4 now if all is well on return
#  instead
	jal inc_s4

# test 5: branching
# $s5 = 5 if all is well at end of test

b_top:	add $s5,$0,$0			# clear $s5
	beq $s5,$0,b_skip1			# if $s5 = 0 goto b_skip1
b_bad1:	addi $s5,$s5,7			# should not happen!
b_skip1:addi $s5,$s5,1			# $s5 = 1 now if all is well
	addi $t0,$0,-1				# $t0 = -1
	bgez $t0,b_skip2			# if $t0 >= 0 goto b_skip2 (it isn't!)
b_good1:addi $s5,$s5,-10		# should do this!
b_skip2:addi $s5,$s5,11			# $s5 = 2 now if all is well
	bltz $t0,b_skip3			# if $t0 < 0 goto b_skip 3 (it is!)
b_bad2:	addi $s5,$s5,13			# should not happen!
b_skip3:addi $s5,$s5,1			# $s5 = 3 now if all is well
#  disable this instruction 
#	bltzal $t0,inc_s5			# call inc_s5 if $t0 < 0 (it is!)
#       replace with
	bltz $t0,n_skip1			# call inc_s5 if $t0 < 0 (it is!)
	addi $s5,$s5,13				# should not happen!
n_skip1:jal inc_s5              # call inc_s5 if $t0 < 0 (it is!)
#
#  disable this instruction
#	bgezal $t0,inc_s5			# call inc_s5 if $t0 >0 0 (it isn't!)
								# $s5 = 4 now if all is well
	add  $t1,$0,$0				# clear $t5
	blez $t1,b_skip4			# if $t1 <= 0 goto b_skip4 (it is!)
	addi $s5,$s5,17				# should not happen!
b_skip4:bgtz $t1,b_skip5		# if $t1 > 0 goto b_skip5 (it isn't!)
	addi $s5,$s5,-18			# should do this!
b_skip5:addi $s5,$s5,19			# $s5 = 5 now if all is well

# test 6: set instructions
# $s6 = 6 if all is well at end of test

	add $s6,$0,$0				# clear $s6
	addi $t0,$0,-10				# $t0 = -10 ( = 0xFFFFFFF6)
	addi $t1,$0,20				# $t1 = 20
	slt $t2,$t0,$t1				# $t2 = 1 if $t0 < $t1 (it is!)
	add $s6,$s6,$t2				# $s6 = 1 now if all is well
	sltu $t3,$t0,$t1			# $t3 = 1 if $t0 < $t1 unsigned (not!)
	add $s6,$s6,$t3				# $s6 = 1 still if all is well
	slti $t4,$t0,-5				# $t4 = 1 if $t0 < -5 (it is!)
	add $s6,$s6,$t4				# $s6 = 2 now if all is well

# not required
	multu $s6,$s6				# should be 2 x 2 = 4
	mflo $s6					# $s6 = 4 now if all is well
# replace
	add $s6, $s6, $s6
	
	sltiu $t5,$t0,-5			# $t5 = 1 if $t0 < -5 unsigned (yes!)
								# sltiu sign-extends but then compares
								# as unsigned; 0xFF..F6 is < 0xFF..FB
	add $s6,$s6,$t5				# $s6 = 5 still if all is well
# test a few stray instructions while we're here
# not required
	mthi $s6					# put $s6 in hi for fun
	mtlo $t0					# put -10 in LO
	mflo $s6					# put -10 in $s6
	mfhi $t6					# put 5 in $t6
	# simulate the prev instructions
	addi $t6, $s6, 0
	addi $s6, $t0, 0
	
	subu $s6,$s6,$t6			# $s6 = -10 - 5 = -15 (even unsigned)

# not required
	divu $s6,$t6				# 0xff..f1 / 5 = 0x33333330 rem 1
	mflo $s6					# $s6 = 0x33333330
	mfhi $t7					# $t7 = 1
# replace
#	andi $s6,$s6,0x33333332
	andi $t7,$t6,1
		
	srav $s6,$s6,$t1			# right shift $s6 20 places;
								# $s6 = 0x00000333
	addi $t1,$t1,-12			# $t1 = 20 - 12 = 8
	srlv $s6,$s6,$t1			# right shift $s6 8 places;
								# $s6 = 0x00000003
	add $s6,$s6,$t7				# $s6 = 4 if all is well
	add $s6,$s6,2				# $s6 = 6 if all is well

# test 7: nonaligned load/store instructions
# $s7 = 7 if all is well at end of test
# this test is not required
	lui $t0,0x1234				# $t0 = 0x12345678
	ori $t0,0x5678
	lui $t1,0x9abc				# $t1 = 0x9abcdef0
	ori $t1,0xdef0

	la $t2,var3					# $t2 = &var3 (pointer to var3)
								# var3 was declared as an array
								#   two words long
	sw $t0,0($t2)				# var3[0] = $t0
	sw $t1,4($t2)				# var3[1] = $t1
                            	
	lb $t3,0($t2)				# $t3 = 0x00000012
	lb $t4,1($t2)				# $t4 = 0x00000034
	lb $t5,4($t2)				# $t5 = 0xffffff9a (nb sign extends)
	lbu $t6,5($t2)				# $t6 = 0x000000bc (doesn't sign extend)
	lwl $t7,1($t2)				# $t7 = 0x345678XX
	lwr $t7,4($t2)				# $t7 = 0x3456789a
	lhu $t8,2($t2)				# $t8 = 0x00005678
	lh $t9,4($t2)				# $t9 = 0xffff9abc (nb sign extends)
                            	
	subu $s7,$t5,$t9			# $s7 = 0x000064de
	subu $s7,$s7,$t3			# $s7 = 0x000064cc
	subu $s7,$s7,$t4			# $s7 = 0x00006498
	subu $s7,$s7,$t8			# $s7 = 0x00000e20
	addu $s7,$s7,$t8			# $s7 = 0x00006498
	addu $s7,$s7,$t6			# $s7 = 0x00006554
	add $s7,$s7,-0x6554			# $s7 = 0
	addu $s7,$s7,$t7			# $s7 = 0x3456789a
                            	
	sb $s7,1($t2)				# var3[1] = 0x129a5678
	sh $s7,2($t2)				# var3[1] = 0x129a789a
	swl $s7,3($t2)				# var3[1] = 0x129a7834
	swr $s7,0($t2)				# var3[1] = 0x9a9a7834
	lw $s7,0($t2)				# $s7 = 0x9a9a7834 if all is well
	lui $t0,0x9a9a				# $t0 = 0x9a9a782d
	ori $t0,0x782d          	
	sub $s7,$s7,$t0				# $s7 = 7 if all is well
#instead
	addi $s7,$0,0x7
	
# prepare to exit program

    lw $ra,12($sp)          	# restore return address
    lw $fp,8($sp)           	# restore frame pointer address
    addu $sp,$sp,16				# pop main's stack frame
	li $v0, 10					# setup for exit syscall
	syscall						# exec syscall
end:j end
##################### END MAIN ###########################################

# inc_s4: Leaf procedure, called from jump test to verify call/return
# behavior.  Increments $s4 once.

inc_s4: addi $s4,$s4,1
	jr $ra

# inc_s5: Leaf procedure, called from branch test to verify bltzal etc.
# Increments $s5 once.

inc_s5: addi $s5,$s5,1
	jr $ra

