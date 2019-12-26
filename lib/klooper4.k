#
# klooper4
#
# For the 2x2 Kinect instrument (with control in the 4th pane)
#

INCDEC_MID = 0
INCDEC_MIN = -2
INCDEC_MAX = 2
INCDEC_INC = 1
INCDEC_DEC = -1
TypoDebug = 0
DebugDebug = 0
DebugOsc = 1
DebugJson = 1
DebugReal = 0
DebugMidi = 0
DebugParam = 0
DebugLoop = 0
DoFlash = 0
DoActive = 0
DoVisualize = 1
FlashFreq = 1b
DoBidule = 1
OscSleep = 0

#define xxx rereadlib();klooper4()

function klooper4() {

	print("KLOOPER4!")

	Osclisten = 7777
	Jsonlisten = 7778

#	if ( ! defined(Launchpad_output) ) {
#		print("You should define the Launchpad input device...")
#		global Launchpad_output
#		Launchpad_output = -1
#	}

	Offsetfilter = 0
	Offsetportfilter = Launchpad_output

	# tempo(500000)

	if ( Machine != "win" ) {
		print("ergox_klooper() only works on Windows, sorry!")
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

	t = new ergox_klooper4_mastertypo(patchprefix)
	t.start()
	t.waittilldone()
	t.stop()
}

class ergox_klooper4_mastertypo {

method init(patchprefix) {

	# print("ergox_klooper init started...") 

	$.note_area_limit = 0.006
	$.slider_area_limit = 0.13
	$.button_area_limit = 0.15
	$.numprograms = 3
	# $.slider1 = "pitchbend"
	$.slider1 = "quant"
	$.last_note_channel = 1
	$.first_preset_fnum = 0
	$.debugcopy = 0
	$.midi_keyboard_count = 0
	$.tuio_sid_note = []
	$.tuio_sid_active = []
	$.tuio_sid_pitchbend = []
	$.tuio_sid_x = []
	$.tuio_sid_y = []
	$.tuio_sid_z = []

	$.oldMerge = Merge
	Merge = 0

	# Drums are going to be on channels 7 and 8,
	# so we don't want those to be affected by Offsetpitch
	$.oldOffsetfilter = Offsetfilter
	Offsetfilter = (1<<6 | 1<<7 )

	$.oscclock = 0
	$.dir = "."
	$.last_transrand = 0
	$.last_corner_trans = 0
	$.last_corner_fade = 0

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
		"bidule" = "set_bidule",
		"scale" = "set_scale",
		"tempo" = "set_tempo",
		# "loopleng"="change_global_loopleng",
		"soundset" = "set_soundset"
		]

	$.globalparamlist = [
		"drumfade" = "toggle",
		"bidule" = "toggle",
		"notedur" = "int",
		"forcedur" = "toggle",
		"repqnt" = "int",
		"chordize" = "toggle",
		"loopxposemode" = "toggle",
		"realxposemode" = "toggle",
		"seqleng" = "int",
		"tempo" = "int",
		"soundset" = "string",
		"grabmode" = "toggle",
		"sequence" = "int",
		"loopvis" = "int",
		"scadjust" = "toggle",
		"scale" = "string",
		"notefreq" = "int",
		"fadeout" = "string",
		"loopleng" = "int",
		"transposed2" = "toggle",
		"transposeu5" = "toggle",
		"transposeu7" = "toggle",
		"trigger%" = "int",
		"kinedist" = "int"
		]

	$.perchanparamlist = [
		"recording" = "toggle",
		"playloop" = "toggle",
		"velocity" = "int",
		"stutter" = "toggle",
		"prestutter" = "toggle",
		"stuttern" = "int",
		"stuttertm" = "int",
		"volume" = "int",
		"quantnowv" = "int",
		"quantrec" = "int",
		"quantreal" = "int",
		"trigger%" = "int",
		"trigable" = "toggle",
		"volvary%" = "int",
		"isdrum" = "toggle",
		"loopleng" = "int",
		"fadeout" = "string",
		"loopnotes" = "int",
		"program" = "int"
		]

	$.chanparamset = [
		"volume" = "set_volume"
		]

	$.globalparam = []
	for ( nm in $.globalparamlist ) {
		type = $.globalparamlist[nm]
		$.set_globalparam(nm,$.null_value_of_type(type))
	}
	$.set_globalparam("scadjust",1)

	$.anykeyboard = 0
	$.lastwarntime = Now

	$.patchprefix = patchprefix

	# $.notedur = 63
	$.notefreq = 63
	$.notevol = 63
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

	$.scale_sequence = [0="Chinese",1="African",2="Arabian",3="New Age",4="Fifths",5="Chromatic"]

	$.buttprimed = ""

	# Now create the loopers

	vals = [ "chan" = 1, "shape" = 5 ]
	# fm8
	vals["nprograms"] = 20

	ch = 1
	$.currloop = 0
	$.nloops = 8
	$.ergox_klooper = []
	for ( lp=0; lp<$.nloops; lp++ ) {
		$.ergox_klooper[lp] = new ergox_klooper4_onelooper($,lp,$.stepsize,lp+1,$.nphrases,vals,$.loopquant)
	}

	# print("Init done, now starting OSC ...") 

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
	}

	$.jsonf = open(string(Jsonlisten)+"@127.0.0.1","rf","tcpip_listen")
	print("Listening for JSON on ",Jsonlisten)
	if ( $.jsonf == "" ) {
		print("Unable to listen on ",Jsonlisten," !?")
		$.jsontid = -1
	} else {
		$.jsontid = task $.jsontask()
	}

	$.parametercontrollers = []
	$.registerparametercontroller("127.0.0.1",1385)

	$.visualizers = []
	$.step_visualizers = []

	# $.registervisualizer("127.0.0.1",1385,0)
	# vismachine = "nosuchbook";
	# vismachine = "antiprism";
	# $.registervisualizer(vismachine,3333,0)

	bidulehost = "127.0.0.1"
	biduleport = 3210
	print("Sending OSC to BIDULE, hostname=",bidulehost," port=",biduleport)
	$.open_bidule(Hostname,biduleport)

	# $.lp=",$.loopnum," send_all_values()

	$.reset()

	$.last_flash = []
	$.last_flash_color = []
	$.next_flash_color = []
	for ( ch=1; ch<=$.nchannels; ch++ ) {
		$.last_flash[ch] = 0
		$.last_flash_color[ch] = -1
		$.next_flash_color[ch] = -1
	}

	# launchpad_reset()

	# $.getallparams()

	print("NOW ACTIVE!")
}

method getallparams()
{
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

	t = $.ergox_klooper[$.currloop]
	isdrum = t.get_chanparam("isdrum")
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
	isdrum = t.get_chanparam("isdrum")
	if ( isdrum ) {
		p = $.grid2drum(r,c)
		p.vol = t.get_chanparam("velocity")
		# print("isdrum rc=",r,c,p)
	} else {
		# print("playgrid rc=",r,c)
		p = $.cell[r][c]
		if ( p == '' ) {
			p = $.fingernote(r,c,prox,rawx,rawy)
			p.vol = t.get_chanparam("velocity")
			# print("playgrid is using fingernote p=",p)
		} else {
			# print("Using grabbed cell value = ",p)
		}
	}
	if ( down ) {
		p.type = NOTEON
	} else {
		p.type = NOTEOFF
	}
	# print("rc=",r,c," rawxy=",rawx,rawy," down=",down,"fingernote=",p)

	$.handle_midi_keyboard(p,$.currloop)
}

method set_globalparam(nm,v) {
	if ( DebugParam )
		print("SET GLOBAL PARAM nm=",nm," v=",v)
	# $.(nm) = v
	$.globalparam[nm] = v
}

method set_transpose_hack() {
	d2 = $.get_globalparam("transposed2")
	u5 = $.get_globalparam("transposeu5")
	u7 = $.get_globalparam("transposeu7")
	t = (d2 * -2) + (u5 * 5) + (u7 * 7)
	# print("TOTAL transpose hack = ",t)
	$.set_transpose(t)
}

method osctask() {
	global ergox_klooper4_osc_restart
	onexit(ergox_klooper4_osc_restart,$)
	while ( (d=get($.oscf)) != Eof ) {
		if ( typeof(d) == "array" ) {
			k = d["elements"]
			for ( n=0; n<k; n++ ) {
				$.handle_osc(d[n])
			}
		} else {
			$.handle_osc(d)
		}
	}
}

method handle_tuio_alive(d) {
	# print("alive=",d)
	nd = sizeof(d)
	tmparr = arraycopy($.tuio_sid_active)
	for ( n=2; n<nd; n++ ) {
		sid = d[n]
		delete tmparr[sid]
	}
	for ( sid in tmparr ) {
		t = $.sid_to_type(sid)
		if ( t == "note" ) {
			nt = $.tuio_sid_note[sid]
			loopnum = nt.chan - 1
			nt.type = NOTEOFF
			# print("Now=",Now," NOTE OFF SID ",sid," nt=",nt)
			$.handle_midi_keyboard(nt,loopnum)
		} else if ( t == "slider" ) {
			slider = $.sid_to_slider(sid)
			# print("SLIDER ",slider," WENT AWAY!!")
			$.handle_tuio_slider(sid,slider,0,0,0)
		} else if ( t == "button" ) {
			button = $.sid_to_button(sid)
			# print("BUTTON ",button," WENT AWAY!!")
		} else {
			print("Unknown sid type? sid=",sid," t=",t)
		}
		# print("DELETING SID=",sid," note=",$.tuio_sid_note[sid])
		delete $.tuio_sid_active[sid]
		delete $.tuio_sid_note[sid]
		delete $.tuio_sid_z[sid]
	}
}

method do_pitchbend(sid,ch,x,f) {
	# PITCHBEND
	nt = ''
	if ( f == 0 ) {
		# print("ZEROING PITCHBEND for ch=",ch)
		nt = pitchbend(ch,0)
		delete $.tuio_sid_pitchbend[sid]
	}
	else if ( sid in $.tuio_sid_pitchbend ) {
		pb = $.tuio_sid_pitchbend[sid]
		# print("ADJUST B PITCHBEND, pb=",pb)
		oldx = pb["x"]
		oldval = pb["value"]
		dx = x - oldx
		smooth = 3
		newval = ((smooth-1)*oldval + (oldval+dx*8192)) / smooth
		newx = ((smooth-1)*oldx + x) / smooth
		# print("ADJUST B PITCHBEND ch=",ch," x=",x," oldx=",pb["x"]," dx=",dx," newx=",newx," newval=",newval)
		$.tuio_sid_pitchbend[sid] = ["value"=newval,"x"=newx]
		nt = pitchbend(ch,newval)
		# print("ADJUST C PITCHBEND, pb=",$.tuio_sid_pitchbend[sid])
	} else {
		# print("\nNEW PITCHBEND ch=",ch," x=",x)
		$.tuio_sid_pitchbend[sid] = ["value"=0,"x"=x]
		nt = pitchbend(ch,0)
	}
	return(nt)
}

method controller_for_slider(sid,slider,ch,x,y,f) {
	nt = ''
	if ( slider == 0 ) {
		# MODULATION
		x = (x - 0.2) * 1.4
		if ( x < 0 ) {
			x = 0
		}
		v = integer(x*128) % 128
		nt = controller(ch,0x01,v)
	} else if ( slider == 1 ) {
		if ( $.slider1 == "pitchbend" ) {
			nt = $.do_pitchbend(sid,ch,x,f)
		} else {
			if ( x < 0.25 )
				q = 1b/2
			else if ( x < 0.6 )
				q = 1b/4
			else if ( x < 0.85 )
				q = 1b/8
			else
				q = 0
			# print("X = ",x,"  Q = ",q," f=",f)
			t = $.ergox_klooper[ch-1]
			oldq = t.get_chanparam("quantreal")
			if ( q != oldq ) {
				# print("CHANGED QUANT SLIDER x=",x," ch=",ch," Q=",q)
				t.set_chanparam("quantreal",q)
			}
		}
	} else {
		print("Unknown slider value in controller_for_slider: ",slider)
	}
	return(nt)
}

method handle_tuio_slider(sid,slider,x,y,f) {
	if ( $.last_note_channel <= 0 ) {
		print("No $.last_note_channel, ignoring slider")
		return()
	}
	ch = $.last_note_channel
	nt = $.controller_for_slider(sid,slider,ch,x,y,f)
	if ( nt != '' ) {
		# print("PLAYING slider nt=",nt)
		$.realtime(nt,Now)
		# if ( ! sid in $.tuio_sid_active ) {
		# 	print("SLIDER!  ch=",ch," xyf = ",x,y,f)
		# }
		$.tuio_sid_active[sid] = 1
		$.tuio_sid_note[sid] = nt
		$.tuio_sid_x[sid] = x
		$.tuio_sid_y[sid] = y
	}
}

method handle_tuio_button(sid,button,x,y,f) {
	if ( sid in $.tuio_sid_active ) {
		# Already down
	} else {
		print("BUTTON went down!  sid=",sid," button=",button," f = ",f)
		$.tuio_sid_active[sid] = 1
		if ( button == 0 ) {
			ch = $.last_note_channel
			t = $.ergox_klooper[ch-1]
			prog = (t.get_chanparam("program")+1)%($.numprograms)
			t.set_chanparam("program",prog)
			$.ano()
			print("BUTTON: PATCH!! ch=",ch," prog=",prog)
			$.realtime(progchange(prog+1,ch),Now)
		} else if ( button == 1 ) {
			sc = $.get_globalparam("scale")
			nsc = sizeof($.scale_sequence)
			for ( n=0; n<nsc; n++ ) {
				if ( $.scale_sequence[n] == sc )
					break
			}
			if ( n >= nsc ) {
				n = 0
			} else {
				n = (n + 1) % nsc
			}
			sc = $.scale_sequence[n]
			print("BUTTON: NEW SCALE n=",n," scale=",sc)
			$.set_globalparam("scale",sc)
			$.set_scale()
			$.ano()
				
		} else if ( button == 2 ) {
			print("BUTTON: TRANSPOSE!!")
			$.do_transrand()
			$.ano()
		}
	}
}

method sid_to_type(sid) {
	ch = sid/1000
	if ( ch < 4 ) {
		return("note")
	} else if ( ch < 6 ) {
		return("slider")
	} else {
		return("button")
	}
}

method sid_to_slider(sid) {
	ch = sid/1000
	if ( ch == 4 || ch == 5 )
		return(ch-4)
	else
		return(-1)
}

method sid_to_button(sid) {
	ch = sid/1000
	if ( ch > 5 )
		return(ch-6)
	else
		return(-1)
}

method z_message(ch,v) {
	# channel pressure
	return(midibytes((ch-1) + 0xd0, v))
}

method x_to_pitch(x) {
	pitch = 30 + 70 * x
	return(pitch)
}

method handle_tuio_25D_set(sid,x,y,z,w,h,f) {
	ch = sid/1000

	# First three areas are channels 1-3, the rest are sliders and buttons
	if ( ch >= 4 ) {
		slider = $.sid_to_slider(sid)
		if ( slider >= 0 ) {
			if ( f >= $.slider_area_limit ) {
				$.handle_tuio_slider(sid,slider,x,y,f)
			} else {
				# print("IGNORING slider, f=",f)
			}
			return()
		}
		# print("BUTTON sid=",sid," xy=",x,y," wh=",w,h," f=",f)
		button = $.sid_to_button(sid)
		if ( button >= 0 ) {
			if ( f >= $.button_area_limit ) {
				$.handle_tuio_button(sid,button,x,y,f)
			} else {
				# print("IGNORING button, f=",f)
			}
			return()
		}
		print("HMMM sid=",sid," is neither button nor slider!?")
	}

	if ( f < $.note_area_limit ) {
		# print("Ignoring note, f=",f)
		return()
	}
	# print("SET last_note_channel =",ch," xyf=",x,y,f)
	$.last_note_channel = ch
	loopnum = ch - 1
	pitch = $.x_to_pitch(x)
	vol = 20 + 118 * y
	if ( vol > 127 )
		vol = 127
	if ( sid in $.tuio_sid_note ) {
		dx = x - $.tuio_sid_x[sid]
		dy = y - $.tuio_sid_y[sid]
		dist = sqrt(dx*dx + dy*dy)

		# print("SID=",sid,"  Z = ",z)
		# Range of z we're interested in is from 0.1 to 0.25
		minz = 0.05
		maxz = 0.20
		if ( z > minz ) {
			if ( z > maxz ) {
				z = maxz
			}
			if ( sid in $.tuio_sid_z ) {
				oldz = $.tuio_sid_z[sid]
				smooth = 3
				newz = ((smooth-1) * oldz + z) / smooth
				# print("SMOOTHED oldz=",oldz," Z=",z," newz=",newz)
				z = newz
			} else {
				# print("FIRST Z = ",z)
			}
			$.tuio_sid_z[sid] = z
			v = integer(((z - minz) *  128) / (maxz-minz))
			nt = $.z_message(ch,v)
			$.realtime(nt,Now)
		} else {
			# Shouldn't really send it ALL the time, but...
			v = 0
			nt = $.z_message(ch,0)
			$.realtime(nt,Now)
		}

		if ( ! ( sid in $.tuio_sid_active ) ) {
			print("Hey, sid=",sid," is in tuio_sid_note, but not tuio_sid_active!?")
			return()
		}

		# print("sid already down, dist=",dist," xy=",x,y," oldxy=",
		# 	$.tuio_sid_x[sid],$.tuio_sid_y[sid])

		kinedist = $.get_globalparam("kinedist") / 1000.0
		if ( dist > kinedist ) {
			# print("dist>",kinedist)
			# let go of the old pitch, and play the new one
			nt = $.tuio_sid_note[sid]
			nt.type = NOTEOFF
			# print("Now=",Now," MOVE NOTE OFF SID ",sid," nt=",nt)
			$.handle_midi_keyboard(nt,loopnum)
			nt.type = NOTEON
			nt.pitch = pitch
			nt.vol = vol
			# print("Playing note on channel ",nt.chan)
			# print("Now=",Now," MOVE NOTE ON SID ",sid," nt=",nt,"  +++++")
			# print("   sid=",sid," noteoff/noteon for pitch=",pitch)
			$.handle_midi_keyboard(nt,loopnum)

			$.tuio_sid_note[sid] = nt
			$.tuio_sid_x[sid] = x
			$.tuio_sid_y[sid] = y
		} else {
			# print("   dist<=kinedist? dist=",dist," kinedist=",kinedist)
		}
	} else {
		nt = makenote(pitch)
		nt.dur = 1b/16
		nt.chan = ch
		nt.vol = vol
		nt.type = NOTEON
		# print("NEW note on channel ",nt.chan)
		# print("Now=",Now," NEW NOTE ON ",sid," nt=",nt,"   +++++")
		$.handle_midi_keyboard(nt,loopnum)
		$.tuio_sid_active[sid] = 1
		$.tuio_sid_note[sid] = nt
		$.tuio_sid_x[sid] = x
		$.tuio_sid_y[sid] = y
		# $.tuio_sid_z[sid] = z
	}
	return()
}

method handle_osc(d) {

	# if ( DebugOsc ) 
	# 	print("handle_osc d=",d)

	addr = d[0]
	t = $.ergox_klooper[$.currloop]
	ch = t.get_currchan()

	if ( substr(addr,1,6) == "/tuio/" ) {
		cmd = d[1]
		if ( cmd == "alive" ) {
			$.handle_tuio_alive(d)
		} else if ( cmd == "fseq" ) {
			# do nothing?
		} else if ( cmd == "set" ) {
			if ( addr == "/tuio/25Dblb" ) {
				sid = d[2]
				x = d[3]
				y = d[4]
				z = d[5]
				angle = d[6]
				w = d[7]
				h = d[8]
				f = d[9]
				# print("25Dblb sid=",sid," z=",z," w=",w," h=",h," f=",f)
				$.handle_tuio_25D_set(sid,x,y,z,w,h,f)
			} else if ( addr == "/tuio/25Dcur" ) {
				sid = d[2]
				x = d[3]
				y = d[4]
				z = d[5]
				w = 0.0
				h = 0.0
				f = 0.0
				$.handle_tuio_25D_set(sid,x,y,z,w,h,f)
			} else if ( addr == "/tuio/2Dcur" ) {
				print("UNIMPLEMENTED: /tuio/2Dcur !!")
			}
		}
	} else if ( addr == "/nth/playgrid" ) {
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
		lp = d[1] - 1
		$.currloop = lp
		t = $.ergox_klooper[$.currloop]
		print("SETTING CHANNEL =",t.get_currchan())
	} else if ( addr == "/nth/currentloop" ) {
		print("/nth/currentloop IS BEING IGNORED!")
		return()
	} else if ( addr == "/nth/perchan/set" ) {
		nm = d[1]
		looptoset = d[2]-1
		v = d[3]
		t = $.ergox_klooper[looptoset]
		if ( nm in $.perchanparamlist ) {
			pt = $.perchanparamlist[nm]
			if ( pt == "toggle" ) {
				t.set_chanparam(nm,$.ison(nm,v))
			} else if ( pt == "int" ) {
				# The value of v might be
				# a 'beat' value like 3b/4
				en = eval_number(v)
				if ( ! defined(en) )
					en = -1
				t.set_chanparam(nm,integer(en))
			} else if ( pt == "float" ) {
				t.set_chanparam(nm,float(v))
			} else if ( pt == "string" ) {
				t.set_chanparam(nm,v)
			} else {
				print("Unknown parameter type for nm=",nm)
			}
			if ( nm in $.chanparamset ) {
				t.($.chanparamset[nm])(ch)
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
				if ( nm == "transposed2" ||
					nm == "transposeu5" ||
					nm == "transposeu7") {
					$.set_transpose_hack()
				}
			} else if ( pt == "int" ) {
				# The value of v might be
				# a 'beat' value like 3b/4
				en = eval_number(v)
				if ( ! defined(en) )
					en = -1
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
			$.do_transrand()
		} else if ( action == "fade" ) {
			$.all_loops("do_fade")
		} else if ( action == "comb" ) {
			$.all_loops("do_comb")
		} else if ( action == "shuffle" ) {
			$.all_loops("do_shuffle")
		} else if ( action == "quantnow" ) {
			$.all_loops("do_quantnow")
		} else {
			print("UNKNOWN global action: ",action)
		}
	} else if ( addr == "/nth/perchan/action") {
		action = d[1]
		lp = d[2]-1
		t = $.ergox_klooper[lp]
		if ( DebugParam )
			print("NTH LOOP ACTION = ",d[1])
		if ( action == "clear" ) {
			t.oneloop_clear()
		} else if ( action == "quantnow" ) {
			t.do_quantnow()
		} else if ( action == "fade" ) {
			t.do_fade(1)
		} else if ( action == "comb" ) {
			t.do_comb()
		} else if ( action == "shuffle" ) {
			t.do_shuffle()
		} else if ( action == "comb" ) {
			$.all_loops("onechan_comb",ch)
		} else if ( action == "shuffle" ) {
			$.all_loops("onechan_shuffle",ch)
		} else {
			print("UNKNOWN perchan action: ",action)
		}
	} else if ( addr == "/registerclient" ) {
		$.registerclient(d[1],d[2])
	} else if ( addr == "/unregisterclient" ) {
		$.registerclient(d[1],d[2])
	} else {
		print("osctask doesn't recognize: ",d)
	}
}

method do_transrand() {
	if ( (Now-$.last_transrand) < milliclicks(1000) ) {
		$.set_transpose(0)
		print("Multiple Quick TransRand == TransReset!\n");
	} else {
		trans = [0=3,1=5,2=7]
		tp = (rand(2)*2-1) * trans[rand(sizeof(trans))]
		$.set_transpose($.get_transpose()+tp)
		# print("SINGLE TransRand!")
	}
	$.last_transrand = Now
}

method jsontask() {
	global ergox_klooper4_json_restart
	onexit(ergox_klooper4_json_restart,$)

	# Input will start coming as soon as a connection is open,
	# and setting the fifotype on the socket inside handle_json is
	# too late, so we change the default.
	fifoctl("default","type","l")

	while ( (x=get($.jsonf)) != Eof ) {
		task $.handle_json(x)
	}
	print("JSONTASK ends!?")
}

method handle_json(jsonconn) {

	if ( DebugJson > 1 )
		print("New JSON connection!")

	while ( (d=get(jsonconn["r"])) != Eof ) {
		if ( substr(d,1,1) == "{" ) {
			if ( DebugJson > 1 )
				print("GOT JSON!! d=",d)
			j = $.string2json(d)
			ret = $.jsonhandler(j)
			if ( DebugJson > 1 )
				print("SENDING BACK ret=",ret)
			put(jsonconn["w"],ret)
			break
		}
	}
	close(jsonconn["r"])
	close(jsonconn["w"])
}

# This is a silly way of doing substitute, should it be built-in?
method substitute(s,c1,c2) {
	w = split(s,c1)
	nw = sizeof(w)
	r = ""
	for ( n=0; n<nw; n++ ) {
		if ( n > 0 )
			r += c2 
		r += w[n]
	}
	return(r)
}

# JSON handling should probably be built-in
method string2json(d)
{
	d = " "+d+" "   # to ensure that the split stuff works
	d = $.substitute(d,":","=")
	d = $.substitute(d,"{","[")
	d = $.substitute(d,"}","]")
	if ( DebugJson > 1 )
		print("STRING2JSON = ",d)
	eval "JSON="+d
	return(JSON)
}

method jsonok() {
	return( "{\"jsonrpc\": \"2.0\", \"result\": 0 }\r\n" )
}

method jsonerr(e,id) {
	if ( typeof(e) != "string" ) {
		print("Hey, e isn't a string in jsonerr? e=",e)
	}
	return( "{\"jsonrpc\": \"2.0\", \"error\": {\"code\": -32700, \"message\": \"" + string(e) + "\"}, \"id\": "+string(id)+" }\r\n" )
}

method jsonresult_str(r,id) {
	return( "{\"jsonrpc\": \"2.0\", \"result\": \"" + string(r) + "\", \"id\": \""+string(id)+"\" }\r\n" )
}

method jsonhandler(j) {

	if ( ! ("method" in j) ) {
		return($.jsonerr("No method in json?",-1))
	}

	id = j["id"]
	meth = j["method"]
	params = j["params"]

	if ( meth == "echo" ) {
		return( $.jsonresult_str(params["value"],id) )
	}
	if ( meth == "ping" ) {
		return( $.jsonresult_str("True",id) )
	}
	if ( meth == "perchan_set" ) {
		# print("PERCHAN_SET params=",params)
		nm = params["name"]
		looptoset = params["channel"]
		v = params["value"]
		# print("perchan_set, name=",nm," ch/looptoset=",params["channel"]," v=",v)

		t = $.ergox_klooper[looptoset]
		ch = t.get_currchan()
		if ( ! (nm in $.perchanparamlist) ) {
			return($.jsonerr("UNKNOWN loop parameter: "+nm,id))
		}
		pt = $.perchanparamlist[nm]
		if ( pt == "toggle" ) {
			t.set_chanparam(nm,$.ison(nm,v))
		} else if ( pt == "int" ) {
			# The value of v might be
			# a 'beat' value like 3b/4
			en = eval_number(v)
			if ( ! defined(en) )
				en = -1
			t.set_chanparam(nm,integer(en))
		} else if ( pt == "float" ) {
			t.set_chanparam(nm,float(v))
		} else if ( pt == "string" ) {
			t.set_chanparam(nm,v)
		} else {
			print("Unknown parameter type for nm=",nm)
		}
		if ( nm in $.chanparamset ) {
			t.($.chanparamset[nm])(ch)
		}
		return( $.jsonok("True",id) )
	}
	if ( meth == "global_set" ) {
		nm = params["name"]
		v = params["value"]
		# print("global_set, name=",nm," v=",v)
		if ( nm in $.globalparamlist ) {
			pt = $.globalparamlist[nm]
			if ( pt == "toggle" ) {
				$.set_globalparam(nm,$.ison(nm,v))
				if ( nm == "transposed2" ||
					nm == "transposeu5" ||
					nm == "transposeu7") {
					$.set_transpose_hack()
				}
			} else if ( pt == "int" ) {
				# The value of v might be
				# a 'beat' value like 3b/4
				en = eval_number(v)
				if ( ! defined(en) )
					en = -1
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
			print("UNKNOWN global parameter: "+nm)
			return($.jsonerr("UNKNOWN global parameter: "+nm,id))
		}
		return( $.jsonok("True",id) )
	}
	if ( meth == "global_action" ) {
		action = params["action"]
		print("GLOBAL ACTION = ",action)
		if ( action == "clear" ) {
			$.all_loops("oneloop_clear")
		} else if ( action == "transreset" ) {
			$.set_transpose(0)
		} else if ( action == "transrand" ) {
			$.do_transrand()
		} else if ( action == "fade" ) {
			$.all_loops("do_fade")
		} else if ( action == "comb" ) {
			$.all_loops("do_comb")
		} else if ( action == "shuffle" ) {
			$.all_loops("do_shuffle")
		} else if ( action == "quantnow" ) {
			$.all_loops("do_quantnow")
		} else {
			print("UNKNOWN global action: ",action)
			return($.jsonerr("UNKNOWN global action: "+action,id))
		}
		return( $.jsonok("True",id) )
	}
	if ( meth == "perchan_action") {
		action = params["action"]
		lp = params["channel"]
		print("PERCHAN ACTION = ",action," chan=",params["channel"]," lp=",lp)
		t = $.ergox_klooper[lp]
		if ( DebugParam )
			print("NTH LOOP ACTION = ",d[1])
		if ( action == "clear" ) {
			t.oneloop_clear()
		} else if ( action == "quantnow" ) {
			t.do_quantnow()
		} else if ( action == "fade" ) {
			t.do_fade(1)
		} else if ( action == "comb" ) {
			t.do_comb()
		} else if ( action == "shuffle" ) {
			t.do_shuffle()
		} else if ( action == "comb" ) {
			$.all_loops("onechan_comb",ch)
		} else if ( action == "shuffle" ) {
			$.all_loops("onechan_shuffle",ch)
		} else {
			print("UNKNOWN perchan action: ",action)
			return($.jsonerr("UNKNOWN perchan action: "+action,id))
		}
		return( $.jsonok("True",id) )
	}
	if ( meth == "current_channel" ) {
		lp = params["channel"]
		$.currloop = lp
		t = $.ergox_klooper[$.currloop]
		print("SETTING CHANNEL =",t.get_currchan(),"  currloop=",lp)
		return( $.jsonok("True",id) )
	}

	return($.jsonerr("Klooper has no method named "+meth,-1))
		
	addr = d[0]
	t = $.ergox_klooper[$.currloop]
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
	} else if ( addr == "/nth/currentloop" ) {
		print("/nth/currentloop IS BEING IGNORED!")
	} else if ( addr == "/registerclient" ) {
		$.registerclient(d[1],d[2])
	} else if ( addr == "/unregisterclient" ) {
		$.registerclient(d[1],d[2])
	} else {
		return("jsontask doesn't recognize: "+string(d))
	}
	return("")
}


method change_global_loopleng(lng) {
	# It comes in as a string like "4b"
	lng = eval_number(lng)
	print("CHANGING GLOBAL LOOPLENG!! lng=",lng)
	$.all_loops("change_loopleng","loopleng",lng)
}

method all_loops(action,...) {
	for ( lp in $.ergox_klooper ) {
		t = $.ergox_klooper[lp]
		# print("ALL LOOPS lp=",lp," t=",t)
		t.(action)(...)
	}
}

method get_scale() {
	return($.curr_scale)
}

method set_soundset() {
	nm = $.get_globalparam("soundset")
	# print("SET SOUNDSET = ",nm)
	if ( nm == "One" ) {
		$.bidule_enable("Omnisphere_0",0)
		$.bidule_enable("Omnisphere_1",1)
		$.bidule_enable("Omnisphere_2",1)
		$.bidule_enable("Omnisphere_3",1)
	} else if ( nm == "Two" ) {
		$.bidule_enable("Omnisphere_0",1)
		$.bidule_enable("Omnisphere_1",0)
		$.bidule_enable("Omnisphere_2",1)
		$.bidule_enable("Omnisphere_3",1)
	} else if ( nm == "Three" ) {
		$.bidule_enable("Omnisphere_0",1)
		$.bidule_enable("Omnisphere_1",1)
		$.bidule_enable("Omnisphere_2",0)
		$.bidule_enable("Omnisphere_3",1)
	} else if ( nm == "Four" ) {
		$.bidule_enable("Omnisphere_0",1)
		$.bidule_enable("Omnisphere_1",1)
		$.bidule_enable("Omnisphere_2",1)
		$.bidule_enable("Omnisphere_3",0)
	}
}
method bidule_enable(nm,mode) {
	msg = [0="/"+nm+"/Mode",1=mode]
	$.to_bidule(msg)
}

method set_bidule() {
	nm = $.get_globalparam("bidule")
	msg = [0="/play",1=nm]
	print("SENDING bidule on/off =",msg)
	$.to_bidule(msg)
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
	for ( lp in $.ergox_klooper ) {
		t = $.ergox_klooper[lp]
		t.set_loop_needs_scaling()
	}
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
		if ( OscSleep > 0 )
			millisleep(OscSleep)
	}
}

method to_visualizers(msg) {
	for ( f in $.visualizers ) {
		# print("Sending msg=",msg)
		mdep("osc","send",f,msg)
		if ( OscSleep > 0 )
			millisleep(OscSleep)
	}
}

method to_step_visualizers(msg) {
	for ( f in $.step_visualizers ) {
		mdep("osc","send",f,msg)
		if ( OscSleep > 0 )
			millisleep(OscSleep)
	}
}

method to_bidule(msg) {
	if ( DoBidule ) {
		if ( DebugOsc ) {
			print("OSC to_bidule msg=",msg)
		}
		mdep("osc","send",$.bidule,msg)
	}
}

method open_bidule(host,port) {
	portaddr = string(port)+"@"+host
	$.bidule = open(portaddr,"wb","osc_send")
}

method registervisualizer(host,port,dosteps) {
	portaddr = string(port)+"@"+host
	for ( f2 in $.visualizers ) {
		if ( $.visualizers[f2] == portaddr ) {
			# print("Already registered, ignoring re-register")
			return()
		}
	}
	f = open(portaddr,"wb","osc_send")
	if ( f < 0 ) {
		print("UNABLE TO OPEN VISUALIZER CONNECTION to ",portaddr," !!!")
		return()
	}
	$.visualizers[f] = portaddr
	if ( dosteps ) {
		$.step_visualizers[f] = portaddr
	}
	print("VISUALIZER CLIENT REGISTERED! portaddr=",portaddr," f=",f)
}


method to_osc_clients(msg) {
	# print("to_osc_clients is disabled (msg=",msg,")")
	return()
	if ( DebugOsc ) {
		print("to_osc_clients msg=",msg)
		# s = sprintf("OSC %s",string(msg))
		# s = substr(s,1,20)
	}
	for ( f in $.oscclients ) {
		if ( DebugOsc > 1 )
			print("Sending msg=",msg," to oscclient f=",f)
		mdep("osc","send",f,msg)
		if ( OscSleep > 0 )
			millisleep(OscSleep)
	}
}

method waittilldone {
	wait($.constid)
}

method realano() {
	$.realtime(ano(),Now)
}

method start() { 

	for ( lp in $.ergox_klooper ) {
		t = $.ergox_klooper[lp]
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
			m2 = [0="/nth/clock",1=tm]
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
	kill($.jsontid)
	# print("Closing oscf=",$.oscf)
	if ( $.oscf >= 0 )
		close($.oscf)
	if ( $.jsonf >= 0 )
		close($.jsonf)
	for ( f in $.oscclients ) {
		close(f)
	}

	for ( lp in $.ergox_klooper ) {
		t = $.ergox_klooper[lp]
		t.stop()
	}

	Typos = -1
	if ( $.consf >= 0 ) {
		Consupdown = 0
		# print("Setting Consecho to 1")
		Root.releaseconsole()
	}
	Consecho = 1
	Merge = $.oldMerge
}

method cons_task() {
	$.consf = Root.grabconsole()
	global ergox_klooper4_resetconsole
	onexit(ergox_klooper4_resetconsole,$)
	while ( $.quit == 0 && (c=get($.consf)) != Eof ) {
		# print("GOT c=",c," from console")
		$.handle_console(c)
	}
}

method midi_task(f) {
	global ergox_klooper4_midi_restart
	onexit(ergox_klooper4_midi_restart,$)
	while ( (c=get(f)) != Eof ) {
		# print("Got midi c=",c)
		$.handle_midi_keyboard(c,$.currloop)
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

method json_restart() {
	if ( ! $.stopme ) {
		print("RESTARTING jsontask!!")
		$.jsontid = task $.jsontask()
	}
}

method gotgesturerc(t,d,f,r,c,prox,rawx,rawy) {
	# print("gotgesturerc rc=",r,c," prox=",prox)
	
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
				t = $.ergox_klooper[$.currloop]
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
	# print("Tempo is now ",tempo())
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
	msg = [0="/nth/erase"]
	$.to_osc_clients(msg)
}
method removeall() {
	msg = [0="/nth/removeall"]
	$.to_osc_clients(msg)
}

method handle_midi_keyboard(c,loopnum) {
	if ( DebugMidi )
		print("MIDI_KEYBOARD c=",c)

	t = $.ergox_klooper[loopnum]
	ch = t.get_currchan()

	# Indicate incoming MIDI notes with red
	if ( DoFlash && c.type == NOTEON ) {
		task $.launchpad_flash_input_chan(ch,2)
	}

	c.time = 0
	c.chan = ch
	isrecording = t.is_recording() && t.is_playloop()

	# print("handle_midi_keyboard isrecording=",isrecording)
	# print("   t.is_recording=",t.is_recording()," t.is_playloop=",t.is_playloop()," t.get_currchan=",t.get_currchan())

	# if ( ! isrecording && c.type == CONTROLLER ) {
	if ( c.type == CONTROLLER ) {
		c.port = 0
		c.time = 0
		# print("Sending controller=",c)
		$.realtime(c,Now)
		return()

		# b0 = integer(subbytes(c,1,1))
		# b1 = integer(subbytes(c,2,1))
		# val = integer(subbytes(c,3,1))
		# if ( b0 == 0xb0 && b1 == 0x07 ) {
		# 	# Volume control always works
		# 	c.port = 0
		# 	c.time = 0
		# 	$.realtime(c,Now)
		# 	return()
		# }
	}

	doscadjust = $.get_globalparam("scadjust") && ! t.get_chanparam("isdrum")
	if ( $.chordgathering ) {
		$.handle_midi_chord(c)
	} else if ( isrecording ) {
		# print("is_recording c=",c)
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
			t.realtime(c,0,0)
			return()
		} else {
			# print("Passing non-note/non-controller through c=",c)
			t.realtime(c,0,0)
			return()
		}
		q = t.get_chanparam("quantrec")
		# print("USING quantrec is_recording = ",q)
		t.looper_input_pq(keydown,c,1.5,900+c.pitch,1,q)
	} else {
		# print("is NOT recording c=",c)
		if ( doscadjust ) {
			# print("c B before scadjust = ",c)
			sc = $.get_scale()
			c = scadjust(c,sc)
			# print("c B after scadjust = ",c)
		}
		q = t.get_chanparam("quantreal")
		# print("USING quantreal NOT looping = ",q)
		if ( q > 0 ) {
			playat = nextquant(Now,q)
		} else {
			playat = Now
		}
		isstuttering = t.isstuttering()
		isprestuttering = t.isprestuttering()
		if ( isstuttering || isprestuttering) {
			c = t.do_stutter(c)
			t.realtime(c,playat,1)
			c.time += 1b/8
			c.type = NOTEOFF
			t.realtime(c,Now,1)
		} else {
			c.time = 0
			t.realtime(c,playat,1)
		}
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
		t = $.ergox_klooper[$.currloop]

		isrecording = t.is_recording() && t.is_playloop()

		if ( ft == "fingerdown" ) {
			p = $.fingernote(row,col,prox,rawx,rawy)
			tm = nextquant(Now,q)

			if ( isrecording ) {
				p.type = NOTEON
				p.time = 0
				q = t.get_chanparam("quantrec")
				# print("USING quantrec = ",q)
				t.looper_input_pq(1,p,prox,fid,0,q)
			} else {
				q = t.get_chanparam("quantreal")
				# print("USING quantreal = ",q)
				$.realtime(p,tm)
			}

			$.lastfingertm[fid] = tm
			$.lastfingerphr[fid] = p

		} else if ( ft == "fingerdrag" ) {
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
					if ( isrecording ) {
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
				if ( isrecording ) {
					p.type = NOTEON
					p.time = 0
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
				if ( isrecording ) {
					loopnt = lastp
					loopnt.type = NOTEOFF
					loopnt.time = 0
					# print("Fingerup = ",loopnt)
					q = $.val2quant($.repqnt)
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
			t = $.ergox_klooper[$.currloop]
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
			t = $.ergox_klooper[$.currloop]
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


class ergox_klooper4_onelooper {

method init(parent,loopnum,stepsize,ch,nphrases,vals,loopquant) {
	$.loopnum = loopnum
	$.parent = parent
	$.tid = -1
	$.stepsize = stepsize
	$.currchan = ch
	$.fadevol = 10
	$.cumulative_fade = 0
	$.last_fade = 0
	# print("ONELOOPER INIT loopnum = ",$.loopnum," currchan = ",$.currchan)
	$.nchannels = 8

	$.chanparamchangemethod = [
		"loopleng"="change_loopleng"
		]
	$.paramnotice = [
		# "recording"=0,
		# "loopnotes"=0
		# "loopleng"=0,
		"soundset"=0
		]

	$.tp_loopstart = 0
	$.typo_setup(nphrases)
	$.setloopphrase('')

	$.chanparam = []
	list = $.parent.get_perchanparamlist()
	for ( nm in list ) {
		type = list[nm]
		$.set_chanparam(nm,$.parent.null_value_of_type(type))
	}

	$.loopquant = loopquant
	$.loop_needs_scaling = 0
	$.vals = vals
	$.init_looptask()
	$.chordornament = ''
	# print("Setting chordornament to ''")
	$.vals["loopxpose"] = 0
	$.centerp = 'p64'
	$.oscplaytasks = []
	$.chan_color = []
	for ( ch=1; ch<=$.nchannels; ch++ ) {
		$.chan_color[ch] = 1
	}
	$.fademap = [
		"Default" = -1,
		"None"    = 0,
		"Slowest" = 1,
		"Slow"    = 2,
		"Medium"  = 3,
		"Fast"    = 4,
		"Fastest" = 5
		]

}

method set_volume() {
	v = $.get_chanparam("volume")
	p = controller($.currchan,0x07,v)
	# print("SET_VOLUME chan=",$.currchan," p=",p)
	$.realtime(p,Now,0)
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

method get_loopphrase() {
	return($.loopphrase)
}
method get_lastplayedphr() {
	return($.lastplayedphr)
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

method get_chanparam(nm) {
	if ( ! ( nm in $.chanparam ) ) {
		print("No value for nm=",nm," in $.chanparam!")
		return(0)
	}
	v = $.chanparam[nm]
	return(v)
}

method set_chanparam(nm,v) {
	# print("SET_LOOPPARAM nm=",nm," v=",v,"  type=",typeof(v))
	if ( ( nm in $.paramnotice) || DebugParam )
		print("SETTING LOOPPARAM nm=",nm," lp=",$.loopnum," ch=",$.currchan," v=",v)
	if ( nm in $.chanparamchangemethod ) {
		# print("Calling chanparamchangemethod on ",nm)
		m = $.chanparamchangemethod[nm]
		$.(m)(nm,v)
	} else {
		$.change_chanparam(nm,v)
	}
	# $.(nm) = v
}

method change_chanparam(nm,v) {
	$.chanparam[nm] = v
}

method change_loopleng(nm,newleng) {
	# print("CHANGING CHANNEL loopleng! loop=",$.loopnum," newleng=",newleng)
	oldleng = $.chanparam[nm]
	$.chanparam[nm] = newleng
	p = $.loopphrase
	# print("oldp = ",p)
	p.length = oldleng

	# Force the looped phrase to be that length, but
	# either repeating or truncating it
	if ( p != '' ) {
		p = repleng(p,newleng)
	}
	p.length = newleng
	$.setloopphrase(p)
	# print("newp = ",p)
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

		loopleng = $.get_chanparam("loopleng")

		# if ( $.currchan == 1 ) {
		# 	print("realtimetask ch=",$.currchan," loopleng=",loopleng," loopphrase=",$.loopphrase)
		# }

		# $.tp_length = loopleng

		if ( DebugReal && $.loopphrase != '')
			print("REALTIME TASK loopnum=",$.loopnum," loopleng = ",loopleng," loopphrase=",$.loopphrase)

		if ( loopleng < 0) {
			print("Negative loop leng? ",loopleng)
			return()
		}

		if ( loopleng == 0 ) {
			# print("loopleng is 0, skipping by loopquant=",$.loopquant)
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
		print("PLAY_LOOP tm=",tm," loopnum=",$.loopnum," loopleng=",loopleng," loopphrase=",$.loopphrase)
	}
	nnotes = sizeof($.loopphrase)
	# if ( nnotes > 75 ) {
	# 	print("HEY ************ loop is ",nnotes," notes long? ")
	# }

	thisloop = cut($.loopphrase,CUT_TIME,0,loopleng)
	doscadjust = $.get_globalparam("scadjust")
	sc = $.parent.get_scale()


	ch = $.currchan
	p = thisloop

	# playing_loop = $.get_chanparam("playloop")
	playing_loop = 1
	# print("CH = ",ch," playing_loop=",playing_loop)
	if ( sizeof(p) == 0 || ! playing_loop ) {
		# print("NOT Playing chan ",ch," in loop ",$.loopnum)
		$.looptask_phr[ch] = p
		$.looptask_vis[ch] = -1
		return()
	}

	fade = $.fademap[$.get_chanparam("fadeout")]
	if ( fade < 0 ) {
		fade = $.fademap[$.get_globalparam("fadeout")]
	}
	if ( fade > 0 ) {
		$.loopphrase -= p
		p.vol -= (3 * fade)
		p -= p{??.vol==0}
		$.loopphrase |= p
	}
	isdrum = $.get_chanparam("isdrum")
	if ( doscadjust && isdrum == 0 ) {
		p = scadjust(p,sc)
	}

	if ( DebugLoop ) {
		print("Playing chan ",ch," in loop ",$.loopnum," phrase=",$.loopphrase)
	}

	if ( Now > tm ) {
		print("Falling behind! dt=",Now-tm)
	}

	# print("LOOP ch=",ch," p=",p)
	# $.looptask_tid[ch] = $.realtime(p,tm,0)

	$.looptask_tid[ch] = task $.phrase_play(p,tm,$.loopnum)

	# if ( DoVisualize ) {
	# 	# print("Doing looptask_vis in loop, p=",p)
	# 	$.looptask_vis[ch] = task $.phrase_visualize(
	# 					p,tm,$.loopnum)
	# 	# print("LOOPTASK_VIS for ch=",ch," is ",$.looptask_vis[ch])
	# }

	$.looptask_phr[ch] = p
	$.looptask_tm[ch] = tm

	# if ( DoVisualize ) {
	# 	$.looptask_steps = task $.steps_visualize(tm,$.loopnum,loopleng)
	# }
}

method realtime(p,tm,dovis) {
	if ( nargs() < 3 ) {
		print("WARNING, third argument not present in realtime!")
		dovis = 0
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
		msg = [0="/nth/step",1=loopnum,2=n]
		# Don't spawn a new task - we want to be able to kill this task
		sleeptill(tm)
		$.parent.to_step_visualizers(msg)
		tm += $.stepsize
	}
}

method stutterit(nt,up) {
	# print("stutterit Start nt=",nt)
	v = nt.vol
	dt = $.get_chanparam("stuttertm")
	ntimes = $.get_chanparam("stuttern")
	# dt = 1b/6
	# ntimes = 4
	nt.length = dt
	nt.dur = 1b/16
	p = repeat(nt,ntimes)
	if ( up )
		p = crescendo(p,v/2,v+20)
	else
		p = crescendo(p,v+20,v/2)
	p.length = (ntimes-1)*dt
	# print("stutterit dt=",dt," ntimes=",ntimes," nt=",nt," p=",p)
	return(p)
}

method phrase_play(p,tm0,lp) {
	$.cumulative_fade = 0
	$.cumulative_quantnow = 0
	# print("==============phrase_play START")
	for ( nt in p ) {

		# print("phrase_play LOOP start nt=",nt)
		tm = tm0 + nt.time
		if ( $.cumulative_quantnow > 0 ) {
			tm = nextquant(tm,$.cumulative_quantnow)
			# print("phrase_play tm quantized = ",tm)
		} else {
			# print("phrase_play tm NOT quantized = ",tm)
		}

		playing_loop = $.get_chanparam("playloop")
		if ( ! playing_loop ) {
			sleeptill(tm)
			continue
		}

		trigable = $.get_chanparam("trigable")
		if ( trigable ) {
			trigger_global = $.get_globalparam("trigger%")
			trigger_chan = $.get_chanparam("trigger%")
			tp = integer(100.0 * (trigger_chan/100.0) * (trigger_global/100.0))

			if ( (tp < 100) && (rand(100) >= tp) ) {
				# print("Omitting nt=",nt," in chan ",$.currchan)
				sleeptill(tm)
				continue
			}
		}
		if ( $.cumulative_fade > 0 && $.should_fade() ) {
			nt = $.fade_phr(nt,$.cumulative_fade)
			if ( nt == '' ) {
				sleeptill(tm)
				continue
			}
		}
		volvary = $.get_chanparam("volvary%")
		if ( volvary > 0 ) {
			nt = noise(nt,0,volvary,VOLUME)
		}

		nt.time = 0
		dt = tm - Now
		if ( $.isprestuttering() ) {
			nt = $.stutterit(nt,1)
			if ( nt.length < dt ) {
				# print("PRESTUTTER nt=",nt)
				# print("PRESTUTTER origtm=",tm," dt=",dt," Now=",Now," newtm=",tm-nt.length," nt.length=",nt.length)
				tm -= nt.length
			} else {
				# print("Not enough time to prestutter")
			}
		}

		if ( DoVisualize ) {
			if ( nt.type == NOTEON ) {
				msg = [0="/nth/noteon",1=nt.chan,2=nt.pitch,3=nt.vol,4=lp]
				task $.sendvisat(tm,msg)
			} else if ( nt.type == NOTEOFF ) {
				msg = [0="/nth/noteoff",1=nt.chan,2=nt.pitch,3=nt.vol,4=lp]
				task $.sendvisat(tm,msg)
			} else if ( nt.type == NOTE ) {
				msg = [0="/nth/noteon",1=nt.chan,2=nt.pitch,3=nt.vol,4=lp]
				task $.sendvisat(tm,msg)
				msg = [0="/nth/noteoff",1=nt.chan,2=nt.pitch,3=nt.vol,4=lp]
				task $.sendvisat(tm+nt.dur,msg)
			}
		}

		sleeptill(tm)
		if ( $.isstuttering() ) {
			# print("stutter nt A = ",nt)
			nt = $.stutterit(nt,0)
			# print("    stutter nt B = ",nt)
		}
		# print("phrase_play LOOP end nt=",nt)
		$.realtime(nt,Now,0)
	}
	# print("==============phrase_play END")
}

method phrase_visualize(p,tm0,lp) {
	for ( nt in p ) {
		tm = tm0 + nt.time
		sleeptill(tm)
		if ( nt.type == NOTEON ) {
			msg = [0="/nth/noteon",1=nt.chan,2=nt.pitch,3=nt.vol,4=lp]
			task $.sendvisat(tm,msg)
		} else if ( nt.type == NOTEOFF ) {
			msg = [0="/nth/noteoff",1=nt.chan,2=nt.pitch,3=nt.vol,4=lp]
			task $.sendvisat(tm,msg)
		} else if ( nt.type == NOTE ) {
			msg = [0="/nth/noteon",1=nt.chan,2=nt.pitch,3=nt.vol,4=lp]
			task $.sendvisat(tm,msg)
			msg = [0="/nth/noteoff",1=nt.chan,2=nt.pitch,3=nt.vol,4=lp]
			task $.sendvisat(tm+nt.dur,msg)
		} else {
			# print("NOT SENDING VIS for nt=",nt)
		}
	}
}
method sendvisat(tm,msg) {
	sleeptill(tm)
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
	msg = [0="/nth/clearchan",1=($.loopnum+1)]
	$.parent.to_visualizers(msg)
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
	# $.tp_length = $.get_chanparam("loopleng")
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

method is_recording() {
	return($.get_chanparam("recording"))
}
method is_playloop() {
	return($.get_chanparam("playloop"))
}

method isstuttering() {
	return($.get_chanparam("stutter"))
}
method isprestuttering() {
	return($.get_chanparam("prestutter"))
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

	isrecording = $.is_recording() && $.is_playloop()

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
		p = $.do_stutter(p)
		$.lastplayedtid[uid] = $.realtime(p,nw,1)
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
			p = $.do_stutter(p)
			$.realtime(p,nw,1)
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
		# print("Adding loopleng to tmpdt !?")
		tmpdt += $.get_chanparam("loopleng")
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
	lim = $.get_chanparam("loopnotes")
	if ( sizeof($.loopphrase) > lim ) {
		# print("LIMITING due to loopnotes =",lim)
		for ( n = 0; n < sizep1; n++ ) {
			r = rand(1,sizeof($.loopphrase))
			pp = $.loopphrase
			pp % r = ''
			$.setloopphrase(pp)
		}
		# print("    size before=",sizeof($.loopphrase))
	}
	p2 = $.loopphrase | p1

	p2 = dedup(p2)
	$.setloopphrase(p2)

	# p.time = 0
	p.type = NOTEOFF
	if ( DebugReal )
		print("END OF INPUT_PQ, p=",p)
	
	$.realtime(p,nw,1)
	# print("playing C p=",p," Now=",Now," nw=",nw)
}

method do_stutter(p) {
	if ( $.isprestuttering() ) {
		p = $.stutterit(p,1)
	} else if ( $.isstuttering() ) {
		p = $.stutterit(p,0)
	}
	return(p)
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

method fade_phr(p,fv) {
	p.vol -= fv
	p -= p{??.vol==0}
	return(p)
}

method should_fade() {
	isdrum = $.get_chanparam("isdrum")
	drumfade = $.get_globalparam("drumfade")
	if ( !isdrum || drumfade )
		return(1)
	else
		return(0)
}

method do_fade(ischan) {
	if ( nargs() < 1 )
		ischan = 0

	if ( (Now - $.last_fade) < milliclicks(600) ) {
		print("MULTIPLE FADES IN < .6 secs, CLEARING!")
		$.oneloop_clear()
		return()
	}
		
	if ( $.loopphrase != '' ) {
		if ( ischan || $.should_fade() ) {
			$.cumulative_fade += $.fadevol
			$.setloopphrase($.fade_phr($.loopphrase,$.fadevol))
		}
	}
	$.last_fade = Now
}

method do_comb() {
	if ( $.loopphrase != '' ) {
		p = $.loopphrase
		onbeat = p{isnearbeat(??,1b/2,0)}
		poff = p - onbeat
		sz = sizeof(poff)
		# if no notes are off the beat, start removing those
		if ( sz == 0 ) {
			onbeat = onbeat{rand(2)==0}
			$.setloopphrase(onbeat)
			return()
		}
		# if only a new notes are left off the beat, remove them all
		if ( sz <= 3 ) {
			$.setloopphrase(onbeat)
			return()
		}
		# Filter the off-beat notes and add them back 
		poff = poff{rand(2)==0}
		onbeat |= poff
		$.setloopphrase(onbeat)
	}
}

method do_shuffle() {
	if ( $.loopphrase != '' ) {
		$.setloopphrase(shuffle($.loopphrase))
	}
}

method do_quantnow(ch) {
	if ( $.loopphrase != '' ) {
		p = $.loopphrase
		q = $.get_chanparam("quantnowv")
		$.cumulative_quantnow = q
		$.setloopphrase(quantize($.loopphrase,q))
	}
}

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

function ergox_klooper4_resetconsole(o) {
	o.stop()
}

function ergox_klooper4_midi_restart(o) {
	o.midi_restart()
}
function ergox_klooper4_osc_restart(o) {
	o.osc_restart()
}
function ergox_klooper4_json_restart(o) {
	o.json_restart()
}
