class woffwalk{
method init {
	$.w = new window()
	$.inherit($.w)

	$.lowval = -24
	$.highval = 24
	k = 0
	$.offs = []
	for ( n=$.lowval; n<=$.highval; n++ )
		$.offs[k++] = string(n)

	$.kbutt = new kvalbutton($.offs,$,"offchanged")
	$.morebutt = new kmenubutton("More","mkmenu_woffwalkmore",$)
	$.walkbutt = new ktoggle("Walk",$,"walkonoff")
	$.watchbutt = new ktoggle("Watch",$,"watchonoff")
	chans = []
	for ( n=1; n<=16; n++ )
		chans[n-1] = string(n)
	$.chanbutt = new kvalbutton(chans)
	$.addchild($.morebutt)
	$.addchild($.kbutt)
	$.addchild($.walkbutt)
	$.addchild($.watchbutt)
	$.addchild($.chanbutt)

	$.setoffset(0)

	# Start out walking with 3rd/4th/5th/6ths
	$.walkvals = [	0=4,1=5,2=7,3=9,
			4=-4,5=-5,6=-7,7=-9]
	$.stoptids = []
	$.looptime = 4b
	$.tid = -1
}
method ison() {
	return ( $.tid >= 0 )
}
method walkonoff(v) {
	if ( $.tid == -1 ) {
		$.tid = task offwalktask($)
		$.stoptids[$.tid] = 1
	} else {
		$.stop()
	}
}
method forcewalking(v) {
	if ( v ) {
		if ( $.tid == -1 ) {
			$.tid = task offwalktask($)
			$.stoptids[$.tid] = 1
		}
	} else {
		$.stop()
	}
}
method watchonoff(v) {
	if ( $.tid == -1 ) {
		$.tid = task offwatchtask($,$.chanbutt.get()+1)
		$.stoptids[$.tid] = 1
	} else {
		$.stop()
	}
}
method delete {
	$.stop()
}
method stop {
	killtids($.stoptids)
	$.stoptids = []
	$.tid = -1
}
method setoffset(v) {
	Offsetpitch = v;
	$.kbutt.set(Offsetpitch-$.lowval);
}
method offchanged (v) {
	$.setoffset(v+$.lowval)
}
method random() {
	if ( sizeof($.walkvals) == 0 ) {
		v = rand(sizeof($.offs)) + $.lowval
		newv = Offsetpitch + v
	} else {
		r = rand(sizeof($.walkvals))
		dir = (rand(2)*2 - 1)
		newv = Offsetpitch + (dir * $.walkvals[r])
		if ( newv < $.lowval || newv > $.highval )
			newv += 2*(-dir * $.walkvals[r])
	}
	$.setoffset(newv)
	$.kbutt.redraw()
}

method redraw {
	$.w.redraw()
	x0 = $.xmin()
	x1 = $.xmax()
	y0 = $.ymin()
	y1 = $.ymax()
	th = $.textheight()
	$.text("Offset Walk",xy(x0,y0,x1,y0+th))
	methodbroadcast()
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	x0 = $.xmin()
	x1 = $.xmax()
	y0 = $.ymin()
	y1 = $.ymax()
	th = $.textheight()
	dy = (y1-y0-th)/5
	y0b = y0 + th
	$.kbutt.resize(xy(x0,y0b,x1,y0b+dy))
	$.morebutt.resize(xy(x0,y0b+dy,x1,y0b+2*dy))
	$.walkbutt.resize(xy(x0,y0b+2*dy,x1,y0b+3*dy))

	$.chanbutt.resize(xy(x0,y0b+3*dy,x1,y0b+4*dy))
	$.watchbutt.resize(xy(x0,y0b+4*dy,x1,y1))
}
method setwalktime(v) {
	$.looptime = v
}
method getwalktime(v) {
	return($.looptime)
}
method setwalktype(arr) {
	$.walkvals = arr
}
}
function offwalktask(o) {
	nexttime = nextquant(Now,1b)
	for ( ;; ) {
		nexttime += $.looptime
		sleeptill(nexttime-1b/4)
		o.random()
	}
}
function mkmenu_woffwalkmore(o,po) {
	o.menucmd("Random",po,"random")
	o.submenu("Walk time ->","mkmenu_woffwalkwalktime",po,"setwalktime")
	o.submenu("Walk type ->","mkmenu_woffwalkwalktype",po,"setwalktype")
}
function mkmenu_woffwalkwalktype(o,po,meth) {
	o.menucmd("Random",po,meth,[0=1,1=2,2=3,3=4,4=5,5=6,6=7,7=8,8=9,9=10,10=11,11=12])
	o.menucmd("+/- 4th",po,meth,[0=5])
	o.menucmd("+/- 5th",po,meth,[0=7])
	o.menucmd("+/- 3,4,5,6th",po,meth,[0=4,1=5,2=7,3=9])
}
function mkmenu_woffwalkwalktime(o,po,meth) {
	o.menucmd("2b",po,meth,2b)
	o.menucmd("4b",po,meth,4b)
	o.menucmd("8b",po,meth,8b)
	o.menucmd("16b",po,meth,16b)
	o.menucmd("32b",po,meth,32b)
	o.menucmd("64b",po,meth,64b)
}
function offwatchtask_quit(o,mf) {
	onexit(closemidi,o)
	Mergefilter = mf
	Offsetpitch = 0
}
function offwatchtask(o,ch) {
	Midiin[o] = f = open()

	onexit(offwatchtask_quit,o,Mergefilter)

	# We eliminate that channel from merging
	Mergefilter |= 1<<(ch-1)

	firstpitch = -1
	while ( (m=get(f)) != Eof ) {
		if ( m.chan != ch )
			continue
		if ( m.type == NOTEON ) {
			if ( firstpitch < 0 )
				firstpitch = m.pitch
			else
				o.setoffset(m.pitch-firstpitch)
		}
	}
}
