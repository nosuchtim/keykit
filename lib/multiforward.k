
function multiforward() {

	# spawn the task that will monitor MIDI input
	t = task task_multiforward()

	Root.waitforconsolekey()

	print("Turning Merge back on...")
	kill(t)
	Merge = 1;
}

function task_multiforward() {

        # Arrange for fifo f to get a copy of all Midi input,
        # and make sure it's cleaned up when this task 
        # gets killed.
	Midiin[$] = f = open()
	onexit(closemidi,$)

	out1 = lookforandopen("output","loopMIDI Port 3")
	out2 = lookforandopen("output","loopMIDI Port 4")

	# Read MIDI input messages forever (or until
	# the task is killed.
	while ( (n=get(f)) != Eof ) {

		print("n=",n);
		n.port = out1
		realtime(n,0)
		n.port = out2
		realtime(n,0)
	}
}
