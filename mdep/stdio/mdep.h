/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#define MACHINE "stdio"	/* value of keykit's Machine variable */

#include <stdio.h>
#ifdef __STDC__
#include <stdlib.h>
#endif
#include <stdarg.h>
#include <unistd.h>
#include <string.h>
#ifdef __FreeBSD__
# include <limits.h>
#else
# include <values.h>
#endif
#include <setjmp.h>
#include <errno.h>

#if !(defined(__FreeBSD__) || defined(linux))
extern int sys_nerr;
extern char *sys_errlist[];
#endif

/* GCC function attribute indicating a function does not return */
#define NO_RETURN_ATTRIBUTE __attribute__((__noreturn__))

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

#define SEPARATOR "/"
#define PATHSEP ":"

#ifdef __STDC__
typedef void (*SIGFUNCTYPE)();
#define CONST const
#else
typedef int (*SIGFUNCTYPE)();
#define CONST
#endif

#ifndef _MAX_PATH
#define _MAX_PATH 256
#endif

#define PORTHANDLE int
