cls
set PLATFORM=win32
rem set MTI_HOME=C:\Modeltech_6.0c

set SOURCE=watch_variable_tf.c veriuser_XL.c
set CPP_SWITCHES= /D "_DEBUG" -c -I%MTI_HOME%\include

rem Visual C/C++ compilation
cl %CPP_SWITCHES% %SOURCE%
link -dll -export:veriusertfs watch_variable_tf.obj veriuser_XL.obj %MTI_HOME%\win32\mtipli.lib /out:watch_variable.dll 


rem Verilog compilation
%MTI_HOME%\%PLATFORM%\vlib work
%MTI_HOME%\%PLATFORM%\vlog watch_variable_test.v
%MTI_HOME%\%PLATFORM%\vsim watch_variable -do vsim-bat.do -pli watch_variable.dll
