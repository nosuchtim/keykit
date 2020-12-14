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
