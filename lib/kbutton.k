class kbutton {

method init(drawfnc,obj,meth,...) {

	$.w = new window()
	$.inherit($.w)
	$.isdown = 0
	$.setdrawfunc(drawfnc)

	$.obj = obj
	$.meth = meth
	$.args = argvlist(...)
	$.invokedown = 1
	$.invokeboth = 0
	$.style(BUTTON)
}
method gettext {
	return($.text)
}
method mouseup(m) {
	if ( $.isdown ) {
		$.isdown = 0
		$.redraw()
		if ( $.invokeboth )
			$.obj.($.meth)(0,varg($.args))
		else if ( ! $.invokedown )   # i.e. it's invokeup
			$.obj.($.meth)(varg($.args))
	}
}
method mousedown(m) {
	if ( ! $.isdown ) {
		$.isdown = 1
		$.w.style(PRESSEDBUTTON)
		$.w.redraw()
		# $.w.fillrectangle($.w.size(),STORE)
		df = $.drawfunc
		if ( df != 0 )
			df($,CLEAR)
		$.w.style(BUTTON)
		if ( $.invokeboth )
			$.obj.($.meth)(1,varg($.args))
		else if ( $.invokedown )
			$.obj.($.meth)(varg($.args))
	}
}
method mousedrag (m) { }
method setinvokedown { $.invokedown = 1 }
method setinvokeup { $.invokedown = 0 }
method setinvokeboth { $.invokeboth = 1; $.invokedown = 0; $.invokeup = 0 }
method setdrawfunc(f) {
	if ( typeof(f) == "string" ) {
		$.drawfunc = global(kbutton_drawtext)
		$.text = f
	}
	else {
		$.drawfunc = f
		$.text = ""
	}
}
method settext(t) {
	$.drawfunc = global(kbutton_drawtext)
	$.text = t
}
method gettext {
	return($.text)
}
method redraw {
	$.w.redraw()
	df = $.drawfunc
	if ( df != 0 )
		df($)
}
}

function kbutton_drawtext(o,v) {
	if ( ! defined(o.gettext) ) {
		print("Warning: no gettext method in object")
	} else {
		t = o.gettext()
		if ( nargs() < 2 )
			v = STORE
		o.textcenter(t,o.size(),v)
	}
}
