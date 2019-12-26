/* dummy midi I/O */
int
mdep_statmidi()
{
	return 0;
}

int
mdep_getnmidi(buff,buffsize)
char *buff;
int buffsize;
{
	return 0;
}

void
mdep_putnmidi(n,p)
int n;
char *p;
{
}

int
mdep_initmidi()
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
