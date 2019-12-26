#name	k2dslider
#usage	k2dslider(vhmin,vhmax,vhinit,vvmin,vvmax,vinit,invokefunc,args)
#desc	Create a 2D slider object and return its id.  When the slider is
#desc	moved, the invokefunc will be called with 3 arguments - the two first ones
#desc	will be the current values (horizontal and vertical) of the slider, and the third will 
#desc	be the args value.  The vmin, vmax, and vinit values are the minimum,
#desc	maximum, and initial values for the sliders (h and v)

class k2dslider {

method init(vhmin,vhmax,vhinit,vvmin,vvmax,vvinit,obj,meth,...) {
	$.w = new window()
	$.inherit($.w)

	$.uhvalue = vhinit
	$.vhmin = vhmin
	$.vhmax = vhmax

	$.uvvalue = vvinit
	$.vvmin = vvmin
	$.vvmax = vvmax

	if ( nargs() < 7 ) {
		$.obj = $0
		$.meth = ""
		$.args = []
	} else {
		$.obj = obj
		$.meth = meth
		$.args = argvlist(...)
	}
	$.hlinexy = 0
	$.vlinexy = 0
}
method redraw {
	$.w.redraw()
	if ( $.hlinexy != 0 ) {
		$.line($.hlinexy)
	}
	if ( $.vlinexy != 0 ) {
		$.line($.vlinexy)
	}
}
method get { return(["h"= $.uhvalue, "v"= $.uvvalue]) }
method do {
	# maybe should put it in background, so errors don't kill slider ?
	if ( $.obj != $0 && $.obj != $-1 )
		$.obj.($.meth)($.uhvalue,$.uvvalue,varg($.args))
}
method resize(sz) {
	$.w.resize(sz)
	ymin = $.ymin()+1
	ymax = $.ymax()-1
	$.yvalue = ymax - (($.uvvalue-$.vvmin)*(ymax-ymin))/($.vvmax-$.vvmin)
	$.vlinexy = xy($.xmin()+1,$.yvalue,$.xmax()-1,$.yvalue)

	xmin = $.xmin()+1
	xmax = $.xmax()-1
	$.xvalue = xmax - (($.vhmax - $.uhvalue)*(xmax-xmin))/($.vhmax-$.vhmin)
	$.hlinexy = xy($.xvalue,$.ymin()+1,$.xvalue,$.ymax()-1)
}
method set(...) {
	# We do it in a separate task so that the task calling this
	# can get killed, but the redrawing of the slider won't get
	# screwed up.
	task $.realset(...)
}
method realset(hvalue,vvalue,dodraw,doit) {

	# bump priority so we don't get killed if parent dies,
	# otherwise drawing gets screwed up.
	incpriority()

	lock($)

	if ( nargs() < 3 )
		dodraw = 0
	if ( nargs() < 4 )
		doit = 0
	if ( dodraw && ($.yvalue >= 0 && $.vlinexy != 0) || ($.xvalue >= 0 && $.hlinexy != 0)) {
		$.line($.hlinexy,CLEAR) # old lines
		$.line($.vlinexy,CLEAR)
	}
	uhval = hvalue
	if ( uhval < $.vhmin )
		uhval = $.vhmin
	else if ( uhval > $.vhmax )
		uhval = $.vhmax
	uvval = vvalue
	if ( uvval < $.vvmin )
		uvval = $.vvmin
	else if ( uvval > $.vvmax )
		uvval = $.vvmax


	ymin = $.ymin()+1
	ymax = $.ymax()-1
	xmin = $.xmin()+1
	xmax = $.xmax()-1
	y = ymax - ((uvval-$.vvmin)*(ymax-ymin))/($.vvmax-$.vvmin)
	$.vlinexy = xy(xmin,y,xmax,y)
	x = xmax - (($.vhmax-uhval)*(ymax-ymin))/($.vhmax-$.vhmin)
	$.hlinexy = xy(x,ymin,x,ymax)
	if ( dodraw ) {
		$.line($.vlinexy,STORE)
		$.line($.hlinexy,STORE)
	}
	$.xvalue = x
	$.uhvalue = uhval
	$.yvalue = y
	$.uvvalue = uvval
	unlock($)
	decpriority()
	if ( doit )
		$.do()
}
method setndo(hv,vv) {
	$.set(hv,vv,1,1)
}
method mousemove(m) {
	$.mousedrag(m)
}
method mousedown(m) {
	$.mousedrag(m)
}
method mousedrag(m) {
	ymin = $.ymin()+1
	ymax = $.ymax()-1
	xmin = $.xmin()+1
	xmax = $.xmax()-1
	my = m["y"]
	if ( my < ymin )
		my = ymin
	else if ( my > ymax )
		my = ymax
	mx = m["x"]
	if ( mx < xmin )
		mx = xmin
	else if ( mx > xmax )
		mx = xmax
	$.uhvalue = $.vhmax - (($.vhmax-$.vhmin)*(xmax-m["x"]))/(xmax-xmin)
	$.uvvalue = $.vvmax - (($.vvmax-$.vvmin)*(m["y"]-ymin))/(ymax-ymin)
	# make it a separate task, because it's going to lock on $, and
	# mouse events should NOT lock.
	task $.setndo($.uhvalue, $.uvvalue)
}
}
