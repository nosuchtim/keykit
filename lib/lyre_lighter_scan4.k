class lyre_lighter_scan4 {
method init (burn) {
	$.inherit(new lyre_lighter(burn))
	$.currtid = -1
	$$.lyre.setmaxon(12)
	$.selflimit = 12
}
method activate(tm) {
	$$.lyre.setextra(1b/16)
	$.dir = 1
}
method run(tm) {
}
method scan(starttm,st) {
	if ( $.dir )
		$.scanright(starttm,st)
	else
		$.scanleft(starttm,st)
}
method scanright(starttm,st) {
	$$.addtid(task $$.scantask(starttm,st,0,23,1))
}
method scanleft(starttm,st) {
	$$.addtid(task $$.scantask(starttm,st,23,0,-1))
}
method notefunc(n,t0) {
	if ( n.type == NOTEOFF )
		return()
	starttm = t0+n.time
	d = n.dur
	if ( d > 2b )
		return()
	if ( d <= 0 )
		d = 4
	d /= 4
	$.scan(starttm,d)
	$.dir = 1 - $.dir
}
method scantask(starttm,dt,c1,c2,dc) {
	sleeptill(starttm)
	tm = starttm
	if ( $.lyre.getnumon() > 2 ) {
		return()
	}
	# Scan the strings from c on up
	for ( c=c1; ; c+=dc ) {
		if ( $.lyre.getnumon() < $.selflimit ) {
			$$.lyre.stringonoff(c,tm,tm+dt)
		}
		tm += dt
		sleeptill(tm)
		if ( c == c2 )
			break
	}
}
}

