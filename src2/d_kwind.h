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
