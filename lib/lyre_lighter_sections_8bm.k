class lyre_lighter_sections_8bm {
method init (burn) {
	$.inherit(new lyre_lighter(burn))
}
method activate {
	$.nc = 8
	$.lastpos = 0
	$.lasttm = 0
	$.secttime = 1b/2
}
method notefunc(n,t0) {

	t = t0+n.time

	if ( (t - $.lasttm) < $.secttime ) {
		return()
	}
	$.lasttm = t

	c = (n.pitch) % ($.nc)
	ns = 24 / $.nc

	t2 = t

	p1 = ($.lastpos * ns + ($.lastpos+1)*ns) / 2
	p2 = (c * ns + (c+1) * ns ) / 2

	if ( p2 > p1 ) {
		dt = $.secttime / (p2-p1+1)
		for ( k=p1; k<p2; k++ ) {
			$$.lyre.stringonoff(k,t2,t2+3*dt)
			$$.lyre.stringonoff(23-k,t2,t2+3*dt)
			t2 += dt
		}
		$$.lyre.stringonoff(p2,t2,t2+$.secttime)
		$$.lyre.stringonoff(23-p2,t2,t2+$.secttime)
	} else {
		dt = $.secttime / (p1-p2+1)
		for ( k=p1; k>p2; k-- ) {
			$$.lyre.stringonoff(k,t2,t2+3*dt)
			$$.lyre.stringonoff(23-k,t2,t2+3*dt)
			t2 += dt
		}
		$$.lyre.stringonoff(p2,t2,t2+$.secttime)
		$$.lyre.stringonoff(23-p2,t2,t2+$.secttime)
	}

	$.lastpos = c
}
method run(t0) {
}
}
