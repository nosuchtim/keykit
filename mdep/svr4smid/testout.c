/*
 * A test program for writing to /dev/smid.
 *
 * Usage: testwrite {file}
 * 
 * The contents of the file will be used to control the pitches of
 * notes written to /dev/smid.
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/fcntl.h>
#include <sys/smid.h>

main(argc,argv)
int argc;
char **argv;
{
	int n, k, c;
	unsigned char buff[100];
	long t;
	int fd, r;
	FILE *fin;
	long tm, nexttm;
	extern int errno;

	if ( argc > 2 ) {
		fd = open(argv[2],O_WRONLY );
		argc--;
		argv++;
	}
	else {
		fd = open("/dev/smid",O_WRONLY );
	}
	if ( fd < 0 ) {
		fprintf(stderr,"UNABLE to open file!  errno=%d\n",errno);
		exit(1);
	}

	if ( argc > 1 ) {
		fin = fopen(argv[1],"r");
	}
	else
		fin = stdin;

	if ( fin == NULL ) {
		fprintf(stderr,"UNABLE to open input!\n");
		exit(1);
	}

	for ( n=0; n<50; n++ ) {
		errno = 0;
		r = ioctl(fd,SMIDRESET,(long)0);
fprintf(stderr,"%d,%d ",r,errno);
	}
	errno = 0;
	r = ioctl(fd,SMIDTIME,&tm);
fprintf(stderr,"SMIDTIME r=%d  errno=%d\n",r,errno);
	while ( (c=getc(fin)) != EOF ) {
		buff[0] = 0x90;
		buff[1] =  c % 128;
		buff[2] = 0x40;
		write(fd,buff,3);
		nexttm = tm + 100;
		while ( tm < nexttm )
			r = ioctl(fd,SMIDTIME,&tm);
		buff[2] = 0x00;
		write(fd,buff,3);
	}
	close(fd);
}
