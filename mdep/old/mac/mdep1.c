#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <Memory.h>

#include "pathname.h"

#include "mdep.h"
#include "key.h"	// for Lowcorelim
#include "clock.h"
#include "appleEvnts.h"
#include "environ.h"
#include "help.h"
#include "myResources.h"

/*********************************************************************************************/


// Machine dependent globals

char		rkeyPath[] = "liblocal;lib";
char		rmusicPath[] = "music";
char		keyPath[_MAX_PATH];
char		musicPath[_MAX_PATH];
char		keynoteHome[_MAX_PATH];

DialogPtr	popupDialog;
WindowPtr	theWindow;
char		filename[_MAX_PATH], pageFile[_MAX_PATH] = "";
char		theScript[80];				// Text for incoming keynote command via Applescript
Boolean		isPageFile;
char		name[_MAX_PATH];
char		theChar;					// the character typed at the console
ENVIRON		theEnv;

MenuHandle	appleMenu, fileMenu, midiMenu; //synthMenu;
FSSpec		homeSpec;			// file spec. for keynote home

// local prototypes
OSErr		GetHome				(char *path);

/*********************************************************************************************/

int
main (int argc,char **argv)
{

	argc = 0;

	MAIN (argc, argv);
	
}

/*********************************************************************************************/

void
SetUpMenus()

{
	short			curMark;

	appleMenu = GetMenu( appleMenuID );				/* Apple Menu */
	if (! appleMenu)
		mdep_abortexit ("Missing Apple menu?");
	AppendResMenu( appleMenu, 'DRVR' );				/* Add all the desk accys */
	InsertMenu( appleMenu, 0 );
	
	fileMenu = GetMenu( fileMenuID );
	if (! fileMenu)
		mdep_abortexit ("Missing file menu?");		
	InsertMenu( fileMenu, 0 );

	DrawMenuBar();

/*
	midiMenu = GetMenu( midiMenuID );
	if (! midiMenu)
		mdep_abortexit ("Missing MIDI menu?");		
	InsertMenu( midiMenu, 1 );

	GetItemMark( midiMenu, QuickTimeItem, &curMark );
	if ( curMark == checkMark) {
		// use built-in QT synthesizer
		theEnv.useQT = TRUE;
	}
	else {
		// use OMS
		theEnv.useQT = FALSE;
	}
*/
} /* SetUpMenus */

/*********************************************************************************************/

void
mdep_bye(void)
{
#if PROFILE
	(void) ProfilerDump("\pkeykit.profile");
	ProfilerTerm();
#endif

	removeClock();

	mdep_endmidi();

#if HELP	
	// Terminate HoW
	EndHelp();
#endif
}

/*********************************************************************************************/

char *
mdep_currentdir (char *buff, int leng)
{

	FSSpec		fileSpec;
	char		fullPathName[_MAX_PATH];
	
	fileSpec.parID = LMGetCurDirStore ();
	fileSpec.vRefNum = LMGetSFSaveDisk ();

	PathNameFromDirID (fileSpec.parID, fileSpec.vRefNum, (StringPtr)&fullPathName[0]);
	
	PtoCstr( (unsigned char*)fullPathName);
	strcpy(buff, fullPathName);

	return buff;

} // mdep_currentdir

/*********************************************************************************************/

OSErr
GetMyEnvironment()
{
	long		response;
	OSErr		err;
	char		errStr[80];
	short		myBit;

	
	// We're assuming that we're running system 6.0.4 or later in
	// order to use the Gestalt trap to query the system environment.
	
	// Check for Color Quickdraw
	err = Gestalt (gestaltQuickdrawFeatures, &response);
	if (err != noErr) {
		sprintf (errStr, "Gestalt returned %d looking for QuickDraw Features", err);
		mdep_popup((char *) errStr);
		goto bail;
	}
	else {
		if ((response & (1 << gestaltHasColor)) == 0) {
			// No Color QuickDraw
			sprintf (errStr, "We need Color QuickDraw - Gestalt returned gestaltQuickdrawFeatures = %.8x", response);
			mdep_popup((char *) errStr);
			goto bail;
		}
	}

	// Check for QuickTime 2.0
	err = Gestalt (gestaltQuickTimeVersion, &response);
	if (err != noErr) {
		theEnv.hasQT2 = FALSE;
		theEnv.useQT = FALSE;
		// Disable the QuickTime items, so user can't select them
//		DisableItem (midiMenu, QuickTimeItem);
//		DisableItem (midiMenu, QTSettingsItem);
		sprintf (errStr, "Gestalt returned %d looking for QuickTime version", err);
		mdep_popup((char *) errStr);
		goto bail;
	}
	else {
		if (response >= 0x02500000) {
			theEnv.hasQT2 = TRUE;
			theEnv.useQT = TRUE;
		}
		else {
			theEnv.hasQT2 = FALSE;
			theEnv.useQT = FALSE;

			sprintf (errStr, "We need QuickTime 2.5 - Gestalt returned %.8x", response);
			mdep_popup((char *) errStr);
			goto bail;

			// Disable the QuickTime items, so user can't select them
//			DisableItem (midiMenu, QuickTimeItem);
//			DisableItem (midiMenu, QTSettingsItem);
			// Make sure OMS item is checked
//			CheckItem (midiMenu, OMSItem, TRUE);
		}
	}


#if FALSE

	// Ask the system if the Code Fragment Manager is available
	err = Gestalt (gestaltCFMAttr, &response);

	if (err) {
		sprintf (errStr, "Gestalt returned %d looking for the Code Fragment Manager", err);
		mdep_popup((char *) errStr);
		goto bail;
	}
	else {
		myBit = gestaltCFMPresent;
		theEnv.hasCFM = BitTst (&response, 31-myBit);

		if (! theEnv.hasCFM) {
			sprintf (errStr, "We need the Code Fragment Manager - Gestalt returned %.8x", response);
			mdep_popup((char *) errStr);
			goto bail;
		}
	}
#endif

	return 0;
	
bail:
	return -1;

} // GetMyEnvironment

/*********************************************************************************************/

static OSErr
GetHome (char *path)
{
	OSErr				err;
	ProcessSerialNumber	psn;
	ProcessInfoRec		pi;
	FSSpec				fileSpec;
	char				fullPathName[_MAX_PATH];
	short				pathLength;

	err = GetCurrentProcess(&psn);  // get our own process serial number
	if (err == noErr) {
		pi.processInfoLength = sizeof(ProcessInfoRec);
					// size of info we want
		pi.processName = NULL;	// don't need the name
		pi.processAppSpec = &fileSpec;	// but the appl.file
		err = GetProcessInformation(&psn, &pi);
	}
	if (err != noErr) {
		eprint("GetHome: GetProcessInformation returned %d", err);
		goto done;
	}
	// fileSpec now contains a FSSpec for the keykit application file

	// save keykit's home file spec
	homeSpec.parID = fileSpec.parID;
	homeSpec.vRefNum = fileSpec.vRefNum;

	// get the full path to home
	PathNameFromDirID (fileSpec.parID, fileSpec.vRefNum, (StringPtr)&fullPathName[0]);

	PtoCstr((unsigned char *) fullPathName);
	strcpy(path, fullPathName);

done:
	return err;

} // GetHome

/*********************************************************************************************/

#if PROFILE
Boolean profilerCleared;
#endif

Handle	mLocalReserve;
//char	*mLocalReserve;

void
mdep_hello (int argc, char **argv)
{
	short	i;
	long	mem;
	OSErr	iErr;
	char	*str, errStr[80];

	FlushEvents( everyEvent - diskMask, 0 );
	InitGraf(&qd.thePort);
	InitFonts();
	InitWindows();
	InitMenus();
	TEInit();
	InitDialogs( NULL );
	InitCursor();

#if !GENERATINGPOWERPC
	/*
	 * Allocate extra stack space
	 */
	SetApplLimit((void *) ( (long)GetApplLimit() - (256 * 1024L) ) );
#endif
	iErr = MemError();

	MaxApplZone();
	iErr = MemError();

	mem = FreeMem();
	for (i = 0; i < 6; i++)
		MoreMasters ();

	// Create a reserve for low memory situations
	mLocalReserve = NewHandle(50000);
//	mLocalReserve = kmalloc(100000, "mLocalReserve");

	SetUpMenus();

	popupDialog = GetNewDialog (POPUPDIALOG, nil, (WindowPtr)(-1L));
	if (popupDialog == 0) {
		DebugStr("\pmdep_hello: Could not get Popup dialog!\n");
		exit(1);
	}
	
	// See what kind of environment we're running in.
	if ( (iErr = GetMyEnvironment()) != noErr ) {
		exit(1);
	}
	
	// Get keynote's home directory.
	GetHome (keynoteHome);
	
	// Make full paths to the keynote library and music directories
	str = strtok (rkeyPath, PATHSEP); 		// get a pointer to the first path
	while (str != NULL) {
		strcat (keyPath, keynoteHome);		// start with the home directory
		strcat (keyPath, PATHCDstr);		// append a directory seoarator
		strcat (keyPath, str);				// concatenate the next path
		str = strtok (NULL, PATHSEP);		// look for another path
		if (str != NULL)
			strcat (keyPath, PATHSEP);		// add the separator
	}

	str = strtok (rmusicPath, PATHSEP); 	// get a pointer to the first path
	while (str != NULL) {
		strcat (musicPath, keynoteHome);	// start with the home directory
		strcat (musicPath, PATHCDstr);		// append a directory seoarator
		strcat (musicPath, str);			// concatenate the next path
		str = strtok (NULL, PATHSEP);		// look for another path
		if (str != NULL)
			strcat (musicPath, PATHSEP);	// add the separator
	}

	// Install Apple events
	InstallAEs();
	
#if HELP	
	// Install help menu
	InitHelp();
#endif

#if PROFILE
	iErr = ProfilerInit (collectDetailed,	// collection method
						 bestTimeBase,		// timebase
						 300,				// estimated number of functions
						 9);				// estimated stack depth
	
	if (iErr == noErr) {
		ProfilerSetStatus (FALSE);			// turn it off for now
		profilerCleared = FALSE;
	}
#endif

installClockTask();

// when we started
keykitstart = mdep_milliclock();
	
} // mdep_hello

/*********************************************************************************************/

int
mdep_changedir(char *d)
{

	WDPBRec	wdpb;
	short	rc;
	char	dir[_MAX_PATH];
	
	strcpy( dir, d );
	CtoPstr( dir );
	
	wdpb.ioNamePtr = (StringPtr)dir;
	wdpb.ioWDDirID = 0;			/* using 0 since name.... */
	wdpb.ioVRefNum = 0;			/* ... identifies fully */
	wdpb.ioWDProcID = '????';	/* Add indivual identification */
	
	rc = PBOpenWDSync( &wdpb );
	if ( rc ) { /* . . . handle the error . . . */ }
	
	LMSetCurDirStore (wdpb.ioWDDirID);

} // mdep_changedir

/*********************************************************************************************/

int
mdep_lsdir(char *dir, char *exp, void (*callback)(char *,int))
{

/*	Recursive procedure: Examine each entry in directory dirID
	If it is a directory, recurse; otherwise, call callback().
*/
	CInfoPBRec	cipbr;				/* local pb */
	HFileInfo	*fpb = (HFileInfo *)&cipbr;	/* to pointers */
	DirInfo	*dpb = (DirInfo *) &cipbr;
	short	rc, idx;
	long	dirID;
	char	filename[_MAX_PATH];

	// get a directory ID from the full pathname in the dir parameter.
	dirID = LMGetCurDirStore ();	// for now use the current directory.

	fpb->ioVRefNum = 0;		/* default volume */
	fpb->ioNamePtr = (StringPtr)filename;	/* buffer to receive name */

	for( idx=1; TRUE; idx++) {	/* indexing loop */
		fpb->ioDirID = dirID;		/* must set on each loop */
		fpb->ioFDirIndex = idx;

		rc = PBGetCatInfoSync( &cipbr );
		if (rc) break;	/* exit when no more entries */

		if (fpb->ioFlAttrib & 16) {
			// it's a directory
			callback ( PtoCstr(fpb->ioNamePtr), 1);
		}
		else {
			// it's a file
			callback ( PtoCstr(fpb->ioNamePtr), 0);
		}
	}

} // mdep_lsdir

/*********************************************************************************************/

long
mdep_filetime(char *fn)
{

FileParam	fpb;
OSErr		rc;
long		ret_val;

	fpb.ioNamePtr = CtoPstr(fn);	// convert to Pascal string
	fpb.ioFDirIndex = 0;			// the index
	fpb.ioVRefNum = 0;				// using current default volume

	rc = PBGetFInfoSync( (ParmBlkPtr)(&fpb) );
	
	PtoCstr((unsigned char *)fn);	// convert back to C string

	if (rc == 0) {
		ret_val = (long)(fpb.ioFlMdDat >> 1);	// Don't return a negative value
		return ret_val;							// return file modified date
	}
	else {
		// error - file probably doesn't exist
		return -1L;
	}

}

/*********************************************************************************************/

int
mdep_fisatty(FILE *f)
{
	if ( f == stdin )
		return 1;
	else
		return 0;// _isatty(_fileno(f));
}

/*********************************************************************************************/

long
mdep_currtime(void)
{
	unsigned long	secs;

	GetDateTime (&secs);
	return secs;
}

/*********************************************************************************************/

long
mdep_coreleft(void)
{
	long mem, growBytes;

	mem = FreeMem();
	if ( mem < *Lowcorelim ) {
		mem = MaxMem(&growBytes);
		if (mem < *Lowcorelim ) {
			// check tempory memory
			mem = TempFreeMem();
		}
	}
	return mem;
}

/*********************************************************************************************/

int
mdep_full_or_relative_path (char *path)
{
	char	*str;

	// Search for an occurance of the node separator character.
	// 'str' will be NULL if we can't find one.
	str = strchr (path, (int)PATHCDchar);

	if (str != NULL)
	{
		// We found an occurance of the node separator character.
		// Must be a path string.
		return 1;	// full or relative path
	}
	else
		return 0;	// plain file name
}

/*********************************************************************************************/

int
mdep_makepath (char *dirname, char *filename, char *result, int resultsize)
{
	char *p, *q;

	if ( resultsize < (int)(strlen(dirname) + strlen(filename) + 1) )
		return 1;
	
	strcpy(result, dirname);

	strcat(result, PATHCDstr);

	strcat(result, filename);

	return 0;
}

/*********************************************************************************************/

Boolean gTempMem = false;

char *
mdep_malloc (unsigned int s, char *tag)
{
	char	*p;
	OSErr	err;
	Handle	mHandle;
	Size	aSize;
	
//	p = (char *) malloc ( (size_t) s );
	p = (char *) NewPtr ( (Size) s);

	if (p == NULL ) {

		// attempt to free enough memory to allow work to be saved
		if ( (mLocalReserve != nil) &&
		 (*mLocalReserve != nil) &&
		 (mLocalReserve != GZSaveHnd()) )
		{
			DisposeHandle(mLocalReserve);
			mLocalReserve = nil;
			aSize = CompactMem( (size_t) s);

/*
 * I wanted to return NULL at this point to allow keykit to abort the current operation
 * and possibly allow the user to save their work and exit, but it appears that keykit may
 * not be checking for NULL because the machine freezes up if I do. Therefore, I'll allow the malloc
 * to succeed with the newly freed up memory so I can get a low memory message to the user.
			p = NULL;
			mdep_popup("Low memory!!  Save work and exit\n");
*/

			// try again
//			p = (char *) malloc ( (size_t) s );
			p = (char *) NewPtr ( (Size) s);
			if (p == NULL) {
				mdep_abortexit("Out of memory!!\n");
			}
			else {
				mdep_popup("Low memory!!  Save work and exit\n");
			}

		}
		else {
			mdep_abortexit("Out of memory!!\n");
		}

	}

/*	
		if ( (mLocalReserve != nil) ) {
			free (mLocalReserve);
			mLocalReserve = nil;
			aSize = CompactMem( (size_t) s);
		}
		else {
			mdep_abortexit("Out of memory!!\n");
		}

		mdep_popup("Out of memory!!  Save work and exit\n");
	}
*/


/*
		// Try to allocate in temporary memory
		mHandle = TempNewHandle (s, &err);
		if (err == noErr) {
			gTempMem = true;
			HLockHi (mHandle);
			p = *mHandle;
		} else {
			p = 0;
			mdep_abortexit("Out of memory!!\n");
		}
*/
	return (p);
}

/*********************************************************************************************/
void
mdep_free (char *s)
{
//long	mem, growBytes, blockSize;
//Size	bytesToFree, compacted;
THz		theZone, appZone;
OSErr	err;

	if (s == NULL) {
		return;
	}

//	bytesToFree = GetPtrSize(s);

	theZone = PtrZone(s);
	appZone = ApplicationZone();
	if(theZone != appZone) {
		err = -1L;
		return;
	}
//	mem = FreeMem();
//	blockSize = MaxBlock();

	DisposePtr( (Ptr) s);
//	compacted = CompactMem( (size_t) s);

//	mem = FreeMem();
//	blockSize = MaxBlock();
/*
	if (!gTempMem) {
		// Don't try to free Temporary memory
		free(s);
	}
	else {
		eprint("Tried to free Temp memory!");
	}
*/
}

/*********************************************************************************************/
