//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_bradecoder.v			                                  ////
////                                                              ////
//// This file is part of the r2000sc SingleCycle				  ////
////	opencores effort.										  ////
////	Simple Single-cycle Mips 32 bits processor				  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// The Branch decoder. 	                                      ////
////	- Continue, un/conditional branch, register branch        ////
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

/* ================= */
/* module definition */
/* ================= */
module	r2000_branchdecoder
	(
		/* Input */
		BranchType_i	,	// Branch Type from instruction decoder
		CondSel_i		,	// Branch Condition  from instruction decoder
		Status_i		,	// Status flags grom the Alu
		/* Output */
//		BrDetect,
		BranchSel_o			// Selection value for the mux pc
	);
/* -------------------------------------------------------------- */
/* in, out declaration */
/* ------------------- */
	input [1:0]			BranchType_i	;
	input [3:0]			CondSel_i		;
	input [3:0]			Status_i		;
	
	output[1:0]			BranchSel_o		;
//	output				BrDetect		;
	
/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */
	wire[1:0]			BranchSel_o		;
	reg[1:0]			rBranchSel		;

	reg					rBranch			;

	wire				wZ, wC, wN, wV	;

/* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */

	assign {wC, wZ, wN, wV} = Status_i;

	always@(BranchType_i, CondSel_i, wZ, wC, wN, wV, rBranch)
	begin
	
		case (BranchType_i)
		   `CONTINU:		/* No rBranch : Normal execution */
		   		begin
					rBranchSel	= `BRANCH_NO;
					
				end
						
		   `CONDITION:		/* Conditional Branch */
		   		begin
			   		case (CondSel_i)
			   			`BRA_ps:	rBranch = 1'b1;         						/* Branch always */
			   			`BNV_ps:	rBranch = 1'b0;         						/* Branch never */
			   			`BCC_ps:	rBranch = (~wC);         						/* Branch on carry clear */
			   			`BCS_ps:	rBranch = ( wC);         						/* Branch on carry set */
			   			`BVC_ps:	rBranch = (~wV);         						/* Branch on overflow clear */
			   			`BVS_ps:	rBranch = ( wV);         						/* Branch on overflow set */
			   			`BEQ_ps:	rBranch = ( wZ);         						/* Branch on equal */
			   			`BNE_ps:	rBranch = (~wZ);         						/* Branch on not equal */
			   			`BGE_ps:	rBranch = ((~wN & ~wV) | ( wN & wV));         	/* Branch on greather than or equal */
			   			`BLT_ps:	rBranch = ( (wN & ~wV) | (~wN & wV));         	/* Branch on less than */
			   			`BGT_ps:	rBranch = (~wZ & ((~wN & ~wV) | ( wN & wV)));  	/* Branch on greather than */
			   			`BLE_ps:	rBranch = ( wZ | ( (wN & ~wV) | (~wN & wV)));  	/* Branch on less than or equal */
			   			`BPL_ps:	rBranch = (~wN);         						/* Branch on plus */
			   			`BMI_ps:	rBranch = ( wN);         						/* Branch on minus */
						default:	rBranch = 1'b0;         						/* Branch never default */
			   		endcase
			   		
			   		if (rBranch)
						rBranchSel	= `BRANCH_COND;
			   		else
						rBranchSel	= `BRANCH_NO;
				end		
				
		   `REGISTER:		/* Register Branch */
		   		begin
					rBranchSel	= `BRANCH_REG;
				end		
					
		   `UNCONDITION:	/* Unconditionnal Branch */
		   		begin
					rBranchSel	= `BRANCH_UNCOND;
				end		
					
		   default:
		   		begin
					rBranchSel	= `BRANCH_NO;
				end		
				
		endcase
	end

	/* Branch detection */
/*	assign BrDetect	= 
							(rBranchSel == `BrA)
						||	(rBranchSel == `BRANCH_REG)
						;
*/	
	assign BranchSel_o = rBranchSel;
										
endmodule