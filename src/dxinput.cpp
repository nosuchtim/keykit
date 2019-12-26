/******************************************************************************
FILE: DXInput.cpp
This module contains all of the Direct Input specific code.  This includes
initialization and uninitializatoin functions as well as functions to get
joystick and keyboard information, and a function to cause force feedback
events.

GLOBALS:
g_lpDInput -- A pointer to the direct input interface
g_lpDIDeviceJoystick -- A pointer to a device interface for the system joystick
******************************************************************************/
#define DIRECTINPUT_VERSION 0x700
#include <windows.h>
#include <basetsd.h>
#include <Dinput.h>
#include <Dinputd.h>

extern "C" {
char * InitDirectInput( HANDLE ev ) ;
void UnInitDirectInput( void ) ;
BOOL GetButtonInput( int jnum, int bnum, BOOL *bButton );
BOOL GetButtons( int jnum, int *butts, int nbutts );
int GetNJoy(void);
void mdep_popup(char *);
void keyerrfile(char *fmt,...);

extern HANDLE Khinstance;
extern HWND Khwnd;
#ifdef NEED_TO_PORT_TO_DIRECTX_8_TO_GET_MESSAGES
extern UINT JoyMessage;
#endif
}

LPDIRECTINPUT           g_lpDInput = NULL ;
int Njoy = 0;
#define MAXNJOY 8
LPDIRECTINPUTDEVICE2    g_lpDIDeviceJoystick[MAXNJOY];

BOOL CALLBACK EnumJoy(LPCDIDEVICEINSTANCE lpddi, LPVOID pvRef) ;

char * InitDirectInput( HANDLE ev )
{
	int n;

	Njoy = 0;

   // We use CoCreateInstance to create a DirectInput object and retrieve
   // it's IDirectInput interface.  This same thing could have been done using
   // the helper function provided by DirectInput called DirectInputCreate(),
   // however, CoCreateInstance provides higher flexibility (aggregation), and
   // it isn't a bad idea to get used to this function.
   if( FAILED(CoCreateInstance(CLSID_DirectInput, NULL, CLSCTX_INPROC_SERVER,
               IID_IDirectInput, (void **)&g_lpDInput)) ) {
	return "Unable to cocreateinstance !?";
	}

   // First thing we do is call the Initialize member of the IDirectInput
   // interface.  This would have been done for us if we had used the helper
   // function DirectInputCreate().
   if( FAILED(g_lpDInput->Initialize((THIS_ HINSTANCE)Khinstance,DIRECTINPUT_VERSION) ) ) {
	return "Unable to Initialize !?";
	}

   // We need to enumerate the joysticks to search for the desired GUID.
   // This requires a callback function (EnumJoy) which is where we do the
   // actual CreateDevice call for the joystick.
   // On our first attempt we try for a force-feedback capable device,
   // otherwise we give in and enumerate regular joysticks.
   g_lpDInput->EnumDevices( DIDEVTYPE_JOYSTICK, EnumJoy, (LPVOID)TRUE,
                             DIEDFL_FORCEFEEDBACK|DIEDFL_ATTACHEDONLY) ;
   if( Njoy == 0 )
      g_lpDInput->EnumDevices( DIDEVTYPE_JOYSTICK, EnumJoy, (LPVOID)FALSE,
                                DIEDFL_ATTACHEDONLY) ;

    for ( n=0; n<Njoy; n++ ) {
	HRESULT r;
	r = g_lpDIDeviceJoystick[n]->SetEventNotification(ev);
	switch (r) {
	case DI_OK:
	case DI_POLLEDDEVICE:
		break;
	default:
		return "Joystick->SetEventNotification got unexpeted return\n";
		break;
	}
        if( FAILED(g_lpDIDeviceJoystick[n]->Acquire()) ) {
		return "Joystick->Acquire failed?\n";
	}
   }

#ifdef NEED_TO_PORT_TO_DIRECTX_8_TO_GET_MESSAGES
	keyerrfile("InitDirectInput E\n");
	/* #define DIRECTINPUT_NOTIFICATION_MSGSTRING  "DIRECTINPUT_NOTIFICATION_MSGSTRING" */
	JoyMessage = RegisterWindowMessage( DIRECTINPUT_NOTIFICATION_MSGSTRING );
	keyerrfile("JoyMessage = %d\n",JoyMessage);
#endif

	return NULL ;
}

/******************************************************************************
FUNCTION: EnumJoy
This function is called by the EnumDevices function in the IDirectInput2
interface.  It is used to enumerate existing joysticks on the system.  This
function looks for a force feedback capable joystick, and then will settle for
any installed joystick.

PARAMETERS:
lpddi -- Device instance information
pvRef -- LPVOID passed into the call to EnumDevices... used here to indicate
         whether we are trying to find force feedback joysticks.

RETURNS:
DIENUM_STOP -- If we find a joystick
DIENUM_CONTINUE -- If we haven't yet
******************************************************************************/
BOOL CALLBACK EnumJoy(LPCDIDEVICEINSTANCE lpddi, LPVOID pvRef)
{
   LPDIRECTINPUTDEVICE  lpDIDeviceJoystickTemp ;
   HRESULT              hr ;
LPDIRECTINPUTDEVICE2    joy;

   // Can we create the device that wased passed in the lpddi pointer
   if( FAILED(g_lpDInput->CreateDevice(lpddi->guidInstance,
               &lpDIDeviceJoystickTemp, NULL)))
   {
      // keep trying
      return DIENUM_CONTINUE ;
   }

   // We want an IDirectInputDevice2 interface for all the cool features...
   // unfortunately the CreateDevice function of the IDirectInput interface
   // only supplies IDirectInputDevice interfaces.  So we do the hokey-pokey
   // and get a new interface.
   hr = lpDIDeviceJoystickTemp->QueryInterface(IID_IDirectInputDevice2,
                                              (void **) &joy) ;
	lpDIDeviceJoystickTemp->Release() ;
	if( FAILED( hr ) ) {
		return DIENUM_CONTINUE ;
	}

	if ( Njoy >= (MAXNJOY-1) )
		return DIENUM_STOP;

   // We are setting the data format for the device.  c_dfDIJoystick is a
   // predefined structure that should be used for joysticks.  It is defined
   // in dinput.lib


	g_lpDIDeviceJoystick[Njoy++] = joy;
	joy->SetDataFormat(&c_dfDIJoystick) ;

	// We are setting the cooperative level to exclusive/foreground for this
	// object.  This means that as long as our app's window is in the
	// foreground, we have exclusive control o the device.  Consider using
	// exclusive background for debugging purposes.

	joy->SetCooperativeLevel(Khwnd,DISCL_EXCLUSIVE|DISCL_BACKGROUND) ;

	return DIENUM_CONTINUE ;
}

BOOL GetButtonInput( int jnum, int bnum, BOOL *bButton )
{
   HRESULT     hr ;
   DIJOYSTATE  diJoyState ;

   // No device object?  Give up.
   if(Njoy == 0)
      return FALSE ;
   if(jnum >= Njoy )
      return FALSE ;

   // Starting from scratch
   *bButton = FALSE ;

   // Poll, or retrieve information from the device
   hr = g_lpDIDeviceJoystick[jnum]->Poll() ;
    if(hr== DIERR_INPUTLOST || hr== DIERR_NOTACQUIRED )
    {
      // If the poll failed, maybe we should acquire
      g_lpDIDeviceJoystick[jnum]->Acquire() ;
      // Lets try the poll again
      hr = g_lpDIDeviceJoystick[jnum]->Poll() ;
    }
   if( FAILED(hr) )
      return FALSE ;

   // Get the device state, and populate the DIJOYSTATE structure
   if( FAILED(g_lpDIDeviceJoystick[jnum]->GetDeviceState( sizeof(DIJOYSTATE), &
                                                     diJoyState)) )
      return FALSE ;

   *bButton = diJoyState.rgbButtons[bnum] ;

   return TRUE ;

}

int GetNJoy() {
	return Njoy;
}

BOOL GetButtons( int jnum, int *bButton, int nbutts )
{
	HRESULT     hr ;
	DIJOYSTATE  diJoyState ;
	int n;

	// No device object?  Give up.
	if( jnum >= Njoy )
		return FALSE ;

	// Poll, or retrieve information from the device
	hr = g_lpDIDeviceJoystick[jnum]->Poll() ;
	if(hr== DIERR_INPUTLOST || hr== DIERR_NOTACQUIRED ) {
		// If the poll failed, maybe we should acquire
		g_lpDIDeviceJoystick[jnum]->Acquire() ;
		// Lets try the poll again
		hr = g_lpDIDeviceJoystick[jnum]->Poll() ;
	}
	if( FAILED(hr) )
		return FALSE ;

	// Get the device state, and populate the DIJOYSTATE structure
	if( FAILED(g_lpDIDeviceJoystick[jnum]->GetDeviceState( sizeof(DIJOYSTATE),
		&diJoyState)) ) {
		return FALSE ;
	}

	for ( n=0; n<nbutts; n++ )
		bButton[n] = diJoyState.rgbButtons[n];

	return TRUE ;
}

void UnInitDirectInput( void )
{
	int n;

	for ( n=0; n<Njoy; n++ ) {
		g_lpDIDeviceJoystick[n]->Unacquire() ;
		g_lpDIDeviceJoystick[n]->Release() ;
	}
	if(g_lpDInput)
		g_lpDInput->Release() ;
	Njoy = 0;
	return ;
}
