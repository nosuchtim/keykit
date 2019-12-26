class wlyre {

method init (strings) {

	$.w = new window()
	$.inherit($.w)

	$.drawing = 1
	$.nstrings = strings
	$.relayison = []
	$.relayon = []
	$.relayoff = []
	$.ontid = []
	$.ontm = []
	$.offtid = []
	$.offtm = []
	$.extradur = 0
	$.numon = 0
	$.gen = 1
	$.maxgen = MAXCLICKS
	$.maxnumon = 4
	$.hardmaxnumon = 12
	$.x0 = -1
	$.within = milliclicks(200)
	for ( n=0; n<$.nstrings; n++ ) {
		nt = relay(n)
		nt.type = NOTEON
		$.relayon[n] = nt
		nt.type = NOTEOFF
		$.relayoff[n] = nt
		$.ontid[n] = -1
		$.offtid[n] = -1
	}
	$.alloff()
	$.notifyobj = $0
}
method setdrawing(v) {
	$.drawing = v
}
method mousedown(m) {
	n = $.stringnear(m["x"])
	if ( n >= 0 )
		$.stringonoff(n,Now,Now+1b/8)
}
	
method mousedrag(m) {
	n = $.stringnear(m["x"])
	if ( n >= 0 )
		$.stringonoff(n,Now,Now+1b/8)
		
}
method setnotify(o) {
	$.notifyobj = o
}
method setmaxon(v) {
	if ( v > $.hardmaxnumon )
		v = $.hardmaxnumon
	$.maxnumon = v
}
method setextra(n) {
	$.extradur = n
}
method delete {
	$.alloff()
}
method alloff(drawit) {
	if ( nargs() < 1 || $.x0 < 0 )
		drawit = 0
	lock($)
	for ( n=0; n<$.nstrings; n++ ) {
		realtime($.relayoff[n])
		$.relayison[n] = 0
		if ( drawit && $.drawing )
			$.drawstringoff(n)
	}
	$.numon = 0
	unlock($)
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	else
		sz = $.w.size()
	$.x0 = sz["x0"]
	$.y0 = sz["y0"]
	$.x1 = sz["x1"]
	$.y1 = sz["y1"]
	$.xsz = $.x1 - $.x0 + 1
}
method setmode(m) {
	if ( m == CLEAR ) {
		$.onmode = CLEAR
		$.offmode = STORE
	} else {
		$.onmode = STORE
		$.offmode = CLEAR
	}
}
method redraw {
	sz = $.w.size()
	$.w.fillrectangle(xy(sz["x0"]+1,sz["y0"]+1,sz["x1"]-1,sz["y1"]-1),$.offmode)
	for ( n=0; n<$.nstrings; n++ ) {
		x = $.x0 + ((n+1)*$.xsz)/($.nstrings+1)
		$.w.line(xy(x,$.y0,x,$.y1),$.onmode)
	}
	$.w.rectangle($.w.size(),$.onmode)
}
method reset {
	$.alloff()
}
method stringnote(c,n,t0) {
	if ( n.type == NOTE ) {
		$.stringonoff(c,t0+n.time,t0+n.time+n.dur)
	} else if ( n.type == NOTEON ) {
		$.stringon(c,t0+n.time)
	} else if ( n.type == NOTEOFF ) {
		$.stringoff(c,t0+n.time)
	}
}
method stringonoff(n,t1,t2) {
	t = task $.realstringonoff(n,t1,t2+$.extradur)
}
method stringon(n,t1) {
	lock($)
	dome = 1
	if ( $.offtid[n] >= 0 ) {
# print("stringon Killing pending off for n=",n)
		kill($.offtid[n])
		$.offtid[n] = -1
	}
	if ( $.ontid[n] >= 0 ) {
		if ( $.ontm[n] > t1 ) {
# print("stringon Killing later pending on for n=",n)
			kill($.ontid[n])
			$.ontid[n] = -1
		} else {
			dome = 0
# print("stringon is avoiding itself due to earlier stringon")
		}
	}
	if ( dome ) {
# print("stringon spawning realstringon at t1=",t1)
		$.ontid[n] = task $.realstringon(n,t1)
		$.ontm[n] = t1
	}
	unlock($)
}
method stringoff(n,t1) {
	lock($)
	dome = 1
	if ( $.offtid[n] >= 0 ) {
		if ( $.offtm[n] > t1 ) {
# print("stringoff Avoiding stringoff due to pending later off")
			dome = 0
		} else {
# print("stringoff Killing pending off for n=",n)
			kill($.offtid[n])
			$.offtid[n] = -1
		}
	}
	if ( $.ontid[n] >= 0 ) {
		if ( $.ontm[n] > t1 ) {
			dome = 0
# print("stringoff avoiding stringoff due to pending on for n=",n)
		}
	}
	if ( dome ) {
# print("stringoff spawning realstringoff at t1=",t1)
		$.offtid[n] = task $.realstringoff(n,t1)
		$.offtm[n] = t1
	}
	unlock($)
}
method realstringonoff(n,t1,t2) {
	$.realstringon(n,t1)
	$.realstringoff(n,t2)
}
method drawstringon(n) {
	x = $.x0 + ((n+1)*$.xsz)/($.nstrings+1)
	for ( d=-2; d<=2; d++ ) {
		$.w.line(xy(x+d,$.y0+1,x+d,$.y1-1),$.onmode)
	}
}
method getnumon {
	return($.numon)
}
method realstringon(n,t) {
# print("realstringon n=",n," t=",t," I am ",gettid())
	sleeptill(t)
	lock($)
	if ( ! $.relayison[n] ) {
		realtime($.relayon[n])
		$.gen++
		if ( $.gen > $.maxgen ) {
			$.alloff()
			$.gen = 1
		}
		$.relayison[n] = $.gen
		if ( $.drawing )
			$.drawstringon(n)
		$.numon++
		if ( $.numon > $.maxnumon ) {
			oldest_k = -1
			oldest_g = $.gen+1
			for ( k=0; k<$.nstrings; k++ ) {
				g2 = $.relayison[k] 
				if ( g2>0 && g2 < oldest_g ) {
					oldest_k = k
					oldest_g = g2
				}
			}
			if ( oldest_k >= 0 ) {
				$.relayison[oldest_k] = 0
				if ( $.drawing )
					$.drawstringoff(oldest_k)
				$.numon--
			}
		}
	}
	$.ontid[n] = -1
	unlock($)
}
method drawstringoff(n) {
	x = $.x0 + ((n+1)*$.xsz)/($.nstrings+1)
	for ( d=-2; d<=2; d++ ) {
		if ( d == 0 )
			$.w.line(xy(x,$.y0+1,x,$.y1-1),$.onmode)
		else
			$.w.line(xy(x+d,$.y0+1,x+d,$.y1-1),$.offmode)
	}
}

method stringnear(xx) {
	dx = $.xsz/($.nstrings+1)
	for ( n=0; n<$.nstrings; n++ ) {
		x = $.x0 + ((n+1)*$.xsz)/($.nstrings+1)
		dist = xx - x
		if ( dist < 0 )
			dist = -dist
		if ( dist < dx )
			return(n)
	}
	return(-1)
}

method realstringoff(n,t) {
# print("realstringoff n=",n," t=",t," I am ",gettid())
	sleeptill(t)
	lock($)
	if ( $.relayison[n] ) {
		realtime($.relayoff[n])
		$.relayison[n] = 0
		if ( $.drawing )
			$.drawstringoff(n)
		$.numon--
	}
	$.offtid[n] = -1
	unlock($)
}
method setborder(v) {
	$.drawborder = v
}
}
