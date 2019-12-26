class lyre_lighter_scan2 {
method init (burn) {
	$.inherit(new lyre_lighter(burn))
	$.stopme = 0
	$.c = 0
	$.running = 0
	$.dir = 1
	$.dt = 1b/32
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
method beatfunc(t0) {
	# On every beat, randomize the position and dir
	$.c = rand(24)
	$.dir = 1 - 2*rand(2)
}
method run() {
	tm = Now
	# Scan the strings back and forth
	while ( ! $.stopme ) {
		$$.lyre.stringonoff($.c,tm,tm+$.dt)
		tm += $.dt
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
