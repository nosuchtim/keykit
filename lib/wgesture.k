class wgesture {
method init {
	$.w = new window()
	$.inherit($.w)
	$.playon = 0

	GestureTool = $
	$.debug = 0

	$.preview = 1
	$.color2chan = ["r"=1,"g"=2,"b"=3]
	$.evolvesteps = 16
	$.evolvetime = 4b
	$.scaletime = 1.0
	$.gesturetype = 0	# show real color
	$.morebutt = new kmenubutton("More","mkmenu_gesture1",$)
	arr = [
		0="Play",
		1="Control"
	]
	$.mode1butt = new kvalbutton(arr,$,"changemode",1)
	$.mode2butt = new kvalbutton(arr,$,"changemode",2)

	$.textwidget = new ktext("Video")
	$.textwidget.style(NOBORDER)
	$.t0 = new kbutton("Stop",$,"stop")
	$.montoggle = new ktoggle("Mon",$,"setmon")
	$.playtoggle = new ktoggle("Play",$,"setplay")
	chans = []
	for ( n=1; n<=16; n++ )
		chans[n-1] = string(n)

	$.grid = []
	$.locationof = []

	global bsriff
	$.rifffunc = bsriff

	$.addchild($.textwidget)
	$.addchild($.morebutt)
	$.addchild($.mode1butt)
	$.addchild($.mode2butt)
	$.addchild($.montoggle)
	$.addchild($.playtoggle)
	# $.addchild($.chanbutt)
	# $.addchild($.patchbutt)

	$.looping = 0
	$.factor = 1.0
	$.stoptids = []
	$.gridrows = 0
	$.gridcols = 0
	$.montid = -1
	$.patch = 1

	$.maxval = 0
	$.setgridsize(16,16,0)

	# Default values of buttons
	$.mode1butt.set(1)
	$.changemode(1,1)
	$.mode2butt.set(1)
	$.changemode(1,2)

	a = mdep("gesture","devices")
	$.width = []
	$.height = []
	$.fing_down = []
	$.fing_wp = []
	$.fing_tm = []
	for ( dev in a ) {
		$.width[dev] = a[dev]["width"]
		$.height[dev] = a[dev]["height"]
		$.fing_down[dev] = []
		$.fing_wp[dev] = []
		$.fing_tm[dev] = []
	}
	$.colors = [
			0=["r"=255,"g"=0,"b"=0],
			1=["r"=0,"g"=255,"b"=0],
			2=["r"=0,"g"=0,"b"=255],
			3=["r"=255,"g"=255,"b"=0]
		]

}
method changemode(m,bn) {
	if ( bn == 1 )
		$.mode1 = m
	else
		$.mode2 = m
}
method drawgridcell(c) {
	p = c.get()
	if ( p.type == CONTROLLER ) {
		c.text("CTRL",c.size())
	} else {
		c.redraw()
	}
}

method redraw(noclean) {
	if ( nargs() < 1 )
		noclean = 0
	if ( noclean == 0 )
		$.w.redraw()
	for ( c in $.children() )
		c.redraw(noclean)
}

method delete {
	killtids($.stoptids)
	$.stoptids = []
	GestureTool = $0
}

method setplay (v) {
	$.playon = v
}
method setmon (v) {
	if ( v ) {
		# turn monitoring on
		gestureclear()
		gesturenotifyrc($,$.gridrows,$.gridcols)
	} else {
		gestureunnotify($)
	}
}
method setfactor(f) {
	$.factor = f
	$.set($.get(),1)
}
method findgrid(m) {
	x = m["x"]
	y = m["y"]
	if ( $.gridcols != 0 )
		dx = (x1-x0)/$.gridcols
	gy0 = y0a+2
	if ( $.gridrows != 0 )
		dy = (y1-gy0)/$.gridrows
	gy1 = gy0
	if ( y < gy0 || x < gx0 )
		return($0)
	for ( r=0; r<$.gridrows; r++ ) {
		gx0 = x0
		gx1 = x0
		if ( r == ($.gridrows-1) )
			gy1 = y1 
		else
			gy1 += dy
		if ( y > gy1 )
			continue
		for ( c=0; c<$.gridcols; c++ ) {
			if ( c == ($.gridcols-1) )
				gx1 = x1 
			else
				gx1 += dx
			if ( x < gx1 )
				return($.grid[r][c])
			gx0 = gx1
		}
		gy0 = gy1
	}
	return($0)
}
method readfile(dosnarf) {
	segsize = getastr("How many beats per cell? [4b] -->",4b)
	if ( dosnarf ) {
		mf = Snarf
	} else {
		fname = browsefiles("MIDI File (*.mid)","*.mid",1)
		if ( fname == "" ) {
			print("No file specified!")
			return()
		}
		mf = readmf(fname)
	}
	tm1 = 0
	for ( r=0; r<$.gridrows; r++ ) {
		for ( c=0; c<$.gridcols; c++ ) {
			w = $.grid[r][c]
			tm2 = tm1 + segsize
			p = cut(mf,CUT_TIME,tm1,tm2)
			p.time -= tm1
			p.length = segsize
			$.setgrid(w,p)
			tm1 = tm2
		}
	}
}
method setgesturetype(v) {
	$.gesturetype = v
}
method setpreview(v) {
	$.preview = v
print("preview = ",$.preview)
}
method setgrid(w,p) {
	w.set(p)
	w.dozoomout(1,"xy")
	w.redraw()
	$.drawgridcell(w)
}

method mousedown (m) {
	w = $.childunder(m)
	if ( m["button"] == 1 )
		md = $.mode1
	else
		md = $.mode2
	mouseforward(m,"mousedown")
}
method dump {
	s = []
	s["gridrows"] = $.gridrows
	s["gridcols"] = $.gridcols
	s["mode1"] = $.mode1
	s["mode2"] = $.mode2
	return ( s )
}
method restore (s) { 
	$.mode1 = s["mode1"]
	$.mode2 = s["mode2"]
	$.setgridsize(s["gridrows"],s["gridcols"],0)
	$.resize()
}
method setgridsize (rneeded,cneeded,doredraw) {
	if ( $.montid >= 0 ) {
		error("Can't set grid size while capturing!");
		return()
	}
	lock($)
	# Add missing columns at the end of existing rows
	for ( r = 0; r<$.gridrows; r++ ) {
		for ( c=$.gridcols; c<cneeded; c++ ) {
			wp = new wrgb()
			$.grid[r][c] = wp
			$.addchild(wp)
		}
	}
	# Remove extra columns at the end of existing rows
	for ( r = 0; r<$.gridrows; r++ ) {
		for ( c=cneeded; c<$.gridcols; c++ ) {
			wp = $.grid[r][c]
			$.removechild(wp)
			delete $.locationof[wp]
		}
	}

	# Add new rows
	for ( r=$.gridrows; r<rneeded; r++ ) {
		$.grid[r] = []
		for ( c=0; c<cneeded; c++ ) {
			wp = new wrgb()
			$.grid[r][c] = wp
			$.addchild(wp)
			$.locationof[wp] = ["row"=r,"col"=c]
		}
	}

	# Remove extra rows
	for ( r=rneeded; r<$.gridrows; r++ ) {
		# the extra columns have already been removed
		for ( c=0; c<cneeded; c++ ) {
			wp = $.grid[r][c]
			$.removechild(wp)
		}
	}

	$.gridrows = rneeded
	$.gridcols = cneeded
	if ( doredraw ) {
		$.resize()
		$.redraw()
	}
	$.setmax(255)

	$.mm = new mmatrix($.gridrows,$.gridcols,makenote(0),makenote(127),
		scale_fifths())

	unlock($)
}

method setmax(mx) {
	$.maxval = mx
	for ( r = 0; r<$.gridrows; r++ ) {
		for ( c=0; c<$.gridcols; c++ ) {
			wp = $.grid[r][c]
			wp.setmax(mx)
		}
	}
}

method stop {
	killtids($.stoptids)
	$.stoptids = []
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	tw = $.textwidth()
	th = $.textheight()
	y0 = $.ymin()+2
	y0a = $.ymin() + th + 4
	x0real = $.xmin() + 2
	x0 = x0real # + tw*2
	x1real = $.xmax() - 2
	x1 = x1real # - tw*2
	y1 = $.ymax() - 1

	dx = (x1real-x0) / 10

	$.textwidget.resize(xy(x0,y0,x0+dx-1,y0a))
	$.montoggle.resize(xy(x0+dx,y0,x0+2*dx-1,y0a))
	$.mode1butt.resize(xy(x0+2*dx+1,y0,x0+3*dx-1,y0a))
	$.mode2butt.resize(xy(x0+3*dx+1,y0,x0+4*dx-1,y0a))
	$.morebutt.resize(xy(x0+4*dx+1,y0,x0+5*dx-1,y0a))
	$.playtoggle.resize(xy(x0+5*dx+1,y0,x0+6*dx-1,y0a))

	# $.chanbutt.resize(xy(x0+5*dx+1,y0,x0+6*dx-1,y0a))
	# $.patchbutt.resize(xy(x0+6*dx+1,y0,x0+7*dx-1,y0a))

	y0 = y0a+2
	for ( r=0; r<$.gridrows; r++ ) {
		gy0 = y0 + r * (y1-y0)/($.gridrows)
		gy1 = y0 + (r+1) * (y1-y0)/($.gridrows)
		for ( c=0; c<$.gridcols; c++ ) {
			gx0 = x0 + c * (x1-x0)/($.gridcols)
			gx1 = x0 + (c+1) * (x1-x0)/($.gridcols)
			arr = xy(gx0+1,gy0+1,gx1-1,gy1-1)
			$.grid[r][c].resize(arr)
		}
	}
}
method toggledebug() {
	$.debug = 1 - $.debug
}
method printdown(s) {
	if ( nargs() > 0 )
		print(s)
	print("fing_wp=",$.fing_wp)
	print("fing_down=",$.fing_down)
}
method gotgesturerc(t,dev,finger,r,c) {

	if ( ! dev in $.colors ) {
		print("wgesture, dev=",dev," not in colors?")
		return()
	}

	if ( t == "fingerup" ) {
		wp = $.fing_wp[dev][finger]
		if ( typeof(wp) != "object" ) {
			print("wgesture, no object for dev=",dev," finger=",finger)
			return()
		} 
		if ( $.debug )
			print("calling rgb 000 dev=",dev," fing=",finger)
		wp.setrgb(0,0,0)
		wp.redraw(0)
		delete $.fing_wp[dev][finger]
		delete $.fing_down[dev][finger]
		delete $.fing_tm[dev][finger]
	} else if ( t == "fingerdown" ) {

		gx = c
		gy = $.gridrows - r - 1
		if ( finger in $.fing_down[dev] ) {
			return()
		}

		if ( $.debug )
			print("Now=",Now," FINGER ",finger,"  dev=",dev,"  gxy=",gx,gy)
		t = nextquant(Now,1b/4)
		if ( ! (gy in $.grid) ) {
			print("Hey, gy=",gy," not in $.grid?")
			return()
		}
		if ( ! (gx in $.grid[gy]) ) {
			print("Hey, gx=",gx," not in $.grid?")
			return()
		}
		wp = $.grid[gy][gx]

		red = $.colors[dev]["r"]
		green = $.colors[dev]["g"]
		blue = $.colors[dev]["b"]

		if ( $.debug )
			print("calling rgb ",red,green,blue," dev=",dev," fing=",finger)
		wp.setrgb(red,green,blue)
		wp.redraw(0)

		$.fing_wp[dev][finger] = wp
		$.fing_down[dev][finger] = 1
		$.fing_tm[dev][finger] = Now
		# print("Setting $.fing_down finger=",finger)
	}
}
method play1 (t,r,c,cl) {
# print("play1 r,c = ",r,c," cl=",cl)
	if ( $.playon ) {
		ch = $.color2chan[cl]
		p = $.mm.getcell(r,c,ch)
		p.time = t
		p.dur = 1b/4
		realtime(p,0)
	}
	if ( defined(TrappedTool) && TrappedTool != $0 ) {
		TrappedTool.notify(r,c,cl)
	}
	if ( defined(MazeTool) && MazeTool != $0 ) {
		MazeTool.notify(r,c,cl)
	}
}
}

function mkmenu_gesturepreview(o,po) {
	o.menucmd("On",po,"setpreview",1)
	o.menucmd("Off",po,"setpreview",0)
}
function mkmenu_gesturetype(o,po) {
	o.menucmd("Real Color",po,"setgesturetype",0)
	o.menucmd("Threshold Color",po,"setgesturetype",1)
}
function mkmenu_gesturesize(o,po) {
	o.menucmd("8x8",po,"setgridsize",8,8,1)
	o.menucmd("16x16",po,"setgridsize",16,16,1)
	o.menucmd("32x32",po,"setgridsize",32,32,1)
}

function mkmenu_gesture1(o,po) {
	o.submenu("Grid Size ->","mkmenu_gesturesize",po)
	o.submenu("Show      ->","mkmenu_gesturetype",po)
	o.submenu("Preview   ->","mkmenu_gesturepreview",po)
	o.menucmd("Print down",po,"printdown")
	o.menucmd("Toggle debug",po,"toggledebug")
}

