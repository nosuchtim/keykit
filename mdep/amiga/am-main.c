/*      _main.c         Copyright (C) 1985  Lattice, Inc.       */
/*	modified for keykit startup				*/

#include <stdio.h>
#include <fcntl.h>
#include <ios1.h>
#include <string.h>
#include <stdlib.h>
#include <workbench/startup.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>
#include <proto/dos.h>
#include <proto/exec.h>

#define MAXARG 32              /* maximum command line arguments */
#define QUOTE  '"'
#define ESCAPE '*'
#define ESC '\027'
#define NL '\n'

#define isspace(c)      ((c == ' ')||(c == '\t') || (c == '\n'))

#ifndef TINY
extern int _CXBRK();
#endif

static int argc;                       /* arg count */
static char **targv, *argv[MAXARG];     /* arg pointers */
static void badarg(char *program);

#define MAXWINDOW 40
extern struct WBStartup *WBenchMsg;
/**
*
* name         _main - process command line, open files, and call "main"
*
* synopsis     _main(line);
*              char *line;     ptr to command line that caused execution
*
* description   This function performs the standard pre-processing for
*               the main module of a C program.  It accepts a command
*               line of the form
*
*                       pgmname arg1 arg2 ...
*
*               and builds a list of pointers to each argument.  The first
*               pointer is to the program name.  For some environments, the
*               standard I/O files are also opened, using file names that
*               were set up by the OS interface module XCMAIN.
*
*	MODIFIED FOR KEYKIT:  Use NEWCON and larger window, allow
*	KEYWINDOW environment variable to override window specs.
*
**/
void _main(line)
register char *line;
{
	struct UFB *ufb;
	register char **pargv;
	register int x;
	struct Process *process;
	struct FileHandle *handle;
	static char window[MAXWINDOW+18];
	char *argbuf;

	/*
	 *
	 * Build argument pointer list
	 *
	 */

	while (argc < MAXARG)
	{
		while (isspace(*line))  line++;
		if (*line == '\0')      break;
		pargv = &argv[argc++];
		if (*line == QUOTE)
		{
			argbuf = *pargv = ++line;  /* ptr inside quoted string */
			while (*line != QUOTE)
			{
				if (*line == ESCAPE)
				{
					line++;
					switch (*line)
					{
					case 'E':
						*argbuf++ = ESC;
						break;
					case 'N':
						*argbuf++ = NL;
						break;
					default:
						*argbuf++ = *line;
					}
					line++;
				}
				else
				{
					*argbuf++ = *line++;
				}
			}
			line++;
			*argbuf++ = '\0';	/* terminate arg */
		}
		else /* non-quoted arg */
		{
			*pargv = line;
			while ((*line != '\0') && (!isspace(*line))) line++;
			if (*line == '\0')  break;
			else *line++ = '\0';  /* terminate arg */
		}
	}  /* while */
	targv = (argc == 0) ? (char **)WBenchMsg : (char **)&argv[0];


	/*
	 *
	 * Open standard files
	 *
	 */
#ifndef TINY
	if (argc == 0)          /* running under workbench      */
	{
		struct UFB *ufb, *ifb;
		/* get window spec from environment */
		if (getenv("KEYWINDOW") == NULL) {
			strcpy(window, "newcon:0/10/640/190/KeyKit");
		} else {
			strncpy(window, getenv("KEYWINDOW"), MAXWINDOW);
		}
		/* strncat(window, WBenchMsg->sm_ArgList->wa_Name,MAXWINDOW); */
		freopen( stdin, window, "r+" );
		freopen( stdout, "*", "r+" );
		freopen( stderr, "*", "r+" );
		ifb = chkufb(0);
#if 0
		ifb->ufbfh = Open(window,MODE_NEWFILE);
		ufb = chkufb(1);
		ufb->ufbfh = ifb->ufbfh;
		ufb->ufbflg = UFB_NC;
		ufb = chkufb(2);
		ufb->ufbfh = ifb->ufbfh;
		ufb->ufbflg = UFB_NC;
#endif
		handle = (struct FileHandle *)(ifb->ufbfh << 2);
		process = (struct Process *)FindTask(0);
		process->pr_ConsoleTask = (APTR)handle->fh_Type;
		x = 0;
	}
	else /* running under CLI            */
	{
		ufb = chkufb(0);
		ufb->ufbfh = Input();
		ufb = chkufb(1);
		ufb->ufbfh = Output();
		ufb = chkufb(2);
		ufb->ufbfh = Open("*", MODE_OLDFILE);
		x = UFB_NC;                     /* do not close CLI defaults    */
	}

	ufb = chkufb(0);
	ufb->ufbflg |= UFB_RA | O_RAW | x;
	ufb = chkufb(1);
	ufb->ufbflg |= UFB_WA | O_RAW | x;
	ufb = chkufb(2);
	ufb->ufbflg |= UFB_RA | UFB_WA | O_RAW;

	x = 0;
	stdin->_file = 0;
	stdin->_flag = _IOREAD | x;
	stdout->_file = 1;
	stdout->_flag = _IOWRT | x;
	stderr->_file = 2;
	stderr->_flag = _IORW | x;

	/*      establish control-c handler */

	onbreak( _CXBRK );

#endif

	/*
	 *
	 * Call user's main program
	 *
	 */

	main(argc,targv);              /* call main function */
	exit(0);
}
