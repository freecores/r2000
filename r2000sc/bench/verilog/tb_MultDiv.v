/*=============================================================
	project		:	SiCyMips
	description	:	Simple Single-cycle Mips 32 bits processor
=============================================================
	file name	:	tb_MultDiv.v
=============================================================
	designer	:	Abdallah Meziti El-Ibrahimi
	mail 		: 	abdallah.meziti@gmail.com
=============================================================*/
/*	description :	test bench of :n bit Multiplier/Divisor	 */
/*	======================================================== */
`timescale 100ns/1ns
`include "define.h"

`define PERIODE_CLK 10

/* ================= */
/* module definition */
/* ================= */
module	tb_MultDiv;

/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */
	reg					clk, rst;
	reg [`dw-1:0]		operand1, operand2;
	reg         		sign;

	reg         		mult_div, start;
	reg [`dw-1:0]		datain;
	reg         		hiw=`LOW, low=`LOW;
	
	wire [`dw-1:0]		hi, lo;
	wire        		ready;
	
/* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */

	/* Module under test instance */
	r2000_multdiv UUT
	(
		/* Input */
		.clk_i			(clk),		// clock
		.rst_i			(rst)		,		// rst
		.operand1_i		(operand1),	// first operand
		.operand2_i		(operand2),	// second operand
		.sign_i			(sign),		// un/signed
		.datain_i		(datain),	// data input
		.mult_div_i		(mult_div),	// choice of the operation
		.start_i		(start),	// start the operation
		.hiw_i			(hiw),		// hi write
		.low_i			(low),		// lo write
		/* Output */
		.hi_o			(hi),	// hi result
		.lo_o			(lo),	// lo result
		.ready_o		(ready)	// end of the operation
	); 

	/* Clock */
	always #(`PERIODE_CLK/2) clk = ~clk; 

	/* Vector of test bench */
	initial begin

		/* The Multiplier */
		mult_div = 1; 
		sign = 0; operand1 = 56 ; operand2 = 89;
		@(posedge clk) start = 1; #(1*`PERIODE_CLK)	 start = 0;	 
		@(posedge ready)
		
		sign = 0; operand1 = 32'h12345678 ; operand2 = 32'h12345678;
		#(20*`PERIODE_CLK)start = 1; #(1*`PERIODE_CLK) start = 0;
		@(posedge ready)
			
		sign = 0; operand1 = 32'h82345678 ; operand2 = 32'h12345678;
		#(2*`PERIODE_CLK)start = 1; #(1*`PERIODE_CLK) start = 0;
		@(posedge ready)
			
		sign = 0; operand1 = 32'hfffffffb ; operand2 = 32'h12345678;
		#(2*`PERIODE_CLK)start = 1; #(1*`PERIODE_CLK) start = 0;
		@(posedge ready)
			
		sign = 1; operand1 = 32'hfffffffb ; operand2 = 32'h12345678;
		#(2*`PERIODE_CLK)start = 1; #(1*`PERIODE_CLK) start = 0;
		@(posedge ready)
			
		sign = 0; operand1 = 32'h12345678 ; operand2 = 32'hfffffffb;
		#(2*`PERIODE_CLK)start = 1; #(1*`PERIODE_CLK) start = 0;
		@(posedge ready)
			
		sign = 1; operand1 = 32'h12345678 ; operand2 = 32'hfffffffb;
		#(2*`PERIODE_CLK)start = 1; #(1*`PERIODE_CLK) start = 0;
		
		/* The Divisor */		 
		mult_div = 0; 
		sign = 0; operand1 = 32'h56 ; operand2 = 32'h89;
		@(posedge clk) start = 1; #(1*`PERIODE_CLK)	 start = 0;	 		 
		@(posedge ready)
		
		sign = 0; operand1 = 32'h456 ; operand2 = 32'h23;
			#(1*`PERIODE_CLK)start = 1; #(1*`PERIODE_CLK) start = 0;
		@(posedge ready)
		
		sign = 0; operand1 = 32'h456 ; operand2 = 32'hfffffffb;
			#(1*`PERIODE_CLK)start = 1; #(1*`PERIODE_CLK) start = 0;
		@(posedge ready)
		
		sign = 1; operand1 = 32'h456 ; operand2 = 32'hfffffffb;
			#(1*`PERIODE_CLK)start = 1; #(1*`PERIODE_CLK) start = 0;
		
		@(posedge ready)#(2*`PERIODE_CLK) $stop;
	end
	
   	/* Vector of test bench */
	initial begin
		clk = 0; rst = 1; #(`PERIODE_CLK) rst = 0;
		#(1000*`PERIODE_CLK) 
		
		$stop;// Stop simulation
	end
	

endmodule