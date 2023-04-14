// resources.h

#define SIGNATURE	'KeyN'	// Application signature

#define POPUPDIALOG 1000	// DLOG ID for the popup dialog resource.
#define POPUPTEXTITEM 2		// Item number for popup dialog text.

#define appIconID	128		// File Reference (FREF) resource IDs
#define fileIconID	129

#define appleMenuID	128		// MENU resource IDs

#define fileMenuID	129
enum {	// file menu items
	quitItem = 1
};

#define editMenuID	130

#define midiMenuID	131
enum {
	QuickTimeItem = 1,
	OMSItem,
	QTSettingsItem = 3
};

/*
#define synthMenuID	131
enum {	// Synthesizer menu items
	externalItem = 1,
	internalItem
};
*/
