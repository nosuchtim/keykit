#
# This is an example program that allows phrases (obtained from, in this
# example, MIDI files) to be trigged by an external keyboard
#

function keymapdemo() {

	# Turn Merge off so that the notes you play on the external
	# keyboard aren't actually echoed (this assumes that you don't have
	# the external keyboard directly driving your MIDI synths).
	print("Turning Merge off...")
	Merge = 0

	# spawn the task that will monitor the keyboard and trigger phrases
	t = task task_keymap()

	Root.waitforconsolekey()

	print("Turning Merge back on...")
	kill(t)
	Merge = 1;
}

function task_keymap() {

	Midiin[$] = f = open()
	onexit(closemidi,$)
	phrases = []

	# Create an array (0 to 127) of phrases that will be triggered for
	# each received NOTEON.  The phrases we create here are just
	# an example - here we create a "reversed" keyboard.

	for ( n=0; n<128; n++ ) {
		phrases[n] = makenote(127-n)
		# You could, for example, read MIDI files into each phrase, like this
		# phrases[n] = readmf("phrase"+string(n)+".mid")
	}

	t = -1
	# Read MIDI input, triggering phrases on each NOTEON
	while ( (m=get(f)) != Eof ) {
		if ( m.type==NOTEON ) {
			p = phrases[m.pitch]

			# stop the previous one, if it exists
			if ( t >= 0 )
				kill(t)

			t = realtime(p)
		}
	}
}
