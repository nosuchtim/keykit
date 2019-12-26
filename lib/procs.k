function proc_list {
	n=0
	p=[]
	p[n++] = ["name"="Nothing","tool"=0]
	p[n++] = ["name"="Delay","tool"=global(ptool_delay)]
	p[n++] = ["name"="Ornament","tool"=global(ptool_ornament)]
	p[n++] = ["name"="Delay Continuous","tool"=global(ptool_delay_continuous)]
	p[n++] = ["name"="Scadjust","tool"=global(ptool_scadjust)]
	p[n++] = ["name"="Filter","tool"=global(ptool_filter)]
	return(p)
}

##########################################

class ptool_delay_continuous {

method init(...) {
	$.w = new window()
	$.inherit($.w)

	$.v = 24
	$.ks = new kslider(0,2b,$.v,$,"delaychange")
	$.addchild($.ks)
}
method process(n) {
	n.time += $.v
	return(n)
}
method get {
	return($.v)
}
method set(v) {
	$.ks.set(v)
}
method delaychange(v) {
	$.v = v
}
method redraw { $.w.redraw(); methodbroadcast(); }

method resize(sz) {
	$.w.resize(sz)
	x0 = $.xmin()
	x1 = $.xmax()
	w = x1-x0
	tw = $.textwidth()
	if ( w > tw ) {
		xm = (x1+x0)/2
		dx = tw*2
		x0 = xm-dx
		x1 = xm+dx
	}
	th = $.textheight()
	$.ks.resize( xy(x0,$.ymin()+th,x1,$.ymax()-th) )
}
}

##########################################

class ptool_delay {

method init(...) {
	$.w = new window()
	$.inherit($.w)

	vals = [0="Whole",1="Half",2="Quarter",3="Eighth",4="Sixteenth",5="32nd"]

	$.ks = new kvalbutton(vals,$,"delaychange")
	$.addchild($.ks)

	$.ks.set(2)
	$.d = $.delayof($.ks.get())
}
method delayof(v) {
	if ( v==0 ) return(4b)
	if ( v==1 ) return(2b)
	if ( v==2 ) return(1b)
	if ( v==3 ) return(1b/2)
	if ( v==4 ) return(1b/4)
	if ( v==5 ) return(1b/8)
}
method process(n) {
	n.time += $.d
	return(n)
}
method get {
	return($.ks.get())
}
method set(v) {
	$.ks.set(v)
}
method delaychange(v) {
	$.d = $.delayof(v)
}
method redraw { $.w.redraw(); methodbroadcast(); }

method resize(sz) {
	$.w.resize(sz)
	y0 = $.ymin()+2
	y1 = $.ymax()-2
	h = y1-y0
	th = $.textheight()
	if ( h > th ) {
		ym = (y1+y0)/2
		dy = th/2
		y0 = ym-dy-1
		y1 = ym+dy+1
	}
	tw = $.textwidth()
	$.ks.resize( xy($.xmin()+2*tw,y0,$.xmax()-2*tw,y1) )
}
}

##########################################

class ptool_scadjust {

method init(...) {
	$.w = new window()
	$.inherit($.w)

	vals = [
		0="C",
		1="C#",
		2="D",
		3="D#",
		4="E",
		5="F",
		6="F#",
		7="G",
		8="G#",
		9="A",
		10="A#",
		11="B"
		]
	$.notes = [
		0='c',
		1='c+',
		2='d',
		3='d+',
		4='e',
		5='f',
		6='f+',
		7='g',
		8='g+',
		9='a',
		10='a+',
		11='b'
		]
	chordvals = []
	n=0
	$.chords = []
	save = Arraysort
	Arraysort = 1
	for ( c in Chords ) {
		chordvals[n] = c
		$.chords[n] = Chords[c]
		n++
	}
	Arraysort = save
	$.ks = new kvalbutton(vals,$,"scadjustchange")
	$.kc = new kvalbutton(chordvals,$,"scadjustchord")
	$.addchild($.ks)
	$.addchild($.kc)

	$.key = 'c'
	$.chord = scale_ionian()

	$.ks.set(0)
	$.kc.set(0)
	$.scadjustchange(0)
	$.scadjustchord(0)
}
method scadjustchange(v) {
	$.key = $.notes[v]
	$.scale = transpose($.chord,$.key)
}
method scadjustchord(v) {
	$.chord = $.chords[v]
	$.scale = transpose($.chord,$.key)
}
method get {
	return($.ks.get())
}
method set(v) {
	$.ks.set(v)
}
method process(n) {
	return(scadjust(n,$.scale))
}
method redraw { $.w.redraw(); methodbroadcast(); }

method resize(sz) {
	$.w.resize(sz)
	y0 = $.ymin()+2
	y1 = $.ymax()-2
	h = y1-y0
	th = $.textheight()
	if ( h > th ) {
		ym = (y1+y0)/2
		dy = th/2
		y0 = ym-2*dy-1
		y1 = ym+dy+1
	}
	tw = $.textwidth()
	$.ks.resize( xy($.xmin()+2*tw,y0,$.xmax()-2*tw,y0+th) )
	$.kc.resize( xy($.xmin()+2*tw,y0+th,$.xmax()-2*tw,y0+2*th) )
}
}

##########################################

class ptool_filter {

method init(...) {
	$.w = new window()
	$.inherit($.w)

	vals = []
	for ( n=0; n<128; n++ )
		vals[n] = string(n)
	nvals = []
	for ( n=0; n<128; n++ )
		nvals[n] = string(makenote(n))
	$.vtext = new ktext("Volume")
	$.vtext.style(NOBORDER)
	$.vminbutt = new kvalbutton(vals,$,"volminchanged")
	$.vmaxbutt = new kvalbutton(vals,$,"volmaxchanged")
	$.ntext = new ktext("Pitch")
	$.ntext.style(NOBORDER)
	$.nminbutt = new kvalbutton(nvals,$,"noteminchanged")
	$.nmaxbutt = new kvalbutton(nvals,$,"notemaxchanged")

	$.addchild($.vtext)
	$.addchild($.vminbutt)
	$.addchild($.vmaxbutt)
	$.addchild($.ntext)
	$.addchild($.nminbutt)
	$.addchild($.nmaxbutt)

	$.vmin = 0
	$.vmax = 127
	$.nmin = 0
	$.nmax = 127
	$.vminbutt.set(0)
	$.vmaxbutt.set(127)
	$.nminbutt.set(0)
	$.nmaxbutt.set(127)
}
method dump {
	return( [
		"vmin"=$.vmin,
		"vmax"=$.vmax,
		"nmin"=$.nmin,
		"nmax"=$.nmax
		] )
}
method restore(st) {
	$.vminbutt.set(st["vmin"])
	$.vmaxbutt.set(st["vmax"])
	$.nminbutt.set(st["nmin"])
	$.nmaxbutt.set(st["nmax"])
}
method volminchanged(v) { $.vmin = v }
method volmaxchanged(v) { $.vmax = v }
method noteminchanged(v) { $.nmin = v }
method notemaxchanged(v) { $.nmax = v }
method process(n) {
	if ( n.type != NOTE && n.type != NOTEON && n.type != NOTEOFF )
		return('')
	if ( n.vol < $.vmin || n.vol > $.vmax )
		return('')
	if ( n.pitch < $.nmin || n.pitch > $.nmax )
		return('')
	return(n)
}
method redraw { $.w.redraw(); methodbroadcast(); }

method resize(sz) {
	$.w.resize(sz)
	y0 = $.ymin()+5
	y0a = $.ymin()+2+5
	y1 = $.ymax()-2
	dy = (y1-y0)/4
	th = $.textheight()
	if ( dy > th )
		dy = th
	tw = $.textwidth()
	x0a = $.xmin()+tw
	x1a = $.xmax()-tw
	xm = (x0a+x1a)/2
	$.vtext.resize( 	xy(x0a,y0,xm-1,y0+1*dy) )
	$.vminbutt.resize(	xy(xm+1,y0,x1a,y0+1*dy) )
	$.vmaxbutt.resize(	xy(xm+1,y0+1*dy,x1a,y0+2*dy) )
	$.ntext.resize(	 	xy(x0a,y0a+2*dy,xm-1,y0a+3*dy) )
	$.nminbutt.resize(	xy(xm+1,y0a+2*dy,x1a,y0a+3*dy) )
	$.nmaxbutt.resize(	xy(xm+1,y0a+3*dy,x1a,y0a+4*dy) )
}
}

##########################################

class ptool_ornament {

method init(...) {
	$.w = new window()
	$.inherit($.w)

	$.v = 24
	$.ks = new wphrase()
	$.butt = new kmenubutton("More","mkmenu_ptool_ornament",$)
	$.addchild($.ks)
	$.addchild($.butt)

	orn = 'co3,go3,co4,co5'
	$.ks.set(orn)
	$.ks.dozoomout(1,"xy")
}

method process(n) {
	if ( n.type == NOTEON || n.type == NOTEOFF ) {
		orn = $.ks.get()
		p = orn
		p.pitch += (n.pitch - orn%1.pitch)
		p.vol += (n.vol - orn%1.vol)
		p.time += n.time
		p.type = n.type
		n = p
	}
	return(n)
}

method setit(v) {
	if ( v == 1 )
		$.set(Snarf)
	else
		$.set(strip(lastbunch(Recorded,2b)))
	$.redraw()
}

method set(p) {
	$.ks.set(p)
	$.ks.dozoomout(1,"xy")
}

method get {
	return($.ks.get())
}
method delaychange(v) {
	$.v = v
}
method redraw { $.w.redraw(); methodbroadcast(); }

method resize(sz) {
	$.w.resize(sz)
	th = $.textheight()
	$.butt.resize( xy($.xmin()+2,$.ymin()+2,$.xmax()-2,$.ymin()+th+2) )
	$.ks.resize( xy($.xmin()+2,$.ymin()+th+4,$.xmax()-2,$.ymax()-2) )
}
}

function mkmenu_ornament1(o,po) {
	o.menucmd("Snarf",po,"setit",1)
	o.menucmd("Last Recorded",po,"setit",2)
}

function mkmenu_ptool_ornament(o,po) {
	o.submenu("Load ->","mkmenu_ornament1",po)
}
