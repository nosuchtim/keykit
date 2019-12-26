/*______________________________________________________________________

	Help on Wheels
	
	Version 1.3

	an AWOL Software Production
	PO Box 24207
	300 Eagleson Road
	Kanata, Ontario, Canada K2M 2C3
 
	Internet: ab026@freenet.carleton.ca
	
	Copyright © 1994-6 Ross Brown.  All rights reserved.
	Portions written by John Norstad are Copyright © 1988, 1989, 1990
	Northwestern University.
_____________________________________________________________________*/


/*______________________________________________________________________

	HoWRez.English.r - Help on Wheels Resource Definitions (English).
	
	These resource definitions must be compiled into the client's help
	file, whether it be the application file itself or a separate file.
	Without these resources, the client's call to HoWRegister will fail.
	
	This resource definitions file uses a number of defined symbols
	which you can define using Rez's "-d" option:
	
	symbol			meaning												default value
	------			-------												-------------
	version	.	.	the version number	.	.	.	.	.	.	.	none (absent)
	versionString	the version as a character string	.	.	none (absent)
	languageCode	the language code	.	.	.	.	.	.	.	.	0 (langEnglish)
	HoWi	.	.	.	ID of first doc 'STR#' resource	.	.	.	256
	HoWt	.	.	.	ID of 'TCON' resource	.	.	.	.	.	.	256
	HoWg	.	.	.	ID of 'TAG ' resource	.	.	.	.	.	.	256
	HoWc	.	.	.	ID of 'CELL' resource	.	.	.	.	.	.	256
	HoWa	.	.	.	ID of 'ALRT', 'DITL', 'STR ' resources	.	256
	application	.	name of client application
							(quoted string)	.	.	.	.	.	.	.	none
	extension	.	name of client extension or control panel
							(quoted string)	.	.	.	.	.	.	.	none
	
	The "version" symbol is only for help files which are separate from
	the application file.  If you define a value for the "version" symbol,
	the help file will contain a 'vers'(1) resource containing that
	version number (in BCD).  Also define the "versionString" symbol if
	you want an equivalent character version to appear in Finder's Get Info
	box for the help file.  If you do not define a value for the "version"
	symbol, no 'vers' resource will be added, and client version checking
	will not occur.
	
	The "languageCode" symbol is most important, because its value becomes
	the ID of the master 'HoW!' resource which points to the others.
	When loading help information, Help on Wheels looks for a master
	resource whose ID matches the current system's current language code,
	or if that fails, the following, in turn:  the language code of the
	server's local version; the default language code indicated by the
	client at registration; and finally, langEnglish (0).
	
	The values you define for the "HoWi", "HoWt", "HoWg", and "HoWc"
	symbols must match the values passed to the "cvrt" tool using
	the options "-i", "-t", "-g", and "-c" respectively.  You must ensure
	that the range of 'STR#' resource IDs beginning at "HoWi" does not
	overlap with any 'STR#' resources you define in your application,
	and likewise that your application has no 'ALRT', 'DITL', or 'STR '
	resources whose ID matches "HoWa".
	
	The "application" symbol is needed only for help files which are
	separate from the application file.  It helps provide an informative
	alert message to users who try to open or print the help file in the
	absence of the help server.  To supply a quoted string value to Rez,
	you must escape the quote characters, thus:  -d application=∂"App∂"
	
	Define the "extension" symbol instead of "application" if your help
	file is a control panel or extension.  Note that the alert message
	generated assumes that your extension detects the Help and Command-?
	keys at startup.
	
	If the help file supports multiple languages, you must also compile
	in the equivalent resource definitions file for each other language
	(e.g., HoWRez.French.r), using different values for all of the "HoW…"
	defined symbols to avoid collisions.  If your help file is a separate
	file, define the "version", "versionString", "application", and
	"extension" symbols only when compiling for the principal language.
	
	See HoWSample's help file for complete information on the use of
	this interface.
_____________________________________________________________________*/


#define SystemSevenOrLater 1
#include "SysTypes.r"
#include "Types.r"

#ifdef version
#ifndef versionString
#define versionString ""
#endif
resource 'vers' (1, purgeable) {
	(version & 0xFF00) >> 8,
	version & 0xFF,
	0,
	0,
	0,
	versionString,
	versionString
};
#endif

#ifndef languageCode
#define languageCode 0	/* default language code = langEnglish (0) */
#endif

#ifndef HoWi
#define HoWi 256
#endif

#ifndef HoWt
#define HoWt 256
#endif

#ifndef HoWg
#define HoWg 256
#endif

#ifndef HoWc
#define HoWc 256
#endif

#ifndef HoWa
#define HoWa 256
#endif

type 'HoW!' {
	integer;					/* first doc 'STR#' resource ID */
	integer;					/* 'TCON' resource ID */
	integer;					/* 'TAG ' resource ID */
	integer;					/* 'CELL' resource ID */
	integer;					/* 'ALRT'/'DITL'/'STR ' resource ID */
};

resource 'HoW!' (languageCode) {
	HoWi,						/* first doc 'STR#' resource ID */
	HoWt,						/* 'TCON' resource ID */
	HoWg,						/* 'TAG ' resource ID */
	HoWc,						/* 'CELL' resource ID */
	HoWa,						/* 'ALRT'/'DITL'/'STR ' resource ID */
};

#ifndef extension
resource 'ALRT' (HoWa, "(HoW) Save Help Text", purgeable) {
	{0, 0, 130, 368},
	HoWa,
	{	/* array: 4 elements */
		/* [1] */
		OK, visible, silent,
		/* [2] */
		OK, visible, silent,
		/* [3] */
		OK, visible, silent,
		/* [4] */
		OK, visible, silent
	},
	alertPositionMainScreen
};
#endif

#ifndef extension
resource 'DITL' (HoWa, "(HoW) Save Help Text", purgeable) {
	{	/* array DITLarray: 3 elements */
		/* [1] */
		{100, 299, 120, 358},
		Button {
			enabled,
			"OK"
		},
		/* [2] */
		{100, 227, 120, 286},
		Button {
			enabled,
			"Cancel"
		},
		/* [3] */
		{7, 74, 87, 358},
		StaticText {
			disabled,
			"Help could not be displayed, because "
			"the help server application “Help on Wheels” "
			"could not be found.  "
			"Do you want to save a readable copy "
			"of the documentation as a TeachText document?"
		}
	}
};
#endif

#ifndef extension
resource 'STR ' (HoWa, "(HoW) Save Help Text", purgeable) {
	"Save help text in:"
};
#endif

#if defined(application) || defined(extension)
resource 'STR '(-16397, purgeable) {
	"This document could not be opened, "
	"because the help server application "
	"“Help on Wheels” could not be found.  "
	"To get a readable copy of the documentation, "
#ifdef application
	"ask for help while using “" application "”."
#else
	"press Help or Command-? while “" extension "” is loading at startup."
#endif
};
#else
resource 'STR '(-16396, purgeable) {
	"Help on Wheels"
};
#endif
