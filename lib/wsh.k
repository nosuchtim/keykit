# This function is a private one for TJT - it is the "startup"
# stuff for Tim's Woodstockhause performances.

function wsh2000() {
	# Filter out channels 1 through 4
	# Mergefilter = 1<<0 | 1<<1 | 1<<2 | 1<<3

	# Filter out channel 5
	Mergefilter = 1<<4

	# Drums
	realtime(jv_bank_patch(10,"S",7))	# normal

	r = ''

	# Turn the Expresson (controller 11) down on channels 5,6,7,8
	# This doesn't affect the Nord - they're listening to controller 7
	r += controller(5,11,0)
	r.length++
	r += controller(6,11,0)
	r.length++
	r += controller(7,11,0)
	r.length++
	r += controller(8,11,0)
	r.length++

	realtime(r)
}

function wsh2001() {
	realtime(gs_reset())
	if ( defined(Typodefaultfile) ) {
		print("Typodefaultfile=",Typodefaultfile)
		typo(Typodefaultfile,1)
	} else {
		typo()
	}
}

function wsh() { wsh2001() }
