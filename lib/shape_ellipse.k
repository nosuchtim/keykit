class shape_ellipse {
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
		$.top.draw_ellipse(px0,py0,px1,py1,STORE,0)
	}
}
