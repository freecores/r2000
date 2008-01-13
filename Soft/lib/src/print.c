#include "string2.h"
#include "integer.h"
//#include "print.h"	// no check uart status
#include "no_os.h"	//	  check uart status

void print(long num,long base,long digits)
{
   char *ptr,buffer[128];
   itoa2(num,buffer,base,&digits);
   ptr=buffer;
   while(*ptr) {
      putchar(*ptr++);          /* Put the character out */
      if(ptr[-1]=='\n') *--ptr='\r';
   }
}              

void print_hex(unsigned long num)
{
   long i;
   unsigned long j;
   for(i=28;i>=0;i-=4) {
      j=((num>>i)&0xf);
      if(j<10) putchar('0'+j);
      else putchar('a'-10+j);
   }
}

void print_string(char *p)
{
   int i;
   for(i=0;p[i];++i) {
      putchar(p[i]);
   }
}

void print_num(unsigned long num)
{
   unsigned long digit,offset;
   for(offset=1000;offset;offset/=10) {
      digit=num/offset;
      putchar(digit+'0');
      num-=digit*offset;
   }
}
