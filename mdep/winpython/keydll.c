#include <windows.h>
#include <mmsystem.h>
#include <string.h>
#include "keydll.h"

HWND     hwndNotify ;

int FAR PASCAL
LibMain (HANDLE hInstance, WORD wDataSeg, WORD wHeapSize, LPSTR lpszCmdLine) {
	return 1 ;
}

int FAR PASCAL KeySetupDll (HWND hwnd) {

	hwndNotify = hwnd ;           // Save window handle for notification
	return 0 ;
}

void FAR PASCAL
KeyTimerFunc (UINT  wID, UINT  wMsg, DWORD dwUser, DWORD dw1, DWORD dw2) {

     PostMessage (hwndNotify, WM_KEY_TIMEOUT, 0, timeGetTime ()) ;
}

HWND     hwndNotify ;

/* midiInputHandler - Low-level callback function to handle MIDI input.
 *      Installed by midiInOpen().  The input handler takes incoming
 *      MIDI events and places them in the circular input buffer.  It then
 *      notifies the application by posting a WM_KEY_MIDIINPUT message.
 *
 *      This function is accessed at interrupt time, so it should be as 
 *      fast and efficient as possible.  You can't make any
 *      Windows calls here, except PostMessage().  The only Multimedia
 *      Windows call you can make are timeGetSystemTime(), midiOutShortMsg().
 *      
 *
 * Param:   hMidiIn - Handle for the associated input device.
 *          wMsg - One of the MIM_***** messages.
 *          dwInstance - Points to CALLBACKINSTANCEDATA structure.
 *          dwParam1 - MIDI data.
 *          dwParam2 - Timestamp (in milliseconds)
 *
 * Return:  void
 */     
void FAR PASCAL midiInputHandler(
HMIDIIN hMidiIn, 
WORD wMsg, 
DWORD dwInstance, 
DWORD dwParam1, 
DWORD dwParam2)
{
	static EVENT event;
	HWND h;
	LPCALLBACKINSTANCEDATA lpc;

	switch(wMsg) {
        case MIM_DATA:
		/* ignore active sensing */
		if ( LOBYTE(LOWORD(dwParam1)) == (BYTE)0xfe )
			break;
		/* fall through */
	case MIM_LONGDATA:
		lpc = (LPCALLBACKINSTANCEDATA)dwInstance;
		h = lpc->hWnd;
		if ( h == 0 )	// e.g. when we're shutting down
			break;
		event.dwDevice = lpc->dwDevice;
		event.data = dwParam1;		/* real MIDI data */
#ifdef EVENT_TIMESTAMP
		event.timestamp = dwParam2;
#endif
		event.islong = (wMsg==MIM_LONGDATA);
		PutEvent(lpc->lpBuf, (LPEVENT) &event);
		PostMessage(h,
			WM_KEY_MIDIINPUT,
			lpc->dwDevice,
			(DWORD)dwInstance);
		break;
	case MIM_OPEN:
		break;
	case MIM_CLOSE:
		break;
        case MIM_ERROR:
	case MIM_LONGERROR:
		lpc = (LPCALLBACKINSTANCEDATA)dwInstance;
		PostMessage(lpc->hWnd,
			WM_KEY_ERROR,
			lpc->dwDevice,
			(DWORD)dwInstance);
		break;
        default:
		break;
	}
}

/* midiOutputHandler - Low-level callback function to handle MIDI output.
 *
 * Param:   hMidiOut - Handle for the associated output device.
 *          wMsg - One of the MOM_***** messages.
 *          dwInstance - Points to CALLBACKINSTANCEDATA structure.
 *          dwParam1 - MIDI data.
 *          dwParam2 - Timestamp (in milliseconds)
 *
 * Return:  void
 */     
void FAR PASCAL midiOutputHandler(
HMIDIIN hMidiOut, 
WORD wMsg, 
DWORD dwInstance, 
DWORD dwParam1, 
DWORD dwParam2)
{
	LPCALLBACKINSTANCEDATA lpc;

	switch(wMsg) {
	case MOM_OPEN:
	case MOM_CLOSE:
		break;

        case MOM_DONE:
		/* The dwParam1 is a pointer to the MIDIHDR structure for */
		/* the block that was just completed */
		lpc = (LPCALLBACKINSTANCEDATA)dwInstance;
		PostMessage(lpc->hWnd,
			WM_KEY_MIDIOUTPUT,
			lpc->dwDevice,
			(DWORD)dwParam1);
		break;

        default:
		break;
    }
}

/* PutEvent - Puts an EVENT in a CIRCULARBUFFER.  If the buffer is full, 
 *      it sets the wError element of the CIRCULARBUFFER structure 
 *      to be non-zero.
 *
 * Params:  lpBuf - Points to the CIRCULARBUFFER.
 *          lpEvent - Points to the EVENT.
 *
 * Return:  void
*/
void FAR PASCAL PutEvent(LPCIRCULARBUFFER lpBuf, LPEVENT lpEvent)
{
	/* If the buffer is full, set an error and return. */
	if(lpBuf->dwCount >= lpBuf->dwSize){
		lpBuf->wError = 1;
		return;
	}
    
	/* Put the event in the buffer, bump the head pointer and byte count.*/
	*lpBuf->lpHead = *lpEvent;
    
	++lpBuf->lpHead;
	++lpBuf->dwCount;

	/* Wrap the head pointer, if necessary. */
	if(lpBuf->lpHead >= lpBuf->lpEnd)
		lpBuf->lpHead = lpBuf->lpStart;
}
