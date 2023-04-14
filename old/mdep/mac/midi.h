// midi.h

#include <QuickTimeMusic.h>
//#include "OMS.h"

#define OMS 0

// Maximum number of buffered MIDI packets
#define MAX_PACKETS		20

#if OMS
#define InputPortID		'in  '
#define OutputPortID	'out '
#endif

#if ! OMS
#define NUMCHANNELS		16
#define DRUMCHANNEL		9		// MIDI Channel 10
#endif

typedef struct {
	//UInt8			packetCnt;				// No. of MIDI packets buffered.
	UInt8			in;
	UInt8			out;
	Boolean			overlap;
	OSErr			error;					// receive overrun
#if OMS
	OMSMIDIPacket	midiMsg[MAX_PACKETS];	// MIDI messages.
	short			mode;
	short			InputPortRefNum;
	short			OutputPortRefNum;
//	OMSNodeInfoList	nodes;
//	OMSIDList		nodes;
	OMSUniqueID		chosenInputID;
	short			inputNode;
	short			outputNode;
#endif
#if ! OMS
	MusicMIDIPacket	midiMsg[MAX_PACKETS];	// MIDI messages.
	NoteAllocator	na;						// Note Allocator component
	NoteRequest		nr;						// Note Request
	NoteChannel		nc[NUMCHANNELS];		// MIDI channels
#endif
#if MIDI_IN_STATS
	wide			ticks;
#endif
} GMIDI;

// prototypes for other than mdep functions
void	SuspendMidi					(void);
void	ResumeMidi					(void);
int		ChooseInputs				(void);
int		ChooseOutputs				(void);
int		OpenOrCloseConnection		(Boolean opening);
