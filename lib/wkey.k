class wkey{
method init {
	$.w = new window()
	$.inherit($.w)

	$.looptime = 1b
	$.tid = task keyshowtask($)
	$.stoptids = [$.tid = 1]
	$.current = Key
}
method delete {
	$.stop()
}
method stop {
	killtids($.stoptids)
	$.stoptids = []
	$.tid = -1
}
method redraw {
	$.w.redraw()
	drawkeyletter($.w,$.current)
}
method update {
	if ( Key != $.current ) {
		$.current = Key
		$.redraw()
	}
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
}
}
function keyshowtask(o) {
	nexttime = nextquant(Now,1b)
	for ( ;; ) {
		nexttime += $.looptime
		sleeptill(nexttime-1b/8)
		o.update()
	}
}
function drawkeyletter(w,p) {
	sz = w.size()
	x0 = sz["x0"]
	y0 = sz["y0"]
	x1 = sz["x1"]
	y1 = sz["y1"]
	tw = w.textwidth()
	th = w.textheight()

	x_left = x0 + 2*tw
	x_right = x1 - 2*tw
	x_mid = (x_left+x_right)/2
	x_midleft = (x_mid+x_left)/2
	x_midright = (x_mid+x_right)/2
	y_bot = y1 - th
	y_top = y0 + th
	y_mid = (y_bot+y_top)/2
	y_midtop = (y_top+y_mid)/2
	y_midbot = (y_bot+y_mid)/2

	p = canonic(p)
	if ( p == canonic('a') ) {
		w.line(xy(x_left,y_bot,x_mid,y_top))
		w.line(xy(x_mid,y_top,x_right,y_bot))
		w.line(xy(x_midleft,y_mid,x_midright,y_mid))
	} else if ( p == canonic('a+') ) {
		w.line(xy(x_left,y_bot,x_mid,y_top))
		w.line(xy(x_mid,y_top,x_right,y_bot))
		w.line(xy(x_midleft,y_mid,x_midright,y_mid))
		drawsharp(w,sz)
	} else if ( p == canonic('b') ) {
		w.line(xy(x_left,y_top,x_mid,y_top))
		w.line(xy(x_mid,y_top,x_midright,y_midtop))
		w.line(xy(x_midright,y_midtop,x_mid,y_mid))
		w.line(xy(x_left,y_mid,x_mid,y_mid))
		w.line(xy(x_mid,y_mid,x_midright,y_midbot))
		w.line(xy(x_midright,y_midbot,x_mid,y_bot))
		w.line(xy(x_left,y_bot,x_mid,y_bot))
		w.line(xy(x_left,y_top,x_left,y_bot))
	} else if ( p == canonic('c') ) {
		w.line(xy(x_left,y_top,x_mid,y_top))
		w.line(xy(x_left,y_top,x_left,y_bot))
		w.line(xy(x_left,y_bot,x_mid,y_bot))
	} else if ( p == canonic('c+') ) {
		w.line(xy(x_left,y_top,x_mid,y_top))
		w.line(xy(x_left,y_top,x_left,y_bot))
		w.line(xy(x_left,y_bot,x_mid,y_bot))
		drawsharp(w,sz)
	} else if ( p == canonic('d') ) {
		w.line(xy(x_left,y_top,x_mid,y_top))
		w.line(xy(x_mid,y_top,x_midright,y_mid))
		w.line(xy(x_midright,y_mid,x_mid,y_bot))
		w.line(xy(x_left,y_bot,x_mid,y_bot))
		w.line(xy(x_left,y_top,x_left,y_bot))
	} else if ( p == canonic('d+') ) {
		w.line(xy(x_left,y_top,x_mid,y_top))
		w.line(xy(x_mid,y_top,x_midright,y_mid))
		w.line(xy(x_midright,y_mid,x_mid,y_bot))
		w.line(xy(x_left,y_bot,x_mid,y_bot))
		w.line(xy(x_left,y_top,x_left,y_bot))
		drawsharp(w,sz)
	} else if ( p == canonic('e') ) {
		w.line(xy(x_left,y_top,x_mid,y_top))
		w.line(xy(x_left,y_mid,x_mid,y_mid))
		w.line(xy(x_left,y_top,x_left,y_bot))
		w.line(xy(x_left,y_bot,x_mid,y_bot))
	} else if ( p == canonic('f') ) {
		w.line(xy(x_left,y_top,x_mid,y_top))
		w.line(xy(x_left,y_mid,x_mid,y_mid))
		w.line(xy(x_left,y_top,x_left,y_bot))
	} else if ( p == canonic('f+') ) {
		w.line(xy(x_left,y_top,x_mid,y_top))
		w.line(xy(x_left,y_mid,x_mid,y_mid))
		w.line(xy(x_left,y_top,x_left,y_bot))
		drawsharp(w,sz)
	} else if ( p == canonic('g') ) {
		w.line(xy(x_midleft,y_top,x_mid,y_top))
		w.line(xy(x_mid,y_top,x_midright,y_midtop))
		w.line(xy(x_midleft,y_top,x_left,y_midtop))
		w.line(xy(x_mid,y_mid,x_midright,y_mid))
		w.line(xy(x_midright,y_mid,x_midright,y_midbot))
		w.line(xy(x_midright,y_midbot,x_mid,y_bot))
		w.line(xy(x_midleft,y_bot,x_mid,y_bot))
		w.line(xy(x_left,y_midtop,x_left,y_midbot))
		w.line(xy(x_left,y_midbot,x_midleft,y_bot))
	} else if ( p == canonic('g+') ) {
		w.line(xy(x_midleft,y_top,x_mid,y_top))
		w.line(xy(x_mid,y_top,x_midright,y_midtop))
		w.line(xy(x_midleft,y_top,x_left,y_midtop))
		w.line(xy(x_mid,y_mid,x_midright,y_mid))
		w.line(xy(x_midright,y_mid,x_midright,y_midbot))
		w.line(xy(x_midright,y_midbot,x_mid,y_bot))
		w.line(xy(x_midleft,y_bot,x_mid,y_bot))
		w.line(xy(x_left,y_midtop,x_left,y_midbot))
		w.line(xy(x_left,y_midbot,x_midleft,y_bot))
		drawsharp(w,sz)
	}
}
function drawsharp(w,sz) {
	x0 = sz["x0"]
	y0 = sz["y0"]
	x1 = sz["x1"]
	y1 = sz["y1"]
	dx = x1 - x0
	dy = y1 - y0
	w.line(xy(  x0+70*dx/100, y0+10*dy/100, x0+95*dx/100, y0+10*dy/100))
	w.line(xy(  x0+70*dx/100, y0+35*dy/100, x0+95*dx/100, y0+35*dy/100))

	w.line(xy(  x0+75*dx/100, y0+5*dy/100, x0+75*dx/100, y0+40*dy/100))
	w.line(xy(  x0+90*dx/100, y0+5*dy/100, x0+90*dx/100, y0+40*dy/100))
}
