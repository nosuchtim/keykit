class wboomix {
method init() {

	$.w = new window()
	$.inherit($.w)

	$.kboomtype = 2		# set to 2 to use Kboom2
	arr = []
	for ( n=0; n<16; n++ )
		arr[n] = string(n+1)
	$.b0 = new kbutton("Resync",$,"resync")
	$.b2 = new kmenubutton("More","mkmenu_boomix1",$)
	$.buttonoff = new ktoggle("On",$,"onoff")
	$.kb = $.newkboom(16)
	$.addchild($.b0)
	$.addchild($.b2)
	$.addchild($.buttonoff)
	$.addchild($.kb)
	$.sleeptime = 2b

	$.ison = 0
	$.startquant = 1
	$.stoptids = []
	$.ph = []
	$.slide = []
	$.speedslide = []
	$.speedof = []
	$.label = []
	$.speedmax = 4b
	$.sweeptask = []
	$.sweepl = []
	$.sweepr = []
	$.buttright = []
	$.buttleft = []
	$.lastdone = -1
	$.sweepinc = 2

	$.nkbooms = 0

	$.setnkbooms(6)
	$.buttonoff.set(0)
}
method newkboom(...) {
	if ( $.kboomtype == 2 )
		return(new wkboom2(...))
	else
		return(new wkboom(...))
}
method setkboomtype(n) {
	$.kboomtype = n

	# change the "main" kboom tool
	$.removechild($.kb)
	$.kb = $.newkboom(16)
	$.addchild($.kb)

	# change all the little ones
	sv = $.nkbooms
	$.setnkbooms(0)
	$.setnkbooms(sv)

	$.resize()
	$.redraw()
}
# this method gets used by both the kbutton and bang
method onoff(v) {
	if ( v ) {
		$.ison = 1
		$.play()
	} else {
		$.ison = 0
		$.stop()
	}
}
method bang() {
	if ($.ison) {
		$.onoff(0)
	} else {
		$.onoff(1)
	}
}
method slidermoved(v,bn,killit) {
	if ( nargs() < 3 )
		killit = 1
	$.ph[bn].setvolfactor(float(v)/100.0)
	if ( killit )
		kill($.sweeptask[bn])
}
method speedmoved(v,bn) {
	$.speedof[bn] = $.speedmax - v + 1
}
method setstartquant (v) {
	$.startquant = v
}
method play (bn) {
	stime = Now     # so they all start in sync
	if ( $.startquant > 1 )
		stime = nextquant(stime,$.startquant)
	for ( i=0; i<$.nkbooms; i++ )
		$.ph[i].play(stime)

	# If the kb is running, sync it as well
	$.kb.sync()
	
	$.buttonoff.set(1)
	$.buttonoff.redraw()
}
method stop {
	for ( i=0; i<$.nkbooms; i++ )
		$.ph[i].stop()
	$.buttonoff.set(0)
	$.buttonoff.redraw()
}

method resync() {
	$.stop()
	$.play()
}
method dump {
	st = []
	st["ph"] = []
	for ( n=0; n<$.nkbooms; n++ ) {
		st["ph"][n] = $.ph[n].dump()
	}
	st["kb"] = $.kb.dump()
	st["kboomtype"] = $.kboomtype
	return ( st )
}
method restore (state) {
	$.setnkbooms(sizeof(state["ph"]))
	$.setkboomtype(state["kboomtype"])
	$.resize()
	for ( n in state["ph"] ) {
		d = state["ph"][n]
		$.ph[n].restore(d)
	}
	$.kb.restore(state["kb"])
	$.redraw()
}
method nbchanged (n) {
	$.setnkbooms(n)
	$.resize()
	$.redraw()
}
method getnkbooms {
	return($.nkbooms)
}

method dobuttright(n) {
	p = $.kb.get()
	st = $.kb.dump()
	st["compact"] = 1	# devious - playing with dump of kboom
	$.ph[n].restore(st)
	$.ph[n].redraw()
	$.updateline(n)
}

method dobuttleft(n) {
	st = $.ph[n].dump()
	st["compact"] = 0	# devious - playing with dump of kboom
	$.kb.restore(st)
	$.kb.redraw()
	$.updateline(n)
}

method setsweepinc(n) {
	$.sweepinc = n
}
method sweepleft(n) {
	kill($.sweeptask[n])
	$.sweeptask[n] = task task_bmx_sweep($,n,-$.sweepinc,0)
}

method sweepright(n) {
	kill($.sweeptask[n])
	$.sweeptask[n] = task task_bmx_sweep($,n,$.sweepinc,100)
}

method volumeof(n) {
	return($.slide[n].get())
}
method volumeadjust(n,inc) {
	v = $.slide[n].get()+inc
	$.slide[n].set(v,1)
	$.slidermoved(v,n,0)	# don't kill task
}

method setnkbooms (needed) {
	if ( needed < 0 )
		error("Bad needed value ("+string(needed)+") in setnkbooms")
	while ( needed > $.nkbooms ) {
		bn = $.nkbooms
		$.ph[bn] = $.newkboom(-1,-1,-1,1)	# make it compact
		$.addchild($.ph[bn])

		$.slide[bn] = new khslider(0,100,50,$,"slidermoved",bn)
		$.addchild($.slide[bn])

		$.speedslide[bn] = new kslider(1,$.speedmax,$.speedmax/2,$,"speedmoved",bn)
		$.addchild($.speedslide[bn])

		$.label[bn] = new ktext(string(bn))
		$.addchild($.label[bn])

		$.speedof[bn] = $.speedmax/2

		if ( bn in $.sweeptask )
			kill($.sweeptask[bn])
		$.sweeptask[bn] = -1

		$.sweepl[bn] = new kbutton("<",$,"sweepleft",bn)
		$.addchild($.sweepl[bn])
		$.sweepr[bn] = new kbutton(">",$,"sweepright",bn)
		$.addchild($.sweepr[bn])

		$.buttright[bn] = new kbutton("<",$,"dobuttright",bn)
		$.addchild($.buttright[bn])
		$.buttleft[bn] = new kbutton(">",$,"dobuttleft",bn)
		$.addchild($.buttleft[bn])

		$.nkbooms++
	}
	while ( needed < $.nkbooms ) {
		bn = $.nkbooms - 1
		kill($.sweeptask[bn])
		$.removechild($.ph[bn]) ; deleteobject($.ph[bn])
		$.removechild($.slide[bn]) ; deleteobject($.slide[bn])
		$.removechild($.speedslide[bn]) ; deleteobject($.speedslide[bn])
		$.removechild($.label[bn]) ; deleteobject($.label[bn])
		$.removechild($.sweepl[bn]) ; deleteobject($.sweepl[bn])
		$.removechild($.sweepr[bn]) ; deleteobject($.sweepr[bn])
		$.removechild($.buttright[bn]) ; deleteobject($.buttright[bn])
		$.removechild($.buttleft[bn]) ; deleteobject($.buttleft[bn])
		$.nkbooms--
	}
}

method get {
	r = ''
	for ( bn=0; bn<$.nkbooms; bn++ ) {
		r += $.ph[bn].get()
	}
	return(r)
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	$.y0 = $.ymin()+2
	$.y1 = $.ymax() - 2
	$.x0 = $.xmin() + 2
	$.x1 = $.xmax() - 2
	th = $.textheight()
	tw = $.textwidth()
	$.ym1 = $.ymin() + th + 5

	$.ym2 = $.ymin() + 2*th + 8

	dx = ($.x1-$.x0)/4
	$.xm1 = $.x0 + dx
	$.xm2 = $.x0 + 2*dx
	$.xm2b = $.x0 + 5*dx/2
	$.xm3 = $.x0 + 3*dx
	$.xm4 = $.x0 + 4*dx

	# buttons at the top
	$.buttonoff.resize(xy($.xm1,$.y0,$.xm2-1,$.ym1-2))
	$.b0.resize(xy($.xm2+1,$.y0,$.xm3-1,$.ym1-2))
	$.b2.resize(xy($.xm3+1,$.y0,$.xm4-1,$.ym1-2))

	bw = tw*2
	prebw = tw*4
	ty1 = $.ym1
	for ( n=0; n<$.nkbooms; n++ ) {
		ty0 = ty1
		ty1 = $.ym1 + (((n+1)*($.y1-$.ym1))/$.nkbooms)
		tymid = (ty0+ty1)/2

		# sweep left/right
		$.label[n].resize(xy($.x0,ty0+1,$.x0+tw*2-1,ty1-1))
		$.speedslide[n].resize(xy($.x0+tw*2+1,ty0+1,$.x0+prebw-1,ty1-1))

		$.sweepl[n].resize(xy($.x0+prebw+1,ty0+1,$.x0+prebw+bw,ty1-1))
		$.slide[n].resize(xy($.x0+prebw+bw+2,ty0+1,$.xm1-bw-2,ty1-1))
		$.sweepr[n].resize(xy($.xm1-bw,ty0+1,$.xm1,ty1-1))

		# upbutton
		$.buttright[n].resize(xy($.xm2-bw,ty0+1,$.xm2,tymid-1))
		# downbutton
		$.buttleft[n].resize(xy($.xm2-bw,tymid+1,$.xm2,ty1-1))


		$.ph[n].resize(xy($.xm1+4,ty0+1,$.xm2-bw-4,ty1-1))
	}
	$.kb.resize(xy($.xm2+5,$.ym1+1,$.x1,ty1))
}

method redraw {
	$.w.redraw()
	$.textleft("Boomix!",xy($.x0,$.y0,$.xm1,$.ym1))
	methodbroadcast();
	$.updateline()
}

method updateline(n) {
	# draw a line under the last block that was moved in or out
	# of the kboom
	if ( nargs() > 0 )
		$.lastdone = n
	x = $.xm2 + 3
	if ( $.lastdone >= 0 ) {
		$.line(xy(x,$.ym1,x,$.y1),CLEAR)
		sz = $.ph[$.lastdone].size()
		$.line(xy(x,sz["y0"],x,sz["y1"]))
	}
}

}

function mkmenu_boomix1(o,po) {
	o.submenu("# of Kbooms ->","mkmenu_bmxnum",po)
	o.submenu("Kboom type  ->","mkmenu_kbtype",po)
	o.submenu("Sweep Speed ->","mkmenu_bmxsweepspeed",po)
	o.submenu("Start Quant ->","mkmenu_wrquantvals",po,"setstartquant")
}

function boomix_leftarrow() {
	x0 = $.xmin()+2
	x1 = $.xmax()-2
	y0 = $.ymin()
	y1 = $.ymax()
	$.line(xy(x1,y1,x0,(y0+y1)/2))
	$.line(xy(x0,(y0+y1)/2,x1,y0))
	$.line(xy(x1,y0,x1,y1))
}

function boomix_rightarrow() {
	x0 = $.xmin()+2
	x1 = $.xmax()-2
	y0 = $.ymin()
	y1 = $.ymax()

	$.line(xy(x0,y1,x1,(y0+y1)/2))
	$.line(xy(x1,(y0+y1)/2,x0,y0))
	$.line(xy(x0,y0,x0,y1))
}

function task_bmx_sweep(obj,n,dir,lim) {
	if ( dir > 0 ) {
		while ( obj.volumeof(n) < lim ) {
			sleeptill(Now+$.speedof[n])
			obj.volumeadjust(n,dir)
		}
	} else {
		while ( obj.volumeof(n) > lim ) {
			sleeptill(Now+$.speedof[n])
			obj.volumeadjust(n,dir)
		}
	}
}

function mkmenu_kbtype(o,po) {
	o.menucmd("1",po,"setkboomtype",1)
	o.menucmd("2",po,"setkboomtype",2)
}
function mkmenu_bmxnum(o,po) {
	for ( n=2; n<=16; n++ )
		o.menucmd(string(n),po,"nbchanged",n)
}
function mkmenu_bmxsweepspeed(o,po) {
	for ( n=1; n<=8; n++ )
		o.menucmd(string(n),po,"setsweepinc",n)
	for ( ; n<=16; n+=2 )
		o.menucmd(string(n),po,"setsweepinc",n)
}
