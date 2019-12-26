class wdancepad {

method init (padnum) {

	$.w = new window()
	$.inherit($.w)
	$.padnum = padnum

	$.b1 = new kbutton("SELECT",$,"doselect")
	$.addchild($.b1)
	$.b2 = new kbutton("START",$,"dostart")
	$.addchild($.b2)

	$.b1.setinvokeboth()
	$.b2.setinvokeboth()

	$.labels = [0=[],1=[],2=[]]
	$.labels[0][0] = "X"
	$.labels[0][1] = "UP"
	$.labels[0][2] = "CIRCLE"
	$.labels[1][0] = "LEFT"
	$.labels[1][1] = ""
	$.labels[1][2] = "RIGHT"
	$.labels[2][0] = "TRIANGLE"
	$.labels[2][1] = "DOWN"
	$.labels[2][2] = "SQUARE"

	$.b = []
	for ( r=0; r<3; r++ ) {
		$.b[r] = []
		for ( c=0; c<3; c++ ) {
			if ( r==1 && c==1 ) { continue }
			$.b[r][c] = new kbutton($.labels[r][c],$,"dob",r,c)
			$.addchild($.b[r][c])
			$.b[r][c].setinvokeboth()
		}
	}
	$.notify = 0
}
method setnotify(o,...) {
	$.notify = o
	$.args = argvlist(...)
}

method dob(updown,r,c) {
	if ( $.notify != 0 )
		$.notify.buttonchange($.padnum,$.labels[r][c],updown,varg($.args))
}
method doselect(updown) {
	if ( $.notify != 0 ) {
		$.notify.buttonchange($.padnum,"SELECT",updown,varg($.args))
	}
}
method dostart(updown) {
	if ( $.notify != 0 )
		$.notify.buttonchange($.padnum,"START",updown,varg($.args))
}
method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	else
		sz = $.w.size()
	th = $.textheight()
	tw = $.textwidth()
	$.x0 = sz["x0"]+3
	$.y0 = sz["y0"]+2
	$.y0a = sz["y0"]+th+4
	$.x1 = sz["x1"]-3
	$.y1 = sz["y1"]-3
	dx = ($.x1-$.x0)/6
	dy = ($.y1-$.y0a)/3
	$.b1.resize(xy($.x0+dx,$.y0,$.x0+3*dx-3,$.y0a-2))
	$.b2.resize(xy($.x0+3*dx+3,$.y0,$.x0+5*dx,$.y0a-2))
	for ( r=0; r<3; r++ ) {
	    for ( c=0; c<3; c++ ) {
		if ( r==1 && c==1 ) { continue }
		$.b[r][c].resize(xy($.x0+c*2*dx,$.y0a+r*dy,
					$.x0+(c+1)*2*dx,$.y0a+(r+1)*dy))
	    }
	}
}
method redraw {
	methodbroadcast()
}
}
