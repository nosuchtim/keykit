/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#define OVERLAY7

#include "key.h"
#include "gram.h"

Kwind *Topwind = NULL;
Kwind *Freewind = NULL;
Htablep Windhash = NULL;

#define WINDUNSCALED -2

void
wredraw1(Kwind *w)
{
	showsane(w);
	werase(w);

	if ( (w->flags & WFLAG_NOBORDER) == 0 ) {
		my_plotmode(P_STORE);
		if ( (w->flags & WFLAG_BUTTON) != 0 )
			wshadow(w, 
				(w->flags&WFLAG_MENUBUTTON) != 0,
				(w->flags&WFLAG_PRESSED) != 0 );
		else
			woutline(w);
	}
	if ( w->type == WIND_PHRASE )
		redrawpwind(w);
	if ( w->type == WIND_TEXT )
		redrawtext(w);
	if ( w->type == WIND_MENU )
		redrawmenu(w);
	w->flags |= WFLAG_DRAWN;

	/* We always move freshly-drawn windows to the top, so when we */
	/* do a "childunder", we find them first. */
	if ( w->prev ) {
		/* it's not already on top */
		Kwind *pw = w->prev;
		/* remove it from list */
		pw->next = w->next;
		if ( w->next )
			w->next->prev = pw;
		/* add it to front */
		Topwind->prev = w;
		w->next = Topwind;
		w->prev = NULL;
		Topwind = w;
	}
}

void
woutline(Kwind *w)
{
	mdep_box(w->x0,w->y0,w->x1,w->y1);
}

void
wshadow(Kwind *w,int menubutton,int pressed)
{
	mdep_color(Forecolor);
	mdep_box(w->x0,w->y0,w->x1,w->y1);			/* outline */
	mdep_color(pressed?Darkcolor:Lightcolor);
	mdep_boxfill(w->x0+2,w->y0+2,w->x1-2,w->y1-2);	/* inner box */
	mdep_color(pressed?Lightcolor:Darkcolor);
	mdep_line(w->x0+1,w->y1-1,w->x1-1,w->y1-1);	/* bottom shadow */
	mdep_line(w->x0+2,w->y1-2,w->x1-2,w->y1-2);	/* bottom shadow */

	mdep_line(w->x1-1,w->y0+1,w->x1-1,w->y1-1);	/* right shadow */
	mdep_line(w->x1-2,w->y0+2,w->x1-2,w->y1-2);	/* right shadow */

	mdep_color(Forecolor);

	if ( menubutton ) {
		/* extra shadow lines to distinguish menu button */
		mdep_line(w->x0+3,w->y1-3,w->x1-3,w->y1-3);
		mdep_line(w->x1-3,w->y0+3,w->x1-3,w->y1-3);
	}
}

void
werase(Kwind *w)
{
	long x1 = w->x1;
	long y1 = w->y1;

	my_plotmode(P_CLEAR);

	/* Watch out, we don't want to change w->x1 or w->y1. */
	if ( x1 > Wroot->x1 ) {
#ifdef OLDSTUFF
		eprint("Warning, werase detects x1 > Wroot->x1.");
#endif
		x1 = Wroot->x1;
	}
	if ( y1 > Wroot->y1 ) {
#ifdef OLDSTUFF
		eprint("Warning, werase detects y1 > Wroot->y1.");
#endif
		y1 = Wroot->y1;
	}
	mdep_boxfill(w->x0,w->y0,x1,y1);

/* my_plotmode(P_STORE); mdep_box(w->x0-1,w->y0-1,x1+1,y1+1); */
}

Kwind *
validwind(int n,char *s)
{
	Kwind *w = windptr(n);

	if ( w == NULL )
		execerror("%s given invalid window number (%d)",s,n);
	return w;
}

Kwind *
windptr(int n)
{
	Datum key;
	Hnodep h;

	key = numdatum(n);
	h = hashtable(Windhash,key,H_LOOK);
	if ( h )
		return h->val.u.wind;
	else
		return NULL;
}

void
windlist(void)
{
	Kwind *w;

	for ( w=Topwind; w!=NULL; w=w->next ) {
		tprint("window w=%lld  wnum=%d  xy01=%d,%d,%d,%d\n",
			(long long)w,windnum(w),w->x0,w->y0,w->x1,w->y1);
	}
}

Kwind *
windfinddeep(Kwind *w,int x,int y)
{
	Kwind *cw;

	if ( w==NULL )
		execerror("windfinddeep() got w==NULL!?");
	for ( cw=Topwind; cw!=NULL; cw=cw->next ) {
		if (x>=cw->x0 && x<=cw->x1 && y>=cw->y0 && y<=cw->y1)
			break;
	}
	return cw;
}

int
windcontains(Kwind *w,long x0,long y0)
{
	int inwind;

	if ( w==NULL )
		execerror("windcontains() found w==NULL!?");
	inwind = (x0>=w->x0 && x0<=w->x1
		&& y0>=w->y0 && y0<=w->y1);
	return inwind;
}

int
windlevel(Kwind *w)
{
	Kwind *w2;
	int lev = 0;
	for ( w2=Topwind; w2!=NULL; w2=w2->next ) {
		if ( w2 == w )
			return lev;
		lev++;
	}
	return(-1);
}

int
windoverlaps(Kwind *w,long x0,long y0,long x1,long y1)
{
	int w1x0, w1y0, w1x1, w1y1;
	int w2x0, w2y0, w2x1, w2y1;
	int xover = 0;
	int yover = 0;

	if ( w==NULL )
		execerror("windoverlaps() found w==NULL!?");

	w1x0 = w->x0;
	w1y0 = w->y0;
	w1x1 = w->x1;
	w1y1 = w->y1;
	w2x0 = x0;
	w2y0 = y0;
	w2x1 = x1;
	w2y1 = y1;

	/* see if x values overlap */
	if ( (w2x0 >= w1x0 && w2x0 <= w1x1)
		|| (w2x1 >= w1x0 && w2x1 <= w1x1)
		|| (w2x0 < w1x0 && w2x1 > w1x1) ) {
		xover = 1;
	}
	if ( (w2y0 >= w1y0 && w2y0 <= w1y1)
		|| (w2y1 >= w1y0 && w2y1 <= w1y1)
		|| (w2y0 < w1y0 && w2y1 > w1y1) ) { 
		yover = 1;
	}
	if ( xover && yover )
		return 1;
	else
		return 0;
}

static int Windownum = 0;

void
reinitwinds(void)
{
	Kwind *w, *nw=NULL;

	if ( Topwind ) {
		for ( w=Topwind; w!=NULL; w=nw ) {
			nw = w->next;
			wfree(w);
		}
	}
	if ( Windhash != NULL )
		freeht(Windhash);
	Windhash = newht(61);

	Windownum = 0;

	/* create Root window */
	Wroot = newkwind();
	Wroot->type = WIND_GENERIC;
	Wroot->flags |= WFLAG_NOBORDER;
	setwrootsize();
}

void
setwrootsize(void)
{
	k_setsize(Wroot,0,0,mdep_maxx(),mdep_maxy());
}

Datum
winddatum(Kwind *w)
{
	Datum d;
	d.type = D_WIND;
	d.u.wind = w;
	return d;
}

Kwind *
newkwind(void)
{
	Kwind *w;
	Datum key;
	Hnodep h;

	if ( Freewind ) {
		w = Freewind;
		if ( Freewind->next )
			Freewind->next->prev = NULL;
		Freewind = Freewind->next;
	}
	else {
		w = (Kwind * ) kmalloc(sizeof(Kwind),"newkwind");
	}

	waddtolist(w,&Topwind);

	w->type = WIND_GENERIC;

	w->flags = 0;

	w->x0 = -1;
	w->y0 = 0;
	w->x1 = 0;
	w->y1 = 0;

	windnum(w) = Windownum++;

	key = numdatum(windnum(w));
	h = hashtable(Windhash,key,H_INSERT);
	if ( h!=NULL && isnoval(h->val) ) {
		h->val = winddatum(w);
	}
	else
		eprint("Hey, newkwind finds window # %d already in hashtable!?\n",windnum(w));

	return w;
}

void
k_initphrase(Kwind *w)
{
	w->showlow = 0;
	w->showhigh = 127;
	w->showstart = 0;
	w->showbar = *Showbar;
	w->showleng = 2 * w->showbar;
}

void
k_inittext(Kwind *w)
{
	int n;
	char **pp;

	w->inscroll = 0;
	w->currcols = 0;
	w->disprows = 0;
	w->currx = 0;
	w->curry = 0;
	w->currcol = 0;
	w->currrow = 0;

/* Hmmm, if the screen gets resized, the MAXCOLS may not be enough. */
/* This might be the reason for resize problems?  I'll add a 4* to make */
/* sure it's not a problem.  Small waste of memory, but not that much.  */

#define MAXCOLS (2+4*(Wroot->x1/mdep_fontwidth()))

	w->numlines = *Textscrollsize;
	w->bufflines = (char **) kmalloc(w->numlines*sizeof(char *),"inittext");
	for ( pp=w->bufflines,n=w->numlines-1; n>=0 ; n-- )
		*pp++ = NULL;
	w->currline = kmalloc((unsigned)MAXCOLS,"inittext");
	w->currline[0] = '\0';
	w->lastused = 0;
	w->currlnum = 0;
	w->bufflines[w->currlnum] = w->currline;
	w->toplnum = 0;
}

void
k_reinittext(Kwind *w)
{
	int n;
	char **pp;

#if 0
	w->inscroll = 0;
	w->currcols = 0;
	w->disprows = 0;
	w->currx = 0;
	w->curry = 0;

#define MAXCOLS (2+Wroot->x1/mdep_fontwidth())
	w->numlines = *Textscrollsize;
	/* Don't realloc bufflines */

	w->currcol = 0;
	w->currrow = 0;
#endif

	for ( pp=w->bufflines,n=w->numlines-1; n>=0 ; n-- )
		*pp++ = NULL;
	w->currline[0] = '\0';
	w->lastused = 0;
	w->currlnum = 0;
	w->bufflines[w->currlnum] = w->currline;
	w->toplnum = 0;
}

void
kwindtext(Symstr str,int kx0,int ky0,int kx1,int ky1,int just)
{
	/* avoid repeated mallocs by keeping space around */
	static char *keepstr = NULL;
	static long keepstrsize = 0;
	int nlines = 1;
	char *p;
	int n, dy, mx, my;

	makeroom((long)(strlen(str)+1),&keepstr,&keepstrsize);
	strcpy(keepstr,str);
	for ( p=keepstr; *p!='\0'; p++ ) {
		if ( *p == '\n' ) {
			*p = '\0';
			nlines++;
		}
	}

	mx = mdep_maxx();
	if ( kx0 > mx ) {
		eprint("Warning, invalid x value (%d) in .text, %d is used instead. (str=%s just=%d)",
			kx0,mx-1,str,just);
		kx0 = mx-1;
	}
	if ( kx1 > mx ) {
		eprint("Warning, invalid x value (%d) in .text, %d is used instead. (str=%s just=%d)",
			kx1,mx-1,str,just);
		kx1 = mx-1;
	}
#ifdef OLDSTUFF
	if ( kx0 > mx || kx1 > mx )
		execerror("Invalid x value(s) in .text");
#endif
	my = mdep_maxy();
#ifdef OLDSTUFF
	if ( ky0 > my || ky1 > my )
		execerror("Invalid y value(s) in .text");
#endif
	if ( ky0 > my ) {
		eprint("Warning, invalid y value (%d) in .text, %d is used instead. (str=%s just=%d)",
			ky0,my-1,str,just);
		ky0 = my-1;
	}
	if ( ky1 > my ) {
		eprint("Warning, invalid y value (%d) in .text, %d is used instead. (str=%s just=%d)",
			ky1,my-1,str,just);
		ky1 = my-1;
	}

	dy = (ky1 - ky0)/nlines;
	p = keepstr;
	for ( n=0; n<nlines; n++ ) {
		textfill(p,kx0,ky0,kx1,ky0+dy,just);
		ky0 += dy;
		p += (strlen(p)+1);
	}
}

void
textfill(char *s,int x0,int y0,int x1,int y1,int just)
{
	/* avoid repeated mallocs by keeping space around */
	static char *keepstr = NULL;
	static long keepstrsize = 0;
	int tx, ty;
	int x, y, dx, dy, lng;
	int wid = mdep_fontwidth();
	int hgt = mdep_fontheight();

	tx = wid*(long)strlen(s);
	ty = hgt;

	y = ((y1+y0-ty)/2);	/* should probably do a ceil() on this */
	if ( y < y0 ) {
		/* no room vertically, draw === in the area to indicate that */
	    minitext:
		dy = (y1-y0)/3;
		dx = (x1-x0)/6;
		mdep_line((int)x0+dx,(int)y0+dy,(int)x1-dx,(int)y0+dy);
		mdep_line((int)x0+dx,(int)y1-dy,(int)x1-dx,(int)y1-dy);
		return;
	}

	if ( just == TEXT_CENTER ) {
		x = ((x1+x0-tx)/2);
		if ( x >= x0 )
			mdep_string(x,y,s);
		else {
			/* String is too long - copy and truncate to fit */
			makeroom((long)(strlen(s)+1),&keepstr,&keepstrsize);
			strcpy(keepstr,s);

			lng = (x1-x0)/wid;
			if ( lng <= 0 )
				goto minitext;
			/* We still center the truncated string */
			dx = ((x1-x0) - (lng*wid))/2;
			keepstr[lng] = '\0';
			mdep_string((int)x0+dx,y,keepstr);
		}
		return;
	}
	else if ( just == TEXT_LEFT ) {
		x = x0+wid/2;
		if ( tx <= (x1-x0-wid) )
			mdep_string(x,y,s);
		else {
			/* String is too long - copy and truncate to fit */
			makeroom((long)(strlen(s)+1),&keepstr,&keepstrsize);
			strcpy(keepstr,s);
			lng = (x1-x0-wid)/wid;
			if ( lng <= 0 )
				goto minitext;
			keepstr[lng] = '\0';
			mdep_string((int)x,y,keepstr);
		}
	}
	else {	/* TEXT_RIGHT */
		x = (x1-tx-wid/2);
		if ( x >= (x0+wid/2) )
			mdep_string(x,y,s);
		else {
			/* String is too long - copy and truncate to fit */
			int slen = (int)strlen(s);
			int shiftleft;

			makeroom((long)(slen+1),&keepstr,&keepstrsize);
			strcpy(keepstr,s);
			lng = (x1-x0-wid)/wid;
			if ( lng <= 0 )
				goto minitext;
			shiftleft = slen - lng;
			if ( shiftleft > 0 )
				strcpy(keepstr,keepstr+shiftleft);
			keepstr[lng] = '\0';
			mdep_string((int)(x1-wid/2-lng*wid),y,keepstr);
		}
	}
}

void
kwindline(Kwind *w,int x0,int y0,int x1,int y1)
{
	Krect cliprect;
	cliprect = makerect(w->x0,w->y0,w->x1,w->y1);
	if ( fullclipit(w,&x0,&y0,&x1,&y1,&cliprect) != NT_INVISIBLE ) {
		mdep_color(Forecolor);
		mdep_line(x0,y0,x1,y1);
	}
}

void
kwindrect(Kwind *w,int x0,int y0,int x1,int y1)
{
	kwindrect2(w,x0,y0,x1,y1,0);
}

void
kwindfill(Kwind *w,int x0,int y0,int x1,int y1)
{
	kwindrect2(w,x0,y0,x1,y1,1);
}

void
kwindrect2(Kwind *w,int x0,int y0,int x1,int y1,int dofill)
{
	Krect clip;
	clip = makerect(w->x0,w->y0,w->x1,w->y1);

	rectnormi(&x0,&y0,&x1,&y1);

	if ( rectclipit(w,&x0,&y0,&x1,&y1,&clip) != NT_INVISIBLE ) {
		mdep_color(Forecolor);
		if ( dofill )
			mdep_boxfill(x0,y0,x1,y1);
		else
			mdep_box(x0,y0,x1,y1);
	}
}

void
kwindellipse(Kwind *w,int x0,int y0,int x1,int y1)
{
	kwindellipse2(w,x0,y0,x1,y1,0);
}

void
kwindfillellipse(Kwind *w,int x0,int y0,int x1,int y1)
{
	kwindellipse2(w,x0,y0,x1,y1,1);
}

void
kwindellipse2(Kwind *w,int x0,int y0,int x1,int y1,int dofill)
{
	Krect clip;
	clip = makerect(w->x0,w->y0,w->x1,w->y1);

	rectnormi(&x0,&y0,&x1,&y1);

	if ( rectclipit(w,&x0,&y0,&x1,&y1,&clip) != NT_INVISIBLE ) {
		mdep_color(Forecolor);
		if ( dofill )
			mdep_fillellipse(x0,y0,x1,y1);
		else
			mdep_ellipse(x0,y0,x1,y1);
	}
}

void
kwindfillpolygon(Kwind *w,int *xarr,int *yarr,int arrsize)
{
	Krect clip;

	clip = makerect(w->x0,w->y0,w->x1,w->y1);

	if ( arrsize < 3 ) {
		execerror("Too few points given to kwindfillpolygon");
	}
#if 0
	int n;
	for ( n=1; n<arrsize; n++ ) {
		/* If any line is completely invisible, don't do anything. */
		if ( fullclipit(w,&xarr[n-1],&yarr[n-1],&xarr[n],&yarr[n],&clip) == NT_INVISIBLE ) {
			return;
		}
	}
#endif

	mdep_color(Forecolor);
	mdep_fillpolygon(xarr,yarr,arrsize);
}

void
rectnorml(long *ax0,long *ay0,long *ax1,long *ay1)
{
	if ( *ax0 > *ax1 ) {
		long t = *ax0;
		*ax0 = *ax1;
		*ax1 = t;
	}
	if ( *ay0 > *ay1 ) {
		long t = *ay0;
		*ay0 = *ay1;
		*ay1 = t;
	}
}

void
rectnormi(int *ax0,int *ay0,int *ax1,int *ay1)
{
	if ( *ax0 > *ax1 ) {
		int t = *ax0;
		*ax0 = *ax1;
		*ax1 = t;
	}
	if ( *ay0 > *ay1 ) {
		int t = *ay0;
		*ay0 = *ay1;
		*ay1 = t;
	}
}

void
scalexy(long *ax,long *ay,long fromx0,long fromy0,long fromx1,long fromy1,long tox0,long toy0,long tox1,long toy1)
{
	long fromdx = fromx1 - fromx0;
	long fromdy = fromy1 - fromy0;
	if ( fromdx == 0 )
		*ax = tox0;
	else
		*ax = tox0 + ((*ax-fromx0)*(tox1-tox0)+(fromdx/2))/fromdx;
	if ( fromdy == 0 )
		*ay = toy0;
	else
		*ay = toy0 + ((*ay-fromy0)*(toy1-toy0)+(fromdy/2))/fromdy;
}

void
scalephr2raw(Kwind *w,long *ax,long *ay)
{
	/* The +1,+1,-1,-1 is so that the coordinate space inside */
	/* a window does NOT include the border. */
	long tox0 = w->x0+1;
	long toy0 = w->y0+1;
	long tox1 = w->x1-1;
	long toy1 = w->y1-1;
	long fromx0 = w->showstart;
	long fromx1 = w->showstart + w->showleng;
	long fromy0 = w->showhigh;
	long fromy1 = w->showlow;
	scalexy(ax,ay,fromx0,fromy0,fromx1,fromy1,tox0,toy0,tox1,toy1);
}

void
scalegrid2wind(Kwind *w,long *ax,long *ay)
{
	if ( w->type != WIND_PHRASE )
		execerror("scalegrid2wind applied to a non-phrase window?!");
	scalexy(ax,ay,
		w->showstart, (long)(w->showhigh),
		w->showstart + w->showleng, (long)(w->showlow),
		(long)windxmin(w)+1,(long)windymin(w)+1,
		(long)windxmax(w)-1,(long)windymax(w)-1);
}

void
scalewind2grid(Kwind *w,long *ax,long *ay)
{
	if ( w->type != WIND_PHRASE )
		execerror("scalewind2grid applied to a non-phrase window?!");
	scalexy(ax,ay,
		(long)windxmin(w)+1,(long)windymin(w)+1,
		(long)windxmax(w)-1,(long)windymax(w)-1,
		w->showstart, (long)(w->showhigh),
		w->showstart + w->showleng, (long)(w->showlow));
}

void
k_setsize(Kwind *w,int x0,int y0,int x1,int y1)
{
	w->x0 = x0;
	w->y0 = y0;
	if ( w->type == WIND_MENU ) {
		menusetsize(w,x0,y0,x1,y1);
		menucalcxy(w);
	}
	else {
		w->x1 = x1;
		w->y1 = y1;
	}
	if ( w->type == WIND_PHRASE ) {
		w->showbar = *Showbar;
	}
	if ( *Resizefix ) {
		if ( w->x0 < 0 ) {
			eprint("x0 of window size is < 0 (%ld) !?  It's being set to 0.",w->x0);
			w->x0 = 0;
		}
		if ( w->y0 < 0 ) {
			eprint("y0 of window size is < 0 (%ld) !?  It's being set to 0.",w->y0);
			w->y0 = 0;
		}
		if ( w->x1 > mdep_maxx() ) {
			eprint("x1 of window size is too large (%ld) !?  It's being set to maxx=%d.",w->x1,mdep_maxx());
			w->x1 = mdep_maxx();
		}
		if ( w->y1 > mdep_maxy() ) {
			eprint("y1 of window size is too large (%ld) !?  It's being set to maxy=%d.",w->y1,mdep_maxy());
			w->y1 = mdep_maxy();
		}
	}
	v_settextsize(w);
}

Kitem *
newkitem(char *name)
{
	Kitem *ki;

	ki = (Kitem * ) kmalloc(sizeof(Kitem),"newkitem");
	ki->name = name;
	ki->next = NULL;
	return ki;
}

Kitem *
k_findmenuitem(Symstr name,Kwind *w,int create)
{
	Kitem *ki, *ki2;

	for ( ki=w->km.items; ki!=NULL; ki=ki->next ) {
		if ( name == ki->name )
			return ki;
	}
	if ( create == 0 )
		return (Kitem*)NULL;
	/* not found, add it to end of items list */
	ki = newkitem(name);
	if ( w->km.items == NULL )
		w->km.items = ki;
	else {
		for ( ki2=w->km.items; ki2->next!=NULL; ki2=ki2->next )
			;
		ki2->next = ki;
	}
	ki->pos = w->km.nitems++;
	return ki;
}

void
windhashdelete(Kwind *w)
{
	Datum key;
	key = numdatum(windnum(w));
	hashtable(Windhash,key,H_DELETE);
}

void
wfree(Kwind *w)
{
	wunlink(w,&Topwind);
	windhashdelete(w);
	waddtolist(w,&Freewind);
	if ( (w->flags & WFLAG_SAVEDUNDER) != 0 )
		mdep_freebitmap(w->saveunder);
}

void
wunlink(Kwind *w,Kwind **tw)
{
	/* patch up the list we're removing it from */
	if ( w->next )
		w->next->prev = w->prev;
	if ( w->prev )
		w->prev->next = w->next;
	else
		*tw = w->next;
}

void
waddtolist(Kwind *w, Kwind **wlist)
{
	w->next = *wlist;
	w->prev = NULL;
	if ( *wlist )
		(*wlist)->prev = w;
	*wlist = w;
}

void
k_initmenu(Kwind *w)
{
	static Pbitmap Emptybitmap = EMPTYBITMAP;
	w->inscroll = 0;
	w->km.items = NULL;
	w->km.nitems = 0;
	w->km.menusize = *Menusize;
	w->km.made = 0;
	w->km.top = 0;
	w->km.choice = M_NOCHOICE;
	w->km.width = 0;
	w->km.header = 8;
}

Kitem *
k_menuitem(Kwind *w,Symstr item)
{
	Kitem *ki;

	/* We only want to call m_menuitem once, when item is first created. */
	ki = k_findmenuitem(item,w,0);
	if ( ki == NULL ) {
		ki = k_findmenuitem(item,w,1);
		m_menuitem(w,ki);
	}
	return ki;
}

Krect
makerect(long x0, long y0, long x1, long y1)
{
	Krect r;
	r.x0 = x0;
	r.y0 = y0;
	r.x1 = x1;
	r.y1 = y1;
	return r;
}
