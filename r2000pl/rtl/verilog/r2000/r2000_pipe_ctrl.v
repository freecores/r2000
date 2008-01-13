//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_pipe_ctrl.v		                                  	  ////
////                                                              ////
//// This file is part of the r2000pl Pipelined				  	  ////
////	opencores effort.										  ////
////	Simple Pipelined Mips 32 bits processor				  	  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// pipeline controller							              ////
////                                                              ////
//// To Do:                                                       ////
//// 				                                              ////
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
module r2000_pipe_ctrl
	(
		/* Input */
		d_cache_hit_i	,
		i_cache_hit_i	,
		
		Exception_i		,
		
		id_rs_i			,
		id_rt_i			,
		ex_rt_i			,	ex_mem_read_i	,
		
		ex_multdiv_rdy_i,
		id_ctl_exe_op_i,
				
		/* Output */
		IF_stall		,	IFID_stall		,	IDEX_stall	,	EXMEM_stall	,	MEMWB_stall	,
		EX_freeze		,	MEM_freeze		,	WB_freeze	,
		IFID_flush		,	IDEX_flush		,	EXMEM_flush	,	MEMWB_flush
	);
/* --------------------------------------------------------------
	parameters
   ------------------- */
	parameter	WIDHTH=`iw;

/* --------------------------------------------------------------
	in, out declaration
   ------------------- */
	input				d_cache_hit_i	,
						i_cache_hit_i	,
						Exception_i		;
	
	input [WIDHTH-1:0]	id_rs_i			,
						id_rt_i			,
						ex_rt_i			;
						
	input				ex_mem_read_i	;	
						
	input				ex_multdiv_rdy_i	;
	input [2:0]			id_ctl_exe_op_i		;

	output
		IF_stall		,	IFID_stall		,	IDEX_stall	,	EXMEM_stall	,	MEMWB_stall	,
		EX_freeze		,	MEM_freeze		,	WB_freeze	,
		IFID_flush		,	IDEX_flush		,	EXMEM_flush	,	MEMWB_flush
		;
													
/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
	wire				Event_MultDivInterlock	,
						Event_RawHazard			,
						Event_ICacheMiss		,
						Event_DCacheMiss		,
						Event_Exception			,
						
						wInterlock				;
												
	reg
		IF_stall		,	IFID_stall		,	IDEX_stall	,	EXMEM_stall	,	MEMWB_stall	,
		EX_freeze		,	MEM_freeze		,	WB_freeze	,
		IFID_flush		,	IDEX_flush		,	EXMEM_flush	,	MEMWB_flush
		;
/* --------------------------------------------------------------
	instances, statements
   ------------------- */

   
	// ---------------------------------------------- //
	// When (RAW hazard) or (mult/div interlock) or (I-cache miss)	then	=>	: stall[PC, IF/ID], flush[ID/EX]
	// When (D-cache miss)											then	=>	: stall[PC, IF/ID, ID/EX, EX/MEM, MEM/WB], freeze[EX, MEM, WB]
	// When (eXception)												then	=>	: 
	// ---------------------------------------------- //
	// STALL : stop do not update the pipe
	// FLUSH : clear the pipe
	// FREEZE : don't enable write to the unit
	// ---------------------------------------------- //
	
	// ---------------------------------------------- //
	/* EVENTS */
	// ---------------------------------------------- //
	// MultDiv interlock :
	//	Occur when mfhi, mflo read hi, lo registers while Mult/Div operation is not ready.
	assign	Event_MultDivInterlock = (!ex_multdiv_rdy_i && ((id_ctl_exe_op_i == `hi_ptr)||(id_ctl_exe_op_i == `lo_ptr)));
	
	// RAW Hazard :	
	//	The control for the hazard detection unit is this single condition
	assign	Event_RawHazard		=	((ex_mem_read_i == `HIGH) &					// The instruction is a load (read memory)
								(ex_rt_i != `zer0) &							// The Destination Register is not r0
								((ex_rt_i == id_rs_i) | (ex_rt_i == id_rt_i)));	// The destination register field of the load in the EX stage...
																				// ...matches either source of the instruction in ID stage
	// I-Cache Miss :	
	assign	Event_ICacheMiss	= ~i_cache_hit_i;
	// D-Cache Miss :	
	assign	Event_DCacheMiss	= ~d_cache_hit_i;

	// eXception :	
	assign	Event_Exception		= Exception_i;
	
	// ---------------------------------------------- //
	/* ACTIONS */
	// ---------------------------------------------- //
	// GENERAL InterLock:
	//	Either from the MultDiv Unit, RAW  or from the I-cache miss 

	always@(Event_Exception, Event_DCacheMiss, Event_ICacheMiss, Event_MultDivInterlock, Event_RawHazard)begin
	
			{IF_stall,	IFID_stall	,	IDEX_stall	, EXMEM_stall	, MEMWB_stall}	= {`LOW,`LOW,`LOW,`LOW,`LOW};
			{							EX_freeze	, MEM_freeze	, WB_freeze}	= {     `HIGH,`HIGH,`HIGH};
			{			IFID_flush	,	IDEX_flush	, EXMEM_flush	, MEMWB_flush}	= {`LOW,`LOW,`LOW,`LOW};
		
`ifdef	CP0
		if (Event_Exception) begin
			{			IFID_flush	,	IDEX_flush	, EXMEM_flush	, MEMWB_flush}	= {`HIGH,`HIGH,`HIGH,`HIGH};
		end else
`endif	//CP0
		if(Event_DCacheMiss) begin
			{IF_stall,	IFID_stall	,	IDEX_stall	, EXMEM_stall	, MEMWB_stall}	= {`HIGH,`HIGH,`HIGH,`HIGH,`HIGH};
			{							EX_freeze	, MEM_freeze	, WB_freeze}	= {     `LOW,`LOW,`LOW};
			
		end else if(Event_ICacheMiss || Event_MultDivInterlock || Event_RawHazard) begin
			{IF_stall,	IFID_stall}				= {`HIGH,`HIGH};
									IDEX_flush	= {     		`HIGH};

		end		
	end
	/*
	assign	wInterlock =	Event_MultDivInterlock | Event_RawHazard | Event_ICacheMiss;

	assign IF_stall		= 	IFID_stall;
	
	assign {IFID_stall	,	IDEX_stall	, EXMEM_stall	, MEMWB_stall}	= {{wInterlock | Event_DCacheMiss}, Event_DCacheMiss, Event_DCacheMiss, Event_DCacheMiss};
	assign {				EX_freeze	, MEM_freeze	, WB_freeze}	= {~Event_DCacheMiss, ~Event_DCacheMiss, ~Event_DCacheMiss};
	
`ifdef	CP0
	assign {IFID_flush	,	IDEX_flush	, EXMEM_flush	, MEMWB_flush}	= {Event_Exception, {wInterlock | Event_Exception}, Event_Exception, Event_Exception};
`else	//CP0
	assign {IFID_flush	,	IDEX_flush	, EXMEM_flush	, MEMWB_flush}	= {`CLEAR, wInterlock, `CLEAR, `CLEAR};
`endif	//CP0
	*/

		
	/*
   // priority of stall over flush
		if (rst_i == `RESET_ON)
			rQ = 0;		// reset synchronously
		else if(stall_i == `HIGH)
			rQ = rQ;	// don't update
		else if(flush_i == `HIGH)//(suppress glith from the combinatorial calculeted flush signal)
			rQ = 0;		// clear
		else
			rQ = D_i;	// else update
	*/
	
endmodule