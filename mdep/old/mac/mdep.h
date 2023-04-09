/*
 *	Copyright (c) 1984, 1985, 1986, 1987, 1988 AT&T
 *	All Rights Reserved
 *
 *	THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF AT&T.
 *
 *	The copyright notice above does not evidence any actual
 *	or intended publication of such source code.
 */

#define MACHINE 	"mac"	// value of keynote's Machine variable
#define PATHSEP 	";"		// path separator: i.e. :usr:lib;:usr:include
#define PATHCDstr	":"		// sub-directory character: i.e. usr/lib => usr:lib on the Mac
#define PATHCDchar	':'		// single character version
#define SEPARATOR	PATHCDstr

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <errno.h>
#include <string.h>
#include <signal.h>
#include <setjmp.h>
#include <limits.h>
#include <stdarg.h>
#include <QDOffscreen.h>
#include <unix.h>
#include <profiler.h>

#ifndef _MAX_PATH
#define _MAX_PATH 132
#endif

extern char			*path;
extern DialogPtr	popupDialog;
extern char			keyPath[];
extern char			musicPath[];
extern WindowPtr	theWindow;
extern char			filename[_MAX_PATH], theScript[80];
extern Cursor		cross;						/* The cross cursor */
extern Cursor		ibeam;						/* The i-beam cursor */
extern Cursor		watch;						/* The watch cursor */
extern char			theChar;
extern long			keykitstart;				// when keykit started

#define PORTHANDLE char *

// Prototypes
void SetUpMenus(void);
#ifndef MAXLONG
#define MAXLONG LONG_MAX
#endif

#define MAIN(ac,av) keymain(ac,av)

#define MOVEBITMAP 1

#define DEMOTIMEOUT 0

#define PROFILE 0

typedef void (*SIGFUNCTYPE)(int);

#define MDEP_MALLOC
char	*mdep_malloc	(unsigned int s, char *tag);
void	mdep_free		(char *s);
#define kmalloc(x,tag)	mdep_malloc	(x,tag)
#define kfree(x)		mdep_free((char *)(x))
//#define kfree(x)		myfree	((char *)(x))
