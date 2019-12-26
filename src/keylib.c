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

long *Debugmalloc = NULL;
extern char *myfgets(char*, int, FILE*);

/* Read all *.k file in the current directory and construct a keylib.k file */
/* that contains #library lines for all of the functions and classes defined. */

FILE *Kf;
char *Kl = "keylib.k";

void
strlowcpy(char *buff,char *p)
{
	char *q;

	for ( q=buff; (*q=*p)!=0; q++,p++ ) {
		if ( *q >= 'A' && *q <= 'Z' )
			*q = *q - 'A' + 'a';
	}
}

void
eprint(char *fmt,...)
{
	va_list args;

	va_start(args,fmt);
	vfprintf(stderr,fmt,args);
	va_end(args);
}

void
cback(char *fname,int type)
{
	char buff[BUFSIZ];
	char lowfname[BUFSIZ];
	FILE *f;
	char *p, *q;
	int lng, l;

	if ( type != 0 )	/* ignore non-files */
		return;

	strlowcpy(lowfname,fname);	 /* converted to lower case */

	lng = (int) strlen(lowfname);
	if ( lng <= 2 )
		return;

	/* We don't want to process keylib.k */
	p = &lowfname[lng-2];
	if ( strcmp(p,".k")!=0 && strcmp(p,".K")!=0 )
		return;

	if ( strcmp(lowfname,Kl) == 0 )
		return;

	eprint("Scanning %s...\n",lowfname);

	errno_t err;
	err = fopen_s(&f, fname,"r");	/* not lowfname */

	if ( err != 0 || f == NULL ) {
		eprint("Unable to open %s\n",fname);
		return;
	}
	while ( myfgets(buff,BUFSIZ,f) != NULL ) {

		/* look for lines beginning with function or class */

		if ( strncmp(buff,"function",8) == 0 )
			l = 8;
		else if ( strncmp(buff,"class",5) == 0 )
			l = 5;
		else
			continue;
		if ( ! isspace(buff[l]) )
			continue;
		q = &buff[l+1];
		while ( isspace(*q) )
			q++;
		p = q;
		while ( *q!=0 && strchr("({ \t\n\r",*q)==NULL )
			q++;
		if ( *q != 0 )
			*q = 0;
		fprintf(Kf,"#library %s %s\n",lowfname,p);
	}
	fclose(f);
}

int
main()
{
	errno_t err;
	err = fopen_s(&Kf, Kl, "w");

	if ( err != 0 || Kf == NULL ) {
		eprint("Unable to open %s\n",Kl);
		exit(1);
	}
	mdep_lsdir(".","*",cback);
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
		errno_t err;
		err = fopen_s(&f, "key.dbg", "w");
		if (err != 0) {
			fprintf(stderr, "UNABLE TO OPEN key.dbg!?\n");
			exit(1);
		}
	}

	va_start(args,fmt);

	if ( f == NULL )
		vfprintf(stderr,fmt,args);	/* last resort */
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
