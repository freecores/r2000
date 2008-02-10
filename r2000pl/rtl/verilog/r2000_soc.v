//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_soc.v				                                  ////
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
module r2000_soc
	(
		/* ~~~~~~~~~~~~~~~ */
		/* Bus memory side */
		/* ~~~~~~~~~~~~~~~ */
		// SRAM
		RAM_ADR_o		,
		RAM_DATA_io		,
		RAM_CEn_o		,
		RAM_OEn_o		,
		RAM_RDn_o		,
		RAM_WRn_o		,

		RAM_blel_o		,	// Byte Memory Low enable
		RAM_bhel_o		,	// Byte Memory High Enable
		RAM_bleh_o		,	// Byte Memory Low enable
		RAM_bheh_o		,	// Byte Memory High Enable
		
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

	output 	[`aw-1:0]		RAM_ADR_o		;

	inout 	[`dw-1:0]		RAM_DATA_io		;
	
	output					RAM_CEn_o		;
	output					RAM_OEn_o		;
	output					RAM_RDn_o		;
	output					RAM_WRn_o		;
	
	output					RAM_blel_o		;
	output					RAM_bhel_o		;
	output					RAM_bleh_o		;
	output					RAM_bheh_o		;
		
`ifdef	EXCEPTION
	input[5:0]				SIG_int_i		;
	input[1:0]				SIG_si_i		;
`endif	//EXCEPTION

	input					clk_i			;
	input					rst_i			;
	
/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
	
	wire	[`aw-1:0]		wMem_data_addr		;
	wire	[`dw-1:0]		wMem_data_pc		;
	
	wire					wMem_data_wr		;
	
	wire	[`aw-1:0]		WB_I_ADR			;
	wire	[`dw-1:0]		WB_I_DAT_M2B		;
	wire	[`dw-1:0]		WB_I_DAT_B2M		;
	wire	[4-1:0]			WB_I_SEL			;
	wire					WB_I_WE				;
	wire					WB_I_CYC, WB_I_STB	;
	wire					WB_I_ACK, WB_I_RTY	;
	wire					WB_I_ERR			;
	reg		[2:0]			WB_I_CTI = 3'b000	;

	wire	[`aw-1:0]		WB_D_ADR			;
	wire	[`dw-1:0]		WB_D_DAT_M2B		;
	wire	[`dw-1:0]		WB_D_DAT_B2M		;
	wire	[4-1:0]			WB_D_SEL			;
	wire					WB_D_WE				;
	wire					WB_D_CYC, WB_D_STB	;
	wire					WB_D_ACK, WB_D_RTY	;
	wire					WB_D_ERR			;
	reg		[2:0]			WB_D_CTI = 3'b000	;
	
	wire	[`aw-1:0]		WB_RAM_ADR				;
	wire	[`dw-1:0]		WB_RAM_DAT_M2B			;
	wire	[`dw-1:0]		WB_RAM_DAT_B2M			;
	wire	[4-1:0]			WB_RAM_SEL				;
	wire					WB_RAM_WE				;
	wire					WB_RAM_CYC, WB_RAM_STB	;
	wire					WB_RAM_ACK, WB_RAM_RTY	;
	reg						WB_RAM_ERR = `CLEAR		;
	reg		[2:0]			WB_RAM_CTI = 3'b000		;

	wire 	[`dw-1:0]		RAM_DATA_i			,
							RAM_DATA_o			;
							
	wire	[3:0]			wRAM_BE				;
	wire					wRAM_WEn			,
							wRAM_OEn			;

/* --------------------------------------------------------------
	instances, statements
   ------------------- */
	/* ~~~~~~~~ */
	/* CPU Core */
	/* ~~~~~~~~ */
	r2000_cpu		CPU
	(
		/* ~~~~~~~~~~~~~~~ */
		/* Bus memory side */
		/* ~~~~~~~~~~~~~~~ */
		// I-CACHE WB
		.WB_I_ADR		(WB_I_ADR		),
		.WB_I_DAT_B2M	(WB_I_DAT_B2M	),
		.WB_I_DAT_M2B	(WB_I_DAT_M2B	),
		.WB_I_SEL		(WB_I_SEL		),
		.WB_I_WE		(WB_I_WE		),

		.WB_I_STB		(WB_I_STB		),
		.WB_I_ACK		(WB_I_ACK		),
		.WB_I_CYC		(WB_I_CYC		),

		.WB_I_RTY		(WB_I_RTY		),
		.WB_I_ERR		(WB_I_ERR		),

		// D-CACHE WB
		.WB_D_ADR		(WB_D_ADR		),
		.WB_D_DAT_M2B	(WB_D_DAT_M2B	),
		.WB_D_DAT_B2M	(WB_D_DAT_B2M	),
		.WB_D_SEL		(WB_D_SEL		),
		.WB_D_WE		(WB_D_WE		),

		.WB_D_STB		(WB_D_STB		),
		.WB_D_ACK		(WB_D_ACK		),
		.WB_D_CYC		(WB_D_CYC		),

		.WB_D_RTY		(WB_D_RTY		),
		.WB_D_ERR		(WB_D_ERR		),

`ifdef	EXCEPTION
		.SIG_int_i		(SIG_int_i		),	// Interrupt exception
		.SIG_si_i		(SIG_si_i		),	// Software Interrupt
`endif	//EXCEPTION

		.clk_i			(clk_i			),	// Clock
		.rst_i			(rst_i			)	// Reset
	);

	/* ~~~~~~~~~~~~~~~~~~ */
	/* SRAM Controller wb */
	/* ~~~~~~~~~~~~~~~~~~ */
	asram_core
	#(	.SRAM_DATA_WIDTH 	(`dw)			,
		.SRAM_ADDR_WIDTH	(`aw)			,
		.READ_LATENCY		(1)				,
		.WRITE_LATENCY		(1))    		
	ASRAM_D_WB(
		/* ~~~~~~~~~~~~~~~~~~~~~~~ */
		/* Wishbone side interface */
		/* ~~~~~~~~~~~~~~~~~~~~~~~ */
		.dat_i				(WB_RAM_DAT_B2M)	,
		.dat_o				(WB_RAM_DAT_M2B)	,
		.addr_i				(WB_RAM_ADR)		,
		.sel_i				(WB_RAM_SEL)		,
		.we_i				(WB_RAM_WE)			,
		.cyc_i				(WB_RAM_CYC)		,
		.stb_i				(WB_RAM_STB)		,
		.ack_o				(WB_RAM_ACK)		,
		.cti_i				(WB_RAM_CTI)		,
		.bte_i				()					,
		/* ~~~~~~~~~~~~~~~~~~~ */
		/* SRAM side interface */
		/* ~~~~~~~~~~~~~~~~~~~ */
		.sram_addr			(RAM_ADR_o)		,
		.sram_data_in		(RAM_DATA_i)	,
		.sram_data_out		(RAM_DATA_o)	,
		.sram_csn			(RAM_CEn_o)		,
		.sram_be			(wRAM_BE)		,
		.sram_wen			(wRAM_WEn)		,
		.sram_oen			(wRAM_OEn)  	,
		/* ~~~~~~~~~~~~~~~ */
		/* Clock and reset */
		/* ~~~~~~~~~~~~~~~ */
		.clk_i				(clk_i)			,
		.rst_i				(rst_i)			
		);
		
	assign RAM_DATA_io		= (wRAM_OEn) ? RAM_DATA_o : `dw'bz;
	assign RAM_DATA_i		= RAM_DATA_io;
	
	assign	RAM_OEn_o		= wRAM_OEn;
	assign	RAM_RDn_o		= wRAM_OEn;
	assign	RAM_WRn_o		= wRAM_WEn;
	assign {RAM_bheh_o, RAM_bleh_o, RAM_bhel_o, RAM_blel_o} = wRAM_BE;

	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	/* INTERCONNECT MATRIX Controller wb */
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	wb_conmax_top
	#(
		`dw,	// Data Bus width
		`aw,	// Address Bus width
		4'hf,	// Register File Address
		2'h1	// Number of priorities of Slave 0
		// Priorities for other Slave will default to 2'h2
	)
	INTERCONNECT (
	.clk_i(clk_i), .rst_i(rst_i),

	// Master 0 Interface
	.m0_data_i	(WB_I_DAT_B2M	),
	.m0_data_o	(WB_I_DAT_M2B	),
	.m0_addr_i	(WB_I_ADR		),
	.m0_sel_i	(WB_I_SEL		),
	.m0_we_i	(WB_I_WE		),
	
	.m0_cyc_i	(WB_I_CYC		),
	.m0_stb_i	(WB_I_STB		),
	.m0_ack_o	(WB_I_ACK		),
	
	.m0_err_o	(WB_I_ERR		),
	.m0_rty_o	(WB_I_RTY		),

	// Master 1 Interface
	.m1_data_i	(WB_D_DAT_B2M	),
	.m1_data_o	(WB_D_DAT_M2B	),
	.m1_addr_i	(WB_D_ADR		),
	.m1_sel_i	(WB_D_SEL		),
	.m1_we_i	(WB_D_WE		),
	  
	.m1_cyc_i	(WB_D_CYC		),
	.m1_stb_i	(WB_D_STB		),
	.m1_ack_o	(WB_D_ACK		),
	  
	.m1_err_o	(WB_D_ERR		),
	.m1_rty_o	(WB_D_RTY		),

	// Master 2 Interface
	.m2_data_i	( `dw'h0000_0000 ),
	.m2_data_o	(),
	.m2_addr_i	( `aw'h0000_0000 ),
	.m2_sel_i	( 4'b0000 ),
	.m2_we_i	( 1'b0 ),
	
	.m2_cyc_i	( 1'b0 ),
	.m2_stb_i	( 1'b0 ),
	.m2_ack_o	(),
	
	.m2_err_o	(),
	.m2_rty_o	(),

	// Master 3 Interface
	.m3_data_i	( `dw'h0000_0000 ),
	.m3_data_o	(),
	.m3_addr_i	( `aw'h0000_0000 ),
	.m3_sel_i	( 4'b0000 ),
	.m3_we_i	( 1'b0 ),
	  
	.m3_cyc_i	( 1'b0 ),
	.m3_stb_i	( 1'b0 ),
	.m3_ack_o	(),
	  
	.m3_err_o	(),
	.m3_rty_o	(),

	// Master 4 Interface
	.m4_data_i	( `dw'h0000_0000 ),
	.m4_data_o	(),
	.m4_addr_i	( `aw'h0000_0000 ),
	.m4_sel_i	( 4'b0000 ),
	.m4_we_i	( 1'b0 ),
	  
	.m4_cyc_i	( 1'b0 ),
	.m4_stb_i	( 1'b0 ),
	.m4_ack_o	(),
	  
	.m4_err_o	(),
	.m4_rty_o	(),

	// Master 5 Interface
	.m5_data_i	( `dw'h0000_0000 ),
	.m5_data_o	(),
	.m5_addr_i	( `aw'h0000_0000 ),
	.m5_sel_i	( 4'b0000 ),
	.m5_we_i	( 1'b0 ),
	  
	.m5_cyc_i	( 1'b0 ),
	.m5_stb_i	( 1'b0 ),
	.m5_ack_o	(),
	  
	.m5_err_o	(),
	.m5_rty_o	(),

	// Master 6 Interface
	.m6_data_i	( `dw'h0000_0000 ),
	.m6_data_o	(),
	.m6_addr_i	( `aw'h0000_0000 ),
	.m6_sel_i	( 4'b0000 ),
	.m6_we_i	( 1'b0 ),
	  
	.m6_cyc_i	( 1'b0 ),
	.m6_stb_i	( 1'b0 ),
	.m6_ack_o	(),
	  
	.m6_err_o	(),
	.m6_rty_o	(),

	// Master 7 Interface
	.m7_data_i	( `dw'h0000_0000 ),
	.m7_data_o	(),
	.m7_addr_i	( `aw'h0000_0000 ),
	.m7_sel_i	( 4'b0000 ),
	.m7_we_i	( 1'b0 ),
	  
	.m7_cyc_i	( 1'b0 ),
	.m7_stb_i	( 1'b0 ),
	.m7_ack_o	(),
	  
	.m7_err_o	(),
	.m7_rty_o	(),

	// Slave 0 Interface
	.s0_data_i	(WB_RAM_DAT_M2B	),
	.s0_data_o	(WB_RAM_DAT_B2M	),
	.s0_addr_o	(WB_RAM_ADR		),
	.s0_sel_o	(WB_RAM_SEL		),
	.s0_we_o	(WB_RAM_WE		),
	
	.s0_cyc_o	(WB_RAM_CYC		),
	.s0_stb_o	(WB_RAM_STB		),
	.s0_ack_i	(WB_RAM_ACK		),
	
	.s0_err_i	(WB_RAM_ERR		),
	.s0_rty_i	(WB_RAM_RTY		),

	// Slave 1 Interface
	.s1_data_i	( `dw'h0000_0000 ),
	.s1_data_o	(),
	.s1_addr_o	(),
	.s1_sel_o	(),
	.s1_we_o	(),
	
	.s1_cyc_o	(),
	.s1_stb_o	(),
	.s1_ack_i	( 1'b0 ),
	
	.s1_err_i	( 1'b0 ),
	.s1_rty_i	( 1'b0 ),

	// Slave 2 Interface
	.s2_data_i	( `dw'h0000_0000 ),
	.s2_data_o	(),
	.s2_addr_o	(),
	.s2_sel_o	(),
	.s2_we_o	(),
	
	.s2_cyc_o	(),
	.s2_stb_o	(),
	.s2_ack_i	( 1'b0 ),
	
	.s2_err_i	( 1'b0 ),
	.s2_rty_i	( 1'b0 ),

	// Slave 3 Interface
	.s3_data_i	( `dw'h0000_0000 ),
	.s3_data_o	(),
	.s3_addr_o	(),
	.s3_sel_o	(),
	.s3_we_o	(),
	  
	.s3_cyc_o	(),
	.s3_stb_o	(),
	.s3_ack_i	( 1'b0 ),
	  
	.s3_err_i	( 1'b0 ),
	.s3_rty_i	( 1'b0 ),

	// Slave 4 Interface
	.s4_data_i	( `dw'h0000_0000 ),
	.s4_data_o	(),
	.s4_addr_o	(),
	.s4_sel_o	(),
	.s4_we_o	(),
	  
	.s4_cyc_o	(),
	.s4_stb_o	(),
	.s4_ack_i	( 1'b0 ),
	  
	.s4_err_i	( 1'b0 ),
	.s4_rty_i	( 1'b0 ),

	// Slave 5 Interface
	.s5_data_i	( `dw'h0000_0000 ),
	.s5_data_o	(),
	.s5_addr_o	(),
	.s5_sel_o	(),
	.s5_we_o	(),
	  
	.s5_cyc_o	(),
	.s5_stb_o	(),
	.s5_ack_i	( 1'b0 ),
	  
	.s5_err_i	( 1'b0 ),
	.s5_rty_i	( 1'b0 ),

	// Slave 6 Interface
	.s6_data_i	( `dw'h0000_0000 ),
	.s6_data_o	(),
	.s6_addr_o	(),
	.s6_sel_o	(),
	.s6_we_o	(),
	  
	.s6_cyc_o	(),
	.s6_stb_o	(),
	.s6_ack_i	( 1'b0 ),
	  
	.s6_err_i	( 1'b0 ),
	.s6_rty_i	( 1'b0 ),

	// Slave 7 Interface
	.s7_data_i	( `dw'h0000_0000 ),
	.s7_data_o	(),
	.s7_addr_o	(),
	.s7_sel_o	(),
	.s7_we_o	(),
	  
	.s7_cyc_o	(),
	.s7_stb_o	(),
	.s7_ack_i	( 1'b0 ),
	  
	.s7_err_i	( 1'b0 ),
	.s7_rty_i	( 1'b0 ),

	// Slave 8 Interface
	.s8_data_i	( `dw'h0000_0000 ),
	.s8_data_o	(),
	.s8_addr_o	(),
	.s8_sel_o	(),
	.s8_we_o	(),
	  
	.s8_cyc_o	(),
	.s8_stb_o	(),
	.s8_ack_i	( 1'b0 ),
	  
	.s8_err_i	( 1'b0 ),
	.s8_rty_i	( 1'b0 ),

	// Slave 9 Interface
	.s9_data_i	( `dw'h0000_0000 ),
	.s9_data_o	(),
	.s9_addr_o	(),
	.s9_sel_o	(),
	.s9_we_o	(),
	  
	.s9_cyc_o	(),
	.s9_stb_o	(),
	.s9_ack_i	( 1'b0 ),
	  
	.s9_err_i	( 1'b0 ),
	.s9_rty_i	( 1'b0 ),

	// Slave 10 Interface
	.s10_data_i	( `dw'h0000_0000 ),
	.s10_data_o	(),
	.s10_addr_o	(),
	.s10_sel_o	(),
	.s10_we_o	(),
	   
	.s10_cyc_o	(),
	.s10_stb_o	(),
	.s10_ack_i	( 1'b0 ),
	   
	.s10_err_i	( 1'b0 ),
	.s10_rty_i	( 1'b0 ),

	// Slave 11 Interface
	.s11_data_i	( `dw'h0000_0000 ),
	.s11_data_o	(),
	.s11_addr_o	(),
	.s11_sel_o	(),
	.s11_we_o	(),
	   
	.s11_cyc_o	(),
	.s11_stb_o	(),
	.s11_ack_i	( 1'b0 ),
	   
	.s11_err_i	( 1'b0 ),
	.s11_rty_i	( 1'b0 ),

	// Slave 12 Interface
	.s12_data_i	( `dw'h0000_0000 ),
	.s12_data_o	(),
	.s12_addr_o	(),
	.s12_sel_o	(),
	.s12_we_o	(),
	   
	.s12_cyc_o	(),
	.s12_stb_o	(),
	.s12_ack_i	( 1'b0 ),
	   
	.s12_err_i	( 1'b0 ),
	.s12_rty_i	( 1'b0 ),

	// Slave 13 Interface
	.s13_data_i	( `dw'h0000_0000 ),
	.s13_data_o	(),
	.s13_addr_o	(),
	.s13_sel_o	(),
	.s13_we_o	(),
	   
	.s13_cyc_o	(),
	.s13_stb_o	(),
	.s13_ack_i	( 1'b0 ),
	   
	.s13_err_i	( 1'b0 ),
	.s13_rty_i	( 1'b0 ),

	// Slave 14 Interface
	.s14_data_i	( `dw'h0000_0000 ),
	.s14_data_o	(),
	.s14_addr_o	(),
	.s14_sel_o	(),
	.s14_we_o	(),
	   
	.s14_cyc_o	(),
	.s14_stb_o	(),
	.s14_ack_i	( 1'b0 ),
	   
	.s14_err_i	( 1'b0 ),
	.s14_rty_i	( 1'b0 ),

	// Slave 15 Interface
	.s15_data_i	( `dw'h0000_0000 ),
	.s15_data_o	(),
	.s15_addr_o	(),
	.s15_sel_o	(),
	.s15_we_o	(),
	   
	.s15_cyc_o	(),
	.s15_stb_o	(),
	.s15_ack_i	( 1'b0 ),
	   
	.s15_err_i	( 1'b0 ),
	.s15_rty_i	( 1'b0 )
	);

endmodule
