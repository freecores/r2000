path;
path=..\..\..\gccmips_elf

set libpath=..\..\..\lib
set incpath=..\..\..\inc
set toolpath=..\..\..\tools
set codepath=..\..\..\..\r2000pl\bench\code

as -o boot.o  %libpath%\src\plasmaboot.s

gcc -O2 -O -Dmain=main2 -Wall -S 		rs_tak.c
gcc -O2 -O -Dmain=main2 -Wall 	 -c -s	rs_tak.c

rem reloacatable -r
ld -Ttext 0 -eentry -Map rs_tak.map -r -s -N -o test.exe boot.o rs_tak.o 
objdump --disassemble-all	test.exe > rs_tak.lst

ld -Ttext 0 -eentry -Map rs_tak.map	 -s -N -o test.exe boot.o rs_tak.o 
rem objdump --disassemble-all	test.exe > rs_tak.lst

rem %toolpath%\convert_bin rs_tak
%toolpath%\convert_mips rs_tak

rem use convert_bin for *.bin but the code is not the same as convert_mips
rem must add the *.bin generation in convert_mips. the difference is with sp Stack Pointer
rem %toolpath%\mlite test.bin BD > test.txt

rem %toolpath%\mlite test.bin

move /Y *.txt %codepath%