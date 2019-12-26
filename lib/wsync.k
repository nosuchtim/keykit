# Sync
#
# This is a tool that lets you loop 4 phrases.  Each phrase has a slider
# associated with it that lets you control its time scaling.  The primary
# intention is that, for example, you can put the same phrase in all 4 slots
# and just play with the time scaling.  Naturally it's not limited to this.
# The "Resync" button will start all phrases at the beginning.

class wsync {

method init {

	$.nphrases = 4         # you can actually change this, if you want more
	$.w = new window()
	$.inherit($.w)

	$.c = []
	$.togg = new ktoggle("On",$,"setonoff")
	$.buttresync = new kbutton("Resync",$,"resync")
	$.addchild($.togg)
	$.addchild($.buttresync)

	$.slide = []
	$.phr = []
	$.valtext = []

	# set up all the widgets - sliders, text fields, and phrases

	for ( i=0; i<$.nphrases; i++ ) {
		$.slide[i] = new kslider(0,40,20,$,"slidemoved",i)
		$.addchild($.slide[i])

		$.phr[i] = new wriff()
		$.phr[i].setlooping(1)
		$.addchild($.phr[i])
		$.phr[i].setstartquant(1)

		$.valtext[i] = new ktext("1.0")
		$.addchild($.valtext[i])
		$.setfactor(i,1.0)
	}
}
method redraw {
	$.w.redraw()
	$.line($.sep)
	$.w.text("Sync",$.textxy)
	for ( o in $.children() )
		o.redraw()
}
method dump {
	ret = []
	ret["i"] = $.nphrases
	for ( i=0; i<$.nphrases; i++ ) {
		ret[i] = $.phr[i].dump()
		ret["val"+string(i)] = $.valtext[i].get()
	}
	return(ret)
}
method restore (state) {
	for ( i=0; i<$.nphrases; i++ ) {
		$.phr[i].restore(state[i])
		$.valtext[i].set(state["val"+string(i)])
	}
}
method play() {
	stime = Now   # so they all start in sync
	for ( i=0; i<$.nphrases; i++ )
		$.phr[i].play(stime)
}
method stop() {
	for ( i=0; i<$.nphrases; i++ )
		$.phr[i].stop()
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
method setfactor (n,f) {
	$.phr[n].setfactor(f)
}
method slidemoved (v,n) {
	if ( v < 20 )
		f = 0.05 + v * 0.05
	else
		f = 1.0 + (v-20) * 0.25
	ss = sprintf("%5.2f",f)
	$.valtext[n].set(ss)
	$.valtext[n].redraw()
	$.setfactor(n,f);
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
	for ( i=0; i<=$.nphrases; i++ ) {
		ym[i] = y0a + i*dy/$.nphrases
	}

	xp1 = x0 + 4*dx/12	# for phrase
	xs1 = x0 + 2	        # for slider
	xs2 = x0 + dx/12
	xss1 = x0 	        # for sync label
	xss2 = x0 + 5*dx/12
	xt1 = x0 + 3 + dx/12	# for valtext
	xt2 = x0 + 4*dx/12 - 3
	xo1 = x0 + 6*dx/12	# for on toggle
	xo2 = x0 + 8*dx/12
	xr1 = x0 + 9*dx/12	# for resync
	xr2 = x0 + 11*dx/12

	$.sep = xy(x0,y0a-2,x1,y0a-2)
	$.textxy = xy(xss1,$.ymin(),xss2, y0a-4)

	$.togg.resize(xy(xo1,y0,xo2,y0a-4))
	$.buttresync.resize(xy(xr1,y0,xr2,y0a-4))

	th2 = 2*th / 3
	for ( i=0; i<$.nphrases; i++ ) {
		ym2 = (ym[i]+ym[i+1])/2
		$.valtext[i].resize(xy(xt1,ym2-th2,xt2,ym2+th2))
		$.slide[i].resize(xy(xs1,ym[i]+2,xs2,ym[i+1]-2))
		$.phr[i].resize(xy(xp1,ym[i]+1,x1,ym[i+1]-1))
	}
}
}
