/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

/* This is a hook to include 'overlay' directives (in mdep.h) */
#define OVERLAY1

int Debugqnote = 0;

#include "key.h"
#include "keymidi.h"

static void real_putnmidi(int buffsize, char *buff, int port);

static int Currport = 0;  /* 1-based input port number (keykit's port
                           * numbers), 0 means default. */

static int lastsync = 0;
static long lastnowoffset = 0;

static void put3onmonitorfifo(int c1, int c2, int c3);
static void putonmonitorfifo(Noteptr n);

void
chksched(char *str)
{
	Sched *s;
	for ( s=Topsched; s!=NULL; s=s->next ) {
		if ( s->next != NULL && s->clicks > s->next->clicks )
			eprint("Sched order: %s %ld %ld\n",str,s->clicks,s->next->clicks);
	}
}

void
psched(void)
{
	Sched *s;
	eprint("(sched=");
	for ( s=Topsched; s!=NULL; s=s->next ) {
		eprint("(%ld=%lld)",s->clicks,(intptr_t)s);
	}
	eprint(";)\n");
}

static char *Grabbuff = NULL;
static long Grabbuffsize = 0;

int Midiok = 0;

long Tempo = 500000L;	/* Microseconds per beat */

long Milltempo = 500;	/* Milliseconds per beat */

long Start;		/* Millsecond value at start of rtloop() */

long Midinow;		/* If MIDI clocks are in control, this is */
			/* current time in keykit clicks */
			/* THIS VALUE INCLUDES Nowoffset !! */

long Midimilli = 0;	/* in milliseconds */

long Nextclick = -1;	/* in milliseconds */

int Chkmouse = 0;	/* if non-zero, there are mouse actions to be */
			/* checked. */

char Sustain[MIDI_OUT_DEVICES+1][16];
			/* one for each MIDI channel, keeping track of */
			/* whether the sustain switch is down. */
char Portamento[MIDI_OUT_DEVICES+1][16];
			/* one for each MIDI channel, like Sustain */

/*
 * first index is 0 (for defaults) or 0-based input port number+1,
 * second index is 0-based channel.  The value is the 1-based output port #.
 */
int Portmap[PORTMAP_SIZE][16] = { 0 };

#define portmapof(port,ch) (((port)==DEFPORT)?(Portmap[DEFPORT][ch]):(Portmap[(port)-MIDI_IN_PORT_OFFSET][(ch)]))

int Newdeferred = 0;

static int Grabcnt;	/* used to throttle MIDI input in GRABMIDI */

#define ISMONITORING (*Monitor_fnum >= 0)

/*
 * midiput
 *
 * Write n bytes of MIDI output.
 * chan can be -1 if there is none.
 */
static void
midiput(int n,Unchar* msg,int port,int chan)
{
	if ( chan < 0 )
		chan = 0;
	/*
	 * If the port value is one of the input ports,
	 * then map it to the desired output port.
	 */
	if ( port > MIDI_IN_PORT_OFFSET ) {
		port = portmapof(port,chan);
	}

	/*
	 * If we're putting stuff out on port 0, or on
	 * a port that's not open, we use the
	 * default port in the Portmap.
	 */
	if ( port <= 0 || Midioutputs[port-1].opened == 0 ) {
		port = portmapof(DEFPORT,chan);
		/*
		 * But if that port isn't open,
		 * don't put out anything.
		 */
		if ( port <= 0 || Midioutputs[port-1].opened == 0 ) {
			return;
		}
	}


	/* real MIDI output */
	if ( *Debugmidi ) {
		int k;
		tprint("midiput( %d, 0x",n);
		for ( k=0; k<n; k++ )
			tprint("%02x",msg[k]&0xff);
		tprint(" , port=%d)\n",port);
	}
	else {
		real_putnmidi(n,(char*)msg,port);
	}
}

#define SETMILLI if ( ! *Sync ) {Midimilli=MILLICLOCK;}

/* Macro here is an optimization (premature as always :-) to */
/* avoid function calls for things called extremely often. */

static int Ngrabbed = 0;
static char *Grabbed = NULL;

#define GRABMIDI Grabcnt=0;while(1){\
			if ( Ngrabbed <= 0 ) { \
				Ngrabbed = real_getnmidi(Grabbuff,Grabbuffsize,&Currport); \
				if ( Ngrabbed <= 0 ) break; \
				SETMILLI; \
				Grabbed = Grabbuff; \
			} \
			while ( Ngrabbed-- > 0 ) { \
				midiparse( (*Grabbed++) & 0xff); \
				if (Grabcnt++ >= (*Grablimit)){goto grabout;} \
			} \
		}; grabout: Grabcnt=Grabcnt;

static void
real_putnmidi(int buffsize, char *buff,int port)
{
	long fn = *Midi_out_fnum;
	int echoport = 0;

	if ( *Echoport > 0 && *Echoport < MIDI_IN_PORT_OFFSET )
		echoport = *Echoport;

	if ( fn >= 0 ) {
		Fifo *f = fifoptr(fn);
		if ( f->flags & FIFO_ISPORT ) {
			mdep_putportdata(f->port,buff,buffsize);
		}
		else {
			tprint("Midioutfifo is a non-port fifo!?  It's being reset to -1\n");
			*Midi_out_fnum = -1;
		}
	}
	else {
		if ( buffsize < MIDISENDLIMIT ) {
			mdep_putnmidi(buffsize,buff, &Midioutputs[port-1] );
			if ( echoport > 0 )
				mdep_putnmidi(buffsize,buff, &Midioutputs[echoport-1] );
		}
		else {
			while ( buffsize > 0 ) {
				int cnt = buffsize;
				if ( cnt > MIDISENDLIMIT )
					cnt = MIDISENDLIMIT;
				mdep_putnmidi(cnt,buff,&Midioutputs[port-1]);
				if ( echoport > 0 )
					mdep_putnmidi(cnt,buff,&Midioutputs[echoport-1]);
				buff += cnt;
				buffsize -= cnt;
			}
		}
	}
}

static int
real_getnmidi(char *buff,int buffsize,int *port)
{
	int r;
	int mdep_port;

	r = mdep_getnmidi(buff,buffsize,&mdep_port);
	// if ( r != 0 ) {
	// 	keyerrfile("mdep_getnmidi r=%d\n",r);
	// }
	if ( *Forceinputport >= 0 )
		*port = (int)(*Forceinputport);
	else {
		*port = mdep_port + MIDI_IN_PORT_OFFSET + 1;
	}
	return r;
}

static void
midiflush(void)
{
	char buff[64];
	int dummy;
	while ( real_getnmidi(buff,sizeof(buff),&dummy) > 0 )
		;
}

static void
put3midi(int c1,int c2,int c3,int port,int chan)
{
	char buff[3];

	buff[0] = c1;
	buff[1] = c2;
	buff[2] = c3;
	midiput(3,(Unchar*)buff,port,chan);

	if ( ISMONITORING ) {
		put3onmonitorfifo(c1,c2,c3);
	}
}

/*****************
 * From here on down is the real-time loop stuff
 ****************/

extern struct midiaction Intmidi;	/* Defined below */

Sched *Topsched = NULL;	/* Deferred events within realtime() */

/* These hold noteons/off that are scheduled during a single click. */
/* Use to guarantee noteoff's are before note-on's (within same click). */
/* Offmsg2 holds note-offs that are scheduled by 0-duration notes, */
/* and that are scheduled as separate note-off's, */
/* so that they are put out after the note-on's. */
static int Numon = 0;
static char *Onmsg;
static int Numoff = 0;
static char *Offmsg;
static int Numoff2 = 0;
static char *Offmsg2;
static int Anynew = 0;
static int *Onport;
static int *Offport;
static int *Off2port;
static Unchar *Onmonitor;
static Unchar *Offmonitor;
static Unchar *Off2monitor;

Symlongp Maxatonce, Noteqsize;

/* This is a queue of notes that have been received via MIDI in (and */
/* possibly echoed on MIDI out), but have not been processed. */
/* If we get more than Noteqsize notes queued up, we're in trouble... */
static Notedata *Noteq;	/* circular queue */
static int Qavail = 0;	/* index of next free slot in noteq */
static int Qbegin = 0;	/* index of head of circular queue */

static Sched *Freesch = NULL;
static Notedata Intnt;
static Noteptr Earliestcurrent = NULL;
static Noteptr Recmiddle = NULL;

#define NOACT ((actfunc)0)

void
resetcurrphr(void)
{
	phdecruse(*Currphr);
	*Currphr = newph(1);
}

/* startrealtime only gets called once, at the very beginning */

void
initmidiport(Midiport *p)
{
	p->name = NULL;
	p->private1 = 0;
	p->opened = 0;
}

void
startrealtime(void)
{
	unsigned u;
	int n;

	installnum("Noteqsize",&Noteqsize,256);

	Noteq = (Notedata *) kmalloc((unsigned)(*Noteqsize) * sizeof(Notedata),"startreal");

	installnum("Maxatonce",&Maxatonce,256);
	u = (unsigned)(*Maxatonce) * 3 * sizeof(char);
	Onmsg = (char *) kmalloc(u,"startreal");
	Offmsg = (char *) kmalloc(u,"startreal");
	Offmsg2 = (char *) kmalloc(u,"startreal");

	u = (unsigned)(*Maxatonce) * sizeof(int);
	Onport = (int *) kmalloc(u,"startreal");
	Offport = (int *) kmalloc(u,"startreal");
	Off2port = (int *) kmalloc(u,"startreal");

	Onmonitor = (Unchar *) kmalloc(*Maxatonce,"startreal");
	Offmonitor = (Unchar *) kmalloc(*Maxatonce,"startreal");
	Off2monitor = (Unchar *) kmalloc(*Maxatonce,"startreal");

	makeroom(256L,&Grabbuff,&Grabbuffsize);

	for ( n=0; n<MIDI_IN_DEVICES; n++ )
		initmidiport(&Midiinputs[n]);
	for ( n=0; n<MIDI_OUT_DEVICES; n++ )
		initmidiport(&Midioutputs[n]);

	if ( mdep_initmidi(Midiinputs,Midioutputs) == 0 ) {
		Midiok = 1;
		midiflush();
		
	}

	/* Free existing phrases in Current and (if recording) Record */
	resetcurrphr();

	if ( *Record ) {
		phdecruse(*Recphr);
		*Recphr = newph(1);
		Recmiddle = NULL;
		Earliestcurrent = NULL;
	}

	Midi = Intmidi;		/* This is the structure that controls */
				/* the MIDI parser. */
	midiparse(-1);		/* Initialize MIDI parser. */

	*Now = -1L;
	*Nowoffset = 0;
	Midinow = 0;
	Midimilli = 0;

	clrcontroller();

	mdep_resetclock();
	Start = MILLICLOCK;
	Nextclick = Start;
}

void
clrcontroller(void)
{
	int n, m;

	for ( m=0; m<=MIDI_OUT_DEVICES; m++ ) {
		for ( n=0; n<16; n++ ) {
			Sustain[m][n] = 0;
			Portamento[m][n] = 0;
		}
	}
}

void
newtempo(long t)
{
	Tempo = t;
	if ( Tempo < MINTEMPO )
		Tempo = MINTEMPO;
	Milltempo = Tempo/1000;
	t = MILLICLOCK;
	Nextclick = t;
	Start = t - ((*Now) * Milltempo)/(*Clicks);
}

/* gets called in execerror(), in case of a signal interrupt */
void
resetreal(void)
{
	*Now = -1;
	*Nowoffset = 0;
	Nextclick = -1;

	midiflush();
	/* flushconsole(); */
	finishoff();		/* Must be before clrsched.  */
	clrsched(&Topsched);
}

/* Send note-offs for any unfinished notes in Currphr */
/* and send any note-off's in Topsched.  Also make sure the Recphr is */
/* in canonical order. */

void
finishoff(void)
{
	register Sched *s;
	int c, m;
	Noteptr n;

	for ( n=firstnote(*Currphr); n!=NULL; n=nextnote(n) ) {
		if ( typeof(n) != NT_ON )
			continue;
		put3midi((int)(NOTEOFF | chanof(n)), (int)pitchof(n), (int)volof(n), (int)portof(n), (int)chanof(n));
	}
	resetcurrphr();

	for ( s=Topsched; s!=NULL; s=s->next ) {
		if ( s->type==SCH_NOTEOFF ) {	/* assume its a NOTEOFF */
			n = s->note;
			put3midi( (int)(NOTEOFF | chanof(n)), (int)pitchof(n), (int)volof(n), (int)portof(n), (int)chanof(n) );
		}
	}

	for ( m=0; m<=MIDI_OUT_DEVICES; m++ ) {
		for ( c=0; c<16; c++ ) {
			if ( Sustain[m][c] ) {
				addandput(m, CONTROLLER, c, SUSTAIN, 0 );
				Sustain[m][c] = 0;
			}
			if ( Portamento[m][c] ) {
				addandput(m, CONTROLLER, c, PORTAMENTO, 0 );
				Portamento[m][c] = 0;
			}
		}
	}
	/* There's a bug, it seems, that gets stuff in this phreorder. */
	/* The timeout is an attempt to try to isolate it. */
	phreorder(*Recphr,MILLICLOCK+5000);
}

/* Add a 3-byte message to the Recorded phrase and output it */
/* chan is 0-based, port is 1-based (or 0 for default) */
void
addandput(int port, int n0, int chan, int c1,int c2)
{
	register Noteptr n = &Intnt;
	int c0 = n0 | chan;

	timeof(n) = *Now;
	typeof(n) = NT_LE3BYTES;
	le3_nbytesof(n) = 3;
	*ptrtobyte(n,0) = c0;
	*ptrtobyte(n,1) = c1;
	*ptrtobyte(n,2) = c2;
	portof(n) = port;
	if ( *Recinput )
		ntrecord(ntcopy(n));

	put3midi( c0, c1, c2, port, chan );
}

long Chkcount = 0;	/* for chkrealoften macro */

#ifdef OLDSTUFF
void
chkrealoften(void)
{
	static int cnt = 0;
	if ( ++cnt > *Throttle2 ) {
		chkinput();
		chkoutput();
		cnt = 0;
	}
}
#endif

void
chkinput(void)
{
	/* Grab MIDI input (possibly echo it) */
	/* and queue up the note on/off's to be */
	/* processed. */
	GRABMIDI;

	while ( Qavail != Qbegin ) {
		register Noteptr q;

		q = (Noteptr)(&Noteq[Qbegin]);

		switch(typeof(q)){
		case NT_ON:
			noteon(q);
			break;
		case NT_OFF:
			noteoff(q);
			break;
		case NT_BYTES:
		case NT_LE3BYTES:
			notemess(q);
			break;
		}
		if ( ++Qbegin >= *Noteqsize )
			Qbegin = 0;
	}
}

void
chkoutput(void)
{
	Sched *s, *pres, *nexts;
	Ktaskp t;
	int disable;
	long throttle;

	/* Don't bother looking at the schedule list until */
	/* the time has advanced to the next click. */

	if ( *Sync ) {
		if ( (Midinow-1) <= *Now )
			return;
		*Now = Midinow-1;
		Nextclick = Start + ((*Now-*Nowoffset)*Milltempo)/(*Clicks);
	}
	else {
		long clk = MILLICLOCK;
		long lastnext;
		long nw;
		if ( clk < Nextclick )
			return;
		lastnext = Nextclick;
		/*
		 * The value of Now gets computed from scratch,
		 * using the Start time and the current value of the clock.
		 */
		nw = (*Clicks)*(clk-Start)/Milltempo;
		Nextclick = Start + ((nw+1)*Milltempo)/(*Clicks);
		*Now = nw + *Nowoffset;
		if ( Nextclick < lastnext ) {
			tprint("Hey, Nextclick wrapped around!?  last=%ld next=%ld\n",lastnext,Nextclick);
			mdep_resetclock();
			Start = MILLICLOCK;
			Nextclick = Start;
		}
	}

	s = Topsched;
	Numon = 0;
	Numoff = 0;
	Numoff2 = 0;
	Anynew = 0;

	/* The Midithrottle value gets used to limit the number of scheduled */
	/* notes we handle at once. */
	throttle = *Midithrottle;
	if ( throttle > *Maxatonce )
		throttle = *Maxatonce-1;

	dummyset(nexts);
	for( pres=NULL; s != NULL; s=nexts){

		/* Topsched list is sorted, so is safe to break early */
		if ( s->clicks > *Now )
			break;

		if ( --throttle <= 0 )
			break;

		disable = 1;
		switch (s->type) {

		case SCH_NOTEOFF:
			disable = execnt(s,pres);
			break;
		case SCH_PHRASE:
			disable = execnt(s,pres);
			break;

		case SCH_WAKE:
			t = s->task;
			if ( t->state != T_SLEEPTILL )
				execerror("SCH_WAKE called on non-waiting task (%ld) !?",t->tid);
			Nsleeptill--;
			restarttask(t);
			break;

		default:
			eprint("(?=%d)",s->type);
			disable = 0;
			break;
		}
		nexts = s->next;	/* it's important that this be */
					/* BELOW the execnt() call, */
					/* because of repeat phrases */
					/* that may be added. */
		if ( disable ) {
			if ( pres == NULL )
				Topsched = nexts;
			else
				pres->next = nexts;
			freesch(s);
		}
		else
			pres = s;
	}
	if ( Anynew ) {
		int ismon = ISMONITORING;
		/* We guarantee that note-off's preceed note-on's when they */
		/* are scheduled at the same time.  This does NOT include */
		/* note-off's that are newly scheduled (the Offmsg2 ones). */
		while ( --Numoff >= 0 ) {
			midiput( 3, (Unchar*)(&(Offmsg[3*Numoff])),Offport[Numoff],Offmsg[3*Numoff]&0xf);
			if ( ismon && Offmonitor[Numoff] ) {
				Unchar* cc = (Unchar*)(&(Offmsg[3*Numoff]));
				put3onmonitorfifo(*cc,*(cc+1),*(cc+2));
			}
		}

		while ( --Numon >= 0 ) {
			midiput( 3, (Unchar*)(&(Onmsg[3*Numon])),Onport[Numon],Onmsg[3*Numon]&0xf);
			if ( ismon && Onmonitor[Numon] ) {
				Unchar* cc = (Unchar*)(&(Onmsg[3*Numon]));
				put3onmonitorfifo(*cc,*(cc+1),*(cc+2));
			}
		}

		while ( --Numoff2 >= 0 ) {
			midiput( 3, (Unchar*)(&(Offmsg2[3*Numoff2])),Off2port[Numoff2],Offmsg2[3*Numoff2]&0xf);
			if ( ismon && Off2monitor[Numoff2] ) {
				Unchar* cc = (Unchar*)(&(Offmsg2[3*Numoff2]));
				put3onmonitorfifo(*cc,*(cc+1),*(cc+2));
			}
		}

	}
	return;
}

Unchar *
ustrchr(Unchar *pn,int n)
{
	Unchar c = (Unchar)n;
	while ( *pn != c && *pn != 0 )
		pn++;
	if ( *pn != c )
		return (Unchar *)NULL;
	else
		return pn;
}

int
chanofbyte(int b)
{
	/* Channel messages must have high bit set */
	if ( (b & 0x80) == 0 )
		return -1;
	/* sys messages don't have channels */
	if ( (b & 0xf0) == 0xf0 )
		return -1;
	return b & 0xf;	/* channel # is lower 4 bits */
}

/*
 * execnt - execute a scheduled note
 */

int
execnt(register Sched *s, Sched *pres)
{
	register Noteptr n;
	int nttype, bytetype;
	int disable = 0;
	Noteptr nxt;
	char *p;
	int realpitch;

sametime:
	n = s->note;
	nttype = typeof(n);
	realpitch = pitchof(n);

	if ( nttype==NT_ON
		|| nttype==NT_NOTE 
		|| ( nttype == NT_OFF && s->offtype != OFF_INTERNAL ) ) {
		/* Apply Offsetpitch */
		if ( *Offsetpitch != 0 && *Offsetportfilter != portof(n) && ((*Offsetfilter&(1<<chanof(n)))==0) ) {
			int tmp = realpitch + (int)*Offsetpitch;
			if ( tmp >= 0 && tmp < 128 )
				realpitch = tmp;
			if ( *Debugmidi ) {
				tprint("pitch offset to %d\n",realpitch);
			}
		}
	}
		
	if ( *Recsched && *Record && (s->offtype == OFF_USER) ) {
		int recordit = 0;
		/* Figure out whether we need to record it. */
		switch(nttype){
		case NT_NOTE:
		case NT_ON:
		case NT_OFF:
			recordit = ((*Recfilter & (1<<chanof(n)))==0);
			break;
		case NT_BYTES:
		case NT_LE3BYTES:
			recordit = *Recsysex;
			break;
		default:
			execerror("Unexpected value (%d) of nttype in execnt\n",nttype);
			break;
		}
		if ( recordit ) {
			Noteptr nn = ntcopy(n);
			timeof(nn) = s->clicks;
			ntrecord(nn);
		}
	}
	if ( ntisbytes(n) ) {
		Unchar* b = ptrtobyte(n,0);
		if ( (b[0] & 0xf0) == CONTROLLER )
			chkcontroller(portof(n),b);

		if ( (b[0]&0xff)==0xf0 && b[1]==0x00 && b[2]==0x7f ) {
			/* Special "Tempo=###" text notes control tempo */
			if ( strncmp((char*)(&b[3]),"Tempo=",6) == 0 ) {
				unsigned char *pn = &b[9];
				unsigned char *q = ustrchr(pn,0xf7);
				*q = '\0';
				newtempo(atol((char*)pn));
				*q = 0xf7; /* this is why it's unsigned */
			}
			/* but other types of text notes are ignored (so far) */
		}
		else {
			midiput(ntbytesleng(n),b,portof(n),chanofbyte(b[0]));
		}
		if ( s->monitor )
			putonmonitorfifo(n);
	}
	else {
		if ( nttype==NT_ON || nttype==NT_NOTE ) {
			if ( Numon >= *Maxatonce ) {
				toomany("on");
				Numon = 0;
				goto toomuch;
			}
			/* Add to list of note-on's we */
			/* want to send right away */
			Onport[Numon] = portof(n);
			Onmonitor[Numon] = s->monitor;
			p = &(Onmsg[3*Numon++]);
			bytetype = NOTEON;
		}
		else {
			if ( Numoff >= *Maxatonce ) {
				toomany("off");
				Numoff = 0;
				goto toomuch;
			}
			if ( s->offtype == OFF_INTERNAL ) {
				/* it's a note-off to complete a NT_NOTE, */
				/* and we want to send these BEFORE anything */
				/* else scheduled at the same time. */
				Offport[Numoff] = portof(n);
				Offmonitor[Numoff] = s->monitor;
				p = &(Offmsg[3*Numoff++]);
			}
			else {
				/* User-scheduled note-off's we */
				/* send AFTER */
				Off2port[Numoff2] = portof(n);
				Off2monitor[Numoff2] = s->monitor;
				p = &(Offmsg2[3*Numoff2++]);
			}
			bytetype = NOTEOFF;
		}
		*p++ = bytetype | chanof(n);
		*p++ = realpitch;
		*p++ = volof(n);
		Anynew = 1;

		/* if it was the start of a full note, schedule the note-off*/
		if ( nttype == NT_NOTE ) {
			long dur = (long)durof(n);
			/* Special case for 0-duration notes and cases when */
			/* the scheduled time has already past.  We want */
			/* their note-offs to be after the note-on's, which */
			/* conflicts with the normal desire to do */
			/* note-off's before note-on's if they're scheduled */
			/* at the same time.  */
			if ( dur == 0 || (s->clicks+dur) <= *Now ) {
				Off2port[Numoff2] = portof(n);
				Off2monitor[Numoff2] = s->monitor;
				p = &(Offmsg2[3*Numoff2++]);
				*p++ = NOTEOFF | chanof(n);
				*p++ = realpitch;
				*p++ = volof(n);
			}
			else {
				/* schedule a copy of the note-on note */
				/* as the note-off */
				Noteptr nn = ntcopy(n);
				Sched *ns;
				long offtime = s->clicks + dur;

				pitchof(nn) = realpitch;
				nextnote(nn) = NULL;
				typeof(nn) = NT_OFF;
				ns = immsched ( SCH_NOTEOFF, offtime, s->task, s->monitor );
				s->task->schedcnt++;
				ns->note = nn;
				ns->offtype = OFF_INTERNAL;
				ns->repeat = 0L;
			}
		}
	}

   toomuch:

	/* We purposely handle the repeat stuff AFTER the stuff above, so */
	/* that the note-off's scheduled above should be BEFORE any */
	/* note-on's scheduled for the start of a repeat.  */
	if ( s->repeat > 0 && s->note == firstnote(s->phr) ) {

		long rtm = s->clicks + s->repeat + timeof(firstnote(s->phr));
		Sched *ns = immsched(SCH_PHRASE,rtm,s->task,s->monitor);
		s->task->schedcnt++;
		ns->phr = s->phr;
		ns->repeat = s->repeat;
		phincruse(ns->phr);
		ns->note = firstnote(ns->phr);
	}

	nxt = nextnote(n);
	if ( nxt != NULL ) {
		/* advance to the next note in the phrase */
		s->note = nxt;
		/* if the next note is at the same time, do it right away */
		if ( timeof(nxt) == timeof(n) ) {
			GRABMIDI;	/* but allow MIDI input to come in */
			n = nxt;
			goto sametime;
		}

		/* figure out when the next note should be scheduled (the */
		/* current clicks value includes the start time of the */
		/* phrase AND the time of the note) */
		s->clicks = s->clicks - timeof(n) + timeof(nxt);
		/* move Sched node, to maintain sorting of list */
		while ( s->next != NULL && s->clicks >= s->next->clicks ) {
			Sched *ns = s->next;
			if ( pres == NULL )
				Topsched = ns;
			else
				pres->next = ns;
			s->next = ns->next;
			ns->next = s;
			pres = ns;
		}
	}
	else {
		/* when we've played (or more accurately, started) the last */
		/* note in a scheduled phrase, we disable it and if necessary */
		/* make note of the fact that it should be freed. */
		disable++;
	}

	return disable;
}

void
toomany(char *onoff)
{
	static long lasttime = 0;
	long tm = MILLICLOCK;
	long dt = tm - lasttime;

	if ( dt < 0 )
		dt = -dt;
	/* Warn no more often than every couple seconds */
	if ( dt > 2000 ) {
#ifdef OLDSTUFF
		eprint("Too many note-%ss - limit is %ld!\n",onoff,*Maxatonce);
#endif
		execerror("Too many note-%ss - limit is %ld!\n",onoff,*Maxatonce);
		lasttime = tm;
	}
}

/* The rc_* functions are called from the MIDI interpreter (midiparse). */
/* To promptly handle (and echo) MIDI input, these routines just stuff */
/* things into the Noteq array, which is then later processed more */
/* completely. */

void
rc_on(Unchar *mess,int indx)
{
	register Noteptr q;

	if ( *Merge != 0 ) {
		if ( *Mergefilter == 0 || ( (1<<Currchan) & *Mergefilter)==0 ) {
			if ( *Mergeport1 >= 0 ) {
				midiput(indx,mess,*Mergeport1,Currchan);
			}
			if ( *Mergeport2 >= 0 ) {
				midiput(indx,mess,*Mergeport2,Currchan);
			}
		}
	}
	if ( (q=qnote(Currchan)) == NULL )
		return;
	typeof(q) = ((int)(mess[2])==0)?NT_OFF:NT_ON;
	setchanof(q) = Currchan;
	pitchof(q) = (int)(mess[1]);
	volof(q) = (int)(mess[2]);
	// keyerrfile("rc_on pitch=%d\n",pitchof(q));
}

void
rc_off(Unchar *mess,int indx)
{
	register Noteptr q;

	if ( *Merge != 0 ) {
		if ( *Mergefilter == 0 || ( (1<<Currchan) & *Mergefilter)==0 ) {
			if ( *Mergeport1 >= 0 ) {
				midiput(indx,mess,*Mergeport1,Currchan);
			}
			if ( *Mergeport2 >= 0 ) {
				midiput(indx,mess,*Mergeport2,Currchan);
			}
		}
	}
	if ( (q=qnote(Currchan)) == NULL )
		return;
	typeof(q) = NT_OFF;
	setchanof(q) = Currchan;
	pitchof(q) = (int)(mess[1]);
	volof(q) = (int)(mess[2]);
}

void
rc_mess(Unchar *mess,int indx)
{
	rc_messhandle(mess,indx,-1);	/* no channel */
}

void
rc_messhandle(Unchar *mess,int indx, int chan)
{
	register Noteptr q;

	if ( *Merge != 0 ) {
		if ( chan<0 || *Mergefilter == 0 || ( (1<<chan) & *Mergefilter)==0 ) {
			if ( *Mergeport1 >= 0 ) {
				midiput(indx,mess,*Mergeport1,chan);
			}
			if ( *Mergeport2 >= 0 ) {
				midiput(indx,mess,*Mergeport2,chan);
			}
		}
	}
	if ( (q=qnote(-1)) == NULL )
		return;
	if ( indx <= 3 ) {
		register int i;
		typeof(q) = NT_LE3BYTES;
		le3_nbytesof(q) = indx;
		for ( i=0; i<indx; i++ ) {
			*ptrtobyte(q,i) = mess[i];
		}
		// keyerrfile("rc_messhandle mess0=%d\n",mess[0]);
	}
	else {
		typeof(q) = NT_BYTES;
		messof(q) = savemess(mess,indx);
	}
}

void
rc_control(Unchar *mess,int indx)
{
	if ( ((*Filter) & M_CONTROLLER) == 0 ) {
		if ( (mess[0] & 0xf0) == CONTROLLER )
			chkcontroller(Currport,mess);
		rc_messhandle(mess,indx,Currchan);
	}
}

void
rc_pressure(Unchar *mess,int indx)
{
	if ( ((*Filter) & M_PRESSURE) == 0 )
		rc_messhandle(mess,indx,Currchan);
}

void
rc_program(Unchar *mess,int indx)
{
	if ( ((*Filter) & M_PROGRAM) == 0 )
		rc_messhandle(mess,indx,Currchan);
}

void
rc_chanpress(Unchar *mess,int indx)
{
	if ( ((*Filter) & M_CHANPRESSURE) == 0 )
		rc_messhandle(mess,indx,Currchan);
}

void
rc_pitchbend(Unchar *mess,int indx)
{
	if ( ((*Filter) & M_PITCHBEND) == 0 )
		rc_messhandle(mess,indx,Currchan);
}

void
rc_sysex(Unchar *mess,int indx)
{
	if ( ((*Filter) & M_SYSEX) == 0 )
		rc_messhandle(mess,indx,-1);	/* no channel */
}

void
rc_position(Unchar *mess,int indx)
{
	if ( ((*Filter) & M_POSITION) == 0 )
		rc_messhandle(mess,indx,-1);	/* no channel */
}

void
rc_song(Unchar *mess,int indx)
{
	if ( ((*Filter) & M_SONG) == 0 )
		rc_messhandle(mess,indx,-1);	/* no channel */
}

void
rc_startstopcont(Unchar *mess,int indx)
{
	if ( mess[0] == MIDISTART ) {
		if ( *Sync ) {
			long qnt = 4 * (*Clicks);
			long n;
tprint("GOT MIDISTART with Sync=1, previous Nowoffset = %ld, Midinow is %ld\n",*Nowoffset,Midinow);
			n = longquant(Midinow,qnt);
			if ( n < Midinow )
				n += qnt;
			*Nowoffset = n - Midinow;
/* tprint("   Setting Nowoffset to %ld\n",*Nowoffset); */
		}
	}
	if ( ((*Filter) & M_STARTSTOPCONT) == 0 )
		rc_messhandle(mess,indx,-1);	/* no channel */
}

void
rc_clock(Unchar *mess,int indx)
{
	static int clk = 0;
	static int cnt = 0;
	dummyusage(mess);
	dummyusage(indx);

	if ( ! *Sync ) {
		if ( ((*Filter) & M_CLOCK) == 0 )
			rc_messhandle(mess,indx,-1);	/* no channel */
		lastsync = 0;
	}
	else {
		if ( *Showsync != 0 && ++cnt > 24 ) {
			tprint("Receiving clock.. (%ld)\n",*Now);
			cnt = 0;
		}
		if ( ++clk > *Clocksperclick ) {
			Midinow += *Clicksperclock;
			/*
			 * If Sync is turned on in the middle of a session,
			 * the value of *Now is going to far exceed
			 * the value of Midinow.  We want to have Midinow
			 * catch up as soon as Sync is turned on.
			 * We also want it to take into account the
			 * Nowoffset.
			 */
			if ( lastsync == 0 || lastnowoffset != *Nowoffset ) {
				lastsync = 1;
				lastnowoffset = *Nowoffset;
				Midinow += *Nowoffset;
/* tprint("Adding Nowoffset to Midinow\n"); */
			}

			if ( Midinow < (*Now ) ) {
/* tprint("adjusting Midinow from %ld to %ld\n",Midinow, *Now); */
				Midinow = *Now ;
			}
			clk = 0;
		}
	}
}

/* Need to keep track of what foot switches are down */
void
chkcontroller(int port, Unchar* mess)
{
	int chan = (int)(mess[0] & 0xf);

	/*
	 * If the port is an input port, map it to the output port.
	 */
	if ( port > MIDI_IN_PORT_OFFSET ) {
		port = portmapof(port,chan);
	}
	if ( port < 0 || port > MIDI_OUT_DEVICES )
		execerror("Invalid port value (%d) in chkcontroller!?\n",port);

	switch ( mess[1] & 0xff ) {
	case SUSTAIN:
		Sustain[port][chan] = (mess[2]?1:0);
		break;
	case PORTAMENTO:
		Portamento[port][chan] = (mess[2]?1:0);
		break;
	}
}

Noteptr 
qnote(int chan)
{
	register Noteptr q = (Noteptr)(&Noteq[Qavail]);
	int nextq = Qavail+1;

	if ( nextq >= *Noteqsize )
		nextq = 0;
	if ( nextq == Qbegin ) {
		eprint("Too many notes for note queue (Noteqsize=%ld)!\nThat usually means nothing's connected to the MIDI input!\n",*Noteqsize);
		Debugqnote++;
		return (Noteptr)NULL;
	}
	if ( *Sync )
		timeof(q) = Midinow;
	else {
		/* Midimilli is in milliseconds.  Convert to clicks relative */
		/* to Start. It should just round to the nearest click, but */
		/* it seems to be consistently behind, so we add 1 click */
		/* (essentially adding a half click and then rounding). */
		timeof(q) = 1 + *Nowoffset + ((Midimilli-Start) * (*Clicks))/ Milltempo;
	}
	Qavail = nextq;
	flagsof(q) = 0;
	if ( chan < 0 )
		chan = 0;	/* default is channel 1 */
	portof(q) = Currport;
#ifdef NTATTRIB
	attribof(q) = Nullstr;
#endif
	return q;
}

void
noteon(register Noteptr q)
{
	register Noteptr n;

	typeof(&Intnt) = NT_ON;
	timeof(&Intnt) = timeof(q);
	setchanof(&Intnt)= chanof(q);
	pitchof(&Intnt) = pitchof(q);
	volof(&Intnt) = volof(q);
	durof(&Intnt) = 0;
	flagsof(&Intnt) = 0;
	portof(&Intnt) = portof(q);
#ifdef NTATTRIB
	attribof(&Intnt) = attribof(q);
#endif
	nextnote(&Intnt) = NULL;

	n = ntcopy(&Intnt);

	/* Always add the new notes to the start of the Current phrase, */
	/* so that Current[0] is always the most recent note. */
	nextnote(n) = firstnote(*Currphr);
	setfirstnote(*Currphr) = n;

	// keyerrfile("noteon onmidiin\n");
	putonmidiinfifo(&Intnt);
	putonmonitorfifo(&Intnt);
}

void
noteoff(Noteptr q)
{
	register Noteptr n;
	register Noteptr pre = NULL;
	register int chan = chanof(q);
	register int pitch = pitchof(q);

	/* Look for this note in the Current phrase */
	for ( n=firstnote(*Currphr); n!=NULL; pre=n,n=nextnote(n) ) {
		if ( chan==(int)chanof(n) && pitch==(int)pitchof(n) )
			break;
	}
	if ( n == NULL )
		return;	/* couldn't find note-on to match the note-off */

	/* we want to note the fact if this is the earliest (ie. last) */
	/* note in the Currphr, so we can adjust Recmiddle. */

#ifdef OLDSTUFF
	if ( *Record && *Recinput && (*Recfilter & (1<<chanof(n))) == 0 )
#endif

	if ( nextnote(n) == NULL ) {
		Earliestcurrent = n;
	}
	else {
		Earliestcurrent = NULL;
	}
		
	/* Remove the note from the Current phrase. */
	if ( n == firstnote(*Currphr))
		setfirstnote(*Currphr) = nextnote(n);
	else
		pre->next = nextnote(n);

	typeof(n) = NT_NOTE;		/* in Current, it's NT_ON */
	durof(n) = timeof(q) - timeof(n);

	/* Add it to the Recorded phrase */
	if ( *Recinput ) {
		ntrecord(n);
	}

	/* The Intnt is not the complete note; it's just the note-off */
	typeof(&Intnt) = NT_OFF;
	timeof(&Intnt) = timeof(q);
	setchanof(&Intnt) = chanof(n);
	pitchof(&Intnt) = pitchof(n);
	volof(&Intnt) = volof(n);
	durof(&Intnt) = durof(n);
	flagsof(&Intnt) = flagsof(n);
	portof(&Intnt) = portof(n);
#ifdef NTATTRIB
	attribof(&Intnt) = attribof(n);
#endif

	putonmidiinfifo(&Intnt);
	putonmonitorfifo(&Intnt);
}

void
notemess(Noteptr q)
{
	long clks = timeof(q);
	Unchar* b;

	typeof(&Intnt) = typeof(q);	/* NOT usertypeof() */
	timeof(&Intnt) = clks;
	messof(&Intnt) = messof(q);
	flagsof(&Intnt) = flagsof(q);
	portof(&Intnt) = portof(q);
#ifdef NTATTRIB
	attribof(&Intnt) = attribof(q);
#endif
	nextnote(&Intnt) = NULL;

	b = ptrtobyte(&Intnt,0);

	/* Do we perhaps want to monitor midi clocks ?? */
	if ( b[0] != 0xf8 ) {
		putonmonitorfifo(&Intnt);
	}

	/* Add it to the Recorded phrase */
	if ( *Recinput && *Recsysex ) {
		/* We never want to record midi clocks, though */
		if ( b[0] != 0xf8 ) {
			ntrecord(ntcopy(&Intnt));
		}
	}
	// keyerrfile("notemess onmidiin\n");
	putonmidiinfifo(&Intnt);
}

/* putonmonitorfifo(n) - Send things to the Monitorfifo */
static void
putonmonitorfifo(Noteptr n)
{
	if ( ISMONITORING ) {
		Fifo *f = fifoptr(*Monitor_fnum);
		if ( f != NULL ) {
			putntonfifo(n,f);
		}
	}
}

/* put3onmonitorfifo(n) - Send things to the Monitorfifo */
/* Shouldn't need to check ISMONITORING, caller should check. */
static void
put3onmonitorfifo(int c1, int c2, int c3)
{
	static Notedata ntdata;
	Noteptr nt;
	Fifo *f;
	int b;

	f = fifoptr(*Monitor_fnum);
	if ( f == NULL )
		return;

	nt = &ntdata;
	b = (c1 & 0xf0);

	if ( b == NOTEON ) {
		typeof(nt) = NT_ON;
	} else if ( b == NOTEOFF ) {
		typeof(nt) = NT_OFF;
	} else {
		tprint("put3onmonitorfifo get unexpected b=0x%x\n",b);
		return;
	}
	timeof(nt) = *Now;
	setchanof(nt) = (c1 & 0xf);
	pitchof(nt) = c2;
	volof(nt) = c3;
	putntonfifo(nt,f);
}

/* ntrecord(n) - Add a note to the Recorded phrase. */
void
ntrecord(Noteptr n)
{
	Noteptr pren, sn, tn;

	if ( *Record == 0 || (*Recfilter & (1<<chanof(n))) != 0 )
		return;

	if ( phreallyused(*Recphr) > 1 ) {
		Phrasep p;

		phdecruse(*Recphr);
		p = newph(1);
		phcopy(p,*Recphr);
		*Recphr = p;
		Recmiddle = NULL;
		Earliestcurrent = NULL;
	}

	/* NO need to make a ntcopy() of n, we own this one. */

	/* Recmiddle is a pointer to the note in Recphr whose time is */
	/* guaranteed to be before any of the notes in Currphr.  We use */
	/* this as the starting point for the insertion search. */
	pren = Recmiddle;	/* possibly NULL, if Recphr is empty */
	if ( pren == NULL )
		sn = Recmiddle = firstnote(*Recphr);
	else
		sn = nextnote(pren);
	while ( sn!=NULL ) {
		if ( ntcmporder(sn,n) > 0 )
			break;
		pren = sn;
		sn = nextnote(sn);
	}
	nextnote(n) = sn;
	if ( sn == NULL )
		lastnote(*Recphr) = n;

	if ( pren == NULL )
		setfirstnote(*Recphr) = n;
	else
		nextnote(pren) = n;

	if ( Earliestcurrent ) {
		if ( n == Earliestcurrent ) {
			Recmiddle = n;
			Earliestcurrent = NULL;
		}
		else {
			/* no longer unexpected, if Recinput is 0 */
#ifdef OLDSTUFF
eprint("I don't expect this to happen (Earliestcurrent) n.time=%ld earliest=%ld\n",timeof(n),timeof(Earliestcurrent));
#endif
		}
	}
	else {
		Noteptr ntn;

		ntn = NULL;
		for ( tn=Recmiddle; tn!=NULL; tn=ntn ) {
			ntn = nextnote(tn);
			if ( ntn == NULL )
				break;
			if ( Topsched!=NULL && timeof(ntn) >= Topsched->clicks )
				break;
		}
		if ( tn )
			Recmiddle = tn;
	}

	if ( endof(n) > (*Recphr)->p_leng ) {
		(*Recphr)->p_leng = endof(n);
	}
}

struct midiaction Intmidi = {
	rc_off,		/* note off (uses same routine as note on) */
	rc_on,		/* note on */
	rc_pressure,	/* pressure */
	rc_control,	/* controller */
	rc_program,	/* program */
	rc_chanpress,	/* chanpress */	
	rc_pitchbend,	/* pitchbend */
	rc_sysex,	/* sysex */
	rc_position,	/* position */
	rc_song,	/* song */
	rc_mess,	/* tune */
	rc_mess,	/* eox */
	rc_clock,	/* timing */
	rc_startstopcont,	/* start */
	rc_startstopcont,	/* continue */
	rc_startstopcont,	/* stop */
	NULL,		/* active sensing is ignored */
	rc_mess		/* reset */
};

/* clear a schedule list */
void
clrsched(Sched **as)
{
	register Sched *s, *nxt;

	dummyset(nxt);
	for ( s=(*as); s!=NULL; s=nxt ) {
		nxt = s->next;
		freesch(s);
	}
	*as = NULL;
}

Sched *
newsch(void)
{
	static Sched *last = NULL;
	static int nused = 0;

	/* First check the free list and use those nodes before anything else */
	if ( Freesch != NULL ) {
		Sched *s = Freesch;
		Freesch = Freesch->next;
		return(s);
	}

	if ( last == NULL || nused == ALLOCSCH ) {
		nused = 0;
		last = (Sched *)
			kmalloc(ALLOCSCH*sizeof(Sched),"newsch");
	}
	nused++;
	return(last++);
}

/* unsched - unschedule all events due to a particular task */
void
unsched(Task *t)
{
	register Sched *s, *pres;

	for ( pres=NULL,s=Topsched; s!=NULL; ) {

		if ( s->task == t ) {
			register Sched *nexts = s->next;
			if ( s->type == SCH_NOTEOFF ) {
				Noteptr n = s->note;
				put3midi( (int)(NOTEOFF | chanof(n)), (int)pitchof(n), (int)volof(n), (int)portof(n), (int)chanof(n) );
			}
			/* remove it from schedule list and free it */
			if ( pres == NULL )
				Topsched = nexts;
			else
				pres->next = nexts;
			freesch(s);
			s = nexts;
		}
		else {
			pres = s;
			s = s->next;
		}
	}
}

void
freesch(register Sched *s)
{
	switch ( s->type ) {
	case SCH_NOTEOFF:
	 	/* If it's a single note, we can free it with no delay */
		ntfree(s->note);
		if ( --(s->task->schedcnt) <= 0 ) {
			wakewaiters(s->task);
			deletetask(s->task);
		}
		break;
	case SCH_PHRASE:
		phdecruse(s->phr);
		if ( --(s->task->schedcnt) <= 0 ) {
			wakewaiters(s->task);
			deletetask(s->task);
		}
		break;
	case SCH_WAKE:
		/* don't free task, it continues on */
		break;
	}
	s->next = Freesch;
	Freesch = s;
}

Sched *
immsched(int type,long clicks,Ktaskp tp,int monitor)
{
	Sched *s;

	/* add a new one to the end of the list. */
	s = newsch();
	s->type = type;
	s->clicks = clicks;
	s->note = NULL;
	s->phr = NULL;
	s->offtype = OFF_USER;
	s->task = tp;
	s->repeat = 0L;
	s->monitor = monitor;

	/* insert into list, sorted by clicks */
	if ( Topsched == NULL || clicks < Topsched->clicks ) {
		s->next = Topsched;
		Topsched = s;
	}
	else {
		register Sched *prev = Topsched;
		register Sched *t = prev->next;
		/* find place in list */
		for ( ; t!=NULL; prev=t,t=t->next ) {
			if ( clicks < t->clicks )
				break;
		}
		s->next = t;
		prev->next = s;
	}
	return(s);
}

/* schedule a phrase */
long
taskphr(Phrasep ph, long clicks, long rep, int monitor)
{
	Sched *s;
	Ktaskp t;

/* eprint("taskphr(milli=%ld clicks=%ld leng=%ld)\n",MILLICLOCK,clicks,ph->p_leng); */
	t = newtp(T_SCHED);
	t->stack = NULL;
	t->schedcnt = 1;
	t->parent = T;
/* eprint("taskphr, tm=%ld\n",clicks + timeof(firstnote(ph))); */
	s = immsched ( SCH_PHRASE, clicks + timeof(firstnote(ph)), t, monitor);
	s->repeat = rep;
	s->note = firstnote(ph);
	s->phr = ph;
	phincruse(ph);
	return t->tid;
}

void
schdwake(long clicks)
{
	(void) immsched ( SCH_WAKE, clicks, T, 0 );
	taskunrun(T,T_SLEEPTILL);
	Nsleeptill++;
	T = Running;
}
