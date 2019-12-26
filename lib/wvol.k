class wvol {

method init {
	$.w = new window()
	$.inherit($.w)

	$.value = 120
	$.slider = new kslider(0,127,$.value,$,"volchange")
	$.togg = new kvalbutton([0="NoRec",1="Rec"],$0)
	$.addchild($.slider)
	$.addchild($.togg)
	$.lasttime = Now
}
method resize (sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	dy = $.textheight()+2
	$.slider.resize(xy($.xmin()+2,$.ymin()+dy,
			$.xmax()-2,$.ymax()-dy-2))
	$.togg.resize(xy($.xmin()+2,$.ymax()-dy,
			$.xmax()-2,$.ymax()-2))
}
method redraw {
	$.w.redraw()
	dy = $.textheight()+2
	$.w.text("Vol",xy($.xmin()+2,$.ymin(),$.xmax()-2,$.ymin()+dy))
	methodbroadcast()
}
method getval { return($.slider.get()) }
method setval (v) { $.value=integer(v) ; return($.slider.set(v)) }
method dump { return(["value"=string($.getval())]) }
method restore (state) {
		$.setval(state["value"])
}
method update() {
		$.volchange($.value)
}
method volchange (v) {
	$.value = integer(v)
	p = gvolchange(v)
	realmidi(p)
	# The 10 is somewhat arbitrary, but we definitely
	# don't want to record it too often
	if ( $.togg.get() && (Now-$.lasttime) > 10 ) {
		p.time = Now
		Recorded |= p
		$.lasttime = Now
	}
}
method get { return(gvolchange($.value)) }

}
