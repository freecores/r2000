#include "print.h"
#include "integer.h"


char *name[] = {
   "", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
   "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen",
   "sixteen", "seventeen", "eighteen", "nineteen",
   "", "ten", "twenty", "thirty", "forty", "fifty", "sixty", "seventy",
   "eighty", "ninety"
};

void number_text(unsigned long number)
{
   int digit;
   puts(itoa10(number));
   puts(": ");
   if(number >= 1000000000)
   {
      digit = number / 1000000000;
      puts(name[digit]);
      puts(" billion ");
      number %= 1000000000;
   }
   if(number >= 100000000)
   {
      digit = number / 100000000;
      puts(name[digit]);
      puts(" hundred ");
      number %= 100000000;
      if(number < 1000000)
      {
         puts("million ");
      }
   }
   if(number >= 20000000)
   {
      digit = number / 10000000;
      puts(name[digit + 20]);
      putchar(' ');
      number %= 10000000;
      if(number < 1000000)
      {
         puts("million ");
      }
   }
   if(number >= 1000000)
   {
      digit = number / 1000000;
      puts(name[digit]);
      puts(" million ");
      number %= 1000000;
   }
   if(number >= 100000)
   {
      digit = number / 100000;
      puts(name[digit]);
      puts(" hundred ");
      number %= 100000;
      if(number < 1000)
      {
         puts("thousand ");
      }
   }
   if(number >= 20000)
   {
      digit = number / 10000;
      puts(name[digit + 20]);
      putchar(' ');
      number %= 10000;
      if(number < 1000)
      {
         puts("thousand ");
      }
   }
   if(number >= 1000)
   {
      digit = number / 1000;
      puts(name[digit]);
      puts(" thousand ");
      number %= 1000;
   }
   if(number >= 100)
   {
      digit = number / 100;
      puts(name[digit]);
      puts(" hundred ");
      number %= 100;
   }
   if(number >= 20)
   {
      digit = number / 10;
      puts(name[digit + 20]);
      putchar(' ');
      number %= 10;
   }
   puts(name[number]);
   putchar ('\r');
   putchar ('\n');
}


int main(void)
{

   unsigned long number, i=0;

   number = 3;

   puts("Essalam alikoum\n");

   for(i = 0;; ++i)
   {
      number_text(number);
      number *= 3;
   }

	return 0;
}

