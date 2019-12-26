/*
 * A test program for reading from /dev/smid.
 * Invoke it, and play something on the SMID input keyboard.
 * Interrupt to terminate.
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/fcntl.h>
#include <sys/smid.h>

main(argc,argv)
int argc;
char **argv;
{
	int n, k, r;
	unsigned char buff[2];
	struct smid_data md;
	int fd;
	extern int errno;

	if ( argc > 1 )
		fd = open(argv[1],O_RDONLY );
	else
		fd = open("/dev/smid",O_RDONLY );
	if ( fd < 0 ) {
		fprintf(stderr,"fd=%d, errno=%d\n",fd,errno);
		perror("/dev/smid");
		exit(1);
	}
	r = ioctl(fd,SMIDRESET,0);
	printf("RESET ioctl r=%d  ",r);
	while ( 1 ) {
		sleep(2);
		r = ioctl(fd,SMIDDATA,&md);
		printf("ioctl r=%d  ",r);
		printf("Time=%ld  ",md.clock);
		printf("Bytes=%ld  ",md.nbytes);
		printf("Buff=%d,%d,...  \n",md.buff[0], md.buff[1]);
	}
}
