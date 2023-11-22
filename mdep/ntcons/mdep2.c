/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#include <windows.h>

#include "key.h"

#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <signal.h>

#define SEPARATOR "\\"

#define NOCHAR -2

// extern int errno;

static int Isatty = 0;
static int Nextchar = NOCHAR;
static int Conseof = 0;

Symlongp Cursereverse, Privatemap, Sharedmap, Forkoff;

typedef struct Point {
	short	x;
	short	y;
} Point;

typedef struct MyRectangle {
	Point origin;
	Point corner;
} MyRectangle;

typedef struct MyBitmap {
	MyRectangle rect;
} MyBitmap;

#ifdef __STDC__
typedef const char *Bitstype;
#else
typedef unsigned char *Bitstype;
#endif

static int Msx, Msy, Msb, Msm;	/* Mouse x, y, buttons, modifier */
static Point Dsize;
static MyRectangle Rawsize;
static MyBitmap Disp;
static int Inwind = 1;
static int Ncolors;
static int Sharecolors;
static int defscreen;
static int defdepth;
static SIGFUNCTYPE Intrfunc;

static Point
Pt(int x,int y)
{
	Point p;

	p.x = (short)x;
	p.y = (short)y;
	return p;
}

static MyRectangle
Rect(int x1,int y1,int x2,int y2)
{
	MyRectangle r;

	r.origin.x = (short)x1;
	r.origin.y = (short)y1;
	r.corner.x = (short)x2;
	r.corner.y = (short)y2;
	return r;
}

void
mdep_setinterrupt(SIGFUNCTYPE i)
{
	Intrfunc = i;
	(void) signal(SIGINT,i);
	(void) signal(SIGFPE,i);
	(void) signal(SIGILL,i);
	(void) signal(SIGSEGV,i);
	(void) signal(SIGTERM,i);
}

void
mdep_ignoreinterrupt(void)
{
	(void) signal(SIGINT, SIG_IGN);
	(void) signal(SIGFPE, SIG_IGN);
	(void) signal(SIGILL, SIG_IGN);
	(void) signal(SIGSEGV, SIG_IGN);
	(void) signal(SIGTERM, SIG_IGN);
}

int
mdep_statconsole(void)
{
printf("mdep_statconsole called, this shouldn't be happening in NT console support!?\n");
	return 0;
}

/* getconsole - Return the next console character.  It's okay to hang, because */
/*              statconsole is used beforehand. */

int
mdep_getconsole(void)
{
printf("mdep_getconsole called, this shouldn't be happening in NT console support!?\n");
	return(EOF);
}

static char *
keyroot(void)
{
	int first = 1;
	static char *p;
	char buff[BUFSIZ];
	int sz;

	if ( !first )
		return p;
	first = 0;
	/* KEYROOT environment variable overrides! */
	if ( (p=getenv("KEYROOT")) == NULL ) {
		sz = GetModuleFileName(NULL,buff,BUFSIZ);
		if ( sz == 0 ) {
			printf("Hmm, GetModuleFileName fails!?  Trying KEYROOT=..\n");
			p = "..";
		}
		else {
			char *q = strrchr(buff,SEPARATOR[0]);
			if ( q ) {
				*q = '\0';
				q = strrchr(buff,SEPARATOR[0]);
			}
			if ( q == NULL ) {
				printf("Hmm, buff=%s doesn't have a directory?!?  Trying KEYROOT=..\n",buff);
				p = "..";
			}
			else {
				*q = '\0';
				p = strsave(buff);
			}
		}
	}
	return p;
}

void
mdep_prerc(void)
{
	extern Symlongp Merge;
	extern int Usestdio;

	Usestdio = 1;
	*Merge = 1;
	*Graphics = 0;
	*Colors = KEYNCOLORS;
	installnum("Cursereverse",&Cursereverse,0L);
	*Windowsys = uniqstr("stdio");
	*Pathsep = uniqstr(PATHSEP);
	*Keyroot = uniqstr(keyroot());
}

char *
mdep_musicpath(void)
{
	char *p, *str;
	char *r = keyroot();

	p = (char *) kmalloc((unsigned)(3*strlen(r)+64),"mdep_musicpath");
	sprintf(p,".%s%s%smusic%s%s%smidifiles",
		PATHSEP,r,SEPARATOR,
		PATHSEP,r,SEPARATOR);
        str = uniqstr(p);
        kfree(p);
        return str;
}

char *
mdep_keypath(void)
{
        char *p, *path;
	char *r = keyroot();

        if ( (p=getenv("KEYPATH")) != NULL && *p != '\0' ) {
                path = uniqstr(p);
        }
        else {
                /* The length calculation here is inexact but liberal */
                p = (char *) kmalloc((unsigned)(2*strlen(r)+128),"mdep_keypath");
                sprintf(p,".%s%s%sliblocal%s%s%slib",
                        PATHSEP,r,SEPARATOR,PATHSEP,r,SEPARATOR);
                path = uniqstr(p);
                kfree(p);
        }
        return path;
}

void
mdep_postrc(void)
{
}

void
mdep_abortexit(char *s)
{
	fprintf(stderr,"KeyKit aborts! %s\n",s?s:"");
	exit(1);
}

char *
mdep_browse(char *lbl, char *expr, int mustexist)
{
	return NULL;
}

int
mdep_shellexec(char *s)
{
	return system(s);
}

void
mdep_hidemouse(void)
{
}

void
mdep_showmouse(void)
{
}

int
mdep_waitfor(int tmout)
{
	return K_TIMEOUT;
}

int
mdep_startgraphics(int argc,char **argv)
{
	extern int Consolefd;
	Consolefd = 0;
	return 0;
}

void
mdep_endgraphics(void)
{
}

void
mdep_boxfill(int x0,int y0,int x1,int y1)
{
}

void
mdep_fillpolygon(int *xarr, int *yarr, int arrsize)
{
}

int
mdep_mouse(int *ax,int *ay,int *am)
{
	*ax = 0;
	*ay = 0;
	*am = MOUSE_MOD_NONE;
	return MOUSE_BTN_NONE;
}

int
mdep_mousewarp(int x, int y)
{
	return 0;
}

void
mdep_plotmode(int m)
{
}

void
mdep_line(int x0,int y0,int x1,int y1)
{
}

void
mdep_ellipse(int x0,int y0,int x1,int y1)
{
}

void
mdep_fillellipse(int x0,int y0,int x1,int y1)
{
}

void
mdep_box(int x0,int y0,int x1,int y1)
{
}

static MyBitmap *
balloc (MyRectangle r)
{
	MyBitmap *b;

	b = (MyBitmap *)malloc(sizeof (struct MyBitmap));
	b->rect=r;
	return b;
}

static void
bfree(MyBitmap *b)
{
	if(b){
		free((char *)b);
	}
}


Pbitmap
mdep_allocbitmap(int x,int y)
{
	Pbitmap p;
	p.xsize = p.origx = (INT16)x;
	p.ysize = p.origy = (INT16)y;
	p.ptr = (unsigned char *) balloc(Rect(0,0,x,y));
	return p;
}

Pbitmap
mdep_reallocbitmap(int x,int y,Pbitmap p)
{
	if ( p.ptr )
		bfree((MyBitmap*)(p.ptr));
	p.xsize = p.origx = (INT16)x;
	p.ysize = p.origy = (INT16)y;
	p.ptr = (unsigned char *) balloc(Rect(0,0,x,y));
	return p;
}

void
mdep_freebitmap(Pbitmap p)
{
	if ( p.ptr )
		bfree((MyBitmap*)(p.ptr));
}

void
mdep_pullbitmap(int x,int y,Pbitmap p)
{
}

void
mdep_sync(void)
{
}

void
mdep_putbitmap(int x,int y,Pbitmap p)
{
}

void
mdep_movebitmap(int x,int y,int wid,int hgt,int tox,int toy)
{
}

int
mdep_screenresize(int x0, int y0, int x1, int y1)
{
	return 0;
}

int
mdep_screensize(int *x0, int *y0, int *x1, int *y1)
{
	*x0 = 0;
	*y0 = 0;
	*x1 = 0;
	*y1 = 0;
	return 0;
}

int
mdep_maxx(void)
{
	return 0;
}
int
mdep_maxy(void)
{
	return 0;
}

void
mdep_setcursor(int type)
{
}

char *
mdep_fontinit(char *fontname)
{
	return NULL;
}

int
mdep_fontwidth(void)
{
	return 1;
}

int
mdep_fontheight(void)
{
	return 1;
}

void
mdep_string(int x,int y,char *s)
{
	printf("%s",s);
}

void
mdep_popup(char *s)
{
	printf("%s",s);
}

void
mdep_initcolors(void)
{
}

void
mdep_color(int n)
{
}

void
mdep_colormix(int n,int r,int g,int b)
{
}

PORTHANDLE *
mdep_openport(char *name, char *mode, char *type)
{
	return NULL;
}

Datum
mdep_ctlport(PORTHANDLE m, char *cmd, char *arg)
{
	return(Noval);
}

Datum
mdep_mdep(int argc)
{
	return(Noval);
}

int
mdep_putportdata(PORTHANDLE m, char *buff, int size)
{
	return 0;
}

int
mdep_getportdata(PORTHANDLE *handle, char *buff, int buffsize, Datum *pd)
{
	return 0;
}

int
mdep_closeport(PORTHANDLE m)
{
	return 0;
}

int
mdep_help(char *fname,char *keyword)
{
	return(1);
}
