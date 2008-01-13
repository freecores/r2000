PATH=C:\dev\Soc\Mips\Soft\gccmips_elf
CCPATH=C:/dev/Soc/Mips/Soft/gccmips_elf/
PATHINC=../../inc
PATHLIB=./
PATHSRC=src

#CC=$(CCPATH)gcc
#LD=$(CCPATH)ld
#AS=$(CCPATH)as

CC=gcc
LD=ld
AS=as

SOURCEC=$(wildcard *.c)
OBJ= $(SOURCEC:.c=.o)
#OBJ= $(wildcard *.o)
SOURCEA=$(wildcard *.s)
OAS=$(SOURCEA:.s=.o)

CFLAGS= -O2 -O  -Wall -c -s	-I$(PATHINC)
LDFLAGS= -Ttext 0 -eentry -Map test.map -s -N -o 

EXEC=compile assemble

all: $(EXEC)

link: $(OBJ)
	$(LD) $(LDFLAGS)  $^ -L$(PATHLIB)
	
compile: $(SOURCEC)
	$(CC) $(CFLAGS) $^

assemble: $(SOURCEA)
	$(AS) -o boot.o boot.s
	$(AS) -o plasmaboot.o plasmaboot.s