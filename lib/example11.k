# Read notes from Midi input, and construct a phrase.
# When you get a note below 'c1', then start playing
# them back under control of Midi input.
#
# See other example*.k files for an explanation
# of what Midiin[] and Merge do.

function example_11() {


        Midiin[$] = f = open()
	print("Play some notes, then a note below C2 to finish...")
	p = ''
	while ( 1 ) {
		nt = get(f)
		if ( nt.pitch < 'c2'.pitch )
			break
		p += nt
	}

	# Wait for the noteoff following the 'c2' noteon
	get(f)

	print("Now you can play them back...")

	Merge = 0
	for ( nt in p ) {
		# Wait for the next message on MIDI input
		m = get(f)
		# Apply the pitch from our saved phrase
		m.pitch = nt.pitch
		realtime(m,0)
	}
	closemidi(f)
	Merge = 1
	print("Done!")
	
}
