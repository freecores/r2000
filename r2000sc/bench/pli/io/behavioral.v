/*

Behavioral simulation of the VeSPA processor.

This model contains no timing information.  It simply executes
the operations defined in the ISA.  It is used to test the basic
ISA definition and the corresponding assembler.

This program is for the use of only students enrolled in
University of Minnesota class EE 5361/CS 5201 during Fall, 2001.

Copyright 2001, David J. Lilja and Sachin Sapatnekar
All rights reserved.

*/

module vespa;

// Set the following macro names to 1 to turn on the corresponding
// execution trace.  Set to 0 to turn the trace off.

//`define	TRACE_REGS	1	// Trace the contents of all registers.
//`define	TRACE_PC	1	// Trace the contents of the program counter.
//`define	TRACE_CC	1	// Trace the contents of the condition codes.




// Declare global parameters.

parameter	WIDTH = 32;		// Datapath width
parameter	NUMREGS = 32;		// Number of registers in the ISA.
parameter	MEMSIZE = (1<<13);	// Size of the memory actually
					// simulated.  Address range is
					// 0 to (2^13 - 1).


// Declare all storage elements defined in the ISA.

reg[7:0]	MEM[0:MEMSIZE-1];	// Byte-wide main memory.
reg[WIDTH-1:0]	R[0:NUMREGS-1];		// General-purpose registers.
reg[WIDTH-1:0]	PC;			// Program counter.
reg[WIDTH-1:0]	IR;			// Instruction register.
reg		C;			// Condition code bit.
reg		V;			// Condition code bit.
reg		Z;			// Condition code bit.
reg		N;			// Condition code bit.
reg		RUN;			// Execute while RUN=1

// These registers are used to simplify some parameter passing
// when calculating ALU operations and setting condition code bits.
// Note that the result contains an extra bit to store the carry-out
// produced by the ALU.

reg[WIDTH-1:0]	op1;			// Source operand 1.
reg[WIDTH-1:0]	op2;			// Source operand 2.
reg[WIDTH  :0]	result;			// Result value.

// Some miscellaneous global values.

integer num_instrs;			// Number of instructions executed.

// Define the op-codes specified in the ISA.

`define	NOP	'd0
`define	ADD	'd1
`define	SUB	'd2
`define	OR	'd3
`define	AND	'd4
`define	NOT	'd5
`define	CMP	'd6
`define	BXX	'd7
`define	JMP	'd8
`define	LD	'd9
`define	LDI	'd10
`define	LDX	'd11
`define	ST	'd12
`define	STX	'd13
`define	HLT	'd31

// Define the conditions available in a conditional branch.

`define	BRA	'b0000
`define	BNV	'b1000
`define	BCC	'b0001
`define	BCS	'b1001
`define	BVC	'b0010
`define	BVS	'b1010
`define	BEQ	'b0011
`define	BNE	'b1011
`define	BGE	'b0100
`define	BLT	'b1100
`define	BGT	'b0101
`define	BLE	'b1101
`define	BPL	'b0110
`define	BMI	'b1110


// Define the op-code, source register, etc., fields in the IR.

`define	OPCODE	IR[31:27]	// op-code field
`define	rdst	IR[26:22]	// destination register
`define	rs1	IR[21:17]	// source register 1
`define	IMM_OP	IR[16]		// IR[16]==1 when source 2 is immediate operand
`define	rs2	IR[15:11]	// source register 2
`define	rst	IR[26:22]	// source register for store op
`define	immed23	IR[22:0]	// 23-bit literal field
`define	immed22	IR[21:0]	// 22-bit literal field
`define	immed17	IR[16:0]	// 17-bit literal field
`define	immed16	IR[15:0]	// 16-bit literal field
`define	COND	IR[26:23]	// Branch conditions.



/*
This is the main loop body.  It first reads the object file
called "v.out" and then fetches and executes instructions until
the RUN bit is turned off.
*/

initial begin

  $readmemh("v.out",MEM);	// Read v.out file into MEM.

  RUN = 1;			// RUN gets reset by the HLT instruction.
  PC = 16;			// Start executing from address 16.        [AP]
  num_instrs = 0;
  
  while (RUN == 1)
    begin
      num_instrs = num_instrs + 1;	// Number of instructions executed.
      fetch;		// Fetch the next instruction.
      execute;		// Execute it.  
		$UserIO(vespa);					// [AP]
		$ShowMemoryMap(vespa);			// [AP]    
		$ClearControlSignals(vespa);	// [AP]
	print_trace;		// Print a trace of execution, if enabled.
      
    end
    
  $display("\nTotal number of instructions executed:  %d\n\n", num_instrs);
  $stop;//$finish;			// Terminate the simulation and exit.

end




// Fetch the next instruction from memory and move it into the IR.

task fetch;
  begin
    IR = read_mem(PC);
    PC = PC + 4;  // PC points to the next instruction to be executed
  end
endtask


// Execute each instruction according to the ISA definition.

task execute;
  begin

   case (`OPCODE) 

      `ADD: begin
	if (`IMM_OP == 0)
	   op2 = R[`rs2];
	else
	   op2 = sext16(`immed16);
	op1 = R[`rs1];
	result = op1 + op2;
	R[`rdst] = result[WIDTH-1:0];
	setcc(op1, op2, result, 0);
      end


      `AND: begin
	if (`IMM_OP == 0)
	   op2 = R[`rs2];
	else
	   op2 = sext16(`immed16);
	op1 = R[`rs1];
	result = op1 & op2;
	R[`rdst] = result[WIDTH-1:0];
      end


      `BXX: begin
        if (checkcc(Z,C,N,V) == 1)
           PC = PC + sext23(`immed23);
      end


      `CMP: begin
	if (`IMM_OP == 0)
	   op2 = R[`rs2];
	else
	   op2 = sext16(`immed16);
	op1 = R[`rs1];
	result = op1 - op2;
	setcc(op1, op2, result, 1);
      end


      `HLT: begin
	RUN = 0;
      end


      `JMP: begin
	if (`IMM_OP == 1)	// If jump-and-link operation, the old PC
	   R[`rdst] = PC;	// value must be saved before it is lost.
	PC = R[`rs1] + sext16(`immed16);
      end


      `LD: begin
	R[`rdst] = read_mem(sext22(`immed22));
      end


      `LDI: begin
	R[`rdst] = sext22(`immed22);
      end


      `LDX: begin
	R[`rdst] = read_mem(R[`rs1] + sext17(`immed17));
      end


      `NOP: begin
      end


      `NOT: begin
	op1 = R[`rs1];
	result = ~op1;
	R[`rdst] = result[WIDTH-1:0];
      end


      `OR: begin
	if (`IMM_OP == 0)
	   op2 = R[`rs2];
	else
	   op2 = sext16(`immed16);
	op1 = R[`rs1];
	result = op1 | op2;
	R[`rdst] = result[WIDTH-1:0];
      end


      `ST: begin
        write_mem(sext22(`immed22),R[`rst]);
      end


      `STX: begin
        write_mem(R[`rs1] + sext17(`immed17),R[`rst]);
      end


      `SUB: begin
	if (`IMM_OP == 0)
	   op2 = R[`rs2];
	else
	   op2 = sext16(`immed16);
	op1 = R[`rs1];
	result = op1 - op2;
	R[`rdst] = result[WIDTH-1:0];
	setcc(op1, op2, result, 1);
      end


      default: begin
	$display("Error: undefined opcode:  %d",`OPCODE) ;
      end


  endcase	// OPCODE case

end
endtask




// Sign extend the given input value into WIDTH bits.

function [WIDTH-1:0] sext16;	// 16-bit input
  input [15:0] d_in;		// the bit field to be sign extended

  sext16[WIDTH-1:0] = { {16{d_in[15]}} ,d_in};

endfunction	// sext16


function [WIDTH-1:0] sext17;	// 17-bit input
  input [16:0] d_in;		// the bit field to be sign extended

  sext17[WIDTH-1:0] = { {15{d_in[16]}} ,d_in};

endfunction	// sext17


function [WIDTH-1:0] sext22;	// 22-bit input
  input [21:0] d_in;		// the bit field to be sign extended

  sext22[WIDTH-1:0] = { {10{d_in[21]}} ,d_in};

endfunction	// sext22


function [WIDTH-1:0] sext23;	// 23-bit input
  input [22:0] d_in;		// the bit field to be sign extended

  sext23[WIDTH-1:0] = { {9{d_in[22]}} ,d_in};

endfunction	// sext23



// Set the condition codes according to the given input value.

task setcc; 
  input [WIDTH-1:0] op1;	// Operand 1.
  input [WIDTH-1:0] op2;	// Operand 2.
  input [WIDTH  :0] result;	// The calculated result value.
  input subt;			// Set if the operation was a subtraction.
				// In this case, the sign bit of op2
				// must be inverted to correctly
				// calculate the V bit.

  begin

    C = result[WIDTH];		// The carry out of the result.

    Z = ~(|result[WIDTH-1:0]);	// Result is zero if all bits are 0.

    N = result[WIDTH-1];	// Result is negative if the most
				// significant bit is a 1.

    // A two's complement overflow for addition occurs if the
    // sign bit of the result is the opposite of the sign bit
    // of the two operands.  Note that for subtraction, the subt
    // input should be set to invert the sign of op2 before calculating
    // the V bit.

    V =	  ( result[WIDTH-1] & ~op1[WIDTH-1] & ~(subt ^ op2[WIDTH-1]))
        | (~result[WIDTH-1] &  op1[WIDTH-1] &  (subt ^ op2[WIDTH-1]));

  end

endtask



// Check the condition codes and return either a 0 or 1 depending
// upon the particular condition selected by the instruction.
//

function checkcc;
  input Z;			// The condition code bits.
  input C;
  input N;
  input V;

  begin

//	$display("####  COND=%h",`COND);
//	$display("####  Condition codes:  C=%b  V=%b  Z=%d  N=%b", C,V,Z,N); 
//	$display("####  IR=%h",IR); 

   case (`COND) 

      `BRA: begin
        checkcc = 1;        
      end

      `BNV: begin
        checkcc = 0;        
      end

      `BCC: begin
        checkcc = ~C;        
      end

      `BCS: begin
        checkcc = C;        
      end

      `BVC: begin
        checkcc = ~V;        
      end

      `BVS: begin
        checkcc = V;        
      end

      `BEQ: begin
        checkcc = Z;        
      end

      `BNE: begin
        checkcc = ~Z;        
      end

      `BGE: begin
        checkcc = (~N & ~V) | (N & V);        
      end

      `BLT: begin
        checkcc = (N & ~V) | (~N & V);        
      end

      `BGT: begin
        checkcc = ~Z & ((~N & ~V) | (N & V));        
      end

      `BLE: begin
        checkcc = Z + ((N & ~V) | (~N & V));        
      end

      `BPL: begin
        checkcc = ~N;
      end

      `BMI: begin
        checkcc = N;
      end

   endcase	// COND case

//	$display("####  checkcc=%b",checkcc); 

end
endfunction	// checkcc




// Read a 32-bit word from memory starting at the address given.
// This read operation assumes a big-endian format.

function [WIDTH-1:0] read_mem;
  input [WIDTH-1:0] addr;		// the address from which to read  

     begin   
        read_mem = {MEM[addr],MEM[addr+1],MEM[addr+2],MEM[addr+3]};
     end

endfunction	// read_mem


// Write the given value to the given address in big-endian order.

task write_mem; 
  input [WIDTH-1:0] addr;	// Address to which to write.   
  input [WIDTH-1:0] data;	// The data to write.           

  begin
    {MEM[addr],MEM[addr+1],MEM[addr+2],MEM[addr+3]} = data;
  end

endtask		// write_mem



// Print an execution trace.

task print_trace;
  integer i;
  integer j;
  integer k;

  begin

    `ifdef TRACE_PC
      begin
       $display("Instruction #:%d\tPC=%h\tOPCODE=%d", num_instrs,PC,`OPCODE); 
      end
    `endif	// TRACE_PC


    `ifdef TRACE_CC
      begin
       $display("Condition codes:  C=%b  V=%b  Z=%d  N=%b", C,V,Z,N); 
      end
    `endif	// TRACE_CC

    `ifdef TRACE_REGS
      begin
        k = 0;
        for (i = 0; i < NUMREGS; i = i + 4) 
          begin
          $write("R[%d]: ",k);
          for (j = 0; j <= 3; j = j + 1) 
            begin
              $write("  %h",R[k]);
              k = k + 1;
            end
          $write("\n");
          end
      $write("\n");
      end
    `endif	// TRACE_REGS



  end
endtask




endmodule	// End of vespa processor module.

