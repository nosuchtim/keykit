/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#define OVERLAY7

#include "key.h"
#include "keymidi.h"

/*
 * midiparse(inbyte)
 *
 * This is a finite state machine that recognizes MIDI.
 *
 * The midiparse() function should be called repeatedly, passing it each midi
 * byte that is to be processed.  A value of -1 will reset the finite
 * state machine.
 *
 * As each MIDI statement is recognized, the 'midiaction' functions (in the
 * external structure 'Midi') are called.  If a single-byte MIDI message is
 * received, the function is called right away.  For multi-byte messages
 * the 'Currfunc' is set to the proper MIDI function, and State determines
 * what the state machine is currently looking for.  When the end of the
 * message is received, the 'Currfunc' is called, and the State goes back
 * to NEEDSTATUS.
 */

/* possible values for State */
#define NEEDSTATUS 0
#define NEEDONEBYTE 1
#define NEEDTWOBYTES 2
#define VARIABLELENGTH 3

#define MESSAGESIZE 256

int State = NEEDSTATUS;	/* The current state of the finite state machine. */
			/* It indicates what we're currently looking for. */

actfunc Currfunc = NULL;/* This is the 'midiaction' function for the */
				/* current MIDI message being processed. */

int Currchan = 0;	/* This is the current channel, ie. the channel # */
			/* on the latest 'channel message' status byte. */

Unchar *Currmessage = NULL;	/* Current message buffer */

int Messleng = 0;	/* Size of currently allocated message */

int Messindex = 0;	/* Index of next byte to go into */
			/* 'Currmessage'.  When Messindex */
			/* gets >= Messleng, the 'Currmessage' */
			/* is reallocated to a larger size. */

int Runnable = 0;	/* If non-zero, the current MIDI message */
			/* can use the "running status byte" feature. */

struct midiaction Midi = {
	NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL
};

void
midiparse(register int inbyte)
{
	int highbit;


	/* If necessary, allocate larger message buffer. */
	if ( Messindex >= Messleng )
		biggermess(&Currmessage,&Messleng);

	if ( inbyte == -1 ) {
		/* start off in running status mode for notes */
		Messindex = 0;
		Currmessage[Messindex++] = 0x90;
		chanmsg(0x90);
		return;
	}

	if ( (inbyte & 0x80) != 0 )
		highbit = 1;
	else
		highbit = 0;

	/* Check active sensing early, so it doesn't interrupt sysex. */
	if ( inbyte == 0xfe ) {
		if ( Midi.mi_active != NULL )
			(*(Midi.mi_active))(Currmessage,Messindex);
		return;
	}

	/*
	 * Variable length messages (ie. the 'system exclusive')
	 * can be terminated by the next status byte, not necessarily
	 * an EOX.  Actually, since EOX is a status byte, this
	 * code ALWAYS handles the end of a VARIABLELENGTH message.
	 */
	if ( State==VARIABLELENGTH && highbit )  {
		/* The message has ended; call Currfunc and reset. */
		if ( Currfunc!=NULL && Messindex>0 )
			(*Currfunc)(Currmessage,Messindex);
		Currfunc = NULL;
		State = NEEDSTATUS;
	}

	/*
	   Real time messages can occur ANYPLACE,
	   but do not interrupt running status.
	*/
	if ( (inbyte & 0xf8) == 0xf8 ) {
		realmess(inbyte);
		return;
	}

	/*
	 * Status bytes always start a new message.
	 */

	if ( highbit ) {
		Messindex = 0;
		Currmessage[Messindex++] = inbyte;
		if ( (inbyte & 0xf0) == 0xf0 ) {
			sysmess(inbyte);
			Runnable = 0;
		}
		else
			chanmsg(inbyte);
		return;
	}

	/*
	 * We've got a Data byte.
	 */

	Currmessage[Messindex++] = inbyte;

	switch ( State ) {
	case NEEDSTATUS:
		/*
		 * We shouldn't get here, since in NEEDSTATUS mode
		 * we're expecting a new status byte, NOT any
		 * data bytes.
	 	 */
		{ char msg[64];
		sprintf(msg,"Got a data byte (0x%02x), expecting a status byte!\n",inbyte);
		eprint(msg);
		}
		break;
	case NEEDTWOBYTES:
		/* wait for the second byte */
		if ( Messindex < 3 )
			return;
		/*FALLTHRU*/
	case NEEDONEBYTE:
		/* We've completed a 1 or 2 byte message. */
		if ( Currfunc != NULL )
			(*Currfunc)(Currmessage,Messindex);
		if ( Runnable ) {
			/* In Runnable mode, we reset the message */
			/* index, but keep the Currfunc and State the */
			/* same.  This provides the "running status */
			/* byte" feature. */
			Messindex = 1;
		}
		else {
			/* If not Runnable, reset to NEEDSTATUS mode */
			State = NEEDSTATUS;
			Currfunc = NULL;
		}
		break;
	case VARIABLELENGTH:
		/* nothing to do */
		break;
	}
	return;
}

/*
 * realmess(inbyte)
 *
 * Call the real-time function for the specified byte, immediately.
 * These can occur anywhere, so they don't change the State.
 */

void
realmess(int inbyte)
{
	register actfunc f = NULL;

	switch ( inbyte ) {
	case 0xf8:
		f = Midi.mi_timing;
		break;
	case 0xfa:
		f = Midi.mi_start;
		break;
	case 0xfb:
		f = Midi.mi_continue;
		break;
	case 0xfc:
		f = Midi.mi_stop;
		break;
	case 0xfe:
		/* do nothing, active sensing gets handled earlier */
		break;
	case 0xff:
		f = Midi.mi_reset;
		break;
	}
	if ( f != NULL ) {
		Unchar mess[1];
		mess[0] = inbyte;
		(*f)(mess,1);
	}
	return;
}

/*
 * chanmsg(inbyte)
 *
 * Interpret a Channel (voice or mode) Message status byte.
 */

void
chanmsg(int inbyte)
{
	Currchan = inbyte & 0xf;	/* channel # is lower 4 bits */
	Runnable = 1;			/* Channel messages can use running status */

	/* The high 4 bits, which determine the type of channel message. */

	switch ( inbyte & 0xf0 ) {
	case 0x80:
		Currfunc = Midi.mi_off;
		State = NEEDTWOBYTES;
		break;
	case 0x90:
		Currfunc = Midi.mi_on;
		State = NEEDTWOBYTES;
		break;
	case 0xa0:
		Currfunc = Midi.mi_pressure;
		State = NEEDTWOBYTES;
		break;
	case 0xb0:
		Currfunc = Midi.mi_controller;
		State = NEEDTWOBYTES;
		break;
	case 0xc0:
		Currfunc = Midi.mi_program;
		State = NEEDONEBYTE;
		break;
	case 0xd0:
		Currfunc = Midi.mi_chanpress;
		State = NEEDONEBYTE;
		break;
	case 0xe0:
		Currfunc = Midi.mi_pitchbend;
		State = NEEDTWOBYTES;
		break;
	}
	return;
}

/*
 * sysmess(inbyte)
 *
 * Initialize (and possibly call) the MIDI function for the specified byte.
 * Set the State that the state-machine should go into.  If the function
 * is not called immediately, Currfunc is set, so that when the state machine
 * gets to the end of the MIDI message, it can then call the function.
 * If the function IS called immediately, the finite state machine is reset
 * (Currfunc=NULL,State=NEEDSTATUS).
 */

void
sysmess(int inbyte)
{
	register actfunc f = NULL;

	switch ( inbyte ) {
	case 0xf0:
		Currfunc = Midi.mi_sysex;
		State = VARIABLELENGTH;
		break;
	case 0xf2:
		Currfunc = Midi.mi_position;
		State = NEEDTWOBYTES;
		break;
	case 0xf3:
		Currfunc = Midi.mi_song;
		State = NEEDONEBYTE;
		break;
	case 0xf6:
		f = Midi.mi_tune;
		Currfunc = NULL;
		State = NEEDSTATUS;
		break;
	case 0xf7:
		f = Midi.mi_eox;
		Currfunc = NULL;
		State = NEEDSTATUS;
		break;
	}
	if ( f != NULL )
		(*f)(Currmessage,Messindex);
	return;
}

/*
 * biggermess(amessage,aMessleng);
 *
 * Allocate a bigger message buffer.  The current message and its length
 * are passed by pointer, so that they can both be modified.
 */

void
biggermess(Unchar **amessage,int *aMessleng)
{
	*aMessleng += MESSAGESIZE;
	*amessage = krealloc(*amessage,*aMessleng,"biggermess");
}
