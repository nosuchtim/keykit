class wriffraf {
method init {
	$.w = new window()
	$.inherit($.w)
	$.b1 = new kmenubutton("More","mkmenu_riffraf1",$)
	$.t1 = new ktoggle("On",$,"setvar","on")
	$.addchild($.b1)
	$.addchild($.t1)

	$.r1 = $.r2 = readmf("funk17.mid")
	eval "#include drums1.kc"
	$.collection = arraycopy(Collection)
	$.ison = 0
	$.leng = 0
	$.stoptids = []
}
method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	y0 = $.ymin()+2
	ym = ($.ymin() + $.ymax())/2
	x0 = $.xmin() + 2
	x1 = $.xmax() - 2
	xm = (x0+x1)/2
	y1 = $.ymax() - 2
	$.t1.resize(xy(x0,ym,xm-1,y1))
	$.b1.resize(xy(xm+1,ym,x1,y1))
	# $.t2.resize(xy(x0+2*dx+1,y0,x1,ym))
	# $.ph.resize(xy(x0,ym+2,x1,y1))
}
method redraw {
	$.w.redraw()
	$.textcenter("Riff Raff",
		xy($.xmin(),$.ymin(),$.xmax(),($.ymin()+$.ymax())/2))
	methodbroadcast()
}

method setvar (v,m,nm) {
	if ( nm == "on" ) {
		if ( v )
			$.tids = riffraff($.r1,$.r2)
		else
			killtids($.tids)
	}
	$.(nm) = v
	return(99)
}
method getcollection { return($.collection) }
method setrhythm (n,rn) {
	if ( rn == 1 )
		$.r1 = $.collection[n]["phrase"]
	else
		$.r2 = $.collection[n]["phrase"]
}
}

function mkmenu_riffraf1(o,po) {
	o.submenu("Rhythm 1 -> ","mkmenu_rrsub",po,1)
	o.submenu("Rhythm 2 -> ","mkmenu_rrsub",po,2)
}

function mkmenu_rrsub(o,po,rn) {
	coll = po.getcollection()
	nc = sizeof(coll)
	for ( n=0; n<nc; n++ ) {
		o.menucmd(coll[n]["name"],po,"setrhythm",n,rn)
	}
}

