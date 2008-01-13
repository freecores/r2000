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
		DATA	,	// Data i/o
		A		,	// Adress
		WE		,	// Write enable
		OE		,	// Output enable
		CS		,	// Chip enable
		BHE		,	// Byte High Enable
		BLE		,	// Byte Low enable
		clk
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

	input		clk	;	
/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */
	reg [2*DATA_LENGTH-1:0]			mem[0:`TAILLE_DATA-1];

/* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */

	// Write
//	always@(CS, WE, BHE, BLE)
//		if (!CS && !WE)begin
//	always@(posedge WE)
//		if (!CS)begin
	always@(negedge clk)
		if ((CS==`CLEAR) && (WE==`CLEAR))begin
			fork
				if (BHE==`CLEAR)
					mem[A][2*DATA_LENGTH-1:DATA_LENGTH] = DATA[2*DATA_LENGTH-1:DATA_LENGTH];
				if (BLE==`CLEAR)
					mem[A][DATA_LENGTH-1:0]				= DATA[DATA_LENGTH-1:0];
			join
		end
	
	// Read
	assign DATA[2*DATA_LENGTH-1:DATA_LENGTH] = (!CS && !OE && WE && !BHE) ? mem[A][2*DATA_LENGTH-1:DATA_LENGTH]	: {DATA_LENGTH{1'bz}};
	assign DATA[DATA_LENGTH-1:0]			 = (!CS && !OE && WE && !BLE) ? mem[A][DATA_LENGTH-1:0]				: {DATA_LENGTH{1'bz}};
		
		
`ifdef MESSAGE_PERI
	always @(WE or OE)
	  if (!WE && !OE)
	    $display("Operational error in SRAM: OE and WE both active");
`endif//MESSAGE_PERI
endmodule
