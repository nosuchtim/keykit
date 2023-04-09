// help.c

#include "HoWLib.h"
#include "help.h"
#include "key.h"
#include <Balloons.h>

/*********************************************************************************************/

static	Boolean	helpServerPresent;

/* How many System-defined items are there in the Help menu? */
short	systemHelpItemCount;


HELPSTRUCT helpData [] = {
	{{"intro"},	{1}},
	{{"wbang"},	{2}},
	{{"wblocks"},	{3}},
	{{"wbounce"},	{4}},
	{{"wchord"},	{5}},
	{{"wcomment"},	{6}},
	{{"wconsole"},	{7}},
	{{"wcontrol"},	{8}},
	{{"wecho"},	{9}},
	{{"wgroup"},	{10}},
	{{"wkboom"},	{11}},
	{{"wmark"},	{12}},
	{{"wmatrix"},	{13}},
	{{"wparam"},	{14}},
	{{"wprogch"},	{15}},
	{{"wriff"},	{16}},
	{{"wriffraf"},	{17}},
	{{"wtempo"},	{18}},
	{{"wvol"},	{19}},
	{{""},		{0}}
};

/*********************************************************************************************/

void
InitHelp()
{
	/* Register with Help on Wheels for help service using help file alias resource */
	/* in preferences or application file.  The alias resource comes from the */
	/* “HoWSample Help alias” Finder alias file, so it contains relative alias information. */
	/* This information is relative to the Finder alias file itself, which was created in */
	/* the same directory as the help file.  HoWFindHelpFile expects the alias resource */
	/* to be relative to the application file. */
	/* So, as long as the help file and the application file are in the same directory, */
	/* this information can be used to resolve the alias with a fast alias search. */
	/* If the fast search fails, HoWFindHelpFile will do an exhaustive search of all */
	/* volumes, but if the exhaustive search fails once, the preferences file's alias */
	/* resource is marked to prevent repeating the failed search. */
	/* Once successfully resolved, the non-relative information in the alias record */
	/* (volume, file ID) will keep track of the help file. */

	extern FSSpec homeSpec;

	FSSpec		helpFileFSSpec;
	Str63		helpFile = "\pKeyKit.help";
	OSErr		osErr;
//	char		string[ 256 ];
	short		i;
//	short		applicationFileRefNum;
	MenuHandle	helpMenuHandle;
	
//	applicationFileRefNum = CurResFile( );
	osErr = noErr;
/*
	osErr = HoWFindHelpFile( applicationFileRefNum,		// preferencesFileRefNum, when avail.
							 applicationFileRefNum,
							 rHelpFileAlias,
							 &helpFileFSSpec );
*/
	for (i = 0; i < 31; i++) {
		homeSpec.name[i] = helpFile[i];
	}

	helpServerPresent = false;
	if( osErr == noErr )
	{	/* We don't start the server right away.  The server will start when the user */
		/* asks for help.  If we did ask to start the server right away, HoWRegister */
		/* would return noServerApplErr if the help server application cannot be found. */
		/* noServerApplErr is not fatal; the client is registered anyway, and a non-casual */
		/* HoWDisplay call will cause the client engine to offer the user a TeachText */
		/* version of the help file.  The same thing could happen to us when we call */
		/* HoWDisplay, but we can't tell that it's happening.  The 'Lang' resource gives */
		/* the language code for which this application has been localized.  By preference, */
		/* if it can find support in the help file, the help server will use the current */
		/* script's current language, or its own language, before using this default language. */
		LangCode	**clientLanguageHandle = (LangCode **) GetIndResource( 'Lang', 1 );
		LangCode	clientLanguage = ( clientLanguageHandle != nil ) ?
					**clientLanguageHandle : langEnglish;
		osErr = HoWRegister( &homeSpec,
							 helpFileVersion,
							 clientLanguage,
							 false,							// start server?
							 NewHoWHandlerProc(NULL) );		// HelpEventHandler

		switch( osErr )
		{
		case noErr:
			helpServerPresent = true;
			break;
		case wrongVersionErr:
			eprint("Help file wrong version\n");
			break;
		default:
			eprint("HoW registration failed\n");
			break;
		}
//		UnloadSeg( (Ptr) HoWRegister );
	}
	/* If osErr != noErr, we don't complain.  For example, a return code of fnfErr from */
	/* HoWFindHelpFile may just mean that the user has trashed the help file. */

	/* Add the "HoWSample Help" item and subsidiary items to the Help menu. */
	osErr = HMGetHelpMenuHandle( &helpMenuHandle );
	if( osErr == noErr && helpMenuHandle != nil )
	{
		systemHelpItemCount = CountMItems( helpMenuHandle );
		AppendMenu( helpMenuHandle, (ConstStr255Param) "\pKeyKit Help" );
//		AppendMenu( helpMenuHandle, (ConstStr255Param) "\p(-" );
	}
	
} // InitHelp

/*********************************************************************************************/

void
DisplayHelp( short tag, Boolean casual )
{
	OSErr	osErr;
	
	osErr = HoWDisplay( tag, casual );
	
	if( !casual )
	{
		switch( osErr )
		{
		case noErr:
		case userCanceledErr:
			break;
		case clientNotRegisteredErr:
			eprint("Help not available\n");
			break;
		default:
			eprint("Can\'t display help! HoWDisplay returned %d\n", osErr);
			break;
		}
	}
	
//	UnloadSeg( (Ptr) HoWDisplay );
	
} // DisplayHelp

/*********************************************************************************************/

void
EndHelp()
{
	/* Deregister with Help on Wheels. */
	(void) HoWDeregister( );

} // EndHelp
