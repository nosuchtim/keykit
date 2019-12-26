#name	kslider
#usage	kslider(vmin,vmax,vinit,invokefunc,args)
#desc	Create a slider object and return its id.  When the slider is
#desc	moved, the invokefunc will be called with 2 arguments - the first
#desc	will be the current value of the slider, and the second will be the
#desc	args value.  The vmin, vmax, and vinit values are the minimum,
#desc	maximum, and initial values for the slider.

class kslider {

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
	$.tid = -1
	$.taskstart = -1
}
method redraw {
	$.w.redraw()
	if ( $.linexy != 0 ) {
		$.line($.linexy)
	}
}
method get { return($.uvalue) }
method do {
	# maybe should put it in background, so errors don't kill slider ?
	if ( $.obj != $0 && $.obj != $-1 )
		$.obj.($.meth)($.uvalue,varg($.args))
}
method resize(sz) {
	$.killtask()
	$.w.resize(sz)
	ymin = $.ymin()+1
	ymax = $.ymax()-1
	$.yvalue = ymax - (($.uvalue-$.vmin)*(ymax-ymin))/($.vmax-$.vmin)
	$.linexy = xy($.xmin()+1,$.yvalue,$.xmax()-1,$.yvalue)
}
method set(...) {
	# We do it in a separate task so that the task calling this
	# can get killed, but the redrawing of the slider won't get
	# screwed up.
	task $.realset(...)
}
method realset(value,dodraw,doit,killtask) {

	if ( nargs() < 4 )
		killtask = 1
	if ( killtask )
		$.killtask()
	# bump priority so we don't get killed if parent dies,
	# otherwise drawing gets screwed up.
	incpriority()

	lock($)

	if ( nargs() < 2 )
		dodraw = 0
	if ( nargs() < 3 )
		doit = 0
	if ( dodraw && $.yvalue >= 0 && $.linexy != 0 ) {
		$.line($.linexy,CLEAR) # old line
	}
	uval = value
	if ( uval < $.vmin )
		uval = $.vmin
	else if ( uval > $.vmax )
		uval = $.vmax

	xmin = $.xmin()+1
	xmax = $.xmax()-1
	y = $.valtoy(uval)
	$.linexy = xy(xmin,y,xmax,y)
	if ( dodraw ) {
		$.line($.linexy,STORE)
	}
	$.yvalue = y
	$.uvalue = uval
	unlock($)
	decpriority()
	if ( doit )
		$.do()
}
method valtoy(uval) {
	ymin = $.ymin()+1
	ymax = $.ymax()-1
	xmin = $.xmin()+1
	xmax = $.xmax()-1
	y = ymax - ((uval-$.vmin)*(ymax-ymin))/($.vmax-$.vmin)
	return(y)
}
method setndo(v) {
	# This kills task if it's running
	$.set(v,1,1,1)
}
method incndo() {
	v = $.uvalue
	v += ($.vmax-$.vmin)/10
	if ( v > $.vmax )
		v = $.vmax
	# This kills task if it's running
	$.set(v,1,1,1)
}
method decndo() {
	v = $.uvalue
	v -= ($.vmax-$.vmin)/10
	if ( v < $.vmin )
		v = $.vmin
	# This kills task if it's running
	$.set(v,1,1,1)
}
method setndo_dontkill(v) {
	$.set(v,1,1,0)
}
method mousemove(m) {
	$.mousedrag(m)
}
method mousedown(m) {
	$.mousedrag(m)
}
method autotask(m)  {
	$.taskstart = Now
	my = m["y"]
	ymin = $.ymin()+1
	ymax = $.ymax()-1
	if ( my < ymin )
		my = ymin
	else if ( my > ymax )
		my = ymax
	y = $.valtoy($.uvalue)
	$.targetvalue = $.vmax - (($.vmax-$.vmin)*(my-ymin))/(ymax-ymin)
	if ( y < my )
		$.ydirection = 1
	else
		$.ydirection = -1
	n = 0
	while ( n++ < 1000 && $.uvalue != $.targetvalue ) {
		lock($)
		y += $.ydirection
		nv = $.vmax - (($.vmax-$.vmin)*(y-ymin))/(ymax-ymin)
		$.setndo_dontkill(nv)
		if ( $.ydirection == 1 ) {
			if ( $.uvalue > $.targetvalue )
				$.uvalue = $.targetvalue
		} else {
			if ( $.uvalue < $.targetvalue )
				$.uvalue = $.targetvalue
		}
		unlock($)
		millisleep(Sliderspeed)
	}
}
method mousedrag(m) {
	if ( m["button"] > 1 ) {
		if ( (Now-$.taskstart) < 1b )
			return()
		$.killtask()
		$.tid = task $.autotask(m)
		return()
	}
	lock($)
	# If autoslider task is running, kill it
	$.killtask()
	ymin = $.ymin()+1
	ymax = $.ymax()-1
	my = m["y"]
	if ( my < ymin )
		my = ymin
	else if ( my > ymax )
		my = ymax
	$.uvalue = $.vmax - (($.vmax-$.vmin)*(m["y"]-ymin))/(ymax-ymin)
	# make it a separate task, because it's going to lock on $, and
	# mouse events should NOT lock.
	task $.setndo($.uvalue)
	unlock($)
}
method killtask {
	if ( $.tid >= 0 ) {
		kill($.tid)
		$.tid = -1
	}
}
method delete {
	$.killtask()
}
}
