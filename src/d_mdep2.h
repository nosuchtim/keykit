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
