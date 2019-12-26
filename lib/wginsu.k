class wginsu {
method init {
	$.w = new window()
	$.inherit($.w)

	$.bangees = []
	$.f = open()
	$.inports = []
	$.inports[0] = "<"
	for ( n=1; n<=16; n++ ) {
		$.inports[n] = string(n)
	}
	$.outports = []
	$.outports[0] = ">"
	for ( n=1; n<=16; n++ ) {
		$.outports[n] = string(n)
	}

	$.notes = []
	for ( n=0; n<128; n++ ) {
		$.notes[n] = string(makenote(n))
	}
	$.vols = []
	for ( n=0; n<128; n++ ) {
		$.vols[n] = string(n+1)
	}
	$.inbutt = new kvalbutton($.inports,$,"inchanged")
	$.outbutt = new kvalbutton($.outports,$,"outchanged")
	$.b1 = new kmenubutton("Ginsu","mkmenu_ginsu",$)
	$.conn = new krubber("Connect",$,"startconn","endconn")

	$.voltext = new ktext("Vol")
	$.notetext = new ktext("Note")

	$.procs = proc_list()

	names = []
	for ( n=0; n<sizeof($.procs); n++ ) {
		names[n] = $.procs[n]["name"]
	}

	$.procbutt = new kvalbutton(names,$,"procchanged",1)

	$.addchild($.b1)
	$.addchild($.inbutt)
	$.addchild($.outbutt)
	$.addchild($.procbutt)

	$.addchild($.conn)

	$.addchild($.voltext)
	$.addchild($.notetext)

	$.taskid = 0
	$.ptool = $0
	$.targetobj = $0
	$.inchan = 0
	$.outchan = 0
	$.inchanged(1)
	$.outchanged(1)
	$.setecho(0)

	$.procchanged(0)
}
method drawbangees (mode) {
	xmid = ($.xmin()+$.xmax())/2
	ymid = ($.ymin()+$.ymax())/2
	for ( i in $.bangees ) {
		if ( i == $0 || i == $-1 ) {
			# This should really delete the item from $.bangees,
			# but it doesn't seem to work?
			delete $.bangees[i]
		}
		else {
			xmid2 = (i.xmin()+i.xmax())/2
			ymid2 = (i.ymin()+i.ymax())/2
			Root.line(xy(xmid,ymid,xmid2,ymid2),mode)
		}
		i.drawbangees(XOR)
	}
}
method startconn { $.drawbangees(XOR) }
method endconn (t) {
	$.drawbangees(XOR)
	if ( t != $ && t != Root )
		$.bangees[t] = 1
	if ( t == $ )
		return()
	if ( t.classof() != "wginsu" )
		return()
	$.bangees[t] = 1
	$.outchanged(0,1)
	t.inchanged(0,1)
}
method showconn(mode) {
	$.drawconn(XOR)
	if ( $.targetobj != $0 )
		$.targetobj.showconn(XOR)
}
method drawconn(mode) {
	if ( $.targetobj == $0 )
		return()
	xmid = ($.xmin()+$.xmax())/2
	ymid = ($.ymin()+$.ymax())/2
	to_xmid = ($.targetobj.xmin()+$.targetobj.xmax())/2
	to_ymid = ($.targetobj.ymin()+$.targetobj.ymax())/2
	Root.line(xy(xmid,ymid,to_xmid,to_ymid),mode)
}
method procchanged(n,doredraw) {
	if ( $.ptool != $0 )
		$.removechild($.ptool)

	pt = $.procs[n]["tool"]
	if ( pt != 0 ) {
		$.ptool = new pt()
		$.addchild($.ptool)
		$.pfunc = global(pfunc_process)
	} else {
		$.ptool = $0
		$.pfunc = global(pfunc_null)
	}
	$.proc = n

	if ( nargs() > 1 && doredraw == 1 ) {
		$.resize()
		if ( $.ptool != $0 )
			$.ptool.redraw()
		else
			$.redraw()
	}
}
method inchanged(n,doredraw) {
	$.inbutt.set(n)
	if ( nargs() > 1 && doredraw ) {
		$.inbutt.redraw()
	}
	$.inchan = n
	if ( n > 0 ) {
		mask = 1 << ($.inchan-1)
		Mergefilter = Mergefilter | mask
		Midiin[$] = $.f
	}
	if ( $.taskid != 0 ) {
		kill($.taskid)
		$.taskid = 0
	}
	if ( $.inchan > 0 )
		$.taskid = task $.task_wginsu()
}
method outchanged(n,doredraw) {
	$.outbutt.set(n)
	if ( nargs() > 1 && doredraw ) {
		$.outbutt.redraw()
	}
	$.outchan = n
}
method redraw {
	$.w.redraw()
	methodbroadcast()
}

method delete {
	kill($.taskid)
	delete(Midiin[$])
	close($.f)
	print("Setting Mergefilter for inchan=",$.inchan," back on...")
	if ( $.inchan > 0 ) {
		mask = 1 << ($.inchan-1)
		Mergefilter = Mergefilter & (~mask)
	}
}

method setecho(v) {
	$.echo = v
	if ( $.inchan > 0 ) {
		mask = 1 << ($.inchan-1)
		if ( v == 0 )
			Mergefilter = Mergefilter | mask
		else
			Mergefilter = Mergefilter & (~mask)
	}
}

method feed(m) {
	if ( $.inchan > 0 && m.chan != $.inchan )
		return()
	if ( $.pfunc != pfunc_null && $.ptool != $0 )
		m = $.pfunc(m,$.ptool)
	if ( m == '' )
		return()
	if ( $.outchan > 0 ) {
		m.chan = $.outchan
		realtime(m,0)
	} else { 
		for ( b in $.bangees )
			b.feed(m)
	}
}

method task_wginsu() {
	# Flush anything already in there
	while ( fifosize($.f) > 0 && (m=get($.f)) != Eof ) {
	}
	# Feed yourself from the Midiin fifo
	while ( (m=get($.f)) != Eof )
		$.feed(m)
}

method dump {
	if ( $.ptool == $0 ) 
		pt = []
	else if ( defined($.ptool.dump) )
		pt = $.ptool.dump()
	else if ( defined($.ptool.get) )
		pt = $.ptool.get()
	else {
		print("No dump or get method in wginso object? (class=",$.ptool.classof(),")")
	}

	state = [
		"proc" = $.proc,
		"ptool" = pt,
		"inchan" = $.inchan,
		"outchan" = $.outchan
		]
	return(state)
}
method restore (state) {
	$.proc = state["proc"]
	i = state["inchan"]-1
	o = state["outchan"]-1

	$.inchanged(i)
	$.outchanged(o)
	$.procchanged($.proc)

	$.inbutt.set(i)
	$.outbutt.set(o)
	$.procbutt.set($.proc)

	if ( state["ptool"] != $0 ) {
		if ( defined($.ptool.dump) )
			$.ptool.restore(state["ptool"])
		else
			$.ptool.set(state["ptool"])
	}
	$.resize()
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)

	y0 = $.ymin()+2
	y0a = $.ymin() + $.textheight() + 4
	y0b = y0a + $.textheight() + 2
	tw = $.textwidth()
	x0 = $.xmin() + 2
	x1 = $.xmax() - 2
	dx = (x1-x0)/4
	y1 = $.ymax() - 2

	xm = (x0+x1)/2
	xm2 = (x1+(xm+tw))/2

	$.b1.resize(xy(x0,y0,xm-tw,y0a-1))
	$.procbutt.resize(xy(x0,y0a+1,xm-tw,y0b))

	$.conn.resize(xy(xm+tw,y0,x1,y0a-1))
	$.inbutt.resize(xy(xm+tw,y0a+1,xm2-1,y0b-1))
	$.outbutt.resize(xy(xm2+1,y0a+1,x1,y0b-1))

	if ( $.ptool != $0 ) {
		$.ptool.resize(xy(x0,y0b+6,x1,y1))
	}
}
}

function mkmenu_ginsu1(o,po) {
	o.menucmd("On",po,"setecho",1)
	o.menucmd("Off",po,"setecho",0)
}

function mkmenu_ginsu(o,po) {
	o.submenu("Echo Input ->","mkmenu_ginsu1",po)
}

function pfunc_process(n,t) {
	return(t.process(n))
}
function pfunc_null(n,t) {
	return(n)
}
