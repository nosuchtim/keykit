class shape {
	method init(top,posx,posy) {
		$.debug = 0
		$.posx = posx
		$.posy = posy
		$.top = top
		$.age = 0.0
		$.setscale(1.0,1.0)
		$.motions = []
		$.mode = STORE
		$.filled = 1
	}
	method setmode(m) {
		$.mode = m
	}
	method setfilled(m) {
		$.filled = m
	}
	method getpos() {
		return(fxy($.posx,$.posy))
	}
	method setpos(posx,posy) {
		$.posx = posx
		$.posy = posy
	}
	method setscale(fx,fy) {
		$.scalex = fx
		$.scaley = fy
if($.debug)print("SETSCALE in SHAPE, fxy=",fx,fy)
	}
	method getage() {
		return($.age)
	}
	method position() {
		return(fxy($.posx,$.posy))
	}
	method addmotion(m) {
		$.motions[m] = 1
if($.debug)print("XXX shape.addmotion, m=",m)
	}
	method move1() {

		init_x = $.posx
		init_y = $.posy
if($.debug)print("=== MOVE1 init_xy=",init_x,init_y,"  posxy=",$.posx,$.posy)

		for ( obj in $.motions )
			obj.move1($$)

		for ( obj in $.motions ) {
if($.debug)print("=== calling bound1 for obj=",obj)
			obj.adjustbound1($$,init_x,init_y)
		}

		$$.age1()
	}
	method age1() {
		ageinc = $.top.getparam("AGEINC")
		$.age += ageinc
	}
	method getmode() {
		return($$.mode)
	}
	method getfilled() {
		return($$.filled)
	}
}
