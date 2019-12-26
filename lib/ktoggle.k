# ktoggle - a toggle button.

class ktoggle {
method init(drawfnc,obj,meth,...) {
	if ( nargs() < 1 ) {
		print("usage: ktoggle(drawfunc,...)")
		return()
	}

	$.w = new window()
	$.inherit($.w)

	$.value = 0
	$.only_do_on = 0
	$.setdrawfunc(drawfnc)
	if ( nargs() > 1 ) {
		$.obj = obj
		$.meth = meth
	}
	else {
		$.obj = $0
	}
	$.args = argvlist(...)
}
method setonly_do_on(v) {
	$.only_do_on = v
}
method mousedown(m) { $.bang(m) }
method gettext() {
	return($.text)
}
method settext(t,j) {
	$.text = t
	if ( nargs() > 1 )
		$.just = j	# is this used?
	$.drawfunc = global(kbutton_drawtext)
}

method setdrawfunc (f) {
	t = typeof(f)
	if ( t == "string" ) {
		$.drawfunc = global(kbutton_drawtext)
		$.text = f
	} else if ( t == "function" ) {
		$.drawfunc = f
		$.text = ""
	} else {
		print("Warning: .setdrawfunc expected string or function, got "+t)
		$.drawfunc = nullfunc
		$.text = ""
	}
}
method mousedrag (m) { }
method mouseup (m) { }
method set(v) { $.value = v }
method get { return($.value) }
method redraw {
	df = $.drawfunc
	if ( $.value ) {
		$.w.fillrectangle($.w.size(),STORE)
		if ( df != 0 )
			df($,CLEAR)
	}
	else {
		$.w.redraw()
		if ( df != 0 )
			df($,STORE)
	}
}
method bang(m) {
	if ( nargs() < 1 )
		m = []
	if ( $.value == 1 && $.only_do_on )
		return()
	$.value = 1 - $.value
	$.redraw()
	if ( $.obj != $0 )
		$.obj.($.meth)($.value,m,varg($.args))
}
}
