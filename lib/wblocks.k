class wblocks {
method init {

	$.w = new window()
	$.inherit($.w)

	arr = []
	for ( n=0; n<16; n++ )
		arr[n] = string(n+1)
	$.b1 = new kvalbutton(arr,$,"nbchanged")
	$.b2 = new kmenubutton("More","mkmenu_blocks1",$)
	$.bloop = new ktoggle("Loop")
	$.addchild($.b1)
	$.addchild($.b2)
	$.addchild($.bloop)

	$.startquant = 1b
	$.stoptids = []
	$.ison = 0
	$.ph = []
	$.phb = []

	$.nblocks = 0

	$.initcollection()

	$.setnblocks(4)
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
	st = ["collection"=$.collection]
	st["b"] = []
	for ( n=0; n<$.nblocks; n++ )
		st["b"][n] = $.phb[n].get()
	return ( st )
}
method restore (state) {
	$.setcollection(state["collection"])
	$.setnblocks(sizeof(state["b"]))
	$.resize()
	for ( n in state["b"] ) {
		if ( n == "collection" )
			continue
		cn = state["b"][n]
		ph = $.collection[cn]["phrase"]
		$.ph[n].set(ph)
		$.ph[n].fitall(ph)
		$.phb[n].set(cn)
	}
	$.redraw()
}
method nbchanged (n) {
	$.setnblocks(n+1)
	$.resize()
	$.redraw()
}
method phbchanged (cn,bn) {
	$.setblock(bn,cn)
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
	# update kvalbutton vals
	for ( bn=0; bn<$.nblocks; bn++ )  {
		$.phb[bn].setvals($.collvals)
	}
}

method setblock (n,cn) {
	ph = $.collection[cn]["phrase"]
	if ( typeof(ph) != "phrase" )
		error("non-phrase found in collection for cn=",cn)
	$.ph[n].set(ph)
	$.ph[n].fitall(ph)
	$.phb[n].set(cn)
}

method setnblocks (needed) {
	if ( needed <= 0 )
		error("Bad needed value ("+string(needed)+") in setnblocks")
	while ( needed > $.nblocks ) {
		bn = $.nblocks
		$.ph[bn] = new wphrase()
		$.addchild($.ph[bn])
		$.phb[bn] = new kvalbutton($.collvals,$,"phbchanged",bn)
		$.addchild($.phb[bn])
		$.nblocks++
		$.setblock(bn,0)	# initialize
	}
	while ( needed < $.nblocks ) {
		bn = $.nblocks - 1
		$.removechild($.ph[bn]) ; deleteobject($.ph[bn])
		$.removechild($.phb[bn]) ; deleteobject($.phb[bn])
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
	$.ym1 = $.ymin() + $.textheight() + 4
	$.ym2 = $.ymin() + 2*$.textheight() + 8
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
		$.phb[n].resize(xy(tx0+1,$.ym1+1,tx1-1,$.ym2))
		$.ph[n].resize(xy(tx0+1,$.ym2,tx1-1,$.y1))
	}
}

method redraw {
	$.w.redraw()
	$.textleft("Blocks:",xy($.x0,$.y0,$.xm1,$.ym1))
	methodbroadcast();
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

	# reset all buttons
	for ( n=0; n<$.nblocks; n++ )
		$.phb[n].set(0)
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
}

function mkmenu_blocks1(o,po) {
	o.menucmd("Read Collection",po,"readcollect")
	o.menucmd("Write Collection",po,"writecollect")
	o.menucmd("Clear Collection",po,"initcollect")
	o.menucmd("Add Snarf to Collection",po,"addsnarf")
	o.submenu("Start Quant            ->","mkmenu_wrquantvals",po,"setstartquant")
	o.menucmd("Snarf All",po,"snarf")
	o.submenu("Snarf One Block        ->","mkmenu_blocks3",po)
	o.submenu("Delete From Collection ->","mkmenu_blocks4",po)
}

function mkmenu_blocks3(o,po) {
	nc = sizeof(po.getnblocks())
	for ( i=0; i<nc; i++ ) {
		o.menucmd("Block # "+string(i+1),po,"snarf1",i)
	}
}
function mkmenu_blocks4(o,po) {
	coll = po.getcollection()
	for ( n in coll ) {
		o.menucmd(coll[n]["name"],po,"delete1",n)
	}
}
