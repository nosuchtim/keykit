/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#define MACHINE "win"	/* value of keykit's Machine variable */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <setjmp.h>
#include <conio.h>
#include <limits.h>
#include <stdarg.h>

#ifndef DONTDEBUG
#include <crtdbg.h>
#endif

#ifndef MAXLONG
#define MAXLONG LONG_MAX
#endif

#define MOVEBITMAP

#define MAIN(ac,av) keymain(ac,av)

#define OPENFILE(f,name,mode,binmode) {char m[3]; \
	m[0] = mode[0]; \
	m[1] = binmode; \
	m[2] = '\0'; \
	f = fopen(name,m);}

#define OPENBINFILE(f,name,mode) OPENFILE(f,name,mode,'b');
#define OPENTEXTFILE(f,name,mode) OPENFILE(f,name,mode,'t');

#define ALLOCNT 1000

#define STACKSIZE 512
#define ARRAYHASHSIZE 503
#define STRHASHSIZE 503
#define PATHSEP ";"

typedef void (*SIGFUNCTYPE)(int);

typedef struct myportinfo *Myporthandle;

#define PORTHANDLE Myporthandle
#define SEPARATOR "\\"

#define MDEP_MIDI_PROVIDED

#define MDEP_OSC_SUPPORT
