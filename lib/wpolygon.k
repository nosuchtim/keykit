class wpolygon {
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

			pts = [
				0=xy($.xmin()+rand(dx),$.ymin()+rand(dy)),
				1=xy($.xmin()+rand(dx),$.ymin()+rand(dy)),
				2=xy($.xmin()+rand(dx),$.ymin()+rand(dy)),
				3=xy($.xmin()+rand(dx),$.ymin()+rand(dy)),
				4=xy($.xmin()+rand(dx),$.ymin()+rand(dy))
			]
	
			$.fillpolygon(pts,rand(3)==0?CLEAR:STORE)

			colorset(1)
		}
	}
}
