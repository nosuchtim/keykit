/*
 * A test program for reading from /dev/midi.
 * Invoke it, and play something on the MIDI input keyboard.
 * Interrupt to terminate.
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/fcntl.h>
#include <sys/midi.h>
#include <stropts.h>
#include <poll.h>

main(argc,argv)
int argc;
char **argv;
{
	int n, k;
	unsigned char buff[100];
	long t;
	int fd, cfd;
	struct pollfd fds[2];
	extern int errno;

	if ( argc > 1 )
		fd = open(argv[1],O_RDONLY );
	else
		fd = open("/dev/midi",O_RDONLY );
	ioctl(fd,MIDIRESET,0);

	cfd = open("/dev/console",O_RDONLY);
fprintf(stderr,"fd=%d  cfd=%d\n",fd,cfd);

	fds[0].fd = cfd;
	fds[0].events = POLLIN;

	fds[1].fd = fd;
	fds[1].events = POLLIN;

	while ( 1 ) {

		fds[0].revents = 0;
		fds[1].revents = 0;

		n = poll(fds,1,1000);

fprintf(stderr,"n=%d errno=%d\n",n,errno);

		if ( n > 0 ) {
			fprintf(stderr,"Poll got n=%d  revents=0x%x , 0x%x\n",
				n,fds[0].revents,fds[1].revents);
		}
#ifdef OLDSTUFF
		if ( (n=read(fd,buff,sizeof(buff))) > 0 ) {
			ioctl(fd,MIDITIME,&t);
			printf("Time=%ld  ",t);
			for ( k=0; k<n; k++ )
				printf("  0x%x",buff[k]);
			printf("\n");
		}
#endif
	}
}
