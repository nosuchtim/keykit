#name	krubber

class krubber {

method init(drawfnc,obj,startmeth,endmeth,...) {
	$.w = new window()
	$.inherit($.w)

	$.isdown = 0
	$.setdrawfunc(drawfnc)
	if ( typeof(obj) != "object" )
		error("Improper usage of krubber!?")
	$.obj = obj
	$.startmeth = startmeth
	$.endmeth = endmeth
	$.args = argvlist(...)
	$.invokedown = 1
	$.w.style(BUTTON)
}

method gettext {
	return($.text)
}

method mousedown (m) {
	grabmouse($)
	$.isdown = 1
	$.startx = $.endx = m["x"]
	$.starty = $.endy = m["y"]
	Root.line(xy($.startx,$.starty,$.endx,$.endy),XOR)

	$.w.style(PRESSEDBUTTON)
	$.w.redraw()
	df = $.drawfunc
	if ( df != 0 )
		(efunction(df))($,CLEAR)

	$.obj.($.startmeth)(varg($.args))
}
method mousedrag (m) {
	Root.line(xy($.startx,$.starty,$.endx,$.endy),XOR)
	$.endx = m["x"]
	$.endy = m["y"]
	Root.line(xy($.startx,$.starty,$.endx,$.endy),XOR)
}
method mouseup {
	if ( ! $.isdown )
		return()
	Root.line(xy($.startx,$.starty,$.endx,$.endy),XOR)

	o = Root.childunder(xy($.endx,$.endy))
	$.obj.($.endmeth)(o,varg($.args))

	$.w.style(BUTTON)
	$.redraw()

	ungrabmouse($)
	$.isdown = 0
}
method setinvokedown { $.invokedown = 1 }
method setinvokeup { $.invokedown = 0 }
method setdrawfunc (f) {
	if ( typeof(f) == "string" ) {
		$.drawfunc = global(kbutton_drawtext)
		$.text = f
	}
	else {
		$.drawfunc = f
		$.text = ""
	}
}
method redraw {
	$.w.redraw()
	df = $.drawfunc
	if ( df != 0 )
		(efunction(df))($)
}
}
