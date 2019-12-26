# This is a simple interpreter loop - create your
# own custom command-line interface.  This one
# accepts these single-letter commands:
#
#   1, 2, 3, etc.  - will play midi files
#   s              - will stop
#   q              - will quit
#   +              - will speed up
#   -              - will slow down

function example7() {

	# Read in the files that will be played
	files = []
	files["1"] = readmf("prelude.mid");
	files["2"] = readmf("jsbach.mid");
	files["3"] = readmf("bachinv1.mid");
	files["4"] = readmf("bachinv2.mid");
	files["5"] = readmf("bachinv3.mid");

	t = -1
	Consecho = 0	# turn off echoing of characters on console
	while ( 1 ) {

		c = Root.waitforconsolekey()

		# "s" will stop
		# "q" will quit
		if ( c == "q" )
			break
		if ( c == "s" ) {
			kill(t)
			continue
		}
		if ( c == "+" ) {
			tempo(tempo()*0.9)
			continue
		}
		if ( c == "-" ) {
			tempo(tempo()*1.1)
			continue
		}

		# If the letter that the user types is
		# one of the array indicies in the files array,
		# play it.
		if ( c in files ) {
			kill(t)		# stop playing of previous one
			t = realtime(files[c])
			continue
		}
	}
	kill(t)
	Consecho = 1
}
