#ifdef FFF
#endif
#ifndef lint
#endif
void keystart(void);
void keyfile(char *fname,int flag);
void keydefine(char *s);
void keystr(char *s);
void defnonly(char *s);
void looponly(char *s);
void loopstart(void);
void looppatch(Instnodep patchin);
void loopend(Instnodep icontinue,Instnodep ibreak);
void yyerror(char *s);
char * ipfuncname(Codep cp);
char * infuncname(Instnodep in);
void pstacktrace(Datum *dp);
void stackbuffclear(void);
void stackbuff(char *s);
long stackbuffleng(void);
void stackbufftrunc(long lng);
char * stackbuffstr(void);
char * stacktrace(Datum *dp,int full,int newlines,Ktaskp t);
void keyerrfile(char *fmt,...);
void execerror(char *fmt,...);
void resetstuff(void);
void forcereboot(void);
void warning(char *fmt,...);
void popupwarning(char *fmt,...);
void finalexit(int r);
void realexit(int r);
void fatalerror(char *s);
void myre_fail(char *s,int c);
void tsync(void);
#ifdef NEEDSYNC
#endif
void tprint(char *fmt,...);
void eprint(char *fmt,...);
void kdoprnt(int addnewline, FILE *f, char *fmt, va_list args);
void intcatch(void);
void setintcatch(void);
void yyunget(int ch);
void stuffch(int ch);
void stuffword(register char *q);
int yyinput(void);
void pushfin(FILE *f,char *fn,int autopop);
#ifdef TRYWITHOUT
#endif
void popfin(void);
#ifdef TRYWITHOUT
#endif
void yyreset(void);
void flushfin(void);
int yyrawin(void);
Codep instructs(char *s);
void corecheck(void);
#ifdef CORELEFT
#endif
int checkfunckey(int c);
int follow(int expect,int ifyes,int ifno);
int follo2(int expect1,int ifyes1,int expect2,int ifyes2,int ifno);
int follo3(int expect1,int ifyes1,int expect2,int expect3,int ifyes2,int ifyes3,int ifno);
int eatpound(void);
void plibrary(char *dir,char *s);
void load1keylib(char *dir, char *keylibk);
void loadkeylibk(void);
void addplibrary(char *dir,char *fname,char *funcname);
void pinclude(char *s);
void macrodefine(char *s,int checkkeyword);
#ifdef __GNUC__
#endif
int scanparam(char **ap);
void macroeval(char *name);
char * scantill(char *lookfor,char *buff,char *pend);
void readkeylibs(void);
Symstr filedefining(char *fnc);
int loadsymfile(Symbolp s,int pushit);
Phrasep filetoph(FILE *f,char *fname);
char * kpathsearch(char *fname);
char * mpathsearch(char *fname);
char * pathsearch(char *fname,long *apathsize,char ***apathparts,Symstrp alastkeypath,char **apathfname,Symstrp pathvar,PATHFUNC pfunc);
char ** makeparts(Symstr path);
int MAIN(int argc,char **argv);
