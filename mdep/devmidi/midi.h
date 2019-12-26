/* MIDI_BUFS is the number of buffers to allocate for MIDI I/O queues. */
/* All of the buffers get allocated when /dev/midi is first */
/* opened, and get freed when /dev/midi is finally closed. */
#define MIDI_BUFS 5

#define MIDIC		('M'<<8)
#define MIDIRESET	(MIDIC|01)
#define MIDITIME	(MIDIC|02)
#define MIDITIMERESET	(MIDIC|03)
#define MIDIACTIVE	(MIDIC|04)
#define MIDITHRU	(MIDIC|05)

#define NUMIRQ 16

#ifdef _KERNEL

/* bits for midi_ctlr.flags */
#define ISOPEN		01
/* active sensing is passed on to the reader */
#define ACTSENSE	02

struct midi_queue {
	struct buf *	buf[MIDI_BUFS];
	off_t		low;
	off_t		high;
};

struct midi_ctlr {
	int			flags;
	time_t			clockoffset;
	struct midi_queue	in;
};

extern struct midi_ctlr midi_ctlr[];
extern int midi_nctlr;
extern int irq_to_ctlr[];
extern int ctlr_to_irq[];
extern int ctlr_to_data_port[];
extern int ctlr_to_status_port[];
#endif
