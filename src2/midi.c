extern "C" {

#include <malloc.h>
#include <time.h>

/* We do NOT want the malloc call, here, to be replace with _malloc_dbg */
#define DONTDEBUG

#include "keymidi.h"
#include "key.h"
#include "d_mdep2.h"

int udp_send(PORTHANDLE mp, char* msg, int msgsize);

void key_start_capture();
void key_stop_capture();

#define CIRCULAR_BUFF_SIZE 1000
#define NUM_OF_OUT_BUFFS 8
#define MIDI_OUT_BUFFSIZE 32
#define NUM_OF_IN_BUFFS 6
#define MIDI_IN_BUFFSIZE 8096
#define EBUFFSIZE 128

#define MIDI_NOSUCH_DEV -2

/* extern FILE *df; */

extern HWND Khwnd;
HMIDIIN Kmidiin[MIDI_IN_DEVICES];
HMIDIOUT Kmidiout[MIDI_OUT_DEVICES];
int MidimapperOutIndex;
MIDIINCAPS midiInCaps[MIDI_IN_DEVICES];
MIDIOUTCAPS midiOutCaps[MIDI_OUT_DEVICES];

static MY_MIDI_BUFF *MidiInBuff = NULL;

HWND     hwndNotify;
int Nmidiin = 0;
int Nmidiout = 0;

LPCIRCULARBUFFER MidiInputBuffer;
LPCALLBACKINSTANCEDATA CallbackInputData[MIDI_IN_DEVICES];
LPCALLBACKINSTANCEDATA CallbackOutputData[MIDI_OUT_DEVICES];

#define MAXJOY 16 
int joyState[MAXJOY];
int joySize = 0;

static LPMIDIHDR newmidihdr(int);
static void freemidihdr(LPMIDIHDR);
static void midiouterror(int r, char *s);
static void midiinerror(int r, char *s);
static unsigned char *bytes = NULL;
static int sofar;
static int nbytes;

int
mdep_getnmidi(char *buff,int buffsize,int *port)
{
	printf("mdep_getnmidi called\n");
	return 0;
}

void
mdep_putnmidi(int n, char *cp, Midiport * pport)
{
	printf("mdep_putnmidi called\n");
}

static DWORD Inputdata = 99;

int
openmidiin(int i)
{
	printf("openmidiin called\n");
	return 1;
}

static int
closemidiin(int windevno)
{
	return 0;
}

static int
closemidiout(int windevno)
{
	return 0;
}

void
mdep_endmidi(void)
{
}

int
mdep_initmidi(Midiport *inputs, Midiport *outputs)
{
	return 0;
}

void
handlemidioutput(long long lParam, int windevno)
{
}

Datum
mdep_mdep(int argc)
{
	char *args[3];
	int n;
	Datum d;

	d = Nullval;
	/*
	 * Things past the first 3 args might be integers
	 */
	for ( n=0; n<3 && n<argc; n++ ) {
		Datum dd = ARG(n);
		if ( dd.type == D_STR ) {
			args[n] = needstr("mdep",dd);
		} else {
			args[n] = "";
		}
	}
	for ( ; n<3; n++ )
		args[n] = "";

	/*
	 * recognized commands are:
	 *     tcpip localaddresses
	 *     priority low/normal/high/realtime
	 *     popen {cmd} "rt"
	 *     popen {cmd} "wt" {string-to-write}
	 */

	if ( strcmp(args[0],"midi")==0 ) {
		execerror("mdep(\"midi\",...) is no longer used.  Use midi(...).\n");
	}
	else if ( strcmp(args[0],"gesture") == 0 ) {
	    execerror("mdep(\"gesture\",...): keykit not compiled with igesture support\n");
	}
	else if ( strcmp(args[0],"lcd") == 0 ) {
	    execerror("mdep(\"lcd\",...): keykit not compiled with lcd support\n");
	}
	else if ( strcmp(args[0],"osc") == 0 ) {

	    if ( strcmp(args[1],"send")==0 ) {
		char buff[512];
		int buffsize = sizeof(buff);
		int sofar = 0;
		char *tp;
		int fnum = neednum("Expecting fifo number ",ARG(2));
		Fifo *fptr;
		Datum d3;

		fptr = fifoptr(fnum);
		if ( fptr == NULL )
			execerror("No fifo numbered %d!?",fnum);

		d3 = ARG(3);
		if ( d3.type == D_ARR ) {
			Htablep arr = d3.u.arr;
			int cnt = 0;
			Symbolp s;
			int asize;
			Datum dd;
			char types[64];

			/* First one is the message (e.g. "/foo") */
			s = arraysym(arr,numdatum(0),H_LOOK);
			if ( s == NULL )
				execerror("First element of array not found?");
			dd = *symdataptr(s);
			if ( dd.type != D_STR )
				execerror("First element of array must be string");
			osc_pack_str(buff,buffsize,&sofar,dd.u.str);
			tp = types;
			*tp++ = ',';
			cnt = 1;
			asize = arrsize(arr);
			for ( n=1; n<asize; n++ ) {
				s = arraysym(arr,numdatum(n),H_LOOK);
				dd = *symdataptr(s);
				switch(dd.type){
				case D_NUM:
					*tp++ = 'i';
					break;
				case D_STR:
					*tp++ = 's';
					break;
				case D_DBL:
					*tp++ = 'f';
					break;
				default:
					execerror("Can't handle type %s!",atypestr(d.type));
				}
				cnt++;
			}
			*tp = '\0';
			osc_pack_str(buff,buffsize,&sofar,types);
			for ( n=1; n<asize; n++ ) {
				s = arraysym(arr,numdatum(n),H_LOOK);
				dd = *symdataptr(s);
				switch(dd.type){
				case D_NUM:
					osc_pack_int(buff,buffsize,&sofar,dd.u.val);
					break;
				case D_STR:
					osc_pack_str(buff,buffsize,&sofar,dd.u.str);
					break;
				case D_DBL:
					osc_pack_dbl(buff,buffsize,&sofar,dd.u.dbl);
					break;
				default:
					execerror("Can't handle type %s!",atypestr(d.type));
				}
			}
		} else {
			for ( n=3; n<argc; n++ ) {
				d = ARG(n);
				if ( d.type == D_STR ) {
					char *s = d.u.str;
					int c;
					while ( (c=*s++) != '\0' ) {
						buff[sofar++] = c;
					}
				} else if ( d.type == D_NUM ) {
					buff[sofar++] = (char)(numval(d));
				} else {
					execerror("Bad type of data given to osc send.");
					
				}
			}
		}
#if 0
		for(n=0;n<sofar;n++){
			tprint("[%d]",buff[n]);
		}
#endif
		
		udp_send(fptr->port,buff,sofar);
		d = numdatum(0);
	    }
	}
	else if ( strcmp(args[0],"tcpip")==0 ) {
	    if ( strcmp(args[1],"localaddresses")==0 ) {
			char *p;
			d = newarrdatum(0,3);
			p = mdep_localaddresses(d);
			if ( p )
				eprint("Error: %s\n",p);
		}
	}
	else if ( strcmp(args[0],"clipboard")==0 ) {
		if ( strcmp(args[1],"get")==0 ) {
			char *s = mdep_getclipboard();
			if ( s != NULL ) {
				d = strdatum(uniqstr(s));
			}
		} else if ( strcmp(args[1],"set")==0 ) {
			if ( mdep_setclipboard(args[2]) != 0 ) {
				d = numdatum(0);
			}
		} else {
			eprint("Error: unrecognized clipboard argument - %s\n",args[1]);
		}
	}
	else if ( strcmp(args[0],"sendinput")==0 ) {
		struct tagINPUT in;
		if ( strcmp(args[1],"keyboard")==0 ) {
			int r;
			int vk = neednum("Expecting integer keycode",ARG(2));
			int up = neednum("Expecting up/down value",ARG(3));
			in.type = INPUT_KEYBOARD;
			in.ki.wVk = vk;
			in.ki.wScan = 0;
			if ( up )
				in.ki.dwFlags = KEYEVENTF_KEYUP;
			else
				in.ki.dwFlags = 0;
			in.ki.time = 0;
			in.ki.dwExtraInfo = 0;
			r = SendInput(1,&in,sizeof(INPUT));
			d = numdatum(r);
		} else if ( strcmp(args[1],"mouse")==0 ) {
			eprint("Error: sendinput of mouse not implemented yet\n");
		} else {
			eprint("Error: unrecognized sendinput argument - %s\n",args[1]);
		}
	}
	else if ( strcmp(args[0],"joystick")==0 ) {
		if ( strcmp(args[1],"init")==0 ) {
			Datum joyinit(int);
			int millipoll = 10;	/* default is 10 milliseconds */

			if ( *args[2] != 0 )
				millipoll = atoi(args[2]);
			if ( millipoll < 1 )
				millipoll = 1;
			d = joyinit(millipoll);

		} else if ( strcmp(args[1],"release")==0 ) {
			void joyrelease();
			joyrelease();
		} else {
			eprint("Error: unrecognized joystick argument - %s\n",args[1]);
		}
	} else if ( strcmp(args[0],"priority")==0 ) {
		BOOL n = FALSE;
		long r = 0; 
		HANDLE p = GetCurrentProcess();
	    if ( strcmp(args[1],"realtime")==0 ) {
			n = SetPriorityClass(p,REALTIME_PRIORITY_CLASS);
		}
	    else if ( strcmp(args[1],"normal")==0 ) {
			n = SetPriorityClass(p,NORMAL_PRIORITY_CLASS);
		}
	    else if ( strcmp(args[1],"low")==0 ) {
			n = SetPriorityClass(p,IDLE_PRIORITY_CLASS);
		}
	    else if ( strcmp(args[1],"high")==0 ) {
			n = SetPriorityClass(p,HIGH_PRIORITY_CLASS);
		}
		else {
			n = FALSE;
			eprint("Error: unrecognized priority - %s\n",args[1]);
		}
		if ( n == FALSE ) {
			r = GetLastError();
			eprint("Error: getlasterror=%ld\n",r);
		}
		else
			r = 0;
		d = numdatum(r);
	}
	else if ( strcmp(args[0],"popen")==0 ) {
		FILE *f;
		int buffsize;
		char *p;
		int c;

		/*
		 * FOR SOME REASON, THIS CODE DOESN'T WORK.
		 * I HAVE NO IDEA WHAT'S WRONG.  The _popen
		 * always seems to return NULL.
		 */
		f = _popen(args[1],args[2]);
		if ( f == NULL ) {
			tprint("popen returned NULL\n");
			d = Nullval;
		}
		else {
			if ( args[2][0] == 'w' ) {
				char *ws = needstr("mdep",ARG(3));
				fprintf(f,"%s",ws);
				d = numdatum(0);
			}
			else {
				/* it's an 'r' */
				p = Msg2;
				buffsize = 0;
				while ( (c=getc(f)) >= 0 ) {
					makeroom(++buffsize,&Msg2,&Msg2size);
					*p++ = c;
				}
				*p = '\0';
				d = strdatum(uniqstr(Msg2));
			}
			_pclose(f);
		}
		
	}
	else {
		/* unrecognized command */
		eprint("Error: unrecognized mdep argument - %s\n",args[0]);
	}
	return d;
}

int
mdep_midi(int openclose, Midiport * p)
{
	return -1;
}

}
