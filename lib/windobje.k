class window {

method init (...) {
	$.wi = new windowobject(...)
	$.inherit($.wi)

	# possible values for mode are: normal, invisible, and icon
	$.mode = "normal"
}

# method delete { deleteobject($.wi) }
method displaymode (mode) {
	if ( nargs() > 0 )
		$.mode = mode
	return($.mode)
}
method classof {
	return($$.class)
}
method erase {
	oldsz = $.wi.size()
	Root.fillrectangle(oldsz,CLEAR)
	Root.drawoverlap(oldsz,$$)
}
method recreate {
	return($$.class+"($"+string(integer($$))+")")
}
method mousedown (m) { mouseforward(m,"mousedown") }
method mouseup (m) { mouseforward(m,"mouseup") }
method mousedrag (m) { mouseforward(m,"mousedrag") }
# method mousemove (m) {
# 	# mouseforward(m,"mousemove")
# }

method windowsover(xyarr,wexcept) {
	if ( nargs() < 2 )
		wexcept = []
	nover = 0
	if ( typeof(wexcept) != "array" )
		error("windowsover() expects an array for wexcept!")
	for ( o in $$.children() ) {
		if ( typeof(o) != "object" ) {
			print("In windowsover, o isn't an object!?  o=",o)
			continue
		}
		if ( ! defined(o.contains) )
			continue
		if ( ! o.contains(xyarr) )
			continue
		if ( o in wexcept )
			continue
		nover++
	}
	return(nover)
}

method drawoverlap(sz,oexcept) {
	for ( o in $$.children() ) {
		if ( typeof(o) != "object" ) {
			print("In windowsover, o isn't an object!?  o=",o)
			continue
		}
		if ( defined(o.contains) && o.contains(sz) && o != oexcept )
			o.redraw()
	}
}
}
