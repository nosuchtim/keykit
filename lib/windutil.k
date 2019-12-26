
function waitup(f) {
	while ( (m=get(f)) != Eof ) {
		if ( m["button"] == 0 )
			break
	}
	return(m)
}

function waitdown(f) {
	while ( (m=get(f)) != Eof ) {
		if ( m["button"] != 0 )
			break
	}
	return(m)
}

function waitnsweep(o,type) {
	if ( nargs() < 2 ) {
		print("usage: waitnsweep(obj,type)")
		return()
	}
	setmouse(SWEEP)
	f = grabmousefifo()
	m = waitdown(f)
	s = o.sweep(f,type,m)
	ungrabmousefifo(f)
	return(s)
}

function xymid(sz) {
	return(xy((sz["x0"]+sz["x1"])/2,(sz["y0"]+sz["y1"])/2))
}

function wselect() {
	setmouse(CROSS)
	f = grabmousefifo()
	m = waitdown(f)
	o = Root.childunder(m)
	m = waitup(f)
	ungrabmousefifo(f)
	setmouse(ARROW)
	return(o)
}

function whelp() {
	o = wselect()
	if ( o == Root )
		mainhelp()
	else {
		cn = o.classof()
		toolhelp(cn)
	}
}

function drawx(s,mode) {
	Root.rectangle(s,mode)
	Root.line(xy(s["x0"],s["y0"],s["x1"],s["y1"]),mode)
	Root.line(xy(s["x0"],s["y1"],s["x1"],s["y0"]),mode)
}
function fillspace(s,wexisting,dir) {
	if ( nargs() != 3 ) {
		print("usage: fillspace(s,wexisting,dir)")
		return(s)
	}
	if ( Root.windowsover(s,wexisting) > 0 ) {
		print("fillspace: too many windows there!?")
		return(s)
	}
	ov = 0
	maxinc = 30
	xb = 3	# extra border to leave
	yb = 3
	dx = maxinc
	dy = maxinc
	drawx(s,XOR)
	while ( 1 ) {
		any = 0
		if ( dir!="y" && (s["x0"]-dx-xb) > Root.xmin()
			&& Root.windowsover(xy(s["x0"]-dx-xb,s["y0"],s["x1"],s["y1"]),wexisting) <= ov ) {
			drawx(s,XOR)
			s["x0"] -= dx
			drawx(s,XOR)
			any++
		}
		if ( dir!="x" && (s["y0"]-dy-yb) > Root.ymin()
			&& Root.windowsover(xy(s["x0"],s["y0"]-dy-yb,s["x1"],s["y1"]),wexisting) <= ov ) {
			drawx(s,XOR)
			s["y0"] -= dy
			drawx(s,XOR)
			any++
		}
		if ( dir!="y" && (s["x1"]+dx+xb) < Root.xmax()
			&& Root.windowsover(xy(s["x0"],s["y0"],s["x1"]+dx+xb,s["y1"]),wexisting) <= ov ) {
			drawx(s,XOR)
			s["x1"] += dx
			drawx(s,XOR)
			any++
		}
		if ( dir!="x" && (s["y1"]+dy+yb) < Root.ymax()
			&& Root.windowsover(xy(s["x0"],s["y0"],s["x1"],s["y1"]+dy+yb),wexisting) <= ov ) {
			drawx(s,XOR)
			s["y1"] += dy
			drawx(s,XOR)
			any++
		}
		if ( ! any ) {
			if ( dx == 1 && dy == 1 )
				break
			dx /= 2
			if ( dx < 1 )
				dx = 1
			dy /= 2
			if ( dy < 1 )
				dy = 1
			# keep going
		}
	}
	drawx(s,XOR)
	return(s)
}

function wresize() {
	o = wselect()
	if ( o == Root )
		return()
	sz = waitnsweep(Root,SWEEP)

	# Resizing a menu automatically makes it permanent
	if ( defined(o.classof) && o.classof() == "wmenu" )
		o.setpermanence(2)

	if ( (sz["x1"]-sz["x0"]) < Toosmallx
		|| ( (sz["y1"]-sz["y0"]) < Toosmally ) ) {
		sz = fillspace(sz,arraylist(o),"xy")
		if ( (sz["x1"]-sz["x0"]) < Toosmallx
			|| ( (sz["y1"]-sz["y0"]) < Toosmally ) ) {
			error("Swept window is too small!")
			return()
		}
	}
	o.erase()
	o.resize(sz)
	o.redraw()
}

# dir is either "x" or "y" or "xy"
function wmax(dir) {

	w = wselect()
	if ( w <= 0 )
		return()
	s = w.size()
	if ( Root.windowsover(s) != 1 ) {	# 1 for root
		print("Sorry, can't handle overlapped windows.")
		return()
	}
	w.erase()
	s = fillspace(s,arraylist(w),dir)
	w.resize(s)
	w.redraw()
}

#name	wdelete
#usage	wdelete()
#desc	This utility lets you point to and delete an object.

function wdelete() {
	o = wselect()
	if ( o == Root )
		return()
	if ( (!defined(Consoledelete) || Consoledelete==0)
		 && o.classof() == "wconsole" ) {
		print("Console cannot be deleted (unless Consoledelete is 1).")
	} else {
		Root.deletetool(o)
	}
}

function wswap() {
	print("Point to the two windows you want to swap...")
	o1 = wselect()
	if ( o1 == Root ) {
		print("Window swap aborted!")
		return()
	}
	for ( o2=o1; o2==o1; ) {	# make sure it's a different window 
		o2 = wselect()
		if ( o2 == Root ) {
			print("Window swap aborted!")
			return()
		}
	}
	sz1 = o1.size()
	sz2 = o2.size()
	o1.erase()
	o2.erase()
	o1.resize(sz2)
	o2.resize(sz1)
	o1.redraw()
	o2.redraw()
}

function wcopy() {
	o1 = wselect()
	if ( o1 == Root ) {
		print("Window copy aborted!")
		return()
	}
	for ( o2=o1; o2==o1; ) {	# make sure it's a different window 
		o2 = wselect()
		if ( o2 == Root ) {
			print("Window copy aborted!")
			return()
		}
	}
	if ( o1.classof() != o2.classof() ) {
		if ( ! defined(o1.get) )
			print("Hey, object class '"+o1.classof()+"' doesn't have a 'get' method!")
		else if ( ! defined(o2.set) )
			print("Hey, object class '"+o2.classof()+"' doesn't have a 'set' method!")
		else {
			d1 = o1.get()
			o2.set(d1)
		}
	}
	else {
		if ( ! defined(o1.dump) )
			print("Hey, object class '"+o1.classof()+"' doesn't have a 'dump' method!")
		else if ( ! defined(o2.restore) )
			print("Hey, object class '"+o2.classof()+"' doesn't have a 'restore' method!")
		else {
			d1 = o1.dump()
			o2.restore(d1)
		}
	}
	o2.erase()
	o2.resize()
	o2.redraw()
}

function wsnarf() {
	o1 = wselect()
	if ( o1 == Root ) {
		print("Window snarf aborted!")
		return()
	}
	if ( ! defined(o1.get) )
		print("Hey, object class '"+o1.classof()+"' doesn't have a 'get' method!")
	else {
		d1 = o1.get()
		if ( typeof(d1) != "phrase" )
			print("Hey, a 'get' on that tool didn't get a phrase!?")
		else {
			Snarf = d1;
			print("Snarfed a phrase of",sizeof(Snarf),"notes.")
		}
	}
}

function wsnarftool() {
	o1 = wselect()
	if ( o1 == Root ) {
		print("Window snarf aborted!")
		return()
	}
	if ( ! defined(o1.dump) )
		print("Hey, object class '"+o1.classof()+"' doesn't have a 'dump' method!")
	else {
		d1 = o1.dump()
		if ( typeof(d1) != "array" )
			print("Hey, a 'dump' on that tool didn't get an array!?")
		else {
			Snarftooldump = d1;
			Snarftoolclass = o1.classof()
			print("Snarfed the ",Snarftoolclass," tool.")
		}
	}
}

function wpastetool() {
	if ( ! defined(Snarftoolclass) || Snarftoolclass=="" ) {
		print("You need to use Snarf Tool first!")
		return()
	}
	sz = waitnsweep(Root,SWEEP)
	tf = efunction(Snarftoolclass)
	o = new tf(...)
	Root.addtool(o,sz)
	o.restore(Snarftooldump)
	Root.redraw()
}
function wmove(o,m,eraseit) {

	setmouse(CROSS)
	f = grabmousefifo()

	if ( nargs() < 2 ) {
		m = waitdown(f)
		o = Root.childunder(m);
		if ( o == Root ) {
			ungrabmousefifo(f)
			setmouse(ARROW)
			return()
		}
	}

	wmx = m["x"]
	wmy = m["y"]

	# Moving a menu automatically makes it permanent
	if ( o.classof() == "wmenu" )
		o.setpermanence(2)

	s = o.size()
	if ( nargs() < 3 || eraseit!=0 ) {
		o.erase()
	}
	Root.rectangle(s,XOR)
	while ( 1 ) {
		m = get(f)
		if ( m["button"] == 0 )
			break
		wmx2 = m["x"]
		wmy2 = m["y"]
		dx = wmx2 - wmx
		dy = wmy2 - wmy
		if ( (s["x0"]+dx)<0 )
			dx = -s["x0"]
		if ( (s["y0"]+dy)<0 )
			dy = -s["y0"]
		if ( (s["x1"]+dx)>Root.xmax() )
			dx = Root.xmax() - s["x1"]
		if ( (s["y1"]+dy)>Root.ymax() )
			dy = Root.ymax() - s["y1"]

		wmx2 = dx + wmx		# in case dx or dy is changed
		wmy2 = dy + wmy

		Root.rectangle(s,XOR)
		s["x0"] += dx
		s["y0"] += dy
		s["x1"] += dx
		s["y1"] += dy
		Root.rectangle(s,XOR)
		wmx = wmx2
		wmy = wmy2
	}
	Root.rectangle(s,XOR)
	s = fit2root(s)
	o.resize(s)
	o.redraw()

	ungrabmousefifo(f)
	setmouse(ARROW)
}

function sweeptool(toolfunc,...) {
	sz = waitnsweep(Root,SWEEP)
	if ( (sz["x1"]-sz["x0"]) < Toosmallx ) {
		sz = fillspace(sz,[],"xy")
		if ( (sz["x1"]-sz["x0"]) < Toosmallx )
			error("Swept window is too small!")
	}
	tf = efunction(toolfunc)
	o = new tf(...)
	if ( typeof(o) != "object" )
		error("sweeptool didn't get an object from toolfunc!?")
	Root.addtool(o,sz)
	o.redraw()
	return(o)
}

function wshowdump() {
	o = wselect()
	if ( o == Root ) {
		print("Window dump aborted!")
		return()
	}
	d = o.dump()
	print("Dump =",d)
}

function wbroadcast() {
	o = wselect()
	if ( o == Root ) {
		print("Window broadcast aborted!")
		return()
	}
	if ( Konnect != $0 )
		Konnect.sendtool(o)
}

function wdump() {
	o = wselect()
	if ( o == Root ) {
		print("Window dump aborted!")
		return()
	}
	if ( ! defined(o.dump) ) {
		print("There's no dump method for that object!?")
		return()
	}
	fname = browsefiles("Any File (*.*)","*.*",0)
	if ( fname == "" )
		print("No file named, no dump.")
	else {
		s = o.dump()
		f = open(fname,"w")
		put(f,"State=(")
		put(f,string(s))
		put(f,");\n")
		close(f)
		print("That '"+o.classof()+"' has been written to '"+fname+"'.")
	}
}

function wrestore() {
	o = wselect()
	if ( o == Root )
		return()
	if ( ! defined(o.restore) ) {
		print("There's no restore method for that object!?")
		return()
	}
	fname = browsefiles("Any File (*.*)","*.*",1)
	if ( fname == "" )
		print("No file named, no dump.")
	else {
		State = 0
		eval "#include \""+string(fname)+"\""
		if ( typeof(State) != "array" ) {
			print("Hey, file '"+fname+"' doesn't contain a State array!?")
		}
		else {
			o.restore(State)
			print("That '"+o.classof()+"' has been restored from '"+fname+"'.")
		}
	}
}

#name	grabmouse
#usage	grabmouse()
#desc	This function arranges for all mouse messages to be intercepted and
#desc	sent to a particular window, rather than being routed to the windows
#desc	underneath the mouse.  When you want to restore things to normal,
#desc	call ungrabmouse().

function grabmouse(w) {
	if ( nargs() != 1 )
		error("Bad usage of grabmouse()!  Expects argument!")

	if ( Mousegrabwind != -1 ) {
		if ( ! defined(Mousegrabwind) )
			print("Hey, Mousegrabwind is undefined!?")
		else
			print("Hey, Mousegrabwind is defined... =",Mousegrabwind)
			# print("Hey, Mousegrabwind=",Mousegrabwind," in grabmouse() Traceback = ",taskinfo(gettid(),"fulltrace"))
	}
	Mousegrabwind = w
	return(Mousegrabwind)
}
#name	ungrabmouse
#usage	ungrabmouse(w)
#desc	This is the complement to grabmouse(), releasing the mouse so that
#desc	mouse events are distributed normally.  The w (window) argument
#desc	should be the same as that passed to grabmouse().

function ungrabmouse(w) {
	if ( w >= 0 ) {
		if ( w != Mousegrabwind ) {
			print("Hey, w (",w,") != Mousegrabwind (",
				Mousegrabwind,") in ungrabmouse!?")
			# fulltrace()
		}
		Mousegrabwind = -1
	}
}
#name	grabmousefifo
#usage	grabmousefifo()
#desc	This function arranges for all mouse messages to be intercepted and
#desc	sent to a new fifo, rather than being routed to the windows underneath
#desc	the mouse.  The fifo id of this new fifo is returned as the value
#desc	of grabmousefifo().  When you want to restore things to normal,
#desc	call ungrabmousefifo().

function grabmousefifo() {
	if ( Mousegrabfifo != -1 ) {
		print("Hey, Mousegrabfifo=",Mousegrabfifo," in grabmousefifo() Traceback = ",taskinfo(gettid(),"fulltrace"))
	}
	Mousegrabfifo = open()
	return(Mousegrabfifo)
}
#name	ungrabmousefifo
#usage	ungrabmousefifo(fifo)
#desc	This is the complement to grabmouse(), releasing the mouse so that
#desc	mouse events are distributed normally.  The fifo argument should be
#desc	the fifo that was created and returned by grabmouse().

function ungrabmousefifo(f) {
	if ( f >= 0 ) {
		if ( f != Mousegrabfifo )
			print("Hey, f!=Mousegrabfifo in ungrabmousefifo!?  f=",f,"  Mousegrabfifo=",Mousegrabfifo)
		Mousegrabfifo = -1
		close(f)
	}
}

function fit2root(sz) {
	if ( sz["x1"] > Root.xmax() ) {
		dx = sz["x1"] - Root.xmax() + 1
		sz["x0"] -= dx
		sz["x1"] -= dx
	}
	if ( sz["y1"] > Root.ymax() ) {
		dy = sz["y1"] - Root.ymax() + 1
		sz["y0"] -= dy
		sz["y1"] -= dy
	}
	if ( sz["x0"] < Root.xmin() )
		sz["x0"] = Root.xmin()
	if ( sz["y0"] < Root.ymin() )
		sz["y0"] = Root.ymin()
	return(sz)
}

function areacontains(area,pt) {
	x = pt["x"]
	y = pt["y"]
	if ( x >= area["x0"] && x <= area["x1"] && y >= area["y0"] && y <= area["y1"] )
		return(1)
	else
		return(0)
}
