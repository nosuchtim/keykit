/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */
#define OVERLAY4

#include "key.h"

#ifndef MOVEBITMAP
Pbitmap Tmap = EMPTYBITMAP;
#endif

char Curschar = '_' /* 0x7f would be a small square */;

#define v_rowsize() (mdep_fontheight()+2)
#define v_colsize() (mdep_fontwidth())
#define columnx(w,c) ((w)->tx0+v_colsize()/2+1+(c)*v_colsize())
#define rowy(w,r) (w->y1-v_rowsize()/4-v_rowsize()*(w->disprows-(r)))

Pbitmap
v_reallocbitmap(int x,int y,Pbitmap p)
{
	Pbitmap t;
	if ( p.ptr == NULL )
		t = mdep_allocbitmap(x,y);
	else
		t = mdep_reallocbitmap(x,y,p);
	return t;
}

int
v_linenorm(Kwind *w,int ln)
{
	while ( ln >= w->numlines )
		ln -= w->numlines;
	while ( ln < 0 )
		ln += w->numlines;
	return ln;
}

void
v_settextsize(Kwind *w)
{
	int xsize, ysize, new_tcols, new_trows;

	if ( w->type != WIND_TEXT )
		return;

	w->tx0 = w->x0 + v_colsize()*3;
	xsize = v_colsize();
	ysize = v_rowsize();
	/* The computation below for Trows parallels what's done in rowtoy() */
	new_trows = (w->y1 - w->y0 - ysize/4 - 2) / ysize;
	if ( new_trows < 1 )
		new_trows = 1;
	new_tcols = (w->x1 - w->tx0 - xsize) / xsize;
	if ( new_tcols < 1 )
		new_tcols = 1;

	if ( new_tcols != w->currcols || new_trows != w->disprows ) {
		w->currcols = new_tcols;
		w->disprows = new_trows;
		w->toplnum = v_linenorm(w,w->lastused + w->disprows - 1);
		w->currrow = w->disprows - 1;
	}
}

void
v_setxy(Kwind *w)
{
	w->currx = columnx(w,w->currcol);
	w->curry = rowy(w,w->currrow);
}

void
drawsweep(Kwind *w,int type,int x0,int y0,int x1,int y1)
{
	switch (type) {
	case M_SWEEP:
		rectnormi(&x0,&y0,&x1,&y1);
		mdep_box(x0,y0,x1,y1);
		break;
	case M_LEFTRIGHT:
		mdep_line(x0,w->y0+1,x0,w->y1-1);
		if ( x1 != x0 )
			mdep_line(x1,w->y0+1,x1,w->y1-1);
		break;
	case M_UPDOWN:
		mdep_line(w->x0+1,y0,w->x1-1,y0);
		if ( y1 != y0 )
			mdep_line(w->x0+1,y1,w->x1-1,y1);
		break;
	}
}

long
sanequant(Kwind *w,long qnt)
{
	int x0, x1;

	/* make sure the given quantize value is at least as big as a pixel */
	for ( ;; ) {
		x0 = clktox(0L);
		x1 = clktox(100L*qnt);
		if ( (x1-x0) >= 100 )
			break;
		qnt *= 2;
	}
	return qnt;
}

void
dosweepstart(Kwind *w,int type,long x0,long y0,Fifo *mf)
{
	if (type!=M_SWEEP && type!=M_ANYWHERE && type!=M_LEFTRIGHT && type!=M_UPDOWN)
		execerror("bad type given to sweep()!");

	if ( type==M_ANYWHERE )
		type = M_SWEEP;

	mdep_setcursor(type);

	fixxy(w,&x0,&y0);

	my_plotmode(P_XOR);

	Pc = (Unchar*)Idosweep;

	pushexp(fifodatum(mf));
	pushexp(numdatum(windnum(w)));
	pushexp(numdatum((long)0));	/* used to be "dogrid" */
	pushexp(numdatum((long)type));
	pushexp(numdatum(x0));
	pushexp(numdatum(y0));

	pushexp(numdatum(x0));	/* x1 */
	pushexp(numdatum(y0));	/* y1 */
	drawsweep(w,type,(int)x0,(int)y0,(int)x0,(int)y0);
}

void
redrawmenu(Kwind *w)
{
	werase(w);
	menucalcxy(w);
	menuconstruct(w,0);
	if ( w->km.choice >= 0 ) {
		highchoice(w);
	}
}

void
mouseblock(Fifo *mf)
{
	if ( mf == NULL )
		execerror("mf==NULL in mouseblock??");
	if ( mf->t != NULL )
		execerror("mf is already blocked in mouseblock??");
	blockfifo(mf,1);
}

void
xyquant(Kwind *w,long *amx,long *amy,long quant,long *aclk,long *apitch)
{
	long qnt, pitch, clk;

	qnt = sanequant(w,quant);
	xytogrid(w,*amx,*amy,&clk,&pitch,qnt);
	if ( clk < w->showstart )
		clk = w->showstart;
	else if ( clk > (w->showstart+w->showleng) )
		clk = (w->showstart+w->showleng);
	if ( pitch < w->showlow )
		pitch = w->showlow;
	else if ( pitch > w->showhigh )
		pitch = w->showhigh;
	*amx = clktox(clk);
	*amy = pitchtoy(w,(int)pitch);
	if ( aclk )
		*aclk = clk;
	if ( apitch )
		*apitch = pitch;
}

void
getmxy(Datum d,int *amx,int *amy,int *amval)
{
	char *err = "getmxy got improper array??";

	/* mouse message is an array with x,y,button */
	if ( d.type != D_ARR )
		execerror("getmxy expects array!?");
	*amx = (int) arraynumval(d.u.arr,Str_x,err);
	*amy = (int) arraynumval(d.u.arr,Str_y,err);
	*amval = (int) arraynumval(d.u.arr,Str_button,err);
}

void
fixxy(Kwind *w,long *amx,long *amy)
{
	if ( w->type == WIND_PHRASE ) {
/* sprintf(Msg1,"fixxy start mx=%d my=%d\n",*amx,*amy);tprint(Msg1); */
		xyquant(w,amx,amy,*Sweepquant,(long*)0,(long*)0);
/* sprintf(Msg1,"fixxy end mx=%d my=%d\n",*amx,*amy);tprint(Msg1); */
	}
	else {
		*amx = boundit((int)(*amx),windxmin(w),windxmax(w));
		*amy = boundit((int)(*amy),windymin(w),windymax(w));
	}
}

void
i_dosweepcont(void)
{
	int x0, y0, x1, y1, type, n, changed, mval, mx, my;
	Fifo *mf;
	long lx0, ly0, lx1, ly1;
	Codep i;
	Datum d;
	Kwind *w;

	i = use_ipcode();
	mf = (Stackp-8)->u.fifo;
	w = windptr((int)((Stackp-7)->u.val));
	/* dogrid = (int)((Stackp-6)->u.val); */
	type = (int)((Stackp-5)->u.val);
	x0 = (int)((Stackp-4)->u.val);
	y0 = (int)((Stackp-3)->u.val);
	x1 = (int)((Stackp-2)->u.val);
	y1 = (int)((Stackp-1)->u.val);

	mval = 1;
	mx = x1;
	my = y1;

	while ( mval !=0 && fifosize(mf)>0 ) {
		long lmx, lmy;
		d = removedatafromfifo(mf);
		getmxy(d,&mx,&my,&mval);
		lmx = mx; lmy = my;
		fixxy(w,&lmx,&lmy);
		mx = (int)lmx; my = (int)lmy;
	}

	if ( mval != 0 ) {
		changed = (mx!=x1 || my!=y1);
		if ( changed ) {
			my_plotmode(P_XOR);
			drawsweep(w,type,x0,y0,x1,y1);
			drawsweep(w,type,x0,y0,mx,my);
			my_plotmode(P_STORE);
			(Stackp-2)->u.val = mx;
			(Stackp-1)->u.val = my;
		}
		setpc(i);	/* loop back to i_dosweepcont() */
		mouseblock(mf);
		return;
	}
	/* sweep has ended */

	my_plotmode(P_XOR);
	drawsweep(w,type,x0,y0,x1,y1);
	my_plotmode(P_STORE);

	mdep_setcursor(M_ARROW);

	/* Scale to values appropriate for the window we're in. */
	lx0 = x0; ly0 = y0;
	lx1 = x1; ly1 = y1;

/* sprintf(Msg1,"before final quant, mx=%d my=%d\n",lx1,ly1);tprint(Msg1); */
	fixxy(w,&lx1,&ly1);	/* for final quantizing */
/* sprintf(Msg1,"after final quant, mx=%d my=%d\n",lx1,ly1);tprint(Msg1); */

	if ( w->type == WIND_PHRASE ) {
		scalewind2grid(w,&lx0,&ly0);
		scalewind2grid(w,&lx1,&ly1);
		lx0 = longquant(lx0,*Sweepquant);
		lx1 = longquant(lx1,*Sweepquant);
	}

	rectnorml(&lx0,&ly0,&lx1,&ly1);

	switch(type){
	case M_LEFTRIGHT:
		ly0 = 0;
		ly1 = (w->type==WIND_PHRASE) ? 127 : w->x1;
		break;
	case M_UPDOWN:
		lx0 = 0;
		lx1 = (w->type==WIND_PHRASE) ? ((*(w->pph))->p_leng) : w->x1;
		break;
	}

	/* pop the coordinates and type */
	for ( n=0; n<8; n++ ) {
		popinto(d);
	}

	/* Ending a sweep() function, construct array to return. */
	pushexp(xy01arr(lx0,ly0,lx1,ly1));

	/* this task continues on normally, calling i_popnreturn */
}

char *
ptbuffer(Kwind *w,int c)
{
	char *p = &(w->currline[c]);
	return p;
}

void
v_string(char *s)
{
	/* v_stringwind(s,Wcons); */
	putonconsoutfifo(uniqstr(s));
}

void
wprint(char *s)
{
	if ( Wprintf->type == WIND_MENU || Wprintf->type == WIND_TEXT )
		v_stringwind(s,Wprintf);
	else
		eprint(s);	/* shouldn't normally happen (but did) */
}

void
v_stringwind(char *s,Kwind *w)
{
	int newline;
	char c;
	char str[2];

	if ( w == NULL || w->disprows==0 || w->currcols==0 ) {
		eprint("%s",s);	/* last resort, to get it out somehow */
		return;
	}

	v_texttobottom(w);

	str[1]='\0';

	v_echar(w); 	/* erase the cursor (assumes Tx,Ty is in right place) */
	while ( (c=(*s++)) != '\0' ) {

		if ( c == '\b' || c == Erasechar) {
			if ( w->currcol > 0 ) {
				w->currcol--;
				v_setxy(w);
				*ptbuffer(w,w->currcol) = '\0';
				v_echar(w);
				
			}
		}
		else {
			newline = (c=='\n' || c=='\r');
			if ( ! newline ) {
				char *pt = ptbuffer(w,w->currcol);
				if ( pt == NULL ) {
					eprint("WARNING!! pt==NULL in v_string()\n");
					return;
				}
				*pt = c;
				str[0] = c;
				my_plotmode(P_STORE);
				mdep_string(w->currx,w->curry,str);
				w->currcol++;
				*ptbuffer(w,w->currcol) = '\0';
			}
			if ( newline || w->currcol >= w->currcols ) {
				w->currcol = 0;
				if ( c != '\r' ) {
					v_scrolldisplay(w);
					v_scrollbuff(w);
				}
			}
		}
		v_setxy(w);
	}
	/* print the cursor after the last character */
	str[0] = Curschar;
	my_plotmode(P_STORE);
	mdep_string(w->currx,w->curry,str);
}

void
v_echar(Kwind *w)
{
	my_plotmode(P_CLEAR);
	mdep_boxfill(w->currx,w->curry,w->currx+v_colsize(),w->curry+v_rowsize()-1);
	my_plotmode(P_STORE);
}

void
v_textdo(Kwind *w,int butt,int x,int y)
{
	dummyusage(butt);
	(void) textscrollupdate(w,x,y);
}

void
v_texttobottom(Kwind *w)
{
	int newtop = v_linenorm(w,w->lastused+w->disprows-1);
	if ( newtop != w->toplnum )  {
		w->toplnum = newtop;
		wredraw1(w);
	}
}

int
toplnum_decr(Kwind *w)
{
	int toplimit = v_linenorm(w,w->currlnum+w->disprows-1);
	if( w->toplnum != toplimit ) {
		w->toplnum = v_linenorm(w,w->toplnum-1);
		return 1;
	}
	else
		return 0;
}

int
toplnum_incr(Kwind *w)
{
	int toplimit = v_linenorm(w,w->currlnum-1);
	if( w->toplnum != toplimit ) {
		w->toplnum = v_linenorm(w,w->toplnum+1);
		return 1;
	}
	else
		return 0;
}

int
textscrollupdate(Kwind *w,int mx,int my)
{
	int newtop, wheight;

	if ( ! (mx > w->x0 && mx < w->tx0 ) ) {
		w->inscroll = 0;
		return 0;
	}

	wheight = w->y1 - w->y0;
	/* if we just moved into the scroll bar... */
	if ( ! w->inscroll ) {
		w->inscroll = 1;
		if ( *Menujump ) {
			int barheight, scrdy;
			/* The first time you go into the scroll */
			/* bar, it attempts to center the scroll bar */
			/* on the current mouse position. */
			barheight = (wheight*w->disprows)/w->numlines;
			scrdy = (wheight-barheight)/(w->numlines-w->disprows);
			if ( scrdy <= 0 )
				scrdy = 1;
			newtop = ( my - w->y0 - barheight/2) / scrdy;
			newtop = boundit(newtop,0,w->numlines-w->disprows);
			if ( newtop != w->toplnum ) {
				w->toplnum = newtop;
				wredraw1(w);
			}
		}
		w->lasty = my;
	}
	else {
		int sz, dm, chgtop;
		int changed = 0;

		sz = (wheight/(3*w->numlines/2));
		if ( sz <= 0 )
			sz = 1;
		dm = (my - w->lasty);
		chgtop = -dm / sz;
		if ( chgtop < 0 ) {
			while ( chgtop++ < 0 && toplnum_decr(w) )
				changed = 1;
		}
		else if ( chgtop > 0 ) {
			while ( chgtop-- > 0 && toplnum_incr(w) )
				changed = 1;
		}
		if ( changed ) {
			wredraw1(w);
			w->lasty = my;
		}
	}
	return 1;
}

void
v_scrolldisplay(Kwind *w)
{
	int ysize = v_rowsize();
	int wid, hgt, x, y;

	my_plotmode(P_STORE);

	x = columnx(w,0);
	y = rowy(w,0);
	hgt = rowy(w,w->disprows-1) - y;
	wid = w->x1 - 1 - x;

	if ( hgt > 0 ) {
#ifdef MOVEBITMAP
		mdep_movebitmap(x,y+ysize,wid,hgt,x,y);
#else
		Tmap = v_reallocbitmap(wid, hgt,Tmap);
		mdep_pullbitmap(x,y+ysize,Tmap);
		mdep_putbitmap(x,y,Tmap);
#endif
	}

	/* erase last row */
	my_plotmode(P_CLEAR);
	mdep_boxfill(x,y+hgt,x+wid,w->y1-1);
	mdep_sync();
}

void
v_scrollbuff(Kwind *w)
{
	char *p;

	w->toplnum = v_linenorm(w,w->toplnum-1);
	p = w->bufflines[w->currlnum];
	if ( p != w->currline )
		eprint("Hey, p!=w->currline!?\n");
	
	w->bufflines[w->currlnum] = uniqstr(p);
	w->currlnum = v_linenorm(w,w->currlnum-1);
	w->lastused = w->currlnum;
	w->bufflines[w->currlnum] = w->currline;
	*(w->currline) = '\0';
}

void
drawtextbar(Kwind *w)
{
	int y0, y1, by0, by1, dy, realtop, realbottom;

	y0 = w->y0 + 1;
	y1 = w->y1 - 1;
	dy = y1 - y0;
	realtop = w->toplnum - w->lastused;
	if ( realtop < 0 )
		realtop += w->numlines;
	realbottom = realtop - w->disprows + 1;
	by0 = y1 - (dy*realtop)/(w->numlines-1);
	by1 = y1 - (dy*realbottom)/(w->numlines-1);
	mdep_boxfill(w->x0+4,by0,w->tx0-6,by1);
}

void
redrawtext(Kwind *w)
{
	char str[2];
	int x, y, i, n;

	my_plotmode(P_STORE);
	drawtextbar(w);

	/* the line separating scroll bar and text */
	mdep_line(w->tx0-2,w->y0+1,w->tx0-2,w->y1-1);

	x = columnx(w,0);
	y = rowy(w,0);
	i = w->toplnum;
	for ( n=0; n<w->disprows; n++ ) {
		char *p = w->bufflines[i];
		if ( p ) {
			int lng;
			lng = (int)strlen(p);
			if ( lng <= w->currcols )
				mdep_string(x,y,p);
			else {
				strncpy(Msg1,p,w->currcols);
				Msg1[w->currcols] = '\0';
				mdep_string(x,y,Msg1);
			}
		}
		if ( --i < 0 )
			i = w->numlines-1;
		y += v_rowsize();
	}
	/* draw text cursor (typically an underline) */
	v_setxy(w);
	str[0] = Curschar;
	str[1] = '\0';
	mdep_string(w->currx,w->curry,str);
}
