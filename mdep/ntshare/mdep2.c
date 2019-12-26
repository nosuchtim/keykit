/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

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
#include "keydll.h"

#define SEPARATOR "\\"
#define PALETTESIZE 256

#ifdef WINSOCK
#define WS_VERSION_REQUIRED 0x0101
#define SOCK_UNCONNECTED 0
#define SOCK_CONNECTED 1
#define SOCK_CLOSED 2
#define SOCK_LISTENING 3

#define PORT_NORMAL 0
#define PORT_CANREAD 1

struct myportinfo {
	char *name;
	char *type;	/* usually "tcpip" */
	SOCKET sock;
	char portstate;
	char sockstate;
	char isopen;
	char closeme;
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


static void sockaway(PORTHANDLE m,char *buff,int size);
static void sendsockedaway(PORTHANDLE mp);

#endif

extern int midishare_hasmidi();

static int Msb = 0;
static int Msx, Msy;
static int Msm = 0;
static int Fontht = -1, Fontwd = -1;
static int Plotmode = -1;
static MSG Kmessage ;
static HDC Firstdc = NULL;
static HDC Khdc = NULL;
static HANDLE Khinstance;
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

void PutInputEvent(long,long,int);

#ifdef WINSOCK
static Myport *newmyport(char *);
static void sockerror(SOCKET,char *,...);
static int tcpip_recv(SOCKET,char *,int);
static int tcpip_send(PORTHANDLE,char *,int);
#endif

void handlemidioutput(long);

void
mdep_popup(char *s)
{
	int n;
	if ( s == NULL )
		s = "Internal error?  NULL given to mdep_popup()?!";
	/* Sometimes there are blank messages, ignore them */
	if ( strcmp(s,"\n")==0 )
		return;
	n = MessageBox(Khwnd, s, "KeyKit", MB_ICONEXCLAMATION | MB_OK);
	if ( n == IDCANCEL )
		cleanexit();
}

#define IDM_ABOUT 100
#define IDM_HELP_TUTORIAL 101
#define IDM_HELP_LANGUAGE 102
#define IDM_HELP_HACKING 103
#define IDM_HELP_TOOLS 104
#define IDM_KEY_ABORT 105

LONG APIENTRY WndProc (HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam);

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
		mdep_popup("Too many events received by savemouse!");
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
		mdep_popup("Hey, getmouseevent called when nothing to get!?");
	else {
		Msx = Keymousex[--Keymousepos];
		Msy = Keymousey[Keymousepos];
		Msb = Keymouseb[Keymousepos];
		Msm = Keymousem[Keymousepos];
	}
}

#define MAXCONSOLE 32
int Keyconsole[MAXCONSOLE];
int Keyconsolepos = 0;

static void
saveconsole(int n)
{
	if ( Keyconsolepos >= MAXCONSOLE )
		mdep_popup("Too many events received by saveconsole!");
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
			mdep_popup("Too many events received by saveevent!");
		}
	}
	else {
		shiftup(Keyevents,Keyeventpos++);
		Keyevents[0] = n;
	}
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

	if ( midishare_hasmidi() ) {
keyerrfile("getkeyevent midishare=K_MIDI\n");
		return K_MIDI;
	}

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

	Khinstance = hInstance;
	if (!hPrevInstance) {
		wndclass.style	       = CS_HREDRAW | CS_VREDRAW;
		/* wndclass.style	       = CS_HREDRAW | CS_VREDRAW | CS_OWNDC ; */
		wndclass.lpfnWndProc   = WndProc ;
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

	fx = GetSystemMetrics(SM_CXFULLSCREEN);
	fy = GetSystemMetrics(SM_CYFULLSCREEN);
	sx = 2*fx/3;
	sy = 2*fy/3;
	if ( sx > 600 )
		sx = 600;
	if ( sy > 440 )
		sy = 440;
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

	Firstdc = GetDC (Khwnd);
	if ( Firstdc == NULL )
		mdep_popup("Unable to get first DC!?");
	Khdc = Firstdc;

	createlogpal();

	ShowWindow (Khwnd, nCmdShow) ;
	UpdateWindow (Khwnd) ;

	hmenu = GetSystemMenu(Khwnd,FALSE);
	AppendMenu(hmenu,MF_SEPARATOR, 0, (LPSTR) NULL);
	AppendMenu(hmenu,MF_STRING, IDM_ABOUT, "About KeyKit...");
	AppendMenu(hmenu,MF_STRING, IDM_HELP_TUTORIAL, "KeyKit Tutorial Help...");
	AppendMenu(hmenu,MF_STRING, IDM_HELP_TOOLS, "KeyKit Tools Help...");
	AppendMenu(hmenu,MF_STRING, IDM_HELP_LANGUAGE, "KeyKit Language Help...");
	AppendMenu(hmenu,MF_STRING, IDM_HELP_HACKING, "KeyKit Hacking Help...");
	AppendMenu(hmenu,MF_SEPARATOR, 0, (LPSTR) NULL);
	AppendMenu(hmenu,MF_STRING, IDM_KEY_ABORT, "Exit, when all else fails...");

	mdep_setcursor(M_ARROW);

	n=0;
	argv[n++] = "key";
	s = strsave(lpszCmdParam); /* afraid to alter lpszCmdParam in-place */
	for ( p=strtok(s," "); p!=NULL; p=strtok(NULL," ") ) {
		argv[n++] = p;
	}
	argv[n] = NULL;
	keymain(n,argv);
	return(0);
}

static BOOL FAR PASCAL
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
		mdep_popup("Hmmm, Fontwd=0 ?  Bad news.");
		Fontwd = 12;
		Fontht = 14;
	}
}

#ifdef WINSOCK
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
	newsock = accept( sock,(struct sockaddr FAR *) &acc_sin,
			 (int FAR *) &acc_sin_len );
	if ( newsock==INVALID_SOCKET ) {
		sockerror(sock,"accept() failed");
		return;
	}
	/* create 2 new fifos for reading/writing new socket */
	prlongto(acc_sin.sin_addr.S_un.S_addr,addrstr);
	name = uniqstr(addrstr);

	m0 = newmyport(name);
	m0->type = "tcpip_read";
	m0->isopen = 1;
	m0->closeme = 1;
	m0->sock = newsock;
	m0->sockstate = SOCK_CONNECTED;

	m1 = newmyport(name);
	m1->type = "tcpip_write";
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
	char *p;
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
			for ( mp=Topport; mp!=NULL; mp=mp->next ) {
				if ( mp->sock == sock && strcmp(mp->type,"tcpip_read")==0 ) {
					mp->portstate = PORT_CANREAD;
				}
			}
			break;
		case FD_WRITE:
/* tprint("FD_WRITE seen!\n"); */
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
/* tprint("FD_CONNECT seen!\n"); */
			nfound = 0;
			for ( mp=Topport; mp!=NULL; mp=mp->next ) {
				if ( mp->sock == sock ) {
					mp->sockstate = SOCK_CONNECTED;
					sendsockedaway(mp);
					nfound++;
				}
			}
			if ( nfound == 0 )
				mdep_popup("FD_CONNECT didn't find sock!?");
			break;
		case FD_OOB:
			break;
		case FD_CLOSE:
			/* remember, there's 2 ports for each socket. */
			nfound = 0;
// tprint("FD_CLOSE seen sock=%d!\n",sock);
			for ( mp=Topport; mp!=NULL; mp=mp->next ) {
				if ( mp->sock == sock ) {
					mp->sockstate = SOCK_CLOSED;
// tprint("Setting mp->sockstate to CLOSED!\n");
					if ( strcmp(mp->type,"tcpip_read")==0) {
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

#ifdef OLDERSTUFF
	case MM_MOM_OPEN:
		return 0;
	case MM_MOM_CLOSE:
		return 0;
	case MM_MOM_DONE:
		handlemidioutput( (long) lParam );
		return 0;
	case MM_MIM_OPEN:
		return 0;
	case MM_MIM_CLOSE:
		return 0;
	case MM_MIM_DATA:
		/* ignore active sensing */
/* keyerrfile("MM_MIM_DATA lParam=0x%lx wParam=0x%lx  tm=%ld\n",(long)lParam,(long)wParam,mdep_milliclock()); */
		if ( LOBYTE(LOWORD(lParam)) == (BYTE) 0xfe )
			return 0;
/* keyerrfile("MM_MIM_DATA NON-ACTIVE !\n"); */
		PutInputEvent(lParam,wParam,0);
		saveevent(K_MIDI);
		return 0;
	case MM_MIM_LONGDATA:
		/* mdep_popup("WndProc got MM_MIM_LONGDATA!"); */

		/* The debug stuff here was for when I was trying to get */
		/* LONG midi data working under Win32s (unsuccessfully). */
#ifdef OLDSTUFF
		sprintf(Msg1,"MM_MIM_LONGDATA lParam=0x%lx wParam=0x%lx\n",
			(long)lParam,(long)wParam);
		keyerrfile(Msg1);
#endif
		{
		char *b;
		LPMIDIHDR lpMidi = (LPMIDIHDR)lParam;
		b = lpMidi->lpData;
#ifdef OLDSTUFF
		keyerrfile("lpMidi.lpData=0x%x  b[0]=0x%x b[1]=0x%x\n",lpMidi->lpData,(int)b[0],(int)b[1]);
		keyerrfile("lpMidi.dwBufferLength=0x%x\n",lpMidi->dwBufferLength);
		keyerrfile("lpMidi.dwFlags=0x%x\n",lpMidi->dwFlags);
		keyerrfile("lpMidi.dwBytesRecorded=0x%lx\n",lpMidi->dwBytesRecorded);
		keyerrfile("lpMidi.dwUser=0x%x\n",lpMidi->dwUser);
#endif
		}
		PutInputEvent(lParam,wParam,1);
		saveevent(K_MIDI);
#ifdef OLDSTUFF
		tprint("(Saved K_MIDI event for MIM_LONGDATA)");
#endif
		return 0;
	case MM_MIM_ERROR:
		if ( Debugmidi!=NULL && *Debug != 0 )
			mdep_popup("WndProc got MM_MIM_ERROR!");
		return 0;
	case MM_MIM_LONGERROR:
		if ( Debugmidi!=NULL && *Debug != 0 )
			mdep_popup("WndProc got MM_MIM_LONGERROR!");
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
		Lasttimeout = lParam;
		return 0;
	case WM_KEY_ERROR:
		return 0;
#ifdef OLDERSTUFF
	case WM_KEY_MIDIINPUT:
		saveevent(K_MIDI);
		return 0;
	case WM_KEY_MIDIOUTPUT:
		handlemidioutput( (long) lParam );
		return 0;
#endif
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
			FARPROC lpfnDlgProc = 
				MakeProcInstance (AboutDlgProc, Khinstance);
			DialogBox(Khinstance, "AboutBox", Khwnd, lpfnDlgProc);
			FreeProcInstance(lpfnDlgProc);
			}
			return 0;
		case IDM_HELP_TUTORIAL:
			p = keyhelp("tutorial.hlp");
			goto gethelp;
			/* NOT REACHED */
		case IDM_HELP_LANGUAGE:
			p = keyhelp("language.hlp");
			goto gethelp;
			/* NOT REACHED */
		case IDM_HELP_TOOLS:
			p = keyhelp("tools.hlp");
			goto gethelp;
			/* NOT REACHED */
		case IDM_HELP_HACKING:
			p = keyhelp("hacking.hlp");
		gethelp:
			if ( p )
				WinHelp(Khwnd,p, HELP_CONTENTS, 0L);
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
			saveconsole(wParam-112+FKEYOFFSET);
			saveevent(K_CONSOLE);
			return 0;
		}
		break;
	case WM_CHAR:
		if ( (int)wParam == 3 && Intrfunc != NULL ) {
			(*Intrfunc)(SIGINT);
		}
		else {
			/* a normal character */
			saveconsole(wParam);
			saveevent(K_CONSOLE);
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
		/* if ( ! ispendingevent(K_WINDRESIZE) && ! ispendingevent(K_WINDEXPOSE) ) { */
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

	}

	return DefWindowProc (hwnd, message, wParam, lParam) ;
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

	if ( SearchPath(NULL,cmd,".exe",BUFSIZ,buff,&pfile) == 0 ) {

		/* The LAST resort is KEYROOT, not first.  That way */
		/* if we happen to execute some other version, */
		/* a mis-set KEYROOT won't screw us up. */

		if ( (p=getenv("KEYROOT")) != NULL && *p != '\0' )
			root = uniqstr(p);
		else {
			/* Last last resorts is ".." */
			if ( exists("../lib/keyrc.k") )
				root = uniqstr("..");
			else if ( exists("c:\\key\\lib\\keyrc.k") )
				root = uniqstr("c:\\key");
			else {
				eprint("KEYROOT not set!  Last resort - trying '..'");
				root = uniqstr("..");
			}
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
		mdep_popup(p);
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
#ifdef OLDSTUFF
		sprintf(Msg1,"Warning, no RC_PALETTE capability?  Setting Colors to %ld!",*Colors);
		mdep_popup(Msg1);
#endif
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
		mdep_colormix(3, 200*n, 200*n, 200*n);	/* light grey */
		mdep_colormix(4, 100*n, 100*n, 100*n);	/* dark grey */
	}
	else {
		Inverted = 0;
		mdep_colormix(0, 255*n, 255*n, 255*n);	/* white */
		mdep_colormix(1, 0, 0, 0 );		/* black */
		mdep_colormix(2, 255*n, 0, 0	);	/* red, for Pickcolor */
		mdep_colormix(3, 200*n, 200*n, 200*n);	/* light grey */
		mdep_colormix(4, 100*n, 100*n, 100*n);	/* dark grey */
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
	sprintf(p,".%s%s%smusic",PATHSEP,keyroot(),SEPARATOR);
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
	if ( PeekMessage (&Kmessage, NULL, 0, 0,PM_REMOVE) == FALSE )
		return FALSE;
	TranslateMessage (&Kmessage) ;
	DispatchMessage (&Kmessage) ;
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
		(LPTIMECALLBACK)KeyTimerFunc, (DWORD)0, TIME_ONESHOT);
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
				mdep_popup(buf);
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
			/* Usually, we quit because WM_DESTROY has done a */
			/* saveevent(K_QUIT), but just in case, we check */
			/* the return value of GetMessage anyway. */
			if ( GetMessage (&Kmessage, NULL, 0, 0) == FALSE ) {
				return K_QUIT;
			}

			TranslateMessage (&Kmessage) ;
			DispatchMessage (&Kmessage) ;
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
		mdep_popup(buff);
#endif
	}
	if ( timeBeginPeriod((UINT)(*Millires)) )
		mdep_popup("timeBeginPeriod fails!?");

	if ( KeySetupDll(Khwnd) ) {
		mdep_popup("KeySetupDll fail!?");
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
		if ( GetComputerName(myname,&dwSize) == FALSE ) {
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
		/* EnumIP(); */
	}
    getout:
#endif
	return(0);
}

#ifdef OLDSTUFF
void
EnumIP()
{
      char     szHostname[100];
      HOSTENT *pHostEnt;
      int      nAdapter = 0;

	keyerrfile("EnumIP myhostname=%s\n",Myhostname);
      pHostEnt = gethostbyname( Myhostname );
	if ( pHostEnt == NULL ) {
		keyerrfile("pHostEnt==NULL!?\n");
		return;
	}
	keyerrfile("h_length=%d\n",pHostEnt->h_length);

      while ( pHostEnt->h_addr_list[nAdapter] )
      {
		struct in_addr addr;
         // pHostEnt->h_addr_list[nAdapter] is the current address in host
         //  order.
		u_long l = (u_long)(*(u_long*)(pHostEnt->h_addr_list[nAdapter]));
		addr.s_addr = l;
		keyerrfile("ADDR=%s\n",inet_ntoa(addr));
         nAdapter++;
      }
}
#endif


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
	int timerid;

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
		mdep_popup("Polyline fails in mdep_line!?\n");
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
		mdep_popup("Polyline fails in mdep_box!?\n");
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
		mdep_popup("Unable to alloc bitmap - impending doom...");
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
		mdep_popup("P_XOR mode doesn't work in mdep_string!!");
	SetBkMode(Khdc,TRANSPARENT);
	/* SetTextColor(Khdc,Rgbvals[Fgindex]); */
	TextOut(Khdc,x,y,s,strlen((const char *)s));
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
		mdep_popup("Hey, Khdc or hPen is NULL in setfgpen!?");
	if ( SelectObject(Khdc,hPen[ci]) == NULL )
		mdep_popup("Unable to select pen in setfgpen!?");
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
		mdep_popup("Unable to select brush in setfgbrush!?");
}

static void
setbgbrush(void)
{
	int ci = Bgindex;
	if ( ci == currbrushindex )
		return;
	currbrushindex = ci;
	if ( SelectObject(Khdc,hBrush[ci]) == NULL )
		mdep_popup("Unable to select brush in setbgbrush!?");
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
		mdep_popup("Khdc==NULL in setpalette!");
		return;
	}
	if ( SelectPalette(Khdc,Hpal,1) == NULL ) {
		mdep_popup("Unable to SelectPalette!");
		return;
	}
	if ( RealizePalette(Khdc) == GDI_ERROR )
		mdep_popup("Unable to RealizePalette!");
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

	makeroom(strlen(fmt)+64,&Msg2,&Msg2size);

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

/* keyerrfile("Using numeric listen address!\n"); */
		addr = inet_addr(hostname);
		local_sin.sin_addr.s_addr = addr;

#ifdef OLDSTUFF
		phe = gethostbyaddr((const char *)(&addr),4,PF_INET);
		if ( phe == NULL ) {
/* keyerrfile("gethostbyaddr returns null!\n"); */
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
			else if ( err == WSAENOTCONN ) {
				char *nm = nameofsock(sock);
				eprint("Winsock error - unable to connect to '%s'",
					nm?nm:"???");
			}
			else
				sockerror(sock,"tcpip_send() failed");
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

static Myport *
newmyport(char *name)
{
	Myport *m;
	m = (Myport *) kmalloc(sizeof(Myport),"newmyport");
	m->name = name;
	m->sock = INVALID_SOCKET;
	m->sockstate = SOCK_UNCONNECTED;
	m->portstate = PORT_NORMAL;
	m->isopen = 0;
	m->closeme = 0;
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
#ifdef WINSOCK
	static PORTHANDLE handle[2];
	PORTHANDLE m0, m1;

	name = uniqstr(name);
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
		m0->type = "tcpip_read";
		m0->isopen = 1;
		m0->closeme = 1;
		m0->sock = sock;
		handle[0] = m0;

		m1 = newmyport(name);
		m1->type = "tcpip_write";
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
		m0->type = "tcpip_listen";
		m0->isopen = 1;
		m0->closeme = 1;
		m0->sock = sock;
		m0->sockstate = SOCK_LISTENING;
		handle[0] = m0;

		handle[1] = (PORTHANDLE)0;

		return handle;
	}
#endif
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

	switch (m->sockstate) {
	case SOCK_UNCONNECTED:
		sockaway(m,buff,size);	/* for delivery when it connects */
		r = size;
		break;
	default:
		r = tcpip_send(m,buff,size);
		break;
	}
	return r;
#else
	return 0;
#endif
}

int
mdep_getportdata(PORTHANDLE *handle, char *buff, int buffsize)
{
#ifdef WINSOCK
	Myport *m;
	int r;

	for ( m=Topport; m!=NULL; m=m->next ) {
		if ( ! m->isopen )
			continue;
		if ( m->portstate == PORT_CANREAD ) {
			if ( m->sockstate == SOCK_LISTENING ) {
				PORTHANDLE *php;
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
	if ( strncmp(m->type,"tcpip",5) == 0 ) {
		if ( m->closeme ) {
			r |= tcpip_close(m->sock);
		}
		m->sock = INVALID_SOCKET;
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
		WinHelp(Khwnd,hlpfile, HELP_PARTIALKEY, (DWORD)keyword);
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
    DWORD dwRead;
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
 
