class ktext {
method init(text,just) {
	if ( nargs() < 1 )
		error("usage: ktext(string)")
	if ( nargs() < 2 )
		$.just = ""
	else
		$.just = just
	$.w = new window()
	$.inherit($.w)
	$.text = text
	$.isinverse = 0
}
method set(text) {
	$.text = string(text)
}
method setinverse(t) {
	$.isinverse = t
}
method setjust(j) {
	$.just = j
}
method setnoborder() {
	$.w.style(NOBORDER)
}
method get() {
	return($.text)
}
method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
}
method redraw() {
	$.w.redraw()
	sz = $.size()
	if ( $.isinverse ) {
		$.w.fillrectangle(sz,STORE)
		mode = CLEAR
	} else {
		mode = STORE
	}
	if ( $.just == "" )
		$.w.text($.text,sz,mode)
	else if ( $.just == "right" )
		$.w.textright($.text,sz,mode)
	else if ( $.just == "left" )
		$.w.textleft($.text,sz,mode)
}
}
