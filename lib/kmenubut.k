# kmenubutton - a menubutton.  When the button is
#	pressed, the named pull-down menu will appear.
#	The drawfunc is used to draw the inside of the button - if drawfunc
#	is equal nullfunc, then the button will just be an empty square.

class kmenubutton {
method init (drawfnc,mkmenufunc,...) {

	if ( typeof(mkmenufunc) != "string" )
		error("Obsolete kmenubutton usage, expects string as 2nd arg")

	$.w = new window()
	$.w.style(MENUBUTTON)
	$.inherit($.w)

	$.mkmenufunc = mkmenufunc
	$.setdrawfunc(drawfnc)
	$.args = argvlist(...)
	$.fifo = -1
	$.menu = -1
	$.submenuobj = $0
}

method settext(t,j) {
	$.text = t
	if ( nargs() > 1 )
		$.just = j
	else
		$.just = "center"
}
method gettext() {
	return($.text)
}

method setdrawfunc (...) {
	f = argv(0)
	if ( typeof(f) == "string" ) {
		$.drawfunc = global(kbutton_drawtext)
		$.settext(...)
	} else {
		$.drawfunc = f
	}
}
method setargs (...) { $.args = argvlist(...) }
method findsubmenu (sb) {
	if ( $ == sb || $.submenuobj == sb )
		return(sb)
	if ( $.submenuobj == $0 || $.submenuobj == $-1 )
		return($0)
	return( $.submenuobj.findsubmenu(sb) )
}
method submenudone {
	$.submenuobj = $0
	$.redraw()
}
method submenumoved { $.submenudone() }
method submenubackup {
	$.redraw()
}
method redraw {
	if ( $.fifo >= 0 ) # if the button is in the middle of being used...
		return()
	$.w.redraw()
	f = $.drawfunc
	f($)
}

method mousedown (m) {
	if ( m["button"] > 1 )
		return()	# ignore another other than button 1

	if ( $.submenuobj != $0 && $.submenuobj != $-1 ) {
		# If menu is already pulled down, get rid of it.
		# Note that this will result in a message coming back to
		# the menu button, causing the button to redraw itself
		# so we don't need to do it here.
		$.submenuobj.youarefreetogo()
		$.submenuobj = $0
	}
	else {
		# $.fillrectangle($.size(),STORE)	# make it look pushed-in
		$.w.style(PRESSEDBUTTON)
		$.w.redraw()
		f = $.drawfunc
		f($,CLEAR)
		$.w.style(MENUBUTTON)

		# force position of menu to be right below button
		m["xy"] = xy($.xmin(),$.ymax()+2)
		$.submenuobj = $.submenustart($.mkmenufunc,$.args,m["xy"])
		$.submenuobj.redrawfirst(1)
		$.submenuobj.postmenu(1)
	}
}
method submenustart(mkfunc,args,sz) {
	o = new wmenu(mkfunc,varg(args))
	o.setpermanence(0)
	o.setnotify($)
	sz = fit2root(sz)
	o.resize(sz)
	return(o)
}
method mousedrag (m) { methodbroadcast(m) }
method mouseup (m) { methodbroadcast(m) }
}
