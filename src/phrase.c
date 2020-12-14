/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#include "key.h"

#ifdef OLDSTUFF
void
countnotes(void)
{
	Noteptr nt;
	Phrasep ph;
	int n, nph, npage;

	eprint("Numnotes=%d\n",Numnotes);
	n = 0;
	for(nt=Freent;nt!=NULL;nt=nextnote(nt))
		n++;
	eprint("Numfree=%d\n",n);
	n = nph = npage = 0;
	for(ph=Topph;ph!=NULL;ph=ph->p_next) {
		if ( ispagedout(ph) )
			npage++;
		else
			n += phsize(ph,0);
		nph++;
	}
	eprint("Num in Topph phrases=%d npage=%d notes=%d\n",nph,npage,n);
	n = nph = npage = 0;
	for(ph=Freeph;ph!=NULL;ph=ph->p_next) {
		if ( ispagedout(ph) )
			npage++;
		else
			n += phsize(ph,0);
		nph++;
	}
	eprint("Num in Freeph phrases=%d npage=%d notes=%d\n",nph,npage,n);
	n = nph = npage = 0;
	for(ph=Tobechecked;ph!=NULL;ph=ph->p_next) {
		if ( ispagedout(ph) )
			npage++;
		else
			n += phsize(ph,0);
		nph++;
	}
	eprint("Num in Tobechecked phrases=%d npage=%d notes=%d\n",nph,npage,n);
}
#endif

void
resetdef(void)
{
	Defvol = DEFVOL;
	Defoct = DEFOCT;
	Defdur = DEFCLICKS;
	Defchan = DEFCHAN;
	Defport = DEFPORT;
	Defatt = Nullstr;
	Defflags = 0;
	Deftime = Def2time = 0L;
}

int
saniport(long port)
{
	if ( port < 0 || port > MAX_PORT_VALUE ) {
		port = DEFPORT;
	}
	return port;
}

Noteptr 
newnt(void)
{
	static Noteptr lastn;
	static int used = ALLOCNT;
	Noteptr n;

	/* to avoid spending much time on it, we only check memory */
	/* every so often. */
	{static int cnt = 0;
		if ( ++cnt > 256 ) {
			cnt = 0;
			corecheck();
		}
	}

	/* First check the free list and use those nodes, before using */
	/* the newly allocated stuff. */
	if ( Freent != NULL ) {
		n = Freent;
		Freent = Freent->next;
		goto getout;
	}
	if ( used == ALLOCNT ) {
		Numalloc += ALLOCNT;
		used = 0;
		lastn = (Noteptr) kmalloc(ALLOCNT*sizeof(Notedata),"newnt");
	}
	used++;
	n = lastn++;
    getout:
	n->next = NULL;
#ifdef NTATTRIB
	n->attrib = Nullstr;
#endif
	n->flags = 0;
	Numnotes++;
	return(n);
}

Midimessp
savemess(Unchar* mess,int leng)
{
	Midimessp m;
	Unchar *p, *q;
	int n;

	m = (Midimessp) kmalloc(sizeof(Midimessdata),"savemess");
	m->leng = leng;
	m->bytes = (Unchar*) kmalloc((unsigned)leng,"savebytes");
	p = m->bytes;
	q = mess;
	for ( n=0; n<leng; n++ )
		*p++ = *q++;
	return(m);
}

/*
 * Add a node to the free list
 */
void
ntfree(Noteptr n)
{
        Midimessp m;

	if ( n == NULL )
		return;
        if ( typeof(n) == NT_BYTES ) {
                m = messof(n);
                kfree(m->bytes);
                kfree(m);
                /* make sure we can't try to free it again */
                messof(n) = NULL;
        }
        nextnote(n) = Freent;
        Freent = n;
	Numnotes--;
}

Noteptr 
ntcopy(Noteptr n)
{
	Noteptr nn;
	int i, nb;

	nn = newnt();
	timeof(nn) = timeof(n);
#ifdef NTATTRIB
	attribof(nn) = attribof(n);
#endif
	flagsof(nn) = flagsof(n);
	portof(nn) = portof(n);
	switch (typeof(nn) = typeof(n)) {
	case NT_BYTES:
		messof(nn) = savemess(messof(n)->bytes,messof(n)->leng);
		break;
	case NT_LE3BYTES:
		nb = le3_nbytesof(nn) = le3_nbytesof(n);
		for ( i=0; i<nb; i++ )
			*ptrtobyte(nn,i) = *ptrtobyte(n,i);
		break;
	default:	/* NT_NOTE, NT_ON, NT_OFF */
		setchanof(nn) = chanof(n);
		pitchof(nn) = pitchof(n);
		volof(nn) = volof(n);
		durof(nn) = durof(n);
		break;
	}
	nextnote(nn) = NULL;
	return(nn);
}

/* freents(n) - works even if n==NULL to begin with */
void
freents(Noteptr n)
{
	Noteptr nxt;

	dummyset(nxt);
	for ( ; n!=NULL; n=nxt ) {
		nxt = n->next;
		ntfree(n);
	}
}

/* compare two Midimess (ie. raw bytes) */
int
bytescmp(Noteptr n1,Noteptr n2)
{
	Unchar *p1, *p2;
	int lng1, lng2;
	int cmp, n;

	p1 = ptrtobyte(n1,0);
	lng1 = ntbytesleng(n1);

	p2 = ptrtobyte(n2,0);
	lng2 = ntbytesleng(n2);

	for ( n=lng1; n-- > 0; ) {
		if ( (cmp=(*p1++)-(*p2++)) != 0 )
			return cmp;
	}
	return lng1 - lng2;
}

int
utypeof(Noteptr nt)
{
	switch (nt->type) {
	case NT_ON:
	case NT_OFF:
	case NT_NOTE:
		return nt->type;
	default:
		return NT_BYTES;
	}
}

/* Compare two notes in the way used for ordering within a phrase. */
/* I *think* this routine is starting to become almost exactly like */
/* ntcmpxact(), except for the handling of midibytes types. */
/* Probably should add a parameter to it, rather than duplicate the */
/* code twice - that way it'll keep in sync better if there are future */
/* changes. */
int
ntcmporder(Noteptr n1,Noteptr n2)
{
	long ld;
	int d;
#ifdef NTATTRIB
	char *att1;
	char *att2;
#endif

	if ( (ld=timeof(n1)-timeof(n2)) < 0 )
		return -1;
	if ( ld > 0 )
		return 1;
	if ( (d=utypeof(n1)-utypeof(n2)) < 0 )
		return -1;
	if ( d > 0 )
		return 1;
	/* Types are the same.  NT_BYTES are not sorted further, so */
	/* that the order of things like pitch bends and other */
	/* miscellaneous stuff is retained. */
	if ( ntisbytes(n1) )
		return 0;
	if ( (d=pitchof(n1)-pitchof(n2)) < 0 )
		return -1;
	if ( d > 0 )
		return 1;
	if ( (d=chanof(n1)-chanof(n2)) < 0 )
		return -1;
	if ( d > 0 )
		return 1;
	if ( (d=portof(n1)-portof(n2)) < 0 )
		return -1;
	if ( d > 0 )
		return 1;
	if ( (d=volof(n1)-volof(n2)) < 0 )
		return -1;
	if ( d > 0 )
		return 1;
	if ( (d=flagsof(n1)-flagsof(n2)) < 0 )
		return -1;
	if ( d > 0 )
		return 1;
	if ( (ld=durof(n1)-durof(n2)) < 0 )
		return -1;
	if ( ld > 0 )
		return 1;
#ifdef NTATTRIB
	/* Quick equality test is to compare the char* pointers, */
	/* since they're both uniqstr'ed.  */
	att1 = attribof(n1);
	att2 = attribof(n2);
	if ( att1 != att2 ) {
		if ( strcmp(att1,att2) < 0 )
			return -1;
		else
			return 1;
	}
#endif
	return 0;
}

/* compare two notes exactly (all attributes are used in the comparison) */
int
ntcmpxact(Noteptr n1,Noteptr n2)
{
	long ld;
	int d;
#ifdef NTATTRIB
	char *att1;
	char *att2;
#endif

	if ( (ld=timeof(n1)-timeof(n2)) < 0 )
		return -1;
	if ( ld > 0 )
		return 1;
	if ( (d=utypeof(n1)-utypeof(n2)) < 0 )
		return -1;
	if ( d > 0 )
		return 1;
	/* types are the same, NT_BYTES needs to be compared */
	if ( ntisbytes(n1) )
		return bytescmp(n1,n2);
	if ( (d=pitchof(n1)-pitchof(n2)) < 0 )
		return -1;
	if ( d > 0 )
		return 1;
	if ( (d=chanof(n1)-chanof(n2)) < 0 )
		return -1;
	if ( d > 0 )
		return 1;
	if ( (d=portof(n1)-portof(n2)) < 0 )
		return -1;
	if ( d > 0 )
		return 1;
	if ( (d=volof(n1)-volof(n2)) < 0 )
		return -1;
	if ( d > 0 )
		return 1;
	if ( (d=flagsof(n1)-flagsof(n2)) < 0 )
		return -1;
	if ( d > 0 )
		return 1;
	if ( (ld=durof(n1)-durof(n2)) < 0 )
		return -1;
	if ( ld > 0 )
		return 1;
#ifdef NTATTRIB
	/* Quick equality test is to compare the char* pointers, */
	/* since they're both uniqstr'ed.  */
	att1 = attribof(n1);
	att2 = attribof(n2);
	if ( att1 != att2 ) {
		if ( strcmp(att1,att2) < 0 )
			return -1;
		else
			return 1;
	}
#endif
	return 0;
}

void
phcopy(Phrasep out,Phrasep in)
{
	Noteptr n, newn, lastn;

	lastn = NULL;
	out->p_leng = in->p_leng;
	for ( n=firstnote(in); n!=NULL; n=nextnote(n) ) {
		newn = ntcopy(n);
		if ( lastn == NULL )
			setfirstnote(out) = newn;
		else
			lastn->next = newn;
		lastn = newn;
		chkrealoften();
	}
	out->p_end = lastn;

}

/*
 * phreorder
 *
 * Make sure the notes in a phrase are in the proper order,
 * and set p_end as a side effect.
 */

void
phreorder(Phrasep ph,long tmout)
{
	Noteptr n, nextn;
	int cnt = 0;

	/* Since we're re-ordering, we can't trust p_end, so we */
	/* have to make sure ntinsert() doesn't use it. */
	lastnote(ph) = NULL;

	for ( n=firstnote(ph); n!=NULL; ) {
		if ( tmout > 0 && ++cnt > 100 ) {
			cnt = 0;
			if ( MILLICLOCK >= tmout ) {
				FILE *tf = fopen("tmp.phrase","w");
				eprint("Warning, phreorder timed out!!\n");
#ifdef DONTDO
				tmout += 30000;
				for ( n=firstnote(ph);n!=NULL;n=n->next ) {
					fprintf(tf,"n=%ld,tm=%ld\n",(long)n,timeof(n));
					if ( MILLICLOCK >= tmout ) {
						fprintf(tf,"TIMEOUT!?\n");
						break;
					}
				}
#endif
				myfclose(tf);
				return;
			}
		}
		if ( (nextn=n->next) == NULL )
			break;
		if ( ntcmporder(n,nextn) <= 0 ) {
			n = nextn;	/* order is okay */
		}
		else {
			/* nextn is out of order, so delete and re-insert */
			n->next = nextn->next;
			ntinsert(nextn,ph);
			/* don't advance n */
		}
	}
	ph->p_end = n;
}

void
phcutusertype(Phrasep pin,Phrasep pout,int types,int invert)
{
	Noteptr n;
	int istype;

	for ( n=firstnote(pin); n!=NULL; n=nextnote(n) ) {
		istype = (usertypeof(n) & types) != 0;
		if ( invert )
			istype = !istype;
		if ( istype )
			ntinsert(ntcopy(n),pout);
	}
}

void
phcutcontroller(Phrasep pin,Phrasep pout,int cnum, int invert)
{
	Noteptr n;
	int istype;

	for ( n=firstnote(pin); n!=NULL; n=nextnote(n) ) {
		istype = (usertypeof(n) & M_CONTROLLER) != 0;
		if ( invert )
			istype = !istype;
		if ( istype && (cnum == *ptrtobyte(n,1)) )
			ntinsert(ntcopy(n),pout);
	}
}

void
phcutflags(Phrasep pin,Phrasep pout,long mask)
{
	Noteptr n;

	for ( n=firstnote(pin); n!=NULL; n=nextnote(n) ) {
		if ( (flagsof(n) & mask) != 0 )
			ntinsert(ntcopy(n),pout);
	}
}

void
phcutchannel(Phrasep pin,Phrasep pout,int chan)
{
	Noteptr n;
	Datum d;

	for ( n=firstnote(pin); n!=NULL; n=nextnote(n) ) {
		if ( ! ntdotvalue(n,CHAN,&d) )
			continue;
		if ( numval(d) == chan )
			ntinsert(ntcopy(n),pout);
	}
}

/*
 * All of the phcut*() functions have the following semantics:
 * the time period of the cut starts at tm1 and ends at (but does NOT
 * include) tm2.  If tm2==tm1, it is handled as if tm2=tm+1.
 * If tm2<0, the cut extends to the end of the phrase.
 */

void
phcut(Phrasep pin,Phrasep pout,long tm1,long tm2,int p1,int p2)
{
	Noteptr n;
	long t;

	if ( tm1 == tm2 )
		tm2 = tm1 + 1;
	for ( n=firstnote(pin); n!=NULL; n=nextnote(n) ) {
		t = timeof(n);
		if ( t >= tm1 && t<tm2 &&
			( !ntisnote(n) || ((int)pitchof(n)>=p1&&(int)pitchof(n)<=p2) ) ){
				ntinsert(ntcopy(n),pout);
		}
	}
}

void
phcutincl(Phrasep pin,Phrasep pout,long tm1,long tm2)
{
	Noteptr n;
	long t, e;

	if ( tm1 == tm2 )
		tm2 = tm1 + 1;
	for ( n=firstnote(pin); n!=NULL; n=nextnote(n) ) {
		t = timeof(n);
		e = endof(n);
		if ( t == e )
			e = t + 1;

		if ( (t<=tm1 && e>tm1) || (t>tm1 && t<tm2) )
			ntinsert(ntcopy(n),pout);
	}
}

void
phcuttrunc(Phrasep pin,Phrasep pout,long tm1,long tm2)
{
	Noteptr n, newn;
	long prehang, overhang;
	long t, e;

	if ( tm1 == tm2 )
		tm2 = tm1 + 1;
	for ( n=firstnote(pin); n!=NULL; n=nextnote(n) ) {
		t = timeof(n);
		e = endof(n);
		if ( t == e )
			e = t + 1;

		if ( t >= tm2 || e <= tm1 )
			continue;

		newn = ntcopy(n);

		prehang = tm1 - t;
		if ( prehang > 0 ) {
			timeof(newn) += prehang;
			durof(newn) -= prehang;
		}
		if ( tm2 >= 0 ) {
			overhang = endof(newn) - tm2;
			if ( overhang > 0 )
				durof(newn) -= overhang;
		}
		/* timeof(newn) -= tm1; */
		ntinsert(newn,pout);
	}
#ifdef OLDSTUFF
	if ( tm2 >= 0 )
		pout->p_leng = tm2 - tm1;
	else
		pout->p_leng = pin->p_leng - tm1;
#endif
}

Phrasep
newph(int inituse)
{
	static Phrasep lastph;
	static int used = ALLOCPH;
	Phrasep p;

	/* First check the free list and use those nodes, before */
	/* using newly allocated stuff. */
	if ( Freeph != NULL ) {
		p = Freeph;
		Freeph = Freeph->p_next;
		goto getout;
	}

	/* allocate a bunch of new ones at a time */
	if ( used == ALLOCPH ) {
		lastph = (Phrasep) kmalloc(ALLOCPH*sizeof(Phrase),"newph");
		used = 0;
	}
	used++;
	p = lastph++;
	init1ph(p);	/* first-time init */
getout:
	reinitph(p);
	p->p_used = inituse;
	/* Topph is the list of phrases in use */
	p->p_next = Topph;
	p->p_prev = NULL;
	if ( Topph != NULL )
		Topph->p_prev = p;
	Topph = p;
	return(p);
}

void
reinitph(Phrasep p)
{
	p->p_notes = NULL;
	p->p_end = NULL;
	p->p_leng = 0L;
	p->p_used = 0;
	p->p_tobe = 0;
}

/*
 * ntinsert(n,p)
 *
 * Insert a note into a phrase, using the note's
 * time (clicks) to determine where it goes.
 */

void
ntinsert(Noteptr n,Phrasep p)
{
	Noteptr lastn = NULL;
	Noteptr prevnt = NULL;
	Noteptr nt1;

	/* quick check to see if it goes at the end */
	lastn = p->p_end;
	if ( lastn != NULL && ntcmporder(n,lastn) >= 0 ) {
		lastn->next = n;
		n->next = NULL;
		p->p_end = n;
		return;
	}

	nt1 = firstnote(p);
	while ( nt1!=NULL && ntcmporder(nt1,n) <= 0 ) {
		prevnt = nt1;
		nt1=nt1->next;
	}
	if ( prevnt == NULL )
		setfirstnote(p) = n;	/* first one in list */
	else
		prevnt->next = n;
	n->next = nt1;
	if ( nt1 == NULL )
		p->p_end = n;
/* printf("   after expensive ntinsert, p->first=%ld\n",realfirstnote(p)); */
}

/*
 * ntdelete
 *
 * Find and delete a note from a phrase.
 */

void
ntdelete(Phrasep ph,Noteptr nt)
{
	Noteptr n, pre;

	for ( pre=NULL,n=firstnote(ph); n!=NULL; pre=n,n=n->next ) {
		if ( n == nt )
			break;
	}
	if ( n != NULL ) {
		/* we found it; delete it */

		if ( pre == NULL )
			setfirstnote(ph) = nt->next;
		else
			pre->next = nt->next;

		if ( nt->next == NULL )
			ph->p_end = pre;

		ntfree(nt);
	}
}

int
usertypeof(Noteptr nt)
{
	Unchar* bp;
	int ch1, ch2, ch3;

	switch(nt->type){
	case NT_NOTE:
		return NT_NOTE;
	case NT_ON:
		return NT_ON;
	case NT_OFF:
		return NT_OFF;
	case NT_BYTES:
	case NT_LE3BYTES:
		bp = ptrtobyte(nt,0);
		ch1 = *bp++;
		switch (ch1 & 0xf0) {
		case 0x80: return NT_ON;	/* shouldn't happen */
		case 0x90: return NT_OFF;	/* shouldn't happen */
		case 0xa0: return M_PRESSURE;
		case 0xb0: return M_CONTROLLER;
		case 0xc0: return M_PROGRAM;
		case 0xd0: return M_CHANPRESSURE;
		case 0xe0: return M_PITCHBEND;
		case 0xf0:
			switch (ch1 & 0xff) {
			case 0xf0:
				ch2 = *bp++;
				ch3 = *bp++;
				if ( ch2 == 0x00 && ch3 == 0x7f )
					return M_SYSEXTEXT;
				else
					return M_SYSEX;
			case 0xf2: return M_POSITION;
			case 0xf3: return M_SONG;
			case 0xf8: return M_CLOCK;
			case 0xfa: return M_STARTSTOPCONT;
			case 0xfb: return M_STARTSTOPCONT;
			case 0xfc: return M_STARTSTOPCONT;
			}
		}
		return NT_BYTES;
	default:
		eprint("nt->type=%d\n",nt->type);
		mdep_popup("Hey, unexpected nt->type in usertypeof() !?");
		return NT_BYTES;
	}
}

/*
 * phtype
 *
 * The phrase type equals the type of all its notes, if they're all
 * consistent, or equals NT_BYTES if they're mixed.
 */

int
phtype(Phrasep p)
{
	Noteptr n = firstnote(p);
	int t;

	if ( n == NULL )
		return(NT_BYTES);	/* -1 would be another possibility */
	t = usertypeof(n);
	for ( n=n->next; n!=NULL; n=n->next ) {
		if ( usertypeof(n) != t )
			return(NT_BYTES);
	}
	return(t);
}

char *
notetoke(INTFUNC infunc)
{
	static char *notebuff = NULL;
	static unsigned int buffsize = 0;
	static int buffinc = 32;
	static char *endofbuff = NULL;
	static int savechar = 0;
	int sc = savechar;
	int state = 0;
	char *p = notebuff;
	int c;

	while ( state >= 0 ) {

		if ( sc != 0 ) {
			c = sc;
			sc = 0;
		}
		else
			c = (*infunc)();

		if ( c == EOF )
			break;

		if ( p>=endofbuff ) {
			/* increase size of notebuff */
			char *r, *newbuff;
			char *q = notebuff;

			buffsize += buffinc;
			buffinc = (buffinc*3)/2;
			newbuff = kmalloc(buffsize,"notetoke");
			r = newbuff;
			while ( q < p )
				*r++ = *q++;
			kfree(notebuff);
			notebuff = newbuff;
			endofbuff = notebuff + buffsize;
			p = r;
		}

		switch (state) {
		case 0:
			if ( c == ',' ) {
				*p++ = c;
				state = 1;
				break;
			}
			if ( isspace(c) || c == '|' )
				break;
			/* single quotes are returned immediately */
			if ( c == '\'' ) {
				*p++ = c;
				*p = '\0';
				state = -1;
				break;
			}
			/* any token beginning with a '#' is a comment, */
			/* and extends to the end of the line. */
			if ( c == '#' ) {
				state = 10;
				break;
			}
			/* First char of a normal token */
			*p++ = c;
			if ( c == '"' )
				state = 3;
			else
				state = 2;
			break;
		case 1:	/* scanning white space after initial comma */
			if ( c == '#' ) {
				state = 11;
				break;
			}
			if ( isspace(c) )
				break;
			/* ignore a lone comma, before the final quote */
			if ( c == '\'' ) {
				notebuff[0] = '\'';
				notebuff[1] = '\0';
				state = -1;
				break;
			}
			/* First char of a normal token (after comma) */
			*p++ = c;
			if ( c == '"' )
				state = 3;
			else
				state = 2;
			break;
		case 2: /* scanning note */
			if ( c==',' || c=='\'' ) {
				sc = c;
				c = '\0';
				state = -1;
			}
			else if ( isspace(c) || c == '|' ) {
				c = '\0';
				state = -1;
			}
			*p++ = c;
			break;
		case 3:	/* scanning quoted string */
#ifdef OLDSTUFF
			if ( c == '\n' || c == '\r' ) {
				eprint("Newline found inside quotes?\n");
				c = '"';
			}
#endif
			*p++ = c;
			if ( c == '"' ) {
				/* a 't'ime may follow the quoted string */
				state = 2;
			}
			break;
		case 10: /* scanning comment */
			if ( c == '\n' || c == '\r' )
				state = 0;
			break;
		case 11: /* scanning comment after an initial comma */
			if ( c == '\n' || c == '\r' )
				state = 1;
			break;
		}
	}
	savechar = sc;
	if ( c == -1 )
		return(NULL);
	else
		return(notebuff);
}

Phrasep
yyphrase(INTFUNC infunc)
{
	Noteptr n;
	Noteptr lastn = NULL;
	Phrasep p;
	char *buff;
	long maxend = UNDEFCLICKS;
	int nquotes = 0;

	/* reset default values for volume, duration, etc. */
	resetdef();

	p = newph(0);
	setfirstnote(p) = NULL;
	p->p_leng = UNDEFCLICKS;

	while ( (buff=notetoke(infunc)) != NULL ) {

		/* if we see a quote, ignore it, but quit reading when we */
		/* get a second one, no matter what state we're in. */
		if ( *buff == '\'' ) {
			if ( ++nquotes >= 2 )
				break;
			continue;
		}
		/* Be forgiving of isolated or duplicated commas */
		if ( *buff==',' && *(buff+1)=='\0' )
			continue;

		n = ntparse(buff,p);

		/* keep track of the maximum note ending time */
		if ( maxend==UNDEFCLICKS || Def2time>maxend )
			maxend = Def2time;

		if ( n == NULL )
			continue;

		/* Avoid ntinsert() if possibe (as an optimization) */
		if ( firstnote(p) == NULL ) {
			setfirstnote(p) = n;
			lastn = n;
		}
		else if ( ntcmporder(n,lastn) >= 0 ) {
			lastn->next = n;
			lastn = n;
		}
		else {
/* printf("yyphrase is doing an insert, lastn=(p=%d t=%ld) thisn=(p=%d t=%ld)\n",
pitchof(lastn),timeof(lastn),pitchof(n),timeof(n)); */
			ntinsert(n,p);
			/* make sure lastn is correct */
			while ( lastn->next != NULL )
				lastn = lastn->next;
		}

	}
	p->p_end = lastn;

	/* If the phrase length isn't explicit, it's the maximum */
	/* note ending time.  Note that we want to handle trailing */
	/* rests, which update Deftime* but aren't real notes. */
	if ( p->p_leng == UNDEFCLICKS ) {
		p->p_leng = ( (maxend==UNDEFCLICKS) ? 0 : maxend );
	}
	return(p);
}

static Symstr Strptr;

int
strinput(void)
{
	int c = *Strptr++;
	return ( c == '\0' ? EOF : c );
}

Phrasep
strtophr(Symstr s)
{
	Strptr = s;
	return(yyphrase(strinput));
}

int
ntbytesleng(Noteptr n)
{
	if ( typeof(n) == NT_BYTES )
		return messof(n)->leng;
	else	/* NT_LE3BYTES */
		return le3_nbytesof(n);
}

/*
 * ntparse(s,p)
 *
 * Given a string (s) containing a literal note description (e.g. "a3",
 * "b-2", "el10"), parse it and construct a Note;
 * Things that are not explicitly specified (e.g. the volume, octave,
 * duration) are taken from the previous call to ntparse.
 */

Noteptr 
ntparse(char *s,Phrasep p)
{
	Noteptr n;
	int type = NT_NOTE;
	long lng;

	while ( isspace(*s) || *s == '|' )
		s++;
	/* A comma indicates the note should be put at the end of the */
	/* last note, otherwise the note starts at the same time */
	/* as the previous note. */
	if ( *s == ',' ) {
		s++;
		while ( isspace(*s) )
			s++;
		Deftime = Def2time;
	}
 
	/* first char of note determines basic type */
	switch (*s) {
	case 'l':
		/* explicit phrase length */
		s++;
		lng = numscan(&s);
		if ( p != NULL )
			p->p_leng = lng;
		return(NULL);
	case 'x':
		/* raw midi bytes */
		n = messtont(s+1);
		if ( n == NULL )
			return(NULL);
		type = typeof(n);
		break;
	case 'r':
		/* rests get scanned, to update Deftime */
		(void) strtont(s);
		/* but they're of no other use */
		return(NULL);
	case '+':
		n = strtont(s+1);
		type = NT_ON;
		break;
	case '-':
		n = strtont(s+1);
		type = NT_OFF;
		break;
	case '"':
		n = strtotextmess(s+1);
		type = typeof(n);
		break;
	default:
		n = strtont(s); /* NT_NOTE */
		break;
	}

	if ( n == NULL )
		return(NULL);	/* error */

	typeof(n) = type;

	Deftime = timeof(n);
	Def2time = endof(n);

	return(n);
}

/*
 * attscan(s)
 *
 * Scan an attribute value of a note.
 */

char *
attscan(char **s)
{
	char *olds = *s;
	char *r;
	char c, savec;

	while ( (c=(**s)) != '`' && c != '\0' )
		(*s)++;
	savec = **s;
	**s = '\0';
	r = uniqstr(olds);
	**s = savec;
	(*s)++;
	return r;
}

/*
 * strtont(s)
 *
 * Give a string (s) containing a literal note description (e.g. "a3",
 * "b-2", "el10"), return the note equivalent.  Things that are
 * not explicitly specified (e.g. the volume, octave, duration) are
 * taken from the previous call to strtont.
 */

Noteptr 
strtont(char *s)
{
	static char pitchnames[]={'c','d','e','f','g','a','b','\0'};
	static int pitchvals[] = { 24, 26, 28, 29, 31, 33, 35};	/* octave 0 */
	int vol, octave, chan;
	DURATIONTYPE dur;
	int val = 0, pitch = -1, isrest = 0;
	long clicks = -1L;
	Noteptr n;
	char *att;
	char c;
	UINT16 flags;
	int port;

	vol = Defvol;
	octave = Defoct;
	dur = Defdur;
	chan = Defchan;
	clicks = Deftime;
	att = Defatt;
	flags = Defflags;
	port = Defport;

	if ( *s == 'p' ) {
		/* If it starts with a 'p', it's a raw pitch number.. */
		s++;
		pitch = (int) numscan(&s);
	}
	else if ( *s == 'r' ) {
		/* 'r' is for 'rest' */
		s++;
		isrest = 1;
	}
	else {
		/* Otherwise, it should be a pitch name */
		int i = 0;
		int schr = *s;
		char *pn = pitchnames;

		while ( (c=(*pn++)) != '\0' ) {
			if ( c == schr )
				break;
			i++;
		}
		if ( c == '\0' )
			return((Noteptr)NULL);
		val = pitchvals[i];
		s++;
	}
	/* Now pick up any of the optional suffixes */
	while ( (c=(*s++)) != '\0' ) {
		switch (c) {
		case '+':
		case '#':
			val++;
			break;
		case '-':
			val--;
			break;
		case '0': case '1': case '2': case '3': case '4':
		case '5': case '6': case '7': case '8': case '9':
			octave = c - '0';
			break;
		case 'o':
		case 'O':
			octave = (int) numscan(&s);
			break;
		case 'v':
		case 'V':
			vol = (int) numscan(&s);
			break;
		case 'd':
		case 'D':
			dur = (DURATIONTYPE) numscan(&s);
			break;
		case 't':
		case 'T':
			clicks = numscan(&s);
			break;
		case 'c':
		case 'C':
			chan = (int) numscan(&s) - 1;
			break;
		case 'P':
			port = saniport(numscan(&s));
			break;
		case ':':
			flags = (int) numscan(&s);
			break;
		case '`':
			att = attscan(&s);
			break;
		}
	}

	/* If a 'raw' pitch number wasn't given .. */
	if ( pitch < 0 )
		pitch = val + 12 * octave;

	/* various sanity checking */
	if ( pitch < 0 )
		pitch = 0;
	else if ( pitch > 127 )
		pitch = 127;

#ifdef OLDSTUFF
	if ( clicks < 0 )
		clicks = 0;
#endif

	if ( chan < 0 )
		chan = 0;
	else if ( chan > 15 )
		chan = 15;

	if ( vol < 0 )
		vol = 0;
	else if ( vol > 127 )
		vol = 127;

	port = saniport(port);

	if ( dur < 0 )
		dur = 0;

	Defchan = chan;
	Defdur = dur;
	Defvol = vol;
	Defoct = octave;
	Defatt = att;
	Defflags = flags;
	Defport = port;

	/* For rests, we just update Deftime* so the default for the */
	/* next note will be appropriate. */
	if ( isrest ) {
		Deftime = Def2time = clicks + dur;
		return((Noteptr)NULL);
	}

	/* If no explicit position is given, */
	/* add it to the end of the list. */
	/* create and add a normal note */
	n = newnt();
	typeof(n) = NT_NOTE;
	timeof(n) = clicks;
	setchanof(n) = chan ;
	pitchof(n) = pitch ;
	volof(n) = vol ;
	durof(n) = (DURATIONTYPE)dur;

	/*
	 * Previous bugs in mfin.c may have generated .kp files
	 * that contain durations equal to UNFINISHED_DURATION.
	 * If we find those, force them to 1 beat.
	 */
	if ( durof(n) == UNFINISHED_DURATION ) {
		durof(n) = *Clicks;
	}

	flagsof(n) = flags;
	portof(n) = Defport;
#ifdef NTATTRIB
	attribof(n) = att;
#endif

	return(n);
}

/*
 * messtont
 *
 * Given a string with a raw MIDI message (in hex bytes),
 * scan it and return the equivalent note.
 */

Noteptr
messtont(char *s)
{
	static Unchar *bytes = NULL;
	static int bytesize = 0;
	static int messinc = 64;
	Noteptr n;
	char c;
	int h, i, bytenum=0, byte1;
	int nbytes = 0;

	n = newnt();

	timeof(n) = Deftime;
	flagsof(n) = Defflags;
	portof(n) = Defport;

#ifdef NTATTRIB
	attribof(n) = Defatt;
#endif
	while ( (c=(*s++)) != '\0' ) {
		if ( c == 't' ) {
			timeof(n) = numscan(&s);
			continue;
		}
		if ( c == ':' ) {
			Defflags = (UINT16)numscan(&s);
			flagsof(n) = Defflags;
			continue;
		}
		if ( c == 'P' ) {
			portof(n) = Defport = saniport(numscan(&s));
			continue;
		}
		if ( c == '`' ) {
			Defatt = attscan(&s);
#ifdef NTATTRIB
			attribof(n) = Defatt;
#endif
			continue;
		}
		if ( (h=hexchar(c)) < 0 ) {
			eprint("Unrecognized character '%c' in literal?\n",c);
			continue;
		}
		if ( ++bytenum <= 1 ) {
			byte1 = h;
			continue;
		}
		if ( nbytes >= bytesize ) {
			Unchar *newbytes;
			int oldsize = bytesize;
			bytesize += messinc;
			messinc = (messinc*3)/2;
			/* should really use realloc for this */
			newbytes = (Unchar*) kmalloc((unsigned)bytesize,"messtont");
			while ( oldsize-- > 0 )
				newbytes[oldsize] = bytes[oldsize];
			kfree(bytes);
			bytes = newbytes;
		}
		bytes[nbytes++] = 16*byte1 + h;
		bytenum = 0;
	}
	if ( nbytes <= 0 ) {
		ntfree(n);
		return(NULL);
	}
	else if ( nbytes <= 3 ) {
		typeof(n) = NT_LE3BYTES;
		le3_nbytesof(n) = nbytes;
		for ( i=0; i<nbytes; i++ )
			*ptrtobyte(n,i) = bytes[i];
	}
	else {
		typeof(n) = NT_BYTES;
		messof(n) = savemess(bytes,nbytes);
	}

	return(n);
}

/*
 * strtotextmess
 *
 * Given a string with a text MIDI message (in double quotes)
 * scan it and return the equivalent note.
 */

Noteptr 
strtotextmess(char *s)
{
	Noteptr n;
	char c;
	int nbytes=0;
	unsigned char *buff;

	n = newnt();
	timeof(n) = Deftime;
	flagsof(n) = Defflags;
	portof(n) = Defport;
#ifdef NTATTRIB
	attribof(n) = Defatt;
#endif
	if ( *s == '"' )
		s++;
	buff = (unsigned char *)kmalloc((unsigned)(strlen(s)+8),"strtotextmess");
	buff[nbytes++] = 0xf0;
	buff[nbytes++] = 0x00;
	buff[nbytes++] = 0x7f;
	while ( (c=(*s++)) != '\0' && c!='"' ) {
		if ( nbytes >= (int)(Buffsize-1) ) {
			eprint("Text note is too long!\n");
			break;
		}
		buff[nbytes++] = c & 0x7f;
	}
	/* pick up trailing 't'ime and attribute specifications */
	if ( c == '"' ) {
		for ( ;; ) {
			c = *s++;
			if ( c == 't' )
				Deftime = Def2time = timeof(n) = numscan(&s);
			else if ( c == ':' )
				Defflags = flagsof(n) = (UINT16)numscan(&s);
			else if ( c == 'P' )
				portof(n) = Defport = saniport(numscan(&s));
			else if ( c == '`' ) {
				Defatt = attscan(&s);
#ifdef NTATTRIB
				attribof(n) = Defatt;
#endif
			}
			else
				break;
		}
	}
	buff[nbytes++] = 0xf7;
	typeof(n) = NT_BYTES;
	messof(n) = savemess(buff,nbytes);
	kfree(buff);
	return(n);
}

Unchar*
ptrtobyte(Noteptr n,int num)
{
	Midimessp m;

	switch(typeof(n)){
	case NT_LE3BYTES:
		if ( num < (int)(le3_nbytesof(n)) )
			return (Unchar*)(&(n->u.b.bytes[num]));
		break;
	default:	/* NT_BYTES */
		{
		m = messof(n);

		if ( m != NULL && m->bytes != NULL && num < m->leng )
			return (Unchar*)(&(m->bytes[num]));
		}
		break;
	}
	execerror("Internal error, ptrtobyte can't get pointer (num=%d)!?\n",num);
	return(NULL);	/* to make compiler happy */
}

