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
