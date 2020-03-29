/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

/*
 * X11 support
 */

#include "key.h"

#include <termios.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <signal.h>
#include <sys/time.h>
#include <sys/errno.h>
#include <unistd.h>
#include <sys/resource.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

#define NOCHAR -2

extern int errno;

#ifdef TTYSTUFF
int Isatty = 0;
int Initdone = 0;
struct termios Initterm;
#endif

#define SOCK_UNCONNECTED 0
#define SOCK_CONNECTED 1
#define SOCK_CLOSED 2
#define SOCK_CANREAD 3
#define SOCK_LISTENING 4
#define SOCK_REFUSED 5
#define INVALID_SOCKET -1

#define PORT_NORMAL 0
#define PORT_CANREAD 1

#define TYPE_NONE 0
#define TYPE_READ 1
#define TYPE_WRITE 2
#define TYPE_LISTEN 3

typedef int SOCKET;
#define SOCKADDR_IN struct sockaddr_in
#define PSOCKADDR struct sockaddr *
#define PHOSTENT struct hostent *
#define PSERVENT struct servent *
#define SOCKET int
#define SOCKET_ERROR (-1)

struct myportinfo {
	char rw;	/* TYPE_READ or TYPE_WRITE */
	char *name;
	SOCKET origsock;
	SOCKET sock;
	char sockstate;
	char portstate;
	char isopen;
	char checkit;
	char closeme;
	char hasreturnedfinaldata;
	char *buff;	/* for stuff put on a socket that hasn't connected */
	int buffsize;
	struct myportinfo *savem0;
	struct myportinfo *savem1;
	struct myportinfo *next;
};

typedef struct myportinfo Myport;
Myport *Topport = NULL;

static int Nextchar = NOCHAR;
static int Conseof = 0;
static int Windevent = 0;
static int MaxFdUsed = 0;
static fd_set ReadFds;
static fd_set ExceptFds;
static fd_set ReadFdsInit;
static fd_set ExceptFdsInit;

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
static int GraphicsInitialized = 0;
static int Nographics = 1;
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
	(void) signal(SIGBUS, SIG_IGN);
}

static void
millisleep(int n)
{
	usleep(1000*n);
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
	/* FIX - 5/4/97 - On some systems/window-managers, the x/y fields are */
	/* not meaningful, so we no longer use them. */
#ifdef OLDVERSION
	Rawsize = Rect(
		ev.xconfigure.x,
		ev.xconfigure.y,
		ev.xconfigure.x+ev.xconfigure.width,
		ev.xconfigure.y+ev.xconfigure.height);
#endif
	Rawsize = Rect(
		0,
		0,
		ev.xconfigure.width,
		ev.xconfigure.height);

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
		if ( updatedrect(ev) ) {
			return K_WINDRESIZE;
		}
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
			/* FIX - 5/4/97 - time wrapping around fix */
			if ( tm < lastexpose )
				lastexpose = 0;
			if ( lastexpose!=0 && (tm-lastexpose)<*Redrawignoretime)
				break;
			lastexpose = tm;
			t = ev.type;
			r = K_WINDEXPOSE;
			/* skip over any additional pending Exposes */
			while ( XPending(dpy) ) {
				XPeekEvent(dpy,&ev);
				t = ev.type;
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
	fd_set readfds;
	fd_set exceptfds;
	struct timeval t;

	int n;

	if ( Nextchar!=NOCHAR ) {
		return 1;
	}

	if ( GraphicsInitialized ) {
		handleinput();
		Nextchar = kbdchar();
		if ( Nextchar == EOF )
			Nextchar = NOCHAR;
		if ( Nextchar == NOCHAR ) {
			return(0);
		} else {
			return(1);
		}
	}

	FD_ZERO(&readfds);
	FD_ZERO(&exceptfds);
	if(Consolefd == -1)
		return 0;
	if(Consolefd > MaxFdUsed)
		MaxFdUsed = Consolefd;
	FD_SET(Consolefd, &readfds);
	FD_SET(Consolefd, &exceptfds);
	t.tv_sec = 0;
	t.tv_usec = 0;
	n = select(MaxFdUsed+1, &readfds, NULL, &exceptfds, &t);

	if ( n < 0 ) {
		char msg[100];
		sprintf(msg,"Hey, poll() returns %d?  (errno=%d)\n",n,errno);
		mdep_popup(msg);
	}
	return n > 0;
}

int
ismuxable(int fd)
{
	fd_set readfds;
	fd_set exceptfds;
	struct timeval t;

	if (fd==-1) return(1);

	FD_ZERO(&readfds);
	FD_ZERO(&exceptfds);
	if(fd > MaxFdUsed) {
		MaxFdUsed = fd;
	}
	FD_SET(fd, &readfds);
	FD_SET(fd, &exceptfds);
	t.tv_sec = 0;
	t.tv_usec = 0;
	errno = 0;
	(void) select(MaxFdUsed+1, &readfds, NULL, &exceptfds, &t);

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
	if ( GraphicsInitialized ) {
		handleinput();
	}

	if ( Nextchar != NOCHAR ) {
		c = Nextchar;
		Nextchar = NOCHAR;
		return c;
	}

	if ( GraphicsInitialized ) {
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

#ifdef TRYWITHOUT
static void
ttysetraw(void)
{
	struct termios termbuff;
	int fd = 0;

	if ( tcgetattr(fd,&Initterm) < 0 ) {
		sprintf(Msg1,
	"Error in tcgetattr(%d) in ttysetraw()?  errno=%d\n",fd,errno);
		mdep_popup(Msg1);
	}

	/* put terminal in raw mode */
	termbuff = Initterm;
	termbuff.c_lflag &= (~ICANON);
	termbuff.c_lflag &= (~ECHO);
	for (i=0; i< NCCS; i++) termbuff.c_cc[i]=0;
	termbuff.c_cc[VMIN] = 1;
	termbuff.c_cc[VTIME] = 1;

	if (tcsetattr(fd, TCSANOW, &termbuff) < 0 ) {
		sprintf(Msg1,
	"Error in tcsetattr(%d,TCSANOW) in ttysetraw()?  errno=%d\n",fd,errno);
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
	*Colors = 64;
	*Fontname = uniqstr(Fntlist[0]);
	installnum("Cursereverse",&Cursereverse,0L);
	installnum("Privatemap",&Privatemap,0L);
	installnum("Sharedmap",&Sharedmap,0L);
	installnum("Nobrowsefiles",&Nobrowsefiles,1L);
	installnum("Forkoff",&Forkoff,0L);
	if ( getenv("OPENWINHOME") != NULL ) {
		*Windowsys = uniqstr("OpenWindows");
		*Sharedmap = 1;
	}
	else {
		*Windowsys = uniqstr("X");
	}
	*Keyroot = uniqstr(keyroot());

#ifdef linux
	{
	extern Symstrp Machine;
	*Machine = uniqstr("linux");
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
		mdep_colormix(3, 200*n, 200*n, 200*n);	/* light grey */
		mdep_colormix(4, 100*n, 100*n, 100*n);	/* dark grey */
		/* ajd: new color */
		mdep_colormix(5, 230*n, 230*n, 230*n);	/* faint grey */
	}
	else {
		mdep_colormix(0, 255*n, 255*n, 255*n);	/* white */
		mdep_colormix(1, 0, 0, 0 );		/* black */
		mdep_colormix(2, 255*n, 0, 0	);	/* red, for Pickcolor */
		mdep_colormix(4, 200*n, 200*n, 200*n);	/* light grey */
		mdep_colormix(3, 100*n, 100*n, 100*n);	/* dark grey */
		/* ajd: not sure if this should be the same as above. */
		mdep_colormix(5, 230*n, 230*n, 230*n);	/* faint grey */
	}
}

char *
mdep_musicpath(void)
{
	char *p, *str;

        if ( (p=getenv("MUSICPATH")) != NULL && *p != '\0' ) {
                str = uniqstr(p);
	}
	else {
		p = (char *) malloc((unsigned)(3*strlen(keyroot())+64));
		sprintf(p,".%s%s/music",*Pathsep,keyroot());
		str = uniqstr(p);
		kfree(p);
	}
        return str;
}

char *
mdep_keypath(void)
{
        char *p, *path;

        if ( (p=getenv("KEYPATH")) != NULL && *p != '\0' ) {
                path = uniqstr(p);
                mdep_popup("Warning - you sure you want to set KEYPATH from the environment?\n");
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
	int ret;
	int iii;
	fd_set readfds;
	fd_set exceptfds;
	struct timeval t;
	Myport *m;
	static int midifd_previous = -1;

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
	if ( !Isatty && !Conseof ) {
		return K_CONSOLE;
	}
#endif

/* keyerrfile("waitfor tmout=%d\n",tmout); */
	ReadFds = ReadFdsInit;
	ExceptFds = ExceptFdsInit;

	if(Midifd > MaxFdUsed) {
		MaxFdUsed = Midifd;
	}

	if (Midifd!=-1) {
		FD_SET(Midifd, &ReadFds);
		FD_SET(Midifd, &ExceptFds);
	}
	
	if (Midifd!=midifd_previous) {
		if ( midifd_previous >= 0 ) {
			FD_CLR(midifd_previous, &ReadFds);
			FD_CLR(midifd_previous, &ExceptFds);
		}
		midifd_previous = Midifd;
	}

	for ( m=Topport; m!=NULL; m=m->next ) {
		if ((m->rw != TYPE_WRITE) &&
			(m->sockstate == SOCK_CLOSED || m->sockstate == SOCK_REFUSED) ) {
			return K_PORT;
		}
		if ( ! m->isopen || m->sock < 0 )
			continue;
		if(m->sock > MaxFdUsed) {
			MaxFdUsed = m->sock;
		}
/* keyerrfile("Adding sock=%d to Readfds\n",m->sock); */
		FD_SET(m->sock, &ReadFds);
		FD_SET(m->sock, &ExceptFds);
	}

	t.tv_sec = 0;
	t.tv_usec = tmout * 1000;
	if (t.tv_usec>1000000) {
		t.tv_sec=  t.tv_usec / 1000000;
		t.tv_usec= t.tv_usec % 1000000;
	}

	/* structure-copy the fd_sets because select() alters them. */
	readfds = ReadFds;
	exceptfds = ExceptFds;

	ret = select(MaxFdUsed+1, &readfds, NULL, &exceptfds, &t);
	if ( ret == 0 ) {
		return K_TIMEOUT;
	}

	if ( ret < 0 ) {
		if ( errno == EINTR ) {
			(*Intrfunc)();
			return K_CONSOLE;
		}
		sprintf(Msg1,"poll/select failed in mdep_waitfor() errno=%d Readfds=0x%x MaxFdUsed=%d\n",errno,ReadFds,MaxFdUsed);
		execerror(Msg1);
	}

	for ( m=Topport; m!=NULL; m=m->next ) {
		if ( m->sock < 0 )
			continue;
		if ((m->rw != TYPE_WRITE) && FD_ISSET(m->sock, &readfds)) {
			m->checkit = 1;
			return K_PORT;
		}
		if (FD_ISSET(m->sock, &exceptfds)) {
			m->checkit = 1;
			return K_PORT;
		}
	}

	if((Midifd!=-1) && (FD_ISSET(Midifd, &readfds))) {
		return K_MIDI;
	}
	if((Displayfd!=-1) && (FD_ISSET(Displayfd, &readfds))) {
		return handle1input();
	}
	if((Consolefd!=-1) && (FD_ISSET(Consolefd, &readfds))) {
		return K_CONSOLE;
	}

	sprintf(Msg1,"p_waitfor?  ret=%d errno=%d", ret, errno);
	mdep_popup(Msg1);
	return K_ERROR;
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
		sprintf(Msg1,"Display is not a supported type\nShould be PseudoColor, GrayScale, TrueColor or DirectColor\n");
		mdep_popup(Msg1);
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
	FD_ZERO(&ReadFds);
	FD_ZERO(&ExceptFds);
	if ( Consolefd >= 0 && ! ismuxable(Consolefd) ) {
		sprintf(Msg1,
      "Stdin can't support synchronous I/O multiplexing! (errno=%d).\n",errno);
		mdep_abortexit(Msg1);
	}
	else {
		if(Consolefd > MaxFdUsed) {
			MaxFdUsed = Consolefd;
		}
		if (Consolefd!=-1) {
			FD_SET(Consolefd, &ReadFds);
			FD_SET(Consolefd, &ExceptFds);
		}
	}
	ReadFdsInit = ReadFds;
	ExceptFdsInit = ExceptFds;
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
		sprintf(Msg1,"Cannot open Display (%s)\n",XDisplayName(NULL));
		mdep_abortexit(Msg1);
	}

	Displayfd = ConnectionNumber(dpy);

	/* We assume that if Displayfd is active, we're getting Console */
	/* keypresses from it, so we don't bother looking at Consolefd. */
	if(Displayfd > MaxFdUsed) {
		MaxFdUsed = Displayfd;
	}
	FD_SET(Displayfd, &ReadFds);
	FD_SET(Displayfd, &ExceptFds);

	ReadFdsInit = ReadFds;
	ExceptFdsInit = ExceptFds;

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
			mdep_abortexit("Unable to load a font!\n");
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

#if OLDSTUFF
	/* Something's wrong here - sometimes I don't */
	/* see the Expose event.  Hence the time limit. */
	et = mdep_currtime() + 2;
	while ( mdep_currtime() < et ) {
		if ( ! XPending(dpy) )
			millisleep(100);
		else if ( handle1input() == K_WINDEXPOSE )
			break;
	}
	if ( mdep_currtime() >= et ) {
		mdep_popup("Warning - didn't get initial expose event?\n");
	}
#endif
}

int
mdep_startgraphics(int argc,char **argv)
{
	int r;
	struct termios t;
	char myname[80];
	char *p;

	if ( (p=getenv("DISPLAY")) == NULL || *p == '\0' ) {
		Nographics = 1;
		*Graphics = 0;
		Usestdio = 1;
	} else {
		Nographics = 0;
		*Graphics = 1;
	}

	if ( GraphicsInitialized )
		return 0;

	if ( tcgetattr(0,&t) == 0 ) {
		Killchar = t.c_cc[VKILL];
		Erasechar = t.c_cc[VERASE];
		Intrchar = t.c_cc[VINTR];
	}
	else {
		Intrchar = 0x7f;
	}
#ifdef TTYSTUFF
	if ( Isatty ) {
		if ( tcsetattr(0, TCSANOW, &Initterm) < 0 )
			mdep_popup("Error in ioctl?\n");
	}
#endif

	if ( gethostname(myname,sizeof(myname)) < 0 ) {
		tprint("gethostname() failed?  Using 'localhost'\n");
		strcpy(myname,"localhost");
	}
	/* Change hostname to lower case */
	for ( p=myname; *p!=0; p++ ) {
		if ( *p >= 'A' && *p <= 'Z' )
			*p = *p - 'A' + 'a';
	}
	installstr("Hostname",myname);

	initfds();

	if ( Nographics )
		return 0;

	initdisplay(argc,argv);
	GraphicsInitialized = 1;
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
	if ( GraphicsInitialized )
		XCloseDisplay(dpy);
}

void
mdep_boxfill(int x0,int y0,int x1,int y1)
{
	if ( Nographics )
		return;
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
	if ( Nographics )
		return;

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
	if ( Nographics )
		return;
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

void
mdep_fillpolygon(int *xarr, int *yarr, int arrsize)
{
	tprint("fillpolygon not supported on linux.\n");
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
	/* FIX - 5/4/97 - just resize, don't move - related to */
	/* comments above in updatedrect */ 
#ifdef OLDVERSION
	XMoveResizeWindow(dpy, Disp.dr, x0,y0,x1-x0,y1-y0);
#endif
	XResizeWindow(dpy, Disp.dr, x1-x0,y1-y0);
	return 0;
}

int
mdep_screensize(int *x0, int *y0, int *x1, int *y1)
{
	if ( Nographics )
		return;
	/* Make sure any pending ConfigureNotify events get read */
	handleinput();

	/* sleep for 50 milliseconds to allow events to happen */
	/* BOGUS but seems to be needed. */
	usleep(1000*50);

	handleinput();

	/* FIX - 5/4/97 - related to comments above in updaterect */
#ifdef OLDVERSION
	*x0 = Rawsize.origin.x;
	*y0 = Rawsize.origin.y;
	*x1 = Rawsize.corner.x;
	*y1 = Rawsize.corner.y;
#endif
	*x0 = 0;
	*y0 = 0;
	*x1 = Rawsize.corner.x - Rawsize.origin.x;
	*y1 = Rawsize.corner.y - Rawsize.origin.y;
	return 0;
}

int
mdep_maxx(void)
{
	if ( Nographics )
		return 0;
	handleinput();
	return Dsize.x-1;
}
int
mdep_maxy(void)
{
	if ( Nographics )
		return 0;
	handleinput();
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

	if ( Nographics )
		return;

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

	if ( Nographics )
		return NULL;

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
	if ( Nographics )
		fprintf(stdout,"%s",s);
	else
		fprintf(stderr,"%s\n",s);
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

static char *
nameofsock(SOCKET sock)
{
	PORTHANDLE mp;

	if ( sock == INVALID_SOCKET )
		return NULL;
	for ( mp=Topport; mp!=NULL; mp=mp->next ) {
		if ( mp->sock == sock )
			return mp->name;
	}
	return NULL;
}

static void
sockerror(SOCKET sock,char *fmt,...)
{
	va_list args;
	char *name;

	makeroom(strlen(fmt)+64,&Msg2,&Msg2size);

	va_start(args,fmt);
	vsprintf(Msg2,fmt,args);
	va_end(args);

	name = nameofsock(sock);
	if ( name )
		tprint("TCP/IP error: %s (sockname=%s)\n",Msg2,name);
	else
		tprint("TCP/IP error: %s\n",Msg2);
}

static SOCKET
tcpip_listen(char *hostname, char *servname)
{
	SOCKADDR_IN local_sin; /* Local socket */
	PHOSTENT phe;  /* to get IP address */
	SOCKET sock;
	char myname[80];
	unsigned short port;
	int r;

	sock = socket( AF_INET, SOCK_STREAM, 0);
	if (sock == INVALID_SOCKET) {
		sockerror(sock,"socket() failed in tcpip_listen()");
		return INVALID_SOCKET;
	}
	if ( isdigit(*servname) ) {
		port = atol(servname);
		if ( port == 0 ) {
			sockerror(sock,"No such service/port: %s ",servname);
			return INVALID_SOCKET;
		}
		port = htons(port);
	} else {
		PSERVENT pse;
		pse = getservbyname(servname, "tcp");
		if (pse == NULL) {
			sockerror(sock,"getservbyname(%s) failed",servname);
			return INVALID_SOCKET;
		}
		port = pse->s_port;
	}
	local_sin.sin_family = AF_INET;
	local_sin.sin_port = port;

	if ( hostname != NULL ) {
		strncpy(myname,hostname,sizeof(myname));
	} else {
		if ( gethostname(myname,sizeof(myname)) < 0 ) {
			sockerror(sock,"gethostname() failed, errno=%d",errno);
			return INVALID_SOCKET;
		}
	}

	phe = gethostbyname(myname);
	if (phe == NULL) {
		sockerror(sock,"gethostbyname(%s) failed",myname);
		return INVALID_SOCKET;
	}

	memcpy((struct sockaddr *) &local_sin.sin_addr,
		*(char **)phe->h_addr_list, phe->h_length);

  	if (bind( sock, (struct sockaddr *) &local_sin, sizeof(local_sin)) == SOCKET_ERROR) {
		sockerror(sock,"bind(%s) failed, errno=%d",servname,errno);
		return INVALID_SOCKET;
	}

	fcntl(sock,F_SETFL,O_NONBLOCK);
	if ( listen( sock, 4) < 0) {
		sockerror(sock,"listen(%s) failed, errno=%d",servname,errno);
		return INVALID_SOCKET;
	}
	return sock;
}

static SOCKET
tcpip_connect(char *name, char *servname)
{
	SOCKADDR_IN dest_sin;  /* DESTination Socket INternet */
	PHOSTENT phe;
	SOCKET sock;
	int r;
	unsigned short port;

	/* See if the we know about the host (phe = Pointer Host Entity)*/

	phe = gethostbyname(name);
	if (phe == NULL) {
		sockerror(INVALID_SOCKET,"Unknown host %s",name);
		return INVALID_SOCKET;
	}

	if ( isdigit(*servname) ) {
		port = atol(servname);
		if ( port == 0 ) {
			sockerror(INVALID_SOCKET,"No such service/port: %s ",servname);
			return INVALID_SOCKET;
		}
		port = htons(port);
	} else {
		PSERVENT pse;
		pse = getservbyname(servname, "tcp");
		if (pse == NULL) {
			sockerror(INVALID_SOCKET,"getservbyname(%s) failed",servname);
			return INVALID_SOCKET;
		}
		port = pse->s_port;
	}
	dest_sin.sin_family = AF_INET;
	dest_sin.sin_port = port;

	sock = socket( AF_INET, SOCK_STREAM, 0);
	if (sock == INVALID_SOCKET) {
		sockerror(sock,"socket() failed, errno=%d",errno);
		return INVALID_SOCKET;
	}

	/* Finish up the Destination Socket */

	memcpy((struct sockaddr *) &dest_sin.sin_addr, *(char **)phe->h_addr_list,
		phe->h_length);

	fcntl(sock,F_SETFL,O_NONBLOCK);

	r = connect( sock, (PSOCKADDR) &dest_sin, sizeof( dest_sin));
	if ( r == SOCKET_ERROR && errno != EINPROGRESS ) {
		sockerror(sock,"connect() failed, errno=%d",errno);
		return INVALID_SOCKET;
	}
	/*
	 * Add it to the list of sockets
	 */
	return sock;
}

static int
tcpip_write(SOCKET sock,char *msg,int msgsize)
{
	int r;
	int nwritten = 0;

	while ( nwritten < msgsize ) {
		r = write(sock,msg+nwritten,msgsize-nwritten);
		if ( r == SOCKET_ERROR ) {
			sockerror(sock,"Error in tcpip_write() fd=%d errno=%d\n",sock,errno);
			return -1;
		}
		nwritten += r;
	}
	return nwritten;
}

static int
tcpip_recv(SOCKET sock,char *buff, int buffsize)
{
	int r = recv(sock,buff,buffsize,0);
	if ( r==0 )
		return 0;	/* socket has closed, perhaps we should eof? */
	if ( r == SOCKET_ERROR && errno == EWOULDBLOCK )
		return 0;
	if ( r == SOCKET_ERROR ) {
		sockerror(sock,"tcpip_recv() failed");
		return 0;
	}
	return r;
}

static int
tcpip_close(SOCKET sock)
{
	close(sock);
	return 0;
}

static Myport *
newmyport(char *name)
{
	Myport *m;
	m = (Myport *) kmalloc(sizeof(Myport),"newmyport");
	m->name = name;
	m->origsock = INVALID_SOCKET;
	m->rw = TYPE_NONE;
	m->sock = INVALID_SOCKET;
	m->sockstate = SOCK_UNCONNECTED;
	m->portstate = PORT_NORMAL;
	m->isopen = 0;
	m->checkit = 0;
	m->closeme = 0;
	m->hasreturnedfinaldata = 0;
	m->buff = NULL;
	m->buffsize = 0;
	m->savem0 = NULL;
	m->savem1 = NULL;

	m->next = Topport;
	Topport = m;
	return m;
}

static void
freemyport(Myport *m)
{
	Myport *prem = NULL;
	Myport *mm;

	for ( prem=NULL,mm=Topport; mm != NULL; mm=mm->next ) {
		if ( mm == m ) {
			/* remove it from list */
			if ( m == Topport )
				Topport = m->next;
			else
				prem->next = m->next;
			if ( m->buff )
				kfree(m->buff);
			kfree(m);
			return;
		} else {
			prem = mm;
		}
	}
}

PORTHANDLE *
mdep_openport(char *name, char *mode, char *type)
{
	static PORTHANDLE handle[2];
	PORTHANDLE m0, m1;
	char buff[BUFSIZ];
	char *p;
	SOCKET sock;

	if ( strcmp(type,"tcpip_connect") == 0 ) {
		strcpy(buff,name);
		p = strchr(buff,'@');
		if ( p == NULL ) {
			eprint("tcpip_connect name must contain a '@' !");
			return NULL;
		}
		*p++ = 0;
		sock = tcpip_connect(p,buff);
		if ( sock == INVALID_SOCKET ) {
			/* Assume tcpip_connect has printed an error */
			return NULL;
		}
		m0 = newmyport(name);
		m0->rw = TYPE_READ;
		m0->isopen = 1;
		m0->closeme = 1;
		m0->sock = sock;
		m0->sockstate = SOCK_UNCONNECTED;
		handle[0] = m0;

		m1 = newmyport(name);
		m1->rw = TYPE_WRITE;
		m1->isopen = 1;
		m1->sock = sock;
		m1->sockstate = SOCK_UNCONNECTED;
		handle[1] = m1;

		return handle;
	}
	if ( strcmp(type,"tcpip_listen") == 0 ) {
		SOCKET sock;

		if ( strchr(mode,'f') == NULL ) {
			eprint("mode on tcpip_listen must contain an 'f' !");
			return NULL;
		}
		if ( strchr(mode,'w') != NULL ) {
			eprint("mode on tcpip_listen can't contain a 'w' !");
			return NULL;
		}
		strcpy(buff,name);
		p = strchr(buff,'@');
		if ( p != NULL )
			*p++ = 0;
		sock = tcpip_listen(p,buff);
		if ( sock == INVALID_SOCKET ) {
			/* Assume tcpip_listen has printed an error */
			return NULL;
		}

		m0 = newmyport(name);
		m0->rw = TYPE_LISTEN;
		m0->isopen = 1;
		m0->closeme = 1;
		m0->origsock = sock;
		m0->sock = sock;	/* will be changed by accept() */
		m0->sockstate = SOCK_LISTENING;
		handle[0] = m0;

		handle[1] = (PORTHANDLE)0;

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

static void
doaccept(SOCKET sock)
{
	SOCKET newsock;
	int acc_sin_len;
	SOCKADDR_IN acc_sin;
	PORTHANDLE m0, m1, mp;
	char *name;
	char addrstr[16];

	acc_sin_len = sizeof(acc_sin);
	newsock = accept( sock,(PSOCKADDR) &acc_sin, &acc_sin_len );
	if ( newsock==INVALID_SOCKET ) {
		sockerror(sock,"accept() failed, errno=%d",errno);
		return;
	}
	fcntl(newsock,F_SETFL,O_NONBLOCK);

	/* create 2 new fifos for reading/writing new socket */
	prlongto(acc_sin.sin_addr.s_addr,addrstr);
	name = uniqstr(addrstr);

	m0 = newmyport(name);
	m0->rw = TYPE_READ;
	m0->isopen = 1;
	m0->closeme = 1;
	m0->sock = newsock;
	m0->sockstate = SOCK_CONNECTED;

	m1 = newmyport(name);
	m1->rw = TYPE_WRITE;
	m1->isopen = 1;
	m1->sock = newsock;
	m1->sockstate = SOCK_CONNECTED;

	/* Save port values for subsequent reading through tcpip_listen port */
	for ( mp=Topport; mp!=NULL; mp=mp->next ) {
		if ( mp->sock == sock ) {
			if ( mp->savem0 !=NULL || mp->savem1 != NULL ) {
				eprint("Warning, doaccept() found savem0/m1!=NULL !?");
				break;
			}
			mp->savem0 = m0;
			mp->savem1 = m1;
			mp->portstate = PORT_CANREAD;
		}
	}
}

static void
tcpip_checksock_accept(Myport *m)
{
	int soerr = 0;
	int soleng = sizeof(int);
	Myport *m2;

	if ( m->sockstate == SOCK_LISTENING ) {
		SOCKADDR_IN sin;  /* accepted socket */
		SOCKET s2;
		int addrlen;

		getsockopt(m->sock,SOL_SOCKET,SO_ERROR,&soerr,&soleng);
		if ( soerr == ECONNREFUSED ) {
			m->isopen = 0;
			m->sockstate = SOCK_REFUSED;
			for ( m2=Topport; m2!=NULL; m2=m2->next ) {
				if ( m2->sock == m->sock && m2 != m ) {
					m2->isopen = 0;
					m2->sockstate = SOCK_REFUSED;
					m2->sock = INVALID_SOCKET;
				}
			}
			tcpip_close(m->sock);
			m->sock = INVALID_SOCKET;
		} else {
			doaccept(m->sock);
		}
	}
}

static void
tcpip_checksock_connect(Myport *m)
{
	int soerr = 0;
	int soleng = sizeof(int);
	Myport *m2;

	if ( m->sockstate == SOCK_UNCONNECTED ) {
		getsockopt(m->sock,SOL_SOCKET,SO_ERROR,&soerr,&soleng);
		if ( soerr == ECONNREFUSED ) {
			m->isopen = 0;
			m->sockstate = SOCK_REFUSED;
			for ( m2=Topport; m2!=NULL; m2=m2->next ) {
				if ( m2->sock == m->sock && m2 != m ) {
					m2->isopen = 0;
					m2->sockstate = SOCK_REFUSED;
					m2->sock = INVALID_SOCKET;
				}
			}
			tcpip_close(m->sock);
			m->sock = INVALID_SOCKET;
		} else {
			m->sockstate = SOCK_CONNECTED;
		}
	}
}

int
mdep_putportdata(PORTHANDLE m, char *buff, int size)
{
	int r;

	tcpip_checksock_connect(m);
	switch (m->sockstate) {
	case SOCK_LISTENING:
#ifdef DEBUG
keyerrfile("mdep_putportdata using sockaway\n");
#endif
		sockaway(m,buff,size);	/* for delivery when it connects */
		r = size;
		break;
	case SOCK_UNCONNECTED:
	default:
		r = tcpip_write(m->sock,buff,size);
		break;
	}
	return r;
}

int
mdep_getportdata(PORTHANDLE *handle, char *buff, int buffsize, Datum *pd)
{
	Myport *m;
	Myport *m2;
	int r;
	int soerr = 0;
	int soleng = sizeof(int);

	for ( m=Topport; m!=NULL; m=m->next ) {

		if ( m->rw != TYPE_READ && m->rw != TYPE_LISTEN )
			continue;

		if ( m->sockstate == SOCK_CLOSED && m->hasreturnedfinaldata == 0 ) {
			m->hasreturnedfinaldata = 1;
			*handle = m;
			return 0;
		}
		if ( m->sockstate == SOCK_REFUSED && m->hasreturnedfinaldata == 0 ) {
			m->hasreturnedfinaldata = 1;
			*handle = m;
			return -2;
		}
		if ( ! m->isopen )
			continue;
		if ( m->rw == TYPE_LISTEN && m->checkit ) {
			tcpip_checksock_accept(m);
			m->checkit = 0;
		}

		if ( m->portstate == PORT_CANREAD ) {
			if ( m->sockstate == SOCK_LISTENING ) {
				PORTHANDLE *php;
				if ( m->savem0==NULL || m->savem1==NULL ) {
					tprint("Warning - got PORT_CANREAD when savem0/m1==NULL !?");
					continue;
				}
				/* return porthandle values as port data */
				php = (PORTHANDLE*)buff;
				*php++ = m->savem0;
				*php++ = m->savem1;
				m->savem0 = NULL;
				m->savem1 = NULL;
				r = 2 * sizeof(PORTHANDLE);
			}
			else if ( m->sockstate == SOCK_CLOSED ) {
				r = 0;
			}
			*handle = m;
			m->portstate = PORT_NORMAL;
			return r;
		}
		if ( m->rw == TYPE_READ ) {
			tcpip_checksock_connect(m);
		}
		if ( m->rw == TYPE_READ && m->checkit ) {
			m->checkit = 0;
			if ( m->sockstate == SOCK_CONNECTED ) {
				r = read(m->sock,buff,buffsize);
				if ( r < 0 ) {
					keyerrfile("mdep_getportdata read r=%d errno=%d\n",r,errno);
				}
				if ( r == 0 ) {
					*handle = m;
					m->isopen = 0;
					m->sockstate = SOCK_CLOSED;
					/*
					 * find the other one
					 */
					for ( m2=Topport; m2!=NULL; m2=m2->next ) {
						if ( m2!=m && m->sock == m2->sock ) {
							m2->isopen = 0;
							m2->sockstate = SOCK_CLOSED;
						}
					}
					return r;
				}
				*handle = m;
				m->portstate = PORT_NORMAL;
				return r;
			}
		}
	}
	return -1;
}

int
mdep_closeport(PORTHANDLE m)
{
	PORTHANDLE m2;

	m->isopen = 0;
	if ( m->rw != TYPE_NONE ) {
		if ( m->closeme ) {
			/*
			 * Find any other port with that sock,
			 * and mark it closed so it doesn't
			 * get used.
			 */
			for ( m2=Topport; m2!=NULL; m2=m2->next ) {
				if ( m2->sock == m->sock && m2 != m ) {
					m2->isopen = 0;
					m2->sock = INVALID_SOCKET;
				}
			}
			tcpip_close(m->sock);
			m->sock = INVALID_SOCKET;
			if ( m->origsock != INVALID_SOCKET ) {
				tcpip_close(m->origsock);
				m->origsock = INVALID_SOCKET;
			}
		}
	}
	freemyport(m);
	return 0;
}

int
mdep_help(char *fname, char *keyword)
{
	return(1);
}
