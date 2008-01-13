//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_comparator.v  comparator module						  ////
////                                                              ////
//// This file is part of the r2000pl Pipelined				  	  ////
////	opencores effort.										  ////
////	Simple Pipelined Mips 32 bits processor				  	  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// WIDHTH bits Arithmetic comparator can perform:				  ////
//// 	- signed SUB	                                          ////
////    - set the status flags used in conditionnal branch        ////
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
module r2000_cmp
	(
		/* Input */
		A_i			,	// Operand A
		B_i			,	// Operand B
		/* Output */
		Status_o		// Status Flags
	);
/* --------------------------------------------------------------
	parameters
   ------------------- */
	parameter	WIDHTH=`dw;
	
/* --------------------------------------------------------------
	in, out declaration
   ------------------- */
	
	input  signed [WIDHTH-1:0]	A_i,B_i	;	// the inputs A_i, B_i are traited as signed
	output [3:0]				Status_o	;
	
/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
	wire [WIDHTH:0]				rResult					;	// Extended Result to n+1 bits for the carry flag
	wire[WIDHTH-1:0]			wResultExt = rResult[WIDHTH-1:0];

	wire						wZero					,
								wOver					,
								wCarry					,
								wNeg					;
	                        	        				
	wire						wRn = rResult[WIDHTH-1]	;
	wire 						wAn = A_i[WIDHTH-1]		;	// MSB
	wire 						wBn = B_i[WIDHTH-1]		;	// MSB
	wire    					wSubt					;
	
/* --------------------------------------------------------------
	instances, statements
   ------------------- */
	assign rResult	=   A_i - B_i;					// Arithmetic comparaison : Signed SUB
		
	assign wCarry 	= rResult[WIDHTH];						// Carry flag
	assign wNeg		= wResultExt[WIDHTH-1];					// Negate flag
	assign wZero 	= (wResultExt == `ZERO);				// Zero flag
	
	assign wSubt	= 1'b1;									// Sub
	assign wOver	= 	(( wRn & ~wAn & ~(wSubt ^ wBn))		// Overflow flag
				  		|(~wRn &  wAn &  (wSubt ^ wBn)));
				  
	assign Status_o = {wCarry, wZero, wNeg, wOver};			// The Status flags
	
endmodule