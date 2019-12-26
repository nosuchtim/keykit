function ergodrive(standalone) {
	if ( nargs() == 0 )
		standalone = 1
	if ( defined(Ergo) ) {
		print("Ergo is already running, it will be restarted!")
		if ( Ergo != $-1 )
			deleteobject(Ergo)
	}
	if ( ! defined(ErgoDebug) ) {
		ErgoDebug = 0
	}
	if ( ! defined(ErgoNosend) ) {
		ErgoNosend = 0
	}
	if ( ! defined(Cs32input) ) {
		Cs32input = -1
		Cs32output = -1
	}
	if ( ! defined(Bcf2000input) ) {
		Bcf2000input = -1
		Bcf2000output = -1
	}
	Ergo = new ergodrive_obj(standalone)
	Ergo.clearcs32all()
	Ergo.start()
	if ( standalone )
		print("Ergo is now running (standalone)")
	else
		print("Ergo is now running (routed)")

	if ( ! defined(Ergodrivechecker) ) {
		print("STARTING ERGOCHECKER!")
		Ergodrivechecker = task ergodrive_check()
	}
	ErgoShouldRestart = 0
}
function ergodrive_check() {
	acts = 0
	while ( 1 ) {
		sleeptill(Now+4b)
		if ( ErgoShouldRestart ) {
			print("Restarting ergo!")
			ErgoShouldRestart = 0
			ergodrive(1)
		}
	}
}
class ergodrive_obj {
	method init(standalone) {
		if ( ! defined(Ergoport) )
			Ergoport = "3930@localhost"

		print("Ergoport = ",Ergoport)

		$.responses = 0
		$.standalone = standalone
		$.itid = -1
		$.debug = 0
		$.mfifo = 0
		$.usegesture = 1
		$.gesturerows = 100
		$.gesturecols = 100

		$.butt2num = [
			"TRIANGLE" = 1,
			"CIRCLE" = 2,
			"X" = 3,
			"SQUARE" = 4,
			"L2" = 5,
			"R2" = 6,
			"L1" = 7,
			"R1" = 8,
			"SELECT" = 9,
			"START" = 10
			]

		$.playmode = "shape"

		$.openit()

		if ( $.usegesture && gesturedevices() > 0 ) {
			g = mdep("gesture","devices")
			$.g_width = []
			$.g_height = []
			for ( n in g ) {
				$.g_width[n] = g[n]["width"]
				$.g_height[n] = g[n]["height"]
			}
			gestureclear()
			gesturenotifyrc($,$.gesturerows,$.gesturecols)
		}
		$.chanenabled = []
		for(ch=0;ch<16;ch++)
			$.chanenabled[ch] = 0
		$.joy = getjoymonitor()
		$.joy.notify($,-1)
		$.njoy = sizeof($.joy.devices())
		$.gaspedal = []
		$.wheel = []
		for ( j=0; j<$.njoy; j++ ) {
			$.gaspedal[j] = 0
			$.wheel[j] = 0
		}
		print("THERE ARE ",$.njoy," wheels!")
		$.gas = task $.task_gas()
		$.sendergo("resetcars "+string($.njoy))
	}
	method analogchange(jn,nm,v) {
		if ( $.debug || ErgoDebug )
			print("ANALOGCHANGE jn=",jn," nm=",nm," v=",v)
		if ( nm == "Y" ) {
			# gas pedal
			if ( v < 2000 ) {
				g = 6
			} else if ( v < 8000 ) {
				g = 5
			} else if ( v < 12000 ) {
				g = 4
			} else if ( v < 17000 ) {
				g = 3
			} else if ( v < 21000 ) {
				g = 2
			} else if ( v < 26000 ) {
				g = 1
			} else if ( v < 30000 ) {
				g = 0
			} else if ( v < 32000 ) {
				g = 0
			} else if ( v < 35000 ) {
				g = -1
			} else if ( v < 38000 ) {
				g = -2
			} else if ( v < 46000 ) {
				g = -3
			} else if ( v < 55000 ) {
				g = -4
			} else {
				g = -5
			}
			if ( g != $.gaspedal[jn] ) {
				$.gaspedal[jn] = g
			}
		} else if ( nm == "X" ) {
			# steering wheel
			if ( v < 7000 ) {
				g = 4
			} else if ( v < 12000 ) {
				g = 3
			} else if ( v < 19000 ) {
				g = 2
			} else if ( v < 28000 ) {
				g = 1
			} else if ( v < 37000 ) {
				g = 0
			} else if ( v < 42000 ) {
				g = -1
			} else if ( v < 47000 ) {
				g = -2
			} else if ( v < 58000 ) {
				g = -3
			} else {
				g = -4
			}
			if ( g != $.wheel[jn] ) {
				$.wheel[jn] = g
			}
		
		}
	}
	method buttonchange(jn,nm,v) {
		print("BUTTONCHANGE jn=",jn," nm=",nm," v=",v)
		if ( ! (nm  in $.butt2num) ) {
			print("Button name ",nm," not recognized!")
			return()
		}
		n = $.butt2num[nm]
		if ( v ) {
			cmd = "wheel_buttondown "+string(jn)+" "+string(n)
		} else {
			cmd = "wheel_buttonup "+string(jn)+" "+string(n)
		}
		$.sendergo(cmd)
	}
	method task_gas() {
		lastgas = []
		lastwheel = []
		for ( j=0; j<$.njoy; j++ ) {
			lastgas[j] = -1
			lastwheel[j] = -1
		}
		while (1) {
			sleeptill(Now+1b/8)
			if ( $ == $-1 )
				break
			for ( j=0; j<$.njoy; j++ ) {
				if ( lastgas[j] != 0 || $.gaspedal[j] != lastgas[j] ) {
					cmd = "gas_ping "+string(j)+" "+string($.gaspedal[j])
					# print("TASK_GAS sending ",cmd)
					$.sendergo(cmd)
					lastgas[j] = $.gaspedal[j]
				}
				if ( lastwheel[j] != 0 || $.wheel[j] != lastwheel[j] ) {
					cmd = "wheel_ping "+string(j)+" "+string($.wheel[j])
					# print("TASK_GAS sending ",cmd)
					$.sendergo(cmd)
					lastwheel[j] = $.wheel[j]
				}
			}
		}
	}
	method gotgesture(d) {
		contacts = d["contacts"]
		dev = d["device"]
		w = $.g_width[dev]
		h = $.g_height[dev]
		for ( i=0; i<contacts; i++ ) {
			if ( ! ( i in d ) ) {
				print("No i=",i," in d=",d," ??")
				continue
			}
			di = d[i]
			if ( ! "x" in di ) {
				print("No x in di=",di)
				continue
			}
			x = di["x"] / w
			y = di["y"] / h
			prox = di["proximity"] / h
			f = di["finger"]
			cmd = "finger "+string(f) +" "+string(x)+" "+string(y)+" "+string(prox)
			$.sendergo(cmd)
		}
	}
	method gotgesturerc(t,d,f,r,c,prox) {
		if ( ErgoDebug ) {
			print("gesture t=",t," d=",d," f=",f," rc=",r,c)
		}
		fx = c / float($.gesturecols)
		fy = r / float($.gesturerows)
		# t is fingerup, fingerdown, fingerdrag
		cmd = t+" "+string(d)+" "+string(f) +" "+string(fx)+" "+string(fy)+" "+string(prox)
		$.sendergo(cmd)
	}
	method openit() {
		$.numok = 0
		$.tcp = open(Ergoport,"rw","tcpip_connect")
		fifoctl($.tcp["r"],"type","l")
	}
	method closeit() {
		close($.tcp["w"])
		close($.tcp["r"])
	}
	method setdebug(dbg) {
		$.debug = dbg
	}
	method start() {
		$.itid = task $.task_input()
		return($.itid)
	}
	method delete {
		print("ergo is killing itid and closing sockets\n")
		gestureunnotify($)
		$.joy.unnotify($,-1)
		if ( $.itid >= 0 )
			kill($.itid)
		# put($.tcp["w"],"quit\r\n")
		if ( $ != $-1 )
			$.closeit()
	}

	method set(p) {
		$.play(p)
	}


	method gridcell(r,c,v) {
		# print("Ergo.gridcell r=",r," c=",c," v=",v)
		cmd = "gridcell "+string(r)+" "+string(c)+" "+string(v)
		put($.mfifo,cmd)
	}
	method play(p) {
		# To avoid conflicting with "control" things,
		# force channel 16 to be mapped to channel 1
		p1 = p{??.chan == 16}
		if ( sizeof(p1) != 0 ) {
			p -= p1
			p1.chan = 1
			p |= p1
		}
		stime = Now
		if ( ErgoDebug )
			print("Ergo.play p=",p)
		for ( nt in p ) {
			tm1 = stime + nt.time
			sleeptill(tm1)
			if ( nt.type == NOTE ) {
				tm2 = stime + latest(nt)
				nt.type = NOTEON
				nt.time = 0
				put($.mfifo,nt)
				task $.play_off(tm2,nt)
			} else if ( nt.type == NOTEON ) {
				nt.time = 0
				put($.mfifo,nt)
			} else if ( nt.type == NOTEOFF ) {
				nt.time = 0
				put($.mfifo,nt)
			} else {
				nt.time = 0
				put($.mfifo,nt)
			}
		}
	}

	method play2(p,tm) {
		if ( nargs() < 2 )
			tm = Now
		stime = tm
		for ( nt in p ) {
			tm1 = stime + nt.time
			sleeptill(tm1)
			if ( nt.type == NOTE ) {
				tm2 = stime + latest(nt)
				nt.type = NOTEON
				nt.time = 0
				put($.mfifo,nt)
				task $.play_off(tm2,nt)
			} else if ( nt.type == NOTEON ) {
				nt.time = 0
				put($.mfifo,nt)
			} else if ( nt.type == NOTEOFF ) {
				nt.time = 0
				put($.mfifo,nt)
			} else {
				nt.time = 0
				put($.mfifo,nt)
			}
		}
	}

	method play_off(tm,nt) {
		sleeptill(tm)
		nt.type = NOTEOFF
		put($.mfifo,nt)
	}
	
	method midi_feed(n) {
		# print("Ergo.midi_feed n=",n)
		put($.mfifo,n)
	}

	method task_input {
		if ( $.standalone ) {
			Midiin[$] = $.mfifo = open()
			onexit(closemidi,$)
		} else {
			$.mfifo = open()
		}

		# When toggle light is on,
		# strips are 0 (lower-left) to 31 (upper-right)
		# When toggle light is off,
		# strips are 32 (lower-left) to 63 (upper-right)
		# within each strip, buttrow is 0 (upper), 1 (mid), 2 (lower)

		# sliders are 0 (lower-left) to 31 (upper-right)

		keys=[65="f0",66="f1",67="f2",68="f3",69="f4",
			70="f5",71="f6",72="f7",73="f8",74="f9",
			75="rew",76="fwd",77="ffwd",78="stop",79="rec",
			80="scrub",81="shuttle",
			82="up",83="down",84="left",85="right"]
		keystate = []
		for ( k in keys ) {
			keystate[keys[k]] = 0
		}

		while ( (m=get($.mfifo)) != Eof ) {

			# print("m=",m)
			cmd = ""
			strip = -1
			stripset = -1
			buttrow = -1
			slider = -1
			fbutt = -1
			key = ""
			shuttle = 999
			knob = -1

			if ( typeof(m) == "string" ) {
				cmd = m
			} else if ( m.port == Bcf2000input ) {
				if ( m.type != CONTROLLER )
					continue
				ch = 1 + (subbytes(m,1,1)&0x0f)
				ct = 0+subbytes(m,2,1)
				cv = 0+subbytes(m,3,1)
				if ( ErgoDebug )
					print("BCF ch=",ch," ct=",ct," cv=",cv)
				if ( ct >= 71 && ct <= 82 ) {
					cmd = "bcfslider "+string(ct)+" "+string(cv)
				}
			} else if ( m.port == Cs32input ) {

				# Ignore sysex from cs32
				if ( m.type != CONTROLLER )
					continue

				ch = 1 + (subbytes(m,1,1)&0x0f)
				ct = 0+subbytes(m,2,1)
				cv = 0+subbytes(m,3,1)
				if ( ErgoDebug )
					print("CS32 = ",m," ch=",ch," ct=",ct," cv=",cv)
				if ( ch == 15 ) {
					if ( ct >= 0 && ct < 64 ) {
						buttrow = 0
						strip = ct
					} else if ( ct>=65 && ct<=85 ) {
						key = keys[ct]
					} else {
						print("Unexpected ch=15 and ct=",ct)
					}
				} else if ( ch == 16 ) {
					if ( ct >= 0 && ct < 64 ) {
						slider = 0
						strip = ct
					} else if ( ct>=64 && ct<=69) {
						knobs = [67=0,68=1,69=2,64=3,65=4,66=5]
						knob = knobs[ct]
					} else if ( ct == 96 ) {
						# The shuttle dial
						if ( cv > 64 )
							cv = cv-128
						shuttle = cv
					} else {
						print("Unexpected ch=16 and ct=",ct)
					}
				} else if ( ch == 14 ) {
					if ( ct >= 64 && ct < 128 ) {
						buttrow = 1
						strip = ct - 64
					} else if ( ct >= 0 && ct < 64 ){
						buttrow = 2
						strip = ct
					}
				}

				if ( key != "" ) {
					keystate[key] = cv
					cmd = "cs32key "+string(key)+" "+string(cv)
					if ( keystate["rec"] != 0 && keystate["stop"] ) {
						print("CLEAR ALL! (unimplemented)")
					}
				} else if ( knob >= 0 ) {
					cmd = "cs32knob "+string(knob)+" "+string(cv)
				} else if ( shuttle != 999 ) {
					if ( shuttle != 0 )
						cmd = "cs32shuttle "+string(shuttle)
				} else if ( strip >= 0 && buttrow >= 0 ) {
					if ( buttrow == 1 && strip >=16 && strip < 32 ) {
						# These are the channel enable/disable buttons
						ch = strip-15
						$.chanenabled[ch] = cv
					}
					cmd = "cs32toggle "+string(strip)+" "+string(buttrow)+" "+string(cv)
				} else if ( strip >= 0 && slider >= 0 ) {
					cmd = "cs32slider "+string(strip)+" "+string(cv)
				} else {
					cmd = "cs32other "+string(m)
				}

			} else if ( m.type == NOTEON ) {
				task $.flashchan(m.chan,127,0)
				cmd = "noteon "+string(m.chan)+" "+string(m.pitch)+" "+string(m.vol)
			} else if ( m.type == NOTEOFF ) {
				cmd = "noteoff "+string(m.chan)+" "+string(m.pitch)+" "+string(m.vol)
			} else if ( m.type == CONTROLLER ) {
				ch = 1 + (subbytes(m,1,1)&0x0f)
				# print("ERGO task_input m=",m," ch=",ch)
				ct = 0+subbytes(m,2,1)
				cv = 0+subbytes(m,3,1)
				cmd = "controller "+string(ch)+" "+string(ct)+" "+string(cv)
			} else if ( m.type == PITCHBEND ) {
				ch = 1 + (subbytes(m,1,1)&0x0f)
				ct = 0+subbytes(m,2,1)
				cv = 0+subbytes(m,3,1)
				cmd = "pitchbend "+string(ch)+" "+string(ct)+" "+string(cv)
			}
			if ( cmd != "" )
				$.sendergo(cmd)

		}
	}
	method flashchan(ch,v1,v2) {
		if ( Cs32output < 0 )
			return()
		n = 15 + ch
		a = midibytes('xbe',n,v1)
		a.port = Cs32output
		realtime(a)
		sleeptill(Now+1b/16)
		a = midibytes('xbe',n,v2)
		a.port = Cs32output
		realtime(a)
	}
	method clearcs32all(n) {
		for ( row=0; row<6; row++ ) {
			for ( n=0; n<32; n++ ) {
				$.clearcs32(row,n)
			}
		}
	}
	method clearcs32(row,n) {
		if ( Cs32output < 0 )
			return()
		if ( row == 0 ) {
			a = midibytes('xbe',n,0)
			a.port = Cs32output
			realtime(a)
		} else if ( row == 1 ) {
			a = midibytes('xbd',0x40+n,0)
			a.port = Cs32output
			realtime(a)
		} else if ( row == 2 ) {
			a = midibytes('xbd',n,0)
			a.port = Cs32output
			realtime(a)
		} else if ( row == 3 ) {
			a = midibytes('xbe',0x20+n,0)
			a.port = Cs32output
			realtime(a)
		} else if ( row == 4 ) {
			a = midibytes('xbd',0x60+n,0)
			a.port = Cs32output
			realtime(a)
		} else if ( row == 5 ) {
			a = midibytes('xbd',0x20+n,0)
			a.port = Cs32output
			realtime(a)
		}
	}

	method activity() {
		return($.responses)
	}
	method sendergo(cmd) {
		if ( $.debug || ErgoDebug )
			print("sendergo cmd=",cmd)
		if ( ErgoNosend )
			return()
		if ( ! defined(Ergobuffer) )
			Ergobuffer = 16
		while ( 1 ) {
			lock($)
			a = put($.tcp["w"],cmd+"\r\n")

			s = "OK"
			$.numok++
			# Things were too slow when we read
			# a response on every line, so we only
			# read the responses every once in a while
			if ( $.numok >= Ergobuffer ) {
				for ( i=0; i<$.numok; i++ ) {
					s = get($.tcp["r"])
					if ( s == Eof || s == Interrupt ) {
						print("EOF/INTERRUPT from ergo socket!")
						ErgoShouldRestart = 1
					} else {
						$.responses++
					}
				}
				$.numok = 0
			}
			unlock($)
			if ( typeof(s) == "string" && s ~~ "OK.*" )
				break
			print("Ergo connection broken?  Attempting reconnect...")
			$.closeit()
			millisleep(1000)
			$.openit()
			millisleep(1000)
		}
	}
}
