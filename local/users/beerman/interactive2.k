
function midimonx() {

	# spawn the task that will monitor MIDI input
	t = task task_midimon()

	Root.waitforconsolekey()

	kill(t)
}

function task_midimonx() {

	Midiin[$] = f = open()
	onexit(closemidi,$)

	while ( (m=get(f)) != Eof ) {
              
               m.time-=m%1.time
               x=transpose(m,-7)
               realtime(x,Now)
                
               
	}
}
