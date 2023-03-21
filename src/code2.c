/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#define OVERLAY5

#include "key.h"
#include "gram.h"

void
i_popignore(void)
{
	Datum d;

	/* Be forgiving if there's nothing on the stack */
	if ( Stackp == Stack )
		execerror("Nothing on stack in popignore() !?");
	popinto(d);

#ifdef THIS_TICKLES_A_BUG_SO_LETS_DO_WITHOUT_THE_WARNING
	/* In rare cases I've seen the value of d.u.codep be equal to 1, */
	/* which causes a core dump, so let's get rid of the check. */

	if ( d.type == D_CODEP ) {
		/* Warn only for built-in functions - this will catch */
		/* occasions when people use printf and fprintf without parens. */
		if ( *Isofuncwarn != 0 && BLTINOF(d.u.codep) != 0 ) {
			char *p = ipfuncname(d.u.codep);
			eprint("Isolated function value (%s) detected - did you forget parenthesis!?\n",p==NULL ? "???" : p );
		}
	}
#endif

#ifdef OLDSTUFF
	if ( d.type == D_CODEP && d.u.func == Printfuncd->u.func )
		execerror("'print' now requires parenthesis around its arguments!");
#endif
}

void
i_defined(void)
{
	register Symbolp s;
	Datum d;

	s = use_symcode();
	d = numdatum( ( isundefd(s) ) ? 0L : 1L );
	pushm(d);
}

void
i_objdefined(void)
{
	Kobjectp o, fo;
	Symstr p;
	Datum d;
	long v;

	popinto(d);
	if ( d.type != D_STR )
		execerror("object expression expects a string, but got %s!\n",atypestr(d.type));
	p = d.u.str;
	popinto(d);
	if ( d.type != D_OBJ )
		execerror("expression expects an object, but got %s!\n",atypestr(d.type));
	o = d.u.obj;
	if ( findobjsym(p,o,&fo) != NULL )
		v = 1;
	else
		v = 0;
	pushexp(numdatum(v));
}

void
i_currobjdefined(void)
{
	long v;

	if ( T->obj )
		v = (T->obj->id >= 0);
	else
		v = 0;
	pushexp(numdatum(v));
}

void
i_realobjdefined(void)
{
	long v;

	if ( T->realobj )
		v = (T->realobj->id >= 0);
	else
		v = 0;
	pushexp(numdatum(v));
}

void
i_task(void)
{
	int npassed;
	long newtid;
	Ktaskp saveT;
	Datum *sp;
	Symbolp s;
	Datum d;

	peekinto(d);
	npassed = (int)numval(d);

	s = use_symcode();

	/* start up a task to call it */
	saveT = T;
	T = newtask(Ipop);
	newtid = T->tid;

	/* Move the function value and arguments from the stack of the */
	/* calling task to the stack of the new task. */

	/* Make sure there's enough room for all args to be moved */
	/* The +1 is for the npassed value. */
	while ( (T->stackp + npassed + PREARGSIZE + 1) >= T->stackend )
		expandstack(T);
	/* Move them over, no reference counting change needed. */
	/* The -1 is for the npassed value. */
	sp = (saveT->stackp) - npassed - PREARGSIZE - 1;
	while ( sp < saveT->stackp )
		*(T->stackp++) = (*sp++);
	callfuncd(s);

	T = saveT;
	/* make sure we pop off the stuff we moved */
	/* The +1 is for the npassed value. */
	T->stackp -= npassed+PREARGSIZE+1;

	pushexp(numdatum(newtid));
}

void
undefsym(Symbolp s)
{
	clearsym(s);
	s->stype = UNDEF;
	*symdataptr(s) = Noval;
}

void
i_undefine(void)
{
	Symbolp s = use_symcode();
	undefsym(s);
}

Phrasep
phresh(Phrasep p)
{
	if ( phreallyused(p) > 0 ) {
		Phrasep ph = newph(0);
		phcopy(ph,p);
		p = ph;
	}
	return p;
}

Datum
dphresh(Datum d)
{
	if ( d.type==D_PHR ) 
		d.u.phr = phresh(d.u.phr);
	return(d);
}

long
doop(register long oldv,register long v,register int type)
{
	switch(type){
	case '=': oldv = v; break;
	case '+': oldv += v; break;
	case '-': oldv -= v; break;
	case '*': oldv *= v; break;
	case '/': if ( v == 0)
			execerror("division by zero");
		  oldv /= v;
		  break;
	case '^': oldv ^= v; break;
	case '&': oldv &= v; break;
	case '|': oldv |= v; break;
	}
	return(oldv);
}

#ifdef OLDSTUFF
void
chknoval(Datum d,char *s)
{
	if ( isnoval(d) )
		execerror("Uninitialized value (Noval) can't be handled by %s",s);
}
#endif

Datum
datumdoop(Datum od,Datum nd,int op)
{
	Datum r;

	if ( op == '=' )
		return(nd);

	switch(op){
	case '+': r = dadd(od,nd); break;
	case '-': r = dsub(od,nd); break;
	case '*': r = dmul(od,nd); break;
	case '/': r = ddiv(od,nd); break;
	case '|': r = dpar(od,nd); break;
	case '&': r = damp(od,nd); break;
	case '^': r = dxor(od,nd); break;
	case '>': r = drightshift(od,nd); break;
	case '<': r = dlshift(od,nd); break;
	default:  execerror("Unknown operator?");
	}
	return(r);
}

Datum
dmodulo(Datum d1,Datum d2)
{
	CHKNOVAL(d1,"modulo operation");
	CHKNOVAL(d2,"modulo operation");
	if ( d1.type == D_PHR && d2.type == D_NUM ) {
		register Noteptr n = picknt(d1.u.phr,(int)numval(d2));
		d1.u.phr = newph(0);
		if ( n != NULL ) {
			n = ntcopy(n);
			ntinsert(n,d1.u.phr);
			d1.u.phr->p_leng = endof(n);
		}
	}
	else {
		long n2 = numval(d2);
		if ( n2 == 0 )
			execerror("modulo operator doesn't work on 0!");
		d1 = numdatum ( (long) (numval(d1) % n2) );
	}
	return(d1);
}

void
i_dot(void)
{
	Datum d, r;
	register int dottype;

	/* The dot type (LENGTH, PITCH, etc.) is the next instruction */
	dottype = (int)use_numcode();
	popinto(d);

	if ( d.type != D_PHR ) {
		execerror("dot expression expects a phrase, but got %s",
			atypestr(d.type));
	}
	r = phdotvalue(d.u.phr, dottype);
	pushm(r);
}

void
i_modulo(void)
{
	Datum d1, d2;

	popinto(d2);
	popinto(d1);
	pushexp(dmodulo(d1,d2));
}

Symstr
addstr(Symstr s1,Symstr s2)
{
	char s[64];
	int need;
	Symstr p;

	need = (long)strlen(s1)+(long)strlen(s2)+1;
	/* avoid expensive kmalloc if we can use small buffer */
	if ( need > (int)sizeof(s) ) {
		Symstr snew;
		snew = (Symstr) kmalloc((unsigned)need,"addstr");
		strcpy(snew,(char*)s1);
		strcat(snew,(char*)s2);
		p = uniqstr((char*)snew);
		kfree(snew);
	}
	else {
		strcpy(s,s1);
		strcat(s,s2);
		p = uniqstr(s);
	}
	return p;
}

Datum
dadd(Datum d1,Datum d2)
{
	CHKNOVAL(d1,"'+' operation");
	CHKNOVAL(d2,"'+' operation");
	if ( d2.type == D_NUM && d1.type == D_NUM )
		d1.u.val += d2.u.val;
	else if ( d2.type == D_STR && d1.type == D_STR )
		d1.u.str = addstr(d1.u.str,d2.u.str);
	else if ( d2.type == D_PHR && d1.type == D_PHR ) {
		/* Make sure we can mess with the phrase in d1 */
		d1 = dphresh(d1);
		phrmerge( d2.u.phr, d1.u.phr, d1.u.phr->p_leng );
		d1.u.phr->p_leng += d2.u.phr->p_leng;
	}
	else if ( numtype(d2) == D_DBL || numtype(d1) == D_DBL )
		d1 = dbldatum( dblval(d1) + dblval(d2) );
	else
		d1 = numdatum( numval(d1) + numval(d2) );
	return(d1);
}

void
i_addcode(void)
{
	Datum d1, d2;

	popinto(d2);
	popinto(d1);
	pushexp(dadd(d1,d2));
}

/* phrop - compute 'p1-p2' or 'p1&p2', ie. the result is all notes from p1 */
/* that match (for '&') or don't match (for '-') notes in p2.  The notes */
/* are compared exactly.  This routine assumes p1 and p2 are already sorted, */
/* at least by ntcmporder(). */
Phrasep
phrop(Phrasep p1,int op,Phrasep p2)
{
	Noteptr n1 = firstnote(p1);
	Noteptr n2 = firstnote(p2);
	Phrasep p = newph(0);
	int cmp;

	p->p_leng = p1->p_leng;
	while ( n1!=NULL &&  n2!=NULL ) {

		chkrealoften();	/* so long phrases don't affect realtime */

		/* When we compare NT_BYTES whose time is the same, we can't */
		/* depend on the order that they're in, because ntcmporder() */
		/* (the function used for ordering phrases) doesn't sort */
		/* NT_BYTES notes (this is necessary, e.g., to retain system */
		/* exclusives and other things in their original order. */
		/* So, we have to take some pains to do this. */

		if ( timeof(n1)==timeof(n2)
			&& ntisbytes(n1) && ntisbytes(n2) ) {

			Noteptr n1a = n1;
			Noteptr n1b = nextnote(n1);
			Noteptr n2a = n2;
			Noteptr n2b = nextnote(n2);
			Noteptr nx, ny;
			int n2size=1;
			int i;
			Symstr n2flags;

			/* find the end of the regions which have such notes */
			while ( n1b!=NULL && timeof(n1b)==timeof(n2a)
				&& ntisbytes(n1b) ) {
				n1b = nextnote(n1b);
			}
			while ( n2b!=NULL && timeof(n2b)==timeof(n1a)
				&& ntisbytes(n2b) ) {
				n2b = nextnote(n2b);
				n2size++;
			}

			/* an array of flags, that we use to eliminate from */
			/* consideration the notes of the n2 region after */
			/* they've been 'used'. */
			n2flags = (Symstr) kmalloc((unsigned)n2size,"phrop");
			for ( i=0; i<n2size; i++ )
				n2flags[i] = 0;

			/* Now, just do a dumb search. */
			for ( nx=n1a; nx!=n1b; nx=nextnote(nx) ) {
				int found = 0;
				for ( i=0,ny=n2a; ny!=n2b; i++,ny=nextnote(ny) ) {
					if (n2flags[i]==0 && ntcmpxact(nx,ny)==0){
						/* note ny should not be */
						/* considered in future seaches */
						n2flags[i] = 1;
						found = 1;
						break;
					}
				}
				if ( (found==1 && op=='&')
					|| (found==0 && op=='-') ) {
					ntinsert(ntcopy(nx),p);
				}
			}
			kfree(n2flags);
			/* now advance both phrases past this section */
			n1 = n1b;
			n2 = n2b;
			continue;
		}

		cmp = ntcmpxact(n1,n2);
		if ( cmp < 0 ) {
			if ( op == '-' )
				ntinsert(ntcopy(n1),p);
			n1 = nextnote(n1);
		}
		else if ( cmp > 0 )
			n2 = nextnote(n2);
		else {
			/* n1 and n2 are equal */
			if ( op == '&' )
				ntinsert(ntcopy(n1),p);
			n1 = nextnote(n1);
			n2 = nextnote(n2);
		}
	}
	if ( op == '-' ) {
		/* when p2 runs out of notes, add the rest of p1 to result */
		while ( n1 != NULL ) {
			ntinsert(ntcopy(n1),p);
			n1 = nextnote(n1);
			chkrealoften();
		}
	}
	return(p);
}

int
phrcmp(Phrasep p1,Phrasep p2)
{
	register Noteptr n1 = firstnote(p1);
	register Noteptr n2 = firstnote(p2);
	register int cmp;

	while ( n1!=NULL && n2!=NULL ) {
		cmp = ntcmpxact(n1,n2);
		if ( cmp != 0 )
			return cmp;
		n1 = nextnote(n1);
		n2 = nextnote(n2);
		
	}
	if ( n1 == NULL && n2 == NULL )
		return 0;
	if ( n1 == NULL )
		return -1;	/* first phrase shorter */
	else
		return 1;	/* first phrase longer */
}

Datum
dsub(Datum d1,Datum d2)
{
	CHKNOVAL(d1,"'-' operation");
	CHKNOVAL(d2,"'-' operation");
	if ( d1.type == D_NUM && d2.type == D_NUM )
		d1.u.val -= d2.u.val;
	else if ( d2.type == D_PHR && d1.type == D_PHR )
		d1.u.phr = phrop(d1.u.phr,'-',d2.u.phr);
	else if ( numtype(d2) == D_DBL || numtype(d1) == D_DBL )
		d1 = dbldatum( dblval(d1) - dblval(d2) );
	else
		d1 = numdatum( numval(d1) - numval(d2) );
	return(d1);
}

void
i_subcode(void)
{
	Datum d1, d2;

	popinto(d2);
	popinto(d1);
	pushexp(dsub(d1,d2));
}

Datum
dmul(Datum d1,Datum d2)
{
	CHKNOVAL(d1,"'*' operation");
	CHKNOVAL(d2,"'*' operation");
	if ( numtype(d1) == D_DBL || numtype(d2) == D_DBL )
		d1 = dbldatum( dblval(d1) * dblval(d2) );
	else
		d1 = numdatum( numval(d1) * numval(d2) );
	return(d1);
}

void
i_mulcode(void)
{
	Datum d1, d2;

	popinto(d2);
	popinto(d1);
	pushexp(dmul(d1,d2));
}

Datum
dxor(Datum d1,Datum d2)
{
	d1 = numdatum( numval(d1) ^ numval(d2) );
	return(d1);
}

void
i_xorcode(void)
{
	Datum d1, d2;

	popinto(d2);
	popinto(d1);
	pushexp(dxor(d1,d2));
}

Datum
ddiv(Datum d1,Datum d2)
{
	CHKNOVAL(d1,"'/' operation");
	CHKNOVAL(d2,"'/' operation");
	/* Phrases use '/' to combine in parallel */
	if ( d1.type == D_PHR && d2.type == D_PHR )
		execerror("Phrases cannot be combined with '/'.  Use '|'.");

	if ( numtype(d1) == D_DBL || numtype(d2) == D_DBL ) {
		double x2 = dblval(d2);
		if ( x2 == 0.0 )	/* ho ho */
			execerror("division by zero");
		d1 = dbldatum ( dblval(d1) /  x2 );
	}
	else {
		long n2 = numval(d2);
		if ( n2 == 0)
			execerror("division by zero");
		d1 = numdatum ( numval(d1) /  n2 );
	}
	return(d1);
}

Datum
dpar(Datum d1,Datum d2)
{
	CHKNOVAL(d1,"'|' operation");
	CHKNOVAL(d2,"'|' operation");
	/* Phrases use '|' to combine in parallel */
	if ( d1.type == D_PHR && d2.type == D_PHR ) {
		d1 = dphresh(d1);
		phrmerge( d2.u.phr, d1.u.phr, 0L);
		if ( d2.u.phr->p_leng >= d1.u.phr->p_leng )
			d1.u.phr->p_leng = d2.u.phr->p_leng;
		return(d1);
	}
	d1 = numdatum ( (long) (numval(d1) | numval(d2)) );
	return(d1);
}

Datum
damp(Datum d1,Datum d2)
{
	CHKNOVAL(d1,"'&' operation");
	CHKNOVAL(d2,"'&' operation");
	/* Phrases use '&' to do intersections */
	if ( d1.type == D_PHR && d2.type == D_PHR )
		d1.u.phr = phrop(d1.u.phr,'&',d2.u.phr);
	else
		d1 = numdatum( (long) (numval(d1) & numval(d2)) );
	return(d1);
}

/* Beware - multiple evaluation of argument! */
#define SANIVALUE(v) ((v)<0?0:((v)>127?127:(v)))

/* setval() does sanity checking on the values that you attempt */
/* to set, and silently fixes/ignores problems. */

void
setval(Noteptr n,int field,Datum nv)
{
	long v;

#ifdef NTATTRIB
	if ( field == ATTRIB ) {
		attribof(n) = dtostr(nv);
		return;
	}
#endif
	v = roundval(nv);
	if ( ntisbytes(n) ) {
		Unchar* b;

		/* Only the TIME, CHAN, and FLAGS can be set on MESS's */
		switch(field) {
		case TIME:
			timeof(n) = v;
			break;
		case FLAGS:
			flagsof(n) = (UINT16)v;
			break;
		case PORT:
			portof(n) = saniport(v);
			break;
		case CHAN:
			if ( --v < 0 )	/* user channel values are +1 */
				v = 0;
			b = ptrtobyte(n,0);
			/* sysex (0xf0) notes don't have a channel */
			if ( (*b & 0x80) != 0 && (*b & 0xf0) != 0xf0 ) {
				*b = (Unchar)((v) | (*b & 0xf0));
			}
			break;
		}
		return;
	}

	switch(field){
	case PITCH:
		pitchof(n) = (Unchar)SANIVALUE(v);	/* restrict to 0-127 */
		break;
	case PORT:
		portof(n) = saniport(v);
		break;
	case CHAN:
		v--;	/* user uses 1-16, but stored values are 0-15 */
		if ( v < 0 )
			v = 0;
		else if ( v > 15 )
			v = 15;
		setchanof(n) = (Unchar)v;
		break;
	case VOL:
		volof(n) = (Unchar)SANIVALUE(v);	/* restrict to 0-127 */
		break;
	case DUR:
		if ( v < 0 ) {
			/* warning("Negative duration value, set to 0",(char*)0); */
			v = 0;
		}
		if ( v > MAXDURATION ) {
			warning("Duration value is too large, has been clipped");
			v = MAXDURATION;
		}
		durof(n) = v;
		break;
	case TIME:
		/* value can be anything, including negative */
		timeof(n) = v;
		break;
	case FLAGS:
		flagsof(n) = (UINT16)v;
		break;
	case TYPE:
		if ( v==NT_NOTE || v==NT_ON || v==NT_OFF ) {
			typeof(n) = (char)v;
		}
		break;
	default:
		warning("Invalid field value to setval()!");
		break;
	}
}

Datum
ntassign(Noteptr n,int dottype,Datum v,int op)
{
	Datum nv;

	if ( ntdotvalue(n,dottype,&nv) ) {
		nv = datumdoop(nv,v,op);
		setval(n,dottype,nv);
	}
	else {
		nv = v;
	}
	return nv;
}

void
phrvarinit(Symbolp s)
{
	clearsym(s);
	s->stype = VAR;
	*symdataptr(s) = phrdatum( newph(1) );
}

#define ASSIGN 0
#define DOTASSIGN 1
#define MODDOTASSIGN 2
#define MODASSIGN 3

void
i_dotassign(void)
{
	int dottype = (int)use_numcode();
	assign(DOTASSIGN,dottype);
}

void
i_moddotassign(void)
{
	int dottype = (int)use_numcode();
	assign(MODDOTASSIGN,dottype);
}

void
i_modassign(void)
{
	assign(MODASSIGN,0);
}

void
i_varassign(void)
{
	assign(ASSIGN,0);
}

void
assign(int type, int dottype)
{
	Datum expr, symd, sd, result, preval;
	int op, n, usepreval=0;
	Symbolp s;
	Datum *sdp;
	Phrasep p;
	long sum, modval, val;
	Noteptr nt;
	int dontpush;

	op = (int)use_numcode();

	dontpush = (op & DONTPUSH);
	if ( dontpush )
		op &= (~DONTPUSH);

	if ( op == INC || op == DEC || op == POSTDEC || op == POSTINC ) {
		if ( type==MODDOTASSIGN || type==MODASSIGN ) {
			Datum d;
			popinto(d);
			modval = numval(d);
		}

		popinto(symd);
		if ( symd.type != D_SYM ) {
			execerror("Assignment (++/--) to non-variable symbol (%s)",
				datumstr(symd));
		}
		s = symd.u.sym;
		sdp = symdataptr(s);

		expr = numdatum(1L);

		switch(op){
		case POSTDEC:
			usepreval = 1;
			preval = *sdp;
			/*FALLTHRU*/
		case DEC:
			op = '-';
			break;

		case POSTINC:
			usepreval = 1;
			preval = *sdp;
			/*FALLTHRU*/
		case INC:
			op = '+';
			break;
		}
	}
	else {
		popinto(expr);
		if ( type==MODDOTASSIGN || type==MODASSIGN ) {
			Datum d;
			popinto(d);
			modval = numval(d);
		}
		popinto(symd);
		if ( symd.type != D_SYM ) {
			execerror("Assignment to non-variable symbol (type is %s, val=%ld)",
				atypestr(symd.type),symd.u.val);
		}
		s = symd.u.sym;
		sdp = symdataptr(s);
	}

	if ( (type==DOTASSIGN || type==MODDOTASSIGN) && sdp->type==D_OBJ )
		execerror("Invalid '.' expression for an object - probably using a reserved word!");

	/* Check for read-only vars */
	if ( (s->flags & S_READONLY) != 0 ) {
		if ( ! dontpush )
			pushm(Noval);
		execerror("Attempt to change read-only variable (%s)!",symname(s));
	}

	if ( (type==DOTASSIGN || type==MODDOTASSIGN) && sdp->type==D_OBJ )
		execerror("Hey, attempt to use '.' on an object - probably using a reserved word!");

	/* In assignments to phrase.length */
 	/* we make sure that the variable is initialized as a empty phrase. */
	if ( type==DOTASSIGN && dottype==LENGTH && sdp->type!=D_PHR )
		phrvarinit(s);

	sd = *sdp;

	/* The 'phrase.xxx', 'phrase%expr', and 'phrase%expr.xxx' only */
	/* work with (suprise) phrases */
	if ( type != ASSIGN && sd.type != D_PHR )
		execerror("Expecting a phrase variable!");

	switch(type){
	case ASSIGN:
		/* This is a normal variable assignment. */
		if ( op == '=' ) {
			result = expr;
			/* don't do a decruse(sd) !! */
			clearsym(s);
		}
		else {
			decruse(sd);
			result = datumdoop(sd,expr,op);
		}
		s->stype = VAR;
		*sdp = result;
		break;
	case DOTASSIGN:
		decruse(sd);
		if ( usepreval )
			preval = phdotvalue(sd.u.phr,dottype);

		/* if the symbol's data is used elsewhere, we */
		/* have to make a fresh copy. */
		if ( phreallyused(sd.u.phr) > 0 ) {
			p = newph(0);
			phcopy(p,sd.u.phr);
			sdp->u.phr = sd.u.phr = p;
		}

		if ( dottype == LENGTH ) {
			Datum v;
			v = numdatum( sd.u.phr->p_leng );
			v = datumdoop(v,expr,op);
			sd.u.phr->p_leng = roundval(v);
			result = numdatum( sd.u.phr->p_leng );
			break;
		}
		/* Do assign operation on each note of the phrase. */
		/* Since this is potentially expensive, we let realtime */
		/* stuff sneak in (via chkrealoften()). */
		sum = 0;
		for ( n=0,nt=firstnote(sd.u.phr); nt!=NULL; nt=nextnote(nt) ) {
			Datum dv;

			chkrealoften();
			dv = ntassign(nt,dottype,expr,op);
			if ( dv.type == D_NUM ) {
				val = numval(dv);
				if ( val >= 0 ) {
					sum += val;
					n++;
				}
			}
		}

		/* This expensive call to phreorder is probably overkill, */
		/* since we've only changed a single note.  NEEDS WORK!  */
		/* It would be easy if the phrases were doubly-linked. */
		phreorder(sd.u.phr,0L);

		/* The result is the average of the assigned values. */
		result = numdatum( n==0 ? 0L : (long)(sum / n) );
		break;

	case MODDOTASSIGN:
		decruse(sd);
		if ( dottype==LENGTH ) {
			sprintf(Msg1,"'%%' can't be combined with %s",dotstr(dottype));
			warning(Msg1);
			break;
		}
		/* if the symbol's data is used exactly once, then we */
		/* re-use it.  Otherwise we have to make a copy. */
		if ( phreallyused(sd.u.phr) > 0 ) {
			p = newph(0);
			phcopy(p,sd.u.phr);
			sdp->u.phr = sd.u.phr = p;
		}

		nt = picknt(sd.u.phr, (int)modval);
		if ( usepreval && nt != NULL ) {
			if ( ! ntdotvalue(nt,dottype,&preval) )
				preval = numdatum(0L);
		}
		if ( nt != NULL )
			result = ntassign(nt,dottype,expr,op);

		/* This call to phreorder is possible overkill, see above. */
		phreorder(sd.u.phr,0L);

		break;

	case MODASSIGN:
		decruse(sd);

	    {register Noteptr lnt, rnt;

		if ( sd.type!=D_PHR || expr.type!=D_PHR ) {
			execerror("Assignment with '%' only works on phrases!");
		}

		/* if the symbol's data is used exactly once, then we */
		/* re-use it.  Otherwise we have to make a copy. */
		if ( phreallyused(sd.u.phr) > 0 ) {
			p = newph(0);
			phcopy(p,sd.u.phr);
			sdp->u.phr = sd.u.phr = p;
		}

		lnt = picknt(sd.u.phr, (int)modval);
		rnt = picknt(expr.u.phr, PHRASEBASE);
		if ( lnt != NULL ) {
			/* If the phrase on the right side of the '=' is */
			/* empty, then we delete the assigned-to note */
			if ( rnt == NULL )
				ntdelete(sd.u.phr,lnt);
			else {
				pitchof(lnt) = (Unchar)doop((long)pitchof(lnt),
						(long)pitchof(rnt),op);
				volof(lnt) = (Unchar)doop((long)volof(lnt),
						(long)volof(rnt),op);
				setchanof(lnt) = (Unchar)doop((long)chanof(lnt),
						(long)chanof(rnt),op);
				durof(lnt) = doop((long)durof(lnt),
						(long)durof(rnt),op);
				flagsof(lnt) = (UINT16)doop((long)flagsof(lnt),
						(long)flagsof(rnt),op);

				/* NOTE: timeof(lnt) is left alone, */
				/* for more intuitive semantics. */
			}
		}
		/* This call to phreorder is possible overkill, see above. */
		phreorder(sd.u.phr,0L);
		result = expr;
	    }
		break;
	}
	sd = *sdp;
	incruse(sd);

	if ( ! dontpush ) {
		/* This originally was:   pushexp( usepreval ? preval : result ); */
		/* But the Zortech compiler seemed to have trouble with that. */
		if ( usepreval ) {
			pushm( preval );
		}
		else {
			pushm( result );
		}
	}

	if ( s->onchange ) {
		taskfunc0(s->onchange);
	}
}

void
fakeval(void)
{
	code(funcinst(I_CONSTANT));
	code(numinst(Noval.u.val));
}

void
recodeassign(Instnodep varinode,Instnodep eqinode)
{
	Instnodep in, prein, tin;
	int eqtype, isdot=0, ismod=0, isarr=0, dottype;
	Instcode cd;

	eqtype = (int) (eqinode->code.u.val);
	in = previnstnode(varinode,eqinode);

	/* Look backwards from the 'eqcode' for a 'dot' instruction, */
	/* indicating that the assignment is to a ".vol", ".length", or */
	/* other 'dot' expression. */

	prein = previnstnode(varinode,in);

	/* For object variable assignments... */
	if ( in != varinode && codeis(in->code,I_OBJVAREVAL) ) {
		in->code = funcinst(I_OBJVARPUSH);
		eqinode->code = funcinst(I_NOOP);
		code(funcinst(I_VARASSIGN));
		code(numinst(eqtype));
		return;
	}

	if ( prein != varinode && codeis(prein->code,I_DOT) ) {
		isdot++;
		dottype = (int) (in->code.u.val);
		/* wipe out the code for original dot type */
		/* and the original 'dot' code */
		in->code = funcinst(I_NOOP);
		in = previnstnode(varinode,in);
		in->code = funcinst(I_NOOP);
		in = previnstnode(varinode,in);
	}
	if ( codeis(in->code,I_MODULO) ) {
		ismod++;
		/* wipe out original modulo code */
		in->code = funcinst(I_NOOP);
		in = previnstnode(varinode,in);
	}

	cd = varinode->code;

	if ( isdot!=0 && codeis(cd,I_ECURROBJEVAL) )
		execerror("Bad '$.' assignment - probably improper use of a reserved word.");

	if ( !codeis(cd,I_VAREVAL) && !codeis(cd,I_OBJVAREVAL) && !codeis(cd,I_ECURROBJEVAL) )
		execerror("Assignment to non-variable!? (%s)",infuncname(varinode));

	if ( isdot ) {
		if ( ismod ) {   /* assignments of the type: var%mod.dottype= */

			if (dottype==LENGTH){
				execerror("Improper combintation of '%%' and %s",
					dotstr(dottype));
			}
			/* var%expr.dottype assignment */
			code(funcinst(I_MODDOTASSIGN));
			code(numinst(dottype));
			code(numinst(eqtype));
		}
		else {		/* assignments of the type: var.dottype = */
				/* (including .input and .output) */
			code(funcinst(I_DOTASSIGN));
			code(numinst(dottype));
			code(numinst(eqtype));
		}
	}
	else {
		if ( ismod ) {	/* assignments of the type: var%mod = */
			code(funcinst(I_MODASSIGN));
			code(numinst(eqtype));
		}
		else {		/* assignments of the type: var = */
			code(funcinst(I_VARASSIGN));
			code(numinst(eqtype));
		}
	}

	for ( tin=eqinode; tin!=varinode; tin=previnstnode(varinode,tin) ) {
		if ( codeis(tin->code,I_ARREND) ) {
			tin->code = funcinst(I_ARRAYPUSH);
			isarr++;
			break;
		}
	}

	/* overwrite original instructions */
	if ( isarr ) {
		eqinode->code = funcinst(I_NOOP);
	}
	else if ( codeis(varinode->code,I_VAREVAL) ) {
		varinode->code = funcinst(I_VARPUSH);
		eqinode->code = funcinst(I_NOOP);
	}
	else if ( codeis(varinode->code,I_VARPUSH) ) {
		eqinode->code = funcinst(I_NOOP);
	}
}

void
i_deleteit(void)
{
	Datum d;

	popinto(d);
	if ( d.type == D_ARR ) {
		clearht(d.u.arr);
	}
	else if ( d.type == D_OBJ ) {
		if ( d.u.obj->id < 0 )
			execerror("Attempt to delete an object that's already been deleted!?");
		freeobj(d.u.obj);
	}
	else {
		execerror("I don't know how to delete %s !?\n",atypestr(d.type));
	}
}

void
i_deletearritem(void)
{
	Datum d;
	Datum darr;

	popinto(d);
	if ( Stackp == Stack )
		execerror("Bad delete statement?!");
	popinto(darr);
	expectarr(darr,d,"following delete");
	(void) arraysym(darr.u.arr,d,H_DELETE);
}

int
recodedelete(Instnodep exprinode,Instnodep lastinode)
{
	Instnodep in;

	for ( in=lastinode; in!=exprinode; in=previnstnode(exprinode,in) ) {
		if ( codeis(in->code,I_ARREND) ) {
			in->code = funcinst(I_NOOP);
			lastinode->code = funcinst(I_DELETEARRITEM);
			break;
		}
	}
	return 0;
}

void
i_readonlyit(void)
{
	Symbolp s;

	s = use_symcode();
	s->flags |= S_READONLY;
}

void
i_onchangeit(void)
{
	Symbolp s;
	Datum d;

	s = use_symcode();
	popinto(d);
	if ( d.type != D_CODEP )
		execerror("Bad onchange statement - expecting function value?!");
	s->onchange = d.u.codep;
}

void
i_eval(void)
{
	Datum d;
	Codep cp;

	popinto(d);
	if ( d.type != D_STR )
		execerror("eval: must be given a string!");
	cp = instructs(d.u.str);

	/* It's important to push this before calling nestinstruct, */
	/* because nestinstruct() pushing a bunch of stuff on the stack. */
	pushexp(numdatum((long)Errors));

	if ( cp )
		nestinstruct(cp);
}
