class wphrase {
method init {

	$.w = new window("phrase")
	$.inherit($.w)

	$.stoptids = []
	$.buttontype = [1=LEFTRIGHT,2=LEFTRIGHT]
	$.buttonmeth = [1="",2=""]
	$.mfifo = -1
	$.notifyobj = $0
	$.playing = 0
	$.w.trackname(uniqtrackname())
	$.set('')
	$.redraw()
	$.anytools = 0
	$.flashtid = -1
	Wphrase[$.w.trackname()] = $
}

method redraw() {
	if ( $.isvisible() == 0 )
		return()
	if ( $.anytools ) {
		# Make sure the vertical view is maximized
		v = $.view()
		# don't redraw if already there
		if ( v["y0"] != 0 || v["y1"] != 127 )
			$.view(xy(v["x0"],0,v["x1"],127))

		# erase the window
		$.w.fillrectangle($.size(),CLEAR)
		$.w.rectangle($.size(),STORE)

		# normally, redrawing a phrase window will redraw
		# the phrase in it (this is built into the built-in
		# phrase window object), but the built-in phrase window
		# doesn't know anything about tools, so we do it
		# ourselves.  Actually, I think maybe the built-in
		# phrase window shouldn't know anything about the
		# phrases that are in it, and we should explicitly
		# draw the phrase all the time.  This would mean
		# that the built-in phrase window would only be
		# doing "scaling/view" operations.  Sounds good (someday).
		tname = $.w.trackname()
		p = Track[tname]
		$.drawphrase(p,STORE)
	} else {
		tname = $.w.trackname()
		if ( ! (tname in Track) ) {
			print("wphrase ",$,", track ",tname," no longer exists")
		} else {
			$.w.redraw()
		}
	}
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
}

method drawphrase(p,mode) {

	tnotes = toolnotes(p)
	p -= tnotes

	# Draw the non-tool notes
	if ( nargs() < 2 )
		mode = STORE
	$.w.drawphrase(p,mode)

	# Draw the tool notes
	for ( nt in tnotes ) {
		$.drawtool(nt,mode)
	}
}

method isvisible() {
	sz = $.size()
	if ( sz["x0"]!=0 || sz["x1"]!=0 || sz["y0"]!=0 || sz["y1"]!=0 )
		return(1)
	else
		return(0)
}

method drawtool(nt,mode) {

	h = note2holder(nt)
	if ( h == $0 || h == $-1 ) {
		print("holder for note: ",nt," has disappeared")
		return()
	}

	spx0 = nt.time
	# if the tool class has a scaleable method, the tool
	# is scaled to the duration of the note, otherwise
	# the duration of the current contents of the tool
	# determines the size of the tool.
	if ( h.scaleit() ) {
		tooldur = nt.dur
	} else {
		tp = h.getaudition()
		tooldur = tp.length
	}
	if ( tooldur == 0 )
		tooldur = 1b
	spx1 = nt.time + tooldur

	vw = $.w.view()
	vwx0 = vw["x0"]
	vwx1 = vw["x1"]

	# If it's completely out of the view, draw nothing
	if ( spx1 < vwx0 || spx0 > vwx1 )
		return()

	y0 = $.ymin()+1
	y1 = $.ymax()-1

	# If it's completely visible, draw it
	if ( spx0 >= vwx0 && spx1 <= vwx1 ) {

		# MUST make sure that tool is resized properly,
		# because the view of the window may have changed
		span = $.scaletowind(xy(spx0,0,spx1,0))
		xyarr = xy(span["x0"],y0,span["x1"],y1)

		h.resize(xyarr)

		if ( mode == CLEAR ) {
			$.fillrectangle(xyarr,CLEAR)
		}
		else {
			if ( nt.flags == 1 )
				colorset(2)
			h.redraw()
			if ( nt.flags == 1 )
				colorset(1)
		}
		return()
	}
	# Off the left edge
	name = h.gettoolname()
	if ( spx0 < vwx0 ) {
		xyarr = xy(vwx0,vw["y0"],spx1,vw["y1"])
		$.drawtoolrange(xyarr,mode,name)
		return()
	}
	# Off the right edge
	if ( spx1 > vwx1 ) {
		xyarr = xy(spx0,vw["y0"],vwx1,vw["y1"])
		$.drawtoolrange(xyarr,mode,name)
		return()
	}
	print("wtools: this shouldn't happen")
}

method drawtoolrange(span,mode,name) {

	y0 = $.ymin()+1
	y0a = $.ymin()+$.textheight()+1
	y1 = $.ymax()-1

	sp = $.scaletowind(span)
	x0 = sp["x0"]
	x1 = sp["x1"]
	xyarr = xy(x0,y0,x1,y1)

	if ( mode == CLEAR ) {
		$.fillrectangle(xyarr,CLEAR)
		return()
	}

	# just put "Tool" in the area
	if ( nargs() < 3 )
		name = "Tool"
	$.w.text(name,xy(x0,y0,x1,y0a),mode)
	$.w.line(xy(x0,y0a+1,x1,y0a+1),mode)
	left = xy(x0,y0,x0,y1)
	$.line(left,mode)
	right = xy(x1,y0,x1,y1)
	$.line(right,mode)
}

method setflags(f) {
	# Changing the flags can never change the tools themselves,
	# so we don't need to do a toolscan.
	Track[$.w.trackname()].flags = f
}

method clearpick() {
	$.setflags(0)
}

method setchan(cn) {
	# Changing the channel can never change the tools themselves,
	# so we don't need to do a toolscan.
	Track[$.w.trackname()].chan = cn
}

method setport(pn) {
	# Changing the channel can never change the tools themselves,
	# so we don't need to do a toolscan.
	Track[$.w.trackname()].port = pn
}

method inholder(m,scaleit) {
	if ( nargs() < 2 || scaleit!=0 )
		m2 = $.scaletogrid(m)
	else
		m2 = m
	phr = $.gettoolnotes()
	ret = ''
	for ( nt in phr ) {
		x0 = nt.time
		x1 = nt.time + nt.dur
		if ( m2["x"] >= x0 && m2["x"] <= x1 )
			ret = nt
	}
	return(ret)
}

method isvisible(nt) {

	vw = $.w.view()
	spx0 = nt.time
	spx1 = nt.time + nt.dur
	vwx0 = vw["x0"]
	vwx1 = vw["x1"]

	# It's completely visible...
	if ( spx0 >= vwx0 && spx1 <= vwx1 )
		return(1)
	else
		return(0)
}

method hastools() {
	return($.anytools)
}

method mousedown (m) {

	b = m["button"]
	if ( b != 1 && b != 2 )
		error("unexpected b="+string(b)+" in wphrase.mousedown!?")

	if ( $.anytools ) {
		# see if it's within an existing tool
		tnt = $.inholder(m)
		if ( tnt != '' ) {
			h = note2holder(tnt)
			isowner = h.getisowner()
			# If the toolholder owns the tool and it's not
			# completely visible, then the tool isn't really
			# usable, so we don't even forward the mouse.
			if ( isowner && $.isvisible(tnt) == 0 ) {
				# print("Tool not completely visible")
				return()
			}

			# If we're in a toolholder, and getting button 1,
			# we forward the mouse event to it.

			# NOW we forward all buttons to it.
			# if ( b == 1 ) {
				mouseforward(m,"mousedown")
				return()
			# }
		}
	}

	if ( $.notifyobj != $0 && $.notifyobj != $-1 ) {
		st = $.buttontype[b]
		meth = $.buttonmeth[b]
		if ( st == POINT )
			$.notifyobj.(meth)($,$.scaletogrid(m),m)
		else {
			grabmouse($)
			$.mfifo = f = open()
			task $.task_mousedown(f,st,m,meth)
		}
	}
}

method mousedrag(m) {
	f = $.mfifo
	if ( f >= 0 )
		put(f,m)
	else {
		mouseforward(m,"mousedrag")
	}
}
method mouseup(m) {
	f = $.mfifo
	if ( f >= 0 ) {
		put(f,m)
		close(f)
		$.mfifo = -1
		setmouse(ARROW)
		ungrabmouse($)
	}
	else {
		mouseforward(m,"mouseup")
	}
}
method setbuttontype(st,b,meth) {
	if ( b != 1  && b != 2 )
		error("Bad value of b in .setbuttontype")
	$.buttontype[b] = st
	$.buttonmeth[b] = meth
}
method flashnotes(...) {
	$.flashtid = task $.task_flashnotes(...)
	$.stoptids[tid] = 1
	return($.flashtid)
}
method killflashnotes() {
	if ( $.flashtid > 0 ) {
		kill($.flashtid)
		$.flashtid = -1
	}
}
method play(...) {
	tid = task $.task_play(...)
	$.stoptids[tid] = 1
	return(tid)
}
method stop {
	killtids($.stoptids)
	$.stoptids = []
	$.playing = 0
}
method endplay {
	if ( $.playing ) {
		$.playing = 0
		kill($.tid1)
		if ( $.tid2 > 0 )
			kill($.tid2)
	}
}
method delete {

	# We want the set method to be the only one that
	# manipulates the tools (toolscan), so we do this.
	$.set('',0)

	delete Wphrase[$]
	killtids($.stoptids)
	$.stoptids = []
	tname = $.w.trackname()
	p = Track[tname]
	delete Track[tname]
}

method gettoolnotes() {
	return(toolnotes($.get()))
}

# Except for the setting of channels and flags, this is
# the ONLY place (I think...) where the phrase in a phrase
# window is modified.  This is important, so we can put
# all the hooks for tool manipulation here.

method set(phr,dodraw) {

	if ( nargs() < 2 )
		dodraw = 0

	# If there are any existing tool notes, see if the new phrase
	# has them.  If it doesn't, then remove them as children.

	tonotify = []
	ww = $.w
	tname = ww.trackname();
	oldphr = Track[tname]

	oldtnotes = toolnotes(oldphr)

	Track[$.w.trackname()] = phr

	if ( sizeof(toolnotes(phr)) > 0 )
		$.anytools = 1
	else
		$.anytools = 0

	# toolscan will make sure that each tool
	# is owned by a toolholder (in case the
	# original owning-toolholder has been deleted).
	# It will also make separate holders for any holders that
	# are duplicated.
	# We only need to do this if the old phrase had tools, or we now
	# have tools.

	if ( sizeof(oldtnotes) > 0 || $.anytools != 0 ) {

	# Go through all the Track, and make sure that for all
	# the tools mentioned, there's at least one (and only one)
	# toolholder that owns it.
	owner = []		# index is toolname, value is toolholder
	unowned = []		# index is toolname
	holderseen = []		# index is holder

	# First go through the toolholders that aren't embedded in phrases.
	# These are the ones that are children of Root.  We assume there
	# are no duplicates (e.g. two owners of the same toolname)
	for ( h in Root.children() ) {
		if ( h in Holder_obj2name ) {
			toolname = h.gettoolname()
			isowner = h.getisowner()
			if ( isowner )
				owner[toolname] = h
			else {
				unowned[toolname] = h
			}
		}
	}

	# Now go through all the tracks and make sure there aren't
	# multiple identical holders, and make sure each tool has 1 owner

	for ( n in Track ) {

		if ( n == tname )
			continue

		if ( n in Wphrase )
			wphr = Wphrase[n]
		else {
			# Might be useful to remove entries from Track
			# that aren't in Wphrase?
			continue
		}

		trkphr = Track[n]
		tnts = toolnotes(trkphr)
		for ( nt in tnts ) {
			h = note2holder(nt)
			if ( h == $0 || h == $-1 ) {
				print("note2holder of nt=",nt," produced ",h," ??")
				continue
			}

			if ( h in holderseen ) {
print("HEY THIS SHOULDN'T HAPPEN!!!!! (h in holderseen in wphrase)")
			}

			holderseen[h] = 1
			# h is the toolholder
			tool = h.gettool()
			toolname = h.gettoolname()
			isowner = h.getisowner()
			alreadyowned = (toolname in owner)
			if ( isowner && alreadyowned ) {
print("HEY THIS SHOULDN'T HAPPEN TWOOOOO!!!!! (isowner in wphrase)")
			} else if ( isowner ) {
				# record info about the tool and its holder
				owner[toolname] = h
			} else if ( ! alreadyowned ) {
				# Record it to make sure there's
				# at least one owner at the end.
				unowned[toolname] = h
			}
		}
	}

	# Now do the track we're currently changing
	n = tname

	wphr = Wphrase[n]

	trkphr = Track[n]
	tnts = toolnotes(trkphr)
	anychange = 0
	for ( nt in tnts ) {
		h = note2holder(nt)
		if ( h == $0 || h == $-1 ) {
			print("note2holder of nt=",nt," produced ",h," ??")
			continue
		}

		if ( h in holderseen ) {

			# create a copy of the holder

			toolname = h.gettoolname()

			newholder = new toolholder(h.getnotifyobj())

			if ( toolname != "" )
				newholder.settoolreference(toolname)
			newnt = makeholdernote(nt.time,nt.time+nt.dur,newholder)
			# Make the the flags (pick) get copied
			newnt.flags = nt.flags

			# Remove the original note and add
			# the new one with the new holder
			trkphr -= nt
			trkphr |= newnt
			anychange = 1
			h = newholder
		}

		holderseen[h] = 1
		# h is the toolholder
		tool = h.gettool()
		toolname = h.gettoolname()
		if ( toolname == "" )
			continue
		isowner = h.getisowner()
		alreadyowned = (toolname in owner)
		if ( isowner && alreadyowned ) {
			print("tool=",tool," name=",toolname," already had an owner!")

			# We want to create a new toolholder and
			# replace the original toolholder.  The
			# notifyobj and the tool of the new toolholder 
			# should be the same, but the new toolholder
			# will NOT own the tool
			newholder = new toolholder(h.getnotifyobj())
			newholder.settoolreference(toolname)
			newnt = makeholdernote(nt.time,nt.time+nt.dur,newholder)
			# Remove the original note and add
			# the new one with the new holder
			trkphr -= nt
			trkphr |= newnt
			anychange = 1

		} else if ( isowner ) {
			# record info about the tool and its holder
			owner[toolname] = h
		} else if ( ! alreadyowned ) {
			# Record it to make sure there's
			# at least one owner at the end.
			unowned[toolname] = h
		}
	}

	if ( anychange ) {
		Track[n] = trkphr
		tonotify[h] = 1
	}

	if ( Readingpage == 0 ) {
	for ( tname in unowned ) {
		if ( ! ( tname in owner ) ) {
			# Let the last toolholder take it over
			h = unowned[tname]
			if ( ! ( tname in Tool ) ) {
				print("tname=",tname," not in Tool!?")
				continue
			}
			h.settool(Tool[tname])
			# print("UNOWNED TOOL is being taken over by h=",h," Tool[tname=",tname,"=",Tool[tname])
			tonotify[h] = 1
		}
	}
	}

	}

	#############
	# NOW go through and get the children right
	#############

	# It's important that we get all the duplicates removed and
	# make sure there's one owner, before doing any children-related stuff.

	newtnotes = toolnotes(Track[$.w.trackname()])

	# This is awkward
	oldtnotes.time = 0
	oldtnotes.dur = 0
	oldtnotes.length = 0
	oldtnotes.vol = 0
	oldtnotes.flags = 0
	newtnotes.time = 0
	newtnotes.dur = 0
	newtnotes.length = 0
	newtnotes.vol = 0
	newtnotes.flags = 0

	removetools = oldtnotes - newtnotes

	for ( nt in removetools ) {
		h = note2holder(nt)
		$.removechild(h)
		nm = Holder_obj2name[h]

		h.giveback(0)
		deleteobject(h)
	}

	reallynew = newtnotes - oldtnotes

# print("reallynew = ",reallynew)

	if ( sizeof(reallynew) > 0 ) {

		# For any really new tools in this phrase, we need to make
		# sure that the toolholders are children of the phrase,
		# AND that the phrase is the notifyobj of the toolholder

		ch = $.children()
		for ( nt in reallynew ) {
			h = note2holder(nt)
			if ( ! (h in ch) ) {
				if ( h == $0 || h == $-1 ) {
					print("Holder for track (nt=",nt,") has disappeared")
				} else {
					$.addchild(h)
					h.setnotify($)
				}
			}
		}
	}

	for ( h in tonotify ) {
		h.notifyofchange($)
	}

	# The wphrase object used to redraw automatically when it
	# was set (with no args).  This was wrong, and I've removed that
	# behaviour.  It's possible that other tools will need to take
	# this change into account, if they assumed that the phrase
	# was redrawn automatically.
	
	if ( dodraw == 1 )
		$.redraw()
}

method untoolholder(hname) {
	tname = $.w.trackname()
	p = Track[tname]
	tnts = toolnotes(p)
	for ( nt in tnts ) {
		h = note2holder(nt)
		if ( h.getholdername() == hname ) {
			tp = h.getaudition(nt.dur)
			if ( h.scaleit() != 0 && tp.length != nt.dur )
				tp = scaleng(tp,nt.dur)
			tp.time += nt.time
			p -= nt
			p |= tp
		}
	}
	$.set(p)
	$.dozoomout(1,"y")
	$.ihavechanged(1)
	$.redraw()
}

method transpose(v) {
	p = $.get()

	# We don't want to transpose "tool" notes
	tnotes = toolnotes(p)
	p -= tnotes
	p.pitch += v
	p |= tnotes
	$.set(p)
}
method setnotify(o) { $.notifyobj = o }
method getaudition(tm0,tm1) {
	phr = Track[$.w.trackname()]
	if ( nargs() == 0 ) {
		tm0 = -MAXCLICKS
		tm1 = MAXCLICKS
		# Leave the phrase alone - we want the whole thing
	} else {
		phr = cut(phr,CUT_TIME,tm0,tm1)
	}
	if ( ! $.anytools )
		return(phr)
	tnotes = toolnotes(phr)
	phr -= tnotes
	for ( nt in tnotes ) {
		tm = nt.time
		dx = nt.dur
		# If the tool isn't within the requested time range,
		# don't even bother asking it
		if ( tm > tm1 || (tm+dx) < tm0 )
			continue
		h = note2holder(nt)
		if ( h == $0 || h == $-1 ) {
			print("wphrase, getaudition, h==$0 ?")
			continue
		}
		p = h.get(dx)
		p.attrib = ""
		if ( sizeof(p) == 0 )
			continue

		# If the tool didn't create a result of the requested length
		# then we scale the result ourselves.  This allows existing
		# tools (that don't pay attention to the get() parameter)
		# to be used unchanged.
		if ( h.scaleit() != 0 && p.length != dx )
			p = scaleng(p,dx)

		p.time += nt.time
		phr |= p
	}
	return(phr)
}
method get {
	# It's important that this return the raw phrase, including
	# any "tool" notes in their raw form (not expanded).
	# This is not the phrase that should used
	# for auditioning things - use getaudition() for that.
	return(Track[$.w.trackname()])
}
method isplaying { return($.playing) }
method fitall { $.dozoomout(1,"xy") }
method forceview (x0,x1) {
	$.dozoomout(0,"y")
	sz = ["x0"=x0,"x1"=x1]
	$.viewset(sz,"x","no")
}
method flash (p) { return(task $.task_flashphrase(p)) }
method viewset (sz,dir,notif) {
	v = $.view()
	if ( nargs() < 2 )
		dir = "xy"
	if ( nargs() < 3 )
		notif = "no"
	if ( dir != "y" ) {
		v["x0"] = sz["x0"]
		v["x1"] = sz["x1"]
	}
	if ( dir != "x" ) {
		v["y0"] = sz["y0"]
		v["y1"] = sz["y1"]
	}
	$.view(v)
	if ( dir!="y" && notif == "yes" && $.notifyobj != $0 && $.notifyobj != $-1 ) {
		$.notifyobj.viewchanged(v)
	}
}
method viewshift(xdiff,ydiff) {
	v = $.view()
	v["x0"] -= xdiff
	v["x1"] -= xdiff
	if ( (v["y0"]-ydiff) < 0 )
		ydiff = v["y0"]
	if ( (v["y1"]-ydiff) > 127 )
		ydiff = v["y1"]-127
	v["y0"] -= ydiff
	v["y1"] -= ydiff
	$.view(v)
}

method fitvert {
	v = $.view()
	g = cut($.get(),CUT_TIME,v["x0"],v["x1"])
	if ( sizeof(g) == 0 )
		return()
	lim = limitsof(g)
	gy0 = lim["lowest"] - 4	# extra breathing room
	if ( gy0 < 0 )
		gy0 = 0
	gy1 = lim["highest"] + 4	# extra breathing room
	if ( gy1 > 127 )
		gy1 = 127

	v = xy(v["x0"],gy0,v["x1"],gy1)
	$.viewset(v,"y","yes")
}

method fullvert {
	v = $.view()
	# don't redraw if already there
	if ( v["y0"] == 0 && v["y1"] == 127 )
		return()
	$.view(xy(v["x0"],0,v["x1"],127))
	$.redraw()
}

method task_mousedown(f,st,m,meth) {
	if ( st == INVOKE ) {
		$.notifyobj.(meth)($,m)
		waitup(f)
	}
	else if ( st == CLOSEST ) {
		p = $.closestnote(m)
		if ( p != '' )
			$.notifyobj.(meth)($,p)
		waitup(f)
	}
	else if ( st == DRAG ) {
		setmouse(LEFTRIGHT)
		$.brushnotify(f,m,meth,0)
	}
	else if ( st == BRUSH ) {
		setmouse(LEFTRIGHT)
		$.brushnotify(f,m,meth,1)
	}
	else if ( st == DRAW ) {
		setmouse(ARROW)
		$.brushnotify(f,m,meth,0)
	}
	else if ( st == LEFTRIGHT ) {
		v = $.sweep(f,st,m)
		$.notifyobj.(meth)($,v)
	}
	else if ( st == UPDOWN ) {
		v = $.sweep(f,st,m)
		$.notifyobj.(meth)($,v)
	}
	else {
		error("task_mousedown, unknown st="+string(st))
	}
}

method task_play(stime,qnt,dosync,stopifplaying) {
	if ( nargs() < 1 )
		stime = Now
	if ( nargs() < 2 )
		qnt = Playquant
	if ( nargs() < 3 )
		dosync = 1
	if ( nargs() < 4 )
		stopifplaying = 1
	p = $.get()
	if ( sizeof(p) <= 0 ) {
		# Since this is used by many other objects, complaining is
		# not the best default behaviour.
		# print("No phrase to play !?")
		return()
	}
	# Figure out when it'll start.
	if ( qnt > 1 )
		stime = nextquant(stime,qnt)
	if ( dosync )
		tmppick = syncphr(p)
	else
		tmppick = p

	# stop it if it's already going
	if ( stopifplaying && $.playing ) {
		$.endplay()
	}

	# Get realtime MIDI output going right away
	$.tid1 = realmidi(tmppick,stime)

	$.lastplay = stime
	$.playing = 1

	etime = stime + (latest(p)-p%1.time) + tmppick%1.time

	$.playoffset = (p%1).time - (tmppick%1).time

	# Arrange for flashing the notes.
	if ( Phraseflashnotes == 1 )
		$.tid2 = $.flashnotes(p,stime,$.playoffset)
	else
		$.tid2 = -1

	if ( ! stopifplaying )
		return()

	onexit(global(domethod),$,"endplay")
	wait($.tid1)
	$.endplay()
}

method dozoomout(fity,dir) {
	g = $.get()
	lim = limitsof(g)
	if ( sizeof(g)==0 || sizeof(lim)==0 )
		return()
	gx0 = lim["earliest"]
	gx1 = lim["latest"]
	if ( ! fity ) {
		gy1 = 127
		gy0 = 0
	}
	else {
		gy0 = lim["lowest"] - 4	# extra room
		if ( gy0 < 0 )
			gy0 = 0
		gy1 = lim["highest"] + 4	# extra room
		if ( gy1 > 127 )
			gy1 = 127
	}

	# provide some extra breathing room
	xinc = (gx1 - gx0)/16
	gx0 -= xinc
	gx1 += xinc

	$.viewset(xy(gx0,gy0,gx1,gy1),dir,"yes")
}

method fitexact() {
	g = $.get()
	lim = limitsof(g)
	if ( sizeof(g)==0 || sizeof(lim)==0 )
		return()
	gx0 = lim["earliest"]
	gx1 = lim["latest"]
	gy0 = lim["lowest"] - 1
	if ( gy0 < 0 )
		gy0 = 0
	gy1 = lim["highest"]
	if ( gy1 > 127 )
		gy1 = 127
	$.viewset(xy(gx0,gy0,gx1,gy1),"xy","no")
}

method task_flashphrase(p) {
	$.drawphrase(p,CLEAR)
	millisleep(200)
	$.drawphrase(p,STORE)
}

method task_flashnotes(ph,stime,offset) {
	off = stime - offset
	if ( typeof(ph) != "phrase" ) {
		# print("Hey, ph=",ph," isn't a phrase? in task_flashnotes")
		return()
	}
	for ( n in ph ) {
		# Might want to make this selectable, for slow machines.
		# if ( n.type != NOTE )
		# 	continue
		if ( (tm = n.time + off) > Now )
			sleeptill(tm)
		$.drawphrase(n,CLEAR)
		# The extra 4 here is mainly for 0-duration things like
		# pitch bends and stuff.
		if ( Flashquick ) {	# do NOT remove curly braces!
			task $.undrawnextnote(n,tm+12)
		}
		else {	# do NOT remove curly braces - grammar is faulty!!
			task $.undrawnextnote(n,tm+n.dur+4)
		}
	}
}
method undrawnextnote(nt,tm) {
	onexit(global(domethod),$,"drawphrase",nt)
	sleeptill(tm)
}
method brushnotify(f,m,meth,doline) {

	oldm = $.scaletogrid(m)

	# signal beginning of brush
	$.notifyobj.(meth)($,0,oldm,oldm)

	y0 = $.ymin()+1
	y1 = $.ymax()-1

	if ( doline ) {
		ln = xy(m["x"],y0,m["x"],y1)
		$.line(ln,XOR)
	}

	b = m["button"]
	while ( (m=get(f)) != Eof ) {
		if ( m["button"] == 0 )
			break
		if ( fifosize(f) > 1 )
			continue
		newm = $.scaletogrid(m)
		if ( oldm["x"]==newm["y"] && oldm["y"]==newm["y"] )
			continue
		$.notifyobj.(meth)($,1,newm,oldm)
		if ( doline )
			$.line(ln,XOR)
		oldm["x"] = newm["x"]
		oldm["y"] = newm["y"]
		if ( doline ) {
			ln["x0"] = ln["x1"] = m["x"]
			$.line(ln,XOR)
		}
	}
	if ( doline )
		$.line(ln,XOR)

	# signal end of brush
	$.notifyobj.(meth)($,2,oldm,oldm)
}

method ihavechanged(n) {
	$.notifyofchange($)
}

method notifyofchange(changedobj,lengthchanged) {
	if ( nargs() < 2 )
		lengthchanged = 0
	# If the length of the object changes, and it is not scalable,
	# we need to adjust the duration of the note, and
	# adjust the size of the tool.
	if ( changedobj != $ && lengthchanged!=0 && ! changedobj.scaleit() ) {
		tname = $.w.trackname()
		phr = Track[tname]
		tnts = toolnotes(phr)
		for ( nt in tnts ) {
			h = note2holder(nt)
			if ( h == changedobj ) {
				nn = h.getaudition()
				phr -= nt
				nt.dur = nn.length
				phr |= nt
			}
		}
		Track[tname] = phr
		$.redraw()
	}

	$.notifyobj.notifyofchange($)
}

method addtool(v) {
	# add an initially-empty tool
	h = new toolholder($)
	p = Track[$.w.trackname()]
	p.flags = 0
	tnote = makeholdernote(v["x0"],v["x1"],h)
	tnote.flags = 1
	p |= tnote
	$.set(p)
}

}

Trknumber = 0
function uniqtrackname() {
	# Make unique indexes for  the Track array.
	Trknumber++
	return(string(Trknumber))
}
