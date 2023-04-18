/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

/*
 * Read a Standard MIDI File.
 */

#include "key.h"
#include "keymidi.h"
#include "mf.h"

int Mf_nomerge = 0;		/* 1 => continue'ed system exclusives are */
				/* not collapsed. */
long Mf_currtime = 0L;		/* current time in delta-time units */
int Mf_skipinit = 1;		/* 1 if initial garbage should be skipped */

#define finished(n) durof(n)=0

static FILE *Mf;
static long Mf_toberead = 0L;
static int Tracknum;
static Phrasep Noteq;
static Phrasep Currph;
static int Numq = 0;
static double Clickfactor = 1.0;
static Htablep Mfarr;
static int Mformat;

static void
mferror(char *s)
{
	execerror(s);
}

static void
mfwarning(char *s)
{
	warning(s);
}

int
mgetc(void)
{
	return getc(Mf);
}

/* read a single character and abort on EOF */
static int
egetc(void)
{
	int c = mgetc();

	if ( c == EOF )
		mferror("premature EOF");
	Mf_toberead--;
	return(c);
}

/* readvarinum - read a varying-length number */

static long
readvarinum(void)
{
	long value;
	int c;

	c = egetc();
	value = c;
	if ( c & 0x80 ) {
		value &= 0x7f;
		do {
			c = egetc();
			value = (value << 7) + (c & 0x7f);
		} while (c & 0x80);
	}
	return (value);
}

static long
to32bit(int c1,int c2,int c3,int c4)
{
	long value = 0L;

	value = (c1 & 0xff);
	value = (value<<8) + (c2 & 0xff);
	value = (value<<8) + (c3 & 0xff);
	value = (value<<8) + (c4 & 0xff);
	return (value);
}

static int
to16bit(int c1,int c2)
{
	return ((c1 & 0xff ) << 8) + (c2 & 0xff);
}

static long
read32bit(void)
{
	int c1, c2, c3, c4;

	c1 = egetc();
	c2 = egetc();
	c3 = egetc();
	c4 = egetc();
	return to32bit(c1,c2,c3,c4);
}

static int
read16bit(void)
{
	int c1, c2;
	c1 = egetc();
	c2 = egetc();
	return to16bit(c1,c2);
}

/* The code below allows collection of a system exclusive message of */
/* arbitrary length.  The Msg1buff is expanded as necessary.  The only */
/* visible data/routines are msginit(), msgadd(), msg(), msgleng(). */

#define MSGINCREMENT 128
static Unchar *Msg1buff = NULL;	/* message buffer */
static int Msg1alloc = 0;		/* Size of currently allocated Msg1 */
static int Msg1index = 0;	/* index of next available location in Msg1 */

static void
msginit(void)
{
	Msg1index = 0;
}

static Unchar *
msg(void)
{
	return(Msg1buff);
}

static int
msgleng(void)
{
	return(Msg1index);
}

static void
msgenlarge(void)
{
	Msg1alloc += MSGINCREMENT;
	Msg1buff = krealloc(Msg1buff,Msg1alloc,"msgenlarge");
}

static void
msgadd(int c)
{
	/* If necessary, allocate larger message buffer. */
	if ( Msg1index >= Msg1alloc )
		msgenlarge();
	Msg1buff[Msg1index++] = c;
}

/* read through the "MThd" or "MTrk" header string */
/* if skip is 1, we attempt to skip initial garbage. */
static int
readmt(char *s,int skip)
{
	int nread = 0;
	char b[4];
	char buff[32];
	int c;
	char *errmsg = "expecting ";

    retry:
	while ( nread<4 ) {
		c = mgetc();
		if ( c == EOF ) {
			strcpy(buff,"EOF while expecting ");
			strcat(buff,s);
			mfwarning(buff);
			return(EOF);
		}
		b[nread++] = c;
	}
	/* See if we found the 4 characters we're looking for */
	if ( s[0]==b[0] && s[1]==b[1] && s[2]==b[2] && s[3]==b[3] )
		return(0);
	if ( skip ) {
		/* If we are supposed to skip initial garbage, */
		/* try again with the next character. */
		b[0]=b[1];
		b[1]=b[2];
		b[2]=b[3];
		nread = 3;
		goto retry;
	}
	strcpy(buff,errmsg);
	strcat(buff,s);
	mferror(buff);
	return(0);
}

/* read a header chunk */
static int
readheader(void)
{
	int format, ntrks, division;

	if ( readmt("MThd",Mf_skipinit) == EOF )
		return(0);

	Mf_toberead = read32bit();
	format = read16bit();
	ntrks = read16bit();
	division = read16bit();

	k_header(format,ntrks,division);

	/* flush any extra stuff, in case the length of header is not 6 */
	while ( Mf_toberead > 0 )
		(void) egetc();
	return(ntrks);
}

static void
metaevent(int type)
{
	int leng = msgleng();
	Unchar *m = msg();

	switch  ( type ) {
	case 0x00:
		k_seqnum(to16bit((int)(m[0]),(int)(m[1])));
		break;
	case 0x01:	/* Text event */
	case 0x02:	/* Copyright notice */
	case 0x03:	/* Sequence/Track name */
	case 0x04:	/* Instrument name */
	case 0x05:	/* Lyric */
	case 0x06:	/* Marker */
	case 0x07:	/* Cue point */
	case 0x08:
	case 0x09:
	case 0x0a:
	case 0x0b:
	case 0x0c:
	case 0x0d:
	case 0x0e:
	case 0x0f:
		/* These are all text events */
		k_metatext(type,leng,m);
		break;
	case 0x20:	/* Channel prefix */
	case 0x21:	/* Supposedly some people mistakenly used 0x21 ? */
		k_chanprefix(m[0]);
		break;
	case 0x2f:	/* End of Track */
		/* k_eot(); */
		break;
	case 0x51:	/* Set tempo */
		k_tempo(to32bit(0,(int)m[0],(int)m[1],(int)m[2]));
		break;
	case 0x54:
		k_smpte(m[0],m[1],m[2],m[3],m[4]);
		break;
	case 0x58:
		k_timesig(m[0],m[1],m[2],m[3]);
		break;
	case 0x59:
		k_keysig(m[0],m[1]);
		break;
	case 0x7f:
		/* k_sqspecific(leng,m); */
		break;
	default:
		/* k_metamisc(type,leng,m); */
		break;
	}
}

static void
chanmessage(int status,int c1,int c2)
{
	int chan = status & 0xf;

	switch ( status & 0xf0 ) {
	case NOTEOFF:
		k_noteoff(chan,c1,c2);
		break;
	case NOTEON:
		k_noteon(chan,c1,c2);
		break;
	case PRESSURE:
		k_pressure(chan,c1,c2);
		break;
	case CONTROLLER:
		k_controller(chan,c1,c2);
		break;
	case PITCHBEND:
		k_pitchbend(chan,c1,c2);
		break;
	case PROGRAM:
		k_program(chan,c1);
		break;
	case CHANPRESSURE:
		k_chanpressure(chan,c1);
		break;
	}
}

static long
mfclicks(void)
{
	double clks = (double)Mf_currtime/Clickfactor;
	return((long)(clks+0.5)); /* round it */
}

/*ARGSUSED*/
void
k_header(int f,int n,int d)
{
	Mformat = f;
	Tracknum = 0;

	dummyusage(n);
	if ( (0x8000 & d) != 0 ) {
		/* It's SMPTE, frame-per-second and ticks per frame */
		int frames_per_second = (d >> 8) & 0x7f;
		int ticks_per_frame = d & 0xff;
		Clickfactor = ((double)frames_per_second * ticks_per_frame) / ((double)(*Clicks) * (1000000.0 / Tempo));
	} else {
		Clickfactor = (double)d / (double)(*Clicks);
	}

#ifdef WARNEVEN
	if ( (d>(*Clicks) && (((int)Clickfactor)*(*Clicks))!=d )
	    || (d<(*Clicks) && (Clicks/d)*d!=(*Clicks)))
		eprint("Warning: division (%d) doesn't evenly divide Clicks (%ld)\n",d,*Clicks);
#endif

}

void
k_starttrack(void)
{
	Symbolp se;
	Datum d, *dp;

	d = numdatum((long)(Tracknum++));
	se = arraysym(Mfarr,d,H_INSERT);
	clearsym(se);
	dp = symdataptr(se);
	*dp = phrdatum(newph(1));
	Currph = dp->u.phr;
}

/* output the top Noteq and remove it from the list */
void
putnfree(void)
{
	Noteptr n = firstnote(Noteq);
	Noteptr nxt = nextnote(n);

	setfirstnote(Noteq) = nxt; 	/* remove from list */
	if ( n == lastnote(Noteq) )
		lastnote(Noteq) = nxt;

	if ( durof(n) == UNFINISHED_DURATION )
		durof(n) = mfclicks() - timeof(n);

	ntinsert(n,Currph);
	/* DO NOT call ntfree(), since we've given the note away to Currph */
	Numq--;
}

void
putallnotes(void)
{
	while ( firstnote(Noteq) != NULL )
		putnfree();
	lastnote(Noteq) = NULL;
	Currph->p_leng = mfclicks();
}

void
k_endtrack(void)
{
	putallnotes();
}

void
k_noteon(int chan,int pitch,int vol)
{
	if ( vol == 0 ) {
		k_noteoff(chan,pitch,(int)(*Defrelease));
		return;
	}
	(void) queuenote(chan,pitch,vol,NT_ON);
}

Noteptr
queuenote(int chan,int pitch,int vol,int type)
{
	Noteptr n = newnt();
	typeof(n) = type;
	timeof(n) = mfclicks();
	setchanof(n) = chan;
	pitchof(n) = pitch;
	volof(n) = vol;
	durof(n) = UNFINISHED_DURATION;
	portof(n) = Defport;
	nextnote(n) = NULL;
	ntinsert(n,Noteq);
	Numq++;
	return n;
}

void
k_noteoff(int chan,int pitch,int vol)
{
	Noteptr n;

	/* find the first note-on (if any) that matches this one */
	for ( n=firstnote(Noteq); n!=NULL; n=nextnote(n) ) {
		if ( chanof(n)==chan
			&& (int)pitchof(n)==pitch
			&& typeof(n)==NT_ON ) {
			break;
		}
	}
	if ( n == NULL ) {
		/* it's an isolated note-off */
		n = queuenote(chan,pitch,vol,NT_OFF);
		finished(n);
	}
	else if ( *Onoffmerge == 0 && vol != (int)(*Defrelease) ) {
		/* If the note-off matches a previous note-on, but has a */
		/* non-default velocity, then we have to turn it into a */
		/* separate keykit note-off, instead of merging it with */
		/* the note-on into a single note. */
		Noteptr o = queuenote(chan,pitch,vol,NT_OFF);
		finished(o);
		finished(n);
	}
	else {
		/* A completed note. */
		typeof(n) = NT_NOTE;
		durof(n) = mfclicks() - timeof(n);

		/* If the MIDI File contains negative delta times (which */
		/* probably aren't legal!) the duration turns out to be */
		/* negative.  Here we deal with that. */
		if ( durof(n) < 0 ) {
			timeof(n) = timeof(n) + durof(n);
			durof(n) = - durof(n);
		}
	}

	/* Now start at the beginning of the list and put out any */
	/* notes we've completed.  This guarantees that the starting */
	/* times of the notes are in the proper (ie. monotonically */
	/* progressing) order. */

	while ( (n=firstnote(Noteq)) != NULL ) {
		/* quit when we get to the first unfinished note */
		if ( typeof(n)!=NT_BYTES && durof(n) == UNFINISHED_DURATION )
			break;
		putnfree();
	}
	/* If the number of notes int Noteq gets too big, then we're */
	/* probably suffering from a note-on that never had a note-off.*/
	/* Force it out. */
	if ( Numq > 1024 )
		putnfree();

}

void
k_pressure(int chan,int pitch,int press)
{
	threebytes(PRESSURE | chan,pitch,press);
}

void
k_controller(int chan,int control,int value)
{
	threebytes(CONTROLLER | chan,control,value);
}

void
k_pitchbend(int chan,int msb,int lsb)
{
	threebytes(PITCHBEND | chan,msb,lsb);
}

void
k_program(int chan,int program)
{
	twobytes(PROGRAM | chan,program);
}

void
k_chanpressure(int chan,int press)
{
	twobytes(CHANPRESSURE | chan,press);
}

void
threebytes(int c1,int c2,int c3)
{
	Unchar bytes[3];
	Noteptr n = newnt();
	timeof(n) = mfclicks();
	typeof(n) = NT_BYTES;
	bytes[0] = c1;
	bytes[1] = c2;
	bytes[2] = c3;
	messof(n) = savemess(bytes,3);
	portof(n) = Defport;
	nextnote(n) = NULL;
	ntinsert(n,Noteq);
	Numq++;
}

void
twobytes(int c1,int c2)
{
	Unchar bytes[2];
	Noteptr n = newnt();
	timeof(n) = mfclicks();
	typeof(n) = NT_BYTES;
	bytes[0] = c1;
	bytes[1] = c2;
	messof(n) = savemess(bytes,2);
	portof(n) = Defport;
	nextnote(n) = NULL;
	ntinsert(n,Noteq);
	Numq++;
}

void
queuemess(Unchar *mess,int leng)
{
	Noteptr n = newnt();
	timeof(n) = mfclicks();
	typeof(n) = NT_BYTES;
	messof(n) = savemess(mess,leng);
	portof(n) = Defport;
	nextnote(n) = NULL;
	ntinsert(n,Noteq);
	Numq++;
}

static void
k_sysex(int leng,Unchar *mess)
{
	queuemess(mess,leng);
}

static void
sysex(void)
{
	k_sysex(msgleng(),msg());
}

void
k_arbitrary(int leng,Unchar *mess)
{
	queuemess(mess,leng);
}

void
k_tempo(long tempo)
{
	char s[100];
	sprintf(s,"\"Tempo=%ld\"t%ld",tempo,mfclicks());
	ntinsert(strtotextmess(s),Currph);
}

void
k_timesig(unsigned nn,unsigned dd,unsigned cc,unsigned bb)
{
	char s[100];
	int denom = 1;

	while ( dd-- > 0 )
		denom *= 2;
	/* First 2 numbers are time signature, next is MIDI-clocks-per-click, */
	/* and the last is 32nd-notes-per-24-MIDI-clocks. */
	sprintf(s,"\"Timesig=%d/%d,%d,%d\"t%ld", nn,denom,cc,bb,mfclicks());
	ntinsert(strtotextmess(s),Currph);
}

void
k_keysig(unsigned sf,unsigned mi)
{
	char s[100];
	sprintf(s,"\"Keysig=%d,%d\"t%ld",sf,mi,mfclicks());
	ntinsert(strtotextmess(s),Currph);
}

void
k_chanprefix(unsigned c)
{
	char s[100];
	sprintf(s,"\"Channelprefix=%d\"t%ld",c,mfclicks());
	ntinsert(strtotextmess(s),Currph);
}

void
k_seqnum(int n)
{
	char s[100];
	sprintf(s,"\"Sequence=%d\"t%ld",n,mfclicks());
	ntinsert(strtotextmess(s),Currph);
}

void
k_smpte(unsigned hr,unsigned mn,unsigned se,unsigned fr,unsigned ff)
{
	char s[100];
	sprintf(s,"\n\"Smpte=%d,%d,%d,%d,%d\"t%ld",hr,mn,se,fr,ff,mfclicks());
	ntinsert(strtotextmess(s),Currph);
}

void
k_metatext(int type,int leng,Unchar *mess)
{
	static char *ttype[] = {
		NULL,
		METATEXT,		/* type=0x01 */
		METACOPYRIGHT,		/* type=0x02 */
		METASEQUENCE,		/* type=0x03 */
		METAINSTRUMENT,		/* type=0x04 */
		METALYRIC,		/* type=0x05 */
		METAMARKER,		/* type=0x06 */
		METACUE,		/* type=0x07 */
		METAUNRECOGNIZED	/* type=0x08-0x0f */
	};
	int unrecognized = (sizeof(ttype)/sizeof(char *)) - 1;
	register int n, c;
	register Unchar *p = mess;
	char *s, *es;

	if ( type < 1 || type > unrecognized )
		type = unrecognized;
	/* The size here is just conservative, not magic. */
	s = kmalloc((unsigned)(100+6*leng),"k_metatext");
	sprintf(s,"\"%s=",ttype[type]);
	es = s + strlen(s);
	for ( n=0; n<leng; n++ ) {
		c = *p++;
		sprintf(es, (isprint(c)||isspace(c)) ? "%c" : "\\0x%02x" , c);
		es += strlen(es);
	}
	sprintf(es,"\"t%ld",mfclicks());
	ntinsert(strtotextmess(s),Currph);
	kfree(s);
}

/* read a track chunk */
static int
readtrack(void)
{
	/* This array is indexed by the high half of a status byte.  It's */
	/* value is either the number of bytes needed (1 or 2) for a channel */
	/* message, or 0 (meaning it's not  a channel message). */
	static int chantype[] = {
		0, 0, 0, 0, 0, 0, 0, 0,		/* 0x00 through 0x70 */
		2, 2, 2, 2, 1, 1, 2, 0		/* 0x80 through 0xf0 */
	};
	long lookfor, lng;
	int c, c1, type;
	int sysexcontinue = 0;	/* 1 if last message was an unfinished sysex */
	int running = 0;	/* 1 when running status used */
	int status = 0;		/* (possibly running) status byte */
	int needed;

	if ( readmt("MTrk",0) == EOF )
		return EOF;

	Mf_toberead = read32bit();
	Mf_currtime = 0;

	k_starttrack();

	while ( Mf_toberead > 0 ) {

		long dt = readvarinum();	/* delta time */
		if ( dt < 0 && (*Warnnegative != 0) ) {
			tprint("Warning: negative delta time (%ld) in MIDI file!\n",dt);
		}
		Mf_currtime += dt;

		c = egetc();

		if ( sysexcontinue && c != 0xf7 )
			mfwarning("didn't find expected continuation of a sysex");

		if ( (c & 0x80) == 0 ) {	 /* running status? */
			if ( status == 0 )
				mfwarning("unexpected running status");
			running = 1;
		}
		else {
			status = c;
			running = 0;
		}

		needed = chantype[ (status>>4) & 0xf ];

		if ( needed ) {		/* ie. is it a channel message? */

			if ( running )
				c1 = c;
			else
				c1 = egetc() & 0x7f;

			/* The &0xf7 here may seem unnecessary, but I've seen */
			/* 'bad' midi files that had, e.g., volume bytes */
			/* with the upper bit set.  This code should not harm */
			/* proper data. */

			chanmessage( status, c1, (needed>1) ? (egetc()&0x7f) : 0 );
			continue;
		}

		switch ( c ) {

		case 0xff:			/* meta event */

			type = egetc();
			/* watch out - Don't combine the next 2 statements */
			lng = readvarinum();
			lookfor = Mf_toberead - lng;
			msginit();

			while ( Mf_toberead > lookfor )
				msgadd(egetc());

			metaevent(type);
			break;

		case 0xf0:		/* start of system exclusive */

			/* watch out - Don't combine the next 2 statements */
			lng = readvarinum();
			lookfor = Mf_toberead - lng;
			msginit();
			msgadd(0xf0);

			while ( Mf_toberead > lookfor )
				msgadd(c=egetc());

			if ( c==0xf7 || Mf_nomerge==0 )
				sysex();
			else
				sysexcontinue = 1;  /* merge into next msg */
			break;

		case 0xf7:	/* sysex continuation or arbitrary stuff */

			/* watch out - Don't combine the next 2 statements */
			lng = readvarinum();
			lookfor = Mf_toberead - lng;

			if ( ! sysexcontinue )
				msginit();

			while ( Mf_toberead > lookfor )
				msgadd(c=egetc());

			if ( ! sysexcontinue ) {
				k_arbitrary(msgleng(),msg());
			}
			else if ( c == 0xf7 ) {
				sysex();
				sysexcontinue = 0;
			}
			break;
		default:
			{
			char buff[32];
			sprintf(buff,"unexpected byte: 0x%02x",c);
			mfwarning(buff);
			}
			break;
		}
	}
	k_endtrack();
	return 0;
}

int
mftoarr(char *mfname,Htablep arr)
{
	int ntrks;

	Mfarr = arr;

	if ( strcmp(mfname,"-") != 0 ) {
		if ( *mfname == '\0' )
			execerror("Invalid (null) filename given to midifile");
		OPENBINFILE(Mf,mfname,"r");
		if ( Mf == NULL )
			execerror("Can't open midifile for reading - %s (%s)",
				mfname,strerror(errno));
	}
	else
		Mf = stdin;

	Noteq = newph(0);

	ntrks = readheader();
	if ( ntrks <= 0 )
		mfwarning("No tracks!");
	while ( ntrks-- > 0 ) {
		if ( readtrack() == EOF )
			break;
	}

	if ( Mf != stdin )
		myfclose(Mf);

	return Mformat;
}
