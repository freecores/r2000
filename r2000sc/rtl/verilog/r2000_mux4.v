//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_mux4.v				                                  ////
////                                                              ////
//// This file is part of the r2000sc SingleCycle				  ////
////	opencores effort.										  ////
////	Simple Single-cycle Mips 32 bits processor				  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// 4 way  WIDHTH bits multiplexer                               ////
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
module	r2000_mux4
	(
		/* input */
		in0_i		,	// input A
		in1_i		,	// input B
		in2_i		,	// input C
		in3_i		,	// input D
		sel_i		,	// sel_i
		/* Output */
		out_o			// Output
	);
	
/* --------------------------------------------------------------
	parameters
   ------------------- */
	parameter	WIDHTH=`dw;

/* -------------------------------------------------------------- */
/* in, out declaration */
/* ------------------- */
	input [WIDHTH-1:0]	in0_i	,
						in1_i	,
						in2_i	,
						in3_i	;
	                         	
	input [1:0]			sel_i	;
                             	
	output [WIDHTH-1:0]	out_o	;
	
/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */

//* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */

	assign out_o =	(sel_i == 0) ?	in0_i:
					(sel_i == 1) ?	in1_i:
					(sel_i == 2) ?	in2_i:
									in3_i;

endmodule