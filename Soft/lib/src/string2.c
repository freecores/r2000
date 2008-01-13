char *strcpy2(char *s, const char *t)
{
   char *tmp=s;
   while((int)(*s++=*t++)) ;
   return(tmp);
}
