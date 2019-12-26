# A game for ear training, sort of.
#
# Play a random note, wait for the user to press the same note.
# If they play the right note, indicate that they found it by
# playing that note in a quick repeated pattern, and then choose a new note.

function eargame() {
	# Start the game as a background task,
	# and kill it as soon as you press a key on the console.
	t = task task_eargame()
	Root.waitforconsolekey()
	kill(t)
}
function task_eargame() {
	lowpitch = 40
	highpitch = 90
	range = highpitch-lowpitch
	Midiin[$] = f = open()
	onexit(closemidi,$)
	choose = ''
	while ( 1 ) {
		if ( choose == '' )
			choose = makenote(lowpitch+rand(range))

		# Play the note that you want the person to match
		realtime(choose)
		while ( 1 ) {

			# Get a MIDI message
			m = get(f)

			# Wait for a note-off before playing the note again
			if ( m.type == NOTEOFF ) {
				sleeptill(Now+1b/2)
				break
			}
			# If the user matches the note...
			if ( m.type == NOTEON && m.pitch == choose.pitch ) {

				# Play the note in a quick repeated
				# pattern to indicate that you found it.
				realtime(step(repeat(choose,8),1b/8))

				# Provide some space before the next new note
				sleeptill(Now+2b)
				choose = ''
			}
		}
	}
}
