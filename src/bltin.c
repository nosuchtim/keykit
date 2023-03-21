/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#define OVERLAY2

#include <math.h>
#include "key.h"
#include "gram.h"

void
bi_debug(int argc)
{
#ifdef OLDSTUFF
	char *p;
	int n;

	if ( argc > 0 ) {
		sprintf(Msg1,"debug called with %d args: ",argc);
		tprint(Msg1);
		for ( n=0; n<argc; n++ ) {
			p = atypestr(ARG(n).type);
			sprintf(Msg1,"(%s)",p);
			tprint(Msg1);
		}
		tprint("\n");
	}
	else
		tprint("debug called with no arguments\n");
	ret(Nullval);
#endif

	char *t;
	if ( argc == 0 )
		t = "";
	else
		t = needstr("debug",ARG(0));

	if ( strcmp(t,"ht") == 0 ) {
		htlists();
	}
#ifdef MDEBUG
	else if ( strcmp(t,"mmreset") == 0 ) {
		mmreset();
	}
	else if ( strcmp(t,"mmdump") == 0 ) {
		mmdump();
	}
#endif
	else if ( strcmp(t,"htlistcheck") == 0 ) {
		htlists();
		htcheck();
		htlists();
	}
	else if ( strcmp(t,"purify") == 0 ) {
#ifdef OLDSTUFF
		purify_allallocated();
#endif
	}
	else {
		eprint("debug: unrecognized keyword (%s) !?\n",t);
	}
	ret(Nullval);
}

Datum
limitsarr(Phrasep ph)
{
	Datum da;
	Noteptr n;
	int maxpitch = -1;
	int minpitch = 128;
	long mintime = MAXCLICKS;
	long maxtime = -MAXCLICKS;
	long tm1, tm2;

	da = newarrdatum(0,5);

	n = firstnote(ph);
	if ( n == NULL )
		return da;

	for ( ; n!=NULL; n=nextnote(n) ) {
		if ( ntisnote(n) ) {
			if ( (int)pitchof(n) > maxpitch )
				maxpitch = pitchof(n);
			if ( (int)pitchof(n) < minpitch )
				minpitch = pitchof(n);
		}
		else {
			int y1, y2;
			nonnotesize(n,&y1,&y2);
			if ( y2 > maxpitch )
				maxpitch = y2;
			if ( y1 < minpitch )
				minpitch = y1;
		}
		tm1 = timeof(n);
		if ( tm1 < mintime )
			mintime = tm1;
		tm2 = endof(n);
		if ( tm2 > maxtime )
			maxtime = tm2;
	}
	setarraydata(da.u.arr,Str_earliest,numdatum(mintime));
	setarraydata(da.u.arr,Str_latest,numdatum(maxtime));
	setarraydata(da.u.arr,Str_lowest,numdatum(minpitch));
	setarraydata(da.u.arr,Str_highest,numdatum(maxpitch));
	return da;
}

void
bi_sizeof(int argc)
{
	Datum d;
	int v;

	if ( argc<1 )
		execerror("usage: sizeof(anything)");
	d = ARG(0);
	switch(d.type){
	case D_PHR: v = phsize(d.u.phr,0); break;
	case D_STR: v = (d.u.str==NULL) ? 0 : (long)strlen(d.u.str); break;
	case D_ARR: v = arrsize(d.u.arr); break;
	case D_NUM: v = sizeof(long); break;
	case D_DBL: v = sizeof(DBLTYPE); break;
	case D_SYM: execerror("sizeof() cannot be used on a symbol!"); break;
	case D_CODEP: execerror("sizeof() cannot be used on a function!"); break;
	case D_OBJ: execerror("sizeof() cannot be used on an object!"); break;
	default:  execerror("sizeof() cannot be used on unknown type?"); break;
	}
	ret(numdatum((long)v));
}

void
bi_limitsof(int argc)
{
	Datum d;
	Phrasep ph;

	if ( argc != 1 )
		execerror("usage: limitsof(phrase)");
	ph = needphr("limitsof",ARG(0));
	d = limitsarr(ph);
	ret(d);
}

void
bi_prstack(int argc)
{
	if ( argc != 0 )
		execerror("usage: prstack()");
	prstack(T->stackframe->u.frm);
	ret(Nullval);
}

void
bi_phdump(int argc)
{
	if ( argc != 0 )
		execerror("usage: phdump()");

	phdump();
	ret(Nullval);
}

static Datum Listarr;

int
tasklistcollect(Hnodep h)
{
	Ktaskp t = h->val.u.task;
	setarraydata(Listarr.u.arr,numdatum(t->tid),Zeroval);
	return 0;
}

void
bi_taskinfo(int argc)
{
	Datum retval;
	Datum *dp;
	Sched *sch;
	char *type;
	long tid;
	Ktaskp t;
	char *s = "taskinfo";
	static int first = 1;
	static Symstr s_id;
	static Symstr s_method;
	static Symstr s_list;
	static Symstr s_stopped;
	static Symstr s_blocked;
	static Symstr s_lowpriority;
	static Symstr s_running;
	static Symstr s_waiting;
	static Symstr s_lockwait;
	static Symstr s_sleeping;
	static Symstr s_scheduled;

	if ( first ) {
		first = 0;
		s_id = uniqstr("id");
		s_method = uniqstr("method");
		s_list = uniqstr("list");
		s_stopped = uniqstr("stopped");
		s_blocked = uniqstr("blocked");
		s_lowpriority = uniqstr("lowpriority");
		s_running = uniqstr("running");
		s_waiting = uniqstr("waiting");
		s_lockwait = uniqstr("lockwait");
		s_sleeping = uniqstr("sleeping");
		s_scheduled = uniqstr("scheduled");
	}

	if ( argc==1 ) {
		Datum d;
		d = ARG(0);
		if ( d.type != D_STR )
			goto usage;

		type = d.u.str;
		if ( type == s_id )
			retval = numdatum(T->tid);
		else if ( type == s_method )
			retval = strdatum(T->method?T->method:Nullstr);
		else if ( type == s_list ) {
			/* construct list of task ids */
			Listarr = newarrdatum(0,32);
			hashvisit(Tasktable,tasklistcollect);
			retval = Listarr;
		}
		else
			goto usage;
		ret(retval);
		return;
	}
	if ( argc != 2 ) {
	    usage:
		execerror("usage: taskinfo(\"list\"), taskinfo(\"id\"), or taskinfo(tid,type)");
	}

	tid = neednum(s,ARG(0));
	type = needstr(s,ARG(1));
	t = taskptr(tid);

	retval = Nullval;	/* default, if not set below */

	if ( t == NULL )
		retval = Nullval;
	else if ( strcmp(type,"status") == 0 ) {
		Symstr st = NULL;
		switch (t->state) {
		case T_STOPPED:
			st=s_stopped; break;
		case T_FREE:
			break;
		case T_BLOCKED:
			st=s_blocked; break;
		case T_RUNNING:
			if ( t->priority < Currpriority )
				st=s_lowpriority;
			else
				st=s_running;
			break;
		case T_SLEEPTILL:
			st=s_sleeping; break;
		case T_SCHED:
			st=s_scheduled; break;
		case T_WAITING:
			st=s_waiting; break;
		case T_LOCKWAIT:
			st=s_lockwait; break;
		default:
			execerror("unknown task type in taskinfo!?");
		}
		if ( st )
			retval = strdatum(st);
	}
	/* for all the other types, the task must be active */
	else if ( t->state == T_FREE )
		retval = Nullval;
	else if ( strcmp(type,"parent")==0 ) {
		if ( t->parent )
			retval = numdatum(t->parent->tid);
	}
	else if ( strcmp(type,"count")==0 )
		retval = numdatum(t->cnt);
	else if ( strcmp(type,"schedtime")==0 ) {
		if ( t->state == T_SLEEPTILL || t->state == T_SCHED ) {
			for ( sch=Topsched; sch!=NULL; sch=sch->next ) {
				if ( sch->task == t ) {
					retval = numdatum(sch->clicks);
					break;
				}
			}
		}
	}
	else if ( strcmp(type,"schedcount")==0 ) {
		if ( t->state == T_SLEEPTILL || t->state == T_SCHED ) {
			for ( sch=Topsched; sch!=NULL; sch=sch->next ) {
				if ( sch->task == t && t->schedcnt > 1 ) {
					retval = numdatum(t->schedcnt);
					break;
				}
			}
		}
	}
	else if ( strcmp(type,"wait")==0 ) {
		if ( t->state == T_WAITING )
			retval = numdatum(t->twait->tid);
	}
	else if ( strcmp(type,"object")==0 ) {
		if ( t->realobj )
			retval = objdatum(t->realobj);
		else
			retval = objdatum(NULL);
	}
	else if ( strcmp(type,"line")==0 ) {
		retval = numdatum(t->linenum);
	}
	else if ( strcmp(type,"file")==0 ) {
		retval = strdatum(t->filename);
	}
	else if ( strcmp(type,"blocked")==0 ) {
		if ( t->state == T_BLOCKED && t->fifo != NULL )
			retval = numdatum(fifonum(t->fifo));
	}
	else if ( strcmp(type,"fulltrace")==0 ) {
		dp = t->stackframe;
		if ( t->stack!=NULL && dp!=NULL ) {
			/* clumsy */
			if ( dp->u.frm != NULL )
				dp = dp->u.frm;
			retval = strdatum(uniqstr(stacktrace(dp,1,0,t)));
		}
	}
	else if ( strcmp(type,"trace")==0 ) {
		dp = t->stackframe;
		/* I think I had a compiler bug that hit when */
		/* combining the statements below, so be careful. */
		if ( t->stack!=NULL && dp!=NULL ) {
			/* clumsy */
			if ( dp->u.frm != NULL )
				dp = dp->u.frm;
			retval = strdatum(uniqstr(stacktrace(dp,0,0,t)));
		}
	}
	else if ( strcmp(type,"priority")==0 ) {
		retval = numdatum(t->priority);
	}
	else {
		execerror("taskinfo: Unrecognized argument (%s)",type);
	}

	ret(retval);
}

void
bi_oldtypeof(int argc)
{
	dummyusage(argc);
	execerror("bi_oldnargs is obsolete!\n");
#ifdef OLDSTUFF

	char *p;
	Datum d;
	if ( argc<1 )
		execerror("usage: typeof(anything)");
	d = ARG(0);
	if ( isnoval(d) )
		p = "<Uninitialized>";
	else
		p = atypestr(d.type);
	/* remove initial "a " or "an " */
	if ( *(p+1) == ' ' )
		p += 2;
	else if ( *(p+2) == ' ' )
		p += 3;
	ret(strdatum(uniqstr(p)));
#endif
}

void
bi_string(int argc)
{
	if ( argc<1 )
		execerror("usage: string(n)");
	ret(strdatum(datumstr(ARG(0))));
}

void
bi_integer(int argc)
{
	Datum d;
	if ( argc<1 )
		execerror("usage: integer(n)");
	d = ARG(0);
	if ( d.type != D_NUM ) {
		/* numval() doesn't work on objects (purposely, */
		/* for the moment), but we do want integer(object) */
		/* to give us the id value.  */
		if ( d.type == D_OBJ )
			d = numdatum(d.u.obj->id);
		else
			d = numdatum(numval(d));
	}
	ret(d);
}

void
bi_float(int argc)
{
	if ( argc<1 )
		execerror("usage: float(n)");
	ret(dbldatum(dblval(ARG(0))));
}

void
bi_phrase(int argc)
{
	Datum d;
	Phrasep ph;

	if ( argc<1 )
		execerror("usage: phrase(n)");
	d = ARG(0);
	switch (d.type) {
	case D_STR:
		ph = strtophr(d.u.str);
		break;
	case D_PHR:
		ph = d.u.phr;
		break;
	default:	/* D_NUM, etc. */
		ph = newph(0);
		break;
	}
	ret(phrdatum(ph));
}

void
bi_sin(int argc)
{
	if ( argc<1 )
		execerror("usage: sin(n)");
	ret(dbldatum(sin(dblval(ARG(0)))));
}

void
bi_cos(int argc)
{
	if ( argc<1 )
		execerror("usage: cos(n)");
	ret(dbldatum(cos(dblval(ARG(0)))));
}

void
bi_tan(int argc)
{
	if ( argc<1 )
		execerror("usage: tan(n)");
	ret(dbldatum(tan(dblval(ARG(0)))));
}

void
bi_asin(int argc)
{
	if ( argc<1 )
		execerror("usage: asin(n)");
	ret(dbldatum(asin(dblval(ARG(0)))));
}

void
bi_acos(int argc)
{
	if ( argc<1 )
		execerror("usage: acos(n)");
	ret(dbldatum(acos(dblval(ARG(0)))));
}

void
bi_atan(int argc)
{
	if ( argc<1 )
		execerror("usage: atan(n)");
	ret(dbldatum(atan(dblval(ARG(0)))));
}

void
bi_sqrt(int argc)
{
	if ( argc<1 )
		execerror("usage: sqrt(n)");
	ret(dbldatum(sqrt(dblval(ARG(0)))));
}

void
bi_exp(int argc)
{
	if ( argc<1 )
		execerror("usage: exp(n)");
	ret(dbldatum(exp(dblval(ARG(0)))));
}

void
bi_log(int argc)
{
	if ( argc<1 )
		execerror("usage: log(n)");
	ret(dbldatum(log(dblval(ARG(0)))));
}

void
bi_log10(int argc)
{
	if ( argc<1 )
		execerror("usage: log10(n)");
	ret(dbldatum(log10(dblval(ARG(0)))));
}

void
bi_pow(int argc)
{
	double x, y;
	if ( argc<2 )
		execerror("usage: pow(x,y)");
	x = dblval(ARG(0));
	y = dblval(ARG(1));
	ret(dbldatum(pow(x,y)));
}

void
bi_readphr(int argc)
{
	Phrasep ph;
	char *fname, *pf;
	FILE *f;

	if ( argc<1 )
		execerror("usage: readphr(fname)");
	fname = needstr("readphr",ARG(0));
	if ( (pf=mpathsearch(fname)) != NULL )
		fname = pf;
	if ( (f=fopen(fname,"r")) == NULL )
		ph = newph(0);
	else {
		ph = filetoph(f,fname);
		myfclose(f);
	}
	ret(phrdatum(ph));
}

void
bi_pathsearch(int argc)
{
	Datum d;
	char *fname;
	char *path, *s;
	static long pathsize = 0;
	static char **pathparts = NULL;
	static char *lastkeypath = NULL;
	static char *pathfname = NULL;

	if ( argc<1 )
		execerror("usage: pathsearch(file [,path])");
	fname = needstr("pathsearch",ARG(0));
	if ( argc > 1 )
		path = needstr("pathsearch",ARG(1));
	else
		path = *Keypath;
	s = pathsearch(fname,&pathsize,&pathparts,&lastkeypath,&pathfname,&path,(PATHFUNC)0);
	if ( s )
		d = strdatum(uniqstr(s));
	else
		d = Nullval;
	ret(d);
}

void
bi_ascii(int argc)
{
	Datum d;
	char str[2];

	if ( argc<1 )
		execerror("usage: ascii(integer-or-string)");
	d = ARG(0);
	switch (d.type) {
	case D_STR:
		d = numdatum((long)(d.u.str[0]));
		break;
	case D_NUM:
		str[0] = (int) numval(d);
		str[1] = '\0';
		d = strdatum(uniqstr(str));
		break;
	default:	/* D_PHR, etc. */
		execerror("usage: ascii(integer-or-string)");
		break;
	}
	ret(d);
}

void
bi_reboot(int argc)
{
	dummyusage(argc);
	forcereboot();
	/*NOTREACHED*/
}

int
funcundefine(Hnodep hn)
{
	Symbolp s;
	Datum d, *dp;
	Codep cp;
	char *nm;

	/* We want to undefine all user-defined functions, but */
	/* we DO NOT undefine ones whose names begin with upper-case letters.*/

	s = hn->val.u.sym;
	nm = symname(s);
	if ( *nm >= 'A' && *nm <= 'Z' )
		return 0;
	dp = symdataptr(s);
	if ( dp == NULL )
		return 0;
	d = *dp;
	if ( d.type != D_CODEP )
		return 0;
	cp = d.u.codep;
	if ( cp==NULL )
		return 0;
	if ( BLTINOF(cp) != 0 )
		return 0;
	undefsym(s);
	return 0;
}

void
bi_refunc(int argc)
{
	dummyusage(argc);
	hashvisit(Topct->symbols, funcundefine);
	ret(Nullval);
}

void
bi_rekeylib(int argc)
{
	dummyusage(argc);
	readkeylibs();
	ret(Nullval);
}

void
bi_midifile(int argc)
{
	Datum d;
	char *s, *pf;

	if ( argc == 1 ) {
		s = needstr("midifile",ARG(0));
		if ( (pf=mpathsearch(s)) != NULL )
			s = pf;
		d = newarrdatum(0,0);
		*Mfformat = mftoarr(s,d.u.arr);
	}
	else if ( argc == 2 ) {
		Htablep arr = needarr("midifile",ARG(0));
		s = needstr("midifile",ARG(1));
		if ( (pf=mpathsearch(s)) != NULL )
			s = pf;
		arrtomf(arr,s);
		d = Nullval;
	}
	else {
		execerror("usage: midifile(filename) or midifile(array,filename)");
	}

	ret(d);
}

void
bi_split(int argc)
{
	Datum d, da;

	if ( argc<1 || argc>2)
		execerror("usage: split(phrase-or-string)");
	d = ARG(0);

	if ( d.type == D_PHR )
		da = phrsplit(d.u.phr);
	else if ( d.type == D_STR ) {
		char *sep;
		if ( argc > 1 )
			sep = needstr("split",ARG(1));
		else
			sep = DEFSPLIT;
		da = strsplit(d.u.str, sep);
	}
	else
		execerror("split: expecting phrase or string");
	ret(da);
}

void
bi_cut(int argc)
{
	Phrasep ph;
	long tm1, tm2;
	int type, t, n;
	Datum d;
	long mask;
	int invert = 0;

	if ( argc < 2 )
		execerror("usage: cut(phrase,type, ... )");
	ph = needphr("cut",ARG(0));
	d = phrdatum(newph(1));
	t = neednum("cut",ARG(1));
	if ( t == CUT_NOTTYPE )
		invert = 1;
	switch ( t ) {
	case CUT_TIME:
		tm1 = neednum("cut",ARG(2));
		tm2 = neednum("cut",ARG(3));
		if ( tm1 > tm2 ) {
			long tt = tm1;
			tm1 = tm2;
			tm2 = tt;
		}
		if ( argc == 5 )
			type = neednum("cut",ARG(4));
		else
			type = CUT_NORMAL;
		switch ( type ) {
		case CUT_NORMAL:
			phcut(ph,d.u.phr,tm1,tm2,0,127);
			break;
		case CUT_TRUNCATE:
			phcuttrunc(ph,d.u.phr,tm1,tm2);
			break;
		case CUT_INCLUSIVE:
			phcutincl(ph,d.u.phr,tm1,tm2);
			break;
		}
		break;
	case CUT_FLAGS:
		mask = neednum("cut",ARG(2));
		phcutflags(ph,d.u.phr,mask);
		break;
	case CUT_CHANNEL:
		n = neednum("cut",ARG(2));
		phcutchannel(ph,d.u.phr,n);	/* n is 1-16 */
		break;
	case CUT_TYPE:
	case CUT_NOTTYPE:
		type = neednum("cut",ARG(2));
		if ( type == M_CONTROLLER && argc>3 ) {
			int cnum = neednum("cut",ARG(3));
			phcutcontroller(ph,d.u.phr,cnum,invert);
		}
		else
			phcutusertype(ph,d.u.phr,type,invert);
		break;
	default:
		execerror("Unknown 'cut' type!?");
	}
	d.u.phr->p_leng = ph->p_leng;
	phdecruse(d.u.phr);	/* to reverse initial (1) */
	ret(d);
}

void
bi_midibytes(int argc)
{
	Phrasep p;
	Noteptr n;
	int nbytes = 0;
#define SOMEBYTES 10
	Unchar sbytes[SOMEBYTES];
	Unchar *bytes;
	Datum d;
	int i, bi, bn;

	if ( argc<1 )
		execerror("usage: midibytes(byte1,byte2,byte3...)");

	/* count the number of bytes that will be in the final result */
	for ( i=0; i<argc; i++ ) {
		d = ARG(i);
		if ( d.type == D_PHR ) {
			for ( n=firstnote(d.u.phr); n!=NULL; n=nextnote(n) ) {
				if ( typeof(n) != NT_BYTES && typeof(n)!=NT_LE3BYTES )
					continue;
				nbytes += ntbytesleng(n);
			}
		}
		else
			nbytes++;
	}

	/* Use the sbytes array to avoid dynamic allocation if we can */
	if ( nbytes < SOMEBYTES )
		bytes = (Unchar*) sbytes;
	else
		bytes = (Unchar*) kmalloc((unsigned)nbytes*sizeof(char),"bi_midibytes");

	bi = 0;
	for ( i=0; i<argc; i++ ) {
		d = ARG(i);
		if ( d.type == D_PHR ) {
			for ( n=firstnote(d.u.phr); n!=NULL; n=nextnote(n) ) {
				int nbb;
				if ( typeof(n) != NT_BYTES && typeof(n)!=NT_LE3BYTES )
					continue;
				nbb = ntbytesleng(n);
				for ( bn=0; bn<nbb; bn++ )
					bytes[bi++] = *ptrtobyte(n,bn);
			}
		}
		else if ( d.type == D_NUM ) {
			int c = neednum ( "midibytes", ARG(i) );
			bytes[bi++] = c;
		}
		else if ( d.type == D_DBL ) {
			int c = numval(ARG(i));
			bytes[bi++] = c;
		}
		else {
			eprint("midibytes: unexpected argument type!\n");
		}
	}

	p = newph(0);
	if ( nbytes > 0 ) {
		n = newnt();
		timeof(n) = 0L;
		portof(n) = 0;
#ifdef NTATTRIB
		attribof(n) = Nullstr;
#endif
		if ( nbytes <= 3 ) {
			typeof(n) = NT_LE3BYTES;
			le3_nbytesof(n) = nbytes;
			for ( i=0; i<nbytes; i++ )
				*ptrtobyte(n,i) = bytes[i];
		}
		else {
			typeof(n) = NT_BYTES;
			messof(n) = savemess(bytes,nbytes);
		}
		nextnote(n) = NULL;
		setfirstnote(p) = n;
	}
	/* Return the single-message phrase */
	d = phrdatum(p);

	if ( bytes != (Unchar*)sbytes )
		kfree(bytes);

	ret(d);
}

void
bi_oldnargs(int argc)
{
	dummyusage(argc);
	execerror("bi_oldnargs is obsolete!\n");
#ifdef OLDSTUFF
	Datum d, *frm, *arg0;
	int npassed, n;

	if ( argc != 0 )
		execerror("usage: nargs()");
	/* We work in the stackframe of the function that called this one. */
	frm = T->stackframe->u.frm;
	npassed = numval(*npassed_of_frame(frm));
	arg0 = arg0_of_frame(frm);
	for ( n=0; n<npassed; n++ ) {
		d = *(arg0+n);
		if ( isnoval(d) )
			break;
	}
	ret(numdatum(n));
#endif
}

void
bi_error(int argc)
{
	execerror("Error: %s",(argc>0) ? needstr("error",ARG(0)) : "???");
}

void
bi_printf(int argc)
{
	char *fmt;
	Datum d;

	d = ARG(0);
	fmt = needstr("printf",d);

	reinitmsg3();
	keyprintf(fmt,1,argc-1,ptomsg3);
	mdep_popup(Msg3);
	ret(Nullval);
}

void
bi_argv(int argc)
{
	int n, npassed;
	struct Datum *arg0, *frm, d, retval;

	if ( argc < 1 )
		execerror("usage: argv( argnum [,argnum2] )");
	n = neednum("argv",ARG(0));
		
	/* Find stackframe in function that called this one, */
	/* and get pointer to arg0 in that frame. */
	if ( T->stackframe == NULL || T->stackframe->u.frm == NULL )
		execerror("argv() must be called from within a function!");
	frm = T->stackframe->u.frm;
	arg0 = arg0_of_frame(frm);
	d = *npassed_of_frame(frm);
	npassed = numval(d);

	/* Always return an array when there are 2 arguments */
	if ( argc > 1 ) {
		int i, n2;
		Datum da;

		n2 = neednum("argv",ARG(1));
		da = newarrdatum(0,2*(npassed-n)+1);
		for ( i=n; i<npassed && i<n2; i++ ) {
			d = *(arg0+i);
			incruse(d);
			setarraydata(da.u.arr,numdatum(i-n),d);
		}
		retval = da;
	}
	else if ( n<0 || n>=npassed ) /* Might want to complain when n<0 */
		retval = Nullval;
	else if ( argc == 1 )
		retval = *(arg0+n);
	ret(retval);
}

void
nomidi(char *s)
{
	execerror("Unable to execute %s, no MIDI support compiled in!",s);
}

void
nographics(char *s)
{
	execerror("Unable to execute %s, no GRAPHICS support compiled in!",s);
}

void
bi_realtime(int argc)
{
	Phrasep p;
	long tid;
	long tm = *Now;
	long rep = 0L;
	int monitor = 1;

	if ( argc < 1 || argc > 4 )
		execerror("usage: realtime( phrase [,time [,repeat [,monitor] ] ] )");

	p = needphr("realtime",ARG(0));
	if ( firstnote(p) == NULL )
		tid = -1;
	else {
		if ( argc > 1 )
			tm = neednum("realtime",ARG(1));
		if ( argc > 2 )
			rep = neednum("realtime",ARG(2));
		if ( argc > 3 )
			monitor = neednum("realtime",ARG(3));
		tid = taskphr(p,tm,rep,monitor);
	}

	ret(numdatum(tid));
}

void
bi_sleeptill(int argc)
{
	long till;

	if ( argc != 1 )
		execerror("usage: sleeptill( time )");

	till = neednum("sleeptill",ARG(0));
#ifdef OLDSTUFF
	if ( till < 0 )
		execerror("sleeptill: negative values aren't allowed");
#endif

	/* NOTE: Do the return first, cause it uses the current value of T, */
	/* which will likely be changed by schdwake(). */
	ret(Nullval);

	/* Don't even bother waiting if we've already gone past. */
	if ( till >  *Now )
		schdwake(till);
}

void
bi_wait(int argc)
{
	long tid;
	Ktaskp t;

	if ( argc != 1 )
		execerror("usage: wait( tid )");

	tid = neednum("wait",ARG(0));

	ret(Nullval);

	/* task doesn't exist, assume it's already done */
	if ( (t=taskptr(tid)) != NULL ) {
		T->twait = t;
		taskunrun(T,T_WAITING);
		Nwaiting++;
		t->anywait = 1;
	}
}

void
bi_lock(int argc)
{
	Symstr nm;
	Lknode *lkhead, *lk;
	Lknode *last = NULL;
	int rv = 0;
	int tstonly = 0;

	if ( argc < 1 || argc > 2 )
		execerror("usage: lock(name [,test] )");

	nm = datumstr(ARG(0));
	if ( argc > 1 )
		tstonly = neednum("lock",ARG(1));

	lkhead = findtoplk(nm);

	/* value (number of tasks that had it locked already) */
	/* is returned immediately, but the task may get 'unrun' below. */
	if ( lkhead->owner != NULL ) {
		rv++;
		for ( lk=lkhead->notify; lk!=NULL; last=lk,lk=lk->notify )
			rv++;
	}
	ret(numdatum(rv));

	if ( tstonly )
		return;

	if ( lkhead->owner == NULL ) {
		/* Lock isn't owned by anyone, so the task become owner */
		/* and continues normally. */
		lkhead->owner = T;
		lkhead->notify = NULL;
		T->lock = lkhead;
		if ( lkhead == lkhead->notify )
			execerror("Internal error: lkhead==lkhead->notify!?\n");
	}
	else {
		Lknode *nlk;
		nlk = newlk(nm);
		if ( nlk == lkhead )
			execerror("Internal error: newlk==lkhead!?\n");
		nlk->owner = T;
		/* lkhead->notify points to list of pending locks.  Note that */
		/* new locks are added to the end of this list. */
		if ( last == NULL )
			lkhead->notify = nlk;
		else
			last->notify = nlk;
		if ( lkhead == lkhead->notify )
			execerror("lkhead==lkhead->notify!????\n");
		T->lock = nlk;
		taskunrun(T,T_LOCKWAIT);
	}
}

void
bi_unlock(int argc)
{
	Ktaskp t, rt;
	Symstr nm;
	Lknode *lk;

	if ( argc != 1 )
		execerror("usage: unlock(name)");

	nm = datumstr(ARG(0));

	lk = findtoplk(nm);
	t = lk->owner;

	if ( t == NULL )
		execerror("unlock on nm=%s fails, no one owns it!?",nm);

	/* Note that this code will even unlock a lock that the current */
	/* task (T) doesn't own.  */

	t->lock = NULL;

	rt = unlocklk(lk);
	if ( rt == NULL )
		ret(numdatum(-1));
	else
		ret(numdatum(rt->tid));

}

void
bi_finishoff(int argc)
{
	if ( argc != 0 )
		execerror("usage: finishoff()");
	finishoff();
	ret(Nullval);
}

void
bi_kill(int argc)
{
	long tid;
	Ktaskp t;
	int killchildren = 1;  /* default */

	if ( argc < 1 )
		execerror("usage: kill(tid,killchildren)");
	tid = neednum("kill",ARG(0));
	t = taskptr(tid);

	if ( argc > 1 ) {
		killchildren = neednum("kill",ARG(1));
	}

	/* Do the ret() right away, because T may get changed */
	ret(numdatum(t==NULL?1L:0L));

	if ( t != NULL ) {
		if ( t->state == T_FREE )
			warning("kill: invalid (freed) task id!?");
		else {
			taskkill(t,1);
			T = NULL; /* Is this needed? */

			/*
			 * NOTE: there are cases when it appears as if
			 * tasks aren't being killed when you call kill().
			 * These are inevitably because the priority of
			 * the task you're trying to kill is higher than
			 * the priority of the task trying to do the killing.
			 */
#ifdef DEBUGSTUFF
{
/* debugging */
	t = taskptr(tid);
	if ( t != NULL ) {
		tprint("Hey, tid=%ld still running after kill?",tid);
		keyerrfile("Hey, tid=%ld still running after kill?",tid);
	}
}
#endif
		}
	}
}

int Anyrun;
int Cprio;

int
chkprio(Hnodep h)
{
	Ktaskp t = h->val.u.task;
	if ( t->priority >= Cprio ) {
		Anyrun++;
		return 1;	/* causes hashvisit to finish early */
	}
	return 0;
}

void
bi_priority(int argc)
{
	char *s = "priority";
	int retval, v;
	long tid;
	Ktaskp t;

	if ( argc < 1 || argc > 2 )
		execerror("usage: priority(task,priority)");
	tid = neednum(s,ARG(0));
	if ( argc > 1 ) {
		v = neednum(s,ARG(1));
		if ( v < 0 || v > MAXPRIORITY )
			execerror("priority: invalid priority value (%d)",v);
	}
	if ( tid < 0 ) {
		/* negative tid means we're dealing with the global Currpriority */
		retval = Currpriority;
		if ( argc == 2 ) {
			if ( v > Currpriority ) {
				/* check to make sure there's at least one */
				/* task at that priority, so we don't hang. */
				Cprio = v;
				Anyrun = 0;
				hashvisit(Tasktable,chkprio);
				if ( Anyrun == 0 )
					execerror("Unable to do priority(%d) - no tasks could run!?",v);
			}
			Currpriority = v;
		}
	}
	else {
		t = taskptr(tid);
		if ( t == NULL )
			execerror("bad task id (%ld) given to priority",tid);
		retval = t->priority;
		if ( argc == 2 )
			t->priority = v;
	}
	ret(numdatum(retval));
}

Dnode *
grabargs(int fromargn,int toargn)
{
	Dnode *dn=NULL, *lastdn, *retn;
	int n = fromargn;

	retn = NULL;
	for ( lastdn=NULL; n<toargn; lastdn=dn,n++ ) {
		dn = newdn();
		dn->d = ARG(n);
		incruse(dn->d);
		dn->next = NULL;
		if ( lastdn )
			lastdn->next = dn;
		else
			retn = dn;
	}
	return retn;
}

void
bi_onexit(int argc)
{
	if ( argc < 1 )
		execerror("usage: onexit(function)");
	T->onexit = needfunc("onexit",ARG(0));
	T->onexitargs = grabargs(1,argc);
	ret(Nullval);
}

void
bi_onerror(int argc)
{
	if ( argc < 1 )
		execerror("usage: onerror(function)");
	T->ontaskerror = needfunc("onerror",ARG(0));
	T->ontaskerrorargs = grabargs(1,argc);
	ret(Nullval);
}

void
bi_tempo(int argc)
{
	long oldtempo = Tempo;

	if ( argc >= 1 )  {
		Datum d;
		long v;

		d = ARG(0);
		v = roundval(d);
		if ( v < MINTEMPO )
			execerror("Value (%ld) given to tempo() is too low, it must be >= %d",v,MINTEMPO);
		newtempo(v);
	}
	ret(numdatum(oldtempo));
}

void
bi_substr(int argc)
{
	Datum d;
	int num, slen, len;
	char *str;
	char *free_this = NULL;
	char *s = "substr";

	if ( argc != 2 && argc != 3 )
		execerror("usage: substr(string,start,length)");

	(*SubstrCount)++;
	str = needstr(s,ARG(0));

	if ( *str == '\0' ) {
		ret(strdatum(Nullstr));
		return;
	}

	str = strsave(str);	/* we need to overwrite it */
	free_this = str;

	num = neednum(s,ARG(1));
	slen = (long)strlen(str);
	if ( num > slen ) {
		str = "";
		slen = 0;
	}
	else if ( num > 0 ) {
		num--;  /* string indexing starts at 1 */
		str += num;
		slen -= num;
	} else {
		free(free_this);
		execerror("Invalid start value (%d) given to substr()",num);
	}
	if ( argc == 3 ) {
		len = neednum(s,ARG(2));
		if ( len < slen && len >= 0 ) {
			str[len] = '\0';
		}
	}
	d = strdatum(uniqstr(str));	/* do not merge with return(d)! */
	free(free_this);
	ret(d);
}

void
bi_sbbyes(int argc)
{
	Datum d;
	int off;
	Phrasep p;
	Noteptr n;
	char *s = "subbytes";
	long origtime;
	Unchar* origbytes;
	int origleng, newleng;

	if ( argc != 2 && argc != 3 )
		execerror("usage: subbytes(MIDIBYTES-phrase,start,length)");

	p = needphr(s,ARG(0));
	off = neednum(s,ARG(1));

	if ( off < 1 )
		execerror("Invalid start value (%d) given to subbytes()",off);

	n = firstnote(p);
	if ( n!=NULL && ntisnote(n) )
		execerror("subbytes() expects a note of type MIDIBYTES!");

	d = phrdatum(newph(0));
	if ( n == NULL ) { /* empty input phrase */
		ret(d);
		return;
	}

	origtime = timeof(n);
	origbytes = ptrtobyte(n,0);
	origleng = ntbytesleng(n);

	if ( argc >= 3 )
		newleng = neednum(s,ARG(2));
	else
		newleng = origleng - off + 1;

	if ( newleng <= 0 || off > origleng ) {
		ret(d);	/* empty phrase */
		return;
	}

	if ( newleng + off > origleng )
		newleng = origleng - off + 1;

	n = newnt();
	timeof(n) = origtime;
	if ( newleng <= 3 ) {
		int i;
		typeof(n) = NT_LE3BYTES;
		le3_nbytesof(n) = (unsigned char)newleng;
		for ( i=0; i<newleng; i++ )
			*ptrtobyte(n,i) = origbytes[off-1+i];
	}
	else {
		typeof(n) = NT_BYTES;
		messof(n) = savemess(&(origbytes[off-1]),newleng);
	}

	setfirstnote(d.u.phr) = n;
	lastnote(d.u.phr) = n;
	ret(d);
}

void
bi_system(int argc)
{
	int n;
	char *str;

	if ( argc != 1 )
		execerror("usage: system(cmd)");
	str = needstr("system",ARG(0));
	n = mdep_shellexec(str);
	ret(numdatum((long)n));
}

void
bi_chdir(int argc)
{
	char *str, *p;

	if ( argc == 0 ) {
		/* return current directory */
		char buff[_MAX_PATH];
		if ( mdep_currentdir(buff,_MAX_PATH) == NULL )
			p = Nullstr;
		else
			p = uniqstr(buff);
	}
	else {
		str = needstr("chdir",ARG(0));
		if ( mdep_changedir(str) == 0 )
			p = str;	/* arguments are already uniqstr'ed */
		else
			p = Nullstr;
	}
	ret(strdatum(p));
}

static Datum lsdatum;
static char * lsdir;
static int lsdirleng;

void
lsdircallback(char *fname,int type)
{
	Symstr fn;
	/*
	 * If mdep_lsdir returns something that contains the
	 * original directory as a prefix, we remove it.
	 */
	if ( strncmp(fname,lsdir,lsdirleng) == 0 ) {
		fname += lsdirleng;
		/*
		 * Take off the directory separator, too.
		 */
		if ( strncmp(fname,*Dirseparator,strlen(*Dirseparator)) == 0 )
			fname += strlen(*Dirseparator);
	}
	fn = uniqstr(fname);
	setarraydata(lsdatum.u.arr,strdatum(fn),numdatum(type));
}

void
bi_lsdir(int argc)
{
	char *dir;
	char *exp;

	if ( argc < 1 )
		dir = uniqstr(".");
	else
		dir = needstr("lsdir",ARG(0));
	if ( argc < 2 )
		exp = uniqstr("*");
	else
		exp = needstr("lsdir",ARG(1));
	lsdatum = newarrdatum(0,7);
	lsdir = dir;
	lsdirleng = (long)strlen(dir);
	mdep_lsdir(dir,exp,lsdircallback);
	ret(lsdatum);
}

void
bi_filetime(int argc)
{
	if ( argc != 1 )
		execerror("usage: filetime(cmd)");
	ret(numdatum(mdep_filetime(needstr("filetime",ARG(0)))));
}

void
bi_coreleft(int argc)
{
	Datum d;

	dummyusage(argc);
#ifdef CORELEFT
	d = numdatum(CORELEFT);
#else
	d = numdatum(-1L);	/* -1, so it doesn't match Noval, argh... */
#endif
	ret(d);
}

void
bi_currtime(int argc)
{
	if ( argc != 0 )
		execerror("usage: currtime()");
	ret(numdatum(mdep_currtime()));
}

void
bi_milliclock(int argc)
{
	if ( argc != 0 )
		execerror("usage: milliclock()");
	ret(numdatum((long)(MILLICLOCK)));
}

void
bi_rand(int argc)
{
	long n1, n2;
	unsigned int r = 0;
	Datum d1, d2;

	if ( argc != 1 && argc != 2 )
		execerror("usage: rand(n1 [,n2])");

	d1 = ARG(0);
	n1 = numval(d1);

	/* If argument is negative, use it to initialize generator */
	if ( argc > 0 && n1 < 0 ) {
		long n2 = -n1;
		long n3 = -n1;
		n1 = -n1;
		if ( argc > 1 ) {
			d2 = ARG(1);
			n2 = -numval(d2);
		}
		if ( argc > 2 ) {
			Datum d3 = ARG(2);
			n3 = -numval(d3);
		}
		keysrand((unsigned)(n1),(unsigned)(n2),(unsigned)(n3));
		ret(Zeroval);
		return;
	}
	
	r = keyrand();
	if ( argc == 1 ) {
		/* 1 argument, generate a random number between 0 and n1-1 */
		if ( n1 < 1 )
			n1 = 1;
		r = r%n1 ;
	}
	else {
		/* 2 arguments, generate number between n1 and n2, inclusive */
		d2 = ARG(1);
		n2 = numval(d2);
		n2 = n2 - n1;
		if ( n2 < 0 )	/* to work if n2<n1 */
			n2 = -n2;
		r = r%(n2+1) + n1;
	}
	ret(numdatum(r));
}

void
bi_exit(int argc)
{
	int r = 0;
	if ( argc > 0 )
		r = neednum("exit",ARG(0));
	realexit(r);
	/*NOTREACHED*/
	ret(Nullval);
}

void
bi_garbcollect(int argc)
{
	if ( argc != 0 )
		execerror("usage: garbcollect()");
	phcheck();
	htcheck();
	ret(Nullval);
}

void
bi_funkey(int argc)
{
	char *s = "funkey";
	int n;

	if ( argc != 2 )
		execerror("usage: funkey(function-key-num,function-to-call)");
	n = neednum(s,ARG(0));
	if ( n < 1 || n > NFKEYS )
		eprint("funkey: number (%d) out of range!\n",n);
	else
		Fkeyfunc[n-1] = needfunc(s,ARG(1));
	ret(Nullval);
}

void
bi_symbolnamed(int argc)
{
	char *nm;
	Symbolp s;
	Datum d;
	Datum *sp;

	if ( argc != 1 )
		execerror("usage: symbolnamed(string)");
	nm = needstr("symbolnamed",ARG(0));
	s = findsym(nm,Topct->symbols);

	/* It's important to do the ret() now, because the loadsym */
	/* below will end up putting garbage on the stack. */
	ret(numdatum(88));

	/* We need to save the Stackp value here, so we can patch */
	/* it with the value that the symbol eventually gets after */
	/* loading the file that supposedly defines it. */
	sp = Stackp-1;

	if ( s == NULL || s->stype == UNDEF ) {
		s = globalinstall(nm,VAR);
		loadsym(s,0);
	}
	if ( s == NULL || s->stype == UNDEF )
		d = Nullval;
	else
		d = *symdataptr(s);
	*sp = d;
}

static int
d2oid(Datum d)
{
	long id;

	if ( d.type == D_NUM ) {
		id = d.u.val + *Kobjectoffset;
	}
	else if ( d.type == D_STR ) {
		char *s = d.u.str;
		if ( *s == '$' )
			s++;
		id = atol(s) + *Kobjectoffset;
	} else {
		id = 0;
	}
	if ( id >= Nextobjid )
		Nextobjid = id + 1;
	return id;
}

void
bi_windobject(int argc)
{
	Kobjectp obj;
	long id = 0;
	char *type = "generic";

	if ( argc < 0 || argc > 2 )
		execerror("usage: windobject(objectid,[type])");
	if (argc == 0 )
		id = newobjectid();
	else {
		id = d2oid(ARG(0));
		if ( id == 0 )
			id = newobjectid();
	}
	if ( argc > 1 )
		type = needstr("windobject",ARG(1));

	obj = windobject(id,1,type);
	ret(objdatum(obj));
}

void
bi_sync(int argc)
{
	if ( argc != 0 )
		execerror("usage: sync()");
	mdep_sync();
	ret(Nullval);
}

void
bi_browsefiles(int argc)
{
	char *s = "browsefiles";
	char *fn;
	Datum retval;

	if ( argc != 3 )
		fn = mdep_browse("Any File","*.*",1);
	else {
		char *desc = needstr(s,ARG(0));
		char *types = needstr(s,ARG(1));
		int mustexist = neednum(s,ARG(2));
		fn = mdep_browse(desc,types,mustexist);
	}
	if ( fn )
		retval = strdatum(uniqstr(fn));
	else
		retval = Nullval;
	ret(retval);
}

void
bi_setmouse(int argc)
{
	int t;
	char *s = "setmouse";

	if ( argc < 1 ) 
		execerror("usage: setmouse(type)");
	t = (int)neednum(s,ARG(0));
	mdep_setcursor(t);
	ret(Nullval);
}

void
bi_mousewarp(int argc)
{
	int x, y, r;
	char *s = "mousewarp";

	if ( argc < 2 ) 
		execerror("usage: mousewarp(x,y)");
	x = (int)neednum(s,ARG(0));
	y = (int)neednum(s,ARG(1));
	r = mdep_mousewarp(x,y);
	ret(numdatum(r));
}

long
arraynumval(Htablep arr,Datum arrindex,char *err)
{
	Symbolp s;
	Datum d;
	long v;

	s = arraysym(arr,arrindex,H_LOOK);
	if ( s == NULL )
		execerror(err);
	d = *symdataptr(s);
	v = roundval(d);
	return v;
}

int
getxy01(Htablep arr,long *ax0,long *ay0,long *ax1,long *ay1,int normalize,char *err)
{
	Symbolp s;

	s = arraysym(arr,Str_x,H_LOOK);
	if ( s ) {
		*ax0 = arraynumval(arr,Str_x,err);
		*ay0 = arraynumval(arr,Str_y,err);
		return 2;
	}
	else {
		*ax0 = arraynumval(arr,Str_x0,err);
		*ay0 = arraynumval(arr,Str_y0,err);
		*ax1 = arraynumval(arr,Str_x1,err);
		*ay1 = arraynumval(arr,Str_y1,err);
		if ( normalize ) {
			if ( *ax0 > *ax1 ) {
				long t = *ax0; *ax0 = *ax1; *ax1 = t;
			}
			if ( *ay0 > *ay1 ) {
				long t = *ay0; *ay0 = *ay1; *ay1 = t;
			}
		}
		return 4;
	}
}

Datum
xy01arr(long x0,long y0,long x1,long y1)
{
	Datum da;

	da = newarrdatum(0,5);
	setarraydata(da.u.arr,Str_x0,numdatum(x0));
	setarraydata(da.u.arr,Str_y0,numdatum(y0));
	setarraydata(da.u.arr,Str_x1,numdatum(x1));
	setarraydata(da.u.arr,Str_y1,numdatum(y1));
	return da;
}

Datum
xyarr(long x0,long y0)
{
	Datum da;

	da = newarrdatum(0,2);
	setarraydata(da.u.arr,Str_x,numdatum(x0));
	setarraydata(da.u.arr,Str_y,numdatum(y0));
	return da;
}

Htablep Newarr;

int
addifnew(Hnodep h)
{
	if ( arraysym(Newarr,h->key,H_LOOK) == NULL )
		setarraydata(Newarr,h->key, *symdataptr(h->val.u.sym) );
	return 0;
}

void
addnonxy(Htablep newarr,Htablep arr)
{
	Newarr = newarr;
	hashvisit(arr,addifnew);
}

void
bi_oldxy(int argc)
{
	dummyusage(argc);
	execerror("bi_oldxy is obsolete!\n");
#ifdef OLDSTUFF
	Datum r;
	long x0, y0, x1, y1;
	char *s = "xy";

	if ( argc == 2 ) {
		x0 = neednum(s,ARG(0));
		y0 = neednum(s,ARG(1));
		r = xyarr(x0,y0);
	}
	else if ( argc == 4 ) {
		x0 = neednum(s,ARG(0));
		y0 = neednum(s,ARG(1));
		x1 = neednum(s,ARG(2));
		y1 = neednum(s,ARG(3));
		r = xy01arr(x0,y0,x1,y1);
	}
	else
		execerror("usage: xy(x,y) or xy(x0,y0,x1,y1)");
	ret(r);
#endif
}

void
bi_attribarray(int argc)
{
	Datum r;
	char *v, *p, *q, *tp;
	char *s = "attribarray";
	int rmbracket = 0;

	if ( argc < 1 )
		execerror("usage: attribarray(s)");
	v = needstr(s,ARG(0));
	r = newarrdatum(0,3);
	/* If there are brackets surrounding it, remove them. */
	if ( *v == '[' ) {
		v++;
		rmbracket = 1;
	}
	strcpy(Buffer,v);
	if ( rmbracket!=0 && (p=strchr(Buffer,'\0')) != Buffer )
		*(p-1) = '\0';
	for ( p=strtok(Buffer,","); p!=NULL; p=strtok(NULL,",") ) {
		if ( (q=strchr(p,'=')) == NULL )
			continue;
		*q++ = '\0';
		/* remove quotes from both name and value */
		if ( *p == '"' ) {
			p++;
			if ( (tp=strchr(p,'\0')) != p )
				*(tp-1) = '\0';
		}
		if ( *q == '"' ) {
			q++;
			if ( (tp=strchr(q,'\0')) != q )
				*(tp-1) = '\0';
		}
		setarraydata(r.u.arr,strdatum(uniqstr(p)),strdatum(uniqstr(q)));
	}
	ret(r);
}

void
bi_screen(int argc)
{
	char *s = "window";
	char *v;
	char *bad = "Improper xy array given to screen()";
	long x0, y0, x1, y1;
	Datum retval;
	int n;

	retval = Nullval;
	v = needstr(s,ARG(0));
	if ( strcmp(v,"size") == 0 || strcmp(v,"resize") == 0 ) {
		if ( argc == 1 ) {
			int ix0, ix1, iy0, iy1;
			if ( mdep_screensize(&ix0,&iy0,&ix1,&iy1) == 0 )
				retval = xy01arr(ix0,iy0,ix1,iy1);
			else
				retval = strdatum(uniqstr("mdep_screensize fails!?"));
		}
		else {
			Htablep arr = needarr(s,ARG(1));
			n = getxy01(arr,&x0,&y0,&x1,&y1,1,bad);
			if ( mdep_screenresize(x0,y0,x1,y1) != 0 )
				retval = strdatum(uniqstr("mdep_screenresize fails!?"));
		}
	}
	else
		execerror("screen(): unrecognized first argument!");
	ret(retval);
}

void
wsettrack(Kwind *w,char *trk)
{
	Symbolp pe;
	Datum *dp;

	/* Make sure Track[trk] exists and is phrase (but don't clear */
	/* any existing value). */
	pe = arraysym(*Track,strdatum(trk),H_INSERT);
	dp = symdataptr(pe);
	if ( dp->type != D_PHR ) {
		clearsym(pe);
		*dp = phrdatum(newph(1));
	}
	w->trk = trk;
	w->pph = &(dp->u.phr);
}

void
bi_colorset(int argc)
{
	int n;
	if ( argc != 1 )
		execerror("usage: colorset(n)");
	n = (int) neednum("colorset",ARG(0));
	if ( n < 0 || n >= (*Colors) )
		execerror("colorset(): bad value (%d) - must be between 0 and %ld!",n,*Colors);
	Forecolor = n;
	mdep_color(Forecolor);
	ret(Nullval);
}

void
bi_colormix(int argc)
{
	int n, r, g, b;
	char *s = "colormix";

	if ( argc != 4 )
		execerror("usage: colormix(n,r,g,b)");
	n = (int) neednum(s,ARG(0));
	r = (int) neednum(s,ARG(1));
	g = (int) neednum(s,ARG(2));
	b = (int) neednum(s,ARG(3));
	mdep_colormix(n,r,g,b);
	ret(Nullval);
}

void
bi_get(int argc)
{
	Fifo *f;
	if ( argc < 1 )
		execerror("usage: get(fifo)");
	f = needfifo("get",ARG(0));
	if ( f == NULL )
		ret(numdatum(*Eofval));
	else {
		getfifo(f);
		/* Don't return a value, task blocks until read succeeds */
	}
}

void
bi_put(int argc)
{
	int v;
	Fifo *f;
	
	if ( argc < 2 )
		execerror("usage: put(fifo,data)");
	f = fifoptr(neednum("put",ARG(0)));
	if ( f == NULL )
		v = -1;
	else {
		if ( (f->flags & FIFO_READ) != 0 )
			execerror("Attempt to put() on a fifo (%ld) that is opened for reading!",fifonum(f));
		putfifo(f,ARG(1));
		v = fifosize(f);
	}
	ret(numdatum(v));
}

void
bi_flush(int argc)
{
	Fifo *f;
	
	if ( argc < 1 )
		execerror("usage: flush(fifo)");
	f = needvalidfifo("flush",ARG(0));
	flushfifo(f);
	ret(Nullval);
}

void
bi_fifoctl(int argc)
{
	Fifo *f;
	char *cmd;
	char *arg;
	Datum d;
	
	if ( argc < 1 )
		execerror("usage: fifoctl(fifo,cmd [,arg]) or fifoctl(\"default\",cmd,arg)");
	d = ARG(0);
	if ( d.type == D_STR && strcmp(d.u.str,"default")==0 )
		f = NULL;
	else
		f = needvalidfifo("fifoctl",ARG(0));
	cmd = needstr("fifoctl",ARG(1));
	if ( argc > 2 )
		arg = needstr("fifoctl",ARG(2));
	else
		arg = Nullstr;

	/* We pass ALL ctl's on PORTs to the mdep_ctlport function first, */
	/* even the ones we recognize internally.  If mdep_ctlport handles */
	/* it (i.e. returns 0, then we're done.  Otherwise we continue. */
	if ( f!=NULL && (f->flags & FIFO_ISPORT) != 0 ) {
		d = mdep_ctlport(f->port,cmd,arg);
		if ( ! isnoval(d) ) {
			ret(d);
			return;
		}
	}

	if ( strcmp(cmd,"type") == 0 ) {
		int nt = fifoctl2type(arg,FIFOTYPE_UNTYPED);
		if ( nt == FIFOTYPE_UNTYPED ) {
			execerror("Bad type argument given to fifoctl!?");
		}
		else {
			if ( f == NULL ) {
				Default_fifotype = nt;
			}
			else {
				f->fifoctl_type = nt;
			}
		}
	}
	else {
		execerror("Unrecognized cmd (%s) given to fifoctl()!?\n",cmd);
	}
	ret(Nullval);
}

void
bi_mdep(int argc)
{
	Datum d;

	d = mdep_mdep(argc);
	ret(d);
}

void
chkinputport(int portno)
{
	int p;
	/* portno is keykit-valued input port number */
	p = portno - MIDI_IN_PORT_OFFSET;
	if ( p < 1 || p > MIDI_IN_DEVICES || Midiinputs[p-1].name == NULL )
		execerror("midi: No input device # %d !?\n",portno);
}

void
chkoutputport(int portno)
{
	/* portno is keykit-valued input port number */
	if ( portno < 1 || portno >= MIDI_OUT_DEVICES || Midioutputs[portno-1].name == NULL )
		execerror("midi: No output device # %d !?\n",portno);
}

void
bi_midi(int argc)
{
#ifndef MDEP_MIDI_PROVIDED
	dummyusage(argc);
	execerror("midi: this port of keykit didn't provide mdep_midi()\n");
#else
	int r, portno;
	char *arg0 = NULL;
	char *arg1;
	int n;
	Datum d;
	char *nm;
	int p;

	d = Nullval;
	if ( argc > 0 )
		arg0 = needstr("mdep",ARG(0));

	/*
	 * recognized commands are:
	 *     input list
	 *     input open {n}
	 *     input close {n}
	 *     input isopen {n}
	 *     output list
	 *     output open {n}
	 *     output close {n}
	 *     output isopen {n}
	 *     output default {n}
	 *     output default {n} {channel}
	 */

	if ( strcmp(arg0,"input")==0 ) {
		arg1 = needstr("mdep",ARG(1));
		if ( strcmp(arg1,"list")==0 ) {
			d = newarrdatum(0,3);
			for ( n=0; n<MIDI_IN_DEVICES; n++ ) {
				nm = Midiinputs[n].name;
				if ( nm != NULL ) {
					int i = n+1+MIDI_IN_PORT_OFFSET;
					setarraydata(d.u.arr,numdatum(i),
						strdatum(uniqstr(nm)));
				}
			}
			/* d is an array of strings */
		}
		else if ( strcmp(arg1,"close")==0 ) {
			if ( argc > 2 )
				portno = neednum("midi",ARG(2));
			else
				execerror("usage: midi(input,close,#)\n");
			chkinputport(portno);
			/* Convert input portno to offset in Midiinputs */
			p = portno - MIDI_IN_PORT_OFFSET;
			if ( Midiinputs[p-1].opened == 0 )
				execerror("midi: input port %d is not open !?\n",portno);
			r = mdep_midi(MIDI_CLOSE_INPUT,&Midiinputs[p-1]);
			if ( r == 0 )
				Midiinputs[p-1].opened = 0;
			d = numdatum(r);
		}
		else if ( strcmp(arg1,"open")==0 ) {
			if ( argc > 2 )
				portno = neednum("midi",ARG(2));
			else
				execerror("usage: midi(input,open,#)\n");
			chkinputport(portno);
			/* Convert input portno to offset in Midiinputs */
			p = portno - MIDI_IN_PORT_OFFSET;
			if ( Midiinputs[p-1].opened == 1 )
				execerror("midi: input port %d is already open !?\n",portno);
			r = mdep_midi(MIDI_OPEN_INPUT,&Midiinputs[p-1]);
			if ( r == 0 )
				Midiinputs[p-1].opened = 1;
			d = numdatum(r);
		}
		else if ( strcmp(arg1,"isopen")==0 ) {
			if ( argc > 2 )
				portno = neednum("midi",ARG(2));
			else
				execerror("usage: midi(input,isopen,#)\n");
			chkinputport(portno);
			/* Convert input portno to offset in Midiinputs */
			p = portno - MIDI_IN_PORT_OFFSET;
			r = Midiinputs[p-1].opened;
			d = numdatum(r);
		} else {
			execerror("usage: midi(input,list/open/close/isopen,#)\n");
		}
	}
	else if ( strcmp(arg0,"output")==0 ) {
		arg1 = needstr("mdep",ARG(1));
		if ( strcmp(arg1,"list")==0 ) {
			d = newarrdatum(0,3);
			for ( n=0; n<MIDI_OUT_DEVICES; n++ ) {
				nm = Midioutputs[n].name;
				if ( nm != NULL ) {
					/*
					 * The index in the port array is
					 * the port number - 1.
					 */
					setarraydata(d.u.arr,numdatum(n+1),
						strdatum(uniqstr(nm)));
				}
			}
			/* d is an array of strings */
		}
		else if ( strcmp(arg1,"close")==0 ) {
			if ( argc > 2 )
				portno = neednum("midi",ARG(2));
			else
				execerror("usage: midi(output,close,#)\n");
			chkoutputport(portno);
			if ( Midioutputs[portno-1].opened == 0 )
				execerror("midi: output port %d is not open !?\n",portno);
			r = mdep_midi(MIDI_CLOSE_OUTPUT,&Midioutputs[portno-1]);
			if ( r == 0 )
				Midioutputs[portno-1].opened = 0;
			d = numdatum(r);
		}
		else if ( strcmp(arg1,"open")==0 ) {
			if ( argc > 2 )
				portno = neednum("midi",ARG(2));
			else
				execerror("usage: midi(output,open,#)\n");
			chkoutputport(portno);
			if ( Midioutputs[portno-1].opened == 1 )
				execerror("midi: output port %d is already open !?\n",portno);
			r = mdep_midi(MIDI_OPEN_OUTPUT,&Midioutputs[portno-1]);
			if ( r == 0 ) {
				Midioutputs[portno-1].opened = 1;
				/*
				 * The very first time an output is opened,
				 * set the default output port to that.
				 */
				if ( Portmap[DEFPORT][0] == 0 ) {
					int k;
					for (k=0; k<16; k++)
						Portmap[DEFPORT][k] = portno;
				}
			}
			d = numdatum(r);
		}
		else if ( strcmp(arg1,"isopen")==0 ) {
			if ( argc > 2 )
				portno = neednum("midi",ARG(2));
			else
				execerror("usage: midi(output,isopen,#)\n");
			chkoutputport(portno);
			r = Midioutputs[portno-1].opened;
			d = numdatum(r);
		} else {
			execerror("usage: midi(output,list/open/close/isopen,#)\n");
		}
	}
	else if ( strcmp(arg0,"portmap")==0 ) {
		if ( argc == 1 ) {
			int m;
			d = newarrdatum(0,3);
			/*
			 * NOTE: Portmap's first index is the *user* port
			 * number (1-based), and the 0 index is used
			 * for the "default" port map.
			 */
			for ( m=0; m < PORTMAP_SIZE; m++ ) {
				Datum d1, d2, ad;
				int um;
#ifdef BADIDEA
				/*
				 * Only include entries for midi input ports
				 * that are open.
				 */
				if ( m>0 && Midiinputs[m-1].opened == 0 )
					continue;
#endif
				ad = newarrdatum(1,3);	/* note: used is 1 */
				for ( n=0; n<16; n++ ) {
					d1 = numdatum(n+1);
					d2 = numdatum(Portmap[m][n]);
					setarraydata(ad.u.arr,d1,d2);
				}
				/* Convert m to user port #.  */
				if ( m > 0 )
					um = m + MIDI_IN_PORT_OFFSET;
				else
					um = 0;
				d1 = numdatum(um);
				setarraydata(d.u.arr,d1,ad);
			}
		} else {
			int ch, inportno, outportno;
			if ( argc < 3 )
				execerror("usage: midi(portmap,inport,chan,outport)\n");
			/*
			 * Usage is midi("portmap",inportnum,chan#,outportnum)
			 */
			inportno = neednum("midi",ARG(1));
			if ( inportno != 0 )
				chkinputport(inportno);

			/* Convert input portno to offset in Midiinputs */
			if ( inportno > 0 )
				p = inportno - MIDI_IN_PORT_OFFSET;
			else
				p = 0;

			ch = neednum("midi",ARG(2)) - 1;
			outportno = neednum("midi",ARG(3));
			if ( outportno != 0 )
				chkoutputport(outportno);
			Portmap[p][ch] = outportno;
		}
	}
	else {
		/* unrecognized command */
		execerror("midi: Unrecognized argument (%s).  Expecting \"input\" or \"output\".",arg0);
	}
	ret(d);
#endif
}

typedef struct bi_bitmap_t {
	int id;
	int xsize, ysize;
	Unchar *bits;
	struct bi_bitmap_t *next;
} bi_bitmap_t;

struct bi_bitmap_t *Bitmaplist = NULL;

static struct bi_bitmap_t *
bitmap_find(int bid)
{
	struct bi_bitmap_t *b;

	for ( b=Bitmaplist; b!=NULL; b=b->next ) {
		if ( b->id == bid )
			return b;
	}
	return NULL;
}

static struct bi_bitmap_t *
bitmap_new(int x, int y)
{
	int mx = -1;
	bi_bitmap_t *b;
	int nbytes;

	for ( b=Bitmaplist; b!=NULL; b=b->next ) {
		if ( b->id > mx )
			mx = b->id;
	}
	b = (bi_bitmap_t*) kmalloc(sizeof(bi_bitmap_t),"bi_bitmap");
	memset(b,0,sizeof(bi_bitmap_t));
	nbytes = x * y * 3;
	b->bits = kmalloc(nbytes,"bi_bitmap");
	memset(b->bits,0,nbytes);
	b->id = mx + 1;
	b->xsize = x;
	b->ysize = y;
	b->next = Bitmaplist;
	Bitmaplist = b;
	return b;
}

/*
 * usage:
 *
 *
 * i =  bitmap("read","filename");
 * sz = bitmap("size",i)
 * b =  bitmap("get",i,x,y,"r")
 *      bitmap("set",i,x,y,"r")
 *      bitmap("delete",i)
 */

void
bi_bitmap(int argc)
{
	char *keyword;
	Datum r;
	int bid;
	int x, y;
	int mx;
	int v;
	char buff[128];
	Unchar *bp;
	Unchar *ep;
	struct bi_bitmap_t *bi;
	char *fname;
	char *s = "bitmap";

	if ( argc < 1 )
		execerror("usage: bitmap(keyword,...)");
	keyword = needstr(s,ARG(0));

	/* For efficiency, the most common (get/set) are done special */
	if ( keyword == Str_get.u.str ) {
		bid = neednum(s,ARG(1));
		if ( (bi=bitmap_find(bid)) == NULL )
			execerror("bitmap index %d not found",bid);
		x = neednum(s,ARG(2));
		y = neednum(s,ARG(3));
		if ( x >= bi->xsize || y >= bi->ysize )
			execerror("bitmap(get) x,y values are too large");
		bp = bi->bits + 3 * (y * bi->xsize + x);
		v = ((*bp)<<16) + ((*(bp+1))<<8) + (*(bp+2));
		r = numdatum(v);
		
	} else if ( keyword == Str_set.u.str ) {
		bid = neednum(s,ARG(1));
		if ( (bi=bitmap_find(bid)) == NULL )
			execerror("bitmap index %d not found",bid);
		x = neednum(s,ARG(2));
		y = neednum(s,ARG(3));
		if ( x >= bi->xsize || y >= bi->ysize )
			execerror("bitmap(set) x,y values are too large");
		v = neednum(s,ARG(4));
		bp = bi->bits + 3 * (y * bi->xsize + x);
		*bp++ = (v&0xff0000)>>16;
		*bp++ = (v&0xff00)>>8;
		*bp++ = (v&0xff);
		r = numdatum(0);

	} else if ( strcmp(keyword,"size") == 0 ) {
		bid = neednum(s,ARG(1));
		if ( (bi=bitmap_find(bid)) == NULL )
			execerror("bitmap index %d not found",bid);
		r = newarrdatum(0,2);
		setarraydata(r.u.arr,Str_x,numdatum(bi->xsize));
		setarraydata(r.u.arr,Str_y,numdatum(bi->ysize));
	} else if ( strcmp(keyword,"read") == 0 ) {
		FILE *f;
		fname = needstr(s,ARG(1));
		if ( (f=fopen(fname,"r")) == NULL )
			execerror("bitmap(read) can't open: %s",fname);

		if ( myfgets(buff,sizeof(buff),f) == NULL )
			execerror("Unexpected EOF in bitmap file");
		if ( strncmp(buff,"P6",2) != 0 )
			execerror("bitmap can only handle P6 ppm files");

		if ( myfgets(buff,sizeof(buff),f) == NULL )
			execerror("Unexpected EOF in bitmap file");
		if ( sscanf(buff,"%d %d",&x,&y) != 2 )
			execerror("Improper header in bitmap file");

		if ( myfgets(buff,sizeof(buff),f) == NULL )
			execerror("Unexpected EOF in bitmap file");
		if ( sscanf(buff,"%d",&mx) != 1 )
			execerror("Improper header in bitmap file");

		bi = bitmap_new(x,y);
		bp = bi->bits;
		ep = bp + (3*x*y);
		while (1) {
			int rv, gv, bv;

			rv = getc(f);
			gv = getc(f);
			bv = getc(f);
			if ( rv<0 || gv<0 || bv<0 )
				break;
			*bp++ = rv;
			*bp++ = gv;
			*bp++ = bv;
			if ( bp >= ep )
				break;
		}
		fclose(f);
		r = numdatum(bi->id);
		
	} else if ( strcmp(keyword,"delete") == 0 ) {
		bid = neednum(s,ARG(1));
		if ( (bi=bitmap_find(bid)) == NULL )
			execerror("bitmap index %d not found",bid);
		execerror("bitmap delete not implemented yet");
	} else {
		execerror("Unrecognized keyword (%s) given to bitmap()",keyword);
	}
	ret(r);
}

void
bi_help(int argc)
{
	char *fname, *keyword;
	int r;

	if ( argc > 0 )
		keyword = needstr("help",ARG(0));
	else
		keyword = NULL;
	if ( argc > 1 )
		fname = needstr("help",ARG(1));
	else
		fname = "language";
	r = mdep_help(fname,keyword);
	ret(numdatum(r));
}

void
bi_fifosize(int argc)
{
	Fifo *f;
	int sz;

	if ( argc < 1 )
		execerror("usage: fifosize(fifo)");
	f = needfifo("fifosize",ARG(0));
	if ( f == NULL )
		sz = -1;
	else
		sz = fifosize(f);
	ret(numdatum(sz));
}

void
validpitch(int n,char *s)
{
	if ( n < 0 || n > 127 )
		execerror("Invalid pitch value (%d) found in %s!",n,s);
}

#define MAXARGS 32

void
bi_open(int argc)
{
	Fifo *f1, *f2;
	Datum d;
	char *fname;
	char *mode;
	char *porttype;
	int n;
	
	if ( argc == 0 ) {
		if (newfifo((char*)NULL,(char*)NULL,(char*)NULL,&f1,&f2) != 1)
			execerror("Internal error - newfifo fails!?");
		d = numdatum((long)fifonum(f1));
		ret(d);
		return;
	}

	fname = needstr("open",ARG(0));
	mode = argc>1 ? needstr("open",ARG(1)) : uniqstr("r");
	porttype = argc>2 ? needstr("open",ARG(2)) : uniqstr("file");

	n = newfifo(fname,mode,porttype,&f1,&f2);
	switch ( n ) {
	case 0:
	default:
		d = numdatum(-1);	/* 8/19/2001 - used to be Nullval */
		break;
	case 1:
		d = numdatum((long)fifonum(f1));
		break;
	case 2:
		d = numdatum((long)fifonum(f2));
		break;
	case 3:
		d = newarrdatum(0,3);
		setarraydata(d.u.arr,Str_r,numdatum(fifonum(f1)));
		setarraydata(d.u.arr,Str_w,numdatum(fifonum(f2)));
		break;
	}
	ret(d);
}

void
bi_close(int argc)
{
	Fifo *f;

	if ( argc < 1 )
		execerror("usage: close(fifo)");
	f = needvalidfifo("close",ARG(0));
	if ( isspecialfifo(f) )
		execerror("You can't close special fifos!");
	closefifo(f);
	deletefifo(f);
	ret(Nullval);
}

long
newobjectid(void)
{
	return Nextobjid++;
}

void
bi_object(int argc)
{
	long oid;
	Kobjectp o;
	Datum d;

	dummyusage(argc);
	/*
	 * Return an object value, given an object constant reference
	 * as a an integer or string (either 123 or "$123").
	 * Normally used to convert a string ("$123") back into
	 * an object reference.
	 */
	d = ARG(0);
	oid = d2oid(d);
	for ( o = Topobj; o!=NULL; o=o->onext ) {
		if ( o->id == oid )
			break;
	}
	if ( o == NULL ) {
		/* Create a new object with that id */
		o = defaultobject(oid,COMPLAIN);
	}
	d = objdatum(o);
	ret(d);
}

void
bi_objectlist(int argc)
{
	Datum d;
	Kobjectp o;

	if ( argc > 0 )
		execerror("usage: objectlist()");
	d = newarrdatum(0,32);
	for ( o = Topobj; o!=NULL; o=o->onext )
		setarraydata(d.u.arr,objdatum(o),numdatum(o->id));
	ret(d);
}

static int
add_stuff_tolist(Hnodep hn, int type)
{
	Symbolp s;

	s = hn->val.u.sym;
	if ( s ) {
		Datum d;
		d = (*symdataptr(s));
		if ( type < 0 || d.type == type ) {
			char *t = uniqstr(typestr(d.type));
			char *nm = symname(s);
			setarraydata(Listarr.u.arr,strdatum(nm),strdatum(t));
		}
	}
	return 0;
}

static int
add_method_tolist(Hnodep hn)
{
	add_stuff_tolist(hn,D_CODEP);
	return 0;
}

static int
add_data_tolist(Hnodep hn)
{
	add_stuff_tolist(hn,-1);
	return 0;
}

void
bi_objectinfo(int argc)
{
	Kobjectp o;
	Datum retval;
	char *t;

	if ( argc != 2 )
		execerror("usage: objectinfo(object,type)");
	o = needobj("objectinfo",ARG(0));
	t = needstr("objectinfo",ARG(1));
	if ( strcmp(t,"methods") == 0 ) {
		Listarr = newarrdatum(0,32);
		hashvisit(o->symbols, add_method_tolist);
		retval = Listarr;
	} else if ( strcmp(t,"data") == 0 ) {
		Listarr = newarrdatum(0,32);
		hashvisit(o->symbols, add_data_tolist);
		retval = Listarr;
	} else {
		execerror("usage: objectinfo(object,type)");
	}
	ret(retval);
}

void
bi_sprintf(int argc)
{
	char *fmt = needstr("sprintf",ARG(0));

	reinitmsg3();
	keyprintf(fmt,1,argc-1,ptomsg3);
	ret(strdatum(uniqstr(Msg3)));
}

#ifdef MDEBUG
void
bi_mmreset(int argc)
{
	mmreset();
	ret(Nullval);
}
void
bi_mmdump(int argc)
{
	mmdump();
	/* printf("Totnotes=%d  Newnotes=%d\n",Totnotes,Newnotes);
	printf("Totphr=%d  Newphr=%d\n",Totphr,Newphr); */
	ret(Nullval);
}
#endif

void
bi_nullfunc(int argc)
{
	dummyusage(argc);
	ret(Nullval);
}

/* The order of elements in this array is not important */
struct bltinfo builtins[] = {
	{ "sizeof",	bi_sizeof,	BI_SIZEOF },
	{ "oldnargs",	bi_oldnargs,	BI_OLDNARGS },
	{ "argv",		bi_argv,	BI_ARGV },
	{ "midibytes",	bi_midibytes,	BI_MIDIBYTES },
	{ "substr",	bi_substr,	BI_SUBSTR },
	{ "subbytes",	bi_sbbyes,	BI_SBBYES },
	{ "rand",		bi_rand,	BI_RAND },
	{ "error",	bi_error,	BI_ERROR },
	{ "printf",	bi_printf,	BI_PRINTF },
	{ "readphr",	bi_readphr,	BI_READPHR },
	{ "exit",		bi_exit,	BI_EXIT },
	{ "oldtypeof",	bi_oldtypeof,	BI_OLDTYPEOF },
	{ "split",	bi_split,	BI_SPLIT },
	{ "cut",		bi_cut,		BI_CUT },
	{ "string",	bi_string,	BI_STRING },
	{ "integer",	bi_integer,	BI_INTEGER },
	{ "phrase",	bi_phrase,	BI_PHRASE },
	{ "float",	bi_float,	BI_FLOAT },
	{ "system",	bi_system,	BI_SYSTEM },
	{ "chdir",	bi_chdir,	BI_CHDIR },
	{ "tempo",	bi_tempo,	BI_TEMPO },
	{ "milliclock",	bi_milliclock,	BI_MILLICLOCK },
	{ "currtime",	bi_currtime,	BI_CURRTIME },
	{ "filetime",	bi_filetime,	BI_FILETIME },
	{ "garbcollect",	bi_garbcollect,	BI_GARBCOLLECT },
	{ "funkey",	bi_funkey,	BI_FUNKEY },
	{ "ascii",	bi_ascii,	BI_ASCII },
	{ "midifile",	bi_midifile,	BI_MIDIFILE },
	{ "reboot",	bi_reboot,	BI_REBOOT },
	{ "refunc",	bi_refunc,	BI_REFUNC },
	{ "debug",	bi_debug,	BI_DEBUG },
	{ "nullfunc",	bi_nullfunc,	BI_NULLFUNC },
	{ "pathsearch",	bi_pathsearch,	BI_PATHSEARCH },
	{ "symbolnamed",	bi_symbolnamed,	BI_SYMBOLNAMED },
	{ "limitsof",	bi_limitsof,	BI_LIMITSOF },
	{ "sin",		bi_sin,		BI_SIN },
	{ "cos",		bi_cos,		BI_COS },
	{ "tan",		bi_tan,		BI_TAN },
	{ "asin",		bi_asin,	BI_ASIN },
	{ "acos",		bi_acos,	BI_ACOS },
	{ "atan",		bi_atan,	BI_ATAN },
	{ "sqrt",		bi_sqrt,	BI_SQRT },
	{ "pow",		bi_pow,		BI_POW },
	{ "exp",		bi_exp,		BI_EXP },
	{ "log",		bi_log,		BI_LOG },
	{ "log10",	bi_log10,	BI_LOG10 },
	{ "realtime",	bi_realtime,	BI_REALTIME },
	{ "finishoff",	bi_finishoff,	BI_FINISHOFF },
	{ "sprintf",	bi_sprintf,	BI_SPRINTF },
/* FIFO-RELATED FUNCTIONS */
	{ "get",		bi_get,		BI_GET },
	{ "put",		bi_put,		BI_PUT },
	{ "open",		bi_open,	BI_OPEN },
	{ "fifosize",	bi_fifosize,	BI_FIFOSIZE },
	{ "flush",	bi_flush,	BI_FLUSH },
	{ "close",	bi_close,	BI_CLOSE },
/* TASK-RELATED FUNCTIONS */
	{ "taskinfo",	bi_taskinfo,	BI_TASKINFO },
	{ "kill",		bi_kill,	BI_KILL },
	{ "priority",	bi_priority,	BI_PRIORITY },
	{ "onexit",	bi_onexit,	BI_ONEXIT },
	{ "onerror",	bi_onerror,	BI_ONERROR },
	{ "sleeptill",	bi_sleeptill,	BI_SLEEPTILL },
	{ "wait",		bi_wait,	BI_WAIT },
	{ "lock",		bi_lock,	BI_LOCK },
	{ "unlock",	bi_unlock,	BI_UNLOCK },
/* OBJECT-RELATED FUNCTIONS */
	{ "object",	bi_object,	BI_OBJECT },
	{ "objectlist",	bi_objectlist,	BI_OBJECTLIST },
/* GRAPHICS-RELATED FUNCTIONS */
	{ "windowobject",	bi_windobject,	BI_WINDOBJECT },
	{ "screen",	bi_screen,	BI_SCREEN },
	{ "setmouse",	bi_setmouse,	BI_SETMOUSE },
	{ "mousewarp",	bi_mousewarp,	BI_MOUSEWARP },
	{ "browsefiles",	bi_browsefiles,	BI_BROWSEFILES },
	{ "colorset",	bi_colorset,	BI_COLORSET },
	{ "colormix",	bi_colormix,	BI_COLORMIX },
	{ "sync",		bi_sync,	BI_SYNC },
	{ "oldxy",	bi_oldxy,	BI_OLDXY },
	{ "Redrawfunc",	bi_nullfunc,	BI_NULLFUNC },
	{ "Resizefunc",	bi_nullfunc,	BI_NULLFUNC },
	{ "Colorfunc",	bi_nullfunc,	BI_NULLFUNC },
	{ "popup",	bi_printf,	BI_PRINTF },
/* MISC FUNCTIONS */
	{ "help",		bi_help,	BI_HELP },
	{ "rekeylib",	bi_rekeylib,	BI_REKEYLIB },
	{ "Exitfunc",	bi_nullfunc,	BI_NULLFUNC },
	{ "Errorfunc",	bi_exit,	BI_EXIT },
	{ "Rebootfunc",	bi_nullfunc,	BI_NULLFUNC },
	{ "Intrfunc",	bi_exit,	BI_EXIT },
	{ "coreleft",	bi_coreleft,	BI_CORELEFT },
	{ "prstack",	bi_prstack,	BI_PRSTACK },
	{ "phdump",	bi_phdump,	BI_PHDUMP },
	{ "lsdir",	bi_lsdir,	BI_LSDIR },
	{ "attribarray",	bi_attribarray,	BI_ATTRIBARRAY },
	{ "fifoctl",	bi_fifoctl,	BI_FIFOCTL },
	{ "mdep",		bi_mdep,	BI_MDEP },
	{ "midi",		bi_midi,	BI_MIDI },
	{ "bitmap",	bi_bitmap,	BI_BITMAP },
	{ "objectinfo",	bi_objectinfo,	BI_OBJECTINFO },
	{ 0,		0,		0 }
};

/* Watch out, the order of elements in this array must match */
/* the BI_* and O_* values */
BLTINFUNC Bltinfuncs[] = {
	0,
	bi_sizeof,
	bi_oldnargs,
	bi_argv,
	bi_midibytes,
	bi_substr,
	bi_sbbyes,
	bi_rand,
	bi_error,
	bi_printf,
	bi_readphr,
	bi_exit,
	bi_oldtypeof,
	bi_split,
	bi_cut,
	bi_string,
	bi_integer,
	bi_phrase,
	bi_float,
	bi_system,
	bi_chdir,
	bi_tempo,
	bi_milliclock,
	bi_currtime,
	bi_filetime,
	bi_garbcollect,
	bi_funkey,
	bi_ascii,
	bi_midifile,
	bi_reboot,
	bi_refunc,
	bi_debug,
	bi_pathsearch,
	bi_symbolnamed,
	bi_limitsof,
	bi_sin,
	bi_cos,
	bi_tan,
	bi_asin,
	bi_acos,
	bi_atan,
	bi_sqrt,
	bi_pow,
	bi_exp,
	bi_log,
	bi_log10,
	bi_realtime,
	bi_finishoff,
	bi_sprintf,
	bi_get,
	bi_put,
	bi_open,
	bi_fifosize,
	bi_flush,
	bi_close,
	bi_taskinfo,
	bi_kill,
	bi_priority,
	bi_onexit,
	bi_sleeptill,
	bi_wait,
	bi_lock,
	bi_unlock,
	bi_object,
	bi_objectlist,
	bi_windobject,
	bi_screen,
	bi_setmouse,
	bi_mousewarp,
	bi_browsefiles,
	bi_colorset,
	bi_colormix,
	bi_sync,
	bi_oldxy,
	bi_coreleft,
	bi_prstack,
	bi_phdump,
	bi_nullfunc,
	o_setinit,
	o_addchild,
	o_removechild,
	o_childunder,
	o_children,
	o_inherited,
	o_addinherit,
	o_size,
	o_redraw,
	o_contains,
	o_xmin,
	o_ymin,
	o_xmax,
	o_ymax,
	o_line,
	o_box,
	o_fill,
	o_style,
	o_mousedo,
	o_type,
	o_textcenter,
	o_textleft,
	o_textright,
	o_textheight,
	o_textwidth,
	o_saveunder,
	o_restoreunder,
	o_printf,
	o_drawphrase,
	o_scaletogrid,
	o_view,
	o_trackname,
	o_sweep,
	o_closestnote,
	o_menuitem,
	bi_lsdir,
	bi_rekeylib,
	bi_fifoctl,
	bi_mdep,
	bi_help,
	o_menuitems,
	o_ellipse,
	o_fillellipse,
	o_scaletowind,
	bi_attribarray,
	bi_onerror,
	bi_midi,
	bi_bitmap,
	bi_objectinfo,
	o_fillpolygon
};
