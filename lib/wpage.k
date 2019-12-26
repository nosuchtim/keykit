class wpage {
method init {
	$.w = new window("root")
	$.inherit($.w)

	$.rootmenuobj = $0
	$.consgrabfifo = -1
	$.focusobj = $0
	$.globals = []
}

method redraw {
	$.w.redraw()
	for ( o in $.children() ) {
		if ( o.displaymode() == "normal" ) {
			o.redraw()
		}
	}
}
method resize {
	print("wpage resize called!\n")
}
method grabconsole() {
	f = open()
	$.consgrabfifo = f
	return(f)
}
method setconsgrabfifo(f) {
	$.consgrabfifo = f
}
method isgrabbed() {
	if ( $.consgrabfifo == -1 )
		return(0)
	else
		return(1)
}
method releaseconsole() {
	$.consgrabfifo = -1
}
method waitforconsolekey {
	f = open()
	$.consgrabfifo = f
	c = get(f)
	$.consgrabfifo = -1
	close(f)
	return(c)
}
method consolekey(c) {
	if ( $.consgrabfifo >= 0 ) {
		put($.consgrabfifo,c)
	} else if ( $.focusobj != $0 && $.focusobj != $-1 ) {
		$.focusobj.consolekey(c)
	} else {
		printf("Warning: consolekey is losing c=("+string(c)+")\n")
	}
}
method focus(co) {
	if ( nargs() > 0 ) {
		$.consgrabfifo = -1
		$.releaseconsole()
		Consechoobj = $0
		$.focusobj = co
		Console = co
	}
	return($.focusobj)
}
method info {
	return("This is the background.")
}
method mousedown (m) {
	if ( m["button"] != 1 ) {
		# Ignore everything except button 1
		return()
	}
	if ( Activemenu == $.rootmenuobj && Activemenu != $0 && Activemenu != $-1 ) {
		Activemenu.youarefreetogo()
		Activemenu = $0
	}
	else {
		o = new wmenu("mkmenu_root")
		o.setpermanence(1)

		if ( defined(Rootmenucenter) && Rootmenucenter!=0 ) {
			# we want the menu to be centered, vertically
			nitems = sizeof(o.menuitems())
			if ( nitems > Menusize )
				nitems = Menusize
			# The +3 here is just a hack so that the "Tools" item ends
			# up just to the right of the mouse when it comes up.
			m["xy"] = xy(m["x"]+3,m["y"]-(((nitems+3) * o.textheight()) / 2))
		}
		else {
			# The default behaviour is for the menu to come up
			# with the top lined up with the mouse.
			m["xy"] = xy(m["x"],m["y"])
		}

		o.resize(m["xy"])
		o.mousedown(m)
		Root.addchild(o)
		$.rootmenuobj = o
	}
}
method deletetool (o) {
	o.erase()
	$.removechild(o)
	deleteobject(o)
}
method addtool (o,sz) {
	if ( nargs() > 1 && typeof(sz) != "array" ) {
		print("Unexpected second argument to addtool(), not an array?")
		return($0)
	}
	$.addchild(o)
	if ( nargs() > 1 )
		o.resize(sz)
	return(o)
}
method stop {
	for ( o in $.children() ) {
		if ( defined(o.stop) )
			o.stop()
	}
}
method update {
	for ( o in $.children() ) {
		if ( defined(o.update) )
			o.update()
	}
}
method dump {
	state = []
	# Save values of global variables
	vars = globvarlist()
	for ( i in vars ) {
		nm = vars[i]["name"]
		state[nm] = globalvalue(nm)
	}
	return(state)
}
method restore (state) {
	# Restore global variables
	for ( nm in state ) {
		cmd = nm + "=" + string(state[nm])
		eval cmd
	}
}
method leave {
	# Save values of global variables
	vars = globvarlist()
	for ( i in vars ) {
		nm = vars[i]["name"]
		$.globals[nm] = globalvalue(nm)
	}
}
method enter {
	# Restore global variables from saved values
	for ( nm in $.globals ) {
		cmd = nm + "=" + string($.globals[nm])
		eval cmd
	}
}
}

function rootreleaseconsole() {
	Root.releaseconsole()
}
