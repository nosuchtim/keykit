/*-------------------------------------------------------
   KEYDLL.H header file for DLL module for KEY program
  -------------------------------------------------------*/

int FAR PASCAL KeySetupDll     (HWND) ;
int FAR PASCAL KeyGetval     (void) ;
void FAR PASCAL KeyTimerFunc (UINT, UINT, DWORD, DWORD, DWORD);

#define WM_KEY_TIMEOUT   (WM_USER + 1)
#define WM_KEY_ERROR    (WM_USER + 2)
#define WM_KEY_MIDIINPUT    (WM_USER + 3)
#define WM_KEY_MIDIOUTPUT    (WM_USER + 4)
#define WM_KEY_SOCKET    (WM_USER + 5)

/* Structure to represent a single MIDI event.  */

typedef struct event_tag
{
	DWORD dwDevice;	/* The index of the midi input device */
	DWORD timestamp;
	DWORD data;	/* for short events, this is the raw data */
			/* for long events, this is a pointer to MIDIHDR */
	WORD islong;
} EVENT;
typedef EVENT FAR *LPEVENT;

/* Structure to manage the circular input buffer.  */

typedef struct circularBuffer_tag
{
    LPEVENT hBuffer;        /* buffer handle */
    WORD    wError;         /* error flags */
    DWORD   dwSize;         /* buffer size (in EVENTS) */
    DWORD   dwCount;        /* byte count (in EVENTS) */
    LPEVENT lpStart;        /* ptr to start of buffer */
    LPEVENT lpEnd;          /* ptr to end of buffer (last byte + 1) */
    LPEVENT lpHead;         /* ptr to head (next location to fill) */
    LPEVENT lpTail;         /* ptr to tail (next location to empty) */
} CIRCULARBUFFER;
typedef CIRCULARBUFFER FAR *LPCIRCULARBUFFER;

/* Structure to pass instance data from the application
 * to the low-level callback function.
 */
typedef struct callbackInstance_tag
{
    HWND                hWnd;
    DWORD               dwDevice;
    LPCIRCULARBUFFER    lpBuf;
} CALLBACKINSTANCEDATA;

typedef CALLBACKINSTANCEDATA FAR *LPCALLBACKINSTANCEDATA;

void FAR PASCAL midiInputHandler(HMIDIIN, WORD, DWORD, DWORD, DWORD);
void FAR PASCAL midiOutputHandler(HMIDIIN, WORD, DWORD, DWORD, DWORD);
void FAR PASCAL PutEvent(LPCIRCULARBUFFER lpBuf, LPEVENT lpEvent);
LPCALLBACKINSTANCEDATA FAR PASCAL AllocCallbackInstanceData(void);
void FAR PASCAL FreeCallbackInstanceData(LPCALLBACKINSTANCEDATA lpBuf);
LPCIRCULARBUFFER AllocCircularBuffer(DWORD dwSize);
void FreeCircularBuffer(LPCIRCULARBUFFER lpBuf);
WORD FAR PASCAL GetEvent(LPCIRCULARBUFFER lpBuf, LPEVENT lpEvent);
