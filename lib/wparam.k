class wparam {
method init {
	$.w = new window()
	$.inherit($.w)

	names = globvarlist()
	$.narr = []
	$.varr = []
	$.vvarr = []
	for ( n=0; n in names; n++ )
		$.narr[n] = names[n]["name"]
	for ( n=0; n in names; n++ )
		$.varr[n] = names[n]["valnames"]
	for ( n=0; n in names; n++ )
		$.vvarr[n] = names[n]["valvals"]
	$.nbutt = new kvalbutton($.narr,$,"namechanged")
	$.vbutt = new kvalbutton($.varr[0],$,"valchanged")
	$.addchild($.nbutt)
	$.addchild($.vbutt)

	# make sure value of first parameter is reflected
	$.namechanged($.nbutt.get(),0)
}
method valchanged (v) {
	n = $.nbutt.get()	# index of name
	cmd = $.narr[n] + "=" + string($.vvarr[n][v])
	eval cmd
}
method namechanged (n,doredraw) {
	$.vbutt.setvals($.varr[n])

	# get current value of that variable
	cmd = "Tmp__ = " + $.narr[n]
	eval cmd
	currval = Tmp__

	# Look it up in vvarr
	ni = sizeof($.vvarr[n])
	for ( i=0; i<ni; i++ ) {
		if ( $.vvarr[n][i] == currval ) {
			break;
		}
	} 
	if ( i >= ni ) {
		print("Hey, didn't find current value of",
			$.narr[n]," in vvarr!?")
		i = 0
	}
	$.vbutt.set(i);
	if ( nargs() < 2 || doredraw!=0 )
		$.vbutt.redraw();

}
method dump {
	return( ["n"=$.nbutt.dump(),"v"=$.vbutt.dump()] )
}
method restore (state) {
	$.nbutt.restore(state["n"])
	$.namechanged($.nbutt.get(),0)
	$.vbutt.restore(state["v"])
	$.valchanged($.vbutt.get())
}

method redraw() {
	$.w.redraw()
	methodbroadcast()
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	$.y0 = $.ymin()+2 ; $.y1 = $.ymax()-2
	$.x0 = $.xmin()+2 ; $.x1 = $.xmax()-2 ; $.xm = ($.x0+$.x1)/2
	$.nbutt.resize(xy($.x0,$.y0,$.xm-1,$.y1))
	$.vbutt.resize(xy($.xm+1,$.y0,$.x1,$.y1))
}
}
