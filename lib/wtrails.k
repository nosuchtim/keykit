class wtrails {
method init {
	$.w = new window()
	$.inherit($.w)
	$.playon = 0

	VideoThreshold = 90
	VideoTool = $
	$.notifyon = 0
	$.debug = 1
	$.playtid = -1
	$.throttle = 1b/16
	$.backlog = 0
	$.segsize = 1b
	$.phrase = step(completescale('c',"newage"),1b/8)

	mdep("video","start")

	$.colors = ["r"="red","g"="green","b"="blue"]
	$.preview = 1
	$.color2chan = ["r"=1,"g"=2,"b"=3]
	$.evolvesteps = 16
	$.evolvetime = 4b
	$.scaletime = 1.0
	$.videotype = 0	# show real color
	$.morebutt = new kmenubutton("More","mkmenu_trails1",$)
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

	$.textwidget = new ktext("Trails")
	$.textwidget.style(NOBORDER)
	$.t0 = new kbutton("Stop",$,"stop")
	$.montoggle = new ktoggle("Mon",$,"setmon")
	$.playtoggle = new ktoggle("Play",$,"setplay")
	$.notifytoggle = new ktoggle("Notify",$,"setnotify")
	chans = []
	for ( n=1; n<=16; n++ )
		chans[n-1] = string(n)

	charr = []
	for ( n=1; n<=14; n++ )
		charr[n-1] = string(n)
	$.chanbutt = new kvalbutton(charr,$,"chanchanged")

	$.grid = []
	$.locationof = []

	global bsriff
	$.rifffunc = bsriff

	$.addchild($.textwidget)
	$.addchild($.morebutt)
	$.addchild($.montoggle)
	$.addchild($.playtoggle)
	$.addchild($.chanbutt)
	$.addchild($.notifytoggle)

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
	$.chanoffset = 0
	$.setgridsize(16,16,0)

	$.reset()

}
method chanchanged(v) {
	$.chanoffset = v
}
method setsegsize(v) {
	$.segsize = v
	$.reset()
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
method setnotify (v) {
	$.notifyon = v
}
method setmon (v) {
	if ( v ) {
		# turn monitoring on
		if ( $.montid < 0 ) {
			mdep("video","capture","start",$.gridcols,$.gridrows)
			$.montid = task $.wtrails_mon($)
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
	fname = browsefiles("MIDI File (*.mid)","*.mid",1)
	if ( fname == "" ) {
		print("No file specified!")
		return()
	}
	mf = onlynotes(readmf(fname))
	mf = mf{??.chan != 10}	# eliminate drum channel
	$.setfromphrase(mf)
}
method readsnarf {
	$.setfromphrase(Snarf)
}
method reset() {
	$.setfromphrase($.phrase)
}
method setfromphrase(mf) {
	tm1 = 0
	$.phrase = mf
	$.phrases = []
	mf.length = latest(mf)
	for ( r=0; r<$.gridrows; r++ ) {
		$.phrases[r] = []
		for ( c=0; c<$.gridcols; c++ ) {
			w = $.grid[r][c]
			tm2 = tm1 + $.segsize
			p = cut(mf,CUT_TIME,tm1,tm2)
			p.time -= tm1
			p.length = $.segsize
			$.phrases[r][c] = p
			tm1 = tm2
			if ( tm1 >= mf.length ) {
				# start over
				tm1 = 0
			}
		}
	}
}
method setvideotype(v) {
	$.videotype = v
}
method setpreview(v) {
	$.preview = v
}
method setgrid(w,p) {
	w.set(p)
	w.dozoomout(1,"xy")
	w.redraw()
	$.drawgridcell(w)
}

method dump {
	s = []
	s["gridrows"] = $.gridrows
	s["gridcols"] = $.gridcols
	s["chanoffset"] = $.chanoffset
	s["notifyon"] = $.notifyon
	s["segsize"] = $.segsize
	s["phrase"] = $.phrase
	return ( s )
}
method restore (s) { 
	$.setgridsize(s["gridrows"],s["gridcols"],0)
	$.chanoffset = s["chanoffset"]
	$.chanbutt.set($.chanoffset)
	$.notifyon = s["notifyon"]
	$.notifytoggle.set($.notifyon)
	$.segsize = s["segsize"]
	$.phrase = s["phrase"]
	$.reset()
	# $.resize()
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
	$.phrases = 0

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

	dx = (x1real-x0) / 7

	$.textwidget.resize(xy(x0real,y0,x0+dx-1,y0a))
	$.montoggle.resize(xy(x0+2*dx,y0,x0+3*dx-1,y0a))
	$.morebutt.resize(xy(x0+3*dx+1,y0,x0+4*dx-1,y0a))
	$.playtoggle.resize(xy(x0+4*dx+1,y0,x0+5*dx-1,y0a))
	$.chanbutt.resize(xy(x0+5*dx+1,y0,x0+6*dx-1,y0a))
	$.notifytoggle.resize(xy(x0+6*dx+1,y0,x0+7*dx-1,y0a))

	if ( $.gridcols != 0 )
		dx = (x1-x0)/$.gridcols
	gy0 = y0a+2
	if ( $.gridrows != 0 )
		dy = (y1-gy0)/$.gridrows
	gy1 = gy0
	for ( r=0; r<$.gridrows; r++ ) {
		gx0 = x0
		gx1 = x0
		if ( r == ($.gridrows-1) )
			gy1 = y1 
		else
			gy1 += dy
		for ( c=0; c<$.gridcols; c++ ) {
			if ( c == ($.gridcols-1) )
				gx1 = x1 
			else
				gx1 += dx
			arr = xy(gx0+1,gy0+1,gx1-1,gy1-1)
			$.grid[r][c].resize(arr)
			gx0 = gx1
		}
		gy0 = gy1
	}
}
method wtrails_mon() {
	lastplay = []
	for ( cl in $.colors )	
		lastplay[cl] = 0
	v = []
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

			for ( cl in $.colors ) {
				v = mdep("video","getchange",
							$.colors[cl],gx,gy)
				if ( v > VideoThreshold ) {
					dt = Now-lastplay[cl]
					if ( dt > -$.backlog ) {
						if ( dt < 1 )
							lastplay[cl] += $.throttle
						else
							lastplay[cl] = Now
						task $.play1(lastplay[cl],r,c,cl)
					}
				}
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
		ch = $.color2chan[cl] + $.chanoffset
		if ( $.phrases != 0 ) {
			p = $.phrases[r][c]
			p.chan = ch
		} else {
			p = $.mm.getcell(r,c,ch)
		}
		p2 = p
		p2.vol /= 2
		p3 = p2
		p3.vol /= 2
		p4 = p3
		p4.vol /= 2
		p5 = p4
		p5.vol /= 2
		# p6 = p5
		# p6.vol /= 2
		p = p + p2 + p3 + p4 + p5 # + p6
		sleeptill(t)
		kill($.playtid)
		$.playtid = realtime(p)
	}
	if ( $.notifyon ) {
		if ( defined(TrappedTool) && TrappedTool != $0 ) {
			TrappedTool.notify(r,c,cl)
		}
		if ( defined(MazeTool) && MazeTool != $0 ) {
			MazeTool.notify(r,c,cl)
		}
	}
}
}

function mkmenu_trailspreview(o,po) {
	o.menucmd("On",po,"setpreview",1)
	o.menucmd("Off",po,"setpreview",0)
}
function mkmenu_trailstype(o,po) {
	o.menucmd("Real Color",po,"setvideotype",0)
	o.menucmd("Threshold Color",po,"setvideotype",1)
}
function mkmenu_trailssize(o,po) {
	o.menucmd("8x8",po,"setgridsize",8,8,1)
	o.menucmd("16x16",po,"setgridsize",16,16,1)
	o.menucmd("32x32",po,"setgridsize",32,32,1)
}
function mkmenu_trailssegsize(o,po) {
	o.menucmd("1b/2",po,"setsegsize",1b/2)
	o.menucmd("1b",po,"setsegsize",1b)
	o.menucmd("2b",po,"setsegsize",2b)
	o.menucmd("4b",po,"setsegsize",4b)
}
function mkmenu_trailsread(o,po) {
	o.menucmd("File",po,"readfile")
	o.menucmd("Snarf",po,"readsnarf")
}

function mkmenu_trails1(o,po) {
	o.submenu("Grid Size ->","mkmenu_trailssize",po)
	o.submenu("Show      ->","mkmenu_trailstype",po)
	o.submenu("Preview   ->","mkmenu_trailspreview",po)
	o.submenu("Read From ->","mkmenu_trailsread",po)
	o.submenu("Seg Size  ->","mkmenu_trailssegsize",po)
}

