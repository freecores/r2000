//////////////////////////////////////////////////////////////////////
////                                                              ////
//// tb_r2000_soc.v The testBench of the r2000pl  soc  		      ////
////                                                              ////
//// This file is part of the r2000pl Pipelined				      ////
////	opencores effort.										  ////
////	Simple Pipelined Mips 32 bits processor				      ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// Test bench of the r2000pl cpu  soc                           ////
//// This model use:											  ////
////   one bus memory                                             ////
////   SRAM for data                                              ////
////   FLASH for code                                             ////
////                                                              ////
//// To Do:                                                       ////
//// YOUR STATE HERE                                              ////
////                                                              ////
//// Author(s):                                                   ////
//// - Abdallah Meziti El-Ibrahimi   abdallah.meziti@gmail.com    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001 YOUR NAME HERE and OPENCORES.ORG          ////
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
module tb_r2000_soc;
	parameter  n = 80;	

/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */
//	reg [n*8:0]			file		;
	reg					clk			,
						rst			;
	integer				i			;

	wire[`aw-1:0]		SRAM_ADDR	;
	wire[`dw-1:0]		SRAM_DATA	;
						
	wire				SRAM_CEn	,
						SRAM_OEn	,
						SRAM_WRn	,
						SRAM_RDn	,
						SRAM_Bhel	,
						SRAM_Blel	,
						SRAM_Bheh	,
						SRAM_Bleh
									;
									
	reg	[5:0]			sig_int		;
	reg	[1:0]			sig_si		;

/* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */

	/* The CPU under test */
	r2000_soc UUT
	(
		/* ~~~~~~~~~~~~~~~ */
		/* Bus memory side */
		/* ~~~~~~~~~~~~~~~ */
		// SRAM         
		.RAM_ADR_o		(SRAM_ADDR)		,
		.RAM_DATA_io	(SRAM_DATA)		,
		
		.RAM_CEn_o		(SRAM_CEn)		,
		.RAM_OEn_o		(SRAM_OEn)		,
		.RAM_RDn_o		(SRAM_RDn)		,
		.RAM_WRn_o		(SRAM_WRn)		,
                        
		.RAM_blel_o		(SRAM_Blel)		,	// Byte Memory Low enable
		.RAM_bhel_o		(SRAM_Bhel)		,	// Byte Memory High Enable
		.RAM_bleh_o		(SRAM_Bleh)		,	// Byte Memory Low enable
		.RAM_bheh_o		(SRAM_Bheh)		,	// Byte Memory High Enable
		                
`ifdef	EXCEPTION
		.SIG_int_i		(sig_int)		,	// Interrupt exception
		.SIG_si_i		(sig_si)		,	// Software Interrupt
`endif	//EXCEPTION

		.clk_i			(clk)			,	// Clock
		.rst_i			(rst)				// Reset
	);
	
	
    /* SRAM memory data */
`ifdef SRAM_IDT
	idt71v416s10	SRAMl
	(	
		.data	(SRAM_DATA[15:0]),
		.addr	(SRAM_ADDR[19:2]),
		.we_	(SRAM_WRn),
		.oe_	(SRAM_OEn),
		.cs_	(SRAM_CEn),
		.ble_	(SRAM_Blel),
		.bhe_   (SRAM_Bhel)
	);
	
	idt71v416s10	SRAMh
	(
		.data	(SRAM_DATA[31:16]),
		.addr	(SRAM_ADDR[19:2]),
		.we_	(SRAM_WRn),
		.oe_	(SRAM_OEn),
		.cs_	(SRAM_CEn),
		.ble_	(SRAM_Bleh),
		.bhe_   (SRAM_Bheh)
	);
`else
	SRAM    SRAMl
	(
		.DATA	(SRAM_DATA[15:0])				,	// Data i/o
		.A		({2'b0,SRAM_ADDR[`aw-1:2]})		,	// Address
		.WE		(SRAM_WRn)						,	// Write enable
		.OE		(SRAM_RDn)						,	// Output enable
		.CS		(SRAM_CEn)						,	// Chip enable
		.BHE	(SRAM_Bhel)						,	// Byte High Enable
		.BLE	(SRAM_Blel)						,	// Byte Low enable
		.clk	(clk)							
	);
	SRAM    SRAMh
	(
		.DATA	(SRAM_DATA[31:16])				,	// Data i/o
		.A		({2'b0,SRAM_ADDR[`aw-1:2]})		,	// Address
		.WE		(SRAM_WRn)						,	// Write enable
		.OE		(SRAM_RDn)						,	// Output enable
		.CS		(SRAM_CEn)						,	// Chip enable
		.BHE	(SRAM_Bheh)						,	// Byte High Enable
		.BLE	(SRAM_Bleh)						,	// Byte Low enable
		.clk	(clk)
	);
`endif

	/* Address decoder */
//	assign SRAM_CEn	= (MemAddresse < `TAILLE_DATA/4) ? `LOW: `HIGH;
	
	/* UART STATUS */
//	assign SRAM_DATA		= ((MemAddresse == `UART_READ) && !SRAM_RDn) ? 0 : {`dw{1'bz}};
	
	/* *********** */
	/* Simule UART */
	/* *********** */
//	always@(SRAM_WRn, SRAM_RDn)	// behavioral simulation
//	always@(posedge clk)		//gate simulation
	always@(negedge clk)		//gate simulation
	begin
		if (SRAM_ADDR == `UART_WRITE)begin
//			if (SRAM_WRn)		// behavioral simulation
			if (!SRAM_WRn)		//gate simulation

`ifdef MSB_UART
				$write("%c",SRAM_DATA[31:24]);
`else
				$write("%c",SRAM_DATA[7:0]);
`endif

			else if (!SRAM_RDn)begin
/*
				$write("Read UART DATA");
				$write(" :PC:%h | RD:%b | WR:%b | ADDR:%h\n",MemAddresse, SRAM_RDn, SRAM_WRn, MemAddresse);
*/
			end

		end else if (SRAM_ADDR == `IRQ_STATUS)
			if (!SRAM_RDn)begin
				$write("Read UART STATUS");
				$write(" : RD:%b | WR:%b | ADDR:%h\n",SRAM_RDn, SRAM_WRn, SRAM_ADDR);
			end
//		else
//			$display("Write SRAM");
	end
	
`ifdef MESSAGE_PERI
	/* ******************** */
	/* Limit of SRAM memory */
	/* ******************** */
//	always@(negedge SRAM_WRn, negedge SRAM_RDn)
	always@(negedge clk)
	begin
		if (!SRAM_WRn || !SRAM_RDn)
			if ((SRAM_ADDR[`aw-1:2] > `TAILLE_DATA) &&
			(SRAM_ADDR != `UART_WRITE) && 
			(SRAM_ADDR != `IRQ_STATUS)
				)begin
				$write("SRAM :Out of memory");
				$write(" :RD:%b | WR:%b | ADDR:%h\n", SRAM_RDn, SRAM_WRn, SRAM_ADDR);
			end
	end
`endif//MESSAGE_PERI

	/* Clock */
	always #(`PERIODE_CLK/2) clk = ~clk; 

   	/* Initial */
	initial begin
		
`ifdef SRAM_IDT
		for(i=0;i<`TAILLE_DATA;i=i+1)begin
			SRAMl.mem1[i]=0;SRAMl.mem2[i]=0;
			SRAMh.mem1[i]=0;SRAMh.mem2[i]=0;
		end
`else
		for(i=0;i<`TAILLE_DATA;i=i+1)begin
			SRAMl.mem[i]=0;
			SRAMh.mem[i]=0;
		end
`endif
			
		// fill SRAM Memory low with code
`ifdef SRAM_IDT
		$readmemh("../../../bench/code/opcodes_sraml1.txt", SRAMl.mem1);
		$readmemh("../../../bench/code/opcodes_sraml2.txt", SRAMl.mem2);
`else
		$readmemh("../../../bench/code/opcodes_sraml.txt", SRAMl.mem);
//		$readmemh("../../../bench/code/dhry21_sraml.txt", SRAMl.mem);
//		$readmemh("../../../bench/code/rtos_sraml.txt", SRAMl.mem);
//		$readmemh("../../../bench/code/rs_tak_sraml.txt", SRAMl.mem);
//		$readmemh("../../../bench/code/pi_sraml.txt", SRAMl.mem);
//		$readmemh("../../../bench/code/count_sraml.txt", SRAMl.mem);
//		$readmemh("../../../bench/code/torture_sraml.txt", SRAMl.mem);
`endif

		// fill SRAM Memory low with code
`ifdef SRAM_IDT
		$readmemh("../../../bench/code/opcodes_sramh1.txt", SRAMh.mem1);
		$readmemh("../../../bench/code/opcodes_sramh2.txt", SRAMh.mem2);
`else
		$readmemh("../../../bench/code/opcodes_sramh.txt", SRAMh.mem);
//		$readmemh("../../../bench/code/dhry21_sramh.txt", SRAMh.mem);
//		$readmemh("../../../bench/code/rtos_sramh.txt", SRAMh.mem);
//		$readmemh("../../../bench/code/rs_tak_sramh.txt", SRAMh.mem);
//		$readmemh("../../../bench/code/pi_sramh.txt", SRAMh.mem);
//		$readmemh("../../../bench/code/count_sramh.txt", SRAMh.mem);
//		$readmemh("../../../bench/code/torture_sramh.txt", SRAMh.mem);
`endif
		
			clk = 1'b0; rst = 1'b1; sig_int	= 6'b0; sig_si	= 2'b0;
		#1				rst = 1'b1;
		#`PERIODE_CLK	rst = 1'b0;
		
		#(0965*`PERIODE_CLK) sig_int = 1; #(2*`PERIODE_CLK)	sig_int = 0;
		
	end

   	/* Vector of test bench */
	initial begin
//		$monitor("PC:%h ",UUT.wMem_code_addr);		
//		   #(1220*`PERIODE_CLK) // 12.2 us
//		    #(550*`PERIODE_CLK) //  5.5 us
//		   #(2000*`PERIODE_CLK) // 20.0 us
		   #(7500*`PERIODE_CLK) // 75.0 us
//		  #(44000*`PERIODE_CLK) // 0.44 ms
//		 #(100000*`PERIODE_CLK) // 10 ms
//	   #(20000000*`PERIODE_CLK) // 200 ms
		
		$stop;// Stop simulation
		
	end
	
endmodule

