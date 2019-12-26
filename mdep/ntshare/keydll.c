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
