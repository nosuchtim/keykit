/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

/* This is a hook to include 'overlay' directives (in mdep.h) */
#define OVERLAY1

#include "key.h"
#include "gram.h"

Phrasep Tobechecked = NULL;
Htablep Htobechecked = NULL;
int Chkstuff = 0;

void
addtobechecked(register Phrasep p)
{
	register Phrasep tp;

	/* make sure it's not already in there */
	for ( tp=Tobechecked; tp!=NULL; tp=tp->p_next ) {
		if ( tp == p )
			return;
	}

	/* Workaround to detect a bug. */
	if ( p->p_tobe < -1000 ) {
		eprint("Ignoring possible bad phrase in addtobechecked!?  Potential memory leak.  p=%lld  tobe=%ld\n",(intptr_t)p,(long)(p->p_tobe));
		return;
	}

	/* remove it from original list */
	if ( p == Topph )
		Topph = p->p_next;
	if ( p->p_next != NULL )
		(p->p_next)->p_prev = p->p_prev;
	if ( p->p_prev != NULL )
		(p->p_prev)->p_next = p->p_next;
	/* Add it to Tobechecked list */

	p->p_next = Tobechecked;
	p->p_prev = NULL;
	if ( Tobechecked != NULL )
		Tobechecked->p_prev = p;
	Tobechecked = p;
	Chkstuff = 1;
}

void
httobechecked(register Htablep p)
{
	/* if it's already in the list... */
	if ( p->h_state == HT_TOBECHECKED )
		return;
	/* remove it from original list */
	if ( p == Topht )
		Topht = p->h_next;
	if ( p->h_next != NULL )
		(p->h_next)->h_prev = p->h_prev;
	if ( p->h_prev != NULL )
		(p->h_prev)->h_next = p->h_next;
	/* Add it to Htobechecked list */

	p->h_next = Htobechecked;
	p->h_prev = NULL;
	p->h_state = HT_TOBECHECKED;
	if ( Htobechecked != NULL )
		Htobechecked->h_prev = p;
	Htobechecked = p;
	Chkstuff = 1;
}

/*
 * phrmerge -  add the contents of 'p' to 'outph', delayed
 * by 'offset'. The assumption is that both phrase's are already sorted.
 */

void
phrmerge(Phrasep p,Phrasep outp,long offset)
{
	Noteptr outn, nt;
	Noteptr usen = NULL;
	Noteptr nt2 = NULL;
	Noteptr *plastn;
	Noteptr lastn;
	int newone = 0;

	/* If p and outp are same, create fresh copy (easiest fix) */
	if ( p == outp ) {
		Phrasep np = newph(1);
		phcopy(np,p);
		p = np;
		newone = 1;
	}
	
	/* If the 'p' phrase can just be tacked onto the end of 'outp', */
	/* then do it directly.  This is an attempt to speed up a common */
	/* use of this function. */
	if ( firstnote(p)!=NULL && firstnote(outp)!=NULL
		&& (lastn=lastnote(outp))!=NULL 
		&& ntcmporder(lastnote(outp),firstnote(p)) < 0 ) {
		for ( nt=firstnote(p); nt!=NULL; nt=nextnote(nt) ) {
			nt2 = ntcopy(nt);
			timeof(nt2) += offset;
			lastn->next = nt2;
			lastn = nt2;
		}
		lastn->next = NULL;
		lastnote(outp) = lastn;
		goto getout;
	}

	/* We want to merge outp and p, putting the result */
	/* back into outp.  Pull off the existing outp list */
	/* and zero it out. */

	outn = firstnote(outp);
	setfirstnote(outp) = NULL;
	nt = firstnote(p);
	if ( nt != NULL ) {
		nt2 = ntcopy(nt);
		timeof(nt2) += offset;
	}
	/* highly optimized code */
	plastn = &(realfirstnote(outp));
	for ( ;; ) {

		chkrealoften();	/* so realtime isn't affected */

		/* Put the lesser of the two available nt's onto */
		/* the end of the new 'outp' list.  */
		if ( outn!=NULL ) {
			if ( nt == NULL )
				goto useoutn;
			if ( ntcmporder(outn,nt2) < 0 )
				goto useoutn;
			/* fall through to usent2*/
		}
		else {			/* outn == NULL */
			if ( nt==NULL )
				break;
			/* fall through to usent2*/
		}
		usen = nt2;
		nt = nt->next;
		if ( nt != NULL ) {
			nt2 = ntcopy(nt);
			timeof(nt2) += offset;
		}
		goto done;
	useoutn:
		usen = outn;
		outn = outn->next;
		/* fall through */
	done:
		*plastn = usen;
		plastn = &(usen->next);
	}
	if ( plastn != &(realfirstnote(outp)) ) {
		*plastn = NULL;
		lastnote(outp) = usen;
	}
    getout:
	if ( newone )
		phdecruse(p);
}

void
phdump(void)
{
	Phrasep p;
	int first = 1;
	for ( p=Topph; p!=NULL; p=p->p_next ) {
		if ( first ) {
			eprint("Dump of Topph phrases:\n");
			first = 0;
		}
		ph1dump(p);
	}
	first = 1;
	for ( p=Tobechecked; p!=NULL; p=p->p_next ) {
		if ( first ) {
			eprint("Dump of Tobechecked phrases:\n");
			first = 0;
		}
		ph1dump(p);
	}
}

void
ph1dump(Phrasep p)
{
	Noteptr n;
	int num;

	num = 0;
	for ( n=firstnote(p); n!=NULL; n=n->next )
		num++;
	sprintf(Msg1,"phrase=%lld numnotes=%d used=%d tobe=%d\n",
		(intptr_t)p,num,(int)(p->p_used),(int)(p->p_tobe));tprint(Msg1);
}

void
phcheck(void)
{
	register Phrasep p, nxt;

	dummyset(nxt);
	for ( p=Tobechecked; p!=NULL; p=nxt ) {

		p->p_used += p->p_tobe;
		p->p_tobe = 0;

		nxt = p->p_next;

		/* remove it from Tobechecked list */
		if ( p->p_prev != NULL )
			p->p_prev->p_next = p->p_next;
		if ( p->p_next != NULL )
			p->p_next->p_prev = p->p_prev;

		if ( p->p_used > 0 ) {
			/* and add it back to Topph list */
			p->p_next = Topph;
			p->p_prev = NULL;
			if ( Topph != NULL )
				Topph->p_prev = p;
			Topph = p;
		} else if ( p->p_used < -100 ) {
			keyerrfile("phcheck is tossing phrase with negative used value (%d)!\n",p->p_used);
		}
		else {
			Noteptr fn = realfirstnote(p);
			if ( fn )
				freents(fn);
			reinitph(p);
			/* and add it to free list */
			p->p_next = Freeph;
			p->p_prev = NULL;
			if ( Freeph != NULL )
				Freeph->p_prev = p;
			Freeph = p;
		}
	}
	Tobechecked = NULL;
}

void
htcheck(void)
{
	register Htablep h, nxt, savelist;

#ifdef lint
	nxt=0;
#endif
	/* This is important, because the call to freeht below may */
	/* start adding things back onto the Htobechecked list! */
if(*Debugmalloc>1)eprint("HTCHECK START\n");
	savelist = Htobechecked;
	Htobechecked = NULL;

	for ( h=savelist; h!=NULL; h=nxt ) {

		nxt = h->h_next;

		h->h_used += h->h_tobe;
if(*Debug>1)eprint("SUMMED h=%lld used=%d\n",(intptr_t)h,h->h_used);
		h->h_tobe = 0;

		/* remove it from Tobechecked list */
		if ( h->h_prev != NULL )
			h->h_prev->h_next = h->h_next;
		if ( h->h_next != NULL )
			h->h_next->h_prev = h->h_prev;
		h->h_state = 0;

		if ( h->h_used > 0 ) {
if(*Debug>1)eprint("htcheck, h=%lld still used\n",(intptr_t)h);
			/* and add it back to Topht list */
			h->h_next = Topht;
			h->h_prev = NULL;
			if ( Topht != NULL )
				Topht->h_prev = h;
			Topht = h;
		} else if ( h->h_used < 0 ) {
			/* There's a but somewhere - occasionally, an h */
			/* gets into the Htobechecked list that is bogus. */
			tprint("h_used < 0, not freeing h\n");
			break;
		} else {
if(*Debug>1)eprint("htcheck calling freeht on %lld used=%d tobe=%d\n",(intptr_t)h,h->h_used,h->h_tobe);
			freeht(h);
		}
	}
}

/* This sequence number is used to represent a pseudo-modification-time */
/* in phrases.  Cheaper than mdep_currtime(), and monotonically increasing. */
/* Macros usesequence() and currsequence() are defined in key.h */
long Seqnum = 0;

char *
strend(register char *s)
{
	while ( *s != '\0' )
		s++;
	return(s);
}

#ifdef OLDRAND
static long Randx=1;

void
keysrand(unsigned x)
{
	Randx = x;
}

int
keyrand(void)
{
	return((int)(((Randx = Randx * 1103515245L + 12345)>>16) & 0x7fff));
}
#endif

/*
 * returns x(n) + z(n) where x(n) = x(n-1) + x(n-2) mod 2^32
 * z(n) = 30903 * z(n-1) + carry mod 2^16
 * Simple, fast, and very good. Period > 2^60
 * This code was obtained from http://remus.rutgers.edu/~rhoads/Code/rands.c
 */

static unsigned int kr2_x, kr2_y, kr2_z;  /* the seeds */

/* returns a random 32-bit integer */
unsigned int
keyrand(void)
{
	unsigned int v;

	v = kr2_x * kr2_y;
	kr2_x = kr2_y;
	kr2_y = v;
	kr2_z = (kr2_z & 65535) * 30903 + (kr2_z >> 16);
	return (kr2_y + (kr2_z&65535));
}

void keysrand (unsigned int seed1, unsigned int seed2, unsigned int seed3)
{
	kr2_x = (seed1<<1) | 1;
	kr2_x = kr2_x * 3 * kr2_x;
	kr2_y = (seed2<<1) | 1;
	kr2_z = seed3;
}


static int Lensofar;
static PFCHAR Phpfunc;

void
phputc(int c)
{
	char ch[2];

	if ( Lensofar >= 0 && Lensofar >= (int)(*Printsplit) ) {
		(*Phpfunc)("\\\n");
		Lensofar = 0;
	}
	ch[0] = c;
	ch[1] = '\0';
	(*Phpfunc)(ch);
	if ( Lensofar >= 0 )
		Lensofar++;
}

void
phputs(char *s)
{
	int len = (int)strlen(s);
	if ( Lensofar >= 0 && (len+Lensofar) > (int)(*Printsplit) ) {
		/* use phputc so it will add the newlines */
		while ( *s != '\0' )
			phputc(*s++);
	}
	else {
		(*Phpfunc)(s);
		if ( Lensofar >= 0 )
			Lensofar += len;
	}
}

void
messprint(Noteptr nt)
{
	Unchar* b;
	int n, v, c1, c2;
	int lng;

	b = ptrtobyte(nt,0);
	lng = ntbytesleng(nt);

	/* Check for the special 'text' messages */
	if ( lng>3 && (b[0]&0xff)==0xf0 && (b[1]&0xff)==0x00 && (b[2]&0xff)==0x7f ) {
		phputc('"');
		for ( n=3; n<lng && (c1=(*ptrtobyte(nt,n))&0xff) != 0xf7 ; n++ )
			phputc(c1);
		phputc('"');
	}
	else {
		/* A normal MIDI message */
		phputc('x');
		for ( n=0; n<lng; n++ ) {
			/* convert each byte to 2 hex characters */
			v = (int)(*ptrtobyte(nt,n)) & 0xff;
			c1 = v % 16;
			c2 = v / 16;
			phputc( (c2>9) ? (c2-10+'a') : (c2+'0') );
			phputc( (c1>9) ? (c1-10+'a') : (c1+'0') );
		}
	}
}

/*
 * phprint(pfunc,ph,nl)
 *
 * Print a readable description of a phrase.
 * pfunc is the function used for output.
 * if nl > 0, add newlines every so many cols (and initial
 * value is nl).  If 0, no newlines are inserted.
 */

void
phprint(PFCHAR pfunc,Phrasep ph,int nl)
{
	Noteptr n;
	long maxend = 0, endm;
	int first = 1;
	char nbuff[64];	/* for numbers and normal notes only, */
			/* this *should* suffice */

	Phpfunc = pfunc;
	if ( nl )
		Lensofar = 0;
	else
		Lensofar = -1;

	/* reset default values for volume, duration, etc. */
	resetdef();

	phputc('\'');
	for ( n=firstnote(ph); n!=NULL; n=nextnote(n) ) {

		if ( first )
			first = 0;
		else {
			char *s;
			/* a blank at the beginning indicates that this */
			/* note starts at the same time as the last one */
			if ( timeof(n) == Deftime )
				s = " ";
			else {
				s = ",";
				Deftime = Def2time;
			}
			phputs(s);
		}

		if ( ntisbytes(n) )
			messprint(n);
		else {
			nttostr(n,nbuff);
			phputs(nbuff);
		}

#ifdef NTATTRIB
		if ( attribof(n) != Defatt && attribof(n) != NULL ) {
			Defatt = attribof(n);
			phputs("`");
			phputs(Defatt);
			phputs("`");
		}
#endif
		if ( portof(n) != Defport ) {
			Defport = portof(n);
			nbuff[0] = 'P';
			(void) prlongto((long)(portof(n)),&nbuff[1]);
			phputs(nbuff);
		}
		if ( flagsof(n) != Defflags ) {
			Defflags = flagsof(n);
			nbuff[0] = ':';
			(void) prlongto(flagsof(n),&nbuff[1]);
			phputs(nbuff);
		}

		if ( timeof(n) != Deftime ) {
			nbuff[0] = 't';
			(void) prlongto(timeof(n),&nbuff[1]);
			phputs(nbuff);
		}

		/* The default time for the next note is the start of the */
		/* previous note.  If a comma is seen (before the NEXT note), */
		/* the default will be the end of the previous note. */
		Deftime = timeof(n);
		Def2time = endof(n);

		endm = endof(n);
		if ( endm > maxend )
			maxend = endm;
	}
	if ( maxend != ph->p_leng ) {
		nbuff[0] = ',';
		nbuff[1] = 'l';
		(void) prlongto(ph->p_leng,&nbuff[2]);
		phputs(nbuff);
	}
	phputc('\'');
}

char *Scachars[] = {
	"c", "c+", "d", "e-", "e", "f", "f+",
	"g", "a-", "a", "b-", "b", "c"
};

/*
 * nttostr(nt,buff)
 *
 * Put a human-readable interpretation of a note into a string.
 */

void
nttostr(Noteptr n,char *buff)
{
	int chan, oct, vol;
	DURATIONTYPE dur;
	register char *p = buff;

	if ( typeof(n) == NT_ON )
		*p++ = '+';
	if ( typeof(n) == NT_OFF )
		*p++ = '-';

	strcpy(p,Scachars[canonipitchof(pitchof(n))]);
	p = strend(p);

	/* We only add the other stuff when it's different from the last one*/
	if ( (oct=canoctave((int)(pitchof(n)))) != Defoct ) {
		*p++ = 'o';
		p = printto(Defoct=oct,p);
	}
	if ( (dur=durof(n)) != Defdur ) {
		*p++ = 'd';
		if ( sizeof(DURATIONTYPE) == sizeof(long) )
			p = prlongto(Defdur=dur,p);
		else
			p = printto((int)(Defdur=dur),p);
	}
	if ( (vol=volof(n)) != Defvol ) {
		*p++ = 'v';
		p = printto(Defvol=vol,p);
	}
	if ( (chan=chanof(n)) != Defchan ) {
		*p++ = 'c';
		p = printto((Defchan=chan)+1,p);
	}
	*p = '\0';
}

int
phsize(register Phrasep p,register int notes)
{
	register int size = 0;
	register Noteptr n;

	if ( p==NULL )
		return(0);
	for ( n=firstnote(p); n!=NULL; n=nextnote(n) ) {
		if ( notes==0 || ntisnote(n) )
			size++;
	}
	return(size);
}

/*
 * picknt
 *
 * Find and return the picknum'th note in a phrase.
 */

Noteptr
picknt(register Phrasep ph,register int picknum)
{
	register Noteptr nt;
	register int n;

	if ( picknum < PHRASEBASE ) {
#ifdef BASEERROR
		execerror("There's no note number '%d' in that phrase!",picknum);
#else
		return(NULL);
#endif
	}
	for ( n=PHRASEBASE,nt=firstnote(ph); nt!=NULL; nt=nextnote(nt) ){
		if ( n++ >= picknum )
			break;
	}
	return(nt);
}

/* phrinphr(d1,d2) - evaluate conditional value of 'phrase in phrase' */
int
phrinphr(Datum d1,Datum d2)
{
	register Noteptr nt1, nt2;

	if ( d1.type != D_PHR || d2.type != D_PHR )
		inerr();

	/* If the 'value' contains more than 1 note, ALL notes must be */
	/* contained in the 'phrase' in order for the condition to be true. */

	for ( nt1=firstnote(d1.u.phr); nt1!=NULL; nt1=nextnote(nt1) ) {
		for ( nt2=firstnote(d2.u.phr); nt2!=NULL; nt2=nextnote(nt2) ) {
			if ( pitchof(nt2) == pitchof(nt1) )
				break;
		}
		if ( nt2 == NULL )
			return(0);	/* any note not found => false */
	}
	return(1);
}

char *
atypestr(int type)
{
	char *s;

	switch(type){
	case D_NUM:	s = "an integer"; break;
	case D_STR:	s = "a string"; break;
	case D_PHR:	s = "a phrase"; break;
	case D_SYM:	s = "a symbol"; break;
	case D_DBL:	s = "a float"; break;
	case D_ARR:	s = "an array"; break;
	case D_CODEP:	s = "a function"; break;
	case D_FRM:	s = "a frame"; break;
	case D_NOTE:	s = "a note"; break;
	case D_DATUM:	s = "a datum"; break;
	case D_FIFO:	s = "a fifo"; break;
	case D_TASK:	s = "a task"; break;
	case D_OBJ:	s = "an object"; break;
	case D_WIND:	s = "a window"; break;
	default:	s = "an UNKNOWN"; break;
	}
	return s;
}

char *
typestr(int type)
{
	char *p;

	p = atypestr(type);
	/* remove initial "a " or "an " */
	if ( *(p+1) == ' ' )
		p += 2;
	else if ( *(p+2) == ' ' )
		p += 3;
	return p;
}

char *
dotstr(register int type)
{
	register char *p;

	switch(type){
	case LENGTH:	 p = ".length"; break;
	case VOL:	 p = ".vol"; break;
	case ATTRIB:	 p = ".attrib"; break;
	case FLAGS:	 p = ".flags"; break;
	case DUR:	 p = ".dur"; break;
	case CHAN:	 p = ".chan"; break;
	case TIME:	 p = ".time"; break;
	case PITCH:	 p = ".pitch"; break;
	case TYPE:	 p = ".type"; break;
	default:	 p = ".unknown?"; break;
	}
	return(p);
}

Datum
phdotvalue(Phrasep ph,int type)
{
	Datum d;
	Noteptr nt;
	int n=0;
	long sum=0;

	switch (type) {
	case LENGTH:
		d = numdatum(ph->p_leng);
		break;
	case NUMBER:
		d = numdatum((long)(T->qmarknum));
		break;
	case TYPE:
		d = numdatum((long)phtype(ph));
		break;
	case ATTRIB:
#ifndef NTATTRIB
		d = strdatum(Nullstr);
#else
		nt = firstnote(ph);
		if ( nt != NULL && attribof(nt) != NULL )
			d = strdatum(attribof(nt));
		else
			d = strdatum(Nullstr);
#endif
		break;
	case PITCH:
	case CHAN:
	case VOL:
	case DUR:
	case TIME:
	case FLAGS:
	case PORT:
		/* The dot value of the rest (PITCH, VOL, etc.) is the */
		/* average over the notes in the phrase.  */
		for ( nt=firstnote(ph); nt!=NULL; nt=nextnote(nt) ) {
			/* non-notes are only included in TIME/CHAN/FLAGS values */
			if ( ntisnote(nt) || (type==TIME || type==CHAN || type==PORT || type==FLAGS) ) {
				(void) ntdotvalue(nt,type,&d);
				sum += numval(d);
				n++;
			}
		}
		d = numdatum( (n==0) ? 0L : (long)(sum/n) );
		break;
	default:
		execerror("Unknown type (%d) in phdotvalue!?",type);
		d = Noval;	/* not reached */
		break;
	}
	return d;
}

int
ntdotvalue(register Noteptr n,register int type,Datum *ad)
{
	int r = 1;
	long v = -1;
	int utype = usertypeof(n);
	Unchar* b0;

	if ( type == ATTRIB ) {
#ifndef NTATTRIB
		(*ad) = strdatum(Nullstr);
#else
		(*ad) = strdatum( attribof(n) ? attribof(n) : Nullstr );
#endif
	} else if ( ntisbytes(n) ) {
		/* Only TIME, CHAN, and FLAGS are valid on MIDIBYTES */
		switch(type){
		case TIME:
			v = timeof(n);
			break;
		case FLAGS:
			v = flagsof(n);
			break;
		case PORT:
			v = portof(n);
			break;
		case CHAN:
			/* make sure it's a status byte */
			if ( (b0=ptrtobyte(n,0))!=NULL && ((*b0)&0x80) != 0 )
				v = 1+(int)((*b0)&0xf);
			else
				r = 0;
			break;
		default:
			/* Invalid things (like nt.pitch) on MIDIBYTES notes */
			/* return -1, so you can compare pitches without */
			/* worrying about checking if it's a MIDIBYTES note. */
			r = 0;
			break;
		}
		(*ad) = numdatum(v);
	}
	else {
		switch(type){
		case PITCH:
			v = pitchof(n);
			break;
		case VOL:
			v = volof(n);
			break;
		case DUR:
			v = durof(n);
			break;
		case TIME:
			v = timeof(n);
			break;
		case FLAGS:
			v = flagsof(n);
			break;
		case PORT:
			v = portof(n);
			break;
		case CHAN:
			v = ( 1 + chanof(n) );
			break;
		case TYPE:
			v = utype;
			break;
		default:
			r = 0;
			break;
		}
		(*ad) = numdatum(v);
	}
	return r;
}

long
getnumval(Datum d,int round)
{
	long v;

	switch (d.type) {
	case D_NUM:
		v = d.u.val;
		break;
	case D_DBL:
		if ( round )
			v = (long)(d.u.dbl + 0.5);
		else
			v = (long)(d.u.dbl);
		break;
	case D_STR:
		{
			char *p = d.u.str;
			int sign = 1;
			int was_hex = 0;
			if ( p == NULL ) {
				v = Noval.u.val;
				break;
			}
			while ( isspace(*p) )
				p++;
			if ( *p == '+' )
				p++;
			else if ( *p == '-' ) {
				p++;
				sign = -1;
			}
			if ( ! isdigit(*p) ) {
				v = Noval.u.val;
				break;
			}
			if ( p[0]=='0' ) {	/* hex or octal */
				int i;
				char *q = p+1;
				v = 0;
				if ( *q =='x' ) {
					was_hex = 1;
					for ( q++; *q != '\0'; q++ ) {
						i = hexchar(*q);
						if ( i < 0 )
							break;
						v = (v*16) + i;
					}
				}
				else {
					for ( ; *q != '\0'; q++ ) {
						i = *q - '0';
						if ( i < 0 || i > 7 )
							break;
						v = (v*8) + i;
					}
				}
			}
			else
				v = atol(p);
			/* A 'q' suffix multiplies by *Clicks */
			p = strchr(p,'\0');
			if ( was_hex==0 && p>d.u.str && (*(p-1) == 'b' || *(p-1) == 'q') )
				v *= *Clicks;
			v *= sign;
		}
		break;
	case D_PHR:
		{
			register Noteptr n = firstnote(d.u.phr);

			/* numeric value of a phrase is either */
			/* the pitch of the first note, or the */
			/* value of the first MIDIbyte */

			if ( n == NULL )
				v = -1;
			else {
				if ( ntisbytes(n) )
					v = (*ptrtobyte(n,0)) & 0xff;
				else
					v = pitchof(n);
			}
		}
		break;
	case D_CODEP:
		// XXX - This code truncates the value of codep on a 64-bit system
		// XXX - It seems to work, but it might not work at some point.
		// XXX - Perhaps some code should be added here to make sure that
		// XXX - the truncated part is 0 (i.e. not significant)?  Not sure.
		// XXX - Maybe this means that numbers in KeyKit are 32-bit,
		// XXX - even on a 64-bit system?  Just thinking out loud here.
		v = (long)(d.u.codep);
		break;
	case D_ARR:
		execerror("getnumval() doesn't work for D_ARR!");
#ifdef OLDCODE
		// I'm not sure this case is still used, it might be vestigal code.  Changing getnumval to be 64-bit (i.e. long long or intptr_t)
		// is a lot of work, so making it an execution error will detect whether it's actually used.
		v = (long)(d.u.arr);
#endif
		break;
	case D_OBJ:
		execerror("getnumval() doesn't work for D_OBJ!");
		break;
	case D_SYM:
		execerror("getnumval() doesn't work for D_SYM!");
		/*NOTREACHED*/
	default:
		execerror("Unknown data type (%d) in getnumval!",d.type);
		/*NOTREACHED*/
	}
	return v;
}

double
getdblval(Datum d)
{
	double f;
	char *endptr;

	switch (d.type) {
	case D_NUM:
		f = (double) d.u.val;
		break;
	case D_DBL:
		f = (double)d.u.dbl;
		break;
	case D_STR:
		f = (double) strtod(d.u.str,&endptr);
		/*
		 * If conversion fails, force it to 0.
		 */
		if ( endptr == d.u.str )
			f = 0.0;
		break;
	case D_PHR:
		f = (double) getnumval(d,0);
		break;
	default:
		execerror("Unknown data type (%d) in getdblval!",d.type);
	}
	return f;
}

int
getnmtype(Datum d)
{
	int t;

	switch (d.type) {
	case D_NUM:
	case D_DBL:
		t = d.type;
		break;
	case D_STR:
		if (strchr(d.u.str,'.')!=NULL)
			t = D_DBL;
		else
			t = D_NUM;
		break;
	default:
		t = D_NUM;
		break;
	}
	return t;
}

#define MAXOPEN 15

struct finfo {
	FILE *ptr;
	char *name;		/* file name or command */
	char *mode;		/* "r" or "w" */
} Files[MAXOPEN];

int
findfile(register char *name)
{
	register char *p;
	register int n;

	for ( n=0; n<MAXOPEN; n++ ) {
		p = Files[n].name;
		if ( p!=NULL && strcmp(name,p)==0 )
			return(n);
	}
	return(-1);
}

void
getnclose(char *fname)
{
	int n;
	FILE *f;

	if ( (n=findfile(fname)) < 0 )
		execerror("Can't close something that's not open: %s",fname);

	f = Files[n].ptr;
	if ( *fname == '|' ) {
#ifdef PIPES
		if ( pclose(f) < 0 )
			eprint("Error in pclose!?\n");
#else
		/*EMPTY*/;
#endif
	}
	else
		myfclose(f);
	Files[n].ptr = NULL;
	Files[n].name = NULL;
}

FILE *
getnopen(char *name,char *mode)
{
	register FILE *f = NULL;
	register int n;

	/* Look to see if the file (or pipe) is already open */
	if ( (n=findfile(name)) >= 0 ) {
		if ( strcmp(Files[n].mode,mode) == 0 )
			return(Files[n].ptr);
		eprint("Conflicting r/w modes - file is automatically closed: %s",name);
		getnclose(name);
		n = findfile(name);
		/* continue on and open the file */
	}

	/* find an open slot */
	for ( n=0; n<MAXOPEN; n++ ) {
		if ( Files[n].name == NULL )
			break;
	}
	if ( n >= MAXOPEN )
		execerror("Too many open files!");

	/* A pipe is indicated by an initial character */

	if ( *name == '|' ) {
#ifdef PIPES
		register char *cmd = name + 1;
		if ( *Abortonint == 0 )
			mdep_ignoreinterrupt();
		f = popen(cmd,mode);
		setintcatch();
#else
		execerror("No pipes!");
#endif
	}
	else {
		/* normal file */
		OPENTEXTFILE(f,name,mode);
	}
	if ( f != NULL ) {
		Files[n].ptr = f;
		Files[n].name = uniqstr(name);
		Files[n].mode = uniqstr(mode);
	}
	return(f);
}

void
closefile(void)
{
	Datum d;

	popinto(d);
	if ( d.type != D_STR )
		execerror("close: must be given a string!");
	getnclose(d.u.str);
}

void
forinerr(void)
{
	execerror("for(... in ...) can only be used on phrases and arrays!");
}

void
inerr(void)
{
	execerror("'in' conditions only work on arrays and phrases!");
}

Instnodep Ifree = NULL;

Instnodep
newin(void)
{
	static Instnodep lastin;
	static int used = ALLOCIN;
	Instnodep i;

	/* First check the free list and use those nodes, before using */
	/* the newly allocated stuff. */
	if ( Ifree != NULL ) {
		i = Ifree;
		Ifree = nextinode(Ifree);
	}
	else  {
		if ( used == ALLOCIN ) {
			used = 0;
			lastin = (Instnodep) kmalloc(ALLOCIN*sizeof(Instnode),"newin");
			*Numinst2 += ALLOCIN;
		}
		used++;
		i = lastin++;
	}
	i->inext = NULL;
	i->code.type = 0;
	return(i);
}

void
freeiseg(Instnodep in)
{
	Instnodep nxti;

	dummyset(nxti);
	for ( ; in!=NULL; in=nxti ) {
		nxti = nextinode(in);
		freeinode(in);
	}
}

void
freecode(Codep cp)
{
	kfree(cp);
}

void
freeinode(Instnodep in)
{
	nextinode(in) = Ifree;
	Ifree = in;
}

Lknode *Toplk = NULL;
Lknode *Freelk = NULL;

Lknode *
newlk(Symstr nm)
{
	static Lknode *lastlk;
	static int used = ALLOCLK;
	Lknode *lk;

	/* First check the free list and use those nodes, before using */
	/* the newly allocated stuff. */
	if ( Freelk != NULL ) {
		lk = Freelk;
		Freelk = Freelk->next;
/* eprint("NEWLK IS REUSING Freelk = %ld\n",lk); */
		goto getout;
	}
	if ( used == ALLOCLK ) {
		used = 0;
		lastlk = (Lknode*) kmalloc(ALLOCLK*sizeof(Lknode),"newlk");
/* eprint("NEWLK IS ALLOCATING lastlk = %ld\n",lastlk); */
	}
	used++;
	lk = lastlk++;
   getout:
	lk->name = nm;
	lk->owner = NULL;
	lk->next = NULL;
	lk->notify = NULL;
/* eprintf("NEWLK lk=%ld\n",lk); */
	return(lk);
}

void
unlinklk(Lknode *lk)
{
	Lknode *lk2, *prelk;
	for ( lk2=Toplk,prelk=NULL; lk2!=NULL && lk2!=lk; prelk=lk2,lk2=lk2->next )
		;
	if ( lk2 == NULL )
		execerror("Hey, unlinklk didn't find node!?");
	/* Remove it from the Toplk list */
	if ( prelk == NULL )
		Toplk = lk->next;
	else
		prelk->next = lk->next;
/* eprint("UNLINK lk=%ld\n",lk); */
	freelk(lk);
}

void
freelk(Lknode *lk)
{
	/* Add it to (head of) Freelk list */
/* eprint("kfree lk=%ld\n",lk); */
	lk->next = Freelk;
	Freelk = lk;
}

Lknode *
findtoplk(Symstr nm)
{
	Lknode *lk;

	for ( lk=Toplk; lk!=NULL; lk=lk->next ) {
		if ( nm == lk->name )
			return lk;
	}
	/* create a new one and add it to list */
	lk = newlk(nm);
	lk->next = Toplk;
	Toplk = lk;
	return(lk);
}

/* Unlock all locks held by a task */
void
unlocktid(Ktaskp t)
{
	Lknode *lk, *nextlk;
	Lknode *lk2, *nextlk2, *prelk2;

	for ( lk=Toplk; lk!=NULL; lk=nextlk ) {
		/* scan queued up locks */
		for ( prelk2=NULL,lk2=lk->notify; lk2!=NULL; lk2=nextlk2 ) {
			nextlk2 = lk2->notify;
			if ( lk2->owner == t ) {
				/* The lock isn't currently owned by this */
				/* task, but it's queued up to be owned. */
				/* So, we just remove it (there's no other */
				/* effect.) */
				if ( prelk2 == NULL )
					lk->notify = nextlk2;
				else
					prelk2->notify = nextlk2;
				freelk(lk2);
				/* don't change prelk2 */
			}
			else
				prelk2 = lk2;
		}
		/* now take a look at the current owner of the lock */
		nextlk = lk->next;
		if ( lk->owner == t )
			unlocklk(lk);
	}
}

/* Returns the restarted task, if any, caused by unlocking the lock. */
Ktaskp
unlocklk(Lknode *lk)
{
	Ktaskp t, rt;

	if ( lk->notify == NULL ) {
		/* No tasks are pending to get the lock. */
		lk->owner = NULL;
		rt = NULL;
		unlinklk(lk);
	}
	else {
		/* There's another task waiting for the lock. */
		Lknode *nextlk = lk->notify;

		t = nextlk->owner;	/* the task we will restart */

		/* Just shift the info from the notify lk into the head, */
		/* and then free the notify lk. */
		lk->notify = nextlk->notify;
		lk->owner = nextlk->owner;
		t->lock = lk;

		freelk(nextlk);

		if ( t->state != T_LOCKWAIT )
			execerror("In unlock(), tid=%ld should have been in 'lockwait' state, but was in state=%d!?",t->tid,t->state);

		restarttask(t);
		rt = t;
	}
	return(rt);
}

void
rmalllocks(void)
{
	Lknode *lk;

	while ( Toplk ) {
		lk = Toplk;
		Toplk = Toplk->next;
		freelk(lk);
	}
	Toplk = NULL;
}

Kobjectp Topobj = NULL;
Kobjectp Freeobj = NULL;
long Nextobjid = 1;

Kobjectp
newobj(long id,int complain)
{
	static Kobjectp lastobj;
	static int used = ALLOCOBJ;
	Kobjectp obj;

/* sprintf(Msg1,"newobject, id=%d complain=%d",id,complain); mdep_popup(Msg1); */
	if ( id == 0 ) {
		;	/* object $0 is like NULL */
	}
	else if ( complain ) {
		Kobjectp to;
		/* Make sure the requested id # isn't already in use. */
		for ( to=Topobj; to!=NULL; to=to->onext ) {
			if ( to->id == id )
				execerror("Hey, object id %ld is already in use!?",id);
		}
	}
	/* First check the free list and use those nodes, before using */
	/* the newly allocated stuff. */
	if ( Freeobj != NULL ) {
		obj = Freeobj;
		Freeobj = Freeobj->onext;
		goto getout;	/* obj is the value we're returning */
	}
	if ( used == ALLOCOBJ ) {
		used = 0;
		lastobj = (Kobject*) kmalloc(ALLOCOBJ*sizeof(Kobject),"newobj");
	}
	used++;
	obj = lastobj++;
	obj->symbols = newht(13);	/* only when first allocated */
    getout:
	obj->inheritfrom = NULL;
	obj->nextinherit = NULL;
	obj->children = NULL;
	obj->nextsibling = NULL;
	obj->id = id;
	if ( id >= Nextobjid )
		Nextobjid = id+1;
	obj->onext = Topobj;
	Topobj = obj;

/* sprintf(buff,"newobject end, id=%d",obj->id); mdep_popup(buff); */

	return(obj);
}

Kobjectp
findobjnum(long n)
{
	Kobjectp o;
/* sprintf(Msg1,"findobjnum start, n=%d",n); mdep_popup(Msg1); */
	for ( o=Topobj; o!=NULL; o=o->onext ) {
		if ( o->id == n ) {
/* sprintf(Msg1,"findobjnum found! n=%d",n); mdep_popup(Msg1); */
			return o;
		}
	}
/* sprintf(Msg1,"findobjnum didn't find ! n=%d",n); mdep_popup(Msg1); */
	return NULL;
}

void
unlinkobj(Kobjectp o)
{
	Kobjectp o2;
	Kobjectp preo;

	for ( o2=Topobj,preo=NULL; o2!=NULL && o2!=o; preo=o2,o2=o2->onext )
		;
	if ( o2 == NULL )
		execerror("Hey, unlinkobj didn't find object!?");
	/* Remove it from the Topobj list */
	if ( preo == NULL )
		Topobj = o->onext;
	else
		preo->onext = o->onext;
}

void
freeobj(Kobjectp o)
{
	/* children and inheritfrom objects are NOT freed, they */
	/* must be freed explicitly, in KeyKit-level code. */
	unlinkobj(o);
	o->id = -1;

	clearht(o->symbols);	/* but don't free table itself, it's reused */

/* sprintf(Msg1,"freeobj o->id=%d",o->id);popup(Msg1); */

#ifdef HACKHACKHACK
/* WARNING!  This is a hack to avoid re-using objects. */
/* We need reference counting!! */
	o->onext = Freeobj;
	Freeobj = o;
#endif
}

Dnode *Dnfree = NULL;

Dnode *
newdn(void)
{
	static Dnode *lastdn;
	static int used = ALLOCDN;

	/* First check the free list and use those nodes, before using */
	/* the newly allocated stuff. */
	if ( Dnfree != NULL ) {
		register Dnode *dn = Dnfree;
		Dnfree = Dnfree->next;
		dn->next = NULL;
		return(dn);
	}
	if ( used == ALLOCDN ) {
		used = 0;
		lastdn = (Dnode*) kmalloc(ALLOCDN*sizeof(Dnode),"newdn");
	}
	used++;
	lastdn->next = NULL;
	return(lastdn++);
}

void
freedn(Dnode *dn)
{
	dn->next = Dnfree;
	Dnfree = dn;
}

void
freednodes(Dnode *dn)
{
	register Dnode *nxtd;

	dummyset(nxtd);
	for ( ; dn!=NULL; dn=nxtd ) {
		nxtd = dn->next;
		freedn(dn);
	}
}

Datum
strdatum(char *s)
{
	Datum d;
	d.type = D_STR;
	d.u.str = s;
	return d;
}

Datum
dbldatum(double f)
{
	Datum d;
	d.type = D_DBL;
	d.u.dbl = (DBLTYPE) f;
	return d;
}

Datum
phrdatum(Phrasep p)
{
	Datum d;
	d.type = D_PHR;
	d.u.phr = p;
	return d;
}

Datum
codepdatum(Codep cp)
{
	Datum d;
	d.type = D_CODEP;
	d.u.codep = cp;
	return d;
}

Datum
framedatum(Datum *f)
{
	Datum d;
	d.type = D_FRM;
	d.u.frm = f;
	return d;
}

Datum
datumdatum(Datum *f)
{
	Datum d;
	d.type = D_DATUM;
	d.u.frm = f;
	return d;
}

Datum
notedatum(Noteptr n)
{
	Datum d;
	d.type = D_NOTE;
	d.u.note = n;
	return d;
}

Datum
symdatum(Symbolp s)
{
	Datum d;
	d.type = D_SYM;
	d.u.sym = s;
	return d;
}

Datum
fifodatum(Fifo *f)
{
	Datum d;
	d.type = D_FIFO;
	d.u.fifo = f;
	return d;
}

Datum
taskdatum(Ktaskp t)
{
	Datum d;
	d.type = D_TASK;
	d.u.task = t;
	return d;
}

Datum
arrdatum(Htablep arr)
{
	Datum d;
	d.type = D_ARR;
	d.u.arr = arr;
	return d;
}

Datum
objdatum(Kobjectp obj)
{
	Datum d;
	d.type = D_OBJ;
	d.u.obj = obj;
	return d;
}

int Codesize[9] = {
	0,	/* IC_NONE */
	5,	/* IC_NUM */
	8,	/* IC_STR */
	8,	/* IC_DBL */
	8,	/* IC_SYM */
	8,	/* IC_PHR */
	8,	/* IC_INST */
	1,	/* IC_FUNC */
	1	/* IC_BLTIN */
};

Unchar *
put_ipcode(Codep ip, Unchar *p)
{
	union ip_union u;
	u.ip = ip;
	*p++ = u.bytes[0];
	*p++ = u.bytes[1];
	*p++ = u.bytes[2];
	*p++ = u.bytes[3];
	*p++ = u.bytes[4];
	*p++ = u.bytes[5];
	*p++ = u.bytes[6];
	*p++ = u.bytes[7];
	return p;
}

Unchar *
put_funccode(BYTEFUNC func, Unchar *p)
{
	*p++ = (Unchar)(intptr_t)func;
	return p;
}

Unchar *
put_bltincode(Unchar bltin, Unchar *p)
{
	*p++ = bltin;
	return p;
}

Unchar *
put_strcode(Symstr str, Unchar *p)
{
	union str_union u;
	u.str = str;
	*p++ = u.bytes[0];
	*p++ = u.bytes[1];
	*p++ = u.bytes[2];
	*p++ = u.bytes[3];
	*p++ = u.bytes[4];
	*p++ = u.bytes[5];
	*p++ = u.bytes[6];
	*p++ = u.bytes[7];
	return p;
}

Unchar *
put_dblcode(DBLTYPE dbl, Unchar *p)
{
	union dbl_union u;
	u.dbl = dbl;
	*p++ = u.bytes[0];
	*p++ = u.bytes[1];
	*p++ = u.bytes[2];
	*p++ = u.bytes[3];
	*p++ = u.bytes[4];
	*p++ = u.bytes[5];
	*p++ = u.bytes[6];
	*p++ = u.bytes[7];
	return p;
}

Unchar *
put_numcode(long num, Unchar *p)
{
	Unchar *tp;

#ifdef FFF
fprintf(FF,"put_numcode num=%d\n",num);
#endif
	tp = varinum_put(num,p);
	return tp;
}

Unchar *
put_symcode(Symbolp sym, Unchar *p)
{
	union sym_union u;
	u.sym = sym;
	*p++ = u.bytes[0];
	*p++ = u.bytes[1];
	*p++ = u.bytes[2];
	*p++ = u.bytes[3];
	*p++ = u.bytes[4];
	*p++ = u.bytes[5];
	*p++ = u.bytes[6];
	*p++ = u.bytes[7];
	return p;
}

Unchar *
put_phrcode(Phrasep phr, Unchar *p)
{
	union phr_union u;
	u.phr = phr;
	*p++ = u.bytes[0];
	*p++ = u.bytes[1];
	*p++ = u.bytes[2];
	*p++ = u.bytes[3];
	*p++ = u.bytes[4];
	*p++ = u.bytes[5];
	*p++ = u.bytes[6];
	*p++ = u.bytes[7];
	return p;
}

Symstr
scan_strcode(Unchar **pp)
{
	union str_union u;
	Unchar *p = *pp;
	u.bytes[0] = *p++;
	u.bytes[1] = *p++;
	u.bytes[2] = *p++;
	u.bytes[3] = *p++;
	u.bytes[4] = *p++;
	u.bytes[5] = *p++;
	u.bytes[6] = *p++;
	u.bytes[7] = *p++;
	*pp = p;
	return u.str;
}

Symbolp
scan_symcode(Unchar **pp)
{
	union sym_union u;
	register Unchar *p = *pp;
	u.bytes[0] = *p++;
	u.bytes[1] = *p++;
	u.bytes[2] = *p++;
	u.bytes[3] = *p++;
	u.bytes[4] = *p++;
	u.bytes[5] = *p++;
	u.bytes[6] = *p++;
	u.bytes[7] = *p++;
	*pp = p;
	return u.sym;
}

DBLTYPE
scan_dblcode(Unchar **pp)
{
	union dbl_union u;
	Unchar *p = *pp;
	u.bytes[0] = *p++;
	u.bytes[1] = *p++;
	u.bytes[2] = *p++;
	u.bytes[3] = *p++;
	u.bytes[4] = *p++;
	u.bytes[5] = *p++;
	u.bytes[6] = *p++;
	u.bytes[7] = *p++;
	*pp = p;
	return u.dbl;
}

Phrasep
scan_phrcode(Unchar **pp)
{
	union phr_union u;
	Unchar *p = *pp;
	u.bytes[0] = *p++;
	u.bytes[1] = *p++;
	u.bytes[2] = *p++;
	u.bytes[3] = *p++;
	u.bytes[4] = *p++;
	u.bytes[5] = *p++;
	u.bytes[6] = *p++;
	u.bytes[7] = *p++;
	*pp = p;
	return u.phr;
}

Codep
scan_ipcode(Unchar **pp)
{
	union ip_union u;
	Unchar *p = *pp;
	u.bytes[0] = *p++;
	u.bytes[1] = *p++;
	u.bytes[2] = *p++;
	u.bytes[3] = *p++;
	u.bytes[4] = *p++;
	u.bytes[5] = *p++;
	u.bytes[6] = *p++;
	u.bytes[7] = *p++;
	*pp = p;
	return u.ip;
}

long
nparamsof(Codep cp)
{
	SCAN_BLTINCODE(cp);
	return scan_numcode(&cp);
}

Symbolp
symof(Codep cp)
{
	SCAN_BLTINCODE(cp);
	scan_numcode(&cp);
	return scan_symcode(&cp);
}

long
nlocalsof(Codep cp)
{
	SCAN_BLTINCODE(cp);
	scan_numcode(&cp);
	scan_symcode(&cp);
	return scan_numcode(&cp);
}

Codep
firstinstof(Codep cp)
{
	SCAN_BLTINCODE(cp);
	scan_numcode(&cp);
	scan_symcode(&cp);
	scan_numcode(&cp);
	return cp;
}

Unchar *
varinum_put(long value,Unchar *p)
{
	int sign;

	if ( value > 0 )
		sign = 0;
	else {
		sign = 0x40;	/* this bit in the first byte indicates sign */
		value = -value;
	}
	if ( value < 64 ) {
		*p++ = sign | (int)value;
	}
	else {
		unsigned long buffer;

		*p++ = 0x80 | sign | 0x3f ;

		/* The extended values use the Standard MIDI File's */
		/* variable-length number convention. */
		buffer = value & 0x7f;
		while ((value >>= 7) > 0) {
			buffer <<= 8;
			buffer |= 0x80;
			buffer += (value & 0x7f);
		}

		for ( ;; ) {
			*p++ = (int)(buffer&0xff);
			if (buffer & 0x80)
				buffer >>= 8;
			else
				break;
		} 
	}
	return p;
}

int
varinum_size(long value)
{
	int sign;
	int sz = 0;

	if ( value > 0 )
		sign = 0;
	else {
		sign = 0x40;	/* this bit in the first byte indicates sign */
		value = -value;
	}
	if ( value < 64 )
		sz++;
	else {
		unsigned long buffer;

		sz++;

		/* The extended values use the Standard MIDI File's */
		/* variable-length number convention. */
		buffer = value & 0x7f;
		while ((value >>= 7) > 0) {
			buffer <<= 8;
			buffer |= 0x80;
			buffer += (value & 0x7f);
		}

		for ( ;; ) {
			sz++;
			if (buffer & 0x80)
				buffer >>= 8;
			else
				break;
		} 
	}
	return sz;
}

long
scan_numcode(Unchar **pp)
{
	long value;
	int c;
	int sign;
	int b;

	b = *(*pp)++;

	/* check for common case (small positive) with 1 test */
	if ( (b & 0xc0) == 0 ) {
		/* value is correct as-is */
		return (long)b;
	}
	else if ( (b & 0x80) == 0 ) {
		/* not extended, the value fits within 1 byte */
		if ( b & 0x40 )
			value = - (b & 0x3f);
		else
			value = b & 0x3f;
	}
	else {
		if ( b & 0x40 )
			sign = -1;
		else
			sign = 1;
		value = 0;
		do {
			c = *(*pp)++;
			value = (value << 7) + (c & 0x7f);
		} while (c & 0x80);
		value *= sign;
	}
	return (value);
}

Unchar B___;	/* temp for SCAN_NUMCODE macro */

/* In scan_numcode1, the first byte is already read and checked for the */
/* 1-byte small-positive case. */
long
scan_numcode1(Unchar **pp,int b)
{
	long value;
	int c;
	int sign;

	if ( (b & 0x80) == 0 ) {
		/* not extended, the value fits within 1 byte */
		if ( b & 0x40 )
			value = - (b & 0x3f);
		else
			value = b & 0x3f;
	}
	else {
		if ( b & 0x40 )
			sign = -1;
		else
			sign = 1;
		value = 0;
		do {
			c = *(*pp)++;
			value = (value << 7) + (c & 0x7f);
		} while (c & 0x80);
		value *= sign;
	}
	return (value);
}

#ifdef MDEP_OSC_SUPPORT

#define MAXBLOBSIZE 8192

void
osc_padit(char *msg,int msgsize,int *sofarp, int topad)
{
	while ( topad-- > 0 && msgsize > *sofarp ) {
		msg[(*sofarp)++] = '\0';
	}
}

void
osc_pack_str(char *msg,int msgsize,int *sofarp, char *s)
{
	int cnt = 0;
	int c;

	while ( (c=*s++) != '\0' && msgsize > *sofarp ) {
		msg[(*sofarp)++] = c;
		cnt++;
	}
	osc_padit(msg,msgsize,sofarp,4-cnt%4);
}

void
osc_pack_int(char *msg,int msgsize,int *sofarp, int v)
{
	union {
		char b[4];
		int i;
	} u;

	u.i = v;
	/* Should really use htonl or something */
	msg[(*sofarp)++] = u.b[3];
	msg[(*sofarp)++] = u.b[2];
	msg[(*sofarp)++] = u.b[1];
	msg[(*sofarp)++] = u.b[0];
}

void
osc_pack_dbl(char *msg,int msgsize,int *sofarp, DBLTYPE v)
{
	union {
		char b[4];
		float d;
	} u;

	u.d = v;
	/* Should really use htonl or something */
	msg[(*sofarp)++] = u.b[3];
	msg[(*sofarp)++] = u.b[2];
	msg[(*sofarp)++] = u.b[1];
	msg[(*sofarp)++] = u.b[0];
}

char *
osc_scanstring(char **buff, int *buffsize)
{
	int totalcnt = 0;
	char *buff0 = *buff;
	int buffsize0 = *buffsize;
	int mod4;

	while ( **buff != '\0' && totalcnt < buffsize0 ) {
		(*buff)++;
		(*buffsize)--;
		totalcnt++;
	}
	if ( **buff != '\0' ) {
		tprint("OSC parser did not find ending 0 on string.");
		return "";
	}

	(*buff)++;
	(*buffsize)--;
	totalcnt++;

	mod4 = totalcnt % 4;
	if ( mod4 ) {
		int n;
		for ( n=4-mod4; n>0; n-- ) {
			if ( **buff != '\0' ) {
				tprint("Unexpected non-0 (0x%02x) "
					"while scanning osc string?",**buff);
			} 
			(*buff)++;
		}
	}
	return buff0;
}

int
osc_scanint(char **buff, int *buffsize)
{
	int i;

	i = my_ntohl(*((int *)(*buff)));
	(*buff) += 4;
	*buffsize -= 4;
	return i;
}

void
osc_scantimetag(char **buff, int *buffsize, int *secs, int *fract)
{
	*secs = my_ntohl(*((int *)(*buff)));
	(*buff) += 4;
	*buffsize -= 4;

	*fract = my_ntohl(*((int *)(*buff)));
	(*buff) += 4;
	*buffsize -= 4;
}

int
osc_scanblob(char **buff, int *buffsize, char *blobbuff, int blobbuffsize)
{
	int n;
	int blobsz;
	int copied = 0;

	blobsz = my_ntohl(*((int *)(*buff)));
	(*buff) += 4;
	*buffsize -= 4;

	// tprint("   SCANBLOB blobsz = %d\n",blobsz);
	if ( blobsz >= MAXBLOBSIZE ) {
		tprint("   BLOB too big! (%d)\n",blobsz);
		return(0);
	}

	for ( n=0; n<blobsz; n++ ) {
		if ( n < blobbuffsize ) {
			*blobbuff++ = **buff;
			copied++;
		}
		(*buff)++;
		(*buffsize)--;
	}
	return copied;
}

float
osc_scanfloat(char **buff, int *buffsize)
{
	float *floatp;
	int i;

	i = my_ntohl(*((int *)(*buff)));
	(*buff) += 4;
	*buffsize -= 4;
	floatp = ((float *) (&i));
	return *floatp;
}

Datum
osc_array(char *buff, int buffsize, int used)
{
	Datum d;
	char *p;
	char *q;
	int arri = 0;
	int n;
	DBLTYPE f;
	char blobbuff[MAXBLOBSIZE];
	int blobbuffsz = sizeof(blobbuff);
	Datum dindex;

	// tprint("\n\nOSC_ARRAY start, buffsize=%d\n",buffsize);
	if ( *buff == '/' ) {
		d = newarrdatum(used,3);
		// keyerrfile("buff=%ld\n",(long)buff);
		p = osc_scanstring(&buff,&buffsize);
		setarraydata(d.u.arr,numdatum(arri++),
			strdatum(uniqstr(p)));
		p = osc_scanstring(&buff,&buffsize);
		if ( *p != ',' ) {
			tprint("OSC parser did not find type tag string.");
		} else {
			for ( p++; *p!='\0'; p++ ) {
				dindex = numdatum(arri++);
				switch(*p){
				case 'i':
					n = osc_scanint(&buff,&buffsize);
					setarraydata(d.u.arr,dindex,
						numdatum(n));
					break;
				case 'f':
					f = osc_scanfloat(&buff,&buffsize);
					setarraydata(d.u.arr,dindex,
						dbldatum(f));
					break;
				case 's':
					q = osc_scanstring(&buff,&buffsize);
					setarraydata(d.u.arr,dindex,
						strdatum(uniqstr(q)));
					break;
				case 'b':
					if ( osc_scanblob(&buff,&buffsize,blobbuff,blobbuffsz) < 0 ) {
						q = "badblob";
					} else {
						q = "goodblob";
					}
					setarraydata(d.u.arr,dindex,
						strdatum(uniqstr(q)));
					break;
				default:
					arri--;
					tprint("OSC parser found bad char (0x%02x) in type tag string.",*p);
				}
			}
		}
	} else if ( *buff == '#' ) {
		d = newarrdatum(used,3);
		if ( strncmp(buff,"#bundle",7) != 0 ) {
			tprint("OSC parser found bad bundle header?");
		} else {
			int secs;
			int fract;
			int sz;
			int blobnum = 0;
			int cnt = 0;
			Datum elem;

			/* Skip past #bundle - OSC spec says it's 8 bytes */
			buff += 8;
			buffsize -= 8;

			osc_scantimetag(&buff,&buffsize,&secs,&fract);
			// tprint("OSC bundle START, secs=%d fract=%d\n",secs,fract);

			while ( buffsize > 0 ) {
				if ( cnt > 100 ) {
					tprint("OSC bundle has more than 100 elements!?  Something's probably wrong.\n");
					break;
				}
				sz = osc_scanblob(&buff,&buffsize,blobbuff,blobbuffsz);
				// tprint("OSC bundle, read blob %d, sz = %d, buffsize is now %d\n",blobnum++,sz,buffsize);
				if ( sz < 0 ) {
					tprint("Bad OSC bundle!?\n");
					break;
				}
				if ( sz > 0 ) {
					// tprint("Good OSC bundle part, sz=%d\n",sz);
					elem = osc_array(blobbuff, sz, 1);
					setarraydata(d.u.arr,numdatum(cnt),elem);
					cnt++;
				}
			}
			setarraydata(d.u.arr,Str_elements,numdatum(cnt));
			setarraydata(d.u.arr,Str_seconds,numdatum(secs));
			setarraydata(d.u.arr,Str_fraction,numdatum(fract));

			// tprint("OSC bundle END\n");
		}
	} else {
		tprint("Bad OSC data.\n");
	}
	return d;
}
#endif
