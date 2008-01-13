##################################################################
# TITLE: Opcode Tester
# AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
# DATE CREATED: 1/10/02
# FILENAME: opcodes.asm
# PROJECT: Plasma CPU core
# COPYRIGHT: Software placed into the public domain by the author.
#    Software 'as is' without warranty.  Author liable for nothing.
# DESCRIPTION:
#    This assembly file tests all of the opcodes supported by the
#    Plasma core.
#    This test assumes that address 0x20000000 is the UART write register
#    Successful tests will print out "A" or "AB" or "ABC" or ....
#    Missing letters or letters out of order indicate a failure.
##################################################################
	.text
	.align	2
	.globl	entry
	.ent	entry
entry:
	.set noreorder

	#Set the CONMAX
#	ori   $1,$1,0x000a		# CFG0 ; MASTER1:2,MASTER0:2
#	lui   $20,0xf000		# Adresse of CFG0
#	sb    $1,0($20)			# Write
	

   #These four instructions must be the first instructions
   #convert.exe will correctly initialize $gp
	lui   $gp,0
	ori   $gp,$gp,0
   #convert.exe will set $4=.sbss_start $5=.bss_end
	lui   $4,0
	ori   $4,$4,0
	lui   $5,0
	ori   $5,$5,0
	lui   $sp,0
	ori   $sp,$sp,0xfff0


#CP0 test
#	ori   $at,$0,0x1		#enable interrupts
	ori   $at,$at,0x400		#mask interrupts
	mtc0  $at,$12			#status	
#CP0 test end

#	mtc0  $0,$12			#disable interrupts

	lui   $20,0x0100         #serial port write address
	ori   $21,$0,'\n'        #<CR> letter
	ori   $22,$0,'X'         #'X' letter
	ori   $23,$0,'\r'
	ori   $24,$0,0x0f80      #temp memory

   ######################################
   #Arithmetic Instructions
   ######################################
	ori   $2,$0,'A'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'r'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'i'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'t'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'h'
	sb    $2,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
	sb    $21,0($20)		#UART		#LF

   #a: ADD  expected=> a:A
	ori   $2,$0,'a'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $3,$0,5
	ori   $4,$0,60
	add   $2,$3,$4
	sb    $2,0($20)		#UART	    #A
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #b: ADDI  expected=> b:A
	ori   $2,$0,'b'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $4,$0,60
	addi  $2,$4,5
	sb    $2,0($20)		#UART	    #A
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #c: ADDIU  expected=> c:A
	ori   $2,$0,'c'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $4,$0,50
	addiu $5,$4,15
	sb    $5,0($20)		#UART		#A
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #d: ADDU  expected=> d:A
	ori   $2,$0,'d'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $3,$0,5
	ori   $4,$0,60
	addu  $2,$3,$4
	sb    $2,0($20)		#UART	    #A
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #e: DIV  expected=> e:ABCDE
	ori   $2,$0,'e'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
	
	ori   $2,$0,65*117+41
	ori   $3,$0,117
	div   $2,$3
	nop
	mflo  $4
	sb    $4,0($20)		#UART	    #A
	mfhi  $4
	addi  $4,$4,66-41
	sb    $4,0($20)		#UART	    #B
	li    $2,-67*19
	ori   $3,$0,19
	div   $2,$3
	nop
	mflo  $4
	sub   $4,$0,$4
	sb    $4,0($20)		#UART	    #C
	ori   $2,$0,68*23
	li    $3,-23
	div   $2,$3
	nop
	mflo  $4
	sub   $4,$0,$4
	sb    $4,0($20)		#UART	    #D
	li    $2,-69*13
	li    $3,-13
	div   $2,$3
	mflo  $4
	sb    $4,0($20)		#UART	    #E
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #f: DIVU  expected=> f:A
	ori   $2,$0,'f'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $2,$0,65*13
	ori   $3,$0,13
	divu  $2,$3
	nop
	mflo  $4
	sb    $4,0($20)		#UART	    #A
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #g: MULT  expected=> g:ABCDE
	ori   $2,$0,'g'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $2,$0,5
	ori   $3,$0,13
	mult  $2,$3
	mflo  $4
	sb    $4,0($20)		#UART	    #A
	li    $2,-5
	ori   $3,$0,13
	mult  $2,$3
	mfhi  $5
	mflo  $4
	sub   $4,$0,$4
	addu  $4,$4,$5
	addi  $4,$4,2
	sb    $4,0($20)		#UART	    #B
	ori   $2,$0,5
	li    $3,-13
	mult  $2,$3
	mfhi  $5
	mflo  $4
	sub   $4,$0,$4
	addu  $4,$4,$5
	addi  $4,$4,3
	sb    $4,0($20)		#UART	    #C
	li    $2,-5
	li    $3,-13
	mult  $2,$3
	mfhi  $5
	mflo  $4
	addu  $4,$4,$5
	addi  $4,$4,3
	sb    $4,0($20)		#UART	    #D
	lui   $4,0xfe98
	ori   $4,$4,0x62e5
	lui   $5,0x6
	ori   $5,0x8db8
	mult  $4,$5
	mfhi  $6
	addiu $7,$6,2356+1+'E'			#E
	sb    $7,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #h: MULTU  expected=> h:A
	ori   $2,$0,'h'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $2,$0,5
	ori   $3,$0,13
	multu $2,$3
	mflo  $4
	sb    $4,0($20)		#UART	    #A
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #i: SLT  expected=> i:ABCDEF
	ori   $2,$0,'i'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
#$SLT1:
	ori   $2,$0,10
	ori   $3,$0,12
	slt   $4,$2,$3
	addi  $5,$4,64
	sb    $5,0($20)		#UART	    #A
	slt   $4,$3,$2
	addi  $5,$4,66
	sb    $5,0($20)		#UART	    #B
	li    $2,0xfffffff0
	slt   $4,$2,$3
	addi  $5,$4,66
	sb    $5,0($20)		#UART	    #C
	slt   $4,$3,$2
	addi  $5,$4,68
	sb    $5,0($20)		#UART	    #D
	li    $3,0xffffffff
#	bal   $SLT1				# one delay slot
	slt   $4,$2,$3			# PC 370 : generate overflow
	addi  $5,$4,68
	sb    $5,0($20)		#UART	    #E
	slt   $4,$3,$2			# PC 37C : generate overflow
	addi  $5,$4,70
	sb    $5,0($20)		#UART	    #F
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #j: SLTI  expected=> j:AB
	ori   $2,$0,'j'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $2,$0,10
	slti  $4,$2,12
	addi  $5,$4,64
	sb    $5,0($20)		#UART	    #A
	slti  $4,$2,8
	addi  $5,$4,66
	sb    $5,0($20)		#UART	    #B
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #k: SLTIU  expected=> k:AB
	ori   $2,$0,'k'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $2,$0,10
	sltiu $4,$2,12
	addi  $5,$4,64
	sb    $5,0($20)		#UART	    #A
	sltiu $4,$2,8
	addi  $5,$4,66
	sb    $5,0($20)		#UART	    #B
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #l: SLTU  expected=> l:AB
	ori   $2,$0,'l'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $2,$0,10
	ori   $3,$0,12
	slt   $4,$2,$3
	addi  $5,$4,64
	sb    $5,0($20)		#UART	    #A
	sltu  $4,$3,$2
	addi  $5,$4,66
	sb    $5,0($20)		#UART	    #B
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #m: SUB  expected=> m:A
	ori   $2,$0,'m'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $3,$0,70
	ori   $4,$0,5
	sub   $2,$3,$4
	sb    $2,0($20)		#UART	    #A
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #n: SUBU  expected=> n:A
	ori   $2,$0,'n'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $3,$0,70
	ori   $4,$0,5
	subu  $2,$3,$4
	sb    $2,0($20)		#UART	    #A
	sb    $23,0($20)		#UART		#CR
	sb    $21,0($20)		#UART		#LF

   ######################################
   #Branch and Jump Instructions
   ######################################
	ori   $2,$0,'B'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'r'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'a'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'n'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'c'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'h'
	sb    $2,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
	sb    $21,0($20)		#UART		#LF

   #a: B  expected=> a:AB
	ori   $2,$0,'a'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $10,$0,'A'
	ori   $11,$0,'B'
	b     $B1
	sb    $10,0($20)	#UART		#A	
	sb    $22,0($20)	#UART	
$B1:
	sb    $11,0($20)	#UART		#B	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #b: BAL  expected=> b:ABCDE
	ori   $2,$0,'b'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $10,$0,'A'
	ori   $11,$0,'B'
	ori   $12,$0,'C'
	ori   $13,$0,'D'
	ori   $14,$0,'E'
	ori   $15,$0,'X'
	bal   $BAL1
	sb    $10,0($20)	#UART		#A	"On Delay Slot
	sb    $13,0($20)	#UART		#D
	b     $BAL2
	sb    $14,0($20)	#UART		#E	"On Delay Slot
	sb    $15,0($20)	#UART			
$BAL1:
	sb    $11,0($20)	#UART		#B
	jr    $31
	sb    $12,0($20)	#UART		#C	"On Delay Slot
	sb    $22,0($20)	#UART			
$BAL2:
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #c: BEQ  expected=> c:ABCD
	ori   $2,$0,'c'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $10,$0,'A'
	ori   $11,$0,'B'
	ori   $12,$0,'C'
	ori   $13,$0,'D'
	ori   $2,$0,100
	ori   $3,$0,123
	ori   $4,$0,123
	beq   $2,$3,$BEQ1
	sb    $10,0($20)	#UART		#A	"On Delay Slot	
	sb    $11,0($20)	#UART		#B	
	beq   $3,$4,$BEQ1
	sb    $12,0($20)	#UART		#C	"On Delay Slot
	sb    $22,0($20)	#UART	
$BEQ1:
	sb    $13,0($20)	#UART		#D
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #d: BGEZ  expected=> d:ABCD
	ori   $2,$0,'d'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $10,$0,'A'
	ori   $11,$0,'B'
	ori   $12,$0,'C'
	ori   $13,$0,'D'
	or    $15,$0,'X'
	ori   $2,$0,100
	li    $3,0xffff1234
	ori   $4,$0,123
	bgez  $3,$BGEZ1
	sb    $10,0($20)	#UART		#A	
	sb    $11,0($20)	#UART		#B
	bgez  $2,$BGEZ1
	sb    $12,0($20)	#UART		#C	"On Delay Slot	
	sb    $22,0($20)	#UART	
$BGEZ1:
	bgez  $0,$BGEZ2
	nop
	sb    $15,0($20)	#UART	
$BGEZ2:
	sb    $13,0($20)	#UART		#D
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #e: BGEZAL  expected=> e:ABCDE
	ori   $2,$0,'e'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $10,$0,'A'
	ori   $11,$0,'B'
	ori   $12,$0,'C'
	ori   $13,$0,'D'
	ori   $14,$0,'E'
	ori   $15,$0,'X'
	li    $3,0xffff1234
	bgezal $3,$BGEZAL1
	nop
	sb    $10,0($20)	#UART		#A
	bgezal $0,$BGEZAL1
	nop
	sb    $13,0($20)	#UART		#D	"On Delay Slot
	b     $BGEZAL2
	sb    $14,0($20)	#UART		#E	"On Delay Slot
	sb    $15,0($20)	#UART	
$BGEZAL1:
	sb    $11,0($20)	#UART		#B
	jr    $31
	sb    $12,0($20)	#UART		#C	"On Delay Slot
	sb    $22,0($20)	#UART	
$BGEZAL2:
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #f: BGTZ  expected=> f:ABCD
	ori   $2,$0,'f'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $10,$0,'A'
	ori   $11,$0,'B'
	ori   $12,$0,'C'
	ori   $13,$0,'D'
	ori   $2,$0,100
	li    $3,0xffff1234
	bgtz  $3,$BGTZ1
	sb    $10,0($20)	#UART		#A
	sb    $11,0($20)	#UART		#B
	bgtz  $2,$BGTZ1
	sb    $12,0($20)	#UART		#C	"On Delay Slot
	sb    $22,0($20)	#UART	
$BGTZ1:
	sb    $13,0($20)	#UART		#D	"On Delay Slot
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #g: BLEZ  expected=> g:ABCD
	ori   $2,$0,'g'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $10,$0,'A'
	ori   $11,$0,'B'
	ori   $12,$0,'C'
	ori   $13,$0,'D'
	ori   $2,$0,100
	li    $3,0xffff1234
	blez  $2,$BLEZ1
	sb    $10,0($20)	#UART		#A
	sb    $11,0($20)	#UART		#B
	blez  $3,$BLEZ1
	sb    $12,0($20)	#UART		#C	"On Delay Slot
	sb    $22,0($20)	#UART	
$BLEZ1:
	blez  $0,$BLEZ2
	nop
	sb    $22,0($20)	#UART	
$BLEZ2:
	sb    $13,0($20)	#UART		#D
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #h: BLTZ  expected=> h:ABCDE
	ori   $2,$0,'h'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $10,$0,'A'
	ori   $11,$0,'B'
	ori   $12,$0,'C'
	ori   $13,$0,'D'
	ori   $14,$0,'E'
	ori   $2,$0,100
	li    $3,0xffff1234
	ori   $4,$0,0
	bltz  $2,$BLTZ1
	sb    $10,0($20)	#UART		#A
	sb    $11,0($20)	#UART		#B
	bltz  $3,$BLTZ1
	sb    $12,0($20)	#UART		#C	"On Delay Slot
	sb    $22,0($20)	#UART	
$BLTZ1:
	bltz  $4,$BLTZ2
	nop
	sb    $13,0($20)	#UART		#D
$BLTZ2:
	sb    $14,0($20)	#UART		#E
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #i: BLTZAL  expected=> i:ABCDE
	ori   $2,$0,'i'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $10,$0,'A'
	ori   $11,$0,'B'
	ori   $12,$0,'C'
	ori   $13,$0,'D'
	ori   $14,$0,'E'
	ori   $15,$0,'X'
	li    $3,0xffff1234
	bltzal $0,$BLTZAL1
	nop
	sb    $10,0($20)	#UART		#A
	bltzal $3,$BLTZAL1
	nop
	sb    $13,0($20)	#UART		#D	"On Delay Slot
	b     $BLTZAL2
	sb    $14,0($20)	#UART		#E	"On Delay Slot
	sb    $15,0($20)	#UART	
$BLTZAL1:
	sb    $11,0($20)	#UART		#B
	jr    $31
	sb    $12,0($20)	#UART		#C	"On Delay Slot
	sb    $22,0($20)	#UART	
$BLTZAL2:
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #j: BNE  expected=> j:ABCD
	ori   $2,$0,'j'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $10,$0,'A'
	ori   $11,$0,'B'
	ori   $12,$0,'C'
	ori   $13,$0,'D'
	ori   $2,$0,100
	ori   $3,$0,123
	ori   $4,$0,123
	bne   $3,$4,$BNE1
	sb    $10,0($20)	#UART		#A
	sb    $11,0($20)	#UART		#B
	bne   $2,$3,$BNE1
	sb    $12,0($20)	#UART		#C	"On Delay Slot
	sb    $22,0($20)	#UART	
$BNE1:
	sb    $13,0($20)	#UART		#D
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #k: J  expected=> k:A
	ori   $2,$0,'k'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $10,$0,'A'
	ori   $11,$0,'B'
	ori   $15,$0,'X'
	j     $J1
	sb    $10,0($20)	#UART	
	sb    $15,0($20)	#UART	
$J1:
	sb    $11,0($20)	#UART	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #l: JAL	expected=> l:ABCDE
	ori   $2,$0,'l'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $10,$0,'A'
	ori   $11,$0,'B'
	ori   $12,$0,'C'
	ori   $13,$0,'D'
	ori   $14,$0,'E'
	ori   $15,$0,'X'
	jal   $JAL1
	sb    $10,0($20)	#UART	
	sb    $13,0($20)	#UART	
	b     $JAL2
	sb    $14,0($20)	#UART	
	sb    $15,0($20)	#UART	
$JAL1:
	sb    $11,0($20)	#UART	
	jr    $31
	sb    $12,0($20)	#UART	
	sb    $22,0($20)	#UART	
$JAL2:
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #m: JALR	expected=> m:ABCDE
	ori   $2,$0,'m'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $10,$0,'A'
	ori   $11,$0,'B'
	ori   $12,$0,'C'
	ori   $13,$0,'D'
	ori   $14,$0,'E'
	ori   $15,$0,'X'
	la    $3,$JALR1
	jalr  $3
	sb    $10,0($20)	#UART	
	sb    $13,0($20)	#UART	
	b     $JALR2
	sb    $14,0($20)	#UART	
	sb    $15,0($20)	#UART	
$JALR1:
	sb    $11,0($20)	#UART	
	jr    $31
	sb    $12,0($20)	#UART	
	sb    $22,0($20)	#UART	
$JALR2:
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #n: JR	expected=> n:AB
	ori   $2,$0,'n'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $10,$0,'A'
	ori   $11,$0,'B'
	ori   $15,$0,'X'
	la    $3,$JR1
	jr    $3
	sb    $10,0($20)	#UART	
	sb    $15,0($20)	#UART	
$JR1:
	sb    $11,0($20)	#UART	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #o: NOP	expected=> o:A
	ori   $2,$0,'o'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $2,$0,65
	nop
	sb    $2,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
	sb    $21,0($20)		#UART		#LF


   ######################################
   #Load, Store, and Memory Control Instructions
   ######################################
	ori   $2,$0,'L'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'o'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'a'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'d'
	sb    $2,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
	sb    $21,0($20)		#UART		#LF

   #a: LB	expected=> a:ABCDE
	ori   $2,$0,'a'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	or    $2,$0,$24
	li    $3,0x414243fc
	sw    $3,16($2)
	lb    $4,16($2)
	sb    $4,0($20)		#UART			#A
	lb    $4,17($2)
	sb    $4,0($20)		#UART			#B
	lb    $4,18($2)
	sb    $4,0($20)		#UART			#C
	lb    $2,19($2)
	sra   $3,$2,8
	addi  $3,$3,0x45
	sb    $3,0($20)		#UART			#D
	addi  $2,$2,0x49
	sb    $2,0($20)		#UART			#E
	sb    $23,0($20)		#UART		#CR
	sb    $21,0($20)		#UART		#LF

   #b: LBU  expected=> b:ABCD
	ori   $2,$0,'b'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	or    $2,$0,$24
	li    $3,0x41424344
	sw    $3,16($2)
	lbu   $4,16($2)
	sb    $4,0($20)		#UART			#A
	lbu   $4,17($2)
	sb    $4,0($20)		#UART			#B
	lbu   $4,18($2)
	sb    $4,0($20)		#UART			#C
	lbu   $2,19($2)
	sb    $2,0($20)		#UART			#D
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #c: LH  expected=> c:AB
	ori   $2,$0,'c'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	or    $2,$0,$24
	li    $3,0x00410042
	sw    $3,16($2)
	lh    $4,16($2)
	sb    $4,0($20)		#UART			#A
	lh    $2,18($2)
	sb    $2,0($20)		#UART			#B
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #d: LHU  expected=> d:AB
	ori   $2,$0,'d'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	or    $2,$0,$24
	li    $3,0x00410042
	sw    $3,16($2)
	lhu   $4,16($2)
	sb    $4,0($20)		#UART			#A
	lhu   $2,18($2)
	sb    $2,0($20)		#UART			#B
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #e: LW  expected=> e:A
	ori   $2,$0,'e'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	or    $2,$0,$24
	li    $3,'A'
	sw    $3,16($2)
	ori   $3,$0,0
	lw    $2,16($2)
	sb    $2,0($20)		#UART			#A
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

#   #f: LWL & LWR  expected=> f:
#	ori   $2,$0,'f'
#	sb    $2,0($20)		#UART	
#	ori   $2,$0,':'
#	sb    $2,0($20)		#UART
#		
#	or    $2,$0,$24
#	li    $3,'A'
#	sw    $3,16($2)
#	ori   $3,$0,0
#	lwl   $2,16($2)
#	lwr   $2,16($2)
#	sb    $2,0($20)		#UART	
#	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #g: SB  expected=> g:A
	ori   $2,$0,'g'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $2,$0,'A'
	sb    $2,0($20)		#UART			#A	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #h: SH  expected=> h:AB
	ori   $2,$0,'h'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	or    $4,$0,$24
	ori   $2,$0,0x4142
	sh    $2,16($4)
	lb    $3,16($4)
	sb    $3,0($20)		#UART			#A
	lb    $2,17($4)
	sb    $2,0($20)		#UART			#B
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #i: SW  expected=> i:ABCD
	ori   $2,$0,'i'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	or    $2,$0,$24
	li    $3,0x41424344
	sw    $3,16($2)
	lb    $4,16($2)
	sb    $4,0($20)		#UART			#A
	lb    $4,17($2)
	sb    $4,0($20)		#UART			#B
	lb    $4,18($2)
	sb    $4,0($20)		#UART			#C
	lb    $2,19($2)
	sb    $2,0($20)		#UART			#D
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #j: SWL & SWR
#	ori   $2,$0,'j'
#	sb    $2,0($20)		#UART	
#	ori   $2,$0,':'
#	sb    $2,0($20)		#UART
#		
#	or    $2,$0,$24
#	li    $3,0x41424344
#	swl   $3,16($2)
#	swr   $3,16($2)
#	lb    $4,16($2)
#	sb    $4,0($20)		#UART	
#	lb    $4,17($2)
#	sb    $4,0($20)		#UART	
#	lb    $4,18($2)
#	sb    $4,0($20)		#UART	
#	lb    $2,19($2)
#	sb    $2,0($20)		#UART	
#	sb    $23,0($20)		#UART		#CR
	sb    $21,0($20)		#UART		#LF


   ######################################
   #Logical Instructions
   ######################################
	ori   $2,$0,'L'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'o'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'g'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'i'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'c'
	sb    $2,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
	sb    $21,0($20)		#UART		#LF

   #a: AND
	ori   $2,$0,'a'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $2,$0,0x0741
	ori   $3,$0,0x60f3
	and   $4,$2,$3
	sb    $4,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #b: ANDI
	ori   $2,$0,'b'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $2,$0,0x0741
	andi  $4,$2,0x60f3
	sb    $4,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #c: LUI
	ori   $2,$0,'c'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	lui   $2,0x41
	srl   $3,$2,16
	sb    $3,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #d: NOR
	ori   $2,$0,'d'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	li    $2,0xf0fff08e
	li    $3,0x0f0f0f30
	nor   $4,$2,$3
	sb    $4,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #e: OR
	ori   $2,$0,'e'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $2,$0,0x40
	ori   $3,$0,0x01
	or    $4,$2,$3
	sb    $4,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #f: ORI
	ori   $2,$0,'f'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $2,$0,0x40
	ori   $4,$2,0x01
	sb    $4,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #g: XOR
	ori   $2,$0,'g'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $2,$0,0xf043
	ori   $3,$0,0xf002
	xor   $4,$2,$3
	sb    $4,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #h: XORI
	ori   $2,$0,'h'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $2,$0,0xf043
	xor   $4,$2,0xf002
	sb    $4,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
	sb    $21,0($20)		#UART		#LF
 
   ######################################
   #Move Instructions
   ######################################
	ori   $2,$0,'M'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'o'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'v'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'e'
	sb    $2,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
	sb    $21,0($20)		#UART		#LF

   #a: MFHI
	ori   $2,$0,'a'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $2,$0,65
	mthi  $2
	mfhi  $3
	sb    $3,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
	sb    $21,0($20)		#UART		#LF

   #b: MFLO
	ori   $2,$0,'b'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $2,$0,65
	mtlo  $2
	mflo  $3
	sb    $3,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #c: MTHI
	ori   $2,$0,'c'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $2,$0,65
	mthi  $2
	mfhi  $3
	sb    $3,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #d: MTLO
	ori   $2,$0,'d'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	ori   $2,$0,65
	mtlo  $2
	mflo  $3
	sb    $3,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
	sb    $21,0($20)		#UART		#LF


   ######################################
   #Shift Instructions
   ######################################
	ori   $2,$0,'S'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'h'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'i'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'f'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'t'
	sb    $2,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
	sb    $21,0($20)		#UART		#LF
	
	#a: SLL
	ori   $2,$0,'a'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	li    $2,0x40414243
	sll   $3,$2,8
	srl   $3,$3,24
	sb    $3,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #b: SLLV
	ori   $2,$0,'b'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	li    $2,0x40414243
	ori   $3,$0,8
	sllv  $3,$2,$3
	srl   $3,$3,24
	sb    $3,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #c: SRA
	ori   $2,$0,'c'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	li    $2,0x40414243
	sra   $3,$2,16
	sb    $3,0($20)		#UART	
	li    $2,0x84000000
	sra   $3,$2,25
	sub   $3,$3,0x80
	sb    $3,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #d: SRAV
	ori   $2,$0,'d'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	li    $2,0x40414243
	ori   $3,$0,16
	srav  $3,$2,$3
	sb    $3,0($20)		#UART	
	ori   $3,$0,25
	li    $2,0x84000000
	srav  $3,$2,$3
	sub   $3,$3,0x80
	sb    $3,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #e: SRL
	ori   $2,$0,'e'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
		
	li    $2,0x40414243
	srl   $3,$2,16
	sb    $3,0($20)		#UART	
	li    $2,0x84000000
	srl   $3,$2,25
	sb    $3,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
#	sb    $21,0($20)		#UART		#LF

   #f: SRLV
	ori   $2,$0,'f'
	sb    $2,0($20)		#UART	
	ori   $2,$0,':'
	sb    $2,0($20)		#UART
   	
	li    $2,0x40414243
	ori   $3,$0,16
	srlv  $4,$2,$3
	sb    $4,0($20)		#UART	
	ori   $3,$0,25
	li    $2,0x84000000
	srlv  $3,$2,$3
	sb    $3,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
	sb    $21,0($20)		#UART		#LF


	ori   $2,$0,'D'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'o'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'n'
	sb    $2,0($20)		#UART	
	ori   $2,$0,'e'
	sb    $2,0($20)		#UART	
	sb    $23,0($20)		#UART		#CR
	sb    $21,0($20)		#UART		#LF

$DONE:
	j     $DONE
	nop
	
	.set	reorder
	.end	entry
	
	.section ".reset_vector","ax"
# Exception Handler
	.globl	interrupt_service_routine
	.ent	interrupt_service_routine
   
#	.ktext 0x80000080
#	.text# 0x00001080
interrupt_service_routine:
   .set noreorder
   
	mfc0	$k0, $13 #cause		# save Cause into k0
	mfc0	$k1, $14 #epc		# save EPC into k1

	# Save registers	

	# Exception Code
#	addiu	$v0, $0, 4		# syscall 4 (print_str)
#	la		$a0, __m1_
#	syscall
#	addiu	$v0, $0, 1		# syscall 1 (print_int)
#	addu	$a0, $0, $k0
#	syscall
#	la		$a0, __m2_
#	syscall

	# Restor registers	
	
	# Calcul Return  address
#	addiu	$k1, $k1, 4		# Overflow		: EPC + 4
	addiu	$k1, $k1, 0		# Interruption	: EPC + 0
#	addiu	$k1, $k1, -4	# Branch Delay	: EPC - 4
	
	mtc0	$0, $13 #cause		# Clear Cause register
	jr		$k1				# Jump to Return address
	rfe						# Return from exception handler

   .set reorder
   .end interrupt_service_routine
   
	.data
	.globl	__m1_
__m1_:	.asciiz "  Exception "
	.globl	__m2_
__m2_:	.asciiz " occurred\n"

