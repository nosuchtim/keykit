/*
 *	Copyright (c) 1984, 1985, 1986, 1987, 1988 AT&T
 *	All Rights Reserved
 *
 *	THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF AT&T.
 *
 *	The copyright notice above does not evidence any actual
 *	or intended publication of such source code.
 */
  
#define DEBUGEVENTS 0
#define DEBUGBITMAPS 0
#define DEBUGWAITNEXT 0

#include <stdlib.h>

#include <ctype.h>
#include <time.h>
#include <Files.h>
#include <Balloons.h>
#include <Fonts.h>

#include "key.h"
#include "pathname.h"
#include "clock.h"
#include "appleEvnts.h"
#include "myResources.h"
#include "environ.h"
#include "help.h"
#if HELP
#include "HoWLib.h"
#endif
#include <string.h>
#include <GXMath.h>
//#include "Wide.h"
#include "stats.h"
//#include "regex.h"

static int			Msb = 0;	// The mouse button pressed
static int			Msx, Msy;	// The mouse coordinates
static int			Msm = 0;	// The mouse mode (which modifier is down)
static RgnHandle	MouseRgn;	// The region for mouse-moved events.

static short	MfontAscent;	// Ascent of the current font

static RGBColor	Mcolors[5];
static short	MplotMode;		// current plot mode.

Cursor		cross;				// The cross cursor
Cursor		ibeam;				// The i-beam cursor
Cursor		watch;				// The watch cursor
Cursor		sweep;				// The sweep cursor
Cursor		leftRight;			// left-right sweep cursor
Cursor		upDown;				// up-down sweep cursor
Cursor		move;				// move something anywhere cursor

extern MenuHandle	appleMenu, fileMenu, midiMenu;
extern char			pageFile[_MAX_PATH];

static Boolean	updateBegan = false;

GWorldPtr	currPort;	// Saves the current port prior to setting up offscreen world
GDHandle	currDev;	// Saves the current device prior to setting up offscreen world
GrafPtr		savedPort;

#define FGWAITTIME	0L;				// minimum (hog the CPU when in foreground
#define BGWAITTIME	300L;			// 5 seconds

static long		waitTime = 0L;		// Assume we start in the foreground
long			keykitstart;		// when keykit started

#define MENUBARHEIGHT	20
#define TITLEBARHEIGHT	18

// local prototypes
void DoAppleItem(short item);
void DoFileItem(short item);
void DoMenuCommand(long menuResult);
WindowPtr MakeWindow(void);
void UpperCase (char *str);
pascal Boolean myFileFilter (CInfoPBRec *pb, char *myDataPtr);
short isPressed (unsigned short k );
void CopyGWtoWindow(GWorldPtr gw, WindowPtr window );
pascal short myDialogHook(short item, DialogPtr theDialog, void *myDataPtr);
void DoMIDIItem (short item);

/*********************************************************************************************/

void
mdep_popup (char *s)
{
	short	itemType, itemHit;
	Rect	itemRect;
	Handle	itemHandle;
	char	theString[256];

	strcpy(theString, s);
	CtoPstr(theString);
	GetDialogItem ( popupDialog, POPUPTEXTITEM, &itemType, &itemHandle, &itemRect );
	SetDialogItemText (itemHandle, (ConstStr255Param)theString);
	
	ShowWindow (popupDialog);
	SelectWindow (popupDialog);
	
	// Wait for the user to hit the okay button
	ModalDialog (nil, &itemHit);
	
	HideWindow (popupDialog);

} // mdep_popup

/*********************************************************************************************/

int
mdep_statconsole()
{
	return ( 1 );	// indicate console has a character
}

/*********************************************************************************************/

int
mdep_getconsole(void)
{
	return theChar;	// the character was stored in this global by mdep_waitfor()
}

/*********************************************************************************************/

void
mdep_prerc(void)
{
}

/*********************************************************************************************/

void
mdep_initcolors(void)
{
	RGBColor	c;

	Mcolors[0].red = 0xffff;	// background (white)
	Mcolors[0].green = 0xffff;
	Mcolors[0].blue = 0xffff;

	Mcolors[1].red = 0;			// foreground (black)
	Mcolors[1].green = 0;
	Mcolors[1].blue = 0;

	Mcolors[2].red = 0xffff;	// pick-highlighting (red)
	Mcolors[2].green = 0;
	Mcolors[2].blue = 0;

	Mcolors[3].red = 0xdeb8;	// grey 1 for 3-D buttons (87%)
	Mcolors[3].green = 0xdeb8;
	Mcolors[3].blue = 0xdeb8;

	Mcolors[4].red = 0x8ccc;	// grey 2 for 3-D buttons (55%)
	Mcolors[4].green = 0x8ccc;
	Mcolors[4].blue = 0x8ccc;
	
	Mcolors[5].red = 0xeeb8;	// button bg grey
	Mcolors[5].green = 0xeeb8;
	Mcolors[5].blue = 0xeeb8;

	
	c.red = c.green = c.blue = 0xFFFF;
	RGBBackColor( &c );


} // mdep_initcolors

/*********************************************************************************************/

char *
mdep_keypath(void)
{
	return keyPath;
}

/*********************************************************************************************/

char *
mdep_musicpath(void)
{
	return musicPath;
}

/*********************************************************************************************/

void
mdep_postrc(void)
{
}

/*********************************************************************************************/

void
mdep_abortexit(char *s)
{
//	DebugStr("\pmdep_abortexit entered!!");
	mdep_bye();
	exit(1);
}

/*********************************************************************************************/

int
mdep_shellexec(char *s)
{
	return(1);
}

/*********************************************************************************************/

void
mdep_setinterrupt(SIGFUNCTYPE i)
{
}

/*********************************************************************************************/

void
mdep_ignoreinterrupt(void)
{
}

/*********************************************************************************************/

void
DoAppleItem (short item)
{
	GrafPtr	curPort;
	Str255	str;
	Handle	h;

	if (item == 1)
	{
		Alert( 128, NULL );		/* Bring up the about box */
	}
	else
	{
		GetPort (&curPort);
		GetMenuItemText (appleMenu, item, str);		/* get DA name */
		SetResLoad (false);
		h = GetNamedResource ('DRVR', str);
		SetResLoad (true);
		if (h != NULL)
		{
			ReserveMem (GetResourceSizeOnDisk (h) + 0x1000);
			(void) OpenDeskAcc (str);			/* open it */
		}
		SetPort (curPort);
	}

} // DoAppleItem

/*********************************************************************************************/

void
DoFileItem (short item)
{

	switch (item) {
	
	case quitItem:
		mdep_bye();
		exit(0);
	}

} // DoFileItem

/*********************************************************************************************/
/*
void
DoSynthItem (short item)
{

	switch (item) {
	
	case internalItem:
		// uncheck external
		CheckItem (synthMenu, externalItem, FALSE);
		// check internal
		CheckItem (synthMenu, internalItem, TRUE);
		theEnv.useQT = TRUE;
		break;

	case externalItem:
		// uncheck internal
		CheckItem (synthMenu, internalItem, FALSE);
		// check external
		CheckItem (synthMenu, externalItem, TRUE);
		theEnv.useQT = FALSE;
		break;
	}

} // DoSynthItem
*/
/*********************************************************************************************/

void
DoMIDIItem (short item)
{
	OSErr	err;
	FSSpec	fSpec;
	short	vRefNum;
	long	dirID;
	FInfo	fndrInfo;

	switch (item) {
/*
	case QuickTimeItem:
		// uncheck OMS
		CheckItem (midiMenu, OMSItem, FALSE);
		// check QuickTime
		CheckItem (midiMenu, QuickTimeItem, TRUE);
		theEnv.useQT = TRUE;
		break;

	case OMSItem:
		// uncheck QuickTime
		CheckItem (midiMenu, QuickTimeItem, FALSE);
		// check OMS
		CheckItem (midiMenu, OMSItem, TRUE);
		theEnv.useQT = FALSE;
		break;
*/
	case QTSettingsItem:
		err = FindFolder (kOnSystemDisk,			// look on the System Disk
						  kControlPanelFolderType,	// look for the Control Panels folder
						  kDontCreateFolder,		// don't create a folder if not found
						  &vRefNum,					// volume reference
						  &dirID);					// directory ID

		if (err != noErr) break;
		
		err = FSMakeFSSpec (vRefNum, dirID, "\pQuickTimeª Settings", &fSpec);
		if (err != noErr) break;
		
		err = FSpGetFInfo(&fSpec, &fndrInfo);	
		if (err != noErr) break;
		
		
		
		break;
	}

} // DoMIDIItem

/*********************************************************************************************/

void
DoMenuCommand (long menuResult)
{
	short menu, item;

	menu = HiWord (menuResult);

	if ( menu == 0 )
		return;

	item = LoWord (menuResult);

	switch (menu) {
	
	case appleMenuID:
		DoAppleItem (item);
		break;
		
	case fileMenuID:
		DoFileItem (item);
		break;

	case midiMenuID:
		DoMIDIItem (item);
		break;

#if HELP	
	case kHMHelpMenuID:
		/* This is a non-casual help display.  The user directly asked for help. */
		switch( item - systemHelpItemCount ) {
		case iHoWHelp:
			DisplayHelp( 0, false );
			break;
		}
#endif
	}
	HiliteMenu (0);

} // DoMenuCommand

/*********************************************************************************************/

int
mdep_waitfor(int tmout)
{
	long				startTime, newSize;
	int					eventType;
	Boolean				gotEvent;
	EventRecord			theEvent;
	WindowPtr			wind;
	short				thePart;
	Point				thePoint;
	short				myEventMask = mDownMask + mUpMask + keyDownMask +
									  activMask + updateMask + highLevelEventMask + osMask;
	Rect				r;
	OSErr				err;
	FInfo				fi;
#if MIDI_IN_STATS
	wide				currentTicks;
	extern void			ComputeLatency ( wide ticks);
#endif

#if DEBUGWAITNEXT
	long long			microstart, micronow;
	long				elapsed, remainder;
#endif

	extern void			SuspendMidi		(void);
	extern void			ResumeMidi		(void);

	startTime = mdep_milliclock();	// get current time
	gotEvent = FALSE;
	eventType = 0;
	
//	if ((startTime - keykitstart) < 4000) {
		// don't process events until keykit is ready.
//		goto waitFor_bail;
//	}

	if (pageFile[0] != '\0') {

		// convert to pascal string
		CtoPstr(pageFile);
		
		err = GetFInfo( (StringPtr)pageFile, 0,  &fi );	/* get current info */
		
		fi.fdCreator = SIGNATURE;						/* change the file's creator */
		
		err = SetFInfo( (StringPtr)pageFile, 0,  &fi );	/* update with changes */
	
		// restore to c string
		PtoCstr( (unsigned char*)pageFile);
		
		pageFile[0] = '\0';
	}
	
	if ( (tmout == 0) ) {
		if ( ! EventAvail (myEventMask, &theEvent) ) {
			goto waitFor_bail;
		}
//		else {
//			waitTime = 0L;
//		}
	}
//	else {
		// Compute the remaining time in ticks
//		waitTime = (tmout - (mdep_milliclock() - startTime)) >> 4;
//	}

//	if (tmout != 0) waitTime = 1L;
	
	waitTime = tmout >> 4;

#if DEBUGWAITNEXT
	Microseconds ( (UnsignedWide *) &microstart);
#endif

//	if (GetNextEvent (myEventMask, &theEvent))

	if (WaitNextEvent (myEventMask,
					   &theEvent,
					   waitTime,
					   MouseRgn))
	{
#if DEBUGWAITNEXT
		Microseconds ((UnsignedWide *) &micronow);
		elapsed = (micronow - microstart) / 1000L;
//		(void) WideSubtract (&micronow, &microstart);			// arg1 = arg1 - arg2
//		elapsed = WideDivide (&micronow, 1000L, &remainder);	// returned = arg1 / arg2

		if ( elapsed > (waitTime << 4)) {
			eprint("WaitNextEvent exceeded sleep time! waitTime = %ld, elapsed = %ld\n",
						waitTime << 4, elapsed);
		}

#endif

		switch (theEvent.what) {

			case mouseDown:
			
				if (theEvent.where.h == -1) {
					// MIDI input event
					eventType = K_MIDI;
					gotEvent = TRUE;
					break;
				}
/*
				if (theEvent.where.h == -2) {
					// clock task fired
				//	eventType = K_NOTHING;
				//	gotEvent = TRUE;
					break;
				}
*/
				thePart = FindWindow( theEvent.where, &wind );
	
				switch (thePart) {
				
				case inMenuBar:
					DoMenuCommand ( MenuSelect (theEvent.where) );
					break;
	
				case inSysWindow:
					SystemClick( &theEvent, wind );
					break;
	
				case inDrag:
					r = qd.screenBits.bounds;
					InsetRect( &r, 4, 4 );		/* Keep it on screen */
					DragWindow( wind, theEvent.where, &r );
					break;
				
				case inGrow:
					r = qd.screenBits.bounds;
					InsetRect( &r, 4, 4 );		/* Keep it on screen */
					newSize = GrowWindow (wind, theEvent.where, &r);
					SizeWindow (wind,
								LoWord(newSize),	// width
								HiWord(newSize),	// height
								TRUE);
					eventType = K_WINDRESIZE;
					gotEvent = TRUE;
					break;

				case inContent:
					if ( (wind != theWindow) ) {
						// This isn't our window
						break;
					}
					
					// If our window is in front, report the mouse click,
					// else bring it to the front.
					if ( wind == FrontWindow() ) {
						Msb = 1;	// indicate button one is pressed
						thePoint = theEvent.where;
						GlobalToLocal(&thePoint);
						Msx = thePoint.h;
						Msy = thePoint.v;
						gotEvent = TRUE;
						eventType = K_MOUSE;
					}
					else {
						SelectWindow( wind );
					}
					break;
										
				} // switch (thePart)
				
				break;
	
			case mouseUp:

				thePart = FindWindow( theEvent.where, &wind );
	
				if ( (thePart == inContent) && (wind == theWindow) ) {
				
						Msb = 0;	// indicate no button is pressed
						thePoint = theEvent.where;
						GlobalToLocal(&thePoint);
						Msx = thePoint.h;
						Msy = thePoint.v;
						gotEvent = TRUE;
						eventType = K_MOUSE;
				}

				break;

			case activateEvt:
	//			InvalRect (&theWindow->portRect);
	//			DrawMenuBar();
				break;

			case updateEvt:
				eventType = K_WINDEXPOSE;
				gotEvent = TRUE;
				BeginUpdate( theWindow );
				EndUpdate( theWindow );
				break;

			case keyDown:
		
				if ( (theEvent.modifiers & cmdKey) ) {
					// If the command key is down, interpret this as
					// a menu command.
					DoMenuCommand ( MenuKey (theEvent.message & charCodeMask) );
					break;
				}
				
				eventType = K_CONSOLE;
				gotEvent = TRUE;
				// save the character in a global...
				theChar = (char)(theEvent.message & charCodeMask);
				break;
	
			case kHighLevelEvent:
				
				validAE = FALSE;

				HandleAppleEvents (&theEvent);
				
				if (validAE) {
					gotEvent = TRUE;
					eventType = K_PORT;
					validAE = FALSE;				
				}
				break;

			case osEvt:
				if (theEvent.message & 0x01000000 ) {		// suspend or resume
					if ( theEvent.message & 0x00000001 ) {
						// resume event
						
						waitTime = FGWAITTIME; 	// resume means activate
						
						ResumeMidi();
						
					} else {
						// suspend event
						
						waitTime = BGWAITTIME;
						
						SuspendMidi();
						
					}
				}
				// -------- check for a mouse-moved event ------
				if ((theEvent.message & 0xFF000000) == 0xFA000000){ // moved
					if (Msb != 0) {
						// Only report moused-moved events if the button is down
						thePoint = theEvent.where;
						GlobalToLocal(&thePoint);
						Msx = thePoint.h;
						Msy = thePoint.v;
						gotEvent = TRUE;
						eventType = K_MOUSE;
					}
				}
	
				break;

			} // switch (theEvent.what)
			
		} // if WaitNextEvent

waitFor_bail:	
	if (!gotEvent) {
		eventType = K_TIMEOUT;
	}
	
#if MIDI_IN_STATS
	if (eventType == K_MIDI) {
		Microseconds ( (UnsignedWide *) &currentTicks );
		ComputeLatency (currentTicks);
	}
#endif

	return eventType;

} // mdep_waitfor

/*********************************************************************************************/

WindowPtr
MakeWindow(void)
{
	Rect		theRect;
	WindowPtr	wind;
	
	SetRect(&theRect, 4,								// left
					  4 + GetMBarHeight() + TITLEBARHEIGHT,	// top
					  qd.screenBits.bounds.right - 32,	// right
					  qd.screenBits.bounds.bottom - 4);		// bottom

	wind = NewCWindow(NULL,				/* create window storage for me */
					  &theRect,			/* the window's rectangle */
					  "\pKeyKit",		/* the window's title */
					  TRUE,				/* draw window */
					  documentProc,		/* window type */
					  (WindowPtr)(-1),	/* put in front of other windows */
					  false,			/* goAwayFlag */
					  0);				/* reference value */
					  
	SetPort (wind);
	
	MouseRgn = NewRgn();
	DiffRgn( LMGetGrayRgn(), ((WindowPeek)wind)->strucRgn, MouseRgn );
					  
	return wind;

} // MakeWindow

/*********************************************************************************************/

#define sweepCursor		128		// rectangle sweep cursor resource id
#define leftRightCursor	129		// left-right sweep cursor resource id
#define upDownCursor	130		// up-down sweep cursor resource id
#define moveCursor		131		// move something anywhere cursor resource id

int
mdep_startgraphics(int argc,char **argv)
{
	/* Get cursors from the system file's resource fork */
	cross = **(GetCursor(crossCursor));
	ibeam = **(GetCursor(iBeamCursor));
	watch = **(GetCursor(watchCursor));
	
	// These are in keykit's resource fork.
	// We should probably check to see that they are really there
	// and default to the cross if they're not.
	sweep = **(GetCursor(sweepCursor));
	leftRight = **(GetCursor(leftRightCursor));
	upDown = **(GetCursor(upDownCursor));
	move = **(GetCursor(moveCursor));

	theWindow = MakeWindow();
	
	*Colors = 256;

	return(0);

} // mdep_startgraphics

/*********************************************************************************************/

void
UpperCase (char *str)
{
	short i;

	for (i = 0; str[i]; i++)
		str[i] = toupper (str[i]);

} // UpperCase

/*********************************************************************************************/

pascal Boolean // suppress this file?
myFileFilter (CInfoPBRec *pb, char *types)
{
	char	theString[80];
	char	*str, *pat;
	char	regExp[80];
	Boolean	keep = FALSE;	// don't display the file unless it matches one of the "types"

	// Don't suppress directories
	if ((pb->hFileInfo.ioFlAttrib) & 0x0010)
		return FALSE;
	
	PtoCstr( (unsigned char *) (pb->hFileInfo.ioNamePtr) );

	strcpy ( (char *) theString, (char *) ( pb->hFileInfo.ioNamePtr) );

	CtoPstr( (char *) (pb->hFileInfo.ioNamePtr) );

	// The Mac filesystem isn't case sensitive, so we won't be either.
	UpperCase (theString);

	pat = strtok (types, ";"); 			// get a pointer to the first pattern
	while (pat != NULL) {

		// Convert the pattern to something re_comp() can use (see regex.c).
		str = strstr (types, "*.");
		if (str != NULL) {
			strcpy (regExp, ".*\\.");
			strcat (regExp, (str + 2));
		}

		// The Mac filesystem isn't case sensitive, so we won't be either.
		UpperCase (regExp);

		// Compile the regular expression for later matching by myFileFilter()
		myre_comp (regExp);
	
		// If the file passed in doesn't match any of the extension patterns,
		// don't display it in the browse dialog.
		keep = keep || myre_exec(theString);
		
		pat = strtok (NULL, ";");		// look for another pattern
	}

	return ( !keep );

} // myFileFilter

/*********************************************************************************************/
// dialog hook routine for CustomPutFile()

pascal short
myDialogHook(short item, DialogPtr theDialog, void *myDataPtr)
{
	short			itemType = 0;
	Rect			itemRect;
	Handle			itemHandle;
	char			filename[256], *str;
	extern Boolean	isPageFile;

	switch (item) {
	
	case sfItemOpenButton:	// user hit the "Save" button
		// Check to see if the file extension is ".kp". If
		// it is change the file's creator to indicate keynote
		// is the creator.
		
		// Get the filename typed by the user.
		GetDialogItem ( theDialog, sfItemFileNameTextEdit, &itemType, &itemHandle, &itemRect );
		
		if (itemType != editText) {
			// if the itemType is not editable text, we must
			// have hooked the conflict dialog box. Since this appears
			// after the user has typed the filename, we will have
			// already decided if the file is either a keynote or page file.
			break;
		}

		// Get the user-typed filename
		GetDialogItemText (itemHandle, (StringPtr)filename);
		
		// convert it to a c-string
		PtoCstr( (unsigned char*) filename );
		
		// look for a "."
		str = strstr (filename, ".");

		if (str != NULL) {
			if ( (strcmp ( (str + 1), "kp" ) == 0) ||	// page file
				 (strcmp ( (str + 1), "k" ) == 0) )		// keynote file
			{
				// indicate that the user is writing a file
				// whose creator should be changed.
				isPageFile = TRUE;
			}
			else {
				isPageFile = FALSE;
			}
		}

		break;
	}
	
	return item;

} // myDialogHook

/*********************************************************************************************/

char *
mdep_browse(char *desc, char *types, int mustexist)
{
	SFTypeList			typeList = {'????'};
	short				numTypes = -1;
	StandardFileReply	theReply;
	short				wdRefNum;
	OSErr				err;
	char				fullPathName[_MAX_PATH];
	Point				where = {-1, -1};
	extern Boolean		isPageFile;

	
	// I'm using the 'mustexist' variable to determine whether
	// to read or write a file.
	if (mustexist) {
	
		CustomGetFile (
			NewFileFilterYDProc (myFileFilter),	// file filter function
			numTypes,							// number of file types
			typeList,							// file type list
			&theReply,							// the result
			0,									// dialog ID
			where,								// location
			NULL,								// dialog hook
			NULL,								// event filter function
			NULL,								// active item list
			NULL,								// activation function
			types);								// pass the type list
/*
		StandardGetFile (NewFileFilterProc (myFileFilter),	// filter function
						 numTypes,							// number of file types
						 typeList,							// file type list
						 &theReply);						// the result
*/
	}
	else {
		CtoPstr( (char *) desc );				// convert the prompt to a Pascal string

		CustomPutFile (
			(StringPtr) desc,					// the prompt
			"\p",								// initial filename
			&theReply,							// the reply structure
			0,									// custom dialog resource
			where,								// where to put the dialog
			NewDlgHookYDProc (myDialogHook),	// my dialog hook routine
			NULL,								// filter proc.
			NULL,								// activeList
			NULL,								// activeProc
			NULL);								// private data ptr.

		// convert the prompt back to a C string
		PtoCstr( (unsigned char*) desc );
	}

	// see if the user cancelled
	if (!theReply.sfGood) return (NULL);

	// Remember the directory where the file came from
	LMSetCurDirStore (theReply.sfFile.parID);
	LMSetSFSaveDisk (-theReply.sfFile.vRefNum);

	// Open a Working Directory
	err = OpenWD (theReply.sfFile.vRefNum, theReply.sfFile.parID, NULL, &wdRefNum);

	// Set the default working directory for fopen()
	err = SetVol(NULL, wdRefNum);

	// Get the full pathname
	PathNameFromDirID (theReply.sfFile.parID, theReply.sfFile.vRefNum, (StringPtr)fullPathName);
	
	// Convert to C strings
	PtoCstr( (unsigned char*)fullPathName);
	PtoCstr( (unsigned char*)theReply.sfFile.name);

	// Combine directory and filename to get a full path
	mdep_makepath (fullPathName, (char*)theReply.sfFile.name, filename, (int)_MAX_PATH);

	/*
	 * Set the global pageFile so the code in mdep_waitfor() will know
	 * to change the creator of this file to match keynote's.
	 */
	if (isPageFile) {
		strcpy (pageFile, filename);
		isPageFile = FALSE;
	}

	return( filename );

} // mdep_browse

/*********************************************************************************************/

/* NOTE: the values that mdep_screenresize() uses are NOT */
/*       the same as what mdep_maxx() and mdep_maxy() give.  mdep_maxx() and mdep_maxy() */
/*       give the size of the plotting area, which is not the same as the */
/*       size of the enclosing window frame, which is what mdep_screenresize() is passed. */
int
mdep_screenresize(int x0, int y0, int x1, int y1)
{
	MoveWindow (theWindow ,(short)x0, (short)(y0 + GetMBarHeight() + TITLEBARHEIGHT), FALSE);
	SizeWindow (theWindow, (short)(x1 - x0), (short)(y1 - y0), FALSE);

	DiffRgn( LMGetGrayRgn(), ((WindowPeek)theWindow)->strucRgn, MouseRgn );

} // mdep_screenresize

/*********************************************************************************************/

int
mdep_screensize(int *x0, int *y0, int *x1, int *y1)
{
	*x0 = theWindow->portRect.left;
	*y0 = theWindow->portRect.top; // - TITLEBARHEIGHT;
	*x1 = theWindow->portRect.right;
	*y1 = theWindow->portRect.bottom;
	
	return (0);

} // mdep_screensize

/*********************************************************************************************/

int
mdep_maxx()
{
//	return qd.screenBits.bounds.right;
	return theWindow->portRect.right; // - theWindow->portRect.left + 1;
}

/*********************************************************************************************/

int
mdep_maxy()
{
//	return qd.screenBits.bounds.bottom;
	return theWindow->portRect.bottom; // - theWindow->portRect.top + 1;
}

/*********************************************************************************************/

void
mdep_plotmode(int mode)
{

//	SetPort (theWindow);

	switch (mode) {
	
	case P_STORE:
		PenMode(patCopy);
		TextMode(srcOr);	// Draws with transparent background.
		break;
	
	case P_CLEAR:
		PenMode(patBic);
		TextMode(srcBic);
		break;
	
	case P_XOR:
		PenMode(patXor);
		TextMode(srcXor);
		break;
		
	} // switch
	
	MplotMode = mode;
	
} // mdep_plotmode

/*********************************************************************************************/

void
mdep_endgraphics(void)
{
}

/*********************************************************************************************/

void
mdep_line(int x0,int y0,int x1,int y1)
{
//	SetPort (theWindow);

	MoveTo ((short)x0, (short)y0);
	LineTo ((short)x1, (short)y1);

} // mdep_line

/*********************************************************************************************/

void
mdep_box(int x0,int y0,int x1,int y1)
{
	Rect	theRect;
	
//	SetPort (theWindow);

	SetRect(&theRect, (short)x0,		// left
					  (short)y0,		// top
					  (short)(x1 + 1),	// right
					  (short)(y1 + 1));	// bottom
	
	FrameRect (&theRect);

} // mdep_box

/*********************************************************************************************/

void
mdep_boxfill(int x0,int y0,int x1,int y1)
{
	Rect	theRect;
	
//	SetPort (theWindow);

	SetRect(&theRect, (short)x0,		// left
					  (short)y0,		// top
					  (short)(x1 + 1),	// right
					  (short)(y1 + 1));	// bottom
	
	PaintRect (&theRect);

} // mdep_boxfill

/*********************************************************************************************/

void
mdep_ellipse (int x0, int y0, int x1, int y1)
{

	Rect	theRect;
	
//	SetPort (theWindow);

	SetRect(&theRect, (short)x0,		// left
					  (short)y0,		// top
					  (short)(x1 + 1),	// right
					  (short)(y1 + 1));	// bottom
	
	FrameOval (&theRect);
	
} // mdep_ellipse

/*********************************************************************************************/

void
mdep_fillellipse (int x0, int y0, int x1, int y1)
{

	Rect	theRect;
	
//	SetPort (theWindow);

	SetRect(&theRect, (short)x0,		// left
					  (short)y0,		// top
					  (short)(x1 + 1),	// right
					  (short)(y1 + 1));	// bottom
	
	PaintOval (&theRect);
	
} // mdep_fillellipse

/*********************************************************************************************/

void
mdep_fillpolygon (int *xarr, int *yarr, int size)
{
	tprint("fillpolygon not supported on Mac.");
} // mdep_fillpolygon

/*********************************************************************************************/

int
mdep_help (char *fname, char *keyword)
{
#if HELP	
	short	i;

	for (i = 0; helpData[i].tag != 0; i++) {
		if ( strcmp ( helpData[i].keyword, keyword ) == 0 ) {
			break;
		}
	}

	DisplayHelp (helpData[i].tag,	// tag
				FALSE );			// casual?
#endif
} // mdep_help

/*********************************************************************************************/

Pbitmap
mdep_allocbitmap(int xsize,int ysize)
{
	Pbitmap		pb;
	Rect		theRect;
	GWorldPtr	gwptr;
	static GWorldFlags	flags = 0;
	QDErr		err;
	
#if DEBUGBITMAPS
	long		mem;
	mem = mdep_coreleft();
#endif

	pb.xsize = pb.origx = xsize;
	pb.ysize = pb.origy = ysize;

	SetRect (&theRect, 0, 0, (short)(xsize - 1), (short)(ysize - 1));

	/* Create an Offscreen Graphics world. */
	err = NewGWorld (&gwptr, 0, &theRect, nil, nil, flags);
	if (err) {
		// must be running in temporary memory
		flags |= useTempMem;
		err = NewGWorld (&gwptr, 0, &theRect, nil, nil, flags);
		if (err) {
			DebugStr ("\pmdep_allocbitmap: NewGWorld failed!");
			mdep_bye();
		}
	
	}
#if DEBUGBITMAPS
	eprint("mdep_allocbitmap: grabbed %ld bytes at 0x%x\n", mdep_coreleft() - mem, gwptr);
#endif

	pb.ptr = (unsigned char*)gwptr;

	return pb;

} // mdep_allocbitmap

/*********************************************************************************************/

Pbitmap
mdep_reallocbitmap(int xsize, int ysize, Pbitmap pb)
{
	mdep_freebitmap(pb);

	return mdep_allocbitmap (xsize, ysize);

} // mdep_reallocbitmap

/*********************************************************************************************/

void
mdep_freebitmap(Pbitmap pb)
{
	GWorldPtr	gwptr;
	long		mem;
	
#if DEBUGBITMAPS
				eprint("mdep_freebitmap\n");
#endif
	gwptr = (GWorldPtr) pb.ptr;

	if ( gwptr ) {
#if DEBUGBITMAPS
		mem = mdep_coreleft();
#endif
		DisposeGWorld (gwptr);
#if DEBUGBITMAPS
		eprint("DisposeGWorld released %ld bytes at 0x%x\n", mdep_coreleft() - mem, gwptr);
#endif
	}

} // mdep_freebitmap

/*********************************************************************************************/

void
mdep_movebitmap(int fromx0,int fromy0,int width,int height,int tox0,int toy0)
{
	Rect		srcRect, dstRect;
	RGBColor 	savefg, savebg, c;

#if DEBUGBITMAPS
//				eprint("mdep_movebitmap\n");
#endif
	// We need to set these because CopyBits looks at them
	GetForeColor( &savefg );
	GetBackColor( &savebg );
	c.red = c.green = c.blue = 0;
	RGBForeColor( &c );
	c.red = c.green = c.blue = 0xFFFF;
	RGBBackColor( &c );

	SetRect(&srcRect, (short)fromx0,					// left
					  (short)fromy0,					// top
					  (short)(fromx0 + width + 1),		// right
					  (short)(fromy0 + height + 1));	// bottom
	
	SetRect(&dstRect, (short)tox0,					// left
					  (short)toy0,					// top
					  (short)(tox0 + width + 1),	// right
					  (toy0 + height + 1));			// bottom
	
    CopyBits( (BitMap *) &(theWindow->portBits), (BitMap *) &(theWindow->portBits), 
    		  &srcRect, &dstRect, srcCopy, NULL );

	RGBForeColor( &savefg );
	RGBBackColor( &savebg );

} // mdep_movebitmap

/*********************************************************************************************/

void
mdep_pullbitmap (int x0, int y0, Pbitmap pb)
{
	GWorldPtr	gwptr;
	Rect		srcRect, dstRect;
	short		height, width;
	
#if DEBUGBITMAPS
				eprint("mdep_pullbitmap\n");
#endif
	gwptr = (GWorldPtr) pb.ptr;
	
	dstRect = (*(gwptr->portPixMap))->bounds;
	
	width = dstRect.right - dstRect.left;
	height = dstRect.bottom - dstRect.top;
	
	SetRect(&srcRect, (short)x0,				// left
					  (short)y0,				// top
					  (short)(x0 + width + 1),	// right
					  (short)(y0 + height + 1));	// bottom
	
	if ( LockPixels( gwptr->portPixMap ) )
	{
	    CopyBits( (BitMap *) &(theWindow->portBits), (BitMap *) &(gwptr->portPixMap), 
	    		  &srcRect, &dstRect, srcCopy, NULL );
    }
 	UnlockPixels( gwptr->portPixMap );
 
} // mdep_pullbitmap

/*********************************************************************************************/

void
mdep_putbitmap (int x0, int y0 ,Pbitmap pb)
{
	GWorldPtr	gwptr;
	RGBColor 	savefg, savebg, c;
	Rect 		srcRect, dstRect;
	GrafPtr 	savePort;
	short		height, width;
	
#if DEBUGBITMAPS
				eprint("mdep_putbitmap\n");
#endif
	GetForeColor( &savefg );		/* Robert sez ya gotta do this */
	GetBackColor( &savebg );
	c.red = c.green = c.blue = 0;
	RGBForeColor( &c );
	c.red = c.green = c.blue = 0xFFFF;
	RGBBackColor( &c );
	GetPort( &savePort );
	SetPort( theWindow );

	gwptr = (GWorldPtr) pb.ptr;

	srcRect = (*(gwptr->portPixMap))->bounds;
	
	width = srcRect.right - srcRect.left;
	height = srcRect.bottom - srcRect.top;
	
	SetRect(&dstRect, (short)x0,				// left
					  (short)y0,				// top
					  (short)(x0 + width + 1),	// right
					  (short)(y0 + height + 1));	// bottom
	
	if ( LockPixels( gwptr->portPixMap ) )
	{
	    CopyBits( (BitMap *) &(gwptr->portPixMap), (BitMap *) &(theWindow->portBits), 
	    		  &srcRect, &dstRect, srcCopy, NULL );
    }
 	UnlockPixels( gwptr->portPixMap );

 	SetPort( savePort );
 	
	RGBForeColor( &savefg );
	RGBBackColor( &savebg );
	
} // mdep_putbitmap

/*********************************************************************************************/

short
isPressed (unsigned short k )

// k =  any keyboard scan code, 0-127
{
	unsigned char km[16];
//	KeyMap	km;		// typedef UInt32 KeyMap[4];

	GetKeys( (UInt32 *) km);
	return ( ( km[k>>3] >> (k & 7) ) & 1);

} // isPressed

/*********************************************************************************************/

#define CMD_CODE	0x37	// command key
#define SHIFT_CODE	0x38	// shift key
#define OPT_CODE	0x3a	// option key
#define CTRL_CODE	0x3b	// control key


/* Gets current state of mouse, always returns immediately.  */
int
mdep_mouse(int *ax,int *ay, int *am)
{
	Point	thePoint;

	// get the current location of the mouse in local coordinates
/*
	GetMouse (&thePoint);
	if ( ax )
		*ax = thePoint.h;
	if ( ay )
		*ay = thePoint.v;
*/
	if ( ax )
		*ax = Msx;
	if ( ay )
		*ay = Msy;
	
	
	// get the current state of the modifier keys
	if ( am ) {
		if ( isPressed (CTRL_CODE) ) {
			*am = 1;
		}
		else if ( isPressed (SHIFT_CODE) ) {
			*am = 2;
		}
		else {
			*am = 0;
		}
	}
	
	if ( Button() ) {
		if ( isPressed (OPT_CODE) ) {
			return 2;	// simulate right mouse button
		}
		else {
			return 1;
		}
	}
	else {
		return 0;
	}
	
} // mdep_mouse

/*********************************************************************************************/

int
mdep_mousewarp(int x, int y)
{
	// Sorry, this is a no-no for the Mac.
}

/*********************************************************************************************/

void
mdep_color (int n)
{
	RGBForeColor( &Mcolors[n] );
}

/*********************************************************************************************/

void
mdep_colormix (int n, int r, int g, int b)
{
	Mcolors[n].red = ((short)r) << 8;
	Mcolors[n].green = ((short)g) << 8;
	Mcolors[n].blue = ((short)b) << 8;
}

/*********************************************************************************************/

void CopyGWtoWindow(GWorldPtr gw, WindowPtr window )
{
	RGBColor savefg, savebg, c;
	Rect srcRect, dstRect;
	GrafPtr savePort;
	
	GetForeColor( &savefg );		/* Robert sez ya gotta do this */
	GetBackColor( &savebg );
	c.red = c.green = c.blue = 0;
	RGBForeColor( &c );
	c.red = c.green = c.blue = 0xFFFF;
	RGBBackColor( &c );
	GetPort( &savePort );
	SetPort( window );

	srcRect = (*(gw->portPixMap))->bounds;
	dstRect = window->portRect;

	if ( LockPixels( gw->portPixMap ))
	{
	    CopyBits( (BitMap *)&(gw->portPixMap), (BitMap *) &(window->portBits), 
	    		  &srcRect, &dstRect, srcCopy, NULL );
    }
 	UnlockPixels( gw->portPixMap );
 	SetPort( savePort );
 	
	RGBForeColor( &savefg );
	RGBBackColor( &savebg );
	
} /* CopyGWtoWindow */

/****************************************************************************************/

void
mdep_sync(void)
{
	//InvalRect (&theWindow->portRect);
}

/*********************************************************************************************/

char *
mdep_fontinit(char *fnt)
{
	SetPort (theWindow);

	TextFont (kFontIDMonaco);	// mono-spaced font
	TextSize (9);
	TextMode (srcOr);	// draws with transparent background

	return((char*)NULL);
}

/*********************************************************************************************/

int
mdep_fontheight (void)
{
	FontInfo	fInfo;
	
	SetPort (theWindow);

	GetFontInfo (&fInfo);
	
	MfontAscent = fInfo.ascent;

	return ((int)(fInfo.ascent + fInfo.descent + 1));

} // mdep_fontheight

/*********************************************************************************************/

int
mdep_fontwidth (void)
{
	FontInfo	fInfo;

	SetPort (theWindow);

	GetFontInfo (&fInfo);
	
	return ((int)fInfo.widMax);

} // mdep_fontwidth

/*********************************************************************************************/

void
mdep_string (int x, int y, char *s)
{
	char	theString[256];

	strcpy (theString, s);
	CtoPstr (theString);
	
	// Keynote gives the drawing point as the upper left corner
	// of the character. QuickDraw draws characters from the baseline.
	MoveTo ( (short)x, (short)(y + MfontAscent));
	DrawString ( (ConstStr255Param)theString );

} // mdep_string

/*********************************************************************************************/

void
mdep_setcursor(int type)
{
	switch (type) {
	
	case M_ARROW:
	default:
		SetCursor (&qd.arrow);
		break;
		
	case M_SWEEP:
		SetCursor (&sweep);
		break;
		
	case M_LEFTRIGHT:
		SetCursor (&leftRight);
		break;
		
	case M_UPDOWN:
		SetCursor (&upDown);
		break;
		
	case M_ANYWHERE:
		SetCursor (&move);
		break;
		
	case M_CROSS:
		SetCursor (&cross);
		break;
		
	case M_BUSY:
		SetCursor (&watch);
		break;
		
	case M_NOTHING:
		HideCursor();
		return;
		
	} // switch

	ShowCursor();

} // mdep_setcursor

/*********************************************************************************************/

static PORTHANDLE 	od[2];		// ports for OpenDocuments AppleEvents
static PORTHANDLE	ds[2];		// ports for "Do Script" AppleEvents

PORTHANDLE *
mdep_openport(char *name, char *mode, char *type)
{

	if ( strcmp (type, OPENDOCS) == 0 ) {
		od[0] = OPENDOCS;
		od[1] = "";
		return od;
	}
	else if ( strcmp (type, DOSCRIPT) == 0 ) {
		ds[0] = DOSCRIPT;
		ds[1] = "";
		return ds;
	}
	else {
		return (PORTHANDLE *) 0;
	}
}

/*********************************************************************************************/

Datum
mdep_ctlport(PORTHANDLE m, char *cmd, char *arg)
{
}

/*********************************************************************************************/

int
mdep_putportdata(PORTHANDLE m, char *buff, int size)
{
}

/*********************************************************************************************/

int
mdep_getportdata(PORTHANDLE *handle, char *buff, int buffsize, Datum *pd)
{
	int ret_val;
	
	if ( strcmp (theAE, DOSCRIPT) == 0 ) {
		// Check for a keynote command line
		ret_val = strlen(theScript);
		if (ret_val == 0) {
			*handle = NULL;
			return -1;
		}
		else {
			strcpy(buff, theScript);
			theScript[0] = '\0';
			theAE[0] = '\0';
			*handle = ds[0];
			return ret_val;
		}
	}

	if ( strcmp (theAE, OPENDOCS) == 0 ) {
		// Check for a page filename
		ret_val = strlen(filename);
		if (ret_val == 0) {
			*handle = NULL;
			return -1;
		}
		else {
			strcpy(buff, filename);
			filename[0] = '\0';
			*handle = od[0];
			return ret_val;
		}
	}
	
	// return -1 if no more input
	return -1;

} // mdep_getportdata

/*********************************************************************************************/

int
mdep_closeport(PORTHANDLE m)
{
}

/*********************************************************************************************/

// I moved this from midi.h because of conflicts with QuickTimeComponents.h and
// keynote.

Datum
mdep_mdep(int argc)
{
	return Noval;
}


