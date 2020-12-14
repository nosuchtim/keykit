void initfifos(void);
Fifodata * newfd(Datum d);
#ifdef THIS_CAUSES_PROBLEM_ON_MAC_AND_DOESNT_REALLY_DO_ANYTHING_ANYWAY
#endif
void freefd(Fifodata *fd);
Fifo * fifoptr(long n);
int findport(Hnodep h);
Fifo * port2fifo(PORTHANDLE port);
void closefifo(Fifo *f);
#ifdef PIPES
#else
#endif
#ifdef lint
#endif
void deletefifo(Fifo *f);
void freeff(Fifo *f);
void flushfifo(Fifo *f);
#ifdef lint
#endif
void flushlinebuff(Fifo* f);
void closeallfifos(void);
char * nameofchar(int c);
void putonconsinfifo(int c);
void putonconsoutfifo(char *s);
void putonconsechofifo(char *s);
void putonmousefifo(int mval,int x,int y,int pressed,int mod);
void putonmidiinfifo(Noteptr n);
void putntonfifo(Noteptr n,Fifo* f);
char * findopt(char *nm,char **args);
int isspecialfifo(Fifo *f);
Fifo * specialfifo(void);
Fifo * getafifo(void);
int fifoctl2type(char *mode, int def);
int mode2flags(char *mode);
int newfifo(char *fname,char *mode,char *porttype,Fifo **pf1,Fifo **pf2);
#ifdef PIPES
#else
#endif
int fifosize(Fifo *f);
void getfromfifo(Fifo *f);
Datum removedatafromfifo(Fifo *f);
void blockfifo(Fifo *f,int noreturn);
void unblocktask(Ktaskp t);
void getfifo(Fifo *f);
void fputit(char *s);
void putfifo(Fifo *f,Datum d);
