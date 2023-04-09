// environ.h

typedef struct environ {
	Boolean	hasQT2;
	Boolean	useQT;
	Boolean MIDIsignedIn;
	Boolean hasCFM;
} ENVIRON;

extern ENVIRON		theEnv;						// A structure containing the machines environment

// prototypes
OSErr	GetMyEnvironment(void);
