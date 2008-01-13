//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_pc.v					                                  ////
////                                                              ////
//// This file is part of the r2000pl Pipelined				  	  ////
////	opencores effort.										  ////
////	Simple Pipelined Mips 32 bits processor				  	  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// Programm Counter module		                              ////
////                                                              ////
//// To Do:                                                       ////
//// 				                                              ////
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
module	r2000_pc
	(
		/* Input */
		clk_i			,
		rst_i			,

		mux_pc_i		,
		stall_i			,
		/* Output */
		PC_o			,
		PC4_o						
	);
	
/* --------------------------------------------------------------
	parameters
   ------------------- */
	parameter	WIDHTH=`dw;

/* -------------------------------------------------------------- */
/* in, out declaration */
/* ------------------- */
	                         	
	input				clk_i	;
	input				rst_i	;

	input				stall_i	;

	input [`dw-1:0]		mux_pc_i;  	
                             	
	output [WIDHTH-1:0]	PC_o	;
	output [WIDHTH-1:0]	PC4_o	;
	
/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */
	reg [`dw-1:0]		rPC		;

//* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */

	always@(`CLOCK_EDGE clk_i, `RESET_EDGE rst_i)
	begin
		if (rst_i == `RESET_ON)begin					// RESET	: clear the pc
			rPC			= `ZERO;
		end	else if (stall_i)begin						// STALL	: do not update
			rPC			= rPC;
		end else begin									// ELSE		: get the value from the mux_pc
			rPC			= mux_pc_i;
		end
	end

	assign PC_o		=	rPC;
	assign PC4_o	=	rPC + `aw'd4;

endmodule