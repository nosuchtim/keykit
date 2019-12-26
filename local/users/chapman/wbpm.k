# Example of sub-classing an existing tool,
# with an intervening hook for one of its methods.

class wbpm {
method init {
	$.w = new window()
	$.inherit($.w)
	$.initval = getbpm()
	$.inc = 0.1
	$.min = 20
	$.max = 400
	$.currval = $.initval
	$.slider = new kslider($.min,$.max,$.initval,$,"do")
	if (defined($.slider.setinc)) {
		$.slider.setinc($.inc)
	}
	$.txt = []
	$.txt["bpm"] = new ktext(string($.initval))
	$.addchild($.slider)
	$.addchild($.txt["bpm"])
}
method redraw {
	$.w.redraw()
	$.w.text("wbpm",$.textxy)
	for ( o in $.children() )
		o.redraw()
}
method do (v) {
	if ( nargs() > 0 )
		if ($.currval != v) {
			$.currval = v
			setbpm(v)
			$.txt["bpm"].set(string(v))
			$.txt["bpm"].redraw()
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

method dump { 
	return(["value"=string($.slider.get())]) 
}

method restore (state) {
	$.set(state["value"])
}
method update { 
	$.slider.do() 
}
method get {
	return($.slider.get()) 
}

method bang { print("Ouch!") }

method set (v,dodraw) {
	$.slider.set(v)
	$.slider.redraw()
	$.do(v)
}
method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	dy = $.textheight() + 4
	x0 = $.xmin()+2
	x1 = $.xmax()-2
#	xw = (x1 - x0) / 2
	$.textxy = xy($.xmin(),$.ymin(),$.xmax(), $.ymin()+$.textheight())
	$.slider.resize(xy(x0,$.ymin()+dy*2, x1,$.ymax()-2))
	$.txt["bpm"].resize(xy(x0,$.ymin()+dy+1, x1,$.ymin()+2*dy-2))
}
}

print("wbpm update")


