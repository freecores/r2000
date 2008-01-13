//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_regfile.v			                                  ////
////                                                              ////
//// This file is part of the r2000pl Pipelined				  	  ////
////	opencores effort.										  ////
////	Simple Pipelined Mips 32 bits processor				  	  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// 32 x 32 bits register file		                              ////
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
/*=============================================================
	project		:	r2000pl Single Cycle
	description	:	Simple Pipelined Mips 32 bits processor
=============================================================
	file name	:	r2000_regfile.v
=============================================================
	designer	:	Abdallah Meziti El-Ibrahimi
	mail 		: 	abdallah.meziti@gmail.com
=============================================================*/
`include "timescale.v"
`include "define.h"

/* ====================
	module definition
   ==================== */
module r2000_regfile
	(
		en_i			,
		/* Input */
		clk_i			,
		rst_i			,
		
		/* Read frome the register file */
		// The read registers 
		RdIndex1_i		,	Data1_o			,   
		RdIndex2_i		,   Data2_o         ,
		
		/* Write to register file */
		WrIndex_i		,	Data_i			,
		Wr_i				// The write control
		
	);
/* --------------------------------------------------------------
	in, out declaration
   ------------------- */
	input [4:0]			RdIndex1_i		,
						RdIndex2_i		,
						WrIndex_i		;
	input				en_i			;
	input [`dw-1:0]		Data_i			;
	input				Wr_i			;
	input				clk_i			;
	input				rst_i			;
	
	output [`dw-1:0]	Data1_o			,
						Data2_o			;
	
/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
	reg [`dw-1:0] 		rf_reg [0:`dw-1]	; // dw bits x 32 registers
	integer				i					;

/* --------------------------------------------------------------
	instances, statements
   ------------------- */

	// R[0] always 0
//	initial rf_reg[`zer0] = `ZERO;
		
	// Write synchronously in the register file
	always@(`CLOCK_EDGE clk_i, `RESET_EDGE rst_i)
	begin
		if (rst_i == `RESET_ON)
			for (i = 0; i < `dw; i = i + 1)
				rf_reg[i] = `ZERO;
		// write the register with new value if Wr_i is high
		else if(Wr_i && (en_i == `SET))
			if (WrIndex_i != `zer0)	/* Don't write in r[0]  */
				rf_reg[WrIndex_i] = Data_i;
	end
	// Read asynchronously from the register file
	assign Data1_o = rf_reg[RdIndex1_i];
	assign Data2_o = rf_reg[RdIndex2_i];
	
endmodule