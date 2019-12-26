function joyecho2file() {
	fn = browsefiles("MIDI file to joyecho2","*.mid",1)
	p = readmf(fn)
	joyecho2(p)
}
function joyecho2(fn) {
	if ( nargs() < 1 ) {
		p = readmf("joy2.mid")
	} else if ( typeof(fn) == "string" ) {
		p = readmf(fn)
	} else if ( typeof(fn) == "phrase" ) {
		p = fn
	} else {
		print("Unexpected argument to joyecho2: ",fn)
		return()
	}
	p = onlynotes(p)
	Merge = 0
	s1 = new joyecho2er(p)
	t = new padmonitor()
	t.notify(s1)
	nw = Now
	Root.waitforconsolekey()
	deleteobject(t)
	s1.stop()
	Merge = 1;
}

class joyecho2er {
method init(ph) {
	$.qnt = 2b
	$.randamount = 0
	$.backamount = 0
	$.echoamount = 0
	$.arr = splitonstarts(ph,4b)

	# Per-joystick things
	$.njoy = sizeof(joyinit())
	print("njoy=",$.njoy)
	$.pos = -1
	$.riff = []
	$.necho = []
	$.realtid = []
	$.ch = []
	$.outport = []
	$.octshift = []
	$.totshift = []
	$.pause = []
	$.trill = []
	$.slower = []
	for ( n=0; n<$.njoy; n++ ) {
		$.riff[n] = ''
		$.necho[n] = 16
		$.realtid[n] = -1
		$.ch[n] = n+1
		$.outport[n] = 0
		$.octshift[n] = 0
		$.totshift[n] = 0
		$.pause[n] = 0
		$.trill[n] = 0
		$.slower[n] = 0
	}
	$.echoquant = 1b
	$.triggerquant = 1b/2
}
method delete {
	kill($.realtid)
}
method trigger(j,doecho) {
	if ( nargs() < 1 )
		doecho = 0
	if ( ! (j in $.riff) ) {
		print("No j=",j," in $.riff")
		return()
	}
	tm = Now
	tm = nextquant(tm,$.triggerquant)
	if ( j in $.realtid ) {
		kill($.realtid[j])
	}
print("Playing j=",j)
	$.realtid[j] = task $.steppertask(j,tm)
}
method steppertask(j,tm) {
	dtm = $.riff[j].length
	sz = sizeof($.riff[j])
	for ( i=1; i<4; i++ ) {
		n = 1
		lasttime = 0
		while ( n <= sz ) {
			nt = ($.riff[j]) % n
			playtime = tm + nt.time
			sleeptill(playtime - 2)
			if ( $.pause[j] ) {
				tm += $.triggerquant
				continue
			}
			nt.time = 0
			if ( $.octshift[j] ) {
				$.totshift[j] += $.octshift[j] * 12
				nt.pitch += $.totshift[j]
			}
			if ( $.slower[j] != 0 ) {
				rr = rand(2) * ($.triggerquant)
				tm += rr
				nt.dur += rr
			}
			if ( $.trill[j] != 0 ) {
				nt.length = $.triggerquant / 2
				nt = repeat(nt,4)
				nt.dur = nt.length
				tm += nt.length
			}
			realtime(nt,playtime)
			n++
		}
		tm += dtm
	}
}
method padchanged(j,b,v) {
	if ( v == 0 ) {
		if ( b == "CIRCLE" ) {
			$.trill[j] = 0
		} else if ( b == "RIGHT" ) {
			$.octshift[j] = 0
			$.totshift[j] = 0
		} else if ( b == "UP" ) {
			$.pause[j] = 0
		} else if ( b == "DOWN" ) {
			$.slower[j] = 0
		}
		return()
	}

	if ( b == "X" ) {
		$.pos++

		p = $.arr[$.pos]
		p.chan = $.ch[j]
		p.port = $.outport[j]
		$.riff[j] = p

		$.trigger(j,1)
	} else if ( b == "UP" ) {
		$.pause[j] = 1
	} else if ( b == "DOWN" ) {
		$.slower[j] = 1
	} else if ( b == "CIRCLE" ) {
		# $.octshift[j] = 1
		# $.trigger(j,1)
		$.trill[j] = 1
		$.trigger(j,1)
	} else if ( b == "LEFT" ) {
		$.pos++
		p = $.riff[j] + $.arr[$.pos]
		p.chan = $.ch[j]
		p.port = $.outport[j]
		$.riff[j] = p
		$.trigger(j,1)
	} else if ( b == "RIGHT" ) {
		$.octshift[j] = 1
	} else if ( b == "TRIANGLE" ) {
		$.riff[j] = arpeggio($.riff[j])
		$.riff[j] = step($.riff[j],1b/4)
		$.trigger(j,1)
	} else if ( b == "SQUARE" ) {
		$.riff[j] = stutter($.riff[j],1b/2,2)
		$.trigger(j,1)
	} else if ( b == "UP" ) {
	}
}
method limit(v,minv,maxv) {
	if ( v < minv )
		return(minv)
	if ( v > maxv )
		return(maxv)
	return(v)
}
method play(tm) {
}
method stop {
	for ( i in $.realtid ) {
		kill($.realtid[i])
		$.realtid[i] = -1
	}
}
method taskloop(tm) {
	$.tm = nextquant(tm,$.qnt)
	sz = sizeof($.arr)
	i = 0
	noback = 0
	while ( i < sz ) {
		sleeptill($.tm-4)
	}
}
}
