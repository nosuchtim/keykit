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

struct AlsaPort {
	struct AlsaPort *next;
	/* const */ char *clientName;
	/* const */ char *portName;
	int client;
	int port;
};
struct AlsaPort *alsaOutputs, **alsaOutportArry;
struct AlsaPort *alsaInputs, **alsaInportArry;
typedef struct PrivateAlsaPortInfo {
	struct AlsaPort *portPtr;
	int idx;
} PrivateAlsaPortInfo;

static void
reverselist(struct AlsaPort **head)
{
	struct AlsaPort *prev = NULL;
	struct AlsaPort *current = *head;
	struct AlsaPort *next = NULL;

	while ( current != NULL ) {
		next = current->next;
		current->next = prev;
		prev = current;
		current = next;
	}

	*head = prev;
}

int
mdep_init_alsa(Midiport *ports, int isinput)
{
	snd_seq_client_info_t *cinfo;
	snd_seq_port_info_t *pinfo;
	int clientNumber, portNumber;
	unsigned int perm, portperm;
	struct AlsaPort *portPtr;
	/* const  */ char *clientName, *portName;
	unsigned int portCount = 0;
	unsigned int idx;

	dummyusage(ports); /* Unused (for now) */

	if (isinput) {
		perm = SND_SEQ_PORT_CAP_READ|SND_SEQ_PORT_CAP_SUBS_READ;
	}
	else {
		perm = SND_SEQ_PORT_CAP_WRITE|SND_SEQ_PORT_CAP_SUBS_WRITE;
	}

	snd_seq_client_info_alloca(&cinfo);
	snd_seq_port_info_alloca(&pinfo);
	snd_seq_client_info_set_client(cinfo, -1);
	while (snd_seq_query_next_client(seq, cinfo) >= 0) {
		/* reset query info */
		snd_seq_port_info_set_client(pinfo, snd_seq_client_info_get_client(cinfo));
		snd_seq_port_info_set_port(pinfo, -1);
		portNumber = 0;
		while (snd_seq_query_next_port(seq, pinfo) >= 0) {
			char buff[BUFSIZ];
			if (snd_seq_client_info_get_client(cinfo) == SND_SEQ_CLIENT_SYSTEM) {
				/* Skip system ports */
				continue;
			}
			portperm = snd_seq_port_info_get_capability(pinfo);
			if ( ((portperm & perm) == perm)
			     && ((portperm & SND_SEQ_PORT_CAP_NO_EXPORT) == 0) ) {
				snprintf(buff, sizeof(buff), "%s",
					 snd_seq_client_info_get_name(cinfo));
				clientName = strdup(buff);
				clientNumber = snd_seq_client_info_get_client(cinfo);
				snprintf(buff, sizeof(buff), "%d:%d %s",
					 clientNumber,
					 portNumber,
					 snd_seq_port_info_get_name(pinfo));
				portName = strdup(buff);
				portNumber = snd_seq_port_info_get_port(pinfo);
					
				portPtr = malloc(sizeof(*portPtr));
				portPtr->clientName = clientName;
				portPtr->client = clientNumber;
				portPtr->portName = portName;
				portPtr->port = portNumber;
				if (isinput) {
					portPtr->next = alsaInputs;
					alsaInputs = portPtr;
				}
				else {
					portPtr->next = alsaOutputs;
					alsaOutputs = portPtr;
				}
				portCount++;
				portNumber++;
			}
		}
	}

	if (isinput)
	{
		reverselist(&alsaInputs);
		alsaInportArry = malloc(portCount * sizeof(*alsaInportArry));
		for (idx=0, portPtr=alsaInputs; idx < portCount; ++idx)
		{
			alsaInportArry[idx] = portPtr;
			portPtr = portPtr->next;
		}
	}
	else {
		reverselist(&alsaOutputs);
		alsaOutportArry = malloc(portCount * sizeof(*alsaOutportArry));
		for (idx=0, portPtr=alsaOutputs; idx < portCount; ++idx)
		{
			alsaOutportArry[idx] = portPtr;
			portPtr = portPtr->next;
		}
	}
		
	return portCount;
}

int
mdep_initmidi(Midiport *inputs, Midiport *outputs)
{
	struct pollfd pfds[1];
	int i;
	int err;
	struct AlsaPort *portPtr;

	if (connect_to_sequencer ()) {
		seq = NULL;
		return -1;
	}

	n_inports = mdep_init_alsa(inputs, 1);
	n_outports = mdep_init_alsa(outputs, 0);

	inports = (AlsaPortInfo*) malloc (sizeof (AlsaPortInfo) * n_inports);
	portPtr = alsaInputs;
	
	for (i = 0; i < n_inports; ++i) {
		PrivateAlsaPortInfo *papinfo;
		inports[i].port_id = -1;
		inports[i].parser = NULL;

		inputs[i].name = portPtr->portName;
		papinfo = (PrivateAlsaPortInfo *)malloc(sizeof(PrivateAlsaPortInfo));
		papinfo->portPtr = portPtr;
		papinfo->idx = i;
		inputs[i].private1 = (intptr_t)papinfo;
		
		portPtr = portPtr->next;
	}

	for ( ; i < MIDI_IN_DEVICES; i++ ) {
		inputs[i].name = NULL;
		inputs[i].private1 = (intptr_t)NULL;
	}

	outports = (AlsaPortInfo*) malloc (sizeof (AlsaPortInfo) * n_outports);
	portPtr = alsaOutputs;
	
	for (i = 0; i < n_outports; ++i) {
		PrivateAlsaPortInfo *papinfo;
		outports[i].port_id = -1;
		outports[i].parser = NULL;

		outputs[i].name = portPtr->portName;
		papinfo = (PrivateAlsaPortInfo *)malloc(sizeof(PrivateAlsaPortInfo));
		papinfo->portPtr = portPtr;
		papinfo->idx = i;
		outputs[i].private1 = (intptr_t)papinfo;
		portPtr = portPtr->next;
	}

	for ( ; i < MIDI_IN_DEVICES; i++ ) {
		outputs[i].name = NULL;
		outputs[i].private1 = (intptr_t)NULL;
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
create_port (AlsaPortInfo* port, int in)
{
	int caps;

	port->port_id = -1;
	port->parser = 0;

	if (in) {
		caps = SND_SEQ_PORT_CAP_WRITE | SND_SEQ_PORT_CAP_SUBS_WRITE;
	} else {
		caps = SND_SEQ_PORT_CAP_READ | SND_SEQ_PORT_CAP_SUBS_READ;
	}

	if ((port->port_id = snd_seq_create_simple_port (seq, "keykit", caps, SND_SEQ_PORT_TYPE_APPLICATION)) < 0) {
		fprintf(stderr, "%s:%d fail!\n", __FUNCTION__, __LINE__);
		return -1;
	}

	snd_seq_ev_clear (&port->event);
	snd_seq_ev_set_source (&port->event, port->port_id);
	snd_seq_ev_set_subs (&port->event);
	snd_seq_ev_set_direct (&port->event);

	snd_midi_event_new (1024, &port->parser);

	return 0;
}

static int
create_port_connect (AlsaPortInfo* port, int in, snd_seq_addr_t *addr)
{
	char buff[BUFSIZ];
	snd_seq_addr_t addr2;
	snd_seq_port_subscribe_t *subs;
	int caps;

	port->port_id = -1;
	port->parser = 0;

	if (in) {
		caps = SND_SEQ_PORT_CAP_WRITE | SND_SEQ_PORT_CAP_SUBS_WRITE;
	} else {
		caps = SND_SEQ_PORT_CAP_READ | SND_SEQ_PORT_CAP_SUBS_READ;
	}

	if ((port->port_id = snd_seq_create_simple_port (seq, "keykit", caps, SND_SEQ_PORT_TYPE_APPLICATION)) < 0) {
		fprintf(stderr, "%s:%d fail!\n", __FUNCTION__, __LINE__);
		return -1;
	}

	snprintf(buff, sizeof(buff), "keykit:%d", port->port_id);
	if (snd_seq_parse_address(seq, &addr2, buff) < 0) {
		fprintf(stderr, "%s:%d fail!\n", __FUNCTION__, __LINE__);
		return -1;
	}
	snd_seq_port_subscribe_alloca(&subs);
	if (in) {
		snd_seq_port_subscribe_set_sender(subs, addr);
		snd_seq_port_subscribe_set_dest(subs, &addr2);
	}
	else {
		snd_seq_port_subscribe_set_sender(subs, &addr2);
		snd_seq_port_subscribe_set_dest(subs, addr);
	}
	snd_seq_port_subscribe_set_queue(subs, 0);
	snd_seq_port_subscribe_set_exclusive(subs, 0);
	snd_seq_port_subscribe_set_time_update(subs, 0);
	snd_seq_port_subscribe_set_time_real(subs, 0);
	if (snd_seq_get_port_subscription(seq, subs) == 0) {
		fprintf(stderr, "%s:%d connection is already subscribed\n", __FUNCTION__, __LINE__);
		return -1;
	}
	if (snd_seq_subscribe_port(seq, subs) < 0) {
		fprintf(stderr, "%s:%d Connection failed (%s)\n", __FUNCTION__, __LINE__, strerror(errno));
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
			fprintf(stderr, "%s:%d fail\n", __FUNCTION__, __LINE__);
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
	PrivateAlsaPortInfo *papinfo;
	papinfo = (PrivateAlsaPortInfo *)port->private1;
	return create_port (&outports[papinfo->idx], 0);
}

static int
openmidioutinfo (MidiOpenInfo * info)
{
	PrivateAlsaPortInfo *papinfo;
	struct AlsaPort *ap;
	snd_seq_addr_t dest;
	papinfo = (PrivateAlsaPortInfo *)info->port->private1;
	if (!info->selection)
	{
		fprintf(stderr, "%s:%d Huh? trying to open ... with selection zero!\n", __FUNCTION__, __LINE__);
		return -1;
	}
	ap = alsaOutportArry[info->selection - 1];
	dest.client = ap->client;
	dest.port = ap->port;
	return create_port_connect (&outports[papinfo->idx], 0, &dest);
}

static int
openmidiin(Midiport * port)
{
	PrivateAlsaPortInfo *papinfo;
	papinfo = (PrivateAlsaPortInfo *)port->private1;
	return create_port (&inports[papinfo->idx], 1);
}

static int
openmidiininfo (MidiOpenInfo * info)
{
	PrivateAlsaPortInfo *papinfo;
	struct AlsaPort *ap;
	snd_seq_addr_t dest;
	papinfo = (PrivateAlsaPortInfo *)info->port->private1;
	if (!info->selection)
	{
		fprintf(stderr, "%s:%d Huh? trying to open ... with selection zero!\n", __FUNCTION__, __LINE__);
		return -1;
	}
	ap = alsaInportArry[info->selection - 1];
	dest.client = ap->client;
	dest.port = ap->port;
	return create_port_connect (&inports[papinfo->idx], 1, &dest);
}

static int
closemidiin(Midiport * port)
{
	PrivateAlsaPortInfo *papinfo;
	papinfo = (PrivateAlsaPortInfo *)port->private1;
	return destroy_port (&inports[papinfo->idx]);
}

static int
closemidiout(Midiport * port)
{
	PrivateAlsaPortInfo *papinfo;
	papinfo = (PrivateAlsaPortInfo *)port->private1;
	return destroy_port (&outports[papinfo->idx]);
}

int
mdep_midi(int openclose, void *ptr)
{
	Midiport *p;
	MidiOpenInfo *info;
	int r;

	switch (openclose) {
	case MIDI_OPEN_OUTPUT:
		p = (Midiport *)ptr;
		r = openmidiout(p);
		break;
	case MIDI_OPEN_OUTPUT_INFO:
		info = (MidiOpenInfo *)ptr;
		r = openmidioutinfo(info);
		break;
	case MIDI_CLOSE_OUTPUT:
		p = (Midiport *)ptr;
		r = closemidiout(p);
		break;
	case MIDI_OPEN_INPUT:
		p = (Midiport *)ptr;
		r = openmidiin(p);
		break;
	case MIDI_OPEN_INPUT_INFO:
		info = (MidiOpenInfo *)ptr;
		r = openmidiininfo(info);
		break;
	case MIDI_CLOSE_INPUT:
		p = (Midiport *)ptr;
		r = closemidiin(p);
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
	PrivateAlsaPortInfo *papinfo = (PrivateAlsaPortInfo *)port->private1;
	AlsaPortInfo * a = &outports[papinfo->idx];
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
 
