/*
 * MIDI support using ALSA (Advanced Linux Sound Architecture).
 */

#include "key.h"
#include <sys/types.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <alsa/asoundlib.h>

// Default MIDI-Device
#define DEF_MIDIDEVICE "hw:0,0"

typedef struct AlsaPortInfo {
	snd_rawmidi_t* midihandle;
	int midifd;
} AlsaPortInfo;

AlsaPortInfo alsa_rawmidi_in, alsa_rawmidi_out;

extern int errno;

int
mdep_initmidi(Midiport *inputs, Midiport *outputs)
{
	outputs[0].name = "alsa";
	outputs[0].private1 = (int) NULL;
	inputs[0].name = "alsa";
	inputs[0].private1 = (int) NULL;

	alsa_rawmidi_in.midihandle = NULL;
	alsa_rawmidi_in.midifd = -1;
	alsa_rawmidi_out.midihandle = NULL;
        alsa_rawmidi_out.midifd = -1;
 
	Midifd = -1;

	return 0;
}

static int
openmidiout(Midiport * port)
{
	int ret = 0;
	char *device;
	int err;
	AlsaPortInfo * a;
	struct pollfd pollstr;

	a = &alsa_rawmidi_out;
	if ( a->midifd >= 0 ) {
		/*
		 * It's already open.
		 */
		port->private1 = (int) a;
		return 0;
	}

	if ( (device=getenv("ALSA_RAWMIDI_DEVICE")) == NULL )
		device = DEF_MIDIDEVICE;

	err = snd_rawmidi_open(NULL, &(a->midihandle),device,0);
	if ( err ) {
		char* msg = strerror(errno);
		a->midihandle = NULL;
		a->midifd = -1;
		Midifd = -1;
		fprintf(stderr,"Unable to open MIDI device '%s', snd_rawmidi_open failed: err=%s\n",device,msg?msg:"NULL");
		if ( getenv("ALSA_RAWMIDI_DEVICE") == NULL )
			fprintf(stderr,"\nYou may want to set ALSA_RAWMIDI_DEVICE\nenvironment variables to specify your card/device explicitly.\n");		return 1;
	}

	snd_rawmidi_nonblock(a->midihandle,1);
	if(!snd_rawmidi_poll_descriptors(a->midihandle,&pollstr,1)) {
                fprintf(stderr,"Unable to get file descriptor for MidiHandle!?  errno=%d\n",errno);
                ret = 1; 
        } 

        /* printf("Got handle %d\n", pollstr.fd); */

	a->midifd = pollstr.fd;
	Midifd = a->midifd;

	if ( ! ismuxable(a->midifd) ) {
		fprintf(stderr,"Hey, midifd isn't muxable!\n");
		exit(1);
	}
	port->private1 = (int) a;
	
	return(ret);
}

static int
openmidiin(Midiport * port)
{
	int ret = 0;
	char *device;
	int err;
	AlsaPortInfo * a;
	struct pollfd pollstr;

	a = &alsa_rawmidi_in;
	if ( a->midifd >= 0 ) {
		/*
		 * It's already open.
		 */
		port->private1 = (int) a;
		return 0;
	}

	if ( (device=getenv("ALSA_RAWMIDI_DEVICE")) == NULL )
		device = DEF_MIDIDEVICE;

	err = snd_rawmidi_open(&(a->midihandle),NULL,device,0);
	if ( err ) {
		char* msg = strerror(errno);
		a->midihandle = NULL;
		a->midifd = -1;
		Midifd = -1;
		fprintf(stderr,"Unable to open MIDI device '%s', snd_rawmidi_open failed: err=%s\n",device,msg?msg:"NULL");
		if ( getenv("ALSA_RAWMIDI_DEVICE") == NULL )
			fprintf(stderr,"\nYou may want to set ALSA_RAWMIDI_DEVICE\nenvironment variables to specify your card/device explicitly.\n");
		return 1;
	}

        snd_rawmidi_nonblock(a->midihandle,1);
        if(!snd_rawmidi_poll_descriptors(a->midihandle,&pollstr,1)) {
                fprintf(stderr,"Unable to get file descriptor for MidiHandle!?  errno=%d\n",errno);
                ret = 1;
        }

	/* printf("Got handle %d\n", pollstr.fd); */

	a->midifd = pollstr.fd;
	Midifd = a->midifd;

	if ( ! ismuxable(a->midifd) ) {
		fprintf(stderr,"Hey, midifd isn't muxable!\n");
		exit(1);
	}
	port->private1 = (int) a;

	return(ret);
}

static int
closemidiin(Midiport * p)
{
	AlsaPortInfo *a = (AlsaPortInfo*) p->private1;
	if ( a ) {
		if ( a->midifd >= 0 ) {
			close(a->midifd);
			a->midifd = -1;
			Midifd = -1;
		}
		if ( a->midihandle != NULL ) {
			snd_rawmidi_close(a->midihandle);
			a->midihandle = NULL;
		}
	}
	return 0;
}

static int
closemidiout(Midiport * p)
{
	AlsaPortInfo *a = (AlsaPortInfo*) p->private1;
	if ( a ) {
		if ( a->midifd >= 0 ) {
			close(a->midifd);
			a->midifd = -1;
			Midifd = -1;
		}
		if ( a->midihandle != NULL ) {
			snd_rawmidi_close(a->midihandle);
			a->midihandle = NULL;
		}
	}
	return 0;
}

int
mdep_midi(int openclose, Midiport * p)
{
	int r;

	switch (openclose) {
	case MIDI_CLOSE_INPUT:
		r = closemidiin(p);
		break;
	case MIDI_OPEN_INPUT:
		r = openmidiin(p);
		break;
	case MIDI_CLOSE_OUTPUT:
		r = closemidiout(p);
		break;
	case MIDI_OPEN_OUTPUT:
		r = openmidiout(p);
		break;
	default:
		/* unrecognized command */
		r = -1;
	}
	return r;
}

void
mdep_endmidi(void)
{
}

/* must return -1 if there is nothing to read */
int
mdep_getnmidi(char *buff,int buffsize,int *port)
{
	AlsaPortInfo * a = &alsa_rawmidi_in;
	if ( a->midihandle == NULL || a->midifd < 0 )
		return 0;
	*port = 0;
	/* MidiHandle is non-blocking.  */
	return snd_rawmidi_read(a->midihandle, buff, (size_t)1);
}

void
mdep_putnmidi(int n,char *p, Midiport * port)
{
	int i;
	AlsaPortInfo * a = &alsa_rawmidi_out;

	if ( a->midifd < 0 )
		return;
	/* Make sure we're blocking, so all bytes get written. */
	snd_rawmidi_nonblock(a->midihandle,0);
	//snd_rawmidi_block_mode(a->midihandle,1);
	if ( snd_rawmidi_write(a->midihandle,p,(size_t)n) != n ) {
		eprint("Hmm, write to MIDI device didn't write everything?\n");
		keyerrfile("Hmm, write to MIDI device didn't write everything?\n");
	}
	/* Put it back to non-block, for getnmidi(). */
	snd_rawmidi_nonblock(a->midihandle,1);
	//snd_rawmidi_block_mode(a->midihandle,0);
}
