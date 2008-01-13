#include "print.h"

int main(void)
{
	union {
		int 	as_int;
		short	as_short[2];
		char	as_char[4];
	}either;
	
	either.as_int = 0x12345678;
	
	if(sizeof(int) == 4 && either.as_char[0] == 0x78)
		print_string("Little endian\n");
	else if(sizeof(int) == 4 && either.as_char[0] == 0x12)
		print_string("Big endian\n");
	else
		print_string("Confused\n");
		
	return 0;
}