class wgrid {

method init (cols,rows) {

	$.w = new window()
	$.inherit($.w)

	$.drawborder = 0
	$.cols = cols
	$.rows = rows
	$.upobj = $0 ; $.upmeth = "" ; $.updata = 0
	$.downobj = $0 ; $.downmeth = "" ; $.downdata = 0
	$.dragobj = $0 ; $.dragmeth = "" ; $.dragdata = 0
	$.callbackup = 0
	$.drawjoints = 1
	$.linecolor = 1
}

method setlinecolor(v) {
	$.linecolor = v
}

method setjoints(v) {
	$.drawjoints = v
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	else
		sz = $.w.size()
	$.x0 = sz["x0"]
	$.y0 = sz["y0"]
	$.x1 = sz["x1"]
	$.y1 = sz["y1"]
}
method redraw {
	ysz = $.y1 - $.y0 + 1
	colorset($.linecolor)
	for ( n=1; n<$.rows; n++ ) {
		y = $.y0 + (n*ysz)/$.rows
		$.w.line(xy($.x0,y,$.x1,y))
	}
	xsz = $.x1 - $.x0 + 1
	for ( n=1; n<$.cols; n++ ) {
		x = $.x0 + (n*xsz)/$.cols
		$.w.line(xy(x,$.y0,x,$.y1))
	}
	if ( $.drawborder )
		$.w.rectangle($.w.size())
}
method setborder(v) {
	$.drawborder = v
}
method drawwallright(r,c,mode) {
	ysz = $.y1 - $.y0 + 1
	xsz = $.x1 - $.x0 + 1
	y = $.y0 + (r*ysz)/$.rows
	y2 = $.y0 + ((r+1)*ysz)/$.rows
	x = $.x0 + ((c+1)*xsz)/$.cols
	if ( $.drawjoints == 0 ) {
		y++
		y2--
	}
	colorset($.linecolor)
	$.w.line(xy(x,y,x,y2),mode)
}
method drawwallbottom(r,c,mode) {
	ysz = $.y1 - $.y0 + 1
	xsz = $.x1 - $.x0 + 1
	y = $.y0 + ((r+1)*ysz)/$.rows
	x = $.x0 + (c*xsz)/$.cols
	x2 = $.x0 + ((c+1)*xsz)/$.rows
	if ( $.drawjoints == 0 ) {
		x++
		x2--
	}
	colorset($.linecolor)
	$.w.line(xy(x,y,x2,y),mode)
}
method getcellxy(r,c) {
	ysz = $.y1 - $.y0 + 1
	xsz = $.x1 - $.x0 + 1
	x0 = $.x0 + (c*xsz)/$.cols
	y0 = $.y0 + (r*ysz)/$.rows
	x0++
	y0++
	x1 = $.x0 + ((c+1)*xsz)/$.cols
	y1 = $.y0 + ((r+1)*ysz)/$.rows
	x1--
	y1--
	return( [
		"x0"=x0,
		"y0"=y0,
		"x1"=x1,
		"y1"=y1
		] )
}
method fillcell(r,c,mode) {
	arr = getcellxy(r,c)
	$.w.fillrectangle(arr,mode)
}
method setcallbackdown (o,m,d) {
	$.downobj=o
	$.downmeth=m
	if ( nargs() > 2 )
		$.downdata = d
	else
		$.downdata = 0
}
method setcallbackdrag (o,m,d) {
	$.dragobj=o
	$.dragmeth=m
	if ( nargs() > 2 )
		$.dragdata = d
	else
		$.dragdata = 0
}
method setcallbackup (o,m,d) {
	$.upobj=o
	$.upmeth=m
	if ( nargs() > 2 )
		$.updata = d
	else
		$.updata = 0
}
method mousedown (m) {
	if ( $.downobj != $0 )
		$.downobj.($.downmeth)($.xy2rc(m),m,$.downdata)
}
method mouseup (m) {
	if ( $.upobj != $0 )
		$.upobj.($.upmeth)($.xy2rc(m),m,$.updata)
}
method mousedrag (m) {
	if ( $.dragobj != $0 )
		$.dragobj.($.dragmeth)($.xy2rc(m),m,$.dragdata)
}
method xy2rc(m) {
	mx = m["x"]
	x = (mx-$.x0)
	c = integer(x*$.cols/($.x1-$.x0))
	my = m["y"]
	y = my-$.y0
	r = integer(y*$.rows/($.y1-$.y0))
# print("xy2rc x0y0x1y1=",$.x0,$.y0,$.x1,$.y1,"   m=",m,"  x1=",$.x1," x0=",$.x0,"  initial c=",c)
	if ( c >= $.cols )
		c = $.cols-1
	else if ( c < 0 )
		c = 0
	if ( r >= $.rows )
		r = $.rows-1
	else if ( r < 0 )
		r = 0
	dx = ($.x1-$.x0)/$.cols
	dy = ($.y1-$.y0)/$.rows
	relx = mx - ($.x0 + c * dx)
	rely = my - ($.y0 + r * dy)
	smallerdx = dx-2
	smallerdy = dy-2
	relx = relx / float(smallerdx)
	rely = rely / float(smallerdy)
	if ( relx < 0.0 ) relx = 0.0
	if ( rely < 0.0 ) rely = 0.0
	if ( relx > 1.0 ) relx = 1.0
	if ( rely > 1.0 ) rely = 1.0
	return(["row"=r,"col"=c,"x"=mx,"y"=my,"relx"=relx,"rely"=rely])
}
# This version is appropriate when you're passing in floating point values,
# and when you want to handle negative and larger-than-the-grid values.
# No bounding, so the returned values can exceed the grid row/col limits.
method rxy2rc(m) {
	mx = m["x"]
	x = (mx-$.x0)
	c1 = float(x)*$.cols/($.x1-$.x0)
# print("rxy2rc m=",m," x=",x,"  c1=",c1)
	c = round(c1 - 0.5)
	my = m["y"]
	y = my-$.y0
	r1 = float(y)*$.rows/($.y1-$.y0)
# print("rxy2rc m=",m," y=",y,"  r1=",r1)
	r = round(r1 - 0.5)
	return(["row"=r,"col"=c,"x"=mx,"y"=my])
}
method wgridrc2xy(m) {
	x = $.x0 + (c*($.x1-$.x0))/$.cols
	y = $.y0 + (r*($.y1-$.y0))/$.rows
	return(["x"=x,"y"=y])
}
}
