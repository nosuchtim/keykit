/* dummy midi I/O */
int
statmidi()
{
	return 0;
}

char *
getnmidi(an)
int *an;
{
	*an = 0; return (char *)0;
}

void
putnmidi(n,p)
int n;
char *p;
{
	char msg[100];
	int k;

	sprintf(msg,"putnmidi %d bytes =",n);
	tprint(msg);
	for ( k=0; k<n; k++ ) {
		sprintf(msg," %02x",(int)(p[k]&0xff));
		tprint(msg);
	}
	tprint("\n");
}

void
initmidi()
{
	extern char **Devmidi;
	char *uniqstr();
	*Devmidi = uniqstr("/dev/debug");
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
