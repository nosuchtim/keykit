#include <sys/time.h>

long Initsecs = 0;
long Initmicro = 0;

/* resetclock - Reset the millisecond clock (ie. the values returned by */
/*              milliclock()) to 0.  */
void
resetclock()
{
	struct timeval t;
	struct timezone tz;

	gettimeofday(&t,&tz);
	Initsecs = t.tv_sec;
	Initmicro = t.tv_usec;
}

long
milliclock()
{
	struct timeval t;
	struct timezone tz;
	long milli;

	if ( Initsecs == 0 )
		resetclock();
	gettimeofday(&t,&tz);
	milli = (t.tv_sec-Initsecs)*1000 + ((t.tv_usec-Initmicro) / 1000);
	return milli;
}
