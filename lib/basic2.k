function gvolchange(v) {
	p = ''
	for ( c=1; c<=16; c++ )
		p += chanvolchange(c,v)
	return(p)
}
function chanvolchange(c,v) {
	if ( c <= 0 ) {
		print("Warning, chanvolchange got bad channel, c=",c)
		return('')
	}
	return(controller(c,0x07,v))
}

function gexpressionchange(v) {
	p = ''
	for ( c=1; c<=16; c++ )
		p += chanexpressionchange(c,v)
	return(p)
}
function chanexpressionchange(c,v) {
	if ( c <= 0 ) {
		print("Warning, chanexpressionchange got bad channel, c=",c)
		return('')
	}
	return(controller(c,0x0b,v))
}

function gmastervol(v) {
	lsb = v & 0xff
	msb = v & 0xff00
	return (midibytes('x707f7f0401',lsb,msb,'xf7'))
}

#name	progchange
#usage	progchange(patchnum,ch)
#desc	Return a program change message, where patchnum is the
#desc	patch number (1-based), and ch is the channel (1-based).

function progchange(patchnum,ch) {
	na = nargs()
	if ( na == 0 ) {
		print("Usage: progchange(patch,channel)")
		return('')
	}
	if ( na< 2 )
		ch = 1	# default
	if ( ch <= 0 || ch > 128 ) {
		print("Warning, progchange got an invalid channel value: ",ch)
		return('')
	}
	if ( patchnum <= 0 || patchnum > 128) {
		print("Warning, progchange got an invalid patchnum value: ",patchnum)
		return('')
	}
	p = midibytes(0xc0 | (ch-1), patchnum-1)
	return(p)
}
function patchchange(...) { return(progchange(...)) }

#name	controller
#usage	controller(ch,cn,val)
#desc	Return a controller message, where ch is the channel (1-based),
#desc	cn is the controller number, and val is the value.

function controller(ch,controllernum,val) {
	if ( val > 127 ) {
		print("Warning, controller got a val > 127!?")
		val = 127
	}
	p = midibytes(0xb0 | (ch-1), controllernum, val)
	return(p)
}

# name: pannote(ch,v)
# desc: Construct a pan controller message
function pannote(ch,v) {
	return(controller(ch,0x0a,v))
}

#name  pitchbend
#usage pitchbend(ch,val)
#desc  Construct a pitchbend message, where ch is the channel (1-based)
#desc  and val is the pitchbend value, input range is -8192 to 8191.
function pitchbend(ch,val) {
	if ( val < -8192 )
		val = -8192
	if ( val > 8191 )
		val = 8191
	val = val + 8192
	return(midibytes((ch-1) + 0xe0, val & 0x7f, (val>>7) & 0x7f))
}

#name	nrpn
#usage	nrpn(ch,mm,ll)
#desc	Return an NRPN message constructed from ch (channel, 1-based),
#desc	mm (most-significant byte) and ll (least-significant byte).
function nrpn(ch,mm,ll) {
	return( midibytes( 0xb0 | (ch-1), 0x62, ll, 0xb0 | (ch-1), 0x63, mm ) )
}
function rpnmsg(ch,mm,ll) {
	return( midibytes( 0xb0 | (ch-1), 0x64, ll, 0xb0 | (ch-1), 0x65, mm ) )
}
function datamsg(ch,mm,ll) {
	return( midibytes( 0xb0 | (ch-1), 6, mm, 0xb0 | (ch-1), 38, ll ) )
}

function bankselect(ch,mm,ll) {
	return( midibytes( 0xb0 | (ch-1), 0, mm, 0xb0 | (ch-1), 32, ll ) )
}

#name	sussect
#usage	sussect(time,channel)
#desc	Generate a phrase with controller messages that press the sustain
#desc	pedal on the specified channel and let it up after the specified
#desc	amount of time.

function sussect(tm,c) {
	if ( nargs() < 2 )
		c = 1	# default channel
	s1 = midibytes(0xb0|(c-1),0x40,0x7f)	# sustain on
	s2 = midibytes(0xb0|(c-1),0x40,0x00)	# sustain off
	s2.time = tm-1b/8		# -1b/8 so it won't overlap next section
	s = s1 | s2
	s.length = tm
	return(s)
}

#name	syncphr
#usage	syncphr(phrase)
#desc	This function returns a copy of the specified phrase, shifting
#desc	the starting time so that it is as close as possible to 0 (but not
#desc	less than 0).  The amount by which the time is shifted must be a
#desc	multiple of lng (which, if not specified, is the length of the Met.
#desc	This is typically used when you want to play a phrase that has
#desc	been taken from the middle of some other phrase.  The goal is
#desc	that the playback should still be synchronized to the current Met.

function syncphr(ph,lng) {
	if ( nargs() < 2 )
		lng = Met.length
	if ( lng <= 0 )
		lng = 1b
	tm1 = (ph%1).time
	offset = numquant(tm1,lng)
	if ( offset > tm1 )
		offset -= lng
	if ( offset != 0 ) {
		ph.time -= offset
		ph.length = nextquant(latest(ph),lng)
	}
	return(ph)
}

#name	resetall
#usage	resetall()
#desc	Returns a phrase containing controller messages that reset
#desc	pitch bend, modulation, breath control, sustain, and channel pressure
#desc	on all 16 channels to nominal values (i.e. 0, or in the case
#desc	of pitch bend, 0x40).

function resetall() {
	a=''
	for ( n=0; n<16; n++ ) {
		# pitch bend reset
		a += midibytes( n + 0xe0, 0x00, 0x40 )
		# modulation amount reset
		a += midibytes( n + 0xb0, 0x01, 0x00 )
		# breath control reset
		a += midibytes( n + 0xb0, 0x02, 0x00 )
		# sustain pedal reset
		a += midibytes( n + 0xb0, 0x40, 0x00 )
		# all-notes-off
		a += midibytes( n + 0xb0, 0x7b, 0x00 )
		# channel pressure reset
		a += midibytes( n + 0xd0, 0x00 )
	}
	return(a)
}

#name	gmresetall
#usage	gmresetall()
#desc	Returns a phrase containing controller messages that reset
#desc	everything appropriately for the beginning of
#desc	a General MIDI piece.

function gmresetall(volval) {
	if ( nargs() < 1 )
		volval = 0x7f
	a=''
	lng = 0;
	for ( n=0; n<16; n++ ) {
		# pitch bend reset
		a += midibytes( n + 0xe0, 0x00, 0x40 )
		a.length++
		# breath control reset
		a += midibytes( n + 0xb0, 0x02, 0x00 )
		a.length++
		# sustain pedal reset
		a += midibytes( n + 0xb0, 0x40, 0x00 )
		a.length++
		# all-notes-off
		a += midibytes( n + 0xb0, 0x7b, 0x00 )
		a.length++
		# channel pressure reset
		a += midibytes( n + 0xd0, 0x00 )
		a.length++

		# volume controller
		a += midibytes( n + 0xb0, 0x07, volval )
		a.length++
		# expression controller
		a += midibytes( n + 0xb0, 0x0b, volval )
		a.length++
		# modulation controller
		a += midibytes( n + 0xb0, 0x01, 0x0 )
		a.length++
		# pan controller
		a += midibytes( n + 0xb0, 0x0a, 0x41 )
		a.length++
		# reverb controller
		a += midibytes( n + 0xb0, 0x5b, 0x1e )
		a.length++
		# chorus controller
		a += midibytes( n + 0xb0, 0x5d, 0x1e )
		a.length++

		# reset pitch bend range to 2 semitones
		a += setbendrange(n,2)
	}
	return(a)
}

function alloff() {
	stop()
	realtime(ano()|resetall())
}
function anoall() {
	r = ''
	for ( ch=1; ch<=16; ch++ ) {
	    p = ''
	    for ( pt=0; pt<=127; pt++ ) {
		nt = makenote(pt)
		nt.type = NOTEOFF
		p |= nt
	    }
	    p.chan = ch
	    p.time = ch
	    r |= p
	}
	return(r)
}
function realgmreset() {
	stop()
	realtime(gmresetall())
}

function startmsg() { return ( midibytes( 0xfa ) ) }
function continuemsg() { return ( midibytes( 0xfb ) ) }
function stopmsg() { return ( midibytes( 0xfc ) ) }

function simulinfo(ph) {
	print("Maximum number of simultaneous notes = ",nsimul(ph))
}

#name	nsimul
#usage	nsimul(ph)
#desc	Return the maximum number of simultaneously-sounding notes in a phrase.
function nsimul(ph) {
	ph = onlynotes(ph)
	m = mono(ph)
	maxsimul = 0
	for ( nt in m ) {
		p1 = cut(ph,CUT_TIME,nt.time,nt.time+nt.dur,INCLUSIVE)
		nnotes = sizeof(p1)
		if ( nnotes > maxsimul )
			maxsimul = nnotes
	}
	return(maxsimul)
}

#name	fractal
#usage	fractal(ph,depth)
#desc	Returns phrase ph fractalized - each note becomes a miniature
#desc	version of the entire phrase, transposed by the note's pitch.
#desc	The depth determines how many times this process is repeated.
#desc	Watch out, this will produce huge phrases.

function fractal(ph,depth) {
	orig = r = ph
	if ( nargs() < 2 )
		depth = 1
	while ( depth-- > 0 ) {
		ph = r
		r = ''
		for ( nt in ph ) {
			f = orig
			f.pitch += (nt.pitch-orig%(1).pitch)
			f = strip(f)
			f = scaleng(f,nt.dur)
			f.time += nt.time
			r |= f
		}
		r.length = ph.length
	}
	return(r)
}

# Try to put all notes within the limits of pitches p1,p2,
# by shifting notes in octave increments
function octavefence(ph,p1,p2) {
	r = nonnotes(ph)
	ph -= r

	if ( sizeof(ph) == 0 )
		return('')

	if ( typeof(p1) == "phrase" )
		p1 = p1.pitch
	if ( typeof(p2) == "phrase" )
		p2 = p2.pitch
	pmid = (p1+p2)/2

	php1 = lowest(ph)
	php2 = highest(ph)
	phmid = (php1+php2)/2

	# First shift the whole phrase up or down to get everything
	# as close as possible while retaining relative melodies.
	ph.pitch += numquant(pmid-phmid,12)

	# Then move individual notes 
	for ( nt in ph ) {
		while ( nt.pitch < p1 )
			nt.pitch += 12
		while ( nt.pitch > p2 )
			nt.pitch -= 12
		r |= nt
	}
	return(r)
}

#name	repfade
#usage	repfade(p,ntimes,inout)
#desc	Repeat the phrase the specified number of times, gradually fading it
#desc	in or out (by including or excluding more notes on each repeat).
#desc	If inout>0, it starts out including only a couple of notes, and ends by
#desc	including the entire phrase - ie. a fade in.  If inout is less than 0,
#desc	it's a fade out.

function repfade(p,ntimes,inout) {
	orig = p
	if ( nargs() < 3 )
		inout = 1	# default is fade in

	if ( ntimes < 2 ) ntimes = 2
	r = ''
	sofar = ''
	dn = float(sizeof(p)) / ntimes
	if ( dn < 1 )
		dn = 1
	for ( i=1; i<ntimes; i++ ) {
		gdn = dn*i
		while ( sizeof(sofar) <= gdn ) {
			n = p%(rand(sizeof(p))+1)
			sofar |= n
			p -= n
		}
		sofar.length = orig.length
		if ( inout > 0 )
			r += sofar
		else {
			t = sofar
			t.time += ((ntimes-i)*orig.length)
			r |= t
		}
	}
	if ( inout > 0 )
		r += orig
	else
		r |= orig
	r.length = orig.length * ntimes
	return(r)
}

function noise(ph,type,amount,att) {
	# amount is amplitude of noise
	# type is 0 (White), 1 (1/f), or 2 (brownian)
	# att is PITCH, VOLUME, DURATION, TIME, CHANNEL
	r = ''
	noiseval(-1)	# reset it
	for ( nt in ph ) {
		if ( att==PITCH || att==OCTAVE )
			oldv = nt.pitch
		else if ( att==VOLUME )
			oldv = nt.vol
		else if ( att==DURATION )
			oldv = nt.dur
		else if ( att==TIME )
			oldv = nt.time
		else if ( att==CHANNEL )
			oldv = nt.chan

		v = noiseval(type,amount)
		if ( att == OCTAVE )
			v *= 12
		v += oldv

		if ( att==PITCH || att==OCTAVE )
			nt.pitch = v
		else if ( att==VOLUME )
			nt.vol = v
		else if ( att==DURATION )
			nt.dur = v
		else if ( att==TIME )
			nt.time = v
		else if ( att==CHANNEL )
			nt.chan = v
		r |= nt
	}
	return(r)
}

function oldcontrolthin(origp,mintm,smooth) {
	if ( nargs() < 2 )
		mintm = 1b/16
	for ( ch=1; ch<=16; ch++ ) {
		p = cut(origp,CUT_CHANNEL,ch)
		origp -= p

		last = []
		last[CHANPRESSURE] = ''
		last[CONTROLLER] = ''
		last[PRESSURE] = ''
		last[PITCHBEND] = ''
		r = ''
		lastdeleted = lastn = ''
		for ( n in p ) {
			# Don't modify the first occurrence of a given type
			if ( ! (n.type in last) ) {
				r |= n
				lastdeleted = ''
				continue
			}
			ln = last[n.type]
			dx = abs(n.time - ln)
			if ( dx > mintm ) {
				last[n.type] = n.time
				r |= n
				lastdeleted = ''
			}
			else {
				# too close to last occurrence of same type,
				# so we delete this one
				lastdeleted = n
			}
			lastn = n
		}
		if ( lastn == lastdeleted )
			r |= lastn
		origp |= r
	}
	return(origp)
}

function thinit(p,mintm) {
	# This function expects to be given a phrase with only a single
	# type of note (e.g. a particular controller).
	r = ''
	lastdeleted = lastincluded = ''
	sz = sizeof(p)
	cnt = 0
	for ( n in p ) {
		cnt++
		if ( cnt == 1 ) {
			# always include first
			r |= n
			lastincluded = n
			lastdeleted = ''
			lastn = n
			continue
		}
		dx = abs(n.time - lastn.time)
		# If it's been a "long time", since the last one, then
		# we want to make sure we include it.
		if ( dx > mintm && lastdeleted != '' ) {
			r |= lastdeleted
			lastincluded = lastdeleted
			lastdeleted = ''
			# but keep going
		}

		dx = abs(n.time - lastincluded.time)
		if ( dx > mintm ) {
			r |= n
			lastincluded = n
			lastdeleted = ''
		}
		else {
			# too close to last occurrence, so delete
			lastdeleted = n
		}
		lastn = n
	}
	# always include last one, if we haven't already
	if ( lastdeleted != '' )
		r |= lastdeleted
	return(r)
}

function thincontrol(origp,mintm) {
	if ( nargs() < 2 )
		mintm = 1b/16
	for ( ch=1; ch<=16; ch++ ) {
		chanp = cut(origp,CUT_CHANNEL,ch)
		origp -= chanp

		r = ''

		p1 = cut(chanp,CUT_TYPE,CHANPRESSURE)
		if ( sizeof(p1) > 0 ) {
			chanp -= p1
			r |= thinit(p1,mintm)
		}

		p2 = cut(chanp,CUT_TYPE,PRESSURE)
		if ( sizeof(p2) > 0 ) {
			chanp -= p2
			r |= thinit(p2,mintm)
		}

		p3 = cut(chanp,CUT_TYPE,PITCHBEND)
		if ( sizeof(p3) > 0 ) {
			chanp -= p3
			r |= thinit(p3,mintm)
		}

		p4 = cut(chanp,CUT_TYPE,CONTROLLER)
		if ( sizeof(p4) > 0 ) {
			chanp -= p4
			pa = []
			for ( cn=0; cn<128; cn++ ) {
				pa[cn] = cut(p4,CUT_TYPE,CONTROLLER,cn)
				r |= thinit(pa[cn],mintm)
			}
		}
		origp |= chanp	# what's left, normal notes and sysex?
		origp |= r	# thinned stuff
	}
	return(origp)
}

function lastnotechord() {
	# Last Note/Chord
	nt = Recorded%(sizeof(Recorded))
	# collect all notes sounding at the same time
	while ( 1 ) {
		ncut = cut(Recorded,CUT_TIME,
				nt%1.time,MAXCLICKS,INCLUSIVE)
		if ( sizeof(ncut) == sizeof(nt) )
			break
		nt = ncut
	}
	return(nt)
}

# name: pitchbendnotes(ph)
# desc: return only pitchbend messages
function pitchbendnotes(ph) {
	ph = ph { (subbytes(??,1,1)&0xe0) == 0xe0 }
	return(ph)
}

# name: controllernotes(ph,type)
# desc: return only controller messages of a given type
function controllernotes(ph,t) {
	ph = cut(ph,CUT_TYPE,CONTROLLER)
	ph = ph { subbytes(??,2,1) == t }
	return(ph)
}

# name: sustainnotes(ph)
# desc: return only the sustain messages in a phrase
function sustainnotes(ph) {
	return(controllernotes(ph,0x40))
}

# name: expressionnotes(ph)
# desc: return only the expression messages in a phrase
function expressionnotes(ph) {
	return(controllernotes(ph,0x0b))
}

# name: modulationnotes(ph)
# desc: return only the modulation messages in a phrase
function modulationnotes(ph) {
	return(controllernotes(ph,0x01))
}

# name: volumenotes(ph)
# desc: return only the volume messages in a phrase
function volumenotes(ph) {
	return(controllernotes(ph,0x07))
}

# name: pannotes(ph)
# desc: return only the pan messages in a phrase
function pannotes(ph) {
	return(controllernotes(ph,0x0a))
}

# name: progchangenotes(ph)
# desc: return only the program change messages in a phrase
function progchangenotes(ph) {
	ph = cut(ph,CUT_TYPE,PROGRAM)
	return(ph)
}

# name: crescendo(ph)
# desc: performs a crescendo on a phrase.

function crescendo(ph,start_vol,end_vol) {

	if ( start_vol < 1 ) start_vol=1
	if ( end_vol < 1 ) end_vol=1
	if ( start_vol > 127 ) start_vol=127
	if ( end_vol > 127 ) end_vol=127

	z=''
	sz=sizeof(ph)
	if ( sz < 2 ) {
		ph.vol = end_vol
		return(ph)
	}
	tm1 = ph%(1).time
	len = ph%sz.time - tm1
	if ( len == 0 ) {
		ph.vol = end_vol
		return(ph)
	}

	spread=end_vol-start_vol
	r = ''
	for ( nt in ph ) {
		if ( typeof(nt) != MIDIBYTES )
			nt.vol = (((nt.time-tm1)*spread) / len) + start_vol
		r |= nt
	}
	return(r)
}

# name: setbendrange(ch,range)
# desc: Sets the pitch bend range on a given channel

function setbendrange(n,range) {
	a = ''
	# reset pitch bend range to 2 semitones
	a = midibytes( n + 0xb0, 100, 0 )
	a.length++
	a += midibytes( n + 0xb0, 101, 0 )
	a.length++
	a += midibytes( n + 0xb0, 6, range )
	a.length++
	a += midibytes( n + 0xb0, 38, 0 )
	a.length++
	return(a)
}

function temponote(t) {
	return( phrase("'\"Tempo="+string(t)+"\"'") )
}

function mergeonoff(p) {
	r = ''
	table = []
	for ( nt in p ) {
		if ( nt.type == NOTEOFF ) {
			# See if there's a note-on for it
			lookfor = makenote(nt.pitch,0,'a'.vol,nt.chan,1)
			if ( lookfor in table ) {
				nt1 = table[lookfor]
				nt.dur = nt.time - nt1.time
				nt.time = nt1.time
				nt.type = NOTE
				r |= nt
			}
		}
		else if ( nt.type == NOTEON ) {
			lookfor = makenote(nt.pitch,0,'a'.vol,nt.chan,1)
			table[lookfor] = nt
		} else {
			r |= nt
		}
	}
	return(r)
}

#name	applyfunc
#usage	applyfunc(p,func,chunksize)
#desc	This function splits a phrase into chunksize-sized chunks,
#desc	applies the function func to some of them (every other one,
#desc	by default), and returns the result, pasted back together.

function applyfunc(p,sz,f) {
	if ( typeof(f) != "function" ) {
		print("Usage: applyfunc(p,f,sz) - third argument must be a function")
		return('')
	}
	arr = []
	tm1 = 0
	tm2 = sz
	endtime = latest(p)
	for ( n=0; tm1 < endtime; n++ ) {
		p2 = cut(p,CUT_TIME,tm1,tm2)
		p2.time -= tm1
		p2.length = sz
		if ( sizeof(p2) > 0 ) {
			if ( n%2 == 0 ) {
				p2 = f(p2)
			}
		}
		arr[n] = p2
		tm1 += sz
		tm2 += sz
	}
	r = ''
	for ( k=0; k<n; k++ ) {
		r += arr[k]
	}
	return(r)
}

# These are utility functions that can be used by applyfunc(), they
# essentially embed arguments to the functions within the function names.
function step_8(p) { return(step(p,1b/2)) }
function step_16(p) { return(step(p,1b/4)) }
function step_32(p) { return(step(p,1b/8)) }
function scadjust_last(p) { return(scadjust(p,scale_last())) }

#name	tonerow_old
#usage	tonerow_old(p)
#desc	Return a tone row of the notes in phrase p.
#desc	Each note in the original phrase appears exactly
#desc	once in the result, but in a random position.
#desc	The original time/duration of the notes is retained.
function tonerow_old(p) {
	# First create an array whose values will be
	# the notes of the result.
	arr = []               # empty array
	tobefilled = sizeof(p);
	# Loop through the notes in phrase p.
	for ( n in p ) {
		# Generate a random number r, from
		# 1 to the number of remaining empty slots.
		# Then look for the 'r'th empty slot.
		slot = -1
		for ( r=1+rand(tobefilled); r>0; r-- ) {
			slot++
			# If that element is already present,
			# advance to next empty slot
			while ( slot in arr ) {
				slot++;
			}
		}
		# Put the note in that slot.
		n.time = 0
		n.length = n.dur
		arr[slot] = n
		tobefilled--
	}
	r = ''
	for ( n=0; n<sizeof(arr); n++ ) {
		r += arr[n]
	}
	return(r)
}

#name	tonerow
#usage	tonerow(p)
#desc	Better version of tonerow, works on all types of notes.
#desc	Return a tone row of the notes in phrase p.
#desc	Each note in the original phrase appears exactly
#desc	once in the result, but in a random position.
#desc	The original time/duration of the notes is retained.
function tonerow(p) {
	r = ''
	# Loop through the notes in phrase p.
	pickfrom = p
	for ( pi=1; sizeof(pickfrom) > 0; pi++ ) {
		# Pick a random note from the phrase.
		rn = pickfrom%(rand(sizeof(pickfrom))+1)
		# Remove it from future consideration
		pickfrom -= rn
		# Retain the time and (for notes) duration
		# from the original phrase.
		rn.time = p%pi.time
		t = typeof(rn)
		if ( t==NOTE || t==NOTEON || t==NOTEOFF ) {
			rn.dur = p%pi.dur
		}
		# Add it to the result.
		r |= rn
	}
	return(r)
}

#name	scalevertical

function scalevertical(p,rangelow,rangehigh) {
	plow = lowest(p)
	phigh = highest(p)
	dp = phigh - plow
	if ( typeof(rangelow) == "integer" )
		dv = rangehigh - rangelow
	else
		dv = rangehigh.pitch - rangelow.pitch
	r = ''
	if ( dp == 0 ) {
		p.pitch = rangelow
		return(p)
	}
	for ( nt in p ) {
		np = nt.pitch - plow
		np = (np * dv / dp) + rangelow
		nt.pitch = np
		r |= nt
	}
	return(r)
}

function evolve(p1,p2,nsteps,leng) {
	t1 = p1%1.time

	p1 = strip(p1)
	p2 = strip(p2)

	s1 = sizeof(p1)
	s2 = sizeof(p2)
	if ( nargs() < 3 )
		nsteps = (s1>s2)?s1:s2
	if ( nargs() < 4 )
		leng = (p1.length>p2.length)?p1.length:p2.length

	# Initialize results
	r1 = p1
	r1.length = leng
	r2 = p2
	r2.length = leng

	for ( n=0; n<nsteps; n++ ) {

		toremove1 = s1*1.0/(nsteps-n)
		forsure1 = integer(toremove1)
		fraction1 = toremove1 - forsure1
		num1 = forsure1 + (rand(100)<(100*fraction1)?1:0)
		# Remove that many notes from p1
		for ( k=1; k<=num1; k++ )
			p1 -= picknote(p1)

		toremove2 = s2*1.0/(nsteps-n)
		forsure2 = integer(toremove2)
		fraction2 = toremove2 - forsure2
		num2 = forsure2 + (rand(100)<(100*fraction2)?1:0)
		# Remove that many notes from p1
		for ( k=1; k<=num2; k++ )
			p2 -= picknote(p2)

		# Add p1 to the end of r1
		r1 += p1
		r1.length = (n+2)*leng

		# Add p2 to the beginning of r2
		r2.time += leng
		r2 |= p2
		r2.length = (n+2)*leng

		s1 -= num1
		s2 -= num2
	}
	r = r1|r2
	r.time += t1
	return(r)
}

function chordmel(x,c,chtype) {
	if ( nargs() < 2 )
		c = 'c'
	if ( nargs() < 3 )
		chtype = "sus"
	chrd = transpose(chordnamed(chtype),canonic(c.pitch))
	r = ''
	for ( n in x ) {
		ch = chrd
		while ( highest(ch) < n.pitch) {
			p = lowestnt(ch)
			ch -= p
			p.pitch += 12
			ch |= p
		}
		ch.time = n.time
		ch.dur = n.dur
		ch.length = n.length
		ch.chan = n.chan
		r |= ch
	}
	return(r)
}

function expandvol(p,factor) {
	v = p.vol
	r = ''
	for ( nt in p ) {
		tmp = nt.vol - v
		tmp *= factor
		tmp += v
		nt.vol = tmp
		r |= nt
	}
	return(r)
}

function autopan(p,minp,maxp) {
	# Magic values for lowest/highest notes

	# Remove any existing pan messages
	p -= pannotes(p)

	# Remove non-notes and add them back at the end
	nn = nonnotes(p)
	p -= nn
	if ( nargs() < 3 ) {
		minp = lowest(p)
		maxp = highest(p)
	} else {
		if ( minp == -1 )
			minp = lowest(p)
		else if ( minp == -2 )
			minp = highest(p)
		if ( maxp == -1 )
			maxp = lowest(p)
		else if ( maxp == -2 )
			maxp = highest(p)
	}
	r = ''
	for ( nt in p ) {
		if ( typeof(nt) == MIDIBYTES ) {
			r |= p
		} else {
			pt = nt.pitch

			if ( minp < maxp ) {
				if ( pt < minp )
					pn = pannote(nt.chan,0)
				else if ( pt > maxp )
					pn = pannote(nt.chan,127)
				else {
					if ( maxp == minp )
						dp = 64
					else
						dp = 127 * (pt-minp) / (maxp-minp)
					pn = pannote(nt.chan,dp)
				}
			} else {
				if ( pt < maxp )
					pn = pannote(nt.chan,0)
				else if ( pt > minp )
					pn = pannote(nt.chan,127)
				else {
					if ( maxp == minp )
						dp = 64
					else
						dp = 127 - 127 * (pt-maxp) / (minp-maxp)
					pn = pannote(nt.chan,dp)
				}
			}
			pn.time = nt.time - 2
			r |= pn
			r |= nt
		}
	}
	r |= nn
	return(r)
}

#name	changeprogchange
#usage	changeprogchange(p,frompatchnum,topatchnum)
#desc	Return p, where every program change message matching
#desc	the frompatchnum is changed to topatchnum.
#desc	The program change numbers are 1-based.

function changeprogchange(p,frompatchnum,topatchnum) {
	pc = cut(p,CUT_TYPE,PROGRAM)
	p -= pc			# remove all program changes from p
	for ( n in pc ) {
		# All the notes in pc are program change messages.
		# Here we pull it apart to find its channel and patch num
		ch = 1+(subbytes(n,1,1)&0xf)
		pn = 1+subbytes(n,2,1)
		if ( frompatchnum == pn ) {
			# it matched, modify it
			p |= progchange(topatchnum,ch)
		} else {
			# didn't match, add the original back to p
			p |= n
		}
	}
   	return(p)
}

#name	ornament
#usage	ornament(ph,orn,doscaleng)
#desc	Apply phrase orn to each note of phrase ph - i.e. each note of
#desc	phrase ph will be turned into a copy of phrase orn.
#desc	If doscaleng is non-zero, then the copy will be scaled to the
#desc	duration of the notes in phrase orn.  If doscaleng is zero,
#desc	the copy will have the original timing.

function ornament(ph,orn,doscaleng) {
	r = ''
	p1 = orn%1.pitch
	if ( nargs() < 3 )
		doscaleng = 0
	for ( n in ph ) {
		if ( n.type != NOTE )
			r |= n
		else {
			ch = n.chan
			v = n.vol
			if ( doscaleng )
				p = scaleng(orn,n.dur)
			else
				p = orn
			p.pitch += (n.pitch - p1)
			p.time += n.time
			p.chan = ch
			p.vol = v
			r |= p
		}
	}
	return(r)
}

#name	debank
#desc	Removes all bank-select controller messages (controller 0
#desc	followed by controller 32) from a phrase.
#desc	Note that it leaves the program change message
#desc	which usually follows.

function debank(ph) {
	r = ''
	prevn = ''
	for ( n in ph ) {
		if ( n.type == CONTROLLER ) {
			b1 = subbytes(n,1,1)
			b2 = subbytes(n,2,1)
			b3 = subbytes(n,3,1)
			b4 = subbytes(n,4,1)
			b5 = subbytes(n,5,1)
			b6 = subbytes(n,6,1)

			if ( b4 != '' ) {
				if ( prevn != '' ) {
					r |= prevn
					prevn = ''
				}

				if ( (b1 & 0xf0)==0xb0
						&& b2 == 0x00 
						&& (b4 & 0xf0)==0xb0
						&& b5 == 0x20 ) { 
					n = subbytes(n,7)
				}
				r |= n
			} else {
				if ( prevn == '' ) {
					prevb1 = b1
					prevb2 = b2
					prevb3 = b3
					prevn = n
				} else if ( (prevb1 & 0xf0)==0xb0
						&& prevb2 == 0x00 
						&& (b1 & 0xf0)==0xb0
						&& b2 == 0x20 ) { 
					# Don't add either one
					prevn = ''
				} else {
					r |= prevn

					prevb1 = b1
					prevb2 = b2
					prevb3 = b3
					prevn = n
				}
			}
			
		} else {
			if ( prevn != '' ) {
				r |= prevn
				prevn = ''
			}
			r |= n
		}
	}
	return(r)
}

#name	derest
#desc	Removes all rests (sections where nothing is playing)
#desc	from a phrase.

function derest(ph) {
	s = split(ph)
	n = sizeof(s)
	if ( n <= 1 )
		return(ph)
	for ( i=n-2; i>=0; i-- ) {
		t1 = latest(s[i])
		t2 = s[i+1]%1.time
		if ( t1 != t2 ) {
			ph1 = cut(ph,CUT_TIME,0,t1)
			ph1.length = t1
			ph2 = cut(ph,CUT_TIME,t2)
			ph2.time -= t2
			ph2.length -= t2
			ph = ph1 + ph2
		}
	}
	return(ph)
}
