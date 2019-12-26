#
# ergox_bayareameetup
#

#define xx eval "#include bayareameetup.k"
#define yy bayareameetup()

INCDEC_MID = 0
INCDEC_MIN = -2
INCDEC_MAX = 2
INCDEC_INC = 1
INCDEC_DEC = -1
TypoDebug = 0
DebugOsc = 1
LcdDebug = 0

#define xxx rereadlib();bbq()

function ergox_bayareameetup_actionmf {
	return(readmf("c:\\local\\midi\\tjt\\actionseries\\actionseries.mid"))
}

function bayareameetup() {

	if ( ! defined(Osclisten) ) {
		Osclisten = 1384
	}

	if ( ! defined(CherryControl) ) {
		print("Hey, CherryControl not defined!")
		return()
	}

	tempo(500000)

	if ( Machine != "win" ) {
		print("ergox_bayareameetup() only works on Windows, sorry!")
		return()
	}

	if ( ! defined(SalvationOutput) ) {
		SalvationOutput = -1
	}

	global GestureDevMap
	GestureDevMap = []

	# if ( ! defined(GestureDevMap) ) {
	# GestureDevMap = []
	# 	# GestureDevMap = [0=0,1=1,2=2,3=3]
	# }

	print("Setting dragthreshold to 0...")
	Gesturedragthreshold = 0.0
	GestureDraglimit = 60

	if ( defined(TypoGM) && TypoGM == 1) {
		print("Sending gmresetall")
		realmidi(gmresetall(0x40))
	}

	patchprefix = "patch"

	t = new ergox_bayareameetup_mastertypo(patchprefix)
	t.start()
	t.waittilldone()
	t.stop()
}

class ergox_bayareameetup_mastertypo {

method init(patchprefix) {

	$.oldMerge = Merge
	Merge = 0

	$.initdone = 0
	$.dir = "."

	mfname = "c:\\local\\midi\\tjt\\actionseries\\actionseries.mid"

	$.anycherry = 0
	$.lastrandvideo = Now

	$.fneural = -1
	$.fneural = open("9999@192.168.1.5","wb","osc_send")
	print("FNEURAL = ",$.fneural)

	$.sound_name = [
		0 = "TinyBell",
		1 = "ElecPiano",
		2 = "BellSwell",
		3 = "Harpschrd",
		4 = "KeyBell",
		5 = "Twang",
		6 = "Plink",
		7 = "Stringy",
		8 = "Ethereal",
		9 = "PlinkDrum",
		10 = "Kalimby",
		11 = "ToyBell",
		12 = "Spacey",
		13 = "Tribal",
		14 = "DrumsEtc"
		]

	$.button_controllers = [
		9=["name"="clear","lcdnum"=0],
		8=["name"="select","lcdnum"=0],
		0xb=["name"="controlG","lcdnum"=0],
		0xa=["name"="controlM","lcdnum"=0],
		16+9=["name"="clear","lcdnum"=1],
		16+8=["name"="select","lcdnum"=1],
		16+0xb=["name"="controlG","lcdnum"=1],
		16+0xa=["name"="controlM","lcdnum"=1]
		]

	# map midi controller #'s to knob #'s
	$.ctrl2knob = [
		23 = ["row"=0,"col"=0,"lcdnum"=1],
		22 = ["row"=1,"col"=0,"lcdnum"=1],
		21 = ["row"=2,"col"=0,"lcdnum"=1],
		20 = ["row"=3,"col"=0,"lcdnum"=1],
		19 = ["row"=0,"col"=1,"lcdnum"=1],
		18 = ["row"=1,"col"=1,"lcdnum"=1],
		17 = ["row"=2,"col"=1,"lcdnum"=1],
		16 = ["row"=3,"col"=1,"lcdnum"=1],

		7 = ["row"=0,"col"=0,"lcdnum"=0],
		6 = ["row"=1,"col"=0,"lcdnum"=0],
		5 = ["row"=2,"col"=0,"lcdnum"=0],
		4 = ["row"=3,"col"=0,"lcdnum"=0],
		3 = ["row"=0,"col"=1,"lcdnum"=0],
		2 = ["row"=1,"col"=1,"lcdnum"=0],
		1 = ["row"=2,"col"=1,"lcdnum"=0],
		0 = ["row"=3,"col"=1,"lcdnum"=0]
		]

	$.init_fx()


	$.save_filenames = [0="save1",1="save2",2="save3"]

	$.patchprefix = patchprefix

	$.presets = [
		"graphic"=$.num_presets("graphic"),
		"music"=$.num_presets("music"),
		"all"=$.num_presets("all")
		]

	$.NoteDur = 63
	$.NoteFreq = 63
	$.NoteVol = 63
	$.ProxVel = 63
	$.DownQnt = 63
	$.RepQnt = 63
	$.CollQnt = 63
	$.Chordize = 0
	$.LoopNotes = 100
	$.RandVideo = 63

	$.Transpose = 0
	$.Sequence = 0
	$.SeqLeng = 63
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
	$.ignore_up = [0=0,1=0]
	$.refresh_on_up = [0=0,1=0]
	$.ignore_controls = 0

	$.gesturepads = 2
	$.lcds = 2
	$.gesturepads = 1
	$.lcds = 1
	print("TOUCH ",$.gesturepads," PAD(s) IN ORDER...")

	$.finger_does_midi = 0
	print("MIDI in ergox_bayareameetup is disabled!!!!")
	$.finger_does_graphics = 1

	# $.chord = 'c'
	# $.curr_scale = completescalephrase($.chord)
	# $.nextchord = ''

	$.vidmode = 0
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
		5 = ["chan"=8,"x"=114,"y"=115],
		7 = ["chan"=8,"x"=112,"y"=113],
		8 = ["chan"=8,"x"=116,"y"=117]
		]

	$.Quant = 1b/4
	$.loopquant = 8b
	$.quit = 0
	$.debug = 0
	$.lasttouchwarn = 0

	$.ergox_bayareameetup = []
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

#	$.params = [
#
#	   "chordornament" = ["ctrl"="musicvalue"],
#	   "loopxpose" = ["ctrl"="musicvalue"],
#	   "completescale" = ["ctrl"="musicvalue"],
#
#	   "zoomin" = ["row"=1,"strp"=3,"ctrl"="1chanaction","method"="zoomin","osc"=1],
#	   "zoomout" = ["row"=2,"strp"=3,"ctrl"="1chanaction","method"="zoomout","osc"=1],
#
#	   # music controls in first three rows of toggles
#	   "recording" = ["row"=0,"strp"=4,"ctrl"="toggle","default"=0],
#	   "fadeenable" = ["row"=1,"strp"=4,"ctrl"="toggle","default"=1],
#	   "fadefast" = ["row"=2,"strp"=4,"ctrl"="toggle","default"=1],
#
#	   "mono" = ["row"=0,"strp"=5,"ctrl"="toggle","default"=0],
#	   "quantdiv" = ["row"=1,"strp"=5,"ctrl"="toggle","default"=0],
#	   "killonup" = ["row"=2,"strp"=5,"ctrl"="toggle","default"=1],
#
#	   "longdur" = ["row"=0,"strp"=6,"ctrl"="toggle","default"=0],
#	   "ornamode" = ["row"=1,"strp"=6,"ctrl"="toggle","default"=0],
#	   "ornastep" = ["row"=2,"strp"=6,"ctrl"="toggle","default"=0],
#
#	   # music parameters
#	   "grabmode" = ["row"=2,"strp"=9,"ctrl"="toggle","default"=0],
#	   "loopxposemode" = ["row"=1,"strp"=9,"ctrl"="toggle","default"=0],
#
#	   "pos" = ["row"=0,"strp"=15,"ctrl"="chorded","inc"="advance_pos","dec"="rewind_pos","set"="set_pos","get"="get_pos","reset"="reset_pos","chan"="all"],
#	   "program" = ["row"=1,"strp"=15,"ctrl"="chorded","default"=0,"set"="set_program","get"="get_program","rand"="rand_program"],
#
#	   "chanpitch1" = ["row"=0,"strp"=14,"ctrl"="chorded","adjust"="adjust_xpose","arg"=1,"reset"="reset_xpose"],
#	   "chanpitch12" = ["row"=1,"strp"=14,"ctrl"="chorded","adjust"="adjust_xpose","arg"=12,"reset"="reset_xpose"],
#
#	   "allpitch1" = ["row"=0,"strp"=13,"ctrl"="chorded","adjust"="adjust_xpose","arg"=1,"chan"="all","reset"="reset_xpose"],
#	   "allpitch5" = ["row"=1,"strp"=13,"ctrl"="chorded","adjust"="adjust_xpose","arg"=5,"chan"="all","reset"="reset_xpose"],
#	   "allpitch7" = ["row"=2,"strp"=13,"ctrl"="chorded","adjust"="adjust_xpose","arg"=7,"chan"="all","reset"="reset_xpose"],
#
#	   "tempo" = ["row"=0,"strp"=12,"ctrl"="chorded","set"="set_tempo","default"=500000,"inc"="inc_tempo","dec"="dec_tempo"],
#	   "quant" = ["row"=1,"strp"=12,"ctrl"="chorded","set"="set_quant","get"="get_quant","default"=$.Quant,"inc"="inc_quant","dec"="dec_quant"],
#	   "length" = ["row"=2,"strp"=12,"ctrl"="chorded","get"="get_length","set"="set_length","inc"="inc_length","dec"="dec_length","default"=8b],
#
#	   "slowness" = ["row"=2,"strp"=11,"ctrl"="chorded","default"=1,"set"="set_slowness","get"="get_slowness","inc"="inc_slowness","dec"="dec_slowness"],
#
#	   # music actions
#	   "killchan" = ["row"=2,"strp"=14,"ctrl"="1chanaction","method"="killchan","osc"=1],
#
#	   "killall" = ["row"=2,"strp"=15,"ctrl"="allchanaction","method"="killall","osc"=1],
#	   "color_rand" = ["row"=0,"strp"=7,"ctrl"="allchanaction","method"="color_rand"],
#	   "colorcycle" = ["row"=1,"strp"=7,"ctrl"="toggle","default"=1,"osc"=1],
#
#	   "change_comb" = ["row"=0,"strp"=10,"ctrl"="1chanaction","method"="change_comb"],
#	   "change_combonbeat" = ["row"=1,"strp"=10,"ctrl"="1chanaction","method"="change_combonbeat"],
#	   "change_shuffle" = ["row"=2,"strp"=10,"ctrl"="1chanaction","method"="change_shuffle"],
#
#	   "change_combonbeat2" = ["row"=1,"strp"=11,"ctrl"="1chanaction","method"="change_combonbeat2"],
#
#	   "mirrored" = ["row"=4,"strp"=0,"ctrl"="toggle","default"=0],
#	   "moving" = ["row"=4,"strp"=1,"ctrl"="toggle","default"=0],
#	   "colorchanging" = ["row"=4,"strp"=2,"ctrl"="toggle","default"=0],
#	   "posalg1" = ["row"=4,"strp"=3,"ctrl"="toggle","default"=0],
#	   "drawaction" = ["row"=5,"strp"=0,"ctrl"="toggle","default"=0],
#	   "midiaction" = ["row"=5,"strp"=1,"ctrl"="toggle","default"=1],
#	   "colorfast" = ["row"=5,"strp"=2,"ctrl"="toggle","default"=0],
#	   "posalg2" = ["row"=4,"strp"=4,"ctrl"="toggle","default"=0],
#	   "autoang" = ["row"=5,"strp"=3,"ctrl"="toggle","default"=0],
#	   "posnoise" = ["row"=5,"strp"=5,"ctrl"="toggle","default"=0],
#	   "initialnoise" = ["row"=5,"strp"=6,"ctrl"="toggle","default"=0],
#	   "vertexnoise" = ["row"=5,"strp"=6,"ctrl"="toggle","default"=0],
#	   "dir1" = ["row"=5,"strp"=7,"ctrl"="toggle","default"=0],
#	   "dir2" = ["row"=5,"strp"=8,"ctrl"="toggle","default"=0],
#	   "angdir" = ["row"=5,"strp"=9,"ctrl"="toggle","default"=0],
#
#	   # row 0 sliders (for music)
#	   "volume0" = ["row"=0,"strp"=0,"ctrl"="slider","default"=0.5,"ctrl"=110,"chan"=9],
#	   "volume1" = ["row"=0,"strp"=1,"ctrl"="slider","default"=0.5,"ctrl"=111,"chan"=9],
#	   # "volume2" = ["row"=0,"strp"=2,"ctrl"="slider","default"=0.5,"ctrl"=112,"chan"=9],
#	   # "fx0" = ["row"=0,"strp"=3,"ctrl"="slider","default"=0.5,"ctrl"=113,"chan"=9],
#	   # "fx1" = ["row"=0,"strp"=4,"ctrl"="slider","default"=0.5,"ctrl"=114,"chan"=9],
#
#
#	   # row 1 sliders (for graphics)
#	   "speedm" = ["row"=1,"strp"=0,"ctrl"="slider","default"=0.5],
#	   "speeda" = ["row"=1,"strp"=1,"ctrl"="slider","default"=0.5],
#	   "velang" = ["row"=1,"strp"=2,"ctrl"="slider","default"=0.5],
#	   "allsize" = ["row"=1,"strp"=3,"ctrl"="slider","default"=0.5],
#	   "aspect" = ["row"=1,"strp"=4,"ctrl"="slider","default"=0.5],
#	   "growfactor" = ["row"=1,"strp"=5,"ctrl"="slider","default"=0.5],
#	   "alpha" = ["row"=1,"strp"=6,"ctrl"="slider","default"=0.5],
#	   "alphafade" = ["row"=1,"strp"=7,"ctrl"="slider","default"=0.5],
#	   "sizefade" = ["row"=1,"strp"=8,"ctrl"="slider","default"=0.5],
#	   "screenfade" = ["row"=1,"strp"=9,"ctrl"="slider","default"=0.5,"global"=1],
#	   "linewidth" = ["row"=1,"strp"=10,"ctrl"="slider","default"=0],
#	   "noisex" = ["row"=1,"strp"=11,"ctrl"="slider","default"=0],
#	   "noisey" = ["row"=1,"strp"=12,"ctrl"="slider","default"=0],
#	   "nsprites" = ["row"=1,"strp"=13,"ctrl"="slider","default"=0.2],
#	   "initang" = ["row"=1,"strp"=14,"ctrl"="slider","default"=0],
#	   "hue1" = ["row"=1,"strp"=15,"ctrl"="slider","default"=0]
#	]


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
		"M" = "ctrl_midi",		# MIDI on/off
		"G" = "ctrl_graphics",		# Graphics on/off
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


	$.buttprimed = ""

	# Now create the loopers

	for ( n=0; n<npads; n++ ) { 

		vals = [ "chan" = n+1, "shape" = 5 ]
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
		$.ergox_bayareameetup[n] = new ergox_bayareameetup_onelooper($,$.fifos[n],$.Quant,ch,$.nphrases,8b,vals)
		t = $.ergox_bayareameetup[n]

		$.ergox_bayareameetup[n].assign_phrasescale('c')
	}

	print("Init done...") 

	$.forceallpads()

	$.button2selection = ["controlM"="music", "controlG"="graphic"]
	$.buttons = ["controlG"=0, "controlM"=0, "clear"=0, "select"=0]
	$.was_pressed = [
		0 = ["controlG"=0, "controlM"=0, "clear"=0, "select"=0],
		1 = ["controlG"=0, "controlM"=0, "clear"=0, "select"=0]
		]
	$.buttonstate = [
		0 = ["controlG"=0, "controlM"=0, "clear"=0, "select"=0],
		1 = ["controlG"=0, "controlM"=0, "clear"=0, "select"=0]
		]

	# keep track of last 2 buttondown times
	$.lastbuttondown = []
	for ( i in $.buttons ) {
		$.lastbuttondown[i] = [0=0,1=0]
	}


	$.knobmodes = ["controlG"=1, "controlM"=1, "controlA"=1]

	$.lcd_mode = []
	$.lcd_mode[0] = "controlG"	# controlG, controlM
	$.lcd_mode[1] = "controlG"	# controlG, controlM

	# $.offset = []
	# $.offset[0] = ["controlG"=0,"controlM"=0,"controlA"=0]
	# $.offset[1] = ["controlG"=0,"controlM"=0,"controlA"=0]

	$.planetmode = [0=$.planetmode_valmap(0),1=$.planetmode_valmap(0)]

	$.fftypes = []
	n = 0
	$.fftypes[n++] = ["name"="None", "toval"=6,
		"params"=[]
		]
	$.fftypes[n++] = ["name"="EdgeEnh", "toval"=12,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="Chromium", "toval"=18,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127],
			3=["low"=0,"high"=127],
			4=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="GaussBlur", "toval"=24,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127],
			3=["low"=0,"high"=127],
			4=["low"=0,"high"=127],
			5=["low"=0,"high"=127],
			6=["low"=0,"high"=127],
			7=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="Glow", "toval"=29,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127],
			3=["low"=0,"high"=127],
			4=["low"=0,"high"=127],
			5=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="HalfTone", "toval"=35,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127],
			3=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="Kaleid", "toval"=41,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127],
			3=["low"=0,"high"=127],
			4=["low"=0,"high"=127],
			5=["low"=0,"high"=127],
			6=["low"=0,"high"=127],
			7=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="LumaOffset", "toval"=47,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127],
			3=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="Posterize", "toval"=52,
		"params"=[
			0=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="RectDistort", "toval"=58,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127],
			3=["low"=0,"high"=127],
			4=["low"=0,"high"=127],
			5=["low"=0,"high"=127],
			6=["low"=0,"high"=127],
			7=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="SpiralBlur", "toval"=64,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127],
			3=["low"=0,"high"=127],
			4=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="TimeBlur", "toval"=70,
		"params"=[
			0=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="TimeSlice", "toval"=76,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127],
			3=["low"=0,"high"=127],
			4=["low"=0,"high"=127],
			5=["low"=0,"high"=127],
			6=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="Vectorize", "toval"=81,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127],
			3=["low"=0,"high"=127],
			4=["low"=0,"high"=127],
			5=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="TileCircle", "toval"=87,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127],
			3=["low"=0,"high"=127],
			4=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="Bubbles", "toval"=93,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127],
			3=["low"=0,"high"=127],
			4=["low"=0,"high"=127],
			5=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="Feedback", "toval"=99,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127],
			3=["low"=0,"high"=127],
			4=["low"=0,"high"=127],
			5=["low"=0,"high"=127],
			6=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="Fishy", "toval"=104,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127],
			3=["low"=0,"high"=127],
			4=["low"=0,"high"=127],
			5=["low"=0,"high"=127],
			6=["low"=0,"high"=127],
			7=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="Kaleid2", "toval"=110,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127],
			3=["low"=0,"high"=127],
			4=["low"=0,"high"=127],
			5=["low"=0,"high"=127],
			6=["low"=0,"high"=127],
			7=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="Mirror1", "toval"=116,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="Mirror2", "toval"=122,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127],
			3=["low"=0,"high"=127],
			4=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="Stripes", "toval"=127,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127],
			3=["low"=0,"high"=127]
			]
		]
	$.fftypes[n++] = ["name"="Twister", "toval"=128,
		"params"=[
			0=["low"=0,"high"=127],
			1=["low"=0,"high"=127],
			2=["low"=0,"high"=127],
			3=["low"=0,"high"=127],
			4=["low"=0,"high"=127],
			5=["low"=0,"high"=127],
			6=["low"=0,"high"=127],
			7=["low"=0,"high"=127]
			]
		]

	$.options = []
	n = 0

	$.options[n++] = ["name"="FF1Type", "type"="graphic", "dest"="ff",
		"valmap"="freeframetype_valmap", "def"=0,
		"params"=["chan"=1,"ctrl"=0]]
	$.options[n++] = ["name"="FF1Val1","type"="graphic", "dest"="ff",
		"params"=["chan"=1,"ctrl"=1]]
	$.options[n++] = ["name"="FF1Val2","type"="graphic", "dest"="ff",
		"params"=["chan"=1,"ctrl"=3]]
	$.options[n++] = ["name"="FF1Val3","type"="graphic", "dest"="ff",
		"params"=["chan"=1,"ctrl"=5]]
	$.options[n++] = ["name"="FF1Val4","type"="graphic", "dest"="ff",
		"params"=["chan"=1,"ctrl"=7]]
	$.options[n++] = ["name"="FF1Val5","type"="graphic", "dest"="ff",
		"params"=["chan"=1,"ctrl"=9]]
	$.options[n++] = ["name"="FF1Val6","type"="graphic", "dest"="ff",
		"params"=["chan"=1,"ctrl"=11]]
	$.options[n++] = ["name"="FF1Val7","type"="graphic", "dest"="ff",
		"params"=["chan"=1,"ctrl"=13]]
	$.options[n++] = ["name"="FF1Val8","type"="graphic", "dest"="ff",
		"params"=["chan"=1,"ctrl"=15]]

	$.options[n++] = ["name"="FF2Type", "type"="graphic", "dest"="ff",
		"valmap"="freeframetype_valmap", "def"=0,
		"params"=["chan"=2,"ctrl"=0]]
	$.options[n++] = ["name"="FF2Val1","type"="graphic", "dest"="ff",
		"params"=["chan"=2,"ctrl"=1]]
	$.options[n++] = ["name"="FF2Val2","type"="graphic", "dest"="ff",
		"params"=["chan"=2,"ctrl"=3]]
	$.options[n++] = ["name"="FF2Val3","type"="graphic", "dest"="ff",
		"params"=["chan"=2,"ctrl"=5]]
	$.options[n++] = ["name"="FF2Val4","type"="graphic", "dest"="ff",
		"params"=["chan"=2,"ctrl"=7]]
	$.options[n++] = ["name"="FF2Val5","type"="graphic", "dest"="ff",
		"params"=["chan"=2,"ctrl"=9]]
	$.options[n++] = ["name"="FF2Val6","type"="graphic", "dest"="ff",
		"params"=["chan"=2,"ctrl"=11]]
	$.options[n++] = ["name"="FF2Val7","type"="graphic", "dest"="ff",
		"params"=["chan"=2,"ctrl"=13]]
	$.options[n++] = ["name"="FF2Val8","type"="graphic", "dest"="ff",
		"params"=["chan"=2,"ctrl"=15]]

	$.options[n++] = ["name"="RandVideo","type"="graphic", "dest"="ff",
		"set"="set_randvideo","params"=["do"="randvideo"]]

	# per-lcd values
	$.options[n++] = ["name"="Color#1","type"="graphic"]
	$.options[n++] = ["name"="Color#2","type"="graphic"]
	$.options[n++] = ["name"="Alpha#1","type"="graphic"]
	$.options[n++] = ["name"="Alpha#2","type"="graphic"]
	$.options[n++] = ["name"="Size#1","type"="graphic"]
	$.options[n++] = ["name"="Size#2","type"="graphic"]
	$.options[n++] = ["name"="Width#1","type"="graphic"]
	$.options[n++] = ["name"="Width#2","type"="graphic"]
	$.options[n++] = ["name"="Shape#1","type"="graphic",
				"valmap"="shape_valmap"]
	$.options[n++] = ["name"="Shape#2","type"="graphic",
				"valmap"="shape_valmap"]
	# $.options[n++] = ["name"="PadMode#1","type"="all","def"=0,
	# 			"valmap"="fingermode_valmap",
	# 			"set"="set_fingermode","params"=["lcdnum"=0]]
	# $.options[n++] = ["name"="PadMode#2","type"="all","def"=0,
	# 			"valmap"="fingermode_valmap",
	# 			"set"="set_fingermode","params"=["lcdnum"=1]]

	$.options[n++] = ["name"="PadMode#1","type"="all","def"=0,
				"valmap"="planetmode_valmap",
				"set"="set_planetmode","params"=["lcdnum"=0]]
	$.options[n++] = ["name"="PadMode#2","type"="all","def"=0,
				"valmap"="planetmode_valmap",
				"set"="set_planetmode","params"=["lcdnum"=1]]

	# all-lcd values
	$.options[n++] = ["name"="Graphics","type"="graphic","def"=0,
				"valmap"="preset_valmap","save"=0]
	$.options[n++] = ["name"="AlphaAll","type"="graphic","def"=65]
	$.options[n++] = ["name"="AlphaAtt","type"="graphic","def"=127]
	$.options[n++] = ["name"="Decay","type"="graphic","def"=31]
	$.options[n++] = ["name"="Zoom","type"="graphic","def"=20]
	$.options[n++] = ["name"="Planets","type"="graphic","def"=32]
	$.options[n++] = ["name"="Gravity","type"="graphic","def"=27]
	$.options[n++] = ["name"="GravLimit","type"="graphic"]
	$.options[n++] = ["name"="Mass","type"="graphic"]
	$.options[n++] = ["name"="Speed","type"="graphic"]
	$.options[n++] = ["name"="Time","type"="graphic"]
	$.options[n++] = ["name"="Centerforce","type"="graphic","def"=10]
	$.options[n++] = ["name"="CollAlpha","type"="graphic"]
	$.options[n++] = ["name"="CollFade","type"="graphic"]
	$.options[n++] = ["name"="CollDist","type"="graphic","def"=10]
	$.options[n++] = ["name"="CollSize","type"="graphic","def"=16]
	$.options[n++] = ["name"="CollSpeed","type"="graphic"]
	$.options[n++] = ["name"="CollHue","type"="graphic"]
	$.options[n++] = ["name"="CollTime","type"="graphic"]
	$.options[n++] = ["name"="ConnAlpha","type"="graphic","def"=127]
	$.options[n++] = ["name"="ColorCyc","type"="graphic","def"=5]
	$.options[n++] = ["name"="ColorCycA","type"="graphic","def"=0]
	$.options[n++] = ["name"="ColorCycC","type"="graphic","def"=20]
	$.options[n++] = ["name"="MaxVel","type"="graphic","def"=0]

	# music values
	$.options[n++] = ["name"="Music","type"="music","def"=0,
				"valmap"="preset_valmap","save"=0]
	$.options[n++] = ["name"="NoteDur","type"="music","def"=0]
	$.options[n++] = ["name"="NoteFreq","type"="music","def"=55]
	$.options[n++] = ["name"="DownQnt","type"="music","def"=49]
	$.options[n++] = ["name"="RepQnt","type"="music","def"=68]
	$.options[n++] = ["name"="CollQnt","type"="music","def"=34]
	$.options[n++] = ["name"="CollVel","type"="music","def"=63]
	$.options[n++] = ["name"="Chordize","type"="music","def"=0,"valmap"="onoff_valmap"]
	# $.options[n++] = ["name"="Looping","type"="music","def"=0,"valmap"="onoff_valmap"]
	$.options[n++] = ["name"="LoopNotes","type"="music","def"=64]
	$.options[n++] = ["name"="ThruMode","type"="music","def"=0]
	$.options[n++] = ["name"="looprecmode","type"="music","def"=0]
	$.options[n++] = ["name"="loopxposemode","type"="music","def"=0]
	$.options[n++] = ["name"="realxposemode","type"="music","def"=0]
	$.options[n++] = ["name"="grabmode","type"="music","def"=0]
	$.options[n++] = ["name"="NoteVol","type"="music","def"=80]
	$.options[n++] = ["name"="ProxVel","type"="music","def"=110]
	$.options[n++] = ["name"="Transpose","type"="music","def"=63,
				"set"="set_transpose",
				"valmap"="transpose_valmap"]
	$.options[n++] = ["name"="SeqLeng","type"="music","def"=16,
				"set"="set_seqleng"]
	$.options[n++] = ["name"="Sequence","type"="music","def"=64,
				"valmap"="autotrans_valmap",
				"set"="set_sequence"]
	$.options[n++] = ["name"="Sound#1","type"="music","def"=15,
				"valmap"="sound_valmap",
				"set"="set_sound","params"=["lcdnum"=0]]
	$.options[n++] = ["name"="Sound#2","type"="music","def"=15,
				"valmap"="sound_valmap",
				"set"="set_sound","params"=["lcdnum"=1]]
	$.options[n++] = ["name"="Looping#1","type"="music","def"=127,
				"valmap"="onoff_valmap",
				"set"="set_looping","params"=["lcdnum"=0]]
	$.options[n++] = ["name"="Looping#2","type"="music","def"=127,
				"valmap"="onoff_valmap",
				"set"="set_looping","params"=["lcdnum"=1]]
	$.options[n++] = ["name"="CollSnd#1","type"="music","def"=60,
				"valmap"="sound_valmap",
				"set"="set_collsound","params"=["lcdnum"=0]]
	$.options[n++] = ["name"="CollSnd#2","type"="music","def"=71,
				"valmap"="sound_valmap",
				"set"="set_collsound","params"=["lcdnum"=1]]
	# $.options[n++] = ["name"="NoteSrc#1","type"="music","def"=0,
	# 			"valmap"="notesrc_valmap",
	# 			"set"="set_notesrc","params"=["lcdnum"=0]]
	# $.options[n++] = ["name"="NoteSrc#2","type"="music","def"=0,
	# 			"valmap"="notesrc_valmap",
	# 			"set"="set_notesrc","params"=["lcdnum"=1]]

	$.options[n++] = ["name"="LoopFade","type"="music",
				"valmap"="loopfade_valmap","def"=50]

	$.options[n++] = ["name"="Fx","type"="music",
				"valmap"="fx_valmap","def"=120,
				"set"="set_fx"]

	# global values
	$.options[n++] = ["name"="Global","type"="all","def"=0,
				"valmap"="preset_valmap","save"=0]

	$.sortarray($.options)
	# print("SORTED OPTIONS = ",$.options)

	$.sound = [0=0,1=0]
	$.collsound = [0=0,1=0]

	# $.notesrc = [0="Collision",0="Collision"]
	$.planetmode = [0="Planetst",0="Planetst"]

	$.reset_first_knob_value()

	$.values = []
	$.values_reported = []
	$.values_source = []
	for ( n in $.options ) {
		if ( $.options[n]["type"] == "graphic" && ! ("dest" in $.options[n]) ) {
			$.options[n]["dest"] = "default"
		}
		nm = $.options[n]["name"]
		if ( "def" in $.options[n] ) {
			$.values[nm] = $.options[n]["def"]
		} else {
			# $.values[nm] = rand(128)
			$.values[nm] = 63
		}
		$.values_reported[nm] = $.values[nm]
		$.values_source[nm] = "default"
	}

	$.controlsG = []
	$.controlsM = []
	$.controlsA = []
	for ( lcdnum=0; lcdnum<$.lcds; lcdnum++ ) {
		$.controlsG[lcdnum] = []
		$.controlsM[lcdnum] = []
		$.controlsA[lcdnum] = []
	}

	$.items = []
	for ( lcdnum=0; lcdnum<$.lcds; lcdnum++ ) {
		$.items[lcdnum] = [
			"controlG"=$.controlsG[lcdnum],
			"controlM"=$.controlsM[lcdnum],
			"controlA"=$.controlsA[lcdnum]
			]
	}

	$.lcd_open()

	$.lcd_label = []
	$.lcd_params = []
	for ( lcdnum=0; lcdnum<$.lcds; lcdnum++ ) {
		$.lcd_label[lcdnum] = []
		$.lcd_params[lcdnum] = []
	}

	$.label_tid = []

	$.finger2osc = ["fingerup"="/touchup","fingerdown"="/touchdown","fingerdrag"="/touchdrag"]
	$.oscclients = []
	$.oscf = open(string(Osclisten)+"@127.0.0.1","rA","osc_listen")
	if ( $.oscf < 0 ) {
		print("Unable to listen on ",Osclisten," !?")
		$.osctid = -1
	} else {
		$.osctid = task $.osctask()
	}

	# $.send_all_values()

	$.reset()

	task $.show_initial_messages()
}

method reset_first_knob_value() {
	$.first_knob_value = []
	for ( n=0; n<8; n++ ) {
		$.first_knob_value[n] = -1
	}
}

method oldcheckit(s) {
	lcdnum = 0
	g = $.controlsG[lcdnum]
	if ( ! (1 in g) ) {
		return()
	}
	if ( $.controlsG[lcdnum][1]["name"] == "Graphics" ) {
		print("HEY!!!!!!!!! controlsG changed to Graphics at ",s)
	} else {
		print("controlsG okay at ",s)
	}
}

method default_control_values(type) {

	if ( nargs() < 1 ) 
		type = "all"

	print("SETTING DEFAULT VALUES type=",type)
	for ( n in $.options ) {
		nm = $.options[n]["name"]
		t = $.options[n]["type"]
		if ( ! ( type == "all" || type == "" || type == t ) ) {
			continue
		}
		if ( "save" in $.options[n] ) {
			print("Ignoring nm=",nm,"  in default_control_values")
			continue
		}
		if ( "def" in $.options[n] ) {
			v = $.options[n]["def"]
		} else {
			v = 63
		}
		# print("BEFORE SETTING DEFAULT VALUE OF option ",nm," v=",v," val=",$.values[nm])
		$.change_value($.options[n],v,"default",1)
		# print("DEFAULT VALUE OF option ",nm," v=",v," val=",$.values[nm])
	}
}

method num_presets(t) {
	list = lsdir($.dir)
	n = 0
	expr = t + "_.*.fpp"
	for ( nm in list ) {
		if ( nm ~~ expr ) {
			n++
		}
	}
	# print("num_presets t=",t," n=",n)
	return(n)
}
method cleanvideo() {
	print("CLEANVIDEO!")
	$.change_value_byname("FF1Type",0,"cleanvideo")
	$.change_value_byname("FF2Type",0,"cleanvideo")
}

method init_controlsG(lcdnum) {
	lock($)
	# Keep $.controls around, so $.items values don't change
	for ( n in $.controlsG[lcdnum] ) {
		delete $.controlsG[lcdnum][n]
	}

	n = 0
	print("init_controlsG lcdnum=",lcdnum)
	if ( lcdnum == 1 ) {
		$.controlsG[lcdnum][n++] = $.find_option("")
	} else {
		$.controlsG[lcdnum][n++] = $.find_option("Graphics")
	}
	# $.controlsG[lcdnum][n++] = $.find_option("Planets")
	$.controlsG[lcdnum][n++] = $.find_option("ColorCycA")
	$.controlsG[lcdnum][n++] = $.find_option("Decay")
	$.controlsG[lcdnum][n++] = $.find_option("Gravity")

	if ( lcdnum == 1 ) {
		$.controlsG[lcdnum][n++] = $.find_option("")
	} else {
		$.controlsG[lcdnum][n++] = $.find_option("Music")
	}
	$.controlsG[lcdnum][n++] = $.find_option("Looping#"+string(lcdnum+1))
	$.controlsG[lcdnum][n++] = $.find_option("Sound#"+string(lcdnum+1))
	$.controlsG[lcdnum][n++] = $.find_option("CollSnd#"+string(lcdnum+1))
	# $.controlsG[lcdnum][n++] = $.find_option("ColorCycA")
	# $.controlsG[lcdnum][n++] = $.find_option("Color#"+string(lcdnum+1))

	if ( $.expert_mode ) {
		$.controlsG[lcdnum][n++] = $.find_option("Centerforce")
		$.controlsG[lcdnum][n++] = $.find_option("CollDist")
		$.controlsG[lcdnum][n++] = $.find_option("Time")
		$.controlsG[lcdnum][n++] = $.find_option("Graphics")
		$.controlsG[lcdnum][n++] = $.find_option("ColorCyc")
		$.controlsG[lcdnum][n++] = $.find_option("Alpha#"+string(lcdnum+1))
		$.controlsG[lcdnum][n++] = $.find_option("Size#"+string(lcdnum+1))
		$.controlsG[lcdnum][n++] = $.find_option("Zoom")

		$.controlsG[lcdnum][n++] = $.find_option("Graphics")
		$.controlsG[lcdnum][n++] = $.find_option("AlphaAll")
		$.controlsG[lcdnum][n++] = $.find_option("MaxVel")
		$.controlsG[lcdnum][n++] = $.find_option("GravLimit")
		$.controlsG[lcdnum][n++] = $.find_option("Width#"+string(lcdnum+1))
		$.controlsG[lcdnum][n++] = $.find_option("AlphaAtt")
		$.controlsG[lcdnum][n++] = $.find_option("Mass")
		$.controlsG[lcdnum][n++] = $.find_option("CollFade")

		$.controlsG[lcdnum][n++] = $.find_option("Graphics")
		$.controlsG[lcdnum][n++] = $.find_option("CollAlpha")
		$.controlsG[lcdnum][n++] = $.find_option("CollSize")
		$.controlsG[lcdnum][n++] = $.find_option("CollSpeed")
	}
	unlock($)
}

method init_controlsA(lcdnum) {
	# Keep $.controls around, so $.items values don't change
	for ( n in $.controlsA[lcdnum] ) {
		delete $.controlsA[lcdnum][n]
	}

	n = 0
	$.controlsA[lcdnum][n++] = $.find_option("Global")
	# $.controlsA[lcdnum][n++] = $.find_option("PadMode#"+string(lcdnum+1))
}

method init_controlsM(lcdnum) {
	# Keep $.controls around, so $.items values don't change
	for ( n in $.controlsM[lcdnum] ) {
		delete $.controlsM[lcdnum][n]
	}
	# $.controlsM[lcdnum][n++] = $.find_option("NoteSrc#"+string(lcdnum+1))

	n = 0
	$.controlsM[lcdnum][n++] = $.find_option("Music")
	$.controlsM[lcdnum][n++] = $.find_option("PadMode#"+string(lcdnum+1))
	$.controlsM[lcdnum][n++] = $.find_option("Sound#"+string(lcdnum+1))
	$.controlsM[lcdnum][n++] = $.find_option("CollSnd#"+string(lcdnum+1))

	$.controlsM[lcdnum][n++] = $.find_option("Looping#"+string(lcdnum+1))
	$.controlsM[lcdnum][n++] = $.find_option("LoopFade")
	$.controlsM[lcdnum][n++] = $.find_option("Sequence")
	$.controlsM[lcdnum][n++] = $.find_option("Chordize")

	if ( $.expert_mode ) {
		$.controlsM[lcdnum][n++] = $.find_option("Music")
		$.controlsM[lcdnum][n++] = $.find_option("SeqLeng")
		$.controlsM[lcdnum][n++] = $.find_option("NoteVol")
		$.controlsM[lcdnum][n++] = $.find_option("NoteDur")
		$.controlsM[lcdnum][n++] = $.find_option("NoteFreq")
		$.controlsM[lcdnum][n++] = $.find_option("DownQnt")
		$.controlsM[lcdnum][n++] = $.find_option("RepQnt")
		$.controlsM[lcdnum][n++] = $.find_option("CollDist")

		$.controlsM[lcdnum][n++] = $.find_option("Music")
		$.controlsM[lcdnum][n++] = $.find_option("CollQnt")
		$.controlsM[lcdnum][n++] = $.find_option("CollVel")
		$.controlsM[lcdnum][n++] = $.find_option("LoopNotes")
		$.controlsM[lcdnum][n++] = $.find_option("Fx")
		$.controlsM[lcdnum][n++] = $.find_option("ProxVel")
	}

}

method init_fx() {
	$.fx = [
		# BJ RingMod
		14=["fx"=1,"param"="Mode"],
		15=["fx"=1,"param"="Frequency"],
		16=["fx"=1,"param"="Depth"],
		17=["fx"=1,"param"="Osc"],
		18=["fx"=1,"param"="LFOFreq"],
		19=["fx"=1,"param"="LFO"],
		20=["fx"=1,"param"="LFOto2"],
		21=["fx"=1,"param"="LFOrtrg"],

		# Scrubby
		23=["fx"=2,"param"="Mode"],
		24=["fx"=2,"param"="SeekRange"],
		25=["fx"=2,"param"="Freeze"],
		26=["fx"=2,"param"="SeekRate"],
		27=["fx"=2,"param"="SeekRateRandMin"],
		28=["fx"=2,"param"="TempoSync"],
		29=["fx"=2,"param"="SeekDuration"],
		30=["fx"=2,"param"="SeekDurRandMin"],
		31=["fx"=2,"param"="Speeds"],
		32=["fx"=2,"param"="Stereo"],
		33=["fx"=2,"param"="PitchConstraint"],
		34=["fx"=2,"param"="Semi0"],
		35=["fx"=2,"param"="Semi1"],
		36=["fx"=2,"param"="Semi2"],
		37=["fx"=2,"param"="Semi3"],
		38=["fx"=2,"param"="Semi4"],
		39=["fx"=2,"param"="Semi5"],
		40=["fx"=2,"param"="Semi6"],
		41=["fx"=2,"param"="Semi7"],
		42=["fx"=2,"param"="Semi8"],
		43=["fx"=2,"param"="Semi9"],
		44=["fx"=2,"param"="Semi10"],
		45=["fx"=2,"param"="Semi11"],
		46=["fx"=2,"param"="OctaveMin"],
		47=["fx"=2,"param"="OctaveMax"],
		48=["fx"=2,"param"="Tempo"],
		49=["fx"=2,"param"="PreDelay"],

		# Transverb
		72=["fx"=3,"param"="Mode"],
		73=["fx"=3,"param"="buffersize"],
		74=["fx"=3,"param"="1:speed"],
		75=["fx"=3,"param"="1:feedback"],
		76=["fx"=3,"param"="1:dist"],
		77=["fx"=3,"param"="2:speed"],
		78=["fx"=3,"param"="2:feedback"],
		79=["fx"=3,"param"="2:dist"],
		80=["fx"=3,"param"="drymix"],
		81=["fx"=3,"param"="1:mix"],
		82=["fx"=3,"param"="2:mix"],
		83=["fx"=3,"param"="quality"],
		84=["fx"=3,"param"="TOMSOUND"],
		85=["fx"=3,"param"="1:speedmode"],
		86=["fx"=3,"param"="2:speedmode"]

	]
}

method sortarray(arr) {
	sz = sizeof(arr)
	for ( n=0; n<(sz-1); n++ ) {
		for ( k=n+1; k<sz; k++ ) {
			if ( arr[n]["name"] > arr[k]["name"] ) {
				t = arr[n]
				arr[n] = arr[k]
				arr[k] = t
			}
		}
	}
}

method find_option(nm) {
	for ( n in $.options ) {
		if ( $.options[n]["name"] == nm )
			return($.options[n])
	}
	return([])
}

method find_command(nm) {
	for ( n in $.commands ) {
		if ( $.commands[n]["name"] == nm )
			return($.commands[n])
	}
	return([])
}

method find_option_byval(val) {
	sz = sizeof($.options)
	n = integer((val/128.0) * sz) % sz
	return($.options[n])
}

method find_command_byval(val) {
	sz = sizeof($.commands)
	n = integer((val/128.0) * sz) % sz
	return($.commands[n])
}

method kill_redisplays() {
	# Kill any pending label redisplays
	for ( nm in $.label_tid ) {
		kill($.label_tid[nm])
		delete $.label_tid[nm]
	}
}

method lcd_setpage(lcdnum,mode) {
	$.kill_redisplays()

	$.lcd_mode[lcdnum] = mode

	print("SETPAGE lcdnum=",lcdnum," mode=",mode)
	$.reset_first_knob_value()
	$.lcd_setpage_items(lcdnum,$.offset[lcdnum][mode],$.items[lcdnum][mode])

	$.lcd_refresh(lcdnum)
}

method lcd_setpage_items(lcdnum,offset,items) {
	# print("lcd_setpage_items, offset=",offset," items=",items)
	mode = $.lcd_mode[lcdnum]
	for ( n=0; n<8; n++ ) {
		row = integer(n % 4)
		col = integer(n / 4)
		ci = offset+n
		$.lcd_set_item(lcdnum,row,col,items,ci)
	}
}

method lcd_set_item(lcdnum,row,col,items,ci) {
	# print("LCD_SET_ITEM row=",row," col=",col," ci=",ci," sizeof(items)=",sizeof(items))
	if ( ci >= sizeof(items) ) {
		f = ""
		nm = ""
		params = []
		# print("   Setting name to blank")
	} else {
		# print("SET_ITEM ci = ",ci)
		c = items[ci]
		# print("    SET_ITEM c = ",c)
		nm = c["name"]
		if ( "params" in c )
			params = c["params"]
		else
			params = []
	}
	if ( col < 0 )
		col = 0
	ci = row+4*col
	$.lcd_label[lcdnum][ci] = nm
	$.lcd_params[lcdnum][ci] = params
}

method mappedvalue(it) {
	nm = it["name"]
	v = $.get_value(nm)
	# print("mappedvalue it=",it," nm=",nm," get_value=",v)
	if ( "valmap" in it ) {
		# print("USING valmap = ",it["valmap"])
		v = $.(it["valmap"])(v,it)
	}
	return(v)
}

method lcd_show_control_value(lcdnum,it,row,col,tmout) {
	lab = $.lcd_label[lcdnum]
	nm = lab[ row + col*4 ]
	nnm = $.omit_lcdnum(nm)
	v = $.mappedvalue(it)
	# print("show_control_value v=",v)
	if ( col == 0 ) {
		if ( typeof(v) == "integer" )
			sval = sprintf("%-9d",v)
		else
			sval = sprintf("%-9s",v)
		snm = sprintf("%-9s",nnm)
		valpos = 0
		nmpos = 0
	} else {
		if ( typeof(v) == "integer" )
			sval = sprintf("%9d",v)
		else
			sval = sprintf("%9s",v)
		snm = sprintf("%9s",nnm)
		valpos = 11
		nmpos = 11
	}
	$.lcd_write(lcdnum,sval,row,valpos)

	# wait for a bit before redisplaying the name again
	if ( tmout > 0 ) {
		sleeptill(Now+tmout)
		$.lcd_write(lcdnum,snm,row,nmpos)
	}
}

method is_per_lcd_name(nm) {
	lng = sizeof(nm)
	return(substr(nm,lng-1,1) == "#")
}

method omit_lcdnum(nm) {
	# If the name contains #1 or #2 (the LCD number),
	# eliminate it but leave the "#"

	# Try without
	# lng = sizeof(nm)
	# if ( substr(nm,lng-1,1) == "#" ) {
	#	nm = substr(nm,1,lng-1)
	# }
	return(nm)
}
method lcd_show_control_name(lcdnum,it,row,col) {
	lab = $.lcd_label[lcdnum]
	nm = lab[row+4*col]
	if ( col == 0 ) {
		snm = sprintf("%-9s",$.limit9($.omit_lcdnum(nm)))
		nmpos = 0
	} else {
		snm = sprintf("%9s",$.limit9($.omit_lcdnum(nm)))
		nmpos = 11
	}
	$.lcd_write(lcdnum,snm,row,nmpos)
}

method lcd_show_action_name(lcdnum,row) {
	print("show_action_name row=",row)
	lab = $.lcd_label[lcdnum]
	$.lcd_write_action(lcdnum,row)
}

method lcd_show_option_value(lcdnum,it,row) {
	nm = it["name"]
	v = $.mappedvalue(it)
	if ( typeof(v) == "integer" ) {
		s = sprintf("%-9s = %-8d",nm,v)
	} else {
		s = sprintf("%-9s = %-8s",nm,v)
	}
	$.lcd_write(lcdnum,s,row,0)
}

method limit9(s) {
	if ( sizeof(s) > 9 ) {
		s = substr(s,1,9)
	}
	return(s)
}

method lcd_write_8labels(lcdnum) {
	lab = $.lcd_label[lcdnum]
	for ( r=0; r<=3; r++ ) {
		s = sprintf("%-9s||%9s",
			$.limit9($.omit_lcdnum(lab[r])),
			$.limit9($.omit_lcdnum(lab[r+4])))
		$.lcd_write(lcdnum,s,r,0)
	}
}

method lcd_write_action(lcdnum,r) {
	lab = $.lcd_label[lcdnum]
	s = sprintf("%-13s",lab[r])
	print("WRITE_ACTION r=",r," s=",s)
	$.lcd_write(lcdnum,s,r,6)
}

method lcd_refresh(lcdnum) {
	$.lcd_clear(lcdnum)
	mode = $.lcd_mode[lcdnum]
	if ( mode ~~ "control.*" ) {
		$.lcd_write_8labels(lcdnum)
	} else {
		print("Not doing anything in lcd_refresh for mode=",mode)
	}
	# print("LCDNUM=",lcdnum," controlG=",$.controlsG[lcdnum])
}

method lcd_refresh_all() {
	for ( lcdnum=0; lcdnum < $.lcds; lcdnum++ ) {
		$.lcd_refresh(lcdnum)
	}
}

method lcd_open() {
	for ( lcdnum=0; lcdnum < $.lcds; lcdnum++ ) {
		$.lcd_backlight(lcdnum,1)
	}
}

method lcd_close() {
	# print("lcd_close begin")
	for ( lcdnum=0; lcdnum < $.lcds; lcdnum++ ) {
		$.lcd_clear(lcdnum,0)
		$.lcd_backlight(lcdnum,0)
	}
	# print("lcd_close end")
}

method lcd_write(lcdnum,msg,row,col) {
	if ( LcdDebug )
		print("lcd_write msg=",msg," row/col=",row," ",col)
	mdep("lcd","write",lcdnum,msg,row,col)
}

method lcd_error(lcdnum,msg) {
	mdep("lcd","write",lcdnum,msg,0,0)
}

method lcd_backlight(lcdnum,onoff) {
	mdep("lcd","backlight",lcdnum,onoff)
}

method lcd_clear(lcdnum,sleepy) {
	mdep("lcd","clear",lcdnum)
	if ( nargs() == 1 || sleepy == 1 ) {
		sleeptill(Now+4)   # HMMMM... why is this needed?
	}
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

method get_loopnotelimit() {
	return($.LoopNotes)
}
method get_notedur() {
	return ($.NoteDur * 4b / 127)
}

method get_notevol() {
	return ($.NoteVol)
}

method fingernote(ft,row,col,prox,fid,x,y,lcdnum) {
	p = 'a'
	p.time = 0
	# print("x,y=",x,y)
	p.pitch = (x + y) * 64
	p = $.common_note(p)
	if ( $.ProxVel > 0 ) {
		newvol = 127 * ($.ProxVel/127.0) * $.map_prox(prox)
		if ( newvol > p.vol ) {
			p.vol = newvol
			print("ProxVel=",$.ProxVel," new p.vol=",p.vol)
		}
	}
	if ( $.NoteDur == 0 ) {
		p.type = NOTEON
	} else {
		p.dur = $.get_notedur()
	}
	p.chan = $.sound[lcdnum]+1
	return(p)
}

method collision_note(scaledx,scaledy,chan1,chan2,radius1,radius2) {
	p = 'a'
	p.pitch = 20 + (scaledx + 0.5) * 90
	p = $.common_note(p)
	newvol = p.vol * ($.CollVel/63.0)
	if ( newvol > p.vol )
		p.vol = newvol
	# print("COLLISION p=",p)
	p.type = NOTE
	if ( $.NoteDur == 0 ) {
		p.dur = 2b
	} else {
		p.dur = 2 * $.get_notedur()
	}
	# print("collision dur = ",p.dur)
	if ( radius1 >= radius2 ) {
		lcdnum = chan1-1
		# print("Collision using collsound of chan1=",chan1," lcdnum=",lcdnum)
		p.chan = $.collsound[lcdnum]+1
	} else {
		lcdnum = chan2-1
		# print("Collision using collsound of chan2=",chan2," lcdnum=",lcdnum)
		p.chan = $.collsound[lcdnum]+1
	}
	return(p)
}

method common_note_loop(p,chordize) {
	p = scadjust(p,$.curr_scale)
	p.pitch += $.Transpose
	return(p)
}

method common_note(p,chordize) {
	if ( nargs() < 2 )
		chordize = 1
	p.vol = $.NoteVol
	# print("common_note p.vol = ",p.vol)
	p = scadjust(p,$.curr_scale)
	p.pitch += $.Transpose
	if ( $.ison($.Chordize) && chordize != 0 ) {
		p = $.make_chord(p)
	}
	return(p)
}

method autotrans_valmap(v,it) {
	# print("autotrans valmap, sizeof autochanges=",sizeof($.AutoChanges))
	return((v*sizeof($.AutoChanges))/128)
}
method check_autotranspose() {
	atv = $.autotrans_valmap($.Sequence)
	tl = ( $.SeqLeng * 64b ) / 127
	if ( $.AutoChangeForce == 1 || ($.AutoLastChange+tl) < Now ) {
		# print("Looking at AutoChanges")
		$.AutoChangeForce = 0
		$.AutoTPos++
		if ( ! (atv in $.AutoChanges) ) {
			print("Hey, atv=",atv," not in AutoChanges, Sequence=",$.Sequence)
			return()
		}
		changes = $.AutoChanges[atv]
		# print("atv = ",atv," changes=",changes)
		if ( $.AutoTPos >= sizeof(changes) ) {
			$.AutoTPos = 0
		}
		# print("atv=",atv," changes=",changes,"  TPos=",$.AutoTPos)
		$.AutoLastChange = Now
		$.Transpose = changes[$.AutoTPos]
		# print("AUTO TRANSPOSE is now ",$.Transpose)
	}
}

method osctask() {
	while ( (d=get($.oscf)) != Eof ) {

		if ( $.initdone == 0 ) {
			print("Ignoring osc messages till initdone...")
			continue
		}

		# print("osctask got d=",d)
		addr = d[0]
		if ( addr == "/registerclient" ) {
			$.registerclient(d[1],d[2])
		} else if ( addr == "/unregisterclient" ) {
			$.registerclient(d[1],d[2])
		} else if ( addr == "/collision" ) {
			scaledx = d[5]
			scaledy = d[6]
			chan1 = d[7]
			chan2 = d[8]
			radius1 = d[9]
			radius2 = d[10]
			# print("/COLLISION chan1=",chan1," chan2=",chan2)
			p = $.collision_note(scaledx,scaledy,chan1,chan2,radius1,radius2)
			q = $.val2quant($.CollQnt)
			tm = nextquant(Now,q)
			$.realtime(p,tm)
		} else {
			print("osctask got d=",d)
		}
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
	# $.reset()
}

method sendneural(msg) {
	if ( $.fneural >= 0 ) {
		print("SENDING to nueral, msg=",msg)
		mdep("osc","send",$.fneural,msg)
	} else {
		print("No neural connection!")
	}
}

method sendosc(msg) {
	if ( DebugOsc ) {
		# print("sendosc msg=",msg)
		# s = sprintf("OSC %s",string(msg))
		# s = substr(s,1,20)

		# $.lcd_write(0,string(msg[0]),0,0)
		# $.lcd_write(0,string(msg[1]),1,0)
		# $.lcd_write(0,string(msg[2]),2,0)
		# $.lcd_write(0,string(msg[3]),3,0)
	}
	for ( f in $.oscclients ) {
		if ( DebugOsc > 1 )
			print("Sending msg=",msg," to oscclient f=",f)
		mdep("osc","send",f,msg)

		# m2 = [0="/setimagedecay",1=0.9]
		# if ( DebugOsc )
		# 	print("Sending m2=",m2," to oscclient f=",f)
		# mdep("osc","send",f,m2)
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
	c = g["control"]
	if ( c == "musicvalue" ) {
		return(0)
	}
	if ( (c == "toggle" && g["row"] > 2 ) ||
		(c == "slider" && g["row"] > 0 ) ) {
		return(1)
	} else {
		return(0)
	}
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
}

method waittilldone {
	wait($.constid)
	$.lcd_close()
}

method realano() {
	# print("REALTIME H realano")
	$.realtime(ano(),Now)
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

method start() { 

	nt = sizeof($.ergox_bayareameetup)
	for ( n=0; n<nt; n++ ) {
		$.ergox_bayareameetup[n].start()
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

	$.clocktid = task $.osc_clock()
}

method osc_clock() {
	tm = nextquant(Now,1b/2)
	dt = 1b/16
	while (1) {
		$.check_autotranspose()
		sleeptill(tm)
		m2 = [0="/clock",1=tm]
		$.sendosc(m2)
		tm += dt
	}
}

method stop {
	if ( gesturedevices() != 0 ) {
		gestureunnotify($)
	}
	$.stopme = 1
	kill($.miditid)
	kill($.clocktid)
	kill($.constid)
	kill($.osctid)
	print("Closing oscf=",$.oscf)
	close($.oscf)
	for ( f in $.oscclients ) {
		close(f)
	}

	nt = sizeof($.fifos)
	for ( n=0; n<nt; n++ ) {
		close($.fifos[n])
		t = $.ergox_bayareameetup[n]
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
	global ergox_bayareameetup_resetconsole
	onexit(ergox_bayareameetup_resetconsole,$)
	while ( $.quit == 0 && (c=get($.consf)) != Eof ) {
		# print("GOT c=",c," from console")
		$.handle_console(c)
	}
}

method midi_task(f) {
	global ergox_bayareameetup_midi_restart
	onexit(ergox_bayareameetup_midi_restart,$)
	while ( (c=get(f)) != Eof ) {
		$.handle_midi(c)
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
	# print("gotgesturerc rc=",r,c," prox=",prox)
	if ( ! (d in GestureDevMap) && t == "fingerup" ) {
		n = sizeof(GestureDevMap)
		GestureDevMap[d] = n
		# print("GESTUREDEVMAP of d=",d," is now ",n)
	}
	if ( $.initdone == 0 ) {
		# print("Waiting for all pads to be touched...")
		return()
	}
	
	d = GestureDevMap[d]
	arr = ["type"=t,"row"=r,"col"=c,"prox"=prox,"device"=d,"finger"=f]
	# print("got arr=",arr)

	$.handle_finger(t,r,c,prox,d,f,rawx,rawy)
}

method tosalvation(p) {
	if ( SalvationOutput > 0 ) {
		p.port = SalvationOutput
		# print("To Salvation: ",p)
		# print("REALTIME J p=",p)
		realtime(p)
	}
}

method putline(f,s) {
	put(f,s)
	put(f,"\n")
}

method ison(v) {
	if ( v > 63 )
		return(1)
	else
		return(0)
}

method chordchanged() {
	p = $.chord
	p.type = NOTE
	p.time = 0
	$.chord = p
	if ( $.ison($.Chordize) ) {
		print("NOT setting scale, since Chordize is on")
		return()
	}
	if ( $.get_value("realxposemode") ) {
		p = ($.chord) % 1
		Offsetpitch = p.pitch - 60
		print("Offsetpitch = ",Offsetpitch)
		return()
	}
	sc = completescalephrase($.chord)
	$.curr_scale = sc
	for ( n in $.ergox_bayareameetup ) {
		t = $.ergox_bayareameetup[n]
		t.rescale_from_scale(sc)
	}
}

method handle_midi_chord(c)
{
	if ( c.type == NOTEOFF ) {
		if ( Current == '' ) {
			if ( sizeof($.nextchord) > 9 ) {
				print("KILLING ALL LOOPS")
				for ( n in $.ergox_bayareameetup ) {
					t = $.ergox_bayareameetup[n]
					t.killchan()
				}
			} else if ( sizeof($.nextchord) > 5 ) {
				print("KILLING current pad loop")
				t = $.ergox_bayareameetup[$.currpad]
				t.killchan()
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

# method notesrc_valmap(v,it) {
# 	if ( v < 64 ) 
# 		return("Collision")
# 	return("Pad")
# 	
# }
# method set_notesrc(val,params) {
# 	lcdnum = params["lcdnum"]
# 	$.notesrc[lcdnum] = $.notesrc_valmap(val)
# 	print("NOTESRC = ",$.notesrc[lcdnum])
# 	# force planet mode to None
# 	# $.change_value_byname("PadMode#"+string(lcdnum+1),127)
# }

method fx_valmap(v,it) {
	if ( v < 32 ) 
		return("None")
	if ( v < 64 ) 
		return("RingMod")
	if ( v < 96 ) 
		return("Scrubby")
	return("Transverb")
}

method set_fx(val,params) {
	s = $.fx_valmap(val)
	print("SET_FX s=",s," params=",params)
	$.fx_mode = s
	if ( s == "None" ) {
		$.fxdisableall()
	}

# 	} else if ( s == "RingMod" ) {
# 		$.change_value_byname("FxEnable1",127,"set_fx")
# 		$.change_value_byname("FxEnable2",0,"set_fx")
# 		$.change_value_byname("FxEnable3",0,"set_fx")
# 
# 		$.change_value_byname("FxPadX#1",15,"set_fx")
# 		$.change_value_byname("FxPadX#2",15,"set_fx")
# 		$.change_value_byname("FxPadY#1",16,"set_fx")
# 		$.change_value_byname("FxPadY#1",16,"set_fx")
# 
# 	} else if ( s == "Scrubby" ) {
# 		$.change_value_byname("FxEnable1",0,"set_fx")
# 		$.change_value_byname("FxEnable2",127,"set_fx")
# 		$.change_value_byname("FxEnable3",0,"set_fx")
# 
# 		$.change_value_byname("FxPadX#1",48,"set_fx")
# 		$.change_value_byname("FxPadX#2",48,"set_fx")
# 		$.change_value_byname("FxPadY#1",49,"set_fx")
# 		$.change_value_byname("FxPadY#1",49,"set_fx")
# 
# 	} else if ( s == "Transverb" ) {
# 		$.change_value_byname("FxEnable1",0,"set_fx")
# 		$.change_value_byname("FxEnable2",0,"set_fx")
# 		$.change_value_byname("FxEnable3",127,"set_fx")
# 
# 		$.change_value_byname("FxPadX#1",74,"set_fx")
# 		$.change_value_byname("FxPadX#2",74,"set_fx")
# 		$.change_value_byname("FxPadY#1",76,"set_fx")
# 		$.change_value_byname("FxPadY#1",76,"set_fx")
#	} else {
#		$.fxenableall()
#	}

}

method fxparam_valmap(v,it) {
	if ( v in $.fx ) {
		f = $.fx[v]
		s = string(f["fx"])+":"+f["param"]
		s = substr(s,1,9)
		return(s)
	}
	return("unknown")
}
method fxrandctrl(fxarr) {
	cnt = 0
	while (cnt<1000) {
		r = rand(128)
		if ( $.fxparam_valmap(r,[]) != "unknown" ) {
			s = $.fxparam_valmap(r)
			print("Random controller r=",r," = ",s)
			fxnum = integer(substr(s,1,1))
			fxarr[fxnum] = 1
			return(r)
		}
		cnt++
	}
	print("Unable to find value fxparam in fxrandctrl!?")
	return(0)
}
method fxdisableall() {
	$.do_fxenable(0)
}
method fxenableall() {
	print("FXENABLEALL!")
	$.do_fxenable(1)
}
method do_fxenable(val) {
	val = val * 127
	print("DO_FXENABLE !! val=",val)
	for ( fx=1; fx<=3; fx++ ) {
		# $.change_value_byname("FxEnable"+string(fx),val,"fxenable")
		$.realtime($.fxenable_phr(fx,val),Now)
	}
}
method fxenable_phr(fx,ison) {
	# print("fxenable_phr  fx=",fx," ison=",ison)
	ctrl = -1
	for ( i in $.fx ) {
		a = $.fx[i]
		if ( a["fx"] == fx && a["param"] == "Mode" ) {
			# print("Found mode at i=",i," a=",a)
			ctrl = i
			break
		}
	}
	if ( ctrl < 0 ) {
		print("Didn't find Mode for fx=",fx)
		return('')
	}
	# print("Found Mode for fx=",fx,"  ctrl=",ctrl)
	if ( ison ) {
		v = 0
	} else {
		v = 100
	}
	p = controller(16,ctrl,v)
	return(p)
}
method set_fxenable(val,params) {
	p = $.fxenable_phr(params["fx"],$.ison(val))
	# print("SET_FXENABLE val=",val," params=",params," p=",p)
	realtime(p)
}

method loopfade_valmap(v,it) {
	if ( v < 20 )
		return(0)
	if ( v < 40 )
		return(1)
	if ( v < 60 )
		return(2)
	if ( v < 80 )
		return(3)
	if ( v < 100 )
		return(4)
	return(5)
}
method get_loopfade() {
	return($.loopfade_valmap($.LoopFade))
}

method preset_valmap(v,it) {
	i = $.preset_info(v,it)
	return(i["label"])
}
method sound_valmap(v,it) {
	# values are 0 to 14
	n = integer(v/8)
	if ( n >= 15 )
		n = 14
	return($.sound_name[n])
	# return(14)
	# return("None")
}
method sound_valmap_channel(v,it) {
	# values are 0 to 15
	n = integer(v/8)
	if ( n < 15 )
		return(n)
	return(14)
	# return("None")
}
method preset_fname(v,it) {
	i = $.preset_info(v,it)
	if ( "fname" in i )
		return(i["fname"])
	return("")
}
method preset_info(v,it) {
	nm = it["name"]
	if ( nm == "Graphics" )
		pname = "graphic"
	else if ( nm == "Music" )
		pname = "music"
	else if ( nm == "Global" )
		pname = "all"
	sz = $.presets[pname]
	pnum = v * sz / 128
	info = ["label"=sprintf("Preset %d",pnum)]
	if ( sz > 0 ) {
		info["fname"] = sprintf("%s_%d.fpp",pname,pnum)
	}
	# print("preset_info sz=",sz," nm=",nm," info=",info)
	return(info)
}

method onoff_valmap(v) {
	if ( v < 64 ) {
		return("off")
	} else {
		return("on")
	}
}

method freeframetype_valmap(v) {
	sz = sizeof($.fftypes)
	from = 0
	for ( k=0; k<sz; k++ ) {
		to = $.fftypes[k]["toval"]
		if ( v < to ) {
			# print("map v=",v," name=",$.fftypes[k]["name"])
			return($.fftypes[k]["name"])
		}
		from = to
	}
	return("????")
}

method change_value_byname(nm,val,source) {
	if ( nargs() < 3 ) {
		error("Change_value_byname needs 3 args")
	}
	it = $.find_option(nm)
	if ( sizeof(it) == 0 ) {
		print("Hey, can't find option named ",nm)
		return()
	}
	return($.change_value(it,val,source))
}

method get_value(nm) {
	if ( ! (nm in $.values_reported) ) {
		print("Hey, nm=",nm," not in values_reported!")
		return(0)
	}
	return($.values_reported[nm])
}

method change_value(it,val,source,force,loadpreset) {

	if ( nargs() < 3 ) {
		error("Hey, change_value needs source!")
	}
	if ( nargs() < 4 )
		force = 0
	if ( nargs() < 5 )
		loadpreset = 0

	nm = it["name"]
	t = it["type"]

	currsrc = $.values_source[nm]
	# print("CHANGE_VALUE nm=",nm,"  source=",source,"  current valsrc=",currsrc)
	reported = $.values_reported[nm]
	$.values[nm] = val

	if ( currsrc != "knob" && typeof(source) == "integer" ) {
		knobnum = source
		# print("Hey, got a knob change to a non-knob value! knob=",knobnum,"  currsrc = ",currsrc)
		if ( $.first_knob_value[knobnum] < 0 ) {
			$.first_knob_value[knobnum] = val
			# print("FIRST knob value for knobnum=",knobnum," is ",val)
			return(0)
		}
		knobdiff = abs($.first_knob_value[knobnum] - val)
		if ( knobdiff > 2 ) {
			# print("KNOB CHANGED!! nm=",nm,"  val=",val)
			$.values_reported[nm] = val
			$.values_source[nm] = "knob"
		} else {
			# print("KNOB DIDN'T CHANGE ENOUGHT! nm=",nm,"  val=",val)
			return(0)
		}
	} else {
		if ( force!=0 || abs(reported-val) > 2 || val==0 || val==127 ) {
			# print("CHANGED nm=",nm,"  val=",val)
			$.values_reported[nm] = val
			if ( typeof(source) == "integer" )
				$.values_source[nm] = "knob"
			else
				$.values_source[nm] = source
		} else {
			# print("Value not changing by one or two: ",nm," v=",val," reported=",reported)
			return(0)
		}
	}

	if ( t == "graphic" ) {

		# print("Setting 'graphic' value of nm=",nm," to ",val)

		if ( it["dest"] == "ff" ) {
			pp = it["params"]
			# print("GRAPHIC FF, nm=",nm," pp=",pp)
			if ( "do" in pp ) {
				$.(pp["do"])()
			} else {
				p = controller(pp["chan"],pp["ctrl"],val)
				# print("Changed value, sending to salvation")
				$.tosalvation(p)
			}
			return(1)
		}

		$.graphic_map = [
			"Planets" = "/setmaxshapes",
			"Time" = "/settimefactor"
		]
		if ( nm == "ColorCycA" ) {
			m2 = [0="/set"+nm,1=(val/127.0)]
			$.sendosc(m2)
			nm = "ColorCyc"
			m2 = [0="/set"+nm,1=(val/127.0)]
			$.sendosc(m2)
		}
		else if ( nm == "Graphics" ) {
			fnm = $.preset_fname(val,it)
			if ( fnm != "" ) {
				$.default_control_values("graphic")
				$.load_values(fnm)
			} else {
				print("NO preset filename...")
			}
			print("GRAPHICS A it=",it)
		} else if ( nm == "Decay" ) {
			v = val / 127.0
			# if ( val > 63 ) {
			# 	dcy = 0.01 + 0.19 * ((val-64)/64.0)
			# } else {
			# 	dcy = 0.01 * (val/64.0)
			# }
			dcy = 1.0 - 0.50 * v * v * v
			# dcy = 1.0 - dcy
			m2 = [0="/setimagedecay",1=dcy]
			print("val=",val,"  DECAY = ",dcy)
			$.sendosc(m2)
		} else if ( nm in $.graphic_map ) {
			m2 = [0=$.graphic_map[nm],1=(val/127.0)]
			$.sendosc(m2)
		} else {
			m2 = [0="/set"+nm,1=(val/127.0)]
			$.sendosc(m2)
		}
	} else if ( t == "music" ) {
		if ( nm == "Music" ) {
			fnm = $.preset_fname(val,it)
			if ( fnm != "" ) {
				$.default_control_values("music")
				$.load_values(fnm)
			}
		} else {
			$.(nm) = val
			# print("Setting 'music' value of nm=",nm," to ",val)
			if ( "set" in it ) {
				if ( "params" in it ) {
					params = it["params"]
				} else {
					params = []
				}
				$.(it["set"])(val,params)
			} else {
				$.(nm) = val
			}
		}
	} else if ( t == "all" ) {
		if ( nm == "Global" ) {
			fnm = $.preset_fname(val,it)
			if ( fnm != "" ) {
				$.load_values(fnm)
			}
		} else {
			# print("Setting 'all' value of nm=",nm," to ",val)
			if ( "set" in it ) {
				if ( "params" in it ) {
					params = it["params"]
				} else {
					params = []
				}
				$.(it["set"])(val,params)
			} else {
				$.(nm) = val
			}
		}
	}
	return(1)
	
}

method shape_valmap(v) {
	if ( v < 32 )
		return("Outline")
	if ( v < 64 )
		return("Filled")
	if ( v < 96 )
		return("Line")
	return("Rect")
}

method planetmode_valmap(v,it) {
	# print("planetmode change, v=",v)
	if ( v < 32 ) 
		return("Planets")
	if ( v < 64 ) 
		return("Notes")
	if ( v < 96 ) 
		return("Fx")
	return("Neural")

	# if ( v < 96 ) 
	# 	return("Attract")
	# return("Repel")
}

method set_randvideo(val,params) {
	print("SET_RANDVIDEO! val=",val," params=",params)
}

method set_planetmode(val,params) {
	oscmap = [
		"Planets"="draw",
		"Attract"="attract",
		"Repel"="repel",
		"Notes"="",
		"Fx"="",
		"Neural"=""
		]

	lcdnum = params["lcdnum"]
	oldmode = oscmap[$.planetmode[lcdnum]]
	$.planetmode[lcdnum] = $.planetmode_valmap(val)
	# print("SET_PLANETMODE! val=",val," params=",params," planetmode=", $.planetmode[lcdnum])

	newmode = oscmap[$.planetmode[lcdnum]]
	if ( newmode != oldmode ) {
		print("FXDISABLEALL")
		$.fxdisableall()
	}

	# # pad behaviour is either notes or planets, mutually-exclusive
	# nm = "NoteSrc#" + string(lcdnum+1)
	# if ( newmode != "" ) {
	# 	$.notesrc[lcdnum] = "Collision"
	# 	$.values[nm] = 0
	# 	$.values_reported[nm] = 0
	# } else {
	# 	$.notesrc[lcdnum] = "Pad"
	# 	$.values[nm] = 127
	# 	$.values_reported[nm] = 127
	# }

	msg = [0="/planetmode",1=(lcdnum+1),2=newmode]
	# print("PLANETMODE SENDING msg=",msg)
	$.sendosc(msg)
}

method set_transpose(val,params) {
	$.Transpose = val - 63
	print("TRANSPOSE = ",$.Transpose)
}
method set_seqleng(v) {
	$.SeqLeng = v
	$.AutoChangeForce = 1
}
method set_sequence(v) {
	$.Sequence = v
	$.AutoChangeForce = 1
}
method transpose_valmap(v,it) {
	return(v - 63)
}

method set_sound(val,params) {
	lcdnum = params["lcdnum"]
	$.sound[lcdnum] = $.sound_valmap_channel(val)
	print("SET_SOUND lcdnum=",lcdnum,"  sound=",$.sound[lcdnum])
	t = $.ergox_bayareameetup[lcdnum]
	t.set_currchan(1+$.sound[lcdnum])
}

method set_looping(val,params) {
	lcdnum = params["lcdnum"]
	t = $.ergox_bayareameetup[lcdnum]
	t.set_looping($.ison(val))
	print("SET_LOOPING lcdnum=",lcdnum,"  val=",val)
}

method set_collsound(val,params) {
	lcdnum = params["lcdnum"]
	$.collsound[lcdnum] = $.sound_valmap_channel(val)
	# print("SET_COLL_SOUND lcdnum=",lcdnum," collsound=",$.collsound[lcdnum])
}

method display_value(lcdnum,mode,it,row,col,val,tmout) {
	nm = it["name"]
	# print("ADJUST nm=",nm," val=",val)
	if ( mode == "option" ) {
		$.lcd_show_option_value(lcdnum,it,row)
	} else {
		if ( nm in $.label_tid ) {
			kill($.label_tid[nm])
			delete $.label_tid[nm]
		}
		# print("DISPLAY_VALUE, it=",it)
		t = task $.lcd_show_control_value(lcdnum,it,row,col,milliclicks(tmout))
		$.label_tid[nm] = t
	}
}


method next_page(lcdnum,mode) {
	pagesize = 8
	$.offset[lcdnum][mode] += pagesize
	if ( $.offset[lcdnum][mode] >= sizeof($.items[lcdnum][mode]) ) {
		$.offset[lcdnum][mode] = 0
	}
	$.lcd_setpage(lcdnum,mode)
	# print("NEXT_PAGE end! offset is ",$.offset[lcdnum][mode])
}

method prev_page(lcdnum,mode) {
	# print("PREV_PAGE! offset was ",$.offset[lcdnum][mode])
	if ( $.offset[lcdnum][mode] == 0 ) {
		print("   AT FIRST PAGE!")
		return()
	}
	pagesize = 8
	$.offset[lcdnum][mode] -= pagesize
	if ( $.offset[lcdnum][mode] < 0 ) {
		print("offset is < 0")
		$.offset[lcdnum][mode] = sizeof($.items[lcdnum][mode])/pagesize
		print("offset is now ",$.offset[lcdnum][mode])
	}
	$.lcd_setpage(lcdnum,mode,pagesize-1)
	print("PREV_PAGE end! offset is ",$.offset[lcdnum][mode])
}

method ano() {
	realtime(ano())
}

method default_pages() {
	$.lcd_setpage(0,"controlG")
	if ( $.lcds > 1 ) {
		$.lcd_setpage(1,"controlG")
	}
}

method reset() {

	$.fx_xy_controllers = [
		0=["x"=0,"y"=0],
		1=["x"=0,"y"=0]
		]
	$.prox_max = 4.0
	$.prox_min = 1.0
	$.expert_mode = 0

	$.fxrandom = 0
	$.fxdisabled = 0
	$.fx_mode = "None"
	$.fx_ctrls = ["None" = ["x"=0,"y"=0,"prox"=0],
			"RingMod" = ["x"=15,"y"=17,"prox"=18],
			"Scrubby" = ["x"=26,"y"=27,"prox"=0],
			"Transverb" = ["x"=74,"y"=76,"prox"=77]
			]

	$.offset = []
	$.offset[0] = ["controlG"=0,"controlM"=0,"controlA"=0]
	$.offset[1] = ["controlG"=0,"controlM"=0,"controlA"=0]

	$.default_control_settings()
	$.default_control_values("all")
	$.default_pages()
	$.cleanvideo()

	$.removeall()
	$.ano()
	$.erase()

	$.midi_focus = 0
	$.midi_focus_lcdnum = 0
	$.save_fnamei = 0
	$.last_clear = 0
	$.clear_count = 0
	$.selected = ""
	$.lastfingerdowntm = 0
	$.lastfingerdownx = 0
	$.lastfingerdowny = 0
	$.lastfingerphr = []
	$.ignorefingertillup = []
	$.lastfingertm = []
	$.current_loaded_fname = ""
	$.last_select_tm = Now

	$.chord = 'c d e- g'
	$.nextchord = ''
	$.chordactive = 1
	$.chordgathering = 1
	$.chordchanged()
}
method default_control_settings() {
	for ( lcdnum=0; lcdnum<$.lcds; lcdnum++ ) {
		$.init_controlsG(lcdnum)
		$.init_controlsM(lcdnum)
		$.init_controlsA(lcdnum)
	}
}
method erase() {
	msg = [0="/erase"]
	$.sendosc(msg)
}
method removeall() {
	msg = [0="/removeall"]
	$.sendosc(msg)
}


method savegraphic(lcdnum) {
	$.choosefile_start(lcdnum,$.do_savegraphic)
}
method saveall(lcdnum) {
	$.choosefile_start(lcdnum,$.do_saveall)
}
method savevideo(lcdnum) {
	$.choosefile_start(lcdnum,$.do_savevideo)
}
method savemusic(lcdnum) {
	$.choosefile_start(lcdnum,$.do_savemusic)
}

method loadgraphic(lcdnum) {
	$.choosefile_start(lcdnum,$.do_loadgraphic)
}
method loadall(lcdnum) {
	$.choosefile_start(lcdnum,$.do_loadall)
}
method loadvideo(lcdnum) {
	$.choosefile_start(lcdnum,$.do_loadvideo)
}
method loadmusic(lcdnum) {
	$.choosefile_start(lcdnum,$.do_loadmusic)
}

method choosefile_start(lcdnum,selectfunc) {
	$.midi_focus = $.choosefile
	$.choosefile_select = selectfunc
	$.midi_focus_lcdnum = lcdnum
	$.save_fnamei = 0

	$.lcd_clear(lcdnum)
	$.lcd_write(lcdnum,"Choose File:",0,0)
	$.show_filename(lcdnum,$.save_filenames[$.save_fnamei])
}

method do_savegraphic(fname) {
	$.save_values(fname,"graphic","all")
}
method do_saveall(fname) {
	$.save_values(fname,"all")
}
method do_savemusic(fname) {
	$.save_values(fname,"music")
}

method do_loadgraphic(fname) {
	$.load_values(fname)
}
method do_loadall(fname) {
	$.load_values(fname)
}
method do_loadmusic(fname) {
	$.load_values(fname)
}

method save_values(fname,valtype,dest) {
	if ( nargs() < 3 ) 
		dest = ""
	print("SAVE_VALUES fname=",fname," valtype=",valtype," dest=",dest)
	f = open(fname,"w")
	if ( f < 0 ) {
		print("UNABLE TO OPEN fname=",fname)
		return()
	}
	for ( nm in $.values ) {
		o = $.find_option(nm)
		if ( sizeof(o) == 0 ) {
			print("Hey, can't find nm=",nm," in options?")
			continue
		}
		if ( ("save" in o) && o["save"] == 0 ) {
			continue
		}
		# Always save PadMode values
		if ( valtype != "all" && ! ( nm ~~ "PadMod.*" ) ) {
			if ( o["type"] != valtype ) 
				continue
			if ( ("dest" in o) && dest!="all" && o["dest"] != dest)
				continue
		}
		put(f,sprintf("%s %s\n",nm,string($.get_value(nm))))
	}
	close(f)
}

method load_values(fname) {
	if ( fname == $.current_loaded_fname ) {
		# print("Not re-loading fname=",fname)
		return()
	}
	print("LOADING fname=",fname)
	f = open(fname,"rl")
	if ( f < 0 ) {
		print("UNABLE TO OPEN fname=",fname)
		return()
	}
	while ( (line=get(f)) != Eof ) {
		words = split(line," =\r\n")
		if ( sizeof(words) < 2 ) {
			print("Bad format?  line=",line)
			continue
		}
		# print("words=",words)
		nm = words[0]
		o = $.find_option(nm)

		# Never load PadMode values?
		if ( nm ~~ "PadMod.*" ) {
			print("NOT LOADING nm=",nm)
			continue
		}
		if ( sizeof(o) == 0 ) {
			print("Hey, can't find nm=",nm," in options?")
			continue
		}
		# print("load_values fname=",fname," calling change_value")
		$.change_value(o,integer(words[1]),"file")
	}
	close(f)
	$.current_loaded_fname = fname
}

method send_all_values() {
	print("Sending all values...")
	for ( nm in $.values ) {
		it = $.find_option(nm)
		print("Sending nm=",it["name"]," val=",$.values[nm])
		$.change_value(it,$.values[nm],"",1)
	}
}

method randvideo() {
	if ( Now > ($.lastrandvideo + milliclicks(500)) ) {
		$.lastrandvideo = Now
		$.rand_values("graphic","ff")
	}
} 
method randgraphic() { $.rand_values("graphic","default") }
method randall() { $.rand_values("all") }
method randmusic() { $.rand_values("music") }

method rand_values(valtype,dest) {
	for ( nm in $.values ) {
		o = $.find_option(nm)
		if ( sizeof(o) == 0 ) {
			print("Hey, can't find nm=",nm," in options?")
			continue
		}
		if ( valtype != "all" ) {
			if ( o["type"] != valtype ) 
				continue
			if ( ("dest" in o) && (o["dest"] != dest) )
				continue
		}
		val = rand(128)
		print("rand_values calling change_value")
		$.change_value(o,val,"rand")
		print("Value of ",nm," is ",$.get_value(nm))
	}
}

method show_filename(lcdnum,fname) {
	s = sprintf("%-15s",fname)
	$.lcd_write(lcdnum,s,2,5)
}
method choosefile(c) {
	print("HI FROM CHOOSEFILE! c=",c)
	b1 = integer(subbytes(c,2,1))
	val = integer(subbytes(c,3,1))
	if ( val == 0 ) {
		return()
	}
	lcdnum = $.midi_focus_lcdnum
	if ( b1 in $.ctrl2knob ) {
		print("B1 KNOB is ",$.ctrl2knob[b1])
	} else if ( b1 in $.button_controllers ) {
		b = $.button_controllers[b1]["name"]
		if ( b == "select" && val != 0 ) {
			print("SELECT called in choosefile, file=",$.save_filenames[$.save_fnamei])
			$.choosefile_select($.save_filenames[$.save_fnamei])
			$.midi_focus = 0
			$.lcd_setpage(lcdnum,"controlG")
		} else if ( b == "clear" && val != 0 ) {
			$.save_fnamei++
			if ( $.save_fnamei >= sizeof($.save_filenames) ) {
				$.save_fnamei = 0
			}
			print("save_fnamei = ",$.save_fnamei)
			$.show_filename(lcdnum,$.save_filenames[$.save_fnamei])
		} else if ( b == "controlG" ) {
			$.offset[lcdnum]["controlG"] = 0
			$.lcd_setpage(lcdnum,"controlG")
			$.midi_focus = 0
		} else if ( b == "controlM" ) {
			$.offset[lcdnum]["controlM"] = 0
			$.lcd_setpage(lcdnum,"controlM")
			$.midi_focus = 0
		}
	}
}

method handle_midi_keyboard(c) {
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
	if ( $.get_value("ThruMode") ) {
		c.time = 0
		c.chan = $.currpad+1
		t = $.ergox_bayareameetup[$.currpad]
		t.playthru(c,uid)
	} else if ( $.get_value("looprecmode") ) {
		if ( c.type == NOTEON ) {
			keydown = 1
		} else {
			keydown = 0
		}
		c.type = NOTE
		# print("LOOPERMODE, sending c=",c," to looper keydown=",keydown)
		t = $.ergox_bayareameetup[$.currpad]
		t.looper_input_p(keydown,c,1.0,uid,1)
	} else if ( $.chordgathering ) {
		$.handle_midi_chord(c)
	} else {
		return()
	}
}

method num_pressed(lcdnum) {
	n = 0
	for ( b in $.buttonstate[lcdnum] ) {
		if ( $.buttonstate[lcdnum][b] ) {
			n++
		}
	}
	return(n)
}

method reset_was_pressed(lcdnum) {
	$.was_pressed[lcdnum] = ["controlG"=0, "controlM"=0, "clear"=0, "select"=0]
}

method next_mode(lcdnum) {
	was = $.was_pressed[lcdnum]

	print("next_mode for lcdnum=",lcdnum," was_pressed = ",was)

	g = was["controlG"]
	m = was["controlM"]
	if ( g && m ) {
		return("controlG")
	}
	if ( g )
		return("controlG")
	if ( m )
		return("controlM")
	print("UNEXPECTED situation in next_mode? lcdnum=",lcdnum," was=",was)
	error("UNEXPECTED in next_mode")
	return("controlM")
}

method handle_midi(c)
{
	# print("handle_midi c=",c)

	if ( c.port != CherryControl ) {

		if ( $.anycherry == 0 ) {
			t = CherryControl
			CherryControl = KeyboardControl
			KeyboardControl = t
			print("Swapping NOW Cherry=",CherryControl," keyboard=",KeyboardControl)
		} else {
			$.handle_midi_keyboard(c)
			return()
		}
	}
	$.anycherry = 1

	if ( c.type != CONTROLLER ) {
		print("Ignoring non-controller message c=",c)
		return()
	}
	if ( $.ignore_controls ) {
		# print("Ignoring due to ignore_controls")
		return()
	}

	b0 = integer(subbytes(c,1,1))
	b1 = integer(subbytes(c,2,1))
	val = integer(subbytes(c,3,1))

	if ( $.midi_focus != 0 ) {
		$.midi_focus(c)
		return()
	}

	# print("b1 = ",b1," val=",val)
	if ( b1 in $.button_controllers ) {

		b = $.button_controllers[b1]["name"]
		lcdnum = $.button_controllers[b1]["lcdnum"]

		if ( lcdnum >= $.lcds ) {
			print("Ignoring button for lcd=",lcdnum," !!!!!")
			return()
		}

		# print("\nLCDNUM = ",lcdnum,"\n\n")

		$.buttonstate[lcdnum][b] = val

		if ( $.ignore_up[lcdnum] ) {
			# print("Ignoring up of button ",b)
			$.ignore_up[lcdnum] = 0
			if ( $.refresh_on_up[lcdnum] ) {
				$.lcd_refresh(lcdnum)
				$.refresh_on_up[lcdnum] = 0
			}
			return()
		}

		mode = $.lcd_mode[lcdnum]

		if ( val == 0 ) {
			$.was_pressed[lcdnum][b] = 1
		}

		print("b=",b)
		if ( (b=="controlM" || b=="controlG") ) {

			if ( $.buttonstate[lcdnum]["select"] != 0 ) {
				thisone = $.button2selection[b]
				if ( $.selected!="" && $.selected!=thisone ) {
					$.selected = "all"
					$.selected = "expertmode"
				} else {
					if ( b == "controlM" )
						$.selected = "music"
					else
						$.selected = "graphic"
				}
				print("SELECTED is now ",$.selected)
				return()
			}
		}

		print("B=",b)
		if ( (b=="controlM" || b=="controlG") && val==0 && $.num_pressed(lcdnum) == 0 ) {
			# newmode = $.next_mode(lcdnum)
			if ( $.selected == "" ) {
				print("DEBUG A")
				if ( b == "controlG" ) {
					$.change_value_byname("PadMode#"+string(lcdnum+1),0,"button")
					$.show_message_lcd(
						[1="Now, Touch the Pad",
						2="to create Graphics"],lcdnum)
					sleeptill(Now+2b)
				} else if ( b == "controlM" ) {
					$.change_value_byname("PadMode#"+string(lcdnum+1),50,"button")
					$.show_message_lcd(
						[1="Now, Touch the Pad",
						2="to play Music"],lcdnum)
					sleeptill(Now+2b)
				}
				# if ( mode == newmode ) {
				# 	# already in desired mode
				# 	$.next_page(lcdnum,mode)
				# } else {
				# 	$.offset[lcdnum][newmode] = 0
				# 	$.lcd_setpage(lcdnum,newmode)
				# }
				$.lcd_setpage(lcdnum,"controlG")
			} else {
				print("Selected is set to ",$.selected," , ignoring M up")
			}
			$.reset_was_pressed(lcdnum)
			return()
		}
		if ( b == "clear" ) {
			if ( val == 0 ) {
				return()
			}
			if ( $.buttonstate[lcdnum]["select"] != 0 ) {
				$.clear_count = 3
			} else {
				$.clear_count = 0
			}

			# dt = milliclicks(1000)
			# sincelast = Now - $.last_clear
			# if ( sincelast > dt ) {
			# 	$.clear_count = 0
			# } else {
			# 	$.clear_count++
			# }
			# $.last_clear = Now

			if ( $.clear_count == 0 ) {
				print("ANO/ERASE/REMOVEALL")
				$.removeall()
				$.ano()
				$.erase()
				for ( lcdnum=0; lcdnum<$.lcds; lcdnum++ ) {
					t = $.ergox_bayareameetup[lcdnum]
					t.killchan()
				}
				$.show_message(
					[1="Clear",
					2=""])
				sleeptill(Now+1b/2)
				$.lcd_refresh_all()
			} else if ( $.clear_count == 1 ) {
				$.show_message(
					[1="Press Clear 3 Times",
					2="for a TOTAL RESET"])
				sleeptill(Now+1b)
				$.lcd_refresh_all()
				print("Nothing done when clear_count==1")
				# $.removeall()
				# $.ano()
				# $.erase()
			} else if ( $.clear_count >= 2 ) {
				print("RESET!")
				$.reset()
				$.show_message(
					[1="TOTAL",
					2="RESET!!!"])
				sleeptill(Now+4b)
				$.lcd_refresh_all()
			} else {
				print("clear_count=",$.clear_count," ignored")
			}
			return()
		}
		if ( b == "select" ) {
			print("SELECT val=",val)
			print("RESETTING first knob value")
			$.reset_first_knob_value()
			if ( val != 0 ) {
				$.selected = ""
				if ( $.expert_mode == 0 ) {
					$.show_message(
						[1="Now press CLEAR",
						2="for total reset!"])
					sleeptill(Now+2b)
					$.lcd_clear(lcdnum)
				}
				$.display_all_values(lcdnum,mode)
			} else {
				n = $.presets[$.selected]
				fname = sprintf("%s_%d.fpp",$.selected,n)
				print("SELECTED =",$.selected," fname=",fname)
				if ( $.selected == "graphic" ) {
					$.do_savegraphic(fname)
				} else if ( $.selected == "music" ) {
					$.do_savemusic(fname)
				} else if ( $.selected == "all" ) {
					$.do_saveall(fname)
				} else if ( $.selected == "expertmode" ) {
					$.expert_mode = 1 - $.expert_mode
					if ( $.expert_mode ) {
						s = "is ON!"
					} else {
						s = "is OFF!"
					}
					$.show_message(
						[1="Expert Mode",
						2=s])
					sleeptill(Now+2b)
					$.selected = ""
					$.default_control_settings()
					$.default_pages()
					return()
				} else {
					print("Ignoring selected = ",$.selected)
					$.selected = ""
					$.lcd_refresh(lcdnum)
					return()
				}
				$.show_message_till(Now+2b,
					[1="Saved "+$.selected+" values",
					2="in preset # "+string(n)])
				$.presets[$.selected]++
				$.selected = ""
			}
			return()
		}

		return()
	}

	# print("knob?  b1=",b1)
	if ( b1 in $.ctrl2knob ) {
		p = $.ctrl2knob[b1]
		row = p["row"]
		col = p["col"]
		lcdnum = p["lcdnum"]

		if ( lcdnum >= $.lcds ) {
			print("Ignoring knob for lcd=",lcdnum," !!!!!!")
			return()
		}

		mode = $.lcd_mode[lcdnum]

		# print("\nLCDNUM = ",lcdnum,"\n\n")

		if ( ! (mode in $.knobmodes) ) {
			return()
		}

		ci = row+col*4
		ci += $.offset[lcdnum][mode]

		# print("CI = ",ci," col=",col," mode=",mode)
		# print("lcdnum=",lcdnum," mode=",mode)

		# aa = $.items[lcdnum]
		# if ( typeof(aa) != "array" ) {
		# 	print("HEY, $.items lcdnum=",lcdnum," isn't an array!?")
		# 	return()
		# }
		# if ( ! (mode in ($.items[lcdnum])) ) {
		# 	print("HEY, mode=",mode," not in items =",$.items[lcdnum])
		# 	return()
		# }

		items = $.items[lcdnum][mode]

		if ( ! ( ci in items ) ) {
			return()
		}
		it = items[ci]

		if ( (mode=="controlG" || mode=="controlM" ) && $.buttonstate[lcdnum]["select"] != 0 ) {
			# print("CONTROL SELECT mode=",mode," for knob = ",it["name"]," ci=",ci," offset=",$.offset[lcdnum][mode])

			if ( $.expert_mode == 0 ) {
				print("Parameter changes not allowed!")
				return()
			}

			if ( $.first_knob_value[ci] < 0 ) {
				# print("Setting first knob value of ci=",ci)
				$.first_knob_value[ci] = val
				return()
			}
			dknob = abs($.first_knob_value[ci]-val)
			# print("dknob = ",dknob," ci=",ci)
			if ( dknob < 3 && val != 0 && val != 127 ) {
				# print("Ignoring value change of knob ci=",ci)
				return()
			}

			# print("USING val=",val," for knob=",ci)
			it = $.find_option_byval(val)
			items[ci] = it
			nm = it["name"]
			if ( $.is_per_lcd_name(nm) ) {
				prefix = substr(nm,1,sizeof(nm)-2)
				per_lcd_name = prefix+"#"+string(lcdnum+1)
				it = $.find_option(per_lcd_name)
				items[ci] = it
			}

			$.lcd_set_item(lcdnum,row,col,items,ci)
			$.lcd_show_control_name(lcdnum,items[ci],row,col)
			print("CONTROL IS NOW ",items[ci]["name"])
			$.ignore_up[lcdnum] = 1
			$.refresh_on_up[lcdnum] = 1
			# $.lcd_refresh(lcdnum)
			return()
		}

		if ( "type" in it ) {
			f = it["type"] + "_adjust"
		} else {
			f = "adjust"
		}
		# print("KNOB nm=",it["name"],"  f=",f," it=",it)
		didit = $.change_value(it,val,ci)
		if ( didit != 0 ) {
			$.display_value(lcdnum,mode,it,row,col,val,1000)
		}
		# $.(f)(lcdnum,mode,it,row,col,val)
	}
	return()
	
}

method display_all_values(lcdnum,mode) {
	items = $.items[lcdnum][mode]
	for ( row=0; row<4; row++ ) {
	    for ( col=0; col<2; col++ ) {
		ci = row+col*4
		ci += $.offset[lcdnum][mode]
		# print("CI = ",ci," col=",col," mode=",mode)
		if ( ! ( ci in items ) ) {
			continue
		}
		it = items[ci]
		val = $.get_value(it["name"])
		$.display_value(lcdnum,mode,it,row,col,val,0)
	    }
	}
}

method show_message_till(endtm,lines) {
	$.show_message(lines)
	$.ignore_controls = 1
	task $.ignore_till(endtm)
}

method show_message(lines) {
	# print("show_message lines=",lines)
	for ( lcdnum=0; lcdnum<$.lcds; lcdnum++ ) {
		$.show_message_lcd(lines,lcdnum)
	}
}
method show_message_lcd(lines,lcdnum) {
	# print("show_message lines=",lines)
	$.lcd_clear(lcdnum)
	for ( row=0; row<4; row++ ) {
		if ( row in lines ) {
			s = lines[row]
			pos = (20 - sizeof(s))/2
			# print("row=",row," pos=",pos," sizeof(s)=",sizeof(s))
			$.lcd_write(lcdnum,s,row,pos)
		}
	}
}

method show_initial_messages() {
	$.ignore_controls = 1
	$.show_message([1="Please touch",2="iGesture pad #1"])
	tenth = milliclicks(100)
	while ( sizeof(GestureDevMap) < 1 ) {
		sleeptill(Now+tenth)
	}
	if ( $.gesturepads > 1 ) {
		$.show_message([1="Please touch",2="iGesture pad #2"])
		while ( sizeof(GestureDevMap) < 2 ) {
			sleeptill(Now+tenth)
		}
	}
	$.lcd_refresh_all()
	$.initdone = 1
	$.ignore_controls = 0
}

method ignore_till(tm) {
	sleeptill(tm)
	$.lcd_refresh_all()
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
	# print("REALTIME A p=",p," tm=",tm)
	realtime(p,tm)
}
method map_prox(prox) {
	if ( prox > $.prox_max )
		prox = $.prox_max
	prox = prox - $.prox_min
	return ( prox / ($.prox_max-$.prox_min))
}
method handle_finger(ft,row,col,prox,padi,finger,rawx,rawy) {

	# print("handle_finger, ft=",ft)

	fid = $.fingeruid(padi,finger)
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

	lcdnum = padi
	# fingermode = $.fingermode[lcdnum]
	# print("handle_finger lcdnum=",lcdnum," fingermode=",fingermode)

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
			print("Second quick finger-down, not being ignored.")
			# print("Second quick finger-down in same place, fid=",fid," that finger is now being ignored!")
			# $.ignorefingertillup[fid] = 1
			# return()
		}
	}

	if ( $.ignorefingertillup[fid] == 1 ) {
		# print("ignoretillup!! fid=",fid)
		if ( ft == "fingerup" ) {
			# print("Finger went back up, resetting ignoretillup")
			$.ignorefingertillup[fid] = 0
		} else {
			return()
		}
	}

	dt = Now - $.lastfingertm[fid]
	$.lastfingertm[fid] = Now
	
	# notesrc = $.notesrc[lcdnum]
	planetmode = $.planetmode[lcdnum]

	# print("HANDLE FINGER PLANETMODE = ",planetmode," ft=",ft)

	if ( planetmode == "Planets" || planetmode == "Attract" || planetmode == "Repel" ) {
		oscaddr = $.finger2osc[ft]
		msg = [0=oscaddr,1=fid,2=rawx,3=rawy,4=prox,5=orient,6=eccent,7=xvel,8=yvel]
		# print("Sending msg=",msg)
		$.sendosc(msg)

	} else if ( planetmode == "Fx" ) {
		print("FINGER ft=",ft," fx_mode=",$.fx_mode)
		if ( ft == "fingerup" ) {
			$.realtime($.fxenable_phr(1,0),Now)
			$.realtime($.fxenable_phr(2,0),Now)
			$.realtime($.fxenable_phr(3,0),Now)
		} else if ( ft == "fingerdrag" ) {
			xctrl = $.fx_ctrls[$.fx_mode]["x"]
			yctrl = $.fx_ctrls[$.fx_mode]["y"]
			proxctrl = $.fx_ctrls[$.fx_mode]["prox"]
			xval = rawx * 127.0
			yval = rawy * 127.0
			proxval = $.map_prox(prox) * 127.0
			px = controller(16,xctrl,xval)
			py = controller(16,yctrl,yval)
			pall = px + py
			if ( proxctrl != 0 ) {
				print("PROX ctrl=",proxctrl," proxval=",proxval)
				pall += controller(16,proxctrl,proxval)
			}
			$.realtime(pall,Now)
		} else if ( ft == "fingerdown" ) {
			if ( $.fx_mode ==  "RingMod" ) {
				$.realtime($.fxenable_phr(1,1),Now)
				$.realtime($.fxenable_phr(2,0),Now)
				$.realtime($.fxenable_phr(3,0),Now)
			} else if ( $.fx_mode ==  "Scrubby" ) {
				$.realtime($.fxenable_phr(1,0),Now)
				$.realtime($.fxenable_phr(2,1),Now)
				$.realtime($.fxenable_phr(3,0),Now)
			} else if ( $.fx_mode ==  "Transverb" ) {
				$.realtime($.fxenable_phr(1,0),Now)
				$.realtime($.fxenable_phr(2,0),Now)
				$.realtime($.fxenable_phr(3,1),Now)
			} else {
				$.realtime($.fxenable_phr(1,0),Now)
				$.realtime($.fxenable_phr(2,0),Now)
				$.realtime($.fxenable_phr(3,0),Now)
			}
		}

	} else if ( planetmode == "Neural" ) {
		osc1 = ( rawx / 0.125 ) % 8
		osc2 = ( rawy / 0.125 ) % 8
		amp = rawx
		amp = prox / 2.0
		amp -= 1.0
		freq = prox * 1000.0
		msg = [0=sprintf("/oscil/%d/feedback",osc1),1=osc2,2=amp]
		msg = [0=sprintf("/oscil/%d/freq",osc1),1=freq]
		$.sendneural(msg)
		return()
		
	} else {
		fid = padi*100+finger
		t = $.ergox_bayareameetup[lcdnum]

		if ( ft == "fingerdown" ) {
			p = $.fingernote(ft,row,col,prox,fid,rawx,rawy,lcdnum)
			q = $.val2quant($.DownQnt)
			tm = nextquant(Now,q)


			# print("lcdnum=",lcdnum," looping=",t.islooping())
			if ( t.islooping() ) {
				p.type = NOTEON
				p.time = 0
				# print("looper_input = ",p)
				t.looper_input_pq(1,p,prox,fid,0,q)
			} else {
				# print("Normal playing = ",p)
				$.realtime(p,tm)
			}

			$.lastfingertm[fid] = tm
			$.lastfingerphr[fid] = p

		} else if ( ft == "fingerdrag" ) {
			# if ( t.islooping() ) {
			# 	# print("Ignoring drag because we're looping")
			# 	return()
			# }
			if ( $.NoteDur == 0 ) {
				return()
			}
			lim = ((1b/32) * 127) / ($.NoteFreq+1)
			# print("NoteFreq=",$.NoteFreq," lim=",lim,"  lim2=",(lim/prox))
			lim = lim / prox
			# print("NoteDur=",$.NoteDur," dt=",dt," lim=",lim)
			if ( dt >= lim ) {
				q = $.val2quant($.RepQnt)
				p = $.fingernote(ft,row,col,prox,fid,rawx,rawy,lcdnum)
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
					q = $.val2quant($.RepQnt)
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

	if ( ! keydown ) {
		if ( c == $.ignorenextup ) {
			$.ignorenextup = 0
			return()
		}
	}

	if ( c == "DEL" ) {
		if ( keydown ) {
			print("RESETTING LOOP")
			for ( t in $.ergox_bayareameetup ) {
				$.ergox_bayareameetup[t].killall()
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

	print("Ignoring char=",c)
	return()

	for ( n=1; n<=$.nletters; n++ ) {
		letter = substr($.keyorder,n,1)
		if ( c == letter ) {
			break
		}
	}
	if ( n <= $.nletters ) {
		floati = n / float($.nletters)
		t = $.ergox_bayareameetup[$.currpad]
		t.looper_input_i(keydown,floati,prox,c)
	} else {
		print("DIDN'T find c=",c)
	}
}

method ctrl_midi(c,nw) {
	$.finger_does_midi = 1 - $.finger_does_midi
	print("FINGER DOES MIDI = ",$.finger_does_midi)
}
method ctrl_graphics(c,nw) {
	$.finger_does_graphics = 1 - $.finger_does_graphics
	print("FINGER DOES GRAPHICS = ",$.finger_does_graphics)
}

method ctrl_exec(c,nw) {
	if ( c == "Q" ) {
		print("NOT saving patches...")
		# $.savegraphicpatch(99)
		# $.savemusicpatch(99)
		$.quit = 1
	} else if ( c == "S" ) {
		print("Swapping Cherry=",CherryControl," keyboard=",KeyboardControl)
		t = CherryControl
		CherryControl = KeyboardControl
		KeyboardControl = t
		print("Swapping NOW Cherry=",CherryControl," keyboard=",KeyboardControl)
	} else if ( c == "A" ) {
		print("ABORTING without saving...")
		$.quit = 1
	} else if ( c == "V" ) {
		$.verbose = 1 - $.verbose
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


class ergox_bayareameetup_onelooper {

method init(parent,inputf,q,ch,nphrases,initiallength,vals) {
	$.parent = parent
	$.inputf = inputf
	$.quant = q
	$.currchan = ch
	$.vals = vals
	$.initiallength = initiallength
	$.loopnumber = 0
	$.chordornament = ''
	# print("Setting chordornament to ''")
	$.vals["loopxpose"] = 0
	$.typo_setup(nphrases)
	$.centerp = 'p64'
	$.rescale_from_phrase('c,e,g')
}

method set_currchan(ch) {
	$.currchan = ch
}

method get_value(nm) {
	return($.parent.get_value(nm))
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
		# print("Loop chan=",$.currchan," tm=",tm/1b)
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
	# if ( $.loopphrase != '' ) {
	# 	print("play_loop tm=",tm," loopphrase=",head($.loopphrase,4),"...")
	# }
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

	# fade = $.tp["loopfade"]
	fade = $.parent.get_loopfade()
	# print("fade=",fade)

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
		# Don't requantize the warped stuff
		if ( w == '' && $.requant > 1 ) {
			p = quantize(p,$.requant)
		}
		p = cut(p,CUT_TIME,0,leng)

		p = $.parent.common_note_loop(p)

		# print("ABOUT TO PLAY LOOPPHRASE")
		# print("play_loop calling realtime for p=",p)
		$.looptask = $.realtime(p,tm)
		# print("Playing looptask leng=",leng," p=",p," Now=",Now)
	}
}

method zoomin() {
	print("ZOOMIN!")
}
method zoomout() {
	print("ZOOMOUT!")
}

method killchan() {
	print("KILLING LOOPTASK ",$.looptask)
	$.loopphrasewarp = ''
	$.setloop('')
	kill($.looptask)
	$.looptask = -1
}

method realtime(p,tm) {
	# print("REALTIME B p=",head(p,4),"... tm=",tm)
	t = realtime(p,tm)
	# i = task $.sendosctask(p,tm)
	return(t)
}

method sendosctask(p,tm) {
	print("sendosctask, p=",p," tm=",tm)
	for ( nt in p ) {
		if ( nt.type == NOTEON ) {
			msg = [0="/noteon",1=nt.chan,2=nt.pitch,3=nt.vol]
			$.sendoscat(msg,tm+nt.time)
		} else if ( nt.type == NOTEOFF ) {
			msg = [0="/noteoff",1=nt.chan,2=nt.pitch,3=nt.vol]
			$.sendoscat(msg,tm+nt.time)
		} else if ( nt.type == NOTE ) {
			msg = [0="/noteon",1=nt.chan,2=nt.pitch,3=nt.vol]
			$.sendoscat(msg,tm+nt.time)
			msg = [0="/noteoff",1=nt.chan,2=nt.pitch,3=nt.vol]
			$.sendoscat(msg,tm+nt.time+nt.dur)
		} else {
			print("NOT SENDING OSC for nt=",nt)
		}
	}
}

method sendoscat(msg,tm) {
	sleeptill(tm)
	$.parent.sendosc(msg)
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

method color_rand() {
	r = rand(360)
	msg = [0="/setchannelhue",1=$.currchan,2=r]
	$.parent.sendosc(msg)
}

# method colorcycle() {
# 	r = rand(360)
# 	msg = [0="/setchannelhue",1=$.currchan,2=r]
# 	$.parent.sendosc(msg)
# }

method killall() {
	Offsetpitch = 0
	print("Offsetpitch = ",Offsetpitch)
	$.killrealtime()
	# Don't reset $.shiftisdown!
	if ( defined($.initiallength) )
		$.tp["length"] = $.initiallength
	else
		$.tp["length"] = 0
	print("TYPO_RESTART, chan=",$.currchan," setting length=",$.tp["length"])
	print("killall is setting loopstart to 0")
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
	# print("chordchanged, p=",p)
	if ( $.get_value("loopxposemode") ) {
		print("loopxposemode is on?")
		# p.time = 0
		# $.vals["loopxpose"] = p.pitch - 60
		print("NOT Setting loopxpose to ",$.vals["loopxpose"])
	} else if ( $.get_value("grabmode") ) {
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
	} else {
		$.rescale_from_phrase(p)
	}
}

method rescale_from_phrase(p) {
	sc = completescalephrase(p)
	sc = sc{??.pitch>=$.minpitch && ??.pitch<=$.maxpitch}
	$.rescale_from_scale(sc)
}

method rescale_from_scale(sc) {
	patt = $.currpatt
	ch = $.currchan
	# print("RESCALE called! patt=",patt," ch=",ch," sc=",sc)

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

method apply_mods(p) {

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

# 	if ( p.chan == 3 ) {
# 		# Drums - program # determines which pitches are used
# 		# program 0,  use 36 to 68
# 		# program 1,  use 69 to 102
# 		# print("drum was=",p)
# 		r = ''
# 		pnum = $.vals["program"]
# 		# print("drum, pnum=",pnum)
# 		if ( pnum == 0 ) {
# 			minpitch = 36
# 			maxpitch = 68
# 		} else {
# 			minpitch = 69
# 			maxpitch = 102
# 		}
# 		pitchrange = maxpitch - minpitch + 1
# 		extra = ($.loopnumber % 10) - 5
# 		for ( nt in p ) {
# 			nt.pitch = minpitch + ((nt.pitch+extra) % pitchrange)
# 			r |= nt
# 		}
# 		p = r
# 		# print("  adjusted=",p)
# 		if ( typeof(p) != "phrase" ) {
# 			print("Hmmm, p isn't a phrase at AA1aaa?")
# 			return()
# 		}
# 	}

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
	# print("Post velocity stuff, p=",p,"  inc=",$.velocityinc," vr=",$.velocityrand)

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
		$.killchan()
		return()
	}
}

# method rand_program() {
# 	p = progchange(1+rand($.vals["nprograms"]),$.currchan)
# 	print("Sending rand progchange p=",p)
# 	realtime(p)
# }

method get_quant() {
	return($.quant)
}
method set_quant(v) {
	$.quant = integer(v)
	if ( $.quant < 1 ) {
		$.quant = 1
	}
	print("Quant is now ",$.quant)
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

	$.looper_input_p(keydown,p,prox,uid,0)
}

method playthru(c,uid) {
	# print("REALTIME THRU uid=",uid," c=",c)
	$.realtime(c,0)
	$.lastplayedphr[uid] = c
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
		# print("REALTIME CLEANUP p=",p)
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

	print("LOOPER_INPUT_P p=",p)
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

	if ( ! reallymidi ) {
		# print("PROX=",prox," qnt=",qnt)
		if ( prox > 1.0 ) {
			qnt = $.quant / qd
		}
		if ( prox > 2.0 ) {
			qnt = $.quant / (2 * qd)
		}
	}
	qnt = integer(qnt)
	if ( qnt < 1 ) {
		qnt = 1
	}
	$.looper_input_pq(keydown,p,prox,uid,reallymidi,qnt)
}

method islooping() {
	return($.looping)
}

method set_looping(val) {
	print("SET_LOOPING in one looper, val=",val)
	$.looping = val
}

method looper_input_pq(keydown,p,prox,uid,reallymidi,qnt) {

	# print("LOOPER_INPUT_PQ p=",p," qnt=",qnt," keydown=",keydown," looping=",$.looping)
	nw = nextquant(Now,qnt)
	# print("input_p  p=",p)

	if ( $.xpose != 0 ) {
		p = transpose(p,$.xpose)
		# print("IS transposing p=",p)
	}
	# if ( $.vals["octave"] != 0) {
	# 	p = transpose(p,$.vals["octave"]*12)
	# }
	if ( $.vals["mono"] ) {
		# print("Forcing pad phrase to be mono")
		p = mono(p,2)
	}

	# print("looper_input i=",i," ii=",ii," sz=",sz," prx=",prox," id=",uid,"  chan=",$.currchan," p=",p)

	# isrecording = $.vals["recording"]

	isrecording = $.looping

	# print("Looper_input_i currchan=",$.currchan," isrecording=",isrecording," keydown=",keydown," uid=",uid)

	# print("MID p=",p," keydown=",keydown)
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

		# if ( ! reallymidi ) {
		# 	print("Not reallymidi, p was",p)
		# 	p = $.parent.common_note(p,0)
		# 	print("   after common_note p =",p)
		# 	# p.vol = (prox*prox) * 127 / 9.0
		# 	# print("Not reallymidi, prox=",prox," p.vol = ",p.vol)
		# } else {
		# 	print("reallymidi, p.vol = ",p.vol)
		# 	# p.vol = $.NoteVol
		# }

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
			# print("REALTIME B p=",p)
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

		tmpdt = lastdown - $.tp["loopstart"]
		while ( tmpdt < 0 )
			tmpdt += $.tp["length"]

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
		if ( $.forcedur ) {
			p1.dur = nextq
		}
		p1.length = nextq
		# print("ADDING $=",$," p1=",p1," TO LOOP!!! chan=",$.currchan)
		if ( p1.dur == 0 ) {
			p1.dur = $.parent.get_notedur()
			print("HEY!!! dur was 0 ?? now p1=",p1)
		}

		sizep1 = sizeof(p1)
		lim = $.parent.get_loopnotelimit()
		if ( sizeof($.loopphrase) > lim ) {
			print("LIMITING loop notes to lim=",lim)
			for ( n = 0; n < sizep1; n++ ) {
				r = rand(1,sizeof($.loopphrase))
				pp = $.loopphrase
				pp % r = ''
				$.loopphrase = pp
			}
		}
		p2 = $.loopphrase | p1

		p2 = dedup(p2)
		# if ( sizeof(p2) > $.parent.get_loopnotelimit ) {
		# 	# just in case p1 is big
		# 	while ( sizeof(p1) > ($.loopnotelimit/2) ) {
		# 		print("REDUCING size of p1?")
		# 		p1 = p1{rand(2)==0}
		# 	}
		# 	while ( sizeof(p2) > $.loopnotelimit ) {
		# 		print("REDUCING size of loopphrase")
		# 		$.loopphrase = $.loopphrase{rand(2)==0}
		# 		p2 = $.loopphrase | p1
		# 	}
		# }
		# print("SETTING LOOP to ",p2)
		$.setloop(p2)
	}
	# p.time = 0
	p.type = NOTEOFF
	# print("END OF INPUT_PQ, p=",p)
	$.realtime(p,nw)
	# print("Playing C p=",p," Now=",Now," nw=",nw)
}

method kill_later(tid,tm) {
	# print("kill_later tid=",tid)
	sleeptill(tm)
	kill(tid)
}

method realano() {
	# print("REALTIME D ano")
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
	# print("REALTIME D p=",p)
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
	# print("LOW NOTE LIMIT EXPERIMENT!")

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
	print("transposed loopphrase=",$.loopphrase)
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


# method set_program(v) {
# 	if ( v < 0 )
# 		v = 0
# 	else if ( v >= $.vals["nprograms"] )
# 		v = $.vals["nprograms"]-1
# 	$.vals["program"] = v
# 	# p = progchange(1+v,$.currchan)
# 	realchan = $.vals["chan"]
# 	p = progchange(1+v,realchan)
# 	print("Sending progchange v=",v," p=",p,"  chan=",realchan)
# 	# print("REALTIME E p=",p)
# 	realtime(p)
# }

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

function ergox_bayareameetup_resetconsole(o) {
	o.stop()
}

function ergox_bayareameetup_midi_restart(o) {
	o.midi_restart()
}
