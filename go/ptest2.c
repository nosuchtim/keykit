/*
 * ptest2 - test program for KeyKit graphics.
 *
 * Useful when first developing graphics support for
 * a new machine/environment.
 *
 * When invoked, this program draws an X in the upper left corner
 * of the screen, then uses the p_*bitmap() functions to copy it
 * to fill the screen.  Press a mouse button to exit.
 */

#include "key.h"

int
MAIN(argc,argv)
int argc;
char **argv;
{
	int mx, my, x, y;
	Pbitmap p;

	mdep_hello(argc,argv);
	mdep_prerc();
	mdep_startgraphics(argc,argv);

	mdep_popup("Begin test of bitmap pull/put stuff");

	mx = mdep_maxx();
	my = mdep_maxy();
	mdep_plotmode(P_STORE);
	mdep_line(0,0,10,10);
	mdep_line(0,10,10,0);
	p = mdep_allocbitmap(10,10);
	mdep_pullbitmap(0,0,p);

	for ( x=10; x<(mx-10); x+=10 ) {
		for ( y=10; y<(my-10); y+=10 ) {
			mdep_putbitmap(x,y,p);
		}
	}

	mdep_popup("Test finished, now wait for mouse down");

	while ( mdep_mouse((int*)NULL,(int*)NULL,(int*)NULL) == 0 ) {
		if ( mdep_waitfor(10) == K_QUIT ) {
			mdep_popup("waitfor got K_QUIT!?");
			exit(0);
		}
	}
	mdep_popup("After waiting for mouse to go down");

	mdep_endgraphics();
	mdep_bye();
	return(0);
}

