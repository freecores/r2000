//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_cpu.v				                                  ////
////                                                              ////
//// This file is part of the r2000sc SingleCycle				  ////
////	opencores effort.										  ////
////	Simple Single-cycle Mips 32 bits processor				  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// The top level module of the r2000sc cpu.                     ////
////	- SINGLE CYCLE mips-I ISA compatible processor			  ////
////	- harvard architecture                                    ////
//// 	- unaligned instruction are not implemented               ////
////	- the CP0 is not implemented                              ////
////	- the delay slot is implemented                           ////
////	- tested ok for C langage programms:                      ////
////		- 800 digits of pi                                    ////
////		- reed-solomon algorithm                              ////
////                                                              ////
////                                                              ////
//// To Do:                                                       ////
////	- implement the CP0                                       ////
////	- execut the dhrystone test                               ////
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
module r2000_cpu
	(
		mem_code_addr_o	,	// Programm Memory Address
		mem_code_inst_i	,	// Programm Memory Instruction
		
		mem_data_addr_o	,	// Data Memory Address
		mem_data_data_io,	// Data Memory in/out of the processor
		mem_data_wr_o	,	// Data Memory Write
		mem_data_rd_o	,	// Data Memory Read
		mem_data_blel_o	,	// Byte Memory Low enable
		mem_data_bhel_o	,	// Byte Memory High Enable
		mem_data_bleh_o	,	// Byte Memory Low enable
		mem_data_bheh_o	,	// Byte Memory High Enable
		
		clk_i			,	// Clock
		rst_i				// Reset
	);
/* --------------------------------------------------------------
	in, out declaration
   ------------------- */
	output [`dw-1:0]		mem_code_addr_o	;
	input  [`dw-1:0]		mem_code_inst_i	;
		
	output [`dw-1:0]		mem_data_addr_o	;
	inout  [`dw-1:0]		mem_data_data_io;
	output 					mem_data_wr_o	;
	output 					mem_data_rd_o	;
	output					mem_data_bhel_o	;
	output					mem_data_blel_o	;
	output					mem_data_bheh_o	;
	output					mem_data_bleh_o	;
		
	input					clk_i			;
	input					rst_i			;
	
/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
	// programm counter
	reg [`dw-1:0]		pc_reg			;
`ifdef DELAY_SLOT                   	
	reg [`dw-1:0]		pc_delay_reg	;
`endif                              	
	wire [`dw-1:0]		pc_plus_4		;
	wire [`dw-1:0]		mux_pc_out		;
	
	// decode unit
//	wire [5:0]			inst_opcode 	;
	wire [4:0]			rs_index		,
						rt_index		,
						rd_index		;
	wire [4:0]			shamt			;
	wire [5:0]			funct			;
//	wire [15:0] 		inst_addr	 	;
                                        
	wire [15:0] 		inst_im			;
	wire [`dw-1:0] 		inst_imup		;
	wire [`dw-1:0]		inst_signextend	;
	wire [`dw-1:0]		inst_zeroextend	;
//	wire [15:0] 		inst_offset		;

	// branch function
	wire [1:0]			ctl_branch_type	;
	wire [3:0]			ctl_branch_cond	;
	wire [3:0]			status			;
	wire [1:0]			mux_branch_sel	;
	
	// alu unit
	wire [1:0]			ctl_alu_src_b	;
	wire [2:0]			ctl_alu_op      ;
	wire [3:0]			alu_cmd			;
	wire [`dw-1:0]		reg_rs			,
						reg_rt			,
						mux_src_b_out	;
	wire [`dw-1:0]		alu_out			;

	// register file unit
	wire [1:0]			ctl_reg_dst		;
	wire 				ctl_reg_rt		,
						ctl_reg_write	;
	wire [2:0]			ctl_mem_to_reg	;
	wire [4:0]			mux_rd_index_out,
						mux_rt_index_out;
	wire [`dw-1:0]		mux_reg_w_out	;
	
	// shifter unit
	wire				ctl_shift_var	,
						ctl_shift_lr	,
						ctl_shift_la	;
	wire [`dw-1:0]		shifter_out		;
	wire [4:0]			shifter_amount	;

	// multiplication/division unit						
	wire				ctl_multdiv_sign,
						ctl_multdiv_op	,
						ctl_multdiv_start,
						ctl_multdiv_hiw	,	
						ctl_multdiv_ow	;
	wire				multdiv_ready	;
	wire				multdiv_interlock;
	wire [`dw-1:0]		hi				,
						lo				;	

	// Memory bus interface	
	wire [1:0]			ctl_mem_tail	;
	wire				ctl_mem_write	,
						ctl_mem_read	,
						ctl_mem_sign	,	
						ctl_mem_oe		;
	
	wire [`dw-1:0]		MemDataInterDin	,
						MemDataInterDout,
						MemDataAddrInt	;
	
	wire				MemDataBlew1	,
						MemDataBler1	,
						MemDataBhew1	,
						MemDataBher1	,
						MemDataBlew2	,
						MemDataBler2	,
						MemDataBhew2	,
						MemDataBher2	;
	
	
/* --------------------------------------------------------------
	instances, statements
   ------------------- */
   
	/* ********************************************************************* */
	/* PC instance */
	/* *********** */
	// INTERLOCK: occur when mfhi, mflo read hi, lo registers
	// while Mult/Div operation is not ready.
	assign multdiv_interlock = (!multdiv_ready && ((ctl_mem_to_reg == `hi_ptr)||(ctl_mem_to_reg == `lo_ptr)));

	r2000_pc 		unit_pc
	(
		.Pc_o				(mem_code_addr_o),		// Programm Memory Address
		.Instruction_i		(mem_code_inst_i),		// Programm Memory Instruction
		                    
		.Interlock_i		(multdiv_interlock),	// Interlock from the Mult/Div operation
		.BranchRegister_i	(reg_rs),				// Register Value to branch to
		.BranchSel_i		(mux_branch_sel),		// Branch selection
		 
		.PcPlus4_o			(pc_plus_4),			// pc + 4
		                    
		.clk_i				(clk_i),				// Clock
		.rst_i				(rst_i)					// Reset
	);
	
	
	/* ********************************************************************* */
	/* INSTRUCTION decode */
	/* ****************** */
//	assign inst_opcode 		= mem_code_inst_i[31:26];				// -- Opcode
	assign rs_index			= mem_code_inst_i[25:21];				// -- rs register index
	assign rt_index			= mem_code_inst_i[20:16];				// -- rt register index
	assign rd_index			= mem_code_inst_i[15:11];				// -- rd register index
	assign shamt			= mem_code_inst_i[10:6];				// -- Shift amount
	assign funct			= mem_code_inst_i[5:0];					// -- function (R-format)
//	assign inst_addr	 	= mem_code_inst_i[15:0];				// -- Address (I-format)

	assign inst_im			= mem_code_inst_i[15:0];				// -- Immediat
	assign inst_imup		= {mem_code_inst_i[15:0],{16{1'b0}}};	// -- Immediat Up
	assign inst_signextend	= {{16{inst_im[15]}},	(inst_im)};		// -- Sign extended
	assign inst_zeroextend	= {{16{1'b0}},			(inst_im)};		// -- Zero extended
//	assign inst_offset		= mem_code_inst_i[15:0];
	
	/* THE DECODER UNIT OF THE CPU */
	r2000_decoder      unit_decoder
	(	/* Input */
		.Instruction_i	(mem_code_inst_i)	,	// the instruction
                                                                                
		/* Output */                                                            
		.AluOp_o		(ctl_alu_op)		,	// alu controls                   
		.AluSrcB_o		(ctl_alu_src_b)		,                                   
		                                                                        
		.RegWrite_o		(ctl_reg_write)		,	// register file controls
		.RegDst_o		(ctl_reg_dst)		,                                   
		.RegDrt_o		(ctl_reg_rt)		,                                   
		                                                                        
		.MemToReg_o		(ctl_mem_to_reg)	,	// memory interface bus control   
		.MemRead_o		(ctl_mem_read)		,                                   
		.MemWrite_o		(ctl_mem_write)		,                                   
		.MemLength_o	(ctl_mem_tail)		,                                   
		.MemSign_o		(ctl_mem_sign)		,                                   
		.MemOe_o		(ctl_mem_oe)		,                                   
                                                                                
		.BranchSel_o	(ctl_branch_type)	,	// branch/jump control            
		.ConditionSel_o	(ctl_branch_cond)	,                                   
				                                                                
		.ShiftVar_o		(ctl_shift_var)		,	// shifter control                
        .ShiftLr_o		(ctl_shift_lr)		,                                   
		.ShiftLa_o		(ctl_shift_la)		,                                   
                                                                                
        .MultDivSign_o	(ctl_multdiv_sign)	,	// multiplication/division control
		.MultDivOp_o	(ctl_multdiv_op)	, 
		.MultDivStart_o	(ctl_multdiv_start)	,
		.MultDivHiW_o	(ctl_multdiv_hiw)	,
		.MultDivLoW_o	(ctl_multdiv_ow)
		);

	/* THE rt index SOURCE */
	r2000_mux2 #(5)    mux_rt_index
	(	/* Input */
		.in0_i			(rt_index)			,	// 		from the instruction rt field...
		.in1_i			(`zer0)				,	// or	zero
		.sel_i			(ctl_reg_rt)		,
		/* Output */
		.out_o			(mux_rt_index_out)		//  rt index choice	
	);
	
	/* THE rd index SOURCE */
	r2000_mux3 #(5)    mux_rd_index
	(	/* Input */
		.in0_i			(rd_index)			,	//		from the instruction rd field...
		.in1_i			(rt_index)			,	// or	from the instruction rt field...
		.in2_i			(`ra)				,	// or	from the ra register pointer
		.sel_i			(ctl_reg_dst)		,
		/* Output */
		.out_o			(mux_rd_index_out)		//  rd index choice
	);
	
	/* THE WRITE REGISTER SOURCE */
	r2000_mux7         mux_reg_w
	(	/* Input */
		.in0_i			(alu_out)			,	//		from the alu result...
		.in1_i			(MemDataInterDin)	,	//	or	from the memory bus interface
		.in2_i			(shifter_out)		,	//	or	from the shifter result
		.in3_i			(pc_plus_4)			,	//	or	from the pc unit
		.in4_i			(hi)				,	//	or	from the hi register
		.in5_i			(lo)				,	//	or	from the lo register
		.in6_i			(inst_imup)			,	//	or	from the immediat up
		.sel_i			(ctl_mem_to_reg)	,
		/* Output */
		.out_o			(mux_reg_w_out)			//	write register choice
	);

	/* REGISTER FILE UNIT */
	r2000_regfile      unit_regfile
	(	
		.clk_i			(clk_i)				,
		.rst_i			(rst_i)				,
		
		/* Read from the register file */
		.RdIndex1_i		(rs_index)			, .Data1_o		(reg_rs)		,
		.RdIndex2_i		(mux_rt_index_out)	, .Data2_o      (reg_rt)		,
		
		/* Write to register file */
		.WrIndex_i		(mux_rd_index_out)	, .Data_i		(mux_reg_w_out)	,
		.Wr_i			(ctl_reg_write)
	);
   
	/* ********************************************************************* */
	/* ARITHMETIC and LOGIC UNIT */
	/* ************************* */
	
	/* ALU CONTROL */
	r2000_aluctrl      unit_alucontrol
	(	/* Input */
		.AluOp_i		(ctl_alu_op)		,
		.FuncCode_i		(funct)				,
		/* Output */
		.AluCtl_o     	(alu_cmd)				// alu command type
	);
	
	/* OPERAND B SOURCE */
	r2000_mux3         mux_alu_operandb
	(	.in0_i			(reg_rt)			,	// 		rt index register file...
		.in1_i			(inst_signextend)	,	// or   sign extended immediat...
		.in2_i			(inst_zeroextend)	,	// or	zero extended immediat...
		.sel_i			(ctl_alu_src_b)		,	// 
		.out_o			(mux_src_b_out)			//		operand b choice
	);
		
	/* THE ALU UNIT */
	r2000_alu          unit_alu
	(	/* Input */
		.AluCtl_i		(alu_cmd)			,	// alu command
		.A_i			(reg_rs)			,	// operand a
		.B_i			(mux_src_b_out)		,	// operand b
		/* Output */
		.AluOut_o		(alu_out)			,	// alu result
		.Status_o		(status)				// status flags
	);
	
	/* THE BRANCH DECODER UNIT */
	r2000_branchdecoder	unit_branchdecoder
	(	/* Input */
		.BranchType_i	(ctl_branch_type)	,	// branch type
		.CondSel_i		(ctl_branch_cond)	,	// branch condition
		.Status_i		(status)			,	// status flags from the alu
		/* Output */
		.BranchSel_o    (mux_branch_sel)		// the branch type of the pc
	);

	/* SHIFTER AMOUNT SOURCE */
	r2000_mux2  #(5)   mux_shift_variable
	(	.in0_i			(shamt)				,	//		from the shamt field of the instruction...
		.in1_i			(reg_rs[4:0])		,	//	or	rs index register file
		.sel_i			(ctl_shift_var)		,
		.out_o			(shifter_amount)     	//		the shift amount choice
	);
	
	/* THE SHIFTER UNIT */
	r2000_shifter      unit_shifter
	(	/* Input */
		.A_i 			(reg_rt)			,	// operand
		.SH_i			(shifter_amount)	,	// Shift amount
		.LR_i			(ctl_shift_lr)		, 	// Left/Right
		.LA_i			(ctl_shift_la)		,	// Logic/Arithmetic
		/* Output */
		.G_o 			(shifter_out)			// shifter result
	);
	
	/* THE MULTIPLICATION/DIVISION UNIT */	  
	r2000_multdiv      unit_multdiv
	(
		/* Input */
		.clk_i			(clk_i)				,
		.rst_i			(rst_i)				,
		.operand1_i		(reg_rs)			,	// first operand
		.operand2_i		(reg_rt)			,	// second operand
		.sign_i			(ctl_multdiv_sign)	,	// un/signed
		.datain_i		(reg_rs)			,	// data input
		.mult_div_i		(ctl_multdiv_op)	,	// type of operation
		.start_i		(ctl_multdiv_start)	,	// start the operation
		.hiw_i			(ctl_multdiv_hiw)	,	// hi write
		.low_i			(ctl_multdiv_ow)	,	// lo write
		/* Output */
		.hi_o			(hi)				,	// hi result
		.lo_o			(lo)				,	// lo result
		.ready_o		(multdiv_ready)			// end of operation
	); 
	
	/* ********************************************************************* */
	/* MEMORY DATA BUS interface */
	/* ************************* */
	r2000_reg2mem      unit_reg_to_mem
	(
		.RegData_i		(reg_rt)			,	// Register Side
		.Length_i		(ctl_mem_tail)		,	// WORD, HALF, BYTE

		.Ad_i			(MemDataAddrInt[1:0]),	// the two least significant bits effective address
		.Oe_i			(ctl_mem_oe)		,	// Memory Write

		.MemData_o		(MemDataInterDout)	,	// Memory Side
		.low1_o			(MemDataBlew1)		,	
		.high1_o		(MemDataBhew1)		,
		.low2_o			(MemDataBlew2)		,
		.high2_o		(MemDataBhew2)	
	);
	r2000_mem2reg      unit_mem_to_reg
	(
		.MemData_i		(mem_data_data_io)	,	// Memory Side (MemDataDin),		// Memory Side
		.Length_i		(ctl_mem_tail)		,	// WORD, HALF, BYTE
		.Sign_i			(ctl_mem_sign)		,	// Sign extension type

		.Ad_i			(MemDataAddrInt[1:0]),	// the two least significant bits effective address
		.Rd_i			(ctl_mem_read)		,	// Memory Read

		.RegData_o		(MemDataInterDin)	,	// Register Side
		.low1_o			(MemDataBler1)		,	
		.high1_o		(MemDataBher1)		,
		.low2_o			(MemDataBler2)		,
		.high2_o		(MemDataBher2)	
	);
	
	
	/* ********************************************************************* */
	/* OUTPUTS SIGNALS FROM CPU */
	/* ************************ */
	
	assign mem_data_wr_o	= (!ctl_mem_write)? clk_i :`HIGH;
	assign mem_data_rd_o	= ctl_mem_read;
	assign MemDataAddrInt	= alu_out;
	assign mem_data_addr_o	= MemDataAddrInt;

	assign mem_data_data_io	= (!ctl_mem_write | (rst_i != `RESET_ON)) ? MemDataInterDout:`dw'bz;	// On reset bi-directional ports in input state
	
	assign mem_data_blel_o	= ~(~MemDataBlew1 | ~MemDataBler1);
	assign mem_data_bhel_o	= ~(~MemDataBhew1 | ~MemDataBher1);
	assign mem_data_bleh_o	= ~(~MemDataBlew2 | ~MemDataBler2);
	assign mem_data_bheh_o	= ~(~MemDataBhew2 | ~MemDataBher2);

endmodule
