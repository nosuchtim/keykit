# graphic utils

function draw_uparrow(o) {
	x0 = o.xmin()
	x1 = o.xmax()
	y0 = o.ymin() + 2
	y1 = o.ymax() - 2
	o.line(xy(x0,y1,(x0+x1)/2,y0))
	o.line(xy((x0+x1)/2,y0,x1,y1))
	o.line(xy(x1,y1,x0,y1))
}

function draw_downarrow(o) {
	x0 = o.xmin()
	x1 = o.xmax()
	y0 = o.ymin() + 2
	y1 = o.ymax() - 2
	o.line(xy(x0,y0,(x0+x1)/2,y1))
	o.line(xy((x0+x1)/2,y1,x1,y0))
	o.line(xy(x1,y0,x0,y0))
}

