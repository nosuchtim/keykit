
class wportmap1{
method init {
	$.w = new window()
	$.inherit($.w)

	$.cin = new kmenubutton("default","wportmap1_inputs",$)
	$.addchild($.cin);

	$.cout = new kmenubutton("","wportmap1_outputs",$)
	$.addchild($.cout)

	$.currinport = 0
	$.currinname = "default"
}

method dump {
	a = []
	a["in"] = $.currinport
	return(a)
}
method restore (state) {
	# if ( "in" in state ) {
	#	$.cin.set(state["in"]) 
	# }
}

method redraw {
	$.w.redraw()

	$.textleft("Port Map (all channels)",xy($.x0,$.y0,$.x1,$.ya))
	$.textleft("Input ",xy($.x0,$.ya,$.x1b,$.yb))
	$.textleft("Output =",xy($.x0,$.yb,$.x1b,$.y1-1))

	methodbroadcast()
}

method resize(sz) {
	tw = $.textwidth()
	th = $.textheight()
	if ( nargs() > 0 ) {
		wid = sz["x1"] - sz["x0"]
		hgt = sz["y1"] - sz["y0"]
		xneeded = tw * 30
		yneeded = 8 + 3*th
		if ( wid > xneeded ) {
			sz["x1"] = sz["x0"] + xneeded;
		}
		if ( hgt > yneeded ) {
			sz["y1"] = sz["y0"] + yneeded;
		}
		$.w.resize(sz)
	}
	$.y0 = $.ymin() ; $.y1 = $.ymax()
	$.x0 = $.xmin() ; $.x1 = $.xmax()
	$.ya = $.y0+2+(th+1)+1
	$.yb = $.y0+2+2*(th+1)+2
	$.x1b = $.x0+($.x1-$.x0)/4
	$.cin.resize(xy($.x1b,$.ya,$.x1-2,$.yb))
	$.cout.resize(xy($.x1b,$.yb,$.x1-2,$.y1-2))
}

method inputchanged (portno,name) {
	if ( portno < 0 )
		return()
	$.currinport = portno
	$.currinname = name
	$.cin.settext(name)
	$.cin.redraw()
}
method outportchanged (portno,name) {
	if ( portno < 0 )
		return()
	mapport($.currinport,portno)
	$.cout.settext(name)
	$.cout.redraw()
}
}

function wportmap1_inputs(o,po) {
	list = midi("input","list");
	names = []
	vals = []
	i = 0;

	names[i] = "default"
	vals[i] = 0
	i++

	old = Arraysort
	Arraysort = 1
	for ( n in list ) {
		if ( midi("input","isopen",n) ) {
			names[i] = list[n]
			vals[i] = n
			i++
		}
	}
	Arraysort = old
	if ( i == 1 ) {
		names[i] = "No inputs are open (use Port Enabler tool)"
		vals[i] = -1
		i++;
	}
	for ( n=0; n<i; n++ ) {
		o.menucmd(names[n],po,"inputchanged",vals[n],names[n])
	}
}
function wportmap1_outputs(o,po) {
	list = midi("output","list");
	names = []
	vals = []
	i = 0;
	old = Arraysort
	Arraysort = 1
	for ( n in list ) {
		if ( midi("output","isopen",n) ) {
			names[i] = list[n]
			vals[i] = n
			i++
		}
	}
	Arraysort = old
	if ( i == 0 ) {
		names[i] = "No outputs are open (use Port Enabler tool)"
		vals[i] = -1
		i++;
	}
	for ( n=0; n<i; n++ ) {
		o.menucmd(names[n],po,"outportchanged",vals[n],names[n])
	}
}
