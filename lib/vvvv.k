function vvvv() {

	if ( defined(Vvvv) ) {
		print("Vvvv is already running, it will be restarted!")
		if ( Vvvv != $-1 )
			deleteobject(Vvvv)
	}
	if ( ! defined(VvvvDebug) ) {
		VvvvDebug = 0
	}
	if ( ! defined(VvvvNosend) ) {
		VvvvNosend = 0
	}
	if ( ! defined(Cs32input) ) {
		Cs32input = -1
		Cs32output = -1
		print("No Cs32input !??!")
	}
	Vvvv = new vvvv_obj()
	Vvvv.clearcs32all()
	Vvvv.start()
	print("Vvvv is now running")
}
class vvvv_obj {
	method init() {

		$.responses = 0
		$.itid = -1
		$.debug = 0
		$.mfifo = 0

		$.playmode = "shape"

		$.openit()

		$.nextdevnum = 1
		$.devmap = []  # maps real devices to the 1,2,3 we want
		$.fingmap = []  # map fingers to 1,2,3 as they go down

		$.chanenabled = []
		for(ch=0;ch<16;ch++)
			$.chanenabled[ch] = 0

		$.outport = VVVVoutput
	}
	method openit() {
		$.numok = 0
	}
	method setdebug(dbg) {
		$.debug = dbg
	}
	method start() {
		gesturenotifyrc($,128,128)
		$.itid = task $.task_input()
		return($.itid)
	}
	method delete {
		print("vvvv is killing itid and closing sockets\n")
		if ( $.itid >= 0 )
			kill($.itid)
		if ( $ != $-1 )
			$.closeit()
		gestureunnotify($)
	}
	method gotgesturerc(gtype,dev,fing,r,c,prox) {
		# print("GOTGESTURE ",gtype," dev=",dev," fing=",fing," rc=",r,c)
		if ( ! ( dev in $.devmap ) ) {
			# print("NEW DEVICE, dev=",dev," will be ",$.nextdevnum)
			$.devmap[dev] = $.nextdevnum++
		}
		dev = $.devmap[dev]
		if ( ! (dev in $.fingmap) ) {
			$.fingmap[dev] = []
		}

		if ( sizeof(gesturestatus()) == 0 ) {
			# print("CLEARING fingmap of dev=",dev)
			$.fingmap[dev] = []
			return()
		}

		if ( ! ( fing in $.fingmap[dev] ) ) {
			# print("Adding fing=",fing," to map, before = ",$.fingmap[dev])
			fn = 1 + sizeof($.fingmap[dev])
			$.fingmap[dev][fing] = fn
		}
		fing = $.fingmap[dev][fing]

		# print("MAPPED dev/fing = ",dev," ",fing)

		if ( dev == 1 ) {
			if ( fing == 1 ) {
				# print("FIRST FINGER dev 0")
				# x coord of first finger is controller 2
				p = controller(1,1,c)
				p.port = VVVVoutput
				realtime(p)

				# y coord of first finger is controller 3
				p = controller(1,2,r)
				p.port = VVVVoutput
				realtime(p)

				# prox first finger is controller 4
				pv = integer(prox * 32)
				if ( pv > 127 ) pv = 127
				p = controller(1,3,pv)
				p.port = VVVVoutput
				realtime(p)
			} else if ( fing == 2 ) {
				# print("SECOND FINGER dev 0")
				# x coord of first finger is controller 6
				p = controller(1,5,c)
				p.port = VVVVoutput
				realtime(p)

				# y coord of first finger is controller 7
				p = controller(1,6,r)
				p.port = VVVVoutput
				realtime(p)

				# prox first finger is controller 8
				pv = integer(prox * 32)
				if ( pv > 127 ) pv = 127
				p = controller(1,7,pv)
				p.port = VVVVoutput
				realtime(p)
			}
			
		} else if ( dev == 2 ) {
			if ( fing == 1 ) {
				# print("FIRST FINGER dev 1")
				# x coord of first finger is controller 10
				p = controller(1,9,c)
				p.port = VVVVoutput
				realtime(p)

				# y coord of first finger is controller 11
				p = controller(1,10,r)
				p.port = VVVVoutput
				realtime(p)

				# prox coord of first finger is controller 1
				pv = integer(prox * 32)
				if ( pv > 127 ) pv = 127
				p = controller(1,0,pv)
				p.port = VVVVoutput
				realtime(p)

			}
		} else {
			if ( fing == 1 ) {
				# print("FIRST FINGER dev 1")
				# x coord of first finger is controller 12
				p = controller(1,11,c)
				p.port = VVVVoutput
				realtime(p)

				# y coord of first finger is controller 13
				p = controller(1,12,r)
				p.port = VVVVoutput
				realtime(p)

				# y coord of first finger is controller 14
				pv = integer(prox * 40)
				if ( pv > 127 ) pv = 127
				p = controller(1,13,pv)
				p.port = VVVVoutput
				realtime(p)
			}
		}
	}

	method set(p) {
		$.play(p)
	}


	method gridcell(r,c,v) {
		# print("VVVV.gridcell r=",r," c=",c," v=",v)
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
		if ( VvvvDebug )
			print("Vvvv.play p=",p)
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
		# print("Vvvv.midi_feed n=",n)
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

			# print("VVVV got m=",m)
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
				if ( VvvvDebug )
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
				# print ("buttrow=",buttrow," strip=",strip)

				if ( key != "" ) {
					keystate[key] = cv
					$.cs32key(key,cv)
				} else if ( knob >= 0 ) {
					$.cs32knob(knob,cv)
				} else if ( shuttle != 999 ) {
					if ( shuttle != 0 )
						$.cs32shuttle(shuttle)
				} else if ( strip >= 0 && buttrow >= 0 ) {
					if ( buttrow == 1 && strip >=16 && strip < 32 ) {
						# These are the channel enable/disable buttons
						ch = strip-15
						$.chanenabled[ch] = cv
					}
					$.cs32toggle(strip,buttrow,cv)
				} else if ( strip >= 0 && slider >= 0 ) {
					$.cs32slider(strip,cv)
				} else {
					$.cs32other(m)
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
				$.sendvvvv(cmd)

		}
	}
	method cs32key(key,cv) {
		print("cs32key key=",key," cv=",cv)
	}
	method cs32knob(knob,cv) {
		print("cs32knob knob=",knob," cv=",cv)
	}
	method cs32shuttle(shuttle) {
		print("cs32shuttle = ",shuttle)
	}
	method cs32toggle(strip,buttrow,cv) {
		print("cs32toggle strip=",strip," buttrow=",buttrow," cv=",cv)
		if ( strip >= 16 && strip <= 31 ) {
			p = makenote(strip-16)
			p.dur=1b
			p.vol=127
			p.port = VVVVoutput
			print("Sending p=",p)
			realtime(p)
		}
	}
	method cs32slider(strip,cv) {
		print("cs32slider strip=",strip," cv=",cv)
		if ( strip >= 0 && strip <= 31 ) {
			p = controller(1,strip,cv)
			p.port = VVVVoutput
			print("Sending p=",p)
			realtime(p)
		}
	}
	method cs32other(m) {
		print("CS32 other m=",m," ???")
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
	method sendvvvv(cmd) {
		nt = makenote(0)
		nt.type = 
		nt.port = VVVVoutput
		print("SENDHVVVV cmd=",cmd,"  nt=",nt)
		realtime(nt)
		# mdep("python",cmd)
	}
}
