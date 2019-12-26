#include "key.h"

/* dummy midi I/O */
int
mdep_statmidi()
{
	return 0;
}

int
mdep_getnmidi(buff,buffsize,port)
char *buff;
int buffsize;
int *port;
{
	return 0;
}

void
mdep_putnmidi(n,p,pport)
int n;
char *p;
Midiport * pport;
{
}

int
mdep_initmidi(Midiport *inputs, Midiport *outputs)
{
	extern char **Devmidi;
	char *uniqstr();
	*Devmidi = uniqstr("/dev/null");
	return 0;
}

void
mdep_endmidi()
{
}
