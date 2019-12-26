# kcmdbutton - a command button

class kcmdbutton {
method init {
	$.butt = new kbutton(global(nullfunc),$,"invoke")
	$.butt.setinvokeup()
	$.inherit($.butt)
	$.cmd = [] 
}
method dump { return([ "cmd"=arraycopy($.cmd) ]) }
method restore(st) { $.setcmd(st["cmd"]) }
method setcmd(cmd) {
	if ( typeof(cmd) != "array")
		error("Hey, setcmd expects an array!?")
	$.cmd = arraycopy(cmd)
	if ( "label" in $.cmd )
		$.settext(cmd["label"])
	else {
		print("Hey, no label in $.cmd!?")
		$.settext("???")
	}
}
method invoke { docmd($.cmd) }

method fit(m) {
	lbl = $.gettext()
	if ( nargs() > 0 )
		sz = ["x0"=m["x"],"y0"=m["y"]]
	else
		sz = $.size()
	tw = $.textwidth()
	sz["x1"] = sz["x0"] + sizeof(lbl)*tw + 2*tw
	sz["y1"] = sz["y0"] + $.textheight() + 6
	sz = fit2root(sz)
	$.resize(sz)
}
}
