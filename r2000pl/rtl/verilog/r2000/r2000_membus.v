//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_MemInterface.v		                                  ////
////                                                              ////
//// This file is part of the r2000pl Pipelined				  	  ////
////	opencores effort.										  ////
////	Simple Pipelined Mips 32 bits processor				  	  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// Simple cpu<->memory interface.                               ////
////	- can perform the all transfert to memory instruction     ////
////	- the lwl, lwr, swl, swr are not implemented due          ////
////		to the architecture of the memorys that not permit    ////
////        unalignde instruction.								  ////
////		but possible with other architecture				  ////
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
module r2000_mem2reg
	(
		/* Input */
		MemData_i		,	// Memory Side
		Length_i		,	// WORD, HALF, BYTE
		Sign_i			,	// Signe extension type

		Ad_i			,	// The two least significant bits effective address
		Rd_i			,	// Read enable
		
		/* Output */
		RegData_o		,	// Register Side
		low1_o			,	// Low octet memory	1
		high1_o			,	// High octet memory 1
		low2_o			,	// Low octet memory	2
		high2_o				// High octet memory 2
	);
	
/* --------------------------------------------------------------
	parameters
   ------------------- */
	parameter	pEndian = `ENDIAN;

/* --------------------------------------------------------------
	in, out declaration
   ------------------- */
	output[`dw-1:0]		RegData_o		;
	input[1:0]			Length_i		;
	input				Sign_i			;
                		
	input[1:0]			Ad_i			;
	input				Rd_i			;

	input[`dw-1:0]		MemData_i		;

	output				low1_o			;
	output				high1_o			;
	output				low2_o			;
	output				high2_o			;
                		
/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */
	reg[`dw-1:0]		RegData_o		;
	reg[`dw-1:0]		rTemp			;
	reg					rLow1			;	
	reg					rHigh1			;
	reg					rLow2			;
	reg					rHigh2			;	

	wire[1:0]			wEndian			;

/* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */

	/* Select the byte in function of the pEndian */
	assign wEndian = Ad_i ^ {2{pEndian}};
	
	/* ********************************* */
	/* MEMORY TO REGISTER FILE INTERFACE */
	/* ********************************* */
	always@(Length_i, wEndian, Sign_i, MemData_i, rTemp)
	begin

		case(Length_i)
			`WORD: begin
				 		rTemp = MemData_i;
						RegData_o = rTemp;
						{rHigh2, rLow2, rHigh1, rLow1} = {`LOW, `LOW, `LOW, `LOW};
`ifdef MESSAGE_MEMBUS
						if (wEndian != 2'b00) $display("Mem -> Reg : WORD error");
`endif
				   end
			`HALF: begin
					case(wEndian[1])
						1'b0:begin
								rTemp[15:0] = MemData_i[15:0];
								{rHigh2, rLow2, rHigh1, rLow1} = {`HIGH, `HIGH, `LOW, `LOW};
								end
						1'b1:begin
								rTemp[15:0] = MemData_i[31:16];
								{rHigh2, rLow2, rHigh1, rLow1} = {`LOW, `LOW, `HIGH, `HIGH};
								end
						default:begin
								rTemp[15:0] = MemData_i;
								{rHigh2, rLow2, rHigh1, rLow1} = {`HIGH, `HIGH, `HIGH, `HIGH};
								end
					endcase
					if (Sign_i)
						RegData_o = {{16{rTemp[15]}},rTemp[15:0]};
					else
						RegData_o = {{16{1'b0}},rTemp[15:0]};
`ifdef MESSAGE_MEMBUS
					if (wEndian[0] != 1'b0) $display("Mem -> Reg : HALF error");
`endif
				   end
			`BYTE: begin 
					case(wEndian)
						2'b00:begin
								rTemp[7:0] = MemData_i[7:0];
								{rHigh2, rLow2, rHigh1, rLow1} = {`HIGH, `HIGH, `HIGH, `LOW};
								end
						2'b01:begin
								rTemp[7:0] = MemData_i[15:8];
								{rHigh2, rLow2, rHigh1, rLow1} = {`HIGH, `HIGH, `LOW, `HIGH};
								end
						2'b10:begin
								rTemp[7:0] = MemData_i[23:16];
								{rHigh2, rLow2, rHigh1, rLow1} = {`HIGH, `LOW, `HIGH, `HIGH};
								end
						2'b11:begin
								rTemp[7:0] = MemData_i[31:24];
								{rHigh2, rLow2, rHigh1, rLow1} = {`LOW, `HIGH, `HIGH, `HIGH};
								end
						default:begin
								rTemp[7:0] = MemData_i;
								{rHigh2, rLow2, rHigh1, rLow1} = {`HIGH, `HIGH, `HIGH, `HIGH};
`ifdef MESSAGE_MEMBUS
								$display("Mem -> Reg : BYTE error");
`endif
								end
					endcase
					if (Sign_i)
						RegData_o = {{24{rTemp[7]}},rTemp[7:0]};
					else
						RegData_o = {{24{1'b0}},rTemp[7:0]};
				   end
			default:begin
						rTemp = MemData_i;
						RegData_o = rTemp;
						{rHigh2, rLow2, rHigh1, rLow1} = {`HIGH, `HIGH, `HIGH, `HIGH};
`ifdef MESSAGE_MEMBUS
						$display("Mem -> Reg : LENGTH ? error");
`endif
				   end
		endcase
	end

	assign low1_o = (Rd_i)? rLow1 : `HIGH; // !
	assign high1_o= (Rd_i)? rHigh1: `HIGH; // !
	assign low2_o = (Rd_i)? rLow2 : `HIGH; // !
	assign high2_o= (Rd_i)? rHigh2: `HIGH; // !
	
	
endmodule

/* ====================
	module definition
   ==================== */
module r2000_reg2mem
	(
		/* Input */
		RegData_i		,	// Register Side
		Length_i		,	// WORD, HALF, BYTE

		Ad_i			,	// The two least significant bits effective address
		Oe_i			,	// Output Enable Memory data
		
		/* Output */
		MemData_o		,	// Memory Side
		low1_o			,	// Low octet memory	1 	
		high1_o			,	// High octet memory 1
		low2_o			,	// Low octet memory	2 
		high2_o			 	// High octet memory 2
	);
	
/* --------------------------------------------------------------
	parameters
   ------------------- */
	parameter	pEndian = `ENDIAN;

/* --------------------------------------------------------------
	in, out declaration
   ------------------- */
	input[`dw-1:0]		RegData_i		;
	input[1:0]			Length_i		;
                		
	input[1:0]			Ad_i			;
	input				Oe_i			;

	output[`dw-1:0]		MemData_o		;
	output				low1_o			;
	output				high1_o			;
	output				low2_o			;
	output				high2_o			;

                		
/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */
	reg[`dw-1:0]	rTemp			;
//	reg[`dw-1:0]	MemData_o		;
	reg				rLow1			;	
	reg				rHigh1			;
	reg				rLow2			;
	reg				rHigh2			;	

	wire[1:0]		wEndian			;
/* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */
	
	assign wEndian = Ad_i ^ {2{pEndian}};

	/* ********************************* */
	/* REGISTER FILE TO MEMORY INTERFACE */
	/* ********************************* */
	always@(RegData_i, Length_i, wEndian, MemData_o)
	begin

		case(Length_i)
			`WORD: begin 
					rTemp = RegData_i;
					{rHigh2, rLow2, rHigh1, rLow1} = {`LOW, `LOW, `LOW, `LOW};
`ifdef MESSAGE_MEMBUS
						if (wEndian != 2'b00) $display("Reg -> Mem : WORD error");
`endif
				   end
			`HALF: begin
					case(wEndian[1])
						1'b0:begin
								rTemp = {{16{1'b0}}, RegData_i[15:0]};
								{rHigh2, rLow2, rHigh1, rLow1} = {`HIGH, `HIGH, `LOW, `LOW};
								end
						1'b1:begin
								rTemp = {RegData_i[15:0], {16{1'b0}}};
								{rHigh2, rLow2, rHigh1, rLow1} = {`LOW, `LOW, `HIGH, `HIGH};
								end
						default:begin
								rTemp = RegData_i;
								{rHigh2, rLow2, rHigh1, rLow1} = {`LOW, `LOW, `LOW, `LOW};
`ifdef MESSAGE_MEMBUS
								$display("Reg -> Mem : HALF error");
`endif
								end
					endcase
					
				   end
			`BYTE: begin 
					case(wEndian)
						2'b00:begin
							rTemp = {{24{1'b0}}, RegData_i[7:0]};
							{rHigh2, rLow2, rHigh1, rLow1} = {`HIGH, `HIGH, `HIGH, `LOW};
								end
						2'b01:begin
							rTemp = {{16{1'b0}},RegData_i[7:0],{8{1'b0}}};
							{rHigh2, rLow2, rHigh1, rLow1} = {`HIGH, `HIGH, `LOW, `HIGH};
								end

						2'b10:begin
							rTemp = {{8{1'b0}},RegData_i[7:0],{16{1'b0}}};
							{rHigh2, rLow2, rHigh1, rLow1} = {`HIGH, `LOW, `HIGH, `HIGH};
								end

						2'b11:begin
							rTemp = {RegData_i[7:0],{24{1'b0}}};
							{rHigh2, rLow2, rHigh1, rLow1} = {`LOW, `HIGH, `HIGH, `HIGH};
								end

						default:begin
							rTemp = RegData_i;
							{rHigh2, rLow2, rHigh1, rLow1} = {`LOW, `LOW, `LOW, `LOW};
`ifdef MESSAGE_MEMBUS
							$display("Reg -> Mem : BYTE error");
`endif
								end

					endcase
		   		  end
					
			default:begin
				 		rTemp = RegData_i;
						{rHigh2, rLow2, rHigh1, rLow1} = {`HIGH, `HIGH, `HIGH, `HIGH};
`ifdef MESSAGE_MEMBUS
						$display("Reg -> Mem : LENGTH ? error");
`endif
			   		end
		endcase
	end

`ifdef ONE_BUS_MEM       	
	assign MemData_o	= rTemp ;
	                            
	assign low1_o 		= rLow1 ;
	assign high1_o		= rHigh1;
	assign low2_o 		= rLow2 ;
	assign high2_o		= rHigh2;
`else                   	
	assign MemData_o	= (Oe_i)? rTemp : `dw'bz;  //  !
	                                               
	assign low1_o 		= (Oe_i)? rLow1 : `HIGH;   //  !
	assign high1_o		= (Oe_i)? rHigh1: `HIGH;   //  !
	assign low2_o 		= (Oe_i)? rLow2 : `HIGH;   //  !
	assign high2_o		= (Oe_i)? rHigh2: `HIGH;   //  !
`endif

endmodule
