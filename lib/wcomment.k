class wcomment {

method init {
	$.w = new window()
	$.inherit($.w)

	$.commentees = []
	$.comment = "Comment..."
	$.w.style(NOBORDER)

}
method redraw {
	$.w.redraw()
	$.w.text($.comment,$.size())
}
method resize (sz) {
	if ( nargs() < 1 )
		sz = $.size()
	tw = $.textwidth()
	sz["x1"] = sz["x0"] + sizeof($.comment)*tw + 2*tw
	sz["y1"] = sz["y0"] + $.textheight() + 6
	sz = fit2root(sz)
	$.w.resize(sz)
}
method mousedown {
	s = getastr("Enter new value for comment (or <CR> to abort) -> ","")
	if ( s != "" ) {
		$.erase()
		$.comment = s
		$.resize()
		$.redraw()
	}
}
method dump {
	return ( [ "comment" = $.comment ])
}
method restore (state) {
	$.comment = state["comment"]
	$.resize()
}
method settext(s) {
	$.comment = s
}
}
