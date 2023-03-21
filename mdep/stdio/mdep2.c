/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#include "key.h"

#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <signal.h>

#define NOCHAR -2

extern int errno;

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
printf("mdep_statconsole called, this shouldn't be happening in stdio support!?\n");
	return 0;
}

/* getconsole - Return the next console character.  It's okay to hang, because */
/*              statconsole is used beforehand. */

int
mdep_getconsole(void)
{
printf("mdep_getconsole called, this shouldn't be happening in stdio support!?\n");
	return(EOF);
}

static char *
keyroot(void)
{
	static char *root = NULL;
	if ( root == NULL ) {
		if ( (root=getenv("KEYROOT")) == NULL )
			root = "..";
		root = uniqstr(root);
	}
	return root;
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
                eprint("Warning - you sure you want to set KEYPATH from the environment?\n");
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

int
mdep_makepath(char *dirname, char *filename, char *result, int resultsize)
{
	if ( resultsize < (int)(strlen(dirname)+strlen(filename)+5) )
		return 1;

	strcpy(result,dirname);
	if ( *dirname != '\0' )
		strcat(result,"/");
	strcat(result,filename);
	return 0;
}

int
mdep_full_or_relative_path(char *fname)
{
	if ( *fname == '/' || *fname == '.' )
		return 1;
	else
		return 0;
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
	dummyusage(lbl);
	dummyusage(expr);
	dummyusage(mustexist);
	return NULL;
}

int
mdep_shellexec(char *s)
{
	dummyusage(s);
	return 0;
}

void
mdep_putconsole(char *s)
{
	fputs(s,stdout);
	(void) fflush(stdout);
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
	dummyusage(tmout);
	return K_TIMEOUT;
}

int
mdep_startgraphics(int argc,char **argv)
{
	extern int Consolefd;

	dummyusage(argc);
	dummyusage(argv);
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
	dummyusage(x0);
	dummyusage(y0);
	dummyusage(x1);
	dummyusage(y1);
}

void
mdep_fillpolygon(int *xarr, int *yarr, int arrsize)
{
	dummyusage(xarr);
	dummyusage(yarr);
	dummyusage(arrsize);
}

int
mdep_mouse(int *ax,int *ay,int *am)
{
	*ax = 0;
	*ay = 0;
	*am = 0;
	return 0;
}

int
mdep_mousewarp(int x, int y)
{
	dummyusage(x);
	dummyusage(y);
	return 0;
}

void
mdep_plotmode(int m)
{
	dummyusage(m);
}

void
mdep_line(int x0,int y0,int x1,int y1)
{
	dummyusage(x0);
	dummyusage(y0);
	dummyusage(x1);
	dummyusage(y1);
}

void
mdep_ellipse(int x0,int y0,int x1,int y1)
{
	dummyusage(x0);
	dummyusage(y0);
	dummyusage(x1);
	dummyusage(y1);
}

void
mdep_fillellipse(int x0,int y0,int x1,int y1)
{
	dummyusage(x0);
	dummyusage(y0);
	dummyusage(x1);
	dummyusage(y1);
}

void
mdep_box(int x0,int y0,int x1,int y1)
{
	dummyusage(x0);
	dummyusage(y0);
	dummyusage(x1);
	dummyusage(y1);
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
	dummyusage(x);
	dummyusage(y);
	dummyusage(p);
}

void
mdep_sync(void)
{
}

void
mdep_putbitmap(int x,int y,Pbitmap p)
{
	dummyusage(x);
	dummyusage(y);
	dummyusage(p);
}

void
mdep_movebitmap(int x,int y,int wid,int hgt,int tox,int toy)
{
	dummyusage(x);
	dummyusage(y);
	dummyusage(wid);
	dummyusage(hgt);
	dummyusage(tox);
	dummyusage(toy);
}

int
mdep_screenresize(int x0, int y0, int x1, int y1)
{
	dummyusage(x0);
	dummyusage(y0);
	dummyusage(x1);
	dummyusage(y1);
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
	dummyusage(type);
}

char *
mdep_fontinit(char *fontname)
{
	dummyusage(fontname);
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
	dummyusage(x);
	dummyusage(y);
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
	dummyusage(n);
}

void
mdep_colormix(int n,int r,int g,int b)
{
	dummyusage(n);
	dummyusage(r);
	dummyusage(g);
	dummyusage(b);
}

PORTHANDLE *
mdep_openport(char *name, char *mode, char *type)
{
	dummyusage(name);
	dummyusage(mode);
	dummyusage(type);
	return NULL;
}

Datum
mdep_ctlport(PORTHANDLE m, char *cmd, char *arg)
{
	dummyusage(m);
	dummyusage(cmd);
	dummyusage(arg);
	return(Noval);
}

Datum
mdep_mdep(int argc)
{
	dummyusage(argc);
	return(Noval);
}

int
mdep_putportdata(PORTHANDLE m, char *buff, int size)
{
	dummyusage(m);
	dummyusage(buff);
	dummyusage(size);
	return 0;
}

int
mdep_getportdata(PORTHANDLE *handle, char *buff, int buffsize, Datum *pd)
{
	dummyusage(handle);
	dummyusage(buff);
	dummyusage(buffsize);
	dummyusage(pd);
	return 0;
}

int
mdep_closeport(PORTHANDLE m)
{
	dummyusage(m);
	return 0;
}

int
mdep_help(char *fname, char *keyword)
{
	dummyusage(fname);
	dummyusage(keyword);
	return 1;
}
