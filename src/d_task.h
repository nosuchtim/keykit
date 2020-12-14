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
