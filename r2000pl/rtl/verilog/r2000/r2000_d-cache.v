//////////////////////////////////////////////////////////////////////
////                                                              ////
//// r2000_cache.v				                                  ////
////                                                              ////
//// This file is part of the r2000pl Pipelined				      ////
////	opencores effort.										  ////
////	Simple Pipelined Mips 32 bits processor				      ////
//// <http://www.opencores.org/projects.cgi/web/r2000/>           ////
////                                                              ////
//// Module Description:                                          ////
//// Behavioural architecture of the cache for the r2000pl cpu.   ////
////	- MEMORY BUS											  ////
////		WishBone compatible									  ////
////	- CACHE SIZE											  ////
////		cache sizable										  ////
////    - MAPPING FUNCTION                                        ////
////		direct                                                ////
////		set-associative		                                  ////
////	- REPLACEMENT ALGORITHM                                   ////
////		random							                      ////
////	- WRITE POLICY		                                      ////
////		write through					                      ////
////		write back	                                          ////
////                                                              ////
//// To Do:                                                       ////
////	- write synthesizable cache                               ////
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
module  r2000_d_cache
/* --------------------------------------------------------------
	parameters
   ------------------- */
	#(
		parameter  [`WORDw-1:0]	cache_size		=	1024	,	//  in bytes, power of 2
		parameter  [`WORDw-1:0]	line_size		=	16		,	//  in bytes, power of 2
		parameter  [`WORDw-1:0]	associativity	=	2		,   //  1 = direct mapped
		parameter				write_strategy	=	1		,	//  write_through or copy_back
		parameter				tpd_clk_out		=	2			//	clock to output propagation delay
//		parameter  [`WORDw-1:0]	uncache_adr		=	40000	,	//  in bytes, power of 2
	)
	(
		en_i			,
		/* ~~~~~~~~~~~~~~~~~~ */
		/* Connections to CPU
		/* ~~~~~~~~~~~~~~~~~~ */
		cpu_addr_i		,	// address bus output            
		cpu_data_i		,	// input data bus
		cpu_data_o		,	// output data bus
		
		cpu_enable_i	,	// starts memory cycle           
		cpu_write_i		,	// selects read or write cycle
		cpu_width_i		,	// byte/halfword/word indicator  
		cpu_ready_o		,	// status from memory system     
		
		/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
		/* Connections to WishBone Bus
		/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
		ADR_O			,
		DAT_I			,
		DAT_O			,
		SEL_O			,
		WE_O			,
		            	
		STB_O			,
		ACK_I			,
		CYC_O			,
		            	
		ERR_I			,
		RTY_I			,
                    	
		clk_i			,	// Clock
		rst_i				// Reset
	);
		
//type strategy_type
	parameter				write_through	=	`CLEAR;
	parameter				copy_back		=	`SET;

//type mem_width
	parameter				width_byte		=	`BYTE;
	parameter				width_halfword	=	`HALF;
	parameter				width_word		=	`WORD;
 
/* --------------------------------------------------------------
	in, out declaration
   ------------------- */
//inputs/outputs
    input					clk_i;
    input					rst_i;
    
	input					en_i		;

    input	[`aw-1:0]		cpu_addr_i ;
    input	[`dw-1:0]		cpu_data_i ;
    output	[`dw-1:0]		cpu_data_o;
    input					cpu_enable_i;
    input					cpu_write_i;
    input	[1:0]			cpu_width_i;
    output					cpu_ready_o;

   	output	[`aw-1:0]		ADR_O;
	input	[`dw-1:0]		DAT_I;
	output	[`dw-1:0]		DAT_O;
	output	[`slw-1:0]		SEL_O;
	output					WE_O;
	output					CYC_O, STB_O;
	input					ACK_I, ERR_I, RTY_I;


	parameter				words_per_line = (line_size / (`WORDw/`BYTEw)); //constant : number of word (of 4 bytes)
	parameter				number_of_sets = ((cache_size / line_size) / associativity);//constant
 
	parameter				pEndian = `ENDIAN;
	parameter				DELAY = 5;
/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
    reg [0:(line_size)*`BYTEw - 1]	cache_data		[0:(number_of_sets - 1)][0:(associativity - 1)];
    reg [0:`dirty]					cache_status	[0:(number_of_sets - 1)][0:(associativity - 1)];
    
    integer cpu_address		;
    integer word_offset		;
    integer set_index		;
    integer cpu_tag			;
    integer entry_index		;
    
	reg								hit				;
    integer							next_replacement_entry_index = 0;
	reg								rCpuReady		=`CLEAR; 
	reg								cpu_ready_o		; 
    reg		[`dw-1:0]				cpu_data_o		;
    
	reg	[`aw-1:0]					ADR_O			;
	reg	[`dw-1:0]					DAT_O			;
	reg								CYC_O			,
									STB_O			;
	reg	[`slw-1:0]					SEL_O			;
	reg								WE_O			;
    integer							rd_cnt			;
	integer							wr_cnt			;

	integer init_set_index;
	integer init_entry_index;
    
	wire[1:0]						wEndian			;
/* --------------------------------------------------------------
	instances, statements
   ------------------- */
   
	// The traitement is Asynchronous
//	always @ (rst_i, cpu_addr_i, cpu_enable_i, en_i) begin
	always @(*) begin
		if (rst_i == `RESET_ON) begin
			//  reset: initialize outputs and the cache store valid bits
			rCpuReady	<= `CLEAR;
			cpu_ready_o = `SET;
			
			ADR_O		= 32'hxxxx_xxxx;
			DAT_O		= 32'hxxxx_xxxx;
			CYC_O		= 0;
			STB_O		= 0;
			SEL_O		= 4'hx;
			WE_O		= 1'hx;
			rd_cnt		= 0;
			wr_cnt		= 0;
			
			begin :Block_Init_Cache
				for (init_set_index=0;init_set_index<=(number_of_sets - 1);init_set_index=init_set_index+1) begin 
					begin :Block_Reset_Cache
						for (init_entry_index=0;init_entry_index<=(associativity - 1);init_entry_index=init_entry_index+1) begin 
							begin 
								cache_status[init_set_index][init_entry_index][`valid] = `CLEAR;
								cache_status[init_set_index][init_entry_index][`dirty] = `CLEAR;
							end
						end //for
					end //end Block Block_Reset_Cache
				end //for
           end //end Block Block_Init_Cache
		
		end else if((cpu_enable_i == `SET) && (en_i == `SET)) begin
			# DELAY // DELAY WAITING THE CORRECT ADRESS
			//  decode address
			cpu_address	= cpu_addr_i;
			word_offset	= ((cpu_address % line_size) / (`WORDw/`BYTEw));
			set_index	= ((cpu_address / line_size) % number_of_sets);
			cpu_tag		= ((cpu_address / line_size) / number_of_sets);
			
			//  check for hit
			hit			= `CLEAR;
			begin :Block_Find_Hit
				integer lookup_entry_index;
			    for (lookup_entry_index=0;lookup_entry_index<=(associativity - 1);lookup_entry_index=lookup_entry_index+1) begin 
			    	if ((cache_status[set_index][lookup_entry_index][`valid] & (cache_status[set_index][lookup_entry_index][`tag] == cpu_tag))) 
			        	begin 
			                hit = `SET;
			                entry_index = lookup_entry_index;
			                disable Block_Find_Hit;
			            end
			    end //for
			end //end Block_Find_Hit
			
			// proceed
			if (hit) 
				begin 
					if (cpu_write_i)begin 
						do_write_hit;end
					else 
						do_read_hit;
				end 
			else 
				begin 
					cpu_ready_o = #(tpd_clk_out)`CLEAR;
					if (cpu_write_i) 
						do_write_miss;
					else 
						do_read_miss;
						
					@(`CLOCK_EDGE clk_i );
					cpu_ready_o = #(tpd_clk_out)`SET;
				end 
		end //if
    end
    
	assign wEndian = cpu_addr_i[1:0] ^ {2{pEndian}};

	// ******************* //
	// Write Hit procedure //
	// ******************* //
	task do_write_hit;
	    begin 
			@(`CLOCK_REVER clk_i );
	        case (cpu_width_i)
	            width_word : 
	                    cache_data[set_index][entry_index][(`dw*word_offset) +: `dw] = cpu_data_i;
	            width_halfword : 
	                    if ((wEndian[1] == 1'b0))	// ms half word 
	                            cache_data[set_index][entry_index][(`dw*word_offset)+`dw/2	+: `dw/2] = cpu_data_i[15:0];
	                    else							// ls half word
	                            cache_data[set_index][entry_index][(`dw*word_offset) 		+: `dw/2] = cpu_data_i[15:0];
	            width_byte : 
	                    if ((wEndian[1] == 1'b0))	// ms half word 
	                        begin 
	                                if ((wEndian[0] == 1'b0))		// byte 0
	                                        cache_data[set_index][entry_index][(`dw*word_offset)+3*`dw/4 +:`dw/4] = cpu_data_i[7:0];
	                                else							// byte 1
	                                        cache_data[set_index][entry_index][(`dw*word_offset)+2*`dw/4 +:`dw/4] = cpu_data_i[7:0];
	                        end 
	                    else							// ls half word
	                        begin 
	                                if ((wEndian[0] == 1'b0))		// byte 2 
	                                        cache_data[set_index][entry_index][(`dw*word_offset)+`dw/4	+:`dw/4] = cpu_data_i[7:0];
	                                else							// byte 3 
	                                        cache_data[set_index][entry_index][(`dw*word_offset)		+:`dw/4] = cpu_data_i[7:0];
	                        end 
	        endcase
	        
	        if ((write_strategy == copy_back)) 
	                cache_status[set_index][entry_index][`dirty] = `SET;
	
			// if write_through cache, also update main memory
	        if ((write_strategy == write_through)) 
	                do_write_through;
	        else	//  copy_back cache 
	            begin 
	            end
	    end
	endtask
                                               
	// ****************** //
	// Read Hit procedure //
	// ****************** //
	task do_read_hit;
		begin 
			cpu_data_o	<= cache_data[set_index][entry_index][(`dw*word_offset) +: `dw];
		end
	endtask
                                               
	// ******************** //
	// Write Miss procedure //
	// ******************** //
	task do_write_miss;
		begin 
			// if write_through cache, just update main memory
			if ((write_strategy == write_through)) 
				do_write_through;
			else begin	//  copy_back cache 
				replace_line;
				if ((rst_i == `SET)) 
					disable do_write_miss;
				do_write_hit;
			end
		end
	endtask
                                               
	// ******************* //
	// Read Miss procedure //
	// ******************* //
	task do_read_miss;
		begin 
			replace_line;
			if ((rst_i == `SET)) 
				disable do_read_miss;
			do_read_hit;
		end
	endtask
                                               
	task do_write_through;
	    begin 
	
			wb_wr1(cpu_addr_i, 4'hf, cpu_data_i);
	        rCpuReady	<= #(tpd_clk_out) `SET;//mem_ready;
	        
//			@(`CLOCK_REVER clk_i );
			@(`CLOCK_EDGE clk_i );
	        
	        rCpuReady	<= #(tpd_clk_out) `CLEAR;
	    end
	endtask
                                               
	task replace_line;
	    begin
	    	//  first chose an entry using "random" number generator 
	        entry_index = next_replacement_entry_index;
	        next_replacement_entry_index = ((next_replacement_entry_index + 1) % associativity);
	        
			if (cache_status[set_index][entry_index][`dirty]) 
				copy_back_line;
			fetch_line;
	    end
	endtask
                                               
	task copy_back_line;
	    
	    integer next_address;
	    integer old_word_offset;
	
	    begin 
	        next_address = (((cache_status[set_index][entry_index][`tag] * number_of_sets) + set_index) * line_size);
			wb_wr_mult(next_address, 4'hf, 0, words_per_line);
	        cache_status[set_index][entry_index][`dirty] = `CLEAR;
	    end
	endtask

	task fetch_line;
	    
	    integer next_address;
	    integer new_word_offset;
	
	    begin 
	        next_address = ((cpu_address / line_size) * line_size);
			wb_rd_mult(next_address, 4'hf, 0 ,words_per_line);
	        
	        cache_status[set_index][entry_index][`dirty]	= `CLEAR;
	        cache_status[set_index][entry_index][`valid]	= `SET;
	        cache_status[set_index][entry_index][`tag]		= cpu_tag;
	        
	    end
	endtask
                                                   
	/*======================================================================================================================================================*/
	/*	WishBone compatible bus functions						*/
	/*======================================================================================================================================================*/
////////////////////////////////////////////////////////////////////
//
// Write 1 Word Task
//
	task wb_wr1;
	input	[`aw-1:0]	a;
	input	[`slw-1:0]	s;
	input	[`dw-1:0]	d;
	
		begin
		
			@(`CLOCK_EDGE clk_i);
			#1;
			ADR_O		= a;
			DAT_O		= d;
			CYC_O		= 1;
			STB_O		= 1;
			WE_O		= 1;
			SEL_O		= s;
			
			@(`CLOCK_EDGE clk_i);
			while(~ACK_I & ~ERR_I)	@(`CLOCK_EDGE clk_i);
			#1;
			CYC_O		= 0;
			STB_O		= 0;
			ADR_O		= 32'hxxxx_xxxx;
			DAT_O		= 32'hxxxx_xxxx;
			WE_O		= 1'hx;
			SEL_O		= 4'hx;
		
		end
	endtask

////////////////////////////////////////////////////////////////////
//
// Write multi Word Task
//
	task wb_wr_mult;
	input	[`aw-1:0]	a;
	input	[`slw-1:0]	s;
	input				delay;
	input				count;
	
	integer				delay;
	integer				count;
	integer				n;
	
		begin
		
			@(`CLOCK_EDGE clk_i);
			#1;
			CYC_O = 1;
			
			for(n=0;n<count;n=n+1) begin
				repeat(delay) begin
					@(`CLOCK_EDGE clk_i);
					#1;
				end
				ADR_O		= a + (n*4);
				//DAT_O		= wr_mem[n + wr_cnt];
				DAT_O		= cache_data[set_index][entry_index][(`dw*n) +: `dw];
				STB_O		= 1;
				WE_O		= 1;
				SEL_O		= s;
				if(n!=0)	@(`CLOCK_EDGE clk_i);
				while(~ACK_I & ~ERR_I)	@(`CLOCK_EDGE clk_i);
				#2;
				STB_O		= 0;
				WE_O		= 1'bx;
				SEL_O		= 4'hx;
				DAT_O		= 32'hxxxx_xxxx;
				ADR_O		= 32'hxxxx_xxxx;
			end
			
			CYC_O=0;
			ADR_O = 32'hxxxx_xxxx;
			
			wr_cnt = wr_cnt + count;
		end
	endtask

////////////////////////////////////////////////////////////////////
//
// Read multi Word Task
//
	task wb_rd_mult;
	input	[`aw-1:0]	a;
	input	[`slw-1:0]	s;
	input		delay;
	input		count;
	
	integer		delay;
	integer		count;
	integer		n;
	
		begin
		
			@(`CLOCK_EDGE clk_i);
			#1;
			CYC_O = 1;
			WE_O = 0;
			SEL_O = s;
			repeat(delay)	@(`CLOCK_EDGE clk_i);
			
			for(n=0;n<count-1;n=n+1)begin
				ADR_O = a + (n*4);
				STB_O = 1;
				while(~ACK_I & ~ERR_I)	@(`CLOCK_EDGE clk_i);
				//rd_mem[n + rd_cnt] = DAT_I;
				cache_data[set_index][entry_index][(`dw*n) +: `dw] = DAT_I;
				#2;
				STB_O=0;
				WE_O = 1'hx;
				SEL_O = 4'hx;
				ADR_O = 32'hxxxx_xxxx;
				repeat(delay)begin
					@(`CLOCK_EDGE clk_i);
					#1;
				end
				WE_O = 0;
				SEL_O = s;
			end
			
			ADR_O = a+(n*4);
			STB_O = 1;
			@(`CLOCK_EDGE clk_i);
			while(~ACK_I & ~ERR_I)	@(`CLOCK_EDGE clk_i);
			//rd_mem[n + rd_cnt] = DAT_I;
			cache_data[set_index][entry_index][(`dw*n) +: `dw] = DAT_I;
			#1;
			STB_O=0;
			CYC_O=0;
			WE_O = 1'hx;
			SEL_O = 4'hx;
			ADR_O = 32'hxxxx_xxxx;
			
			rd_cnt = rd_cnt + count;
		end
	endtask

endmodule
//////////////////////////////////////////////////////////////////////////
