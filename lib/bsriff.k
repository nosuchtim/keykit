#name	bsriff

Bskey = 'e-'
BsMajor = []
BsMajor[ 1 ]= 'e-o-2'
BsMajor[ 2 ]= 'e-o-2,f,g,b-'
BsMajor[ 3 ]= 'e-o-2,b-'
BsMajor[ 4 ]= 'e-o-2,b-'
BsMajor[ 5 ]= 'e-o-2,f,g,b-'
BsMajor[ 6 ]= 'e-o-2,b-'
BsMajor[ 7 ]= 'e-o-2,f,g,b-'
BsMajor[ 8 ]= 'e-o-2,b-'
BsMinor = []
BsMinor[ 1 ]= 'e-o-2'
BsMinor[ 2 ]= 'e-o-2,f,g-,b-'
BsMinor[ 3 ]= 'e-o-2,b-'
BsMinor[ 4 ]= 'e-o-2,b-'
BsMinor[ 5 ]= 'e-o-2,f,g-,b-'
BsMinor[ 6 ]= 'e-o-2,b-'
BsMinor[ 7 ]= 'e-o-2,f,g-,b-'
BsMinor[ 8 ]= 'e-o-2,b-'
	
function bsriff2() {
	return( bsriff() + bsriff() )
}

function bsriff(key,chan1,agitation,direction,maj) {

	if ( nargs() == 0 ) {
		key = Keybase
		chan1 = 1
		agitation = rand(3)
		# direction = rand(3) - 1
		direction = 0
		maj = rand(2)
	} else if ( nargs() == 3 ) {
		direction = 0
		maj = 1
	} else if ( nargs() != 5 ) {
		print("usage: bsriff(key,channel,agitation,direction,maj)")
		return('')
	}

	guide = key

	nsteps = 8
	leng = 2b

	# The follow phrase gives bsguide some notes to gravitate towards.
	key.length = leng/2
	key.dur = leng/2
	follow = repleng(key,leng)

	if ( agitation > 0 ) {
		f = ''
		for ( fnt in follow ) {
			if ( rand(2) )
				fnt.pitch += 12 * rand(agitation)
			else
				fnt.pitch -= 12 * rand(agitation)
			f |= fnt
		}
		follow = f
	}

	if ( agitation > 1 )
		nsteps = 16

	if ( maj )
		bsm = BsMajor
	else
		bsm = BsMinor
	p = bsguide(bsm,Bskey,guide,follow,leng/nsteps,leng)
	p.chan = chan1

	p = p{isonbeat(??,1b)||rand(2)}

	if ( direction != 0 ) {
		r = ''
		ninc = sizeof(p)/3
		n = 0
		oct = 0
		for ( nt in p ) {
			nt.pitch += direction * oct
			if ( ++n >= ninc ) {
				oct += 12
				n = 0
			}
			r |= nt
		}
		p = r
	}

	# Add sustain pedal messages.
	sus = repleng(sussect(2b),leng)
	sus.chan = chan1
	
	return(p|sus)
}
