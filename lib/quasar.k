function quasar(standalone) {
	if ( nargs() == 0 )
		standalone = 1
	if ( defined(Quasar) ) {
		print("Quasar is already running, it will be restarted!")
		deleteobject(Quasar)
	}
	Quasar = new quasar_obj(standalone)
	Quasar.start()
	if ( standalone )
		print("Quasar is now running (reading MIDI and gesture)")
	else
		print("Quasar is now running (server only, not reading MIDI input)")
}
class quasar_obj {
	method init(standalone) {

		if ( ! defined(Quasarport) )
			Quasarport = "3931@localhost"

		print("Quasarport = ",Quasarport)

		$.standalone = standalone
		$.itid = -1
		$.debug = 0
		$.mfifo = 0

		$.nrows = 100
		$.ncols = 100

		$.lastfingerrow = []
		$.lastfingercol = []
		for ( f=0; f<10; f++ ) {
			$.lastfingerrow[f] = -1
			$.lastfingercol[f] = -1
		}

		$.openit()
		$.sendquasar("rows "+string($.nrows))
		$.sendquasar("cols "+string($.ncols))

		if ( gesturedevices() > 0 ) {
			g = mdep("gesture","devices")
			$.g_width = []
			$.g_height = []
			for ( n in g ) {
				$.g_width[n] = g[n]["width"]
				$.g_height[n] = g[n]["height"]
			}
			gestureclear()
			gesturenotify($)
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
			x = di["x"]
			y = di["y"]
			row = integer($.nrows * (h-y) / h)
			if ( row >= $.nrows )
				row = $.nrows-1
			else if ( row < 0 )
				row = 0
			col = integer($.ncols * (w-x) / w)
			if ( col >= $.ncols )
				col = $.ncols-1
			else if ( col < 0 )
				col = 0
			row = $.nrows - 1 - row
			col = $.ncols - 1 - col
			# print("finger = ",di["finger"],
			# 	" x=",x," y=",y," rowcol=",row,col)
			f = di["finger"]
			if ( row == $.lastfingerrow[f] && col == $.lastfingercol[f] ) {
				# print("Not sending repeat")
			} else {
				cmd = "finger "+string(f)
					+" "+string(row)+" "+string(col)
				# print("cmd=(",cmd,")")
				$.sendquasar(cmd)
				$.lastfingerrow[f] = row
				$.lastfingercol[f] = col
			}
		}
	}
	method openit() {
		$.tcp = open(Quasarport,"rw","tcpip_connect")
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
		print("quasar is killing itid and closing sockets\n")
		gestureunnotify($)
		if ( $.itid >= 0 )
			kill($.itid)
		$.closeit()
	}

	method set(p) {
		$.play(p)
	}

	method play(p,echoit) {
		if ( nargs() == 1 )
			echoit = 1
		stime = Now
		for ( nt in p ) {
			tm1 = stime + nt.time
			sleeptill(tm1)
			if ( nt.type == NOTE ) {
				tm2 = stime + latest(nt)
				nt.type = NOTEON
				nt.time = 0
				if ( echoit )
					realtime(nt)
				put($.mfifo,nt)
				task $.play_off(tm2,nt,echoit)
			} else if ( nt.type == NOTEON ) {
				nt.time = 0
				if ( echoit )
					realtime(nt)
				put($.mfifo,nt)
			} else if ( nt.type == NOTEOFF ) {
				nt.time = 0
				if ( echoit )
					realtime(nt)
				put($.mfifo,nt)
			} else {
				nt.time = 0
				if ( echoit )
					realtime(nt)
				put($.mfifo,nt)
			}
		}
	}

	method play2(p,tm,echoit) {
		if ( nargs() == 1 )
			echoit = 1
		stime = tm
		for ( nt in p ) {
			tm1 = stime + nt.time
			sleeptill(tm1)
			if ( nt.type == NOTE ) {
				tm2 = stime + latest(nt)
				nt.type = NOTEON
				nt.time = 0
				if ( echoit )
					realtime(nt)
				put($.mfifo,nt)
				task $.play_off(tm2,nt,echoit)
			} else if ( nt.type == NOTEON ) {
				nt.time = 0
				if ( echoit )
					realtime(nt)
				put($.mfifo,nt)
			} else if ( nt.type == NOTEOFF ) {
				nt.time = 0
				if ( echoit )
					realtime(nt)
				put($.mfifo,nt)
			} else {
				nt.time = 0
				if ( echoit )
					realtime(nt)
				put($.mfifo,nt)
			}
		}
	}

	method play_off(tm,nt,echoit) {
		sleeptill(tm)
		nt.type = NOTEOFF
		if ( echoit )
			realtime(nt)
		put($.mfifo,nt)
	}
	
	method task_input {
		if ( $.standalone ) {
			Midiin[$] = $.mfifo = open()
			onexit(closemidi,$)
		} else {
			$.mfifo = open()
		}

		while ( (m=get($.mfifo)) != Eof ) {

			cmd = ""
			if ( m.type == NOTEON ) {
				cmd = "noteon "+string(m.chan)+" "+string(m.pitch)+" "+string(m.vol)
			} else if ( m.type == NOTEOFF ) {
				cmd = "noteoff "+string(m.chan)+" "+string(m.pitch)+" "+string(m.vol)
			} else if ( m.type == CONTROLLER ) {
				ch = 1 + subbytes(m,1,1)&0x0f
				ct = 0+subbytes(m,2,1)
				cv = 0+subbytes(m,3,1)
				cmd = "controller "+string(ch)+" "+string(ct)+" "+string(cv)
			} else if ( m.type == PITCHBEND ) {
				ch = 1 + subbytes(m,1,1)&0x0f
				ct = 0+subbytes(m,2,1)
				cv = 0+subbytes(m,3,1)
				cmd = "pitchbend "+string(ch)+" "+string(ct)+" "+string(cv)
			}
			if ( cmd != "" )
				$.sendquasar(cmd)

		}
	}

	method sendquasar(cmd) {
		if($.debug != 0 || (defined(Quasardebug) && Quasardebug==1))
			print("cmd=",cmd)
		while ( 1 ) {
			lock($)
			a = put($.tcp["w"],cmd+"\r\n")
			s = get($.tcp["r"])
			unlock($)
			if ( typeof(s) == "string" && s ~~ "OK.*" )
				break
			print("Quasar connection broken?  Attempting reconnect...")
			$.closeit()
			millisleep(2000)
			$.openit()
		}
	}
}
