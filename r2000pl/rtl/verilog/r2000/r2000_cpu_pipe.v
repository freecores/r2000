//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_cpu_pipe.v				                              ////
////                                                              ////
//// This file is part of the r2000pl Pipelined				      ////
////	opencores effort.										  ////
////	Simple Pipelined Mips 32 bits processor				      ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// The top level module of the r2000pl cpu.                     ////
////	- 5 stage pipeline mips-I ISA compatible processor		  ////
////	- harvard architecture                                    ////
////	- I-cache ans D-Cache implemented                         ////
////	- one delay slot is used		                          ////
////	- the CP0 is implemented (without MMU)                 	  ////
//// 	- unaligned instruction are not implemented               ////
////	- tested ok for C langage programms:                      ////
////		- 800 digits of pi                                    ////
////		- reed-solomon algorithm                              ////
////		- dhrystone test Version 2.1                          ////
////                                                              ////
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

//`define BREAK_PT

/* ====================
	module definition
   ==================== */
module r2000_cpu_pipe
	(
		mem_code_addr_o	,	// Programm Memory Address
		mem_code_inst_i	,	// Programm Memory Instruction
		mem_code_hit_i	,	// I-Cache hit signal
		
		mem_data_addr_o	,	// Data Memory Address
		mem_data_data_i	,	// Data Memory in the processor
		mem_data_data_o	,	// Data Memory out of the processor
		mem_data_hit_i	,	// D-Cache hit signal //Data Memory Stop the processor

		mem_data_wr_o	,	// Data Memory Write
		mem_data_rd_o	,	// Data Memory Read
		
		mem_data_en_o	,
`ifdef DCACHE
		mem_data_width_o,	// Byte Memory Width
`else// DCACHE
		mem_data_blel_o	,	// Byte Memory Low enable
		mem_data_bhel_o	,	// Byte Memory High Enable
		mem_data_bleh_o	,	// Byte Memory Low enable
		mem_data_bheh_o	,	// Byte Memory High Enable
`endif// DCACHE
		
`ifdef	CP0
		sig_int_i		,	// Interrupt exception
		sig_si_i		,	// Software Interrupt
`endif	//CP0	

		clk_i			,	// Clock
		rst_i				// Reset
	);
/* --------------------------------------------------------------
	in, out declaration
   ------------------- */
	output [`dw-1:0]		mem_code_addr_o	;
	input  [`dw-1:0]		mem_code_inst_i	;
	input					mem_code_hit_i	;
		
	output [`dw-1:0]		mem_data_addr_o	;
	input  [`dw-1:0]		mem_data_data_i ;
	output [`dw-1:0]		mem_data_data_o ;
	input					mem_data_hit_i	;
	
	output 					mem_data_wr_o	;
	output 					mem_data_rd_o	;
	output 					mem_data_en_o	;
`ifdef DCACHE
	output	[1:0]			mem_data_width_o;
`else// DCACHE
	output					mem_data_bhel_o	;
	output					mem_data_blel_o	;
	output					mem_data_bheh_o	;
	output					mem_data_bleh_o	;
`endif// DCACHE
		
`ifdef	CP0
	input[5:0]				sig_int_i		;
	input[1:0]				sig_si_i		;
`endif	//CP0	

	input					clk_i			;
	input					rst_i			;
	
/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
	// programm counter
	wire [`dw-1:0]		wPC					;
	wire [`dw-1:0]		IF_PCplus4			,	ID_PCplus4		,	ID_PCplus8	,	EX_PCplus8;
	wire [`dw-1:0]		ID_mux_pc_out;  	
	wire [`aw-1:0]		wTargetBranch		;
	wire [`aw-1:0]		wTargetJump			;
	                                    	
	// decode unit                      	
	wire [`dw-1:0]		ID_inst				,	EX_inst
`ifdef DEBUG
											,	MEM_inst		,	WB_inst
`endif//DEBUG
											;
	wire [4:0]			ID_rs_index			,
						ID_rt_index			,	EX_rt_index		,
						ID_rd_index			,	EX_rd_index		,	MEM_rd_index		,	WB_rd_index;
	wire [4:0]			EX_shamt			;
	wire [5:0]			EX_funct			;
                                        	
	wire [15:0] 		ID_im				;
	wire [`dw-1:0] 		ID_imup				,	EX_imup			;
	wire [`dw-1:0]		ID_signextend		,	EX_signextend	;
	wire [`dw-1:0]		ID_zeroextend		,	EX_zeroextend	;

	// branch function
	wire [15:0] 		wAdresse16			;
	wire [25:0] 		wAdresse26			;
	wire [1:0]			ID_ctl_branch_type	;
	wire [3:0]			ID_ctl_branch_cond	;
	wire [3:0]			ID_cmp_status		;
	wire [`SELWIDTH-1:0]ID_mux_branch_sel	
`ifdef	CP0
											,	EX_mux_branch_sel	,	MEM_mux_branch_sel	;
	reg					MEM_branch_Slot			// Detect branch slot when exception
`endif	//CP0	
											;
	
	// alu unit
	wire [1:0]			ID_ctl_alu_src_b	, 	EX_ctl_alu_src_b	;
	wire [2:0]			ID_ctl_alu_op		,	EX_ctl_alu_op		;
	wire [3:0]			EX_alu_cmd			;
	wire [`dw-1:0]		EX_mux_src_b_out	;
	wire [`dw-1:0]		EX_alu_out			,	MEM_alu_out			;
	wire [3:0]			EX_AluStatus		;	// Alu Status
	wire				ID_ctl_alu_status	,	EX_ctl_alu_status	;
	
	// forward
	wire [1:0]			rs_sel				,
						rt_sel				;
	wire [`dw-1:0]		ID_reg_rs_forward	,
						ID_reg_rt_forward	;
	// hazard
	wire				wInterlock			,
						wRaw_Hazard			;

	// register file unit
	wire [`dw-1:0]		ID_reg_rs			,	EX_reg_rs			,		
						ID_reg_rt			,	EX_reg_rt			, MEM_reg_rt			;
	wire [1:0]			ID_ctl_reg_dst		;
	wire 				ID_ctl_reg_rt		,
						ID_ctl_reg_write	, 	EX_ctl_reg_write	,	MEM_ctl_reg_write	,	WB_ctl_reg_write;
	wire [2:0]			ID_ctl_execution_op	,	EX_ctl_execution_op	;
	wire [4:0]			ID_mux_rd_index_out	,	
						ID_mux_rt_index_out	;
	wire [`dw-1:0]		EX_result_operation	,	MEM_result_operation,
						MEM_RegDatain		,	WB_RegDatain		;
	wire				ID_clt_reg_src		,	EX_clt_reg_src		,	MEM_clt_reg_src		;
	
	// shifter unit
	wire				ID_ctl_shift_var	,	EX_ctl_shift_var, 
						ID_ctl_shift_lr		,	EX_ctl_shift_lr	,
						ID_ctl_shift_la		,	EX_ctl_shift_la	;
	wire [`dw-1:0]		EX_shifter_out		;
	wire [4:0]			EX_shifter_amount	;

	// multiplication/division unit						
	wire				ID_ctl_multdiv_sign	,	EX_ctl_multdiv_sign	, 
						ID_ctl_multdiv_op	,	EX_ctl_multdiv_op	,  
						ID_ctl_multdiv_start,	EX_ctl_multdiv_start,
						ID_ctl_multdiv_hiw	,	EX_ctl_multdiv_hiw	, 	
						ID_ctl_multdiv_low	,	EX_ctl_multdiv_low	; 
	wire				EX_multdiv_ready	;
	wire				wMultDiv_Interlock	;
	wire [`dw-1:0]		EX_hi				,
						EX_lo				;
	
	// Memory bus interface	
	wire [1:0]			ID_ctl_mem_tail		,	EX_ctl_mem_tail	,	MEM_ctl_mem_tail	;  
	wire				ID_ctl_mem_write	,	EX_ctl_mem_write,	MEM_ctl_mem_write	,
						ID_ctl_mem_read		,	EX_ctl_mem_read	,	MEM_ctl_mem_read	,  
						ID_ctl_mem_sign		,	EX_ctl_mem_sign	,	MEM_ctl_mem_sign	,  	
						ID_ctl_mem_oe		,	EX_ctl_mem_oe	,	MEM_ctl_mem_oe		;    
	
	wire [`dw-1:0]		MemDataInterDin		,
						MemDataInterDout	,
						MemDataAddrInt		;
	
	wire				MEM_MemDataBlew1	,
						MEM_MemDataBler1	,
						MEM_MemDataBhew1	,
						MEM_MemDataBher1	,
						MEM_MemDataBlew2	,
						MEM_MemDataBler2	,
						MEM_MemDataBhew2	,
						MEM_MemDataBher2	;
	
	// Pipeline Control
	wire				EX_freeze			,	MEM_freeze		,	WB_freeze			;
	wire				IFID_flush			,	IDEX_flush		,	EXMEM_flush			,	MEMWB_flush	;
	wire				IF_stall			;
	wire				IFID_stall			,	IDEX_stall		,	EXMEM_stall			,	MEMWB_stall	;

	// co-processor 0
	wire				ID_sig_clt_sys		,	EX_sig_clt_sys	,	MEM_sig_clt_sys		;
	wire				ID_sig_clt_brk		,	EX_sig_clt_brk	,	MEM_sig_clt_brk		;
	wire				ID_clt_rfe			,	EX_clt_rfe		,	MEM_clt_rfe			;
	wire				ID_clt_CoMf			;
	wire				ID_clt_CoMt			,	EX_clt_CoMt		,	MEM_clt_CoMt		;
`ifdef	CP0
	wire [`dw-1:0]		IF_EPC				,	ID_EPC			,	EX_EPC				,	MEM_EPC		;
	reg	 [4:0]			IF_EXC				,	ID_EXC			,	EX_EXC				,	MEM_EXC		;
	wire [`dw-1:0]		wEPC_Vector			;
	
	wire 				EX_ovf				,
						EX_Carry			,
						EX_Zero				,
						EX_Neg				;
	wire 				EX_sig_ovf			,	MEM_sig_ovf		;
	wire [5:0]			MEM_sig_int			;
	wire [1:0]			MEM_sig_si			;
	
	wire				wException			;
	wire [`dw-1:0]		MEM_cp0_dout		;
`endif	//CP0	
	
/* --------------------------------------------------------------
	instances, statements
   ------------------- */
   
	/* ********************* */
	/* PIPELINE CONTROL UNIT */
	/* ********************* */
	// ---------------------------------------------- //
	// When (RAW hazard) or (mult/div interlock) or (I-cache miss)	then	=>	: stall[PC, IF/ID], flush[ID/EX]
	// When (D-cache miss)											then	=>	: stall[PC, IF/ID, ID/EX, EX/MEM, MEM/WB], freeze[EX, MEM, WB]
	// When (eXception)												then	=>	: 
	// ---------------------------------------------- //
	// STALL : stop do not update the pipe
	// FLUSH : clear the pipe
	// FREEZE : don't enable write to the unit
	// ---------------------------------------------- //
	
	r2000_pipe_ctrl	unit_pipe_ctrl
	(
		/* Input */
		.d_cache_hit_i		(mem_data_hit_i),
		.i_cache_hit_i		(mem_code_hit_i),
		
		.Exception_i		(wException)	,
		                    
		.id_rs_i			(ID_rs_index)	,
		.id_rt_i			(ID_rt_index)	,
		.ex_rt_i			(EX_rt_index)	,	.ex_mem_read_i	(EX_ctl_mem_read),
		
		.ex_multdiv_rdy_i	(EX_multdiv_ready)		,
		.id_ctl_exe_op_i	(ID_ctl_execution_op)	,
				
		/* Output */
		.IF_stall		(IF_stall)	,	.IFID_stall		(IFID_stall),	.IDEX_stall	(IDEX_stall),	.EXMEM_stall	(EXMEM_stall),	.MEMWB_stall	(MEMWB_stall),
		.EX_freeze		(EX_freeze)	,	.MEM_freeze		(MEM_freeze),	.WB_freeze	(WB_freeze)	,                 
		.IFID_flush		(IFID_flush),	.IDEX_flush		(IDEX_flush),	.EXMEM_flush(EXMEM_flush),	.MEMWB_flush    (MEMWB_flush)
	);
	
	/*======================================================================================================================================================*/
	/*	IF:Instruction Fetch STAGE						*/
	/*======================================================================================================================================================*/

	/* *********** */
	/* THE PC UNIT */
	/* *********** */
	r2000_pc	unit_pc
	(
		/* Input */
		.clk_i			(clk_i)			,
		.rst_i			(rst_i)			,

		.mux_pc_i		(ID_mux_pc_out)	,
		.stall_i		(IF_stall)		,
		
		/* Output */
		.PC_o			(wPC)			,	
		.PC4_o			(IF_PCplus4)	
	);

`ifdef 	BREAK_PT
	always@(`CLOCK_EDGE clk_i)
		if (wPC == 'h9d0)
			$stop;
`endif	//BREAK_PT
	
	// Code Memory address
	assign mem_code_addr_o = wPC;
	
	/* ************** */
	/* IF/ID PIPELINE */
	/* ************** */
	/* CONTROL */
	/* DATAPATH */
	r2000_pipe #(`dw) IFID_pc_pipe		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IFID_stall) , .flush_i(IFID_flush) , .D_i(IF_PCplus4)			,	.Q_o(ID_PCplus4) );
	r2000_pipe #(`dw) IFID_inst_pipe	(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IFID_stall) , .flush_i(IFID_flush) , .D_i(mem_code_inst_i)	,	.Q_o(ID_inst) );

`ifdef	CP0
	assign	IF_EPC = wPC;
	r2000_pipe #(`dw) IFID_epc_pipe		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IFID_stall) , .flush_i(IFID_flush) , .D_i(IF_EPC)				,	.Q_o(ID_EPC) );
`endif	//CP0

	/*======================================================================================================================================================*/
	/*	ID:Instruction Decode STAGE						*/
	/*======================================================================================================================================================*/
	/* ****************** */
	/* INSTRUCTION decode */
	/* ****************** */
	assign ID_rs_index			= ID_inst[25:21];					// -- rs register index
	assign ID_rt_index			= ID_inst[20:16];					// -- rt register index
	assign ID_rd_index			= ID_inst[15:11];					// -- rd register index

	assign ID_im				= ID_inst[15:0];					// -- Immediat
	assign ID_imup				= {			 ID_im,	 {16{1'b0}}};	// -- Immediat Up
	assign ID_signextend		= {{16{ID_im[15]}},		ID_im};		// -- Sign extended
	assign ID_zeroextend		= {		{16{1'b0}},		ID_im};		// -- Zero extended
	
	/* THE DECODER UNIT OF THE CPU */
	r2000_decoder      unit_decoder
	(	/* Input */
		.Instruction_i	(ID_inst)				,	// the instruction
                                                                                
		/* Output */
		/* INSTRUCTION DECODE STAGE */                                                            
		.RegDrt_o		(ID_ctl_reg_rt)			,                                   
                                                                                
		.BranchSel_o	(ID_ctl_branch_type)	,	// branch/jump control            
		.ConditionSel_o	(ID_ctl_branch_cond)	,                                   
				                                                                
		/* EXECUTION STAGE */                                                            
		.AluOp_o		(ID_ctl_alu_op)			,	// alu controls                   
		.AluSrcB_o		(ID_ctl_alu_src_b)		,                                   
		.AluStatus_o	(ID_ctl_alu_status)		,
		                                                                        
		.ShiftVar_o		(ID_ctl_shift_var)		,	// shifter control                
        .ShiftLr_o		(ID_ctl_shift_lr)		,                                   
		.ShiftLa_o		(ID_ctl_shift_la)		,                                   
                                                                                
        .MultDivSign_o	(ID_ctl_multdiv_sign)	,	// multiplication/division control
		.MultDivOp_o	(ID_ctl_multdiv_op)		, 
		.MultDivStart_o	(ID_ctl_multdiv_start)	,
		.MultDivHiW_o	(ID_ctl_multdiv_hiw)	,
		.MultDivLoW_o	(ID_ctl_multdiv_low)	,
		                                                                        
		.ExOp_o			(ID_ctl_execution_op)	,	// choice the operation result
		
		/* MEMORY STAGE */                                                            
		.MemRead_o		(ID_ctl_mem_read)		,	// memory interface bus control                                   
		.MemWrite_o		(ID_ctl_mem_write)		,                                   
		.MemOe_o		(ID_ctl_mem_oe)			,
		.MemLength_o	(ID_ctl_mem_tail)		,                                   
		.MemSign_o		(ID_ctl_mem_sign)		,                                   
		
		/* WRITE BACK STAGE */                                                            
		.RegWrite_o		(ID_ctl_reg_write)		,	// register file controls
		.RegDst_o		(ID_ctl_reg_dst)		,
		.RegSrc_o		(ID_clt_reg_src)		,
		
		/* CO-PROCESSOR 0 */
		.CoSys_o		(ID_sig_clt_sys)		,	// syscall instruction cp0
		.CoBreak_o		(ID_sig_clt_brk)		,	// break instruction cp0
		.CoRfe_o		(ID_clt_rfe)			,	// rfe cp0
		.CoMf_o			(ID_clt_CoMf)			,	// CP0 Move From
		.CoMt_o			(ID_clt_CoMt)				// CP0 Move To
		
	);
	
	/* FORWARD UNIT */	
	r2000_forward		unit_forward
	(
		/* input */
		.id_rs_i	(ID_rs_index)	,
		.id_rt_i	(ID_rt_index)	,
		
		.ex_rd_i	(EX_rd_index)	,	.ex_reg_write_i		(EX_ctl_reg_write),
		.mem_rd_i	(MEM_rd_index)	,	.mem_reg_write_i	(MEM_ctl_reg_write),
		.wb_rd_i 	(WB_rd_index)	,	.wb_reg_write_i 	(WB_ctl_reg_write),
		
		/* Output */
		.sel_a_o 	(rs_sel)		,
		.sel_b_o 	(rt_sel)
	);
	
	/* FORWARD MUX */	
	assign ID_reg_rs_forward =	(rs_sel == 1) ? 	EX_result_operation		:
								(rs_sel == 2) ?		MEM_RegDatain			:
								(rs_sel == 3) ? 	WB_RegDatain			:
`ifdef	CP0
													(ID_clt_CoMt || ID_clt_CoMf)	?	`ZERO	: //Suppress the influence of rs field wich is MT=00100
`endif	//CP0
													ID_reg_rs				;
													
	assign ID_reg_rt_forward =	(rt_sel == 1) ? 	EX_result_operation		:
								(rt_sel == 2) ? 	MEM_RegDatain			:
								(rt_sel == 3) ? 	WB_RegDatain			:
`ifdef	CP0
													(ID_clt_CoMf)	?	MEM_cp0_dout	: 
`endif	//CP0
													ID_reg_rt				;

	/* *********************** */
	/* THE NEW PC VALUE CHOICE */
	/* *********************** */
	assign wAdresse16		= ID_inst[15:0];								// -- Immediat 16 bits
	assign wAdresse26		= ID_inst[25:0];								// -- Immediat 26 bits
	
	assign wTargetBranch	= { {14{wAdresse16[15]}}, wAdresse16, 2'b0 };	// -- Branch value
	assign wTargetJump		= { ID_PCplus4[31:28]	, wAdresse26, 2'b0 };	// -- Jump value
	
`ifdef	CP0
	r2000_mux5 #(`aw) mux_pc
	(	/* Input */
		.in0_i		(IF_PCplus4),					// 		from the pc + 4...
		.in1_i		(ID_reg_rs_forward)			,	// or	from rs indexed register file... 
		.in2_i		(ID_PCplus4 + wTargetBranch),	// or	from the branch value...
		.in3_i		(wTargetJump)				,	// or	from the jump value 
		.in4_i		(wEPC_Vector)				,	// or	from the CP0 EPC 
		
		.sel_i		(ID_mux_branch_sel)			,	// 
		/* Output */
		.out_o		(ID_mux_pc_out)					// the new pc value choice
	);
`else
	r2000_mux4 #(`aw) mux_pc
	(	/* Input */
		.in0_i		(IF_PCplus4),					// 		from the pc + 4...
		.in1_i		(ID_reg_rs_forward)			,	// or	from rs indexed register file... 
		.in2_i		(ID_PCplus4 + wTargetBranch),	// or	from the branch value...
		.in3_i		(wTargetJump)				,	// or	from the jump value 
		.sel_i		(ID_mux_branch_sel)			,	// 
		/* Output */
		.out_o		(ID_mux_pc_out)					// the new pc value choice
	);
`endif	//CP0

	assign ID_PCplus8 = ID_PCplus4 + 4;			// the pc + 4 was executed in the delay slot so store the pc + 8
	
	/* THE COMPARE UNIT */
	r2000_cmp			unit_comparator
	(
		/* Input */
		.A_i			(ID_reg_rs_forward),	// Operand A
		.B_i			(ID_reg_rt_forward),	// Operand B
		/* Output */
		.Status_o		(ID_cmp_status)			// Status Flags
	);
	/* THE BRANCH DECODER UNIT */
	r2000_branchdecoder	unit_branchdecoder
	(	/* Input */
		.BranchType_i	(ID_ctl_branch_type),	// branch type
		.CondSel_i		(ID_ctl_branch_cond),	// branch condition
		.Status_i		(ID_cmp_status)		,	// status flags from the alu
`ifdef	CP0
		.Exception_i	(wException)		,	// Exception has occured
`endif	//CP0
		/* Output */
		.BranchSel_o    (ID_mux_branch_sel)		// the branch type of the pc
	);

	/* THE rt index SOURCE */
	r2000_mux2 #(`iw)    mux_rt_index
	(	/* Input */
		.in0_i			(ID_rt_index)		,	// 		from the instruction rt field...
		.in1_i			(`zer0)				,	// or	zero
		.sel_i			(ID_ctl_reg_rt)		,
		/* Output */
		.out_o			(ID_mux_rt_index_out)	//  rt index choice	
	);
	
	/* THE rd index SOURCE */
	r2000_mux3 #(`iw)    mux_rd_index
	(	/* Input */
		.in0_i			(ID_rd_index)		,	//		from the instruction rd field...
		.in1_i			(ID_rt_index)		,	// or	from the instruction rt field...
		.in2_i			(`ra)				,	// or	from the ra register pointer
		.sel_i			(ID_ctl_reg_dst)	,
		/* Output */
		.out_o			(ID_mux_rd_index_out)	//  rd index choice
	);
	
	/* REGISTER FILE UNIT */
	r2000_regfile      unit_regfile
	(	
		.en_i			(WB_freeze)				,
		
		.clk_i			(~clk_i)				,	// may put REGISTER FILE ON NEGEDGE CLK
		.rst_i			(rst_i)					,
		
		/* Read from the register file */
		.RdIndex1_i		(ID_rs_index)			, .Data1_o		(ID_reg_rs)		,
		.RdIndex2_i		(ID_mux_rt_index_out)	, .Data2_o      (ID_reg_rt)		,
		
		/* Write to register file */
		.WrIndex_i		(WB_rd_index)			, .Data_i		(WB_RegDatain)	,
		.Wr_i			(WB_ctl_reg_write)
	);
   
	/* ************** */
	/* ID/EX PIPELINE */
	/* ************** */
	/* CONTROL */
	// EX
	r2000_pipe #(  3) IDEX_ctl_alu_op_pipe 			(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_ctl_alu_op)			,	.Q_o(EX_ctl_alu_op) );
	r2000_pipe #(  2) IDEX_ctl_alu_src_b_pipe 		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_ctl_alu_src_b)		,	.Q_o(EX_ctl_alu_src_b) );
	r2000_pipe #(  1) IDEX_ctl_alu_status_pipe 		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_ctl_alu_status)		,	.Q_o(EX_ctl_alu_status) );
	                                            	                                                     	                      	                                           	
	r2000_pipe #(  1) IDEX_ctl_shift_var_pipe 		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_ctl_shift_var)		,	.Q_o(EX_ctl_shift_var) );
	r2000_pipe #(  1) IDEX_ctl_shift_lr_pipe 		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_ctl_shift_lr)			,	.Q_o(EX_ctl_shift_lr) );
	r2000_pipe #(  1) IDEX_ctl_shift_la_pipe 		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_ctl_shift_la)			,	.Q_o(EX_ctl_shift_la) );
	                                                                                                     	                      	                                           	
	r2000_pipe #(  1) IDEX_ctl_multdiv_sign_pipe	(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_ctl_multdiv_sign) 	,	.Q_o(EX_ctl_multdiv_sign) );
	r2000_pipe #(  1) IDEX_ctl_multdiv_op_pipe 		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_ctl_multdiv_op)		,	.Q_o(EX_ctl_multdiv_op) );
	r2000_pipe #(  1) IDEX_ctl_multdiv_start_pipe	(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_ctl_multdiv_start)	,	.Q_o(EX_ctl_multdiv_start) );
	r2000_pipe #(  1) IDEX_ctl_multdiv_hiw_pipe 	(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_ctl_multdiv_hiw)		,	.Q_o(EX_ctl_multdiv_hiw) );
	r2000_pipe #(  1) IDEX_ctl_multdiv_low_pipe 	(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_ctl_multdiv_low)		,	.Q_o(EX_ctl_multdiv_low) );
	                                                                                                     	                      	
	r2000_pipe #(  3) IDEX_ctl_execution_op_pipe	(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_ctl_execution_op)		,	.Q_o(EX_ctl_execution_op) );
                                                                                                                                  	
	// MEM                                                                                                                        	
	r2000_pipe #(  1) IDEX_ctl_mem_read_pipe 		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_ctl_mem_read)			,	.Q_o(EX_ctl_mem_read) );
	r2000_pipe #(  1) IDEX_ctl_mem_write_pipe 		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_ctl_mem_write)		,	.Q_o(EX_ctl_mem_write) );
	r2000_pipe #(  1) IDEX_ctl_mem_oe_pipe 			(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_ctl_mem_oe)			,	.Q_o(EX_ctl_mem_oe) );
	r2000_pipe #(  2) IDEX_ctl_mem_tail_pipe 		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_ctl_mem_tail)			,	.Q_o(EX_ctl_mem_tail) );
	r2000_pipe #(  1) IDEX_ctl_mem_sign_pipe 		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_ctl_mem_sign)			,	.Q_o(EX_ctl_mem_sign) );
	                                                                                                                              	
	// WB                                                                                                                         	
	r2000_pipe #(  1) IDEX_ctl_reg_write_pipe 		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_ctl_reg_write)		,	.Q_o(EX_ctl_reg_write) );
	r2000_pipe #(  1) IDEX_ctl_reg_src_pipe 		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_clt_reg_src)			,	.Q_o(EX_clt_reg_src) );
	
	/* DATAPATH */
	r2000_pipe #(`dw) IDEX_pc_pipe 					(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(`CLEAR)		, .D_i(ID_PCplus8)				,	.Q_o(EX_PCplus8) );
	r2000_pipe #(`dw) IDEX_inst_pipe				(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(IDEX_flush)	, .D_i(ID_inst)					,	.Q_o(EX_inst) );
                                        			                                                                                                        		        	
	r2000_pipe #(`dw) IDEX_rs_pipe 					(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(`CLEAR)		, .D_i(ID_reg_rs_forward) 		,	.Q_o(EX_reg_rs) );
	r2000_pipe #(`dw) IDEX_rt_pipe					(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(`CLEAR)		, .D_i(ID_reg_rt_forward) 		,	.Q_o(EX_reg_rt) );
                                        			                                                                          		                           	
	r2000_pipe #(`dw) IDEX_se_pipe 					(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(`CLEAR)		, .D_i(ID_signextend)			,	.Q_o(EX_signextend) );
	r2000_pipe #(`dw) IDEX_ze_pipe					(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(`CLEAR)		, .D_i(ID_zeroextend)			,	.Q_o(EX_zeroextend) );
	r2000_pipe #(`dw) IDEX_up_pipe 					(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(`CLEAR)		, .D_i(ID_imup)					,	.Q_o(EX_imup) );
	r2000_pipe #(`iw) IDEX_rd_pipe					(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(`CLEAR)		, .D_i(ID_mux_rd_index_out)		,	.Q_o(EX_rd_index) );
	                                                                                                                                                        	
`ifdef	CP0                                                                                                                                                 	
	r2000_pipe #(  1) IDEX_sig_brk_pipe				(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(`CLEAR)		, .flush_i(`CLEAR) 		, .D_i(ID_sig_clt_brk)			,	.Q_o(EX_sig_clt_brk) );
	r2000_pipe #(  1) IDEX_sig_sys_pipe				(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(`CLEAR)		, .flush_i(`CLEAR) 		, .D_i(ID_sig_clt_sys)			,	.Q_o(EX_sig_clt_sys) );
	                                                                                                                                                        	
	r2000_pipe #(  1) IDEX_rfe_pipe					(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(`CLEAR)		, .D_i(ID_clt_rfe)				,	.Q_o(EX_clt_rfe) );
	r2000_pipe #(  1) IDEX_comt_pipe				(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(`CLEAR)		, .D_i(ID_clt_CoMt)				,	.Q_o(EX_clt_CoMt) );
	r2000_pipe #(`dw) IDEX_epc_pipe					(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(`CLEAR)		, .D_i(ID_EPC)					,	.Q_o(EX_EPC) );
	r2000_pipe #(`SELWIDTH) IDEX_brc_pipe			(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(IDEX_stall)	, .flush_i(`CLEAR)		, .D_i(ID_mux_branch_sel)		,	.Q_o(EX_mux_branch_sel) );
`endif	//CP0
	/*======================================================================================================================================================*/
	/*	EX:Execution STAGE								*/
	/*======================================================================================================================================================*/
	/* ************************* */
	/* ARITHMETIC and LOGIC UNIT */
	/* ************************* */
	assign EX_funct		= EX_inst[5:0]		;	// -- function (R-format)
	assign EX_shamt		= EX_inst[10:6]		;	// -- Shift amount
//	assign EX_rs_index	= EX_inst[25:21]	;	// -- rs register index
	assign EX_rt_index	= EX_inst[20:16]	;	// -- rt register index

	/* ALU CONTROL */
	r2000_aluctrl      unit_alucontrol
	(	/* Input */
		.AluOp_i		(EX_ctl_alu_op)		,
		.FuncCode_i		(EX_funct)			,
		/* Output */
		.AluCtl_o     	(EX_alu_cmd)			// alu command type
	);
	
	/* OPERAND B SOURCE */
	r2000_mux3         mux_alu_operandb
	(
		.in0_i			(EX_reg_rt)			,	// 		rt index register file...
		.in1_i			(EX_signextend)		,	// or   sign extended immediat...
		.in2_i			(EX_zeroextend)		,	// or	zero extended immediat...
		.sel_i			(EX_ctl_alu_src_b)	,	// 
		.out_o			(EX_mux_src_b_out)		//		operand b choice
	);
		
	/* THE ALU UNIT */
	r2000_alu          unit_alu
	(	/* Input */
		.AluCtl_i		(EX_alu_cmd)		,	// alu command
		.A_i			(EX_reg_rs)			,	// operand a
		.B_i			(EX_mux_src_b_out)	,	// operand b
		.StateValid_i	(EX_ctl_alu_status)	,	// Valid Status
		/* Output */
		.AluOut_o		(EX_alu_out)		,	// alu result
		.Status_o		(EX_AluStatus)			// status flags
	);
`ifdef	CP0
	assign {EX_Carry, EX_Zero, EX_Neg, EX_ovf} = EX_AluStatus;	// Alu Status
	assign EX_sig_ovf = EX_ovf;
`endif	//CP0	
	
	/* SHIFTER AMOUNT SOURCE */
	r2000_mux2  #(5)   mux_shift_variable
	(	.in0_i			(EX_shamt)			,	//		from the shamt field of the instruction...
		.in1_i			(EX_reg_rs[4:0])	,	//	or	rs index register file
		.sel_i			(EX_ctl_shift_var)	,
		.out_o			(EX_shifter_amount)     //		the shift amount choice
	);
	
	/* THE SHIFTER UNIT */
	r2000_shifter      unit_shifter
	(	/* Input */
		.A_i 			(EX_reg_rt)			,	// operand
		.SH_i			(EX_shifter_amount)	,	// Shift amount
		.LR_i			(EX_ctl_shift_lr)	, 	// Left/Right
		.LA_i			(EX_ctl_shift_la)	,	// Logic/Arithmetic
		/* Output */
		.G_o 			(EX_shifter_out)		// shifter result
	);
	
	/* THE MULTIPLICATION/DIVISION UNIT */	  
	r2000_multdiv      unit_multdiv
	(
		.en_i			(EX_freeze)				,
		
		/* Input */
		.clk_i			(~clk_i)				,
		.rst_i			(rst_i)					,
		.operand1_i		(EX_reg_rs)				,	// first operand
		.operand2_i		(EX_reg_rt)				,	// second operand
		.datain_i		(EX_reg_rs)				,	// data input
		.sign_i			(EX_ctl_multdiv_sign)	,	// un/signed
		.mult_div_i		(EX_ctl_multdiv_op)		,	// type of operation
		.start_i		(EX_ctl_multdiv_start)	,	// start the operation
		.hiw_i			(EX_ctl_multdiv_hiw)	,	// hi write
		.low_i			(EX_ctl_multdiv_low)	,	// lo write
		/* Output */
		.hi_o			(EX_hi)					,	// hi result
		.lo_o			(EX_lo)					,	// lo result
		.ready_o		(EX_multdiv_ready)			// end of operation
	); 
	
	r2000_mux7         mux_reg_w
	(	/* Input */
		.in0_i			(EX_alu_out)			,	//		from the alu result...
		.in1_i			(`ZERO)					,	//	or	from null (not used)
		.in2_i			(EX_shifter_out)		,	//	or	from the shifter result
		.in3_i			(EX_PCplus8)			,	//	or	from the pc unit
		.in4_i			(EX_hi)					,	//	or	from the hi register
		.in5_i			(EX_lo)					,	//	or	from the lo register
		.in6_i			(EX_imup)				,	//	or	from the immediat up
		.sel_i			(EX_ctl_execution_op)	,
		/* Output */
		.out_o			(EX_result_operation)			//	write register choice
	);

	/* *************** */
	/* EX/MEM PIPELINE */
	/* *************** */
	/* CONTROL */
	// MEM
	r2000_pipe #(  1) EXMEM_ctl_mem_read_pipe 	(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(EXMEM_stall)	, .flush_i(EXMEM_flush) , .D_i(EX_ctl_mem_read)		,	.Q_o(MEM_ctl_mem_read) );
	r2000_pipe #(  1) EXMEM_ctl_mem_write_pipe 	(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(EXMEM_stall)	, .flush_i(EXMEM_flush) , .D_i(EX_ctl_mem_write)	,	.Q_o(MEM_ctl_mem_write) );
	r2000_pipe #(  1) EXMEM_ctl_mem_oe_pipe 	(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(EXMEM_stall)	, .flush_i(EXMEM_flush) , .D_i(EX_ctl_mem_oe)		,	.Q_o(MEM_ctl_mem_oe) );
	r2000_pipe #(  2) EXMEM_ctl_mem_tail_pipe 	(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(EXMEM_stall)	, .flush_i(EXMEM_flush) , .D_i(EX_ctl_mem_tail)		,	.Q_o(MEM_ctl_mem_tail) );
	r2000_pipe #(  1) EXMEM_ctl_mem_sign_pipe 	(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(EXMEM_stall)	, .flush_i(EXMEM_flush) , .D_i(EX_ctl_mem_sign)		,	.Q_o(MEM_ctl_mem_sign) );
	// WB                                                                                             	
	r2000_pipe #(  1) EXMEM_ctl_reg_write_pipe 	(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(EXMEM_stall)	, .flush_i(EXMEM_flush) , .D_i(EX_ctl_reg_write)	,	.Q_o(MEM_ctl_reg_write) );
	r2000_pipe #(  1) EXMEM_ctl_reg_src_pipe 	(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(EXMEM_stall)	, .flush_i(EXMEM_flush) , .D_i(EX_clt_reg_src)		,	.Q_o(MEM_clt_reg_src) );
	
	/* DATAPATH */
`ifdef DEBUG
	r2000_pipe #(`dw) EXMEM_inst_pipe			(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(EXMEM_stall)	, .flush_i(EXMEM_flush) , .D_i(EX_inst)				,	.Q_o(MEM_inst) );
`endif//DEBUG                               	
	r2000_pipe #(`dw) EXMEM_result_pipe 		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(EXMEM_stall)	, .flush_i(EXMEM_flush) , .D_i(EX_result_operation)	,	.Q_o(MEM_result_operation) );
	r2000_pipe #(`dw) EXMEM_address_pipe		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(EXMEM_stall)	, .flush_i(EXMEM_flush) , .D_i(EX_alu_out)			,	.Q_o(MEM_alu_out) );
	r2000_pipe #(`iw) EXMEM_rd_pipe				(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(EXMEM_stall)	, .flush_i(EXMEM_flush) , .D_i(EX_rd_index)			,	.Q_o(MEM_rd_index) );
	r2000_pipe #(`dw) EXMEM_rt_pipe				(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(EXMEM_stall)	, .flush_i(EXMEM_flush) , .D_i(EX_reg_rt)			,	.Q_o(MEM_reg_rt) );
	
`ifdef	CP0
	r2000_pipe #(  1) EXMEM_sig_brk_pipe		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(`CLEAR)		, .flush_i(`CLEAR)		, .D_i(EX_sig_clt_brk)		,	.Q_o(MEM_sig_clt_brk) );
	r2000_pipe #(  1) EXMEM_sig_sys_pipe		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(`CLEAR)		, .flush_i(`CLEAR)		, .D_i(EX_sig_clt_sys)		,	.Q_o(MEM_sig_clt_sys) );
	r2000_pipe #(  6) EXMEM_sig_int_pipe		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(`CLEAR)		, .flush_i(`CLEAR)		, .D_i(sig_int_i)			,	.Q_o(MEM_sig_int) );
	r2000_pipe #(  2) EXMEM_sig_si_pipe			(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(`CLEAR)		, .flush_i(`CLEAR)		, .D_i(sig_si_i)			,	.Q_o(MEM_sig_si) );
	r2000_pipe #(  1) EXMEM_sig_ovf_pipe 		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(`CLEAR)		, .flush_i(`CLEAR)		, .D_i(EX_sig_ovf)			,	.Q_o(MEM_sig_ovf) );

	r2000_pipe #(  1) EXMEM_comt_pipe			(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(EXMEM_stall)	, .flush_i(EXMEM_flush) , .D_i(EX_clt_CoMt)			,	.Q_o(MEM_clt_CoMt) );
	r2000_pipe #(  1) EXMEM_rfe_pipe			(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(EXMEM_stall)	, .flush_i(EXMEM_flush) , .D_i(EX_clt_rfe)			,	.Q_o(MEM_clt_rfe) );
	r2000_pipe #(`dw) EXMEM_epc_pipe			(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(EXMEM_stall)	, .flush_i(EXMEM_flush) , .D_i(EX_EPC)				,	.Q_o(MEM_EPC) );
	r2000_pipe #(`SELWIDTH) EXMEM_brc_pipe		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(EXMEM_stall)	, .flush_i(EXMEM_flush) , .D_i(EX_mux_branch_sel)	,	.Q_o(MEM_mux_branch_sel) );
`endif	//CP0	
	/*======================================================================================================================================================*/
	/*	MEM:Memory STAGE								*/
	/*======================================================================================================================================================*/
	/* ************************* */
	/* MEMORY DATA BUS interface */
	/* ************************* */
`ifdef DCACHE
`else// DCACHE
	r2000_reg2mem      unit_reg_to_mem
	(
		.RegData_i		(MEM_reg_rt)			,	// Register Side
		.Length_i		(MEM_ctl_mem_tail)		,	// WORD, HALF, BYTE

		.Ad_i			(MemDataAddrInt[1:0])	,	// the two least significant bits effective address
		.Oe_i			(MEM_ctl_mem_oe)		,	// Memory Write

		.MemData_o		(MemDataInterDout)		,	// Memory Side
		.low1_o			(MEM_MemDataBlew1)		,	
		.high1_o		(MEM_MemDataBhew1)		,
		.low2_o			(MEM_MemDataBlew2)		,
		.high2_o		(MEM_MemDataBhew2)	    
	);
`endif// DCACHE
	r2000_mem2reg      unit_mem_to_reg
	(
		.MemData_i		(mem_data_data_i)		,	// Memory Side (MemDataDin),		// Memory Side
		.Length_i		(MEM_ctl_mem_tail)		,	// WORD, HALF, BYTE
		.Sign_i			(MEM_ctl_mem_sign)		,	// Sign extension type

		.Ad_i			(MemDataAddrInt[1:0])	,	// the two least significant bits effective address
		.Rd_i			(MEM_ctl_mem_read)		,	// Memory Read

		.RegData_o		(MemDataInterDin)		,	// Register Side
		.low1_o			(MEM_MemDataBler1)		,	
		.high1_o		(MEM_MemDataBher1)		,
		.low2_o			(MEM_MemDataBler2)		,
		.high2_o		(MEM_MemDataBher2)	
	);
	
	/* ********************************************************************* */
	/* OUTPUTS SIGNALS FROM CPU TO MEMORY */
	/* ********************************** */
	// Enable
	assign mem_data_en_o	= MEM_freeze;
	
	// Read write
	assign mem_data_wr_o	= MEM_ctl_mem_write;
	assign mem_data_rd_o	= MEM_ctl_mem_read;
	
	// Adress
	assign MemDataAddrInt	= MEM_alu_out;
	assign mem_data_addr_o	= MemDataAddrInt;
`ifdef DCACHE
	// Data
	assign mem_data_data_o	= MEM_reg_rt;	// remove "r2000_reg2mem"

	// Bit select
	assign mem_data_width_o = MEM_ctl_mem_tail;
`else// DCACHE
	// Data
	assign mem_data_data_o	= MemDataInterDout;	// On reset bi-directional ports in input state
	
	// Bit select
	assign mem_data_blel_o	= ~(~MEM_MemDataBlew1 | ~MEM_MemDataBler1);
	assign mem_data_bhel_o	= ~(~MEM_MemDataBhew1 | ~MEM_MemDataBher1);
	assign mem_data_bleh_o	= ~(~MEM_MemDataBlew2 | ~MEM_MemDataBler2);
	assign mem_data_bheh_o	= ~(~MEM_MemDataBhew2 | ~MEM_MemDataBher2);
`endif// DCACHE
	
	/* REGISTER DATA WRITE SOURCE */
	r2000_mux2  	   mux_reg_datain
	(	.in0_i			(MEM_result_operation)	,	//		from the Result of execution operation (ALU, SHIFTER, MULT/DIVDER...)
		.in1_i			(MemDataInterDin)		,	//	or	from the data memory
		.sel_i			(MEM_clt_reg_src)		,
		.out_o			(MEM_RegDatain)     		//		the result write back to the registerfile
	);

`ifdef	CP0
	always@(`CLOCK_EDGE clk_i, `RESET_EDGE rst_i)
	begin
		if (rst_i == `RESET_ON)
			MEM_branch_Slot = `CLEAR;
		else
			// Branch Slot instruction in MEM stage (see mux_pc)
			MEM_branch_Slot = ((MEM_mux_branch_sel == 1) ||
								(MEM_mux_branch_sel == 2) ||
								(MEM_mux_branch_sel == 3));
	end
	
	/*==================================================*/
	/*	CP0 :Co-Processor0 Unit							*/
	/*==================================================*/
	r2000_cp0	unit_cp0
	(
		// Register transfert
		.rw_i			(MEM_clt_CoMt)		,	// Read/Write Signal
		.addr_i			(MEM_rd_index)		,	// Adress of the register Write
		.data_i			(MEM_RegDatain)		,	// Data in the register
		
		.addr_o			(ID_rd_index)		,	// Adress of the register Read
		.data_o			(MEM_cp0_dout)		,	// Data out of the register
		
		.brch_i			(MEM_branch_Slot)	,	// Detect exception in Branch Slot 
		// Exception signals
		.OVF_i			(MEM_sig_ovf)		,	// Overflow exception
		.SYS_i			(MEM_sig_clt_sys)	,	// System exception
		.INT_i			(MEM_sig_int)		,	// Interrupt interrupt
		.SI_i			(MEM_sig_si)		,	//
		
		.EPC_i			(MEM_EPC)			,	// PC to EPC
		
		.Exception_o	(wException)		,	// Exception occured
		.PC_vec_o		(wEPC_Vector)		,	// Exception Vector
		
		.rfe_i			(MEM_clt_rfe)		,	// Signal of the rfe instruction
		
		// System
		.rst_i			(rst_i)				,
		.clk_i          (~clk_i)
	);
`endif	//CP0

	/* *************** */
	/* MEM/WB PIPELINE */
	/* *************** */
	/* CONTROL */
	// WB
	r2000_pipe #(  1) MEMWB_ctl_reg_write_pipe 	(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(MEMWB_stall) , .flush_i(MEMWB_flush) , .D_i(MEM_ctl_reg_write) ,	.Q_o(WB_ctl_reg_write) );
	
	/* DATAPATH */
`ifdef DEBUG
	r2000_pipe #(`dw) MEMWB_inst_pipe			(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(MEMWB_stall) , .flush_i(MEMWB_flush) , .D_i(MEM_inst)			,	.Q_o(WB_inst) );
`endif//DEBUG                                                                                                                                  			
	r2000_pipe #(`dw) MEMWB_regdatain_pipe		(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(MEMWB_stall) , .flush_i(MEMWB_flush) , .D_i(MEM_RegDatain)	,	.Q_o(WB_RegDatain) );
	r2000_pipe #(`iw) MEMWB_rd_pipe 			(.clk_i(clk_i) , .rst_i(rst_i) , .stall_i(MEMWB_stall) , .flush_i(MEMWB_flush) , .D_i(MEM_rd_index)		,	.Q_o(WB_rd_index) );
	
	/*======================================================================================================================================================*/
	/*	WB:Write Back STAGE								*/
	/*======================================================================================================================================================*/


endmodule
