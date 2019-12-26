// midi.c

#include <stdio.h>
#include "d_midi.h"		// for mdep midi prototypes
//#include "mdep.h"
#include "resources.h"
#include <QuickTimeMusic.h>
#include <Gestalt.h>
#include "environ.h"
#include "stats.h"
#include "midi.h"
//#include "Wide.h"

GMIDI gMidi;

/*********************************************************************************************/

void eprint(char *fmt,...);
void mdep_popup(char *s);

/*********************************************************************************************/
// local prototypes

pascal	ComponentResult myReadHook	(MusicMIDIPacket *myPacket, long myRefCon);
#if MIDI_IN_STATS
void	ComputeLatency				( wide ticks);
#endif

/*********************************************************************************************/

#if MIDI_IN_STATS
void
ComputeLatency ( wide ticks)
{
	(void) WideSubtract (&ticks, &(gMidi.ticks));	// arg1 = arg1 - arg2
	UpdateWideStats (&inLatency, ticks);

} // ComputeLatency
#endif

/*********************************************************************************************/

int
mdep_statmidi (void)
{
	return ( (gMidi.in - gMidi.out) > 0 ? FALSE : TRUE);
}

/*********************************************************************************************/

int
mdep_getnmidi (char *buff, int buffsize)
{
	short i, size, totalSize;
	
	if ( (gMidi.in == gMidi.out) && (gMidi.overlap == FALSE) ) {
		// no input
		return 0;
	}
	
	if (gMidi.error != noErr) {
		gMidi.error = noErr;
		eprint("MIDI Receive overrun!\n");
	}
	
	totalSize = 0;
	
	for(;;) {

		size = gMidi.midiMsg[gMidi.out].length;
		
		if ( (totalSize + size) > buffsize ) {
			if (totalSize == 0) {
				eprint("Too many bytes in input packet: %d\n", size);
			}
			break;
		}
		
		// Copy the data from the packet into keynote's buffer
		for (i = totalSize; i < (totalSize + size); i++) {
			buff[i] = gMidi.midiMsg[gMidi.out].data[i - totalSize];
		}
		
		totalSize += size;
	
		// point to the next slot
		gMidi.out++;
		if (gMidi.out >= MAX_PACKETS) {
			// wrap around
			gMidi.out = 0;
		}
		
		if (gMidi.in == gMidi.out) {
			break;
		}

	} // for
	
	gMidi.overlap = FALSE;

	return totalSize;

} // mdep_getnmidi

/*********************************************************************************************/

void
mdep_putnmidi(int n, char *cp)
{

#if PROFILE
	extern Boolean profilerCleared;
#endif
	MusicMIDIPacket	p;
	short			i, theCh;
	ComponentResult	cerr;
	long			iNum, value;


	if (n > 249) {
		eprint("MIDI message = %d too large!\n", n);
		return;
	}

	// Copy the MIDI packet
	for (i = 0; i < n; i++) {
		p.data[i] = *cp++;
	}

/*****************************************************************
// I couldn't get this to work with the internal synth.
// The documentation is vague, but it may only work with the
// so-called "MIDI synthesizer component", which is dedicated to a single
// channel.
	
	p.length = (unsigned short) n;

	theCh = p.data[0] & 0xfL;	// the MIDI channel (0-based)
	
	cerr = NASendMIDI (gMidi.na, gMidi.nc[theCh], &p);
	
	return;

*****************************************************************/
	
	if (theEnv.useQT) {
		theCh = p.data[0] & 0xfL;	// the MIDI channel (0-based)

		switch (p.data[0] & 0xf0) {
		case 0x80:	// note off
			cerr = NAPlayNote(gMidi.na, gMidi.nc[theCh], (long)(p.data[1]), 0L);
			break;
		case 0x90:	// note on
#if PROFILE
			if (! profilerCleared) {
			//	ProfilerClear();
				profilerCleared = TRUE;
			}
			ProfilerSetStatus (TRUE);			// turn on the profiler with the first note

#endif
			cerr = NAPlayNote(gMidi.na, gMidi.nc[theCh], (long)(p.data[1]), (long)(p.data[2]));
			break;
		case 0xa0:	// key pressure
			eprint("mdep_putnmidi: key pressure not handled yet!\n");
			break;
		case 0xb0:	// parameter

/*
			kControllerModulationWheel	= 1,
			kControllerBreath			= 2,
			kControllerFoot				= 4,
			kControllerPortamentoTime	= 5,
			kControllerVolume			= 7,
			kControllerBalance			= 8,
			kControllerPan				= 10,
			kControllerExpression		= 11,

			kControllerPitchBend		= 32,
			kControllerAfterTouch		= 33,

			kControllerSustain			= 64,
			kControllerPortamento		= 65,
			kControllerSostenuto		= 66,
			kControllerSoftPedal		= 67,
			kControllerReverb			= 91,
			kControllerTremolo			= 92,
			kControllerChorus			= 93,
			kControllerCeleste			= 94,
			kControllerPhaser			= 95
*/

			value = ((unsigned long)(p.data[2])) << 8;
			NASetController (gMidi.na, gMidi.nc[theCh], (long)(p.data[1]), value);
			break;

		case 0xc0:	// program
			cerr = NASetInstrumentNumber(gMidi.na, gMidi.nc[theCh], (long)(p.data[1] + 1));
			break;

		case 0xd0:	// channel pressure
		//	eprint("channel %d pressure = %d\n", theCh, p.data[1]);
		//	NASetNoteChannelVolume (na, nc[theCh], Long2Fix( (long)(p.data[1]) ) );
			break;

		case 0xe0:	// pitch wheel
		//	value = (((unsigned long)(p.data[2])) << 8) + p.data[1];
		//	eprint("pitch bend: value = %d\n", bend);
		//	NASetController(gMidi.na, gMidi.nc[theCh], kControllerPitchBend, value);
			break;

		case 0xf0:	// system message - ignore
			break;

		default:
			eprint("unknown message: 0 = %d, 1 = %d, 2 = %d\n", p.data[0], p.data[1], p.data[2]);
		}
	}


} // mdep_putnmidi

/*********************************************************************************************/

void
mdep_endmidi(void)
{

	short			i;
	ComponentResult	cerr;

	if (theEnv.hasQT2) {
		if (gMidi.na != NULL) {
			cerr = NALoseDefaultMIDIInput(gMidi.na);
			CloseComponent(gMidi.na);		/* disposes notechannels too */
		}
	}
	
} // mdep_endmidi

/*********************************************************************************************/

pascal ComponentResult
myReadHook (MusicMIDIPacket *myPacket, long myRefCon)
{
	short			theCh, i, size, buffered;
	ComponentResult	ret_val;
	OSErr			postErr;
	GMIDI			*ref;
	EvQEl			*eventPtr;


	ret_val = noErr;

	ref = (GMIDI *) myRefCon;
	
	theCh = myPacket->data[0] & 0x0F;

	if (myPacket->reserved == kMusicPacketPortLost) {			// port gone? make channel quiet
		NASetNoteChannelVolume(ref->na, ref->nc[theCh], 0);
	}
	else if (myPacket->reserved == kMusicPacketPortFound) {		// port back? raise volume
		NASetNoteChannelVolume(ref->na, ref->nc[theCh], 0x00010000);
	}
	else {
		// ignore real-time messages
		if (myPacket->data[0] < 0xf8) {
		
			if( (ref->in == ref->out) && ref->overlap ) {
				// MIDI packet receive buffer overrun
				ref->error = -1;
				return ret_val;
			}

			size = myPacket->length;

			// Make a copy of the message
			ref->midiMsg[ref->in].length = size;
			for (i = 0; i < size; i++) {
				ref->midiMsg[ref->in].data[i] = myPacket->data[i];
			}
			
			ref->in++;	// point to the next slot

			if (ref->in >= MAX_PACKETS) {
				// end of buffer - wrap around
				ref->in = 0;
			}

			if (ref->in == ref->out) {
				// MIDI packet receive buffer will overrun on next packet
				ref->overlap = TRUE;
			}

			// Post a special mouseDown event so our event loop
			// will get the MIDI event quickly.
			postErr = PPostEvent (mouseDown, 0L, &eventPtr);
			eventPtr->evtQWhere.h = -1;
			
#if MIDI_IN_STATS
			if (ref->in < ref->out) {
				buffered = (ref->in + MAX_PACKETS);
			}
			else {
				buffered = ref->in - ref->out;
			}
			UpdateStats (&inBuffer, buffered);

			// save the current time in microticks
			Microseconds ( (UnsignedWide *) &(ref->ticks) );
#endif
			
		}
	}

	return ret_val;

} // myReadHook

/*********************************************************************************************/

int
mdep_initmidi(void)
{
	ComponentResult			cerr, numComps;
	long					iNum;
	OSType					synthType;
	SynthesizerConnections	synthConn;
	MusicComponent			mc;
	Str31					instrName = "\pStandard Kit", synthName;
	short					i;
	
	void DoSynthItem (short item);
	extern MenuHandle	synthMenu;
	
	gMidi.error = noErr;
	gMidi.overlap = FALSE;
	gMidi.in = gMidi.out = 0;

	if (theEnv.hasQT2) {
	
		// Open the note allocator component
		gMidi.na = OpenDefaultComponent (kNoteAllocatorComponentType, 0);

		if (gMidi.na != NULL) {
	
			gMidi.nr.info.flags = 0;
			gMidi.nr.info.reserved = 0;
			gMidi.nr.info.polyphony = 2;
			gMidi.nr.info.typicalPolyphony = 0x00010000;
			NAStuffToneDescription(gMidi.na, 1L, &gMidi.nr.tone);	// 1L is for piano
			for (i = 0; i < DRUMCHANNEL; i++) {
				// Request a new note channel
				cerr = NANewNoteChannel(gMidi.na, &gMidi.nr, &gMidi.nc[i]);
				if (cerr != noErr) {
					eprint("NANewNoteChannel: Failed to allocate Note Channel: 0x%lx", cerr);
					return 1;
				}
			}
			
			// MIDI Channel 10 is for percussion
			gMidi.nr.tone.instrumentNumber = kFirstDrumkit + 1;		// Standard Drum Kit
			gMidi.nr.tone.gmNumber = kFirstDrumkit + 1;
			for (i = 0; i < 31; i++) {
				gMidi.nr.tone.instrumentName[i] = instrName[i];
			}
			cerr = NANewNoteChannel(gMidi.na, &gMidi.nr, &gMidi.nc[DRUMCHANNEL]);
			if ( (cerr == noErr) && (gMidi.nc[DRUMCHANNEL]) ) {
				cerr = NAFindNoteChannelTone(gMidi.na, gMidi.nc[DRUMCHANNEL], &gMidi.nr.tone, &iNum);
			}
			if (cerr == noErr) {
				cerr = NASetInstrumentNumber(gMidi.na, gMidi.nc[DRUMCHANNEL], iNum);
			}

			NAStuffToneDescription(gMidi.na, 1L, &gMidi.nr.tone);	// 1L is for piano
			for (i = DRUMCHANNEL+1; i < NUMCHANNELS; i++) {
				// Request a new note channel
				gMidi.nc[i] = 0;
				cerr = NANewNoteChannel(gMidi.na, &gMidi.nr, &gMidi.nc[i]);
			}
		
			// Install a handler for incoming MIDI data
			cerr = NAUseDefaultMIDIInput(gMidi.na,								// note allocator comp.
										 NewMusicMIDIReadHookProc(myReadHook),	// read hook UPP
										 (long) &gMidi,							// reference constant
										 0);									// flags
			if (cerr != noErr) {
				switch (cerr) {
				case cantReceiveFromSynthesizerErr:
					eprint("NAUseDefaultMIDIInput: Can\'t Receive From Synthesizer!\n");
					break;
				case cantSendToSynthesizerErr:
					eprint("NAUseDefaultMIDIInput: Can\'t Send to Synthesizer!\n");
					break;
				case synthesizerErr:
					eprint("NAUseDefaultMIDIInput: Synthesizer Error!\n");
					break;
				case synthesizerNotRespondingErr:
					eprint("NAUseDefaultMIDIInput: Synthesizer Not Responding!\n");
					break;
				default:
					eprint("NAUseDefaultMIDIInput: 0x%lx\n", cerr);
				}
			}
		

		} // if gMidi.na != NULL
		else {
			eprint("OpenDefaultComponent: Failed to open Note Allocator!");
			return 1;
		}

		// select internal syth. and bail
	//	DoSynthItem (internalItem);
	//	DisableItem (synthMenu, externalItem);
		return 0;

	} // if (theEnv.hasQT2)
	
	else {
		// failed to init MIDI
		return 1;
	}

} // mdep_initmidi

/*********************************************************************************************/

void
SuspendMidi()
{
	ComponentResult		cerr;
	short				i;

	for (i = 0; i < NUMCHANNELS; i++) {
		// Make channel available to be stolen
		cerr = NAUnrollNoteChannel (gMidi.na, gMidi.nc[i]);
	}

} // SuspendMidi

/*********************************************************************************************/

void
ResumeMidi()
{
	ComponentResult		cerr;
	short				i;

	for (i = 0; i < NUMCHANNELS; i++) {
		// Make channel available to be stolen
		cerr = NAPrerollNoteChannel (gMidi.na, gMidi.nc[i]);
	}

} // ResumeMidi

/*********************************************************************************************/

