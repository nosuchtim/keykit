#include <sys\types.h>
#include <sys\timeb.h>

static struct _timeb Tb0;

long
mdep_milliclock()
{
	struct _timeb tb;

	_ftime(&tb);
	return (long)((tb.time-Tb0.time)*1000 + (tb.millitm-Tb0.millitm));
}

void
mdep_resetclock()
{
	_ftime(&Tb0);
}
