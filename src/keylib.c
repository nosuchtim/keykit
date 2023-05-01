/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>

#include "d_mdep1.h"

#ifdef __GNUC__
/* GLIBC prefers int for errno type, not errno_t */
#define errno_t int
#endif

long *Debugstrsave = NULL;
long *Debugmalloc = NULL;
extern char *myfgets(char*, int, FILE*);

/* Read all *.k file in the current directory and construct a keylib.k file */
/* that contains #library lines for all of the functions and classes defined. */

FILE *Kf;
char *Kl = "keylib.k";

void
eprint(char *fmt,...)
{
	va_list args;

	va_start(args,fmt);
	vfprintf(stderr,fmt,args);
	va_end(args);
}

char **lines;
unsigned int linesdim = 0;
unsigned int linescount;

/* Add a line to the list read */
void
addline(const char *p)
{
	char **newlines;
	char *q;
	
	if (linescount == linesdim)
	{
		linesdim = (3 * linesdim) / 2;
		if (linesdim < 20) {
			linesdim = 20;
		}
		newlines = realloc(lines, linesdim * sizeof(char **));
		if (!newlines)
		{
			eprint("Failed to allocate space for %d lines\n", linesdim);
			exit(1);
		}
		lines = newlines;
	}
	/* Dup the line and add to tail of array */
	q = strdup(p);
	if (!q)
	{
		eprint("Failed to duplicate '%s' string\n", p);
		exit(1);
	}
	lines[linescount++] = q;
}

void
sortlines(void)
{
	unsigned int i, j;
	for (i=0; i<linescount; ++i) {
		for (j=i+1; j<linescount; ++j) {
			if (strcmp(lines[i],lines[j])>0) {
				char *p;
				p = lines[i];
				lines[i] = lines[j];
				lines[j] = p;
			}
		}
	}
}

void
printlines(FILE *f)
{
	unsigned int i;
	for (i=0; i<linescount; ++i)
	{
		fprintf(f, "%s\n", lines[i]);
	}
}

void
cback(char *fname,int type)
{
	char buff[BUFSIZ];
	char line[BUFSIZ];
	FILE *f;
	char *p, *q;
	int lng, l;

	if ( type != 0 ) {	/* ignore non-files */
		return;
	}

	lng = (int) strlen(fname);
	if ( lng <= 2 ) {
		return;
	}

	/* We don't want to process keylib.k */
	p = &fname[lng-2];
	if ( strcasecmp(p,".k")!=0 || strcasecmp(fname,Kl) == 0 ) {
		return;
	}

	eprint("Scanning %s...\n",fname);

	errno_t err = 0;
	f = fopen(fname,"r");	/* not lowfname */
	if ( f == NULL ) {
		err = errno;
	}

	if ( err != 0 || f == NULL ) {
		eprint("Unable to open %s\n",fname);
		return;
	}
	while ( myfgets(buff,BUFSIZ,f) != NULL ) {

		/* look for lines beginning with function or class */

		if ( strncmp(buff,"function",8) == 0 ) {
			l = 8;
		}
		else if ( strncmp(buff,"class",5) == 0 ) {
			l = 5;
		}
		else {
			continue;
		}
		if ( ! isspace(buff[l]) ) {
			continue;
		}
		q = &buff[l+1];
		while ( isspace(*q) ) {
			q++;
		}
		p = q;
		while ( *q!=0 && strchr("({ \t\n\r",*q)==NULL ) {
			q++;
		}
		if ( *q != 0 ) {
			*q = 0;
		}
		sprintf(line,"#library %s %s",fname,p);
		addline(line);
	}
	fclose(f);
}

int
main()
{
	errno_t err = 0;
	Kf = fopen(Kl, "w");
	if ( Kf == NULL ) {
		err = errno;
	}

	if ( err != 0 || Kf == NULL ) {
		eprint("Unable to open %s\n",Kl);
		exit(1);
	}
	mdep_lsdir(".","*",cback);
	sortlines();
	printlines(Kf);
	fclose(Kf);
	exit(0);
	return(0);
}

void
keyerrfile(char *fmt, ...)
{
	va_list args;
	static FILE *f = NULL;

	if (f == NULL) {
		errno_t err = 0;
		f = fopen("key.dbg", "w");
		if ( f == NULL ) {
			err = errno;
		}
		if (err != 0) {
			fprintf(stderr, "UNABLE TO OPEN key.dbg!?\n");
			exit(1);
		}
	}

	va_start(args,fmt);

	if ( f == NULL ) {
		vfprintf(stderr,fmt,args);	/* last resort */
	}
	else {
		vfprintf(f,fmt,args);
		fflush(f);
	}
	va_end(args);
}

void
mdep_destroywindow(void)
{
}
