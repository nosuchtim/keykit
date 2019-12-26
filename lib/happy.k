
# Happy Feet - Tim's Woodstockhausen 2002 piece
#

function initialcontrollers {
	for ( c=1; c<=16; c++ ) {
		p = controller(c,0x07,100)	# volume
		realmidi(p)
		p = controller(c,0x0b,100)	# expression
		realmidi(p)
	}
}
function autohappy(...) {
	while ( 1 ) {
		happy(...)
		rereadlib()
	}
}

# Create a noteset from joy music (i.e. arr)
function setsfromjoy(arr) {
	riffsets = []
	nsets = integer((sizeof(arr)+7) / 8)
	ai = 0
	arrsz = sizeof(arr)
	for ( n=0; n<nsets ; n++ ) {
		riffsets[n] = []
		for ( i=0; i<8; i++ ) {
			if ( ai < arrsz )
				riffsets[n][i] = arr[ai++]
			else
				riffsets[n][i] = arr[arrsz-1]
		}
	}
# print("setsfromjoy, size = ",sizeof(riffsets))
	return(riffsets)
}

function happy(...) {
	happyfeet(...)
}
function oldhappyfeet() {


	happyfoot(42)

	p = arr42[70]
	p = echo(p,16,2*1b/2)
	realtime(p)

	happyfoot(53)	# short ones, short sequence

	happyfoot(52)

	happyfoot(62)

}
function happyfeet(fn) {

	print("HAPPYFEET start")
	joymapinit()

print("nargs=",nargs())
	if ( nargs() == 0 ) {
		fn = "joy6.mid"
		joymid = readmf(fn)
	} else {
		fn = "c:\\midi\\"+fn
		joymid = readmf(fn)
		joymid = onlynotes(joymid)
		joymid = step(joymid,1b/16)
	}
	print("fn=",fn)

	arr42 = splitonstarts(joymid,3b,0)

	padmon = new padmonitor()

	rhythmsets = happy_rhythmsets6()
	psets = [
		0 = happy_patchset6_rhythmic(),
		1 = happy_patchset6_bass(),
		2 = happy_patchset6_light(),
		3 = happy_patchset6_rhythmic()
		]
	# dpsets = happy_drumsets6()
	dpsets = happy_drumsets6soft()

	r = "X"
	while ( r != "SQUARE" ) {
	
	print("TOP OF LOOP R = ",r)

	# if ( r == "DOWN" ) {
	# 	# 4a with 6b splits
	# 	print("Happy 4a, 6b")
	# 	arr1 = splitonstarts(joymid,6b,0)
	# 	arrgood = []
	# 	r = happydo(global(happy4a),padmon,arr1,arrgood)
	# 	continue
	# }

## PART ONE

	if ( r == "X" ) {

		print("::::: ")
		print("ONE")
		print("::::: ")

		realtime(resetall())
		realtime(ano())

		p1 = ''
		for ( ccc=1; ccc<=8; ccc++ ) {
			p1 += patchnamed("Piano",ccc)
		}
		realtime(p1)

		initialcontrollers()

		# 4a with 3b splits
		arrgood = [
			0 = 0,
			1 = 8,
			2 = 24,
			3 = 28,
			4 = 40,
			5 = 44,
			6 = 54,
			7 = 69
			]

		r = happydo(global(happy4a),padmon,arr42,arrgood)
		if ( r == 0 )
			r = "CIRCLE"
		continue
	}

	if ( r == "UP" ) {
		p = arr42[70]
		p = echo(p,16,2*1b/2)
		realtime(p)
		r = "CIRCLE"
		continue
	}

## PART TWO

	if ( r == "CIRCLE" ) {
		print(":::::::  ::::::::")
		print(":::::::  TWO")
		print(":::::::  ::::::::")
		arr1 = splitonstarts(joymid,0,3)
		arrgood = [
			0 = 0,
			1 = 128,
			2 = 224,
			3 = 240
			]
		patchstarts = [
			0 = 4,	# Dyno-E.Piano
			1 = 0,	# picked bass
			2 = 0,	# Mondo'Rimba
			3 = 2,	# pot covers

			4 = 0,	# Mondo'Rimba
			5 = 3,	# Marimba
			6 = 0,	# Picked Bass
			7 = 5	# Nylon Guitar
			]
		psets5a = [
			0 = happy_patchset6_rhythmic(),
			1 = happy_patchset6_bass(),
			2 = happy_patchset6_light(),
			3 = happy_patchset6_light(),
			4 = happy_patchset6_light(),
			5 = happy_patchset6_rhythmic(),
			6 = happy_patchset6_bass(),
			7 = happy_patchset6_rhythmic()
			]
print("SIZEOF arr1 = ",sizeof(arr1))
		r = happydo(global(happy5a),padmon,
				arr1,psets5a,dpsets,arrgood,patchstarts,"X")
		print("RETURN FROM 5a (CIRCLE) is ",r)
		if ( r == 0 )
			r = "LEFT"
		continue
	}

## PART THREE

	if ( r == "LEFT" ) {
		print(":::::::  ::::::::  ::::::::")
		print(":::::::  ::::::::  THREE")
		print(":::::::  ::::::::  ::::::::")
		# arr1 = splitonstarts(joymid,0,8)
		arr1 = splitonstarts(joymid,3b,0)
		arrgood = [
			0 = 0,
			1 = 40
			]
		patchstarts = [
			0 = 4,	# Dyno-E.Piano
			1 = 3,	# Punctured BASS
			2 = 8,	# Snappy Clav
			3 = 9,	# Glockenspielc 
			4 = 1,	# Finger Pickin'
			5 = 2,	# Pot Covers
			6 = 3,	# Marimba 
			7 = 1	# Pop Bottle
			]
		psets5a2 = [
			0 = happy_patchset6_rhythmic(),
			1 = happy_patchset6_bass(),
			2 = happy_patchset6_rhythmic(),
			3 = happy_patchset6_light(),

			4 = happy_patchset6_rhythmic(),
			5 = happy_patchset6_light(),
			6 = happy_patchset6_rhythmic(),
			7 = happy_patchset6_light()
			]
		r = happydo(global(happy5a),padmon,
				arr1,psets5a2,dpsets,arrgood,patchstarts,"X")
		if ( r == 0 )
			r = "RIGHT"
		continue
	}

## PART FOUR

	if ( r == "RIGHT" ) {
		print("Happy 6a, 3b")
		arr = splitonstarts(joymid,3b,0)
		riffsets = setsfromjoy(arr)

		print("PLAYING arr[0]")
		aa = splitonstarts(arr[0],0,4)
		p = step(aa[0],1b/4)
		p = echo(p,8,1b,0.9)
print("PART FOUR STARTS, p=",p)
		realtime(p)

		patchstarts = [
			0 = 3,	# 7,	# Aftermath
			1 = 2,	# 1,	# Pull Me Please
			2 = 6,	# Koto
			3 = 2, 	# 3	# Pot Covers

			4 = 1,	# Finger Pickin'
			5 = 2,	# Pot Covers
			6 = 3,	# Marimba 
			7 = 1	# Pop Bottle
			]
		psets6 = [
			0 = happy_patchset6_rhythmic(),
			1 = happy_patchset6_bass(),
			2 = happy_patchset6_rhythmic(),
			3 = happy_patchset6_light(),
			4 = happy_patchset6_rhythmic(),
			5 = happy_patchset6_light(),
			6 = happy_patchset6_rhythmic(),
			7 = happy_patchset6_light()
			]
		r = happydo(global(happy6a),padmon,
			rhythmsets,riffsets,psets6,riffsets,dpsets,patchstarts)
		if ( r == 0 )
			r = "TRIANGLE"
		continue
	}

## ENDING

	if ( r == "TRIANGLE" ) {

		# THIS IS THE ENDING

		realtime(ano())
		HappyEnding = arr42[70]
		p = happyend()
		realtime(p)
		r = "X"		# Ready to start again
		continue
	}


	if ( r == "DOWN" ) {
		print("Happy 6a, 6b")
		arr = splitonstarts(joymid,6b,0)
		riffsets = setsfromjoy(arr)
		r = happydo(global(happy6a),padmon,
			rhythmsets,riffsets,psets,riffsets,dpsets)
		continue
	}

	}
	deleteobject(padmon)
	return(r)
}

function happyend() {
	p = HappyEnding
	p.dur = 1b/4
	p.length=1b
	p.vol += 50

	p0a = echo(p,8,1b/4,1.0)
	p0a.length = 2b
	p0 = echo(p,32,1b/4,0.96)
	p0 = slowdown(p0)
	p0 = cut(p0,CUT_TIME,0,6b)
	p0.length = latest(p0)
	p0r = reverse(echo(p,16,1b/8,0.93))
	return(p0+p0r)

	p0 = echo(p,8,1b/8,0.95)
	p0.length = 1b
	p1 = echo(p,8,1b/4,0.95)
	p1.length = 2b
	p2 = echo(p,8,1b/2,0.95)
	p2.length = 4b
	p3 = echo(p,16,1b,0.90)
	p3.length = 4b
	p = p0+p1+p2+p3
	return(p)
}

function happydo(f,padmon,...) {
	h = new f(...)
	h.start(padmon)
	r = h.run()
	deleteobject(h)
	return(r)
}

##############################################

class happybase {
method init() {
	$.waittid = task $.do()
	$.playtid = -1
	$.r = 0
	$.njoy = sizeof(JoyNames)
	ai = 0
	$.padmon = $0

	$.selecting = []
	$.selecting2 = []
	$.selecting2count = []
	$.selecting4 = []
	$.starting = []
	$.starting2 = []
	$.starting2count = []
	$.starting4 = []
	for ( n=0; n<$.njoy; n++ ) {
		$.selecting[n] = 0
		$.selecting2[n] = 0
		$.selecting2count[n] = 0
		$.selecting4[n] = 0
		$.starting[n] = 0
		$.starting2[n] = 0
		$.starting2count[n] = 0
		$.starting4[n] = 0
	}
	$.retrigger = 1
}
method do { while (1) { sleeptill(Now+2b) } }
method start(padmon) {
	$.padmon = padmon
	$.padmon.notify($$)
}
method finish(r) {
	$$.stop()
	$.padmon.notify($0)
	$.r = r
	kill($.waittid)
}
method run {
	wait($.waittid)
	return($.r)
}
method padchanged(j,b,v) {
	realj = JoyMap[j]

	if ( $.selecting[realj] ) {
		if ( v == 0 ) return()

		$.selecting[realj] = 0

		if ( b == "SELECT" ) {
			$.selecting2[realj] = 1
			$.selecting2count[realj] = 2
			return()
		}
print("padchanged, realj=",realj," calling selectit")
		$$.selectit(realj,b,v)
		return()
	}

	if ( $.selecting2[realj] ) {
		if ( v == 0 ) return()

		if ( b == "SELECT" ) {
			# Stay in selecting 2 mode, but count
			$.selecting2count[realj]++
			if ( $.selecting2count[realj] > 3 ) {
				$.selecting2[realj] = 0
				$.selecting4[realj] = 1
			}
			return()
		}

		$.selecting2[realj] = 0

print("padchanged, realj=",realj," calling selectit2")
		$$.selectit2(realj,b,v)
		return()
	}
	if ( $.selecting4[realj] ) {
		if ( v == 0 ) return()

		if ( b == "START" )
			return()
		if ( b == "SELECT" )
			return()

		$.selecting4[realj] = 0
		$.finish(b)
		return()
	}


	if ( $.starting[realj] ) {
		if ( v == 0 ) return()

		$.starting[realj] = 0

		if ( b == "START" ) {
			$.starting2[realj] = 1
			$.starting2count[realj] = 2
			return()
		}

		$$.startit(realj,b,v)
		return()
	}
	if ( $.starting2[realj] ) {
		if ( v == 0 ) return()

		if ( b == "START" ) {
			# Stay in starting 2 mode, but count
			$.starting2count[realj]++
			if ( $.starting2count[realj] > 3 ) {
				$.starting2[realj] = 0
				$.starting4[realj] = 1
			}
			return()
		}
		if ( b == "SELECT" )
			return()

		$.starting2[realj] = 0

		$$.startit2(realj,b,v)
		return()
	}

	if ( $.starting4[realj] ) {
		if ( v == 0 ) return()

		if ( b == "START" )
			return()
		if ( b == "SELECT" )
			return()

		$.starting4[realj] = 0
		$.finish(b)
		return()
	}


	if ( b == "START" ) {
		if ( v == 0 ) {
			return()
		}
		$.starting[realj] = 1
		$.selecting[realj] = 0
	} else if ( b == "SELECT" ) {
		if ( v == 0 ) {
			return()
		}
		$.selecting[realj] = 1
		$.starting[realj] = 0
	} else {
		$$.playit(realj,b,v)
	}
}
method playthis(p,tm) {
	if ( $$.retrigger && $.playtid > 0 )
		kill($.playtid)
	$.playtid = realtime(p,tm)
}
method playit(j,b,v) {
	if ( v == 1 ) {
		$$.playon(j,b)
	} else {
		$$.playoff(j,b)
	}
}
method selectit(j,b,v) {
	print("selectit wasn't overridden?")
	return(0)
}
method selectit2(j,b,v) {
	# if ( b == "TRIANGLE" ) {
	# 	return(1)
	# }
	return(0)
}
method startit(j,b,v) {
	print("startit wasn't overridden?")
	return(0)
}
method startit2(j,b,v) {
	print("startit2 wasn't overridden?")
	return(0)
}
method stop() {
	print("stop wasn't overridden?")
}
method playon(j,b) {
	print("playon wasn't overridden?")
}
method playoff(j,b) {
}
}

##############################################

class padplayer4 {
method init(j,rhythmsets) {
	$.ch = j+1
	$.rhythmsets = rhythmsets
	$.pad = []
	for ( nm in padbuttons() ) {
		$.pad[nm] = ''
	}
	$.tid = -1
	$.repeat = 6			# INITIAL # of REPEATS
	$.playquant = 1b
	$.stepquant = 1b/4
	$.autocycle = 0
	$.rhythmset = 0
	$.arrsize = 16	# minimum size
	$.voladjust = 0
}
method louder {
	$.voladjust += 10
}
method softer {
	$.voladjust -= 10
}
method setrhythmset(n) {
	$.rhythmset = 0
	print("RHYTHMSET=",$.rhythmset)
	$.setpad()
}
method nextrhythmset(n) {
	$.rhythmset++
	if ( ! ($.rhythmset in $.rhythmsets) )
		$.rhythmset = 0
	print("RHYTHMSET=",$.rhythmset)
	$.setpad()
}
method setrepeat(n) {
	$.repeat = n
}
method repeatless() {
	if ( $.repeat == 1 )
		$.repeat = 0
	else
		$.repeat /= 2
print("Repeat is now ",$.repeat)
}
method repeatmore() {
	$.repeat *= 2
print("Repeat is now ",$.repeat)
}
method togglecycle(n) {
	$.autocycle = 1 - $.autocycle
}
method set(p) {

	# Split phrase up into the individual starts,
	# and assign to $.arr

	$.arr = splitonstarts(p,0,1)
	for ( i=0; i<$.arrsize; i++ ) {
		if ( ! ( i in $.arr ) )
			$.arr[i] = ''
		else {
			p = $.arr[i]
			p.chan = $.ch
			p.dur = $.stepquant
			p.length = $.stepquant
			$.arr[i] = p
		}
	}
	$.setpad()
}
method apply(offset,riff) {
	i = offset
	r = ''
	if ( ! (offset in $.arr) ) {
		print("Warning, nothing to apply?")
		return('')
	}
	for ( n in riff ) {
		if ( ! (i in $.arr) ) {
			i = offset
		}
		p = $.arr[i]
		p.dur = n.dur
		p.time = n.time
		p.length = n.length
		r |= p
		i++
	}
	return(r)
}
method setpad {
	rset = $.rhythmsets[$.rhythmset]
	$.pad = []

	$.pad["X"] =		$.apply(0,rset[0])
	$.pad["UP"] =		$.apply(1,rset[1])
	$.pad["CIRCLE"] =	$.apply(1,rset[2])
	$.pad["LEFT"] =		$.apply(0,rset[3])
	$.pad["RIGHT"] =	$.apply(0,rset[4])
	$.pad["TRIANGLE"] =	$.apply(1,rset[5])
	$.pad["DOWN"] =		$.apply(1,rset[6])
	$.pad["SQUARE"] =	$.apply(0,rset[7])
}
method cycle {
	t = $.arr[0]
	$.arr[0] = $.arr[1]
	$.arr[1] = $.arr[2]
	$.arr[2] = $.arr[3]
	$.arr[3] = t
	$.setpad()
}
method play(b) {
	if ( b in $.pad ) {
		p = $.pad[b]
		if ( $.repeat > 1 ) {
			if ( $.repeat <= 4 )
				fact = 0.85
			if ( $.repeat <= 6 )
				fact = 0.88
			else if ( $.repeat <= 8 )
				fact = 0.9
			else if ( $.repeat <= 12 )
				fact = 0.92
			else if ( $.repeat <= 16 )
				fact = 0.95
			else 
				fact = 0.98
			p = echo(p,$.repeat,p.length,fact)
		}
		p.vol += $.voladjust
		tm = nextquant(Now,$.playquant)
		task $.playat(p,tm)
		if ( $.autocycle )
			$.cycle()
	}
}
method playat(p,tm) {
	sleeptill(tm-2)
	lock($)
	if ( $.tid != -1 ) {
		kill($.tid)
		$.tid = -1
	}
	$.tid = realtime(p,tm)
	unlock($)
}
method stop {
	kill($.tid)
}
}

class happy4a {
method init(arr,arrgood) {
	$.inherit(new happybase())
print("happy4a start")
	$.arr = arr
	$.arrsize = sizeof(arr)
	$.arrgood = arrgood
	$.arrgoodindex = 0
	$.arrpos = 0
	$.player = []
	$.njoy = sizeof(JoyNames)
	for ( j=0; j<$.njoy; j++ ) {
		$.player[j] = new padplayer4(j,happy_rhythmsets4())
		$.player[j].setrepeat(6)
	}
	$.advance()
}

method stop {
	print("METHOD STOP in 4a")
	for ( j in $.player ) {
		$.player[j].stop()
	}
	print("END OF METHOD STOP in 4a")
}
method advance {
	if ( sizeof($.arrgood) > 0 ) {
		if ( ! ( $.arrgoodindex in $.arrgood ) ) {
			print("Calling finish")
			# $.player[j].set('')
			lock($)
			$.finish(0)
			unlock($)
			return()
		}
		$.arrpos = $.arrgood[$.arrgoodindex++]
	}
print("ADVANCE CALLED arrpos=",$.arrpos);
	for ( j=0; j<$.njoy; j++ ) {
		if ( $.arrpos in $.arr ) {
			p = $.arr[$.arrpos++]
			$.player[j].set(p)
		} else if ( sizeof($.arrgood) > 0 ) {
			p = $.arr[$.arrgood[sizeof($.arrgood)-1]]
			$.player[j].set(p)
		} else {
			print("Ran off the end of the 4a array... arrpos=",$.arrpos)
			print("Calling finish")
			# $.player[j].set('')
			lock($)
			$.finish(0)
			unlock($)
			return()
		}
	}
}

method playon(j,b) {
	# Okay, it's one of the 3 "channel" pads
	if ( j in $.player ) {
		$.player[j].play(b);
	}
}
method playoff(j,b) {
}

method startit(j,b,v) {
	# if ( b == "X" ) {
	# 	return(1);
	# }
	if ( b == "SQUARE" ) {
		$.player[j].louder()
	} else if ( b == "TRIANGLE" ) {
		$.player[j].softer()
	}
	return(0)
}
method selectit(j,b,v) {
	if ( b == "CIRCLE" ) {
	} else if ( b == "UP" ) {
		$.player[j].repeatmore()
	} else if ( b == "DOWN" ) {
		$.player[j].repeatless()
	} else if ( b == "SQUARE" ) {
		$.player[j].patchchangetype()
	} else if ( b == "LEFT" ) {
		for ( j in $.player ) {
			$.player[j].togglecycle()
		}
	} else if ( b == "X" ) {
		for ( j in $.player ) {
			$.player[j].nextrhythmset()
		}
	} else if ( b == "TRIANGLE" ) {
		$.advance()
	}
	return(0)
}

method selectit2(j,b,v) {
	if ( b == "X" ) {
		# reset rhythm
		for ( j in $.player ) {
			$.player[j].setrhythmset(0)
		}
	} else if ( b == "TRIANGLE" ) {
		$.advance()
	}
	return(0)
}

method delete {
	for ( t in $.player ) {
		deleteobject($.player[t])
	}
}
}

##############################################
class padplayer5 {
method init(j,patchsets,drumsets,initpatchtype,initdrumset) {

	if ( nargs() < 4 )
		initpatchtype = 0
	if ( nargs() < 5 )
		initdrumset = 0
	$.initpatchtype = initpatchtype

	$.patchtype = $.initpatchtype
	$.patchsets = patchsets
	$.patchset = $.patchsets[$.patchtype]

	$.ch = j+1
	$.pad = []
	for ( nm in padbuttons() ) {
		$.pad[nm] = ''
	}
	$.nriffsets = 5

	$.tid = -1
	$.repeat = 4
	$.playquant = 1b
	$.stepquant = 1b/4
	$.drumvolinit = 110

	$.riffset = 0
	$.playingdrums = 0
	$.drumsets = drumsets
	$.drumsetindex = initdrumset
	$.patchindex = 0
	$.octave = 0

	$.voladjust = 0
}
method octaveup {
	$.octave++
}
method octavedown {
	$.octave--
}
method louder {
	$.voladjust += 10
}
method softer {
	$.voladjust -= 10
}
method setrhythmset(n) {
	$.riffset = n
	print("RIFFSET=",$.riffset)
	$.setpad()
}
method nextrhythmset(n) {
	$.riffset++
	if ( $.riffset >= $.nriffsets )
		$.riffset = 0
	print("RIFFSET=",$.riffset)
	$.setpad()
}
method toggledrummode {
	$.playingdrums = 1 - $.playingdrums
	$.riffset = 0
	$.stop()
	$.patchchange(0)
}
method patchreset() {
	$.patchindex = 0
	$.drumsetindex = 0
	$.stop()
	$.patchchange(0)
}
method applymapto(maparr,q) {
	r = ''
	for ( tn in q ) {
		if ( ! ( tn.pitch in maparr ) ) {
			print("Hey, pitch=",tn.pitch," isn't in maparr?")
		} else {
			tn.pitch = maparr[tn.pitch]
		}
		r |= tn
	}
	return(r)
}
method patchchangetype() {
	$.patchtype++
	if ( ! ( $.patchtype in $.patchsets ) ) {
		$.patchtype = 0
	}
	$.patchset = $.patchsets[$.patchtype]
	$.patchindex = 0
	$.patchchange(0)
}
method patchfix(v) {
	if ( $.playingdrums == 0 ) {
		$.patchindex = v
	} else {
		$.drumpatchindex = v
	}
	$.patchchange(0)
}
method patchchange(inc) {
	if ( nargs() < 1 )
		inc = 1
	if ( $.playingdrums == 0 ) {
		$.patchindex += inc
		if ( typeof($.patchset) != "array" ) {
			print("In padplayer5.patchchange, $.patchset isn't an array? ch=",$.ch);
			print("$.patchset=",$.patchset)
			return()
		}
		if ( ! ( $.patchindex in $.patchset ) ) {
			$.patchindex = 0;
		}
		p = patchnamed($.patchset[$.patchindex],$.ch)
		print("Channel ",$.ch," Patch=",$.patchset[$.patchindex])
		$.setpad()
		$.stop()
	} else {
		$.drumsetindex += inc
		if ( ! ( $.drumsetindex in $.drumsets["name"] ) ) {
			$.drumsetindex = 0;
		}
		print("Channel ",$.ch," drumset=",$.drumsets["name"][$.drumsetindex])
		p = patchnamed($.drumsets["name"][$.drumsetindex],$.ch)
		$.remapdrums()
		$.setpad()
		$.stop()
	}
	if ( p != "" )
		realtime(p)
}

method remapdrums() {
	$.drumnotes = $.drumsets["notes"][$.drumsetindex]
print("    $.drumnotes=",$.drumnotes); SnarfDrumnotes = $.drumnotes
	dnotesz = sizeof($.drumnotes)

	# We're going to be changing the arr to match
	# the current drum patch, so create a separate
	# copy of the array
	$.drumarr = arraycopy($.arr)

	# Find the lowest and highest notes in the drumarr.
	# First just get a single phrase with all the drumarr.
	all = ''
	for ( n in $.drumarr ) {
		oneset = $.drumarr[n]
		if ( typeof(oneset) == "phrase" ) {
			all += oneset
		}
	}
	pitchlow = lowest(all)
	pitchhigh = highest(all)
	# create a map which spreads the drum notes from the
	# lowest to the highest notes in the all phrase
	maparr = []
	for ( n=pitchlow; n<=pitchhigh; n++ ) {
		dnum = 1 + dnotesz * (n-pitchlow)/(pitchhigh-pitchlow+1) 
		maparr[n] = ($.drumnotes%dnum).pitch
# print("n=",n," dnum=",dnum," maparr[",n,"] = ",maparr[n])
		}

	# map all the notes
# print("patchchange inc=",inc," before map drumarr = ",$.drumarr)
	for ( n in $.drumarr ) {
		d = $.drumarr[n]
		d= $.applymapto(maparr,d)
		d.vol = $.drumvolinit
		$.drumarr[n] = d
	}
}
method setrepeat(n) {
	$.repeat = n
}
method repeatless() {
	if ( $.repeat <= 1 )
		$.repeat = 0
	else
		$.repeat /= 2
print("Repeat is now ",$.repeat)
}
method repeatmore() {
	if ( $.repeat == 0 )
		$.repeat = 1
	else
		$.repeat *= 2
print("Repeat is now ",$.repeat)
}
method repeatmax() {
	$.repeat = 24
print("Repeat is now ",$.repeat)
}
method repeatmin() {
	$.repeat = 0
print("Repeat is now ",$.repeat)
}
method set(setarr,setarrpos) {

print("set start, setarrpos=",setarrpos)
	# Take things from setarr and copy into $.arr
	$.arr = []
	for ( i=0; i<8; i++ ) {
		if ( ! ( setarrpos in setarr ) )
			$.arr[i] = ''
		else {
			p = setarr[setarrpos++]
			p.chan = $.ch
			$.arr[i] = p
		}
	}
	$.setpad()
	return(setarrpos)
}
method setpad {
	$.pad = []

	if ( $.playingdrums ) {
		arr = $.drumarr
	} else {
		arr = $.arr
	}

	if ( $.riffset == 0 ) {
		$.pad["X"] =		preechorand(arr[0],2,2)
		$.pad["UP"] =		preechorand(arr[1],2,2)
		$.pad["CIRCLE"] =	preechorand(arr[2],2,2)
		$.pad["LEFT"] =		preechorand(arr[3],2,2)
		$.pad["RIGHT"] =	preechorand(arr[4],2,2)
		$.pad["TRIANGLE"] =	preechorand(arr[5],2,2)
		$.pad["DOWN"] =		preechorand(arr[6],2,2)
		$.pad["SQUARE"] =	preechorand(arr[7],2,2)
	}
	else if ( $.riffset == 1 ) {
		$.pad["X"] =		preechorand(arr[0],3,3,100,1)
		$.pad["UP"] =		preechorand(arr[1],3,3,100,1)
		$.pad["CIRCLE"] =	preechorand(arr[2],3,3,100,1)
		$.pad["LEFT"] =		preechorand(arr[3],3,3,100,1)
		$.pad["RIGHT"] =	preechorand(arr[4],3,3,100,1)
		$.pad["TRIANGLE"] =	preechorand(arr[5],3,3,100,1)
		$.pad["DOWN"] =		preechorand(arr[6],3,3,100,1)
		$.pad["SQUARE"] =	preechorand(arr[7],3,3,100,1)
	}
	else if ( $.riffset == 2 ) {
		$.pad["X"] =		preechorand(arr[0],2,4,60,1)
		$.pad["UP"] =		preechorand(arr[1],2,4,60,1)
		$.pad["CIRCLE"] =	preechorand(arr[2],2,4,60,1)
		$.pad["LEFT"] =		preechorand(arr[3],2,4,60,1)
		$.pad["RIGHT"] =	preechorand(arr[4],2,4,60,1)
		$.pad["TRIANGLE"] =	preechorand(arr[5],2,4,60,1)
		$.pad["DOWN"] =		preechorand(arr[6],2,4,60,1)
		$.pad["SQUARE"] =	preechorand(arr[7],2,4,60,1)
	}
	else if ( $.riffset == 3 ) {
		$.pad["X"] =		preechorand(arr[0],1,2,25)
		$.pad["UP"] =		preechorand(arr[1],1,2,25)
		$.pad["CIRCLE"] =	preechorand(arr[2],1,2,25)
		$.pad["LEFT"] =		preechorand(arr[3],1,2,25)
		$.pad["RIGHT"] =	preechorand(arr[4],1,2,25)
		$.pad["TRIANGLE"] =	preechorand(arr[5],1,2,25)
		$.pad["DOWN"] =		preechorand(arr[6],1,2,25)
		$.pad["SQUARE"] =	preechorand(arr[7],1,2,25)

	}
	else if ( $.riffset == 4 ) {
		$.pad["X"] =		chordizerand(preechorand(arr[0],1,1))
		$.pad["UP"] =		chordizerand(preechorand(arr[1],1,1))
		$.pad["CIRCLE"] =	chordizerand(preechorand(arr[2],1,1))
		$.pad["LEFT"] =		chordizerand(preechorand(arr[3],1,1))
		$.pad["RIGHT"] =	chordizerand(preechorand(arr[4],1,1))
		$.pad["TRIANGLE"] =	chordizerand(preechorand(arr[5],1,1))
		$.pad["DOWN"] =		chordizerand(preechorand(arr[6],1,1))
		$.pad["SQUARE"] =	chordizerand(preechorand(arr[7],1,1))
	}
	if ( $.playingdrums ) {
		nhead = 12
		$.pad["X"] = head($.pad["X"],nhead)
		$.pad["UP"] = head($.pad["UP"],nhead)
		$.pad["CIRCLE"] = head($.pad["CIRCLE"],nhead)
		$.pad["LEFT"] = head($.pad["LEFT"],nhead)
		$.pad["RIGHT"] = head($.pad["RIGHT"],nhead)
		$.pad["TRIANGLE"] = head($.pad["TRIANGLE"],nhead)
		$.pad["DOWN"] = head($.pad["DOWN"],nhead)
		$.pad["SQUARE"] = head($.pad["SQUARE"],nhead)
	}
}
method play(b) {
	if ( b in $.pad ) {
		p = $.pad[b]
		if ( $.repeat > 1 ) {
			if ( $.repeat <= 4 )
				fact = 0.85
			else if ( $.repeat <= 8 )
				fact = 0.9
			else if ( $.repeat <= 16 )
				fact = 0.95
			else 
				fact = 0.98
			p = echo(p,$.repeat,p.length,fact)
		}
		tm = nextquant(Now,$.playquant)
		p.vol += $.voladjust
		if ( $.octave != 0 )
			p.pitch += (12*$.octave)
		task $.playat(p,tm)
	}
}
method stop {
	lock($)
	if ( $.tid != -1 ) {
		kill($.tid)
		$.tid = -1
	}
	unlock($)
}
method playat(p,tm) {
	sleeptill(tm-2)
	lock($)
	if ( $.tid != -1 ) {
		kill($.tid)
		$.tid = -1
	}
	$.tid = realtime(p,tm)
	unlock($)
}
}

class happy5a {
method init(arr,patchsets,drumsets,arrgood,patchstarts,firstpad) {

	$.inherit(new happybase())

	$.patchsets = patchsets

	$.drumsets = drumsets
	$.arrgood = arrgood
	$.arrgoodindex = 0
	$.patchstarts = patchstarts

	$.arr = arraycopy(arr)
	$.arrsize = sizeof($.arr)
print("happy5a, arr size = ",sizeof($.arr))
	$.arrpos = 0
	$.player = []
	$.njoy = sizeof(JoyNames)
	for ( j=0; j<$.njoy; j++ ) {
		$.player[j] = new padplayer5(j,patchsets,drumsets,j,j)
	}
	$.advance()
	for ( j=0; j<$.njoy; j++ ) {
		$.player[j].patchfix($.patchstarts[j])
	}
	if ( nargs() >= 6 )
		$.playon(0,firstpad)
}
method stop {
	print("METHOD STOP in 5a")
	for ( j in $.player ) {
		$.player[j].stop()
	}
}

method advance {
print("happy5a, ADVANCE")
	if ( sizeof($.arrgood) > 0 ) {
		if ( ! ( $.arrgoodindex in $.arrgood ) ) {
			print("Calling finish")
			# $.player[j].set('')
			lock($)
			$.stop()
			$.finish(0)
			unlock($)
			return()
		}
		$.arrpos = $.arrgood[$.arrgoodindex++]
	}
	print("Advance, starting at arrpos=",$.arrpos);
	for ( j=0; j<$.njoy; j++ ) {
		if ( $.arrpos in $.arr ) {
			$.arrpos = $.player[j].set($.arr,$.arrpos)
		} else {
			print("Ran off the end of the 5a array... arrpos=",$.arrpos)
			print("Calling finish(0)")
			$.stop()
			$.finish(0)
			# $.player[j].set('')
		}
	}
}

method playon(j,b) {
	# Okay, it's one of the 3 "channel" pads
	if ( j in $.player ) {
		$.player[j].play(b);
	}
}
method playoff(j,b) {
	# Okay, it's one of the 3 "channel" pads
	if ( b == "X" ) {
		return()
	}
}

method startit(j,b,v) {
print("happy5a, startit b=",b)
	# if ( b == "X" ) {
	# 	return(1);
	# }
	if ( b == "X" ) {
		if ( j in $.player ) {
			$.player[j].stop();
		}
	} else if ( b == "SQUARE" ) {
		$.player[j].louder()
	} else if ( b == "TRIANGLE" ) {
		$.player[j].softer()
	} else if ( b == "UP" ) {
		$.player[j].octaveup()
	} else if ( b == "DOWN" ) {
		$.player[j].octavedown()
	}
	return(0)
}
method startit2(j,b,v) {
	if ( b == "X" ) {
		if ( j in $.player ) {
			$.player[j].stop();
		}
	}
	return(0)
}
method selectit(j,b) {
	if ( b == "CIRCLE" ) {
		$.player[j].patchchange()
	} else if ( b == "UP" ) {
		$.player[j].repeatmore()
	} else if ( b == "DOWN" ) {
		$.player[j].repeatless()
	} else if ( b == "SQUARE" ) {
		$.player[j].patchchangetype()
	} else if ( b == "X" ) {
		for ( j in $.player ) {
			$.player[j].nextrhythmset()
		}
	} else if ( b == "TRIANGLE" ) {
		$.advance()
	}
	return(0)
}

method selectit2(j,b) {
	if ( b == "CIRCLE" ) {
print("RESETTING PATCH")
		$.player[j].patchreset()
		$.player[j].patchfix($.patchstarts[j])
	} else if ( b == "X" ) {
		for ( j in $.player ) {
			$.player[j].setrhythmset(0)
		}
	} else if ( b == "LEFT" ) {
		# Change patch mode between normal and drums
		$.player[j].toggledrummode()
	} else if ( b == "UP" ) {
		$.player[j].repeatmax()
	} else if ( b == "DOWN" ) {
		$.player[j].repeatmin()
	}
	return(0)
}

method delete {
print("HAPPY 5a DELETE CALLED! (calling stop from here)")
	$.stop()
	for ( t in $.player ) {
		deleteobject($.player[t])
	}
}
}

##############################################
class happy6a {
method init(rhythmsets,riffsets,patchsetarr,drumriffsets,drumsets,patchstarts) {
	$.inherit(new happybase())
	$.player = []
	$.njoy = sizeof(JoyNames)
	tm = nextquant(Now+4,4b)
	$.autoadvance = 0
	$.patchstarts = patchstarts

	for ( j=0; j<$.njoy; j++ ) {
		$.player[j] = new plexplayer(j+1,tm,$,32,1b/4,
			rhythmsets,
			riffsets,
			patchsetarr,
			drumriffsets,
			drumsets,
			j)	# j is used for initial patch set
		print("j=",j," SETING PATCHFIX = ",$.patchstarts[j])
		$.player[j].patchfix($.patchstarts[j])
		# Defult is now to start with recording (looping) off
		$.player[j].setrecording(0);
	}
}

method stop {
	print("METHOD STOP in 6a")
	for ( j in $.player ) {
		$.player[j].stop()
	}
}
method shiftall(v) {
	for ( j in $.player ) {
		$.player[j].shiftit(v)
	}
}

method playon(j,b) {
	if ( j == "" ) {
		print("Hmm, playon ignores j=blank")
		return()
	}
	if ( j in $.player ) {
		i = joypad_name2index(b)
		$.player[j].playindex(i);
		if ( b == "SQUARE" && $.autoadvance ) {
			for ( a in $.player ) {
				$.player[a].notesetchange()
			}
		}
	}
}
method playoff(j,b) {
}

# Start+<button> does loop-oriented things
method startit(j,b,v) {
	if ( b == "X" ) {
		# $.player[j].backspace()
		$.player[j].clear()
	} else if ( b == "CIRCLE" ) {
		$.player[j].togglerecording()
	} else if ( b == "UP" ) {
		$.player[j].octaveup()
	} else if ( b == "DOWN" ) {
		$.player[j].octavedown()
	} else if ( b == "RIGHT" ) {
		$.player[j].durlonger()
	} else if ( b == "LEFT" ) {
		$.player[j].durshorter()
	} else if ( b == "SQUARE" ) {
		$.player[j].louder()
	} else if ( b == "TRIANGLE" ) {
		$.player[j].softer()
	}
	return(0)
}

# Start+Start+<button> does more advanced loop-oriented things
method startit2(j,b,v) {
# print("startit2 b=",b)
	if ( b == "X" ) {
		# Clear all loops, the reset everything
		for ( jj in $.player ) {
			$.player[jj].clear()
		}
		$.player[j].reset()
		realtime(resetall())
		realtime(ano())
		$.player[j].patchfix($.patchstarts[j])
	} else if ( b == "CIRCLE" ) {
		$.player[j].togglefading()
	} else if ( b == "UP" ) {
		$.player[j].faster()
	} else if ( b == "DOWN" ) {
		$.player[j].slower()
	} else if ( b == "RIGHT" ) {
		$.player[j].longerloop()
	} else if ( b == "LEFT" ) {
		$.player[j].shorterloop()
	}
	return(0)
}

method selectit(j,b,v) {
	if ( b == "CIRCLE" ) {
		$.player[j].patchchange()
	} else if ( b == "X" ) {
		$.player[j].rhythmsetchange()
	} else if ( b == "TRIANGLE" ) {
		# Advance ALL note sets
		for ( a in $.player ) {
			$.player[a].notesetchange()
		}
	} else if ( b == "SQUARE" ) {
		$.player[j].patchchangetype()
	} else if ( b == "LEFT" ) {
		$.player[j].togglearpeggiomode()
	} else if ( b == "UP" ) {
		n = $.player[j].morenotes()
	} else if ( b == "DOWN" ) {
		n = $.player[j].fewernotes()
	} else if ( b == "RIGHT" ) {
		arr = patchmap_rand(j+1)
		p = arr["patch"]
		print("Channel ",j," Patch=",arr["name"])
		realtime(p)
	}
	return(0)
}

method selectit2(j,b,v) {
print("selectit2 b=",b)
	# if ( b == "SQUARE" ) {
	# 	# finish, complete exit
	# 	return(1)
	# }
	if ( b == "X" ) {
		$.player[j].togglerhythmmode()
	} else if ( b == "LEFT" ) {
		# Change patch mode between normal and drums
		$.player[j].toggledrummode()
	} else if ( b == "CIRCLE" ) {
print("RESETTING PATCH")
		$.player[j].patchreset()
		$.player[j].patchfix($.patchstarts[j])
	} else if ( b == "DOWN" ) {
		# Change to pitch shift mode
		# DISABLED - it's too annoying if I accidentally enable it
		# $.player[j].togglepitchshift()
	} else if ( b == "TRIANGLE" ) {
		# finish, and go to next section
		# return(2)
	} else if ( b == "RIGHT" ) {
		# $.autoadvance = 1 - $.autoadvance
	}
	return(0)
}

method delete {
print("HAPPY 6a DELETE CALLED! (calling stop from here)")
	$.stop()
	for ( t in $.player ) {
		deleteobject($.player[t])
	}
}
}

##############################################

class cycleplayer {
method init(loopers) {
	$.loopers = loopers
	$.tm = tm
	$.stopme = 0
	$.tid = task $.playtask()
	$.step = 0
	$.steptm = 1b/4
	$.mute = 0
}
method delete {
	kill($.tid)
	for ( n in $.loopers ) {
		$.loopers[n].setmute(0)
	}
}
method setstep(s) {
	$.step = s
}
method setmute(m) {
	$.mute = m
}
method playtask() {
	tm0 = $.tm
	cnt = 0
	cnt = sizeof($.loopers)
	solo = 0
	while ($.stopme == 0) {
		# Turn on the one we want to solo
		i = 0
		for ( n in $.loopers ) {
			if ( i == solo )
				$.loopers[n].setmute(0)
			i++
		}
		# Turn off the other ones
		i = 0
		for ( n in $.loopers ) {
			if ( i != solo )
				$.loopers[n].setmute(1)
			i++
		}
		sleeptill(Now+1b)
		solo++
		if ( solo >= cnt )
			solo = 0
	}
}
}

##################################################

function preechorand(p,echolikely,necho,percent,echoprestep) {
	if ( nargs() < 4 )
		percent = 100
	if ( nargs() < 5 )
		echoprestep = 1

	if ( ! echoprestep )
		p = step(p,1b/4)

	q = p{rand(echolikely) == 0}
	p -= q
	if ( necho < 3 )
		fact = 0.8
	else
		fact = 0.9
	q = preecho(q,necho,1b/4,fact)
	p |= q

	if ( echoprestep ) {
		p = step(p,1b/4)
	}

	if ( percent < 100 ) {
		p = p { rand(100)<percent }
	}
	return(p)
}
function chordizerand(p) {
	q = p{rand(4) == 0}
	p -= q
	q = chordmel(q,'c',"maj")
	p |= q
	p = step(p,1b/4)
	return(p)
}

