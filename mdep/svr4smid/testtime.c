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
	int fd;
	long t;
	extern int errno;
	struct smid_data sd;

	if ( argc > 1 )
		fd = open(argv[1],O_RDONLY );
	else
		fd = open("/dev/smid",O_RDONLY );
	if ( fd < 0 ) {
		fprintf(stderr,"fd=%d, errno=%d\n",fd,errno);
		perror("/dev/smid");
		exit(1);
	}
	fprintf(stderr,"start 0\n");
	for ( n=0; n<100; n++ )
		r = ioctl(fd,SMIDRESET,0);
	fprintf(stderr,"start 1\n");
	for ( n=0; n<100; n++ )
		r = ioctl(fd,SMIDTIME,&t);
	fprintf(stderr,"start 2\n");
	for ( n=0; n<10000; n++ ) {
		r = ioctl(fd,SMIDDATA,&sd);
		fprintf(stderr,"r=%d sd.bytes=%d\n",r,sd.nbytes);
	}
	fprintf(stderr,"start 3\n");
	fprintf(stderr,"r=%d sd.bytes=%d\n",r,sd.nbytes);

	for ( n=0; n<10; n++ ) {
		r = ioctl(fd,SMIDTIME,&t);
		fprintf(stderr,"r=%d time=%ld\n",r,t);
		sleep(3);
	}
	close(fd);
}
