class wcontrol {

method init {
	$.w = new window()
	$.inherit($.w)
	# The list of controllers is copied from the controllerlist array
	cl = controllerlist()
	$.cname = []
	$.cval = []
	for ( i in cl ) {
		$.cname[i] = cl[i]["name"]
		$.cval[i] = cl[i]["value"]
	}
	$.c = []
	$.butt1 = new kvalbutton($.cname,$0)
	$.butt2 = new kmenubutton("More","mkmenu_control1",$)
	$.addchild($.butt1)
	$.addchild($.butt2)
	for ( n=1; n<=16; n++ ) {
		$.c[n] = new kslider(0,127,64,$,"doback",n)
		$.addchild($.c[n])
	}
	regicontrol($)
}

method delete { unregicontrol($) }
method get {
	r = ''
	cv = $.cval[$.butt1.get()]
	for ( ch=1; ch<=16; ch++ ) {
		v = $.c[ch].get()
		p = controller(ch,cv,v)
		p.time = ch-1
		r |= p
	}
	r.length = 16
	return(r)
}
method snarf { setsnarf($.get()) }
method send { realmidi($.get()) }
method force (cn,ch,cv) {
	# Find out which controller we're using
	i = $.butt1.get()
	if ( cn != $.cval[i] )
		return()
	$.c[ch].set(cv,1)
}
method setall(v) {
	for ( ch=1; ch<=16; ch++ ) {
		$.c[ch].set(v)
		$.doback(v,ch)
	}
	$.redraw()
}
method setallmin { $.setall(0) }
method setallmid { $.setall(64) }
method setallmax { $.setall(127) }
method doback (val,ch) {
	# Find out which controller we're currently using
	p = controller(ch,$.getcv(),val)
	realmidi(p)
	p.time += Now
	Recorded |= p
}
method getcv { return( $.cval[$.butt1.get()] ) }
method dump {
	st = ["cv"=$.butt1.get()]
	for ( n=1; n<=16; n++ )
		st[n] = $.c[n].get()
	return(st)
}
method restore (st) {
	$.butt1.set(st["cv"])
	for ( n=1; n<=16; n++ )
		$.c[n].set(st[n])
	regicontrol($)
}
method update {
	$.send()
}
method redraw() {
	$.w.redraw()
	th = $.textheight()
	tw = $.textwidth()
	y0 = $.ymin() ; y1 = y0+th+4 ; y2 = y1+th+4; y3 = $.ymax()-4
	x0 = $.xmin()+2 ; xn = $.xmax()-2
	$.text("Controllers",xy(x0+$.dxa,y0,x0+2*$.dxa,y1))
	for ( n=1; n<=16; n++ ) {
		$.text(string(n),xy(x0+(n-1)*$.dxb,y1,xn-(16-n)*$.dxb,y2))
	}
	methodbroadcast()
}

method resize(sz) {
	th = $.textheight()
	tw = $.textwidth()
	if ( nargs() > 0 )
		$.w.resize(sz)
	y0 = $.ymin() ; y1 = y0+th+4 ; y2 = y1+th+4; y3 = $.ymax()-2
	x0 = $.xmin()+2 ; xn = $.xmax()-2
	$.dxa = (xn-x0)/3
	$.dxb = (xn-x0)/16.0
	$.butt1.resize(xy(x0,y0+2,x0+$.dxa,y1))
	$.butt2.resize(xy(x0+2*$.dxa,y0+2,xn,y1))
	for ( n=1; n<=16; n++ )
		$.c[n].resize(xy(x0+(n-1)*$.dxb,y2,xn-(16-n)*$.dxb,y3))
}
}

function mkmenu_control1(o,po) {
	o.menucmd("Send",po,"send")
	o.menucmd("Snarf",po,"snarf")
	o.menucmd("All 100%",po,"setall",127)
	o.menucmd("All 90%",po,"setall",127*90/100)
	o.menucmd("All 80%",po,"setall",127*80/100)
	o.menucmd("All 70%",po,"setall",127*70/100)
	o.menucmd("All 60%",po,"setall",127*60/100)
	o.menucmd("All 50%",po,"setall",127*50/100)
	o.menucmd("All 40%",po,"setall",127*40/100)
	o.menucmd("All 30%",po,"setall",127*30/100)
	o.menucmd("All 20%",po,"setall",127*20/100)
	o.menucmd("All 10%",po,"setall",127*10/100)
	o.menucmd("All 0%",po,"setall",0)
}
