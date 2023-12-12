/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */
#define OVERLAY4

#include "key.h"
#include "keymidi.h"

Symlongp Mousebutt;
Symlongp Sweepquant, Menuymargin;
Symlongp Rtmouse;
Symlongp Dragquant;
Symlongp Keyinverse, Panraster;
Symlongp Bendrange, Bendoffset, Showtext, Showbar;
Symlongp Volstem, Volstemsize, Colors, Colornotes;
Symlongp Inverse, Menusize, Menujump, Menuscrollwidth, Menusize;
Symlongp Textscrollsize;

int Pmode = -1;
int Backcolor = 0;
int Forecolor = 1;
int Pickcolor = 2;
int Lightcolor = 3;
int Darkcolor = 4;
int ButtonBGcolor = 5;

Kwind *Wroot = NULL;	/* root window */
#ifdef OLDSTUFF
Kwind *Wcons = NULL;	/* text (console) window */
#endif
Kwind *Wprintf = NULL;

/* These are used by the SHOWXSTART and SHOWYHIGH macros */
long Lastst = -1;
int Lastxs;
long Lastsh = -1;
int Lastys;

/*
 * The values here are the heights of the vertical
 * lines that are drawn when controller and sysex notes are seen.
 */
#define OFFVAL 10
#define ONVAL 20
#define SYSEXVAL 30

void
nonnotesize(Noteptr n,int *apitch1,int *apitch2)
{
	static char str[32];
	Unchar* bp = ptrtobyte(n,0);
	int b1, b2, b3;
	int type1;
	char *s = NULL;
	int p1, p2;

	b1 = *bp++;
	b2 = *bp++;
	b3 = *bp;
	type1 = b1 & 0xf0;

	p1 = 0;
	p2 = 127;
	switch ( type1 ) {
	case BEGINSYSEX:
		p1 = 64;
		p2 = 65;
		break;
	case PRESSURE:
		p2 = b3;
		break;
	case CONTROLLER:
		switch ( b2 ) {
		case 0x40:	/* sustain switch */
			if ( b3 > 0 )
				p2 = ONVAL;
			else
				p2 = OFFVAL;
			s = "sust";
			break;
		case 0x41:	/* portamento switch */
			if ( b3 > 0 )
				p2 = ONVAL;
			else
				p2 = OFFVAL;
			s = "port";
			break;
#ifdef OLDSTUFF
		case 0x1:	/* modulation wheel */
		case 0x2:	/* breath control */
		case 0x4:	/* foot control */
		case 0x5:	/* portamento time */
		case 0x7:	/* volume */
			p2 = b3;
			break;
#endif
		default:
			p2 = b3;
			break;
		}
		break;
	case PROGRAM:
		sprintf(s=str,"prog=%d",b2);
		p2 = ONVAL;
		break;
	case CHANPRESSURE:
		p2 = b2;
		break;
	case PITCHBEND:
		p2 = ((b3<<7) | b2) - 0x2000;
		p2 /= (*Bendrange)/128;
		p1 = *Bendoffset;
		p2 = *Bendoffset + p2;
		if ( p1 > p2 ) {
			int t = p1;
			p1 = p2;
			p2 = t;
		}
		break;
	default:
		break;
	}
	*apitch1 = p1;
	*apitch2 = p2;
}

#ifdef KEY_GRAPHICS

void
startgraphics(void)
{
	char *err;

	if ( mdep_startgraphics(Argc,Argv) )
		mdep_popup("Can't initialize graphics?!");
	err = mdep_fontinit(*Fontname);
	if ( err )
		mdep_popup(err);
	if ( *Colors < 5 ) {
		sprintf(Msg1,"Hey, there aren't enough colors, trouble!!  Colors=%ld",*Colors);
		mdep_popup(Msg1);
	}
	else
		mdep_initcolors();
	mdep_setcursor(M_ARROW);
	m_init();
	reinitwinds();
	wredraw1(Wroot);
}

void
my_plotmode(int m)
{
	Pmode = m;
	mdep_plotmode(m);
}

void
showsane(Kwind *w)
{
	switch (w->type) {
	case WIND_MENU:
		menucalcxy(w);
		break;
	case WIND_PHRASE:
		if ( w->showlow < 0 )
			w->showlow = 0;
		else if ( w->showlow > 127 )
			w->showlow = 127;
	
		if ( w->showhigh < 0 )
			w->showhigh = 0;
		else if ( w->showhigh > 127 )
			w->showhigh = 127;
	
		if ( w->showlow > w->showhigh ) {
			int t = w->showlow;
			w->showlow = w->showhigh;
			w->showhigh = t;
		}
	
		if ( w->showlow == w->showhigh ) {
			if ( w->showlow > 0 )
				(w->showlow)--;
			else
				(w->showhigh)++;
		}
		if ( w->showleng <= 0 )
			w->showleng = *Clicks;
		break;
	}
}

void
redrawpwind(Kwind *w)
{
	if ( (intptr_t)(*(w->pph)) < 1000 ) {
		execerror("Internal error, redrawpwind (trk=%s) has bad phrase!?\n",w->trk);
	}
	drawph(w,*(w->pph));
	my_plotmode(P_STORE);
	mdep_box(w->x0,w->y0,w->x1,w->y1);
	drawbars(w,w->x0+1,w->y0+1,w->x1-1,w->y1-1);
}

/* draw measure bars.  If lev==1, draw labels, too */
void
drawbars(Kwind *w,int sx,int sy,int ex,int ey)
{
	long click, eclick, mod;
	int x0, lastx;
	int min_dx = (int)(*Minbardx);

	if ( w->showbar == 0 )
		return;
	mdep_color(Lightcolor);
	my_plotmode(P_STORE);

	/* figure out where the first bar goes (and purposely don't draw */	
	/* one on the left edge of the display, ie. when mod == 0) */
	mod = (w->showstart) % (w->showbar);

	click = (w->showstart)-mod;
	eclick = (w->showstart) + (w->showleng);

	lastx = -9999;
	for ( ; click<eclick; click += w->showbar ) {
		x0 = clktox(click);
		if ( x0 < sx || x0 > ex )
			continue;
		if ( (x0-lastx) < min_dx )
			continue;
		mdep_line(x0,sy,x0,ey);
		lastx = x0;
	}
	mdep_color(Forecolor);
}

void
centertext(char *s,int x,int y)
{
	x = x-((int)(strlen(s))*mdep_fontwidth())/2;
	y = y-mdep_fontheight()/2;
	if ( x >= 0 && y >= 0 )
		mdep_string(x,y,s);
}

void
righttext(char *s,int x,int y)
{
	mdep_string(x+mdep_fontwidth()/2,y,s);
}

/* make sure a phrase is free to be modified */
void
gridphresh(Phrasepp aph)
{
	(*aph)->p_used += (*aph)->p_tobe;
	(*aph)->p_tobe = 0;
	if ( (*aph)->p_used > 1 ) {
		Phrasep oldp = *aph;
		phdecruse(oldp);
		*aph = newph(1);
		phcopy(*aph,oldp);
	}
}

int
windorigx(Kwind *w)
{
	int x;

	x = w->x0+1;

#ifdef OLDKEYBOARDSTUFF
	if ( *Keyboard )
		x = w->x0+8*mdep_fontwidth();
#endif

	return x;
}

void
drawph(Kwind *w,Phrasep p)
{
	drawclipped(w,p,w->showstart,w->showstart+w->showleng,
		w->showlow,w->showhigh,
		w->x0+1,w->y0+1,w->x1-1,w->y1-1);
}

int chancolors[16];

void
setupchancolors()
{
	int ch;
	Symbolp s;
	Datum d;
	int color;

	for ( ch=0; ch<16; ch++ ) {
		s = arraysym(*Chancolormap,numdatum(ch+1),H_LOOK);
		if ( s == NULL ) {
			eprint("Chancolormap doesn't value for ch=%d\n",ch+1);
			chancolors[ch] = 1;
			continue;
		}
		d = *symdataptr(s);
		color = (int)roundval(d);
		chancolors[ch] = color;
	}
}

void
drawclipped(Kwind *w,Phrasep p,long sclicks,long eclicks,int spitch,int epitch,int sx,int sy,int ex,int ey)
{
	int x1, y1, x2, y2;
	Noteptr n;
	int pitch;
	long lasts = MAXCLICKS, laste = MAXCLICKS;
	int yhigh, lastx1=0, lastx2=0, denom, isnote;
	long s, e;
	long ndrawn = 0;
	Krect cliprect;
	int dochancolors = 0;
	int color;
	int f;

	/* If Chancolormap array is not empty, get the channel colors */
	if ( *Chancolors != 0 ) {
		dochancolors = 1;
		setupchancolors();
	}

	cliprect = makerect(sx,sy,ex,ey);

	if ( p == NULL )
		return;

	/* removal of loop constants in computation of y values */
	yhigh = Disporigy + SHOWYHIGH;
	denom = w->showhigh - w->showlow;
	if ( denom == 0 )
		return;

	setnotecolor((Noteptr)NULL,-1);

	for ( n=firstnote(p); n!=NULL ; n=nextnote(n)) {

		f = flagsof(n) & FLG_PICK;

		isnote = ntisnote(n);

		e = endof(n);
		s = timeof(n);
		if ( isnote != 0 && e < sclicks && s < sclicks )
			continue;
		if ( s > eclicks )
			break;	/* assumption that notes are sorted by time */

		/* because this is done a lot, code below is essentially an */
		/* in-line expansion of drawnt() and ntbox().  Can you say */
		/* premature optimization?  */

		/* avoid using clktox if possible */
		if ( s != lasts ) {
			x1 = lastx1 = clktox(s);
			lasts = s;
		}
		else
			x1 = lastx1;

		if ( e != laste ) {
			x2 = lastx2 = clktox(e);
			laste = e;
		}
		else
			x2 = lastx2;

		if ( dochancolors ) {
			// %16 to be robust
			color = chancolors[chanof(n) % 16]; 
		} else {
			color = -1;
		}

		if ( ! isnote ) {
			if ( x1 > ex || x1 < sx )
				continue;

			/* channel color if unpicked, otherwise pick color */
			if ( dochancolors == 1 && f == 0 )
				setnotecolor(n,color);
			else
				setnotecolor(n,-1);

			drawnonnt(w,n,&cliprect);
			continue;
		}

		/* a normal note */
		pitch = pitchof(n);
		if ( pitch < spitch || pitch > epitch )
			continue;
		y1 = yhigh - (int)(((long)pitch*Dispdy)/denom);
		y2 = yhigh - (int)(((long)(pitch-1)*Dispdy)/denom);

		if ( y2 > y1 )
			y2--;

		if ( x2 > x1 ) {
			if ( --x2 > x1 )
				--x2;
		}

		if ( x1 > ex || x2 < sx )
			continue;
		if ( y1 > ey || y2 < sy )
			continue;
		if ( x1 < sx )
			x1 = sx;
		if ( y1 < sy )
			y1 = sy;
		if ( x2 > ex )
			x2 = ex;
		if ( y2 > ey )
			y2 = ey;

		/* channel color if unpicked, otherwise pick color */
		if ( dochancolors == 1 && f == 0 )
			setnotecolor(n,color);
		else
			setnotecolor(n,-1);

		mdep_boxfill(x1,y1,x2,y2);
		if ( *Volstem ) {
			y1 = pitchtoy(w,(int)pitchof(n));
			y2 = pitchtoy(w,(int)pitchof(n)+(int)(*Volstemsize));
			y2 = y1 - (y1-y2)*(int)volof(n)/128;
			mdep_line(x1,y1,x1,y2);
		}
		if ( ndrawn++ > *Drawcount ) {
			ndrawn = 0;
			chkinput();
			chkoutput();
		}
	}
	if ( *Colornotes )
		mdep_color(Forecolor);
}

void
setnotecolor(Noteptr n, int color)
{
	static int lastc = -1;
	int c, f;

	if ( n == NULL ) {
		lastc = -1;
		return;
	}
	f = flagsof(n);
	if ( color < 0 ) {
		if ( (f & FLG_PICK) != 0 && Pmode!=P_CLEAR )
			c = Pickcolor;
		else
			c = Forecolor;
	} else {
		c = color;
	}
	if ( c != lastc ) {
		mdep_color(lastc=c);
	}
}

Noteptr
closestnt(Kwind *w,Phrasep ph,int x,int y)
{
	int x1, y1, x2, y2, nx, ny, dx, dy;
	Noteptr n, closn;
	int dist, closdist;
	Krect cliprect;

	closdist = -1;
	closn = NULL;
	cliprect = makerect(Disporigx,Disporigy,Dispcornx,Dispcorny);
	for ( n=firstnote(ph); n!=NULL; n=nextnote(n) ) {
		if ( ntbox(w,n,&x1,&y1,&x2,&y2,&cliprect) == NT_INVISIBLE )
			continue;
		if ( ntisnote(n) ) {
			/* for non-notes, we use the beginning of the note */
			nx = x1;
			ny = (y1+y2)/2;
		}
		else {
			/* for non-notes, we use the top of its line */
			nx = (x1+x2)/2;
			ny = y1;
		}
		/* dist = (int)(sqrt((nx-x)*(nx-x)+(ny-y)*(ny-y))); */
		dx = nx - x;
		dy = ny - y;
		dist = (dx>0?dx:-dx) + (dy>0?dy:-dy);
		if ( closdist < 0 || dist < closdist ) {
			closn = n;
			closdist = dist;
		}
	}
	return closn;
}

#ifdef DRAWNT_NO_LONGER_USED
void
drawnt(Kwind *w,Noteptr n)
{
	int x1, y1, x2, y2;
	Krect cliprect;

	cliprect = makerect(Disporigx,Disporigy,Dispcornx,Dispcorny);
	if ( ntbox(w,n,&x1,&y1,&x2,&y2,&cliprect) == NT_INVISIBLE )
		return;
	if ( *Colornotes )
		setnotecolor(n,-1);
	if ( ! ntisnote(n) )
		drawnonnt(w,n,&cliprect);
	else {
		mdep_boxfill(x1,y1,x2,y2);
		if ( *Volstem ) {
			y1 = pitchtoy(w,(int)pitchof(n));
			y2 = pitchtoy(w,(int)pitchof(n)+(int)(*Volstemsize));
			y2 = y1 - (y1-y2)*(int)volof(n)/128;
			mdep_line(x1,y1,x1,y2);
		}
	}
}
#endif

void
drawnonnt(Kwind *w,Noteptr n,Krect *r)
{
	int x1, y1, x2, y2;
	char *s;

	if ( (s=textnoteinfo(w,n,&x1,&y1,&x2,&y2)) != NULL ) {
		int r1, r2;

		if ( ! *Showtext )
			return;
		r1 = dispclip(w,&x1,&y1,r);
		r2 = dispclip(w,&x2,&y2,r);
		if ( r1==NT_INVISIBLE && r2==NT_INVISIBLE ) {
			return;
		}
		mdep_box(x1,y1,x2,y2);
		kwindtext(s,x1,y1,x2,y2,TEXT_CENTER);
		/* mdep_line(x,y1,x,y2); */
	}
	else {
		x1 = clktox(timeof(n));
		(void) nonnoteinfo(w,n,&y1,&y2);
		mdep_line(x1,y1,x1,y2);
	}
}

char *
nonnoteinfo(Kwind *w,Noteptr n,int *ay1,int *ay2)
{
	static char str[32];
	Unchar* bp = ptrtobyte(n,0);
	int b1, b2, b3;
	int type1;
	char *s = NULL;
	int v = 0;
	int off = 0;
	int dy = Dispcorny-Disporigy;

	b1 = *bp++;
	b2 = *bp++;
	b3 = *bp;
	type1 = b1 & 0xf0;

	switch ( type1 ) {
	case PRESSURE:
		v = b3;
		break;
	case CONTROLLER:
		switch ( b2 ) {
		case 0x40:	/* sustain switch */
			if ( b3 > 0 )
				v = ONVAL;
			else
				v = OFFVAL;
			s = "sust";
			break;
		case 0x41:	/* portamento switch */
			if ( b3 > 0 )
				v = ONVAL;
			else
				v = OFFVAL;
			s = "port";
			break;
#ifdef OLDSTUFF
		case 0x1:	/* modulation wheel */
		case 0x2:	/* breath control */
		case 0x4:	/* foot control */
		case 0x5:	/* portamento time */
		case 0x7:	/* volume */
			v = b3;
			break;
#endif
		default:
			v = b3;
			break;
		}
		break;
	case PROGRAM:
		sprintf(s=str,"prog=%d",b2);
		v = ONVAL;
		break;
	case CHANPRESSURE:
		v = b2;
		break;
	case PITCHBEND:
		v = ((b3<<7) | b2) - 0x2000;
		v /= (*Bendrange)/128;
		off = *Bendoffset;
		break;
	case SYSTEMMESSAGE:
		v = SYSEXVAL;
		break;
	default:
		break;
	}
	*ay2 = Dispcorny - (dy*off)/128;
	*ay1 = *ay2 - (dy*v)/128;
	*ay1 = boundit(*ay1,Disporigy,Dispcorny);

	if ( *ay1 > *ay2 ) {
		int t = *ay1;
		*ay1 = *ay2;
		*ay2 = t;
	}
	return s;
}

char *
textnoteinfo(Kwind *w,Noteptr n,int *ax1, int *ay1, int *ax2, int *ay2)
{
#define MAXTEXTSIZE 256
	static char str[MAXTEXTSIZE+2];
	int b1, b2, b3, i, c, ymid;
	char *s, *pp = NULL;
	Unchar* bp;
	int theight;
	int nbytes = ntbytesleng(n);

	if ( nbytes < 5 )
		return NULL;

	bp = ptrtobyte(n,0);
	b1 = *bp++;
	b2 = *bp++;
	b3 = *bp++;

	if ( ! ((b1&0xf0) == BEGINSYSEX && b2 == 0 && b3 == 0x7f) )
		return NULL;

	s = str;
	if ( nbytes > MAXTEXTSIZE )
		nbytes = MAXTEXTSIZE;
	for ( i=3; i<nbytes; i++ ) {
		c = *bp++;
		if ( c == 0xf7 )
			break;
		if ( c == '#' && pp == NULL )
			pp = s;
		*s++ = c;
	}
	*s = '\0';

	if ( pp == NULL )
		pp = str;
	if ( strncmp(pp,"#label=",7)==0 ) {
		char *p;
		pp += 7;
		if ( (p=strchr(pp,':')) != NULL )
			*p = 0;
	}

	*ax1 = clktox(timeof(n));
	*ax2 = *ax1 + ((long)strlen(pp)+1) * mdep_fontwidth();

	ymid = (Disporigy+Dispcorny)/2;
	theight = mdep_fontheight();
	*ay1 = ymid - (theight/2);
	*ay2 = *ay1 + theight;

	*ay1 = boundit(*ay1,Disporigy,Dispcorny);
	*ay2 = boundit(*ay2,Disporigy,Dispcorny);

	return pp;
}

/* returns NT_VISIBLE, NT_INVISIBLE, NT_CLIPPED */
int
ntbox(Kwind *w,Noteptr n,int *ax0,int *ay0,int *ax1,int *ay1,Krect *r)
{
	int r1, r2;
	int pitch;

	*ax0 = clktox(timeof(n));
	*ax1 = clktox((long)(endof(n)));
	if ( ! ntisnote(n) ) {
		if ( textnoteinfo(w,n,ax0,ay0,ax1,ay1) != NULL ) {
			if ( ! *Showtext )
				return NT_INVISIBLE;
			goto gotabox;
		}

		(void) nonnoteinfo(w,n,ay0,ay1);
		if ( *ax0 < r->x0 || *ax1 > r->x1 )
			return NT_INVISIBLE;
		else
			return NT_VISIBLE;
	}

	pitch = pitchof(n);
	*ay0 = pitchtoy(w,pitch);
	*ay1 = pitchtoy(w,pitch-1);
	if ( *ay1 > *ay0 )
		(*ay1)--;

	/* The end of the note should ideally be 2 pixels in from the start */
	/* of the ending click, so that there's space inbetween it and any */
	/* note that's directly abutted. */
	if ( *ax1 > *ax0 ) {
		if ( --(*ax1) > *ax0 )
			--(*ax1);
	}
    gotabox:
	r1 = dispclip(w,ax0,ay0,r);
	r2 = dispclip(w,ax1,ay1,r);
	if ( r1==NT_INVISIBLE && r2==NT_INVISIBLE )
		return(NT_INVISIBLE);
	if ( r1==NT_INVISIBLE || r2==NT_INVISIBLE )
		return(NT_CLIPPED);
	return(NT_VISIBLE);
}

#define ISLEFT          01
#define ISRIGHT         02
#define ISBOTTOM        04
#define ISATOP           010

int
clipcode(Kwind *w,int x,int y,Krect *r)
{
        int rc = 0;

        dummyusage(w);
        if(x < r->x0)
                rc |= ISLEFT;
        else if(x > r->x1)
                rc |= ISRIGHT;
        if(y < r->y0)
                rc |= ISATOP;
        else if(y > r->y1)
                rc |= ISBOTTOM;
        return(rc);
}

int
fullclipit(Kwind *w,int *x1,int *y1,int *x2,int *y2,Krect *r)
{
        int c1, c2, c, clipped;
        int xa = *x1, xb = *x2, ya = *y1, yb = *y2;
        int x=0, y=0;

        c1 = clipcode(w,xa, ya,r);
        c2 = clipcode(w,xb, yb,r);

        clipped = (c1 || c2 ? 1 : 0);

        while(c1 || c2) {
                if(c1 & c2)             /* formerly && */
                        return(NT_INVISIBLE); /* does not intersect window */
                c = c1;
                if(c == 0)
                        c = c2;
                if(c & ISLEFT) { /* push toward left edge */
                        y = ya + (yb - ya)*(r->x0 - xa)/(xb - xa);
                        x = r->x0;
                } else if(c & ISRIGHT) { /*  push toward right edge */
                        y = ya + (yb - ya)*(r->x1 - xa)/(xb - xa);
                        x = r->x1;
                }
                if(c & ISBOTTOM) { /*  push toward bottom edge */
                        x = xa + (xb - xa)*(r->y1 - ya)/(yb - ya);
                        y = r->y1;
                } else if(c & ISATOP) { /*  push toward top edge */
                        x = xa + (xb - xa)*(r->y0 - ya) / (yb - ya);
                        y = r->y0;
                }
                if(c == c1) {
                        xa = x;
                        ya = y;
                        c1 = clipcode(w,x, y,r);
                }
                else {
                        xb = x;
                        yb = y;
                        c2 = clipcode(w,x, y,r);
                }
        }
        *x1 = xa;
        *x2 = xb;
        *y1 = ya;
        *y2 = yb;

        return(clipped ? NT_CLIPPED : NT_VISIBLE);
}

/* Similar to fullclipit, but designed for boxes, which don't want the */
/* the intersection points to be interpolated. */
int
rectclipit(Kwind *w,int *x1,int *y1,int *x2,int *y2,Krect *r)
{
        int c1, c2, c, clipped;
        int xa = *x1, xb = *x2, ya = *y1, yb = *y2;
        int x, y;

        c1 = clipcode(w,xa, ya,r);
        c2 = clipcode(w,xb, yb,r);

        clipped = (c1 || c2 ? 1 : 0);

        while(c1 || c2) {
                if(c1 & c2)             /* formerly && */
                        return(NT_INVISIBLE); /* does not intersect window */
		c = c1;
		if ( c ) {
			c = c1;
			x = xa;
			y = ya;
		}
		else {
                        c = c2;
			x = xb;
			y = yb;
		}
                if(c & ISLEFT) { /* push toward left edge */
                        x = r->x0;
                } else if(c & ISRIGHT) { /*  push toward right edge */
                        x = r->x1;
                }
                if(c & ISBOTTOM) { /*  push toward bottom edge */
                        y = r->y1;
                } else if(c & ISATOP) { /*  push toward top edge */
                        y = r->y0;
                }
                if(c == c1) {
                        xa = x;
                        ya = y;
                        c1 = clipcode(w,x, y,r);
                }
                else {
                        xb = x;
                        yb = y;
                        c2 = clipcode(w,x, y,r);
                }
        }
        *x1 = xa;
        *x2 = xb;
        *y1 = ya;
        *y2 = yb;

        return(clipped ? NT_CLIPPED : NT_VISIBLE);
}

void
gridline(Kwind *w,long clks1,int pitch1,long clks2,int pitch2)
{
	int x1, y1, x2, y2;
	Krect cliprect;

	x1 = clktox(clks1);
	y1 = pitchtoy(w,pitch1);
	x2 = clktox(clks2);
	y2 = pitchtoy(w,pitch2);
	cliprect = makerect(Disporigx,Disporigy,Dispcornx,Dispcorny);
	if ( fullclipit(w,&x1,&y1,&x2,&y2,&cliprect) != NT_INVISIBLE ) {
		mdep_color(Forecolor);
		mdep_line( x1,y1,x2,y2);
	}
}

void
gridtext(Kwind *w,long clks1,int pitch1,char *str)
{
	int x1, y1;

	x1 = clktox(clks1);
	y1 = pitchtoy(w,pitch1);
	mdep_string(x1+mdep_fontwidth()/2,y1-mdep_fontheight()/2, str);
}

int
dispclip(Kwind *w,int *ax,int *ay,Krect *kr)
{
	int r = NT_VISIBLE;

    dummyusage(w);
	if ( *ax < kr->x0 ) {
		r = NT_INVISIBLE;
		*ax = kr->x0;
	}
	else if ( *ax > kr->x1) {
		r = NT_INVISIBLE;
		*ax = kr->x1;
	}

	if ( *ay < kr->y0) {
		r = NT_INVISIBLE;
		*ay = kr->y0;
	}
	else if ( *ay > kr->y1) {
		r = NT_INVISIBLE;
		*ay = kr->y1;
	}
	return(r);
}
#endif

/* quantize a value according to q */
long
longquant(long v,long q)
{
	long rem;

	if ( q <= 0 )
		q = 1;
	if ( v < 0 ) {
		rem = -v % q;
		if ( (rem*2) > q )
			v -= (q-rem);
		else
			v += rem;
	}
	else {
		rem = v % q;
		if ( (rem*2) > q )
			v += (q-rem);
		else
			v -= rem;
	}
	return v;
}


#ifdef KEY_GRAPHICS

int
pitchyraw(Kwind *w,int pitch)
{
	int denom = w->showhigh - w->showlow;
	return denom==0 ? 0 : (int)(((long)pitch*(long)Dispdy)/denom);
}

int
pitchtoy(Kwind *w,int pitch)
{
	return Disporigy + SHOWYHIGH - pitchyraw(w,pitch);
}

void
xytogrid(Kwind *w,long x,long y,long *aclick,long *apitch,long quant)
{
	int shigh = w->showhigh;
	int slow = w->showlow;
	int dp = shigh-slow;
	int tmpx, tmpy;
	int redo = 0;
	int ddy = Dispdy;
	int ddx = Dispdx;

	if ( ddy <= 0 )
		ddy = 1;
	if ( ddx <= 0 )
		ddx = 1;

	*aclick = (w->showstart) + ((long)(x-Disporigx) * (w->showleng)) / ddx;
	*apitch = shigh - ((long)(y-Disporigy) * dp) / ddy;

	/* the gyrations here are to guarantee that xytogrid is */
	/* an EXACT reversal to clktox and pitchtoy. No doubt there's */
	/* an easier way. */

	tmpx = clktox(*aclick);
	tmpy = pitchtoy(w,(int)(*apitch));

	if ( tmpy < y )
		(*apitch)--, redo=1;
	if ( tmpx < x )
		(*aclick)++, redo=1;
	if ( redo ) {
		tmpx = clktox(*aclick);
		tmpy = pitchtoy(w,(int)(*apitch));
		if ( tmpy > y )
			(*apitch)++;
		if ( tmpx > x )
			(*aclick)--;
	}

	if ( quant > 1 )
		*aclick = longquant(*aclick,(long)quant);
}

void
pharea(Phrasep ph,long *astart,long *aend,long *alow,long *ahigh)
{
	Noteptr n;
	long mintime=MAXCLICKS, maxtime= -MAXCLICKS;
	int minpitch = 129, maxpitch = -1;

	for ( n=firstnote(ph); n!=NULL; n=nextnote(n) ) {
		long t = timeof(n);
		long e = endof(n);
		if ( e > maxtime )
			maxtime = e;
		if ( t < mintime )
			mintime = t;
		if ( ntisnote(n) ) {
			int p = pitchof(n);
			if ( p > maxpitch )
				maxpitch = p;
			if ( p < minpitch )
				minpitch = p;
		}
	}
	*astart = mintime;
	*aend = maxtime;
	*ahigh = maxpitch;
	*alow = minpitch;
}

void
gridpan(Kwind *w,long cshift,int pshift)
{
	static Pbitmap panbits = EMPTYBITMAP;
	int fromx, tox, clrx, slow, shigh, xshift, yshift;
	int fromy, toy, clry, clrx2a, clrx2b;
	long sclicks, eclicks;	/* the area that will be repainted */
	int spitch, epitch;
	long sclick2, eclick2;

	if ( cshift == 0 && pshift == 0 )
		return;

	shigh = w->showhigh;
	slow = w->showlow;

	/* make sure pitches doesn't take us out of the 0-127 range */
	if ( pshift > 0 && (shigh+pshift)>127 )
		pshift = 127 - shigh;
	else if ( pshift < 0 && (slow+pshift)<0 )
		pshift = -slow;

	/* If we pan more than what we're currently showing, just redraw. */
	/* Also, the Panraster variable can be used to disable the use of */
	/* raster operations for panning, to save memory. */
	if ( *Panraster==0 || cshift >= w->showleng || -cshift >= w->showleng ) {
		w->showstart -= cshift;
		w->showhigh += pshift;
		w->showlow += pshift;
		wredraw1(w);
		return;
	}

	fromx = tox = Disporigx;
	sclick2 = w->showstart;
	eclick2 = w->showstart + w->showleng;
	clrx2a = Disporigx;
	clrx2b = Dispcornx;

	if ( cshift == 0 )
		xshift = 0;
	else
		xshift = SHOWXSTART - clktoxraw(w->showstart-cshift);

	if ( xshift < 0 ) {
		/* we're panning left */
		sclicks = w->showstart + w->showleng;
		eclicks = sclicks - cshift;/* cshift is negative */
		xshift = - xshift;
		fromx += xshift;
		clrx = Dispcornx - xshift;
		clrx2b = clrx-1;
		sclick2 += cshift;
	}
	else if ( xshift > 0 ) {
		/* panning right */
		eclicks = w->showstart;
		sclicks = w->showstart - cshift;
		tox += xshift;
		clrx = Disporigx;
		clrx2a = tox+1;
		eclick2 -= cshift;
	}
    else
    {
        eclicks = 0;
        sclicks = 0;
        clrx = 0;
    }

	toy = fromy = Disporigy;
	if ( pshift == 0 )
		yshift = 0;
	else if ( pshift < 0 ) {
		/* we're panning up */
		spitch = slow + pshift;
		epitch = slow;
		yshift = SHOWYHIGH - pitchyraw(w,shigh+pshift);
		fromy += yshift;
		clry = Dispcorny - yshift;
	}
	else {
		/* panning down */
		spitch = shigh;
		epitch = shigh + pshift;
		yshift = - SHOWYHIGH + pitchyraw(w,shigh+pshift);
		toy += yshift;
		clry = Disporigy;
	}

	/* pan by copying rasters screen-to-screen */

	panbits = v_reallocbitmap(Dispdx-xshift+1,Dispdy-yshift+1,panbits);
	mdep_pullbitmap(fromx,fromy,panbits);
	my_plotmode(P_STORE);
	mdep_putbitmap(tox,toy,panbits);

	/* erase the areas we need to redraw */

	my_plotmode(P_CLEAR);
	if ( cshift != 0 ) {
		mdep_boxfill(clrx,Disporigy,clrx+xshift,Dispcorny);
	}
	if ( pshift != 0 )
		mdep_boxfill(Disporigx,clry,Dispcornx,clry+yshift);

	w->showstart -= cshift;
	w->showlow += pshift;
	w->showhigh += pshift;

	/* redraw */
	my_plotmode(P_STORE);
	if ( cshift != 0 ) {
		drawclipped(w,*(w->pph),sclicks,eclicks,
				w->showlow,w->showhigh,
				clrx,Disporigy,clrx+xshift,Dispcorny);
		drawbars(w,clrx,Disporigy,clrx+xshift,Dispcorny);
	}
	if ( pshift != 0 ) {
		drawclipped(w,*(w->pph),sclick2,eclick2,
				spitch,epitch,
				clrx2a,clry,clrx2b,clry+yshift);
		drawbars(w,clrx2a,clry,clrx2b,clry+yshift);
	}
}

#endif

#ifdef OLDKEYBOARDSTUFF
		     /*   c c+  d d+  e  f f+  g g+  a a+  b    */
char Blackkeys[] = 	{ 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0 };
char Y1inc[] = 		{ 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0 };
char Y0inc[] =		{ 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1 };

void
drawkeyboard(Kwind *w,int erasefirst)
{
	int low = w->showlow;
	int high = w->showhigh;
	int dx = (w->dispx0 - w->x0)/10;
	int x0 = w->x0 + 2;
	int xb = x0 + dx*6;
	int xc = x0 + dx*4;
	int xtext = (xb + w->dispx0)/2;
	int p, cp, y0, y1, prevy, nexty, prevy1inc;
	int pblack = (*Keyinverse)? P_STORE : P_CLEAR;
	int pwhite = (*Keyinverse)? P_CLEAR : P_STORE;

	if ( erasefirst ) {
		my_plotmode(P_CLEAR);
		mdep_boxfill(x0,Disporigy,Disporigx-5,Dispcorny);
	}
	my_plotmode(pwhite);
	mdep_boxfill(x0,y0=pitchtoy(w,high),xb,y1=pitchtoy(w,low));
	my_plotmode(pblack);
	if ( *Keyinverse )
		mdep_line(xb,y0,xb,y1);
	prevy1inc = -1;
	for ( p=low+1; p<=high; p++ ) {
		y0 = pitchtoy(w,p-1);
		y1 = pitchtoy(w,p);
		cp = canonipitchof(p);
		if ( cp == 0 ) {
			char num[4];
			sprintf(num,"%d",canoctave(p));
			my_plotmode(P_STORE);
			centertext(num,xtext,(y0+y1)/2);
			my_plotmode(pblack);
		}
		if ( Blackkeys[cp] ) {
			if ( y0 > y1 )
				y0--;
			mdep_boxfill(x0,y1,xc,y0);
		}
		else {
			if ( Y0inc[cp] && (p-1) != low ) {
				if ( prevy1inc > 0 )
					y0 = prevy1inc;
				else {
					prevy = pitchtoy(w,p-2);
					y0 = (prevy+y0)/2;
				}
			}
			if ( Y1inc[cp] && p != high ) {
				nexty = pitchtoy(w,p+1);
				y1 = (nexty+y1)/2;
				prevy1inc = y1;
			}
			mdep_line(x0,y1,xb,y1);
			/* mdep_line(xb,y1,xb,y0); */
			mdep_line(xb,y0,x0,y0);
		}
	}
	my_plotmode(P_STORE);
}
#endif