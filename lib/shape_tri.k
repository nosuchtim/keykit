class shape_tri {
	method init(d,x,y) {
		$.s = new shape(d,x,y)
		$.inherit($.s)
	}
	method redraw() {
		$.disp.draw_line(
			$.posx+$.boundx0,
			$.posy+$.boundy1,
			$.posx+($.boundx0+$.boundx1)/2,
			$.posy+$.boundy0,STORE)
		$.disp.draw_line(
			$.posx+($.boundx0+$.boundx1)/2,
			$.posy+$.boundy0,
			$.posx+$.boundx1,
			$.posy+$.boundy1,STORE)
		$.disp.draw_line(
			$.posx+$.boundx1,
			$.posy+$.boundy1,
			$.posx+$.boundx0,
			$.posy+$.boundy1,STORE)
	}
}
