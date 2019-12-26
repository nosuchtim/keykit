#include "clock.h"
#include "environ.h"

long tm0;

Handle	sysHandle;
TMInfo	*myTMInfo;

/*********************************************************************************************/

long
mdep_milliclock(void)
{
	return tm0;
}

/*********************************************************************************************/

void
mdep_resetclock(void)
{
	tm0 = 0L;
}

/*********************************************************************************************/

// If we're compiling for a 68k machine,
// The task pointer is being passed in A1.

// This function will retrieve it for us.
//TMInfo *GetTMInfo()
//	ONEWORDINLINE(0x2049);	// MOVEA.L   A1,A0

#define CHECKTIMETOSET	10L		// Check MIDI input and output
								//   every N times myClockTask is called.

//#define GETTMINFO GetTMInfo()
#if !GENERATINGPOWERPC
#pragma parameter myClockTask(__A1)
#endif
pascal void
myClockTask ( TMInfo *recPtr )
//myClockTask ()
{
void chkinput (void);
void chkoutput (void);

//static long timeToCheck = CHECKTIMETOSET;

OSErr			postErr;
EvQEl			*eventPtr;
extern int 		inchkoutput;

//	TMInfo *recPtr;

//	long	oldA5;
	
//	recPtr = GETTMINFO;
	
//	oldA5 = SetA5 ( recPtr->tmRefCon );	// Get our application's A5 world.
	(*(long *)(recPtr->tmRefCon)) += MILLI_CLOCK;	// increment the 1 millisecond clock variable.
	
//	tm0 += 1;							// increment the 1 millisecond clock variable.

//	if (recPtr->tmRefCon % 6 == 0) {
//		chkinput();
//		if (! inchkoutput)
//			chkoutput();
		// Post a special mouseDown event so our event loop
		// will get an event before the sleep timer expires.
//		postErr = PPostEvent (mouseDown, 0L, &eventPtr);
//		eventPtr->evtQWhere.h = -2;
//	}

	// Reactivate the timed task
	PrimeTime ( (QElemPtr)recPtr, MILLI_CLOCK);
		
//	oldA5 = SetA5 (oldA5);				// restore caller's A5 world.

} // myClockTask

/*********************************************************************************************/

void
installClockTask ()
{
	long	myDelay;
	OSErr	err;
	
//	err = LockMemory (&tm0, sizeof (long));

	// allocate storage for the TMTask structure in the system heap
	// in case keynote terminates without getting a chance to call removeClock().
	sysHandle = NewHandleSys ( sizeof (TMInfo) );
	
	// Lock the handle so it doesn't move after we dereference it
	HLock (sysHandle);
	
//	err = LockMemory (*sysHandle, sizeof (TMInfo));

	// get a pointer to the storage
	myTMInfo = (TMInfo *) *sysHandle;

	myDelay = MILLI_CLOCK;	// 1 millisecond

	myTMInfo->atmTask.tmAddr = NewTimerProc (myClockTask);	// universal ptr to my task
	myTMInfo->atmTask.qLink = NULL;
	myTMInfo->atmTask.qType = 0;
	myTMInfo->atmTask.tmCount = 0L;
	myTMInfo->atmTask.tmWakeUp = 0;
	myTMInfo->atmTask.tmReserved = 0;
	myTMInfo->tmRefCon = (long) &tm0;				// Store address of the clock variable.
//	myTMInfo->tmRefCon = (long) SetCurrentA5();		// Store address of my A5 world so
													// I can access my application's globals.

	InsXTime ( (QElemPtr)myTMInfo );				// Install my task

	PrimeTime ( (QElemPtr)myTMInfo, myDelay );		// Activate it

} // installClockTask

/*********************************************************************************************/

void
removeClock()
{
	RmvTime ( (QElemPtr)myTMInfo );
	HUnlock (sysHandle);
	DisposeHandle (sysHandle);
}