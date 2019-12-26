class lyre_lighter_pitch_modulo {
method init (burn) {
	$.inherit(new lyre_lighter(burn))
}
method notefunc(n,t0) {
	c = (n.pitch) % 24
	$$.lyre.stringnote(c,n,t0)
}
method run(t0) {
}
}
