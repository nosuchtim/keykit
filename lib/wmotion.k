class wmotion {
	method init {
		$.w = new window()
		$.inherit($.w)

		Motion = $

		$.debug = 0
		$.mfifo = 0
		$.volmin = 40 
		$.volmax = 100

		$.playmode = "shape"

		$.param = []

		$.spritelimit = 5
		$.spriteindex = 0
		$.sprites = []
		$.nsprites = 0
		for ( s=0; s<$.spritelimit; s++ )
			$.sprites[s] = $0

		$.motions = []
		n = 0
		$.motions[n++] = global(motion_bounce)
		# $.motions[n++] = global(motion_rand)


		$.shapes = []
		n = 0
		$.shapes[n++] = global(shape_rect)
		$.shapes[n++] = global(shape_ellipse)

		$.control = []

		$.itid = task $.task_input()
		$.gtid = task $.task_draw()


	}
	method delete {
		kill($.itid)
		kill($.gtid)
	}

	method shapemode {
		$.playmode = "shape"
	}
	method hbarmode {
		$.playmode = "hbar"
	}
	method vbarmode {
		$.playmode = "vbar"
	}
	method doerase {
		print("ERASE CALLED!!!")
		$.w.redraw()
	}
	method colorshift {
		print("COLORSHIFT CALLED!!!")
		$.randomize("RED1")
		$.randomize("GREEN1")
		$.randomize("BLUE1")
		$.randomize("RED2")
		$.randomize("GREEN2")
		$.randomize("BLUE2")
	}

	method getparam(s) {
		if ( s in $.param ) {
			v = $.param[s]
			return(v)
		}
		else {
			print("Bad parameter name given to getparam, s=",s)
			return(0.0)
		}
	}
	method setparam(s,v) {
		if ( ! ( s in $.control ) ) {
			print("Bad parameter name given to setparam, s=",s)
			return()
		}
		c = $.control[s]
		# The value coming in is expected to be between 0 and 1.0
		if ( v < 0.0 || v > 1.0 ) {
			print("Bad value given to setparam for s=",s," v=",v)
			return()
		}
		$.param[s] = v
		dp = c["high"] - c["low"]
		$.param[s] = c["low"] + (dp * v)
	}

	method iscontrol(m,s) {
		c = $.control[s]
		if ( (c["type"] ~~ "note.*")
			&& (m.type == NOTEON || m.type == NOTEOFF)
			&& m.pitch == c["pitch"]
			&& m.chan == c["chan"]) {
			if ( m.type == NOTEON )
				return(127)
			else
				return(0)
		}
		if ( c["type"] == "control" && m.type == CONTROLLER
			&& subbytes(m,2,1) == c["val"]
			&& (subbytes(m,1,1)&0x0f) == c["chan"] ) {
			v = subbytes(m,3,1)+0
			return(v)
		}
		return(-1)
	}
	method isanycontrol(m) {
		for ( s in $.control ) {
			if ( $.iscontrol(m,s) >= 0 ) {
				return(1)
			}
		}
		return(0)
	}

	method controlentry_control(m) {
		b1 = subbytes(m,1,1)
		b2 = subbytes(m,2,1)
		return([
			"type"="control","val"=integer(b2),"chan"=(b1&0x0f)
			])
	}

	method controlentry_note_onoff(m) {
		low = 0.0
		high = 1.0
		return([
			"low"=low,"high"=high,
			"type"="noteonoff","pitch"=m.pitch,"chan"=m.chan
			])
	}

	method controlentry_note_on(f) {
		while ( (m=get($.mfifo)).type != NOTEON )
			;
		while ( (m2=get($.mfifo)).type != NOTEOFF )
			;
		return([
			"type"="noteon","pitch"=m.pitch,"chan"=m.chan
			])
	}

	method controlentry_note_toggle() {
		while ( (m=get($.mfifo)).type != NOTEON )
			;
		while ( (m2=get($.mfifo)).type != NOTEOFF )
			;
		return([
			"type"="notetoggle","pitch"=m.pitch,"chan"=m.chan
			])
	}

	method newcontroller() {
		while ((m=get($.mfifo)) != Eof ) {
			isany = $.isanycontrol(m)
			if ( ! isany && m.type == CONTROLLER )
				break
			continue
		}
		return(m)
	}

	method set(p) {
		$.play(p)
	}

	method play(p) {
		stime = Now
		for ( nt in p ) {
			tm1 = stime + nt.time
			sleeptill(tm1)
			tm2 = stime + latest(nt)
			nt.type = NOTEON
			nt.time = 0
			realtime(nt)
			put($.mfifo,nt)
			task $.play_off(tm2,nt)
		}
	}

	method play_off(tm,nt) {
		sleeptill(tm)
		nt.type = NOTEOFF
		realtime(nt)
		put($.mfifo,nt)
	}
	
	method write_control(fn) {
		f = open(fn,"w")
		if ( f < 0 ) {
			print("Can't open ",fn)
			return()
		}
		put(f,$.control)
		close(f)
	}

	method read_control(fn) {
		s = readfile(fn)
		if ( s == "" ) {
			print("No file, or empty: ",fn)
			return()
		}
		print("s=",s)
		eval "MotionControls = "+s
		$.control = MotionControls
		MotionContrlols = 0
	}

	method getanote() {
		while ( (m=get($.mfifo)).type != NOTEON )
			;
		nt = m
		while ( (m=get($.mfifo)).type != NOTEOFF )
			;
		return(nt)
	}

	method setcontrols() {

		print("Hit the redraw on/off note...")
		$.control["REDRAW"] = $.controlentry_note_toggle()

		print("Hit the colorshift on/off note...")
		$.control["COLORSHIFT"] = $.controlentry_note_on()

		print("Hit the XOR on/off note...")
		$.control["XOR"] = $.controlentry_note_toggle()

		print("Hit the HBAR mode on note...")
		$.control["HBAR"] = $.controlentry_note_on()

		print("Hit the VBAR mode on note...")
		$.control["VBAR"] = $.controlentry_note_on()

		print("Hit the SHAPE mode on note...")
		$.control["SHAPE"] = $.controlentry_note_on()

		print("Hit the ERASE note...")
		$.control["ERASE"] = $.controlentry_note_on()

		print("Move rand slider...")
		nc = $.newcontroller()
		$.control["RAND"] = $.controlentry_control(nc)

		print("Move delta slider...")
		nc = $.newcontroller()
		$.control["DELTA"] = $.controlentry_control(nc)

		print("Move Xsize slider...")
		nc = $.newcontroller()
		$.control["XSIZE"] = $.controlentry_control(nc)

		print("Move Ysize slider...")
		nc = $.newcontroller()
		$.control["YSIZE"] = $.controlentry_control(nc)

		print("Move Age slider...")
		nc = $.newcontroller()
		$.control["AGEINC"] = $.controlentry_control(nc)

		print("Move XDIR slider...")
		nc = $.newcontroller()
		$.control["XDIR"] = $.controlentry_control(nc)

		print("Move YDIR slider...")
		nc = $.newcontroller()
		$.control["YDIR"] = $.controlentry_control(nc)

		print("Move Red Initial slider...")
		nc = $.newcontroller()
		$.control["RED1"] = $.controlentry_control(nc)
		print("Move Green Initial slider...")
		nc = $.newcontroller()
		$.control["GREEN1"] = $.controlentry_control(nc)
		print("Move Blue Initial slider...")
		nc = $.newcontroller()
		$.control["BLUE1"] = $.controlentry_control(nc)
		print("Move Red Final slider...")
		nc = $.newcontroller()
		$.control["RED2"] = $.controlentry_control(nc)
		print("Move Green Final slider...")
		nc = $.newcontroller()
		$.control["GREEN2"] = $.controlentry_control(nc)
		print("Move Blue Final slider...")
		nc = $.newcontroller()
		$.control["BLUE2"] = $.controlentry_control(nc)
	}

	method set_defaults() {
		$.control["COLORSHIFT"]["default"] = 0.0
		$.control["ERASE"]["default"] = 0.0
		$.control["HBAR"]["default"] = 0.0
		$.control["VBAR"]["default"] = 0.0
		$.control["SHAPE"]["default"] = 0.0
		$.control["REDRAW"]["default"] = 0.0
		$.control["XOR"]["default"] = 0.0
		$.control["RAND"]["default"] = 0.0
		$.control["DELTA"]["default"] = 0.25
		$.control["XSIZE"]["default"] = 0.5
		$.control["YSIZE"]["default"] = 0.5
		$.control["AGEINC"]["default"] = 1.0
		$.control["XDIR"]["default"] = 0.1
		$.control["YDIR"]["default"] = 0.1
		$.control["RED1"]["default"] = 60000.0
		$.control["GREEN1"]["default"] = 30000.0
		$.control["BLUE1"]["default"] = 0.0
		$.control["RED2"]["default"] = 0.0
		$.control["GREEN2"]["default"] = 30000.0
		$.control["BLUE2"]["default"] = 60000.0

		$.control["COLORSHIFT"]["low"] = 0.0
		$.control["ERASE"]["low"] = 0.0
		$.control["HBAR"]["low"] = 0.0
		$.control["VBAR"]["low"] = 0.0
		$.control["SHAPE"]["low"] = 0.0
		$.control["REDRAW"]["low"] = 0.0
		$.control["XOR"]["low"] = 0.0
		$.control["RAND"]["low"] = 0.0
		$.control["DELTA"]["low"] = 0.01
		$.control["XSIZE"]["low"] = 0.1
		$.control["YSIZE"]["low"] = 0.1
		$.control["XDIR"]["low"] = -0.2
		$.control["YDIR"]["low"] = -0.2
		$.control["AGEINC"]["low"] = 0.1
		$.control["RED1"]["low"] = 0.0
		$.control["GREEN1"]["low"] = 0.0
		$.control["BLUE1"]["low"] = 0.0
		$.control["RED2"]["low"] = 0.0
		$.control["GREEN2"]["low"] = 0.0
		$.control["BLUE2"]["low"] = 0.0

		$.control["COLORSHIFT"]["high"] = 1.0
		$.control["ERASE"]["high"] = 1.0
		$.control["HBAR"]["high"] = 0.0
		$.control["VBAR"]["high"] = 1.0
		$.control["SHAPE"]["high"] = 1.0
		$.control["REDRAW"]["high"] = 1.0
		$.control["XOR"]["high"] = 1.0
		$.control["RAND"]["high"] = 0.1
		$.control["DELTA"]["high"] = 2.0
		$.control["XSIZE"]["high"] = 2.0
		$.control["YSIZE"]["high"] = 2.0
		$.control["XDIR"]["high"] = 0.2
		$.control["YDIR"]["high"] = 0.2
		$.control["AGEINC"]["high"] = 25.0
		$.control["RED1"]["high"] = 65535.0
		$.control["GREEN1"]["high"] = 65535.0
		$.control["BLUE1"]["high"] = 65535.0
		$.control["RED2"]["high"] = 65535.0
		$.control["GREEN2"]["high"] = 65535.0
		$.control["BLUE2"]["high"] = 65535.0

		$.control["COLORSHIFT"]["func"] = "colorshift"
		$.control["ERASE"]["func"] = "doerase"
		$.control["HBAR"]["func"] = "hbarmode"
		$.control["VBAR"]["func"] = "vbarmode"
		$.control["SHAPE"]["func"] = "shapemode"
		$.control["XOR"]["func"] = "xor_change"
	}

	method randomize(s) {
		c = $.control[s]
		dv = c["high"] - c["low"]
		r = rand(10001)
		v = r / 10000.0
		$.setparam(s,v)
	}

	method xor_change(v) {
		if ( v ) 
			mode = XOR
		else
			mode = STORE
		for ( i in $.sprites ) {
			ss = $.sprites[i]
			if ( ss == $0 || ss == $-1 )
				continue
			ss.setmode(mode)
		}
	}

	method vol2f(v) {
		vv = v - $.volmin
		vv = vv * 128 / ($.volmax-$.volmin)
		return(vv/127.0)
	}

	method task_input {
		Midiin[$] = $.mfifo = open()
		print("f = ",$.mfifo)
		onexit(closemidi,$)

		print("Hit a 'C' to set controls, any other key will use previous values...")
		nt = $.getanote()
		if ( canonic(nt) == 0 ) {
			$.setcontrols()
			$.write_control("c:\\motionnew.km")
		} else {
			$.read_control("c:\\motiondefaults.km")
			print("Read controls = ",$.control)
		}

		$.set_defaults()

		for ( s in $.control ) {
			print("Setting default val for s=",s)
			$.param[s] = $.control[s]["default"]
			print("Paramter ",s," is ",$.param[s])
		}

		print("READY FOR MIDI INPUT")

		xoff = 0
		while ( (m=get($.mfifo)) != Eof ) {

			if($.debug) print("GET FROM MFIFO = ",m)

			found = 0
			for ( s in $.control ) {
				c = $.control[s]
				if ( c["type"] == "control" ) {
					if ( (v=$.iscontrol(m,s)) >= 0 ) {
						$.setparam(s,v/127.0)
						found = 1
						break
					}
				} else if ( c["type"] == "noteonoff" ) {
					if ( (v=$.iscontrol(m,s)) >= 0 ) {
						$.setparam(s,v/127.0)
						found = 1
						break
					}
					
				} else if ( c["type"] == "noteon" ) {
					if ( (v=$.iscontrol(m,s)) >= 0 ) {
						if ( m.type == NOTEON ) {
							f = c["func"]
							if ( defined($.(f))) {
								$.(f)()
							} else {
								print("f=",f," is not defined?")
							}
							found = 1
						}
						break
					}
					
				} else if ( c["type"] == "notetoggle" ) {
					if ( (v=$.iscontrol(m,s)) >= 0 ) {
						found = 1
						if ( m.type == NOTEON ) {
							xx = $.getparam(s)
							$.setparam(s,1.0-xx)
							if ( "func" in c ) {
								f = c["func"]
								$.(f)($.getparam(s))
							}
						}
						break
					}
				}
			}

			if ( found != 0 || m.type != NOTEON )
				continue

			lock($)

			if ( $.playmode == "hbar" ) {
				# y position is based on pitch
				yp = ((128-m.pitch) * 3)%128
				y = yp / 128.0
				y2 = y + $.vol2f(m.vol)/10
print("HBAR calling fillrect, y=",y," y2=",y2)
				$.fill_rect(0.0,y,1.0,y2,XOR)

			} else if ( $.playmode == "vbar" ) {
				# y position is based on pitch
				xp = ((128-m.pitch) * 3)%128
				x = xp / 128.0
				x2 = x + $.vol2f(m.vol)/10
print("VBAR calling fillrect, x=",x," x2=",x2)
				$.fill_rect(x,0.0,x2,1.0,XOR)

			} else if ( $.playmode == "shape" ) {

				# x position keeps advancing
				xoff += 4
				xp = xoff%128

				# y position is based on pitch
				yp = ((128-m.pitch) * 3)%128

				dx0 = 0.1*(m.pitch-64)/128
				dy0 = 2*0.1*(m.pitch-64)/128

				dx0 = $.getparam("XDIR")
				dy0 = $.getparam("YDIR")

				if ( dx0 == 0.0 )
					dx0 = 0.01
				if ( dy0 == 0.0 )
					dy0 = 0.01
				x0 = xp / 128.0
				y0 = yp / 128.0

				sfunc = $.shapes[rand(sizeof($.shapes))]

if($.debug)print("\nCREATING NEW SHAPE, xy0=",x0,y0)
				s = new sfunc($, x0, y0)
if($.debug)print("\nCREATING ++++++ NEW SHAPE, s=",s)
				vv = $.vol2f(m.vol)
				sx = vv*($.getparam("XSIZE"))
				sy = vv*($.getparam("YSIZE"))
				s.setscale(sx,sy)
print("xy0 = ",x0,y0,"  sxy=",sx,sy)

				mfunc = $.motions[rand(sizeof($.motions))]
				mobj = new mfunc($)
if($.debug)print("\nCREATING ++++++ NEW MOTIONOBJ, mobj=",mobj)
				mobj.setdxy(dx0,dy0)
				s.addmotion(mobj)
				s.addmotion(new motion_rand($))

				maxage = -1
				found = -1
				for ( i in $.sprites ) {
					ss = $.sprites[i]
					if ( ss == $0 || ss == $-1 ) {
						found = i
						break
					}
					ma = ss.getage()
					if ( ma > maxage ) {
						maxage = ma
						found = i
					}
				}
				if ( found == -1 ) {
					$.sprites[0] = s
					$.nsprites = 1
				} else {
					fs = $.sprites[found]
					if ( fs != $0  && fs != $-1 )
						deleteobject(fs)
					else
						$.nsprites++
					$.sprites[found] = s
				}
			}

			unlock($)
		}
	}
	method redraw {
		$.w.redraw()
		lock($)
		for ( i in $.sprites ) {
			ss = $.sprites[i]
			if ( ss != $0 && ss != $-1 )
				ss.redraw()
		}
		unlock($)
	}
	method resize(sz) {
		if ( nargs() > 0 ) {
			$.w.resize(sz)
		}
		$.dx = $.xmax() - $.xmin()
		$.dy = $.ymax() - $.ymin()
	}
	method draw_line(x0,y0,x1,y1,mode) {
		x0 = $.xmin() + x0 * $.dx
		y0 = $.ymin() + y0 * $.dy
		x1 = $.xmin() + x1 * $.dx
		y1 = $.ymin() + y1 * $.dy
		xy1 = xy(x0,y0,x1,y1)
		$.w.line(xy1,mode)
	}
	method draw_rect(x0,y0,x1,y1,mode) {
		x0 = $.xmin() + x0 * $.dx
		y0 = $.ymin() + y0 * $.dy
		x1 = $.xmin() + x1 * $.dx
		y1 = $.ymin() + y1 * $.dy
		xy1 = xy(x0,y0,x1,y1)
		$.w.rectangle(xy1,mode)
	}
	method fill_rect(x0,y0,x1,y1,mode) {
		x0 = $.xmin() + x0 * $.dx
		y0 = $.ymin() + y0 * $.dy
		x1 = $.xmin() + x1 * $.dx
		y1 = $.ymin() + y1 * $.dy
		xy1 = xy(x0,y0,x1,y1)
		$.w.fillrectangle(xy1,mode)
	}
	method draw_ellipse(x0,y0,x1,y1,mode,fill) {
		if ( nargs() < 6 )
			fill = 0
		x0 = $.xmin() + x0 * $.dx
		y0 = $.ymin() + y0 * $.dy
		x1 = $.xmin() + x1 * $.dx
		y1 = $.ymin() + y1 * $.dy
		xy1 = xy(x0,y0,x1,y1)
		if ( fill )
			$.w.fillellipse(xy1,STORE)
		else
			$.w.ellipse(xy1,STORE)
	}
	method task_draw {
		while ( 1 ) {
			millisleep(20)

			if ( $.nsprites == 0 ) {
				continue;
			}

			lock($)
			if ( $.getparam("REDRAW") > 0 )
				$.w.redraw()
			for ( i in $.sprites ) {
				ss = $.sprites[i]
				if ( ss == $0 || ss == $-1 )
					continue
				ss.move1()
			}
			for ( i in $.sprites ) {
				ss = $.sprites[i]
				if ( ss == $0 || ss == $-1 )
					continue
				rc = 5
				cv = ss.getage()
				if ( cv > 500 ) {
					deleteobject(ss)
					$.sprites[i] = $0
					$.nsprites--
				} else {
					rval1 = $.getparam("RED1")
					gval1 = $.getparam("GREEN1")
					bval1 = $.getparam("BLUE1")
					rval2 = $.getparam("RED2")
					gval2 = $.getparam("GREEN2")
					bval2 = $.getparam("BLUE2")
					cf = cv/500.00
					rval = rval1 + cf*(rval2-rval1) 
					gval = gval1 + cf*(gval2-gval1) 
					bval = bval1 + cf*(bval2-bval1) 
					colormix(rc,rval,gval,bval)
					colorset(rc)
					ss.redraw()
					colorset(1)
				}
			}
			unlock($)
		}
	}
}
