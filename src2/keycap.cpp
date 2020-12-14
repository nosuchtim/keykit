//------------------------------------------------------------------------------
// File: KeyCap.cpp
//
// Desc: Video Capture sample for DirectShow
//
// Copyright (c) 1993-2001 Microsoft Corporation.  All rights reserved.
//------------------------------------------------------------------------------

#include "keyoptions.h"

#if KEYCAPTURE

#include <windows.h>
#include <dbt.h>
#include <streams.h>
#include <mmreg.h>
#include <msacm.h>
#include <fcntl.h>
#include <io.h>
#include <stdio.h>
#include <commdlg.h>
// #include <atlbase.h>
#include <string.h>

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifdef WIN32_LEAN_AND_MEAN
#undef WIN32_LEAN_AND_MEAN
#endif

#define _ATL_APARTMENT_THREADED
#define WIN32_LEAN_AND_MEAN		// Exclude rarely-used stuff from Windows headers

// #include <atlbase.h>
extern CComModule _Module;
// #include <atlcom.h>

#include "qedit.h"
#include <windowsx.h>
#include <mmsystem.h>

BOOL  statusInit(HANDLE hInst, HANDLE hPrev);
void  statusUpdateStatus(HWND hwnd, LPCTSTR lpsz);
int statusGetHeight(void);

extern "C" {

extern void keyerrfile(char *fmt,...);
typedef unsigned int GRIDTYPE;
extern GRIDTYPE *GridRed;
extern GRIDTYPE *GridGreen;
extern GRIDTYPE *GridBlue;
extern GRIDTYPE *GridGrey;

extern GRIDTYPE *GridRedAvg;
extern GRIDTYPE *GridGreenAvg;
extern GRIDTYPE *GridBlueAvg;
extern GRIDTYPE *GridGreyAvg;

extern GRIDTYPE *GridRedAvgPrev;
extern GRIDTYPE *GridGreenAvgPrev;
extern GRIDTYPE *GridBlueAvgPrev;
extern GRIDTYPE *GridGreyAvgPrev;

extern int GridXsize;
extern int GridYsize;
extern int GridChanging;

}

#include "keycap.h"

extern TCHAR szStatusClass[];

BOOL  statusInit(HANDLE hInst, HANDLE hPrev);
void  statusUpdateStatus(HWND hwnd, LPCTSTR lpsz);
int statusGetHeight(void);

// you can never have too many parentheses!
#define ABS(x) (((x) > 0) ? (x) : -(x))

// An application can advertise the existence of its filter graph
// by registering the graph with a global Running Object Table (ROT).
// The GraphEdit application can detect and remotely view the running
// filter graph, allowing you to 'spy' on the graph with GraphEdit.
//
// To enable registration in this sample, define REGISTER_FILTERGRAPH.
//
#ifdef  DEBUG
#define REGISTER_FILTERGRAPH
#endif


//------------------------------------------------------------------------------
// Global data
//------------------------------------------------------------------------------
HINSTANCE ghInstApp;
HACCEL ghAccel;
HFONT  ghfontApp;
TEXTMETRIC gtm;
TCHAR gszAppName[]=TEXT("KeyCap");
HWND ghwndApp, ghwndStatus;
HDEVNOTIFY ghDevNotify;
PUnregisterDeviceNotification gpUnregisterDeviceNotification;
PRegisterDeviceNotification gpRegisterDeviceNotification;
DWORD g_dwGraphRegister=0;

int callbackcount = 0;

// This semi-COM object is a callback COM object for the sample grabber
//
class CFakeCallback : public ISampleGrabberCB 
{
	char *s;
	BITMAPINFO bminfo;
	int xsize;
	int ysize;
	
public:
	void tjtinit(BITMAPINFO b) {
		s = "unset";
		bminfo = b;
		xsize = bminfo.bmiHeader.biWidth;
		ysize = bminfo.bmiHeader.biHeight;
	
	}

    STDMETHODIMP_(ULONG) AddRef() { return 2; }
    STDMETHODIMP_(ULONG) Release() { return 1; }

    STDMETHODIMP QueryInterface(REFIID riid, void ** ppv)
    {
        if (riid == IID_ISampleGrabberCB || riid == IID_IUnknown) 
        {
            *ppv = (void *) static_cast<ISampleGrabberCB *>(this);
            return NOERROR;
        }    
        return E_NOINTERFACE;
    }

    STDMETHODIMP SampleCB( double SampleTime, IMediaSample * pSample )
    {
	callbackcount++;

	// Allocate space for the DIB buffer
	long dl = pSample->GetActualDataLength();

	REFERENCE_TIME tstart, tend;
	int hr = pSample->GetTime(&tstart,&tend);
	if ( hr != S_OK ) {
		// debuglog << "Unable to get time of mediasample?\n";
		return 0;
	}

	BYTE *psamplebuff = NULL;
	hr = pSample->GetPointer(&psamplebuff);
	if ( hr != S_OK ) {
		// debuglog << "Unable to get pointer to mediasample?\n";
		return 0;
	}

	// keyerrfile("GridChanging to 1\n");
	GridChanging=1;

	/* compute total */

	int bytesperpix = 3;
	int offset = 0;
	int x, y;

	int gxysize = GridXsize * GridYsize;
	int totpercell = (xsize * ysize) / gxysize;

	memset(GridRed,0,gxysize*sizeof(GRIDTYPE));
	memset(GridGreen,0,gxysize*sizeof(GRIDTYPE));
	memset(GridBlue,0,gxysize*sizeof(GRIDTYPE));
	memset(GridGrey,0,gxysize*sizeof(GRIDTYPE));

	for ( y=0; y<ysize; y++ ) {
		int ybytes = y * (xsize * bytesperpix);
		BYTE *sampleptr = psamplebuff + ybytes;
		int scaledy = y * GridYsize / ysize;
		if ( scaledy >= GridYsize ) {
			scaledy = GridYsize-1;
		}
		int offsety = (GridYsize-1-scaledy) * GridXsize;
		for ( x=0; x<xsize; x++ ) {
			unsigned char *p = sampleptr + x*bytesperpix;
			int blueval = *p++;
			int greenval = *p++;
			int redval = *p++;
			int greyval = (redval + greenval + blueval);

			int scaledx = x * GridXsize / xsize;
			if ( scaledx >= GridXsize ) {
				scaledx = GridXsize-1;
			}
			offset = scaledx + offsety;

			GridRed[offset] += redval;
			GridGreen[offset] += greenval;
			GridBlue[offset] += blueval;
			GridGrey[offset] += greyval;

		}
	}

	offset = 0;
	for ( y=0; y<GridYsize; y++ ) {
		for ( x=0; x<GridXsize; x++ ) {
			GridRedAvg[offset] = GridRed[offset] / totpercell;
			GridGreenAvg[offset] = GridGreen[offset] / totpercell;
			GridBlueAvg[offset] = GridBlue[offset] / totpercell;
			GridGreyAvg[offset] = GridGrey[offset] / totpercell;
			offset++;
		}
	}

	GridChanging=0;

        return 0;
    }

    STDMETHODIMP BufferCB( double SampleTime, BYTE * pBuffer, long BufferLen )
    {
        return 0;
    }

};

struct _capstuff {
    ICaptureGraphBuilder2 *pBuilder;
    IVideoWindow *pVW;
    IMediaEventEx *pME;
    IAMDroppedFrames *pDF;
    IAMVideoCompression *pVC;
    IAMVfwCaptureDialogs *pDlg;
    IAMStreamConfig *pASC;      // for audio cap
    IAMStreamConfig *pVSC;      // for video cap
    IBaseFilter *pGrabber;
    ISampleGrabber *pGrabberInterface;
    IBaseFilter *pNull2;
    CFakeCallback pCallback;
    IBaseFilter *pVCap, *pACap;
    IGraphBuilder *pFg;
    BOOL fCaptureGraphBuilt;
    BOOL fPreviewGraphBuilt;
    BOOL fCapturing;
    BOOL fPreviewing;
    bool fDeviceMenuPopulated;
    IMoniker *rgpmVideoMenu[10];
    IMoniker *pmVideo;
    double FrameRate;
    BOOL fWantPreview;
    long lCapStartTime;
    long lCapStopTime;
    WCHAR wachFriendlyName[120];
    BOOL fUseTimeLimit;
    BOOL fUseFrameRate;
    DWORD dwTimeLimit;
    int iFormatDialogPos;
    int iSourceDialogPos;
    int iDisplayDialogPos;
    int iVCapDialogPos;
    int iACapDialogPos;
    int iVCapCapturePinDialogPos;
    int iVCapPreviewPinDialogPos;
    int iACapCapturePinDialogPos;
    long lDroppedBase;
    long lNotBase;
    BOOL fPreviewFaked;
    int iVideoInputMenuPos;
    LONG NumberOfVideoInputs;
    HMENU hMenuPopup;
    int iNumVCapDevices;
} gcap;


CComModule _Module;


//------------------------------------------------------------------------------
// Funciton Prototypes
//------------------------------------------------------------------------------
typedef LONG(PASCAL *LPWNDPROC)(HWND, UINT, WPARAM, LPARAM); // pointer to a window procedure
LONG WINAPI AppWndProc(HWND hwnd, UINT uiMessage, WPARAM wParam, LPARAM lParam);
LONG PASCAL AppCommand(HWND hwnd, unsigned msg, WPARAM wParam, LPARAM lParam);
BOOL CALLBACK AboutDlgProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);
void ErrMsg(LPTSTR sz,...);
int DoDialog(HWND hwndParent, int DialogID, DLGPROC fnDialog, long lParam);
int FAR PASCAL FrameRateProc(HWND hDlg, UINT Message, UINT wParam, LONG lParam);
int FAR PASCAL TimeLimitProc(HWND hDlg, UINT Message, UINT wParam, LONG lParam);
int FAR PASCAL PressAKeyProc(HWND hDlg, UINT Message, UINT wParam, LONG lParam);
void TearDownGraph(void);
BOOL BuildCaptureGraph();
BOOL BuildPreviewGraph();
void UpdateStatus(BOOL fAllStats);
void AddDevicesToMenu();
void ChooseDevices(TCHAR *szVideo);
void ChooseDevices(IMoniker *pmVideo);
void ChooseFrameRate();
BOOL InitCapFilters();
void FreeCapFilters();
BOOL StopPreview();
BOOL StartPreview();
BOOL StopCapture();
BOOL StartCapture();
DWORDLONG GetSize(LPCTSTR tach);
void MakeMenuOptions();
void OnClose();


extern "C" {
void key_start_capture() {
            if(gcap.fPreviewing)
                StopPreview();
            if(gcap.fPreviewGraphBuilt)
                TearDownGraph();
            BuildCaptureGraph();
            StartCapture();
}
void key_stop_capture() {
            StopCapture();
            if(gcap.fWantPreview) {
                    BuildPreviewGraph();
                    StartPreview();
            }
}
}


// Adds/removes a DirectShow filter graph from the Running Object Table,
// allowing GraphEdit to "spy" on a remote filter graph if enabled.
HRESULT AddGraphToRot(IUnknown *pUnkGraph, DWORD *pdwRegister);
void RemoveGraphFromRot(DWORD pdwRegister);


//------------------------------------------------------------------------------
// Name: SetAppCaption()
// Desc: Set the caption to be the application name followed by the capture file
//------------------------------------------------------------------------------
void SetAppCaption()
{
    TCHAR tach[_MAX_PATH + 80];

    lstrcpyn(tach, gszAppName, NUMELMS(tach));
    SetWindowText(ghwndApp, tach);
}


extern "C"
{
/*----------------------------------------------------------------------------*\
|   AppInit2( hInst, hPrev)                                                     |
|                                                                              |
|   Description:                                                               |
|       This is called when the application is first loaded into               |
|       memory.  It performs all initialization that doesn't need to be done   |
|       once per instance.                                                     |
|                                                                              |
|   Arguments:                                                                 |
|       hInstance       instance handle of current instance                    |
|       hPrev           instance handle of previous instance                   |
|                                                                              |
|   Returns:                                                                   |
|       TRUE if successful, FALSE if not                                       |
|                                                                              |
\*----------------------------------------------------------------------------*/
BOOL AppInit2(HINSTANCE hInst, HINSTANCE hPrev, int sw) 
{
    WNDCLASS    cls;
    HDC         hdc;

    const DWORD  dwExStyle = 0;

    CoInitialize(NULL);
    DbgInitialise(hInst);

    /* Save instance handle for DialogBoxs */
    ghInstApp = hInst;

    ghAccel = LoadAccelerators(hInst, MAKEINTATOM(ID_APP));

    if(!hPrev) {
        /*
        *  Register a class for the main application window
        */
        cls.hCursor        = LoadCursor(NULL,IDC_ARROW);
        cls.hIcon          = LoadIcon(hInst, TEXT("KeyCapIcon"));
        cls.lpszMenuName   = MAKEINTATOM(ID_APP);
        cls.lpszClassName  = MAKEINTATOM(ID_APP);
        cls.hbrBackground  = (HBRUSH)(COLOR_WINDOW + 1);
        cls.hInstance      = hInst;
        cls.style          = CS_BYTEALIGNCLIENT | CS_VREDRAW | CS_HREDRAW | CS_DBLCLKS;
        cls.lpfnWndProc    = (WNDPROC) AppWndProc;
        cls.cbWndExtra     = 0;
        cls.cbClsExtra     = 0;

        if(!RegisterClass(&cls))
            return FALSE;
    }

    // Is this necessary?
    ghfontApp = (HFONT)GetStockObject(ANSI_VAR_FONT);
    hdc = GetDC(NULL);
    SelectObject(hdc, ghfontApp);
    GetTextMetrics(hdc, &gtm);
    ReleaseDC(NULL, hdc);

    ghwndApp=CreateWindowEx(dwExStyle,
        MAKEINTATOM(ID_APP),    // Class name
        gszAppName,             // Caption
        // Style bits
        WS_OVERLAPPEDWINDOW | WS_CLIPCHILDREN,
        CW_USEDEFAULT, 0,       // Position
        320,300,                // Size
        (HWND)NULL,             // Parent window (no parent)
        (HMENU)NULL,            // use class menu
        hInst,                  // handle to window instance
        (LPSTR)NULL             // no params to pass on
        );

    // create the status bar
    statusInit(hInst, hPrev);
    ghwndStatus = CreateWindowEx(0,
        szStatusClass,
        NULL,
        WS_CHILD|WS_BORDER|WS_VISIBLE|WS_CLIPSIBLINGS,
        0, 0,
        0, 0,
        ghwndApp,
        NULL,
        hInst,
        NULL);
    if(ghwndStatus == NULL) {
        return(FALSE);
    }
    ShowWindow(ghwndApp,sw);

    // get which devices to use from win.ini
    ZeroMemory(gcap.rgpmVideoMenu, sizeof(gcap.rgpmVideoMenu));
    gcap.pmVideo = 0;

    TCHAR szVideoDisplayName[1024];
    *szVideoDisplayName = 0; // null terminate

    GetProfileString(TEXT("annie"), TEXT("VideoDevice2"), TEXT(""),
        szVideoDisplayName,
        sizeof(szVideoDisplayName)/sizeof(szVideoDisplayName[0]));

    gcap.fDeviceMenuPopulated = false;
    AddDevicesToMenu();

    // do we want preview?
    gcap.fWantPreview = GetProfileInt(TEXT("annie"), TEXT("WantPreview"), FALSE);

    // get the frame rate from win.ini before making the graph
    gcap.fUseFrameRate = GetProfileInt(TEXT("annie"), TEXT("UseFrameRate"), 1);
    int units_per_frame = GetProfileInt(TEXT("annie"), TEXT("FrameRate"), 666667);  // 15fps
    gcap.FrameRate = 10000000. / units_per_frame;
    gcap.FrameRate = (int)(gcap.FrameRate * 100) / 100.;

    // reasonable default
    if(gcap.FrameRate <= 0.)
        gcap.FrameRate = 15.0;

    gcap.fUseTimeLimit = GetProfileInt(TEXT("annie"), TEXT("UseTimeLimit"), 0);
    gcap.dwTimeLimit = GetProfileInt(TEXT("annie"), TEXT("TimeLimit"), 0);

    // instantiate the capture filters we need to do the menu items
    // this will start previewing, if wanted
    // 
    // make these the official devices we're using

    ChooseDevices(szVideoDisplayName);
    // and builds a partial filtergraph.

    // Register for device add/remove notifications.
    DEV_BROADCAST_DEVICEINTERFACE filterData;
    ZeroMemory(&filterData, sizeof(DEV_BROADCAST_DEVICEINTERFACE));

    filterData.dbcc_size = sizeof(DEV_BROADCAST_DEVICEINTERFACE);
    filterData.dbcc_devicetype = DBT_DEVTYP_DEVICEINTERFACE;
    filterData.dbcc_classguid = AM_KSCATEGORY_CAPTURE;

    gpUnregisterDeviceNotification = NULL;
    gpRegisterDeviceNotification = NULL;
    // dynload device removal APIs
    {
        HMODULE hmodUser = GetModuleHandle(TEXT("user32.dll"));
        ASSERT(hmodUser);       // we link to user32
        gpUnregisterDeviceNotification = (PUnregisterDeviceNotification)
        GetProcAddress(hmodUser, "UnregisterDeviceNotification");

        // m_pRegisterDeviceNotification is prototyped differently in unicode
        gpRegisterDeviceNotification = (PRegisterDeviceNotification)
            GetProcAddress(hmodUser,
#ifdef UNICODE
            "RegisterDeviceNotificationW"
#else
            "RegisterDeviceNotificationA"
#endif
            );
        // failures expected on older platforms.
        ASSERT(gpRegisterDeviceNotification && gpUnregisterDeviceNotification ||
            !gpRegisterDeviceNotification && !gpUnregisterDeviceNotification);
    }

    ghDevNotify = NULL;

    if(gpRegisterDeviceNotification) {
        ghDevNotify = gpRegisterDeviceNotification(ghwndApp, &filterData, DEVICE_NOTIFY_WINDOW_HANDLE);
        ASSERT(ghDevNotify != NULL);
    }

    SetAppCaption();
    return TRUE;
}
}

void IMonRelease(IMoniker *&pm) 
{
    if(pm) {
        pm->Release();
        pm = 0;
    }
}

/*----------------------------------------------------------------------------*\
|   AppWndProc( hwnd, uiMessage, wParam, lParam )                              |
|                                                                              |
|   Description:                                                               |
|       The window proc for the app's main (tiled) window.  This processes all |
|       of the parent window's messages.                                       |
|                                                                              |
|   Arguments:                                                                 |
|       hwnd            window handle for the window                           |
|       msg             message number                                         |
|       wParam          message-dependent                                      |
|       lParam          message-dependent                                      |
|                                                                              |
|   Returns:                                                                   |
|       0 if processed, nonzero if ignored                                     |
|                                                                              |
\*----------------------------------------------------------------------------*/
LONG WINAPI  AppWndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) 
{
    PAINTSTRUCT ps;
    HDC hdc;
    RECT rc;
    int cxBorder, cyBorder, cy;

    switch(msg) {
        case WM_CREATE:
            break;

        case WM_COMMAND:
            return AppCommand(hwnd,msg,wParam,lParam);

        case WM_INITMENU:
            // we can start capture if not capturing already
            EnableMenuItem((HMENU)wParam, MENU_START_CAP, 
                (!gcap.fCapturing) ? MF_ENABLED :
            MF_GRAYED);
            // we can stop capture if it's currently capturing
            EnableMenuItem((HMENU)wParam, MENU_STOP_CAP, 
                (gcap.fCapturing) ? MF_ENABLED : MF_GRAYED);

            // We can bring up a dialog if the graph is stopped
            EnableMenuItem((HMENU)wParam, MENU_DIALOG0, !gcap.fCapturing ?
                MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_DIALOG1, !gcap.fCapturing ?
                MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_DIALOG2, !gcap.fCapturing ?
                MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_DIALOG3, !gcap.fCapturing ?
                MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_DIALOG4, !gcap.fCapturing ?
                MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_DIALOG5, !gcap.fCapturing ?
                MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_DIALOG6, !gcap.fCapturing ?
                MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_DIALOG7, !gcap.fCapturing ?
                MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_DIALOG8, !gcap.fCapturing ?
                MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_DIALOG9, !gcap.fCapturing ?
                MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_DIALOGA, !gcap.fCapturing ?
                MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_DIALOGB, !gcap.fCapturing ?
                MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_DIALOGC, !gcap.fCapturing ?
                MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_DIALOGD, !gcap.fCapturing ?
                MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_DIALOGE, !gcap.fCapturing ?
                MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_DIALOGF, !gcap.fCapturing ?
                MF_ENABLED : MF_GRAYED);

            // change frame rate when not capturing, and only if the video
            // filter captures a VIDEOINFO type format
            EnableMenuItem((HMENU)wParam, MENU_FRAMERATE,
                MF_ENABLED);
            // change time limit when not capturing
            EnableMenuItem((HMENU)wParam, MENU_TIMELIMIT,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            // change capture file name when not capturing
            EnableMenuItem((HMENU)wParam, MENU_SET_CAP_FILE,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            // pre-allocate capture file when not capturing
            EnableMenuItem((HMENU)wParam, MENU_ALLOC_CAP_FILE,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            // can save capture file when not capturing
            EnableMenuItem((HMENU)wParam, MENU_SAVE_CAP_FILE,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            // do we want preview?
            CheckMenuItem((HMENU)wParam, MENU_PREVIEW, 
                (gcap.fWantPreview) ? MF_CHECKED : MF_UNCHECKED);
            // can toggle preview if not capturing
            EnableMenuItem((HMENU)wParam, MENU_PREVIEW,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);

            // can't select a new capture device when capturing
            EnableMenuItem((HMENU)wParam, MENU_VDEVICE0,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_VDEVICE1,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_VDEVICE2,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_VDEVICE3,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_VDEVICE4,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_VDEVICE5,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_VDEVICE6,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_VDEVICE7,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_VDEVICE8,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_VDEVICE9,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_ADEVICE0,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_ADEVICE1,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_ADEVICE2,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_ADEVICE3,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_ADEVICE4,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_ADEVICE5,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_ADEVICE6,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_ADEVICE7,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_ADEVICE8,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);
            EnableMenuItem((HMENU)wParam, MENU_ADEVICE9,
                !gcap.fCapturing ? MF_ENABLED : MF_GRAYED);

            break;


        case WM_INITMENUPOPUP:
            if(GetSubMenu(GetMenu(ghwndApp), 1) == (HMENU)wParam) {
                AddDevicesToMenu();
            }

            break;

        //
        // We're out of here!
        //
        case WM_DESTROY:
            DbgTerminate();

            IMonRelease(gcap.pmVideo);
			{
                    for(int i = 0; i < NUMELMS(gcap.rgpmVideoMenu); i++) {
                        IMonRelease(gcap.rgpmVideoMenu[i]);
                    }
            }

            CoUninitialize();
            PostQuitMessage(0);
            break;


        case WM_CLOSE:
            OnClose();
            break;

        case WM_ENDSESSION:
            if(wParam || (lParam & ENDSESSION_LOGOFF)) {
                OnClose();
            }
            break;

        case WM_ERASEBKGND:
            break;

        // ESC will stop capture
        case WM_KEYDOWN:
            if((GetAsyncKeyState(VK_ESCAPE) & 0x01) && gcap.fCapturing) {
                StopCapture();
                if(gcap.fWantPreview) {
                    BuildPreviewGraph();
                    StartPreview();
                }
            }
            break;

        case WM_PAINT:
            hdc = BeginPaint(hwnd,&ps);

            // nothing to do
            EndPaint(hwnd,&ps);
            break;

        case WM_TIMER:
            // update our status bar with #captured, #dropped
            // if we've stopped capturing, don't do it anymore.  Some WM_TIMER
            // messages may come late, after we've destroyed the graph and
            // we'll get invalid numbers.
            if(gcap.fCapturing)
                UpdateStatus(FALSE);

            // is our time limit up?
            if(gcap.fUseTimeLimit) {
                    if((timeGetTime() - gcap.lCapStartTime) / 1000 >=
                        gcap.dwTimeLimit) {
			key_stop_capture();
                    }
            }
            break;

        case WM_SIZE:
            // make the preview window fit inside our window, taking up
            // all of our client area except for the status window at the
            // bottom
            GetClientRect(ghwndApp, &rc);
            cxBorder = GetSystemMetrics(SM_CXBORDER);
            cyBorder = GetSystemMetrics(SM_CYBORDER);
            cy = statusGetHeight() + cyBorder;
            MoveWindow(ghwndStatus, -cxBorder, rc.bottom - cy,
                rc.right + (2 * cxBorder), cy + cyBorder, TRUE);
            rc.bottom -= cy;
            // this is the video renderer window showing the preview
            if(gcap.pVW)
                gcap.pVW->SetWindowPosition(0, 0, rc.right, rc.bottom);
            break;

        case WM_FGNOTIFY:
            // uh-oh, something went wrong while capturing - the filtergraph
            // will send us events like EC_COMPLETE, EC_USERABORT and the one
            // we care about, EC_ERRORABORT.
            if(gcap.pME) {
                    LONG event, l1, l2;
			HRESULT hrAbort = S_OK;
                    BOOL bAbort = FALSE;
                    while(gcap.pME->GetEvent(&event, (LONG_PTR *) &l1, 
                        (LONG_PTR *) &l2, 0) == S_OK) {
                        gcap.pME->FreeEventParams(event, l1, l2);
                        if(event == EC_ERRORABORT) {
                            StopCapture();
                            bAbort = TRUE;
                            continue;
                        }
                        else if(event == EC_DEVICE_LOST) {
                                // Check if we have lost a capture filter being used.
                                // lParam2 of EC_DEVICE_LOST event == 1 indicates device added
                                //                                 == 0 indicates device removed
                                if(l2 == 0) {
                                    IBaseFilter *pf;
                                    IUnknown *punk = (IUnknown *) (LONG_PTR) l1;
                                    if(S_OK == punk->QueryInterface(IID_IBaseFilter, (void **) &pf)) {
                                        if(::IsEqualObject(gcap.pVCap, pf)) {
                                            pf->Release();
                                            bAbort = FALSE;
                                            StopCapture();
                                            TCHAR szError[100];
                                        HRESULT hr = StringCchCopy(szError, 100,
                                                TEXT("Stopping Capture (Device Lost). Select New Capture Device"));
                                            ErrMsg(szError);
                                            break;
                                        }
                                        pf->Release();
                                    }
                                }
                        }
                    } // end while
                    if(bAbort) {
                            if(gcap.fWantPreview) {
                                BuildPreviewGraph();
                                StartPreview();
                            }
                            TCHAR szError[100];
                        HRESULT hr = StringCchPrintf(szError, 100, TEXT("ERROR during capture, error code=%08x\0"), hrAbort);
                            ErrMsg(szError);
                    }
            }
            break;

        case WM_DEVICECHANGE:
            // We are interested in only device arrival & removal events
            if(DBT_DEVICEARRIVAL != wParam && DBT_DEVICEREMOVECOMPLETE != wParam)
                break;
            PDEV_BROADCAST_HDR pdbh = (PDEV_BROADCAST_HDR) lParam;
            if(pdbh->dbch_devicetype != DBT_DEVTYP_DEVICEINTERFACE) {
                break;
            }
            PDEV_BROADCAST_DEVICEINTERFACE pdbi = (PDEV_BROADCAST_DEVICEINTERFACE) lParam;
            // Check for capture devices.
            if(pdbi->dbcc_classguid != AM_KSCATEGORY_CAPTURE) {
                break;
            }

            // Check for device arrival/removal.
            if(DBT_DEVICEARRIVAL == wParam || DBT_DEVICEREMOVECOMPLETE == wParam) {
                gcap.fDeviceMenuPopulated = false;
            }
            break;

    }

    return (LONG) DefWindowProc(hwnd,msg,wParam,lParam);
}


// Make a graph builder object we can use for capture graph building
//
BOOL MakeBuilder() 
{
    // we have one already
    if(gcap.pBuilder)
        return TRUE;

    HRESULT hr = CoCreateInstance((REFCLSID)CLSID_CaptureGraphBuilder2,
        NULL, CLSCTX_INPROC, (REFIID)IID_ICaptureGraphBuilder2,
        (void **)&gcap.pBuilder);

    return (hr == NOERROR) ? TRUE : FALSE;
}


// Make a graph object we can use for capture graph building
//
BOOL MakeGraph() 
{
    // we have one already
    if(gcap.pFg)
        return TRUE;

    HRESULT hr = CoCreateInstance(CLSID_FilterGraph, NULL, CLSCTX_INPROC,
        IID_IGraphBuilder, (LPVOID *)&gcap.pFg);

    return (hr == NOERROR) ? TRUE : FALSE;
}


// make sure the preview window inside our window is as big as the
// dimensions of captured video, or some capture cards won't show a preview.
// (Also, it helps people tell what size video they're capturing)
// We will resize our app's window big enough so that once the status bar
// is positioned at the bottom there will be enough room for the preview
// window to be w x h
//
int gnRecurse = 0;


void ResizeWindow(int w, int h) 
{
    RECT rcW, rcC;
    int xExtra, yExtra;
    int cyBorder = GetSystemMetrics(SM_CYBORDER);

    gnRecurse++;

    GetWindowRect(ghwndApp, &rcW);
    GetClientRect(ghwndApp, &rcC);
    xExtra = rcW.right - rcW.left - rcC.right;
    yExtra = rcW.bottom - rcW.top - rcC.bottom + cyBorder + statusGetHeight();

    rcC.right = w;
    rcC.bottom = h;
    SetWindowPos(ghwndApp, NULL, 0, 0, rcC.right + xExtra,
        rcC.bottom + yExtra, SWP_NOZORDER | SWP_NOMOVE);

    // we may need to recurse once.  But more than that means the window cannot
    // be made the size we want, trying will just stack fault.
    //
    if(gnRecurse == 1 && ((rcC.right + xExtra != rcW.right - rcW.left && w > GetSystemMetrics(SM_CXMIN)) ||
        (rcC.bottom + yExtra != rcW.bottom - rcW.top)))
        ResizeWindow(w,h);

    gnRecurse--;
}


// Tear down everything downstream of a given filter
void NukeDownstream(IBaseFilter *pf) 
{
    //DbgLog((LOG_TRACE,1,TEXT("Nuking...")));

    IPin *pP, *pTo;
    ULONG u;
    IEnumPins *pins = NULL;
    PIN_INFO pininfo;
    HRESULT hr = pf->EnumPins(&pins);
    pins->Reset();
    while(hr == NOERROR) {
        hr = pins->Next(1, &pP, &u);
        if(hr == S_OK && pP) {
            pP->ConnectedTo(&pTo);
            if(pTo) {
                hr = pTo->QueryPinInfo(&pininfo);
                if(hr == NOERROR) {
                    if(pininfo.dir == PINDIR_INPUT) {
                        NukeDownstream(pininfo.pFilter);
                        gcap.pFg->Disconnect(pTo);
                        gcap.pFg->Disconnect(pP);
                        gcap.pFg->RemoveFilter(pininfo.pFilter);
                    }
                    pininfo.pFilter->Release();
                }
                pTo->Release();
            }
            pP->Release();
        }
    }
    if(pins)
        pins->Release();
}


// Tear down everything downstream of the capture filters, so we can build
// a different capture graph.  Notice that we never destroy the capture filters
// and WDM filters upstream of them, because then all the capture settings
// we've set would be lost.
//
void TearDownGraph() 
{
    if(gcap.pGrabber)
        gcap.pGrabber->Release();
    gcap.pGrabber = NULL;
    gcap.pFg->RemoveFilter(gcap.pNull2);
    if(gcap.pNull2)
        gcap.pNull2->Release();
    gcap.pNull2 = NULL;

    if(gcap.pVW) {
        // stop drawing in our window, or we may get wierd repaint effects
        gcap.pVW->put_Owner(NULL);
        gcap.pVW->put_Visible(OAFALSE);
        gcap.pVW->Release();
    }
    gcap.pVW = NULL;
    if(gcap.pME)
        gcap.pME->Release();
    gcap.pME = NULL;
    if(gcap.pDF)
        gcap.pDF->Release();
    gcap.pDF = NULL;

    // destroy the graph downstream of our capture filters
    if(gcap.pVCap)
        NukeDownstream(gcap.pVCap);
    if(gcap.pACap)
        NukeDownstream(gcap.pACap);

    // potential debug output - what the graph looks like
    // if (gcap.pFg) DumpGraph(gcap.pFg, 1);

#ifdef REGISTER_FILTERGRAPH
    // Remove filter graph from the running object table   
    if (g_dwGraphRegister)
    {
        RemoveGraphFromRot(g_dwGraphRegister);
        g_dwGraphRegister = 0;
    }
#endif

    gcap.fCaptureGraphBuilt = FALSE;
    gcap.fPreviewGraphBuilt = FALSE;
    gcap.fPreviewFaked = FALSE;
}


// create the capture filters of the graph.  We need to keep them loaded from
// the beginning, so we can set parameters on them and have them remembered
//
BOOL InitCapFilters() 
{
	HRESULT hr=S_OK;
	BOOL f;

	// debuglog << "InitCapFilters\n";

    f = MakeBuilder();
    if(!f) {
        ErrMsg(TEXT("Cannot instantiate graph builder"));
        return FALSE;
    }

    //
    // First, we need a Video Capture filter, and some interfaces
    //

    gcap.pVCap = NULL;
    if(gcap.pmVideo != 0) {
        IPropertyBag *pBag;
        gcap.wachFriendlyName[0] = 0;
        hr = gcap.pmVideo->BindToStorage(0, 0, IID_IPropertyBag, (void **)&pBag);
        if(SUCCEEDED(hr)) {
            VARIANT var;
            var.vt = VT_BSTR;
            hr = pBag->Read(L"FriendlyName", &var, NULL);
            if(hr == NOERROR) {
                hr = StringCchCopyW(gcap.wachFriendlyName, sizeof(gcap.wachFriendlyName) / sizeof(gcap.wachFriendlyName[0]), var.bstrVal);
                SysFreeString(var.bstrVal);
            }
            pBag->Release();
        }
        hr = gcap.pmVideo->BindToObject(0, 0, IID_IBaseFilter, (void**)&gcap.pVCap);
    }

    if(gcap.pVCap == NULL) {
        ErrMsg(TEXT("Error %x: Cannot create video capture filter"), hr);
        goto InitCapFiltersFail;
    }


    //
    // make a filtergraph, give it to the graph builder and put the video
    // capture filter in the graph
    //

    f = MakeGraph();
    if(!f) {
        ErrMsg(TEXT("Cannot instantiate filtergraph"));
        goto InitCapFiltersFail;
    }
    hr = gcap.pBuilder->SetFiltergraph(gcap.pFg);
    if(hr != NOERROR) {
        ErrMsg(TEXT("Cannot give graph to builder"));
        goto InitCapFiltersFail;
    }

    hr = gcap.pFg->AddFilter(gcap.pVCap, NULL);
    if(hr != NOERROR) {
        ErrMsg(TEXT("Error %x: Cannot add vidcap to filtergraph"), hr);
        goto InitCapFiltersFail;
    }

    // Calling FindInterface below will result in building the upstream
    // section of the capture graph (any WDM TVTuners or Crossbars we might
    // need).

    // we use this interface to get the name of the driver
    // Don't worry if it doesn't work:  This interface may not be available
    // until the pin is connected, or it may not be available at all.
    // (eg: interface may not be available for some DV capture)
    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
            &MEDIATYPE_Video,
            gcap.pVCap, IID_IAMVideoCompression, (void **)&gcap.pVC);

    // !!! What if this interface isn't supported?
    // we use this interface to set the frame rate and get the capture size
    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
            &MEDIATYPE_Video, gcap.pVCap,
            IID_IAMStreamConfig, (void **)&gcap.pVSC);
        if(hr != NOERROR) {
            // this means we can't set frame rate (non-DV only)
            ErrMsg(TEXT("Error %x: Cannot find VCapture:IAMStreamConfig"), hr);
    }

    AM_MEDIA_TYPE *pmt;

    // default capture format
    if(gcap.pVSC && gcap.pVSC->GetFormat(&pmt) == S_OK) {
        // DV capture does not use a VIDEOINFOHEADER
        if(pmt->formattype == FORMAT_VideoInfo) {
            // resize our window to the default capture size
            ResizeWindow(HEADER(pmt->pbFormat)->biWidth,
                ABS(HEADER(pmt->pbFormat)->biHeight));
        }
        DeleteMediaType(pmt);
    }

    // we use this interface to bring up the 3 dialogs
    // NOTE:  Only the VfW capture filter supports this.  This app only brings
    // up dialogs for legacy VfW capture drivers, since only those have dialogs
    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
        &MEDIATYPE_Video, gcap.pVCap,
        IID_IAMVfwCaptureDialogs, (void **)&gcap.pDlg);


	// potential debug output - what the graph looks like
	// DumpGraph(gcap.pFg, 1);

	return TRUE;

InitCapFiltersFail:
    FreeCapFilters();
    return FALSE;
}


// all done with the capture filters and the graph builder
//
void FreeCapFilters() 
{
    if(gcap.pFg)
        gcap.pFg->Release();
    gcap.pFg = NULL;
    if(gcap.pBuilder)
        gcap.pBuilder->Release();
    gcap.pBuilder = NULL;
    if(gcap.pVCap)
        gcap.pVCap->Release();
    gcap.pVCap = NULL;
    if(gcap.pACap)
        gcap.pACap->Release();
    gcap.pACap = NULL;
    if(gcap.pASC)
        gcap.pASC->Release();
    gcap.pASC = NULL;
    if(gcap.pVSC)
        gcap.pVSC->Release();
    gcap.pVSC = NULL;
    if(gcap.pVC)
        gcap.pVC->Release();
    gcap.pVC = NULL;
    if(gcap.pDlg)
        gcap.pDlg->Release();
    gcap.pDlg = NULL;

}

// Helper functions:
HRESULT GetPin(IBaseFilter *pFilter, PIN_DIRECTION PinDir, IPin **ppPin)
{
    IEnumPins  *pEnum;
    IPin       *pPin;
    pFilter->EnumPins(&pEnum);
    while(pEnum->Next(1, &pPin, 0) == S_OK)
    {
        PIN_DIRECTION PinDirThis;
        pPin->QueryDirection(&PinDirThis);
        if (PinDir == PinDirThis)
        {
            pEnum->Release();
            *ppPin = pPin;
            return S_OK;
        }
        pPin->Release();
    }
    pEnum->Release();
    return E_FAIL;  
}

HRESULT ConnectFilters(IGraphBuilder *pGraph, IBaseFilter *pFirst, IBaseFilter *pSecond)
{
    IPin *pOut = NULL, *pIn = NULL;
    HRESULT hr = GetPin(pFirst, PINDIR_OUTPUT, &pOut);
    if (FAILED(hr)) return hr;
    hr = GetPin(pSecond, PINDIR_INPUT, &pIn);
    if (FAILED(hr)) 
    {
        pOut->Release();
        return E_FAIL;
     }
    hr = pGraph->Connect(pOut, pIn);
    pIn->Release();
    pOut->Release();
    return hr;
}


// build the capture graph
//
BOOL BuildCaptureGraph() 
{
    USES_CONVERSION;
    int cy, cyBorder;
    HRESULT hr;
    AM_MEDIA_TYPE *pmt;
    AM_MEDIA_TYPE mt;
    VIDEOINFOHEADER *pVideoHeader;
	int iBitDepth;
	HDC hdc;
	CComQIPtr< ISampleGrabberCB, &IID_ISampleGrabberCB > pCB( &gcap.pCallback );

    // we have one already
    if(gcap.fCaptureGraphBuilt)
        return TRUE;

    // No rebuilding while we're running
    if(gcap.fCapturing || gcap.fPreviewing)
        return FALSE;

    // We don't have the necessary capture filters
    if(gcap.pVCap == NULL)
        return FALSE;

    // we already have another graph built... tear down the old one
    if(gcap.fPreviewGraphBuilt)
        TearDownGraph();


	// debuglog << "Creating SampleGrabber\n";

	hr = CoCreateInstance(CLSID_SampleGrabber, NULL, CLSCTX_INPROC_SERVER,
			IID_IBaseFilter, (void**)&gcap.pGrabber);
	if ( hr != S_OK ) {
		ErrMsg(TEXT("Cannot instantiate samplegrabber"));
		goto SetupCaptureFail;
	}
	hr = CoCreateInstance(CLSID_NullRenderer, NULL, CLSCTX_INPROC_SERVER,
				IID_IBaseFilter, (void**)&gcap.pNull2);
	if ( hr != S_OK ) {
		ErrMsg(TEXT("Cannot instantiate NullRenderer 2"));
		goto SetupCaptureFail;
	}		

	// debuglog << "Adding SampleGrabber to graph\n";
	/*
	 * Add TJT's filters to the graph.
	 */
	hr = gcap.pFg->AddFilter(gcap.pNull2, L"NullRenderer3");
	if ( hr != S_OK ) {
		ErrMsg(TEXT("Unable to add NullRenderer filter 2?"));
		goto SetupCaptureFail;
	}
	hr = gcap.pFg->AddFilter(gcap.pGrabber, L"Grabber");
	if ( hr != S_OK ) {
		ErrMsg(TEXT("Unable to add SampleGrabber filter?"));
		goto SetupCaptureFail;
	}

	hr = gcap.pGrabber->QueryInterface(IID_ISampleGrabber,
			(void **)&gcap.pGrabberInterface);
	if ( hr != S_OK ) {
		ErrMsg(TEXT("Unable to get SampleGrabber interface?"));
		goto SetupCaptureFail;
	}
	
	// debuglog << "Setting callback\n";

	hr = gcap.pGrabberInterface->SetCallback( pCB, 0 );
	hr = gcap.pGrabberInterface->SetOneShot( FALSE );
	hr = gcap.pGrabberInterface->SetBufferSamples( FALSE );
	// Find the current bit depth.
	hdc = GetDC(NULL);
	iBitDepth = GetDeviceCaps(hdc, BITSPIXEL);
	// debuglog << " bit depth = " << iBitDepth << "\n";
	ReleaseDC(NULL, hdc);
	// Set the media type.
	ZeroMemory(&mt, sizeof(AM_MEDIA_TYPE));
	mt.majortype = MEDIATYPE_Video;
	switch (iBitDepth)
	{
	case 8:
	    mt.subtype = MEDIASUBTYPE_RGB8;
	    break;
	case 16:
	    mt.subtype = MEDIASUBTYPE_RGB555;
	    break;
	case 24:
	    mt.subtype = MEDIASUBTYPE_RGB24;
	    break;
	case 32:
	    mt.subtype = MEDIASUBTYPE_RGB32;
	    break;
	default:
	    mt.subtype = MEDIASUBTYPE_NULL;
	}
	if ( mt.subtype == MEDIASUBTYPE_NULL ) {
		ErrMsg(TEXT("Unable to handle bit depth"));
	} else {
		mt.subtype = MEDIASUBTYPE_RGB24;
		hr = gcap.pGrabberInterface->SetMediaType(&mt);
		if ( hr != S_OK ) {
			ErrMsg(TEXT("Unable to SetMediaType?"));
		}
	}
        

    hr = gcap.pBuilder->RenderStream(&PIN_CATEGORY_CAPTURE,
            &MEDIATYPE_Video,
            gcap.pVCap, NULL, gcap.pGrabber);

    if(hr != NOERROR) {
            ErrMsg(TEXT("Cannot render video capture stream"));
	    // debuglog << "Cannot render video capture stream, hr="<<hr<<"\n";
            goto SetupCaptureFail;
    }

	hr = ConnectFilters(gcap.pFg, gcap.pGrabber, gcap.pNull2 );
	if ( hr != S_OK ) {
            ErrMsg(TEXT("Unable to Connect output of pGrabber"));
            goto SetupCaptureFail;
	}


	if ( gcap.pGrabberInterface->GetConnectedMediaType(&mt) != S_OK ) {
            ErrMsg(TEXT("Unable to get connected media type"));
            goto SetupCaptureFail;
	} else {
		if ( mt.subtype == MEDIASUBTYPE_RGB8 ) {
			// debuglog << "connected subtype is 8 bit\n";
		} else if ( mt.subtype == MEDIASUBTYPE_RGB32 ) {
			// debuglog << "connected subtype is 32 bit\n";
		} else {
			// debuglog << "connected subtype is unknown bits\n";
		}
	}
	// Get a pointer to the video header. 
	pVideoHeader = (VIDEOINFOHEADER*)mt.pbFormat; 
	if (pVideoHeader == NULL) {
            ErrMsg(TEXT("connected pbFormat is empty?"));
            goto SetupCaptureFail;
	}
	// The video header contains the bitmap information. 
	// Copy it into a BITMAPINFO structure. 
	BITMAPINFO BitmapInfo; 
	ZeroMemory(&BitmapInfo, sizeof(BitmapInfo)); 
	CopyMemory(&BitmapInfo.bmiHeader, &(pVideoHeader->bmiHeader), sizeof(BITMAPINFOHEADER)); 
	// Create a DIB from the bitmap header, and get a pointer to the buffer. 

	gcap.pCallback.tjtinit(BitmapInfo);


    if(gcap.fWantPreview) {
            hr = gcap.pBuilder->RenderStream(&PIN_CATEGORY_PREVIEW,
                &MEDIATYPE_Video, gcap.pVCap, NULL, NULL);
            if(hr == VFW_S_NOPREVIEWPIN) {
                // preview was faked up for us using the (only) capture pin
                gcap.fPreviewFaked = TRUE;
            }
            else if(hr != S_OK) {
                ErrMsg(TEXT("Cannot render video preview stream"));
                goto SetupCaptureFail;
            }
    }

    //
    // Get the preview window to be a child of our app's window
    //

    // This will find the IVideoWindow interface on the renderer.  It is 
    // important to ask the filtergraph for this interface... do NOT use
    // ICaptureGraphBuilder2::FindInterface, because the filtergraph needs to
    // know we own the window so it can give us display changed messages, etc.

    if(gcap.fWantPreview) {
        hr = gcap.pFg->QueryInterface(IID_IVideoWindow, (void **)&gcap.pVW);
        if(hr != NOERROR && gcap.fWantPreview) {
            ErrMsg(TEXT("This graph cannot preview"));
        }
        else if(hr == NOERROR) {
            RECT rc;
            gcap.pVW->put_Owner((OAHWND)ghwndApp);    // We own the window now
            gcap.pVW->put_WindowStyle(WS_CHILD);    // you are now a child
            // give the preview window all our space but where the status bar is
            GetClientRect(ghwndApp, &rc);
            cyBorder = GetSystemMetrics(SM_CYBORDER);
            cy = statusGetHeight() + cyBorder;
            rc.bottom -= cy;
            gcap.pVW->SetWindowPosition(0, 0, rc.right, rc.bottom); // be this big
            gcap.pVW->put_Visible(OATRUE);
        }
    }

    // now tell it what frame rate to capture at.  Just find the format it
    // is capturing with, and leave everything alone but change the frame rate
    hr = gcap.fUseFrameRate ? E_FAIL : NOERROR;
    if(gcap.pVSC && gcap.fUseFrameRate) {
        hr = gcap.pVSC->GetFormat(&pmt);
        // DV capture does not use a VIDEOINFOHEADER
        if(hr == NOERROR) {
            if(pmt->formattype == FORMAT_VideoInfo) {
                VIDEOINFOHEADER *pvi = (VIDEOINFOHEADER *)pmt->pbFormat;
                pvi->AvgTimePerFrame = (LONGLONG)(10000000 / gcap.FrameRate);
                hr = gcap.pVSC->SetFormat(pmt);
            }
            DeleteMediaType(pmt);
        }
    }
    if(hr != NOERROR)
        ErrMsg(TEXT("Cannot set frame rate for capture"));

    // now ask the filtergraph to tell us when something is completed or aborted
    // (EC_COMPLETE, EC_USERABORT, EC_ERRORABORT).  This is how we will find out
    // if the disk gets full while capturing
    hr = gcap.pFg->QueryInterface(IID_IMediaEventEx, (void **)&gcap.pME);
    if(hr == NOERROR) {
        gcap.pME->SetNotifyWindow((OAHWND)ghwndApp, WM_FGNOTIFY, 0);
    }

    // potential debug output - what the graph looks like
    // DumpGraph(gcap.pFg, 1);

    // Add our graph to the running object table, which will allow
    // the GraphEdit application to "spy" on our graph
#ifdef REGISTER_FILTERGRAPH
    hr = AddGraphToRot(gcap.pFg, &g_dwGraphRegister);
    if (FAILED(hr))
    {
        ErrMsg(TEXT("Failed to register filter graph with ROT!  hr=0x%x"), hr);
        g_dwGraphRegister = 0;
    }
#endif

    // All done.
    gcap.fCaptureGraphBuilt = TRUE;
    return TRUE;

SetupCaptureFail:
    TearDownGraph();
    return FALSE;
}



// build the preview graph!
//
// !!! PLEASE NOTE !!!  Some new WDM devices have totally separate capture
// and preview settings.  An application that wishes to preview and then 
// capture may have to set the preview pin format using IAMStreamConfig on the
// preview pin, and then again on the capture pin to capture with that format.
// In this sample app, there is a separate page to set the settings on the 
// capture pin and one for the preview pin.  To avoid the user
// having to enter the same settings in 2 dialog boxes, an app can have its own
// UI for choosing a format (the possible formats can be enumerated using
// IAMStreamConfig) and then the app can programmatically call IAMStreamConfig
// to set the format on both pins.
//
BOOL BuildPreviewGraph() 
{
    int cy, cyBorder;
    HRESULT hr;
    AM_MEDIA_TYPE *pmt;

    // we have one already
    if(gcap.fPreviewGraphBuilt)
        return TRUE;

    // No rebuilding while we're running
    if(gcap.fCapturing || gcap.fPreviewing)
        return FALSE;

    // We don't have the necessary capture filters
    if(gcap.pVCap == NULL)
        return FALSE;

    // we already have another graph built... tear down the old one
    if(gcap.fCaptureGraphBuilt)
        TearDownGraph();

    //
    // Render the preview pin - even if there is not preview pin, the capture
    // graph builder will use a smart tee filter and provide a preview.
    //
    // !!! what about latency/buffer issues?

    // NOTE that we try to render the interleaved pin before the video pin, because
    // if BOTH exist, it's a DV filter and the only way to get the audio is to use
    // the interleaved pin.  Using the Video pin on a DV filter is only useful if
    // you don't want the audio.

    // maybe it's DV?
    hr = gcap.pBuilder->RenderStream(&PIN_CATEGORY_PREVIEW,
            &MEDIATYPE_Video, gcap.pVCap, NULL, NULL);
    if(hr == VFW_S_NOPREVIEWPIN) {
            // preview was faked up for us using the (only) capture pin
            gcap.fPreviewFaked = TRUE;
        }
        else if(hr != S_OK) {
            ErrMsg(TEXT("This graph cannot preview!"));
    }

    //
    // Get the preview window to be a child of our app's window
    //

    // This will find the IVideoWindow interface on the renderer.  It is 
    // important to ask the filtergraph for this interface... do NOT use
    // ICaptureGraphBuilder2::FindInterface, because the filtergraph needs to
    // know we own the window so it can give us display changed messages, etc.

    hr = gcap.pFg->QueryInterface(IID_IVideoWindow, (void **)&gcap.pVW);
    if(hr != NOERROR) {
        ErrMsg(TEXT("This graph cannot preview properly"));
    }
    else {

        //Find out if this is a DV stream
        AM_MEDIA_TYPE * pmtDV;


        if(gcap.pVSC && SUCCEEDED(gcap.pVSC->GetFormat(&pmtDV))) {
            if(pmtDV->formattype == FORMAT_DvInfo) {
                // in this case we want to set the size of the parent window to that of 
                // current DV resolution.
                // We get that resolution from the IVideoWindow.
                CComQIPtr <IBasicVideo, &IID_IBasicVideo> pBV(gcap.pVW);

                if(pBV != NULL) {   
                    HRESULT hr1, hr2;
                    long lWidth, lHeight;
                    hr1 = pBV->get_VideoHeight(&lHeight);
                    hr2 = pBV->get_VideoWidth(&lWidth);
                    if(SUCCEEDED(hr1) && SUCCEEDED(hr2)) {
                        ResizeWindow(lWidth, abs(lHeight));
                    }
                }   
            }
        }

        RECT rc;
        gcap.pVW->put_Owner((OAHWND)ghwndApp);    // We own the window now
        gcap.pVW->put_WindowStyle(WS_CHILD);    // you are now a child


        // give the preview window all our space but where the status bar is
        GetClientRect(ghwndApp, &rc);
        cyBorder = GetSystemMetrics(SM_CYBORDER);
        cy = statusGetHeight() + cyBorder;
        rc.bottom -= cy;
        gcap.pVW->SetWindowPosition(0, 0, rc.right, rc.bottom); // be this big
        gcap.pVW->put_Visible(OATRUE);
    }

    // now tell it what frame rate to capture at.  Just find the format it
    // is capturing with, and leave everything alone but change the frame rate
    // No big deal if it fails.  It's just for preview
    // !!! Should we then talk to the preview pin?
    if(gcap.pVSC && gcap.fUseFrameRate) {
        hr = gcap.pVSC->GetFormat(&pmt);
        // DV capture does not use a VIDEOINFOHEADER
        if(hr == NOERROR) {
            if(pmt->formattype == FORMAT_VideoInfo) {
                VIDEOINFOHEADER *pvi = (VIDEOINFOHEADER *)pmt->pbFormat;
                pvi->AvgTimePerFrame = (LONGLONG)(10000000 / gcap.FrameRate);
                hr = gcap.pVSC->SetFormat(pmt);
                if(hr != NOERROR)
                    ErrMsg(TEXT("%x: Cannot set frame rate for preview"), hr);
            }
            DeleteMediaType(pmt);
        }
    }

    // make sure we process events while we're previewing!
    hr = gcap.pFg->QueryInterface(IID_IMediaEventEx, (void **)&gcap.pME);
    if(hr == NOERROR) {
        gcap.pME->SetNotifyWindow((OAHWND)ghwndApp, WM_FGNOTIFY, 0);
    }

    // potential debug output - what the graph looks like
    // DumpGraph(gcap.pFg, 1);

    // Add our graph to the running object table, which will allow
    // the GraphEdit application to "spy" on our graph
#ifdef REGISTER_FILTERGRAPH
    hr = AddGraphToRot(gcap.pFg, &g_dwGraphRegister);
    if (FAILED(hr))
    {
        ErrMsg(TEXT("Failed to register filter graph with ROT!  hr=0x%x"), hr);
        g_dwGraphRegister = 0;
    }
#endif

    // All done.
    gcap.fPreviewGraphBuilt = TRUE;
    return TRUE;
}


// Start previewing
//
BOOL StartPreview() 
{
    // way ahead of you
    if(gcap.fPreviewing)
        return TRUE;

    if(!gcap.fPreviewGraphBuilt)
        return FALSE;

    // run the graph
    IMediaControl *pMC = NULL;
    HRESULT hr = gcap.pFg->QueryInterface(IID_IMediaControl, (void **)&pMC);
    if(SUCCEEDED(hr)) {
        hr = pMC->Run();
        if(FAILED(hr)) {
            // stop parts that ran
            pMC->Stop();
        }
        pMC->Release();
    }
    if(FAILED(hr)) {
        ErrMsg(TEXT("Error %x: Cannot run preview graph"), hr);
        return FALSE;
    }

    gcap.fPreviewing = TRUE;
    return TRUE;
}


// stop the preview graph
//
BOOL StopPreview() 
{
    // way ahead of you
    if(!gcap.fPreviewing) {
        return FALSE;
    }

    // stop the graph
    IMediaControl *pMC = NULL;
    HRESULT hr = gcap.pFg->QueryInterface(IID_IMediaControl, (void **)&pMC);
    if(SUCCEEDED(hr)) {
        hr = pMC->Stop();
        pMC->Release();
    }
    if(FAILED(hr)) {
        ErrMsg(TEXT("Error %x: Cannot stop preview graph"), hr);
        return FALSE;
    }

    gcap.fPreviewing = FALSE;

    // !!! get rid of menu garbage
    InvalidateRect(ghwndApp, NULL, TRUE);

    return TRUE;
}


// start the capture graph
//
BOOL StartCapture() 
{
    BOOL fHasStreamControl;
    HRESULT hr;

    // way ahead of you
    if(gcap.fCapturing)
        return TRUE;

    // or we'll get confused
    if(gcap.fPreviewing)
        StopPreview();

    // or we'll crash
    if(!gcap.fCaptureGraphBuilt)
        return FALSE;

    // This amount will be subtracted from the number of dropped and not 
    // dropped frames reported by the filter.  Since we might be having the
    // filter running while the pin is turned off, we don't want any of the
    // frame statistics from the time the pin is off interfering with the
    // statistics we gather while the pin is on
    gcap.lDroppedBase = 0;
    gcap.lNotBase = 0;

    REFERENCE_TIME start = MAX_TIME, stop = MAX_TIME;

    // don't capture quite yet...
    hr = gcap.pBuilder->ControlStream(&PIN_CATEGORY_CAPTURE, NULL,
        NULL, &start, NULL, 0, 0);
    //DbgLog((LOG_TRACE,1,TEXT("Capture OFF returns %x"), hr));

    // Do we have the ability to control capture and preview separately?
    fHasStreamControl = SUCCEEDED(hr);

    // prepare to run the graph
    IMediaControl *pMC = NULL;
    hr = gcap.pFg->QueryInterface(IID_IMediaControl, (void **)&pMC);
    if(FAILED(hr)) {
        ErrMsg(TEXT("Error %x: Cannot get IMediaControl"), hr);
        return FALSE;
    }

    // If we were able to keep capture off, then we can
    // run the graph now for frame accurate start later yet still showing a
    // preview.   Otherwise, we can't run the graph yet without capture
    // starting too, so we'll pause it so the latency between when they
    // press a key and when capture begins is still small (but they won't have
    // a preview while they wait to press a key)

    if(fHasStreamControl)
        hr = pMC->Run();
    else
        hr = pMC->Pause();
    if(FAILED(hr)) {
        // stop parts that started
        pMC->Stop();
        pMC->Release();
        ErrMsg(TEXT("Error %x: Cannot start graph"), hr);
        return FALSE;
    }

#ifdef NOKEYSTART
    // press a key to start capture
    f = DoDialog(ghwndApp, IDD_PressAKeyDialog, (DLGPROC)PressAKeyProc, 0);
    if(!f) {
        pMC->Stop();
        pMC->Release();
        if(gcap.fWantPreview) {
            BuildPreviewGraph();
            StartPreview();
        }
        return f;
    }
#endif

    // Start capture NOW!
    if(fHasStreamControl) {
        // we may not have this yet
        if(!gcap.pDF) {
               hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
                   &MEDIATYPE_Video, gcap.pVCap,
                   IID_IAMDroppedFrames, (void **)&gcap.pDF);
        }

        // turn the capture pin on now!
        hr = gcap.pBuilder->ControlStream(&PIN_CATEGORY_CAPTURE, NULL,
            NULL, NULL, &stop, 0, 0);
        //DbgLog((LOG_TRACE,0,TEXT("Capture ON returns %x"), hr));
        // make note of the current dropped frame counts
        if(gcap.pDF) {
            gcap.pDF->GetNumDropped(&gcap.lDroppedBase);
            gcap.pDF->GetNumNotDropped(&gcap.lNotBase);
            //DbgLog((LOG_TRACE,0,TEXT("Dropped counts are %ld and %ld"),
            //      gcap.lDroppedBase, gcap.lNotBase));
        } 
    }
    else {
        hr = pMC->Run();
        if(FAILED(hr)) {
            // stop parts that started
            pMC->Stop();
            pMC->Release();
            ErrMsg(TEXT("Error %x: Cannot run graph"), hr);
            return FALSE;
        }
    }

    pMC->Release();

    // when did we start capture?
    gcap.lCapStartTime = timeGetTime();

    // update status bar 30 times per second - #captured, #dropped
    SetTimer(ghwndApp, 1, 33, NULL);

    gcap.fCapturing = TRUE;
    return TRUE;
}


// stop the capture graph
//
BOOL StopCapture() 
{
    // way ahead of you
    if(!gcap.fCapturing) {
        return FALSE;
    }

    // stop the graph
    IMediaControl *pMC = NULL;
    HRESULT hr = gcap.pFg->QueryInterface(IID_IMediaControl, (void **)&pMC);
    if(SUCCEEDED(hr)) {
        hr = pMC->Stop();
        pMC->Release();
    }
    if(FAILED(hr)) {
        ErrMsg(TEXT("Error %x: Cannot stop graph"), hr);
        return FALSE;
    }

    // when the graph was stopped
    gcap.lCapStopTime = timeGetTime();

    // no more status bar updates
    KillTimer(ghwndApp, 1);

    // one last time for the final count and all the stats
    UpdateStatus(TRUE);

    gcap.fCapturing = FALSE;

    // !!! get rid of menu garbage
    InvalidateRect(ghwndApp, NULL, TRUE);

    return TRUE;
}


// Let's talk about UI for a minute.  There are many programmatic interfaces
// you can use to program a capture filter or related filter to capture the
// way you want it to.... eg:  IAMStreamConfig, IAMVideoCompression,
// IAMCrossbar, IAMTVTuner, IAMTVAudio, IAMAnalogVideoDecoder, IAMCameraControl,
// IAMVideoProcAmp, etc.
//
// But you probably want some UI to let the user play with all these settings.
// For new WDM-style capture devices, we offer some default UI you can use.
// The code below shows how to bring up all of the dialog boxes supported 
// by any capture filters.
//
// The following code shows you how you can bring up all of the
// dialogs supported by a particular object at once on a big page with lots
// of thumb tabs.  You do this by starting with an interface on the object that
// you want, and using ISpecifyPropertyPages to get the whole list, and
// OleCreatePropertyFrame to bring them all up.  This way you will get custom
// property pages a filter has, too, that are not one of the standard pages that
// you know about.  There are at least 9 objects that may have property pages.
// Your app already has 2 of the object pointers, the video capture filter and
// the audio capture filter (let's call them pVCap and pACap)
// 1.  The video capture filter - pVCap
// 2.  The video capture filter's capture pin - get this by calling
//     FindInterface(&PIN_CATEGORY_CAPTURE, pVCap, IID_IPin, &pX);
// 3.  The video capture filter's preview pin - get this by calling
//     FindInterface(&PIN_CATEGORY_PREVIEW, pVCap, IID_IPin, &pX);
// 4.  The audio capture filter - pACap
// 5.  The audio capture filter's capture pin - get this by calling
//     FindInterface(&PIN_CATEGORY_CAPTURE, pACap, IID_IPin, &pX);
// 6.  The crossbar connected to the video capture filter - get this by calling
//     FindInterface(NULL, pVCap, IID_IAMCrossbar, &pX);
// 7.  There is a possible second crossbar to control audio - get this by 
//     looking upstream of the first crossbar like this:
//     FindInterface(&LOOK_UPSTREAM_ONLY, pX, IID_IAMCrossbar, &pX2);
// 8.  The TV Tuner connected to the video capture filter - get this by calling
//     FindInterface(NULL, pVCap, IID_IAMTVTuner, &pX);
// 9.  The TV Audio connected to the audio capture filter - get this by calling
//     FindInterface(NULL, pACap, IID_IAMTVAudio, &pX);
// 10. We have a helper class, CCrossbar, which makes the crossbar issue less
//     confusing.  In fact, although not supported here, there may be more than
//     two crossbars, arranged in many different ways.  An application may not
//     wish to have separate dialogs for each crossbar, but instead hide the
//     complexity and simply offer the user a list of inputs that can be chosen.
//     This list represents all the unique inputs from all the crossbars.
//     The crossbar helper class does this and offers that list as #10.  It is
//     expected that an application will either provide the crossbar dialogs
//     above (#6 and #7) OR provide the input list (this #10), but not both.
//     That would be confusing because if you select an input using dialog 6 or
//     7 the input list here in #10 won't know about your choice.
//
// Your last choice for UI is to make your own pages, and use the results of 
// your custom page to call the interfaces programmatically.


void MakeMenuOptions() 
{
    HRESULT hr;
    HMENU hMenuSub = GetSubMenu(GetMenu(ghwndApp), 2); // Options menu

    // remove any old choices from the last device
    RemoveMenu(hMenuSub, 4, MF_BYPOSITION);
    RemoveMenu(hMenuSub, 4, MF_BYPOSITION);
    RemoveMenu(hMenuSub, 4, MF_BYPOSITION);
    RemoveMenu(hMenuSub, 4, MF_BYPOSITION);
    RemoveMenu(hMenuSub, 4, MF_BYPOSITION);
    RemoveMenu(hMenuSub, 4, MF_BYPOSITION);
    RemoveMenu(hMenuSub, 4, MF_BYPOSITION);
    RemoveMenu(hMenuSub, 4, MF_BYPOSITION);
    RemoveMenu(hMenuSub, 4, MF_BYPOSITION);
    RemoveMenu(hMenuSub, 4, MF_BYPOSITION);

    int zz = 0;
    gcap.iFormatDialogPos = -1;
    gcap.iSourceDialogPos = -1;
    gcap.iDisplayDialogPos = -1;
    gcap.iVCapDialogPos = -1;
    gcap.iACapDialogPos = -1;
    gcap.iVCapCapturePinDialogPos = -1;
    gcap.iVCapPreviewPinDialogPos = -1;
    gcap.iACapCapturePinDialogPos = -1;

    // If this device supports the old legacy UI dialogs, offer them

    if(gcap.pDlg && !gcap.pDlg->HasDialog(VfwCaptureDialog_Format)) {
        AppendMenu(hMenuSub, MF_STRING, MENU_DIALOG0 + zz, TEXT("Video Format..."));
        gcap.iFormatDialogPos = zz++;
    }
    if(gcap.pDlg && !gcap.pDlg->HasDialog(VfwCaptureDialog_Source)) {
        AppendMenu(hMenuSub, MF_STRING, MENU_DIALOG0 + zz, TEXT("Video Source..."));
        gcap.iSourceDialogPos = zz++;
    }
    if(gcap.pDlg && !gcap.pDlg->HasDialog(VfwCaptureDialog_Display)) {
        AppendMenu(hMenuSub, MF_STRING, MENU_DIALOG0 + zz, TEXT("Video Display..."));
        gcap.iDisplayDialogPos = zz++;
    }

    // don't bother looking for new property pages if the old ones are supported
    // or if we don't have a capture filter
    if(gcap.pVCap == NULL || gcap.iFormatDialogPos != -1)
        return;

    // New WDM devices support new UI and new interfaces.
    // Your app can use some default property
    // pages for UI if you'd like (like we do here) or if you don't like our
    // dialog boxes, feel free to make your own and programmatically set 
    // the capture options through interfaces like IAMCrossbar, IAMCameraControl
    // etc.

    // There are 9 objects that might support property pages.  Let's go through
    // them.

    ISpecifyPropertyPages *pSpec;
    CAUUID cauuid;

    // 1. the video capture filter itself

    hr = gcap.pVCap->QueryInterface(IID_ISpecifyPropertyPages, (void **)&pSpec);
    if(hr == S_OK) {
        hr = pSpec->GetPages(&cauuid);
        if(hr == S_OK && cauuid.cElems > 0) {
            AppendMenu(hMenuSub,MF_STRING,MENU_DIALOG0+zz, TEXT("Video Capture Filter..."));
            gcap.iVCapDialogPos = zz++;
            CoTaskMemFree(cauuid.pElems);
        }
        pSpec->Release();
    }

    // 2.  The video capture capture pin

    IAMStreamConfig *pSC;
    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
            &MEDIATYPE_Video, gcap.pVCap,
            IID_IAMStreamConfig, (void **)&pSC);

    if(hr == S_OK) {
        hr = pSC->QueryInterface(IID_ISpecifyPropertyPages, (void **)&pSpec);
        if(hr == S_OK) {
            hr = pSpec->GetPages(&cauuid);
            if(hr == S_OK && cauuid.cElems > 0) {
                AppendMenu(hMenuSub,MF_STRING,MENU_DIALOG0+zz, TEXT("Video Capture Pin..."));
                gcap.iVCapCapturePinDialogPos = zz++;
                CoTaskMemFree(cauuid.pElems);
            }
            pSpec->Release();
        }
        pSC->Release();
    }

    // 3.  The video capture preview pin.
    // This basically sets the format being previewed.  Typically, you
    // want to capture and preview using the SAME format, instead of having to
    // enter the same value in 2 dialog boxes.  For a discussion on this, see
    // the comment above the MakePreviewGraph function.

    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_PREVIEW,
            &MEDIATYPE_Video, gcap.pVCap,
            IID_IAMStreamConfig, (void **)&pSC);
    if(hr == S_OK) {
        hr = pSC->QueryInterface(IID_ISpecifyPropertyPages, (void **)&pSpec);
        if(hr == S_OK) {
            hr = pSpec->GetPages(&cauuid);
            if(hr == S_OK && cauuid.cElems > 0) {
                AppendMenu(hMenuSub,MF_STRING,MENU_DIALOG0+zz,TEXT("Video Preview Pin..."));
                gcap.iVCapPreviewPinDialogPos = zz++;
                CoTaskMemFree(cauuid.pElems);
            }
            pSpec->Release();
        }
        pSC->Release();
    }

    // !!! anything needed to delete the popup when selecting a new input?
}


// how many captured/dropped so far
//
void UpdateStatus(BOOL fAllStats) 
{
    HRESULT hr;
    LONG lDropped, lNot=0, lAvgFrameSize;
    TCHAR tach[160];

    // we use this interface to get the number of captured and dropped frames
    // NOTE:  We cannot query for this interface earlier, as it may not be
    // available until the pin is connected
    if(!gcap.pDF) {
         hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
                &MEDIATYPE_Video, gcap.pVCap,
                IID_IAMDroppedFrames, (void **)&gcap.pDF);
    }

    // this filter can't tell us dropped frame info.
    if(!gcap.pDF) {
        statusUpdateStatus(ghwndStatus,
            TEXT("Filter cannot report capture information"));
        return;
    }

    hr = gcap.pDF->GetNumDropped(&lDropped);
    if(hr == S_OK)
        hr = gcap.pDF->GetNumNotDropped(&lNot);
    if(hr != S_OK)
        return;

    lDropped -= gcap.lDroppedBase;
    lNot -= gcap.lNotBase;

    if(!fAllStats) {
        LONG lTime = timeGetTime() - gcap.lCapStartTime;
        hr = StringCchPrintf(tach, 160, TEXT("Captured %d frames (%d dropped) %d.%dsec\0"), lNot,
            lDropped, lTime / 1000, 
            lTime / 100 - lTime / 1000 * 10);
        statusUpdateStatus(ghwndStatus, tach);
        return;
    }

    // we want all possible stats, including capture time and actual acheived
    // frame rate and data rate (as opposed to what we tried to get).  These
    // numbers are an indication that though we dropped frames just now, if we
    // chose a data rate and frame rate equal to the numbers I'm about to
    // print, we probably wouldn't drop any frames.

    // average size of frame captured
    hr = gcap.pDF->GetAverageFrameSize(&lAvgFrameSize);
    if(hr != S_OK)
        return;

    // how long capture lasted
    LONG lDurMS = gcap.lCapStopTime - gcap.lCapStartTime;
    double flFrame;     // acheived frame rate
    LONG lData;         // acheived data rate

    if(lDurMS > 0) {
        flFrame = (double)(LONGLONG)lNot * 1000. /
            (double)(LONGLONG)lDurMS;
        lData = (LONG)(LONGLONG)(lNot / (double)(LONGLONG)lDurMS *
            1000. * (double)(LONGLONG)lAvgFrameSize);
    }
    else {
        flFrame = 0.;
        lData = 0;
    }

    hr = StringCchPrintf(tach, 160, TEXT("Captured %d frames in %d.%d sec (%d dropped): %d.%d fps %d.%d Meg/sec\0"),
        lNot, lDurMS / 1000, lDurMS / 100 - lDurMS / 1000 * 10,
        lDropped, (int)flFrame,
        (int)(flFrame * 10.) - (int)flFrame * 10,
        lData / 1000000,
        lData / 1000 - (lData / 1000000 * 1000));
    statusUpdateStatus(ghwndStatus, tach);
}


// Check the devices we're currently using and make filters for them
//
void ChooseDevices(IMoniker *pmVideo) 
{
    USES_CONVERSION;
#define VERSIZE 40
#define DESCSIZE 80
    int versize = VERSIZE;
    int descsize = DESCSIZE;
    WCHAR wachVer[VERSIZE]={0}, wachDesc[DESCSIZE]={0};
    TCHAR tachStatus[VERSIZE + DESCSIZE + 5]={0};


    // they chose a new device. rebuild the graphs
    if(gcap.pmVideo != pmVideo ) {
        if(pmVideo) {
            pmVideo->AddRef();
        }
        IMonRelease(gcap.pmVideo);
        gcap.pmVideo = pmVideo;
        if(gcap.fPreviewing)
            StopPreview();
        if(gcap.fCaptureGraphBuilt || gcap.fPreviewGraphBuilt)
            TearDownGraph();
        FreeCapFilters();
        InitCapFilters();
        if(gcap.fWantPreview) { // were we previewing?
            BuildPreviewGraph();
            StartPreview();
        }
        MakeMenuOptions();  // the UI choices change per device
    }

    // Set the check marks for the devices menu.
    int i;
    for(i = 0; i < NUMELMS(gcap.rgpmVideoMenu); i++) {
        if(gcap.rgpmVideoMenu[i] == NULL)
            break;
        CheckMenuItem(GetMenu(ghwndApp), 
            MENU_VDEVICE0 + i, 
            (S_OK == gcap.rgpmVideoMenu[i]->IsEqual(gcap.pmVideo)) ? MF_CHECKED : MF_UNCHECKED); 
    }

    // Put the video driver name in the status bar - if the filter supports
    // IAMVideoCompression::GetInfo, that's the best way to get the name and
    // the version.  Otherwise use the name we got from device enumeration
    // as a fallback.
    if(gcap.pVC) {
        HRESULT hr = gcap.pVC->GetInfo(wachVer, &versize, wachDesc, &descsize,
            NULL, NULL, NULL, NULL);
        if(hr == S_OK) {
            // It's possible that the call succeeded without actually filling
            // in information for description and version.  If these strings
            // are empty, just display the device's friendly name.
            if(wcslen(wachDesc) && wcslen(wachVer)) {
                hr = StringCchPrintf(tachStatus, VERSIZE + DESCSIZE + 5, TEXT("%s - %s\0"), W2T(wachDesc), W2T(wachVer));
                statusUpdateStatus(ghwndStatus, tachStatus);
                return;
            }
        }
    }

    // Since the GetInfo method failed (or the interface did not exist),
    // display the device's friendly name.
    statusUpdateStatus(ghwndStatus, W2T(gcap.wachFriendlyName));
}

void ChooseDevices(TCHAR *szVideo) 
{
    WCHAR wszVideo[1024];

#ifndef UNICODE
    MultiByteToWideChar(CP_ACP, 0, szVideo, -1, wszVideo, NUMELMS(wszVideo));
#else
    wcscpy(wszVideo, T2W(szVideo));
#endif

    IBindCtx *lpBC;
    HRESULT hr = CreateBindCtx(0, &lpBC);
    IMoniker *pmVideo = 0;
    if(SUCCEEDED(hr)) {
        DWORD dwEaten;
        hr = MkParseDisplayName(lpBC, wszVideo, &dwEaten,
            &pmVideo);

        lpBC->Release();
    }

    // Handle the case where the video capture device used for the previous session
    // is not available now.
    BOOL bFound = FALSE;
    if(pmVideo != NULL) {
        for(int i = 0; i < NUMELMS(gcap.rgpmVideoMenu); i++) {
            if(gcap.rgpmVideoMenu[i] != NULL &&
                S_OK == gcap.rgpmVideoMenu[i]->IsEqual(pmVideo)) {
                bFound = TRUE;
                break;
            }
        }
    }

    if(!bFound) {
        if(gcap.iNumVCapDevices > 0) {
            IMonRelease(pmVideo);
            ASSERT(gcap.rgpmVideoMenu[0] != NULL);
            pmVideo = gcap.rgpmVideoMenu[0];
            pmVideo->AddRef();
        }
        else
            goto CleanUp;
    }

    ChooseDevices(pmVideo);

CleanUp:
    IMonRelease(pmVideo);
}


// put all installed video and audio devices in the menus
//
void AddDevicesToMenu() 
{
    USES_CONVERSION;

    if(gcap.fDeviceMenuPopulated) {
        return;
    }
    gcap.fDeviceMenuPopulated = true;
    gcap.iNumVCapDevices = 0;

    UINT    uIndex = 0;
    HMENU   hMenuSub;
    HRESULT hr;
    BOOL bCheck = FALSE;

    hMenuSub = GetSubMenu(GetMenu(ghwndApp), 1);        // Devices menu

    // Clean the sub menu
    int iMenuItems = GetMenuItemCount(hMenuSub);
    if(iMenuItems == -1) {
        ErrMsg(TEXT("Error Cleaning Devices Menu"));
        // return;
    }
    else if(iMenuItems > 0) {
        for(int i = 0; i < iMenuItems; i++) {
            RemoveMenu(hMenuSub, 0, MF_BYPOSITION);
        }

    } {
        for(int i = 0; i < NUMELMS(gcap.rgpmVideoMenu); i++) {
            IMonRelease(gcap.rgpmVideoMenu[i]);
        }
    }


    // enumerate all video capture devices
    ICreateDevEnum *pCreateDevEnum;
    hr = CoCreateInstance(CLSID_SystemDeviceEnum, NULL, CLSCTX_INPROC_SERVER,
        IID_ICreateDevEnum, (void**)&pCreateDevEnum);
    if(hr != NOERROR) {
        ErrMsg(TEXT("Error Creating Device Enumerator"));
        return;
    }

    IEnumMoniker *pEm;
    hr = pCreateDevEnum->CreateClassEnumerator(CLSID_VideoInputDeviceCategory,
        &pEm, 0);
    if(hr != NOERROR) {
        ErrMsg(TEXT("Sorry, you have no video capture hardware"));
        return;
    }
    pEm->Reset();
    ULONG cFetched;
    IMoniker *pM;
    while(hr = pEm->Next(1, &pM, &cFetched), hr==S_OK) {
        IPropertyBag *pBag;
        hr = pM->BindToStorage(0, 0, IID_IPropertyBag, (void **)&pBag);
        if(SUCCEEDED(hr)) {
            VARIANT var;
            var.vt = VT_BSTR;
            hr = pBag->Read(L"FriendlyName", &var, NULL);
            if(hr == NOERROR) {
                AppendMenu(hMenuSub, MF_STRING, MENU_VDEVICE0 + uIndex,
                    W2T(var.bstrVal));

                if(gcap.pmVideo != 0 && (S_OK == gcap.pmVideo->IsEqual(pM)))
                    bCheck = TRUE;
                CheckMenuItem(hMenuSub, 
                    MENU_VDEVICE0 + uIndex, 
                    (bCheck ? MF_CHECKED : MF_UNCHECKED));
                bCheck = FALSE;
                EnableMenuItem(hMenuSub,
                    MENU_VDEVICE0 + uIndex,
                    (gcap.fCapturing ? MF_DISABLED : MF_ENABLED));


                SysFreeString(var.bstrVal);

                ASSERT(gcap.rgpmVideoMenu[uIndex] == 0);
                gcap.rgpmVideoMenu[uIndex] = pM;
                pM->AddRef();
            }
            pBag->Release();
        }
        pM->Release();
        uIndex++;
    }
    pEm->Release();

    gcap.iNumVCapDevices = uIndex;
}



// let them pick a frame rate
//
void ChooseFrameRate() 
{
    double rate = gcap.FrameRate;

    DoDialog(ghwndApp, IDD_FrameRateDialog, (DLGPROC)FrameRateProc, 0);

    HRESULT hr = E_FAIL;

    // If somebody unchecks "use frame rate" it means we will no longer
    // tell the filter what frame rate to use... it will either continue
    // using the last one, or use some default, or if you bring up a dialog
    // box that has frame rate choices, it will obey them.

    // new frame rate?
    if(gcap.fUseFrameRate && gcap.FrameRate != rate) {
        if(gcap.fPreviewing)
            StopPreview();
        // now tell it what frame rate to capture at.  Just find the format it
        // is capturing with, and leave everything else alone
        if(gcap.pVSC) {
            AM_MEDIA_TYPE *pmt;
            hr = gcap.pVSC->GetFormat(&pmt);
            // DV capture does not use a VIDEOINFOHEADER
            if(hr == NOERROR) {
                if(pmt->formattype == FORMAT_VideoInfo) {
                    VIDEOINFOHEADER *pvi = (VIDEOINFOHEADER *)pmt->pbFormat;
                    pvi->AvgTimePerFrame =(LONGLONG)(10000000 / gcap.FrameRate);
                    hr = gcap.pVSC->SetFormat(pmt);
                    if(hr != S_OK)
                        ErrMsg(TEXT("%x: Cannot set new frame rate"), hr);
                }
                DeleteMediaType(pmt);
            }
        }
        if(hr != NOERROR)
            ErrMsg(TEXT("Cannot set frame rate for capture"));
        if(gcap.fWantPreview)  // we were previewing
            StartPreview();
    }
}


// let them set a capture time limit
//
void ChooseTimeLimit() 
{
    DoDialog(ghwndApp, IDD_TimeLimitDialog, (DLGPROC)TimeLimitProc, 0);
}


/*----------------------------------------------------------------------------*\
|    AppCommand()
|
|    Process all of our WM_COMMAND messages.
\*----------------------------------------------------------------------------*/
LONG PASCAL AppCommand(HWND hwnd, unsigned msg, WPARAM wParam, LPARAM lParam) 
{
    HRESULT hr;
    int id = GET_WM_COMMAND_ID(wParam, lParam);
    switch(id) {
        //
        // Our about box
        //
        case MENU_ABOUT:
            DialogBox(ghInstApp, MAKEINTRESOURCE(IDD_ABOUT), hwnd, 
                (DLGPROC)AboutDlgProc);
            break;

        //
        // We want out of here!
        //
        case MENU_EXIT:
            PostMessage(hwnd,WM_CLOSE,0,0L);
            break;

        // start capturing
        //
        case MENU_START_CAP:

		key_start_capture();
		break;

        // toggle preview
        // 
        case MENU_PREVIEW:
            gcap.fWantPreview = !gcap.fWantPreview;
            if(gcap.fWantPreview) {
                BuildPreviewGraph();
                StartPreview();
            }
            else
                StopPreview();
            break;

        // stop capture
        //
        case MENU_STOP_CAP:
		key_stop_capture();
		break;

        // pick a frame rate
        //
        case MENU_FRAMERATE:
            ChooseFrameRate();
            break;

        // pick a time limit
        //
        case MENU_TIMELIMIT:
            ChooseTimeLimit();
            break;

        // pick which video capture device to use
        // pick which video capture device to use
        //
        case MENU_VDEVICE0:
        case MENU_VDEVICE1:
        case MENU_VDEVICE2:
        case MENU_VDEVICE3:
        case MENU_VDEVICE4:
        case MENU_VDEVICE5:
        case MENU_VDEVICE6:
        case MENU_VDEVICE7:
        case MENU_VDEVICE8:
        case MENU_VDEVICE9:
            ChooseDevices(gcap.rgpmVideoMenu[id - MENU_VDEVICE0] );
            break;

        // pick which audio capture device to use
        //
        case MENU_ADEVICE0:
        case MENU_ADEVICE1:
        case MENU_ADEVICE2:
        case MENU_ADEVICE3:
        case MENU_ADEVICE4:
        case MENU_ADEVICE5:
        case MENU_ADEVICE6:
        case MENU_ADEVICE7:
        case MENU_ADEVICE8:
        case MENU_ADEVICE9:
            ChooseDevices(gcap.pmVideo );
            break;

        // video format dialog
        //
        case MENU_DIALOG0:
        case MENU_DIALOG1:
        case MENU_DIALOG2:
        case MENU_DIALOG3:
        case MENU_DIALOG4:
        case MENU_DIALOG5:
        case MENU_DIALOG6:
        case MENU_DIALOG7:
        case MENU_DIALOG8:
        case MENU_DIALOG9:
        case MENU_DIALOGA:
        case MENU_DIALOGB:
        case MENU_DIALOGC:
        case MENU_DIALOGD:
        case MENU_DIALOGE:
        case MENU_DIALOGF:

            // they want the VfW format dialog
            if(id - MENU_DIALOG0 == gcap.iFormatDialogPos) {
                    // this dialog will not work while previewing
                    if(gcap.fWantPreview)
                        StopPreview();
                    HRESULT hrD;
                    hrD = gcap.pDlg->ShowDialog(VfwCaptureDialog_Format, ghwndApp);
                    // Oh uh!  Sometimes bringing up the FORMAT dialog can result
                    // in changing to a capture format that the current graph 
                    // can't handle.  It looks like that has happened and we'll
                    // have to rebuild the graph.
                    if(hrD == VFW_E_CANNOT_CONNECT) {
                        DbgLog((LOG_TRACE,1,TEXT("DIALOG CORRUPTED GRAPH!")));
                        TearDownGraph();    // now we need to rebuild
                        // !!! This won't work if we've left a stranded h/w codec
                    }

                    // Resize our window to be the same size that we're capturing
                    if(gcap.pVSC) {
                            AM_MEDIA_TYPE *pmt;
                            // get format being used NOW
                            hr = gcap.pVSC->GetFormat(&pmt);
                            // DV capture does not use a VIDEOINFOHEADER
                            if(hr == NOERROR) {
                                if(pmt->formattype == FORMAT_VideoInfo) {
                                    // resize our window to the new capture size
                                    ResizeWindow(HEADER(pmt->pbFormat)->biWidth,
                                        abs(HEADER(pmt->pbFormat)->biHeight));
                                }
                                DeleteMediaType(pmt);
                            }
                    }

                    if(gcap.fWantPreview) {
                            BuildPreviewGraph();
                            StartPreview();
                    }
            }
            else if(id - MENU_DIALOG0 == gcap.iSourceDialogPos) {
                    // this dialog will not work while previewing
                    if(gcap.fWantPreview)
                        StopPreview();
                    gcap.pDlg->ShowDialog(VfwCaptureDialog_Source, ghwndApp);
                    if(gcap.fWantPreview)
                        StartPreview();
            }
            else if(id - MENU_DIALOG0 == gcap.iDisplayDialogPos) {
                    // this dialog will not work while previewing
                    if(gcap.fWantPreview)
                        StopPreview();
                    gcap.pDlg->ShowDialog(VfwCaptureDialog_Display, ghwndApp);
                    if(gcap.fWantPreview)
                        StartPreview();

                    // now the code for the new dialogs
            }
            else if(id - MENU_DIALOG0 == gcap.iVCapDialogPos) {
                    ISpecifyPropertyPages *pSpec;
                    CAUUID cauuid;
                    hr = gcap.pVCap->QueryInterface(IID_ISpecifyPropertyPages,
                        (void **)&pSpec);
                    if(hr == S_OK) {
                        hr = pSpec->GetPages(&cauuid);
                        hr = OleCreatePropertyFrame(ghwndApp, 30, 30, NULL, 1,
                            (IUnknown **)&gcap.pVCap, cauuid.cElems,
                            (GUID *)cauuid.pElems, 0, 0, NULL);
                        CoTaskMemFree(cauuid.pElems);
                        pSpec->Release();
                    }
            }
            else if(id - MENU_DIALOG0 == gcap.iVCapCapturePinDialogPos) {
                    // You can change this pin's output format in these dialogs.
                    // If the capture pin is already connected to somebody who's 
                    // fussy about the connection type, that may prevent using 
                    // this dialog(!) because the filter it's connected to might not
                    // allow reconnecting to a new format. (EG: you switch from RGB
                    // to some compressed type, and need to pull in a decoder)
                    // I need to tear down the graph downstream of the
                    // capture filter before bringing up these dialogs.
                    // In any case, the graph must be STOPPED when calling them.
                    if(gcap.fWantPreview)
                        StopPreview();  // make sure graph is stopped

                    // The capture pin that we are trying to set the format on is connected if
                    // one of these variable is set to TRUE. The pin should be disconnected for
                    // the dialog to work properly.
                    if(gcap.fCaptureGraphBuilt || gcap.fPreviewGraphBuilt) {
                        DbgLog((LOG_TRACE,1,TEXT("Tear down graph for dialog")));
                        TearDownGraph();    // graph could prevent dialog working
                    }
                    IAMStreamConfig *pSC;
                    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_CAPTURE,
                            &MEDIATYPE_Video, gcap.pVCap,
                            IID_IAMStreamConfig, (void **)&pSC);
                    ISpecifyPropertyPages *pSpec;
                    CAUUID cauuid;
                    hr = pSC->QueryInterface(IID_ISpecifyPropertyPages,
                        (void **)&pSpec);
                    if(hr == S_OK) {
                            hr = pSpec->GetPages(&cauuid);
                            hr = OleCreatePropertyFrame(ghwndApp, 30, 30, NULL, 1,
                                (IUnknown **)&pSC, cauuid.cElems,
                                (GUID *)cauuid.pElems, 0, 0, NULL);

                            // !!! What if changing output formats couldn't reconnect
                            // and the graph is broken?  Shouldn't be possible...

                            if(gcap.pVSC) {
                                AM_MEDIA_TYPE *pmt;
                                // get format being used NOW
                                hr = gcap.pVSC->GetFormat(&pmt);
                                // DV capture does not use a VIDEOINFOHEADER
                                if(hr == NOERROR) {
                                    if(pmt->formattype == FORMAT_VideoInfo) {
                                        // resize our window to the new capture size
                                        ResizeWindow(HEADER(pmt->pbFormat)->biWidth,
                                            abs(HEADER(pmt->pbFormat)->biHeight));
                                    }
                                    DeleteMediaType(pmt);
                                }
                            }

                            CoTaskMemFree(cauuid.pElems);
                            pSpec->Release();
                    }
                    pSC->Release();
                    if(gcap.fWantPreview) {
                            BuildPreviewGraph();
                            StartPreview();
                    }
            }
            else if(id - MENU_DIALOG0 == gcap.iVCapPreviewPinDialogPos) {
                    // this dialog may not work if the preview pin is connected
                    // already, because the downstream filter may reject a format
                    // change, so we better kill the graph. (EG: We switch from 
                    // capturing RGB to some compressed fmt, and need to pull in
                    // a decompressor)
                    if(gcap.fWantPreview) {
                        StopPreview();
                        TearDownGraph();
                    }

                    IAMStreamConfig *pSC;

                    // This dialog changes the preview format, so it might affect
                    // the format being drawn.  Our app's window size is taken
                    // from the size of the capture pin's video, not the preview
                    // pin, so changing that here won't have any effect. All in all,
                    // this probably won't be a terribly useful dialog in this app.
                    hr = gcap.pBuilder->FindInterface(&PIN_CATEGORY_PREVIEW,
                            &MEDIATYPE_Video, gcap.pVCap,
                            IID_IAMStreamConfig, (void **)&pSC);

                    ISpecifyPropertyPages *pSpec;
                    CAUUID cauuid;
                    hr = pSC->QueryInterface(IID_ISpecifyPropertyPages,
                        (void **)&pSpec);
                    if(hr == S_OK) {
                            hr = pSpec->GetPages(&cauuid);
                            hr = OleCreatePropertyFrame(ghwndApp, 30, 30, NULL, 1,
                                (IUnknown **)&pSC, cauuid.cElems,
                                (GUID *)cauuid.pElems, 0, 0, NULL);
                            CoTaskMemFree(cauuid.pElems);
                            pSpec->Release();
                    }
                    pSC->Release();
                    if(gcap.fWantPreview) {
                            BuildPreviewGraph();
                            StartPreview();
                    }
            }
            else if(((id - MENU_DIALOG0) >  gcap.iVideoInputMenuPos) && 
                (id - MENU_DIALOG0) <= gcap.iVideoInputMenuPos + gcap.NumberOfVideoInputs) {
                    // Remove existing checks
                    for(int j = 0; j < gcap.NumberOfVideoInputs; j++) {
                        CheckMenuItem(gcap.hMenuPopup, j, MF_BYPOSITION | 
                            ((j == (id - MENU_DIALOG0) - gcap.iVideoInputMenuPos - 1) ?
                            MF_CHECKED : MF_UNCHECKED )); 
                    }

            }

            break;

    }
    return 0L;
}


/*----------------------------------------------------------------------------*\
|   ErrMsg - Opens a Message box with a error message in it.  The user can     |
|            select the OK button to continue                                  |
\*----------------------------------------------------------------------------*/
void ErrMsg(LPTSTR szFormat,...)
{
    static TCHAR szBuffer[2048]={0};
    const size_t NUMCHARS = sizeof(szBuffer) / sizeof(szBuffer[0]);
    const int LASTCHAR = NUMCHARS - 1;

    // Format the input string
    va_list pArgs;
    va_start(pArgs, szFormat);

    // Use a bounded buffer size to prevent buffer overruns.  Limit count to
    // character size minus one to allow for a NULL terminating character.
    HRESULT hr = StringCchVPrintf(szBuffer, NUMCHARS - 1, szFormat, pArgs);
    va_end(pArgs);

    // Ensure that the formatted string is NULL-terminated
    szBuffer[LASTCHAR] = TEXT('\0');

    MessageBox(ghwndApp, szBuffer, NULL,
               MB_OK | MB_ICONEXCLAMATION | MB_TASKMODAL);
}


/* AboutDlgProc()
 *
 * Dialog Procedure for the "about" dialog box.
 *
 */

BOOL CALLBACK AboutDlgProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) 
{
    switch(msg) {
        case WM_COMMAND:
            EndDialog(hwnd, TRUE);
            return TRUE;
        case WM_INITDIALOG:
            return TRUE;
    }
    return FALSE;
}


// brings up a dialog box
//
int DoDialog(HWND hwndParent, int DialogID, DLGPROC fnDialog, long lParam) 
{
    DLGPROC fn;
    int result;

    fn = (DLGPROC)MakeProcInstance(fnDialog, ghInstApp);
    result = (int) DialogBoxParam(ghInstApp,
        MAKEINTRESOURCE(DialogID),
        hwndParent,
        fn,
        lParam);
    FreeProcInstance(fn);

    return result;
}


//
// FrameRateProc: Choose a frame rate
//
int FAR PASCAL FrameRateProc(HWND hwnd, UINT msg, UINT wParam, LONG lParam) 
{
    TCHAR  tach[32];
    USES_CONVERSION;
	HRESULT hr;

    switch(msg) {
        case WM_INITDIALOG:
            /* put the current frame rate in the box */
            hr = StringCchPrintf(tach, 32, TEXT("%d\0"), (int) gcap.FrameRate);
            SetDlgItemText(hwnd, IDC_FRAMERATE, tach);
            CheckDlgButton(hwnd, IDC_USEFRAMERATE, gcap.fUseFrameRate);
            break;

        case WM_COMMAND:
            switch(wParam) {
            case IDCANCEL:
                EndDialog(hwnd, FALSE);
                break;

            case IDOK:
                /* get the new frame rate */
                GetDlgItemText(hwnd, IDC_FRAMERATE, tach, sizeof(tach)/sizeof(tach[0]));

#ifdef UNICODE
                int rc;

                // Convert Multibyte string to ANSI
                char szANSI[STR_MAX_LENGTH];
                rc = WideCharToMultiByte(CP_ACP, 0, tach, -1, szANSI, 
                    STR_MAX_LENGTH, NULL, NULL);
                double frameRate = atof(szANSI);
#else
                double frameRate = atof(tach);
#endif

                if(frameRate <= 0.) {
                    ErrMsg(TEXT("Invalid frame rate."));
                    break;
                }
                else
                    gcap.FrameRate = frameRate;

                gcap.fUseFrameRate = IsDlgButtonChecked(hwnd, IDC_USEFRAMERATE);
                EndDialog(hwnd, TRUE);
                break;
            }
            break;

        default:
            return FALSE;
    }
    return TRUE;
}

//
// TimeLimitProc: Choose a capture time limit
//
int FAR PASCAL TimeLimitProc(HWND hwnd, UINT msg, UINT wParam, LONG lParam) 
{
    TCHAR   tach[32];
    DWORD   dwTimeLimit;
	HRESULT hr;

    switch(msg) {
        case WM_INITDIALOG:
            /* put the current time limit info in the boxes */
            hr = StringCchPrintf(tach, 32, TEXT("%d\0"), gcap.dwTimeLimit);
            SetDlgItemText(hwnd, IDC_TIMELIMIT, tach);
            CheckDlgButton(hwnd, IDC_USETIMELIMIT, gcap.fUseTimeLimit);
            break;

        case WM_COMMAND:
            switch(wParam) {
            case IDCANCEL:
                EndDialog(hwnd, FALSE);
                break;

            case IDOK:
                /* get the new time limit */
                dwTimeLimit = GetDlgItemInt(hwnd, IDC_TIMELIMIT, NULL, FALSE);
                gcap.dwTimeLimit = dwTimeLimit;
                gcap.fUseTimeLimit = IsDlgButtonChecked(hwnd, IDC_USETIMELIMIT);
                EndDialog(hwnd, TRUE);
                break;
            }
            break;

        default:
            return FALSE;
    }
    return TRUE;
}


//
// PressAKeyProc: Press OK to capture
//
int FAR PASCAL PressAKeyProc(HWND hwnd, UINT msg, UINT wParam, LONG lParam) 
{
    TCHAR tach[_MAX_PATH];
	HRESULT hr;

    switch(msg) {
        case WM_INITDIALOG:
            /* set the current file name in the box */
            hr = StringCchPrintf(tach, _MAX_PATH, TEXT("%s\0"), "dummy");
            SetDlgItemText(hwnd, IDC_CAPFILENAME, tach);
            break;

        case WM_COMMAND:
            switch(wParam) {
            case IDCANCEL:
                EndDialog(hwnd, FALSE);
                break;

            case IDOK:
                EndDialog(hwnd, TRUE);
                break;
            }
            break;

        default:
            return FALSE;
    }
    return TRUE;
}

void OnClose() 
{
    TCHAR szBuf[512];
    WCHAR *wszDisplayName = NULL;

    // Unregister device notifications
    if(ghDevNotify != NULL) {
        ASSERT(gpUnregisterDeviceNotification);
        gpUnregisterDeviceNotification(ghDevNotify);
        ghDevNotify = NULL;
    }

    StopPreview();
    StopCapture();
    TearDownGraph();
    FreeCapFilters();

    // store current settings in win.ini for next time

    WCHAR *szDisplayName = NULL;
    szDisplayName = 0;
    if(gcap.pmVideo) {
        if(SUCCEEDED(gcap.pmVideo->GetDisplayName(0, 0, &szDisplayName)))
        {
            if(wszDisplayName)
            {
                USES_CONVERSION;
                _tcsncpy(szBuf, W2T(wszDisplayName), NUMELMS(szBuf));
                CoTaskMemFree(wszDisplayName);
            }
        }
    }

    szDisplayName = 0;

    // Save the integer settings
    HRESULT hr = StringCchPrintf(szBuf, 512, TEXT("%d"), (int)(10000000 / gcap.FrameRate));
    WriteProfileString(TEXT("annie"), TEXT("FrameRate"), szBuf);

    hr = StringCchPrintf(szBuf, 512, TEXT("%d"), gcap.fUseFrameRate);
    WriteProfileString(TEXT("annie"), TEXT("UseFrameRate"), szBuf);

    hr = StringCchPrintf(szBuf, 512, TEXT("%d"), gcap.fWantPreview);
    WriteProfileString(TEXT("annie"), TEXT("WantPreview"), szBuf);

    hr = StringCchPrintf(szBuf, 512, TEXT("%d"), gcap.fUseTimeLimit);
    WriteProfileString(TEXT("annie"), TEXT("UseTimeLimit"), szBuf);

    hr = StringCchPrintf(szBuf, 512, TEXT("%d"), gcap.dwTimeLimit);
    WriteProfileString(TEXT("annie"), TEXT("TimeLimit"), szBuf);
}



// Adds a DirectShow filter graph to the Running Object Table,
// allowing GraphEdit to "spy" on a remote filter graph.
HRESULT AddGraphToRot(IUnknown *pUnkGraph, DWORD *pdwRegister) 
{
    IMoniker * pMoniker;
    IRunningObjectTable *pROT;
    WCHAR wsz[128];
    HRESULT hr;

    if (FAILED(GetRunningObjectTable(0, &pROT)))
        return E_FAIL;

    hr = StringCchPrintfW(wsz, 128, L"FilterGraph %08x pid %08x\0", (DWORD_PTR)pUnkGraph,
              GetCurrentProcessId());

    hr = CreateItemMoniker(L"!", wsz, &pMoniker);
    if (SUCCEEDED(hr)) 
    {
        hr = pROT->Register(0, pUnkGraph, pMoniker, pdwRegister);
        pMoniker->Release();
    }
    pROT->Release();
    return hr;
}

// Removes a filter graph from the Running Object Table
void RemoveGraphFromRot(DWORD pdwRegister)
{
    IRunningObjectTable *pROT;

    if (SUCCEEDED(GetRunningObjectTable(0, &pROT))) 
    {
        pROT->Revoke(pdwRegister);
        pROT->Release();
    }
}


// class names for status bar and static text windows
TCHAR szStatusClass[] = TEXT("StatusClass");
TCHAR szText[] = TEXT("SText");
int   gStatusStdHeight;   // based on font metrics

static HANDLE ghFont;
static HBRUSH ghbrHL, ghbrShadow;


//------------------------------------------------------------------------------
// Local Function Prototypes
//------------------------------------------------------------------------------
LRESULT CALLBACK statusWndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);
LRESULT CALLBACK fnText(HWND, UINT, WPARAM, LPARAM);
static void PaintText(HWND hwnd, HDC hdc);



/*--------------------------------------------------------------+
| statusCreateTools - create the objects needed for status bar
|
+--------------------------------------------------------------*/
void
statusCreateTools(void)
{
    HDC hdc;
    TEXTMETRIC tm;
    HFONT hfont;

    ghbrHL = CreateSolidBrush(GetSysColor(COLOR_BTNHIGHLIGHT));
    ghbrShadow = CreateSolidBrush(GetSysColor(COLOR_BTNSHADOW));

    /* Create the font we'll use for the status bar - use system as default */
    ghFont = CreateFont(12, 0,      // height, width
        0, 0,                       // escapement, orientation
        FW_NORMAL,                  // weight,
        FALSE, FALSE, FALSE,        // attributes
        ANSI_CHARSET,               // charset
        OUT_DEFAULT_PRECIS,         // output precision
        CLIP_DEFAULT_PRECIS,        // clip precision
        DEFAULT_QUALITY,            // quality
        VARIABLE_PITCH | FF_MODERN,
        TEXT("Helv"));

    if(ghFont == NULL)
    {
        ghFont = GetStockObject(SYSTEM_FONT);
    }

    // find the char size to calc standard status bar height
    hdc = GetDC(NULL);
    hfont = (HFONT)SelectObject(hdc, ghFont);
    GetTextMetrics(hdc, &tm);
    SelectObject(hdc, hfont);
    ReleaseDC(NULL, hdc);

    gStatusStdHeight = tm.tmHeight * 3 / 2;
}


/*--------------------------------------------------------------+
| statusDeleteTools
|
+--------------------------------------------------------------*/
void statusDeleteTools(void)
{
    DeleteObject(ghbrHL);
    DeleteObject(ghbrShadow);

    DeleteObject(ghFont);
}


/*--------------------------------------------------------------+
| statusInit - initialize for status window, register the
|          Window's class.
|
+--------------------------------------------------------------*/
BOOL statusInit(HANDLE hInst, HANDLE hPrev)
{
    WNDCLASS  cls;

    statusCreateTools();

    if(!hPrev)
    {
        cls.hCursor       = LoadCursor(NULL, IDC_ARROW);
        cls.hIcon         = NULL;
        cls.lpszMenuName  = NULL;
        cls.lpszClassName = szStatusClass;
        cls.hbrBackground = (HBRUSH) (COLOR_BTNFACE + 1);
        cls.hInstance     = (HINSTANCE)hInst;
        cls.style         = CS_HREDRAW | CS_VREDRAW | CS_DBLCLKS;
        cls.lpfnWndProc   = (WNDPROC)statusWndProc;
        cls.cbClsExtra    = 0;
        cls.cbWndExtra    = 0;

        if(!RegisterClass(&cls))
            return FALSE;

        cls.hCursor        = LoadCursor(NULL,IDC_ARROW);
        cls.hIcon          = NULL;
        cls.lpszMenuName   = NULL;
        cls.lpszClassName  = szText;
        cls.hbrBackground  = (HBRUSH) (COLOR_BTNFACE + 1);
        cls.hInstance      = (HINSTANCE)hInst;
        cls.style          = CS_HREDRAW | CS_VREDRAW | CS_DBLCLKS;
        cls.lpfnWndProc    = (WNDPROC)fnText;
        cls.cbClsExtra     = 0;
        cls.cbWndExtra     = 0;

        if(!RegisterClass(&cls))
            return FALSE;
    }

    return TRUE;
}


/*--------------------------------------------------------------+
| statusGetHeight
|
| Returns the recommended height for a status bar based on the
| character dimensions of the font used
+--------------------------------------------------------------*/
int statusGetHeight(void)
{
    return(gStatusStdHeight);
}


/*--------------------------------------------------------------+
| statusUpdateStatus - update the status line
|
| The argument can either be NULL or a string
+--------------------------------------------------------------*/
void statusUpdateStatus(HWND hwnd, LPCTSTR lpsz)
{
    HWND hwndtext;

    hwndtext = GetDlgItem(hwnd, 1);
    if(!lpsz || *lpsz == '\0')
    {
        SetWindowText(hwndtext,TEXT(""));
    }
    else
    {
        SetWindowText(hwndtext, lpsz);
    }
}


/*--------------------------------------------------------------+
| statusWndProc - window proc for status window
|
+--------------------------------------------------------------*/
LRESULT CALLBACK
statusWndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    PAINTSTRUCT ps;
    HWND hwndSText;

    switch(msg)
    {
        case WM_CREATE:
        {
            /* we need to create the static text control for the status bar */
            hwndSText = CreateWindow(szText,
                TEXT(""),
                WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS,
                0, 0, 0, 0,
                hwnd,
                (HMENU) 1,  // child id
                GetWindowInstance(hwnd),
                (LPSTR)NULL);

            if(!hwndSText)
            {
                return -1;
            }
            break;
        }

        case WM_DESTROY:
            statusDeleteTools();
            break;

        case WM_SIZE:
        {
            RECT rc;

            GetClientRect(hwnd, &rc);

            MoveWindow(GetDlgItem(hwnd, 1),    // get child window handle
                2, 1,                   // xy just inside
                rc.right - 4,
                rc.bottom - 2,
                TRUE);

            break;
        }

        case WM_PAINT:
        {
            BeginPaint(hwnd, &ps);

            // only the background and the child window need painting
            EndPaint(hwnd, &ps);
            break;
        }

        case WM_SYSCOLORCHANGE:
            statusDeleteTools();
            statusCreateTools();
            break;

        case WM_ERASEBKGND:
            break;

    }

    return DefWindowProc(hwnd, msg, wParam, lParam);
}


/*--------------------------------------------------------------+
| fnText - window proc for static text window
|                               |
+--------------------------------------------------------------*/
LRESULT CALLBACK
fnText(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam )
{
    switch(msg)
    {
        case WM_SETTEXT:
            DefWindowProc(hwnd, msg, wParam, lParam);
            InvalidateRect(hwnd,NULL,FALSE);
            UpdateWindow(hwnd);
            return 0L;

        case WM_ERASEBKGND:
            return 0L;

        case WM_PAINT:
        {
            PAINTSTRUCT ps;

            BeginPaint(hwnd, &ps);
            PaintText(hwnd, ps.hdc);
            EndPaint(hwnd, &ps);
            return 0L;
        }
    }

    return DefWindowProc(hwnd, msg, wParam, lParam);
}


/*--------------------------------------------------------------+
| PaintText - paint the shadowed static text field
|
+--------------------------------------------------------------*/
void PaintText(HWND hwnd, HDC hdc)
{
    RECT rc;
    TCHAR ach[128];
    int  len;
    int  dx, dy;
    RECT  rcFill;
    HFONT hfontOld;
    HBRUSH hbrSave;

    GetClientRect(hwnd, &rc);

    len = GetWindowText(hwnd,ach,sizeof(ach)/sizeof(ach[0]));

    SetBkColor(hdc, GetSysColor(COLOR_BTNFACE));
    SetTextColor(hdc, GetSysColor(COLOR_BTNTEXT));

    hfontOld = (HFONT)SelectObject(hdc, ghFont);

    rcFill.left = rc.left + 1;
    rcFill.right = rc.right - 1;
    rcFill.top = rc.top + 1;
    rcFill.bottom = rc.bottom - 1;

    /* move in some and do background and text in one swoosh */
    ExtTextOut(hdc,4,1,ETO_OPAQUE,&rcFill,ach,len,NULL);

    dx = rc.right - rc.left;
    dy = rc.bottom - rc.top;

    hbrSave = (HBRUSH)SelectObject(hdc, ghbrShadow);
    PatBlt(hdc, rc.left, rc.top, 1, dy, PATCOPY);
    PatBlt(hdc, rc.left, rc.top, dx, 1, PATCOPY);

    SelectObject(hdc, ghbrHL);
    PatBlt(hdc, rc.right-1, rc.top+1, 1, dy-1, PATCOPY);
    PatBlt(hdc, rc.left+1, rc.bottom -1, dx-1, 1,  PATCOPY);

    if(hfontOld)
        SelectObject(hdc, hfontOld);
    if(hbrSave)
        SelectObject(hdc, hbrSave);
}

#endif
