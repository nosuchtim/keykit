#name	wconsole
#usage	wconsole(window)
#desc	This tool is a console window, allowing interaction with
#desc	the interactive command interpreter.

class wconsole {
method init (fifo,interp,scroll) {
	$.w = new window("text")
	$.inherit($.w)

	if ( nargs() < 1 )
		fifo = open()
	if ( nargs() < 2 )
		interp = global(interploop)
	if ( nargs() < 3 )
		scroll = 1
	$.scroll = scroll
	$.consfifo = fifo
	if ( GrabNoSwitch && Root.isgrabbed() ) {
		print("Console is grabbed, focus is not being switched...")
	} else {
		Root.focus($)
	}
	if ( interp != nullfunc ) {
		task interp($.consfifo,$)
	}
}
method stop { registop(-1) }
method mousedown (m) {
	if ( GrabNoSwitch && Root.isgrabbed() ) {
		print("Console is grabbed, focus is not being switched...")
	} else {
		if ( Root.focus() != $ ) {
			Root.focus($)
			Consecho = 1
		}
	}
	$.mousedo(m)
}
method mousedrag (m) {
	if ( $.scroll )
		$.mousedo(m)
}
method consecho(c) {
	$.w.printf("%s",c)
}
method consolekey (c) {
	if ( $.consfifo >= 0 )
		put($.consfifo,c)
}
}
