#name	bsguide
#usage	bsguide(arr,arrkey,keyguide,noteguide,stepsize,lng)
#desc	Synthesize a monophonic phrase based on these arguments:
#desc
#desc	arr
#desc	.br
#desc	An array whose elements are phrases, each one specifying
#desc	the allowable notes that can be used on a given step.
#desc	For example, if bsarr contained these elements:
#desc	arr[1]='c' ; arr[2]='c,e,g' ; arr[3]='c,g' ; arr[4]='g'
#desc	then only a 'c' would be allowed in the first step, and
#desc	the second step would allow a 'c', 'e', or 'g'.
#desc	The arr array can be of any size; when it runs out,
#desc	it is reused from the beginning.  For example, in the
#desc	example above, the fifth step would allow only a 'c'.
#desc	
#desc	arrkey
#desc	.br
#desc	The key that the phrases in the arr array are meant
#desc	to be in.  E.g. in the example above, the value of arrkey
#desc	would most likely be 'c'.  This is needed so that
#desc	the arr array can be transposed to other keys.
#desc	
#desc	keyguide
#desc	.br
#desc	A phrase that will determine the key (or really, chords)
#desc	in the final result.  For example, if the value of
#desc	keyguide was 'c,c,c,f', the notes picked during the first
#desc	three beats would be based in C, and the final beat would
#desc	be based in F.  Essentially the phrases in the arr array
#desc	are transposed based on these notes.
#desc	
#desc	noteguide
#desc	.br
#desc	A phrase whose notes will be used as "guide" points in
#desc	picking the pitches in the final result.  For example,
#desc	if the guide phrase was 'co5,co4,co3', then the first note
#desc	in the final result would be as close as possible to 'co5',
#desc	and the note picked on the second beat would be as close as
#desc	possible to 'co4'.  If the notes of guide are very close
#desc	together, then they will strongly influence the general shape
#desc	of the final result.  If instead the notes of guide are
#desc	farther apart, then the final result will be allowed to meander
#desc	more freely between the guide notes (but still subject to the
#desc	contraints of the arr array described above).  E.g. a guide
#desc	phrase of 'co5d384,co4' would allow 4 beats of meandering
#desc	before being pushed back toward 'co4'.
#desc	
#desc	stepsize
#desc	.br
#desc	This is the step size of the final result.  E.g. a value
#desc	of 1b/4 means the result would consist of sixteenth notes.
#desc	
#desc	lng
#desc	.br
#desc	The desired length of the final result.
#desc	

function bsguide(arr,arrkey,keyguide,noteguide,stepsize,lng,lowlim,highlim ) {
	if ( nargs() < 5 ) {
		print("usage: bsguide(key,bsarr,keyguide,noteguide,stepsize,lng)")
		return(0)
	}
	p = ''
	lastnt = 'a'
	lasttm = 0
	bsindex = 1
	bslimit = sizeof(arr)
	bsarr = []
	for ( i in arr )
		bsarr[i] = arr[i]
	if ( nargs() < 7 ) {
		lowlim = 28
		highlim = 100
	}
	dir = 1
	seed = Now
	for ( n in p ) {
		seed = (seed * (n.time+1) + n.pitch + 5)
	}
	while ( p.length < lng ) {
		n = makenote('a',stepsize)

		# if we're within stepsize of keyguide note,
		# use it to rekey the scales in bsarr
		kn = closestt(keyguide,lasttm,stepsize)
		if ( kn != '' ) {
			bsrekey(arr,arrkey,bsarr,kn)
		}

		# if we're within stepsize of noteguide note, use it to find
		# closest note, otherwise use lastnt
		gn = closestt(noteguide,lasttm,stepsize)
		if ( gn != '' ) {
			n.pitch = gn.pitch
			# Find the closest note in the current BeatScale
			cn = closest(n,bsarr[bsindex])
		}
		else {
			n.pitch = lastnt.pitch

			if ( n.pitch < lowlim )
				dir = 1
			else if ( n.pitch > highlim )
				dir = -1

			# Find the closest note in the current BeatScale
			# (except don't chose the same note, and go in
			# the desired direction)
			cn = closest(n,bsarr[bsindex],dir)
		}
		if ( cn.pitch == 0 ) error("Hey, cn.pitch==0 ? ")

		n.pitch = cn.pitch
		p += n
		lastnt = n
		lasttm += stepsize
		if ( ( (seed/8) %6) < 2 )
			dir = -dir
		seed = seed * (n.time+1) + n.pitch + 5
		if ( ++bsindex > bslimit )
			bsindex = 1
	}
	return(p)
}
function arrayclear(arr) {
	for ( i in arr ) delete arr[i]
}
function bsrekey(bsarr,bskey,newarr,newkey) {
	dk = canonic(newkey) - canonic(bskey)
	if ( dk == 0 )
		return(0)
	arrayclear(newarr)
	for ( i in bsarr )
		newarr[i] = transpose(bsarr[i],dk)
	return(1)
}
