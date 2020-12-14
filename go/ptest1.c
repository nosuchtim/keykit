/*
 * ptest1 - test program for KeyKit graphics.
 *
 * Useful when first developing graphics support for
 * a new machine/environment.
 *
 * When invoked, this program draws a series of concentric
 * rectangles, and then waits for you to press a mouse button.
 * Each time you press a mouse button, the mouse cursor should
 * change.  It will cycle through all the different cursors
 * (ie. you should keep pressing the button), and then clear
 * the display (by XORing everything - there should be nothing
 * left), and then quit.
 */

#include "key.h"

void
waitmouse()
{
	while ( mdep_mouse((int*)NULL,(int*)NULL,(int*)NULL) == 0 ) {
		if ( mdep_waitfor(10) == K_QUIT )
			exit(0);
	}
	while ( mdep_mouse((int*)NULL,(int*)NULL,(int*)NULL) != 0 ) {
		if ( mdep_waitfor(10) == K_QUIT )
			exit(0);
	}
}

int
MAIN(argc,argv)
int argc;
char **argv;
{
	int mx, my, n, x;
	static int cursors[] = { M_ARROW, M_SWEEP, M_CROSS, M_LEFTRIGHT,
		M_UPDOWN, M_ANYWHERE, M_BUSY, -1 };

	mdep_hello(argc,argv);
	mdep_prerc();
	mdep_startgraphics(argc,argv);
	mdep_initmidi();
	mx = mdep_maxx();
	my = mdep_maxy();
	mdep_plotmode(P_XOR);
	mdep_line(0,0,mx,my);
	mdep_line(0,my,mx,0);
	/* mdep_sync(); */
	for ( x=10; x<(mx/2) && x<(my/2); x+=10 )
		mdep_box(x,x,mx-x,my-x);

	waitmouse();

	for ( n=0; cursors[n] >= 0; n++ ) {
		mdep_setcursor(cursors[n]);
		waitmouse();
	}

	/* this should erase everything */
	mdep_line(0,0,mx,my);
	mdep_line(0,my,mx,0);
	for ( x=10; x<(mx/2) && x<(my/2); x+=10 )
		mdep_box(x,x,mx-x,my-x);
	waitmouse();
	mdep_endgraphics();
	mdep_bye();
	exit(0);
	return(0);
}
