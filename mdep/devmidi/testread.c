/*
 * A test program for reading from /dev/midi.
 * Invoke it, and play something on the MIDI input keyboard.
 * Interrupt to terminate.
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/fcntl.h>
#include <sys/midi.h>

main(argc,argv)
int argc;
char **argv;
{
	int n, k;
	unsigned char buff[100];
	long t;
	int fd;

fprintf(stderr,"testread 1\n");sleep(1);
	if ( argc > 1 )
		fd = open(argv[1],O_RDONLY );
	else
		fd = open("/dev/midi",O_RDONLY );
fprintf(stderr,"testread 2\n");sleep(1);
	ioctl(fd,MIDIRESET,0);
fprintf(stderr,"testread 3\n");sleep(1);
	while ( 1 ) {
fprintf(stderr,"testread 4\n");sleep(1);
		if ( (n=read(fd,buff,sizeof(buff))) > 0 ) {
fprintf(stderr,"testread 5\n");sleep(1);
			ioctl(fd,MIDITIME,&t);
fprintf(stderr,"testread 6\n");sleep(1);
			printf("Time=%ld  ",t);
			for ( k=0; k<n; k++ )
				printf("  0x%x",buff[k]);
			printf("\n");
		}
fprintf(stderr,"testread 7\n");sleep(1);
	}
}
