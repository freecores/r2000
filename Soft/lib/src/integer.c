#include "string2.h"

void itoa2(long n, char *s, int base, long *digits)
{
   long i,j,sign;
   unsigned long n2;
   char number[20];
   for(i=0;i<15;++i) {
      number[i]=' ';
   }
   number[15]=0;
   if(n>=0||base!=10) {
      sign=1;
   } else {
      sign=-1;
   }
   n2=n*sign;
   for(j=14;j>=0;--j) {
      i=n2%base;
      n2/=base;
      number[j]=i<10?'0'+i:'a'+i-10;
      if(n2==0&&15-j>=*digits) break;
   } 
   if(sign==-1) {
      number[--j]='-';
   }
   if(*digits==0||*digits<15-j) {
      strcpy2(s,&number[j]);
      *digits=15-j;
   } else {
      strcpy2(s,&number[15-*digits]);
   }
}

char *xtoa(unsigned long num)
{
   static char buf[12];
   int i, digit;
   buf[8] = 0;
   for (i = 7; i >= 0; --i)
   {
      digit = num & 0xf;
      buf[i] = digit + (digit < 10 ? '0' : 'A' - 10);
      num >>= 4;
   }
   return buf;
}

char *itoa10(unsigned long num)
{
   static char buf[12];
   int i;
   buf[10] = 0;
   for (i = 9; i >= 0; --i)
   {
      buf[i] = (char)((num % 10) + '0');
      num /= 10;
   }
   return buf;
}
