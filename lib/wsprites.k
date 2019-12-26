class wsprites {
	method init {
		$.w = new window()
		$.inherit($.w)
		$.itid = task $.task_input()
		$.gtid = task $.task_draw()
		$.sprites = []
		$.spritelimit = 10
		$.spriteindex = 0
	}
	method delete {
		kill($.itid)
		kill($.gtid)
	}
	method resize(sz) {
		if ( nargs() > 0 )
			$.w.resize(sz)
		$.x0 = $.xmin()
		$.y0 = $.ymin()
		$.x1 = $.xmax()
		$.y1 = $.ymax()
		$.xsz = $.x1 - $.x0
		$.ysz = $.y1 - $.y0
	}
	method redraw {
		$.w.redraw()
		# print("sz=",$.w.size())
		for ( n in $.sprites ) {
			arr = $.sprites[n]
			s = arr["type"]
			# print("redraw arr=",arr)
			if ( s == "line" ) {
				# print("Prescale =",arr["xy"])
				t = $.xyscale(arr["xy"])
				# print("Drawing line t=",t)
				$.w.line(t)
			} else {
				print("Unknown type: ",s)
			}
		}
	}
	method xyscale(arr) {
		return([
			"x0" = $.x0 + arr["x0"] * $.xsz,
			"y0" = $.y0 + arr["y0"] * $.ysz,
			"x1" = $.x0 + arr["x1"] * $.xsz,
			"y1" = $.y0 + arr["y1"] * $.ysz
			])
	}
	method task_input {
		Midiin[$] = f = open()
		print("f = ",f)
		onexit(closemidi,$)
		while ( (m=get(f)) != Eof ) {
			if ( m.type != NOTEON )
				continue
			print("note ",m)
			xp = (m.pitch * 3)%128

			dx0 = 0.3*(m.pitch-64)/128
			dx1 = 0.3*(m.vol-64)/128

			dy0 = 0.3*(m.pitch-64)/128
			dy1 = 0.3*(m.vol-64)/128

			if ( dy0 == 0.0 )
				dy0 = 0.001
			if ( dy1 == 0.0 )
				dy1 = 0.001
			arr = [
				"type" = "line",
				"xy" = ["x0"=xp * 1.0 / 128,
					"y0"=0.0,
					"x1"=xp * 1.0 / 128,
					"y1"=0.5 * m.vol / 128],
				"dxy" = ["x0"=dx0,
					"y0"=dy0,
					"x1"=dx1,
					"y1"=dy1]
				]
			ns = sizeof($.sprites) 
			if ( ns >= $.spritelimit ) {
				$.sprites[$.spriteindex] = arr
				$.spriteindex++
				if ( $.spriteindex >= $.spritelimit )
					$.spriteindex = 0
			} else {
				n = sizeof($.sprites)
				$.sprites[n] = arr
			}
		}
	}
	method moveit(axy,adxy) {
		axy["x0"] += adxy["x0"]
		axy["y0"] += adxy["y0"]
		axy["x1"] += adxy["x1"]
		axy["y1"] += adxy["y1"]

		if ( axy["x0"] >= 1.0 ) {
			axy["x0"] = 1.0 - (axy["x0"] - 1.0)
			adxy["x0"] = -adxy["x0"]
		} else if ( axy["x0"] < 0.0 ) {
			axy["x0"] = - (axy["x0"])
			adxy["x0"] = -adxy["x0"]
		}

		if ( axy["x1"] >= 1.0 ) {
			axy["x1"] = 1.0 - (axy["x1"] - 1.0)
			adxy["x1"] = -adxy["x1"]
		} else if ( axy["x1"] < 0.0 ) {
			axy["x1"] = - (axy["x1"])
			adxy["x1"] = -adxy["x1"]
		}

		if ( axy["y0"] >= 1.0 ) {
			axy["y0"] = 1.0 - (axy["y0"] - 1.0)
			adxy["y0"] = -adxy["y0"]
		} else if ( axy["y0"] < 0.0 ) {
			axy["y0"] = - (axy["y0"])
			adxy["y0"] = -adxy["y0"]
		}

		if ( axy["y1"] >= 1.0 ) {
			axy["y1"] = 1.0 - (axy["y1"] - 1.0)
			adxy["y1"] = -adxy["y1"]
		} else if ( axy["y1"] < 0.0 ) {
			axy["y1"] = - (axy["y1"])
			adxy["y1"] = -adxy["y1"]
		}

	}
	method task_draw {
		while ( 1 ) {
			millisleep(50)
			for ( n in $.sprites ) {
				# print("sprite n=",n," = ",$.sprites[n])
				arr = $.sprites[n]
				if ( ("xy" in arr) && ("dxy" in arr) ) {
					$.moveit(arr["xy"],arr["dxy"])
				}
			}
			# rc = 2+rand(10)
			# colormix(rc,rand(255)*256,rand(255)*256,rand(255)+256)
			# colorset(rc)

			# colorset(1)
			$.redraw()
		}
	}
}
