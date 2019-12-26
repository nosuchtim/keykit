class wprogchx{
method init {
	$.w = new window()
	$.inherit($.w)

	$.playquant = 1
	$.c = []
	$.t = []
	$.collname = ""

	$.morebutt = new kmenubutton("More","mkmenu_wpxmore",$)
	$.addchild($.morebutt)
	$.randbutt = new kbutton("Rand",$,"randomize")
	$.addchild($.randbutt)

	$.pname = []
	$.togall = new ktoggle(" ",$,"dotogall")
	$.addchild($.togall)
	for ( n=1; n<=16; n++ ) {
		$.c[n] = new kvalbutton($.pname,$,"valchanged",n)
		$.addchild($.c[n])
		$.t[n] = new ktoggle(" ")
		$.addchild($.t[n])
		$.t[n].set(n>1?0:1)
	}

	$.pmap = []
	$.setdefaults()

	# $.setcollection("Patchmap")
	for ( n=1; n<=16; n++ ) {
		$.c[n].set(0)
	}

	$.autosnarf = 1
}

method dotogall(v) {
	for ( n=1; n<=16; n++ ) {
		if ( v ) {
			$.t[n].set(1)
		} else {
			$.t[n].set(0)
		}
		$.t[n].redraw()
	}
}
method setdefaults() {
	defouts = midi("portmap")[0]
	outnames = midi("output","list")
	for ( n=1; n<=16; n++ ) {
		out = defouts[n]
		if ( out in Port2Patchmap )
			pmap = Port2Patchmap[out]
		else
			pmap = patchmap_gm()
		pnames = patchmapnames(pmap)
		$.c[n].setvals(pnames)
		$.c[n].set($.c[n].get())

		$.pmap[n] = pmap
	}
}

method setcollection(s,doredraw) {

	if ( s == "" )
		s = "Patchmap"

	$.collname = s
	eval "ARR = "+s
	$.collection = ARR
	$.pnames = patchmapnames($.collection)

	for ( n=1; n<=16; n++ ) {
		$.c[n].setvals($.pnames)
		$.c[n].set($.c[n].get())
		$.pmap[n] = $.collection
	}
	if ( nargs() > 1 && doredraw )
		$.redraw()
}

method delete {
}

method valchanged (v,ch) {

	arr = patchmap_bynum_pmap(v,ch,$.pmap[ch])
	p = arr["patch"]
	$.playthis(p)

	if ( $.autosnarf )
		$.snarf()
}
method dump {
	a = []
	for ( n=1; n<=16; n++ ) { a["c"+string(n)] = $.c[n].get() }
	for ( n=1; n<=16; n++ ) { a["t"+string(n)] = $.t[n].get() }
	a["collname"] = $.collname
	return(a)
}
method restore (state) {
	$.setcollection(state["collname"])
	for ( n=1; n<=16; n++ ) {
		$.c[n].set(state["c"+string(n)])
		$.t[n].set(state["t"+string(n)])
	}
}
method playthis(p) {
	realmidi(p,nextquant(Now,$.playquant))
}

method play {
	$.playthis($.get())
}

method redraw {
	$.w.redraw()
	th = $.textheight()
	tw = $.textwidth()
	y0 = $.ymin() ; y1 = y0+th+4 ; y1b = y0+2*th+4; y2 = $.ymax()-4
	x0 = $.xmin() ; x1 = $.xmin()+4*tw+4 ; x2 = $.xmax()
	dy = (y2-y1b)/16
	$.text("Ch",xy(x0,y1,x1,y1b))
	$.text("Program",xy(x1,y1,x2,y1b))
	for ( n=1; n<=16; n++ )
		$.text(string(n), xy(x0,y1b+(n-1)*dy,x1,y1b+n*dy))
	methodbroadcast()
}

method randomize {
	for ( ch=1; ch<=16; ch++ ) {
		nr = sizeof($.pmap[ch])
		if ( $.t[ch].get() ) {
			$.c[ch].set(rand(nr))
			$.c[ch].redraw()
		}
	}
	$.playthis($.get())
	if ( $.autosnarf )
		$.snarf()
}

method snarf {
	setsnarf($.get())
}

method get {
	r = ''
	for ( ch=1; ch<=16; ch++ ) {
		if ( $.t[ch].get() ) {
			v = $.c[ch].get()
			arr = patchmap_bynum_pmap(v,ch,$.pmap[ch])
			p = arr["patch"]
			r |= p
		}
	}
	r.length = 16
	return(r)
}

method resize(sz) {
	th = $.textheight()
	tw = $.textwidth()
	if ( nargs() > 0 )
		$.w.resize(sz)
	y0 = $.ymin() ; y1 = y0+th+4 ; y1b = y0+2*th+4; y2 = $.ymax()-4
	x0 = $.xmin() ; x1 = $.xmin()+4*tw+4 ; x2 = $.xmax()
	xm = (x0+x2)/2
	$.morebutt.resize(xy(x0,y0,xm-1,y1))
	$.randbutt.resize(xy(xm+1,y0,x2,y1))
	dy = (y2-y1b)/16
	$.togall.resize(xy(x2-2*tw-1,y1b-dy/2,x2-2,y1b-2))
	for ( n=1; n<=16; n++ ) {
		$.c[n].resize(xy(x1+1,y1b+(n-1)*dy,x2-2*tw-3,y1b+n*dy-2))
		$.t[n].resize(xy(x2-2*tw-1,y1b+(n-1)*dy,x2-2,y1b+n*dy-2))
	}
}

method setautosnarf(v) {
	print("v=",v)
	$.autosnarf = v
}
method setplayquant(v) {
	$.playquant = v
}

}

function mkmenu_wpxmore(o,po) {
	o.submenu("Load Patches ->","mkmenu_wpxpatches",po)
	o.submenu("AutoSnarf    ->","mkmenu_wpxsnarf",po)
	o.submenu("Play Quant   ->","mkmenu_wrquantvals",po,"setplayquant")
	o.menucmd("Send",po,"play")
	o.menucmd("Snarf",po,"snarf")
}
function mkmenu_wpxsnarf(o,po) {
	o.menucmd("On",po,"setautosnarf",1)
	o.menucmd("Off",po,"setautosnarf",0)
}
function mkmenu_wpxpatches(o,po) {
	o.menucmd("JV1010 All",po,"setcollection","patchmap_jv1010_all()",1)
	o.menucmd("SC8850 All",po,"setcollection","patchmap_sc8850()",1)
	o.menucmd("Virus B (OS 4.51)",po,"setcollection","patchmap_virusb()",1)
	o.menucmd("TR-Rack",po,"setcollection","patchmap_trrack()",1)
	o.menucmd("General Midi",po,"setcollection","patchmap_gm()")
}
