void addtobechecked(register Phrasep p);
void httobechecked(register Htablep p);
void phrmerge(Phrasep p,Phrasep outp,long offset);
void phdump(void);
void ph1dump(Phrasep p);
void phcheck(void);
void htcheck(void);
#ifdef lint
#endif
char * strend(register char *s);
#ifdef OLDRAND
void keysrand(unsigned x);
int keyrand(void);
#endif
unsigned int keyrand(void);
void keysrand (unsigned int seed1, unsigned int seed2, unsigned int seed3);
void phputc(int c);
void phputs(char *s);
void messprint(Noteptr nt);
void phprint(PFCHAR pfunc,Phrasep ph,int nl);
#ifdef NTATTRIB
#endif
void nttostr(Noteptr n,char *buff);
int phsize(register Phrasep p,register int notes);
Noteptr picknt(register Phrasep ph,register int picknum);
#ifdef BASEERROR
#else
#endif
int phrinphr(Datum d1,Datum d2);
char * atypestr(int type);
char * typestr(int type);
char * dotstr(register int type);
Datum phdotvalue(Phrasep ph,int type);
#ifndef NTATTRIB
#else
#endif
int ntdotvalue(register Noteptr n,register int type,Datum *ad);
#ifndef NTATTRIB
#else
#endif
long getnumval(Datum d,int round);
#ifdef OLDCODE
#endif
double getdblval(Datum d);
int getnmtype(Datum d);
int findfile(register char *name);
void getnclose(char *fname);
#ifdef PIPES
#else
#endif
FILE * getnopen(char *name,char *mode);
#ifdef PIPES
#else
#endif
void closefile(void);
void forinerr(void);
void inerr(void);
Instnodep newin(void);
void freeiseg(Instnodep in);
void freecode(Codep cp);
void freeinode(Instnodep in);
Lknode * newlk(Symstr nm);
void unlinklk(Lknode *lk);
void freelk(Lknode *lk);
Lknode * findtoplk(Symstr nm);
void unlocktid(Ktaskp t);
Ktaskp unlocklk(Lknode *lk);
void rmalllocks(void);
Kobjectp newobj(long id,int complain);
Kobjectp findobjnum(long n);
void unlinkobj(Kobjectp o);
void freeobj(Kobjectp o);
#ifdef HACKHACKHACK
#endif
Dnode * newdn(void);
void freedn(Dnode *dn);
void freednodes(Dnode *dn);
Datum strdatum(char *s);
Datum dbldatum(double f);
Datum phrdatum(Phrasep p);
Datum codepdatum(Codep cp);
Datum framedatum(Datum *f);
Datum datumdatum(Datum *f);
Datum notedatum(Noteptr n);
Datum symdatum(Symbolp s);
Datum fifodatum(Fifo *f);
Datum taskdatum(Ktaskp t);
Datum arrdatum(Htablep arr);
Datum objdatum(Kobjectp obj);
Unchar * put_ipcode(Codep ip, Unchar *p);
Unchar * put_funccode(BYTEFUNC func, Unchar *p);
Unchar * put_bltincode(Unchar bltin, Unchar *p);
Unchar * put_strcode(Symstr str, Unchar *p);
Unchar * put_dblcode(DBLTYPE dbl, Unchar *p);
Unchar * put_numcode(long num, Unchar *p);
#ifdef FFF
#endif
Unchar * put_symcode(Symbolp sym, Unchar *p);
Unchar * put_phrcode(Phrasep phr, Unchar *p);
Symstr scan_strcode(Unchar **pp);
Symbolp scan_symcode(Unchar **pp);
DBLTYPE scan_dblcode(Unchar **pp);
Phrasep scan_phrcode(Unchar **pp);
Codep scan_ipcode(Unchar **pp);
long nparamsof(Codep cp);
Symbolp symof(Codep cp);
long nlocalsof(Codep cp);
Codep firstinstof(Codep cp);
Unchar * varinum_put(long value,Unchar *p);
int varinum_size(long value);
long scan_numcode(Unchar **pp);
long scan_numcode1(Unchar **pp,int b);
#ifdef MDEP_OSC_SUPPORT
void osc_padit(char *msg,int msgsize,int *sofarp, int topad);
void osc_pack_str(char *msg,int msgsize,int *sofarp, char *s);
void osc_pack_int(char *msg,int msgsize,int *sofarp, int v);
void osc_pack_dbl(char *msg,int msgsize,int *sofarp, DBLTYPE v);
char * osc_scanstring(char **buff, int *buffsize);
int osc_scanint(char **buff, int *buffsize);
void osc_scantimetag(char **buff, int *buffsize, int *secs, int *fract);
int osc_scanblob(char **buff, int *buffsize, char *blobbuff, int blobbuffsize);
float osc_scanfloat(char **buff, int *buffsize);
Datum osc_array(char *buff, int buffsize, int used);
#endif
