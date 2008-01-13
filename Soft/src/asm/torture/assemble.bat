path;
path=..\..\..\gccmips_elf

set libpath=..\..\..\lib
set incpath=..\..\..\inc
set toolpath=..\..\..\tools
set codepath=..\..\..\..\r2000pl\bench\code

as -o test.o torture.s
ld.exe -Ttext 0x00000000 -eentry -Map test.map -s -N -o test.exe %libpath%\plasmaboot.o test.o

objdump.exe --disassemble test.exe > list.txt
rem copy test.map 
rem copy list.txt 
convert_bin.exe torture
rem copy code.txt  

rem%toolpath%\mlite test.bin BD > test.txt

rem%toolpath%\mlite test.bin

move /Y *.txt %codepath%