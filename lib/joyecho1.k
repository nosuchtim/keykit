function joyecho1file() {
	fn = browsefiles("MIDI file to joyecho1","*.mid",1)
	p = readmf(fn)
	joyecho1(p)
}
function joyecho1(fn) {
	if ( nargs() < 1 ) {
		p = readmf("joy2.mid")
	} else if ( typeof(fn) == "string" ) {
		p = readmf(fn)
	} else if ( typeof(fn) == "phrase" ) {
		p = fn
	} else {
		print("Unexpected argument to joyecho1: ",fn)
		return()
	}
	p = onlynotes(p)
	Merge = 0
	s1 = new joyecho1er(p)
	# s2 = new joyecho1er(p)
	t = new padmonitor()
	t.notify(s1)
	nw = Now
	Root.waitforconsolekey()
	s1.stop()
	deleteobject(t)
	Merge = 1;
}

class joyecho1er {
method init(ph) {
	$.qnt = 2b
	$.randamount = 0
	$.backamount = 0
	$.echoamount = 0
	$.arr = splitonstarts(ph,1b)

	# Per-joystick things
	$.njoy = sizeof(joyinit())
	print("njoy=",$.njoy)
	$.pos = -1
	$.riff = []
	$.necho = []
	$.realtid = []
	$.ch = []
	$.outport = []
	for ( n=0; n<$.njoy; n++ ) {
		$.riff[n] = ''
		$.necho[n] = 16
		$.realtid[n] = -1
		$.ch[n] = n+1
		$.outport[n] = 0
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
	p = $.riff[j]
	if ( doecho != 0 && $.necho[j] > 0 ) {
		leng = p.length
		leng = nextquant(p.length,$.echoquant)
		p = echo(p,$.necho[j],leng,0.98)
	}
	tm = Now
	tm = nextquant(tm,$.triggerquant)
	if ( j in $.realtid )
		kill($.realtid[j])
	p.chan = $.ch[j]
	p.port = $.outport[j]
print("Playing j=",j," chan=",$.ch[j])
	$.realtid[j] = realtime(p,tm)
	
}
method padchanged(j,b,v) {
	if ( v == 0 ) {
		return()
	}
	if ( b == "X" ) {
		$.pos++
		$.riff[j] = $.arr[$.pos]
		$.trigger(j,1)
	} else if ( b == "CIRCLE" ) {
		$.trigger(j,1)
	} else if ( b == "LEFT" ) {
		$.pos++
		$.riff[j] = $.riff[j] + $.arr[$.pos]
		$.trigger(j,1)
	} else if ( b == "RIGHT" ) {
		$.trigger(j,1)
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
