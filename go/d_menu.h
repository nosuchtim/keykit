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
