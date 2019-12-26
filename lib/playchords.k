# by 
# Tom Gilson, tgilson@yahoo.com

function sendNoteOffs(theNote, thePhrase ) {
	p = theNote.pitch
	Midiin[gettid()] = f = open()
	n=get(f)
	while ( !((n.type == NOTEOFF) && (n.pitch == p)) ) {
		n=get(f)	
	}
	sz = sizeof(thePhrase)
	while ( sz > 0  ) {
		thePhrase%sz.type = NOTEOFF
		sz = sz-1
	}
	realtime( thePhrase,0) 
}


function playchords() {
	if (  (!(defined(PlayChordsActive))) || (PlayChordsActive == 0)) {
		Merge = 0
		PlayChordsActive = task playChordstask()
		print("playChords is active")


	}
	else {
		kill(PlayChordsActive)
		Merge = 1
		PlayChordsActive = 0 
		print("playChords disabled")

	}
}

function playChordstask() {
	# note 47 = xpose down an octave
	# note 46 = first inversion / alternate voicing
	# note 45 = second inversion	/ alternate voicing
	# note 44 = major (1)
	# note 43 = minor	(2)
	# note 42 = maj7	(3)
	# note 41 = min7  (4)
	# note 40 = maj9  (5)
	# note 39 = min9  (6)
	# note 38 = sus	(7)
	# note 37 = dim	(8)
	# note 36 = aug	(9)

	Midiin[gettid()] = f = open()
    		while ( (n=get(f)) != Eof ) {
			if ( (n.type == NOTEON) && (n.pitch > 47) &&  (lowest(Current) < 45) )  {
				sz= sizeof(Current)
				temp = Current
				transposeDown = 0
				firstInversion = 0
				secondInversion = 0
				theChord = 0
				while ( sz > 0 ) {
					theNote=temp%sz
					p = theNote.pitch
					if (p == 47 ) 
						transposeDown = 1
					if (p == 46 ) 
						firstInversion = 1
					if (p == 45 ) 
						secondInversion = 1
					if (p < 45 ) 
						theChord = p
					sz = sz -1
				}
				note =n
				td = 12 * transposeDown			
				fi = 12 * firstInversion
				si = 12 * secondInversion
				if (theChord == 44) { # major 
					print("major")
					thePhrase = transpose(note, 0-td+fi)  | transpose(note,4 - td)  | transpose(note,7 -td - si) 
					realtime(thePhrase,0)
					task sendNoteOffs(note, thePhrase)
				}
				if (theChord == 43) {# minor
					print("minor")
					thePhrase = transpose(note, 0-td+fi)  | transpose(note,3 - td)  | transpose(note,7 -td - si) 
					realtime(thePhrase,0)
					task sendNoteOffs(note, thePhrase)
				}
				if (theChord == 42) {# maj7
					print("maj7")
					thePhrase = transpose(note, 0-td+fi)  | transpose(note,4 - td)  | transpose(note,7 -td - si) |transpose(note,11 -td - si) 
					realtime(thePhrase,0)
					task sendNoteOffs(note, thePhrase)
				}
				if (theChord == 41) {# min7
					print("min7")
					thePhrase = transpose(note, 0-td+fi)  | transpose(note,3 - td)   | transpose(note,7 -td - si) | transpose(note,10 -td - si) 
					realtime(thePhrase,0)
					task sendNoteOffs(note, thePhrase)
				}
				if (theChord == 40) {# maj9
					print("maj9")
					thePhrase = transpose(note, 0-td+fi)  | transpose(note,4 - td)   |  transpose(note,7 -td ) |transpose(note,11 -td ) | transpose(note,14 -td-si )
					realtime(thePhrase,0)
					task sendNoteOffs(note, thePhrase)
				}
				if (theChord == 39) {# min9
					print("min9")
					thePhrase = transpose(note, 0-td+fi)  | transpose(note,3 - td)   |  transpose(note,7 -td ) | transpose(note,10 -td ) | transpose(note,14 -td-si )
					realtime(thePhrase,0)
					task sendNoteOffs(note, thePhrase)
				}
				if (theChord == 38) {# sus
					print("sus")
					thePhrase = transpose(note, 0-td+fi)  | transpose(note,5 - td)  | transpose(note,7 -td - si) 
					realtime(thePhrase,0)
					task sendNoteOffs(note, thePhrase)
				}
				if (theChord == 37) {# dim
					print("dim")
					thePhrase = transpose(note, 0-td+fi)  | transpose(note,3 - td)  | transpose(note,6 -td - si) 
					realtime(thePhrase,0)
					task sendNoteOffs(note, thePhrase)
				}
				if (theChord == 36) {# aug
					print("aug")
					thePhrase = transpose(note, 0-td+fi)  | transpose(note,4 - td)  | transpose(note,8 -td - si) 
					realtime(thePhrase,0)
					task sendNoteOffs(note, thePhrase)
				}


			} 	else {
					if (n > 47) 
						realtime(n,0)
				
			}	

		}
}

