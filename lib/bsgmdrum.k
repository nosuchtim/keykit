
Dr_GM_kick1=gmdrumnamed("Acoustic Bass Drum")
Dr_GM_kick2=gmdrumnamed("Bass Drum 1")
Dr_GM_stick=gmdrumnamed("Side Stick")
Dr_GM_snare1=gmdrumnamed("Acoustic Snare")
Dr_GM_snare2=gmdrumnamed("Electric Snare")
Dr_GM_closedhh=gmdrumnamed("Closed Hi-Hat")
Dr_GM_openhh=gmdrumnamed("Open Hi-Hat")
Dr_GM_ride=gmdrumnamed("Ride Cymbal 1")
Dr_GM_crash=gmdrumnamed("Crash Cymbal 1")
Dr_GM_hit1=gmdrumnamed("Cowbell")
Dr_GM_hit2=gmdrumnamed("Tambourine")
Dr_GM_hit3=gmdrumnamed("Cabasa")
Dr_GM_hit4=gmdrumnamed("Short Guiro")
Dr_GM_tom1=gmdrumnamed("Low Floor Tom")
Dr_GM_tom2=gmdrumnamed("High Floor Tom")
Dr_GM_tom3=gmdrumnamed("Low Tom")

# We purposely don't include the crash
Dr_GM_all = Dr_GM_kick1 | Dr_GM_kick2 | Dr_GM_stick
	| Dr_GM_snare1 | Dr_GM_snare2
	| Dr_GM_closedhh | Dr_GM_openhh
	| Dr_GM_ride | Dr_GM_hit1 | Dr_GM_hit2 | Dr_GM_hit3
	| Dr_GM_tom1 | Dr_GM_tom2 | Dr_GM_hit4 | Dr_GM_tom3

Dr_GM_Choices = []
Dr_GM_Choices[ 1 ]= Dr_GM_kick1 | Dr_GM_kick2
Dr_GM_Choices[ 2 ]= Dr_GM_all
Dr_GM_Choices[ 3 ]= Dr_GM_all
Dr_GM_Choices[ 4 ]= Dr_GM_all
Dr_GM_Choices[ 5 ]= Dr_GM_snare1 | Dr_GM_snare2
Dr_GM_Choices[ 6 ]= Dr_GM_all
Dr_GM_Choices[ 7 ]= Dr_GM_all
Dr_GM_Choices[ 8 ]= Dr_GM_all

Dr_GM_Vals = []

Dr_GM_Vals["V"] = []
Dr_GM_Vals["V"][ 1 ] = ["min"=80,"max"=100]
Dr_GM_Vals["V"][ 2 ] = ["min"=20,"max"=100]
Dr_GM_Vals["V"][ 3 ] = ["min"=30,"max"=100]
Dr_GM_Vals["V"][ 4 ] = ["min"=20,"max"=100]
Dr_GM_Vals["V"][ 5 ] = ["min"=80,"max"=100]
Dr_GM_Vals["V"][ 6 ] = ["min"=20,"max"=100]
Dr_GM_Vals["V"][ 7 ] = ["min"=30,"max"=100]
Dr_GM_Vals["V"][ 8 ] = ["min"=20,"max"=100]

Dr_GM_Vals["%"] = []
Dr_GM_Vals["%"][ 1 ] = 90
Dr_GM_Vals["%"][ 2 ] = 40
Dr_GM_Vals["%"][ 3 ] = 80
Dr_GM_Vals["%"][ 4 ] = 70
Dr_GM_Vals["%"][ 5 ] = 90
Dr_GM_Vals["%"][ 6 ] = 40
Dr_GM_Vals["%"][ 7 ] = 80
Dr_GM_Vals["%"][ 8 ] = 70

function bsgmdrum4() {
	return(bsgmdrum(4b))
}
function bsgmdrum8() {
	return(bsgmdrum(8b))
}
function bsgmdrumn(b,n) {
	r = ''
	for ( i=0; i<n; i++ )
		r += bsgmdrum(b)
	return(r)
}
function bsgmdrum(leng) {

	if ( nargs() < 1 )
		leng = 4b

	r = ''
	stepsize = 1b/4
	ns = sizeof(Dr_GM_Choices)
	percentvals = Dr_GM_Vals["%"]
	volvals = Dr_GM_Vals["V"]
	rest = 'r' ; rest.length = stepsize
	while ( r.length < leng ) {
	    for ( n=1; n<=ns; n++ ) { 
		if ( percentvals[n] <= rand(100) ) {
			r += rest
			continue
		}
		# Pick the drum we're going to use
		dc = Dr_GM_Choices[n]
		dn = rand(sizeof(dc))
		d = dc%(dn+1)

		# Set volume
		v = bschoose(volvals[n])

		nt = makenote(d.pitch,stepsize,v,d.chan)
		r += nt
	    }
	}
	r = cut(r,CUT_TIME,0,leng)

	if ( ! defined(Nobspreechoes) ) {
		# add some pre-echoes
		rsome1 = r{??.time > 0 && rand(14)==0 }
		rsome2 = r{??.time > 0 && rand(8)==0 }
		r -= rsome1
		r -= rsome2
		rsome1 = echomaster(rsome1,0,0,0,2,1b/8,0.75)
		rsome2 = echomaster(rsome2,0,0,0,1,1b/4,0.60)
		r |= rsome1
		r |= rsome2
	}

	return(r)
}

