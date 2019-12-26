/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#include "key.h"
#include "gram.h"

#ifdef FFF
FILE *FF = NULL;
#endif

#ifndef lint
char *Copyright = "KeyKit 8.0 - Copyright 1996 AT&T Corp.  All rights reserved.";
#endif

// int errno;

char *Yytext;
char *Yytextend;
char *Buffer;
unsigned int Buffsize;
long Msg1size = 0;
long Msg2size = 0;
long Msg3size = 0;
long Wmsgsize = 0;
long Msgtsize = 0;
char *Msg1;
char *Msg2;
char *Msg3;
char *Wmsg;
char *Msgt;
char *Pyytext;
char *Ungot;
long Ungotsize = 0;
int Usestdio = 0;
int ReadytoEval = 0;

FILE *Fin = NULL;		/* current input */
FILE *Fout = NULL;		/* current output */
int Keycnt = 0;
int Errors = 0;
int Doconsole = 0;
int Gotanint = 0;
int Errfileit = 0;
int Dbg = 0;

char Tty[] = "tty";
char *Infile = Tty;		/* current input file name */
char Autopop = 0;

static FILE *Fstack[FSTACKSIZE];	/* Nested FILEs being read */
static char *Fnstack[FSTACKSIZE];	/* The names of those files */
static int Lnstack[FSTACKSIZE];		/* Current line # in those files */
static int Popstack[FSTACKSIZE];	/* Whether to auto-pop on EOF */
static FILE **Fstackp = Fstack;
static char **Fnstackp = Fnstack;
static int *Lnstackp = Lnstack;
static int *Popstackp = Popstack;
static long Ungoti;
static int Maxpathleng = 0;
static Htablep Keylibtable = NULL;

char *Progname = "key";
int Macrosused = 0;
int Lineno = 1;

Instnodep Loopstack[FSTACKSIZE];
int Loopnum = -1;

Codep Fkeyfunc[NFKEYS];

char *stdinonly[] = { "-" };

#define DONTFLAGERROR 0
#define FLAGERROR 1

int Argc;
char **Argv;

void keyerrfile(char *fmt,...);

void
keystart(void)
{
	register char *p;

	/* these are dynamically allocated to avoid using global static */
	/* memory, which some compilers limit to 64 K */

	if ( (p=getenv("BUFSIZ")) == NULL )
		Buffsize = BUFSIZ;
	else
		Buffsize = atoi(p);

	keysrand(0x87654321,0x11111111,0x12345678);

	Yytext = kmalloc(Buffsize,"keystart");
	Yytext[0] = 0;
	Yytextend = (Yytext+Buffsize-1);

	Buffer = kmalloc(Buffsize,"keystart");
	Buffer[0] = 0;

	Msg1 = kmalloc((unsigned)(Msg1size=Buffsize),"keystart");
	Msg1[0] = 0;
	Msg2 = kmalloc((unsigned)(Msg2size=10),"keystart");
	Msg2[0] = 0;
	Msg3 = kmalloc((unsigned)(Msg3size=10),"keystart");
	Msg3[0] = 0;
	Wmsg = kmalloc((unsigned)(Wmsgsize=Buffsize),"keystart");
	Wmsg[0] = 0;

	Ungot = kmalloc((unsigned)(Ungotsize=Buffsize),"keystart");
	Ungot[0] = 0;
	Ungoti = 0;
	Pyytext = Yytext;

	_Dnumtmp_.type = D_NUM;
	Stopcode.u.func = (BYTEFUNC)I_STOP;
	Stopcode.type = IC_INST;

	/* Nextobjid = 1 + (mdep_currtime()%(1<<15)) << 15; */
	Nextobjid = 1;

	newcontext((Symbolp)NULL,113);		/* no good reason for 113 */
	Topct = Currct;

	/* Watch out, order of these things is probably critical. */

	initstrs();
	initsyms();
	pushiseg();
	inittasks();
	initfifos();
	mdep_prerc();	/* Machine-dependent, BEFORE reading keykit.rc. */
}

void
keyfile(char *fname,int flag)
{
	FILE *f;
	Codep cp, cp2;

	OPENTEXTFILE(f,fname,"r");
	if ( f == NULL ) {
		if ( flag )
			eprint("%s: can't open %s (%s)\n",
					Progname,fname,strerror(errno));
		return;
	}
	cp2 = instructs("");
	T = newtask(cp2);
	pushfin(f,fname,0);
	pushiseg();
	Errors = 0;
	yyparse();
	popfin();
	cp = popiseg();
	if ( Errors > 0 )
		freecode(cp);
	else
		nestinstruct(cp);
}

/* used when we just want to define functions, */
/* and not actually execute anything. */
void
keydefine(char *s)
{
	Codep cp = instructs(s);
	freecode(cp);
}

void
keystr(char *s)
{
	Codep cp;

	T = newtask(instructs(""));
	cp = instructs(s);
	if ( cp )
		nestinstruct(cp);
}

/* defnonly(s) - warn if illegal definition */
void
defnonly(char *s)
{
	if (Indef == 0)
		execerror("%s used outside definition",s);
}

/* looponly(s) - warn if illegal continue or break */
void
looponly(char *s)
{
	if (Loopnum<0)
		execerror("%s used outside a for or while loop",s);
}

void
loopstart(void)
{
	if ( Loopnum >= (FSTACKSIZE-1) )
		execerror("Loops are nested too deeply!");
	Loopstack[++Loopnum] = NULL;
}

void
looppatch(Instnodep patchin)
{
	Instnodep t;
	Instcode* ip;

	t = Loopstack[Loopnum];
	Loopstack[Loopnum] = patchin;
	ip = ptincode(patchin,1);
	ip->u.in = t;
}

void
loopend(Instnodep icontinue,Instnodep ibreak)
{
	Instnodep i, nexti;
	Instcode* ic;

	dummyset(nexti);
	/* patch up the break and continue statements */
	if ( Loopnum < 0 )
		execerror("In loopend, unexpected Loopnum < 0 !?");
	for ( i=Loopstack[Loopnum]; i!=NULL; i=nexti ) {
		ic = ptincode(i,1);
		nexti = ic->u.in;
		switch (i->code.u.val) {
		case IBREAK:
			i->code = funcinst(I_GOTO);
			ic->u.in = ibreak;
			break;
		case ICONTINUE:
			i->code = funcinst(I_GOTO);
			ic->u.in = icontinue;
			break;
		default:
			execerror("loopend() didn't get IBREAK or ICONTINUE, got %ld!?",i->code.u.val);
		}
	}
	Loopnum--;
}

/* yyerror(s) - report compile-time error */
void
yyerror(char *s)
{
	warning(s);
	Errors++;

	while ( Indef > 0 ) {
		Codep cp;
		Datum *dp;
		Symbolp s = Currct->func;

		enddef(s);

		/* We want to completely eradicate the function that was */
		/* being defined when the error occured. */
		dp = symdataptr(s);
		if ( dp ) {
			cp = dp->u.codep;
			kfree(cp);
			*dp = Noval;
		}
		s->stype = UNDEF;
	}

	flushfin();	/* flush rest of current file */

	/* DON'T LONGJMP (Hmm, why did I say this?  It's causing a problem */
	/* in either case.)  There are sometimes (but not usually) serious */
	/* problems when a syntax error is encountered, particularly when */
	/* there's an unclosed brace.  UNFIXED BUG HERE.   */ 
}

char *
ipfuncname(Codep cp)
{

	if ( cp == NULL )
		return NULL;
	else
		return symname(symof(cp));
}

char *
infuncname(Instnodep in)
{
	char *p;

	if ( in == NULL )
		return "NULL";
	if ( (in=nextinode(in)) == NULL )
		return "NULL";
	switch(in->code.type) {
	case IC_NONE:	p = "?NONE?"; break;
	case IC_NUM:	p = "NUMBER"; break;
	case IC_STR:	p = "STRING"; break;
	case IC_DBL:	p = "DOUBLE"; break;
	case IC_SYM:	p = symname(in->code.u.sym); break;
	case IC_PHR:	p = "PHRASE"; break;
	case IC_INST:	p = "INSTRUCTION"; break;
	case IC_FUNC:	p = "FUNCTION"; break;
	case IC_BLTIN:	p = "BUILT_IN"; break;
	default:	p = "DEFAULT"; break;
	}
	return p;
}

void
pstacktrace(Datum *dp)
{
	/* The Msgt buffer is used for printing within tprint(), so we */
	/* need to be sure there's enough room for the stacktrace. */
	char *s = stacktrace(dp,1,1,T);
	makeroom((long)(64+strlen(s)),&Msgt,&Msgtsize);
	tprint("Function traceback:\n%s",s);
}

static char *Stackbuff = NULL;
static long Stackbuffsofar = 0;
static long Stackbuffsize = 0;

void
stackbuffclear(void)
{
	makeroom(8L,&Stackbuff,&Stackbuffsize);
	*Stackbuff = '\0';
	Stackbuffsofar = 0;
}

void
stackbuff(char *s)
{
	long sleng = (long) strlen(s);
	makeroom(Stackbuffsofar+sleng+2,&Stackbuff,&Stackbuffsize);
	strcpy(Stackbuff+Stackbuffsofar,s);
	Stackbuffsofar += sleng;
}

long
stackbuffleng(void)
{
	return Stackbuffsofar;
}

void
stackbufftrunc(long lng)
{
	Stackbuff[lng] = '\0';
	Stackbuffsofar = lng;
}

char *
stackbuffstr(void)
{
	return Stackbuff;
}

char *
stacktrace(Datum *dp,int full,int newlines,Ktaskp t)
{
	Datum d;
	Datum *arg0;
	Codep cp;
	int n, npassed, varsize;
	int first = 1;
	char *comma = "";
	Datum *initialdp = dp;
	Datum *stackbegin = t->stack;
	char *s, *ipf;
	int waserr = 0;

	stackbuffclear();
	while ( dp != NULL ) {
		if ( dp > initialdp || dp < stackbegin ) {
/* eprint("stacktrace() detects errant pointer, early break!\n"); */
/* eprint("dp=%ld stackbegin=%ld initialdp=%ld\n",dp,stackbegin,initialdp); */
			waserr = 1;
			break;
		}
		cp = (dp - FRAME_FUNC_OFFSET)->u.codep;
		if ( cp == NULL )
			break;
		if ( first ) {
			first = 0;
			comma = ",";
		}
		else {
			stackbuff(comma);
			if ( newlines )
				stackbuff("\n");
		}
		ipf = ipfuncname(cp);
		if ( ipf == NULL )
			ipf = "?UNKNOWN?";
		stackbuff(ipf);
		if ( ! full )
			stackbuff("()");
		else {
			npassed = (int)((dp - FRAME_NPASSED_OFFSET)->u.val);
			varsize = (int)((dp - FRAME_VARSIZE_OFFSET)->u.val);
			arg0 = (dp - FRAMEHEADER - varsize);
			stackbuff("(");
			for ( n=0; n<npassed; n++ ) {
				long limit;
				if ( n > 0 )
					stackbuff(",");
				limit = stackbuffleng() + 32;
				d = *(arg0+n);
				if ( isnoval(d) )
					stackbuff("<Uninitialized>");
				else
					prdatum(d,stackbuff,1);
				if ( stackbuffleng() > limit ) {
					stackbufftrunc(limit);
					stackbuff("...");
				}
			}
			stackbuff(")");
		}
		dp = dp->u.frm;
	}
	if ( newlines )
		stackbuff("\n");
	s = stackbuffstr();
	if ( waserr ) {
		sprintf(Msg1,"Error in stacktrace, s=(%s)\n",s);
		mdep_popup(Msg1);
	}
	return s;
}

int Inerror = 0;

void
keyerrfile(char *fmt,...)
{
	va_list args;
	static FILE *f = NULL;

	if ( f == NULL )
		f = fopen("key.dbg","w");

	va_start(args,fmt);

	if ( f == NULL )
		vfprintf(stderr,fmt,args);	/* last resort */
	else {
		vfprintf(stdout,fmt,args);
		// vfprintf(f,fmt,args);
		fflush(f);
	}
	va_end(args);
}

/* recover from run-time error */
void
execerror(char *fmt,...)
{
	va_list args;

	Inerror++;
	if ( Inerror > 1 ) {
		if ( Inerror > 3 ) {
			warning("Recursive error!!!");
			goto skipitall;
		}
		if ( Inerror > 2 ) {
			warning("Recursive error!!");
			goto skipmore;
		}
		warning("Recursive error?");
		goto skipabit;
	}

	/* somewhat arbitrary, real conservative because it has been */
	/* easy to overrun this buffer with the stack trace, in the past. */
	makeroom(1024+2*(long)strlen(fmt),&Msgt,&Msgtsize);

	va_start(args,fmt);
	vsprintf(Msgt,fmt,args);
	va_end(args);

	if ( Errfileit )
		keyerrfile("%s\n",Msgt);

	/* If there is a per-task error function, we save the error message */
	/* for it.  The per-task error function will be invoked in taskbury. */
	if ( T != NULL && T->ontaskerror != NULL ) {
		T->ontaskerrormsg = uniqstr(Msgt);
	} else {
		/* Default onerror action is to use warning(), */
		/* and to print a stacktrace. */
		warning(Msgt);
		if ( T ) {
			pstacktrace(T->stackframe);
		}
	}

    skipabit:

	if ( T ) {
		taskkill(T,1);
		T = NULL;
	}
	else
		eprint("Hmmm, T==NULL in execerror!?\n");

	/* When we get an error in one task, we don't want */
	/* to clear Topsched and do other things that screw up realtime, */
	/* so we no longer call resetstuff() here. */
	/* resetstuff(); */

    skipmore:

	if ( *Abortonerr != 0 )
		mdep_abortexit(Msgt);

	/* avoid calling user-defined error function when recursive */
	if ( Inerror < 2 ) {
		if ( Errorfuncd->type == D_CODEP )
			taskfunc0(Errorfuncd->u.codep);
		else
			eprint("Warning, Errorfunc has non-function value!?");
	}
	else
		Errors++;

	flushfin();	/* flush rest of current file */

    skipitall:

	Inerror = 0;
	restartexec();
	/*NOTREACHED*/
}

void
resetstuff(void)
{
	resetreal();		/* in case it happens during rtloop() */
	m_reset();
}

void
forcereboot(void)
{
	resetstuff();
	flushfin();	/* flush rest of current file */
	startreboot();
	restartexec();
	/*NOTREACHED*/
}

/* print warning message */
void
warning(char *fmt,...)
{
	long needed;
	va_list args;

	if ( fmt == NULL )
		return;
	/* need to be especially conservative in the length, here, because */
	/* the message buffer can still get overrun if something being */
	/* printed is really long. */
	needed = 512L + (long)strlen(fmt) + (Infile?(long)strlen(Infile):0);
	makeroom(needed,&Wmsg,&Wmsgsize);
	sprintf(Wmsg, "%s: ",Progname);

	va_start(args,fmt);
	vsprintf(strend(Wmsg),fmt,args);
	va_end(args);

	/* On syntax errors, we don't bother telling what line we were */
	/* executing, since that's unlikely to be of any use. */
	if ( strcmp(fmt,"syntax error") != 0 ) {
		if ( T != NULL )
			sprintf(strend(Wmsg)," \nwhile executing near line %ld in file %s",T->linenum,(T->filename?T->filename:"??"));
	}
	if ( Infile!=Tty && Infile!=NULL && *Infile != '\0' )
		sprintf(strend(Wmsg)," \nwhile reading %s near line %d",Infile,Lineno);
	strcat(Wmsg,"\n");
	eprint(Wmsg);
	tsync();
}

/* popup warning message */
void
popupwarning(char *fmt,...)
{
	long needed;
	va_list args;

	if ( fmt == NULL )
		return;

	/* Somewhat arbitrary, meant to be conservative, but in reality */
	/* it's still capable of being overrun.  */
	needed = 512L + (long)strlen(fmt) + (Infile?(long)strlen(Infile):0);
	makeroom(needed,&Wmsg,&Wmsgsize);

	sprintf(Wmsg, "%s: ",Progname);

	va_start(args,fmt);
	vsprintf(strend(Wmsg),fmt,args);
	va_end(args);

	/* On syntax errors, we don't bother telling what line we were */
	/* executing, since that's unlikely to be of any use. */
	if ( strcmp(fmt,"syntax error") != 0 ) {
		if ( T != NULL )
			sprintf(strend(Wmsg)," \nwhile executing near line %ld in file %s",T->linenum,T->filename);
	}
	if ( Infile!=Tty && Infile!=NULL && *Infile != '\0' )
		sprintf(strend(Wmsg)," \nwhile reading %s near line %d",Infile,Lineno);
	strcat(Wmsg,"\n");
	mdep_popup(Wmsg);
}

void
finalexit(int r)
{
	mdep_endmidi();
	mdep_bye();
	exit(r);
}

void
realexit(int r)
{
	finishoff();
	closeallfifos();	/* so ports get closed */
	finalexit(r);
}

void
fatalerror(char *s)
{
	strcpy(Msg1,s);
	strcat(Msg1,"\n");
	eprint(Msg1);
	resetreal();
	realexit(1);
	/*NOTREACHED*/
}

void
myre_fail(char *s,int c)
{
	dummyusage(c);
	execerror("Failure in myre_exec: %s",s);
}

void
tsync(void)
{
#ifdef NEEDSYNC
	mdep_sync();
#endif
}

void
tprint(char *fmt,...)
{
	va_list args;

	va_start(args,fmt);
	kdoprnt(0,stdout,fmt,args);
	va_end(args);
}

void
eprint(char *fmt,...)
{
	va_list args;

	va_start(args,fmt);
	kdoprnt(1,stderr,fmt,args);
	fflush(stderr);
	va_end(args);
}

void
kdoprnt(int addnewline, FILE *f, char *fmt, va_list args)
{
	long lng;

	/* Somewhat arbitrary, meant to be conservative, but in reality */
	/* it's still capable of being overrun.  Things that are likely */
	/* to overrun it should do their own makeroom() calls. */
	makeroom(1024+2*(long)strlen(fmt),&Msgt,&Msgtsize);

	vsprintf(Msgt,fmt,args);

	if ( Errfileit )
		keyerrfile(Msgt);

	if ( Usestdio )
		fputs(Msgt,f);
	else
		putonconsoutfifo(uniqstr(Msgt));

	if ( addnewline ) {
		lng = (long)strlen(Msgt);
		if ( Msgt[lng-1] != '\n' )
			putonconsoutfifo(uniqstr("\n"));
	}
}

void
intcatch(void)
{
	if ( Abortonint!=NULL && *Abortonint != 0 )
		mdep_abortexit("Intcatch is forcing a core dump...\n");
	mdep_setinterrupt((SIGFUNCTYPE)intcatch);
	Gotanint++;
	if ( Gotanint > 10 )
		finalexit(1);
	if ( Gotanint > 5 ) {
		eprint("Calling mdep_abortexit() to force a core dump!\n");
		mdep_abortexit("Gotanint > 5 !?!");
		/*NOTREACHED*/
	}
	if ( Gotanint > 3 ) {
		forcereboot();
		/*NOTREACHED*/
	}
	if ( Gotanint > 1 )
		eprint("Gotanint=%d\n",Gotanint);
}

void setintcatch(void)
{
	/* mdep_setinterrupt((SIGFUNCTYPE)intcatch); */
}

void
yyunget(int ch)
{
	if ( ch == EOF )	/* new code, suspect */
		return;
	if ( ch == 0 )
		execerror("Hey, ch==0 in yyunget!");
	stuffch(ch);
	if ( Pyytext > Yytext )
		Pyytext--;
}

void
stuffch(int ch)
{
	long needed = Ungoti+2;
	makeroom(needed,&Ungot,&Ungotsize);
	if ( ch == '\r' )
		ch = '\n';
	Ungot[Ungoti++] = ch;
}

void
stuffword(register char *q)
{
	register char *t = strend(q) - 1;

	while ( t>=q )
		stuffch(*t--);
}

int
yyinput(void)
{
	register int ch;

restart:
	if ( (ch=yyrawin()) == EOF ) {
		return(EOF);
	}

	/* a backslash followed by \r or \n is ignored */
	if ( ch == '\\' ) {
		register int nextc = yyrawin();
		if ( nextc == '\r' || nextc == '\n' )
			goto restart;
		yyunget(nextc);
	}
	return(ch);
}

void
pushfin(FILE *f,char *fn,int autopop)
{
	if ( Fstackp >= (&Fstack[FSTACKSIZE]) ) {
		int n;
		char **pp;
		for ( n=0,pp=Fnstack; pp < &Fnstack[FSTACKSIZE]; n++,pp++ ) {
			char *fname = *pp;
			if ( fname )
				eprint("Fnstack=%s\n",fname);
		}
		execerror("Too many files are being sourced!  Increase FSTACKSIZE!");
	}

	/* Save current file pointer and name */
	*Fstackp++ = Fin;
	*Fnstackp++ = Infile;
	*Lnstackp++ = Lineno;
	*Popstackp++ = Autopop;

	if ( f!=NULL && mdep_fisatty(f) ) {
		Infile = Tty;
	}
	else {
		/* Must make local copy of name, because it's not unique */
		/* and file inclusion can be recursive. */

		Infile = fn ? strsave(fn) : fn;		/* NOT uniqstr */
	}
	Fin = f;
	Lineno = 1;

#ifdef TRYWITHOUT
	keyerrfile("Linetrace A may be adding I_FILENAME!\n");
	if ( *Linetrace ) {
		code(funcinst(I_LINENUM));
		code(numinst(Lineno));
		code(funcinst(I_FILENAME));
		code(strinst(Infile==NULL?Nullstr:uniqstr(Infile)));
	}
#endif

	Autopop = autopop;
	if ( ! Autopop ) {
		yyreset();
	}
}

/* skip the rest of the current input file and go to the previous one */
void
popfin(void)
{
	if ( ! Autopop )
		yyreset();

	/* Restore file we were reading before this one */
	if ( Fstackp <= Fstack ) {
		eprint("Hey, popfin called too often?\n");
		Fin = NULL;
		Infile = "";
		Lineno = 0;
	}
	else {
		if ( Infile != Tty )
			kfree(Infile);
		Fin = *--Fstackp;
		Infile = *--Fnstackp;
		Lineno = *--Lnstackp;
		Autopop = *--Popstackp;
	}
#ifdef TRYWITHOUT
	keyerrfile("Linetrace B may be adding I_FILENAME!\n");
	if ( *Linetrace ) {
		code(funcinst(I_LINENUM));
		code(numinst(Lineno));
		code(funcinst(I_FILENAME));
		code(strinst(Infile));
	}
#endif
}

void
yyreset(void)
{
	*Yytext = '\0';
	Ungoti = 0;
	Ungot[Ungoti] = 0;
	Loopnum = -1;
	Indef = 0;
	/* ttyclear(); */
}

/* skip the rest of the current input file */
void
flushfin(void)
{
	yyreset();
	if ( Fin != NULL && Infile != Tty ) {
		eprint("Flushing rest of file: %s\n",Infile);
		while ( getc(Fin) != EOF )
			;
		/*
		 * Should be closing the file, here, but
		 * a call to myfclose returns an error?
		 * I guess we'll try fclose(), but I don't
		 * what's going on.
		 */
		fclose(Fin);
	}
}

/* Get a character from the current input (Fin), with no interpretation. */
int
yyrawin(void)
{
	register int ch;

restart:
	/* If we have input stashed away, use it */
	if ( Ungoti > 0 ) {
		ch = Ungot[--Ungoti];
		if ( ch == 0 )
			ch = EOF;
	}
	else {
		/* Read a char from the current Fin */
		if ( Fin == NULL )
			ch = EOF;
		else {
			ch = getc(Fin);
			/* quick test for most common situation */
			if ( ch > '\r' )
				goto getout;
		}

		if ( ch == EOF ) {
			if ( Autopop ) {
				myfclose(Fin);
				popfin();
				goto restart;
			}
			return(EOF);
		}
		if ( ch == '\r' )
			ch = '\n';

		if ( ch == '\n' ) {
			/* We only adjust Lineno when we read a character */
			/* the first time (ie. not when from Ungot). */
			Lineno++;
			if ( *Linetrace ) {
				code(funcinst(I_LINENUM));
				code(numinst(Lineno));
			}
		}
	}

getout:
	if ( Pyytext < Yytextend )
		*Pyytext++ = ch;
	return(ch);
}

int Killchar = '@';
int Erasechar = '\b';
int Eofchar = 4;
int Intrchar = 0x7f;

Codep
instructs(char *s)
{
	Codep cp;
	pushfin((FILE *)NULL,(char *)NULL,0);
	pushiseg();
	stuffword(s);
	Errors = 0;
	yyparse();
	cp = popiseg();
	if ( Errors > 0 ) {
		freecode(cp);
		return NULL;
	}
	else {
		popfin();
		return cp;
	}
}

void
corecheck(void)
{
#ifdef CORELEFT
	long v = CORELEFT;
	if ( v >= 0 && v < *Lowcorelim ) {
		tprint("Memory is getting very low.  %d K left.  Get out while you can.\n",
			(int)(CORELEFT/1000));
	}
#endif
}

int
checkfunckey(int c)
{
	int n;

	if ( (c & FKEYBIT) == 0 )
		return 0;	/* not a function key */

	n = c & (~FKEYBIT);
	if ( n >= 0 && n < NFKEYS ) {
		Codep cp = Fkeyfunc[n];
		if ( cp )
			taskfunc0(cp);
		return 1;
	}
	return 0;
}

/* follow() - look ahead for >=, etc. */
int
follow(int expect,int ifyes,int ifno)
{
	register int ch = yyinput();

	if ( ch == expect)
		return ifyes;
	yyunget(ch);
	return ifno;
}

int
follo2(int expect1,int ifyes1,int expect2,int ifyes2,int ifno)
{
	register int ch = yyinput();

	if ( ch == expect1)
		return ifyes1;
	if ( ch == expect2)
		return ifyes2;
	yyunget(ch);
	return ifno;
}

int
follo3(int expect1,int ifyes1,int expect2,int expect3,int ifyes2,int ifyes3,int ifno)
{
	register int ch = yyinput();

	if ( ch == expect1)
		return ifyes1;
	if ( ch == expect2) {
		int ch3 = yyinput();
		if ( ch3 == expect3 )
			return ifyes3;
		yyunget(ch3);
		return ifyes2;
	}
	yyunget(ch);
	return ifno;
}


int
eatpound(void)
{
	int c;

	/* comments extend from a '#' (at the beginning of a word) */
	/* to the end of the line. */
	for ( ;; ) {
		c = yyinput();
		if ( c == EOF )
			break;
		if ( c == '\n' || c == '\r' ) {
			Pyytext--;	/* get rid of the newline */
			break;
		}
	}
	*Pyytext = '\0';

	/* Could be a macro or #include, though */

	if ( strncmp("#define",Yytext,7) == 0 )
		macrodefine(Yytext+7,1);
	else if ( strncmp("#include",Yytext,8) == 0 )
		pinclude(Yytext+8);
	else if ( strncmp("#library",Yytext,8) == 0 )
		mdep_popup("#library in eatpound() no longer recognized!");
	return(1);
}

void
plibrary(char *dir,char *s)
{
	long lng = (long)strlen(s);
	char *wrd1 = (char *) kmalloc(lng,"plibrary");
	char *wrd2 = (char *) kmalloc(lng,"plibrary");
	if ( sscanf(s,"%s %s",wrd1,wrd2) != 2 )
		eprint("Improper '#library' statement!\n");
	else
		addplibrary(dir,wrd1,wrd2);
	kfree(wrd1);
	kfree(wrd2);
}

void
load1keylib(char *dir, char *keylibk)
{
	FILE *f;
	char buff[BUFSIZ];

	OPENTEXTFILE(f,keylibk,"r");
	if ( Errfileit )
		tprint("Loading keylib: %s\n",keylibk);
	if ( f != NULL ) {
		while ( myfgets(buff,BUFSIZ,f) != NULL ) {
			if ( strncmp(buff,"#library",8)==0 )
				plibrary(dir,buff+8);
		}
		myfclose(f);
	}
}

void
loadkeylibk(void)
{
	/* Go through all the directories in the Keypath, and load all the */
	/* keylib.k files (if they exist) */
	static int pathsize = 0;
	static char **pathparts = NULL;
	static char *lastkeypath = NULL;
	static char *pathfname = NULL;	/* result is kept here */

	(void) pathsearch("keylib.k",&pathsize,&pathparts,
			&lastkeypath,&pathfname,Keypath,load1keylib);
}

void
addplibrary(char *dir,char *fname,char *funcname)
{
	char buff[BUFSIZ];
	Hnodep h;

	if ( mdep_makepath(dir,fname,buff,BUFSIZ) ) {
		mdep_popup("mdep_makepath fails?");
		return;
	}
	h = hashtable(Keylibtable,strdatum(uniqstr(funcname)),H_INSERT);
	if ( isnoval(h->val) ) {
		h->val = strdatum(uniqstr(buff));
	}
}

void
pinclude(char *s)
{
	char *p, *p1 = NULL;
	char *fname;

	/* isolate the file name (getting rid of quotes) */
	while ( isspace(*s) )
		s++;
	if ( *s == '"' ) {
		p1 = ++s;
		for ( p=p1; *p; p++ ) {
			if ( *p == '"' ) {
				*p = '\0';
				break;
			}
		}
	}
	else {
		p1 = s;
		for ( p=p1; *p; p++ ) {
			if ( isspace(*p) ) {
				*p = '\0';
				break;
			}
		}
	}
	fname = kpathsearch(p1);
	if ( fname ) {
		FILE *f;
		OPENTEXTFILE(f,fname,"r");
		if ( f )
			pushfin(f,fname,1);
		else
			eprint("%s: can't open %s (%s)\n",
					Progname,fname,strerror(errno));
	}
	else {
		eprint("#include failed, can't find '%s' ?!\n",p1);
	}
}

#define skipspace(s) while(isspace(*s))s++

typedef struct Macro {
	char *name;
	char **params;
	int nparams;
	char *value;
	struct Macro *next;
} Macro;

static Macro *Topmac = NULL;

/* Scan the macro definition in s, creating a new Macro structure. */
void
macrodefine(char *s,int checkkeyword)
{
	char *p, *nm;
	Macro *m;
	int n, echar;
	Symbolp sym;
#ifdef __GNUC__
	/* This is because in GNU C, constant strings (e.g. those */
	/* passed to macrodefine()) are not writable by default. */
	char buffer[strlen(s)+1];
	(void) strcpy(buffer,s);
	s = buffer;
#endif

	skipspace(s);
	for ( p=s; isnamechar(*p); p++ )
		;
	echar = *p;
	if ( echar != '\0' )
		*p++ = '\0';
	nm = uniqstr(s);

	if ( checkkeyword ) {
		sym = findsym(nm,Keywords);
		if ( sym ) {
			eprint("Can't #define an existing symbol: %s\n",nm);
			return;
		}
	}
	sym = findsym(nm,Macros);
	if ( sym == 0 )
                (void) syminstall(nm,Macros,MACRO);
	else if ( sym->stype == UNDEF )
		sym->stype = MACRO;
	else if ( sym->stype != MACRO ) {
	}
	m = (Macro *) kmalloc(sizeof(Macro),"macrodefine");
	m->name = nm;
	skipspace(p);
	if ( echar != '(' ) {
		/* Macro has no parameters */
		m->nparams = 0;
		m->value = uniqstr(p);
	}
	else {
		char **pp, *param, *params[NPARAMS];
		int nparams = 0;

		/* Gather parameter names */
		do {
			if ( nparams >= NPARAMS )
				execerror("Too many macro parameters!  Increase NPARAMS!");
			skipspace(p);
			param = p;
			echar = scanparam(&p);
			params[nparams++] = uniqstr(param);
		} while ( echar == ',' );

		if ( echar != ')' )
			execerror("Improper #define format");

		skipspace(p);
		m->value = uniqstr(p);

		m->nparams = nparams;
		if ( nparams > 0 ) {
			pp=(char **)kmalloc(nparams*sizeof(char *),"macrodefine2");
			for ( n=0; n<nparams; n++ )
				pp[n] = params[n];
			m->params = pp;
		}
	}
	m->next = Topmac;
	Topmac = m;
}

int
scanparam(char **ap)
{
	register char *p = *ap;
	int echar;

	while ( isnamechar(*p) )
		p++;
	echar = *p;
	*p++ = '\0';
	*ap = p;
	return(echar);
}

/* Check to see if name is a macro, and if so, substitute its value (possibly*/
/* gathering the arguments and substituting them in the macro definition). */
/* The macro value is stuffed back onto the input stream. */
void
macroeval(char *name)
{
	Macro *m;
	char *p, *q, *sofar, *args[NPARAMS];
	char *buff, *errstr;
	int c, n, nparams, echar;
	char ch;

	for ( m=Topmac; m!=NULL; m=m->next ) {
		if ( name == m->name )
			break;
	}
	if ( m == NULL )
		return;

	if ( ++Macrosused > 10 )
		execerror("Macros too deeply nested (recursive?)");

	if ( m->nparams <= 0 ) {
		stuffword(m->value);
		return;
	}
	/* The macro has parameters */
	while ( (c=yyinput()) != EOF && c != '(' )
		;
	nparams = m->nparams;

	buff = kmalloc(Buffsize,"macroeval");

	for ( n=echar=0; echar != ')' ; n++ ) {
		p = scantill("),",buff,buff+Buffsize);
		if ( p == NULL ) {
			errstr = "Non-terminated call to macro";
			goto err;
		}
		echar = *--p;
		*p = '\0';	/* get rid of terminating ',' or ')' */
		if ( n < nparams ) {
			args[n] = strsave(buff);	/* NOT uniqstr */
		}
	}
	if ( n > nparams ) {
		errstr = "Too many arguments in call to macro";
		goto err;
	}
	if ( n < nparams ) {
		errstr = "Too few arguments in call to macro";
		goto err;
	}

	/* now stuff the macro replacement value, and substitute any */
	/* parameters we find. */
	p = m->value;
	sofar = buff;
	while ( (ch=(*p++)) != '\0' ) {
		*sofar = ch;
		if ( ! isnamechar(ch) ){
			sofar++;
			continue;
		}
		/* we've seen the start of a name; grab the rest */
		q = sofar+1;
		while ( isnamechar(*p) )
			*q++ = *p++;
		*q = '\0';
		/* see if it's a parameter name */
		for ( n=0; n < nparams; n++ ) {
			if ( strcmp(m->params[n],sofar) == 0 )
				break;
		}
		/* if it is a parameter, substitute the value */
		if ( n < nparams )
			strcpy(sofar,args[n]);
		sofar = strend(sofar);
	}
	*sofar = '\0';
	stuffword(buff);

	for ( n=0; n < nparams; n++ )
		kfree(args[n]);
	kfree(buff);
	return;

    err:
	kfree(buff);
	execerror("%s %s",errstr,m->name);
	return;		 /* should be NOTREACHED*/
}

char *
scantill(char *lookfor,char *buff,char *pend)
{
	register char *p = buff;
	register int ch;

	while ( (ch=yyinput()) != EOF ) {

		if ( p >= pend )
			execerror("Too much macro expansion!");

		*p++ = ch;
		/* if we find one of the characters we're looking for... */
		if ( strchr(lookfor,ch) != NULL )
			return(p);

		switch ( ch ) {
		case '(': p = scantill(")",p,pend); break;
		case '{': p = scantill("}",p,pend); break;
		case '[': p = scantill("]",p,pend); break;
		case '"': p = scantill("\"",p,pend); break;
		case '\'': p = scantill("'",p,pend); break;
		}
	}
	return(NULL);
}

void
readkeylibs(void)
{
	if ( Keylibtable == NULL ) {
		char *p = getenv("KEYLIBHASHSIZE");
		Keylibtable = newht ( p ? atoi(p) : 251 );
	}
	loadkeylibk();
}

Symstr
filedefining(char *fnc)
{
	static int first = 1;
	Hnodep h;

	if ( first ) {
		first = 0;
		readkeylibs();
	}
	h = hashtable(Keylibtable,strdatum(fnc),H_LOOK);
	if ( h ) {
		return ( h->val.u.str );	/* filename */
	}
	return NULL;
}

/* loadsym - Attempt to load a function definition for a symbol. */
/*           This should only be used for global variables. */
/*           If pushit is set, the value of the symbol is pushed */
/*           on the stack (even if a value isn't found). */
int
loadsymfile(Symbolp s,int pushit)
{
	Symstr fname;
	Symstr sname;
	FILE *f = NULL;
	int errs = 0;
	Codep cp;

	sname = symname(s);
	fname = filedefining(sname);

	if ( fname )
		OPENTEXTFILE(f,fname,"r");

	if ( f == NULL ) {
		if ( pushit ) {
			pushexp(s->sd);
		}
		return 1;
	}

	if ( *Loadverbose )
		tprint("Loading %s\n",fname);
	pushfin(f,fname,0);

	pushiseg();

	Errors = 0;
	yyparse();
	errs = Errors;

	/* We need to push the loaded value right away, because */
	/* nestinstruct() is going to push some other garbage */
	/* on the stack. */
	if ( pushit ) {
		pushexp(s->sd);
	}

	cp = popiseg();
	if ( errs > 0 )
		freecode(cp);
	else
		nestinstruct(cp);

	popfin();
	myfclose(f);

	if ( isnoval(s->sd) ) {
		eprint("Warning: no value for '%s' found in file '%s' !?\n",
			symname(s),fname);
	}

	return(errs);
}

Phrasep
filetoph(FILE *f,char *fname)
{
	Phrasep p;

	pushfin(f,fname,0);
	p = yyphrase(yyinput);
	popfin();
	return p;
}

char *
kpathsearch(char *fname)
{
	static int pathsize = 0;
	static char **pathparts = NULL;
	static char *lastkeypath = NULL;
	static char *pathfname = NULL;	/* result is kept here */

	return pathsearch(fname,&pathsize,&pathparts,
			&lastkeypath,&pathfname,Keypath,(PATHFUNC)NULL);
}

char *
mpathsearch(char *fname)
{
	static int pathsize = 0;
	static char **pathparts = NULL;
	static char *lastkeypath = NULL;
	static char *pathfname = NULL;	/* result is kept here */

	return pathsearch(fname,&pathsize,&pathparts,
			&lastkeypath,&pathfname,Musicpath,(PATHFUNC)NULL);
}

/* Seach a path for a file, and return a static (ie. reused on subsequent */
/* calls) buffer of full path. This routine is confusingly generalized */
/* so it can be used for searching both Keypath and Musicpath. */

char *
pathsearch(char *fname,long *apathsize,char ***apathparts,Symstrp alastkeypath,char **apathfname,Symstrp pathvar,PATHFUNC pfunc)
{
	char *kp;
	long needed;
	int pn = 0;

	if ( *apathparts == NULL || *alastkeypath != *pathvar ) {
		if ( *apathparts != NULL )
			kfree(*apathparts);
		*apathparts = makeparts(*pathvar);
		*alastkeypath = *pathvar;
	}

	needed = Maxpathleng + (long)strlen(fname) + 8;
	if ( needed > *apathsize ) {
		if ( *apathfname != NULL )
			kfree(*apathfname);
		*apathfname = kmalloc((unsigned)needed,"kpathsearch");
		*apathsize = needed;
	}

	/* for absolute and relative path names, there is no search */
	if ( mdep_full_or_relative_path(fname) ) {
		strcpy(*apathfname,fname);
		return(*apathfname);
	}

	while ( (kp=(*apathparts)[pn++]) != NULL ) {

		/* combine directory and filename */
		if ( mdep_makepath(kp, fname, *apathfname, *apathsize) ) {
			mdep_popup("mdep_makepath fails?");
			continue;
		}
		if ( pfunc == NULL ) {
			if ( exists(*apathfname) )
				return(*apathfname);
		}
		else {
			/* Note that pfunc gets called for ALL found files, */
			/* it doesn't abort after finding the first one. */
			if ( exists(*apathfname) )
				(*pfunc)(kp,*apathfname);
		}
	}
	return(NULL);
}

/*
 * Break a KEYPATH into Pathsep-separated parts.
 * Pathsep can be escaped.
 */
char **
makeparts(Symstr path)
{
	int nparts = 0;
	int lng;
	char *buff, *bp, *p;
	char c, sep;
	char **parts;

	buff = kmalloc(Buffsize,"makeparts");
	if ( Pathsep == NULL || *Pathsep == NULL )
		execerror("bad Pathsep value!?");
	sep = **Pathsep;

	/* count to get the (maximum) # of parts */
	p = path;
	while ( *p != '\0' ) {
		if ( *p++ == sep )
			nparts++;
	}
	parts = (char **) kmalloc((nparts+2)*sizeof(char *),"makeparts");
	bp = buff;
	nparts = 0;
	c = 1;	/* just to be non-0 */

	for ( p=path; c != '\0' ; ) {

		c = *p++;
		if ( c == sep || c == '\0' ) {
			*bp = '\0';

			/* An empty value is equivalent to the current directory */
			if ( *buff == '\0' )
				mdep_currentdir(buff,Buffsize);

			parts[nparts++] = uniqstr(buff);
			lng = (long)strlen(buff);
			if ( lng > Maxpathleng )
				Maxpathleng = lng;
			bp = buff;
			continue;
		}
		if ( c == '\\' ) {
			/* backslash-sep results in just sep */
			if ( *p == sep )
				c = *p++;
		}
		*bp++ = c;
	}
	parts[nparts] = NULL;
	kfree(buff);
	return(parts);
}

int
MAIN(int argc,char **argv)
{
	int nerrs = 0;
	int go_interactive = 1;
	int do_rc = 1;
	char *p;
	int c;
	int realConsolefd;

	Argv = argv;
	Argc = argc;
	p = argv[0];

	Fin = stdin;
	Fout = stdout;
	Diagfunc = mdep_popup;

	mdep_hello(argc,argv);

	realConsolefd = Consolefd;
	Consolefd = -1;

	keystart();

	while ( argc > 1 && argv[1][0] == '-' ) {

		c = argv[1][1];

		/* a '-' by itself represents stdin, and '-c' preceeds */
		/* command-line keykit statements. These both end */
		/* the processing of command-line options */
		if ( c == '\0' || c == 'c' )
			break;

		switch (c) {

		case 'p':
			if ( argv[1][2]=='\0' && argc>2 ) {
				argc--;
				argv++;
				p = argv[1];
			}
			else
				p = &argv[1][2];
			*Initconfig = uniqstr(p);
			break;
		case 'i':
			if ( argv[1][2]=='\0' && argc>2 ) {
				argc--;
				argv++;
				p = argv[1];
			}
			else
				p = &argv[1][2];
			*Initconfig = uniqstr(p);
			break;
		case 'D':
			Dbg = 1;
			break;
		case 'd':
			if ( Debug )
				(*Debug)++;
			break;
		case 'f':	/* for setting font, but handled by mdep_startgraphics() */
			if ( argv[1][2]=='\0' || argv[1][3]=='\0' ) {
				argc--;
				argv++;
			}
			break;
		case 'I':
			*Abortonint = 1;
			break;

		/* can't decide what letter to use */
		case 'e':
		case 'E':
		case 'L':
			Errfileit = 1;	/* last resort debugging */
			/* Don't clear the file here - we might have */
			/* already put stuff into it. */
			break;
		case 'n':
			/* Disable insertion of byte-codes that maintain */
			/* line numbers.  This saves memory, and possibly */
			/* CPU time, but means error messages will contain */
			/* garbage line numbers. */
			*Linetrace = 0;
			break;
		case 'r':
			do_rc = 0;
			break;
		case 't':
		case 'T':
			/* NOTE: The default value of *Linetrace (Trace) */
			/* is now 1, so the internal byte-codes that */
			/* maintain line numbers, are inserted by default. */
			/* The -t option increases *Linetrace to 2 which */
			/* will cause a complete line-level trace to */
			/* be put into the file key.err. */

			(*Linetrace)++;
			break;
		case 'y':
			yydebug++;
			break;
		default:
			eprint("Unrecognized option: -%c ??\n",c);
			break;
		}
		argc--;
		argv++;
	}

	if ( argc <= 1 ) {
		argc = 1;
		argv = stdinonly;
	}
	else {
		argc--;
		argv++;
	}

	/* I can't recall why we play this game with the Consolefd, but it */
	/* probably has something to do with end-of-file, or something.    */
	/* For startgraphics(), we restore the real Consolefd for linux.   */
	Consolefd = realConsolefd;
	startgraphics();
	Consolefd = -1;

	startrealtime();
	startreboot();

	initsyms2();	/* for stuff that gets set in startgraphics, mainly */
	if ( Errfileit )
		*Loadverbose = 1;

	ReadytoEval = 1;
	go_interactive = 1;

	while ( argc-- > 0 ) {
		char *arg = *argv++;
		char *suff = strrchr(arg,'.');

		if ( strcmp(arg,"-") == 0 ) {
			/* Start up an interactive command interpreter */
			Consolefd = realConsolefd;
			if ( do_rc ) {
				keystr("keyrc();");
				do_rc = 0;
			}
			exectasks(0);
			Consolefd = -1;

			go_interactive = 0;
			continue;
		}
		if ( strncmp(arg,"-c",2) == 0 ) {
			if ( arg[2] == '\0' ) {
				if ( argc <= 0 ) {
					mdep_popup("Missing argument after -c");
					continue;
				}
				arg = *argv++;
				argc--;
			}
			else
				arg += 2;

			keystr(arg);

			exectasks(0);
			go_interactive = 0;
			nerrs += Errors;
			continue;
		}

		/* Anything else should be the name of a file */
		if ( ! exists(arg) ) {
			sprintf(Msg1,"No such file: %s",arg);
			mdep_popup(Msg1);
			go_interactive = 0;
			nerrs++;
			continue;
		}
		if ( suff!=NULL && (strcmp(suff,".km")==0 || strcmp(suff,".KM")==0) ) {
			/* *.km arguments are mouse demos */
			sprintf(Msg1,"mousedemo(\"%s\")",arg);
			keystr(Msg1);
			go_interactive = 1;
			continue;
		}
		if ( suff!=NULL && (strcmp(suff,".kp")==0 || strcmp(suff,".KP")==0) ) {
			/* *.kp arguments automatically set Initconfig */
			*Initconfig = uniqstr(arg);
			go_interactive = 1;
			continue;
		}
		go_interactive = 0;
		keyfile(arg,FLAGERROR);
		exectasks(0);
	}
	if ( go_interactive ) {
		Consolefd = realConsolefd;
		if ( do_rc )
			keystr("keyrc();");
		exectasks(0);
		Consolefd = -1;
	}

	finalexit(nerrs);
	return(nerrs);	/* what the hey... */
}
