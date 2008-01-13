//////////////////////////////////////////////////////////////////////
////                                                              ////
//// define.h					                                  ////
////                                                              ////
//// This file is part of the r2000sc SingleCycle				  ////
////	opencores effort.										  ////
////	Simple Single-cycle Mips 32 bits processor				  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// definition for the project                                   ////
////                                                              ////
//// To Do:                                                       ////
//// tested ok		                                              ////
////                                                              ////
//// Author(s):                                                   ////
//// - Abdallah Meziti El-Ibrahimi   abdallah.meziti@gmail.com    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001 Abdallah Meziti and OPENCORES.ORG         ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

/* Length of memorys */
`define TAILLE_CODE	100*1024
`define TAILLE_DATA 100*1024

/* Level Logic */
`ifdef  ACTIVE_LOW
`define RESET_EDGE	negedge
`define RESET_ON	1'b0
`define CLOCK_EDGE	negedge

`else
`define RESET_EDGE	posedge
`define RESET_ON	1'b1
`define CLOCK_EDGE	posedge
`endif

//`define TRACE  1
`define DELAY_SLOT  1

`define dw		32		// Data Width
`define aw		32		// Address Width

`define ZERO	32'd0
`define ONE		32'd1

`define LOW		1'd0
`define HIGH	1'd1

//----- M I P S O p c o d e s -----
	// OPCODE
`define special	6'd0	// SPECIAL
`define regimm	6'd1	// REGIMM
`define j		6'd2
`define jal		6'd3
`define beq		6'd4
`define bne		6'd5
`define blez	6'd6
`define bgtz	6'd7
`define addi	6'd8
`define addiu	6'd9
`define slti	6'd10
`define sltiu	6'd11
`define andi	6'd12
`define ori		6'd13
`define xori	6'd14
`define lui		6'd15
`define lb		6'd32
`define lh		6'd33
`define lwl		6'd34
`define lw		6'd35
`define lbu		6'd36
`define lhu		6'd37
`define lwr		6'd38
`define sb		6'd40
`define sh		6'd41
`define swl		6'd42
`define sw		6'd43
`define swr		6'd46

	// SPECIAL
`define sll		6'd0
`define srl		6'd2
`define sra		6'd3
`define sllv	6'd4
`define srlv	6'd6
`define srav	6'd7
`define jr		6'd8
`define jalr	6'd9
`define syscall	6'd12
`define break	6'd13
`define mfhi	6'd16
`define mthi	6'd17
`define mflo	6'd18
`define mtlo	6'd19
`define mult	6'd24
`define multu	6'd25
`define div		6'd26
`define divu	6'd27
`define add		6'd32
`define addu	6'd33
`define sub		6'd34
`define subu	6'd35
`define and		6'd36
`define or		6'd37
`define xor		6'd38
`define nor		6'd39
`define slt		6'd42
`define sltu	6'd43

	// REGIMM
`define bgez	5'd1
`define bltz	5'd0
`define bgezal	5'd17
`define bltzal	5'd16

	// EXTRAT
`define halt	6'd63	// Fake

	// BRANCH
`define bra_non	3'd0	// Branch None
`define bra_imm	3'd1	// Branch Immediat
`define bra_reg	3'd2	// Branch Register
`define bra_rel	3'd3	// Branch Relativ
`define bra_stp	3'd4	// Branch Stop

	// ALU Operation
`define aluop_and	4'd0
`define aluop_or	4'd1
`define aluop_add	4'd2
`define aluop_sub	4'd6
`define aluop_slt	4'd7
`define aluop_sltu	4'd8
`define aluop_nor	4'd12
`define aluop_xor	4'd13
`define aluop_tra	4'd14
	

	// Conventional Names of Registers
`define zer0	5'd0	// Always returns 0
`define at		5'd1	// (assembly temporary) Reserved for use by assembly
`define v0		5'd2	// Value returned by subroutine
`define v1		5'd3
`define a0		5'd4	// (arguments) First few parameters for subroutine
`define a1		5'd5
`define a2		5'd6
`define a3		5'd7
`define t0		5'd8	// (temporaries) Subroutines can use without saving
`define t1		5'd9
`define t2		5'd10
`define t3		5'd11
`define t4		5'd12
`define t5		5'd13
`define t6		5'd14
`define t7		5'd15
`define t8		5'd24
`define t9		5'd25
`define s0		5'd16	// Subroutine register variables
`define s1		5'd17
`define s2		5'd18
`define s3		5'd19
`define s4		5'd20
`define s5		5'd21
`define s6		5'd22
`define s7		5'd23
`define k0		5'd26	// Reserved for use by interrupt/trap handler
`define k1		5'd27
`define gp		5'd28	// Global pointer
`define sp		5'd29	// Stack pointer
`define s8		5'd30	// Ninth register variable
`define fp		5'd30	// Frame pointer
`define ra		5'd31	// Return adress for subroutine

`define hi_ptr	3'd4	// adress of hi register
`define lo_ptr	3'd5	// adress of hi register

	// Memory
`define ENDIAN		1'd1	// 1 : Big Endian, 0 : little endian

`define BYTE		2'd1	// Width of one BYTE in octet
`define HALF		2'd2	// Width of one HALF in octet
`define WORD		2'd4	// Width of one WORD in octet

	
	// I/O
`define UART_WRITE        32'h20000000//32'h03ffc
`define UART_READ         32'h20000000
`define IRQ_MASK          32'h20000010
`define IRQ_STATUS        32'h20000020
`define IRQ_UART_WRITE_AVAILABLE 32'h20000002

/* ******************* */
/* BRANCH DECODER MUXC */
/* ******************* */
`define BRANCH_NO		2'd0
`define BRANCH_REG		2'd1
`define BRANCH_COND		2'd2
`define BRANCH_UNCOND	2'd3

`define CONTINU		2'b00
`define CONDITION	2'b01
`define REGISTER	2'b10
`define UNCONDITION	2'b11

	// conditions
`define BRA_ps		4'b0000
`define BNV_ps		4'b1000
`define BCC_ps		4'b0001
`define BCS_ps		4'b1001
`define BVC_ps		4'b0010
`define BVS_ps		4'b1010
`define BEQ_ps		4'b0011
`define BNE_ps		4'b1011
`define BGE_ps		4'b0100
`define BLT_ps		4'b1100
`define BGT_ps		4'b0101
`define BLE_ps		4'b1101
`define BPL_ps		4'b0110
`define BMI_ps		4'b1110

