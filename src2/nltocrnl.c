/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#include <stdio.h>
main(argc,argv)
int argc;
char **argv;
{
	int c;
	int state = 0;
	int ret = 0;

	if ( argc > 1 ) {
		fprintf(stderr,"nltonlcr can only be used as a filter!\n");
		exit(1);
	}
	while ( (c=getchar()) != EOF ) {
		switch (state) {
		case 0:		/* previous char was not \r */
			if ( c == '\r' )
				state = 1;
			else if ( c == '\n' ) {
				ret = 1;
				putchar('\r');	/* the whole point of this filter */
			}
			break;
		case 1:		/* previous char was \r */
			state = 0;
			break;
		}
		putchar(c);
	}
	return ret;
}
