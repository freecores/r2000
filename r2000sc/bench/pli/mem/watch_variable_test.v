/**********************************************************************
 * $dump_mem_hex and $fill_mem example -- Verilog HDL test bench.
 *
 * Verilog test bench to test the $dump_mem_hex, $dump_mem_ascii
 * and $fill_mem PLI applications.
 *
 * For the book, "The Verilog PLI Handbook" by Stuart Sutherland
 *  Book copyright 1999, Kluwer Academic Publishers, Norwell, MA, USA
 *   Contact: www.wkap.il
 *  Example copyright 1998, Sutherland HDL Inc, Portland, Oregon, USA
 *   Contact: www.sutherland.com or (503) 692-0898
 *********************************************************************/
`timescale 1ns / 1ns 
module watch_variable;

  parameter LEFT_BIT = 7, RIGHT_BIT = 00, FIRST_ADDR = 0, LAST_ADDR = 1023;

//  parameter LEFT_BIT = 23, RIGHT_BIT = 00, FIRST_ADDR = 0, LAST_ADDR = 3;
//  parameter LEFT_BIT = 00, RIGHT_BIT = 23, FIRST_ADDR = 0, LAST_ADDR = 3;
//  parameter LEFT_BIT = 23, RIGHT_BIT = 00, FIRST_ADDR = 3, LAST_ADDR = 0;
//  parameter LEFT_BIT = 00, RIGHT_BIT = 23, FIRST_ADDR = 3, LAST_ADDR = 0;
//  parameter LEFT_BIT = 24, RIGHT_BIT = 01, FIRST_ADDR = 0, LAST_ADDR = 3;
//  parameter LEFT_BIT = 01, RIGHT_BIT = 24, FIRST_ADDR = 0, LAST_ADDR = 3;
//  parameter LEFT_BIT = 23, RIGHT_BIT = 00, FIRST_ADDR = 1, LAST_ADDR = 4;
//  parameter LEFT_BIT = 23, RIGHT_BIT = 00, FIRST_ADDR = 4, LAST_ADDR = 1;

  reg  [LEFT_BIT:RIGHT_BIT] RAM [FIRST_ADDR:LAST_ADDR];

  integer addr;
  wire [23:0] vector1, vector2;

  initial
    begin

//      $display("Loading memory from Verilog HDL...");
//      $display("----------------------------------\n");
      fill_mem("Hello world!");
//      #1 dump_mem_hex;
//      #1 dump_mem_ascii;

      $display("Accessing memory using $dump_mem...");
      $display("-----------------------------------\n");
      $watch_data_hex(RAM[FIRST_ADDR]); /* address ignored by PLI */



      #10 $stop;//$finish;
    end

/*
  assign vector1 = RAM[FIRST_ADDR];
  always @(vector1)
    $display("\nRAM[%0d] just changed to %h\n", FIRST_ADDR, RAM[FIRST_ADDR]);

  assign vector2 = RAM[LAST_ADDR];
  always @(vector2)
    $display("\nRAM[%0d] just changed to %h\n", LAST_ADDR, RAM[LAST_ADDR]);
*/

  task dump_mem_ascii;
    begin
      $write("Within Verilog:\n Memory contents in ASCII are:\n   ");
      if (FIRST_ADDR < LAST_ADDR)
        for (addr=FIRST_ADDR; addr<=LAST_ADDR; addr=addr+1)
          $write("%s", RAM[addr]);
      else
        for (addr=FIRST_ADDR; addr>=LAST_ADDR; addr=addr-1)
          $write("%s", RAM[addr]);
      $display("\n");           //terminate dump string
    end
  endtask

  task dump_mem_hex;
    begin
      $display("Within Verilog:\n Memory contents in hex are:");
      if (FIRST_ADDR < LAST_ADDR)
        for (addr=FIRST_ADDR; addr<=LAST_ADDR; addr=addr+1)
          $display("   address %0d:\t %h", addr, RAM[addr]);
      else
        for (addr=FIRST_ADDR; addr>=LAST_ADDR; addr=addr-1)
          $display("   address %0d:\t %h", addr, RAM[addr]);
    end
  endtask

  task fill_mem; /* assumes at least 4 words, each word at least 24 bits wide */
    input [(20*8)-1:0] string; /* input for 20 ASCII characters */
    integer i;
    begin
      if (FIRST_ADDR < LAST_ADDR)
        begin
          if (   (LEFT_BIT - RIGHT_BIT) !== 7
              && (RIGHT_BIT - LEFT_BIT) !== 7 )
            disable fill_mem;  /* abort if word is not 24 bits wide */
          for (i=0;i<LAST_ADDR-FIRST_ADDR+1;i=i+1)  
          	RAM[FIRST_ADDR+i] = i;//string[8*(i+1):8*i];
/*          RAM[FIRST_ADDR+3] = string[23: 0];
          RAM[FIRST_ADDR+2] = string[47:24];
          RAM[FIRST_ADDR+1] = string[71:48];
          RAM[FIRST_ADDR+0] = string[95:72];*/
        end
      else
        begin
          if (   (LEFT_BIT - RIGHT_BIT) !== 8
              && (RIGHT_BIT - LEFT_BIT) !== 8 )
            disable fill_mem;  /* abort if word is not 24 bits wide */
          RAM[FIRST_ADDR-3] = string[23: 0];
          RAM[FIRST_ADDR-2] = string[47:24];
          RAM[FIRST_ADDR-1] = string[71:48];
          RAM[FIRST_ADDR-0] = string[95:72];
        end
    end
  endtask

endmodule
