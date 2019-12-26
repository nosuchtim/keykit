/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

/*
 * This contains support for MPU-compatible SMID interfaces on 386 machines.
 * It assumes the 'devsmid' driver is installed.
 */

#include "key.h"
#include <poll.h>
#include <fcntl.h>
#include <sys/smid.h>

#define SMIDDEVICE "/dev/smid"

extern int errno;

int
initmidi(void)
{
	extern char **Devmidi;
	int r;
	int ret = 0;

	Midifd = open(SMIDDEVICE,O_RDWR);
	if ( Midifd >= 0 ) {

		if ( Devmidi )
			*Devmidi = uniqstr(SMIDDEVICE);
		r = ioctl(Midifd,SMIDRESET,0); /* 3 args to pacify lint */
		if ( r < 0 )
			fprintf(stderr,"ERROR in ioctl(SMIDRESET) on Midifd?  errno=%d\n",errno);
			
		if ( ! isastream(Midifd) ) {
			fprintf(stderr,"Hey, Midifd isn't a stream!\n");
			nopoll();
		}
		if ( fcntl(Midifd,F_SETFL,O_NDELAY) < 0 )
			fprintf(stderr,"ERROR in fcntl(O_NDELAY) on Midifd?  errno=%d\n",errno);
	}
	else {
		fprintf(stderr,"Unable to open %s (errno=%d)\n",
			SMIDDEVICE,errno);
		ret = 1;
	}
	millisleep(5);	/* /dev/midi needs some breathing room */
	return(ret);
}

void
endmidi(void)
{
	if ( Midifd >= 0 )
		close(Midifd);
}

static struct smid_data Sd;

int
statmidi(void)
{
	char tmp[2];
	int any;

	if ( Sd.nbytes > 0 )
		return 1;
	if ( Midifd < 0 )
		return 0;
	/* This assumes Midifd is in O_NDELAY mode */
	any = read(Midifd,tmp,1);
	if ( any <= 0 )
		return 0;
	if ( ioctl(Midifd,SMIDDATA,&Sd) < 0 ) {
		fprintf(stderr,"Error (errno=%d) in ioctl of Midifd!  Midi is being disabled!\n",errno);
		Midifd = -1;
		return 0;
	}
	if ( Sd.nbytes > 0 )
		return 1;
	else
		return 0;
}

int
getnmidi(char *buff,int buffsize)
{
	int r;
	if ( Midifd < 0 )
		return 0;
	/* if statmidi hasn't already gotten some, try to get some */
	if ( Sd.nbytes<=0 ) {
		if ( ioctl(Midifd,SMIDDATA,&Sd) < 0 ) {
			fprintf(stderr,"Error (errno=%d) in ioctl of Midifd!  Midi is being disabled!\n",errno);
			Midifd = -1;
			return 0;
		}
		if ( Sd.nbytes <= 0 )
			return 0;
	}
	if ( Sd.nbytes < buffsize ) {
		r = Sd.nbytes;
		(void) memcpy(buff,Sd.buff,r);
		Sd.nbytes = 0;
	}
	else {
		r = buffsize;
		(void) memcpy(buff,Sd.buff,buffsize);
		/* shift unread stuff back down */
		Sd.nbytes -= buffsize;
		(void) memcpy(Sd.buff,Sd.buff+buffsize,Sd.nbytes);
	}
	return r;
}

void
putnmidi(int n,char *p)
{
	if ( Midifd < 0 )
		return;
	if ( write(Midifd,p,(unsigned)n) != n )
		eprint("Hmm, write to /dev/midi didn't write everything?\n");
}

static long Mt = 0;

void
resetclock(void)
{
	int r;
	if ( Midifd < 0 ) {
		Mt = 0;
		return;
	}
	r = ioctl(Midifd,SMIDTIMERESET);
	if ( r < 0 ) {
		fprintf(stderr,"Error (errno=%d) in ioctl(SMIDTIMERESET) of Midifd!  Midi is being disabled!\n",errno);
		Midifd = -1;
	}
}

long
milliclock(void)
{
	long t;
	int r;

	if ( Midifd < 0 )
		return Mt++;
	r = ioctl(Midifd,SMIDTIME,&t);
	if ( r < 0 ) {
		fprintf(stderr,"Error (errno=%d) in ioctl(SMIDTIME) of Midifd!  Midi is being disabled!\n",errno);
		Midifd = -1;
	}
	return t;
}
