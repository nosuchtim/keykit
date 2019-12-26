class wtrapped {

method init {

	$.w = new window()
	$.inherit($.w)

	$.ch = 1
	$.tid = -1
	$.ballgridsize = 1000
	$.currentcolor = "r"

	$.butt2color = ["R1"="r","R2"="g","L1"="b"]
	$.colorchan = ["r"=1,"g"=2,"b"=3]
	$.colorindex = ["r"=8,"g"=9,"b"=10]
	colormix(8,255*255,0,0)
	colormix(9,0,255*255,0)
	colormix(10,0,0,255*255)

	$.grid = $0
	$.more = new kmenubutton("More","mkmenu_trapped1",$)
	$.addchild($.more)
	$.redbutt = new ktoggle("R",$,"redonoff")
	$.addchild($.redbutt)
	$.greenbutt = new ktoggle("G",$,"greenonoff")
	$.addchild($.greenbutt)
	$.bluebutt = new ktoggle("B",$,"blueonoff")
	$.addchild($.bluebutt)
	$.onoffbutt = new ktoggle("On",$,"onoff")
	$.addchild($.onoffbutt)
	$.joybutt = new ktoggle("Joy",$,"joyonoff")
	$.addchild($.joybutt)
	$.brakebutt = new kbutton("Brake",$,"brake")
	$.addchild($.brakebutt)

	$.slidermax = 1000
	$.decayslider = []
	for ( cl in $.colorindex ) {
		$.decayslider[cl] = new kslider(0,$.slidermax,
					$.slidermax/2,$,"changedecay")
		$.addchild($.decayslider[cl])
	}

	$.maxe =    1000000
	$.einc =      60000
	$.edec =      60000
	$.edecaymax =     4000
	$.edecay =     $.edecaymax / 2

	$.maxmove =  300
	$.key = 'c'
	$.scale = "aeolian"
	$.startquant = 1b
	$.playquant = 1b/4
	$.movesize = 1b/8
	$.movedlimit = []
	$.playlimit = 4
	$.incfactor = 1
	$.joy = $0
	$.freeze = []
	$.freezep = []
	for ( cl in $.colorindex ) {
		$.movedlimit[cl] = 12
		$.freeze[cl] = 0
		$.freezep[cl] = ''
	}
	$.tids = []
	$.redbutt.set(1)

	TrappedTool = $

	$.setgridsize(16,0)
}

method changedecay(v) {
	$.edecay = $.edecaymax * v / $.slidermax
}

method setgridsize(v,doredraw) {
	$.nrows = v
	$.ncols = v
	if ( $.grid != $0 ) {
		$.removechild($.grid)
	}
	deleteobject($.grid)
	$.grid = new wgrid($.ncols,$.nrows)
	$.addchild($.grid)

	$.grid.setcallbackdown($,"gotdown")
	$.grid.setcallbackup($,"gotup")
	$.grid.setcallbackdrag($,"gotdrag")
	$.initballs()
	$.randballs()
	$.setscale($.key,$.scale)

	if ( doredraw ) {
		$.resize()
		$.redraw()
	}
}

method randballs {
	tot = 5
	for ( r=0; r<$.nrows; r++ ) {
		for ( c=0; c<$.ncols; c++ ) {
			v = rand(tot)
			$.balldx[r][c] = 1+ v
			$.balldy[r][c] = 1 + tot - v
		}
	}
}
method initballs {
	lock($)
	$.ballx = []
	$.bally = []
	$.balldx = []
	$.balldy = []
	$.ballcolor = []
	$.energy = []
	$.sideup = []
	$.sidedown = []
	$.sideleft = []
	$.sideright = []

	$.moved = []
	$.movedsize = []
	$.movednext = []
	for ( cl in $.colorindex ) {
		$.moved[cl] = []
		$.movedsize[cl] = 0
		$.movednext[cl] = 0
	}

	for ( r=0; r<$.nrows; r++ ) {
		$.ballx[r] = []
		$.bally[r] = []
		$.balldx[r] = []
		$.balldy[r] = []
		$.ballcolor[r] = []
		$.energy[r] = []
		$.sideup[r] = []
		$.sidedown[r] = []
		$.sideleft[r] = []
		$.sideright[r] = []
		for ( c=0; c<$.ncols; c++ ) {
			$.ballx[r][c] = $.ballgridsize/2
			$.bally[r][c] = $.ballgridsize/2
			$.balldx[r][c] = 0
			$.balldy[r][c] = 0
			$.ballcolor[r][c] = 0
			$.energy[r][c] = 0
			$.sideup[r][c] = ''
			$.sidedown[r][c] = ''
			$.sideleft[r][c] = ''
			$.sideright[r][c] = ''
		}
	}
	unlock($)
}
method ballxy(arr,bx,by) {
	x0 = arr["x0"]
	y0 = arr["y0"]
	x1 = arr["x1"]
	y1 = arr["y1"]
	bx0 = x0 + 1 + (x1-x0-2)*bx/$.ballgridsize
	by0 = y0 + 1 + (y1-y0-2)*by/$.ballgridsize
	return( xy(bx0-1,by0-1,bx0+1,by0+1) )
}
method playit(p,cl) {
	if ( typeof(p) != "phrase") {
		print("Hey, playit given non-phrase?")
		return()
	}
	p.chan = $.colorchan[cl]
	tm = nextquant(Now,$.playquant)
	f = $.freeze[cl]
	if ( f == 1 ) {
		for ( t in $.tids )
			kill(t)
		$.tids = []
		p.type = NOTEON
		realtime(p,tm)
		$.freeze[cl] = 2
		$.freezep[cl] = p
	} else if ( f == 2 ) { 
		# do nothing, wait for freeze == 3
	} else if ( f == 3 ) { 
		p = $.freezep[cl]
		p.type = NOTEOFF
		realtime(p,tm)
		$.freezep[cl] = ''
		$.freeze[cl] = 0
	} else {
		t = realtime(p,tm)
		$.tids[t] = 1
	}
}
method hitleft(r,c) {
	$.playit($.sideleft[r][c],$.ballcolor[r][c])
}
method hitright(r,c) {
	$.playit($.sideright[r][c],$.ballcolor[r][c])
}
method hitup(r,c) {
	$.playit($.sideup[r][c],$.ballcolor[r][c])
}
method hitdown(r,c) {
	$.playit($.sidedown[r][c],$.ballcolor[r][c])
}
method moveballs {
	lock($)
	for ( r=0; r<$.nrows; r++ ) {
		for ( c=0; c<$.ncols; c++ ) {
			ch = $.ballcolor[r][c]
			fr = $.freeze[ch]
			if ( fr == 2 )
				continue
			m = $.energy[r][c]
			if ( m > 0 ) {
				m -= $.edecay
				if ( m < 0 )
					m = 0
				$.energy[r][c] = m
			}

			mv = ( m * $.maxmove ) / $.maxe

			dx = $.balldx[r][c] * mv
			dy = $.balldy[r][c] * mv
			bx = $.ballx[r][c]
			by = $.bally[r][c]
			cellxy = $.grid.getcellxy(r,c)
			origarr = $.ballxy(cellxy,bx,by)
			if ( dx==0 && dy==0 ) {
				# Erase it
				$.w.fillrectangle(origarr,CLEAR)
				continue
			}
			x = bx + dx
			if ( x < 0 ) {
				$.hitleft(r,c)
				x = -x
				if ( x > $.ballgridsize )
					x = $.ballgridsize
				$.balldx[r][c] = -$.balldx[r][c]
			} else if ( x > $.ballgridsize ) {
				$.hitright(r,c)
				x = $.ballgridsize - (x-$.ballgridsize)
				if ( x < 0 )
					x = 0
				$.balldx[r][c] = -$.balldx[r][c]
			}
			y = by + dy
			if ( y < 0 ) {
				$.hitup(r,c)
				y = -y
				if ( y > $.ballgridsize )
					y = $.ballgridsize
				$.balldy[r][c] = -$.balldy[r][c]
			} else if ( y > $.ballgridsize ) {
				$.hitdown(r,c)
				y = $.ballgridsize - (y-$.ballgridsize)
				if ( y < 0 )
					y = 0
				$.balldy[r][c] = -$.balldy[r][c]
			}
			newarr = $.ballxy(cellxy,x,y)
			$.w.fillrectangle(origarr,CLEAR)
			if ( $.energy[r][c] > 0 ) {
				colorset($.colorindex[$.ballcolor[r][c]])
				$.w.fillrectangle(newarr,STORE)
				colorset(1)
			}
			$.ballx[r][c] = x
			$.bally[r][c] = y
		}
	}
	unlock($)
}
method drawballs(mode) {
	if ( nargs() < 1 )
		mode = STORE
	for ( r=0; r<$.nrows; r++ ) {
		for ( c=0; c<$.ncols; c++ ) {
			if ( $.energy[r][c] > 0 ) {
				bx = $.ballx[r][c]
				by = $.bally[r][c]
				cellxy = $.grid.getcellxy(r,c)
				arr = $.ballxy(cellxy,bx,by)
				colorset($.colorindex[$.ballcolor[r][c]])
				$.w.fillrectangle(arr,mode)
				colorset(1)
			}
		}
	}
}
method ison {
	if ( $.tid >= 0 )
		return(1)
	else
		return(0)
}
method brake(v) {
	for ( r=0; r<$.nrows; r++ ) {
		for ( c=0; c<$.ncols; c++ ) {
			$.energy[r][c] = 0
		}
	}
}
method redonoff(v) {
	if ( v ) {
		$.currentcolor = "r"
		$.greenbutt.set(0) ; $.greenbutt.redraw()
		$.bluebutt.set(0) ; $.bluebutt.redraw()
	} else {
		$.redbutt.set(1) ; $.redbutt.redraw()
	}
}
method greenonoff(v) {
	if ( v ) {
		$.currentcolor = "g"
		$.redbutt.set(0) ; $.redbutt.redraw()
		$.bluebutt.set(0) ; $.bluebutt.redraw()
	} else {
		$.greenbutt.set(1) ; $.greenbutt.redraw()
	}
}
method blueonoff(v) {
	if ( v ) {
		$.currentcolor = "b"
		$.redbutt.set(0) ; $.redbutt.redraw()
		$.greenbutt.set(0) ; $.greenbutt.redraw()
	} else {
		$.bluebutt.set(1) ; $.bluebutt.redraw()
	}
}
method onoff(v) {
	if ( v ) {
		if ( $.tid >= 0 )
			kill($.tid)
		$.tid = task $.trappedtask()
	} else {
		kill($.tid)
		$.tid = -1
	}
}
method joyonoff(v) {
	if ( v ) {
		if ( $.joy != $0 )
			deleteobject($.joy)
		$.joy = getjoymonitor()
		$.joy.notify($)
	} else {
		if ( $.joy != $0 )
			deleteobject($.joy)
		$.joy = $0
	}
}
method buttonchange(jn,nm,v) {
	# print("method buttonchange called jn=",jn," nm=",nm," v=",v)
	if ( nm == "SQUARE" ) {
		realtime(patchrandom($.colorchan[$.currentcolor]))
	}
	if ( nm in $.butt2color ) {
		lock($)
		ch = $.butt2color[nm]
		if ( v == 1 ) {
			if ( $.freeze[ch] == 0 ) {
				$.freeze[ch] = 1
				$.freezep[ch] = ''
			}
		} else {
			$.freeze[ch] = 3
		}
		unlock($)
	}
}
method analogchange(jn,nm,v) {
	print("method analogchange called jn=",jn," nm=",nm," v=",v)
}
method trappedtask {
	# print("trappedtask start")
	tm = Now
	tm = nextquant(tm,$.startquant)
	while ( 1 ) {
		sleeptill(tm-2)
		$.moveballs()
		tm += $.movesize

# 		arr = $.popevent()
# 		if ( arr == 0 ) {
# 			tm += $.movesize
# 			continue
# 		}
# 		if ( typeof(arr) != "array" ) {
# 			print("Hey, arr=",arr)
# 			tm += $.movesize
# 			continue
# 		}
# 		t = arr["type"]
# 		if ( t == "note" ) {
# 			if ( "p" in arr ) {
# 				p = arr["p"]
# 				p.chan = $.ch
# 				realtime(p,tm)
# 				# print("realtime p=",p," tm=",tm," Now=",Now)
# 			} else {
# 				print("Hey, p not in arr")
# 			}
# 			if ( "time" in arr ) {
# 				tm += arr["time"]
# 			} else {
# 				print("Hey, time not in arr")
# 			}
# 		} else if ( t == "clear" ) {
# 			$.play_fromindex = 0
# 			$.play_toindex = 0
# 			$.play_arr = []
# 		}
	}
}
method delete {
	kill($.tid)
	TrappedTool = $0
}
method resize (sz) {
			if ( nargs() > 0 )
				$.w.resize(sz)
			$.dy = $.textheight() + 5
			tw = $.textwidth()

			ym2 = $.ymin() + 2

			dx = $.textwidth()*2
			$.x0a = $.xmin() + 2 + 3*dx
			$.decayslider["r"].resize(xy($.xmin()+2,$.ymin()+$.dy,
				$.xmin()+dx-1,$.ymax()-2))
			$.decayslider["g"].resize(xy($.xmin()+dx+1,$.ymin()+$.dy,
				$.xmin()+2*dx-1,$.ymax()-2))
			$.decayslider["b"].resize(xy($.xmin()+2*dx+1,$.ymin()+$.dy,
				$.xmin()+3*dx-1,$.ymax()-2))

			$.redbutt.resize(xy($.xmin()+2,ym2,
				$.xmin()+dx-1,$.ymin()+$.dy-2))
			$.greenbutt.resize(xy($.xmin()+dx+1,ym2,
				$.xmin()+2*dx-1,$.ymin()+$.dy-2))
			$.bluebutt.resize(xy($.xmin()+2*dx+1,ym2,
				$.xmin()+3*dx-1,$.ymin()+$.dy-2))

			$.gridxy = xy($.x0a+1,$.ymin()+$.dy,
					$.xmax()-3,$.ymax()-2)
			$.grid.resize($.gridxy)

			$.xm = ($.xmin()+$.xmax())/2
			if ( $.xm < ($.xmax()-28*tw) )
				$.xm = ($.xmax()-28*tw)

			$.xmdx = ($.xmax() - $.xm)/8


			$.onoffbutt.resize(xy($.xm+4*$.xmdx+1,ym2,
				$.xm+5*$.xmdx-1,$.ymin()+$.dy-2))
			$.brakebutt.resize(xy($.xm+5*$.xmdx+1,ym2,
				$.xm+6*$.xmdx-1,$.ymin()+$.dy-2))
			$.joybutt.resize(xy($.xm+6*$.xmdx+1,ym2,
				$.xm+7*$.xmdx-1,$.ymin()+$.dy-2))
			$.more.resize(xy($.xm+7*$.xmdx+1,ym2,
				$.xmax()-2,$.ymin()+$.dy-2))
		}
method redraw {
			$.w.redraw()
			$.w.text("Trapped Balls",xy($.xmin(),$.ymin(),
					$.xm,$.ymin()+$.dy))
			methodbroadcast()
			$.w.rectangle($.gridxy)
			$.drawballs()
		}
method gotdown (...) {
	$.gotdrag(...)
}
method gotup (m,ms) {
}
method notify(r,c,cl) {
	$.gotdrag(["row"=r,"col"=c],["button"=1],8,cl)
}
method gotdrag (m,ms,incfactor,cl) {
	if ( nargs() < 3 ) {
		incfactor = $.incfactor
	}
	if ( nargs() < 4 ) {
		cl = $.currentcolor
	}
	if ( ! $.ison() )
		return()
	r = m["row"]
	c = m["col"]
	if ( r >= $.nrows )
		return()
	if ( c >= $.ncols )
		return()

	lock($)

	e = $.energy[r][c]
	if ( ms["button"] == 1 )
		e += ($.einc*incfactor)
	else
		e -= $.edec
	if ( e < 0 )
		e = 0
	if ( e > $.maxe )
		e = $.maxe
	$.energy[r][c] = e
	$.ballcolor[r][c] = cl
	if ( $.movedlimit[cl] > 0 ) {
		# See if the current r,c is already in the list
		found = -1
		for ( a in $.moved[cl] ) {
			arr = $.moved[cl][a]
			if ( typeof(arr) != "array" ) {
				print("Hey, moved[a=",a,"] isn't an array?")
				$.moved = []
				return()
			}
			ac = arr["c"]
			ar = arr["r"]
			if ( ac == c && ar == r ) {
				found = a
			}
		}
		if ( found<0 ) {
			# Wasn't found, add it
			$.moved[cl][$.movednext[cl]] = ["c"=c,"r"=r]
			added = $.movednext[cl]
			$.movednext[cl]++
			$.movedsize[cl]++
			while ( $.movedsize[cl] > $.movedlimit[cl] ) {

				# Delete the one with the lowest number
				# But if it's not the one with least
				# energy, swap first

				leaste = $.maxe+1
				leaste_a = -1
				for ( a in $.moved[cl] ) {
					arr = $.moved[cl][a]
					if ( typeof(arr) != "array" ) {
						print("Hey, moved[a=",a,"] isn't an array?")
						continue
					}
					ac = arr["c"]
					ar = arr["r"]
					ae = $.energy[ar][ac]
					if ( ae < leaste && a != added ) {
						leaste = ae
						leaste_a = a
					}
				}

				di = $.movednext[cl] - $.movedsize[cl]
				if ( di != leaste_a ) {
					savearr = $.moved[cl][di]
					$.moved[cl][di] = $.moved[cl][leaste_a]
					$.moved[cl][leaste_a] = savearr
				}
				c2 = $.moved[cl][di]["c"]
				r2 = $.moved[cl][di]["r"]
				$.energy[r2][c2] = 0
				delete $.moved[cl][di]
				$.movedsize[cl]--
			}
		}
	}

	unlock($)

}

method setplayquant(v) {
	$.playquant = v
}

method setmovinglimit(v) {
	$.movedlimit[$.currentcolor] = v
}
method setincfactor(v) {
	$.incfactor = v
}

method setmovesize(n) {
	$.onoff(0)
	$.movesize = n
	$.onoff(1)
}
method setscale(k,s) {
	sc = completescale(k,s)
	arr = splitonstarts(sc,0,1)
	$.setfromarr(arr,1)
}
method readfile(nstarts) {
	fname = browsefiles("MIDI File (*.MID)","*.mid",0)
	if ( fname == "" ) {
		print("No file specified")
		return()
	}
	p = onlynotes(readmf(fname))
	arr = splitonstarts(p,0,nstarts)
	$.setfromarr(arr,1)
}

method setfromarr(arr,exactfit) {

	lock($)
	for ( i in arr )
		arr[i].time = 0
	if ( exactfit ) {
		ai = 0
		tot = $.ncols * $.nrows * 4
		sofar = 0
		arrsz = sizeof(arr)
		for ( r=0; r<$.nrows; r++ ) {
			for ( c=0; c<$.ncols; c++ ) {
				d = arrsz * sofar++ / tot
				$.sideup[r][c] = arr[d]

				d = arrsz * sofar++ / tot
				$.sidedown[r][c] = arr[d]

				d = arrsz * sofar++ / tot
				$.sideleft[r][c] = arr[d]

				d = arrsz * sofar++ / tot
				$.sideright[r][c] = arr[d]
			}
		}
	} else {
		# This version uses each item once, and restarts
		# from the beginning when it runs out
		ai = 0
		for ( r=0; r<$.nrows; r++ ) {
			for ( c=0; c<$.ncols; c++ ) {
				if ( ! ( ai in arr ) )
					ai = 0
				p = arr[ai++]
				$.sideup[r][c] = p
				if ( ! ( ai in arr ) )
					ai = 0
				p = arr[ai++]
				$.sidedown[r][c] = p
				if ( ! ( ai in arr ) )
					ai = 0
				p = arr[ai++]
				$.sideleft[r][c] = p
				if ( ! ( ai in arr ) )
					ai = 0
				p = arr[ai++]
				$.sideright[r][c] = p
			}
		}
	}
	unlock($)
}
method setchan(c) {
	$.ch = c
}
}

function mkmenu_trapped1(o,po) {
	o.submenu("Grid Size   ->","mkmenu_trappedgridsize",po)
	o.submenu("Channel     ->","mkmenu_trappedchan",po)
	o.submenu("From Scale  ->","mkmenu_trappedkey",po)
	o.submenu("Move Freq   ->","mkmenu_trappedsize",po)
	o.submenu("Play Quant  ->","mkmenu_trappedplayquant",po)
	o.submenu("Moving Limit->","mkmenu_trappedmoving",po)
	o.submenu("Mouse Energy->","mkmenu_trappedincfactor",po)
	o.menucmd("From File",po,"readfile",1)
}
function mkmenu_trappedchan(o,po) {
	for ( c=1; c<=16; c++ ) {
		o.menucmd(string(c),po,"setchan",c)
	}
}
function mkmenu_trappedkey(o,po) {
	o.submenu("C","mkmenu_trappedscale",po,'c')
	o.submenu("C#","mkmenu_trappedscale",po,'c+')
	o.submenu("D","mkmenu_trappedscale",po,'d')
	o.submenu("D#","mkmenu_trappedscale",po,'d+')
	o.submenu("E","mkmenu_trappedscale",po,'e')
	o.submenu("F","mkmenu_trappedscale",po,'f')
	o.submenu("F#","mkmenu_trappedscale",po,'f+')
	o.submenu("G","mkmenu_trappedscale",po,'g')
	o.submenu("G#","mkmenu_trappedscale",po,'g+')
	o.submenu("A","mkmenu_trappedscale",po,'a')
	o.submenu("A#","mkmenu_trappedscale",po,'a+')
	o.submenu("B","mkmenu_trappedscale",po,'b')
}
function mkmenu_trappedscale(o,po,k) {
	o.menucmd("Ionian",po,"setscale",k,"ionian")
	o.menucmd("Dorian",po,"setscale",k,"dorian")
	o.menucmd("Phrygian",po,"setscale",k,"phrygian")
	o.menucmd("Lydian",po,"setscale",k,"lydian")
	o.menucmd("Mixolydian",po,"setscale",k,"mixolydian")
	o.menucmd("Aeolian",po,"setscale",k,"aeolian")
	o.menucmd("Locrian",po,"setscale",k,"locrian")
	o.menucmd("Newage",po,"setscale",k,"newage")
	o.menucmd("Fifths",po,"setscale",k,"fifths")
}
function mkmenu_trappedincfactor(o,po) {
	o.menucmd("1",po,"setincfactor",1)
	o.menucmd("2",po,"setincfactor",2)
	o.menucmd("4",po,"setincfactor",4)
	o.menucmd("8",po,"setincfactor",8)
}
function mkmenu_trappedgridsize(o,po) {
	o.menucmd("4",po,"setgridsize",4,1)
	o.menucmd("8",po,"setgridsize",8,1)
	o.menucmd("16",po,"setgridsize",16,1)
}
function mkmenu_trappedmoving(o,po) {
	o.menucmd("1",po,"setmovinglimit",1)
	o.menucmd("2",po,"setmovinglimit",2)
	o.menucmd("4",po,"setmovinglimit",4)
	o.menucmd("8",po,"setmovinglimit",8)
	o.menucmd("12",po,"setmovinglimit",12)
	o.menucmd("16",po,"setmovinglimit",16)
	o.menucmd("32",po,"setmovinglimit",32)
	o.menucmd("64",po,"setmovinglimit",64)
}
function mkmenu_trappedsize(o,po) {
	o.menucmd("1b",po,"setmovesize",1b)
	o.menucmd("1b/2",po,"setmovesize",1b/2)
	o.menucmd("1b/4",po,"setmovesize",1b/4)
	o.menucmd("1b/8",po,"setmovesize",1b/8)
	o.menucmd("1b/16",po,"setmovesize",1b/16)
	o.menucmd("1b/32",po,"setmovesize",1b/32)
}
function mkmenu_trappedplayquant(o,po) {
	o.menucmd("2b",po,"setplayquant",2b)
	o.menucmd("1b",po,"setplayquant",1b)
	o.menucmd("1b/2",po,"setplayquant",1b/2)
	o.menucmd("1b/4",po,"setplayquant",1b/4)
	o.menucmd("1b/8",po,"setplayquant",1b/8)
	o.menucmd("1b/16",po,"setplayquant",1b/16)
	o.menucmd("1b/32",po,"setplayquant",1b/32)
}
