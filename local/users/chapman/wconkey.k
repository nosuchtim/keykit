class wconkey {

method init {
	initConMap()
	$.nwphrs = 7         # you can actually change this, if you want more
	$.w = new window()
	$.inherit($.w)

	$.c = []
	$.togg = new ktoggle("On",$,"setonoff")
	$.constogg = new ktoggle("Cons",$,"consonoff")
	$.buttresync = new kbutton(textfunc("Resync"),$,"resync")
	$.addchild($.togg)
	$.addchild($.constogg)
	$.addchild($.buttresync)

	$.enable = []
	$.enabled = []
	$.wphr = []
	$.tasks = []
	$.needsupdating = []
	$.lengthof = []
	$.initialkey = 'c'
	$.octave = []
	$.trans = []
	$.filter = []
	$.chordize = []
	$.rawph = []
	$.origph = []
	$.scaleto = chord('c',"major")
	$.startquant = Playquant
	$.active = 0
	$.chordtype = "major"

	# set up all the widgets - enables, text fields, and phrases

	for ( i=0; i<$.nwphrs; i++ ) {
		$.enable[i] = new ktoggle("On",$,"setenable",i)
		$.enabled[i] = 0
		$.addchild($.enable[i])

		$.wphr[i] = new wphrase()
		$.addchild($.wphr[i])

		$.tasks[i] = -1
		$.needsupdating[i] = 0
		$.filter[i] = 0
		$.chordize[i] = 0
		$.lengthof[i] = 8b
		$.octave[i] = 0
		$.trans[i] = 0
	}
	for ( i=0; i<$.nwphrs; i++ ) {
		$.setraw(i,$.gen1(i))
		$.reset1(i,0)

	}
	$.constid = task $.constask()
	if ( $.constid >= 0 )
		$.constogg.set(1)
	$.togg.set(1)
	$.setonoff(1)
}
method setraw(i,p) {
	$.rawph[i] = p
}
method reset1(i,doredraw) {
	p = $.rawph[i]
	if ( $.octave[i] != 0 )
		p.pitch += $.octave[i]*12
	if ( $.trans[i] != 0 )
		p.pitch += $.trans[i]
	for ( f=$.filter[i]; f>0; f-- ) {
		p = p{rand(2)==0}
	}
	if ( $.chordize[i] ) {
		lookfor = canonic($.initialkey)
		r = ''
		for ( nt in p ) {
			if ( canonic(nt) == lookfor ) {
				ch = transpose(chordnamed($.chordtype),nt.pitch)
				ch.chan = nt.chan
				ch.time = nt.time
				ch.dur = nt.dur
				ch.vol = nt.vol + 20
				r |= ch
			} else {
				r |= nt
			}
		}
		p = r
	}

	p.length = $.lengthof[i]
	$.wphr[i].set(p)

	$.needsupdating[i] = 1

	$.wphr[i].dozoomout(0,"y")
	$.wphr[i].forceview(0,p.length)
	if ( nargs() > 1 && doredraw == 1 ) {
		$.wphr[i].redraw()
	}
}
method setenable(v,m,i) {
	$.enabled[i] = v
	if ( v == 0 ) {
		$.wphr[i].stop()
	}
}
method redraw {
	$.w.redraw()
	$.line($.sep)
	$.w.text("Four Play",$.textxy)
	for ( o in $.children() )
		o.redraw()
	$.drawactive($.active)
}
method dump {
	ret = []
	ret["i"] = $.nwphrs
	for ( i=0; i<$.nwphrs; i++ ) {
		ret[i] = $.rawph[i]
	}
	return(ret)
}
method restore (state) {
	for ( i=0; i<$.nwphrs; i++ ) {
		$.wphr[i].set(state[i])
	}
}
method play() {
	stime = nextquant(Now,$.startquant)   # so they all start in sync
	for ( i=0; i<$.nwphrs; i++ ) {
		$.tasks[i] = task $.play1(i,stime)
	}
}

method play1(i,tm) {
	looptm = 8b
	while ( 1 ) {
		sleeptill(tm-24)
		p = $.gen1(i)
		$.setph(i,p)

if (0==1) {
		if ( $.needsupdating[i] ) {
			$.needsupdating[i] = 0
#			$.wphr[i].redraw()

#			p = $.wphr[i].get()
			if ( sizeof(p) == 0 )
				looptm = 0
			else
				looptm = p.length
		}
		looptm = 8b
}

		sleeptill(tm-2)
		if ( $.enabled[i] ) {
			$.wphr[i].play(tm)
		}
		if ( looptm < 1b )
			tm += 1b
		else
			tm += looptm
	}
}
method delete {
	killtids($.tasks)
	$.tasks = []
	Root.releaseconsole()
}
method stop() {
	for ( i=0; i<$.nwphrs; i++ ) {
		$.wphr[i].stop()
		if ( (i in $.tasks) && $.tasks[i] >= 0 )
			kill($.tasks[i])
	}
	$.tasks = []
}
method resync() {
	$.stop()
	$.play()
}
method setonoff (v) {
	$.ison = v
	if ( v )
		$.play()
	else
		$.stop()
}

method consonoff () {
	if ( $.constid < 0 )
		$.constid = task $.constask()
	else {
		kill($.constid)
		$.constid = -1
	}
}

method drawactive(i) {
	x = $.wphr[i].size()
	x["x0"]--
	x["y0"]--
	x["x1"]++
	x["y1"]++
	$.rectangle(x,STORE)
}

method setactive(i) {
	if (( i > -1 ) && (i < $.nwphrs)) {
	
	  $.active = i
	  for ( n=0; n<$.nwphrs; n++ ) {
		x = $.wphr[n].size()
		x["x0"]--
		x["y0"]--
		x["x1"]++
		x["y1"]++
		if ( n == i )
			$.rectangle(x,STORE)
		else
			$.rectangle(x,CLEAR)
	  }
	}
}

method constask() {
	global constaskdone1
	f = Root.grabconsole()
	Consecho = 0
	onexit(constaskdone1,$,f)
	while ( 1 ) {
		c = get(f)
		keypressed($,c)
	}
}

method transposeall(t) {
	# Don't transpose the drum track
	for ( i=1; i<$.nwphrs; i++ ) {
		$.trans[i] += t
		if ( $.trans[i] > 12 )
			$.trans[i] -= 12
		if ( $.trans[i] < -12 )
			$.trans[i] += 12
		$.reset1(i,1)
	}
}
method genall() {
	for ( i=0; i<$.nwphrs; i++ ) {
		$.setraw(i,$.gen1(i))
		$.reset1(i,1)
	}
}

method gen1(i) {
	if ( i == 0 ) {
		x = bsgmdrum8()
		return(x)
	}
	app = 0
	autostep = 1
	ntracks = 1
	leng = $.lengthof[i]
	x = arpeggio(bsgmdrum8()) #total_expresso("default",13,rand(milliclock()),$.initialkey,
		#ntracks, "no",0,0,autostep,app,leng)
	x = scadjust(x,$.scaleto)
	x.chan = i
	return(x)
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	th = $.textheight()
	tw = $.textwidth()
	x0 = $.xmin()+2
	x1 = $.xmax()-2
	dx = x1-x0

	y0 = $.ymin()+2
	y0a = y0 + th + 6
	y1 = $.ymax()-2
	dy = y1-y0a
	ym = []
	for ( i=0; i<=$.nwphrs; i++ ) {
		ym[i] = y0a + i*dy/$.nwphrs
	}

	xp1 = x0 + 4*dx/12	# for phrase
	xs1 = x0 + 2	        # for slider
	xs2 = x0 + dx/12
	xss1 = x0 	        # for sync label
	xss2 = x0 + 5*dx/12
	xt1 = x0 + 3 + dx/12	# for valtext

	xo1 = x0 + 5*dx/12	# for on toggle
	xo1a = x0 + 6*dx/12	# for on toggle
	xo2 = x0 + 8*dx/12
	xr1 = x0 + 9*dx/12	# for resync
	xr2 = x0 + 11*dx/12

	$.sep = xy(x0,y0a-2,x1,y0a-2)
	$.textxy = xy(xss1,$.ymin(),xss2, y0a-4)

	$.togg.resize(xy(xo1,y0,xo1a-1,y0a-4))

	$.constogg.resize(xy(xo1a+1,y0,xo2,y0a-4))

	$.buttresync.resize(xy(xr1,y0,xr2,y0a-4))

	th2 = 2*th / 3
	for ( i=0; i<$.nwphrs; i++ ) {
		ym2 = (ym[i]+ym[i+1])/2
		ytmp = ym[i]+2+th
		if ( ytmp > ym[i+1] )
			ytmp = ym[i+1]
		$.enable[i].resize(xy(xs1,ym[i]+2,xs2,ytmp))
		$.wphr[i].resize(xy(xt1+1,ym[i]+2,x1-1,ym[i+1]-2))
	}
}


method setph(i,ph) {
			$.setraw(i,ph)
			$.reset1(i,1)
}


method toggle(i) {
			if ( $.enabled[i] )
				$.enabled[i] = 0
			else
				$.enabled[i] = 1
			$.enable[i].set($.enabled[i])
			$.enable[i].redraw()
}

method toggleall() {
	for ( i=0; i<$.nwphrs; i++ ) {
		$.toggle(i)
	}
}


}
function constaskdone1(o,f) {
	Consecho = 1
	Root.releaseconsole()
}
