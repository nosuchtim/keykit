#define xxx rereadlib();leap()

LeapDisplay = 0
LeapChord = ''
LeapScale = makescale(scalenamed("newage"))
LeapRoot = 'p0'
LeapDistThreshold = 0.005
LeapMinPitch = 40
LeapMaxPitch = 110
LeapLast = 0
RoyFreq = 1b/16
RoyDur = 1b/2
RoyQuant = 1b/4

# Roy's keyboard
# RoyLowNote = 49
# RoyHighNote = 72
RoyLowNote = 48
RoyHighNote = 71

Scale1Percent = 100

# my keyboard

SwitchTime = 4b

function x2pitch(x) {
	dp = LeapMaxPitch - LeapMinPitch
	return(LeapMinPitch + integer(dp * x))
}

function leapnote1(sid,x,y,z) {
	nt = 'a'
	nt.pitch = x2pitch(x)
	nt.dur = 1b/16
	nt.chan = (16 * y) % 16
	nt.vol = (128 * z) % 128
	nt.time = Now
	# print("chan",nt.chan,"pitch",nt.pitch,"vol",nt.vol,"x",x,"y",y,"z",z)
	return(nt)
}

function leapnote2(sid,x,y,z) {
	nt = 'a'
	nt.pitch = x2pitch(x)
	nt.dur = 1b/8
	nt.chan = (16 * y) % 16
	nt.vol = (128 * z) % 128
	nt.time = nextquant(Now,1b/8)
	# print("chan",nt.chan,"pitch",nt.pitch,"vol",nt.vol,"x",x,"y",y,"z",z)
	return(nt)
}

function leapnote3(sid,x,y,z) {
	nt = 'a'
	nt.pitch = x2pitch(x)
	nt.dur = 1b/4
	nt.chan = 1
	nt.vol = (128 * z) % 128
	nt.time = nextquant(Now,1b/4)
	# print("chan",nt.chan,"pitch",nt.pitch,"vol",nt.vol,"x",x,"y",y,"z",z)
	return(nt)
}

function leapnote4(sid,x,y,z) {
	nt = 'a'
	nt.pitch = x2pitch(x)
	nt.dur = 1b
	nt.chan = 1
	nt.vol = (128 * z) % 128
	if ( y < 0.2 ) {
		q = 1b/2
	} else if ( y < 0.4 ) {
		q = 1b/4
	} else if ( y < 0.7 ) {
		q = 1b/8
	} else {
		q = 1b/16
	}
	nt.time = nextquant(Now,q)
	# print("chan",nt.chan,"pitch",nt.pitch,"vol",nt.vol,"x",x,"y",y,"z",z)
	return(nt)
}

function leapnote6(sid,x,y,z) {
	nt = 'a'
	nt.pitch = x2pitch(x)
	nt.dur = 1b
	nt.chan = 1
	nt.vol = (128 * z) % 128
	if ( y < 0.25 ) {
		q = 1b/2
	} else if ( y < 0.7 ) {
		q = 1b/4
	} else {
		q = 1b/8
	}
	nt.time = nextquant(Now,q)
	# print("chan",nt.chan,"pitch",nt.pitch,"vol",nt.vol,"x",x,"y",y,"z",z)
	nt = scadjust(nt,LeapScale)
	return(nt)
}

function leapnote5(sid,x,y,z) {
	nt = leapnote4(sid,x,y,z)
	nt = scadjust(nt,LeapScale)
	return(nt)
}

function leapnote7(sid,x,y,z) {
	nt = leapnote4(sid,x,y,z)
	nt.chan = 10
	return(nt)
}

function leapnote8(sid,x,y,z) {
	nt = leapnote6(sid,x,y,z)
	nt.chan = 10
	nt.time = Now
	return(nt)
}

RoyTask = -1
RoyScale1 = 0

function royinit() {
	global RoyScales
	global RoyScale1
	RoyScales = []
	RoyScales1 = []
	# Scale 2 is the diminished
	RoyScales[2] = 'p2,p5,p8,p11'
	RoyScales[1] = 'p0,p4,p7,p9'

	RoyScales1[0] = 'p0,p4,p7,p9'
	RoyScales1[1] = 'p0,p3,p7,p9'
	RoyScales1[2] = 'p0,p3,p6,p9'
	RoyScales1[3] = 'p0,p4,p7,p10'
	RoyScales1[4] = 'p0,p4,p6,p10'
}

function royswitcher() {
	print("royswitcher start")
	RoyState = 1
	print("RoySwitch starts!")
	while ( 1 ) {
		sleeptill(Now+SwitchTime)
		if ( RoyState == 1 ) {
			RoyState = 2
		} else if ( RoyState == 2 ) {
			RoyState = 1
		}
		print("RoyState = ",RoyState)
	}
	print("RoySwitch ends!")
}

function roynote(nt) {
	if ( rand(100) < Scale1Percent ) {
		printf(" 1.%d",RoyScale1)
		nt = scadjust(nt,RoyScales1[RoyScale1])
	} else {
		printf(" 2")
		nt = scadjust(nt,RoyScales[2])
	}
	# printf("=%d",nt.pitch)
	r = rand(3)
	nt.dur = RoyDur

	# print("ROYNOTE=",nt)
	# if ( r == 0 ) {
	# 	nt.dur = RoyDur
	# } else {
	# 	nt.dur = 2 * RoyDur
	# }

	return(nt)
}

function leapnote9(sid,x,y,z) {

	nt = 'a'
	nt.pitch = x2pitch(x)
	nt.dur = 1b
	nt.chan = 1
	nt.vol = (128 * z) % 128

	nt = roynote(nt)
	nt.pitch += LeapRoot.pitch

	if ( y < 0.2 ) {
		q = 1b/2
	} else if ( y < 0.4 ) {
		q = 1b/4
	} else if ( y < 0.7 ) {
		q = 1b/8
	} else {
		q = 1b/16
	}
	nt.time = nextquant(Now,q)
	return(nt)
}

function leap() {
	host = "127.0.0.1"
	port = 3333
	RoyState = 2
	print("Hi from leap()")
	if ( RoyTask > 0 ) {
		kill(RoyTask)
	}
	print("INITIALIZING RoyScales and Switcher")
	royinit()
	RoyTask = -1
	# RoyTask = task royswitcher()
	print("NO AUTO SWITCHER!")
	Merge = 0

	s = string(port)+"@"+host
	f = open(s,"rA","osc_listen")
	if ( f < 0 ) {
		print("Unable to open ",s)
		return()
	}
	t1 = task leaplisten(s,f)
	t2 = task chordlisten()
	notefuncs = [
		"1"=leapnote1,
		"2"=leapnote2,
		"3"=leapnote3,
		"4"=leapnote4,
		"5"=leapnote5,
		"6"=leapnote6,
		"7"=leapnote7,
		"8"=leapnote8,
		"9"=leapnote9
		]
	threshold = [
		"n"=0.000,
		"l"=0.001,
		"m"=0.005,
		"h"=0.010
		]

	global current_notefunc
	current_notefunc = notefuncs["9"]

	while (1) {
		c = Root.waitforconsolekey()
		if ( c == "q" || c == 33 ) {
			break
		}
		if ( c in notefuncs ) {
			current_notefunc = notefuncs[c]
			print("\nSwitching to ",c,"\n")
		} else if ( c in threshold ) {
			LeapDistThreshold = threshold[c]
			print("Threshold = ",LeapDistThreshold)
		} else {
			print("\nUnrecognized: ",c,"\n")
		}

	}
	print("\n")
        kill(t1)
        kill(t2)
	kill(RoyTask)
	close(f)
}

function chordlisten() {
	Midiin[$] = f = open()
	LeapChord = ''
	while ( 1 ) {
		nt = get(f)
		if ( nt.type != NOTEON ) {
			continue
		}
		nt.type = NOTE
		print("nt.pitch=",nt.pitch," lownote=",RoyLowNote)
		if ( nt.pitch >= RoyLowNote && nt.pitch <=RoyHighNote ) {
			nt.pitch -= RoyLowNote
			if ( nt.pitch == 0 ) {
				Scale1Percent = 100
			} else if (nt.pitch == 1 ) {
				Scale1Percent = 75
			} else if (nt.pitch == 2 ) {
				Scale1Percent = 50
			} else if (nt.pitch == 3 ) {
				Scale1Percent = 25
			} else if (nt.pitch == 4 ) {
				Scale1Percent = 0

			} else if (nt.pitch == 5 ) {
				RoyScale1 = 0
			} else if (nt.pitch == 6 ) {
				RoyScale1 = 1
			} else if (nt.pitch == 7 ) {
				RoyScale1 = 2
			} else if (nt.pitch == 8 ) {
				RoyScale1 = 3
			} else if (nt.pitch == 9 ) {
				RoyScale1 = 4

			} else if (nt.pitch == 10 ) {
				RoyDur = 1b/2
			} else if (nt.pitch == 11 ) {
				RoyDur = 1b*2

			} else if (nt.pitch == 12 ) {
				Offsetpitch = 0
			} else if (nt.pitch == 13 ) {
				Offsetpitch = 1
			} else if (nt.pitch == 14 ) {
				Offsetpitch = 2
			} else if (nt.pitch == 15 ) {
				Offsetpitch = 3
			} else if (nt.pitch == 16 ) {
				Offsetpitch = 4
			} else if (nt.pitch == 17 ) {
				Offsetpitch = 5
			} else if (nt.pitch == 18 ) {
				Offsetpitch = 6
			} else if (nt.pitch == 19 ) {
				Offsetpitch = 7
			} else if (nt.pitch == 20 ) {
				Offsetpitch = 8
			} else if (nt.pitch == 21 ) {
				Offsetpitch = 9
			} else if (nt.pitch == 22 ) {
				Offsetpitch = 10
			} else if (nt.pitch == 23 ) {
				Offsetpitch = 11
			}

			continue
		}
		nt = roynote(nt)
		nt.time = nextquant(Now,RoyFreq)
# print("playing nt=",nt)
		realtime(nt,0)
		continue

		c = makenote(canonic(nt))

		if ( nt.type == NOTEON ) {
			if ( sizeof(Current) == 1 ) {
				print("NEW CHORD!")
				LeapChord = c
			} else {
				LeapChord |= c
			}
			LeapScale = makescale(LeapChord)
			LeapRoot = c
			print("Chord = ",LeapChord," Root = ",LeapRoot)
		}
		if ( nt.type == CONTROLLER ) {
			print("controller=",nt)
# print("playing controller nt=",nt)
			realtime(nt,0)
		}
	}
}

function leaplisten(s,f) {
	print("Now listening on ",s)
	sidpos = []
	while ( (d = get(f)) != Eof ) {
		nmsg = d["elements"]
		for ( n=0; n<nmsg; n++ ) {
			msg = d[n]
			addr = msg[0]
			if ( addr != "/tuio/25Dcur" && addr != "/tuio/2Dcur" && addr != "/tuio/25Dblb" ) {
				continue
			}
			cmd = msg[1]
			if ( cmd != "set" ) {
				continue
			}
			sid = msg[2]
			x = msg[3]
			y = msg[4]
			z = msg[5]
			dist = 1.0
			if ( sid in sidpos ) {
				lastx = sidpos[sid]["x"]
				lasty = sidpos[sid]["y"]
				lastz = sidpos[sid]["z"]
				dx = lastx - x
				dy = lasty - y
				dz = lastz - z
				dist = sqrt(dx*dx+dy*dy+dz*dz)
			}
			# print("Now=",Now," LeapLast=",LeapLast)
			if ( dist > LeapDistThreshold && ((Now-LeapLast)>RoyFreq) ) {
				# print("dist=",dist)
				nt = current_notefunc(sid,x,y,z)
# print("playing dist nt=",nt)
				realtime(nt,0)
				LeapLast = nt.time
				global LeapDisplay
				if ( LeapDisplay != 0 ) {
					LeapDisplay.poke(nt.time,x,y,z)
				}
			}
			sidpos[sid] = ["x"=x,"y"=y,"z"=z]
		}
	}
}
