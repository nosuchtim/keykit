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

#define K_JOYBUTTON 0
#define K_JOYANALOG 1

// extern int errno;
extern HWND KeyHwnd;

static SIGFUNCTYPE Intrfunc;

static int Isatty = 0;
static int Nextchar = NOCHAR;
static int Conseof = 0;
static MSG Kmessage;

#define WS_VERSION_REQUIRED 0x0101
#define SOCK_UNCONNECTED 0
#define SOCK_CONNECTED 1
#define SOCK_CLOSED 2
#define SOCK_LISTENING 3
#define SOCK_REFUSED 4

#define PORT_NORMAL 0
#define PORT_CANREAD 1

#define TYPE_NONE 0
#define TYPE_READ 1
#define TYPE_WRITE 2
#define TYPE_LISTEN 3

typedef enum myport_type_t {
	MYPORT_TCPIP_READ = 1,
	MYPORT_TCPIP_WRITE = 2,
	MYPORT_TCPIP_LISTEN = 3,
	MYPORT_JOYSTICK = 4,
	MYPORT_GESTURE = 5,
	MYPORT_UDP_WRITE = 6,
	MYPORT_UDP_LISTEN = 7,
	MYPORT_OSC_WRITE = 8,
	MYPORT_OSC_LISTEN = 9
} myport_type_t;

struct myportinfo {
	char *name;
	myport_type_t myport_type;
	char rw;
	SOCKET sock;
	SOCKADDR_IN sockaddr;
	char portstate;
	char sockstate;
	char isopen;
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
char *Myhostname = NULL;
int NoWinsock = 1;

/* To make VC++ 6 happy */
typedef int (_stdcall *MYDLGPROC)(HWND,UINT,UINT,LONG);

static void sockaway(PORTHANDLE m,char *buff,int size);
static void sendsockedaway(PORTHANDLE mp);

static int Msx, Msy, Msb, Msm;	/* Mouse x, y, buttons, modifier */

Symlongp Cursereverse, Privatemap, Sharedmap, Forkoff;

#ifdef OLDSTUFF
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

static Point Dsize;
static MyRectangle Rawsize;
static MyBitmap Disp;
static int Inwind = 1;
static int Ncolors;
static int Sharecolors;
static int defscreen;
static int defdepth;

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
#endif

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

#define MAXEVENTS 512
static short Keyevents[MAXEVENTS];
static int Keyeventpos = 0;
static int Keyeventwarned = 0;
static int amBrowsing = 0;

static void
shiftup(short *arr,int n)
{
	int i;
	for ( i=n; i>0; i-- )
		arr[i] = arr[i-1];
}

static void
saveevent(int n)
{
	if ( Keyeventpos >= MAXEVENTS ) {
		/* Don't warn while the file browser is up */
		if ( amBrowsing==0 && Keyeventwarned == 0 ) {
			Keyeventwarned = 1;
			eprint("Too many events received by saveevent!");
		}
	}
	else {
		shiftup(Keyevents,Keyeventpos++);
		Keyevents[0] = n;
	}
}

void
saveportevent(void)
{
	saveevent(K_PORT);
}

// See if there's any event of a given type in the queue.
static int
ispendingevent(int n)
{
	int i;
	for ( i=Keyeventpos-1; i>=0; i-- ) {
		if ( Keyevents[i] == n )
			return 1;
	}
	return 0;
}

#define MAXMOUSE 256
int Keymousex[MAXMOUSE];
int Keymousey[MAXMOUSE];
int Keymouseb[MAXMOUSE];
int Keymousem[MAXMOUSE];
int Keymousepos = 0;

static void
savemouse(int x,int y,int b,int m)
{
	if ( Keymousepos >= MAXMOUSE )
		eprint("Too many events received by savemouse!");
	else {
		Keymousex[Keymousepos] = x;
		Keymousey[Keymousepos] = y;
		Keymouseb[Keymousepos] = b;
		Keymousem[Keymousepos] = m;
		Keymousepos++;
	}
}

static void
getmouseevent(void)
{
	if ( Keymousepos <= 0 )
		eprint("Hey, getmouseevent called when nothing to get!?");
	else {
		Msx = Keymousex[--Keymousepos];
		Msy = Keymousey[Keymousepos];
		Msb = Keymouseb[Keymousepos];
		Msm = Keymousem[Keymousepos];
	}
}

static int
getkeyevent(void)
{
	int r;

	if ( Keyeventpos <= 0 ) {
		Keyeventwarned = 0;
		r = -1;
	}
	else {
		r = Keyevents[--Keyeventpos];
		if (r == K_MOUSE)
			getmouseevent();
	}
	return r;
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

void
KeyTimerFunc(UINT  wID, UINT  wMsg, DWORD dwUser, DWORD dw1, DWORD dw2) {
	PostMessage(KeyHwnd, WM_KEY_TIMEOUT, 0, timeGetTime());
}

static int
handle1input(void)
{
	if ( PeekMessage (&Kmessage, NULL, 0, 0,PM_REMOVE) == FALSE ) {
		return FALSE;
	}
	TranslateMessage (&Kmessage) ;
	DispatchMessage (&Kmessage) ;
#if KEYDISPLAY
	AppDo3();
#endif
	return TRUE;
}

int
mdep_waitfor(int tmout)
{
	/*
	long tm0 = mdep_milliclock();
	long tm1 = tm0 + tmout;
	tprint("mdep_waitfor tmout=%d tm0=%ld tm1=%ld\n",tmout,tm0,tm1);
	long tm;
	while ( 1 ) {
		tm = mdep_milliclock();
		if ( tm >= tm1 ) {
			break;
		}
	}
	tprint("mdep_waitfor final tm=%ld\n",tm);
	return K_TIMEOUT;
	*/

	static int usetimer = 1;
	int n;
	int timerid = 0;
	long tm0, tm1;

	tm0 = mdep_milliclock();
	if ( tmout < *Millires ) {
		/* timeout is essentially 0, so don't block */
		if ( (n=getkeyevent()) > 0 )
			return n;
		if ( handle1input() == FALSE )
			return K_TIMEOUT;
		if ( (n=getkeyevent()) > 0 )
			return n;
		return K_TIMEOUT;
	}
	timerid = timeSetEvent((UINT)tmout,(UINT)(*Millires),
		(LPTIMECALLBACK)KeyTimerFunc, (DWORD_PTR)0, TIME_ONESHOT);
	if ( timerid == 0 ) {
		usetimer = 0;

/* screw the warning altogether */
#ifdef OLDSTUFF
		char buf[250];
		static int warned = 0;
		if ( ! warned ) {
			/* To disable initial warning, set KEYNOWARN env var.*/
			char *p = getenv("KEYNOWARN");
			if ( p == NULL || *p == '\0' ) {
				sprintf(buf,"The following warning will only appear once.\n"
					"Unable to use timeSetEvent!?  (Probably Win32s)\n"
					"TIMING WILL BE DONE WITH POLLING!");
				"tmout=%ld timeGetTime=%ld *Now=%ld  milli=%ld.\n"
				tmout,(long)timeGetTime(),*Now,mdep_milliclock());
				eprint(buf);
			}
			warned = 1;
		}
#endif

	}
	while (1) {
		if ( (n=getkeyevent()) > 0 )
			break;

		/* Here is where we block, if ever. */

		if ( usetimer ) {
			/*
			 * Usually, we quit because WM_DESTROY has
			 * done a saveevent(K_QUIT), but just in case,
			 * we check the return value of GetMessage
			 * anyway.
			 */
			if ( GetMessage(&Kmessage,NULL,0,0)==FALSE ) {
				return K_QUIT;
			}
			TranslateMessage (&Kmessage) ;
			DispatchMessage (&Kmessage) ;
#if KEYDISPLAY
			AppDo3();
#endif
		}
		else {
			/* THIS ONE DOES NOT BLOCK!!  For Win32s.  */
			(void) handle1input();
			tm1 = mdep_milliclock();
			if ( (tm1-tm0) > tmout )
				return K_TIMEOUT;
		}
		if ( tmout == 0 ) {
			/* If timeout is 0, we want to get out after only */
			/* 1 check of the message queues. */
			n = K_TIMEOUT;
			break;
		}
	}
	if ( timerid != 0 ) {
		if ( n != K_TIMEOUT )
			timeKillEvent(timerid);
	}
#ifdef SAVEFORARAINYDAY
{
	long tm1 = mdep_milliclock();
	long diff = tm1 - tm0 - tmout;
	if ( diff > *Milliwarn ) {
		eprint("Timeout mismatch (%ld) tm1=%ld Last=%ld",diff,tm1,Lasttimeout);
	}
}
#endif
	return n;

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
	*am = 0;
	return 0;
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

#ifdef OLDSTUFF
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
#endif

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

#ifdef OLDSTUFF
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

/*
Datum
mdep_mdep(int argc)
{
	return(Noval);
}
*/

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
#endif

int
mdep_help(char *fname,char *keyword)
{
	return(1);
}

#define NJOY 8
#define NJOYBUTTONS 24
static unsigned int JoyButts[NJOY] = {0};
static unsigned int JoyCaptured[NJOY] = {0};
static unsigned int JoyX[NJOY] = {0};
static unsigned int JoyY[NJOY] = {0};
static unsigned int JoyZ[NJOY] = {0};
static unsigned int JoyR[NJOY] = {0};
static unsigned int JoyU[NJOY] = {0};
static unsigned int JoyV[NJOY] = {0};
static int JoyMaxNum = 0;
static int JoyRunning = 0;

Datum
joyinit(int millipoll)
{
	JOYCAPS caps;
	int n;
	Datum d;
	int numdev;


	d = newarrdatum(0,3);
	numdev = joyGetNumDevs();
	if ( numdev >= NJOY )
		numdev = NJOY;

	JoyMaxNum = 0;
	for ( n=0; n<numdev; n++ ) {
		MMRESULT r = joyGetDevCaps(n,&caps,sizeof(JOYCAPS));
		if ( r == JOYERR_NOERROR ) {
			/*
			 * For some reason (at least on XP), capturing
			 * only seems to work once - i.e. if we do
			 * a joyReleaseCapture, a subsequent joySetCapture
			 * will fail.  So, we only do it once.
			 */
			if ( JoyCaptured[n] )
				r = JOYERR_NOERROR;
			else {
				JoyCaptured[n] = 1;
				r = joySetCapture(KeyHwnd,n,millipoll,FALSE);
			}
			if ( r != JOYERR_NOERROR ) {
				tprint("Ignoring Error in joySetCapture? (n=%d,err=%d caps=%s)\n",n,r,caps.szPname);
			}
			setarraydata(d.u.arr,numdatum(n),
			    strdatum(uniqstr(caps.szPname)));
			if ( JoyMaxNum < (n+1) )
				JoyMaxNum = n+1;
		}
	}
	JoyRunning = 1;
	return d;
}

void
joyrelease()
{
	JoyRunning = 0;
}

static void
joycheck(int t)
{
	BOOL r;
	int jn, bn;

	if ( JoyRunning == 0 )
		return;
	for ( jn=0; jn<JoyMaxNum; jn++ ) {
		JOYINFOEX jx;
		jx.dwSize = sizeof(jx);
		jx.dwFlags = JOY_RETURNBUTTONS
				| JOY_RETURNX
				| JOY_RETURNY
				| JOY_RETURNZ
				| JOY_RETURNR
				| JOY_RETURNU
				| JOY_RETURNV;
		r = joyGetPosEx(jn,&jx);
		if ( r!=JOYERR_NOERROR )
			continue;
		if ( jx.dwXpos != JoyX[jn] ) {
			JoyX[jn] = jx.dwXpos;
			saveevent(K_PORT);
			savejoy(K_JOYANALOG,jn,'X',jx.dwXpos);
		}
		if ( jx.dwYpos != JoyY[jn] ) {
			JoyY[jn] = jx.dwYpos;
			saveevent(K_PORT);
			savejoy(K_JOYANALOG,jn,'Y',jx.dwYpos);
		}
		if ( jx.dwZpos != JoyZ[jn] ) {
			JoyZ[jn] = jx.dwZpos;
			saveevent(K_PORT);
			savejoy(K_JOYANALOG,jn,'Z',jx.dwZpos);
		}
		if ( jx.dwRpos != JoyR[jn] ) {
			JoyR[jn] = jx.dwRpos;
			saveevent(K_PORT);
			savejoy(K_JOYANALOG,jn,'R',jx.dwRpos);
		}
		if ( jx.dwUpos != JoyU[jn] ) {
			JoyU[jn] = jx.dwUpos;
			saveevent(K_PORT);
			savejoy(K_JOYANALOG,jn,'U',jx.dwUpos);
		}
		if ( jx.dwVpos != JoyV[jn] ) {
			JoyV[jn] = jx.dwVpos;
			saveevent(K_PORT);
			savejoy(K_JOYANALOG,jn,'V',jx.dwVpos);
		}
		if ( jx.dwButtons != JoyButts[jn] ) {
			int oldv = JoyButts[jn];
			int newv = jx.dwButtons;
			for ( bn=0; bn<NJOYBUTTONS; bn++ ) {
				int oldbit = oldv & (1<<bn);
				int newbit = newv & (1<<bn);
				if ( oldbit != newbit ) {
					saveevent(K_PORT);
					savejoy(K_JOYBUTTON,jn,bn,newbit != 0);
				}
			}
			JoyButts[jn] = jx.dwButtons;
		}
	}
}


int
udp_send(PORTHANDLE mp,char *msg,int msgsize)
{
	SOCKET sock = mp->sock;
	int r;

	if ( NoWinsock )
		return INVALID_SOCKET;

	// keyerrfile("udp_send msg=(%s) size=%d\n",msg,msgsize);
	r = sendto(sock,msg,msgsize,0,(PSOCKADDR) &(mp->sockaddr),sizeof(SOCKADDR_IN));
	// keyerrfile("sendto returns r=(%d)\n",r);
	// tprint("udp sendto returns r=(%d)\n",r);
	if ( r == SOCKET_ERROR ) {
		int err = WSAGetLastError();
		sockerror(sock,"Error sending to socket, err=%d",err);
		return -1;
	}
	return 0;
}

static int
udp_recv(PORTHANDLE mp, char *buff, int buffsize)
{
	int r;
	SOCKET sock = mp->sock;
	SOCKADDR_IN src_sin;
	int len;
	int e;

	if (NoWinsock) {
		return -1;
	}

	errno = 0;
	len = sizeof(src_sin);
	r = recvfrom(sock,buff,buffsize,0,(PSOCKADDR) &src_sin,&len);

	if ( ! allowaccept(sock,&src_sin) ) {
		sockerror(sock,"udp_recv() failed");
		return -1;
	}

	// keyerrfile("(udp_recv r=%d e=%d wsa=%d buff=%d,%d,%d,%d)",
	// 	r,errno,WSAGetLastError(),buff[0],buff[1],buff[2],buff[3]);
	buff[buffsize-1] = 0;
	if ( r==0 )
		return -1;	/* socket has closed, perhaps we should eof? */
	e = WSAGetLastError();
	if ( r == SOCKET_ERROR && (e == WSAEWOULDBLOCK || e == WSAEFAULT) )
		return -1;
	if ( r == SOCKET_ERROR ) {
		// keyerrfile("SOCKET ERROR: (udp_recv r=%d e=%d wsa=%d buff=%d,%d,%d,%d)\n",
		// 	r,errno,e,buff[0],buff[1],buff[2],buff[3]);
		sockerror(sock,"udp_recv() failed");
		return -1;
	}
	return r;
}

int
my_ntohl(int v)
{
	return ntohl(v);
}
