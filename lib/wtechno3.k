class wtechno3 {
method init {

	$.w = new window()
	$.inherit($.w)

	arr = []
	for ( n=0; n<16; n++ )
		arr[n] = string(n+1)
	$.b1 = new kvalbutton(arr,$,"nbchanged")
	$.b2 = new kmenubutton("More","mkmenu_technoC_1",$)
	$.kboomtype = 2
	$.bloop = new ktoggle("Loop")
	$.kb = $.newkboom(16)
	$.addchild($.b1)
	$.addchild($.b2)
	$.addchild($.bloop)
	$.addchild($.kb)

	$.transvals = []
	for ( n=0; n<25; n++ )
		$.transvals[n] = string(n-12)

	$.startquant = 1b
	$.stoptids = []
	$.ison = 0
	$.ph = []
	$.buttup = []
	$.buttdown = []
	$.transbutt = []
	$.ph2 = []
	$.buttup2 = []
	$.buttdown2 = []
	$.transbutt2 = []
	$.lastdone = -1

	$.nblocks = 0

	$.initcollection()

	$.setnblocks(8)
	$.bloop.set(1)
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
		if ( $.ph2[n].contains(m) )
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
	st = ["collection"=$.collection]
	st["ph"] = []
	st["ph2"] = []
	for ( n=0; n<$.nblocks; n++ ) {
		st["ph"][n] = $.ph[n].dump()
		st["ph2"][n] = $.ph2[n].dump()
	}
	st["kb"] = $.kb.dump()
	return ( st )
}
method restore (state) {
	$.setcollection(state["collection"])
	$.setnblocks(sizeof(state["ph"]))
	$.resize()
	for ( n in state["ph"] ) {
		ph = state["ph"][n]
		$.ph[n].restore(ph)
	}
	for ( n in state["ph2"] ) {
		ph = state["ph2"][n]
		$.ph2[n].restore(ph)
	}
	$.kb.restore(state["kb"])
	$.redraw()
}
method nbchanged (n) {
	$.setnblocks(n+1)
	$.resize()
	$.redraw()
}
method setcollection (coll) {
	# watch out, this is used in restore,
	# so don't do graphics
	$.collection = arraycopy(coll)
	$.setcollvals($.collection)
}
method getnblocks {
	return($.nblocks)
}
method getcollection {
	return($.collection)
}
method initcollection {
	$.setcollection([0=["name"="One beat","phrase"='r']])
}
method setcollvals (collection) {
	$.collvals = []
	for ( n in collection )
		$.collvals[n] = collection[n]["name"]
}

method setblock (n,cn) {
	ph = $.collection[cn]["phrase"]
	if ( typeof(ph) != "phrase" )
		error("non-phrase found in collection for cn=",cn)
	$.ph[n].set(ph)
}

method dobuttup(n,r) {
	if ( nargs() < 2 )
		r = 1
	p = $.kb.dump()
	# force the kboom tool to be compact
	p["compact"] = 1
	if ( r == 1 ) {
		$.ph[n].restore(p)
		$.ph[n].redraw()
	} else if ( r == 2 ) {
		$.ph2[n].restore(p)
		$.ph2[n].redraw()
	}
	$.updateline(n)
}

method dobuttdown(n,r) {
	if ( nargs() < 2 )
		r = 1
	if ( r == 1 ) {
		p = $.ph[n].dump()
	} else {
		p = $.ph2[n].dump()
	}
	# force the kboom tool to be non-compact
	p["compact"] = 0
	$.kb.restore(p)
	$.kb.resize()
	$.kb.redraw()
	$.updateline(n)
}

method newkboom(...) {
	if ( $.kboomtype == 2 )
		return(new wkboom2(...))
	else
		return(new wkboom(...))
}
method setnblocks (needed) {
	if ( needed <= 0 )
		error("Bad needed value ("+string(needed)+") in setnblocks")
	while ( needed > $.nblocks ) {
		bn = $.nblocks

		$.ph[bn] = $.newkboom(-1,-1,-1,1)	# make it compact
		$.addchild($.ph[bn])

		$.buttup[bn] = new kbutton(global(draw_uparrow),$,"dobuttup",bn)
		$.addchild($.buttup[bn])
		$.buttdown[bn] = new kbutton(global(draw_downarrow),$,"dobuttdown",bn)
		$.addchild($.buttdown[bn])

		$.transbutt[bn] = new kvalbutton($.transvals,$,"technoC_transbutt",bn)
		$.addchild($.transbutt[bn])
		$.transbutt[bn].set(12)

		# SECOND ROW

		$.ph2[bn] = $.newkboom(-1,-1,-1,1)	# make it compact
		$.addchild($.ph2[bn])

		$.buttup2[bn] = new kbutton(global(draw_uparrow),$,"dobuttup",bn,2)
		$.addchild($.buttup2[bn])
		$.buttdown2[bn] = new kbutton(global(draw_downarrow),$,"dobuttdown",bn,2)
		$.addchild($.buttdown2[bn])

		$.transbutt2[bn] = new kvalbutton($.transvals,$,"technoC_transbutt",bn,2)
		$.addchild($.transbutt2[bn])
		$.transbutt2[bn].set(12)

		$.nblocks++
		$.setblock(bn,0)	# initialize
	}
	while ( needed < $.nblocks ) {
		bn = $.nblocks - 1
		$.removechild($.ph[bn]) ; deleteobject($.ph[bn])
		$.removechild($.buttup[bn]) ; deleteobject($.buttup[bn])
		$.removechild($.buttdown[bn]) ; deleteobject($.buttdown[bn])
		$.removechild($.transbutt[bn]) ; deleteobject($.transbutt[bn])

		$.removechild($.ph2[bn]) ; deleteobject($.ph2[bn])
		$.removechild($.buttup2[bn]) ; deleteobject($.buttup2[bn])
		$.removechild($.buttdown2[bn]) ; deleteobject($.buttdown2[bn])
		$.removechild($.transbutt2[bn]) ; deleteobject($.transbutt2[bn])

		$.nblocks--
	}
	$.b1.set($.nblocks-1)
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

method snarf1(n) {
	Snarf = ( $.ph[n].get() | $.ph2[n].get() )
}

method delete1(n) {
	nc = sizeof($.collection)
	for ( i=n+1; i<nc; i++ ) {
		$.collection[i-1] = $.collection[i]
		$.collvals[i-1] = $.collvals[i]
	}
	delete $.collection[nc-1]
	delete $.collvals[nc-1]
	$.setcollvals($.collection)
}

method bangstepat(bn,tm) {
	kb = $.ph[bn]
	tr = $.transbutt[bn].get() - 12
	kb.transposemode("immediate")
	kb.settranspose(tr)
	kb.bang(tm)

	kb2 = $.ph2[bn]
	tr2 = $.transbutt2[bn].get() - 12
	kb2.transposemode("immediate")
	kb2.settranspose(tr2)
	kb2.bang(tm)
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
			sleeptill(stime-1b/2)
			ph = $.ph[bn].get()
			ph2 = $.ph2[bn].get()
			lng = ph.length
			lng2 = ph2.length
			task $.bangstepat(bn,stime)
			if ( lng > lng2 )
				stime += lng
			else
				stime += lng2
		}
		# sleeptill(stime-1b/2)
		if ( $.bloop.get() == 0 || $.ison == 0 )
			break
		$.stoptids = []
		$.stoptids[gettid()] = 1
		startbn = 0
	}
	$.ison = 0
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
	$.ym1a = $.ym1 + th + 4
	$.ym2 = $.ymin() + 2*th + 8

	# The height of the patterns at the top is 4*th, including the
	# up/down buttons
	$.ym3 = $.ym2 + 4*th
	$.ym3b = $.ym3 + 5*th

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

		# upbutton
		txmid = (tx0+tx1)/2
		$.buttdown[n].resize(xy(tx0+1,$.ym3-th,txmid-1,$.ym3))
		# downbutton
		$.buttup[n].resize(xy(txmid+1,$.ym3-th,tx1-1,$.ym3))

		$.transbutt[n].resize(xy(tx0+1,$.ym1+1,tx1-1,$.ym1a-1))

		$.ph[n].resize(xy(tx0+1,$.ym1a+1,tx1-1,$.ym3-th-1))

		$.buttdown2[n].resize(xy(tx0+1,$.ym3b-th,txmid-1,$.ym3b))
		# downbutton
		$.buttup2[n].resize(xy(txmid+1,$.ym3b-th,tx1-1,$.ym3b))

		$.transbutt2[n].resize(xy(tx0+1,$.ym3+1,tx1-1,$.ym3+th+1))

		$.ph2[n].resize(xy(tx0+1,$.ym3+th+1,tx1-1,$.ym3b-th-1))

	}
	$.kb.resize(xy($.x0,$.ym3b+4,$.x1,$.y1))
}

method redraw {
	$.w.redraw()
	$.textleft("Techno!",xy($.x0,$.y0,$.xm1,$.ym1))
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

method addsnarf (p) {
	nc = sizeof($.collection)
	if ( sizeof(Snarf) == 0 )
		print("There is no phrase in the Snarf!?")
	else {
		nm = getastr("Enter name of new phrase in collection --> ")
		$.collection[nc] = ["name"=nm,"phrase"=Snarf]
		$.setcollvals($.collection)
	}
}

method readcollect {
	nm = browsefiles("Key Collection (*.kc)","*.kc",1)
	if ( nm == "" )
		return()
	if ( ! fileexists(nm) )
		error("Can't open file: ",nm)
	eval "#include \""+nm+"\""
	$.setcollection(Collection)

	$.redraw()
}

method writecollect {
	nm = browsefiles("Key Collection (*.kc)","*.kc",0)
	if ( nm == "" )
		return()
	f = open(nm,"w")
	nc = sizeof($.collection)
	put(f,"Collection = [\n")
	sep = ""
	for ( n=0; n<nc; n++ ) {
		put(f,sep+"\t"+string(n)+"=\n")
		put(f,"\t\t[\"name\"=\""+$.collection[n]["name"]+"\",\n")
		put(f,"\t\t\"phrase\"=")
		put(f,$.collection[n]["phrase"])
		put(f,"]")
		sep = ",\n"
	}
	put(f,"\n]\n");
	close(f)
}

method technoC_transbutt(n) {
}

}

function mkmenu_technoC_1(o,po) {
	o.menucmd("Read Collection",po,"readcollect")
	o.menucmd("Write Collection",po,"writecollect")
	o.menucmd("Clear Collection",po,"initcollect")
	o.menucmd("Add Snarf to Collection",po,"addsnarf")
	o.submenu("Start Quant            ->","mkmenu_wrquantvals",po,"setstartquant")
	o.menucmd("Snarf All",po,"snarf")
	o.submenu("Snarf One Block        ->","mkmenu_technoC_3",po)
	o.submenu("Delete From Collection ->","mkmenu_technoC_4",po)
}

function mkmenu_technoC_3(o,po) {
	nc = sizeof(po.getnblocks())
	for ( i=0; i<nc; i++ ) {
		o.menucmd("Block # "+string(i+1),po,"snarf1",i)
	}
}
function mkmenu_technoC_4(o,po) {
	coll = po.getcollection()
	for ( n in coll ) {
		o.menucmd(coll[n]["name"],po,"delete1",n)
	}
}

