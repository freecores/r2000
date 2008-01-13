cls
set PLATFORM=win32
rem set MTI_HOME=C:\Modeltech_6.0c

set SOURCE=dump_memory_tf.c fill_memory_tf.c veriuser_XL.c
set CPP_SWITCHES= /D "_DEBUG" -c -I%MTI_HOME%\include

rem Visual C/C++ compilation
cl %CPP_SWITCHES% %SOURCE%
link -dll -export:veriusertfs dump_memory_tf.obj fill_memory_tf.obj veriuser_XL.obj %MTI_HOME%\win32\mtipli.lib /out:dump_and_fill_mem.dll 


rem Verilog compilation
%MTI_HOME%\%PLATFORM%\vlib work

%MTI_HOME%\%PLATFORM%\vlog dump_and_fill_mem_test.v

%MTI_HOME%\%PLATFORM%\vsim dump_mem_test -c -do vsim-bat.do -pli dump_and_fill_mem.dll
