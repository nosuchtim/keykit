class wellipse {
	method init {
		$.w = new window()
		$.inherit($.w)
		$.tid = task $.task_draw()
	}
	method delete {
		kill($.tid)
	}
	method redraw {
		$.w.redraw()
	}
	method task_draw {
		while ( 1 ) {
			millisleep(100)
			dx = $.xmax() - $.xmin()
			dy = $.ymax() - $.ymin()
			sz = xy($.xmin()+rand(dx),$.ymin()+rand(dy),
					$.xmin()+rand(dx),$.ymin()+rand(dy))

			rc = 2+rand(10)
			colormix(rc,rand(255)*256,rand(255)*256,rand(255)*256)
			colorset(rc)

			if ( rand(2) == 0 )
				$.ellipse(sz)
			else
				$.fillellipse(sz,rand(3)==0?CLEAR:STORE)

			# $.fill(xy($.xmin(),$.ymin(),$.xmax(),$.ymax()),STORE)
			colorset(1)
		}
	}
}
