#ifdef OLDSTUFF
void countnotes(void);
#endif
void resetdef(void);
int saniport(long port);
Noteptr  newnt(void);
#ifdef NTATTRIB
#endif
Midimessp savemess(Unchar* mess,int leng);
void ntfree(Noteptr n);
Noteptr  ntcopy(register Noteptr n);
#ifdef NTATTRIB
#endif
void freents(Noteptr n);
int bytescmp(Noteptr n1,Noteptr n2);
int utypeof(Noteptr nt);
int ntcmporder(register Noteptr n1,register Noteptr n2);
#ifdef NTATTRIB
#endif
#ifdef NTATTRIB
#endif
int ntcmpxact(register Noteptr n1,register Noteptr n2);
#ifdef NTATTRIB
#endif
#ifdef NTATTRIB
#endif
void phcopy(Phrasep out,Phrasep in);
void phreorder(Phrasep ph,long tmout);
#ifdef DONTDO
#endif
void phcutusertype(Phrasep pin,Phrasep pout,int types,int invert);
void phcutcontroller(Phrasep pin,Phrasep pout,int cnum, int invert);
void phcutflags(Phrasep pin,Phrasep pout,long mask);
void phcutchannel(Phrasep pin,Phrasep pout,int chan);
void phcut(Phrasep pin,Phrasep pout,long tm1,long tm2,int p1,int p2);
void phcutincl(Phrasep pin,Phrasep pout,long tm1,long tm2);
void phcuttrunc(Phrasep pin,Phrasep pout,long tm1,long tm2);
#ifdef OLDSTUFF
#endif
Phrasep newph(int inituse);
void reinitph(register Phrasep p);
void ntinsert(Noteptr n,Phrasep p);
void ntdelete(register Phrasep ph,register Noteptr nt);
int usertypeof(Noteptr nt);
int phtype(register Phrasep p);
char * notetoke(INTFUNC infunc);
#ifdef OLDSTUFF
#endif
Phrasep yyphrase(INTFUNC infunc);
int strinput(void);
Phrasep strtophr(Symstr s);
int ntbytesleng(Noteptr n);
Noteptr  ntparse(char *s,Phrasep p);
char * attscan(char **s);
Noteptr  strtont(char *s);
#ifdef OLDSTUFF
#endif
#ifdef NTATTRIB
#endif
Noteptr messtont(char *s);
#ifdef NTATTRIB
#endif
#ifdef NTATTRIB
#endif
Noteptr  strtotextmess(char *s);
#ifdef NTATTRIB
#endif
#ifdef NTATTRIB
#endif
Unchar* ptrtobyte(register Noteptr n,register int num);
