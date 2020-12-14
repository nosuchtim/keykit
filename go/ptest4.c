/*
 * ptest3 - test program for KeyKit graphics.
 *
 * Useful when first developing graphics support for
 * a new machine/environment.
 *
 * When invoked, this program draws text with surrounding rectangles.
 * The text should be centered and completely enclosed within the
 * rectangles.  The rectangle surrounding "hello world" should be
 * completely visible (ie. location 0,0 is the upper-leftmost point).
 */

#include "key.h"

void ctext(int,int,char *);

int
MAIN(argc,argv)
int argc;
char **argv;
{
	int mx, my;
	int n = 256;

	mdep_hello(argc,argv);
	mdep_prerc();
	mdep_startgraphics(argc,argv);
	mx = mdep_maxx();
	my = mdep_maxy();

	mdep_colormix(5,255*n,0,0);
	mdep_colormix(6,0,255*n,0);
	mdep_colormix(7,0,0,255*n);
	mdep_color(1);
	mdep_plotmode(P_STORE);
	mdep_boxfill(10,10,100,60);
	mdep_color(1);
	mdep_plotmode(P_XOR);
	mdep_string(10,50,"Hello");

	mdep_sync();

	while ( mdep_mouse((int*)NULL,(int*)NULL,(int*)NULL) == 0 )
		mdep_waitfor(10);

	mdep_endgraphics();
	mdep_bye();
	exit(0);
	return 0;
}

void
ctext(int x,int y,char *s)
{
	int x2 = x + mdep_fontwidth()*strlen(s);
	int y2 = y + mdep_fontheight();

	mdep_string(x,y,s);
	mdep_line(x,y,x2,y);
	mdep_line(x2,y,x2,y2);
	mdep_line(x2,y2,x,y2);
	mdep_line(x,y2,x,y);
}
