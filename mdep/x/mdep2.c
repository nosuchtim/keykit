/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

/*
 * X11 support
 */

#include "key.h"

#include <termio.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <signal.h>
#include <sys/time.h>
#include <sys/errno.h>
/* SunOS doesn't have ulimit.h */
/* #include <ulimit.h> */
#include <stropts.h>
#include <poll.h>
#include <sys/resource.h>

#ifndef NOSOCKETS
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#endif

#define NOCHAR -2

extern int errno;

#ifdef TTYSTUFF
static int Isatty = 0;
static int Initdone = 0;
static struct termio Initterm;
#endif
static int Nextchar = NOCHAR;
static int Pollable = 1;
static int Conseof = 0;
static int Windevent = 0;
static struct pollfd Fds[8];
static int Nsockfds = 0;
#define FDS_CONSOLE 0
#define FDS_DISPLAY 1
#define FDS_MIDI 2
#define FDS_SOCKETS 3

/* For solaris 2.6, someone said this was needed */
/* to access fields of the Display structure */
#define XLIB_ILLEGAL_ACCESS 1

#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>

Symlongp Cursereverse, Privatemap, Sharedmap, Forkoff, Nobrowsefiles;

typedef struct Point {
	short	x;
	short	y;
} Point;

typedef struct Rectangle {
	Point origin;
	Point corner;
} Rectangle;

typedef struct Bitmap {
	Drawable dr;
	Rectangle rect;
} Bitmap;

#ifdef __STDC__
typedef const char *Bitstype;
#else
typedef unsigned char *Bitstype;
#endif

/*
 * Function Codes
 */
#define	F_STORE	(GXcopy)		/* target = source */
#define	F_OR	(GXor)			/* target |= source */
#define	F_CLR	(GXandInverted)		/* target &= ~source */
#define	F_XOR	(GXxor)			/* target ^= source */

#define button1()		((Msb&4)!=0)
#define button2()		((Msb&2)!=0)
#define button3()		((Msb&1)!=0)
#define button123()		((Msb&7)!=0)

/* list of Fonts, in the order they are searched for */
static char *Fntlist[] = {
	"rom11x16",	/* for 730X */
	"*-lucidatypewriter-bold-r-*-14-140-*",
	"lucidasanstypewriter-bold",
	"fgb-13",
	"fixed",
	NULL
};

static XFontStruct *Currfont = NULL;
static int Msx, Msy, Msb, Msm;	/* Mouse x, y, buttons, modifier */
static int FMode = F_STORE;
static int Mfontxsize;
static int Mfontysize;
static Point Dsize;
static Rectangle Rawsize;
static Bitmap Disp;
static int Graphing = 0;
static int Inwind = 1;
static GC gc;
static Display *dpy = NULL;
static int fgpix, bgpix;
static Colormap	colormap;
static XColor *colors;
static int Ncolors;
static int Sharecolors;
static int defscreen;
static int defdepth;
static int Backpix, Forepix;
static unsigned long inputmask = ButtonPressMask|ButtonReleaseMask|ButtonMotionMask|
				 StructureNotifyMask|ExposureMask|KeyPressMask|
				 PointerMotionHintMask|ColormapChangeMask|
				 EnterWindowMask|LeaveWindowMask|
				 FocusIn|FocusOut;
static SIGFUNCTYPE Intrfunc;

#define KBDBUFSIZE	128
static unsigned char kbdbuffer[KBDBUFSIZE];	/* buffer for kbd input */
static struct {
	unsigned char *buf;
	unsigned char *in;
	unsigned char *out;
	int cnt;
	int size;
} kbdbuf = {kbdbuffer, kbdbuffer, kbdbuffer, 0, KBDBUFSIZE};

#undef button

int Last_p_mode = -1;

static void
resetmode(void)
{
	Last_p_mode = -1;
}

static Point
Pt(int x,int y)
{
	Point p;

	p.x = (short)x;
	p.y = (short)y;
	return p;
}

static Rectangle
Rect(int x1,int y1,int x2,int y2)
{
	Rectangle r;

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
	(void) signal(SIGPIPE,i);
	(void) signal(SIGEMT,i);
	(void) signal(SIGBUS,i);
}

void
mdep_ignoreinterrupt(void)
{
	(void) signal(SIGINT, SIG_IGN);
	(void) signal(SIGFPE, SIG_IGN);
	(void) signal(SIGILL, SIG_IGN);
	(void) signal(SIGSEGV, SIG_IGN);
	(void) signal(SIGTERM, SIG_IGN);
	(void) signal(SIGPIPE, SIG_IGN);
	(void) signal(SIGEMT, SIG_IGN);
	(void) signal(SIGBUS, SIG_IGN);
}

static void
millisleep(int n)
{
	struct pollfd fds[1];
	int r;

	r = poll(fds,0,n);
	if ( r < 0 ) {
		char msg[100];
		sprintf(msg,"poll() = %d in millisleep(%d)?  (errno=%d)\n",
			r,n,errno);
		mdep_popup(msg);
	}
}

static int
kbdchar(void)
{
	int i;

	if(!kbdbuf.cnt)
		return -1;
	i = *kbdbuf.out++;
	if(kbdbuf.out == &kbdbuf.buf[kbdbuf.size])
		kbdbuf.out = kbdbuf.buf;
	kbdbuf.cnt--;
	return(i);
}

static int
updatedrect(XEvent ev)
{
	Rawsize = Rect(
		ev.xconfigure.x,
		ev.xconfigure.y,
		ev.xconfigure.x+ev.xconfigure.width,
		ev.xconfigure.y+ev.xconfigure.height);

	if (Disp.rect.corner.x == ev.xconfigure.width &&
		    Disp.rect.corner.y == ev.xconfigure.height)
			return 0;
	Disp.rect.corner.x = (short)(ev.xconfigure.width);
	Disp.rect.corner.y = (short)(ev.xconfigure.height);
	Dsize = Disp.rect.corner;
	return 1;
}

static int
state2modifier(int s)
{
	int m;
	if ( s & ShiftMask )
		m = 2;
	else if ( s & ControlMask )
		m = 1;
	else
		m = 0;
	return(m);
}

static int
handle1input(void)
{
	XEvent ev;
	KeySym key;
	unsigned char s[128], *cp;
	int n, t, r;
	Window rw, cw;
	int xr, yr, xw, yw;
	unsigned bstate;

	XNextEvent(dpy, &ev);
	switch (ev.type) {
	case ButtonPress:
		XSetInputFocus(dpy,Disp.dr,RevertToPointerRoot,CurrentTime);
		Msb |= (8 >> ev.xbutton.button);
		Msm = state2modifier(ev.xbutton.state);
		Msx = ev.xbutton.x;
		Msy = ev.xbutton.y;
		return K_MOUSE;

	case ButtonRelease:
		Msb &= ~(8 >> ev.xbutton.button);
		Msm = state2modifier(ev.xbutton.state);
		Msx = ev.xbutton.x;
		Msy = ev.xbutton.y;
		return K_MOUSE;

	case MotionNotify:
		n = XQueryPointer(dpy,Disp.dr,&rw,&cw,&xr,&yr,&xw,&yw,&bstate);
		if(button123() && bstate==0)
			break;
		Msm = state2modifier(bstate);
		Msx = xw;
		Msy = yw;
		return K_MOUSE;

	case MapNotify:
	case NoExpose:
		break;

	case ConfigureNotify:
		if ( updatedrect(ev) )
			return K_WINDRESIZE;
		break;

	/* When the pointer leaves the window, the colormap gets */
	/* changed back.  When it re-enters the window, I want */
	/* to restore the map.  This code does that, but causes an */
	/* unnecessary flicker that should eventually be eliminated. */
	case ColormapNotify:
		if ( Inwind == 1 && *Privatemap )
			XInstallColormap(dpy, colormap);
		break;

	case EnterNotify:
		Inwind = 1;
		if ( *Privatemap )
			XInstallColormap(dpy, colormap);
		break;

	case LeaveNotify:
		Inwind = 0;
		break;

	case FocusIn:
		break;

	case FocusOut:
		break;

	case Expose:
		if (ev.xexpose.count == 0) {
			static long lastexpose = 0;
			long tm = mdep_milliclock();
			/* FIX - 5/4/97 - related to time wrapping around */
			if ( tm < lastexpose)
				lastexpose = 0;
			if ( lastexpose!=0 && (tm-lastexpose)<*Redrawignoretime)
				break;
			lastexpose = tm;
			t = ev.type;
			r = K_WINDEXPOSE;
			/* skip over any additional pending Exposes */
			while ( XPending(dpy) ) {
				XPeekEvent(dpy,&ev);
				if ( t!=Expose && t!=ConfigureNotify )
					break;
				if ( t==ConfigureNotify && updatedrect(ev) )
					r |= K_WINDRESIZE;
				XNextEvent(dpy, &ev);
			}
			return r;
		}
		break;

	case KeyPress:
		Msx = ev.xkey.x;
		Msy = ev.xkey.y;
		n = XLookupString(&(ev.xkey), (char*)s, sizeof(s), &key, NULL);

		/* Function keys are turned into escape sequences. */
		/* F1 == ESC-'a', F2 == ESC-'b', etc. */
		if ( IsFunctionKey(key) ) {
			s[0] = '\033';
			s[1] = key - XK_F1 + 'a';
			n = 2;
		}

		if ( n > 0 ) {
			cp = s;
			if ( *s == Intrchar && Intrfunc != NULL ) {
				(*Intrfunc)();
			}
			do{
				if(kbdbuf.cnt == kbdbuf.size) {
					mdep_popup("Too many chars in kbdbuf?\n");
					break;
				}
				*kbdbuf.in++ = *cp++;
				kbdbuf.cnt++;
				if(kbdbuf.in == &kbdbuf.buf[kbdbuf.size])
					kbdbuf.in = kbdbuf.buf;
			} while (--n);
			return K_CONSOLE;
		}
		break;
	}
	return K_NOTHING;
}

static void
handleinput(void)
{
	int k;
	while(XPending(dpy)) {
		k = handle1input();
		if ( k == K_WINDEXPOSE || k == K_WINDRESIZE )
			Windevent |= k;
	}
}

int
mdep_statconsole(void)
{
	struct pollfd fds[1];
	int n;

	if ( Nextchar!=NOCHAR )
		return 1;

	if ( Graphing ) {
		handleinput();
		Nextchar = kbdchar();
		if ( Nextchar == EOF )
			Nextchar = NOCHAR;
		if ( Nextchar == NOCHAR )
			return(0);
		else
			return(1);
	}
	if ( !Pollable )
		return oldstatconsole();

	fds[0].fd = Consolefd;
	fds[0].events = POLLIN;
	n = poll(fds,1,0);
	if ( n < 0 ) {
		char msg[100];
		sprintf(msg,"Hey, poll() returns %d?  (errno=%d)\n",n,errno);
		mdep_popup(msg);
	}
	return n > 0;
}

int
oldstatconsole(void)
{
	int n;
	char inbuf[2];

	if ( fcntl(0, F_SETFL, O_NDELAY) < 0 )
		mdep_popup("Error A in fcntl?\n");
	n = read(0,inbuf,1);
	if ( fcntl(0, F_SETFL, 0) < 0 )
		mdep_popup("Error B in fcntl?\n");

	Nextchar = (n>0) ? inbuf[0] : NOCHAR;
	if ( Nextchar == NOCHAR )
		return(0);
	else
		return(1);
}

static int
my_isastream(int fd)
{
	struct pollfd fds[1];

	fds[0].fd = fd;
	fds[0].events = POLLIN;
	errno = 0;
	(void) poll(fds,1,0);
	return ( errno == 0 );
}

/* getconsole - Return the next console character.  It's okay to hang, because */
/*              statconsole is used beforehand. */

int
mdep_getconsole(void)
{
	int c;

	if ( Conseof ) {
		return EOF;
	}
	if ( Graphing )
		handleinput();

	if ( Nextchar != NOCHAR ) {
		c = Nextchar;
		Nextchar = NOCHAR;
		return c;
	}

	if ( Graphing ) {
		while ( (c=kbdchar()) == EOF ) {
			(void) mdep_waitfor(9999);
		}
	}
	else
	{
		errno = 0;
		c = getchar();
		if ( c < 0 && errno == EINTR )
			c = Intrchar;
		else if ( c == EOF ) {
			Conseof = 1;
		}
	}
	return(c);
}

static void
nopoll(void)
{
	Pollable = 0;
	mdep_popup("poll() unusable, CPU time will be accumulated continuously.\n");
}

#ifdef TRYWITHOUT
static void
ttysetraw(void)
{
	struct termio termbuff;
	int fd = 0;

	if ( ioctl(fd,TCGETA,&Initterm) < 0 ) {
		sprintf(Msg1,"Error in ioctl(%d,TCGETA) in ttysetraw()?  errno=%d\n",fd,errno);
		mdep_popup(Msg1);
	}

	/* put terminal in raw mode */
	termbuff = Initterm;
	termbuff.c_lflag &= (~ICANON);
	termbuff.c_lflag &= (~ECHO);
#ifdef ECHOCTL
	termbuff.c_lflag &= (~ECHOCTL);
#endif
	termbuff.c_cc[4] = 1;
	termbuff.c_cc[5] = 1;

	if ( ioctl(fd,TCSETA,&termbuff) < 0 ) {
		sprintf(Msg1,"Error in ioctl(%d,TCSETA) in ttysetraw()?  errno=%d\n",fd,errno);
		mdep_popup(Msg1);
	}
	Initdone = 1;
}
#endif

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
	char *p;

	*Merge = 1;
	*Panraster = 0;
	*Resizeignoretime = 200;
	*Redrawignoretime = 200;
	*Colors = KEYNCOLORS;
	*Fontname = uniqstr(Fntlist[0]);
	installnum("Cursereverse",&Cursereverse,0L);
	installnum("Privatemap",&Privatemap,0L);
	installnum("Sharedmap",&Sharedmap,0L);
	installnum("Nobrowsefiles",&Nobrowsefiles,1L);
	installnum("Forkoff",&Forkoff,1L);
	if ( getenv("OPENWINHOME") != NULL ) {
		*Windowsys = uniqstr("OpenWindows");
		*Sharedmap = 1;
	}
	else {
		*Windowsys = uniqstr("X");
	}
	*Keyroot = uniqstr(keyroot());

#ifdef sun
	{
	extern Symstrp Machine;
	*Machine = uniqstr("sun");
	}
#endif
}

void
mdep_initcolors(void)
{
	int n = 256;
	char *p = getenv("KEYINVERSE");

	if ( p != NULL && *p != '0' ) {
		mdep_colormix(0, 0, 0, 0 );		/* black */
		mdep_colormix(1, 255*n, 255*n, 255*n);	/* white */
		mdep_colormix(2, 255*n, 0, 0	);	/* red, for Pickcolor */
		mdep_colormix(3, 100*n, 100*n, 100*n);	/* */
		mdep_colormix(4, 200*n, 200*n, 200*n);	/* button pressed */
		mdep_colormix(5, 50*n, 50*n, 100*n);	/* button background */
	}
	else {
		mdep_colormix(0, 255*n, 255*n, 255*n);	/* white */
		mdep_colormix(1, 0, 0, 0 );		/* black */
		mdep_colormix(2, 255*n, 0, 0	);	/* red, for Pickcolor */
		mdep_colormix(3, 200*n, 200*n, 200*n);	/* */
		mdep_colormix(4, 100*n, 100*n, 100*n);	/* button pressed */
		mdep_colormix(5, 210*n, 210*n, 210*n);	/* button background */
	}
}

char *
mdep_musicpath(void)
{
	char *p, *str;

	p = (char *) malloc((unsigned)(3*strlen(keyroot())+64));
	sprintf(p,".%s%s/music",*Pathsep,keyroot());
        str = uniqstr(p);
        kfree(p);
        return str;
}

char *
mdep_keypath(void)
{
        char *p, *path;

        if ( (p=getenv("KEYPATH")) != NULL && *p != '\0' ) {
                path = uniqstr(p);
        }
        else {
                /* The length calculation here is inexact but liberal */
                p = (char *) malloc((unsigned)(2*strlen(keyroot())+128));
                sprintf(p,".%s%s/liblocal%s%s/lib",
                        *Pathsep,keyroot(),*Pathsep,keyroot());
                path = uniqstr(p);
                kfree(p);
        }
        return path;
}

int
mdep_makepath(char *dirname, char *filename, char *result, int resultsize)
{
	char *p, *q;

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
	/* NOTE: this isn't really used if NOBROWSESUPPORT is set in mdep.h. */
	/* fill in someday, when there's a standard file selection dialog */
	return NULL;
}

int
mdep_shellexec(char *s)
{
	FILE *f;
	char buff[BUFSIZ];
	int r = 1;

	sprintf(buff,"sh -c '%s' 2>&1",s);
	f = popen(buff,"r");
	if ( f ) {
		while ( fgets(buff,BUFSIZ,f) != NULL )
			tprint(buff);
		r = pclose(f);
		r >>= 8;	/* to get real exit code */
	}
	return r;
}

void
mdep_putconsole(char *s)
{
	fputs(s,stdout);
	(void) fflush(stdout);
}

static void
clearrect(int x0,int y0,int x1,int y1)
{
 	XSetFunction(dpy,gc,F_STORE);
 	XSetForeground(dpy,gc,bgpix);
	resetmode();
	XFillRectangle(dpy, Disp.dr, gc, x0,y0, x1-x0,y1-y0);
}

static void
bitblt (Bitmap *sb,Rectangle r,Bitmap *db,Point p,int f)
{
	int wd = r.corner.x - r.origin.x;
	int ht = r.corner.y - r.origin.y;

	XSetFunction(dpy, gc, f);
	if ( f == F_XOR )
		XSetForeground(dpy, gc, fgpix^bgpix);
	else
		XSetForeground(dpy,gc,fgpix);
	resetmode();
	XCopyArea(dpy, sb->dr, db->dr, gc, r.origin.x, r.origin.y,
		wd, ht, p.x, p.y);
}

void
mdep_hidemouse(void)
{
}

void
mdep_showmouse(void)
{
}

int Midicnt = 0;
long Miditime = 0;

int
mdep_waitfor(int tmout)
{
	int ret, nfds, n;

	if ( Nextchar != NOCHAR || kbdbuf.cnt != 0 ) {
		return K_CONSOLE;
	}
	if ( Windevent ) {
		int k = Windevent;	/* K_WINDRESIZE or K_WINDEXPOSE */
		Windevent = 0;
		return k;
	}

	/* This next check is necessary, I believe, because X input may be */
	/* available and buffered in the X library, so that poll() really */
	/* doesn't indicate that X input is available, it only will */
	/* indicate when *new* X input is available. */

	if ( Displayfd>=0 && XPending(dpy) ) {
		int t;
		/* Should probably try to let MIDI input in, if it's */
		/* available.  At least occasionally.  Perhaps alternate?  */
		t = handle1input();
		return t;
	}

#ifdef TRYWITHOUT
	if ( !Isatty && !Conseof )
		return K_CONSOLE;
#endif

	if ( !Pollable ) {
		int t = oldp_waitfor(tmout);
		return t;
	}

	Fds[FDS_CONSOLE].revents = 0;	/* needed? */
	Fds[FDS_DISPLAY].revents = 0;	/* needed? */
	Fds[FDS_MIDI].revents = 0;	/* needed? */
	Fds[FDS_MIDI].fd = Midifd;
	nfds = 3;
	for ( n=0; n<Nsockfds; n++ ) {
		Fds[FDS_SOCKETS+n].revents = 0;
fprintf(stderr,"before poll, setting FDS_Sockets = %d\n",Fds[FDS_SOCKETS+n].fd);
		nfds++;
	}

	ret = poll(Fds,nfds,tmout);
	if ( ret == 0 )
		return K_TIMEOUT;

	for ( n=0; n<Nsockfds; n++ ) {
		if ( Fds[FDS_SOCKETS+n].revents & POLLIN ) {
fprintf(stderr,"waitfor found revents for socket!\n");
		}
	}

	if ( ret < 0 ) {
		if ( errno == EINTR ) {
			(*Intrfunc)();
			return K_CONSOLE;
		}
		sprintf(Msg1,"poll() failed in mdep_waitfor() errno=%d\n",errno);
		nopoll();
		execerror(Msg1);
	}
	if ( Fds[FDS_MIDI].revents & POLLIN )
		return K_MIDI;
	if ( Fds[FDS_DISPLAY].revents & POLLIN ) {
fprintf(stderr,"waitfor returns display event\n");
		return handle1input();
	}
	if ( Fds[FDS_CONSOLE].revents & POLLIN )
		return K_CONSOLE;
	for ( n=0; n<Nsockfds; n++ ) {
		if ( Fds[FDS_SOCKETS+n].revents & POLLIN ) {
fprintf(stderr,"waitfor returns K_PORT!\n");
			return K_PORT;
		}
	}
	/* If the X display is closed without any other notification, we */
	/* disable it from further consideration. */
	if ( Fds[FDS_DISPLAY].revents & (POLLNVAL|POLLERR|POLLHUP) ) {
		Fds[FDS_DISPLAY].fd = -1;
		/* mdep_popup("Display fd is being disabled in mdep_waitfor()"); */
		return K_ERROR;
	}
	sprintf(Msg1,"p_waitfor?  ret=%d errno=%d MIDI=%d DISPLAY=%d CONSOLE=%d",
		ret,errno,
		Fds[FDS_MIDI].revents,
		Fds[FDS_DISPLAY].revents,
		Fds[FDS_CONSOLE].revents);
	mdep_popup(Msg1);
	return K_ERROR;
}

int
oldp_waitfor(int tmout)
{
	long etime;

	if ( tmout )
		etime = MILLICLOCK + tmout;
	mdep_popup("oldp_waitfor may not work!\n");
	if ( mdep_statconsole() ) {
		return K_CONSOLE;
	}
	if ( mdep_statmidi() ) {
		return K_MIDI;
	}
	if ( Displayfd>=0 && XPending(dpy) ) {
		return K_MOUSE;
	}
	if ( tmout == 0 ) {
		return 0;
	}
	while ( MILLICLOCK < etime ) {
		if ( mdep_statconsole() ) {
			return K_CONSOLE;
		}
		if ( mdep_statmidi() ) {
			return K_MIDI;
		}
		if ( Displayfd>=0 && XPending(dpy) ) {
			return K_MOUSE;
		}
	}
	return 0;
}

static void
setfont(XFontStruct *fp,char *nm)
{
	if ( Currfont )
		XFreeFont(dpy,Currfont);
	XSetFont(dpy, gc, fp->fid);
	Currfont = fp;
	Mfontxsize = XTextWidth(Currfont,"m",1);
	Mfontysize = Currfont->max_bounds.ascent + Currfont->max_bounds.descent;
	if ( nm && Fontname )
		*Fontname = uniqstr(nm);
}

#include "tjt.ico"
#include "keykit.ico"

static void
seticon(void)
{
	static char *lasticon = NULL;
	static Pixmap keyicon;
	static Pixmap tjticon;
	static Pixmap newicon;
	static XWMHints wm_hints;
	char *icon = (Icon ? *Icon : "keykit");

	if ( lasticon != NULL && ( lasticon==icon || strcmp(lasticon,icon)==0 ) )
		return;

	lasticon = icon;

	/* hardcoded magic value "tjt" uses internal small picture */
	if ( strcmp(lasticon,"tjt")==0 ) {
		tjticon = XCreateBitmapFromData( dpy, RootWindow(dpy,defscreen),
			(Bitstype)tjt_bits, tjt_width, tjt_height);
		wm_hints.icon_pixmap = tjticon;
	}
	else {
		unsigned int width, height;
		int val, xhot, yhot;

		/* try to read the icon file */
		val = XReadBitmapFile( dpy, RootWindow(dpy,defscreen),
			lasticon, &width, &height, &newicon, &xhot, &yhot);

		if ( val==BitmapFileInvalid || val==BitmapOpenFailed
			|| val==BitmapNoMemory ) {

			/* If reading the file failed, use the standard icon */
			keyicon = XCreateBitmapFromData(dpy,RootWindow(dpy,defscreen),
				(Bitstype)keykit_bits, keykit_width, keykit_height);
			wm_hints.icon_pixmap = keyicon;
		}
		else
			wm_hints.icon_pixmap = newicon;
	}
	wm_hints.flags = IconPixmapHint;
	XSetWMHints(dpy, Disp.dr, &wm_hints);
}

static void
initcolormap(char **argv)
{
	unsigned long	pixels[256];
	unsigned long	pmasks;
	register int	i;
	XVisualInfo	vinfo;
	int	planes;
	char *cname;
	Visual *visual;
	XColor ccolor;
	XColor tcolor;

	/* *Colors should be the number of colors we want to be able to use. */

	Ncolors = DisplayCells(dpy, defscreen);
	if ( *Colors > Ncolors )
		*Colors = Ncolors;
	Ncolors = *Colors;

	colormap = XDefaultColormap(dpy, defscreen);
	bgpix = Backpix;
	fgpix = Forepix;

	planes = DisplayPlanes(dpy, defscreen);
	/* see what kind of visual we're dealing with */
	if (planes==1 ||
		!(XMatchVisualInfo(dpy, defscreen, planes, PseudoColor, &vinfo)
		|| XMatchVisualInfo(dpy, defscreen, planes, GrayScale, &vinfo)
		|| XMatchVisualInfo(dpy, defscreen, planes, TrueColor, &vinfo)
		|| XMatchVisualInfo(dpy, defscreen, planes, DirectColor, &vinfo))) {
		return;
	}

	visual = vinfo.visual;
	if ( Ncolors <= 2 )
		return;

	colors = (XColor *) malloc( Ncolors * sizeof(XColor));

	if ( *Sharedmap || XAllocColorCells(dpy,colormap,False,
					&pmasks,0,pixels,Ncolors)==0){
		Colormap newmap;

		if ( ! (*Privatemap) ) {
			Sharecolors = 1;
		}
		else {
			/* try private colormap */
			newmap = XCreateColormap(dpy, RootWindow(dpy,defscreen),
					visual, AllocNone);
			if (XAllocColorCells(dpy, newmap, False, &pmasks, 0, pixels, Ncolors)==0){
				char msg[100];
				sprintf(msg, "Couldn't allocate all %d colors\n",
					Ncolors);
				mdep_popup(msg);
				return;
			}
			colormap = newmap;
			XInstallColormap(dpy, colormap);
		}
	}
	for ( i=0; i<Ncolors; i++ )
		colors[i].pixel = pixels[i];

	/* allow .Xdefaults settings in */
	cname = XGetDefault(dpy,argv[0],"foreground");
	if (cname) if (XAllocNamedColor(dpy,colormap,cname,&ccolor,&tcolor)) {
		Forepix = fgpix = ccolor.pixel;
	}
	cname = XGetDefault(dpy,argv[0],"background");
	if (cname) if (XAllocNamedColor(dpy,colormap,cname,&ccolor,&tcolor)) {
		Backpix = bgpix = ccolor.pixel;
	}
}

static XFontStruct *
findgoodfont(void)
{
	XFontStruct *f;
	int n;
	char *fnt;

	for ( n=0; (fnt=Fntlist[n])!=NULL; n++ ) {
		if ( (f=XLoadQueryFont(dpy, fnt)) != NULL )
			return f;
	}
	return NULL;
}

static void
initfds(void)
{
	if ( ! my_isastream(Consolefd) ) {
		sprintf(Msg1,"Stdin is not streams-based and can't support poll()! (errno=%d).\n",errno);
		mdep_popup(Msg1);
		nopoll();
	}
	else {
		Fds[FDS_MIDI].events = POLLIN;
		Fds[FDS_CONSOLE].events = POLLIN;
		Fds[FDS_DISPLAY].events = POLLIN;

		Fds[FDS_CONSOLE].fd = Consolefd;
		Fds[FDS_DISPLAY].fd = -1;
		Fds[FDS_MIDI].fd = -1;
	}
}

static void
initdisplay(int argc,char **argv)
{
	int i;
	XSetWindowAttributes xswa;
	XSizeHints sizehints;
	XWMHints wmhints;
	char *geom = 0;
	long et;
	int flags;
	unsigned int width, height;
	int x, y;
	char **ap;
	char *fntname = Fntlist[0];
	XFontStruct *font;

	if(!(dpy= XOpenDisplay(NULL))){
		char msg[100];
		sprintf(msg,"Cannot open Display (%s)\n",XDisplayName(NULL));
		perror(msg);
		exit(1);
	}

	Displayfd = dpy->fd;

	/* We assume that if Displayfd is active, we're getting Console */
	/* keypresses from it, so we don't bother looking at Consolefd. */
	Fds[FDS_DISPLAY].fd = Displayfd;

	(void) memset(&sizehints, 0, sizeof(sizehints));
	defscreen = DefaultScreen(dpy);
	defdepth = DefaultDepth(dpy, defscreen);
	Backpix = WhitePixel(dpy, defscreen);
	Forepix = BlackPixel(dpy, defscreen);

	ap = argv;
	i = argc;
	while(i-- > 0){
		if(!strcmp("-fn", ap[0])){
			fntname = ap[1];
			if ( Fontname )
				*Fontname = uniqstr(fntname);
			i--; ap++;
		}
		else if(ap[0][0] == '='){
			geom = ap[0];	
			flags = XParseGeometry(ap[0],&x,&y,&width,&height);
			if(WidthValue & flags){
				sizehints.flags |= USSize;
				sizehints.width = width;
			}
			if(HeightValue & flags){
	    			sizehints.flags |= USSize;
				sizehints.height = height;
			}
			if(XValue & flags){
				if(XNegative & flags)
				  x=DisplayWidth(dpy,defscreen)+x 
					- sizehints.width;
				sizehints.flags |= USPosition;
				sizehints.x = x;
			}
			if(YValue & flags){
				if(YNegative & flags)
				  y=DisplayHeight(dpy,defscreen)+y
					-sizehints.height;
				sizehints.flags |= USPosition;
				sizehints.y = y;
			}
		}
		ap++;
	}

	if ( (font=XLoadQueryFont(dpy, fntname)) == NULL ) {
		if ( (font=findgoodfont()) == NULL ) {
			mdep_popup("Unable to load a font!\n");
			exit(1);
		}
	}

	sizehints.width_inc = sizehints.height_inc = 1;
	sizehints.min_width = sizehints.min_height = 20;
	sizehints.flags |= PResizeInc|PMinSize;
	if(!geom){
		sizehints.width = font->max_bounds.width * 80;
		sizehints.height = (font->max_bounds.ascent +
				 font->max_bounds.descent) * 24;
		sizehints.flags |= PSize;
	}

	xswa.event_mask = 0;

	initcolormap(argv);

	xswa.background_pixel = bgpix;
	xswa.border_pixel = fgpix;
	Disp.dr = XCreateWindow(dpy, RootWindow(dpy, defscreen),
		sizehints.x,sizehints.y, sizehints.width, sizehints.height,
		2,0,InputOutput, DefaultVisual(dpy, defscreen),
		CWEventMask | CWBackPixel | CWBorderPixel, &xswa);
	XSetStandardProperties(dpy, Disp.dr, argv[0], argv[0],
				None, argv, argc, &sizehints);

	seticon();

	XMapWindow(dpy, Disp.dr);

	gc = XCreateGC(dpy, Disp.dr, 0, NULL);
	XSetForeground(dpy, gc, fgpix);
	XSetBackground(dpy, gc, bgpix);
	resetmode();

	setfont(font,(char*)NULL);

	XSetLineAttributes(dpy, gc, 0, LineSolid, CapNotLast, JoinMiter);
	Dsize.x = (short) sizehints.width;
	Dsize.y = (short) sizehints.height;
	Disp.rect.origin = Pt(0,0);
	Disp.rect.corner = Dsize;

	Rawsize = Disp.rect;	/* will be corrected when first */
				/* ConfigureNotify event is seen. */

#define MOUSEALIVE
#ifdef MOUSEALIVE
	/* If you want the mouse to be always alive (when button not pressed) */
	inputmask |= PointerMotionMask;
#endif
	XSelectInput(dpy, Disp.dr, inputmask);

	wmhints.flags = InputHint;
	wmhints.input = True;
	XSetWMHints(dpy, Disp.dr, &wmhints);

	/* Something's wrong here - sometimes I don't */
	/* see the Expose event.  Hence the time limit. */
	/* This is very old code, though - the problem is probably gone. */
	et = mdep_currtime() + 10;
	while ( mdep_currtime() < et ) {
		if ( ! XPending(dpy) )
			millisleep(100);
		else if ( handle1input() == K_WINDEXPOSE )
			break;
	}
	if ( mdep_currtime() >= et ) {
		mdep_popup("Warning - didn't get initial expose event?\n");
	}
}

int
mdep_startgraphics(int argc,char **argv)
{
	int r;
	struct termio t;

	if ( Graphing )
		return 0;

	if ( ioctl(0,TCGETA,&t) == 0 ) {
		Killchar = t.c_cc[VKILL];
		Erasechar = t.c_cc[VERASE];
		Intrchar = t.c_cc[VINTR];
	}
	else {
		Intrchar = 0x7f;
	}
#ifdef TTYSTUFF
	if ( Isatty ) {
		if ( ioctl(0,TCSETA,&Initterm) < 0 )
			mdep_popup("Error in ioctl?\n");
	}
#endif

	initfds();
	initdisplay(argc,argv);
	Graphing = 1;
	if ( Forkoff && *Forkoff ) {
		r = fork();
		if ( r < 0 ) {
			mdep_popup("Unable to fork!?\n");
			return 0;
		}
		if ( r > 0 ) {
			exit(0);
			/*NOTREACHED*/
		}
	}
	/* successful child */
	return 0;
}

void
mdep_endgraphics(void)
{
	if ( Graphing )
		XCloseDisplay(dpy);
}

void
mdep_boxfill(int x0,int y0,int x1,int y1)
{
	XFillRectangle(dpy, Disp.dr, gc,x0,y0,x1-x0+1,y1-y0+1);
}

int
mdep_mouse(int *ax,int *ay,int *am)
{
	int but;

	handleinput();
	if ( ax )
		*ax = Msx;
	if ( ay )
		*ay = Msy;
	if ( am )
		*am = Msm;

	if ( button1() && ( button2() || button3() ) )
		but = 3;
	else if ( button2() || button3() )
		but = 2;
	else if ( button1() )
		but = 1;
	else
		but = 0;

	return but;
}

int
mdep_mousewarp(int x, int y)
{
	XWarpPointer(dpy,None,None,0,0,0,0,x,y);
	return 0;
}

void
mdep_plotmode(int m)
{
	if ( m == Last_p_mode )
		return;

	switch (Last_p_mode=m) {
	case P_CLEAR:
		XSetFunction(dpy, gc, F_STORE);
		XSetForeground(dpy, gc, bgpix);
		FMode = F_CLR;
		break;
	case P_STORE:
		FMode = F_STORE;
		XSetFunction(dpy, gc, FMode);
		XSetForeground(dpy, gc, fgpix);
		break;
	case P_XOR:
		FMode = F_XOR;
		XSetFunction(dpy, gc, FMode);
		XSetForeground(dpy, gc, fgpix^bgpix);
		break;
	}
}

void
mdep_line(int x0,int y0,int x1,int y1)
{
	XDrawLine(dpy, Disp.dr, gc, x0, y0, x1, y1);
	/* keykit expects inclusive line endpoints */
	XDrawPoint(dpy, Disp.dr, gc, x1, y1);
}

void
mdep_box(int x0,int y0,int x1,int y1)
{
	XDrawRectangle(dpy, Disp.dr, gc, x0, y0, x1-x0, y1-y0);
}

void
mdep_ellipse(int x0,int y0,int x1,int y1)
{
	XDrawArc(dpy, Disp.dr, gc, x0, y0, x1-x0, y1-y0, 0, 360 );
}

void
mdep_fillellipse(int x0,int y0,int x1,int y1)
{
	XFillArc(dpy, Disp.dr, gc, x0, y0, x1-x0, y1-y0, 0, 360);
}

static Bitmap *
balloc (Rectangle r)
{
	Bitmap *b;

	b = (Bitmap *)malloc(sizeof (struct Bitmap));
	b->dr = XCreatePixmap(dpy, Disp.dr, r.corner.x-r.origin.x,
		r.corner.y-r.origin.y, defdepth);
	b->rect=r;
	return b;
}

static void
bfree(Bitmap *b)
{
	if(b){
		XFreePixmap(dpy, b->dr);
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
		bfree((Bitmap*)(p.ptr));
	p.xsize = p.origx = (INT16)x;
	p.ysize = p.origy = (INT16)y;
	p.ptr = (unsigned char *) balloc(Rect(0,0,x,y));
	return p;
}

void
mdep_freebitmap(Pbitmap p)
{
	if ( p.ptr )
		bfree((Bitmap*)(p.ptr));
}

void
mdep_pullbitmap(int x,int y,Pbitmap p)
{
	bitblt(&Disp,Rect(x,y,x+p.xsize,y+p.ysize),(Bitmap*)(p.ptr),Pt(0,0),F_STORE);
}

void
mdep_sync(void)
{
	XSync(dpy, 0);
}

void
mdep_putbitmap(int x,int y,Pbitmap p)
{
	bitblt((Bitmap*)(p.ptr),Rect(0,0,p.xsize,p.ysize),&Disp,Pt(x,y),FMode);
	XSync(dpy, 0);
}

void
mdep_movebitmap(int x,int y,int wid,int hgt,int tox,int toy)
{
	XSetFunction(dpy, gc, F_STORE);
	XSetForeground(dpy,gc,fgpix);
	resetmode();
	XCopyArea(dpy, Disp.dr, Disp.dr, gc, x, y,
		wid, hgt, tox, toy);
}

int
mdep_screenresize(int x0, int y0, int x1, int y1)
{
	XMoveResizeWindow(dpy, Disp.dr, x0,y0,x1-x0,y1-y0);
	return 0;
}

int
mdep_screensize(int *x0, int *y0, int *x1, int *y1)
{
	*x0 = Rawsize.origin.x;
	*y0 = Rawsize.origin.y;
	*x1 = Rawsize.corner.x;
	*y1 = Rawsize.corner.y;
	return 0;
}

int
mdep_maxx(void)
{
	return Dsize.x-1;
}
int
mdep_maxy(void)
{
	return Dsize.y-1;
}

static unsigned char myarrow_bits[] = {
   0xff, 0x3f, 0xff, 0x1f, 0xff, 0x0f, 0xff, 0x07, 0xff, 0x03, 0xff, 0x03,
   0xff, 0x03, 0xff, 0x07, 0xff, 0x0f, 0xff, 0x1f, 0x8f, 0x3f, 0x07, 0x7f,
   0x03, 0xfe, 0x01, 0xfc, 0x00, 0x78, 0x00, 0x30};
static unsigned char myarrow_mask_bits[] = {
   0x00, 0x00, 0xfe, 0x07, 0xfe, 0x03, 0xfe, 0x01, 0xfe, 0x00, 0xfe, 0x00,
   0xfe, 0x01, 0xfe, 0x03, 0xce, 0x07, 0x86, 0x0f, 0x02, 0x1f, 0x00, 0x3e,
   0x00, 0x7c, 0x00, 0x78, 0x00, 0x30, 0x00, 0x00};
static unsigned char cross_bits[] = {
   0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00,
   0x80, 0x00, 0xff, 0x7f, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00,
   0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x00, 0x00};
static unsigned char coffee_bits[] = {
   0x80, 0x00, 0x00, 0x07, 0x00, 0x08, 0xc0, 0x08, 0x20, 0x07, 0x00, 0x00,
   0xf0, 0x07, 0x48, 0x3c, 0xf8, 0x47, 0x08, 0x58, 0x08, 0x40, 0x08, 0x3c,
   0x18, 0x08, 0xfa, 0x3f, 0x02, 0x20, 0xfc, 0x1f};
static unsigned char sweep_bits[] = {
   0x03, 0x84, 0x47, 0x84, 0x4e, 0x80, 0x5c, 0x84, 0x78, 0x84, 0x70, 0x80,
   0x7e, 0x84, 0x00, 0x84, 0x00, 0x80, 0x00, 0x84, 0xdb, 0x86, 0x00, 0x80,
   0x00, 0x80, 0x00, 0x80, 0xff, 0xff, 0x00, 0x00};
static unsigned char leftright_bits[] = {
   0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0x41, 0x08, 0x61, 0x18, 0x71, 0x38,
   0xf9, 0x7f, 0xfd, 0xff, 0xf9, 0x7f, 0x71, 0x38, 0x61, 0x18, 0x41, 0x08,
   0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00};
static unsigned char no_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
static unsigned char updown_bits[] = {
   0xff, 0xff, 0x00, 0x00, 0x00, 0x01, 0x80, 0x03, 0xc0, 0x07, 0xe0, 0x0f,
   0xf0, 0x1f, 0x80, 0x03, 0x80, 0x03, 0x80, 0x03, 0x80, 0x03, 0xf0, 0x1f,
   0xe0, 0x0f, 0xc0, 0x07, 0x80, 0x03, 0x00, 0x01};
static unsigned char anywhere_bits[] = {
   0x3f, 0xfc, 0x1f, 0xf8, 0x0f, 0xf0, 0x1f, 0xf8, 0x3b, 0xdc, 0x71, 0x8e,
   0xe0, 0x07, 0xc0, 0x03, 0xc0, 0x03, 0xe0, 0x07, 0x71, 0x8e, 0x3b, 0xdc,
   0x1f, 0xf8, 0x0f, 0xf0, 0x1f, 0xf8, 0x3f, 0xfc};

#define NOCURSOR (Cursor)0

static struct cinfo {
	int type;
	char *bits;
	char *maskbits;
	int hotx, hoty;
	Cursor curs;
} Clist[] = {
	M_ARROW, (char*)myarrow_bits, (char*)myarrow_mask_bits, 1,1, NOCURSOR,
	M_CROSS, (char*)cross_bits, (char*)cross_bits, 8,8, NOCURSOR,
	M_SWEEP, (char*)sweep_bits, (char*)sweep_bits, 0,0, NOCURSOR,
	M_LEFTRIGHT,(char*)leftright_bits, (char*)leftright_bits, 0,0,NOCURSOR,
	M_UPDOWN, (char*)updown_bits, (char*)updown_bits, 0,0, NOCURSOR,
	M_ANYWHERE, (char*)anywhere_bits, (char*)anywhere_bits, 8,8, NOCURSOR,
	M_BUSY, (char*)coffee_bits, (char*)coffee_bits, 0,0, NOCURSOR,
	M_NOTHING, (char*)no_bits, (char*)no_bits, 0,0, NOCURSOR,
	-1, (char*)NULL, (char*)NULL, 0,0, NOCURSOR
};

void
mdep_setcursor(int type)
{
	static int first = 1;
	int n, t;
	struct cinfo *clist;
	XColor fgcolor, bgcolor;

	clist = Clist;

	if ( first ) {
		Pixmap sp, mp;

		for ( n=0; clist[n].type >= 0 ; n++ ) {
			fgcolor.pixel = fgpix;
			bgcolor.pixel = bgpix;
			XQueryColor(dpy, colormap, &fgcolor);
			XQueryColor(dpy, colormap, &bgcolor);
			mp = XCreatePixmapFromBitmapData(dpy, Disp.dr,
				(char*)clist[n].bits, 16, 16, 1, 0, 1);
			sp = XCreatePixmapFromBitmapData(dpy, Disp.dr,
				(char*)clist[n].maskbits, 16, 16, 1, 0, 1);
			clist[n].curs = XCreatePixmapCursor(dpy, sp,mp,
				&fgcolor,&bgcolor, clist[n].hotx,clist[n].hoty);
			XFreePixmap(dpy, sp);
			XFreePixmap(dpy, mp);
		}
		first = 0;
	}
	for ( n=0; (t=clist[n].type) >= 0 ; n++ ) {
		if ( t == type )
			break;
	}
	if ( t < 0 )
		n = 0;	/* default to M_ARROW if invalid */
	XDefineCursor(dpy, Disp.dr, clist[n].curs);
}

char *
mdep_fontinit(char *fontname)
{
	XFontStruct *fp;
	int n;

	fp = XLoadQueryFont(dpy, fontname);
	if (fp) {
		setfont(fp,(char*)NULL);
		return NULL;	/* means success */
	}

	/* Try various fonts in search of one that works. */
	for ( n=0; (fontname=Fntlist[n])!=NULL; n++ ) {
		fp = XLoadQueryFont(dpy, fontname);
		if ( fp ) {
			setfont(fp,fontname);	/* change Fontname variable */
			return NULL;	/* means success */
		}
	}
	return "Unable to load font";
}

int
mdep_fontwidth(void)
{
	return Mfontxsize;
}

int
mdep_fontheight(void)
{
	return Mfontysize;
}

void
mdep_string(int x,int y,char *s)
{
	XDrawString(dpy,Disp.dr,gc,x,y+Currfont->max_bounds.ascent,s,strlen(s));

	seticon();	/* this is just a convenient place for this, */
			/* it doesn't *have* to be here. */
}

void
mdep_popup(char *s)
{
	printf("%s\n",s);
}

void
mdep_color(int n)
{
	XColor *c;
	int m;

	if ( n < 0 || n >= Ncolors )
		return;

	c = &colors[n];
	if ( n == 1 )
		fgpix = Forepix;
	else if ( n == 0 )
		fgpix = Backpix;
	else
		fgpix = c->pixel;
	m = Last_p_mode;
	resetmode();
	mdep_plotmode(m);
}

void
mdep_colormix(int n,int r,int g,int b)
{
	XColor *c;

#ifdef OLDSTUFF
	if ( n < 2 )
		return;	/* don't allow changing colors 0 and 1 */
#endif

	if ( n >= Ncolors )
		return;
	c = &colors[n];
	c->red = (short)r;
	c->green = (short)g;
	c->blue = (short)b;
	c->flags = DoRed | DoGreen | DoBlue;
	if ( Sharecolors )
		XAllocColor(dpy, colormap, c);
	else
		XStoreColor(dpy, colormap, c);
	if ( n == 1 )
		Forepix = fgpix = c->pixel;
	else if ( n == 0 )
		Backpix = bgpix = c->pixel;
}

#define SOCK_UNCONNECTED 0
#define SOCK_CONNECTED 1
#define SOCK_CLOSED 2
#define SOCK_CANREAD 3
#define SOCK_UNACCEPTED 4
#define INVALID_SOCKET -1
#define SOCKET_ERROR -1

typedef int SOCKET;

struct myportinfo {
	char *type;	/* usually "tcpip" */
	SOCKET origsock;
	SOCKET sock;
	char sockstate;
	char isopen;
	char closeme;
	char *buff;	/* for stuff put on a socket that hasn't connected */
	int buffsize;
	struct myportinfo *next;
};

typedef struct myportinfo Myport;
Myport *Topport = NULL;

#ifndef NOSOCKETS
static void
sockerror(char *s)
{
	makeroom(strlen(s)+64,&Msg2,&Msg2size);
	sprintf(Msg2,"Winsock error - %s - err=%d",s,errno);
	mdep_popup(Msg2);
}
#endif

static SOCKET
tcpip_listen(char *servname)
{
#ifdef NOSOCKETS
	return INVALID_SOCKET;
#else
	struct sockaddr_in local_sin; /* Local socket */
	struct hostent *phe;  /* to get IP address */
	SOCKET sock;
	struct servent *pse;
	char myname[80];
	int r;

	sock = socket( AF_INET, SOCK_STREAM, 0);
	if (sock == INVALID_SOCKET) {
		sockerror("socket() failed in tcpip_listen()");
		return INVALID_SOCKET;
	}

	local_sin.sin_family = AF_INET;
	if ( isdigit(*servname) ) {
		local_sin.sin_port = htons((u_short)atoi(servname));
	}
	else {
		pse = getservbyname(servname, "tcp");
		if (pse == NULL) {
			sprintf(Msg1,"getservbyname(%s) failed",servname);
			sockerror(Msg1);
			return INVALID_SOCKET;
		}
		local_sin.sin_port = pse->s_port;
	}

	if ( gethostname(myname,sizeof(myname)) < 0 ) {
		sockerror("gethostname() failed");
		return INVALID_SOCKET;
	}

	phe = gethostbyname(myname);
	if (phe == NULL) {
		sockerror("gethostbyname() failed");
		return INVALID_SOCKET;
	}

	memcpy((struct sockaddr *) &local_sin.sin_addr,
		*(char **)phe->h_addr_list, phe->h_length);

  	if (bind( sock, (struct sockaddr *) &local_sin, sizeof(local_sin)) == SOCKET_ERROR) {
		sockerror("bind() failed");
		return INVALID_SOCKET;
	}

	if ( listen( sock, 4) < 0) {
		sockerror("listen() failed");
		return INVALID_SOCKET;
	}

	if ( fcntl(sock , F_SETFL, O_NDELAY) < 0 )
		sockerror("Error in fcntl on socket (listen)?");

	return sock;
#endif
}

static SOCKET
tcpip_connect(char *name, char *servname)
{
#ifdef NOSOCKETS
	return INVALID_SOCKET;
#else
	struct sockaddr_in dest_sin;  /* DESTination Socket INternet */
	struct hostent *phe;
	struct servent *pse;
	SOCKET sock;
	int r;

	/* See if the we know about the host (phe = Pointer Host Entity)*/

	phe = gethostbyname(name);
	if (phe == NULL) {
		sprintf(Msg1,"Unknown host %s",name);
		sockerror(Msg1);
		return INVALID_SOCKET;
	}

	dest_sin.sin_family = AF_INET;
	if ( isdigit(*servname) ) {
		dest_sin.sin_port = htons((u_short)atoi(servname));
	}
	else {
		pse = getservbyname(servname, "tcp");
		if (pse == NULL) {
			sprintf(Msg1,"getservbyname(%s,\"tcp\") failed!",servname);
			sockerror(Msg1);
			return INVALID_SOCKET;
		}
		dest_sin.sin_port = pse->s_port;
	}

	sock = socket( AF_INET, SOCK_STREAM, 0);
	if (sock == INVALID_SOCKET) {
		sockerror("socket() failed");
		return INVALID_SOCKET;
	}

	/* Finish up the Destination Socket */

	memcpy((struct sockaddr *) &dest_sin.sin_addr, *(char **)phe->h_addr_list,
		phe->h_length);

	r = connect( sock, (struct sockaddr*) &dest_sin, sizeof( dest_sin));
	if ( r == SOCKET_ERROR && errno != EINPROGRESS ) {
		sockerror("connect() failed");
		return INVALID_SOCKET;
	}

	if ( fcntl(sock , F_SETFL, O_NDELAY) < 0 )
		sockerror("Error in fcntl on socket (connect)?");

	return sock;
#endif
}

static int
tcpip_send(SOCKET sock,char *msg,int msgsize)
{
#ifdef NOSOCKETS
	return 0;
#else
	int r;
	r = send(sock,msg,msgsize,0);
	if ( r == SOCKET_ERROR ) {
		sockerror("tcpip_send() failed");
		return 1;
	}
	return 0;
#endif
}

static int
tcpip_recv(SOCKET sock,char *buff, int buffsize)
{
#ifdef NOSOCKETS
	return 0;
#else
	int r;
	r = recv(sock,buff,buffsize,0);
	if ( r==0 )
		return 0;	/* socket has closed, perhaps we should eof? */
	if ( r == SOCKET_ERROR && errno == EWOULDBLOCK )
		return 0;
	if ( r == SOCKET_ERROR ) {
		sockerror("tcpip_recv() failed");
		return 0;
	}
	return r;
#endif
}

static int
tcpip_close(SOCKET sock)
{
#ifdef NOSOCKETS
	return 0;
#else
fprintf(stderr,"tcpip_close - NEEDS WORK - eliminating fds from Fds\n");
	if ( close(sock) ) {
		sockerror("close() of socket failed");
		return 1;
	}
	return 0;
#endif
}

static Myport *
newmyport()
{
	Myport *m;
	m = (Myport *) kmalloc(sizeof(Myport),"newmyport");
	m->origsock = INVALID_SOCKET;
	m->sock = INVALID_SOCKET;
	m->sockstate = SOCK_UNCONNECTED;
	m->isopen = 0;
	m->closeme = 0;
	m->buff = NULL;
	m->buffsize = 0;

	m->next = Topport;
	Topport = m;
	return m;
}

PORTHANDLE *
mdep_openport(char *name, char *mode, char *type)
{
	static PORTHANDLE handle[2];
	PORTHANDLE m0, m1;

	if ( strcmp(type,"tcpip_connect") == 0 ) {
		char buff[BUFSIZ];
		char *p;
		SOCKET sock;

		strcpy(buff,name);
		p = strchr(buff,'@');
		if ( p == NULL ) {
			eprint("tcpip_connect name must contain a '@' !");
			return NULL;
		}
		*p++ = 0;
		sock = tcpip_connect(p,buff);
		m0 = newmyport();
		m0->type = "tcpip_read";
		m0->isopen = 1;
		m0->closeme = 1;
		m0->sock = sock;
		m0->sockstate = SOCK_UNCONNECTED;
		handle[0] = m0;

		m1 = newmyport();
		m1->type = "tcpip_write";
		m1->isopen = 1;
		m1->sock = sock;
		m1->sockstate = SOCK_UNCONNECTED;
		handle[1] = m1;

		Fds[FDS_SOCKETS + Nsockfds].fd = sock;
		Fds[FDS_SOCKETS + Nsockfds].events = POLLIN;
fprintf(stderr,"tcpip_connect Setting Fds[%d] to sock=%d\n",FDS_SOCKETS+Nsockfds,sock);
		Nsockfds++;

		return handle;
	}
	if ( strcmp(type,"tcpip_listen") == 0 ) {
		SOCKET sock;

		sock = tcpip_listen(name);
		m0 = newmyport();
		m0->type = "tcpip_read";
		m0->isopen = 1;
		m0->closeme = 1;
		m0->origsock = sock;
		m0->sock = sock;	/* will be changed by accept() */
		m0->sockstate = SOCK_UNACCEPTED;
		handle[0] = m0;

		m1 = newmyport();
		m1->type = "tcpip_write";
		m1->isopen = 1;
		m1->sock = sock;
		m1->sockstate = SOCK_UNACCEPTED;
		handle[1] = m1;

		Fds[FDS_SOCKETS + Nsockfds].fd = sock;
		Fds[FDS_SOCKETS + Nsockfds].events = POLLIN;
fprintf(stderr,"tcpip_listen Setting Fds[%d] to sock=%d\n",FDS_SOCKETS+Nsockfds,sock);
		Nsockfds++;

		return handle;
	}
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

static void
sockaway(PORTHANDLE m,char *buff,int size)
{
	if ( m->buff == NULL ) {
		m->buff = (char *) kmalloc(size,"sockaway");
		m->buffsize = size;
		memcpy(m->buff,buff,size);
	}
	else {
		char *newbuff = (char *) kmalloc(size+m->buffsize,"sockaway");
		memcpy(newbuff,m->buff,m->buffsize);
		memcpy(newbuff+m->buffsize,buff,size);
		kfree(m->buff);
		m->buff = newbuff;
	}
}

int
mdep_putportdata(PORTHANDLE m, char *buff, int size)
{
	int r;

fprintf(stderr,"MDEP_PUTPORTDATA , size=%d buff=(%s) \n",size,buff);
	r = tcpip_send(m->sock,buff,size);
if ( r != 0 ) fprintf(stderr,"after tcpip_send,r=%d\n",r);
	return r;

#ifdef OLDSTUFF
	switch (m->sockstate) {
	case SOCK_UNCONNECTED:
	case SOCK_UNACCEPTED:
		sockaway(m,buff,size);	/* for delivery when it connects */
		r = size;
		break;
	default:
		r = tcpip_send(m->sock,buff,size);
		break;
	}
	return r;
#endif
}

int
mdep_getportdata(PORTHANDLE *handle, char *buff, int buffsize)
{
	Myport *m;
	int r;

	for ( m=Topport; m!=NULL; m=m->next ) {
		if ( ! m->isopen )
			continue;
		if ( strcmp(m->type,"tcpip_read") == 0 ) {
			*buff = 0;
			r = tcpip_recv(m->sock,buff,buffsize);
			if ( r > 0 ) {
fprintf(stderr,"  MDEP_GETPORTDATA RETURNS DATA!!, r=%d buff=%s\n",r,buff);
				*handle = m;
				return r;
			}
		}
	}
	return -1;
}

int
mdep_closeport(PORTHANDLE m)
{
	int r = 0;

	m->isopen = 0;
	if ( strncmp(m->type,"tcpip",5) == 0 ) {
		if ( m->closeme ) {
			r |= tcpip_close(m->sock);
			m->sock = INVALID_SOCKET;
			if ( m->origsock != INVALID_SOCKET ) {
				r |= tcpip_close(m->origsock);
				m->origsock = INVALID_SOCKET;
			}
		}
	}
	kfree(m);
	return r;
}

int
mdep_help(char *fname, char *keyword)
{
	return(1);
}
