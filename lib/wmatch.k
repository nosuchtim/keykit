class wmatch {
method init {
	$.w = new window()
	$.inherit($.w)

	$.ph = new wphrase()
	$.b1 = new kmenubutton("More","mkmenu_match1",$)

	$.addchild($.ph)
	$.addchild($.b1)

	$.match = new matchdiagram(0.2,120,800,340, 3,10)
	$.fn = "n:\\htdocs\\match.svg"
}

method redraw {
	$.w.redraw()
	$.w.text("Monitor",xy($.x0+1,$.y0,$.x0+2*$.dx+1,$.y0a))
	$.w.rectangle($.r,STORE)
	methodbroadcast()
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	$.dx = ($.xmax()-$.xmin()) / 7
	$.y0 = $.ymin()+2
	$.y0a = $.ymin() + $.textheight() + 4
	$.x0 = $.xmin() + 2
	$.x1 = $.xmax() - 2
	$.y1 = $.ymax() - 2
	$.yb = ($.y0a + $.y1)/2
	$.b1.resize(xy($.x0+2*$.dx,$.y0,$.x0+3*$.dx-1,$.y0a))
	$.ph.resize(xy($.x0,$.y0a+2,$.x1,$.yb))
	$.r = xy($.x0,$.yb+2,$.x1,$.y1)
	$.w.rectangle($.r,STORE)
}

method get() {
	return($.ph.get())
}

method dump() {
	return(["ph"=$.ph.get()])
}
method restore(st) {
	$.set(st["ph"])
}

method set(ph,doredraw) {
	if ( nargs() < 2 )
		doredraw = 0
	ph = onlynotes(ph)
	ph = strip(ph)
	$.ph.set(ph)
	# $.ph.dozoomout(1,"xy")
	$.ph.fitexact()
	if ( doredraw ) {
		$.ph.redraw()
	}
}

method loadfile {
	ph = browsephrase()
	if ( sizeof(ph) > 0 )
		$.set(ph,1)
}

method loadsnarf {
	if ( sizeof(Snarf) > 0 )
		$.set(Snarf,1)
}

method drawmatch(svg,dostep) {
	ph = $.get()
	$.match.drawmatch(ph,$.w,$.r,svg,dostep,$.fn)
}

}

function mkmenu_match_limit(o,po) {
	o.menucmd("1",po,"setlimit",1)
	o.menucmd("3",po,"setlimit",3)
	o.menucmd("10",po,"setlimit",10)
	o.menucmd("25",po,"setlimit",25)
	o.menucmd("50",po,"setlimit",50)
	o.menucmd("100",po,"setlimit",100)
	o.menucmd("200",po,"setlimit",200)
}
function mkmenu_match1(o,po) {
	o.menucmd("Read File",po,"loadfile")
	o.menucmd("Read Snarf",po,"loadsnarf")
	o.menucmd("Draw Matching Diagram",po,"drawmatch",0,0)
	o.menucmd("Draw Matching Diagram, stepped",po,"drawmatch",0,1)
	o.menucmd("Generate SVG",po,"drawmatch",1,0)
	o.menucmd("Generate SVG, stepped",po,"drawmatch",1,1)
}

