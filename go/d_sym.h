void newcontext(Symbolp s, int sz);
void popcontext(void);
Symbolp newsy(void);
void freesy(register Symbolp sy);
Symbolp findsym(register char *p,Htablep symbols);
Symbolp findobjsym(char *p,Kobjectp o,Kobjectp *foundobj);
Symbolp uniqvar(char* pre);
Symbolp lookup(char *p);
Symbolp localinstall(Symstr p,int t);
Symbolp globalinstall(Symstr p,int t);
Symbolp globalinstallnew(Symstr p,int t);
Symbolp syminstall(Symstr p,Htablep symbols,int t);
void clearsym(register Symbolp s);
#ifdef OLDSTUFF
#endif
#ifdef OLDSTUFF
#endif
long neednum(char *s,Datum d);
Codep needfunc(char *s,Datum d);
Kobjectp needobj(char *s,Datum d);
Fifo * needfifo(char *s,Datum d);
Fifo * needvalidfifo(char *s,Datum d);
char * needstr(char *s,Datum d);
Htablep needarr(char *s,Datum d);
Phrasep needphr(char *s,Datum d);
Symstr datumstr(Datum d);
Datum newarrdatum(int used,int size);
#ifdef OLDSTUFF
#endif
Htablepp globarray(char *name);
Datum phrsplit(Phrasep p);
#ifdef OLDSTUFF
#endif
Datum strsplit(char *str,char *sep);
void setarraydata(Htablep arr,Datum i,Datum d);
void setarrayelem(Htablep arr,long n,char *p);
void fputdatum(FILE *f,Datum d);
void installnum(char *name,Symlongp *pvar,long defval);
void installstr(char *name,char *str);
Datum funcdp(Symbolp s, BLTINCODE f);
void initsyms(void);
void initsyms2(void);
#ifdef MDEP_OSC_SUPPORT
#endif
void initstrs(void);
#ifdef MDEP_OSC_SUPPORT
#endif
void pfprint(char *s);
void phtofile(FILE *f,Phrasep p);
void vartofile(Symbolp s, char *fname);
#ifdef PIPES
#else
#endif
#ifdef PIPES
#endif
void filetovar(register Symbolp s, char *fname);
#ifdef PIPES
#else
#endif
#ifdef PIPES
#endif
Hnodep newhn(void);
void freehn(Hnodep hn);
#ifdef OLDSTUFF
#endif
Htablep newht(int size);
void clearht(Htablep ht);
#ifdef lint
#endif
void freeht(Htablep ht);
void htlists(void);
Symstr uniqstr(char *s);
int isundefd(Symbolp s);
Hnodep hashtable(Htablep ht,Datum key,int action);
Symbolp arraysym(Htablep arr,Datum subs,int action);
int arrsize(Htablep arr);
int dtcmp(Datum *d1,Datum *d2);
Datum * arrlist(Htablep arr,int *asize,int sortit);
void hashvisit(Htablep arr,HNODEFUNC f);
