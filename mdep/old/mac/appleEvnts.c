// appleEvents.c

#include <stdio.h>			// for sprintf()
#include <string.h>
#include <AppleEvents.h>
#include <AERegistry.h>
#include "appleEvnts.h"
#include "mdep.h"			// for filename
#include "pathname.h"
#include "d_mdep1.h"

/**************************************************************************************/

Boolean validAE = FALSE;
char DOSCRIPT[] = "doScript";
char OPENDOCS[] = "openDocs";
char theAE[80];

/**************************************************************************************/

pascal void
HandleAppleEvents (EventRecord *theEvent)
{
	AEProcessAppleEvent (theEvent);

} /* HandleAppleEvents */

/**************************************************************************************/

pascal OSErr
MyAEOpenDoc (AppleEvent *theAppleEvent, AppleEvent *reply, long handlerRefcon)
{

// A handler for the Open Documents event

//	extern char	*theAE;
	FSSpec		myFSS;
	AEDescList	docList;
	OSErr		myErr;
	long		index, itemsInList;
	Size		actualSize;
	AEKeyword	keywd;
	DescType	returnedType;
	WDPBRec		wdpb;
	short		wdRefNum, fRefNum;
	char		fullPathName[_MAX_PATH];
	CInfoPBRec	pb;
	
	validAE = TRUE;
	strcpy (theAE, OPENDOCS);

	// get the direct parameter--a descriptor list--and put
	// it into docList
	myErr = AEGetParamDesc(theAppleEvent, keyDirectObject,
							  typeAEList, &docList);
	
/*
	// check for missing required parameters
	myErr = MyGotRequiredParams(theAppleEvent);
	if (myErr) {
		// an error occurred:  do the necessary error handling
		myErr = AEDisposeDesc(&docList);
		return	myErr;
	}
*/
	// count the number of descriptor records in the list
	myErr = AECountItems (&docList, &itemsInList);

	// now get each descriptor record from the list, coerce
	// the returned data to an FSSpec record, and open the
	// associated file
	for (index=1; index<=itemsInList; index++) {
		myErr = AEGetNthPtr(&docList, index, typeFSS, &keywd,
							&returnedType, (Ptr)&myFSS,
							sizeof(myFSS), &actualSize);

		//CheckError("AEGetNthPtr");
		
		// Get the full pathname
		PathNameFromDirID (myFSS.parID, myFSS.vRefNum, (StringPtr)fullPathName);
		
		// Convert to C strings
		PtoCstr( (unsigned char*)fullPathName);
		PtoCstr( (unsigned char*)myFSS.name);
	
		// Combine directory and filename to get a full path
		mdep_makepath (fullPathName, (char*)myFSS.name, filename, (int)_MAX_PATH);

	}

	myErr = AEDisposeDesc (&docList);

	return	noErr;

} /* MyAEOpenDoc */

/**************************************************************************************/

pascal OSErr
MyAEOpenApp (AppleEvent *theAppleEvent, AppleEvent *reply, long handlerRefcon)
{

// A handler for the OpenApplication event

	return noErr;

} // MyAEOpenApp

/**************************************************************************************/

pascal OSErr
MyAEQuitApp (AppleEvent *theAppleEvent, AppleEvent *reply, long handlerRefcon)
{
	mdep_bye();
	exit(0);

} // MyAEQuitApp

/**************************************************************************************/

pascal OSErr
MyAEDoScript (AppleEvent *theAppleEvent, AppleEvent *reply, long handlerRefcon)
{

// A handler for the "Do Script" event

//	extern char	*theScript, *theAE;
	AEDescList	docList;
	OSErr		myErr;
	long		index, itemsInList;
	Size		actualSize;
	AEKeyword	keywd;
	DescType	returnedType;
	char		theText[80], *theTxt;

	validAE = FALSE;
	strcpy (theAE, DOSCRIPT);

	// get the direct parameter--a descriptor list--and put
	// it into docList
	myErr = AEGetParamDesc(theAppleEvent, keyDirectObject,
							  typeAEList, &docList);
	if (myErr != noErr)
		goto bail;
	
	// count the number of descriptor records in the list
	myErr = AECountItems (&docList, &itemsInList);
	if (myErr != noErr)
		goto bail;

	// now get each descriptor record from the list, coerce
	// the returned data to typeIntlText.
	for (index=1; index<=itemsInList; index++) {
		myErr = AEGetNthPtr(&docList, index, typeIntlText, &keywd,
							&returnedType, (Ptr)&theText,
							sizeof(theText), &actualSize);
		if (myErr != noErr) {
			goto bail;
		}
		
		theText[actualSize] = '\0';				// terminate the string
		theTxt = ((char *)(&theText[0])) + 4;	// point past the type characters
		strcpy( theScript, theTxt );	// Copy the script into the global
	}

	validAE = TRUE;

bail:
	return myErr;

} // MyAEDoScript

/**************************************************************************************/

void
InstallAEs()
{
	OSErr	myErr;

	// Install the "OpenApplication" Apple event
	myErr = AEInstallEventHandler (kCoreEventClass, kAEOpenApplication,
								   NewAEEventHandlerProc (MyAEOpenApp), 0L, false);

	// Install the "OpenDocuments" Apple event
	myErr = AEInstallEventHandler (kCoreEventClass, kAEOpenDocuments,
								   NewAEEventHandlerProc (MyAEOpenDoc), 0L, false);
								   
	// Install the "QuitApplication" Apple event
	myErr = AEInstallEventHandler (kCoreEventClass, kAEQuitApplication,
								   NewAEEventHandlerProc (MyAEQuitApp), 0L, false);


	// Install the "Do Script" Apple event
	myErr = AEInstallEventHandler (kAEMiscStandards, kAEDoScript,
								   NewAEEventHandlerProc (MyAEDoScript), 0L, false);

}