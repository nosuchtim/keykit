extern "C" {

#include "key.h"

Ktaskp T;		/* currently-active task */

int	Indef;
int	Inclass;
int	Inparams;
int	Inselect;
int	Globaldecl;
long	Wmsgsize;
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

FILE *Fin;
FILE *Fout;
int Keycnt;
int Errors;
int Doconsole;
int Gotanint;
int Errfileit;
int Dbg;

char Tty[] = "tty";
char *Infile = Tty;		/* current input file name */
char Autopop = 0;

static FILE *Fstack[FSTACKSIZE];	/* Nested FILEs being read */
static char *Fnstack[FSTACKSIZE];	/* The names of those files */
static int Lnstack[FSTACKSIZE];		/* Current line # in those files */
static int Popstack[FSTACKSIZE];	/* Whether to auto-pop on EOF */
static FILE **Fstackp = Fstack;
static char **Fnstackp = Fnstack;
static int *Lnstackp = Lnstack;
static int *Popstackp = Popstack;
static long Ungoti;
static int Maxpathleng = 0;
static Htablep Keylibtable = NULL;

char *Progname = "key";
int Macrosused = 0;
int Lineno = 1;

Instnodep Loopstack[FSTACKSIZE];
int Loopnum = -1;

Codep Fkeyfunc[NFKEYS];

char *stdinonly[] = { "-" };


/*
 * The index into this array is the port number minus 1.
 */
Midiport Midiinputs[MIDI_IN_DEVICES];
Midiport Midioutputs[MIDI_OUT_DEVICES];

void
initExterns() {

	Indef = 0;	/* >0 while parsing a function definition */
	Inclass = 0;	/* >0 while parsing a class definition */
	Inparams = 0;	/* 1 while parsing the parameters of a func def'n */
	Inselect = 0;	/* 1 while parsing a select {...} construct */
	Globaldecl = 0;	/* 1 while parsing a global statement. */

	Msg1size = 0;
	Msg2size = 0;
	Msg3size = 0;
	Wmsgsize = 0;
	Msgtsize = 0;
	Ungotsize = 0;
	Usestdio = 0;
	ReadytoEval = 0;
	Keycnt = 0;
	Errors = 0;
	Doconsole = 0;
	Gotanint = 0;
	Errfileit = 0;
	Dbg = 0;
	Tty = "tty";
	Infile = Tty;		/* current input file name */
	Autopop = 0;
	Progname = "key";
	Macrosused = 0;
	Lineno = 1;
	Loopnum = -1;
	stdinonly[0] = { "-" };
	Inerror = 0;
	Killchar = '@';
	Erasechar = '\b';
	Eofchar = 4;
	Intrchar = 0x7f;
	Consolefd = 0;
	Displayfd = -1;
	Midifd = -1;
	ConsoleEOF = 0;
	Nblocked = 0;
	Fifonum = 0;
	Default_fifotype = FIFOTYPE_UNTYPED;

	Fifotable = NULL;
	Topfifo = NULL;
	Freefifo = NULL;
	Midi_in_f = NULL;
	Midi_out_f = NULL;
	Consinf = NULL;
	Consoutf = NULL;
	Mousef = NULL;

	Fin = NULL;
	Fout = NULL;
	Keycnt = 0;
	Errors = 0;
	Doconsole = 0;
	Gotanint = 0;
	Errfileit = 0;
	Dbg = 0;
}

}
