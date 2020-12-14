#pragma once

#ifndef INT16
#define INT16 short
#endif

#ifndef UINT16
#define UINT16 unsigned INT16
#endif

#ifndef MAXLONG
#define MAXLONG LONG_MAX
#endif

typedef unsigned char Unchar;
typedef Unchar *Codep;
typedef struct Instnode *Instnodep;
typedef struct Midimessdata *Midimessp;
typedef struct Notedata *Noteptr;
typedef char *Bytep;
typedef struct Phrase *Phrasep;
typedef struct Symbol *Symbolp;
typedef Phrasep *Phrasepp;
typedef long *Symlongp;
typedef char *Symstr;
typedef Symstr *Symstrp;
typedef struct Hnode *Hnodep;
typedef struct Hnode **Hnodepp;
typedef struct Htable *Htablep;
typedef struct Kobject *Kobjectp;

typedef struct bi_bitmap_t {
	int id;
	int xsize, ysize;
	Unchar *bits;
	struct bi_bitmap_t *next;
} bi_bitmap_t;

/* These macros can be overridden in mdep.h for systems that require */
/* special ways of opening text vs. binary files. */
#ifndef OPENTEXTFILE
#define OPENTEXTFILE(f,file,mode) f=fopen(file,mode)
#endif
#ifndef OPENBINFILE
#define OPENBINFILE(f,file,mode) f=fopen(file,mode)
#endif

#ifndef PORTHANDLE
#define PORTHANDLE unsigned long
#endif

#define skipspace(s) while(isspace(*s))s++

typedef struct Macro {
	char *name;
	char **params;
	int nparams;
	char *value;
	struct Macro *next;
} Macro;

// #define DEBUG
// #define BIGDEBUG
// #define DEBUGEXEC

/* If MDEP_MALLOC is defined, then a machine-dependent mdep.h can */
/* provide its own macros for kmalloc and kfree. */
#ifndef MDEP_MALLOC

#ifdef MDEBUG
#define kmalloc(x,tag) dbgallocate(x,tag)
#else
#define kmalloc(x,tag) allocate(x,tag)
#endif

#define kfree(x) myfree((char *)(x))

#endif

/* It's important that dummyusage() NOT change the value of its argument! */
#ifndef dummyusage
#ifdef lint
#define dummyusage(x) x=x
#define dummyset(x) x=0
#else
#define dummyusage(x)
#define dummyset(x)
#endif
#endif

#ifndef isspace
#define isspace(c) ((c)==' '||(c)=='\t'||(c)=='\n'||(c)=='\r')
#endif

#ifndef isdigit
#define isdigit(c) ((c)>='0'&&(c)<='9')
#endif

#ifndef isalpha
#define isalpha(c) (((c)>='a'&&(c)<='z')||((c)>='A'&&(c)<='Z')||(c)=='_')
#endif

#ifndef isalnum
#define isalnum(c) (((c)>='a'&&(c)<='z')||((c)>='A'&&(c)<='Z')||(c)=='_'||((c)>='0'&&(c)<='9'))
#endif

#ifdef __STDC__
#define NOARG void
#else
#define NOARG
#endif

#include "phrase.h"

#define DONTFLAGERROR 0
#define FLAGERROR 1

typedef void (*SIGFUNCTYPE)(int);

typedef float DBLTYPE;
typedef int (*INTFUNC)(NOARG);
typedef void (*BYTEFUNC)(NOARG);
typedef Unchar BLTINCODE;

#ifdef __STDC__
typedef void (*STRFUNC)(Symstr);
typedef void (*BLTINFUNC)(int);
typedef int (*HNODEFUNC)(Hnodep);
typedef void (*PATHFUNC)(char*,char*);
#else
typedef void (*STRFUNC)();
typedef void (*BLTINFUNC)();
typedef int (*HNODEFUNC)();
typedef void (*PATHFUNC)();
#endif

/* These are the values of the Datum type */
/* #define D_NONE 0 - no longer used */
#define D_NUM 1
#define D_STR 2
#define D_PHR 3
#define D_SYM 4
#define D_DBL 5
#define D_ARR 6
#define D_CODEP 7
#define D_FRM 8
#define D_NOTE 9
#define D_DATUM 10
#define D_FIFO 11
#define D_TASK 12
#define D_WIND 13
#define D_OBJ 14

/* Watch out, these values must line up with the Bytefuncs array */
#define I_POPVAL	0
#define I_DBLPUSH	1
#define I_STRINGPUSH	2
#define I_PHRASEPUSH	3
#define I_ARREND	4
#define I_ARRAYPUSH	5
#define I_INCOND	6
#define I_DIVCODE	7
#define I_PAR		8
#define I_AMP		9
#define I_LSHIFT	10
#define I_RIGHTSHIFT	11
#define I_NEGATE	12
#define I_TILDA		13
#define I_LT		14
#define I_GT		15
#define I_LE		16
#define I_GE		17
#define I_NE		18
#define I_EQ		19
#define I_REGEXEQ	20
#define I_AND1		21
#define I_OR1		22
#define I_NOT		23
#define I_NOOP		24
#define I_POPIGNORE	25
#define I_DEFINED	26
#define I_OBJDEFINED	27
#define I_CURROBJDEFINED	28
#define I_REALOBJDEFINED	29
#define I_TASK		30
#define I_UNDEFINE	31
#define I_DOT		32
#define I_MODULO	33
#define I_ADDCODE	34
#define I_SUBCODE	35
#define I_MULCODE	36
#define I_XORCODE	37
#define I_DOTASSIGN	38
#define I_MODDOTASSIGN	39
#define I_MODASSIGN	40
#define I_VARASSIGN	41
#define I_DELETEIT	42
#define I_DELETEARRITEM	43
#define I_READONLYIT	44
#define I_ONCHANGEIT	45
#define I_EVAL		46
#define I_VAREVAL	47
#define I_OBJVAREVAL	48
#define I_FUNCNAMED	49
#define I_LVAREVAL	50
#define I_GVAREVAL	51
#define I_VARPUSH	52
#define I_OBJVARPUSH	53
#define I_CALLFUNC	54
#define I_OBJCALLFUNCPUSH	55
#define I_OBJCALLFUNC	56
#define I_ARRAY		57
#define I_LINENUM	58
#define I_FILENAME	59
#define I_FORIN1	60
#define I_FORIN2	61
#define I_POPNRETURN	62
#define I_STOP		63
#define I_SELECT1	64
#define I_SELECT2	65
#define I_SELECT3	66
#define I_PRINT		67
#define I_GOTO		68
#define I_TFCONDEVAL	69
#define I_TCONDEVAL	70
#define I_CONSTANT	71
#define I_DOTDOTARG	72
#define I_VARG		73
#define I_CURROBJEVAL	74
#define I_CONSTOBJEVAL	75
#define I_ECURROBJEVAL	76
#define I_EREALOBJEVAL	77
#define I_RETURNV	78
#define I_RETURN	79
#define I_QMARK		80
#define I_FORINEND	81
#define I_DOSWEEPCONT	82
#define I_CLASSINIT	83
#define I_PUSHINFO	84
#define I_POPINFO	85
#define I_NARGS		86
#define I_TYPEOF	87
#define I_XY2		88
#define I_XY4		89

/* watch out, these values are tied to the Codesize array */
#define IC_NONE 0
#define IC_NUM 1
#define IC_STR 2
#define IC_DBL 3
#define IC_SYM 4
#define IC_PHR 5
#define IC_INST 6
#define IC_FUNC 7
#define IC_BLTIN 8

/* Watch out, these values must line up with the Bltinfuncs array */
#define BI_NONE		0
#define BI_SIZEOF	1
#define BI_OLDNARGS	2
#define BI_ARGV		3
#define BI_MIDIBYTES	4
#define BI_SUBSTR	5
#define BI_SBBYES	6
#define BI_RAND		7
#define BI_ERROR	8
#define BI_PRINTF	9
#define BI_READPHR	10
#define BI_EXIT		11
#define BI_OLDTYPEOF	12
#define BI_SPLIT	13
#define BI_CUT		14
#define BI_STRING	15
#define BI_INTEGER	16
#define BI_PHRASE	17
#define BI_FLOAT	18
#define BI_SYSTEM	19
#define BI_CHDIR	20
#define BI_TEMPO	21
#define BI_MILLICLOCK	22
#define BI_CURRTIME	23
#define BI_FILETIME	24
#define BI_GARBCOLLECT	25
#define BI_FUNKEY	26
#define BI_ASCII	27
#define BI_MIDIFILE	28
#define BI_REBOOT	29
#define BI_REFUNC	30
#define BI_DEBUG	31
#define BI_PATHSEARCH	32
#define BI_SYMBOLNAMED	33
#define BI_LIMITSOF	34
#define BI_SIN		35
#define BI_COS		36
#define BI_TAN		37
#define BI_ASIN		38
#define BI_ACOS		39
#define BI_ATAN		40
#define BI_SQRT		41
#define BI_POW		42
#define BI_EXP		43
#define BI_LOG		44
#define BI_LOG10	45
#define BI_REALTIME	46
#define BI_FINISHOFF	47
#define BI_SPRINTF	48
#define BI_GET		49
#define BI_PUT		50
#define BI_OPEN		51
#define BI_FIFOSIZE	52
#define BI_FLUSH	53
#define BI_CLOSE	54
#define BI_TASKINFO	55
#define BI_KILL		56
#define BI_PRIORITY	57
#define BI_ONEXIT	58
#define BI_SLEEPTILL	59
#define BI_WAIT		60
#define BI_LOCK		61
#define BI_UNLOCK	62
#define BI_OBJECT	63
#define BI_OBJECTLIST	64
#define BI_WINDOBJECT	65
#define BI_SCREEN	66
#define BI_SETMOUSE	67
#define BI_MOUSEWARP	68
#define BI_BROWSEFILES	69
#define BI_COLORSET	70
#define BI_COLORMIX	71
#define BI_SYNC		72
#define BI_OLDXY	73
#define BI_CORELEFT	74
#define BI_PRSTACK	75
#define BI_PHDUMP	76
#define BI_NULLFUNC	77
/* Methods, much like built-in functions */
#define O_SETINIT	78
#define O_ADDCHILD	79
#define O_REMOVECHILD	80
#define O_CHILDUNDER	81
#define O_CHILDREN	82
#define O_INHERITED	83
#define O_ADDINHERIT	84
#define O_SIZE		85
#define O_REDRAW	86
#define O_CONTAINS	87
#define O_XMIN		88
#define O_YMIN		89
#define O_XMAX		90
#define O_YMAX		91
#define O_LINE		92
#define O_BOX		93
#define O_FILL		94
#define O_STYLE		95
#define O_MOUSEDO	96
#define O_TYPE		97
#define O_TEXTCENTER	98
#define O_TEXTLEFT	99
#define O_TEXTRIGHT	100
#define O_TEXTHEIGHT	101
#define O_TEXTWIDTH	102
#define O_SAVEUNDER	103
#define O_RESTOREUNDER	104
#define O_PRINTF	105
#define O_DRAWPHRASE	106
#define O_SCALETOGRID	107
#define O_VIEW		108
#define O_TRACKNAME	109
#define O_SWEEP		110
#define O_CLOSESTNOTE	111
#define O_MENUITEM	112
#define BI_LSDIR	113
#define BI_REKEYLIB	114
#define BI_FIFOCTL	115
#define BI_MDEP		116
#define BI_HELP		117
#define O_MENUITEMS	118
#define O_ELLIPSE	119
#define O_FILLELLIPSE	120
#define O_SCALETOWIND	121
#define BI_ATTRIBARRAY	122
#define BI_ONERROR	123
#define BI_MIDI		124
#define BI_BITMAP	125
#define BI_OBJECTINFO	126
#define O_FILLPOLYGON	127

#define IO_STD 1
#define IO_REDIR 2

#define CUT_NORMAL 0
#define CUT_TRUNCATE 1
#define CUT_INCLUSIVE 2
#define CUT_TIME 3
#define CUT_FLAGS 4
#define CUT_TYPE 5
#define CUT_CHANNEL 6
#define CUT_NOTTYPE 7
#define CUT_PITCH 7

/* These values start here because they continue from NT_ON, NT_OFF, ... */
#define M_CHANPRESSURE 16
#define M_CONTROLLER 32
#define M_PROGRAM 64
#define M_PRESSURE 128
#define M_PITCHBEND 256
#define M_SYSEX 512
#define M_POSITION 1024
#define M_CLOCK 2048
#define M_SONG 4096
#define M_STARTSTOPCONT 8192
#define M_SYSEXTEXT 16384

/* Used for return values of mdep_waitfor() */
#define K_CONSOLE  1
#define K_MOUSE 2
#define K_MIDI 4
#define K_WINDEXPOSE 8
#define K_WINDRESIZE 16
#define K_TIMEOUT 32
#define K_ERROR 64
#define K_NOTHING 128
#define K_QUIT 256
#define K_PORT 512

#define T_STATUS 1
#define T_KILL 2
#define T_PAUSE 4
#define T_RESTART 8

/* For Symbol.flags */
#define S_READONLY 1
#define S_SEEN 2

/* Offset applied to return values of fromconsole() for function keys */
#define FKEYBIT 1024
#define KEYUPBIT 2048
#define KEYDOWNBIT 4096
#define NFKEYS 24

/* This flag allows 'phrase % number' operation to be zero or one-based */
/* I guess 1-based is more natural (ie. 'a,b,c'%1 == 'a'), but 0-based */
/* would make it more array-like.  Note that the existing library of */
/* keykit functions depends on phrases being one-based, so this can't */
/* be changed unless you change the library.  Not advised, but I can */
/* envision changing it if/when other strong reasons warrant it. */
#define PHRASEBASE 1		/* affects 'phrase % number' operation */

/* These are the amounts used for bulk allocation of various structures */
#define ALLOCSY 64
#define ALLOCIN 512
#define ALLOCSCH 64
#define ALLOCHN 128
#define ALLOCTF 32
#define ALLOCINT 32
#define ALLOCDN 32
#define ALLOCFD 32
#define ALLOCLK 32
#define ALLOCOBJ 64

#define H_INSERT 0
#define H_LOOK 1
#define H_DELETE 2

#define COMPLAIN 1
#define NOCOMPLAIN 0

/* default separator for split() on strings */
#define DEFSPLIT " \t\n"

#define ISDEBUGON (Debug!=NULL && *Debug!=0)

/* KeyKit programs get parsed and 'compiled' into lists of Inst's. */
/* Each program segment (e.g. a function) is kept in a separate list. */
/* The Inst's are maintained as linked lists rather than as arrays, */
/* so that they can be dynamically allocated (hence no program length */
/* restrictions) and so that separate intruction segements (e.g. for each */
/* user-defined function) can be more easily maintained. */

typedef union Instunion {
	BLTINCODE bltin;
	BYTEFUNC func;
	DBLTYPE dbl;
	long val;
	Symstr str;
	Symbolp sym;
	Instnodep in;
	Codep ip;
	Phrasep phr;
	Unchar bytes[8];
} Inst;
	
/* values of ival in Inst */
#define IBREAK 8
#define ICONTINUE 9

union str_union {
	Symstr str;
	Unchar bytes[8];
};
union dbl_union {
	DBLTYPE dbl;
	Unchar bytes[8];	/* WRONG! (when DBLTYPE is not of size 4) */
};
union sym_union {
	Symbolp sym;
	Unchar bytes[8];
};
union phr_union {
	Phrasep phr;
	Unchar bytes[8];
};
union ip_union {
	Codep ip;
	Unchar bytes[8];
};

#define DONTPUSH 0x800

/* This is an arbitrary magic number */
#define FORINJUNK 0x1234

typedef struct Instcode {
	Inst u;
	int type;
} Instcode;

typedef struct Instnode {
	Instcode code;
	Instnodep inext;
	int offset;	/* only used in inodes2code() */
} Instnode;

/* The Datum is the basic type for the Stack that gets manipulated during */
/* the execution of Inst's. */

typedef struct Datum {	/* interpreter stack type */
	short type;	/* uses D_* values */
	union Datumu {
		long	val;	/* D_NUM */
		DBLTYPE	dbl;	/* D_DBL */
		Symstr	str;
		Symbolp sym;
		Phrasep	phr;
		Htablep arr;	/* If type==D_ARR (array), this is a ptr to */
				/* ptr to elements (double indirect because */
				/* arrays are manipulated by reference) */
		Codep codep;		/* D_CODEP */
		struct Datum *frm;	/* D_FRM */
		struct Datum *datum;	/* D_DATUM */
		Noteptr note;		/* D_NOTE */
		struct Ktask *task;	/* D_TASK */
		struct Fifo *fifo;	/* D_FIFO */
		struct Kwind *wind;	/* D_WIND */
		Kobjectp obj;		/* D_OBJ */
	} u;
} Datum;

typedef union Datumu Datumu;

typedef struct Dnode {
	struct Datum d;
	struct Dnode *next;
} Dnode;

typedef struct Hnode {
	Hnodep next;
	Datum key;
	Datum val;
} Hnode;

#define HT_TOBECHECKED 1

typedef struct Htable {
	int size;	/* size of nodetable */
	int count;	/* number of actual elements */
	short h_used;
	short h_tobe;
	Hnodepp nodetable;
	Htablep h_next;
	Htablep h_prev;
	short h_state;	/* HT_TOBECHECKED or 0 */
} Htable;

typedef Htablep *Htablepp;

/* Symbol entries are created during the parsing of a keykit program, */
/* and are typically pointed-to by Inst entries.  To make array elements */
/* work like normal variables (ie. avoiding lots of special cases in the */
/* routines which execute Inst's), an array is represented by a head Symbol */
/* which points to a hash table pointing to Symbols, one per array element.*/
/* References to array elements get turned (at execution time) into */
/* references to the Symbol (possibly newly generated at execution time) */
/* for the desired element, after which it looks like a normal variable.  */
/* When an array is passed as an argument to a function, it is passed */
/* by reference, allowing modification of the passed array */

typedef struct Symbol { /* symbol table entry */
	Symbolp next;
	Datum	name;	/* For normal variables, this is the name. */
			/* For array elements, it's the index value. */
	INT16	stype;	/* UNDEF, VAR, MACRO, TOGLOBSYM, -or- a keyword */
	char	stackpos;/* 0 if symbol is global, okay if unsigned or signed */
	char	flags;	/* S_READONLY, etc. */
	Codep	onchange;/* to execute when variable changes value */
	Datum sd;	/* Value of global VARs and array elements. */
} Symbol;

/* When parsing a keykit program, Contexts are used to determine what */
/* Symbols are local (e.g. parameters within a user-defined function) */
/* and which are global. */

typedef struct Context {
	struct Context *next;
	Symbolp func;
	Htablep symbols;
	int localnum;
	int paramnum;
} Context;

struct bltinfo {
	char *name;
	BLTINFUNC func;
	BLTINCODE bltindex;
};

typedef struct Ktask *Ktaskp;

#define OFF_USER 0
#define OFF_INTERNAL 1

typedef enum {
	FIFOTYPE_UNTYPED,
	FIFOTYPE_BINARY,
	FIFOTYPE_LINE,
	FIFOTYPE_FIFO,
	FIFOTYPE_ARRAY
} Fifotype;

typedef struct schednode {
	struct schednode *next;
	long clicks;			/* scheduled time */
	char type;			/* SCH_* */
	char offtype;			/* for SCH_NOTEOFF) */
	char monitor;			/* If 1, add to Monitorfifo */
	Phrasep phr;			/* for SCH_PHRASE */
	Noteptr note;			/* for SCH_NOTEOFF and SCH_PHRASE. */
	Ktaskp task;
	long repeat;			/* if > 0, a repeat time. */
} Sched;

typedef struct Tofree {
	Noteptr note;
	struct Tofree *next;
} Tofree;

typedef struct Ktask {
	Unchar* pc;	/* current instruction */
	Ktaskp nextrun;	/* Used for the Running list */
	Datum *stack;	/* the stack (duh) */
	int stacksize;	/* allocated size of stack */
	Datum *stackp;	/* next free spot on stack */
	Datum *stackend;/* just past last allocated element */
	Datum *stackframe;	/* beginning of current stack frame */
	Datum *arg0;	/* argument 0 of current stack frame */
	int state;	/* T_FREE, T_RUNNING, etc. */
	int nested;	/* number of nested instruction streams */
	long tid;	/* task id, >= 0 */
	int priority;	/* 0=normal, >0 is high priority */
	Codep first;	/* first instruction */
	int schedcnt;	/* number of scheduled events due to this task */
	long cnt;	/* number of instructions executed */
	int tmp;	/* for temporary use as a flag, counter, etc. */
	Ktaskp twait;   /* if state==T_WAITING, we're waiting for this */
	Datum *qmarkframe;    /* keeps track of ? (in ph{??.chan==1} ) */
	int qmarknum;	      /* ? number (as in ph{??.number<10} ) */
	int rminstruct;	      /* says if instructions should be freed */
	Ktaskp parent;
	int anychild;	      /* If this task has any children */
	int anywait;	      /* If any tasks are waiting for this one */
	struct Fifo *fifo;	      /* Task is blocked on this fifo. */
	Codep onexit;
	Dnode *onexitargs;
	Codep ontaskerror;
	Dnode *ontaskerrorargs;
	Symstr ontaskerrormsg;
	Ktaskp nxt;     /* Used for the Toptp and Freetp lists */
	Ktaskp tmplist; /* Used for temporary lists. */
	long linenum;
	Symstr filename;
	struct Lknode *lock;
	Kobjectp obj;	/* object we're running method of */
	Kobjectp realobj;/* object we're running method on behalf of */
	Symstr method;
	BLTINCODE pend_bltin;	/* pending function (when T_OBJBLOCKED). */
	short pend_npassed;	/* for pending function */
} Task;

typedef struct Fifodata {
	struct Fifodata *next;
	Datum d;
} Fifodata;

typedef struct Fifo {
	Fifodata *head;		/* Points to last "put" */
	Fifodata *tail;		/* Points to next "get" */
	int size;
	int flags;		/* For FIFO_* bitflags, see above */
	FILE *fp;		/* If non-NULL, this is a file fifo */
	Ktaskp t;		/* This task is blocked on this fifo */
	PORTHANDLE port;	/* If FIFO_ISPORT is set, this is used. */
	long num;
	struct Fifo *next;
	Fifotype fifoctl_type;	/* type of data read from fifo */
	char *linebuff;		/* Saved data for FIFO_LINE */
	long linesize;		/* Total size of linebuff (for makeroom) */
	long linesofar;		/* How much actually used */
} Fifo;

typedef struct Lknode {
	Symstr name;		/* Only used in Toplk list. */
	Task *owner;
	struct Lknode *next;	/* Only used in Toplk list. */
	struct Lknode *notify;	/* List of pending locks with same name */
} Lknode;

typedef struct Kobject {
	long id;
	Htablep symbols;
	Kobjectp inheritfrom;	/* list of objects we inherit from */
	Kobjectp nextinherit;	/* next in that list */
	Kobjectp children;
	Kobjectp nextsibling;
	Kobjectp onext;
} Kobject;

/*
 * There are this many input devices, and this many output devices.
 */
#define MAX_PORT_VALUE (MIDI_IN_DEVICES+MIDI_OUT_DEVICES)
#define MIDI_OUT_DEVICES 64
#define MIDI_IN_PORT_OFFSET 64
#define MIDI_IN_DEVICES 64
#define PORTMAP_SIZE (MIDI_IN_DEVICES+1)

typedef struct Midiport {
	int opened;
	Symstr name;
	int private1;	/* mdep layer can use this for whatever it wants */
} Midiport;

/*
 * The index into this array is the port number minus 1.
 */
Midiport Midiinputs[MIDI_IN_DEVICES];
Midiport Midioutputs[MIDI_OUT_DEVICES];

/*
 * Used for the first argument of the mdep_midi function.
 */
#define MIDI_OPEN_OUTPUT 0
#define MIDI_CLOSE_OUTPUT 1
#define MIDI_OPEN_INPUT 2
#define MIDI_CLOSE_INPUT 3

/* values of T->state */
/* T_RUNNING is a task that is currently free, available for use */
#define T_FREE 0
/* T_RUNNING is an active task */
#define T_RUNNING 1
/* T_BLOCKED is a task blocked on a fifo */
#define T_BLOCKED 2
/* T_SLEEPTILL is a task that is waiting because of a sleeptill() function */
#define T_SLEEPTILL 3
/* T_STOPPED is a task stopped */
#define T_STOPPED 4
/* T_SCHED is a task scheduled as a result of realtime() */
#define T_SCHED 5
/* T_WAITING is a task waiting for a signal. */
#define T_WAITING 6
/* T_LOCKWAIT is a task waiting for a lock. */
#define T_LOCKWAIT 7

/* This is purposely low, just to exercise newly added code. */
#define ISEGINC 2

/* Bits that can be set in Fifo.flags.  When a fifo is */
/* created, all of the bits default to 0. */
#define FIFO_OPEN 1		/* if set, FIFO is open */
#define FIFO_PIPE (1<<1)	/* fifo is connected to a pipe (vs. a file) */
#define FIFO_WRITE (1<<2)	/* fifo is used for writing */
#define FIFO_READ (1<<3)	/* fifo is used for reading */
#define FIFO_SPECIAL (1<<4)	/* fifo is special (MIDI, CONSOLE, MOUSE), */
				/* it can't be closed by the user. */
#define FIFO_NORETURN (1<<5)	/* tells whether to use ret() */
#define FIFO_APPEND (1<<6)	/* fifo is writing */
#define FIFO_ISPORT (1<<7)	/* fifo is attached to a mdep_openport() */

#define fifonum(f) ((f)->num)

#define FIFOINC 64

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
typedef void (*actfunc)(Unchar*, int);
#else
typedef void (*actfunc)();
#endif

#define MYMETATEMPO	-1
#define MYMETATIMESIG	-2
#define MYMETAKEYSIG	-3
#define MYMETASEQNUM	-4
#define MYMETASMPTE	-5
#define MYCHANPREFIX	-6

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


/* possible values for State */
#define NEEDSTATUS 0
#define NEEDONEBYTE 1
#define NEEDTWOBYTES 2
#define VARIABLELENGTH 3

#define MESSAGESIZE 256
#define SCH_NOTEOFF 0
#define SCH_PHRASE 1
#define SCH_WAKE 2

#define FREEABLE 1
#define NOTFREEABLE 0

#define MAXPRIORITY 1000
#define DEFPRIORITY 500

#define disabled(s) ((s)->clicks==MAXCLICKS)



#ifdef OLDSTUFF
#endif

#define Pc (T->pc)
#define Stack (T->stack)
#define Stackp (T->stackp)
#define Stackend (T->stackend)
#define Firstframe (T->firstframe)
#define arg0_of_frame(f) ((f)-FRAMEHEADER-numval(*((f)-FRAME_VARSIZE_OFFSET)))
#define npassed_of_frame(f) ((f)-FRAME_NPASSED_OFFSET)
#define func_of_frame(f) ((f)-FRAME_FUNC_OFFSET)
#define fname_of_frame(f) ((f)-FRAME_FNAME_OFFSET)
#define ARG(n) (*(T->arg0+(n)))

#define isglobal(s) ((s)->stackpos==0)
/* #define isnoval(d) (((d).type==Noval.type)&&((d).u.val==Noval.u.val)) */
#define isnoval(d) (((d).u.val==Noval.u.val) && ((d).type==Noval.type) )
#define CHKNOVAL(d,s) if(isnoval(d)){ \
		sprintf(Msg1,"Uninitialized value (Noval) can't be handled by %s",s); \
		execerror(Msg1); \
	}

/* In function calls, there are PREARGSIZE things on the stack before */
/* the argument values.  Currently this is the func/obj/method values. */
#define PREARGSIZE 4
#define FRAME_PREARG_FUNC_OFFSET 0
#define FRAME_PREARG_REALOBJ_OFFSET 1
#define FRAME_PREARG_OBJ_OFFSET 2
#define FRAME_PREARG_METHOD_OFFSET 3

/* size of frame header */
#define FRAMEHEADER 9

/* offset of various things in the frame header */
#define FRAME_VARSIZE_OFFSET 1
#define FRAME_NPASSED_OFFSET 2
#define FRAME_METHOD_OFFSET 3
#define FRAME_OBJ_OFFSET 4
#define FRAME_REALOBJ_OFFSET 5
#define FRAME_PC_OFFSET 6
#define FRAME_FUNC_OFFSET 7
#define FRAME_FNAME_OFFSET 8
#define FRAME_LNUM_OFFSET 9

#ifdef __STDC__
typedef void (*PFCHAR)(char*);
typedef int (*INTFUNC2P)(unsigned char*, unsigned char*);
#else
typedef void (*PFCHAR)();
typedef int (*INTFUNC2P)();
#endif


/* The following macros are for (premature as always) optimization */

#define symname(s) ((s)->name.type==D_STR?(s)->name.u.str:dtostr((s)->name))

#define numdatum(l) ((_Dnumtmp_.u.val=(l)),_Dnumtmp_)

#define phnumused(p) ((p)->p_used)
#define phreallyused(p) ((p)->p_used+(p)->p_tobe)

#define phincruse(p) {if((p)!=NULL){((p)->p_tobe)++;}}
#define phdecruse(p) {if((p)!=NULL){ \
	if(((p)->p_used+(--((p)->p_tobe)))<=0)addtobechecked(p);}}

#define arrincruse(a) {if((a)!=NULL){((a)->h_tobe)++;}}
#define arrdecruse(a) {if((a)!=NULL){if(((a)->h_used+(--((a)->h_tobe)))<=0)httobechecked(a);}}

#define incruse(d) {if((d).type==D_PHR)phincruse((d).u.phr) else if((d).type==D_ARR)arrincruse((d).u.arr)}
#define decruse(d) {if((d).type==D_PHR)phdecruse((d).u.phr) else if((d).type==D_ARR)arrdecruse((d).u.arr)}

#define peekinto(x) x = *(Stackp - 1)
#define popinto(x) \
	if(Stackp==Stack) \
		underflow(); \
	else { \
		x = *(--Stackp); \
		decruse(x); \
	}
#define popnodecr(x) \
	if(Stackp==Stack) \
		underflow(); \
	else { \
		x = *(--Stackp); \
	}
#define pushchk if(Stackp>=Stackend)expandstack(T);
#define pushstk(x) *Stackp++ = (x);

/* #define enoughstack(n) if((Stackp+(n))>=Stackend)expandstack(T) */

/* Both pushm and pushexp are used to put things on the stack.  If it's an */
/* expression (ie. you don't want it evaluated multiple times), use pushexp(). */

#define pushm(x) pushchk;incruse(x);pushstk(x)
#define pushfunc(x) pushchk;pushstk(x)
#define pushnoinc(x) pushchk;pushstk(x)
#define pushnum(n) pushchk;pushstk(numdatum(n))
#define pushstr(p) pushchk;pushstk(strdatum(p))
#define pushm_notph(x) pushchk;incruse(x);pushstk(x)
#define pushexp(x) pushchk;{Datum dtmp;dtmp=(x);incruse(dtmp);pushstk(dtmp);}

#define pushnoinc_nochk(x) pushstk(x)
#define pushnum_nochk(n) pushstk(numdatum(n))
#define pushexp_nochk(x) {Datum dtmp;dtmp=(x);incruse(dtmp);pushstk(dtmp);}
#define pushfunc_nochk(x) pushstk(x)

#define setpc(i) Pc=(Unchar*)(i)
#define nextinode(in) ((in)->inext)

#define SCAN_FUNCCODE(p) *(p)++
#define SCAN_BLTINCODE(p) *(p)++
#define SKIP_SYMCODE(p) p+=Codesize[IC_SYM]
#define BLTINOF(p) *(p)
#define use_strcode() scan_strcode(&(Pc))
#define use_symcode() scan_symcode(&(Pc))
#define use_numcode() scan_numcode(&(Pc))
#define use_dblcode() scan_dblcode(&(Pc))
#define use_ipcode() scan_ipcode(&(Pc))
#define use_phrcode() scan_phrcode(&(Pc))
#define SCAN_NUMCODE(p) ((((B___=*(p)++) & 0xc0)==0)?(long)B___:scan_numcode1(&p,B___))

#define currsequence() (Seqnum)
#define usesequence() (++Seqnum)

#define codeis(c,v) (((c).u.func==(BYTEFUNC)(v)) && ((c).type==IC_FUNC))

#define chkrealoften() if(++Chkcount>*Throttle2){chkinput();chkoutput();Chkcount=0;}else

/* legal first characters of names */
#define isname1char(c) (isalpha(c)||c=='_')
/* legal subsequent characters of names */
#define isnamechar(c) (isalnum(c)||c=='_')

#ifdef FDEBUG
#define PRFUNC(x) if(*Debug)prfunc(x),tprint("\n")
#else
#define PRFUNC(x)
#endif

#define numval(d) ((d).type==D_NUM?(d).u.val:getnumval(d,0))
#define roundval(d) ((d).type==D_NUM?(d).u.val:getnumval(d,1))
#define dblval(d) ((d).type==D_DBL?(double)((d).u.dbl):getdblval(d))
#define numtype(d) ((d).type==D_NUM?(d).type:getnmtype(d))

#define FSTACKSIZE	16	/* Maximum # of nested files being read */
#define NPARAMS		64	/* Maximum # of macro parameters */
#define INITSTACKSIZE	100

#ifdef MDEP_OSC_SUPPORT
#endif

/*
 * first index is 0 (for defaults) or 0-based input port number+1,
 * second index is 0-based channel.  The value is the 1-based output port #.
 */


/* Global keykit variables */


#ifndef ARRAYHASHSIZE
/* #define ARRAYHASHSIZE 503 */
#define ARRAYHASHSIZE 251
#endif

#ifndef DEFLOWLIM
#define DEFLOWLIM 50000
#endif

#ifndef BUFSIZ
#define BUFSIZ 512
#endif

#define BIGBUFSIZ 4096

#ifndef MILLICLOCK
#define MILLICLOCK mdep_milliclock()
#endif

#ifndef MIDISENDLIMIT
#define MIDISENDLIMIT 100
#endif

#ifndef MINTEMPO
#define MINTEMPO 10000
#endif

#ifdef STATMIDI
Hey, mdep_statmidi is no longer used!
#endif

#ifdef OLDSTUFF
#ifndef STATMIDI
#define STATMIDI mdep_statmidi()
#endif
#endif

#ifndef CORELEFT
#define CORELEFT mdep_coreleft()
#endif

#ifndef PATHSEP
#define PATHSEP ":"
#endif

#ifndef SEPARATOR
#define SEPARATOR "/"
#endif

#define NONAMEPREFIX "__"

#define KEYVERSION "8.0"

/* These values might, e.g., be set to 'p' and 'P', if that's what the */
/* real function keys put out.  Depends on what mdep_getconsole() in mdep.c does. */
#ifndef FKEY1
#define FKEY1 'a'
#define FKEY13 'm'
#endif

#ifndef PIPES
#ifdef unix
#define PIPES	1
#endif
#endif

#ifndef YYMAXDEPTH
#define YYMAXDEPTH 9600
#endif

#define MAX_POLYGON_POINTS 8

#define KEYNCOLORS 64

#define funcinst(x) realfuncinst((BYTEFUNC)(x))
struct Pbitmap {
	INT16 xsize, ysize;	/* current size */
	INT16 origx, origy;	/* allocated size */
	unsigned char* ptr;
};

struct Kpoint {
	long x0;
	long y0;
};

struct Krect {
	long x0;
	long y0;
	long x1;
	long y1;
};

struct Kitem {
	Symstr name;
	int pos;
	struct Kmenu* nested;
	Dnode* args;
	struct Kitem* next;
};

struct Kmenu {
	struct Kitem* items;
	int nitems;
	struct Kmenu* next;

	INT16 x, y;	/* For now, the x,y of the menu is the same as */
			/* x0,y0 of the window enclosing it, but I forsee */
			/* the possibility of having titles on the menus. */
	INT16 header;	/* height of header at top of menu */
	INT16 width, height;
	INT16 offset;
	short made;	/* 0 if its Pbitmaps have not been created */
	short top;	/* menu item displayed at top */
	int choice;	/* ranges from 0 to shown(km)-1, i.e. it's */
			/* the currently-highlighted choice within */
			/* displayed items.  If < 0, it means that */
			/* nothing is highlighted. */
	int menusize;	/* Number of entries displayed - i.e. any number */
			/* more than this enables a scrollbar. */
};

#define WINDUNSCALED -2

#define MSCROLLWIDTH ((int)(*Menuscrollwidth)*mdep_fontwidth()/4) /* width of menu scroll bar */
#define mymin(a,b) ((a)>(b)?(b):(a))
#define shown(w) mymin((w)->km.nitems,(w)->km.menusize)
#define menuxarea(w) ((w)->km.width+5)
#define menuyarea(w) ((w)->km.height+4)
#define hasscrollbar(w) ((w)->km.offset!=0)

#define finished(n) durof(n)=0

struct Kwind {
	int wnum;
	int type;	/* WIND_* */
	int flags;	/* WFLAG_* */
	struct Kwind* next;
	struct Kwind* prev;

	/* Window area in physical coordinate space (0,0,mdep_maxx(),mdep_maxy()) */
	int x0, y0, x1, y1;

	/* These are shared by windows (MENU,TEXT) that have scrollbars */
	int inscroll;		/* whether mouse is in scrollbar (only for */
				/* WIND_TEXT, WIND_MENU) */
	int lasty;

	/* following fields used for WIND_TEXT */
	int tx0;		/* This is where text starts (taking into */
				/* account scroll bar)*/
	int currrow, currcol;	/* Current row and column within display area*/
				/* the top row of the display area is row 0. */
	int currx, curry;	/* Coordinates of currrow,currcol */
	int currcols;		/* Number of cols shown */
	int disprows;		/* Number of rows shown */
	char** bufflines;	/* Circular buffer of saved lines.  The */
				/* direction is reversed from what you might */
				/* think.  If toplnum is 50 (i.e. the 1st */
				/* line on the display is bufflines[50]), */
				/* then the 2nd display line is bufflines[49]*/
	int numlines;		/* Total number of lines in bufflines */
	char* currline;		/* active line */
	int currlnum;		/* index of that line in bufflines */
	int toplnum;		/* index (in bufflines) of top row in display*/
	int lastused;		/* last used line (often equal to currlnum) */

	/* following fields used for WIND_PHRASE */
	Symstr trk;
	Phrasepp pph;
	int showlow;
	int showhigh;
	long showstart;
	long showleng;
	int showbar;

	/* following fields used for WIND_MENU */
	/* NOTE: km SHOULD EVENTUALLY BE A POINTER, CAUSE KM TAKES A LOT OF */
	/* SPACE THAT SHOULDN'T BE USED FOR EVERY WINDOW. */
	struct Kmenu km;

	struct Pbitmap saveunder;  /* used when WFLAG_SAVEDUNDER is set*/
};

typedef struct Kmenu Kmenu;
typedef struct Kitem Kitem;
typedef struct Kwind Kwind;
typedef struct Kpoint Kpoint;
typedef struct Krect Krect;
typedef struct Pbitmap Pbitmap;

#define EMPTYBITMAP {0,0,0,0,0}

/* avoid recomputing the x value of w->showstart unless it's changed */
#define SHOWXSTART ((Lastst==w->showstart)?Lastxs:clktoxraw(w->showstart))
/* avoid recomputing the y value of w->showhigh unless it's changed */
#define SHOWYHIGH ((Lastsh==w->showhigh)?Lastys:pitchyraw(w,w->showhigh))

#define clktoxraw(clicks) ((w->showleng==0) ? 0 : (int)(((clicks)*Dispdx + Dispdx/2)/w->showleng))
#define clktox(clicks) (Disporigx+clktoxraw(clicks)-SHOWXSTART)

#define Disporigy (w->y0+1)
#define Disporigx (w->x0+1)
#define Dispcorny (w->y1-1)
#define Dispcornx (w->x1-1)
#define Dispdx (Dispcornx - Disporigx)
#define Dispdy (Dispcorny - Disporigy)

#define windxmax(w) ((w)->x1)
#define windymax(w) ((w)->y1)
#define windxmin(w) ((w)->x0)
#define windymin(w) ((w)->y0)

#define windnum(w) ((w)->wnum)

#define MAXWIND 128

#define WIND_GENERIC 1
#define WIND_PHRASE 2
#define WIND_TEXT 3
#define WIND_MENU 4

/* These must match the macro values MENU_* in sym.c */
#define M_NOCHOICE -1
#define M_BACKUP -2
#define M_UNDEFINED -3
#define M_MOVE -4
#define M_DELETE -5

/* The default is for windows to have borders */
#define WFLAG_NOBORDER 1
/* This bit only has meaning if the WFLAG_NOBORDER bit is 0 */
#define WFLAG_BUTTON 2
/* Initially this bit is 0.  It's set (and never cleared) when window is */
/* actually drawn. */
#define WFLAG_DRAWN 4
/* This bit means that the saveunder bitmap is set */
#define WFLAG_SAVEDUNDER 8
/* This bit is for menu buttons */
#define WFLAG_MENUBUTTON 16
/* This bit is for depressed menu buttons */
#define WFLAG_PRESSED 32

#define DISP_TEXT 0
#define DISP_LINE 1
#define DISP_RECT 2
#define DISP_FILL 3

#define TEXT_CENTER 0
#define TEXT_LEFT 1
#define TEXT_RIGHT 2

#define PREORDER 0
#define POSTORDER 1

#define NT_VISIBLE 1
#define NT_INVISIBLE 2
#define NT_CLIPPED 3

/*********/
/* NOTE THAT SOME OF THE VALUES BELOW MUST MATCH THE MACRO VALUES */
/* SET IN main.c FOR THE BUILT-IN KEYKIT MACROS. */
/*********/

/* values given to graph functions in mdep*.c */
#define P_CLEAR 0
#define P_STORE 1
#define P_XOR 2

/* values given to mdep_setcursor() */
#define M_NOTHING 0
#define M_ARROW 1
#define M_SWEEP 2
#define M_CROSS 3
#define M_LEFTRIGHT 4
#define M_UPDOWN 5
#define M_ANYWHERE 6
#define M_BUSY 7

#ifndef YYDEBUG
typedef union {
	Symbolp	sym;	/* symbol table pointer */
	Instnodep in;	/* machine instruction */
	int	num;	/* number of arguments */
	long	val;	/* numeric constant */
	DBLTYPE	dbl;	/* floating constant */
	char	*str;	/* string constant */
	Phrasep	phr;	/* phrase constant */
} YYSTYPE;
#endif

