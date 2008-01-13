//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_multiplier.v			                                  ////
////                                                              ////
//// This file is part of the r2000sc SingleCycle				  ////
////	opencores effort.										  ////
////	Simple Single-cycle Mips 32 bits processor				  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// 32 bits x 32 bits = 64 bits un/signed multipler              ////
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
// Unsigned/Signed multiplication based on
// Advanced Digital Design with the Verilog HDL book fig10-40.
// Description: Calculates product_o.
//				The "sign" input determines whether
//              signs (two's complement) should be taken into consideration.
module r2000_multiplier
	(
		/* Input */
		clk_i			,
		rst_i			,
		word1_i			,	// Multiplicand
		word2_i			,	// Multiplicater
		sign_i			,	// un/signed operation
		start_i			,	// start the operation
		/* Output */	
		product_o		,	// Write to HI, LO registers
		ready_o			,	// End of the operation
		write_o
	);
/* --------------------------------------------------------------
	parameters
   ------------------- */
	parameter 				L_word = `dw;
	parameter				L_cnt = 5	;
	
/* --------------------------------------------------------------
	in, out declaration
   ------------------- */
	output 	[2*L_word-1:0] 	product_o	;
	output					ready_o		,
							write_o		;

	input	[L_word-1: 0] 	word1_i		,
							word2_i		;
	input 					start_i		,
							sign_i		,
							clk_i		,
							rst_i		;
	
/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
	reg [1:0]				sState		,
							sNextState	;
	reg	[L_word-1: 0] 		rMultiplicand;	
	reg [2*L_word: 0]		rProductTemp;
	reg 					rLoadWords	;
	reg						rShift		,
							rAddShift	,
							rIncrement	,
							rWrite		;
	reg	[L_cnt-1 :0] 		rCounter	;
	reg						rNegOut		;
	
	parameter				IDLE = 0, RUNNING = 1, WRITE = 2;
	wire 					ready_o = (sState == IDLE) && (rst_i != `RESET_ON); 
 
/* --------------------------------------------------------------
	instances, statements
   ------------------- */
	// Controller
	always @ (`CLOCK_EDGE clk_i, `RESET_EDGE rst_i)  	// State transitions
		if (rst_i == `RESET_ON)
			sState <= IDLE;
		else
			sState <= sNextState; 

	// Combinational logic for ASM-based controller
	always @ (sState, start_i, rProductTemp, rCounter)//, Empty)
	begin
		rLoadWords = 0; rShift = 0; rAddShift = 0; rIncrement = 0; rWrite = 0;// Flush = 0;
		
		case (sState)
			IDLE:		/* Reset the state machine */
				if (!start_i)
					sNextState = IDLE;
				else begin
					rLoadWords = 1;
					sNextState = RUNNING;
				end
		
			RUNNING:	/* The division operation */
				begin
					rIncrement = 1; 
					if (rProductTemp[0])
						rAddShift = 1;
					else
						rShift = 1;
					if (rCounter == L_word-1)
						sNextState = WRITE; 
					else
						sNextState = RUNNING;
				end
			WRITE:	/* Write the result to HI, LO registers */
				begin
					rWrite = 1;
					sNextState = IDLE; 
				end
			default: 	sNextState = IDLE;
		endcase
	end
 
	// Register/Datapath Operations
	always @ (`CLOCK_EDGE clk_i, `RESET_EDGE rst_i) 
		if (rst_i == `RESET_ON) begin
			rMultiplicand = 0; rProductTemp = 0; rCounter = 0;
		end else begin 
			if (rLoadWords == 1) begin
				rMultiplicand = word1_i;
				
				/* Traitement of the signs of inputs and output */
			    rMultiplicand = (!sign_i || !word1_i[L_word-1]) ? 
		                            word1_i: 
		                           ~word1_i + 1'b1;
		    	rProductTemp = (!sign_i || !word2_i[L_word-1]) ?
		                            {{L_word{1'b0}}, word2_i} :
		                            {{L_word{1'b0}},~word2_i + 1'b1};
				rNegOut = sign_i && 
		                        ((word1_i[L_word-1] && !word2_i[L_word-1]) 
		                      ||(!word1_i[L_word-1] &&  word2_i[L_word-1]));
				rCounter = 0;
			end
			
			/* Division Operation */
			if (rShift)
				rProductTemp = rProductTemp >> 1;

			if (rAddShift)begin 
				rProductTemp[2*L_word: L_word] = rProductTemp[2*L_word: L_word] + rMultiplicand;
				rProductTemp = rProductTemp >> 1;
			end

			if (rIncrement)
				rCounter = rCounter + 1;
		end
		
	/* Traitement of the sign of the output */
	assign	product_o = (!rNegOut) ? 
	                 rProductTemp[2*L_word-1:0] : 
	                ~rProductTemp[2*L_word-1:0] + 1'b1;
	                
	/* Signal to write the registers to HI, LO register */                
	assign	write_o = rWrite;
	
endmodule
