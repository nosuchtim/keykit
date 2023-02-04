/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

/* This is the nt mdep2.c */

#define WINSOCK
#include <windows.h>
#include <mmsystem.h>
#include <malloc.h>
#include <mmsystem.h>
#ifdef WINSOCK
#include <winsock.h>
#endif
#include <stdlib.h>

#include <dos.h>
#include <time.h>
#include <io.h>
#include <direct.h>
#include "key.h"

#define K_JOYBUTTON 0
#define K_JOYANALOG 1

#define SEPARATOR "\\"
#define PALETTESIZE 256

#ifdef WINSOCK
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

#endif

HANDLE Khinstance;
HANDLE KhprevInstance;
int KnCmdShow;
HANDLE joyEvent = NULL;
HANDLE JoyHandle[1];

static int Msb = 0;
static int Msx, Msy;
static int Msm = 0;
static int Joyjt, Joyjn, Joybn, Joybv;
static int Fontht = -1, Fontwd = -1;
static int Plotmode = -1;
static MSG Kmessage ;
static HDC Firstdc = NULL;
static HDC Khdc = NULL;
static HCURSOR Kcursor = 0;
static long Lasttimeout;
static int Maxx, Maxy;
static int Palettesize = 0;
static HPEN hPen[KEYNCOLORS];
static HBRUSH hBrush[KEYNCOLORS];
static int Fgindex = 1;
static int Bgindex = 0;
static COLORREF Rgbvals[KEYNCOLORS];
static int Ignoretillup = 0;
static SIGFUNCTYPE Intrfunc;
static HPALETTE Hpal = NULL;
static int Inverted = 0;
static RECT Kwindrect;

HWND Khwnd;	/* DO NOT MAKE THIS STATIC!!! */

static void createpensandbrushes();
static void createlogpal(void);
static void setpalette(void);
static void recreatepenbrush(int n);
static void freecursors(void);
static void setfgpen(int);
static void setfgbrush(void);
static void setbgbrush(void);
static void setuprgb(int,int,int,int);
static void cleanexit(void);
static void deletepensandbrushes(void);
static char *keyhelp(char *);

#ifdef WINSOCK
static Myport *newmyport(char *);
static void sockerror(SOCKET,char *,...);
static int tcpip_recv(SOCKET,char *,int);
static int tcpip_send(PORTHANDLE,char *,int);
#endif

void handlemidioutput(long long,int);

// int errno;
/* int __mb_cur_max = 0x00100000L; */

void
mdep_popup(char *s)
{
	int n;
	if ( s == NULL )
		s = "Internal error?  NULL given to mdep_popup()?!";
	/* Sometimes there are blank messages, ignore them */
	if ( strcmp(s,"\n")==0 )
		return;
	// n = MessageBox(Khwnd, s, "KeyKit", MB_ICONEXCLAMATION | MB_OK);
	n = MessageBox(Khwnd, s, "KeyKit", 0);
	if ( n == IDCANCEL )
		cleanexit();
}

#define IDM_ABOUT 100
#define IDM_KEY_ABORT 105

LONG APIENTRY WndProc (HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam);

#if KEYDISPLAY
void AppDo3();
#endif

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

#define MAXJOYEV 64
int Keyjoyjt[MAXJOYEV];
int Keyjoyjn[MAXJOYEV];
int Keyjoybn[MAXJOYEV];
int Keyjoybv[MAXJOYEV];
int Keyjoypos = 0;

static void
savejoy(int jt, int jn, int bn, int bv)
{
	static long lastwarn = 0;

	if ( Keyjoypos >= MAXJOYEV ) {
		/* Don't complain, it's just annoying */
#if 0
		if ( complain==1 &&
			(lastwarn==0 || (mdep_milliclock()-lastwarn)>30000) ) {
			lastwarn = mdep_milliclock();
			eprint("Too many events received by savejoy!");
		}
#endif
	} else {
		Keyjoyjt[Keyjoypos] = jt;
		Keyjoyjn[Keyjoypos] = jn;
		Keyjoybn[Keyjoypos] = bn;
		Keyjoybv[Keyjoypos] = bv;
		Keyjoypos++;
	}
}

static BOOL
getjoy(void)
{
	if ( Keyjoypos <= 0 )
		return FALSE;
	else {
		--Keyjoypos;
		Joyjt = Keyjoyjt[Keyjoypos];
		Joyjn = Keyjoyjn[Keyjoypos];
		Joybn = Keyjoybn[Keyjoypos];
		Joybv = Keyjoybv[Keyjoypos];
		return TRUE;
	}
}

#define MAXCONSOLE 32
int Keyconsole[MAXCONSOLE];
int Keyconsolepos = 0;

static void
saveconsole(int n)
{
#ifdef DEBUGTYPING
keyerrfile("saveconsole n=0x%x consolepos=%d\n",n,Keyconsolepos);
#endif
	if ( Keyconsolepos >= MAXCONSOLE )
		eprint("Too many events received by saveconsole!");
	else
		Keyconsole[Keyconsolepos++] = n;
}

int
mdep_statconsole()
{
	return ( Keyconsolepos > 0 );
}

int
mdep_getconsole(void)
{
	int c;
	if ( Keyconsolepos <= 0 )
		c = -1;
	else
		c = Keyconsole[--Keyconsolepos];
	return c;
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

int WINAPI
WinMain (HINSTANCE hInstance, HINSTANCE hPrevInstance,
                    LPSTR lpszCmdParam, int nCmdShow)
{
	static char szAppName[] = "KeyKit" ;
	WNDCLASS    wndclass ;
	static char *argv[6];	/* static to avoid putting on stack */
	HMENU hmenu;
	int fx, fy, sx, sy, n;
	char *s, *p;
	int fullscreen = 0;

	n=0;
	argv[n++] = "key";
	s = strsave(lpszCmdParam); /* afraid to alter lpszCmdParam in-place */
	for ( p=strtok(s," "); p!=NULL; p=strtok(NULL," ") ) {
		if ( strcmp(p,"-F") == 0 )
			fullscreen = 1;
		else
			argv[n++] = p;
	}
	argv[n] = NULL;

	Khinstance = hInstance;
	KhprevInstance = hPrevInstance;
	KnCmdShow = nCmdShow;

	if (!hPrevInstance) {
		wndclass.style	       = CS_HREDRAW | CS_VREDRAW;
		/* wndclass.style	       = CS_HREDRAW | CS_VREDRAW | CS_OWNDC ; */
		wndclass.lpfnWndProc   = (WNDPROC) WndProc ;
		wndclass.cbClsExtra    = 0 ;
		wndclass.cbWndExtra    = 0 ;
		wndclass.hInstance     = hInstance ;
		wndclass.hIcon         = LoadIcon (Khinstance, "keykit") ;
		wndclass.hCursor       = NULL;
		wndclass.hbrBackground = GetStockObject (WHITE_BRUSH) ;
		wndclass.lpszMenuName  = NULL ;
		wndclass.lpszClassName = szAppName ;
		
		RegisterClass (&wndclass) ;
	}

	if ( !fullscreen ) {
		fx = GetSystemMetrics(SM_CXFULLSCREEN);
		fy = GetSystemMetrics(SM_CYFULLSCREEN);
		sx = 2*fx/3;
		sy = 2*fy/3;
		if ( sx > 800 )
			sx = 800;
		if ( sy > 600 )
			sy = 600;
		Khwnd = CreateWindow (szAppName,         // window class name
		    "KeyKit",     // window caption
                    WS_OVERLAPPEDWINDOW,     // window style
                    fx - sx - fx/20,           // initial x position
                    fy/20,           // initial y position
                    sx,           // initial x size
                    sy,           // initial y size
                    NULL,                    // parent window handle
                    NULL,                    // window menu handle
                    hInstance,               // program instance handle
		    NULL) ;		     // creation parameters
	} else {
		Khwnd = CreateWindowEx (0,szAppName,    // window class name
		    "KeyKit",     // window caption
                    WS_POPUP,     // window style
                    0,0,
                    GetSystemMetrics(SM_CXSCREEN),     // initial x size
                    GetSystemMetrics(SM_CYSCREEN),     // initial x size
                    NULL,                    // parent window handle
                    NULL,                    // window menu handle
                    hInstance,               // program instance handle
		    NULL) ;		     // creation parameters
	}

	Firstdc = GetDC (Khwnd);
	if ( Firstdc == NULL )
		eprint("Unable to get first DC!?");
	Khdc = Firstdc;

	createlogpal();

	ShowWindow (Khwnd, nCmdShow) ;
	UpdateWindow (Khwnd) ;

	hmenu = GetSystemMenu(Khwnd,FALSE);
	AppendMenu(hmenu,MF_SEPARATOR, 0, (LPSTR) NULL);
	AppendMenu(hmenu,MF_STRING, IDM_ABOUT, "About KeyKit...");
	AppendMenu(hmenu,MF_SEPARATOR, 0, (LPSTR) NULL);
	AppendMenu(hmenu,MF_STRING, IDM_KEY_ABORT, "Exit, when all else fails...");

	mdep_setcursor(M_ARROW);

	if (FAILED(CoInitialize(NULL))) {
		eprint("Unable to CoInitialize !?");
		return(0);
	}

	keymain(n,argv);
	return(0);
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
				r = joySetCapture(Khwnd,n,millipoll,FALSE);
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

static BOOL
AboutDlgProc (HWND hDlg, UINT message, UINT wParam, LONG lParam)
{
	switch(message) {
	case WM_INITDIALOG:
		return TRUE;
	case WM_COMMAND:
		switch(wParam) {
		case IDOK:
			EndDialog(hDlg, 0);
			return TRUE;
		case IDABORT:
			cleanexit();
		}
		break;
	}
	return FALSE;
}

static void
getfontinfo(void)
{
	TEXTMETRIC tm;
	BOOL r;

	r = GetTextMetrics (Khdc, &tm) ;
	if ( r != TRUE ) {
		eprint( "Error in GetTextMetrics!?  Lasterror=%ld",
			GetLastError());
	}
	Fontwd = tm.tmAveCharWidth ;
	Fontht = tm.tmHeight + tm.tmExternalLeading ;
	if ( Fontwd == 0 ) {
		eprint("Hmmm, Fontwd=0 ?  Bad news.");
		Fontwd = 12;
		Fontht = 14;
	}
}

static BOOL
allowaccept(SOCKET sock, SOCKADDR_IN *acc_sin) {
	char* keyallow = getenv("KEYALLOW");
	if (keyallow == NULL || *keyallow == '\0') {
		return FALSE;
	}
	SOCKADDR_IN allow_sin;
	allow_sin.sin_addr.s_addr = inet_addr(keyallow);
	ULONG allow_addr = allow_sin.sin_addr.S_un.S_addr;
	ULONG acc_addr = (*acc_sin).sin_addr.S_un.S_addr;
	/*
	char buff[1000];
	sprintf(buff, "%d,%d,%d,%d  %d,%d,%d,%d",
		allow_sin.sin_addr.S_un.S_un_b.s_b1,
		allow_sin.sin_addr.S_un.S_un_b.s_b2,
		allow_sin.sin_addr.S_un.S_un_b.s_b3,
		allow_sin.sin_addr.S_un.S_un_b.s_b4,
		
		acc_sin->sin_addr.S_un.S_un_b.s_b1,
		acc_sin->sin_addr.S_un.S_un_b.s_b2,
		acc_sin->sin_addr.S_un.S_un_b.s_b3,
		acc_sin->sin_addr.S_un.S_un_b.s_b4
		);
	*/
	if ((allow_sin.sin_addr.S_un.S_addr) == (acc_sin->sin_addr.S_un.S_addr)) {
		return TRUE;
	}
	return FALSE;
}

#ifdef WINSOCK
static void
doaccept(SOCKET sock) {
	SOCKET newsock;
	int acc_sin_len;
	SOCKADDR_IN acc_sin;
	PORTHANDLE m0, m1, mp;
	char *name;
	char addrstr[16];

	acc_sin_len = sizeof(acc_sin);
	newsock = accept( sock,(struct sockaddr FAR *) &acc_sin,
			 (int FAR *) &acc_sin_len );
	if ( newsock==INVALID_SOCKET ) {
		sockerror(sock,"accept() failed");
		return;
	}
	if ( ! allowaccept(sock,&acc_sin) ) {
		sockerror(sock,"accept() not allowed, set KEYALLOW to hostname allowed");
		return;
	}
	/* create 2 new fifos for reading/writing new socket */
	prlongto(acc_sin.sin_addr.S_un.S_addr,addrstr);
	name = uniqstr(addrstr);

	m0 = newmyport(name);
	m0->rw = TYPE_READ;
	m0->myport_type = MYPORT_TCPIP_READ;
	m0->isopen = 1;
	m0->closeme = 1;
	m0->sock = newsock;
	m0->sockstate = SOCK_CONNECTED;

	m1 = newmyport(name);
	m1->rw = TYPE_WRITE;
	m1->myport_type = MYPORT_TCPIP_WRITE;
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
#endif

static LONG APIENTRY
WndProc (HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	int m, mod, iLoop;
	NPLOGPALETTE pLogPal;
#ifdef WINSOCK
	SOCKET sock;
	Myport *mp;
	int nfound;
#endif
	
	switch (message) {
#ifdef WINSOCK
	case WM_KEY_SOCKET:
		sock = (SOCKET) wParam;

		saveevent(K_PORT);	/* don't really have to do it for */
					/* all FD_* events, but better not */
					/* to miss anything. */

		switch(WSAGETSELECTEVENT(lParam)) {
		case FD_READ:
/* tprint("FD_READ seen!\n"); */
			// tprint("Got FD_READ!\n");
			for ( mp=Topport; mp!=NULL; mp=mp->next ) {
				if ( mp->sock == sock && (
					mp->myport_type == MYPORT_TCPIP_READ
					|| mp->myport_type == MYPORT_UDP_LISTEN
					|| mp->myport_type == MYPORT_OSC_LISTEN
					)) {
/* tprint("Setting PORT_CANREAD\n"); */
					mp->portstate = PORT_CANREAD;
				}
			}
			break;
		case FD_WRITE:
			for ( mp=Topport; mp!=NULL; mp=mp->next ) {
				if ( mp->sock == sock ) {
					sendsockedaway(mp);
				}
			}
			break;
		case FD_ACCEPT:
			doaccept(sock);
			break;
		case FD_CONNECT:
			/* remember there's 2 ports for each socket. */
			nfound = 0;
			for ( mp=Topport; mp!=NULL; mp=mp->next ) {
				if ( mp->sock == sock ) {
					if ( mp->sockstate == SOCK_UNCONNECTED )
						mp->sockstate = SOCK_CONNECTED;
					if ( mp->rw == TYPE_WRITE ) {
						sendsockedaway(mp);
					}
					nfound++;
				}
			}
			if ( nfound == 0 )
				eprint("FD_CONNECT didn't find sock!?");
			break;
		case FD_OOB:
			break;
		case FD_CLOSE:
			/* remember, there's 2 ports for each socket. */
			nfound = 0;
			for ( mp=Topport; mp!=NULL; mp=mp->next ) {
				if ( mp->sock == sock ) {
					mp->sockstate = SOCK_CLOSED;
					if ( mp->myport_type == MYPORT_TCPIP_READ ) {
// tprint("Setting mp->portstate to PORT_CANREAD!\n");
						mp->portstate = PORT_CANREAD;
					}
					nfound++;
				}
			}
			if ( nfound == 0 )
				eprint("FD_CLOSE didn't find sock!?");
			break;
		}
		return 0;
#endif
	case WM_TIMER:
		/* These messages should only be received while */
		/* mdep_browse() is active.  Something of a hack. */
		chkinput();
		chkoutput();
		handlewaitfor(mdep_waitfor(0));
		return 0;
	case WM_KEY_TIMEOUT:
		saveevent(K_TIMEOUT);
		Lasttimeout = (long)lParam;
		return 0;
	case WM_KEY_ERROR:
		return 0;
	case WM_KEY_MIDIINPUT:
		saveevent(K_MIDI);
		return 0;
#if 0
	case WM_KEY_MIDIOUTPUT:
		/* The wParam is the port */
		handlemidioutput( lParam, (int) wParam );
		return 0;
#endif
	case WM_KEY_PORT:
		return 0;
	case WM_QUERYNEWPALETTE:
		setpalette();
		return TRUE;
#ifdef OLDSTUFF
	case WM_PALETTECHANGED:
		// mdep_popup("WndProc got WM_PALETTECHANGED!");
		return 0;
	case WM_PALETTEISCHANGING:
		return 0;
#endif
	case WM_SETFOCUS:
		setpalette();
		return 0;
	case WM_CREATE:
		pLogPal = (NPLOGPALETTE) LocalAlloc (LMEM_FIXED,
			  (sizeof (LOGPALETTE) +
			  (sizeof (PALETTEENTRY) * (PALETTESIZE))));
		if(!pLogPal){
			MessageBox(hwnd, "<WM_CREATE> Not enough memory for palette.", NULL, MB_OK | MB_ICONHAND);
			PostQuitMessage (0) ;
			break;
		}
		pLogPal->palVersion    = 0x300;
		pLogPal->palNumEntries = PALETTESIZE;

		/* fill in intensities for all palette entry colors */
		for (iLoop = 0; iLoop < PALETTESIZE; iLoop++) {
			*((WORD *) (&pLogPal->palPalEntry[iLoop].peRed)) = (WORD)iLoop;
			pLogPal->palPalEntry[iLoop].peBlue  = 0;
			pLogPal->palPalEntry[iLoop].peFlags = PC_EXPLICIT;
		}
		Hpal = CreatePalette ((LPLOGPALETTE) pLogPal) ;
		return 0 ;
	case WM_SYSCOMMAND:
		switch (wParam) {
		case IDM_ABOUT: {
			eprint("ABOUT Dialog has been disabled\n");
			// FARPROC lpfnDlgProc = 
			//	MakeProcInstance (AboutDlgProc, Khinstance);
			// DialogBoxA(Khinstance, "AboutBox", Khwnd,
			//	(MYDLGPROC) lpfnDlgProc);
			// FreeProcInstance(lpfnDlgProc);
			}
			return 0;
		case IDM_KEY_ABORT:
			exit(1);
			return 0;
		case SC_SCREENSAVE:
			return 1;
		}
		break;
	case WM_SIZE:
		Maxx = LOWORD(lParam);
		Maxy = HIWORD(lParam);

		/* We grab it here, because we might be on our way out */
		/* (exiting) when we want to get it in mdep_screensize(). */
		{
			RECT r;
			if ( GetWindowRect(Khwnd,&r) == FALSE )
				Kwindrect.right = -1;
			else
				Kwindrect = r;
		}

		if ( (wParam == SIZE_MAXIMIZED
			|| wParam ==SIZE_RESTORED
			|| wParam ==SIZE_MAXSHOW )
			&& !ispendingevent(K_WINDRESIZE) ) {
			saveevent(K_WINDRESIZE);
		}
		break;
	case WM_KEYDOWN:
		/* for function keys */
		if ( wParam >= 112 && wParam <= 123 ) {
			saveconsole((int)((wParam-112)|FKEYBIT));
			saveevent(K_CONSOLE);
			return 0;
		}
		if ( *Consupdown != 0 ) {
#ifdef DEBUGTYPING
keyerrfile("KEYDOWN lParam=0x%lx wParam=0x%lx\n",(long)lParam,(long)wParam);
#endif
			if ( (lParam & (1<<30)) != 0 ) {
				/* It's a repeat character, don't add */
			} else {
				/* It's the first time for this char */
				if ( (int)wParam == 3 && Intrfunc != NULL ) {
					(*Intrfunc)(SIGINT);
				}
				else {
					/* a normal character */
					saveconsole((int)(wParam|KEYDOWNBIT));
					saveevent(K_CONSOLE);
				}
			}
			return 0;
		}
		break;
	case WM_KEYUP:
		if ( *Consupdown != 0 ) {
#ifdef DEBUGTYPING
keyerrfile("KEYUP lParam=0x%lx wParam=0x%lx\n",(long)lParam,(long)wParam);
#endif
			/* It's the first time for this char */
			if ( (int)wParam == 3 && Intrfunc != NULL ) {
				/* (*Intrfunc)(SIGINT); */
			}
			else {
				/* a normal character */
				saveconsole((int)(wParam|KEYUPBIT));
				saveevent(K_CONSOLE);
			}
			return 0;
		}
		break;
	case WM_CHAR:
		if ( *Consupdown == 0 ) {
			if ( (int)wParam == 3 && Intrfunc != NULL ) {
				(*Intrfunc)(SIGINT);
			}
			else {
				/* a normal character */
				saveconsole((int)wParam);
				saveevent(K_CONSOLE);
			}
		}
		return 0;

	case WM_LBUTTONDOWN:
	case WM_MBUTTONDOWN:
	case WM_RBUTTONDOWN:
		if ( Ignoretillup )
			return 0;
		m = mod = 0;
		if ( wParam & MK_LBUTTON )
			m |= 1;
		else if ( (wParam & MK_RBUTTON) || (wParam & MK_MBUTTON) )
			m |= 2;
		if ( wParam & MK_CONTROL )
			mod |= 1;
		if ( wParam & MK_SHIFT )
			mod |= 2;
		goto gotmouse;

	case WM_LBUTTONUP:
	case WM_MBUTTONUP:
	case WM_RBUTTONUP:
		m = mod = 0;
		if ( Ignoretillup ) {
			Ignoretillup = 0;
			return 0;
		}
	    gotmouse:
		saveevent(K_MOUSE);
		savemouse(LOWORD(lParam),HIWORD(lParam),m,mod);
		return 0;

	case WM_MOUSEMOVE:
		if ( Ignoretillup )
			return 0;
		SetCursor(Kcursor);
		saveevent(K_MOUSE);
		m = 0;
		if ( wParam & MK_LBUTTON )
			m |= 1;
		else if ( (wParam & MK_RBUTTON) || (wParam & MK_MBUTTON) )
			m |= 2;
		savemouse(LOWORD(lParam),HIWORD(lParam),m,0);
		return 0;

	case WM_ACTIVATE:
		if ( LOWORD(wParam) == WA_CLICKACTIVE )
			Ignoretillup = 1;
		return 0;

	case WM_PAINT:
		/* if ( ! ispendingevent(K_WINDRESIZE) && ! ispendingevent(K_WINDEXPOSE) ) */
		if ( ! ispendingevent(K_WINDEXPOSE) ) {
			saveevent(K_WINDEXPOSE);
		}
		ValidateRect(hwnd, NULL);
		return 0 ;

	case WM_CLOSE:
		/* The window handle is used in the midi callback, so make sure */
		/* midi gets closed before the window is destroyed. */
		mdep_endmidi();
		saveevent(K_QUIT);
		return 0;

	case WM_QUIT:
		mdep_endmidi();		/* not really needed, but just in case */
		saveevent(K_QUIT);
		return 0;

	case WM_DESTROY:
		mdep_endmidi();		/* not really needed, but just in case */
		saveevent(K_QUIT);
		return 0 ;

	case MM_JOY1MOVE:
	case MM_JOY2MOVE:
	case MM_JOY1ZMOVE:
	case MM_JOY2ZMOVE:
		joycheck(1);
		return 0;
	case MM_JOY1BUTTONDOWN:
	case MM_JOY2BUTTONDOWN:
	case MM_JOY1BUTTONUP:
	case MM_JOY2BUTTONUP:
		joycheck(2);
		return 0;
	}

	return (long)(DefWindowProc (hwnd, message, wParam, lParam)) ;
}

static int
isadir(char *dir)
{
	struct _stat s;

	if ( _stat(dir,&s) < 0 || (s.st_mode & _S_IFDIR) == 0 )
		return(0);
	else
		return(1);
}

static void
addifdir(char *dir,char *buff)
{
	if ( isadir(dir) ) {
		strcat(buff,";");
		strcat(buff,dir);
	}
}

static char *
keyroot(void)
{
	static char *root = NULL;
	char *cmd, *p, *pfile;
	char buff[BUFSIZ];

	if ( root )
		return root;

	cmd = GetCommandLine();
	if ( (p=strchr(cmd,' ')) != NULL )
		*p = '\0';
	if ( (p=strrchr(cmd,'/')) != NULL )
		cmd = p+1;
	if ( (p=strrchr(cmd,'\\')) != NULL )
		cmd = p+1;

	/* KEYROOT, if set, now overrides the exe path, */
	/* so the lib and bin directories can be in different places. */

	if ( (p=getenv("KEYROOT")) != NULL && *p != '\0' ) {

		/* If (and only if) KEYROOT is set and used, we chdir to it */
		root = uniqstr(p);
		_chdir(root);

	} else if ( SearchPath(NULL,cmd,".exe",BUFSIZ,buff,&pfile) == 0 ) {

		/* If we can't get it by looking for the exe, */
		/* last last resort is ".." */

		if ( exists("../lib/keyrc.k") )
			root = uniqstr("..");
		else if ( exists("c:\\key\\lib\\keyrc.k") )
			root = uniqstr("c:\\key");
		else {
			eprint("KEYROOT not set!  Last resort - trying '..'");
			root = uniqstr("..");
		}
	}
	else {
		cmd = buff;
		/* Take off file.exe */
		if ( (p=strrchr(cmd,'/')) != NULL )
			*p = '\0';
		else if ( (p=strrchr(cmd,'\\')) != NULL )
			*p = '\0';
		/* Take off parent directory (i.e. src or bin) */
		if ( (p=strrchr(cmd,'/')) != NULL )
			*p = '\0';
		else if ( (p=strrchr(cmd,'\\')) != NULL )
			*p = '\0';
		root = uniqstr(cmd);
	}
	return root;
}

static char *
keyhelp(char *fname)
{
	char *p, *str;

	p = (char *) kmalloc((unsigned)(3*strlen(keyroot())+64),"keyhelp");
	sprintf(p,"%s%s%s%s%s",keyroot(),SEPARATOR,"doc",SEPARATOR,fname);
	str = uniqstr(p);
	kfree(p);
	if ( ! exists(str) ) {
		sprintf(p,"%s doesn't exist!?",str);
		eprint(p);
		return NULL;
	}
	return str;
}

void
mdep_prerc(void)
{
	/* Warning - this may be the second time we call GetDeviceCaps for */
	/* this stuff - createlogpal() may have been called by this time. */

	/* Find out how many colors we have. */
	if ( (GetDeviceCaps(Khdc,RASTERCAPS) & RC_PALETTE) == 0 ) {
		*Colors = GetDeviceCaps(Khdc, NUMCOLORS);
		/* documentation says -1 means it has more than 8 bits/pixel */
		if ( *Colors == -1 || *Colors > KEYNCOLORS )
			*Colors = KEYNCOLORS;
	}
	else {
		*Colors = KEYNCOLORS;	/* size of logical palette */
	}
	*Pathsep = uniqstr(PATHSEP);
	*Panraster = 0;
	*Keyroot = keyroot();
}

void
mdep_initcolors(void)
{
	int n = 256;
	char *p = getenv("KEYINVERSE");

	if ( p != NULL && *p != '0' ) {
		Inverted = 1;
		mdep_colormix(0, 0, 0, 0 );		/* black */
		mdep_colormix(1, 255*n, 255*n, 255*n);	/* white */
		mdep_colormix(2, 255*n, 0, 0	);	/* red, for Pickcolor */
		mdep_colormix(3, 100*n, 100*n, 100*n);	/* */
		mdep_colormix(4, 200*n, 200*n, 200*n);	/* button pressed */
		mdep_colormix(5, 50*n, 50*n, 50*n);	/* button background */
	}
	else {
		Inverted = 0;
		mdep_colormix(0, 255*n, 255*n, 255*n);	/* white */
		mdep_colormix(1, 0, 0, 0 );		/* black */
		mdep_colormix(2, 255*n, 0, 0	);	/* red, for Pickcolor */
		mdep_colormix(3, 200*n, 200*n, 200*n);	/* */
		mdep_colormix(4, 100*n, 100*n, 100*n);	/* button pressed */
		mdep_colormix(5, 210*n, 210*n, 210*n);	/* button background */
	}
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
		p = (char *) kmalloc((unsigned)(2*strlen(keyroot())+128),"keypath");
		sprintf(p,".%s%s%sliblocal%s%s%slib",
			PATHSEP,keyroot(),SEPARATOR,
			PATHSEP,keyroot(),SEPARATOR);
		path = uniqstr(p);
		kfree(p);
	}
	return path;
}

char *
mdep_musicpath(void)
{
	char *p, *str;

	p = (char *) kmalloc((unsigned)(3*strlen(keyroot())+64),"musicpath");
	sprintf(p,".%s%s%smusic%s%s%smidifiles",
		PATHSEP,keyroot(),SEPARATOR,
		PATHSEP,keyroot(),SEPARATOR);
	str = uniqstr(p);
	kfree(p);
	return str;
}

void
mdep_postrc(void)
{
}

static void
cleanexit(void)
{
	mdep_endmidi();
	mdep_bye();
	exit(0);
}

void
mdep_abortexit(char *s)
{
	DebugBreak();		/* for debugging? */
	/* FatalAppExit(0,s); 	/* in final version */

	/* NOTREACHED */
	exit(1);
}

int
mdep_shellexec(char *s)
{
	return system(s);
}

void
mdep_setinterrupt(SIGFUNCTYPE i)
{
	Intrfunc = i;
	signal(SIGFPE, i);
	signal(SIGILL, i);
	/*  signal(SIGINT, i);   */
	signal(SIGSEGV, i);
	/*  signal(SIGTERM, i);  */
}

void
mdep_ignoreinterrupt(void)
{
	Intrfunc = NULL;
	signal(SIGFPE, SIG_IGN);
	signal(SIGILL, SIG_IGN);
	/*  signal(SIGINT, SIG_IGN);   */
	signal(SIGSEGV, SIG_IGN);
	/*  signal(SIGTERM, SIG_IGN);  */
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

int Ktimehack = 0;

int
mdep_waitfor(int tmout)
{
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

/* From here on down is plotting support */

typedef struct Mbitmap {
	HBITMAP hBitmap;
} Mbitmap;

static void
starttimerstuff(void)
{
	TIMECAPS tc;

	/* This gets done only once.  We do it here so that programs can */
	/* use the graphical stuff without calling mdep_initmidi.  */

	timeGetDevCaps(&tc, sizeof(TIMECAPS));
	if ( tc.wPeriodMin > (UINT)(*Millires) ) {
		*Millires = tc.wPeriodMin;
		if ( *Milliwarn < *Millires )
			*Milliwarn = *Millires * 10;
#ifdef FORTHEMOMENTNOWARNING
		char buff[128];
		sprintf(buff,"Warning - wPeriodMin=%d Millires=%ld Milliwarn=%ld - Realtime may suffer",
			tc.wPeriodMin,*Millires,*Milliwarn);
		eprint(buff);
#endif
	}
	if ( timeBeginPeriod((UINT)(*Millires)) )
		eprint("timeBeginPeriod fails!?");

	if ( KeySetupDll(Khwnd) ) {
		eprint("KeySetupDll fail!?");
	}
}

int
mdep_startgraphics(int argc,char **argv)
{
	static first = 1;

	if ( ! first )
		return 0;
	first = 0;
	createpensandbrushes();
	starttimerstuff();
	installstr("Hostname","localhost");
	Myhostname = "localhost";
#ifdef WINSOCK
	{
		int err;
		char *p;
		WSADATA wsaData;
		char myname[80];
		DWORD dwSize;

		err = WSAStartup(WS_VERSION_REQUIRED,&wsaData);
		if ( err ) {
			sockerror(INVALID_SOCKET,"WSAStartup failed!? (maybe wrong version?)");
			goto getout;
		}

		/* Get hostname --
			** Assumption that you have modified
			your hosts file (in system/drivers/etc/hosts. */

		dwSize = sizeof(myname);
		if ( GetComputerNameA(myname,&dwSize) == FALSE ) {
			if ( gethostname(myname,sizeof(myname)) < 0 ) {
				sockerror(INVALID_SOCKET,"GetComputerName() AND gethostname() failed!?  Using 'localhost'");
				strcpy(myname,"localhost");
			}
		}
		/* Change hostname to lower case */
		for ( p=myname; *p!=0; p++ ) {
			if ( *p >= 'A' && *p <= 'Z' )
				*p = *p - 'A' + 'a';
		}
		installstr("Hostname",myname);
		Myhostname = uniqstr(myname);
		NoWinsock = 0;
	}
    getout:
#endif
	return(0);
}

#define FILENAMESIZE   300

char *
mdep_browse(char *desc, char *types, int mustexist)
{
	static char szFilter[FILENAMESIZE];
	static char szFileName[FILENAMESIZE];
	static char saveddir[_MAX_PATH];
	static int saved = 0;
	char origdir[_MAX_PATH];
	OPENFILENAME ofn;
	char *fn;
	int i = 0 ;
	UINT_PTR timerid;

	if ( GetCurrentDirectory(_MAX_PATH,origdir) == 0 )
		origdir[0] = 0;
	if ( saved )
		_chdir(saveddir);
	ofn.lStructSize 	 = sizeof(OPENFILENAME);
	ofn.hwndOwner		 = Khwnd;
	ofn.hInstance            = Khinstance ;
	ofn.lpstrFilter		 = szFilter;
	ofn.lpstrCustomFilter    = NULL;
	ofn.nFilterIndex         = 1L ;
	ofn.lpstrFile            = szFileName ;
	ofn.nMaxFile             = FILENAMESIZE ;
	ofn.lpstrFileTitle       = NULL ;
	ofn.nMaxFileTitle        = 0 ;
	ofn.lpstrInitialDir      = NULL;
	ofn.lpstrTitle  	 = NULL ;
	ofn.Flags                = 0 ;
	ofn.nFileOffset          = 0 ;
	ofn.nFileExtension       = 0 ;
	ofn.lpstrDefExt 	 = NULL;
	ofn.lCustData            = 0L ;
	if ( mustexist )
		ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST | OFN_READONLY;
	else
		ofn.Flags = OFN_READONLY;
	ofn.Flags = 0;

	szFileName[0] = '\0';

	strcpy(szFilter,desc);
	strcat(szFilter,"|");
	strcat(szFilter,types);
	strcat(szFilter,"|");

	for (i = 0; szFilter[i] != '\0'; i++){
		if (szFilter[i] == '|')
			szFilter[i] = '\0';
	}

	/* We sent WM_TIMER messages every 2 milliseconds, so we get at */
	/* least some realtime I/O, though no KeyKit statement processing. */
	timerid = SetTimer(Khwnd,1,2,NULL);
	amBrowsing = 1;

	/* Display the Open dialog box. */
	if ( GetOpenFileName(&ofn) == TRUE )
		fn = ofn.lpstrFile;
	else
		fn = NULL;

	KillTimer(Khwnd,timerid);
	amBrowsing = 0;

	Ignoretillup = 1;
	if ( GetCurrentDirectory(_MAX_PATH,saveddir) )
		saved = 1;
	if ( origdir[0] != 0 )
		_chdir(origdir);
	return fn;
}

/* NOTE: the values that mdep_screenresize() and mdep_screensize() use are NOT */
/*       the same as what mdep_maxx() and mdep_maxy() give.  mdep_maxx() and mdep_maxy() */
/*       give the size of the plotting area, which is not the same as the */
/*       size of the enclosing window frame, which is what mdep_screensize() */
/*       gives and what mdep_screenresize() expects. */
int
mdep_screenresize(int x0, int y0, int x1, int y1)
{
	int n;
	n = SetWindowPos(Khwnd,HWND_TOP,x0,y0,x1-x0,y1-y0,SWP_NOCOPYBITS);
	return (n==FALSE);
}

int
mdep_screensize(int *x0, int *y0, int *x1, int *y1)
{
	if ( Kwindrect.right < 0 ) {
		RECT r;
		if ( GetWindowRect(Khwnd,&r) == FALSE )
			return 1;
		Kwindrect = r;
	}
	*x0 = Kwindrect.left;
	*y0 = Kwindrect.top;
	*x1 = Kwindrect.right;
	*y1 = Kwindrect.bottom;
	return 0;
}

int
mdep_maxx()
{
	return Maxx;
}

int
mdep_maxy()
{
	return Maxy;
}

void
mdep_plotmode(int mode)
{
	if ( mode == Plotmode )
		return;
	if ( mode!=P_STORE && mode!=P_CLEAR && mode!=P_XOR ) {
		eprint("Bad mode (%d) in mdep_plotmode",mode);
		return;
	}
	Plotmode = mode;

	if ( Plotmode == P_STORE ) {
		setfgpen(Fgindex);
		SetROP2(Khdc,R2_COPYPEN);
		SetTextColor(Khdc,Rgbvals[Fgindex]);
	}
	else if ( Plotmode == P_CLEAR ) {
		setfgpen(Bgindex);
		SetROP2(Khdc,R2_COPYPEN);
		SetTextColor(Khdc,Rgbvals[Bgindex]);
	}
	else {
		setfgpen(Fgindex);
		/* It really should always be XORPEN, but for some reason */
		/* it doesn't work when doing black on white background? */
		if ( Inverted )
			SetROP2(Khdc,R2_XORPEN);
		else
			SetROP2(Khdc,R2_MERGEPENNOT);
		SetROP2(Khdc,R2_NOT);
		SetTextColor(Khdc,Rgbvals[Fgindex]);
	}
}

void
mdep_endgraphics(void)
{
	freecursors();
	deletepensandbrushes();
#ifdef WINSOCK
	if ( WSACleanup() )
		sockerror(INVALID_SOCKET,"WSACleanup() failed");
#endif
}

void
mdep_destroywindow()
{
	MSG msg;

	DestroyWindow(Khwnd);
	PostQuitMessage(0);

	/* Acquire and dispatch messages until a WM_QUIT message is received. */
	while (GetMessage(&msg, NULL, 0, 0)) {
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}

	CoUninitialize() ;
}

void
mdep_line(int x0,int y0,int x1,int y1)
{
	POINT pt[3];

	pt[0].x = x0;
	pt[0].y = y0;
	pt[1].x = x1;
	pt[1].y = y1;
	/* The additional entry here is because */
	/* we want inclusive endpoints. */
	pt[2].x = x1+1;
	pt[2].y = y1+1;

	if ( Polyline(Khdc,pt,3) == FALSE )
		eprint("Polyline fails in mdep_line!?\n");
}

void
mdep_box(int x0,int y0,int x1,int y1)
{
	POINT pt[5];

	pt[0].x = x0;
	pt[0].y = y0;
	pt[1].x = x1;
	pt[1].y = y0;
	pt[2].x = x1;
	pt[2].y = y1;
	pt[3].x = x0;
	pt[3].y = y1;
	pt[4].x = x0;
	pt[4].y = y0;
	if ( Polyline(Khdc,pt,5) == FALSE )
		eprint("Polyline fails in mdep_box!?\n");
}

void
mdep_boxfill(int x0,int y0,int x1,int y1)
{
	int t;

	if ( x0 > x1 ) {
		t = x0;
		x0 = x1;
		x1 = t;
	}
	if ( y0 > y1 ) {
		t = y0;
		y0 = y1;
		y1 = t;
	}

#ifdef THETHOUGHTDIDNTCOUNT
	/* The drawing of lines vs filled boxes doesn't appear to speed */
	/* it up noticably, but it's the thought that counts.  :-)  */

	if ( x0 == x1 ) {
		MoveToEx(Khdc,x0,y0,(LPPOINT)NULL);
		LineTo(Khdc,x1,y1+1);
	}
	else if ( y0 == y1 ) {
		MoveToEx(Khdc,x0,y0,(LPPOINT)NULL);
		LineTo(Khdc,x1+1,y1);
	}
	else {
#endif
		switch(Plotmode){
		case P_CLEAR:
			setbgbrush();
			PatBlt(Khdc,x0,y0,(x1-x0+1),(y1-y0+1),PATCOPY);
			break;
		case P_STORE:
			setfgbrush();
			PatBlt(Khdc,x0,y0,(x1-x0+1),(y1-y0+1),PATCOPY);
			break;
		case P_XOR:
			setfgbrush();
			PatBlt(Khdc,x0,y0,(x1-x0+1),(y1-y0+1),DSTINVERT);
			break;
		}
}

void
mdep_ellipse(int x0,int y0,int x1,int y1)
{
	SelectObject(Khdc, GetStockObject(HOLLOW_BRUSH));
	switch(Plotmode){
	case P_CLEAR:
		setfgpen(Bgindex);
		Ellipse(Khdc,x0,y0,x1,y1);
		break;
	case P_STORE:
		setfgpen(Fgindex);
		Ellipse(Khdc,x0,y0,x1,y1);
		break;
	}
	setfgbrush();
}

void
mdep_fillellipse(int x0,int y0,int x1,int y1)
{
	switch(Plotmode){
	case P_CLEAR:
		setfgpen(Bgindex);
		setbgbrush();
		Ellipse(Khdc,x0,y0,x1,y1);
		setfgbrush();
		break;
	case P_STORE:
		setfgbrush();
		setfgpen(Fgindex);
		Ellipse(Khdc,x0,y0,x1,y1);
		break;
	}
}

void
mdep_fillpolygon(int *xarr,int *yarr,int arrsize)
{
	int n;
	POINT pts[MAX_POLYGON_POINTS];

	for ( n=0; n<arrsize; n++ ) {
		pts[n].x = xarr[n];
		pts[n].y = yarr[n];
	}
	switch(Plotmode){
	case P_CLEAR:
		setfgpen(Bgindex);
		setbgbrush();
		Polygon(Khdc,pts,arrsize);
		setfgbrush();
		break;
	case P_STORE:
		setfgbrush();
		setfgpen(Fgindex);
		Polygon(Khdc,pts,arrsize);
		break;
	}
}

Pbitmap
mdep_allocbitmap(int xsize,int ysize)
{
	Pbitmap pb;
	Mbitmap *mbptr;

/* xsize+=1; ysize+=1; */
	pb.xsize = pb.origx = xsize;
	pb.ysize = pb.origy = ysize;
	mbptr = (Mbitmap*) kmalloc(sizeof(Mbitmap),"mdep_bitmap");
	if ( mbptr == NULL )
		eprint("Unable to alloc bitmap - impending doom...");
	mbptr->hBitmap = CreateCompatibleBitmap (Khdc,xsize,ysize);
	pb.ptr = (char*)mbptr;
	return pb;
}

Pbitmap
mdep_reallocbitmap(int xsize,int ysize,Pbitmap pb)
{
	Mbitmap *mbptr = (Mbitmap*)pb.ptr;
/* xsize+=1; ysize+=1; */
	if ( mbptr )
		DeleteObject(mbptr->hBitmap);
	mdep_freebitmap(pb);
	return mdep_allocbitmap(xsize,ysize);

}

void
mdep_freebitmap(Pbitmap pb)
{
	Mbitmap *mbptr = (Mbitmap*)pb.ptr;
	if ( mbptr ) {
		DeleteObject(mbptr->hBitmap);
		kfree((char*)mbptr);
	}
}

void
mdep_movebitmap(int fromx0,int fromy0,int width,int height,int tox0,int toy0)
{
	BitBlt(Khdc,tox0,toy0,width,height,Khdc,fromx0,fromy0,SRCCOPY);
}

void
mdep_pullbitmap(int x0,int y0,Pbitmap pb)
{
	Mbitmap *mbptr = (Mbitmap*)pb.ptr;
	HBITMAP old;
	HDC hdcMem;

	hdcMem = CreateCompatibleDC(Khdc);
	old = SelectObject(hdcMem, mbptr->hBitmap);
	BitBlt(hdcMem,0,0,pb.xsize,pb.ysize,Khdc,x0,y0,SRCCOPY);
	SelectObject(hdcMem,old);
	DeleteDC(hdcMem);
}

void
mdep_putbitmap(int x0,int y0,Pbitmap pb)
{
	Mbitmap *mbptr = (Mbitmap*)pb.ptr;
	HBITMAP old;
	HDC hdcMem;

	hdcMem = CreateCompatibleDC(Khdc);
	old = SelectObject(hdcMem, mbptr->hBitmap);
	BitBlt(Khdc,x0,y0,pb.xsize,pb.ysize,hdcMem,0,0,SRCCOPY);
	SelectObject(hdcMem,old);
	DeleteDC(hdcMem);
}

/* Gets current state of mouse, always returns immediately.  */
int
mdep_mouse(int *ax,int *ay, int *am)
{
	if ( ax )
		*ax = Msx;
	if ( ay )
		*ay = Msy;
	if ( am )
		*am = Msm;
	return Msb;
}

int
mdep_mousewarp(int x, int y)
{
	POINT p;

	p.x = 0;
	p.y = 0;
	if ( ClientToScreen(Khwnd,&p) == FALSE )
		return 0;
	x += p.x;
	y += p.y;
	return ( SetCursorPos(x,y) == TRUE );
}

void
mdep_color(int n)
{
	Fgindex = n;
	if ( Plotmode == P_STORE ) {
		setfgpen(Fgindex);
		SetTextColor(Khdc,Rgbvals[Fgindex]);
	}
	else if ( Plotmode == P_CLEAR ) {
		setfgpen(Bgindex);
		SetTextColor(Khdc,Rgbvals[Bgindex]);
	}
	else {	/* P_XOR */
		setfgpen(Fgindex);
		if ( Inverted )
			SetROP2(Khdc,R2_XORPEN);
		else
			SetROP2(Khdc,R2_MERGEPENNOT);
		SetROP2(Khdc,R2_NOT);
		SetTextColor(Khdc,Rgbvals[Fgindex]);
	}
}

void
mdep_colormix(int n,int r,int g,int b)
{
	setuprgb(n,r/256,g/256,b/256);
}

void
mdep_sync(void)
{
	GdiFlush();
}

char *
mdep_fontinit(char *fnt)
{
	SelectObject (Khdc, GetStockObject (SYSTEM_FIXED_FONT)) ;
	return((char*)NULL);
}

int
mdep_fontheight(void)
{
	if ( Fontht < 0 )
		getfontinfo();
	return Fontht;
}

int
mdep_fontwidth(void)
{
	if ( Fontwd < 0 )
		getfontinfo();
	return Fontwd;
}

void
mdep_string(int x, int y, char *s)
{
	if ( Plotmode == P_XOR )
		eprint("P_XOR mode doesn't work in mdep_string!!");
	SetBkMode(Khdc,TRANSPARENT);
	/* SetTextColor(Khdc,Rgbvals[Fgindex]); */
	TextOut(Khdc,x,y,s,(int)strlen((const char *)s));
}

static struct cinfo {
	int type;
	LPCSTR idc;
	char *name;
	HCURSOR curs;
} Clist[] = {
	M_ARROW,	IDC_ARROW,	"arrow", 0,
	M_CROSS,	IDC_CROSS,	"cross", 0,
	M_SWEEP,	0,		"sweep", 0,
	M_LEFTRIGHT,	IDC_SIZEWE,	"leftrigh", 0,
	M_UPDOWN,	IDC_SIZENS,	"updown", 0,
	M_ANYWHERE,	IDC_SIZEALL,	"anywhere", 0,
	M_BUSY,		IDC_WAIT,	"busy", 0,
	M_NOTHING,	0,	"nothing", 0,
	-1, 		0, 		"", 0
};

void
mdep_setcursor(int type)
{
	static int first = 1;
	int n;

	if ( first ) {
		first = 0;
		for ( n=0; Clist[n].type >= 0; n++ ) {
			if ( Clist[n].idc == 0 )
				Clist[n].curs = LoadCursor (Khinstance, Clist[n].name);
			else
				Clist[n].curs = LoadCursor (NULL, Clist[n].idc);

			if ( Clist[n].curs == NULL )
				eprint("Unable to load cursor - name=%s",Clist[n].name);
		}
	}
	for ( n=0; Clist[n].type >= 0; n++ ) {
		if ( type == Clist[n].type ) {
			SetCursor(Kcursor=Clist[n].curs);
			return;
		}
	}
	SetCursor(Kcursor=Clist[0].curs);	/* defaults to arrow */
}

static void
freecursors(void)
{
	int n;
	for ( n=0; Clist[n].type >= 0; n++ ) {
		if ( Clist[n].idc == 0 )
			DestroyCursor(Clist[n].curs);
	}
}

static void
setfgpen(int ci)
{
	if ( Khdc == NULL || hPen[ci] == NULL )
		eprint("Hey, Khdc or hPen is NULL in setfgpen!?");
	if ( SelectObject(Khdc,hPen[ci]) == NULL )
		eprint("Unable to select pen in setfgpen!?");
}

static int currbrushindex = -1;

static void
setfgbrush(void)
{
	int ci = Fgindex;
	if ( ci == currbrushindex )
		return;
	currbrushindex = ci;
	if ( SelectObject(Khdc,hBrush[ci]) == NULL )
		eprint("Unable to select brush in setfgbrush!?");
}

static void
setbgbrush(void)
{
	int ci = Bgindex;
	if ( ci == currbrushindex )
		return;
	currbrushindex = ci;
	if ( SelectObject(Khdc,hBrush[ci]) == NULL )
		eprint("Unable to select brush in setbgbrush!?");
}

static void
setuprgb(int n,int r,int g,int b)
{
	Rgbvals[n] = (COLORREF) RGB(r,g,b);
	recreatepenbrush(n);
}

static void
deletepensandbrushes(void)
{
	int n;
	for ( n=0; n<KEYNCOLORS; n++ ) {
		DeleteObject(hPen[n]);
		DeleteObject(hBrush[n]);
	}
}

static void
recreatepenbrush(int n)
{
	HBRUSH hb;

	if ( hPen[n] )
		DeleteObject(hPen[n]);
	hPen[n] = CreatePen(PS_SOLID,0,Rgbvals[n]);
	if ( hPen[n] == NULL )
		eprint("Unable to CreatePen for n=%d",n);

	if ( hBrush[n] )
		DeleteObject(hBrush[n]);

	/* for some reason, the brushes I'm getting are dithered, so */
	/* I just hardcode these in order to get them right. */
	switch(n) {
	case 3:
		hb = GetStockObject(Inverted?DKGRAY_BRUSH:LTGRAY_BRUSH);
		break;
	case 4:
		hb = GetStockObject(Inverted?LTGRAY_BRUSH:DKGRAY_BRUSH);
		break;
	default:
		hb = CreateSolidBrush(Rgbvals[n]);
		break;
	}
	hBrush[n] = hb;
	if ( hBrush[n] == NULL )
		eprint("Unable to CreateSolidBrush for n=%d",n);
}

static void
createpensandbrushes()
{
	int n;
	for ( n=0; n<KEYNCOLORS; n++ )
		recreatepenbrush(n);
}

static void
createlogpal(void)
{
	int iRasterCaps;

	iRasterCaps = GetDeviceCaps(Khdc, RASTERCAPS);
	iRasterCaps = (iRasterCaps & RC_PALETTE) ? TRUE : FALSE;

	if (iRasterCaps)
		Palettesize = GetDeviceCaps(Khdc, SIZEPALETTE);
	else
		Palettesize = GetDeviceCaps(Khdc, NUMCOLORS);
}

static void
setpalette(void)
{
	if ( Khdc == NULL ) {
		eprint("Khdc==NULL in setpalette!");
		return;
	}
	if ( SelectPalette(Khdc,Hpal,1) == NULL ) {
		eprint("Unable to SelectPalette!");
		return;
	}
	if ( RealizePalette(Khdc) == GDI_ERROR )
		eprint("Unable to RealizePalette!");
}

#ifdef WINSOCK

static char *
nameofsock(SOCKET sock)
{
	PORTHANDLE mp;
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

	makeroom((long)strlen(fmt)+64,&Msg2,&Msg2size);

	va_start(args,fmt);
	vsprintf(Msg2,fmt,args);
	va_end(args);

	name = nameofsock(sock);
	if ( name ) {
		tprint("Winsock - %s - err=%d sockname=%s\n",
			Msg2,WSAGetLastError(),name);
	}
	else {
		tprint("Winsock - %s - err=%d\n", Msg2,WSAGetLastError());
	}
}

static SOCKET
tcpip_listen(char *hostname, char *servname)
{
	SOCKADDR_IN local_sin; /* Local socket */
	PHOSTENT phe;  /* to get IP address */
	SOCKET sock;
	PSERVENT pse;
	int r, i;

	if ( NoWinsock )
		return INVALID_SOCKET;

	if ( servname==0 || *servname == 0 )
		return INVALID_SOCKET;
	if ( hostname==0 || *hostname == 0 )
		return INVALID_SOCKET;

	sock = socket( AF_INET, SOCK_STREAM, 0);
	if (sock == INVALID_SOCKET) {
		sockerror(sock,"socket() failed in tcpip_listen()");
		return INVALID_SOCKET;
	}

	local_sin.sin_family = AF_INET;
	if ( isdigit(*servname) ) {
		local_sin.sin_port = htons((u_short)atoi(servname));
	}
	else {
		pse = getservbyname(servname, "tcp");
		if (pse == NULL) {
			sockerror(sock,"getservbyname(%s) failed",servname);
			return INVALID_SOCKET;
		}
		local_sin.sin_port = pse->s_port;
	}
	for ( i=0; i<8; i++ )
			local_sin.sin_zero[i] = 0;

	if ( isdigit(*hostname) ) {

		unsigned long addr;

		addr = inet_addr(hostname);
		local_sin.sin_addr.s_addr = addr;

#ifdef OLDSTUFF
		phe = gethostbyaddr((const char *)(&addr),4,PF_INET);
		if ( phe == NULL ) {
			sockerror(sock,"gethostbyaddr() failed");
			return INVALID_SOCKET;
		}
		memcpy((struct sockaddr FAR *) &local_sin.sin_addr,
			*(char **)phe->h_addr_list, phe->h_length);
#endif
	}
	else {
		phe = gethostbyname(hostname);
		if (phe == NULL) {
			sockerror(sock,"gethostbyname() failed");
			return INVALID_SOCKET;
		}
		memcpy((struct sockaddr FAR *) &local_sin.sin_addr,
			*(char **)phe->h_addr_list, phe->h_length);
	}

  	if (bind( sock, (struct sockaddr FAR *) &local_sin, sizeof(local_sin)) == SOCKET_ERROR) {
		sockerror(sock,"bind() failed");
		return INVALID_SOCKET;
	}

	r = WSAAsyncSelect(sock,Khwnd,WM_KEY_SOCKET,
			FD_CONNECT|FD_OOB|FD_ACCEPT|FD_READ|FD_WRITE|FD_CLOSE);
	if ( r == SOCKET_ERROR ) {
		sockerror(sock,"WSAAsyncSelect() failed");
		return INVALID_SOCKET;
	}

	if ( listen( sock, 4) < 0) {
		WSAAsyncSelect(sock,Khwnd,0,0);
		sockerror(sock,"listen() failed");
		return INVALID_SOCKET;
	}
	return sock;
}

static SOCKET
tcpip_connect(char *name, char *servname)
{
	SOCKADDR_IN dest_sin;  /* DESTination Socket INternet */
	PHOSTENT phe;
	PSERVENT pse;
	SOCKET sock;
	int r, i;

	if ( NoWinsock )
		return INVALID_SOCKET;

	/* See if the we know about the host (phe = Pointer Host Entity)*/

	phe = gethostbyname(name);
	if (phe == NULL) {
		eprint("Unknown host name: %s",name);
		return INVALID_SOCKET;
	}

	/* THERE IS A BUG (well, to be kind, a difference) IN THE MS TCP/IP */
	/* FOR WFW 3.11!!  The static area pointed to by gethostbyname() is */
	/* overwritten by the getservbyname() call !!!!  Must use it right away.*/ 

	/* Make up Destination Socket */
	dest_sin.sin_family = AF_INET;
	memcpy((struct sockaddr FAR *) &dest_sin.sin_addr,
			*(char **)phe->h_addr_list, phe->h_length);

	/* Get the port # (pse - Pointer to Server Entity)*/
	if ( isdigit(*servname) ) {
		dest_sin.sin_port = htons((u_short)atoi(servname));
	}
	else {
		pse = getservbyname(servname, "tcp");
		if (pse == NULL) {
			sockerror(INVALID_SOCKET,"getservbyname(%s,\"tcp\") failed!",
				servname);
			return INVALID_SOCKET;
		}
		dest_sin.sin_port = pse->s_port;
	}
	for ( i=0; i<8; i++ )
		dest_sin.sin_zero[i] = 0;

	sock = socket( AF_INET, SOCK_STREAM, 0);
	if (sock == INVALID_SOCKET) {
		sockerror(sock,"socket() failed");
		return INVALID_SOCKET;
	}

	r = WSAAsyncSelect(sock,Khwnd,WM_KEY_SOCKET,
			FD_CONNECT|FD_OOB|FD_ACCEPT|FD_READ|FD_WRITE|FD_CLOSE);
	if ( r == SOCKET_ERROR ) {
		sockerror(sock,"WSAAsyncSelect() failed");
		return INVALID_SOCKET;
	}

	r = connect( sock, (PSOCKADDR) &dest_sin, sizeof( dest_sin));
	if ( r == SOCKET_ERROR && WSAGetLastError() != WSAEWOULDBLOCK ) {
		sockerror(sock,"connect() failed");
		return INVALID_SOCKET;
	}
	return sock;
}

#define SOCKSENDLIMIT 64

static int
tcpip_send(PORTHANDLE mp,char *msg,int msgsize)
{
	SOCKET sock = mp->sock;
	Myport *m2;
	int r;

	if ( NoWinsock )
		return INVALID_SOCKET;

	if (mp->buff != NULL) {
		/* if there's something already socked away, we don't want */
		/* to get ahead of it. */
		sockaway(mp,msg,msgsize);
		sendsockedaway(mp);
		return 0;
	}
	while ( msgsize > 0 ) {
		int cnt = msgsize;
		if ( cnt > SOCKSENDLIMIT )
			cnt = SOCKSENDLIMIT;
		r = send(sock,msg,cnt,0);
		if ( r == SOCKET_ERROR ) {
			int err = WSAGetLastError();
			if ( err == WSAEWOULDBLOCK ) {
				sockaway(mp,msg,msgsize);	/* for when FD_WRITE comes */
				return 0;
			}

			if ( err == WSAENOTCONN ) {
				char *nm = nameofsock(sock);
				eprint("Unable to connect to '%s'",
					nm?nm:"???");
			}
			else {
				sockerror(sock,"Error sending to socket, err=%d",err);
			}
			mp->sockstate = SOCK_REFUSED;
			/*
			 * Make sure the same state is set on the
			 * other (read) fifo.
			 */
			for ( m2=Topport; m2!=NULL; m2=m2->next ) {
				if ( m2 != mp && m2->sock == sock ) {
					m2->sockstate = SOCK_REFUSED;
				}
			}
			return 1;
		}
		msg += cnt;
		msgsize -= cnt;
	}
	return 0;
}

static int
tcpip_recv(SOCKET sock,char *buff, int buffsize)
{
	int r;

	if ( NoWinsock )
		return INVALID_SOCKET;

	r = recv(sock,buff,buffsize,0);
	if ( r==0 )
		return 0;	/* socket has closed, perhaps we should eof? */
	if ( r == SOCKET_ERROR && WSAGetLastError() == WSAEWOULDBLOCK )
		return 0;
	if ( r == SOCKET_ERROR ) {
		sockerror(sock,"tcpip_recv() failed");
		return 0;
	}
	return r;
}

/*
 * tcpip_close should work for both tcp and ucp.
 */
static int
tcpip_close(SOCKET sock)
{
	if ( NoWinsock )
		return 1;

	if ( closesocket(sock) ) {
		sockerror(sock,"closesocket() failed");
		return 1;
	}
	return 0;
}

static SOCKET
udp_listen(char *hostname, char *servname)
{
	SOCKADDR_IN local_sin; /* Local socket */
	PHOSTENT phe;  /* to get IP address */
	SOCKET sock;
	PSERVENT pse;
	int r, i;

	if ( NoWinsock )
		return INVALID_SOCKET;

	if ( servname==0 || *servname == 0 )
		return INVALID_SOCKET;
	if ( hostname==0 || *hostname == 0 )
		return INVALID_SOCKET;

	sock = socket( PF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (sock == INVALID_SOCKET) {
		sockerror(sock,"socket() failed in tcpip_listen()");
		return INVALID_SOCKET;
	}

	local_sin.sin_family = PF_INET;
	if ( isdigit(*servname) ) {
		local_sin.sin_port = htons((u_short)atoi(servname));
	}
	else {
		pse = getservbyname(servname, "udp");
		if (pse == NULL) {
			sockerror(sock,"getservbyname(%s) failed",servname);
			return INVALID_SOCKET;
		}
		local_sin.sin_port = pse->s_port;
	}
	for ( i=0; i<8; i++ )
			local_sin.sin_zero[i] = 0;

	if ( isdigit(*hostname) ) {

		unsigned long addr;

		addr = inet_addr(hostname);
		local_sin.sin_addr.s_addr = addr;

#ifdef OLDSTUFF
		phe = gethostbyaddr((const char *)(&addr),4,PF_INET);
		if ( phe == NULL ) {
			sockerror(sock,"gethostbyaddr() failed");
			return INVALID_SOCKET;
		}
		memcpy((struct sockaddr FAR *) &local_sin.sin_addr,
			*(char **)phe->h_addr_list, phe->h_length);
#endif
	}
	else {
		phe = gethostbyname(hostname);
		if (phe == NULL) {
			sockerror(sock,"gethostbyname() failed");
			return INVALID_SOCKET;
		}
		memcpy((struct sockaddr FAR *) &local_sin.sin_addr,
			*(char **)phe->h_addr_list, phe->h_length);
	}

  	if (bind( sock, (struct sockaddr FAR *) &local_sin, sizeof(local_sin)) == SOCKET_ERROR) {
		sockerror(sock,"bind() failed");
		return INVALID_SOCKET;
	}

	r = WSAAsyncSelect(sock,Khwnd,WM_KEY_SOCKET,
			FD_CONNECT|FD_OOB|FD_ACCEPT|FD_READ|FD_WRITE|FD_CLOSE);
	if ( r == SOCKET_ERROR ) {
		sockerror(sock,"WSAAsyncSelect() failed");
		return INVALID_SOCKET;
	}

	return sock;
}

static SOCKET
udp_connect(char *name, char *servname, SOCKADDR_IN * pdest_sin)
{
	PHOSTENT phe;
	PSERVENT pse;
	SOCKET sock;
	int i;

	if ( NoWinsock )
		return INVALID_SOCKET;

	/* See if the we know about the host (phe = Pointer Host Entity)*/

	// keyerrfile("udp_connect start, name=%s servname=%s\n",name,servname);
	phe = gethostbyname(name);
	if (phe == NULL) {
		eprint("Unknown host name: %s",name);
		return INVALID_SOCKET;
	}

	/* THERE IS A BUG (well, to be kind, a difference) IN THE MS TCP/IP */
	/* FOR WFW 3.11!!  The static area pointed to by gethostbyname() is */
	/* overwritten by the getservbyname() call !!!!  Must use it right away.*/ 

	/* Make up Destination Socket */
	pdest_sin->sin_family = PF_INET;
	memcpy((struct sockaddr FAR *) &(pdest_sin->sin_addr),
			*(char **)phe->h_addr_list, phe->h_length);

	/* Get the port # (pse - Pointer to Server Entity)*/
	if ( isdigit(*servname) ) {
		pdest_sin->sin_port = htons((u_short)atoi(servname));
	}
	else {
		pse = getservbyname(servname, "udp");
		if (pse == NULL) {
			sockerror(INVALID_SOCKET,"getservbyname(\"%s\",\"udp\") failed!",
				servname);
			return INVALID_SOCKET;
		}
		pdest_sin->sin_port = pse->s_port;
	}
	for ( i=0; i<8; i++ )
		pdest_sin->sin_zero[i] = 0;

	sock = socket( PF_INET, SOCK_DGRAM, IPPROTO_UDP);
	// keyerrfile("udp_connect socket=%ld\n",(long)sock);
	if (sock == INVALID_SOCKET) {
		sockerror(sock,"socket() failed");
		return INVALID_SOCKET;
	}

#if 0
	r = WSAAsyncSelect(sock,Khwnd,WM_KEY_SOCKET,
			FD_CONNECT|FD_OOB|FD_ACCEPT|FD_READ|FD_WRITE|FD_CLOSE);
	if ( r == SOCKET_ERROR ) {
		sockerror(sock,"WSAAsyncSelect() failed");
		return INVALID_SOCKET;
	}

	r = connect( sock, (PSOCKADDR) pdest_sin, sizeof( SOCKADDR_IN ));
	if ( r == SOCKET_ERROR && WSAGetLastError() != WSAEWOULDBLOCK ) {
		sockerror(sock,"connect() failed");
		return INVALID_SOCKET;
	}
#endif
// keyerrfile("udp_connect, returns sock=%ld\n",(long)sock);
	return sock;
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

static Myport *
newmyport(char *name)
{
	Myport *m;
	m = (Myport *) kmalloc(sizeof(Myport),"newmyport");
	m->name = name;
	m->sock = INVALID_SOCKET;
	m->rw = TYPE_NONE;
	m->sockstate = SOCK_UNCONNECTED;
	m->portstate = PORT_NORMAL;
	m->isopen = 0;
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
#endif

PORTHANDLE *
mdep_openport(char *name, char *mode, char *type)
{
	name = uniqstr(name);
#ifdef WINSOCK
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
		if ( sock == INVALID_SOCKET ) {
			if ( *Debug != 0 )
				eprint("tcpip_connect to p=%s buff=%s fails!?",p,buff);
			return NULL;
		}
/* eprint("tcpip_connect sock=%d\n",sock); */
		m0 = newmyport(name);
		m0->rw = TYPE_READ;
		m0->myport_type = MYPORT_TCPIP_READ;
		m0->isopen = 1;
		m0->closeme = 1;
		m0->sock = sock;
		handle[0] = m0;

		m1 = newmyport(name);
		m1->rw = TYPE_WRITE;
		m1->myport_type = MYPORT_TCPIP_WRITE;
		m1->isopen = 1;
		m1->sock = sock;
		handle[1] = m1;

		return handle;
	}
	if ( strcmp(type,"tcpip_listen") == 0 ) {
		char buff[BUFSIZ];
		char *p;
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
		if ( p == NULL ) {
			eprint("tcpip_listen name must contain a '@' !");
			return NULL;
		}
		*p++ = 0;
		sock = tcpip_listen(p,buff);
		if ( sock == INVALID_SOCKET ) {
			eprint("tcpip_listen to name=%s fails!?",name);
			return NULL;
		}
		m0 = newmyport(name);
		m0->rw = TYPE_LISTEN;
		m0->myport_type = MYPORT_TCPIP_LISTEN;
		m0->isopen = 1;
		m0->closeme = 1;
		m0->sock = sock;
		m0->sockstate = SOCK_LISTENING;
		handle[0] = m0;

		handle[1] = (PORTHANDLE)0;

		return handle;
	}
	if ( strcmp(type,"udp_send") == 0 ) {
		char buff[BUFSIZ];
		char *p;
		SOCKET sock;
		SOCKADDR_IN dest_sin;

		// keyerrfile("udp_connect mode=(%s)\n",mode);
		strcpy(buff,name);
		p = strchr(buff,'@');
		if ( p == NULL ) {
			eprint("udp_connect name must contain a '@' !");
			return NULL;
		}
		if ( strchr(mode,'w') == NULL ) {
			eprint("mode on udp_connect must contain a 'w' !");
			return NULL;
		}
		if ( strchr(mode,'r') != NULL ) {
			eprint("mode on udp_connect can't contain a 'r' !");
			return NULL;
		}
		*p++ = 0;
		sock = udp_connect(p,buff,&dest_sin);
		// keyerrfile("udp_connect sock=(%ld)\n",sock);
		if ( sock == INVALID_SOCKET ) {
			if ( *Debug != 0 )
				eprint("udp_connect to p=%s buff=%s fails!?",p,buff);
			return NULL;
		}
		handle[0] = (PORTHANDLE)0;

		m1 = newmyport(name);
		m1->rw = TYPE_WRITE;
		m1->myport_type = MYPORT_UDP_WRITE;
		m1->isopen = 1;
		m1->closeme = 1;
		m1->sock = sock;
		m1->sockaddr = dest_sin;
		m1->sockstate = SOCK_CONNECTED;
		handle[1] = m1;

		// keyerrfile("udp_connect returns handle\n");

		return handle;
	}
	if ( strcmp(type,"udp_listen") == 0 ) {
		char buff[BUFSIZ];
		char *p;
		SOCKET sock;

		if ( strchr(mode,'w') != NULL ) {
			eprint("mode on udp_listen can't contain a 'w' !");
			return NULL;
		}
		strcpy(buff,name);
		p = strchr(buff,'@');
		if ( p == NULL ) {
			eprint("udp_listen name must contain a '@' !");
			return NULL;
		}
		*p++ = 0;
		sock = udp_listen(p,buff);
		if ( sock == INVALID_SOCKET ) {
			eprint("udp_listen to name=%s fails!?",name);
			return NULL;
		}
		// keyerrfile("udp_listen returned sock=%ld\n",(long)sock);
		m0 = newmyport(name);
		m0->rw = TYPE_LISTEN;
		m0->myport_type = MYPORT_UDP_LISTEN;
		m0->isopen = 1;
		m0->closeme = 1;
		m0->sock = sock;
		m0->sockstate = SOCK_LISTENING;
		handle[0] = m0;

		handle[1] = (PORTHANDLE)0;

		return handle;
	}
	if ( strcmp(type,"osc_send") == 0 ) {
		char buff[BUFSIZ];
		char *p;
		SOCKET sock;
		SOCKADDR_IN dest_sin;

		// keyerrfile("osc_send mode=(%s)\n",mode);
		strcpy(buff,name);
		p = strchr(buff,'@');
		if ( p == NULL ) {
			eprint("osc_send name must contain a '@' !");
			return NULL;
		}
		if ( strchr(mode,'w') == NULL ) {
			eprint("mode on osc_send must contain a 'w' !");
			return NULL;
		}
		if ( strchr(mode,'r') != NULL ) {
			eprint("mode on osc_send can't contain a 'r' !");
			return NULL;
		}
		*p++ = 0;
		sock = udp_connect(p,buff,&dest_sin);
		// keyerrfile("osc_send sock=(%ld)\n",sock);
		if ( sock == INVALID_SOCKET ) {
			if ( *Debug != 0 )
				eprint("osc_send to p=%s buff=%s fails!?",p,buff);
			return NULL;
		}
		handle[0] = (PORTHANDLE)0;

		m1 = newmyport(name);
		m1->rw = TYPE_WRITE;
		m1->myport_type = MYPORT_OSC_WRITE;
		m1->isopen = 1;
		m1->closeme = 1;
		m1->sock = sock;
		m1->sockaddr = dest_sin;
		m1->sockstate = SOCK_CONNECTED;
		handle[1] = m1;

		// keyerrfile("osc_send returns handle\n");

		return handle;
	}
	if ( strcmp(type,"osc_listen") == 0 ) {
		char buff[BUFSIZ];
		char *p;
		SOCKET sock;

		if ( strchr(mode,'w') != NULL ) {
			eprint("mode on osc_listen can't contain a 'w' !");
			return NULL;
		}
		if ( strchr(mode,'A') == NULL ) {
			eprint("mode on osc_listen must contain an 'A' !");
			return NULL;
		}
		strcpy(buff,name);
		p = strchr(buff,'@');
		if ( p == NULL ) {
			eprint("osc_listen name must contain a '@' !");
			return NULL;
		}
		*p++ = 0;
		sock = udp_listen(p,buff);
		if ( sock == INVALID_SOCKET ) {
			eprint("osc_listen to name=%s fails!?",name);
			return NULL;
		}
		// keyerrfile("osc_listen returned sock=%ld\n",(long)sock);
		m0 = newmyport(name);
		m0->rw = TYPE_LISTEN;
		m0->myport_type = MYPORT_OSC_LISTEN;
		m0->isopen = 1;
		m0->closeme = 1;
		m0->sock = sock;
		m0->sockstate = SOCK_LISTENING;
		handle[0] = m0;

		handle[1] = (PORTHANDLE)0;

		return handle;
	}
    }
#endif

    {
	static PORTHANDLE handle[2];
	PORTHANDLE m0;

	if ( strcmp(type,"joystick") == 0 ) {

		if ( strchr(mode,'l') == NULL ) {
			eprint("mode on joystick must contain an 'l' !");
			return NULL;
		}
		m0 = newmyport(name);
		m0->rw = TYPE_LISTEN;
		m0->myport_type = MYPORT_JOYSTICK;
		m0->isopen = 1;
		m0->closeme = 1;
		m0->sock = 0;
		m0->sockstate = 0;
		handle[0] = m0;

		handle[1] = (PORTHANDLE)0;

		return handle;
	}
    }
    eprint("Unknown port type - %s\n",type);
    return NULL;
}

#ifdef WINSOCK
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
sendsockedaway(PORTHANDLE mp)
{
	if (mp->sockstate != SOCK_CONNECTED ) {
		return;
	}
	if (mp->buff != NULL) {
		char *p = mp->buff;
		int sz = mp->buffsize;
		/* important to null it out now, because tcpip_send may result */
		/* in sockaway() being called. */
		mp->buff = NULL;
		mp->buffsize = 0;
		(void) tcpip_send(mp,p,sz);
		kfree(p);
	}
}

#endif

Datum
mdep_ctlport(PORTHANDLE m, char *cmd, char *arg)
{
	if ( strcmp(cmd,"atest1")==0 ) {	/* to see if it's working */
		mdep_popup(cmd);
		mdep_popup(arg);
		return(numdatum(0));
	}
	return Noval;	/* we don't handle any ctl's */
}

int
mdep_putportdata(PORTHANDLE m, char *buff, int size)
{
#ifdef WINSOCK
	int r;

	// tprint("mdep_purportdata buff=%s size=%d sockstat=%d\n",buff,m->sockstate);
	// tprint("    buff[0]=%d buff[1]=%d buff[2]=%d buff[3]=%d\n",(int)buff[0],(int)buff[1],(int)buff[2],(int)buff[3]);
	switch(m->myport_type){
	case MYPORT_OSC_WRITE:
		// keyerrfile("mdep_putportdata MYPORT_OSC_WRITE!\n");
		r = udp_send(m,buff,size);
		break;
	case MYPORT_UDP_WRITE:
		r = udp_send(m,buff,size);
		break;
	default:
		switch (m->sockstate) {
		case SOCK_UNCONNECTED:
			/* for delivery when it connects */
			sockaway(m,buff,size);
			r = size;
			break;
		case SOCK_CLOSED:
		case SOCK_REFUSED:
			r = 0;
			break;
		default:
			r = tcpip_send(m,buff,size);
			break;
		}
	}
	return r;
#else
	return 0;
#endif
}

int
mdep_getportdata(PORTHANDLE *handle, char *buff, int buffsize, Datum *pd)
{
#ifdef WINSOCK
	Myport *m;
	int r;

	for ( m=Topport; m!=NULL; m=m->next ) {

		if ( m->rw == TYPE_READ && m->sockstate == SOCK_CLOSED && m->hasreturnedfinaldata == 0 ) {
			m->hasreturnedfinaldata = 1;
			*handle = m;
			return 0;
		}
		if ( m->rw == TYPE_READ && m->sockstate == SOCK_REFUSED && m->hasreturnedfinaldata == 0 ) {
			m->hasreturnedfinaldata = 1;
			*handle = m;
			return -2;
		}

		if ( ! m->isopen )
			continue;

		if ( m->portstate == PORT_CANREAD ) {

			if ( m->sockstate == SOCK_LISTENING
				&& m->myport_type == MYPORT_OSC_LISTEN ) {

				int cnt = 0;

				while ( cnt++ < 4 ) {
					errno = 0;
					r = udp_recv(m,buff,buffsize);
					if ( ! ( r<0 && WSAGetLastError()==WSAEFAULT ) ) {
						break;
					}
					
				}
				// keyerrfile("udp_recv after loop r=%d, cnt=%d\n",r,cnt);
				if ( r <= 0 ) {
					continue;
				}
				*pd = osc_array(buff,r,0);
			} else if ( m->sockstate == SOCK_LISTENING
				&& m->myport_type == MYPORT_UDP_LISTEN ) {

				// tprint("SHOULD BE READING UDP NOW!\n");
				r = udp_recv(m,buff,buffsize);
				if ( r < 0 ) {
					r = 0;
				}
			} else if ( m->sockstate == SOCK_LISTENING ) {
				PORTHANDLE *php;
				// keyerrfile("getportdata, CANREAD, SOCK_LISTENING\n");
				if ( m->savem0==NULL || m->savem1==NULL ) {
					eprint("Warning - got PORT_CANREAD when savem0/m1==NULL !?");
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
			else {
				r = tcpip_recv(m->sock,buff,buffsize);
			}
			*handle = m;
			m->portstate = PORT_NORMAL;
			return r;
		}
	}
#endif
    {
	Myport *m;

	for ( m=Topport; m!=NULL; m=m->next ) {
		if ( m->myport_type == MYPORT_JOYSTICK ) {
			if ( getjoy() ) {
				*handle = m;
				switch(Joyjt) {
				case K_JOYBUTTON:
					sprintf(buff,"button %d %d %d\n",
						Joyjn,Joybn,Joybv!=0?1:0);
					break;
				case K_JOYANALOG:
					sprintf(buff,"analog %d %c %d\n",
						Joyjn,Joybn,Joybv);
					break;
				}
				return (int)strlen(buff);
			}
		}
	}
    }
	return -1;
}

int
mdep_closeport(PORTHANDLE m)
{
	int r = 0;

#ifdef WINSOCK
	PORTHANDLE prevmp;
	PORTHANDLE mp;

	m->isopen = 0;

	switch (m->myport_type) {
	case MYPORT_TCPIP_READ:
	case MYPORT_TCPIP_WRITE:
	case MYPORT_TCPIP_LISTEN:
	case MYPORT_UDP_WRITE:
	case MYPORT_UDP_LISTEN:
	case MYPORT_OSC_WRITE:
	case MYPORT_OSC_LISTEN:
		if ( m->closeme ) {
			/* works for both tcp and udp */
			r |= tcpip_close(m->sock);
		}
		m->sock = INVALID_SOCKET;
		break;
	default:
		break;
	}
	/* Remove m from Topport list */
	for ( prevmp=NULL,mp=Topport; mp!=NULL; prevmp=mp,mp=mp->next ) {
		if ( mp == m )
			break;
	}
	if ( prevmp == NULL )
		Topport = m->next;
	else
		prevmp->next = m->next;
	kfree(m);
#endif
	return r;
}

int
mdep_help(char *fname,char *keyword)
{
	char buff[256];
	char *hlpfile;

	sprintf(buff,"%s.hlp",fname);
	hlpfile = keyhelp(buff);
	if ( hlpfile == NULL )
		return 1;
	if ( keyword == NULL )
		WinHelp(Khwnd,hlpfile, HELP_CONTENTS, 0L);
	else
		WinHelp(Khwnd,hlpfile, HELP_PARTIALKEY, (long long)keyword);
	return(0);
}

/* BUFSIZE must be big enough to hold all output from netstat */
#define BUFSIZE 4096 
 
static BOOL CreateChildProcess(void); 
static char *ReadFromPipe(HANDLE r, HANDLE w, Datum d); 
 
char *
mdep_localaddresses(Datum d)
{ 
    SECURITY_ATTRIBUTES saAttr; 
	HANDLE hRead, hWrite, hSave; 
 
    /* Set the bInheritHandle flag so pipe handles are inherited. */ 
 
    saAttr.nLength = sizeof(SECURITY_ATTRIBUTES); 
    saAttr.bInheritHandle = TRUE; 
    saAttr.lpSecurityDescriptor = NULL; 
 
    /* 
     * The steps for redirecting child's STDOUT: 
     *     1.  Save current STDOUT, to be restored later. 
     *     2.  Create anonymous pipe to be STDOUT for child. 
     *     3.  Set STDOUT of parent to be write handle of pipe, so 
     *         it is inherited by child. 
     */ 
 
    /* Save the handle to the current STDOUT. */ 
 
    hSave = GetStdHandle(STD_OUTPUT_HANDLE); 
 
    /* Create a pipe for the child's STDOUT. */ 
 
    if (! CreatePipe(&hRead, &hWrite, &saAttr, 0)) 
        return ("Stdout pipe creation failed\n"); 
 
    /* Set a write handle to the pipe to be STDOUT. */ 
 
    if (! SetStdHandle(STD_OUTPUT_HANDLE, hWrite)) 
        return ("Redirecting STDOUT failed"); 
 
    /* Now create the child process. */ 
 
    if ( CreateChildProcess() == FALSE ) { 
        return ("Create process failed"); 
    }
 
    /* After process creation, restore the saved STDOUT. */ 
 
    if (! SetStdHandle(STD_OUTPUT_HANDLE, hSave)) 
        return ("Re-redirecting Stdout failed\n"); 
 
    /* Read from pipe that is the standard output for child process. */ 
 
    return ReadFromPipe(hRead,hWrite,d); 
} 
 
static BOOL
CreateChildProcess()
{ 
    PROCESS_INFORMATION piProcInfo; 
    STARTUPINFO siStartInfo; 
 
    /* Set up members of STARTUPINFO structure. */ 
 
    siStartInfo.cb = sizeof(STARTUPINFO); 
    memset(&siStartInfo,0,sizeof(siStartInfo));
    siStartInfo.lpReserved = NULL; 
    siStartInfo.lpReserved2 = NULL; 
    siStartInfo.cbReserved2 = 0; 
    siStartInfo.lpDesktop = NULL; 
    siStartInfo.dwFlags = STARTF_USESHOWWINDOW; 
	siStartInfo.wShowWindow = SW_HIDE;
 
    /* Create the child process. */ 
 
    return CreateProcess(NULL, 
        "netstat -r",       /* command line                       */ 
        NULL,          /* process security attributes        */ 
        NULL,          /* primary thread security attributes */ 
        TRUE,          /* handles are inherited              */ 
        0,             /* creation flags                     */ 
        NULL,          /* use parent's environment           */ 
        NULL,          /* use parent's current directory     */ 
        &siStartInfo,  /* STARTUPINFO pointer                */ 
        &piProcInfo);  /* receives PROCESS_INFORMATION       */ 
}
 
static char *
ReadFromPipe(HANDLE hRead, HANDLE hWrite, Datum d)
{
    DWORD dwRead;	// DWORD here is okay, I think
    char buff[BUFSIZE]; 
	char word1[BUFSIZ];
	char word3[BUFSIZ];
    HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); 
	int sofar, n;
	char *p;
 
    /* 
     * Close the write end of the pipe before reading from the 
     * read end of the pipe. 
     */ 
 
    if (! CloseHandle(hWrite)) 
        return("Closing handle failed"); 
 
    /* Read output from child, collecting it in buff */
 
	sofar = 0;
    for (;;) { 
        if (! ReadFile(hRead, buff+sofar, BUFSIZE-sofar, &dwRead, NULL) || 
            dwRead == 0) break; 
		sofar += dwRead;
		buff[sofar] = 0;
    } 
	n = 0;
	for ( p=strtok(buff,"\n"); p!=NULL; p=strtok(NULL,"\n") ) {

		/* We want to pull out all the lines for which the */
		/* gateway field is 127.0.0.1.  (except for 127.0.0.0) */

		if ( sscanf(p," %s %*s %s",word1,word3) == 2 ) {
			if ( strcmp(word3,"127.0.0.1") == 0
				&& strcmp(word1,"127.0.0.0") != 0 ) {
				setarraydata(d.u.arr,numdatum(n), strdatum(uniqstr(word1)));
				n++;
			}
		}
	}
	return 0;
} 
 
int
my_ntohl(int v)
{
	return ntohl(v);
}
