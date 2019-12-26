/* THIS FILE WAS CREATED BY THE Install SCRIPT. */
#include "config.h"
#include "sys/types.h"
#include "sys/midi.h"

struct midi_ctlr midi_ctlr[MIDI_UNITS];
int midi_nctlr = MIDI_UNITS;
int irq_to_ctlr[NUMIRQ];	/* to be filled in by midi_init */

int ctlr_to_irq[] = {
MIDI_0_VECT
};
int ctlr_to_data_port[] = {
MIDI_0_SIOA
};
int ctlr_to_status_port[] = {
MIDI_0_SIOA + 1
};
