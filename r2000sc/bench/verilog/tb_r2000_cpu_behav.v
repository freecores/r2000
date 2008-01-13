//////////////////////////////////////////////////////////////////////
////                                                              ////
//// tb_r2000_cpu_behav.v The testBench of the behav r2000sc      ////
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

`define PERIODE_CLK 10 // 10 x 1ns = 10ns behavioral 100 Mhz
//`define TRACE

/* ====================
	module definition
   ==================== */
module tb_r2000_cpu_behav;
	parameter  n = 40;	

/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */
	reg [n*8:0]			file;
	reg					clk;
	integer				i,j;
	
	integer				mcd;

/* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */
	r2000_behavioral UUT(clk);

	/* Clock */
	always #(`PERIODE_CLK/2) clk = ~clk; 

   	/* Initial */
	initial begin
/*		$dumpfile ("my.dump");
		$dumpvars;
		#1000 $dumpoff;
*/		

		file =
//		{"code/rtos_behav",".txt"}
		{"code/rs_tak_behav",".txt"}
//		{"code/alu_behav",".txt"}
//		{"code/opcodes_behav",".txt"}
//		{"code/pi_behav",".txt"}
//		{"code/count_behav",".txt"}
//		{"code/torture_behav",".txt"}
		;
		
		// fill Memory with 0s
		for(i=0;i<`TAILLE_CODE;i=i+1)
			UUT.mem[i]=0;
			
		// fill Memory with code
		$readmemh(file, UUT.mem);
		
`ifdef TRACE	
		// trace file
		mcd =  $fopen("trace.txt");
`endif
		
		clk = 1'b0;
	end

   	/* Vector of test bench */
	initial begin
//		   #(1220*`PERIODE_CLK) // 12.2 us
//		    #(350*`PERIODE_CLK) // 3.5 us
//		   #(30000*`PERIODE_CLK) // 50 us
//		#(1000000*`PERIODE_CLK) // 10 ms
		#(200000000*`PERIODE_CLK) // 20 ms

		$fclose(mcd);
		$stop;// Stop simulation
	end

`ifdef TRACE	
	/* Generating trace file */
	always@(UUT.pc)
	begin
		$fwrite(mcd,"%h ",UUT.pc);
		for (j=0;j<`dw;j=j+1)
			$fwrite(mcd,"%h ",UUT.r[j]);
		$fwrite(mcd,"\n");
	end
`endif

endmodule
