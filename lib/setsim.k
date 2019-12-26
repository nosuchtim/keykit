#
# The set of functions below implements something like a Markov chain,
# using one phrase as the basis of constructing a 'similar' phrase.
# Usage is:
#
#      setsim(phrase,wind,increment,type)
#      makesim(num,type)
#
# setsim() takes a 'phrase' and breaks it into pieces of size 'wind'.
# Each window is split into a 'left half' and 'right half', and a table
# is built that records their association.
#
# makesim() is then used to construct a new phrase, starting with a
# random one of the 'left half's, and picking one of the 'right half's
# that can follow it.  This 'right half' then becomes the 'left half'
# for which another 'right half' is chosen.  This repeats the specified
# number of times.  An example:
#
#      setsim(sonata,2b,1b,"p")
#      makesim(20,"p")
#
# The explanation above describes what happens when type is "p" (pitch).
# When type is "r", the rhythm of the phrase is used as the basis of
# building a similar (but different) table, which can then be used to
# construct a phrase that is similar in rhythm to the original.
# This doesn't work as well as the "p"itch stuff.

#################
# Start of code #
#################

Beatmeasure = 0
Beatincrement = 0

function setsim(inphrase,wind,increment,type) {
	if ( nargs() < 3 ) {
		print("usage: setsim(phrase,wind,increment,\"p\"itch-or-\"r\"hythm)")
		return()
	}
	if  ( nargs() == 3 )
		type = "p"
	if ( substr(type,1,1) == "p" ) {
		setsimpitch(inphrase,wind,increment)
	}
	else {
		setsimrhythm(inphrase,wind,increment)
	}
}

function setsimpitch(inphrase,wind,increment) {

	if ( nargs() != 3 ) {
		print("usage: setsim(inphrase,wind,increment)")
		return()
	}

	# set the volume and channel to the defaults,
	# so they don't get in the way
	inphrase.vol = 'a'.vol
	inphrase.chan = 'a'.chan

	lim = inphrase.length - wind
	Leftnotes = []
	Rightnotes = []

	for (start=0; start<=lim; start+=increment ) {

		left = cut(inphrase,CUT_TIME,start,start+wind/2-1)
		if ( sizeof(left) <= 0 )
			continue

		while ( start<=lim ) {
			right = cut(inphrase,CUT_TIME,start+wind/2,start+wind-1)
			if ( sizeof(right) > 0 )
				break
			start += wind/2
		}

		left.time -= (left%1).time
		right.time -= (right%1).time

		left.length = wind/2
		right.length = wind/2

		# One Leftnotes element for each unique left-half.
		# The (associative) index is the left-half phrase,
		# and the value is the number of right-halfs that
		# are associated with it.

		if ( ! (left in Leftnotes) )
			Leftnotes[left] = 0

		n = Leftnotes[left]++

		# The Rightnotes array indicies are formed from the
		# concatenation of the left-half phrase with an
		# index number that goes from 0 to the number of
		# right-halfs associated with that left-half.

		if ( ! (left in Rightnotes) )
			Rightnotes[left] = []
		Rightnotes[left][n] = right
	}
}

function setsimrhythm(inphrase,measure,increment) {
	if ( nargs() != 3 ) {
		print("usage: setsim(inphrase,wind,increment)")
		return()
	}

	Beatmeasure = measure
	Beatincrement = increment

	# we're only interested in the durations.
	inphrase.vol = 'a'.vol
	inphrase.chan = 'a'.chan
	inphrase.pitch = 'a'.pitch

	lim = inphrase.length - measure
	Beatbuckets = []
	Beatphrs = []

	for (s1=0; s1<=lim; s1+=measure ) {
	    thismeas = dedupdur(cut(inphrase,CUT_TIME,s1,s1+measure+increment))
	    thismeas.time -= s1
	    for ( s2=0; s2<=(measure-increment); s2+=increment ) {
		ph = cut(thismeas,CUT_TIME,s2,s2+increment)
		ph.time -= s2
		if ( sizeof(ph) <= 0 )
			continue
		ph.length = increment

		# One bucket for each increment within the measure.
		# The value in the bucket is the number of phrases in
		# the Beatphrs array for that increment
		if ( ! (s2 in Beatbuckets) )
			Beatbuckets[s2] = 0
		n = Beatbuckets[s2]++
		if ( ! (s2 in Beatphrs) )
			Beatphrs[s2] = []
		Beatphrs[s2][n] = ph
	    }
	}
}

function printsimpitch() {
	for ( left in Leftnotes ) {
		print("left[  ",left,"  ] = ",Leftnotes[left])
		for ( n=0; n<Leftnotes[left]; n++ ) {
			print("     right[",left," ",n," = ",Rightnotes[left][n])
		}
	}
}

function printsimrhythm() {
	for ( left in Beatbuckets ) {
		print("left[  ",left,"  ] = ",Beatbuckets[left])
		for ( n=0; n<Beatbuckets[left]; n++ ) {
			print("     right[",left," ",n," = ",Beatphrs[left][n])
		}
	}
}

function makesim(num,type) {
	if ( nargs() < 2 )
		type = "p"
	if ( type == "p")
		return(makesimpitch(num))
	else
		return(makesimrhythm(num))
}

function pickrandleft( r, left) {
	# Pick a random left side
	r=rand(sizeof(Leftnotes))
	for ( left in Leftnotes ) {
		if ( --r <= 0 )
			break
	}
	return(left)
}

function makesimpitch(num, r,left,rnd,right,nright) {
	left = ""
	ph = ''
	while ( --num > 0 ) {
		if ( ! ( left in Leftnotes ) )
			left = pickrandleft()
		# randomly pick one of the right sides for the current left
		nright = Leftnotes[left]
		right = Rightnotes[left][rand(nright)]
		ph += right
		left = right
	}
	return(ph)
}

function pickrandbeat( r, beat ) {
	r=rand(sizeof(Beatbuckets))
	for ( beat in Beatbuckets ) {
		if ( --r <= 0 )
			break
	}
	return(beat)
}

function makesimrhythm(num, r,currbeat,ph,left,rnd,right,nright) {
	currbeat = -1
	ph = ''
	while ( num-- > 0 ) {
		# randomly pick one of the right sides for the current left
		if ( ! ( currbeat in Beatbuckets ) )
			currbeat = pickrandbeat()
		nright = 0 + Beatbuckets[currbeat]
		right = Beatphrs[currbeat][rand(nright)]
		ph += right
		currbeat += Beatincrement
		if ( currbeat > Beatmeasure )
			currbeat = 0
	}
	return(ph)
}
