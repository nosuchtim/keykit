/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#define OVERLAY8

#include "key.h"
#include "gram.h"

Htablep Keywords = NULL;
Htablep Macros = NULL;
Htablep Topht = NULL;
static Htablep Freeht = NULL;

Context *Currct = NULL;
Context *Topct = NULL;

Symlongp Merge, Now, Clicks, Debug, Sync, Optimize, Mergefilter, Nowoffset;
Symlongp Mergeport1, Mergeport2;
Symlongp Debugwait, Debugmidi, Debugrun, Debugfifo, Debugmouse, Debuggesture;
Symlongp Clocksperclick, Clicksperclock, Graphics, Debugdraw, Debugmalloc;
Symlongp Millicount, Throttle2, Loadverbose, Warnnegative, Midifilenoteoff;
Symlongp Drawcount, Mousedisable, Forceinputport, Showsync, Echoport;
Symlongp Inputistty, Debugoff, Fakewrap, Mfsysextype;
Symlongp Tempotrack, Onoffmerge, Defrelease, Grablimit, Mfformat, Defoutport;
Symlongp Filter, Record, Recsched, Throttle, Recfilter, Recinput, Recsysex;
Symlongp Lowcorelim, Arraysort, Midithrottle, Defpriority;
Symlongp Taskaddr, Debuginst, Usewindfifos, Prepoll, Printsplit;
Symlongp Novalval, Eofval, Intrval, Debugkill, Debugkill1, Linetrace;
Symlongp Abortonint, Abortonerr, Redrawignoretime, Resizeignoretime;
Symlongp Consecho, Checkcount, Isofuncwarn, Consupdown, Monitor_fnum;
Symlongp Consecho_fnum, Slashcheck, Directcount, SubstrCount;
Symlongp Mousefnum, Consinfnum, Consoutfnum, Midi_in_fnum, Mousefifolimit;
Symlongp Saveglobalsize, Warningsleep, Millires, Milliwarn, Resizefix;
Symlongp Deftimeout;
Symlongp Minbardx, Kobjectoffset, Midi_out_fnum, Mousemoveevents;
Symlongp Numinst1, Numinst2, Offsetpitch, Offsetfilter, DoDirectinput;
Symlongp Offsetportfilter;
Datum *Rebootfuncd, *Nullfuncd, *Errorfuncd;
Datum *Intrfuncd, *Nullvald;
Datum Zeroval, Noval, Nullval, _Dnumtmp_;
Datum *Colorfuncd;
Datum *Redrawfuncd;
Datum *Resizefuncd;
Datum *Exitfuncd;
Htablepp Track, Wpick;
Htablepp Chancolormap;
Symlongp Chancolors;

void
newcontext(Symbolp s, int sz)
{
	Context *c;

	c = (Context *) kmalloc(sizeof(Context),"newcontext");
	c->symbols = newht(sz);
	c->func = s;
	c->next = Currct;
	c->localnum = 1;
	c->paramnum = 1;
	Currct = c;
}

void
popcontext(void)
{
	Context *nextc;
	if ( Currct == NULL || Currct->next == NULL )
		execerror("popcontext called too many times!\n");
	nextc = Currct->next;
	kfree((char*)Currct);
	Currct = nextc;
}

Symbolp Free_sy = NULL;

Symbolp
newsy(void)
{
	static Symbolp lastsy;
	static int used = ALLOCSY;
	Symbolp s;

	/* First check the free list and use those nodes, before using */
	/* the newly allocated stuff. */
	if ( Free_sy != NULL ) {
		s = Free_sy;
		Free_sy = Free_sy->next;
		goto getout;
	}

	/* allocate a BUNCH of new ones at a time */
	if ( used == ALLOCSY ) {
		used = 0;
		lastsy = (Symbolp) kmalloc(ALLOCSY*sizeof(Symbol),"newsy");
	}
	used++;
	s = lastsy++;

    getout:
	s->stype = UNDEF;
	s->stackpos = 0;	/* i.e. it's global */
	s->flags = 0;
	s->onchange = NULL;
	s->next = NULL;
	return(s);
}

void
freesy(register Symbolp sy)
{
	/* Add it to the list of free symbols */
	sy->next = Free_sy;
	Free_sy = sy;
}

Symbolp
findsym(register char *p,Htablep symbols)
{
	Datum key;
	Hnodep h;

	key = strdatum(p);
	h = hashtable(symbols,key,H_LOOK);
	if ( h )
		return h->val.u.sym;
	else
		return NULL;
}

Symbolp
findobjsym(char *p,Kobjectp o,Kobjectp *foundobj)
{
	Datum key;
	Hnodep h;
	Htablep symbols = o->symbols;
	Symbolp s;

	if ( symbols == NULL ) {
		mdep_popup("Internal error - findobjsym finds NULL symbols!");
		return NULL;
	}
	key = strdatum(p);
	h = hashtable(symbols,key,H_LOOK);
	if ( h ) {
		if ( foundobj )
			*foundobj = o;
		return h->val.u.sym;
	}

	/* Not found, try inherited objects */
	if ( o->inheritfrom != NULL ) {
		Kobjectp o2;
		for ( o2=o->inheritfrom; o2!=NULL; o2=o2->nextinherit ) {
			s=findobjsym(p,o2,foundobj);
			if ( s != NULL ) {
				return(s);
			}
		}
	}
	return NULL;
}

Symbolp
uniqvar(char* pre)
{
	static long unum = 0;
	char buff[32];

	if ( pre == NULL )
		pre = "";
	strncpy(buff,pre,20);	/* 20 is 32 - (space for NONAMEPREFIX + num) */
	buff[20] = 0;
	sprintf(strend(buff),"%s%ld",NONAMEPREFIX,unum++);
	if ( unum > (MAXLONG-4) )
		execerror("uniqvar() has run out of names!?");
	return globalinstallnew(uniqstr(buff),VAR);
}

/* lookup(p) - find p in symbol table */
Symbolp
lookup(char *p)
{
	Symbolp s;

	if ( (s=findsym(p,Currct->symbols)) != NULL )
		return(s);
	if ( Currct != Topct && (s=findsym(p,Topct->symbols)) != NULL )
		return(s);
	return(NULL);
}

Symbolp
localinstall(Symstr p,int t)
{
	Symbolp s = syminstall(p,Currct->symbols,t);
	if ( Inparams )
		s->stackpos = Currct->paramnum++;
	else
		s->stackpos = -(Currct->localnum++);	/* okay if chars are unsigned*/
	return(s);
}

int Starting = 1;

Symbolp
globalinstall(Symstr p,int t)
{
	Symbolp s;
	if ( (s=findsym(p,Topct->symbols)) != NULL )
		return s;
	s = syminstall(p,Topct->symbols,t);
	return(s);
}

/* Use this variation if you know that the symbol is new */
Symbolp
globalinstallnew(Symstr p,int t)
{
	return syminstall(p,Topct->symbols,t);
}

Symbolp
syminstall(Symstr p,Htablep symbols,int t)
{
	Symbolp s;
	Hnodep h;
	Datum key;

	key = strdatum(p);
	h = hashtable(symbols,key,H_INSERT);
	if ( h==NULL )
		execerror("Unexpected h==NULL in syminstall!?");
	if ( isnoval(h->val) ) {
		s = newsy();
		s->name = key;
		s->stype = t;
		s->stackpos = 0;
		s->sd = Noval;
		h->val = symdatum(s);
	}
	else {
		if ( h->val.type != D_SYM )
			execerror("Unexpected h->val.type!=D_SYM in syminstall!?");
		s = h->val.u.sym;
	}
	return s;
}

void
clearsym(register Symbolp s)
{
#ifdef OLDSTUFF
	Codep cp;
	BLTINCODE bc;
#endif

	if ( s->stype == VAR ) {
		Datum *dp = symdataptr(s);
		switch (dp->type) {
		case D_ARR:
			if ( dp->u.arr ) {
				arrdecruse(dp->u.arr);
				dp->u.arr = NULL;
			}
			break;
		case D_PHR:
			if ( dp->u.phr != NULL ) {
				phdecruse(dp->u.phr);
				dp->u.phr = NULL;
			}
			break;
		case D_CODEP:

			/* BUG FIX - 5/4/97 - no longer free it */
#ifdef OLDSTUFF
			cp = dp->u.codep;
			bc = ((cp==NULL) ? 0 : BLTINOF(cp));
			/* If it's a built-in function, then the codep was */
			/* allocated by funcdp(), so we can free it. */
			if ( bc != 0 ) {
				/* kfree(cp); */
				dp->u.codep = NULL;
			}
#endif
			dp->u.codep = NULL;
			break;
		default:
			break;
		}
	}
}

static struct {		/* Keywords */
	char	*name;
	int	kval;
} keywords[] = {
	{ "function",	FUNC },
	{ "return",	RETURN },
	{ "if",		IF },
	{ "else",		ELSE },
	{ "while",	WHILE },
	{ "for",		FOR },
	{ "in",		SYM_IN },  /* to avoid conflict on windows */
	{ "break",	BREAK },
	{ "continue",	CONTINUE },
	{ "task",		TASK },
	{ "eval",		EVAL },
	{ "vol",		VOL },	/* sorry, I'm just used to 'vol' */
	{ "volume",	VOL },
	{ "vel",		VOL },
	{ "velocity",	VOL },
	{ "chan",		CHAN },
	{ "channel",	CHAN },
	{ "pitch",	PITCH },
	{ "time",		TIME },
	{ "dur",		DUR },
	{ "duration",	DUR },
	{ "length",	LENGTH },
	{ "number",	NUMBER },
	{ "type",		TYPE },
	{ "defined",	DEFINED },
	{ "undefine",	UNDEFINE },
	{ "delete",	SYM_DELETE },
	{ "readonly",	READONLY },
	{ "onchange",	ONCHANGE },
	{ "flags",	FLAGS },
	{ "varg",		VARG },
	{ "attrib",	ATTRIB },
	{ "global",	GLOBALDEC },
	{ "class",	CLASS },
	{ "method",	METHOD },
	{ "new",		KW_NEW },
	{ "nargs",	NARGS },
	{ "typeof",	TYPEOF },
	{ "xy",		XY },
	{ "port",		PORT },
	{ 0,		0 },
};

long
neednum(char *s,Datum d)
{
	if ( d.type != D_NUM && d.type != D_DBL )
		execerror("%s expects a number, got %s!",s,atypestr(d.type));
	return ( roundval(d) );
}

Codep
needfunc(char *s,Datum d)
{
	if ( d.type != D_CODEP )
		execerror("%s expects a function, got %s!",s,atypestr(d.type));
	return d.u.codep;
}

Kobjectp
needobj(char *s,Datum d)
{
	if ( d.type != D_OBJ )
		execerror("%s expects an object, got %s!",s,atypestr(d.type));
	return d.u.obj;
}

Fifo *
needfifo(char *s,Datum d)
{
	long n;
	Fifo *f;

	if ( d.type != D_NUM && d.type != D_DBL ) {
		execerror("%s expects a fifo id (i.e. a number), but got %s!",
			s,atypestr(d.type));
	}
	n = roundval(d);
	f = fifoptr(n);
	return f;
}

Fifo *
needvalidfifo(char *s,Datum d)
{
	Fifo *f;

	f = needfifo(s,d);
	if ( f == NULL )
		execerror("%s expects a fifo id, and %ld is not a valid fifo id!",s,numval(d));
	return f;
}

char *
needstr(char *s,Datum d)
{
	if ( d.type != D_STR )
		execerror("%s expects a string, got %s!",s,atypestr(d.type));
	return ( d.u.str );
}

Htablep
needarr(char *s,Datum d)
{
	if ( d.type != D_ARR )
		execerror("%s expects an array, got %s!",s,atypestr(d.type));
	return ( d.u.arr );
}

Phrasep
needphr(char *s,Datum d)
{
	if ( d.type != D_PHR )
		execerror("%s expects a phrase, got %s!",s,atypestr(d.type));
	return ( d.u.phr );
}

Symstr
datumstr(Datum d)
{
	char buff[32];
	char *p;
	long id;

	if ( isnoval(d) )
		execerror("Attempt to convert uninitialized value (Noval) to string!?");

	switch ( d.type ) {
	case D_NUM:
		(void) prlongto(d.u.val,p=buff);
		break;
	case D_PHR:
		p = phrstr(d.u.phr,0);
		break;
	case D_DBL:
		sprintf(p=buff,"%g",d.u.dbl);
		break;
	case D_STR:
		p = d.u.str;
		break;
	case D_ARR:
		/* we re-use the routines in main.c for doing */
		/* printing into a buffer.  I supposed we could really */
		/* do this for all the data types here. */
		stackbuffclear();
		prdatum(d,stackbuff,1);
		p = stackbuffstr();
		break;
	case D_OBJ:
		buff[0] = '$';
		id = (d.u.obj?d.u.obj->id:-1) + *Kobjectoffset;
		(void) prlongto(id,buff+1);
		p = buff;
		break;
	default:
		p = "";
		break;
	}
	p = uniqstr(p);
	return p;
}

Datum
newarrdatum(int used,int size)
{
	Datum d;

	d.type = D_ARR;
	d.u.arr = newht(size>0 ? size : ARRAYHASHSIZE);
	
#ifdef OLDSTUFF
if(Debug&&*Debug>1)eprint("newarrdatum(%d), d.u.arr=%ld\n",used,(long)(d.u.arr));
#endif
	d.u.arr->h_used = used;
	d.u.arr->h_tobe = 0;
	return d;
}

Htablepp
globarray(char *name)
{
	Datum *dp;
	Symbolp s;

	s = globalinstall(name,VAR);
	s->stype = VAR;
	dp = symdataptr(s);
	*dp = newarrdatum(1,0);
	return &(dp->u.arr);
}

Datum
phrsplit(Phrasep p)
{
#define MAXSIMUL 128
	Noteptr activent[MAXSIMUL];
	long activetime[MAXSIMUL];
	Noteptr n, newn;
	Phrasep p2;
	Symbolp s;
	Datum d, da;
	long tm2;
	int i, j, k;
	Htablep arr;
	int samesection, nactive = 0;
	long t, elapse, closest, now = 0L;
	long arrnum = 0L;

	da = newarrdatum(0,0);
	arr = da.u.arr;

	n = firstnote(p);

	while ( n!=NULL || nactive>0 ) {

		/* find out which event is closer: the end of a pending */
		/* note, or the start of the next one (if there is one). */

		if ( n != NULL ) {
			closest = n->clicks - now;
			samesection = 1;
		}
		else {
			closest = 30000;
			samesection = 0;
		}

		/* Check the ending times of the pending notes, to see */
		/* if any of them end before the next note starts.  If so, */
		/* we want to create a new section.  */
		for ( k=0; k<nactive; k++ ) {
#ifdef OLDSTUFF
			if ( durof(activent[k]) <= 0 )
				continue;
#endif
			if ( (t=activetime[k]) <= closest ) {
				closest = t;
				samesection = 0;
			}
		}

		/* We want to let that amount of time elapse. */
		elapse = closest;
		if ( samesection!=0 && (closest == 0 || nactive == 0) )
			goto addtosame;

		/* We're going to create a new element in the split array */

		d = numdatum((long)arrnum++);
		s = arraysym(arr,d,H_INSERT);
		p2 = newph(1);

		/* add all active notes to the phrase */
		tm2 = now+elapse;
		for ( k=0; k<nactive; k++ ) {
			newn = ntcopy(activent[k]);
			if ( timeof(newn) < now ) {
				long overhang = now - timeof(newn);
				timeof(newn) += overhang;
				durof(newn) -= overhang;
			}
			if ( endof(newn) > tm2 ) {
				durof(newn) = tm2-timeof(newn);
			}
			ntinsert(newn,p2);
		}
		p2->p_leng = tm2;
		*symdataptr(s) = phrdatum(p2);

		/* If any notes are pending, take into account elapsed */
		/* time, and if they expire, get rid of them. */
		for ( i=0; i<nactive; i++ ) {
			if ( (activetime[i] -= elapse) <= 0L ) {
				/* Remove this note from the list by */
				/* shifting everything down. */
				for ( j=i+1; j<nactive; j++ ) {
					activetime[j-1] = activetime[j];
					activent[j-1] = activent[j];
				}
				nactive--;
				i--;	/* don't advance loop index */
			}
		}

	addtosame:
		if ( samesection ) {
			/* add this new note (and all others that start at the */
			/* same time) to the list of active ones */
			long thistime = timeof(n);
			while ( n!=NULL && timeof(n) == thistime ) {
				if ( nactive >= MAXSIMUL )
					execerror("Too many simultaneous notes in expression (limit is %d)\n",MAXSIMUL);
				activent[nactive] = n;
				activetime[nactive++] = durof(n);
				/* advance to next note */
				n = nextnote(n);
			}
		}
		now += elapse;
	}
	return(da);
}

/* sep contains the list of possible separator characters. */
/* multiple consecutive separator characters are treated as one. */

Datum
strsplit(char *str,char *sep)
{
	char buffer[128];
	char *buff, *p, *endp;
	char *word = NULL;
	int isasep;
	Datum da;
	Htablep arr;
	long n;
	int slen = (int)strlen(str);
	int state;

	/* avoid kmalloc if we can use small buffer */
	if ( slen >= (int)sizeof(buffer) )
		buff = kmalloc((unsigned)(slen+1),"strsplit");
	else
		buff = buffer;
	strcpy(buff,str);
	endp = buff + slen;

	/* An inital scan to figure out how big an array we need */
	for ( state=0,n=0,p=buff; state >= 0 && p < endp ; p++ ) {
		isasep = (strchr(sep,*p) != NULL);
		switch ( state ) {
		case 0:	/* before word */
			if ( ! isasep )
				state = 1;
			break;
		case 1:	/* scanning word */
			if ( isasep ) {
				n++;
				state=0;
			}
			break;
		}
	}
	if ( state == 1 )
		n++;

	da = newarrdatum(0,(int)n);
	arr = da.u.arr;

	for ( state=0,n=0,p=buff; state >= 0 && p < endp ; p++ ) {

		isasep = (strchr(sep,*p) != NULL);
		switch ( state ) {
		case 0:	/* before word */
			if ( ! isasep ) {
				word = p;
				state = 1;
			}
			break;
		case 1:	/* scanning word */
			if ( isasep ) {
				*p = '\0';
				setarrayelem(arr,n++,word);
				state=0;
			}
			break;
		}
	}
	if ( state == 1 ) {
		*p = '\0';
		setarrayelem(arr,n++,word);
	}
	if ( slen >= (int)sizeof(buffer) )
		kfree(buff);
	return(da);
}

void
setarraydata(Htablep arr,Datum i,Datum d)
{
	Symbolp s;
	if ( isnoval(i) )
		execerror("Can't use undefined value as array index\n");
	s = arraysym(arr,i,H_INSERT);
	*symdataptr(s) = d;
}

void
setarrayelem(Htablep arr,long n,char *p)
{
	setarraydata(arr,numdatum(n),strdatum(uniqstr(p)));
}

void
fputdatum(FILE *f,Datum d)
{
	char *str = datumstr(d);
	int c;
	int i = 0;
	int nl = (*Printsplit)!=0;

	if ( d.type == D_STR )
		putc('"',f);
	for ( ; (c=(*str)) != '\0'; str++ ) {
		char *p = NULL;
		i++;
		if ( nl>0 && i>nl ) {
			i = 0;
			fputs("\\\n",f);
		}
		switch (c) {
		case '\n':
			p = "\\n";
			break;
		case '\r':
			p = "\\r";
			break;
		case '"':
			p = "\\\"";
			break;
		case '\\':
			p = "\\\\";
			break;
		}
		if ( p )
			fputs(p,f);
		else
			putc(c,f);
	}
	if ( d.type == D_STR )
		putc('"',f);
}

static struct binum {
	char *name;
	long val;
	Symlongp *ptovar;
} binums[] = {
	{ "Noval", MAXLONG, &Novalval },
	{ "Eof", MAXLONG-1, &Eofval },
	{ "Interrupt", MAXLONG-2, &Intrval },
	{ "Merge", 0L, &Merge },
	{ "Mergeport1", 0L, &Mergeport1 },    // default output
	{ "Mergeport2", -1L, &Mergeport2 },   //
	{ "Mergefilter", 0L, &Mergefilter },
	{ "Clicks", (long)(DEFCLICKS), &Clicks },
	{ "Debug", 0L, &Debug },
	{ "Optimize", 1L, &Optimize },
	{ "Debugwait", 0L, &Debugwait },
	{ "Debugoff", 0L, &Debugoff },
	{ "Fakewrap", 0L, &Fakewrap },
	{ "Debugrun", 0L, &Debugrun },
	{ "Debuginst", 0L, &Debuginst },
	{ "Debugkill", 0L, &Debugkill },
	{ "Debugfifo", 0L, &Debugfifo },
	{ "Debugmalloc", 0L, &Debugmalloc },
	{ "Debugdraw", 0L, &Debugdraw },
	{ "Debugmouse", 0L, &Debugmouse },
	{ "Debugmidi", 0L, &Debugmidi },
	{ "Debuggesture", 0L, &Debuggesture },
	{ "Now", -1L, &Now },
	{ "Nowoffset", 0L, &Nowoffset },
	{ "Sync", 0L, &Sync },
	{ "Showsync", 0L, &Showsync },
	{ "Clocksperclick", 1L, &Clocksperclick },
	{ "Clicksperclock", 1L, &Clicksperclock },
	{ "Filter", 0L, &Filter },	/* bitmask for message filtering */
	{ "Record", 1L, &Record },		/* If 0, recording is disabled */
	{ "Recsched", 0L, &Recsched },	/* If 1, record scheduled stuff */
	{ "Recinput", 1L, &Recinput },	/* If 1, record midi input */
	{ "Recsysex", 1L, &Recsysex },	/* If 1, record sysex */
	{ "Recfilter", 0L, &Recfilter },	/* per-channel bitmask turns off recording */
	{ "Lowcore", DEFLOWLIM, &Lowcorelim },
	{ "Millicount", 0L, &Millicount },	/* see mdep.c */
	{ "Throttle2", 100L, &Throttle2 },
	{ "Drawcount", 8L, &Drawcount },
	{ "Mousedisable", 0L, &Mousedisable },
	{ "Forceinputport", -1L, &Forceinputport },
	{ "Checkcount", 20L, &Checkcount },
	{ "Loadverbose", 0L, &Loadverbose },
	{ "Warnnegative", 1L, &Warnnegative },
	{ "Midifilenoteoff", 1L, &Midifilenoteoff },
	{ "Isofuncwarn", 1L, &Isofuncwarn },
	{ "Inputistty", 0L, &Inputistty },
	{ "Arraysort", 0, &Arraysort },
	{ "Taskaddr", 0, &Taskaddr },
	{ "Tempotrack", 0, &Tempotrack },
	{ "Onoffmerge", 1, &Onoffmerge },
	{ "Defrelease", 0, &Defrelease },
	{ "Defoutport", 0, &Defoutport },
	{ "Echoport", 0, &Echoport },
	{ "Grablimit", 1000, &Grablimit },
	{ "Mfformat", 0, &Mfformat },
	{ "Mfsysextype", 0, &Mfsysextype },
	{ "Trace", 1, &Linetrace },
	{ "Abortonint", 0, &Abortonint },
	{ "Abortonerr", 0, &Abortonerr },
	{ "Debugkill1", 0, &Debugkill1 },
	{ "Consecho", 1, &Consecho },
	{ "Slashcheck", 1, &Slashcheck },
	{ "Directcount", 0, &Directcount },
	{ "SubstrCount", 0, &SubstrCount },
	{ "Consupdown", 0, &Consupdown },
	{ "Prepoll", 0, &Prepoll },
	{ "Printsplit", 77, &Printsplit },
	{ "Midithrottle", 128, &Midithrottle },
	{ "Throttle", 100, &Throttle },
	{ "Defpriority", 500, &Defpriority },
	{ "Redrawignoretime", 100L, &Redrawignoretime },
	{ "Resizeignoretime", 100L, &Resizeignoretime },
	{ "Graphics", 1, &Graphics },
	{ "Consinfifo", -1, &Consinfnum },
	{ "Consoutfifo", -1, &Consoutfnum },
	{ "Mousefifo", -1, &Mousefnum },
	{ "Midiinfifo", -1, &Midi_in_fnum },
	{ "Midioutfifo", -1, &Midi_out_fnum },
	{ "Monitorfifo", -1, &Monitor_fnum },
	{ "Consechofifo", -1, &Consecho_fnum },
	{ "Saveglobalsize", 256L, &Saveglobalsize },
	{ "Warningsleep", 0L, &Warningsleep },
	{ "Deftimeout", 2L, &Deftimeout },
	{ "Millires", 1L, &Millires },
	{ "Milliwarn", 2L, &Milliwarn },
	{ "Resizefix", 1L, &Resizefix },
	{ "Mousemoveevents", 0L, &Mousemoveevents },
	{ "Objectoffset", 0L, &Kobjectoffset },
	{ "Showtext", 1, &Showtext },
	{ "Showbar", 4*DEFCLICKS, &Showbar },
	{ "Sweepquant", 1, &Sweepquant },
	{ "Menuymargin", 2, &Menuymargin },
	{ "Menusize", 12, &Menusize },
	{ "Dragquant", 1, &Dragquant },
	{ "Menuscrollwidth", 15, &Menuscrollwidth },
	{ "Textscrollsize", 200, &Textscrollsize },
	{ "Menujump", 0, &Menujump },
	{ "Panraster", 1, &Panraster },
	{ "Bendrange", 1024*16, &Bendrange },
	{ "Bendoffset", 64, &Bendoffset },
	{ "Volstem", 0, &Volstem },
	{ "Volstemsize", 4, &Volstemsize },
	{ "Colors", 2, &Colors },
	{ "Colornotes", 1, &Colornotes },
	{ "Chancolors", 0, &Chancolors },
	{ "Inverse", 0, &Inverse },
	{ "Usewindfifos", 0, &Usewindfifos },
	{ "Mousefifolimit", 1L, &Mousefifolimit },
	{ "Minbardx", 8L, &Minbardx },
	{ "Numinst1", 0L, &Numinst1 },
	{ "Numinst2", 0L, &Numinst2 },
	{ "Directinput", 0L, &DoDirectinput },
	{ "Offsetpitch", 0L, &Offsetpitch },
	{ "Offsetportfilter", -1L, &Offsetportfilter },
	{ "Offsetfilter", 1<<9, &Offsetfilter },/* per-channel bitmask turns off
		offset effect, default turns it off for channel 10, drums */
	{ 0, 0, 0 }
};

Phrasepp Currphr, Recphr;

static struct biphr {
	char *name;
	Phrasepp *ptophr;
} biphrs[] = {
	{ "Current", &Currphr },
	{ "Recorded", &Recphr },
	{ 0, 0 }
};

Symstrp Keypath, Machine, Keyerasechar, Keykillchar, Keyroot;
Symstrp Printsep, Printend, Musicpath;
Symstrp Pathsep, Dirseparator, Devmidi, Version, Initconfig, Keypagepersistent, Nullvalsymp;
Symstrp Fontname, Icon, Windowsys, Drawwindow, Picktrack;

static struct bistr {
	char *name;
	char *val;
	Symstrp *ptostr;
} bistrs[] = {
	{ "Keyroot", "", &Keyroot },
	{ "Keypath", "", &Keypath },
	{ "Musicpath", "", &Musicpath },
	{ "Machine", MACHINE, &Machine },
	{ "Devmidi", "", &Devmidi },
	{ "Printsep", " ", &Printsep },
	{ "Printend", "\n", &Printend },
	{ "Pathseparator", PATHSEP, &Pathsep },
	{ "Dirseparator", SEPARATOR, &Dirseparator },
	{ "Version", KEYVERSION, &Version },
	{ "Initconfig", "", &Initconfig },
	{ "Keypagepersistent", "", &Keypagepersistent },
	{ "Killchar", "", &Keykillchar },
	{ "Erasechar", "", &Keyerasechar },
	{ "Font", "", &Fontname },
	{ "Icon", "", &Icon },
	{ "Windowsys", "", &Windowsys },
	{ "Nullval", "", &Nullvalsymp },
	{ 0, 0, 0 }
};

void
installnum(char *name,Symlongp *pvar,long defval)
{
	Symbolp s;
	name = uniqstr(name);
	/* Only install and set value if not already present */
	if ( (s=lookup(name)) == NULL ) {
		s = globalinstallnew(name,VAR);
		*symdataptr(s) = numdatum(defval);
	}
	*pvar = (Symlongp)( &(symdataptr(s)->u.val) ) ;
}

void
installstr(char *name,char *str)
{
	Symbolp s = globalinstallnew(uniqstr(name),VAR);
	*symdataptr(s) = strdatum(uniqstr(str));
}

/* build a Datum that is a function pointer, pointing to a built-in function */
Datum
funcdp(Symbolp s, BLTINCODE f)
{
	Codep cp;
	Datum d;
	int sz;

	sz = Codesize[IC_BLTIN] + varinum_size(0) + Codesize[IC_SYM];
	cp = (Codep) kmalloc(sz,"funcdp");
	// keyerrfile("CP 0 = %lld, sz=%d\n", (intptr_t)cp,sz);

	*Numinst1 += sz;

	d.type = D_CODEP;
	d.u.codep = cp;

	cp = put_bltincode(f,cp);
	// keyerrfile("CP 3 = %lld\n", (intptr_t)cp);
	cp = put_numcode(0,cp);
	// keyerrfile("CP 4 = %lld\n", (intptr_t)cp);
	cp = put_symcode(s,cp);
	// keyerrfile("CP 5 = %lld\n", (intptr_t)cp);
	return d;
}

/* Pre-defined macros.  It is REQUIRED that these values match the */
/* corresponding values in phrase.h and grid.h.  For example, the value */
/* of P_STORE must match STORE, NT_NOTE must match NOTE, etc.  */

static char *Stdmacros[] = {

	/* These are values for nt.type, also used as bit-vals for  */
	/* the value of Filter. */
	"MIDIBYTES 1", /* NT_LE3BYTES is not here - not user-visible */
	"NOTE 2",
	"NOTEON 4",
	"NOTEOFF 8",
	"CHANPRESSURE 16", "CONTROLLER 32", "PROGRAM 64", "PRESSURE 128",
		"PITCHBEND 256", "SYSEX 512", "POSITION 1024", "CLOCK 2048",
		"SONG 4096", "STARTSTOPCONT 8192", "SYSEXTEXT 16384",

	"Nullstr \"\"",

	/* Values for action() types.  The values are intended to not */
	/* overlap the values for interrupt(), to avoid misuse and */
	/* also to leave open the possibility of merging the two. */
	"BUTTON1DOWN 1024", "BUTTON2DOWN 2048", "BUTTON12DOWN 4096",
	"BUTTON1UP 8192", "BUTTON2UP 16384", "BUTTON12UP 32768",
	"BUTTON1DRAG 65536", "BUTTON2DRAG 131072", "BUTTON12DRAG 262144",
	"MOVING 524288",
	/* values for setmouse() and sweep() */
	"NOTHING 0", "ARROW 1", "SWEEP 2", "CROSS 3",
		"LEFTRIGHT 4", "UPDOWN 5", "ANYWHERE 6", "BUSY 7",
		"DRAG 8", "BRUSH 9", "INVOKE 10", "POINT 11", "CLOSEST 12",
		"DRAW 13",
	/* values for cut() */
	"NORMAL 0", "TRUNCATE 1", "INCLUSIVE 2",
	"CUT_TIME 3", "CUT_FLAGS 4", "CUT_TYPE 5",
	"CUT_CHANNEL 6", "CUT_NOTTYPE 7",
	/* values for menudo() */
	"MENU_NOCHOICE -1", "MENU_BACKUP -2", "MENU_UNDEFINED -3",
	"MENU_MOVE -4", "MENU_DELETE -5",
	/* values for draw() */
	"CLEAR 0", "STORE 1", "XOR 2",
	/* values for window() */
	"TEXT 1", "PHRASE 2",
	/* values for style() */
	"NOBORDER 0", "BORDER 1", "BUTTON 2", "MENUBUTTON 3", "PRESSEDBUTTON 4",
	/* values for kill() signals */
	"KILL 1",
	NULL
};

/* initsyms() - install constants and built-ins in table */
void
initsyms(void)
{
	int i;
	Symbolp s;
	Datum *dp;
	char *p;

	Zeroval = numdatum(0L);
	Noval = numdatum(MAXLONG);
	Nullstr = uniqstr("");

	Keywords = newht(113);	/* no good reason for 113 */ 
	for (i = 0; (p = keywords[i].name) != NULL; i++) {
		(void)syminstall(uniqstr(p), Keywords, keywords[i].kval);
	}

	for (i=0; (p=binums[i].name)!=NULL; i++) {
		/* Don't need to uniqstr(p), because installnum does it. */ 
		installnum(p,binums[i].ptovar,binums[i].val);
	}
	
	for (i=0; (p=biphrs[i].name)!=NULL; i++) {
		s = globalinstallnew(uniqstr(p),VAR);
		dp = symdataptr(s);
		*dp = phrdatum(newph(1));
		*(biphrs[i].ptophr) = &(dp->u.phr);
		s->stackpos = 0;	/* i.e. it's global */
	}
	
	for (i=0; (p=bistrs[i].name)!=NULL; i++) {
		s = globalinstallnew(uniqstr(p),VAR);
		dp = symdataptr(s);
		*dp = strdatum(uniqstr(bistrs[i].val));
		*(bistrs[i].ptostr) = &(dp->u.str);
	}
	
	for (i=0; (p=builtins[i].name)!=NULL; i++) {
		s = globalinstallnew(uniqstr(p), VAR);
		dp = symdataptr(s);
		*dp = funcdp(s,builtins[i].bltindex);
	}

	Rebootfuncd = symdataptr(lookup(uniqstr("Rebootfunc")));
	Nullfuncd = symdataptr(lookup(uniqstr("nullfunc")));
	Errorfuncd = symdataptr(lookup(uniqstr("Errorfunc")));
	Intrfuncd = symdataptr(lookup(uniqstr("Intrfunc")));
	Nullvald = symdataptr(lookup(uniqstr("Nullval")));
	Nullval = *Nullvald;

	Colorfuncd = symdataptr(lookup(uniqstr("Colorfunc")));
	Redrawfuncd = symdataptr(lookup(uniqstr("Redrawfunc")));
	Resizefuncd = symdataptr(lookup(uniqstr("Resizefunc")));
	Exitfuncd = symdataptr(lookup(uniqstr("Exitfunc")));
	Track = globarray(uniqstr("Track"));
	Chancolormap = globarray(uniqstr("Chancolormap"));

	Macros = newht(113);	/* no good reason for 113 */

	for ( i=0; (p=Stdmacros[i]) != NULL;  i++ ) {
		/* Some compilers make strings read-only */
		p = strsave(p);
		macrodefine(p,0);
		free(p);
	}
	sprintf(Msg1,"MAXCLICKS=%ld",(long)(MAXCLICKS));
	macrodefine(Msg1,0);
	sprintf(Msg1,"MAXPRIORITY=%ld",(long)(MAXPRIORITY));
	macrodefine(Msg1,0);

	*Inputistty = mdep_fisatty(Fin) ? 1 : 0;
	if ( *Inputistty == 0 )
		*Consecho = 0;
	Starting = 0;

	*Keypath = uniqstr(mdep_keypath());
	*Musicpath = uniqstr(mdep_musicpath());
}

void
initsyms2(void)
{
	if ( **Keyerasechar == '\0' ) {
		char str[2];
		str[0] = Erasechar;
		str[1] = '\0';
		*Keyerasechar = uniqstr(str);
	}
	if ( **Keykillchar == '\0' ) {
		char str[2];
		str[0] = Killchar;
		str[1] = '\0';
		*Keykillchar = uniqstr(str);
	}
}

Datum Str_x0, Str_y0, Str_x1, Str_y1, Str_x, Str_y, Str_button;
Datum Str_type, Str_mouse, Str_drag, Str_move, Str_up, Str_down;
Datum Str_highest, Str_lowest, Str_earliest, Str_latest, Str_modifier;
Datum Str_default, Str_w, Str_r, Str_init;
Datum Str_get, Str_set, Str_newline;
Datum Str_red, Str_green, Str_blue, Str_grey, Str_surface;
Datum Str_finger, Str_hand, Str_xvel, Str_yvel;
Datum Str_proximity, Str_orientation, Str_eccentricity;
Datum Str_width, Str_height;
#ifdef MDEP_OSC_SUPPORT
Datum Str_elements, Str_seconds, Str_fraction;
#endif

void
initstrs(void)
{
	Str_type = strdatum(uniqstr("type"));
	Str_mouse = strdatum(uniqstr("mouse"));
	Str_drag = strdatum(uniqstr("mousedrag"));
	Str_move = strdatum(uniqstr("mousemove"));
	Str_up = strdatum(uniqstr("mouseup"));
	Str_down = strdatum(uniqstr("mousedown"));
	Str_x = strdatum(uniqstr("x"));
	Str_y = strdatum(uniqstr("y"));
	Str_x0 = strdatum(uniqstr("x0"));
	Str_y0 = strdatum(uniqstr("y0"));
	Str_x1 = strdatum(uniqstr("x1"));
	Str_y1 = strdatum(uniqstr("y1"));
	Str_button = strdatum(uniqstr("button"));
	Str_modifier = strdatum(uniqstr("modifier"));
	Str_highest = strdatum(uniqstr("highest"));
	Str_lowest = strdatum(uniqstr("lowest"));
	Str_earliest = strdatum(uniqstr("earliest"));
	Str_latest = strdatum(uniqstr("latest"));
	Str_default = strdatum(uniqstr("default"));
	Str_w = strdatum(uniqstr("w"));
	Str_r = strdatum(uniqstr("r"));
	Str_init = strdatum(uniqstr("init"));
	Str_get = strdatum(uniqstr("get"));
	Str_set = strdatum(uniqstr("set"));
	Str_newline = strdatum(uniqstr("\n"));
	Str_red = strdatum(uniqstr("red"));
	Str_green = strdatum(uniqstr("green"));
	Str_blue = strdatum(uniqstr("blue"));
	Str_grey = strdatum(uniqstr("grey"));
	Str_surface = strdatum(uniqstr("surface"));
	Str_finger = strdatum(uniqstr("finger"));
	Str_hand = strdatum(uniqstr("hand"));
	Str_xvel = strdatum(uniqstr("xvel"));
	Str_yvel = strdatum(uniqstr("yvel"));
	Str_proximity = strdatum(uniqstr("proximity"));
	Str_orientation = strdatum(uniqstr("orientation"));
	Str_eccentricity = strdatum(uniqstr("eccentricity"));
	Str_height = strdatum(uniqstr("height"));
	Str_width = strdatum(uniqstr("width"));
#ifdef MDEP_OSC_SUPPORT
	Str_elements = strdatum(uniqstr("elements"));
	Str_seconds = strdatum(uniqstr("seconds"));
	Str_fraction = strdatum(uniqstr("fraction"));
#endif
}

static FILE *Mf;

void
pfprint(char *s)
{
	fputs(s,Mf);
}

void
phtofile(FILE *f,Phrasep p)
{
	Mf = f;
	phprint(pfprint,p,0);
	putc('\n',f);
	if ( fflush(f) )
		mdep_popup("Unexpected error from fflush()!?");
}

void
vartofile(Symbolp s, char *fname)
{
	FILE *f;
	
	if ( fname==NULL || *fname == '\0' )
		return;

	if ( stdioname(fname) )
		f = stdout;
	else if ( *fname == '|' ) {
#ifdef PIPES
		f = popen(fname+1,"w");
		if ( f == NULL ) {
			eprint("Can't open pipe: %s\n",fname+1);
			return;
		}
#else
		eprint("No pipes!\n");
		return;
#endif
	}
	else {
		f = getnopen(fname,"w");
		if ( f == NULL ) {
			eprint("Can't open %s\n",fname);
			return;
		}
	}

	phtofile(f,symdataptr(s)->u.phr);
	
	if ( f != stdout ) {
		if ( *fname != '|' )
			getnclose(fname);
#ifdef PIPES
		else {
			if ( pclose(f) < 0 )
				eprint("Error in pclose!?\n"); 
		}
#endif
	}
}

/* Map the contents of a file (or output of a pipe) into a phrase */
/* variable. Note that if the file can't be read or the pipe can't */
/* be opened, it's a silent error. */

void
filetovar(register Symbolp s, char *fname)
{
	FILE *f;
	Phrasep ph;

	if ( fname==NULL || *fname == '\0' )
		return;

	if ( stdioname(fname) )
		f = stdin;
	else if ( *fname == '|' ) {
		/* It's a pipe... */
#ifdef PIPES
		f = popen(fname+1,"r");
#else
		warning("No pipes!");
		return;
#endif
	}
	else {
		/* a normal file */

		/* Use KEYPATH value to look for files. */
		char *pf = mpathsearch(fname);
		if ( pf )
			fname = pf;

		f = getnopen(fname,"r");
	}
	if ( f == NULL || feof(f) )
		return;		/* Silence.  Might be appropriate to */
				/* make some noise when a pipe fails. */
	clearsym(s);
	s->stype = VAR;
	ph = filetoph(f,fname);
	phincruse(ph);
	*symdataptr(s) = phrdatum(ph);

	if ( f != stdin ) {
		if ( *fname != '|' )
			getnclose(fname);
#ifdef PIPES
		else
			if ( pclose(f) < 0 )
				eprint("Error in pclose!?\n"); 
#endif
	}

}

Hnodep Free_hn = NULL;

Hnodep
newhn(void)
{
	static Hnodep lasthn;
	static int used = ALLOCHN;
	Hnodep hn;

	/* First check the free list and use those nodes, before using */
	/* the newly allocated stuff. */
	if ( Free_hn != NULL ) {
		hn = Free_hn;
		Free_hn = Free_hn->next;
		goto getout;
	}

	/* allocate a BUNCH of new ones at a time */
	if ( used == ALLOCHN ) {
		used = 0;
		lasthn = (Hnodep) kmalloc(ALLOCHN*sizeof(Hnode),"newhn");
	}
	used++;
	hn = lasthn++;

    getout:
	hn->next = NULL;
	hn->val = symdatum(NULL);
	/* hn->key = NULL; */
	return(hn);
}

void
freehn(Hnodep hn)
{
	if ( hn == NULL )
		execerror("Hey, hn==NULL in freehn\n");

	switch ( hn->val.type ) {
	case D_SYM:
		if ( hn->val.u.sym ) {
			clearsym(hn->val.u.sym);
			freesy(hn->val.u.sym);
		}
		break;
	case D_TASK:
		if ( hn->val.u.task ) {
			freetp(hn->val.u.task);
		}
		break;
	case D_FIFO:
		if ( hn->val.u.fifo )
			freeff(hn->val.u.fifo);
		break;
	case D_WIND:
		break;
	default:
		eprint("Hey, type=%d in clearhn, should something go here??\n",hn->val.type);
		break;
	}
	hn->val = Noval;

	hn->next = Free_hn;
	Free_hn = hn;
}

#ifdef OLDSTUFF
void
chkfreeht() {
	register Htablep ht;
	if ( Freeht == NULL || Freeht->h_next == NULL )
		return;
	for ( ht=Freeht->h_next; ht!=NULL; ht=ht->h_next ) {
		if ( ht == Freeht ) {
			eprint("INFINITE LOOP IN FREEHT LIST!!!\n");
			abort();
		}
	}
}
#endif

/* To avoid freeing and re-allocating the large chunks of memory */
/* used for the hash tables, we keep them around and reuse them. */

Htablep
newht(int size)
{
	register Hnodepp h, pp;
	register Htablep ht;

/* eprint("(newht(%d ",size); */
	/* See if there's a saved table we can use */
	for ( ht=Freeht; ht!=NULL; ht=ht->h_next ) {
		if ( ht->size == size )
			break;
	}
	if ( ht != NULL ) {
		/* Remove from Freeht list */
		if ( ht->h_prev == NULL ) {
			/* it's the first one in the Freeht list */
			Freeht = ht->h_next;
			if ( Freeht != NULL )
				Freeht->h_prev = NULL;
		}
		else if ( ht->h_next == NULL ) {
			/* it's the last one in the Freeht list */
			ht->h_prev->h_next = NULL;
		}
		else {
			ht->h_next->h_prev = ht->h_prev;
			ht->h_prev->h_next = ht->h_next;
		}
	}
	else {
		ht = (Htablep) kmalloc( sizeof(Htable), "newht" );
		h = (Hnodepp) kmalloc( size * sizeof(Hnodep), "newht" );
		ht->size = size;
		ht->nodetable = h;
		/* initialize entire table to NULLS */
		pp = h + size;
		while ( pp-- != h )
			*pp =  NULL;
	}

	ht->count = 0;
	ht->h_used = 0;
	ht->h_tobe = 0;
	ht->h_next = NULL;
	ht->h_prev = NULL;
	ht->h_state = 0;
	if ( Topht != NULL ) {
		Topht->h_prev = ht;
		ht->h_next = Topht;
	}
	Topht = ht;
	return(ht);
}

void
clearht(Htablep ht)
{
	register Hnodep hn, nexthn;
	register Hnodepp pp;
	register int n = ht->size;
	
	pp = ht->nodetable;
	/* as we're freeing the Hnodes pointed to by this hash table, */
	/* we zero out the table, in preparation for its reuse. */
#ifdef lint
	nexthn = 0;
#endif
	if ( ht->count != 0 ) {
		while ( --n >= 0 ) {
			for ( hn=(*pp); hn != NULL; hn=nexthn ) {
				nexthn = hn->next;
/* if(*Debug>0)eprint("freehn being called from clearht\n"); */
				freehn(hn);
			}
			*pp++ = NULL;
		}
	}
	ht->count = 0;
}

void
freeht(Htablep ht)
{
	register Htablep ht2;

	clearht(ht);

	/* If it's in the Htobechecked list... */
	for ( ht2=Htobechecked; ht2!=NULL; ht2=ht2->h_next ) {
		if ( ht2 == ht )
			break;
	}
	/* remove it */
	if ( ht2 != NULL ) {
		if ( ht2->h_next )
			ht2->h_next->h_prev = ht2->h_prev;
		if ( ht2 == Htobechecked )
			Htobechecked = ht2->h_next;
		else
			ht2->h_prev->h_next = ht2->h_next;
	}

	for ( ht2=Freeht; ht2!=NULL; ht2=ht2->h_next ) {
		if ( ht == ht2 ) {
			eprint("HEY!, Trying to free an ht node (%lld) that's already in the Free list!!\n",(intptr_t)ht);
			abort();
		}
	}
	/* Add to Freeht list */
	if ( Freeht )
		Freeht->h_prev = ht;
	ht->h_next = Freeht;
	ht->h_prev = NULL;
	ht->h_used = 0;
	ht->h_tobe = 0;
	ht->h_state = 0;
	Freeht = ht;
}

void
htlists(void)
{
	Htablep ht3;
	eprint("   Here's the Freeht list:");
	for(ht3=Freeht;ht3!=NULL;ht3=ht3->h_next)eprint("(%lld,sz%d,u%d,t%d)",(intptr_t)ht3,ht3->size,ht3->h_used,ht3->h_tobe);
	eprint("\n");
	eprint("   Here's the Htobechecked list:");
	for(ht3=Htobechecked;ht3!=NULL;ht3=ht3->h_next)eprint("(%lld,sz%d,u%d,t%d)",(intptr_t)ht3,ht3->size,ht3->h_used,ht3->h_tobe);
	eprint("\n");
	eprint("   Here's the Topht list:");
	for(ht3=Topht;ht3!=NULL;ht3=ht3->h_next)eprint("(%lld,sz%d,u%d,t%d)",(intptr_t)ht3,ht3->size,ht3->h_used,ht3->h_tobe);
	eprint("\n");
}

/*
 * String interning table — uses dedicated Strnode instead of Hnode.
 * Supports incremental tri-color mark-and-sweep garbage collection.
 */

static Strtable *Strtab = NULL;

/* Strnode pool allocator, following the newhn/freehn pattern */
#define ALLOCSN 128
static Strnodep Free_sn = NULL;

static Strnodep
newsn(void)
{
	static Strnodep lastsn;
	static int used = ALLOCSN;
	Strnodep sn;

	if ( Free_sn != NULL ) {
		sn = Free_sn;
		Free_sn = Free_sn->next;
		goto getout;
	}
	if ( used == ALLOCSN ) {
		used = 0;
		lastsn = (Strnodep) kmalloc(ALLOCSN*sizeof(Strnode),"newsn");
	}
	used++;
	sn = lastsn++;

    getout:
	sn->next = NULL;
	sn->str = NULL;
	sn->gc_color = GC_WHITE;
	return sn;
}

static void
freesn(Strnodep sn)
{
	sn->next = Free_sn;
	Free_sn = sn;
}

static Strtable *
new_strtable(int size)
{
	Strtable *st = (Strtable *) kmalloc(sizeof(Strtable),"new_strtable");
	st->size = size;
	st->count = 0;
	st->buckets = (Strnodep *) kmalloc(size*sizeof(Strnodep),"strtable_buckets");
	memset(st->buckets, 0, size*sizeof(Strnodep));
	return st;
}

/* Compute hash value of a string (same algorithm as the old uniqstr) */
static int
strhash(char *s, int tablesize)
{
	register unsigned int t = 0;
	register int c;
	register char *p = s;

	while ( (c=(*p++)) != '\0' ) {
		t += c;
		t <<= 3;
	}
	return t % tablesize;
}

/* Look up a Symstr pointer in the string table by pointer identity */
static Strnodep
strtable_find_ptr(Symstr s)
{
	int v;
	Strnodep sn;

	if ( Strtab == NULL || s == NULL )
		return NULL;
	v = strhash(s, Strtab->size);
	for ( sn = Strtab->buckets[v]; sn != NULL; sn = sn->next ) {
		if ( sn->str == s )
			return sn;
	}
	return NULL;
}

/* ---- String GC state ---- */

int Strgc_state = STRGC_IDLE;
static int Strgc_allocs = 0;
static int Strgc_threshold = 5000;
static int Strgc_work = 100;

/* Mark phase cursor */
static int Strgc_mark_group = 0;	/* which root group we're scanning */
static int Strgc_mark_pos = 0;		/* position within current root group */

/* For scanning hash tables incrementally */
static Htablep Strgc_mark_ht = NULL;	/* current hash table being scanned */
static int Strgc_mark_bucket = 0;	/* current bucket in that table */
static Hnodep Strgc_mark_hn = NULL;	/* current hnode in that bucket */

/* For scanning task stacks incrementally */
static Ktaskp Strgc_mark_task = NULL;
static int Strgc_mark_stackpos = 0;

/* Sweep phase cursor */
static int Strgc_sweep_bucket = 0;

/* Gray list for nested arrays discovered during marking */
typedef struct GrayEntry {
	Htablep ht;
	int bucket;
	Hnodep hn;
	struct GrayEntry *next;
} GrayEntry;

static GrayEntry *Gray_list = NULL;
static GrayEntry *Free_gray = NULL;

static GrayEntry *
new_gray(void)
{
	GrayEntry *g;
	if ( Free_gray != NULL ) {
		g = Free_gray;
		Free_gray = Free_gray->next;
	} else {
		g = (GrayEntry *) kmalloc(sizeof(GrayEntry),"new_gray");
	}
	g->next = NULL;
	return g;
}

static void
free_gray(GrayEntry *g)
{
	g->next = Free_gray;
	Free_gray = g;
}

/* Forward declarations for GC mark helpers */
static void strgc_mark_str(Symstr s);
static void strgc_mark_datum(Datum d);
static void strgc_push_ht(Htablep ht);
static int strgc_drain_gray(int budget);
static int strgc_mark_ht_partial(Htablep ht, int *bucket, Hnodep *hn, int budget);
static void strgc_mark_phrase_notes(Phrasep ph);

Symstr
uniqstr(char *s)
{
	Strnodep *table;
	Strnodep h, toph;
	int v;

	if ( Strtab == NULL ) {
		char *p = getenv("STRHASHSIZE");
		char *g = getenv("STRGCTHRESHOLD");
		char *w = getenv("STRGCWORK");
		Strtab = new_strtable( p ? atoi(p) : 1009 );
		if (g) Strgc_threshold = atoi(g);
		if (w) Strgc_work = atoi(w);
	}

	v = strhash(s, Strtab->size);

	table = Strtab->buckets;
	toph = table[v];
	if ( toph == NULL ) {
		/* no collision */
		h = newsn();
		h->str = kmalloc((unsigned)strlen(s)+1,"uniqstr");
		strcpy((char*)(h->str),s);
		Strtab->count++;
		Strgc_allocs++;
	}
	else {
		Strnodep prev;

		/* quick test for first node in list, most common case */
		if ( strcmp(toph->str,s) == 0  ) {
			if ( Strgc_state != STRGC_IDLE )
				toph->gc_color = GC_BLACK;
			return(toph->str);
		}

		/* Look through entire list */
		h = toph;
		for ( prev=h; (h=h->next) != NULL; prev=h ) {
			if ( strcmp(h->str,s) == 0 )
				break;
		}
		if ( h == NULL ) {
			/* string wasn't found, add it */
			h = newsn();
			h->str = kmalloc((unsigned)strlen(s)+1,"uniqstr");
			strcpy((char*)(h->str),s);
			Strtab->count++;
			Strgc_allocs++;
		}
		else {
			/* Symstr found.  Delete it from its current */
			/* position so we can move it to the top. */
			prev->next = h->next;
		}
	}
	/* Whether we've just allocated a new node, or whether we've */
	/* found the node somewhere in the list, we insert it at the */
	/* top of the list.  Ie. the lists are constantly re-arranging */
	/* themselves to put the most recently seen entries on top. */
	h->next = toph;
	table[v] = h;
	/* Write barrier: mark any string touched during active GC as live */
	if ( Strgc_state != STRGC_IDLE )
		h->gc_color = GC_BLACK;
	return(h->str);
}

/* ---- String GC: mark helpers ---- */

static void
strgc_mark_str(Symstr s)
{
	Strnodep sn;

	if ( s == NULL )
		return;
	sn = strtable_find_ptr(s);
	if ( sn != NULL && sn->gc_color == GC_WHITE )
		sn->gc_color = GC_BLACK;
}

static void
strgc_mark_datum(Datum d)
{
	switch ( d.type ) {
	case D_STR:
		strgc_mark_str(d.u.str);
		break;
	case D_ARR:
		if ( d.u.arr != NULL )
			strgc_push_ht(d.u.arr);
		break;
	case D_PHR:
		if ( d.u.phr != NULL )
			strgc_mark_phrase_notes(d.u.phr);
		break;
	case D_SYM:
		/* Follow symbol to mark its name and value */
		if ( d.u.sym != NULL ) {
			strgc_mark_datum(d.u.sym->name);
			strgc_mark_datum(d.u.sym->sd);
		}
		break;
	case D_OBJ:
		/* Object has a symbol table */
		if ( d.u.obj != NULL && d.u.obj->symbols != NULL )
			strgc_push_ht(d.u.obj->symbols);
		break;
	}
}

static void
strgc_mark_phrase_notes(Phrasep ph)
{
#ifdef NTATTRIB
	Noteptr n;
	for ( n = ph->p_notes; n != NULL; n = n->next ) {
		if ( n->attrib != NULL )
			strgc_mark_str(n->attrib);
	}
#endif
}

static void
strgc_push_ht(Htablep ht)
{
	GrayEntry *g;

	if ( ht == NULL )
		return;
	/* Avoid duplicates by checking if this ht is already in the gray list */
	for ( g = Gray_list; g != NULL; g = g->next ) {
		if ( g->ht == ht )
			return;
	}
	g = new_gray();
	g->ht = ht;
	g->bucket = 0;
	g->hn = NULL;
	g->next = Gray_list;
	Gray_list = g;
}

/* Scan part of a hash table, marking string Datums in key and val.
 * Returns the number of work units consumed. */
static int
strgc_mark_ht_partial(Htablep ht, int *bucket, Hnodep *hn, int budget)
{
	int work = 0;

	while ( work < budget && *bucket < ht->size ) {
		if ( *hn == NULL )
			*hn = ht->nodetable[*bucket];
		while ( *hn != NULL && work < budget ) {
			strgc_mark_datum((*hn)->key);
			strgc_mark_datum((*hn)->val);
			*hn = (*hn)->next;
			work++;
		}
		if ( *hn == NULL )
			(*bucket)++;
	}
	return work;
}

/* Drain gray list entries, return work consumed */
static int
strgc_drain_gray(int budget)
{
	int work = 0;

	while ( Gray_list != NULL && work < budget ) {
		GrayEntry *g = Gray_list;
		int remaining = budget - work;

		work += strgc_mark_ht_partial(g->ht, &g->bucket, &g->hn, remaining);

		if ( g->bucket >= g->ht->size ) {
			/* Done with this table */
			Gray_list = g->next;
			free_gray(g);
		}
	}
	return work;
}

/* ---- String GC: mark step (incremental root walk) ---- */

/* Externs needed for root scanning that are not in key.h */
extern Fifo *Topfifo;
extern Htablep Fifotable;
extern Lknode *Toplk;

static void
strgc_mark_step(void)
{
	int budget = Strgc_work;
	int work;

	/* Always drain gray list first */
	work = strgc_drain_gray(budget);
	if ( work >= budget )
		return;
	budget -= work;

	while ( budget > 0 ) {
		switch ( Strgc_mark_group ) {

		case 0: {
			/* Built-in Str_* Datums and Nullstr */
			extern Datum Str_x0, Str_y0, Str_x1, Str_y1;
			extern Datum Str_x, Str_y, Str_button;
			extern Datum Str_type, Str_mouse, Str_drag;
			extern Datum Str_move, Str_up, Str_down;
			extern Datum Str_highest, Str_lowest;
			extern Datum Str_earliest, Str_latest, Str_modifier;
			extern Datum Str_default, Str_w, Str_r, Str_init;
			extern Datum Str_get, Str_set, Str_newline;
			extern Datum Str_red, Str_green, Str_blue;
			extern Datum Str_grey, Str_surface;
			extern Datum Str_finger, Str_hand;
			extern Datum Str_xvel, Str_yvel;
			extern Datum Str_proximity, Str_orientation;
			extern Datum Str_eccentricity;
			extern Datum Str_width, Str_height;
			extern char *Nullstr;
			extern char *Defatt;

			Datum *builtins[] = {
				&Str_x0, &Str_y0, &Str_x1, &Str_y1,
				&Str_x, &Str_y, &Str_button,
				&Str_type, &Str_mouse, &Str_drag,
				&Str_move, &Str_up, &Str_down,
				&Str_highest, &Str_lowest,
				&Str_earliest, &Str_latest, &Str_modifier,
				&Str_default, &Str_w, &Str_r, &Str_init,
				&Str_get, &Str_set, &Str_newline,
				&Str_red, &Str_green, &Str_blue,
				&Str_grey, &Str_surface,
				&Str_finger, &Str_hand,
				&Str_xvel, &Str_yvel,
				&Str_proximity, &Str_orientation,
				&Str_eccentricity,
				&Str_width, &Str_height
			};
			int nbuiltins = sizeof(builtins)/sizeof(builtins[0]);
			int i;

			for ( i = 0; i < nbuiltins; i++ )
				strgc_mark_datum(*builtins[i]);
#ifdef MDEP_OSC_SUPPORT
			{
				extern Datum Str_elements, Str_seconds, Str_fraction;
				strgc_mark_datum(Str_elements);
				strgc_mark_datum(Str_seconds);
				strgc_mark_datum(Str_fraction);
			}
#endif
			strgc_mark_str(Nullstr);
			strgc_mark_str(Defatt);
			budget--;
			Strgc_mark_group++;
			Strgc_mark_pos = 0;
			break;
		}

		case 1:
			/* Keywords hash table */
			if ( Keywords != NULL ) {
				Strgc_mark_ht = Keywords;
				Strgc_mark_bucket = 0;
				Strgc_mark_hn = NULL;
				work = strgc_mark_ht_partial(Strgc_mark_ht,
					&Strgc_mark_bucket, &Strgc_mark_hn, budget);
				budget -= work;
				if ( Strgc_mark_bucket < Keywords->size )
					return; /* not done yet */
			}
			Strgc_mark_group++;
			break;

		case 2:
			/* Macros hash table */
			if ( Macros != NULL ) {
				Strgc_mark_ht = Macros;
				Strgc_mark_bucket = 0;
				Strgc_mark_hn = NULL;
				work = strgc_mark_ht_partial(Strgc_mark_ht,
					&Strgc_mark_bucket, &Strgc_mark_hn, budget);
				budget -= work;
				if ( Strgc_mark_bucket < Macros->size )
					return;
			}
			Strgc_mark_group++;
			Strgc_mark_ht = Topht;
			Strgc_mark_bucket = 0;
			Strgc_mark_hn = NULL;
			break;

		case 3:
			/* All active hash tables via Topht linked list */
			while ( Strgc_mark_ht != NULL && budget > 0 ) {
				work = strgc_mark_ht_partial(Strgc_mark_ht,
					&Strgc_mark_bucket, &Strgc_mark_hn, budget);
				budget -= work;
				if ( Strgc_mark_bucket >= Strgc_mark_ht->size ) {
					Strgc_mark_ht = Strgc_mark_ht->h_next;
					Strgc_mark_bucket = 0;
					Strgc_mark_hn = NULL;
				} else {
					return; /* not done with this table */
				}
			}
			if ( Strgc_mark_ht == NULL ) {
				Strgc_mark_group++;
				/* Set up for task scanning */
				{
					extern Ktaskp strgc_get_toptp(void);
					Strgc_mark_task = strgc_get_toptp();
				}
				Strgc_mark_stackpos = 0;
			}
			break;

		case 4: {
			/* All tasks: scan stacks, filename, method, etc. */
			while ( Strgc_mark_task != NULL && budget > 0 ) {
				Ktaskp t = Strgc_mark_task;
				int stksize;
				int i;

				strgc_mark_str(t->filename);
				strgc_mark_str(t->method);
				strgc_mark_str(t->ontaskerrormsg);
				budget--;

				/* Scan task stack */
				stksize = (int)(t->stackp - t->stack);
				for ( i = Strgc_mark_stackpos; i < stksize && budget > 0; i++ ) {
					strgc_mark_datum(t->stack[i]);
					budget--;
				}
				if ( i < stksize ) {
					Strgc_mark_stackpos = i;
					return; /* not done with this task's stack */
				}

				/* Scan onexitargs and ontaskerrorargs */
				{
					Dnode *dn;
					for ( dn = t->onexitargs; dn != NULL; dn = dn->next ) {
						strgc_mark_datum(dn->d);
						budget--;
					}
					for ( dn = t->ontaskerrorargs; dn != NULL; dn = dn->next ) {
						strgc_mark_datum(dn->d);
						budget--;
					}
				}

				Strgc_mark_task = t->nxt;
				Strgc_mark_stackpos = 0;
			}
			if ( Strgc_mark_task == NULL )
				Strgc_mark_group++;
			break;
		}

		case 5: {
			/* Phrases: walk Topph and Tobechecked for NTATTRIB strings */
			extern Phrasep Topph;
			extern Phrasep Tobechecked;
			/* We do all phrases in one go since attrib scanning is fast */
			Phrasep p;
			for ( p = Topph; p != NULL; p = p->p_next ) {
				strgc_mark_phrase_notes(p);
				budget--;
			}
			for ( p = Tobechecked; p != NULL; p = p->p_next ) {
				strgc_mark_phrase_notes(p);
				budget--;
			}
			Strgc_mark_group++;
			break;
		}

		case 6: {
			/* Objects: each object's symbol table */
			extern Kobjectp Topobj;
			Kobjectp o;
			for ( o = Topobj; o != NULL; o = o->onext ) {
				if ( o->symbols != NULL )
					strgc_push_ht(o->symbols);
				budget--;
			}
			Strgc_mark_group++;
			break;
		}

		case 7: {
			/* Locks: mark name strings */
			Lknode *lk;
			for ( lk = Toplk; lk != NULL; lk = lk->next ) {
				strgc_mark_str(lk->name);
				budget--;
			}
			Strgc_mark_group++;
			break;
		}

		case 8: {
			/* FIFOs: walk Fifodata chains */
			Fifo *f;
			for ( f = Topfifo; f != NULL; f = f->next ) {
				Fifodata *fd;
				for ( fd = f->head; fd != NULL; fd = fd->next ) {
					strgc_mark_datum(fd->d);
					budget--;
				}
			}
			Strgc_mark_group++;
			break;
		}

		case 9: {
			/* Context chain */
			Context *ct;
			for ( ct = Topct; ct != NULL; ct = ct->next ) {
				if ( ct->symbols != NULL )
					strgc_push_ht(ct->symbols);
				budget--;
			}
			Strgc_mark_group++;
			break;
		}

		case 10:
			/* Special tables: Tasktable, Fifotable, Windhash */
			{
				extern Htablep Windhash;
				if ( Tasktable != NULL )
					strgc_push_ht(Tasktable);
				if ( Fifotable != NULL )
					strgc_push_ht(Fifotable);
				if ( Windhash != NULL )
					strgc_push_ht(Windhash);
			}
			/* Keylibtable is static in main.c; provide accessor */
			{
				extern Htablep strgc_get_keylibtable(void);
				Htablep klt = strgc_get_keylibtable();
				if ( klt != NULL )
					strgc_push_ht(klt);
			}
			budget--;
			Strgc_mark_group++;
			break;

		case 11: {
			/* MIDI port names */
			int i;
			for ( i = 0; i < MIDI_IN_DEVICES; i++ )
				strgc_mark_str(Midiinputs[i].name);
			for ( i = 0; i < MIDI_OUT_DEVICES; i++ )
				strgc_mark_str(Midioutputs[i].name);
			budget--;
			Strgc_mark_group++;
			break;
		}

		case 12: {
			/* Htobechecked list */
			extern Htablep Htobechecked;
			Htablep h;
			for ( h = Htobechecked; h != NULL; h = h->h_next ) {
				strgc_push_ht(h);
				budget--;
			}
			Strgc_mark_group++;
			break;
		}

		case 13:
			/* Final drain of gray list */
			work = strgc_drain_gray(budget);
			budget -= work;
			if ( Gray_list != NULL )
				return; /* still draining */
			/* All roots scanned, transition to sweep */
			Strgc_state = STRGC_SWEEP;
			Strgc_sweep_bucket = 0;
			return;

		default:
			/* Should not reach here */
			Strgc_state = STRGC_SWEEP;
			Strgc_sweep_bucket = 0;
			return;
		}

		/* After completing a group, drain any gray entries that were added */
		work = strgc_drain_gray(budget);
		budget -= work;
	}
}

/* ---- String GC: MARK_INIT phase (reset colors) ---- */

static void
strgc_reset_colors(void)
{
	int budget = Strgc_work;
	int i;

	for ( i = Strgc_sweep_bucket; i < Strtab->size && budget > 0; i++ ) {
		Strnodep sn;
		for ( sn = Strtab->buckets[i]; sn != NULL; sn = sn->next )
			sn->gc_color = GC_WHITE;
		budget--;
	}
	Strgc_sweep_bucket = i;
	if ( i >= Strtab->size ) {
		Strgc_state = STRGC_MARK;
		Strgc_mark_group = 0;
		Strgc_mark_pos = 0;
		Strgc_mark_ht = NULL;
		Strgc_mark_bucket = 0;
		Strgc_mark_hn = NULL;
		Strgc_mark_task = NULL;
		Strgc_mark_stackpos = 0;
	}
}

/* ---- String GC: sweep phase ---- */

static int Strgc_freed = 0;	/* count of strings freed in current sweep */

static void
strgc_sweep_step(void)
{
	int budget = Strgc_work;

	while ( Strgc_sweep_bucket < Strtab->size && budget > 0 ) {
		Strnodep sn, prev, next;

		prev = NULL;
		for ( sn = Strtab->buckets[Strgc_sweep_bucket]; sn != NULL; sn = next ) {
			next = sn->next;
			if ( sn->gc_color == GC_WHITE ) {
				/* Unreachable — free it */
				if ( prev != NULL )
					prev->next = next;
				else
					Strtab->buckets[Strgc_sweep_bucket] = next;
				kfree(sn->str);
				freesn(sn);
				Strtab->count--;
				Strgc_freed++;
			} else {
				/* Reset for next cycle */
				sn->gc_color = GC_WHITE;
				prev = sn;
			}
		}
		Strgc_sweep_bucket++;
		budget--;
	}

	if ( Strgc_sweep_bucket >= Strtab->size ) {
		/* Sweep complete */
		Strgc_state = STRGC_IDLE;
		Strgc_allocs = 0;
if(*Debug>1){eprint("STRGC: sweep complete, freed %d strings\n",Strgc_freed);}
		Strgc_freed = 0;
	}
}

/* ---- String GC: public interface ---- */

void
strgc_step(void)
{
	switch ( Strgc_state ) {
	case STRGC_IDLE:
		if ( Strgc_allocs >= Strgc_threshold ) {
			Strgc_state = STRGC_MARK_INIT;
			Strgc_sweep_bucket = 0; /* reused as reset cursor */
			Strgc_freed = 0;
if(*Debug>1){eprint("STRGC: starting GC cycle, %d allocs\n",Strgc_allocs);}
		}
		break;
	case STRGC_MARK_INIT:
		strgc_reset_colors();
		break;
	case STRGC_MARK:
		strgc_mark_step();
		break;
	case STRGC_SWEEP:
		strgc_sweep_step();
		break;
	}
}

void
strgc_full(void)
{
	/* Force a full GC cycle if not already in progress */
	if ( Strtab == NULL )
		return;
	if ( Strgc_state == STRGC_IDLE ) {
		Strgc_state = STRGC_MARK_INIT;
		Strgc_sweep_bucket = 0;
	}
	while ( Strgc_state != STRGC_IDLE )
		strgc_step();
}

int
isundefd(Symbolp s)
{
	Datum d;

	if ( s->stype == UNDEF )
		return(1);
	d = *symdataptr(s);
	if ( isnoval(d) )
		return(1);
	else
		return(0);
}

/*
 * Look for an element in the hash table.
 * Values of 'action':
 *     H_INSERT ==> look for, and if not found, insert
 *     H_LOOK ==> look for, but don't insert
 *     H_DELETE ==> look for and delete
 */

Hnodep
hashtable(Htablep ht,Datum key,int action)
{
	Hnodepp table;
	Hnodep h, toph, prev;
	int v, nc;

	table = ht->nodetable;

	/* base the hash value on the 'uniqstr'ed pointer */
	switch ( key.type ) {
	case D_NUM:
		v = ((unsigned int)(key.u.val)) % (ht->size);
		break;
	case D_STR:
		v = ((intptr_t)(key.u.str)>>2) % (ht->size);
		break;
	case D_OBJ:
		v = ((unsigned int)(key.u.obj->id)>>2) % (ht->size);
		break;
	default:
		execerror("hashtable isn't prepared for that key.type");
		break;
	}

	/* look in hash table of existing elements */
	toph = table[v];
	if ( toph != NULL ) {

		/* collision */

		/* quick test for first node in list, most common case */
		if ( dcompare(key,toph->key) == 0 ) {
			if ( action != H_DELETE )
				return(toph);
			/* delete from list and free */
			table[v] = toph->next;
			freehn(toph);
			ht->count--;
			return(NULL);
		}

		/* Look through entire list */
		h = toph;
		nc = 0;
		for ( prev=h; ((h=h->next) != NULL); prev=h ) {
			nc++;
			if ( dcompare(key,h->key) == 0 ) {
				break;
			}
		}
		if ( h != NULL ) {
			/* Found.  Delete it from it's current */
			/* position so we can either move it to the top, */
			/* or leave it deleted. */
			prev->next = h->next;
			if ( action == H_DELETE ) {
				/* delete it */
				freehn(h);
				ht->count--;
				return(NULL);
			}
			/* move it to the top of the collision list */
			h->next = toph;
			table[v] = h;
			return(h);
		}
	}

	/* it wasn't found */
	if ( action == H_DELETE ) {
		return(NULL);
	}

	if ( action == H_LOOK )
		return(NULL);

	h = newhn();
	h->key = key;
	h->val = Noval;
	ht->count++;

	/* Add to top of collision list */
	h->next = toph;
	table[v] = h;

	return(h);
}

/*
 * Look for the symbol for a particular array element, given
 * a pointer to the main array symbol, and the subscript value.
 * Values of 'action':
 *     H_INSERT ==> look for symbol, and if not found, insert
 *     H_LOOK ==> look for symbol, don't insert
 *     H_DELETE ==> look for symbol and delete it
 */

Symbolp
arraysym(Htablep arr,Datum subs,int action)
{
	Symbolp s = NULL;
	Symbolp ns;
	Hnodep h;
	Datum key;

	if ( arr == NULL )
		execerror("Internal error: arr==0 in arraysym!?");

	key = dtoindex(subs);

	switch (action) {
	case H_LOOK:
		h = hashtable(arr,key,action);
		if ( h )
			s = h->val.u.sym;
		break;
	case H_INSERT:
		h = hashtable(arr,key,action);
		if ( isnoval(h->val) ) {
			/* New element, initialized to null string */
			ns = newsy();
			ns->name = key;
			ns->stype = VAR;
			*symdataptr(ns) = strdatum(Nullstr);
			h->val = symdatum(ns);
		}
		s = h->val.u.sym;
		break;
	case H_DELETE:
		(void) hashtable(arr,key,action);
		break;
	default:
		execerror("Internal error: bad action in arraysym!?");
	}
	return(s);
}

int
arrsize(Htablep arr)
{
	return arr->count;
}

int
dtcmp(Datum *d1,Datum *d2)
{
	return dcompare(*d1,*d2);
}

static int elsize;	/* element size */
static INTFUNC2P qscompare;

/*
 * Quick Sort routine.
 * Code by Duane Morse (...!noao!terak!anasazi!duane)
 * Based on Knuth's ART OF COMPUTER PROGRAMMING, VOL III, pp 114-117.
 */

/* Exchange the contents of two vectors.  n is the size of vectors in bytes. */
static void
memexch(register unsigned char *s1,register unsigned char *s2,register int n)
{
	register unsigned char c;
	while (n--) {
		c = *s1;
		*s1++ = *s2;
		*s2++ = c;
	}
}

static void
mysort(unsigned char *vec,int nel)
{
	register short i, j;
	register unsigned char *iptr, *jptr, *kptr;

begin:
	if (nel == 2) {	/* If 2 items, check them by hand. */
		if ((*qscompare)(vec, vec + elsize) > 0)
			memexch(vec, vec + elsize, elsize);
		return;
	}
	j = (short) nel;
	i = 0;
	kptr = vec;
	iptr = vec;
	jptr = vec + elsize * nel;
	while (--j > i) {

		/* From the righthand side, find first value */
		/* that should be to the left of k. */
		jptr -= elsize;
		if ((*qscompare)(jptr, kptr) > 0)
			continue;

		/* Now from the lefthand side, find first value */
		/* that should be to right of k. */

		iptr += elsize;
		while(++i < j && (*qscompare)(iptr, kptr) <= 0)
			iptr += elsize;

		if (i >= j)
			break;

		/* Exchange the two items; k will eventually end up between them. */
		memexch(jptr, iptr, elsize);
	}
	/* Move item 0 into position.  */
	memexch(vec, iptr, elsize);
	/* Now sort the two partitions. */
	if ((nel -= (i + 1)) > 1)
		mysort(iptr + elsize, nel);

	/* To save a little time, just start the routine over by hand. */
	if (i > 1) {
		nel = i;
		goto begin;
	}
}

static void
pqsort(unsigned char *vec,int nel,int esize,INTFUNC2P compptr)
{
	if (nel < 2)
		return;
	elsize = esize;
	qscompare = compptr;
	mysort(vec, nel);
}

/* Return a Noval-terminated list of the index values of an array.  */
Datum *
arrlist(Htablep arr,int *asize,int sortit)
{
	register Hnodepp pp;
	register Hnodep h;
	register Datum *lp;
	register int hsize;
	Datum *list;

	pp = arr->nodetable;
	hsize = arr->size;
	*asize = arrsize(arr);
	list = (Datum *) kmalloc((*asize+1)*sizeof(Datum),"arrlist");

	lp = list;
	/* visit each slot in the hash table */
	while ( hsize-- > 0 ) {
		/* and traverse its list */
		for ( h=(*pp++); h!=NULL; h=h->next ) {
			*lp++ = h->val.u.sym->name;
		}
	}
	*lp++ = Noval;
	if ( sortit )
		pqsort((unsigned char *)list,*asize,(int)sizeof(Datum),(INTFUNC2P)dtcmp);
	return(list);
}

void
hashvisit(Htablep arr,HNODEFUNC f)
{
	register Hnodepp pp;
	register Hnodep h;
	register int hsize;

	pp = arr->nodetable;
	hsize = arr->size;
	/* visit each slot in the hash table */
	while ( hsize-- > 0 ) {
		/* and traverse its list */
		for ( h=(*pp++); h!=NULL; h=h->next ) {
			if ( (*f)(h) )
				return;	/* used to be break, apparent mistake */
		}
	}
}

