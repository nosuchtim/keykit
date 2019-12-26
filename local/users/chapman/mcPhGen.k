#
# Functions for generating phrases from parameters and sequences
#
#


function scaleng2(ph,lng) {
	if ( nargs() != 2 ) {
		print("usage: scaleng(phrase,length)")
		return('')
	}
	r = ''
	pfactor = lng  / (ph.length * 1.0)

#	sendMsg(lng)
#	sendMsg(ph.length)
#	sendMsg(pfactor)

	if ( ph.length == 0 && sizeof(ph) != 0 ) {
		print("scaleng: a phrase with length=0 can't be scaled")
		return(ph)
	}

	for ( nt in ph ) {
		# scale both time and duration
		np = nt
		
		np.time = pfactor
		np.dur *=  pfactor
		r |= np
	}
	r.length = lng
	return(r)
}



function Part303(pat) {
  ph = ''
  pseq = pat["seq"]
#sendMsg("<")
  for (r = 1; r <= pat["params"]["P2"]; r++) {

    pgen = pat["SeqFN"] (pat, r, varg(pseq[r]))
#    sendMsg(string(pgen) + string(pseq[r]))
    ph += pgen
  }
#sendMsg(">")

  ph.chan = pat["params"]["Chan"]
  ph.pitch += pat["params"]["P1"] 

  ph = chadjust(ph, scaleng('c g a b', ph.length))
  ph = repeat(ph,pat["params"]["Repeat"])    

  if (ph.length!=0) {
    ph = scaleng(ph, pat["params"]["Dur"])
  }

  ph.dur *= pat["params"]["Gate"] 

  return(ph)
}



function Seq303(pat,note,dur,pitch,vol,repcount,p1,p2){
  if (typeof(pitch)=="phrase") {
    ph = pitch  
  } else {  
    ph = 'c'
    ph.pitch = pitch
  }

  if (repcount == 0) {
	repcount = 1
  }

  ph.vol = vol
#  ph = repeat(ph,repcount)
  ph = phPatStutter(ph, repcount, 0.9, 4)

  ph.time /= repcount
  ph.dur /= repcount
  ph.length /= repcount

  s = pat["params"]["Chord"]
  if (s!="") {
    ph.attrib = s
    ph = chseq(ph,s)
    ph = arpeggio(ph)
  } 

  ph = msgGet("p",1,p1) + ph

  return(ph)
}

#sendMsg(cph("p",1,2))



function SeqMix(pat,note,bank,program,vol,filter,rez,lfo,delay) {
 chan=note
#ph = controller(chan,0,81)
#ph += controller(chan,32,bank)
#ph += controller(chan,32,0)
 ph = progchange(program,chan)
 ph += msgGet("v",chan,vol)
 ph += msgGet("fc",chan,filter) + cph("fr",chan,rez) 
# ph.time+=note
# ph.chan=note
  return(ph)
}




function getSeqPatPhrase(p) {
   ph = p["PartFN"](p)
   return(ph)
}





# A group of functions to generate and modify note sequences.

Chins = [
		"major"='p0 p4 p7',
		"minor"='p0 p3 p7',
		"maj7"='p0 p4 p7 p11',
		"min7"='p0 p3 p7 p10',
		"maj9"='p0 p4 p7 p11 p14',
		"min9"='p0 p3 p7 p10 p14',
		"sus"='p0 p5 p7',
		"dim"='p0 p3 p6',
		"aug"='p0 p4 p8',
		"Maj69"='p0 p4 p7 p9',
		"MajB769"='p0 p3 p5 p9 p10',
		"HalfDim"='p0 p3 p6 p10',
		"Dim9"='p0 p3 p6 p9 p14',
		"NModMaj1"='p0 p1 p4 p8',
		"NModMaj2"='p0 p4 p6 p9',
		"NModMaj3"='p0 p1 p3 p6',	
		"NModDom1"='p0 p1 p4 p7',	
		"NModDom2"='p0 p1 p4 p6',
		"NModDom3"='p0 p2 p6 p8',
		"NModDom4"='p0 p5 p8 p11',
		"ArtDim"='p0 p2 p5 p8',
		"AOVoic1"='p0 p7 p10 p12 p17',
		"AOVoic2"='p0 p1 p7 p12 p17',
		"AllMaj"='p0 p2 p5 p7 p11 p16 p21',
		"Res"='p0 p4 p7 p10 p14 p17 p20 p23',
		"Vitr1"='p0 p3 p6 p8 p14 p16 p19 p22',
		"Vitr2"='p0 p3 p5 p9 p13 p16 p19 p23',
		"Fourths"='p0 p6 p11 p17 p22 p28',
		"Pr1"='p0 p2 p3 p5 p7 p11',
		"Pr2"='p0 p3 p5 p7 p11 p13',
		"Pr3"='p0 p5 p7 p11 p13 p14',
		"Pr4"='p0 p3 p5 p7 p11 p14 p17']

i = 0
for (s in Chins) {
	Chins[i] = Chins[s]
	Chins[string(i)] = Chins[s]
	i = i + 1
}




# Change channel
function phCh(ph, chan) {
	ph.chan = chan
	return(ph)
}



# Change channel and change relative duration of notes.
function phChDur(ph, chan, dur) {
	ph.chan = chan
	ph.dur *= dur
	return(ph)
}


function phFadeNum(valueA, valueB, fade) {
	value = valueA + (valueB - valueA) * fade
	#print (valueA ,valueB,fade, value)
	return (value)
}


# Fade from phrase A to phrase B in a number of generations
function phMorph(phA, phB, generations) {
	ph = ''
	fadestep = 1 / (generations - 1.0)
	fade = 0
	for (i=0; i < generations; i++) {
	
		note = 1
		phnew = ''

		for (evA in phA) {
			evB = phB%note
			evnew = evA
			evnew.dur = phFadeNum(evA.dur, evB.dur, fade)
			evnew.vol = phFadeNum(evA.vol, evB.vol, fade)
			phnew += evnew
			note += 1
		}
		ph += phnew
		fade += fadestep
	}
	return (ph)
}



MySnips = [
	"A"='p45,p45',
	"B"=''
]


# Make a pattern from strings 
# "AA  AABB"
# "CC    C "
function phBuild(patstr) {

#	ph = MySnips[sChar]
}


# Apply a volume chop to the phrase
# ie. ph is a drumbeat / melody
#     volstr is "001122440000"
# consider stutter version
function phVolStr(ph, volstr) {
#	for (char in volstr) {
#		# modify vol of notes in ph
#	}
	return (ph)
}




# Over a number of generations slowly build phPat into a whole pattern
# ie phPat is a drum beat
#    phChop is |--------|----     |----   --|
#    
function phChop(phPat, phChop) {
	
}




# Chop notes up into repeated sections.
# decay each repetition by decay amount. 
# <1 is fade out.  1 is no decay.  >1 is fade in.
function phStutter(ph, rate, decay) {

	phnew = ''
	rate *= 1.0

	for (ev in ph) {

		evnew = 'c'
		evnew.vol = ev.vol
		evnew.pitch = ev.pitch
		evnew.chan = ev.chan
		d = ev.dur
		evnew.dur = d / rate
		d = ev.dur
#	print(ev.dur, ev.length)
		evnew.length = d / rate

		for (i=0; i < rate; i++) {
			phnew += evnew
			evnew.vol *= decay
		}
	}

	return (phnew)	
}


PatStutter = []
PatStutter[1] = 'cd24v127,cd24,cd48'
PatStutter[2] = 'cd24v127,cd48'
PatStutter[3] = 'cd24v127,cd24,cd48'
PatStutter[4] = repeat('cv127,cd48,cv0',2)


PhStepperMap=[
	"a"=[0=1b/4,1=1b/2,2=1b,3=2b,4=4b,5=6b,6=8b,7=10b,8=12b,9=16b],
	"d"=[0='p34',1='p35',2='p55',3='p45',4='p33',5='p62',6='p86',7='p74',8='p23',9='p65']
]

function phStepper(dursteps,volsteps,pitchsteps,repsteps) {
  ph = ''
  durmap = PhStepperMap["a"]
  pitchmap = PhStepperMap["d"]
#   sendMsg(dursteps)
  for (i=1;i<6;i++) {
    # Look up in mapping array or 
    dur = durmap[integer(substr(dursteps,i,1))]
    vol = integer(substr(volsteps,i,1)) * 12
#    pitch = integer(substr(pitchsteps,i,1)) - 5
    pitch = pitchmap[integer((substr(pitchsteps,i,1)))]
    rep = integer((substr(repsteps,i,1)))

    ev = pitch
    ev = scaleng(repeat(ev,rep), dur)
    ev.vol = vol
    ph += ev
  }
  return(ph)
}

#ph=phStepper("22522","865865","12891","12342")
#ph.chan=10
#sendMsg(ph)
#realtime(ph)


# Chop notes up into little patterns using the PatStutter (TM) library.
# decay each repetition by decay amount. 
# <1 is fade out.  1 is no decay.  >1 is fade in.
function phPatStutter(ph, rate, decay, pattern) {

	phnew = ''
	rate *= 1.0

	for (ev in ph) {

		evnew = PatStutter[pattern]
		evnew.vol *= (ev.vol/127.0)
		evnew.pitch = ev.pitch 
		evnew.chan = ev.chan
		evnew = scaleng(evnew, rate)

		for (i=0; i < (ev.dur / rate); i++) {
			phnew += evnew
			evnew.vol *= decay
		}
	}

	return (phnew)	
}




function phMake (ph, srcpat) {
	r = ''
	for (n in ph) {
		snipi = gph(srcpat, n.pitch, n.vol)
		snipi = scaleng(snipi, n.dur)
		snipi.time += n.time
		r |= snipi
	}
	r.length = ph.length
	r.dur = ph.dur
	return (r)
}



function struc (ph) {
	r = ''
	for (n in ph) {
		snipi = Arr[n.pitch]
		snipi = cut(snipi,CUT_TIME,0b,n.length,TRUNCATE)
#		snipi = repleng(snipi,n.length)
		snipi.time += n.time
		snipi.chan = n.chan
		r |= snipi
	}
	r = cut(r,CUT_TIME,0b,ph.length,TRUNCATE)
	return (r)
}


function mio (ph,filename) {
	arr = []
	for (i = 1; i < 17; i++ ) {
		arr[i]=cut(ph,CUT_CHANNEL,i) 
	}
	midifile(arr,filename)
}



# Produce a chord sequence from a list of notes
function chseq(ph) {
	r = ''
	for (n in ph) {
		typ = n.attrib
		if ( ! (typ in Chins) ) {
			typ = "major"
		}
		
		ch = Chins[typ]
		ch.pitch += n.pitch
		ch.dur = n.dur
		ch.length = n.length - n.time
		ch.vel = n.vel
		r += ch
	}
	return(r)
}



if (0) {

#A=phMorph('cv120,fv80','cv60,ev120', 4)

A=phPatStutter('cv120,av90d48,d,eo1', 24, 0.9, 4)

#print(A)
#realtime(A)
}


