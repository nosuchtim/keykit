// help.h

#if GENERATINGPOWERPC
#define HELP	1
#else
#define HELP	0
#endif

// alias to help file
#define	rHelpFileAlias	128

// help file version
#define	helpFileVersion	0x0130

// Help menu
#define	iHoWHelp	1

typedef struct {
	char	*keyword;
	short	tag;
} HELPSTRUCT;

extern	HELPSTRUCT helpData[];
/* How many System-defined items are there in the Help menu? */
extern	short	systemHelpItemCount;

// prototypes
void	InitHelp		( void );
void	ErrorMessage	( short errorID, long code );
void	DisplayHelp		( short tag, Boolean casual );
void	EndHelp			( void );
