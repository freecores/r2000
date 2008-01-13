//////////////////////////////////////////////////////////////////////
////                                                              ////
//// SRAM.v Simple model of the SRAM IDT71V416S                   ////
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
module SRAM
	(
		CS		,	// Chip enable
		OE		,	// Output enable
		WE		,	// Write enable
		BHE		,	// Byte High Enable
		BLE		,	// Byte Low enable
		A		,	// Adress
		DATA		// Data i/o
	);
	parameter	ADDRESS_LENGTH = `dw;
	parameter	DATA_LENGTH = 8;
	
/* --------------------------------------------------------------
	in, out declaration
   ------------------- */
	input		CS	;	
	input		OE	;	
	input		WE	;	
	input		BHE	;
	input		BLE	;
	input[ADDRESS_LENGTH-1:0]		A	;	
	inout[2*DATA_LENGTH-1:0]		DATA;
	
/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */
	reg [2*DATA_LENGTH-1:0]			mem[0:`TAILLE_DATA-1];

/* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */

	assign DATA[2*DATA_LENGTH-1:DATA_LENGTH] = (!CS && !OE && WE && !BHE) ? mem[A][2*DATA_LENGTH-1:DATA_LENGTH]	: {DATA_LENGTH{1'bz}};
	assign DATA[DATA_LENGTH-1:0]			 = (!CS && !OE && WE && !BLE) ? mem[A][DATA_LENGTH-1:0]				: {DATA_LENGTH{1'bz}};
		
	always@(CS, WE, BHE, BLE)
		if (!CS && !WE)begin
			if (!BHE)	mem[A][2*DATA_LENGTH-1:DATA_LENGTH] = DATA[2*DATA_LENGTH-1:DATA_LENGTH];
			if (!BLE)	mem[A][DATA_LENGTH-1:0]				= DATA[DATA_LENGTH-1:0];
		end
		
	always @(WE or OE)
	  if (!WE && !OE)
	    $display("Operational error in SRAM: OE and WE both active");

endmodule
