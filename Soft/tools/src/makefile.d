#
# $Header: /home/marcus/revision_ctrl_test/oc_cvs/cvs/r2000/Soft/tools/src/makefile.d,v 1.1.1.1 2008-01-13 13:32:36 ameziti Exp $
#
# commands 
CD   = cd
ECHO = echo
MAKE = make

# sources 
PSR_SRC = ./src/parser

all:
	@$(CD) $(PSR_SRC);                 \
        $(ECHO) Making $(PSR_SRC) ...;     \
        $(MAKE)

clean:
	rm -f ./vl2mv;			   \
	rm -f ./include/verilog_yacc.h;    \
	rm -f ./lib/*.a;		   \
	rm -f ./src/array/array.o;	   \
	rm -f ./src/array/libarray.a;	   \
	rm -f ./src/list/list.o;	   \
	rm -f ./src/list/liblist.a;	   \
	rm -f ./src/parser/*.o;		   \
	rm -f ./src/parser/verilog_lex.c;  \
	rm -f ./src/parser/verilog_yacc.c; \
	rm -f ./src/st/st.o;		   \
	rm -f ./src/st/libst.a;		   \
	rm -f ./src/util/*.o;		   \
	rm -f ./src/util/libutil.a