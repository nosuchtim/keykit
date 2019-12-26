#name	arpeggio
#usage	arpeggio(phrase)
#desc	Returns an arpeggiated version of the phrase.  One way of describing
#desc	it is that all the notes have been separated and then put back
#desc	together, back-to-back.

function arpeggio(phr) {
	if ( nargs() < 1 ) {
		print("usage: arpeggio(phrase)")
		return('')
	}
	lastend = 0
	r = ''
	for ( nt in phr ) {
		nt.time = lastend
		r |= nt
		d = nt.duration
		if ( d == 0 )
			d = 1
		lastend += d
	}
	r.length = lastend
	return(r)
}

#name	legato
#usage	legato(phrase)
#desc	Extends the duration of each note to abutt the start of the next note.
#desc	Doesn't modify the duration of the last note.

function legato(ph) {
	r = ''
	non = nonnotes(ph)
	ph -= non
	for ( nt in ph ) {
		nextt = nexttime(ph,nt.time)
		# notes at the end of the phrase aren't touched
		if ( nextt >= 0 )
			nt.dur = nextt - nt.time
		r |= nt
	}
	return(r|non)
}

#name	attime
#usage	attime(phrase,time)
#desc	Returns those notes in the specified phrase that are
#desc	sounding at the specified time.  If a note ends exactly
#desc	at the specified time, it is not included.

function attime(ph,tm) {
	return ( ph { ??.time <= tm && (??.time+??.dur) > tm } )

}

#name	nexttime
#usage	nexttime(ph,st)
#desc	Return the time of the next note AFTER time 'st', in phrase 'ph'
#desc	If there are no notes after it, returns -1;

function nexttime(ph,st) {
	if ( nargs() != 2 ) {
		print("usage: nexttime(phrase, start-time)")
		return('')
	}
	cph = cut(ph,CUT_TIME,1+st,1+ph%sizeof(ph).time)
	if ( sizeof(cph) == 0 )
		return(-1)
	for ( n=1; cph%n.time==st; n++ )
		;
	return(cph%n.time)
}

#name	closest
#usage	closest(note,scale [,direction] )
#desc	Returns a note from the specified scale that is closest in pitch
#desc	to the specified note.  If the optional direction argument is given,
#desc	it specifies the direction (1==up, -1==down) that we want the
#desc	chosen note to be in (relative to the original note).  Specifying
#desc	the direction also guarantees that a note different from the
#desc	original is chosen (if possible).

function closest(nt,scl,dir) {
	if ( nargs() < 3 )
		dir = 0
	if ( sizeof(scl) == 0 ) {
		print("Hey, closest() needs some notes in the scale!")
		return('')
	}
	inc = sign = 1
	arr = []
	for ( n in scl )
		arr[n.pitch % 12] = 1
	t = nt.pitch
	if ( dir != 0 ) {
		t += dir
		inc++
		sign = -dir
	}
	while  ( ( ! (t%12) in arr) || (dir!=0 && dir==sign) || t<0 ) {
		t += (sign*inc++)
		# make sure, if we go past the ends, that we aren't
		# looking in that direction, cause we'd never find anything
		if ( t < 0 )
			dir = 1
		if ( t > 127 )
			dir = -1
		sign = -sign
	}
	nt.pitch = t
	return(nt)
}

#name	closestmap
#usage	closestmap(nt,map)
#desc	The map argument is a set of notes.  This function takes the
#desc	single note nt and changes its pitch to the closest note in the map set.

function closestmap(nt,map) {
	if ( sizeof(map) == 0 ) {
		print("Hey, closestmap() needs some notes in the map!")
		return('')
	}
	arr = []
	for ( n in map )
		arr[n.pitch] = 1
	lookingfor = nt.pitch
	p1 = nt.pitch
	d1 = 128
	d2 = 128
	if ( lookingfor in arr ) {
		return(nt)
	}
	for ( n1=lookingfor; n1<127; n1++ ) {
		if ( n1 in arr ) {
			d1 = n1 - lookingfor
			break
		}
	}
	for ( n2=lookingfor; n2>=0; n2-- ) {
		if ( n2 in arr ) {
			d2 = lookingfor - n2 - lookingfor
			break
		}
	}
	if ( d1 < d2 )
		nt.pitch = n1
	else
		nt.pitch = n2
	return(nt)
}

#name	closestt
#usage	closestt(phrase,time,limit)
#desc	Return the single note in the specified phrase that is closest
#desc	in time to the specified time.  If the limit argument is given,
#desc	the search is limited to notes within that amount of time
#desc	(i.e. to notes between (time-limit) and (time+limit)).

function closestt(ph,tm,lim) {
	if ( nargs() < 2 ) {
		print("usage: closestt(phrase,time)")
		return('')
	}
	if ( nargs() > 2 ) {
		ph = cut(ph,CUT_TIME,tm-lim,tm+lim)
	}
		
	mindt = MAXCLICKS
	for ( n in ph ) {
		dt = tm-n.time
		if ( dt > 0 ) {
			if ( dt < mindt ) {
				minnt = n
				mindt = dt
			}
		}
		else {
			# as soon as n.time is greater than tm, we only
			# have to check that one, and we're done.
			dt = -dt
			if ( dt < mindt ) {
				minnt = n
				mindt = dt
			}
			break
		}
	}
	if ( mindt == MAXCLICKS )
		return('')
	else
		return(minnt)
}

#name	flip
#usage	flip(phrase [,about])
#desc	Flip the pitches of the specified phrase about some intermediate
#desc	pitch (i.e. high notes become lower, and low notes become higher).
#desc	Given a single argument, the flip is done about the average pitch
#desc	of the original phrase.  A second argument can specify a particular
#desc	pitch about which to flip.

function flip(ph1,ph2) {
	na = nargs();
	if ( na > 2 || na < 1 ) {
		print("usage: flip(phrase) or flip(phrase,about-note)")
		return('')
	}
	if ( na == 1 )
		fp = ph1.pitch * 2 	# 1 arg, flip ph1 about its own average
	else
		fp = ph2.pitch * 2

	r = ''
	for ( n in ph1 ) {
		n.pitch = fp - n.pitch
		r |= n;
	}
	return(r)
}

#name	highest
#usage	highest(phrase)
#desc	Returns the highest-pitched note in the specified phrase.

function highest(ph) {
	lim = limitsof(ph)
	return(lim["highest"])
}

#name	lastbunch
#usage	lastbunch(ph,spc,types)
#desc	Return the last "bunch" of notes in ph.  The value of spc is the time
#desc	that determines where the bunch ends - as soon as a blank space of
#desc	that size is detected, the bunch has ended.  This is useful for
#desc	grabbing the last little bit of the Recorded phrase.
#desc	If a third argument is given, it is a bitmask of note types
#desc	to look for - all other types are ignored.

function lastbunch(ph,spc,types) {
	if ( nargs() < 3 )
		types = 0
	tm1 = -1
	if ( nargs() < 2 )
		spc = 2b
	r = ''
	for ( n=sizeof(ph); n>0; n-- ) {
		nt = ph%n
		if ( types != 0 ) {
			if ( (nt.type & types) == 0 ) {
				continue
			}
		}
		e = nt.time + nt.dur
		if ( tm1 > 0 && (e+spc) < tm1 )
			break
		if ( tm1 < 0 || nt.time < tm1 )
			tm1 = nt.time
		r |= nt
	}
	return(r)
}

#name	latest
#usage	latest(phrase)
#desc	Return the ending time of the latest note in the given phrase.

function latest(ph) {
	lim = limitsof(ph)
	if ( "latest" in lim )
		return(lim["latest"])
	else
		return(0)
}

#name	lowest
#usage	lowest(phrase)
#desc	Returns the lowest pitch in the specified phrase.

function lowest(ph) {
	lim = limitsof(ph)
	if ( "lowest" in lim )
		return(lim["lowest"])
	else
		return(0)
}

#name	lowestnt
#usage	lowestnt(phrase)
#desc	Returns the lowest-pitched note in the specified phrase.

function lowestnt(ph) {
	low = 129
	lownt = ''
	for ( nt in ph ) {
		if ( nt.type == MIDIBYTES )
			continue
		if ( nt.pitch < low ) {
			low = nt.pitch
			lownt = nt
		}
	}
	return(lownt)
}

#name	highestnt
#usage	highestnt(phrase)
#desc	Returns the highest-pitched note in the specified phrase.

function highestnt(ph) {
	high = -1
	highnt = ''
	for ( nt in ph ) {
		if ( nt.type == MIDIBYTES )
			continue
		if ( nt.pitch > high ) {
			high = nt.pitch
			highnt = nt
		}
	}
	return(highnt)
}

#name	minvolume
#usage	minvolume(phrase)
#desc	Returns the lowest volume in the specified phrase.

function minvolume(ph) {
	low = 129
	for ( nt in ph ) {
		if ( nt.type == MIDIBYTES )
			continue
		if ( nt.vol < low )
			low = nt.vol
	}
	return(low)
}

#name	maxvolume
#usage	maxvolume(phrase)
#desc	Returns the largest volume in the specified phrase.

function maxvolume(ph) {
	high = 0
	for ( nt in ph ) {
		if ( nt.type == MIDIBYTES )
			continue
		if ( nt.vol > high )
			high = nt.vol
	}
	return(high)
}

#name	minduration
#usage	minduration(phrase)
#desc	Returns the smallest duration in the specified phrase.

function minduration(p) {
	mindur = MAXCLICKS
	for ( n in p ) {
		if ( n.dur < mindur )
			mindur = n.dur
	}
	return(mindur)
}

#name	makenote
#usage	makenote(pitch [,duration [,volume [,chan]]] )
#desc	A simple utility for generating a single-note phrase.
#desc	The pitch is the only required argument; additional
#desc	arguments specify the duration, velocity, and channel.

function makenote(p,d,v,c) {
	if ( nargs()==0 ) {
		print("usage: makenote(pitch[,duration[,volume[,chan]]])")
		return('')
	}
	nt = 'a'
	nt.pitch = p
	n = nargs()
	if ( n > 1 )
		nt.dur = d
	if ( n > 2 )
		nt.vol = v
	if ( n > 3 )
		nt.chan = c
	nt.length = nt.dur
	return(nt)
}

#name	mono
#usage	mono(phrase,type)
#desc	Returns a monophonic version of the specified phrase.
#desc	If type==0, high notes are given priority (e.g. if two notes are
#desc	playing simultaneously, the higher note will be chosen).
#desc	If type==1, low notes are given priority.  If type==2,
#desc	the priority is randomized.

function mono(ph,typ) {
	if ( nargs() == 0 ) {
		print("usage: mono(phrase, [type:1=low-note-priority,2=random] )")
		return()
	}
	if ( nargs() == 1 )
		typ = 0
	non = nonnotes(ph)
	ph -= non
	arr = split(ph);
	r = ''
	n = sizeof(arr)
	if ( typ == 1 ) {
		while ( --n >= 0 ) {
			r |= lowestnt(arr[n]);
		}
	}
	else if ( typ == 2 ) {
		while ( --n >= 0 ) {
			r |= arr[n] % (1+rand(sizeof(arr[n])))
		}
	}
	else {
		while ( --n >= 0 ) {
			r |= highestnt(arr[n]);
		}
	}
	return(r|non)
}

#name	quantize
#usage	quantize(phrase,quant [,limit] )
#desc	Quantize a phrase.  Each note's starting time will be
#desc	quantized by the specified quant value.  If a limit
#desc	is specified, notes that would need to be moved by an
#desc	amount larger than this limit will not be adjusted at all.

function quantize(ph,qnt,lim) {
	if ( nargs() < 2 ) {
		print("usage: quantize(phrase, quant [,limit ] )")
		return('')
	}
	if ( nargs() < 3 )
		lim = qnt
	if ( qnt <= 0 )
		qnt = 1;
	r = ''
	for ( nt in ph ) {
		rem = (nt.time) % qnt;
		if ( (rem*2) <= qnt )
			delta = -rem
		else
			delta = (qnt-rem);
		if ( delta >= -lim && delta <= lim )
			nt.time += delta;
		r |= nt
	}
	return(r)
}

#name	quantizefirst
#usage	quantizefirst(ph,qnt)
#desc	Quantize the first note of ph, and shift the
#desc	rest of the phrase by the same amount.

function quantizefirst(ph,qnt) {
	if ( nargs() < 2 ) {
		print("usage: quantizefirst(phrase, quant )")
		return('')
	}
	nt = ph%1
	ph.time -= (nt.time - numquant(nt.time,qnt))
	return (ph)
}

#name	quantizedur
#usage	quantizedur(ph,qnt)
#desc	Quantize the duration of all notes in ph.

function quantizedur(ph,qnt) {
	if ( nargs() < 2 ) {
		print("usage: quantizedur(phrase, quant )")
		return('')
	}
	r = ''
	for ( nt in ph ) {
		nt.dur = numquant(nt.dur,qnt)
		r |= nt
	}
	return (r)
}

#name	repeat
#usage	repeat(phrase,num_times)
#desc	Repeat a phrase as many times as specified.  The length attribute
#desc	of the phrase determines the offset of the repetitions.

function repeat(ph,n,q) {
	if ( nargs() == 0 ) {
		print("usage: repeat(phrase,number [,quant])")
		return('')
	}
	r = ''
	if ( nargs() > 2 ) {
		ph.length = numquant(ph.length,q)
		if ( ph.length == 0 )
			ph.length = q
	}
	while ( n-- > 0 )
		r = r + ph
	return(r)
}

#name	repleng
#usage	repleng(phrase,length)
#desc	Repeat the specified phrase as many times as it takes
#desc	to fill the specified length of time.  The resultant
#desc	phrase is truncated to the exact length, if it doesn't
#desc	come out evenly.

function repleng(ph,lng) {
	if ( nargs() != 2 ) {
		print("usage: repleng(phrase,desired-length)")
		return('')
	}
	# avoid infinite loop if length is 0
	if ( ph.length != 0 ) {
		while ( ph.length < lng )
			ph = ph + ph
		ph = cut(ph,CUT_TIME,0,lng,TRUNCATE)
	}
	ph.length = lng;
	return(ph)
}

#name	reverse
#usage	reverse(ph)
#desc	Reverse the phrase in time, so the first notes come last,
#desc	and the last notes come first.

function reverse(ph) {
	if ( nargs() == 0 ) {
		print("usage: reverse(phrase)")
		return('')
	}
	leng = ph.length
	r = ''
	for ( nt in ph ) {
		nt.time = leng - nt.time - nt.dur
		r |= nt
	}
	r.length = leng
	return(r)
}

#name	revpitch
#usage	revpitch(phrase)
#desc	Reverse the pitches of a phrase (e.g. the pitch of the first note
#desc	will become the pitch of the last note).  The timing is left intact.

function revpitch(ph) {
	if ( nargs() == 0 ) {
		print("usage: revpitch(phrase)")
		return('')
	}
	leng = ph.length
	r = ''
	nts = onlynotes(ph)
	ph -= nts
	totnotes = sizeof(nts)
	halfnts = sizeof(nts)/2
	for ( n=1; n<=halfnts; n++ ) {
		k = totnotes-n+1
		t = nts%n.pitch
		nts%n.pitch = nts%k.pitch
		nts%k.pitch = t
	}
	return(ph|nts)
}

#name	scaleng
#usage	scaleng(phrase,length)
#desc	Scale the phrase to the specified length by expanding it length-wise,
#desc	adjusting both the time and duration of the notes.

function scaleng(ph,lng) {
	if ( nargs() != 2 ) {
		print("usage: scaleng(phrase,length)")
		return('')
	}
	if ( ph == '' )
		return('')
	r = ''
	if ( ph.length == 0 && sizeof(ph) != 0 ) {
		print("scaleng: a phrase with length=0 can't be scaled")
		return(ph)
	}
	scaf = float(lng)/ph.length
	for ( nt in ph ) {
		# scale both time and duration
		nt.time *= scaf
		nt.dur *= scaf
		r |= nt
	}
	r.length = lng
	return(r)
}

#name	scatimes
#usage	scatimes(phrase,factor)
#desc	Scale a phrase by multiplying the time and duration of
#desc	each note by a specified factor.

function scatimes(ph,n) {
	if ( nargs() == 0 ) {
		print("usage: scatimes(phrase,factor)")
		return('')
	}
	ph.time *= n
	ph.dur *= n;
	ph.length *= n
	return(ph)
}

#name	scadur
#usage	scadur(phrase,factor)
#desc	Scale the durations of a phrase by multiplying the duration of
#desc	each note by a specified factor.

function scadur(ph,n) {
	if ( nargs() == 0 ) {
		print("usage: scadur(phrase,factor)")
		return('')
	}
	ph.dur *= n;
	return(ph)
}

#name	scavol
#usage	scavol(phrase,factor)
#desc	Scale the volume of a phrase by multiplying the volume of
#desc	each note by a specified factor.

function scavol(ph,n) {
	if ( nargs() == 0 ) {
		print("usage: scavol(phrase,factor)")
		return('')
	}
	ph.vol *= n;
	return(ph)
}

#name	step
#usage	step(ph,stepdur)
#desc	Convert a phrase to be in step time, ie. all notes with the same
#desc	spacing and duration.  Overlapped notes (no matter how small the
#desc	overlap) are played at the same time.

Default_step = 1b/4

function step(ph,stepdur) {
	if ( nargs() == 1 ) {
		stepdur = Default_step
	}
	else if ( nargs() != 2 ) {
		print("usage: step(phrase) or step(phrase,duration)")
		return('')
	}
	if ( typeof(stepdur) != "integer" ) {
		print("step() - second argument must be an integer")
		return('')
	}
	if ( typeof(ph) != "phrase" ) {
		print("step() - first argument must be a phrase")
		return('')
	}
	lasttime = (ph%1).time
	steptime = 0
	r = ''
	for ( nt in ph ) {
		if ( nt.time != lasttime ) {
			steptime += stepdur
			lasttime = nt.time
		}
		nt.time = steptime
		r |= nt
	}
	r.dur = stepdur
	r.length = steptime + stepdur
	return(r)
}

#name	strip
#usage	strip(ph)
#desc	Strip off any leading and trailing rests from a phrase

function strip(ph) {
	if ( nargs() == 0 ) {
		print("usage: strip(phrase)")
		return('')
	}
	if ( sizeof(ph) < 1 )
		return('')
	ph.time -= (ph%1).time
	lastnt = ph%(sizeof(ph))
	ph.length = lastnt.time + lastnt.duration
	return(ph)
}

#name	transpose
#usage	transpose(phrase,amount)
#desc	Transposes the phrase by the specified amount.

function transpose(phr,amount) {
	if ( nargs() != 2 ) {
		print("usage: transpose(phrase,amount)")
		return('')
	}
	phr.pitch += amount
	return(phr)
}

#name	ano
#usage	ano()
#desc	Return a phrase containing all-notes-off messages on each channel.
#desc	This does not include note-offs for each individual note, however.

function ano(ch) {
	if ( nargs() > 0 ) {
		a = midibytes( (ch-1) + 0xb0, 0x7b, 0x00 )
	} else {
		a=''
		for ( n=0; n<16; n++ ) {
			a += midibytes( n + 0xb0, 0x7b, 0x00 )
		}
	}
	return(a)
}

#name	allsusoff
#usage	allsusoff()
#desc	Return a phrase containing a "sustain off" on all channels.
#desc   Useful for resetting things if you have a hanging note.

function allsusoff() {
	r = ''
	for ( c=1; c<=16; c++ ) {
		r += midibytes(0xb0|(c-1),0x40,0x00)	# sustain off
	}
	return(r)
}


#name	onlynotes
#usage	onlynotes(ph)
#desc	Return only the regular notes (non-controller, non-sysex, etc) of ph.

function onlynotes(ph) {
	return( cut(ph,CUT_TYPE,NOTEON|NOTEOFF|NOTE) )
}

#name	nonnotes
#usage	nonnotes(ph)
#desc	Return all non-notes (i.e. controller, sysex, etc) of ph.

function nonnotes(ph) {
	return( cut(ph,CUT_NOTTYPE,NOTEON|NOTEOFF|NOTE) )
}

#name	delay
#usage	delay(ph,tm)
#desc	Return phrase ph, delayed by time tm.

function delay(ph,tm) {
	ph.time += tm
	ph.length += tm
	return(ph)
}

#name	chaninfo
#usage	chaninfo(p)
#desc	Return a string giving channel information about phrase p.

function chaninfo(p) {
	s = "Channels:"
	sep = " "
	for ( c=1; c<=16; c++) {
		t = cut(p,CUT_CHANNEL,c);
		n = sizeof(t)
		if ( n>0 ) {
			s += sep + string(c)
			s += ("("+string(n)+")")
			sep = ","
		}
	}
	return(s)
}

#name	eventime
#usage	eventime(ph)
#desc	Return phrase ph with all of its notes evenly spaced in time.

function eventime(ph) {
	n = sizeof(ph)
	if ( n <= 2 )
		return (ph)
	tm1 = ph%1 . time
	tmn = ph%n . time
	r = ''
	dt = (tmn-tm1)/(n-1)
	for ( k=1; k<=n; k++ ) {
		nt = ph%k
		nt.time = tm1 + (k-1)*(tmn-tm1)/(n-1)
		r |= nt
	}
	return (r)
}

#name	swapnote
#usage	swapnote(ph)
#desc	Swap every two notes in the phrase ph.

function swapnote(ph) {
	r = ''
	sz = integer(sizeof(ph)/2)*2
	for ( n=1; n<sz; n+=2 ) {
		n1 = ph%n
		n2 = ph%(n+1)
		t = n2.time
		n2.time = n1.time
		n1.time = t
		r |= n2
		r |= n1
	}
	return(r)
}

#name	shuffle
#usage	shuffle(ph)
#desc	This function takes a phrase, splits in in 2 halves (along time)
#desc	and shuffles the result (ie. first a note from the first half, then
#desc	a note from the second half, etc.).  The timing of the original
#desc	phrase is applied to the result.

function shuffle(ph) {
	sz = sizeof(ph)
	mid = sz/2
	if ( sz%2 == 1 )
		mid++
	halftime = ph%mid.time
	r = ''
	for ( k=1; k<=mid; k++ ) {
		r += ph%k
		n = mid+k
		if ( n <= sz )
			r += ph%n
	}
	return(apply(r,ph))
}

#name	apply
#usage	apply(target,source,apptype,startquant)
#desc	Apply stuff (pitch, volume, timing, etc.) from the source phrase
#desc	to the target phrase.  The apptype is the bitwise-or of PITCH,
#desc	VOLUME, DURATION, TIME, EXACTTIME, CHANNEL.
#desc	Default apptype is TIME|DURATION

function apply(target,source,apptype,startquant) {

	if ( ! defined(TIME) )
		constant()
	if ( nargs() == 0 ) {
		print "usage: apply(target,source, [apptype] )"
		return('')
	}
	if ( nargs() == 2 )
		apptype = TIME | DURATION

	sn=1 ; roff=0 ; r = ''

	target = target{??.type!=MIDIBYTES}
	source = source{??.type!=MIDIBYTES}
	sleng = sizeof(source)
	if ( sleng == 0 || sizeof(target) == 0 )
		return(r)
	stm1 = source%1 . time
	ttm1 = target%1 . time

	if ( nargs() < 4 )
		stoff = 0
	else {
		q1 = numquant(stm1,startquant) - stm1
		if ( q1 < 0 )
			q1 += startquant
		q2 = numquant(ttm1,startquant) - ttm1
		if ( q2 < 0 )
			q2 += startquant
		stoff = q2 - q1
	}

	if ( (apptype&SCADJUST)!=0 || (apptype&SCAFILT)!=0 ) {
		# make an array of the scale's notes
		arrayinit(scarr)
		for ( nt in source )
			scarr[canonic(nt)] = 1
	}

	for ( nt in target ) {
		snt = source%sn
		if ( (apptype&PITCH) != 0 )
			nt.pitch = snt.pitch
		if ( (apptype&DURATION) != 0 )
			nt.dur = snt.dur
		if ( (apptype&VOLUME) != 0 )
			nt.vol = snt.vol
		if ( (apptype&TIME) != 0 )
			nt.time = stoff + ttm1 + (snt.time-stm1) + roff
		if ( (apptype&EXACTTIME) != 0 )
			nt.time = snt.time + roff
		if ( (apptype&CHANNEL) != 0 )
			nt.chan = snt.chan
		if ( (apptype&SCAFILT) != 0 ) {
			if ( ! (canonic(nt) in scarr) )
				continue
		}
		if ( (apptype&SCADJUST) != 0 ) {
			inc = sign = 1
			while ( ! (canonic(nt) in scarr) ) {
				nt.pitch += (sign*inc)
				inc = inc + 1
				sign = -sign
			}
		}
		r |= nt
		if ( ++sn > sleng ) {
			# If the source phrase runs out, start it over
			sn = 1
			roff += source.length
		  }
	}
	rleng = sizeof(r)
	r.length = r%rleng.time + r%rleng.dur
	return(r)
}

function applynear(target,source,apptype) {
	r = ''
	for ( nt in target ) {
		snt = closestt(source,nt.time)
		if ( (apptype&PITCH) != 0 )
			nt.pitch = snt.pitch
		if ( (apptype&DURATION) != 0 )
			nt.dur = snt.dur
		if ( (apptype&VOLUME) != 0 )
			nt.vol = snt.vol
		if ( (apptype&TIME) != 0 )
			nt.time = snt.time
		r |= nt
	}
	r.length = latest(r)
	return(r)
}

#name	dupsof
#usage	dupsof(p)
#desc	Return a phrase containing one copy of any notes that
#desc	are duplicated in phrase p
function dupsof(p) {
          dups = ''
          for ( n in p ) {
               atnow = p{??.time==n.time && ??.pitch==n.pitch}
               # of there's more than one note at the same time ...
               if ( sizeof(atnow) > 1 )
                    dups |= atnow      # save a copy   
          }
          dups = dedup(dups)        # remove all dups so we're
                                    # left with 1 copy of each note
                                    # that has duplicates.
          return(dups)
}

#name	dedup
#usage	dedup(ph)
#desc	Remove any duplicate notes (in time and pitch) from a phrase.

function dedup(ph) {
	for ( n in ph ) {

		# THIS SHOULD USE cut() !!!!

		atnow = ph{??.time==n.time && ??.pitch==n.pitch}
		# If there's more than 1 note at this time,pitch
		# then remove all but the first one
		if ( sizeof(atnow) > 1 )
			ph -= atnow{??.number>1}
	}
	return(ph)
}

#name	dedupdur
#usage	dedupdur(ph)
#desc	Remove any duplicate notes (including comparison of duration)
#desc	from a phrase.

function dedupdur(ph) {
	for ( n in ph ) {

		# THIS SHOULD USE cut() !!!!

		atnow = ph{??.time==n.time && ??.dur==n.dur && ??.pitch==n.pitch}
		# If there's more than 1 note at this time,pitch,duration
		# then remove all but the first one
		if ( sizeof(atnow) > 1 )
			ph -= atnow{??.number>1}
	}
	return(ph)
}

#name	findroot
#usage	findroot(ph)
#desc	Given a phrase, try to guess the root of what's being played.
#desc	The algorithm was given to me by Christopher John Rolfe (rolfe@sfu.ca),
#desc	who says it was culled from W.Russo, Jazz Composition and Orchestration,
#desc	p.25, ex.7.

Strength = [0=12,1=8,2=6,3=4,4=2,5=1,6=12,7=0,8=3,9=5,10=7,11=9]

function findroot(ph) {
	n = sizeof(ph)
	ph.time = 0	# so that notes are sorted by pitch
	maxv = 999
	root = ''
	ph -= nonnotes(ph)
	for ( n1=1; n1<=n; n1++ ) {
		for ( n2=n1; n2<=n; n2++ ) {
			v = Strength[dp=(ph%n2.pitch-ph%n1.pitch)]
			if ( v < maxv ) {
				if ( (v%2)==0 )
					root = ph%n1
				else
					root = ph%n2
				maxv = v
			}
		}
	}
	return(root)
}

#name	makerootevery
#usage	makerootevery(melody,intrvl)
#desc	Figure out a root note (using findroot()) every intrvl beats,
#desc	and return it.

function makerootevery(melody,intrvl) {
	t1 = 0
	t2 = intrvl
	melody = onlynotes(melody)
	r = ''
	for ( ; ; t2 += intrvl ) {
		ct = cut(melody,CUT_TIME,t1,t2)
		if ( sizeof(ct) == 0 ) {
			if ( sizeof(cut(melody,CUT_TIME,t2,MAXCLICKS))==0 )
				break
			t1 = t2
			continue
		}
		low = lowest(ct)
		rt = findroot(ct)
		if ( rt == '' ) {
			t1 = t2
			continue
		}
		while ( rt.pitch >= low && rt.pitch > 12 )
			rt.pitch -= 12
		# chrd = chord(rt,"major")
		rt.dur = intrvl
		rt.time = t1
		r |= rt
		t1 = t2
	}
	return(r)
}

function addrootevery(mel,intrvl) {
	return( mel | makerootevery(mel,intrvl) )
}

#name	pitchlimit
#usage	pitchlimit(p,p1,p2)
#desc	Adjust the pitches of notes in phrase p so that they
#desc	fall between p1 and p2, by shifting the notes in octave increments.

function pitchlimit(p,p1,p2) {
	nts = onlynotes(p)
	p -= nts
	if ( typeof(p1) == "phrase" )
		p1 = p1.pitch
	if ( typeof(p2) == "phrase" )
		p2 = p2.pitch
	r = ''
	for ( n in nts ) {
		while ( n.pitch > p2 && n.pitch > 12 )
			n.pitch -= 12
		while ( n.pitch < p1 && n.pitch < 115 )
			n.pitch += 12
		r |= n
	}
	return ( r | p )
}

function transposeseqrepeat(p,seq) {
	r = ''
	base = seq%1.pitch
	for ( n in seq ) {
		t = n.pitch - base 
		r += transpose(p,t)
	}
	return(r)
}

function transposeseqinplace(p,seq) {
	r = ''
	base = seq%1.pitch
	num = sizeof(seq)
	lng = latest(p)
	t1 = 0
	for ( i=1; i<=num; i++ ) {
		t2 = (float(i)*lng)/num
		t = seq%i.pitch - base 
		sect = cut(p,CUT_TIME,t1,t2)
		r |= transpose(sect,t)
		t1 = t2
	}
	return(r)
}

function scadjustseqinplace(p,seq,scale) {
	if ( nargs() < 3 )
		scale = scale_newage()
	r = ''
	base = seq%1.pitch
	num = sizeof(seq)
	lng = latest(p)
	t1 = 0
	for ( n in seq ) {
		t2 = n.time + n.dur
		sect = cut(p,CUT_TIME,t1,t2)
		r |= scadjust(sect,scale,n)
		t1 = t2
	}
	return(r)
}

function firsthalf(p) {
	lng = latest(p)
	p = cut(p,CUT_TIME,0,lng/2)
	p.length = lng/2
	return(p)
}

function secondhalf(p) {
	lng = latest(p)
	p = cut(p,CUT_TIME,lng/2,lng)
	p.time -= lng/2
	p.length = lng/2
	return(p)
}

#name	chord
#usage	chord(root,type,oct)
#desc	Return a chord, where root is the root note, oct is the
#desc	octave number, and type is a string that identifies the
#desc	type of chord - possible values are:
#desc	"major", "minor", "maj7", "min7", "maj9", "min9", "sus", "dim", "aug", 
#desc	"Maj69", "MajB769", "HalfDim", "Dim9", 
#desc	"NModMaj1", "NModMaj2", "NModMaj3",
#desc	"NModDom1", "NModDom2", "NModDom3", "NModDom4", 
#desc	"ArtDim", "AOVoic1", "AOVoic2", "AllMaj", "Res", 
#desc	"Vitr1", "Vitr2", "Fourths", "Pr1", "Pr2", "Pr3", "Pr4"

Chords = [
		"major"='p0 p4 p7',
		"minor"='p0 p3 p7',
		"maj7"='p0 p4 p7 p11',
		"min7"='p0 p3 p7 p10',
		"maj9"='p0 p4 p7 p11 p14',
		"min9"='p0 p3 p7 p10 p14',
		"sus"='p0 p5 p7',
		"dim"='p0 p3 p6',
		"aug"='p0 p4 p8',
		"Maj69"='p0 p4 p7 p9',
		"MajB769"='p0 p3 p5 p9 p10',
		"HalfDim"='p0 p3 p6 p10',
		"Dim9"='p0 p3 p6 p9 p14',
		"NModMaj1"='p0 p1 p4 p8',
		"NModMaj2"='p0 p4 p6 p9',
		"NModMaj3"='p0 p1 p3 p6',	
		"NModDom1"='p0 p1 p4 p7',	
		"NModDom2"='p0 p1 p4 p6',
		"NModDom3"='p0 p2 p6 p8',
		"NModDom4"='p0 p5 p8 p11',
		"ArtDim"='p0 p2 p5 p8',
		"AOVoic1"='p0 p7 p10 p12 p17',
		"AOVoic2"='p0 p1 p7 p12 p17',
		"AllMaj"='p0 p2 p5 p7 p11 p16 p21',
		"Res"='p0 p4 p7 p10 p14 p17 p20 p23',
		"Vitr1"='p0 p3 p6 p8 p14 p16 p19 p22',
		"Vitr2"='p0 p3 p5 p9 p13 p16 p19 p23',
		"Fourths"='p0 p6 p11 p17 p22 p28',
		"Pr1"='p0 p2 p3 p5 p7 p11',
		"Pr2"='p0 p3 p5 p7 p11 p13',
		"Pr3"='p0 p5 p7 p11 p13 p14',
		"Pr4"='p0 p3 p5 p7 p11 p14 p17'
	]

function allchords() {
	return(Chords)
}

function chord(root,typ,oct) {
	if ( ! (typ in Chords) ) {
		print("chord(): unrecognized chord type - ",typ)
		return('')
	}
	ch = Chords[typ]
	ch.pitch += root.pitch
	return(ch)
}

function chordnamed(s) {
	if ( s in Chords )
		return(Chords[s])
	else
		return('')
}

#name	echo
#usage	echo(ph,num,rtime,rfactor)
#desc	Return phrase ph echoed num times, with rtime delay between
#desc	each echo, and with the volume of each echo decreased by rfactor.
#desc	NEW BEHAVIOUR - 8/9/99 - the length of the result is
#desc	now explicitly set.  This is more "right", but some algorithms
#desc	may have been depending (unknowingly) on the old semantic.

function echo(ph,num,rtime,rfactor) {
	if ( nargs() < 3 )
		rtime = 1b
	if ( nargs() < 4 )
		rfactor = 0.90
	origt = ph%(1).time
	ph.time -= origt
	r = ph
	for ( n=0; n<num; n++ ) {
		ph.time += rtime
		ph.vol *= rfactor
		r |= ph
	}
	r.time += origt
	nl = latest(r)
	if ( r.length < nl )
		r.length = nl
	return(r)
}

#name	spread
#usage	spread(ph,num,rtime,rfactor)
#desc	Return phrase ph "spread" num times, with rtime delay between
#desc	each iteration, and with the volume of each iteration decreased
#desc	by rfactor.  A "spread" is like an echo, except that notes are
#desc	repeated in BOTH directions, forward and back.

function spread(ph,num,rtime,rfactor) {
	if ( nargs() < 3 )
		rtime = 1b
	if ( nargs() < 4 )
		rfactor = 0.90
	return(echomaster(ph,num,rtime,rfactor,num,rtime,rfactor))
}

#name	preecho
#usage	preecho(ph,num,rtime,factor)
#desc	Return phrase ph with each note preceeded by 'pre' echoes.
#desc	num is the number of echoes, rtime is the time between them,
#desc	and rfactor is the volume factor (between 0.0 and 1.0)
#desc	If not provided, rtime and rfactor default to 1b and 0.9
function preecho(ph,num,rtime,rfactor) {
	if ( nargs() < 3 )
		rtime = 1b
	if ( nargs() < 4 )
		rfactor = 0.90
	return(echomaster(ph,0,0,0,num,rtime,rfactor)) 
}

#name	echomaster
#usage	echomaster(ph,fnum,ftime,ffactor,bnum,btime,bfactor)
#desc	Return phrase ph with echoes, forward and back.
#desc	fnum is the number of forward echos, ftime is the echo time, ffactor
#desc	is the volume reduction factor.  bnum/btime/bfactor is for the
#desc	backward echos.

function echomaster(ph,fnum,ftime,ffactor,bnum,btime,bfactor) {
	origph = ph
	origt = ph%(1).time
	origph.time -= origt
	r = origph

	# Do the forward echoes
	ph = origph
	for ( n=0; n<fnum; n++ ) {
		ph.time += ftime
		ph.vol *= ffactor
		r |= ph
	}
	# Do the backward echoes
	ph = origph
	for ( n=0; n<bnum; n++ ) {
		ph.time -= btime
		ph.vol *= bfactor
		r |= ph
	}
	r.time += origt
	return(r)
}

#name	floor
#usage	floor(f)
#desc	Returns the floor (maximum integer that is less than f).
function floor(f) {
	if ( f < 0 )
		return(-1-integer(-f))
	else
		return(integer(f))
}

#name	round
#usage	round(f)
#desc	Returns the rounded integer value of f.
function round(f) {
	return(floor(0.5+f))
}
