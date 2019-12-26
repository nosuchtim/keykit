#
# This is a "timer" tool, showing elapsed time up to some limit.
# Intended for use when you have, say, an improvised piece that
# is 10 minutes long.  It lets you see where you are within the 10 minutes.

class wtimer {

method init {
	$.w = new window()
	$.inherit($.w)

	$.startbutt = new kbutton("Start",$,"start")
	mins = []
	for ( n=0; n<30; n++ ) {
		mins[n] = string(n+1)
	}
	$.minbutt = new kvalbutton(mins,$,"setminutes")

	$.addchild($.startbutt)
	$.addchild($.minbutt)

	$.stoptids = []
	$.minutes = 10
	$.sofar = -1
	$.minbutt.set($.minutes-1)
}

method setminutes(n) {
	$.minutes = n+1
}

method start() {
	$.stop()
	$.tid = task wtimer_task($,$.minutes)
	$.stoptids[$.tid] = 1
	$.sofar = 0
	$.mark(0)
}

method dump {
	return ( [ "minutes"=$.minutes ] )
}

method restore (state) {
	$.setminutes(state["minutes"]-1)
	$.minbutt.set($.minutes-1)
}

method stop {
	killtids($.stoptids)
	$.stoptids = []
	$.sofar = -1
}

method delete {
	$.stop()
}

method redraw {
	$.w.redraw()
	$.w.textleft("Timer",xy($.x0+1,$.y0,$.x0+4*$.dx+1,$.y0a))
	$.mark($.sofar)
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
	$.ym = ($.y0a + $.y1)/2
	$.startbutt.resize(xy($.x0+6*$.dx+1,$.y0,$.x0+7*$.dx-2,$.y0a))
	$.minbutt.resize(xy($.x0+5*$.dx+1,$.y0,$.x0+6*$.dx-2,$.y0a))
}

method mark(secs) {
	if ( $.sofar < 0 ) {
		return()
	}
	lastm = $.sofar / 60
	m = secs / 60
	s = secs % 60
	if ( m > $.minutes ) {
		print("wtimer m=",m," too big?")
	} else {
		$.w.fillrectangle(xy($.x0,$.y0a,$.x1,$.y1),CLEAR)
		dm = ($.x1-$.x0) / ($.minutes+1)

		tx = xy($.x0+(m)*dm,$.y0a,$.x0+(m+1)*dm,$.y1)
		$.w.fillrectangle(tx,STORE)
		tx = xy($.x0+(m)*dm,$.y0a,$.x0+(m+1)*dm,$.ym)
		$.w.text(string(m),tx,CLEAR)
		tx = xy($.x0+(m)*dm,$.ym,$.x0+(m+1)*dm,$.y1)
		$.w.text(string(s),tx,CLEAR)
	}
	$.sofar = secs
}

}

function wtimer_task(o,m) {
	t = Now
	tensecs = seconds(10)
	tot = tensecs * 6 * m
	secs = 0
	endsecs = (m+1) * 60 - 10
	while ( secs < endsecs ) {
		t += tensecs
		secs += 10
		sleeptill(t)
		o.mark(secs)
	}
	o.stop()
}
