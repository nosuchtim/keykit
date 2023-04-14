/* dummy midi I/O */
int
statmidi()
{
	return 0;
}

int
getnmidi(buff,buffsize)
char *buff;
int buffsize;
{
	return 0;
}

void
putnmidi(n,p)
int n;
char *p;
{
}

int
initmidi()
{
	extern char **Devmidi;
	char *uniqstr();
	*Devmidi = uniqstr("/dev/null");
	return 0;
}

void
endmidi()
{
}

void
rtstart()
{
}

void
rtend()
{
}
