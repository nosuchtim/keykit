/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#define NOTEOFF 0x80
#define NOTEON 0x90
#define PRESSURE 0xa0
#define CONTROLLER 0xb0
#define PITCHBEND 0xe0
#define PROGRAM 0xc0
#define CHANPRESSURE 0xd0

#define SUSTAIN 0x40
#define PORTAMENTO 0x41

#define SYSTEMMESSAGE	0xf0
#define BEGINSYSEX	0xf0
#define MTCQUARTERFRAME	0xf1
#define SONGPOSPTR	0xf2
#define SONGSELECT	0xf3

#define MIDISTART	0xfa
#define MIDICONTINUE	0xfb
#define MIDISTOP	0xfc

/* These are the strings used in keykit to identify Standard MIDI File */
/* meta text messages. */

#define METATEXT		"Text Event"
#define METACOPYRIGHT		"Copyright Notice"
#define METASEQUENCE		"Sequence/Track Name"
#define METAINSTRUMENT		"Instrument Name"
#define METALYRIC		"Lyric"
#define METAMARKER		"Marker"
#define METACUE			"Cue Point"
#define METAUNRECOGNIZED	"Unrecognized"

/*
 * The 'midiaction' structure contains pointers to functions that
 * will be called for each type of midi event received.
 */

#ifdef __STDC__
typedef void (*actfunc)(Unchar*,int);
#else
typedef void (*actfunc)();
#endif

struct midiaction {
	actfunc mi_off;		/* 0x8- note off */
	actfunc mi_on;		/* 0x9- note on */
	actfunc mi_pressure;	/* 0xa- key pressure */
	actfunc mi_controller;	/* 0xb- controller change */
	actfunc mi_program;	/* 0xc- program change */
	actfunc mi_chanpress;	/* 0xd- channel pressure */
	actfunc mi_pitchbend;	/* 0xe- pitch wheel */
	actfunc mi_sysex;	/* 0xf0 system exclusive */
				/* 0xf1 is undefined */
	actfunc mi_position;	/* 0xf2 song position */
	actfunc mi_song;	/* 0xf3 song number */
				/* 0xf4 is undefined */
				/* 0xf5 is undefined */
	actfunc mi_tune;	/* 0xf6 */
	actfunc mi_eox;		/* 0xf7 end of system exclusive */
	actfunc mi_timing;	/* 0xf8 timing clock */
				/* 0xf9 is undefined */
	actfunc mi_start;	/* 0xfa sequencer start */
	actfunc mi_continue;	/* 0xfb sequencer continue */
	actfunc mi_stop;	/* 0xfc sequencer stop */
				/* 0xfd is undefined */
	actfunc mi_active;	/* 0xfe active sensing */
	actfunc mi_reset;	/* 0xff system reset */
};

extern struct midiaction Midi;
extern int Currchan;
