/* dummy midi I/O */
#include "key.h"
int
mdep_initmidi()
{
	extern char **Devmidi;
	char *uniqstr();
	ami_openmidi();
	*Devmidi = uniqstr("/dev/null");
	return 0;
}

void
mdep_endmidi()
{
	ami_closemidi();
}

void
rtstart( void )
{
}

void
rtend( void )
{
}
