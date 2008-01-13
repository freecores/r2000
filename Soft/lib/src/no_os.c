#include "plasma.h"
#include "no_os.h"

void putchar(int value)
{
#ifdef UART
   while((MemoryRead(IRQ_STATUS) & IRQ_UART_WRITE_AVAILABLE) == 0)
   		;
#endif
   MemoryWrite(UART_WRITE, value);
}

int puts(const char *string)
{
   while(*string)
   {
      if(*string == '\n')
         putchar('\r');
      putchar(*string++);
   }
   return 0;
}

void OS_InterruptServiceRoutine(unsigned int status)
{
   (void)status;
   putchar('I');
}

int kbhit(void)
{
   return MemoryRead(IRQ_STATUS) & IRQ_UART_READ_AVAILABLE;
}

int getch(void)
{
   while(!kbhit()) ;
   return MemoryRead(UART_READ);
}
