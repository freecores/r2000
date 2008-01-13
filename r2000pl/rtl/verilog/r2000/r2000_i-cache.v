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
module  r2000_i_cache
/* --------------------------------------------------------------
	parameters
   ------------------- */
	#(
		parameter  [`WORDw-1:0]	cache_size		=	1024	,	//  in bytes, power of 2
		parameter  [`WORDw-1:0]	line_size		=	16		,	//  in bytes, power of 2
		parameter  [`WORDw-1:0]	associativity	=	2		,   //  1 = direct mapped
		parameter				tpd_clk_out		=	2			//	clock to output propagation delay
	)
	(
		/* ~~~~~~~~~~~~~~~~~~ */
		/* Connections to CPU
		/* ~~~~~~~~~~~~~~~~~~ */
		cpu_addr_i		,	// address bus output            
		cpu_data_o		,	// output data bus
		
		cpu_enable_i	,	// starts memory cycle           
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
    
    input	[`aw-1:0]		cpu_addr_i ;
    output	[`dw-1:0]		cpu_data_o;
    input					cpu_enable_i;
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
 
/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
    reg [0:(line_size)*`BYTEw - 1]	cache_data		[0:(number_of_sets - 1)][0:(associativity - 1)];
    reg [0:`valid]					cache_status	[0:(number_of_sets - 1)][0:(associativity - 1)];
    
    integer cpu_address		;
    integer word_offset		;
    integer set_index		;
    integer cpu_tag			;
    integer entry_index		;
    
	reg								hit				;
    integer							next_replacement_entry_index = 0;
	reg								cpu_ready_o		=`CLEAR; 
    reg		[`dw-1:0]				cpu_data_o		;
    
	reg	[`aw-1:0]					ADR_O			;
	reg	[`dw-1:0]					DAT_O			;
	reg								CYC_O			,
									STB_O			;
	reg	[`slw-1:0]					SEL_O			;
	reg								WE_O			;
    integer							rd_cnt			;
	integer							wr_cnt			;

    
/* --------------------------------------------------------------
	instances, statements
   ------------------- */
	always begin
		begin
			//  reset: initialize outputs and the cache store valid bits
			cpu_ready_o	<= `CLEAR;
			
			ADR_O		= 32'hxxxx_xxxx;
			DAT_O		= 32'hxxxx_xxxx;
			CYC_O		= 0;
			STB_O		= 0;
			SEL_O		= 4'hx;
			WE_O		= 1'hx;
			rd_cnt		= 0;
			wr_cnt		= 0;
			
			begin :Block_Init_Cache
				integer init_set_index;
				for (init_set_index=0;init_set_index<=(number_of_sets - 1);init_set_index=init_set_index+1) begin 
					begin :Block_Reset_Cache
						integer init_entry_index;
						for (init_entry_index=0;init_entry_index<=(associativity - 1);init_entry_index=init_entry_index+1) begin 
							begin 
								cache_status[init_set_index][init_entry_index][`valid] = `CLEAR;
							end
						end //for
					end //end Block Block_Reset_Cache
				end //for
			end //end Block Block_Init_Cache
           
			// Wait for cache enable
			@(`CLOCK_EDGE(cpu_enable_i));
			
			begin :Block_Work_Cache
				while (1) begin 
						//  wait for a cpu request
					    @(`CLOCK_REVER(clk_i));
					    
						//  decode address
						cpu_address	= bv_to_natural(cpu_addr_i);
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
								do_read_hit;
							end 
						else 
							begin 
								do_read_miss;
							end 
						
						begin if((rst_i == `SET)) disable Block_Work_Cache; end
				end //while
			end //end Block_Work_Cache
           
			// loop exited on reset: wait until it goes inactive then start again
//			@( `CLOCK_EDGE (((clk_i == `CLEAR) & (rst_i == `CLEAR))));
		end
	end
                                               
	// ****************** //
	// Read Hit procedure //
	// ****************** //
	task do_read_hit;
		begin 
			cpu_data_o	<= cache_data[set_index][entry_index][(`dw*word_offset) +: `dw];
			cpu_ready_o	<= #(tpd_clk_out) `SET;
			
			@(`CLOCK_EDGE clk_i );
			
			cpu_ready_o	<= #(tpd_clk_out) `CLEAR;
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
                                               
                                               
	task replace_line;
	    begin
	    	//  first chose an entry using "random" number generator 
	        entry_index = next_replacement_entry_index;
	        next_replacement_entry_index = ((next_replacement_entry_index + 1) % associativity);
	        
			fetch_line;
	    end
	endtask
                                               

	task fetch_line;
	    
	    integer next_address;
	    integer new_word_offset;
	
	    begin 
	        next_address = ((cpu_address / line_size) * line_size);
			wb_rd_mult(next_address, 4'hf, 0 ,words_per_line);
	        
	        cache_status[set_index][entry_index][`valid]	= `SET;
	        cache_status[set_index][entry_index][`tag]		= cpu_tag;
	        
	    end
	endtask
                                                   
	/*======================================================================================================================================================*/
	/*	functions						*/
	/*======================================================================================================================================================*/
	function [`WORDw-1:0] bv_to_natural;
	    input  [`WORDw-1:0] bv;
	    integer result;// = 0;
	    begin : Function
	        begin 
	            begin :Block_bv2nat
	                integer index;
	                result = 0;
	                for (index=`WORDw-1;index>=0;index=index-1) begin 
	                    result = ((result * 2) + bv[index]);
	                    
	                end //for
	            end //end Block Block_bv2nat
	            begin 
	                bv_to_natural=result;
	                disable Function;
	            end
	        end
	    end // Function
	endfunction
                                                   
                                               
	function [0:`WORDw-1] natural_to_bv;
	    input  [`WORDw-1:0]  nat ;
	    input  [`WORDw-1:0]  length ;
	    integer temp;// = nat;
	    reg [0:`WORDw-1] result;//=0;
	    begin : Function
	        begin 
	            begin :Block_nat2bv
	                integer index;
	                result=0;temp = nat;
	                for (index=`WORDw-1;index>=0;index=index-1) begin 
	                    begin 
	                        result[index] = (temp % 2);
	                        temp = (temp / 2);
	                    end
	                    
	                end //for 
	            end //end Block Block_nat2bv
	            begin 
	                natural_to_bv=result;
	                disable Function;
	            end
	        end
	    end // Function
	endfunction
                                               

	/*======================================================================================================================================================*/
	/*	WishBone compatible bus functions						*/
	/*======================================================================================================================================================*/

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
			
			for(n=0;n<count-1;n=n+1)
			   begin
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
				repeat(delay)
				   begin
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
