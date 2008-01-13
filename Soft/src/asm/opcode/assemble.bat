path;
path=..\..\..\gccmips_elf

set libpath=..\..\..\lib
set incpath=..\..\..\inc
set toolpath=..\..\..\tools
set codepath=..\..\..\..\r2000pl\bench\code

rem as -o test.o  tt-alu-bare.s
as -o test.o  opcodes.s

ld -Ttext 0x00000000 -eentry -Map opcodes.map -r -s -N -o test.exe test.o --stats 
objdump.exe --disassemble-all test.exe > opcodes.lst

ld -Ttext 0x00000000 -eentry -Map opcodes.map -s -N -o test.exe test.o 

%toolpath%\convert_bin opcodes


rem%toolpath%\mlite test.bin BD > test.txt
rem%toolpath%\mlite test.bin

move /Y *.txt %codepath%