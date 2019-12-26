#######################################################
#
# An example - realtime grabbing/processing of snippets.
#
# Two "trigger" notes are used - one of them will advance
# to the next "state", and the other will clear everything.
#
# This code is driven by an array that defines a set of
# "states".  Each state is defined by functions that:
#
#    - get called when the trigger notes are detected,
#    - get called to map MIDI input notes
#
#######################################################

function snipper() {

	realtime(ano())

	realtime(sc7turnoff(1))
	realtime(sc7turnon(2,3,4,5))

	realtime(progchange(12,2))	# vibes
	realtime(progchange(72,3))	# clarinet
	realtime(progchange(42,4))	# violin
	realtime(progchange(31,5))	# lead guitar

	print("Press note for trigger 1")
	Trig1 = getanote()
	print("Press note for trigger 2")
	Trig2 = getanote()

	Scale = chordnamed("MajB769")
	Scale.pitch += canonic('c')

	saveMerge = Merge
	Merge = 0
	Current = ''

	t1 = task snipper_task_main(1)

	Root.waitforconsolekey()

	kill(t1)
	kill(LoopTid)

	realtime(ano())
	realtime(sc7turnon(1))

	Merge = saveMerge

	print("Done.")
}

######################################################
#
# This function is used to grab what's been recently
# recorded, and add it to the LoopSnippet array.
# Recorded things are kept in the Snippet phrase.
#
######################################################

function grab_snippet(tm) {

	# Add NOTEOFF's for any currently-held notes, so
	# the Snippet is sane
	for ( nt in Current ) {
		if ( nt.chan == Trig1.chan && nt.pitch == Trig1.pitch )
			continue
		if ( nt.chan == Trig2.chan && nt.pitch == Trig2.pitch )
			continue
		# Make sure we take mapping into account!
		func = InState[State]["mapper"]
		nt = func(nt)
		if ( nt != '' ) {
			nt.type = NOTEOFF
			nt.time = tm
			Snippet |= nt
		}
	}
	Snippet = mergeonoff(Snippet)

	# If it's the first one...

	if ( LoopLength < 0 ) {
		p = lastbunch(Snippet,4b)
		# If nothing was present, don't do anything
		if ( p == '' )
			return(State)
		t1 = p%1.time
		p = strip(p)
		p.length = tm - t1
		LoopLength = p.length
		LoopNextTime = tm
		LoopSnippet[0] = p
		LoopTid = task snipper_task_loop()
	} else {

		# Subsequent snippets get adjusted to match the
		# length and time of the first one

		loopstart = LoopNextTime
		if ( (tm-loopstart) < -(LoopLength)/2 ) {
			# We got the trigger closer to
			# the start time of the
			# previous loop iteration,
			# so we want to deal with the
			# previous iteration.
			loopstart -= LoopLength
			usingprev = 1
		} else {
			usingprev = 0
		}
		tm1 = loopstart - LoopLength
		p = cut(Snippet,CUT_TIME,tm1,loopstart)
		p.time -= tm1
		p.length = LoopLength
		if ( usingprev ) {
			# if we grab the previous
			# iteration, then the current
			# one is already going, and
			# even though we add addthis,
			# it's not going to play until
			# the next loop.  So we play
			# it ourselves.
			realtime(p,loopstart)
		}
		LoopSnippet[sizeof(LoopSnippet)] = p
	}
	Snippet = ''
	return(State+1)
}

######################################################
#
# This function clears all recorded snippets.
#
######################################################

function clear_all() {
	# Clear everything
	if ( LoopLength > 0 ) {
		kill(LoopTid)
		realtime(ano())
	}
	LoopSnippet = []
	LoopLength = -1
	LoopTid = -1
	CurrentTrans = 0
	NextTrans = 999
	Snippet = ''
	ForeverCount = 0
	return(0)	# return to State 0
}

######################################################
#
# These functions map notes to a
# specific scale on a specific MIDI channel.
#
######################################################

function map_scale_chan2(m) {
	return(map_scale(m,2))
}
function map_scale_chan3(m) {
	return(map_scale(m,3))
}
function map_scale_chan4(m) {
	return(map_scale(m,4))
}
function map_scale_chan5(m) {
	return(map_scale(m,5))
}

function map_scale(m,ch) {
	found = closest(m,Scale)
	if ( found != '' )
		m.pitch = found.pitch
	if ( nargs() > 1 )
		m.chan = ch
	return(m)
}

#######################################################
#
# This function alternatively does one of two things:
#
#    - Generates a random transpose value for the next loop
#    - Shuffles the channel numbers of the snippets, so that
#      different instruments play each part
#    - Reverses the snippets
#
#######################################################

function trans_rand_forever() {

	# We cycle between three behaviours

	t = ForeverCount++ % 3
	if ( t == 0 ) {

		# An array of potential transpose values
		transvals = [	0=3,
				1=5,
				2=7,
				3=-3,
				4=-5,
				5=-7
			]
		# Pick a transpose value randomly
		NextTrans = transvals[rand(sizeof(transvals))]
	}
	else if ( t == 1 ) {
		# Rotate the channel numbers
		# we've recorded.
		c0 = LoopSnippet[0].chan
		ns = sizeof(LoopSnippet)
		for ( n=1; n<ns; n++ )
			LoopSnippet[n-1].chan = LoopSnippet[n].chan
		LoopSnippet[ns-1].chan = c0
	}
	else if ( t == 2 ) {
		# Reverse all the snippets
		ns = sizeof(LoopSnippet)
		for ( n=0; n<ns; n++ )
			LoopSnippet[n] = reverse(LoopSnippet[n])
	}
	return(State)
}

#######################################################
#
# This is where it all really gets set up.
#
# The InState array contains the functions that get
# called when trigger notes are detected, and when
# MIDI input notes are received.
#
#######################################################

function snipper_task_main(chantomap) {

	Midiin[$] = f = open()
	onexit(global(closemidi),$)

	InState = []

	######## In State 0, we map things to channel 2

	InState[0] = [
		"triggers" = [1=grab_snippet,2=clear_all],
		"mapper" = map_scale_chan2
	]

	######## In State 1, we map things to channel 3

	InState[1] = [
		"triggers" = [1=grab_snippet,2=clear_all],
		"mapper" = map_scale_chan3
	]

	######## In State 2, we map things to channel 4,
	######## and transpose/rotate things

	InState[2] = [
		"triggers" = [1=trans_rand_forever,2=clear_all],
		"mapper" = map_scale_chan4
	]

	clear_all()
	State = 0

	# Here we grab MIDI input messages and process them

	while ( (m=get(f)) != Eof ) {

		# Look for the trigger notes

		trig = 0
		if ( m.chan == Trig1.chan && m.pitch == Trig1.pitch )
			trig = 1
		if ( m.chan == Trig2.chan && m.pitch == Trig2.pitch )
			trig = 2

		if ( trig != 0 ) {

			if ( m.type == NOTEON ) {

				# Invoke the appropriate "trigger" function
				# assigned to the current state.

				func = InState[State]["triggers"][trig]
				newstate = func(m.time)
				if ( typeof(newstate) != "integer"
					|| newstate < 0 
					|| newstate > sizeof(InState) )
					print("Warning: bad state value")
				else
					State = newstate
			}
			continue
		}

		if ( m.chan!=chantomap || m.type!=NOTEON && m.type!=NOTEOFF )
			continue

		# Use the "mapper" function for the current state, to
		# transform the received midi note.

		func = InState[State]["mapper"]
		m = func(m)

		if ( m != '' ) {

			# Add it to the Snippet phrase
			Snippet |= m

			if ( CurrentTrans != 0 )
				m.pitch += CurrentTrans
			realtime(m,0)
		}
	}
}

#######################################################
#
# This function loops, playing the Snippets we've grabbed,
# and transposing them when told to.
#
#######################################################

function snipper_task_loop() {
	while ( 1 ) {
		p = ''
		for ( n in LoopSnippet )
			p |= LoopSnippet[n]
		if ( NextTrans != 999 ) {
			CurrentTrans += NextTrans
			# Make sure it stays in the range -11 to 11
			CurrentTrans = CurrentTrans % 12
			NextTrans = 999
			realtime(ano())
		}
		if ( CurrentTrans != 0 )
			p.pitch += CurrentTrans
		t1 = realtime(p,LoopNextTime)
		onexit(global(killtids),t1)
		LoopNextTime += LoopLength
		sleeptill(LoopNextTime-8)
	}
}
