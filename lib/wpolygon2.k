class wpolygon2 {
	method init {
		$.w = new window()
		$.inherit($.w)

		$.fromcolor = 2
		$.tocolor = 10

		$.rval = []
		$.gval = []
		$.bval = []
		$.polypts = []
		$.polydir = []

		$.tid = task $.task_draw()

	}
	method delete {
		kill($.tid)
	}
	method redraw {
		print("wpolygon2 REDRAW")
		$.w.redraw()
	}
	method resize(sz) {
		if ( nargs() > 0 ) {
			$.w.resize(sz)
		}
		dx = $.xmax() - $.xmin()
		dy = $.ymax() - $.ymin()
		for ( rc = 2; rc < 10; rc++ ) {
			$.polypts[rc] = [
				0=xy($.xmin()+rand(dx),$.ymin()+rand(dy)),
				1=xy($.xmin()+rand(dx),$.ymin()+rand(dy)),
				2=xy($.xmin()+rand(dx),$.ymin()+rand(dy))
			]
			$.polydir[rc] = [
				0=xy(rand(8)-4,rand(8)-4),
				1=xy(rand(8)-4,rand(8)-4),
				2=xy(rand(8)-4,rand(8)-4)
			]
			$.rval[rc] = rand(255)*256
			$.gval[rc] = rand(255)*256
			$.bval[rc] = rand(255)*256
		}
	}
	method task_draw {
		while ( 1 ) {
			millisleep(10)

			if ( sizeof($.polypts) == 0 )
				continue;

			for ( rc=2; rc<10; rc++ ) {
				$.w.fillpolygon($.polypts[rc],CLEAR)
			}
			for ( rc=2; rc<10; rc++ ) {
				colormix(rc,$.rval[rc],$.gval[rc],$.bval[rc])
				colorset(rc)
				for ( n in $.polypts[rc] ) {

					$.polypts[rc][n]["x"] += $.polydir[rc][n]["x"]
					if ( $.polypts[rc][n]["x"] > $.xmax() ) {
						$.polypts[rc][n]["x"] = $.xmax()
						$.polydir[rc][n]["x"] = -$.polydir[rc][n]["x"]
					}
					if ( $.polypts[rc][n]["x"] < $.xmin() ) {
						$.polypts[rc][n]["x"] = $.xmin()
						$.polydir[rc][n]["x"] = -$.polydir[rc][n]["x"]
					}

					$.polypts[rc][n]["y"] += $.polydir[rc][n]["y"]
					if ( $.polypts[rc][n]["y"] > $.ymax() ) {
						$.polypts[rc][n]["y"] = $.ymax()
						$.polydir[rc][n]["y"] = -$.polydir[rc][n]["y"]
					}
					if ( $.polypts[rc][n]["y"] < $.ymin() ) {
						$.polypts[rc][n]["y"] = $.ymin()
						$.polydir[rc][n]["y"] = -$.polydir[rc][n]["x"]
					}

					$.rval[rc] += rand(256)
					if ( $.rval[rc] > 256*256 )
						$.rval[rc] = 0
					$.gval[rc] -= rand(256)
					if ( $.gval[rc] < 0 )
						$.gval[rc] = 256*256
					$.bval[rc] += rand(256)
					if ( $.bval[rc] > 256*256 )
						$.bval[rc] = 0
				}
				$.w.fillpolygon($.polypts[rc],STORE)
			}
			colorset(1)
		}
	}
}
