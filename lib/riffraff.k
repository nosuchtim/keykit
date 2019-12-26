# riffraff - Play a game of riff-trading with the computer.
#            Assumes that Rhythm has been previously initialized with a rhythm.
#            Every so many beats (actually, half the Rhythm length), the computer
#            will generate and then play a variation of whatever you have just
#            played.  The variation here just swaps pairs of notes.

Pre = 1b/4
Rifftochan = -1
Riffdiv = 4
function riffraff(r1,r2) {
	if ( nargs() < 2 )
		error("riffraff expects 2 arguments!?")
	Rhythm = r1 + r2
	Riffleng = Rhythm.length
	# schedule the routine that generates a
	# variation of the previous half of the pattern
	starttm = nextquant(Now,Playquant)
	# play Rhythm repeatedly
	tid1 = task rrtask2(Rhythm,starttm,Rhythm.length);
	tid2 = task rrtask1(starttm+Riffleng/Riffdiv-Pre,Riffleng/Riffdiv);
	return([tid1=1,tid2=2])
}

function rrtask1(starttm,delta) {
	tm = starttm
	while (1) {
		sleeptill(tm)
		rr()
		tm += delta
	}
}
function rrtask2(ph,starttm,delta) {
	tm = starttm
	while (1) {
		sleeptill(tm)
		realmidi(ph)
		tm += delta
	}
}

function rr() {
	x=cut(Recorded,CUT_TIME,Now-Riffleng/Riffdiv,Now)
	x=onlynotes(x)

	# swap each pair of notes in x
	lim = sizeof(x)
	for ( n=1; n<lim; n+=2 ) {
		t = x%n.pitch
		x%n.pitch = x%(n+1).pitch
		x%(n+1).pitch = t
	}
	x.time -= (Now-Riffleng/Riffdiv)
	x = quantize(x,1b/8)
	if ( Rifftochan > 0 )
		x.chan = Rifftochan
	realmidi(x)
}
