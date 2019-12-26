/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

/*
 * This contains support for MPU-compatible MIDI interfaces on 386 machines.
 * It assumes the 'devmidi' driver is installed.
 */

/*
 * To be the most forgiving, the stuff below is an in-line expansion of
 * the contents of <sys/midi.h>.  That way it will work on systems that
 * don't have the midi driver, without any need for differences in the
 * makefile.  This will still be harmless on systems that don't have that
 * driver, since they will not have the /dev/midi file, which controls
 * activation of this stuff.   UNLESS it's a different kind of /dev/midi,
 * which in fact may be the case on Sun systems.
 */

#include "key.h"
#include <poll.h>
#include <sys/midi.h>

#ifndef O_RDWR
#include <sys/fcntl.h>
#endif

#define MIDIDEVICE "/dev/midi"

extern int errno;

void
initmidi()
{
	static int first = 1;
	extern char **Devmidi;

	if ( first ) {
		first = 0;
		Midifd = open(MIDIDEVICE,O_RDWR);
		if ( Midifd >= 0 ) {

			*Devmidi = uniqstr(MIDIDEVICE);
			ioctl(Midifd,MIDIRESET,0); /* 3 args to pacify lint */
			if ( ! isastream(Midifd) ) {
				fprintf(stderr,"Hey, Midifd isn't a stream!\n");
				nopoll();
			}
			if ( fcntl(Midifd,F_SETFL,O_NDELAY) < 0 )
				fprintf(stderr,"ERROR in fcntl(O_NDELAY) on Midifd?  errno=%d\n",errno);
		}
		else {
			fprintf(stderr,"Unable to open %s (errno=%d)\n",
				MIDIDEVICE,errno);
		}
	}
}

void
endmidi()
{
	if ( Midifd >= 0 )
		close(Midifd);
}

#define MSIZE 128
static char midibuff[MSIZE];
static int midisz = 0;

int
statmidi()
{
	if ( midisz > 0 )
		return 1;
	if ( Midifd < 0 )
		return 0;
	/* This assumes Midifd is in O_NDELAY mode */
	midisz = read(Midifd,midibuff,MSIZE);
	if ( midisz < 0 ) {
		fprintf(stderr,"Error (errno=%d) in reading Midifd!  Midi is being disabled!\n",errno);
		Midifd = -1;
	}
	if ( midisz > 0 )
		return 1;
	else
		return 0;
}

char *
getnmidi(an)
int *an;
{

	if ( Midifd < 0 ) {
		*an = 0;
		return (char *)0;
	}
	if ( midisz>0 || (midisz=read(Midifd,midibuff,MSIZE)) > 0 ) {
		*an = midisz;
		midisz = 0;
		return midibuff;
	}
	if ( midisz < 0 ) {
		fprintf(stderr,"Error (errno=%d) in reading Midifd!  Midi is being disabled!\n",errno);
		Midifd = -1;
	}
	midisz = 0;
	*an = 0;
	return (char *)0;
}

void
putnmidi(n,p)
int n;
char *p;
{
	if ( Midifd < 0 )
		return;
	if ( write(Midifd,p,(unsigned)n) != n )
		eprint("Hmm, write to /dev/midi didn't write everything?\n");
}

static long Mt = 0;

void
resetclock()
{
	if ( Midifd < 0 ) {
		Mt = 0;
		return;
	}
	ioctl(Midifd,MIDITIMERESET);
}

long
milliclock()
{
	long t;

	if ( Midifd < 0 )
		return Mt++;
	ioctl(Midifd,MIDITIME,&t);
	return t;
}
