//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_pipe.v			                                  	  ////
////                                                              ////
//// This file is part of the r2000pl Pipelined				  	  ////
////	opencores effort.										  ////
////	Simple Pipelined Mips 32 bits processor				  	  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// n bits register with stall, flush, stop function             ////
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
module r2000_pipe
	(
		/* Input */
		clk_i			,
		rst_i			,
		
		stall_i			,
		flush_i			,
		
		D_i				,	// Data in
		Q_o					// Data Out
	);
/* --------------------------------------------------------------
	parameters
   ------------------- */
	parameter	WIDHTH=`dw;

/* --------------------------------------------------------------
	in, out declaration
   ------------------- */
	input					clk_i		;
	input					rst_i		;
	
	input 					stall_i		,
							flush_i		;
							
	input	[WIDHTH-1:0]	D_i			;
	
	output	[WIDHTH-1:0]	Q_o			;
	
/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
	reg [WIDHTH-1:0] 		rQ			; 

/* --------------------------------------------------------------
	instances, statements
   ------------------- */

   // priority of stall over flush
   
	always@(`CLOCK_EDGE clk_i)
	// Write synchronously in the register
	begin
		if (rst_i == `RESET_ON)
			rQ = `LOW;		// reset synchronously
		else if(stall_i == `HIGH)
			rQ = rQ;		// don't update
		else if(flush_i == `HIGH)//(suppress glith from the combinatorial calculeted flush signal)
			rQ = `LOW;		// clear
		else
			rQ = D_i;		// else update
	end
	
	// Read asynchronously from the register
	assign Q_o = rQ;
	
endmodule