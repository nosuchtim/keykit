// stats.h

#define MIDI_IN_STATS 0

#if MIDI_IN_STATS

#include <Timer.h>
//#include "Wide.h"

typedef struct {
	short	cnt;
	long	acc;
	short	min;
	short	max;
	double	avg;
} STATS;

typedef struct {
	long	cnt;
	wide	acc;
	wide	min;
	wide	max;
	long	avg;
} WIDESTATS;

extern STATS		inBuffer;
extern WIDESTATS	inLatency;

void	UpdateStats		(STATS *stats, short newValue);
void	UpdateWideStats	(WIDESTATS *stats, wide newValue);

#endif

/*********************************************************************************************/

