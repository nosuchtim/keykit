#include "key.h"

/* dummy midi I/O */
int
mdep_statmidi()
{
	return 0;
}

int
mdep_getnmidi(buff,buffsize,p)
char *buff;
int buffsize;
int *p;
{
	return 0;
}

void
mdep_putnmidi(n,p,port)
int n;
char *p;
Midiport *port;
{
}

int
mdep_initmidi(inputs,outputs)
Midiport * inputs;
Midiport * outputs;
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
