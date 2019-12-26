class wcascade {
method init {
	$.w = new window()
	$.inherit($.w)

	$.scaletime = 1.0
	$.morebutt = new kmenubutton("More","mkmenu_cascade1",$)
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

	$.textwidget = new ktext("GrabBag")
	$.textwidget.style(NOBORDER)
	$.t0 = new kbutton("Stop",$,"stop")
	$.montoggle = new ktoggle("Mon",$,"setmon")
	$.looptoggle = new ktoggle("Loop",$,"setlooping")
	$.walktoggle = new ktoggle("Walk",$,"setwalking")
	chans = []
	for ( n=1; n<=16; n++ )
		chans[n-1] = string(n)
	$.chanbutt = new kvalbutton(chans,$,"changechan")
	$.patchbutt = new kvalbutton(patchmapnames(),$,"changepatch")
	$.patchnums = patchmapnums()

	$.grid = []
	$.locationof = []

	global bsriff
	$.rifffunc = bsriff

	$.addchild($.textwidget)
	$.addchild($.morebutt)
	$.addchild($.mode1butt)
	$.addchild($.mode2butt)
	$.addchild($.montoggle)
	$.addchild($.looptoggle)
	$.addchild($.walktoggle)
	$.addchild($.chanbutt)
	$.addchild($.patchbutt)

	$.startquant = 1
	$.loopquant = 1b
	$.retrigger = 0
	$.looping = 0
	$.walking = 0
	$.walkrepeat = 1
	$.walkcountup = 0
	$.pauserepeat = 0
	$.pausecountdown = 0
	$.factor = 1.0
	$.playtid = 0
	$.chktid = 0
	$.stoptids = []
	$.origp = ''
	$.gridrows = 0
	$.gridcols = 0
	$.startpatt($0)
	$.current_patt_r = -1
	$.current_patt_c = -1
	$.current_ctrl = ''
	$.current_ctrl_w = $0
	$.lookfor = []
	$.montid = -1
	$.rechannel = 1
	$.patch = 1

	$.setgridsize(4,4,0)

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
method changechan(ch) {
	$.rechannel = ch+1
}
method changepatch(v) {
	$.patch = $.patchnums[v]
	realmidi(progchange($.patch,$.rechannel))
}
method changevol(v) {
	realmidi(chanvolchange($.rechannel,v))
}
method changemode(m,bn) {
	if ( bn == 1 )
		$.mode1 = m
	else
		$.mode2 = m
}
method drawgridcell(c) {
	p = c.get()
	c.redraw()
}

method redraw {
	$.w.redraw()
	for ( c in $.children() ) {
		if ( c.classof() == "wphrase" ) {
			$.drawgridcell(c)
		} else {
			c.redraw()
		}
	}
}

method delete {
	killtids($.stoptids)
	$.stoptids = []
}

method setfunc(f,fill,ch) {
	$.rifffunc = f
	if ( fill != 0 ) {
		for ( r=0; r<$.gridrows; r++ ) {
			for ( c=0; c<$.gridcols; c++ ) {
				w = $.grid[r][c]
				p = f()
				$.setgrid(w,p)
			}
		}
	}
	if ( nargs() > 2 ) {
		$.rechannel = ch
		$.chanbutt.set(ch-1)
		$.chanbutt.redraw()
	}
}

method scaleall(f) {
	for ( r=0; r<$.gridrows; r++ ) {
		for ( c=0; c<$.gridcols; c++ ) {
			w = $.grid[r][c]
			p = w.get()
			p = scatimes(p,f)
			$.setgrid(w,p)
		}
	}
}

method setlooping(v) {
	$.looping = v
	if ( v != 0 && $.walktoggle.get() != 0 ) {
		$.walking = 0
		$.walktoggle.set(0)
		$.walktoggle.redraw()
	}
}
method setwalking(v) {
	$.walking = v
	if ( v != 0 && $.looptoggle.get() != 0 ) {
		$.looping = 0
		$.looptoggle.set(0)
		$.looptoggle.redraw()
	}
	if ( $.walking && $.current_patt_w == $0 ) {
		r = rand($.gridrows)
		c = rand($.gridcols)
		w = $.grid[r][c]
		$.playcell(w)
	}
}
method setmon (v) {
	if ( v ) {
		# turn monitoring on
		if ( $.montid < 0 ) {
			$.montid = task wcascade_mon($)
		}
	} else {
		# turn monitoring off
		if ( $.montid >= 0 ) {
			kill($.montid)
			$.montid = -1
		}
	}
}
method setstartquant (v) {
	$.startquant = v
}
method setloopquant (v) {
	$.loopquant = v
}
method setwalkrepeat (v) {
	$.walkrepeat = v
}
method setpauserepeat (v) {
	$.pauserepeat = v
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
	if ( w.classof() == "wphrase" ) {
		if ( md == 0 ) {
			$.setgrid(w,Snarf)
		} else if ( md == 1 ) {
			$.setgrid(w,strip(lastbunch(Recorded,2b)))
		} else if ( md == 2 ) {
			$.setgrid(w,strip(lastbunch(Recorded,8b)))
		} else if ( md  == 3 ) {
			nt = tail(Recorded,1)
			if ( nt.type != NOTEON ) {
				mn = makenote(nt.pitch,1b,100,nt.chan)
				$.lookfor[mn] = w
			} else {
				print("Last note received wasn't a NOTE?")
			}
		} else if ( md == 4 ) {
			$.lookfor[w] = "a"
		} else if ( md == 5 ) {
			if ( m["button"] > 1 )
				slowchange = 1
			else
				slowchange = 0
			$.playcell(w,slowchange)
		} else if ( md == 6 ) {
			Snarf = w.get()
		} else if ( md == 7 ) {
			func = $.rifffunc
			$.setgrid(w,func())
		} else {
			print("Undefined mode (",md,")");
		}
	}
	else {
		mouseforward(m,"mousedown")
	}
}

method playcell(w,slowchange) {
	if ( nargs() < 2 )
		slowchange = 0
	# Play
	p = w.get()
	if ( $.current_patt_w != $0 ) {
		# Already one playing
		if ( $.retrigger ) {
			$.highlight($.current_patt_w,CLEAR)
			$.stop()
			$.startpatt(w)
			$.usepercent()
			$.next_patt_w = $0
			tm = nextquant(Now,$.startquant)
			$.playcurrentat(tm)
		} else {
			# queue up this one
			$.next_patt_w = w
		}
	} else {
		$.startpatt(w)
		$.usepercent()
		$.next_patt_w = $0
		tm = nextquant(Now,$.startquant)
		$.playcurrentat(tm)
		$.resetpausecountdown()
	}
}
method dump {
	s = []
	s["gridrows"] = $.gridrows
	s["gridcols"] = $.gridcols
	s["startquant"] = $.startquant
	s["loopquant"] = $.loopquant
	s["mode1"] = $.mode1
	s["mode2"] = $.mode2
	s["grid"] = []
	s["rechannel"] = $.rechannel
	s["patch"] = $.patch
	s["walkrepeat"] = $.walkrepeat
	s["pauserepeat"] = $.pauserepeat
	s["low"] = $.lowslider.get()
	s["lookfor"] = []
	for ( r=0; r<$.gridrows; r++ ) {
		s["grid"][r] = []
		s["lookfor"][r] = []
		for ( c=0; c<$.gridcols; c++ ) {
			w = $.grid[r][c]
			s["grid"][r][c] = w.get()
			# See if it's in the lookfor array
			found = 0
			for ( nt in $.lookfor ) {
				if ( $.lookfor[nt] == w ) {
					found = nt
					break
				}
			}
			if ( found != 0 )
				s["lookfor"][r][c] = found
		}
	}
	return ( s )
}
method restore (s) { 
	$.mode1 = s["mode1"]
	$.mode2 = s["mode2"]
	$.setgridsize(s["gridrows"],s["gridcols"],0)
	lf = s["lookfor"]
	for ( r=0; r<$.gridrows; r++ ) {
		for ( c=0; c<$.gridcols; c++ ) {
			w = $.grid[r][c]
			w.set(s["grid"][r][c])
			w.dozoomout(1,"xy")
			if ( lf[r][c] != 0 ) {
				$.lookfor[s["lookfor"][r][c]] = w
			}
		}
	}
	$.startquant = s["startquant"]
	$.loopquant = s["loopquant"]
	$.rechannel = s["rechannel"]
	$.walkrepeat = s["walkrepeat"]
	$.pauserepeat = s["pauserepeat"]
	$.chanbutt.set($.rechannel-1)
	$.patchbutt.set($.patch-1)
	$.resize()
}
method setretrigger (v) {
	$.retrigger = v
}
method setgridsize (rneeded,cneeded,doredraw) {
	# Add missing columns at the end of existing rows
	for ( r = 0; r<$.gridrows; r++ ) {
		for ( c=$.gridcols; c<cneeded; c++ ) {
			wp = new wphrase()
			$.grid[r][c] = wp
			$.addchild(wp)
			$.locationof[wp] = ["row"=r,"col"=c]
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
			wp = new wphrase()
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
	x0 = x0real + tw*2
	x1real = $.xmax() - 2
	x1 = x1real - tw*2
	y1 = $.ymax() - 1

	dx = (x1real-x0) / 10

	$.textwidget.resize(xy(x0real,y0,x0+dx-1,y0a))
	$.montoggle.resize(xy(x0+dx,y0,x0+2*dx-1,y0a))
	$.mode1butt.resize(xy(x0+2*dx+1,y0,x0+3*dx-1,y0a))
	$.mode2butt.resize(xy(x0+3*dx+1,y0,x0+4*dx-1,y0a))
	$.morebutt.resize(xy(x0+4*dx+1,y0,x0+5*dx-1,y0a))

	$.chanbutt.resize(xy(x0+5*dx+1,y0,x0+6*dx-1,y0a))
	$.patchbutt.resize(xy(x0+6*dx+1,y0,x0+7*dx-1,y0a))

	$.walktoggle.resize(xy(x0+8*dx+1,y0,x0+9*dx-1,y0a))
	$.looptoggle.resize(xy(x0+9*dx+1,y0,x1real,y0a))

	if ( $.gridcols != 0 )
		dx = (x1-x0)/$.gridcols
	gy0 = y0a+2
	if ( $.gridrows != 0 )
		dy = (y1-gy0)/$.gridrows
	gy1 = gy0
	for ( r=0; r<$.gridrows; r++ ) {

		# $.textwidget[r].resize(xy(x0real,y0a+2+r*dy,x0-1,y0a+2+(r+1)*dy))

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
method highlight(w,mode) {
	sz = w.size()
	$.rectangle(rectresize(sz,-1),mode)
}
method wcascadechk(tm) {
	sleeptill(tm-milliclicks(50))

	$.highlight($.current_patt_w,CLEAR)

	if ( $.next_patt_w != $0 ) {
		# There's a pending next pattern

		$.startpatt($.next_patt_w)
		$.usepercent()

		$.next_patt_w = $0

		$.pausecountdown = 0
		$.walkcountup = 0

		$.playcurrentat(tm)
	} else {
		if ( $.pauserepeat != 0 && $.pausecountdown>0 ) {
			$.pausecountdown--
			$.playcurrentat(tm,1)
		} else {
			if ( $.looping!=0 ) {
				$.playcurrentat(tm)
				$.resetpausecountdown()

			} else if ( $.walking != 0 ) {
				# We stay on a given cell $.walkrepeat times
				$.walkcountup++
				if ( $.walkcountup >= $.walkrepeat ) {
					$.walknext()
					$.walkcountup = 0
					$.resetpausecountdown()
				}
				$.playcurrentat(tm)
			} else {
				# We're stopping
				$.startpatt($0)
			}
		}
	}
}
method gotmidi(m) {
	if ( m.type == NOTEON ) {
		nt = makenote(m.pitch,1b,100,m.chan)
		if ( nt in $.lookfor ) {
			$.playcell($.lookfor[nt])
		}
	}
}
}

function mkmenu_cascade2(o,po) {
	o.menucmd("On",po,"setretrigger",1)
	o.menucmd("Off",po,"setretrigger",0)
}

function mkmenu_cascadeqvals(o,po,meth) {
	o.menucmd("None",po,meth,1)
	o.menucmd("1b",po,meth,1b)
	o.menucmd("2b",po,meth,2b)
	o.menucmd("4b",po,meth,4b)
	o.menucmd("8b",po,meth,8b)
}
function mkmenu_cascaderepeat(o,po,meth) {
	o.menucmd("1",po,meth,1)
	o.menucmd("2",po,meth,2)
	o.menucmd("4",po,meth,4)
	o.menucmd("8",po,meth,8)
}
function mkmenu_cascadepauserepeat(o,po,meth) {
	o.menucmd("0",po,meth,0)
	o.menucmd("1",po,meth,1)
	o.menucmd("2",po,meth,2)
	o.menucmd("3",po,meth,3)
	o.menucmd("4",po,meth,4)
	o.menucmd("5",po,meth,5)
	o.menucmd("6",po,meth,6)
	o.menucmd("7",po,meth,7)
	o.menucmd("8",po,meth,8)
	o.menucmd("15",po,meth,15)
	o.menucmd("31",po,meth,31)
}
function mkmenu_cascadesize(o,po) {
	o.menucmd("2x2",po,"setgridsize",2,2,1)
	o.menucmd("4x4",po,"setgridsize",4,4,1)
	o.menucmd("2x4",po,"setgridsize",2,4,1)
	o.menucmd("8x8",po,"setgridsize",8,8,1)
	o.menucmd("16x16",po,"setgridsize",16,16,1)
}

function mkmenu_cascade1(o,po) {
	o.submenu("Grid Size   ->","mkmenu_cascadesize",po)
	o.submenu("Loop Quant  ->","mkmenu_cascadeqvals",po,"setloopquant")
	o.submenu("Walk Repeat ->","mkmenu_cascaderepeat",po,"setwalkrepeat")
	o.submenu("Pause Repeat->","mkmenu_cascadepauserepeat",po,"setpauserepeat")
	o.submenu("Retrigger   ->","mkmenu_cascade2",po)
	o.submenu("Start Quant ->","mkmenu_cascadeqvals",po,"setstartquant")
	o.submenu("Load from   ->","mkmenu_cascadeload",po)
	o.submenu("Riff Func   ->","mkmenu_cascadefunc",po,0)
	o.submenu("Fill All    ->","mkmenu_cascadefunc",po,1)
	o.submenu("Scale All   ->","mkmenu_cascadescale",po,1)
}
function mkmenu_cascadeload(o,po) {
	o.menucmd("File",po,"readfile",0)
	o.menucmd("Snarf",po,"readfile",1)
}
function mkmenu_cascadefunc(o,po,fill) {
	global bsriff
	global bsriff2
	global bschord
	global bs202drum4
	global bs202drum8
	global bsgmdrum4
	global bsgmdrum8
	o.menucmd("BS Riff (4b)",po,"setfunc",bsriff,fill)
	o.menucmd("BS Riff (8b)",po,"setfunc",bsriff2,fill)
	o.menucmd("BS Chords",po,"setfunc",bschord,fill)
	o.menucmd("DR202 drums (4b)",po,"setfunc",bs202drum4,fill,10)
	o.menucmd("DR202 drums (8b)",po,"setfunc",bs202drum8,fill,10)
	o.menucmd("GM drums (4b)",po,"setfunc",bsgmdrum4,fill,10)
	o.menucmd("GM drums (8b)",po,"setfunc",bsgmdrum8,fill,10)
}
function mkmenu_cascadescale(o,po) {
	o.menucmd("Slow down",po,"scaleall",2.0)
	o.menucmd("Speed up",po,"scaleall",0.5)
}

function wcascade_mon(gb) {
	Midiin[$] = f = open()
	onexit(closemidi,$)
	while ( (m=get(f)) != Eof ) {
		gb.gotmidi(m)
	}
}
