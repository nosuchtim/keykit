/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

/*
 * Convert a keykit phrase to Standard MIDI File.
 */

#define OVERLAY2

#include <stdio.h>
#include <errno.h>
#include "key.h"
#include "keymidi.h"

#define MYMETATEMPO	-1
#define MYMETATIMESIG	-2
#define MYMETAKEYSIG	-3
#define MYMETASEQNUM	-4
#define MYMETASMPTE	-5
#define MYCHANPREFIX	-6

static Noteptr Pend = NULL;		/* list of pending note-offs */
static FILE *Trktmp;
static char Tmpfname[16];	/* enough space for "#xxxxx.tmp" */
static long Trksize;
static FILE *Outf;
static double Clickfactor = 1.0;
static int Laststat = 0;	/* NOTEON, NOTEOFF, PRESSURE, etc. */

static void
trackbyte(int c)	/* must be used by everything that writes track data */
{
	c = c & 0xff;
	putc(c,Trktmp);
	Trksize++;
}

static void
writevarinum (register long value)
{
	unsigned char buffer[8];
	int bi = 0;

	buffer[bi] = (unsigned char)(value & 0x7f);
	while ((value >>= 7) > 0 && bi < (int)(sizeof(buffer)-1) ) {
		buffer[++bi] = 0x80 | (unsigned char)(value & 0x7f);
	}
	while ( bi >= 0 ) {
		trackbyte((int)(buffer[bi--]&0xff));
	} 
}

static void
putdelta(long clicks)
{
	if ( clicks < 0 ) {
		tprint("midifile: negative time (%ld) forced to 0!",clicks);
		clicks = 0;
	}
	/* should do some scaling here? */
	writevarinum ((long)(clicks*Clickfactor + 0.5));
}

static void
write16bit(int val)
{
	putc( (val>>8) & 0xff, Outf );
	putc( val & 0xff, Outf );
}

static void
write32bit(long val)
{
	putc( (int)((val>>24) & 0xff), Outf );
	putc( (int)((val>>16) & 0xff), Outf );
	putc( (int)((val>>8) & 0xff), Outf );
	putc( (int)(val & 0xff), Outf );
}

static void
putnote(unsigned int c,unsigned int p,unsigned int v)
{
	/* Use running status (ie. omit status byte) when possible */
	if ( (int)c != Laststat ) {
		Laststat = c;
		trackbyte((int)c);
	}
	trackbyte((int)p);
	trackbyte((int)v);
}

static char *
keytextmess(char *b,int lng)
{
	if ( lng <= 3 )
		return(NULL);
	if ( (b[0]&0xff) != 0xf0 )
		return(NULL);
	if ( (b[1]&0xff) != 0x00 )
		return(NULL);
	if ( (b[2]&0xff) != 0x7f )
		return(NULL);
	return(&b[3]);
}

static int
metatype(char *s)
{
	/* Most of the entries in this table are the standard MIDI file */
	/* meta 'text' messages, the last few are ones that I've made up */
	/* to represent the other meta-type messages. */
	static struct typeinfo {
		char *type_name;
		int type_val;
	} ttype[] = {
		{ METATEXT,		1 },
		{ METACOPYRIGHT,		2 },
		{ METASEQUENCE,		3 },
		{ METAINSTRUMENT,		4 },
		{ METALYRIC,		5 },
		{ METAMARKER,		6 },
		{ METACUE,		7 },
		{ METAUNRECOGNIZED,	8 },
		{ "Tempo",		MYMETATEMPO },
		{ "Timesig",		MYMETATIMESIG },
		{ "Keysig",		MYMETAKEYSIG },
		{ "Seqnum",		MYMETASEQNUM },
		{ "Smpte",		MYMETASMPTE },
		{ "Channelprefix",	MYCHANPREFIX },
		{ NULL, 0 }
	};
	int n;
	char *p;

	for ( n=0; (p=ttype[n].type_name) != NULL; n++ ) {
		if ( strcmp(s,p) == 0 )
			return(ttype[n].type_val);
	}
	return 0;
}

static void
putmetatext(type,contents)  /* generate a standard midifile meta text message */
int type;
char *contents;	/* ends with 0xf7, NOT 0x00 */
{
	char *q;
	int lng;

	trackbyte(0xff);
	trackbyte(type);
	/* see how long it is. */
	for ( lng=0,q=contents; ((*q++)&0xff) != 0xf7 ; lng++ )
		;
	/* write length, and then text */
	writevarinum((long)lng);
	while ( ((*contents)&0xff) != 0xf7 )
		trackbyte(*contents++);
}

static void
mftempo(long microsecs)
{
	trackbyte(0xff);
	trackbyte(0x51);
	trackbyte(0x03);
	trackbyte( (int)((microsecs>>16) & 0xff) );
	trackbyte( (int)((microsecs>>8) & 0xff) );
	trackbyte( (int)(microsecs & 0xff) );
}

static void
timesig(int nn, int dd, int cc, int bb)
{
	trackbyte(0xff);
	trackbyte(0x58);
	trackbyte(0x04);
	trackbyte(nn);
	trackbyte(dd);
	trackbyte(cc);
	trackbyte(bb);
}

static void
keysig(int sf,int mi)
{
	trackbyte(0xff);
	trackbyte(0x59);
	trackbyte(0x02);
	trackbyte(sf);
	trackbyte(mi);
}

static void
seqnum(int n)
{
	trackbyte(0xff);
	trackbyte(0x00);
	trackbyte(0x02);
	write16bit(n);
}

static void
chanprefix(int n)
{
	trackbyte(0xff);
	trackbyte(0x20);
	trackbyte(0x01);
	trackbyte(n);
}

static void
smpte(int hr, int mn, int se, int fr, int ff)
{
	trackbyte(0xff);
	trackbyte(0x54);
	trackbyte(0x05);
	trackbyte(hr);
	trackbyte(mn);
	trackbyte(se);
	trackbyte(fr);
	trackbyte(ff);
}

static void
putmymeta(int type, char *contents)
{
	switch(type){
	case MYMETATEMPO:
		{ long microsecs;
		if ( sscanf(contents,"%ld",&microsecs) != 1 )
			eprint("Bad 'Tempo=...' message!?\n");
		else
			mftempo(microsecs);
		}
		break;
	case MYMETATIMESIG:
		{ int nn,denom,cc,bb;
		if ( sscanf(contents,"%d/%d,%d,%d",&nn,&denom,&cc,&bb) != 4 )
			eprint("Bad 'Timesig=...' message!?\n");
		else {
			int dd = 0;
			while ( denom > 1 ) {
				dd++;
				denom /= 2;
			}
			timesig(nn,dd,cc,bb);
		}
		}
		break;
	case MYMETAKEYSIG:
		{ int sf,mi;
		if ( sscanf(contents,"%d,%d",&sf,&mi) != 2 )
			eprint("Bad 'Keysig=...' message!?\n");
		else
			keysig(sf,mi);
		}
		break;
	case MYMETASEQNUM:
		{ int n;
		if ( sscanf(contents,"%d",&n) != 1 )
			eprint("Bad 'Seqnum=...' message!?\n");
		else
			seqnum(n);
		}
		break;
	case MYMETASMPTE:
		{ int hr,mn,se,fr,ff;
		if ( sscanf(contents,"%d,%d,%d,%d,%d",&hr,&mn,&se,&fr,&ff) != 5 )
			eprint("Bad 'Smpte=...' message!?\n");
		else
			smpte(hr,mn,se,fr,ff);
		}
		break;
	case MYCHANPREFIX:
		{ int n;
		if ( sscanf(contents,"%d",&n) != 1 )
			eprint("Bad 'Channelprefix=...' message!?\n");
		else
			chanprefix(n);
		}
		break;
	}
}

static int
metamess(char *text)
{
	char *p;
	int type;

	/* look for the '=' */
	for ( p=text; *p!='=' && ((*p)&0xff) != 0xf7; p++ )
		;
	if ( *p != '=' )
		return(0);
	*p = '\0';
	type = metatype(text);
	*p++ = '=';

	if ( type == 0 )
		return(0);	/* unrecognized */

	if ( type > 0 )
		putmetatext(type,p);
	else
		putmymeta(type,p);
	return(1);
}

static void
putbytes(Noteptr nt)
{
	Unchar* b = ptrtobyte(nt,0);
	int lng = ntbytesleng(nt);
	int expecting = 0;
	unsigned char b1;
	int n;

	b1 = *b;
	switch ( b1 & 0xf0 )  {
	case NOTEON:
	case NOTEOFF:
	case PRESSURE:
	case CONTROLLER:
	case PITCHBEND:
		expecting = 3;
		break;
	case PROGRAM:
	case CHANPRESSURE:
		expecting = 2;
		break;
	}

	if ( expecting!=0 && expecting==lng ) {
		/* see if we can use running status, ie. omit status byte */
		if ( (int)b1 != Laststat )
			trackbyte((int)b1);
		trackbyte((int)(*(b+1)));
		if ( expecting > 2 )
			trackbyte((int)(*(b+2)));
	}
	else {
		/* See if it's a keykit 'text' message, which is used */
		/* to represent meta messages. */

		char *text = keytextmess((char *)b,lng);

		if ( text!=NULL && metamess(text)!=0 ) {
			/* metamess() outputs the message as a side-effect. */
			dummyusage(text);
		} else if ( *b == 0xf0 ) {
			/* For a sysex, choose one of two ways of putting */
			/* it out */
			if ( *Mfsysextype == 0 ) {
				trackbyte(0xf7);
				writevarinum((long)lng);
				for ( n=0; lng-- > 0; n++ )
					trackbyte((int)(*(b+n)));
			} else {
				trackbyte(0xf0);
				writevarinum((long)(lng-1));
				lng--;
				for ( n=1; lng-- > 0; n++ )
					trackbyte((int)(*(b+n)));
			}
		} else {
			/* For messages that we don't recognize otherwise, */
			/* we use the 'f7' escape mechanism in the midi file */
			/* standard to put out arbitrary bytes. */
			trackbyte(0xf7);
			writevarinum((long)lng);
			for ( n=0; lng-- > 0; n++ )
				trackbyte((int)(*(b+n)));
		}
	}
	Laststat = b1;
}

static void
header(int format,int ntrks, int division)
{
	fputs("MThd",Outf);
	write32bit(6L);
	write16bit(format);
	write16bit(ntrks);
	write16bit(division);
}

static int
inittrack(void)
{
	OPENBINFILE(Trktmp,Tmpfname,"w");
	if ( Trktmp == NULL ) {
		tprint("Can't open midifile for writing - '%s' (%s)",
			Tmpfname,strerror(errno));
		return 1;
	}
	Trksize = 0;
	Pend = NULL;
	return 0;
}

static int
dumptrack(void)
{
	int c;

	myfclose(Trktmp);
	OPENBINFILE(Trktmp,Tmpfname,"r");
	if ( Trktmp == NULL ) {
		tprint("Can't re-open midifile for dumping - '%s' (%s)",
			Tmpfname,strerror(errno));
		return 1;
	}
	fputs("MTrk",Outf);
	write32bit(Trksize);
	while ( (c=getc(Trktmp)) != EOF )
		putc(c,Outf);
	myfclose(Trktmp);
	return 0;
}

static void
endoftrack(void)
{
	trackbyte(0xff);
	trackbyte(0x2f);
	trackbyte(0x00);
}

static int
tempotrack(void)
{
	if ( inittrack() != 0 )
		return 1;
	putdelta(0L);
	timesig(4,2,24,8);
	putdelta(0L);
	mftempo(Tempo);
	putdelta(0L);
	endoftrack();
	if ( dumptrack() != 0 )
		return 1;
	return 0;
}

static void
setfactor(int div)
{
	double d1 = (double)div;
	double d2 = (double)DEFCLICKS;
	Clickfactor = d1 / d2;
	if ((div>DEFCLICKS && (((int)Clickfactor)*DEFCLICKS)!=div )
	    ||(div<DEFCLICKS && (DEFCLICKS/div)*div!=DEFCLICKS)) {
		eprint("Warning: division (%d) doesn't evenly divide DEFCLICKS (%d)\n",div,DEFCLICKS);
	}
}

static void
maketemp()	/* find a temporary file name (inefficient but portable) */
{
	int n = 0;

	do {
		sprintf(Tmpfname,"#%05d.tmp",++n);
	} while ( exists(Tmpfname) );
}

static void
rmtemp(void)
{
	(void) unlink(Tmpfname);
}

static void
addpend(Noteptr n)
{
	Noteptr newp, pp;
	Noteptr lastp = NULL;

	newp = ntcopy(n);
	timeof(newp) = endof(n);
	typeof(newp) = NT_OFF;

	/* insertion sort into existing list */
	for ( pp=Pend; pp!=NULL; pp=nextnote(pp) ) {
		if ( ntcmporder(pp,newp) > 0 )
			break;
		lastp = pp;
	}

	nextnote(newp) = pp;	/* pp may be NULL */

	if ( pp == Pend )
		Pend = newp;
	else
		nextnote(lastp) = newp;
}

static void
phtrack(Phrasep p)
{
	Noteptr n = firstnote(p);
	long lasttime = 0;
	long toend;

	while ( n != NULL || Pend != NULL ) {

		/* Put out whichever is earlier - the top pending note-off or */
		/* the start of the next note.  If they're both at the same */
		/* time, the Pending note-off's get preference. */

		if ( n==NULL || (Pend!=NULL && timeof(Pend) <= timeof(n) ) ) {

			/* put out the top pending note-off */

			Noteptr nextp = nextnote(Pend);

			putdelta(timeof(Pend)-lasttime);

			lasttime = timeof(Pend);

			/* To distinguish this kind of note-off from a */
			/* note-off with a release velocity, we use the */
			/* common method of a note-on with a 0 volume. */

			if ( *Midifilenoteoff != 0 )
				putnote(NOTEOFF | chanof(Pend), pitchof(Pend), 0);
			else
				putnote(NOTEON | chanof(Pend), pitchof(Pend), 0);

			ntfree(Pend);
			Pend =  nextp;
		}
		else {
			/* put out the next note in the phrase */

			putdelta(timeof(n)-lasttime);
			lasttime = timeof(n);
			if ( typeof(n) == NT_BYTES || typeof(n) == NT_LE3BYTES) {
				putbytes(n);
			}
			else {
				int high;

				/* typeof(n) is NT_NOTE, NT_ON, or NT_OFF */
				if ( typeof(n) == NT_OFF )
					high = NOTEOFF;
				else
					high = NOTEON;
				putnote( high | chanof(n),pitchof(n),volof(n));

				/* For a full note, we add the note-off */
				/* to the Pend'ing list */
				if ( typeof(n) == NT_NOTE )
					addpend(n);
			}
			n = nextnote(n);
		}
	}
	toend = p->p_leng - lasttime;
	if ( toend < 0 )
		toend = 0;
	/* Put out the end-of-track meta message that indicates */
	/* the length of the track. */
	putdelta(toend);
	endoftrack();
}

static int
dophrase(Phrasep p)
{
	if ( inittrack() != 0 )
		return 1;
	phtrack(p);
	if ( dumptrack() != 0 )
		return 1;
	return 0;
}

void
arrtomf(Htablep arr,char *fname)
{
	Datum *alist;
	int type, ntracks, n;
	Phrasep ph;
	int div = (int)(*Clicks);
	int err = 0;

	if ( stdioname(fname) )
		Outf = stdout;
	else {
		if ( *fname == '\0' )
			execerror("Invalid (null) filename given to midifile");
		OPENBINFILE(Outf,fname,"w");
		if ( Outf == NULL ) {
			execerror("Can't open midifile for writing - '%s' (%s)",
				fname,strerror(errno));
		}
	}

	alist = arrlist(arr,&ntracks,1);

	maketemp();
	setfactor(div);

	type = ntracks>1 ? 1 : 0;

	if ( *Tempotrack == 0 )
		header( type, ntracks, div);
	else {
		/* force it to be type 1, and add tempo track */
		header( 1, ntracks+1, div );
		err = tempotrack();
		if ( err != 0 )
			goto getout;
	}
	for ( n=0; n<ntracks; n++ ) {
		Symbol *as = arraysym(arr,alist[n],H_LOOK);
		Datum *dp = symdataptr(as);

		if ( dp->type != D_PHR ) {
			err = 1;
			tprint("midifile: non-phrase found in array!");
			goto getout;
		}
		ph = dp->u.phr;
		Laststat = -1;
		err = dophrase(ph);
		if ( err != 0 )
			goto getout;
	}
    getout:

	rmtemp();
	if ( Outf != stdout )
		myfclose(Outf);
	if ( err != 0 )
		execerror("midifile: error while generating file=%s",fname);
}
