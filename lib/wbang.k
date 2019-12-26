class wbang {
method init {
	$.w = new window()
	$.inherit($.w)

	$.bangees = []
	$.message = "bang"
	$.args = []
	$.comment = "Send a\n'bang' msg"
	$.phrase = ''

	$.b1 = new kmenubutton("More","mkmenu_bang",$)
	$.t1 = new ktoggle("On",$,"setonoff")
	$.t2 = new kbutton("Bang",$,"bang")
	$.r1 = new krubber("Add",$,"startadd","endadd")
	$.r2 = new krubber("Del",$,"startdel","enddel")

	$.addchild($.b1)
	$.addchild($.t1)
	$.addchild($.t2)
	$.addchild($.r1)
	$.addchild($.r2)

}
method redraw {
	$.w.redraw()
	y0a = $.ymin() + $.textheight() + 3
	y1a = $.ymax() - $.textheight() - 3
	$.text($.comment,xy($.xmin(),y0a+2,$.xmax(),y1a))
	methodbroadcast()
}
method resize (sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	dx = ($.xmax()-$.xmin()) / 3
	th = $.textheight()
	y0 = $.ymin()+1
	y0a = y0 + th + 3
	y0b = y0a + 2*th + 3
	x0 = $.xmin()+1
	x1 = $.xmax()-1
	xmid = (x0+x1)/2
	y1 = $.ymax()-2
	y1a = $.ymax() - $.textheight() - 3
	$.t1.resize(xy(x0+1,y0+1,x0+dx-1,y0a))
	$.b1.resize(xy(x0+dx+1,y0+1,x0+2*dx-1,y0a))
	$.t2.resize(xy(x0+2*dx+1,y0+1,x1-1,y0a))

	$.r1.resize(xy(x0+1,y1a+1,xmid-1,y1))
	$.r2.resize(xy(xmid+1,y1a+1,x1-1,y1))
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
	}
}
method startadd { $.drawbangees(XOR) }
method endadd (to) {
	$.drawbangees(XOR)
	if ( to != $ && to != Root )
		$.bangees[to] = 1
}
method startdel { $.drawbangees(XOR) }
method enddel (to) {
	$.drawbangees(XOR)
	arr = $.bangees
	if ( to != Root && to != $ && (to in arr) )
		delete arr[to]
}
method delete {
	delete Midiin[$]
	if ( defined($.midiid) )
		kill($.midiid)
}
method clearbangees (w) { $.bangees = [] }
method set (var,val) { $.(var) = val }
method setonoff (v) { if (v) $.on(); else $.off() }

method dump { return ( [
	"phrase" = $.phrase,
	"comment" = $.comment,
	"message" = $.message,
	"bangees" = $.bangees
	])
}
method restore (state) {
	$.phrase = state["phrase"]
	$.comment = state["comment"]
	$.message = state["message"]
	$.bangees = arraycopy(state["bangees"])
}
method flash { task $.task_wbangflash() }
method bang {
	for ( i in $.bangees ) {
		# should really try to delete bangees that disappear, but
		# delete doesn't seem to work on those entries in bangees?
		if ( i == $0 || i == $-1 )
			continue
		if ( defined(i.($.message)) ) {
			i.($.message)(varg($.args))
		}
		else {
			print("wbang can't find method '"+$.message+"' of object",i)
		}
	}
}
method on {
	if ( sizeof($.phrase) == 0 )
		print("Warning, bangger doesn't have anything to look for!?")
	$.ison = 1
	$.midiid = task $.task_wbangmidi()
	$.t1.set(1)
}
method off {
	$.ison = 0
	if ( defined($.midiid) )
		kill($.midiid)
	$.t1.set(0)
}
method play { $.on() }
method stop { $.off() }
method setphrase (ph) {
	ph.time = 0
	ph.length = 0
	$.phrase = ph
}
method loadrec { $.phrase = tail(Recorded,1) }
method setcomment {
	$.comment = getastr("Enter comment -> ")
	$.redraw()
}
method setmessage {
	s = getastr("Enter message -> ")
	if ( s == "" )
		return()
	$.comment = s
	words = split(s)
	$.message = words[0]
	$.args = []
	if ( sizeof(words) > 1 ) {
		for ( n=1; n<sizeof(words); n++ ) {
			$.args[n-1] = words[n]
		}
	}
	$.redraw()
}
method task_wbangflash() {
	xmid = ($.xmin()+$.xmax())/2
	ymid = ($.ymin()+$.ymax())/2
	for ( i in $.bangees ) {
		xmid2 = (i.xmin()+i.xmax())/2
		ymid2 = (i.ymin()+i.ymax())/2
		Root.line(xy(xmid,ymid,xmid2,ymid2),XOR)
	}
	millisleep(1000)
	for ( i in $.bangees ) {
		xmid2 = (i.xmin()+i.xmax())/2
		ymid2 = (i.ymin()+i.ymax())/2
		Root.line(xy(xmid,ymid,xmid2,ymid2),XOR)
	}
}
method task_wbangmidi {
	Midiin[$] = f = open()
	onexit(closemidi,$)
	while ( (m=get(f)) != Eof ) {
		ph = $.phrase
		if ( m.type==NOTEON ) {
			if ( m.pitch == ph%1.pitch )
				$.bang()
		}
		else if ( m.type == MIDIBYTES ) {
			m.time = m.length = 0
			if ( m == ph%1 )
				$.bang()
		}
	}
}
}

function mkmenu_bang(o,po) {
	o.menucmd("Load Recorded",po,"loadrec")
	o.menucmd("Set Comment",po,"setcomment")
	o.menucmd("Set Message",po,"setmessage")
	o.menucmd("Delete ALL Trigees",po,"clearbangees")
}
