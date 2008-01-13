//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_pc.v The program Counter                               ////
////                                                              ////
//// This file is part of the r2000sc SingleCycle				  ////
////	opencores effort.										  ////
////	Simple Single-cycle Mips 32 bits processor				  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// The programm counter unit.                                   ////
////	- can branch, jump, continue the execution of the program ////
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
module r2000_pc
	(
		Pc_o				,	// Programm Memory Address
		Instruction_i		,	// Programm Memory Instruction
		
		Interlock_i			,	// Interlock Signal from the Mult/Div module
		BranchRegister_i	,	// Register value for branch
		BranchSel_i			,	// Branch selection
		
		PcPlus4_o			,	// Pc + 4 
		
		clk_i				,	// 
		rst_i					// 
	);
/* --------------------------------------------------------------
	in, out declaration
   ------------------- */
	output [`aw-1:0]		Pc_o			;
	input  [`dw-1:0]		Instruction_i	;
		
	input [`aw-1:0]			BranchRegister_i;
	input					Interlock_i;
	input [1:0]				BranchSel_i	;
	output [`aw-1:0]		PcPlus4_o		;

	input					clk_i			;
	input					rst_i			;
	
/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
	// programm counter
	reg [`aw-1:0]		pc_reg			;
`ifdef DELAY_SLOT                   	
	reg [`aw-1:0]		pc_delay_reg	;
`endif                              	
	wire [`aw-1:0]		wPcPlus4		;
	wire [`aw-1:0]		mux_pc_out		;
	
	// decode unit
	wire [15:0] 		wAdresse16		;
	wire [25:0] 		wAdresse26		;

	// branch function
	wire [`aw-1:0]		wTargetBranch	;
	wire [`aw-1:0]		wTargetJump		;
	wire [1:0]			BranchSel_i		;
	

	
/* --------------------------------------------------------------
	instances, statements
   ------------------- */
   
	/* ********************************************************************* */
	/* PC instance */
	/* *********** */
	assign wAdresse16		= Instruction_i[15:0];							// -- Immediat 16 bits
	assign wAdresse26		= Instruction_i[25:0];							// -- Immediat 26 bits
	
	assign wTargetBranch	= { {14{wAdresse16[15]}}, wAdresse16, 2'b0 };	// -- Branch value
	assign wTargetJump		= { wPcPlus4[31:28]		, wAdresse26, 2'b0 };	// -- Jump value
	
	assign wPcPlus4			= pc_reg + `dw'd4;
	
	/* *********************** */
	/* THE NEW PC VALUE CHOICE */
	/* *********************** */
	r2000_mux4 #(`aw) mux_pc
	(	/* Input */
		.in0_i		(wPcPlus4)					,	// 		from the pc + 4...
		.in1_i		(BranchRegister_i)			,	// or	from rs indexed register file... 
`ifdef DELAY_SLOT
		.in2_i		(pc_reg + wTargetBranch)	,	// or	from the branch value...
`else
		.in2_i		(wPcPlus4 + wTargetBranch)	,	// or	from the branch value...
`endif
		.in3_i		(wTargetJump)				,	// or	from the jump value 
		.sel_i		(BranchSel_i)				,	// 
		/* Output */
		.out_o		(mux_pc_out)				// the new pc value choice
	);
	
	/* *********** */
	/* THE PC UNIT */
	/* *********** */
	always@(`CLOCK_EDGE clk_i, `RESET_EDGE rst_i)
	begin
		if (rst_i == `RESET_ON)begin			// reset: clear the pc
			pc_reg			<= `ZERO;
`ifdef DELAY_SLOT
			pc_delay_reg	<= `ZERO;
`endif
		end	else if (Interlock_i)	begin		// interlock: stop the pc
			pc_reg			<= pc_reg;
			pc_delay_reg 	<= pc_delay_reg;
		end else begin							// else: get the value from the mux_pc
`ifdef DELAY_SLOT
			pc_reg			<= mux_pc_out;
			pc_delay_reg 	<= pc_reg;
`else
			pc_reg			<= mux_pc_out;
`endif
		end
	end
	
`ifdef DELAY_SLOT
	assign	Pc_o = pc_delay_reg;
`else
	assign	Pc_o = pc_reg;
`endif
	assign	PcPlus4_o = wPcPlus4;
   
endmodule
