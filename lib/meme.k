#
# Some routines which maintain "memes" - little musical programs.
# (Idea courtesy of Tim Perkis).  A meme is an ordered set
# of instructions.  Each instruction is an invocation of a function.
# The function takes as input the current "state", and returns
# a phrase that gets added to the final output of the program.
#
# The current state is contained in the global array Mstate,
# which is just an associative array that the instructions
# can use any way they like.
#
# The return value of an instruction is either '' (meaning that it
# may have changed the Mstate, but it doesn't have any new output
# to generate), or it is a phrase value which gets merged into
# the generated output of the program.
#
# By convention, the functions that are used as instructions
# are named op_*.  The current set of instructions is:
#
#     op_pinc - adjusts pitch
#     op_tinc - adjusts time
#     op_vinc - adjusts velocity
#     op_vset - sets velocity
#     op_dinc - adjusts duration
#     op_dset - sets duration
#     op_trig - triggers playing of the current note/chord
#
# meme_gen() generates a new "meme" program
# randomly, using the Meme_ops array.  The initialization
# of the Meme_ops array determines the frequency of various
# instructions - if you want an instruction to be used more
# often, include more instances of it in Meme_ops.
#
# meme_eval() takes a meme and runs it, generating a phrase.
# The initial contents of Mstate is hard-coded in meme_eval.
#
# mem_mate() takes two memes and mates them, either using
# a specified mating function, or choosing one
# of the available mating functions randomly.
# To add a new mating style, just add a function
# to the Matings array in meme_init.

global Meme
global Matings

function op_pinc(arg) {
	Mstate["pitch"] += arg
	return('')
}
function op_vinc(arg) {
	Mstate["vol"] += arg
	return('')
}
function op_vset(arg) {
	Mstate["vol"] = arg
	return('')
}
function op_tinc(arg) {
	Mstate["time"] += arg
	return('')
}
function op_dinc(arg) {
	Mstate["dur"] += arg
	return('')
}
function op_dset(arg) {
	Mstate["dur"] = arg
	return('')
}
function op_trig(arg) {
	nt = makenote(Mstate["pitch"],Mstate["dur"],Mstate["vol"])
	nt.time = Mstate["time"]
	return(nt)
}

function meme_fromphrase(p) {
	Mstate = [
		"pitch" = 'a'.pitch,
		"time" = 0,
		"dur" = 1b,
		"vol" = 'a'.vol
	]
	p = onlynotes(p)
	m = []
	usevset = 1
	usedset = 1
	for ( n in p ) {
		m[sizeof(m)] = ["func"="pinc","args"=(n.pitch - Mstate["pitch"])]
		m[sizeof(m)] = ["func"="tinc","args"=(n.time - Mstate["time"])]

		if ( usedset )
			m[sizeof(m)] = ["func"="dset","args"=n.dur]
		else
			m[sizeof(m)] = ["func"="dinc","args"=(n.dur - Mstate["dur"])]

		if ( usevset )
			m[sizeof(m)] = ["func"="vset","args"=n.vol]
		else
			m[sizeof(m)] = ["func"="vinc","args"=(n.vol - Mstate["vol"])]

		m[sizeof(m)] = ["func"="trig","args"=""]
		Mstate = [
			"pitch" = n.pitch,
			"time" = n.time,
			"dur" = n.dur,
			"vol" = n.vol
		]
	}
	return(m)
}

function meme_newop(f,args) {
	if ( nargs() < 2 )
		args = ""
	Meme_ops[sizeof(Meme_ops)] = ["func"=f,"args"=args]
}
function meme_newmate(f,nm) {
	if ( nargs() < 2 )
		nm = ""
	Matings[sizeof(Matings)] = ["func"=f,"name"=nm]
}
function meme_add(m,inst) {
	sz = sizeof(m)
	m[sz] = inst
}

function meme_gen(ninst) {
	if ( narg < 1 ) 
		ninst = 10
	m = []
	for ( n=0; n < ninst; n++ ) {
		# pick one of ops
		opn = rand(sizeof(Meme_ops))
		meme_add(m,Meme_ops[opn])
	}
	return(m)
}

function meme_eval(m) {
	Mstate = [
		"pitch" = 'a'.pitch,
		"time" = 0,
		"dur" = 1b,
		"vol" = 'a'.vol
	]
	s = ""
	Meme = ''
	for ( n=0; n in m; n++ ) {
		s = "Meme |= op_"+m[n]["func"]+"("+string(m[n]["args"])+");"
		eval s
	}
	Meme.length = latest(Meme)
	return(Meme)
}
	
function meme_print(m) {
	for ( n=0; n in m; n++ ) {
		print( "op_",m[n]["func"],"(",m[n]["args"],");")
	}
	printf("\n")
}
	
function mt(n) {
	if ( nargs() < 1 )
		n = 10
	meme_init()
	m = meme_gen(n)
	p = meme_eval(m)
	meme_print(m)
	realmidi(p)
}

function meme_mate(m1,m2,mtype) {
	if ( mtype < 0 )
		mtype = rand(sizeof(Matings))
	mf = Matings[mtype]["func"]
	return( mf(m1,m2) )
}

# Take the first half of m1 and the second half of m2
function meme_mate_1(m1,m2) {
	sz1 = sizeof(m1)
	sz2 = sizeof(m2)
	mid1 = sz1/2
	mid2 = sz2/2
	m3 = []
	m3n = 0
	for ( n=0; n<mid1; n++ ) {
		m3[m3n++] = m1[n]
	}
	for ( n=mid2; n<sz2; n++ ) {
		m3[m3n++] = m2[n]
	}
	return(m3)
}

# Take the first have of m1, the first half m2, then the second half of each
# The result is twice as long as the originals
function meme_mate_2(m1,m2) {
	sz1 = sizeof(m1)
	sz2 = sizeof(m2)
	mid1 = sz1/2
	mid2 = sz2/2
	m3 = []
	m3n = 0
	for ( n=0; n<mid1; n++ ) {
		m3[m3n++] = m1[n]
	}
	for ( n=0; n<mid2; n++ ) {
		m3[m3n++] = m2[n]
	}
	for ( n=mid1; n<sz1; n++ ) {
		m3[m3n++] = m1[n]
	}
	for ( n=mid2; n<sz2; n++ ) {
		m3[m3n++] = m2[n]
	}
	return(m3)
}

# Take the middle half of m1, and the rest (first and last part) of m2
function meme_mate_3(m1,m2) {
	sz1 = sizeof(m1)
	sz2 = sizeof(m2)
	mid1a = sz1/4
	mid1b = 3*sz1/4
	mid2a = sz2/4
	mid2b = 3*sz2/4
	m3 = []
	m3n = 0
	for ( n=0; n<mid2a; n++ ) {
		m3[m3n++] = m2[n]
	}
	for ( n=mid1a; n<mid1b; n++ ) {
		m3[m3n++] = m1[n]
	}
	for ( n=mid2b; n<sz2; n++ ) {
		m3[m3n++] = m2[n]
	}
	return(m3)
}

# One-time initialization of meme things.

function meme_init() {
	# Generate table of ops
	Meme_ops = []

	meme_newop( "pinc","3")
	meme_newop( "pinc","-3")
	meme_newop( "pinc","7")
	meme_newop( "pinc","-7")
	meme_newop( "pinc","12")
	meme_newop( "pinc","-12")

	meme_newop( "tinc","1b/8")
	meme_newop( "tinc","1b/4")
	meme_newop( "tinc","1b/8")
	meme_newop( "tinc","1b/2")

	meme_newop( "vinc","5")
	meme_newop( "vinc","-5")
	meme_newop( "vinc","10")
	meme_newop( "vinc","-10")
	meme_newop( "vset","100")
	meme_newop( "vset","80")

	meme_newop( "dinc","24")
	meme_newop( "dinc","-24")

	meme_newop( "trig")
	meme_newop( "trig")
	meme_newop( "trig")
	meme_newop( "trig")

	Matings = []
	meme_newmate(meme_mate_1,"h1/h2")
	meme_newmate(meme_mate_2,"h1/h2/h1/h2")
	meme_newmate(meme_mate_3,"h1/h2/h1")
}

