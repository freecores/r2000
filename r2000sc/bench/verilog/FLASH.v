//////////////////////////////////////////////////////////////////////
////                                                              ////
//// FLASH.v Simple model of the FLASH AT49BV162A                 ////
////                                                              ////
//// This file is part of the r2000sc SingleCycle				  ////
////	opencores effort.										  ////
////	Simple Single-cycle Mips 32 bits processor				  ////
//// <http://www.opencores.org/cores/YOUR DIRECTORY/>             ////
////                                                              ////
//// Module Description:                                          ////
//// YOUR MODULE DESCRIPTION                                      ////
////                                                              ////
//// To Do:                                                       ////
//// YOUR STATE HERE                                              ////
////                                                              ////
//// Author(s):                                                   ////
//// - Abdallah Meziti El-Ibrahimi   abdallah.meziti@gmail.com    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001 YOUR NAME HERE and OPENCORES.ORG          ////
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

`timescale 100ns/1ns
`include "define.h"

/* ====================
	module definition
   ==================== */
module FLASH
	(
		CS,		// Chip enable
		OE,		// Output enable
		WE,		// Write enable
		A,		// Adress
		DATA	// Data o
	);
	parameter	ADDRESS_LENGTH	= `dw;
	parameter	DATA_LENGTH		= `dw;
/* --------------------------------------------------------------
	in, out declaration
   ------------------- */
	input		CS	;	
	input		OE	;	
	input		WE	;	
	input[ADDRESS_LENGTH-1:0]	A	;	
	output[DATA_LENGTH-1:0]		DATA;
	
/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */
	reg [DATA_LENGTH-1:0]			mem[0:`TAILLE_CODE-1];

/* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */

	assign DATA = (!CS && !OE) ? mem[A]	: {DATA_LENGTH{1'bz}};
		
	always @(WE or OE)
	  if (!WE && !OE)
	    $display("Operational error in SRAM: OE and WE both active");

endmodule
