function gcontrol(ch,cnum) {
	if ( gesturedevices() <= 0 ) {
		print("No gesture device available!?")
		return()
	}
	if ( nargs() < 2 ) {
		print("Usage: gcontrol(channel,starting-controller-#)")
		return()
	}
	Gcontrol = new gcontrol_obj(ch,cnum)
	Root.waitforconsolekey()
	Gcontrol.stop()
	delete Gcontrol
}
class gcontrol_obj {
	method init(ch,cnum) {

		$.ch = ch
		$.cnum = cnum
		$.itid = -1
		$.debug = 0

		c = cnum
		$.controlx = []
		$.controly = []
		$.lastx = []
		$.lasty = []
		for ( n=0; n<5; n++ ) {
			$.controlx[n] = c++
			$.controly[n] = c++
			$.lastx[n] = -1
			$.lasty[n] = -1
		}

		g = mdep("gesture","devices")
		$.g_width = []
		$.g_height = []
		for ( n in g ) {
			$.g_width[n] = g[n]["width"]
			$.g_height[n] = g[n]["height"]
		}
		gestureclear()
		gesturenotify($)
	}
	method gotgesture(d) {
		contacts = d["contacts"]
		dev = d["device"]
		w = $.g_width[dev]
		h = $.g_height[dev]
		for ( i=0; i<contacts; i++ ) {
			if ( ! ( i in d ) ) {
				print("No i=",i," in d=",d," ??")
				continue
			}
			di = d[i]
			if ( ! "x" in di ) {
				print("No x in di=",di)
				continue
			}
			x = di["x"] / w
			y = di["y"] / h
			f = di["finger"]
			if ( f in $.controlx ) {
				v = integer(x*127)
				if ( $.lastx[f] != v ) {
					n = controller($.ch,$.controlx[f],v)
					realtime(n)
					$.lastx[f] = v
				}
			}
			if ( f in $.controly ) {
				v = integer(y*127)
				if ( $.lasty[f] != v ) {
					n = controller($.ch,$.controly[f],v)
					realtime(n)
					$.lasty[f] = v
				}
			}
		}
	}
	method setdebug(dbg) {
		$.debug = dbg
	}
	method stop {
		print("gcontrol is killing itid and closing sockets\n")
		if ( $.itid >= 0 )
			kill($.itid)
		gestureunnotify($)
	}

}
