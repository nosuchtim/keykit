class wprogch{
method init {
	$.w = new window()
	$.inherit($.w)

	psz = sizeof(Patchmap)
	$.pname = []
	$.pnum = []
	for ( n=0; n<psz; n++ ) {
		$.pname[n] = Patchmap[n]["name"]
		$.pnum[n] = Patchmap[n]["num"]
	}

	$.c = []
	for ( n=1; n<=16; n++ ) {
		$.c[n] = new kvalbutton($.pname,$,"valchanged",n)
		$.addchild($.c[n])
		if (ACPATCHES)
			$.valchanged(0, n)	############## Initialisation
	}
	regiprogram($)
}
method delete {
	unregiprogram($)
}
method valchanged (v,ch) {
	if ( ! (v in $.pnum) )
		error("Hey, v=",v," in valchanged, not in $.pnum ?")
	pn = $.pnum[v]
	if (ACPATCHES){
		# Hack by Stef for GeoMaestro	
		realtime(PourAC(ACPat[pn]["lsb"],ACPat[pn]["pat"],ch))	
	} else {
		realmidi(progchange(pn,ch))
	}
	broadcastprogram(ch,pn)		
}
method force (ch,pn) {
	$.c[ch].set(pn-1)
	if ($ in Root.children() ) $.c[ch].redraw()
}
method dump {
	a = []
	for ( n=1; n<=16; n++ ) { a[n] = $.c[n].get() }
	return(a)
}
method restore (state) {
	for ( n=1; n<=16; n++ ) {
		if (state[n] in Patchmap) { 
			$.c[n].set(state[n]) 
			if (ACPATCHES)
				$.valchanged(state[n], n)
		}
	}
}

method redraw {
	$.w.redraw()
	th = $.textheight()
	tw = $.textwidth()
	y0 = $.ymin() ; y1 = y0+th+4 ; y2 = $.ymax()-4
	x0 = $.xmin() ; x1 = $.xmin()+4*tw+4 ; x2 = $.xmax()
	dy = (y2-y1)/16
	$.text("Ch",xy(x0,y0,x1,y1))
	$.text("Program",xy(x1,y0,x2,y1))
	for ( n=1; n<=16; n++ )
		$.text(string(n), xy(x0,y1+(n-1)*dy,x1,y1+n*dy))
	methodbroadcast()
}

method snarf {
	r = ''
	for ( ch=1; ch<=16; ch++ ) {
		p = progchange($.c[ch].get()+1,ch)
		p.time = ch-1
		r |= p
	}
	r.length = 16
	setsnarf(r)
}

method resize(sz) {
	th = $.textheight()
	tw = $.textwidth()
	if ( nargs() > 0 )
		$.w.resize(sz)
	y0 = $.ymin() ; y1 = y0+th+4 ; y2 = $.ymax()-4
	x0 = $.xmin() ; x1 = $.xmin()+4*tw+4 ; x2 = $.xmax()
	dy = (y2-y1)/16
	for ( n=1; n<=16; n++ )
		$.c[n].resize(xy(x1+1,y1+(n-1)*dy,x2-3,y1+n*dy))
}
}
