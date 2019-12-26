/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

/*
 * Amiga code for keykit
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <signal.h>
#include <setjmp.h>
#include <math.h>

#include <dos/dos.h>
#include <dos.h>
#include <exec/exec.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/graphics.h>

extern int errno;
#include "d_amtimer.h"
#include "d_ammain.h"

#undef	GLOBAL
#undef	NOT

#define MACHINE		"amiga"
#define MILLICLOCK	TimeCounter
#define RTSTART		realstart()
#define RTEND		realend()
#define DEFKEYPATH	";keykit:lib;keykit:music"
#define DEFTMPDIR	"keykit:tmp"	/* don't put this in RAM: or it	*/
					/* defeats the purpose!		*/
#define PATHNAME(d,f,r)	amigapath(d,f,r)
#define CORELEFT	mdep_coreleft()
#define MAIN(ac,av)	keymain(ac,av)
#define GRAPHABLE	1
#define MIDIABLE	1
#define PROTOTYPES	1
#define GRAPHABLE		1
#define MOVEBITMAP	1
#define LINETRACK	1
#define BOXFILLISFASTER	1

/* allow ctrl-c checks during execute() */
#define KEYCHECK	if (statconsole()) getconsole()

/* I can't get pipes to work consistently.  If you want to try them,	*/
/* remove the comments from the next line and change the makefile to	*/
/* compile and link am-pipes.c with key.  This also requires ARP.	*/
/* #define PIPES	1 */

/* we don't bother with M5 stuff in keykit, but mftokey needs it.	*/
#ifndef BAREMINIMUM
#define NOM5		1
#endif

extern volatile long __far TimeCounter;
extern char *currdir;

void realstart(void);
void realend(void);
long mdep_coreleft(void);
void fatal(char*);

#ifdef PIPES
FILE *popen(char*,char*);
#endif

#define	Debug Key_Debug
#define MAXLONG 0x7fffffff
#define DEFKEYROOT	"keykit"
#define SEPARATOR ","

typedef	void (*SIGFUNCTYPE)(int);
extern void intcatch( void );
#define	changedir(x)	chdir(x)

#define	_MAX_PATH	1024

typedef	enum {
	MDPORT_NONE,		/* Port does not support a particular I/O direction or I/O at all */
	MDPORT_REXX,		/* Write to some other AREXX host's port */
	MDPORT_HOST,		/* KeyKit owned AREXX host port */
	MDPORT_RREPLY,		/* Reply port for a MDPORT_REXX port that sends back data results */
	MDPORT_WREPLY,		/* Port for replies from a MDPORT_HOST port */
	MDPORT_RDEVICE,		/* Read port for an EXEC device (CONSOLE, parallel etc) */
	MDPORT_WDEVICE,		/* Write port for an EXEC device (CONSOLE, parallel etc) */
} PORTTYPE;

typedef struct PORTSTRUCT
{
	struct Node node;			/* Placed on waiting or ready list */
	PORTTYPE type;				/* What type of port is this? */
	struct MsgPort *port;		/* exec I/O message port or arexx port etc. */
	char mode;					/* I/O mode to use */
	struct PORTSTRUCT *mate;
	union {
		struct {
			char host[ 40 ];
			char ext[ 10 ];
			struct List outstand;		/* Messages which have not been replied too. */
		} rexx;
		struct {
			struct IOStdReq *ioreq;	/* request structure for device io */
		} dev;
	} u;
} PORTSTRUCT, *PORTSPTR;

#define PORTHANDLE PORTSPTR

#define IOMODE_RAW		1
#define IOMODE_STREAM	2
#define IOMODE_LINES	3
