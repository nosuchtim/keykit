class wexpresso {
method init {
	$.w = new window()
	$.inherit($.w)

	$.usegroup = 1

	if ( $.usegroup ) {
		$.ph = new wgroup()
		# Make sure normal right-click is looping
		$.ph.setbutton( 27, 2, NOREDRAW, 0 )
	} else {
		$.ph = new wphrase()
	}

	$.morebutton = new kmenubutton("More","mkmenu_expresso1",$)
	$.genbutton = new kbutton("Gen",$,"gen_next",1)
	$.grabbutton = new kbutton("Grab",$,"gloadrec",2b)

	nums = []
	for ( n=0; n<25; n++ )
		nums[n] = string(n+1)
	$.iterbutton = new kvalbutton(nums,$,"iterchanged")
	$.itertext = new ktext("g")

	trks = []
	for ( n=0; n<6; n++ )
		trks[n] = string(n+1)
	$.ntrksbutton = new kvalbutton(trks,$,"ntrkschanged")
	$.ntrkstext = new ktext("#")

	chans = []
	for ( n=0; n<16; n++ )
		chans[n] = string(n+1)
	$.chanbutton = new kvalbutton(chans,$,"chanchanged")
	$.chantext = new ktext("c")

	$.octoffset = 3
	octs = []
	for ( n=0; n<7; n++ )
		octs[n] = string(n-$.octoffset)
	$.octbutton = new kvalbutton(octs,$,"octchanged")
	$.octtext = new ktext("o")

	combs = []
	combs[0] = "None"
	for ( n=1; n<8; n++ )
		combs[n] = "Remove "+string(n)+" of 8"
	$.combbutton = new kvalbutton(combs,$,"combchanged")
	$.combtext = new ktext("r")

	volincs = []
	volincs[0] = "No change"
	for ( n=1; n<14; n++ ) {
		if ( n < 13 )
			mxv = 10*n
		else
			mxv = 127
		volincs[n] = string(mxv)
	}
	$.volbutton = new kvalbutton(volincs,$,"volchanged")
	$.voltext = new ktext("v")

	$.itertext.style(NOBORDER)
	$.ntrkstext.style(NOBORDER)
	$.chantext.style(NOBORDER)
	$.octtext.style(NOBORDER)
	$.voltext.style(NOBORDER)
	$.combtext.style(NOBORDER)

	$.title = new ktext("Expresso")
	$.title.style(NOBORDER)
	$.transfile = "default"
	$.transtext = new ktext($.transfile)
	$.randtoggle = new ktoggle("Randomize",$,"setvar","autorand")
	$.randtext = new ktext("")
	$.xphr = new wphrase()
	$.gphr = new wphrase()
	$.addchild($.ph)
	$.addchild($.morebutton)

	$.addchild($.iterbutton)
	$.addchild($.ntrksbutton)
	$.addchild($.chanbutton)
	$.addchild($.octbutton)
	$.addchild($.combbutton)
	$.addchild($.volbutton)

	$.addchild($.itertext)
	$.addchild($.ntrkstext)
	$.addchild($.chantext)
	$.addchild($.octtext)
	$.addchild($.combtext)
	$.addchild($.voltext)

	$.addchild($.genbutton)
	$.addchild($.grabbutton)
	$.addchild($.title)
	$.addchild($.randtoggle)
	$.addchild($.randtext)
	$.addchild($.transtext)
	$.addchild($.xphr)
	$.addchild($.gphr)

	$.randtoggle.set(1)

	$.xphr.set('c')
	$.gphr.set('')
	$.xphr.dozoomout(1,"xy");
	$.gphr.dozoomout(1,"xy");

	$.iter = 10
	$.ntrks = 3
	$.startquant = 4b
	$.autosnarf = 1
	$.autorand = 1
	$.autoapply = 0
	$.autostep = 1
	$.autodur = 0
	$.autolength = 8b
	$.autoplay = 1
	$.autoloop = 1
	$.factor = 1.0
	$.randpatches = "none"
	$.scalem = 1
	$.drums = 0
	$.firstchan = 1
	$.checkquant = 4b
	$.oct = 0
	$.comb = 0
	$.volinc = 0
	$.playrect = []

	$.iterbutton.set($.iter-2)
	$.ntrksbutton.set($.ntrks-1)
	$.chanbutton.set($.firstchan-1)
	$.octbutton.set($.oct+$.octoffset)
	$.combbutton.set($.comb)
	$.volbutton.set($.volinc)

	# if ( $.usegroup ) {
	# 	$.autoloop = 0
	# 	$.autoplay = 0
	# }

	$.ison = 0
	$.leng = 0
	$.stoptids = []
	$.origp = ''
	$.nextp = ''
	$.setseed()
}
method setscalem(v) {
	$.scalem = v
}
method setautoplay(v) {
	$.autoplay = v
}
method setautoloop(v) {
	$.autoloop = v
}
method setseed(r) {
	if ( nargs() < 1 )
		r = milliclock()
	$.randtext.set(string(r))
	$.seed = r
	rand(-r)
}
method set(p) {
	p.flags = 0
	if ( $.drums != 0 ) {
		p.chan = 10
	}
	$.xphr.set(p)
	$.xphr.dozoomout(1,"xy");
	$.xphr.redraw()
}
method setgrab(p) {
	p.flags = 0
	$.gphr.set(p)
	$.gphr.dozoomout(1,"xy");
	$.gphr.redraw()
}
method applyautodur(p) {
	n = $.autodur
	if ( n == 1 ) {
		p.dur = 1b/8
	} else if ( n == 2 ) {
		p.dur = 1b
	} else if ( n == 3 ) {
		p1 = p{rand(2)==0}
		p -= p1 ; p1.dur = 1b ; p |= p1
	} else if ( n == 4 ) {
		p.dur = 2b
	} else if ( n == 5 ) {
		p1 = p{rand(2)==0}
		p -= p1 ; p1.dur = 2b ; p |= p1
	}
	return(p)
}
method dogen() {
	if ( $.autorand ) {
		$.setseed()
		$.randtext.redraw()
	}
	gp = $.gphr.get()
	p = total_expresso($.transfile,$.iter,$.seed,$.xphr.get(),
		$.ntrks,$.randpatches,$.scalem,0,
		$.autostep,$.autoapply,$.autolength,gp)
	p = $.applyautodur(p)
	if ( $.firstchan != 1 ) {
		p.chan += ($.firstchan-1)
	}
	if ( $.firstchan == 10 ) {
		while ( p.vol < 60 )
			p.vol += 10
	}

	$.origp = p

	if ( $.oct != 0 ) {
		p.pitch += ($.oct * 12)
	}
	p = $.applycomb(p)
	if ( $.volinc != 0 ) {
		while ( p.vol < (10*$.volinc) )
			p.vol += 10
	}
	return(p)
}
method gen_next(doautoplay, p) {
	if ( nargs() < 1 )
		doautoplay = 0
	if ( nargs() < 2 )
		p = 0

	if ( ! (doautoplay && $.autoplay) ) {
		if ( p == 0 ) {
			p = $.dogen()
			if ( $.usegroup ) {
				$.ph.killflashnotes()
				$.ph.stop()
			}
			$.setresult(p,1)
		}
		return()
	}

	if ( p == 0 ) {
		p = $.dogen()
	}

	if ( ! $.usegroup && ! $.ison ) {
		$.setresult(p,1)
		$.play()
	} else if ( ! $.autoloop ) {
		$.stop()
		$.setresult(p,1)
		$.play()
	} else {
		# We're looping
		$.ph.killflashnotes()
		if ( $.usegroup ) {
			$.ph.stop()
		}

		$.ph.set(p)
		$.fitit()
		$.ph.redraw()
		$.nextp = p

		if ( $.usegroup ) {
			if ( $.autoplay ) {
				if ( $.autoloop ) {
					$.ph.loop()
				} else {
					$.play()
				}
			}
		}
	}
}
method set_next(p,doautoplay) {
	$.gen_next(doautoplay,p)
}
method fitit() {
	if ( $.autolength != 0 )
		$.ph.forceview(0,$.autolength)
	else
		$.ph.fitall()
}
method redraw {
		$.w.redraw()
		if ( $.ison )
			$.rectangle($.playrect,STORE)
		methodbroadcast()
}

method delete {
			killtids($.stoptids)
			$.stoptids = []
			}

method iterchanged (v) {
	$.iter = v+2;
}
method ntrkschanged (v) {
	$.ntrks = v+1;
}
method chanchanged (v) {
	$.firstchan = v+1;
}
method octchanged (v) {
	oldoct = $.oct
	$.oct = v-$.octoffset
	doct = $.oct - oldoct
	p = $.get()
	p.pitch += (doct * 12)
	$.set_next(p,1)
}
method applycomb(p) {
	v = $.comb
	if ( v == 0 )
		return(p)
	p = p{rand(8)>=v}
	return(p)
}
method combchanged (v) {
	p = $.get()
	$.comb = v
	p = $.applycomb($.get())
	$.set_next(p,1)
}
method volchanged (v) {
	p = $.get()
	$.volinc = v
	if ( $.volinc != 0 ) {
		while ( p.vol < (10*$.volinc) )
			p.vol += 10
	}
	$.set_next(p,1)
}

method setvar (v,m,nm) {
			if ( nm == "on" ) {
				if ( v ) $.play(); else $.stop()
			}
			$.(nm) = v
			return(99)
		}
method bang {
			if ( $.ison )
				$.stop()
			else
				$.play()
			}
method xbang {
			if ( $.ison )
				$.stop()
			else
				$.xplay()
			}
method gbang {
			if ( $.ison )
				$.stop()
			else
				$.gplay()
			}
method setstartquant (v) { $.startquant = v }
method setcheckquant (v) { $.checkquant = v }
method setfactor(f) {
	$.factor = f
	$.set($.get(),1)
}
method get { return($.origp) }
method setresult (p,doredraw) {
				if ( $.factor != 1.0 )
					p = scatimes(p,$.factor)
				if ( $.drums != 0 )
					p.chan = 10
				$.ph.set(p,0)
				$.leng = p.length
				$.fitit()
				if ( nargs() > 1 && doredraw ) {
					$.redraw()
				}
				}
method mousedown (m) {
		if ( $.usegroup && $.ph.contains(m) ) {
			mouseforward(m,"mousedown")
			return()
		}
		b = m["button"]
		if ( b == 1 ) {
			if ( $.ph.contains(m) )
				$.bang()
			else if ( $.xphr.contains(m) )
				$.xbang()
			else if ( $.gphr.contains(m) )
				$.gbang()
			else {
				mouseforward(m,"mousedown")
			}
		} else if ( b == 2 ) {
			if ( $.ph.contains(m) )
				Snarf = $.ph.get()
			else if ( $.xphr.contains(m) )
				Snarf = $.xphr.get()
			else if ( $.gphr.contains(m) )
				Snarf = $.gphr.get()
			else {
				mouseforward(m,"mousedown")
			}
		}
	}
method dump {
	return ( [
			"ph" = $.ph.dump(),
			"phrase" = $.xphr.get(),
			"gphrase" = $.gphr.get(),
			"iter" = $.iter,
			"seed" = $.seed,
			"ntrks" = $.ntrks,
			"autorand" = $.autorand,
			"autoplay" = $.autoplay,
			"startquant" = $.startquant,
			"checkquant" = $.checkquant,
			"autosnarf" = $.autosnarf,
			"autoapply" = $.autoapply,
			"autostep" = $.autostep,
			"autodur" = $.autodur,
			"autolength" = $.autolength,
			"autoloop" = $.autoloop,
			"factor" = $.factor,
			"randpatches" = $.randpatches,
			"scalem" = $.scalem,
			"firstchan" = $.firstchan,
			"oct" = $.oct,
			"comb" = $.comb,
			"volinc" = $.volinc,
			"transfile" = $.transfile,
			"drums" = $.drums
		] )
}
method restore (state) {
	$.set(state["phrase"])
	if ( "gphrase" in state ) {
		$.setgrab(state["gphrase"])
	}
	if ( "ph" in state ) {
		$.ph.restore(state["ph"])
	}
	$.autorand = state["autorand"]
	$.randtoggle.set($.autorand)
	$.setseed(state["seed"])
	$.iter = state["iter"]
	$.ntrks = state["ntrks"]
	$.autoplay = state["autoplay"]
	$.startquant = state["startquant"]
	if ( "checkquant" in state ) {
		$.checkquant = state["checkquant"]
	}
	$.autosnarf = state["autosnarf"]
	$.autoapply = state["autoapply"]
	$.autostep = state["autostep"]
	if ( "autodur" in state )
		$.autodur = state["autodur"]
	$.autolength = state["autolength"]
	$.autoloop = state["autoloop"]
	$.factor = state["factor"]
	$.transfile = state["transfile"]
	$.randpatches = state["randpatches"]
	$.scalem = state["scalem"]
	$.firstchan = state["firstchan"]
	$.drums = state["drums"]
	$.oct = state["oct"]
	if ( "comb" in state ) {
		$.comb = state["comb"]
	}
	if ( "volinc" in state ) {
		$.volinc = state["volinc"]
	}
	if ( $.comb == "" )
		$.comb = 0

	$.iterbutton.set($.iter-2)
	$.ntrksbutton.set($.ntrks-1)
	$.chanbutton.set($.firstchan-1)
	$.octbutton.set($.oct+$.octoffset)
	$.combbutton.set($.comb)
	$.transtext.set($.transfile)
}
method setautosnarf (v) { $.autosnarf = v }
method setautostep (v) { $.autostep = v }
method setautodur (v) { $.autodur = v }
method setautolength (v) { $.autolength = v }
method setdrums (v) { $.drums = v }
method setautoapply (v) { $.autoapply = v }
method setrandpatches (v) {
	if ( v == 0 ) $.randpatches = "none" ; else $.randpatches = "yes"
}
method loadrec (space) {
	p = lastbunch(Recorded,space,NOTE)
	p.time -= p%1.time
	p.length = nextquant(latest(p),Met.length)
	$.set(p,1)
}
method gloadrec (space) {
	p = lastbunch(Recorded,space,NOTE)
	p.time -= p%1.time
	p.length = nextquant(latest(p),Met.length)
	$.setgrab(p,1)
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
method gloadsnarf () {
	p = Snarf
	p.time -= p%1.time
	p.length = nextquant(latest(p),Met.length)
	$.setgrab(p,1)
}
method loadfile {
	ph = browsephrase()
	if ( sizeof(ph) > 0 )
		$.set(ph,1)
}
method gloadfile {
	ph = browsephrase()
	if ( sizeof(ph) > 0 )
		$.setgrab(ph,1)
}

method enterrand {
	rstr = getastr("Enter random seed (a number) -> ")
	$.setseed(integer(rstr))
	$.randtext.redraw()
}

method loadtrans {
	fn = browsefiles("Expresso Transformations","*.exp",1)
	if ( fn != "" ) {
		# This is the real filename
		$.transfile = fn
		# Produce a more readable version for the onscreen text
		suff = split(fn,"\\/.:")
		if ( sizeof(suff) > 1 )
			fn = suff[sizeof(suff)-2]
		$.transtext.set(fn)
		$.transtext.redraw()
	}
}

method play(stime,dox) {
	$.ison = 1
	$.rectangle($.playrect,STORE)
	qnt = $.startquant
	if ( nargs() < 1 ) {
		if ( qnt == 1 )
			stime = Now
		else
			stime = nextquant(Now,qnt)
	}
	if ( $.usegroup ) {
		if ( $.autoloop ) {
			$.ph.loop()
		} else {
			$.ph.play(stime,qnt)
		}

	} else {
		tid = $.ph.play(stime,qnt)

		$.stoptids[tid] = 1

		if ( $.autoloop ) {
			tid2 = task $.checkloop(stime)
			$.stoptids[tid2] = 1
		}
	}
}

method checkloop(tm) {

	# tm is the time that the first (already scheduled) one
	# is going to play at.  We wait until it's started playing...
	sleeptill(tm+1b/8)

	while ( $.autoloop && $.ison ) {

		nextchecktm = tm + $.checkquant

		etm = tm + $.origp.length

		while ( $.nextp == '' && (nextchecktm-1b/8) <= etm ) {
			sleeptill(nextchecktm-1b/8)
			nextchecktm += $.checkquant
		}
		if ( $.nextp != '' ) {
			$.setresult($.nextp,1)
			if ( $.autosnarf )
				Snarf = $.nextp
			$.nextp = ''
			tm = nextchecktm - $.checkquant
		} else {
			sleeptill(etm-1b/8)
			tm += $.origp.length
		}

		# tid = $.ph.play(tm,$.startquant)
		tid = $.ph.play(tm)

		$.stoptids = [gettid()=1,tid=1]
	}
}

method xplay(stime) {
	$.ison = 1
	qnt = $.startquant
	if ( nargs() < 1 ) {
		if ( qnt == 1 )
			stime = Now
		else
			stime = nextquant(Now,qnt)
	}
	tid = $.xphr.play(stime,qnt)
	$.stoptids[tid] = 1
}
method gplay(stime) {
	$.ison = 1
	qnt = $.startquant
	if ( nargs() < 1 ) {
		if ( qnt == 1 )
			stime = Now
		else
			stime = nextquant(Now,qnt)
	}
	tid = $.gphr.play(stime,qnt)
	$.stoptids[tid] = 1
}

method stop {
	killtids($.stoptids)
	$.stoptids = []
	$.setoff()
}

method setoff {
	$.ison = 0
	$.rectangle($.playrect,CLEAR)
	# $.t1.set(0)
	# $.t1.redraw()
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	dx = ($.xmax()-$.xmin()) / 11
	y0 = $.ymin()+2
	y0aa = $.ymin() + $.textheight() + 4
	y0a = $.ymin() + 2*$.textheight() + 6
	y0b = $.ymin() + 3*$.textheight() + 8
	x0 = $.xmin() + 2
	x1 = $.xmax() - 2
	y1 = $.ymax() - 2

	$.title.resize(xy(x0,y0,x0+2*dx-1,y0aa-1))
	$.transtext.resize(xy(x0+2*dx+1,y0,x0+5*dx-1,y0aa-1))

	$.randtoggle.resize(xy(x0+2*dx+1,y0aa+1,x0+3*dx-1,y0a-1))
	$.randtext.resize(xy(x0+3*dx+1,y0aa+1,x0+5*dx-1,y0a-1))

	$.morebutton.resize(xy(x0,y0aa+1,x0+2*dx-1,y0a-1))

	bx0 = x0
	bx1 = x0+7*dx
	dbx = (bx1-bx0)/8

	$.itertext.resize(xy(bx0+0*dbx+1,y0a+1,bx0+1*dbx-1,y0b))
	$.iterbutton.resize(xy(bx0+1*dbx+1,y0a+1,bx0+2*dbx-1,y0b))

	$.octtext.resize(xy(bx0+2*dbx+1,y0a+1,bx0+3*dbx-1,y0b))
	$.octbutton.resize(xy(bx0+3*dbx+1,y0a+1,bx0+4*dbx-1,y0b))

	$.chantext.resize(xy(bx0+4*dbx+1,y0a+1,bx0+5*dbx-1,y0b))
	$.chanbutton.resize(xy(bx0+5*dbx+1,y0a+1,bx0+6*dbx-1,y0b))

	$.ntrkstext.resize(xy(bx0+6*dbx+1,y0a+1,bx0+7*dbx-1,y0b))
	$.ntrksbutton.resize(xy(bx0+7*dbx+1,y0a+1,bx1-1,y0b))

	$.combtext.resize(xy(bx0+6*dbx+1,y0,bx0+7*dbx-1,y0aa-1))
	$.combbutton.resize(xy(bx0+7*dbx+1,y0,bx1-1,y0aa-1))

	$.voltext.resize(xy(bx0+6*dbx+1,y0aa+1,bx0+7*dbx-1,y0a-1))
	$.volbutton.resize(xy(bx0+7*dbx+1,y0aa+1,bx1-1,y0a-1))

	x0b = (x0+5*dx+1+x1)/2
	$.genbutton.resize(xy(x0+7*dx+1,y0,x0+9*dx-1,y0aa+1))
	$.grabbutton.resize(xy(x0+9*dx+1,y0,x1,y0aa+1))

	$.xphr.resize(xy(x0+7*dx+1,y0aa+1,x0+9*dx-1,y0b))
	$.gphr.resize(xy(x0+9*dx+1,y0aa+1,x1,y0b))

	if ( $.usegroup ) {
		$.ph.resize(xy(x0,y0b+6,x1,y1))
	} else {
		$.ph.resize(xy(x0,y0b+2,x1,y1))
	}

	$.playrect = $.ph.size()
	$.playrect["x0"]--
	$.playrect["y0"]--
	$.playrect["x1"]++
	$.playrect["y1"]++
}
}

function mkmenu_autosnarf(o,po) {
	o.menucmd("On",po,"setautosnarf",1)
	o.menucmd("Off",po,"setautosnarf",0)
}

function mkmenu_drums(o,po) {
	o.menucmd("On",po,"setdrums",1)
	o.menucmd("Off",po,"setdrums",0)
}

function mkmenu_scalem(o,po) {
	o.menucmd("On",po,"setscalem",1)
	o.menucmd("Off",po,"setscalem",0)
}
function mkmenu_xautoplay(o,po) {
	o.menucmd("On",po,"setautoplay",1)
	o.menucmd("Off",po,"setautoplay",0)
}
function mkmenu_xautoloop(o,po) {
	o.menucmd("On",po,"setautoloop",1)
	o.menucmd("Off",po,"setautoloop",0)
}

function mkmenu_randpatches(o,po) {
	o.menucmd("On",po,"setrandpatches",1)
	o.menucmd("Off",po,"setrandpatches",0)
}

function mkmenu_expressoqvals(o,po,meth) {
	o.menucmd("None",po,meth,1)
	o.menucmd("1b",po,meth,1b)
	o.menucmd("2b",po,meth,2b)
	o.menucmd("4b",po,meth,4b)
	o.menucmd("8b",po,meth,8b)
}

function mkmenu_autostep(o,po) {
	o.menucmd("Off",po,"setautostep",0)
	o.menucmd("Step all to 16th",po,"setautostep",1)
	o.menucmd("Step all to 32th",po,"setautostep",2)
	o.menucmd("Step some to 32nd",po,"setautostep",3)
	o.menucmd("Arpeggiate only",po,"setautostep",4)
	o.menucmd("Step all 8th and 16th",po,"setautostep",5)
}

function mkmenu_autodur(o,po) {
	o.menucmd("Off",po,"setautodur",0)
	o.menucmd("Dur all 64th",po,"setautodur",1)
	o.menucmd("Dur all 1b",po,"setautodur",2)
	o.menucmd("Dur some 1b",po,"setautodur",3)
	o.menucmd("Dur all 2b",po,"setautodur",4)
	o.menucmd("Dur some 2b",po,"setautodur",5)
}

function mkmenu_autolength(o,po) {
	o.menucmd("Off",po,"setautolength",0)
	o.menucmd("2b",po,"setautolength",2b)
	o.menucmd("4b",po,"setautolength",4b)
	o.menucmd("8b",po,"setautolength",8b)
	o.menucmd("16b",po,"setautolength",16b)
}

function mkmenu_checkquant(o,po) {
	o.menucmd("2b",po,"setcheckquant",2b)
	o.menucmd("4b",po,"setcheckquant",4b)
	o.menucmd("8b",po,"setcheckquant",8b)
	o.menucmd("16b",po,"setcheckquant",16b)
}


function mkmenu_autoapply(o,po) {
	o.menucmd("Nothing",po,"setautoapply",0)
	o.menucmd("Scale all to Grabbed",po,"setautoapply",4)
	o.menucmd("Map all to Grabbed",po,"setautoapply",5)
	o.menucmd("Scale all to Last Recorded",po,"setautoapply",1)
	o.menucmd("Scale some to Last Recorded",po,"setautoapply",2)
	o.menucmd("Mono some",po,"setautoapply",3)
}

function mkmenu_loadgen(o,po) {
	o.menucmd("From Recorded (1b space)",po,"loadrec",1b)
	o.menucmd("From Recorded (4b space)",po,"loadrec",4b)
	o.menucmd("From Snarf",po,"loadsnarf")
	o.menucmd("From File",po,"loadfile")
}

function mkmenu_loadgrab(o,po) {
	o.menucmd("From Recorded (1b space)",po,"gloadrec",1b)
	o.menucmd("From Recorded (4b space)",po,"gloadrec",4b)
	o.menucmd("From Snarf",po,"gloadsnarf")
	o.menucmd("From File",po,"gloadfile")
}

function mkmenu_expresso1(o,po) {
	o.submenu("Load Gen      ->","mkmenu_loadgen",po)
	o.submenu("Load Grab     ->","mkmenu_loadgrab",po)

	o.submenu("AutoApply     ->","mkmenu_autoapply",po)
	o.submenu("AutoStep      ->","mkmenu_autostep",po)
	o.submenu("AutoLength    ->","mkmenu_autolength",po)
	o.submenu("AutoDur       ->","mkmenu_autodur",po)
	o.submenu("Random Patches->","mkmenu_randpatches",po)
	o.submenu("Start Quant   ->","mkmenu_expressoqvals",po,"setstartquant")
	o.submenu("Scale Lengths ->","mkmenu_scalem",po)
	o.submenu("AutoPlay      ->","mkmenu_xautoplay",po)
	o.submenu("AutoSnarf     ->","mkmenu_autosnarf",po)
	o.submenu("Loop          ->","mkmenu_xautoloop",po)

	o.menucmd("Snarf",po,"snarf")
	o.submenu("Force Drums   ->","mkmenu_drums",po)
	o.submenu("Check Quant   ->","mkmenu_checkquant",po)
	o.menucmd("Enter Random Seed",po,"enterrand")
	o.menucmd("Set Transforms",po,"loadtrans")
}

