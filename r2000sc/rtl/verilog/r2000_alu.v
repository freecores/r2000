//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_alu.v  alu module									  ////
////                                                              ////
//// This file is part of the r2000sc SingleCycle				  ////
////	opencores effort.										  ////
////	Simple Single-cycle Mips 32 bits processor				  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// WIDHTH bits Arithmetic and Logic Unit which can perform:     ////
//// 	- signed ADD, SUB                                         ////
////    - AND, OR, XOR, NOR                                       ////
////	- un/signed test and set                                  ////
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
module r2000_alu
	(
		/* Input */
		AluCtl_i	,	// Alu control from the AluCtrl module
		A_i			,	// Operand A
		B_i			,	// Operand B
		/* Output */
		AluOut_o	,	// Result of the operation
		Status_o		// Status Flags
	);
/* --------------------------------------------------------------
	parameters
   ------------------- */
	parameter	WIDHTH=`dw;
	
/* --------------------------------------------------------------
	in, out declaration
   ------------------- */
	input [3:0]					AluCtl_i	;
	
//	input  [WIDHTH-1:0]			A_i,B_i		;
	input  signed [WIDHTH-1:0]	A_i,B_i	;	// the inputs A_i, B_i are traited as signed
	output [WIDHTH-1:0]			AluOut_o	;
	output [3:0]				Status_o	;
	
/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
	reg [WIDHTH:0]				rResult					;	// Extended Result to n+1 bits for the carry flag
	wire[WIDHTH-1:0]			wResultExt = rResult[WIDHTH-1:0];

	wire						wZero					,
								wOver					,
								wCarry					,
								wNeg					;
	                        	        				
	reg [WIDHTH-1:0] 			rAu						,
								rBu						;
	                        	
	wire						wRn = rResult[WIDHTH-1]	;
	wire 						wAn = A_i[WIDHTH-1]		;	// MSB
	wire 						wBn = B_i[WIDHTH-1]		;	// MSB
	wire    					wSubt					;
	
/* --------------------------------------------------------------
	instances, statements
   ------------------- */
	always @(AluCtl_i, A_i, B_i)
	begin
		rAu = A_i;	// Unsigned Operand A
		rBu = B_i;	// Unsigned Operand B
		case (AluCtl_i)
			`aluop_add		: rResult	<=   A_i + B_i;					// Arithmetic Operation : Signed ADD
			`aluop_sub		: rResult	<=   A_i - B_i;					// Arithmetic Operation : Signed SUB
			`aluop_and		: rResult	<=   A_i & B_i;					// Logic Operation : AND
			`aluop_or		: rResult	<=   A_i | B_i;					// Logic Operation : OR
			`aluop_xor		: rResult	<=   A_i ^ B_i;					// Logic Operation : XOR
			`aluop_nor		: rResult	<= ~(A_i | B_i);				// Logic Operation : NOR
			`aluop_sltu		: rResult	<=   rAu < rBu ? `ONE:`ZERO;	// Logic Operation : Unsigned Test and set
			`aluop_slt		: rResult	<=   A_i < B_i ? `ONE:`ZERO;    // Logic Operation : Signed Test and set
			default			: rResult	<= 	 B_i;						// Transfert
		endcase
	end
		
	assign wCarry 	= rResult[WIDHTH];						// Carry flag
	assign wNeg		= wResultExt[WIDHTH-1];					// Negate flag
	assign wZero 	= (wResultExt == `ZERO);				// Zero flag
	
	assign wSubt	= (AluCtl_i == `aluop_sub);
	assign wOver	= 	(( wRn & ~wAn & ~(wSubt ^ wBn))		// Overflow flag
				  		|(~wRn &  wAn &  (wSubt ^ wBn)));
				  
	assign Status_o = {wCarry, wZero, wNeg, wOver};			// The Status flags
	assign AluOut_o = wResultExt;							// The result
	
endmodule