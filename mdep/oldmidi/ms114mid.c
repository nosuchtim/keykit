/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

/*
 * Midiator stuff for MIDI programs.
 *
 * This code works with the Key Electronics MIDIator interface model MS-114.
 * It seems to work okay, although the stuff in putnmidi (that explicitly
 * checks for CTS to be clear) should not be necessary - the
 * CRTSCTS bit of c_cflag should handle that, but didn't seem to.
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/fcntl.h>
#include <termio.h>
#include "misc.h"

extern char *Msg;

#define MIDIATOR "/dev/midiator"
#define MBSIZE 128

static int Fdrs232 = -1;
static char Mbbuff[MBSIZE];
static int Mbend = 0;		/* points past last byte read into Mbbuff */
static int Mbhead = 0;
static int Mbclicks = 5;	/* milliseconds per click */

Symlongp Midiatorbaud;

void
initmidi()
{
	extern char **Devmidi;
	char *uniqstr();
	struct termio tio;
	char buff[100];
	int bf;
	char *mf;

	installnum("Midiatorbaudrate",&Midiatorbaud,38400);
	if ( Devmidi != NULL && *Devmidi != NULL && **Devmidi != '\0' )
		mf = *Devmidi;
	else
		mf = *Devmidi = uniqstr(MIDIATOR);

	if ((Fdrs232=open(mf, O_RDWR | O_NDELAY))<0) {
		if ( fisatty(stdout) ) {
			sprintf(buff,"Can't open '%s'.  MIDI I/O is disabled!\n",mf);
			tprint(buff);
		}
		return;
	}

	/* the bsd compiler on the Sun doesn't automatically make the file */
	/* descriptor O_NDELAY when the O_NDELAY is in the open call. */
	fcntl(Fdrs232,F_SETFL,O_NDELAY|fcntl(Fdrs232,F_GETFL,0));

	ioctl(Fdrs232, TCGETA, &tio);
	tio.c_iflag = 0;
	tio.c_oflag = 0;
	switch (*Midiatorbaud) {
	case 9600: bf = B9600; break;
	case 19200: bf = B19200; break;
	case 38400: bf = B38400; break;
	default:
		sprintf(Msg,"Unknown baud rate (Midiatorbaudrate=%ld), defaulting to 38400)\n",*Midiatorbaud);
		tprint(Msg);
		bf = B38400;
		break;
	}
	tio.c_cflag = bf | CS8 | CREAD | CLOCAL | CRTSCTS;
	tio.c_lflag = 0;
	tio.c_line = 0;
	tio.c_cc[0] = 0;
	tio.c_cc[1] = 0;
	tio.c_cc[2] = 0;
	tio.c_cc[3] = 0;
	tio.c_cc[4] = 7; /* min */
	tio.c_cc[5] = 5; /* time */
	ioctl(Fdrs232, TCSETA, &tio);
}

void
endmidi()
{
	if ( Fdrs232 >= 0 )
		close(Fdrs232);
}

void
rtstart()
{
	Mbend = 0;
	Mbhead = 0;
}

void
rtend()
{
	flushconsole();
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
	r = read(Fdrs232,b,MBSIZE);
	for ( n=0; n<r; n++ ) {
		int c = b[n]&0xff;
		if ( c == 0xfe )
			continue;	/* ignore active sensing */
		Mbbuff[Mbend++] = c;
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
	if ( Mbend<=Mbhead )
		(void) statmidi();	/* give it a chance to arrive */
	if ( Mbend > Mbhead ) {
		*an = 1;
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
int n;
char *p;
{
	int m1, m2, r1, r2;
	if ( Fdrs232 < 0 )
		return;
	if ( *Midiatorbaud <= 19200 ) {
		/* no need to check CTS */
		write(Fdrs232,p,n);
	}
	else {
	    int k, nb;
#define BURSTLENGTH 4
	    for ( k=0; k<n; ) {
		/* Wait for CTS to indicate we can write. */
		for ( ;; ) {
			r1 = ioctl(Fdrs232, TIOCMGET, &m1);
			if ( (m1 & TIOCM_CTS) != 0 )
				break;
		}
		nb = n - k;
		if ( nb > BURSTLENGTH )
			nb = BURSTLENGTH;
		write(Fdrs232,p,nb);
		p += nb;
		k += nb;
	    }
	}
}
