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

	mdep_hello(argc,argv);
	mdep_prerc();
	mdep_startgraphics(argc,argv);
	mx = mdep_maxx();
	my = mdep_maxy();
	mdep_plotmode(P_STORE);
	ctext(0,0,"hello world");
	ctext(0,mdep_fontheight()+2,"goodbye cruel world");
	ctext(0,2*(mdep_fontheight()+2),"This should be completely enclosed");
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
