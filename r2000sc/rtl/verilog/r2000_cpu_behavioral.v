//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_cpu_behavioral.v The behavioral description of the cpu ////
////                                                              ////
//// This file is part of the r2000sc SingleCycle				  ////
////	opencores effort.										  ////
////	Simple Single-cycle Mips 32 bits processor				  ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// this is the behavioral description of the r2000sc.           ////
////	- Execute the mips-I instruction excepted those with CP0  ////
////	- CP0 not implemented                                     ////
////	- Implement debugger function programmed with PLI         ////
////		- can stop the cpu at certain PC value (breakpoint)   ////
////    	- can dump desired C variables or array from memory   ////
////		- the variables are listed in WatchVar.txt file       ////
////		- the file contain the name,start address,length,type ////
////		- look at r2000sc\bench\pli\mem for the PLI source    ////
////                                                              ////
//// To Do:                                                       ////
////	- test more the interlock                                 ////
//// 	- implement the CP0                                       ////
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

//--------------- C O N F I G U R A T I O N ---------------
`define BIG_ENDIAN		// Type of memory. Defined: Big endian; Undefined: little endian
//`define ERROR_STOP		// Stop on error. when trying to execute undefined opcode
//`define INTERLOCK		// Interlock. simulate the interlock du to reel mult/div operation. still some bugs
//`define DELAY_SLOT_b	// Delay slot on branch. simulate the reel delay slot on branch
`define BREAKPOINT		// Breakpoint. use the breakpoint function with PLI functions


`ifdef DELAY_SLOT_b
	`define PC_inc	8
`else
	`define PC_inc	4
`endif

//--------------- M I P S I S A . V ---------------

//----- m o d u l e M I P S ( ) -----
module r2000_cpu_behavioral (clk);

/* --------------------------------------------------------------
	parameters
   ------------------- */
	parameter dw = 32;

/* -------------------------------------------------------------- */
/* in, out declaration */
/* ------------------- */
	input	clk;
		 
/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
   
//----- R e g i s t e r s -----
	reg [dw-1:0]	pc			;	// -- Program counter
	reg [2:0]		mux_pc		;	// -- Type of Branch
	reg [dw-1:0]	ir			;	// -- Instruction Register
	reg [dw-1:0]	hi, lo		;	// -- Multyply/Divide Registers
	reg run						;	// -- Run flag
`ifdef BREAKPOINT
	reg	[dw-1:0]	breakpoint	;	// -- Breakpoint register
	reg				break_en=1	;	// -- Breakpoint enable
`endif
//----------- C P 0 -----------
	reg	[dw-1:0]	STATUS		,	// -- CP0 STATUS REGISTER
					CAUSE		,	// -- CP0 CAUSE REGISTER
					EPC			;	// -- CP0 EPC REGISTER
//----- M e m o r i e s -----

	reg [7:0] mem [0:`TAILLE_CODE-1];	// -- Byte Addressable Data Memory
	reg signed [dw-1:0] r [0:31];		// -- Signed General Register File

//----- W i r e s -----

	wire [5:0]		op			= ir[31:26];	// -- Opcode
	wire [4:0]		rs			= ir[25:21];	// -- rs register field
	wire [4:0]		rt			= ir[20:16];	// -- rt register field
	wire [4:0]		rd			= ir[15:11];	// -- rd register field
	wire [4:0]		shamt		= ir[10:6];		// -- Shift amount
	wire [5:0]		funct		= ir[5:0];		// -- function field (R-format)
	wire [15:0]		addr		= ir[15:0];		// -- Address field (I-format)
	wire [25:0]		targ		= ir[25:0];		// -- Target address field (J-Format)

	wire signed[dw-1:0]	se		= {{16{addr[15]}},	(addr)};		// -- Sign extended
	wire [dw-1:0]	ze			= {{16{1'b0}},		(addr)};		// -- Zero extended
	wire [15:0] 	im			= ir[15:0];
	wire [15:0] 	offset		= ir[15:0];
	wire [dw-1:0]	target		= { {14 {offset[15]}}, offset, 2'b0 };
	wire [dw-1:0]	targetj		= { pc[31:28], targ, 2'b0 };

`ifdef INTERLOCK
//----- M u l t / D i v  U n i t -----
	reg				ready		;	// simulate the delay of mult/div operation
	reg				interlock	;	// interlock the processor when read hi, lo and mult/div not finished
	reg [5:0]		count		;	// simulate the time of mult/div operation 32 clock
	reg				start		;	// 
`endif
	
//----- I n t e g e r ----
	reg	[dw-1:0]	temp		,
					temp1		;
	integer			i			,
					adr			;
	
	initial
	begin
		for (i=0; i<dw; i=i+1) r[i] = 0;
		pc = 0;	ir = 0;
`ifdef INTERLOCK
		ready = 1;
`endif
	end	

	initial
	begin
		run = 1;
		while(run)
		begin
			r[`zer0] = 0;
			@(`CLOCK_EDGE clk)
			begin
`ifdef BREAKPOINT
				// -------------------------- //
				// -- Brekpoint traitement -- //
				// -------------------------- //
				if (break_en)
					if (breakpoint == pc)begin
						$watch_data_hex(mem[0]);// PLI function that dump desired varible from memory
						breakpoint = pc;		// Put simulator breakpoint here
					end
`endif
				// ----------------------- //
				// -- Fetch instruction -- //
				// ----------------------- //
`ifdef INTERLOCK
				if (interlock)begin
					ir = read_mem(pc-4);
					mux_pc = `bra_stp;	// -- No Branch	
				end else begin
					ir = read_mem(pc);
					mux_pc = `bra_non;	// -- No Branch	
				end
`else
					ir = read_mem(pc);
					mux_pc = `bra_non;	// -- No Branch	
`endif
				// ------------------------- //
				// -- Execute instruction -- //
				// ------------------------- //
				case (op)
					`j:		mux_pc = `bra_imm;
					`jal:	{ mux_pc, r[`ra] } = {`bra_imm, pc + `PC_inc};//+ 4};
					`beq:	if (r[rs]==r[rt])	mux_pc = `bra_rel;
					`bne:	if (r[rs]!=r[rt])	mux_pc = `bra_rel;
					`blez:	if (r[rs]<= 0)		mux_pc = `bra_rel;
					`bgtz:	if (r[rs]> 0)		mux_pc = `bra_rel;
					`addi:	if (rt != `zer0)	r[rt] = r[rs] + se;
					`addiu:	if (rt != `zer0)	r[rt] = r[rs] + se;
					`slti:	if (rt != `zer0)	r[rt] = (r[rs] < se) ? 1 : 0;
					`sltiu:	if (rt != `zer0)	begin // r[rs], se: unsigned
													temp = r[rs]; temp1 = se;
													r[rt] = (temp < temp1) ? 1 : 0;
												end
					`andi:	if (rt != `zer0)	r[rt] = r[rs] & ze;
					`ori:	if (rt != `zer0)	r[rt] = r[rs] | ze;
					`xori:	if (rt != `zer0)	r[rt] = r[rs] ^ ze;
					`lui:	if (rt != `zer0)	r[rt] = {im, {16{1'b0}}};
					`lb:	if (rt != `zer0)	begin temp = read_mem(r[rs]+se); r[rt] = { {24{temp[31]}},	temp[31:24]}; end
					`lbu:	if (rt != `zer0)	begin temp = read_mem(r[rs]+se); r[rt] = { {24{1'b0}},		temp[31:24]}; end
					`sb:	write_mem(r[rs]+se, {r[rt][7:0], {24{1'b0}}}, `BYTE);
`ifdef BIG_ENDIAN
					`lh:	if (rt != `zer0)	begin temp = read_mem(r[rs]+se); r[rt] = { {16{temp[31]}}, temp[31:16]}; end
					`lwl:	if (rt != `zer0) begin
								temp = r[rs]+se;
								case (temp[2:0])// % 4
									0:	r[rt]	   = read_mem(r[rs]+se);
									1:	begin temp = read_mem(r[rs]+se); r[rt][31:8] = temp[31:8];   end
									2:	begin temp = read_mem(r[rs]+se); r[rt][31:16] = temp[31:16]; end
									3:	begin temp = read_mem(r[rs]+se); r[rt][31:24] = temp[31:24]; end
								endcase
							end
					`lw:	if (rt != `zer0)	r[rt] = read_mem(r[rs]+se);
					`lhu:	if (rt != `zer0)	begin temp = read_mem(r[rs]+se); r[rt] = { {16{1'b0}}, temp[31:16]}; end
					`lwr:	if (rt != `zer0) begin
								temp = r[rs]+se;
								case (temp[2:0])// % 4
									0:	begin temp = read_mem(r[rs]+se); r[rt][7:0]  = temp[31:8];  end
									1:	begin temp = read_mem(r[rs]+se); r[rt][15:0] = temp[31:16]; end
									2:	begin temp = read_mem(r[rs]+se); r[rt][23:0] = temp[31:24];  end
									3:	r[rt]	   = read_mem(r[rs]+se);
								endcase
							end
					`sh:	write_mem(r[rs]+se, {r[rt][15:0], {16{1'b0}}}, `HALF);
`else
					`lh:	if (rt != `zer0)	begin temp = read_mem(r[rs]+se); r[rt] = { {16{temp[15]}}, temp[15:0]}; end
					`lw:	if (rt != `zer0)	r[rt] = read_mem(r[rs]+se);
					`lhu:	if (rt != `zer0)	begin temp = read_mem(r[rs]+se); r[rt] = { {16{1'b0}}, temp[15:0]}; end
					`sh:	write_mem(r[rs]+se, {{16{1'b0}}, r[rt][15:0]}, `HALF);
`endif
					`swl:	$display("\n CPU:pc:%x | swl not implemented",pc);
					`sw:	write_mem(r[rs]+se, r[rt], `WORD);
					`swr:	$display("\n CPU:pc:%x | swr not implemented",pc);
					
					/* ******* */
					/* SPECIAL */
					/* ******* */
					`special:	case (funct)
									`sll:	if (rd != `zer0)	r[rd] = r[rt] << shamt;
									`srl:	if (rd != `zer0)	r[rd] = r[rt] >> shamt;
									`sra:	if (rd != `zer0)begin
												temp = r[rt];
												for(i=0;i<shamt;i=i+1)
													temp = {r[rt][31],temp[31:1]};
												r[rd] = temp;
											end
									`sllv:	if (rd != `zer0)	r[rd] = r[rt] << r[rs][4:0];
									`srlv:	if (rd != `zer0)	r[rd] = r[rt] >> r[rs][4:0];
									`srav:	if (rd != `zer0)begin
												temp = r[rt];
												for(i=0;i<r[rs][4:0];i=i+1)
													temp = {r[rt][31],temp[31:1]};
												r[rd] = temp;
											end
									`jr:	mux_pc = `bra_reg;
									`jalr:	{mux_pc, r[rd]} = {`bra_reg, pc + `PC_inc};//4};
									`syscall:
												case (r[`v0])
													1:$write("%d",r[`a0]);	// print an integer
													2:$write("%f",r[`a0]);	// print an float
													3:$write("%f",r[`a0]);	// print an double
													4:	begin				// print a string
															for(i=r[`a0];mem[i];i=i+1)
																$write("%c",mem[i]);
														end
													10:	begin				// exit
															run = 0;
															$stop;
														end
													default:	begin
																	$display("\n CPU:pc:%x | syscall bad ",pc);
`ifdef ERROR_STOP
																	$stop;
`endif
																end
												endcase
									`break: $display("\n CPU:pc:%x | break not implemented",pc);	
									`mfhi:	if (rd != `zer0)	begin
`ifdef INTERLOCK
																	if (!ready)begin	// Wait Mult/Div finish
																		interlock = 1;
																		mux_pc = `bra_stp;
																	end else begin
																		interlock = 0;
																		r[rd] = hi;
																		mux_pc = `bra_non;
																	end
`else
																	r[rd] = hi;
`endif
																end
									`mthi:	if (rd == `zer0)	hi = r[rs];
									`mflo:	if (rd != `zer0)	begin
`ifdef INTERLOCK
																	if (!ready)begin	// Wait Mult/Div finish
																		interlock = 1;
																		mux_pc = `bra_stp;
																	end else begin
																		interlock = 0;
																		mux_pc = `bra_non;
																		r[rd] = lo;
																	end
`else
																		r[rd] = lo;
`endif
																end
									`mtlo:	if (rd == `zer0)	lo = r[rs];
									`mult:	if (rd == `zer0)	{hi, lo} = r[rs] * r[rt];
									`multu:	if (rd == `zer0)	begin // r[rs], r[rt]: unsigned
																	temp = r[rs]; temp1 = r[rt];
																	{hi, lo} = temp * temp1;
																end
									`div:	if (rd == `zer0)	{hi, lo} = {(r[rs] % r[rt]), (r[rs] / r[rt])};
									`divu:	if (rd == `zer0)	begin // r[rs], r[rt]: unsigned
																	temp = r[rs]; temp1 = r[rt];
																	{hi, lo} = {(temp % temp1), (temp / temp1)};
																end
									`add:	if (rd != `zer0)	r[rd] =   r[rs] + r[rt];
									`addu:	if (rd != `zer0)	r[rd] =   r[rs] + r[rt];
									`sub:	if (rd != `zer0)	r[rd] =   r[rs] - r[rt];
									`subu:	if (rd != `zer0)	r[rd] =   r[rs] - r[rt];
									`and:	if (rd != `zer0)	r[rd] =   r[rs] & r[rt];
									`or:	if (rd != `zer0)	r[rd] =   r[rs] | r[rt];
									`xor:	if (rd != `zer0)	r[rd] =   r[rs] ^ r[rt];
									`nor:	if (rd != `zer0)	r[rd] = ~(r[rs] | r[rt]);
									`slt:	if (rd != `zer0)	r[rd] =  (r[rs] < r[rt]) ? 1 : 0;
									`sltu:	if (rd != `zer0)	begin // r[rs], r[rt]: unsigned
																	temp = r[rs]; temp1 = r[rt];
																	r[rd] =  (temp < temp1) ? 1 : 0;
																end

									default: begin 
												$display("\n CPU:pc:%x | bad funct",pc);
`ifdef ERROR_STOP
												$stop;
`endif
											end
								endcase
					/* ****** */
					/* REGIMM */
					/* ****** */
					`regimm:	case (rt)
									`bltz:		if(r[rs] < 0)	mux_pc = `bra_rel;
									`bgez:		if(r[rs] >= 0)	mux_pc = `bra_rel;
									`bltzal:	if(r[rs] < 0)	{mux_pc, r[`ra]}	= {`bra_rel, (pc + `PC_inc)};//4)};
									`bgezal:	if(r[rs] >= 0)	{mux_pc, r[`ra]}	= {`bra_rel, (pc + `PC_inc)};//4)};
									default: begin
												$display("\n CPU:pc:%x | bad regimm",pc);
`ifdef ERROR_STOP
												$stop;
`endif
											end
								endcase
							
					/* ****** */
					/* Extrat */
					/* ****** */
					`halt:	run = 0;
					default: begin
								$display("\n CPU:pc:%x | bad opcode:%x",pc, ir);
`ifdef ERROR_STOP
								$stop;
`endif
							end

				endcase//op
				
				// --------------- //
				// -- UPDATE PC -- //
				// --------------- //
				case (mux_pc)
					`bra_imm:	pc = targetj;
					`bra_reg:	pc = r[rs]; 		// Carefull that the register is not modified
					`bra_rel:	pc = pc + target;
`ifdef INTERLOCK
					`bra_stp:	pc = pc;			// interlock stop the pc
`endif
					default:	pc = pc + 4;
				endcase
			end//posedge
		end//while
	end//initial
	
`ifdef INTERLOCK
	// Simulate the latency of mult/div
	always@(`CLOCK_EDGE clk)
	begin
		if (ready && ((op==`special)&&((funct==`mult)||(funct==`multu)||(funct==`div)||(funct==`divu))))
		begin
			ready = 0;
			count = 0;
			start = 1;
		end if (start) begin
			if (count == 32)begin
				start = 0;
				ready = 1;
			end else
				count = count + 1;
		end
	end
`endif

	
	// Read a 32-bit word from memory starting at the address given.
	// This read operation assumes a big-endian format.
	function [dw-1:0] read_mem;
		input [dw-1:0]	addr;		// the address from which to read
		
			if(addr == `UART_READ)	// Read from uart
				read_mem = 0;
			else if(addr == `IRQ_STATUS)				// Read uart status
				read_mem = `IRQ_UART_WRITE_AVAILABLE;	// Write available
			else
				begin
					if ((32'h10000000 <= addr) && (addr < 32'h10000000 + `TAILLE_CODE/4) )
						addr = addr - 32'h10000000;
						
					read_mem = {mem[addr],mem[addr+1],mem[addr+2],mem[addr+3]};
				end
	
	endfunction	// read_mem

	// Write the given value to the given address in big-endian order.
	task write_mem; 
		input [dw-1:0]	addr;	// Address to which to write.
		input [dw-1:0]	data;	// The data to write.
		input [1:0]		taille;
	
		begin
			if(addr == `UART_WRITE)// Print to uart
				case (taille)
					`BYTE:	$write("%s",data[31:24]);
					`HALF:	$write("%s",data[23:16]);
					`WORD:	$write("%s",data[7:0]);
				endcase
			else
				begin
					if ((32'h10000000 <= addr) && (addr < 32'h10000000 + `TAILLE_CODE/4) )
						addr = addr - 32'h10000000;

					case (taille)
						`BYTE:	mem[addr]										= data[31:24];
						`HALF:	{mem[addr],mem[addr+1]}							= data[31:16];
						`WORD:	{mem[addr],mem[addr+1],mem[addr+2],mem[addr+3]}	= data;
					endcase
				end
		end
	endtask// write_mem
endmodule