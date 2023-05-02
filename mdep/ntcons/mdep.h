/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#define MACHINE "stdio"	/* value of keykit's Machine variable */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
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

#ifndef MAXLONG
#define MAXLONG LONG_MAX
#endif

#define LINETRACK

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

typedef void (*SIGFUNCTYPE)(int);

#define PORTHANDLE int

#define PATHSEP ";"
#define SEPARATOR "\\"

#define unlink _unlink
#define strcasecmp _stricmp
