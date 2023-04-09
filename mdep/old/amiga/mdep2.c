/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

/*
 * Amiga code for keykit
 *	Alan Bland
 *	mab@druwy.att.com
 */

#include <workbench/startup.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>
#include <libraries/gadtools.h>
#include <clib/macros.h>
#include <intuition/intuition.h>
#include <graphics/gfxmacros.h>
#include <graphics/gfxbase.h>
#include <exec/types.h>
#include <exec/ports.h>
#include <exec/io.h>
#include <exec/devices.h>
#include <exec/memory.h>
#include <dos/dosasl.h>
#include <libraries/asl.h>
#include <devices/serial.h>
#include <devices/printer.h>
#include <devices/parallel.h>
#include <devices/clipboard.h>
#include <devices/console.h>
#include <rexx/rxslib.h>
#include <rexx/storage.h>
#include <stdio.h>
#include <signal.h>
#include <time.h>

#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/gadtools.h>
#include <proto/asl.h>
#include <clib/console_protos.h>
#include <clib/rexxsyslib_protos.h>
#include <pragmas/console_pragmas.h>

/* "Debug" is used by both exec and keykit */
/* we don't use keykit's "Debug" here, so we can fake it */
#include "key.h"

#define	adjusty(y) ((y)+window->BorderTop + 1)
#define	adjustx(x) ((x)+window->BorderLeft + 1)

#define ROM_VERSION 37	/* kickstart 2.04 or later */
long text_line;
static ami_maxpen;

/* Remember-key for chip mem tracking */
/* Non-chip mem uses malloc, which gets freed automatically */
struct Library *RexxSysBase;
static long pubsig;
static int dont_open_midi = 0;
static char screenname[ 100 ];
static UWORD allocpens[ 256 ];

#define DRMODE	0
#define APENVAL	1
#define BPENVAL	2
#define MAXGRVALS 3
static long lastvals[ MAXGRVALS ] = {-1,-1,-1}, savevals[ MAXGRVALS ];

typedef struct BMAPLIST
{
	struct MinNode node;
	struct BitMap *bm;
} BMAPLIST;

#define	MSEL_NEW		0
#define	MSEL_QUIT		1
#define	MSEL_EDITOR		2
#define	MSEL_CLI		3

struct NewMenu menuitems[] =
{
	{ NM_TITLE, "Project",   0,   0, 0, 0,             },
	{ NM_ITEM,  "New...",    "N", 0, 0, (APTR)MSEL_NEW,      },
	{ NM_ITEM,  NM_BARLABEL, 0,   0, 0, 0,             },
	{ NM_ITEM,  "Quit...",   "Q", 0, 0, (APTR)MSEL_QUIT,     },

	{ NM_TITLE, "Progs",     0,   0, 0, 0,             },
	{ NM_ITEM,  "Editor",    "E", 0, 0, (APTR)MSEL_EDITOR,   },
	{ NM_ITEM,  "CLI",       "C", 0, 0, (APTR)MSEL_CLI,      },

	{ NM_END,   NULL,        0,   0, 0, 0,             },
};

struct List bmaps;

static int Fontxsize;
static int Fontysize;
static int baseline;

extern struct GfxBase *GfxBase;
static int mousex, mousey, mouseb, mousem;	/* current mouse info */
static struct Screen *screen;			/* custom screen */
static int madescreen;				/* Did we create the screen or just attach */
static struct Window *window;			/* backdrop window */
static struct Menu *menu;			/* Menu strip pointer */
static APTR vip;				/* visualinfo pointer */
static struct RastPort *rp;			/* rastport from backdrop window */
static UBYTE depth;				/* screen depth - can change! */
static struct Window *prevreqwin;		/* move DOS requestors to my screen */
static int curmode;				/* P_STORE, P_CLEAR, or P_XOR */
static BOOL titleshown;				/* is title bar being shown? */
extern void (*ami_byefcn)( void );
void ami_bye( void );
static int checkmousekey(BOOL waitflag);
static int Inverted = 0;
static struct MsgPort *rexxreply;
static int FGPen = 1;
static int BGPen = 0;

static long portmask;				/* Mask of port signals allocated to ports */
static struct List waitio, readyio;	/* Lists for port I/O operations */
__aligned struct RastPort cliprast;

/* keyboard buffer holds a single key press (multi-key escape sequences) */
/* function keys only work in graphics mode (raw input) */
#define KBUFSIZ 30
static char kbuf[KBUFSIZ];	/* converted keystroke buffer */
static int nkeys = 0;		/* num chars remaining to be processed */
static int kindex = 0;		/* index of next char in kbuf */


static ULONG save_idcmp;
static struct Process *proc;

extern struct IntuitionBase *IntuitionBase;
extern struct GfxBase *GfxBase;
long winfh;

struct ConsoleDevice *ConsoleDevice;	/* needed for RawKeyConvert */
struct IOStdReq cioreq;			/* ditto */

mdep_statconsole()
{
	register int class, code;
	register struct IntuiMessage *message;

	if (nkeys > 0) return 1;

	/* see if VANILLAKEY message has arrived */
	if ((message = (struct IntuiMessage *)GetMsg(window->UserPort)) == 0) return 0;
	class = message->Class;
	code = message->Code;
	ReplyMsg((struct Message *)message);

	if (class != VANILLAKEY) return 0;

	/* got a keystroke - vanillakey does not allow multi-keys */
	if (code == 3) {
		kindex = 0;
		nkeys = 0;
		Signal((struct Task *) proc, SIGBREAKF_CTRL_C);
		chkabort();
		return 0;
	}
	kbuf[0] = code;
	kindex = 0;
	nkeys = 1;
	return 1;
}

void
putconsole(char *s)
{
	char c = 0;

	while ( (c=(*s++)) != '\0' ) {
		if (c != '\n')
			Text( window->RPort, &c, 1 );
		if (c == '\n')
		{
			if( text_line + mdep_fontheight() >= window->Height - mdep_fontheight() )
			{
				ScrollRaster( window->RPort, 0, mdep_fontheight(), window->BorderLeft,
					window->BorderTop, window->Width - window->BorderRight,
					window->Height - window->BorderBottom );
			}
			else
				text_line += mdep_fontheight();
			Move( window->RPort, adjustx(1), adjusty(text_line) );
		}
	}
}

mdep_getconsole()
{
	register int	keystroke = -1;

	if( nkeys )
	{
		keystroke = kbuf[kindex++];
		--nkeys;
	}
	return keystroke;
}

/*------------------------------------------------------------------------
 * MIDI I/O Routines for Amiga.
 *
 * Uses low-level serial I/O for simultaneous reads and writes.
 */

static struct MsgPort	*MidiInPort, *MidiOutPort;
static struct IOExtSer	*MidiIn, *MidiOut;
static int	SerOpen = 0;

/* data from the serial.device is read into this buffer.  double-buffering */
/* is used so that keykit can process the previous buffer while the */
/* serial.device is filling the new buffer. */
#define INBUFSIZE	512
static char	Buf1[INBUFSIZE];
static char	Buf2[INBUFSIZE];
static char*	MidiInBuf[2] = { Buf1, Buf2 };
static int		MidiInCount;		/* number of bytes requested */
static UBYTE	BufNumber = 0;		/* 0 or 1, for double-buffering */
static UBYTE	MidiDataAvail = 0;	/* non-zero means request is complete */
static UBYTE	ReadPending = 0;	/* startmidiread/stopmidiread */

/*
 * start an asynchronous read request from MIDI IN.  if any data
 * is currently pending, that many bytes will be requested (up to
 * INBUFSIZE bytes).  otherwise, 1 byte will be requested, and we'll
 * find out later via statmidi when data has arrived.
 */
static void startmidiread( void )
{
	if( dont_open_midi )
		return;

	/* find out how many bytes are waiting for us */
	MidiIn->IOSer.io_Command = SDCMD_QUERY;
	DoIO((struct IORequest *) MidiIn);
	MidiInCount = MidiIn->IOSer.io_Actual;
	if (MidiInCount == 0) {
		MidiInCount = 1;
	} else if (MidiInCount > INBUFSIZE) {
		MidiInCount = INBUFSIZE;
	}

	/* issue the read request */
	MidiIn->IOSer.io_Data = (APTR) MidiInBuf[BufNumber];
	MidiIn->IOSer.io_Length = MidiInCount;
	MidiIn->IOSer.io_Command = CMD_READ;
	MidiIn->IOSer.io_Flags = IOF_QUICK;	/* use quick I/O */
	BeginIO((struct IORequest *) MidiIn);
	/* did I/O complete quickly? */
	if ((MidiIn->IOSer.io_Flags & IOF_QUICK)) {
		/* wow, data's coming in fast! */
		MidiDataAvail = 1;
	} else {
		/* no data this time, it'll arrive later */
		MidiDataAvail = 0;
		ReadPending = 1;
	}
}

static void stopmidiread( void )
{
	if (ReadPending) {
		AbortIO((struct IORequest *) MidiIn);
		WaitIO((struct IORequest *) MidiIn);
		ReadPending = 0;
	}
}

/*
 * read data from MIDI IN.  assumes startmidiread has been previously done
 * to request 1 or more bytes from the serial.device.  statmidi should
 * have been done previously to determine that the request has completed.
 */
int
mdep_getnmidi(char *buf, int size)
{
	int count = 0;

	if( dont_open_midi )
		return count;
	/* if the previous read request is complete, return it. */
	/* we use double-buffering so the driver and keykit can share. */
	if (MidiDataAvail) {
		count = MidiInCount;

		/* start a new read request to fill the other buffer */
		BufNumber = BufNumber ? 0 : 1;
		startmidiread();

		/* return the previous buffer */
		memcpy( buf, MidiInBuf[BufNumber ? 0 : 1], count );
	}

	/* no data available */
	return count;
}

/*
 * write n bytes to MIDI OUT
 */
void mdep_putnmidi(int n, char *buf)
{
	if( dont_open_midi )
		return;
	MidiOut->IOSer.io_Data = (APTR) buf;
	MidiOut->IOSer.io_Length = n;
	MidiOut->IOSer.io_Command = CMD_WRITE;
	DoIO((struct IORequest *) MidiOut);	/* synchronous request */
}

/*
 * check if any midi data is waiting to be received
 */
statmidi( void )
{
	/* check if data has previously been received */
	if (MidiDataAvail) return 1;

	/* check if i/o has completed */
	MidiDataAvail = CheckIO((struct IORequest *) MidiIn) == FALSE ? 0 : 1;
	return (int) MidiDataAvail;
}

void ami_openmidi( void )
{
	int	error;

	opentimer();

	if( dont_open_midi )
		return;

	/* create message port for serial device */
	MidiInPort = (struct MsgPort *) CreatePort(SERIALNAME,0);
	if (MidiInPort == NULL) fatal("Can't create MidiInPort");

	/* create i/o request block for serial device */
	MidiIn = (struct IOExtSer *)
		CreateExtIO(MidiInPort, sizeof(struct IOExtSer));
	if (MidiIn == NULL) fatal("Can't create MidiIn");

	/* open the serial device */
	MidiIn->io_SerFlags = SERF_SHARED;
	SerOpen = OpenDevice(SERIALNAME,0,(struct IORequest *) MidiIn,0) == 0 ? 1 : 0;
	if (SerOpen == 0) fatal("Can't open serial.device");

	/* set serial device parameters */
	MidiIn->io_Baud = 31250;
	MidiIn->io_SerFlags = SERF_RAD_BOOGIE;
	MidiIn->IOSer.io_Command = SDCMD_SETPARAMS;
	error = DoIO((struct IORequest *) MidiIn);
	if (error != 0) {
		char errmsg[60];
		sprintf(errmsg, "Serial SETPARAMS failed, error %d", error);
		fatal(errmsg);
	}

	/* clone MidiIn into MidiOut to allow simultaneous i/o */
	MidiOutPort = (struct MsgPort *) CreatePort("keyout",0);
	if (MidiOutPort == NULL) fatal("Can't create MidiOutPort");

	MidiOut = (struct IOExtSer *)
			CreateExtIO(MidiOutPort, sizeof(struct IOExtSer));
	*MidiOut = *MidiIn;
	MidiOut->IOSer.io_Message.mn_ReplyPort = MidiOutPort;

	/* start the input coming */
	startmidiread();
}

void ami_closemidi()
{
	stopmidiread();
	if (SerOpen) CloseDevice((struct IORequest *)MidiIn);
	if (MidiIn) DeleteExtIO((struct IORequest *)MidiIn);
	if (MidiOut) DeleteExtIO((struct IORequest *)MidiOut);
	if (MidiInPort) DeletePort(MidiInPort);
	if (MidiOutPort) DeletePort(MidiOutPort);
	SerOpen = 0;
	MidiIn = 0;
	MidiOut = 0;
	MidiInPort = 0;
	MidiOutPort = 0;
	closetimer();
	dont_open_midi = 0;
}

/*
 * call this when the realtime loop is started
 */
void realstart()
{
	/* don't allow realtime loop if timer interrupt isn't setup */
	/* currently only the first instance of keykit can use the timer */
	if (!timer_running()) {
		execerror("Sorry, timer not available");
	}
}

int mdep_mousewarp( int x, int y )
{
	MoveSprite( &window->WScreen->ViewPort, 0, x + window->BorderLeft, y + window->BorderRight );
	return( 0 );
}

/*
 * Here's the real main.  If called from CLI, pass argc/argv normally.
 * If called from Workbench, we have some work to do.
 */

static char *wbargv[] = { "key" };

int main(int argc, char **argv)
{
	char *s;
	if (argc == 0) {
		/* fake argc/argv for workbench */
		/* in the future, parse the tooltypes etc. */
		argc = 1;
		argv = wbargv;
	}
	if( argc > 1 && stricmp( argv[1], "nomidi" ) == 0 )
		dont_open_midi = 1;

	InitRastPort( &cliprast );
	rexxreply = CreateMsgPort();
	memset( allocpens, 0xff, sizeof( allocpens ) );
	if( s = getenv( "KEYPRIORITY" ) )
		SetTaskPri( FindTask( NULL ), atoi(s) );
	NewList( &waitio );
	NewList( &readyio );
	NewList( &bmaps );
	if( ( RexxSysBase = OpenLibrary( "rexxsyslib.library", 0 ) ) == NULL )
	{
		fprintf( stderr, "%s: can't open rexxsyslib.library", argv[0] );
		exit( 1 );
	}

	return keymain(argc, argv);
}

/*
 * Initialize machine-dependent variables before keykit.rc
 */
void mdep_prerc()
{
	char *s, mpath[ 200 ];
	*Pathsep = uniqstr(",");
	if( (s = getenv( "KEYROOT" )) == NULL )
		*Keyroot = uniqstr( "KeyKit:" );
	else
		*Keyroot = uniqstr( s );
	sprintf( mpath, ",%s%smusic", *Keyroot,
			strchr( "/:", (*Keyroot)[strlen(*Keyroot)-1] ) ? "" : "/" );
			
	*Musicpath = uniqstr(mpath);
	Killchar = 24;		/* amiga kill char is ^X */
	Erasechar = '\b';	/* amiga erase char is BS */
	if( s = getenv( "KEYCOLORS" ) )
		*Colors = atoi(s);
	else
		*Colors = KEYNCOLORS;		/* 4 bit-planes is default */
	ami_byefcn = ami_bye;
}

char *
mdep_musicpath(void)
{
	char *p, *str;

	p = (char *) kmalloc((unsigned)(3*strlen(*Keyroot)+64), "music path");
	sprintf(p,"%s%s%smusic",*Pathsep,*Keyroot,SEPARATOR);
	str = uniqstr(p);
	kfree(p);
	return str;
}


char *
mdep_keypath( void )
{
	char *p, *path;
	char buf[ 200 ];

	if ( (p=getenv("KEYPATH")) != NULL && *p != '\0' ) {
		path = p;
		sprintf(buf, "keykit: warning - using $KEYPATH of: %s", p);
		eprint( buf );
	}
	else {
		path = "keykit:,keykit:liblocal,keykit:lib";
	}
	return path;
}

void
ami_freebmaps( struct List *lp )
{
	struct Node *np;
	BMAPLIST *bl;
	while( np = RemHead( lp ) )
	{
		bl = (BMAPLIST *)np;
		if( bl->bm )
		{
			FreeBitMap( bl->bm );
		}
		free( np );
	}
}

void
ami_freebitmap( struct BitMap *bm )
{
	struct MinNode *np;
	BMAPLIST *bl;

	for( np = (struct MinNode *)bmaps.lh_Head; np->mln_Succ; np = np->mln_Succ )
	{
		bl = (BMAPLIST *)np;
		if( bm == bl->bm )
			break;
	}

	if( np->mln_Succ && bm )
	{
		Remove( (struct Node *)np );
		FreeBitMap( bm );
		free( np );
	}
	else
	{
		mdep_popup( "Hey, didn't find bitmap to free" );
	}
}

/*
 * Amiga-dependent clean-up
 */
void ami_bye()
{
	ami_freebmaps( &bmaps );
	if( RexxSysBase ) CloseLibrary( RexxSysBase );
	if( rexxreply ) DeleteMsgPort( rexxreply );
	ami_closemidi();
	mdep_endgraphics();

	exit(0);
}

void millisleep(unsigned t)
{
	unsigned v = t/20;
	Delay(v > 0 ? v : 1);	/* avoid Delay(0) bug */
}

void mdep_setinterrupt(void (*f)())
{
	signal(SIGINT, f);
	signal(SIGFPE, f);
}

void mdep_ignoreinterrupt()
{
	signal(SIGINT, SIG_IGN);
	signal(SIGFPE, SIG_IGN);
}

mdep_shellexec(char *s)
{
	return system(s);
}

/*
 * default color map - arbitrary except for pens 0, 1, 2 and n-3, n-2 and n-1
 * which are paired for correct complement effect drawing
 */
static UWORD mypens[]=
{
	15,	/* DETAILPEN */
	1,	/* BLOCKPEN */
	15,	/* TEXTPEN */
	0,	/* SHINEPEN */
	15,	/* SHADOWPEN */
	13,	/* FILLPEN */
	15,	/* FILLTEXTPEN */
	1,	/* BACKGROUNDPEN */
	0,	/* HIGHLIGHTTEXTPEN */
	15,	/* BARDETAILPEN */
	1,	/* BARBLOCKPEN */
	0,	/* BARTRIMPEN */
	65535,
};

#define PENSOFF	3
static UWORD colortable[] = {
	0xfff,	/*  0 white */
	0xccc,	/*  1 light grey */
	0xf00,	/*  2 red */
	0xa80,	/*  3 medium orange */
	0x008,	/*  4 medium blue */
	0x808,	/*  5 medium purple */
	0x880,	/*  6 medium yellow */
	0x59c,	/*  7 medium cyan */
	0xd00,	/*  8 red */
	0x0d0,	/*  9 green */
	0x00d,	/* 10 blue */
	0xaaa,	/* 11 orange */
	0x0ff,	/* 12 yellow */
	0x59c,	/* 13 cyan */
	0x888,	/* 14 dark grey */
	0x000,	/* 15 black */
};

/* set title bar on or off */
static void settitle(BOOL state)
{
	static char titlebar[ 100 ];
	strcpy( titlebar, "KeyKit v6.0c - " );

	/* show free memory in title bar */
	if (state == TRUE) {
		sprintf(titlebar, "KeyKit v6.0c - Chip=%d, Fast=%d",
			AvailMem(MEMF_CHIP), AvailMem(MEMF_FAST));
	}
	SetWindowTitles( window, "KeyKit v6.0c - ported by Gregg Wonderly", titlebar );
	ShowTitle(window->WScreen, state);
	titleshown = state;
}

void
mdep_initcolors(void)
{
	char *p = getenv("KEYINVERSE");

	Inverted = 0;
	if ( p != NULL && *p != '0' )
		Inverted = 1;
	if( Inverted )
	{
		allocpens[ FGPen ] = 0;
		allocpens[ BGPen ] = *Colors-1;
	}
	else
	{
		allocpens[ FGPen ] = *Colors-1;
		allocpens[ BGPen ] = 0;
	}
}

int mdep_startgraphics(int argc, char **argv)
{
	char *s;
	long dispid;
	long width = STDSCREENWIDTH;
	long height = STDSCREENHEIGHT;
	long oscan = OSCAN_STANDARD;
	long autoscroll = 0;
	struct Screen *scr;

	if (rp) {
		/* screen is already open */
		return(0);
	}
	
	dispid = 0;
	if( s = getenv( "KEYSCREEN" ) )
	{
		strcpy( screenname, s );
	}

	if( s = getenv( "KEYDISPLAY" ) )
	{
		if( sscanf( s, "%lx", &dispid ) != 1 )
			dispid = 0;
	}

	while( dispid == 0 )
	{
		struct ScreenModeRequester *req;
		req = AllocAslRequestTags( ASL_ScreenModeRequest,
					ASLSM_DoAutoScroll, TRUE,
					ASLSM_DoDepth, TRUE,
					ASLSM_DoWidth, TRUE,
					ASLSM_DoHeight, TRUE,
					ASLSM_DoDepth, TRUE,
					ASLSM_DoOverscanType, TRUE,
					TAG_DONE );
		if( req )
		{
			if( AslRequest( req, NULL ) == TRUE )
			{
				dispid = req->sm_DisplayID;
				width = req->sm_DisplayWidth;
				height = req->sm_DisplayHeight;
				depth = req->sm_DisplayDepth;
				*Colors = (1L << depth);
				oscan = req->sm_OverscanType;
				autoscroll = req->sm_AutoScroll;
				FreeAslRequest( req );
			}
			else
			{
				FreeAslRequest( req );
				req = NULL;
			}

			if( !req )
			{
				mdep_popup( "Can not get screen mode with ASL requester" );
				ami_bye();
			}
		}
	}

	/* Colors can be 2, 4, 8, 16, 32, 64, 128 or 256 as desired. */
	
	/* adjust Colors to legal value and find screen depth */
	if (*Colors <= 2) {
		*Colors = 2;
		depth = 1;
	} else if (*Colors <= 4) {
		*Colors = 4;
		depth = 2;
	} else if (*Colors <= 8) {
		*Colors = 8;
		depth = 3;
	} else if (*Colors <= 16) {
		*Colors = 16;
		depth = 4;
	} else if (*Colors <= 32) {
		*Colors = 32;
		depth = 5;
	} else if (*Colors <= 64) {
		*Colors = 64;
		depth = 6;
	} else if (*Colors <= 128) {
		*Colors = 128;
		depth = 7;
	} else {
		*Colors = 256;
		depth = 8;
	}
	mypens[ DETAILPEN ] = *Colors-1;
	mypens[ SHADOWPEN ] = *Colors-1;
	mypens[ TEXTPEN ] = *Colors-1;
	mypens[ FILLPEN ] = *Colors-3;
	mypens[ FILLTEXTPEN ] = *Colors-1;
	mypens[ BARDETAILPEN ] = *Colors-1;

	if( ( menu = CreateMenus( menuitems, TAG_DONE ) ) == NULL )
	{
			mdep_popup("CreateMenus failed!\n");
			ami_bye();
			return(1);
	}

	madescreen = 0;
	if( ( scr = LockPubScreen( screenname ) ) == NULL )
	{
		madescreen = 1;
		if (!(screen = OpenScreenTags( NULL,
					SA_Depth, depth,
					SA_DisplayID, dispid,
					SA_Width, width,
					SA_Height, height,
					SA_AutoScroll, autoscroll,
					SA_Title, "KeyKit v6.0c",
					SA_PubName, screenname,
					SA_Overscan, oscan,
					SA_Interleaved, TRUE,
					SA_PubSig, pubsig = AllocSignal( -1 ),
					SA_PubTask, FindTask( NULL ),
					SA_Pens, mypens,
					TAG_DONE ) ) )
		{
			mdep_popup("OpenScreen failed!\n");
			ami_bye();
			return(1);
		}

		PubScreenStatus( screen, 0 );
		if( (scr = LockPubScreen( screenname ) ) == NULL )
		{
			mdep_popup( "LockPubScreen Failed after open" );
			ami_bye();
			return(1);
		}
	}

	/* open a backdrop window for the main activity */
	if (!(window = OpenWindowTags(NULL,
				WA_PubScreen, scr,
				WA_PubScreenFallBack, TRUE,
				WA_Title, "Amiga KeyKit",
				WA_Top, 1,
				WA_Left, 1,
				WA_Width, scr->Width - 2,
				WA_Height, scr->Height - 2,
				WA_MinWidth, 100L,
				WA_MinHeight, 100L,
				WA_MaxWidth, ~0L,
				WA_MaxHeight, ~0L,
				WA_IDCMP, IDCMP_SIZEVERIFY|IDCMP_NEWSIZE|IDCMP_MOUSEBUTTONS|
					IDCMP_MOUSEMOVE|IDCMP_RAWKEY|IDCMP_MENUVERIFY|IDCMP_MENUPICK,
				WA_Flags, WFLG_ACTIVATE|WFLG_RMBTRAP|WFLG_NEWLOOKMENUS|
					WFLG_SIZEBBOTTOM|WFLG_DRAGBAR|WFLG_SIZEGADGET|WFLG_DEPTHGADGET|
					WFLG_SMART_REFRESH|WFLG_NOCAREREFRESH|WFLG_REPORTMOUSE,
				TAG_DONE))) {
		mdep_popup("OpenWindow failed!\n");
		UnlockPubScreen( NULL, scr );
		mdep_endgraphics();
		return(1);
	}
	UnlockPubScreen( NULL, scr );

	if( ( vip = GetVisualInfo( window->WScreen, TAG_DONE ) ) != NULL )
	{
		if( LayoutMenus( menu, vip, TAG_DONE ) == FALSE )
		{
			mdep_popup( "LayoutMenus failed!\n" );
			mdep_endgraphics();
			return( 1 );
		}
		SetMenuStrip( window, menu );
	}
	settitle(TRUE);
	Fontxsize = window->RPort->TxWidth;
	Fontysize = window->RPort->TxHeight;
	baseline = window->RPort->TxBaseline;

	/* For the amiga, we have to make black and white complements of each other, so
	 * we have the allocpens array which actually determines which pen is associated
	 * with the keykit pen.
	 */
	if( Inverted )
	{
		allocpens[FGPen] = 0;
		allocpens[BGPen] = *Colors-1;
	}
	else
	{
		allocpens[FGPen] = *Colors-1;
		allocpens[BGPen] = 0;
	}
	allocpens[2] = 2;
	allocpens[3] = 1;
	allocpens[4] = *Colors-2;

	/* Set the Base 16 (or fewer colors */
	LoadRGB4(&window->WScreen->ViewPort, colortable, min( *Colors, 16 ) );

	ami_maxpen = *Colors - 6;
	/* Set complementary colors */
	SetRGB4(&window->WScreen->ViewPort, *Colors-3, 5, 9, 12 );
	SetRGB4(&window->WScreen->ViewPort, *Colors-2, 3, 3, 3 );
	SetRGB4(&window->WScreen->ViewPort, *Colors-1, 0, 0, 0 );

	/* this will put DOS requestors on the new screen */
	proc = (void *)FindTask( NULL );
	prevreqwin = (struct Window *) proc->pr_WindowPtr;
	proc->pr_WindowPtr = (APTR) window;

	rp = window->RPort;
	curmode = -1;
	mdep_plotmode(P_STORE);
	mousex = mousey = mouseb = 0;

	*Consecho = 1;

	/* RawKeyConvert needs this */
	if( OpenDevice("console.device",-1, (struct IORequest*)&cioreq,0 ) )
		fatal("no console.device");
	ConsoleDevice = (struct ConsoleDevice *)cioreq.io_Device;

	return(0);
}

void mdep_endgraphics()
{
	if (window)
	{
		/* restore intuition mouse pointer */
		ClearPointer(window);

		/* restore DOS requesters to original window */
		if (prevreqwin) proc->pr_WindowPtr = (APTR) prevreqwin;
		prevreqwin = NULL;

		ClearMenuStrip( window );
		CloseWindow(window);
		window = NULL;
	}
	if( menu ) FreeMenus( menu );
	menu = NULL;
	if( vip ) FreeVisualInfo( vip );
	vip = NULL;
	if (screen && madescreen ) {
		/*PubScreenStatus( screen, PSNF_PRIVATE );*/
		while( CloseScreen(screen) != TRUE )
		{
			mdep_popup( "Visiting windows must be closed\nbefore keykit can exit!" );
		}
	}
	screen = NULL;
	ami_freebmaps( &bmaps );
	rp = NULL;

	if (ConsoleDevice) CloseDevice((struct IORequest *)&cioreq);
}

mdep_maxx() { return ( window->Width - window->BorderLeft - window->BorderRight - 2 ); }

mdep_maxy() { return ( window->Height - window->BorderTop - window->BorderBottom - 2 ); }

void mdep_plotmode(int mode)
{
	int m, a, b;

	switch (mode) {
	case P_XOR:
		a = allocpens[ FGPen ];
		b = allocpens[ BGPen ];
		m = COMPLEMENT;
		break;
	case P_STORE:
		a = allocpens[ FGPen ];
		b = allocpens[ BGPen ];
		m = JAM2;
		break;
	case P_CLEAR:
		a = allocpens[ BGPen ];
		b = allocpens[ FGPen ];
		m = JAM1;
		break;
	default:
		return;
	}
	SetRAST( m, a, b );
	curmode = mode;
}

void mdep_line(int x0, int y0, int x1, int y1)
{
	Move(rp, adjustx(x0), adjusty(y0));
	Draw(rp, adjustx(x1), adjusty(y1));
}

void mdep_box(int x0, int y0, int x1, int y1)
{
	SHORT box[8];

	x0 = adjustx(x0);
	y0 = adjusty(y0);

	x1 = adjustx(x1);
	y1 = adjusty(y1);

	box[0] = x0; box[1] = y1;
	box[2] = x1; box[3] = y1;
	box[4] = x1; box[5] = y0;
	box[6] = x0; box[7] = y0;
	Move(rp, x0, y0);
	PolyDraw(rp, 4, box);
}

void mdep_dot(int x0, int y0)
{
	WritePixel(rp, adjustx(x0), adjusty(y0));
}

void mdep_boxfill(int x0, int y0, int x1, int y1)
{
	x0 = adjustx(x0);
	y0 = adjusty(y0);

	x1 = adjustx(x1);
	y1 = adjusty(y1);

#if 0
	if (curmode == P_CLEAR) {
		BltBitMap(rp->BitMap, x0, y0, rp->BitMap,
			x0, y0,	x1-x0+1, y1-y0+1, 0x00, 0xff, 0);
	}
	else
#endif
	{
		if( x1 > window->Width - window->BorderRight - 1 )
			x1 = window->Width - window->BorderRight - 1;
		if( y1 > window->Height - window->BorderBottom - 1 )
			y1 = window->Height - window->BorderBottom - 1;
		if( x0 < window->BorderLeft + 1 )
			x0 = window->BorderLeft + 1;
		if( y0 < window->BorderTop + 1 )
			y0 = window->BorderTop + 1;
		switch( curmode )
		{
		case P_STORE:
			SetRAST( JAM1, allocpens[ FGPen ], -1 );
			break;
		case P_CLEAR:
			SetRAST( JAM1, -1, allocpens[ BGPen ] );
			break;
		case P_XOR:
			SetRAST( COMPLEMENT, allocpens[ FGPen ], -1 );
			break;
		}
		RectFill(rp, x0, y0, x1, y1);
	}
}

Pbitmap mdep_allocbitmap(int xsize, int ysize)
{
	Pbitmap pb;
	BMAPLIST *bp;

	bp = (BMAPLIST *)kmalloc( sizeof( *bp ), "alloc bitmap" );
	if (!bp) fatal("no mem");

	pb.ptr = (unsigned char *) AllocBitMap( xsize, ysize, depth,
				BMF_CLEAR, window->WScreen->RastPort.BitMap );
	if (!pb.ptr)
	{
		kfree( bp );
		fatal("no mem");
	}
	pb.xsize = pb.origx = xsize;
	pb.ysize = pb.origy = ysize;

	bp->bm = (struct BitMap *)pb.ptr;

	/* Add at head so that short used maps are found fast */
	AddHead( &bmaps, (struct Node *)&bp->node );
	return pb;
}

Pbitmap mdep_reallocbitmap(int xsize, int ysize, Pbitmap pb)
{
	if (xsize <= pb.origx && ysize <= pb.origy) {
		pb.xsize = xsize;
		pb.ysize = ysize;
		return pb;
	}
	mdep_freebitmap(pb);
	return mdep_allocbitmap(xsize, ysize);
}

void mdep_freebitmap(Pbitmap pb)
{
	WaitBlit();
	ami_freebitmap( (struct BitMap *)pb.ptr );
}

/* pullbitmap and pushbitmap assume entire screen is available */
/* these need to be changed if you want to try a workbench window */
/* probably by using ClipBlit instead of BltBitMap */

void mdep_pullbitmap(int x0, int y0, Pbitmap pb)
{
	/* pullblit is always assumed to be a direct copy (P_STORE) */
	cliprast.BitMap = (struct BitMap *) pb.ptr;
	ClipBlit(rp, adjustx(x0), adjusty(y0), &cliprast, 0, 0, pb.xsize, pb.ysize, 0xc0);
}

void mdep_putbitmap(int x0, int y0, Pbitmap pb)
{
	cliprast.BitMap = (struct BitMap *) pb.ptr;
	ClipBlit(&cliprast, 0, 0, rp, adjustx(x0), adjusty(y0), pb.xsize, pb.ysize, 0xc0);
}

void mdep_movebitmap(int x, int y, int wid, int ht, int tox, int toy)
{
	ClipBlit(rp, adjustx(x), adjusty(y), rp, adjustx(tox), adjusty(toy), wid, ht, 0xc0);
}

/*
 * Convert RAWKEY to VANILLAKEY - from RKM 1.3 Libs & Devs
 */
int DeadKeyConvert(struct IntuiMessage *msg, UBYTE *kbuffer, LONG kbsize, struct KeyMap *kmap)
{
	static struct InputEvent ievent = {NULL, IECLASS_RAWKEY,0,0,0};
	if (msg->Class != RAWKEY) return -2;
	ievent.ie_Code = msg->Code;
	ievent.ie_Qualifier = msg->Qualifier;
	ievent.ie_position.ie_addr = *((APTR*)msg->IAddress);
	return RawKeyConvert(&ievent,kbuffer,kbsize,kmap);
}

/*
 * Return K_MOUSE or K_CONSOLE to reflect any mouse or keyboard activity.
 * mousex, mousey, and mouseb are updated to reflect the state of the
 * mouse (even if K_CONSOLE occurred).  If waitflag is TRUE, we wait for
 * new activity, FALSE means we return the currently pending event if
 * any, or K_MOUSE if nothing is pending.  K_WINDRESIZE is returned for
 * window sizing and K_ WINDEXPOSE refresh events.  If K_CONSOLE is returned,
 * keykit will call mdep_getconsole() to actually get the keystroke.
 */

static int checkmousekey(BOOL waitflag)
{
	static int verify = 0;
	char buf[ 100 ];
	struct MenuItem *item;
	struct IntuiMessage *message;
	int class, code, qual;
	int newmousex, newmousey;
	BOOL mouse_moved = FALSE;

	/* continue returning chars until keyboard buffer is empty */
	if (nkeys > 0) {
		return K_CONSOLE;
	}

	for (;;) {
		if ((message = (struct IntuiMessage *)GetMsg(window->UserPort)) == NULL) {
			if (waitflag == TRUE) {
				Wait(1<<window->UserPort->mp_SigBit);
				continue;
			} else {
				/* use most recent mouse stuff */
				return 0;
			}
		}
		do {
			class = message->Class;
			code = message->Code;
			newmousex = message->MouseX;
			newmousey = message->MouseY;
			qual = message->Qualifier;
			if( class == IDCMP_RAWKEY )
			{
				nkeys = DeadKeyConvert(message, kbuf, KBUFSIZ, 0);
				kindex = 0;
			}
			ReplyMsg((struct Message *)message);

			if( ( newmousey <= window->BorderTop + window->TopEdge ) &&
				( newmousey >= window->TopEdge ) )
			{
				window->Flags &= ~WFLG_RMBTRAP;
			}
			else if( verify == 0 )
			{
				window->Flags |= WFLG_RMBTRAP;
			}

			/* show screen title bar whenever left-amiga key is pressed */
			if (titleshown == FALSE && (qual & AMIGALEFT)) {
				settitle(TRUE);
			} else if (titleshown == TRUE && !(qual & AMIGALEFT)) {
				settitle(FALSE);
			}

			switch (class) {
			case IDCMP_RAWKEY:
				if (nkeys < 1) continue; /* dead key */
				/* handle special case characters */
				if (kbuf[kindex] == 3) {
					nkeys = 0;
					Signal((struct Task *) proc, SIGBREAKF_CTRL_C);
					chkabort();
				} else if ((kbuf[kindex]&0xff) == 0x9b) {
					/* start of escape sequence */
					/* convert F1-F10 to <ESC>a thru j */
					/* shifted F1-F10 to <ESC>k thru t */
					/* help to <ESC>u */
					if (kbuf[nkeys-1] == '~') {
						if (kbuf[nkeys-2] == '?') {
							/* HELP = <CSI>?~ */
							kbuf[1] = 'u';
						} else {
							/* F1 = <CSI>0~ F2 = <CSI>1~ etc */
							kbuf[1] = atoi(kbuf+1) + 'a';
						}
						kbuf[0] = '\033';
						nkeys = 2;
						kindex = 0;
					} else {
#ifdef ANSI_NOT_YET
						/* make anything else be real ANSI */
						/* by changing <CSI> to <ESC>[ */
						/* arrow keys are all that's left */
						memcpy(&kbuf[2], &kbuf[1], nkeys-1);
						++nkeys;
						kindex = 0;
						kbuf[0] = '\033';
						kbuf[1] = '[';
#else
						/* ignore any other escape sequences */
						nkeys = 0;
						continue;
#endif
					}
				}
				return K_CONSOLE;
			case IDCMP_MOUSEMOVE:
				/* collapse buffered mouse movements into one */
				mouse_moved = TRUE;
				continue;
			case IDCMP_MOUSEBUTTONS:
				verify = 0;
				mousem = message->Qualifier;
				switch (code) {
				case SELECTUP:
					mouseb &= ~1;
					break;
				case SELECTDOWN:
					mouseb |= 1;
					break;
				case MENUUP:
					mouseb &= ~2;
					break;
				case MENUDOWN:
					mouseb |= 2;
					break;
				}
				return K_MOUSE;
			case IDCMP_SIZEVERIFY:
				window->Flags &= ~WFLG_REPORTMOUSE;
				break;
			case IDCMP_NEWSIZE:
				window->Flags |= WFLG_REPORTMOUSE;
				return K_WINDRESIZE;
			case IDCMP_REFRESHWINDOW:
				return K_WINDEXPOSE;
			case IDCMP_MENUVERIFY:
				verify = 1;
				break;
			case IDCMP_MENUPICK:
				while( (((unsigned)code)&0xffff) != MENUNULL )
				{
					item = ItemAddress( menu, code );
					switch( (int)GTMENUITEM_USERDATA( item ) )
					{
					case MSEL_NEW:
						break;
					case MSEL_QUIT:
						if( amiask( "Ready to QUIT keykit?", NULL ) )
							mdep_bye();
						break;
					case MSEL_EDITOR:
						sprintf( buf, "bin:vi -S %s -s", screenname );
						System( buf, NULL );
						break;
					case MSEL_CLI:
						break;
					}
					code = item->NextSelect;
				}
				verify = 0;
				break;
			}
		} while (message = (struct IntuiMessage *) GetMsg(window->UserPort));

		if (mouse_moved == TRUE) {
			mousex = newmousex-adjustx(0);
			mousey = newmousey-adjusty(0);
			return K_MOUSE;
		}
	}
}

/* wait for mouse or keyboard activity */
int mdep_wait()
{
	return checkmousekey(TRUE);
}

/* get current mouse state without waiting */
int mdep_mouse(int *ax, int *ay, int *am)
{
	checkmousekey(FALSE);
	if (ax) *ax = mousex;
	if (ay) *ay = mousey;
	*am = mousem;
	return mouseb;
}

void mdep_color(int n)
{
	SetRAST( -1, allocpens[ FGPen = n ], -1 );
	mdep_plotmode( curmode );
}

void mdep_colormix(int n, int r, int g, int b)
{
	if (n>=0 && n<ami_maxpen )
	{
		/*
		 * If the color has not already been assigned a pen number, assign one now.
		 * The first 3 pens and the last three pens are already used, so add three
		 * now to avoid new pens overwriting the existing pens mappings.
		 */
		if( allocpens[ n ] == 0xffff )
			allocpens[ n ] = n + PENSOFF;

		SetRGB32(&window->WScreen->ViewPort, allocpens[ n ], r<<16, g<<16, b<<16);
	}
	mdep_plotmode( curmode );
}

void mdep_sync()
{
	WaitBlit();
}

/*------------------------------------------------------------------------
 * Amiga-specific font routines - for now, only supports ROM topaz.8
 */

long mdep_fontwidth()
{
	return( Fontxsize );
}

long mdep_fontheight()
{
	return( Fontysize );
}

char *mdep_fontinit(char *fontname)
{
	/* assume topaz.8 */
	if( window )
	{
		Fontxsize = window->RPort->TxWidth;
		Fontysize = window->RPort->TxHeight;
		*Menuymargin = 1;
		baseline = window->RPort->TxBaseline;
	}
	return NULL;
}

void mdep_string(int x, int y, char *s)
{
	SaveRAST( JAM1, allocpens[ FGPen ], -1 );
	Move(rp, adjustx(x), adjusty(y) + baseline );
	Text(rp, s, strlen(s));
	RestoreRAST( );
}

void
SaveRAST( long mode, long apen, long bpen )
{
	savevals[ APENVAL ] = rp->FgPen;
	savevals[ BPENVAL ] = rp->BgPen;
	savevals[ DRMODE ] = rp->DrawMode;
	SetRAST( mode, apen, bpen );
}

void
SetRAST( long mode, long apen, long bpen )
{
	if( lastvals[ DRMODE ] != mode && mode != -1 )
	{
		lastvals[ DRMODE ] = mode;
		SetDrMd( rp, mode );
	}

	if( lastvals[ APENVAL ] != apen && apen != -1 )
	{
		lastvals[ APENVAL ] = apen;
		SetAPen( rp, apen );
	}

	if( lastvals[ BPENVAL ] != bpen && bpen != -1 )
	{
		lastvals[ BPENVAL ] = bpen;
		SetBPen( rp, bpen );
	}
}
	
void
RestoreRAST( void )
{
	SetRAST( savevals[ DRMODE ], savevals[ APENVAL ], savevals[ BPENVAL ] );
}

/*------------------------------------------------------------------------
 * mouse pointer
 */

#define MOUSE_HT 12
#define MOUSE_WD 16

static USHORT chip nomouse[] = {0,0,0,0,0,0};	/* invisible mouse */
static USHORT *mousedata;
static int mouse_xoff = 0, mouse_yoff = 0;

static USHORT chip anywhere_pointer[] = {
0,0,
0xe700,0x0000,0xc300,0x0000,0xa500,0x0000,0x1800,0x0000,
0x1800,0x0000,0xa500,0x0000,0xc300,0x0000,0xe700,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0,0
};
static short anywhere_xoff = -1;
static short anywhere_yoff = 0;
static USHORT chip arrow_pointer[] = {
0,0,
0xf000,0x0000,0xc000,0x0000,0xa000,0x0000,0x9000,0x0000,
0x0800,0x0000,0x0400,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0,0
};
static short arrow_xoff = -1;
static short arrow_yoff = 0;
static USHORT chip busy_pointer[] = {
0,0,
0xff00,0x0000,0x8100,0x0000,0x4200,0x3c00,0x4200,0x3c00,
0x2400,0x1800,0x1000,0x0800,0x0800,0x1000,0x2400,0x0800,
0x4200,0x1000,0x4200,0x0800,0x8100,0x1000,0xff00,0x0000,
0,0
};
static short busy_xoff = -1;
static short busy_yoff = 0;
static USHORT chip cross_pointer[] = {
0,0,
0x0800,0x0000,0x0800,0x0000,0x0800,0x0000,0x0000,0x0000,
0xe380,0x0000,0x0000,0x0000,0x0800,0x0000,0x0800,0x0000,
0x0800,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0,0
};
static short cross_xoff = -5;
static short cross_yoff = -4;
static USHORT chip leftright_pointer[] = {
0,0,
0x0000,0x0000,0x0000,0x0000,0x1040,0x0000,0x3060,0x0000,
0x6030,0x0000,0xfff8,0x0000,0x6030,0x0000,0x3060,0x0000,
0x1040,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0,0
};
static short leftright_xoff = -1;
static short leftright_yoff = -5;
static USHORT chip sweep_pointer[] = {
0,0,
0xff00,0x0000,0xc100,0x0000,0xa100,0x0000,0x9100,0x0000,
0x8100,0x0000,0x8100,0x0000,0x8100,0x0000,0xff00,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0,0
};
static short sweep_xoff = -1;
static short sweep_yoff = 0;
static USHORT chip updown_pointer[] = {
0,0,
0x0200,0x0000,0x0700,0x0000,0x0f80,0x0000,0x1ac0,0x0000,
0x0200,0x0000,0x0200,0x0000,0x0200,0x0000,0x1ac0,0x0000,
0x0f80,0x0000,0x0700,0x0000,0x0200,0x0000,0x0000,0x0000,
0,0
};
static short updown_xoff = -7;
static short updown_yoff = 0;

void
mdep_setcursor(type)
int type;		/* M_NOTHING, M_ARROW, M_..etc..*/
{
	static int prevcursor = M_NOTHING;

	if (type == prevcursor) return;

	switch(type) {
	case M_NOTHING:
		mdep_hidemouse();
		return;
	case M_CROSS:
		mousedata = cross_pointer;
		mouse_xoff = cross_xoff;
		mouse_yoff = cross_yoff;
		break;
	case M_SWEEP:
		mousedata = sweep_pointer;
		mouse_xoff = sweep_xoff;
		mouse_yoff = sweep_yoff;
		break;
	case M_LEFTRIGHT:
		mousedata = leftright_pointer;
		mouse_xoff = leftright_xoff;
		mouse_yoff = leftright_yoff;
		break;
	case M_UPDOWN:
		mousedata = updown_pointer;
		mouse_xoff = updown_xoff;
		mouse_yoff = updown_yoff;
		break;
	case M_ANYWHERE:
		mousedata = anywhere_pointer;
		mouse_xoff = anywhere_xoff;
		mouse_yoff = anywhere_yoff;
		break;
	case M_BUSY:
		mousedata = busy_pointer;
		mouse_xoff = busy_xoff;
		mouse_yoff = busy_yoff;
		break;
	case M_ARROW:
	default: 		
		mousedata = arrow_pointer;
		mouse_xoff = arrow_xoff;
		mouse_yoff = arrow_yoff;
		break;
	}
	mdep_showmouse();
}

void mdep_hidemouse()
{
	SetPointer(window, nomouse, 1, 1, 0, 0);
}

void mdep_showmouse()
{
	SetPointer(window, mousedata, MOUSE_HT, MOUSE_WD, mouse_xoff, mouse_yoff);
}

/*------------------------------------------------------------------------
 * fatal error - show an error message and exit.
 */

struct IntuiText hdrtext = { 3,1,JAM1,10,16,NULL,"keykit error!",NULL };
struct IntuiText fataltext = { 2,1,JAM1,10,32,NULL,NULL,&hdrtext };
struct IntuiText canceltext = { 0,1,JAM1,7,3,NULL,"Cancel",NULL };

void fatal(char *text)
{
	amimessage( text, "Oh well..." );
	mdep_bye();
}

void mdep_popup( char *str )
{
	if( strcmp( str, "\n" ) )
	{
		if( screen == NULL )
			printf( "%s\n", str );
		else
			(void)amimessage( str, NULL );
	}
}

int
amiask( char *str, char *prompt )
{
	struct EasyStruct es = {
		sizeof( struct EasyStruct ),
		0,
		"KeyKit Error",
		NULL,
		"Okay|Cancel",
	};

	es.es_TextFormat = str;
	es.es_GadgetFormat = prompt ? prompt : "Okay|Cancel";
	
	return( EasyRequest( window, &es, NULL, 0 ) );
}

int
amimessage( char *str, char *prompt )
{
	struct EasyStruct es = {
		sizeof( struct EasyStruct ),
		0,
		"KeyKit Error",
		NULL,
		"Okay",
	};

	es.es_TextFormat = str;
	es.es_GadgetFormat = prompt ? prompt : "Okay";
	
	return( EasyRequest( window, &es, NULL, 0 ) );
}

void mdep_abortexit( char *str )
{
	(void) amimessage( str, "Continue Exiting" );
	mdep_bye();
}

char *mdep_browse( char *prompt, char *pat, int cnt )
{
	struct FileRequester *fr;
	char *s = NULL;

	/* This will covert most *.somethings to #?.somethings */
	if( *pat == '*' || strchr( pat, ';' ) )
	{
		char npat[ 200 ], *t;
		char tpat[ 200 ];
		strcpy( tpat, pat );
		strcpy( npat, "#?.(" );
		for( t = strtok( tpat, ";" ); t; t = strtok( NULL, ";" ) )
		{
			if( *t == '*' && t[1] == '.' )
			{
				if( t != tpat )
					strcat( npat, "|" );
				strcat( npat, t+2 );
			}
		}
		strcat( npat, ")" );
		pat = npat;
	}

	if( fr = AllocFileRequest())
	{
		if( AslRequestTags( fr,
				ASL_Dir, *Keyroot,
				ASL_Window, window,
				ASL_Hail, prompt,
				ASLFR_DoPatterns, TRUE,
				ASLFR_RejectIcons, TRUE,
				ASLFR_InitialPattern, pat ? pat : "#?",
				ASL_FuncFlags, (ULONG)FILF_DOWILDFUNC,
				TAG_DONE) )
		{
			s = kmalloc( strlen( fr->rf_Dir ) + strlen( fr->rf_File ) + 4, "path-file buffer" );
			if( s )
			{
				strcpy( s, fr->rf_Dir );
				AddPart( s, fr->rf_File, -1 );
			}
		}
		FreeFileRequest( fr );
	}
	return( s );
}

/* Get the windows location */
int
mdep_screensize( int *oxp, int *oyp, int *cxp, int *cyp )
{
	*oxp = window->LeftEdge;
	*oyp = window->TopEdge;
	*cxp = window->Width;
	*cyp = window->Height;
	return 0;
}

/* Set the windows location */
int
mdep_screenresize( int ox, int oy, int cx, int cy )
{
	ChangeWindowBox( window, (long)ox, (long)oy, (long)cx, (long)cy );
	return 0;
}

int
mdep_waitfor(int tmout)
{
	struct Node *np;
	long mask;
	static long got;
	struct MsgPort *port;
	int n;
	long tm0;

	tm0 = milliclock();
	if ( tmout < *Millires ) {
		/* timeout is essentially 0, so don't block */
		
		if ( (n=checkmousekey(FALSE)) > 0 )
			return n;
		return K_TIMEOUT;
	}

	/* tmout is in milliseconds, createtimer needs microseconds */
	port = createtimer( tmout * 1000 );
	if ( port == 0 ) {
		char buf[100];
		sprintf(buf,"Unable to createtimer!? tmout=%ld",tmout);
		mdep_popup(buf);
	}

	mask =
		(1L<<window->UserPort->mp_SigBit)|
		(1L<<port->mp_SigBit)|
		(1L<<MidiInPort->mp_SigBit)|
		(1L<<MidiOutPort->mp_SigBit)|
		(1L<<rexxreply->mp_SigBit)|
		0;
	mask |= portmask;
	n = 0;
	while( n == 0 ) {
		if( ( n = checkmousekey( FALSE ) ) != 0 )
		{
			got &= ~(1L <<window->UserPort->mp_SigBit);
			canceltimer( );
			break;
		}

		/* Here is where we block, if ever. */
		got |= Wait( mask );

		if( got & (1L << rexxreply->mp_SigBit ) )
		{
			struct RexxMsg *rxmsg;
			got &= ~(1L << rexxreply->mp_SigBit );
			while( (rxmsg = (struct RexxMsg *)GetMsg(rexxreply) ) != NULL )
			{
				if( ARG0(rxmsg) ) DeleteArgstring( (UBYTE *)ARG0(rxmsg) );
				if( rxmsg->rm_Action & RXFF_RESULT )
				{
					if( rxmsg->rm_Result1 == 0 && rxmsg->rm_Result2 )
						DeleteArgstring( (UBYTE *)(rxmsg->rm_Result2) );
				}
				DeleteRexxMsg( rxmsg );
			}
		}

		if( ( got & (1L << port->mp_SigBit) ) || tmout == 0 )
		{
			got &= ~(1L << port->mp_SigBit);
			/* If timeout is 0, we want to get out after only */
			/* 1 check of the message queues. */
			n = K_TIMEOUT;
			GetMsg( port );
			break;
		}

		if( got & portmask )
		{
			n = K_PORT;
			canceltimer( );
			/* Move waiting ports to the ready list */
			for( np = waitio.lh_Head; np->ln_Succ; np = np->ln_Succ )
			{
				PORTHANDLE p;
				p = (PORTHANDLE )np;
				if( p->port && ( (1L << p->port->mp_SigBit) & got ) )
				{
					got &= ~(1L << p->port->mp_SigBit);
					Remove( np );
					AddTail( &readyio, np );
				}
			}
			break;
		}

		if( got & ( (1L << MidiInPort->mp_SigBit ) |
			  ( 1L << MidiOutPort->mp_SigBit ) ) )
		{
			/* Check if midi input there */
			if( got & (1L <<  MidiInPort->mp_SigBit ) )
				statmidi();
			got &= ~( (1L <<  MidiInPort->mp_SigBit ) |
					  (1L << MidiOutPort->mp_SigBit ) );
			n = K_MIDI;
			canceltimer( );
			break;
		}
	}
	freetimer( port );
	return n;
}

struct timerequest *trq;
struct MsgPort *
createtimer( long tval )
{
	struct MsgPort *tport;

	tport = CreateMsgPort();
	trq = (struct timerequest *)CreateExtIO( tport, sizeof( *trq ) );
	if( tport == NULL || trq == NULL )
	{
		goto allocerr;
	}

	if( OpenDevice( TIMERNAME, UNIT_VBLANK, (struct IORequest *)trq, 0L ) == 0 )
	{
		trq->tr_node.io_Command = TR_ADDREQUEST;
		trq->tr_time.tv_secs = tval/1000000;
		trq->tr_time.tv_micro = tval%1000000;

		SendIO( (struct IORequest *)trq );
		return( tport );
	}

allocerr:
	if( tport ) DeleteMsgPort( tport );
	if( trq ) DeleteExtIO( (struct IORequest *)trq );
	return( NULL );
}

void
canceltimer( )
{
	AbortIO( (struct IORequest *)trq );
	WaitIO( (struct IORequest *)trq );
}

void
freetimer( struct MsgPort *tport )
{
    CloseDevice( (struct IORequest *)trq );
    DeleteExtIO( (struct IORequest *) trq );
    DeleteMsgPort( tport );
}


PORTHANDLE *
open_rexx_port( register char *name, register char *mode, register char *type )
{
	PORTHANDLE *f;

	f = (PORTHANDLE *)kmalloc( sizeof( PORTHANDLE ) * 2, "rexx handle" );
	if( !f )
	{
		mdep_popup( "No memory for port structures" );
		return NULL;
	}

	f[0] = (PORTHANDLE)kmalloc( sizeof( PORTSTRUCT ), "rexx port 0" );
	if( !f[0] )
	{
		mdep_popup( "No memory for port structures" );
		return NULL;
	}
	f[1] = (PORTHANDLE)kmalloc( sizeof( PORTSTRUCT ), "rexx port 1" );
	if( !f[1] )
	{
		mdep_popup( "No memory for port structures" );
		return NULL;
	}
	f[0]->mate = f[1];
	f[1]->mate = f[0];

	f[0]->port = NULL;
	/* There is no message port for the write side of an AREXX port */
	f[1]->port = NULL;
	f[0]->node.ln_Name = NULL;
	f[1]->node.ln_Name = NULL;
	NewList( &f[0]->u.rexx.outstand );
	NewList( &f[1]->u.rexx.outstand );

	/* Send to an AREXX host and expect no replies */
	if( stricmp( type, "rexxhost-noreply" ) == 0 )
	{
		while( FindPort( name ) == NULL )
		{
			char buf[ 100 ];
			sprintf( buf, "Can't find AREXX host\n%s, what next?", name );
			if( amimessage( buf, "Try Again|Cancel" ) == 0 )
			{
				kfree( f[0] );
				kfree( f[1] );
				kfree( f );
				return NULL;
			}
		}
		strncpy( f[1]->u.rexx.host, name, sizeof( f[1]->u.rexx.host ) );
		f[1]->u.rexx.host[ sizeof( f[1]->u.rexx.host ) - 1 ] = 0;
		f[1]->type = MDPORT_REXX;
		f[1]->node.ln_Name = strdup( name );

		/* This port can not be read from. */
		f[0]->type = MDPORT_NONE;
	}
	/* Send to an AREXX host and expect replies */
	else if( stricmp( type, "rexx" ) == 0 )
	{
		while( FindPort( name ) == NULL )
		{
			char buf[ 100 ];
			sprintf( buf, "Can't find AREXX host %s,\nwhat next?", name );
			if( amimessage( buf, "Try Again|Cancel" ) == 0 )
			{
				kfree( f[0] );
				kfree( f[1] );
				kfree( f );
				return NULL;
			}
		}

		/* Create the reply port structure */
		if( ( f[0]->port = CreateMsgPort() ) == NULL )
		{
			kfree( f[0] );
			kfree( f[1] );
			kfree( f );
			mdep_popup( "No memory for port structures" );
		}
		portmask |= (1L << f[0]->port->mp_SigBit );

		strncpy( f[0]->u.rexx.host, name, sizeof( f[0]->u.rexx.host ) );
		f[0]->u.rexx.host[ sizeof( f[0]->u.rexx.host ) - 1 ] = 0;

		strncpy( f[1]->u.rexx.host, name, sizeof( f[1]->u.rexx.host ) );
		f[1]->u.rexx.host[ sizeof( f[1]->u.rexx.host ) - 1 ] = 0;

		f[0]->node.ln_Name = strdup( name );
		f[1]->node.ln_Name = strdup( name );
		f[0]->type = MDPORT_RREPLY;
		f[1]->type = MDPORT_REXX;
	}
	/* Create an AREXX host */
	else if( stricmp( type, "rexxhost" ) == 0 )
	{
		char *portname, *ext;

		portname = strtok( name, ":" );
		ext = strtok( NULL, ":" );
		if( FindPort( portname ) != NULL )
		{
			char buf[ 100 ];
			sprintf( buf, "AREXX host %s, already exists!!", portname );
			mdep_popup( buf );
			kfree( f[0] );
			kfree( f[1] );
			kfree( f );
			return NULL;
		}
		if( ( f[0]->port = CreatePort( portname, 0 ) ) == NULL )
		{
			kfree( f[0] );
			kfree( f[1] );
			kfree( f );
			mdep_popup( "no memory for port structures" );
			return NULL;
		}
		*f[0]->u.rexx.ext = 0;
		portmask |= (1L << f[0]->port->mp_SigBit );
		if( ext )
		{
			strncpy( f[0]->u.rexx.ext, ext, sizeof( f[0]->u.rexx.ext ) );
			f[0]->u.rexx.ext[ sizeof( f[0]->u.rexx.ext ) - 1 ] = 0;
		}
		f[0]->node.ln_Name = strdup( name );
		f[0]->type = MDPORT_HOST;
		f[1]->type = MDPORT_WREPLY;
	}

	AddHead( &waitio, &f[0]->node );
	AddHead( &waitio, &f[1]->node );

	return( f );
}

union printerio {
	struct IOStdReq ios;
	struct IODRPReq iodrp;
	struct IOPrtCmdReq iopc;
};

PORTHANDLE *
open_device_port( char *name, char *mode, char *type )
{
	struct MsgPort *rport;
	char *t, *s, *up, *fp, *mp;
	int unit, mmode;
	long flags, size;
	PORTHANDLE *p;

	p = (PORTHANDLE *)kmalloc( 2 * sizeof( *p ), "open device port" );
	if( !p )
	{
		mdep_popup( "no memory for ports" );
		return NULL;
	}
	p[0] = (PORTHANDLE)kmalloc( sizeof( *(p[0]) ), "device handle 0" );
	if( !p[0] )
	{
		mdep_popup( "no memory for ports" );
		return NULL;
	}

	p[1] = (PORTHANDLE)kmalloc( sizeof( *(p[1]) ), "device handle 1" );
	if( !p[1] )
	{
		mdep_popup( "no memory for ports" );
		return NULL;
	}

	s = strdup( name );
	t = strtok( name, ":" );
	up = strtok( NULL, ":" );
	if( up == NULL )
		unit = 0;
	else
		unit = atoi( up );
	fp = strtok( NULL, ":" );
	if( fp == NULL )
		flags = 0;
	else
		flags = atol( fp );

	mp = strtok( NULL, ":" );
	if( mp == NULL )
		mmode = IOMODE_STREAM;
	else
	{
		mmode = IOMODE_STREAM;
		if( strcmp( mp, "raw" ) == 0 )
			mmode = IOMODE_RAW;
		else if( strcmp( mp, "stream" ) == 0 )
			mmode = IOMODE_STREAM;
		else if( strcmp( mp, "lines" ) == 0 )
			mmode = IOMODE_LINES;
	}

	if( strcmp( t, "serial.device" ) == 0 )
		size = sizeof( struct IOExtSer );
	else if( strcmp( t, "console.device" ) == 0 )
		size = sizeof( struct IOStdReq );
	else if( strcmp( t, "clipboard.device" ) == 0 )
		size = sizeof( struct IOClipReq );
	else if( strcmp( t, "gameport.device" ) == 0 )
		size = sizeof( struct IOStdReq );
	else if( strcmp( t, "input.device" ) == 0 )
		size = sizeof( struct IOStdReq );
	else if( strcmp( t, "parallel.device" ) == 0 )
		size = sizeof( struct IOExtPar );
	else if( strcmp( t, "printer.device" ) == 0 )
		size = sizeof( union printerio );
	else
		size = sizeof( struct IOStdReq );

	if( ( rport = CreateMsgPort() ) == NULL )
	{
		free( s );
		kfree( p[0] );
		kfree( p[1] );
		kfree( p );
		return( NULL );
	}

	p[0]->port = rport;
	p[1]->port = rport;
	if( ( p[0]->u.dev.ioreq = CreateIORequest( rport, size ) ) == NULL )
	{
		DeleteMsgPort( rport );
		free( s );
		kfree( p[0] );
		kfree( p[1] );
		kfree( p );
		return( NULL );
	}

	if( ( p[1]->u.dev.ioreq = CreateIORequest( rport, size ) ) == NULL )
	{
		DeleteIORequest( p[0]->u.dev.ioreq );
		DeleteMsgPort( rport );
		free( s );
		kfree( p[0] );
		kfree( p[1] );
		kfree( p );
		return( NULL );
	}

	if( OpenDevice( t, unit, (struct IORequest *)p[0]->u.dev.ioreq, flags ) != 0 )
	{
		DeleteIORequest( p[0]->u.dev.ioreq );
		DeleteIORequest( p[1]->u.dev.ioreq );
		DeleteMsgPort( rport );
		free( s );
		kfree( p[0] );
		kfree( p[1] );
		kfree( p );
		return( NULL );
	}

	free( s );

	p[0]->type = MDPORT_RDEVICE;
	p[1]->type = MDPORT_WDEVICE;
	p[0]->mode = mmode;
	p[1]->mode = mmode;

	/* Make the READ and write side identical */
	memcpy( p[1]->u.dev.ioreq, p[0]->u.dev.ioreq, size );

	return p;
}

PORTHANDLE  *
mdep_openport( register char *name, register char *mode, register char *type )
{
	static PORTHANDLE *p;
	if( strnicmp( type, "rexx", 4 ) == 0 )
		p = open_rexx_port( name, mode, type );
	else if( strcmp( type, "device" ) == 0 )
		p = open_device_port( name, mode, type );
	else
	{
		sprintf( Msg1, "unknown port type: %s\ncan not open port to/from\n%s", type, name );
		mdep_popup( Msg1 );
		p = NULL;
	}

	return( p );
}

mdep_closeport( register PORTHANDLE f )
{
	register struct RexxMsg *rxmsg;

	if( !f ) return( -1 );

	Forbid();
	switch( f->type )
	{
	case MDPORT_WREPLY:
		while( rxmsg = (struct RexxMsg *)RemHead( &f->u.rexx.outstand ) )
		{
			rxmsg->rm_Result1 = 5;
			ReplyMsg( (struct Message *)rxmsg );
		}
		break;

	case MDPORT_HOST:
		/* Flush all messages from port. */
		while( rxmsg = (struct RexxMsg *)GetMsg( f->port ) )
		{
			if( rxmsg->rm_Action & RXFF_RESULT )
			{
				rxmsg->rm_Result1 = 20;
				rxmsg->rm_Result2 = (ULONG) CreateArgstring( "Host shut down", 14 );
				ReplyMsg( (struct Message *)rxmsg );
			}
			else
			{
				if( ARG0( rxmsg ) ) DeleteArgstring( (UBYTE *) ARG0( rxmsg ) );
				DeleteRexxMsg( rxmsg );
			}
		}
		portmask &= ~(1L << f->port->mp_SigBit );
		if( f->port ) DeletePort( f->port );

		/* Take it out of the list that it is in */
		Remove( &f->node );
		break;

	case MDPORT_RREPLY:
		if( f->port )
		{
			while( rxmsg = (struct RexxMsg *)GetMsg( f->port ) )
			{
				if( rxmsg->rm_Action & RXFF_RESULT )
				{
					if( rxmsg->rm_Result1 == 0 && rxmsg->rm_Result2 )
						DeleteArgstring( (UBYTE *)(rxmsg->rm_Result2) );
				}
				if( ARG0( rxmsg ) ) DeleteArgstring( (UBYTE *) ARG0( rxmsg ) );
				DeleteRexxMsg( rxmsg );
			}
			portmask &= ~(1L << f->port->mp_SigBit );
		}
		if( f->port ) DeleteMsgPort( f->port );

		/* Take it out of the list that it is in */
		Remove( &f->node );
		break;
	case MDPORT_WDEVICE:
	case MDPORT_RDEVICE:
		if( CheckIO( (struct IORequest *) f->u.dev.ioreq ) )
		{
			AbortIO( (struct IORequest *) f->u.dev.ioreq );
			WaitIO( (struct IORequest *) f->u.dev.ioreq );
		}

		/* Only one side of the port can free all these resources on close */
		if( f->type == MDPORT_WDEVICE )
		{
			CloseDevice( (struct IORequest *) f->u.dev.ioreq );
			DeleteMsgPort( f->port );
		}
		DeleteExtIO( (struct IORequest *) f->u.dev.ioreq );
		break;
	}

	Permit();

	/* Free other general data */
	if( f->node.ln_Name ) free( f->node.ln_Name );
	free( f );

	return( 0 );
}

int
mdep_getportdata( register PORTHANDLE *f, register char *buf, register unsigned size )
{
	register long v;
	register PORTHANDLE h;

	/* Rotate the ready data so that everybody gets a chance no matter how
	 * much data any one port is getting
	 */
	h = (PORTHANDLE )RemHead( &readyio );
	if( !h )
		return(-1);

	AddTail( &readyio, &h->node );

	*f = h;
	switch( h->type )
	{
	case MDPORT_HOST:
	case MDPORT_RREPLY:
		v = mdep_readarexx( h, buf, size );
		break;
	case MDPORT_RDEVICE:
		v = mdep_readdevice( h, buf, size );
		break;
	default:
		v = -1;
		break;
	}

	/* If nothing to read, put port back on waiting list */
	if( v == -1 )
	{
		Remove( &h->node );
		AddTail( &waitio, &h->node );
	}
	return( v );
}

long
mdep_readdevice( PORTHANDLE f, char *buf, unsigned size )
{
	char *cbuf;

	switch( f->type )
	{
	case MDPORT_RDEVICE:
		if( ( cbuf = AllocMem( size, MEMF_CHIP ) ) != NULL )
		{
			f->u.dev.ioreq->io_Command = CMD_READ;
			f->u.dev.ioreq->io_Length = size;
			f->u.dev.ioreq->io_Data = cbuf;
			DoIO( (struct IORequest *)f->u.dev.ioreq );
			memcpy( buf, cbuf, size );
			FreeMem( cbuf, size );
			if( f->u.dev.ioreq->io_Error == 0 )
				return( (long)f->u.dev.ioreq->io_Actual );
			return( -1 );
		}
		break;
	}
	return( -1 );
}

long
mdep_readarexx( register PORTHANDLE f, register char *buf, register unsigned size )
{
	register struct RexxMsg *rxmsg;
	register long ret = -1;

	if( (rxmsg = (struct RexxMsg *) GetMsg( f->port )) && rxmsg->rm_Result1 == 0 )
	{
		if( f->type == MDPORT_HOST )
		{
			int len = strlen( ARG0( rxmsg ) );
			ret = min( size-1, len + 1 );
			memcpy( buf, ARG0( rxmsg ), ret );
			buf[ret] = 0;
			strcat( buf, "\n" );
		}
		else if( f->type == MDPORT_RREPLY )
		{
			if( rxmsg->rm_Result1 == 0 )
			{
				int len = strlen( (char *)rxmsg->rm_Result2 );
				strncpy( buf, (char *)rxmsg->rm_Result2, size );
				ret = min( size, len );
			}
			else
			{
				sprintf( buf, "Failed: %d\n", rxmsg->rm_Result1 );
				ret = strlen( buf );
			}
		}
	}

	if( rxmsg )
	{
		/*ret = rxmsg->rm_Result1;*/

		/* If the message is from a REXX client to this host, don't reply to it yet */
		if( f->type == MDPORT_HOST )
		{
			/* Put the response in the list for later replies */
			AddTail( &f->mate->u.rexx.outstand, &rxmsg->rm_Node.mn_Node );
		}
		else
		{
			if( ARG0(rxmsg) ) DeleteArgstring( (UBYTE *)ARG0( rxmsg ) );
			if( f->type == MDPORT_RREPLY && rxmsg->rm_Result2 && rxmsg->rm_Result1 == 0 )
				DeleteArgstring( (UBYTE *)rxmsg->rm_Result2 );
		}
	}
	else
		ret = -1;

	return( ret );
}

long
mdep_writearexx( register PORTHANDLE f, register char *buf, register unsigned size )
{
	Fifo *p;
	register struct RexxMsg *rxmsg;
	register struct MsgPort *port, *rport;

	/* If this is the reply side of a host port, get the message to reply */
	if( f->type == MDPORT_WREPLY )
	{
		if( ( rxmsg = (struct RexxMsg *)RemHead( &f->u.rexx.outstand ) ) == NULL )
			return -1;

		if( rxmsg->rm_Action & RXFF_RESULT )
		{
			if( size == 0 )
				rxmsg->rm_Result1 = 5;
			else
			{
				buf[size] = 0;
				if( p = port2fifo(f) )
				{
					if( p->fifoctl_type & FIFO_LINE && strchr( buf, '\n' ) == NULL )
						buf[size++] = '\n';
				}
				rxmsg->rm_Result1 = 0;
				rxmsg->rm_Result2 = (ULONG) CreateArgstring( buf, size );
			}
		}
		else
		{
			if( size == 0 )
				rxmsg->rm_Result1 = 0;
			else
			{
				int i = atoi( buf );
				if( i != 0 || isdigit( *buf ) )
					rxmsg->rm_Result1 = i;
				else
				{
					char buf1[ 300 ];

					rxmsg->rm_Result1 = 5;
					sprintf( buf1, "REXX PORT would have returned %.*s,\nexpecting a number, returning\nthe value of 5 instead!", size, buf );

					mdep_popup( buf1 );
				}
			}
		}
			
		ReplyMsg( (struct Message *)rxmsg );
		return( (long)size );
	}

	/* Should be MDPORT_REXX if we make it to here */

	if( ( rport = f->mate->port ) == NULL )
		rport = rexxreply;
	rxmsg = CreateRexxMsg( rport, "", "" );

	if( ( rxmsg == NULL ) ||
		( ARG0( rxmsg ) = CreateArgstring( buf, size ) ) == NULL )
	{
		Permit();
		if( rxmsg ) DeleteRexxMsg( rxmsg );
		mdep_popup( "Not enough memory to send AREXX message" );
		return( -1 );
	}
	rxmsg->rm_Action = RXFUNC;
	if( f->mate->type == MDPORT_RREPLY )
		rxmsg->rm_Action |= RXFF_RESULT;

	rxmsg->rm_Result1 = 0;
	rxmsg->rm_Result2 = 0;
	ARG1( rxmsg ) = 0;

	Forbid();
	while( ( port = FindPort( f->u.rexx.host ) ) == NULL )
	{
		char buf[ 100 ];
		sprintf( buf, "Can't find AREXX host %s,\nwhat next?", f->u.rexx.host );
		if( amimessage( buf, "Try Again|Cancel" ) == 0 )
		{
			Permit();
			DeleteArgstring( (UBYTE *)ARG0(rxmsg) );
			DeleteRexxMsg( rxmsg );
			return -1;
		}
	}
	PutMsg( port, (struct Message *)rxmsg );
	Permit();
	return( (int)size );
}

long
mdep_writedevice( register PORTHANDLE f, register char *buf, register unsigned size )
{
	char *cbuf;

	switch( f->type )
	{
	case MDPORT_WDEVICE:
		if( ( cbuf = AllocMem( size, MEMF_CHIP ) ) != NULL )
		{
			memcpy( cbuf, buf, size );
			f->u.dev.ioreq->io_Command = CMD_WRITE;
			f->u.dev.ioreq->io_Length = size;
			f->u.dev.ioreq->io_Data = cbuf;
			DoIO( (struct IORequest *)f->u.dev.ioreq );
			FreeMem( cbuf, size );
			return( (long)size );
		}
		break;
	}
	return( -1 );
}

long
mdep_putportdata( register PORTHANDLE f, register char *buf, register unsigned size )
{
	register long v;

	switch( f->type )
	{
	case MDPORT_HOST:
	case MDPORT_WREPLY:
	case MDPORT_REXX:
		v = mdep_writearexx( f, buf, size );
		break;
	case MDPORT_WDEVICE:
		v = mdep_writedevice( f, buf, size );
		break;
	default:
		v = -1;
		break;
	}
	return( v );
}

Datum
mdep_ctlport(PORTHANDLE m, char *cmd, char *arg)
{
	Fifo *f;
	int old;

	if( m && ( f = port2fifo(m) ) )
	{
		if( stricmp( cmd, "mode" ) == 0 )
		{
			old = f->fifoctl_type;
			f->fifoctl_type = fifoctl2type(arg,FIFO_BINARY);
			return(numdatum(old));
		}
	}
	return Noval;	/* we don't handle this ctl */
}

Datum
mdep_mdep(int argc)
{
	char buf[300];
	char *vals[10];
	char *cmd1, *cmd2;

	if( argc < 1 )
		execerror("Too few arguments for mdep_mdep!\n");
		
	cmd1 = needstr("mdep",ARG(0));
	if ( strcmp(cmd1,"popup") == 0 ) {
		if( argc != 2 )
			execerror("Too many arguments for mdep_mdep(\"popup\")!\n");
		cmd2 = needstr("mdep",ARG(1));
		mdep_popup(cmd2);
		return(strdatum(uniqstr("yes")));
	}
	else if ( strcmp(cmd1, "readargs") == 0 ) {
		Htablep arr;
		Symbolp as;
		char *t, *cmd, *line, *fmt;
		Datum d, da, mda;
		Htablep rarr, marr;
		struct RDArgs *parmargs, *retargs;
		long *argsarr[ 10 ];
		int i;

		if( argc != 3 )
			execerror("Incorrect arguments for mdep(\"readargs\")!\n");

		line = needstr("mdep(readargs)",ARG(1));
		arr = needarr("mdep(readargs)",ARG(2));
		line = strdup( line );
		cmd = strtok( line, " " );
		t = strtok( (char *)NULL, "\n" );

		as = arraysym( arr, strdatum( uniqstr( cmd ) ), H_LOOK );
		if( as == NULL )
			execerror("template not found for %s in mdep(\"readargs\")!\n", cmd );

		d = (*symdataptr(as));
		if ( d.type != D_STR )
		{
			sprintf( buf, "template not string for %s in mdep(\"readargs\")!\n", cmd );
			execerror( buf );
		}

		sprintf( buf, "%s\n", t );
		parmargs = AllocDosObject( DOS_RDARGS, NULL );
		parmargs->RDA_Source.CS_Buffer = buf;
		parmargs->RDA_Source.CS_Length = strlen( buf );
		parmargs->RDA_Source.CS_CurChr = 0;
		parmargs->RDA_Flags = RDAF_NOPROMPT;

		memset( argsarr, 0, sizeof( argsarr ) );
		fmt = strdup( d.u.str );
		if( ( retargs = ReadArgs( fmt, (long *)argsarr, parmargs ) ) == NULL )
		{
			long err = IoErr();

			Fault( err, "Parse Error", buf, sizeof( buf ) );
			FreeArgs( parmargs );
			FreeDosObject( DOS_RDARGS, parmargs );
			execerror( buf );
		}

		da = newarrdatum(0,0);
		rarr = da.u.arr;
		memset(vals, 0, sizeof(vals ) );
		for( i = 0, t = strtok( fmt, "," ); t && i < 10; ++i, t = strtok( NULL, "," ) )
			vals[i] = t;
		for( i = 0; i < 10; ++i )
		{
			char *p, *sp;
			int found, j;

			sp = p = strchr( vals[i], '/' );
			if( !p )
				continue;
			++p;
			found = 0;
			while( !found && *p )
			{
				Datum tda;

				found = 1;
				tda = numdatum(i);

				switch( *p )
				{
				case 'a': case 'A':
					/*
					 * If a is not the only argument type specifier, then honor
					 * that type specifier.  Otherwise just store a string.
					 */
					if( p[1] != 0 || p >= sp + 2 )
					{
						found = 0;
						break;
					}
				case 'k': case 'K':
				case 'f': case 'F':
					setarrayelem( rarr, i, (char *)argsarr[i]);
					break;
				case 's': case 'S':
				case 't': case 'T':
					setarraydata( rarr, tda, numdatum((long)argsarr[i]) );
					break;
				/* This is an array, so... */
				case 'm': case 'M':
					mda = newarrdatum(0,0);
					setarraydata( rarr, tda, mda );
					marr = mda.u.arr;
					for( j = 0; argsarr[i][j]; ++j )
						setarrayelem( marr, j, (char *)argsarr[i][j] );
					break;
				case 'n': case 'N':
					setarraydata( rarr, tda, numdatum(*argsarr[i]) );
					break;
				case '/':
					break;
				default:
					setarraydata( rarr, tda, numdatum((long)argsarr[i]) );
					break;
				}
				++p;
			}
		}
		FreeArgs( parmargs );
		FreeDosObject( DOS_RDARGS, parmargs );
		return( da );
	}
	return(Noval);
}
