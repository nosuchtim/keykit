#########################################
# Message Library
#########################################






#########################################
# Interface
#########################################






#########################################
# Data structures
#########################################



# MsgMap - keyed on logical name
#  fn - function type 
#  c - controller number
#  msb - most significant byte
#  lsb - least significant byte




#########################################
# Functionality
#########################################



# By loading up different controller maps you can generate output for
CtrlMapGB = [
	"vol" = ["fn"=0, "c"=7],
	"pan" = ["fn"=0, "c"=10],
	"hzc" = ["fn"=0, "c"=21],
	"fil" = ["fn"=0, "c"=74],
	"res" = ["fn"=0, "c"=71],
	"typ" = ["fn"=0, "c"=34],
	"del" = ["fn"=0, "c"=94],
	"efx" = ["fn"=0, "c"=86],
	"rev" = ["fn"=0, "c"=91],
	"lfo" = ["fn"=0, "c"=16],

	"aa" = ["fn"=0, "c"=73],
	"ad" = ["fn"=0, "c"=75],
	"as" = ["fn"=0, "c"=31],
	"ar" = ["fn"=0, "c"=72],
	"al" = ["fn"=0, "c"=80],

	"fa" = ["fn"=0, "c"=82],
	"fd" = ["fn"=0, "c"=83],
	"fs" = ["fn"=0, "c"=28],
	"fr" = ["fn"=0, "c"=29],
	"fl" = ["fn"=0, "c"=19],

	"pa" = ["fn"=0, "c"=26],
	"pd" = ["fn"=0, "c"=27],
	"ps" = ["fn"=0, "c"=39],
	"pr" = ["fn"=0, "c"=40],
	"pl" = ["fn"=0, "c"=18],

	"prg" = ["fn"=8],
	"msb" = ["fn"=0, "c"=0],
	"lsb" = ["fn"=0, "c"=32]
]




CtrlMapISIS = [
	"v" = ["fn"=0, "c"=7],
	"m" = ["fn"=0, "c"=1],
	"p" = ["fn"=0, "c"=10],
	"lr" = ["fn"=1, "c"=1],
	"lp" = ["fn"=1, "c"=17],
	"lv" = ["fn"=1, "c"=20],
	"lf" = ["fn"=1, "c"=23],
	"cho" = ["fn"=1, "c"=93],
	"rev" = ["fn"=1, "c"=91],
	"a" = ["fn"=0, "c"=73],
	"d" = ["fn"=0, "c"=75],
	"s" = ["fn"=0, "c"=31],
	"r" = ["fn"=0, "c"=72],
	"fc" = ["fn"=0, "c"=74],
	"fc1" = ["fn"=2, "msb"=1,"lsb"=32],
	"fr" = ["fn"=2, "msb"=1,"lsb"=33],
	"vr" = ["fn"=2, "msb"=1,"lsb"=8],
	"va" = ["fn"=2, "msb"=1,"lsb"=9],
	"vd" = ["fn"=2, "msb"=1,"lsb"=10]
]



function msgInit() {
	MsgMap = CtrlMapGB

	MsgDrums = [
	]

	# b Bass  s Snare  h hihat  o open  c cymbal  l latin  t tom  m misc
	msgSetDrum("b", "35 36 47 48 95 96")
	msgSetDrum("s", "38 50 52 97 98")
	msgSetDrum("h", "42 44 54 58")
	msgSetDrum("o", "46 56 63")
	msgSetDrum("c", "63 64 65 67 69 71")
	msgSetDrum("l", "72 73 74 75 76 77 78")
	msgSetDrum("t", "41 43 45 62 68 70")
	msgSetDrum("z", "81 82 83")
	msgSetDrum("m", "84 85 86 87 88 89 90 91 92 93")

}



# Set the possible notes for the drum type specified
# msgSetDrum("b", "34 35 37>3 37>2")
function msgSetDrum(name, notestr) {

	notes = split(notestr)

	drums = []

	for (i in notes) {
		note = notes[i]
		notedef = split(note,".")
		ph = 'c'
		ph.pitch = integer(notedef[0])
		drums[i] = ph
	}

	MsgDrums[name] = drums
}


# Return a midi message for this channel and value
function msgGet(msg,ch,v) {

	ph = ''

	# If you can find the controller
	if (msg in MsgMap) {

		msgdata = MsgMap[msg]
		fn = msgdata["fn"]
		
		# Find a handler
		if (fn in KMMsgFuncs) {
			func = KMMsgFuncs[fn]

			# Execute handler to return a phrase
			ph = func(msgdata,ch,v)
		}
	}

	return(ph)
}



# Get a control curve phrase
function msgGetFade(msg, ch, dur, smooth, values) {
	arr = split(values)
	r = ''
	for (vidx in arr) {
		vidx2 = vidx + 1 

		# Are we still in the middle
		if (vidx2 in arr) {
			v = integer(arr[vidx])
			v2 = integer(arr[vidx2])
			vstep = (v2 - v)/smooth
			for (i = 0; i<smooth; i++) {
				v += vstep
				r += msgGet(msg,ch,v)
				r.length += 5
			}
		}
	}
	newph = scaleng(r, dur)
	return (newph)
}


#



function initConMap (clear) {
	if (!defined(ConInc)) { 
		ConInc = 1
	}
	
	if ((nargs()>0) || (!defined(ConChan))) {
		ConChan = []
		for (con in MsgMap) {
			vals = []
			ConChan[con] = vals
		}

		for (con in PatCons) {
			ConChan[con] = vals
		}
	}
}

