#define xxx rereadlib();roy()

Map = []
LaunchMap = []

function royscaleinit() {

	global RoyScales
	global RoyScale1

	RoyScales2 = []
	RoyScales1 = []
	# Scale 2 is the diminished
	RoyScales2[0] = 'p2,p5,p8,p11'

	RoyScales1[0] = 'p0,p4,p7,p9'   # maj6
	RoyScales1[1] = 'p0,p3,p7,p9'   # min6
	RoyScales1[2] = 'p0,p3,p6,p9'   # dim
	RoyScales1[3] = 'p0,p4,p7,p10'  # dom7
	RoyScales1[4] = 'p0,p4,p6,p10'  # maj7b5

	RoyOctave = 4
	RoyScale1Choice = 0
	RoyScale2Choice = 0

	# This maps [row][col] to the offsets for the circle of fifths/fourths
	global Circle
	Circle = []
	Circle[4] = [0=0,1=7,2=2,3=9]
	Circle[5] = [0=5,1=99,2=99,3=4]
	Circle[6] = [0=10,1=99,2=99,3=11]
	Circle[7] = [0=3,1=8,2=1,3=6]

	# Notes with these pitches adjust circleoffset
	Adjustments = [8=5,24=-5]
}

function setmap1() {
	print("SET MAP Scale1Choice=",RoyScale1Choice," Scale2Choice=",RoyScale2Choice," CircleOffset=",RoyCircleOffset," Octave=",RoyOctave)
	row = 0  # just row 0 for how
	scale1 = RoyScales1[RoyScale1Choice]
	scale2 = RoyScales2[RoyScale2Choice]

	scale1.pitch += RoyCircleOffset
	scale2.pitch += RoyCircleOffset

	map = []
	map[0] = (scale1%1).pitch % 12
	map[1] = (scale1%2).pitch % 12
	map[2] = (scale1%3).pitch % 12
	map[3] = (scale1%4).pitch % 12

	map2 = []
	map2[0] = (scale2%1).pitch % 12
	map2[1] = (scale2%2).pitch % 12
	map2[2] = (scale2%3).pitch % 12
	map2[3] = (scale2%4).pitch % 12

	# Find the closest note in the scale1 to 0
	minval = 99
	mincol = 99
	for ( c=0; c<4; c++ ) {
		v = map[c]
		v = v % 12
		if ( v < minval ) {
			minval = v
			mincol = c
		}
	}
	# print("mincol=",mincol," minval=",minval," map=",map)
	# shift the maps down so that the mincol is at col 0
	for ( tmp=0; tmp<mincol; tmp++ ) {

		t = map[0]
		map[0] = map[1]
		map[1] = map[2]
		map[2] = map[3]
		map[3] = t

		t = map2[0]
		map2[0] = map2[1]
		map2[1] = map2[2]
		map2[2] = map2[3]
		map2[3] = t
	}
	# Make sure all the notes are above the first one
	for ( t=1; t<4; t++ ) {
		if ( map2[t] <= map2[0] ) {
			map2[t] += 12
		}
	}
	# print("after shift map=",map)
	# print("after shift map2=",map2)

	Map[0] = []
	Map[0][0] = map[0]
	Map[0][1] = map[1]
	Map[0][2] = map[2]
	Map[0][3] = map[3]
	Map[0][4] = 12 + map[0]
	Map[0][5] = 12 + map[1]
	Map[0][6] = 12 + map[2]
	Map[0][7] = 12 + map[3]

	Map[1] = []
	Map[1][0] = map2[0]
	Map[1][1] = map2[1]
	Map[1][2] = map2[2]
	Map[1][3] = map2[3]
	Map[1][4] = 12 + map2[0]
	Map[1][5] = 12 + map2[1]
	Map[1][6] = 12 + map2[2]
	Map[1][7] = 12 + map2[3]

	for ( row=0; row<2; row++ ) {
		for ( col in Map[row] ) {
			Map[row][col] += RoyOctave * 12
		}
	}
}

function oldsetmap2() {
	row = 1
	RoyScale2Choice = 0
	scale = RoyScales2[RoyScale2Choice]
	p0 = RoyOctave * 12
	Map[row] = []
	Map[row][0] = p0 + scale%1
	Map[row][1] = p0 + scale%2
	Map[row][2] = p0 + scale%3
	Map[row][3] = p0 + scale%4
	Map[row][4] = 12 + p0 + scale%1
	Map[row][5] = 12 + p0 + scale%2
	Map[row][6] = 12 + p0 + scale%3
	Map[row][7] = 12 + p0 + scale%4
}

function roy() {

	oldMerge = Merge
	Merge = 0
	realtime(ano())

	royscaleinit()

	# spawn the task that will monitor midi input
	# looking for middle C 
	t = task roylook()
	
	rowstart = [0=112,1=96,2=80,3=64,4=48,5=32,6=16,7=0]
	for ( row=0; row<8; row++ ) {
		p0 = rowstart[row]
		for ( col=0; col<8; col++) {
			LaunchMap[p0+col] = ["row"=row,"col"=col]
		}
	}

	RoyCircleOffset = 0
	setmap1()
	# setmap2()

	# that task is now going on in parallel with this one.
	# So we just sleep for 10 seconds and then kill the task.
        Root.waitforconsolekey()

	kill(t)
	Merge = oldMerge
}

function adjustcircle(dp) {
	RoyCircleOffset += dp
	if ( RoyCircleOffset < 0 ) {
		RoyCircleOffset += 12
	}
	RoyCircleOffset = RoyCircleOffset % 12
	setmap1()
}

function adjustoctave(dp) {
	RoyOctave = RoyOctave + dp
	if ( RoyOctave < 2 )
		RoyOctave = 2
	else if ( RoyOctave > 8 )
		RoyOctave = 8
	setmap1()
}

function roylook(p1,n1) {
	
	# Arrange for fifo f to get a copy of Midi input,
	# and make sure it's cleaned up when this task 
	# gets killed.

	Midiin[$] = f = open()
	onexit(closemidi,$)

	# Remember, the messages we're going to get
	# here include both note-ons and note-offs.

	print("Ready...")
	while ( (m=get(f)) != Eof ) {
		if ( m.type == NOTEON || m.type == NOTEOFF ) {
			# print("m=",m," pitch=",m.pitch)
			if ( m.pitch in Adjustments ) {
				if ( m.type == NOTEON ) {
					adjustcircle(Adjustments[m.pitch])
				}
				continue
			}
			if ( ! ( m.pitch in LaunchMap) ) {
				print("pitch=",m.pitch," not in LaunchMap")
				continue
			}
			# print("LaunchMap = ",LaunchMap[m.pitch])
			row = LaunchMap[m.pitch]["row"]
			col = LaunchMap[m.pitch]["col"]
			# print("m.pitch=",m.pitch," row=",row," col=",col)
			if ( row in Map ) {
				p = Map[row][col]
				# print("   Map = ",p)
				m.pitch = p
				m.time = 0
				# print("Playing m=",m)
				realtime(m)
				continue
			}
			if ( m.type == NOTEOFF ) {
				continue
			}
			if ( (row in Circle) && (col in Circle[row]) ) {
				offset = Circle[row][col]
				# find the closest note above 0 
				cnt = makenote(offset)
				# print("CIRCLE! offset = ",offset," nt=",cnt)
				RoyCircleOffset = offset
				setmap1()
			} else {
				print("Nothing in row=",row," col=",col)
			}
		} else if ( m.type == CONTROLLER ) {
			v1 = 0 + subbytes(m,2,1)
			v2 = 0 + subbytes(m,3,1)
			if ( v2 == 0 ) {
				continue
			}
			if ( v1 == 110 ) {
				adjustoctave(-1)
			} else if ( v1 == 111 ) {
				adjustoctave(1)
			} else if ( v1 >= 104 && v1 <= 108 ) {
				RoyScale1Choice = v1 - 104
				setmap1()
			} else {
				print("Unrecognized controller = ",v1)
			}
		} else {
			print("NONNOTE m=",m)
		}
	}
}
