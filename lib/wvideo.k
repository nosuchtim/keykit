class wvideo {
method init {
	$.w = new window()
	$.inherit($.w)
	$.lastplay = 0
	$.playon = 0

	VideoThreshold = 80
	VideoTool = $
	$.debug = 1

	mdep("video","start")

	$.preview = 1
	$.color2chan = ["r"=1,"g"=2,"b"=3]
	$.evolvesteps = 16
	$.evolvetime = 4b
	$.scaletime = 1.0
	$.videotype = 0	# show real color
	$.morebutt = new kmenubutton("More","mkmenu_video1",$)
	arr = [
		0="Paste (Snarf)",
		1="Paste (Recorded 2b)",
		2="Paste (Recorded 8b)",
		3="Set Trigger (Recorded)",
		4="Set Trigger (Console)",
		5="Play",
		6="Snarf",
		7="Paste (Random Riff)"
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
	# $.chanbutt = new kvalbutton(chans,$,"changechan")
	# $.patchbutt = new kvalbutton(patchmapnames(),$,"changepatch")
	# $.patchnums = patchmapnums()

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
	$.startpatt($0)
	$.current_patt_r = -1
	$.current_patt_c = -1
	$.current_ctrl = ''
	$.current_ctrl_w = $0
	$.montid = -1
	$.patch = 1

	$.maxval = 0
	$.setgridsize(16,16,0)

	# Default values of buttons
	$.mode1butt.set(5)
	$.changemode(5,1)
	$.mode2butt.set(1)
	$.changemode(1,2)

}
method startpatt(w) {
	if ( w == $0 || w == $-1 ) {
		$.current_patt_w = $0
		$.current_patt = ''
	} else if ( nargs() == 1 ) {
		$.current_patt_w = w
		$.current_patt = w.get()
	} else {
		print("starttpatt called with > 1 args?")
	}
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
	VideoTool = $0
}

method setplay (v) {
	$.playon = v
}
method setmon (v) {
	if ( v ) {
		# turn monitoring on
		if ( $.montid < 0 ) {
			mdep("video","capture","start",$.gridcols,$.gridrows)
			$.montid = task $.wvideo_mon($)
		}
	} else {
		# turn monitoring off
		if ( $.montid >= 0 ) {
			mdep("video","capture","stop")
			kill($.montid)
			$.montid = -1
		}
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
method setvideotype(v) {
	$.videotype = v
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
	# w = findgrid(m)
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
method wvideo_mon() {
	lastplay1 = 0
	lastplay2 = 0
	lastplay3 = 0
	while ( 1 ) {
		lock($)

		if ( $.preview ) {
			avg = mdep("video","getaverage")
			ra = avg["red"]
			ga = avg["green"]
			ba = avg["blue"]
			gra = avg["grey"]
# print("ra=",ra," ga=",ga," ba=",ba," gra=",gra)
		}

		for ( r = 0; r<$.gridrows; r++ ) {
			for ( c=0; c<$.gridcols; c++ ) {
				gx = c
				gy = r

				wp = $.grid[r][c]

				if ( $.preview ) {
					red = mdep("video","get","red",gx,gy)
					green = mdep("video","get","green",gx,gy)
					blue = mdep("video","get","blue",gx,gy)
					if ( $.videotype == 1 ) {
						# Threshold colors
						if ( red > ra )
							red = 255
						else
							red = 0
						if ( green > ga )
							green = 255
						else
							green = 0
						if ( blue > ba )
							blue = 255
						else
							blue = 0
					}
					wp.setrgb(red,green,blue)
				}

				red = mdep("video","getchange","red",gx,gy)
				if ( red > VideoThreshold ) {
					t = Now
					if ( (t-lastplay1) < 1 ) {
						t = lastplay1 + 1
					}
					lastplay1 = t
					task $.play1(t,r,c,"r")
				}
				green = mdep("video","getchange","green",gx,gy)
				if ( green > VideoThreshold ) {
					t = Now
					if ( (t-lastplay2) < 1 ) {
						t = lastplay2 + 1
					}
					lastplay2 = t
					task $.play1(t,r,c,"g")
				}
				blue = mdep("video","getchange","blue",gx,gy)
				if ( blue > VideoThreshold ) {
					t = Now
					if ( (t-lastplay3) < 1 ) {
						t = lastplay3 + 1
					}
					lastplay3 = t
					task $.play1(t,r,c,"b")
				}
			}
		}
		unlock($)
		if ( $.preview ) {
			$.redraw(1)
		}
		sleeptill(Now+1b/4)
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

function mkmenu_videopreview(o,po) {
	o.menucmd("On",po,"setpreview",1)
	o.menucmd("Off",po,"setpreview",0)
}
function mkmenu_videotype(o,po) {
	o.menucmd("Real Color",po,"setvideotype",0)
	o.menucmd("Threshold Color",po,"setvideotype",1)
}
function mkmenu_videosize(o,po) {
	o.menucmd("8x8",po,"setgridsize",8,8,1)
	o.menucmd("16x16",po,"setgridsize",16,16,1)
	o.menucmd("32x32",po,"setgridsize",32,32,1)
}

function mkmenu_video1(o,po) {
	o.submenu("Grid Size ->","mkmenu_videosize",po)
	o.submenu("Show      ->","mkmenu_videotype",po)
	o.submenu("Preview   ->","mkmenu_videopreview",po)
}

