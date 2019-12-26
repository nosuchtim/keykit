#name	khslider
#usage	khslider(vmin,vmax,vinit,invokefunc,args)
#desc	Create a horizontal slider object and return its id.  When slider is
#desc	moved, the invokefunc will be called with 2 arguments - the first
#desc	will be the current value of the slider, and the second will be the
#desc	args value.  The vmin, vmax, and vinit values are the minimum,
#desc	maximum, and initial values for the slider.

class khslider {

method init(vmin,vmax,vinit,obj,meth,...) {
	$.w = new window()
	$.inherit($.w)
	$.uvalue = vinit
	$.vmin = vmin
	$.vmax = vmax
	if ( nargs() < 4 ) {
		$.obj = $0
		$.meth = ""
		$.args = []
	} else {
		$.obj = obj
		$.meth = meth
		$.args = argvlist(...)
	}
	$.linexy = 0
	$.dofill = 1
}
method redraw {
	$.w.redraw()
	if ( $.linexy != 0 ) {
		$.line($.linexy)
		$.fillit(STORE)
	}
}
method fillit(mode) {
	if ( $.dofill ) {
		x0 = $.xmin()
		y0 = $.ymin()
		x1 = $.linexy["x0"]
		y1 = $.ymax()
		$.fill(xy(x0+1,y0+1,x1-1,y1-1),mode)
	}
}
method get { return($.uvalue) }
method do {
	# maybe should put it in background, so errors don't kill slider ?
	if ( $.obj != $0 && $.obj != $-1 )
		$.obj.($.meth)($.uvalue,varg($.args))
}
method resize(sz) {
	$.w.resize(sz)
	xmin = $.xmin()+1
	xmax = $.xmax()-1
	$.xvalue = xmin + (($.uvalue-$.vmin)*(xmax-xmin))/($.vmax-$.vmin)
	$.linexy = xy($.xvalue,$.ymin()+1,$.xvalue,$.ymax()-1)
}
method set(...) {
	# We do it in a separate task so that the task calling this
	# can get killed, but the redrawing of the slider won't get
	# screwed up.
	task $.realset(...)
}
method realset(value,dodraw) {

	# bump priority so we don't get killed if parent dies,
	# otherwise drawing gets screwed up.
	incpriority()

	lock($)

	if ( nargs() < 2 )
		dodraw = 0
	if ( dodraw && $.xvalue >= 0 && $.linexy != 0 ) {
		$.line($.linexy,CLEAR) # old line
		$.fillit(CLEAR)
	}
	uval = value
	if ( uval < $.vmin )
		uval = $.vmin
	else if ( uval > $.vmax )
		uval = $.vmax

	ymin = $.ymin()+1
	ymax = $.ymax()-1
	xmin = $.xmin()+1
	xmax = $.xmax()-1
	x = xmin + ((uval-$.vmin)*(xmax-xmin))/($.vmax-$.vmin)
	$.linexy = xy(x,ymin,x,ymax)
	if ( dodraw ) {
		$.line($.linexy,STORE)
		$.fillit(STORE)
	}
	$.xvalue = x
	$.uvalue = uval
	unlock($)
	decpriority()
}
method setndo(v) {
	$.set(v,1)
	$.do()
}
method mousemove(m) {
	$.mousedrag(m)
}
method mousedown(m) {
	$.mousedrag(m)
}
method mousedrag(m) {
	xmin = $.xmin()+1
	xmax = $.xmax()-1
	$.uvalue = $.vmin + (($.vmax-$.vmin)*(m["x"]-xmin))/(xmax-xmin)
	# make it a separate task, because it's going to lock on $, and
	# mouse events should NOT lock.
	task $.setndo($.uvalue)
}
}
