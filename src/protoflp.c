/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

/*
 * protoflp [ -c -s | -n | -p ] [ -d declarations.h ] < input.c > output.c
 *
 * See README for info.  This program relies heavily on conventions
 * in the style of function definitions, and is not likely to
 * be generally acceptable.
 */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#ifndef __FreeBSD__
#include <malloc.h>
#endif

#define BFSIZE 8096
#define MAXARGS 512
#define PROTO 0
#define NOPROTO 1

#ifdef __STDC__
char *
strsave(char *s)
#else
char *
strsave(s)
char *s;
#endif
{
	char *p = (char*) malloc((unsigned)(strlen(s)+1));
	strcpy(p,s);
	return(p);
}

#ifdef __STDC__
int
main(int argc,char **argv)
#else
int
main(argc,argv)
int argc;
char **argv;
#endif
{
	char *line1;
	char *p;
	char *defs = NULL;
	char *buff, *lastline, *func, *arg1, *args, *word1, *word2;
	int n, l, ln, words, isproto, dtype = PROTO;
	int found_no_return_attribute;
	FILE *fdef;
	char **decs;
	int suppress_output = 0;

	/* malloc buffers to avoid testing global data size limits */
	buff = (char*) malloc(BFSIZE);
	lastline = (char*) malloc(BFSIZE);
	func = (char*) malloc(BFSIZE);
	arg1 = (char*) malloc(BFSIZE);
	args = (char*) malloc(BFSIZE);
	word1 = (char*) malloc(BFSIZE);
	word2 = (char*) malloc(BFSIZE);
	decs = (char **) malloc(MAXARGS*sizeof(char*));
	if ( decs == NULL ) {
		fprintf(stderr,"No memory!?\n");
		exit(1);
	}
	while ( argc>1 ) {
		if ( argv[1][0] != '-' )
			break;
		switch (argv[1][1]) {
		    case 's':
			    suppress_output = 1;
			    break;
		case 'p':
			dtype = PROTO;
			break;
		case 'n':
			dtype = NOPROTO;
			break;
		case 'd':
			if ( argv[1][2] == '\0' )
				p = argv[2];
			else {
				p = &(argv[1][2]);
				argc--;
				argv++;
			}
			defs = p;
			break;
		}
		argc--;
		argv++;
	}
	if ( defs ) {
		if ( (fdef = fopen(defs,"w")) == NULL ) {
			fprintf(stderr,"protoflp: can't open '%s'\n",defs);
			perror("protoflp");
			exit(1);
		}
	}
	while ( fgets(buff,BFSIZE,stdin) != NULL ) {
		l = (int)strlen(buff);
		if ( ! (isalpha(buff[0]) && buff[l-2]==')') ) {
			/* For non-function lines, we normally just echo */
			/* them.  However, we also want to grab the */
			/* type name before the function name. */
			strcpy(lastline,buff);
			if (!suppress_output) {
				fputs(buff,stdout);
			}

			/* #if, #ifdef, #ifndef, #else, and #endif directives get */
			/* put into the definition file. */
		    	if ( fdef!=NULL && buff[0]=='#' &&
				( strncmp(buff,"#if",3)==0 ||
				  strncmp(buff,"#else",5)==0 ||
				  strncmp(buff,"#endif",6)==0 ) ) {

				fputs(buff,fdef);
			}
			continue;
		}
		ln = 0;
		line1 = strsave(buff);

		/* The code below is a manual implementation of: */
		/* sscanf(line1,"%[^(](%[^)])",func,args); */
		/* because some compilers' sscanf() isn't smart enough. */
		{
			char *xx;
			char *zz = line1;
			for (xx=func; *zz && *zz != '('; ++xx, ++zz) {
				*xx = *zz;
			}
			*xx = 0;
			++zz; /* skip '(' */
			for (xx=args; *zz && *zz != ')'; ++xx, ++zz) {
				*xx = *zz;
			}
			*xx = 0;
		}
		strcpy(arg1,args);
		if ( (p=strchr(arg1,',')) != NULL )
			*p = '\0';
		words = sscanf(arg1,"%s %s",word1,word2);
		found_no_return_attribute = 0;
		while ( fgets(buff,BFSIZE,stdin) != NULL ) {
			if ( buff[0] == '\n' )
				continue;
			if ( !strcmp(buff, "NO_RETURN_ATTRIBUTE\n") )
			{
				found_no_return_attribute = 1;
				continue;
			}
			if ( buff[0] == '{' )
				break;
			decs[ln++] = strsave(buff);
		}
		if ( buff[0] != '{' ) {
			fprintf(stderr,"Unable to find '{' after function !?\n");
			exit(1);
		}
		isproto = (words>1 || (words==1&&strcmp(word1,"void")==0));
		if ( dtype == PROTO ) {	/* we want to prototize it */
		    char protoline[BFSIZE];

		    if ( isproto ) {

			/* If it's already protoized, we don't do anything! */
			strcpy(protoline,line1);
		    }
		    else {
			/* Turn old form into prototypes.  This makes */
			/* lots of assumptions about the format. */
			strcpy(protoline,func);
			strcat(protoline,"(");
			if ( ln == 0 )
				strcat(protoline,"void");
			else {
			    for ( n=0; n<ln; n++ ) {
				p = strrchr(decs[n],';');
				if ( p == NULL ) {
					fprintf(stderr,"protoflp: declaration format error - must end in semicolon\n");
					fprintf(stderr,"declaration line: %s\n",decs[n]);
					fprintf(stderr,"function: %s\n",func);
					exit(1);
				}
				*p = '\0';
				strcat(protoline,decs[n]);
				if ( (n+1)<ln )
					strcat(protoline,",");
			    }
			}
			strcat(protoline,")\n");
		    }
		    if (!suppress_output) {
			    printf("%s",protoline);
			    if (!found_no_return_attribute) {
				    printf("{\n");
			    }
		    }
		    /* non-static functions get put into the fdef file */
		    if ( fdef && strncmp(lastline,"static",6)!=0 ) {
			/* The function type is on the previous line */
			if ( *lastline != '\n' ) {
				if ( (p=strchr(lastline,'\n')) != NULL )
					*p = '\0';
				fprintf(fdef,"%s ",lastline);
			}
			if ( (p=strchr(protoline,'\n')) != NULL )
				*p = '\0';
			fprintf(fdef,"%s\n",protoline);
			if (found_no_return_attribute)
			{
				fprintf(fdef, "NO_RETURN_ATTRIBUTE\n");
				if (!suppress_output) {
					printf("NO_RETURN_ATTRIBUTE\n");
				}
			}
			fprintf(fdef, ";\n");
			}
		    if (!suppress_output && found_no_return_attribute)
		    {
			    printf("{\n");
		    }
		}
		else {	 /* We want to turn it into old form */

		    if ( ! isproto ) {
			/* If it's already in old form, don't do anything! */
			printf("%s",line1);
			for ( n=0; n<ln; n++ )
				printf("%s",decs[n]);
			printf("{\n");
		    }
		    else {
		        char abuff[BFSIZE];
		        char *p, *q, *sep = "";
			int isvoid;

			isvoid = (sscanf(args,"%s %s",word1,word2) == 1
				&& strcmp(word1,"void") == 0);
			
			if ( isvoid )
				printf("%s()\n{\n",func);
			else {
			    strcpy(abuff,args);
			    printf("%s(",func);
			    for(p=strtok(abuff,",");p!=NULL;p=strtok(NULL,",")){
				q = strchr(p,'\0');
				while ( --q > p ) {
					if ( isspace(*q) )
						break;
				}
				if ( q <= p ) {
					fprintf(stderr,"protoflp: declaration format error, expecting space (arg=%s args=%s)!\n",p,args);
					exit(1);
				}
				q++;
				while ( *q == '*' )
					q++;
				printf("%s%s",sep,q);
				sep = ",";
			    }
			    printf(")\n");
			    /* now go back through the arguments again and */
			    /* put out old declarations. */
			    strcpy(abuff,args);
			    for ( p=strtok(abuff,","); p!=NULL; p=strtok(NULL,",") )
				printf("%s;\n",p);
			    printf("{\n");
			}
		    }
		    /* non-static functions get put into the fdef file */
		    if ( fdef && strncmp(lastline,"static",6)!=0 ) {
			/* The function type is on the previous line */
			if ( *lastline != '\n' ) {
				if ( (p=strchr(lastline,'\n')) != NULL )
					*p = '\0';
				fprintf(fdef,"%s ",lastline);
			}
			fprintf(fdef,"%s();\n",func);
		    }
		}
	}
	exit(0);
	return 0;
}
