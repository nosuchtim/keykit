class walsaportpick {

method init {
        $.w = new window()
        $.inherit($.w)

        $.inports = midi("input", "list")
	$.inkvb = []
	$.inportval = []
	$.intext = []
        $.inporttext = []
        
        $.outports = midi("output", "list")
	$.outkvb = []
	$.outportval = []
	$.outtext = []
        $.outporttext = []

	$.nins = sizeof($.inports);
	$.nouts = sizeof($.outports);
	$.maxlength = 12
	old = Arraysort
	Arraysort = 1
	n = 0
        $.insellist = [ ]
        $.inportlist = [ ]
        $.insellist[n++] = "None"
        for ( i in $.inports ) {
                $.insellist[n] = $.inports[i]
                $.inportlist[n] = i # capture port number (index of $.inports)
                n++
                }
        print("inports", $.inports)
        print("insellist", $.insellist)
        n = 0
	for ( i in $.inports ) {
		s = $.inports[i]
		$.inportval[n] = i

		##$.intext[n] = new ktext("IN","left")              # ORG.
                inporttext = "IN P"+string(i)
                $.inporttext[n] = inporttext
		$.intext[n] = new ktext(inporttext,"left")    # show port index

		$.inkvb[n] = new kvalbutton($.insellist,$,"inportselchanged",n)
		$.inkvb[n].settext(s,"right")
		$.addchild($.inkvb[n])
		$.addchild($.intext[n])
		if ( sizeof(s) > $.maxlength )
			$.maxlength = sizeof(s);
		n++
	}
	n = 0
        $.outsellist = [ ]
        $.outportlist = [ ]
        $.outsellist[n++] = "None"
        for ( i in $.outports ) {
                $.outsellist[n]=$.outports[i]
                $.outportlist[n] = i
                n++
                }
        print("outports", $.outports)
        print("outsellist", $.outsellist)
        n=0
	for ( i in $.outports ) {
#		printf("%s:%d\n", taskinfo("file"), taskinfo("line"))
		s = $.outports[i]
		$.outportval[n] = i
                outporttext = "OUT P"+string(i)
                $.outporttext[n] = outporttext
		##$.outtext[n] = new ktext("OUT","left")            # ORG.
		$.outtext[n] = new ktext(outporttext,"left")  # show port index

		$.outkvb[n] = new kvalbutton($.outsellist,$,"outportselchanged",n)
		$.outkvb[n].settext(s,"right")
		$.addchild($.outkvb[n])
		$.addchild($.outtext[n])
		if ( sizeof(s) > $.maxlength )
			$.maxlength = sizeof(s);
		n++
	}
	Arraysort = old
	$.resetvals()
}

method resetvals() {
	for ( n=1; n<=$.nins; n++ ) {
		r = midi("input","isopento",$.inportval[n-1])
#		print("resetvals I:", r, n-1, $.inportval[n-1])
		$.inkvb[n-1].set(r)
	}
	for ( n=1; n<=$.nouts; n++ ) {
		r = midi("output","isopento",$.outportval[n-1])
#		print("resetvals O:", r, n-1, $.outportval[n-1])
		$.outkvb[n-1].set(r)
	}
}

# args are selection, output/input, n
method outportselchanged(newport, whichport) {
#	print("outportselchanged:", "newport:", newport, "whichport:", whichport, "outportval:", $.outportval[whichport])
	# outportval[whichport] is the port number to change
	# newport is the index into outport to change the port to
#	print(taskinfo("file"), ":", taskinfo("line"), "See if", $.outportval[whichport], "(", $.outporttext[whichport], ") is open")
	if (midi("output", "isopen", $.outportval[whichport])) {
#		print(taskinfo("file"), ":", taskinfo("line"), "(Yes; close it)");
		r = midi("output", "close", $.outportval[whichport]);
		if (r != 0) {
			error("Error closing outport", $.outportval[whichport]);
		}
	}
	printf("Change out '%s' to '%s'\n", $.outporttext[whichport], $.outsellist[newport])
	if (newport == 0) {
#		print("Disable", $.outporttext[whichport])
	}
	else {
#		printf("A %s:%d port %d newport %d\n", taskinfo("file"), taskinfo("line"), $.outportval[whichport], newport)
		r = midi("output", "open", $.outportval[whichport], newport)
	}
#	if (r != 0) {
#		printf("B %s:%d r: %d\n", taskinfo("file"), taskinfo("line"), r)
#	}
}

method inportselchanged(newport, whichport) {
#	print("inportselchanged:", newport, whichport, "inportval:", $.inportval[whichport])
#	printf("Change in '%s' to '%s'\n", $.inporttext[whichport], $.insellist[newport])
       
	if (midi("input", "isopen", $.inportval[whichport])) {
		r = midi("input", "close", $.inportval[whichport]);
		if (r != 0) {
			error("Error figuring out if inport", $.inportval[whichport], " is closed");
		}
	}
	if (newport == 0) {
#		print("Disable", $.inporttext[whichport])
	}
	else {
#		printf("C %s:%d\n", taskinfo("file"), taskinfo("line"))
		r = midi("input", "open", $.inportval[whichport], newport)
	}
#	if (r != 0) {
#		printf("D %s:%d r: %d\n", taskinfo("file"), taskinfo("line"), r)
#	}
		
}

method resize(sz) {
	tw = $.textwidth()
	th = $.textheight()
	if ( nargs() > 0 ) {
		wid = sz["x1"] - sz["x0"]
		hgt = sz["y1"] - sz["y0"]

		##xneeded = tw * ($.maxlength + 8)	# ORG.
		xneeded = tw * ($.maxlength + 10)	# 2nd column widened

		yneeded = 4 + th * ($.nins+$.nouts+1)
		if ( wid > xneeded ) {
			sz["x1"] = sz["x0"] + xneeded;
		}
		if ( hgt > yneeded ) {
			sz["y1"] = sz["y0"] + yneeded;
		}
		$.w.resize(sz)
	}

	y0 = $.ymin();
	y0a = $.ymin()+$.textheight+2
	y1 = $.ymax();
	x0 = $.xmin();
	x1 = $.xmax();
	
	##x0a = $.xmin() + tw*5;		# ORG.
	x0a = $.xmin() + tw*8;			# 1st column widened


	y0b = y0 + th + 2
	y = y0b
	h = y1-y0b
	for ( n=0; n<$.nins; n++ ) {
		yb = y0b + (n+1)*h/($.nins+$.nouts)
		$.intext[n].resize(xy(x0, y, x0a, yb))
		$.inkvb[n].resize(xy(x0a, y, x1, yb))
		y = yb
	}
	for ( n=0; n<$.nouts; n++ ) {
		yb = y0b + ($.nins+n+1)*h/($.nins+$.nouts)
		$.outtext[n].resize(xy(x0, y, x0a, yb))
		$.outkvb[n].resize(xy(x0a, y, x1, yb))
		y = yb
	}
}

method redraw {
#	print("$.redraw");
	$.w.redraw()
	$.resetvals()
	$.w.text("Midi Port Enabler", xy($.xmin(), $.ymin(), $.xmax(), $.ymin() + $.textheight()+2))
	methodbroadcast()
}

method dump {
	st = [
		
	]
	return(st)
}
method restore(setup) {
}
}
