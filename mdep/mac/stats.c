// stats.c

#include <stdarg.h>
#include "stats.h"

#if MIDI_IN_STATS

STATS		inBuffer	= {0, 0, 0x7fff, 0, 0.0};
WIDESTATS	inLatency	= {0L, {0, 0}, {gxPositiveInfinity, gxPositiveInfinity}, {0, 0}, 0L};

/*********************************************************************************************/

void
UpdateStats(STATS *stats, short newValue)
{
	(stats->cnt)++;

	if (newValue < stats->min) {
		stats->min = newValue;
	}
	if (newValue > stats->max) {
		stats->max = newValue;
	}
	
	stats->acc += newValue;
	
	stats->avg = stats->acc / stats->cnt;

} // UpdateStats

/*********************************************************************************************/

void
UpdateWideStats (WIDESTATS *stats, wide newValue)
{
	long	remainder;
	
	(stats->cnt)++;

	if ( WideCompare(&newValue, &stats->max) > 0 ) {
		stats->max = newValue;
	}
	if ( WideCompare(&newValue, &stats->min) < 0 ) {
		stats->min = newValue;
	}
	
	(void) WideAdd (&stats->acc, &newValue);						// sum = accumulated + newValue

	stats->avg = WideDivide (&stats->acc, stats->cnt, &remainder);	// avg = accumulated / count
	
} // UpdateStats

#endif