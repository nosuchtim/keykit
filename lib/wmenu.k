class wmenu {
method init (mkmenufunc,...) {

	fnc = function(mkmenufunc)
	if ( ! defined(fnc) )
		error("wmenu fails - there is no function named "+string(mkmenufunc))
	if ( typeof(fnc) != "function" )
		error("wmenu fails - there is no function named "+string(mkmenufunc))

	$.w = new window("menu")
	$.inherit($.w)

	$.item = []
	$.args = argv(1,nargs())
	$.mkmenufunc = mkmenufunc
	$.submenuobj = $0
	$.choice = MENU_NOCHOICE
	$.firstchoice = MENU_NOCHOICE
	$.permanence = 2
	$.notify = $0
	$.saved = 0
	$.leftmargin = 4
	$.grabbed = 0
	$.abouttodelete = 0
	fnc($,...)
}
method info { return("menu: "+string($.mkmenufunc)) }

method resize (...) {
	if ( $.saved )
		$.saved = 0	# so we don't do restoreunder
	$.w.resize(...)
}
method recreate {
	return("wmenu($"+string(integer($))+",\""+$.mkmenufunc+"\",varg("+string($.args)+"))")
}
method youarefreetogo {
		if ( $.permanence < 2 ) {
			tobefreed = $0
			if ( $.submenuobj != $0 && $.submenuobj != $-1 ) {
				tobefreed = $.submenuobj
				$.submenuobj = $0
			}
			$.undraw()
			if ( $.notify != $0 && $.notify != $-1 )
				$.notify.submenudone()
			$.deleteme()
			if ( tobefreed!=$0 && tobefreed!=$-1 )
				tobefreed.youarefreetogo()
		}
}
method findsubmenu (sb) {
		if ( $ == sb || $.submenuobj == sb )
			return(sb)
		if ( $.submenuobj == $0 || $.submenuobj == $-1 )
			return($0)
		return( $.submenuobj.findsubmenu(sb) )
}
method setpermanence (v) {
	$.permanence = v
}
method getpermanence { return($.permanence) }

method menucmd(lbl,obj,meth,...) {
	if ( nargs() < 2 )
		error("usage: .menucmd(lbl,obj,meth,...)")
	n = $.menuitem(lbl)
	it = $.item[n] = ["label"=lbl,"type"="command"]
	if ( typeof(obj) == "string" ) {
		it["obj"] = obj
		it["args"] = argv(2,nargs())
	}
	else if ( typeof(obj) == "object" ) {
		it["obj"] = obj
		it["meth"] = meth
		it["args"] = argvlist(...)
	}
	else if ( typeof(obj) == "function" ) {
		it["obj"] = obj
		it["args"] = argv(2,nargs())
	}
	else {
		print("Old use of menucmd, lbl=",lbl,"  IGNORED")
	}
}

method submenu(lbl,mkmenu,...) {
	n = $.menuitem(lbl)
	$.item[n] = []
	$.item[n]["label"] = lbl
	$.item[n]["type"] = "submenu"
	$.item[n]["mkmenu"] = mkmenu
	if ( typeof(mkmenu) != "string" )
		print(".submenu expects a string for mkmenu value!?")
	$.item[n]["args"] = argvlist(...)
}

method submenubackup() {
	grabmouse($)
	$.w.redraw()
	$.grabbed = 1
}

method submenudone() {
	if ( $.permanence < 2 )
		$.undraw()
	if ( $.notify != $0 && $.notify != $-1 )
		$.notify.submenudone()
	$.choice = MENU_NOCHOICE
	$.submenuobj = $0
	if ( $.permanence < 2 ) {
		$.deleteme()
	}
}

method setnotify(o) {
	$.notify = o
}

method undraw() {
	if ( $.saved ) {
		$.restoreunder()
		$.saved = 0
	}
	else {
		$.erase()
	}
	if ( $ in Root.children() )
		Root.removechild($)
}

method redrawfirst(saveit) {

	if ( Activemenu == $0 || Activemenu == $-1 ) {
		if ( $.permanence < 2 )
			Activemenu = $
	}
	else if ( Activemenu.findsubmenu($) == $ ) {
		# print("Activemenu is a parent or same, no clearing!!")
	}
	else {
		Activemenu.youarefreetogo()
		if ( $.permanence < 2 )
			Activemenu = $
		else
			Activemenu = $0
	}
	if ( $.saved==0 ) {
		if ( nargs() > 0 && saveit != 0 && $.permanence<2 ) {
			$.saveunder()
			$.saved = 1
		}
		else if ( $.permanence==0 ) {
			$.saveunder()
			$.saved = 1
		}
	}
	$.w.redraw()
}

method waitup() {
	f = grabmousefifo()
	waitup(f)
	ungrabmousefifo(f)
}

method mousedown(m,nomove) {

	if ( nargs()<2 )
		nomove = 0

	if ( m["button"] > 1 )
		return()
	grabmouse($)
	$.grabbed = 1
	if ( "xy" in m )
		$.w.resize(m["xy"])

	m["mousedown"] = 1	# this is a flag to mousedo, telling
				# it not to highlight a choice

	newchoice = $.mousedo(m)

	if ( newchoice != MENU_DELETE && newchoice != MENU_MOVE ) {
		$.redrawfirst(1)
	}

	$.firstchoice = newchoice
	if ( newchoice == MENU_MOVE ) {
		if ( !nomove ) {
			neederase = 1
			if ( $.saved ) {
				$.restoreunder()
				$.saved = 0
				neederase = 0
			}
			ungrabmouse($)
			$.grabbed = 0
			task wmove($,m,neederase)
			if ( $.notify != $-1 && $.notify != $0 ) {
				$.notify.submenudone()
				$.notify = $0	# only gets notified once
			}
			if ( $ == Activemenu )
				Activemenu = $0
		}
	}
	else if ( newchoice == MENU_DELETE ) {
		# We don't want to delete it until we get the mouseup
		$.abouttodelete = 1
	}
	else if ( newchoice == MENU_UNDEFINED ) {
		print("MENU_UNDEFINED NO LONGER USED, THIS SHOULD NOT HAPPEN!")
		# do nothing
	}
	else if ( $.choice == $.firstchoice && $.choice != MENU_NOCHOICE
		&& $.submenuobj != $0 && $.submenuobj != $-1 ) {
		# Selecting a sub-menu a 2nd time will put it down
		$.clearsubmenuobj()
		$.submenuobj = $0
		$.choice = MENU_NOCHOICE
		ungrabmouse($)
		task $.waitup()
	}
	else {
		$.setchoice(newchoice,m)
	}
}

method submenustart(mkfunc,args,sz) {
	o = new wmenu(mkfunc,varg(args))
	o.setpermanence(0)
	o.setnotify($)
	# we want the submenu to be centered, vertically
	nitems = sizeof(o.menuitems())
	if ( nitems > Menusize )
		nitems = Menusize
	sz["y"] -= ((nitems * o.textheight()) / 2)
	sz = fit2root(sz)
	o.resize(sz)
	return(o)
}

method clearsubmenuobj() {
	if ( $.submenuobj != $0 && $.submenuobj != $-1 ) {
		o = $.submenuobj
		$.submenuobj = $0
		o.setnotify($0)
		o.youarefreetogo()
	}
}

method setchoice(newchoice,m) {
	if ( newchoice == $.choice )
		return()
	$.clearsubmenuobj()
	$.choice = newchoice
	if ( $.choice < 0 )
		return()

	mtype = $.item[$.choice]["type"]
	if ( mtype == "submenu" ) {
		mkfnc = $.item[$.choice]["mkmenu"]
		args = $.item[$.choice]["args"]
		sz = $.size()
		subsz = xy(sz["x1"]+1,m["y"])
		$.submenuobj = $.submenustart(mkfnc,args,subsz)
		$.submenuobj.redrawfirst(1)
	}
}

method mousedrag(m) {

	if ( m["button"] > 1 )
		return()

	if ( ! ($.grabbed) ) {
		$.mousedown(m,1)
		return()
	}
	if ( $.abouttodelete )
		return()
	sz = $.size()
	if ( m["x"] > sz["x0"] && m["x"] < (sz["x1"]-6) ) {
		newchoice = $.mousedo(m)
		$.setchoice(newchoice,m)
		return()
	}
	# If we go off the left side...
	if ( m["x"] < ( sz["x0"]- $.leftmargin ) ) {
		# If we're notifying someone, we assume that we're a
		# sub-menu, so we back up to the parent by deleting ourselves
		if ( $.notify != $-1 && $.notify != $0 ) {
			if ( $.choice != MENU_NOCHOICE )
				$.clearsubmenuobj()
			ungrabmouse($)
			$.notify.submenubackup()
		}
		return()
	}
	choice = $.choice
	if ( choice < 0 )
		return()
	mtype = $.item[choice]["type"]
	if ( mtype=="submenu" ) {

		if ( m["x"]<sz["x1"] || m["y"]<sz["y0"] || m["y"]>sz["y1"] )
			return()

		ungrabmouse($)
		$.grabbed = 0

		m["type"] = "mousedown"
		m["xy"] = $.submenuobj.size()
		$.submenuobj.setpermanence(1)
		$.submenuobj.mousedown(m,1)		# this will grab the mouse
	}
	else if ( mtype=="command" ) {

		# If we go a fair distance off to the right,
		# we "tear off" the button
		tw = $.textwidth()
		if ( m["x"]>(sz["x1"]+6*tw) ) {

			# Create a kcmdbutton widget
			nw = new kcmdbutton()
			Root.addtool(nw)
			nw.setcmd($.item[choice])
			nw.fit(m)
			nw.redraw()
			task wmove(nw,m)

			# Send a mouseup to ourselves, to terminate menu
			m["type"] = "mouseup"
			m["button"] = 0
			$.mouseup(m)
			if ( Activemenu != $0 && Activemenu != $-1 ) {
				Activemenu.youarefreetogo()
				Activemenu = $0
			}
		}
	}
}

method postmenu(perm) {
	if ( nargs() == 0 )
		error("postmenu needs arg!")
	$.setpermanence(perm)
	Root.addchild($)
}

method mouseup(m) {
	if ( ! $.grabbed )
		return()

	if ( $.abouttodelete ) {
		choiceis = $.mousedo(m)
		$.abouttodelete = 0
		ungrabmouse($)
		# but don't actually delete it unless we're still over the X
		if ( choiceis == MENU_DELETE ) {
			$.undraw()	# This will do the Root.removechild()
			$.deleteme()
		}
		return()
	}

	choiceis = $.mousedo(m)
	if ( choiceis >= 0 )
		cmd = $.item[choiceis]
	else
		cmd = []
	choicewas = $.choice
	if ( cmd["type"] == "submenu" && choiceis == $.firstchoice
		&& $.submenuobj != $-1 && $.submenuobj != $0 ) {
		$.submenuobj.postmenu(1)
		# If we've made a child permanent, we're somewhat permanent, too
		if ( $.permanence == 0 )
			$.postmenu(1)
		wasmenu = 1
	}
	else if ( $.choice == MENU_MOVE ) {
		$.postmenu(1)
	}
	else if ( $.choice != MENU_NOCHOICE ) {
		$.clearsubmenuobj()
		if ( $.permanence < 2 ) {
			$.permanence = 0
		}
		$.choice = MENU_NOCHOICE
		wasmenu = 0
	}
	ungrabmouse($)
	$.grabbed = 0

	if ( $.permanence == 0 ) {
		$.undraw()
	}

	if ( $.notify != $0 && $.notify != $-1
		&& cmd["type"] == "command" && choicewas >= 0 ) {
		$.notify.submenudone()
	}
	if ( $.permanence == 0 ) {
		$.deleteme()
	}

	if ( cmd["type"] == "command" )
		docmd(cmd)
}
method deleteme() {
	if ( $ == Activemenu )
		Activemenu = $0
	deleteobject($)
}
}
