function padbuttons {
	butts = [
		"START" = 9,
		"START" = 11,
		"SELECT" = 8,
		"L1" = 6,
		"L2" = 4,
		"R2" = 5,
		"R1" = 7,
		"X" = 2,
		"CIRCLE" = 1,
		"SQUARE" = 3,
		"TRIANGLE" = 0,
		"UP" = 12,
		"DOWN" = 14,
		"RIGHT" = 13,
		"LEFT" = 15
		]
	return(butts)
}

Joypad_nameindex = [
	"X" = 0,
	"UP" = 1,
	"CIRCLE" = 2,
	"LEFT" = 3,
	"RIGHT" = 4,
	"TRIANGLE" = 5,
	"DOWN" = 6,
	"SQUARE" = 7
	]

function joypad_name2index(nm) {
	if ( nm in Joypad_nameindex )
		return(Joypad_nameindex[nm])
	print("Warning: nm=",nm," is not in Joypad_nameindex")
	return(0)
}

function padorder {
	return(
		[0="X",1="UP",2="CIRCLE",3="LEFT",4="RIGHT",5="TRIANGLE",6="DOWN",7="SQUARE"])
}

function joymapinit() {
	if ( defined(JoyMap) && sizeof(JoyMap) > 0 ) {
		return()
	}
	global(JoyMap)
	JoyMap = []
	joyinit()
	nj = sizeof(JoyNames)
	f = open("buttons","rl","joystick")
	butts = padbuttons()
	bynum = padbuttonsbynum()
	print("Press pads in order, from 0 to ",(nj-1))
	lastjn = -1
	i = 0
	while ( 1 ) {
		p = get(f);
		arr = split(p)
		jn = integer(arr[1])
		bv = integer(arr[3])
		if ( bv == 0 && jn != lastjn ) {
			print("You just pressed pad: ",i)
			JoyMap[jn] = i++
			lastjn = jn
			if ( i >= nj ) {
				break
			}
		}
	}
	print("JoyMap is now initialized.")
}

function padbuttonsbynum {
	bynum = []
	butts = padbuttons()
	for ( s in butts ) {
		bynum[integer(butts[s])] = s
	}
	return(bynum)
}

function joyinit(millipoll) {
	if ( nargs() < 1 )
		millipoll = 2
	global(JoyNames)
	JoyNames = mdep("joystick","init",string(millipoll))
	return(JoyNames)
}

function joyrelease() {
	mdep("joystick","release")
}

function joyplay() {
	joys = joyinit()
	njoy = sizeof(joys)
	f = open("buttons","rl","joystick")
	riffs = []

	butts = padbuttons()
	bynum = padbuttonsbynum()
	for (j=0; j<njoy; j++) {
		riffs[j] = []
		for ( n in bynum ) {
			riffs[j][n] = onlynotes(bsriff())	# get rid of sustain msgs
		}
	}
	tid = []
	while ( 1 ) {
		p = get(f);
		arr = split(p)
		jn = integer(arr[1])
		bn = integer(arr[2])
		if ( ! defined(bn) ) {
			# analog things come out as "Z", etc.
			continue
		}
		bv = integer(arr[3])

		# Quit when we see the start button
		if ( bn == butts["START"] && bv == 1 )
			break

		if ( bv == 0 ) {
			if ( bn in tid )
				kill(tid[bn])
		} else {
			p = riffs[jn][bn]
			tid[bn] = realtime(p,Now)
		}
	}
	close(f)
	joyrelease()
}
function joydrums() {
	joys = joyinit()
	njoy = sizeof(joys)
	f = open("buttons","rl","joystick")

	drums = []
	n = 0
	drums[n++] = gmdrumnamed("Acoustic Bass Drum")
	drums[n++] = gmdrumnamed("Bass Drum 1")
	drums[n++] = gmdrumnamed("Side Stick")
	drums[n++] = gmdrumnamed("Acoustic Snare")
	drums[n++] = gmdrumnamed("Electric Snare")
	drums[n++] = gmdrumnamed("Closed Hi-Hat")
	drums[n++] = gmdrumnamed("Open Hi-Hat")
	drums[n++] = gmdrumnamed("Ride Cymbal 1")
	drums[n++] = gmdrumnamed("Crash Cymbal 1")
	drums[n++] = gmdrumnamed("Cowbell")
	drums[n++] = gmdrumnamed("Tambourine")
	drums[n++] = gmdrumnamed("Cabasa")
	drums[n++] = gmdrumnamed("Short Guiro")
	drums[n++] = gmdrumnamed("Low Floor Tom")
	drums[n++] = gmdrumnamed("High Floor Tom")
	drums[n++] = gmdrumnamed("Low Tom")
	ndrums = n

	riffs = []

	butts = padbuttons()
	bynum = padbuttonsbynum()
	for (j=0; j<njoy; j++) {
		riffs[j] = []
		for ( bn in bynum ) {
			riffs[j][bn] = drums[bn%ndrums]
		}
	}
	tid = []
	print("drums=",drums," ndrums=",ndrums)
	while ( 1 ) {
		p = get(f);
		arr = split(p)
		jn = integer(arr[1])
		bn = integer(arr[2])
		if ( ! defined(bn) ) {
			# analog things come out as "Z", etc.
			continue
		}
		bv = integer(arr[3])

		# Quit when we see the start button
		if ( bn == butts["START"] && bv == 1 )
			break

		if ( bv == 1 ) {
			p = riffs[jn][bn]
			print("bn=",bn," p=",p)
			if ( typeof(p) == "phrase" ) {
				realtime(p,Now)
			}
		}
	}
	close(f)
	joyrelease()
}
function joyfile() {
	joys = joyinit()
	njoy = sizeof(joys)
	fn = browsefiles("Midi File", "*.mid",1)
	if ( fn == "" ) {
		print("No file found")
		return()
	}
	f = open("buttons","rl","joystick")
	riffs = []
	mf = readmf(fn)
	mf = onlynotes(mf)
	mf.chan = 1
	i = 0
	inc = 1b
	butts = padbuttons()
	bynum = padbuttonsbynum()
	order = padorder()
	for (j=0; j<njoy; j++) {
		riffs[j] = []
		for ( k=0; k<sizeof(order); k++ ) {
			lng = inc + 4b
			p = cut(mf,CUT_TIME,i,i+lng)
			p = strip(p)
			p.length = lng
			n = butts[order[k]]
			riffs[j][n] = p
			# i += inc
			i += lng
		}
	}
	tid = []
	dostep = 0
	stepquant = 1b/4
	q = 1b/2
	while ( 1 ) {
		p = get(f);
print(p);
		arr = split(p)
		jn = integer(arr[1])
		bn = integer(arr[2])
		bv = integer(arr[3])

		# Quit when we see the start button
		if ( bn == butts["START"] && bv == 1 )
			break

		# Quit when we see the start button
		if ( bn == butts["SELECT"] && bv == 1 ) {
			dostep=1
		}

print("bn=",bn," bv=",bv);
		if ( bv == 0 ) {
print("TWO")
			if ( bn in tid )
				kill(tid[bn])
		} else {
print("THREE")
			if ( ! (bn in (riffs[jn]) ) ) {
				print("No riff for bn=",bn," in jn=",jn)
			} else {
				p = riffs[jn][bn]
				if ( dostep ) {
					p = step(p,stepquant)
				}
				p = repeat(p,4)
				# p.chan = rand(4)+1
				p.chan = 1+ (jn*bn)%4
				# tid[bn] = realtime(p,nextquant(Now,q))
				tid[bn] = realtime(p,Now)
			}
		}
print("FOUR")
	}
	close(f)
	joyrelease()
}
