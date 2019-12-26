#define xxx rereadlib();creative()

LeapDisplay = 0
LeapChord = ''
LeapScale = makescale(scalenamed("newage"))
LeapRoot = 'p0'
LeapDistThreshold = 0.01
LeapMinPitch = 30
LeapMaxPitch = 127
LeapLast = 0
CreativeFreq = 1b/16
CreativeDur = 1b/2
CreativeQuant = 1b/4

# Creative's keyboard
# CreativeLowNote = 49
# CreativeHighNote = 72
CreativeLowNote = 28
CreativeHighNote = 120

Scale1Percent = 100

# my keyboard

SwitchTime = 4b

function creativex2pitch(x) {
	dp = LeapMaxPitch - LeapMinPitch
	p = (LeapMinPitch + integer(dp * x))
	print("x2pitch x=",x," p=",p)
	return(p)
}

function creativenote1(sid,x,y,z) {
	nt = 'a'
	nt.pitch = creativex2pitch(x)
	nt.dur = 1b/16
	nt.chan = (16 * y) % 16
	nt.vol = (128 * z) % 128
	nt.time = Now
	# print("chan",nt.chan,"pitch",nt.pitch,"vol",nt.vol,"x",x,"y",y,"z",z)
	return(nt)
}

function creativenote2(sid,x,y,z) {
	nt = 'a'
	nt.pitch = creativex2pitch(x)
	nt.dur = 1b/8
	nt.chan = (16 * y) % 16
	nt.vol = (128 * z) % 128
	nt.time = nextquant(Now,1b/8)
	# print("chan",nt.chan,"pitch",nt.pitch,"vol",nt.vol,"x",x,"y",y,"z",z)
	return(nt)
}

function creativenote3(sid,x,y,z) {
	nt = 'a'
	nt.pitch = creativex2pitch(x)
	nt.dur = 1b/4
	nt.chan = 1
	nt.vol = (128 * z) % 128
	nt.time = nextquant(Now,1b/4)
	# print("chan",nt.chan,"pitch",nt.pitch,"vol",nt.vol,"x",x,"y",y,"z",z)
	return(nt)
}

function creativenote4(sid,x,y,z) {
	nt = 'a'
	nt.pitch = creativex2pitch(x)
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

function creativenote6(sid,x,y,z) {
	nt = 'a'
	nt.pitch = creativex2pitch(x)
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

function creativenote5(sid,x,y,z) {
	nt = creativenote4(sid,x,y,z)
	nt = scadjust(nt,LeapScale)
	return(nt)
}

function creativenote7(sid,x,y,z) {
	nt = creativenote4(sid,x,y,z)
	nt.chan = 10
	return(nt)
}

function creativenote8(sid,x,y,z) {
	nt = creativenote6(sid,x,y,z)
	nt.chan = 10
	nt.time = Now
	return(nt)
}

CreativeTask = -1
CreativeScale1 = 0

function creativeinit() {
	global CreativeScales
	global CreativeScale1
	CreativeScales = []
	CreativeScales1 = []
	# Scale 2 is the diminished
	CreativeScales[2] = 'p2,p5,p8,p11'
	CreativeScales[1] = 'p0,p4,p7,p9'

	CreativeScales1[0] = 'p0,p4,p7,p9'
	CreativeScales1[1] = 'p0,p3,p7,p9'
	CreativeScales1[2] = 'p0,p3,p6,p9'
	CreativeScales1[3] = 'p0,p4,p7,p10'
	CreativeScales1[4] = 'p0,p4,p6,p10'
}

function creativeswitcher() {
	print("creativeswitcher start")
	CreativeState = 1
	print("CreativeSwitch starts!")
	while ( 1 ) {
		sleeptill(Now+SwitchTime)
		if ( CreativeState == 1 ) {
			CreativeState = 2
		} else if ( CreativeState == 2 ) {
			CreativeState = 1
		}
		print("CreativeState = ",CreativeState)
	}
	print("CreativeSwitch ends!")
}

function creativenote(nt) {
	if ( rand(100) < Scale1Percent ) {
		printf(" 1.%d",CreativeScale1)
		nt = scadjust(nt,CreativeScales1[CreativeScale1])
	} else {
		printf(" 2")
		nt = scadjust(nt,CreativeScales[2])
	}
	# printf("=%d",nt.pitch)
	r = rand(3)
	nt.dur = CreativeDur

	# print("ROYNOTE=",nt)
	# if ( r == 0 ) {
	# 	nt.dur = CreativeDur
	# } else {
	# 	nt.dur = 2 * CreativeDur
	# }

	return(nt)
}

function creativenote9(sid,x,y,z) {

	nt = 'a'
	nt.pitch = creativex2pitch(x)
	nt.dur = 1b
	nt.chan = 1
	nt.vol = (128 * z) % 128

	nt = creativenote(nt)
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

function creative() {
	host = "127.0.0.1"
	port = 3333
	CreativeState = 2
	print("Hi from creative()")
	if ( CreativeTask > 0 ) {
		kill(CreativeTask)
	}
	print("INITIALIZING CreativeScales and Switcher")
	creativeinit()
	CreativeTask = -1
	# CreativeTask = task creativeswitcher()
	print("NO AUTO SWITCHER!")
	Merge = 0

	s = string(port)+"@"+host
	f = open(s,"rA","osc_listen")
	if ( f < 0 ) {
		print("Unable to open ",s)
		return()
	}
	t1 = task creativelisten(s,f)
	t2 = task creativechordlisten()
	notefuncs = [
		"1"=creativenote1,
		"2"=creativenote2,
		"3"=creativenote3,
		"4"=creativenote4,
		"5"=creativenote5,
		"6"=creativenote6,
		"7"=creativenote7,
		"8"=creativenote8,
		"9"=creativenote9
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
	kill(CreativeTask)
	close(f)
}

function creativechordlisten() {
	Midiin[$] = f = open()
	LeapChord = ''
	while ( 1 ) {
		nt = get(f)
		if ( nt.type != NOTEON ) {
			continue
		}
		nt.type = NOTE
		print("nt.pitch=",nt.pitch," lownote=",CreativeLowNote)
		if ( nt.pitch >= CreativeLowNote && nt.pitch <=CreativeHighNote ) {
			nt.pitch -= CreativeLowNote
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
				CreativeScale1 = 0
			} else if (nt.pitch == 6 ) {
				CreativeScale1 = 1
			} else if (nt.pitch == 7 ) {
				CreativeScale1 = 2
			} else if (nt.pitch == 8 ) {
				CreativeScale1 = 3
			} else if (nt.pitch == 9 ) {
				CreativeScale1 = 4

			} else if (nt.pitch == 10 ) {
				CreativeDur = 1b/2
			} else if (nt.pitch == 11 ) {
				CreativeDur = 1b*2

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
		nt = creativenote(nt)
		nt.time = nextquant(Now,CreativeFreq)
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

function creativelisten(s,f) {
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
			if ( dist > LeapDistThreshold && ((Now-LeapLast)>CreativeFreq) ) {
				# print("dist=",dist)
				nt = current_notefunc(sid,x,y,z)
				nt.chan = 1
				nt.vol = 100
				print("playing dist=",dist,"  z=",z,"  nt=",nt)
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
