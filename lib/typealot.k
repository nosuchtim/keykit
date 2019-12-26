#
# typealot - playing with letters
#
# Run this function, and you can attach phrases to the letters on your
# keyboard (the computer keyboard, not the MIDI one), and then play them.
#
# After invoking this function, you should play something on your MIDI
# keyboard, and then press an upper-case letter on your computer keyboard.
# The notes that you just played will be assigned to that letter.
# Then, whenever you press the corresponding lower-case letter on your
# computer keyboard, the phrase will be played.
#
# The "phrase" that is grabbed, when you press an upper-case letter,
# is determined by using the expression "lastbunch(Recorded,1b)" -
# this searches the Recorded MIDI input backward (from the end) looking
# for the first 1-beat space - and it then returns everything from that
# point forward.  I.e. if you just played 4 notes (after a pause of at least
# 1 beat), it will get those 4 notes.
#
# By pressing ">" you can save your current collection of phrases in
# a file.  By pressing "<" you can read a previously-saved file.

function typealot(fname) {

	ascii_a = ascii("a")
	ascii_z = ascii("z")
	ascii_A = ascii("A")
	ascii_Z = ascii("Z")

	# initialize the array of phrases attached to each key
	TypePhrases = []
	for ( n=ascii_a; n<=ascii_z; n++ )
		TypePhrases[n] = ''

	# Optional argument is a filename to read to initialize the array
	if ( nargs() > 0 )
		typealot_read(fname)

	print("===== Typealot =====")
	print("Upper case letters grab recent MIDI input.");
	print("Lower case letters play things assigned to upper case letters.")
	print("Type away...  (ESC or control-d will abort)")
	Consecho = 0
	tid = -1
	while ( 1 ) {
		c = Root.waitforconsolekey()
		ch = ascii(c)
		# Pressing ESC or control-d will get you out
		if ( ch == 27 || ch == 4 )
			break
		if ( ch in TypePhrases ) {
			p = TypePhrases[ch]
			if ( p != '' ) {
				# Stop the previous phrase (if still playing)
				kill(tid)
				# Play the phrase assigned to the letter
				tid = realtime(p)
			}
		}
		else if ( ch >= ascii_A && ch <= ascii_Z ) {
			ch = ch - ascii_A + ascii_a
			TypePhrases[ch] = strip(lastbunch(Recorded,1b))
			print("Character ",ascii(ch)," now plays ",sizeof(TypePhrases[ch])," notes.")
		} else if ( ch == ascii(">") ) {
			fname = typealot_prompt("Enter file to write to --> ")
			typealot_write(fname)
		} else if ( ch == ascii("<") ) {
			fname = typealot_prompt("Enter file to read --> ")
			typealot_read(fname)
		}
	}
	Consecho = 1
}

function typealot_prompt(prompt) {
	r = ""
	Consecho = 1
	consoleprintf(prompt)
	while ( 1 ) {
		c = Root.waitforconsolekey()
		if ( c == "\r" || c == "\n" )
			break
		r += c
	}
	Consecho = 0
	return(r)
}

function typealot_read(fname) {
	f = open(fname,"r")
	if ( f < 0 )
		print("Can't open file: ",fname)
	else {
		# Read the file and put the array it contains
		# into TypePhrases.
		a = get(f)
		eval ("TypePhrases="+a)
		close(f)
		print("File ",fname," read.")
	}
}

function typealot_write(fname) {
	f = open(fname,"w")
	if ( f < 0 )
		print("Can't open file: ",fname)
	else {
		put(f,string(TypePhrases))
		close(f)
	}
	print("File ",fname," written.")
}
