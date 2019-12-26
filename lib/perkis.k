function task_slidermon() {  # version for reading volume sliders on channels 1-16
    Midiin[$] = f = open()
    onexit(closemidi,$)
    while ( (m=get(f)) != Eof ) {
        if ( m.type == CONTROLLER ) {
            ch = m.chan-1   # our ch space is 0-15
            cnum = integer(subbytes(m,2,1))
            cval = integer(subbytes(m,3,1))
		print("m=",m,"  port=",m.port)
            # printf("%d-%d ",cval, m.port)
	}
   }
}

function slidermon() {

	# spawn the task that will monitor MIDI input
	t = task task_slidermon()

	Root.waitforconsolekey()

	kill(t)
}
