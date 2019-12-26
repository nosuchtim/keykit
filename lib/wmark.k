class wmark {
method init {
	$.w = new window()
	$.inherit($.w)
	$.ph1 = new wphrase()
	$.ph2 = new wphrase()
	$.addchild($.ph1)
	$.addchild($.ph2)

	$.b1 = new kmenubutton("Orig","mkmenu_mark1",$)
	$.b2 = new kmenubutton("Sim","mkmenu_mark2",$)
	$.addchild($.b1)
	$.addchild($.b2)

	$.isset = 0
	$.stoptids = []
}
method redraw {
	$.w.redraw()
	methodbroadcast();
	$.w.text("Markov Maker",
		xy($.xmin(),$.ymin(),$.xmax(),$.ymin()+$.textheight()+4))
}
method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	dx = ($.xmax()-$.xmin()) / 6
	dy = ($.ymax()-$.ymin()) / 3
	y0 = $.ymin()+2
	y0a = $.ymin() + $.textheight() + 4
	y0b = ( y0a + $.ymax() ) / 2
	x0 = $.xmin() + 2
	x1 = $.xmax() - 2
	y1 = $.ymax() - 2
	$.b1.resize(xy(x0+1,y0a+2,x0+dx-1,y0b-2))
	$.b2.resize(xy(x0+1,y0b+2,x0+dx-1,y1))
	$.ph1.resize(xy(x0+dx+1,y0a+2,x1,y0b-2))
	$.ph2.resize(xy(x0+dx+1,y0b+2,x1,y1))
}
method delete {
	killtids($.stoptids)
	$.stoptids = []
}
method set (p,doredraw) {
	p = onlynotes(p)
	$.ph1.set(p,0)
	$.ph1.fitall()
	if ( nargs() > 1 && doredraw )
		$.ph1.redraw()
	$.isset = 0
}
method get {
	return($.ph2.get())
}
method play (stime) {
	if ( $.ph1.isplaying() || $.ph2.isplaying() )
		$.stop()
	if ( nargs() < 1 ) {
		stime = nextquant(Now,1b)
	}
	tid = $.ph2.play(stime,1b)
	$.stoptids[tid] = 1
}
method stop {
	killtids($.stoptids)
	$.stoptids = []
	$.ph1.stop()
	$.ph2.stop()
}
method mousedown (m) {
	if ( $.ph1.contains(m) ) {
		if ( $.ph1.isplaying() || $.ph2.isplaying() )
			$.stop()
		else {
			tid = $.ph1.play(nextquant(Now,1b))
			$.stoptids[tid] = 1
		}
	}
	else if ( $.ph2.contains(m) ) {
		if ( $.ph1.isplaying() || $.ph2.isplaying() )
			$.stop()
		else {
			tid = $.ph2.play(nextquant(Now,1b))
			$.stoptids[tid] = 1
		}
	}
	else {
		mouseforward(m,"mousedown")
	}
}
method dump {
	return ( [ "phrase" = $.ph1.get() ] )
}
method restore (state) { $.set(state["phrase"]) }
method snarforig { Snarf = $.ph1.get() }
method snarf { Snarf = $.ph2.get() }
method loadsnarf {
	p = Snarf
	p = syncphr(p)
	if ( (p%1).time > (Met.length/2) ) {
		p.time -= Met.length
		p.length -= Met.length
	}
	$.set(p,1)
}
method loadfile {
	$.stop()
	ph = browsephrase()
	if ( sizeof(ph) > 0 )
		$.set(ph,1)
}
method setsim (win,inc) {
	o = new kmsg("Setting sim...")
	o.resize($.ph1.size())
	o.redraw()
	setsim($.ph1.get(),win,inc,"p")
	deleteobject(o)
	$.isset = 1
}
method makesim (n) {
	if ( $.isset == 0 ) {
		print("You need to do a 'Set sim->' !")
		return()
	}
	p = makesim(n)
	$.ph2.set(p,0)
	$.ph2.fitall()
	$.ph2.redraw()
}

}

function mkmenu_mark1(o,po) {
	o.submenu("Read    ->","mkmenu_markread",po)
	o.submenu("Set Sim ->","mkmenu_markset",po);
	o.menucmd("Snarf",po,"snarforig")
}

function mkmenu_markset(o,po) {
	o.submenu("Win 1b/8 ->","mkmenu_markset2",po,1b/8)
	o.submenu("Win 1b/4 ->","mkmenu_markset2",po,1b/4)
	o.submenu("Win 1b/2 ->","mkmenu_markset2",po,1b/2)
	o.submenu("Win 1b ->","mkmenu_markset2",po,1b)
	o.submenu("Win 2b ->","mkmenu_markset2",po,2b)
}

function mkmenu_markset2(o,po,win) {
	o.menucmd("Inc 1b/16",po,"setsim",win,1b/16)
	o.menucmd("Inc 1b/8",po,"setsim",win,1b/8)
	o.menucmd("Inc 1b/4",po,"setsim",win,1b/4)
	o.menucmd("Inc 1b/2",po,"setsim",win,1b/2)
	o.menucmd("Inc 1b",po,"setsim",win,1b)
}


function mkmenu_markread(o,po) {
	o.menucmd("File",po,"loadfile")
	o.menucmd("Snarf",po,"loadsnarf")
}

function mkmenu_mark2(o,po) {
	o.submenu("Make Sim ->","mkmenu_mark3",po)
	o.menucmd("Snarf",po,"snarf")
}

function mkmenu_mark3(o,po) {
	for ( n=16; n<64; n+=16 )
		o.menucmd(string(n)+" times",po,"makesim",n)
	for ( n=64; n<256; n+=64 )
		o.menucmd(string(n)+" times",po,"makesim",n)
	for ( n=256; n<1024; n+=256 )
		o.menucmd(string(n)+" times",po,"makesim",n)
	for ( n=1024; n<4096; n+=1024 )
		o.menucmd(string(n)+" times",po,"makesim",n)
}
