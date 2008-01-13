//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_forward.v			                                  ////
////                                                              ////
//// This file is part of the r2000pl Pipelined				  	  ////
////	opencores effort.										  ////
////	Simple Pipelined Mips 32 bits processor				  	  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// The Forwarding Unit			                              ////
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
module	r2000_forward
	(
		/* input */
		id_rs_i			,
		id_rt_i			,
		
		ex_rd_i			,	ex_reg_write_i	,
		mem_rd_i		,	mem_reg_write_i	,
		wb_rd_i			,	wb_reg_write_i 	,
		
		/* Output */
		sel_a_o			,
		sel_b_o
	);
	
/* --------------------------------------------------------------
	parameters
   ------------------- */
	parameter	WIDHTH=`iw;
	
/* -------------------------------------------------------------- */
/* in, out declaration */
/* ------------------- */
	input [WIDHTH-1:0]	id_rs_i			,
						id_rt_i			,
		
						ex_rd_i			,
						mem_rd_i		,
						wb_rd_i			;
		
	input				ex_reg_write_i	,
						mem_reg_write_i	,
						wb_reg_write_i	;
	output [1:0]		sel_a_o			,
						sel_b_o			;
	
/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */
	wire				bypassAfromEX, bypassAfromMEM, bypassAfromWB,
						bypassBfromEX, bypassBfromMEM, bypassBfromWB;

/* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */

	// The bypass to input A from the EX stage for an ALU operation
	assign bypassAfromEX	=	ex_reg_write_i & (ex_rd_i != `zer0) & (ex_rd_i == id_rs_i);	// yes, bypass
	// The bypass to input A from the MEM stage for an ALU operation
	assign bypassAfromMEM	=	mem_reg_write_i & (mem_rd_i != `zer0) & (mem_rd_i == id_rs_i) & (ex_rd_i != id_rs_i);	// yes, bypass
	// The bypass to input A from the WB stage for an ALU operation
	assign bypassAfromWB	=	wb_reg_write_i & (wb_rd_i != `zer0) & (wb_rd_i == id_rs_i) & (mem_rd_i != id_rs_i)  &  (ex_rd_i != id_rs_i);		// yes, bypass
	
	// The bypass to input B from the EX stage for an ALU operation
	assign bypassBfromEX	=	ex_reg_write_i & (ex_rd_i != `zer0) & (ex_rd_i == id_rt_i);	// yes, bypass
	// The bypass to input B from the MEM stage for an ALU operation
	assign bypassBfromMEM	=	mem_reg_write_i & (mem_rd_i != `zer0) & (mem_rd_i == id_rt_i) & (ex_rd_i != id_rt_i);	// yes, bypass
	// The bypass to input B from the WB stage for an ALU operation
	assign bypassBfromWB	=	wb_reg_write_i & (wb_rd_i != `zer0) & (wb_rd_i == id_rt_i) & (mem_rd_i != id_rt_i) & (ex_rd_i != id_rt_i);		// yes, bypass
	
	// The A input to the ALU is bypassed from MEM if there is a bypass there,
	// Otherwise from WB if there is a bypass there, and otherwise comes from the IDEX register
	assign sel_a_o =	bypassAfromEX	?	1	:
						bypassAfromMEM	?	2	:
					    bypassAfromWB	?	3	:
					    					0	;
					    					
	// The B input to the ALU is bypassed from MEM if there is a bypass there,
	// Otherwise from WB if there is a bypass there, and otherwise comes from the IDEX register
	assign sel_b_o =	bypassBfromEX	?	1	:
						bypassBfromMEM	?	2	:
						bypassBfromWB	?	3	:
											0	;
endmodule