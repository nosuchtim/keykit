class wkeywalk{
method init {
	$.w = new window()
	$.inherit($.w)

	$.keys = [
		0 = "c",
		1 = "c+",
		2 = "d",
		3 = "d+",
		4 = "e",
		5 = "f",
		6 = "f+",
		7 = "g",
		8 = "g+",
		9 = "a",
		10 = "a+",
		11 = "b"
	]
	$.kbutt = new kvalbutton($.keys,$,"keychanged")
	$.morebutt = new kmenubutton("More","mkmenu_wkeywalkmore",$)
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

	# Start out walking with 3rd/4th/5th/6ths
	$.walkvals = [0=4,1=5,2=7,3=9]
	$.stoptids = []
	$.looptime = 4b
	$.tid = -1
}
method ison() {
	return ( $.tid >= 0 )
}
method walkonoff(v) {
	if ( $.tid == -1 ) {
		$.tid = task keywalktask($)
		$.stoptids[$.tid] = 1
	} else {
		$.stop()
	}
}
method watchonoff(v) {
	if ( $.tid == -1 ) {
		$.tid = task keywatchtask($,$.chanbutt.get()+1)
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
method keychanged (v) {
	Key.pitch = Keybase.pitch + v
}
method random() {
	if ( sizeof($.walkvals) == 0 )
		v = rand(sizeof($.keys))
	else {
		r = rand(sizeof($.walkvals))
		v = (rand(2)*2 - 1) * $.walkvals[r]
	
	}
	Key.pitch += v
	$.kbutt.set(canonic(Key))
	$.kbutt.redraw()
}

method redraw {
	$.w.redraw()
	x0 = $.xmin()
	x1 = $.xmax()
	y0 = $.ymin()
	y1 = $.ymax()
	th = $.textheight()
	$.text("Key Walk",xy(x0,y0,x1,y0+th))
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
method setwalktype(arr) {
	$.walkvals = arr
}
}
function keywalktask(o) {
	nexttime = nextquant(Now,1b)
	for ( ;; ) {
		nexttime += $.looptime
		sleeptill(nexttime-1b/4)
		o.random()
	}
}
function mkmenu_wkeywalkmore(o,po) {
	o.menucmd("Random",po,"random")
	o.submenu("Walk time ->","mkmenu_wkeywalkwalktime",po,"setwalktime")
	o.submenu("Walk type ->","mkmenu_wkeywalkwalktype",po,"setwalktype")
}
function mkmenu_wkeywalkwalktype(o,po,meth) {
	o.menucmd("Random",po,meth,[0=1,1=2,2=3,3=4,4=5,5=6,6=7,7=8,8=9,9=10,10=11,11=12])
	o.menucmd("+/- 4th",po,meth,[0=5])
	o.menucmd("+/- 5th",po,meth,[0=7])
	o.menucmd("+/- 3,4,5,6th",po,meth,[0=4,1=5,2=7,3=9])
}
function mkmenu_wkeywalkwalktime(o,po,meth) {
	o.menucmd("2b",po,meth,2b)
	o.menucmd("4b",po,meth,4b)
	o.menucmd("8b",po,meth,8b)
	o.menucmd("16b",po,meth,16b)
	o.menucmd("32b",po,meth,32b)
	o.menucmd("64b",po,meth,64b)
}
function keywatchtask_quit(o,mf) {
	onexit(closemidi,$)
	Mergefilter = mf
}
function keywatchtask(o,ch) {
	Midiin[$] = f = open()

	onexit(keywatchtask_quit,$,Mergefilter)

	# We eliminate that channel from merging
	Mergefilter |= 1<<(ch-1)

	while ( (m=get(f)) != Eof ) {
		if ( m.chan != ch )
			continue
		if ( m.type == NOTEON )
			Key.pitch = m.pitch
	}
}
