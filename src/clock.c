#include <windows.h>
#include <mmsystem.h>

static long tm0;

long
mdep_milliclock(void)
{
	return ((long)timeGetTime())-tm0;
}

void
mdep_resetclock(void)
{
	tm0 = (long)timeGetTime();
}
