class lyre_lighter_scan1 {
method init (burn) {
	$.inherit(new lyre_lighter(burn))
	$.stopme = 0
	$.c = 0
	$.running = 0
	$.dir = 1
}
method activate {
	$.lyre.setextra(1b/8)
}
method start {
	if ( ! $.running ) {
		$.running = 1
		$$.addtid(task $.run())
	}
}
method stop {
	$.stopme = 1
}
method notefunc(n,t0) {
	task $.dirswitchtask(n.time+t0)
}
method dirswitchtask(tm) {
	sleeptill(tm)
	# Avoid switching on every note, because
	# purely-stepped music gets it stuck
	if ( rand(3) != 0 ) {
		$.dir = -$.dir
	}
}
method run() {
	dt = 1b/16
	tm = Now
	# Scan the strings back and forth
	while ( ! $.stopme ) {
		$$.lyre.stringonoff($.c,tm,tm+dt)
		tm += dt
		sleeptill(tm)
		$.adjustc($.dir)
	}
	$.running = 0
	$.stopme = 0
}
method adjustc(dc) {
	$.c += dc
	if ( $.c > 23 ) {
		$.dir = -1
		$.c = 22
	} else if ( $.c < 0 ) {
		$.dir = 1
		$.c = 1
	}
}
}
