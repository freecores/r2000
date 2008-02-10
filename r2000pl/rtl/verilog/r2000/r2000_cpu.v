//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_cpu.v				                                  ////
////                                                              ////
//// This file is part of the r2000pl Pipelined				      ////
////	opencores effort.										  ////
////	Simple Pipelined Mips 32 bits processor				      ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
////                                                              ////
////                                                              ////
//// To Do:                                                       ////
//// - add WishBone Bus I-cache D-cache                           ////
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
module r2000_cpu
	(
		/* ~~~~~~~~~~~~~~~ */
		/* Bus memory side */
		/* ~~~~~~~~~~~~~~~ */
		// I-CACHE WB
		WB_I_ADR		,
		WB_I_DAT_B2M	,
		WB_I_DAT_M2B	,
		WB_I_SEL		,
		WB_I_WE			,
		
		WB_I_STB		,
		WB_I_ACK		,
		WB_I_CYC		,
		
		WB_I_RTY		,
		WB_I_ERR		,
		
		// D-CACHE WB
		WB_D_ADR		,
		WB_D_DAT_M2B	,
		WB_D_DAT_B2M	,
		WB_D_SEL		,
		WB_D_WE			,
		
		WB_D_STB		,
		WB_D_ACK		,
		WB_D_CYC		,
		
		WB_D_RTY		,
		WB_D_ERR		,
		
`ifdef	EXCEPTION
		SIG_int_i		,	// Interrupt exception
		SIG_si_i		,	// Software Interrupt
`endif	//EXCEPTION

		clk_i			,	// Clock
		rst_i				// Reset
	);
/* --------------------------------------------------------------
	in, out declaration
   ------------------- */
	output	[`aw-1:0]		WB_I_ADR			;
	input	[`dw-1:0]		WB_I_DAT_M2B		;
	output	[`dw-1:0]		WB_I_DAT_B2M		;
	output	[4-1:0]			WB_I_SEL			;
	output					WB_I_WE				;
	output					WB_I_CYC, WB_I_STB	;
	input					WB_I_ACK, WB_I_RTY	;
	input					WB_I_ERR			;

	output	[`aw-1:0]		WB_D_ADR			;
	input	[`dw-1:0]		WB_D_DAT_M2B		;
	output	[`dw-1:0]		WB_D_DAT_B2M		;
	output	[4-1:0]			WB_D_SEL			;
	output					WB_D_WE				;
	output					WB_D_CYC, WB_D_STB	;
	input					WB_D_ACK, WB_D_RTY	;
	input					WB_D_ERR			;
	
`ifdef	EXCEPTION
	input[5:0]				SIG_int_i		;
	input[1:0]				SIG_si_i		;
`endif	//EXCEPTION

	input					clk_i			;
	input					rst_i			;
	
/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
	wire	[`aw-1:0]		wMem_code_addr		;
	wire	[`dw-1:0]		wMem_code_inst		;
	wire					wMem_code_hit		;
	
	wire	[`aw-1:0]		wMem_data_addr		;
	wire	[`dw-1:0]		wMem_data_cp		;
	wire	[`dw-1:0]		wMem_data_pc		;
	
	wire					wMem_data_rd		,
							wMem_data_wr		,
							wMem_data_en		;
	
	
	wire					dcache_enable		;

	wire	[1:0]			wMem_data_width		;
	wire					wMem_data_hit		;
	wire	[3:0]			wRAM_BE				;
	wire					wRAM_WEn			,
							wRAM_OEn			;

/* --------------------------------------------------------------
	instances, statements
   ------------------- */

	r2000_i_cache
	#(	.cache_size 	(`ICACHE_SIZE	)	,	//  in bytes, power of 2
		.line_size		(`ICACHE_LINE	)	,	//  in bytes, power of 2
		.associativity	(`ICACHE_ASSO	)	,   //  1 = direct mapped
		.tpd_clk_out	(`ICACHE_TPD	))		//	clock to output propagation delay
	ICACHE(                              	
		/* ~~~~~~~~~~~~~~~~~~ */
		/* Connections to CPU
		/* ~~~~~~~~~~~~~~~~~~ */
		.cpu_addr_i		(wMem_code_addr)	,	// address bus output            
		.cpu_data_o		(wMem_code_inst)	,	// output data bus
		.cpu_enable_i	(~rst_i)			,	// starts memory cycle           
		.cpu_ready_o	(wMem_code_hit)		,	// status from memory system     
		                                	
		/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
		/* Connections to WishBone Bus
		/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
		.ADR_O			(WB_I_ADR)			,
		.DAT_I			(WB_I_DAT_M2B)		,
		.DAT_O			(WB_I_DAT_B2M)		,
		.WE_O 			(WB_I_WE)			,
		.SEL_O			(WB_I_SEL)			,
		            	                	
		.STB_O			(WB_I_STB)			,
		.ACK_I			(WB_I_ACK)			,
		.CYC_O			(WB_I_CYC)			,
		            	                	
		.ERR_I			(WB_I_ERR)			,
		.RTY_I     		(WB_I_RTY)			,
		            	                	
		.clk_i			(clk_i)				,	
		.rst_i			(rst_i)					// synchronous reset input       
	);
		

	/* ~~~~~~~~ */
	/* CPU Core */
	/* ~~~~~~~~ */
	r2000_cpu_pipe	COREPIPE
	(
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	/* INSTRUCTION MEMORY INTERFACE */
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
		.mem_code_addr_o	(wMem_code_addr),	// Programm Memory Address
		.mem_code_inst_i	(wMem_code_inst),	// Programm Memory Instruction
		.mem_code_hit_i		(wMem_code_hit)	,	// I-Cache hit signal
		                	
	/* ~~~~~~~~~~~~~~~~~~~~~ */
	/* DATA MEMORY INTERFACE */
	/* ~~~~~~~~~~~~~~~~~~~~~ */
		.mem_data_addr_o	(wMem_data_addr),	// Data Memory Address

		.mem_data_data_i	(wMem_data_cp)	,	// Data Memory in the processor
		.mem_data_data_o	(wMem_data_pc)	,	// Data Memory out of the processor
		.mem_data_hit_i		(wMem_data_hit)	,	// D-Cache hit signal
		
		.mem_data_wr_o		(wMem_data_wr)	,	// Data Memory Write
		.mem_data_rd_o		(wMem_data_rd)	,	// Data Memory Read
		.mem_data_en_o		(wMem_data_en)	,
		.mem_data_width_o	(wMem_data_width),	// Byte Memory Width

`ifdef	EXCEPTION
		.sig_int_i			(SIG_int_i)		,	// Interrupt exception
		.sig_si_i			(SIG_si_i)		,	// Software Interrupt
`endif	//EXCEPTION	
	/* ~~~~~~~~~~~~~ */		                	
	/* CLOCK & RESET */
	/* ~~~~~~~~~~~~~ */		                	
		.clk_i				(clk_i)			,	// Clock
		.rst_i				(rst_i)				// Reset
	);


	// if not reset: enable d-cache when read or write cycle
	assign dcache_enable = ~(rst_i | (~(wMem_data_wr | wMem_data_rd)));
	
	r2000_d_cache
	#(	.cache_size		(`DCACHE_SIZE	),	//  in bytes, power of 2
		.line_size		(`DCACHE_LINE	),	//  in bytes, power of 2
		.associativity	(`DCACHE_ASSO	),	//  1 = direct mapped
		.write_strategy	(`DCACHE_BACK	),	//  write_through or copy_back
		.tpd_clk_out	(`DCACHE_TPD	))	//	clock to output propagation delay
	DCACHE(
		.en_i			(wMem_data_en)	,//`SET)			,
		/* ~~~~~~~~~~~~~~~~~~ */
		/* Connections to CPU
		/* ~~~~~~~~~~~~~~~~~~ */
		.cpu_addr_i		(wMem_data_addr),	// address bus output            
		.cpu_data_i		(wMem_data_pc)	,	// input data bus
		.cpu_data_o		(wMem_data_cp)	,	// output data bus
		
		.cpu_enable_i	(dcache_enable)	,	// starts memory cycle           
		.cpu_write_i	(wMem_data_wr)	,	// selects read or write cycle
		.cpu_width_i	(wMem_data_width),	// byte/halfword/word indicator  
		.cpu_ready_o	(wMem_data_hit)	,	// status from memory system     
		
		/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
		/* Connections to WishBone Bus
		/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
		.ADR_O			(WB_D_ADR)		,
		.DAT_I			(WB_D_DAT_M2B)	,
		.DAT_O			(WB_D_DAT_B2M)	,
		.SEL_O			(WB_D_SEL)		,
		.WE_O			(WB_D_WE)		,
		            	
		.STB_O			(WB_D_STB)		,
		.ACK_I			(WB_D_ACK)		,
		.CYC_O			(WB_D_CYC)		,
		            	
		.ERR_I			(WB_D_ERR)		,
		.RTY_I			(WB_D_RTY)		,
                    	
		.clk_i			(clk_i)			,	// Clock
		.rst_i			(rst_i)				// Reset
	);
		
`ifdef DEBUG_CACHE
	always@(`CLOCK_REVER clk_i)		//gate simulation
	begin
		if (wMem_data_addr == `UART_WRITE)
			if (wMem_data_wr)		// behavioral simulation

`ifdef MSB_UART
				$write("%c",wMem_data_pc[7:0]);
`else //MSB_UART
				$write("%c",wMem_data_pc[31:24]);
`endif//MSB_UART
	end

`endif//DEBUG_CACHE
	

endmodule
