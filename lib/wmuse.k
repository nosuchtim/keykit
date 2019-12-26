class wmuse {
method init {
	$.w = new window()
	$.inherit($.w)
	$.ph1 = new wphrase()
	$.addchild($.ph1)

	algs = [0="Markov",1="WordPlay 1", 2="WordPlay 2"]
	$.b1 = new kvalbutton(algs,$,"algchanged")
	lengs = [0="32b", 1="128b"]
	$.b2 = new kvalbutton(lengs)
	$.markovvals = [0="bachinv1", 1="bachinv2", 2="bachinv3"]
	$.wordvals = [0="midi", 1="wordplay", 2="museomat"]
	$.vals = $.markovvals
	$.b3 = new kvalbutton($.vals)
	$.addchild($.b1)
	$.addchild($.b2)
	$.addchild($.b3)

	$.isset = 0
	$.stoptids = []
}
method algchanged (v) {
	changed = 0
	if ( v == 0 ) {
		if ( $.vals != $.markovvals ) {
			$.vals = $.markovvals
			changed = 1
		}
	}
	else if ( v == 1 ) {
		if ( $.vals != $.wordvals ) {
			$.vals = $.wordvals
			changed = 1
		}
	}
	else if ( v == 2 ) {
		if ( $.vals != $.wordvals ) {
			$.vals = $.wordvals
			changed = 1
		}
	}
	if ( changed ) {
		$.b3.setvals($.vals)
		$.b3.set(0)
		$.b3.redraw()
	}
}
method redraw {
	$.w.redraw()
	methodbroadcast();
	$.w.line(xy($.xmin()+4,$.y0a-2,$.xmax()-4,$.y0a-2))
	$.w.text("Museomat",xy($.xmin(),$.ymin(),$.xmax(),$.y0a))
	$.w.textright("Algorithm:", xy($.x0,$.y0a,$.x0+$.dx,$.y0a+$.dy))
	$.w.textright("Length:", xy($.x0,$.y0a+$.dy,$.x0+$.dx,$.y0a+2*$.dy))
	$.w.textright("Input:", xy($.x0,$.y0a+2*$.dy,$.x0+$.dx,$.y1))
}
method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	$.dx = ($.xmax()-$.xmin()) / 4
	$.y0 = $.ymin()+2
	$.y0a = $.ymin() + $.textheight() + 4
	$.dy = ( $.ymax() - $.y0a ) / 3
	$.x0 = $.xmin() + 2
	$.x1 = $.xmax() - 2
	$.y1 = $.ymax() - 2
	$.b1.resize(xy($.x0+$.dx,$.y0a+2,$.x0+2*$.dx-1,$.y0a+$.dy-1))
	$.b2.resize(xy($.x0+$.dx,$.y0a+$.dy+1,$.x0+2*$.dx-1,$.y0a+2*$.dy-1))
	$.b3.resize(xy($.x0+$.dx,$.y0a+2*$.dy+1,$.x0+2*$.dx-1,$.y1))
	$.ph1.resize(xy($.x0+2*$.dx+1,$.y0a+2,$.x1,$.y1))
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
method play (stime) {
	if ( $.ph1.isplaying() )
		$.stop()
	if ( nargs() < 1 ) {
		stime = nextquant(Now,1b)
	}
	tid = $.ph1.play(stime,1b)
	$.stoptids[tid] = 1
}
method stop {
	killtids($.stoptids)
	$.stoptids = []
	$.ph1.stop()
}
method mousedown (m) {
	if ( $.ph1.contains(m) ) {
		if ( $.ph1.isplaying() )
			$.stop()
		else {
			tid = $.ph1.play(nextquant(Now,1b))
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
method snarf { Snarf = $.ph1.get() }
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
	$.ph1.set(p,0)
	$.ph1.fitall()
	$.ph1.redraw()
}

}

function mkmenu_muse1(o,po) {
	o.submenu("Word 1 ->","mkmenu_museread",po)
	o.submenu("Word 2 ->","mkmenu_museset",po);
}

function mkmenu_museset(o,po) {
	o.submenu("Win 1b/8 ->","mkmenu_museset2",po,1b/8)
	o.submenu("Win 1b/4 ->","mkmenu_museset2",po,1b/4)
	o.submenu("Win 1b/2 ->","mkmenu_museset2",po,1b/2)
	o.submenu("Win 1b ->","mkmenu_museset2",po,1b)
	o.submenu("Win 2b ->","mkmenu_museset2",po,2b)
}

function mkmenu_museset2(o,po,win) {
	o.menucmd("Inc 1b/16",po,"setsim",win,1b/16)
	o.menucmd("Inc 1b/8",po,"setsim",win,1b/8)
	o.menucmd("Inc 1b/4",po,"setsim",win,1b/4)
	o.menucmd("Inc 1b/2",po,"setsim",win,1b/2)
	o.menucmd("Inc 1b",po,"setsim",win,1b)
}


function mkmenu_museread(o,po) {
	o.menucmd("File",po,"loadfile")
	o.menucmd("Snarf",po,"loadsnarf")
}

function mkmenu_muse2(o,po) {
	o.submenu("Make Sim ->","mkmenu_muse3",po)
	o.menucmd("Snarf",po,"snarf")
}

function mkmenu_muse3(o,po) {
	for ( n=16; n<64; n+=16 )
		o.menucmd(string(n)+" times",po,"makesim",n)
	for ( n=64; n<256; n+=64 )
		o.menucmd(string(n)+" times",po,"makesim",n)
	for ( n=256; n<1024; n+=256 )
		o.menucmd(string(n)+" times",po,"makesim",n)
	for ( n=1024; n<4096; n+=1024 )
		o.menucmd(string(n)+" times",po,"makesim",n)
}
