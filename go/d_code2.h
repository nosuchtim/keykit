void i_popignore(void);
#ifdef THIS_TICKLES_A_BUG_SO_LETS_DO_WITHOUT_THE_WARNING
#endif
#ifdef OLDSTUFF
#endif
void i_defined(void);
void i_objdefined(void);
void i_currobjdefined(void);
void i_realobjdefined(void);
void i_task(void);
void undefsym(Symbolp s);
void i_undefine(void);
Phrasep phresh(Phrasep p);
Datum dphresh(Datum d);
long doop(register long oldv,register long v,register int type);
#ifdef OLDSTUFF
void chknoval(Datum d,char *s);
#endif
Datum datumdoop(Datum od,Datum nd,int op);
Datum dmodulo(Datum d1,Datum d2);
void i_dot(void);
void i_modulo(void);
Symstr addstr(Symstr s1,Symstr s2);
Datum dadd(Datum d1,Datum d2);
void i_addcode(void);
Phrasep phrop(Phrasep p1,int op,Phrasep p2);
int phrcmp(Phrasep p1,Phrasep p2);
Datum dsub(Datum d1,Datum d2);
void i_subcode(void);
Datum dmul(Datum d1,Datum d2);
void i_mulcode(void);
Datum dxor(Datum d1,Datum d2);
void i_xorcode(void);
Datum ddiv(Datum d1,Datum d2);
Datum dpar(Datum d1,Datum d2);
Datum damp(Datum d1,Datum d2);
void setval(Noteptr n,int field,Datum nv);
#ifdef NTATTRIB
#endif
Datum ntassign(Noteptr n,int dottype,Datum v,int op);
void phrvarinit(Symbolp s);
void i_dotassign(void);
void i_moddotassign(void);
void i_modassign(void);
void i_varassign(void);
void assign(int type, int dottype);
void fakeval(void);
void recodeassign(Instnodep varinode,Instnodep eqinode);
void i_deleteit(void);
void i_deletearritem(void);
int recodedelete(Instnodep exprinode,Instnodep lastinode);
void i_readonlyit(void);
void i_onchangeit(void);
void i_eval(void);
