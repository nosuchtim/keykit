#include <windows.h>
#include <mmsystem.h>
#include <commdlg.h>
#include <malloc.h>
#include <dos.h>
#include <time.h>
#include <io.h>
#include <direct.h>
#include <Mshare.h>

/* We do NOT want the malloc call, here, to be replace with _malloc_dbg */
#define DONTDEBUG

#include "keydll.h"
#include "keymidi.h"
#include "key.h"
#include "d_mdep2.h"

#define CIRCULAR_BUFF_SIZE 1000
#define NUM_OF_OUT_BUFFS 4
#define MIDI_OUT_BUFFSIZE 32
#define NUM_OF_IN_BUFFS 4
#define MIDI_IN_BUFFSIZE 8096
#define EBUFFSIZE 128

/* extern FILE *df; */

int Moutinit = 0;
int Mininit = 0;

short myRefNum;
short midiPort;

int Nmidiin = 0;
int Nmidiout = 0;

static Byte mbuffer[8096];
static Byte* embuffer = mbuffer+sizeof(mbuffer);
static Byte* firstone = NULL;
static Byte* nextavail = mbuffer;

#define addbyte(c) if(nextavail!=firstone){\
			if(firstone==NULL)\
				firstone = nextavail;\
			*nextavail++= (c);\
keyerrfile("addbyte c=0x%02x\n",c);\
			if(nextavail >= embuffer)\
				nextavail = mbuffer;\
			} else {\
keyerrfile("addbyte sees full buffer!\n");\
			}

int
midishare_hasmidi()
{
	if ( firstone != NULL )
		return 1;
	else
		return 0;
}

int
mdep_getnmidi(char *buff,int buffsize)
{
	int r;

	if ( ! Mininit ) {
		firstone = NULL;
		return 0;
	}
	if ( firstone == NULL ) {
		return 0;
	}
	r = 0;
keyerrfile("mdep_getnmidi start\n");
	while ( r < buffsize ) {
		if ( firstone == nextavail ) {
			firstone = NULL;
			break;
		}
keyerrfile("mdep_getnmidi c=%d\n",*firstone);
		*buff++ = *firstone++;
		if ( firstone >= embuffer )
			firstone = mbuffer;
		r++;
	}
keyerrfile("mdep_getnmidi returns r=%d\n",r);
	return r;
}

void
mdep_putnmidi(int n,char *cp)
{
	BYTE *p = (BYTE*)cp;

	if ( ! Moutinit )
		return;
	keyerrfile("mdep_putnmidi n=%d\n",n);
	if ( n <= 3 ) {
		int ch = (*cp & 0xf);
		int st = (*cp & 0xf0);

		if ( st == 0x90 ) {
			MidiEvPtr e = MidiNewEv(typeKeyOn);
			Chan(e)= ch+1;
			Port(e) = (Byte) midiPort;
			Pitch(e) = p[1];
			Vel(e) = p[2];
			Date(e) = 0;

			keyerrfile("MidiSend evtype=%d ch=%d vel=%d pitch=%d port=%d Date=%ld milli=%ld\n",e->evType,ch,Vel(e),Pitch(e),midiPort,Date(e),mdep_milliclock());
			MidiSendIm(myRefNum,e);
		} else if ( st == 0x80 ) {
			MidiEvPtr e = MidiNewEv(typeKeyOff);
			Chan(e)= ch+1;
			Port(e) = (Byte) midiPort;
			Pitch(e) = p[1];
			Vel(e) = p[2];
			Date(e) = 0;

			keyerrfile("MidiSend evtype=%d ch=%d vel=%d pitch=%d port=%d Date=%ld milli=%ld\n",e->evType,ch,Vel(e),Pitch(e),midiPort,Date(e),mdep_milliclock());

			MidiSendIm(myRefNum,e);
		}

		return;
	}
	else {
		return;
	}
}

int
openmidiin(int i)
{
	int r = 0;
	keyerrfile("openmidiin i=%d\n",i);

	return(r);
}

static int
closemidiin(void)
{
	keyerrfile("closemidiin\n");
	if ( Mininit == 0 )
		return -1;

	Mininit = 0;
	return 0;
}

static int
closemidiout()
{
	keyerrfile("closemidiout\n");
	if ( Moutinit == 0 )
		return -1;
	Moutinit = 0;
	return 0;
}

void
mdep_endmidi(void)
{
	MidiClose(myRefNum);
}

static void MSALARMAPI shareAlarm(short ref) {
	MidiEvPtr e;

	while ( e=MidiGetEv(ref) ) {
		switch( e->evType ) {
		case typeNote:
			keyerrfile("shareAlarm Note!\n");
			addbyte(0x90);
			addbyte(0x64);
			addbyte(0x64);
			break;
		case typeKeyOn:
			keyerrfile("shareAlarm KeyOn clock=%ld\n",mdep_milliclock());
			addbyte(0x90);
			addbyte(e->info.note.pitch);
			addbyte(e->info.note.vel);
			break;
		case typeKeyOff:
			keyerrfile("shareAlarm KeyOff clock=%ld\n",mdep_milliclock());
			addbyte(0x80);
			addbyte(e->info.note.pitch);
			addbyte(e->info.note.vel);
			break;
		case typeKeyPress:
			keyerrfile("shareAlarm KeyPress\n");
			break;
		case typeCtrlChange:
			keyerrfile("shareAlarm CtrlChange\n");
			break;
		case typeProgChange:
			keyerrfile("shareAlarm ProgChange\n");
			break;
		case typeChanPress:
			keyerrfile("shareAlarm ChanPress\n");
			break;
		case typePitchWheel:
		case typeSongPos:
		case typeSongSel:
		case typeClock:
		case typeStart:
		case typeContinue:
		case typeStop:
		case typeTune:
		case typeActiveSens:
		case typeReset:
		case typeSysEx:
			break;
#ifdef SAVETHIS
			{
			int count = MidiCountFields(e);
			MidiSEXPtr se = Link(LinkSE(e));
			if ( se ) {
				keyerrfile("shareAlarm sysexe count=%d\n",count);
				addbyte(0xf0);
				while ( count ) {
					Byte* bb = se->data;
					int n = ( count>=12 ? 12 : count);
					count -= n;
					while ( n-- > 0 ) {
						addbyte(*bb);
						bb++;
					}
				}
			} else {
				keyerrfile("shareAlarm sysexe null?\n");
			}
			}
			break;
#endif
		case typeStream:
			keyerrfile("shareAlarm e.type=%d\n",e->evType);
			break;
		default:
			keyerrfile("shareAlarm e.type=%d\n",e->evType);
			break;
		}
	}
}

int
mdep_initmidi(void)
{
	Moutinit = 1;
	Mininit = 1;

	if ( ! MidiShare() ) {
		keyerrfile("MidiShare() returns error\n");
		return 1;
	}
	keyerrfile("MidiShare version is %d\n",MidiGetVersion());

	myRefNum = MidiOpen("keykit");

	if ( myRefNum < 1 ) {
		keyerrfile("MidiOpen failed?\n");
		return 1;
	}

	keyerrfile("MidiShare myRefNum=%d\n",myRefNum);

	MidiSetRcvAlarm(myRefNum, shareAlarm);

#define PHYSMIDI_IO 0
	MidiConnect(PHYSMIDI_IO,myRefNum,TRUE);	/* receive events */
	MidiConnect(myRefNum,PHYSMIDI_IO,TRUE);	/* transmit events */
	midiPort = 1;

	return 0;
}

Datum
mdep_mdep(int argc)
{
	char *args[3];
	int n, devno;
	Datum d;

	d = Nullval;
	for ( n=0; n<3 && n<argc; n++ ) {
		args[n] = needstr("mdep",ARG(n));
	}
	for ( ; n<3; n++ )
		args[n] = "";

	/*
	 * recognized commands are:
	 *     midi input list
	 *     midi output list
	 *     midi input close
	 *     midi output close
	 *     midi input open
	 *     midi output open
	 *     midi input open {n}
	 *     midi output open {n}
	 *     priority low/normal/high/realtime
	 *     popen {cmd} "rt"
	 *     popen {cmd} "wt" {string-to-write}
	 */

	if ( strcmp(args[0],"midi")==0 ) {
	    if ( strcmp(args[1],"input")==0 ) {
		if ( strcmp(args[2],"list")==0 ) {
			d = newarrdatum(0,3);
#ifdef OLDSTUFF
			for ( n=0; n<Nmidiin && n<MAX_MIDI_DEVICES; n++ ) {
				nm = midiInCaps[n].szPname;
				setarraydata(d.u.arr,numdatum(n),
						strdatum(uniqstr(nm)));
			}
#endif
			/* d is an array of strings */
		}
		else if ( strcmp(args[2],"close")==0 ) {
#ifdef OLDSTUFF
			r = closemidiin();
			d = numdatum(r);
#endif
		}
		else if ( strcmp(args[2],"open")==0 ) {
		}
	    }
	    else if ( strcmp(args[1],"output")==0 ) {
		if ( strcmp(args[2],"list")==0 ) {
			d = newarrdatum(0,3);
#ifdef OLDSTUFF
			for ( n=0; n<Nmidiout && n<MAX_MIDI_DEVICES; n++ ) {
				nm = midiOutCaps[n].szPname;
				setarraydata(d.u.arr,numdatum(n),
						strdatum(uniqstr(nm)));
			}
#endif
			/* d is an array of strings */
		}
		else if ( strcmp(args[2],"close")==0 ) {
		}
		else if ( strcmp(args[2],"open")==0 ) {
			if ( argc > 3 )
				devno = neednum("mdep",ARG(3));
			else
				devno = -1;	/* MIDI_MAPPER */
			if ( devno >= Nmidiout )
				execerror("mdep(midi,output,open,#): No output # %d !?\n",devno);

			n = 0;
			Moutinit = 1;
			d = numdatum(n);
		}
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
	else if ( strcmp(args[0],"priority")==0 ) {
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
	}
	return d;
}

