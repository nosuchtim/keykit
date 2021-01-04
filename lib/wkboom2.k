class wkboom2 {

method init (nsteps,ndrums,qnt,compact) {

	$.w = new window()
	$.inherit($.w)

	$.notifyobj = $0
	$.kbdrumlabel = []
	$.kbdrumnote = []
	$.kbstep = []
	$.kbprestep = []
	$.kbcurrent = []
	$.xstart = []
	$.ystart = []
	$.ison = 0
	$.bar = 4		# Every 4 steps, the vertical line is doubled.
	$.stepbutton = 0	# set to 1 if you want a separate step button
				# rather than using button 2
	$.konnectsend = 0
	$.konnectreceive = 0
	$.startquant = 1
	$.pretime = 12
	$.doflash = 1
	$.nloops = 0
	$.beatid = -1
	$.totaltrans = 0
	$.transmode = "next"	# or "immediate"
	$.nexttrans = 0
	$.volfactor = -1
	$.grabbed = 0
	$.jittamount = 1b

	if ( nargs() < 1 || nsteps < 0 )
		nsteps = Kboomsteps
	if ( nargs() < 2 || ndrums < 0 )
		ndrums = 4
	if ( nargs() < 3 || qnt < 0 )
		qnt = 1b/4
	if ( nargs() < 4 || compact < 0 )
		compact = 0

	$.layout = 1
	$.forcechan = 0
	$.quant = qnt
	$.stepsize = qnt
	$.compact = compact

	$.ndrums = 0
	if ( $.compact == 0 )
		$.drumbutt = []

	$.menubutt = new kmenubutton("More","kb2_mkmenu_kboom1",$)
	$.onoffbutt = new ktoggle("On",$,"setonoff")
	arr = []
	for ( n=0; n<25; n++ )
		arr[n] = string(n-12)
	chans = [0="X"]
	for ( n=1; n<=16; n++ )
		chans[n] = string(n)
	$.chanbutt = new kvalbutton(chans,$,"changechan")
	$.transbutt = new kvalbutton(arr,$,"changetranspose")
	$.modebutt = new kvalbutton([0="A"],$,"changemode")
	$.addchild($.menubutt)
	$.addchild($.onoffbutt)
	$.addchild($.modebutt)
	$.addchild($.transbutt)
	$.addchild($.chanbutt)
	$.transbutt.set(12)
	$.chanbutt.set(0)
	if ( $.stepbutton ) {
		$.stepbutt = new kbutton("Step",$,"step")
		$.addchild($.stepbutt)
	}

	$.modes = [
		"O"=0,		# On/Off
		"V"=1,		# Volume
		"P"=2,		# Pan
		"C"=3,		# Cutoff
		"R"=4,		# Resonance
		"%"=5,		# Probability
		"J"=6,		# Jitter
		"D"=7,		# Decay
		"E"=8,		# Echo (pre)
		"B"=9,		# Brightness
		"H"=11,		# Harmonic
		"A"=12,		# Attack (GM2)
		"Y"=13,		# Decay (GM2)
		"L"=14,		# Release (GM2)
		"G"=15		# Gate
		]
	$.modenames = [
		"O"="Toggle",	# On/Off
		"V"="Velocity",	# Volume
		"P"="Pan",	# Pan
		"C"="Cutoff",	# Cutoff
		"R"="Resonance",# Resonance
		"%"="Probability",# Probability
		"J"="Jitter",	# Jitter
		"D"="Decay",	# Decay
		"E"="Preecho",	# Preecho
		"B"="Brightness",	# Brightness
		"H"="Harmonic",		# Harmonic
		"A"="Attack(GM2)",	# Attack
		"Y"="Decay(GM2)",	# Decay
		"L"="Release(GM2)",	# Release
		"G"="Gate"	# Gate
		]
	$.modedefault = [
		"O"=0,
		"V"=64,
		"P"=64,
		"C"=64,
		"R"=64,
		"%"=100,
		"J"=0,
		"D"=64,
		"E"=0,
		"B"=64,
		"H"=64,
		"A"=64,
		"Y"=64,
		"L"=64,
		"G"=0
		]
	$.modelimit = [
		"O"=1,
		"V"=127,
		"P"=127,
		"C"=100,
		"R"=100,
		"%"=100,
		"J"=100,
		"D"=100,
		"E"=3,
		"B"=127,
		"H"=127,
		"A"=127,
		"Y"=127,
		"L"=127,
		"G"=1
		]
	$.mode = "O"

	$.setdrummap(Drummapdefault,0,nsteps,ndrums)

	$.initcell(1)

	$.initialkey = Key
	$.currentkey = Key
	$.currstep = 0
	Kboomtool = $
}

method setdrummap(t,doredraw,nsteps,ndrums) {
	global drummap
	global dr202map
	$.drummap = drummap
	me = "O%VJEPBHAYLG"
	if ( defined(KboomModes) ) {
		me = "KboomModes"
	}
	if ( t == "dr202" ) {
		$.drummap = dr202map
		me = "OVCDRJ"
	} else if ( t != "gm" ) {
		print("Unrecognized drum map name, ",t,", assuming 'gm'")
	}
	# Construct modesenabled array from list of letters
	$.modesenabled = []
	$.mnames = []
	$.mletters = []
	i = 0
	for ( n=0; n<sizeof(me); n++ ) {
		ch = substr(me,n+1,1)
		$.modesenabled[ch] = $.modes[ch]
		$.mnames[i] = $.modenames[ch]
		$.mletters[i] = ch
		i++
	}
	$.drummapname = t
	kb2_setupdrummaps()
	if ( $.compact == 0 ) {
		for ( dn=0; dn<$.ndrums; dn++ ) {
			$.drumbutt[dn].setargs($,dn,$.kbbuttmap,$.kbnotemap)
		}
	}
	$.modebutt.setvals($.mnames)
	$.modebutt.set(0)

	if ( nargs() > 2 ) {
		$.setnsteps(nsteps)
		$.setndrums(ndrums)
	}
	doinit = 1
	reset = 1
	$.wkboomreadkitdefault(doinit,doredraw,reset)
}

method setnotify(o) {
	$.notifyobj = o
}

method setbar(v) {
	$.bar = v
	$.redraw()
}

method setkonnectsend(v) {
	$.konnectsend = v
}

method setkonnectreceive(v) {
	$.konnectreceive = v
}

method setquanthalf(doredraw) {
	if ( $.quant > 1 )
		$.setquant($.quant/2,doredraw)
	else
		print("Too small")
}
method setquantdouble(doredraw) {
	$.setquant($.quant*2,doredraw)
}

method setquant(v,doredraw) {
	$.quant = v 
	if ( nargs() > 1 && doredraw!=0 ) {
		p = $.get()
		$.set(p,1,0)
	}
}

method setstartquant(v) {
	$.startquant = v 
}

method shift(n) {
	cL = $.cellL
	for ( sn=0; sn<$.nsteps; sn++ ) {
		sn2 = sn + n
		if ( sn2 >= $.nsteps )
			sn2 -= $.nsteps
		else if ( sn2 < 0 )
			sn2 += $.nsteps
		for ( dn=0; dn<$.ndrums; dn++ ) {
			$.cellL[sn][dn] = arraycopy(cL[sn2][dn])
		}
	}
	$.redraw()
}

method cellOn(sn,dn) {
	$.cellL[sn][dn]["O"] = 1
}
method cellVol(sn,dn,v) {
	if ( "V" in $.modesenabled ) {
		$.cellL[sn][dn]["V"] = v
	}
}
method cellOff(sn,dn) {
	$.cellL[sn][dn]["O"] = 0
}

method addrand(n) {
	while ( n-- > 0 ) {
		sn = rand($.nsteps)
		dn = rand($.ndrums)
		$.cellOn(sn,dn)
	}
	$.recomputeall()
	$.ihavechanged(0)
	$.redraw()
}

method counton() {
	count=0
	for ( sn=0; sn<$.nsteps; sn++ ) {
		for ( dn=0; dn<$.ndrums; dn++ ) {
			if ( $.cellL[sn][dn]["O"] == 1 ) {
				count++
			}
		}
	}
	return(count)
}

method clearrand(n) {
	while ( n-- > 0 ) {
		numon = $.counton()
		count=rand(numon)+1
		for ( sn=0; sn<$.nsteps; sn++ ) {
			for ( dn=0; dn<$.ndrums; dn++ ) {
				if ( $.cellL[sn][dn]["O"] == 1 ) {
					count--
					if ( count == 0 )
						break
				}
			}
			if ( count == 0 )
				break
		}
		if ( sn < $.nsteps && dn < $.ndrums ) {
			$.cellOff(sn,dn)
		}
	}
	$.recomputeall()
	$.ihavechanged(0)
	$.redraw()
}

# method wkboomread() {
# 	fname = getastr("Enter name of file you want to read a pattern from -> ")
# 	global _Wkboom_tmp
# 	if ( ! fileexists(fname) )
# 		print("That file (",fname,") doesn't exist!?")
# 	else {
# 		eval "#include "+fname
# 		$.restore(_Wkboom_tmp)
# 	}
# }

method wkboomreadkit(o,doinit,doredraw,reset) {
	kbfile = browsefiles("Drum Kit (.kbm)","*.kbm",1)
	if ( ! fileexists(kbfile) ) {
		print("File "+kbfile+" doesn't exist!?")
		return()
	}
	$.readkitfile(kbfile,doinit,doredraw,reset)
}

method wkboomrand(reset,nrand,chanrand) {
	if ( nargs() < 3 )
		chanrand = 0
	print("wkboomrand, reset=",reset," nrand=",nrand)
	p = ''
	for ( n=0; n<nrand; n++ ) {
		nt = makenote(1+rand(127))
		nt.dur = 1b
		nt.length = 1b
		if ( chanrand ) {
			nt.chan = 1+ rand(16)
		} else {
			nt.chan = 10
		}
		p += nt
	}
	$.setscale(p,1,reset)
}

method wkboomreadkitdefault(doinit,doredraw,reset) {
	if ( $.drummapname == "gm" ) {
		if ( defined(KboomDrumkit) )
			fn = KboomDrumkit
		else
			fn = "drums.kbm"
	}
	else
		fn = $.drummapname+".kbm"
	kbfile = pathsearch(fn)
	if ( ! fileexists(kbfile) )
		print("No default drum kit - can't find drums.kbm")
	else
		$.readkitfile(kbfile,doinit,doredraw,reset)
	if ( doredraw ) {
		$.modebutt.set(0)
		$.mode = 0
		$.redraw()
	}
}

method readkitfile(mapfile,doinit,doredraw,reset) {
	if ( reset ) {
		$.setndrums(0)
		ndrums = 0
	} else {
		ndrums = $.ndrums
	}
	drumchan = 10
	f = open(pathsearch(mapfile))
	while ( (ln=get(f)) != Eof ) {
		arr = split(ln)
		if ( substr(arr[0],1,1) == "#" )
			continue
		if ( arr[0] == "chan" ) {
			drumchan = 0 + arr[1]
			continue
		}
		$.kbdrumlabel[ndrums] = arr[0]
		$.kbdrumnote[ndrums] = makenote(0+arr[1],$.stepsize,'a'.vol,drumchan)
		ndrums++
	}
	$.setndrums(ndrums)
	close(f)

	$.setndrums(ndrums)
	if ( $.compact == 0 ) {
		for ( n=0; n<$.ndrums; n++ )
			$.drumbutt[n].settext($.kbdrumlabel[n])
	}
	$.initcell(reset)
	if ( doredraw!=0 ) {
		$.resize()
		$.redraw()
	}
}

method loadit(pt,usesnarf,reset,space) {
	if ( usesnarf != 0 )
		p = Snarf
	else {
		p = lastbunch(Recorded,space)
		p.time -= p%1.time
		p.length = latest(p)
	}
	p = onlynotes(p)
	if ( sizeof(p) < 1 ) {
		print("No notes?!")
		return()
	}
	if ( pt != 0 ) {
		# load both pitches and timing,
		# and keep the durations the same
		$.set(p,1,reset)
	}
	else {
		# Load pitches only.
		# In this case we fix the durations to
		# be the step size.
		p.dur = $.stepsize
		$.setscale(p,1,reset)
	}
}

# BOGUS!! - the set and setscale methods should be merged!!

method set(ph,doredraw,reset) {
	print("method set, ison = ",$.ison)
	wason = 0
	wasstep = 0
	if ( nargs() < 2 )
		doredraw = 0
	if ( nargs() < 3 )
		reset = 1

	if ( sizeof(ph) <= 0 ) {
		if ( doredraw ) {
			$.resize()
			$.redraw()
		}
		return()
	}

	# cellL = arraycopy($.cellL)

	if ( reset ) {
		labels = []
		notes = []
		ndrums = 0
	} else {
		# keep existing ones
		labels = $.kbdrumlabel
		notes = $.kbdrumnote
		ndrums = $.ndrums
	}
	if ( $.ison ) {
		$.onoffbutt.set(0)
		if ( doredraw )
			$.onoffbutt.redraw()
		$.ison = 0
		wason = 1
		wasstep = $.currstep
	}
	ph = onlynotes(ph)
	# If we're not resetting, we remove any existing notes
	# in the drum list from the phrase we're using to set the pitches
	pph = ph
	for ( n=0; n<ndrums; n++ ) {
		d1 = notes[n]
		pph = pph { ??.pitch!= d1.pitch || ??.chan != d1.chan }
	}
	# Now we set up the pitches
	for ( p=127; p>0; p-- ) {
		nt = pph{??.pitch==p}
		if ( sizeof(nt) == 0 )
			continue
		nt = head(nt,1)
		nt.time = 0
		nt.length = 0
		labels[ndrums] = string(nt)
		notes[ndrums] = nt
		ndrums++
	}
	$.setndrums(sizeof(labels))
	if ( $.compact == 0 ) {
		for ( n=0; n<$.ndrums; n++ )
			$.drumbutt[n].settext(labels[n])
	}
	$.kbdrumlabel = labels
	$.kbdrumnote = notes

	# Now we figure out which cells are actually filled-in

	$.stepsize = $.quant
	if ( ph.length == 0 )
		ph.length = latest(ph)
	ph.length = nextquant(ph.length,$.quant)
	ns = ph.length/$.quant
	$.setnsteps(ns)

	$.initcell(1)
	# $.copytocell(cellL)

	sn = 0
	ph = quantize(ph,$.quant)
	for ( sn=0; sn<ns; sn++ ) {
		cp = cut(ph,CUT_TIME,sn*$.quant,(sn+1)*$.quant)
		for ( nt in cp ) {
			# find pitch of nt in drums
			for ( dn=0; dn<$.ndrums; dn++ ) {
				if ( notes[dn].pitch == nt.pitch )
					break
			}
			if ( dn < $.ndrums ) {
				$.cellOn(sn,dn)
				$.cellVol(sn,dn,nt.vol)
			}
		}
	}
	$.checkdrumlabels()
	if ( doredraw ) {
		$.resize()
		$.redraw()
	}
	$.recomputeall()
	$.restart()
	if ( wason ) {
		$.stop()
		$.on()
		$.currstep = wasstep
	}
}

method setscale(ph,doredraw,reset) {
	print("method setscale, ison = ",$.ison)
	wason = 0
	currstep = 0
	if ( nargs() < 2 )
		doredraw = 0
	if ( nargs() < 3 )
		reset = 1
	if ( $.ison ) {
		$.onoffbutt.set(0)
		if ( doredraw )
			$.onoffbutt.redraw()
		$.ison = 0
		wason = 1
		wasstep = $.currstep
	}

	cellL = arraycopy($.cellL)

	if ( reset ) {
		labels = []
		notes = []
		ndrums = 0
	} else {
		# keep existing ones
		labels = $.kbdrumlabel
		notes = $.kbdrumnote
		ndrums = $.ndrums
	}
	ph = onlynotes(ph)
	# If we're not resetting, we remove any existing notes
	# in the drum list from the phrase we're using to set the pitches
	pph = ph
	for ( n=0; n<ndrums; n++ ) {
		d1 = notes[n]
		pph = pph { (??.pitch != d1.pitch) || (??.chan != d1.chan) }
	}
	for ( p=127; p>0; p-- ) {
		nt = pph{??.pitch==p}
		if ( sizeof(nt) == 0 )
			continue
		nt = head(nt,1)
		nt.time = 0
		nt.length = 0
		labels[ndrums] = string(nt)
		notes[ndrums] = nt
		ndrums++
	}

	$.setndrums(sizeof(labels))
	if ( $.compact == 0 ) {
		for ( n=0; n<$.ndrums; n++ )
			$.drumbutt[n].settext(labels[n])
	}
	$.kbdrumlabel = labels
	$.kbdrumnote = notes

	$.initcell(1)
	$.copytocell(cellL)

	$.checkdrumlabels()
	if ( doredraw ) {
		$.resize()
		$.redraw()
	}
	$.recomputeall()
	$.restart()
	if ( wason ) {
		$.stop()
		$.on()
		$.currstep = wasstep
	}
}

method checkdrumlabels() {
	# Go through drums and see if any of the notes match
	# things in the drum map.  If so, change the labels
	# to match.  This is used if you set the drums with setscale()
	# or something.

	if ( $.compact != 0 )
		return()

	for ( d=0; d<$.ndrums; d++ ) {
		nt = $.kbdrumnote[d]
		leng = sizeof($.kbnotemap)
		for ( n=0; n<leng; n++ ) {
			s = $.kbnotemap[n]
			if ( typeof(s) != "phrase" )
				continue
			if ( (nt.pitch==s.pitch) && (nt.chan==s.chan) ) {
				newname = $.kbbuttmap[n]
				$.kbdrumlabel[d] = newname
				$.drumbutt[d].settext(newname)
				break
			}
		}
	}
}

# method wkboomwrite() {
# 	fname = getastr("Enter name of file you want to write the pattern into -> ")
# 	a = $.dump()
# 	f = open(fname,"w")
# 	put(f,"_Wkboom_tmp=")
# 	put(f,string(a)+"\n") 
# 	close(f)
# }

method transposemode(mode) {
	$.transmode = mode
}

method setsteps(nsteps) {
	$.setnsteps(nsteps)
	$.changedsteps()
	$.ihavechanged(1)
	$.recomputeall()
}

method changedsteps() {
	# cellL = arraycopy($.cellL)
	$.initcell(0)
	# $.copytocell(cellL)
	$.resize()
	$.redraw()
	$.restart()
}

method changedrums(inc) {
	# cellL = arraycopy($.cellL)
	$.setndrums($.ndrums + inc)
	$.initcell(0)
	# $.copytocell(cellL)
	$.recomputeall()
	$.resize()
	$.redraw()
}

method dump() {
	st = []
	st["kbdrumlabel"] = $.kbdrumlabel
	st["kbdrumnote"] = $.kbdrumnote
	st["doflash"] = $.doflash
	st["compact"] = $.compact
	st["layout"] = $.layout
	st["cellL"] = $.cellL
	st["mode"] = $.mode
	st["totaltrans"] = $.totaltrans
	st["startquant"] = $.startquant
	return(st)
}

method restore(st) {
	$.doflash = st["doflash"]
	$.compact = st["compact"]
	$.layout = st["layout"]
	$.totaltrans = st["totaltrans"]
	$.startquant = st["startquant"]

	if ( "mode" in st )
		$.mode = st["mode"]
	$.cellL = arraycopy(st["cellL"])

	$.setnsteps(sizeof($.cellL))
	$.setndrums(sizeof($.cellL[0]))
	# Important for setting of kbdrumnote to be after setndrums call.
	$.kbdrumnote = arraycopy(st["kbdrumnote"])
	$.kbdrumlabel = arraycopy(st["kbdrumlabel"])
	$.recomputeall()

	$.resize()
	if ( $.compact == 0 ) {
		for ( dn=0; dn<$.ndrums; dn++ ) {
			nm = $.kbdrumlabel[dn]
			$.drumbutt[dn].settext(nm)
		}
	}
}

method redraw() {
	$.w.redraw()
	ndrums = $.ndrums
	xstart = $.xstart
	ystart = $.ystart
	x0 = $.xmin()
	x1 = $.xmax()
	y0 = $.ymin()
	y1 = $.ymax()
	ty = y0
	if ( $.layout == 2 )
		ty += $.textheight() + 5
	for ( n=0; n<ndrums; n++ ) {
		$.line(xy(x0,ystart[n],x1,ystart[n]))
	}
	for ( n=0; n<$.nsteps; n++ ) {
		# show beat number at top
		xyarr = $.xyofstep(n)
		$.text(string(n+1),xyarr)
		$.line(xy(xstart[n],ty,xstart[n],y1))
		if ( (n % ($.bar)) == 0 ) {
			$.line(xy(xstart[n]+1,ty,xstart[n]+1,y1))
		}
	}
	for ( sn=0; sn<$.nsteps; sn++ ) {
		cellsnL = $.cellL[sn]
		for ( dn=0; dn<ndrums; dn++ ) {
			$.drawcell(sn,dn)
		}
	}
	methodbroadcast()
}

method drawcell(sn,dn) {
	xstart = $.xstart
	ystart = $.ystart
	x0 = xstart[sn]+1
	y0 = ystart[dn]+1
	x1 = xstart[sn+1]-1
	y1 = ystart[dn+1]-1
	# If we're highlighting every $.bar steps, make adjustment
	if ( (($.bar) > 0) && ((sn % ($.bar)) == 0) ) {
		x0++
	}
	v = $.cellL[sn][dn]["O"]
	marg = 2
	if ( $.mode == 0 ) {
		if ( v > 0 ) {
			$.w.fillrectangle(xy(x0,y0,x1,y1),STORE)
		} else {
			$.w.fillrectangle(xy(x0,y0,x1,y1),CLEAR)
		}

	} else {
		if ( v > 0 ) {
			$.w.fillrectangle(xy(x0,y0,x1,y1),STORE)
			$.w.fillrectangle(xy(x0+marg,y0+marg,x1-marg,y1-marg),CLEAR)
			mv = $.cellL[sn][dn][$.mode]
			mlim = $.modelimit[$.mode]
			if ( mv > mlim ) {
				print("Value (mv=",mv,") is over limit (mlim=",mlim,")")
				mv = mlim
			}
			dy = (y1-y0-2*marg)*(mlim-mv)/mlim
			$.w.fillrectangle(xy(x0+marg,y0+dy+marg,x1-marg,y1-marg),STORE)
		} else {
			$.w.fillrectangle(xy(x0,y0,x1,y1),CLEAR)
		}
	}
}

method mousedown(m) {
	x = m["x"]
	y = m["y"]
	xstart = $.xstart
	ystart = $.ystart
	ndrums = $.ndrums

	for ( dn=0; dn<ndrums; dn++ ) {
		if ( y < ystart[dn+1] )
			break;
	}
	if ( dn >= ndrums )
		dn = -1

	# The right button now toggles on/off, even when
	# mode is set to some other attribute

	if ( y < ystart[0] || x < xstart[0] || dn < 0 ) {
		mouseforward(m,"mousedown")
		return()
	}
	for ( sn=0; sn<$.nsteps; sn++ ) {
		if ( x < xstart[sn+1] ) {
			if ( m["button"] > 1 )
				cm = "O"
			else
				cm = $.mode
			$.hitcellL(sn,dn,0,cm)
			if ( $.konnectsend!=0 && Konnect != $0 )
				Konnect.sendkboomcell(sn,dn,0,cm)

			# For everything other than toggle on/off,
			# we grab the mouse and act like a slider
			if ( cm != "O" ) {
				grabmouse($)
				$.grabbed = 1
				$.lasty = y
				$.lastsn = sn
				$.lastdn = dn
			} else {
				$.ihavechanged(0)
			}
			return()
		}
	}
	mouseforward(m,"mousedown")
	return()
}

method mousedrag(m) {
	if ( $.grabbed ) {
		dy = m["y"] - $.lasty
		$.hitcellL($.lastsn,$.lastdn,dy,$.mode)
		$.lasty = m["y"]
	} else {
		mouseforward(m,"mousedrag")
	}
}

method mouseup(m) {
	if ( $.grabbed ) {
		$.grabbed = 0
		ungrabmouse($)
		$.ihavechanged(0)
	} else {
		mouseforward(m,"mousedrag")
	}
}

method ihavechanged(lengthchanged) {
	if ( $.notifyobj != $0 && $.notifyobj != $-1 )
		$.notifyobj.notifyofchange($,lengthchanged)
}

method konnecthitcell(sn,dn,dy,cm) {
	if ( $.konnectreceive )
		$.hitcellL(sn,dn,dy,cm)
}

method hitcellL(sn,dn,dy,cmode) {
	# Increment the state of the cell (sn,dn)
	if ( cmode == "O" || cmode == 0 ) {
		v = $.cellL[sn][dn]["O"]
		if ( v ) {
			# turn the cell off
			$.cellL[sn][dn]["O"] = 0
		}
		else {
			$.cellL[sn][dn]["O"] = 1
		}
	} else {
		cv = $.cellL[sn][dn][cmode]
		mlim = $.modelimit[cmode]
		cv -= dy;
		if ( cv < 0 )
			cv = 0
		else if ( cv > mlim )
			cv = mlim;
		$.cellL[sn][dn][cmode] = cv
	}
	$.drawcell(sn,dn)
}

method initcell(reset) {
	ndrums = $.ndrums
	if ( ! reset ) {
		savecellL = arraycopy($.cellL)
	}
	$.cellL = []
# print("initcell called")
	for ( sn=0; sn<$.nsteps; sn++ ) {
		$.cellL[sn] = []
		$.kbstep[sn] = ''
		$.kbprestep[sn] = ''
		for ( dn=0; dn<ndrums; dn++ ) {
			$.cellL[sn][dn] = []
			for ( m in $.modes ) {
				$.cellL[sn][dn][m] = $.modedefault[m]
			}
		}
	}
	for ( dn=0; dn<ndrums; dn++ )
		$.kbcurrent[dn] = []
	if ( ! reset ) {
		$.copytocell(savecellL)
	}
}

method clearcells() {
	$.initcell(1)
	$.redraw()
	$.ihavechanged(0)
}

method resize(sz) {
	if ( nargs() > 0 ) {
		$.w.resize(sz)
	}
	dy = $.textheight()
	dx = 1
	dp = 1

	x0 = $.xmin()
	y0 = $.ymin()
	x1 = $.xmax()
	y1 = $.ymax()
	if ( $.compact == 0 ) {
		x0b = $.xmin() + ($.xmax()-$.xmin())/3
		ty = $.textheight() + 4
	}
	else {
		x0b = $.xmin() + 1
		ty = 4
	}
	ty0 = ty
	if ( $.layout == 2 ) {
		ty += ($.textheight()+1)
		x0b = x0
	}

	ndrums = $.ndrums
	xstart = $.xstart
	ystart = $.ystart
	for ( sn=0; sn<=$.nsteps; sn++ ) {
		xstart[sn] = x0b+(sn*(x1-x0b))/$.nsteps
	}
	for ( dn=0; dn<=ndrums; dn++ )
		ystart[dn] = y0 + ty + (dn*(y1-y0-ty))/ndrums

	if ( $.compact == 0 ) {
		for ( dn=0; dn<ndrums; dn++ ) {
			xyarr = xy(x0+1,ystart[dn],xstart[0]-2,ystart[dn+1])
			if ( $.layout == 2 )
				$.drumbutt[dn].resize(xy(0,0,0,0))
			else
				$.drumbutt[dn].resize(xyarr)
		}
		if ( $.layout == 2 ) {
			topxwid = x1-x0-1
			topy = ystart[0] - $.textheight() - 2
		} else {
			topxwid = xstart[0]-x0-1
			topy = ystart[0]
		}
		if ( $.stepbutton ) {
			dx = topxwid/6 - 2
			$.onoffbutt.resize(xy(x0+1,y0+1,x0+dx-1,topy))
			$.transbutt.resize(xy(x0+dx+1,y0+1,x0+2*dx-1,topy))
			$.chanbutt.resize(xy(x0+2*dx+1,y0+1,x0+3*dx-1,topy))
			$.stepbutt.resize(xy(x0+3*dx+1,y0+1,x0+4*dx-1,topy))
			$.modebutt.resize(xy(x0+4*dx+1,y0+1,x0+5*dx-1,topy))
			$.menubutt.resize(xy(x0+5*dx+1,y0+1,x0+topxwid-2,topy))
		}
		else {
			dx = topxwid/5 - 2
			$.onoffbutt.resize(xy(x0+1,y0+1,x0+dx-1,topy))
			$.transbutt.resize(xy(x0+dx+1,y0+1,x0+2*dx-1,topy))
			$.chanbutt.resize(xy(x0+2*dx+1,y0+1,x0+3*dx-1,topy))
			$.modebutt.resize(xy(x0+3*dx+1,y0+1,x0+4*dx-1,topy))
			$.menubutt.resize(xy(x0+4*dx+1,y0+1,x0+topxwid-2,topy))
		}
	}
}

method finddrum(w,y) {
	ndrums = $.ndrums
	ystart = $.ystart
	for ( n=0; n<ndrums; n++ ) {
		if ( y >= ystart[n] && y <= ystart[n+1] )
			return(n)
	}
	return(-1)
}

method preecho(n,v) {
	if ( v == 0 )
		return(n)
	return ( preecho(n,v,$.stepsize/(v+1),0.7) )
}

method computestep(sn) {
	$.kbstep[sn] = ''
	$.kbprestep[sn] = ''
	ndrums = $.ndrums

	if ( ! ( sn in $.cellL ) )
		return()

	lock($)

	cells = $.cellL[sn]

	pre = ''
	post = ''
	for ( dn=0; dn<ndrums; dn++ ) {
		if ( ! ( dn in cells ) )
			continue
		if ( cells[dn]["O"] == 0 ) {
			$.kbcurrent[dn]["G"] = 0
			continue
		}

		nt = $.kbdrumnote[dn]
		if ( $.totaltrans != 0 ) {
			if ( nt.chan != 10 )
				nt.pitch += $.totaltrans
		}
		for ( m in $.modesenabled ) {

			mv = cells[dn][m]

			# first handle modes that don't have state
			if ( m == "V" ) {
				nt.vol = mv
				continue
			}
			if ( m == "%" ) {
				if ( rand(100) >= mv ) {
					nt = ''
					continue
				}
			}
			if ( m == "E" ) {
				nt = $.preecho(nt,mv)
				continue
			}
			if ( m == "G" ) {
				currentwas = $.kbcurrent[dn][m]
# print("sn=",sn," dn=",dn," mv=",mv," kbcurrent[dn][G]=",currentwas)
				if ( (m in $.kbcurrent[dn]) && 1 == currentwas && mv == 0 ) {
# print("AAA setting kbcurrent dn=",dn," m=",m," to 0")
					$.kbcurrent[dn][m] = 0
				}

				if ( (m in $.kbcurrent[dn]) && 1 == currentwas ) {
# print("  Setting nt='' to bypass, dn=",dn," sn=",sn)
					nt = ''
					break
				}
				# Figure out how long the note should be,
				# by looking at the G value.
				if ( mv == 1 ) {
# print("Looking to see how long, nt=",nt)
					nt.dur += $.stepsize
# print("   Initial increment of dur = ",nt.dur)
					firstsn = sn
					tmpsn = sn
					while (1) {
						tmpsn++
						if ( tmpsn >= $.nsteps )
							tmpsn = 0
# print("   tmpsn=",tmpsn," firstsn=",firstsn)
						if ( firstsn == tmpsn )
							break
						tmpcells = $.cellL[tmpsn]
						if ( tmpcells[dn]["O"] == 0 
							|| tmpcells[dn]["G"] == 0 ) {
							break
						}
						nt.dur += $.stepsize
# print("   tmpsn=",tmpsn," Extending nt.dur to ",nt.dur)
					}
				}
# print("   Final nt=",nt)
# print("   Setting kbcurrent dn=",dn," m=",m," to mv=",mv)
				$.kbcurrent[dn][m] = mv
				continue
			}

			# If the previous step set the same value
			# for this particular attribute, we don't want
			# to send it a second time.
			if ( (m in $.kbcurrent[dn]) && mv == $.kbcurrent[dn][m] ) {
				continue
			}
			$.kbcurrent[dn][m] = mv

			p = nt.pitch
			if ( m == "J" ) {
				j = ($.jittamount * mv) / 100
				nt.time += (rand(j)-j/2)
			} else if ( m == "P" ) {
				mm = pannote(nt.chan,mv)
				pre += mm;
			} else if ( m == "B" ) {
				mm = brightnote(nt.chan,mv)
				pre += mm;
			} else if ( m == "H" ) {
				mm = harmonicnote(nt.chan,mv)
				pre += mm;
			} else if ( m == "A" ) {
				mm = attacknote(nt.chan,mv)
				pre += mm;
			} else if ( m == "Y" ) {
				mm = decaynote(nt.chan,mv)
				pre += mm;
			} else if ( m == "L" ) {
				mm = releasenote(nt.chan,mv)
				pre += mm;
			} else if ( m == "C" ) {
				mv += 0x0e
				mm = midibytes(nrpn(nt.chan,0x15,p),
					datamsg(nt.chan,mv,mv))
				pre += mm;
			} else if ( m == "D" ) {
				mv += 0x0e
				mm = midibytes(nrpn(nt.chan,0x17,p),
					datamsg(nt.chan,mv,mv))
				pre += mm;
			} else if ( m == "R" ) {
				mv += 0x0e
				mm = midibytes(nrpn(nt.chan,0x16,p),
					datamsg(nt.chan,mv,mv))
				pre += mm;
			}
		}
		post |= nt
	}
	if ( $.volfactor > -1 ) {
		pre.vol *= $.volfactor
		post.vol *= $.volfactor
	}
	if ( $.forcechan > 0 ) {
		pre.chan = $.forcechan
		post.chan = $.forcechan
	}
	$.kbprestep[sn] = pre
	$.kbstep[sn] = post
	unlock($)
}

method getstep(sn,withatts) {
	if ( nargs() < 2 ) {
		withatts = 0
	}
	r = ''
	ndrums = $.ndrums

	if ( ! ( sn in $.cellL ) )
		return('')

	lock($)

	cells = $.cellL[sn]

	for ( dn=0; dn<ndrums; dn++ ) {
		if ( ! ( dn in cells ) )
			continue
		if ( cells[dn]["O"] == 0 )
			continue

		nt = $.kbdrumnote[dn]
		if ( $.totaltrans != 0 ) {
			if ( nt.chan != 10 )
				nt.pitch += $.totaltrans
		}
		atts = attribarray(nt.attrib)
		for ( m in $.modesenabled ) {

			mv = cells[dn][m]

			# first handle modes that don't have state
			if ( m == "V" ) {
				nt.vol = mv
			} else if ( m == "E" ) {
				nt = $.preecho(nt,mv)
			} else {
				atts[m] = mv
			}
		}
		if ( withatts )
			nt.attrib = string(atts)
		if ( $.volfactor > -1 )
			nt.vol *= $.volfactor
		r |= nt
	}
	unlock($)
	return(r)
}

method recomputeall() {
	$.resetcurrent()
}
method resetcurrent() {
	for ( dn=0; dn<$.ndrums; dn++ )
		$.kbcurrent[dn] = []
}

method getnsteps {
	return($.nsteps)
}

method phraseofstep(sn) {

	ph = $.kbstep[sn]

	preph = $.kbprestep[sn]
	preph.time = - $.pretime

	return( preph | ph )
}

method get() {
	r = ''
	$.recomputeall()
	for ( sn=0; sn<$.nsteps; sn++ ) {
		ph = $.getstep(sn,0)
		ph.time += sn * $.stepsize
		r |= ph
	}
	r.length = $.nsteps * $.stepsize
	return(r)
}

method flash(sn, tm) {

	xyarr = $.xyofstep(sn)
	sleeptill(tm)

	# draw the step number in inverse video
	$.fillrectangle(xyarr,STORE)
	$.text(string(sn+1), xyarr,CLEAR)

	sleeptill(Now+$.stepsize)

	$.fillrectangle(xyarr,CLEAR)
	$.text(string(sn+1), xyarr)
}

method xyofstep(sn,inset) {
	xstart = $.xstart
	ystart = $.ystart
	if ( nargs() < 1 )
		sn = 0
	y0 = $.ymin()
	if ( $.layout == 2 )
		y0 += $.textheight() + 3
	xyarr = xy(xstart[sn]+1,y0+1,xstart[sn+1]-1,ystart[0]-1)
	return(xyarr)
}

method changetranspose(n) {
	$.settranspose(n-12)
}
method changechan(n) {
	$.forcechan = n
}

method changemode(n) {
	$.mode = $.mletters[n]
	$.redraw()
}

method step {
	if ( $.beatid >= 0 ) {
		$.stop()
		sleeptill(Now+$.stepsize+1)	# to unhighlight current beat
		kill($.beatid)
		$.beatid = -1
		# leave currstep alone
	}
	else {
		xyarr = $.xyofstep($.currstep)
		$.fillrectangle(xyarr,CLEAR)
		$.text(string($.currstep+1), xyarr)
		$.currstep = ($.currstep+1)%($.nsteps)
	}
	xyarr = $.xyofstep($.currstep)
	$.fillrectangle(xyarr,STORE)
	$.text(string($.currstep+1), xyarr,CLEAR)

	$.computestep($.currstep)
	p = $.phraseofstep($.currstep)
	if ( p != '' ) {
		p.time -= (p%1).time
		realmidi(p,Now)
		if ( $.konnectsend!=0 && Konnect != $0 )
			Konnect.sendphrase(p)
	}
}

method restart(starttm) {
	# print("restart! ison=",$.ison)
	if ( nargs() < 1 ) {
		if ( $.startquant <= -100 ) {
			starttm = waitforstart($,$.startquant)
		} else if ( $.startquant == -1 ) {
			lng = $.nsteps * $.stepsize
			starttm = nextquant(Now,lng)
		} else {
			starttm = nextquant(Now,$.startquant)
		}
	}
	if ( $.beatid >= 0 )
		kill($.beatid)
	$.beatid = task $.task_kbbeat(starttm)
}

method setnsteps(ns) {
	$.nsteps = ns
	for ( sn=0; sn<ns; sn++ ) {
		$.kbstep[sn] = ''
		$.kbprestep[sn] = ''
	}
}

method copytocell(fromcellL) {
	ndrums = $.ndrums
	tocellL = $.cellL
	for ( sn=0; sn<$.nsteps; sn++ ) {
		if ( !(sn in fromcellL) || !(sn in tocellL) )
			continue
		for ( dn=0; dn<ndrums; dn++ ) {
			if ( !(dn in fromcellL[sn]) || !(dn in tocellL[sn]) )
				continue
			tocellL[sn][dn] = arraycopy(fromcellL[sn][dn])
		}
	}
}
method flashon { $.doflash = 1 }
method flashoff { $.doflash = 0 }
method setlayout (n) { $.layout = n; $.resize(); $.redraw() }
method setvolfactor(f) {
	$.volfactor = f
	$.recomputeall()
}
method realtranspose(v) {
	$.totaltrans = v
	$.nexttrans = v
	$.recomputeall()
}
method settranspose (v) {
	if ( $.transmode == "next" )
		$.nexttrans = v
	else
		$.realtranspose(v)
}
method transpose (v) {
	nv = $.nexttrans + v	# $.nexttrans, so it's cumulative
	if ( $.transmode == "next" )
		$.nexttrans = nv
	else
		$.realtranspose(nv)
}
method setndrums (ndrums) {
	while ( ndrums > $.ndrums ) {
		dn = $.ndrums
		if ( $.compact == 0 ) {
			$.drumbutt[dn] = new kmenubutton("---",
				"kb2_kb_mkmenu",$,dn,$.kbbuttmap,$.kbnotemap)
			$.addchild($.drumbutt[dn])
		}
		# don't wipe out existing values
		if ( ! (dn in $.kbdrumnote) ) {
			$.kbdrumnote[dn] = ''
		}
		$.ndrums++
	}
	while ( ndrums < $.ndrums && $.ndrums > 1 ) {
		$.ndrums--
		dn = $.ndrums
		if ( $.compact == 0 ) {
			o = $.drumbutt[dn]
			$.removechild(o)
			deleteobject(o)
		}
		delete $.kbdrumnote[dn]
	}
}
method onAnd(sn,dn) {
	$.cellOn(sn,dn)
	$.drawcell(sn,dn)
}
method offAnd(sn,dn) {
	$.cellOff(sn,dn)
	$.drawcell(sn,dn)
}
method setdrum (dn,nt,nm) {
	if ( nargs() < 3 )
		nm = ""
	if ( typeof(nt) == "phrase" ) {
		# $.kbdrumnote[dn] = makenote(nt.pitch,
		# 	$.stepsize,'a'.vol,nt.chan)
		$.kbdrumnote[dn] = nt
	}
	else if ( nt == 0 ) {
		# Last Rec Note/Chord
		nt = lastnotechord(Recorded)
		nt.dur = $.stepsize
		nt.time = 0
		nt.length = latest(nt)
		$.kbdrumnote[dn] = nt
		nm = string(nt)
	}
	else if ( nt == 1 ) {
		# Last Rec Phrase
		nt = lastbunch(Recorded,2b)
		nt = strip(nt)
		nt.length = latest(nt)
		$.kbdrumnote[dn] = nt
		nm = string(nt)
	}
	else if ( nt == 2 ) {
		# Use Snarf
		nt = strip(Snarf)
		nt.length = latest(nt)
		$.kbdrumnote[dn] = nt
		nm = string(nt)
	}
	else if ( nt == 3 ) {
		nm = getastr("Enter label --> ")
	}
	else if ( nt == 4 ) {
		# clear
		for ( sn=0; sn<$.nsteps; sn++ ) {
			if (  $.cellL[sn][dn]["O"] != 0 ) {
				$.offAnd(sn,dn)
			}
		}
		nm = ""
	}
	else if ( nt == 5 ) {
		# delete

		# shift other drum rows down one
		for ( dn2=dn+1; dn2<$.ndrums; dn2++ ) {
			for ( sn=0; sn<$.nsteps; sn++ ) {
				$.cellL[sn][dn2-1] = arraycopy($.cellL[sn][dn2])
			}
			$.kbdrumlabel[dn2-1] = $.kbdrumlabel[dn2]
			$.kbdrumnote[dn2-1] = $.kbdrumnote[dn2]
			if ( $.compact == 0 )
				$.drumbutt[dn2-1].settext($.kbdrumlabel[dn2-1])
		}
		$.changedrums(-1)
		nm = ""
	}
	else if ( nt == 6 ) {
		# every 8
		for ( sn=0; sn<$.nsteps; sn++ ) {
			if ( sn%8 != 0 )
				continue
			$.onAnd(sn,dn)
		}
		nm = ""
	}
	else if ( nt == 7 ) {
		# every other 8
		for ( sn=0; sn<$.nsteps; sn++ ) {
			if ( ((sn-4)%8) != 0 )
				continue
			$.onAnd(sn,dn)
		}
		nm = ""
	}
	else if ( nt == 8 ) {
		# half random
		for ( sn=0; sn<$.nsteps; sn++ ) {
			if ( rand(2) == 0 )
				continue
			$.onAnd(sn,dn)
		}
		nm = ""
	}
	else if ( nt == 9 ) {
		# random 1
		sn = rand($.nsteps)
		$.onAnd(sn,dn)
		nm = ""
	}
	else if ( nt == 10 ) {
		# random 4
		for ( n=0; n<4; n++ ) {
			sn = rand($.nsteps)
			$.onAnd(sn,dn)
		}
		nm = ""
	}
	else if ( nt == 11 ) {
		nm = ""		# the ------- separator
	}
	if ( nm != "" ) {
		$.kbdrumlabel[dn] = nm
		if ( $.compact == 0 ) {
			$.drumbutt[dn].settext(nm)
			$.drumbutt[dn].redraw()
		}
	}

	# Really shouldn't call this every time
	$.ihavechanged(0)
}
method stop { $.onoffbutt.set(0); $.onoffbutt.redraw(); $.ison = 0 }
method on(...) {
	$.ison = 1
	if ( $.beatid < 0 )
		$.restart(...)
	$.resetcurrent()
	$.onoffbutt.set(1)
	$.onoffbutt.redraw()
}
method sync { $.currstep = 0 }
method play { $.on() }
method snarf { Snarf = dr202decode($.get()) }
method setonoff (v) { if ( v ) $.on(); else $.stop() }
method delete { Kboomtool=$0 ; if ( $.beatid >= 0 ) kill($.beatid) }

method bang(...) { $.sync(); if ($.ison) { $.stop(...); } else { $.on(...); $.nloop = 0; } }

method resetbeatid() {
	$.beatid = -1
}

# The argument, if specified, is the start time
method task_kbbeat(starttm) {
	tm = starttm
	onexit(global(kb2_beatend),$)
	$.currstep = 0
	if ( $.currentkey != Key ) {
		$.currentkey = Key
		task $.realtranspose(Key.pitch - $.initialkey)
	}
	while ( $.ison ) {
		$.computestep($.currstep)
		p = $.phraseofstep($.currstep)
		if ( p != '' ) {
			realmidi(p,tm)
			if ( $.konnectsend!=0 && Konnect != $0 ) {
				p.time += tm
				Konnect.sendphrase(p)
			}
			if ( defined(Motion) )
				Motion.play(p)
		}
		if ( $.doflash ) {
			task $.flash($.currstep,tm)
		}
		# If the tempo's too fast, we don't want to fall behind.
		# Hence this loop.
		for ( ;; ) {
			tm += $.stepsize
			$.currstep = ($.currstep+1)%($.nsteps)
			if ( $.currstep == 0 ) {
				if ( $.nloops > 0 ) {
					$.nloops--
					if ( $.nloops == 0 )
						$.stop()
				}
			}
			if ( tm >= Now )
				break
		}
		# after updating currstep, just before going to sleep...
		if ( $.ison != 0 && $.currstep == 0 ) {
			if ( $.nexttrans != $.totaltrans )
				task $.realtranspose($.nexttrans)
			if ( $.currentkey != Key ) {
				$.currentkey = Key
				task $.realtranspose(Key.pitch - $.initialkey)
			}
		}
		sleeptill(tm-$.stepsize+2)
	}
	$.beatid = -1
}

}

function kb2_setupdrummaps() {
	# NOTE: IF YOU ADD TO kbbuttmap, ADD AN ENTRY TO $.kbnotemap, TOO!
	$.kbbuttmap = [
		0="Use Rec'd Note/Chord",
		1="Use Rec'd Phrase",
		2="Use Snarf",
		3="Set Label",
		4="Clear",
		5="Delete",
		6="Every 8",
		7="Every other 8",
		8="Half Random",
		9="Random 1",
		10="Random 4",
		11="------------"
		]
	$.kbnotemap = [
		0=0,
		1=1,
		2=2,
		3=3,
		4=4,
		5=5,
		6=6,
		7=7,
		8=8,
		9=9,
		10=10,
		11=11
		]
	offset = sizeof($.kbbuttmap)
	dm = $.drummap()
	dmsize = sizeof(dm)
	for ( n=0; n<dmsize; n++ ) {
		$.kbbuttmap[offset+n] = dm[n]["name"]
		$.kbnotemap[offset+n] = dm[n]["note"]
	}
}

function kb2_kb_mkmenu(o,po,dn,dmap,dnote) {
	nm = sizeof(dmap)
	for ( n=0; n<nm; n++ ) {
		o.menucmd(dmap[n],po,"setdrum",dn,dnote[n],dmap[n])
	}
}


function kb2_mkmenu_kboom1(o,po) {
	o.menucmd("Snarf",po,"snarf")
	o.menucmd("Clear",po,"clearcells")
	o.submenu("Load Drums ->","kb2_mkmenu_kboomload",po)
	o.submenu("Step Size  ->","kb2_mkmenu_kboomstepsize",po)
	o.submenu("Start Quant->","kb2_mkmenu_kboomstartquant",po)
	# o.menucmd("Read File",po,"wkboomread")
	# o.menucmd("Write File",po,"wkboomwrite")
	o.submenu("Flash      ->","kb2_mkmenu_kboom2",po)
	o.submenu("Layout     ->","kb2_mkmenu_kboom2layout",po)
	o.submenu("Transpose  ->","kb2_mkmenu_kboomtrans",po)
	o.submenu("# of Steps ->","kb2_mkmenu_kboom4",po)
	o.submenu("# of Drums ->","kb2_mkmenu_kboom5",po)
	o.submenu("Drum Map   ->","kb2_mkmenu_kboom6",po)
	o.submenu("Shift      ->","kb2_mkmenu_kbshift",po)
	o.submenu("Random     ->","kb2_mkmenu_kbrand",po)
	o.submenu("Bar Steps  ->","kb2_mkmenu_kbbar",po)
	o.submenu("Konnect    ->","kb2_mkmenu_kbkonnect",po)
	# o.menucmd("Restart",po,"restart")
}

function kb2_mkmenu_kbkonnect(o,po) {
	o.menucmd("Send On",po,"setkonnectsend",1)
	o.menucmd("Send Off",po,"setkonnectsend",0)
	o.menucmd("Receive On",po,"setkonnectreceive",1)
	o.menucmd("Receive Off",po,"setkonnectreceive",0)
}


function kb2_mkmenu_kbbar(o,po) {
	o.menucmd("2",po,"setbar",2)
	o.menucmd("4",po,"setbar",4)
	o.menucmd("6",po,"setbar",6)
	o.menucmd("8",po,"setbar",8)
	o.menucmd("16",po,"setbar",16)
}

function kb2_mkmenu_kboomstepsize(o,po) {
	o.menucmd("In Half",po,"setquanthalf",1)
	o.menucmd("Double",po,"setquantdouble",1)
	o.submenu("Set to ->","kb2_mkmenu_kboomquant",po)
}

function kb2_mkmenu_kboomquant(o,po) {
	o.menucmd("Whole",po,"setquant",4b,1)
	o.menucmd("Half",po,"setquant",2b,1)
	o.menucmd("Quarter",po,"setquant",1b,1)
	o.menucmd("8th",po,"setquant",1b/2,1)
	o.menucmd("16th",po,"setquant",1b/4,1)
	o.menucmd("32nd",po,"setquant",1b/8,1)
	o.menucmd("64th",po,"setquant",1b/16,1)
	o.menucmd("128th",po,"setquant",1b/32,1)
	o.menucmd("1 click",po,"setquant",1,1)
}

function kb2_mkmenu_kboomstartquant(o,po) {
	o.menucmd("Length of pattern",po,"setstartquant",-1)
	o.menucmd("1 click",po,"setstartquant",1)
	o.menucmd("1 beat",po,"setstartquant",1b)
	o.menucmd("2 beats",po,"setstartquant",2b)
	o.menucmd("4 beats",po,"setstartquant",4b)
	o.menucmd("8 beats",po,"setstartquant",8b)
	o.menucmd("Midi Start",po,"setstartquant",-100)
	o.menucmd("Midi Start + 4b",po,"setstartquant",-100-4b)
}


function kb2_mkmenu_kbshift(o,po) {
	o.menucmd("1 >>>",po,"shift",-1)
	o.menucmd("4 >>>",po,"shift",-4)
	o.menucmd("<<< 1",po,"shift",1)
	o.menucmd("<<< 4",po,"shift",4)
}
function kb2_mkmenu_kbrand(o,po) {
	o.menucmd("Add 8",po,"addrand",8)
	o.menucmd("Add 16",po,"addrand",16)
	o.menucmd("Add 24",po,"addrand",24)
	o.menucmd("Add 32",po,"addrand",32)
	o.menucmd("Clear 2",po,"clearrand",2)
	o.menucmd("Clear 4",po,"clearrand",4)
	o.menucmd("Clear 8",po,"clearrand",8)
}

function kb2_mkmenu_kboomload(o,po) {
	o.submenu("Add   ->","kb2_mkmenu_kboomread",po,0)
	o.submenu("Reset ->","kb2_mkmenu_kboomread",po,1)
}

function kb2_mkmenu_kboomread(o,po,reset) {
	o.menucmd("Drumkit (default)",po,"wkboomreadkitdefault",reset,1,1,reset)
	o.menucmd("Drumkit from File",po,"wkboomreadkit",reset,1,1,reset)
	o.submenu("Pitches and Timing ->","kb2_mkmenu_kboomreadpt",po,1,reset)
	o.submenu("Pitches only       ->","kb2_mkmenu_kboomreadpt",po,0,reset)
	o.menucmd("Random 4",po,"wkboomrand",reset,4)
	o.menucmd("Random 8",po,"wkboomrand",reset,8)
	o.menucmd("Random 16",po,"wkboomrand",reset,16)
	o.menucmd("Random 32",po,"wkboomrand",reset,32)
	o.menucmd("Random 16 (rand channels)",po,"wkboomrand",reset,16,1)
	o.menucmd("Random 32 (rand channels)",po,"wkboomrand",reset,32,1)
}

function kb2_mkmenu_kboomreadpt(o,po,pt,reset) {
	o.menucmd("From Snarf",po,"loadit",pt,1,reset)
	o.menucmd("From Recorded (2b space)",po,"loadit",pt,0,reset,2b)
	o.menucmd("From Recorded (8b space)",po,"loadit",pt,0,reset,8b)
}

# function mkmenu_readsnarf(o,po) {
# 	o.menucmd("Use Pitches and Timing",po,"readsnarf",1)
# 	o.menucmd("Use Pitches only",po,"readsnarf",0)
# }

function kb2_mkmenu_kboomtrans(o,po) {
	o.menucmd("Immediate",po,"transposemode","immediate")
	o.menucmd("Next",po,"transposemode","next")
	o.menucmd("Reset",po,"settranspose",0)
}

function kb2_mkmenu_kboom4(o,po) {
	ns = po.getnsteps()*2
	for ( n=ns; n>=1; n-- )
		o.menucmd(string(n),po,"setsteps",n)
}

function kb2_mkmenu_kboom5(o,po) {
	o.menucmd("Add 1",po,"changedrums",1)
	o.menucmd("Add 4",po,"changedrums",4)
	o.menucmd("Delete 1",po,"changedrums",-1)
	o.menucmd("Delete 4",po,"changedrums",-4)
}
function kb2_mkmenu_kboom6(o,po) {
	o.menucmd("General MIDI",po,"setdrummap","gm",1)
	o.menucmd("DR-202",po,"setdrummap","dr202",1)
}

function kb2_mkmenu_kboom2(o,po) {
	o.menucmd("On",po,"flashon")
	o.menucmd("Off",po,"flashoff")
}
function kb2_mkmenu_kboom2layout(o,po) {
	o.menucmd("1",po,"setlayout",1)
	o.menucmd("2",po,"setlayout",2)
}


function kb2_beatend(o) {
	o.resetbeatid()
}
