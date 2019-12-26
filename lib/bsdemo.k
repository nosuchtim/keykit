#name	bsdemo
#usage	bsdemo()
#desc	This is an example of using the bsguide() function.

function bsdemo(chan1,chan2) {

	if ( nargs() < 2 ) chan1 = chan2 = 1

	# The bsmajor[] and bsminor[] arrays are first prepared
	# for major and minor chords (see the description of bsguide()
	# for an explanation of what its first argument is).
	
	Bskey = 'e-'
	bsmajor = []
	bsmajor[ 1 ]= 'e-o-2'
	bsmajor[ 2 ]= 'e-o-2,f,g,b-'
	bsmajor[ 3 ]= 'e-o-2,b-'
	bsmajor[ 4 ]= 'e-o-2,b-'
	bsmajor[ 5 ]= 'e-o-2,f,g,b-'
	bsmajor[ 6 ]= 'e-o-2,b-'
	bsmajor[ 7 ]= 'e-o-2,f,g,b-'
	bsmajor[ 8 ]= 'e-o-2,b-'
	bsminor = []
	bsminor[ 1 ]= 'e-o-2'
	bsminor[ 2 ]= 'e-o-2,f,g-,b-'
	bsminor[ 3 ]= 'e-o-2,b-'
	bsminor[ 4 ]= 'e-o-2,b-'
	bsminor[ 5 ]= 'e-o-2,f,g-,b-'
	bsminor[ 6 ]= 'e-o-2,b-'
	bsminor[ 7 ]= 'e-o-2,f,g-,b-'
	bsminor[ 8 ]= 'e-o-2,b-'
	
	# The guide* phrases are the ones that determine the
	# chord progression.  The sus* phrases are sustain pedal
	# messages that will be added in after everything's done.

	guide3 = repeat('g,g,b-,b-,c,c,e-,f',4)
	sus3 = repeat(repeat(sussect(2b),3)
		+ repeat(sussect(1b),2),4)

	guide4 = 'e-,e-,f,f'
	sus4 = repeat(sussect(2b),2)

	guide5 = 'g,g,g,g'
	sus5 = sussect(4b)

	guide6 = 'd,d,d,d'
	sus6 = sussect(4b)
	
	# Use the chord progression specified above, synthesize
	# the sections of the final piece, using bsguide().

	p3 = bssection(bsmajor,guide3,32b,chan1,chan2)
	p4a = bssection(bsmajor,guide4,4b,chan1,chan2)
	p4b = bssection(bsmajor,guide4,4b,chan1,chan2)
	p4c = bssection(bsmajor,guide4,4b,chan1,chan2)
	p4d = bssection(bsmajor,guide4,4b,chan1,chan2)
	p5a = bssection(bsminor,guide5,4b,chan1,chan2)
	p5b = bssection(bsminor,guide5,4b,chan1,chan2)
	p5c = bssection(bsminor,guide5,4b,chan1,chan2)
	p6 = bssection(bsmajor,guide6,4b,chan1,chan2)
	
	# Put the pieces together, and add the sustain pedals.

	p = p3 + p4a + p5a + p4b + p5b + p4c + p5c + p4d + p6
	sus = sus3 + sus4 + sus5 + sus4 + sus5 + sus4 + sus5 + sus4 + sus6
	sus.chan = chan1
	return(p|sus)
}

# bssection - create a section of music using the chord progression
# specified in the guide phrase.  Creates 2 independent phrases,
# both using the same chord progression, but using different
# "follow" phrases (see bsguide()) - the intention is that one
# of them (on chan1) be low notes (piano or bass) and the other
# is higher notes (solo voice on chan2).  In actuality, it probably
# sounds better if both phrases are played with the same voice.

function bssection(bsarr,guide,lng,chan1,chan2) {

	# create "follow" phrases
	f1 = repeat('c',64)
	# f2 = repeat('co4d192'+'co3d192'+'co4d192'+'co3d192', 8)
	f2 = repeat('co4d192'+'co4d192'+'co4d192'+'co4d192', 8)

	pa = bsguide(bsarr,Bskey,guide,f1,1b/4,lng)
	pa.chan = chan1

	pb = bsguide(bsarr,Bskey,guide,f2,1b/4,lng)
	pb.chan = chan2

	p = pa{isonbeat(??,1b)||rand(2)} | pb{rand(3)}
	return(p)
}

function bsstring(str,majmin) {

	if ( nargs() < 2 )
		majmin = 0

	bskey = 'e-'
	bsmajor = []
	bsmajor[ 1 ]= 'e-o-2'
	bsmajor[ 2 ]= 'e-o-2,f,g,b-'
	bsmajor[ 3 ]= 'e-o-2,b-'
	bsmajor[ 4 ]= 'e-o-2,b-'
	bsmajor[ 5 ]= 'e-o-2,f,g,b-'
	bsmajor[ 6 ]= 'e-o-2,b-'
	bsmajor[ 7 ]= 'e-o-2,f,g,b-'
	bsmajor[ 8 ]= 'e-o-2,b-'
	bsminor = []
	bsminor[ 1 ]= 'e-o-2'
	bsminor[ 2 ]= 'e-o-2,f,g-,b-'
	bsminor[ 3 ]= 'e-o-2,b-'
	bsminor[ 4 ]= 'e-o-2,b-'
	bsminor[ 5 ]= 'e-o-2,f,g-,b-'
	bsminor[ 6 ]= 'e-o-2,b-'
	bsminor[ 7 ]= 'e-o-2,f,g-,b-'
	bsminor[ 8 ]= 'e-o-2,b-'
	
	ntimes = 8
	p0 = strnotes(str)
	dodetense = 1
	if ( dodetense == 0 ) {
		p1 = p0
	}
	else {
		p1 = ''
		for ( n in p0 ) {
			if ( p1 == '' )
				p1 = lastn = n
			else {
				while ( tension(n,lastn) > 3 )
					n.pitch++
			}
			p1 |= n
		}
	}
	p = scatimes(p1,8)

	guide = shuffle(repeat(p1,ntimes+1))
	guide = guide { isonbeat(??,3b) }
	guide =  octavefence(guide,72,72)

	p2 = bsguide(majmin==0?bsmajor:bsminor,bskey,p,guide,1b/4,p.length)

	pend = latest(p2)
	p2a = p2 { isonbeat(??,2b) }
	p2b = gradinclude(p2,0.0,1.0,0)
	p2 = dedup(p2a | p2b)
	p2 = octavefence(p2,44,100)

	p2r = reverse(p2)
	p2rev = ''
	c = 4b
	for ( n=0; ; n=n+2 ) {
		z = cut(p2r,CUT_TIME,n*c,(n+1)*c)
		if ( sizeof(z) == 0 )
			break
		z.time -= n*c
		z.length = c
		p2rev += z
	}
	p2 = p2 + p2rev
	p2.chan = 1	# vibes

	p2x = makerootevery(p2,1b)
	p2x = gradinclude(p2x,0.0,1.0)
	p2x = octavefence(p2x,44,56)
	p2x.chan = 2	# piano
	p2 |= p2x
	p2y = makerootevery(p2,4b)
	p2y = octavefence(p2y,32,44)
	p2y.chan = 3	# bass
	p2 |= p2y

	# proot = octavefence(p,36,50)
	# proot = proot | transpose(proot,4) | transpose(proot,-5)
	
	sus = sussect(2b)
	susp = sus
	while ( susp.length < p2.length )
		susp += sus
	susp.chan = 1
	patches =  progchange(25,1)
			| progchange(1,2)
			|  progchange(36,3)
	p3 = patches | p2 | susp
	return(p3)
}

function gradinclude(p,startprob,endprob,curve) {
	r = ''
	if ( nargs() < 4 )
		curve = 0
	starttm = p%1.time
	deltatm = latest(p) - starttm

	seed = 0
	for ( n in p )
		seed += n.time + n.pitch
	for ( n in p ) {
		prob = startprob + endprob * float(n.time-starttm)/deltatm
		if ( curve == 1 )
			prob = 1.0 - (1.0-prob)*(1.0-prob)
		else if ( curve == 2 )
			prob = prob * prob
		prob *= 100
		if ( (seed%100) < prob )
			r |= n
		seed += n.time + n.pitch
	}
	return(r)
}
