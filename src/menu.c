/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#define OVERLAY4

#include "key.h"

#include "d_menu.h"

static int Menuysize = 0;

#define MSCROLLWIDTH ((int)(*Menuscrollwidth)*mdep_fontwidth()/4) /* width of menu scroll bar */
#define mymin(a,b) ((a)>(b)?(b):(a))
#define shown(w) mymin((w)->km.nitems,(w)->km.menusize)
#define menuxarea(w) ((w)->km.width+5)
#define menuyarea(w) ((w)->km.height+4)
#define hasscrollbar(w) ((w)->km.offset!=0)

static void
scrollbar(Kwind *w)
{
	int x0 = w->km.x;
	int y0 = w->km.y + w->km.header;
	int y1 = w->km.y+w->km.height;
	int nitems = w->km.nitems;
	int top = w->km.top;
	int bary0, bary1;
	int inset = MSCROLLWIDTH/7;

	bary0 = y0 + ((y1-y0)*top)/nitems;
	bary1 = y0 + ((y1-y0)*(top+w->km.menusize))/nitems;
	my_plotmode(P_STORE);
	mdep_boxfill(x0+1+inset,bary0+1,x0+MSCROLLWIDTH-1-inset,bary1-1);
}

static void
erasescrollbar(Kwind *w)
{
	my_plotmode(P_CLEAR);
	mdep_boxfill(w->km.x+1,w->km.y+w->km.header+1,w->km.x+MSCROLLWIDTH-1,w->km.y+w->km.height-1);
}

void
menustringat(Kwind *w,int itempos,int itemnum)
{
	int n;
	Kitem *ki;

	for ( n=0,ki=w->km.items; ki!=NULL; ki=ki->next,n++ ) {
		if ( n == itemnum ) {
			int y = w->km.y+w->km.header+itempos*Menuysize+1+(int)(*Menuymargin);
			mdep_string(w->km.offset+w->km.x+mdep_fontwidth()/2+2, y, ki->name);
			break;
		}
	}
}

/* menuconstruct(m,existing) - if 'existing' is non-zero, we assume */
/* the menu's already displayed, so we keep the frame, and only change */
/* the strings. */
void
menuconstruct(Kwind *w,int existing)
{
	int n, x1, y1, ny, xmid;
	Kitem *ki;
	int x0 = w->km.x;
	int realy0 = w->km.y;
	int y0 = w->km.y + w->km.header;
	int nshow = shown(w);

	/* Let MIDI I/O happen, since redrawing menus can take some time */
	mdep_sync(); chkinput(); chkoutput(); mdep_sync();

	x1 = x0 + w->km.width;
	y1 = realy0 + w->km.height;

	if ( ! existing ) {
		my_plotmode(P_CLEAR);
		mdep_boxfill(x0,y0,x1,y0+Menuysize-2);
	}
	mdep_sync(); chkinput(); chkoutput(); mdep_sync();
	my_plotmode(P_STORE);
	ny = y0;
	if ( ! existing ) {
		mdep_line(x0+1,realy0,x1-1,realy0);
		xmid = ((x0+x1)/2+x1)/2;
		mdep_line(xmid,realy0+1,xmid,y0-1);
		mdep_line(xmid,realy0+1,x1-1,y0-1);
		mdep_line(x1-1,realy0+1,xmid,y0-1);
		/* mdep_line(x0+1,realy0+1,x1-1,realy0+1); */
		/* mdep_line(x0+1,ny-1,x1-1,ny-1); */
		mdep_line(x0+1,ny,x1-1,ny);
	}
	for ( n=0,ki=w->km.items; ki!=NULL; ki=ki->next,n++ ) {
		if ( n < w->km.top )
			continue;
		if ( n >= (w->km.top + nshow) )
			break;
		if ( existing ) {
			mdep_sync(); chkinput(); chkoutput(); mdep_sync();
			my_plotmode(P_CLEAR);
			mdep_boxfill(w->km.offset+x0+1, ny+(int)(*Menuymargin),
				w->km.x+menuxarea(w)-6, ny+Menuysize-1);
			my_plotmode(P_STORE);
		}
		mdep_string(w->km.offset+x0+mdep_fontwidth()/2+2,
				ny+1+(int)(*Menuymargin), ki->name);
		ny += Menuysize;
		if ( ! existing )
			mdep_line(w->km.offset+x0+1,ny,x1-1,ny);
	}
	/* two sides */
	if ( ! existing ) {
		mdep_line(x0,realy0,x0,y1);
		mdep_line(x1,realy0,x1,y1);
		if ( hasscrollbar(w) ) {
			int x0b = x0 + w->km.offset;
			mdep_line(x0b,y0,x0b,y1);
			mdep_line(x0+1,y1,x0b-1,y1); /* bottom of scroll bar */
		}
		/* extra edges to give 3-d look */
		mdep_line(x0+1,y1+1,x1,y1+1);
		mdep_line(x1+1,realy0+1,x1+1,y1+1);
		mdep_line(x1+2,realy0+2,x1+2,y1+1);
/* sprintf(Msg1,"Menu right edge is %d,%d %d,%d\n",x1+2,realy0+2,x1+2,y1+1);tprint(Msg1); */
/* sprintf(Msg1,"Menu bottom edge is %d,%d %d,%d\n",x0+1,y1+1,x1,y1+1);tprint(Msg1); */
	}
	if ( hasscrollbar(w) ) {
		mdep_sync(); chkinput(); chkoutput(); mdep_sync();
		if ( existing )
			erasescrollbar(w);
		scrollbar(w);
	}

	mdep_sync();
}

void
m_menuitem(Kwind *w,Kitem *ki)
{
	dummyusage(ki);
	w->km.made = 0;
}

void
menusetsize(Kwind *w, int x0, int y0, int x1, int y1)
{
	int dy, sz;

	dummyusage(x0);
	dummyusage(x1);
	dy = y1 - y0;
	if ( dy == 0 )
		sz = *Menusize;
	else
		sz = dy / Menuysize;
	if ( sz < 2 )
		sz = 2;
	w->km.menusize = sz;
	w->km.top = 0;
	w->km.choice = MENU_NOCHOICE;
	w->lasty = y0;
}

void
menucalcxy(Kwind *w)
{
	int choice = w->km.choice;
	int maxlen = 0;
	int n, c;
	Kitem *ki;

	w->km.x = w->x0;
	w->km.y = w->y0;
	for ( n=0,ki=w->km.items; ki!=NULL; ki=ki->next,n++ ) {
		c = (int)strlen(ki->name);
		if ( c > maxlen )
			maxlen = c;
	}
	w->km.width = maxlen * mdep_fontwidth() + mdep_fontwidth() + 4;
	if ( w->km.nitems <= w->km.menusize ) {
		w->km.height = w->km.nitems * Menuysize + w->km.header;
		w->km.offset = 0;
	}
	else {
		w->km.height = w->km.menusize * Menuysize + w->km.header;
		w->km.offset = MSCROLLWIDTH;
		w->km.width += MSCROLLWIDTH;
	}

	/* adjust y to put mouse over choice */
	if ( choice < 0 )
		choice = 0;

	/* the edges of the screen may require repositioning */
	if ( w->km.x <= 0 ) {
		w->km.x = 1;
		w->x0 = w->km.x;
	}
	if ( w->km.y <= 0 ) {
		w->km.y = 1;
		w->y0 = w->km.y;
	}
	if ( (w->km.x+w->km.width+4) >= Wroot->x1 ) {
		w->km.x = Wroot->x1 - w->km.width - 5;
		w->x0 = w->km.x;
	}
	if ( (w->km.y+w->km.height+2) >= Wroot->y1 ) {
		w->km.y = Wroot->y1 - w->km.height - 3;
		w->y0 = w->km.y;
	}

	/* NEW STUFF */
	w->x1 = w->x0 + w->km.width + 4;
	w->y1 = w->y0 + w->km.height + 2;

	if ( w->km.x <= 0 || w->km.y <= 0 ) {
		wredraw1(Wroot);
		execerror("Whoops, menu is too big to fit on the screen!");
	}
}

void
drawchoice(Kwind *w,int unhigh)
{
	int x0, y0;

	if ( w->km.choice < 0 )
		return;
	x0 = w->km.x+1;
	y0 = w->km.y + w->km.header + w->km.choice * Menuysize + 1;

	my_plotmode(unhigh?P_CLEAR:P_STORE);
	mdep_boxfill(w->km.offset+x0, y0, x0 + w->km.width-2, y0 + Menuysize - 2);
	my_plotmode(unhigh?P_STORE:P_CLEAR);
	menustringat(w,w->km.choice,w->km.choice+w->km.top);
}

void
highchoice(Kwind *w)
{
	drawchoice(w,0);
}

void
unhighchoice(Kwind *w)
{
	drawchoice(w,1);
}

int
boundit(int val,int mn,int mx)
{
	if ( val < mn )
		return mn;
	else if ( val > mx )
		return mx;
	else
		return val;
}

static void
updatemenu(Kwind *w,int mx,int my, int nodraw)
{
	int nchoice;

	if ( my < w->km.y || my > (w->km.y + w->km.height) 
		|| mx < w->km.x || mx > (w->km.x + w->km.width) ) {

		/* if we've got a current choice, unhighlight it */
		if ( w->km.choice >= 0 ) {
			unhighchoice(w);
		}
		w->km.choice = MENU_NOCHOICE;
		return;
	}

	/* see if we're in a menu item */
	nchoice = menuchoice(w,mx,my);

	if ( nchoice != MENU_MOVE && nchoice != MENU_DELETE ) {
		/* see if we're in the scroll bar */
		if ( scrollupdate(w,mx,my) )
			return;
	}

	/* if we've got a current choice, and we've changed it... */
	if ( w->km.choice >= 0 && w->km.choice != nchoice ) {

		/* Normally, unhighlight the item we've left */
		unhighchoice(w);
		w->km.choice = MENU_NOCHOICE;
	}

	/* highlight the new choice */
	if ( w->km.choice != nchoice ) {
		w->km.choice = nchoice;
		if ( nodraw == 0 ) {
			highchoice(w);
		}
	}
	return;
}

int
scrollupdate(Kwind *w,int mx,int my)
{
	int newtop;
	int barheight, scrdy;
	int sbah;

	if ( ! (mx >= w->km.x && mx < w->km.x + w->km.offset) ) {
		w->inscroll = 0;
		return 0;
	}

	/* if we just moved into the scrol bar... */
	if ( w->km.choice >= 0 ) {
		highchoice(w);
		w->km.choice = MENU_NOCHOICE;
	}
	w->inscroll = 1;

	/* scroll bar area height (vertical space scroll bar slides in) */
	sbah = w->km.height - w->km.header;

	/* The first time you go into the scroll */
	/* bar, it attempts to center the scroll bar */
	/* on the current mouse position. */
	barheight = (sbah*w->km.menusize)/w->km.nitems;

	int scrdy_num = sbah - barheight; /* numerator of scrdy */
	int scrdy_denom = w->km.nitems-w->km.menusize; /* denomonator of scrdy */
	scrdy = scrdy_num / scrdy_denom;
	if ( scrdy <= 0 ) {
		newtop = my - (w->km.y+w->km.header) - barheight/2;
		scrdy = (w->km.height - barheight) - w->km.menusize;
		if ( newtop < 0 ) {
			newtop = 0;
		}
		newtop = ((newtop * (w->km.nitems-w->km.menusize)) * scrdy_denom ) / scrdy_num;
	}
	else {
		newtop = (( my - (w->km.y+w->km.header) - barheight/2) * scrdy_denom ) / scrdy_num;
	}

	newtop = boundit(newtop,0,w->km.nitems-w->km.menusize);
	if ( newtop != w->km.top ) {
		w->km.top = newtop;
		menuconstruct(w,1);
	}
	w->lasty = my;
	return 1;
}

int
menuchoice(Kwind *w,int x,int y)
{
	int n;
	int ny = w->km.y + w->km.header;
	int nshow = shown(w);
	int nchoice = MENU_NOCHOICE;
	int x0 = w->km.x;
	int x1 = x0 + w->km.width;

	if ( x >= x0 && x <= x1 ) {
		if ( y > w->km.y && y < ny ) {
			if ( x > ((x0+x1)/2+x1)/2 )
				nchoice = MENU_DELETE;
			else
				nchoice = MENU_MOVE;
		}
		else for ( n=0; n<nshow; ny+=Menuysize,n++ ) {
			if ( y > ny && y <= (ny+Menuysize) ) {
				nchoice = n;
				break;
			}
		}
	}
	return nchoice;
}

void
m_reset(void)
{
}

void
m_init(void)
{
	static int first = 1;

	if ( first ) {
		Menuysize = mdep_fontheight() + 2 * (int)(*Menuymargin);
		first = 0;
	}
}

void
m_menudo(Kwind *w,int b,int x,int y,int nodraw)
{
	dummyusage(b);
	updatemenu(w,x,y,nodraw);
}
