#include <windows.h>
#include <mmsystem.h>

static long tm0;
long Firsttime = 0;

long
mdep_milliclock(void)
{
	return ((long)timeGetTime())-tm0;
}

void
mdep_resetclock(void)
{
	Firsttime = tm0 = (long)timeGetTime();
}
