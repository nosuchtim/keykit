class wlifecell {

method init {
	$.w = new window()
	$.inherit($.w)

	$.commentees = []
	$.comment = "Comment..."
	# $.w.style(NOBORDER)
	$.factor = 1.0
	$.red = 0
	$.green = 0
	$.blue = 0

}
method setmax(mx) {
	$.factor = (255*256.0) / mx
}
method setrgb(r,g,b) {
	$.red = r * $.factor
	$.green = g * $.factor
	$.blue = b * $.factor
}
method redraw(noclear) {
	if ( nargs() < 1 )
		noclear = 0
	sz = $.size()
	# $.w.text($.comment,sz)
	x0 = sz["x0"]
	x1 = sz["x1"]
	y0 = sz["y0"]
	y1 = sz["y1"]
	dx = (x1-x0)/3

	if ( noclear == 0 ) {
		$.w.redraw()
	}

	colormix(5,$.red,$.green,$.blue)
	colorset(5)
	$.w.fillrectangle(xy(x0,y0,x1,y1),STORE)

	colorset(1)
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
