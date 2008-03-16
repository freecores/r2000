//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_cp0.v				                                  ////
////                                                              ////
//// This file is part of the r2000pl Pipelined				      ////
////	opencores effort.										  ////
////	Simple Pipelined Mips 32 bits processor				      ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// Co-processor 0					                              ////
////                                                              ////
//// To Do:                                                       ////
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

// Cause register Fields
`define 	BD		31
`define 	IP		15:8
`define 	ExcCode	6:2


// Status register Fields
`define 	BEV		22
`define 	IM		15:8


/* ================= */
/* module definition */
/* ================= */
module	r2000_cp0
	(
		// Register transfert
		rw_i			,	// Read/Write Signal
		addr_rw_i		,	// Adress of the register Write
		data_i			,	// Data in the register

		addr_rd_i		,	// Adress of the register Read
		data_o			,	// Data out of the register
		
		rfe_i			,	// Signal of the rfe instruction
		
		// Exception events signals
		brch_i			,	// Detect exception in Branch Slot 
		
		OVF_i			,	// Overflow exception
		SYS_i			,	// System exception
		INT_i			,	// Interrupt exception
		SI_i			,	// 

		// Exception control signals
		Exception_o		,	// Exception occured
		
		EPC_rpt_i		,	// PC to EPC repeat
		EPC_ctn_i		,	// PC to EPC continue
		
		PC_vec_o		,	// Exception Vector
		
		
		// System signals
		stall_i			,	// stall
		rst_i			,
		clk_i
	);
	
/* -------------------------------------------------------------- */
/* in, out declaration */
/* ------------------- */
	input				rw_i		;
	input[4:0]			addr_rw_i	;	// Adress of the register Write
	input[4:0]			addr_rd_i	;	// Adress of the register Read
	input[`dw-1:0]		data_i		;
	output[`dw-1:0]		data_o		;

	input				brch_i		;	
	input				SYS_i		;
	input				OVF_i		;
	input[5:0]			INT_i		;
	input[1:0]			SI_i		;	//
	output				Exception_o	;
		
	input[`dw-1:0]		EPC_rpt_i	;
	input[`dw-1:0]		EPC_ctn_i	;
	output[`dw-1:0]		PC_vec_o	;
	
	input				rfe_i		;
	
	input				stall_i		;
	input				rst_i		;
	input				clk_i		;
	
`ifdef	EXCEPTION

/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */
	reg [`dw-1:0] rSTATUS	;	
	reg [`dw-1:0] rCAUSE	;
	reg [`dw-1:0] rEPC		;
	
	/* STATUS Register format fields */
	wire			BEV		= rSTATUS[22]	;	// Location of Vectors
//	wire	[7:0]	IM		= rSTATUS[15:8]	;	// Interrupt Mask
	
	wire			KUo				,	// Old Kernel/User mode
					IEo				,	// Old Interrupt Enable
					KUp				,	// Previous Kernel/User mode
					IEp				,	// Previous Interrupt Enable
					KUc				,	// Current Kernel/User mode
					IEc				;	// Current Interrupt Enable


	/* CAUSE Register format fields */
//	wire	[4:0]	ExcCode	= rCAUSE[`ExcCode]	;	// Exception Code
//	wire	[7:0]	IP		= rCAUSE[15:8]	;	// Interrupt Pending

	reg				wStall			;
		
	wire			wExceptionDetect;	// Exception Detection
	reg				rExceptionSave	;	// Store the Exception signal while pipeline stall
	
	wire			wException		;	// Exception occured signal

	wire			wRepeat			;	// Repeat or continue type of exception
	
	wire			ptrSTATUS		;

	reg[`dw-1:0]	rPC_vec = `ZERO;
	
	
/* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */

	assign	wRepeat = `LOW;

	// Set "Exception sign" active until all Stalls are completed.
	always@(rst_i, stall_i, wException)
		if (rst_i || !stall_i)
			wStall = `LOW;
		else if (stall_i && wException )
			wStall = `HIGH;

	assign {KUo, IEo, KUp, IEp, KUc, IEc} = rSTATUS[5:0];

	// Exception if Interrupt pending AND Not Masked AND Current Interrupt Enable

	assign wExceptionDetect = ((rCAUSE[`IP] & rSTATUS[`IM]) || OVF_i || SYS_i || SI_i) && IEc;
	always@(`CLOCK_EDGE clk_i, `RESET_EDGE rst_i)
		if (rst_i)
			rExceptionSave = `CLEAR;
		else if (wStall)
			rExceptionSave = rExceptionSave;
		else
			rExceptionSave = wExceptionDetect;
	assign wException = wExceptionDetect;
				
	// Used for "Stall the pipeline"
	assign Exception_o = wException || rExceptionSave;
	
	/* ************************* */
	/* STATUS Register statement */
	/* ************************* */
	assign ptrSTATUS = (addr_rw_i == `STATUS_adr);

	always@(`CLOCK_EDGE clk_i, `RESET_EDGE rst_i)
	begin
		if (rst_i) begin
			rSTATUS = `ZERO;
			rSTATUS[`BEV] = `SET;
		end
		else if (wStall)
			rSTATUS = rSTATUS;
		else if (ptrSTATUS && rw_i)
			rSTATUS = data_i;
		else if (wException)
			rSTATUS[5:0] = {rSTATUS[3:0],2'b0};
		else if (rfe_i)
			rSTATUS[3:0] = rSTATUS[5:2];
	end
	
	/* ************************ */
	/* CAUSE Register statement */
	/* ************************ */
//	always@(`CLOCK_EDGE clk_i, `RESET_EDGE rst_i)
	always@(rst_i, wStall, wException, INT_i, SI_i)// Asynchrone
	begin
		if (rst_i) begin
			rCAUSE = `ZERO;
		end
		else if (wStall)
			rCAUSE = rCAUSE;
		else if (wException)
		begin
				if (SYS_i) begin
					rCAUSE[`ExcCode]	=	`SYS_MNE;
				end else if (OVF_i) begin
					rCAUSE[`ExcCode]	=	`OVF_MNE;
				end else if (INT_i || SI_i) begin
					rCAUSE[`ExcCode]	=	`INT_MNE;
				end
				
				rCAUSE[`BD]	= brch_i;	// Branch Delay
		end
		else
			rCAUSE[`IP] = {INT_i, SI_i};
	end

	/* ************************ */
	/* Vector statement: Gated */
	/* ************************ */
	always@(wException)
	begin
		if (wException) begin
				if (SYS_i) begin
					if (BEV)
						rPC_vec		=	`GRL_VECTOR_BEV;
					else
						rPC_vec		=	`GRL_VECTOR;
				end else if (OVF_i) begin
					if (BEV)
						rPC_vec		=	`GRL_VECTOR_BEV;
					else
						rPC_vec		=	`GRL_VECTOR;
				end else if (INT_i || SI_i) begin
					if (BEV)
						rPC_vec		=	`INT_VECTOR_BEV;
					else
						rPC_vec		=	`INT_VECTOR;
				end
		end
	end		
	/* ********************** */
	/* EPC Register statement */
	/* ********************** */
	always@(`CLOCK_EDGE clk_i, `RESET_EDGE rst_i)
	begin
		if (rst_i)
			rEPC = `ZERO;
		else if (wStall)
			rEPC = rEPC;
		else if (wException)
			if (wRepeat)
				rEPC = EPC_rpt_i;	// Repeat
			else
				rEPC = EPC_ctn_i;	// Continue
	end
	
	// Ouput
	assign 	data_o = 
				(addr_rd_i == `STATUS_adr)	? rSTATUS:
				(addr_rd_i == `CAUSE_adr)	? rCAUSE:
				(addr_rd_i == `EPC_adr)		? rEPC:
											  `ZERO;	
	assign PC_vec_o = rPC_vec;
	
	
`endif	//EXCEPTION
endmodule