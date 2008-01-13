path;
path=..\..\..\gccmips_elf

set libpath=..\..\..\lib
set incpath=..\..\..\inc
set toolpath=..\..\..\tools
set codepath=..\..\..\..\r2000pl\bench\code

gcc  -O2 -O  -Wall -S	 -I%incpath%\ eGcd.c
gcc  -O2 -O  -Wall -c -s -I%incpath%\ eGcd.c

ld -Ttext 0 -eentry -Map test.map -s -N -o test.exe %libpath%\boot.o %libpath%\no_os.o %libpath%\integer.o %libpath%\string2.o %libpath%\print.o eGcd.o
objdump.exe --disassemble test.exe > test.lst
rem copy test.map 
rem copy list.txt 
convert_bin 

move /Y *.txt %codepath%