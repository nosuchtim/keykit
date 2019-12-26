class wtext {

method init(s) {
	$.w = new window()
	$.inherit($.w)

	$.commentees = []
	if ( nargs() < 1 )
		s = "Comment..."
	$.comment = s
	# $.w.style(NOBORDER)

}
method redraw {
	$.w.redraw()
	$.w.text($.comment,$.size())
}
method resize (sz) {
	if ( nargs() < 1 )
		sz = $.size()
	$.w.resize(sz)
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
