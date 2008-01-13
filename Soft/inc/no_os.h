#define MemoryRead(A) (*(volatile unsigned int*)(A))
#define MemoryWrite(A,V) *(volatile unsigned int*)(A)=(V)

void putchar(int value);
int puts(const char *string);
void OS_InterruptServiceRoutine(unsigned int status);
int kbhit(void);
int getch(void);
