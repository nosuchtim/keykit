#name	picknote
#usage	picknote(phrase, n)
#desc	Returns n random notes from the specified phrase.  If n is omitted,
#desc	a single random note is returned.

function picknote(ph,n) {
	leng = sizeof(ph)
	if ( nargs() <= 1 )
		return ( ph % (1+rand(leng)) )
	r = ''
	if ( n >= leng )
		return(ph)
	for ( i=0; i<n; i++ ) {
		# pick a random note from phrase ph
		nt = ph % (1+rand(sizeof(ph)))
		# add it to the result
		r |= nt
		# remove it from the original phrase
		ph -= nt
	}
	return(r)
}

#name	pickphr
#usage	pickphr(phrase1,phrase2,phrase3...)
#desc	Randomly chooses and returns one of its argument phrases.

function pickphr() {
	return ( argv(rand(nargs())) )
}

#name	randdur
#usage	randdur(phrase,range)
#desc	Returns the phrase with the duration of its notes randomly
#desc	varied within the specified range.  For example, if the
#desc	range value is 2, the note durations will be adjusted by
#desc	values ranging from +2 to -2.

function randdur(ph,rng) {
	if ( nargs() == 0 ) {
		print("usage: randdur(phrase,range)")
		return('')
	}
	r = ''
	for ( nt in ph ) {
		nt.dur += rng - rand(rng*2+1)
		r |= nt
	}
	return(r)
}

#name	randpitch
#usage	randpitch(phrase,range)
#desc	Returns the phrase with the pitch of its notes randomly
#desc	varied within the specified range.  For example, if the
#desc	range value is 2, the note pitches will be adjusted by
#desc	values ranging from +2 to -2.

function randpitch(ph,rng) {
	if ( nargs() == 0 ) {
		print("usage: randpitch(phrase,range)")
		return('')
	}
	r = ''
	for ( nt in ph ) {
		nt.pitch += (rand(rng*2+1)-rng)
		r |= nt
	}
	return(r)
}

#name	randvol
#usage	randvol(phrase,range)
#desc	Returns the phrase with the velocity of its notes randomly
#desc	varied within the specified range.  For example, if the
#desc	range value is 2, the note velocities will be adjusted by
#desc	values ranging from +2 to -2.

function randvol(ph,rng) {
	if ( nargs() == 0 ) {
		print("usage: randvol(phrase,range)")
		return('')
	}
	r = ''
	for ( nt in ph ) {
		nt.vol += rng - rand(rng*2+1)
		r |= nt
	}
	return(r)
}
