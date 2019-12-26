class kmsg {

method init (msg,sz) {
	$.w = new window()
	$.inherit($.w)
	$.msg = msg
	$.saved = 0
}
method redraw {
	if ( ! $.saved ) {
		$.w.saveunder()
		$.saved = 1
	}
	$.w.redraw()
	$.w.textcenter($.msg,$.size())
}
method resize (sz) {
	# message is centered on requested size,
	# but is forced to fit the text
	m = xymid(sz)
	tx = $.textwidth() * (sizeof($.msg)+2)
	ty = ($.textheight() * 3) / 2
	dx = sz["x1"] - sz["x0"]
	dy = sz["y1"] - sz["y0"]
	if ( tx > dx )
		tx = dx
	if ( ty > dy )
		ty = dy
	$.w.resize(xy(m["x"]-tx/2, m["y"]-ty/2,
			m["x"]+tx/2, m["y"]+ty/2))
}
method delete {
	if ( $.saved )
		$.w.restoreunder()
}
}
