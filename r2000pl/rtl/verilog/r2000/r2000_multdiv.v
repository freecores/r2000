//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_multdiv.v			                                  ////
////                                                              ////
//// This file is part of the r2000pl Pipelined				  	  ////
////	opencores effort.										  ////
////	Simple Pipelined Mips 32 bits processor				  	  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// 32 bits multiplication/dividion unit which can perform:      ////
////	- un/signed multiplication/division operation             ////
////	- start and wait for the end of operation                 ////
////    - generat extrat signal at the end for writing result     ////
////    	in others register (hi, lo)                           ////
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

//`define SIMULE

/* ====================
	module definition
   ==================== */
module r2000_multdiv
	(
		/* Input */
		clk_i			,	// 
		rst_i			,	//
		en_i			,
		
		operand1_i		,	// first operand
		operand2_i		,	// second operand
		sign_i			,	// un/signed
		datain_i		,	// data input
		mult_div_i		,	// choice of the operation
		start_i			,	// start_i the operation
		hiw_i			,	// hi write command
		low_i			,	// lo write command
		/* Output */
		hi_o			,	// hi result
		lo_o			,	// lo result
		ready_o				// end of the operation (module ready)
	); 
/* --------------------------------------------------------------
	in, out declaration
   ------------------- */
   input         		clk_i, rst_i	;
   input [`dw-1:0]		operand1_i		,
   						operand2_i		;
   						
	input				en_i			;
	
   input         		sign_i			;
   input [`dw-1:0]		datain_i		;
   input         		mult_div_i		;
   input         		start_i			;
   input         		hiw_i, low_i	;

   output [`dw-1:0]		hi_o			,
   						lo_o			;
   output 				ready_o       	;

/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
	reg [`dw-1:0]		hi_reg, lo_reg	;
	
`ifdef	SIMULE
	reg
`else
	wire
`endif
			[2*`dw-1:0]	wProduct		;
`ifdef	SIMULE
	reg
`else
	wire
`endif
			[`dw-1:0]	wQuotient		,
						wRemainder		;
						
	wire				wStartMult		,
						wStartDiv		,
						wReadyMult		,
						wReadyDiv		;
	reg					wSelReady		;
`ifdef	SIMULE
	reg
`else
	wire
`endif
						wWriteMult		,
						wWriteDiv		;
						
	wire				wStart			;
	
/* --------------------------------------------------------------
	instances, statements
   ------------------- */
   
	assign wStart		= ((en_i == `SET) && start_i);
	assign wStartMult	= wStart &  mult_div_i;
	assign wStartDiv	= wStart & ~mult_div_i;

`ifdef	SIMULE
	assign wReadyMult	= 1;
	assign wReadyDiv	= 1;
	
	always@(`CLOCK_EDGE clk_i)
	begin
		wWriteMult = 0; wWriteDiv = 0;
		
		if (wStartMult) begin
//			if (sign_i)begin
//			end else begin
				wProduct = operand1_i * operand2_i;
//			end
			wWriteMult = 1;
		end
		if (wStartDiv) begin
//			if (sign_i)begin
//			end else begin
				{wRemainder, wQuotient} = {(operand1_i % operand2_i), (operand1_i / operand2_i)};
//			end
			wWriteDiv = 1;
		end
	end
	
`else
	/* SELECT WHICH MODULE IS READY */
	always@(`CLOCK_EDGE clk_i)
		if (wStart)
			wSelReady = mult_div_i;

	/* *************** */
	/* MULTIPLIER UNIT */
	/* *************** */
	r2000_multiplier   unit_Multiplier
	(
		/* Input */
		.clk_i		(clk_i),
		.rst_i		(rst_i),
		.word1_i	(operand1_i),
		.word2_i	(operand2_i),
		.sign_i		(sign_i),
		.start_i	(wStartMult),
		/* Output */
		.product_o	(wProduct),
		.ready_o	(wReadyMult),
		.write_o  	(wWriteMult)
	);
	
	/* ************* */
	/* DIVISION UNIT */
	/* ************* */
	r2000_divisor unit_Divisor
	(
		/* Input */
		.clk_i		(clk_i),
		.rst_i		(rst_i),
		.dividend_i	(operand1_i),
		.divider_i	(operand2_i),
		.sign_i		(sign_i),
		.start_i	(wStartDiv),
		/* Output */
		.quotient_o	(wQuotient),
		.remainder_o(wRemainder),
		.write_o  	(wWriteDiv),
		.ready_o    (wReadyDiv)
	);
	
`endif

	/* ********************** */
	/* WRTIE HI, LO REGISTERS */
	/* ********************** */
	always@(`CLOCK_EDGE clk_i, `RESET_EDGE rst_i)
	begin
		if (rst_i == `RESET_ON) begin
			hi_reg = 0; lo_reg = 0;
		end else if (hiw_i)
			hi_reg = datain_i;				// Data from the datapath
		else if (low_i)
			lo_reg = datain_i;
		else if (wWriteMult)				// Data from the Multiplication unit
			{hi_reg, lo_reg} = wProduct;
		else if (wWriteDiv)					// Data from the Division unit
			{hi_reg, lo_reg} = {wRemainder, wQuotient};
	end
	
	/* SELECT WHICH MODULE IS READY */
//	assign ready_o	= (wSelReady) ? wReadyMult : wReadyDiv;
	wire   wReady	= ((wSelReady) ? wReadyMult : wReadyDiv);
	assign ready_o	= ~wStart & wReady;						// Not ready when at start signal
	
	assign hi_o = hi_reg;
	assign lo_o = lo_reg;
   
endmodule
