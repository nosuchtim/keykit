#
# klooper_techshop
#
# For the Kinect SpacePalette instrument, this is the first version
# that uses the techshop layout.

LOOPHACK = 1
LastTime = 0

INCDEC_MID = 0
INCDEC_MIN = -2
INCDEC_MAX = 2
INCDEC_INC = 1
INCDEC_DEC = -1
TypoDebug = 0

Zexpand = 3

NoZcontrol = 1

Wusik = 0
Chording = 0
ChordType = 0
ChordList = [ 0='p12,p7,p5',  1='p12,p15,p19', 2='p12,p19', 3='p12,p18,p23', 4='p12,p3,p19,p22' ]
ChordList = [ 0='p12,p7,p5',  1='p12,p5', 2='p12,p15,p19,p22' ]
LoopingOnWhileDown = 0
LoopingOffWhileDown = 0
LoopingFadeWhileDown = 0
LastLoopingFade = 0
AnoWhileDown = 0
DebugDebug = 0
DebugOsc = 0
DebugJson = 1
DebugButton = 1
DebugReal = 1
DebugEdge = 0
DebugReal2 = 1
DebugSID = 0
DebugZ = 0
DebugMidi = 0
DebugParam = 0
DebugLoop = 0
DebugNotes = 1

DebugNew = 0
PushOut = 0

DoFlash = 0
DoFade = 1
DoActive = 0
DoVisualize = 0
FlashFreq = 1b
DoBidule = 1
DoSlow = 0
OscSleep = 0
Tuio_sid_task = []
Tuio_sid_note = []
Tuio_sid_lasttm = []
Chan_activity = []
TransReallyRand = 0
Midiloopnum = 7
Midisid = 8000

Edgehack_y_low = 0.1
Edgehack_x_low = 0.1
Edgehack_y_high = 0.9
Edgehack_x_high = 0.9

CornerCheck = 0
NextNoteChangePatch = 0
NextNoteChangeLooping = 0
StopContinuous = 0

# Things that are often changed
VerticalMin = 0.1
VerticalMax = 0.85
VerticalBands = 3
ProgramChangeImmediate = 0
LoopingChangeImmediate = 0
DoLooping = 1

ForceRestartMinutes = 120   # if < 0, no forced restart
KlooperNoteAreas = 4
KlooperButtonAreas = 8
MusicLowerButtons = 0

Button_chordtype = -1
Button_looping_fade_whiledown = -1
Button_ano = -1
Button_reset_chord = -1
Button_chordtype = -1
Button_looping_on = -1
Button_looping_off = -1
Button_patch_all = -1

if ( KlooperButtonAreas == 8 ) {
	Button_ano_whiledown = -1

	# lower-left buttons
	Button_ano2 = 0
	Button_chording_whiledown = 1

	# lower-right buttons
	Button_looping_off_whiledown = 2
	Button_looping_on_whiledown = 3

	# upper-left buttons
	Button_scale = 5
	Button_key = 4

	# upper-right buttons
	Button_patch_1 = 6
	Button_reset_patch = 7
} else if ( KlooperButtonAreas == 12 ) {
	print("12-button NEEDS WORK!!")
} else {
	print("Unexpected value of KlooperButtonAreas!")
}

true = 1
false = 0

KlooperHtmlDir = "c:/local/dojopanel/"

#define xxx rereadlib();klooper_techshop_continuous()

function klooper_techshop_continuous() {
	print("klooper_techshop_continuous start!")
	while (1) {
		rereadlib()
		global StopContinuous
		StopContinuous = 0
		klooper_techshop()
		if ( ForceRestartMinutes < 0 ) {
			break
		}
		global StopContinuous
		print("StopContinuous=",StopContinuous)
		if ( StopContinuous > 0 ) {
			break
		}
		print("ForceRestartMinutes is restarting klooper_techshop()");
	}
	print("klooper_techshop_continuous end!")
}

function klooper_techshop() {

	if ( nargs() > 0 ) {
		print("HEY!  arguments to klooper_techshop are ignored!")
	}

	print("KLOOPER techshop!  NoteAreas = ",KlooperNoteAreas)

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

	t = new ergox_klooper_techshop_mastertypo(patchprefix)
	t.start()
	t.waittilldone()
	t.stop()
}

class ergox_klooper_techshop_mastertypo {

method init(patchprefix) {

	# print("ergox_klooper init started...") 

	$.note_area_limit = 0.006
	$.slider_area_limit = 0.13
	$.button_area_limit = 0.1
	$.numprograms = 6
	# $.slider1 = "pitchbend"
	$.slider1 = "quant"
	$.last_note_channel = 1
	$.first_preset_fnum = 0
	$.debugcopy = 0
	$.midi_keyboard_count = 0
	$.tuio_sid_active = []
	$.tuio_sid_pitchbend = []
	$.tuio_sid_x = []
	$.tuio_sid_y = []
	$.tuio_sid_z = []
	$.disabled_till_clear = []
	$.transpose_pos = 0

	$.button_down = []

	Tuio_sid_task = []
	Tuio_sid_note = []
	Tuio_sid_lasttm = []

	$.oldMerge = Merge
	Merge = 0

	# Drums are going to be on channels 6 and 7,
	# so we don't want those to be affected by Offsetpitch
	$.oldOffsetfilter = Offsetfilter
	Offsetfilter = (1<<5 | 1<<6 )

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
		"pitchmin" = "int",
		"pitchmax" = "int",
		"velocitymin" = "int",
		"velocitymax" = "int",
		"velocitydflt" = "int",
		"quantreal" = "int",
		"trigger%" = "int",
		"trigable" = "toggle",
		"volvary%" = "int",
		"isdrum" = "toggle",
		"loopleng" = "int",
		"fadeout" = "string",
		"loopnotes" = "int",
		"program" = "int",
		"xyctl" = "toggle",
		"depth" = "string"
		]

	$.chanparamset = [
		"volume" = "set_volume"
		]

	$.depthctlmap = [
		"None" = -1,
		"Aftertouch"    = 0,
		"Modulation" = 1
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

	# $.scale_sequence = [0="Chinese",2="Arabian",3="African",4="Fifths",5="Chromatic"]
	$.scale_sequence = [
		0="African",
		1="Arabian"]


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
		$.ergox_klooper[lp] = new ergox_klooper_techshop_onelooper($,lp,$.stepsize,lp+1,$.nphrases,vals,$.loopquant)
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

	$.jsonf1 = open(string(Jsonlisten)+"@127.0.0.1","rf","tcpip_listen")
	print("Listening for JSON on ",Jsonlisten)
	if ( $.jsonf1 == "" ) {
		print("Unable to listen on ",Jsonlisten," !?")
		$.jsontid1 = -1
	} else {
		$.jsontid1 = task $.jsontask($.jsonf1)
	}

	# $.jsonf2 = open(string(Jsonlisten)+"@happy","rf","tcpip_listen")
	# print("Listening for JSON on ",Jsonlisten)
	# if ( $.jsonf2 == "" ) {
	# 	print("Unable to listen on ",Jsonlisten," !?")
	# 	$.jsontid2 = -1
	# } else {
	# 	$.jsontid2 = task $.jsontask($.jsonf2)
	# }


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

	$.set_globalparam("scale",$.scale_sequence[0])
	$.set_scale()

	print("SETTING INITIAL PATCHES!")
	for ( ch=1; ch<=$.nchannels; ch++ ) {
		t = $.get_looper(ch-1)
		$.set_patch(t,ch,0)
	}

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

	$.loadjsonfile("default_techshop.klp")

	print("NOW ACTIVE!")
}

method loadjsonfile(fname) {
	print("READING JSON file: "+fname)
	s = $.myreadfile(fname)
	j = $.string2json(s)
	if ( DebugJson > 1 ) print("j =",j)
	params = j["params"]
	global true
	global false
	true = 1
	false = 0
	for ( pname in params ) {
		if ( pname == "__" ) {
			continue
		}
		arr = params[pname]
		if ( typeof(arr) != "array" ) {
			print("Hey, pname=",pname," isn't an array!?")
			continue
		}
		if ( "global" in arr ) {
			gval = arr["global"]
			$.global_set(pname,gval)
		}
		if ( "perchan" in arr ) {
			chanarr = arr["perchan"]
			for ( i in chanarr ) {
				$.perchan_set(pname,chanarr[i],i)
			}
		}
			
	}
}

method myreadfile(fname) {
	f = open(fname)
	if ( f < 0 ) {
		return("")
	}
	r = ""
	while ( (s=get(f)) != Eof ) {
		r += (s+"\n");
	}
	close(f)
	return(r)
}

method get_looper(loopnum) {
	if ( sizeof($.ergox_klooper) != $.nloops ) {
		print("HEY!! ergox_klooper has changed!  =",$.ergox_klooper," nloops=",$.nloops)
		# For some reason, an entry for $.nloops gets in there
		for ( lp in $.ergox_klooper ) {
			if ( lp >= $.nloops ) {
				print("Deleting ergox_klooper lp=",lp)
				delete $.ergox_klooper[lp]
			}
		}
	}
	return($.ergox_klooper[loopnum])
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

	t = $.get_looper($.currloop)
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
	print("OSCTASK start!!!")
	global ergox_klooper_techshop_osc_restart
	onexit(ergox_klooper_techshop_osc_restart,$)
	while ( (d=get($.oscf)) != Eof ) {
		# print("osctask d=",d)
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
	nd = sizeof(d)
	tmparr = arraycopy($.tuio_sid_active)
	chans_active = []
	for ( n=2; n<nd; n++ ) {
		sid = d[n]
		if ( ! sid in $.tuio_sid_active ) {
			if ( DebugSID )
				print("Now=",Now," sid=",sid," ADDING to tuio_sid_active, x/y=-1")
			$.tuio_sid_active[sid] = 1
			$.tuio_sid_x[sid] = -1
			$.tuio_sid_y[sid] = -1
		}
		delete tmparr[sid]
		if ( sid in Tuio_sid_note ) {
			nt = Tuio_sid_note[sid]
			chans_active[nt.chan] = 1
		}
	}

	# If any of the disabled_till_clear channels are clear
	# (i.e. no active notes), then re-enable them
	for ( ch in $.disabled_till_clear ) {
		if ( ! (ch in chans_active) ) {
			delete $.disabled_till_clear[ch]
			print("CLEARING disabled_till_clear of ch=",ch)
		}
	}

	# In order to catch stuck notes, put out an ANO on channels
	# that have had activity, whenever they don't have any active sessions
	for ( ch in Chan_activity ) {
		if ( ! (ch in chans_active) ) {
			if ( DebugReal )
				print("Now=",Now," NO ACTIVE SESSIONS on ch=",ch,"  SENDING OUT ANO!!")
			$.realtime(ano(ch),Now)
			delete Chan_activity[ch]
		}
	}

	# What's left in tmparr are the sid's of no-longer-active sids
	# print("handle_tuio_alive, B d=",d," tmparr = ",tmparr)
	for ( sid in tmparr ) {
		t = $.sid_to_type(sid)
		if ( t == "note" ) {
			$.cleanup_note_on_sid(sid)
		} else if ( t == "slider" ) {
			slider = $.sid_to_slider(sid)
			# print("SLIDER ",slider," WENT AWAY!!")
			$.handle_tuio_slider(sid,slider,0,0,0)
		} else if ( t == "button" ) {
			button = $.sid_to_button(sid)
			# print("BUTTON ",button," WENT AWAY!!")
			$.handle_tuio_button_up(sid,button)
		} else {
			print("Unknown sid type? sid=",sid," t=",t)
		}
		# if ( DebugSID ) print("DELETING SID=",sid," active/z/x/y")
		delete $.tuio_sid_active[sid]
		delete $.tuio_sid_z[sid]

		for ( b in $.button_down ) {
			buttonsid = $.button_down[b]
			if ( buttonsid == sid ) {
				# if ( DebugButton ) print("DELETING button_down for b=",b," sid=",sid)
				delete $.button_down[b]
			}
		}

		delete $.tuio_sid_x[sid]
		delete $.tuio_sid_y[sid]
	}
	# if ( sizeof($.tuio_sid_active) != 0 ) {
	# 	print("Now=",Now," got alive msg, active=",$.tuio_sid_active)
	# }
	# print("handle_tuio_alive B tuio_sid_active=",$.tuio_sid_active)
}

method cleanup_note_on_sid(sid) {
	if ( sid in Tuio_sid_note ) {
		nt = Tuio_sid_note[sid]
		if ( nt.type == NOTEON ) {
			loopnum = nt.chan - 1
			nt.type = NOTEOFF
			if ( DebugNotes )
				print("Now=",Now," sid=",sid," no longer alive, generating noteoff nt=",nt)
			if ( DebugLoop ) {
				print("Cleanup_note_on_sid loopnum=",loopnum," calling handle_midi_keyboard nt=",nt)
			}
			$.handle_midi_keyboard(nt,loopnum,sid)
		}
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
		} else {   # quant
			if ( x < 0.25 )
				q = 1b/2
			else if ( x < 0.65 )
				q = 1b/4
			else if ( x < 0.85 )
				q = 1b/8
			else
				q = 1b/8  # was 0
			# print("X = ",x,"  Q = ",q," f=",f)
			t = $.get_looper(ch-1)
			$.change_quant(t,q)
		}
	} else {
		print("Unknown slider value in controller_for_slider: ",slider)
	}
	return(nt)
}

method change_quant(t,q) {
	oldq = t.get_chanparam("quantreal")
	if ( q != oldq ) {
		# print("CHANGED QUANTREAL SLIDER ch=",t.get_currchan()," Q=",q)
		t.set_chanparam("quantreal",q)
	}
	oldq = t.get_chanparam("quantrec")
	if ( q != oldq ) {
		# print("CHANGED QUANTREC SLIDER ch=",t.get_currchan()," Q=",q)
		t.set_chanparam("quantrec",q)
	}
}

method handle_tuio_slider(sid,slider,x,y,f) {
	if ( $.last_note_channel <= 0 ) {
		print("No $.last_note_channel, ignoring slider")
		return()
	}
	# print("SLIDER!  sid=",sid)
	ch = $.last_note_channel
	nt = $.controller_for_slider(sid,slider,ch,x,y,f)
	if ( nt != '' ) {
		# print("PLAYING slider nt=",nt)
		$.realtime(nt,Now)
		# if ( ! sid in $.tuio_sid_active ) {
		# 	print("SLIDER!  ch=",ch," xyf = ",x,y,f)
		# }
		if ( DebugSID ) {
			print("Setting sid=",sid," to active, xy=",x,y)
		}
		$.tuio_sid_active[sid] = 1
		$.tuio_sid_x[sid] = x
		$.tuio_sid_y[sid] = y
	}
}

method change_patch(t,ch,prog) {
	if ( nargs() < 3 ) {
		prog = (t.get_chanparam("program")+1)%($.numprograms)
	} else {
		prog = 0
	}
	$.set_patch(t,ch,prog)
}

method set_patch(t,ch,prog) {
	t.set_chanparam("program",prog)
	print("SENDING CHANGE OF PATCH!! ch=",ch," prog=",prog)
	$.realtime(ano(ch),Now)

	# +1 here because first arg to progchange is 1-based
	if ( Wusik ) {
		$.realtime(progchange(prog+2,ch),Now)
	} else {
		$.realtime(progchange(prog+1,ch),Now)
	}

	$.realtime(ano(ch),Now)

	zz = $.z_message(t,0)
	if ( DebugZ )
		print("SENDING on ch=",ch," z_message for 0 value")
	$.realtime(zz,Now)
}

method handle_tuio_button_up(sid,button) {
	# print("handle_tuio_button_up!  button=",button)
	# if ( button == Button_looping_whiledown ) {
	# 	print("Looping whiledown is let up!")
	# 	LoopingWhileDown = 0
	# }
	if ( button == Button_looping_on_whiledown ) {
		print("Looping_on_whiledown is let up!")
		LoopingOnWhileDown = 0
	}
	if ( button == Button_looping_off_whiledown ) {
		print("Looping_off is let up!")
		LoopingOffWhileDown = 0
	}
	if ( button == Button_looping_fade_whiledown ) {
		print("Looping_fade is let up!")
		LoopingFadeWhileDown = 0
	}
	if ( button == Button_ano_whiledown ) {
		print("AnoWhileDown is let up!")
		AnoWhileDown = 0
	}
	if ( button == Button_chording_whiledown ) {
		print("Chording is let up!")
		Chording = 0
	}
}

method fade_looping() {
	print("FADE LOOPING calling do_fade")
	$.all_loops("do_fade")
}

method reset_looping() {
	print("CLEARING ALL LOOPS and turning off LOOPING")
	$.all_loops("oneloop_clear")
	$.all_loops("oneloop_noloop")
	for ( ch=1; ch<=$.nchannels; ch++ ) {
		$.change_looping(ch,0)
	}
	NextNoteChangeLooping = 0
}

method handle_tuio_button_down(sid,button,x,y,f) {
	if ( (sid in $.tuio_sid_active) && (button in $.button_down) ) {
		if ( DebugButton > 1 )
			print("BUTTON ",button," is already down")
		# Already down
	} else {
		if ( DebugButton )
			print("BUTTON ",button," went down!  sid=",sid," f = ",f," xy=",x,y)
		$.button_down[button] = sid
		$.tuio_sid_active[sid] = 1
		$.tuio_sid_x[sid] = x
		$.tuio_sid_y[sid] = y
		if ( button == Button_key ) {
			if ( DebugButton )
				print("BUTTON: TRANSPOSE!!")
			$.do_transrand()
			$.ano()
		} else if ( button == Button_looping_on_whiledown ) {
			LoopingOnWhileDown = 1
			print("Enabling LoopingOnWhileDown!!")
		} else if ( button == Button_looping_off_whiledown ) {
			LoopingOffWhileDown = 1
			print("Enabling LoopingOffWhileDown!!")
		} else if ( button == Button_looping_fade_whiledown ) {
			LoopingFadeWhileDown = 1
			print("Enabling LoopingFadeWhileDown!!")
			if ( (Now-LastLoopingFade) < milliclicks(1200) ) {
				print("multiple quick clear - CLEARING ALL LOOPS!")
				$.reset_looping()
			}
			LastLoopingFade = Now

		# } else if ( button == Button_looping_on ) {
		# 	for ( ch=1; ch<=$.nchannels; ch++ ) {
		# 		$.change_looping(ch,1)
		# 	}
		# } else if ( button == Button_looping_off ) {
		# 	for ( ch=1; ch<=$.nchannels; ch++ ) {
		# 		$.change_recording(ch,0)
		# 	}

		} else if ( button == Button_ano_whiledown ) {
			AnoWhileDown = 1
			print("AnoWhileDown is set!!")
		} else if ( button == Button_chording_whiledown ) {
			Chording = 1
			print("Chording is set!!")
		} else if ( button == Button_ano2 ) {
			print("ANO!")
			ChordType = 0
			$.ano()
		} else if ( button == Button_chordtype ) {
			ChordType = (ChordType+1) % sizeof(ChordList)
			print("ChordType = ",ChordList[ChordType])
		} else if ( button == Button_ano ) {
			print("ANO!")
			$.ano()
# 		} else if ( button == Button_looping ) {
# 
# 			if ( DoLooping ) {
# 				if ( LoopingChangeImmediate ) {
# 					print("BUTTON looping: changing ALL looping")
# 					for ( ch=1; ch<=$.nchannels; ch++ ) {
# 						$.change_looping(ch)
# 					}
# 				} else {
# 					print("BUTTON looping: next frame set looping")
# 					NextNoteChangeLooping = 1
# 				}
# 			} else {
# 				print("BUTTON looping: LOOPING IS DISABLED!!")
# 			}
		} else if ( button == Button_scale ) {
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
			# if ( DebugButton )
				print("BUTTON: NEW SCALE n=",n," scale=",sc)
			$.set_globalparam("scale",sc)
			$.set_scale()
			$.ano()
				
		} else if ( button == Button_reset_patch ) {
			$.reset_patches()
		} else if ( button == Button_patch_all ) {
			$.change_all_patches()
		} else if ( button == Button_patch_1 ) {
			if ( DebugButton )
				print("BUTTON patch: Next Note changes patch!!")
			NextNoteChangePatch = 1
			print("SETTING NextNoteChangePatch!")
		} else {
			print("BUTTON ",button,": has no function");
		}
		if ( DebugButton )
			print("END OF BUTTON ",button," went down!  sid=",sid," f = ",f," xy=",x,y)
	}
}

method sid_to_type(sid) {
	ch = sid/1000
	if ( ch <= KlooperNoteAreas ) {
		return("note")
	} else if ( ch <= (KlooperNoteAreas+KlooperButtonAreas) ) {
		return("button")
	} else {
		return("slider")
	}
}

method sid_to_slider(sid) {
	ch = sid/1000
	first_slider = KlooperNoteAreas + KlooperButtonAreas + 1
	if ( ch == first_slider || ch == (first_slider+1) )
		return(ch-first_slider)
	else
		return(-1)
}

method sid_to_button(sid) {
	ch = sid/1000
	if ( ch > KlooperNoteAreas )
		return(ch-(KlooperNoteAreas+1))
	else
		return(-1)
}

method z_message(t,v) {
	if ( NoZcontrol ) {
		return('')
	}
	ch = t.get_currchan()
	dc = t.get_chanparam("depth")
	depthctl = $.depthctlmap[dc]
	# print("z v=",v," dc=",dc," depthctl=",depthctl)
	if ( depthctl < 0 ) {
		p = ''
	} else if ( depthctl == 0 ) {
		# channel pressure
		p = midibytes((ch-1) + 0xd0, v)
	} else {
		# modulation controller
		p = controller(ch, 0x01,v*Zexpand)
	}
	# print("z_message returns ",p)
	return(p)
}

method xy_to_ctl(t,x) {
	print("NEEDS IMPLEMENTATION!  xy_to_ctl ")
	return('')
}

method x_to_pitch(t,x) {
	pitchmin = t.get_chanparam("pitchmin")
	if ( pitchmin < 1 )
		pitchmin = 30   # default
	pitchmax = t.get_chanparam("pitchmax")
	if ( pitchmax < 1 )
		pitchmax = 100   # default
	if ( pitchmin > pitchmax ) {
		tmp = pitchmin
		pitchmin = pitchmax
		pitchmax = tmp
	}
	pitch = pitchmin + (pitchmax-pitchmin) * x
	return(pitch)
}

method y_to_quant(t,y) {
	y = y - VerticalMin
	if ( y < 0 )
		y = 0.0
	y = y * 1.0 / (VerticalMax-VerticalMin)
		
	if ( VerticalBands == 4 ) {
		if ( y < 0.2 )
			q = 1b
		else if ( y < 0.5 )
			q = 1b/2
		else if ( y < 0.90 )
			q = 1b/4
		else
			q = 1b/8
	} else if ( VerticalBands == 3 ) {
		if ( y < 0.15 )
			q = 1b
		else if ( y < 0.60 )
			q = 1b/2
		else
			q = 1b/4
	} else {
		if ( y < 0.4 )
			q = 1b/2
		else
			q = 1b/4
	}
	return(q)
}

method y_to_velocity(t,y) {
	velocitymin = t.get_chanparam("velocitymin")
	if ( velocitymin < 1 )
		velocitymin = 20   # default
	velocitymax = t.get_chanparam("velocitymax")
	if ( velocitymax < 1 )
		velocitymax = 127   # default
	if ( velocitymin > velocitymax ) {
		tmp = velocitymin
		velocitymin = velocitymax
		velocitymax = tmp
	}
	velocity = velocitymin + (velocitymax-velocitymin) * y
	return(velocity)
}

method change_all_patches() {
	for ( ch=1; ch<=$.nchannels; ch++ ) {
		t = $.get_looper(ch-1)
		$.change_patch(t,ch)
	}
}

method reset_patches() {
	print("RESET PATCHES!")
	for ( ch=1; ch<=$.nchannels; ch++ ) {
		t = $.get_looper(ch-1)
		$.change_patch(t,ch,0)
	}
}

method check_change(ch) {
	if ( NextNoteChangePatch ) {
		if ( DebugButton )
			print("CHANGING PATCH due to NextNoteChangePatch!!!")
		t = $.get_looper(ch-1)
		# isdrum = t.get_chanparam("isdrum")
		# if ( ! isdrum ) {
			print("NEW CHANGE PATCH code")
			$.change_patch(t,ch)
			NextNoteChangePatch = 0
			return()
		# } else {
		# 	print("Ignoring drum channel for patch change")
		# }
	}
	if ( NextNoteChangeLooping ) {
		$.change_looping(ch)

	}
	return(0)
}

method change_looping(ch,newval) {
	t = $.get_looper(ch-1)
	if ( nargs() < 2 ) {
		v = t.get_chanparam("recording",0)
		if ( v ) {
			newval = 0
		} else {
			newval = 1
		}
	}
	if ( DebugButton )
		print("CHANGING LOOPING ch=",ch," newval=",newval)
	t.set_chanparam("recording",newval)
	t.set_chanparam("playloop",newval)
	if ( newval == 0 ) {
		$.realtime(ano(),Now)  # all channels
	}
	NextNoteChangeLooping = 0
}

method change_recording(ch,newval) {
	t = $.get_looper(ch-1)
	if ( nargs() < 2 ) {
		v = t.get_chanparam("recording",0)
		if ( v ) {
			newval = 0
		} else {
			newval = 1
		}
	}
	if ( DebugButton )
		print("CHANGING LOOPING ch=",ch," newval=",newval)
	t.set_chanparam("recording",newval)
	if ( newval == 0 ) {
		$.realtime(ano(),Now)  # all channels
	}
	NextNoteChangeLooping = 0
}

method change_playloop(ch,newval) {
	t = $.get_looper(ch-1)
	if ( DebugButton )
		print("CHANGING PLAYLOOP ch=",ch," newval=",newval)
	t.set_chanparam("playloop",newval)
}

method force_looping(t,v) {
	t1 = t.get_chanparam("playloop")
	t2 = t.get_chanparam("recording")
	if ( t1 != v || t2 != v ) {
		print("FORCE_LOOPING v=",v)
		t.set_chanparam("recording",v)
		t.set_chanparam("playloop",v)
	}
	if ( v == 0 ) {
		print("Sending ANO on channel ",t.get_currchan())
		$.realtime(ano(t.get_currchan()),Now)
	}
}

method handle_tuio_25D_set(sid,x,y,z,w,h,f) {
	ch = sid/1000

	# print("handle_tuio_25D_set! sid=",sid," xyz=",x,y,z)

	if ( ch in $.disabled_till_clear ) {
		print("handle_tuio_25D, ch=",ch," is disabled_till_clear")
		return()
	}

	# The first KlooperNoteAreas areas are channels 1-N,
	# the rest are sliders and buttons
	if ( ch > KlooperNoteAreas ) {
		slider = $.sid_to_slider(sid)
		if ( slider >= 0 ) {
			if ( f >= $.slider_area_limit ) {
				$.handle_tuio_slider(sid,slider,x,y,f)
			} else {
				# print("IGNORING slider, f=",f)
			}
			return()
		}
		button = $.sid_to_button(sid)
		if ( DebugButton > 1 )
			print("BUTTON sid=",sid," button=",button," xy=",x,y," wh=",w,h," f=",f)
		if ( button >= 0 ) {
			if ( f >= $.button_area_limit ) {
				$.handle_tuio_button_down(sid,button,x,y,f)
			} else {
				if ( DebugButton > 1 )
					print("IGNORING button ",button," f=",f)
			}
			return()
		}
		print("HMMM sid=",sid," is neither button nor slider!?")
		return()
	}

	if ( f < $.note_area_limit ) {
		# print("Ignoring note, f=",f)
		return()
	}
	if ( DebugLoop ) {
		print("SET last_note_channel =",ch," xyz=",x,y,z," whf=",w,h,f)
	}
	if ( DebugEdge ) {
		print("EDGE DEBUG ch=",ch," xyf=",x,y,f)
	}
	if ( y < Edgehack_y_low || y > Edgehack_y_high) {
		if ( DebugEdge ) {
			print("IGNORING EDGE! y=",y)
		}
		return()
	}
	if ( x < Edgehack_x_low || x > Edgehack_x_high) {
		if ( DebugEdge ) {
			print("IGNORING EDGE! x=",x)
		}
		return()
	}

	loopnum = ch - 1
	t = $.get_looper(loopnum)

	if ( AnoWhileDown ) {
		print("AnoWhileDown in tuio_set, sending ano on ch=",ch)
		$.realtime(ano(ch),Now)
		$.force_looping(t,0)
		return()
	}
	if ( LoopingOnWhileDown ) {
		# print("LoopingOnWhileDown Now=",Now," ch=")
		$.force_looping(t,1)
	}
	if ( LoopingOffWhileDown ) {
		# print("LoopingOffWhileDown Now=",Now)
		$.force_looping(t,0)
		return()
	}
	if ( LoopingFadeWhileDown ) {
		# print("LoopingClearWhileDown Now=",Now)
		if ( t.get_loopphrase() != '' ) {
			print("FADING LOOP FOR ch=",ch)
			t.do_fade()
			# t.oneloop_clear()
		}
		return()
	}

	$.last_note_channel = ch

	# change_patch used to be here

	xyctl = t.get_chanparam("xyctl")
	# print("xyctl=",xyctl)
	if ( xyctl ) {
		nt = $.xy_to_ctl(t,x,y)
		if ( nt != '' ) {
			$.realtime(nt,Now)
		}
		return()
	} else {
		pitch = $.x_to_pitch(t,x)
		# vol = $.y_to_velocity(t,y)
		vol = t.get_chanparam("velocitydflt")
		if ( vol == 0 )
			vol = 80
		q = $.y_to_quant(t,y)
		# print("Y=",y," Q=",q," Vel=",vol)
		$.change_quant(t,q)
	}

	if ( vol > 127 )
		vol = 127
	if ( sid in Tuio_sid_note ) {
		if ( DebugLoop ) {
			print("sid=",sid," in Tuio_sid_note = ",Tuio_sid_note[sid])
		}
		dx = x - $.tuio_sid_x[sid]
		dy = y - $.tuio_sid_y[sid]
		dist = sqrt(dx*dx + dy*dy)
		# print("sid=",sid," dist=",dist)

		if ( DebugSID )
			print("SID=",sid,"  Z = ",z)
		# Range of z we're interested in
		minz = 0.05
		maxz = 0.30
		# print("AAA z=",z," minz=",minz)
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
			if ( DebugZ )
				print("SENDING aftertouch on ch=",ch," z=",z," v=",v)
			nt = $.z_message(t,v)
			if ( nt != '' ) {
				print("CALLING REALTIME AA")
				$.realtime(nt,Now)
			}
		} else {
			# Shouldn't really send it ALL the time, but...
			v = 0
			if ( DebugZ )
				print("SENDING aftertouch on ch=",ch," 0!")
			nt = $.z_message(t,0)
			if ( nt != '' ) {
				print("CALLING REALTIME BB")
				$.realtime(nt,Now)
			}
		}

		if ( ! ( sid in $.tuio_sid_active ) ) {
			print("Hey, sid=",sid," is in Tuio_sid_note=",Tuio_sid_note,", but not tuio_sid_active=",$.tuio_sid_active)
			print("   in 25Dset, xyz=",x,y,z," wh=",w,h," f=",f)
			print("   Tuio_sid_note=",Tuio_sid_note[sid]," lasttm=",Tuio_sid_lasttm[sid])
			return()
		}

		# print("sid already down, dist=",dist," xy=",x,y," oldxy=",
		# 	$.tuio_sid_x[sid],$.tuio_sid_y[sid])

		kinedist = $.get_globalparam("kinedist") / 1000.0
		if ( dist > kinedist ) {

			# print("Check change patch 1")
			if ( $.check_change(ch) ) {
				print("Early return due to check_change")
				return()
			}

			# # let go of the old pitch, and play the new one

			### NEW STUFF!!
			if ( DebugNew ) {
				nt = Tuio_sid_note[sid]
				nt.type = NOTEOFF
				if ( DebugLoop ) {
					print("Now=",Now," sid=",sid," MOVE NOTE OFF nt=",nt)
				}
				$.handle_midi_keyboard(nt,loopnum,sid)
			}
			### END OF NEW STUFF!!

			nt = makenote(pitch,1b/8,vol,ch)
			if ( DebugEdge ) {
				print("EDGE DEBUG continuing note nt=",nt)
			}
			nt.type = NOTEON
			if ( DebugReal ) {
				print("Now=",Now," sid=",sid," Kinedist=",dist," new nt=",nt)
			}
			if ( DebugLoop ) {
				print("BB! loopnum=",loopnum," calling handle_midi_keyboard nt=",nt)
			}
			$.handle_midi_keyboard(nt,loopnum,sid)

			$.tuio_sid_x[sid] = x
			$.tuio_sid_y[sid] = y
		} else {
			# print("   dist<=kinedist? dist=",dist," kinedist=",kinedist)
		}
	} else {

		# print("Check change patch 2")
		if ( $.check_change(ch) ) {
			print("Early return due to check_change")
			return()
		}

		nt = makenote(pitch)
		if ( DebugEdge ) {
			print("EDGE DEBUG making note nt=",nt)
		}
		nt.dur = 1b/16
		nt.chan = ch
		nt.vol = vol
		nt.type = NOTEON
		if ( DebugNotes )
			print("Now=",Now," sid=",sid," handling NEW nt=",nt)
		if ( DebugLoop ) {
			print("CC! loopnum=",loopnum," calling handle_midi_keyboard nt=",nt)
		}
		$.handle_midi_keyboard(nt,loopnum,sid)
		if ( DebugSID ) {
			print("Setting SID=",sid," to active, xy=",x,y)
		}
		$.tuio_sid_active[sid] = 1
		$.tuio_sid_x[sid] = x
		$.tuio_sid_y[sid] = y
		# $.tuio_sid_z[sid] = z
	}

	# Now check for the magic gestures (hands in the corners)
	corners = []
	# print("CHECKING FOR MAGIC CORNERS!  tuio_sid_active=",$.tuio_sid_active)

	if ( CornerCheck ) {
	for ( sid in $.tuio_sid_active ) {

		ty = $.sid_to_type(sid)
		if ( ty != "note" ) {
			# print("CORNER CHECK IGNORING sid=",sid,", not a note")
			continue
		}

		ch = sid/1000
		if ( ! (ch in corners) ) {
			corners[ch] = []
		}
		x = $.tuio_sid_x[sid]
		y = $.tuio_sid_y[sid]
		if ( x < 0 || y < 0 ) {
			# print("Hey, sid=",sid," has unset x/y?")
			continue
		}
		# print("Now=",Now," CORNER CHECK sid=",sid," x=",x," y=",y)
		if ( x < 0.20 && y < 0.20 ) {
			corners[ch]["lowerleft"] = sid
		}
		if ( x < 0.20 && y > 0.75 ) {
			corners[ch]["upperleft"] = sid
		}
		if ( x > 0.75 && y < 0.20 ) {
			corners[ch]["lowerright"] = sid
		}
		if ( x > 0.75 && y > 0.75 ) {
			corners[ch]["upperright"] = sid
		}
		
	}
	for ( ch in corners ) {
		arr = corners[ch]
		t = $.get_looper(ch-1)

		if ( ("lowerleft" in arr) && ("lowerright" in arr) ) {
			print("MAGIC LL,LR !! ch=",ch," TURNING LOOPING OFF")
			$.disabled_till_clear[ch] = 1
			t.set_chanparam("recording",0)
			t.set_chanparam("playloop",0)
			# $.realtime(ano(ch),Now)
			$.realtime(ano(),Now)  # all channels
		}
		if ( ("upperleft" in arr) && ("upperright" in arr) ) {
			print("MAGIC UL,UR !! ch=",ch," TURNING LOOPING ON")
			$.disabled_till_clear[ch] = 1
			t.set_chanparam("recording",1)
			t.set_chanparam("playloop",1)
		}
		if ( ("upperleft" in arr) && ("lowerright" in arr) ) {
			print("MAGIC UL,LR !! ch=",ch)
			$.disabled_till_clear[ch] = 1
		}
		if ( ("lowerleft" in arr) && ("upperright" in arr) ) {
			print("MAGIC LL,UR !! ch=",ch," CHANGING PATCH!")
			if (sid in Tuio_sid_note) {
				print("SHOULD BE SENDING noteoff for sid=",sid," note=",Tuio_sid_note[sid])
			} else {
				print("No Tuio_sid_note for sid=",sid)
			}
			sid_ll = arr["lowerleft"]
			sid_ur = arr["upperright"]
			sid_lr = arr["lowerright"]
			sid_ul = arr["upperleft"]
			# print("CLEANING UP NOTE ON sid_ll=",sid_ll," and sid_ur=",sid_ur)

			$.cleanup_note_on_sid(sid_ll)
			$.cleanup_note_on_sid(sid_ur)
			$.cleanup_note_on_sid(sid_lr)
			$.cleanup_note_on_sid(sid_ul)

			$.disabled_till_clear[ch] = 1

			print("CORNERS for chaning patch:")
			$.printxy(sid_ll)
			$.printxy(sid_ur)
			$.printxy(sid_lr)
			$.printxy(sid_ul)
			$.change_patch(t,ch)
			task $.delayed_ano(ch)
		}
	}
	}
	return()
}

method printxy(sid) {
	print("SID=",sid," x=",$.tuio_sid_x[sid]," y=",$.tuio_sid_y[sid])
}

method delayed_ano(ch) {
	# final attempt to silence notes during patch changes
	sleeptill(Now+1b)
	realtime(ano(ch))
}

method handle_osc(d) {

	# if ( DebugOsc ) 
	# 	print("handle_osc d=",d)

	addr = d[0]
	t = $.get_looper($.currloop)
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
		t = $.get_looper($.currloop)
		print("SETTING CHANNEL =",t.get_currchan())
	} else if ( addr == "/nth/currentloop" ) {
		print("/nth/currentloop IS BEING IGNORED!")
		return()
	} else if ( addr == "/nth/perchan/set" ) {
		nm = d[1]
		looptoset = d[2]-1
		v = d[3]
		t = $.get_looper(looptoset)
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
		t = $.get_looper(lp)
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
		$.transpose_pos = 0
		print("Multiple Quick TransRand == TransReset!\n");
		# $.all_loops("oneloop_clear")
		# print("Multiple Quick TransRand == TransReset and ALL LOOP CLEAR!\n");
	} else {
		if ( TransReallyRand ) {
			trans = [0=3,1=5,2=7]
			tp = (rand(2)*2-1) * trans[rand(sizeof(trans))]
			$.set_transpose($.get_transpose()+tp)
			# print("SINGLE TransRand!")
		} else {
			trans = [0=0,1=3,2=-2,3=5]
			$.transpose_pos = ($.transpose_pos+1) % sizeof(trans)
			tp = trans[$.transpose_pos]
			$.set_transpose(tp)
		}
	}
	$.last_transrand = Now
}

method jsontask(jsonf) {
	global ergox_klooper_techshop_json_restart
	onexit(ergox_klooper_techshop_json_restart,$)

	# Input will start coming as soon as a connection is open,
	# and setting the fifotype on the socket inside handle_json is
	# too late, so we change the default.
	fifoctl("default","type","l")

	if ( DebugJson )
		print("JSONTASK starts")
	while ( (x=get(jsonf)) != Eof ) {
		task $.handle_json(x)
	}
	print("JSONTASK ends!?")
}

method handle_json(jsonconn) {

	if ( DebugJson >1 )
		print("New JSON connection!")

	reqtype = ""
	while ( (d=get(jsonconn["r"])) != Eof ) {
		if ( DebugJson > 2 )
			print("GOT line:",d)
		if ( d == "\n" || d == "\r\n" || d == "\r" ) {
			# if ( DebugJson )
			# 	print("GOT JSON blank line")
			if ( reqtype == "GET" ) {
				$.get_response(jsonconn["w"],getline)
				break;
			} else if ( reqtype == "POST" ) {
				# print("GOT POST request, continue reading")
			} else {
				print("GOT unrecognized request")
				put(jsonconn["w"],"Unrecognized request\n")
				break;
			}
			
		} else if ( substr(d,1,4) == "GET " ) {
			# if ( DebugJson )
			# 	print("GOT GET: ",d)
			reqtype = "GET"
			getline = d
		} else if ( substr(d,1,5) == "POST " ) {
			# if ( DebugJson )
			# 	print("GOT POST: ",d)
			reqtype = "POST"
			postline = d
		} else if ( substr(d,1,8) == "OPTIONS " ) {
			if ( DebugJson )
				print("GOT OPTIONS: ",d)
			reqtype = "OPTIONS"
		} else if ( substr(d,1,1) == "{" ) {
			if ( DebugJson ) {
				if ( strindex(d,"\"hello\"") < 0 ) {
					print("JSON INPUT: ",d)
				}
			}
			j = $.string2json(d)
			ret = $.jsonhandler(j)
			if ( DebugJson >2 )
				print("JSON OUTPUT: ",ret)
			put(jsonconn["w"],ret)
			break
		} else {
			# if ( DebugJson )
			# 	print("GOT NON-JSON: ",d)
		}
	}
	# if ( DebugJson )
	# 	print("CLOSING JSON connection!")
	close(jsonconn["r"])
	close(jsonconn["w"])
}

method get_response(fout,getline) {

	put(fout,"GET has been disabled!\n")
	return()

	# Responses seem to get occasionally corrupted,
	# not sure why, but the lock helps
	# lock("get_response")

	if ( DebugJson )
		print("START:",getline)
	words = split(getline)
	url = words[1]
	if ( url == "/" )
		url = "index.html"
	fname = KlooperHtmlDir + url
	fin = open(fname)
	if ( fin >= 0 ) {
		# print("Sending back fname=",fname)
		if (
			strindex(fname,".html") > 0
			|| strindex(fname,".htm") > 0
			|| strindex(fname,".css") > 0
			|| strindex(fname,".js") > 0
			) {
			fifoctl(fin,"type","l")
			fifoctl(fout,"type","l")
			cnt = 0
			totsize = 0
			while ( (line=get(fin)) != Eof ) {
				chunk = 64
				left = sizeof(line)
				while ( left > 0 ) {
					part1 = substr(line,1,chunk)
					line = substr(line,chunk+1)
					put(fout,part1)
					# print("CHUNK size=",sizeof(part1))
					totsize += sizeof(part1)
					cnt++
					left = sizeof(line)
					sleeptill(Now+1)
				}
				# put(fout,line)
				# totsize += sizeof(line)
				# cnt++
			}
			close(fin)
			print("TEXT FILE=",fname," had ",cnt," lines and ",totsize," bytes")
		} else {
			fifoctl(fin,"type","b")
			fifoctl(fout,"type","b")
			cnt = 0
			while ( (c=get(fin)) != Eof ) {
				put(fout,integer(c))
				cnt++
			}
			close(fin)
			# print("BINARY FILE=",fname," had ",cnt," bytes")
		}
	} else {
		print("UNABLE TO OPEN fname=",fname)
	}
	if ( DebugJson )
		print("END:",getline)
	# unlock("get_response")
}

method options_response(f) {
	s = "HTTP/1.1 200 OK\r\n"
		+"Access-Control-Allow-Origin: *\r\n"
		+"Access-Control-Allow-Methods: GET, POST, OPTIONS\r\n"
		+"Content-Length: 0\r\n"
		+"\r\n"
		+"\r\n";
	print("Sending back: s=",s)
	put(f,s)
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
	d = $.substitute(d,"[","arraylistordered(")
	d = $.substitute(d,"]",")")
	d = $.substitute(d,"{","[")
	d = $.substitute(d,"}","]")
	if ( DebugJson > 2 )
		print("STRING2JSON = ",d)
	global true
	global false
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

method jsonresult_number(r,id) {
	return( "{\"jsonrpc\": \"2.0\", \"result\": " + string(r) + ", \"id\": \""+string(id)+"\" }\r\n" )
}

method perchan_set(nm,v,looptoset) {
	# print("perchan_set, name=",nm," ch/looptoset=",params["channel"]," v=",v)

	t = $.get_looper(looptoset)
	ch = t.get_currchan()
	if ( ! (nm in $.perchanparamlist) ) {
		return("UNKNOWN loop parameter: "+nm)
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
	return( Nullval)
}

method global_set(nm,v) {
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
		return("UNKNOWN global parameter: "+nm)
	}
	return( Nullval)
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
		msg = $.perchan_set(nm,v,looptoset)
		if ( msg == Nullval ) {
			return( $.jsonok("True",id) )
		} else {
			return($.jsonerr(msg,id))
		}
	}
	if ( meth == "global_set" ) {
		nm = params["name"]
		v = params["value"]
		msg = $.global_set(nm,v)
		if ( msg == Nullval ) {
			return( $.jsonok("True",id) )
		} else {
			return($.jsonerr(msg,id))
		}

	}
	if ( meth == "global_get" ) {
		nm = params["name"]
		v = $.get_globalparam(nm)
		print("global_set, name=",nm," v=",v)
		if ( v == Nullval ) {
			return($.jsonerr("UNKNOWN global parameter: "+nm,id))
		}
		if ( typeof(v) == "string" ) {
			return($.jsonresult_str(v,id))
		} else {
			return($.jsonresult_number(v,id))
		}
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
		t = $.get_looper(lp)
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
		t = $.get_looper($.currloop)
		print("SETTING CHANNEL =",t.get_currchan(),"  currloop=",lp)
		return( $.jsonok("True",id) )
	}

	return($.jsonerr("Klooper has no method named "+meth,-1))
		
	addr = d[0]
	t = $.get_looper($.currloop)
	ch = t.get_currchan()

	if ( addr == "/nth/echo" ) {
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

method check_looper() {
	if ( sizeof($.ergox_klooper) != $.nloops ) {
		print("Hey!  ergox_klooper has changed!? = ",$.ergox_klooper)
		return()
	}
}

method all_loops(action,...) {
	$.check_looper()
	for ( lp in $.ergox_klooper ) {
		t = $.ergox_klooper[lp]
		t.(action)(...)
	}
}

method get_scale() {
	return($.curr_scale)
}

method set_soundset() {
	print("SOUNDSET setting is disabled!")
	return()

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
	# print("SENDING bidule on/off =",msg)
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
	print("SCALE = ",nm,"  sc=",sc)
	$.completescalesz = sizeof(sc)
	$.curr_scale = sc
	$.check_looper()
	for ( lp in $.ergox_klooper ) {
		t = $.ergox_klooper[lp]
		# print("lp=",lp," t=",t," calling set_loop_needs_scaling")
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

	$.check_looper()
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

	$.clocktid = task $.check_stuff()
}

method check_stuff() {
	tm = nextquant(Now,1b/2)
	dt = 1b/2
	if ( ForceRestartMinutes > 0 ) {
		force_restart = tm + milliclicks(1000*60*ForceRestartMinutes)
	} else {
		force_restart = -1
	}
	while (1) {
		$.check_autotranspose()
		sleeptill(tm)
		if ( $.oscclock ) {
			m2 = [0="/nth/clock",1=tm]
			$.to_osc_clients(m2)
		}
		# print("tm=",tm," force_restart=",force_restart," Now=",Now)
		if ( force_restart > 0 && Now > force_restart ) {
			print("Calling $.stop!")
			task $.stop()
			break
		}
		tm += dt
	}
}

method stop {
	if ( $.stopme != 0 ) {
		print("Multiple calls to $.stop are ignored")
		return()
	}
	$.stopme = 1
	$.quit = 1
	kill($.miditid)
	kill($.clocktid)
	kill($.constid)
	kill($.osctid)
	kill($.jsontid1)
	# kill($.jsontid2)
	print("Closing oscf=",$.oscf)
	if ( $.oscf >= 0 ) {
		close($.oscf)
		$.oscf = -1
	}
	if ( $.jsonf1 >= 0 ) {
		close($.jsonf1)
		$.jsonf1 = -1
	}
	print("STOP D")
	# if ( $.jsonf2 >= 0 )
	# 	close($.jsonf2)
	for ( f in $.oscclients ) {
		close(f)
	}
	$.oscclients = []

	$.check_looper()
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
	print("STOP end")
}

method cons_task() {
	$.consf = Root.grabconsole()
	global ergox_klooper_techshop_resetconsole
	onexit(ergox_klooper_techshop_resetconsole,$)
	while ( $.quit == 0 && (c=get($.consf)) != Eof ) {
		# print("GOT c=",c," from console")
		$.handle_console(c)
	}
}

method midi_task(f) {
	global ergox_klooper_techshop_midi_restart
	onexit(ergox_klooper_techshop_midi_restart,$)
	while ( (c=get(f)) != Eof ) {
		print("Got midi c=",c)
		if ( DebugLoop ) {
			print("DD! calling handle_midi_keyboard c=",c)
		}
		$.handle_midi_keyboard(c,Midiloopnum,Midisid)
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
		print("NOT RESTARTING jsontask!!")
		# print("RESTARTING jsontask!!")
		# $.jsontid1 = task $.jsontask($.jsonf1)
		## $.jsontid2 = task $.jsontask($.jsonf2)
	}
}

method putline(f,s) {
	put(f,s)
	put(f,"\n")
}

method ison(nm,v) {
	if ( v=="on" || v==1 )
		return(1)
	if ( v=="off" || v==0 )
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
				t = $.get_looper($.currloop)
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
		return(Nullval)
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
	# print("SET TRANSPOSE = ",val)
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

method makechord(c) {
	r = ''
	chord = ChordList[ChordType]
	for ( nt in chord ) {
		r |= transpose(c,nt.pitch - 12)
	}
	return(r)
}

method handle_midi_keyboard(c,loopnum,sid) {

	if ( nargs() < 3 ) {
		print("Hey, no sid passed to handle_midi_keyboard!")
		return()
	}
	if ( DebugMidi || DebugLoop )
		print("Now=",Now," handle_midi_keyboard loop=",loopnum," c=",c," sid=",sid)

	t = $.get_looper(loopnum)
	ch = t.get_currchan()

	# Indicate incoming MIDI notes with red
	if ( DoFlash && c.type == NOTEON ) {
		task $.launchpad_flash_input_chan(ch,2)
	}

	c.time = 0
	c.chan = ch
	isrecording = t.is_recording() && t.is_playloop()

	if ( Chording ) {
		c = $.makechord(c)
	}

	if ( isrecording && DebugReal ) {
		print("handle_midi_keyboard c=",c," isrecording=",isrecording)
	}
	# print("   t.is_recording=",t.is_recording()," t.is_playloop=",t.is_playloop()," t.get_currchan=",t.get_currchan())

	# if ( ! isrecording && c.type == CONTROLLER ) {
	if ( c.type == CONTROLLER ) {
		c.port = 0
		c.time = 0
		print("Sending controller=",c)
		$.realtime(c,Now,0,-1)
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
			print("Passing controller through c=",c)
			t.realtime(c,0,0,-1)
			return()
		} else {
			print("Passing non-note/non-controller through c=",c," playat=",playat)
			t.realtime(c,0,0,-1)
			return()
		}
		q = t.get_chanparam("quantrec")
		if ( DebugLoop ) {
			print("AA USING quantrec is_recording = ",q)
		}
		t.looper_input_pq(keydown,c,1.5,900+c.pitch,1,q,sid)
	} else {
		# print("is NOT recording c=",c)
		if ( doscadjust ) {
			# print("c B before scadjust = ",c)
			sc = $.get_scale()
			c = scadjust(c,sc)
			# print("c B after scadjust = ",c)
		}
		q = t.get_chanparam("quantreal")
		# print("USING quantreal NOT recording/looping = ",q)
		if ( q > 0 ) {
			playat = nextquant(Now,q)
		} else {
			playat = Now
		}
		isstuttering = t.isstuttering()
		isprestuttering = t.isprestuttering()
		if ( isstuttering || isprestuttering) {
			c = t.do_stutter(c)
			t.realtime(c,playat,1,sid)
			c.time += 1b/8
			c.type = NOTEOFF
			t.realtime(c,Now,1,-1)
		} else {
			c.time = 0
			print("CALLING REALTIME CC")
			t.realtime(c,playat,1,sid)
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
	if ( DebugReal2 ) {
		print("Now=",Now," REALTIME in Mastertypo p=",p," tm=",tm," tm%48=",tm%48)
	}
	realtime(p,tm)
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
			t = $.get_looper($.currloop)
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
			t = $.get_looper($.currloop)
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
	if ( c == "Z" && keydown ) {
		DebugZ = 1 - DebugZ
		print("DebugZ is now ",DebugZ)
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
	if ( c == "N" && keydown ) {
		print("Sending Ano")
		realtime(ano())
		return()
	}
	if ( c == "J" && keydown ) {
		DebugJson = !DebugJson
		print("DebugJson is now ",DebugJson)
		return()
	}

	if ( keydown && c != "SHIFT")
		print("Ignoring char=",c)
	return()

}

method ctrl_exec(c,nw) {
	if ( c == "Q" ) {
		realtime(ano())
		print("SETTING StopContinuous!")
		global StopContinuous
		StopContinuous = 1
		$.quit = 1
	} else if ( c == "V" ) {
		$.verbose = 1 - $.verbose
	}
}

}


class ergox_klooper_techshop_onelooper {

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
		"Fastest" = 10
		]

}

method set_volume() {
	v = $.get_chanparam("volume")
	p = controller($.currchan,0x07,v)
	# print("SET_VOLUME chan=",$.currchan," p=",p)
	$.realtime(p,Now,0,-1)
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
	# print("Changing chanparam nm=",nm," v=",v)
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
			print("Now=",Now," REALTIME TASK loopnum=",$.loopnum," loopleng = ",loopleng," loopphrase=",$.loopphrase)

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
		# if ( DebugReal && $.loopphrase != '')
		# 	print("REALTIME TASK TWO")

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

	# if ( DebugLoop && $.currchan == 1 ) {
	# 	print("START play_loop, ch=",$.currchan," tm=",tm," loopleng=",loopleng)
	# }

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
		print("Playing chan ",ch," in loop ",$.loopnum," loopphrase=",$.loopphrase)
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

method realtime(p,tm,dovis,sid) {
	if ( nargs() < 4 ) {
		error("WARNING, four arguments not present in realtime! Nothing will be played!")
		return()
	}

	print("REALTIME X p=",p," sid=",sid," tm=",tm," tm%48=",tm%48," Now=",Now)
	# print("LastTime=",LastTime," diff=",tm-LastTime)
	LastTime = tm
	if ( p.type != NOTEON && p.type != NOTEOFF && sid != -1 ) {
		error("UNEXPECTED in realtime!  p.type=",p.type," and sid=",sid)
	}
	if ( ( p.type == NOTEON || p.type == NOTEOFF ) && sid == -1 ) {
		error("UNEXPECTED in realtime!  p.type=",p.type," and sid=",sid)
	}
	# if ( sizeof(p) > 1 ) {
	# 	error("UNEXPECTED in realtime!  sizeof(p) > 1?  p=",p)
	# }

	if ( sid >= 0 ) {

		if ( ! (sid in Tuio_sid_lasttm) ) {
			# print("Now=",Now," sid=",sid," INSERTING -1 into Tuio_sid_lasttm!")
			if ( DebugReal )
				print("Setting Tuio_sid_lasttm of sid=",sid," to ZERO!")
			Tuio_sid_lasttm[sid] = 0
		}
		if ( ! (sid in Tuio_sid_note) ) {
			# print("Now=",Now," sid=",sid," INSERTING '' into Tuio_sid_note!")
			Tuio_sid_note[sid] = ''
		}
		lasttm = Tuio_sid_lasttm[sid]
		tminc = 2
		addtoloop = ''
		passthru = 0
		if ( p.chan == 8 )
			passthru = 1
		if ( p.type==NOTEON && ! passthru ) {
			prevnt = Tuio_sid_note[sid]

			# If the previous note was a NOTEON, we either
			# want to kill it (if it hasn't played yet),
			# or send a NOTEOFF for it.
			if ( prevnt.type == NOTEON ) {
				if ( tm >= lasttm && Now < lasttm ) {
					if ( DebugNotes )
						print("Now=",Now," sid=",sid," Killing previous note at lasttm=",lasttm)
					kill(Tuio_sid_task[sid])
					lasttm = -1
				} else {
					# Send noteoff to terminate previous note
					offtime = lasttm + tminc

					# if ( DebugLoop ) {
					# 	addtoloop = prevnt
					# 	addtoloop.type = NOTE
					# 	addtoloop.dur = tm - lasttm
					# 	print("SHOULD BE ADDING TO LOOP prevnt=",prevnt," Now=",Now," addtoloop=",addtoloop," lasttm=",lasttm," tm=",tm)
					# }
					prevnt.type = NOTEOFF
					if ( offtime < Now )
						offtime = Now

					print("==== TRYING NEW handle_midi for noteoff")
					sc = $.parent.handle_midi_keyboard(prevnt,$.loopnum,sid)
				}
				# if ( prevnt.pitch == p.pitch ) {
				# 	print("Identical NOTEON, NOT PLAYING nt=",p)
				# 	return()
				# }

			}
		}

		# Re-obtain lasttm, because handle_midi_keyboard
		# may have updated it
		lasttm = Tuio_sid_lasttm[sid]
		# print("**** Re-Updating lasttm to ",lasttm)
		if ( PushOut ) {
			if ( tm <= lasttm ) {
				print("Now=",Now," sid=",sid," tm=",tm," lasttm=",lasttm," PUSHING TM OUT A BIT!")
				tm = lasttm + tminc
			}
		}

		# print("REAL REALTIME Now=",Now," sid=",sid," ====== REALTIME p=",p," tm=",tm," lasttm=",lasttm," tm%48=",tm%48)
		t = realtime(p,tm)
		Tuio_sid_lasttm[sid] = tm
		# print("Setting Tuio_sid_lasttm of sid=",sid," to ",tm)
		Tuio_sid_note[sid] = p
		Tuio_sid_task[sid] = t
		if ( p.type == NOTEON ) {
			Chan_activity[p.chan] = 1
		}
		# print("Now=",Now," sid=",sid," realtime saving lasttm=",tm," for nt=",p," task=",t)
	} else {
		if ( DebugReal )
			print("Now=",Now," ==== NO SID REALTIME p=",p," tm=",tm)
		t = realtime(p,tm)
	}

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

		# playing_loop = $.get_chanparam("playloop")
		playing_loop = $.is_playloop()
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
		$.realtime(nt,Now,0,-1)
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

method oneloop_noloop() {
	# print("ONELOOP_NOLOOP called!!!!")
	$.set_chanparam("recording",0)
	$.set_chanparam("playloop",0)
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
	if ( DebugLoop ) {
		print("SET LOOP Phrase p= ",p)
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
	if ( DoSlow ) {
		slow = $.vals["slowness"]
		if ( slow != 1 ) {
			p = scatimes(p,slow)
			print("APPLY_MODS slow=",slow," BB p=",p)
		}
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

method finishnotes() {
	print("FINISHNOTES")
	for ( uid in $.lastplayedphr ) {
		print("FINISHNOTES uid=",uid)
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

# method looper_input_p(keydown,p,prox,uid,reallymidi,sid) {
# 
# 	print("LOOPER_INPUT_P keydown=",keydown,"uid=",uid,"p=",p)
# 	if ( typeof(p) != "phrase" ) {
# 		print("Hmmm, p isn't a phrase at XX?")
# 		return()
# 	}
# 	if ( p == '' ) {
# 		print("NULL phrase given to looper_input_p?")
# 		return()
# 	}
# 	$.looper_input_pq(keydown,p,prox,uid,reallymidi,$.stepsize,sid)
# }

method is_recording() {
	# if ( LoopingWhileDown ) {
	# 	# print("LoopingWhileDown is forcing is_recording to true!")
	# 	return(1)
	# }
	return($.get_chanparam("recording"))
}
method is_playloop() {
	# if ( LoopingWhileDown ) {
	# 	# print("LoopingWhileDown is forcing is_playloop to true!")
	# 	return(1)
	# }
	return($.get_chanparam("playloop"))
}

method isstuttering() {
	return($.get_chanparam("stutter"))
}
method isprestuttering() {
	return($.get_chanparam("prestutter"))
}

# prox isn't used...

method looper_input_pq(keydown,p,prox,uid,reallymidi,qnt,sid) {

	if ( nargs() < 7 ) {
		print("Hey! no sid passed to looper_input_pq!")
		return()
	}
	nw = nextquant(Now,qnt)

	if ( DebugLoop )
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
		# print("REALTIME POSTMID recording uid=",uid," p=",p," Now=",Now," nw=",nw)
		$.lastplayedphr[uid] = p
		# print("keydown lastplayedphr for uid=",uid," is ",p)
		if ( $.sustainwhiledown ) {
			p.type = NOTEON
		}
		# print("REALTIME XA p=",p," Now=",Now," nw=",nw," nw%48=",nw%48)
		# p = $.do_stutter(p)
		# print("REALTIME XB p=",p," Now=",Now," nw=",nw)
		$.lastplayedtid[uid] = $.realtime(p,nw,1,sid)
		$.lastplayedtm[uid] = nw
		return()
	}

	if ( ! (uid in $.lastplayedphr) ) {
		# print("Hey, uid=",uid," is not in lastplayedphr = ",$.lastplayedphr)
		return()
	}

	p = $.lastplayedphr[uid]

	if ( DebugLoop )
		print("keyup in looper_input, lastplayedphr, p=",p)

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
			$.realtime(p,nw,1,sid)
		}
		return()
	}
	# We ARE recording
	if ( DebugLoop )
		print("WE ARE RECORDING, p=",p)

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
	
	$.realtime(p,nw,1,sid)
	# print("REALTIME XE playing p=",p," Now=",Now," nw=",nw," nw%48=",nw%48)
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

	if ( (Now - $.last_fade) < milliclicks(1200) ) {
		print("MULTIPLE FADES IN < 1.2 secs, IGNORING!")
		return()
	}
		
	if ( $.loopphrase != '' ) {
		print("DOING FADE!")
		if ( ischan || $.should_fade() ) {
			$.cumulative_fade += $.fadevol
			$.setloopphrase($.fade_phr($.loopphrase,$.fadevol))
		}
		if ( $.loopphrase == '' ) {
			print("FADED COMPLETELY!! Clearing loop")
			$.oneloop_clear()
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

function ergox_klooper_techshop_resetconsole(o) {
	o.stop()
}

function ergox_klooper_techshop_midi_restart(o) {
	o.midi_restart()
}
function ergox_klooper_techshop_osc_restart(o) {
	o.osc_restart()
}
function ergox_klooper_techshop_json_restart(o) {
	o.json_restart()
}
