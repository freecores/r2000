/*=============================================================
	project		:	SiCyMips
	description	:	Simple Single-cycle Mips 32 bits processor
=============================================================
	file name	:	tb_Divisor.v
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
module	tb_Divisor;

/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */
	reg					clk, rst;
	reg [`dw-1:0]		dividend, divider;
	reg         		sign;

	reg         		mult_div, start;
	reg [`dw-1:0]		datain;
	reg         		hiw=`LOW, low=`LOW;
	
	wire [`dw-1:0]		quotient, remainder;
	wire        		ready, write;
	
/* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */

	/* Module under test instance */
	r2000_divisor UUT
	(
		.clk_i		(clk),
		.rst_i		(rst),
		.start_i	(),
		
		.sign_i		(sign),
		.dividend_i	(dividend),
		.divider_i	(divider),
		
		.quotient_o	(quotient),
		.remainder_o(remainder),
		.write_o	(write),
		.ready_o	(ready)
	);

	/* Clock */
	always #(`PERIODE_CLK/2) clk = ~clk; 

	/* Vector of test bench */
	initial begin

		/* The Multiplier */
		mult_div = 1; 
		sign = 0; dividend = 56 ; divider = 89;
		@(posedge clk) start = 1; #(1*`PERIODE_CLK)	 start = 0;	 
		@(posedge ready)
		
		sign = 0; dividend = 32'h12345678 ; divider = 32'h12345678;
		#(20*`PERIODE_CLK)start = 1; #(1*`PERIODE_CLK) start = 0;
		@(posedge ready)
			
		sign = 0; dividend = 32'h82345678 ; divider = 32'h12345678;
		#(2*`PERIODE_CLK)start = 1; #(1*`PERIODE_CLK) start = 0;
		@(posedge ready)
			
		sign = 0; dividend = 32'hfffffffb ; divider = 32'h12345678;
		#(2*`PERIODE_CLK)start = 1; #(1*`PERIODE_CLK) start = 0;
		@(posedge ready)
			
		sign = 1; dividend = 32'hfffffffb ; divider = 32'h12345678;
		#(2*`PERIODE_CLK)start = 1; #(1*`PERIODE_CLK) start = 0;
		@(posedge ready)
			
		sign = 0; dividend = 32'h12345678 ; divider = 32'hfffffffb;
		#(2*`PERIODE_CLK)start = 1; #(1*`PERIODE_CLK) start = 0;
		@(posedge ready)
			
		sign = 1; dividend = 32'h12345678 ; divider = 32'hfffffffb;
		#(2*`PERIODE_CLK)start = 1; #(1*`PERIODE_CLK) start = 0;
		
		/* The Divisor */		 
		mult_div = 0; 
		sign = 0; dividend = 32'h56 ; divider = 32'h89;
		@(posedge clk) start = 1; #(1*`PERIODE_CLK)	 start = 0;	 		 
		@(posedge ready)
		
		sign = 0; dividend = 32'h456 ; divider = 32'h23;
			#(1*`PERIODE_CLK)start = 1; #(1*`PERIODE_CLK) start = 0;
		@(posedge ready)
		
		sign = 0; dividend = 32'h456 ; divider = 32'hfffffffb;
			#(1*`PERIODE_CLK)start = 1; #(1*`PERIODE_CLK) start = 0;
		@(posedge ready)
		
		sign = 1; dividend = 32'h456 ; divider = 32'hfffffffb;
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