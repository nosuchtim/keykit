function maptoscale(s,key) {
	allnotes = ''
	scale = scalenamed(s)
	if ( scale == '' ) {
		scale = chordnamed(s)
		if ( scale == '' ) {
			print("No Scale or Chord named "+s)
			return('')
		}
	}
	scale.time = 0
	scale.pitch += canonic(key)
	return(scale)
}

function allnotesin(s,key) {
	allnotes = ''
	scale = maptoscale(s,key)
	for ( n in scale ) {
		n.pitch = n.pitch % 12
		while ( n.pitch < 128 ) {
			if ( ! ( n in allnotes ) )
				allnotes |= n
			if ( n.pitch >= 116 )
				break
			n.pitch += 12
		}
		
	}
	return(allnotes)
}

function remapper(chantomap) {

	# spawn the task that will monitor MIDI input
	t2 = task task_remapper_checkallowed()
	t1 = task task_remapper(chantomap)
	onexit(global(killtids),t1,t2)
	wait(t1)
	wait(t2)
	print("remapper ends")
}

function task_remapper_quit(o,mf) {
	onexit(closemidi,$)
	Mergefilter = mf
}

function task_remapper_checkallowed() {
	Allowednotes = ''
	currentkey = ''
	currentmapto = ""
	tm = Now
	inc = milliclicks(500)
	for ( ;; ) {
		if ( currentkey != Key || currentmapto != Mapto ) {
			Allowednotes = allnotesin(Mapto,Key)
			currentmapto = Mapto
			currentkey = Key
		}
		tm += inc
		sleeptill(tm)
	}
}

function task_remapper(chantomap) {

	Midiin[$] = f = open()
	onexit(task_remapper_quit,$,Mergefilter)

	Mergefilter |= 1<<(chantomap-1)

	currentallowed = ''
	while ( (m=get(f)) != Eof ) {
		if ( m.chan != chantomap )
			continue
		if ( m.type != NOTEON && m.type != NOTEOFF ) {
			# We're note merging this channel, so we
			# need to do it manually
			realtime(m,0)
			continue
		}

		# We only let the allowed notes change
		# when no notes (other than the one we've just
		# started) are still down
		if ( m.type == NOTEON && Current==m ) {
			currentallowed = Allowednotes
		}

		m = pitch_allowed_remap(m,currentallowed)
		realtime(m,0)
	}
}

function pitch_allowed_remap(m,currentallowed) {
	mindp = 1000
	lastdp = 1000
	found = ''
	for ( n in currentallowed ) {
		dp = n.pitch - m.pitch
		if ( dp < 0 )
			dp = -dp
		if ( dp < mindp ) {
			mindp = dp
			found = n
		}
		if ( dp > lastdp )
			break
		lastdp = dp
	}
	if ( found == '' )
		return('')
	m.pitch = found.pitch
	return(m)
}
