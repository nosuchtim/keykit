class wlife {
method init {
	$.w = new window()
	$.inherit($.w)
	$.localergo = 0
	$.playon = 0
	$.devplay = -1
	$.devkey = -1
	$.devletter = -1
	$.letters = [0="A",1="C",2="T",3="G"]
	$.letter2num = ["A"=0,"C"=1,"T"=2,"G"=3]
	$.ndown = 0
	$.scales = [
		0 = "octaves",
		1 = "fifths",
		2 = "newage",
		3 = "ionian",
		4 = "lydian",
		5 = "mixolydian",
		6 = "aeolian",
		7 = "dorian",
		8 = "harminor",
		9 = "melminor"
	]
	$.lowpitch = 36
	$.highpitch = 96

	GestureTool = $
	$.debug = 0

	$.pokecolor = 1
	$.playquant = 1b
	$.startquant = 1b/4
	$.running = 0
	$.nextplay = Now
	$.limit = 4
	$.gestureon = 1
	$.letterval = ["A" = 1, "C" = 2, "T" = 3, "G" = 4]
	$.erasedead = 1

	$.setspeed(1)	 # per second

	$.cf = (255*256.0) / 255.0
	$.preview = 1
	$.color2chan = ["r"=1,"g"=2,"b"=3]
	$.lifetype = 0
	$.morebutt = new kmenubutton("More","mkmenu_life1",$)

	$.textwidget = new ktext("Life with DNA")
	$.textwidget.style(NOBORDER)
	$.t0 = new kbutton("Stop",$,"stop")
	# $.montoggle = new ktoggle("Mon",$,"setmon")
	$.playtoggle = new ktoggle("Play",$,"setplay")
	$.textwidget2 = new ktext("C")
	$.textwidget3 = new ktext("newage")
	chans = []
	for ( n=1; n<=16; n++ )
		chans[n-1] = string(n)

	$.grid = []
	$.gridval = []
	$.gridphr = []
	$.locationof = []

	global bsriff
	$.rifffunc = bsriff

	$.addchild($.textwidget)
	$.addchild($.textwidget2)
	$.addchild($.textwidget3)
	$.addchild($.morebutt)
	# $.addchild($.montoggle)
	$.addchild($.playtoggle)

	$.looping = 0
	$.factor = 1.0
	$.stopme = 0
	$.gridrows = 0
	$.gridcols = 0
	$.montid = -1
	$.patch = 1

	$.maxval = 0
	$.setgridsize(32,32,0)

	# Default values of buttons

	a = mdep("gesture","devices")
	$.width = []
	$.height = []
	$.fing_down = []
	$.fing_wp = []
	$.fing_tm = []
	for ( dev in a ) {
		$.width[dev] = a[dev]["width"]
		$.height[dev] = a[dev]["height"]
		$.fing_wp[dev] = []
		$.fing_tm[dev] = []
	}
	$.colors = [
			0=["r"=255,"g"=0,"b"=0],
			1=["r"=0,"g"=255,"b"=0],
			2=["r"=0,"g"=0,"b"=255],
			3=["r"=255,"g"=255,"b"=0]
		]
	Midiin[$] = f = open()
	$.midiintid = task $.midiin_task(f)
	$.anotid = task $.ano_task(f)
}

method ano_task() {
	while (1) {
		sleeptill(Now+milliclicks(15*1000))
		realtime(ano())
	}
}
method midiin_task(f) {
	# Interpret notes coming from spd-6 pad
	while ( (m=get(f)) != Eof ) {
		if ( m.type == NOTEOFF )
			continue
		if ( m.type == NOTEON ) {
			# print("WLIFE MIDIIN = ",m)
			randit = (m.vol<60)
			if ( m.pitch == 'co1'.pitch ) {
				$.doletter("A",randit)
			} else if ( m.pitch == 'c+o2'.pitch ) {
				$.doletter("C",randit)
			} else if ( m.pitch == 'do1'.pitch ) {
				$.doletter("T",randit)
			} else if ( m.pitch == 'do2'.pitch ) {
				$.doletter("G",randit)

			} else if ( m.pitch == 'f+'.pitch ) {
				$.fleet("A")
			} else if ( m.pitch == 'eo4'.pitch ) {
				$.fleet("C")
			} else if ( m.pitch == 'f'.pitch ) {
				$.fleet("T")
			} else if ( m.pitch == 'fo4'.pitch ) {
				$.fleet("G")

			} else if ( m.pitch == 'f+o1'.pitch ) {
				$.pattern_init(1,0)	# CLEAR
				$.ano()
			} else if ( m.pitch == 'go1'.pitch ) {
				$.ano()
				$.togglerun()

			} else if ( m.pitch == 'a-o2'.pitch ) {
				$.pattern_init(1,0)	# CLEAR
			} else if ( m.pitch == 'go2'.pitch ) {
				$.togglerun()
			}
		}
	}
}
method togglerun {
	if ( $.running ) {
		print("Stopping ...")
		$.stop()		# STOP
	} else {
		print("Starting ...")
		task $.ngen(-1)		# GO
	}
}

method milli2clicks(m) {
	return ( m * 1b / (tempo()/1000.0) )
}

method ano() {
	print("Playing ano")
	realtime(ano())
}

method realtime(p,tm) {
	tid = realtime(p,tm)
	if ( $.localergo ) {
		for ( n in p ) {
			if ( n.type == NOTE ) {
				# print("NOTE n=",n)
				if ( defined(Ergo) && Ergo != $-1 ) {
					task Ergo.play(p)
				}
			} else if ( n.type == NOTEON ) {
				# print("NOTEON n=",n)
				if ( defined(Ergo) && Ergo != $-1 ) {
					task Ergo.play(p)
				}
			}
		}
	}
	return(tid)
}

method ngen(n) {

	if ( $.running )
		return()
	$.running = 1
	tm1 = milliclock()
	$.nextplay = Now+$.milli2clicks($.cyclemilli)
	i = 0
	while ( n<0 || i<n ) {
		if ( $.stopme ) {
			$.stopme = 0
			break
		}
		gt1 = milliclock()
		$.generate()
		gt2 = milliclock()
		if ( $.erasedead ) {
			$.redrawgrid(0,1)	# don't clear it, draw dead
		} else {
			$.redrawgrid(0,0)
		}
		sleeptill($.nextplay)
		$.nextplay += $.milli2clicks($.cyclemilli)

		i++
	}
	tm2 = milliclock()
	print("Stopped, ",i," generations in ",(tm2-tm1)/1000.0," seconds")
	$.running = 0
}

method generate {
	# lock($)
	grm1 = $.gridrows-1
	changes = []
	nchanges = 0
	for ( r = 0; r<$.gridrows; r++ ) {
		gcm1 = $.gridcols-1
		for ( c=0; c<$.gridcols; c++ ) {

			col2 = c
			if ( c == 0 ) {
				col1 = gcm1
				col3 = c+1
			} else if ( c == gcm1 ) {
				col1 = $.gridcols-2
				col3 = 0
			} else {
				col1 = c-1
				col3 = c+1
			}

			row2 = r
			if ( r == 0 ) {
				row1 = grm1
				row3 = r+1
			} else if ( r == grm1 ) {
				row1 = $.gridrows-2
				row3 = 0
			} else {
				row1 = r-1
				row3 = r+1
			}

			# c1-3 is top row
			# c7-9 is bottom row

			grow1 = $.gridval[row1]
			grow2 = $.gridval[row2]
			grow3 = $.gridval[row3]

			g11 = grow1[col1]
			g12 = grow1[col2]
			g13 = grow1[col3]

			g21 = grow2[col1]
			g22 = grow2[col2]
			g23 = grow2[col3]

			g31 = grow3[col1]
			g32 = grow3[col2]
			g33 = grow3[col3]

			c1 = (g11!=0)
			c2 = (g12!=0)
			c3 = (g13!=0)

			c4 = (g21!=0)
			c5 = (g22!=0)
			c6 = (g23!=0)

			c7 = (g31!=0)
			c8 = (g32!=0)
			c9 = (g33!=0)

			tot = c1+c2+c3+c4+c6+c7+c8+c9
			if ( c5 == 0 ) {
				if ( tot == 3 ) {
					# born
					tot = g11 + g12 + g13
						+ g21 + g23 
						+ g31 + g32 + g33
					avg = tot / 3.0
					if ( avg < 1 )
						avg = 1
					# avg = round(avg)
					#print("born r=",r," c=",c," tot=",tot," avg=",avg)
					changes[nchanges++]=["r"=r,"c"=c,"v"=avg]
				}
			} else {
				if ( tot < 2 || tot > 3 ) {
					# die
					changes[nchanges++]=["r"=r,"c"=c,"v"=0]
				}
			}
		}
	}
	result = ''
	for ( i in changes ) {
		ch = changes[i]
		r = ch["r"]
		c = ch["c"]
		v = ch["v"]
		$.set_cell_val(r,c,v)
		if ( v != 0 ) {
			ph = $.row_phr[r]
			if ( typeof(ph) != "phrase" ) {
				print("Hey, r=",r," ph=",ph," isn't a phrase?")
				continue
			}
			# ph = $.gridphr[r][c]
			ph.chan = $.gv2chan(v)
			if($.debug>1)print("   change rc=",r,c," v=",v," ph.pitch=",ph.pitch," chan=",ph.chan)
			result += ph
			rf = float(r) / ($.gridrows-1)
			cf = float(c) / ($.gridcols-1)
			if ( $.localergo ) {
				if ( defined(Ergo) && Ergo != $-1 ) {
					task Ergo.gridcell(rf,cf,v)
				}
			} else {
				toergo = midibytes(0xf0,1,r,c,v,0xf7)
				# print("r=",r," c=",c," toergo=",toergo)
				realtime(toergo)
			}
		}
	}
	if ( result != '' && $.playon != 0 ) {
		rsize = sizeof(result)
		result = result { rand(rsize) < $.limit }
		# result = head(result,$.limit)
		result.length = latest(result)
		clicksincycle = $.milli2clicks($.cyclemilli)
		result = scaleng(result,clicksincycle)
		# tm = prevquant(Now,$.playquant)
		tm = $.nextplay
		if ( $.startquant != 0 )
			tm = nextquant(tm,$.startquant)
		resultshort = result{??.dur < 4}
		result -= resultshort
		resultshort.dur = 4
		result |= resultshort

		p2 = result{rand(2)==0}
		result -= p2
		p2.dur = 1b/2
		result |= p2
		result = quantize(result,1b/4)

		$.realtime(result,tm)
		if ( $.debug ) print("Playing result=",result," tm=",tm," Now=",Now)
	}
	# unlock($)
}

method set_cell_val(r,c,v) {
	$.gridval[r][c] = v
}

method pattern_init(doredraw,patt) {
	if ( nargs() < 1 )
		doredraw = 1
	if ( nargs() < 2 )
		patt = 0
	lock($)
	for ( r = 0; r<$.gridrows; r++ ) {
		for ( c=0; c<$.gridcols; c++ ) {
			$.set_cell_val(r,c,0)
		}
	}
	if ( patt == 1 ) {
		$.glider_at(5,5,2)
	} else if ( patt == 2 ) {
		for ( r = 0; r<$.gridrows; r++ ) {
			for ( c=0; c<$.gridcols; c++ ) {
				if ( rand(6) == 0 ) {
					rv = 1+rand(4)
					$.set_cell_val(r,c,rv)
				}
			}
		}
	}
	unlock($)
	if ( doredraw )
		$.redraw()
}
method glider_at(r,c,v) {
	$.set_cell_val(r,c,v)
	$.set_cell_val(r,c+1,v)
	$.set_cell_val(r,c+2,v)
	$.set_cell_val(r+1,c+2,v)
	$.set_cell_val(r+2,c+1,v)
}
method drawgridcell(c) {
	p = c.get()
	if ( p.type == CONTROLLER ) {
		c.text("CTRL",c.size())
	} else {
		c.redraw()
	}
}

method delete {
	GestureTool = $0
	kill($.midiintid)
	kill($.anotid)
}

method setlimit (n) {
	$.limit = n
}
method doletter(ch,randit) {
	if ( randit ) {
		atleast = 8
		x0 = rand($.gridrows-atleast)
		x1 = rand($.gridrows-atleast)
		y0 = rand($.gridcols-atleast)
		y1 = rand($.gridcols-atleast)
		if ( x1 < x0 ) {
			t = x1
			x1 = x0
			x0 = t
		}
		if ( y1 < y0 ) {
			t = y1
			y1 = y0
			y0 = t
		}
		x1 += atleast
		y1 += atleast
	} else {
		x0 = 1*($.gridcols)/6.0
		y0 = 1*($.gridrows)/6.0
		x1 = 5*($.gridcols)/6.0
		y1 = 5*($.gridrows)/6.0
	}
	$.setletter(ch,x0,y0,x1,y1)
}
method setletter(ch,x0,y0,x1,y1) {
	if ( ch == "A" )
		$.drawA(x0,y0,x1,y1,$.letterval["A"])
	else if ( ch == "C" )
		$.drawC(x0,y0,x1,y1,$.letterval["C"])
	else if ( ch == "T" )
		$.drawT(x0,y0,x1,y1,$.letterval["T"])
	else if ( ch == "G" )
		$.drawG(x0,y0,x1,y1,$.letterval["G"])
	else {
		print("Can't draw letter: ",ch)
	}
}
method drawA(x0,y0,x1,y1,v) {
	x24 = x0 + round((x1-x0)/2.0)
	x14 = x0 + round(1*(x1-x0)/4.0)
	x34 = x0 + round(3*(x1-x0)/4.0)
	y24 = y0 + round((y1-y0)/2.0)
	$.drawline(x24,y0,x0,y1,v)
	$.drawline(x24,y0,x1,y1,v)
	$.drawline(x14,y24,x34,y24,v)
}
method drawC(x0,y0,x1,y1,v) {
	midx = x0 + (x1-x0)/2
	x16 = x0 + round(1*(x1-x0)/6.0)
	x26 = x0 + round(2*(x1-x0)/6.0)
	x46 = x0 + round(4*(x1-x0)/6.0)
	x56 = x0 + round(5*(x1-x0)/6.0)
	midy = y0 + (y1-y0)/2
	y16 = y0 + round(1*(y1-y0)/6.0)
	y26 = y0 + round(2*(y1-y0)/6.0)
	y56 = y0 + round(5*(y1-y0)/6.0)
	$.drawline(x56,y0,x1,y16,v)
	$.drawline(x16,y0,x56,y0,v)
	$.drawline(x0,y16,x16,y0,v)
	$.drawline(x0,y16,x0,y56,v)
	$.drawline(x0,y56,x16,y1,v)
	$.drawline(x16,y1,x56,y1,v)
	$.drawline(x56,y1,x1,y56,v)
}
method drawT(x0,y0,x1,y1,v) {
	midx = x0 + (x1-x0)/2
	$.drawline(x0,y0,x1,y0,v)
	$.drawline(midx,y0,midx,y1,v)
}
method drawG(x0,y0,x1,y1,v) {
	midx = x0 + (x1-x0)/2
	x16 = x0 + round(1*(x1-x0)/6.0)
	x26 = x0 + round(2*(x1-x0)/6.0)
	x36 = x0 + round(3*(x1-x0)/6.0)
	x46 = x0 + round(4*(x1-x0)/6.0)
	x56 = x0 + round(5*(x1-x0)/6.0)
	midy = y0 + (y1-y0)/2
	y16 = y0 + round(1*(y1-y0)/6.0)
	y26 = y0 + round(2*(y1-y0)/6.0)
	y36 = y0 + round(3*(y1-y0)/6.0)
	y56 = y0 + round(5*(y1-y0)/6.0)
	$.drawline(x56,y0,x1,y16,v)
	$.drawline(x16,y0,x56,y0,v)
	$.drawline(x0,y16,x16,y0,v)
	$.drawline(x0,y16,x0,y56,v)
	$.drawline(x0,y56,x16,y1,v)
	$.drawline(x16,y1,x56,y1,v)
	$.drawline(x56,y1,x1,y56,v)
	$.drawline(x1,y56,x1,y36,v)
	$.drawline(x36,y36,x1,y36,v)
}
method outofbounds(r,c) {
	if ( r < 0 || r >= $.gridrows || c < 0 ||  c >= $.gridcols )
		return(1)
	return(0)
}
method drawline(c0,r0,c1,r1,v) {
	# Silly but quick
	# print("drawline c0=",c0," r0=",r0," c1=",c1," r1=",r1)
	c0 = round(c0)
	c1 = round(c1)
	r0 = round(r0)
	r1 = round(r1)
	if ( $.outofbounds(r0,c0) && $.outofbounds(r1,c1) )
		return()
	dr = abs(r1-r0)
	dc = abs(c1-c0)
	npoints = dc
	if ( dr > dc )
		npoints = dr
	npoints++
	for (n=0; n<npoints; n++) {
		if ( (npoints-1) == 0 )
			f = 0.0
		else
			f = n/float(npoints-1)
		r = r0 + round(f * (r1-r0))
		c = c0 + round(f * (c1-c0))
		# print("f=",f," r=",r," c=",c)
		if ( $.outofbounds(r,c) )
			continue
		$.set_cell_val(r,c,v)
		$.drawcell(r,c)
	}
}
method setspeed (n) {
	$.cyclemilli = integer(1000 / n)
	$.nextplay -= $.milli2clicks($.cyclemilli)
	# print("setspeed, milli2clicks of 1000 is ",$.milli2clicks(1000))
}
method setcolor (n) {
	$.pokecolor = n
}
method setplay (v) {
	$.playon = v
}
method setfactor(f) {
	$.factor = f
	$.set($.get(),1)
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
			tm2 = tm1 + segsize
			p = cut(mf,CUT_TIME,tm1,tm2)
			p.time -= tm1
			p.length = segsize
			# $.setgrid(w,p)
			tm1 = tm2
		}
	}
}
method setscale(k,s,nstarts) {
	keytext = [
		0="C",
		1="C#",
		2="D",
		3="D#",
		4="E",
		5="F",
		6="F#",
		7="G",
		8="G#",
		9="A",
		10="A#",
		11="B"
		]
	ks = keytext[canonic(k)]

	$.textwidget2.set(ks)
	$.textwidget3.set(string(s))
	$.textwidget2.redraw()
	$.textwidget3.redraw()
	if ( nargs() < 3 )
		nstarts = 1
	sc = completescale(k,s)
	sc = sc{??.pitch>$.lowpitch && ??.pitch<$.highpitch}
	sc = step(sc,$.playquant)
	arr = splitonstarts(sc,0,nstarts)
	# print("setscale k=",k," s=",s)
	$.setfromarr(arr,1)
	$.setrowphr(sc)
}
method setrowphr(scl) {
	$.row_phr = []
	nnotes = sizeof(scl)
	for ( r=0; r<$.gridrows; r++ ) {
		p = scl % ((nnotes * r) / $.gridrows )
		p.time -= p%1.time
		p.dur = $.playquant
		p.length = $.playquant
		# reverse index so low notes are at the bottom
		$.row_phr[$.gridrows-1-r] = p
	}
}
method readfile(nstarts) {
	fname = browsefiles("MIDI File (*.MID)","*.mid",0)
	if ( fname == "" ) {
		print("No file specified")
		return()
	}
	$.setfromfile(fname,nstarts)
}
method setfromfile(fname,nstarts) {
	$.setfromphrase(readmf(fname),nstarts)
}
method setfromsnarf(nstarts) {
	$.setfromphrase(Snarf,nstarts)
}
method setfromphrase(p,nstarts) {
	p = onlynotes(p)
	if ( sizeof(p) == 0 ) {
		print("No notes in phrase!?")
		return()
	}
	arr = splitonstarts(p,0,nstarts)
	$.setfromarr(arr,1)
}

method setfromarr(arr,exactfit) {

	lock($)
	for ( i in arr ) {
		tm1 = arr[i]%1.time
		arr[i].time -= tm1
	}
	# This version uses each item once, and restarts
	# from the beginning when it runs out
	ai = 0
	for ( r=0; r<$.gridrows; r++ ) {
		for ( c=0; c<$.gridcols; c++ ) {
			if ( ! ( ai in arr ) )
				ai = 0
			p = arr[ai++]
			$.gridphr[r][c] = p
		}
	}
	unlock($)
}
method setlifetype(v) {
	$.lifetype = v
}
method setpreview(v) {
	$.preview = v
}
method seterase(v) {
	$.erasedead = v
}
method setgrid(w,p) {
	w.set(p)
	w.dozoomout(1,"xy")
	w.redraw()
	$.drawgridcell(w)
}

method pokeat(r,c) {
	if ( $.gridval[r][c] == 0 ) {
		$.set_cell_val(r,c,$.pokecolor)
		$.drawcell(r,c)
	}
}
method mousedown (m) {
	loc = $.findgrid(m)
	if ( sizeof(loc) != 0 ) {
		$.pokeat(loc["r"],loc["c"])
	} else {
		mouseforward(m,"mousedown")
	}
}
method mousedrag (m) {
	loc = $.findgrid(m)
	if ( sizeof(loc) != 0 ) {
		$.pokeat(loc["r"],loc["c"])
	} else {
		mouseforward(m,"mousedrag")
	}
}
method dump {
	s = []
	s["gridrows"] = $.gridrows
	s["gridcols"] = $.gridcols
	return ( s )
}
method restore (s) { 
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
			$.gridval[r][c] = 0
			$.gridphr[r][c] = ''
		}
	}

	# Add new rows
	for ( r=$.gridrows; r<rneeded; r++ ) {
		$.gridval[r] = []
		$.gridphr[r] = []
		for ( c=0; c<cneeded; c++ ) {
			$.gridval[r][c] = 0
			$.gridphr[r][c] = ''
		}
	}

	$.gridrows = rneeded
	$.gridcols = cneeded
	if ( $.gestureon ) {
		gestureclear()
		gesturenotifyrc($,$.gridrows,$.gridcols)
	}
	if ( doredraw ) {
		$.resize()
		$.redraw()
	}
	$.setmax(255)

	$.mm = new mmatrix($.gridrows,$.gridcols,makenote(0),makenote(127),
		scale_fifths())

	unlock($)

	$.pattern_init(0)	# don't redraw
	$.setscale('c',"newage")
	if ( ! $.localergo ) {
		realtime(midibytes(0xf0,0,$.gridrows,$.gridcols,0xf7))
	}
}

method setmax(mx) {
	$.maxval = mx
}

method stop {
	$.stopme = 1
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	tw = $.textwidth()
	th = $.textheight()
	$.y0 = $.ymin()+2
	$.y0a = $.ymin() + th + 4
	$.x0 = $.xmin() + 2

	$.x1 = $.xmax() - 2
	$.y1 = $.ymax() - 1

	dx = ($.x1-$.x0) / 10

	layout_horizontal(
		xy($.x0,$.y0,$.x1,$.y0a),
		$.textwidget,
		# $.montoggle,
		$.morebutt,
		$.playtoggle,
		$.textwidget2,
		$.textwidget3)

}

method redraw() {
	$.w.redraw()
	for ( c in $.children() ) {
		c.redraw()
	}
	$.redrawgrid(0,0)	# already erased, so don't clear, and don't draw dead
}

method redrawgrid(clearit,drawdead) {
	y0 = $.y0a+2

	if ( clearit ) {
		$.w.fillrectangle(xy($.x0,y0,$.x1,$.y1),CLEAR)
	}
	for ( r=0; r<$.gridrows; r++ ) {
		gy0 = y0 + r * ($.y1-y0)/($.gridrows)
		gy1 = y0 + (r+1) * ($.y1-y0)/($.gridrows)
		for ( c=0; c<$.gridcols; c++ ) {
			gx0 = $.x0 + c * ($.x1-$.x0)/($.gridcols)
			gx1 = $.x0 + (c+1) * ($.x1-$.x0)/($.gridcols)
			arr = xy(gx0+1,gy0+1,gx1-1,gy1-1)
			$.drawcellarr(r,c,arr,drawdead)
		}
	}
	colorset(1)
}

method drawline_row(r,mode) {
	y0 = $.y0a+2
	gy0 = y0 + r * ($.y1-y0)/($.gridrows)
	gy1 = y0 + (r+1) * ($.y1-y0)/($.gridrows)
	gymid = ( gy0 + gy1 ) / 2
	arr = xy($.x0+1,gymid,$.x1-1,gymid)
	colorset(1)
	$.w.line(arr,mode)
}
method drawline_col(c,mode) {
	# print("drawline_col(c=",c," mode=",mode,")")
	y0 = $.y0a+2
	x0 = $.x0
	gxmid = $.x0 + (c+0.5) * ($.x1-$.x0)/($.gridcols)
	arr = xy(gxmid,y0,gxmid,$.y1)
	colorset(1)
	$.w.line(arr,mode)
}
method drawcell(r,c) {
	y0 = $.y0a+2
	gy0 = y0 + r * ($.y1-y0)/($.gridrows)
	gy1 = y0 + (r+1) * ($.y1-y0)/($.gridrows)
	gx0 = $.x0 + c * ($.x1-$.x0)/($.gridcols)
	gx1 = $.x0 + (c+1) * ($.x1-$.x0)/($.gridcols)
	arr = xy(gx0+1,gy0+1,gx1-1,gy1-1)
	$.drawcellarr(r,c,arr)
	colorset(1)
}

# Colors:
#  1          1.5         2.0       2.5         3.0       3.5       4.0
#   red      orange     yellow   yel-gr       green      aqua       blue

method drawcellarr(r,c,arr,drawdead) {
	if ( nargs() < 4 )
		drawdead = 0
	gv = $.gridval[r][c]
	ch = $.gv2chan(gv)
	if ( ch == 0 ) {
		if ( drawdead ) {
			$.w.fillrectangle(arr,CLEAR)
		}
	}
	else if ( ch == 1 ) {
		colormix(5,255*$.cf,0,0)		# red
		colorset(5)
		$.w.fillrectangle(arr,STORE)
	} else if ( ch == 2 ) {
		colormix(6,255*$.cf,175*$.cf,0)		# orange
		colorset(6)
		$.w.fillrectangle(arr,STORE)
	} else if ( ch == 3 ) {
		colormix(7,255*$.cf,255*$.cf,0)		# yellow
		colorset(7)
		$.w.fillrectangle(arr,STORE)
	} else if ( ch == 4 ) {
		colormix(8,150*$.cf,255*$.cf,0)		# yellow-green
		colorset(8)
		$.w.fillrectangle(arr,STORE)
	} else if ( ch == 5 ) {
		colormix(9,0,170*$.cf,0)		# green
		colorset(9)
		$.w.fillrectangle(arr,STORE)
	} else if ( ch == 6 ) {
		colormix(10,0,255*$.cf,180*$.cf)	# aqua
		colorset(10)
		$.w.fillrectangle(arr,STORE)
	} else if ( ch == 7 ) {
		colormix(11,0,0,255*$.cf)		# blue
		colorset(11)
		$.w.fillrectangle(arr,STORE)
	} else {
		print("Unexpected value r=",r," c=",c," gv=",gv)
	}
}

method findgrid(m) {
	x = m["x"]
	y = m["y"]
	gx0 = $.x0
	if ( $.gridcols == 0 || $.gridrows == 0 )
		return()

	gy0 = $.y0a+2
	gy1 = gy0

	dx = ($.x1-$.x0)/$.gridcols
	dy = ($.y1-gy0)/$.gridrows

	if ( y < gy0 || x < gx0 )
		return([])

	for ( r=0; r<$.gridrows; r++ ) {
		gx0 = $.x0
		gx1 = $.x0
		if ( r == ($.gridrows-1) )
			gy1 = $.y1 
		else
			gy1 += dy
		if ( y > gy1 )
			continue
		for ( c=0; c<$.gridcols; c++ ) {
			if ( c == ($.gridcols-1) )
				gx1 = $.x1 
			else
				gx1 += dx
			if ( x < gx1 )
				return(["r"=r,"c"=c])
			gx0 = gx1
		}
		gy0 = gy1
	}
	return([])
}

method toggledebug() {
	$.debug = 1 - $.debug
	print("debug=",$.debug)
}
method play_column(f,r,c) {
	$.drawline_col(c,STORE)
	p = $.column_phrase(c)
	if ( r >= 0 && r < (2*$.gridrows/8) ) {
		p.time = 0
		p.type = NOTEON
	} else if ( r < (3*$.gridrows/8) ) {
		p = arpeggio(step(p,1b/8))
	} else if ( r < (4*$.gridrows/8) ) {
		p = arpeggio(step(p,1b/4))
	} else if ( r < (5*$.gridrows/8) ) {
		p = arpeggio(step(p,1b/4))
	} else if ( r < (6*$.gridrows/8) ) {
		p = arpeggio(step(p,1b/2))
	} else if ( r < (7*$.gridrows/8) ) {
		p = arpeggio(step(p,1b/2))
	} else {
		p = arpeggio(step(p,1b))
	}
	if ( p.time != 0 ) {
		p = repeat(p,8)
		p = p{rand(3)==0}
	}
	if ( $.startquant != 0 ) {
		tm = nextquant(Now,$.startquant)
	} else {
		tm = Now
	}
	t = $.realtime(p,tm)
	if ( $.debug ) print("Playing column=",p," tm=",tm)

	$.fing_down[f] = ["r"=r,"c"=c,"phr"=p,"tid"=t]
	if ( $.debug && p != '' ) print("playing column c=",c," p=",p)
}
method unplay_column(f,r,c) {
	$.drawline_col(c,CLEAR)
	if ( ! (f in $.fing_down) ) {
		print("unplay, f=",f," not in fing_down?")
		return()
	}
	# print("unplay_column, fing_down=",$.fing_down[f])
	p = $.fing_down[f]["phr"]
	t = $.fing_down[f]["tid"]
	kill(t)
	if ( p.type == NOTEON ) {
		p.type = NOTEOFF
		$.realtime(p,Now)
		if ($.debug) print("Playing NOTEOFFs, p=",p," tm=",Now)
	}
	delete $.fing_down[f]
}
method poke_key(f,r,c) {
	$.fing_down[f] = ["r"=r,"c"=c,"type"="key"]
	key = integer(12 * c/($.gridcols-1))
	map = [0=0,1=0,2=0,3=3,4=3,5=5,6=5,7=7,8=7,9=7,10=10,11=10,12=0]
	key = map[key]
	$.key = makenote(key)

	nsc = sizeof($.scales)
	# reverse r so 0 is at bottom
	r = $.gridrows - 1 - r
	sc = integer((nsc-1) * r/($.gridrows-1))
	s = $.scales[sc]
	$.setscale($.key,s)
}
method unpoke_key(f,r,c) {
	delete $.fing_down[f]
}
method nlettersdown {
	n = 0
	for ( f in $.fing_down ) {
		ff = $.fing_down[f]
		if ( ("type" in ff) && ff["type"] == "letter" )
			n++
	}
	return(n)
}
method poke_letter(f,r,c) {
	$.fing_down[f] = ["r"=r,"c"=c,"type"="letter"]
	n = $.nlettersdown()
	if ( n > $.ndown )
		$.ndown = n
}
method dopokeletter(r,c,ndown) {
	c13 = $.gridcols / 3
	c23 = 2*$.gridcols / 3
	r12 = $.gridrows / 2

	r15 = $.gridrows / 5
	r25 = 2*$.gridrows / 5
	r35 = 3*$.gridrows / 5
	r45 = 4*$.gridrows / 5
	$.letter = -1
	if ( c < c13 && r < r12 ) {
		$.letter = 0
	} else if ( c < c13 && r >= r12 ) {
		$.letter = 1
	} else if ( c >= c13 && c <= c23 && r < r12 ) {
		$.letter = 2
	} else if ( c >= c13 && c <= c23 && r >= r12 ) {
		$.letter = 3
	} else if ( c > c23 ) {
		if ( r < r15 ) {
			$.ngen(-1)		# GO
		} else if ( r < r25 ) {
			$.stop()		# STOP
		} else if ( r < r35 ) {
			$.pattern_init(1,0)	# CLEAR
		} else if ( r < r45 ) {
			$.playon = 1 - $.playon # PLAY
			$.playtoggle.set($.playon)
			$.playtoggle.redraw()
		} else {
			$.ano()			# ANO
			# $.erasedead = 1 - $.erasedead	# ERASEDEAD
			# print("ERASEDEAD = ",$.erasedead)
		}
	}
	if ( $.letter >= 0 ) {
		# print("LETTER=",$.letter)
		if ( ndown >= 3 ) {
			$.fleet($.letter)
		} else {
			$.doletter($.letters[$.letter],ndown==2)
		}
	}
}
method fleet(letter) {
	# $.pattern_init(1,0)	# CLEAR
	letternum = $.letter2num[letter]
	for ( n=0; n<1; n++ ) {
		gr = rand($.gridrows-3)
		gc = rand($.gridcols-3)
		$.glider_at(gr,gc,letternum+1)
		$.redrawgrid(0,0)
	}
}
method unpoke_letter(f,r,c) {
	if ( $.nlettersdown() == 1 ) {
		# print("LAST FINGER UP, r,c=",r,c,"  ndown=",$.ndown)

		$.dopokeletter(r,c,$.ndown)

		$.ndown = 0
	}
	delete $.fing_down[f]
}
method gotgesturerc(t,dev,finger,r,c,prox) {

	# print("Got t=",t," dev=",dev," fing=",finger)
	if ( $.devplay < 0 ) {
		$.devplay = dev
		print("DEVPLAY = ",dev)
	} else if ( $.devkey < 0 && dev != $.devplay ) {
		$.devkey = dev
		print("DEVKEY  dev=",dev," devplay=",$.devplay," devkey=",$.devkey)
	} else if ( $.devletter < 0 && dev != $.devplay && dev != $.devkey ) {
		$.devletter = dev
		print("DEVLETTER = ",dev)
	}
	# print("gotgesturerc t=",t," dev=",dev," finger=",finger," rc=",r,c," prox=",prox)

	# reverse the row value
	r = $.gridrows - r - 1

	f = dev * 100 + finger

	if ( t == "fingerdrag" ) {

		if($.debug)print("fingerdrag! t=",t," dev=",dev," finger=",finger," rc=",r,c)
		if ( f in $.fing_down ) {
			oldr = $.fing_down[f]["r"]
			oldc = $.fing_down[f]["c"]
			if ( c != oldc ) {
				if ( dev == $.devplay ) {
					$.unplay_column(f,r,oldc)
					$.play_column(f,r,c)
				} else if ( dev == $.devkey ) {
					$.unpoke_key(f,r,c)
					$.poke_key(f,r,c)
				} else if ( dev == $.devletter ) {
					$.unpoke_letter(f,r,c)
					$.poke_letter(f,r,c)
				}
			}
		} else {
			print("Hmm, drag of f=",f," not in fing_down!?")
			return()
		}
	} else if ( t == "fingerup" ) {
		if ( ! ( f in $.fing_down ) ) {
			print("Hmm, up of f=",f," not in fing_down!?")
			return()
		}
		oldr = $.fing_down[f]["r"]
		oldc = $.fing_down[f]["c"]
		if ( dev == $.devplay ) {
			$.unplay_column(f,r,oldc)
		} else if ( dev == $.devkey ) {
			$.unpoke_key(f,r,c)
		} else if ( dev == $.devletter ) {
			$.unpoke_letter(f,r,c)
		}

	} else if ( t == "fingerdown" ) {

		if ( dev == $.devplay ) {
			$.play_column(f,r,c)
		} else if ( dev == $.devkey ) {
			$.poke_key(f,r,c)
		} else if ( dev == $.devletter ) {
			$.poke_letter(f,r,c)
		}

	} else {
		print("Unexpected t=",t," in gotgesturerc")
	}
	# print("end got")
}

method gv2chan(gv) {
	if ( gv < 1 ) {
		ch = 0
	} else if ( gv >= 1 && gv < 1.33 ) {
		ch = 1
	} else if ( gv >= 1.33 && gv < 1.66 ) {
		ch = 2
	} else if ( gv >= 1.66 && gv < 2.33 ) {
		ch = 3
	} else if ( gv >= 2.33 && gv <= 2.66 ) {
		ch = 4
	} else if ( gv >= 2.66 && gv <= 3.33 ) {
		ch = 5
	} else if ( gv >= 3.33 && gv < 3.66 ) {
		ch = 6
	} else if ( gv >= 3.66 && gv <= 4.0 ) {
		ch = 7
	} else {
		ch = 8
	}
	return(ch)
}

method column_phrase(c) {
	result = ''
	for ( r=0; r<$.gridrows; r++ ) {
		gv = $.gridval[r][c]
		if ( gv != 0 ) {
			p = $.row_phr[r]
			ch = $.gv2chan(gv)
			p.chan = ch
			result |= p
		}
	}
	return(result)
}
}

function mkmenu_lifepreview(o,po) {
	o.menucmd("On",po,"setpreview",1)
	o.menucmd("Off",po,"setpreview",0)
}
function mkmenu_lifeerase(o,po) {
	o.menucmd("On",po,"seterase",1)
	o.menucmd("Off",po,"seterase",0)
}
function mkmenu_lifetype(o,po) {
	o.menucmd("Real Color",po,"setlifetype",0)
	o.menucmd("Threshold Color",po,"setlifetype",1)
}
function mkmenu_lifesize(o,po) {
	o.menucmd("16x16",po,"setgridsize",16,16,1)
	o.menucmd("32x32",po,"setgridsize",32,32,1)
	o.menucmd("64x64",po,"setgridsize",64,64,1)
	o.menucmd("128x128",po,"setgridsize",128,128,1)
	o.menucmd("256x256",po,"setgridsize",256,256,1)
}
function mkmenu_lifecolorset(o,po) {
	o.menucmd("1",po,"setcolor",1)
	o.menucmd("2",po,"setcolor",2)
	o.menucmd("3",po,"setcolor",3)
	o.menucmd("4",po,"setcolor",4)
}
function mkmenu_lifeletter(o,po) {
	o.menucmd("Center A",po,"doletter","A",0)
	o.menucmd("Center C",po,"doletter","C",0)
	o.menucmd("Center T",po,"doletter","T",0)
	o.menucmd("Center G",po,"doletter","G",0)
	o.menucmd("Rand A",po,"doletter","A",1)
	o.menucmd("Rand C",po,"doletter","C",1)
	o.menucmd("Rand T",po,"doletter","T",1)
	o.menucmd("Rand G",po,"doletter","G",1)
}
function mkmenu_lifelimit(o,po) {
	for ( i=1; i<=12; i++ )
		o.menucmd(string(i),po,"setlimit",i)
}
function mkmenu_lifespeed(o,po) {
	o.menucmd("1/32",po,"setspeed",1.0/32)
	o.menucmd("1/16",po,"setspeed",1.0/16)
	o.menucmd("1/8",po,"setspeed",1.0/8)
	o.menucmd("1/4",po,"setspeed",1.0/4)
	o.menucmd("1/2",po,"setspeed",1.0/2)
	o.menucmd("1",po,"setspeed",1)
	o.menucmd("2",po,"setspeed",2)
	o.menucmd("4",po,"setspeed",4)
	o.menucmd("8",po,"setspeed",8)
	o.menucmd("16",po,"setspeed",16)
	o.menucmd("32",po,"setspeed",32)
	o.menucmd("64",po,"setspeed",64)
	o.menucmd("128",po,"setspeed",128)
	o.menucmd("256",po,"setspeed",256)
	o.menucmd("1000",po,"setspeed",1000)
}

function mkmenu_life1(o,po) {
	o.menucmd("Stop",po,"stop")
	o.menucmd("Go",po,"ngen",-1)
	o.menucmd("ANO",po,"ano",1,0)
	o.menucmd("Clear",po,"pattern_init",1,0)
	o.menucmd("Glider",po,"pattern_init",1,1)
	o.menucmd("Random",po,"pattern_init",1,2)
	o.submenu("Letter    ->","mkmenu_lifeletter",po)
	o.submenu("Erase Dead->","mkmenu_lifeerase",po)
	o.submenu("Speed     ->","mkmenu_lifespeed",po)
	o.menucmd("1 gen",po,"ngen",1)
	o.menucmd("10 gen",po,"ngen",10)
	o.menucmd("100 gen",po,"ngen",100)
	o.menucmd("1000 gen",po,"ngen",1000)
	o.submenu("PokeColor ->","mkmenu_lifecolor",po)
	o.submenu("Limit     ->","mkmenu_lifelimit",po)
	o.submenu("Grid Size ->","mkmenu_lifesize",po)
	o.submenu("Scale     ->","mkmenu_lifekey",po)
	o.submenu("Show      ->","mkmenu_lifetype",po)
	o.submenu("Preview   ->","mkmenu_lifepreview",po)
	o.menucmd("Toggle debug",po,"toggledebug")
}
function mkmenu_lifekey(o,po) {
	o.submenu("C","mkmenu_lifescale",po,'c')
	o.submenu("C#","mkmenu_lifescale",po,'c+')
	o.submenu("D","mkmenu_lifescale",po,'d')
	o.submenu("D#","mkmenu_lifescale",po,'d+')
	o.submenu("E","mkmenu_lifescale",po,'e')
	o.submenu("F","mkmenu_lifescale",po,'f')
	o.submenu("F#","mkmenu_lifescale",po,'f+')
	o.submenu("G","mkmenu_lifescale",po,'g')
	o.submenu("G#","mkmenu_lifescale",po,'g+')
	o.submenu("A","mkmenu_lifescale",po,'a')
	o.submenu("A#","mkmenu_lifescale",po,'a+')
	o.submenu("B","mkmenu_lifescale",po,'b')
}
function mkmenu_lifescale(o,po,k) {
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
