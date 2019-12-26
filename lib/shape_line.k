class shape_line {
	method init(d,x,y) {
		$.s = new shape(d,x,y)
		$.inherit($.s)
	}
	method redraw() {
		$.disp.draw_line(
			$.posx+$.boundx0,
			$.posy+$.boundy0,
			$.posx+$.boundx1,
			$.posy+$.boundy1,STORE)
	}
}
