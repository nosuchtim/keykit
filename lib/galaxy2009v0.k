#
# ergox_galaxy2009v0
#

INCDEC_MID = 0
INCDEC_MIN = -2
INCDEC_MAX = 2
INCDEC_INC = 1
INCDEC_DEC = -1
TypoDebug = 0
DebugDebug = 0
DebugOsc = 0
DebugReal = 0
DebugParam = 0
DebugLoop = 0
DoFlash = 0
DoActive = 0
DoVisualize = 1
FlashFreq = 1b
DoBidule = 0

function ergox_galaxy2009v0_actionmf {
	return(readmf("c:\\local\\midi\\tjt\\actionseries\\actionseries.mid"))
}

function g9v0() {
	galaxy2009v0()
}
function galaxy2009v0() {

	if ( ! defined(Osclisten) ) {
		Osclisten = 1384
	}

	if ( ! defined(Launchpad_output) ) {
		print("You should define the Launchpad input device...")
		global Launchpad_output
		Launchpad_output = -1
	}

	Offsetfilter = 0
	Offsetportfilter = Launchpad_output

	# tempo(500000)

	if ( Machine != "win" ) {
		print("ergox_galaxy2009v0() only works on Windows, sorry!")
		return()
	}

	# print("Setting dragthreshold to 0...")
	Gesturedragthreshold = 0.0
	GestureDraglimit = 60

	if ( defined(TypoGM) && TypoGM == 1) {
		print("Sending gmresetall")
		realmidi(gmresetall(0x40))
	}

	patchprefix = "patch"

	t = new ergox_galaxy2009v0_mastertypo(patchprefix)
	t.start()
	t.waittilldone()
	t.stop()
}

class ergox_galaxy2009v0_mastertypo {

method init(patchprefix) {

	print("ergox_galaxy2009v0 init started...") 

	$.first_preset_fnum = 0
	$.debugcopy = 0
	$.midi_keyboard_count = 0

	$.oldMerge = Merge
	Merge = 0

	# Drums are going to be on channels 7 and 8,
	# so we don't want those to be affected by Offsetpitch
	$.oldOffsetfilter = Offsetfilter
	Offsetfilter = (1<<6 | 1<<7 )

	$.oscclock = 0
	$.initdone = 0
	$.dir = "."

	$.autoano = 1
	$.nchannels = 8
	$.gridrows = 8
	$.gridcols = 8

	mfname = "c:\\local\\midi\\tjt\\actionseries\\actionseries.mid"

	$.cell = []
	for ( r=0; r<$.gridrows; r++ ) {
		$.cell[r] = []
		for ( c=0; c<$.gridcols; c++ ) {
			$.cell[r][c] = ''
		}
	}

	$.globalparamset = [
		"scale" = "set_scale",
		"tempo" = "set_tempo",
		"loopleng"="change_loopleng"
		]

	$.globalparamlist = [
		"notedur" = "int",
		"forcedur" = "toggle",
		"downqnt" = "int",
		"repqnt" = "int",
		"chordize" = "toggle",
		"loopxposemode" = "toggle",
		"realxposemode" = "toggle",
		"seqleng" = "int",
		"tempo" = "int",
		"grabmode" = "toggle",
		"sequence" = "int",
		"loopvis" = "int",
		"scadjust" = "toggle",
		"scale" = "string",
		"notefreq" = "int",
		"fadeout" = "string",
		"loopleng" = "int",
		"trigger%" = "int"
		]

	$.chanparamset = [
		"volume" = "set_volume"
		]

	$.perchanparamlist = [
		"recording" = "toggle",
		"playloop" = "toggle",
		"velocity" = "int",
		"volume" = "int",
		"quant" = "int",
		"quantall" = "toggle",
		"trigger%" = "int",
		"isdrum" = "toggle"
		]

	$.perloopparamlist = [
		"playloop" = "toggle",
		"loopleng" = "int",
		"fadeout" = "string",
		"trigger%" = "int",
		"loopnotes" = "int"
		]

	$.globalparam = []
	for ( nm in $.globalparamlist ) {
		type = $.globalparamlist[nm]
		$.set_globalparam(nm,$.null_value_of_type(type))
	}

	$.chanparam = []
	for ( ch=1; ch<=$.nchannels; ch++ ) {
		$.chanparam[ch] = []
		for ( nm in $.perchanparamlist ) {
			type = $.perchanparamlist[nm]
			$.set_chanparam(ch,nm,$.null_value_of_type(type))
		}
	}

	$.anykeyboard = 0
	$.lastwarntime = Now

	$.patchprefix = patchprefix

	# $.notedur = 63
	$.notefreq = 63
	$.notevol = 63
	$.downqnt = 1b/4
	$.repqnt = 63
	$.chordize = 0

	$.transpose = 0
	$.def_sequence = 68
	$.def_sequence = 0
	$.sequence = $.def_sequence
	$.seqleng = 64
	$.AutoLastChange = 0
	$.AutoTPos = 0
	$.AutoChanges = [
		0=[0=0],
		1=[0=0,1=3,2=-2,3=5],
		2=[0=0,1=7,2=-2,3=5],
		3=[0=0,1=5,2=0,3=7],
		4=[0=0,1=5,2=3,3=-2],
		5=[0=0,1=7,2=3,3=10],
		6=[0=0,1=5,2=7,3=-2],
		7=[0=0,1=7]
		]
	$.AutoChangeForce = 0

	$.dragisdown = 1
	$.stopme = 0
	$.ignore_up = 0
	$.refresh_on_up = 0
	$.ignore_controls = 0

	# print("TOUCH IGESTURE PAD...")

	$.finger_does_midi = 0
	$.finger_does_graphics = 1

	# $.chord = 'c'
	# $.curr_scale = completescalephrase($.chord)
	# $.nextchord = ''

	$.vidmode = 0
	$.selectA = 1
	$.selectB = 2

	$.nphrases = $.gridrows * $.gridcols

	$.stepsize = 1b/4
	$.loopquant = 8b
	$.quit = 0
	$.debug = 0
	$.lasttouchwarn = 0

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

	$.lastvol = []
	$.lastprox = []
	$.dragvol = 0

	padi = 0
	for ( finger=0; finger<10; finger++ ) {
		uid = $.fingeruid(padi,finger)
		$.lastvol[uid] = Now
		$.lastprox[uid] = 0.0
	}

	$.keyorder = "QAZWSXEDCRFVTGBYHNUJMIK,OL.";
	$.nletters = sizeof($.keyorder)

	$.ctrl_list = [
		"X" = "ctrl_exec"		# Xecute
	]

	$.scale_notes = [
		"Japanese" = 'p0,p3,p5,p8,p10',
		"Japanese2" = 'p0,p2,p3,p7,p8',
		"Japanese3" = 'p0,p1,p5,p7,p10',
		"Japanese4" = 'p0,p2,p3,p5,p7,p9',
		"Egyptian" = 'p0,p2,p3,p7,p8',
		"Egyptian2" = 'p0,p2,p3,p6,p7,p8,p11',
		"Greek" = 'p0,p1,p4,p7,p8,p10',
		"Greek1" = 'p0,p3,p4,p5,p7,p9,p11',
		"Greek2" = 'p0,p2,p3,p6,p7,p9,p10',
		"Greek3" = 'p0,p1,p3,p4,p7,p8,p10',
		"Greek4" = 'p0,p2,p3,p4,p7,p8,p10,p11',
		"Greek5" = 'p0,p3,p4,p5,p7,p8,p11',
		"Chinese" = 'p0,p2,p5,p7,p9',
		"Javanese" = 'p0,p2,p4,p5,p7,p9,p11',
		"Ionian" = 'p0,p2,p4,p5,p7,p9,p11',
		"Dorian" = 'p0,p2,p3,p5,p7,p9,p10',
		"Arabian" = 'p0,p1,p4,p5,p7,p8,p10',   # Phrygian
		"Arabian2" = 'p0,p1,p3,p6,p7,p8,p11',   # Blues?
		"Arabian3" = 'p0,p2,p3,p5,p7,p9,p10',
		"Indian" = 'p0,p1,p4,p6,p7,p8,p11',   # Purvi
		"African" = 'p0,p3,p5,p7,p10',
		"Lydian" = 'p0,p2,p4,p6,p7,p9,p11',
		"Mixolydian" = 'p0,p2,p4,p5,p7,p9,p10',
		"Aeolian" = 'p0,p2,p3,p5,p7,p8,p10',
		"Hungarian" = 'p0,p2,p3,p5,p6,p8,p9',
		"Rwanda" = 'p0,p2,p3,p7,p10',
		"New Age" = 'p0,p3,p5,p7,p10',
		"Fifths" = 'p0,p7',
		"Harminor" = 'p0,p2,p3,p5,p7,p8,p11',
		"Melminor" = 'p0,p2,p3,p5,p7,p9,p11',
		"Chromatic" = 'p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11'
		]

	$.buttprimed = ""

	# Now create the loopers

	vals = [ "chan" = 1, "shape" = 5 ]
	# fm8
	vals["nprograms"] = 20

	ch = 1
	$.currloop = 0
	$.nloops = 8
	$.ergox_galaxy2009v0 = []
	for ( lp=0; lp<$.nloops; lp++ ) {
		$.ergox_galaxy2009v0[lp] = new ergox_galaxy2009v0_onelooper($,lp,$.stepsize,ch,$.nphrases,vals,$.loopquant)
	}

	print("Init done, now starting OSC ...") 

	$.padmode = [0="Draw",0="Draw"]

	$.values = []

	$.finger2osc = ["fingerup"="/touchup","fingerdown"="/touchdown","fingerdrag"="/touchdrag"]
	$.oscclients = []
	$.oscf = open(string(Osclisten)+"@127.0.0.1","rA","osc_listen")
	print("Listening for OSC on ",Osclisten)
	if ( $.oscf < 0 ) {
		print("Unable to listen on ",Osclisten," !?")
		$.osctid = -1
	} else {
		$.osctid = task $.osctask()
		# print("osctid = ",$.osctid)
	}

	$.parametercontrollers = []
	$.registerparametercontroller("127.0.0.1",1385)

	$.visualizers = []
	$.registervisualizer("127.0.0.1",1385)
	$.open_bidule(Hostname,3210)

	# $.lp=",$.loopnum," send_all_values()

	$.reset()

	$.initdone = 1

	$.last_flash = []
	$.last_flash_color = []
	$.next_flash_color = []
	for ( ch=1; ch<=$.nchannels; ch++ ) {
		$.last_flash[ch] = 0
		$.last_flash_color[ch] = -1
		$.next_flash_color[ch] = -1
	}

	launchpad_reset()

	print("Asking parameter controller for parameters")
	$.to_parameter_controllers([0="/sendallparams"])
	print("Waiting for all parameter controller messages to arrive.")
	$.got_continue = 0
	$.to_parameter_controllers([0="/echo",1="continue"])
	toolong = Now + milliclicks(10000)
	while ( $.got_continue == 0 && Now < toolong ) {
		sleeptill(Now+1b/2)
	}
	if ( Now >= toolong ) {
		print("Didn't get continue message!?  Continuing anyway...")
	} else {
		print("All parameters sent (and hopefully received).")
	}
	print("NOW ACTIVE!")
}

method null_value_of_type(t) {
	if ( t == "int" ) return(0)
	if ( t == "toggle" ) return(0)
	if ( t == "string" ) return("")
	print("Unexpected type in null_value_of_type: ",t)
}

method get_perchanparamlist() {
	return($.perchanparamlist)
}
method get_perloopparamlist() {
	return($.perloopparamlist)
}
# method get_perchlpparamlist() {
# 	return($.perchlpparamlist)
# }

method launchpad_flash_chan(ch,tm,dur,color) {
	if ( tm > Now )
		sleeptill(tm)
	df = tm - $.last_flash[ch] 
	# print("df=",df," tm=",tm)
	if ( df < FlashFreq ) {
		# print("Too often, omitting flash of chan=",ch)
		if ( color != $.last_flash_color[ch] ) {
			# print("SAVING nextcolor = ",color)
			$.next_flash_color[ch] = color
		}
		return()
	}
	nextcolor = $.next_flash_color[ch]
	if ( nextcolor >= 0 ) {
		color = nextcolor
		$.next_flash_color[ch] = -1
		# print("USING nextcolor = ",color," dur=",dur)
	}
	$.last_flash[ch] = tm
	# print("SETTING last_flash to ",tm)
	$.last_flash_color[ch] = color
	row = ch - 1
	col = 7
	launchpad_on(row,col,color)
	sleeptill(Now+dur)
	launchpad_off(row,col,color)
}

method launchpad_show_input_chan(ch,color) {
	row = ch - 1
	col = 8
	launchpad_on(row,col,color)
}

method launchpad_flash_input_chan(ch,color) {
	$.launchpad_show_input_chan(ch,color)
	sleeptill(Now+12)
	$.launchpad_show_input_chan(ch,0)
}

method make_chord(p) {
	c = $.chord
	c.time = 0
	c.pitch -= c%1.pitch
	c.vol = p.vol
	c.dur = p.dur
	c.pitch += p.pitch
	return(c)
}

method fingernote(row,col,prox,x,y) {

	notesperrow = $.completescalesz / $.gridrows
	pos = 1 + notesperrow * row + col
	nt = $.curr_scale % pos
	p = $.common_note(nt)

	# print("r,c=",row,col," p.pitch=",p.pitch)

	nd = $.get_globalparam("notedur")
	if ( nd == 0 ) {
		p.type = NOTEON
	} else {
		p.dur = nd
	}
	return(p)
}

method common_note(p,chordize) {
	if ( nargs() < 2 )
		chordize = 1
	p.vol = $.notevol
	# print("Common_note p=",p," Should it be paying attention to isdrum?")

	t = $.ergox_galaxy2009v0[$.currloop]
	ch = t.get_currchan()
	isdrum = $.get_chanparam("isdrum",ch)
	if ( isdrum == 0 ) {
		doscadjust = $.get_globalparam("scadjust")
		if ( doscadjust ) {
			p = scadjust(p,$.curr_scale)
			p.pitch += $.transpose
		}
		if ( $.chordize && chordize != 0 ) {
			p = $.make_chord(p)
			print("MAKING CHORD! p=",p)
		}
	}
	return(p)
}

method autotrans_valmap(v,it) {
	# print("autotrans valmap, sizeof autochanges=",sizeof($.AutoChanges))
	return((v*sizeof($.AutoChanges))/128)
}
method check_autotranspose() {
	if ( $.sequence == 0 ) {
		return()
	}
	print("check_autotranspose, sequence = ",$.sequence)
	atv = $.autotrans_valmap($.sequence)
	tl = $.get_seqleng()
	# print("check_autotranspose, tl=",tl,"  /1b = ",tl/1b)
	if ( $.AutoChangeForce == 1 || ($.AutoLastChange+tl) < Now ) {
		print("Looking at AutoChanges, force=",$.AutoChangeForce)
		if ( $.autoano ) {
			$.realtime(ano(),Now)
		}
		$.AutoChangeForce = 0
		$.AutoTPos++
		if ( ! (atv in $.AutoChanges) ) {
			print("Hey, atv=",atv," not in AutoChanges, sequence=",$.sequence)
			return()
		}
		changes = $.AutoChanges[atv]
		# print("atv = ",atv," changes=",changes)
		if ( $.AutoTPos >= sizeof(changes) ) {
			$.AutoTPos = 0
		}
		# print("atv=",atv," changes=",changes,"  TPos=",$.AutoTPos)
		$.AutoLastChange = Now
		Offsetpitch = changes[$.AutoTPos]
		# print("AUTO OFFSET is now ",Offsetpitch)
	}
}

method grid2drum(r,c) {
	p = 36 + c + r * $.gridcols
	return(makenote(p))
}

method playgrid(t,r,c,down) {
	prox = 2.0
	rawx = (c+0.5) / $.gridcols
	rawy = (r+0.5) / $.gridrows
	ch = t.get_currchan()
	isdrum = $.get_chanparam("isdrum",ch)
	# print("PLAYGRID! rc=",r,c," ch=",ch," isdrum=",isdrum)
	if ( isdrum ) {
		p = $.grid2drum(r,c)
		p.vol = t.get_chanparam("velocity",ch)
		# print("isdrum rc=",r,c,p)
	} else {
		# print("playgrid rc=",r,c)
		p = $.cell[r][c]
		if ( p == '' ) {
			p = $.fingernote(r,c,prox,rawx,rawy)
			p.vol = t.get_chanparam("velocity",ch)
			# print("playgrid is using fingernote p=",p)
		} else {
			print("Using grabbed cell value = ",p)
		}
	}
	if ( down ) {
		p.type = NOTEON
	} else {
		p.type = NOTEOFF
	}
	# print("rc=",r,c," rawxy=",rawx,rawy," down=",down,"fingernote=",p)

	$.handle_midi_keyboard(p)
}

method set_globalparam(nm,v) {
	if ( DebugParam )
		print("SET GLOBAL PARAM nm=",nm," v=",v)
	# $.(nm) = v
	$.globalparam[nm] = v
}

method set_chanparam(ch,nm,v) {
	if ( DebugParam )
		print("SET CHAN PARAM ch=",ch," nm=",nm," v=",v)
	$.chanparam[ch][nm] = v
}
method get_chanparam(nm,ch) {
	if ( typeof(nm) != "string" || typeof(ch) != "integer" ) {
		print("ERROR: get_chanparam bad args ! (ch=",ch," nm=",nm)
		return(0)
	}
	if ( ! ( nm in $.chanparam[ch] ) ) {
		print("No chanparam named: ",nm," !?")
		return(0)
	} else {
		return($.chanparam[ch][nm])
	}
}

method osctask() {
	global ergox_galaxy2009v0_osc_restart
	onexit(ergox_galaxy2009v0_osc_restart,$)
	while ( (d=get($.oscf)) != Eof ) {

		if ( $.initdone == 0 ) {
			# print("Ignoring osc messages till initdone... val=",$.initdone)
			continue
		}

		if ( DebugOsc ) 
			print("osctask got d=",d)

		addr = d[0]
		t = $.ergox_galaxy2009v0[$.currloop]
		ch = t.get_currchan()

		if ( addr == "/nth/playgrid" ) {
			r = d[1]
			c = d[2]
			down = d[3]
			$.playgrid(t,r,c,down)
		} else if ( addr == "/nth/echo" ) {
			if ( d[1] == "continue" ) {
				$.got_continue = 1
			}
		} else if ( addr == "/nth/ano" ) {
			print("ANO!")
			$.realano()
		} else if ( addr == "/nth/grab" ) {
			r = d[1]
			c = d[2]
			p = lastbunch(Recorded)
			p.time = 0
			$.cell[r][c] = p
			print("grabbed row/col=",r,c,"  p=",p)
		} else if ( addr == "/nth/currentchannel" ) {
			ch = d[1]
			if ( DebugParam )
				print("SETTING CHANNEL=",ch," in loop ",$.currloop)
			t.set_currchan(ch)
		} else if ( addr == "/nth/currentloop" ) {
			lp = d[1]
			if ( DebugParam )
				print("SETTING LOOP=",lp)
			$.currloop = lp
		} else if ( addr ~~ "/nth/perchan/set" ) {
			nm = d[1]
			v = d[2]
			if ( nm in $.perchanparamlist ) {
				pt = $.perchanparamlist[nm]
				if ( pt == "toggle" ) {
					$.set_chanparam(ch,nm,$.ison(nm,v))
				} else if ( pt == "int" ) {
					# The value of v might be
					# a 'beat' value like 3b/4
					en = eval_number(v)
					$.set_chanparam(ch,nm,integer(en))
				} else if ( pt == "float" ) {
					$.set_chanparam(ch,nm,float(v))
				} else if ( pt == "string" ) {
					$.set_chanparam(ch,nm,v)
				} else {
					print("Unknown parameter type for nm=",nm)
				}
				if ( nm in $.chanparamset ) {
					$.($.chanparamset[nm])(ch)
				}
			} else {
				print("UNKNOWN perchan parameter: ",nm)
			}
		} else if ( addr ~~ "/nth/perloop/set" ) {
			nm = d[1]
			v = d[2]
			if ( nm in $.perloopparamlist ) {
				pt = $.perloopparamlist[nm]
				if ( pt == "toggle" ) {
					t.set_loopparam(nm,$.ison(nm,v))
				} else if ( pt == "int" ) {
					# The value of v might be
					# a 'beat' value like 3b/4
					en = eval_number(v)
					t.set_loopparam(nm,integer(en))
				} else if ( pt == "float" ) {
					t.set_loopparam(nm,float(v))
				} else if ( pt == "string" ) {
					t.set_loopparam(nm,v)
				} else {
					print("Unknown parameter type for nm=",nm)
				}
			} else {
				print("UNKNOWN loop parameter: ",nm)
			}
		} else if ( addr ~~ "/nth/global/set" ) {
			nm = d[1]
			v = d[2]
			if ( nm in $.globalparamlist ) {
				pt = $.globalparamlist[nm]
				if ( pt == "toggle" ) {
					$.set_globalparam(nm,$.ison(nm,v))
				} else if ( pt == "int" ) {
					# The value of v might be
					# a 'beat' value like 3b/4
					en = eval_number(v)
					$.set_globalparam(nm,integer(en))
				} else if ( pt == "float" ) {
					$.set_globalparam(nm,float(v))
				} else if ( pt == "string" ) {
					$.set_globalparam(nm,v)
				} else {
					print("Unknown parameter type for nm=",nm)
				}
				if ( nm in $.globalparamset ) {
					$.($.globalparamset[nm])(v)
				}
			} else if ( nm == "transposeabs" ) {
				i = integer(v)
				$.set_transpose(i)
			} else {
				print("UNKNOWN global parameter: ",nm)
				# $.set_globalparam(nm,v)
			}
		} else if ( addr == "/nth/global/action") {
			action = d[1]
			# print("NTH GLOBAL ACTION = ",action)
			if ( action == "clear" ) {
				$.all_loops("oneloop_clear")
			} else if ( action == "transreset" ) {
				$.set_transpose(0)
			} else if ( action == "transrand" ) {
				trans = [0=3,1=5,2=7]
				tp = (rand(2)*2-1) * trans[rand(sizeof(trans))]
				$.set_transpose($.get_transpose()+tp)
			} else if ( action == "fade" ) {
				$.all_loops("allchan_fade")
			} else if ( action == "comb" ) {
				$.all_loops("allchan_comb")
			} else if ( action == "shuffle" ) {
				$.all_loops("allchan_shuffle")
			} else if ( action == "quantnow" ) {
				$.all_loops("allchan_quantnow",ch)
			} else {
				print("UNKNOWN global action: ",action)
			}
		} else if ( addr == "/nth/perchan/action") {
			action = d[1]
			if ( DebugParam )
				print("NTH CHANNEL ACTION = ",d[1])
			if ( action == "clear" ) {
				$.all_loops("onechan_clear",ch)
			} else if ( action == "quantnow" ) {
				$.all_loops("onechan_quantnow",ch)
			} else if ( action == "fade" ) {
				$.all_loops("onechan_fade",ch)
			} else if ( action == "comb" ) {
				$.all_loops("onechan_comb",ch)
			} else if ( action == "shuffle" ) {
				$.all_loops("onechan_shuffle",ch)
			} else {
				print("UNKNOWN perchan action: ",action)
			}
# 		} else if ( addr == "/nth/perchlp/action") {
# 			action = d[1]
# 			if ( DebugParam )
# 				print("NTH PERCHLP ACTION = ",d[1])
# 			if ( action == "clear" ) {
# 				print("NO ACTION FOR perchlp clear yet!")
# 			} else {
# 				print("UNKNOWN chlp action: ",action)
# 			}
		} else if ( addr == "/nth/perloop/action") {
			action = d[1]
			if ( DebugParam )
				print("NTH LOOP ACTION = ",d[1])
			if ( action == "clear" ) {
				t.oneloop_clear()
			} else if ( action == "quantnow" ) {
				t.allchan_quantnow()
			} else if ( action == "fade" ) {
				t.allchan_fade()
			} else if ( action == "comb" ) {
				t.allchan_comb()
			} else if ( action == "shuffle" ) {
				t.allchan_shuffle()
			} else {
				print("UNKNOWN perloop action: ",action)
			}
		} else if ( addr == "/registerclient" ) {
			$.registerclient(d[1],d[2])
		} else if ( addr == "/unregisterclient" ) {
			$.registerclient(d[1],d[2])
		} else {
			print("osctask doesn't recognize: ",d)
		}
	}
}

method change_loopleng(lng) {
	# It comes in as a string like "4b"
	lng = eval_number(lng)
	$.all_loops("change_loopleng","loopleng",lng)
}

method all_loops(action,...) {
	for ( lp in $.ergox_galaxy2009v0 ) {
		t = $.ergox_galaxy2009v0[lp]
		t.(action)(...)
	}
}

method get_scale() {
	return($.curr_scale)
}

method set_scale() {
	nm = $.get_globalparam("scale")
	if ( DebugParam )
		print("SET_SCALE nm=",nm)
	if ( ! ( nm in $.scale_notes) ) {
		print("No scale named: ",nm)
		return()
	}
	chord = $.scale_notes[nm]
	sc = completescalephrase(chord)
	sc = sc{??.pitch > 20 && ??.pitch < 116}
	# print("SCALE = ",nm,"  sc=",sc)
	$.completescalesz = sizeof(sc)
	$.curr_scale = sc
	for ( lp in $.ergox_galaxy2009v0 ) {
		t = $.ergox_galaxy2009v0[lp]
		t.set_loop_needs_scaling()
	}
}

method set_volume(ch) {
	v = $.get_chanparam("volume",ch)
	p = controller(ch,0x07,v)
	# print("SET_VOLUME chan=",ch," p=",p)
	$.realtime(p,Now)
}

method registerclient(host,port) {
	portaddr = string(port)+"@"+host
	for ( f2 in $.oscclients ) {
		if ( $.oscclients[f2] == portaddr ) {
			# print("Already registered, ignoring re-register")
			return()
		}
	}
	f = open(portaddr,"wb","osc_send")
	$.oscclients[f] = portaddr
	print("OSC CLIENT REGISTERED! portaddr=",portaddr)
	print("NOT DOING RESET!")
}

method registerparametercontroller(host,port) {
	portaddr = string(port)+"@"+host
	for ( f2 in $.parametercontrollers ) {
		if ( $.parametercontrollers[f2] == portaddr ) {
			# print("Already registered, ignoring re-register")
			return()
		}
	}
	f = open(portaddr,"wb","osc_send")
	$.parametercontrollers[f] = portaddr
	# print("PARAMETER CONTROLLER REGISTERED! portaddr=",portaddr)
}

method to_parameter_controllers(msg) {
	if ( DebugOsc ) {
		print("to_parameter_controllers msg=",msg)
	}
	for ( f in $.parametercontrollers ) {
		if ( DebugOsc > 1 )
			print("Sending msg=",msg," to parametercontroller f=",f)
		mdep("osc","send",f,msg)
		millisleep(10)
	}
}

method to_visualizers(msg) {
	# if ( DebugOsc ) {
	# 	print("to_visualizers msg=",msg)
	# }
	for ( f in $.visualizers ) {
		# if ( DebugOsc > 1 )
		# 	print("Sending msg=",msg," to visualizers f=",f)
		mdep("osc","send",f,msg)
		millisleep(10)
	}
}

method to_bidule(msg) {
	if ( DoBidule ) {
		print("to_bidule msg=",msg," $.bidule=",$.bidule)
		mdep("osc","send",$.bidule,msg)
	}
}

method open_bidule(host,port) {
	portaddr = string(port)+"@"+host
	$.bidule = open(portaddr,"wb","osc_send")
}

method registervisualizer(host,port) {
	portaddr = string(port)+"@"+host
	for ( f2 in $.visualizers ) {
		if ( $.visualizers[f2] == portaddr ) {
			# print("Already registered, ignoring re-register")
			return()
		}
	}
	f = open(portaddr,"wb","osc_send")
	$.visualizers[f] = portaddr
	# print("DISPLAY CLIENT REGISTERED! portaddr=",portaddr)
}


method to_osc_clients(msg) {
	if ( DebugOsc ) {
		print("to_osc_clients msg=",msg)
		# s = sprintf("OSC %s",string(msg))
		# s = substr(s,1,20)
	}
	for ( f in $.oscclients ) {
		if ( DebugOsc > 1 )
			print("Sending msg=",msg," to oscclient f=",f)
		mdep("osc","send",f,msg)
		millisleep(10)
	}
}

method waittilldone {
	wait($.constid)
}

method realano() {
	$.realtime(ano(),Now)
}

method start() { 

	for ( lp in $.ergox_galaxy2009v0 ) {
		t = $.ergox_galaxy2009v0[lp]
		t.start()
	}

	Consecho = 0
	Consupdown = 1
	$.constid = task $.cons_task()

	Midiin[$] = f = open()
	$.miditid = task $.midi_task(Midiin[$])

	# print("MIDITID = ",$.miditid)
	if ( gesturedevices() == 0 ) {
		# print("Warning, no gesture pads are connected!")
	} else {
		gestureclear()
		gesturenotifyrc($,$.gridrows,$.gridcols)
	}

	$.clocktid = task $.check_stuff()
}

method check_stuff() {
	tm = nextquant(Now,1b/2)
	dt = 1b/2
	while (1) {
		$.check_autotranspose()
		sleeptill(tm)
		if ( $.oscclock ) {
			m2 = [0="/clock",1=tm]
			$.to_osc_clients(m2)
		}
		tm += dt
	}
}

method stop {
	# print("STOP called")
	if ( gesturedevices() != 0 ) {
		gestureunnotify($)
	}
	$.stopme = 1
	kill($.miditid)
	kill($.clocktid)
	kill($.constid)
	kill($.osctid)
	# print("Closing oscf=",$.oscf)
	if ( $.oscf >= 0 )
		close($.oscf)
	for ( f in $.oscclients ) {
		close(f)
	}

	for ( lp in $.ergox_galaxy2009v0 ) {
		t = $.ergox_galaxy2009v0[lp]
		t.stop()
	}

	Typos = -1
	if ( $.consf >= 0 ) {
		Consupdown = 0
		# print("Setting Consecho to 1")
		Consecho = 1
		Root.releaseconsole()
	}
	Merge = $.oldMerge
}

method cons_task() {
	$.consf = Root.grabconsole()
	global ergox_galaxy2009v0_resetconsole
	onexit(ergox_galaxy2009v0_resetconsole,$)
	while ( $.quit == 0 && (c=get($.consf)) != Eof ) {
		# print("GOT c=",c," from console")
		$.handle_console(c)
	}
}

method midi_task(f) {
	global ergox_galaxy2009v0_midi_restart
	onexit(ergox_galaxy2009v0_midi_restart,$)
	while ( (c=get(f)) != Eof ) {
		# print("Got midi c=",c)
		$.handle_midi_keyboard(c)
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

method osc_restart() {
	if ( ! $.stopme ) {
		print("RESTARTING osctask!!")
		$.osctid = task $.osctask()
	}
}

method gotgesturerc(t,d,f,r,c,prox,rawx,rawy) {
	# print("gotgesturerc rc=",r,c," prox=",prox)
	if ( $.initdone == 0 ) {
		# print("Waiting for all pads to be touched...")
		return()
	}
	
	# FORCE all pads to be device 0
	d = 0

	arr = ["type"=t,"row"=r,"col"=c,"prox"=prox,"device"=d,"finger"=f]
	# print("got arr=",arr)

	$.handle_finger(t,r,c,prox,d,f,rawx,rawy)
}

method putline(f,s) {
	put(f,s)
	put(f,"\n")
}

method ison(nm,v) {
	if ( v=="on" )
		return(1)
	if ( v=="off" )
		return(0)
	print("UNEXPECTED value in ison nm=",nm," v=",v)
	return(0)
}

method chordchanged() {
	p = $.chord
	p.type = NOTE
	p.time = 0
	$.chord = p
	if ( $.chordize ) {
		print("NOT setting scale, since chordize is on")
		return()
	}
	if ( $.get_globalparam("realxposemode") ) {
		p = ($.chord) % 1
		Offsetpitch = p.pitch - 60
		print("Offsetpitch = ",Offsetpitch)
		return()
	}
	if ( DebugParam )
		print("CHORDCHANGE = ",$.chord)
	sc = completescalephrase($.chord)
	$.curr_scale = sc
}

method handle_midi_chord(c)
{
	if ( c.type == NOTEOFF ) {
		print("Current = ",Current)
		if ( Current == '' ) {
			if ( sizeof($.nextchord) > 9 ) {
				print("KILLING ALL LOOPS")
				$.all_loops("oneloop_clear")
			} else if ( sizeof($.nextchord) > 5 ) {
				print("KILLING current pad loop")
				t = $.ergox_galaxy2009v0[$.currloop]
				t.oneloop_clear()
			} else {
				if ( $.nextchord != '' ) {
					$.chord = $.nextchord
					# print("Nextchord=",$.nextchord," calling chordchanged")
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

		$.chord = $.nextchord
		$.chordchanged()
	}
			
}

method chan_get(ch,nm) {
	s = nm + "#" + string(ch)
	v = $.(s)
	# print("CHAN_GET called, ch=",ch," nm=",nm," s=",s," v=",v)
	return(v)
}

method get_seqleng() {
	# print("GET_SEQLENG returns ",$.seqleng)
	return($.seqleng)
}

method get_globalparam(nm) {
	if ( ! ( nm in $.globalparam ) ) {
		print("ERROR get_globalparam called on nm=",nm)
		return(0)
	}
	return($.globalparam[nm])
}

method set_tempo() {
	v = $.get_globalparam("tempo")
	print("Setting BPM to ",v)
	bpm(v)
	print("Tempo is now ",tempo())
}

method set_transpose(val) {
	# $.transpose = val - 63
	realtime(ano())
	Offsetpitch = val
	# $.transpose = val
	if ( DebugParam )
		print("SET_TRANSPOSE = (Offsetpitch) = ",Offsetpitch)
}
method get_transpose() {
	return(Offsetpitch)
}
method set_seqleng(v) {
	$.seqleng = v
	# print("SEQLENG = ",$.seqleng)
	$.AutoChangeForce = 1
}
method set_sequence(v) {
	# print("SET_SEQUENCE v=",v)
	$.sequence = v
	$.AutoChangeForce = 1
}
method transpose_valmap(v,it) {
	return(v - 63)
}

method ano() {
	if ( DebugReal ) print("REALTIME H ano")
	realtime(ano())
}

method reset() {

	# $.default_control_values()

	$.removeall()
	$.ano()
	$.erase()

	$.lastfingerdowntm = 0
	$.lastfingerdownx = 0
	$.lastfingerdowny = 0
	$.lastfingerphr = []
	$.ignorefingertillup = []
	$.lastfingertm = []
	$.last_select_tm = Now

	$.chord = 'c d e- g'
	$.nextchord = ''
	$.chordactive = 1
	$.chordgathering = 0
	$.chordchanged()
}
method erase() {
	msg = [0="/erase"]
	$.to_osc_clients(msg)
}
method removeall() {
	msg = [0="/removeall"]
	$.to_osc_clients(msg)
}

method handle_midi_keyboard(c) {
	if ( DebugReal )
		print("MIDI_KEYBOARD c=",c)

	if ( c.type == CONTROLLER ) {
		b0 = integer(subbytes(c,1,1))
		b1 = integer(subbytes(c,2,1))
		val = integer(subbytes(c,3,1))
		if ( b0 == 0xb0 && b1 == 0x07 ) {
			# Volume control always works
			c.port = 0
			c.time = 0
			$.realtime(c,Now)
			return()
		}
	}

	t = $.ergox_galaxy2009v0[$.currloop]
	ch = t.get_currchan()

	# Indicate incoming MIDI notes with red
	if ( DoFlash && c.type == NOTEON ) {
		task $.launchpad_flash_input_chan(ch,2)
	}

	c.time = 0
	c.chan = ch
	# print("MIDI ch = ",ch,"  c=",c,"  islooping=",t.islooping())
	doscadjust = $.get_globalparam("scadjust") && ! $.get_chanparam("isdrum",ch)
	if ( $.chordgathering ) {
		$.handle_midi_chord(c)
	} else if ( t.islooping() ) {
		# print("islooping c=",c)
		if ( doscadjust ) {
			sc = $.get_scale()
			c = scadjust(c,sc)
		}
		if ( c.type == NOTEON )
			keydown = 1
		else if ( c.type == NOTEOFF )
			keydown = 0
		else if ( c.type == CONTROLLER ) {
			# print("Passing controller through c=",c)
			t.realtime(c,0,0,ch)
			return()
		} else {
			print("Passing non-note/non-controller through c=",c)
			t.realtime(c,0,0,ch)
			return()
		}
		q = $.downqnt
		t.looper_input_pq(keydown,c,1.5,900+c.pitch,1,q)
	} else {
		# print("is NOT looping c=",c)
		if ( doscadjust ) {
			print("c B before scadjust = ",c)
			sc = $.get_scale()
			c = scadjust(c,sc)
			print("c B after scadjust = ",c)
		}
		t.realtime(c,0,1,ch)
	}
	return()
}

method ignore_till(tm) {
	sleeptill(tm)
	$.ignore_controls = 0
}

method fingeruid(pad,finger) {
	return( pad * 100 + finger )
}
				
method val2quant(v) {
	if ( v < 32 )
		return(1b/2)
	if ( v < 64 )
		return(1b/4)
	if ( v < 96 )
		return(1b/8)
	if ( v < 127 )
		return(1b/16)
	return(1)
}

method realtime(p,tm) {
	if ( DebugReal ) print("REALTIME in Mastertypo p=",p," tm=",tm)
	realtime(p,tm)
}
method handle_finger(ft,row,col,prox,padi,finger,rawx,rawy) {

	print("handle_finger, ft=",ft," rawxy=",rawx, rawy," padi=",padi)

	fid = $.fingeruid(padi,finger)
	# print("HANDLE_FINGER padi=",padi," finger=",finger," fid=",fid)
	orient = 0.0
	eccent = 0.0
	xvel = 0.0
	yvel = 0.0

	if (0) {
		if ( ft == "fingerdown" ) {
			print("FINGER DOWN Now=",Now," rc=",row," ",col," xy=",rawx,rawy," f=",finger," padi=",padi)
		}
		if ( ft == "fingerup" ) {
			print("FINGER UP Now=",Now," rc=",row," ",col," xy=",rawx,rawy," f=",finger," padi=",padi)
		}
	}

	# if ( $.globalvals["fingoscmode"] ) {

	if ( ! ( fid in $.lastfingertm ) ) {
		print("Hey, fid=",fid," not in lastfingertm?")
		$.lastfingertm[fid] = 0
		$.lastfingerdowntm = 0.0
		$.lastfingerdownx = 0.0
		$.lastfingerdowny = 0.0
		$.lastfingerphr[fid] = ''
	}

	if ( ft == "fingerdown" ) {
		dt = Now - $.lastfingerdowntm
		dx = abs(rawx - $.lastfingerdownx)
		dy = abs(rawy - $.lastfingerdowny)
		$.lastfingerdowntm = Now
		$.lastfingerdownx = rawx
		$.lastfingerdowny = rawy
		# print("fingerdown dt=",dt," dxy = ",dx," ",dy," Now=",Now," lasttm=",$.lastfingertm[fid])
		if ( dt < 20 && (dx < 0.02 || dy < 0.02) ) {
			if ( Now > ($.lastwarntime+8b) ) {
				print("Second quick finger-down, not being ignored.")
				$.lastwarntime = Now
			}
			# print("Second quick finger-down in same place, fid=",fid," that finger is now being ignored!")
			# $.ignorefingertillup[fid] = 1
			# return()
		}
	}

	if ( $.ignorefingertillup[fid] == 1 ) {
		print("ignoretillup!! fid=",fid)
		if ( ft == "fingerup" ) {
			# print("Finger went back up, resetting ignoretillup")
			$.ignorefingertillup[fid] = 0
		} else {
			return()
		}
	}

	dt = Now - $.lastfingertm[fid]
	$.lastfingertm[fid] = Now
	
	# notesrc = $.notesrc
	padmode = $.padmode

	print("HANDLE FINGER PLANETMODE = ",padmode," ft=",ft)

	if ( padmode == "Draw" ) {
		oscaddr = $.finger2osc[ft]
		msg = [0=oscaddr,1=fid,2=rawx,3=rawy,4=prox,5=orient,6=eccent,7=xvel,8=yvel]
		$.to_osc_clients(msg)

	} else {
		fid = padi*100+finger
		t = $.ergox_galaxy2009v0[$.currloop]

		if ( ft == "fingerdown" ) {
			p = $.fingernote(row,col,prox,rawx,rawy)
			q = $.downqnt
			tm = nextquant(Now,q)


			if ( t.islooping() ) {
				p.type = NOTEON
				p.time = 0
				# print("looper_input = ",p)
				t.set_currchan(p.chan)
				t.looper_input_pq(1,p,prox,fid,0,q)
			} else {
				print("Normal playing = ",p)
				$.realtime(p,tm)
			}

			$.lastfingertm[fid] = tm
			$.lastfingerphr[fid] = p

		} else if ( ft == "fingerdrag" ) {
			# if ( t.islooping() ) {
			# 	# print("Ignoring drag because we're looping")
			# 	return()
			# }
			nd = $.get_globalparam("notedur")
			if ( nd == 0 ) {
				return()
			}
			lim = ((1b/32) * 127) / ($.notefreq+1)
			# print("notefreq=",$.notefreq," lim=",lim,"  lim2=",(lim/prox))
			lim = lim / prox
			# print("notedur=",$.notedur," dt=",dt," lim=",lim)
			if ( dt >= lim ) {
				q = $.val2quant($.repqnt)
				p = $.fingernote(row,col,prox,rawx,rawy)
				tm = nextquant(Now,q)
				lastp = $.lastfingerphr[fid]
				if ( lastp != '' ) {
					lastp.type = NOTEOFF
					if ( t.islooping() ) {
						loopnt = lastp
						loopnt.type = NOTEOFF
						loopnt.time = 0
						# print("looper drag off = ",loopnt)
						t.looper_input_pq(0,loopnt,prox,fid,0,q)
					} else {
						$.realtime(lastp,$.lastfingertm[fid]+1)
					}
				}
				# print("FingerDrag p=",p)
				if ( t.islooping() ) {
					p.type = NOTEON
					p.time = 0
					# print("Looper drag input = ",p)
					t.set_currchan(p.chan)
					t.looper_input_pq(1,p,prox,fid,0,q)
				} else {
					$.realtime(p,tm)
				}
				# print("fingerdrag p=",p)
				$.lastfingertm[fid] = tm
				$.lastfingerphr[fid] = p
			}
		} else if ( ft == "fingerup" ) {
			lastp = $.lastfingerphr[fid]
			# print("fingerup, lastp=",lastp)
			if ( lastp.type == NOTEON ) {
				lastp.type = NOTEOFF
				# print("SENDING NOTEOFF! lastp=",lastp)
				if ( t.islooping() ) {
					loopnt = lastp
					loopnt.type = NOTEOFF
					loopnt.time = 0
					# print("Fingerup = ",loopnt)
					q = $.val2quant($.repqnt)
					t.set_currchan(loopnt.chan)
					t.looper_input_pq(0,loopnt,prox,fid,0,q)
				} else {
					$.realtime(lastp,$.lastfingertm[fid]+1)
				}
			}
			$.lastfingerphr[fid] = ''
		}
	}
	return()
}

method handle_console(c) {

	keydown = (substr(c,1,1) == "+" )
	c = substr(c,2)
	padi = -1
	prox = 2.0

	$.handle_chr(c,padi,prox,keydown)
}

method handle_chr(c,padi,prox,keydown) {

	# print("handle_chr c=",c," keydown=",keydown)
	if ( ! keydown ) {
		if ( c == $.ignorenextup ) {
			$.ignorenextup = 0
			return()
		}
	}

	if ( c == "I" ) {
		if ( keydown == 1 ) {
			t = $.ergox_galaxy2009v0[$.currloop]
			print(chaninfo(t.get_loopphrase()))
		}
		return()
	}
	if ( c == "A" ) {
		if ( keydown == 1 ) {
			$.autoano = 1 - $.autoano
			print("AUTOANO = ",$.autoano)
		}
		return()
	}

	if ( c == "DEL" ) {
		if ( keydown ) {
			print("RESETTING LOOP")
			t = $.ergox_galaxy2009v0[$.currloop]
			t.killall()
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
		if ( c in $.ctrl_list ) {
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

	if ( c == "D" && keydown ) {
		DebugDebug = 1 - DebugDebug
		DoActive = 1 - DoActive
		print("DebugDebug is now ",DebugDebug,"  DoActive=",DoActive)
		return()
	}

	if ( c == "L" && keydown ) {
		DebugLoop = 1 - DebugLoop
		print("DebugLoop is now ",DebugLoop)
		return()
	}
	if ( c == "P" && keydown ) {
		DebugParam = 1 - DebugParam
		print("DebugParam is now ",DebugParam)
		return()
	}
	if ( c == "R" && keydown ) {
		DebugReal = 1 - DebugReal
		print("DebugReal is now ",DebugReal)
		return()
	}

	if ( c == "V" && keydown ) {
		DoVisualize = 1 - DoVisualize
		print("DoVisualize is now ",DoVisualize)
		return()
	}
	if ( c == "O" && keydown ) {
		DebugOsc = ( DebugOsc + 1 ) % 3
		print("DebugOsc is now ",DebugOsc)
		return()
	}
	if ( c == "F" && keydown ) {
		DoFlash = 1 - DoFlash
		print("DoFlash is now ",DoFlash)
		return()
	}
	if ( c == "G" && keydown ) {
		FlashFreq = 2 * FlashFreq
		print("FlashFreq is now ",FlashFreq)
		return()
	}
	if ( c == "H" && keydown ) {
		FlashFreq = FlashFreq/2
		print("FlashFreq is now ",FlashFreq)
		return()
	}

	if ( keydown && c != "SHIFT")
		print("Ignoring char=",c)
	return()

}

method ctrl_exec(c,nw) {
	if ( c == "Q" ) {
		realtime(ano())
		$.quit = 1
	} else if ( c == "V" ) {
		$.verbose = 1 - $.verbose
	}
}

}


class ergox_galaxy2009v0_onelooper {

method init(parent,loopnum,stepsize,ch,nphrases,vals,loopquant) {
	$.loopnum = loopnum
	$.parent = parent
	$.tid = -1
	$.stepsize = stepsize
	$.currchan = ch
	$.nchannels = 8

	$.loopparamchangemethod = [
		"loopleng"="change_loopleng"
		]
	$.paramnotice = [
		# "loopleng"=0,
		# "loopnotes"=0
		]

	$.tp_loopstart = 0

	# $.chlpparam = []
	# for ( p in $.parent.get_perchlpparamlist() ) {
	# 	$.chlpparam[p] = []
	# }
	# for ( ch=1; ch<=$.nchannels; ch++ ) {
	# 	for ( s in $.chlpparam ) {
	# 		$.chlpparam[s][ch] = 0
	# 	}
	# }

	$.loopparam = []
	for ( p in $.parent.get_perloopparamlist() ) {
		$.loopparam[p] = 0
	}

	$.loopquant = loopquant
	$.loop_needs_scaling = 0
	$.vals = vals
	$.init_looptask()
	$.chordornament = ''
	# print("Setting chordornament to ''")
	$.vals["loopxpose"] = 0
	$.typo_setup(nphrases)
	$.centerp = 'p64'
	$.oscplaytasks = []
	$.chan_color = []
	for ( ch=1; ch<=$.nchannels; ch++ ) {
		$.chan_color[ch] = 1
	}
	$.fademap = [
		"None"    = 0,
		"Slowest" = 1,
		"Slow"    = 2,
		"Medium"  = 3,
		"Fast"    = 4,
		"Fastest" = 5
		]
}

method init_looptask() {
	$.looptask_tid = []
	$.looptask_phr = []
	$.looptask_tm = []
	$.looptask_vis = []
	for ( ch=1; ch<=$.nchannels; ch++ ) {
		$.looptask_tid[ch] = -1
		$.looptask_phr[ch] = ''
		$.looptask_vis[ch] = -1
	}
	$.looptask_steps = -1
}

method kill_looptasks() {
	kill($.looptask_steps)
	for ( ch=1; ch<=$.nchannels; ch++ ) {
		kill($.looptask_tid[ch])
		$.looptask_phr[ch] = ''
		kill($.looptask_vis[ch])
	}
}

method get_globalparam(nm) {
	return($.parent.get_globalparam(nm))
}
method get_chanparam(nm,ch) {
	return($.parent.get_chanparam(nm,ch))
}

method get_loopphrase() {
	return($.loopphrase)
}
method get_lastplayedphr() {
	return($.lastplayedphr)
}

method set_currchan(ch) {
	$.currchan = ch
	msg = [0="/Omnisphere_0/Mode",1=0]
	$.parent.to_bidule(msg)
}
method get_currchan() {
	# print("GET_CURRCHAN = ",$.currchan)
	return($.currchan)
}

method finishloading() {
	$.completescalesz = sizeof($.vals["completescale"])
}

method getvals() {
	print("HEY, getvalues shouldn't be called!")
	return([])
	return($.vals)
}

method start() {

	$.tid = task $.realtimetask()

	$.startdown = []
	$.selectdown = []
}

method stop {
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

method get_loopparam(nm) {
	if ( ! ( nm in $.loopparam ) ) {
		print("No value for nm=",nm," in $.loopparam!")
		return(0)
	}
	v = $.loopparam[nm]
	# print("get_loopparam nm=",nm," returns ",v)
	return(v)
}

method set_loopparam(nm,v) {
	if ( ( nm in $.paramnotice) || DebugParam )
		print("SETTING LOOPPARAM nm=",nm," lp=",$.loopnum," v=",v)
	if ( nm in $.loopparamchangemethod ) {
		# print("Calling loopparamchangemethod on ",nm)
		m = $.loopparamchangemethod[nm]
		$.(m)(nm,v)
	} else {
		$.change_loopparam(nm,v)
	}
	# $.(nm) = v
}

method change_loopparam(nm,v) {
	$.loopparam[nm] = v
}

method change_loopleng(nm,newleng) {
	# print("CHANGING loopleng! loop=",$.loopnum," newleng=",newleng)
	oldleng = $.loopparam[nm]
	$.loopparam[nm] = newleng
	p = $.loopphrase
	# print("oldp = ",p)
	p.length = oldleng

	# Force the looped phrase to be that length, but
	# either repeating or truncating it
	p = repleng(p,newleng)
	p.length = newleng
	$.setloopphrase(p)
	# print("newp = ",p)
}

method set_chlpparam(nm,val) {
	ch = $.currchan
	if ( DebugParam )
		print("SETTING CHLPPARAM nm=",nm," lp=",$.loopnum," ch=",ch," v=",val)
	$.chlpparam[nm][ch] = val
}

method get_chlpparam(nm,ch) {
	if ( ! ( nm in $.chlpparam ) ) {
		print("Hey, nm=",nm," isn't a chlp param!?")
		return(0)
	}
	return($.chlpparam[nm][ch])
}

method realtimetask() {
	# print("STARTING realtimetask, tid=",gettid())
	tm = nextquant(Now,$.loopquant)
	checktime = 1b
	$.playprev = 0
	for ( ;; ) {
		t = Now
		while ( (Now+checktime) < (tm-2) ) {
			sleeptill(Now+checktime)
			# # If the loop has been cleared, reset
			# if ( $.tp_length == 0 ) {
			# 	tm = nextquant(Now,$.loopquant)
			# 	break
			# }
		}
		sleeptill(tm-1b/8)

		loopleng = $.get_loopparam("loopleng")
		# $.tp_length = loopleng

		if ( DebugReal && $.loopphrase != '')
			print("REALTIME TASK loopnum=",$.loopnum," loopleng = ",loopleng," loopphrase=",$.loopphrase)

		if ( loopleng < 0) {
			print("Negative loop leng? ",loopleng)
			return()
		}

		if ( loopleng == 0 ) {
			print("loopleng is 0, skipping by loopquant=",$.loopquant)
			tm += $.loopquant
			continue
		}

		# There's a loop playing

		# If we've already established the length, keep track
		# of when each loop starts, so we know how to record new stuff
		if ( loopleng != 0 ) {
			# print("HEY!  length!=0 = ",loopleng," Setting loopstart to tm=",tm," me=",$," chan=",$.currchan)
			$.tp_loopstart = tm
		}
		if ( DebugReal && $.loopphrase != '')
			print("REALTIME TASK TWO")

		# Not working
		if ( $.playprev != 0 ) {
			$.play_loop($.playprev,loopleng)
			tm = $.playprev + loopleng
			$.playprev = 0
		} else {
			$.play_loop(tm,loopleng)
			tm += loopleng
		}
	}
	print("HEY, REALTIMETASK LOOP broke out?")
}

method set_loop_needs_scaling() {
	$.loop_needs_scaling = 1
}

method play_loop(tm,loopleng) {

	if ( DoVisualize ) {
		$.looptask_steps = task $.steps_visualize(tm,$.loopnum,loopleng)
	}
	if ( $.loopphrase == '' ) {
		return()
	}
	if ( DebugLoop ) {
		print("PLAY_LOOP tm=",tm," loopnum=",$.loopnum," loopleng=",loopleng)
	}
	nnotes = sizeof($.loopphrase)
	# if ( nnotes > 75 ) {
	# 	print("HEY ************ loop is ",nnotes," notes long? ")
	# }

	thisloop = cut($.loopphrase,CUT_TIME,0,loopleng)
	doscadjust = $.get_globalparam("scadjust")
	sc = $.parent.get_scale()

	trigger_loop = $.get_loopparam("trigger%")
	trigger_global = $.get_globalparam("trigger%")

	chp = []
	# Fade things
	for ( ch=1; ch<=$.nchannels; ch++ ) {

		p = cut(thisloop,CUT_CHANNEL,ch)
		if ( sizeof(p) == 0 )
			continue

		fade = $.fademap[$.get_loopparam("fadeout")]
		fade_global = $.fademap[$.get_globalparam("fadeout")]
		if ( fade_global > fade ) {
			# print("Global fadeout overrides loop fadeout!")
			fade = fade_global
		}
		if ( fade > 0 ) {
			$.loopphrase -= p
			p.vol -= (3 * fade)
			p -= p{??.vol==0}
			$.loopphrase |= p
		}
		isdrum = $.get_chanparam("isdrum",ch)
		if ( doscadjust && isdrum == 0 ) {
			p = scadjust(p,sc)
		}

		trigger_chan = $.get_chanparam("trigger%",ch)
		tp = integer(100.0 * (trigger_chan/100.0) * (trigger_loop/100.0) * (trigger_global/100.0))
		if ( DebugLoop ) {
			print("Trigger tp=",tp)
		}
		if ( tp < 100 ) {
			p = p{rand(100)<tp}
			# print("Trigger% enabled, tp=",tp)
		}
		if ( DebugLoop ) {
			print("chp B =",chp[ch])
		}
		if ( $.get_chanparam("quantall",ch) ) {
			q = $.get_chanparam("quant",ch)
			# print("quantall by q=",q)
			chp[ch] = quantize(chp[ch],q)
		}
		if ( DebugLoop ) {
			print("chp C =",chp[ch],"  ch=",ch," playing=",$.get_chlpparam("playloop",ch))
		}
		playing_loop = $.get_loopparam("playloop")
		playing_chan = $.get_chanparam("playloop",ch)
		# print("CH = ",ch," playing_loop=",playing_loop," _chan=",playing_chan)
		if ( ! ( playing_loop && playing_chan ) ) {
			# print("NOT Playing chan ",ch," in loop ",$.loopnum)
			$.looptask_phr[ch] = p
			$.looptask_vis[ch] = -1
			continue
		}

		chp[ch] = p

		if ( DebugLoop ) {
			print("Playing chan ",ch," in loop ",$.loopnum)
		}

		if ( Now > tm ) {
			print("Falling behind! dt=",Now-tm)
		}

		$.looptask_tid[ch] = $.realtime(p,tm,0,ch)
		if ( DoVisualize ) {
			# print("Doing looptask_vis in loop, p=",p)
			$.looptask_vis[ch] = task $.phrase_visualize(
							p,tm,$.loopnum)
			# print("LOOPTASK_VIS for ch=",ch," is ",$.looptask_vis[ch])
		}
		$.looptask_phr[ch] = p
		$.looptask_tm[ch] = tm

	}
	# if ( DoVisualize ) {
	# 	$.looptask_steps = task $.steps_visualize(tm,$.loopnum,loopleng)
	# }
}

method realtime(p,tm,dovis,ch) {
	if ( nargs() < 3 ) {
		print("WARNING, third argument not present in realtime!")
		dovis = 0
	}
	if ( nargs() < 4 ) {
		print("WARNING, fourth argument not present in realtime!")
		ch = $.currchan
	}
	if ( DebugReal )  print("REALTIME in onelooper p=",p)
	t = realtime(p,tm)

	if ( dovis && DoVisualize ) {
		# print("Doing (singlenote?) visualize in t.realtime p=",p)
		task $.phrase_visualize(p,tm,$.loopnum)
	}

	return(t)
}

method steps_visualize(tm,loopnum,loopleng) {
	nsteps = loopleng / $.stepsize
	for ( n=0; n<nsteps; n++ ) {
		msg = [0="/step",1=loopnum,2=n]
		# Don't spawn a new task - we want to be able to kill this task
		sleeptill(tm)
		$.parent.to_visualizers(msg)
		tm += $.stepsize
	}
}

method phrase_visualize(p,tm0,lp) {
	for ( nt in p ) {
		tm = tm0 + nt.time
		sleeptill(tm)
		if ( nt.type == NOTEON ) {
			msg = [0="/noteon",1=nt.chan,2=nt.pitch,3=nt.vol,4=lp]
			task $.sendvisat(tm,msg)
		} else if ( nt.type == NOTEOFF ) {
			msg = [0="/noteoff",1=nt.chan,2=nt.pitch,3=nt.vol,4=lp]
			task $.sendvisat(tm,msg)
		} else if ( nt.type == NOTE ) {
			msg = [0="/noteon",1=nt.chan,2=nt.pitch,3=nt.vol,4=lp]
			task $.sendvisat(tm,msg)
			msg = [0="/noteoff",1=nt.chan,2=nt.pitch,3=nt.vol,4=lp]
			task $.sendvisat(tm+nt.dur,msg)
		} else {
			# print("NOT SENDING VIS for nt=",nt)
		}
	}
}
method sendvisat(tm,msg) {
	sleeptill(tm)
	# $.parent.to_parameter_controllers(msg)
	$.parent.to_visualizers(msg)
}

method zoomin() {
	print("ZOOMIN!")
}
method zoomout() {
	print("ZOOMOUT!")
}

method oneloop_clear() {
	# print("oneloop_clear on loop ",$.loopnum," with ano!")
	$.setloopphrase('')
	$.kill_looptasks()
	$.init_looptask()
	$.realano()
	$.killosctasks()
	msg = [0="/clearloop",1=$.loopnum]
	$.parent.to_visualizers(msg)
}

method currchan_clear() {
	$.onechan_clear($.currchan)
}

method onechan_clear(ch) {
	# print("onechan_clear on loopnum=",$.loopnum," with ano! chan=",ch)
	p = $.loopphrase
	p -= $.loopphrase{??.chan == ch}
	$.setloopphrase(p)
	$.realano(ch)
	kill($.looptask_tid[ch])
}

method init_misc() {
	$.octshift = 0
	$.fractality = 0
	$.durscale = 1
	$.durscalerand = $.defaultdurscalerand
	$.velocityinc = $.defaultvelocityinc
	$.velocityrand = $.defaultvelocityrand

	$.setloopphrase('')
}

method setloopphrase(p) {
	sz = sizeof(p)
	if ( sz > 200 ) {
		print("FILTERING LOOP RANDOMLY BY 2 !?!?  sizeof(p)=",sz)
		p = p{rand(2)==0}
	}
	$.loopphrase = p
}

method killrealtime() {
	# print("KILLREALTIME called")
	kill($.tid)
	$.tid = -1
	$.kill_looptasks()
	$.init_looptask()
	$.killosctasks()
}

method killosctasks() {
	# print("KILLING OSC TASKS")
	for ( t in $.oscplaytasks ) {
		kill(t)
	}
	$.oscplaytasks = []
}

method killall() {
	Offsetpitch = 0
	print("Offsetpitch = ",Offsetpitch)
	$.killrealtime()
	# Don't reset $.shiftisdown!
	# $.tp_length = $.get_loopparam("loopleng")
	print("TYPO_RESTART, loop=",$.loopnum)
	print("killall is setting loopstart to 0")
	$.tp_loopstart = 0
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
	# print("chordchanged, p=",p)
	if ( $.get_globalparam("loopxposemode") ) {
		print("loopxposemode is on?")
		# p.time = 0
		# $.vals["loopxpose"] = p.pitch - 60
		print("NOT Setting loopxpose to ",$.vals["loopxpose"])
	} else if ( $.get_globalparam("grabmode") ) {
		print("grabmode?")
		r = ''
		# make it canonical (pitches starting from 0) and dedup
		for ( c in p ) {
			a = makenote(canonic(c.pitch))
			if ( (a & r) == '' ) {
				r |= a
			}
		}
		print("SETTING chordornament to r=",r)
		$.chordornament = r
	}
}

method apply_mods(p) {

	# print("APPLY_MODS p=",p)
	if ( p == '' ) {
		print("Hmmmm *********** apply_mods called on p=",p)
		return('')
	}
	if ( typeof(p) != "phrase") {
		print("Non phrase (",p,") given to apply_mods...")
		return('')
	}

	p.chan = $.currchan

	# print("apply_mods p=",p)
	if ( typeof(p) != "phrase" ) {
		print("Hmmm, p isn't a phrase at AA1a?")
		return()
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

	if ( typeof(p) != "phrase" ) {
		print("Hmmm, p isn't a phrase at AA1c?")
		return()
	}

	return(p)
}

method looper_input_cmd(keydown,cmd,pad,prox,fingeruid) {

	print("LOOPER_INPUT_CMD??")
	if ( cmd == "START" ) {
		return()
	}
	if ( cmd == "STOP" ) {
		$.oneloop_clear()
		return()
	}
}

method inc_tempo(f) {
	$.set_tempo(tempo()/2.0)
}
method dec_tempo(f) {
	$.set_tempo(tempo()*2.0)
}

### method force_length_16b() { $.force_length(16b) }
### 
### method inc_length(factor) {
### 	$.set_length($.tp_length*2.0)
### }
### method dec_length(factor) {
### 	$.set_length($.tp_length/2.0)
### }
### method get_length() {
### 	return($.tp_length)
### }
### 
### method set_length(newleng) {
### 	print("SETTING length of loop ",$.loopnum,"to",newleng)
### 
### 	# print("old leng=",$.tp_length," phrase=",$.loopphrase)
### 	p = $.loopphrase
### 	oldleng = $.tp_length
### 	p.length = oldleng
### 	$.tp_length = newleng
### 
### 	# Force the looped phrase to be that length, but
### 	# either repeating or truncating it
### 	if ( newleng > oldleng ) {
### 		# Don't repeat it blindly, vary it
### 		p = p + shuffle(p)
### 	}
### 	p = repleng(p,newleng)
### 	p.length = newleng
### 	$.setloopphrase(p)
### 	# print("   new leng=",$.tp_length," phrase=",$.loopphrase)
### }
### 
### method set_loop_length(nw) {
### 	print("SET_LOOP_LENGTH, nw=",nw)
### 	if ( $.tp_length == 0 ) {
### 		print("typo set_loop_length called, SETTING LENGTH, loopstart=",$.tp_loopstart,"  chan=",$.currchan)
### 		if ( $.loopphrase == '' ) {
### 			print("Nothing in loopphrase, so ignoring set_loop_length");
### 			return()
### 		}
### 		lng = nw - $.tp_loopstart
### 		lq = nextquant(lng,$.loopquant)
### 		if ( (lq - lng) > ($.loopquant/2) ) {
### 			# play_loop(tm)
### 			lq -= $.loopquant
### 		}
### 		if ( lq < 0 ) {
### 			print("lq<0 ? lq=",lq," $.tp[loopstart]=",$.tp_loopstart,"  nw=",nw,"  lng=",lng)
### 			lq = $.loopquant
### 			print("Forcing lq to ",lq)
### 		}
### 		$.tp_length = lq
### 		ls = prevquant(nw,lq)
### 		if ( ls != $.tp_loopstart ) {
### 			# If we've already passed what should
### 			# really be the start of the first
### 			# iteration of the loop, we should
### 			# play the loop right away,
### 			# so there's not a blank space
### 			t2 = $.tp_loopstart + $.tp_length
### 			$.play_loop(t2,loopleng)
### 			# $.playprev = t2
### 		}
### 
### 		print("SET_LOOP_LENGTH setting loopstart to ls=",ls)
### 		$.tp_loopstart = ls
### 		print("LOOP LENGTH set to ",lq," ( ",lq/1b," beats )")
### 
### 	}
### }

method looper_input_i(keydown,i,prox,uid) {

	# print("looper iput keydown=",keydown," Now=",Now," nw=",nw," quant=",$.stepsize)

	sz = sizeof($.phr)
	ii = integer(i * sz + 0.5) % sz
	p = $.phr[ii]

	$.looper_input_p(keydown,p,prox,uid,0)
}

method looper_input_rc(keydown,r,c,prox,uid) {
	print("LOOPER_INPUT_RC rc=",r,c)
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

	$.looper_input_p(keydown,p,prox,uid,0)
}

method finishnotes() {
	# print("FINISHNOTES")
	for ( uid in $.lastplayedphr ) {
		# print("FINISHNOTES uid=",uid)
		p = $.lastplayedphr[uid]
		# print("SHOULD BE CLEANING UP  p=",p)
		p.type = NOTEOFF
		p.time = 0
		if ( DebugReal ) print("REALTIME CLEANUP p=",p)
		realtime(p,0)
		if ( uid in $.lastplayedtid ) {
			kill($.lastplayedtid[uid])
		}
	}
	$.lastplayedphr = []
	$.lastplayedtid = []
	$.lastplayedtm = []
}

method looper_input_p(keydown,p,prox,uid,reallymidi) {

	print("LOOPER_INPUT_P keydown=",keydown,"uid=",uid,"p=",p)
	if ( typeof(p) != "phrase" ) {
		print("Hmmm, p isn't a phrase at XX?")
		return()
	}
	if ( p == '' ) {
		print("NULL phrase given to looper_input_p?")
		return()
	}
	$.looper_input_pq(keydown,p,prox,uid,reallymidi,$.stepsize)
}

method islooping() {
	return($.get_chanparam("recording",$.currchan))
}

# prox isn't used...

method looper_input_pq(keydown,p,prox,uid,reallymidi,qnt) {

	nw = nextquant(Now,qnt)
	# print("input_p  p=",p)

	if ( DebugReal )
		print("LOOPER_INPUT_PQ p=",p," qnt=",qnt," keydown=",keydown," nw=",nw)

	if ( $.xpose != 0 ) {
		p = transpose(p,$.xpose)
		print("IS transposing p=",p)
	}

	isrecording = $.islooping()

	if ( DebugReal )
		print("Looper_input_pq chan=",$.currchan," isrecording=",isrecording," keydown=",keydown," uid=",uid," reallymidi=",reallymidi)

	if ( keydown == 1 ) {

		# key just went down

		# If we're recording, we set
		# the start of the loop if it's not set already

		# print("keydown, loopstart=",$.tp_loopstart)

		if ( isrecording && ($.tp_loopstart == 0) ) {
			nq = prevquant(nw,$.loopquant)
			$.tp_loopstart = nq
			print("STARTING LOOOP!!  loopstart/nq=",nq," p=",p)
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

		p = $.apply_mods(p)
		# print("p after mods = ",p)
		if ( typeof(p) != "phrase" ) {
			print("Hmmm, p isn't a phrase at XX1b?")
			return()
		}
		if ( p == '' ) {
			return()
		}
		co = $.chordornament
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
		# print("REALTIME POSTMID recording uid=",uid," p=",p)
		$.lastplayedphr[uid] = p
		# print("keydown lastplayedphr for uid=",uid," is ",p)
		if ( $.sustainwhiledown ) {
			p.type = NOTEON
		}
		# print("REALTIME A p=",p)
		$.lastplayedtid[uid] = $.realtime(p,nw,1,$.currchan)
		$.lastplayedtm[uid] = nw
		return()
	}

	if ( ! (uid in $.lastplayedphr) ) {
		print("Hey, uid=",uid," is not in lastplayedphr?")
		return()
	}

	p = $.lastplayedphr[uid]
	# print("p from lastplayed uid=",uid," p=",p)
	lastdown = $.lastplayedtm[uid]

	killonup = $.vals["killonup"]
	if ( reallymidi == 0 && killonup ) {
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
		if ( DebugReal )
			print("NOT RECORDING!")
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
			$.realtime(p,nw,1,$.currchan)
		}
		return()
	}
	# We ARE recording
# print("ARE RECORDING, p=",p)

	# Realtime - timing of notes gets used

	d = nw-lastdown

	# print("LOOPING on keyup, p=",p," d=",d)

	newp = ''
	p.type = NOTE
	for ( tmpnt in p ) {
		if ( (tmpnt.time + tmpnt.dur) < d ) {
			tmpnt.dur = d - tmpnt.time
		} 
		newp |= tmpnt
	}
	p = newp
	# print("NEW p = ",p)

	tmpdt = lastdown - $.tp_loopstart
	while ( tmpdt < 0 ) {
		print("Adding loopleng to tmpdt !?")
		tmpdt += $.get_loopparam("loopleng")
	}

	if ( reallymidi==0 && killonup ) {
		killdt = Now-lastdown
		p1 = cut(p,CUT_TIME,0,killdt,TRUNCATE)
		# print("Truncated recorded killdt=",killdt," p1=",p1)
	} else {
		p1 = p
	}
	# print("p1=",p1)
	p1.time += nextquant(tmpdt,qnt)
	if ( p1.time <= lastdown ) {
		nw += qnt/2
	}
	d = nw-lastdown
	if ( d <= 0 )
		d = 1
	nextq = nextquant(d,qnt)
	p1.length = nextq
	# print("ADDING $=",$," p1=",p1," TO LOOP!!! chan=",$.currchan)

	if ( p1.dur == 0 ) {
		p1.dur = 6
		# print("dur==0, seet to ",p1.dur)
	}

	sizep1 = sizeof(p1)
	lim = $.get_loopparam("loopnotes")
	if ( sizeof($.loopphrase) > lim ) {
		print("LIMITING due to loopnotes =",lim)
		for ( n = 0; n < sizep1; n++ ) {
			r = rand(1,sizeof($.loopphrase))
			pp = $.loopphrase
			pp % r = ''
			$.setloopphrase(pp)
		}
	}
	p2 = $.loopphrase | p1

	p2 = dedup(p2)
	$.setloopphrase(p2)

	# p.time = 0
	p.type = NOTEOFF
	if ( DebugReal )
		print("END OF INPUT_PQ, p=",p)
	
	$.realtime(p,nw,1,$.currchan)
	# print("playing C p=",p," Now=",Now," nw=",nw)
}

method kill_later(tid,tm) {
	# print("kill_later tid=",tid)
	sleeptill(tm)
	kill(tid)
}

method realano(ch) {
	if ( DebugReal ) print("REALTIME D ano")
	if ( nargs() > 0 )
		realtime(ano(ch))
	else
		realtime(ano())
}

method allchan_fade() {
	if ( $.loopphrase != '' ) {
		p = $.loopphrase
		p.vol -= 10
		p -= p{??.vol==0}
		$.setloopphrase(p)
	}
}

method onechan_fade(ch) {
	if ( $.loopphrase != '' ) {
		p = $.loopphrase
		# print("onechan_fade ch=",ch," start=",p)
		pch = cut(p,CUT_CHANNEL,ch)
		p -= pch
		pch.vol -= 10
		pch -= pch{??.vol==0}
		p |= pch
		$.setloopphrase(p)
	}
}

method allchan_comb() {
	if ( $.loopphrase != '' ) {
		p = $.loopphrase
		p = p{rand(2)==0}
		$.setloopphrase(p)
	}
}

method onechan_comb(ch) {
	if ( $.loopphrase != '' ) {
		p = $.loopphrase
		# print("onechan_fade ch=",ch," start=",p)
		pch = cut(p,CUT_CHANNEL,ch)
		p -= pch
		pch = pch{rand(2)==0}
		p |= pch
		$.setloopphrase(p)
	}
}

method allchan_shuffle() {
	if ( $.loopphrase != '' ) {
		p = $.loopphrase
		p = shuffle(p)
		$.setloopphrase(p)
	}
}

method onechan_shuffle(ch) {
	if ( $.loopphrase != '' ) {
		p = $.loopphrase
		# print("onechan_fade ch=",ch," start=",p)
		pch = cut(p,CUT_CHANNEL,ch)
		p -= pch
		pch = shuffle(pch)
		p |= pch
		$.setloopphrase(p)
	}
}

method currchan_quantnow() {
	$.onechan_quantnow($.currchan)
}

method allchan_quantnow() {
	# Could be more efficient, but channels will likely be split apart soon
	for ( ch=1; ch<=$.nchannels; ch++ ) {
		$.onechan_quantnow(ch)
	}
}

method onechan_quantnow(ch) {
	if ( $.loopphrase != '' ) {
		p = $.loopphrase
		q = $.get_chanparam("quant",ch)
		print("Do_quantize quant=",q," ch=",ch)
		pch = cut(p,CUT_CHANNEL,ch)
		p -= pch
		pch = quantize(pch,q)
		p |= pch
		$.setloopphrase(p)
	}
}
# method currchan_debug1() {
# 	loopleng = $.get_loopparam("loopleng")
# 	print("debug1 loopleng = ",loopleng)
# 	$.loopphrase -= $.loopphrase{??.chan == $.currchan}
# 	$.loopphrase |= repleng('ad24',loopleng)
# }

method change_offset(o) {
	if ( o == Offsetpitch )
		return()
	print("Changing Offsetpitch to ",o)
	Offsetpitch = o
	$.realano()
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

method typo_setup(nphrases) {

	# Constants and setup

	$.minpitch = 34
	$.maxpitch = 105

	$.debug = 1
	$.tamefractal = 1
	$.loopnotelimit = 200
	# print("LOW NOTE LIMIT EXPERIMENT!")

	$.nnotes = 16

	$.sustainwhiledown = 1
	$.xpose = 0

	$.nnotesmax = 20
	$.minlength = 1b
	$.fixedsize = 0
	$.stepfile = 0

	$.npatterns = 10
	$.warpall = 0
	$.verbose = 0
	$.keyorder = "QAZWSXEDCRFVTGBYHNUJMIK,OL.";
	$.nletters = sizeof($.keyorder)
	# if ( nphrases > $.nletters ) {
	# 	print("HEY, nphrases is > nletters!?")
	# }
	$.nletters = nphrases
	$.debug = 0
	$.controllerinc = 5

	$.defaultvelocityinc = 20
	$.defaultvelocityrand = 2
	$.defaultdurscalerand = 1

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

	Tnumbers = ["0"=0,"1"=1,"2"=2,"3"=3,"4"=4,"5"=5,"6"=6,"7"=7,"8"=8,"9"=9]

	$.limits = [
		"A" = ["min"=0,"mid"=2,"max"=4,"inc"=1],
		"O" = ["min"=-3,"mid"=0,"max"=3,"inc"=1],
		"D" = ["min"=0.5,"mid"=1.0,"max"=4.0,"inc"=2.0],
		"Y" = ["min"=0,"mid"=1,"max"=5,"inc"=1],
		"F" = ["min"=0,"mid"=1,"max"=4,"inc"=1],
		"W" = ["min"=1,"mid"=2,"max"=5,"inc"=1]
	]

	# Per-pattern stuff

	$.typo = []

	$.setloopphrase('')
	$.lastplayedphr = []	# index is uid
	$.lastplayedtm = []	# index is uid
	$.lastplayedtid = []	# index is uid
	$.finger = []		# index is key(character)

	# print("END OF INIT, currpatt = ",$.currpatt)

	$.nextpattern = -1
	$.lastfract = ''
}

method change_shuffle(v) {
	$.setloopphrase(shuffle($.loopphrase))
}

method reset_xpose(dp) {
	$.xpose = 0
	print("transpose in chan=",$.currchan," is now ",$.xpose)
}

method adjust_xpose(dp) {
	$.xpose += dp
	print("transpose in chan=",$.currchan," is now ",$.xpose)
	$.setloopphrase(transpose($.loopphrase,dp))
	print("transposed loopphrase=",$.loopphrase)
}

# method set_octave(v) {
# 	dp = v - $.vals["octave"]  # do this first
# 	$.vals["octave"] = v
# 	$.setloopphrase(transpose($.loopphrase,dp * 12))
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

}

function ergox_galaxy2009v0_resetconsole(o) {
	o.stop()
}

function ergox_galaxy2009v0_midi_restart(o) {
	o.midi_restart()
}
function ergox_galaxy2009v0_osc_restart(o) {
	o.osc_restart()
}
