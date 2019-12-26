class lyre_lighter_pitch_scaled {
method init (burn) {
	$.inherit(new lyre_lighter(burn))
}
method notefunc(n,t0) {
	c = 24 * (n.pitch - $$.low) / ($$.high - $$.low + 1)
	$$.lyre.stringnote(c,n,t0)
}
method run(t0) {
}
}
