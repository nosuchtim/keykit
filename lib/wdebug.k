class wdebug {

	method init() {
		$.w = new window()
		$.inherit($.w)
		origfocus = Root.focus()
		$.consw = new wconsole(-1,nullfunc,1)
		$.addchild($.consw)
		Dwindow = $.consw
		Root.focus(origfocus)
	}

	method delete {
		Dwindow = Console
	}

	method resize (sz) {
		if ( nargs() > 0 )
			$.w.resize(sz)
		$.consw.resize(xy($.xmin(),$.ymin(),$.xmax(),$.ymax()))
	}

	method redraw {
		methodbroadcast()
	}
}
