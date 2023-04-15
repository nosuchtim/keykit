// clock.h

#include <Timer.h>

#define TIMEMGR 1			// use Time Manager?

#define MILLI_CLOCK	1L		// 1 millisecond clock

long	mdep_milliclock (void);
void	mdep_resetclock (void);

#if TIMEMGR

typedef struct {
	QElemPtr					qLink;
	short						qType;
	TimerUPP					tmAddr;
	long						tmCount;
} OldTMTask;

typedef struct {
	TMTask	atmTask;
	long	tmRefCon;
} TMInfo;

void		installClockTask	(void);
void pascal	myClockTask			(TMInfo *recPtr);
void		removeClock			(void);
#endif