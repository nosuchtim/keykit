class motion {
	method init(top) {
		$.dx = 0.0
		$.dy = 0.0
		$.debug = 0
		$.top = top
	}
	method getparam(s) {
		v = $.top.getparam(s)
		return(v)
	}
	method setdxy(dx,dy) {
		$.dx = dx
		$.dy = dy
	}
	method adjustbound1(s,initx,inity) {
		if($.debug)print("MOTION . bound1 $=",$," s=",s," initxy=",initx,inity)
		$$.bound1(s,initx,inity)
	}
}
