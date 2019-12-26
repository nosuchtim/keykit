/*
 * This is support for the /dev/midi driver on Sparcstations, a
 * (currently non-standard) device driver that allows the serial interface
 * on a Sparcstation to be driven at MIDI rates.  This also requires a
 * special plug (known as a MIDI 'doober') attached to the serial connector.
 * For more info, contact tjt@twitch.att.com or dss@sun.com.
 */

#include <stdio.h>
#include <fcntl.h>
#include <midi.h>
#include <signal.h>

#define MIDIDEVICE "/dev/midi"
#define MBSIZE 128

#define MICROPERTICK 1000

static int Mfd = -1;
static int Mbsofar = 0;
static int Mbhead = 0;
static unsigned char Mbuff[MBSIZE];
static unsigned char Mmsg[MBSIZE];
#ifdef OLDSTUFF
static unsigned long Deltasofar = 0;
#endif
static int Mdbg = 0;

void
midialarm()
{
	Mfd = -1;
}

void
safedrain()
{
	/* The MIDI_DRAIN ioctl() sometimes get hung - there's probably */
	/* a bug in the /dev/midi driver.  This makes sure we get past it. */

	signal(SIGALRM,midialarm);
	alarm(2);
	ioctl(Mfd,MIDI_DRAIN,0);
	alarm(0);
	if ( Mfd < 0 ) {
		char msg[100];
		sprintf(msg,"'%s' isn't responding.  MIDI I/O is disabled!\n", MIDIDEVICE);
		tprint(msg);
	}
	else
		ioctl(Mfd,MIDI_FLUSH,0);
}

void
initmidi()
{
	extern char **Devmidi;
	extern int errno;
	extern char *sys_errlist[];
	extern int sys_nerr;
	char *uniqstr();

	if ( Mfd >= 0 )
		return;
	Mfd = open(MIDIDEVICE,O_RDWR | O_NDELAY);
	if ( Mfd < 0 ) {
		char msg[100];
		sprintf(msg,"Can't open '%s' (%s)!  MIDI I/O is disabled!\n",
			MIDIDEVICE,
			errno<=sys_nerr?sys_errlist[errno]:"Unknown error");
		tprint(msg);
	}
	else {
		struct midi_ioctl mi;
		*Devmidi = uniqstr(MIDIDEVICE);
		ioctl(Mfd,MIDI_GET,&mi);
		mi.tick = MICROPERTICK;
		ioctl(Mfd,MIDI_SET,&mi);
		safedrain();
	}
}

void
sun_reset()
{
	if ( Mfd >= 0 )
		safedrain();
}

void
endmidi()
{
	sun_reset();
	if ( Mfd >= 0 )
		close(Mfd);
}

void
rtstart()
{
	sun_reset();
}

void
rtend()
{
	sun_reset();
}

void
somemoremidi()
{
	int n;

	if ( (n=read(Mfd,&Mbuff[Mbsofar],MBSIZE-Mbsofar)) > 0 ) {
		Mbsofar += n;
	}
}

int
statmidi()
{
	int n;
	char buff[2];

	if ( Mfd < 0 )
		return 0;
	if ( Mbsofar > 0 )
		return 1;
	somemoremidi();
	if ( Mbsofar > 0 )
		return 1;
	return 0;
}

int
frombuff()
{
	if ( Mbhead < Mbsofar ) {
		int c = Mbuff[Mbhead++];
		if ( Mbhead == Mbsofar ) {
			/* buffer is emptied, reset it */
			Mbhead = Mbsofar = 0;
		}
		return c;
	}
	/* buffer is emptied, reset it */
	Mbhead = Mbsofar = 0;
	while ( Mbsofar <=0 ) {
		somemoremidi();
	}
	return frombuff();
}

char *
getnmidi(an)
int *an;
{
	int sz, n, b0, b1, delta;

	if ( Mbsofar <= 0 )
		somemoremidi();
	if ( Mbsofar <= 0 )
		return (char *)NULL;
	/* transfer an entire message to Mmsg */ 
	Mmsg[0] = b0 = frombuff();
	Mmsg[1] = b1 = frombuff();

	sz = Mmsg[2] = frombuff();
	for ( n=0; n<sz; n++ )
		Mmsg[3+n] = frombuff();
	*an = n;
	return (char *)(&Mmsg[3]);
}

void
putnmidi(n,p)
int n;
char *p;
{
	char buff[3];

	buff[0] = 0;
	buff[1] = 0;
	buff[2] = n;
	write(Mfd,buff,3);
	write(Mfd,p,n);
}
