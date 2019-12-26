#define FULLON 4

Kb_names = []
Kb_notes = []

class wkboom {

method init (nsteps,ndrums,qnt,compact) {

	$.w = new window()
	$.inherit($.w)

	$.notifyobj = $0
	setupdrummaps()
	$.kbnotemap = Kb_notes
	$.kbbuttmap = Kb_names
	$.kbdrumlabel = []
	$.kbdrumnote = []
	$.kbstep = []
	$.xstart = []
	$.ystart = []
	$.ison = 0
	$.konnectsend = 0
	$.konnectreceive = 1
	$.stepbutton = 0	# set to 1 if you want a separate step button
				# rather than using button 2
	$.startquant = Kboomquant
	$.doflash = 1
	$.nloops = 0
	$.beatid = -1
	$.inc = FULLON
	$.totaltrans = 0
	$.transmode = "next"	# or "immediate"
	$.nexttrans = 0
	$.volfactor = -1

	if ( nargs() < 1 || nsteps < 0 )
		nsteps = Kboomsteps
	if ( nargs() < 2 || ndrums < 0 )
		ndrums = 4
	if ( nargs() < 3 || qnt < 0 )
		qnt = 1b/4
	if ( nargs() < 4 || compact < 0 )
		compact = 0

	$.layout = 1
	$.quant = qnt
	$.stepsize = qnt
	$.compact = compact

	$.ndrums = 0
	if ( $.compact == 0 )
		$.drumbutt = []

	$.setnsteps(nsteps)
	$.setndrums(ndrums)

	if ( defined(KboomDrumkit) )
		$.readkitfile(KboomDrumkit,0)

	$.initcell()

	$.b1 = new kmenubutton("More","mkmenu_kboom1",$)
	$.b2 = new ktoggle("On",$,"setonoff")
	$.addchild($.b1)
	$.addchild($.b2)
	if ( $.stepbutton ) {
		$.b3 = new kbutton("Step",$,"step")
		$.addchild($.b3)
	}

	$.currstep = 0
	# $.restart()
	Kboomtool = $

}

method setnotify(o) {
	$.notifyobj = o
}

method setkonnectsend(v) {
	$.konnectsend = v
}
method setkonnectreceive(v) {
	$.konnectreceive = v
}

method setquanthalf(doredraw) {
	$.quant = $.quant/2 
	if ( nargs() > 0 && doredraw!=0 ) {
		p = $.get()
		$.set(p,1,0)
	}
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
	c = arraycopy($.cell)
	for ( sn=0; sn<$.nsteps; sn++ ) {
		sn2 = sn + n
		if ( sn2 >= $.nsteps )
			sn2 -= $.nsteps
		else if ( sn2 < 0 )
			sn2 += $.nsteps
		for ( dn=0; dn<$.ndrums; dn++ ) {
			$.cell[sn][dn] = c[sn2][dn]
		}
	}
	$.redraw()
}

method addrand(n) {
	while ( n-- > 0 ) {
		sn = rand($.nsteps)
		dn = rand($.ndrums)
		$.cell[sn][dn] = FULLON
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

method wkboomreadkit(o) {
	kbfile = browsefiles("Drum Kit (.kbm)","*.kbm",1)
	if ( ! fileexists(kbfile) ) {
		print("File "+kbfile+" doesn't exist!?")
		return()
	}
	$.readkitfile(kbfile,1)
}

method wkboomreadkitdefault() {
	kbfile = pathsearch("drums.kbm")
	if ( ! fileexists(kbfile) )
		print("No default drum kit - can't find drums.kbm")
	else
		$.readkitfile(kbfile,1)
}

method readkitfile(mapfile,doinit) {
	labels = []
	notes = []
	ndrums = 0
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
		labels[ndrums] = arr[0]
		notes[ndrums] = makenote(0+arr[1],$.stepsize,'a'.vol,drumchan)
		ndrums++
	}
	close(f)

	$.setndrums(sizeof(labels))
	if ( $.compact == 0 ) {
		for ( n=0; n<$.ndrums; n++ )
			$.drumbutt[n].settext(labels[n])
	}
	$.kbdrumlabel = labels
	$.kbdrumnote = notes
	if ( nargs() < 1 || doinit!=0 ) {
		$.initcell()
		$.resize()
		$.redraw()
	}

}

method loadit(pt,usesnarf,reset) {
	if ( usesnarf != 0 )
		p = Snarf
	else {
		p = lastbunch(Recorded,2b)
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
		$.b2.set(0)
		if ( doredraw )
			$.b2.redraw()
		$.ison = 0
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

	$.initcell()
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
			if ( dn < $.ndrums )
				$.cell[sn][dn] = FULLON
		}
	}
	$.checkdrumlabels()
	if ( doredraw ) {
		$.resize()
		$.redraw()
	}
	$.recomputeall()
	$.restart()
}

method setscale(ph,doredraw,reset) {
	if ( nargs() < 2 )
		doredraw = 0
	if ( nargs() < 3 )
		reset = 1
	if ( $.ison ) {
		$.b2.set(0)
		if ( doredraw )
			$.b2.redraw()
		$.ison = 0
	}
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

	$.initcell()
	$.checkdrumlabels()
	if ( doredraw ) {
		$.resize()
		$.redraw()
	}
	$.recomputeall()
	$.restart()
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
		leng = sizeof(Kb_notes)
		for ( n=0; n<leng; n++ ) {
			s = Kb_notes[n]
			if ( typeof(s) != "phrase" )
				continue
			if ( (nt.pitch==s.pitch) && (nt.chan==s.chan) ) {
				newname = Kb_names[n]
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

method setmode(mode) {
	if ( mode == "binary" )
		$.setinc(FULLON)
	else
		$.setinc(1)
}

method transposemode(mode) {
	$.transmode = mode
}

method setsteps(nsteps) {
	$.setnsteps(nsteps)
	$.changedsteps()
	$.recomputeall()
}

method changedsteps() {
	cell = $.cell
	$.initcell()
	$.copytocell(cell)
	$.resize()
	$.redraw()
	$.restart()
	$.ihavechanged(1)
}

method changedrums(inc) {
	cell = arraycopy($.cell)
	$.setndrums($.ndrums + inc)
	$.initcell()
	$.copytocell(cell)
	$.recomputeall()
	$.resize()
	$.redraw()
}

method dump() {
	st = []
	st["kbdrumlabel"] = $.kbdrumlabel
	st["kbdrumnote"] = $.kbdrumnote
	st["doflash"] = $.doflash
	st["inc"] = $.inc
	st["compact"] = $.compact
	st["layout"] = $.layout
	st["cell"] = $.cell
	return(st)
}

method restore(st) {
	$.doflash = st["doflash"]
	$.inc = st["inc"]
	$.compact = st["compact"]
	$.layout = st["layout"]
	$.cell = arraycopy(st["cell"])
	$.nsteps = sizeof($.cell)
	nd = sizeof($.cell[0])
	$.setndrums(nd)
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
	}
	cell = $.cell
	for ( sn=0; sn<$.nsteps; sn++ ) {
		cellsn = cell[sn]
		for ( dn=0; dn<ndrums; dn++ ) {
			v = cellsn[dn]
			if ( v > 0 ) {
				$.fillcell(sn,dn,v,STORE)
			}
		}
	}
	methodbroadcast()
}

method fillcell(sn,dn,val,mode) {
	xstart = $.xstart
	ystart = $.ystart
	x0 = xstart[sn]+1
	y0 = ystart[dn]+1
	x1 = xstart[sn+1]-1
	y1 = ystart[dn+1]-1
	dy = (y1-y0) * (FULLON-val) / (FULLON)
	$.w.fillrectangle(xy(x0,y0+dy,x1,y1),mode)
}

method drumofy(y) {
	ndrums = $.ndrums
	ystart = $.ystart
	for ( dn=0; dn<ndrums; dn++ ) {
		if ( y < ystart[dn+1] )
			break;
	}
	if ( dn >= ndrums )
		return(-1)
	else
		return(dn)
}

method mousedown(m) {
	x = m["x"]
	y = m["y"]
	xstart = $.xstart
	ystart = $.ystart
	ndrums = $.ndrums
	if ( m["button"] > 1 ) {
		if ( x < xstart[0] ) {
			dn = $.drumofy(y)
			if ( dn >= 0 ) {
				realmidi($.kbdrumnote[dn],Now)
			}
		}
		else {
			$.step()
		}
		return()
	}
	if ( y < ystart[0] || x < xstart[0] ) {
		mouseforward(m,"mousedown")
		return()
	}
	dn = $.drumofy(y)
	if ( dn>=0 ) {
		for ( sn=0; sn<$.nsteps; sn++ ) {
			if ( x < xstart[sn+1] ) {
				$.hitcell(sn,dn)
				if ( $.konnectsend!=0 && Konnect != $0 )
					Konnect.sendkboomcell(sn,dn)
				task $.computestep(sn)
				$.ihavechanged(0)
				return()
			}
		}
	}
	mouseforward(m,"mousedown")
}

method ihavechanged(lengthchanged) {
	if ( $.notifyobj != $0 && $.notifyobj != $-1 )
		$.notifyobj.notifyofchange($,lengthchanged)
}

method konnecthitcell(sn,dn) {
	if ( $.konnectreceive )
		$.hitcell(sn,dn)
}

method hitcell(sn,dn) {
	# Increment the state of the cell (sn,dn)
	v = $.cell[sn][dn]
	if ( v >= FULLON ) {
		# turn the cell off
		$.fillcell(sn,dn,v,CLEAR)
		$.cell[sn][dn] = 0
		$.kbstep[sn] -= $.kbdrumnote[dn]
	}
	else {
		v = $.cell[sn][dn] + $.inc
		if ( v > FULLON )
			v = FULLON
		$.cell[sn][dn] = v
		$.fillcell(sn,dn,v,STORE)
	}
}

method initcell() {
	ndrums = $.ndrums
	$.cell = cell = []
	for ( sn=0; sn<$.nsteps; sn++ ) {
		cell[sn] = []
		$.kbstep[sn] = ''
		for ( dn=0; dn<ndrums; dn++ ) {
			cell[sn][dn] = 0
		}
	}
}

method clearcells() {
	$.initcell()
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
			dx = topxwid/3 - 2
			$.b2.resize(xy(x0+1,y0+1,x0+dx-1,topy))
			$.b1.resize(xy(x0+2*dx+1,y0+1,x0+topxwid-2,topy))
			$.b3.resize(xy(x0+dx+1,y0+1,x0+2*dx-1,topy))
		}
		else {
			dx = topxwid/2 - 2
			$.b2.resize(xy(x0+1,y0+1,x0+dx-1,topy))
			$.b1.resize(xy(x0+dx+1,y0+1,x0+topxwid-2,topy))
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

method computestep(sn) {
	$.kbstep[sn] = ''
	ndrums = $.ndrums
	lock($)

	for ( dn=0; dn<ndrums; dn++ ) {
		v = $.cell[sn][dn]
		if ( v == 0 )
			continue
		if ( v >= FULLON || (rand(1000)<(v*1000/FULLON)) ) {
			nt = $.kbdrumnote[dn]
			if ( $.totaltrans != 0 ) {
				if ( nt.chan != 10 )
					nt.pitch += $.totaltrans
			}
			if ( $.volfactor > -1 ) {
				nt.vol *= $.volfactor
			}
			$.kbstep[sn] |= nt
		}
	}
	unlock($)
}

method recomputeall() {
	for ( sn=0; sn<$.nsteps; sn++ )
		$.computestep(sn)
}

method getnsteps {
	return($.nsteps)
}

method get() {
	r = ''
	$.recomputeall()
	for ( sn=0; sn<$.nsteps; sn++ ) {
		ph = $.kbstep[sn]
		ph.time = sn * $.stepsize
		r |= ph
	}
	r.length = $.nsteps * $.stepsize
	return(r)
}

method flash(sn,tm) {

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
	p = $.kbstep[$.currstep]
	if ( p != '' ) {
		realmidi(p,Now)
		# if ( Konnect != $0 )
		# 	Konnect.sendphrase(p)
	}
}

method restart {
	if ( $.startquant == -1 ) {
		lng = $.nsteps * $.stepsize
		starttm = nextquant(Now,lng)
	} else {
		starttm = nextquant(Now,$.startquant)
	}
	if ( $.beatid >= 0 )
		kill($.beatid)
	$.beatid = task $.task_kbbeat(starttm)
}

method setnsteps(ns) {
	$.nsteps = ns
	for ( sn=0; sn<ns; sn++ )
		$.kbstep[sn] = ''
}

method copytocell(fromcell) {
	ndrums = $.ndrums
	tocell = $.cell
	for ( sn=0; sn<$.nsteps; sn++ ) {
		if ( !(sn in fromcell) || !(sn in tocell) )
			continue
		for ( dn=0; dn<ndrums; dn++ ) {
			if ( !(dn in fromcell[sn]) || !(dn in tocell[sn]) )
				continue
			tocell[sn][dn] = fromcell[sn][dn]
		}
	}
}
method flashon { $.doflash = 1 }
method flashoff { $.doflash = 0 }
method setlayout(n) { $.layout = n; $.resize(); $.redraw() }
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
				"kb_mkmenu",$,dn,$.kbbuttmap,$.kbnotemap)
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
method setdrum (dn,nt,nm) {
	if ( nargs() < 3 )
		nm = ""
	if ( typeof(nt) == "phrase" ) {
		$.kbdrumnote[dn] = makenote(nt.pitch,
			$.stepsize,'a'.vol,nt.chan)
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
			if (  $.cell[sn][dn] != 0 ) {
				$.fillcell(sn,dn,FULLON,CLEAR)
				$.cell[sn][dn] = 0
				$.computestep(sn)
			}
		}
		nm = ""
	}
	else if ( nt == 5 ) {
		# delete

		# shift other drum rows down one
		for ( dn2=dn+1; dn2<$.ndrums; dn2++ ) {
			for ( sn=0; sn<$.nsteps; sn++ ) {
				$.cell[sn][dn2-1] = $.cell[sn][dn2]
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
			$.fillcell(sn,dn,FULLON,STORE)
			$.cell[sn][dn] = FULLON
			$.computestep(sn)
		}
		nm = ""
	}
	else if ( nt == 7 ) {
		# every other 8
		for ( sn=0; sn<$.nsteps; sn++ ) {
			if ( ((sn-4)%8) != 0 )
				continue
			$.fillcell(sn,dn,FULLON,STORE)
			$.cell[sn][dn] = FULLON
			$.computestep(sn)
		}
		nm = ""
	}
	else if ( nt == 8 ) {
		# half random
		for ( sn=0; sn<$.nsteps; sn++ ) {
			if ( rand(2) == 0 )
				continue
			$.fillcell(sn,dn,FULLON,STORE)
			$.cell[sn][dn] = FULLON
			$.computestep(sn)
		}
		nm = ""
	}
	else if ( nt == 9 ) {
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
method stop { $.b2.set(0); $.b2.redraw(); $.ison = 0 }
method on {
	$.ison = 1
	if ( $.beatid < 0 )
		$.restart()
	$.b2.set(1)
	$.b2.redraw()
}
method sync { $.currstep = 0 }
method play { $.on() }
method snarf { Snarf = $.get() }
method setinc (v) { $.inc = v }
method setonoff (v) { if ( v ) $.on(); else $.stop() }
method delete { if ( $.beatid >= 0 ) kill($.beatid) }
method bang { $.sync(); $.play(); $.nloops = 1 }

method resetbeatid() {
	$.beatid = -1
}

method task_kbbeat(starttm) {
	tm = starttm
	onexit(global(kb_beatend),$)
	$.currstep = 0
	while ( $.ison ) {
		p = $.kbstep[$.currstep]
		if ( p != '' ) {
			realmidi(p,tm)
			# if ( Konnect != $0 ) {
			# 	p.time += tm
			# 	Konnect.sendphrase(p)
			# }
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
			else
				task $.recomputeall()
		}
		sleeptill(tm-$.stepsize/3)
	}
	$.beatid = -1
}

}

function setupdrummaps() {
	if ( sizeof(Kb_names) == 0 ) {
		# NOTE: IF YOU ADD TO Kb_names, ADD AN ENTRY TO Kb_notes, TOO!
		Kb_names = [
			0="Use Rec'd Note/Chord",
			1="Use Rec'd Phrase",
			2="Use Snarf",
			3="Set Label",
			4="Clear",
			5="Delete",
			6="Every 8",
			7="Every other 8",
			8="Half Random",
			9="------------"
			]
		Kb_notes = [
			0=0,
			1=1,
			2=2,
			3=3,
			4=4,
			5=5,
			6=6,
			7=7,
			8=8,
			9=9
			]
		offset = sizeof(Kb_names)
		dm = drummap()
		dmsize = sizeof(dm)
		for ( n=0; n<dmsize; n++ ) {
			Kb_names[offset+n] = dm[n]["name"]
			Kb_notes[offset+n] = dm[n]["note"]
		}
	}
}

function kb_mkmenu(o,po,dn,dmap,dnote) {
	nm = sizeof(dmap)
	for ( n=0; n<nm; n++ ) {
		o.menucmd(dmap[n],po,"setdrum",dn,dnote[n],dmap[n])
	}
}


function mkmenu_kboom1(o,po) {
	o.menucmd("Snarf",po,"snarf")
	o.menucmd("Clear",po,"clearcells")
	# o.menucmd("Read Drumkit",po,"wkboomreadkit")
	o.submenu("Load Drums ->","mkmenu_kboomload",po)
	o.submenu("Step Size  ->","mkmenu_kboomstepsize",po)
	o.submenu("Start Quant->","mkmenu_kboomstartquant",po)
	# o.menucmd("Read File",po,"wkboomread")
	# o.menucmd("Write File",po,"wkboomwrite")
	o.submenu("Flash      ->","mkmenu_kboom2",po)
	o.submenu("Layout     ->","mkmenu_kboom2layout",po)
	o.submenu("Toggle Mode->","mkmenu_kboom3",po)
	o.submenu("Transpose  ->","mkmenu_kboomtrans",po)
	o.submenu("# of Steps ->","mkmenu_kboom4",po)
	o.submenu("# of Drums ->","mkmenu_kboom5",po)
	o.submenu("Shift      ->","mkmenu_kbshift",po)
	o.submenu("Random     ->","mkmenu_kbrand",po)
	# o.menucmd("Restart",po,"restart")
	o.submenu("Konnect    ->","mkmenu_kbkonnect",po)
}

function mkmenu_kbkonnect(o,po) {
	o.menucmd("Send On",po,"setkonnectsend",1)
	o.menucmd("Send Off",po,"setkonnectsend",0)
	o.menucmd("Receive On",po,"setkonnectreceive",1)
	o.menucmd("Receive Off",po,"setkonnectreceive",0)
}

function mkmenu_kboomstepsize(o,po) {
	o.menucmd("In Half",po,"setquanthalf",1)
	o.submenu("Set to ->","mkmenu_kboomquant",po)
}

function mkmenu_kboomquant(o,po) {
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

function mkmenu_kboomstartquant(o,po) {
	o.menucmd("Length of pattern",po,"setstartquant",-1)
	o.menucmd("1 click",po,"setstartquant",1)
	o.menucmd("1 beat",po,"setstartquant",1b)
	o.menucmd("2 beats",po,"setstartquant",2b)
	o.menucmd("4 beats",po,"setstartquant",4b)
	o.menucmd("8 beats",po,"setstartquant",8b)
}

function mkmenu_kbshift(o,po) {
	o.menucmd("1 >>>",po,"shift",-1)
	o.menucmd("4 >>>",po,"shift",-4)
	o.menucmd("<<< 1",po,"shift",1)
	o.menucmd("<<< 4",po,"shift",4)
}
function mkmenu_kbrand(o,po) {
	o.menucmd("Add 8",po,"addrand",8)
	o.menucmd("Add 16",po,"addrand",16)
	o.menucmd("Add 24",po,"addrand",24)
	o.menucmd("Add 32",po,"addrand",32)
}

function mkmenu_kboomload(o,po) {
	o.submenu("Add   ->","mkmenu_kboomread",po,0)
	o.submenu("Reset ->","mkmenu_kboomread",po,1)
}

function mkmenu_kboomread(o,po,reset) {
	o.menucmd("Drumkit (default)",po,"wkboomreadkitdefault",reset)
	o.menucmd("Drumkit from File",po,"wkboomreadkit",reset)
	o.submenu("Pitches and Timing ->","mkmenu_kboomreadpt",po,1,reset)
	o.submenu("Pitches only       ->","mkmenu_kboomreadpt",po,0,reset)
}

function mkmenu_kboomreadpt(o,po,pt,reset) {
	o.menucmd("From Snarf",po,"loadit",pt,1,reset)
	o.menucmd("From Recorded (2b space)",po,"loadit",pt,0,reset)
}

# function mkmenu_readsnarf(o,po) {
# 	o.menucmd("Use Pitches and Timing",po,"readsnarf",1)
# 	o.menucmd("Use Pitches only",po,"readsnarf",0)
# }

function mkmenu_kboomtrans(o,po) {
	o.menucmd("Immediate",po,"transposemode","immediate")
	o.menucmd("Next",po,"transposemode","next")
	o.menucmd("Reset",po,"settranspose",0)
}

function mkmenu_kboom3(o,po) {
	o.menucmd("On/Off",po,"setmode","binary")
	o.menucmd("Gradual",po,"setmode","gradual")
}

function mkmenu_kboom4(o,po) {
	ns = po.getnsteps()*2
	for ( n=1; n<=ns; n++ )
		o.menucmd(string(n),po,"setsteps",n)
}

function mkmenu_kboom5(o,po) {
	o.menucmd("Add 1",po,"changedrums",1)
	o.menucmd("Add 4",po,"changedrums",4)
	o.menucmd("Delete 1",po,"changedrums",-1)
	o.menucmd("Delete 4",po,"changedrums",-4)
}

function mkmenu_kboom2(o,po) {
	o.menucmd("On",po,"flashon")
	o.menucmd("Off",po,"flashoff")
}

function mkmenu_kboom2layout(o,po) {
	o.menucmd("1",po,"setlayout",1)
	o.menucmd("2",po,"setlayout",2)
}

function kb_beatend(o) {
	o.resetbeatid()
}
