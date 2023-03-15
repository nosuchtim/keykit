class wportpick {

method init {

        $.w = new window()
        $.inherit($.w)

        $.inports = midi("input", "list")
	$.intogg = []
	$.inportval = []
	$.intext = []

        $.outports = midi("output", "list")
	$.outtogg = []
	$.outportval = []
	$.outtext = []

	$.nins = sizeof($.inports);
	$.nouts = sizeof($.outports);
	$.maxlength = 12
	old = Arraysort
	Arraysort = 1
	n = 0
	for ( i in $.inports ) {
		s = $.inports[i]
		$.inportval[n] = i

		##$.intext[n] = new ktext("IN","left")              # ORG.
		$.intext[n] = new ktext("IN P"+string(i),"left")    # show port index

		$.intogg[n] = new ktoggle(" ",$,"toggle","input",n)
		$.intogg[n].settext(s,"right")
		$.addchild($.intogg[n])
		$.addchild($.intext[n])
		if ( sizeof(s) > $.maxlength )
			$.maxlength = sizeof(s);
		n++
	}
	n = 0
	for ( i in $.outports ) {
		s = $.outports[i]
		$.outportval[n] = i

		##$.outtext[n] = new ktext("OUT","left")            # ORG.
		$.outtext[n] = new ktext("OUT P"+string(i),"left")  # show port index

		$.outtogg[n] = new ktoggle(" ",$,"toggle","output",n)
		$.outtogg[n].settext(s,"right")
		$.addchild($.outtogg[n])
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
		$.intogg[n-1].set(midi("input","isopen",$.inportval[n-1]))
	}
	for ( n=1; n<=$.nouts; n++ ) {
		$.outtogg[n-1].set(midi("output","isopen",$.outportval[n-1]))
	}
}

method toggle(v,m,t,n) {
	# t is either "input" or "output"
	if (t == "input")
		p = $.inportval[n]
	else
		p = $.outportval[n]
	if ( p == "" ) {
		error("Error in value, t=",t," n=",n);
	}
	if ( v ) {
		if ( midi(t,"isopen",p) )
			print("MIDI "+t+" "+string(p)+" was already open.")
		else
			midi(t,"open",p)
	}
	else
		if ( midi(t,"isopen",p) == 0 )
			print("MIDI "+t+" "+string(p)+" was already closed.")
		else
			midi(t,"close",p)
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
	
	$.dy = (y1-y0-th-4)/($.nins+$.nouts)

	##x0a = $.xmin() + tw*5;		# ORG.
	x0a = $.xmin() + tw*8;			# 1st column widened


	y0b = y0 + th + 2
	y = y0b
	h = y1-y0b
	for ( n=0; n<$.nins; n++ ) {
		yb = y0b + (n+1)*h/($.nins+$.nouts)
		$.intext[n].resize(xy(x0, y, x0a, yb))
		$.intogg[n].resize(xy(x0a, y, x1, yb))
		y = yb
	}
	for ( n=0; n<$.nouts; n++ ) {
		yb = y0b + ($.nins+n+1)*h/($.nins+$.nouts)
		$.outtext[n].resize(xy(x0, y, x0a, yb))
		$.outtogg[n].resize(xy(x0a, y, x1, yb))
		y = yb
	}
}

method redraw {
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
