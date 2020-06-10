#   PAD LABELS
#
#          	Select 			Start
#
#      Rotate Turret		Fire            Rotate Turret
#	  Turret				  Turret
#      CounterClockwise         Red              Clockwise
#
#            Fire                                  Fire
#	     Blue                                  Green
#
#           Rotate				Rotate
#       Move Direction      Move             Move Direction
#      CounterClockwise                        Clockwise
#
#
#   Commands
#
#	ESCAPE  	- quit
#	space   	- toggle on/off
#	\r or \n	- redraw
#	v		- verbose (toggle)
#
#	r	- Rhythm on
#	R	- Rhythm off
#
#	c	- switch mouse color
#	C	- Clear all balls
#
#	p	- Random Patch
#	P	- Reset Patch
#
#	q	- quantize more
#	Q	- quantize less
#
#	0	- Walls = keyset
#	1-9	- Walls = file 1-9
#
#	a	- All notes off
#	A	- All notes more off 
#
#	w	- Rand Walls Down
#	W	- All Walls Up
#
#	o	- octave down
#	O	- octave up
#
#	t	- More Threads
#	T	- Fewer Threads
#
#	n	- More Notes
#	N	- Fewer Notes
#
#	d	- Decay More
#	D	- Decay Less
#
#	b	- More Balls
#	B	- Fewer Balls
#
#	e	- Less Energy
#	E	- More Energy
#
#	m	- Move Slower
#	M	- More Faster
#
#	s	- Tempo Slower
#	S	- Tempo Faster


class wbouncing {

method init {

	$.w = new window()
	$.inherit($.w)

	$.d2r = 2.0*3.14159265358979323846/360.0
	$.oldmerge = Merge
	Merge = 0

	$.linecolor = 1
	$.joycolor = [0=9,1=8,2=10,3=1]
	$.joycl = [0="r",1="g",2="b",3="r"]
	$.joytype = 1	# 	0 is dance pad, 1 is driving wheel

	$.playbreakdown = 1

	$.joy = getjoymonitor()
	$.joyinit = 0
	$.njoy = 0
	$.buttonstate = []

	$.keyset = [0='c',1='d',2='e-',3='f',4='g',5='a',6='b-',7='c']
	$.keysetsize = sizeof($.keyset)
	$.keysetpos = 0
	$.doresetkeyset = 0

	# Figure Remember what ports each channel goes to
	$.defouts = midi("portmap")[0]

	$.tid = -1

	$.butt2color = ["UP"="r","LEFT"="b","RIGHT"="g",
			"L1"="b","R1"="r","R2"="r","L2"="g"]
	$.fmax = 1000000.0
	$.fmove = $.fmax / 100
	$.lastkeysetgrab = milliclock()

	$.octave = 0
	$.lengthen = 1
	$.intermittent = 1

	$.verbose = 0
	$.exactfit = 0

	$.currentcolor = "r"
	$.maxballspercolor = 16
	$.editing = 0
	$.joystate = ["ANALOGX"=0, "ANALOGY"=0, "ANALOGR"=0, "ANALOGZ"=0]
	$.selectdown = 0
	$.startdown = 0
	$.shiftdown = 0
	$.breakout = 0
	$.desc1 = ""
	$.debugmove=0
	$.randomadd = 1
	$.mapon = 0
	$.lockballson = 0

	$.laststart = Now

	$.loopplaying = [0=0,1=0,2=0,3=0]

	# Define JoyBallsFiles in keylocal.k if you want
	if ( defined(JoyBallsFiles) ) {
		$.filenames = JoyBallsFiles
	} else {
		$.filenames = [
			0="jsbach.mid",
			1="prelude.mid",
			2="bachinv1.mid",
			3="bachinv2.mid",
			4="..\\music\\state.mid",
			5="..\\music\\stkans1.mid",
			6="..\\music\\twinkle.mid",
			7="..\\music\\stkans3.mid",
			8="..\\music\\shamelss.mid"
		]
	}
	$.nfiles = sizeof($.filenames)
	$.filenum = 0

	$.colorchan = [
			"r"= ["top"=5,"right"=6,"bottom"=7,"left"=8],
			"g"= ["top"=1,"right"=2,"bottom"=3,"left"=4],
			"b"= ["top"=11,"right"=12,"bottom"=13,"left"=14]
			]

	$.colorindex = ["r"=8,"g"=9,"b"=10]
	$.colorbuttpressed = []
	$.colordur = ["r"=1.0,"g"=1.0,"b"=1.0]
	$.defaultvol = 90
	$.colorvol = ["r"=$.defaultvol,"g"=$.defaultvol,"b"=$.defaultvol]

	$.editdobuttons = ["UP"=1,"DOWN"=-1,"LEFT"=-2,"RIGHT"=2]
	$.offset = 0
	$.debug = 0

	colormix(8,255*255,0,0)
	colormix(9,0,255*255,0)
	colormix(10,0,0,255*255)
	colormix(11,0,0,0)

	$.grid = $0

	$.basevelocity = 0
	$.topvelocity = 127

	$.decaydefault = 3   # infinite decay, 30 was the default previously
	$.decaymin = 3

	$.decaymax = 1000
	$.velocitydefault = 500
	$.energydefault = 500
	$.energymin = 50
	$.energymax = 5000
	$.dsmall = 0.024
	$.slidermax = 1000

	$.maxe =       1000000
	$.einit =        60000
	$.einc =         60000
	$.edec =         60000
	$.edecaymax =     4000

	$.maxmove =  300
	$.key = 'c'
	$.scale = "aeolian"
	$.startquant = 1b
	$.playquant = 1b/4
	$.wallredrawdelay = 1b/4

	$.movemilli = 20
	$.fdfactor = 13333.0 * ($.movemilli/40.0)	# amount to multiply dx/dy things by

	$.colorlimit = []
	$.playlimit = 4

	$.colordecay = []
	$.colorvelocity = []
	$.colorenergy = []
	for ( cl in $.colorindex ) {
		$.colordecay[cl] = $.decaydefault
		$.colorvelocity[cl] = $.velocitydefault
		$.colorenergy[cl] = $.energydefault
		$.colorlimit[cl] = 2
	}
	$.ntids = 2
	$.tids = []
	$.nexttid = -1

	$.setgridsize(16,0)

	if ( defined(JoyBallsNotes) ) {
		$.nnotes = JoyBallsNotes
	} else {
		$.nnotes = 1
	}
	$.resetfilenotes()
	$.resetkeyset()
	$.filenum = 0

	$.joyonoff(1)
	# $.joybutt.set(1)

	$.consf = Root.grabconsole()
	Consecho = 0
	$.constid = task $.constask($.consf)

	$.onoff(1)

	realtime(ano())
	$.patchreset()

	$.gbag = new wgrabbag()
	$.gbag.setbsgmdrum8()
	$.gbag.forcewalking(0)
}

method resetall() {
	print("RESETALL")
	$.ntids = 2
	$.octave = 0
	$.lengthen = 1
	$.intermittent = 1
	$.nnotes = 1
	$.resetfilenotes()
	$.ballmovethrottle = 0
	$.ballmovecount = 0
	t = 500000
	$.changetempo(t)
}

method currentcolorswitch() {
	if ( $.currentcolor == "r" )
		$.currentcolor = "g"
	else if ( $.currentcolor == "g" )
		$.currentcolor = "b"
	else
		$.currentcolor = "r"
	print("CURRENT COLOR is now ",$.currentcolor)
}
method resetfilenotes() {
	for ( n=0; n<$.nfiles; n++ ) {
		$.filenum = n+1
		$.setfromfile($.filenames[n],$.nnotes)
	}
}

method resetkeyset() {
	$.filenum = 0
	sz = sizeof($.keyset)
	p = ''
	for ( n=0; n<sz; n++ ) {
		p += $.keyset[n]
	}
	$.setfromphrase(p,1)
}

method shutdown(tm) {
	sleeptill(tm)
	Root.deletetool($)
}
method constask(f) {
	while ( (c=get(f)) != Eof ) {
		if ( c == ascii(27) ) {
			# ESCAPE quits
			task $.shutdown(Now+1b)
			return()
		} else if ( c == " " ) {
			$.toggleonoff()
			$.redraw()
		} else if ( c == "\r" || c == "\n" ) {
			$.redraw()
		} else if ( c == "r" ) {
			$.gbag.forcewalking(1)
		} else if ( c == "R" ) {
			$.gbag.forcewalking(0)
			$.gbag.stopplaying()
		} else if ( c == "v" ) {
			$.verbose = 1 - $.verbose
		} else if ( c == "c" ) {
			$.currentcolorswitch()
		} else if ( c == "C" ) {
			$.clear()
		} else if ( c == "u" ) {
			$.resetall()
		} else if ( c == "p" ) {
			$.patchrandom()
		} else if ( c == "P" ) {
			$.patchreset()
		} else if ( c == "q" ) {
			if ( $.playquant > 1b/16 )
				$.playquant /= 2
			print("QUANT is now ",$.playquant)
		} else if ( c == "Q" ) {
			$.playquant *= 2
			print("QUANT is now ",$.playquant)
		} else if ( c == "0" ) { $.setfile(0)
		} else if ( c == "1" ) { $.setfile(1)
		} else if ( c == "2" ) { $.setfile(2)
		} else if ( c == "3" ) { $.setfile(3)
		} else if ( c == "4" ) { $.setfile(4)
		} else if ( c == "5" ) { $.setfile(5)
		} else if ( c == "6" ) { $.setfile(6)
		} else if ( c == "7" ) { $.setfile(7)
		} else if ( c == "8" ) { $.setfile(8)
		} else if ( c == "9" ) { $.setfile(9)
		} else if ( c == "a" ) {
			print("Allnotesoff!")
			realtime(ano())
		} else if ( c == "A" ) {
			print("ALLNOTESOFF!")
			realtime(anoall())
		} else if ( c == "w" ) {
			$.randwallsdown()
		} else if ( c == "W" ) {
			$.allwallsup(1)
		} else if ( c == "o" ) {
			if ( $.octave > -3 )
				$.octave--
			print("OCTAVE = ",$.octave)
		} else if ( c == "O" ) {
			if ( $.octave < 3 )
				$.octave++
			print("OCTAVE = ",$.octave)
		} else if ( c == "t" ) {
			if ( $.ntids < 10 )
				$.ntids++
			print("THREADS = ",$.ntids)
		} else if ( c == "T" ) {
			if ( $.ntids > 1 )
				$.ntids--
			print("THREADS = ",$.ntids)
		} else if ( c == "N" ) {
			if ( $.nnotes > 1 ) {
				$.nnotes--
				$.resetfilenotes()
			}
			print("NNOTES is ",$.nnotes)
		} else if ( c == "n" ) {
			$.nnotes++
			$.resetfilenotes()
			print("NNOTES is ",$.nnotes)
		} else if ( c == "l" ) {
			if ( $.lengthen < 6 )
				$.lengthen++
			print("LENGTHEN is ",$.lengthen)
		} else if ( c == "L" ) {
			if ( $.lengthen > 1 )
				$.lengthen--
			print("LENGTHEN is ",$.lengthen)
		} else if ( c == "i" ) {
			$.intermittent++
			print("INTERMITTENT is ",$.intermittent)
		} else if ( c == "I" ) {
			if ( $.intermittent > 1 )
				$.intermittent--
			print("INTERMITTENT is ",$.intermittent)
		} else if ( c == "d" ) {
			for ( cl in $.colorindex ) {
				$.colordecay[cl] *= 1.5
				if ( cl == "r" )
					print("DECAY = ",$.colordecay[cl])
			}
		} else if ( c == "D" ) {
			for ( cl in $.colorindex ) {
				$.colordecay[cl] /= 1.5
				if ( $.colordecay[cl] < ($.decaymin) ) {
					$.colordecay[cl] = $.decaymin
				}
				if ( cl == "r" )
					print("DECAY = ",$.colordecay[cl])
			}
		} else if ( c == "B" ) {
			# fewer balls
			lock($)
			for ( cl in $.colorindex ) {
				if ( $.colorlimit[cl] > 1 ) {
					maxn = -1
					for ( n in $.ball[cl] ) {
						if ($.ball[cl][n]["on"]) {
							if ( maxn < n )
								maxn = n
						}
					}
					if ( maxn >= 0 ) {
						$.deleteball(cl,0)
					}
					$.colorlimit[cl]--
				}
				if ( cl == "r" ) {
					print("BALLS = ",$.colorlimit[cl])
				}
			}
			unlock($)
		} else if ( c == "b" ) {
			# more balls
			lock($)
			for ( cl in $.colorindex ) {
				if ( $.colorlimit[cl] < ($.maxballspercolor-1) )
					$.colorlimit[cl]++
				if ( cl == "r" )
					print("BALLS = ",$.colorlimit[cl])
			}
			unlock($)
		} else if ( c == "E" ) {
			# more energy
			$.energydefault /= 1.5
			if ( $.energydefault < $.energymin )
				$.energydefault = $.energymin
			print("energydefault = ",$.energydefault)
		} else if ( c == "e" ) {
			# less energy
			$.energydefault *= 1.5
			if ( $.energydefault > $.energymax )
				$.energydefault = $.energymax
			print("energydefault = ",$.energydefault)
		} else if ( c == "m" ) {
			$.ballmovethrottle++
			print("MOVETHROTTLE = ",$.ballmovethrottle)
		} else if ( c == "M" ) {
			if ( $.ballmovethrottle > 0 )
				$.ballmovethrottle--
			print("MOVETHROTTLE = ",$.ballmovethrottle)
		} else if ( c == "s" ) {
			# slow
			t = tempo()*1.2
			$.changetempo(t)
		} else if ( c == "S" ) {
			# faster
			t = tempo()/1.2
			if ( t > 10000 )
				$.changetempo(t)
		} else {
			print("Unrecognized char: ",c)
		}
	}
}
method patchreset() {
	print("PATCH RESET")
	realtime(progchange(18,1))
	realtime(progchange(38,2))
	realtime(progchange(71,3))
	realtime(progchange(76,4))

	realtime(progchange(2,5))
	realtime(progchange(3,6))
	realtime(progchange(4,7))
	realtime(progchange(5,8))

	realtime(progchange(93,11))
	realtime(progchange(86,12))
	realtime(progchange(88,13))
	realtime(progchange(80,14))
}
method patchrandom() {
	print("PATCH RANDOM")
	realtime(progchange(1+rand(128),1))
	realtime(progchange(1+rand(128),2))
	realtime(progchange(1+rand(128),3))
	realtime(progchange(1+rand(128),4))

	realtime(progchange(1+rand(64),5))
	realtime(progchange(1+rand(64),6))
	realtime(progchange(1+rand(64),7))
	realtime(progchange(1+rand(64),8))

	realtime(progchange(1+rand(128),11))
	realtime(progchange(1+rand(128),12))
	realtime(progchange(1+rand(128),13))
	realtime(progchange(1+rand(128),14))
}
method changetempo(t) {
	if ( t > 2000000 )
		t = 2000000
	if ( t < 20000 )
		t = 20000
	tempo(t)
	bpm = round(60 / (t / 1000000.0))
	print("Tempo is now ",bpm," BPM,  t=",t)
}

method dump() {
	return( [
		"colorlimit" = $.colorlimit,
		"colordecay" = $.colordecay,
		"colorvelocity" = $.colorvelocity,
		"colorenergy" = $.colorenergy,
		"sidetop" = $.sidetop,
		"sidebottom" = $.sidebottom,
		"sideleft" = $.sideleft,
		"sideright" = $.sideright,
		"wallbottom" = $.wallbottom,
		"wallright" = $.wallright,
		"filenum" = $.filenum,
		"mapon" = $.mapon,
		"joyon" = $.joyon,
		"ball" = $.ball
	] )
}
method restore(st) {
	$.mapon = st["mapon"]
	$.joyon = st["joyon"]

	$.colorlimit = arraycopy(st["colorlimit"])
	$.colordecay = arraycopy(st["colordecay"])
	$.colorvelocity = arraycopy(st["colorvelocity"])
	$.colorenergy = arraycopy(st["colorenergy"])

	$.sidetop = arraycopy(st["sidetop"])
	$.sidebottom = arraycopy(st["sidebottom"])
	$.sideleft = arraycopy(st["sideleft"])
	$.sideright = arraycopy(st["sideright"])
	$.wallbottom = arraycopy(st["wallbottom"])
	$.wallright = arraycopy(st["wallright"])
	$.ball = arraycopy(st["ball"])

	$.joyonoff($.joyon)
}

method setgridsize(v,doredraw) {
	$.nrows = v
	$.ncols = v
	if ( $.grid != $0 ) {
		$.removechild($.grid)
	}
	deleteobject($.grid)
	$.grid = new wgrid($.ncols,$.nrows)
	$.grid.setlinecolor($.linecolor)
	$.addchild($.grid)

	$.grid.setcallbackdown($,"gotdown")
	$.grid.setcallbackdrag($,"gotdrag")
	$.initballs()
	$.setscale($.key,$.scale)

	if ( doredraw ) {
		$.resize()
		$.redraw()
	}


}

method initballs {
	$.ball = []
	for ( cl in $.colorindex ) {
		$.ball[cl] = []
		for ( n=0; n<$.maxballspercolor; n++ ) {
			$.ball[cl][n] = []
			$.ball[cl][n]["on"] = 0
			$.ball[cl][n]["row"] = -1
			$.ball[cl][n]["col"] = -1
			$.ball[cl][n]["fx"] = -1.0
			$.ball[cl][n]["fy"] = -1.0
			$.ball[cl][n]["dfx"] = 0.0	# from -1 to 1
			$.ball[cl][n]["dfy"] = 0.0	# from -1 to 1
		}
	}
	$.sidetop = []
	$.sidebottom = []
	$.sideleft = []
	$.sideright = []
	$.wallbottom = []
	$.wallright = []

	for ( r=0; r<$.nrows; r++ ) {
		$.sidetop[r] = []
		$.sidebottom[r] = []
		$.sideleft[r] = []
		$.sideright[r] = []
		$.wallbottom[r] = []
		$.wallright[r] = []
		for ( c=0; c<$.ncols; c++ ) {
			$.sidetop[r][c] = []
			$.sidebottom[r][c] = []
			$.sideleft[r][c] = []
			$.sideright[r][c] = []
			$.wallbottom[r][c] = 1
			$.wallright[r][c] = 1
			for ( f=0; f<($.nfiles+1); f++ ) {
				$.sidetop[r][c][f] = ''
				$.sidebottom[r][c][f] = ''
				$.sideleft[r][c][f] = ''
				$.sideright[r][c][f] = ''
			}
		}
	}
	$.allwallsup(0)
}
method allwallsup(doredraw) {
	if ( nargs() < 1 )
		doredraw = 1
	for ( r=0; r<$.nrows; r++ ) {
		for ( c=0; c<$.ncols; c++ ) {
			$.wallbottom[r][c] = 1
			$.wallright[r][c] = 1
		}
	}
	if ( doredraw )
		$.redraw()
}
method randwallsdown(doredraw) {
	if ( nargs() < 1 )
		doredraw = 1
	for ( r=0; r<($.nrows-1); r++ ) {
		for ( c=0; c<$.ncols; c++ ) {
			if ( $.wallbottom[r][c] && (rand(8)==0) ) {
				$.wallbottom[r][c] = 0
			}
		}
	}
	for ( r=0; r<$.nrows; r++ ) {
		for ( c=0; c<($.ncols-1); c++ ) {
			if ( $.wallright[r][c] && (rand(8)==0) ) {
				$.wallright[r][c] = 0
			}
		}
	}
	if ( doredraw )
		$.redraw()
}
method erasewalls {
	$.grid.setlinecolor(0)
	for ( r=0; r<$.nrows; r++ ) {
		for ( c=0; c<$.ncols; c++ ) {
			if ( $.wallright[r][c] == 0 ) {
				$.grid.drawwallright(r,c,STORE)
			}
			if ( $.wallbottom[r][c] == 0 ) {
				$.grid.drawwallbottom(r,c,STORE)
			}
		}
	}
	$.grid.setlinecolor($.linecolor)
}
method ballxy(arr,bx,by) {
	x0 = arr["x0"]
	y0 = arr["y0"]
	x1 = arr["x1"]
	y1 = arr["y1"]
	bx0 = x0 + 1 + (x1-x0-2)*bx/($.fmax/$.ncols)
	by0 = y0 + 1 + (y1-y0-2)*by/($.fmax/$.nrows)
	return( xy(bx0-1,by0-1,bx0+1,by0+1) )
}
method playit(p,cl,side) {
	if ( typeof(p) != "phrase") {
		print("Hey, playit given non-phrase? = ",p)
		return()
	}
	p.chan = $.colorchan[cl][side]

	# print("cl=",cl," side=",side," chan=",p.chan)

	p.vol = $.basevelocity + ($.topvelocity - $.basevelocity) * $.colorvelocity[cl] / $.slidermax
	p.pitch += $.offset
	p.dur *= $.colordur[cl]
	if ( $.mapon ) {
		sc = maptoscale(Mapto,Key)
		p = scadjust(p,sc)
	}
	if ( $.verbose )
		print("playit, filenum=",$.filenum," p=",p)

	tm = nextquant(Now,$.playquant)
	if ( $.nexttid in $.tids ) {
		t = $.tids[$.nexttid]
		kill(t)
	} else if ( $.nexttid < 0 ) {
		$.nexttid = 0
	}
	if ( $.octave != 0 ) {
		o = $.octave
		while ( o > 0 ) {
			o--
			p.pitch += 12
		}
		while ( o < 0 ) {
			++o
			p.pitch -= 12
		}
	}
	if ( $.lengthen > 1 ) {
		r = ''
		for ( nt in p ) {
			if ( rand(7-$.lengthen) == 0 ) {
				nt.dur *= (2*$.lengthen)
			}
			r |= nt
		}
		p = r
	}
	if ( $.intermittent > 1 ) {
		p = p{rand($.intermittent)==0}
	}
	$.tids[$.nexttid] = realtime(p,tm)
	$.nexttid++
	if ( $.nexttid >= $.ntids ) {
		$.nexttid = 0
	}
}
method playhit(side,r,c,cl) {
	if ( side == "left" ) {
		p = $.sideleft[r][c][$.filenum]
	} else if ( side == "right" ) {
		p = $.sideright[r][c][$.filenum]
	} else if ( side == "top" ) {
		p = $.sidetop[r][c][$.filenum]
	} else if ( side == "bottom" ) {
		p = $.sidebottom[r][c][$.filenum]
	} else {
		print("Hey, playhit called with bad side=",side)
		return()
	}
	if ( ($.filenum == 0) && (Current != '') && (milliclock()-$.lastkeysetgrab) > 500 ) {
		$.lastkeysetgrab = milliclock()
		p = Current
		p.time = 0
		p.dur = 1b
		p.type = NOTE
		print("Grabbing ",p)
		p.length = 1b/4
		$.keyset[$.keysetpos++] = p
		if ( $.keysetpos >= $.keysetsize )
			$.keysetpos = 0
		if ( $.verbose )
			print("keyset is now ",$.keyset)
		$.doresetkeyset = 1
	}
	$.playit(p,cl,side)

}
method hitleft(r,c,cl) {
	$.playhit("left",r,c,cl)
	# $.playit($.sideleft[r][c][$.filenum],cl,"left")
	if ( $.breakout && c > 0 ) {
		if ( r < 0 || r >= $.nrows )
			print("Unexpected r in hitleft")
		$.breakdownleft(r,c)
	}
}
method breakdownleft(r,c) {
	if ( c <= 0 ) {
		print("breakdownleft c=",c)
		return()
	}
	$.wallright[r][c-1] = 0
	$.grid.setlinecolor(0)
	$.grid.drawwallright(r,c-1,STORE)
	$.grid.setlinecolor($.linecolor)
}
method hitright(r,c,cl) {
	$.playhit("right",r,c,cl)
	# $.playit($.sideright[r][c][$.filenum],cl,"right")
	if ( $.breakout && c < ($.nrows-1) ) {
		$.breakdownright(r,c)
	}
}
method breakdownright(r,c) {
	$.wallright[r][c] = 0
	$.grid.setlinecolor(0)
	$.grid.drawwallright(r,c,STORE)
	$.grid.setlinecolor($.linecolor)
}
method hittop(r,c,cl,dbg) {
	$.playhit("top",r,c,cl)
	# $.playit($.sidetop[r][c][$.filenum],cl,"top")
	if ( $.breakout && r > 0 ) {
		$.breakdowntop(r,c)
	}
}
method breakdowntop(r,c) {
	if ( r <= 0 ) {
		print("breakdowntop r=",r)
		return()
	}
	wb = $.wallbottom[r-1]
	if ( typeof(wb) != "array" ) {
		print("Hmm, wallbottom r-1=",(r-1)," isn't an array?  It's ",typeof(wb))
		return()
	}
	$.wallbottom[r-1][c] = 0
	$.grid.setlinecolor(0)
	$.grid.drawwallbottom(r-1,c,STORE)
	$.grid.setlinecolor($.linecolor)
}
method hitbottom(r,c,cl) {
	$.playhit("bottom",r,c,cl)
	# $.playit($.sidebottom[r][c][$.filenum],cl,"bottom")
	if ( $.breakout && r < ($.nrows-1) ) {
		$.breakdownbottom(r,c)
	}
}
method breakdownbottom(r,c) {
	$.wallbottom[r][c] = 0
	$.grid.setlinecolor(0)
	$.grid.drawwallbottom(r,c,STORE)
	$.grid.setlinecolor($.linecolor)
}
method dofire(j,nm) {

	# print("dofire, nm=",nm)

	jfxy = $.joypos[j]
	# jxy = $.fxy2xy(jfxy["x"],jfxy["y"])

	$.addball($.butt2color[nm],jfxy["x"],jfxy["y"],$.joyturret[j])
}
method domove(j,forward) {

	lock($)

	jfxy = $.joypos[j]

	jxy = $.fxy2xy(jfxy["x"],jfxy["y"])
	oldrc = $.grid.rxy2rc(jxy,0)
	r = oldrc["row"]
	c = oldrc["col"]

	if ( forward < 0 ) {
		movedir = $.joymovedir[j]
	}
	else {
		movedir = 180.0 + $.joymovedir[j]
		if ( movedir > 360.0 )
			movedir -= 360.0
	}
	nfx = jfxy["x"] + $.fmove * cos($.d2r*movedir)
	nfy = jfxy["y"] + $.fmove * sin($.d2r*movedir)

	njxy = $.fxy2xy(nfx,nfy)
	newrc = $.grid.rxy2rc(njxy,0)
	newrow = newrc["row"]
	newcol = newrc["col"]
	
	if ( newrow < 0 || newcol < 0 || newrow >= $.nrows || newcol >= $.ncols) {
		unlock($)
		return()
	}

	colorset(0)
	$.drawjoy(j,STORE)
	jfxy["x"] = nfx
	jfxy["y"] = nfy

	colorset($.joycolor[j])
	$.drawjoy(j,STORE)

	bouncetype = ""
	if ( (r != newrow || c != newcol) ) {
		if (r!=newrow && c!=newcol)
			iscorner = 1
		else
			iscorner = 0

		bouncedy = 0
		bouncedx = 0
		redrawbottomr = -2
		redrawbottomc = -2
		redrawrightr = -2
		redrawrightc = -2

		# Special cases for corners
		if ( iscorner ) {
			# print("ISCORNER");
			if ( newrow < r && newcol < c ) {
				# upper-left
				horiz = ($.hastop(r,c) && $.hastop(r,c-1) && !$.hasright(r,c-1))
				vert = ($.hasright(r,c-1) && $.hasright(r-1,c-1) && !$.hastop(r,c))
				corn1 = ($.hastop(r,c) && $.hasright(r,c-1))
				corn2 = ($.hasright(r-1,c-1) && $.hastop(r,c-1))
				if ( horiz ) {
					bouncetype = "top"
				} else if ( vert ) {
					bouncetype = "left"
				} else if ( corn1 || corn2 ) {
					$.breakdowntop(r,c)
					bouncedy = 1
					bouncedx = 1
					redrawbottomr = r-1
					redrawbottomc = c
					redrawrightr = r
					redrawrightc = c-1
				}
			} else if ( newrow > r && newcol < c ) {
				# lower-left
				horiz = ($.hastop(r+1,c) && $.hastop(r+1,c-1) && !$.hasright(r,c-1))
				vert = ($.hasright(r,c-1) && $.hasright(r+1,c-1) && !$.hastop(r+1,c))
				corn1 = ($.hastop(r+1,c) && $.hasright(r,c-1))
				corn2 = ($.hasright(r+1,c-1) && $.hastop(r+1,c-1))
				if ( horiz ) {
					bouncetype = "bottom"
				} else if ( vert ) {
					bouncetype = "left"
				} else if ( corn1 || corn2 ) {
					$.breakdownbottom(r,c)
					bouncedy = 1
					bouncedx = 1
					redrawbottomr = r
					redrawbottomc = c
					redrawrightr = r
					redrawrightc = c-1
				}
			} else if ( newrow < r && newcol > c ) {
				# upper-right
				horiz = ($.hastop(r,c) && $.hastop(r,c+1) && !$.hasright(r,c))
				vert = ($.hasright(r,c) && $.hasright(r-1,c) && !$.hastop(r,c))
				corn1 = ($.hastop(r,c) && $.hasright(r,c))
				corn2 = ($.hasright(r-1,c) && $.hastop(r,c+1))
				if ( horiz ) {
					bouncetype = "top"
				} else if ( vert ) {
					bouncetype = "right"
				} else if ( corn1 || corn2 ) {
					$.breakdowntop(r,c)
					bouncedy = 1
					bouncedx = 1
					redrawbottomr = r-1
					redrawbottomc = c
					redrawrightr = r
					redrawrightc = c
				}
			} else if ( newrow > r && newcol > c ) {
				# lower-right
				horiz = ($.hastop(r+1,c) && $.hastop(r+1,c+1) && !$.hasright(r,c))
				vert = ($.hasright(r,c) && $.hasright(r+1,c) && !$.hastop(r+1,c))
				corn1 = ($.hastop(r+1,c) && $.hasright(r,c))
				corn2 = ($.hasright(r+1,c) && $.hastop(r+1,c+1))
				if ( horiz ) {
					bouncetype = "bottom"
				} else if ( vert ) {
					bouncetype = "right"
				} else if ( corn1 || corn2 ) {
					$.breakdowntop(r,c)
					bouncedy = 1
					bouncedx = 1
					redrawbottomr = r
					redrawbottomc = c
					redrawrightr = r
					redrawrightc = c
				}
			}
		}

		if ( bouncetype == "" ) {
			# NORMAL bounce, off one side 
			if ( newrow < r ) {
				# potential bounce off top
				if ( $.hastop(r,c) ) {
					bouncetype = "top"
				}
			} else if ( newrow > r ) {
				# potential bounce off bottom
				if ( $.hasbottom(r,c) ) {
					bouncetype = "bottom"
				}
			} else if ( newcol < c ) {
				# potential bounce off left
				if ( $.hasleft(r,c) ) {
					bouncetype = "left"
				}
			} else if ( newcol > c ) {
				# potential bounce off right
				if ( $.hasright(r,c) ) {
					bouncetype = "right"
				}
			}
		}

		# print("BOUNCETYPE = ",bouncetype)

		if ( bouncetype == "top" ) {
			$.breakdowntop(r,c)
			if ( $.playbreakdown )
				$.hittop(r,c,$.joycl[j])
			bouncedy = 1
			redrawbottomr = r-1
			redrawbottomc = c
		} else if ( bouncetype == "bottom" ) {
			$.breakdownbottom(r,c)
			if ( $.playbreakdown )
				$.hitbottom(r,c,$.joycl[j])
			bouncedy = 1
			redrawbottomr = r
			redrawbottomc = c
		} else if ( bouncetype == "left" ) {
			$.breakdownleft(r,c)
			if ( $.playbreakdown )
				$.hitleft(r,c,$.joycl[j])
			bouncedx = 1
			redrawrightr = r
			redrawrightc = c-1
		} else if ( bouncetype == "right" ) {
			$.breakdownright(r,c)
			if ( $.playbreakdown )
				$.hitright(r,c,$.joycl[j])
			bouncedx = 1
			redrawrightr = r
			redrawrightc = c
		}

		# if ( redrawrightr != -2 ) {
		# 	task $.redrawright(redrawrightr,
		# 		redrawrightc)
		# }
		# if ( redrawbottomr != -2 ) {
		# 	task $.redrawbottom(redrawbottomr,
		# 		redrawbottomc)
		# }
	}

	unlock($)
}
method moveballs(cl) {
	# print("moveballs Now=",Now)
	lock($)
	lim = $.colorlimit[cl]
	for ( n=0; n<lim; n++ ) {
		b = $.ball[cl][n]
		if ( b["on"] == 0 )
			break
if($.debugmove>0){print("moveballs b=",b)}
		r = b["row"]
		c = b["col"]
		realdfx = b["dfx"] * $.fdfactor * $.colorenergy[cl] / $.energydefault
		nfx = b["fx"] + realdfx
		realdfy = b["dfy"] * $.fdfactor * $.colorenergy[cl] / $.energydefault
		nfy = b["fy"] + realdfy

		if ( $.colordecay[cl] > ($.decaymin) ) {
			ddd = 1.0 - 0.05 * float($.colordecay[cl]) / $.decaymax
			b["dfx"] = float(b["dfx"]) * ddd
			b["dfy"] = float(b["dfy"]) * ddd
		} else {
		}
		# If it goes slow enough, delete it
		velocity = abs(b["dfx"]) + abs(b["dfy"])
		if ( velocity < $.dsmall ) {
			$.deleteball(cl,n)
			n--
			continue
		}

		# scale nfx,y to size of grid on screen
		nxy = $.fxy2xy(nfx,nfy)
		rc = $.grid.rxy2rc(nxy,0)
		newrow = rc["row"] 
		newcol = rc["col"] 
# print("r,c=",r,c,"  newrow,col=",rc)
		bouncetype = ""
		if ( (r != newrow || c != newcol) ) {
			if (r!=newrow && c!=newcol)
				iscorner = 1
			else
				iscorner = 0

			bouncedy = 0
			bouncedx = 0
			redrawbottomr = -2
			redrawbottomc = -2
			redrawrightr = -2
			redrawrightc = -2

			# Special cases for corners
			if ( iscorner ) {
				# print("ISCORNER");
				if ( newrow < r && newcol < c ) {
					# upper-left
					horiz = ($.hastop(r,c) && $.hastop(r,c-1) && !$.hasright(r,c-1))
					vert = ($.hasright(r,c-1) && $.hasright(r-1,c-1) && !$.hastop(r,c))
					corn1 = ($.hastop(r,c) && $.hasright(r,c-1))
					corn2 = ($.hasright(r-1,c-1) && $.hastop(r,c-1))
					if ( horiz ) {
						bouncetype = "top"
					} else if ( vert ) {
						bouncetype = "left"
					} else if ( corn1 || corn2 ) {
						$.hittop(r,c,cl,"A")
						b["dfy"] = -b["dfy"]
						b["dfx"] = -b["dfx"]
						bouncedy = 1
						bouncedx = 1
						redrawbottomr = r-1
						redrawbottomc = c
						redrawrightr = r
						redrawrightc = c-1
					}
				} else if ( newrow > r && newcol < c ) {
					# lower-left
					horiz = ($.hastop(r+1,c) && $.hastop(r+1,c-1) && !$.hasright(r,c-1))
					vert = ($.hasright(r,c-1) && $.hasright(r+1,c-1) && !$.hastop(r+1,c))
					corn1 = ($.hastop(r+1,c) && $.hasright(r,c-1))
					corn2 = ($.hasright(r+1,c-1) && $.hastop(r+1,c-1))
					if ( horiz ) {
						bouncetype = "bottom"
					} else if ( vert ) {
						bouncetype = "left"
					} else if ( corn1 || corn2 ) {
						$.hitbottom(r,c,cl)
						b["dfy"] = -b["dfy"]
						b["dfx"] = -b["dfx"]
						bouncedy = 1
						bouncedx = 1
						redrawbottomr = r
						redrawbottomc = c
						redrawrightr = r
						redrawrightc = c-1
					}
				} else if ( newrow < r && newcol > c ) {
					# upper-right
					horiz = ($.hastop(r,c) && $.hastop(r,c+1) && !$.hasright(r,c))
					vert = ($.hasright(r,c) && $.hasright(r-1,c) && !$.hastop(r,c))
					corn1 = ($.hastop(r,c) && $.hasright(r,c))
					corn2 = ($.hasright(r-1,c) && $.hastop(r,c+1))
					if ( horiz ) {
						bouncetype = "top"
					} else if ( vert ) {
						bouncetype = "right"
					} else if ( corn1 || corn2 ) {
						$.hittop(r,c,cl,"B")
						b["dfy"] = -b["dfy"]
						b["dfx"] = -b["dfx"]
						bouncedy = 1
						bouncedx = 1
						redrawbottomr = r-1
						redrawbottomc = c
						redrawrightr = r
						redrawrightc = c
					}
				} else if ( newrow > r && newcol > c ) {
					# lower-right
					horiz = ($.hastop(r+1,c) && $.hastop(r+1,c+1) && !$.hasright(r,c))
					vert = ($.hasright(r,c) && $.hasright(r+1,c) && !$.hastop(r+1,c))
					corn1 = ($.hastop(r+1,c) && $.hasright(r,c))
					corn2 = ($.hasright(r+1,c) && $.hastop(r+1,c+1))
					if ( horiz ) {
						bouncetype = "bottom"
					} else if ( vert ) {
						bouncetype = "right"
					} else if ( corn1 || corn2 ) {
						$.hittop(r,c,cl,"C")
						b["dfy"] = -b["dfy"]
						b["dfx"] = -b["dfx"]
						bouncedy = 1
						bouncedx = 1
						redrawbottomr = r
						redrawbottomc = c
						redrawrightr = r
						redrawrightc = c
					}
				}
			}

			if ( bouncetype == "" ) {
				# NORMAL bounce, off one side 
				if ( newrow < r ) {
					# potential bounce off top
					if ( $.hastop(r,c) ) {
						bouncetype = "top"
					}
				} else if ( newrow > r ) {
					# potential bounce off bottom
					if ( $.hasbottom(r,c) ) {
						bouncetype = "bottom"
					}
				} else if ( newcol < c ) {
					# potential bounce off left
					if ( $.hasleft(r,c) ) {
						bouncetype = "left"
					}
				} else if ( newcol > c ) {
					# potential bounce off right
					if ( $.hasright(r,c) ) {
						bouncetype = "right"
					}
				}
			}

			if ( bouncetype == "top" ) {
				$.hittop(r,c,cl,"D")
				b["dfy"] = -b["dfy"]
				bouncedy = 1
				redrawbottomr = r-1
				redrawbottomc = c
			} else if ( bouncetype == "bottom" ) {
				$.hitbottom(r,c,cl)
				b["dfy"] = -b["dfy"]
				bouncedy = 1
				redrawbottomr = r
				redrawbottomc = c
			} else if ( bouncetype == "left" ) {
				$.hitleft(r,c,cl)
				b["dfx"] = -b["dfx"]
				bouncedx = 1
				redrawrightr = r
				redrawrightc = c-1
			} else if ( bouncetype == "right" ) {
				$.hitright(r,c,cl)
				b["dfx"] = -b["dfx"]
				bouncedx = 1
				redrawrightr = r
				redrawrightc = c
			}


			if ( bouncedx && bouncedy ) {
				if ( bouncedx )
					nfx = b["fx"]
				if ( bouncedy )
					nfy = b["fy"]
			} else {
				if ( bouncedx )
					nfx = b["fx"]
				if ( bouncedy )
					nfy = b["fy"]
			}

			nxy = $.fxy2xy(nfx,nfy)
# print("BOUNCE, b=",b,"  nfxy=",nfx,nfy,"  nxy=",nxy["x"],nxy["y"])
			rc = $.grid.rxy2rc(nxy,0)
			# Sanity check - if we bounce, we should
			# be in the same cell.
			if ( ! bouncedy ) {
				if ( newrow < 0 ) {
					print("!bouncedy, newrow<0")
					newcol = 0
				}
				b["row"] = newrow
			}
			if ( ! bouncedx ) {
				if ( newcol < 0 ) {
					print("!bouncedx, newcol<0=",newcol)
					newcol = 0
				}
				b["col"] = newcol
			}
			if ( redrawrightr != -2 ) {
				task $.redrawright(redrawrightr,
					redrawrightc)
			}
			if ( redrawbottomr != -2 ) {
				task $.redrawbottom(redrawbottomr,
					redrawbottomc)
			}
# print("b is now ",b)
		}
		colorset(0)
		$.drawball(b,STORE)
		$.updateball(b,nfx,nfy,nxy["x"],nxy["y"])
		colorset(b["color"])
		$.drawball(b,STORE)
	}
	# colorset(1)
	unlock($)
}
method redrawright(r,c) {
	if ( r<0 || r>=$.nrows || c<-1 || c>=$.ncols )
		return()
	sleeptill(Now+$.wallredrawdelay)
	lock($)
	if ( c<0 || $.wallright[r][c] ) {
		$.grid.drawwallright(r,c,STORE)
	}
	unlock($)
	sleeptill(Now+8*$.wallredrawdelay)
	lock($)
	if ( c<0 || $.wallright[r][c] ) {
		$.grid.drawwallright(r,c,STORE)
	}
	unlock($)
}
method redrawbottom(r,c) {
	if ( r<-1 || r>=$.nrows || c<0 || c>=$.ncols )
		return()
	sleeptill(Now+$.wallredrawdelay)
	lock($)
	if ( r<0 || $.wallbottom[r][c] ) {
		$.grid.drawwallbottom(r,c,STORE)
	}
	unlock($)
	sleeptill(Now+8*$.wallredrawdelay)
	lock($)
	if ( r<0 || $.wallbottom[r][c] ) {
		$.grid.drawwallbottom(r,c,STORE)
	}
	unlock($)
}
method hastop(r,c) {
	if ( r<=0 || c<0 || r>=$.nrows || c>=$.ncols )
		return(1)
	if ( $.wallbottom[r-1][c] )
		return(1)
	return(0)
}
method hasbottom(r,c) {
	if ( r<0 || c<0 || c>=($.ncols) || r>=($.nrows-1) )
		return(1)
	if ( $.wallbottom[r][c] )
		return(1)
	return(0)
}
method hasleft(r,c) {
	if ( c<=0 || r<0 || c>=$.ncols || r>=$.nrows )
		return(1)
	if ( $.wallright[r][c-1] )
		return(1)
	return(0)
}
method hasright(r,c) {
	if ( c<0 || r<0 || c>=($.ncols-1) || r>=$.nrows )
		return(1)
	if ( $.wallright[r][c] )
		return(1)
	return(0)
}
method updateball(b,nfx,nfy,nx,ny) {
	# b["xy"] = xy(nx-1,ny-1,nx+1,ny+1)
	b["xy"] = xy(nx-3,ny-3,nx+3,ny+3)
	b["fx"] = nfx
	b["fy"] = nfy
}
method drawball(b,mode) {
	# print("drawball, color=",b["color"]," mode=",mode)
	# if ( mode != CLEAR )
	# 	colorset(b["color"])
	r = b["xy"]
	if ( typeof(r) == "array" ) {
		$.w.fillrectangle(b["xy"],mode)
	}
}
method drawballs() {
	for ( cl in $.colorindex ) {
		lim = $.colorlimit[cl]
		for ( n=0; n<lim; n++ ) {
			b = $.ball[cl][n]
			if (b["on"]==0 )
				break
			colorset(b["color"])
			$.drawball(b,STORE)
		}
	}
	# colorset(1)
}
method ison {
	if ( $.tid >= 0 )
		return(1)
	else
		return(0)
}
method clear(v) {
	lock($)
	for ( cl in $.colorindex ) {
		while ( $.ball[cl][0]["on"] ) {
			$.deleteball(cl,0)
		}
	}
	unlock($)
}
method maponoff(v) {
	$.mapon = v
}
method toggleonoff() {
	if ( $.tid < 0 ) {
		$.onoff(1)
	} else {
		$.onoff(0)
	}
}
method onoff(v) {
	lock($)
	if ( v ) {
		if ( $.tid >= 0 )
			kill($.tid)
		$.tid = task $.mazetask()
		print("ON!")
	} else {
		kill($.tid)
		$.tid = -1
		print("OFF!")
	}
	unlock($)
}
method addoneball(v) {
	if ( v == 0 )
		return()

	for ( cl in $.colorbuttpressed ) {
		lim = $.colorlimit[cl]
		found = -1
		for ( n=0; n<lim; n++ ) {
			b = $.ball[cl][n]
			if (b["on"]==0 ) {
				found = n
				break
			}
		}
		if ( found < 0 )
			continue

		if ( $.randomadd || found == 0 ) {

			r = rand($.nrows)
			c = rand($.ncols)
			cellxy = $.grid.getcellxy(r,c)
			arr = ["row"=r,"col"=c,
				"x"=(cellxy["x0"]+cellxy["x1"])/2,
				"y"=(cellxy["y0"]+cellxy["y1"])/2]
			$.gotdown(arr,["button"=1],cl)

		} else if ( found > 0 ) {
			# creating a copy of the last ball
			b = arraycopy($.ball[cl][found-1])
			b["dfy"] = -b["dfy"]
			$.ball[cl][found] = b
		}
	}
}
method editonoff(v) {
	$.editing = v
}
method joyonoff(v) {
	$.joyon = v
	if ( v ) {
		$.joy.notify($,-1)
	} else {
		$.joy.unnotify($,-1)
	}
}
method lockballs(v) {
	$.lockballson = v
}
method shiftmap(v) {
	$.mapon = v
	$.mapbutt.set($.mapon)
	$.mapbutt.redraw()
}
method togglemap(v) {
	if ( v == 1 ) {
		$.mapon = 1 - $.mapon
		$.mapbutt.set($.mapon)
		$.mapbutt.redraw()
	}
}
method pitchreset(v) {
	if ( v == 1 ) {
		$.offset = 0
		Key = 'c'
	}
}
method pitchup(v) {
	if ( v == 1 ) {
		$.offset++
		Key++
	}
}
method pitchdown(v) {
	if ( v == 1 ) {
		$.offset--
		Key--
	}
}
method pitchright(v) {
	if ( v == 1 ) {
		$.offset += 7
		Key+=7
	}
}
method pitchleft(v) {
	if ( v == 1 ) {
		$.offset -= 7
		Key-=7
	}
}

method setfile(v) {
	print("NOTE SET =",v)
	$.filenum = v
}
method buttonchange(jn,nm,v) {
	if ( $.joytype == 0 )
		$.dancepadbuttonchange(jn,nm,v)
	else
		$.wheelbuttonchange(jn,nm,v)
}
method wheelbuttonchange(jn,nm,v) {
	if ( $.verbose )
		print("method buttonchange called jn=",jn," nm=",nm," v=",v)
	$.buttonstate[jn][nm] = v
	if ( v == 0 ) {
		return()
	}
	if ( nm == "R1" || nm == "L1" || nm == "R2" || nm == "L2" ) {
		$.dofire(jn,nm)
	} else if ( nm == "TRIANGLE" ) {
		$.dorotatemovedir(jn,-1)
	} else if ( nm == "START" ) {
		$.clear()
		if ( (Now-$.laststart) < milliclicks(1000) ) {
			$.allwallsup(1)
		}
		$.laststart = Now
	} else if ( nm == "SELECT" ) {
		print("SELECT isn't active")
	}
}
method dancepadbuttonchange(jn,nm,v) {
	if ( $.verbose )
		print("method buttonchange called jn=",jn," nm=",nm," v=",v)
	$.buttonstate[jn][nm] = v
	if ( v == 0 ) {
		return()
	}
	if ( nm == "LEFT" || nm == "UP" || nm == "RIGHT") {
		$.dofire(jn,nm)
	} else if ( nm == "X" ) {
		$.dorotateturret(jn,-1)
	} else if ( nm == "CIRCLE" ) {
		$.dorotateturret(jn,1)
	} else if ( nm == "DOWN" ) {
		$.domove(jn,1)
	} else if ( nm == "SQUARE" ) {
		$.dorotatemovedir(jn,1)
	} else if ( nm == "TRIANGLE" ) {
		$.dorotatemovedir(jn,-1)
	} else if ( nm == "START" ) {
		$.clear()
		if ( (Now-$.laststart) < milliclicks(1000) ) {
			$.allwallsup(1)
		}
		$.laststart = Now
	} else if ( nm == "SELECT" ) {
		print("SELECT isn't active")
	}
}

method joyvalquant(v) {
	if ( v < 22000 )
		v = -1
	else if ( v < 40000 )
		v = 0
	else
		v = 1
	return(v)
}
method joyval(nm,v) {
	v = $.joyvalquant(v)
	if ( $.joystate[nm] != v ) {
		$.joystate[nm] = v
		return(v)
	}
	return(99)
}
method bounddf(v) {
	if ( v > 1.0 )
		return(1.0)
	if ( v < -1.0 )
		return(-1.0)
	if ( v > 0 && v < $.dsmall )
		v = $.dsmall
	if ( v < 0 && -v < $.dsmall )
		v = -$.dsmall
	return(v)
}
method analogchange(jn,nm,v) {
	if ( $.joytype == 0 )
		$.dancepadanalogchange(jn,nm,v)
	else
		$.wheelanalogchange(jn,nm,v)
}
method wheelanalogchange(jn,nm,v) {
	if ( $.verbose )
		print("method wheelanalogchange called jn=",jn," nm=",nm," v=",v)
	$.buttonstate[jn][nm] = v
}
method dancepadanalogchange(jn,nm,v) {
 	# print("method analogchange called jn=",jn," nm=",nm," v=",v)
}
method joyval2control(v,c) {
	c = c + 5 * $.joyvalquant(v)
	if ( c < 0 )
		c = 0
	if ( c > 127 )
		c = 127
	return(c)
}
method editball(v,nm,amount) {
	$.editballreal(v,nm,1)
}
method editball2(v,nm,amount) {
	$.editballreal(v,nm,3)
}
method editballreal(v,nm,factor) {
	jd = $.joyval(nm,v)
	if ( jd == 99 ) {
		return()
	}
	jd *= factor
	for ( cl in $.colorbuttpressed ) {
		lim = $.colorlimit[cl]
		for ( n=0; n<lim; n++ ) {
			b = $.ball[cl][n]
			if (b["on"]==0 )
				break
			if ( nm == "ANALOGX" || nm == "ANALOGR" ) {
				b["dfx"] += (jd*0.3)
				b["dfx"] = $.bounddf(b["dfx"])
			}
			if ( nm == "ANALOGY" || nm == "ANALOGZ" ) {
				b["dfy"] += (jd*0.3)
				b["dfy"] = $.bounddf(b["dfy"])
			}
		}
	}
}
method oldballspeed(v,nm) {
	jd = $.joyval(nm,v)
	if ( jd == 99 ) {
		return()
	}
	jd *= 2
	for ( cl in $.colorbuttpressed ) {
		lim = $.colorlimit[cl]
		for ( n=0; n<lim; n++ ) {
			b = $.ball[cl][n]
			if (b["on"]==0 )
				break
			if ( nm == "ANALOGX" || nm == "ANALOGR" ) {
				b["dfx"] += (jd*0.3)
				b["dfx"] = $.bounddf(b["dfx"])
			}
			if ( nm == "ANALOGY" || nm == "ANALOGZ" ) {
				b["dfy"] += (jd*0.3)
				b["dfy"] = $.bounddf(b["dfy"])
			}
		}
	}
}
method mazetask {
	tm = Now
	tm = nextquant(tm,$.startquant)
	movethrottle = 2
	movecount = 0
	redrawthrottle = 5000
	redrawcount = 0
	$.ballmovethrottle = 0
	$.ballmovecount = 0
	while ( 1 ) {
		sleeptill(tm)

		# only move once every movethrottle loops
		if ( movecount++ > movethrottle ) {
			movecount = 0
			for ( jn=0; jn<$.njoy; jn++ ) {
				bs = $.buttonstate[jn]
				if ( bs["DOWN"] == 1 ) {
					$.domove(jn,1)
				}
				if ( $.joytype == 0 ) {
					if ( bs["X"] == 1 ) {
						$.dorotateturret(jn,-1)
					}
				} else {
					# wheel
					v = bs["Y"]
					if ( v < 24000 ) {
						$.domove(jn,-1)
					} else if ( v > 40000 ) {
						$.domove(jn,1)
					}
					v = bs["X"]
					if ( v > 40000 ) {
						$.dorotateturret(jn,1)
						$.dorotatemovedir(jn,1)
					} else if ( v < 24000 ) {
						$.dorotateturret(jn,-1)
						$.dorotatemovedir(jn,-1)
					}
				}
				if ( bs["CIRCLE"] == 1 ) {
					$.dorotateturret(jn,1)
				}
				if ( bs["SQUARE"] == 1 ) {
					$.dorotatemovedir(jn,1)
				}
				if ( bs["TRIANGLE"] == 1 ) {
					$.dorotatemovedir(jn,-1)
				}
			}
			# Draw joysticks every once in a while
			lock($)
			$.drawjoys()
			unlock($)
		}

		if ( $.ballmovecount++ >= $.ballmovethrottle ) {
			$.ballmovecount = 0
			$.moveballs("r")
			$.moveballs("g")
			$.moveballs("b")
		}

		if ( $.doresetkeyset ) {
			$.resetkeyset()
			$.doresetkeyset = 0
		}

		oldtm = tm
		tm += milliclicks($.movemilli)
		if ( tm == oldtm )
			tm++

		if ( redrawcount++ > redrawthrottle ) {
			# redraw everything every once in a while
			$.redraw()
			redrawcount = 0
		}
	}
}
method delete {
	$.gbag.forcewalking(0)
	$.gbag.stopplaying()
	deleteobject($.gbag)
	if ( $.joy != $0 )
		$.joy.unnotify($,-1)
	kill($.tid)
	kill($.constid)
	Consecho = 1
	Merge = $.oldmerge
	Root.releaseconsole()
	realtime(ano())
}
method resize (sz) {
		if ( nargs() > 0 )
			$.w.resize(sz)
		$.dy = $.textheight() + 5
		tw = $.textwidth()

		ym2 = $.ymin() + 2

		$.dx = $.textwidth()*2
		$.x0a = $.xmin() + 2
		cln = 0

		y0 = $.ymin()+$.dy
		ddy = ($.ymax()-2-y0)/3
		y0a = y0+ddy
		y0b = y0+2*ddy
		y0c = $.ymax()-2

		x0 = $.xmin()+2

		$.gridsize = xy($.x0a+2,$.ymin()+$.dy,
				$.xmax()-3,$.ymax()-2)
		$.grid.resize($.gridsize)
		$.griddx = $.gridsize["x1"] - $.gridsize["x0"]
		$.griddy = $.gridsize["y1"] - $.gridsize["y0"]

		$.xm = $.xmin() + ($.xmax()-$.xmin())/3
		if ( $.xm < ($.xmax()-28*tw) )
			$.xm = ($.xmax()-28*tw)

		$.xmdx = ($.xmax() - $.xm)/8

		if ( $.joyinit == 0 ) {
			$.joyinit = 1
			$.joypos = []
			$.joyturret = []
			$.joymovedir = []
			$.njoy = sizeof(JoyNames)
			midx = ($.xmax() + $.xmin()) / 2
			midy = ($.ymax() + $.ymin()) / 2
			for (n=0; n<$.njoy; n++){
				jrow = 3.5
				jcol = 3.5 + n
				jx = jcol*$.fmax/$.ncols
				jy = jrow*$.fmax/$.nrows
				$.joypos[n] = xy(jx,jy)
				if ( $.joytype == 0 ) {
					$.joyturret[n] = 45.0
					$.joymovedir[n] = 135.0
				} else {
					$.joyturret[n] = 45.0
					$.joymovedir[n] = 45.0
				}

				$.buttonstate[n] = []
				if ( $.joytype == 1 ) {
					$.buttonstate[n]["Y"] = 32511
					$.buttonstate[n]["X"] = 32511
				}
			}
		}

	}
method redraw {
		lock($)
		colorset($.linecolor)
		$.w.redraw()
		$.w.textcenter("Bouncing off the Walls",xy($.xmin(),$.ymin(),
				$.xmax(),$.ymin()+$.dy))
		x0c = $.xmin() + 2 + 3*$.dx
		x0d = $.xmin() + 2 + 4*$.dx
		y0 = $.ymin()+$.dy
		ddy = ($.ymax()-2-y0)/3
		y0a = y0+ddy
		y0b = y0+2*ddy
		y0c = $.ymax()-2
		th = $.textheight()

		methodbroadcast()
		$.erasewalls()
		colorset($.linecolor)
		$.w.rectangle($.gridsize)
		$.drawballs()
		$.drawjoys()
		unlock($)
	}

method drawjoys {
	if ( $.joyinit == 0 )
		return()
	for ( n=0; n<$.njoy; n++ ) {
		colorset($.joycolor[n])
		$.drawjoy(n,STORE)
	}
}
method drawjoy(j,mode) {
	jxy = $.fxy2xy($.joypos[j]["x"],$.joypos[j]["y"])
	arrowlen = round($.fmove * 2.5)
	arrowhalf = (2*arrowlen) / 3

	r1 = xy( jxy["x"]-3, jxy["y"]-3, jxy["x"]+3, jxy["y"]+3)
	$.w.fillrectangle(r1,mode)

	arrang = 25

	# Draw line and an array in the direction of moving
	dir_rad = $.d2r*$.joymovedir[j]
	dir_rad1 = $.d2r*($.joymovedir[j]+arrang)
	dir_rad2 = $.d2r*($.joymovedir[j]-arrang)

	# print("dir=",$.joymovedir[j],dir_rad)
	# print("dir1=",$.joymovedir[j]+arrang,dir_rad1)
	# print("dir2=",$.joymovedir[j]-arrang,dir_rad2)

	dirxy = $.fxy2xy($.joypos[j]["x"]+arrowlen*cos(dir_rad),
			$.joypos[j]["y"]+arrowlen*sin(dir_rad))
	dir1xy = $.fxy2xy($.joypos[j]["x"]+arrowhalf*cos(dir_rad1),
			$.joypos[j]["y"]+arrowhalf*sin(dir_rad1))
	dir2xy = $.fxy2xy($.joypos[j]["x"]+arrowhalf*cos(dir_rad2),
			$.joypos[j]["y"]+arrowhalf*sin(dir_rad2))

	# print("dirxy=",dirxy)
	# print("dir1xy=",dir1xy)
	# print("dir2xy=",dir2xy)

	$.w.line(xy(jxy["x"],jxy["y"],dirxy["x"],dirxy["y"]),mode)
	$.w.line(xy(dirxy["x"],dirxy["y"],dir1xy["x"],dir1xy["y"]),mode)
	$.w.line(xy(dirxy["x"],dirxy["y"],dir2xy["x"],dir2xy["y"]),mode)

	# Draw line and little ball at end for turret/ball direction
	turretxy = $.fxy2xy($.joypos[j]["x"]+arrowlen*cos($.d2r*$.joyturret[j]),
			$.joypos[j]["y"]+arrowlen*sin($.d2r*$.joyturret[j]))
	$.w.line(xy(jxy["x"],jxy["y"],turretxy["x"],turretxy["y"]),mode)
	$.w.fillrectangle(xy(
			turretxy["x"]-2,turretxy["y"]-2,
			turretxy["x"]+2,turretxy["y"]+2),mode)
}
method angnorm(d) {
	while ( d > 360.0 )
		d -= 360.0
	while ( d < 0.0 )
		d += 360.0
	return(d)
}
method dorotatemovedir(j,rightleft) {
	lock($)
	colorset(0)
	$.drawjoy(j,STORE)
	colorset($.joycolor[j])
	$.joymovedir[j] = $.angnorm($.joymovedir[j] + rightleft * 5.0)
	$.drawjoy(j,STORE)
	unlock($)
}
method dorotateturret(j,rightleft) {
	lock($)
	colorset(0)
	$.drawjoy(j,STORE)
	colorset($.joycolor[j])
	$.joyturret[j] = $.angnorm($.joyturret[j] + rightleft * 5.0)
	$.drawjoy(j,STORE)
	unlock($)
}

method notify(r,c,cl) {
	cellxy = $.grid.getcellxy(r,c)
	arr = ["row"=r,"col"=c,
		"x"=(cellxy["x0"]+cellxy["x1"])/2,
		"y"=(cellxy["y0"]+cellxy["y1"])/2]
	$.gotdown(arr,["button"=1],cl)
}
method fxy2xy(fx,fy) {
	return(xy(integer($.gridsize["x0"] + $.griddx * fx / $.fmax),
		integer($.gridsize["y0"] + $.griddy * fy / $.fmax)))
}
method gotdrag (m,ms,cl) {
	if ( nargs() < 3 ) {
		cl = $.currentcolor
	}
	# Drag events don't include the modifier, bummer
	ms["modifier"] = $.shiftdown * 2 + $.controldown
	$.realgotdown(1,m,ms,cl)
}
method gotdown (m,ms,cl) {
	if ( nargs() < 3 ) {
		cl = $.currentcolor
	}
	$.realgotdown(0,m,ms,cl)
}
method realgotdown(dragged,m,ms,cl) {

	# print("realgotdown(dragged=",dragged," m=",m," ms=",ms," cl=",cl)
	r = m["row"]
	c = m["col"]
	if ( r >= $.nrows )
		return()
	if ( c >= $.ncols )
		return()

	lock($)

	if ( ms["modifier"] == "" ) {
		$.shiftdown = 0
		$.controldown = 0
	} else {
		$.shiftdown = (( ms["modifier"] & 2 ) != 0 )
		$.controldown = (( ms["modifier"] & 1 ) != 0 )
	}

	# When the control key is down, we're deleting/adding walls
	if ( $.controldown ) {
		# If the shift key is down, we're adding walls
		addit = ((ms["modifier"] & 2) != 0)
		if ( ms["button"] == 2 && c < ($.ncols-1) ) {
			# do the right wall
			$.wallright[r][c] = addit
			if ( $.wallright[r][c] == 0 ) {
				$.grid.setlinecolor(0)
				$.grid.drawwallright(r,c,STORE)
				$.grid.setlinecolor($.linecolor)
			} else {
				$.grid.drawwallright(r,c,STORE)
			}
		} else if ( ms["button"] == 1 && r < ($.nrows-1) ) {
			# toggle the bottom wall
			$.wallbottom[r][c] = addit
			if ( $.wallbottom[r][c] == 0 ) {
				$.grid.setlinecolor(0)
				$.grid.drawwallbottom(r,c,STORE)
				$.grid.setlinecolor($.linecolor)
			} else {
				$.grid.drawwallbottom(r,c,STORE)
			}
		}
		unlock($)
		return()
	}
	if ( dragged ) {
		unlock($)
		return()
	}

	if ( $.shiftdown ) {

# XXX - This isn't really used anymore, I think.

		# find any balls already in that cell, and delete 1
		found = -1
		laston = -1
		for ( cl in $.colorindex ) {
			lim = $.colorlimit[cl]
			for ( n=0; n<lim; n++ ) {
				b = $.ball[cl][n]
				if (b["on"]==0)
					break
				laston = n
				if ( b["row"]==r && b["col"]==c ) {
					found = n
					foundcl = cl
				}
			}
		}
		if ( found>=0 ) {
			b = $.ball[foundcl][found]
			colorset(0)
			$.drawball(b,STORE)
			colorset($.linecolor)
			b["on"] = 0
			# swap it with last "on" one
			if ( laston != found ) {
				tb = $.ball[foundcl][found]
				$.ball[foundcl][found] = $.ball[foundcl][laston]
				$.ball[foundcl][laston] = tb
			}
		}
		unlock($)
		return()
	}

	initfx = (m["x"] - $.gridsize["x0"]) * $.fmax / $.griddx
	initfy = (m["y"] - $.gridsize["y0"]) * $.fmax / $.griddy

	$.addball(cl,initfx,initfy)
	unlock($)
}

method addball(cl,initfx,initfy,ang) {
	if ( nargs() < 4 )
		ang = 45.0
	# find any balls already in that cell
	freeslot = -1
	laston = -1
	for ( n=0; n<$.colorlimit[cl]; n++ ) {
		b = $.ball[cl][n]
		if (b["on"]==0) {
			freeslot = n
			break
		}
		laston = n
	}
	if ( freeslot < 0 ) {
		# Erase 0th one and shift others down
		colorset(0)
		$.drawball($.ball[cl][0],STORE)
		colorset($.linecolor)

		lim = $.colorlimit[cl]
		for ( n=1; n<lim; n++ )
			$.ball[cl][n-1] = $.ball[cl][n]
		freeslot = lim-1
	}
	n = freeslot
	$.ball[cl][n] = []
	b = $.ball[cl][n]
	b["on"] = 1

	bxy = $.fxy2xy(initfx,initfy)
	brc = $.grid.rxy2rc(bxy,0)
	b["row"] = brc["row"]
	b["col"] = brc["col"]
	b["color"] = $.colorindex[cl]

	$.updateball(b,initfx,initfy,bxy["x"],bxy["y"])

	b["dfx"] = 1.0 * cos($.d2r * ang)
	b["dfy"] = 1.0 * sin($.d2r * ang)

	# print("NEW ball b=",b)

	# print("addball init b=",b)

	colorset(b["color"])
	$.drawball(b,STORE)

	# colorset(1)
}

method deleteball(cl,dn) {
	laston = -1
	lim = $.colorlimit[cl]
	for ( n=0; n<lim; n++ ) {
		b = $.ball[cl][n]
		if (b["on"]==0)
			break
		laston = n
	}
	if ( laston>=0 ) {
		b = $.ball[cl][dn]
		colorset(0)
		$.drawball(b,STORE)
		colorset($.linecolor)
		b["on"] = 0
		# swap it with last "on" one
		if ( laston != dn ) {
			tb = $.ball[cl][dn]
			$.ball[cl][dn] = $.ball[cl][laston]
			$.ball[cl][laston] = tb
		}
	}
}

method setplayquant(v) {
	$.playquant = v
}

method setmovinglimit(v) {
	if ( v > $.maxballspercolor ) {
		print("You can't have that many, the limit is ",$.maxballspercolor)
		return()
	}
	lock($)
	for ( cl in $.colorindex ) {
		n = v
		while ( (n in $.ball[cl]) && $.ball[cl][n]["on"] ) {
			$.deleteball(cl,n)
		}
		$.colorlimit[cl] = v
	}
	unlock($)
}

method setscale(k,s,nstarts) {
	if ( nargs() < 3 )
		nstarts = 1
	sc = completescale(k,s)
	sc = step(sc,$.playquant)
	arr = splitonstarts(sc,0,nstarts)
	$.setfromarr(arr,$.exactfit)
}
method readfile(nstarts) {
	fname = browsefiles("MIDI File (*.MID)","*.mid",0)
	if ( fname == "" ) {
		print("No file specified")
		return()
	}
	$.setfromfile(fname,nstarts)
}
method setfromfile(fname,nstarts) {
	p = onlynotes(readmf(fname))
	if ( sizeof(p) == 0 )
		p = onlynotes(readmf("jsbach.mid"))
	p -= p{??.chan==10}
	# print("setfromfile filenum=",$.filenum," fname=",fname," size=",sizeof(p))
	$.setfromphrase(p,nstarts)
}
method setfromsnarf(nstarts) {
	$.setfromphrase(Snarf,nstarts)
}
method setfromphrase(p,nstarts) {
	p = onlynotes(p)
	if ( sizeof(p) == 0 ) {
		print("No notes in phrase!?")
		return()
	}
	arr = splitonstarts(p,0,nstarts)
	$.setfromarr(arr,$.exactfit)
}

method setfromarr(arr,exactfit) {

	lock($)
	for ( i in arr ) {
		tm1 = arr[i]%1.time
		arr[i].time -= tm1
	}
	if ( exactfit ) {
		ai = 0
		tot = $.ncols * $.nrows * 4
		sofar = 0
		arrsz = sizeof(arr)
		for ( r=0; r<$.nrows; r++ ) {
			for ( c=0; c<$.ncols; c++ ) {
				d = arrsz * sofar++ / tot
				$.sidetop[r][c][$.filenum] = arr[d]

				d = arrsz * sofar++ / tot
				$.sidebottom[r][c][$.filenum] = arr[d]

				d = arrsz * sofar++ / tot
				$.sideleft[r][c][$.filenum] = arr[d]

				d = arrsz * sofar++ / tot
				$.sideright[r][c][$.filenum] = arr[d]
			}
		}
	} else {
		# This version uses each item once, and restarts
		# from the beginning when it runs out
		ai = 0
		for ( r=0; r<$.nrows; r++ ) {
			for ( c=0; c<$.ncols; c++ ) {
				if ( ! ( ai in arr ) )
					ai = 0
				p = arr[ai++]
				$.sidetop[r][c][$.filenum] = p
				if ( ! ( ai in arr ) )
					ai = 0
				p = arr[ai++]
				$.sidebottom[r][c][$.filenum] = p
				if ( ! ( ai in arr ) )
					ai = 0
				p = arr[ai++]
				$.sideleft[r][c][$.filenum] = p
				if ( ! ( ai in arr ) )
					ai = 0
				p = arr[ai++]
				$.sideright[r][c][$.filenum] = p
			}
		}
	}
	unlock($)
}
method debugprint {
	$.debug = 1 - $.debug
	for ( cl in $.colorindex ) {
		print("cl=",cl)
		for ( n=0; n<$.maxballspercolor; n++ ) {
			b = $.ball[cl][n]
			if (b["on"]==0)
				break
			print("b=",b)
		}
	}
}
}

