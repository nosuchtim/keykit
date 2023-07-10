/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#include "key.h"
#include "gram.h"

void
o_setinit(int argc)
{
	dummyusage(argc);
	execerror("o_setinit called!?   It's obsolete!");
#ifdef OLDSTUFF
	Codep cp;
	Kobjectp o = T->obj;
	if ( argc != 1 )
		execerror("usage: o.setinit(function)");
	cp = needfunc("setinit",ARG(0));
	setelement(o,uniqstr("init"),codepdatum(cp));
	ret(Nullval);
#endif
}

void
setelement(Kobjectp o,Symstr e,Datum d)
{
	Symbolp sym;
	if ( o->symbols == NULL )
		execerror("Internal error, o->symbols==NULL in setelement!");
	sym = syminstall(e,o->symbols,VAR);
	*symdataptr(sym) = d;
}

void
setmethod(Kobjectp o,char *m,BLTINCODE i)
{
	Symbolp sym;
	Symstr meth = uniqstr(m);
	if ( o->symbols == NULL )
		execerror("Internal error, o->symbols==NULL in setelement!");
	sym = syminstall(meth,o->symbols,VAR);
	*symdataptr(sym) = funcdp(sym,i);
}

void
setdata(Kobjectp o,char *m,Datum d)
{
	Symbolp sym;
	Symstr meth = uniqstr(m);
	if ( o->symbols == NULL )
		execerror("Internal error, o->symbols==NULL in setelement!");
	sym = syminstall(meth,o->symbols,VAR);
	*symdataptr(sym) = d;
}

Kobjectp
defaultobject(long id,int complain)
{
	Kobjectp o;
	o = newobj(id,complain);
	/* setmethod(o,"setinit",O_SETINIT); */
	setmethod(o,"addchild",O_ADDCHILD);
	setmethod(o,"removechild",O_REMOVECHILD);
	setmethod(o,"childunder",O_CHILDUNDER);
	setmethod(o,"children",O_CHILDREN);
	setmethod(o,"inherited",O_INHERITED);
	setmethod(o,"inherit",O_ADDINHERIT);
	setdata(o,"class",Nullval);
	return o;
}

void
o_addchild(int argc)
{
	Kobjectp o1, o2, o;

	if ( argc != 1 )
		execerror("usage: .addchild(new-child-object)");
	if ( T->obj == NULL )
		execerror("usage: .addchild() called with no current object!?");
	o1 = T->obj;
	o2 = needobj(".addchild",ARG(0));

	/* find end of o1 children list (stopping if o2 is already in it) */
	for (o=o1->children;o!=NULL&&o->nextsibling!=NULL&&o!=o2;o=o->nextsibling)
		;
	if ( o == o2 )  /* It's already in the list.  Harmless error. */
		goto getout;

	if ( o2->nextsibling != NULL ) {
		tprint("In $%ld.addchild() - $%ld is a child of something else!?\n",o1->id,o2->id);
		goto getout;
		/* execerror(Msg1); */
	}
	if ( o1->children == NULL ) {
		o1->children = o2;
	}
	else {
		/* add o2 to end of children list */
		if ( o == NULL )
			execerror("Internal error, o==NULL in .addchild!?");
		o->nextsibling = o2;
	}
    getout:
	ret(Nullval);
}

#ifdef SAVEFORERRORCHECKING
void
chksib(Kobjectp o1, char *s)
{
	Kobjectp o;
	for (o=o1->children;o!=NULL;o=o->nextsibling) {
		if ( o == o->nextsibling )
			execerror("Infinite sibling loop: o=%ld o1=%ld %s\n",o,o1,s);
	}
}
#endif

void
o_removechild(int argc)
{
	Kobjectp o1, o2, o, preo;

	if ( argc != 1 )
		execerror("usage: .removechild(child-object)");
	if ( T->realobj == NULL )
		execerror("usage: .removechild() called with no current object!?");
	o1 = T->realobj;
	o2 = needobj(".removechild",ARG(0));
	/* remove o2 from children list */
	for (o=o1->children,preo=NULL; o!=NULL&&o!=o2; preo=o,o=o->nextsibling)
		;
	if ( o == NULL ) {
		execerror("In .removechild, object $%ld isn't a child of $%ld",
			o2->id,o1->id);
	}
	if ( preo == NULL )
		o1->children = o->nextsibling;
	else
		preo->nextsibling = o->nextsibling;

	/* NULL out the nextsibling of the object we've just removed, */
	/* so that there's no warning if we try to add it back. */
	o2->nextsibling = NULL;

	/* Don't free the object, it must be done explicitly */
	ret(Nullval);
}
	
void
o_children(int argc)
{
	Kobjectp o, obj;
	Datum d;

	dummyusage(argc);
	obj = T->realobj;
	d = newarrdatum(0,32);
	for ( o=obj->children; o!=NULL; o=o->nextsibling ) {
		/* Don't include children who have been deleted - id<0 */
		if ( o->id >= 0 )
			setarraydata(d.u.arr,objdatum(o),numdatum(o->id));
	}
	ret(d);
}

void
o_addinherit(int argc)
{
	Kobjectp o1, o2, o;

	if ( argc != 1 )
		execerror("usage: .addinherit(obj-to-inherit-from)");
	o1 = T->realobj;
	o2 = needobj("inherit",ARG(0));
	if ( o2->nextinherit != NULL )
		execerror("Unexpected o2->nextinherit!=NULL in .inherit!?");
	if ( o1->inheritfrom == NULL )
		o1->inheritfrom = o2;
	else {
		/* add o2 to end of list of objects that o1 inherits from */
		for (o=o1->inheritfrom;o!=NULL&&o->nextinherit!=NULL;o=o->nextinherit)
			;
		if ( o == NULL )
			execerror("Unexpected o==NULL in .inherit!?");
		o->nextinherit = o2;
	}
	ret(Nullval);
}

void
o_inherited(int argc)
{
	Kobjectp o, obj;
	Datum d;

	dummyusage(argc);
	obj = T->realobj;
	d = newarrdatum(0,32);
	for ( o=obj->inheritfrom; o!=NULL; o=o->nextinherit )
		setarraydata(d.u.arr,objdatum(o),numdatum(o->id));
	ret(d);
}

Kwind*
windid(Kobjectp o)
{
	Datum d;
	Symbolp s;

	if ( o->symbols == NULL )
		execerror("Internal error, o->symbols==NULL in windid!");
	s = findsym(Str_w.u.str,o->symbols);
	if ( s == NULL )
		execerror("In windid(), couldn't find .w element of window object!?");
	d = (*symdataptr(s));
	if ( d.type != D_WIND && d.type != D_OBJ ) {
		execerror("In windid(), .w isn't a window object, it's %s!? (id=%ld)",atypestr(d.type),o->id);
	}
	return(d.u.wind);
}

void
o_size(int argc)
{
	Datum retval;
	long x0, y0, x1, y1;
	int n;
	Kwind *w;

	w = windid(T->obj);
	if ( argc == 0 ) {
		retval = xy01arr((long)(w->x0),(long)(w->y0),
			(long)(w->x1),(long)(w->y1));
	}
	else {
		Htablep arr = needarr(".size",ARG(0));
		n = getxy01(arr,&x0,&y0,&x1,&y1,1,"bad array given to .size");
		if ( w == Wroot )
			execerror("Unable to set root window size!!");
		if ( n == 2 ) {
			x1 = x0;
			y1 = y0;
		}
		k_setsize(w,(int)x0,(int)y0,(int)x1,(int)y1);
		retval = Nullval;
	}
	ret(retval);
}

void
o_contains(int argc)
{
	long x0, y0, x1, y1;
	int n;
	Kwind *w;
	long r;

	dummyusage(argc);
	w = windid(T->obj);
	n = getxy01(needarr(".contains",ARG(0)),&x0,&y0,&x1,&y1,1,"bad array given to .contains");
	if ( n == 2 )
		r = windcontains(w,x0,y0);
	else
		r = windoverlaps(w,x0,y0,x1,y1);
	ret(numdatum(r));
}

void
o_mousedo(int argc)
{
	long x0, y0, x1, y1, butt;
	Htablep arr;
	int n;
	Kwind *w;
	long r = 0;
	int nodraw;
	char *bad = "bad array given to .mousedo, needs x0/y0/button";

	dummyusage(argc);
	w = windid(T->obj);
	arr = needarr(".mousedo",ARG(0));
	n = getxy01(arr,&x0,&y0,&x1,&y1,1,bad);
	if ( n != 2 )
		execerror(bad);
	butt = arraynumval(arr,Str_button,bad);

	/* If there's a "mousedown" value in the array, it's a flag */
	/* telling us that we shouldn't redraw/highlight anything. */
	nodraw = (arraysym(arr,Str_down,H_LOOK) != NULL);

	if ( w->type == WIND_MENU ) {
		m_menudo(w,butt,x0,y0,nodraw);
		if ( w->km.choice >= 0 )
			r = w->km.choice + w->km.top;
		else
			r = w->km.choice;
	}
	else if ( w->type == WIND_TEXT ) {
		v_textdo(w,butt,x0,y0);
	}
	else
		execerror(".mousedo only works on menu and text windows!?");
	ret(numdatum(r));
}

int
needplotmode(char *meth,Datum d)
{
	int n;

	n = neednum(meth,d);
	switch (n) {
	case P_STORE:
	case P_CLEAR:
	case P_XOR:
		break;
	default:
		execerror("Bad plot mode (%d) given to %s !?",n,meth);
	}
	return n;
}

void
o_lineboxfill(int argc,char *meth,KWFUNC f,int norm)
{
	long x0, y0, x1, y1;
	int n, omode;
	Kwind *w;
	char *bad = "bad xy array, must have 4 elements (x0/y0/x1/y1)";

	w = windid(T->obj);
	n = getxy01(needarr(meth,ARG(0)),&x0,&y0,&x1,&y1,norm,bad);
	if ( n != 4 )
		execerror(bad);
	omode = Pmode;
	my_plotmode( argc<=1 ? P_STORE : (int)needplotmode(meth,ARG(1)) );
	(*f)(w,(int)x0,(int)y0,(int)x1,(int)y1);
	if ( Pmode != omode )
		my_plotmode(omode);
}

void
o_fillpolygon(int argc)
{
	long x0, y0, x1, y1;
	int n, omode, nxy;
	Kwind *w;
	Htablep arr;
	int asize;
	Datum arrindex;
	Datum d;
	Symbolp s;
	int xarr[MAX_POLYGON_POINTS];
	int yarr[MAX_POLYGON_POINTS];
	int pi = 0;

	w = windid(T->obj);
	arr = needarr(".fillpolygon",ARG(0));
	asize = arrsize(arr);
	if ( asize >= MAX_POLYGON_POINTS ) {
		execerror("Too many points in polygon array");
	}
	if ( asize < 3 ) {
		execerror("Too few points in polygon array");
	}

	omode = Pmode;
	my_plotmode( argc<=1 ? P_STORE : (int)needplotmode(".fillpolygon",ARG(1)) );

	for ( n=0; n<asize; n++ ) {
		arrindex = numdatum(n);
		s = arraysym(arr,arrindex,H_LOOK);
		if ( s == NULL ) {
			execerror("Non-consecutive values in array of points?");
		}
		d = *symdataptr(s);
		if ( d.type != D_ARR ) {
			execerror("non-xy value in array of points");
		}
		nxy = getxy01(d.u.arr,&x0,&y0,&x1,&y1,0,
			"bad xy array in .fillpolygon, must have x/y");
		if ( nxy != 2 ) {
			execerror("non-xy value in array of points");
		}
		xarr[pi] = x0;
		yarr[pi] = y0;
		pi++;
	}
	kwindfillpolygon(w,xarr,yarr,pi);
	if ( Pmode != omode )
		my_plotmode(omode);
	ret(Nullval);
}

void
o_line(int argc)
{
	o_lineboxfill(argc,".line",kwindline,0);
	ret(Nullval);
}

void
o_box(int argc)
{
	o_lineboxfill(argc,".rectangle",kwindrect,1);
	ret(Nullval);
}

void
o_fill(int argc)
{
	o_lineboxfill(argc,".fillrectangle",kwindfill,1);
	ret(Nullval);
}

void
o_ellipse(int argc)
{
	if ( argc > 1 && (int)needplotmode(".ellipse",ARG(1))==P_XOR )
		execerror("Sorry, ellipse drawing doesn't support XOR mode!");
	o_lineboxfill(argc,".ellipse",kwindellipse,1);
	ret(Nullval);
}

void
o_fillellipse(int argc)
{
	if ( argc > 1 && (int)needplotmode(".fillellipse",ARG(1))==P_XOR )
		execerror("Sorry, ellipse drawing doesn't support XOR mode!");
	o_lineboxfill(argc,".fillellipse",kwindfillellipse,1);
	ret(Nullval);
}

void
o_style(int argc)
{
	Kwind *w = windid(T->obj);
	int b;
	int allflags = WFLAG_NOBORDER | WFLAG_BUTTON
			| WFLAG_MENUBUTTON | WFLAG_PRESSED;

	if ( argc > 0 ) {
		w->flags &= (~allflags);
		b = (int)neednum(".style",ARG(0));
		switch (b) {
		case 0:	/* no border */
			w->flags |= WFLAG_NOBORDER;
			break;
		case 1: /* simple outline */
			break;
		case 2:	/* shadow border */
			w->flags |= WFLAG_BUTTON;
			break;
		case 3:	/* menu button */
			w->flags |= ( WFLAG_BUTTON | WFLAG_MENUBUTTON);
			break;
		case 4:	/* depressed menu button */
			w->flags |= ( WFLAG_BUTTON |
				WFLAG_MENUBUTTON | WFLAG_PRESSED);
			break;
		}
	}
	else {
		/* return current setting */
		if ( (w->flags & WFLAG_NOBORDER)!=0 )
			b = 0;
		else if ( (w->flags & WFLAG_BUTTON)==0 )
			b = 1;
		else if ( (w->flags & WFLAG_MENUBUTTON)==0 )
			b = 2;
		else if ( (w->flags & WFLAG_PRESSED)==0 )
			b = 3;
		else
			b = 4;
	}
	ret(numdatum(b));
}

void
o_saveunder(int argc)
{
	int wid, hgt;
	Kwind *w = windid(T->obj);

	/* We used to check for multiple saveunders (i.e. without an */
	/* interveaning restoreunder), but no more. */
	dummyusage(argc);
	wid = w->x1 - w->x0 + 1;
	hgt = w->y1 - w->y0 + 1;
	w->saveunder = mdep_allocbitmap(wid,hgt);
	my_plotmode(P_STORE);
	mdep_pullbitmap(w->x0,w->y0,w->saveunder);
	w->flags |= WFLAG_SAVEDUNDER;

	ret(Nullval);
}

void
o_restoreunder(int argc)
{
	Kwind *w = windid(T->obj);
	if ( (w->flags & WFLAG_SAVEDUNDER) != 0 ) {
		int keepit = 0;
		if ( argc > 0 )
			keepit = (int)neednum("restoreunder",ARG(0));
		my_plotmode(P_STORE);
		mdep_putbitmap(w->x0,w->y0,w->saveunder);
		if ( keepit == 0 ) {
			mdep_freebitmap(w->saveunder);
			w->flags &= (~WFLAG_SAVEDUNDER);
		} else {
		}
	}
	else
		execerror(".restoreunder used without a previous saveunder!?");
	ret(Nullval);
}

void
o_textheight(int argc)
{
	dummyusage(argc);
	ret(numdatum(mdep_fontheight()));
}

void
o_textwidth(int argc)
{
	dummyusage(argc);
	ret(numdatum(mdep_fontwidth()));
}

void
o_text(int argc,int just)
{
	long x0, y0, x1, y1;
	char *str;
	int n, omode;
	char *bad = "bad xy array in .text*, must have x0/y0/x1/y1";
	Kwind *w = windid(T->obj);

	if ( (w->type==WIND_TEXT && (argc<0 || argc>1)) || 
		(w->type!=WIND_TEXT && (argc < 2 || argc > 3))) {
		execerror("bad usage of .text*");
	}
	str = needstr(".text",ARG(0));
	if ( w->type == WIND_TEXT ) {
		k_reinittext(w);
		return;
	}
	n = getxy01(needarr(".text",ARG(1)),&x0,&y0,&x1,&y1,1,bad);
	if ( n != 4 )
		execerror(bad);

	omode = Pmode;
	my_plotmode( argc<=2 ? P_STORE : (int)needplotmode(".text",ARG(2)) );
	kwindtext(str,(int)x0,(int)y0,(int)x1,(int)y1,just);
	if ( Pmode != omode )
		my_plotmode(omode);
}

void
o_printf(int argc)
{
	char *fmt = needstr(".printf",ARG(0));

	Wprintf = windid(T->obj);
	keyprintf(fmt,1,argc-1,wprint);
	ret(Nullval);
}

void
o_textcenter(int argc)
{
	o_text(argc,TEXT_CENTER);
	ret(Nullval);
}

void
o_textleft(int argc)
{
	o_text(argc,TEXT_LEFT);
	ret(Nullval);
}

void
o_textright(int argc)
{
	o_text(argc,TEXT_RIGHT);
	ret(Nullval);
}

void
o_type(int argc)
{
	char *t;
	Kwind *w = windid(T->obj);

	dummyusage(argc);
	switch(w->type){
	case WIND_GENERIC:	t = "generic"; break;
	case WIND_PHRASE:	t = "phrase"; break;
	case WIND_MENU:		t = "menu"; break;
	case WIND_TEXT:		t = "text"; break;
	default: 		t = "unknown"; break;
	}
	ret(strdatum(uniqstr(t)));
}

void
o_xmin(int argc)
{
	Kwind *w = windid(T->obj);

	dummyusage(argc);
	ret(numdatum(windxmin(w)));
}

void
o_ymin(int argc)
{
	Kwind *w = windid(T->obj);

	dummyusage(argc);
	ret(numdatum(windymin(w)));
}

void
o_xmax(int argc)
{
	Kwind *w = windid(T->obj);

	dummyusage(argc);
	ret(numdatum(windxmax(w)));
}

void
o_ymax(int argc)
{
	Kwind *w = windid(T->obj);

	dummyusage(argc);
	ret(numdatum(windymax(w)));
}

void
o_redraw(int argc)
{
	Kwind *w = windid(T->obj);

	dummyusage(argc);
	wredraw1(w);
	ret(Nullval);
}

void
o_childunder(int argc)
{
	Kobjectp o, topo, fo;
	Kwind *w, *topw, *w2;
	int n;
	Symbolp sym;
	long x0, y0, x1, y1;
	Htablep arr;
	char *s = ".childunder";
	char *bad = "bad xy array in .childunder";

	dummyusage(argc);
	arr = needarr(s,ARG(0));
	n = getxy01(arr,&x0,&y0,&x1,&y1,1,bad);
	if ( n != 2 )
		execerror(bad);
	topo = T->realobj;
	topw = NULL;
	for ( o=T->realobj->children; o!=NULL; o=o->nextsibling ) {
		if ( o == o->nextsibling )
			execerror("Internal error, inifinite sibling loop in o_childunder");
		sym = findobjsym(uniqstr("contains"),o,&fo);
		if ( sym == NULL )
			continue;
		w = windid(fo);
		if ( windcontains(w,x0,y0) ) {
			if ( ! topw ) {
				topw = w;
				topo = o;
			}
			else {
				/* see if w is in front of topw */
				for ( w2=Topwind; w2!=topw && w2!=NULL; w2=w2->next ) {
					if ( w2 == w )
						break;
				}
				if ( w2 == NULL )
					execerror("Unexpected w2==NULL!?");
				if ( w2 == w ) {
					topw = w;
					topo = o;
				}
			}
		}
	}
	ret(objdatum(topo));
}

void
o_drawphrase(int argc)
{
	Phrasep ph;
	char *s = ".drawphrase";
	Kwind *w = windid(T->obj);
	int omode;

	if ( argc > 2 )
		execerror("bad usage of .drawphrase");
	ph = needphr(s,ARG(0));
	omode = Pmode;
	my_plotmode( argc<=1 ? P_STORE : (int)needplotmode(s,ARG(1)) );
	drawph(w,ph);
	if ( Pmode != omode )
		my_plotmode(omode);
	ret(Nullval);
}

void
o_scaletogrid(int argc)
{
	long x0, y0, x1, y1;
	int n;
	Htablep arr;
	Datum retval;
	char *bad = "bad xy array in .scaletogrid";
	char *s = ".scaletogrid";
	Kwind *w = windid(T->obj);

	dummyusage(argc);
	arr = needarr(s,ARG(0));
	n = getxy01(arr,&x0,&y0,&x1,&y1,1,bad);
	if ( n == 2 ) {
		scalewind2grid(w,&x0,&y0);
		retval = xyarr(x0,y0);
	}
	else if ( n == 4 ) {
		scalewind2grid(w,&x0,&y0);
		scalewind2grid(w,&x1,&y1);
		retval = xy01arr(x0,y0,x1,y1);
	}
	else
		execerror(bad);
	addnonxy(retval.u.arr,arr);
	ret(retval);
}

void
o_scaletowind(int argc)
{
	long x0, y0, x1, y1;
	int n;
	Htablep arr;
	Datum retval;
	char *bad = "bad xy array in .scaletowind";
	char *s = ".scaletowind";
	Kwind *w = windid(T->obj);

	dummyusage(argc);
	arr = needarr(s,ARG(0));
	n = getxy01(arr,&x0,&y0,&x1,&y1,1,bad);
	if ( n == 2 ) {
		scalegrid2wind(w,&x0,&y0);
		retval = xyarr(x0,y0);
	}
	else if ( n == 4 ) {
		scalegrid2wind(w,&x0,&y0);
		scalegrid2wind(w,&x1,&y1);
		retval = xy01arr(x0,y0,x1,y1);
	}
	else
		execerror(bad);
	addnonxy(retval.u.arr,arr);
	ret(retval);
}

void
o_closestnote(int argc)
{
	long x0, y0, x1, y1;
	int n;
	Htablep arr;
	Datum d;
	Noteptr nt;
	Phrasep ph;
	char *bad = "bad xy array in .closestnote";
	char *s = ".closestnote";
	Kwind *w = windid(T->obj);

	dummyusage(argc);
	arr = needarr(s,ARG(0));
	/* The values we're getting in the array are SUPPOSED to be raw */
	/* x,y values, NOT click/pitch values. */
	n = getxy01(arr,&x0,&y0,&x1,&y1,0,bad);
	if ( n != 2 )
		execerror(bad);
	ph = newph(1);
	nt = closestnt(w,*(w->kp.pph),x0,y0);
	if ( nt )
		ntinsert(ntcopy(nt),ph);
	d = phrdatum(ph);
	ret(d);
}

void
o_view(int argc)
{
	long x0, y0, x1, y1;
	int n;
	Htablep arr;
	Datum retval;
	char *bad = "bad array given to .view, needs x0/y0/x1/y1";
	char *s = ".view";
	Kwind *w = windid(T->obj);

	if ( argc == 1 ) {
		arr = needarr(s,ARG(0));
		n = getxy01(arr,&x0,&y0,&x1,&y1,1,bad);
		if ( n != 4 )
			execerror(bad);
		w->kp.showlow = y0;
		w->kp.showhigh = y1;
		w->kp.showstart = x0;
		w->kp.showleng = x1-x0;
	}
	retval = xy01arr(w->kp.showstart,(long)(w->kp.showlow),
		w->kp.showstart+w->kp.showleng,(long)(w->kp.showhigh));
	ret(retval);
}

void
o_sweep(int argc)
{
	Fifo *f;
	long x, y;
	int n;
	Htablep arr;
	char *s = ".sweep";
	Kwind *w = windid(T->obj);

	if ( argc != 3 )
		execerror("usage: .sweep(f,type,xy)");

	f = needvalidfifo(s,ARG(0));
	n = (int)neednum(s,ARG(1));
	arr = needarr("sweep",ARG(2));
	(void) getxy01(arr,&x,&y,&x,&y,0,"Improper array given to .sweep()");
	dosweepstart(w,n,x,y,f);
	/* Don't return a value, since dosweepstart() starts */
	/* an instruction sequence that will eventually return a value. */
}

void
o_trackname(int argc)
{
	Kwind *w = windid(T->obj);
	Datum retval;

	retval = Nullval;
	if ( w->type != WIND_PHRASE )
		execerror(".trackname() can only be used on phrase windows");
	if ( argc == 0 ) {
		retval=strdatum(w->type!=WIND_PHRASE ? Nullstr:w->kp.trk);
	}
	else if ( argc == 1 ) {
		char *s;
		s = needstr(".trackname",ARG(0));
		wsettrack(w,s);
	}
	else
		execerror("usage: window(\"phrase\" [,trackname])");
	ret(retval);
}

void
o_menuitem(int argc)
{
	Kwind *w = windid(T->obj);
	char *label;
	char *s = ".menuitem";
	Kitem *ki;
	int r = -1;

	if ( argc != 1 )
		execerror("usage: .menuitem(label)");

	if ( w->type != WIND_MENU )
		execerror(".menuitem() must be applied to a menu window!?");
	
	label = needstr(s,ARG(0));
	ki = k_menuitem(w,label);
	ki->args = NULL;
	menucalcxy(w);
	r = ki->pos;
	ret(numdatum(r));
}

void
o_menuitems(int argc)
{
	Kwind *w = windid(T->obj);
	Kitem *ki;
	Datum d;

	dummyusage(argc);
	if ( w->type != WIND_MENU )
		execerror(".menuitems() must be applied to a menu window!?");
	
	d = newarrdatum(0,11);
	for ( ki=w->km.items; ki!=NULL; ki=ki->next ) {
		setarraydata(d.u.arr,strdatum(ki->name),numdatum(0));
	}
	ret(d);
}

Kobjectp
windobject(long id,int complain,char *type)
{
#ifdef OLDSTUFF
	static int first = 1;
#endif
	Symbolp s;
	Kobjectp o;
	Kwind *w = NULL;

	if(id==0){
		mdep_popup("windobject got id==0!?");
		abort();
	}

#ifdef OLDSTUFF
	Symstr c;
	static Symstr str_generic, str_menu, str_phrase, str_root, str_text;
	if ( first ) {
		first = 0;
		str_generic = uniqstr("window/generic");
		str_text = uniqstr("window/text");
		str_phrase = uniqstr("window/phrase");
		str_root = uniqstr("window/root");
		str_menu = uniqstr("window/menu");
	}
#endif

	o = defaultobject(id,complain);

	if ( strcmp(type,"generic") == 0 ) {
		w = newkwind();
		w->type = WIND_GENERIC;
	}
	else if ( strcmp(type,"text") == 0 ) {
		w = newkwind();
		w->type = WIND_TEXT;
		k_inittext(w);
	}
	else if ( strcmp(type,"phrase") == 0 ) {
		w = newkwind();
		w->type = WIND_PHRASE;
		k_initphrase(w);
		wsettrack(w,Nullstr);
	}
	else if ( strcmp(type,"menu") == 0 ) {
		w = newkwind();
		w->type = WIND_MENU;
		k_initmenu(w);
	}
	else if ( strcmp(type,"root") == 0 ) {
		w = Wroot;
	}
	else
		execerror("window(new...), bad argument!");

	if ( w != Wroot )
		k_setsize(w,0,0,0,0);

	if ( o->symbols == NULL )
		execerror("Internal error, o->symbols==NULL in windobject!");
	s = syminstall(Str_w.u.str,o->symbols,VAR);
	(*symdataptr(s)) = winddatum(w);

	/* general window methods */
	setmethod(o,"size",O_SIZE);
	setmethod(o,"resize",O_SIZE);
	setmethod(o,"redraw",O_REDRAW);
	setmethod(o,"contains",O_CONTAINS);
	setmethod(o,"xmin",O_XMIN);
	setmethod(o,"ymin",O_YMIN);
	setmethod(o,"xmax",O_XMAX);
	setmethod(o,"ymax",O_YMAX);
	setmethod(o,"line",O_LINE);
	setmethod(o,"rectangle",O_BOX);
	setmethod(o,"fillrectangle",O_FILL);
	setmethod(o,"fill",O_FILL);
	setmethod(o,"ellipse",O_ELLIPSE);
	setmethod(o,"fillellipse",O_FILLELLIPSE);
	setmethod(o,"fillpolygon",O_FILLPOLYGON);
	setmethod(o,"style",O_STYLE);
	setmethod(o,"mousedo",O_MOUSEDO);
	setmethod(o,"windtype",O_TYPE);
	setmethod(o,"text",O_TEXTCENTER);
	setmethod(o,"textcenter",O_TEXTCENTER);
	setmethod(o,"textleft",O_TEXTLEFT);
	setmethod(o,"textright",O_TEXTRIGHT);
	setmethod(o,"textheight",O_TEXTHEIGHT);
	setmethod(o,"textwidth",O_TEXTWIDTH);
	setmethod(o,"saveunder",O_SAVEUNDER);
	setmethod(o,"restoreunder",O_RESTOREUNDER);
	setmethod(o,"printf",O_PRINTF);

	/* phrase window methods */
	setmethod(o,"drawphrase",O_DRAWPHRASE);
	setmethod(o,"scaletogrid",O_SCALETOGRID);
	setmethod(o,"scaletowind",O_SCALETOWIND);
	setmethod(o,"view",O_VIEW);
	setmethod(o,"trackname",O_TRACKNAME);
	setmethod(o,"sweep",O_SWEEP);
	setmethod(o,"closestnote",O_CLOSESTNOTE);

	/* menu window methods */
	setmethod(o,"menuitem",O_MENUITEM);
	setmethod(o,"menuitems",O_MENUITEMS);

	return o;
}
