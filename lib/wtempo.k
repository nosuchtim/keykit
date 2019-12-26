class wtempo {

method init {
	$.w = new window()
	$.inherit($.w)
	$.initval = 500000
	$.inc = 10000
	$.min = 10000
	$.max = 1000000
	$.currval = $.initval
	$.slider = new kslider($.min,$.max,$.initval,$,"do")
	$.button1 = new kbutton(global(draw_uparrow),$,"increment")
	$.button2 = new kbutton(global(draw_downarrow),$,"decrement")
	# $.button1.style(NOBORDER)
	# $.button2.style(NOBORDER)
	$.addchild($.slider)
	$.addchild($.button1)
	$.addchild($.button2)
}
method redraw {
	$.w.redraw()
	$.w.text("Tempo",$.textxy)
	for ( o in $.children() )
		o.redraw()
}
method do (v) {
	if ( nargs() > 0 )
		$.currval = v
	# Reverse the direction,
	# so up is faster, and down is slower
	tempo($.max-$.currval+$.min)
	if ( Konnect != $0 ) {
		Konnect.sendtempo(tempo())
	}
}
method increment {
	$.set($.slider.get()+$.inc,1)
	$.slider.do()
}
method decrement {
	$.set($.slider.get()-$.inc,1)
	$.slider.do()
}
method dump { return(["value"=string($.slider.get())]) }
method restore (state) {
	$.set(state["value"])
}
method update { $.slider.do() }
method get {
	# used to be: return($.slider.get()) }
	t = $.max-$.currval+$.min
	return( phrase("'\"Tempo="+string(t)+"\"'") )
}
method bang { print("Ouch!") }
method set (v,dodraw) {
	$.slider.set(v)
	if( nargs() > 1 && dodraw)
		$.slider.redraw()
}
method resize(sz) {
	$.w.resize(sz)
	dy = $.textheight() + 4
	x0 = $.xmin()+2
	x1 = $.xmax()-2
	$.textxy = xy($.xmin(),$.ymin(),$.xmax(), $.ymin()+$.textheight())
	$.slider.resize(xy(x0,$.ymin()+dy*2, x1,$.ymax()-dy))
	$.button1.resize(xy(x0,$.ymin()+dy+1, x1,$.ymin()+2*dy-2))
	$.button2.resize(xy(x0,$.ymax()-dy+2, x1,$.ymax()-2))
}
}
