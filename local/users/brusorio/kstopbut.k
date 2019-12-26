# stopbut - a circle button.

class kstopbut {
method init(drawfnc,obj,meth,...) {
	if ( nargs() < 1 ) {
		print("usage: kstopbut(drawfunc,...)")
		return()
	}

	$.w = new window()
	$.inherit($.w)
	$.value = 0
	if ( typeof(drawfnc) == "string" )
		drawfnc = textfunc(drawfnc)
	$.drawfuncstr = drawfnc
	if ( nargs() > 1 ) {
		$.obj = obj
		$.meth = meth
	}
	else {
		$.obj = $0
	}
	$.args = argvlist(...)
}
method mousedown(m) { $.bang(m) }
method setdrawfunc(f) { $.drawfuncstr = f }
method mousedrag (m) { }
method mouseup (m) { }
method set(v) { $.value = v }
method get { return($.value) }
method redraw {
		$.w.style(NOBORDER)
	df = $.drawfuncstr
	if ( $.value ) {
		$.w.fillellipse ($.w.size(),STORE)
		if ( df != 0 )
			efunction(df)(CLEAR)
	}
	else {
		$.w.redraw()
	  	$.w.ellipse ($.w.size(),STORE)

		if ( df != 0 )
			efunction(df)(STORE)
	}
}
method bang(m) {
	$.value = 1 - $.value
	$.redraw()
	if ( $.obj != $0 )
		$.obj.($.meth)($.value,m,varg($.args))
}
}
