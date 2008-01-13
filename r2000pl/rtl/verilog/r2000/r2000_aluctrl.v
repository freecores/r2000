//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_aluctrl.v			                                  ////
////                                                              ////
//// This file is part of the r2000pl Pipelined				  	  ////
////	opencores effort.										  ////
////	Simple Pipelined Mips 32 bits processor				  	  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// Control the operations of the ALU                            ////
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
module	r2000_aluctrl
	(
		/* Input */
		AluOp_i				,	// Alu Operation from the instruction decoder
		FuncCode_i			,	// Function Code from the funct instruction field
		/* Output */
		AluCtl_o				// Alu control to the alu module
	);
/* --------------------------------------------------------------
	in, out declaration
   ------------------- */
	input[2:0]			AluOp_i		;
	input[5:0]			FuncCode_i	;

	output[3:0]			AluCtl_o	;

/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
	reg [3:0]			AluCtl_o	;
/* --------------------------------------------------------------
	instances, statements
   ------------------- */
      
	always @ (AluOp_i, FuncCode_i)
		case (AluOp_i)						/* I-Format instructions */
			3'd0	:	AluCtl_o	<=	`aluop_add; 	// add
			3'd1	:	AluCtl_o	<=	`aluop_sub; 	// sub
			3'd2	:	AluCtl_o	<=	`aluop_and; 	// and
			3'd3	:	AluCtl_o	<=	`aluop_or; 		// or
			3'd4	:	AluCtl_o	<=	`aluop_slt; 	// slt
			3'd5	:	AluCtl_o	<=	`aluop_sltu; 	// sltu
			3'd6	:	AluCtl_o	<=	`aluop_xor;	 	// xor
			3'd7	:	case (FuncCode_i)	/* R-Format instructions */
							`add,									// add
							`addu	: AluCtl_o	<=	`aluop_add; 	// addu
							`sub,									// sub
							`subu	: AluCtl_o	<=	`aluop_sub; 	// subu
							`and	: AluCtl_o	<=	`aluop_and; 	// and
							`or		: AluCtl_o	<=	`aluop_or;	 	// or
							`xor	: AluCtl_o	<=	`aluop_xor;	 	// xor
							`nor	: AluCtl_o	<=	`aluop_nor;		// nor
							`slt	: AluCtl_o	<=	`aluop_slt; 	// slt
							`sltu	: AluCtl_o	<=	`aluop_sltu; 	// sltu
							default	: AluCtl_o	<=	`aluop_tra;		// Transfert
						endcase
			default	:	AluCtl_o	<=	`aluop_add; 	// add
	endcase
endmodule 	
