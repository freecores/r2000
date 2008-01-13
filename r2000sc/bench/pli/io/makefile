CCPATH=C:/Modeltech_6.0c/gcc-3.2.3-mingw32/bin/
PLIPATHINC=c:/Modeltech_6.0c/include
PLIPATHLIB=c:/Modeltech_6.0c/win32

MTI_HOME=C:/Modeltech_6.0c
PLATFORM=win32

CC=$(CCPATH)gcc
LD=$(CCPATH)gcc

SOURCE=vpi_user.c UserIO_vpi_string.c ShowMemoryMap_vpi.c ClearControlSignals_vpi.c
OBJ= $(SOURCE:.c=.o)

CFLAGS= -c -g -I$(PLIPATHINC)
LDFLAGS= -shared -o

SOURCEV=behavioral.v
#SIMFLAG=-c

EXEC=simule

all: $(EXEC)

# -- simule -- #
simule: pli_test verilog
	vsim $(SIMFLAG) vespa -do vsim-bat.do -pli pli_test.dll

# -- synthesize -- #
verilog: libwork $(SOURCEV)
	$(MTI_HOME)/$(PLATFORM)/vlog $(SOURCEV)
	
libwork: 
	vlib work

# -- compile --#
pli_test: $(OBJ)
	$(LD) $(LDFLAGS) pli_test.dll $^ -L$(PLIPATHLIB) -lmtipli 

%.o: %.c
	$(CC) -o $@  $< $(CFLAGS)

