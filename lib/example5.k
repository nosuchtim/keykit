#
# This is an example program that takes MIDI input and
# maps it to different channels.  Every time a NOTEOFF
# is received on MIDI input, the channel (to which all
# subsequent input is mapped) will be incremented.
# The channels used will be 1,2,3,4,1,2,3,4,...
#
# In other words, if you play 5 notes on your MIDI keyboard,
# the first will be on channel 1, the second will be
# on channel 2, the third will be on channel 3, the fourth
# will be on channel 4, and the fifth will be on channel 1.
# The MIDI channels on the incoming MIDI will be ignored.
#
# Naturally, the most interesting way to use this is to set up
# your synthesizer so that it contains different patches
# on channels 1 through 4.

function example5() {

	# Turn Merge off so that the notes you play on the external
	# keyboard aren't actually echoed (this assumes that you don't have
	# the external keyboard directly driving your MIDI synths).
	print("Turning Merge off...")
	Merge = 0

	# spawn the task that will monitor MIDI input
	t = task task_example5()

	Root.waitforconsolekey()

	print("Turning Merge back on...")
	kill(t)
	Merge = 1;
}

function task_example5() {

        # Arrange for fifo f to get a copy of all Midi input,
        # and make sure it's cleaned up when this task 
        # gets killed.
	Midiin[$] = f = open()
	onexit(closemidi,$)

	lowchan = 1
	highchan = 4
	ch = lowchan

	# Read MIDI input messages forever (or until
	# the task is killed.
	while ( (n=get(f)) != Eof ) {

		if ( n.type == NOTEON
			|| n.type == NOTEOFF
			|| n.type == CHANPRESSURE
			|| n.type == CONTROLLER
			|| n.type == PITCHBEND ) {
			n.chan = ch
		}
		if ( n.type == NOTEOFF && sizeof(Current) == 0 ) {
			# Cycle from lowchan to highchan
			if ( ch < highchan )
				ch++
			else
				ch = lowchan
		}
		realtime(n,0)	# play it
	}
}
