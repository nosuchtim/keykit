class wquix {

method init {
	$.w = new window()
	$.inherit($.w)

	$.c = []
	$.panel = new window()
	$.addchild($.panel)
	$.togg = new ktoggle("On",$,"setonoff")
	$.addchild($.togg)
	$.morebutton = new kmenubutton("More","mkmenu_wquix",$)
	$.addchild($.morebutton)

	arr = []
	for ( n=1; n<12; n++ ) { arr[n-1] = string(n) }
	$.linesbutton = new kvalbutton(arr,$,"setnlines")
	$.addchild($.linesbutton)

	arr2 = []
	for ( n=1; n<16; n++ ) { arr2[n-1] = string(n) }
	$.chanbutton = new kvalbutton(arr2,$,"setchannel")
	$.addchild($.chanbutton)

	$.snapbutton = new kbutton("Snap",$,"snap")
	$.addchild($.snapbutton)
	$.slide = new kslider(0,100,60,$,"setspeed")
	$.lowslide = new kslider(0,128,30)
	$.highslide = new kslider(0,128,100)
	$.addchild($.slide)
	$.addchild($.lowslide)
	$.addchild($.highslide)
	$.riff1 = new wriff() ; $.addchild($.riff1)
	$.riff1.setlistentokey(1,'c')
	$.riff1.setneverfit(1)
	$.riff1.setlooping(1)
	$.tid = -1
	$.bounce = 0

	$.makelength = 8b

	$.style = 1
	$.startquant = 4b
	$.riff1.setstartquant($.startquant)

	$.ch = 1
	$.chanbutton.set($.ch-1)

	$.nlines = 3
	$.linesbutton.set($.nlines-1)
	$.lines = []
	$.dirs = []
	$.sleeptm = 40
	$.xlimit = 32
	$.ylimit = 128	# do not change this
}

method setstartquant(v) {
	$.startquant = v
}
method setlength(v) {
	$.makelength = v
}
method setchannel(v) {
	$.ch = v + 1
}

method setnlines(v) {
	$.nlines = v + 1
	if ( $.tid >= 0 ) {
		$.off()
		$.on()
	}
}
method redraw {
	$.w.redraw()
	$.panel.redraw()
	$.w.text("Quix",$.textxy)
	for ( o in $.children() )
		o.redraw()
}
method dump { return([
	"riff1"=$.riff1.dump(),
	"nlines"=$.nlines,
	"bounce"=$.bounce
	])
}
method restore (state) {
	$.riff1.restore(state["riff1"])
	$.nlines = state["nlines"]
	$.linesbutton.set($.nlines-1)
	$.bounce = state["bounce"]
}
method snap {

	# $.riff1.stop()

	sz = $.panel.size()
	sz2 = ["x0"=0,"x1"=$.xlimit,"y0"=$.ylimit,"y1"=0]
	stepsize = 1b/4
	p = ''
	for ( n=0; n<$.nlines; n++ ) {
		p1 = line2phrase($.lines[n],sz,sz2,stepsize)
		p |= p1
	}

	low = $.lowslide.get()
	high = $.highslide.get()
	p = octavefence(p,low,high)

	p.chan = $.ch

	# We depend on wriff to do the transposing.
	# We always map to 'c'
	sc = maptoscale(Mapto,'c')

	if ( $.style == 0 ) {
		p = step(arpeggio(p),stepsize)
		p = scadjust(p,sc)
	} else {
		p = scafilt(p,sc)
		p = step(arpeggio(p),stepsize)
	}
	p = cut(p,CUT_TIME,0,$.makelength)
	p.length = $.makelength
	$.riff1.set(p)
	v = ["x0"=0,"x1"=p.length,"y0"=0,"y1"=$.ylimit]
	# print("v=",v)
	$.riff1.viewset(v)
	$.riff1.redraw()
	$.riff1.seton()
}
method on {
	if ( $.tid >= 0 )
		print("wquix is already on!?")
	else {
		$.redraw()
		$.tid = task $.task_quix()
	}
}
method delete {
	kill($.tid)
	millisleep(1000)
}
method off {
	if ( $.tid < 0 )
		print("wquix not running!?")
	else {
		kill($.tid)
		$.tid = -1
	}
}
method setonoff (v) { if (v) $.on(); else $.off() }
method setspeed (v) { $.sleeptm = 100-v }

method task_quix() {
	xdx = $.panel.xmax()-$.panel.xmin()
	ydx = $.panel.ymax()-$.panel.ymin()
	for ( n=0; n<$.nlines; n++ ) {
		$.lines[n] = xy(
				$.panel.xmin()+rand(xdx),
				$.panel.ymin()+rand(ydx),
				$.panel.xmin()+rand(xdx),
				$.panel.ymin()+rand(ydx))
		$.dirs[n] = xy(rand(2)+1,rand(4)+1,rand(4)+1,rand(2)+1)
		$.line($.lines[n],XOR)
	}
	while ( 1 ) {
		if ( $.sleeptm > 0 ) {
			sync()
			millisleep($.sleeptm)
		}
		sz = $.panel.size()
		for ( n=0; n<$.nlines; n++ ) {
			$.line($.lines[n],XOR)
			$.adj($.lines[n],$.dirs[n],sz)
			$.line($.lines[n],XOR)
		}
	}
}

method adj(ln,d,sz) {
	ln["x0"] += d["x0"]
	if ( ln["x0"] < sz["x0"] ) {
		ln["x0"] -= d["x0"]
		d["x0"] = -d["x0"]
		$.dobounce(ln)
	}
	else if ( ln["x0"] > sz["x1"] ) {
		ln["x0"] -= d["x0"]
		d["x0"] = -d["x0"]
		$.dobounce(ln)
	}

	ln["x1"] += d["x1"]
	if ( ln["x1"] < sz["x0"] ) {
		ln["x1"] -= d["x1"]
		d["x1"] = -d["x1"]
		$.dobounce(ln)
	}
	else if ( ln["x1"] > sz["x1"] ) {
		ln["x1"] -= d["x1"]
		d["x1"] = -d["x1"]
		$.dobounce(ln)
	}

	ln["y0"] += d["y0"]
	if ( ln["y0"] < sz["y0"] ) {
		ln["y0"] -= d["y0"]
		d["y0"] = -d["y0"]
		$.dobounce(ln)
	}
	else if ( ln["y0"] > sz["y1"] ) {
		ln["y0"] -= d["y0"]
		d["y0"] = -d["y0"]
		$.dobounce(ln)
	}

	ln["y1"] += d["y1"]
	if ( ln["y1"] < sz["y0"] ) {
		ln["y1"] -= d["y1"]
		d["y1"] = -d["y1"]
		$.dobounce(ln)
	}
	else if ( ln["y1"] > sz["y1"] ) {
		ln["y1"] -= d["y1"]
		d["y1"] = -d["y1"]
		$.dobounce(ln)
	}
}

method setbounce(v) {
	$.bounce = v
}
method dobounce(ln) {
	if ( $.bounce ) {
		sc = maptoscale(Mapto,Key)
		p = makenote(30+rand(70),1b/4,100,1)
		p = scadjust(p,sc)
		realtime(p)
	}
}

method resize(sz) {

	if ( $.tid >= 0 ) {
		restart = 1
		$.off()
	} else {
		restart = 0
	}

	$.w.resize(sz)
	th = $.textheight()
	tw = $.textwidth()
	x0 = $.xmin()+2
	x0a = x0+4*tw
	x1 = $.xmax()-2
	dx = x1-x0
	xm = x0 + dx/2
	xm1 = x0 + dx/3
	xm2 = x0 + 2*dx/3
	x0b = (x0a+2*tw)

	y0 = $.ymin()+2
	y0a = y0 + th + 6
	y1 = $.ymax()-2

	$.textxy = xy($.xmin(),$.ymin(),x0b, y0a-4)
	dx1 = (xm-x0b)/5

	$.togg.resize(xy(x0b,y0,x0b+dx1,y0a-4))
	$.linesbutton.resize(xy(x0b+dx1+1,y0,x0b+2*dx1,y0a-4))
	$.chanbutton.resize(xy(x0b+2*dx1+1,y0,x0b+3*dx1,y0a-4))
	$.morebutton.resize(xy(x0b+3*dx1+1,y0,x0b+4*dx1,y0a-4))
	$.snapbutton.resize(xy(x0b+4*dx1+1,y0,xm,y0a-4))

	$.slide.resize(xy(x0+2,y0a,x0a,y1))

	$.lowslide.resize(xy(xm+1,y0a,xm+tw,y1))
	$.highslide.resize(xy(xm+tw,y0a,xm+2*tw,y1))

	$.panel.resize(xy(x0a+2,y0a,xm-1,y1))
	$.riff1.resize(xy(xm+2*tw,y0,x1,y1))

	if ( restart ) {
		$.on()
	}
}
}

function line2phrase(line,sz,sz2,stepsize) {

	dx = line["x1"]-line["x0"]
	dy = line["y1"]-line["y0"]

	nsteps=sz2["x1"]-sz2["x0"]
	nsteps=8

	p = ''
	for ( n=0; n<nsteps; n++ ) {
		x = line["x0"] + (n*dx)/nsteps
		y = line["y0"] + (n*dy)/nsteps
		xy3 = scalexy(x,y,sz,sz2)
		nt = 'a'
		nt.pitch = xy3["y"]
		nt.time = xy3["x"]*stepsize
		nt.dur = stepsize
		p |= nt
	}
	p = dedup(p)
	return(p)
}
function scalexy(x,y,sz,sz2) {
	# print("scalexy xy=",x," ",y," sz=",sz," sz2=",sz2)
	dx = sz["x1"]-sz["x0"]
	dy = sz["y1"]-sz["y0"]
	dx2 = sz2["x1"]-sz2["x0"]
	dy2 = sz2["y1"]-sz2["y0"]
	x3 = sz2["x0"] + (dx2*(x-sz["x0"]))/dx
	y3 = sz2["y0"] + (dy2*(y-sz["y0"]))/dy
	xy3 = ["x"=x3,"y"=y3]
	# print("returning xy3=",xy3)
	return(xy3)
}
function mkmenu_wquix(o,po) {
	o.submenu("Start Quant ->","mkmenu_quixqvals",po,"setstartquant")
	o.submenu("Length      ->","mkmenu_quixleng",po,"setlength")
	o.submenu("Play Bounce ->","mkmenu_quixbounce",po,"setbounce")
}
function mkmenu_quixbounce(o,po,meth) {
	o.menucmd("On",po,"setbounce",1)
	o.menucmd("Off",po,"setbounce",0)
}
function mkmenu_quixqvals(o,po,meth) {
	o.menucmd("None",po,meth,1)
	o.menucmd("1b",po,meth,1b)
	o.menucmd("2b",po,meth,2b)
	o.menucmd("4b",po,meth,4b)
	o.menucmd("8b",po,meth,8b)
}

function mkmenu_quixleng(o,po,meth) {
	o.menucmd("4b",po,meth,4b)
	o.menucmd("8b",po,meth,8b)
	o.menucmd("16b",po,meth,16b)
	o.menucmd("32b",po,meth,32b)
}

