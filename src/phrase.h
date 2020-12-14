/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

/*
 * A Note contains a single MIDI message, and a Phrase is a list of notes.
 * A note can be an NT_NOTE (which is a complete note with duration), an
 * NT_BYTES (arbitrary MIDI message), an NT_ON (just a note-on), or an
 * NT_OFF (just a note-off).
 */

/* These values need to be independent bits (1,2,etc.), and their order */
/* is the order that they'll be sorted (after clicks) within phrases. */
#define NT_BYTES 1
#define NT_NOTE 2
#define NT_ON 4
#define NT_OFF 8
#define NT_LE3BYTES 16

/* bits in .flags value of Notes */
#define FLG_PICK 1

/* default values at the beginning of constant phrases */
#define DEFCHAN 0
#define DEFVOL 63
#define DEFOCT 3
#define DEFCLICKS 96
#define DEFPORT 0

/* A magic number (sorry...) for un-initialized click-type values */
#define UNDEFCLICKS -99999

/* Maximum (and illegal) value of a clicks value. */
/* Should be the maximum value of a long, but I'm */
/* too lazy to find the most portable way of defining */
/* that.  This is adequate. */
#define MAXCLICKS 9999999L

/* Normally, Notes have .attrib values, but if you want to save */
/* memory, you can turn that feature off by defining NONTATTRIB */
#ifndef NONTATTRIB
#define NTATTRIB
#endif

/* This is the maximum number of MIDI ports we support */
#define MAX_PORTS 32

#define typeof(nt) ((nt)->type)
#define portof(nt) ((nt)->port)
#define timeof(nt) ((nt)->clicks)

/* Beware - original endof() macro triggered a compiler bug on the sparc */
#ifdef ORIGINAL_ENDOF
#define endof(nt) \
	((typeof(nt)==NT_NOTE)?((long)(durof(nt)+timeof(nt))):(timeof(nt))) */
#endif
#define endof(nt) (timeof(nt)+((typeof(nt)==NT_NOTE)?durof(nt):0L))

#define messof(nt) ((nt)->u.m)
#define chanof(nt) (((nt)->u.n.chan) & 0x0f)
#define setchanof(nt) ((nt)->u.n.chan)
#define pitchof(nt) ((nt)->u.n.pitch)
#define volof(nt) ((nt)->u.n.vol)
#define durof(nt) ((nt)->u.n.duration)
#define attribof(nt) ((nt)->attrib)
#define flagsof(nt) ((nt)->flags)
#define le3_nbytesof(nt) ((nt)->u.b.nbytes)
#define gt3_nbytesof(nt) ((nt)->u.m->leng)
#define ntisnote(nt) (typeof(nt)==NT_NOTE||typeof(nt)==NT_ON||typeof(nt)==NT_OFF)
#define ntisbytes(nt) (typeof(nt)==NT_BYTES||typeof(nt)==NT_LE3BYTES)
#define canonipitchof(p) ((p)%12)
#define canoctave(p) (-2+(p)/12)
#define setfirstnote(p) ((p)->p_notes)
#define realfirstnote(p) ((p)->p_notes)
#define nextnote(n) ((n)->next)
#define lastnote(p) ((p)->p_end)
#define firstnote(p) ((p)->p_notes)

/* first-time initialization */
#define init1ph(p) {(p)->p_prev = NULL;}

/* Maximum size of a single note (which is normally small, but for */
/* quoted strings can be any size) */
#define NOTESIZE 256

#ifndef ALLOCNT
#define ALLOCNT 512
#endif
#ifndef ALLOCPH
#define ALLOCPH 128
#endif

#define DURATIONTYPE long
#define MAXDURATION (MAXLONG-2)
#define UNFINISHED_DURATION (MAXLONG-1)

typedef struct Midimessdata {
	int leng;
	Unchar* bytes;
} Midimessdata;

typedef struct Notedata {
	Noteptr next;
	long clicks;	/* # of clicks from start of phrase. */
	union {
		struct {		/* for NT_NOTE, NT_ON, NT_OFF */
			Unchar chan;
			Unchar pitch;
			Unchar vol;
			DURATIONTYPE duration;
		} n;
		struct {		/* for NT_LE3BYTES */
			Unchar nbytes;
			Unchar bytes[3];
		} b;
		Midimessp m;		/* for NT_BYTES */
	} u;
	char type;	/* NT_NOTE, NT_BYTES, NT_LE3BYTES, NT_ON, NT_OFF */
	Unchar port;
	UINT16 flags;
#ifdef NTATTRIB
	char *attrib;
#endif
} Notedata;

typedef struct Phrase {
	Noteptr p_notes;
	Noteptr p_end;		/* last note in phrase */

	long p_leng;		/* Length in clicks.  If -1, this */
				/*    is an available (temp) one. */
	short p_used;		/* Number of things using this phrase */
	short p_tobe;		/* Pending increment to p_used */

	Phrasep p_next;
	Phrasep p_prev;
} Phrase;

extern Phrasep Topph, Freeph;
// extern FILE *Fgetc;
extern int Defvol, Defoct, Defchan, Defport;
extern DURATIONTYPE Defdur;
extern char *Defatt;
extern UINT16 Defflags;
extern long Deftime, Def2time;
extern int Numnotes;
extern char *Nullstr;
