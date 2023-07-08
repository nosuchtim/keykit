/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

struct Pbitmap {
	INT16 xsize, ysize;	/* current size */
	INT16 origx, origy;	/* allocated size */
	unsigned char *ptr;
};

struct Kpoint {
	long x0;
	long y0;
};

struct Krect {
	long x0;
	long y0;
	long x1;
	long y1;
};

struct Kitem {
	Symstr name;
	int pos;
	struct Kmenu *nested;
	Dnode *args;
	struct Kitem *next;
};

struct Kmenu {
	struct Kitem *items;
	int nitems;
	struct Kmenu *next;

	INT16 x,y;	/* For now, the x,y of the menu is the same as */
			/* x0,y0 of the window enclosing it, but I forsee */
			/* the possibility of having titles on the menus. */
	INT16 header;	/* height of header at top of menu */
	INT16 width, height;
	INT16 offset;
	short made;	/* 0 if its Pbitmaps have not been created */
	short top;	/* menu item displayed at top */
	int choice;	/* ranges from 0 to shown(km)-1, i.e. it's */
			/* the currently-highlighted choice within */
			/* displayed items.  If < 0, it means that */
			/* nothing is highlighted. */
	int menusize;	/* Number of entries displayed - i.e. any number */
			/* more than this enables a scrollbar. */
};

struct Ktext {
	/* following fields used for WIND_TEXT */
	int tx0;		/* This is where text starts (taking into */
				/* account scroll bar)*/
	int currrow, currcol;	/* Current row and column within display area*/
				/* the top row of the display area is row 0. */
	int currx, curry;	/* Coordinates of currrow,currcol */
	int currcols;		/* Number of cols shown */
	int disprows;		/* Number of rows shown */
	char **bufflines;	/* Circular buffer of saved lines.  The */
				/* direction is reversed from what you might */
				/* think.  If toplnum is 50 (i.e. the 1st */
				/* line on the display is bufflines[50]), */
				/* then the 2nd display line is bufflines[49]*/
	int numlines;		/* Total number of lines in bufflines */
	char *currline;		/* active line */
	int currlnum;		/* index of that line in bufflines */
	int toplnum;		/* index (in bufflines) of top row in display*/
	int lastused;		/* last used line (often equal to currlnum) */
};

struct Kwind {
	int wnum;
	int type;	/* WIND_* */
	int flags;	/* WFLAG_* */
	struct Kwind *next;
	struct Kwind *prev;

	/* Window area in physical coordinate space (0,0,mdep_maxx(),mdep_maxy()) */
	int x0, y0, x1, y1;

	/* These are shared by windows (MENU,TEXT) that have scrollbars */
	int inscroll;		/* whether mouse is in scrollbar (only for */
				/* WIND_TEXT, WIND_MENU) */
	int lasty;

	struct Ktext kt;

	/* following fields used for WIND_PHRASE */
	Symstr trk;
	Phrasepp pph;
	int showlow;
	int showhigh;
	long showstart;
	long showleng;
	int showbar;

	/* following fields used for WIND_MENU */
	/* NOTE: km SHOULD EVENTUALLY BE A POINTER, CAUSE KM TAKES A LOT OF */
	/* SPACE THAT SHOULDN'T BE USED FOR EVERY WINDOW. */
	struct Kmenu km;

	struct Pbitmap saveunder;  /* used when WFLAG_SAVEDUNDER is set*/
};

typedef struct Kmenu Kmenu;
typedef struct Kitem Kitem;
typedef struct Kwind Kwind;
typedef struct Kpoint Kpoint;
typedef struct Krect Krect;
typedef struct Pbitmap Pbitmap;

#define EMPTYBITMAP {0,0,0,0,0}

/* avoid recomputing the x value of w->showstart unless it's changed */
#define SHOWXSTART ((Lastst==w->showstart)?Lastxs:clktoxraw(w->showstart))
/* avoid recomputing the y value of w->showhigh unless it's changed */
#define SHOWYHIGH ((Lastsh==w->showhigh)?Lastys:pitchyraw(w,w->showhigh))

#define clktoxraw(clicks) ((w->showleng==0) ? 0 : (int)(((clicks)*Dispdx + Dispdx/2)/w->showleng))
#define clktox(clicks) (Disporigx+clktoxraw(clicks)-SHOWXSTART)

#define Disporigy (w->y0+1)
#define Disporigx (w->x0+1)
#define Dispcorny (w->y1-1)
#define Dispcornx (w->x1-1)
#define Dispdx (Dispcornx - Disporigx)
#define Dispdy (Dispcorny - Disporigy)

#define windxmax(w) ((w)->x1)
#define windymax(w) ((w)->y1)
#define windxmin(w) ((w)->x0)
#define windymin(w) ((w)->y0)

#define windnum(w) ((w)->wnum)

#define MAXWIND 128

#define WIND_GENERIC 1
#define WIND_PHRASE 2
#define WIND_TEXT 3
#define WIND_MENU 4

/* These must match the macro values MENU_* in sym.c */
#define M_NOCHOICE -1
#define M_BACKUP -2
#define M_UNDEFINED -3
#define M_MOVE -4
#define M_DELETE -5

/* The default is for windows to have borders */
#define WFLAG_NOBORDER 1
/* This bit only has meaning if the WFLAG_NOBORDER bit is 0 */
#define WFLAG_BUTTON 2
/* Initially this bit is 0.  It's set (and never cleared) when window is */
/* actually drawn. */
#define WFLAG_DRAWN 4
/* This bit means that the saveunder bitmap is set */
#define WFLAG_SAVEDUNDER 8
/* This bit is for menu buttons */
#define WFLAG_MENUBUTTON 16
/* This bit is for depressed menu buttons */
#define WFLAG_PRESSED 32

#define DISP_TEXT 0
#define DISP_LINE 1
#define DISP_RECT 2
#define DISP_FILL 3

#define TEXT_CENTER 0
#define TEXT_LEFT 1
#define TEXT_RIGHT 2

#define PREORDER 0
#define POSTORDER 1

#define NT_VISIBLE 1
#define NT_INVISIBLE 2
#define NT_CLIPPED 3

/*********/
/* NOTE THAT SOME OF THE VALUES BELOW MUST MATCH THE MACRO VALUES */
/* SET IN main.c FOR THE BUILT-IN KEYKIT MACROS. */
/*********/

/* values given to graph functions in mdep*.c */
#define P_CLEAR 0
#define P_STORE 1
#define P_XOR 2

/* values given to mdep_setcursor() */
#define M_NOTHING 0
#define M_ARROW 1
#define M_SWEEP 2
#define M_CROSS 3
#define M_LEFTRIGHT 4
#define M_UPDOWN 5
#define M_ANYWHERE 6
#define M_BUSY 7

extern Symlongp Sweepquant;
extern Symlongp Dragquant;
extern Symlongp Bendrange, Bendoffset, Showtext, Showbar;
extern Symlongp Volstem, Volstemsize, Panraster, Colors;
extern Symlongp Colornotes, Inverse, Menujump, Menuscrollwidth, Menusize;
extern Symlongp Graphmode, Graphdriver, Menuymargin;
extern Symlongp Textscrollsize;
extern Symlongp Keyinverse, Cursereverse, Usewindfifos;
extern int Backcolor, Forecolor, Pickcolor, Lightcolor, Darkcolor, ButtonBGcolor;
extern Phrasepp Pickphr, Gridphr;
extern Symstrp Fontname, Icon, Windowsys;
extern int Rawx, Rawy;
extern long Lastst, Lastsh;
extern int Lastxs, Lastys;
extern Kwind *Wind;
extern int Nwind;
extern Kwind *Wroot, *Wprintf;
extern Kwind *Topwind;
extern Htablep Windhash;

#ifdef __STDC__
typedef void (*NOTEFNCPTR)(struct Kwind*,Noteptr);
typedef void (*WINDFUNC)(struct Kwind*);
typedef void (*KWFUNC)(Kwind*,int,int,int,int);
#else
typedef void (*NOTEFNCPTR)();
typedef void (*WINDFUNC)();
typedef void (*KWFUNC)();
#endif
