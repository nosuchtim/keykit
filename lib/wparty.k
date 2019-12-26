class wparty {
method init {

	$.w = new window()
	$.inherit($.w)

	arr = []
	for ( n=0; n<16; n++ )
		arr[n] = string(n+1)
	$.b1 = new kvalbutton(arr,$,"nbchanged")
	$.b2 = new kmenubutton("More","mkmenu_party1",$)
	$.bloop = new ktoggle("Loop")
	$.kb = $.newtool()
	$.addchild($.b1)
	$.addchild($.b2)
	$.addchild($.bloop)
	$.addchild($.kb)

	$.startquant = 1b
	$.stoptids = []
	$.ison = 0
	$.ph = []
	$.transb = []
	$.buttup = []
	$.buttdown = []
	$.lastdone = -1
	$.transvals = []
	for ( n=0; n<25; n++ ) {
		$.transvals[n] = string(n-12)
	}

	$.nblocks = 0

	$.setnblocks(16)
	$.bloop.set(1)
}
method newtool {
	o = new wgrind()
	return(o)
}
method setstartquant (v) { $.startquant = v }
method play (bn) {
	tid = task $.playtask(bn)
	$.stoptids[tid] = 1
}
method mousedown (m) {
	for ( n=0; n<$.nblocks; n++ ) {
		if ( $.ph[n].contains(m) )
			break
	}
	if ( n >= $.nblocks )
		mouseforward(m,"mousedown")
	else {
		if ( $.ison )
			$.stop()
		else
			$.play(n)
	}
}
method dump {
	st = []
	st["b"] = []
	st["ph"] = []
	for ( n=0; n<$.nblocks; n++ ) {
		st["b"][n] = $.transb[n].get()
		st["ph"][n] = $.ph[n].get()
	}
	st["kb"] = $.kb.dump()
	return ( st )
}
method restore (state) {
	$.setnblocks(sizeof(state["b"]))
	$.resize()
	for ( n in state["b"] ) {
		cn = state["b"][n]
		ph = state["ph"][n]
		$.ph[n].set(ph)
		$.ph[n].fitall(ph)
		$.transb[n].set(cn)
	}
	$.kb.restore(state["kb"])
	$.redraw()
}
method nbchanged (n) {
	$.setnblocks(n+1)
	$.resize()
	$.redraw()
}
method phbchanged (cn,bn) {
	# $.redraw()
}
method getnblocks {
	return($.nblocks)
}

method dobuttup(n) {
	p = $.kb.get()
# print("dobuttup p=",p)
	$.ph[n].set(p)
	g = limitsof(p)
	if ( p != '' && sizeof(g) != 0 ) {
		glow = g["lowest"]
		if ( glow > 2 )
			glow -= 1
		ghigh = g["highest"]
		if ( ghigh < 125 )
			ghigh += 1
		$.ph[n].viewset(xy(0,glow,p.length,ghigh))
	}
	$.ph[n].redraw()
	$.updateline(n)
}

method dobuttdown(n) {
	p = $.ph[n].get()
	if ( sizeof(p) == 0 ) {
		print("No notes in that block!");
	} else {
		$.kb.set(p,1,0)	# redraw, but keep existing drums
		$.updateline(n)
	}
}

method setnblocks (needed) {
	if ( needed <= 0 )
		error("Bad needed value ("+string(needed)+") in setnblocks")
	while ( needed > $.nblocks ) {
		bn = $.nblocks
		$.ph[bn] = new wphrase()
		$.addchild($.ph[bn])
		$.transb[bn] = new kvalbutton($.transvals,$,"phbchanged",bn)
		$.transb[bn].setbyval("0")
		$.addchild($.transb[bn])
		$.buttup[bn] = new kbutton(global(draw_uparrow),$,"dobuttup",bn)
		$.addchild($.buttup[bn])
		$.buttdown[bn] = new kbutton(global(draw_downarrow),$,"dobuttdown",bn)
		$.addchild($.buttdown[bn])
		$.nblocks++
	}
	while ( needed < $.nblocks ) {
		bn = $.nblocks - 1
		$.removechild($.ph[bn]) ; deleteobject($.ph[bn])
		$.removechild($.transb[bn]) ; deleteobject($.transb[bn])
		$.removechild($.buttup[bn]) ; deleteobject($.buttup[bn])
		$.removechild($.buttdown[bn]) ; deleteobject($.buttdown[bn])
		$.nblocks--
	}
	$.b1.set($.nblocks-1)
}

method get {
	r = ''
	for ( bn=0; bn<$.nblocks; bn++ ) {
		r += $.ph[bn].get()
	}
	return(r)
}

method snarf {
	Snarf = $.get()
}

method snarf1(n) {
	Snarf = $.ph[n].get()
}

method playtask (startbn) {
	if ( nargs() < 1 )
		startbn = 0
	$.ison = 1
	qnt = $.startquant
	if ( qnt == 1 )
		stime = Now
	else
		stime = nextquant(Now,qnt)
	while ( 1 ) {
		for ( bn=startbn; bn<$.nblocks; bn++ ) {
			sleeptill(stime-1b/4)
			ph = $.ph[bn].get()
			lng = ph.length
			if ( sizeof(ph) != 0 ) {
				tid = $.ph[bn].play(stime,1,0)
				$.stoptids[tid] = 1
			}
			stime += lng
		}
		# sleeptill(stime-1b/2)
		if ( $.bloop.get() == 0 || $.ison == 0 )
			break
		$.stoptids = []
		$.stoptids[gettid()] = 1
		startbn = 0
	}
	$.ison = 0

	# $.looplng = $.leng
	# tid = task partychk(stime+$.looplng)
	# $.stoptids[tid] = 1
}

method stop {
	killtids($.stoptids)
	$.stoptids = []
	$.ison = 0
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	$.y0 = $.ymin()+2
	$.y1 = $.ymax() - 2
	th = $.textheight()
	$.ym1 = $.ymin() + th + 4
	$.ym2 = $.ymin() + 2*th + 8

	# The height of the patterns at the top is 4*th, including the
	# up/down buttons
	$.ym3 = $.ym2 + 4*th

	$.x0 = $.xmin() + 2
	$.x1 = $.xmax() - 2
	dx = ($.x1-$.x0)/4
	$.xm1 = $.x0 + dx
	$.xm2 = $.x0 + 2*dx
	$.xm3 = $.x0 + 3*dx
	$.xm4 = $.x0 + 4*dx

	$.b1.resize(xy($.xm1,$.y0,$.xm2-1,$.ym1-1))
	$.b2.resize(xy($.xm2+1,$.y0,$.xm3-1,$.ym1-1))
	$.bloop.resize(xy($.xm3+1,$.y0,$.xm4-1,$.ym1-1))
	# $.b4.resize(xy($.xm4+1,$.y0,$.x1,$.ym1-1))

	tx1 = $.x0
	for ( n=0; n<$.nblocks; n++ ) {
		tx0 = tx1
		tx1 = $.x0 + (((n+1)*($.x1-$.x0))/$.nblocks)

		# button
		$.transb[n].resize(xy(tx0+1,$.ym1+1,tx1-1,$.ym2))

		# upbutton
		txmid = (tx0+tx1)/2
		$.buttdown[n].resize(xy(tx0+1,$.ym3-th,txmid-1,$.ym3))
		# downbutton
		$.buttup[n].resize(xy(txmid+1,$.ym3-th,tx1-1,$.ym3))

		$.ph[n].resize(xy(tx0+1,$.ym2,tx1-1,$.ym3-th-1))
	}
	$.kb.resize(xy($.x0,$.ym3+4,$.x1,$.y1))
}

method redraw {
	$.w.redraw()
	$.textleft("Party!",xy($.x0,$.y0,$.xm1,$.ym1))
	methodbroadcast();
	$.updateline()
}

method updateline(n) {
	# draw a line under the last block that was moved in or out
	# of the kboom
	if ( nargs() > 0 )
		$.lastdone = n
	if ( $.lastdone >= 0 ) {
		$.line(xy($.x0,$.ym3+2,$.x1,$.ym3+2),CLEAR)
		sz = $.ph[$.lastdone].size()
		$.line(xy(sz["x0"],$.ym3+2,sz["x1"],$.ym3+2))
	}
}

}

function mkmenu_party1(o,po) {
	o.submenu("Start Quant            ->","mkmenu_wrquantvals",po,"setstartquant")
	o.menucmd("Snarf All",po,"snarf")
	o.submenu("Snarf One Block        ->","mkmenu_party3",po)
}

function mkmenu_party3(o,po) {
	nc = sizeof(po.getnblocks())
	for ( i=0; i<nc; i++ ) {
		o.menucmd("Block # "+string(i+1),po,"snarf1",i)
	}
}

