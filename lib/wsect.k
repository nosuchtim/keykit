class wsect {
method init {
	$.w = new window()
	$.inherit($.w)

	$.ph = new wphrase()
	$.b1 = new kmenubutton("More","mkmenu_sect1",$)
	$.addchild($.ph)
	$.addchild($.b1)

	$.startquant = 1b
	$.nsect = 0
	$.loopquant = 1
	$.retrigger = 1
	$.maxsect = 4b
	$.repeat = 0
	$.loop = 0
	$.leng = 0
	$.strip = 0
	$.step = 0
	$.nexttranspose = 0
	$.taskid = task $.task_wsect()
	$.stoptids = []
	$.stoptids[$.taskid] = 1
	$.ison = 1
	$.initrange = 0
	$.lownote = 0
	$.highnote = 127
	$.lastid = -1
	$.playingid = -1
	Merge=0
	print("Turning Merge off...")
}
method wayout { $.ph.wayout() }
method redraw { $.w.redraw() ; methodbroadcast(); }

method delete {
		killtids($.stoptids)
		$.stoptids = []
		print("Turning Merge back on...")
		Merge=1
		}

method task_wsect() {
	Midiin[$] = f = open()
	onexit(closemidi,$)
	while ( (m=get(f)) != Eof ) {
		# ph = $.phrase
		if ( m.type==NOTEON ) {
			if ( $.initrange==1 ) {
				$.lownote = m.pitch
				$.initrange = 2
				continue
			}
			if ( $.initrange==2 ) {
				$.highnote = m.pitch
				$.resection()
				$.initrange = 0
				continue
			}
			n = m.pitch - $.lownote
			if ( n < 0 || n >= $.nsect ) {
				print("not in range?  m=",m)
				realtime(m,0)		# play things that aren't in the range
			} else {
				task $.playsection(n,m.vol)
			}
		}
		else if ( m.type==CONTROLLER ) {
			if ( subbytes(m,2,1) == 0x40 ) {
				if ( subbytes(m,3,1) == 0x00 )
					$.repeat = 0
				else
					$.repeat = 1
			}
		}
		else
				realtime(m,0)
	}
}

method setmaxsect (v) { $.maxsect = v }
method setstartquant (v) { $.startquant = v }
method get { return($.ph.get()) }
method set (p,doredraw) {
	$.ph.set(p,0)
	$.leng = p.length
	$.ph.fitall()
	$.arr = []
	$.resection()
	if ( nargs() > 1 && doredraw )
		$.redraw()
}
method resection() {
	narr = $.highnote - $.lownote
	print("high=",$.highnote," low=",$.lownote," narr=",narr)
	s1 = $.leng / narr
	if ( s1 <= 0 ) {
		s1 = 1
	}
	qnt = 2b
	$.sectsize = numquant( s1 , qnt )
	while ( $.sectsize <= 0 ) {
		qnt /= 2
		if ( qnt == 0 ) {
			print("Bad news in resection!?")
			break
		}
		$.sectsize = numquant( s1 , qnt )
	}
	$.nsect = $.leng / $.sectsize
	$.origsectsize = $.sectsize
	if ( $.sectsize > $.maxsect )
		$.sectsize = $.maxsect
	p = $.ph.get()
	for ( n=0; n < $.nsect; n++ ) {
		p2 = cut(p,CUT_TIME,n*$.origsectsize,n*$.origsectsize+$.sectsize)
		p2 -= nonnotes(p2)
		p2.time -= numquant(p2%1.time,$.sectsize)
		if ( p2%1.time < 0 )
			p2.time += $.sectsize
		if ( $.strip )
			p2 = strip(p2)
		if ( $.step ) {
print("arpeg")
			p2 = arpeggio(p2)
			p2 = step(p2,1b/4)
		}
		$.arr[n] = p2
	}
}
method playsection(n,v) {
	t = nextquant(Now,$.startquant)
	# we don't want to kill the existing one till the new one starts
	sleeptill(t)
	lock($)
	if ( $.retrigger ) {
		kill($.lastid)
		kill($.playingid)
	}
	p = $.arr[n]
	if ( nargs() > 1 ) {
		p.vol = v
	}
	$.lastid = task $.playit(p,t)
	unlock($)
}
method playit(p,t) {
	while ( 1 ) {
		p = transpose(p,canonic(Key)-canonic('c'))
		print("playit = ",p)
		$.playingid = realtime(p,t)
		t += $.sectsize
		sleeptill(t)
		if ( $.repeat == 0 )
			break;
	}
}
method dump {
	return ( [ "phrase" = $.ph.get() ] )
}
method restore (state) { $.set(state["phrase"]) }
method setretrigger (v) { $.retrigger = v }
method setrepeat (v) { $.repeat = v }
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
	tid = $.ph.play(stime,qnt)
	$.stoptids[tid] = 1

	$.looplng = numquant($.leng, $.loopquant)
	if ( $.looplng == 0 )
		$.looplng = $.loopquant
	tid = task $.wsectchk(stime+$.looplng)
	$.stoptids[tid] = 1
}

method stop {
	killtids($.stoptids)
	$.stoptids = []
	$.setoff()
}

method setoff {
	$.ison = 0
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
	$.b1.resize(xy(x0,y0,x1,y0a))
	$.ph.resize(xy(x0,y0a+2,x1,y1))
}
method wsectchk(tm) {
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

method startinitrange() {
	$.initrange = 1
}
method setstrip(v) {
	$.strip = v
	for ( n=0; n < $.nsect; n++ ) {
		$.arr[n] = strip($.arr[n])
	}
}
method setstep(v) {
	$.step = v
}

method setscale(sc) {
	print("scale=",sc)
	s = makescale(scalenamed("newage"))
	for ( n=0; n < $.nsect; n++ ) {
		$.arr[n] = scadjust($.arr[n],s)
	}
}
}

function mkmenu_sect2(o,po) {
	o.menucmd("On",po,"setretrigger",1)
	o.menucmd("Off",po,"setretrigger",0)
}
function mkmenu_sect3(o,po) {
	o.menucmd("On",po,"setrepeat",1)
	o.menucmd("Off",po,"setrepeat",0)
}

function mkmenu_wrquantvals(o,po,meth) {
	o.menucmd("None",po,meth,1)
	o.menucmd("1b/4",po,meth,1b/4)
	o.menucmd("1b/2",po,meth,1b/2)
	o.menucmd("1b",po,meth,1b)
	o.menucmd("2b",po,meth,2b)
	o.menucmd("4b",po,meth,4b)
	o.menucmd("8b",po,meth,8b)
}

function mkmenu_wrsectvals(o,po,meth) {
	o.menucmd("None",po,meth,1)
	o.menucmd("1b/4",po,meth,1b/4)
	o.menucmd("1b/2",po,meth,1b/2)
	o.menucmd("1b",po,meth,1b)
	o.menucmd("2b",po,meth,2b)
	o.menucmd("4b",po,meth,4b)
}
function mkmenu_sectscales(o,po) {
	o.menucmd("None",po,"setscale","none")
	o.menucmd("Newage",po,"setscale","newage")
	o.menucmd("Fifths",po,"setscale","fifths")
}
function mkmenu_setstrip(o,po) {
	o.menucmd("Off",po,"setstrip",0)
	o.menucmd("On",po,"setstrip",1)
}
function mkmenu_setstep(o,po) {
	o.menucmd("Off",po,"setstep",0)
	o.menucmd("On",po,"setstep",1)
}

function mkmenu_sect1(o,po) {
	o.menucmd("Load from File",po,"loadfile")
	o.menucmd("Load from Snarf",po,"loadsnarf")
	o.menucmd("Init Range",po,"startinitrange")
	o.submenu("Retrigger    ->","mkmenu_sect2",po)
	o.submenu("Repeat       ->","mkmenu_sect3",po)
	o.submenu("Start Quant  ->","mkmenu_wrquantvals",po,"setstartquant")
	o.submenu("Maximum Sect ->","mkmenu_wrsectvals",po,"setmaxsect")
	o.submenu("Scale        ->","mkmenu_sectscales",po)
	o.submenu("Strip        ->","mkmenu_setstrip",po)
	o.submenu("Step         ->","mkmenu_setstep",po)
}

