#include "print.h"

int gcd (int i, int j)
{
   while (i != j)
      if (i > j)
          i -= j;
      else
          j -= i;
   return i;
}

int main(void)
{	
	int a,b,c;
	
	print_string("Calculate the Euclid GCD\n");
	
	for(a=1;a<5;a++)
		for(b=1;b<5;b++)
		{
			c = gcd (a, b);
			print_string("eGCD(");print(a,10,0);putchar(',');print(b,10,0);print_string(")=");print(c,10,0);
			print_string(" \n");
		}
	
	return 0;
	
}