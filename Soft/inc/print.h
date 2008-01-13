#include "plasma.h"

#ifndef WIN32	// MIPS
/*
#undef putchar
#define putchar(C) *(volatile unsigned char*)UART_WRITE=(unsigned char)(C)
*/
#endif

void print(long num,long base,long digits);
void print_hex(unsigned long num);
void print_string(char *p);
void print_num(unsigned long num);

