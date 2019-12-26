#name	chadjust
#usage	chadjust(melody,chords)
#desc	Adjusts the notes of the melody phrase so that they fall on the notes
#desc	of the chords that are playing (at the same time) in the chords phrase.

function chadjust(mel,ch) {
	if ( sizeof(ch) == 0 ) {
		print("Hey, chadjust needs some chords!")
		return('')
	}
	currscl = ch
	r = ''
	for ( nt in mel ) {
		tm = nt.time
		scl = cut(ch,CUT_TIME,tm,tm,INCLUSIVE)
		if ( sizeof(scl) != 0 )
			currscl = scl
		r |= closest(nt, currscl)
	}
	return(r)
}

#name	chfilter
#usage	chfilter(melody,chord)
#desc	Return a copy of the melody phrase, leaving only those notes that
#desc	match the chords that occur in the chord phrase at the same time.

function chfilter(mel,ch) {
	if ( nargs() == 0 ) {
		print("usage: chfilter(melody,chords)")
		return('')
	}
	return ( mel { isinscale(??, attime(ch,??.time)) } )
}

#name	scadjust
#usage	scadjust(melody,scale)
#desc	Adjust the notes in the melody phrase so that each note falls on
#desc	the closest note in the scale phrase.

function scadjust(mel,scale) {
	if ( nargs() == 0 ) {
		print("usage: scadjust(melody,scale)")
		return('')
	}
	nmel = sizeof(mel)
	if ( sizeof(scale) == 0 ) {
		print("Hey, scadjust() needs some notes in the scale!")
		return('')
	}
	r = ''
	scarr = []
	for ( nt in scale )
		scarr[canonic(nt)] = 1
	for ( nt in mel ) {
		if ( nt.type & (NOTE|NOTEOFF|NOTEON) ) {
			inc = sign = 1
			cnt = 0
			# Don't do computation with nt.pitch directly,
			# because negative pitches are invalid
			# and get adjusted automatically
			ptch = nt.pitch
			while ( ! (canonic(ptch) in scarr) && cnt++ < 100 ) {
				ptch += (sign*inc)
				inc = inc + 1
				sign = -sign
			}
			nt.pitch = ptch
			if ( cnt >= 100 ) {
				print("Something's amiss in scadjust, for nt=",nt)
				continue
			}
		}
		r |= nt
	}
	return(r)
}

#name	scafilt
#usage	scafilt(melody,scale)
#desc	Return a copy of the melody phrase, leaving only those notes
#desc	that fall on the scale specified by the scale phrase.

# on the given scale
function scafilt(mel,scale) {
	if ( nargs() == 0 ) {
		print("usage: scafilt(melody,scale)")
		return('')
	}
	return ( mel { isinscale(??, scale) } )
}

Scales = [
	"ionian" = 'p0,p2,p4,p5,p7,p9,p11',
	"dorian" = 'p0,p2,p3,p5,p7,p9,p10',
	"phrygian" = 'p0,p1,p3,p5,p7,p8,p10',
	"lydian" = 'p0,p2,p4,p6,p7,p9,p11',
	"mixolydian" = 'p0,p2,p4,p5,p7,p9,p10',
	"aeolian" = 'p0,p2,p3,p5,p7,p8,p10',
	"locrian" = 'p0,p1,p3,p5,p6,p8,p10',
	"newage" = 'p0,p3,p5,p7,p10',
	"fifths" = 'p0,p7',
	"octaves" = 'p0',
	"harminor" = 'p0,p2,p3,p5,p7,p8,p11',
	"melminor" = 'p0,p2,p3,p5,p7,p9,p11',
	"chromatic" = 'p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11'
	]

function allscales() {
	return(Scales)
}

function scale_ionian() { return(Scales["ionian"]) }
function scale_dorian() { return(Scales["dorian"]) }
function scale_phrygian() { return(Scales["phrygian"]) }
function scale_lydian() { return(Scales["lydian"]) }
function scale_mixolydian() { return(Scales["mixolydian"]) }
function scale_aeolian() { return(Scales["aeolian"]) }
function scale_locrian() { return(Scales["locrian"]) }
function scale_newage() { return(Scales["newage"]) }
function scale_fifths() { return(Scales["fifths"]) }
function scale_harminor() { return(Scales["harminor"]) }
function scale_melminor() { return(Scales["melminor"]) }
function scale_chromatic() { return(Scales["chromatic"]) }

function scalenamed(s) {
	if ( s in Scales )
		return(Scales[s])
	else
		return('')
}

# Return a scale containing the last stuff that arrived on Midi input
# (i.e. Recorded)
function scale_last() {
	p = onlynotes(lastbunch(Recorded,2b))
	if ( sizeof(p) <= 0 ) {
		print("No notes in Recorded!?")
		return('')
	}
	return(makescale(p))
}
function makescale(p) {
	p.time = 0
	p.dur = 0
	scale = ''
	for ( n in p ) {
		while ( n.pitch >= 12 )
			n.pitch -= 12
		scale |= n
	}
	scale = dedup(scale)
	return(scale)
}

#name	completescale
#usage	completescale(key,scalename)
#desc	Return a phrase which is in the given key and scale, and extends
#desc	from the lowest note (in the key/scale) to the highest note.
function completescale(c,nm) {
	p = scalenamed(nm)
	if ( p == '' ) {
		print("There is no scale named: ",nm)
		return('')
	}
	cp = canonic(c)
	p.pitch += cp
	r1 = ''
	for ( nt in p ) {
		v = nt.pitch - 12
		if ( v >= 0 ) {
			nt.pitch -= 12
		}
		r1 |= nt
	}
	r1.time = 0
	r = ''
	offset = 0
	while ( offset < 128 ) {
		for ( nt in r1 ) {
			if ( (offset+nt.pitch) < 128 ) {
				nt.pitch += offset
				r += nt
			}
		}
		offset += 12
	}
	return(r)
}

#name	completescalephrase
#usage	completescalephrase(p)
#desc	Return a phrase which has the notes in p duplicated across all octaves.
function completescalephrase(p) {
	r1 = ''
	for ( nt in p ) {
		r1 |= makenote(canonic(nt.pitch))
	}
	r1.time = 0
	r = ''
	offset = 0
	while ( offset < 128 ) {
		for ( nt in r1 ) {
			if ( (offset+nt.pitch) < 128 ) {
				nt.pitch += offset
				r += nt
			}
		}
		offset += 12
	}
	return(r)
}

