path;
path=..\..\..\gccmips_elf

set libpath=..\..\..\lib
set incpath=..\..\..\inc
set toolpath=..\..\..\tools
set codepath=..\..\..\..\r2000pl\bench\code

gcc  -O2 -O  -Wall -S	 -I%incpath%\ count.c
gcc  -O2 -O  -Wall -c -s -I%incpath%\ count.c

ld -Ttext 0 -eentry -Map count.map -r -s -N -o test.exe %libpath%\boot.o %libpath%\no_os.o %libpath%\integer.o %libpath%\string2.o %libpath%\print.o count.o
objdump --disassemble-all	test.exe > count.lst

ld -Ttext 0 -eentry -Map count.map -s -N -o test.exe %libpath%\boot.o %libpath%\no_os.o %libpath%\integer.o %libpath%\string2.o %libpath%\print.o count.o

%toolpath%\convert_mips count

move /Y *.txt %codepath%