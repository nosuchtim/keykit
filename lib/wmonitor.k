class wmonitor {
method init {
	$.w = new window()
	$.inherit($.w)

	$.ph = new wphrase()
	$.b1 = new kmenubutton("More","mkmenu_monitor1",$)

	$.chans = []
	for ( n=0; n<16; n++ )
		$.chans[n] = string(n+1)
	$.chans[16] = "ALL"
	$.chanbutt = new kvalbutton($.chans,$,"chanchanged")

	# The list of controllers is copied from the
	# controllerlist() array.
	cl = controllerlist()
	$.valtypes = []
	$.cvalues = []
	for ( i in cl ) {
		$.valtypes[i] = cl[i]["name"]
		$.cvalues[i] = cl[i]["value"]
	}
	lasti = sizeof($.valtypes)
	$.valtypes[lasti] = "ALL"
	$.cvalues[lasti] = -1

	$.ctrlbutt = new kvalbutton($.valtypes,$,"ctrlchanged")

	$.addchild($.ph)
	$.addchild($.b1)
	$.addchild($.chanbutt)
	$.addchild($.ctrlbutt)

	$.chanbutt.set(16)
	$.ctrlbutt.set(lasti)
	$.lookchan = -1
	$.lookctrl = -1

	$.p = ''
	$.limit = 50
	$.step = 1b/8

	$.tid = task $.lookee()
	$.stoptids = [$.tid = 1]
}

method ctrlchanged(v) {
	$.lookctrl = $.cvalues[v]
}
method chanchanged(v) {
	if ( v > 15 )
		$.lookchan = -1
	else
		$.lookchan = v
}

method append(p) {
	p.length = $.step
	p.time = 0
	p.dur = $.step
	$.p += p
	while ( sizeof($.p) > $.limit ) {
		pp = $.p
		pp%1 = ''
		n1 = pp%1
		t = n1.time
		pp.time -= t
		pp.length = $.step * $.limit
		$.p = pp
	}
	$.set($.p,1)
}

method get { return($.p) }

method set (p,doredraw) {
	$.ph.set(p,0)
	$.leng = p.length
	$.ph.dozoomout(0,"x")	# the y dimension is always maxed
	if ( nargs() > 1 && doredraw )
		$.redraw()
	}

method dump {
	return ( [
			"chan"=$.chanbutt.get(),
			"ctrl"=$.ctrlbutt.get()
		] )
}
method restore (state) {
	ch = state["chan"]
	$.chanbutt.set(ch)
	$.chanchanged(ch)

	ct = state["ctrl"]
	$.ctrlbutt.set(ct)
	$.ctrlchanged(ct)
}

method stop {
	killtids($.stoptids)
	$.stoptids = []
}
method delete {
	$.stop()
}

method redraw {
	$.w.redraw()
	$.w.text("Monitor",xy($.x0+1,$.y0,$.x0+2*$.dx+1,$.y0a))
	$.w.text("Ch:",xy($.x0+3*$.dx+1,$.y0,$.x0+4*$.dx+1,$.y0a))
	$.w.text("Ct:",xy($.x0+5*$.dx+1,$.y0,$.x0+6*$.dx+1,$.y0a))
	methodbroadcast()
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	$.dx = ($.xmax()-$.xmin()) / 7
	$.y0 = $.ymin()+2
	$.y0a = $.ymin() + $.textheight() + 4
	$.x0 = $.xmin() + 2
	x1 = $.xmax() - 2
	y1 = $.ymax() - 2
	$.b1.resize(xy($.x0+2*$.dx,$.y0,$.x0+3*$.dx-1,$.y0a))
	$.chanbutt.resize(xy($.x0+4*$.dx+1,$.y0,$.x0+5*$.dx+1,$.y0a))
	$.ctrlbutt.resize(xy($.x0+6*$.dx+1,$.y0,x1,$.y0a))
	$.ph.resize(xy($.x0,$.y0a+2,x1,y1))
}
method lookee(o) {
	Midiin[$] = f = open()
	onexit(global(closemidi),$)
	while ( (nt=get(f)) != Eof ) {
		if ( $.lookchan < 0 || nt.chan == ($.lookchan+1) ) {
			if ( $.lookctrl < 0 ||
				( nt.type == CONTROLLER &&
				  integer(subbytes(nt,2,1) == $.lookctrl ))){

				$.append(nt)
			}
		}
	}
}
method setlimit(n) {
	$.limit = n
}

}

function mkmenu_monitor_limit(o,po) {
	o.menucmd("1",po,"setlimit",1)
	o.menucmd("3",po,"setlimit",3)
	o.menucmd("10",po,"setlimit",10)
	o.menucmd("25",po,"setlimit",25)
	o.menucmd("50",po,"setlimit",50)
	o.menucmd("100",po,"setlimit",100)
	o.menucmd("200",po,"setlimit",200)
}
function mkmenu_monitor1(o,po) {
	o.submenu("Notes to keep -> ","mkmenu_monitor_limit",po)
}

