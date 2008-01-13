/*=============================================================
	project		:	SiCyMips
	description	:	Simple Single-cycle Mips 32 bits processor
=============================================================
	file name	:	tb_Barrel.v
=============================================================
	designer	:	Abdallah Meziti El-Ibrahimi
	mail 		: 	abdallah.meziti@gmail.com
=============================================================*/
/*	description :	test bench of :n bit logical left/right Barrel shifter			*/
/*	===============================================================================	*/
`timescale 100ns/1ns

`include "define.h"

/* ================= */
/* module definition */
/* ================= */
module	tb_Barrel;

/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */
	reg [`dw-1:0]		a;
	reg [4:0]			sh;
	reg 				lr, la;

	wire	[`dw-1:0]	g;

/* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */

	/* Module under test instance */
	r2000_shifter Barrel_UT
	(
		/* Input */
		.A_i(a),		// Operand A
		.SH_i(sh),	// Shift amount
		.LR_i(lr),	// Left/Right
		.LA_i(la),	// Logic/Arithmetic
		/* Output */
		.G_o(g)		// Out shifted
	);

	/* Vector of test bench */
	initial begin
			a = 32'h8A5F ; 		sh = 0 ;	lr = 0;la = 1;
		#1	a = 32'h8A5F ; 		sh = 1 ;	lr = 0;la = 1;
		#1	a = 32'h8A5F ; 		sh = 1 ;	lr = 1;la = 1;
		#1	a = 32'h8A5F ; 		sh = 2 ;	lr = 0;la = 1;
		#1	a = 32'h8A5F ; 		sh = 2 ;	lr = 1;la = 1;
		#1	a = 32'h7E93C2A1 ;	sh = 12 ;	lr = 1;la = 1;
		#1	a = 32'h7E93C2A1 ;	sh = 15 ;	lr = 0;la = 1;
		#1	a = 32'h7E93C2A1 ;	sh = 29 ;	lr = 1;la = 1;
		#1	a = 32'h8E93C2A1 ;	sh = 5 ;	lr = 1;la = 1;
		#1	a = 32'h8E93C2A1 ;	sh = 5 ;	lr = 0;la = 1;
		#1	a = 32'h8E93C2A1 ;	sh = 5 ;	lr = 0;la = 0;
	end
	
	/* Monitor visualization */
	initial begin
		$monitor("Time=%0d Shift Amount= %h | Left/Right=%h | Logic/Arith=%h a=%h | g=%h", $time,sh , lr, la, a, g);
	end

endmodule