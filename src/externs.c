#include "key.h"

// int errno;

int Tjt;
int	Indef;
int	Inclass;
int	Inparams;
int	Inselect;
int	Globaldecl;

char *Yytext;
char *Yytextend;
char *Buffer;
unsigned int Buffsize;
long Msg1size;
long Msg2size;
long Msg3size;
long Wmsgsize;
long Msgtsize;
char *Msg1;
char *Msg2;
char *Msg3;
char *Wmsg;
char *Msgt;
char *Pyytext;
char *Ungot;
long Ungotsize;
int Usestdio;
int ReadytoEval;

FILE *Fin;
FILE *Fout;
int Keycnt;
int Errors;
int Doconsole;
int Gotanint;
int Errfileit;
int Dbg;

char Tty[16];
char *Infile;
char Autopop;

FILE *Fstack[FSTACKSIZE];	/* Nested FILEs being read */
char *Fnstack[FSTACKSIZE];	/* The names of those files */
int Lnstack[FSTACKSIZE];		/* Current line # in those files */
int Popstack[FSTACKSIZE];	/* Whether to auto-pop on EOF */
FILE **Fstackp;
char **Fnstackp;
int *Lnstackp;
int *Popstackp;
long Ungoti;
int Maxpathleng;
Htablep Keylibtable;

struct bi_bitmap_t* Bitmaplist;

char *Progname;
int Macrosused;
int Lineno;

Instnodep Loopstack[FSTACKSIZE];
int Loopnum;

Codep Fkeyfunc[NFKEYS];

char *stdinonly[2];

int Argc;
char **Argv;

char *Stackbuff;
long Stackbuffsofar;
long Stackbuffsize;
int Inerror;
int Killchar;
int Erasechar;
int Eofchar;
int Intrchar;
Macro *Topmac;

int Anyrun;
int Cprio;

Datum lsdatum;
char * lsdir;
int lsdirleng;
Htablep Newarr;
char* Scachars[13];
int nbytenames;

char *Bytenames[] = {
	"i_pop",
	"i_dblpush",
	"i_stringpush",
	"i_phrasepush",
	"i_arrend",
	"i_arraypush",
	"i_incond",
	"i_divcode",
	"i_par",
	"i_amp",
	"i_lshift",
	"i_rightshift",
	"i_negate",
	"i_tilda",
	"i_lt",
	"i_gt",
	"i_le",
	"i_ge",
	"i_ne",
	"i_eq",
	"i_regexeq",
	"i_and1",
	"i_or1",
	"i_not",
	"i_noop",
	"i_popignore",
	"i_defined",
	"i_objdefined",
	"i_currobjdefined",
	"i_realobjdefined",
	"i_task",
	"i_undefine",
	"i_dot",
	"i_modulo",
	"i_addcode",
	"i_subcode",
	"i_mulcode",
	"i_xorcode",
	"i_dotassign",
	"i_moddotassign",
	"i_modassign",
	"i_varassign",
	"i_deleteit",
	"i_deletearritem",
	"i_readonlyit",
	"i_onchangeit",
	"i_eval",
	"i_vareval",
	"i_objvareval",
	"i_funcnamed",
	"i_lvareval",
	"i_gvareval",
	"i_varpush",
	"i_objvarpush",
	"i_callfunc",
	"i_objcallfuncpush",
	"i_objcallfunc",
	"i_array",
	"i_linenum",
	"i_filename",
	"i_forin1",
	"i_forin2",
	"i_popnreturn",
	"i_stop",
	"i_select1",
	"i_select2",
	"i_select3",
	"i_print",
	"i_goto",
	"i_tfcondeval",
	"i_tcondeval",
	"i_constant",
	"i_dotdotarg",
	"i_varg",
	"i_currobjeval",
	"i_constobjeval",
	"i_ecurrobjeval",
	"i_erealobjeval",
	"i_returnv",
	"i_return",
	"i_qmark",
	"i_forinend",
	"i_dosweepcont",
	"i_classinit",
	"i_pushinfo",
	"i_popinfo",
	"i_nargs",
	"i_typeof",
	"i_xy2",
	"i_xy4"
};

/* The order in this list MUST match the values of the I_* macros */
BYTEFUNC Bytefuncs[] = {
	i_pop,
	i_dblpush,
	i_stringpush,
	i_phrasepush,
	i_arrend,
	i_arraypush,
	i_incond,
	i_divcode,
	i_par,
	i_amp,
	i_lshift,
	i_rightshift,
	i_negate,
	i_tilda,
	i_lt,
	i_gt,
	i_le,
	i_ge,
	i_ne,
	i_eq,
	i_regexeq,
	i_and1,
	i_or1,
	i_not,
	i_noop,
	i_popignore,
	i_defined,
	i_objdefined,
	i_currobjdefined,
	i_realobjdefined,
	i_task,
	i_undefine,
	i_dot,
	i_modulo,
	i_addcode,
	i_subcode,
	i_mulcode,
	i_xorcode,
	i_dotassign,
	i_moddotassign,
	i_modassign,
	i_varassign,
	i_deleteit,
	i_deletearritem,
	i_readonlyit,
	i_onchangeit,
	i_eval,
	i_vareval,
	i_objvareval,
	i_funcnamed,
	i_lvareval,
	i_gvareval,
	i_varpush,
	i_objvarpush,
	i_callfunc,
	i_objcallfuncpush,
	i_objcallfunc,
	i_array,
	i_linenum,
	i_filename,
	i_forin1,
	i_forin2,
	i_popnreturn,
	i_stop,
	i_select1,
	i_select2,
	i_select3,
	i_print,
	i_goto,
	i_tfcondeval,
	i_tcondeval,
	i_constant,
	i_dotdotarg,
	i_varg,
	i_currobjeval,
	i_constobjeval,
	i_ecurrobjeval,
	i_erealobjeval,
	i_returnv,
	i_return,
	i_qmark,
	i_forinend,
	i_dosweepcont,
	i_classinit,
	i_pushinfo,
	i_popinfo,
	i_nargs,
	i_typeof,
	i_xy2,
	i_xy4
};

char* Grabbuff;
long Grabbuffsize;

int Midiok;

long Tempo;	/* Microseconds per beat */

long Milltempo;	/* Milliseconds per beat */

long Start;		/* Millsecond value at start of rtloop() */

long Midinow;		/* If MIDI clocks are in control, this is */
			/* current time in keykit clicks */
			/* THIS VALUE INCLUDES Nowoffset !! */

long Midimilli;	/* in milliseconds */

long Nextclick;	/* in milliseconds */

int Chkmouse;	/* if non-zero, there are mouse actions to be */
			/* checked. */

char Sustain[MIDI_OUT_DEVICES + 1][16];
/* one for each MIDI channel, keeping track of */
/* whether the sustain switch is down. */
char Portamento[MIDI_OUT_DEVICES + 1][16];
/* one for each MIDI channel, like Sustain */

char *Msg1;
char* Nullstr;
int Defvol, Defoct, Defchan, Defport;
DURATIONTYPE Defdur;
char *Defatt;
long Deftime;
long Def2time;
UINT16 Defflags;

/* Each phrase in the entire system is a member of one of the following lists */

Noteptr Freent;
Phrasep Topph;		/* Phrases in use */
Phrasep Freeph;		/* Free list, available for re-use by newph() */

int Numnotes;	/* Total number of notes in use. */
int Numalloc;	/* Total number of notes that have been allocated. */

Symlongp Mousebutt;
Symlongp Sweepquant, Menuymargin;
Symlongp Rtmouse;
Symlongp Dragquant;
Symlongp Keyinverse, Panraster;
Symlongp Bendrange, Bendoffset, Showtext, Showbar;
Symlongp Volstem, Volstemsize, Colors, Colornotes;
Symlongp Inverse, Menusize, Menujump, Menuscrollwidth, Menusize;
Symlongp Textscrollsize;

int Pmode;
int Backcolor;
int Forecolor;
int Pickcolor;
int Lightcolor;
int Darkcolor;

Kwind *Wroot;	/* root window */
Kwind *Wprintf;

long Lastst;
int Lastxs;
long Lastsh;
int Lastys;

Instnodep* Iseg;
Instnodep* Lastin;
Instnodep* Future;

int Maxiseg;
int Niseg;
Instcode Stopcode;

Htablep Fifotable;
Fifo *Topfifo;
Fifo *Freefifo;
int Nblocked;
long Fifonum;
int Default_fifotype;

Fifo *Midi_in_f;
Fifo *Midi_out_f;
Fifo *Consinf;
Fifo *Consoutf;
Fifo *Mousef;

int State;	/* The current state of the finite state machine. */
			/* It indicates what we're currently looking for. */

actfunc Currfunc;/* This is the 'midiaction' function for the */
				/* current MIDI message being processed. */

int Currchan;	/* This is the current channel, ie. the channel # */
			/* on the latest 'channel message' status byte. */

Unchar* Currmessage;	/* Current message buffer */

int Messleng;	/* Size of currently allocated message */

int Messindex;	/* Index of next byte to go into */
			/* 'Currmessage'.  When Messindex */
			/* gets >= Messleng, the 'Currmessage' */
			/* is reallocated to a larger size. */

int Runnable;	/* If non-zero, the current MIDI message */
			/* can use the "running status byte" feature. */

struct midiaction Midi;
int Currchan;

Noteptr Pend;		/* list of pending note-offs */
FILE *Trktmp;
char Tmpfname[16];	/* enough space for "#xxxxx.tmp" */
long Trksize;
FILE *Outf;
double Clickfactor;
int Laststat;	/* NOTEON, NOTEOFF, PRESSURE, etc. */

Kwind* Topwind;
Kwind* Freewind;
Htablep Windhash;

int Menuysize;

int Mf_nomerge;		/* 1 => continue'ed system exclusives are */
				/* not collapsed. */
long Mf_currtime;		/* current time in delta-time units */
int Mf_skipinit;		/* 1 if initial garbage should be skipped */

FILE *Mf;
long Mf_toberead;
int Tracknum;
Phrasep Noteq;
Phrasep Currph;
int Numq;
double Clickfactor;
Htablep Mfarr;
int Mformat;

void
initExterns(void)
{
	Bitmaplist = NULL;
	Tjt = 0;
	Indef = 0;
	Inclass = 0;
	Inparams = 0;
	Inselect = 0;
	Globaldecl = 0;
	Msg1size = 0;
	Msg2size = 0;
	Msg3size = 0;
	Wmsgsize = 0;
	Msgtsize = 0;
	Ungotsize = 0;
	Usestdio = 0;
	ReadytoEval = 0;
	Fin = NULL;
	Fout = NULL;
	Keycnt = 0;
	Errors = 0;
	Doconsole = 0;
	Gotanint = 0;
	Errfileit = 0;
	Dbg = 0;
	
	strcpy(Tty,"tty");
	Infile = Tty;
	Autopop = 0;
	Fstackp = Fstack;
	Fnstackp = Fnstack;
	Lnstackp = Lnstack;
	Popstackp = Popstack;
	Ungoti = 0;
	Maxpathleng = 0;
	Keylibtable = NULL;
	
	Progname = "key";
	Macrosused = 0;
	Lineno = 1;
	Loopnum = -1;
	stdinonly[0] = "-";
	stdinonly[1] = NULL;
	
	Stackbuff = NULL;
	Stackbuffsofar = 0;
	Stackbuffsize = 0;
	Inerror = 0;
	Killchar = '@';
	Erasechar = '\b';
	Eofchar = 4;
	Intrchar = 0x7f;
	Topmac = NULL;
	Anyrun = 0;
	Cprio = 0;
	Scachars[0] = "c";
	Scachars[1] = "c+";
	Scachars[2] = "d";
	Scachars[3] = "e-";
	Scachars[4] = "e";
	Scachars[5] = "f";
	Scachars[6] = "f+";
	Scachars[7] = "g";
	Scachars[8] = "a-";
	Scachars[9] = "a";
	Scachars[10] = "b-";
	Scachars[11] = "b";
	Scachars[12] = "c";
	
	nbytenames = sizeof(Bytenames)/sizeof(Bytenames[0]);
	
	Grabbuff = NULL;
	Grabbuffsize = 0;
	
	Midiok = 0;
	
	Tempo = 500000L;
	
	Milltempo = 500;
	
	Midimilli = 0;
	
	Nextclick = -1;
	
	Chkmouse = 0;
	
	Nullstr = "";
	Deftime = 0L;
	Def2time = 0L;
	Defflags = 0;
	
	Freent = NULL;
	Topph = NULL;
	Freeph = NULL;
	
	Numnotes = 0;
	Numalloc = 0;
	
	Pmode = -1;
	Backcolor = 0;
	Forecolor = 1;
	Pickcolor = 2;
	Lightcolor = 3;
	Darkcolor = 4;
	
	Wroot = NULL;
	Wprintf = NULL;
	
	Lastst = -1;
	Lastsh = -1;
	
	Iseg = NULL;
	Lastin = NULL;
	Future = NULL;
	
	Maxiseg = 0;
	Niseg = -1;
	
	Fifotable = NULL;
	Topfifo = NULL;
	Freefifo = NULL;
	Nblocked = 0;
	Fifonum = 0;
	Default_fifotype = 0;
	
	Midi_in_f = NULL;
	Midi_out_f = NULL;
	Consinf = NULL;
	Consoutf = NULL;
	Mousef = NULL;
	
	State = NEEDSTATUS;
	Currfunc = NULL;
	Currchan = 0;
	Currmessage = NULL;
	Messleng = 0;
	Messindex = 0;
	Runnable = 0;
	
	memset(&Midi, 0, sizeof(struct midiaction));
	
	Pend = NULL;
	Clickfactor = 1.0;
	Laststat = 0;
	
	Topwind = NULL;
	Freewind = NULL;
	Windhash = NULL;
	
	Menuysize = 0;
	Mf_nomerge = 0;
	Mf_currtime = 0L;
	Mf_skipinit = 1;
	Mf_toberead = 0L;
	Numq = 0;
	Clickfactor = 1.0;
}