# 
# This is a crude "visual keyboard".  It doesn't show black and white
# keys, or anything, but shows currently-deperessed notes visually,
# in realtime.

class wvisual {

method init {
	$.w = new window()
	$.inherit($.w)

	$.chans = []
	for ( n=0; n<16; n++ )
		$.chans[n] = string(n+1)
	$.chans[16] = "ALL"
	$.chanbutt = new kvalbutton($.chans,$,"chanchanged")
	$.addchild($.chanbutt)

	$.chanbutt.set(16)
	$.lookchan = -1

	$.tid = task $.lookee()
	$.stoptids = [$.tid = 1]
}

method shownote(n) {
	if ( n.type == NOTEON || n.type == NOTEOFF ) {
		xv1 = $.x0 + 1 + n.pitch*($.x1 - $.x0-2)/128
		xv2 = $.x0 + 1 + (n.pitch+1)*($.x1 - $.x0-2)/128
		x = xy(xv1,$.y0a+2,xv2,$.y1-2)
		if ( n.type == NOTEON )
			$.w.fillrectangle(x,STORE)
		else 
			$.w.fillrectangle(x,CLEAR)
	}
}

method chanchanged(v) {
	if ( v > 15 )
		$.lookchan = -1
	else
		$.lookchan = v
}

method dump {
	return ( [ "chan"=$.chanbutt.get() ] )
}

method restore (state) {
	ch = state["chan"]
	$.chanbutt.set(ch)
	$.chanchanged(ch)
}

method stop {
	killtids($.stoptids)
	$.stoptids = []
}
method delete {
	$.stop()
}

method redraw {
	$.w.redraw()
	$.w.text("Visual Notes",xy($.x0+1,$.y0,$.x0+4*$.dx+1,$.y0a))
	$.w.text("Ch:",xy($.x0+5*$.dx+1,$.y0,$.x0+6*$.dx,$.y0a))
	methodbroadcast()
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	$.dx = ($.xmax()-$.xmin()) / 7
	$.y0 = $.ymin()+2
	$.y0a = $.ymin() + $.textheight() + 4
	$.x0 = $.xmin() + 2
	$.x1 = $.xmax() - 2
	$.y1 = $.ymax() - 2
	$.chanbutt.resize(xy($.x0+6*$.dx+1,$.y0,$.x0+7*$.dx-2,$.y0a))
}
method lookee(o) {
	Midiin[$] = f = open()
	onexit(global(closemidi),$)
	while ( (nt=get(f)) != Eof ) {
		if ( $.lookchan < 0 || nt.chan == ($.lookchan+1) ) {
			$.shownote(nt)
		}
	}
}

}
