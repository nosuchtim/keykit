class wconsole2 {
method init(fifo,interp,scroll) {
#	tracek(DBGTRACE_KEYKIT, "%$ nargs %d", $, nargs())
	$.w = new wconsole()
	$.inherit($.w)
        
	if ( nargs() < 1 )
		fifo = open()
	if ( nargs() < 2 )
		interp = global(interploop)
	if ( nargs() < 3 )
		scroll = 1
	$.scroll = scroll
	$.consfifo = fifo

        $.inselect = 0
        $.sel_x = $.sel_y = 0 # start corner of select

        $.submenuobj = $0 # ???
	$.permanence = 2
	$.notify = $0
        
        $.mkmenufunc = "mkmenu_wconsole2"
}

method redraw {
	$.w.redraw();
        methodbroadcast();
}

method delete {
       $.setselection()
       deleteobject($.w)
}

method mousedown(m) {
	if ( GrabNoSwitch && Root.isgrabbed() ) {
		print("Console is grabbed, focus is not being switched...")
	} else {
		if ( Root.focus() != $ ) {
			Root.focus($)
			Consecho = 1
		}
	}
        button=m["button"]
        if (button==1) {
		# left button pushed, want to do selection start
                if ($.inselect)
                {
			# (should) clear previous selection 
                        $.inselect = 0;
                        $.redraw();
                }
                if (!$.inselect)
                {
			$.inselect = 1;
                        $.sel_x=m["x"];
                        $.sel_y=m["y"];
                }
        } else if (button==2) {
		# should dump debug if menu is presented (e.g. .submenuobj is non-zero)
		# if not, present (and set .submenuobj) when button pushed.
		# "youarefreetogo" looks to remove the menu (need to check)
		if ( $.submenuobj != $0 && $.submenuobj != $-1 ) {
			# If menu is already pulled down, get rid of it.
			# Note that this will result in a message coming back to
			# the menu button, causing the button to redraw itself
			# so we don't need to do it here.
			$.submenuobj.youarefreetogo()
			$.submenuobj = $0
		} else {
			# force position of menu to be right below button
			# m["xy"] = xy($.xmin(),$.ymax()+2)

			# make menu where x/y of mouse is
			m["xy"] = xy(m["x"],m["y"])
			$.submenuobj = $.submenustart($.mkmenufunc,$,m["xy"])
			$.submenuobj.redrawfirst(1)
			$.submenuobj.postmenu(1)
		}
        } else {
	        mouseforward(m, "mousedown")
        }
}

method submenustart(mkfunc,args,sz) {
	o = new wmenu(mkfunc,$)
	o.setpermanence(0)
	o.setnotify($)
	sz = fit2root(sz)
	o.resize(sz)
	return(o)
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

method mousedrag(m) {
        if ($.scroll)
	        $.mousedo(m)

	if (m["button"] == 1)
	{
		# in select?
                if ($.inselect)
                {
#			keyerrfile("zzinselect %d [%u %u] [%u %u]\n", $.inselect, $.sel_x, $.sel_y, m["x"], m["y"]);
	                if ($.w.setselection($.sel_x, $.sel_y, m["x"], m["y"]))
                        {
#				keyerrfile("redraw\n")
                                # select window changed; redraw
				$.redraw()
                        }
                }
	}
}
method consecho(c) {
#	keyerrfile("consecho\n");
	$.w.printf("%s",c)
	# Hmm? how to get called for _any_ keyboard text drawn to clear selection
	$.setselection()
}
method mouseup(m) {
#	keyerrfile("mouseup\n");
	if (m["button"] == 1) {
		if ($.inselect) {
			# Hmm, should we do anything on mouseup from selection???
                	# Selection is still active
		}
        }
}

method resize(sz) {
#	tracek(DBGTRACE_KEYKIT, "%$", $)
	if ( nargs() > 0 ) {
		$.w.resize(sz)
        }
}

method copy(o)
{
#	keyerrfile("copy\n");
	# getselection() fetches selection
        str = $.w.getselection()
	if (str != "") {
		mdep("clipboard", "set", str)
	}
}
method paste(o)
{
#	keyerrfile("paste\n");
	# mdep will setup kbdchar() to consume the selection buffer...
        mdep("clipboard", "get");
}

}

function mkmenu_wconsole2(o,po) {
#	tracek(DBGTRACE_KEYKIT, "%$ o %$ po %$", $, o, po)
	o.menucmd("Copy",po,"copy", po)
	o.menucmd("Paste",po,"paste", po)
}

