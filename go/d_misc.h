int exists(char *fname);
void myfclose(FILE *f);
int hexchar(register int c);
long numscan(register char **as);
char * prlongto(register long n,register char *s);
char * printto(register int n,register char *s);
char * strsave(register char *s);
int stdioname(char *fname);
void allocerror(void);
#ifdef MDEBUG
#endif
#ifndef MDEBUG
char * allocate(unsigned int s, char *tag);
#else
char * dbgallocate(unsigned int s,char *tag);
void mmreset(void);
char * visstr(char *s);
void mmdump(void);
#endif
void myfree(char *s);
#ifdef MDEBUG
#endif
char * myfgets(char *buff, int bufsiz, FILE *f);
