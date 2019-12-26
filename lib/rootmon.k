
function rootmon() {

	# spawn the task that will monitor MIDI input
	t = task task_rootmon()

	Root.waitforconsolekey()

	kill(t)
}

function task_rootmon() {

	incr = 2b
	next = Now
	realtime(Met,next)      # first beat

	while ( 1 ) {

		# we schedule the metronome one beat ahead
		next += incr
		realtime(Met,next)

		sleeptill(next)
		bunch = cut(Recorded,CUT_TIME,next,next-incr,TRUNCATE)
		bunch |= Current
		if ( sizeof(bunch) > 0 ) {

			# Take only the notes within
			# an octave of the lowest note
			low = lowest(bunch)
			bunch = bunch{??.pitch<=(low+12)}

			r = findroot(bunch)
			pretty = 'a' ; pretty.pitch = r.pitch
			print(pretty)
		}
	}
}
