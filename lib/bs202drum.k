# This code creates drum patterns for the Boss DR202 drum box.

Dr_kick1='p36c10'
Dr_kick2='p35c10'
Dr_snare1='p38c10'
Dr_snare2='p40c10'
Dr_closedhh='p42c10'
Dr_openhh='p46c10'
Dr_ride='p51c10'
Dr_crash='p49c10'
Dr_hit1='p50c10'
Dr_hit2='p47c10'
Dr_hit3='p43c10'
Dr_perc1='p60c10'
Dr_perc2='p61c10'

# We purposely don't include the crash
Dr_all = Dr_kick1 | Dr_kick2 | Dr_snare1 | Dr_snare2 | Dr_closedhh | Dr_openhh
	| Dr_ride | Dr_hit1 | Dr_hit2 | Dr_hit3 | Dr_perc1 | Dr_perc2

# This array controls the possible drum sounds on each step.

Dr_Choices = []
Dr_Choices[ 1 ]= Dr_kick1
Dr_Choices[ 2 ]= Dr_all
Dr_Choices[ 3 ]= Dr_all
Dr_Choices[ 4 ]= Dr_all
Dr_Choices[ 5 ]= Dr_snare1 | Dr_snare2
Dr_Choices[ 6 ]= Dr_all
Dr_Choices[ 7 ]= Dr_all
Dr_Choices[ 8 ]= Dr_all

# These arrays control the min/max values of
# Decay/Cutoff/Resonance/Volume for each step.

DrVals = []
DrVals["D"] = []
DrVals["D"][ 1 ] = ["min"=50,"max"=100]
DrVals["D"][ 2 ] = ["min"=0,"max"=75]
DrVals["D"][ 3 ] = ["min"=0,"max"=100]
DrVals["D"][ 4 ] = ["min"=0,"max"=75]
DrVals["D"][ 5 ] = ["min"=50,"max"=100]
DrVals["D"][ 6 ] = ["min"=0,"max"=75]
DrVals["D"][ 7 ] = ["min"=0,"max"=100]
DrVals["D"][ 8 ] = ["min"=0,"max"=75]

DrVals["C"] = []
DrVals["C"][ 1 ] = ["min"=50,"max"=100]
DrVals["C"][ 2 ] = ["min"=50,"max"=100]
DrVals["C"][ 3 ] = ["min"=50,"max"=100]
DrVals["C"][ 4 ] = ["min"=50,"max"=100]
DrVals["C"][ 5 ] = ["min"=50,"max"=100]
DrVals["C"][ 6 ] = ["min"=50,"max"=100]
DrVals["C"][ 7 ] = ["min"=50,"max"=100]
DrVals["C"][ 8 ] = ["min"=50,"max"=100]

DrVals["R"] = []
DrVals["R"][ 1 ] = ["min"=0,"max"=40]
DrVals["R"][ 2 ] = ["min"=20,"max"=80]
DrVals["R"][ 3 ] = ["min"=20,"max"=80]
DrVals["R"][ 4 ] = ["min"=20,"max"=80]
DrVals["R"][ 5 ] = ["min"=0,"max"=40]
DrVals["R"][ 6 ] = ["min"=20,"max"=80]
DrVals["R"][ 7 ] = ["min"=20,"max"=80]
DrVals["R"][ 8 ] = ["min"=20,"max"=80]

DrVals["V"] = []
DrVals["V"][ 1 ] = ["min"=80,"max"=100]
DrVals["V"][ 2 ] = ["min"=40,"max"=100]
DrVals["V"][ 3 ] = ["min"=50,"max"=100]
DrVals["V"][ 4 ] = ["min"=40,"max"=100]
DrVals["V"][ 5 ] = ["min"=80,"max"=100]
DrVals["V"][ 6 ] = ["min"=40,"max"=100]
DrVals["V"][ 7 ] = ["min"=50,"max"=100]
DrVals["V"][ 8 ] = ["min"=40,"max"=100]

# This array controls the probability of
# a drum sound on each step.

DrVals["%"] = []
DrVals["%"][ 1 ] = 90
DrVals["%"][ 2 ] = 40
DrVals["%"][ 3 ] = 80
DrVals["%"][ 4 ] = 70
DrVals["%"][ 5 ] = 90
DrVals["%"][ 6 ] = 40
DrVals["%"][ 7 ] = 80
DrVals["%"][ 8 ] = 70

# utility function

function bschoose(arr) {
	mn = arr["min"]
	mx = arr["max"]
	dv = mx - mn + 1
	return ( mn + rand(dv) )
}

# This is the function that uses the arrays above to
# generate drum patterns.

function bs202drum(leng) {

	if ( nargs() < 1 )
		leng = 4b

	r = ''
	stepsize = 1b/4
	ns = sizeof(Dr_Choices)
	percent = DrVals["%"]
	rest = 'r' ; rest.length = stepsize

	# Keep generating until the desired length is achieved
	while ( r.length < leng ) {
	    # For each step...
	    for ( n=1; n<=ns; n++ ) { 
		# Decide whether anything will play on this beat
		if ( percent[n] <= rand(100) ) {
			r += rest
			continue
		}
		# Pick the drum we're going to use
		dc = Dr_Choices[n]
		dn = rand(sizeof(dc))
		d = dc%(dn+1)

		# Set volume
		v = bschoose(DrVals["V"][n])

		nt = makenote(d.pitch,stepsize,v,d.chan)

		# Set "R","C","D" parameters (that will control
		# Resonance/Cutoff/Decay)
		atts = []
		atts["R"] = bschoose(DrVals["R"][n])
		atts["C"] = bschoose(DrVals["C"][n])
		atts["D"] = bschoose(DrVals["D"][n])

		# Attach those parameters to the note
		nt.attrib = string(atts)

		# This function converts the parameters
		# attached to a note into the sysex values
		# needed to drive the DR202 drum box.
		nt = dr202decode(nt)

		r += nt
	    }
	}
	# Make sure the result is the exact desired length
	r = cut(r,CUT_TIME,0,leng)

	# Add some "pre-echoes" to some of the notes.
	# These are the quick "triplet-like" things that
	# add some interest.
	if ( ! defined(Nobspreechoes) ) {
		# add some pre-echoes
		rn = onlynotes(r)	# to get rid of sysex's
		# Pick some notes in the phrase (1 out of 14)
		rsome1 = rn{??.time > 0 && rand(14)==0 }
		# Pick some other notes in the phrase (1 out of 8)
		rsome2 = rn{??.time > 0 && rand(8)==0 }
		# Remove them from the original phrase
		r -= rsome1
		r -= rsome2
		# Generate "pre-echoes" for those notes
		rsome1 = echomaster(rsome1,0,0,0,2,1b/8,0.75)
		rsome2 = echomaster(rsome2,0,0,0,1,1b/4,0.60)
		# Add the results back to the original phrase
		r |= rsome1
		r |= rsome2
	}
	return(r)
}

function bs202drum4() {
	return(bs202drum(4b))
}
function bs202drum8() {
	return(bs202drum(8b))
}
function bs202drumn(b,n) {
	r = ''
	for ( i=0; i<n; i++ )
		r += bs202drum(b)
	return(r)
}
