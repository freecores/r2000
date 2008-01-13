//////////////////////////////////////////////////////////////////////
////                                                              ////
//// tb_r2000_cpu.v The testBench of the r2000sc                  ////
////                                                              ////
//// This file is part of the r2000sc SingleCycle				  ////
////	opencores effort.										  ////
////	Simple Single-cycle Mips 32 bits processor				  ////
//// <http://www.opencores.org/cores/YOUR DIRECTORY/>             ////
////                                                              ////
//// Module Description:                                          ////
//// YOUR MODULE DESCRIPTION                                      ////
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

//`define PERIODE_CLK 100 // 100 x 1ns = 100ns post rout 10 Mhz
`define PERIODE_CLK 10 // 10 x 1ns = 10ns behavioral 100 Mhz

//
`define MSB				// Position of the data in uart

/* ====================
	module definition
   ==================== */
module tb_r2000_cpu;
	parameter  n = 80;	

/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */
	reg [n*8:0]			file		;
	reg					clk			,
						rst			;
	integer				i			;

	wire[`dw-1:0]		MemCodeAddr	,
						MemCodeInst	,
						MemDataAddr	;
	wire[`dw-1:0]		MemDataD	;
	wire				MemDataCs	,
						MemDataWr	,
						MemDataRd	,
						MemDataBhel	,
						MemDataBlel	,
						MemDataBheh	,
						MemDataBleh	;

/* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */

	/* The CPU under test */
	r2000_cpu	UUT
	(
		.mem_code_addr_o	(MemCodeAddr)	,	// Memory Programm Address
		.mem_code_inst_i	(MemCodeInst)	,	// Memory Programm Instruction
		                   	
		.mem_data_addr_o	(MemDataAddr)	,	// Memory Data Address
		.mem_data_data_io	(MemDataD)		,	// Memory Data in/out of the processor
		.mem_data_wr_o	  	(MemDataWr)		,	// Memory Data Write
		.mem_data_rd_o	  	(MemDataRd)		,	// Memory Data Read
		.mem_data_blel_o	(MemDataBlel)	,	// Memory Byte Low enable
		.mem_data_bhel_o	(MemDataBhel)	,	// Memory Byte High Enable
		.mem_data_bleh_o	(MemDataBleh)	,	// Memory Byte Low enable
		.mem_data_bheh_o	(MemDataBheh)	,	// Memory Byte High Enable
		               
		.clk_i			    (clk)			,	// Clock
		.rst_i			    (rst)				// Reset
	);
	
	
    /* SRAM data */
	SRAM    SRAMl
	(	.CS		(MemDataCs)						,	//`LOW),			// Chip enable
		.OE		(MemDataRd)						,	// Output enable
		.WE		(MemDataWr)						,	// Write enable
		.BHE	(MemDataBhel)					,	// Byte High Enable
		.BLE	(MemDataBlel)					,	// Byte Low enable
		.A		({2'b0,MemDataAddr[`dw-1:2]})	,	// Address
		.DATA	(MemDataD[15:0])					// Data i/o
	);
	SRAM    SRAMh
	(	.CS		(MemDataCs)						,	//`LOW),			// Chip enable
		.OE		(MemDataRd)						,	// Output enable
		.WE		(MemDataWr)						,	// Write enable
		.BHE	(MemDataBheh)					,	// Byte High Enable
		.BLE	(MemDataBleh)					,	// Byte Low enable
		.A		({2'b0,MemDataAddr[`dw-1:2]})	,	// Address
		.DATA	(MemDataD[31:16])					// Data i/o
	);
	
	/* Flash Memory code Data */
	FLASH FLASH1
	(
		.CS		(`LOW)							,	// Chip enable
		.OE		(`LOW)							,	// Output enable
		.WE		(`HIGH)							,	// Write enable
		.A		({2'b0,MemCodeAddr[`dw-1:2]})	,	// Adress
		.DATA	(MemCodeInst)						// Data o
	);
	
	/* Address decoder */
	assign MemDataCs	= (MemDataAddr < `TAILLE_DATA/4) ? `LOW: `HIGH;
	
	/* UART STATUS */
	assign MemDataD		= ((MemDataAddr == `UART_READ) && !MemDataRd) ? 0 : {`dw{1'bz}};
	
	/* *********** */
	/* Simule UART */
	/* *********** */
	always@(negedge MemDataWr, negedge MemDataRd)
	begin
		if (MemDataAddr == `UART_WRITE)begin
			if (!MemDataWr)
//`ifdef ENDIAN
`ifdef MSB
				$write("%c",MemDataD[31:24]);
`else
				$write("%c",MemDataD[7:0]);
`endif

			else if (!MemDataRd)begin
/*
				$write("Read UART DATA");
				$write(" :PC:%h | RD:%b | WR:%b | ADDR:%h\n",MemCodeAddr, MemDataRd, MemDataWr, MemDataAddr);
*/
			end

		end else if (MemDataAddr == `IRQ_STATUS)
			if (!MemDataRd)begin
				$write("Read UART STATUS");
				$write(" :PC:%h | RD:%b | WR:%b | ADDR:%h\n",MemCodeAddr, MemDataRd, MemDataWr, MemDataAddr);
			end
//		else
//			$display("Write SRAM");
	end
	
	/* ******************** */
	/* Limit of SRAM memory */
	/* ******************** */
//	always@(negedge MemDataWr, negedge MemDataRd)
	always@(negedge clk)
	begin
		if (!MemDataWr || !MemDataRd)
			if ((MemDataAddr[`dw-1:2] > `TAILLE_DATA) &&
			(MemDataAddr != `UART_WRITE) && 
			(MemDataAddr != `IRQ_STATUS)
				)begin
				$write("SRAM :Out of memory");
				$write(" :PC:%h | RD:%b | WR:%b | ADDR:%h\n",MemCodeAddr, MemDataRd, MemDataWr, MemDataAddr);
			end
	end

	/* Clock */
	always #(`PERIODE_CLK/2) clk = ~clk; 

   	/* Initial */
	initial begin
		file =
//		{"../../../bench/code/dhry21_code",".txt"}
//		{"../../../bench/code/rtos_code",".txt"}
		{"../../../bench/code/rs_tak_code",".txt"}
//		{"../../../bench/code/opcodes_code",".txt"}
//		{"../../../bench/code/pi_code",".txt"}
//		{"../../../bench/code/count_code",".txt"}
//		{"../../../bench/code/torture_code",".txt"}
		;
		
		// fill Memory with 0s
		for(i=0;i<`TAILLE_CODE;i=i+1)
			FLASH1.mem[i]=0;
		for(i=0;i<`TAILLE_DATA;i=i+1)begin
			SRAMl.mem[i]=0;
			SRAMh.mem[i]=0;
		end
			
		// fill FLASH Memory with code
		$readmemh(file, FLASH1.mem);
		
		// fill SRAM Memory low with code
//		$readmemh("../../../bench/code/dhry21_sraml.txt", SRAMl.mem);
//		$readmemh("../../../bench/code/rtos_sraml.txt", SRAMl.mem);
		$readmemh("../../../bench/code/rs_tak_sraml.txt", SRAMl.mem);
//		$readmemh("../../../bench/code/opcodes_sraml.txt", SRAMl.mem);
//		$readmemh("../../../bench/code/pi_sraml.txt", SRAMl.mem);
//		$readmemh("../../../bench/code/count_sraml.txt", SRAMl.mem);
//		$readmemh("../../../bench/code/torture_sraml.txt", SRAMl.mem);

		// fill SRAM Memory low with code
//		$readmemh("../../../bench/code/dhry21_sramh.txt", SRAMh.mem);
//		$readmemh("../../../bench/code/rtos_sramh.txt", SRAMh.mem);
		$readmemh("../../../bench/code/rs_tak_sramh.txt", SRAMh.mem);
//		$readmemh("../../../bench/code/opcodes_sramh.txt", SRAMh.mem);
//		$readmemh("../../../bench/code/pi_sramh.txt", SRAMh.mem);
//		$readmemh("../../../bench/code/count_sramh.txt", SRAMh.mem);
//		$readmemh("../../../bench/code/torture_sramh.txt", SRAMh.mem);
		
		clk = 1'b0; rst = 1'b0;
		#1  rst = 1'b1;
		#1  rst = 1'b0;
		
	end

   	/* Vector of test bench */
	initial begin
//		   #(1220*`PERIODE_CLK) // 12.2 us
//		    #(350*`PERIODE_CLK) // 3.5 us
//		   #(30000*`PERIODE_CLK) // 50 us
//		#(1000000*`PERIODE_CLK) // 10 ms
	   #(20000000*`PERIODE_CLK) // 200 ms
		
		$stop;// Stop simulation
	end

endmodule

