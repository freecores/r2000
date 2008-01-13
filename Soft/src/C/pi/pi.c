/*Calculate the value of PI.  Takes a long time!*/
#include "print.h"

//long a=10000,b,c=56,d,e,f[57],g;
long a=10000,b,c=2800,d,e,f[2801],g;
int main()
{
   long a5=a/5;
   
   for(;b-c;)
   	f[b++]=a5;

   for(	;
   		d=0,g=c*2;
   		c-=14,print_num(e+d/a),e=d%a)
   	for(	b=c;
   			d+=f[b]*a, f[b]=d%--g,d/=g--,--b;
   			d*=b);
   			
   putchar("\nDone.");
   return 0;
}

