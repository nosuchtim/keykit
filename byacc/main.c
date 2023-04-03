#include <stdio.h>
#include <signal.h>
#include "defs.h"

void exit(int status);

char dflag;
char lflag;
char rflag;
char tflag;
char vflag;

char *file_prefix = "y";
char *myname = "yacc";
char *temp_form = "yacc.XXXXXXX";

int lineno;
int outline;

char *action_file_name;
char *defines_file_name;
char *input_file_name = "";
char *output_file_name;
char *text_file_name;
char *union_file_name;
char *verbose_file_name;

FILE *action_file;	/*  a temp file, used to save actions associated    */
			/*  with rules until the parser is written	    */
FILE *defines_file;	/*  y.tab.h					    */
FILE *input_file;	/*  the input file				    */
FILE *output_file;	/*  y.tab.c					    */
FILE *text_file;	/*  a temp file, used to save text until all	    */
			/*  symbols have been defined			    */
FILE *union_file;	/*  a temp file, used to save the union		    */
			/*  definition until all symbol have been	    */
			/*  defined					    */
FILE *verbose_file;	/*  y.output					    */

int nitems;
int nrules;
int nsyms;
int ntokens;
int nvars;

int   start_symbol;
char  **symbol_name;
short *symbol_value;
short *symbol_prec;
char  *symbol_assoc;

short *ritem;
short *rlhs;
short *rrhs;
short *rprec;
char  *rassoc;
short **derives;
char *nullable;

extern char *mktemp();
extern char *getenv();


done(k)
int k;
{
    if (action_file) { fclose(action_file); unlink(action_file_name); }
    if (text_file) { fclose(text_file); unlink(text_file_name); }
    if (union_file) { fclose(union_file); unlink(union_file_name); }
    exit(k);
}


onintr()
{
    done(1);
}

#ifdef _WIN32
typedef void (*SIGFUNCTYPE)(int);
#else
typedef void (*SIGFUNCTYPE)();
#endif

set_signals()
{
#ifdef SIGINT
    if (signal(SIGINT, SIG_IGN) != SIG_IGN)
	signal(SIGINT, (SIGFUNCTYPE) onintr);
#endif
#ifdef SIGTERM
    if (signal(SIGTERM, SIG_IGN) != SIG_IGN)
	signal(SIGTERM, (SIGFUNCTYPE) onintr);
#endif
#ifdef SIGHUP
    if (signal(SIGHUP, SIG_IGN) != SIG_IGN)
	signal(SIGHUP, (SIGFUNCTYPE) onintr);
#endif
}


void
usage()
{
    fprintf(stderr, "usage: %s [-dlrtv] [-b file_prefix] filename\n", myname);
    exit(1);
}


void
getargs(argc, argv)
int argc;
char *argv[];
{
    register int i;
    register char *s;

    if (argc > 0) myname = argv[0];
    for (i = 1; i < argc; ++i)
    {
	s = argv[i];
	if (*s != '-') break;
	switch (*++s)
	{
	case '\0':
	    input_file = stdin;
	    if (i + 1 < argc) usage();
	    return;

	case '-':
	    ++i;
	    goto no_more_options;

	case 'b':
	    if (*++s)
		 file_prefix = s;
	    else if (++i < argc)
		file_prefix = argv[i];
	    else
		usage();
	    continue;

	case 'd':
	    dflag = 1;
	    break;

	case 'l':
	    lflag = 1;
	    break;

	case 'r':
	    rflag = 1;
	    break;

	case 't':
	    tflag = 1;
	    break;

	case 'v':
	    vflag = 1;
	    break;

	default:
	    usage();
	}

	for (;;)
	{
	    switch (*++s)
	    {
	    case '\0':
		goto end_of_option;

	    case 'd':
		dflag = 1;
		break;

	    case 'l':
		lflag = 1;
		break;

	    case 'r':
		rflag = 1;
		break;

	    case 't':
		tflag = 1;
		break;

	    case 'v':
		vflag = 1;
		break;

	    default:
		usage();
	    }
	}
end_of_option:;
    }

no_more_options:;
    if (i + 1 != argc) usage();
    input_file_name = argv[i];
}


char *
allocate(n)
unsigned n;
{
    register char *p;

    p = NULL;
    if (n)
    {
	p = CALLOC(1, n);
	if (!p) no_space();
    }
    return (p);
}

create_file_names()
{
    int i, len;
    char *tmpdir;

#ifdef _WIN32
    char *_strdup(const char*);
    action_file_name = _strdup(tmpnam(NULL));
    text_file_name = _strdup(tmpnam(NULL));
    union_file_name = _strdup(tmpnam(NULL));
#else
    tmpdir = getenv("TMPDIR");
    if (tmpdir == 0) tmpdir = "/tmp";

    len = strlen(tmpdir);
    i = len + 13;
    if (len && tmpdir[len-1] != '/')
	++i;

    action_file_name = MALLOC(i);
    if (action_file_name == 0) no_space();
    text_file_name = MALLOC(i);
    if (text_file_name == 0) no_space();
    union_file_name = MALLOC(i);
    if (union_file_name == 0) no_space();

    strcpy(action_file_name, tmpdir);
    strcpy(text_file_name, tmpdir);
    strcpy(union_file_name, tmpdir);

    if (len && tmpdir[len - 1] != '/')
    {
	action_file_name[len] = '/';
	text_file_name[len] = '/';
	union_file_name[len] = '/';
	++len;
    }

    strcpy(action_file_name + len, temp_form);
    strcpy(text_file_name + len, temp_form);
    strcpy(union_file_name + len, temp_form);

    action_file_name[len + 5] = 'a';
    text_file_name[len + 5] = 't';
    union_file_name[len + 5] = 'u';

    mktemp(action_file_name);
    mktemp(text_file_name);
    mktemp(union_file_name);
#endif

    len = strlen(file_prefix);
    if (dflag)
    {
	/*  the number 7 below is the size of ".tab.h"; sizeof is not used  */
	/*  because of a C compiler that thinks sizeof(".tab.h") == 6	    */
	defines_file_name = MALLOC(len + 7);
	if (defines_file_name == 0) no_space();
	strcpy(defines_file_name, file_prefix);
	strcpy(defines_file_name + len, DEFINES_SUFFIX);
    }

    output_file_name = MALLOC(len + 7);
    if (output_file_name == 0) no_space();
    strcpy(output_file_name, file_prefix);
    strcpy(output_file_name + len, OUTPUT_SUFFIX);

    if (vflag)
    {
	verbose_file_name = MALLOC(len + 8);
	if (verbose_file_name == 0) no_space();
	strcpy(verbose_file_name, file_prefix);
	strcpy(verbose_file_name + len, VERBOSE_SUFFIX);
    }
}


open_files()
{
    create_file_names();

    if (input_file == 0)
    {
	input_file = fopen(input_file_name, "r");
	if (input_file == 0) open_error(input_file_name);
    }

    action_file = fopen(action_file_name, "w");
    if (action_file == 0) open_error(action_file_name);

    text_file = fopen(text_file_name, "w");
    if (text_file == 0) open_error(text_file_name);

    if (vflag)
    {
	verbose_file = fopen(verbose_file_name, "w");
	if (verbose_file == 0) open_error(verbose_file_name);
    }

    if (dflag)
    {
	defines_file = fopen(defines_file_name, "w");
	if (defines_file == 0) open_error(defines_file_name);
	union_file = fopen(union_file_name, "w");
	if (union_file ==  0) open_error(union_file_name);
    }

    output_file = fopen(output_file_name, "w");
    if (output_file == 0) open_error(output_file_name);
}


int
main(argc, argv)
int argc;
char *argv[];
{
    set_signals();
    getargs(argc, argv);
    open_files();
    reader();
    lr0();
    lalr();
    make_parser();
    verbose();
    output();
    done(0);
    /*NOTREACHED*/
}
