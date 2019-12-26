class wvoldemo {

method init {
        $.w = new window()
        $.inherit($.w)

        # Add a slider widget as a child
        $.slider = new kslider(0,127,120,$,"volchange")
        $.addchild($.slider)
}
method redraw {
	$.w.redraw()
	methodbroadcast()
}
method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	$.slider.resize($.w.size())
}
method volchange(v) {
	$.value = integer(v)
	p = controller(1,0x07,v)
	realtime(p)
}
method get 		{ return($.slider.get()) }
method set(v) 		{ return($.slider.set(v)) }
method dump 		{ return(["value"=string($.get())]) }
method restore(state)	{ $.set(state["value"]) }
}
