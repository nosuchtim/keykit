
class wleap {
	method init {
		$.w = new window()
		$.inherit($.w)
		$.tid = task $.task_draw()
		global LeapDisplay
		LeapDisplay = $
	}
	method delete {
		kill($.tid)
		global LeapDisplay
		LeapDisplay = 0
	}
	method redraw {
		$.w.redraw()
	}
	method resize(sz) {
		if ( nargs() > 0 ) {
			$.w.resize(sz)
		}
		$.x0 = $.xmin()+1
		$.x1 = $.xmax()+1
		$.y0 = $.ymin()-1
		$.y1 = $.ymax()-1
		$.width = $.x1 - $.x0
		$.height = $.y1 - $.y0
		$.dx = $.xmax() - $.xmin()
		$.dy = $.ymax() - $.ymin()
	}
	method task_draw {
	}
	method poke(tm,x,y,z) {
		# print("poke xyz=",x,y,z)
		xval = $.x0+($.dx*x)
		yval = $.y1-($.dy*y)
		v = z*z * 100
		x0 = xval-v ; if ( x0 < $.x0 ) x0 = $.x0
		y0 = yval-v ; if ( y0 < $.y0 ) y0 = $.y0
		x1 = xval+v ; if ( x1 > $.x1 ) x1 = $.x1
		y1 = yval+v ; if ( y1 > $.y1 ) y1 = $.y1
		sz = xy(x0,y0,x1,y1)
		# print("sz=",sz)

		task $.flash(tm,sz)
	}
	method flash(tm,sz) {
		sleeptill(tm)
		rc = 2+rand(10)
		colormix(rc,rand(255)*256,rand(255)*256,rand(255)*256)
		colorset(rc)
		$.fillrectangle(sz,STORE)
		millisleep(500)
		$.fillrectangle(sz,CLEAR)
		colorset(1)
	}
}
