CCPATH=C:/Modeltech_6.0c/gcc-3.2.3-mingw32/bin/
PLIPATHINC=c:/Modeltech_6.0c/include
PLIPATHLIB=c:/Modeltech_6.0c/win32

MTI_HOME=C:/Modeltech_6.0c
PLATFORM=win32

CC=$(CCPATH)gcc
LD=$(CCPATH)gcc

SOURCE=watch_variable_tf.c veriuser_XL.c
OBJ= $(SOURCE:.c=.o)

CFLAGS= -c -g -I$(PLIPATHINC)
LDFLAGS= -shared -o

SOURCEV=watch_variable_test.v
SIMFLAG=-c


EXEC=simule

all: $(EXEC)

# -- simule -- #
simule: verilog compile
	vsim $(SIMFLAG) watch_variable -do vsim-bat.do -pli watch_variable.dll

# -- synthesize -- #
verilog: libwork $(SOURCEV)
	$(MTI_HOME)/$(PLATFORM)/vlog $(SOURCEV)
	
libwork:
	vlib work

# -- compile --#
compile: $(OBJ)
	$(LD) $(LDFLAGS) watch_variable.dll $^ -L$(PLIPATHLIB) -lmtipli 
#compile: processor.o
#	$(LD) $(LDFLAGS) watch_variable.dll processor.o -L$(PLIPATHLIB) -lmtipli 

%.o: %.c
	$(CC) -o $@  $< $(CFLAGS)
#processor.o: $(SOURCE)
#	$(CC) $(CFLAGS) $(SOURCE)
