/*
 * The define of _WIN32_WINNT here is in order to
 * cause winuser.h to include the definiton of
 * tagINPUT and other things for the SendInput function.
 */
#define _WIN32_WINNT 0x0500

#include <windows.h>
#include <mmsystem.h>
#include <commdlg.h>
#include <malloc.h>
#include <dos.h>
#include <time.h>
#include <io.h>

/* We do NOT want the malloc call, here, to be replace with _malloc_dbg */
#define DONTDEBUG

#include "keydll.h"
#include "keymidi.h"
#include "key.h"
#include "d_mdep2.h"

BOOL GetButtonInput(int,int,BOOL *);
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

#define devnoOutIndex(d) (((d)==MIDI_MAPPER)?(MidimapperOutIndex):(d))

HMIDIIN Kmidiin[MIDI_IN_DEVICES];
HMIDIOUT Kmidiout[MIDI_OUT_DEVICES];
int MidimapperOutIndex;
MIDIINCAPS midiInCaps[MIDI_IN_DEVICES];
MIDIOUTCAPS midiOutCaps[MIDI_OUT_DEVICES];
int Nmidiin = 0;
int Nmidiout = 0;
LPCIRCULARBUFFER MidiInputBuffer;

typedef struct mymidiinbuff {
	LPMIDIHDR midihdr;
} MY_MIDI_BUFF;

static MY_MIDI_BUFF *MidiInBuff = NULL;

LPCALLBACKINSTANCEDATA CallbackInputData[MIDI_IN_DEVICES];
LPCALLBACKINSTANCEDATA CallbackOutputData[MIDI_OUT_DEVICES];

#define MAXJOY 16 
int joyState[MAXJOY];
int joySize = 0;

static LPMIDIHDR newmidihdr(int);
static int InitMidiInBuff(int);
static void freemidihdr(LPMIDIHDR);
static void midiouterror(int r, char *s);
static void midiinerror(int r, char *s);
static unsigned char *bytes = NULL;
static int sofar;
static int nbytes;

int
mdep_getnmidi(char *buff,int buffsize,int *port)
{
	static EVENT ev;
	static unsigned char smallbuff[3];
	static int waslong;
	LPMIDIHDR lpMidi;
	int r;

	if ( port )
		*port = 0;
	if ( bytes == NULL ) {
		if ( GetEvent(MidiInputBuffer,&ev) == 0 )
			return 0;
		if ( port ) {
			*port = ev.dwDevice;
		}
		if ( ev.islong ) {
			lpMidi = (LPMIDIHDR)ev.data;
			if ( ((lpMidi->dwFlags) & MHDR_DONE) == 0 )
				mdep_popup("Hey, MHDR_DONE not set in dwFlags!?");
			bytes = lpMidi->lpData;
			nbytes = (int)(lpMidi->dwBytesRecorded);
			sofar = 0;
		}
		else {
			BYTE statusbyte;
			smallbuff[0] = LOBYTE(LOWORD(ev.data));
			statusbyte = smallbuff[0] & (BYTE)0xf0;

			switch ( statusbyte ) {

			/* Three byte events */
			case NOTEOFF:
			case NOTEON:
			case PRESSURE:
			case CONTROLLER:
			case PITCHBEND:
				nbytes = 3;
				break;

			/* Two byte events */
			case PROGRAM:
			case CHANPRESSURE:
				nbytes = 2;
				break;

			/* MIDI system events (0xf0 - 0xff) */
			case SYSTEMMESSAGE:
			    switch(statusbyte) {
				/* Two byte system events */
				case MTCQUARTERFRAME:
				case SONGSELECT:
					nbytes = 2;
					break;
				/* Three byte system events */
				case SONGPOSPTR:
					nbytes = 3;
					break;
				/* One byte system events */
				default:
					nbytes = 1;
					break;
			    }
			    break;
            
			default:
				/* unknown event !? */
				nbytes = 0;
				break;
			}
			if ( nbytes > 1 ) {
				smallbuff[1] = HIBYTE(LOWORD(ev.data));
				if ( nbytes > 2 )
					smallbuff[2] = LOBYTE(HIWORD(ev.data));
			}
			bytes = smallbuff;
			sofar = 0;
		}
	}
	r = 0;
	if ( bytes != NULL ) {
		char *bp = buff;
		while ( r < buffsize && sofar < nbytes ) {
			*bp++ = bytes[sofar++];
			r++;
		}
		if ( sofar >= nbytes ) {
			/* We've used up all the bytes */
			bytes = NULL;
			if ( ev.islong ) {
				/* give buffer back to the MIDI input device */
				int i = (int)(ev.dwDevice);
				if ( i < 0 || i >= Nmidiin ) {
					mdep_popup("Hey, bad ev.dwDevice!?");
				}
				else {
					midiInPrepareHeader(Kmidiin[i],
						(LPMIDIHDR)(ev.data),sizeof(MIDIHDR));
					midiInAddBuffer(Kmidiin[i],
						(LPMIDIHDR)(ev.data),sizeof(MIDIHDR));
				}
			}
		}
	}
	return r;
}

void
mdep_putnmidi(int n, char *cp, Midiport * pport)
{
	BYTE *p = (BYTE*)cp;
	BYTE *q;
	LPMIDIHDR midihdr;
	int r;
	union {
		DWORD dwData;
		BYTE bData[4];
	} u;
	HMIDIOUT km;
	int windevno;
	int mydevno;

	windevno = pport->private1;
	mydevno = devnoOutIndex(windevno);
	if ( windevno == MIDI_NOSUCH_DEV )
		return;

	km = Kmidiout[mydevno];

	if ( km == 0 )
		return;
	if ( n <= 3 ) {
		u.bData[0] = (n>0) ? p[0] : 0;
		u.bData[1] = (n>1) ? p[1] : 0;
		u.bData[2] = (n>2) ? p[2] : 0;
		u.bData[3] = 0;
		r = midiOutShortMsg(km, u.dwData);
		if ( r ) {
			midiouterror(r,"Error in midiOutShortMsg: ");
			return;
		}
	}
	else {
		midihdr = newmidihdr(n);
		if ( midihdr == 0 ) {
			mdep_popup("Unable to allocate midihdr in putnmidi!?");
			return;
		}
		r = midiOutPrepareHeader(km, midihdr,sizeof(MIDIHDR));
		if ( r ) {
			midiouterror(r,"Error in midiOutPrepareHeader: ");
			return;
		}
		for ( q=midihdr->lpData; n-- > 0; ) {
			*q++ = *p++;
		}
		r = midiOutLongMsg(km,midihdr,sizeof(MIDIHDR));
		if ( r ) {
			midiouterror(r,"Error in midiOutLongMsg: ");
			return;
		}
	}
}

int
openmidiin(int i)
{
	int r;

	CallbackInputData[i]->hWnd = Khwnd;
	CallbackInputData[i]->dwDevice = i;
	CallbackInputData[i]->lpBuf = MidiInputBuffer;

	r = midiInOpen((LPHMIDIIN)&(Kmidiin[i]),
			  i,
			  (DWORD_PTR)midiInputHandler,
			  (DWORD_PTR)(CallbackInputData[i]),
			  CALLBACK_FUNCTION);
	if(r) {
		char msg[256];
		/* can't open */
		Kmidiin[i] = 0;
		FreeCallbackInstanceData(CallbackInputData[i]);
		sprintf(msg,"Error in midiInOpen of '%s' : ",Midiinputs[i].name);
		midiinerror(r,msg);
		return(r);
	}
	else {
		/* successful open, with function callbacks */
		if ( InitMidiInBuff(i) ) {
			midiInStart(Kmidiin[i]);
		}
		else {
			Kmidiin[i] = 0;
			mdep_popup("Unable to allocate Midi Buffers!?");
			return(1);
		}
	}
	return(r);
}

static int
closemidiin(int windevno)
{
	if ( CallbackInputData[windevno] )
		CallbackInputData[windevno]->hWnd = 0;	/* so callbacks don't cause messages */

	if ( Kmidiin[windevno] != 0 ) {
#define THIS_CAUSES_A_HANG_ON_SOME_SYSTEMS 1
#ifdef THIS_CAUSES_A_HANG_ON_SOME_SYSTEMS
		midiInReset(Kmidiin[windevno]);
#endif
		midiInReset(Kmidiin[windevno]);
		midiInClose(Kmidiin[windevno]);
		Kmidiin[windevno] = 0;
	}
	return 0;
}

static int
closemidiout(int windevno)
{
	HMIDIOUT km;
	int mydevno = devnoOutIndex(windevno);

	km = Kmidiout[mydevno];
	if ( km == 0 )
		return -1;

	/* timeEndPeriod((UINT)(*Millires)); - what was this for? */

	midiOutClose(km);
	Kmidiout[mydevno] = 0;

	return 0;
}

void
mdep_endmidi(void)
{
	int devno;

	for ( devno=0; devno<MIDI_OUT_DEVICES; devno++ )
		closemidiout(devno);
	for ( devno=0; devno<MIDI_IN_DEVICES; devno++ )
		closemidiin(devno);
}

int
mdep_initmidi(Midiport *inputs, Midiport *outputs)
{
	int r, i;

	*Devmidi = uniqstr("winmm");

	/* Allocate a circular buffer for low-level MIDI input.  This buffer
	 * is filled by the low-level callback function and emptied by the
	 * application when it receives MM_MIDIINPUT messages.
	 */
	MidiInputBuffer = AllocCircularBuffer((DWORD)(CIRCULAR_BUFF_SIZE));
	if (MidiInputBuffer == NULL) {
		mdep_popup("Not enough memory available for input buffer.");
		return 1;
	}

	for (i=0; i<MIDI_OUT_DEVICES; i++ ) {
		CallbackOutputData[i] = AllocCallbackInstanceData();
		if (CallbackOutputData[i] == NULL) {
			mdep_popup("Not enough memory available!?");
			return 1;
		}
	}

	Nmidiout = midiOutGetNumDevs();
	for (i=0; (i<Nmidiout) && (i<MIDI_OUT_DEVICES); i++) {
		r = midiOutGetDevCaps(i, (LPMIDIOUTCAPS) &midiOutCaps[i],
                                sizeof(MIDIOUTCAPS));
		if(r) {
			midiouterror(r,"Error in midiOutGetDevCaps: ");
			Nmidiout = i;		/* and admit no more devices */
			break;
		}
		outputs[i].name = uniqstr(midiOutCaps[i].szPname);
		outputs[i].private1 = i;
	}
	/*
	 * Add MIDI_MAPPER to the list.
	 */
	if ( Nmidiout < (MIDI_OUT_DEVICES-1) && i < (MIDI_OUT_DEVICES-1) ) {
		outputs[i].name = uniqstr("MIDI_MAPPER");
		outputs[i].private1 = MIDI_MAPPER;
		MidimapperOutIndex = i;
		i++;
		Nmidiout++;
	}
	for ( ; i<MIDI_OUT_DEVICES; i++ ) {
		outputs[i].name = NULL;
		outputs[i].private1 = MIDI_NOSUCH_DEV;
	}

	/* Get the number of MIDI input devices.  Then get the capabilities of
	 * each device.
	 */
	Nmidiin = midiInGetNumDevs();
#if THIS_MESSAGE_IS_BOGUS
	if (!Nmidiin) {
		tprint("There are no MIDI input devices.");
		return 1;
	}
#endif
	for (i=0; (i<Nmidiin) && (i<MIDI_IN_DEVICES); i++) {
		r = midiInGetDevCaps(i, (LPMIDIINCAPS) &midiInCaps[i],
                                sizeof(MIDIINCAPS));
		if(r) {
			midiinerror(r,"Error in midiInGetDevCaps: ");
			Nmidiin = i;		/* and admit no more devices */
			break;
		}
		inputs[i].name = uniqstr(midiInCaps[i].szPname);
		inputs[i].private1 = i;
	}
	for ( i=0; i<Nmidiin; i++ ) {
		if ((CallbackInputData[i] = AllocCallbackInstanceData())==NULL){
			mdep_popup("Not enough memory available.");
			return 1;
		}
	}
	for ( ; i<MIDI_IN_DEVICES; i++ ) {
		CallbackInputData[i] = NULL;
	}

	return 0;
}

static LPMIDIHDR
newmidihdr(int sz)
{
	LPMIDIHDR lpMidi;
	HPSTR lpData;

	lpData = (HPSTR) GlobalAlloc(0, (DWORD)sz);
	if(lpData == NULL)
		return 0;
	    
	lpMidi = (LPMIDIHDR) GlobalAlloc(0, (DWORD)sizeof(MIDIHDR));
	if(lpMidi == NULL)
		return 0;
	    
	lpMidi->lpData = lpData;
	lpMidi->dwBufferLength = sz;
	lpMidi->dwBytesRecorded = 0;
	lpMidi->dwUser = 0;
	lpMidi->dwFlags = 0;
	return lpMidi;
}

static void
freemidihdr(LPMIDIHDR midihdr)
{
	GlobalFree(midihdr->lpData);
	GlobalFree(midihdr);
}

void
handlemidioutput(long long lParam, int windevno)
{
	LPMIDIHDR midihdr;
	HMIDIOUT km;
	int mydevno;

	if ( windevno < -1 || windevno > MAX_PORT_VALUE ) {
		keyerrfile("handlemidioutput invalid windevno=%lx  lParam=%lx\n",(long)windevno,(long)lParam);
		return;
	}
	mydevno = devnoOutIndex(windevno);
	km = Kmidiout[mydevno];
	if ( km ) {
		midihdr = (LPMIDIHDR) lParam;
		midiOutUnprepareHeader(km,midihdr,sizeof(MIDIHDR));
		freemidihdr(midihdr);
	}
}

static int
InitMidiInBuff(int i)
{
	int n;

	if ( MidiInBuff ) {
		for ( n=0; n<NUM_OF_IN_BUFFS; n++ ) {
			midiInUnprepareHeader(Kmidiin[i],
				MidiInBuff[n].midihdr,sizeof(MIDIHDR));
			freemidihdr(MidiInBuff[n].midihdr);
		}
		free(MidiInBuff);
	}

	MidiInBuff = malloc( NUM_OF_IN_BUFFS * sizeof (MY_MIDI_BUFF) );
	if ( MidiInBuff == NULL )
		return 0;

	for ( n=0; n<NUM_OF_IN_BUFFS; n++ ) {
	
		MidiInBuff[n].midihdr = newmidihdr(MIDI_IN_BUFFSIZE);

		midiInPrepareHeader(Kmidiin[i],
			MidiInBuff[n].midihdr,sizeof(MIDIHDR));
		midiInAddBuffer(Kmidiin[i],
			MidiInBuff[n].midihdr,sizeof(MIDIHDR));
	}
	return 1;
}

/*
 * circbuf.c - Routines to manage the circular MIDI input buffer.
 *      This buffer is filled by the low-level callback function and
 *      emptied by the application.  Since this buffer is accessed
 *      by a low-level callback, memory for it must be allocated
 *      exactly as shown in AllocCircularBuffer().
 */

/*
 * AllocCircularBuffer -    Allocates memory for a CIRCULARBUFFER structure 
 * and a buffer of the specified size.
 *
 * Params:  dwSize - The size of the buffer, in events.
 *
 * Return:  A pointer to a CIRCULARBUFFER structure identifying the 
 *      allocated display buffer.  NULL if the buffer could not be allocated.
 */

static LPCIRCULARBUFFER
AllocCircularBuffer(DWORD dwSize)
{
    LPCIRCULARBUFFER lpBuf;
    LPEVENT lpMem;
    
    lpBuf = (LPCIRCULARBUFFER) GlobalAlloc(0,(DWORD)sizeof(CIRCULARBUFFER));
    if ( lpBuf == NULL )
        return NULL;
    
    lpMem = (LPEVENT) GlobalAlloc(0, dwSize * sizeof(EVENT));
    if ( lpMem == NULL )
        return NULL;
    
    lpBuf->hBuffer = lpMem;
    lpBuf->wError = 0;
    lpBuf->dwSize = dwSize;
    lpBuf->dwCount = 0L;
    lpBuf->lpStart = lpMem;
    lpBuf->lpEnd = lpMem + dwSize;
    lpBuf->lpTail = lpMem;
    lpBuf->lpHead = lpMem;
        
    return lpBuf;
}

/* FreeCircularBuffer - Frees the memory for the given CIRCULARBUFFER 
 * structure and the memory for the buffer it references.
 *
 * Params:  lpBuf - Points to the CIRCULARBUFFER to be freed.
 *
 * Return:  void
 */

static void
FreeCircularBuffer(LPCIRCULARBUFFER lpBuf)
{
    GlobalFree(lpBuf->hBuffer);
    GlobalFree(lpBuf);
}

/* GetEvent - Gets a MIDI event from the circular input buffer.  Events
 *  are removed from the buffer.  The corresponding PutEvent() function
 *  is called by the low-level callback function, so it must reside in
 *  the callback DLL.
 *
 * Params:  lpBuf - Points to the circular buffer.
 *          lpEvent - Points to an EVENT structure that is filled with the
 *              retrieved event.
 *
 * Return:  Returns non-zero if successful, zero if there are no 
 *   events to get.
 */

static WORD FAR PASCAL
GetEvent(LPCIRCULARBUFFER lpBuf, LPEVENT lpEvent)
{
    /* If no event available, return.
     */
    if(lpBuf->dwCount <= 0)
        return 0;
    
    /* Get the event.
     */
    *lpEvent = *lpBuf->lpTail;
    
    /* Decrement the byte count, bump the tail pointer.
     */
    --lpBuf->dwCount;
    ++lpBuf->lpTail;
    
    /* Wrap the tail pointer, if necessary.
     */
    if(lpBuf->lpTail >= lpBuf->lpEnd)
        lpBuf->lpTail = lpBuf->lpStart;

    return 1;
}

/* AllocCallbackInstanceData - Allocates a CALLBACKINSTANCEDATA
 *      structure.  This structure is used to pass information to the
 *      low-level callback function, each time it receives a message.
 *
 * Params:  void
 *
 * Return:  A pointer to the allocated CALLBACKINSTANCE data structure.
 */

static LPCALLBACKINSTANCEDATA FAR PASCAL
AllocCallbackInstanceData(void)
{
    LPCALLBACKINSTANCEDATA lpBuf;
    
    lpBuf = (LPCALLBACKINSTANCEDATA) GlobalAlloc(0, (DWORD)sizeof(CALLBACKINSTANCEDATA));
    return lpBuf;
}

/* FreeCallbackInstanceData - Frees the given CALLBACKINSTANCEDATA structure.
 *
 * Params:  lpBuf - Points to the CALLBACKINSTANCEDATA structure to be freed.
 *
 * Return:  void
 */

static void FAR PASCAL
FreeCallbackInstanceData(LPCALLBACKINSTANCEDATA lpBuf)
{
    GlobalFree(lpBuf);
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
openmidiout(int windevno)
{
	int mydevno = devnoOutIndex(windevno);
	int r;

	CallbackOutputData[mydevno]->hWnd = Khwnd;         
	CallbackOutputData[mydevno]->dwDevice = mydevno;
	r = midiOutOpen (
		&Kmidiout[mydevno],
		windevno,
		(DWORD_PTR)midiOutputHandler,
		(DWORD_PTR)CallbackOutputData[mydevno],
		(DWORD) CALLBACK_FUNCTION );

	if ( r ) {
		char msg[256];
		sprintf(msg,"Error in nmidiOutOpen of '%s' : ",Midioutputs[mydevno].name);
		midiouterror(r,msg);
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

