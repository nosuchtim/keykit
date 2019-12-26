class wremapper{
method init {
	$.w = new window()
	$.inherit($.w)

	$.chans = []
	for ( n=0; n<16; n++ )
		$.chans[n] = string(n+1)
	$.chanbutt = new kvalbutton($.chans)
	$.onoffbutt = new ktoggle("On",$,"onoff")
	$.addchild($.chanbutt)
	$.addchild($.onoffbutt)

	$.stoptids = []
	$.tid = -1
}
method onoff(v) {
	if ( $.tid == -1 ) {
		ch = $.chanbutt.get()+1
		$.tid = task remapper(ch)
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
method redraw {
	$.w.redraw()
	x0 = $.xmin()
	x1 = $.xmax()
	y0 = $.ymin()
	y1 = $.ymax()
	th = $.textheight()
	$.text("Remapper",xy(x0,y0,x1,y0+th))
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
	dy = (y1-y0-th)/2
	y0b = y0 + th
	$.chanbutt.resize(xy(x0,y0b,x1,y0b+dy))
	$.onoffbutt.resize(xy(x0,y0b+dy,x1,y1))
}
}
