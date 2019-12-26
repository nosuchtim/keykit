class wpriority {
method init {
	$.w = new window()
	$.inherit($.w)

	$.varr = [0="normal",1="high",2="realtime"]
	$.nbutt = new ktext("Priority");
	$.vbutt = new kvalbutton($.varr,$,"valchanged")
	$.addchild($.nbutt)
	$.addchild($.vbutt)

	# make sure first value is set
	$.valchanged()
}
method valchanged () {
	mdep("priority",$.vbutt.getvalue())
}
method dump {
	return( ["v"=$.vbutt.dump()] )
}
method restore (state) {
	$.vbutt.restore(state["v"])
	$.valchanged($.vbutt.get())
}

method redraw() {
	$.w.redraw()
	methodbroadcast()
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	$.y0 = $.ymin()+2 ; $.y1 = $.ymax()-2
	$.x0 = $.xmin()+2 ; $.x1 = $.xmax()-2 ; $.xm = ($.x0+$.x1)/2
	$.nbutt.resize(xy($.x0,$.y0,$.xm-1,$.y1))
	$.vbutt.resize(xy($.xm+1,$.y0,$.x1,$.y1))
}
}
