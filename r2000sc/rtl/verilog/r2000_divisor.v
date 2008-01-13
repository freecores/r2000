//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_divisor.v			                                  ////
////                                                              ////
//// This file is part of the r2000sc SingleCycle				  ////
////	opencores effort.										  ////
////	Simple Single-cycle Mips 32 bits processor				  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// 32 bits / 32 bits = 32bits un/signed divisor with remainder  ////
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
// Unsigned/Signed division based on Patterson and Hennessy's algorithm.
// Description: Calculates quotient.  The "sign" input determines whether
//              signs (two's complement) should be taken into consideration.
module r2000_divisor
	(
		/* Input */
		clk_i			,
		rst_i			,
		start_i			,	// start the operation

		sign_i			,	// un/signed operation
		dividend_i		,	// Dividend
		divider_i		,	// Divider
		
		/* Output */
		quotient_o		,	// Quotient
		remainder_o		,	// Remainder
		write_o			,	// Write to HI, LO registers
		ready_o				// End of the operation
	);
/* --------------------------------------------------------------
	parameters
   ------------------- */
	parameter 			L_word = `dw	;
	parameter			L_cnt = 5		;
/* --------------------------------------------------------------
	in, out declaration
   ------------------- */

	input         		clk_i			,
						rst_i			;
	input        		sign_i			;
	input [L_word-1:0] 	dividend_i		,
						divider_i		;
	input         		start_i			;
	
	output [L_word-1:0]	quotient_o		,
						remainder_o		;
	output        		write_o, ready_o;

/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
	reg [L_word-1:0]	rQuotientTemp	;
	reg [2*L_word-1:0]	rDividendCopy	,
						rDividerCopy	;
//						diff;
	reg					rNegOut			;

	reg [L_cnt:0]		rCounter		;
	
	parameter 			L_state = 3		;
	parameter			IDLE = 0		, RUNNING = 1	, ERROR = 2	, WRITE = 3;
	reg [L_state-1:0]	sState			,
						sNextState		;
	reg 					rLoadWords	,
//							Shift		,
//							Flush		,
//							Increment	,
							rOperate	,
							rSubtract	,
							rWrite		;
	
//	wire     			ready_o = !rCounter;
	wire 				ready_o = (sState == IDLE) && (rst_i != `RESET_ON); 
	
	wire				GTE				;

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
	always @ (sState, start_i, GTE, rCounter)
	begin
		rLoadWords = 0; rOperate = 0; rSubtract = 0; rWrite = 0; //Increment = 0; Shift = 0;
		
		case (sState)
			IDLE:		/* Reset the sState machine */
				if (!start_i)
					sNextState = IDLE;
				else begin
					rLoadWords = 1;
					sNextState = RUNNING;
				end
		
			RUNNING:	/* The division operation */
				begin
					rOperate=1; //Increment = 1;
					if (GTE)
						rSubtract = 1;
					if (rCounter == 0)
						sNextState = WRITE; 
					else
						sNextState = RUNNING;
				end
			WRITE:	/* Write the result to HI, LO registers */
				begin
					rWrite = 1;
					sNextState = IDLE; 
				end
/*			ERROR:
				sNextState = ERROR;
			default:	sNextState = ERROR;*/
			default:	sNextState = IDLE;
		endcase
	end
   
   
//	initial rCounter = 0;
//	initial rNegOut = 0;
	
	assign GTE = (rDividendCopy >= rDividerCopy);
   
	always @(`CLOCK_EDGE clk_i, `RESET_EDGE rst_i )
		if (rst_i == `RESET_ON) begin
			rCounter = 0; rNegOut = 0;
//		end else if( ready_o 		) begin
		end else if( rLoadWords ) begin
				
			/* Traitement of the signs of inputs and output */
	        rDividendCopy	= (!sign_i || !dividend_i[31]) ?
	                        	{{L_word{1'd0}}, dividend_i} :
	                        	{{L_word{1'd0}},~dividend_i + 1'b1};
	        rDividerCopy	= (!sign_i || !divider_i[L_word-1]) ?
	                       		{1'b0, divider_i,       {(L_word-1){1'd0}}} :
	                       		{1'b0,~divider_i + 1'b1,{(L_word-1){1'd0}}};
	
	        rNegOut = sign_i &&
	                          	  ((divider_i[L_word-1] && !dividend_i[L_word-1])
	                        	||(!divider_i[L_word-1] &&  dividend_i[L_word-1]));
	
	        rQuotientTemp	= 0;
	        rCounter			= L_word-1;
			
		/* Division Operation */
//	     end else if ( rCounter > 0) begin
	     end else if ( rOperate    ) begin
//	        diff = rDividendCopy - rDividerCopy;
	        rQuotientTemp = rQuotientTemp << 1;
//			if( GTE		 ) begin
			if( rSubtract ) begin
//				rDividendCopy = diff;
				rDividendCopy		= rDividendCopy - rDividerCopy;
				rQuotientTemp[0]	= 1'd1;
	        end
	        rDividerCopy	= rDividerCopy >> 1;
	        rCounter			= rCounter - 1;
	        
    	 end
     
	/* Traitement of the sign of the output */
	assign quotient_o =	(!rNegOut) ?
						 rQuotientTemp :
						~rQuotientTemp + 1'b1;
	assign remainder_o =	(!rNegOut) ?
						 rDividendCopy[L_word-1:0] :
						~rDividendCopy[L_word-1:0] + 1'b1;
	                
	/* Signal to write the registers to HI, LO register */                
	assign write_o = rWrite;
endmodule

