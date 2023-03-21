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
#include <limits.h>
#ifndef MAXLONG
#define MAXLONG LONG_MAX	/* Posix compatible */
#endif
#include <setjmp.h>
#include <errno.h>
#include <inttypes.h>


#define MACHINE "linux"	/* default value of keykit's Machine variable */

/* GCC function attribute indicating a function does not return */
#define NO_RETURN_ATTRIBUTE __attribute__((__noreturn__))

#define MDEP_MIDI_PROVIDED

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
