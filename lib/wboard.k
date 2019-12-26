####################################
# THIS IS AN UNFINISHED TOOL.
# IT DOESN'T DO ANYTHING USEFUL
#
# I think it was supposed to let you sequence a series
# of phrases, letting you adjust the transpose values
# of each with the menus at the top.  I imagine the top row
# of phrases was supposed to be melody, and the bottom
# one was bass/chords.   Who knows - this is unlikely
# to be resurrected, but might serve as an example
# for something.
#
# Actually, the most useful part of this code is the
# example of a pop-up menu in the phrase windows -
# it's the code that starts with:
#       o = new wmenu("mkmenu_boardcell",$,n,row)
#
####################################

class wboard {
method init {

	$.w = new window()
	$.inherit($.w)

	arr = []
	for ( n=0; n<16; n++ )
		arr[n] = string(n+1)
	$.b1 = new kmenubutton("More","mkmenu_board1",$)
	$.bloop = new ktoggle("Loop")
	$.addchild($.b1)
	$.addchild($.bloop)

	$.startquant = 1b
	$.stoptids = []
	$.ison = 0
	$.ph = []
	$.ph2 = []
	$.phb = []

	$.transvals = []
	for ( n=0; n<26; n++ )
		$.transvals[n] = string(n-12)

	$.blocklength = 4b
	$.nblocks = 0	# so setnblocks will be happy
	$.setnblocks(8)
}
method setstartquant (v) { $.startquant = v }
method play (bn) {
	tid = task $.playtask(bn)
	$.stoptids[tid] = 1
}
method playat(n) {
	if ( $.ison )
		$.stop()
	else
		$.play(n)
}
method mousedown (m) {
	for ( n=0; n<$.nblocks; n++ ) {
		if ( $.ph[n].contains(m) ) {
			row = 1
			break
		}
		if ( $.ph2[n].contains(m) ) {
			row = 2
			break
		}
	}
	if ( n >= $.nblocks )
		mouseforward(m,"mousedown")
	else {
		o = new wmenu("mkmenu_boardcell",$,n,row)
		o.setpermanence(1)
		o.resize(xy(m["x"],m["y"]))
		o.mousedown(m)
		Root.addchild(o)

	}
}
method dump {
	st["nblocks"] = $.nblocks
	return ( st )
}
method restore (state) {
	$.setnblocks(stats["nblocks"])
	$.resize()
	$.redraw()
}
method transposechange (cn,bn) {
	$.redraw()
}
method setblock (n,ph,row) {
	ph = syncphr(ph,$.blocklength)
	ph = cut(ph,CUT_TIME,0,$.blocklength)
	ph.length = $.blocklength
	if ( row == 1 ) {
		$.ph[n].set(ph)
		$.ph[n].forceview(0,$.blocklength)
	}
	else {
		$.ph2[n].set(ph)
		$.ph2[n].forceview(0,$.blocklength)
	}
}
method pasteat(n,row) {
	if ( typeof(Snarf) != "phrase" ) {
		print("Error, Snarf doesn't contain a phrase!")
	}
	else if ( sizeof(Snarf) == 0 ) {
		print("Warning, pasting empty phrase...")
	}
	else {
		$.setblock(n,Snarf,row)
		$.redraw()
	}
}

method setnblocks (needed) {
	if ( needed <= 0 )
		error("Bad needed value ("+string(needed)+") in setnblocks")
	while ( needed > $.nblocks ) {
		bn = $.nblocks

		$.ph[bn] = new wphrase()
		$.ph2[bn] = new wphrase()
		$.phb[bn] = new kvalbutton($.transvals,$,"transposechange",bn)
		$.phb[bn].set(12)

		$.addchild($.ph[bn])
		$.addchild($.ph2[bn])
		$.addchild($.phb[bn])

		$.nblocks++
		p = ''
		p.length = $.blocklength
		$.setblock(bn,p,1)
		$.setblock(bn,p,2)
	}
	while ( needed < $.nblocks ) {
		bn = $.nblocks - 1
		$.removechild($.ph[bn]) ; deleteobject($.ph[bn])
		$.removechild($.ph2[bn]) ; deleteobject($.ph2[bn])
		$.removechild($.phb[bn]) ; deleteobject($.phb[bn])
		$.nblocks--
	}
	# $.b1.set($.nblocks-1)
}

method get {
	r = ''
	for ( bn=0; bn<$.nblocks; bn++ ) {
		r += ( $.ph[bn].get() | $.ph2[bn].get() )
	}
	return(r)
}

method snarf {
	Snarf = $.get()
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
			ph = $.ph[bn].get() | $.ph2[bn].get()
			lng = ph.length
			if ( sizeof(ph) != 0 ) {
				tid = $.ph[bn].play(stime,1,0)
				$.stoptids[tid] = 1
				tid2 = $.ph2[bn].play(stime,1,0)
				$.stoptids[tid2] = 1
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
	# tid = task wblockschk(stime+$.looplng)
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
	$.ym1 = $.ymin() + 2
	$.ym2 = $.ym1 + th+2
	tmp = ($.ymax()-$.ym2)/2
	$.ym3 = $.ym2 + tmp

	$.x0 = $.xmin() + 2
	$.x1 = $.xmax() - 2
	dx = ($.x1-$.x0)/4
	$.xm1 = $.x0 + dx
	$.xm2 = $.x0 + 2*dx
	$.xm3 = $.x0 + 3*dx
	$.xm4 = $.x0 + 4*dx

	tx1 = $.x0 + 7 * $.textwidth()
	x0a = tx1

	$.b1.resize(xy($.x0,$.ym2,x0a,$.ym2+th))
	$.bloop.resize(xy($.x0+1,$.ym3,x0a,$.ym3+th))

	for ( n=0; n<$.nblocks; n++ ) {
		tx0 = tx1
		tx1 = x0a + (((n+1)*($.x1-x0a))/$.nblocks)
		$.phb[n].resize(xy(tx0+1,$.ym1+1,tx1-1,$.ym2))
		$.ph[n].resize(xy(tx0+1,$.ym2,tx1-1,$.ym3))
		$.ph2[n].resize(xy(tx0+1,$.ym3,tx1-1,$.y1))
	}
}

method redraw {
	$.w.redraw()
	$.textleft("Board",xy($.x0,$.y0,$.xm1,$.ym2))
	methodbroadcast();
}

}

function mkmenu_board1(o,po) {
	o.submenu("Start Quant            ->","mkmenu_wrquantvals",po,"setstartquant")
	o.menucmd("Snarf All",po,"snarf")
}

function mkmenu_boardcell(o,po,n,row) {
	o.menucmd("Start/Stop",po,"playat",n)
	o.menucmd("Paste",po,"pasteat",n,row)
}
