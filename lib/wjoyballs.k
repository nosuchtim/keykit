class wjoyballs {

method init {

	$.w = new window()
	$.inherit($.w)

	$.joyon = 0

	# Figure Remember what ports each channel goes to
	$.defouts = midi("portmap")[0]

	$.reverbtimeval = 64
	$.reverbeffectval = 64
	$.delayfeedbackval = 64
	$.delayeffectval = 64

	$.lastx = -1
	$.lasty = -1
	$.tid = -1
	$.fmax = 1000000.0
	$.fdfactor = 13333.0	# amount to multiply dx/dy things by
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
	$.lastbunch = ''
	$.lastbunchtm = 0
	$.lastbunchdelta = 8b
	$.mapon = 0
	$.lockballson = 0
	$.effectport = 0
	if ( defined(EffectPort) )
		$.effectport = EffectPort

	$.loopplaying = [0=0,1=0,2=0,3=0]

	$.setbasech(1)

	$.selecteditmodes = [
		"SQUARE" = [ "DESC" = "VOL/DUR, FILE SETTING, BALL SPEED/MOVE",
			"L2" = "lockballs",
			"SQUARE"="file0","TRIANGLE"="file1",
			"CIRCLE"="file2","X"="file3",
			"ANALOGX" = "", "ANALOGY" = "editenergy",
			"ANALOGR" = "editball2", "ANALOGZ" = "editball2",
			"UP" = "volup", "DOWN" = "voldown",
			"LEFT" = "durshorter", "RIGHT" = "durlonger"
			],
		"TRIANGLE" = [ "DESC" = "PITCH CHANGING",
			"L2" = "shiftmap",
			"SQUARE"="","TRIANGLE"="togglemap",
			"CIRCLE"="","X"="pitchreset",
			"ANALOGX" = "", "ANALOGY" = "",
			"ANALOGR" = "", "ANALOGZ" = "",
			"UP" = "pitchup", "DOWN" = "pitchdown",
			"LEFT" = "pitchleft", "RIGHT" = "pitchright"
			],
		"CIRCLE" = [ "DESC" = "L2=LOCKBALLS, PAD=PATCH CHANGES, BUTTS=BALL OPS, JOY=BALL SPEED/MOVING",
			"L2" = "lockballs",
			"SQUARE"="dobreakout","TRIANGLE"="allwallsup",
			"CIRCLE"="addoneball","X"="deleteoneball",
			"ANALOGX" = "", "ANALOGY" = "editenergy",
			"ANALOGR" = "editball2", "ANALOGZ" = "editball2",
			"UP" = "patchup", "DOWN" = "patchdown",
			"LEFT" = "patchleft", "RIGHT" = "patchright"
			],
		"X" = [ "DESC" = "PATCH CHANGES, LOOP PLAYBACK",
			"SQUARE"="loopback0","TRIANGLE"="loopback1",
			"CIRCLE"="loopback2","X"="loopback3",
			"ANALOGX" = "", "ANALOGY" = "",
			"ANALOGR" = "", "ANALOGZ" = "",
			"UP" = "patchup", "DOWN" = "patchdown",
			"LEFT" = "patchleft", "RIGHT" = "patchright"
			]
		]
	$.starteditmodes = [
		"SQUARE" = [ "DESC" = "REVERB/DELAY",
			"SQUARE"="","TRIANGLE"="",
			"CIRCLE"="","X"="",
			"ANALOGX" = "reverbtime", "ANALOGY" = "reverbeffect",
			"ANALOGR" = "delayfeedback", "ANALOGZ" = "delayeffect",
			"UP" = "", "DOWN" = "",
			"LEFT" = "", "RIGHT" = ""
			],
		"TRIANGLE" = [ "DESC" = "NOTHING YET",
			"SQUARE"="","TRIANGLE"="",
			"CIRCLE"="","X"="",
			"ANALOGX" = "", "ANALOGY" = "",
			"ANALOGR" = "", "ANALOGZ" = "",
			"UP" = "", "DOWN" = "",
			"LEFT" = "", "RIGHT" = ""
			],
		"CIRCLE" = [ "DESC" = "NOTHING YET",
			"L2" = "",
			"SQUARE"="","TRIANGLE"="",
			"CIRCLE"="","X"="",
			"ANALOGX" = "", "ANALOGY" = "",
			"ANALOGR" = "", "ANALOGZ" = "",
			"UP" = "", "DOWN" = "",
			"LEFT" = "", "RIGHT" = ""
			],
		"X" = [ "DESC" = "NOTHING YET",
			"SQUARE"="","TRIANGLE"="",
			"CIRCLE"="","X"="",
			"ANALOGX" = "", "ANALOGY" = "",
			"ANALOGR" = "", "ANALOGZ" = "",
			"UP" = "", "DOWN" = "",
			"LEFT" = "", "RIGHT" = ""
			]
		]

	# Initial edit mode
	$.editmeths = $.selecteditmodes["CIRCLE"]

	$.nfiles = 4
	$.filenum = 0
	# Define JoyBallsFiles in keylocal.k if you want
	if ( defined(JoyBallsFiles) ) {
		$.filenames = JoyBallsFiles
	} else {
		$.filenames = [
			0="jsbach.mid",
			1="prelude.mid",
			2="bachinv1.mid",
			3="bachinv2.mid"]
	}
	$.filephrase = []
	for ( n in $.filenames ) {
		p = onlynotes(readmf($.filenames[n]))
		if ( sizeof(p) == 0 )
			p = onlynotes(readmf("jsbach.mid"))
		$.filephrase[n] = p
	}

	$.butt2color = ["R1"="g","R2"="b","L1"="r"]
	$.colorchan = ["r"=1,"g"=2,"b"=3]
	$.colorindex = ["r"=8,"g"=9,"b"=10]
	$.orderedcolors = [0="r",1="g",2="b"]
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
	$.wallcolor = 11
	$.joynum = 0

	$.grid = $0
	$.more = new kmenubutton("More","mkmenu_joyballs_1",$)
	$.addchild($.more)
	$.redbutt = new ktoggle("R",$,"redonoff")
	$.addchild($.redbutt)
	$.greenbutt = new ktoggle("G",$,"greenonoff")
	$.addchild($.greenbutt)
	$.bluebutt = new ktoggle("B",$,"blueonoff")
	$.addchild($.bluebutt)

	$.b3 = new kvalbutton([0="Normal",1="Control",2="Shift"],
			$,"modchanged",REDRAW);
	charr = []
	for ( n=1; n<=14; n++ )
		charr[n-1] = string(n)
	$.chanbutt = new kvalbutton(charr,$,"chanchanged")
	$.addchild($.chanbutt)

	filearr = [0="File 1",1="File 2",2="File 3",3="File 4"]
	$.filebutt = new kvalbutton(filearr,$,"filenumchanged")
	$.addchild($.filebutt)

	$.onoffbutt = new ktoggle("On",$,"onoff")
	$.addchild($.onoffbutt)

	$.mapbutt = new ktoggle("Map",$,"maponoff")
	$.addchild($.mapbutt)

	$.joybutt = new ktoggle("Joy",$,"joyonoff")
	$.addchild($.joybutt)

	$.clearbutt = new kbutton("Clear",$,"clear")
	$.addchild($.clearbutt)

	$.basevelocity = 0
	$.topvelocity = 127
	$.decaydefault = 10
	$.decaymax = 1000
	$.velocitydefault = 500
	$.energydefault = 500
	$.dsmall = 0.024

	$.slidermax = 1000
	$.decayslider = []
	$.volslider = []
	$.energyslider = []
	for ( cl in $.colorindex ) {
		$.decayslider[cl] = new kslider(0,$.slidermax,
					$.decaydefault,$,"changedecay",cl)
		$.addchild($.decayslider[cl])
		$.volslider[cl] = new kslider(0,$.slidermax,
					$.velocitydefault,$,"changevol",cl)
		$.addchild($.volslider[cl])
		$.energyslider[cl] = new kslider(0,$.slidermax,
					$.energydefault,$,"changeenergy",cl)
		$.addchild($.energyslider[cl])
	}

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
	$.movesize = 1b/8
	$.colorlimit = []
	$.playlimit = 4
	$.freeze = []
	$.freezep = []

	$.colordecay = []
	$.colorvelocity = []
	$.colorenergy = []
	$.lastpatchtime = []
	$.lastpatcharr1 = ["r"=[],"g"=[],"b"=[]]
	$.lastpatcharr2 = ["r"=[],"g"=[],"b"=[]]
	$.lastpatcharr3 = ["r"=[],"g"=[],"b"=[]]
	for ( cl in $.colorindex ) {
		$.colordecay[cl] = $.decaydefault
		$.colorvelocity[cl] = $.velocitydefault
		$.colorenergy[cl] = $.energydefault
		$.colorlimit[cl] = $.maxballspercolor/2
		$.freeze[cl] = 0
		$.freezep[cl] = ''
		$.lastpatchtime[cl] = Now-8b
	}
	$.tids = []
	$.redbutt.set(1)

	MazeTool = $

	$.setgridsize(16,0)

	if ( defined(JoyBallsNotes) ) {
		nnotes = JoyBallsNotes
	} else {
		nnotes = 1
	}
	for ( n=0; n<$.nfiles; n++ ) {
		$.filenum = n
		print("Reading file ",$.filenames[n]," nnotes=",nnotes)
		$.setfromfile($.filenames[n],nnotes)
	}
	$.filenum = 0

	# $.joyonoff(1)
	# $.joybutt.set(1)
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
		"basech" = $.basech,
		"filenum" = $.filenum,
		"mapon" = $.mapon,
		"joynum" = $.joynum,
		"joyon" = $.joyon,
		"ball" = $.ball
	] )
}
method restore(st) {
	for ( cl in $.colorindex ) {
		$.decayslider[cl].set(st["colordecay"][cl])
		$.volslider[cl].set(st["colorvelocity"][cl])
		$.energyslider[cl].set(st["colorenergy"][cl])
	}
	$.mapon = st["mapon"]
	if ( "joynum" in st )
		$.joynum = st["joynum"]
	if ( $.joynum == "" )
		$.joynum = 0
	$.joyon = st["joyon"]

	$.setbasech(st["basech"])
	$.chanbutt.set($.basech-1)
	$.mapbutt.set($.mapon)

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
	$.joybutt.set($.joyon)
}

method filenumchanged(v) {
	$.filenum = v
}
method chanchanged(v) {
	$.setbasech(v+1)
}
method setbasech(v) {
	$.basech = v
	$.colorchan = ["r"=$.basech,"g"=$.basech+1,"b"=$.basech+2]
}
method changedecay(v,cl) {
	$.colordecay[cl] = v
}
method changevol(v,cl) {
	$.colorvelocity[cl] = v
}
method changeenergy(v,cl) {
	# change all the existing balls
	lock($)
	$.colorenergy[cl] = v
	for ( cl in $.colorindex ) {
		for ( n=0; n<$.maxballspercolor; n++ ) {
			b = $.ball[cl][n]
			if ( b["on"] == 0 )
				break
			# Reset dfx to original values
			if ( b["dfx"] < 0  )
				b["dfx"] = -1.0
			else
				b["dfx"] = 1.0
			if ( b["dfy"] < 0 )
				b["dfy"] = -1.0
			else
				b["dfy"] = 1.0
		}
	}
	unlock($)
}

method editenergy(v,nm) {
	jd = $.joyval(nm,v)
	if ( jd == 99 ) {
		return()
	}
	for ( cl in $.colorbuttpressed ) {
		if ( jd < 0 )
			$.energyslider[cl].incndo()
		else if ( jd > 0 )
			$.energyslider[cl].decndo()
	}
}

method setgridsize(v,doredraw) {
	$.nrows = v
	$.ncols = v
	if ( $.grid != $0 ) {
		$.removechild($.grid)
	}
	deleteobject($.grid)
	$.grid = new wgrid($.ncols,$.nrows)
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
	lock($)
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
			for ( f=0; f<$.nfiles; f++ ) {
				$.sidetop[r][c][f] = ''
				$.sidebottom[r][c][f] = ''
				$.sideleft[r][c][f] = ''
				$.sideright[r][c][f] = ''
			}
		}
	}
	unlock($)
	$.allwallsup(0)
}
method allwallsup(doredraw) {
	if ( nargs() < 1 )
		doredraw = 1
	lock($)
	for ( r=0; r<$.nrows; r++ ) {
		for ( c=0; c<$.ncols; c++ ) {
			$.wallbottom[r][c] = 1
			$.wallright[r][c] = 1
		}
	}
	unlock($)
	if ( doredraw )
		$.redraw()
}
method allwallsrand(doredraw,f) {
	if ( nargs() < 1 )
		doredraw = 1
	lock($)
	for ( r=0; r<$.nrows; r++ ) {
		for ( c=0; c<$.ncols; c++ ) {
			$.wallbottom[r][c] = ( rand(100) < (f * 100) )
			$.wallright[r][c] = ( rand(100) < (f * 100) )
		}
	}
	unlock($)
	if ( doredraw )
		$.redraw()
}
method erasewalls {
	for ( r=0; r<$.nrows; r++ ) {
		for ( c=0; c<$.ncols; c++ ) {
			if ( $.wallright[r][c] == 0 ) {
				$.grid.drawwallright(r,c,CLEAR)
			}
			if ( $.wallbottom[r][c] == 0 ) {
				$.grid.drawwallbottom(r,c,CLEAR)
			}
		}
	}
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
method playit(p,cl) {
	if ( typeof(p) != "phrase") {
		print("Hey, playit given non-phrase?")
		return()
	}
	p.chan = $.colorchan[cl]
	p.vol = $.basevelocity + ($.topvelocity - $.basevelocity) * $.colorvelocity[cl] / $.slidermax
	p.pitch += $.offset
	p.dur *= $.colordur[cl]
	if ( $.mapon ) {
		sc = maptoscale(Mapto,Key)
		p = scadjust(p,sc)
	}
	if ( $.debug )
		print("p=",p)

	tm = nextquant(Now,$.playquant)
	f = $.freeze[cl]
	if ( f == 1 ) {
		for ( t in $.tids )
			kill(t)
		$.tids = []
		p.type = NOTEON
		$.realtime(p,tm)
		$.freeze[cl] = 2
		$.freezep[cl] = p
	} else if ( f == 2 ) { 
		# do nothing, wait for freeze == 3
	} else if ( f == 3 ) { 
		p = $.freezep[cl]
		p.type = NOTEOFF
		$.realtime(p,tm)
		$.freezep[cl] = ''
		$.freeze[cl] = 0
	} else {
		t = $.realtime(p,tm)
		$.tids[t] = 1
	}
}
method loopback0(v) {
	$.loopback(v,0)
}
method loopback1(v) {
	$.loopback(v,1)
}
method loopback2(v) {
	$.loopback(v,2)
}
method loopback3(v) {
	$.loopback(v,3)
}
method loopback(v,n) {
	dt = 4b - n*1b
	if ( v == 1 ) {
		p = cut($.lastbunch,CUT_TIME,
			$.lastbunchtm-dt,$.lastbunchtm)
		p.time -= $.lastbunchtm-dt
		p = strip(p)
		if ( $.loopplaying[n] )
			kill($.loopplaying[n])
		$.loopplaying[n] = realtime(p,Now)
	}
}
method realtime(p,tm) {
# print("realtime p=",p)
	t = realtime(p,tm)
	p.time += tm
	# Keep the last so many beats of time
	ptime = tm - $.lastbunchdelta
	$.lastbunch = cut($.lastbunch,CUT_TIME,tm,ptime) | p
	$.lastbunchtm = tm
	return(t)
}
method hitleft(r,c,cl) {
	$.playit($.sideleft[r][c][$.filenum],cl)
	if ( $.breakout && c > 0 ) {
		if ( r < 0 || r >= $.nrows )
			print("Unexpected r in hitleft")
		$.wallright[r][c-1] = 0
		$.grid.drawwallright(r,c-1,CLEAR)
	}
}
method hitright(r,c,cl) {
	$.playit($.sideright[r][c][$.filenum],cl)
	if ( $.breakout && c < ($.nrows-1) ) {
		$.wallright[r][c] = 0
		$.grid.drawwallright(r,c,CLEAR)
	}
}
method hittop(r,c,cl) {
	$.playit($.sidetop[r][c][$.filenum],cl)
	if ( $.breakout && r > 0 ) {
		$.wallbottom[r-1][c] = 0
		$.grid.drawwallbottom(r-1,c,CLEAR)
	}
}
method hitbottom(r,c,cl) {
	$.playit($.sidebottom[r][c][$.filenum],cl)
	if ( $.breakout && r < ($.nrows-1) ) {
		$.wallbottom[r][c] = 0
		$.grid.drawwallbottom(r,c,CLEAR)
	}
}
method moveballs(cl) {
	lock($)
	lim = $.colorlimit[cl]
	$.lastx = -1
	# $.breakout = $.controldown
	for ( n=0; n<lim; n++ ) {
		b = $.ball[cl][n]
		if ( b["on"] == 0 )
			break
		r = b["row"]
		c = b["col"]
		realdfx = b["dfx"] * $.fdfactor * $.colorenergy[cl] / $.energydefault
		nfx = b["fx"] + realdfx
		realdfy = b["dfy"] * $.fdfactor * $.colorenergy[cl] / $.energydefault
		nfy = b["fy"] + realdfy

		if ( $.colordecay[cl] > (0.1*$.decaydefault) ) {
			ddd = 1.0 - 0.05 * float($.colordecay[cl]) / $.decaymax
			b["dfx"] = float(b["dfx"]) * ddd
			b["dfy"] = float(b["dfy"]) * ddd
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
						$.hittop(r,c,cl)
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
						$.hittop(r,c,cl)
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
						$.hittop(r,c,cl)
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
				$.hittop(r,c,cl)
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
		$.drawball(b,CLEAR)
		$.updateball(b,nfx,nfy,nxy["x"],nxy["y"])
# print("MOVED ball b=",b)
		colorset($.colorindex[cl])
if($.debugmove>0){print("drawing b=",b);}
		$.drawball(b,STORE)
	}
	colorset(1)
	unlock($)
}
method redrawright(r,c) {
	if ( r<0 || r>=$.nrows || c<-1 || c>=$.ncols )
		return()
	sleeptill(Now+1b)
	lock($)
	if ( c<0 || $.wallright[r][c] ) {
		colorset($.wallcolor)
		$.grid.drawwallright(r,c,STORE)
	}
	unlock($)
}
method redrawbottom(r,c) {
	if ( r<-1 || r>=$.nrows || c<0 || c>=$.ncols )
		return()
	sleeptill(Now+1b)
	lock($)
	if ( r<0 || $.wallbottom[r][c] ) {
		colorset($.wallcolor)
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
	b["xy"] = xy(nx-1,ny-1,nx+1,ny+1)
	b["fx"] = nfx
	b["fy"] = nfy
}
method drawball(b,mode) {
	arr = b["xy"]
	$.w.fillrectangle(arr,mode)
	if ( mode == STORE ) {
		if ( $.lastx >= 0 ) {
			a = xy($.lastx,$.lasty,arr["x0"],arr["y0"])
			# $.w.line(a,mode)
		}
		$.lastx = arr["x0"]
		$.lasty = arr["y0"]
	}
}
method drawballs(mode) {
	if ( nargs() < 1 )
		mode = STORE
	
# print("\nDrawballs start")
	for ( cl in $.colorindex ) {
		lim = $.colorlimit[cl]
		$.lastx = -1
		colorset($.colorindex[cl])
		for ( n=0; n<lim; n++ ) {
			b = $.ball[cl][n]
			if (b["on"]==0 )
				break
			$.drawball(b,mode)
		}
	}
	colorset(1)
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
	$.redraw()
}
method maponoff(v) {
	$.mapon = v
}
method redonoff(v) {
	if ( v ) {
		$.currentcolor = "r"
		$.greenbutt.set(0) ; $.greenbutt.redraw()
		$.bluebutt.set(0) ; $.bluebutt.redraw()
	} else {
		$.redbutt.set(1) ; $.redbutt.redraw()
	}
}
method greenonoff(v) {
	if ( v ) {
		$.currentcolor = "g"
		$.redbutt.set(0) ; $.redbutt.redraw()
		$.bluebutt.set(0) ; $.bluebutt.redraw()
	} else {
		$.greenbutt.set(1) ; $.greenbutt.redraw()
	}
}
method blueonoff(v) {
	if ( v ) {
		$.currentcolor = "b"
		$.redbutt.set(0) ; $.redbutt.redraw()
		$.greenbutt.set(0) ; $.greenbutt.redraw()
	} else {
		$.bluebutt.set(1) ; $.bluebutt.redraw()
	}
}
method onoff(v) {
	lock($)
	if ( v ) {
		if ( $.tid >= 0 )
			kill($.tid)
		$.tid = task $.mazetask()
	} else {
		kill($.tid)
		$.tid = -1
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
method deleteoneball(v) {
	if ( v == 0 )
		return()
	lock($)
	for ( cl in $.colorbuttpressed ) {
		# delete 0th one if it's on
		b = $.ball[cl][0]
		if (b["on"]!=0 ) {
			$.deleteball(cl,0)
		}
	}
	unlock($)
}
method editonoff(v) {
	$.editing = v
}
method setjoynum(v) {
	# Unregister previous joynum
	$.joynum = v
}
method joyonoff(v) {
	if ( ! defined(v) )
		v = 0
	$.joyon = v
}
method patchup(v) {
	if ( v == 0 )
		return()
	$.patchdown(v)
}
method patchdown(v) {
	if ( v == 0 )
		return()
	for ( cl in $.colorbuttpressed ) {
		$.throttlepatchchange(cl,1)	# random
	}
}
method patchleft(v) {
	if ( v == 0 )
		return()
	for ( cl in $.colorbuttpressed ) {
		$.throttlepatchprev(cl)
	}
}
method patchright(v) {
	if ( v == 0 )
		return()
	for ( cl in $.colorbuttpressed ) {
		$.throttlepatchchange(cl,0)
	}
}
method resetafterpatchchange(cl) {
	$.colordur[cl] = 1.0
	$.colorvol[cl] = $.defaultvol
	$.sendvol(cl)
}
method throttlepatchchange(cl,rnd) {

	# Don't sent patch changes too often
	if ( $.lastpatchtime[cl] < (Now-1b/2) ) {

		$.lastpatchtime[cl] = Now

		ch = $.colorchan[cl]
		if ( rnd ) {
			arr = patchmap_rand(ch)
		} else {
			# arr = patchmap_type(ch,".*")
			arr = patchmap_type(ch,"good")
		}
		# 

		print("Ch ",ch," Patch ",arr["name"])
		p = arr["patch"]
		if ( typeof(p) != "phrase" ) {
			print("No phrase in patch arr=",arr)
			return()
		}
		realtime(arr["patch"])
		$.lastpatcharr3[cl] = $.lastpatcharr2[cl]
		$.lastpatcharr2[cl] = $.lastpatcharr1[cl]
		$.lastpatcharr1[cl] = arraycopy(arr)
		$.resetafterpatchchange(cl)
	}
}
method throttlepatchprev(cl) {

	# Don't sent patch changes too often
	if ( $.lastpatchtime[cl] < (Now-1b/2) ) {

		$.lastpatchtime[cl] = Now

		ch = $.colorchan[cl]
		arr = $.lastpatcharr2[cl]
		if ( sizeof(arr) != 0 ) {
			$.lastpatcharr1[cl] = $.lastpatcharr2[cl]
			$.lastpatcharr2[cl] = $.lastpatcharr3[cl]
			$.lastpatcharr3[cl] = []
			print("Ch ",ch," Patch ",arr["name"])
			realtime(arr["patch"])
			$.resetafterpatchchange(cl)
		}
	}
}
method dobreakout(v) {
	$.breakout = v
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

method sendvol(cl) {
	realtime(chanvolchange($.colorchan[cl],$.colorvol[cl]))
}
method durshorter(v) {
	$.duredit(v,0)
}
method durlonger(v) {
	$.duredit(v,1)
}
method duredit(v,longer) {
	for ( cl in $.colorbuttpressed ) {
		ch = $.colorchan[cl]
		d = $.colordur[cl]
		if ( longer ) {
			d *= 2.0
			if ( d > 16.0 )
				d = 16.0
		} else {
			d /= 2.0
			if ( d < 0.25 )
				d = 0.25
		} 
		if ( d != $.colordur[cl] ) {
			$.colordur[cl] = d
# print("dur change = ",d)
		}
	}
}
method volreset(v) {
	$.voledit(v,-1)
}
method volup(v) {
	$.voledit(v,1)
}
method voldown(v) {
	$.voledit(v,0)
}
method voledit(v,up) {
	for ( cl in $.colorbuttpressed ) {
		ch = $.colorchan[cl]
		v = $.colorvol[cl]
		if ( up == 1 ) {
			v += 10
			if ( v > 127 )
				v = 127
		} else if ( up == 0 ) {
			v -= 10
			if ( v < 0 )
				v = 0
		} else {
			v = $.defaultvol
		}
		if ( v != $.colorvol[cl] ) {
			$.colorvol[cl] = v
print("vol change=",v," cl=",cl)
			$.sendvol(cl)
		}
	}
}
method file0(v) {
	$.filenum = 0
}
method file1(v) {
	$.filenum = 1
}
method file2(v) {
	$.filenum = 2
}
method file3(v) {
	$.filenum = 3
}
method buttonchange(jn,nm,v) {
	# print("method buttonchange called jn=",jn," nm=",nm," v=",v)

	if ( nm == "SELECT" || nm == "START" ) {
		if ( nm == "SELECT" ) {
			$.selectdown = v
			if ( $.selectdown ) {
				$.desc1 = $.editmeths["DESC"]
			} else {
				# If edit mode is same as when we
				# first pressed, print current mode
				if ( $.desc1 != "" && $.editmeths["DESC"] == $.desc1 ) {
					print("EDIT MODE: ",$.desc1)
					$.desc1 = ""
				}
			}
			

			if ( $.startdown )
				realtime(ano())
		} else {
			$.startdown = v
			if ( $.selectdown )
				realtime(ano())
		}
		return()
	}
	# if ( nm == "L2" ) {
	# 	$.shiftdown = v
	# 	return()
	# }
	if ( nm in $.butt2color ) {
		# One of the buttons that activates the 3 colors was pressed
		cl = $.butt2color[nm]
		if ( v ) {
			$.colorbuttpressed[cl] = v
		} else {
			# If "lockballs" is on, then we ignore any
			# attempt to turn them off
			if ( ! ($.lockballson) ) {
				delete $.colorbuttpressed[cl]
			}
		}
		return()
	}
	if ( $.selectdown ) {
		# If the select button is down, then the
		# edit buttons control the edit mode
		if ( v == 1 && nm in $.selecteditmodes ) {
			$.editmeths = $.selecteditmodes[nm]
			print("EDIT MODE: ",$.editmeths["DESC"])
		}
		return()
	}
	if ( $.startdown ) {
		if ( v == 1 && nm in $.starteditmodes ) {
			$.editmeths = $.starteditmodes[nm]
			print("EDIT MODE: ",$.editmeths["DESC"])
		}
		return()
	}
	if ( nm in $.editmeths ) {
		meth = $.editmeths[nm]
		if ( meth != "" ) {
			$.(meth)(v,nm)
		}
		return()
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
	nm = "ANALOG"+nm
	if ( nm in $.editmeths ) {
		meth = $.editmeths[nm]
		if ( meth != "" ) {
			$.(meth)(v,nm)
		}
		return()
	}
}
method joyval2control(v,c) {
	c = c + 5 * $.joyvalquant(v)
	if ( c < 0 )
		c = 0
	if ( c > 127 )
		c = 127
	return(c)
}
method reverbtime(v,nm,amount) {
	$.reverbtimeval = $.joyval2control(v,$.reverbtimeval)
print("revtimeval=",$.reverbtimeval)
	p = midibytes( 0xb0, 91, $.reverbtimeval )
	p.port = $.effectport
	realtime(p)
}
method reverbeffect(v,nm,amount) {
	$.reverbeffectval = $.joyval2control(v,$.reverbeffectval)
print("reveffectval=",$.reverbeffectval)
	p = midibytes( 0xb0, 92, $.reverbeffectval )
	p.port = $.effectport
	realtime(p)
}
method delayfeedback(v,nm,amount) {
	$.delayfeedbackval = $.joyval2control(v,$.delayfeedbackval)
print("delayfeedbackval=",$.delayfeedbackval)
	p = midibytes( 0xb0, 81, $.delayfeedbackval )
	p.port = $.effectport
	realtime(p)
}
method delayeffect(v,nm,amount) {
	$.delayeffectval = $.joyval2control(v,$.delayeffectval)
print("delayeffectval=",$.delayeffectval)
	p = midibytes( 0xb0, 82, $.delayeffectval )
	p.port = $.effectport
	realtime(p)
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
	# print("mazetask start")
	tm = Now
	tm = nextquant(tm,$.startquant)
	while ( 1 ) {
		sleeptill(tm-2)
		if ( $.joyon == 0 ) {
			$.moveballs("r")
			$.moveballs("g")
			$.moveballs("b")
		} else {
			if ( "r" in $.colorbuttpressed )
				$.moveballs("r")
			if ( "g" in $.colorbuttpressed )
				$.moveballs("g")
			if ( "b" in $.colorbuttpressed )
				$.moveballs("b")
		}
		tm += $.movesize
	}
}
method delete {
	kill($.tid)
	MazeTool = $0
}
method resize (sz) {
			if ( nargs() > 0 )
				$.w.resize(sz)
			$.dy = $.textheight() + 5
			tw = $.textwidth()

			ym2 = $.ymin() + 2

			$.dx = $.textwidth()*2
			$.x0a = $.xmin() + 2 + 4*$.dx
			cln = 0

			y0 = $.ymin()+$.dy
			ddy = ($.ymax()-2-y0)/3
			y0a = y0+ddy
			y0b = y0+2*ddy
			y0c = $.ymax()-2

			x0 = $.xmin()+2
			for ( n=0; n<sizeof($.orderedcolors); n++ ) {
				cl = $.orderedcolors[n]
				x0a = x0 + $.dx

				x1 = $.xmin()+(cln+1)*$.dx-1
				$.decayslider[cl].resize(
					xy(x0,y0,x0a,y0a-3))
				$.volslider[cl].resize(
					xy(x0,y0a+3,x0a,y0b-3))
				$.energyslider[cl].resize(
					xy(x0,y0b+3,x0a,y0c))
				cln++
				x0 = x0a
			}

			$.redbutt.resize(xy($.xmin()+2,ym2,
				$.xmin()+$.dx-1,$.ymin()+$.dy-2))
			$.greenbutt.resize(xy($.xmin()+$.dx+1,ym2,
				$.xmin()+2*$.dx-1,$.ymin()+$.dy-2))
			$.bluebutt.resize(xy($.xmin()+2*$.dx+1,ym2,
				$.xmin()+3*$.dx-1,$.ymin()+$.dy-2))

			$.gridsize = xy($.x0a+2,$.ymin()+$.dy,
					$.xmax()-3,$.ymax()-2)
			$.grid.resize($.gridsize)
			$.griddx = $.gridsize["x1"] - $.gridsize["x0"]
			$.griddy = $.gridsize["y1"] - $.gridsize["y0"]

			$.xm = $.xmin() + ($.xmax()-$.xmin())/3
			if ( $.xm < ($.xmax()-28*tw) )
				$.xm = ($.xmax()-28*tw)

			$.xmdx = ($.xmax() - $.xm)/8


			$.mapbutt.resize(xy($.xm+1*$.xmdx+1,ym2,
				$.xm+2*$.xmdx-1,$.ymin()+$.dy-2))
			$.onoffbutt.resize(xy($.xm+2*$.xmdx+1,ym2,
				$.xm+3*$.xmdx-1,$.ymin()+$.dy-2))
			$.chanbutt.resize(xy($.xm+3*$.xmdx+1,ym2,
				$.xm+4*$.xmdx-1,$.ymin()+$.dy-2))
			$.filebutt.resize(xy($.xm+4*$.xmdx+1,ym2,
				$.xm+5*$.xmdx-1,$.ymin()+$.dy-2))
			$.clearbutt.resize(xy($.xm+5*$.xmdx+1,ym2,
				$.xm+6*$.xmdx-1,$.ymin()+$.dy-2))
			$.joybutt.resize(xy($.xm+6*$.xmdx+1,ym2,
				$.xm+7*$.xmdx-1,$.ymin()+$.dy-2))
			$.more.resize(xy($.xm+7*$.xmdx+1,ym2,
				$.xmax()-2,$.ymin()+$.dy-2))
		}
method redraw {
		lock($)
		$.w.redraw()
		colorset($.wallcolor)
		$.w.textcenter("JoyBalls",xy($.xmin(),$.ymin(),
				$.xm,$.ymin()+$.dy))
		x0c = $.xmin() + 2 + 3*$.dx
		x0d = $.xmin() + 2 + 4*$.dx
		y0 = $.ymin()+$.dy
		ddy = ($.ymax()-2-y0)/3
		y0a = y0+ddy
		y0b = y0+2*ddy
		y0c = $.ymax()-2
		th = $.textheight()

		$.w.textcenter("D",xy(x0c,y0-th,x0d,y0a-1-th))
		$.w.textcenter("C",xy(x0c,y0,x0d,y0a-1))
		$.w.textcenter("Y",xy(x0c,y0+th,x0d,y0a-1+th))

		$.w.textcenter("V",xy(x0c,y0a+1-th,x0d,y0b-1-th))
		$.w.textcenter("E",xy(x0c,y0a+1,x0d,y0b-1))
		$.w.textcenter("L",xy(x0c,y0a+1+th,x0d,y0b-1+th))

		$.w.textcenter("N",xy(x0c,y0b+1-th,x0d,y0c-th))
		$.w.textcenter("G",xy(x0c,y0b+1,x0d,y0c))
		$.w.textcenter("Y",xy(x0c,y0b+1+th,x0d,y0c+th))

		methodbroadcast()
		$.w.rectangle($.gridsize)
		$.erasewalls()
		$.drawballs()
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
				$.grid.drawwallright(r,c,CLEAR)
			} else {
				colorset($.wallcolor)
				$.grid.drawwallright(r,c,STORE)
			}
		} else if ( ms["button"] == 1 && r < ($.nrows-1) ) {
			# toggle the bottom wall
			$.wallbottom[r][c] = addit
			if ( $.wallbottom[r][c] == 0 ) {
				$.grid.drawwallbottom(r,c,CLEAR)
			} else {
				colorset($.wallcolor)
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
			$.drawball(b,CLEAR)
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

	$.addball($.currentcolor,r,c,initfx,initfy)
	unlock($)
}

method addball(cl,r,c,initfx,initfy) {
	# print("addball cl=",cl)
	if ( cl != "r" && cl != "g" && cl != "b" ) {
		print("Hey, addball can't handle cl=",cl)
		return()
	}
	# find any balls already in that cell
	found = -1
	freeslot = -1
	laston = -1
	for ( n=0; n<$.colorlimit[cl]; n++ ) {
		b = $.ball[cl][n]
		if (b["on"]==0) {
			freeslot = n
			break
		}
		laston = n
		if ( b["row"]==r && b["col"]==c )
			found = n
	}
	if ( freeslot < 0 ) {
		# Erase 0th one and shift others down
		$.drawball($.ball[cl][0],CLEAR)

		lim = $.colorlimit[cl]
		for ( n=1; n<lim; n++ )
			$.ball[cl][n-1] = $.ball[cl][n]
		freeslot = lim-1
	}
	n = freeslot
	$.ball[cl][n] = []
	b = $.ball[cl][n]
	b["on"] = 1
	b["row"] = r
	b["col"] = c

	bxy = $.fxy2xy(initfx,initfy)
	$.updateball(b,initfx,initfy,bxy["x"],bxy["y"])

	b["dfx"] = 1.0
	b["dfy"] = 1.0
# print("NEW ball b=",b," in slot n=",n)
	colorset($.colorindex[cl])
	$.drawball(b,STORE)
	colorset(1)
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
		$.drawball(b,CLEAR)
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
		oldlim = $.colorlimit[cl]
		n = v
		while ( (n in $.ball[cl]) && $.ball[cl][n]["on"] ) {
			$.deleteball(cl,n)
		}
		$.colorlimit[cl] = v
	}
	unlock($)
}

method setmovesize(n) {
	$.onoff(0)
	$.movesize = n
	$.onoff(1)
}
method setscale(k,s,nstarts) {
	if ( nargs() < 3 )
		nstarts = 1
	sc = completescale(k,s)
	sc = step(sc,$.playquant)
	arr = splitonstarts(sc,0,nstarts)
	$.setfromarr(arr,1)
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
	$.setfromphrase(readmf(fname),nstarts)
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
	$.setfromarr(arr,1)
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

function mkmenu_joyballs_1(o,po) {
	o.submenu("Grid Size   ->","mkmenu_joyballs_gridsize",po)
	o.submenu("Rand Walls  ->","mkmenu_joyballs_randwalls",po)
	o.submenu("Move Freq   ->","mkmenu_joyballs_size",po)
	o.submenu("Play Quant  ->","mkmenu_joyballs_playquant",po)
	o.submenu("Moving Limit->","mkmenu_joyballs_moving",po)
	o.submenu("From Scale  ->","mkmenu_joyballs_key",po)
	o.submenu("Breakout    ->","mkmenu_joyballs_breakout",po)
	# o.submenu("Joystick    ->","mkmenu_joyballs_joynum",po)
	o.menucmd("From File (1 note/wall)",po,"readfile",1)
	o.menucmd("From File (2 notes/wall)",po,"readfile",2)
	o.menucmd("From File (3 notes/wall)",po,"readfile",3)
	o.menucmd("From Snarf (1 note/wall)",po,"setfromsnarf",1)
	o.menucmd("From Snarf (2 notes/wall)",po,"setfromsnarf",2)
	o.menucmd("From Snarf (3 notes/wall)",po,"setfromsnarf",3)
	o.menucmd("Debug Print",po,"debugprint")
	o.menucmd("All Walls Up",po,"allwallsup",1)
}
function mkmenu_joyballs_breakout(o,po) {
	o.menucmd("on",po,"dobreakout",1)
	o.menucmd("off",po,"dobreakout",0)
}
function mkmenu_joyballs_randwalls(o,po) {
	o.menucmd("10%",po,"allwallsrand",1,0.1)
	o.menucmd("20%",po,"allwallsrand",1,0.2)
	o.menucmd("50%",po,"allwallsrand",1,0.5)
}
function mkmenu_joyballs_key(o,po) {
	o.submenu("C","mkmenu_joyballs_scale",po,'c')
	o.submenu("C#","mkmenu_joyballs_scale",po,'c+')
	o.submenu("D","mkmenu_joyballs_scale",po,'d')
	o.submenu("D#","mkmenu_joyballs_scale",po,'d+')
	o.submenu("E","mkmenu_joyballs_scale",po,'e')
	o.submenu("F","mkmenu_joyballs_scale",po,'f')
	o.submenu("F#","mkmenu_joyballs_scale",po,'f+')
	o.submenu("G","mkmenu_joyballs_scale",po,'g')
	o.submenu("G#","mkmenu_joyballs_scale",po,'g+')
	o.submenu("A","mkmenu_joyballs_scale",po,'a')
	o.submenu("A#","mkmenu_joyballs_scale",po,'a+')
	o.submenu("B","mkmenu_joyballs_scale",po,'b')
}
function mkmenu_joyballs_scale(o,po,k) {
	o.menucmd("Ionian",po,"setscale",k,"ionian")
	o.menucmd("Dorian",po,"setscale",k,"dorian")
	o.menucmd("Phrygian",po,"setscale",k,"phrygian")
	o.menucmd("Lydian",po,"setscale",k,"lydian")
	o.menucmd("Mixolydian",po,"setscale",k,"mixolydian")
	o.menucmd("Aeolian",po,"setscale",k,"aeolian")
	o.menucmd("Locrian",po,"setscale",k,"locrian")
	o.menucmd("Newage",po,"setscale",k,"newage")
	o.menucmd("Fifths",po,"setscale",k,"fifths")
}
function mkmenu_joyballs_gridsize(o,po) {
	o.menucmd("4",po,"setgridsize",4,1)
	o.menucmd("8",po,"setgridsize",8,1)
	o.menucmd("16",po,"setgridsize",16,1)
	o.menucmd("32",po,"setgridsize",32,1)
	o.menucmd("64",po,"setgridsize",64,1)
	o.menucmd("128",po,"setgridsize",128,1)
	o.menucmd("256",po,"setgridsize",256,1)
}
function mkmenu_joyballs_moving(o,po) {
	o.menucmd("1",po,"setmovinglimit",1)
	o.menucmd("2",po,"setmovinglimit",2)
	o.menucmd("4",po,"setmovinglimit",4)
	o.menucmd("8",po,"setmovinglimit",8)
	o.menucmd("12",po,"setmovinglimit",12)
	o.menucmd("16",po,"setmovinglimit",16)
}
function mkmenu_joyballs_size(o,po) {
	o.menucmd("1b",po,"setmovesize",1b)
	o.menucmd("1b/2",po,"setmovesize",1b/2)
	o.menucmd("1b/4",po,"setmovesize",1b/4)
	o.menucmd("1b/8",po,"setmovesize",1b/8)
	o.menucmd("1b/16",po,"setmovesize",1b/16)
	o.menucmd("1b/32",po,"setmovesize",1b/32)
}
function mkmenu_joyballs_joynum(o,po) {
	for ( n=0; n<8; n++ )
		o.menucmd(string(n),po,"setjoynum",n)
}
function mkmenu_joyballs_playquant(o,po) {
	o.menucmd("2b",po,"setplayquant",2b)
	o.menucmd("1b",po,"setplayquant",1b)
	o.menucmd("1b/2",po,"setplayquant",1b/2)
	o.menucmd("1b/4",po,"setplayquant",1b/4)
	o.menucmd("1b/8",po,"setplayquant",1b/8)
	o.menucmd("1b/16",po,"setplayquant",1b/16)
	o.menucmd("1b/32",po,"setplayquant",1b/32)
}
