function scratch3file() {
	fn = browsefiles("MIDI file to scratch3","*.mid",1)
	p = readmf(fn)
	scratch3(p)
}
function scratch3(fn) {
	if ( nargs() < 1 ) {
		p = readmf("joy2.mid")
	} else if ( typeof(fn) == "string" ) {
		p = readmf(fn)
	} else if ( typeof(fn) == "phrase" ) {
		p = fn
	} else {
		print("Unexpected argument to scratch3: ",fn)
		return()
	}
	p = onlynotes(p)
	Merge = 0
	s1 = new scratch3er(p)
	# s2 = new scratch3er(p)
	# t = task volmonitor([s1=1,s2=2],1)
	# t = task volmonitor([s1=1],1)
	t = new padmonitor()
	t.notify(s1)
	nw = Now
	s1.play(nw)
	# s2.play(nw)
	Root.waitforconsolekey()
	deleteobject(t)
	s1.stop()
	# s2.stop()
	Merge = 1;
}

class scratch3er {
method init(ph) {
	$.qnt = 2b
	$.randamount = 0
	$.backamount = 0
	$.preamount = 0
	$.echoamount = 0
	$.looptid = -1
	$.realtid = -1
	$.arr = splitonstarts(ph)
}
method delete {
	kill($.looptid)
	kill($.realtid)
}
method map_0_127(v,v1,v2) {
	f1 = 0
	f2 = 127
	v = v1 + integer(  ((v-f1) * (v2-v1+1)) / (f2-f1+1) )
	return(v)

}
method padchanged(j,b,v) {
	if ( b == "X" ) {
		$.randamount--
	} else if ( b == "CIRCLE" ) {
		$.randamount++
	} else if ( b == "LEFT" ) {
		$.backamount--
	} else if ( b == "RIGHT" ) {
		$.backamount++
	} else if ( b == "TRIANGLE" ) {
		$.preamount--
	} else if ( b == "SQUARE" ) {
		$.preamount++
	} else if ( b == "UP" ) {
		$.preamount = 0
		$.randamount = 0
		$.backamount = 0
	}
	$.preamount = $.limit($.preamount,0,10)
	$.backamount = $.limit($.backamount,0,10)
	$.randamount = $.limit($.randamount,0,12)
	print("pre=",$.preamount," back=",$.backamount ," rand=",$.randamount)
}
method limit(v,minv,maxv) {
	if ( v < minv )
		return(minv)
	if ( v > maxv )
		return(maxv)
	return(v)
}
method volchanged(ch,v) {
	if ( ch == 1 ) {
		$.randamount = $.map_0_127(v,0,12)
	} else if ( ch == 2 ) {
		# Likelyhook of going back - 0 to 10
		$.backamount = $.map_0_127(v,0,10)
	} else if ( ch == 3 ) {
		# Likelyhook of preecho
		$.preamount = $.map_0_127(v,0,10)
	} else if ( ch == 4 ) {
		$.echoamount = $.map_0_127(v,0,10)
	}
}
method play(tm) {
	$.looptid = task $.taskloop(tm)
}
method stop {
	kill($.looptid)
	kill($.realtid)
	$.looptid = -1
	$.realtid = -1
}
method taskloop(tm) {
	$.tm = nextquant(tm,$.qnt)
	sz = sizeof($.arr)
	i = 0
	noback = 0
	while ( i < sz ) {
		sleeptill($.tm-4)
		if ( $.backamount > 0 ) {
			if ( noback == 0 ) {
				if ( $.backamount >= rand(10) ) {
					i -= 3
					noback = 3
				}
			} else {
				noback--
			}
		}

		if ( i < 0 ) {
			i = 0
		}

		ri = i + rand(1+2*$.randamount) - $.randamount
		if ( ri < 0 )
			ri = 0
		if ( ri >= sz )
			ri = sz-1
		p = $.arr[ri]
		i++
		dt = p.length
		if ( $.preamount > 0 ) {
			if ( $.preamount >= rand(10) ) {
				dtpre = 1b/4
				npre = 2
				prefact = 0.6
				p = p | preecho(p,npre,dtpre,prefact)
				p.time -= (p%1).time
				p.length = dt + npre*dtpre
				dt = p.length
				p = cut(p,CUT_TIME,0,dt,TRUNCATE)
			}
		}
		if ( $.echoamount > 0 ) {
			if ( $.echoamount >= rand(10) ) {
				p = echo(p,2,1b/2,0.6)
				p.length = latest(p)
				dt = p.length
				p = cut(p,CUT_TIME,0,dt,TRUNCATE)
			}
		}
		$.realtid = realtime(p,$.tm)
		$.tm += dt
	}
}
}
