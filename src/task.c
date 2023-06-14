/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#define OVERLAY6

#ifdef PYTHON
#include "Python.h"
#endif
#include "key.h"
#include "gram.h"


Codep Ipop, Idosweep, Ireboot;

Ktaskp T;		/* currently-active task */
Ktaskp Running = NULL;	/* list of runnable tasks */

int Currpriority = DEFPRIORITY; /* current priority level, tasks lower */
				/* than this do not run. */

static Ktaskp Toptp = NULL;
static Ktaskp Freetp = NULL;
static long Tid = 0;

Htablep Tasktable = NULL;
int Nwaiting = 0;
int Nsleeptill = 0;

#ifdef DEBUGRUN
Ktaskp TraceT = NULL;
#endif

int Consolefd = 0;
int Displayfd = -1;
int Midifd = -1;
static int ConsoleEOF = 0;

/* The order in this list does NOT have to match the I_* values, */
/* or anything else. */
struct ilist {
	BYTEFUNC i;
	char *name;
} Ilist[] = {
	{ i_addcode, "i_addcode" },
	{ i_amp, "i_amp" },
	{ i_and1, "i_and1" },
	{ i_arrend, "i_arrend" },
	{ i_array, "i_array" },
	{ i_arraypush, "i_arraypush" },
	{ i_callfunc, "i_callfunc" },
	{ i_objvarpush, "i_objvarpush" },
	{ i_objcallfunc, "i_objcallfunc" },
	{ i_objcallfuncpush, "i_objcallfuncpush" },
	{ i_lvareval, "i_lvareval" },
	{ i_gvareval, "i_gvareval" },
	{ i_constant, "i_constant" },
	{ i_dotdotarg, "i_dotdotarg" },
	{ i_currobjeval, "i_currobjeval" },
	{ i_ecurrobjeval, "i_ecurrobjeval" },
	{ i_erealobjeval, "i_erealobjeval" },
	{ i_constobjeval, "i_constobjeval" },
	{ i_dblpush, "i_dblpush" },
	{ i_defined, "i_defined" },
	{ i_objdefined, "i_objdefined" },
	{ i_currobjdefined, "i_currobjdefined" },
	{ i_realobjdefined, "i_realobjdefined" },
	{ i_deleteit, "i_deleteit" },
	{ i_deletearritem, "i_deletearritem" },
	{ i_divcode, "i_divcode" },
	{ i_dot, "i_dot" },
	{ i_dotassign, "i_dotassign" },
	{ i_eq, "i_eq" },
	{ i_eval, "i_eval" },
	{ i_forin1, "i_forin1" },
	{ i_forin2, "i_forin2" },
	{ i_forinend, "i_forinend" },
	{ i_ge, "i_ge" },
	{ i_goto, "i_goto" },
	{ i_gt, "i_gt" },
	{ i_incond, "i_incond" },
	{ i_le, "i_le" },
	{ i_lshift, "i_lshift" },
	{ i_lt, "i_lt" },
	{ i_modassign, "i_modassign" },
	{ i_moddotassign, "i_moddotassign" },
	{ i_modulo, "i_modulo" },
	{ i_mulcode, "i_mulcode" },
	{ i_ne, "i_ne" },
	{ i_negate, "i_negate" },
	{ i_noop, "i_noop" },
	{ i_not, "i_not" },
	{ i_onchangeit, "i_onchangeit" },
	{ i_or1, "i_or1" },
	{ i_par, "i_par" },
	{ i_phrasepush, "i_phrasepush" },
	{ i_pop, "i_pop" },
	{ i_popignore, "i_popignore" },
	{ i_popnreturn, "i_popnreturn" },
	{ i_print, "i_print" },
	{ i_qmark, "i_qmark" },
	{ i_readonlyit, "i_readonlyit" },
	{ i_regexeq, "i_regexeq" },
	{ i_return, "i_return" },
	{ i_returnv, "i_returnv" },
	{ i_rightshift, "i_rightshift" },
	{ i_select1, "i_select1" },
	{ i_select2, "i_select2" },
	{ i_select3, "i_select3" },
	{ i_stop, "i_stop" },
	{ i_stringpush, "i_stringpush" },
	{ i_subcode, "i_subcode" },
	{ i_task, "i_task" },
	{ i_fcondeval, "i_fcondeval" },
	{ i_tcondeval, "i_tcondeval" },
	{ i_tilda, "i_tilda" },
	{ i_undefine, "i_undefine" },
	{ i_varassign, "i_varassign" },
	{ i_funcnamed, "i_funcnamed" },
	{ i_vareval, "i_vareval" },
	{ i_objvareval, "i_objvareval" },
	{ i_varg, "i_varg" },
	{ i_varpush, "i_varpush" },
	{ i_xorcode, "i_xorcode" },
	{ i_dosweepcont, "i_dosweepcont" },
	{ i_filename, "i_filename" },
	{ i_linenum, "i_linenum" },
	{ i_classinit, "i_classinit" },
	{ i_pushinfo, "i_pushinfo" },
	{ i_popinfo, "i_popinfo" },
	{ i_nargs, "i_nargs" },
	{ i_typeof, "i_typeof" },
	{ i_xy2, "i_xy2" },
	{ i_xy4, "i_xy4" },
	{ 0, 0 }
};

char *
funcnameof(BYTEFUNC i)
{
	int n;
	for ( n=0; Ilist[n].i != 0; n++ ) {
		if ( i == Ilist[n].i )
			return Ilist[n].name;
	}
	return NULL;
}

Ktaskp
taskptr(long tid)
{
	Hnodep h = hashtable(Tasktable,numdatum(tid),H_LOOK);
	if ( h )
		return( h->val.u.task );
	else
		return(NULL);
}

jmp_buf Begin;

void
restartexec(void)
NO_RETURN_ATTRIBUTE
{
	longjmp(Begin,1);
	/*NOTREACHED*/
}

void
makesuredefined(Datum **dpp,char *nm)
{
	Datum fd;
	fd = **dpp;
	if ( isnoval(fd) ) {
		Symbolp s = lookup(uniqstr(nm));
		loadsym(s,0);
		*dpp = symdataptr(s);
	}
}

void
checkports(void)
{
	char buff[BIGBUFSIZ];  // BIG because udp messages can be large
	int sz, i;
	PORTHANDLE port;
	Fifo *f;
	Datum ddata;

	while ( 1 ) {
		ddata = Noval;
		sz = mdep_getportdata(&port,buff,BIGBUFSIZ,&ddata);
		/* -1 indicates there's no more ports with info */
		if ( sz == -1 )
			break;

		/* See which fifo got some data */
		f = port2fifo(port);
		if ( f == NULL ) {
			eprint("Port value (%d) from mdep_getportdata not in a fifo?!",port);
			continue;
		}

		// tprint("(checkports port=%ld f=%ld sz=%d\n",(long)port,(long)f,sz);
		if ( sz <= 0 ) {
			long v;
			if ( sz == 0 ) {
				/*
				 * port has been closed from the other side
				 */
				v = *Eofval;
				flushlinebuff(f);
				/* tprint("(PORT CLOSED)"); */
			} else if ( sz == -2 ) {
				/*
				 * -2 from indicates a connection
				 * refused or interrupt or
				 * other error on the fifo.
				 */
				v = *Intrval;
			} else {
				eprint("Error from mdep_getportdata for fifo=%d",fifonum(f));
				v = *Intrval;
			}
			putfifo(f,numdatum(v));
			continue;
		}
		switch(f->fifoctl_type) {
		case FIFOTYPE_FIFO:
			{
			Datum da;
			Fifo *f0, *f1;
			PORTHANDLE *php = (PORTHANDLE*)buff;

			if ( sz != 2*sizeof(PORTHANDLE) ) {
				mdep_popup("FIFOTYPE_FIFO got unexpected size from getportdata?!");
				continue;
			}
			f0 = getafifo();
			f0->flags = FIFO_OPEN | FIFO_ISPORT | FIFO_READ;
			f0->fifoctl_type = Default_fifotype;
			f0->port = *php++;
			f1 = getafifo();
			f1->flags = FIFO_OPEN | FIFO_ISPORT | FIFO_WRITE;
			f1->fifoctl_type = Default_fifotype;
			f1->port = *php;
			da = newarrdatum(0,3);
			setarraydata(da.u.arr,Str_r,numdatum(fifonum(f0)));
			setarraydata(da.u.arr,Str_w,numdatum(fifonum(f1)));
			putfifo(f,da);
			}
			break;
		case FIFOTYPE_UNTYPED:
		case FIFOTYPE_BINARY:
			for ( i=0; i<sz; i++ )
				putfifo(f,numdatum(buff[i]));
			break;
		case FIFOTYPE_LINE:
			for ( i=0; i<sz; i++ ) {
				int c = buff[i];
				makeroom((long)(3+f->linesofar),
					&(f->linebuff),&(f->linesize));
				f->linebuff[f->linesofar++] = c;
				if ( c == '\n' ) {
					flushlinebuff(f);
				}
			}
			break;
		case FIFOTYPE_ARRAY:
			if ( isnoval(ddata) ) {
				eprint("Noval in mdep_getportdata for ARRAY fifo=%d",fifonum(f));
			} else {
				putfifo(f,ddata);
			}
			break;
		}
	}
}

static long lastexpose = 0;
static long lastresize = 0;

void
handlewaitfor(int wn)
{
	long t;
	long dt;
	long dt2;

	switch(wn){
	case K_CONSOLE:
		{
		int r = handleconsole();
		if ( r < 0 )
			tprint("handleconsole returned r=%d ?\n",r);
		if ( Gotanint )
			doanint();
		}
		break;

	case K_MOUSE:
		checkmouse();
		break;

	case K_WINDEXPOSE:
		t = MILLICLOCK;
		dt = t-lastexpose;
		if ( dt<0 ) dt = -dt;
		if ( dt >= *Redrawignoretime )
			lastexpose = t;
		if ( dt >= *Redrawignoretime ) {
			makesuredefined(&Redrawfuncd,"Redrawfunc");
			taskfunc0(Redrawfuncd->u.codep);
		}
		break;

	case K_WINDRESIZE:
		t = MILLICLOCK;
		dt = t-lastresize;
		if ( dt<0 ) dt = -dt;
		setwrootsize();
		if ( dt >= *Resizeignoretime )
			lastresize = t;
		if ( dt >= *Resizeignoretime ) {
			makesuredefined(&Resizefuncd,"Resizefunc");
			taskfunc0(Resizefuncd->u.codep);
		}
		break;

	/* mdep_waitfor() really shouldn't return multiple values, */
	/* but it does on Linux. */
	case K_WINDEXPOSE | K_WINDRESIZE:
		t = MILLICLOCK;
		dt = t-lastexpose;
		dt2 = t-lastresize;
		if ( dt<0 ) dt = -dt;
		if ( dt2<0 ) dt2 = -dt2;
		/*
		 * I think there's a bug on linux (perhaps on all systems)
		 * that causes the value of t to change after taskfunc0
		 * is called, so we make use of t before doing anything else.
		 * BOGUS!
		 */
		if ( dt >= *Redrawignoretime )
			lastexpose = t;
		if ( dt2 >= *Resizeignoretime )
			lastresize = t;
		setwrootsize();
		if ( dt2 >= *Resizeignoretime ) {
			makesuredefined(&Resizefuncd,"Resizefunc");
			taskfunc0(Resizefuncd->u.codep);
		}
		if ( dt >= *Redrawignoretime ) {
			makesuredefined(&Redrawfuncd,"Redrawfunc");
			taskfunc0(Redrawfuncd->u.codep);
		}
		break;

	case K_PORT:
		checkports();
		break;
	case K_MIDI:
		break;
	case K_NOTHING:
		break;
	case K_QUIT:
		{
			static int gotexit = 0;	 /* only call Exitfunc once */
			if ( gotexit == 0 ) {
				makesuredefined(&Exitfuncd,"Exitfunc");
				taskfunc0(Exitfuncd->u.codep);
				gotexit = 1;
			}
		}
		break;
	case K_TIMEOUT:
		break;
	default:
		eprint("Bad value given to handlewaitfor() - %d\n",wn);
		break;
	}
}

#ifdef PYTHON
PyThreadState * KeyPyState = NULL;
#endif

char *Bytenames[] = {
	"i_pop",
	"i_dblpush",
	"i_stringpush",
	"i_phrasepush",
	"i_arrend",
	"i_arraypush",
	"i_incond",
	"i_divcode",
	"i_par",
	"i_amp",
	"i_lshift",
	"i_rightshift",
	"i_negate",
	"i_tilda",
	"i_lt",
	"i_gt",
	"i_le",
	"i_ge",
	"i_ne",
	"i_eq",
	"i_regexeq",
	"i_and1",
	"i_or1",
	"i_not",
	"i_noop",
	"i_popignore",
	"i_defined",
	"i_objdefined",
	"i_currobjdefined",
	"i_realobjdefined",
	"i_task",
	"i_undefine",
	"i_dot",
	"i_modulo",
	"i_addcode",
	"i_subcode",
	"i_mulcode",
	"i_xorcode",
	"i_dotassign",
	"i_moddotassign",
	"i_modassign",
	"i_varassign",
	"i_deleteit",
	"i_deletearritem",
	"i_readonlyit",
	"i_onchangeit",
	"i_eval",
	"i_vareval",
	"i_objvareval",
	"i_funcnamed",
	"i_lvareval",
	"i_gvareval",
	"i_varpush",
	"i_objvarpush",
	"i_callfunc",
	"i_objcallfuncpush",
	"i_objcallfunc",
	"i_array",
	"i_linenum",
	"i_filename",
	"i_forin1",
	"i_forin2",
	"i_popnreturn",
	"i_stop",
	"i_select1",
	"i_select2",
	"i_select3",
	"i_print",
	"i_goto",
	"i_fcondeval",
	"i_tcondeval",
	"i_constant",
	"i_dotdotarg",
	"i_varg",
	"i_currobjeval",
	"i_constobjeval",
	"i_ecurrobjeval",
	"i_erealobjeval",
	"i_returnv",
	"i_return",
	"i_qmark",
	"i_forinend",
	"i_dosweepcont",
	"i_classinit",
	"i_pushinfo",
	"i_popinfo",
	"i_nargs",
	"i_typeof",
	"i_xy2",
	"i_xy4"
};

/* The order in this list MUST match the values of the I_* macros */
BYTEFUNC Bytefuncs[] = {
	i_pop,
	i_dblpush,
	i_stringpush,
	i_phrasepush,
	i_arrend,
	i_arraypush,
	i_incond,
	i_divcode,
	i_par,
	i_amp,
	i_lshift,
	i_rightshift,
	i_negate,
	i_tilda,
	i_lt,
	i_gt,
	i_le,
	i_ge,
	i_ne,
	i_eq,
	i_regexeq,
	i_and1,
	i_or1,
	i_not,
	i_noop,
	i_popignore,
	i_defined,
	i_objdefined,
	i_currobjdefined,
	i_realobjdefined,
	i_task,
	i_undefine,
	i_dot,
	i_modulo,
	i_addcode,
	i_subcode,
	i_mulcode,
	i_xorcode,
	i_dotassign,
	i_moddotassign,
	i_modassign,
	i_varassign,
	i_deleteit,
	i_deletearritem,
	i_readonlyit,
	i_onchangeit,
	i_eval,
	i_vareval,
	i_objvareval,
	i_funcnamed,
	i_lvareval,
	i_gvareval,
	i_varpush,
	i_objvarpush,
	i_callfunc,
	i_objcallfuncpush,
	i_objcallfunc,
	i_array,
	i_linenum,
	i_filename,
	i_forin1,
	i_forin2,
	i_popnreturn,
	i_stop,
	i_select1,
	i_select2,
	i_select3,
	i_print,
	i_goto,
	i_fcondeval,
	i_tcondeval,
	i_constant,
	i_dotdotarg,
	i_varg,
	i_currobjeval,
	i_constobjeval,
	i_ecurrobjeval,
	i_erealobjeval,
	i_returnv,
	i_return,
	i_qmark,
	i_forinend,
	i_dosweepcont,
	i_classinit,
	i_pushinfo,
	i_popinfo,
	i_nargs,
	i_typeof,
	i_xy2,
	i_xy4
};

void
exectasks(int nosetjmp)
{
	int wn, b;
	long tmout, ccnt, thcnt;

#ifdef PYTHON
	Py_BEGIN_ALLOW_THREADS

	// { PyThreadState *_save;
	// 	_save = PyEval_SaveThread();

	// KeyPyState = PyEval_SaveThread();
#endif

	if ( (!nosetjmp) )
		setjmp(Begin);

	setintcatch();

	thcnt = ccnt = 0;
	int nbytenames = sizeof(Bytenames)/sizeof(Bytenames[0]);

	for ( ;; ) {

		/* The value of Throttle controls how many instructions */
		/* will be interpreted per each check of realtime stuff. */
		if ( ++thcnt <= *Throttle )
			goto runit;
		thcnt = 0;

		if ( Gotanint ) {
			doanint();
			goto runit;
		}

		if ( Running != NULL )
			tmout = 0;
		else {
			if ( Nblocked<=0 && Nwaiting <= 0
				&& Nsleeptill <= 0 ) {
				break;	/* quit exectasks */
			}
			if ( Topsched!=NULL ) {
				/* OPTIMIZE!! */
				tmout = (Topsched->clicks - *Now)*((Tempo/1000)/(*Clicks));
				tmout -= *Prepoll;
				if ( tmout < 0 )
					tmout = 0;
			}
			else
				tmout = *Deftimeout;
		}
		wn = mdep_waitfor((int)tmout);

		/* Handle MIDI I/O right away. */
		chkoutput();
		chkinput();

		switch(wn){
		case 0:
			mdep_popup("Warning, mdep_waitfor returned 0!");
			break;
		case K_TIMEOUT:
			break;
		default:
			handlewaitfor(wn);
			break;
		}

	runit:

		for ( T=Running; T!=NULL; T=T->nextrun ) {

			if ( T->priority < Currpriority )
				continue;
				
			b = SCAN_FUNCCODE(Pc);
			if ( b >= nbytenames || b < 0 ) {
				fatalerror("Invalid byte code!!\n");
				continue;
			}
			T->cnt++;

			/* TADA!!!  This runs 1 interpreted instruction. */
			(*(Bytefuncs[b]))();

			if ( T == NULL )
				break;
		}

		if ( (Chkstuff!=0) && (ccnt-- <= 0) ) {
			if ( Tobechecked != NULL ) phcheck();
			if ( Htobechecked != NULL ) htcheck();
			Chkstuff = 0;
			ccnt = (int)*Checkcount;
		}

	}
	T = NULL;

#ifdef PYTHON
	Py_END_ALLOW_THREADS

	// PyEval_RestoreThread(_save); }

	// PyEval_RestoreThread(KeyPyState);
#endif
}

void
loadsym(Symbolp s,int pushit)
{
	int nerrs;
	Datum d;

#ifdef TRYTHISEVENTUALLY
	clearsym(s);
	*symdataptr(s) = Noval;
#endif
	nerrs = loadsymfile(s,pushit);
	if ( nerrs > 0 ) {
		/* no file was found to define it */
		clearsym(s);
		s->stype = VAR;
		*symdataptr(s) = Noval;
		return;
	}
	d = *symdataptr(s);
	if ( isnoval(d) )
		execerror("No value found for %s!?\n",symname(s));
}

void
i_vareval(void)
{
	execerror("i_vareval should never actually be called!");
}

void
i_objvareval(void)
{
	Symbolp s;
	Kobjectp o, fo;
	Symstr p;
	Datum d, d2;

	popinto(d);
	if ( d.type != D_STR )
		execerror("object variable expression expects a string, but got %s!\n",atypestr(d.type));
	p = d.u.str;

	popinto(d2);
	if ( d2.type != D_OBJ )
		execerror("object expression expects an object, but got %s!",atypestr(d2.type));
	o = d2.u.obj;

	s = findobjsym(p,o,&fo);
	if ( s == NULL ) {
		execerror("No element '%s' in object $%ld !?",
			p,o->id);
	}
	if ( T->obj->id != o->id && T->realobj->id != o->id )
		execerror("Element .%s of $%ld can't be accessed from outside!",p,o->id);
	d = *symdataptr(s);
	pushm(d);
}

void
i_funcnamed(void)
{
	Symbolp s;
	Datum d, retd;

	popinto(d);
	if ( d.type != D_STR )
		execerror("function() expects a string, but got %s!",atypestr(d.type));
	s = findsym(d.u.str,Topct->symbols);
	if ( s == NULL || s->stype == UNDEF ) {
		s = globalinstall(d.u.str,VAR);
		loadsym(s,1);
	}
	else {
		retd = *symdataptr(s);
		pushm(retd);
	}
}

/* evaluation of a local variable */
void
i_lvareval(void)
{
	Symbolp s;
	Datum d;
	int sp;

	s = use_symcode();
	sp = s->stackpos;

	/* handle unsigned characters and broken compilers */
	if ( sp > 127 )
		sp -= 256;

	if ( sp > 0 ) {
		/* It's one of the parameter variables */
		d = ARG(sp - 1);
	}
	else {
		/* It's one of the local variables */
		Datum *dp = T->stackframe - FRAMEHEADER + sp + 1;
		d = *dp;
	}

	if ( isnoval(d) )
		execerror("no value for variable \"%s\", \n",symname(s));
	pushm(d);
}

/* evaluation of a global variable */
void
i_gvareval(void)
{
	Symbolp s;

	s = use_symcode();
	switch(s->stype){
	case VAR:
		if ( s->sd.type==D_CODEP && s->sd.u.codep==NULL ) {
			/* e.g., when a function has a syntax */
			/* error the first time it's read. */
			loadsym(s,1);
		}
		else {
			pushexp(s->sd);
		}
		break;
	case UNDEF:
		/* try to find a function definition for it */
		loadsym(s,1);

		/* I don't think this test really works... */
		if ( s->sd.type == D_CODEP && s->sd.u.codep == NULL ) {
			eprint("Unable to find a definition for a function named '%s' !!",symname(s));
			s->sd = Noval;
		}
		break;
	default:
		execerror("Unexpected value in IVAREVAL!");
	}
}

void
i_varpush(void)
{
	Datum d;

	d.u.sym = use_symcode();
	d.type = D_SYM;
	pushm_notph(d);
}

void
i_objvarpush(void)
{
	Datum d, d2;
	Symbolp s;
	Kobjectp obj;
	Symstr p;

	popinto(d);
	if ( d.type != D_STR )
		execerror("object expression expects a string, but got %s!\n",atypestr(d.type));
	p = d.u.str;
	popinto(d2);
	if ( d2.type != D_OBJ )
		execerror("object expression expects an object, but got %s!\n",atypestr(d2.type));
	obj = d2.u.obj;
	if ( obj == NULL )
		execerror("Internal error, obj==NULL in objvarpush!?");
	if ( obj->symbols == NULL )
		execerror("Internal error, symbols==NULL in objvarpush!?");
	if ( obj->id != T->obj->id && obj->id != T->realobj->id )
		execerror("Element .%s of object $%ld can only be set from within a method!",p,obj->id);
	s = syminstall(p,obj->symbols,VAR);	/* NOT findobjsym */
	pushexp(symdatum(s));
}

void
i_callfunc(void)
{
	Symbolp s;

	s = use_symcode();
	callfuncd(s);
}

void
i_objcallfuncpush(void)
{
	Symbolp s;
	Datum d1, d2, d;
	Kobjectp o, fo;
	Symstr p;

	popinto(d1);
	if ( d1.type != D_STR )
		execerror("object expression expects a string, but got %s!\n",atypestr(d1.type));
	p = d1.u.str;

	popinto(d2);
	if ( d2.type != D_OBJ )
		execerror("Attempt to call object method (%s) on a non-object value!?",p);
	o = d2.u.obj;

	s = findobjsym(p,o,&fo);
	if ( s == NULL ) {
		execerror("Element '%s' of object $%ld doesn't exist!?",
			p,o->id);
	}

	/* We want to push the function, object, and method. */

	d = *symdataptr(s);
	if ( d.type != D_CODEP ) {
		execerror("Element '%s' of object $%ld isn't a function!?  (it's %s)",
			p,fo->id,atypestr(d.type));
	}
	pushnoinc(d);
	d = objdatum(o);
	pushnoinc(d);
	d = objdatum(fo);
	pushnoinc(d);
	d = strdatum(p);
	pushnoinc(d);
}

void
i_objcallfunc(void)
{
	Symbolp s;

	s = use_symcode();
	callfuncd(s);
}

void
i_array(void)
{
	long nitems;
	Datum a, d1, d2;
	int n;

	nitems = use_numcode();	/* size of array list */
	a = newarrdatum(0,(int)nitems);
	for ( n=0; n<nitems; n++ ) {
		popnodecr(d1);
		popnodecr(d2);
		setarraydata(a.u.arr,d2,d1);
	}
	pushexp(a);
}

void
filelinetrace(void)
{
	char *fn = T->filename;
	if ( fn == NULL || *fn == '\0' )
		fn = "(NULL)";
	keyerrfile("Task=%d File=%s Line=%ld\n",T->tid,fn,T->linenum);
}

void
i_linenum(void)
{
	T->linenum = use_numcode();
	if ( *Linetrace > 1 )
		filelinetrace();
}

void
i_filename(void)
{
	T->filename = use_strcode();
#ifdef TRYWITHOUT
	if ( *Linetrace > 1 )
		filelinetrace();
#endif
}

int
printmeth(Hnodep h)
{
	Datum d;
	d = h->val;
	keyerrfile("printmeth  d.type=%s\n",atypestr(d.type));
	if ( d.type == D_SYM ) {
		keyerrfile("method=%s\n",symname(d.u.sym));
	}
	return(0);
}

void
i_pushinfo(void)
{
	Datum d;
	long currlinenum = T->linenum;
	char *currfilename = T->filename;

	popinto(d);
	if ( d.type != D_NUM )
		execerror("Internal error, i_pushinfo expected a D_NUM!?");
	T->linenum = d.u.val;

	popinto(d);
	if ( d.type != D_STR )
		execerror("Internal error, i_pushinfo expected a D_STR!?");
	T->filename = d.u.str;

	pushnum(currlinenum)
	pushexp(strdatum(currfilename));
}

void
i_popinfo(void)
{
	Datum d;

	popinto(d);
	if ( d.type != D_STR )
		execerror("Hey, i_popinfo didn't get D_STR? got %s\n",atypestr(d.type));
	else
		T->filename = d.u.str;
	popinto(d);
	if ( d.type != D_NUM )
		execerror("Hey, i_popinfo didn't get D_NUM? got %s\n",atypestr(d.type));
	else
		T->linenum = d.u.val;
}

void
i_typeof(void)
{
	Datum d;
	char *p;

	popinto(d);
	if ( isnoval(d) )
		p = "<Uninitialized>";
	else
		p = atypestr(d.type);
	/* remove initial "a " or "an " */
	if ( *(p+1) == ' ' )
		p += 2;
	else if ( *(p+2) == ' ' )
		p += 3;
	pushstr(uniqstr(p));
}

void
i_xy2(void)
{
	Datum d1, d2, r;
	long x0, y0;

	popinto(d1);
	popinto(d2);
	y0 = neednum("xy",d1);
	x0 = neednum("xy",d2);
	r = xyarr(x0,y0);
	pushm(r);
}

void
i_xy4(void)
{
	Datum d1, d2, d3, d4, r;
	long x0, y0, x1, y1;

	popinto(d1);
	popinto(d2);
	popinto(d3);
	popinto(d4);
	y1 = neednum("xy",d1);
	x1 = neednum("xy",d2);
	y0 = neednum("xy",d3);
	x0 = neednum("xy",d4);
	r = xy01arr(x0,y0,x1,y1);
	pushm(r);
}

void
i_nargs(void)
{
	Datum d, *frm, *arg0;
	int npassed, n;

	/* We work in this stackframe */
	frm = T->stackframe;
	npassed = numval(*npassed_of_frame(frm));
	arg0 = arg0_of_frame(frm);
	for ( n=0; n<npassed; n++ ) {
		d = *(arg0+n);
		if ( isnoval(d) )
			break;
	}
	pushnum(n)
}

void
i_classinit(void)
{
	Datum d, d2;
	Symbolp sym;
	Kobjectp o;

	d = ARG(0);
	if ( d.type == D_OBJ )
		o = d.u.obj;
	else
		o = defaultobject(newobjectid(),COMPLAIN);
	if ( o==NULL || o->id <= 0 )
		execerror("Internal error, invalid object in i_classinit!?");
	if ( o->symbols == NULL )
		execerror("Internal error, o->symbols==NULL in i_classinit?");

	/* There are pairs of values on the stack (method function and name),*/
	/* terminated by the class name. */
	while ( 1 ) {
		popinto(d);
		if ( d.type == D_STR )
			break;
		popinto(d2);
		/* d is the function, d2 is the method name */
		sym = syminstall(uniqstr(d2.u.str),o->symbols,VAR);
		*symdataptr(sym) = d;
	}

	/* The name of the class is put into a data element */
	/* (named "class") in the object. */
	setdata(o,"class",d);

	/* hashvisit(o->symbols,printmeth); */

	/* This will be the return value of the class function. */
	pushexp(objdatum(o));

	/* Now push the initial stuff on the stack that is necessary */
	/* to call the "init" method of this object.  The rest of the */
	/* necessary stuff for this method invocation is done in the yacc */
	/* grammar. */

	sym = findsym(Str_init.u.str,o->symbols);
	if ( sym == NULL )
		execerror("No init method found in i_classinit\n");

	d = *symdataptr(sym);
	pushexp(d);

	d.u.obj = o;
	d.type = D_OBJ;
	pushm_notph(d);

	d.u.obj = o;
	d.type = D_OBJ;
	pushm_notph(d);

	d = Str_init;
	pushm_notph(d);
}

void
i_forin1(void)
{
	Symbolp s;
	Datum d;
	Codep i1;

	i1 = use_ipcode();
	s = use_symcode();
	popinto(d);

	pushexp(codepdatum(i1));	/* for final jumping out of loop */
	pushexp(symdatum(s));
	if ( d.type == D_PHR ) {
		pushexp(notedatum(firstnote(d.u.phr)));
		pushexp(phrdatum(d.u.phr));
	}
	else if ( d.type == D_ARR ) {
		int asize;
		Datum *alist;

		alist = arrlist(d.u.arr,&asize,(int)(*Arraysort!=0));
		pushexp(numdatum(0L));
		pushexp(datumdatum(alist));
	}
	else
		execerror("'for(var in expr)' only works on phrases and arrays!");
	/* This is a hack, so that ret() won't complain when stuff */
	/* is left on the stack - which happens when you return() */
	/* directly out of a "for(x in y)" loop. */
	pushexp(numdatum(FORINJUNK));
}

void
i_forin2(void)
{
	Datum d, d2, d3;

	/* don't pop the stuff, we just use it in-place */

	if ( Stackp < (Stack+4) )
		execerror("IFORIN2 detects low stack?!");
	d = *(Stackp-2);
	d2 = *(Stackp-3);
	d3 = *(Stackp-4);
	if ( d3.type != D_SYM )
		execerror("IFORIN2 didn't get symbol!?");
	if ( d.type == D_PHR ) {
		Noteptr nt;
		Phrasep ph;
		if ( d2.u.note == NULL ) {
			forinjumptoend();
			return;
		}
		clearsym(d3.u.sym);
		phrvarinit(d3.u.sym);	/* new phrase */
		nt = ntcopy(d2.u.note);
		ph = symdataptr(d3.u.sym)->u.phr;
		ntinsert(nt,ph);
		ph->p_leng = endof(nt);
		(Stackp-3)->u.note = nextnote(d2.u.note);
	}
	else if ( d.type == D_DATUM ) {
		Datum subd;
		long v1;

		v1 = d2.u.val;
		subd = *(d.u.datum+v1);
		if ( isnoval(subd) ) {
			forinjumptoend();
			return;
		}
		clearsym(d3.u.sym);
		d3.u.sym->stype = VAR;
		*symdataptr(d3.u.sym) = subd;
		(Stackp-3)->u.val = v1 + 1;
	}
	else
		execerror("IFORIN2 got unexpected type!?");
}

void
i_popnreturn(void)
{
	Datum d;

	popinto(d);
	ret(d);
}

void
i_stop(void)
{
	Datum d;

	popinto(d);
	if ( d.type != D_CODEP )
		execerror("ISTOP got %s (numval=%ld) (expected D_CODEP), Task=%ld!  val=%ld",atypestr(d.type),numval(d),T->tid,d.u.val);
	Pc = d.u.codep;
	if ( Pc )
		return;

	if ( T->nested > 0 ) {
		Datum d1, d2, d3;

		if ( T->rminstruct )
			freecode(T->first);
		popinto(d1);	/* rminstruct */
		popinto(d2);	/* first */
		popinto(d3);	/* pc */
		if ( d1.type != D_NUM || d2.type != D_CODEP || d3.type != D_CODEP )
			execerror("nested task didn't get expected stack, Task=%ld!",T->tid);
		T->rminstruct = (int)d1.u.val;
		T->first = d2.u.codep;
		T->pc = (Unchar*)(d3.u.codep);
		T->nested--;
		return;
	}
		
	/* Remove task */
	taskkill(T,0);

	T = NULL;
}

void
i_select1(void)
{
	Datum d;

	/* Top of stack is the original phrase. */
	d = *(Stackp-1);
	if ( d.type != D_PHR )
		execerror("select operation only works on phrases!");

	pushexp(phrdatum(newph(0)));	/* to be constructed */
	pushexp(notedatum(firstnote(d.u.phr)));	/* walking note */

	pushexp(numdatum(T->qmarknum));
	pushexp(phrdatum(newph(0)));	/* qmark phrase */
	pushexp(framedatum(T->qmarkframe));
	T->qmarkframe = Stackp-1;
	T->qmarknum = 0;
}

void
i_select2(void)
{
	Noteptr wnt;
	Phrasep qph;
	Datum d, d2;
	Codep i1;

	i1 = use_ipcode();
	/* stack == qmark sym, qmark frame, walking note ptr, */
	/*          new phrase and orig phrase */
	if ( (Stackp-1)->type != D_FRM )
		execerror("Bad stack (0) in ISELECT2!");
	if ( (Stackp-2)->type != D_PHR )
		execerror("Bad stack (1) in ISELECT2!");
	if ( (Stackp-3)->type != D_NUM )
		execerror("Bad stack (2) in ISELECT2!");
	if ( (Stackp-4)->type != D_NOTE )
		execerror("Bad stack (3) in ISELECT2!");
	if ( (Stackp-5)->type != D_PHR )
		execerror("Bad stack (4) in ISELECT2!");
	wnt = (Stackp-4)->u.note;
	if ( wnt == NULL ) {
		/* Done walking through orig phrase, get out. */
		popinto(d);	/* qmark frame */
		T->qmarkframe = d.u.frm;
		popinto(d);	/* qmark phrase */
		popinto(d);	/* qmark num */
		T->qmarknum = (int)(d.u.val);
		popinto(d);	/* walking nt */
		popinto(d2);	/* new phrase */
		popinto(d);	/* orig phrase */
		d2.u.phr->p_leng = d.u.phr->p_leng;
		pushm(d2);	/* leave new phrase on stack */
		setpc(i1);
		return;
	}
	qph = (Stackp-2)->u.phr;
	if ( firstnote(qph) )
		ntfree(firstnote(qph));
	setfirstnote(qph) = ntcopy(wnt);
	(Stackp-4)->u.note = nextnote(wnt);
	T->qmarknum++;
}

void
i_select3(void)
{
	Codep i1;
	Datum d;

	i1 = use_ipcode();
	popinto(d);	/* condition value */
	if ( numval(d) ) {
		/* true - include current note in result */
		Phrasep qph = (Stackp-2)->u.phr;
		Phrasep ph = (Stackp-5)->u.phr;
		ntinsert(ntcopy(firstnote(qph)),ph);
	}
	setpc(i1);
}

void
i_print(void)
{
	long nargs;
	int n;
	Datum d;

	nargs = use_numcode();
	for ( n=(int)nargs; n>0; ) {
		Datum d2;
		d2 = *(Stackp-n);
		prdatum(d2,(STRFUNC)tprint,0);
		if ( --n > 0 )
			tprint(*Printsep);
		else
			tprint(*Printend);
	}
	for ( n=(int)nargs; n>0; n-- )
		popinto(d);
	tsync();
}

void
keyprintf(char *fmt,int arg0,int nargs, STRFUNC outfunc)
{
	int i = 0;
	char s[2];
	char *p = fmt;
	int c;
	Datum d;
	char *w, word[256];
	long id;

	s[1] = '\0';

	while ( (c=(*p++)) != '\0' ) {
	    switch (c) {
	    case '%':
		if ( i >= nargs )
			execerror("Too few args for print format!");
		w = word;
		*w++ = '%';
		while ( (c=(*p++)) != '\0' ) {
			*w++ = c;
			if ( strchr("dfpsx$",c) != NULL )
				break;
		}
		*w++ = '\0';
		d = ARG(arg0+i);
		switch (c) {
		case '$':
			if (d.type != D_OBJ)
				execerror("%%$ format expects and D_OBJ!");
			id = (d.u.obj?d.u.obj->id:-1) + *Kobjectoffset;
			sprintf(Msg1, "$%ld", id);
			(*outfunc)(Msg1);
			break;
		case 'd':
		case 'x':
		case 'o':
			sprintf(Msg1,word,numval(d));
			(*outfunc)(Msg1);
			break;
		case 'f':
			sprintf(Msg1,word,dblval(d));
			(*outfunc)(Msg1);
			break;
		case 's':
			if ( d.type != D_STR )
				execerror("printf() %%s format expects a string, but got %s!\n",atypestr(d.type));
			makeroom((long)(strlen(d.u.str)+32),
				&Msg1,&Msg1size);
			sprintf(Msg1,word,d.u.str);
			(*outfunc)(Msg1);
			break;
		case 'p':
			if ( d.type != D_PHR )
				execerror("printf() %%p format expects a phrase, but got %s!\n",atypestr(d.type));
			(*outfunc)(phrstr(d.u.phr,(*Printsplit)!=0));
			break;
		}
		i++;
		break;
	    default:
		s[0] = c;
		(*outfunc)(s);
		break;
	    }
	}
}

void
checkmouse(void)
{
	static int oldx = -1;
	static int oldy = -1;
	static int oldm = -1;
	int m, x, y, mod, b;
	int moved;
	int pressed = 0;

	if ( *Mousedisable )
		return;

	b = mdep_mouse(&x,&y,&mod);
	m = b & 3;	/* We only want to acknowledge button 1&2 */

	moved = (x!=oldx || y!=oldy);

	/* Avoid multiple mouse events when the mouse hasn't moved */
	if ( m==oldm && !moved )
		return;

#ifdef NO_MOUSE_UP_DRAG_EVENTS
	/* This eliminates mouse drag events when the button is up. */
	if ( m==oldm && m==0 ) )
		return;
#endif
	if ( oldm == 0 && m != 0 )
		pressed = 1;
	else if ( oldm > 0 && m == 0 )
		pressed = -1;

	oldm = m;
	if ( moved ) {
		oldx = x;
		oldy = y;
	}
	putonmousefifo(m,x,y,pressed,mod);
}

int
handleconsole(void)
{
	if ( Consolefd < 0 ) {
		if ( ConsoleEOF ) {
			/* We've already put Eofchar on console fifo */
			/* WAS: putonconsinfifo(Eofchar); */
			return 0;
		}
		return -2;
	}

	if ( *Inputistty==0 || mdep_statconsole() ) {
		int c;
		c = mdep_getconsole();
		if ( c == '\033' && mdep_statconsole() ) {
			c = mdep_getconsole();
			if ( c >= FKEY1 && c <= (FKEY1+11) )
				c = FKEYBIT | (c - FKEY1);
			else if ( c >= FKEY13 && c <= (FKEY13+11) )
				c = FKEYBIT | (c - FKEY13);
			else
				c = FKEYBIT | 24;
		}
		/* We disallow EOF on the console when in graphics, */
		/* so an inadvertant control-d doesn't clobber everything. */
		if ( (c < 0 || c == Eofchar) && *Graphics==0 ) {
			Consolefd = -1;
			ConsoleEOF = 1;
			putonconsinfifo(Eofchar);
			return 0;
		}
		if ( checkfunckey(c) )
			return 0;
		if ( c == Intrchar ) {
			doanint();
			return -4;
		}
		if ( *Consecho && c > 0 ) {
			char s[2];
			s[0] = (c=='\r' ? '\n' : c);
			s[1] = '\0';
			putonconsechofifo(uniqstr(s));
		}
		putonconsinfifo( c);
		return 0;
	}
	return 0;
}

void
doanint(void)
{
	Gotanint = 0;
	if ( Intrfuncd->type == D_CODEP )
		taskfunc0(Intrfuncd->u.codep);
	else
		eprint("Warning, Intrfunc has a non-function value!?");
}

void
i_goto(void)
{
	Pc = use_ipcode();
}

void
i_fcondeval(void)
{
	Codep i1;
	Datum d;

	i1 = use_ipcode();

	popinto(d);
	if ( numval(d) )
		setpc(i1);
}

void
i_tcondeval(void)
{
	Codep i1;
	Datum d;

	i1 = use_ipcode();
	popinto(d);
	if ( ! numval(d) )
		setpc(i1);
}

void
i_constant(void)
{
	Datum d;

	d.u.val = use_numcode();
	d.type = D_NUM;
	pushm_notph(d);
}

void
i_dotdotarg(void)
{
	long nargs;
	int n, up_npassed, up_nparams;
	Datum d, dnpassed, dfunc, *dp;

	nargs = use_numcode();
	dp = T->stackframe;
	if ( dp == NULL )
		execerror("Unexpected dp==NULL in i_dotdotarg!?");
	dnpassed = *npassed_of_frame(dp);
	up_npassed = numval(dnpassed);

	dfunc = *func_of_frame(dp);
	if ( dfunc.type != D_CODEP )
		execerror("Unexpected dfunc!=D_CODEP in i_dotdotarg!?");
	up_nparams = nparamsof(dfunc.u.codep);

	for ( n=up_nparams; n<up_npassed; n++ ) {
		d = ARG(n);
		pushm(d);
		nargs++;
	}
	pushexp(numdatum(nargs));
}

void
i_varg(void)
{
	long nargs;
	int n, nv;
	Htablep arr;
	Datum d, *dp;

	nargs = use_numcode();
	popinto(d);
	if ( d.type != D_ARR ) {
		execerror("varg() expects an array value, but got %s",
			atypestr(d.type));
	}
	arr = d.u.arr;
	/* alist = arrlist(arr,&nv,1); */
	nv = arrsize(arr);
	for ( n=0; n<nv; n++ ) {
		Symbol *as;
		as = arraysym(arr,numdatum(n),H_LOOK);
		if ( as == NULL )
			execerror("varg() can't find item %d in array$?",n);
		dp = symdataptr(as);
		if ( dp == NULL )
			execerror("varg() something wrong with item %d in array$?",n);
		d = *dp;
		pushm(d);
		nargs++;
	}
	pushexp(numdatum(nargs));
}

void
i_currobjeval(void)
{
	Datum d;

	d.u.obj = T->realobj;
	d.type = D_OBJ;
	pushm_notph(d);

	d.u.obj = T->obj;
	d.type = D_OBJ;
	pushm_notph(d);

	d.type = D_STR;
	d.u.str = T->method;
	pushm_notph(d);
}

void
i_constobjeval(void)
{
	long id;
	Datum d;
	Kobjectp o;

	id = use_numcode();

	o = findobjnum(id);
	/* If it doesn't already exist, we create it. */
	if ( o == NULL )
		o = defaultobject(id,NOCOMPLAIN);
	d = objdatum(o);
	pushm_notph(d);
}

void
i_ecurrobjeval(void)
{
	Datum d;

	d.u.obj = T->obj;
	d.type = D_OBJ;
	if ( d.u.obj == NULL )
		execerror("No current object, $ can't be evaluated!");
	if ( d.u.obj->id < 0 )
		execerror("Current object has been deleted!?");
	pushm_notph(d);
}

void
i_erealobjeval(void)
{
	Datum d;

	d.u.obj = T->realobj;
	d.type = D_OBJ;
	if ( d.u.obj == NULL )
		execerror("No real object, $$ can't be evaluated!");
	if ( d.u.obj->id < 0 )
		execerror("Real object has been deleted!?");
	pushm_notph(d);
}

void
i_returnv(void)
{
	Datum d;

	popinto(d);
	ret(d);
}

void
i_return(void)
{
	ret(Nullval);
}

void
i_qmark(void)
{
	Phrasep p1 = (T->qmarkframe-1)->u.phr;
	pushexp(phrdatum(p1));
}

void
forinjumptoend(void)
{
	Datum d;

	d = *(Stackp-5);
	if ( d.type != D_CODEP )
		execerror("forinjumptoend() didn't get D_CODEP!\n");
	setpc(d.u.codep);
}

void
i_forinend(void)
{
	Datum d;
	int n;

	popinto(d);	/* should be FORINJUNK */
	popinto(d);	/* either a phrase or an array */
	if ( d.type == D_DATUM ) {
		if ( d.u.datum )
			kfree(d.u.datum); /* allocated by arrlist */
	}
	for ( n=0; n<3; n++ )
		popinto(d);
}

void
rmalltasksfifos(void)
{
	clearht(Tasktable);
	T = NULL;
	setrunning((Ktaskp)NULL);
	closeallfifos();
}

void
startreboot(void)
{
	rmalltasksfifos();
	rmalllocks();
	(void) newtask(Ireboot);

	Consinf = specialfifo();
	*Consinfnum = fifonum(Consinf);

	Consoutf = specialfifo();
	*Consoutfnum = fifonum(Consoutf);

	if ( Midiok ) {
		Midi_in_f = specialfifo();
		*Midi_in_fnum = fifonum(Midi_in_f);
	}
	else {
		Midi_in_f = NULL;
		*Midi_in_fnum = -1;
	}

	Mousef = specialfifo();
	*Mousefnum = fifonum(Mousef);
	reinitwinds();

	wredraw1(Wroot);
}

void
nestinstruct(Codep cp)
{
	pushexp(codepdatum(T->pc));
	pushexp(codepdatum(T->first));
	pushexp(numdatum(T->rminstruct));
	pushexp(codepdatum((Codep)NULL));

	T->nested++;
	T->rminstruct = 1;
	T->first = cp;
	T->pc = cp;
}

void
taskfunc0(Codep cp)
{
	Ktaskp t, saveT;

	/* start up a task to call it */
	t = newtask(Ipop);

	saveT = T;
	T = t;
	pushexp(codepdatum(cp));
	pushexp(objdatum(saveT?saveT->realobj:NULL));
	pushexp(objdatum(saveT?saveT->obj:NULL));
	pushexp(strdatum(saveT?saveT->method:Nullstr));
	pushexp(numdatum(0));
	callfuncd((Symbolp)NULL);
	T = saveT;
}

int
pushdnodes(Dnode *dn,int move)
{
	Dnode *dp;
	int nargs;

	for ( nargs=0,dp=dn; dp!=NULL; nargs++,dp=dp->next ) {
		if ( move ) {
			/* do not remove curly braces, pushm is bad */
			pushnoinc(dp->d);
		}
		else {
			/* do not remove curly braces, pushm is bad */
			pushm(dp->d);
		}
	}
	return nargs;
}

void
taskfuncn(Codep cp,Dnode *dn)
{
	Ktaskp t, saveT;
	int nargs;

	/* start up a task to call cp */
	t = newtask(Ipop);

	saveT = T;
	T = t;
	pushexp(codepdatum(cp));
	pushexp(objdatum(saveT?saveT->realobj:NULL));
	pushexp(objdatum(saveT?saveT->obj:NULL));
	pushexp(strdatum(saveT?saveT->method:Nullstr));
	nargs = pushdnodes(dn,0);
	pushexp(numdatum(nargs));
	callfuncd((Symbolp)NULL);
	T = saveT;
}

void
initstack(Ktaskp t)
{
	Datum d;
	t->stackframe = NULL;
	if ( t->stack ) {
		t->stackp = t->stack;
		/* The code below used to be one statement.  It was broken */
		/* apart due to a suspected compiler bug. */
		d = codepdatum((Codep)NULL);
		*(t->stackp) = d;
		t->stackp++;
	}
}

Ktaskp
newtask(Codep cp)
{
	unsigned int stksize = INITSTACKSIZE;
	Ktaskp t = newtp(T_RUNNING);

	t->stack = alloctaskstack(&stksize);
	t->stacksize = stksize;
	t->stackend = t->stack + stksize;

	initstack(t);

	t->rminstruct = 0;
	t->cnt = 0L;
	t->nested = 0;
	t->anychild = 0;
	t->nextrun = NULL;
	t->obj = NULL;
	t->realobj = NULL;
	t->method = NULL;
	t->linenum = -1;
	t->filename = NULL;
	t->parent = T;	/* slightly dangerous - calling routines should */
			/* be careful that T is indeed the desired parent. */

	if ( t->parent == t )
		execerror("t->parent==t in newtask!!!");

	if ( T ) {
		T->anychild = 1;
		t->priority = T->priority;
	}
	else {
		t->priority = (int)*Defpriority;
	}

	t->pc = cp;
	t->first = cp;
	linktask(t);

	return t;
}

void
setrunning(Ktaskp t)
{
	Running = t;
}

void
restarttask(Ktaskp t)
{
	t->state = T_RUNNING;
	linktask(t);
}

void
taskunrun(Ktaskp t,int nstate)
{
	unlinktask(t);
	t->state = nstate;
}

Ktaskp Tasklist;

int
taskcollectchildren(Hnodep h)
{
	Ktaskp t = h->val.u.task;
	int addit = 0;
	Ktaskp t2;

	/* If this task's parent is in the list, it's a child, so add it. */
	for ( t2=Tasklist; t2!=NULL; t2=t2->tmplist) {
		if ( t->parent == t2 ) {
			addit++;
			break;
		}
	}
	if ( addit ) {
		/*
		 * If it's already in the list, don't add it again!
		 */
		for ( t2=Tasklist; t2!=NULL; t2=t2->tmplist) {
			if ( t2 == t ) {
				addit = 0;
				break;
			}
		}
		if ( addit ) {
			t->tmplist = Tasklist;
			Tasklist = t;
		}
	}
	return 0;
}

void
taskkill(Ktaskp t,int killchildren)
{
	Ktaskp tp;
	int prio = T->priority;	   /* of task who's doing the killing */

	if ( t->state == T_FREE ) {
		return;			/* be lenient */
	}

	if ( t->anychild == 0 ) {
		if ( t->priority <= prio ) {
			taskbury(t);
		}
	}
	else {
		/* Create a list of all children */
		t->tmplist = NULL;
		Tasklist = t;

		/* The list is created in reverse order (children at the */
		/* top of the list).  This is very important, because that's */
		/* the order we want to kill them in. */
		hashvisit(Tasktable,taskcollectchildren);

#ifdef DEBUGSTUFF
tprint("taskkill(t=%ld killchildren=%d), children=",t->tid,killchildren);
for ( tp=Tasklist; tp!=NULL; tp=tp->tmplist ) {
tprint(",(%ld,%d)",tp->tid,tp->priority);
}
tprint("\n");
#endif
		if ( killchildren ) {
			/* Note, this kills children *and* t */
			for ( tp=Tasklist; tp!=NULL; tp=tp->tmplist ) {
				if ( tp->priority <= prio ) {
					taskbury(tp);
				}
			}
		}
		else {
			if ( t->priority <= prio ) {
				/* If only t gets killed, the children directly */
				/* under it get re-parented. */
				for ( tp=Tasklist; tp!=NULL; tp=tp->tmplist ) {
					if ( tp->parent == t )
						tp->parent = t->parent;
				}
				taskbury(t);
			}
		}
	}
}

static Ktaskp Taskbeingkilled;

int
taskunwait(Hnodep h)
{
	Ktaskp t = h->val.u.task;
	if ( t->state == T_WAITING && t->twait == Taskbeingkilled){
		Nwaiting--;
		restarttask(t);
	}
	return 0;
}

void
wakewaiters(Ktaskp t)
{
	if ( t->anywait ) {
		Taskbeingkilled = t;
		hashvisit(Tasktable,taskunwait);
	}
}

void
taskbury(Ktaskp t)
{
	/* Restart any tasks that were waiting on this one. */
	wakewaiters(t);

	switch (t->state) {
	case T_BLOCKED:
		if ( t->fifo ) {
			t->fifo->t = NULL;
			t->fifo = NULL;
		}
		else
			eprint("Hey, t->fifo==NULL for T_BLOCKED task!?\n");
		break;
	case T_WAITING:
		break;
	case T_SLEEPTILL:
	case T_SCHED:
		unsched(t);
		break;
	case T_STOPPED:
		execerror("kill: stopped task id!?\n");
		break;
	}

	/* If there's an onerror function defined for this task, use it. */
	if ( t->ontaskerror ) {
		int nargs; 
		Ktaskp saveT = T;

		T = t;
		initstack(t);
		t->pc = (Unchar*)Ipop;
		t->first = Ipop;
		t->nested = 0;
		t->rminstruct = 0;
		pushexp(codepdatum(t->ontaskerror));
		pushexp(objdatum(saveT?saveT->realobj:NULL));
		pushexp(objdatum(saveT?saveT->obj:NULL));
		pushexp(strdatum(saveT?saveT->method:Nullstr));

		/* Push the error string on as the first argument, then */
		/* the rest of the args given to onerror(). */
		nargs = 0;
		if ( t->ontaskerrormsg != NULL ) {
			pushnoinc(strdatum(t->ontaskerrormsg));
			nargs++;
		}
		nargs += pushdnodes(t->ontaskerrorargs,1);
		pushexp(numdatum(nargs));

		callfuncd((Symbolp)NULL);

		freednodes(t->ontaskerrorargs);

		t->ontaskerror = NULL;
		t->ontaskerrorargs = NULL;
		t->ontaskerrormsg = NULL;

		if ( t->state != T_RUNNING )
			restarttask(t);
		T = saveT;
	}
	else if ( t->onexit ) {
		int nargs; 
		Ktaskp saveT = T;

		T = t;
		initstack(t);
		t->pc = (Unchar*)Ipop;
		t->first = Ipop;
		t->nested = 0;
		t->rminstruct = 0;
		pushexp(codepdatum(t->onexit));
		pushexp(objdatum(saveT?saveT->realobj:NULL));
		pushexp(objdatum(saveT?saveT->obj:NULL));
		pushexp(strdatum(saveT?saveT->method:Nullstr));
		nargs = pushdnodes(t->onexitargs,1);
		pushexp(numdatum(nargs));
		callfuncd((Symbolp)NULL);
		freednodes(t->onexitargs);
		t->onexitargs = NULL;
		t->onexit = NULL;
		if ( t->state != T_RUNNING )
			restarttask(t);
		T = saveT;
	}
	else {
		unlocktid(t);
		unlinktask(t);
		deletetask(t);
	}
}

void
printrunning(char *s)
{
	char *sep = "";
	Ktaskp t;

	eprint("RUNNING Tasks (%s) = ",s);
	for ( t=Running; t!=NULL; t=t->nextrun ) {
		eprint("%s%ld",sep,t->tid);
		sep = ",";
	}
	eprint("\n");
}

#ifdef TRYWITHOUT
void
taskclear(Ktaskp t)
{
	t->pc = 0;
	t->nextrun = 0;
	t->stack = 0;
	t->stacksize = 0;
	t->stackp = 0;
	t->stackend = 0;
	t->stackframe = 0;
	t->arg0 = 0;
	t->state = 0;
	t->nested = 0;
	t->tid = 0;
	t->priority = 0;
	t->first = 0;
	t->schedcnt = 0;
	t->cnt = 0;
	t->tmp = 0;
	t->twait = 0;
	t->qmarkframe = 0;
	t->qmarknum = 0;
	t->rminstruct = 0;
	t->parent = 0;
	t->anychild = 0;
	t->anywait = 0;
	t->pout = 0;
	t->fifo = 0;
	t->onexit = 0;
	t->onexitargs = 0;
	t->ontaskerror = 0;
	t->ontaskerrorargs = 0;
	t->ontaskerrormsg = 0;
	t->tmplist = 0;
	t->linenum = 0;
	t->filename = "";
}
#endif

Ktaskp
newtp(int state)
{
	Ktaskp t;
	Hnodep h;

	if ( Freetp != NULL ) {
		t = Freetp;
		Freetp = Freetp->nxt;
	}
	else {
		t = (Ktaskp) kmalloc(sizeof(Task),"newtp");
	}

	/* add it to list of non-free tasks */
	t->nxt = Toptp;
	Toptp = t;

	/* The initializations are carefully chosen to be exactly (hopefully) */
	/* the ones needed by all tasks, realtime or otherwise. */

	t->stack = NULL;
	t->state = state;
	t->anychild = 0;
	t->anywait = 0;
	t->priority = 0;
	t->onexit = NULL;
	t->onexitargs = NULL;
	t->ontaskerror = NULL;
	t->ontaskerrorargs = NULL;
	t->ontaskerrormsg = NULL;
	t->qmarkframe = NULL;
	t->linenum = 0;
	t->filename = "";
	t->tid = Tid++;
	/* Add it to Tasktable */
	h = hashtable(Tasktable,numdatum(t->tid),H_INSERT);
	if ( isnoval(h->val) )
		h->val = taskdatum(t);
	else
		eprint("Hmm, task=%ld was already in Tasktable!?\n",t->tid);
	return t;
}

void
linktask(Ktaskp p)
{
	p->nextrun = Running;
	setrunning(p);
}

void
freetp(Ktaskp t)
{
	/* T_SCHED tasks don't have any stack or instructions */
	if ( t->state != T_SCHED ) {
		if ( t->rminstruct ) {
			freecode(t->first);
			t->first = NULL;
		}
	}
	if ( t->stack ) {
		cachetaskstack(t->stack, t->stacksize);
		t->stack = NULL;
	}
	t->state = T_FREE;
	t->nxt = Freetp;
	Freetp = t;

}

void
deletetask(Ktaskp t)
{
	/* Remove it from the Tasktable (if this becomes expensive, we */
	/* might be able to delay it, and clean up T_FREE tasks from the */
	/* table in a delayed/lazy fashion. */
	(void) hashtable(Tasktable,numdatum(t->tid),H_DELETE);
}

void
unlinktask(Ktaskp p)
{
	Ktaskp q;
	Ktaskp r = NULL;

	if ( p == NULL )
		return;
/* eprint("UNLINKTASK, t=%ld tid=%ld\n",(long)p,p->tid); */
	for ( q=Running; q!=NULL && q!=p; r=q,q=q->nextrun )
		;
	if ( q == NULL )
		return;
	if ( r == NULL )
		setrunning(p->nextrun);
	else
		r->nextrun = p->nextrun;
}

void
expandstack(Ktaskp p)
{
	expandstackatleast(p,1);
}

void
expandstackatleast(Ktaskp p, int needed)
{
	Datum *olds = p->stack;
	Datum *olde = p->stackend;
	Datum *oldsp = p->stackp;
	Datum *oldsf = p->stackframe;
	Datum *oldqf = p->qmarkframe;
	Datum *s, *ns;


	/* We want to increase by at least 50% */
	if ( (p->stacksize)/2 > needed )
		needed = p->stacksize / 2;

	p->stacksize += needed;
	p->stack = (Datum*) kmalloc(p->stacksize*sizeof(Datum),"expandstack");
	p->stackp = p->stack + (oldsp - olds);
	p->qmarkframe = p->stack + (oldqf - olds);
	p->stackend = p->stack + p->stacksize;

	/* copy old stack to new one */
	if ( olds == NULL ) {
		mdep_popup("Internal error: olds == NULL in expandstack!?");
		return;
	}
	for ( ns=p->stack,s=olds; s<olde; ns++,s++ ) {
		/* adjust frame pointers, since they point within the stack */
		if ( s->type == D_FRM ) {
			ns->type = D_FRM;
			if ( s->u.frm )
				ns->u.frm = p->stack + (s->u.frm - olds);
			else
				ns->u.frm = NULL;
		}
		else
			*ns = *s;
	}

	if ( oldsf != NULL ) {
		p->stackframe = p->stack + (oldsf - olds);
		redoarg0(p);
	}
	kfree(olds);
}

/* This sets of the sequence of instructions that's used for dragging */
/* phrases, sweeping stuff, and doing the menus.  Basically just an */
/* infinite loop, followed by a return.  */

Codep
infiniteloop(BYTEFUNC f)
{
	Instnodep in;
	Codep cp;

	pushiseg();
	in = code(funcinst(f));
	(void)code(instnodeinst(in));	/* An infinite loop to previous code. */
	code(funcinst(I_POPNRETURN));
	code(funcinst(I_RETURNV));
	cp = popiseg();
	return cp;
}

void
inittasks(void)
{
	if ( Tasktable == NULL ) {
		char *p = getenv("TASKHASHSIZE");
		Tasktable = newht( p ? atoi(p) : 67 );
	}

	Ireboot = instructs("Rebootfunc();");

	pushiseg();
	code(funcinst(I_POPVAL));
	code(Stopcode);
	Ipop = popiseg();

	Idosweep = infiniteloop((BYTEFUNC)I_DOSWEEPCONT);
}

void
eprfunc(BYTEFUNC i)
{
	char *p;
	intptr_t ii;

	ii = (intptr_t)i;
	if ( ii>=0 && ii < (int)(sizeof(Bytenames)/sizeof(Bytenames[0])) ) {
		keyerrfile("%s",Bytenames[ii],ii);
	}
	else {
		p = funcnameof(i);
		if ( p )
			keyerrfile("%s",p);
		else
			keyerrfile("??? %ld",(intptr_t)i);
	}
}

/* Following is structures/functions to support caching the last
 * CSFREELIST_SIZE freed task stacks to save on re-allocating
 * when next task(w/stack) is created */
struct Cachestack {
	struct Cachestack *next;
	unsigned int size;
	/* &Cachestack.next is base of cached stack - Cachestack.size in size */
};
#define MAX_CACHED_STACKS  16
static struct Cachestack *cachedstacks = NULL;
static unsigned int numcachedstacks = 0;

/* Return a task stack of size stksize Datum structures */
void *
alloctaskstack(unsigned int *stksizep)
{
	void *stack;
	unsigned int stksize = *stksizep;
	unsigned int cachedsize;
	
	if (cachedstacks != NULL)
	{
		if ( cachedstacks->size == 0) {
			execerror("Huh? cache stack size is zero?!?\n");
		}

		/* Get stack base/size from cachedstacks */
		cachedsize = cachedstacks->size;
		stack = (void *)cachedstacks;
		/* Peel stack off cachedstacks queue */
		cachedstacks = cachedstacks->next;
		--numcachedstacks;

		/* If size of stack is too small resize the stack */
		if (cachedsize < stksize)
		{
			stack = krealloc(stack, stksize * sizeof(Datum), "alloctaskstack");
		}
		else {
			stksize = cachedsize;
		}
		*stksizep = stksize;
	}
	else {
		/* Don't have a cached stack... */
		stack = kmalloc(stksize * sizeof(Datum), "alloctaskstack");
	}
	return stack;
}

/* Cache a stack for reuse when next task (that requires a stack) is created */
void
cachetaskstack(void *stack, unsigned int stksize)
{
	struct Cachestack *ptr;
	if (numcachedstacks < MAX_CACHED_STACKS)
	{
		unsigned int CUTOFFSTACKSIZE = 3*INITSTACKSIZE;
		/* Limit cached stack to CUTOFFSTACKSIZE */
		if (stksize > CUTOFFSTACKSIZE)
		{
			stack = krealloc(stack,CUTOFFSTACKSIZE*sizeof(Datum),"alloctaskstack");
			stksize = CUTOFFSTACKSIZE;
		}			
		ptr = (struct Cachestack *)stack;
		ptr->size = stksize;
		ptr->next = cachedstacks;
		cachedstacks = ptr;
		numcachedstacks++;
	}
	else {
		/* Already have enough cached task stacks... */
		kfree(stack);
	}
}
