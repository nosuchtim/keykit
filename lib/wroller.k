#define FULLON 4
#define SPEEDFACTOR 5

class wroller {

method init (nctrls) {

	$.w = new window()
	$.inherit($.w)

	cl = controllerlist(1)
	$.cname = []
	$.cval = []
	for ( i in cl ) {
		$.cname[i] = cl[i]["name"]
		$.cval[i] = cl[i]["value"]
	}
	$.lfotypes = [0="sine",1="ramp up",2="ramp down",3="square",4="random"]
	$.ch = 1
	$.startquant = 1
	$.nsteps = 16
	$.lfosteps = 128
	$.speednorm = 100
	$.ison = 0
	$.loopid = -1
	$.inc = FULLON
	$.totaltrans = 0
	$.sweepsize = 1b/32
	$.lfosize = 1b/8
	if ( $.sweepsize <= 0 )
		$.sweepsize = 1
	if ( nargs() < 1 )
		nctrls = 4
	$.nctrls = 0
	$.ctrlbutt = []
	$.lowslider = []
	$.highslider = []
	$.sweep1butt = []
	$.sweep2butt = []
	$.speedslider = []
	$.lfobutton = []
	$.lfotype = []
	$.valslider = []

	$.lfoid = []
	$.lfostep = []
	$.lfospeed = []

	$.setnctrls(nctrls)

	$.b1 = new kmenubutton("More","mkmenu_roller1",$)
	$.phr = new wphrase()
	$.phr.set(step(repeat('c',16),1b/4))
	$.phr.dozoomout(0,"xy")
	$.b3 = new ktoggle("Loop",$,"setlooponoff")
	chans = []
	for ( n=0; n<16; n++ ) {
		chans[n] = "Ch "+string(n+1)
	}
	$.cb = new kvalbutton(chans,$,"setchan")
	$.rbutt = new kbutton("R",$,"randomize")

	$.addchild($.phr)
	$.addchild($.b1)
	$.addchild($.b3)
	$.addchild($.cb)
	$.addchild($.rbutt)

}

method setchan(ch) {
	$.ch = ch + 1
	p = $.phr.get()
	p.chan = $.ch
	$.phr.set(p)
}

method set(p) {
	$.phr.set(p)
	$.phr.dozoomout(1,"xy")
}

method changectrls(inc) {
	$.setnctrls($.nctrls + inc)
	$.resize()
	$.redraw()
}

method dump() {
	st = []
	st["nctrls"] = $.nctrls
	st["c"] = []
	st["phr"] = $.phr.get()
	st["ch"] = $.ch
	for ( n=0; n<$.nctrls; n++ ) {
		st["c"][n] = [
			"ctrl"=$.ctrlbutt[n].get(),
			"low"=$.lowslider[n].get(),
			"high"=$.highslider[n].get(),
			"speed"=$.speedslider[n].get(),
			"lfotype"=$.lfotype[n].get()
		]
	}
	return(st)
}

method restore(st) {
	nd = st["nctrls"]
	$.setnctrls(nd)
	for ( n=0; n<$.nctrls; n++ ) {
		c = st["c"][n]
		$.ctrlbutt[n].set(c["ctrl"],0)
		$.lowslider[n].set(c["low"],0)
		$.highslider[n].set(c["high"],0)
		$.speedslider[n].set(c["speed"],0)
		$.lfotype[n].set(c["lfotype"],0)
	}
	$.phr.set(st["phr"])
	$.setchan(st["ch"]-1)
	$.resize()
}

method redraw() {
	$.w.redraw()
	$.w.text("Roller Derby",xy($.xmin(),$.ymin(),$.xmid0,$.ymin()+$.textheight()))
	$.w.text("Low",xy($.xs[0],$.ym0a,$.xs[1],$.ym0b))
	$.w.text("High",xy($.xs[1],$.ym0a,$.xs[2],$.ym0b))
	$.w.text("Sweep",xy($.xs[2],$.ym0a,$.xs[4],$.ym0b))
	$.w.text("Speed",xy($.xs[4],$.ym0a,$.xs[5],$.ym0b))
	methodbroadcast()
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	th = $.textheight()
	tw = $.textwidth()
	dp = 1

	x0 = $.xmin()
	y0 = $.ymin()
	x1 = $.xmax()
	y1 = $.ymax()
	x0b = $.xmin() + ($.xmax()-$.xmin())/3
	ty = th + 4

	nctrls = $.nctrls
	ystart = []
	$.ym0a = y0 + ty
	$.ym0b = y0 + 2*ty
	topbar = 2*ty
	for ( dn=0; dn<=nctrls; dn++ ) {
		ystart[dn] = y0 + topbar + (dn*(y1-y0-topbar))/nctrls
	}

	$.xmid0 = x0 + 14*tw
	rm = ($.xmin()+$.xmax())/2
	if ( $.xmid0 > rm )
		$.xmid0 = rm
	$.xmid1 = ($.xmid0 + x1)/2
	$.xmid2 = ($.xmid1 + x1)/2

	xmarg = 2
	ymarg = 2

	dx = (x1-$.xmid0)/5
	$.phr.resize(xy($.xmid0,y0+1,$.xmid0+dx-xmarg,$.ym0a))
	$.rbutt.resize(xy($.xmid0+dx+xmarg,y0+1,$.xmid0+2*dx-xmarg,$.ym0a))
	$.b3.resize(xy($.xmid0+2*dx+xmarg,y0+1,$.xmid0+3*dx-xmarg,$.ym0a))
	$.b1.resize(xy($.xmid0+3*dx+xmarg,y0+1,$.xmid0+4*dx-xmarg,$.ym0a))
	$.cb.resize(xy($.xmid0+4*dx+xmarg,y0+1,x1-xmarg,$.ym0a))

	ddx = (x1 - $.xmid0) / 8
	$.xs = []
	for ( n=0; n<8; n++ ) {
		$.xs[n] = $.xmid0 + n*ddx
	}
	for ( dn=0; dn<nctrls; dn++ ) {
		ym1 = ystart[dn]+ymarg
		ym2 = ystart[dn+1]-ymarg
		$.ctrlbutt[dn].resize(xy(x0+xmarg,ym1,$.xs[0]-xmarg,ym2))

		$.lowslider[dn].resize(xy($.xs[0]+xmarg,ym1,$.xs[1]-xmarg,ym2))
		$.highslider[dn].resize(xy($.xs[1]+xmarg,ym1,$.xs[2]-xmarg,ym2))
		$.sweep1butt[dn].resize(xy($.xs[2]+xmarg,ym1,$.xs[3]-xmarg,ym2))
		$.sweep2butt[dn].resize(xy($.xs[3]+xmarg,ym1,$.xs[4]-xmarg,ym2))
		$.speedslider[dn].resize(xy($.xs[4]+xmarg,ym1,$.xs[5]-xmarg,ym2))
		$.lfotype[dn].resize(xy($.xs[5]+xmarg,ym1,$.xs[6]-xmarg,ym2))
		$.lfobutton[dn].resize(xy($.xs[6]+xmarg,ym1,$.xs[7]-xmarg,ym2))
		$.valslider[dn].resize(xy($.xs[7]+xmarg,ym1,x1-xmarg,ym2))
	}
}

method snarf() {
	Snarf = $.get()
}
method get() {
	r = ''
	for ( dn=0; dn<$.nctrls; dn++ ) {
		v = $.valslider[dn].get()
		r |= $.notefor(dn,v)
	}
	return(r)
}

method speedchange(v,dn) {
	$.lfospeed[dn] = v/float($.speednorm)
}

method lowchange(v,dn) {
	$.playcontroller(dn,$.lowslider[dn].get())
}
method highchange(v,dn) {
	$.playcontroller(dn,$.highslider[dn].get())
}

method playcontroller(dn,v) {
	p = $.notefor(dn,v)
	realmidi(p)
}

method notefor(dn,v) {
	n = $.ctrlbutt[dn].get()
	cn = $.cval[n]
	p = controller($.ch,cn,v)
	return(p)
}

method sweepup(dn) {
	task $.sweeptask(dn,0)
}
method sweepdown(dn) {
	task $.sweeptask(dn,1)
}

method sweeptask(dn,down) {
	v0 = $.lowslider[dn].get()
	v1 = $.highslider[dn].get()
	if ( down ) {
		t = v0
		v0 = v1
		v1 = t
	}

	if ( v1 > v0 ) 
		inc = 1
	else
		inc = -1

	starttm = nextquant(Now,$.startquant)
	tm = starttm
	for ( v=v0; ; v += inc ) {
		$.playcontroller(dn,v)
		tm += $.sweepsize
		sleeptill(tm)
		if ( v == v1 )
			break
	}
}

method randomize() {
	for ( dn=0; dn<$.nctrls; dn++ ) {
		v = rand(128)
		$.valslider[dn].setndo(v)
	}
}

method setnctrls (nctrls) {
	while ( nctrls > $.nctrls ) {
		dn = $.nctrls

		$.ctrlbutt[dn] = new kvalbutton($.cname,$,"setctrl",dn)
		$.lowslider[dn] = new kslider(0,127,10,$,"lowchange",dn)
		$.highslider[dn] = new kslider(0,127,120,$,"highchange",dn)
		$.sweep1butt[dn] = new kbutton("Up",$,"sweepup",dn)
		$.sweep2butt[dn] = new kbutton("Down",$,"sweepdown",dn)
		$.speedslider[dn] = new kslider(1,SPEEDFACTOR*$.speednorm,$.speednorm,$,"speedchange",dn)

		$.lfotype[dn] = new kvalbutton($.lfotypes,$,"setctrl",dn)
		$.lfobutton[dn] = new ktoggle("LFO",$,"lfoonoff",dn)
		$.valslider[dn] = new kslider(0,127,10,$,"valsliderchange",dn)


		$.addchild($.ctrlbutt[dn])
		$.addchild($.lowslider[dn])
		$.addchild($.highslider[dn])
		$.addchild($.sweep1butt[dn])
		$.addchild($.sweep2butt[dn])
		$.addchild($.speedslider[dn])
		$.addchild($.lfotype[dn])
		$.addchild($.lfobutton[dn])
		$.addchild($.valslider[dn])

		$.initctrl(dn)

		$.nctrls++
	}
	while ( nctrls < $.nctrls && $.nctrls > 1 ) {
		$.nctrls--
		dn = $.nctrls
		$.rmdelete($.ctrlbutt[dn])
		$.rmdelete($.lowslider[dn])
		$.rmdelete($.highslider[dn])
		$.rmdelete($.sweep1butt[dn])
		$.rmdelete($.sweep2butt[dn])
	}
}

method initctrl(dn) {
	$.lfoid[dn] = -1
	$.lfospeed[dn] = 1.0
}

method rmdelete(o) {
	$.removechild(o)
	deleteobject(o)
}

method setctrl (dn,nt,nm) {
	# print("setctrl, dn=",dn," nt=",nt)
}

method delete {
	for ( n=0; n<$.nctrls; n++ ) {
		if ( $.lfoid[n] >= 0 )
			kill($.lfoid[n])
	}
	if ( $.loopid >= 0 )
		kill($.loopid)
}

method setlooponoff (v) {
	if ( v ) {
		$.loopon()
	}
	else {
		$.loopoff()
	}
}
method loopon {
	lock($)
	if ( $.loopid < 0 )
		$.loopid = task $.task_rollerloop()
	unlock($)
}
method loopoff() {
	lock($)
	if ( $.loopid >= 0 ) {
		kill($.loopid)
		$.loopid = -1
	}
	unlock($)
}
method loopstop {
	$.b3.set(0)
	$.b3.redraw()
	$.loopoff()
}
method task_rollerloop() {
	starttm = nextquant(Now,$.startquant)
	onexit(global(domethod),$.phr,"stop")
	tm = starttm
	while ( 1 ) {
		p = $.phr.get()
		$.phr.play(tm,1)	# no quantization of start time
		tm += p.length
		sleeptill(tm-1)
	}
}

method lfoonoff (v,m,dn) {
	if ( v )
		$.lfoon(dn)
	else
		$.lfostop(dn)
}
method lfoon(dn) {
	lock($)
	if ( $.lfoid[dn] < 0 )
		$.lfoid[dn] = task $.task_rollerlfo(dn)
	unlock($)
}
method lfooff(dn) {
	lock($)
	if ( $.lfoid[dn] >= 0 ) {
		kill($.lfoid[dn])
		# There's a bug, somewhere - there are cases when you try
		# to kill a task and it doesn't die...
		while ( taskinfo($.lfoid[dn],"status") != "" ) {
			print("MULTIPLE ATTEMPTS NEEDED TO KILL ",$.lfoid[dn],"??")
			kill($.lfoid[dn])
		}
		$.lfoid[dn] = -1
	}
	unlock($)
}
method lfostop(dn) {
	$.lfobutton[dn].set(0)
	$.lfobutton[dn].redraw();
	$.lfooff(dn)
}
method task_rollerlfo(dn) {
	starttm = nextquant(Now,$.startquant)
	$.lfostep[dn] = 0
	tm = starttm
	while ( 1 ) {
		lfotype = $.lfotype[dn].get()
		tm += $.lfosize
		if ( lfotype == 4 ) {
			tm += (SPEEDFACTOR - $.lfospeed[dn]) * $.lfosize
		}
		$.lfostep[dn] = $.lfostep[dn] + $.lfospeed[dn]
		if ( $.lfostep[dn] > $.lfosteps )
			$.lfostep[dn] -= $.lfosteps

		v = lfovalue($.lfostep[dn],$.lfosteps,lfotype,
			$.lowslider[dn].get(),$.highslider[dn].get())
		$.setvalue(dn,v)
		$.playcontroller(dn,v)
		sleeptill(tm-1b/4)
	}
}

method valsliderchange(v,dn) {
	$.playcontroller(dn,v)
}

method setvalue(dn,v) {
	$.valslider[dn].set(v,1)
}

method loadnord() {
	nf = browsefiles("Nord patches (*.pch)","*.pch",1)
	if ( nf == "" ) {
		print("Patch loading cancelled")
		return()
	}
	f = open(nf)
	magic = "[Controllers]"
	mlen = sizeof(magic)
	c = []
	nc = 0
	while ( (line=get(f)) != Eof ) {
		if ( substr(line,1,mlen) == magic ) {
			while ( (line=get(f)) != Eof ) {
				c1 = substr(line,1,1)
				if ( c1 == "M" ) {
					cc = integer(substr(line,2))
					c[nc++] = cc
				}
				if ( c1 == "[" || c1 == "" )
					break
			}
			break
		}
	}
	close(f)
	if ( nc < 1 ) {
		print("No controllers found!?")
		return()
	}
	$.setnctrls(nc)
	for ( n=0; n<nc; n++ ) {
		$.ctrlbutt[n].set(c[n])
	}
	$.resize()
	$.redraw()
}

}

function mkmenu_roller1(o,po) {
	o.submenu("# of Ctrls ->","mkmenu_roller5",po)
	o.menucmd("Load Nord Patch",po,"loadnord")
	o.menucmd("Snarf",po,"snarf")
}

function mkmenu_roller5(o,po) {
	o.menucmd("Add 1",po,"changectrls",1)
	o.menucmd("Add 4",po,"changectrls",4)
	o.menucmd("Delete 1",po,"changectrls",-1)
	o.menucmd("Delete 4",po,"changectrls",-4)
}

function lfovalue(stepnum,nsteps,lfotype,v0,v1) {
	v = v0
	if ( lfotype == 0 ) {
		# sine
		# sine value goes from 0 to 2*pi
		dv = v1-v0
		dm = v0 + dv/2
		v = dm + (dv/2)*sin(stepnum*2*3.14159/(nsteps-1))
	} else if ( lfotype == 1 ) {
		# up
		v = v0 + (v1-v0)*stepnum/(nsteps-1)
	} else if ( lfotype == 2 ) {
		# down
		v = v1 - (v1-v0)*stepnum/(nsteps-1)
	} else if ( lfotype == 3 ) {
		# square
		if ( stepnum < nsteps/2 )
			v = v0
		else
			v = v1
	} else if ( lfotype == 4 ) {
		# random
		v = v0 + (v1-v0)*rand(128)/128
	} else {
		print("Unknown lfovalue type? type=",lfotype)
		v = v0
	}
	return(v)
}

