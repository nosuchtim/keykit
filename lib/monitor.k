# Utilities to monitor things and notify things

function volmonitor(notify,echorest) {

	if ( nargs() < 2 ) 
		echorest = 0

	if ( typeof(notify) != "array" ) {
		print("volmonitor expects an array as first argument.")
		return()
	}

        # Arrange for fifo f to get a copy of all Midi input,
        # and make sure it's cleaned up when this task 
        # gets killed.
	Midiin[$] = f = open()
	onexit(closemidi,$)

	# Read MIDI input messages forever (or until
	# the task is killed.
	while ( (n=get(f)) != Eof ) {

		if ( n.type == CONTROLLER && subbytes(n,2,1) == 7 ) {
			b2 = subbytes(n,3,1)
			for ( obj in notify ) {
				obj.volchanged(n.chan,b2)
			}
		} else if ( echorest ) {
			realtime(n,0)
		}
	}
}

