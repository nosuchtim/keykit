
C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_grid.h 
#ifdef OLDSTUFF
#endif
void startgraphics(void);
void my_plotmode(int m);
void showsane(Kwind *w);
void redrawpwind(Kwind *w);
void drawbars(Kwind *w,int sx,int sy,int ex,int ey);
void centertext(char *s,int x,int y);
void righttext(char *s,int x,int y);
void gridphresh(Phrasepp aph);
int windorigx(Kwind *w);
#ifdef OLDKEYBOARDSTUFF
#endif
void drawph(Kwind *w,Phrasep p);
void setupchancolors(void);
void drawclipped(Kwind *w,Phrasep p,long sclicks,long eclicks,int spitch,int epitch,int sx,int sy,int ex,int ey);
void setnotecolor(Noteptr n, int color);
Noteptr closestnt(Kwind *w,Phrasep ph,int x,int y);
#ifdef DRAWNT_NO_LONGER_USED
void drawnt(Kwind *w,Noteptr n);
#endif
void drawnonnt(Kwind *w,Noteptr n,Krect *r);
char * nonnoteinfo(Kwind *w,Noteptr n,int *ay1,int *ay2);
#ifdef OLDSTUFF
#endif
char * textnoteinfo(Kwind *w,Noteptr n,int *ax1, int *ay1, int *ax2, int *ay2);
void nonnotesize(Noteptr n,int *apitch1,int *apitch2);
#ifdef OLDSTUFF
#endif
int ntbox(Kwind *w,Noteptr n,int *ax0,int *ay0,int *ax1,int *ay1,Krect *r);
int clipcode(Kwind *w,int x,int y,Krect *r);
int fullclipit(Kwind *w,int *x1,int *y1,int *x2,int *y2,Krect *r);
int rectclipit(Kwind *w,int *x1,int *y1,int *x2,int *y2,Krect *r);
void gridline(Kwind *w,long clks1,int pitch1,long clks2,int pitch2);
void gridtext(Kwind *w,long clks1,int pitch1,char *str);
int dispclip(Kwind *w,int *ax,int *ay,Krect *kr);
long longquant(long v,long q);
int pitchyraw(Kwind *w,int pitch);
int pitchtoy(Kwind *w,int pitch);
void xytogrid(Kwind *w,long x,long y,long *aclick,long *apitch,long quant);
void pharea(Phrasep ph,long *astart,long *aend,long *alow,long *ahigh);
void gridpan(Kwind *w,long cshift,int pshift);
#ifdef OLDKEYBOARDSTUFF
void drawkeyboard(Kwind *w,int erasefirst);
#endif

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_kwind.h 
void wredraw1(Kwind *w);
void woutline(Kwind *w);
void wshadow(Kwind *w,int menubutton,int pressed);
void werase(Kwind *w);
#ifdef OLDSTUFF
#endif
#ifdef OLDSTUFF
#endif
Kwind * validwind(int n,char *s);
Kwind * windptr(int n);
void windlist(void);
Kwind * windfinddeep(Kwind *w,int x,int y);
int windcontains(Kwind *w,long x0,long y0);
int windlevel(Kwind *w);
int windoverlaps(Kwind *w,long x0,long y0,long x1,long y1);
void reinitwinds(void);
void setwrootsize(void);
Datum winddatum(Kwind *w);
Kwind * newkwind(void);
void k_initphrase(Kwind *w);
void k_inittext(Kwind *w);
void k_reinittext(Kwind *w);
#if 0
#endif
void kwindtext(Symstr str,int kx0,int ky0,int kx1,int ky1,int just);
#ifdef OLDSTUFF
#endif
#ifdef OLDSTUFF
#endif
void textfill(char *s,int x0,int y0,int x1,int y1,int just);
void kwindline(Kwind *w,int x0,int y0,int x1,int y1);
void kwindrect(Kwind *w,int x0,int y0,int x1,int y1);
void kwindfill(Kwind *w,int x0,int y0,int x1,int y1);
void kwindrect2(Kwind *w,int x0,int y0,int x1,int y1,int dofill);
void kwindellipse(Kwind *w,int x0,int y0,int x1,int y1);
void kwindfillellipse(Kwind *w,int x0,int y0,int x1,int y1);
void kwindellipse2(Kwind *w,int x0,int y0,int x1,int y1,int dofill);
void kwindfillpolygon(Kwind *w,int *xarr,int *yarr,int arrsize);
#if 0
#endif
void rectnorml(long *ax0,long *ay0,long *ax1,long *ay1);
void rectnormi(int *ax0,int *ay0,int *ax1,int *ay1);
void scalexy(long *ax,long *ay,long fromx0,long fromy0,long fromx1,long fromy1,long tox0,long toy0,long tox1,long toy1);
void scalephr2raw(Kwind *w,long *ax,long *ay);
void scalegrid2wind(Kwind *w,long *ax,long *ay);
void scalewind2grid(Kwind *w,long *ax,long *ay);
void k_setsize(Kwind *w,int x0,int y0,int x1,int y1);
Kitem * newkitem(char *name);
Kitem * k_findmenuitem(Symstr name,Kwind *w,int create);
void windhashdelete(Kwind *w);
void wfree(Kwind *w);
void wunlink(Kwind *w,Kwind **tw);
void waddtolist(Kwind *w, Kwind **wlist);
void k_initmenu(Kwind *w);
Kitem * k_menuitem(Kwind *w,Symstr item);
Krect makerect(long x0, long y0, long x1, long y1);

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_main.h 
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

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_task.h 
#ifdef PYTHON
#endif
#ifdef DEBUGRUN
#endif
char * funcnameof(BYTEFUNC i);
Ktaskp taskptr(long tid);
void restartexec(void);
void makesuredefined(Datum **dpp,char *nm);
void checkports(void);
void handlewaitfor(int wn);
#ifdef PYTHON
#endif
void exectasks(int nosetjmp);
#ifdef PYTHON
#endif
#ifdef PYTHON
#endif
void loadsym(Symbolp s,int pushit);
#ifdef TRYTHISEVENTUALLY
#endif
void i_vareval(void);
void i_objvareval(void);
void i_funcnamed(void);
void i_lvareval(void);
void i_gvareval(void);
void i_varpush(void);
void i_objvarpush(void);
void i_callfunc(void);
void i_objcallfuncpush(void);
void i_objcallfunc(void);
void i_array(void);
void filelinetrace(void);
void i_linenum(void);
void i_filename(void);
#ifdef TRYWITHOUT
#endif
int printmeth(Hnodep h);
void i_pushinfo(void);
void i_popinfo(void);
void i_typeof(void);
void i_xy2(void);
void i_xy4(void);
void i_nargs(void);
void i_classinit(void);
void i_forin1(void);
void i_forin2(void);
void i_popnreturn(void);
void i_stop(void);
void i_select1(void);
void i_select2(void);
void i_select3(void);
void i_print(void);
void keyprintf(char *fmt,int arg0,int nargs, STRFUNC outfunc);
void checkmouse(void);
#ifdef NO_MOUSE_UP_DRAG_EVENTS
#endif
int handleconsole(void);
void doanint(void);
void i_goto(void);
void i_tfcondeval(void);
void i_tcondeval(void);
void i_constant(void);
void i_dotdotarg(void);
void i_varg(void);
void i_currobjeval(void);
void i_constobjeval(void);
void i_ecurrobjeval(void);
void i_erealobjeval(void);
void i_returnv(void);
void i_return(void);
void i_qmark(void);
void forinjumptoend(void);
void i_forinend(void);
void rmalltasksfifos(void);
void startreboot(void);
void nestinstruct(Codep cp);
void taskfunc0(Codep cp);
int pushdnodes(Dnode *dn,int move);
void taskfuncn(Codep cp,Dnode *dn);
void initstack(Ktaskp t);
Ktaskp newtask(Codep cp);
void setrunning(Ktaskp t);
void restarttask(Ktaskp t);
void taskunrun(Ktaskp t,int nstate);
int taskcollectchildren(Hnodep h);
void taskkill(Ktaskp t,int killchildren);
#ifdef DEBUGSTUFF
#endif
int taskunwait(Hnodep h);
void wakewaiters(Ktaskp t);
void taskbury(Ktaskp t);
void printrunning(char *s);
#ifdef TRYWITHOUT
void taskclear(Ktaskp t);
#endif
Ktaskp newtp(int state);
void linktask(Ktaskp p);
void freetp(Ktaskp t);
void deletetask(Ktaskp t);
void unlinktask(Ktaskp p);
void expandstack(Ktaskp p);
void expandstackatleast(Ktaskp p, int needed);
Codep infiniteloop(BYTEFUNC f);
void inittasks(void);
void eprfunc(BYTEFUNC i);

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_fifo.h 
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

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_code2.h 
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

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_code.h 
void resetstack(void);
void underflow(void);
void i_pop(void);
void clriseg(void);
void pushiseg(void);
Codep inodes2code(Instnodep inlist);
Codep popiseg(void);
void rminstnode(Instnodep t,Instnodep prei,int adjust);
void instnodepatch(Instnodep t,Instnodep i1,Instnodep i2);
void optiseg(Instnodep t);
Instnodep futureinstnode(void);
void addinode(Instnodep in);
Instnodep code(Instcode ic);
Instcode numinst(int n);
Instcode strinst(Symstr s);
Instcode dblinst(double d);
Instcode syminst(Symbolp s);
Instcode phrinst(Phrasep p);
Instcode instnodeinst(Instnodep n);
Instcode realfuncinst(BYTEFUNC f);
Instcode bltininst(BLTINCODE f);
Instnodep previnstnode(register Instnodep ilow,register Instnodep in);
Instcode* ptincode(register Instnodep in,register int n);
void i_dblpush(void);
void i_stringpush(void);
void i_phrasepush(void);
void makeroom(long n,char **aptr,long *asize);
void reinitmsg2(void);
void ptomsg2(register Symstr s);
void reinitmsg3(void);
void ptomsg3(register Symstr s);
Symstr phrstr(Phrasep p, int nl);
Symstr dtostr(Datum d);
Datum dtoindex(Datum d);
void expectarr(Datum d,Datum subs,char *s);
void i_arrend(void);
void i_arraypush(void);
void i_incond(void);
void startclass(Symbolp sp);
void endclass(Symbolp sp);
void startdef(register Symbolp sp);
void enddef(register Symbolp sp);
void callfuncd(Symbolp s);
#ifdef OLDSTUFF
void chkstk(void);
void prtstk(void);
#endif
void ret(Datum retd);
void redoarg0(Ktaskp t);
Datum * symdataptr(Symbolp s);
void i_divcode(void);
void i_par(void);
void i_amp(void);
Datum dlshift(Datum d1,Datum d2);
Datum drightshift(Datum d1,Datum d2);
void i_lshift(void);
void i_rightshift(void);
void i_negate(void);
void i_tilda(void);
void i_lt(void);
void i_gt(void);
void i_le(void);
void i_ge(void);
void i_ne(void);
void i_eq(void);
void i_regexeq(void);
int dcompare(Datum d1,Datum d2);
void i_and1(void);
void i_or1(void);
void i_not(void);
void prdatum(Datum d,STRFUNC outfunc,int quotes);
void i_noop(void);
void prstack(Datum *d);

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_util.h 
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

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_sym.h 
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

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_bltin.h 
void bi_debug(int argc);
#ifdef OLDSTUFF
#endif
#ifdef MDEBUG
#endif
#ifdef OLDSTUFF
#endif
Datum limitsarr(Phrasep ph);
void bi_sizeof(int argc);
void bi_limitsof(int argc);
void bi_prstack(int argc);
void bi_phdump(int argc);
int tasklistcollect(Hnodep h);
void bi_taskinfo(int argc);
void bi_oldtypeof(int argc);
#ifdef OLDSTUFF
#endif
void bi_string(int argc);
void bi_integer(int argc);
void bi_float(int argc);
void bi_phrase(int argc);
void bi_sin(int argc);
void bi_cos(int argc);
void bi_tan(int argc);
void bi_asin(int argc);
void bi_acos(int argc);
void bi_atan(int argc);
void bi_sqrt(int argc);
void bi_exp(int argc);
void bi_log(int argc);
void bi_log10(int argc);
void bi_pow(int argc);
void bi_readphr(int argc);
void bi_pathsearch(int argc);
void bi_ascii(int argc);
void bi_reboot(int argc);
int funcundefine(Hnodep hn);
void bi_refunc(int argc);
void bi_rekeylib(int argc);
void bi_midifile(int argc);
void bi_split(int argc);
void bi_cut(int argc);
void bi_midibytes(int argc);
#ifdef NTATTRIB
#endif
void bi_oldnargs(int argc);
#ifdef OLDSTUFF
#endif
void bi_error(int argc);
void bi_printf(int argc);
void bi_argv(int argc);
void nomidi(char *s);
void nographics(char *s);
void bi_realtime(int argc);
void bi_sleeptill(int argc);
#ifdef OLDSTUFF
#endif
void bi_wait(int argc);
void bi_lock(int argc);
void bi_unlock(int argc);
void bi_finishoff(int argc);
void bi_kill(int argc);
#ifdef DEBUGSTUFF
#endif
int chkprio(Hnodep h);
void bi_priority(int argc);
Dnode * grabargs(int fromargn,int toargn);
void bi_onexit(int argc);
void bi_onerror(int argc);
void bi_tempo(int argc);
void bi_substr(int argc);
void bi_sbbyes(int argc);
void bi_system(int argc);
void bi_chdir(int argc);
void lsdircallback(char *fname,int type);
void bi_lsdir(int argc);
void bi_filetime(int argc);
void bi_coreleft(int argc);
#ifdef CORELEFT
#else
#endif
void bi_currtime(int argc);
void bi_milliclock(int argc);
void bi_rand(int argc);
void bi_exit(int argc);
void bi_garbcollect(int argc);
void bi_funkey(int argc);
void bi_symbolnamed(int argc);
void bi_windobject(int argc);
void bi_sync(int argc);
void bi_browsefiles(int argc);
void bi_setmouse(int argc);
void bi_mousewarp(int argc);
long arraynumval(Htablep arr,Datum arrindex,char *err);
int getxy01(Htablep arr,long *ax0,long *ay0,long *ax1,long *ay1,int normalize,char *err);
Datum xy01arr(long x0,long y0,long x1,long y1);
Datum xyarr(long x0,long y0);
int addifnew(Hnodep h);
void addnonxy(Htablep newarr,Htablep arr);
void bi_oldxy(int argc);
#ifdef OLDSTUFF
#endif
void bi_attribarray(int argc);
void bi_screen(int argc);
void wsettrack(Kwind *w,char *trk);
void bi_colorset(int argc);
void bi_colormix(int argc);
void bi_get(int argc);
void bi_put(int argc);
void bi_flush(int argc);
void bi_fifoctl(int argc);
void bi_mdep(int argc);
void chkinputport(int portno);
void chkoutputport(int portno);
void bi_midi(int argc);
#ifndef MDEP_MIDI_PROVIDED
#else
#ifdef BADIDEA
#endif
#endif
void bi_bitmap(int argc);
void bi_help(int argc);
void bi_fifosize(int argc);
void validpitch(int n,char *s);
void bi_open(int argc);
void bi_close(int argc);
long newobjectid(void);
void bi_object(int argc);
void bi_objectlist(int argc);
void bi_objectinfo(int argc);
void bi_sprintf(int argc);
#ifdef MDEBUG
void bi_mmreset(int argc);
void bi_mmdump(int argc);
#endif
void bi_nullfunc(int argc);

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_meth.h 
void o_setinit(int argc);
#ifdef OLDSTUFF
#endif
void setelement(Kobjectp o,Symstr e,Datum d);
void setmethod(Kobjectp o,char *m,BLTINCODE i);
void setdata(Kobjectp o,char *m,Datum d);
Kobjectp defaultobject(long id,int complain);
void o_addchild(int argc);
#ifdef SAVEFORERRORCHECKING
void chksib(Kobjectp o1, char *s);
#endif
void o_removechild(int argc);
void o_children(int argc);
void o_addinherit(int argc);
void o_inherited(int argc);
Kwind* windid(Kobjectp o);
void o_size(int argc);
void o_contains(int argc);
void o_mousedo(int argc);
int needplotmode(char *meth,Datum d);
void o_lineboxfill(int argc,char *meth,KWFUNC f,int norm);
void o_fillpolygon(int argc);
void o_line(int argc);
void o_box(int argc);
void o_fill(int argc);
void o_ellipse(int argc);
void o_fillellipse(int argc);
void o_style(int argc);
void o_saveunder(int argc);
void o_restoreunder(int argc);
void o_textheight(int argc);
void o_textwidth(int argc);
void o_text(int argc,int just);
void o_printf(int argc);
void o_textcenter(int argc);
void o_textleft(int argc);
void o_textright(int argc);
void o_type(int argc);
void o_xmin(int argc);
void o_ymin(int argc);
void o_xmax(int argc);
void o_ymax(int argc);
void o_redraw(int argc);
void o_childunder(int argc);
void o_drawphrase(int argc);
void o_scaletogrid(int argc);
void o_scaletowind(int argc);
void o_closestnote(int argc);
void o_view(int argc);
void o_sweep(int argc);
void o_trackname(int argc);
void o_menuitem(int argc);
void o_menuitems(int argc);
Kobjectp windobject(long id,int complain,char *type);
#ifdef OLDSTUFF
#endif

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_phrase.h 
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

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_misc.h 
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

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_fsm.h 
void midiparse(register int inbyte);
void realmess(int inbyte);
void chanmsg(int inbyte);
void sysmess(int inbyte);
void biggermess(Unchar **amessage,int *aMessleng);

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_keyto.h 
void arrtomf(Htablep arr,char *fname);

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_mdep1.h 
void mdep_hello(int argc,char **argv);
void mdep_bye(void);
int mdep_changedir(char *d);
char * mdep_currentdir(char *buff,int leng);
int mdep_lsdir(char *dir, char *exp, void (*callback)(char *,int));
long mdep_filetime(char *fn);
int mdep_fisatty(FILE *f);
long mdep_currtime(void);
long mdep_coreleft(void);
int mdep_full_or_relative_path(char *path);
int mdep_makepath(char *dirname, char *filename, char *result, int resultsize);
#ifdef OLDSTUFF
#endif
#ifdef LOCALUNLINK
int unlink(const char *path);
#endif

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_mdep2.h 
#ifdef WINSOCK
#endif
#ifdef WINSOCK
#endif
#ifdef WINSOCK
#endif
void mdep_popup(char *s);
#if KEYDISPLAY
#endif
#if 0
#endif
#ifdef DEBUGTYPING
#endif
int mdep_statconsole(void);
int mdep_getconsole(void);
void saveportevent(void);
Datum joyinit(int millipoll);
void joyrelease(void);
#ifdef WINSOCK
#endif
#ifdef WINSOCK
#endif
#ifdef WINSOCK
#endif
#ifdef OLDSTUFF
#endif
#ifdef DEBUGTYPING
#endif
#ifdef DEBUGTYPING
#endif
void mdep_prerc(void);
void mdep_initcolors(void);
char * mdep_keypath(void);
char * mdep_musicpath(void);
void mdep_postrc(void);
void mdep_abortexit(char *s);
int mdep_shellexec(char *s);
void mdep_setinterrupt(SIGFUNCTYPE i);
void mdep_ignoreinterrupt(void);
#if KEYDISPLAY
#endif
int mdep_waitfor(int tmout);
#ifdef OLDSTUFF
#endif
#if KEYDISPLAY
#endif
#ifdef SAVEFORARAINYDAY
#endif
#ifdef FORTHEMOMENTNOWARNING
#endif
int mdep_startgraphics(int argc,char **argv);
#ifdef WINSOCK
#endif
char * mdep_browse(char *desc, char *types, int mustexist);
int mdep_screenresize(int x0, int y0, int x1, int y1);
int mdep_screensize(int *x0, int *y0, int *x1, int *y1);
int mdep_maxx(void);
int mdep_maxy(void);
void mdep_plotmode(int mode);
void mdep_endgraphics(void);
#ifdef WINSOCK
#endif
void mdep_destroywindow(void);
void mdep_line(int x0,int y0,int x1,int y1);
void mdep_box(int x0,int y0,int x1,int y1);
void mdep_boxfill(int x0,int y0,int x1,int y1);
#ifdef THETHOUGHTDIDNTCOUNT
#endif
void mdep_ellipse(int x0,int y0,int x1,int y1);
void mdep_fillellipse(int x0,int y0,int x1,int y1);
void mdep_fillpolygon(int *xarr,int *yarr,int arrsize);
Pbitmap mdep_allocbitmap(int xsize,int ysize);
Pbitmap mdep_reallocbitmap(int xsize,int ysize,Pbitmap pb);
void mdep_freebitmap(Pbitmap pb);
void mdep_movebitmap(int fromx0,int fromy0,int width,int height,int tox0,int toy0);
void mdep_pullbitmap(int x0,int y0,Pbitmap pb);
void mdep_putbitmap(int x0,int y0,Pbitmap pb);
int mdep_mouse(int *ax,int *ay, int *am);
int mdep_mousewarp(int x, int y);
void mdep_color(int n);
void mdep_colormix(int n,int r,int g,int b);
void mdep_sync(void);
char * mdep_fontinit(char *fnt);
int mdep_fontheight(void);
int mdep_fontwidth(void);
void mdep_string(int x, int y, char *s);
void mdep_setcursor(int type);
#ifdef WINSOCK
#ifdef OLDSTUFF
#endif
#ifdef OLDSTUFF
#endif
#if 0
#endif
int udp_send(PORTHANDLE mp,char *msg,int msgsize);
#endif
PORTHANDLE * mdep_openport(char *name, char *mode, char *type);
#ifdef WINSOCK
#endif
#ifdef WINSOCK
#endif
Datum mdep_ctlport(PORTHANDLE m, char *cmd, char *arg);
int mdep_putportdata(PORTHANDLE m, char *buff, int size);
#ifdef WINSOCK
#else
#endif
int mdep_getportdata(PORTHANDLE *handle, char *buff, int buffsize, Datum *pd);
#ifdef WINSOCK
#endif
int mdep_closeport(PORTHANDLE m);
#ifdef WINSOCK
#endif
int mdep_help(char *fname,char *keyword);
char * mdep_localaddresses(Datum d);
int my_ntohl(int v);

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_mfin.h 
int mgetc(void);
void k_header(int f,int n,int d);
#ifdef WARNEVEN
#endif
void k_starttrack(void);
void putnfree(void);
void putallnotes(void);
void k_endtrack(void);
void k_noteon(int chan,int pitch,int vol);
Noteptr queuenote(int chan,int pitch,int vol,int type);
void k_noteoff(int chan,int pitch,int vol);
void k_pressure(int chan,int pitch,int press);
void k_controller(int chan,int control,int value);
void k_pitchbend(int chan,int msb,int lsb);
void k_program(int chan,int program);
void k_chanpressure(int chan,int press);
void threebytes(int c1,int c2,int c3);
void twobytes(int c1,int c2);
void queuemess(Unchar *mess,int leng);
void k_arbitrary(int leng,Unchar *mess);
void k_tempo(long tempo);
void k_timesig(unsigned nn,unsigned dd,unsigned cc,unsigned bb);
void k_keysig(unsigned sf,unsigned mi);
void k_chanprefix(unsigned c);
void k_seqnum(int n);
void k_smpte(unsigned hr,unsigned mn,unsigned se,unsigned fr,unsigned ff);
void k_metatext(int type,int leng,Unchar *mess);
int mftoarr(char *mfname,Htablep arr);

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_midi.h 
int mdep_getnmidi(char *buff,int buffsize,int *port);
void mdep_putnmidi(int n, char *cp, Midiport * pport);
int openmidiin(int i);
#ifdef THIS_CAUSES_A_HANG_ON_SOME_SYSTEMS
#endif
void mdep_endmidi(void);
int mdep_initmidi(Midiport *inputs, Midiport *outputs);
#if THIS_MESSAGE_IS_BOGUS
#endif
void handlemidioutput(long long lParam, int windevno);
#if KEYCAPTURE
int startvideo(void);
void stopvideo(void);
#endif
#if KEYDISPLAY
int startdisplay(int noborder, int width, int height);
#endif
void setvideogrid(int gx, int gy);
Datum mdep_mdep(int argc);
#if KEYCAPTURE
#else
#endif
#if KEYDISPLAY
#endif
#if 0
#endif
int openmidiout(int windevno);
int mdep_midi(int openclose, Midiport * p);
#if 0
#endif
#ifdef EVENT_TIMESTAMP
#endif
void PutEvent(LPCIRCULARBUFFER lpBuf, LPEVENT lpEvent);

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_real.h 
void chksched(char *str);
void psched(void);
void resetcurrphr(void);
void initmidiport(Midiport *p);
void startrealtime(void);
void clrcontroller(void);
void newtempo(long t);
void resetreal(void);
void finishoff(void);
void addandput(int port, int n0, int chan, int c1,int c2);
#ifdef OLDSTUFF
void chkrealoften(void);
#endif
void chkinput(void);
void chkoutput(void);
Unchar * ustrchr(Unchar *pn,int n);
int chanofbyte(int b);
int execnt(register Sched *s, Sched *pres);
void toomany(char *onoff);
#ifdef OLDSTUFF
#endif
void rc_on(Unchar *mess,int indx);
void rc_off(Unchar *mess,int indx);
void rc_mess(Unchar *mess,int indx);
void rc_messhandle(Unchar *mess,int indx, int chan);
void rc_control(Unchar *mess,int indx);
void rc_pressure(Unchar *mess,int indx);
void rc_program(Unchar *mess,int indx);
void rc_chanpress(Unchar *mess,int indx);
void rc_pitchbend(Unchar *mess,int indx);
void rc_sysex(Unchar *mess,int indx);
void rc_position(Unchar *mess,int indx);
void rc_song(Unchar *mess,int indx);
void rc_startstopcont(Unchar *mess,int indx);
void rc_clock(Unchar *mess,int indx);
void chkcontroller(int port, Unchar* mess);
Noteptr  qnote(int chan);
#ifdef NTATTRIB
#endif
void noteon(register Noteptr q);
#ifdef NTATTRIB
#endif
void noteoff(Noteptr q);
#ifdef OLDSTUFF
#endif
#ifdef NTATTRIB
#endif
void notemess(Noteptr q);
#ifdef NTATTRIB
#endif
void ntrecord(Noteptr n);
#ifdef OLDSTUFF
#endif
void clrsched(Sched **as);
Sched * newsch(void);
void unsched(Task *t);
void freesch(register Sched *s);
Sched * immsched(int type,long clicks,Ktaskp tp,int monitor);
long taskphr(Phrasep ph, long clicks, long rep, int monitor);
void schdwake(long clicks);

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_view.h 
#ifndef MOVEBITMAP
#endif
Pbitmap v_reallocbitmap(int x,int y,Pbitmap p);
int v_linenorm(Kwind *w,int ln);
void v_settextsize(Kwind *w);
void v_setxy(Kwind *w);
void drawsweep(Kwind *w,int type,int x0,int y0,int x1,int y1);
long sanequant(Kwind *w,long qnt);
void dosweepstart(Kwind *w,int type,long x0,long y0,Fifo *mf);
void redrawmenu(Kwind *w);
void mouseblock(Fifo *mf);
void xyquant(Kwind *w,long *amx,long *amy,long quant,long *aclk,long *apitch);
void getmxy(Datum d,int *amx,int *amy,int *amval);
void fixxy(Kwind *w,long *amx,long *amy);
void i_dosweepcont(void);
char * ptbuffer(Kwind *w,int c);
void v_string(char *s);
void wprint(char *s);
void v_stringwind(char *s,Kwind *w);
void v_echar(Kwind *w);
void v_textdo(Kwind *w,int butt,int x,int y);
void v_texttobottom(Kwind *w);
int toplnum_decr(Kwind *w);
int toplnum_incr(Kwind *w);
int textscrollupdate(Kwind *w,int mx,int my);
void v_scrolldisplay(Kwind *w);
#ifdef MOVEBITMAP
#else
#endif
void v_scrollbuff(Kwind *w);
void drawtextbar(Kwind *w);
void redrawtext(Kwind *w);

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_regex.h 
char * myre_compX(char *pat);
#ifdef EXTEND
#endif
#ifdef EXTEND
#endif
char *      myre_comp(char *pat);
#ifdef __STDC__
#else
#endif
int myre_exec(register char *lp);
#ifdef __STDC__
#else
#endif
void myre_modw(register char *s);
int myre_subs(register char *src, register char *dst);
#ifdef REGEXDEBUG
#endif

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_clock.h 
long mdep_milliclock(void);
void mdep_resetclock(void);

C:\Users\tjt\go\src\github.com\vizicist\keykit\src>cat d_menu.h 
void menustringat(Kwind *w,int itempos,int itemnum);
void menuconstruct(Kwind *w,int existing);
void m_menuitem(Kwind *w,Kitem *ki);
void menusetsize(Kwind *w, int x0, int y0, int x1, int y1);
void menucalcxy(Kwind *w);
void drawchoice(Kwind *w,int unhigh);
void highchoice(Kwind *w);
void unhighchoice(Kwind *w);
int boundit(int val,int mn,int mx);
int scrollupdate(Kwind *w,int mx,int my);
#ifdef BETTERSCROLLING
#else
#endif
#ifdef BETTERSCROLLING
#else
#endif
#ifdef BETTERSCROLLING
#else
#endif
int menuchoice(Kwind *w,int x,int y);
void m_reset(void);
void m_init(void);
void m_menudo(Kwind *w,int b,int x,int y,int nodraw);
