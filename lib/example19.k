function example19() {
	o = []
	f = []
	for ( i=1; i<=8; i++ ) {
		# o[i] = lookforandopen("output","Yoke.*"+string(i))
		# f[i] = readmf("whateverfilename"+string(i))
		o[i] = lookforandopen("output","Wavetable")
		f[i] = readmf("prelude.mid")
	}
	tm = Now+1b   # a little in the future to make sure they all start together
	t = []
	for ( i=1; i<=8; i++ ) {
		p = f[i]
		p.port = o[i]
		t[i] = realtime(p,tm)
	}
	Root.waitforconsolekey()
	for ( i=1; i<=8; i++ ) {
		kill(t[i])
	}
}
