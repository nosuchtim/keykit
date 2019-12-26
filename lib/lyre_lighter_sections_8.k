class lyre_lighter_sections_8 {
method init (burn) {
	$.inherit(new lyre_lighter(burn))
}
method activate {
	$.nc = 8
}
method notefunc(n,t0) {
	c = (n.pitch) % ($.nc)
	ns = 24 / $.nc
	c1 = c * ns
	dt = 1b/48
	t = t0+n.time
	t2 = t
	if ( rand(2) == 0 ) {
		for ( k=0; k<ns; k++ ) {
			$$.lyre.stringonoff(c1+k,t2,t2+3*dt)
			t2 += dt
		}
	} else {
		for ( k=ns-1; k>=0; k-- ) {
			$$.lyre.stringonoff(c1+k,t2,t2+3*dt)
			t2 += dt
		}
	}
}
method run(t0) {
}
}
