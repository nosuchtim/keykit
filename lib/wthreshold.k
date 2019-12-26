class wthreshold {

method init {
	$.w = new window()
	$.inherit($.w)

	$.value = 100
	$.slider = new kslider(0,255,$.value,$,"change")
	$.togg = new ktext(string($.value))
	$.addchild($.slider)
	$.addchild($.togg)
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
	$.w.text("Thresh",xy($.xmin()+2,$.ymin(),$.xmax()-2,$.ymin()+dy))
	methodbroadcast()
}
method getval { return($.slider.get()) }
method setval (v) { $.value=integer(v) ; return($.slider.set(v)) }
method dump { return(["value"=string($.getval())]) }
method restore (state) {
	$.setval(state["value"])
}
method change (v) {
	VideoThreshold = integer(v)
	$.togg.set(string(v))
	$.togg.redraw()
}
method get { return($.value) }

}
