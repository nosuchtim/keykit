/* THIS FILE WAS CREATED BY THE Install SCRIPT. */
#include "config.h"
#include "sys/types.h"
#include "sys/stream.h"
#include "sys/smid.h"

int Smid_nctlr = SMID_UNITS;
struct smid_stream Smid_stream[SMID_STREAMS];
struct smid_stream *Smid_end = &Smid_stream[SMID_STREAMS];
struct smid_ctlr Smid_ctlr[SMID_UNITS];
int Irq_to_ctlr[NUMIRQ];	/* to be filled in by smid_init */

int Ctlr_to_irq[] = {
SMID_0_VECT
};
int Ctlr_to_data_port[] = {
SMID_0_SIOA
};
int Ctlr_to_status_port[] = {
SMID_0_SIOA + 1
};
