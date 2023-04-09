/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#include <stdio.h>
#ifdef __STDC__
#include <stdlib.h>
#endif
#include <stdarg.h>
#include <unistd.h>
#include <string.h>
#include <values.h>
#include <setjmp.h>
#include <errno.h>

extern int sys_nerr;
extern char *sys_errlist[];

#define MACHINE "unix"	/* default value of keykit's Machine variable */

#define LINETRACK
#define MOVEBITMAP

#define BOXFILLISFASTER

#define NOBROWSESUPPORT

#ifdef __STDC__
typedef void (*SIGFUNCTYPE)();
#define CONST const
#else
typedef int (*SIGFUNCTYPE)();
#define CONST
#endif

#define PORTHANDLE Myporthandle

typedef struct myportinfo *Myporthandle;

#ifndef _MAX_PATH
#define _MAX_PATH 256
#endif
