/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */
#define OVERLAY4

#include "key.h"

#ifndef MOVEBITMAP
Pbitmap Tmap = EMPTYBITMAP;
#endif

Symlongp Textscrollgutter;

#define Curschar '_' /* 0x7f would be a small square */
char cursor_str[2] = { Curschar, '\0' };

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
	char *oldcurrline;
	int n;

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
		if ( new_tcols > w->currlinelen ) {
			/* need to realloc currline larger; then find
			 * currline in bufflines and point to realloced buffer */
			oldcurrline = w->currline;
			w->currline = krealloc(w->currline, new_tcols + 1, "v_settextsize");
			for (n=0; n<w->numlines; ++n) {
				if ( w->bufflines[n] == oldcurrline ) {
					w->bufflines[n] = w->currline;
					break;
				}
			}
			if ( n == w->numlines ) {
				eprint("%s: did not find currline in bufflines!?\n");
			}
		}
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

	v_textcursor(w, 0); 	/* erase the cursor (assumes Tx,Ty is in right place) */
	while ( (c=(*s++)) != '\0' ) {

		if ( c == '\b' || c == Erasechar) {
			if ( w->currcol > 0 ) {
				w->currcol--;
				v_setxy(w);
				*ptbuffer(w,w->currcol) = '\0';
				v_textcursor(w, 0);
				
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
					/* v_scrolldisplay drew the text,
					 * draw the text scrollbar */
					drawtextbar(w);
				}
			}
		}
		v_setxy(w);
	}
	/* show the cursor after the last character */
	v_textcursor(w, 1);
}

/* Draw (or erase) text cursor - if its visible */
void
v_textcursor(Kwind *w, int drawit)
{
	if ( drawit != 0 ) {
		int dl;
		dl = w->toplnum - w->currlnum;
		if (dl < 0) {
			dl += w->numlines;
		}
		if (dl < w->disprows) {
			my_plotmode(P_STORE);
			mdep_string(w->currx,w->curry,cursor_str);
		}
	}
	else {
		my_plotmode(P_CLEAR);
		mdep_boxfill(w->currx,w->curry,w->currx+v_colsize(),w->curry+v_rowsize()-1);
	}
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
	int newtop, barheight, numofftop, dy, y0;
	int gutter = *Textscrollgutter;

	if ( ! (mx > w->x0 && mx < w->tx0 ) ) {
		w->inscroll = 0;
		return 0;
	}

	/* Cap scrollgutter to leave at least one pixel for scrollbar */
	dy = w->y1 - w->y0 - 2; /* Max vertical extent of scrollbar w/o gutter */
	if ( dy < (2 * gutter + 1) ) {
		gutter = (dy - 1) / 2;
	}
	y0 = w->y0 + (2 * gutter);
	dy = (w->y1 - (2 * gutter)) - y0;

	if (w->disprows >= w->nactive ) {
		/* Display holds all of content; can't scroll... */
		return 1;
	}

	/* Display holds a portion of the text, ratio of disprows/nactive;
	 * calculate barheight as that ratio of dy. */
	barheight = (dy * w->disprows) / w->nactive;

	/* bar bumps into top/bottom of scrollbar; range of bar
	 * placement is w->y0+barheight/2 to w->y1-barheight/2.
	 * numofftop can range from 0 to nactive - disprows.
	 * Note: when interpolating, output range goes to
	 *       nactive+disprows+1 to make number of steps
	 *       match number of non-visible rows. */
	numofftop = interpolate(my, y0+barheight/2, y0+dy-barheight/2, 0, w->nactive-w->disprows + 1);
	numofftop = boundit(numofftop, 0, w->nactive-w->disprows);

	/* Top of buffer is currlnum + (nactive-1). */
	newtop = w->currlnum + (w->nactive - 1);
	newtop -= numofftop;
	while (newtop >= w->numlines) {
		newtop -= w->numlines;
	}
	while (newtop < 0) {
		newtop += w->numlines;
	}

	if (newtop != w->toplnum) {
		w->toplnum = newtop;
		wredraw1(w);
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
	char *p, *q;
	int len;

	w->toplnum = v_linenorm(w,w->toplnum-1);
	p = w->bufflines[w->currlnum];
	if ( p != w->currline ) {
		eprint("Hey, p!=w->currline!?\n");
	}
	
	/* Save off a copy of currline */
	len = strlen(p);
	q = kmalloc(len+1, "v_scrollbuf");
	strcpy(q, p);
	w->bufflines[w->currlnum] = q;
	w->currlnum = v_linenorm(w,w->currlnum-1);
	w->lastused = w->currlnum;
	if ( w->bufflines[w->currlnum] != NULL ) {
		/* Free content of console line to be overwritten */
		kfree(w->bufflines[w->currlnum]);
	}
	else {
		w->nactive++;
	}
	w->bufflines[w->currlnum] = w->currline;
	*(w->currline) = '\0';
}

void
drawtextbar(Kwind *w)
{
	int y0, dy, barheight, result;
	int numofftop = -1;
	int by0, by1;
	int gutter = *Textscrollgutter;

	/* Cap scrollgutter to leave at least one pixel for scrollbar */
	dy = w->y1 - w->y0 - 2; /* Max vertical extent of scrollbar w/o gutter */
	if ( dy < (2 * gutter + 1) ) {
		gutter = (dy - 1) / 2;
	}
	y0 = w->y0 + (2 * gutter);
	dy = (w->y1 - (2 * gutter)) - y0;
		

	/* Erase where scrollbar could be */
	my_plotmode(P_CLEAR);
	mdep_boxfill(w->x0+4,w->y0+1,w->tx0-6,w->y1-1);	
	
	
	/* Ratio of scrollbar height is number of displayed lines divided
	 * by number of lines in bufflines */
	if (w->disprows >= w->nactive) {
		barheight = dy;
		result = 0;
	}
	else {
		barheight = (dy * w->disprows) / w->nactive;
		/* Given:
		 * toplnum => bufflines index of top visible row
		 * disprows => number of visible rows
		 * nactive => number of active lines
		 * currlnum => buffline index of active line(bottom):
		 * 1) Number of rows off top is number of active lines
		 * minus the difference between toplnum and currlnum.
		 * 2) Number of rows off top is in range
		 *    of 0 .. (number of active rows - disprows)
		 */

		numofftop = (w->nactive -1) - (w->toplnum - w->currlnum);
		numofftop = v_linenorm(w, numofftop);

		/* scale numofftop into range of 0 .. dy - barheight */
		result = interpolate(numofftop, 0, w->nactive - w->disprows, 0, dy - barheight);

		/* Clamp result to possible range */
		result = boundit(result, 0, dy - barheight);
	}
	by0 = result + y0;
	by1 = by0 + barheight;
	mdep_plotmode(P_STORE);
	mdep_boxfill(w->x0+4,by0,w->tx0-6,by1);	
}

void
redrawtext(Kwind *w)
{
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
	/* show text cursor (typically an underline) */
	v_setxy(w);
	v_textcursor(w, 1);
}
