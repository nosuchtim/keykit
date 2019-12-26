
function monitor() {

	# spawn the task that will monitor MIDI input
	t = task task_midimon()

	Root.waitforconsolekey()

	kill(t)
}

function task_monitor() {

	Midiin[$] = f = open()
	onexit(closemidi,$)

	while ( (m=get(f)) != Eof ) {

               m.time-=m%1.time
		print(m)
               x=transpose(m,-0)
               realtime(x,Now)


	}
}
