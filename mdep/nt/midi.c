#include <windows.h>
#include <mmsystem.h>
#include <commdlg.h>
#include <malloc.h>
#include <dos.h>
#include <time.h>
#include <io.h>

/* We do NOT want the malloc call, here, to be replaced with _malloc_dbg */
#define DONTDEBUG

#include "keymidi.h"
#include "key.h"
#include "d_mdep2.h"

#define __WINDOWS_MM__
#include "../rtmidi/cpp/rtmidi_c.h"

int udp_send(PORTHANDLE mp, char* msg, int msgsize);

BOOL GetButtonInput(int, int, BOOL*);
void key_start_capture();
void key_stop_capture();

#define EBUFFSIZE 128

#define MIDI_NOSUCH_DEV -2
#define MIDIBUFF_SIZE 8096

HWND     hwndNotify;

static int Nmidiin = 0;
static RtMidiInPtr rtmidiin[MIDI_IN_DEVICES];
static char* RtmidiInputNames[MIDI_IN_DEVICES];
static int midiInUserData[MIDI_IN_DEVICES];

static int Nmidiout = 0;
static RtMidiOutPtr rtmidiout[MIDI_OUT_DEVICES];
static char* RtmidiOutputNames[MIDI_OUT_DEVICES];

static unsigned char* bytes = NULL;
static int sofar;
static int nbytes;

// One midiInBuff for each input device
struct {
	char buff[MIDIBUFF_SIZE];
	char* readSoFar;
	char* nextToWrite;
	char* end;
} midiBuff[MIDI_IN_DEVICES];

/*
static char midibuff[MIDIBUFF_SIZE];
static char* midibuff_sofar = midibuff;
static char* midibuff_next = midibuff;
static char* midibuff_end = midibuff + MIDIBUFF_SIZE;
*/

static void midiouterror(int r, char* s);
static void midiinerror(int r, char* s);

int
mdep_getnmidi(char* buff, int buffsize, int* port)
{
	// Find the first device that has input

	int devno = -1; // in case no device has input
	for (int i = 0; i < Nmidiin; i++) {
		if (midiBuff[i].nextToWrite > midiBuff[i].readSoFar) {
			devno = i;
			break;
		}
	}
	if ( devno < 0 ) {
		if (port) {
			*port = 0;
		}
		return 0;
	}

	if (port) {
		*port = devno;
	}
	int gotten = 0;
	for ( int i=0; i<buffsize; i++ ) {
		if (midiBuff[devno].readSoFar >= midiBuff[devno].nextToWrite) {
			// we've reached the end of the input buffer, so reset things
			midiBuff[devno].readSoFar = midiBuff[devno].buff;
			midiBuff[devno].nextToWrite = midiBuff[devno].buff;
			return gotten;
		}
		buff[gotten] = *midiBuff[devno].readSoFar++;
		gotten++;
	}
	return gotten;
}

void
mdep_putnmidi(int n, char *cp, Midiport * pport)
{
	int windevno;

	windevno = pport->private1;
	if (windevno == MIDI_NOSUCH_DEV)
		return;

	int sofar = 0;
	while ( sofar < n ) {
		char *p = cp + sofar;
		int byte0 = *p & 0xff;
		int status = byte0 & 0xf0;
		int expecting = 0;
		switch (status) {
			case NOTEON:
			case NOTEOFF:
			case PRESSURE:
			case CONTROLLER:
			case PITCHBEND:
				expecting = 3;
				break;
			case PROGRAM:
			case CHANPRESSURE:
				expecting = 2;
				break;
		}
		switch (byte0) {
			case MIDISTART:
			case MIDICONTINUE:
			case MIDISTOP:
				expecting = 1;
		}
		if (expecting != 0) {
			// When we know the length to expect,
			// we allow putnmidi to send multiple messages
			rtmidi_out_send_message(rtmidiout[windevno], p, expecting);
			sofar += expecting;
		} else {
			// BUT for system messages, we expect only one
			// Ideally, this code should 
			rtmidi_out_send_message(rtmidiout[windevno], p, n);
			break;
		}
	}

	if (rtmidiout[windevno]->ok != true) {
		midiouterror(1, (char *)(rtmidiout[windevno]->msg));
		return;
	}
}

int
openmidiin(int windevno)
{
	midiBuff[windevno].readSoFar = midiBuff[windevno].buff;
	midiBuff[windevno].nextToWrite = midiBuff[windevno].buff;
	midiBuff[windevno].end = midiBuff[windevno].buff + MIDIBUFF_SIZE;
	rtmidi_open_port(rtmidiin[windevno], windevno, RtmidiInputNames[windevno]);
	return (rtmidiin[windevno]->ok == true) ? 0 : -1;
}

static int
closemidiin(int windevno)
{
	rtmidi_close_port(rtmidiin[windevno]);
	return (rtmidiin[windevno]->ok == true) ? 0 : -1;
}

static int
closemidiout(int windevno)
{
	if (windevno == MIDI_NOSUCH_DEV)
		return -1;

	rtmidi_close_port(rtmidiout[windevno]);
	return (rtmidiout[windevno]->ok == true) ? 0 : -1;
}

void
mdep_endmidi(void)
{
	int devno;

	for ( devno=0; devno<Nmidiin; devno++ )
		closemidiin(devno);
	for ( devno=0; devno<Nmidiout; devno++ )
		closemidiout(devno);
}

void
mdep_rtmidi_callback(double timeStamp, const unsigned char* message, size_t messageSize, void *userData) {

	// The userData is the device number
	int* up = (int*)(userData);
	int devno = *up;

	// Append to midibuff
	for (int i = 0; i < messageSize; i++) {
		if ( midiBuff[devno].nextToWrite >= midiBuff[devno].end ) {
			midiinerror(0,"midi input buffer overflow");
			break;
		}
		*midiBuff[devno].nextToWrite++ = message[i];
	}
}

void
mdep_push_midi_byte(unsigned char byte) {

}

int
mdep_initmidi(Midiport *inputs, Midiport *outputs)
{
	int r, i;

	// The first RtMidiIn and RtMidiOut instance is just to get the number of inputs and outputs.
	RtMidiInPtr rtin;
	RtMidiOutPtr rtout;
	rtin = rtmidi_in_create(RTMIDI_API_WINDOWS_MM, "keykit",1000);
	rtout = rtmidi_out_create(RTMIDI_API_WINDOWS_MM, "keykit");
	Nmidiout = rtmidi_get_port_count(rtout);
	Nmidiin = rtmidi_get_port_count(rtin);

	// We then create a separate RtMidiIn/Out for each port.  This is necessary
	// in order to receive and send things to all the ports simultaneously.
	// I.e. Each instance of RtMidiIn/Out can only handle a single connection.

	*Devmidi = uniqstr("winmm");

	int windevno;
	for (windevno = 0; windevno < Nmidiin; windevno++) {
		rtmidiin[windevno] = rtmidi_in_create(RTMIDI_API_WINDOWS_MM, "keykit", 1000);
		midiInUserData[windevno] = windevno;
		rtmidi_in_set_callback(rtmidiin[windevno], mdep_rtmidi_callback, &midiInUserData[windevno]);
	}
	for (windevno = 0; windevno < Nmidiout; windevno++) {
		rtmidiout[windevno] = rtmidi_out_create(RTMIDI_API_WINDOWS_MM, "keykit");
	}

	char bufOut[1024];
	int bufLen = sizeof(bufOut);

	for (i=0; i<Nmidiout; i++ ) {
		int ret = rtmidi_get_port_name(rtmidiout[i], i, bufOut, &bufLen);
		if ( ret < 0 ) {
			char msg[1024];
			sprintf(msg, "Can't get name for output port %d", i);
			mdep_popup(msg);
		}
		char *name = strsave(bufOut);
		RtmidiOutputNames[i] = name;
		outputs[i].name = name;
		outputs[i].private1 = i;
	}

	for ( ; i<Nmidiout; i++ ) {
		outputs[i].name = NULL;
		outputs[i].private1 = MIDI_NOSUCH_DEV;
	}

	/* Get the number of MIDI input devices.  Then get the capabilities of
	 * each device.
	 */
	for (i=0; i<Nmidiin; i++) {
		MIDIINCAPS midiInCaps;
		r = midiInGetDevCaps(i, (LPMIDIINCAPS) &midiInCaps,
                                sizeof(MIDIINCAPS));
		if(r) {
			midiinerror(r,"Error in midiInGetDevCaps: ");
			Nmidiin = i;		/* and admit no more devices */
			break;
		}
		inputs[i].name = uniqstr(midiInCaps.szPname);
		inputs[i].private1 = i;
		RtmidiInputNames[i] = inputs[i].name;
	}
	return 0;
}

static void
midiinerror(int r, char *s)
{
	char ebuff[EBUFFSIZE+2];
	int lng;

	strcpy(ebuff,s);
	lng = (int)strlen(ebuff);
	midiInGetErrorText(r, ebuff+lng, EBUFFSIZE-lng);
	lng = (int)strlen(ebuff);
	strcpy(ebuff+lng,"\r\n");
	tprint(ebuff); // mdep_popup(ebuff);
}

static void
midiouterror(int r, char *s)
{
	char ebuff[EBUFFSIZE+2];
	int lng;

	strcpy(ebuff,s);
	lng = (int)strlen(ebuff);
	midiOutGetErrorText(r, ebuff+lng, EBUFFSIZE-lng);
	lng = (int)strlen(ebuff);
	strcpy(ebuff+lng,"\r\n");
	tprint(ebuff); // mdep_popup(ebuff);
}

static int
mdep_setclipboard(char *text)
{
	HGLOBAL hGlobal;
	HANDLE h;
	LPTSTR szString;
	long leng;

	leng = (long)strlen(text);
	hGlobal = GlobalAlloc(GMEM_MOVEABLE, (leng+1)*sizeof(char));
	if (hGlobal == NULL) {
		eprint("Can't allocate clipboard text?.\n");
		return 0;
	}
	szString = (char *) GlobalLock(hGlobal);
	memcpy(szString, (char *) text, leng*sizeof(char));
	szString[leng] = (char) 0;
	GlobalUnlock(hGlobal);
	if (!OpenClipboard(NULL)) {
		eprint("Can't open clipboard (%d).\n",GetLastError());
		return 0;
	}
	EmptyClipboard();
	h = SetClipboardData(CF_TEXT, (HANDLE) hGlobal);
	if ( h == NULL ) {
		eprint("Can't set clipboard (%d).\n",GetLastError());
		CloseClipboard();
		return 0;
	}
	CloseClipboard();
	return 1;
}

static Symstr
mdep_getclipboard(void)
{
	Symstr s = NULL;

	if (!IsClipboardFormatAvailable(CF_TEXT))
		return Nullstr;

	if (OpenClipboard(NULL)) {
		HANDLE h = GetClipboardData(CF_TEXT);
		if ( h ) {
			LPTSTR lpt;
			lpt = GlobalLock(h);
			if ( lpt ) {
				s = uniqstr(lpt);
				GlobalUnlock(h);
			}
		}
		CloseClipboard();
		if ( s == NULL )
			s = Nullstr;
		return s;
	} else {
		eprint("Can't open clipboard (%d).\n",GetLastError());
		return Nullstr;
	}
}


#if KEYCAPTURE
int
startvideo()
{
	extern BOOL AppInit2(HINSTANCE hInst, HINSTANCE hPrev, int sw);
	extern HANDLE KhprevInstance;
	extern HANDLE Khinstance;
	extern int KnCmdShow;

	if(!AppInit2(Khinstance,KhprevInstance,KnCmdShow))
		return FALSE;
	return TRUE;
}

void
stopvideo()
{
	key_stop_capture();
}
#endif

#if KEYDISPLAY
int
startdisplay(int noborder, int width, int height)
{
	extern BOOL AppInit3(HINSTANCE , HINSTANCE , int, int, int, int );
	extern HANDLE KhprevInstance;
	extern HANDLE Khinstance;
	extern int KnCmdShow;

	if(!AppInit3(Khinstance,KhprevInstance,KnCmdShow,noborder,width,height))
		return FALSE;
	return TRUE;
}
#endif

/*
 * One grid for Red (normalized to take out average red)
 * One grid for Blue (normalized to take out average blue)
 * One grid for Green (normalized to take out average green)
 * One grid for Sum (normalized to take out average Sum)
 */
typedef unsigned int GRIDTYPE;
GRIDTYPE *GridRed = NULL;
GRIDTYPE *GridGreen = NULL;
GRIDTYPE *GridBlue = NULL;
GRIDTYPE *GridGrey = NULL;

GRIDTYPE *GridRedAvg = NULL;
GRIDTYPE *GridGreenAvg = NULL;
GRIDTYPE *GridBlueAvg = NULL;
GRIDTYPE *GridGreyAvg = NULL;

GRIDTYPE *GridRedAvgPrev = NULL;
GRIDTYPE *GridGreenAvgPrev = NULL;
GRIDTYPE *GridBlueAvgPrev = NULL;
GRIDTYPE *GridGreyAvgPrev = NULL;

int GridXsize;
int GridYsize;
int GridChanging;

void
setvideogrid(int gx, int gy)
{
	int gxysize = gx * gy;

	if ( GridRed != NULL ) {
		free(GridRed);
		free(GridGreen);
		free(GridBlue);
		free(GridGrey);

		free(GridRedAvg);
		free(GridGreenAvg);
		free(GridBlueAvg);
		free(GridGreyAvg);

		free(GridRedAvgPrev);
		free(GridGreenAvgPrev);
		free(GridBlueAvgPrev);
		free(GridGreyAvgPrev);
	}
	GridRed = malloc(gxysize*sizeof(GRIDTYPE));
	GridGreen = malloc(gxysize*sizeof(GRIDTYPE));
	GridBlue = malloc(gxysize*sizeof(GRIDTYPE));
	GridGrey = malloc(gxysize*sizeof(GRIDTYPE));

	GridRedAvg = malloc(gxysize*sizeof(GRIDTYPE));
	GridGreenAvg = malloc(gxysize*sizeof(GRIDTYPE));
	GridBlueAvg = malloc(gxysize*sizeof(GRIDTYPE));
	GridGreyAvg = malloc(gxysize*sizeof(GRIDTYPE));

	GridRedAvgPrev = malloc(gxysize*sizeof(GRIDTYPE));
	GridGreenAvgPrev = malloc(gxysize*sizeof(GRIDTYPE));
	GridBlueAvgPrev = malloc(gxysize*sizeof(GRIDTYPE));
	GridGreyAvgPrev = malloc(gxysize*sizeof(GRIDTYPE));

	memset(GridRedAvg,0,gxysize*sizeof(GRIDTYPE));
	memset(GridGreenAvg,0,gxysize*sizeof(GRIDTYPE));
	memset(GridBlueAvg,0,gxysize*sizeof(GRIDTYPE));
	memset(GridGreyAvg,0,gxysize*sizeof(GRIDTYPE));

	memset(GridRedAvgPrev,0,gxysize*sizeof(GRIDTYPE));
	memset(GridGreenAvgPrev,0,gxysize*sizeof(GRIDTYPE));
	memset(GridBlueAvgPrev,0,gxysize*sizeof(GRIDTYPE));
	memset(GridGreyAvgPrev,0,gxysize*sizeof(GRIDTYPE));

	GridXsize = gx;
	GridYsize = gy;
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
	else if ( strcmp(args[0],"env") == 0 ) {
	    if ( strcmp(args[1],"get")==0 ) {
		char *s = getenv(args[2]);
		if ( s != NULL ) {
			d = strdatum(uniqstr(s));
		} else {
			d = strdatum(Nullstr);
		}
	    } else {
		execerror("mdep(\"env\",... ) doesn't recognize %s\n",args[1]);
	    }
	}
	else if ( strcmp(args[0],"video") == 0 ) {
#if KEYCAPTURE
	    if ( strcmp(args[1],"capture")==0 ) {
		if ( strcmp(args[2],"stop") == 0 ) {
			key_stop_capture();
		} else if ( strcmp(args[2],"start") == 0 ) {
			int gx;
			int gy;
			Datum d3 = ARG(3);
			Datum d4 = ARG(4);

			key_start_capture();
			gx = roundval(d3);
			gy = roundval(d4);
			setvideogrid(gx,gy);
		} else {
			execerror("mdep(\"video\",\"capture\",...): %s not recognized\n",args[2]);
		}

	    } else if ( strcmp(args[1],"start")==0 ) {
		int gx = 32;
		int gy = 32;
		if (!startvideo())
			d = numdatum(0);
		else
			d = numdatum(1);

	    } else if ( strcmp(args[1],"get")==0
			&& *args[3] != 0 && *args[4] != 0 ) {

			Datum d3 = ARG(3);
			Datum d4 = ARG(4);
			int gx = roundval(d3);
			int gy = roundval(d4);
			int v;
			int offset = gy * GridXsize + gx;

			args[2] = needstr("mdep",ARG(2));

			if ( strcmp(args[2],"red")==0 )
				v = GridRedAvg[offset];
			else if ( strcmp(args[2],"green")==0 )
				v = GridGreenAvg[offset];
			else if ( strcmp(args[2],"blue")==0 )
				v = GridBlueAvg[offset];
			else if ( strcmp(args[2],"grey")==0 )
				v = GridGreyAvg[offset];
			else
				execerror("mdep(\"video\",\"get\",...): %s is unrecognized\n",args[2]);
			d = numdatum(v);

	    } else if ( strcmp(args[1],"getaverage")==0 ) {

			int gx, gy;
			long redtot = 0;
			long greentot = 0;
			long bluetot = 0;
			long greytot = 0;
			int redavg, greenavg, blueavg, greyavg;
			int nxy = GridXsize * GridYsize;

			for ( gx=0; gx<GridXsize; gx++ ) {
				for ( gy=0; gy<GridYsize; gy++ ) {
					int offset = gy * GridXsize + gx;
					int rv = GridRedAvgPrev[offset];
					int gv = GridGreenAvgPrev[offset];
					int bv = GridBlueAvgPrev[offset];
					redtot += rv;
					greentot += gv;
					bluetot += bv;
					greytot += (rv+gv+bv);
				}
			}
			redavg = redtot / nxy;
			greenavg = greentot / nxy;
			blueavg = bluetot / nxy;
			greyavg = greytot / nxy;

			d = newarrdatum(0,3);
			setarraydata(d.u.arr,
				Str_red,numdatum(redavg));
			setarraydata(d.u.arr,
				Str_green,numdatum(greenavg));
			setarraydata(d.u.arr,
				Str_blue,numdatum(blueavg));
			setarraydata(d.u.arr,
				Str_grey,numdatum(greyavg));

	    } else if ( strcmp(args[1],"getchange")==0
			&& *args[3] != 0 && *args[4] != 0 ) {

			Datum d3 = ARG(3);
			Datum d4 = ARG(4);
			int gx = roundval(d3);
			int gy = roundval(d4);
			int v;
			int dv;
			int offset = gy * GridXsize + gx;

			args[2] = needstr("mdep",ARG(2));

			if ( strcmp(args[2],"red")==0 ) {
				v = GridRedAvg[offset];
				dv = v - GridRedAvgPrev[offset];
				GridRedAvgPrev[offset] = v;
			} else if ( strcmp(args[2],"green")==0 ) {
				v = GridGreenAvg[offset];
				dv = v - GridGreenAvgPrev[offset];
				GridGreenAvgPrev[offset] = v;
			} else if ( strcmp(args[2],"blue")==0 ) {
				v = GridBlueAvg[offset];
				dv = v - GridBlueAvgPrev[offset];
				GridBlueAvgPrev[offset] = v;
			} else if ( strcmp(args[2],"grey")==0 ) {
				v = GridGreyAvg[offset];
				dv = v - GridGreyAvgPrev[offset];
				GridGreyAvgPrev[offset] = v;
			} else
				execerror("mdep(\"video\",\"get\",...): %s is unrecognized\n",args[2]);
			if ( dv == v )
				dv = 0;
			d = numdatum(dv);

	    } else {
		eprint("Error: unrecognized video argument - %s\n",args[1]);
	    }
#else
	    execerror("mdep(\"video\",...): keykit not compiled with video support\n");
#endif
	}
	else if ( strcmp(args[0],"gesture") == 0 ) {
	    execerror("mdep(\"gesture\",...): keykit not compiled with igesture support\n");
	}
	else if ( strcmp(args[0],"lcd") == 0 ) {
	    execerror("mdep(\"lcd\",...): keykit not compiled with lcd support\n");
	}
#if KEYDISPLAY
	else if ( strcmp(args[0],"display") == 0 ) {

	    if ( strcmp(args[1],"start")==0 ) {
		int gx = 32;
		int gy = 32;
		int width = neednum("Expecting integer width",ARG(2));
		int height = neednum("Expecting integer height",ARG(3));
		int noborder = 0;
		char *nbp = "xxx";

		if ( argc < 4 )
			execerror("mdep(\"display\",\"start\",...) needs at least 4 args\n");
		if ( argc > 4 ) {
			nbp = needstr("mdep display",ARG(4));
			noborder = (strcmp(nbp,"noborder")==0);
		}
		if (!startdisplay(noborder,width,height))
			d = numdatum(0);
		else
			d = numdatum(1);

	    }
	}
#endif
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
openmidiout(int windevno)
{
	int r = 0;

	char *outputName = RtmidiOutputNames[windevno];
	rtmidi_open_port(rtmidiout[windevno], windevno, outputName);
	if (rtmidiout[windevno]->ok != true) {
		char msg[256];
		sprintf(msg, "Error in nmidiOutOpen of '%s' : ", outputName);
		r = 1;
		midiouterror(r, msg);
	}
	return r;
}

int
mdep_midi(int openclose, Midiport * p)
{
	int r, windevno;

	switch (openclose) {
	case MIDI_CLOSE_INPUT:
		windevno = p->private1;
		r = closemidiin(windevno);
		break;
	case MIDI_OPEN_INPUT:
		windevno = p->private1;
		r = openmidiin(windevno);
		break;
	case MIDI_CLOSE_OUTPUT:
		windevno = p->private1;
		r = closemidiout(windevno);
		break;
	case MIDI_OPEN_OUTPUT:
		windevno = p->private1;
		r = openmidiout(windevno);
		break;
	default:
		/* unrecognized command */
		r = -1;
	}
	return r;
}

int KeySetupDll(HWND hwnd) {

	hwndNotify = hwnd;           // Save window handle for notification
	return 0;
}

void
KeyTimerFunc(UINT  wID, UINT  wMsg, DWORD dwUser, DWORD dw1, DWORD dw2) {

	PostMessage(hwndNotify, WM_KEY_TIMEOUT, 0, timeGetTime());
}
