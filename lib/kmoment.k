# kmoment - a momentary press button.

class kmoment {
method init(drawfnc,obj,meth,...) {
	if ( nargs() < 1 ) {
		print("usage: kmoment(drawfunc,...)")
		return()
	}

	$.w = new window()
	$.inherit($.w)

	$.value = 0
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
method mousedown(m) { $.domoment(1) }
method mouseup(m) { $.domoment(0) }
method mousedrag (m) { }
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
method domoment(v) {
	if ( v != $.value ) {
		$.value = v
		$.redraw()
		if ( $.obj != $0 )
			$.obj.($.meth)($.value,varg($.args))
	}
}
}
