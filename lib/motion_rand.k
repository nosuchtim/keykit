class motion_rand {
	method init(top) {
		$.mt = new motion(top)
		$.inherit($.mt)
	}
	method move1(sh) {
		posxy = sh.getpos()
		a = $.getparam("RAND")
		posx = posxy["x0"] + a - (rand(100) * 2*a) / 100.0
		posy = posxy["y0"] + a - (rand(100) * 2*a) / 100.0
		sh.setpos(posx,posy)
	}
	method bound1(s,initx,inity) {
		if($$.debug)print("MOTION_RAND . bound1 $=",$," s=",s," initxy=",initx,inity)
	}
}
