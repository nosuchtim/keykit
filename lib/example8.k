#
# This is an example program that takes MIDI input on
# channel 1, and echos it (immediately) on channels
# 2, 3, and 4.

function example8() {

	# Turn Merge off so that the notes you play on the external
	# keyboard aren't actually echoed (this assumes that you don't have
	# the external keyboard directly driving your MIDI synths).
	print("Turning Merge off...")
	Merge = 0

	# spawn the task that will monitor MIDI input
	t = task task_example8()

	Root.waitforconsolekey()

	print("Turning Merge back on...")
	kill(t)
	Merge = 1;
}

function task_example8() {

        # Arrange for fifo f to get a copy of all Midi input,
        # and make sure it's cleaned up when this task 
        # gets killed.
	Midiin[$] = f = open()
	onexit(closemidi,$)

	# Read MIDI input messages forever (or until
	# the task is killed.
	while ( (n=get(f)) != Eof ) {

		realtime(n,0)	# play everything than comes in
		if ( n.chan == 1 ) {
			n.chan++
			realtime(n,0)	# play it on channel 2
			n.chan++
			realtime(n,0)	# play it on channel 3
			n.chan++
			realtime(n,0)	# play it on channel 4
		}
	}
}
