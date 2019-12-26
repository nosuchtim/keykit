class lyre_lighter_scan3b {
method init (burn) {
	$.inherit(new lyre_lighter(burn))
	$.currtid = -1
	$$.lyre.setmaxon(24)
	$.selflimit = 24
}
method activate(tm) {
	$.step = milliclicks(50)
	$$.lyre.setextra(1b/16)
	$.dir = 1
}
method run(tm) {
}
method scan(starttm) {
	if ( $.dir )
		$.scanright(starttm)
	else
		$.scanleft(starttm)
}
method scanright(starttm) {
	$$.addtid(task $$.scantask(starttm,$.step,0,23,1))
}
method scanleft(starttm) {
	$$.addtid(task $$.scantask(starttm,$.step,23,0,-1))
}
method notefunc(n,t0) {
	if ( n.type == NOTEOFF )
		return()
	starttm = t0+n.time
	$.scan(starttm)
	if ( n.type == NOTE ) {
		# For longer notes, add another scan to
		# to make it thicker
		if ( n.dur > 1b/4 ) {
			starttm += $.step
			$.scan(starttm)
		}
	}
	$.dir = 1 - $.dir
}
method scantask(starttm,dt,c1,c2,dc) {
	r = rand(3)
	if ( r == 0 )
		dt /= 2
	else if ( r == 1 ) 
		dt /= 4
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
