/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

/*
 * MCB51 stuff for MIDI programs.
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/fcntl.h>
#include <termio.h>

long time();
#define XOFF 19
#define XON 17
#define N_XOFF 0xf9
#define N_XON 0xfd
#define INITTIME 0xf4
#define TSTAMP 0xf5
#define BOXBAUD B9600
#define MBSIZE 128

#define MCBDEVICE "/dev/mcb51"

static int Fdrs232 = -1;
static char Mbbuff[MBSIZE];
static int Mbend = 0;		/* points past last byte read into Mbbuff */
static int Mbhead = 0;
static int Mbclicks = 5;	/* milliseconds per click */

extern long Midimilli;

void resetmb();

void
initmidi()
{
	extern char **Devmidi;
	char *uniqstr();
	struct termio tio;
	char buff[100];

	if ((Fdrs232=open(MCBDEVICE, O_RDWR | O_NDELAY))<0) {
		if ( fisatty(stdout) ) {
			sprintf(buff,"Can't open '%s'\n",MCBDEVICE);
			tprint(buff);
		}
		return;
	}

	/* the bsd compiler on the Sun doesn't automatically make the file */
	/* descriptor O_NDELAY when the O_NDELAY is in the open call. */
	fcntl(Fdrs232,F_SETFL,O_NDELAY|fcntl(Fdrs232,F_GETFL,0));

	ioctl(Fdrs232, TCGETA, &tio);
	tio.c_iflag = IXON | IXOFF;
	tio.c_oflag = 0;
	tio.c_cflag = BOXBAUD | CS8 | CREAD | CLOCAL;
	tio.c_lflag = 0;
	tio.c_line = 0;
	tio.c_cc[0] = 0;
	tio.c_cc[1] = 0;
	tio.c_cc[2] = 0;
	tio.c_cc[3] = 0;
	tio.c_cc[4] = 7; /* min */
	tio.c_cc[5] = 5; /* time */
	ioctl(Fdrs232, TCSETA, &tio);

	resetmb();
	*Devmidi = uniqstr(MCBDEVICE);
}

void
endmidi()
{
	if ( Fdrs232 >= 0 )
		close(Fdrs232);
}

void
mcb_resetclock()
{
	char buf[2];

	if ( Fdrs232 < 0 )
		return;
	*buf = INITTIME;
	write(Fdrs232, buf, 1);
	*buf = 0x00;
	write(Fdrs232, buf, 1);
	write(Fdrs232, buf, 1);
	write(Fdrs232, buf, 1);
}

void
rtstart()
{
	mcb_resetclock();
	Mbend = 0;
	Mbhead = 0;
}

void
rtend()
{
	flushconsole();
	resetmb();
}

int
statmidi()
{
	int r, n;
	char b[MBSIZE];

	if ( Fdrs232 < 0 )
		return 0;

	if ( Mbend > Mbhead )
		return 1;
	Mbend = 0;
	Mbhead = 0;
	r = read(Fdrs232,b,MBSIZE-4);	/* -4 forpossible TSTAMP */
	for ( n=0; n<r; n++ ) {
		int c = b[n]&0xff;
/* sprintf(Msg,"(statmid,c=0x%02x)",c);tprint(Msg); */
		if ( c == N_XOFF )
			c = XOFF;
		if ( c == N_XON )
			c = XON;
		if ( c == 0xfe )
			continue;	/* ignore active sensing */
		Mbbuff[Mbend++] = c;
		if ( c == TSTAMP || c == INITTIME ) {
			int b0;

			/* make sure there's 3 following bytes */
			while ( n+3 >= r ) {
				while ( read(Fdrs232,&b[r],1) != 1 )
					;
				b0 = b[r] & 0xff;
				/* ignore active sensing */
				if ( b0 == 0xfe )
					continue;
				if ( b0 == N_XOFF )
					b[r] = XOFF;
				if ( b0 == N_XON )
					b[r] = XON;
				r++;
			}
		}
	}
	if ( Mbend <= 0 )
		return 0;
	return 1;
}

/* getnmidi - Return as many MIDI input bytes as are available. */
/* The return value is a ointer to a static buffer (or NULL if there's */
/* nothing available).  The 'an' argument returns the byte count. */
char *
getnmidi(an)
int *an;
{
	long v;
	int b0, b1, b2;

    again:
	if ( Mbend>Mbhead || statmidi()!=0 ) {
		int c = Mbbuff[Mbhead] & 0xff;

		if ( c == TSTAMP || c == INITTIME ) {
			v = 0;
			Mbhead++;
			b0 = Mbbuff[Mbhead++] & 0xff;
			b1 = Mbbuff[Mbhead++] & 0xff;
			b2 = Mbbuff[Mbhead++] & 0xff;
			if (b2 & 0x40) b1 |= 0x80;
			if (b2 & 0x20) b0 |= 0x80;
			b2 &= 0x1f;
			v = b0 + 256L*(long)(b1 + 256*(b2));
/* sprintf(Msg,"TIME v=%ld\n",v);tprint(Msg); */
			if ( c == TSTAMP ) {
				Midimilli = v * Mbclicks;
			}
			goto again;
		}
	}
	if ( Mbend > Mbhead ) {
		*an = 1;
/* sprintf(Msg,"m(%d 0x%02x)\n",Mbbuff[Mbhead],Mbbuff[Mbhead]);tprint(Msg); */
		return &Mbbuff[Mbhead++];
	}
	else {
		*an = 0;
		return (char *)NULL;
	}
}

/* putnmidi - Send n bytes of MIDI output */
void
putnmidi(n,p)
char *p;
{
	int k;
	char *q;

	if ( Fdrs232 < 0 )
		return;

	for ( k=n,q=p ; k-- > 0; q++ ) {
		switch ( *q & 0xff ) {
		case XOFF: *q = N_XOFF; break;
		case XON: *q = N_XON; break;
		}
	}
	write(Fdrs232,p,n);
}

void
resetmb()
{
	char buf[2];

	if ( Fdrs232 < 0 )
		return;

	*buf = 0xff;
	write(Fdrs232, buf, 1);
	*buf = 0x00;
	write(Fdrs232, buf, 1);

	millisleep(50);	/* the box needs some time to recover */

	/* set click interval */
	*buf = 0xff;
	write(Fdrs232, buf, 1);
	*buf = 0x10 + Mbclicks;
	write(Fdrs232, buf, 1);
}

void
putk(b)
{
	char buf[2];

	switch ( b & 0xff ) {
	case XOFF: b = N_XOFF; break;
	case XON: b = N_XON; break;
	}
	buf[0] = b;
	write(Fdrs232,buf,1);
}

void
puttag(t)
long t;
{

	int b0, b1, b2;

	b0 = t & 0xff;
	b1 = (t>>8) & 0xff;
	b2 = (t>>16) & 0x1f;
	b2 |= (b0 & 0x80) >> 2;
	b2 |= (b1 & 0x80) >> 1;
	b0 &= 0x7f;
	b1 &= 0x7f;
	putk(TSTAMP);
	putk(b0);
	putk(b1);
	putk(b2);
}

/* puttmidi - Send n bytes of MIDI output at time t (milliseconds) */
void
puttmidi(n,p,t)
char *p;
long t;
{
	puttag(t/Mbclicks);
	putnmidi(n,p);
}

