class wmapwalk{
method init {
	$.w = new window()
	$.inherit($.w)

	$.mapto = []
	n=0
	old = Arraysort
	Arraysort = 1
	initial = 0
	for ( i in allchords() )
		$.mapto[n++] = i
	for ( i in allscales() ) {
		if ( i == "newage" )
			initial = n
		$.mapto[n++] = i
	}
	Arraysort = old
	$.kbutt = new kvalbutton($.mapto,$,"mapchanged")
	$.morebutt = new kmenubutton("More","mkmenu_wmapwalkmore",$)
	$.walkbutt = new ktoggle("Walk",$,"setwalking")
	$.addchild($.morebutt)
	$.addchild($.kbutt)
	$.addchild($.walkbutt)

	$.stoptids = []
	$.looptime = 4b
	$.tid = -1

	$.kbutt.set(initial)
	$.mapchanged(initial)
}
method setwalking(v) {
	if ( $.tid == -1 ) {
		$.tid = task mapwalktask($)
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
method mapchanged (v) {
	global(Mapto)
	Mapto = $.mapto[v]
}
method random() {
	v = rand(sizeof($.mapto))
	$.mapchanged(v)
	$.kbutt.set(v)
	$.kbutt.redraw()
}

method redraw {
	$.w.redraw()
	x0 = $.xmin()
	x1 = $.xmax()
	y0 = $.ymin()
	y1 = $.ymax()
	th = $.textheight()
	$.text("Map Walk",xy(x0,y0,x1,y0+th))
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
	dy = (y1-y0-th)/3
	y0b = y0 + th
	$.kbutt.resize(xy(x0,y0b,x1,y0b+dy))
	$.morebutt.resize(xy(x0,y0b+dy,x1,y0b+2*dy))
	$.walkbutt.resize(xy(x0,y0b+2*dy,x1,y1))
}
method setwalktime(v) {
	$.looptime = v
}
}
function mapwalktask(o) {
	nexttime = nextquant(Now,1b)
	for ( ;; ) {
		nexttime += $.looptime
		sleeptill(nexttime-1b/4)
		o.random()
	}
}
function mkmenu_wmapwalkmore(o,po) {
	o.menucmd("Random",po,"random")
	o.submenu("Walk time ->","mkmenu_wmapwalkwalktime",po,"setwalktime")
}
function mkmenu_wmapwalkwalktime(o,po,meth) {
	o.menucmd("2b",po,meth,2b)
	o.menucmd("4b",po,meth,4b)
	o.menucmd("8b",po,meth,8b)
	o.menucmd("16b",po,meth,16b)
	o.menucmd("32b",po,meth,32b)
}
