#
# ergox - playing with letters and fingers
#

INCDEC_MID = 0
INCDEC_MIN = -2
INCDEC_MAX = 2
INCDEC_INC = 1
INCDEC_DEC = -1
TypoDebug = 0
ErgoDebug = 1
ErgoNotes = 1

#define xxx rereadlib();bbq()

function bbq {
	ergox("c:\\local\\midi\\tjt\\26mix30_8.tp",1)
}

function actionmf {
	return(readmf("c:\\local\\midi\\tjt\\actionseries\\actionseries.mid"))
}

function ergox(timer) {

	if ( ! defined(ErgoRestart) ) {
		ErgoRestart = -1
	}

	tempo(500000)

	if ( Machine != "win" ) {
		print("ergox() only works on Windows, sorry!")
		return()
	}

	if ( ! defined(Cs32output) ) {
		print("ergox() needs Cs32output to be defined!")
		return()
	}

	if ( ! defined(SalvationOutput) ) {
		SalvationOutput = -1
	}

	if ( nargs() < 2 )
		timer = 0

	if ( ! defined(ErgoOutput) ) {
		ErgoOutput = -1
	}
	Cs32debug = 0
	Cs32debug2 = 0

	global GestureDevMap
	GestureDevMap = []

	# if ( ! defined(GestureDevMap) ) {
	# GestureDevMap = []
	# 	# GestureDevMap = [0=0,1=1,2=2,3=3]
	# }

	# print("Setting dragthreshold to 0...")
	Gesturedragthreshold = 0.05

	if ( defined(TypoGM) && TypoGM == 1) {
		print("Sending gmresetall")
		realmidi(gmresetall(0x40))
	}

	patchprefix = "patch"

	t = new mastertypo(patchprefix)
	t.start()
	print("TOUCH ALL THREE PADS IN ORDER...")
	t.waittilldone()
	t.stop()

	if ( ErgoRestart >= 0 ) {
		# print("RESTARTING ERGOX!")
		# task ergox()
		exit(0)
	}
}

class mastertypo {

method init(patchprefix) {

	$.oldMerge = Merge
	Merge = 0

	mfname = "c:\\local\\midi\\tjt\\actionseries\\actionseries.mid"

	$.videoslider2ctrl =  [
		0=2,1=4,2=6,3=8,4=10,5=12,6=14,7=16,
		8=22,9=24,10=26,11=28,12=30,13=32,14=34,15=36]

	$.playing = [0=-1,1=-1,2=-1]
	$.videoffparamvals = []
	$.videolfoparamvals = []
	$.videoffselectvals = []
	for ( n=0; n<=3; n++ ) {
		$.videoffselectvals[n] = 0
	}
	for ( srow=0; srow<=1; srow++ ) {
		for ( stp=0; stp<=15; stp++ ) {
			ct = $.video_ctrl(srow,stp)
			$.videoffparamvals[ct] = 0
			$.videolfoparamvals[ct] = 0
		}
	}

	$.patchprefix = patchprefix
	$.currchan = 1

	$.dragisdown = 1
	$.stopme = 0

	$.chord = ''
	$.nextchord = ''
	$.chordactive = 1
	$.chordgathering = 1
	$.chordgathering = 0
	$.videomode = 0
	$.videoffselectmode = 0
	$.videolfomode = 0
	$.videolfotask = -1
	$.selectA = 1
	$.selectB = 2

	$.gridrows = 3
	$.gridcols = 3

	$.gridrows = 20
	$.gridcols = 20

	$.gridrows = 7
	$.gridcols = 20

	$.nphrases = $.gridrows * $.gridcols

	# Channels 4/7 map to controllers 110-113, for effects on channel 1 
	# Channels 5/8 map to controllers 114-117, for effects on channel 2
	$.chan2controllers = [
		4 = ["chan"=8,"x"=110,"y"=111],
		5 = ["chan"=8,"x"=114,"y"=115]
		# 7 = ["chan"=8,"x"=112,"y"=113],
		# 8 = ["chan"=8,"x"=116,"y"=117]
		]

	$.Quant = 1b/4
	$.loopquant = 8b
	$.quit = 0
	$.debug = 0
	$.lasttouchwarn = 0

	$.ergox = []
	$.fifos = []

	$.shiftisdown = 0

	# If shiftpolarity is 0, then you need to hold down
	# the SHIFT key in order to be recording notes.
	# If you set shiftpolarity to 1, then recording will be on
	# by default (and holding down shift will cause it to NOT record)
	$.shiftpolarity = 0

	$.nletters = 0

	$.charproc = 0
	$.ignorenextup = 0
	$.ctrl = 0

	$.globalparams = [
	   "realxposemode" = ["row"=0,"strp"=9,"control"="toggle","default"=0,"type"="music"],
	   "lfospeed" = ["row"=0,"strp"=9,"control"="slider","default"=64,"type"="video"]
	]

	$.globalvals = []
	gparams = $.globalparams
	for ( nm in gparams ) {
		$.globalvals[nm] = gparams[nm]["default"]
	}

	$.params = [

	   "chordornament" = ["type"="music","control"="musicvalue"],
	   "loopxpose" = ["type"="music","control"="musicvalue"],
	   "completescale" = ["type"="music","control"="musicvalue"],

	   # music controls in first three rows of toggles
	   "recording" = ["type"="music","row"=0,"strp"=4,"control"="toggle","default"=0],
	   "fadeenable" = ["type"="music","row"=1,"strp"=4,"control"="toggle","default"=0],
	   "fadefast" = ["type"="music","row"=2,"strp"=4,"control"="toggle","default"=0],

	   "mono" = ["type"="music","row"=0,"strp"=5,"control"="toggle","default"=0],
	   "quantdiv" = ["type"="music","row"=1,"strp"=5,"control"="toggle","default"=0],
	   "killonup" = ["type"="music","row"=2,"strp"=5,"control"="toggle","default"=1],

	   "longdur" = ["type"="music","row"=0,"strp"=6,"control"="toggle","default"=0],
	   "ornamode" = ["type"="music","row"=1,"strp"=6,"control"="toggle","default"=0],
	   "ornastep" = ["type"="music","row"=2,"strp"=6,"control"="toggle","default"=0],

	   # music parameters
	   "grabmode" = ["type"="music","row"=2,"strp"=9,"control"="toggle","default"=0],
	   "loopxposemode" = ["type"="music","row"=1,"strp"=9,"control"="toggle","default"=0],

	   "pos" = ["type"="music","row"=0,"strp"=15,"control"="chorded","inc"="advance_pos","dec"="rewind_pos","set"="set_pos","get"="get_pos","reset"="reset_pos","chan"="all"],
	   "program" = ["type"="music","row"=1,"strp"=15,"control"="chorded","default"=0,"set"="set_program","get"="get_program","rand"="rand_program"],

	   "chanpitch1" = ["type"="music","row"=0,"strp"=14,"control"="chorded","adjust"="adjust_xpose","arg"=1,"reset"="reset_xpose"],
	   "chanpitch12" = ["type"="music","row"=1,"strp"=14,"control"="chorded","adjust"="adjust_xpose","arg"=12,"reset"="reset_xpose"],

	   "allpitch1" = ["type"="music","row"=0,"strp"=13,"control"="chorded","adjust"="adjust_xpose","arg"=1,"chan"="all","reset"="reset_xpose"],
	   "allpitch5" = ["type"="music","row"=1,"strp"=13,"control"="chorded","adjust"="adjust_xpose","arg"=5,"chan"="all","reset"="reset_xpose"],
	   "allpitch7" = ["type"="music","row"=2,"strp"=13,"control"="chorded","adjust"="adjust_xpose","arg"=7,"chan"="all","reset"="reset_xpose"],

	   "tempo" = ["type"="music","row"=0,"strp"=12,"control"="chorded","set"="set_tempo","default"=500000,"inc"="inc_tempo","dec"="dec_tempo"],
	   "quant" = ["type"="music","row"=1,"strp"=12,"control"="chorded","set"="set_quant","get"="get_quant","default"=$.Quant,"inc"="inc_quant","dec"="dec_quant"],
	   "length" = ["type"="music","row"=2,"strp"=12,"control"="chorded","get"="get_length","set"="set_length","inc"="inc_length","dec"="dec_length","default"=8b],

	   "slowness" = ["type"="music","row"=2,"strp"=11,"control"="chorded","default"=1,"set"="set_slowness","get"="get_slowness","inc"="inc_slowness","dec"="dec_slowness"],

	   # music actions
	   "killloopnow" = ["type"="music","row"=2,"strp"=14,"control"="1chanaction","method"="killloopnow"],

	   "typo_restart" = ["type"="music","row"=2,"strp"=15,"control"="allchanaction","method"="typo_restart"],

	   "change_comb" = ["type"="music","row"=0,"strp"=10,"control"="1chanaction","method"="change_comb"],
	   "change_combonbeat" = ["type"="music","row"=1,"strp"=10,"control"="1chanaction","method"="change_combonbeat"],
	   "change_shuffle" = ["type"="music","row"=2,"strp"=10,"control"="1chanaction","method"="change_shuffle"],

	   "change_combonbeat2" = ["type"="music","row"=1,"strp"=11,"control"="1chanaction","method"="change_combonbeat2"],

	   # graphic controls in row 3/4/5 of toggles
	   "env1polarity" = ["type"="graphic","row"=3,"strp"=12,"control"="toggle","default"=0],
	   "env2polarity" = ["type"="graphic","row"=3,"strp"=13,"control"="toggle","default"=0],
	   "env3polarity" = ["type"="graphic","row"=3,"strp"=14,"control"="toggle","default"=0],
	   "env4polarity" = ["type"="graphic","row"=3,"strp"=15,"control"="toggle","default"=0],
	   "mirrored" = ["type"="graphic","row"=4,"strp"=0,"control"="toggle","default"=0],
	   "moving" = ["type"="graphic","row"=4,"strp"=1,"control"="toggle","default"=0],
	   "colorchanging" = ["type"="graphic","row"=4,"strp"=2,"control"="toggle","default"=0],
	   "poswalk" = ["type"="graphic","row"=4,"strp"=3,"control"="toggle","default"=0],
	   "autodir" = ["type"="graphic","row"=4,"strp"=4,"control"="toggle","default"=0],
	   "moveable" = ["type"="graphic","row"=4,"strp"=5,"control"="toggle","default"=0],
	   "magnet" = ["type"="graphic","row"=4,"strp"=6,"control"="toggle","default"=0],
	   "vstaction" = ["type"="graphic","row"=4,"strp"=7,"control"="toggle","default"=0],
	   "drawaction" = ["type"="graphic","row"=5,"strp"=0,"control"="toggle","default"=0],
	   "midiaction" = ["type"="graphic","row"=5,"strp"=1,"control"="toggle","default"=1],
	   "colorfast" = ["type"="graphic","row"=5,"strp"=2,"control"="toggle","default"=0],
	   "autoang" = ["type"="graphic","row"=5,"strp"=3,"control"="toggle","default"=0],
	   "posnoise" = ["type"="graphic","row"=5,"strp"=4,"control"="toggle","default"=0],
	   "vertexnoise" = ["type"="graphic","row"=5,"strp"=5,"control"="toggle","default"=0],
	   "initialnoise" = ["type"="graphic","row"=5,"strp"=6,"control"="toggle","default"=0],
	   "dir1" = ["type"="graphic","row"=5,"strp"=7,"control"="toggle","default"=0],
	   "dir2" = ["type"="graphic","row"=5,"strp"=8,"control"="toggle","default"=0],
	   "angdir" = ["type"="graphic","row"=5,"strp"=9,"control"="toggle","default"=0],

	   # row 0 sliders (for music)
	   "volume0" = ["type"="music","row"=0,"strp"=0,"control"="slider","default"=0.5,"ctrl"=110,"chan"=9],
	   "volume1" = ["type"="music","row"=0,"strp"=1,"control"="slider","default"=0.5,"ctrl"=111,"chan"=9],
	   "volume2" = ["type"="music","row"=0,"strp"=2,"control"="slider","default"=0.5,"ctrl"=112,"chan"=9],
	   "fx0" = ["type"="music","row"=0,"strp"=3,"control"="slider","default"=0.5,"ctrl"=113,"chan"=9],
	   "fx1" = ["type"="music","row"=0,"strp"=4,"control"="slider","default"=0.5,"ctrl"=114,"chan"=9],

	   "volume" = ["type"="music","row"=0,"strp"=5,"control"="slider","default"=0.5,"ctrl"=7,"chan"=9],
	   "varyvol" = ["type"="music","row"=0,"strp"=6,"control"="slider","default"=0.0],
	   "varypitch" = ["type"="music","row"=0,"strp"=7,"control"="slider","default"=0.0],

	   # row 0 sliders (for graphics)
	   "timefactor" = ["type"="graphic","row"=0,"strp"=10,"control"="slider","default"=0.5],
	   "magnetfactor" = ["type"="graphic","row"=0,"strp"=11,"control"="slider","default"=0.5],
	   "env1" = ["type"="graphic","row"=0,"strp"=12,"control"="slider","default"=0.0],
	   "env2" = ["type"="graphic","row"=0,"strp"=13,"control"="slider","default"=0.0],
	   "env3" = ["type"="graphic","row"=0,"strp"=14,"control"="slider","default"=0.0],
	   "env4" = ["type"="graphic","row"=0,"strp"=15,"control"="slider","default"=0.0],

	   "shape" = ["type"="graphic","control"="graphicvalue", "default"=1],
	   "targetofenv1" = ["type"="graphic","control"="graphicvalue", "default"=0],
	   "targetofenv2" = ["type"="graphic","control"="graphicvalue", "default"=0],
	   "targetofenv3" = ["type"="graphic","control"="graphicvalue", "default"=0],
	   "targetofenv4" = ["type"="graphic","control"="graphicvalue", "default"=0],

	   # row 1 sliders (for graphics)
	   "speedm" = ["type"="graphic","row"=1,"strp"=0,"control"="slider","default"=0.5],
	   "speeda" = ["type"="graphic","row"=1,"strp"=1,"control"="slider","default"=0.5],
	   "velang" = ["type"="graphic","row"=1,"strp"=2,"control"="slider","default"=0.5],
	   "allsize" = ["type"="graphic","row"=1,"strp"=3,"control"="slider","default"=0.5],
	   "aspect" = ["type"="graphic","row"=1,"strp"=4,"control"="slider","default"=0.5],
	   "growfactor" = ["type"="graphic","row"=1,"strp"=5,"control"="slider","default"=0.5],
	   "alpha" = ["type"="graphic","row"=1,"strp"=6,"control"="slider","default"=0.5],
	   "movedir" = ["type"="graphic","row"=1,"strp"=7,"control"="slider","default"=0.5],
	   "spritefreq" = ["type"="graphic","row"=1,"strp"=8,"control"="slider","default"=0.5],
	   "screenfade" = ["type"="graphic","row"=1,"strp"=9,"control"="slider","default"=0.5,"global"=1],
	   "linewidth" = ["type"="graphic","row"=1,"strp"=10,"control"="slider","default"=0],
	   "noisex" = ["type"="graphic","row"=1,"strp"=11,"control"="slider","default"=0],
	   "noisey" = ["type"="graphic","row"=1,"strp"=12,"control"="slider","default"=0],
	   "nsprites" = ["type"="graphic","row"=1,"strp"=13,"control"="slider","default"=0.2],
	   "initang" = ["type"="graphic","row"=1,"strp"=14,"control"="slider","default"=0],
	   "hue1" = ["type"="graphic","row"=1,"strp"=15,"control"="slider","default"=0]
	]


	$.currpad = 0

	$.lastvol = []
	$.lastprox = []
	$.dragvol = 0

	npads = 3

	for ( padi=0; padi<npads; padi++ ) {
		for ( finger=0; finger<10; finger++ ) {
			uid = $.fingeruid(padi,finger)
			$.lastvol[uid] = Now
			$.lastprox[uid] = 0.0
		}
	}

	$.keyorder = "QAZWSXEDCRFVTGBYHNUJMIK,OL.";
	$.nletters = sizeof($.keyorder)

	$.ctrl_immediate_list = [
		"/" = "ctrl_info"		# Info
		# "F" = "ctrl_ano"
		]

	$.ctrl_list = [
		"O" = "ctrl_offset",		# Offset
		"Q" = "ctrl_quant",		# Quant
		"P" = "ctrl_pattern",		# Pattern
		"R" = "ctrl_pattern_reset",	# Pattern (reset on next loop)
		"A" = "ctrl_assign",		# Assign (to keys)
		"T" = "ctrl_transitions",	# Transitions
		"X" = "ctrl_exec",		# Xecute
		"L" = "ctrl_length",		# Length
		"W" = "ctrl_warp",		# Warp
		"I" = "ctrl_immediate"		# Immediate
	]


	$.cs32buttons = [65="f0",66="f1",67="f2",68="f3",69="f4",
			70="f5",71="f6",72="f7",73="f8",74="f9",
			75="rew",76="fwd",77="ffwd",78="stop",79="rec",
			80="scrub",81="shuttle",
			82="up",83="down",84="left",85="right"]

	$.envbuttons = ["left"=1,"up"=2,"down"=3,"right"=4]

	$.buttprimed = ""

	# Now create the loopers

	for ( n=0; n<npads; n++ ) { 

		vals = [ "chan" = n+1]
		if ( n==2 ) {
			# Drum channel
			vals["nprograms"] = 2
		} else if ( n==1 ) {
			# imposcar
			vals["nprograms"] = 20
			# Drum channel
		} else {
			# fm8
			vals["nprograms"] = 20
		}

		$.fifos[n] = open()
		ch = n+1
		# print("ONE LOOPER Quant=",$.Quant)
		$.ergox[n] = new ergox_onelooper($.fifos[n],$.Quant,ch,$.nphrases,8b,vals)
		t = $.ergox[n]

		for ( gn in $.params ) {
			prm = $.params[gn]
			if ( ! ("default" in prm) ) {
				continue
			}
			dflt = prm["default"]
			ctype = prm["control"]
			# print("Setting default value of",gn," to ",dflt)
			if ( "set" in prm ) {
				# print("Calling set method to set default for =",gn)
				t.(prm["set"])(dflt)
			} else if ( ctype == "toggle" || ctype == "chanvalue" || ctype == "graphicvalue" ) {
				vals[gn] = dflt
			} else if ( ctype == "slider" ) {
				vals[gn] = integer(127.0 * dflt)
			}
		}


		# $.ergox[n].assign_mf(mfname)
		$.ergox[n].assign_phrasescale('c')
	}

	$.clearcs32()
	$.redisplaycs32()

	print("Init done, pausing...") 
	sleeptill(Now+milliclicks(300))

	if ( ErgoRestart >= 0 ) {
		print("LOADING PATCH ",ErgoRestart," !")
		$.loadgraphicpatch(ErgoRestart)
		$.loadmusicpatch(ErgoRestart)
		$.loadvideoApatch(ErgoRestart)
		$.loadvideoBpatch(ErgoRestart)
		# ErgoRestart = -1
	}

	$.forceallpads()
	$.redisplaycs32()

	$.clicktid = -1
	$.clicktid = task $.clicktask()
}

method clicktask() {
	dt = $.loopquant
	dt = 4b
	tm = nextquant(Now,dt)
	p = 'xfb'
	p.port = ErgoOutput
	# print("clicktask p=",p)
	while ( 1 ) {
		sleeptill(tm-2)
		# print("sending midicontinue Now=",Now," loopquant=",$.loopquant)
		realtime(p,tm)
		tm += dt
	}
}

method isvideoparam(nm) {
	g = $.params[nm]
	if ( "video" in g ) {
		return(1)
	}
	return(0)
}

method isgraphicparam(nm) {
	g = $.params[nm]
	if ( ! ("type" in g) ) {
		print("ERROR: nm=",nm," has no 'type' value")
		return(0)
	}
	p = g["type"]
	return (p == "graphic")
	
# 	c = g["control"]
# 	if ( c == "musicvalue" ) {
# 		return(0)
# 	}
# 	if ( c == "graphicvalue" ) {
# 		return(1)
# 	}
# 	if ( (c == "toggle" && g["row"] > 2 ) ||
# 		(c == "slider" && g["row"] > 0 ) ) {
# 		return(1)
# 	} else {
# 		return(0)
# 	}
}

method ismusicparam(nm) {
	return ( ! $.isgraphicparam(nm) ) 
}

method forceallpads() {
	$.forcepadcurrent(2)
	$.forcepadcurrent(1)
	$.forcepadcurrent(0)
}

method forcepadcurrent(pn) {
	$.currpad = pn

	p = $.makecs32toggle(pn,0,1)
	p.port = Cs32output
	realtime(p)
	if ( Cs32debug ) {
		print("Cs32debug forcing pad current pn=",pn," p=",p)
	}
	$.toergo(p)

	$.padparamstoergo(pn)
}

method waittilldone {
	wait($.constid)
}

method realano() {
	realtime(ano())
}

method typo_timer() {
	minute = seconds(60)
	tm = Now
	m = 0
	while ( 1 ) {
		print("Minute: ",m)
		tm += minute
		sleeptill(tm)
		m++
	}
}

method parameterat(row,sliderow,strp) {
	for ( nm in $.params ) {
		g = $.params[nm]
		isslider = (g["control"] == "slider")
		if ( (sliderow<0 && !isslider) 
			&& g["strp"] == strp && g["row"] == row ) {
			return(nm)
		}
		if ( (sliderow>=0 && isslider)
			&& g["strp"] == strp && g["row"] == sliderow ) {
			return(nm)
		}
	}
	return("")
}

method makecs32toggle(row,strp,val) {
	if ( row == 0 ) {
		b0 = 0xbe
		b1 = 0x10
	} else if ( row == 1 ) {
		b0 = 0xbd
		b1 = 0x50
	} else if ( row == 2 ) {
		b0 = 0xbd
		b1 = 0x10
	} else if ( row == 3 ) {
		b0 = 0xbe
		b1 = 0x00
	} else if ( row == 4 ) {
		b0 = 0xbd
		b1 = 0x40
	} else if ( row == 5 ) {
		b0 = 0xbd
		b1 = 0x00
	}
	b1 = b1 | strp
	# print("makecs32toggle, b0=",b0," b1=",b1," val=",val)
	return(midibytes(b0,b1,val))
}

method makecs32slider(row,strp,val) {
	if ( row == 0 ) {
		b0 = 0xbf
		b1 = 0x10
	} else if ( row == 1 ) {
		b0 = 0xbf
		b1 = 0x00
	}
	b1 = b1 | strp
	# print("makecs32slider, b0=",b0," b1=",b1," val=",val)
	return(midibytes(b0,b1,val))
}

method start(timer) { 

	if ( nargs() < 1 ) {
		timer = 0
	}

	nt = sizeof($.ergox)
	for ( n=0; n<nt; n++ ) {
		$.ergox[n].start()
	}

	Consecho = 0
	Consupdown = 1
	$.constid = task $.cons_task()

	Midiin[$] = f = open()
	$.miditid = task $.midi_task(Midiin[$])

	# print("MIDITID = ",$.miditid)
	if ( gesturedevices() == 0 ) {
		print("Warning, no gesture pads are connected!")
	} else {
		gestureclear()
		gesturenotifyrc($,$.gridrows,$.gridcols)
	}

	if ( timer != 0 )
		$.timer = task $.typo_timer()
	else
		$.timer = -1
}

method stop {
	if ( gesturedevices() != 0 ) {
		gestureunnotify($)
	}
	$.stopme = 1
	kill($.clicktid)
	kill($.timer)
	kill($.miditid)
	kill($.constid)

	kill($.videolfotask)
	$.videolfotask = -1

	for ( n=0; n<3; n++ ) {
		if ( $.playing[n] != -1 ) {
			kill($.playing[n])
			$.playing[n] = -1
		}
	}

	nt = sizeof($.fifos)
	for ( n=0; n<nt; n++ ) {
		close($.fifos[n])
		t = $.ergox[n]
		t.stop()
	}
	Typos = -1
	if ( $.consf >= 0 ) {
		Consupdown = 0
		Consecho = 1
		Root.releaseconsole()
	}
	Merge = $.oldMerge
}

method cons_task() {
	$.consf = Root.grabconsole()
	global resetconsole
	onexit(resetconsole,$)
	while ( $.quit == 0 && (c=get($.consf)) != Eof ) {
		# print("GOT c=",c," from console")
		$.handle_console(c)
	}
}

method midi_task(f) {
	global ergox_midi_restart
	onexit(ergox_midi_restart,$)
	while ( (c=get(f)) != Eof ) {
		if ( Cs32debug ) {
			print("GOT MIDI = ",c)
		}
		if ( c.port == Cs32input ) {
			# print("GOT CS32 MIDI - ",c)
			$.handle_midi_cs32(c)
		} else {
			$.handle_midi_other(c)
		}
	}
	print("HEY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! midi_task finishes?!?")
}

method midi_restart() {
	if ( $.stopme ) {
		closemidi($)
	} else {
		print("RESTARTING midi_task!!")
		$.miditid = task $.midi_task(Midiin[$])
	}
}

method gotgesturerc(t,d,f,r,c,prox,rawx,rawy) {
	if ( ! (d in GestureDevMap) && t == "fingerup" ) {
		n = sizeof(GestureDevMap)
		GestureDevMap[d] = n
		# print("GESTUREDEVMAP of d=",d," is now ",n)
	}
	if ( sizeof(GestureDevMap) < 3 ) {
		if ( (Now-$.lasttouchwarn) > milliclicks(1000) ) {
			print("YOU NEED TO TOUCH ALL THREE PADS!!!")
			$.lasttouchwarn = Now
		}
		return()
	}
	
	d = GestureDevMap[d]
	arr = ["type"=t,"row"=r,"col"=c,"prox"=prox,"device"=d,"finger"=f]
	# print("got arr=",arr)

	$.handle_finger(t,r,c,prox,d,f,rawx,rawy)
}

method toergo(p) {
	p.time = 0
	p.port = ErgoOutput
	if ( ErgoDebug ) {
		print("toergo p=",p)
	}
	realtime(p)
}

method toergo_phrase(p) {
	p.port = ErgoOutput
	if ( ErgoDebug ) {
		print("toergo p=",p)
	}
	realtime(p)
}

method tosalvation(p) {
	if ( SalvationOutput > 0 ) {
		p.port = SalvationOutput
		p.chan = 16
		# print("To Salvation: ",p)
		realtime(p)
	}
}

method putline(f,s) {
	put(f,s)
	put(f,"\n")
}

method graphicpatchname(n) {
	return($.patchprefix + string(n) + "g.rgo")
}
method musicpatchname(n) {
	return($.patchprefix + string(n) + "m.rgo")
}
method videoApatchname(n) {
	return($.patchprefix + string(n) + "va.rgo")
}
method videoBpatchname(n) {
	# return($.patchprefix + string(n) + "vb.rgo")
	return($.patchprefix + string(n) + "va.rgo")
}

method savegraphicpatch(n) {
	fname = $.graphicpatchname(n)
	f = open(fname,"w")
	if ( f < 0 ) {
		print("Unable to open ",fname," for saving ??")
		return()
	}
	print("Saving graphic patch",n,"...")
	for ( pn=0; pn<3; pn++ ) {
		t = $.ergox[pn]
		vals = t.getvals()
		pfx = "pad "+string(pn)+" "
		# $.putline(f,pfx + "shape" + " " + string(vals["shape"]))
		for ( gn in $.params ) {
			if ( gn == "" ) {
				print("Huh? empty name in $.params?")
				continue
			}
			if ( $.isgraphicparam(gn) ) {
				$.putline(f,pfx + gn + " " + string(vals[gn]))
			}
		}
	}
	gparams = $.globalparams
	for ( gn in gparams ) {
		g = gparams[gn]
		if ( g["type"] == "graphic" ) {
			$.putline(f,"global "+gn+" "+string($.globalvals[gn]))
		}
	}
	close(f)
	$.flashcs32(2)
}

method savevideoApatch(n) {
	$.savevideopatch(n,"A")
}
method savevideoBpatch(n) {
	$.savevideopatch(n,"B")
}

method savevideopatch(n,ab) {
	if ( ab == "A" ) {
		fname = $.videoApatchname(n)
		ff1 = 0
		ff2 = 1
	} else {
		fname = $.videoBpatchname(n)
		ff1 = 2
		ff2 = 3
	}
	f = open(fname,"w")
	if ( f < 0 ) {
		print("Unable to open ",fname," for saving ??")
		return()
	}
	print("Saving video ",ab," patch",n,"...")
	$.putline(f,"videoffselect "+string(ff1)+" "+string($.videoffselectvals[ff1]))
	$.putline(f,"videoffselect "+string(ff2)+" "+string($.videoffselectvals[ff2]))

	if ( ab == "A" ) {
		srow = 0
	} else {
		srow = 1
	}

	# for ( srow=0; srow<=1; srow++ ) {
	for ( stp=0; stp<=15; stp++ ) {
		ct = $.video_ctrl(srow,stp)
		val = $.videoffparamvals[ct]
		$.putline(f,"videoffparam "+string(srow)+" "+string(stp)+" "+string(val))
		val = $.videolfoparamvals[ct]
		$.putline(f,"videolfoparam "+string(srow)+" "+string(stp)+" "+string(val))
	}
	# }

	if ( ab == "A" )
		$.putline(f,"videoselect A "+string($.selectA))
	else
		$.putline(f,"videoselect B "+string($.selectB))

	$.saveglobals(f,"video")

	# There are no video parameters, at the moment
	# for ( pn=0; pn<3; pn++ ) {
	# 	t = $.ergox[pn]
	# 	vals = t.getvals()
	# 	pfx = "pad "+string(pn)+" "
	# 	for ( gn in $.params ) {
	# 		if ( gn == "" ) {
	# 			print("Huh? empty name in $.params?")
	# 			continue
	# 		}
	# 		if ( $.isvideoparam(gn) ) {
	# 			$.putline(f,pfx + gn + " " + string(vals[gn]))
	# 		}
	# 	}
	# }
	close(f)
	$.flashcs32(2)
}

method saveglobals(f,t) {
	gparams = $.globalparams
	for ( gn in gparams ) {
		g = gparams[gn]
		if ( g["type"] == t ) {
			print("WRITING parameter gn=",gn)
			$.putline(f,"global " + gn + " " + string($.globalvals[gn]))
		}
	}
}

method loadgraphicpatch(n) {
	$.loadpatches_begin()
	$.loadpatch($.graphicpatchname(n))
	$.loadpatches_finish()
}

method loadmusicpatch(n) {
	$.loadpatches_begin()
	$.loadpatch($.musicpatchname(n))
	$.loadpatches_finish()
}

method loadmusicgraphicpatch(n) {
	$.loadpatches_begin()
	$.loadpatch($.musicpatchname(n))
	$.loadpatch($.graphicpatchname(n))
	$.loadpatches_finish()
}

method savemusicgraphicpatch(n) {
	$.savemusicpatch(n)
	$.savegraphicpatch(n)
}

method loadvideoApatch(n) {
	$.loadpatches_begin()
	$.loadpatch($.videoApatchname(n),"A")
	$.loadpatches_finish()
}

method loadvideoBpatch(n) {
	$.loadpatches_begin()
	$.loadpatch($.videoBpatchname(n),"B")
	$.loadpatches_finish()
}

method loadpatch(fname,ab) {

	if ( nargs() < 2 )
		ab = "A"
	print("LOADPATCH fname=",fname)

	f = open(fname,"r")
	if ( f < 0 ) {
		print("Unable to open ",fname," for loading??")
		return()
	}
	print("Loading patch in",fname,"...")
	while ( (line=get(f)) != Eof ) {
		w = split(line," ")
		# print("line=",line)

		if ( w[0] == "tempo" ) {
			tempo(integer(w[1]))
			continue
		}
		if ( w[0] == "quant" ) {
			print("IGNORING QUANT line!!")
			# $.quant = integer(w[1])
			continue
		}
		if ( w[0] == "global" ) {
			gn = w[1]
			gval = w[2]
			valchar1 = substr(gval,1,1)
			if ( valchar1 ~~ "[0123456789]" ) {
				$.globalvals[gn] = integer(gval)
			} else {
				$.globalvals[gn] = gval
			}
			print("READ global gn=",gn," gval=",gval," type=",typeof(gval))
			continue
		}

		if ( w[0] == "videoffparam" ) {
			sliderow = integer(w[1])
			if ( ab == "A" )
				sliderow = 0
			else
				sliderow = 1
			strp = integer(w[2])
			val = integer(w[3])
			$.video_adjust_ffparam(sliderow,strp,val)
			continue
		}
		if ( w[0] == "videolfoparam" ) {
			sliderow = integer(w[1])
			if ( ab == "A" )
				sliderow = 0
			else
				sliderow = 1
			strp = integer(w[2])
			val = integer(w[3])
			$.video_adjust_lfoparam(sliderow,strp,val)
			continue
		}
		if ( w[0] == "videoffselect" ) {
			ffsel = integer(w[1]) % 2
			if ( ab == "A" ) {
				ffseloffset = 0
			} else {
				ffseloffset = 2
			}
			strp = ffsel + ffseloffset
			print("VIDEOFFSELECT strp=",strp)
			cval = integer(w[2])
			$.video_adjust_ffselect(strp,cval)
			continue
		}
		if ( w[0] == "videoselect" ) {
			v = integer(w[2])
			if ( w[1] == "A" ) {
				$.selectA = v
				# print("LOADPATCH, selectA set to ",$.selectA)
			} else if ( w[1] == "B" ) {
				$.selectB = v
				# print("LOADPATCH, selectB set to ",$.selectB)
			} else {
				print("Unexpected line: "+line)
			}
			continue
		}

		if ( w[0] != "pad" || sizeof(w) < 4 ) {
			print("Malformed line in patch: ",line)
			continue
		}
		pn = integer(w[1])
		nm = w[2]
		if ( ! (3 in w) ) {
			print("Malformed line in patch: ",line)
			continue
		}
		valchar1 = substr(w[3],1,1)
		if ( valchar1 == "'" ) {
			for ( i=1; substr(line,i,1) != "'" && i<100; i++ ) {
				;
			}
			if ( substr(line,i,1) == "'" ) {
				val = phrase(substr(line,i+1))
			} else {
				val = ''
			}
		} else if ( valchar1 != "\"" ) {
			val = integer(w[3])
		}
		t = $.ergox[pn]
		vals = t.getvals()
		
		# print("LOADPATCH, nm=",nm)
		if ( substr(nm,1,8) == "targetof" ) {
			bp = substr(nm,9)
			# print("SAW TARGETOF!! nm=",nm,"  Calling settargetof, val=",val," typeofval=",typeof(val))
			$.settargetof(pn,bp,val,0)

			envname = "targetofenv1"
			if ( typeof(vals[envname]) == "string" ) {
				print ("Hey, targetofenv1 is a string!?")
			}
		}

		if ( (nm in $.params) && ("set" in $.params[nm]) ) {
			# print("LOADING PATCH, using set method")
			setmeth = $.params[nm]["set"]
			t.(setmeth)(val)
		}
		if ( nm == "chan" || (nm in $.params) ) {
			vals[nm] = val
		} else {
			print("Unrecognized parameter name in patch: ",nm)
		}
		# print("Set pn=",pn," nm=",nm," to ",vals[nm])
	
	}
	# print("Done loading patch, now redisplaying/forcing/etc")

	t = $.ergox[0]
	vals = t.getvals()
	# print("chordornament of 0 is ",vals["chordornament"])

	envname = "targetofenv1"
	if ( typeof(vals[envname]) == "string" ) {
		print ("Hey, targetofenv1 is a string!?")
	}

	print("Done reading patch in",fname)
	close(f)
}

method loadpatches_begin() {
	$.savecurrent = $.currpad
}

method loadpatches_finish() {
	# print("NOW IN loadpatches_finish")
	$.flashcs32(1)
	$.forceallpads()
	$.redisplaycs32()
	$.forcepadcurrent($.savecurrent)
	$.redisplaycs32()

	for ( n in $.ergox ) {
		t = $.ergox[n]
		t.finishloading()
	}
}

method savemusicpatch(n) {
	fname = $.musicpatchname(n)
	f = open(fname,"w")
	if ( f < 0 ) {
		print("Unable to open ",fname," for saving ??")
		return()
	}
	lock($)
	print("Saving music patch",n,"...")
	for ( pn=0; pn<3; pn++ ) {
		t = $.ergox[pn]
		vals = t.getvals()
		pfx = "pad "+string(pn)+" "
		$.putline(f,pfx + "chan" + " " + string(vals["chan"]))
		for ( gn in $.params ) {
			# print("Loop gn=",gn)
			if ( ! $.ismusicparam(gn) ) {
				continue
			}
			prm = $.params[gn]
			# print("   music param! gn=",gn," prm=",$.params[gn])
			ctype = prm["control"]
			if ( ctype == "toggle" || ctype == "chanvalue" ) {
				# print("Saving toggle/chanvalue, gn=",gn)
				$.putline(f,pfx + gn + " " + string(vals[gn]))
			} else if ( ctype == "chorded" && ("get" in prm) ) {
				# print("Saving chorded, gn=",gn)
				getmeth = prm["get"]
				v = t.(getmeth)()
				$.putline(f,pfx + gn + " " + string(v))
			} else if ( ctype == "musicvalue" ) {
				$.putline(f,pfx + gn + " " + string(vals[gn]))
			}
		}
	}
	gparams = $.globalparams
	for ( gn in gparams ) {
		g = gparams[gn]
		if ( g["type"] == "music" ) {
			$.putline(f,"global "+gn+" "+string($.globalvals[gn]))
		}
	}
	$.putline(f,"tempo "+string(tempo()))
	# $.putline(f,"quant "+string($.quant))
	close(f)
	$.flashcs32(2)
	unlock($)
}

method padparamstoergo(pn) {
	# print("PARAMSTOERGO pn=",pn," Need redisplay?")
	$.currpad = pn
	t = $.ergox[pn]
	vals = t.getvals()

	# The current pad is indicated in the 0th strp
	p = $.makecs32toggle(pn,0,1)
	$.toergo(p)
	# print("Sent current pad, p=",p)

	# row 3 (first 12 toggles) indicates shape
	shape = vals["shape"]
	if ( shape < 0  || shape > 11 ) {
		print("Warning, shape value > 11 ?!")
	} else {
		p = $.makecs32toggle(3,shape,1)
		# print("Sending SHAPE (",shape,") toggle to ergo p=",p)
		$.toergo(p)
	}

	# Other individual toggles/sliders
	for ( nm in $.params ) {
		g = $.params[nm]
		sub1 = substr(nm,1,8)
		if ( g["control"] == "toggle" ) {
			p = $.makecs32toggle(g["row"],g["strp"],vals[nm])
		} else if ( g["control"] == "slider" ) {
			p = $.makecs32slider(g["row"],g["strp"],vals[nm])
			# print("Slider nm=",nm," val=",vals[nm])
		} else if ( sub1 == "targetof" ) {
			# print("HANDLING targetof, current val=",vals[nm])
			bp = substr(nm,9)
			$.settargetof($.currpad,bp,vals[nm],0)
		} else {
			# print("DID NOT DO ANYTHING WITH nm=",nm)
		}
		if ( Cs32debug ) {
			print("Sending param nm=",nm," p=",p)
		}
		$.toergo(p)
	}
}

method chordchanged() {
	if ( $.globalvals["realxposemode"] ) {
		p = ($.chord) % 1
		Offsetpitch = p.pitch - 60
		print("Offsetpitch = ",Offsetpitch)
		return()
	}
	for ( n in $.ergox ) {
		t = $.ergox[n]
		t.chordchanged($.chord)
	}
}

method handle_midi_chord(c)
{
	if ( c.type == NOTEOFF ) {
		if ( Current == '' ) {
			if ( sizeof($.nextchord) > 9 ) {
				print("KILLING ALL LOOPS")
				for ( n in $.ergox ) {
					t = $.ergox[n]
					t.killloopnow()
				}
			} else if ( sizeof($.nextchord) > 5 ) {
				print("KILLING current pad loop")
				t = $.ergox[$.currpad]
				t.killloopnow()
			} else {
				if ( $.nextchord != '' ) {
					$.chord = $.nextchord
					$.chordchanged()
				}
				$.nextchord = ''
			}
			$.chordactive = 0
		}
	} else if ( c.type == NOTEON ) {
		if ( ! $.chordactive ) {
			$.chordactive = 1
			$.nextchord = ''
		}
		$.nextchord |= c
	}
			
}

method video_ctrl(sliderow,strp)
{
	ct = $.videoslider2ctrl[strp]
	if ( sliderow == 1 ) {
		ct += 40
	}
	return(ct)
}

method video_adjust_ffparam(sliderow,strp,val) {
	ct = $.video_ctrl(sliderow,strp)
	# print("video_adjust_ffparam sliderow=",sliderow," strp=",strp," ct=",ct," val=",val)
	p = controller(16,ct,val)
	$.videoffparamvals[ct] = val
	$.tosalvation(p)
}

method video_adjust_lfoparam(sliderow,strp,val) {
	ct = $.video_ctrl(sliderow,strp)
	# print("video_adjust_lfoparam sliderow=",sliderow," strp=",strp," ct=",ct," val=",val)
	p = controller(15,ct,val)
	$.videolfoparamvals[ct] = val
	# print("video_adjust_lfoparam ct=",ct," val=",val)
	# $.tosalvation(p)
}

method video_adjust_ffselect(strp,val) {
	ct = 1 + 20 * strp
	# print("video_adjust_ffselect strp=",strp," ct=",ct," val=",val)
	p = controller(16,ct,val)
	$.videoffselectvals[strp] = val
	$.tosalvation(p)
}

method handle_midi_other(c)
{
	if ( c.type == NOTEON ) {
		# print("noteon to ergo - ",c)
		if ( ErgoNotes ) {
			$.toergo(c)
		}
	}
}

method handle_midi_cs32(c)
{
	# Channels 14,15,16 are the Cs32
	if ( c.type != CONTROLLER || c.chan < 14 ) {
		# print("Sending to ergo only c=",c)

		if ( $.chordgathering ) {
			$.handle_midi_chord(c)
		} else {
			$.toergo(c)
		}
		return()
	}

	b0 = integer(subbytes(c,1,1))
	b1 = integer(subbytes(c,2,1))
	val = integer(subbytes(c,3,1))
	b1high = (b1 & 0xf0)
	row = -1
	sliderow = -1
	# print("Setting sliderow to -1")
	if ( b0 == 0xbe && b1high == 0x10 ) {
		row = 0
	} else if ( b0 == 0xbd && b1high == 0x50 ) {
		row = 1
	} else if ( b0 == 0xbd && b1high == 0x10 ) {
		row = 2
	} else if ( b0 == 0xbe && b1high == 0x00 ) {
		row = 3
	} else if ( b0 == 0xbd && b1high == 0x40 ) {
		row = 4
	} else if ( b0 == 0xbd && b1high == 0x00 ) {
		row = 5
	} else if ( b0 == 0xbf && b1high == 0x10 ) {
		sliderow = 0
	} else if ( b0 == 0xbf && b1high == 0x00 ) {
		sliderow = 1
	} else if ( b0 == 0xbf ) {
		print("HEY!!! GOT UNEXPECTED 0xbf = ",c)
		print("WEIRD MODE??")
	}

	# print("b0=",b0," b1=",b1," $.cs32buttons=",$.cs32buttons)
	if ( b0 == 0xbe && (b1 in $.cs32buttons) ) {
		butt = $.cs32buttons[b1]
		if ( val == 0 ) {
			return()
		}
		wasprimed = $.buttprimed
		$.buttprimed = butt
		# print("SETTING buttprimed = ",$.buttprimed)
		if ( butt in $.envbuttons ) {
			envbutt = $.envbuttons[butt]
			print("ENV BUTTON ",envbutt," PRESSED!")
			$.buttprimed = "env"+string(envbutt)
			$.displayenv(envbutt)
			return()
		} else if ( butt == "stop" ) {
			print("Sending all-notes-off...")
			$.realano()
			$.buttprimed = ""
			$.redisplaycs32()
		} else if ( butt == "rec" ) {
			print("CLEARING GESTUREDEVMAP!!")
			GestureDevMap = []
		} else if ( butt == "f0" ) {
		} else if ( butt == "f1" ) {
		} else if ( butt == "f2" ) {
		}
		$.toergo(c)
		return()
	}

	if ( row < 0 && sliderow < 0 ) {
		print("ignoring c=",c)
		return()
	}

	strp = b1 & 0x0f
	t = $.ergox[$.currpad]
	vals = t.getvals()
	ch = vals["chan"]

	nm = $.parameterat(row,sliderow,strp)
	if ( nm != "" ) {
		prm = $.params[nm]
		ctype = prm["control"]
	} else {
		prm = 0
		ctype = ""
	}
	# print("row=",row," sliderow=",sliderow," strp=",strp," nm=",nm)

	# Handle global sliders
	gprm = $.globalparams
	for ( gnm in gprm ) {
		arr = gprm[gnm]
		# print("GLOBAL gnm=",gnm,"  arr=",arr)
		if ( typeof(arr) != "array" ) {
			print("Hmmm, arr != array?!")
			return()
		}
		if ( arr["control"] == "slider" ) {
		    if ( arr["row"] == sliderow && strp == arr["strp"] ) {
			# print("FOUND global, gnm=",gnm)
			if ( gnm == "lfospeed" ) {
				# print("LFO SPEED! val =", val)
				$.globalvals["lfospeed"] = val
			} else {
				print("Can't handle global gnm=",gnm)
			}
			return()
		    }
		}
	}

	# Sliders get handled here
	if ( sliderow >= 0 ) {
		if ( $.videoffselectmode == 1 ) {
			# video sliders
			# print("VID FFSELECT MODE sliderow=",sliderow," slider=",strp," val=",val)
			if ( sliderow == 0 && (strp >= 0 && strp <= 3) ) {
				$.video_adjust_ffselect(strp,val)
			} else {
				print("THAT SLIDER doesn't work in FF Select mode")
			}
			return()
		}
		if ( $.videolfomode == 1 ) {
			# lfo sliders
			$.video_adjust_lfoparam(sliderow,strp,val)
			return()
		}
		if ( $.videomode == 1 ) {
			# video sliders
			$.video_adjust_ffparam(sliderow,strp,val)
			return()
		}
		if ( $.buttprimed != "" ) {
			$.buttprimed = ""
			print("Slider is clearing buttprimed")
		}
		if ( prm == 0 ) {
			print("No parameter for slider ",strp)
			return()
		}
		if ( nm != "" ) {
			vals[nm] = val
			# print("Slider nm=",nm," val=",val)
		}
		if ( ! ("type" in prm) ) {
			print("Hey, no type in prm for nm=",nm)
			return()
		}
		if ( prm["type"] == "graphic" ) {
			# graphic sliders
			if ( prm != 0 && ("global" in prm) ) {
				# print("ADJUSTING GLOBAL VALUE IN ALL PADS")
				for ( pn in $.ergox ) {
					tmpt = $.ergox[pn]
					tmpvals = tmpt.getvals()
					tmpvals[nm] = val
				}
			}
			# print("SLIDER nm=",nm," sending toergo c=",c)
			$.toergo(c)
		} else if ( prm["type"] == "music" ) {
			# music sliders
			if ( prm != 0 && ("ctrl" in prm) ) {
				ct2 = prm["ctrl"]
				ch2 = prm["chan"]
				p = controller(ch2,ct2,val)
				# print("CTRL = ",ct2," p=",p)
				realtime(p)
			}
			if ( prm != 0 && ("default" in prm) ) {
				t = $.ergox[$.currpad]
				vals = t.getvals()
				# print("SETTING MUSIC VALS[",nm,"] to ",val)
				vals[nm] = val
			}
		} else {
			print("Unknown prm[type]=",prm["type"]," for nm=",nm)
		}
		return()
	}

	# okay, it's one of the buttons in rows 0,1,2,3,4,5

	# print("IT'S NOT A GLOBAL")

	# Handle chorded buttons
	ff = ""
	bp = $.buttprimed

	# Handle envelope target setting
	if ( bp == "env1" || bp == "env2" || bp == "env3" || bp == "env4" ) {
		$.settargetof($.currpad,bp,strp)

		return()
	}

	if ( bp == "f5" ) {
		ff = "music"
	} else if ( bp == "f6" ) {
		ff = "graphic"
	} else if ( bp == "f0" ) {
		ff = "musicgraphic"
	} else if ( bp == "f2" ) {
		ff = "videoA"
	} else if ( bp == "f7" ) {
		ff = "videoB"
	}

	if ( ff != "" ) {
		$.buttprimed = ""
		if ( row >=0 && row <= 2 ) {
			fn = "load" + ff + "patch"
			n = strp + row*16
		} else if ( row >=3 && row <= 5 ) {
			fn = "save" + ff + "patch"
			n = strp + (row-3)*16
		} else {
			fn = ""
		}
		if ( fn != "" ) {
			$.(fn)(n)
			$.redisplaycs32()
			$.redisplayvideoselect()
		}
		return(1)
	}

	# Handle global toggle buttons
	gprm = $.globalparams
	for ( gnm in gprm ) {
		arr = gprm[gnm]
		# print("GLOBAL gnm=",gnm,"  arr=",arr)
		if ( typeof(arr) != "array" ) {
			print("Hmmm, arr != array?!")
			return()
		}
		if ( arr["control"] == "toggle" ) {
			if ( arr["row"] == row && strp == arr["strp"] ) {
				v = $.globalvals[gnm]
				print("previous globalvals gnm=",gnm," = ",v)
				$.globalvals[gnm] = (v==0)
				print("new globalvals gnm=",gnm," = ",$.globalvals[gnm])
				return()
			}
		}
	}

		
	if ( prm != 0 && ctype == "chorded" ) {
		$.handle_chording(row,strp,nm,prm)
		return()
	}

	# Handle normal buttons
	if ( $.buttprimed != "" ) {
		$.buttprimed = ""
		print("Normal button is clearing buttprimed")
	}

	if ( row == 5 && strp == 15 ) {
		$.videomode = (val!=0)
		print("VIDEO MODE button pressed, videomode=",val)
		return()
	}

	if ( row == 5 && strp == 11 ) {
		$.videoffselectmode = (val!=0)
		print("VIDEO FF SELECT MODE button pressed =",val)
		return()
	}
	if ( row == 4 && strp == 10 ) {
		$.videolfomode = (val!=0)
		print("VIDEO LFO MODE button pressed =",val)
		return()
	}
	if ( row == 4 && strp == 9 ) {
		$.videolfoenable(val!=0)
		return()
	}

	# Handle video buttons
	if ( row == 4 && (strp >= 12 && strp <= 14) ) {

		print("SELECT no longer works")

		# # Select A
		# whichinput = strp - 12
		# $.selectA = whichinput
		# $.tosalvation(makenote(whichinput))
		# $.redisplayvideoselect()
		return()
	}

	if ( row == 5 && (strp >= 12 && strp <= 14) ) {

		print("SELECT no longer works")

		# Select B
		# whichinput = strp - 12
		# $.selectB = whichinput
		# $.tosalvation(makenote(100+whichinput))
		# $.redisplayvideoselect()
		return()
	}
	if ( ( strp == 15 && row == 4 ) || ( strp == 11 && row == 4 ) ) {
		if ( strp == 15 ) {
			ab = "B"
			srow = 1
			ff1 = 2
			ff2 = 3
		}
		else {
			ab = "A"
			srow = 0
			ff1 = 0
			ff2 = 1
		}
		print("RAND VIDEO ",ab," !")

		$.video_adjust_ffselect(ff1,rand(127))
		$.video_adjust_ffselect(ff2,rand(127))

		for ( stp=0; stp<=15; stp++ ) {
			$.video_adjust_ffparam(srow,stp,rand(127))
		}
		$.setcs32(4,15,0)
		$.setcs32(4,11,0)
		return()
	}

	# The other lower rows (3,4,5) go either to ergo
	if ( row > 2 ) {
		# first 12 buttons of row 3 are for shape
		if ( row == 3 && strp < 12 ) {
			vals["shape"] = strp
			print("Setting shape to ",vals["shape"])
		} else if (row==3 || row==4 || row==5) {
			for ( gn in $.params ) {
				g = $.params[gn]
				if ( g["control"] == "toggle" && 
					row==g["row"] && strp==g["strp"] ) {
					vals[gn] = (val!=0)
					print("Setting",gn,"to ",vals[gn])
				}
			}
		} else {
			print("Unexpected row=",row)
		}
		$.toergo(c)
	} else if ( strp == 0 ) {
		$.currpad = row
		# Send active-pad strip to ergo
		$.toergo(c)
		$.padparamstoergo($.currpad)
	} else if ( strp == 1 ) {
		vals["chan"] = row + 1
	} else if ( strp == 2 ) {
		vals["chan"] = row + 4
	} else if ( strp == 3 ) {
		vals["chan"] = row + 7
	} else {
		if ( nm != "" )
			$.handle_musicparam(row,strp,nm,val)
		else {
			print("No name for row=",row," strp=",strp)
		}
	}
	$.redisplaycs32()
}

method runlfo() {
	x = 0.01
	print("RUNLFO START!!")
	while (1) {
		sp = $.globalvals["lfospeed"]
		x += 1.0 / (4.0 * (sp+1))
		for ( ct in $.videolfoparamvals ) {
			amount = $.videolfoparamvals[ct]
			if ( amount != 0 ) {
				v = $.videoffparamvals[ct]
				v += integer((amount/2.0) * sin(x))
				if ( v < 0 )
					v = 0
				else if ( v > 127 )	
					v = 127
				# print("lfoparam of ct=",ct," is now ",v)
				p = controller(16,ct,v)
				# $.videoffparamvals[ct] = v
				$.tosalvation(p)
			}
		}
		sleeptill(Now+4)
	}
}

method videolfoenable(onoff) {
	if ( onoff == 0 ) {
		if ( $.videolfotask >= 0 ) {
			print("KILLING videolfotask")
			kill($.videolfotask)
			$.videolfotask = -1
		}
	} else {
		if ( $.videolfotask == -1 ) {
			print("STARTING videolfotask")
			$.videolfotask = task $.runlfo()
	
		}
	}
}

method settargetof(currpad,bp,strp,redisplay)
{
	if ( nargs() < 4 ) {
		redisplay = 1
	} else {
		# print("settarget, redisplay=",redisplay)
	}
	envnum = integer(substr(bp,4,1))
	# print("======== SETTARGETOF pad=",currpad," bp=",bp," strp=",strp)
	tmpt = $.ergox[currpad]
	tmpvals = tmpt.getvals()
	tmpvals["targetof"+bp] = strp
	$.buttprimed = ""
	if ( redisplay != 0 ) {
		$.redisplaycs32()
	}
	# Create the special controller msg that communicates to ergo
	v = ( envnum << 4 ) | (strp+1)
	c = controller(13,1,v)
	# print("Special msg = ",c)
	$.toergo(c)
}

method handle_chording(row,strp,nm,prm) {

	handled = 0
	if ( ("chan" in prm) && (prm["chan"] == "all") ) {
		print("handle_chording A, buttprimed = ",$.buttprimed)
		saveprimed = $.buttprimed
		for ( n in $.ergox ) {
			t = $.ergox[n]
			$.buttprimed = saveprimed
			handled = $.handle_chording1(t,row,strp,nm,prm)
		}
	} else {
		print("handle_chording B, buttprimed = ",$.buttprimed)
		t = $.ergox[$.currpad]
		handled = $.handle_chording1(t,row,strp,nm,prm)
	}
	if ( handled == 0 ) {
		print("Nothing done for nm=",nm,", nothing primed...")
	}
	# Turn the led back off - chorded things are never lit
	$.setcs32(row,strp,0)
}

method handle_chording1(t,row,strp,nm,prm) {
		
	if ( $.buttprimed == "f4" ) {
		$.buttprimed = ""
		print("Increase value=",nm,"row=",row,"strp=",strp," prm=",prm)
		if ( "inc" in prm ) {
			# print("Using inc to increment")
			meth = prm["inc"]
			t.(meth)()
		} else if ( ("set" in prm) && ("get" in prm) ) {
			# print("Using set/get to increment")
			setmeth = prm["set"]
			getmeth = prm["get"]
			v = t.(getmeth)()
			t.(setmeth)(v+1)
		} else if ( "adjust" in prm ) {
			# print("Using adjust to increment")
			t.(prm["adjust"])(prm["arg"])
		} else {
			print("Don't know how to increase value: ",nm)
		}
		print("handle_chording1 is returning 1")
		return(1)
	}
	if ( $.buttprimed == "f3" ) {
		$.buttprimed = ""
		print("Reset value=",nm,"row=",row,"strp=",strp)
		prm = $.params[nm]
		if ( "reset" in prm ) {
			# print("Using reset")
			t.(prm["reset"])()
		} else if ( ("set" in prm) && ("default" in prm) ) {
			# print("Using set/default to reset")
			t.(prm["set"])(prm["default"])
		} else {
			print("Don't know how to reset value: ",nm)
		}
		return(1)
	}
	if ( $.buttprimed == "f8" ) {
		$.buttprimed = ""
		print("Randomize value=",nm,"row=",row,"strp=",strp)
		prm = $.params[nm]
		if ( "rand" in prm ) {
			# print("Using rand")
			t.(prm["rand"])()
		} else {
			print("Don't know how to randomize value: ",nm)
		}
		return(1)
	}
	if ( $.buttprimed == "f9" ) {
		$.buttprimed = ""
		print("Decrease",nm)
		prm = $.params[nm]
		if ( "dec" in prm ) {
			print("Using dec to decrement")
			meth = prm["dec"]
			t.(meth)()
		} else if ( ("set" in prm) && ("get" in prm) ) {
			print("Using set/get to decrement")
			setmeth = prm["set"]
			getmeth = prm["get"]
			v = t.(getmeth)()
			t.(setmeth)(v-1)
		} else if ( "adjust" in prm ) {
			print("Using adjust to decrement")
			t.(prm["adjust"])(-prm["arg"])
		} else {
			print("Don't know how to decrease value: ",nm)
		}
		return(1)
	}
	return(0)
}


method handle_musicparam(row,strp,nm,val) {

	t = $.ergox[$.currpad]
	vals = t.getvals()
	ch = vals["chan"]

	print("musicparam nm=",nm)
	paramarr = $.params[nm]
	print("musicparam paramarr=",paramarr)

	# print("paramarr=",paramarr)
	ctype = paramarr["control"]
	if ( "arg" in paramarr )
		arg = paramarr["arg"]
	else
		arg = 0
	if ( ctype == "chanvalue" ) {
		print("Handle_musicparam for nm=",nm," is doing nothing")
		return()
	}
	if ( ctype == "chorded" ) {
		print("Control ",nm," is chorded...")
		$.setcs32(row,strp,0)
		return()
	}
	if ( ctype == "allchanaction" ) {
		meth = paramarr["method"]
		print("ALLCHANACTION calling method=",meth)
		for ( n in $.ergox ) {
			t = $.ergox[n]
			t.(meth)(arg)
		}
		return()
	}
	if ( ctype == "1chanaction" ) {
		meth = paramarr["method"]
		print("1CHANACTION calling method=",meth)
		t.(meth)(arg)
		return()
	}

	print("HANDLE_MUSICPARAM!  row=",row," strp=",strp," nm=",nm," val=",val," pad=",$.currpad," ch=",ch)

	if ( nm != "" ) {
		print("MUSIC PARAM, TOGGLE!  nm=",nm," paramarr=",paramarr)
		v = (vals[nm] != 0)
		vals[nm] = 1 - v
		print("  new value of ",nm," is ",vals[nm])
		if ( "global" in paramarr ) {
			print("GLOBAL VALUE!!  needs implement")
			for ( n in $.ergox ) {
				t = $.ergox[n]
				vv = t.getvals()
				vv[nm] = vals[nm]
			}
		}
	} else if ( strp == 1 ) {
		vals["chan"] = row + 1
	} else if ( strp == 2 ) {
		vals["chan"] = row + 4
	} else if ( strp == 3 ) {
		vals["chan"] = row + 7
	} else {
		print("strp ",strp," has no meaning yet")
	}
}

method fingeruid(pad,finger) {
	return( pad * 100 + finger )
}
				
method handle_finger(ft,row,col,prox,padi,finger,rawx,rawy) {

	if ( TypoDebug ) {
		print("handle_finger ft=",ft," row/col=",row,col," fing/prox=",finger,prox)
	}
	# i = ((row * $.gridcols)+col) % ($.nletters)
	floati = ((row * $.gridcols)+col) / float($.gridrows * $.gridcols)

	uid = $.fingeruid(padi,finger)

	t = $.ergox[padi]
	vals = t.getvals()

	ch = vals["chan"]

	if ( ch in $.chan2controllers ) {
		cc = $.chan2controllers[ch]
		xv = integer(rawx * 127) % 128
		yv = integer(rawy * 127) % 128
		# print("CONTROLLER PAD!! x=",cc["x"]," xv=",xv," y=",cc["y"]," yv=",yv)
		ccch = cc["chan"]
		xp = controller(ccch,cc["x"],xv)
		yp = controller(ccch,cc["y"],yv)
		realtime(xp)
		realtime(yp)
		return()
	}
	if ( ch >= 4 ) {
		print("Ignoring ch=",ch)
		return()
	}

	normrow = integer(row - ($.gridrows/2))
	normcol = integer(col - ($.gridcols/2))

	if ( ft == "fingerdown" ) {
		# print("FINGER DOWN Now=",Now)
		keydown = 1
		tn = ch - 1
		if ( tn in $.ergox ) {
			t = $.ergox[tn]
			# t.looper_input_i(keydown,floati,prox,uid)
			t.looper_input_rc(keydown,normrow,normcol,prox,uid)
		}
	} else if ( ft == "fingerup" ) {
		keydown = 0
		tn = ch - 1
		if ( tn in $.ergox ) {
			t = $.ergox[tn]
			# t.looper_input_i(keydown,floati,prox,uid)
			t.looper_input_rc(keydown,normrow,normcol,prox,uid)
		}
	} else if ( ft == "fingerdrag" ) {
		if ( $.dragisdown ) {
			tn = ch - 1
			keydown = 0
			if ( tn in $.ergox ) {
				t = $.ergox[tn]
				# t.looper_input_i(keydown,floati,prox,uid)
				t.looper_input_rc(keydown,normrow,normcol,prox,uid)
			}
			keydown = 1
			if ( tn in $.ergox ) {
				t = $.ergox[tn]
				# t.looper_input_i(keydown,floati,prox,uid)
				t.looper_input_rc(keydown,normrow,normcol,prox,uid)
			}
		} else {

			keydown = -1

			# Find out what channel the notes attached
			# to this finger are on.

			if ( $.dragvol ) {
				dt = Now - $.lastvol[uid]
				if ( dt > 2 ) {
					v = integer((prox * prox) * 127.0 / 9.0)
					if ( v > 127 )
						v = 127
					if ( $.debug > 1 ) {
						print("fingerdrag sending vol ch=",ch," v=",v," Now=",Now)
					}
					p = controller(ch,0x0b,v)
					realtime(p)

					$.lastvol[uid] = Now
				}
			}
			$.lastprox[uid] = prox
			# print("lastprox Now=",Now," uid=",uid," prox=",prox)
		}
	}
}

method handle_console(c) {

	keydown = (substr(c,1,1) == "+" )
	c = substr(c,2)
	padi = -1
	prox = 2.0

	# print("Got console=",c)
	$.handle_chr(c,padi,prox,keydown)
}

method handle_chr(c,padi,prox,keydown) {

	if ( ! keydown ) {
		if ( c == $.ignorenextup ) {
			$.ignorenextup = 0
			return()
		}
	}

	if ( c == "DEL" ) {
		if ( keydown ) {
			print("RESETTING LOOP")
			for ( t in $.ergox ) {
				$.ergox[t].typo_restart()
			}
		}
		return()
	}

	if ( c == "CTRL" ) {
		$.ctrl = keydown
		return()
	}

	if ( $.charproc != 0 ) {
		if ( keydown ) {
			f = $.charproc
			if ( ! defined($.(f)) ) {
				print("f=",f," not defined?")
			} else {
				$.(f)(c)
			}
			# The function might have changed the
			# function as a way to grab the next character
			# If so, leave it alone
			if ( $.charproc == f )
				$.charproc = 0
			$.ignorenextup = c
		}
		return()
	}

	if ( $.ctrl ) {
		if ( c in $.ctrl_immediate_list ) {
			# Call it right away
			f = $.ctrl_immediate_list[c]
			$.(f)(0)
		} else if ( c in $.ctrl_list ) {
			# Call it afte we get the next character
			$.charproc = $.ctrl_list[c]
		}
		$.ignorenextup = c
		return()
	}

	if ( c == "END" ) {
		if ( keydown ) {
			print("Sending all-notes-off...")
			$.realano()
		}
		return()
	}	
	# Otherwise, we pass the key to whatever the current func is

	for ( n=1; n<=$.nletters; n++ ) {
		letter = substr($.keyorder,n,1)
		if ( c == letter ) {
			break
		}
	}
	if ( n <= $.nletters ) {
		floati = n / float($.nletters)
		t = $.ergox[$.currchan-1]
		t.looper_input_i(keydown,floati,prox,c)
	} else {
		print("DIDN'T find c=",c)
	}
}

method flashcs32(ntimes) {
	t = $.ergox[$.currpad]
	vals = t.getvals()
	shape = vals["shape"]
	for ( n=0; n<ntimes; n++ ) {
		for ( c=0; c<=15; c++ ) {
			$.setcs32(3,c,1)
		}
		sleeptill(Now+1b/2)
		for ( c=0; c<=15; c++ ) {
			$.setcs32(3,c,c==shape)
		}
	}
}

# method redisplayvideo() {
# 	for ( r=3; r<=5; r++ ) {
# 		for ( c=0; c<12; c++ ) {
# 			$.setcs32(r,c,0)
# 		}
# 	}
# 	$.redisplayvideoselect()
# }

method redisplayvideoselect() {
	$.setcs32(4,12,$.selectA == 0)
	$.setcs32(4,13,$.selectA == 1)
	$.setcs32(4,14,$.selectA == 2)

	$.setcs32(5,12,$.selectB == 0)
	$.setcs32(5,13,$.selectB == 1)
	$.setcs32(5,14,$.selectB == 2)
}

method displayenv(envbutt) {
	# clear everything and light a few rows of lights to indicate we're
	# showing the envelope target
	for ( r=3; r<=4; r++ ) {
		for ( c=0; c<=11; c++ ) {
			$.setcs32(r,c,1)
		}
		for ( c=12; c<=15; c++ ) {
			$.setcs32(r,c,0)
		}
	}
	r=5
	for ( c=0; c<=15; c++ ) {
		$.setcs32(r,c,0)
	}

	# show which env we're talking about, in the 3rd row, butts 12-15
	for ( c=12; c<=15; c++ ) {
		eb = c - 11
		$.setcs32(3,c,eb==envbutt)
	}

	# show it's target
	t = $.ergox[$.currpad]
	vals = t.getvals()
	print("DISPLAYENV envbutt=",envbutt)
	envname = "targetofenv" + string(envbutt)
	print("Showing envname=",envname," target=",vals[envname])
	$.setcs32(r,vals[envname],1)
}

method redisplaycs32() {

	# print("REDISPLAY CS32 for currpad=",$.currpad)
	t = $.ergox[$.currpad]
	vals = t.getvals()
	ch = vals["chan"]

	envname = "targetofenv1"
	if ( typeof(vals[envname]) == "string" ) {
		print ("Hey, targetofenv1 is a string!?")
	}

	chrow = (ch-1)%3
	chcol = integer((ch-1) / 3)

	# Show which pad is active in the first column
	for ( r=0; r<3; r++ ) {
		$.setcs32(r,0, r==$.currpad )
	}

	# The next 3 columns show which channel is assigned to that pad
	for ( r=0; r<3; r++ ) {
		$.setcs32(r,1, (r==chrow) && chcol == 0)
		$.setcs32(r,2, (r==chrow) && chcol == 1)
		$.setcs32(r,3, (r==chrow) && chcol == 2)
	}

	# clear the rest of the columns
	for ( c=5; c<=15; c++ ) {
		for ( r=0; r<3; r++ ) {
			$.setcs32(r,c, 0)
		}
	}

	# Show the current shape in row 3
	shape = vals["shape"]
	for ( c=0; c<=11; c++ ) {
		$.setcs32(3,c, c == shape)
	}

	# turn the led's on/off for all the toggle parameters
	for ( gn in $.params ) {
		g = $.params[gn]
		if ( g["control"] == "toggle" ) {
			val = vals[gn]
			# print("For gn=",gn," val=",val," row/strp=",g["row"],g["strp"])
			$.setcs32(g["row"],g["strp"],val)
			# print("Displaying toggle gn=",gn," val=",val)
		}
	}
	gparams = $.globalparams
	for ( gn in gparams ) {
		# print("Displaying global param gn=",gn)
		g = gparams[gn]
		if ( typeof(g) != "array" ) {
			print("Hmmm, globalparams of gn=",gn," not an array, g=",g)
			break
		}
		if ( g["control"] == "toggle" ) {
			val = $.globalvals[gn]
			# print("  val = ",val)
			# print("For gn=",gn," val=",val," row/strp=",g["row"],g["strp"])
			$.setcs32(g["row"],g["strp"],val)
		}
	}

}

method setcs32(row,n,v) {
	if ( v ) {
		r = $.get_cs32one(row,n,0x7f)
	} else {
		r = $.get_cs32one(row,n,0)
	}
	r.port = Cs32output
	realtime(r)
	if ( Cs32debug2 ) {
		print("Cs32debug r=",r)
	}

	# r.port = ErgoOutput
	# print("toergo setcs32 r=",r)
	# realtime(r)
}

method clearcs32(n) {
	for ( row=0; row<6; row++ ) {
		for ( n=0; n<16; n++ ) {
			$.setcs32(row,n,0)
		}
	}
}

method get_cs32one(row,n,v) {
	# print("get_cs32one, n=",n," v=",v)
	if ( n < 0 || n > 15 ) {
		print("Hey, get_cs32one got n=",n,"?")
		return('')
	}
	if ( Cs32output < 0 )
		return()
	if ( row == 3 ) {
		return(midibytes('xbe',n,v))
	} else if ( row == 4 ) {
		return(midibytes('xbd',0x40+n,v))
	} else if ( row == 5 ) {
		return(midibytes('xbd',n,v))
	} else if ( row == 0 ) {
		return(midibytes('xbe',0x10+n,v))
	} else if ( row == 1 ) {
		return(midibytes('xbd',0x50+n,v))
	} else if ( row == 2 ) {
		return(midibytes('xbd',0x10+n,v))
	} else {
		return('')
	}
}

method fakeloop(cn) {
	cn++
	print("fakeloop started chan=",cn)
	while(1) {
		p = ''
		for ( n=0; n<4; n++ ) {
			p += makenote(1+rand(127),1b,40+rand(80),cn)
		}
		$.toergo_phrase(p)
		sleeptill(Now+4b)
	}
	
}

method ctrl_exec(c,nw) {
	if ( c == "Q" ) {
		$.savegraphicpatch(99)
		$.savemusicpatch(99)
		$.savevideoApatch(99)
		$.savevideoBpatch(99)
		$.quit = 1
	} else if ( c == "1" || c=="2" || c=="3" ) {
		cn = ascii(c) - ascii("1")
		if ( $.playing[cn] == -1 ) {
			$.playing[cn] = task $.fakeloop(cn)
		} else {
			print("Killing fakeloop on chan=",cn+1)
			kill($.playing[cn])
			$.playing[cn] = -1
		}
	} else if ( c == "A" ) {
		print("ABORTING without saving...")
		$.quit = 1
	} else if ( c == "D" ) {
		Cs32debug = 1 - Cs32debug
		print("Cs32debug = ",Cs32debug)
	} else if ( c == "R" ) {
		$.savegraphicpatch(99)
		$.savemusicpatch(99)
		$.savevideoApatch(99)
		$.savevideoBpatch(99)
		ErgoRestart = 99
		$.quit = 1
	} else if ( c == "V" ) {
		$.verbose = 1 - $.verbose
	} else if ( c == "T" ) {
		if ( $.timer >= 0 )
			kill($.timer)
		$.timer = task $.typo_timer()
	}
}

method ctrl_quant(c,nw) {
	# The keys A-Z will map to offsets -12 to 12.
	q = 1
	if ( c == "H" ) {
		q = 2b
	} else if ( c == "Q" ) {
		q = 1b
	} else if ( c == "E" ) {
		q = 1b/2
	} else if ( c == "S" ) {
		q = 1b/4
	} else if ( c == "T" ) {
		q = 1b/8
	} else if ( c == "N" ) {
		q = 1
	}
	$.requant = q
}

}


class ergox_onelooper {

method init(inputf,q,ch,nphrases,initiallength,vals) {
	$.inputf = inputf
	$.quant = q
	$.currchan = ch
	$.vals = vals
	$.initiallength = initiallength
	$.loopnumber = 0
	$.vals["chordornament"] = ''
	print("Setting chordornament to ''")
	$.vals["loopxpose"] = 0
	$.typo_setup(nphrases)
	$.centerp = 'p64'
	$.rescale_from_phrase('c,e,g')
}

method finishloading() {
	$.completescalesz = sizeof($.vals["completescale"])
}

method getvals() {
	return($.vals)
}

method start() {

	$.tid = task $.realtimetask()

	$.startdown = []
	$.selectdown = []

	$.inputtid = task $.inputtask($.inputf)
}

method inputtask(f) {
	while ( (c=get(f)) != Eof ) {
		print("TYPOS_OBJECT got c=",c)
	}
}

method stop {
	kill($.inputtid)
	$.killrealtime()
}

method morenotes {
	$.nnotes++
	if ( $.nnotes > $.nnotesmax )
		$.nnotes = $.nnotesmax
}
method lessnotes {
	$.nnotes--
	if ( $.nnotes < 1 )
		$.nnotes = 1
}

method realtimetask() {
	tm = nextquant(Now,$.loopquant)
	checktime = 1b
	$.playprev = 0
	for ( ;; ) {
		t = Now
		while ( (Now+checktime) < (tm-2) ) {
			sleeptill(Now+checktime)
			# If the loop has been cleared, reset
			if ( $.tp["length"] == 0 ) {
				tm = nextquant(Now,$.loopquant)
				break
			}
		}
		sleeptill(tm-1b/4)
		if ( $.nextpattern >= 0 ) {
			$.topattern($.nextpattern)
			$.nextpattern = -1
		}
		loopleng = $.tp["length"]
		if ( loopleng < 0) {
			print("Negative loop leng? ",loopleng)
			return()
		}

		if ( loopleng == 0 ) {
			tm += $.loopquant
			continue
		}

		# There's a loop playing

		# If we've already established the length, keep track
		# of when each loop starts, so we know how to record new stuff
		if ( $.tp["length"] != 0 ) {
			# print("HEY!  length!=0 = ",$.tp["length"]," Setting loopstart to tm=",tm," me=",$," chan=",$.currchan)
			$.tp["loopstart"] = tm
		}

		# ta = $.tp["transitions"]
		# t = sizeof($.tp["transitions"])
		# if ( t > 1 ) {
		# 	print("TRANSITION is calling change_offsets!")
		# 	$.change_offset($.tp["transitions"][$.transitionpos/$.transmultiple])
		# 	$.transitionpos++
		# 	if ( $.transitionpos >= (t*$.transmultiple) )
		# 		$.transitionpos = 0
		# } else {
		# 	print("TRANSITION is calling change_offsets!")
		# 	$.change_offset($.tp["transitions"][0])
		# }

		$.loopnumber++

		# Not working
		if ( $.playprev != 0 ) {
			$.play_loop($.playprev)
			tm = $.playprev + loopleng
			$.playprev = 0
		} else {
			$.play_loop(tm)
			tm += loopleng
		}
	}
	print("HEY, REALTIMETASK LOOP broke out?")
}

method play_loop(tm) {
	# print("play_loop tm=",tm," loopphrase=",$.loopphrase)
	leng = $.tp["length"]

	# print("play_loop tm=",tm)

	p = $.loopphrase
	if ( p == '' ) {
		return()
	}
	# print("play_loop tm=",tm," p=",p)
	if ( sizeof(p) > 75 ) {
		print("HEY ************ loop is > 75 notes long?")
	}

	t = $.tp["tonality"]
	if ( t != 0 ) {
		p = scadjust(p,$.tonalscales[t])
	}

	w = $.loopphrasewarp
	if ( w != '' ) {
		p = w
	}

	fade = $.tp["loopfade"]

	# print("play_loop chan=",$.currchan," fade=",$.tp["loopfade"],"  fadeenable = ",$.vals["fadeenable"])
	if ( $.vals["fadeenable"] && (fade > 0) ) {
		# print("Fading pre = ",p)
		if ( $.vals["fadefast"] ) {
			p.vol -= (5 * fade)
		} else {
			p.vol -= (2 * fade)
		}
		# print("      post = ",p)
		p -= p{??.vol==0}
		$.loopphrase = p
	}

	if ( p != '' ) {
		# if ( $.vals["loopxpose"] != 0 ) {
		# 	p.pitch += $.vals["loopxpose"]
		# 	print("LOOPXPOS=",$.vals["loopxpose"]," p=",p)
		# }
		if ( $.looprestep != 0 ) {
			p = step(p,$.quant)
		}
		vv = $.vals["varyvol"]
		if ( vv ) {
			p2 = ''
			for ( nt in p ) {
				r = rand(vv/2)
				if ( rand(2) )
					r = -r
				nt.vol += r
				p2 |= nt
			}
			p = p2
		}
		# Don't requantize the warped stuff
		if ( w == '' && $.requant > 1 ) {
			p = quantize(p,$.requant)
		}
		p = cut(p,CUT_TIME,0,leng)
		$.looptask = $.realtime(p,tm)
		# print("Playing looptask leng=",leng," p=",p," Now=",Now)
	}
}

method killloopnow() {
	print("KILLING LOOPTASK ",$.looptask)
	$.loopphrasewarp = ''
	$.setloop('')
	kill($.looptask)
	$.looptask = -1
}

method realtime(p,tm) {
	# print("realtime p=",p," tm=",tm,"  Now=",Now)
	if ( ErgoOutput >= 0 ) {
		p2 = p
		p2 = mono(p2)
		p2.port = ErgoOutput
		# print("realtime toergo p2=",p2)
		p |= p2
	}
	t = realtime(p,tm)
	# print("method realtime t=",t)
	return(t)
}

method typoforwardall(arr,pos) {

	# print("FORWARDALL, pos=",pos)
	$.sourcepos = pos

	# The indicies of $.phr are  will be "Q", "A", "Z", ...
	# The values will be the bits of the phrase

	$.phr = []
	if ( sizeof(arr) == 0 )
		return()

	for ( n=1; n<=$.nletters; n++ ) {
		letter = substr($.keyorder,n,1)
		$.phr[n-1] = $.next_in_sourcephr()
		# if ( n<3 ) {
		# 	print("Setting phr[",n-1,"] to ",$.phr[n-1])
		# }
	}
}

method next_in_sourcephr() {
	arr = $.sourcephr
	pos = $.sourcepos + 1
	if ( ! (pos in arr) )
		pos = 0
	if ( ! (pos in arr) )
		return('')
	$.sourcepos = pos
	return(arr[pos])
}

method prev_in_sourcephr() {
	arr = $.sourcephr
	pos = $.sourcepos - 1
	if ( ! (pos in arr) )
		pos = sizeof(arr)-1
	if ( ! (pos in arr ) )
		return('')
	$.sourcepos = pos
	return(arr[pos])
}

method init_misc() {
	$.loopmode = 0
	$.ctlr = $.initial_ctlr()
	$.requant = 1
	$.octshift = 0
	$.fractality = 0
	$.durscale = 1
	$.durscalerand = $.defaultdurscalerand
	$.velocityinc = $.defaultvelocityinc
	$.velocityrand = $.defaultvelocityrand
	$.looprestep = 0

	$.setloop('')

	$.loopphrasewarp = ''
}

method setloop(p) {
	if ( sizeof(p) > 120 ) {
		p = p{rand(2)==0}
	}
	# if ( $.vals["monoloop"] ) {
	# 	print("Forcing loopphrase to be mono")
	# 	p = mono(p)
	# }
	$.loopphrase = p
}

method typo_init() {
	$.tp["loopstart"] = 0
	$.init_misc()
}

method typo_init_from_phrase(patt,p,minlength,fixedsize) {

	# print("INIT_FROM_PHRASE!  patt=",patt," minl=",minlength," fix=",fixedsize," head(30) of p=",head(p,30))
	if ( nargs() < 3 )
		minlength = 0
	if ( nargs() < 4 )
		fixedsize = 4

	p.chan = ch
	# arr = split(p)
	arr = splitonstarts(p,minlength,fixedsize)
	for ( i in arr ) {
		arr[i] = strip(arr[i])
	}
	# $.phr = $.typo[patt]["phrase"]
	$.sourcephr = $.typo[patt]["sourcephr"]
	$.sourcepos = $.typo[patt]["sourcepos"]
	$.sourcephr = arr
	$.firstpos = -1
	$.typoforwardall($.sourcephr,$.firstpos)
	global Tjt
	Tjt = arr
}

method reset_pos() {
	$.firstpos = -1
	$.typoforwardall($.sourcephr,$.firstpos)
}

method get_pos() {
	return($.firstpos)
}
method set_pos(v) {
	$.firstpos = v
	$.typoforwardall($.sourcephr,$.firstpos)
}

method advance_pos() {
	$.firstpos += 9
	print("Pos is now ",$.firstpos)
	if ( ! ($.firstpos in $.sourcephr) ) {
		$.firstpos = -1
	}
	$.typoforwardall($.sourcephr,$.firstpos)
}

method rewind_pos() {
	$.firstpos -= 9
	print("Pos is now ",$.firstpos)
	if ( ! ($.firstpos in $.sourcephr) ) {
		$.firstpos = -1
	}
	$.typoforwardall($.sourcephr,$.firstpos)
}

method killrealtime() {
	# print("KILLREALTIME called")
	kill($.tid)
	$.tid = -1
	kill($.looptask)

}

method typo_restart() {
	Offsetpitch = 0
	print("Offsetpitch = ",Offsetpitch)
	$.killrealtime()
	# Don't reset $.shiftisdown!
	if ( defined($.initiallength) )
		$.tp["length"] = $.initiallength
	else
		$.tp["length"] = 0
	print("TYPO_RESTART, chan=",$.currchan," setting length=",$.tp["length"])
	print("typo_restart is setting loopstart to 0")
	$.tp["loopstart"] = 0
	$.tp["transitions"] = [0=0]
	$.transmultiple = 1
	$.init_misc()
	$.tid = task $.realtimetask()
}

method nextinscale(p,sc) {
	p.pitch++
	p1 = p
	while ( p.pitch < 127 ) {
		if ( p in sc )
			return(p)
		p.pitch++
	}
	return(p1)
}

method chordchanged(p) {
	print("chordchanged, p=",p)
	if ( $.vals["loopxposemode"] ) {
		# p.time = 0
		# $.vals["loopxpose"] = p.pitch - 60
		print("NOT Setting loopxpose to ",$.vals["loopxpose"])
	} else if ( $.vals["grabmode"] ) {
		r = ''
		# make it canonical (pitches starting from 0) and dedup
		for ( c in p ) {
			a = makenote(canonic(c.pitch))
			if ( (a & r) == '' ) {
				r |= a
			}
		}
		print("SETTING chordornament to r=",r)
		$.vals["chordornament"] = r
	} else {
		$.rescale_from_phrase(p)
	}
}

method rescale_from_phrase(p) {
	patt = $.currpatt
	ch = $.currchan
	sc = completescalephrase(p)
	sc = sc{??.pitch>=$.minpitch && ??.pitch<=$.maxpitch}
	print("RESCALE called! patt=",patt," ch=",ch," p=",p," sc=",sc)

	$.vals["completescale"] = sc
	$.completescalesz = sizeof(sc)

	i = 1
	for ( nt in sc ) {
		if ( nt.pitch > $.centerp ) {
			break
		}
		i++
	}
	$.centeri = i
	# print("CENTERi = ",$.centeri)

	sc = step(sc,1b/4)
	$.typo_init_from_phrase(patt,sc,0,1)
	return()
}

# Each thing assigned to a key gets a chord
method assign_bs(tp) {
	for ( cp=1; ; cp++ ) {
		c = substr($.keyorder,cp,1)
		if ( c == "" )
			break
		p = tp[c]
		
		p2 = onlynotes(bsriff())
		p2a = onlynotes(p2)
		dpitch = p2a%1.pitch - p%1.pitch
		p2.pitch -= dpitch
		p2.chan = p.chan
		p2 = cut(p2,CUT_TIME,0,1b)
		tp[c] = p2
	}
}

# Each thing assigned to a key gets a chord
method assign_inversions(tp) {
	for ( cp=1; ; cp++ ) {
		c = substr($.keyorder,cp,1)
		if ( c == "" )
			break
		p = tp[c]
		
		cn = $.chords[rand(sizeof($.chords))]
		p2 = transpose(chordnamed(cn),p)
		p2 = scadjust(p2,makescale('c,e-,g,b-'))
		p2.chan = p.chan
		p2.vol = p.vol
		p2.dur = p.dur

		tp[c] = p2
	}
}

# Each thing assigned to a key gets a chord
method assign_chord(tp) {
	for ( cp=1; ; cp++ ) {
		c = substr($.keyorder,cp,1)
		if ( c == "" )
			break
		p = tp[c]
		
		cn = $.chords[rand(sizeof($.chords))]
		p2 = transpose(chordnamed(cn),p)
		p2 = scadjust(p2,makescale('c,e,g'))
		p2.chan = p.chan
		p2.vol = p.vol
		p2.dur = p.dur

		tp[c] = p2
	}
}

# Each thing assigned to a key gets an octave-transposed copy added
method assign_octaves(tp) {
	for ( cp=1; ; cp++ ) {
		c = substr($.keyorder,cp,1)
		if ( c == "" )
			break
		p = tp[c]
		if ( rand(2) == 0 ) {
			p = p + transpose(p,12)
		} else {
			p = transpose(p,12) + p
		}
		tp[c] = p
	}
}

# Each thing assigned to a key gets an octave-transposed copy added
method assign_rand(tp) {
	for ( cp=1; ; cp++ ) {
		c = substr($.keyorder,cp,1)
		if ( c == "" )
			break
		p = tp[c]
		r = rand(4)
		if ( r == 0 ) {
			p = p + transpose(p,12)
		} else if ( r == 1 ) {
			p = transpose(p,12) + p
		} else if ( r == 2 ) {
			p = preecho(p,5,1b/4,0.7)
		} else {
			p = echo(p,5,1b/4,0.7)
		}
		tp[c] = p
	}
}

method apply_mods(p,prox) {

	if ( p == '' ) {
		print("Hmmmm *********** apply_mods called on p=",p)
		return('')
	}
	if ( typeof(p) != "phrase") {
		print("Non phrase (",p,") given to apply_mods...")
		return('')
	}

	p.chan = $.currchan
	p.vol = (prox*prox) * 127 / 9.0

	vp = $.vals["varypitch"]
	if ( vp ) {
		r = rand(vp/2)
		if ( rand(2) )
			r = -r
		p.pitch += r
	}
	vv = $.vals["varyvol"]
	if ( vv ) {
		r = rand(vv/2)
		if ( rand(2) )
			r = -r
		print("Adjusting vol by r=",r)
		p.vol += r
	}

	# print("apply_mods p=",p)
	if ( typeof(p) != "phrase" ) {
		print("Hmmm, p isn't a phrase at AA1a?")
		return()
	}

	if ( p.chan == 3 ) {
		# Drums - program # determines which pitches are used
		# program 0,  use 36 to 68
		# program 1,  use 69 to 102
		# print("drum was=",p)
		r = ''
		pnum = $.vals["program"]
		# print("drum, pnum=",pnum)
		if ( pnum == 0 ) {
			minpitch = 36
			maxpitch = 68
		} else {
			minpitch = 69
			maxpitch = 102
		}
		pitchrange = maxpitch - minpitch + 1
		extra = ($.loopnumber % 10) - 5
		for ( nt in p ) {
			nt.pitch = minpitch + ((nt.pitch+extra) % pitchrange)
			r |= nt
		}
		p = r
		# print("  adjusted=",p)
		if ( typeof(p) != "phrase" ) {
			print("Hmmm, p isn't a phrase at AA1aaa?")
			return()
		}
	}

	if ( $.vals["longdur"] ) {
		p.dur *= 2
	}
	if ( typeof(p) != "phrase" ) {
		print("Hmmm, p isn't a phrase at AA1b?")
		return()
	}
	slow = $.vals["slowness"]
	if ( slow != 1 ) {
		p = scatimes(p,slow)
	}

	p.pitch += (12*$.octshift)
	p.vol += $.velocityinc
	vr = $.velocityrand
	if ( typeof(p) != "phrase" ) {
		print("Hmmm, p isn't a phrase at AA1ca?")
		return()
	}
	if ( vr != 0 ) {
		rval = rand(20) - 10
		# make sure it adjusts it at least somewhat
		if ( rval == 0 )
			rval = 1
		p.vol += (vr * rval)
	}

	if ( $.nnotes > 0 ) {
		arr = splitonstarts(p,0,$.nnotes)
		p = arr[0]
		if ( typeof(p) != "phrase" ) {
			print("Hmmm, p isn't a phrase at AA1cb?  arr=",arr,"  nnotes=",$.nnotes)
			return()
		}
	}
	if ( typeof(p) != "phrase" ) {
		print("Hmmm, p isn't a phrase at AA1c?")
		return()
	}

	i = $.immediate
	if ( i != 0 ) {
		p = i(p)
	}
	ds = $.durscale
	dsr = $.durscalerand
	if ( ds != 1 || dsr > 1 ) {
		dsrv = 1 + rand(dsr)
		p = scatimes(p,ds * dsrv)
	}
	t = $.tp["tonality"]
	if ( t != 0 ) {
		p = scadjust(p,$.tonalscales[t])
	}
	if ( $.fractality > 0 ) {
		p = $.imm_fract(p,$.fractality)
	}
	# print("apply_mods returns p=",p)
	if ( typeof(p) != "phrase" ) {
		print("Hmmm, p isn't a phrase at AA1d?")
		return()
	}

	return(p)
}

method looper_input_cmd(keydown,cmd,pad,prox,fingeruid) {

	print("LOOPER_INPUT_CMD??")
	if ( cmd == "START" ) {
		$.loopmode = 0
		return()
	}
	if ( cmd == "STOP" ) {
		$.killloopnow()
		return()
	}
}

method rand_program() {
	p = progchange(1+rand($.vals["nprograms"]),$.currchan)
	print("Sending rand progchange p=",p)
	realtime(p)
}

method get_quant() {
	return($.quant)
}
method set_quant(v) {
	$.quant = integer(v)
	if ( $.quant < 1 ) {
		$.quant = 1
	}
	# print("Quant is now ",$.quant)
}

method inc_quant(f) {
	$.set_quant($.quant * 2.0)
}
method dec_quant(f) {
	$.set_quant($.quant / 2.0)
}

method set_tempo(v) {
	tempo(v)
	# print("Tempo is now ",tempo())
}

method inc_tempo(f) {
	$.set_tempo(tempo()/2.0)
}
method dec_tempo(f) {
	$.set_tempo(tempo()*2.0)
}

method force_length_16b() { $.force_length(16b) }

method inc_length(factor) {
	$.set_length($.tp["length"]*2.0)
}
method dec_length(factor) {
	$.set_length($.tp["length"]/2.0)
}
method get_length() {
	return($.tp["length"])
}

method set_length(newleng) {
	# print("SETTING length of chan",$.currchan,"to",newleng)
	# print("old leng=",$.tp["length"]," phrase=",$.loopphrase)
	p = $.loopphrase
	oldleng = $.tp["length"]
	p.length = oldleng
	$.tp["length"] = newleng
	# Force the looped phrase to be that length, but
	# either repeating or truncating it
	if ( newleng > oldleng ) {
		# Don't repeat it blindly, vary it
		p = p + shuffle(p)
	}
	p = repleng(p,newleng)
	p.length = newleng
	$.loopphrase = p
	# print("   new leng=",$.tp["length"]," phrase=",$.loopphrase)
}

method set_loop_length(nw) {
	if ( $.tp["length"] == 0 ) {
		print("typo set_loop_length called, SETTING LENGTH, loopstart=",$.tp["loopstart"],"  chan=",$.currchan)
		if ( $.loopphrase == '' ) {
			print("Nothing in loopphrase, so ignoring set_loop_length");
			return()
		}
		lng = nw - $.tp["loopstart"]
		lq = nextquant(lng,$.loopquant)
		if ( (lq - lng) > ($.loopquant/2) ) {
			# play_loop(tm)
			lq -= $.loopquant
		}
		if ( lq < 0 ) {
			print("lq<0 ? lq=",lq," $.tp[loopstart]=",$.tp["loopstart"],"  nw=",nw,"  lng=",lng)
			lq = $.loopquant
			print("Forcing lq to ",lq)
		}
		$.tp["length"] = lq
		ls = prevquant(nw,lq)
		if ( ls != $.tp["loopstart"] ) {
			# If we've already passed what should
			# really be the start of the first
			# iteration of the loop, we should
			# play the loop right away,
			# so there's not a blank space
			t2 = $.tp["loopstart"] + $.tp["length"]
			$.play_loop(t2)
			# $.playprev = t2
		}

		print("SET_LOOP_LENGTH setting loopstart to ls=",ls)
		$.tp["loopstart"] = ls
		print("LOOP LENGTH set to ",lq," ( ",lq/1b," beats )")

	}
}

method looper_input_i(keydown,i,prox,uid) {

	# print("looper iput keydown=",keydown," Now=",Now," nw=",nw," quant=",$.quant)

	sz = sizeof($.phr)
	ii = integer(i * sz + 0.5) % sz
	p = $.phr[ii]

	$.looper_input_p(keydown,p,prox,uid)
}

method looper_input_rc(keydown,r,c,prox,uid) {
	n = $.centeri + c
	if ( n < 1 ) {
		n = 1
	} else if ( n > $.completescalesz ) {
		n = $.completescalesz
	}
	p = $.vals["completescale"] % n
	if ( p == '' ) {
		print("NULL phrase for rc=",r,c," n=",n," cmpsz=",$.completescalesz," completescale=",$.vals["completescale"]," ??")
		return()
	}
	p.pitch += (r * 12)
	# print("INPUT_RC r=",r," c=",c," n=",n," p=",p)

	$.looper_input_p(keydown,p,prox,uid)
}

method looper_input_p(keydown,p,prox,uid) {

	if ( typeof(p) != "phrase" ) {
		print("Hmmm, p isn't a phrase at XX?")
		return()
	}
	if ( p == '' ) {
		print("NULL phrase given to looper_input_p?")
		return()
	}
	qnt = $.quant

	if ( $.vals["quantdiv"] ) {
		qd = 3.0
	} else {
		qd = 2.0
	}

	if ( prox > 1.0 ) {
		qnt = $.quant / qd
	}
	if ( prox > 2.0 ) {
		qnt = $.quant / (2 * qd)
	}
	qnt = integer(qnt)
	# print("PROX=",prox," qnt=",qnt)
	if ( qnt < 1 ) {
		qnt = 1
	}
	nw = nextquant(Now,qnt)
	# print("input_p  p=",p)

	if ( $.xpose != 0 ) {
		p = transpose(p,$.xpose)
	}
	# if ( $.vals["octave"] != 0) {
	# 	p = transpose(p,$.vals["octave"]*12)
	# }
	if ( $.vals["mono"] ) {
		# print("Forcing pad phrase to be mono")
		p = mono(p,2)
	}

	# print("looper_input i=",i," ii=",ii," sz=",sz," prx=",prox," id=",uid,"  chan=",$.currchan," p=",p)

	isrecording = $.vals["recording"]
	# print("Looper_input_i isrecording=",isrecording," keydown=",keydown," uid=",uid)

	if ( keydown == 1 ) {

		# key just went down

		# If we're recording, we set
		# the start of the loop if it's not set already

		# print("keydown, loopstart=",$.tp["loopstart"])

		if ( isrecording && ($.tp["loopstart"] == 0) ) {
			nq = prevquant(nw,$.loopquant)
			$.tp["loopstart"] = nq
			print("STARTING LOOOP!!  loopstart/nq=",nq)
		}
		# When the key goes down, we just play it.
		# It doesn't get added to the loop until it's let up.

		if ( typeof(p) != "phrase" ) {
			print("Hmmm, p isn't a phrase at XX1a?")
			return()
		}
		# print("preapply p=",p," prox=",prox," uid=",uid)
		if ( p == '' ) {
			print("NULL phrase before apply_mods?")
			return()
		}
		p = $.apply_mods(p,prox,uid)
		if ( typeof(p) != "phrase" ) {
			print("Hmmm, p isn't a phrase at XX1b?")
			return()
		}
		if ( p == '' ) {
			return()
		}
		co = $.vals["chordornament"]
		if ( $.vals["ornamode"] != 0 && sizeof(co) > 1 ) {
			lw = lowest(co)
			r = p
			for ( nt in co ) {
				if ( nt.pitch == lw ) {
					continue
				}
				p2 = p
				p2.pitch += (nt.pitch - lw)
				r |= p2
			}
			p = r
			if ( $.vals["ornastep"] != 0 ) {
				p = arpeggio(step(p,qnt))
			}
			# print("Ornamented p=",p)
			
		}

		if ( typeof(p) != "phrase" ) {
			print("Hmmm, p isn't a phrase at XX2?")
			return()
		}
		$.lastplayedphr[uid] = p
		# print("lastplayedphr for uid=",uid," is ",p)
		if ( $.sustainwhiledown ) {
			p.type = NOTEON
		}
		$.lastplayedtid[uid] = $.realtime(p,nw)
		# print("Playing A p=",p," Now=",Now," nw=",nw," prox=",prox," qnt=",qnt)
		$.lastplayedtm[uid] = nw
		# print("realtime p=",p,"  nw=",nw,"  Now=",Now," prox=",prox)
		return()
	}

	if ( ! (uid in $.lastplayedphr) ) {
		print("Hey, uid=",uid," is not in lastplayedphr?")
		return()
	}

	p = $.lastplayedphr[uid]
	lastdown = $.lastplayedtm[uid]

	killonup = $.vals["killonup"]
	if ( killonup ) {
		# print("Killing on up, delayed")
		$.kill_later($.lastplayedtid[uid],Now+1b/8)
	}

	if ( keydown == 0 ) {
		delete $.lastplayedphr[uid]
		delete $.lastplayedtm[uid]
		delete $.lastplayedtid[uid]
	}

	# print("p=",p,"  isrecording = ",isrecording)
	if ( ! isrecording ) {
		# We're NOT recording
		# p.time = 0
		if ( killonup == 0 || $.sustainwhiledown ) {
			if ( nw == lastdown ) {
				# print("Adding a bit of time to noteoff?")
				nw += qnt/2
			}
			# print("realtime 2 p=",p,"  nw=",nw,"  Now=",Now)
			if ( killonup ) {
				p.time = 0
			}
			p.type = NOTEOFF
			$.realtime(p,nw)
			# print("Playing B p=",p," Now=",Now," nw=",nw)
		}
		return()
	}
	# We ARE recording
	if ( $.loopmode > 0 ) {
		print("LOOPMODE > 0 isn't used, right??")
		# Append mode - duration of notes gets used,
		# but the start time is ignored -
		# they just get appended to the loop.
		p2 = $.loopphrase + p
		$.setloop(p2)
	} else {
		# Realtime - timing of notes gets used

		d = nw-lastdown
		# print("REALTIME LOOPING, p=",p," d=",d)
		newp = ''
		for ( tmpnt in p ) {
			if ( (tmpnt.time + tmpnt.dur) < d ) {
				tmpnt.dur = d - tmpnt.time
			} 
			newp |= tmpnt
		}
		p = newp
		# print("NEW p = ",p)

		tmpdt = lastdown - $.tp["loopstart"]
		while ( tmpdt < 0 )
			tmpdt += $.tp["length"]

		if ( killonup ) {
			killdt = Now-lastdown
			p1 = cut(p,CUT_TIME,0,killdt,TRUNCATE)
			# print("Truncated recorded killdt=",killdt," p1=",p1)
		} else {
			p1 = p
		}
		p1.time += nextquant(tmpdt,qnt)
		if ( p1.time <= lastdown ) {
			nw += qnt/2
		}
		d = nw-lastdown
		if ( d <= 0 )
			d = 1
		nextq = nextquant(d,qnt)
		if ( $.forcedur ) {
			p1.dur = nextq
		}
		p1.length = nextq
		# print("ADDING $=",$," p1=",p1," TO LOOP!!! chan=",$.currchan)

		p2 = $.loopphrase | p1

		p2 = dedup(p2)
		if ( sizeof(p2) > $.loopnotelimit ) {
			# just in case p1 is big
			while ( sizeof(p1) > ($.loopnotelimit/2) ) {
				print("REDUCING size of p1?")
				p1 = p1{rand(2)==0}
			}
			while ( sizeof(p2) > $.loopnotelimit ) {
				# print("REDUCING size of loopphrase")
				$.loopphrase = $.loopphrase{rand(2)==0}
				p2 = $.loopphrase | p1
			}
		}
		# print("SETTING LOOP to ",p2)
		$.setloop(p2)
	}
	# p.time = 0
	p.type = NOTEOFF
	$.realtime(p,nw)
	# print("Playing C p=",p," Now=",Now," nw=",nw)
}

method kill_later(tid,tm) {
	# print("kill_later tid=",tid)
	sleeptill(tm)
	kill(tid)
}

method realano() {
	realtime(ano())
}

method ctrl_ano(c,nw) {
	print("Sending all-notes-off...")
	$.realano()
}

method ctrl_info(c,nw) {

	# atts = ""
	# if ( $.tp["tonality"] > 0  ) {
	# 	atts = atts + "Y=" + string($.tp["tonality"]) + " "
	# }
	# print("\nCURRENT: Pattern=",$.currpatt,"  Channel=",$.currchan,"  Loop=",$.tp["length"]/1b,"beats ",atts)
}

method ctrl_ornament(c,nw) {
	a = ascii(c) - ascii("0")
	ch = $.currchan
	if ( a >= 0 && a < 10 ) {
		orn = $.ornament[a]
		if ( sizeof(orn) > 0 ) {
			for ( i in $.phr ) {
				pk = orn[rand(sizeof(orn))]
				$.phr[i] = ornament($.phr[i],pk)
				if ( OrnamentScale ) {
					p = $.phr[i]
					p = scadjust(p,makescale(scalenamed("newage")))
					$.phr[i] = p
				}
			}
		}
	}
}

method assign_mf(fname) {

	print("ASSIGN_MF fname=",fname)
	$.typo_init()

	p = readmf(fname)
	p = onlynotes(p)
	# Eliminate channel 10, usually drums
	p -= p{??.chan==10}
	if ( sizeof(p) == 0 ) {
		print("No notes in midi file: ",fname)
		return()
	}
	if ( $.stepfile ) {
		p = step(p,1b/4)
	}

	$.typo_init_from_phrase($.currpatt,p,$.minlength,$.fixedsize)
}

method assign_phrasescale(p) {

	# print("ASSIGN_PHRASESCALE p=",p)
	$.typo_init()

	p = onlynotes(p)
	sc = completescalephrase(p)
	sc = sc{??.pitch>=$.minpitch && ??.pitch<=$.maxpitch}
	sc = step(sc,1b/4)
	$.typo_init_from_phrase($.currpatt,sc,0,1)
}

method ctrl_assign(c,nw) {
	a = ascii(c) - ascii("0")
	if ( a >= 0 && a < 10 ) {
		if ( ! ( a in $.assigns ) ) {
			print("No assignments in slot ",a)
		} else {
			print("Assignments now coming from slot ",a)
			$.sourcepos = $.assigns[a]["sourcepos"]
			$.sourcephr = arraycopy($.assigns[a]["sourcephr"])
			$.phr = arraycopy($.assigns[a]["phr"])
		}
		
	} else if ( c == "M" || c == "N" ) {
		fname = browsefiles("midi files (*.mid)","*.mid",1)
		if ( fname != "" && ! fileexists(fname) ) {
			print("Hey, fname=",fname," doesn't exist?")
			return()
		}
		if ( fname != "" ) {
			$.assign_mf(fname)
			print(fname+" has been read and assigned to letters.")
		}
	} else if ( c == "O" ) {
		# ornament
		$.charproc = "ctrl_ornament"
	} else if ( c == "C" ) {
		$.assign_chord($.currchan,$.phr)
	} else if ( c == "I" ) {
		$.assign_inversions($.currchan,$.phr)
	} else if ( c == "B" ) {
		$.assign_bs($.currchan,$.phr)
	} else if ( c == "P" ) {
		$.assign_rand($.currchan,$.phr)
	} else if ( c == "A" ) {
		$.ctrl_assignall()
	} else {
		print("Unrecognized char - ",c)
	}
}

method ctrl_transitions(c,nw) {
	if ( c == "L" ) {
		$.transmultiple = 2
	} else if ( c == "S" ) {
		$.transmultiple = 1
	} else {
		a = ascii(c) - ascii("0")
		if ( a >= 0 && a < 10 ) {
			$.tp["transitions"] = $.transitions[a]
			print("Transitions set to ",$.tp["transitions"])
			# Assume that first transition is currently playing
			if ( sizeof($.tp["transitions"]) > 1 )
				$.transitionpos = 1
			else
				$.transitionpos = 0
		}
	}
}

method change_offset(o) {
	if ( o == Offsetpitch )
		return()
	print("Changing Offsetpitch to ",o)
	Offsetpitch = o
	$.realano()
}

method ctrl_offset(c,nw) {
	# The keys A-Z will map to offsets -12 to 12.
	a = ascii(c) - ascii("A")
	if ( a >= 0 && a < 26 ) {
		$.change_offset( -12 + a )
	}
}

method imm_echo(p) {
	lt = latest(p)
	if ( lt < 1b/4 )
		lt = 1b/4
	if ( lt > 4b )
		lt = 4b
	if ( $.imm_echo_type == 0 ) {
		p = echo(p,3,lt,0.85)
	} else if ( $.imm_echo_type == 1 ) {
		p = echo(p,5,lt,0.90)
	} else if ( $.imm_echo_type == 2 ) {
		p = echo(p,7,lt,0.95)
	} else if ( $.imm_echo_type == 3 ) {
		p = echo(p,16,lt,0.97)
	} else if ( $.imm_echo_type == 4 ) {
		$.immediate = 0
	}
	return(p)
}

method imm_scale(p) {
	p = scadjust(p,$.scales)
	return(p)
}

method old_imm_fract(p,fractsize) {
	if ( nargs() < 2 )
		fractsize = 2
	if ( sizeof($.lastfract) >= fractsize ) {
		# It's fractsize notes long, take off the first
		# one and append new one
		$.lastfract = strip(tail($.lastfract,fractsize))
	}
	$.lastfract += p
	p = strip(fractal($.lastfract,1))
	p = step(p,1b/4)
	p1 = p{rand(2)==0}
	p -= p1
	p2 = p{rand(2)==0}
	p -= p2
	p1.dur = 1b/2
	p2.dur = 1b
	p |= p1
	p |= p2
	p = arpeggio(p)
	p = scadjust(p,$.scales)
	return(p)
}

method imm_fract(p,fractsize) {
	if ( nargs() < 2 )
		fractsize = 1
	fz = fractsize+1
	origp = p
	if ( sizeof(p) >= fz ) {
		$.lastfract = head(p,fz)
	} else {
		$.lastfract += p
		if ( sizeof($.lastfract) > fz ) {
			$.lastfract = strip(tail($.lastfract,fz))
		}
	}
	p = strip(fractal($.lastfract,1))
	if ( $.tamefractal ) {
		n=0
		# Make sure it's not too fast
		while ( p.dur < 1b/6 && ++n < 4 ) {
			p = scatimes(p,2)
		}
		p = scadjust(p,origp)
	}
	return(p)
}

method ctrl_immediate(c,nw) {
	# Set the 'immediate' processor for played notes
	if ( c == "E" ) {
		$.immediate = $.imm_echo
		$.imm_echo_type = ($.imm_echo_type+1)%5
	} else if ( c == "F" ) {
		$.immediate = $.imm_fract
	} else if ( c == "W" ) {
		$.immediate = $.imm_fract
	} else if ( c == "S" ) {
		$.immediate = $.imm_scale
	} else {
		print("Unknown Immediate character: ",c)
	}
}

method fractal_chan() {
	leng = $.tp["length"]
	p = $.tp["loopphrase"]
	p = fractal(p,1)
	p = step(p,1b/8)
	p2a = p{rand(2)==0}
	p = p - p2a
	p2b = p{rand(2)==0}
	p = p - p2b
	p2a.dur *= 2
	p2b.dur *= 4
	p = p | p2a | p2b
	p = arpeggio(p)
	p = cut(p,CUT_TIME,0,leng)
	trq = $.requant
	if ( trq > 1 )
		p = quantize(p,trq)
	$.tp["loopphrasewarp"] = p
}

method spaces(p,leng) {
	if ( nargs() < 2 )
		leng = latest(p)
	for ( n=0; n<4; n++ ) {
		b1 = rand(leng-1b)
		p2 = cut(p,CUT_TIME,b1,b1+1b)
		p = p - p2
	}
	return(p)
}

method stutter(p) {
	p = stutterrand(p)
	return(p)
}
method chords(p) {
	q = p{ rand(2) == 0 }
	p -= q
	cn = $.chords[rand(sizeof($.chords))]
	c = chordnamed(cn)
	sc = makescale('c,e,g')
	for ( a in q ) {
		p2 = transpose(c,a)
		p2 = scadjust(p2,sc)
		p2.chan = a.chan
		p2.vol = a.vol
		p2.dur = a.dur
		p2.time = a.time
		p |= p2
	}
	return(p)
}

method echo(p) {
	r = rand(6)
	if ( r == 0 ) {
		p = preecho(p,5,1b/8,0.8)
	} else if ( r == 1 ) {
		p = echo(p,3,1b/4,0.85)
	} else if ( r == 2 ) {
		p = echo(p,2,1b,1.0)
	} else if ( r == 3 ) {
		p = echo(p,4,1b/8,0.8)
	} else if ( r == 4 ) {
		p = echo(p,2,1b/2,1.0)
	}
	return(p)
}

method warp(f) {
	leng = $.tp["length"]
	w = $.tp["loopphrasewarp"]
	if ( sizeof(w) > 0 )
		p = w
	else
		p = $.tp["loopphrase"]
	$.tp["loopphrasewarp"] = $.(f)(p,leng)
}

method warpit(f) {
	$.warp(f)
}

method ctrl_warp(c,nw) {
	if ( c == "A" ) {
		$.warpall = 1
		print ("Warp all")
	} if ( c == "C" ) {
		$.warpall = 0
		print ("Warp chan")
	} else if ( c == "S" ) {
		# spaces
		print ("Warp spaces")
		$.warpit("spaces")
	} else if ( c == "H" ) {
		# comb by half
		print ("Warp half")
		$.warpit("comb")
	} else if ( c == "T" ) {
		# stutter
		print ("Warp stutter")
		$.warpit("stutter")
	} else if ( c == "E" ) {
		# echo
		print ("Warp echo")
		$.warpit("echo")
	} else if ( c == "O" ) {
		# echo
		print ("Warp chords")
		$.warpit("chords")
	} else if ( c == "F" ) {
		# fractal
		print ("Warp fractal")
		$.fractal_chan()
	} else if ( c == "W" ) {
		$.tp["loopphrasewarp"] = ''
		print ("Warp cleared")
	}
}

method ctrl_length(c,nw) {
	if ( c == "H" ) {
		$.tp["length"] *= 0.5
	} else if ( c == "D" ) {
		leng = $.tp["length"]
		newleng = leng * 2

		origp = $.tp["loopphrase"]
		p = origp
		p.length = newleng
		# If the second half doesn't have anything,
		# then duplicate the first half
		p2 = cut(p,CUT_TIME,leng,newleng)
		if ( sizeof(p2) == 0 ) {
			origwarp = $.tp["loopphrasewarp"]
			if ( sizeof(origwarp) == 0 )
				origwarp = origp
			p2 = cut(origwarp,CUT_TIME,0,leng)
			p2.length = leng
			p = repleng(p2,newleng)
		}
		$.tp["loopphrasewarp"] = p
		$.tp["length"] = newleng
	} else {
		# The keys 1-9 map to lengths
		a = ascii(c) - ascii("0")
		if ( a >= 1 && a < 10 ) {
			$.tp["length"] = a * 1b
		}
	}
	print("Length = ",($.tp["length"]/1b)," beats")
}

method ctrl_pattern(c,nw) {
	# The keys 0-9 will map to patterns
	a = ascii(c) - ascii("0")
	if ( a >= 0 && a < 10 ) {

		# copy the current loop over to the new pattern
		$.typo[a]["loopphrase"] = $.typo[$.currpatt]["loopphrase"]
		$.typo[a]["length"] = $.typo[$.currpatt]["length"]
		$.typo[a]["looptask"] = arraycopy($.typo[$.currpatt]["looptask"])

		$.topattern(a)
		print("Switched to Pattern = ",a,
			"   length = ",$.typo[a]["length"])
	}
}
method ctrl_pattern_reset(c,nw) {
	# The keys 0-9 will map to patterns
	a = ascii(c) - ascii("0")
	if ( a >= 0 && a < 10 ) {
		$.nextpattern = a
		print("WILL BE Switching to Pattern = ",a,
			"   length = ",$.typo[a]["length"])
	}
}

method topattern(n) {

	$.currpatt = n
	$.transitionpos = 0

	$.tp = $.typo[n]

	# Careful - these global variables should not be altered
	# by any other code, the arrays they point to must not
	# be re-allocated, they must be the values in $.typo[]
	$.loopphrase = $.tp["loopphrase"]
	$.loopphrasewarp = $.tp["loopphrasewarp"]
	if ( "loopquant" in $.tp )
		$.loopquant = $.tp["loopquant"]
	else
		$.loopquant = 8b
	# print("LOOPQUANT = ",$.loopquant)
	$.mode = $.tp["mode"]
	$.loopmode = $.tp["loopmode"]
	$.looptask = $.tp["looptask"]
	$.ctlr = $.tp["ctlr"]
	$.pan = $.tp["pan"]
	$.immediate = $.tp["immediate"]
	$.requant = $.tp["requant"]
	$.octshift = $.tp["octshift"]
	$.fractality = $.tp["fractality"]
	$.durscale = $.tp["durscale"]
	$.durscalerand = $.tp["durscalerand"]
	$.velocityinc = $.tp["velocity"]
	$.velocityrand = $.tp["velocityrand"]
	$.looprestep = $.tp["looprestep"]
	$.phr = $.tp["phrase"]
	$.assigns = $.tp["assigns"]
	$.sourcephr = $.tp["sourcephr"]
	$.loopfade = $.tp["loopfade"]

	$.sourcepos = $.tp["sourcepos"]

	$.change_offset( $.tp["transitions"][0] )

	$.lastplayedphr = []	# index is uid
	$.lastplayedtm = []	# index is uid
	$.lastplayedtid = []	# index is uid
	$.finger = []		# index is key(character)

	# for ( ctlr in $.controllers ) {
	# 	p = controller($.currchan,ctlr,$.ctlr[ctlr])
	# 	print("NOT Sending controller p=",p)
	# 	# realtime(p)
	# }

	task $.ctrl_info()
}

method inc_value(v,origval,name) {

	if ( v == INCDEC_MID )
		i = $.limits[name]["mid"]
	else if ( v == INCDEC_MIN )
		i = $.limits[name]["min"]
	else if ( v == INCDEC_MAX )
		i = $.limits[name]["max"]
	else if ( v == INCDEC_INC )
		i = origval + $.limits[name]["inc"]
	else if ( v == INCDEC_DEC )
		i = origval - $.limits[name]["inc"]
	else {
		print("Hey, invalid v=",v," given to inc_value")
		i = $.limits[name]["mid"]
	}
	return(limitval(i, $.limits[name]["min"], $.limits[name]["max"]))
}
method mult_value(v,origval,name) {

	if ( v == INCDEC_MID )
		i = $.limits[name]["mid"]
	else if ( v == INCDEC_MIN )
		i = $.limits[name]["min"]
	else if ( v == INCDEC_MAX )
		i = $.limits[name]["max"]
	else if ( v == INCDEC_INC )
		i = origval * $.limits[name]["inc"]
	else if ( v == INCDEC_DEC )
		i = origval / $.limits[name]["inc"]
	else {
		print("Hey, invalid v=",v," given to inc_value")
		i = $.limits[name]["mid"]
	}
	return(limitval(i, $.limits[name]["min"], $.limits[name]["max"]))
}
method inc_durscale(v) {
	$.durscale = $.mult_value(v,$.durscale,"D")
	print("durscale=",$.durscale)
}
method inc_tonality(v) {
	$.typo[$.currpatt]["tonality"] =
		$.inc_value(v,$.tp["tonality"],"Y")
}
method inc_fractality(v) {
	$.fractality = $.inc_value(v,$.fractality,"F")
}
method inc_velocityinc(v) {
	if ( v == INCDEC_MID )
		$.velocityinc = $.defaultvelocityinc
	else if ( v == INCDEC_MIN )
		$.velocityinc = -999
	else if ( v == INCDEC_MAX )
		$.velocityinc = 999
	else if ( v == INCDEC_INC )
		$.velocityinc += 10
	else if ( v == INCDEC_DEC )
		$.velocityinc -= 10
}

method inc_controller(v,ctlr) {
	ov = $.ctlr[ctlr]
	if ( v == INCDEC_MID )
		ov = 64
	else if ( v == INCDEC_MIN )
		ov = 0
	else if ( v == INCDEC_MAX )
		ov = 127
	else if ( v == INCDEC_INC )
		ov += $.controllerinc
	else if ( v == INCDEC_DEC )
		ov -= $.controllerinc
	if ( ov > 127 )
		ov = 127
	if ( ov < 0 )
		ov = 0
	$.ctlr[ctlr] = ov
	if ( ctlr == 0x5c )
		p = gm2reverbtime(ov)
	else
		p = controller($.currchan,ctlr,ov)
	realtime(p)
}

method inc_velocityrand(v) {
	if ( v == INCDEC_INC ) {
		if ( $.velocityrand < 4 ) {
			$.velocityrand++
		}
	} else if ( v == INCDEC_DEC ) {
		if ( $.velocityrand > 0 ) {
			$.velocityrand--
		}
	}
	print("velocityrand=",$.velocityrand)
}

method inc_durscalerand(v) {
	if ( v == INCDEC_INC ) {
		if ( $.durscalerand < 4 ) {
			$.durscalerand++
		}
	} else if ( v == INCDEC_DEC ) {
		if ( $.durscalerand > 1 ) {
			$.durscalerand--
		}
	}
	print("durscalerand=",$.durscalerand)
}

method inc_nnotes(v) {
	if ( v == INCDEC_INC ) {
		$.morenotes()
	} else if ( v == INCDEC_DEC ) {
		$.lessnotes()
	}
	if ( $.debug ) print("nnotes=",$.nnotes)
}

method init_pattern(n) {
	# Initialization should be non-destructive, so that
	# restored things can be initialized and hence upgraded
	# to include new values
	if ( ! (n in $.typo) ) {
		$.typo[n] = []
	}
	if ( ! ("loopstart" in $.typo[n]) ) {
		$.typo[n]["loopstart"] = 0
	}
	if ( ! ("loopquant" in $.typo[n]) ) {
		$.typo[n]["loopquant"] = 4b
	}
	if ( ! ("length" in $.typo[n]) ) {
		$.typo[n]["length"] = $.initiallength
	}
	if ( ! ("transitions" in $.typo[n]) ) {
		$.typo[n]["transitions"] = [0=0]
	}
	if ( ! ("loopphrase" in $.typo[n]) ) {
		$.typo[n]["loopphrase"] = ''
	}
	if ( ! ("loopphrasewarp" in $.typo[n]) ) {
		$.typo[n]["loopphrasewarp"] = ''
	}
	if ( ! ("loopmode" in $.typo[n]) ) {
		$.typo[n]["loopmode"] = 0
	}
	if ( ! ("ctlr" in $.typo[n]) ) {
		$.typo[n]["ctlr"] = $.initial_ctlr()
	}
	if ( ! ("pan" in $.typo[n]) ) {
		$.typo[n]["pan"] = 64
	}
	if ( ! ("immediate" in $.typo[n]) ) {
		$.typo[n]["immediate"] = 0
	}
	if ( ! ("requant" in $.typo[n]) ) {
		$.typo[n]["requant"] = 0
	}
	if ( ! ("octshift" in $.typo[n]) ) {
		$.typo[n]["octshift"] = 0
	}
	if ( ! ("tonality" in $.typo[n]) ) {
		$.typo[n]["tonality"] = 0
	}
	if ( ! ("loopfade" in $.typo[n]) ) {
		$.typo[n]["loopfade"] = $.defaultloopfade
	}
	if ( ! ("fractality" in $.typo[n]) ) {
		$.typo[n]["fractality"] = 0
	}
	if ( ! ("durscale" in $.typo[n]) ) {
		$.typo[n]["durscale"] = 1
	}
	if ( ! ("durscalerand" in $.typo[n]) ) {
		$.typo[n]["durscalerand"] = $.defaultdurscalerand
	}
	if ( ! ("velocity" in $.typo[n]) ) {
		$.typo[n]["velocity"] = $.defaultvelocityinc
	}
	if ( ! ("velocityrand" in $.typo[n]) ) {
		$.typo[n]["velocityrand"] = $.defaultvelocityrand
	}
	if ( ! ("looprestep" in $.typo[n]) ) {
		$.typo[n]["looprestep"] = 0
	}
	if ( ! ("looptask" in $.typo[n]) ) {
		$.typo[n]["looptask"] = -1
	}
	if ( ! ("sourcephr" in $.typo[n]) ) {
		$.typo[n]["sourcephr"] = []
	}
	if ( ! ("sourcepos" in $.typo[n]) ) {
		$.typo[n]["sourcepos"] = -1
	}
	if ( ! ("phrase" in $.typo[n]) ) {
		$.typo[n]["phrase"] = []
	}
	if ( ! ("assigns" in $.typo[n]) ) {
		# Per-pattern array of key assignment stuff
		$.typo[n]["assigns"] = []
	}
}


method typo_setup(nphrases) {

	# Constants and setup

	$.minpitch = 34
	$.maxpitch = 105

	$.debug = 1
	$.tamefractal = 1
	$.loopnotelimit = 75
	print("LOW NOTE LIMIT EXPERIMENT!")
	$.loopnotelimit = 24

	$.inputtid = -1

	$.loopfade = 0

	$.nnotes = 16

	$.sustainwhiledown = 1
	$.forcedur = 0
	$.xpose = 0

	$.nnotesmax = 20
	$.minlength = 1b
	$.fixedsize = 0
	$.stepfile = 0

	$.npatterns = 10
	$.warpall = 0
	$.defaultmode = "L"
	$.verbose = 0
	$.keyorder = "QAZWSXEDCRFVTGBYHNUJMIK,OL.";
	$.nletters = sizeof($.keyorder)
	# if ( nphrases > $.nletters ) {
	# 	print("HEY, nphrases is > nletters!?")
	# }
	$.nletters = nphrases
	$.debug = 0
	$.controllerinc = 5

	$.defaultloopfade = 2
	$.defaultvelocityinc = 20
	$.defaultvelocityrand = 2
	$.defaultdurscalerand = 1
	$.transmultiple = 1
	$.imm_echo_type = 0

	$.pmap = []
	$.pmap = patchmap_for_chan($.currchan)

	$.patches = []

	# Whoowee - two levels of indirection in the function calls!

	c = $.currchan
	$.patches["all"] = (patchtypes_for_chan(c))(".*")
	$.patches["pad"] = (patchtypes_for_chan(c))("pad")
	$.patches["hard"] = (patchtypes_for_chan(c))("hard")
	$.patches["bass"] = (patchtypes_for_chan(c))("bass");
	$.patches["perc"] = (patchtypes_for_chan(c))("perc");
	$.patches["drum"] = (patchtypes_for_chan(c))("drum");
	$.patches["vocal"] = (patchtypes_for_chan(c))("vocal");
	$.patches["all"] = (drumtypes_for_chan(c))(".*")
	$.patches["good"] = (drumtypes_for_chan(c))("good")

	if ( ! defined($.nopatches) ) {
		# No patch changes will be sent on these channels
		# $.nopatches = [ 7=1, 8=1, 9=1 ]
		# $.nopatches = [1=1,2=1,3=1,4=1,5=1,6=1,7=1,8=1,9=1]
		$.nopatches = []
	}

	$.chords = [0="sus",1="min7",2="major",3="minor"]

	$.ornament = [
		1 = [
			0 = 'cd24,e-,g,a',
			1 = 'cd24,e-',
			2 = 'cd24,e-,f',
			3 = 'cd24,e-,f,c',
			4 = 'cd24,b-,a,e-,f,g',
			5 = 'cd24,e-,e',
			6 = 'cd24,g',
			7 = 'cd24,co4',
			8 = 'cd24,g,g-d24,gco4',
			9 = 'cd24,d,b-,e-',
			10 = 'cd24,go2,d,b-,e-',
			11 = 'cd24,e-o2,e,g'
			],
		2 = [],
		3 = [],
		4 = [],
		5 = [],
		6 = [],
		7 = [],
		8 = [],
		9 = [],
		0 = []
		]

	$.transitions = [
		0 = [0=0],
		1 = [0=0,1=1,2=0,3=-2],
		2 = [0=0,1=7,2=0,3=3],
		3 = [0=0,1=3,2=0,3=-5],
		4 = [0=0,1=-5,2=2,3=3],
		5 = [0=0,1=-2,2=-4,3=-5],
		6 = [0=0,1=3,2=5,3=-2,4=-5,5=3,6=-2,7=2],
		7 = [0=0,1=3,2=5,3=7,4=10,5=7,6=5,7=3],
		8 = [0=0,1=7],
		9 = [0=0,1=-2],
		10 = [0=0]	# ?? needed?
		]

	Tnumbers = ["0"=0,"1"=1,"2"=2,"3"=3,"4"=4,"5"=5,"6"=6,"7"=7,"8"=8,"9"=9]

	$.limits = [
		"A" = ["min"=0,"mid"=2,"max"=4,"inc"=1],
		"O" = ["min"=-3,"mid"=0,"max"=3,"inc"=1],
		"D" = ["min"=0.5,"mid"=1.0,"max"=4.0,"inc"=2.0],
		"Y" = ["min"=0,"mid"=1,"max"=5,"inc"=1],
		"F" = ["min"=0,"mid"=1,"max"=4,"inc"=1],
		"W" = ["min"=1,"mid"=2,"max"=5,"inc"=1]
	]

	# The values here are the default controller values
	if ( ! defined($.controllers) ) {
		$.controllers = [
			0x07 = 85,	# vol
			0x0b = 85,	# expression
			0x5b = 40,	# reverb
			0x5c = 40,	# reverbtime (non-standard)
			0x5d = 40,	# chorus
			0x4a = 64	# brightness
		]
		$.controllerletters = [
			"V" = 0x07,	# vol
			"E" = 0x0b,	# expression
			"R" = 0x5b,	# reverb
			"T" = 0x5c,	# reverbtime (non-standard)
			"C" = 0x5d,	# chorus
			"B" = 0x4a	# brightness
		]
	}

	$.scaless = [
		"N" = "newage",
		"I" = "ionian",
		"L" = "lydian",
		"A" = "aeolian",
		"F" = "fifths",
		"H" = "harminor",
		"M" = "melminor"
	]
	$.tonalscales = [
		0 = '',
		1 = makescale(scalenamed("lydian")),
		2 = makescale(scalenamed("newage")),
		3 = makescale(scalenamed("aeolian")),
		4 = makescale(scalenamed("melminor")),
		5 = makescale(scalenamed("newage")),
		6 = makescale(scalenamed("fifths"))
	]

	# Per-pattern stuff

	$.typo = []

	# Should this start at 1?
	for ( n=0; n<$.npatterns; n++ ) {
		$.init_pattern(n)
		# $.rescale(n,'c',"newage")
	}

	# Yes, calling topattern twice is bogus.  Don't change it.
	$.topattern(1)
	$.typo_init()
	$.topattern(1)
	# print("END OF INIT, currpatt = ",$.currpatt)

	$.nextpattern = -1
	$.lastfract = ''
}

# method get_octave() {
# 	return($.vals["octave"])
# }

method change_comb(v) {
	$.loopphrase = $.loopphrase{rand(2)==0}
}

method change_combonbeat(v) {
	$.loopphrase = quantize($.loopphrase,1b/4)
}

method change_combonbeat2(v) {
	$.loopphrase = quantize($.loopphrase,1b/2)
}

method change_shuffle(v) {
	$.loopphrase = shuffle($.loopphrase)
}

method reset_xpose(dp) {
	$.xpose = 0
	print("transpose in chan=",$.currchan," is now ",$.xpose)
}

method adjust_xpose(dp) {
	$.xpose += dp
	print("transpose in chan=",$.currchan," is now ",$.xpose)
	$.loopphrase = transpose($.loopphrase,dp)
}

# method set_octave(v) {
# 	dp = v - $.vals["octave"]  # do this first
# 	$.vals["octave"] = v
# 	$.loopphrase = transpose($.loopphrase,dp * 12)
# }

method inc_slowness(v) {
	$.set_slowness($.vals["slowness"] * 2)
}
method dec_slowness(v) {
	$.set_slowness($.vals["slowness"] / 2.0)
}

method set_slowness(v) {
	$.vals["slowness"] = v
	# print("Setting SLOWNESS to ",v)
}

method get_slowness() {
	return($.vals["slowness"])
}


method set_program(v) {
	if ( v < 0 )
		v = 0
	else if ( v >= $.vals["nprograms"] )
		v = $.vals["nprograms"]-1
	$.vals["program"] = v
	# p = progchange(1+v,$.currchan)
	realchan = $.vals["chan"]
	p = progchange(1+v,realchan)
	print("Sending progchange v=",v," p=",p,"  chan=",realchan)
	realtime(p)
}

method get_program(v) {
	return($.vals["program"])
}

method initial_ctlr() {
	arr = []
	for ( i in $.controllers ) {
		arr[i] = $.controllers[i]
	}
	return(arr)
}

}

function resetconsole(o) {
	o.stop()
}

function ergox_midi_restart(o) {
	o.midi_restart()
}
