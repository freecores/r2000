//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_shifter.v			                                  ////
////                                                              ////
//// This file is part of the r2000pl Pipelined				  	  ////
////	opencores effort.										  ////
////	Simple Pipelined Mips 32 bits processor				  	  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// 32 bits left/right logic/arithmetic barrel shifter           ////
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
module	r2000_shifter
	(
		/* Input */
		A_i				,	// Operand A
		SH_i			,	// Shift amount
		LR_i			, 	// Left/Right
		LA_i			,	// Logic/Arithmetic
		/* Output */
		G_o					// Out shifted
	);
/* -------------------------------------------------------------- */
/* in, out declaration */
/* ------------------- */
	input [`dw-1:0]		A_i		;
	input [4:0]			SH_i	;
	input 				LR_i	,
						LA_i	;

	output	[`dw-1:0]	G_o		;

/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */
	wire [1:0]			wSo1			,
						wSo2			,
						wSo3			;	// Outputs of the Selective 2's complement
	wire [63:0] 		wAext			,
						wGext			;	// Operand A , Out extension
	wire [63:0] 		wFirstStageOut	;
	wire [63:0] 		wSecondStageOut	;
	
/* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */
	r2000_selectshift Selective_inst
	(
		/* Input */
		.SH_i		(SH_i),	// Shift amount
		.LR_i		(LR_i), 	// Left/Right
		/* Output */
		.So1_o	(wSo1),	// First Stage Mux Select
		.So2_o	(wSo2),	// Second Stage Mux Select
		.So3_o	(wSo3) 	// Third Stage Mux Select
	);
	
	assign	wAext = (LA_i) ?
						{{32'b0}			,A_i}:	// Logic
						{{32{A_i[`dw-1]}}	,A_i};	// Arithmetic

	// Generate 47Bit First Stage 4to1 Mux
	generate
		genvar i; // for generate logic
		for (i=0; i<64; i=i+1)
		begin : u
			r2000_mux4 #(1) MuxFirstStage
					(
						/* Input */
						.in0_i	(wAext[i]),
						.in1_i	(wAext[((i>(63-16))?i-(64-16)-16:i)+16]),
						.in2_i	(wAext[((i>(63-32))?i-(64-32)-32:i)+32]),
						.in3_i	(wAext[((i>(63-48))?i-(64-48)-48:i)+48]),
						.sel_i	(wSo1),		
						/* Output */
						.out_o	(wFirstStageOut[i])
					);
		end
	endgenerate
	
	// Generate 35Bit Second Stage 4to1 Mux
	generate
		genvar j; // for generate logic
		for (j=0; j<64; j=j+1)
		begin : v
			r2000_mux4 #(1) MuxSecondStage
					(
						/* Input */
						.in0_i	(wFirstStageOut[j]),
						.in1_i	(wFirstStageOut[((j>(63-4))?j-(64-4)-4:j)+4]),
						.in2_i	(wFirstStageOut[((j>(63-8))?j-(64-8)-8:j)+8]),
						.in3_i	(wFirstStageOut[((j>(63-12))?j-(64-12)-12:j)+12]),
						.sel_i	(wSo2),		
						/* Output */
						.out_o	(wSecondStageOut[j])
					);
		end
	endgenerate
	
	// Generate 32Bit Second Stage 4to1 Mux
	generate
		genvar k; // for generate logic
		for (k=0; k<64; k=k+1)
		begin : z
			r2000_mux4 #(1) MuxThirdStage
					(
						/* Input */
						.in0_i	(wSecondStageOut[k]),
						.in1_i	(wSecondStageOut[((k>(63-1))?k-(64-1)-1:k)+1]),
						.in2_i	(wSecondStageOut[((k>(63-2))?k-(64-2)-2:k)+2]),
						.in3_i	(wSecondStageOut[((k>(63-3))?k-(64-3)-3:k)+3]),
						.sel_i	(wSo3),		
						/* Output */
						.out_o	(wGext[k])
					);
		end
	endgenerate
	
	assign G_o = wGext[32:0];

endmodule

/*	===============================================================================	*/

/* ================= */
/* module definition */
/* ================= */
module	r2000_selectshift
	(
		/* Input */
		SH_i		,	// Shift amount
		LR_i		,	// Left/Right
		/* Output */
		So1_o		,	// First Stage Mux Select
		So2_o		,	// Second Stage Mux Select
		So3_o		 	// Third Stage Mux Select
	);
/* -------------------------------------------------------------- */
/* in, out declaration */
/* ------------------- */
	input [4:0]			SH_i	;
	input 				LR_i	;

	output[1:0]			So1_o	,
						So2_o	,
						So3_o	;
	
/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */
	wire [5:0] 			SHext	;	// SH extended
	wire [5:0] 			SHcmp	;	// SH 2's complement
	wire [6:0] 			Cmd		;	// for the 2's complement
	wire [5:0] 			Out		;	// SH out
	
//* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */
	assign SHext = {1'b0,SH_i};

	assign 	Cmd[0] = 1'b0;
	// Generate 6Bits 2's complement	
	generate
		genvar i; // for generate logic
		for (i=0; i<6; i=i+1)
		begin : u
			xor (SHcmp[i], SHext[i], Cmd[i]);
			or	(Cmd[i+1], Cmd[i], SHext[i]);
		end
	endgenerate

	assign Out = (LR_i) ? SHcmp : SHext;

	assign		So1_o = Out[5:4];
	assign		So2_o = Out[3:2];
	assign		So3_o = Out[1:0];
	
endmodule
		
