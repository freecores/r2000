path;
path=..\..\..\gccmips_elf

set libpath=..\..\..\lib
set incpath=..\..\..\inc
set toolpath=..\..\..\tools
set codepath=..\..\..\..\r2000pl\bench\code

gcc  -O2 -O  -Wall -S	 -I%incpath%\ pi.c
gcc  -O2 -O  -Wall -c -s -I%incpath%\ pi.c

ld -Ttext 0 -eentry -Map pi.map -s -N -o test.exe %libpath%\boot.o %libpath%\no_os.o %libpath%\integer.o %libpath%\string2.o %libpath%\print.o pi.o
objdump.exe --disassemble test.exe > pi.lst
rem copy test.map 
rem copy list.txt 

%toolpath%\convert_bin pi
rem %toolpath%\convert_mips pi

rem %toolpath%\mlite test.bin BD > test.txt

rem %toolpath%\mlite test.bin

move /Y *.txt %codepath%