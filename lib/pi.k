# The microsound mailing list did a project where everyone was supposed
# to compose a piece using pi (3.14159...) in some direct way.
# Below are the algorithms I used for my piece.

# The arrays here are used to map the digits of pi to
# determine various attributes of the notes.

Digit2dur = [
	0 = 1b/64,
	1 = 1b/32,
	2 = 1b/16,
	3 = 1b/8,
	4 = 1b/4,
	5 = 1b/2,
	6 = 1b,
	7 = 2b,
	8 = 4b,
	9 = 8b
	]
Digit2delta = [
	0 = -12,
	1 = -7,
	2 = -5,
	3 = -3,
	4 = -2,
	5 = 2,
	6 = 3,
	7 = 5,
	8 = 7,
	9 = 12
	]
Digit2vol = [
	0 = 30,
	1 = 40,
	2 = 50,
	3 = 60,
	4 = 70,
	5 = 80,
	6 = 90,
	7 = 100,
	8 = 110,
	9 = 120
	]
Digit2rep = [
	0 = 0,
	1 = 0,
	2 = 1,
	3 = 1,
	4 = 2,
	5 = 2,
	6 = 3,
	7 = 3,
	8 = 4,
	9 = 4
	]
Digit2stutter = [
	0 = 1,
	1 = 1,
	2 = 1,
	3 = 1,
	4 = 1,
	5 = 1,
	6 = 1,
	7 = 2,
	8 = 4,
	9 = 8
	]
NDigit2chan = [
	0 = 1,
	1 = 2,
	2 = 3,
	3 = 4,
	4 = 5,
	5 = 6,
	6 = 7,
	7 = 8,
	8 = 9,
	9 = 10
	]
# I ended up mapping to just 3 channels (7,8,9).
Digit2chan = [
	0 = 7,
	1 = 8,
	2 = 9,
	3 = 7,
	4 = 8,
	5 = 9,
	6 = 7,
	7 = 8,
	8 = 9,
	9 = 7
	]

function piscan(pos,nnotes,sectsize,startnt,secs,dopatches) {
	if ( nargs() < 6 )
		dopatches = 1
	r = ''
	lastpitch = startnt.pitch

	patches = ''
	digits = pidigits()
	digitsize = sizeof(digits)

	# Estimate how many digits we need
	needed = pos + 16*4 + nnotes*6 + 5

	if ( needed > digitsize ) {
		pos = (needed % digitsize)
	}

	# Generate patch changes by taking 3 digits and
	# using them to select a patch from the patches for each channel
	# Even if dopatches is 0, we eat up the digits

	for ( ch=1; ch<=16; ch++ ) {
		pmap = patchmap_for_chan(ch)
		pnum = digits[pos++] * 100 + digits[pos++] * 10 + digits[pos++]
		sz = sizeof(pmap)
		pnum = pnum % sz
		m = pmap[pnum]
		p = patchmap_phrase(m,ch)
		p.length=4
		if ( dopatches )
			patches += p
	}

	# Generate notes using the digits of pi.

	for ( n=0; n<nnotes; n++ ) {
		nd = Digit2dur[digits[pos++]]
		nt = makenote(lastpitch)
		nt.dur = nd
		nt.chan = Digit2chan[digits[pos++]]
		nt.pitch += Digit2delta[digits[pos++]]
		lastpitch = nt.pitch
		nt.vol = Digit2vol[digits[pos++]]
		nt.length = nt.dur
		nr = Digit2rep[digits[pos++]]
		rnt = repeat(nt,nr)
		rnt.length = nr * nd
		r += rnt
	}

	# Now go back and take each sectsize section and
	# repeat it N times (where N is determined by the
	# digits of pi).

	nsect = r.length/sectsize
	r2 = ''
	for ( n=0; n<nsect; n++ ) {
		p = cut(r,CUT_TIME,n*sectsize,(n+1)*sectsize)
		p.time -= n*sectsize
		p.length = sectsize
		ns = Digit2stutter[digits[pos++]]
		p = repeat(p,ns)
		p.length = sectsize * ns
		r2 += p
	}
	r = scaleng(r2,secs*2b)
	r |= patches
	return(r)
}

# The code inside piscan() should really use this function
# for generating the patches.

function pipatches(pos) {
	patches = ''
	digits = pidigits()
	digitsize = sizeof(digits)

	# Generate patch changes by taking 3 digits and
	# using them to select a patch from the patches for each channel
	channels = []
	for ( n=0; n<10; n++ ) {
		channels[Digit2chan[n]] = 1
	}
	for ( ch in channels ) {
		pmap = patchmap_for_chan(ch)
		pnum = digits[pos++] * 100 + digits[pos++] * 10 + digits[pos++]
		sz = sizeof(pmap)
		pnum = pnum % sz
		m = pmap[pnum]
		p = patchmap_phrase(m,ch)
		p.length=4
		patches += p
	}
	return(patches)
}

function readpifile(fname,desired) {
	f = open(pathsearch(fname))
	if ( f < 0 ) {
		print("Unable to find ",fname)
		return()
	}
	arr = []
	i = 0
	while ( (s=get(f)) != Eof ) {
		for ( n=0; n<sizeof(s); n++ ) {
			d = substr(s,n+1,1)
			if ( d ~~ "[0-9]" ) {
				arr[i++] = integer(d)
				if ( i >= desired )
					break
			}
		}
		if ( i >= desired )
			break
	}
	close(f)
	return(arr)
}

function pidigits {
	global(Pi)
	if ( ! defined(Pi) ) {
		Pi = readpifile("pi100000.txt",100000)
	}
	return(Pi)
}

# This is the function that generates the complete piece.
# It calls piscan() 6 times, and overlays the results.
# It then transposes and scales sections of the piece.
# The digits of pi are used for many aspects.
# The piece is exactly 3 minutes 14 seconds long.

function irrational(pos) {
	if ( nargs() < 1 )
		pos = 1

	nsecs=3*60+14
	leng=nsecs*2b

	r = ''
	nnotes = 21
	sect = 16b

	pos += 3
	r |= scaleng(piscan(pos,  3 * nnotes, sect, 'c', nsecs, 0),leng)

	pos += 1
	r |= scaleng(piscan(pos,  1 * nnotes, sect, 'c', nsecs, 0),leng)

	pos += 4
	r |= scaleng(piscan(pos,  4 * nnotes, sect, 'c', nsecs, 0),leng)

	pos += 1
	r |= scaleng(piscan(pos,  1 * nnotes, sect, 'c', nsecs, 0),leng)

	pos += 5
	r |= scaleng(piscan(pos,  5 * nnotes, sect, 'c', nsecs, 0),leng)

	pos += 9
	r |= scaleng(piscan(pos,  9 * nnotes, sect, 'c', nsecs, 0),leng)

	r.length=leng

	print("After scans...")

	nt = 'c'
	seq =    transpose(nt,   3)
		+transpose(nt,   1)
		+transpose(nt,  -4)
		+transpose(nt,   1)
		+transpose(nt,  -6)

	r = scadjustseqinplace(r,scaleng(seq,leng),scale_aeolian())
	r = transposeseqinplace(r,scaleng(seq,leng))

	# Get the notes into a reasonable range
	r = octavefence(r,32,96)
	r = transpose(r,-12)

	return(r)
}

# This generates another variation.

function irrational_too(pos) {
	if ( nargs() < 1 )
		pos = 1

	digits = pidigits()
	nsecs=3*60+14
	leng=nsecs*2b

	r = ''
	nnotes = 31 * 2
	sect = 16b

	for ( n=0; n<12; n++ ) {
		pos += digits[n]
		r |= scaleng(piscan(pos,  digits[n] * nnotes,
						sect, 'c', nsecs, 0),leng)
	}

	r.length=leng

	print("After scans...")

	nt = 'c'
	seq = ''
	for ( n=0; n<12; n++ ) {
		# alternate positive and negative transposes
		seq += transpose(nt,  (2*(n%2)-1) * digits[n])
	}

	r = scadjustseqinplace(r,scaleng(seq,leng),scale_aeolian())
	r = transposeseqinplace(r,scaleng(seq,leng))

	# Get the notes into a reasonable range
	r = octavefence(r,32,96)
	r = transpose(r,-12)

	# Make sets of patch changes, evenly spaced.
	pos = 314
	patches = ''
	for ( n=0; n<nsecs; n++ ) {
		pos += digits[n]
		patches += pipatches(pos)
		patches.length += 1b
	}
	patches = scaleng(step(patches,1b),leng)
	r |= patches

	return(r)
}

#######################
# Initial experiment
#######################

function pi1() {

	secs = 3 * 60 + 14
	r = ''
	secspersection = secs / 10.0

	r += piscan(1004,   100, 8b, 'c',secspersection)  # real good
	r += piscan(1013,   100, 4b, 'c',secspersection)  # decent
	r += piscan(1015,   100, 4b, 'c',secspersection)  # fair

	r += piscan(311,   60, 4b, 'c',secspersection)	# okay
	r += piscan(4005,  100, 1b, 'c',secspersection) # maybe
	r += piscan(4006,  100, 1b, 'c',secspersection)

	r += piscan(3412,  200, 8b, 'c',secspersection) # maybe
	r += piscan(444,   50,  1b, 'c',secspersection)  # maybe
	r += piscan(77,   600, 8b, 'c',secspersection)	# okay

	# r += piscan(5000,   500, 8b, 'c',secspersection)
	# r += piscan(55,   900, 8b, 'c',secspersection)
	# r += piscan(66,   200, 8b, 'c',secspersection)

	r += piscan(99,   50, 8b, 'c',secspersection)

	return(r)

}

#######################
# Something to make trying different starting indexes quick
#######################

function pitry() {

	global(Pitid)
	kill(Pitid)

	global(Pistart)
	if ( ! defined(Pistart) ) {
		Pistart = 1
	}
	global(Pinum)
	if ( ! defined(Pinum) ) {
		Pinum = 50
	}
	global(Pisect)
	if ( ! defined(Pisect) ) {
		Pisect = 16b
	}
	global(Pisecs)
	if ( ! defined(Pisecs) ) {
		Pisecs = 1
	}
	print("Pistart=",Pistart)
	print("Pinum=",Pinum)
	print("Pisect=",Pisect)
	r = piscan(Pistart,  Pinum, Pisect, 'c',Pisecs)
	print("length=",r.length/1b)
	Pitid = realtime(r,Now)

	Pistart++
}
