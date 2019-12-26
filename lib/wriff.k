class wriff {
method init {
	$.w = new window()
	$.inherit($.w)

	$.ph = new wphrase()
	$.b1 = new kmenubutton("More","mkmenu_riff1",$)
	$.t1 = new ktoggle("On",$,"setvar","on")
	$.t2 = new ktoggle("Loop",$,"setvar","loop")
	$.addchild($.ph)
	$.addchild($.b1)
	$.addchild($.t1)
	$.addchild($.t2)

	$.startquant = 1
	$.loopquant = 1
	$.retrigger = 1
	$.loop = 0
	$.factor = 1.0
	$.ison = 0
	$.leng = 0
	$.nexttranspose = 0
	$.stoptids = []
	$.origp = ''
	$.listentokey = 0
	$.basekey = 'c'
	$.currentkey = 'c'
	$.neverfit = 0
}
method viewset(...) { $.ph.viewset(...) }
method wayout { $.ph.wayout() }
method redraw { $.w.redraw() ; methodbroadcast(); }

method delete {
			killtids($.stoptids)
			$.stoptids = []
			}

method setvar (v,m,nm) {
			if ( nm == "on" ) {
				if ( v ) $.play(); else $.stop()
			}
			$.(nm) = v
			return(99)
		}
method strip { $.set(strip($.ph.get()),1) }
method bang {
			if ( $.ison )
				$.stop()
			else
				$.play()
			}
method setstartquant (v) { $.startquant = v }
method setlooping (v) {
	$.loop = v
	$.t2.set(1)
}
method setloopquant (v) { $.loopquant = v }
method setfactor(f) {
	$.factor = f
	$.set($.get(),1)
}
method get { return($.origp) }
method set (p,doredraw) {
				$.origp = p
				if ( $.factor != 1.0 )
					p = scatimes(p,$.factor)
				if ( $.listentokey != 0 ) {
					tr = canonic(Key)-canonic($.basekey)
					p = transpose($.origp,tr)
				}
				$.ph.set(p,0)
				$.leng = p.length
				if ( $.neverfit == 0 )
					$.ph.fitall()
				if ( nargs() > 1 && doredraw )
					$.redraw()
				}
method mousedown (m) {
				if ( $.ph.contains(m) )
					$.bang()
				else {
					mouseforward(m,"mousedown")
				}
			}
method dump {
	return ( [
		"startquant" = $.startquant,
		"loopquant" = $.loopquant,
		"loop" = $.loop,
		"phrase" = $.ph.get()
		] )
}
method restore (state) {
	$.set(state["phrase"])
	$.startquant = state["startquant"]
	$.loopquant = state["loopquant"]
	$.loop = state["loop"]
	if ( $.loop ) {
		$.t2.set(1)
	}
}
method setretrigger (v) { $.retrigger = v }
method setlistentokey (v,k) { $.listentokey = v; $.basekey = k }
method setneverfit (v) { $.neverfit = v; }
method loadrec (space) {
	p = lastbunch(Recorded,space)
	p = syncphr(p)
	if ( (p%1).time > (Met.length/2) ) {
		p.time -= Met.length
		p.length -= Met.length
	}
	$.set(p,1)
}
method snarf { Snarf = $.ph.get() }
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
	ph = browsephrase()
	if ( sizeof(ph) > 0 )
		$.set(ph,1)
}

method transpose(v) {
	$.nexttranspose += integer(v)
}
method play(stime) {
	$.ison = 1
	qnt = $.startquant
	if ( nargs() < 1 ) {
		if ( qnt == 1 )
			stime = Now
		else
			stime = nextquant(Now,qnt)
	}
	if ( $.nexttranspose != 0 ) {
		$.ph.transpose($.nexttranspose)
		$.nexttranspose = 0
		$.ph.fitall()
		$.ph.redraw()
	}
	if ( $.listentokey != 0 && $.currentkey != Key ) {
		$.currentkey = Key
		$.set($.origp,1)	# This will pay attention to Key
		tr = canonic(Key)-canonic($.basekey)
		p = transpose($.origp,tr)
		$.ph.set(p,0)
		$.leng = p.length
	}
	tid = $.ph.play(stime,qnt)
	$.stoptids[tid] = 1

	if ( $.t1.get() == 0 ) {	# to avoid flash
		$.t1.set(1)
		$.t1.redraw()
	}
	$.looplng = numquant($.leng, $.loopquant)
	if ( $.looplng == 0 )
		$.looplng = $.loopquant
	tid = task $.wriffchk(stime+$.looplng)
	$.stoptids[tid] = 1
}

method stop {
	killtids($.stoptids)
	$.stoptids = []
	$.setoff()
}

method seton {
	if ( ! $.ison ) {
		$.play()
	}
}

method setoff {
	$.ison = 0
	$.t1.set(0)
	$.t1.redraw()
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	dx = ($.xmax()-$.xmin()) / 3
	y0 = $.ymin()+2
	y0a = $.ymin() + $.textheight() + 4
	x0 = $.xmin() + 2
	x1 = $.xmax() - 2
	y1 = $.ymax() - 2
	$.t1.resize(xy(x0,y0,x0+dx-1,y0a))
	$.b1.resize(xy(x0+dx+1,y0,x0+2*dx-1,y0a))
	$.t2.resize(xy(x0+2*dx+1,y0,x1,y0a))
	$.ph.resize(xy(x0,y0a+2,x1,y1))
}
method wriffchk(tm) {
	sleeptill(tm-milliclicks(50))
	if ( $.ison ) {
		if ( $.loop!=0 && $.looplng>0 ) {
			$.play(tm)
		}
		else {
			$.setoff()
		}
	}
}
}

function mkmenu_riff2(o,po) {
	o.menucmd("On",po,"setretrigger",1)
	o.menucmd("Off",po,"setretrigger",0)
}
function mkmenu_listentokey(o,po) {
	o.menucmd("On",po,"setlistentokey",1,'c')
	o.menucmd("Off",po,"setlistentokey",0,'c')
}

function mkmenu_riffqvals(o,po,meth) {
	o.menucmd("None",po,meth,1)
	o.menucmd("1b",po,meth,1b)
	o.menucmd("2b",po,meth,2b)
	o.menucmd("4b",po,meth,4b)
	o.menucmd("8b",po,meth,8b)
}

function mkmenu_riff1(o,po) {
	o.menucmd("Load Rec (1b space)",po,"loadrec",1b)
	o.menucmd("Load Rec (4b space)",po,"loadrec",4b)
	o.menucmd("Load from Snarf",po,"loadsnarf")
	o.menucmd("Load from File",po,"loadfile")
	o.submenu("Loop Quant      ->","mkmenu_riffqvals",po,"setloopquant")
	o.submenu("Retrigger       ->","mkmenu_riff2",po)
	o.submenu("Listen to Key   ->","mkmenu_listentokey",po)
	o.submenu("Start Quant     ->","mkmenu_riffqvals",po,"setstartquant")
	o.menucmd("Snarf",po,"snarf")
	o.menucmd("Strip",po,"strip")
}

