/*
 * MIDI support using ALSA (Advanced Linux Sound Architecture) Sequencer
 *  (NOT raw MIDI ports)
 */

#include "key.h"
#include <sys/types.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <sys/errno.h>
#include <fcntl.h>
#include <unistd.h>

// #include <sound/asound.h>
#include <asm-generic/poll.h>
#include <alsa/input.h>
#include <alsa/output.h>
#include <alsa/conf.h>
#include <alsa/seq_event.h>
#include <alsa/global.h>
#include <alsa/timer.h>
#include <alsa/seq_midi_event.h>
#include <alsa/seq.h>
#include <alsa/seqmid.h>
#include <alsa/rawmidi.h>
#include <alsa/error.h>

typedef struct AlsaPortInfo {
    snd_midi_event_t *parser;
    snd_seq_event_t event;
    int port_id;
} AlsaPortInfo;

static AlsaPortInfo* inports = 0;
static AlsaPortInfo* outports = 0;
static int n_inports;
static int n_outports;
static snd_seq_t* seq = 0;

static int
connect_to_sequencer (void)
{
	int err;

	if ((err = snd_seq_open (&seq, "default", SND_SEQ_OPEN_DUPLEX, SND_SEQ_NONBLOCK)) != 0) {
		eprint ("cannot connect to ALSA sequencer: %s\n",
			snd_strerror (err));
		return -1;
	}
	
	snd_seq_set_client_name (seq, "keykit");

	return 0;
}

int
mdep_initmidi(Midiport *inputs, Midiport *outputs)
{
	struct pollfd pfds[1];
	int i;
	char* env;
	int err;

	if (connect_to_sequencer ()) {
		seq = NULL;
		return -1;
	}

	if ((env = getenv ("KEY_NMIDI_INPUTS")) == NULL) {
		n_inports = 1;
	} else {
		n_inports = atoi (env);
		if (n_inports < 1) {
			n_inports = 1;
		}
		if (n_inports > MIDI_IN_DEVICES) {
			n_inports = MIDI_IN_DEVICES;
		}
	}

	inports = (AlsaPortInfo*) malloc (sizeof (AlsaPortInfo) * n_inports);

	for (i = 0; i < n_inports; ++i) {
		char buf[32];

		snprintf (buf, sizeof (buf), "in %d", i+1);

		inports[i].port_id = -1;
		inports[i].parser = NULL;


		inputs[i].name = strdup (buf);
		inputs[i].private1 = i;
	}

	for ( ; i < MIDI_IN_DEVICES; i++ ) {
		inputs[i].name = NULL;
		inputs[i].private1 = -1;
	}

	
	if ((env = getenv ("KEY_NMIDI_OUTPUTS")) == NULL) {
		n_outports = 1;
	} else {
		n_outports = atoi (env);
		if (n_outports < 1) {
			n_outports = 1;
		}
		if (n_outports > MIDI_IN_DEVICES) {
			n_outports = MIDI_IN_DEVICES;
		}
	}

	outports = (AlsaPortInfo*) malloc (sizeof (AlsaPortInfo) * n_outports);

	for (i = 0; i < n_outports; ++i) {
		char buf[32];

		outports[i].port_id = -1;
		outports[i].parser = NULL;

		snprintf (buf, sizeof (buf), "out %d", i+1);

		outputs[i].name = strdup (buf);
		outputs[i].private1 = i;
	}

	for ( ; i < MIDI_OUT_DEVICES; i++ ) {
		outputs[i].name = NULL;
		outputs[i].private1 = -1;
	}
 
	if ((err = snd_seq_poll_descriptors(seq, pfds, 1, POLLIN)) < 0) {
		fprintf (stderr,"Unable to get file descriptor for Midi I/O (%s)\n", snd_strerror (err));
		snd_seq_close (seq);
		seq = NULL;
		return -1;
	} 

	Midifd = pfds[0].fd;

	return 0;
}

static int
create_port (AlsaPortInfo* port, int in) {
	int caps;

	port->port_id = -1;
	port->parser = 0;

	if (in) {
		caps = SND_SEQ_PORT_CAP_WRITE | SND_SEQ_PORT_CAP_SUBS_WRITE;
	} else {
		caps = SND_SEQ_PORT_CAP_READ | SND_SEQ_PORT_CAP_SUBS_READ;
	}

	if ((port->port_id = snd_seq_create_simple_port (seq, "keykit", caps, SND_SEQ_PORT_TYPE_APPLICATION)) < 0) {
		return -1;
	}

	snd_seq_ev_clear (&port->event);
	snd_seq_ev_set_source (&port->event, port->port_id);
	snd_seq_ev_set_subs (&port->event);
	snd_seq_ev_set_direct (&port->event);

	snd_midi_event_new (1024, &port->parser);

	return 0;
}

static
int destroy_port (AlsaPortInfo* port)
{
	if (port->port_id >= 0) {
		if (snd_seq_delete_port (seq, port->port_id) != 0) {
			return -1;
		}
		snd_midi_event_free (port->parser);

		port->parser = NULL;
		port->port_id = -1;
	}
	return 0;
}

static int
openmidiout (Midiport * port)
{
	return create_port (&outports[port->private1], 0); }

static int
openmidiin(Midiport * port)
{
	return create_port (&inports[port->private1], 1); }

static int
closemidiin(Midiport * p)
{
	return destroy_port (&inports[p->private1]); }

static int
closemidiout(Midiport * p)
{
	return destroy_port (&outports[p->private1]); }

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
	if (seq) {
		snd_seq_close (seq);
	}
}

/* must return -1 if there is nothing to read */
int
mdep_getnmidi(char *buff, int buffsize, int *port)
{
	snd_seq_event_t *ev;
	int nbytes;

	if (port) {
		*port = 0;
	}
	if (seq == NULL) {
		return -1;
	}

	if (snd_seq_event_input (seq, &ev) <= 0) {
		return -1;
	}

	int port_id = ev->dest.port;
	int n;

	for (n = 0; n < n_inports; ++n) {
		if (inports[n].port_id == port_id) {
			if ((nbytes = snd_midi_event_decode (inports[n].parser, (unsigned char *)buff, buffsize, ev)) < 0) {
				fprintf (stderr, "bad parse on port %d\n", port_id);
				return -1;
			}

			if (port) {
				*port = n;
			}

			return nbytes;
		}
	}
	return -1;
}

void
mdep_putnmidi(int n,char *p, Midiport * port)
{
	AlsaPortInfo * a = &outports[port->private1];
	int have_event = 0;
	int idx;
	int ret;

	if (seq == NULL) {
		return;
	}
	/* Is this even required - doesn't parent handle running status
	 * for the _output_ side? */
	snd_midi_event_reset_encode (a->parser);

	snd_seq_nonblock (seq, 0);

	for (idx = 0; idx < n; ++idx)
	{
		ret = snd_midi_event_encode_byte(a->parser, p[idx], &a->event);
		if (ret == 0)
		{
			/* Need more MIDI bytes to encode a complete ALSA sequencer event */
			continue;
		}
		if (ret > 0)
		{
			/* Have fully encoded ALSA sequencer event - send it out */
			have_event = 1;
			if (snd_seq_event_output (seq, &a->event) < 0) {
				eprint("Hmm, write to MIDI device didn't write everything?\n");
				keyerrfile("Hmm, write to MIDI device didn't write everything?\n");
			}
		}
		else 
		{
			eprint("snd_midi_event_encode_byte returned %d?", ret);
			keyerrfile("snd_midi_event_encode_byte returned %d?", ret);
		}
	}

	if (have_event)
	{
		if (snd_seq_drain_output (seq) < 0) {
			eprint("Hmm, drain of MIDI device didn't write everything?\n");
			keyerrfile("Hmm, drain of MIDI device didn't write everything?\n");
		}
	}
	snd_seq_nonblock (seq, 1);
}
 
