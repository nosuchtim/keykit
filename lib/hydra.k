function hydra() {

	if ( defined(Hydra) ) {
		print("Hydra is already running, it will be restarted!")
		if ( Hydra != $-1 )
			deleteobject(Hydra)
	}
	if ( ! defined(HydraDebug) ) {
		HydraDebug = 0
	}
	if ( ! defined(HydraNosend) ) {
		HydraNosend = 0
	}
	if ( ! defined(Cs32input) ) {
		Cs32input = -1
		Cs32output = -1
		print("No Cs32input !??!")
	}
	Hydra = new hydra_obj()
	Hydra.clearcs32all()
	Hydra.start()
	print("Hydra is now running")
}
class hydra_obj {
	method init() {

		$.responses = 0
		$.itid = -1
		$.debug = 0
		$.mfifo = 0

		$.playmode = "shape"

		$.openit()

		$.chanenabled = []
		for(ch=0;ch<16;ch++)
			$.chanenabled[ch] = 0
	}
	method openit() {
		$.numok = 0
	}
	method setdebug(dbg) {
		$.debug = dbg
	}
	method start() {
		$.itid = task $.task_input()
		return($.itid)
	}
	method delete {
		print("hydra is killing itid and closing sockets\n")
		if ( $.itid >= 0 )
			kill($.itid)
		# if ( $ != $-1 )
		# 	$.closeit()
	}

	method set(p) {
		$.play(p)
	}


	method gridcell(r,c,v) {
		# print("Hydra.gridcell r=",r," c=",c," v=",v)
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
		if ( HydraDebug )
			print("Hydra.play p=",p)
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
		# print("Hydra.midi_feed n=",n)
		put($.mfifo,n)
	}

	method task_input {
		Midiin[$] = $.mfifo = open()
		onexit(closemidi,$)

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
			} else if ( m.port == Cs32input ) {

				# Ignore sysex from cs32
				if ( m.type != CONTROLLER )
					continue

				ch = 1 + (subbytes(m,1,1)&0x0f)
				ct = 0+subbytes(m,2,1)
				cv = 0+subbytes(m,3,1)
				if ( HydraDebug )
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
				$.sendhydra(cmd)

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
				r = $.clearcs32(row,n)
				r.port = Cs32output
				realtime(r)
			}
		}
	}
	method clearcs32(row,n) {
		if ( Cs32output < 0 )
			return()
		if ( row == 0 ) {
			return(midibytes('xbe',n,0))
		} else if ( row == 1 ) {
			return(midibytes('xbd',0x40+n,0))
		} else if ( row == 2 ) {
			return(midibytes('xbd',n,0))
		} else if ( row == 3 ) {
			return(midibytes('xbe',0x20+n,0))
		} else if ( row == 4 ) {
			return(midibytes('xbd',0x60+n,0))
		} else if ( row == 5 ) {
			return(midibytes('xbd',0x20+n,0))
		} else {
			return('')
		}
	}

	method activity() {
		return($.responses)
	}
	method sendhydra(cmd) {
		print("SENDHYDRA cmd=",cmd)
		mdep("python",cmd)
	}
}
