//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_decoder.v			                                  ////
////                                                              ////
//// This file is part of the r2000pl Pipelined				  	  ////
////	opencores effort.										  ////
////	Simple Pipelined Mips 32 bits processor				  	  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// The main decoder that control all units of the cpu.          ////
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

`include "timescale.v"
`include "define.h"

/* ====================
	module definition
   ==================== */
module	r2000_decoder
	(	/* Input */
		Instruction_i		,	// the instruction
                                                                                
		/* Output */
		/* INSTRUCTION DECODE STAGE */                                                            
		RegDrt_o			,                                   
                                                                               
		BranchSel_o			,	// branch/jump control            
		ConditionSel_o		,                                   
				                                                                
		/* EXECUTION STAGE */                                                            
		AluOp_o				,	// alu controls                   
		AluSrcB_o			,                                   
		AluStatus_o			,
		                                                   
		ShiftVar_o			,	// shifter control                
        ShiftLr_o			,                                   
		ShiftLa_o			,                                   
                                                                                
        MultDivSign_o		,	// multiplication/division control
		MultDivOp_o			, 
		MultDivStart_o		,
		MultDivHiW_o		,
		MultDivLoW_o		,
		                                                                       
		ExOp_o				,	// choice the operation result
		
		/* MEMORY STAGE */                                                            
		MemRead_o			,	// memory interface bus control                                   
		MemWrite_o			,                                   
		MemOe_o				,
		MemLength_o			,                                   
		MemSign_o			,                                   
		
		/* WRITE BACK STAGE */                                                            
		RegWrite_o			,	// register file controls
		RegDst_o		    ,
		RegSrc_o			,
		
		/* CO-PROCESSOR 0 */
		CoSys_o				,	// syscall instruction
		CoBreak_o			,	// break instruction
		CoRfe_o				,	// rfe instruction
		CoMf_o				,	// CP0 Move From
		CoMt_o					// CP0 Move To
		
	);
/* --------------------------------------------------------------
	in, out declaration
   ------------------- */
	input  [`dw-1:0]	Instruction_i	;
	
	output[2:0]			AluOp_o         ;
	output[1:0]			AluSrcB_o       ;
	output				AluStatus_o		;
	
	output				RegWrite_o      ;
	output [1:0]		RegDst_o        ;
	output				RegDrt_o		;
	output				RegSrc_o		;
	
	output [2:0]		ExOp_o      	;

	output				MemRead_o       ;
	output				MemWrite_o      ;
	output				MemOe_o			;
	output [1:0]		MemLength_o		;
	output				MemSign_o		;

	output[1:0]			BranchSel_o		;
	output[3:0]			ConditionSel_o	;

	output				ShiftVar_o		;
	output		        ShiftLr_o		;
	output				ShiftLa_o		;

	output		        MultDivSign_o	;
	output				MultDivOp_o		;
	output				MultDivStart_o	;
	output				MultDivHiW_o	;
	output				MultDivLoW_o	;
	
	output				CoSys_o			;
	output				CoBreak_o		;
	output				CoRfe_o			;
	output				CoMf_o			;
	output				CoMt_o			;
	
/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
	wire [5:0]		op				;	// -- Opcode
	wire [4:0]		rs				;	// -- rs register field
	wire [4:0]		ct				;	// -- Condition//rt register field
	wire [4:0]		rd				;	// -- rd register field
	wire [4:0]		shamt			;	// -- Shift amount
	wire [5:0]		funct			;	// -- function field (R-format)
	            	        		
	wire			co				;	// -- coprocessor 0
	wire [18:0]		blank			;	// -- coprocessor 0

	reg[2:0]		AluOp_o         ;
	reg[1:0]		AluSrcB_o       ;

	
	reg				RegWrite_o      ;
	reg [1:0]		RegDst_o        ;
	reg				RegDrt_o		;
	reg				RegSrc_o		;
	
	reg [2:0]		ExOp_o      	;

	reg				MemRead_o       ;
	reg				MemWrite_o      ;
	reg				MemOe_o			;
	reg [1:0]		MemLength_o		;
	reg				MemSign_o		;

	reg	[1:0]		BranchSel_o		;
	reg	[3:0]		ConditionSel_o	;

	reg				ShiftVar_o		;
	reg		        ShiftLr_o		;
	reg				ShiftLa_o		;

	reg		        MultDivSign_o	;
	reg				MultDivOp_o		;
	reg				MultDivStart_o	;
	reg				MultDivHiW_o	;
	reg				MultDivLoW_o	;
   
/* --------------------------------------------------------------
	instances, statements
   ------------------- */

	assign {op, rs, ct, rd, shamt, funct} = Instruction_i;
	
	assign {op, co, blank, funct} = Instruction_i;
   
	// Alu operation
	always@(op)
	begin
		case (op)
		    
		    `addi,`addiu:	AluOp_o=3'd0; 	// add
		    `andi		:	AluOp_o=3'd2; 	// and
		    `ori		:	AluOp_o=3'd3; 	// or
		    `slti		:	AluOp_o=3'd4; 	// slt
		    `sltiu		:	AluOp_o=3'd5; 	// sltu
		    `xori		:	AluOp_o=3'd6;	// xor
		                 	
			`lb,`lbu,`lh,`lhu,
			`lw,`lwl,`lwr,
			`sb,`sh,`sw,`swl,`swr
						:	AluOp_o=3'd0; 	// add
			             	
			`beq,`bgtz,`blez,`bne,
			`regimm		:	AluOp_o=3'd1; 	// sub
		    `special	:	AluOp_o=3'd7;	// funct
			default		:	AluOp_o=3'd0; 	// add
		endcase
	end
	
	// Alu Status Valid
	assign AluStatus_o	=	(((op ==`special) && (funct ==`add)) ||
							((op ==`special) && (funct ==`sub)) ||
							(op ==`addi));

	// register file write
	always@(op, ct, funct)
	begin
			if ((op == `div) || (op ==`divu)||(op == `mult)||(op == `multu)||(op == `mthi)||(op == `mtlo)||
				(op == `sb) || (op ==`sh)||(op == `sw)||(op == `swl)||(op == `swr)||
				(op ==`sb)||(op == `sh)||(op == `swr)||(op == `j)||
				((op == `special) && (funct == `jr))||
				(op == `beq) || (op == `bgtz)||(op == `blez)||(op == `bne)||
				((op == `regimm) && ((ct == `bgez)||(ct == `bltz))) ||
				((op ==`cop0) && ((rs ==`mt)||(funct ==`rfe)))
				)
				RegWrite_o <= `LOW; else RegWrite_o <= `HIGH;
	end

	// Memory Read/Write
	always@(op)
	begin
						MemRead_o  = `LOW;//`HIGH;
						MemWrite_o = `LOW;//`HIGH;
		case (op)
			`lb,`lbu,`lh,`lhu,
			`lw,`lwl,`lwr
					:	MemRead_o  = `HIGH;//`LOW;

			`sb,`sh,`sw,`swl,`swr
					:	MemWrite_o = `HIGH;//`LOW;
		default		:begin
						MemRead_o  = `LOW;//`HIGH;
						MemWrite_o = `LOW;//`HIGH;
					end
		endcase
	end
	
	// To register file
	always@(op, funct, ct)
	begin
		case (op)

			`lb,`lbu,`lh,`lhu,
			`lw,`lwl,`lwr
						:	RegSrc_o <= 1;	// Memory
			default		:	RegSrc_o <= 0;	// Register
		endcase
	end

	/* Result operation */
	always@(op, funct, ct)
	begin
		case (op)
			`jal		:	ExOp_o <= 3;
			`lui		:	ExOp_o <= 6;
			`special	:
				case(funct)
					`sll,`sllv,`sra,
					`srav,`srl,`srlv
								:	ExOp_o <= 2;
					`jalr		:	ExOp_o <= 3;
					`mfhi		:	ExOp_o <= 4;
					`mflo		:	ExOp_o <= 5;
					default		:	ExOp_o <= 0;		
				endcase
			`regimm		:	if ((ct==`bgezal)||(ct==`bltzal))
								ExOp_o <= 3; else ExOp_o <= 0;

			default		:	ExOp_o <= 0;
		endcase
	end
	
	// memory interface
	always@(op)
	begin
		// Taille of the data transfert
		case (op)
			`lb,`lbu,`sb:	MemLength_o <= `BYTE;
			`lh,`lhu,`sh:	MemLength_o <= `HALF;
			`lw,`sw:		MemLength_o <= `WORD;
			default:		MemLength_o <= `WORD;
		endcase
		// sign extension of the data transfert
		case (op)
			`lhu,`lbu:		MemSign_o <= `LOW;
			default:		MemSign_o <= `HIGH;
		endcase
		// meory write
		case (op)
			`sb,`sh,`sw:	MemOe_o <= `HIGH;//`LOW;
			default:		MemOe_o <= `LOW;//`HIGH;
		endcase
	end
	
	// Immediate operand
	always@(op, funct)
	begin
		if ((op == `addi) || (op ==`addiu) || (op == `slti) || (op == `sltiu) ||
			(op == `lb) || (op == `lbu) || (op == `lh) || (op == `lhu) || (op == `lw) || (op == `lwl) ||
			(op == `lwr) || (op == `sb) || (op == `sh) || (op == `sw) || (op == `swl) || (op == `swr)	)
			AluSrcB_o = 1;
		else if ((op == `andi) || (op == `ori) || (op == `xori))
			AluSrcB_o = 2;
		else AluSrcB_o = 0;
	end

	// Rt register
	always@(op, ct)
	begin
		if(
		(op == `regimm)&&
		   ((ct == `bgez)||
			(ct == `bltz)||
			(ct == `bgezal)||
			(ct == `bltzal)
			)
		)
		RegDrt_o	= 1; else RegDrt_o	= 0;
	end
	// Destination Register
	always@(op, ct)
	begin
		case (op)
			`special	:	RegDst_o <= 0;
			`addi,`addiu,`andi,`ori,
			`slti,`sltiu,`xori,
			`lb,`lbu,`lh,`lhu,
			`lui,`lw,`lwl,`lwr
						:	RegDst_o <= 1;
			`jal		:	RegDst_o <= 2;
			`regimm		:	if ((ct == `bgezal) || (ct == `bltzal))
								RegDst_o <= 2; else RegDst_o <= 0;
`ifdef	EXCEPTION
			`cop0		:	if (rs ==`mf) //MFC0
								RegDst_o <= 1; else 
								RegDst_o <= 0;
`endif	//EXCEPTION				
			default		:	RegDst_o <= 0;
		endcase
	end
	
	// Branch operation
	always@(op, funct, ct)
	begin
		case (op)
			`special	:begin
							if ((funct == `jr)||(funct == `jalr))
								BranchSel_o	<= `REGISTER; else BranchSel_o	<= `CONTINU;
							ConditionSel_o	<= `BNV_ps;
						 end
			`regimm		:begin
							BranchSel_o <= `CONDITION;
							case(ct)
								`bgez,
								`bgezal:	ConditionSel_o <= `BGE_ps;
								`bltzal,
								`bltz:		ConditionSel_o <= `BLT_ps;
								default:	ConditionSel_o <= `BNV_ps;
							endcase
						 end
			`j, `jal	:begin
							BranchSel_o		<= `UNCONDITION;
							ConditionSel_o	<= `BNV_ps;
						 end
			`beq		:begin
							BranchSel_o		<= `CONDITION;
							ConditionSel_o	<= `BEQ_ps;
						 end
			`bgtz		:begin
							BranchSel_o		<= `CONDITION;
							ConditionSel_o	<= `BGT_ps;
						 end
			`blez		:begin
							BranchSel_o		<= `CONDITION;
							ConditionSel_o	<= `BLE_ps;
						 end
			`bne		:begin
							BranchSel_o		<= `CONDITION;
							ConditionSel_o	<= `BNE_ps;
						 end
			default		:begin
							BranchSel_o		<= `CONTINU;
							ConditionSel_o	<= `BNV_ps;
						 end
		endcase
		
	end
	
	// Shift operations
	always@(op, funct)
	begin
		if ((op == `special) && (
			 (funct == `sllv)||
			 (funct == `srlv)||
			 (funct == `srav)))
		ShiftVar_o <= `HIGH; else ShiftVar_o <= `LOW;
		
		if ((op == `special) &&	(
			 (funct == `sll)||
			 (funct == `sllv)))
		ShiftLr_o <= `HIGH; else ShiftLr_o <= `LOW;
		
		if ((op == `special) && (
			 (funct == `sra)||
			 (funct == `srav)))
		ShiftLa_o <= `LOW; else ShiftLa_o <= `HIGH;
	end

	// Multiplication/Division operations
	always@(op, funct)
	begin
		if ((op == `special) && (
			 (funct == `mult)||
			 (funct == `div)))
		MultDivSign_o <= `HIGH; else MultDivSign_o <= `LOW;
		
		if ((op == `special) && (
			 (funct == `mult)||
			 (funct == `multu)))
		MultDivOp_o <= `HIGH; else MultDivOp_o <= `LOW;
		
		if ((op == `special) && (
			 (funct == `mult)||
			 (funct == `multu)||
			 (funct == `div)||
			 (funct == `divu)))
		MultDivStart_o <= `HIGH; else MultDivStart_o <= `LOW;
		
		if ((op == `special) && (
			 (funct == `mthi)))
		MultDivHiW_o <= `HIGH; else MultDivHiW_o <= `LOW;
		
		if ((op == `special) && (
			 (funct == `mtlo)))
		MultDivLoW_o <= `HIGH; else MultDivLoW_o <= `LOW;
	end

	/* Co-processor 0 */
	assign CoSys_o		=	((op ==`special) && (funct ==`syscall));
	assign CoBreak_o	=	((op ==`special) && (funct ==`break));
	assign CoRfe_o		=	((op ==`cop0) && (blank == 0) && (funct ==`rfe));
	assign CoMf_o		=	((op ==`cop0) && (rs ==`mf) && (shamt == 0) && (funct == 0));
	assign CoMt_o		=	((op ==`cop0) && (rs ==`mt) && (shamt == 0) && (funct == 0));
	
endmodule 