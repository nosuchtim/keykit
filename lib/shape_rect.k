class shape_rect {
	method init(d,x,y) {
		$.s = new shape(d,x,y)
		$.inherit($.s)
		$.boundx0 = -0.2
		$.boundy0 = -0.2
		$.boundx1 = 0.2
		$.boundy1 = 0.2
	}
	method getbounds() {
		f = fxy($.boundx0*$.scalex,$.boundy0*$.scaley,$.boundx1*$.scalex,$.boundy1*$.scaley)
		return(f)
	}
	method redraw() {
		px0 = $.posx+$.boundx0*$.scalex
		py0 = $.posy+$.boundy0*$.scaley
		px1 = $.posx+$.boundx1*$.scalex
		py1 = $.posy+$.boundy1*$.scaley
if($.debug)print("RECT DRAW xy0=",px0,py0," xy1=",px1,py1,"  scalexy=",$.scalex,$.scaley,"  boundxy0=",$.boundx0,$.boundy0,"  boundxy1=",$.boundx1,$.boundy1)
		m = $.getmode()
		if ( $$.getfilled() ) {
			$.top.fill_rect(px0,py0,px1,py1,m)
		} else {
			$.top.draw_rect(px0,py0,px1,py1,m)
		}
	}
}
