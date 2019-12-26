# The goal of this code is to apply a filter to the
# realtime playing of a phrase.  The filter is applied
# to each note in the phrase, JUST BEFORE the note
# is played.  This would be useful if the filter
# was controlled by, say, the value of some
# MIDI controllers (which you could monitor
# in a separate task, perhaps setting some global
# variables to reflect their state).  In this example,
# the filter just randomly varies the channel
# of the output.

function rand_channel (p) {
	p.chan = 1+rand(16)
	return(p)
}

function realmidifilter(p,f) {
	tm0 = Now
	for ( nt in p ) {
		attime = tm0 + nt.time
		if ( attime > Now ) {
			sleeptill(attime-2)
		}
		nt.time = 0
		realtime(f(nt),attime)
	}
}

function example_9(p) {
        task realmidifilter(p,rand_channel)
}

