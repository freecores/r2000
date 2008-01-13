path;
path=..\..\..\gccmips_elf
as -o test1.o  opcodes.asm
ld.exe -Ttext 0x00000000 -eentry -Map test.map -s -N -o test.exe test1.o 
objdump.exe --disassemble test.exe > list.txt
rem copy test.map 
rem copy list.txt 
rem ..\tools\convert_bin.exe
rem copy code.txt  

rem..\tools\mlite test.bin BD > test.txt

rem..\tools\mlite test.bin
