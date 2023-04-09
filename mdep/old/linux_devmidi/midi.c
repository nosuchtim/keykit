/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

/*
 * This contains support for Voxware MIDI version 2.9 and (hopefully) later.
 * It assumes Voxware is installed.
 */

#include "key.h"
#include <sys/types.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

/* Change this if you prefer to use a different default MIDI interface */
#define MIDIDEVICE "/dev/midi00"

extern int errno;

static int NoMidiIn = 0;
static char *MidiDevice = NULL;

int
mdep_initmidi(Midiport *inputs, Midiport *outputs)
{
	extern char **Devmidi;
	int r;
	int ret = 0;

	/*
	 * If MIDIOUTPUT is set, it is the name of a file for
	 * MIDI output only.  No input will be attempted.
	 * This is appropriate for named pipes to another program.
	 *
	 * If MIDIDEVICE is set, it is expected to be a device that
	 * can do both input and output.
	 */
	if ( (MidiDevice = getenv("MIDIOUTPUT")) != NULL ) {
		NoMidiIn = 1;
	} else {
		if ( (MidiDevice = getenv("MIDIDEVICE")) == NULL ) {
			MidiDevice = MIDIDEVICE;	/* default */
		}
	}

	outputs[0].name = "devmidi";
	outputs[0].private1 = (int) NULL;
	if ( NoMidiIn == 0 ) {
		inputs[0].name = "devmidi";
		inputs[0].private1 = (int) NULL;
	}
	Midifd = -1;
	return 0;
}

static int
opendevmidi(Midiport * port)
{
	Midifd = open(MidiDevice,O_RDWR);
	if ( Midifd >= 0 ) {
		if ( Devmidi )
			*Devmidi = uniqstr(MidiDevice);
		if ( ! ismuxable(Midifd) ) {
			fprintf(stderr,"Hey, Midifd isn't muxable!\n");
			exit(1);
		}
		port->private1 = Midifd;
		return 0;
	}
	else {
		fprintf(stderr,"Unable to open %s (errno=%d)\n",
			MidiDevice,errno);
		return 1;
	}
}

static int
closedevmidi(Midiport * port)
{
	if ( Midifd >= 0 ) {
		close(Midifd);
		Midifd = -1;
	}
	port->private1 = -1;
	return 0;
}

void
mdep_endmidi(void)
{
	close(Midifd);
	Midifd = -1;
}

int
mdep_midi(int openclose, Midiport * p)
{
	int r;

	switch (openclose) {
	case MIDI_CLOSE_INPUT:
		r = closedevmidi(p);
		break;
	case MIDI_OPEN_INPUT:
		if ( NoMidiIn )
			r = 1;
		else
			r = opendevmidi(p);
		break;
	case MIDI_CLOSE_OUTPUT:
		r = closedevmidi(p);
		break;
	case MIDI_OPEN_OUTPUT:
		r = opendevmidi(p);
		break;
	default:
		/* unrecognized command */
		r = -1;
	}
	return r;
}


/* must return -1 if there is nothing to read */
int
mdep_getnmidi(char *buff,int buffsize, int *port)
{
	fd_set readfds;
	fd_set writefds;
	fd_set exceptfds;
	struct timeval t;
	int r;

	if ( Midifd < 0 || NoMidiIn != 0 )
		return 0;

	*port = 0;
	FD_ZERO(&readfds);
	FD_ZERO(&writefds);
	FD_ZERO(&exceptfds);
	FD_SET(Midifd, &readfds);
	FD_SET(Midifd, &exceptfds);
	t.tv_sec = 0;
	t.tv_usec = 0;
	if(select(Midifd+1, &readfds, &writefds, &exceptfds, &t) == 0) {
		return -1;
	}
	r = read(Midifd, buff, buffsize);
	return r;
}

void
mdep_putnmidi(int n,char *p, Midiport * port)
{
	int i;
	int fd = port->private1;
	
	if ( fd < 0 )
		return;
	if ( write(fd,p,(unsigned)n) != n ) {
		eprint("Hmm, write to MIDI device didn't write everything?\n");
		keyerrfile("Hmm, write to MIDI device didn't write everything?\n");
	}
}
