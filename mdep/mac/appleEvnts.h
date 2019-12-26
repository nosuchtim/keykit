// appleEvents.h

void		InstallAEs (void);
pascal void	HandleAppleEvents (EventRecord *theEvent);
pascal		OSErr MyAEOpenDoc (AppleEvent *theAppleEvent, AppleEvent *reply, long handlerRefcon);
pascal		OSErr MyAEOpenApp (AppleEvent *theAppleEvent, AppleEvent *reply, long handlerRefcon);
pascal		OSErr MyAEQuitApp (AppleEvent *theAppleEvent, AppleEvent *reply, long handlerRefcon);
pascal		OSErr MyAEDoScript (AppleEvent *theAppleEvent, AppleEvent *reply, long handlerRefcon);

extern Boolean validAE;
extern char theAE[], DOSCRIPT[], OPENDOCS[];
