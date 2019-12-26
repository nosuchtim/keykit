#
# Hoops - Herb's Loops

INCDEC_MID = 0
INCDEC_MIN = -2
INCDEC_MAX = 2
INCDEC_INC = 1
INCDEC_DEC = -1

function hoops1b(fname,timer,t) {

	if ( Machine != "win" ) {
		print("hoops1b() probably only works on Windows, sorry!")
		return()
	}

	if ( nargs() < 1 )
		fname = ""
	if ( nargs() < 2 )
		timer = 0

	# if ( defined(TypoGM) && TypoGM == 1 )
	# 	realmidi(gmresetall(0x40))

	oldMerge = Merge
	Merge = 0

	t = new hoops1b_object(fname)

	t.start(timer)
	t.starttasks()

	j = getjoymonitor()
	j.notify(t,-1)

	print("The hoops are alive...")
	t.waittilldone()

	j.unnotify(t,-1)

	Merge = oldMerge
	print("Hoops done.")
}

class hoops1b_object {

method init(fname) {
	if ( nargs() < 1 )
		fname = ""
	$.always_record = 1
	$.forcefour = 0
	$.debug = 1
	$.tamefractal = 1
	$.defmultiple = 3
	$.transmultiple = $.defmultiple
	$.tid = -1
	$.inputtid = -1
	$.inputf = -1
	$.verbose = 0
	$.maxjoy = 16
	$.consf = -1
	$.nsects = 0
	if ( defined(TypoGM) && TypoGM == 1 )
		$.gm = 1
	else
		$.gm = 0

	$.typo_setup(fname)
}

method setverbose(v) { $.verbose = v }

method delete {
	lock($)
	kill($.tid)
	$.tid = -1
	kill($.inputtid)
	unlock($)
}

method isrunning {
	return($.tid >= 0 )
}
method stop {
	lock($)
	kill($.tid)
	$.tid = -1
	unlock($)
}
method start(timer) {

	lock($)
	kill($.tid)
	$.tid = task $.realtimetask()

	if ( $.verbose )
		print("Hoops away ...  (control-X Q will quit)")

	if ( timer != 0 )
		$.timer = task $.typo_timer()

	$.lr_change_func = []
	$.pad_change_func = []
	$.startdown = []
	$.selectdown = []
	for ( j=0; j<$.maxjoy; j++ ) {
		$.lr_change_func[j] = "lr_change_play"
		$.pad_change_func[j] = "pad_change_play"
		$.startdown[j] = 0
		$.selectdown[j] = 0
	}
	$.inputf = open()
	kill($.inputtid)
	$.inputtid = task $.inputtask($.inputf)
	unlock($)
}

method starttasks { 
	Consecho = 0
	Consupdown = 1
	$.consf = Root.grabconsole()
	$.constid = task $.cons_task($.consf,$.inputf)
	$.miditid = task $.midi_task($.inputf)
	$.pulsetid = 0
}

method waittilldone {
	wait($.inputtid)
	$.final_cleanup()
}

method kill_current_loop {
	for ( c in $.loop_tid ) {
		kill($.loop_tid[c])
		$.loop_tid[c] = -1
	}
}

method final_cleanup {
	print("Saving in last.tp")
	$.typo_dump("last.tp")

	$.kill_current_loop()
	kill($.inputtid)

	# $.joy.unnotify($,-1)
	if ( $.inputf >= 0 ) {
		close($.inputf)
		$.inputf = -1
	}

	$.killrealtime()
	if ( $.consf >= 0 ) {
		kill($.constid)
		kill($.miditid)
		kill($.pulsetid)
		Consupdown = 0
		Consecho = 1
		Root.releaseconsole()
	}
	if ( $.timer >= 0 )
		kill($.timer)
	realtime(ano())
}

method printmode(f) {
	print("\nMODE:  ",f)
	if ( f in $.helpfor ) {
		print($.helpfor[f])
	}
}

method buttonchange(jn,nm,v) {
	changed = 0
	if ( nm == "START" ) {
		if ( v == 0 )
			$.printmode($.pad_change_func[jn])
		$.startdown[jn] = v
		changed = v
	} else if ( nm == "SELECT" ) {
		if ( v == 0 )
			$.printmode($.lr_change_func[jn])
		$.selectdown[jn] = v
		changed = v
	}

	if ( $.startdown[jn] && $.selectdown[jn] && changed ) {
		print("Sending all-notes-off...")
		$.realtime(ano())
		return()
	}
	if ( $.selectdown[jn] && v == 0 ) {
		# should probably unplay any notes playing for the button
		# that just got let up
		print("Should be unplaying something")
		return()
	}

	if ( $.selectdown[jn] && (nm in $.button2lrmode) ) {
		f = $.button2lrmode[nm]
		$.lr_change_func[jn] = f
		$.printmode(f)
		return()
	}

	if ( $.selectdown[jn] && (nm in $.button2padmode) ) {
		f = $.button2padmode[nm]
		$.pad_change_func[jn] = f
		$.printmode(f)
		return()
	}

	if ( nm == "L1" || nm == "L2" || nm == "R1" || nm == "R2" ) {
		if ( jn in $.lr_change_func ) {
			f = $.lr_change_func[jn]
			$.(f)(jn,nm,v)
		}
	} else {
		if ( jn in $.pad_change_func ) {
			f = $.pad_change_func[jn]
			$.(f)(jn,nm,v)
		}
	}
}
method input(...) {
	if ( $.verbose ) {
		print("TYPO input ",...)
	}
	if ( $.inputf >= 0 ) {
		na = nargs()
		for ( n=0; n<na; n++ ) {
			v = argv(n)
			put($.inputf,v)
		}
	}
}

method morenotes {
	ch = $.currloop
	$.nnotes[ch]++
	if ( $.nnotes[ch] > 5 )
		$.nnotes[ch] = 5
}
method lessnotes {
	ch = $.currloop
	$.nnotes[ch]--
	if ( $.nnotes[ch] < 1 )
		$.nnotes[ch] = 1
}
method setnotes(v) {
	ch = $.currloop
	$.nnotes[ch] = v
}
method lr_change_play(jn,nm,v) {
	if ( v )
		vs = "+"
	else
		vs = "-"

	if ( nm == "L1" ) {
		if ( v )
			$.lessnotes()
	} else if ( nm == "R1" ) {
		if ( v )
			$.morenotes()
	} else if ( nm == "L2" ) {
		if ( v )
			$.input("+LEFTARROW")
		else
			$.input("-LEFTARROW")
	} else if ( nm == "R2" ) {
		if ( v )
			$.input("+RIGHTARROW")
		else
			$.input("-RIGHTARROW")
	}
}
method pad_change_play(jn,nm,v) {
	if ( v )
		vs = "+"
	else
		vs = "-"

	if ( nm in $.button2playkey ) {
		k = $.button2playkey[nm][($.joyshift+jn)%3]
		# The initial "P" means it's from a play-only device

		$.input("P"+vs+k)
	}
}
method lr_change_patch(jn,nm,v) {
	if ( v )
		vs = "+"
	else
		vs = "-"

	if ( nm == "L1" ) {
		if ( v && $.currloop > 1 ) {
			$.currloop--
			$.print_chan_line($.currloop,1)
		}
	} else if ( nm == "R1" ) {
		if ( v && $.currloop < 10 ) {
			$.currloop++
			$.print_chan_line($.currloop,1)
		}
	} else if ( nm == "R2" ) {
		if ( v ) 
			$.ctrl_sound("S",0)
	} else if ( nm == "L2" ) {
		if ( v ) 
			$.ctrl_sound("A",0)
	}
}

method pad_change_file(jn,nm,v) {
	# if (v) print("FILE jn=",jn," nm=",nm," v=",v)

	if ( v )
		vs = "+"
	else
		vs = "-"

	if ( nm == "L1" ) {
		if ( v )
			$.lessnotes()
	} else if ( nm == "R1" ) {
		if ( v )
			$.morenotes()
	} else if ( nm == "R2" ) {
	} else if ( nm == "L2" ) {
	} else if ( nm in $.button2playkey ) {
		k = $.button2playkey[nm][($.joyshift+jn)%3]
		# The initial "P" means it's from a play-only device
		$.input("P"+vs+k)
	}
}
method anoforjoy(jn) {
	# Should really send note-off only for things
	# sent by currently-pressed buttons in this joystick
	$.realtime(ano())
}
method lr_change_loop(jn,nm,v) {

	if ( v )
		vs = "+"
	else
		vs = "-"


	if ( nm == "L1" ) {
		if ( v )
			$.input("+BS")
		else
			$.input("-BS")
	} else if ( nm == "L2" ) {
		if ( v )
			$.input("+DEL")
		else
			$.input("-DEL")
	} else if ( nm == "R1" ) {
		if ( v )
			$.input("+SHIFT")
		else
			$.input("-SHIFT")
	} else if ( nm == "R2" ) {
		if ( v )
			$.input("+RETURN")
		else
			$.input("-RETURN")
	}
}
method analogchange(jn,nm,v) {
	# print("ANALOGCHANGE jn=",jn," nm=",nm," v=",v)
}

method realtime(...) {
	return(realtime(...))
}
method realtime_echonotes(...) {
	return(realtime(...))
}

method realtimetask() {

	if ( $.verbose ) {
		print("TYPO realtimetask() start $=",$)
	}

	tm = nextquant(Now,1b)

	checktime = 1b
	$.playprev = 0
	if ( $.verbose )
		print("REALTIMETASK length=",Tp["length"]," Now=",Now," tm=",tm)
	for ( ;; ) {
		t = Now
		while ( (Now+checktime) < (tm-2) ) {
			sleeptill(Now+checktime)
			# If the loop has been cleared, reset
			if ( Tp["length"] == 0 ) {
				tm = nextquant(Now,$.loopquant)
				break
			}
		}
		sleeptill(tm-1b/4)
		if ( $.nextpattern >= 0 ) {
			$.topattern($.nextpattern)
			# $.currloop = 1
			$.nextpattern = -1
		}
		loopleng = Tp["length"]
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
		if ( Tp["length"] != 0 ) {
			Tp["loopstart"] = tm
		}

		ta = Tp["transitions"]
		t = sizeof(Tp["transitions"])
		if ( t > 1 ) {
			$.change_offset(Tp["transitions"][$.transitionpos/$.transmultiple])
			$.transitionpos++
			if ( $.transitionpos >= (t*$.transmultiple) )
				$.transitionpos = 0
		} else {
			$.change_offset(Tp["transitions"][0])
		}

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
}

method play_loop(tm) {
	if ( $.verbose ) {
		print("playloop tm=",tm," $=",$)
	}
	leng = Tp["length"]
	for ( ch=1; ch<=$.chans; ch++ ) {
		p = $.loopphrase[ch]

		t = Tp["tonality"]
		if ( t != 0 ) {
			p = scadjust(p,$.tonalscales[t])
		}

		w = ''
		if ( ch in $.loopphrasewarp ) {
			w = $.loopphrasewarp[ch]
			if ( w != '' ) {
				p = w
			}
		}
		if ( $.loopfade > 0 ) {
			p.vol -= (5 * $.loopfade)
			p -= p{??.vol==0}
			$.loopphrase[ch] = p
		}

		if ( p != '' && $.loopmute[ch] == 0 ) {
			if ( $.looprestep[ch] != 0 ) {
				p = step(p,$.quant)
			}
			# Don't requantize the warped stuff
			if ( w == '' && $.requant[ch] > 1 ) {
				p = quantize(p,$.requant[ch])
			}
			p = cut(p,CUT_TIME,0,leng)
			$.looptask[ch] = $.realtime_echonotes(p,tm)
		}
	}
}

method typoforwardall(ch,arr,pos) {

	# The indicies of tarr will be "Q", "A", "Z", ...
	# The values will be the bits of the phrase

	$.phr[ch] = []
	if ( sizeof(arr) == 0 )
		return()

	$.nletters = sizeof($.keyorder)

	for ( n=1; n<=$.nletters; n++ ) {
		letter = substr($.keyorder,n,1)
		# $.phr[ch][letter] = arr[pos]
		$.phr[ch][letter] = $.next_in_sourcephr(ch)
	}
}

method next_in_sourcephr(ch) {
	arr = $.sourcephr[ch]
	pos = $.sourcepos[ch] + 1
	if ( ! (pos in arr) )
		pos = 0
	if ( ! (pos in arr) )
		return('')
	$.sourcepos[ch] = pos
	return(arr[pos])
}

method prev_in_sourcephr(ch) {
	arr = $.sourcephr[ch]
	pos = $.sourcepos[ch] - 1
	if ( ! (pos in arr) )
		pos = sizeof(arr)-1
	if ( ! (pos in arr ) )
		return('')
	$.sourcepos[ch] = pos
	return(arr[pos])
}

method init_chan(ch,initpatch) {
	$.loopmode[ch] = 0
	$.loopmute[ch] = 0
	$.ctlr[ch] = $.initial_ctlr()
	# if ( initpatch )
	# 	$.sound[ch] = patchmap_bynum(1,ch)	# piano
	$.requant[ch] = 1
	$.octshift[ch] = 0
	$.fractality[ch] = 0
	$.durscale[ch] = 1
	$.velocityinc[ch] = $.defaultvelocityinc
	$.looprestep[ch] = 0

	$.settrack(ch,'')

	$.loopphrasewarp[ch] = ''
}

method settrack(ch,p) {
	$.loopphrase[ch] = p
	if ( Grindertool != $0 && Grindertool != $-1 ) {
		Grindertool.settrack(ch,p)
	}
}

method typo_init(ch) {
	Tp["loopstart"] = 0
	$.init_chan(ch,1)
}

method typo_init_from_phrase(patt,ch,p,minlength,fixedsize) {

	if ( nargs() < 4 )
		minlength = 0
	if ( nargs() < 5 )
		fixedsize = 4

	p.chan = ch
	# arr = split(p)
	arr = splitonstarts(p,minlength,fixedsize)
	for ( i in arr ) {
		arr[i] = strip(arr[i])
	}
	$.phr = $.typo[patt]["phrase"]
	$.sourcephr = $.typo[patt]["sourcephr"]
	$.sourcepos = $.typo[patt]["sourcepos"]
	$.sourcephr[ch] = arr
	$.sourcepos[ch] = -1
	$.typoforwardall(ch,$.sourcephr[ch],$.sourcepos[ch])
}


method killrealtime() {
	lock($)
	kill($.tid)
	$.tid = -1
	for ( ch in $.looptask ) {
		kill($.looptask[ch])
	}
	unlock($)
}

method typo_restart() {
	$.killrealtime()
	# Don't reset $.shiftisdown!
	if ( defined($.initiallength) )
		$.setlength($.initiallength)
	else
		$.setlength(0)
	Tp["loopstart"] = 0
	Tp["transitions"] = [0=0]
	$.transmultiple = $.defmultiple
	for ( c=1; c<=$.chans; c++ ) {
		$.init_chan(c,0)
	}
	$.tid = task $.realtimetask()
}

method dump {
	return ([
		"shiftpolarity" = $.shiftpolarity,
		"typo" = string($.typo) 
		])
}
method restore(st) {
	$.typo = st["typo"]
	$.finish_restore()
}
method force_defaults() {
	# A hack to adjust old default values that are
	# embedded in old *.tp files
	for ( p in $.typo ) {
		a = $.typo[p]["ctlr"]
		for ( c in a ) {
			a[c][0x07] = 70
			a[c][0x0b] = 70
		}
	}
}
method typo_dump(fname) {
	f = open(fname,"w")
# print("Dumping, typo[1][sourcephr]=",$.typo[1]["sourcephr"])
	put(f,"Typo ="+string($.typo))
	close(f)
}

method typo_restore(fname) {
	if ( ! fileisreadable(fname) ) {
		print("Unable to read fname=",fname)
		return()
	}
	eval "#include \""+fname+"\""
	$.typo = arraycopy(Typo)
# print("RESTORING, typo[1][sourcephr]=",$.typo[1]["sourcephr"])
	$.finish_restore()
}
method finish_restore {
	$.force_defaults()
# print("FINISH_RESTORE, typo[0]=",$.typo[0]["sourcephr"])
	for ( n=0; n<$.npatterns; n++ ) {
		$.init_pattern(n)
		$.typo[n]["loopstart"] = 0
		$.typo[n]["loopphrasewarp"] = []
	}
	$.topattern(1)
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

method rescale(patt,ch,sc,nm) {
	$.scales = step(completescale(sc,nm),1b/4)
	$.scales = strip($.scales{??.number>=12})
			| delay(strip($.scales{??.number>=17}),2)
			| delay(strip($.scales{??.number>=15}),4)
	$.scales = step(arpeggio($.scales),1b)
	$.scales = swapnote($.scales)
	$.typo_init_from_phrase(patt,ch,$.scales,0,3)
}

# Each thing assigned to a key gets a chord
method assign_bs(ch,tp) {
	for ( cp=1; ; cp++ ) {
		c = substr($.keyorder,cp,1)
		if ( c == "" )
			break
		p = tp[ch][c]
		
		p2 = onlynotes(bsriff())
		p2a = onlynotes(p2)
		dpitch = p2a%1.pitch - p%1.pitch
		p2.pitch -= dpitch
		p2.chan = p.chan
		p2 = cut(p2,CUT_TIME,0,1b)
		tp[ch][c] = p2
	}
}

# Each thing assigned to a key gets a chord
method assign_inversions(ch,tp) {
	for ( cp=1; ; cp++ ) {
		c = substr($.keyorder,cp,1)
		if ( c == "" )
			break
		p = tp[ch][c]
		
		cn = $.chords[rand(sizeof($.chords))]
		p2 = transpose(chordnamed(cn),p)
		p2 = scadjust(p2,makescale('c,e-,g,b-'))
		p2.chan = p.chan
		p2.vol = p.vol
		p2.dur = p.dur

		tp[ch][c] = p2
	}
}

# Each thing assigned to a key gets a chord
method assign_chord(ch,tp) {
	for ( cp=1; ; cp++ ) {
		c = substr($.keyorder,cp,1)
		if ( c == "" )
			break
		p = tp[ch][c]
		
		cn = $.chords[rand(sizeof($.chords))]
		p2 = transpose(chordnamed(cn),p)
		p2 = scadjust(p2,makescale('c,e,g'))
		p2.chan = p.chan
		p2.vol = p.vol
		p2.dur = p.dur

		tp[ch][c] = p2
	}
}

# Each thing assigned to a key gets an octave-transposed copy added
method assign_octaves(ch,tp) {
	for ( cp=1; ; cp++ ) {
		c = substr($.keyorder,cp,1)
		if ( c == "" )
			break
		p = tp[ch][c]
		if ( rand(2) == 0 ) {
			p = p + transpose(p,12)
		} else {
			p = transpose(p,12) + p
		}
		tp[ch][c] = p
	}
}

# Each thing assigned to a key gets an octave-transposed copy added
method assign_rand(ch,tp) {
	for ( cp=1; ; cp++ ) {
		c = substr($.keyorder,cp,1)
		if ( c == "" )
			break
		p = tp[ch][c]
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
		tp[ch][c] = p
	}
}

method apply_mods(p) {
	if ( typeof(p) != "phrase") {
		print("Non phrase (",p,") given to apply_mods...")
		return('')
	}
	ch = $.currloop
	p.chan = ch
	if ( $.chanrand == 1 ) {
		# Deterministic randomness on the pitch
		rand(-p.pitch)
		r = rand(15)+1
		if ( r >= 10 )
			r++
		p.chan = r
	} else if ( $.chanrand == 2 ) {
		# Totally random, but avoid 10
		r = rand(15)+1
		if ( r >= 10 )
			r++
		p.chan = r
	}
	if ( ch != 10 ) {
		p.pitch += (12*$.octshift[$.currloop])
	}
	p.vol += $.velocityinc[$.currloop]

	if ( $.nnotes[ch] > 0 ) {
		arr = splitonstarts(p,0,$.nnotes[ch])
		p = arr[0]
	}

	if ( $.currloop in $.immediate ) {
		i = $.immediate[$.currloop]
		if ( i != 0 ) {
			p = i(p)
		}
	}
	if ( $.durscale[$.currloop] != 1 ) {
		p = scatimes(p,$.durscale[$.currloop])
	}
	t = Tp["tonality"]
	if ( t != 0 ) {
		p = scadjust(p,$.tonalscales[t])
	}
	if ( $.fractality[$.currloop] > 0 ) {
		p = $.imm_fract(p,$.fractality[$.currloop])
	}
	return(p)
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

method resetnnotes(ch) {
	if ( nargs() < 1 ) {
		$.nnotes = []
		for ( ch=1; ch<=16; ch++ )
			$.nnotes[ch] = 1
	} else {
		$.nnotes[ch] = 1
	}
}

method resetglobal() {
	$.resetnnotes()
	$.chanrand = 0
	$.shiftpolarity = $.defaultshiftpolarity

	$.loopfade = 0
	$.recording = 1
	$.armed = 0
	$.nsects = 0
	$.overdubbing = 1
	$.pulse_adjust = 0
	$.currloop = 0
	$.last_tap_set = 0
	$.new_pulse_time = 0
	$.new_loop_phrase = []
	$.new_loop_beats = []
}

method resetstuff() {

	$.resetglobal()

	$.typo[$.currpatt]["tonality"] = 0

	for ( c=1; c<=$.chans; c++ ) {
		$.typo[$.currpatt]["ctlr"][c] = $.initial_ctlr()
		$.typo[$.currpatt]["octshift"][c] = 0
		$.typo[$.currpatt]["fractality"][c] = 0
		$.typo[$.currpatt]["durscale"][c] = 1
		$.typo[$.currpatt]["velocity"][c] = 0
	}
}

method ctrl_exec(c,nw) {
	if ( c == "Q" ) {
		$.quit = 1
	} else if ( c == "R" ) {
		$.resetstuff()
	} else if ( c == "V" ) {
		$.verbose = 1 - $.verbose
	} else if ( c == "L" ) {
		print("CTRL_EXEC L, shiftpolarity =",$.shiftpolarity)
		$.shiftpolarity = 1 - $.shiftpolarity
		if ( $.shiftpolarity == 1 )
			print("Loop recording is now ON by default.")
		else
			print("Loop recording is now OFF by default.")
	} else if ( c == "C" ) {
		print("Clearing all sounds.")
		$.typo[$.currpatt]["sound"] = []
		$.sound = $.typo[$.currpatt]["sound"]
	} else if ( c == "T" ) {
		if ( $.timer >= 0 )
			kill($.timer)
		$.timer = task $.typo_timer()
	}
}

method ctrl_grabber(c,nw) {
	if ( c in $.phr[$.currloop] ) {
		p = lastbunch(Recorded,1b)
		p = quantize(p,$.grabquant)
		p = strip(p)
		if ( p == '' ) {
			print("Nothing in Recorded to grab...")
			return()
		}
		p.length = numquant(latest(p),$.grabquant)
		# If all the notes are at the same time, assume it's
		# a note or chord, and fix the duration
		if ( p.time == 0 ) {
			p.dur = 1b
		}
		$.phr[$.currloop][c] = p
		print("Character ",c," now plays ",sizeof(p)," notes.")
		return()
	}
}

method ctrl_file(c,nw) {
	if ( c == "W" ) {
		print("Write file with all settings...")
		fname = browsefiles("typo files (*.tp)","*.tp",0)
		if ( fname != "" )
			$.typo_dump(fname)
	} else if ( c == "R" ) {
		print("Read file with all settings...")
		fname = browsefiles("typo files (*.tp)","*.tp",0)
		if ( fname != "" )
			$.typo_restore(fname)
	} else {
		print("Unrecognized char - ",c)
	}
}

method assign_write(p) {
	print("Write file with assignments...")
	fname = browsefiles("typo files (*.tpa)","*.tpa",0)
	if ( fname != "" && ! ( fname ~~ ".tpa" ) ) {
		fname = fname + ".tpa"
	}
	if ( fname == "" ) {
		print("No file written");
	} else {
		f = open(fname,"w")
		if ( f < 0 ) {
			print("Can't open file: ",fname)
		}else {
			sep = "["
			for ( n in p ) {
				put(f,sep)
				put(f,"\n")
				put(f,n)
				put(f,"=")
				put(f,p[n])
				put(f,"\n")
				sep = ","
			}
			put(f,"]\n")
			close(f)
			print("File ",fname," written.")
		}
	}
}

method assign_read() {
	print("Read file with assignments...")
	fname = browsefiles("typo files (*.tpa)","*.tpa",0)
	if ( fname != "" && ! ( fname ~~ ".tpa" ) ) {
		fname = fname + ".tpa"
	}
	if ( fname == "" ) {
		print("No file read");
	} else {
		$.ctrl_assign_read_tpa(fname)
	}
}
method ctrl_assign_read_tpa(fname) {
	s = readfile(fname)
	if ( s == "" ) {
		print("Can't open file or it's empty: ",fname)
	} else {
		eval ("__Phrarr="+s)
		print("File ",fname," read.")
		$.ctrl_assign_read_tpa_arr(__Phrarr)
	}
}
method ctrl_assign_set_tpa_arr(phrarr) {
	$.phr = phrarr
	Tp["phrase"] = $.phr
}
method ctrl_assign_set_tpa_arr_chan(arr,ch) {
	$.phr[ch] = arr
}
method ctrl_assign_read_tpa_arr(phrarr) {
	if ( ! (1 in phrarr) ) {
		print("Hey, that file doesn't have a channel 1 entry")
		return()
	}
	ctrl_assign_set_tpa_arr(phrarr)
	ctrl_assign_fix_tpa_arr()
}

method ctrl_assign_fix_tpa_arr() {
	phrarr = $.phr
	# For any channels that aren't included,
	# copy channel 1
	for ( c=2; c<=16; c++ ) {
		if ( ! (c in phrarr ) ) {
			phrarr[c] = arraycopy(phrarr[1])
		}
	}
	# For any keys that aren't given in the map,
	# assign them from the inherited key
	for ( ch=1; ch<=16; ch++ ) {
		arr = phrarr[ch]
		$.ctrl_assign_fix_tpa_arr1(arr)
	}
}

method ctrl_assign_fix_tpa_arr1(arr) {
	# For any keys that aren't given in the map,
	# assign them from the inherited key
	for ( cp=1; ; cp++ ) {
		c = substr($.keyorder,cp,1)
		if ( c == "" ) {
			break
		}
		if ( ! (c in arr) ) {
			inh = substr($.keyinherit,cp,1)
			arr[c] = arr[inh]
		}
	}
}

method ctrl_ano(c,nw) {
	print("Sending all-notes-off...")
	$.realtime(ano())
}

method ctrl_info(c,nw) {

	print("========")
	# print("\nPULSE_TIME = ",$.pulse_time)
	print("\nBEATS IN MASTER LOOP = ",$.loop_beats[1]," leng=",$.loop_beats[1]*$.pulse_time)
	return()

	atts = ""
	if ( Tp["tonality"] > 0  ) {
		atts = atts + "Y=" + string(Tp["tonality"]) + " "
	}
	print("\nCURRENT: Pattern=",$.currpatt,"  Loop=",$.currloop,"  Loop=",Tp["length"]/1b,"beats ",atts)
	for ( c=1; c<=$.chans; c++ ) {
		$.print_chan_line(c,0)
	}
}

method print_chan_line(c,always) {
	p = $.loopphrase[c]
	if ( c in $.nopatches ) {
		nm = ""
	} else if ( typeof($.sound) == "array" && (c in $.sound) && ("name" in $.sound[c]) ) {
		nm = "sound="+$.sound[c]["name"]
	} else {
		nm = "sound=Unknown"
	}
	atts = " "
	if ( sizeof(p) > 0 ) {
		w = ""
		if ( (c in $.loopphrasewarp) ) {
			ws = sizeof($.loopphrasewarp[c])
			if ( ws > 0 )
				w = "   warped"
		}
		print("Chan(",c,") ",nm,atts,"  looped notes=",sizeof(p),w)
	} else if ( (c in $.sound) || (c in $.nopatches) ) {
		print("Chan(",c,") ",nm,atts)
	} else if ( always ) {
		# print("Chan(",c,") ",atts,"  no sound assigned")
		print("Loop ",c)
	}
}

method ctrl_scale(c,nw) {
	if ( c in $.scaless ) {
		$.rescale($.currpatt,$.currloop,'c',$.scaless[c])
		print("Switching to scale: ",$.scaless[c])
	} else {
		print("No such scale: ",c,"   Scales are:")
		for ( n in $.scaless )
			print(n," - ",$.scaless[n])
	}
}

method ctrl_ornament(c,nw) {
	a = ascii(c) - ascii("0")
	ch = $.currloop
	if ( a >= 0 && a < 10 ) {
		orn = $.ornament[a]
		if ( sizeof(orn) > 0 ) {
			for ( i in $.phr[ch] ) {
				pk = orn[rand(sizeof(orn))]
				$.phr[ch][i] = ornament($.phr[ch][i],pk)
				if ( OrnamentScale ) {
					p = $.phr[ch][i]
					p = scadjust(p,makescale(scalenamed("newage")))
					$.phr[ch][i] = p
				}
			}
		}
	}
}

method ctrl_assignall(c,nw) {
	print("Copying key assignments from channel ",$.currloop," to all chans")
	for ( ch=1; ch<=$.chans; ch++ ) {
		if ( ch == $.currloop )
			continue
		$.sourcepos[ch] = $.sourcepos[$.currloop]
		$.sourcephr[ch] = $.sourcephr[$.currloop]
		$.phr[ch] = arraycopy($.phr[$.currloop])
		for ( i in $.phr[ch] ) {
			p = $.phr[ch][i]
			p.chan = ch
			$.phr[ch][i] = p
		}
	}
}

method ctrl_assigncopy(c,nw) {
	a = ascii(c) - ascii("0")
	if ( a >= 0 && a < 10 ) {
		print("Copying key assignments from channel ",a," to chan ",$.currloop)
		if ( $.currloop != a ) {
			$.phr[$.currloop] = arraycopy($.phr[a])
			for ( i in $.phr[$.currloop] ) {
				p = $.phr[$.currloop][i]
				p.chan = $.currloop
				$.phr[$.currloop][i] = p
			}
		}
	}
}

method ctrl_assign_read_mf(fname,allchannels) {
	$.typo_init($.currloop)

	p = readmf(fname)
	p = onlynotes(p)
	# Eliminate channel 10, usually drums
	p -= p{??.chan==10}
	if ( sizeof(p) == 0 ) {
		print("No notes in midi file: ",fname)
		return()
	}
	p = step(p,1b/4)

	if ( allchannels ) {
		print("Assigning midi file to ALL channels.")
		$.typo_init_from_phrase($.currpatt,$.currloop,p)
		$.ctrl_assignall()
	} else {
		print("Assigning midi file to channel ",$.currloop)
		$.typo_init_from_phrase($.currpatt,$.currloop,p)
	}
}

method ctrl_assign(c,nw) {
	a = ascii(c) - ascii("0")
	if ( a >= 0 && a < 10 ) {
		if ( ! ( a in $.assigns ) ) {
			print("No assignments in slot ",a)
		} else {
			print("Assignments now coming from slot ",a)
			$.sourcepos[$.currloop] = $.assigns[a]["sourcepos"]
			$.sourcephr[$.currloop] = arraycopy($.assigns[a]["sourcephr"])
			$.phr[$.currloop] = arraycopy($.assigns[a]["phr"])
			$.ctrl_assignall()
		}
		
	} else if ( c == "M" || c == "N" ) {
		fname = browsefiles("midi files (*.mid)","*.mid",1)
		if ( fname != "" && ! fileexists(fname) ) {
			print("Hey, fname=",fname," doesn't exist?")
			return()
		}
		if ( fname != "" ) {
			$.ctrl_assign_read_file(fname,c=="N")
		}
		print(fname+" has been read and assigned to letters.")
	} else if ( c == "S" ) {
		$.charproc = "ctrl_scale"
	} else if ( c == "O" ) {
		# ornament
		$.charproc = "ctrl_ornament"
	} else if ( c == "C" ) {
		$.assign_chord($.currloop,$.phr)
	} else if ( c == "I" ) {
		$.assign_inversions($.currloop,$.phr)
	} else if ( c == "B" ) {
		$.assign_bs($.currloop,$.phr)
	} else if ( c == "P" ) {
		$.assign_rand($.currloop,$.phr)
	} else if ( c == "R" ) {
		$.assign_read()
	} else if ( c == "W" ) {
		$.assign_write($.phr)
	} else if ( c == "K" ) {
		# We Want to sent the next character to ctrl_scale
		$.charproc = "ctrl_scale"
	} else if ( c == "A" ) {
		$.ctrl_assignall()
	} else if ( c == "Y" ) {
		# We Want to sent the next character to ctrl_assigncopy
		$.charproc = "ctrl_assigncopy"
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
			Tp["transitions"] = $.transitions[a]
			print("Transitions set to ",Tp["transitions"])
			# Assume that first transition is currently playing
			if ( sizeof(Tp["transitions"]) > 1 )
				$.transitionpos = 1
			else
				$.transitionpos = 0
		}
	}
}

method ctrl_bank(c,nw) {

	a = ascii(c) - ascii("0")
	if ( a >= 0 && a < 10 ) {
		$.currbank = a
		# print("Sound Bank set to ",$.currbank)
		$.print_bank(a)
	} else {
		print("Unrecognized char - ",c)
	}
}

method ctrl_changes(c,nw) {

	a = ascii(c) - ascii("0")
	if ( a >= 0 && a < 10 ) {
		# print("Sound Bank set to ",$.currbank)
		for ( c in $.changes[a] ) {
			nm = $.changes[a][c]
			arr = patch_lookup(nm,c,$.pmap[c])
			if ( sizeof(arr) == 0 ) {
				print("No patch named ",nm," in channel ",c)
			} else {
				p = arr["patch"]
				$.realtime(p)
				$.sound[c] = arraycopy(arr)
				$.print_chan_line(c,0)
			}
		}
	} else {
		print("Unrecognized char - ",c)
	}
}

method ctrl_sound(c,nw) {

	if ( $.currloop in $.nopatches ) {
		print("No patch changes on channel ",$.currloop)
		return()
	}

	nm = ""
	arr = []
	ptype = ""
	a = ascii(c) - ascii("0")
	if ( a >= 0 && a < 10 ) {
		if ( ! ( a in $.banks[$.currbank] ) || typeof($.banks[$.currbank][a]) != "string" ) {
			print("No sound in bank",$.currbank,"slot",a)
			return()
		}
		printf("Bank "+string($.currbank)+" ")
		nm = $.banks[$.currbank][a]
	} else if ( $.currloop == 10 ) {

		if ( c == "A" )
			arr = drummap_rand($.currloop)
		else
			arr = drummap_type($.currloop,"good")

	} else if ( c == "A" ) {
		arr = patchmap_rand($.currloop)
	} else if ( c == "R" || c == "S" ) {
		ptype = "all"
	} else if ( c == "P" ) {
		ptype = "pad"
	} else if ( c == "H" ) {
		ptype = "hard"
	} else if ( c == "B" ) {
		ptype = "bass"
	} else if ( c == "C" ) {
		ptype = "perc"
	} else if ( c == "V" ) {
		ptype = "vocal"
	} else if ( c == "D" ) {
		ptype = "drum"
	} else {
		print("Unrecognized char - ",c)
		return()
	}

	if ( ptype != "" ) {
		a = $.patches[$.currloop][ptype]
		r = rand(sizeof(a))
		nm = a[r]
	}

	if ( nm != "" && sizeof(arr) == 0 ) {
		arr = patch_lookup(nm,$.currloop,$.pmap[$.currloop])
	if ( $.debug ) print("Looked up nm=",nm,"  arr=",arr)
		if ( sizeof(arr) == 0 ) {
			print("Hmm, no patch named ",nm," on channel ",$.currloop)
			return()
		}
	}
	if ( ! defined(arr) || ! ( "patch" in arr ) ) {
		print("Hmm, no value for arr in ctrl_sound ?  c=",c," nm=",nm)
		return()
	}
	p = arr["patch"]
	$.realtime(p)
	$.sound[$.currloop] = arraycopy(arr)
	$.print_chan_line($.currloop,0)
}

method ctrl_keep(c,nw) {

	# S is Sounds
	if ( c == "S" || c == "U" || c == "Y" || c == "A" || c == "C" ) {
		$.keeptype = c
		$.charproc = "ctrl_keep2"
	} else {
		print("Unknown keep type character - ",c)
	}
}

method ctrl_keep2(c,nw) {

	arr = []
	a = ascii(c) - ascii("0")
	if ( a >= 0 && a < 10 ) {
		if ( $.keeptype == "S" ) {
			arr = arraycopy($.sound[$.currloop])
			$.banks[$.currbank][a] = $.sound[$.currloop]["name"]
			print("Sound ",$.banks[$.currbank][a]," saved in bank",$.currbank,"slot",a)
		} else if  ( $.keeptype == "C" ) {
			$.changes[a] = []
			for ( c=1; c<=$.chans; c++ ) {
				if ( c in $.sound )
					$.changes[a][c] = $.sound[c]["name"]
			}
		} else if  ( $.keeptype == "A" ) {
			$.assigns[a] = []
			$.assigns[a]["sourcepos"] = $.sourcepos[$.currloop]
			$.assigns[a]["sourcephr"] = arraycopy($.sourcephr[$.currloop])
			$.assigns[a]["phr"] = arraycopy($.phr[$.currloop])
			print("Assignments saved in slot ",a)
		}
	} else if ( c == "K" ) {
		for ( b in $.banks ) {
			$.print_bank(b)
		}
		return()
	} else {
		print("Unrecognized char - ",c)
		return()
	}

}

method print_bank(b) {
	for ( n=0; n<10; n++ ) {
		if ( n in $.banks[b] ) {
			any = 1
			print("Bank ",b," Sound slot ",n," is ",$.banks[b][n])
		}
	}
}

method ctrl_pan(c,nw) {
	if ( c == "L" ) {
		v = 0
	} else if ( c == "R" ) {
		v = 127
	} else if ( c == "C" ) {
		v = 64
	}
	p = pannote($.currloop,v)
	$.realtime(p)
	$.pan[$.currloop] = v
}

method change_offset(o) {
	if ( o == Offsetpitch )
		return()
	Offsetpitch = o
	$.realtime(ano())
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
		$.immediate[$.currloop] = 0
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
		$.immediate[$.currloop] = $.imm_echo
		$.imm_echo_type = ($.imm_echo_type+1)%5
	} else if ( c == "F" ) {
		$.immediate[$.currloop] = $.imm_fract
	} else if ( c == "W" ) {
		$.immediate[$.currloop] = $.imm_fract
	} else if ( c == "S" ) {
		$.immediate[$.currloop] = $.imm_scale
	} else {
		print("Unknown Immediate character: ",c)
	}
}

method fractal_chan(ch) {
	leng = Tp["length"]
	p = Tp["loopphrase"][ch]
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
	trq = $.requant[ch]
	if ( trq > 1 )
		p = quantize(p,trq)
	Tp["loopphrasewarp"][ch] = p
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

method comb(p) {
	p = p{rand(2) == 0}
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

method warp_chan(ch,f) {
	leng = Tp["length"]
	w = Tp["loopphrasewarp"][ch]
	if ( sizeof(w) > 0 )
		p = w
	else
		p = Tp["loopphrase"][ch]
	Tp["loopphrasewarp"][ch] = $.(f)(p,leng)
}

method warpit(f) {
	if ( $.warpall ) {
		for ( ch=1; ch<=$.chans; ch++ ) {
			$.warp_chan(ch,f)
		}
	} else {
		$.warp_chan($.currloop,f)
	}
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
		if ( $.warpall ) {
			for ( ch=1; ch<=$.chans; ch++ ) {
				$.fractal_chan(ch)
			}
		} else {
			$.fractal_chan($.currloop)
		}
	} else if ( c == "W" ) {
		for ( ch=1; ch<=$.chans; ch++ ) {
			Tp["loopphrasewarp"][ch] = ''
		}
		print ("Warp cleared")
	}
}

method setlength(v) {
	Tp["length"] = v
}

method ctrl_length(c,nw) {
	if ( c == "H" ) {
		$.setlength(Tp["length"] * 0.5)
	} else if ( c == "D" ) {
		leng = Tp["length"]
		newleng = leng * 2
		for ( ch=1; ch<=$.chans; ch++ ) {
			origp = Tp["loopphrase"][ch]
			p = origp
			p.length = newleng
			# If the second half doesn't have anything,
			# then duplicate the first half
			p2 = cut(p,CUT_TIME,leng,newleng)
			if ( sizeof(p2) == 0 ) {
				origwarp = Tp["loopphrasewarp"][ch]
				if ( sizeof(origwarp) == 0 )
					origwarp = origp
				p2 = cut(origwarp,CUT_TIME,0,leng)
				p2.length = leng
				p = repleng(p2,newleng)
			}
			Tp["loopphrasewarp"][ch] = p
		}
		$.setlength(newleng)
	} else {
		# The keys 1-9 map to lengths
		a = ascii(c) - ascii("0")
		if ( a >= 1 && a < 10 ) {
			$.setlength(a * 1b)
		}
	}
	print("Length = ",(Tp["length"]/1b)," beats")
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

method ctrl_quant(c,nw) {
	# The keys A-Z will map to offsets -12 to 12.
	q = 1
	if ( c == "P" ) {
		q = $.pulse_time
	} else if ( c == "H" ) {
		q = $.pulse_time / 2
	} else if ( c == "Q" ) {
		q = $.pulse_time / 4
	} else if ( c == "E" ) {
		q = $.pulse_time / 8
	}
	print("Quantizing to ",q)
	if ( ! ( $.currloop in $.loop_phrase ) ) {
		print("Hey, currloop=",$.currloop," not in loop_phrase?")
		return()
	}
	for ( b in $.loop_phrase[$.currloop] ) {
		$.loop_phrase[$.currloop][b] =
			quantize($.loop_phrase[$.currloop][b],q) 
	}
	$.normalize($.currloop)
	$.loop_quant[$.currloop] = q
}

method ctrl_note(c,nw) {
	# The keys A-Z will map to pitches
	n = ascii(c) - ascii("A") + 'a'.pitch
	nt = makenote(n)
	nt.type = NOTEON
	$.got_notedown(nt,nw)
	task $.ctrl_note_task(nt,nw)
}
method ctrl_note_task(nt,nw) {
	sleeptill(nw+1b/4)
	nt.type = NOTEOFF
	$.got_noteup(nt,nw)
}

method topattern(n) {

	# XXX - should I be looking at $.lastplayed and turning things off?

	$.currpatt = n
	$.transitionpos = 0
	$.currbank = 0

	Tp = $.typo[n]

	# Careful - these global variables should not be altered
	# by any other code, the arrays they point to must not
	# be re-allocated, they must be the values in $.typo[]
	$.loopphrase = Tp["loopphrase"]
	$.loopphrasewarp = Tp["loopphrasewarp"]
	if ( "loopquant" in Tp )
		$.loopquant = Tp["loopquant"]
	else
		$.loopquant = $.defaultloopquant
	$.mode = Tp["mode"]
	$.loopmode = Tp["loopmode"]
	$.loopmute = Tp["loopmute"]
	$.looptask = Tp["looptask"]
# print("topattern, looptask=",$.looptask)
	$.ctlr = Tp["ctlr"]
	$.sound = Tp["sound"]
	$.pan = Tp["pan"]
	$.immediate = Tp["immediate"]
	$.requant = Tp["requant"]
	$.octshift = Tp["octshift"]
	$.fractality = Tp["fractality"]
	$.durscale = Tp["durscale"]
	$.velocityinc = Tp["velocity"]
	$.looprestep = Tp["looprestep"]
	$.phr = Tp["phrase"]
	$.banks = Tp["banks"]
	$.assigns = Tp["assigns"]
	$.changes = Tp["changes"]
	$.sourcephr = Tp["sourcephr"]

# print("TOPATTERN, sourcephr size is ",sizeof($.sourcephr)," sourcephr=",$.sourcephr)
	$.sourcepos = Tp["sourcepos"]

	$.change_offset( Tp["transitions"][0] )

	# print("Switching to Pattern = ",n,"   length = ",Tp["length"])

	$.lastplayed = []	# index is key(character)
	for ( ch=1; ch<=$.chans; ch++ ) {
		for ( ctlr in $.controllers ) {
			if ( (ch in $.nopatches) ) {
				# print("Avoiding ctlr ",ctlr," on ch=",ch)
			} else {
				p = controller(ch,ctlr,$.ctlr[ch][ctlr])
				$.realtime(p)
			}
		}
		if ( ! ( ch in $.nopatches ) ) {
			if ( ch in $.sound ) {
				p = $.sound[ch]["patch"]
				$.realtime(p)
			}
		}
		if ( $.currloop in $.pan ) {
			p = pannote($.currloop,$.pan[$.currloop])
			$.realtime(p)
		}
	}
	if ( $.verbose ) {
		task $.ctrl_info()
	}
}

method inc_vol(v) {
	$.inc_controller(v,$.controllerletters["V"])
}
method inc_express(v) {
	$.inc_controller(v,$.controllerletters["E"])
}
method inc_chorus(v) {
	$.inc_controller(v,$.controllerletters["C"])
}
method inc_reverb(v) {
	$.inc_controller(v,$.controllerletters["R"])
}
method inc_reverbtime(v) {
	$.inc_controller(v,$.controllerletters["T"])
}
method inc_bright(v) {
	$.inc_controller(v,$.controllerletters["B"])
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
method set_octave(v) {
	$.octshift[$.currloop] = v
}
method inc_octave(v) {
	$.octshift[$.currloop] = $.inc_value(v,$.octshift[$.currloop],"O")
}
method inc_durscale(v) {
	$.durscale[$.currloop] = $.mult_value(v,$.durscale[$.currloop],"D")
	print("durscale=",$.durscale[$.currloop]," for chan ",$.currloop)
}
method inc_tonality(v) {
	$.typo[$.currpatt]["tonality"] =
		$.inc_value(v,Tp["tonality"],"Y")
}
method inc_fractality(v) {
	$.fractality[$.currloop] = $.inc_value(v,$.fractality[$.currloop],"F")
}
method inc_velocityinc(v) {
	if ( v == INCDEC_MID )
		$.velocityinc[$.currloop] = $.defaultvelocityinc
	else if ( v == INCDEC_MIN )
		$.velocityinc[$.currloop] = -999
	else if ( v == INCDEC_MAX )
		$.velocityinc[$.currloop] = 999
	else if ( v == INCDEC_INC )
		$.velocityinc[$.currloop] += 10
	else if ( v == INCDEC_DEC )
		$.velocityinc[$.currloop] -= 10
}

method inc_controller(v,ctlr) {
	ov = $.ctlr[$.currloop][ctlr]
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
	$.ctlr[$.currloop][ctlr] = ov
	if ( ctlr == 0x5c )
		p = gm2reverbtime(ov)
	else
		p = controller($.currloop,ctlr,ov)
	$.realtime(p)
}

method inc_joyshift(v) {
	if ( v == INCDEC_INC ) {
		if ( $.joyshift < 2 ) {
			$.anoforjoy(-1)
			$.joyshift++
		}
	} else if ( v == INCDEC_DEC ) {
		if ( $.joyshift > 0 ) {
			$.anoforjoy(-1)
			$.joyshift--
		}
	}
	print("joyshift=",$.joyshift)
}

method inc_chanrand(v) {
	if ( v == INCDEC_INC ) {
		if ( $.chanrand < 2 ) {
			$.chanrand++
		}
	} else if ( v == INCDEC_DEC ) {
		if ( $.chanrand > 0 ) {
			$.chanrand--
		}
	}
	print("chanrand=",$.chanrand)
}

method inc_chan(v) {
	if ( v == INCDEC_INC ) {
		$.chanchange(1)
	} else if ( v == INCDEC_DEC ) {
		$.chanchange(-1)
	}
}

method inc_loop(v) {
	if ( v == INCDEC_INC ) {
		$.loopchange(1)
	} else if ( v == INCDEC_DEC ) {
		$.loopchange(-1)
	}
}

method inc_sect(v) {
	if ( v == INCDEC_INC ) {
		$.sectchange(1)
	} else if ( v == INCDEC_DEC ) {
		$.sectchange(-1)
	}
}

method setfade(v) {
	$.loopfade = v
	if ( $.loopfade > 4 )
		$.loopfade = 4
	if ( $.loopfade < 0 )
		$.loopfade = 0
}

method inc_loopfade(v) {
	if ( v == INCDEC_INC ) {
		if ( $.loopfade < 4 ) {
			$.loopfade++
		}
	} else if ( v == INCDEC_DEC ) {
		if ( $.loopfade > 0 ) {
			$.loopfade--
		}
	}
	print("loopfade=",$.loopfade)
}

method inc_nnotes(v) {
	if ( v == INCDEC_INC ) {
		$.morenotes()
	} else if ( v == INCDEC_DEC ) {
		$.lessnotes()
	}
	if ( $.debug ) print("nnotes=",$.nnotes[$.currloop])
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
		$.typo[n]["loopquant"] = $.defaultloopquant
	}
	if ( ! ("length" in $.typo[n]) ) {
		$.typo[n]["length"] = 0
	}
	if ( ! ("transitions" in $.typo[n]) ) {
		$.typo[n]["transitions"] = [0=0]
	}
	if ( ! ("loopphrase" in $.typo[n]) ) {
		$.typo[n]["loopphrase"] = []
		for ( c=1; c<=$.chans; c++ ) {
			$.typo[n]["loopphrase"][c] = ''
		}
	}
	if ( ! ("loopphrasewarp" in $.typo[n]) ) {
		$.typo[n]["loopphrasewarp"] = []
		for ( c=1; c<=$.chans; c++ ) {
			$.typo[n]["loopphrasewarp"][c] = ''
		}
	}
	if ( ! ("loopmode" in $.typo[n]) ) {
		$.typo[n]["loopmode"] = []
		for ( c=1; c<=$.chans; c++ ) {
			$.typo[n]["loopmode"][c] = 0
		}
	}
	if ( ! ("loopmute" in $.typo[n]) ) {
		$.typo[n]["loopmute"] = []
		for ( c=1; c<=$.chans; c++ ) {
			$.typo[n]["loopmute"][c] = 0
		}
	}
	if ( ! ("ctlr" in $.typo[n]) ) {
		$.typo[n]["ctlr"] = []
		for ( c=1; c<=$.chans; c++ ) {
			$.typo[n]["ctlr"][c] = $.initial_ctlr()
		}
	}
	if ( ! ("sound" in $.typo[n]) ) {
		$.typo[n]["sound"] = []
		# for ( c=1; c<=$.chans; c++ ) {
		# 	$.typo[n]["sound"][c] = patchmap_bynum(1,c)
		# }
	}
	if ( ! ("pan" in $.typo[n]) ) {
		$.typo[n]["pan"] = []
		for ( c=1; c<=$.chans; c++ ) {
			$.typo[n]["pan"][c] = 64
		}
	}
	if ( ! ("immediate" in $.typo[n]) ) {
		$.typo[n]["immediate"] = []
		for ( c=1; c<=$.chans; c++ ) {
			$.typo[n]["immediate"][c] = 0
		}
	}
	if ( ! ("requant" in $.typo[n]) ) {
		$.typo[n]["requant"] = []
		for ( c=1; c<=$.chans; c++ ) {
			$.typo[n]["requant"][c] = 0
		}
	}
	if ( ! ("octshift" in $.typo[n]) ) {
		$.typo[n]["octshift"] = []
		for ( c=1; c<=$.chans; c++ ) {
			$.typo[n]["octshift"][c] = 0
		}
	}
	if ( ! ("tonality" in $.typo[n]) ) {
		$.typo[n]["tonality"] = 0
	}
	if ( ! ("fractality" in $.typo[n]) ) {
		$.typo[n]["fractality"] = []
		for ( c=1; c<=$.chans; c++ ) {
			$.typo[n]["fractality"][c] = 0
		}
	}
	if ( ! ("durscale" in $.typo[n]) ) {
		$.typo[n]["durscale"] = []
		for ( c=1; c<=$.chans; c++ ) {
			$.typo[n]["durscale"][c] = 1
		}
	}
	if ( ! ("velocity" in $.typo[n]) ) {
		$.typo[n]["velocity"] = []
		for ( c=1; c<=$.chans; c++ ) {
			$.typo[n]["velocity"][c] = 0
		}
	}
	if ( ! ("looprestep" in $.typo[n]) ) {
		$.typo[n]["looprestep"] = []
		for ( c=1; c<=$.chans; c++ ) {
			$.typo[n]["looprestep"][c] = 0
		}
	}
	if ( ! ("looptask" in $.typo[n]) ) {
		$.typo[n]["looptask"] = []
		for ( c=1; c<=$.chans; c++ ) {
			$.typo[n]["looptask"][c] = -1
		}
	}
	if ( ! ("sourcephr" in $.typo[n]) ) {
		$.typo[n]["sourcephr"] = []
		for ( c=1; c<=$.chans; c++ ) {
			$.typo[n]["sourcephr"][c] = []
		}
	}
# print("INIT_PATTERN, sourcephr of pattern 0, chan 1 is ",sizeof($.typo[n]["sourcephr"][1]))
# print("INIT_PATTERN, sourcephr TOTAL is ",$.typo[n]["sourcephr"])
	if ( ! ("sourcepos" in $.typo[n]) ) {
		$.typo[n]["sourcepos"] = []
		for ( c=1; c<=$.chans; c++ ) {
			$.typo[n]["sourcepos"][c] = -1
		}
	}
	if ( ! ("phrase" in $.typo[n]) ) {
		$.typo[n]["phrase"] = []
		for ( c=1; c<=$.chans; c++ ) {
			$.typo[n]["phrase"][c] = []
		}
	}
	if ( ! ("banks" in $.typo[n]) ) {
		# Per-pattern array of sound names in slots
		$.typo[n]["banks"] = []
		for ( b=0; b<10; b++ ) {
			$.typo[n]["banks"][b] = []
		}
	}
	if ( ! ("changes" in $.typo[n]) ) {
		# Per-pattern array of patch changes
		$.typo[n]["changes"] = []
		for ( b=0; b<10; b++ ) {
			$.typo[n]["changes"][b] = []
		}
	}
	if ( ! ("assigns" in $.typo[n]) ) {
		# Per-pattern array of key assignment stuff
		$.typo[n]["assigns"] = []
	}
}

method global_defaults() {
	$.grabquant = 1b/4
	$.npatterns = 10
	$.warpall = 0
	$.defaultmode = "L"
	$.keyorder   = "QAZWSXEDCRFVTGBYHNUJMIK,OL.123456789";
	$.keyinherit = "QAZWSXEDCQAZWSXEDCQAZWSXEDCQAZWSXEDC";
	$.debug = 0
	$.controllerinc = 5
	$.defaultshiftpolarity = 1
	$.defaultvelocityinc = 20
	$.transmultiple = $.defmultiple
	$.imm_echo_type = 0

	$.quant = 1b/4
	$.quant = 1
	$.defaultloopquant = 1b
	$.defaultloopquant = 1
	$.defaultchan = 1

	$.defaultbeats = 8
	$.control_chan = 16  

	$.control_arm = 13  # pitch
	$.control_purge = 14 
	$.control_reset = 15
	$.control_tap = 16

	$.control_punchinout = 9
	$.control_addbeat = 10
	$.control_subbeat = 11
	$.control_shuffle = 12

	$.control_mute = 5
	$.control_nudgeforward = 6
	$.control_nudgebackward = 7
	$.control_copy = 8

	$.control_upchannel = 1
	$.control_downchannel = 2
	$.control_flyquant1 = 3
	$.control_flyquant2 = 4

	$.control_quant1 = 33
	$.control_quant2 = 44
	$.control_info = 55
}


method cons_task(fromf,tof) {
	while ( (c=get(fromf)) != Eof ) {
		put(tof,c)
	}
}

method midi_task(tof) {
	Midiin[$] = f = open()
	onexit(closemidi,$)
	while ( (n=get(f)) != Eof ) {
		put(tof,n)
	}
}

method pulse_task(nextpulse) {
	$.last_pulse_time = nextpulse
	while ( 1 ) {
		# print("TOP OF PULSE_TASK nextpulse=",nextpulse)
		sleeptill(nextpulse-4)
		lock($)

		if ( $.nextsect > 0 ) {
			$.currsect = $.nextsect
			$.nextsect = 0
			print("PULSE_TASK IS SWITCHING TO SECTION ",$.currsect)
			$.set_sect_vars($.currsect)
			$.currloop = 0
			$.recording = 1
			$.armed = 1	# Ready for ending of loop
			$.print_info()
		}

		thispulse = nextpulse
		$.last_pulse_time = thispulse
		nextpulse += $.pulse_time
		if ( $.pulse_adjust != 0 ) {
print("PULSE_ADJUST = ",$.pulse_adjust)
			nextpulse += $.pulse_adjust
			$.pulse_adjust = 0
		}
		for ( c=1; c<=$.nloops; c++ ) {
			if ( $.loop_mute[c] )
				continue
			if ( $.loop_beats[c] <= 0 ) {
				continue
			}
			b = $.loop_pulse[c]
			if ( b in $.loop_phrase[c] ) {
				p = $.loop_phrase[c][b]
				if ( p != '' ) {
					# print("CHAN=",c,"  PLAYING LOOP (b=",b,") ",p," Now=",Now," thispulse=",thispulse)
					q = $.loop_flyquant[c]
					if ( q != 0 ) {
print("Quantizing to q=",q)
						p = quantize(p,q)
						$.loop_phrase[c][b] = p
					}
					$.loop_tid[c] = realtime(p,thispulse)
				}
			}
			$.loop_pulse[c]++
			b++
			if ( $.loop_beats[c] > 0 && b >= $.loop_beats[c] ) {
				# Loop back to the beginning of this loop
				if ( $.loop_finished[c] == 0 ) {
					$.loop_finish(c)
				}

				$.loop_pulse[c] = 0
				$.loop_began[c] = nextpulse
				# print("BACK TO BEGINNING, loop=",c,"  finished=",$.loop_finished[c],"  began=",$.loop_began[c],"  Now=",Now)
				if ( $.new_pulse_time != 0 ) {

					# print("PULSE IS CHANGING")
					for ( ch=1; ch <= $.nloops; ch++ ) {
						$.loop_phrase[ch] = $.new_loop_phrase[ch]
						if ( $.loop_beats[ch] != 0 ) {
							$.loop_beats[ch] = $.new_loop_beats[ch]
							# print("New beats for ch=",ch," is ",$.loop_beats[ch])
						}
						$.fill_blanks(ch)
					}
					$.pulse_time = $.new_pulse_time
					$.new_pulse_time = 0
					$.new_loop_phrase = []
					$.new_loop_beats = []
				}
				# kill($.loop_tid[c])
			}
		}
		unlock($)
	}
}

method loop_finish(lp) {
	print("FINISHED UP loop ",lp)
	$.loop_finished[lp] = 1
	$.add_undo($.currsect,lp,"deleteloop")
	$.fill_blanks(lp)
}

method typo_setup(fname) {

	# Constants and setup

	if ( $.verbose )
		print("Hoops Initializing...")
	$.chans = 16
	$.nletters = 0
	$.joyshift = 1

	$.global_defaults()
	$.resetglobal()

	$.pmap = []
	for ( c=1; c<=16; c++ ) {
		$.pmap[c] = patchmap_for_chan(c)
	}

	$.patches = []
	for ( c=1; c<=16; c++ ) {
		$.patches[c] = []

		# Whoowee - two levels of indirection in the function calls!

		$.patches[c]["all"] = (patchtypes_for_chan(c))(".*")
		$.patches[c]["pad"] = (patchtypes_for_chan(c))("pad")
		$.patches[c]["hard"] = (patchtypes_for_chan(c))("hard")
		$.patches[c]["bass"] = (patchtypes_for_chan(c))("bass");
		$.patches[c]["perc"] = (patchtypes_for_chan(c))("perc");
		$.patches[c]["drum"] = (patchtypes_for_chan(c))("drum");
		$.patches[c]["vocal"] = (patchtypes_for_chan(c))("vocal");
	}
	$.patches[10]["all"] = (drumtypes_for_chan(c))(".*")
	$.patches[10]["good"] = (drumtypes_for_chan(c))("good")

	if ( ! defined($.nopatches) ) {
		# No patch changes will be sent on the channels in $.nopatches
		if ( $.gm )
			$.nopatches = []
		else
			$.nopatches = [1=1,2=1,3=1,4=1,5=1,6=1,7=1,8=1,9=1,10=1,11=1,12=1,13=1,14=1,15=1,16=1]
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
		1 = [0=0,1=0,2=0,3=0,4=2,5=2,6=2,7=2],
		# 2 is 12-bar blues
		2 = [
			0=0,1=0,2=0,3=0,4=5,5=5,6=0,7=0,8=7,9=5,10=0,11=0,
			12=0,13=0,14=2,15=2,16=3,17=3,18=2,19=2
			],
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

#		"2" = scaleng(gmdrumnamed("Open Hi-Hat")+repeat(gmdrumnamed("Closed Hi-Hat"),3),$.loopquant),
# 		"3" = scaleng(gmdrumnamed("Open Hi-Hat"),$.loopquant)


	Tnumbers = ["0"=0,"1"=1,"2"=2,"3"=3,"4"=4,"5"=5,"6"=6,"7"=7,"8"=8,"9"=9]

	$.lastdown = []	# one per letter/key - records the last
				# time it was pressed, so when it comes
				# up you can get a duration if you want
	$.lastdownq = []

	$.ctrl_immediate_list1 = [
		"R" = "got_arm",
		"=" = "got_info"		# Info
		]

	# These need a valid/current channel
	$.ctrl_immediate_list2 = [
		"S" = "got_section",
		"N" = "got_nudgeforward",
		"B" = "got_nudgebackward",
		"M" = "got_mute",
		"T" = "got_tap",
		"E" = "got_reset",
		"-" = "got_subbeat",
		"F" = "got_shuffle",
		"Y" = "got_copy",
		"P" = "got_purge",
		"I" = "got_punchinout",
		"U" = "got_undo"
		# "D" = "got_downchannel"
		# "F" = "ctrl_ano"
		]
	$.shift_immediate_list = [
		"=" = "got_addbeat",
		"U" = "got_shiftup",
		"D" = "got_shiftdown"
		]

	$.ctrl_list = [
		# O" = "ctrl_offset",		# Offset
		# N" = "ctrl_pan",		# Pan
		"Q" = "ctrl_quant",		# Quant
		"." = "ctrl_note",		# Note
		# P" = "ctrl_pattern",		# Pattern
		# R" = "ctrl_pattern_reset",	# Pattern (reset on next loop)
		# A" = "ctrl_assign",		# Assign (to keys)
		# F" = "ctrl_file",		# File (read/write)
		# S" = "ctrl_sound",		# Sound
		# B" = "ctrl_bank",		# Sound bank
		# C" = "ctrl_changes",		# Sound changes
		# K" = "ctrl_keep",		# Keep (Sound (S/U) or Assigns)
		# T" = "ctrl_transitions",	# Transitions
		# "L" = "ctrl_length",		# Length
		# "W" = "ctrl_warp",		# Warp
		# "I" = "ctrl_immediate",		# Immediate
		# "G" = "ctrl_grabber",		# Grab
		"X" = "ctrl_exec"		# Xecute
	]

	$.incdeclist = [
		"C" = "inc_chan",
		"A" = "inc_loopfade",
		"S" = "inc_sect",
		"L" = "inc_loop",
		"V" = "inc_vol",
		"E" = "inc_express",
		"O" = "inc_octave",
		"D" = "inc_durscale",
		"Y" = "inc_tonality",
		"F" = "inc_fractality",
		"V" = "inc_velocityinc",
		"B" = "inc_bright",
		"R" = "inc_reverb",
		"T" = "inc_reverbtime",
		"J" = "inc_joyshift",
		"N" = "inc_nnotes"
	]
	$.limits = [
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

	$.button2lrmode = [
		"TRIANGLE" = "lr_change_patch",
		"CIRCLE" = "lr_change_play",
		"SQUARE" = "lr_change_loop",
		"X" = "lr_change_file"
		]

	$.helpfor = [
		"lr_change_play" = "L1=less_notes L2=previous R1=more_notes R2=advance",
		"lr_change_loop" = "L1=bs L2=del R1=record R2=setloop",
		"lr_change_patch" = "L1=chan-- L2=anysound R1=chan++ R2=goodsound"
		]

	$.button2padmode = [
		"TRIANGLE" = "pad_change_patch",
		"CIRCLE" = "pad_change_play",
		"SQUARE" = "pad_change_loop",
		"X" = "pad_change_file"
		]

	$.button2playkey = [
		"X" = [0="Q",1="R",2="U"],
		"UP" = [0="W",1="T",2="I"],
		"CIRCLE" = [0="E",1="Y",2="O"],
		"LEFT" = [0="A",1="F",2="J"],
		"RIGHT" = [0="D",1="H",2="L"],
		"TRIANGLE" = [0="Z",1="V",2="M"],
		"DOWN" = [0="X",1="B",2=","],
		"SQUARE" = [0="C",1="N",2="."]
		]

	$.init_loop_stuff()

	# Per-pattern stuff

	$.typo = []

	# Should this start at 1?
	for ( n=0; n<$.npatterns; n++ ) {
		$.init_pattern(n)
		for ( ch=1; ch<=$.chans; ch++ ) {
			$.rescale(n,ch,'c',"newage")
		}
	}

	$.currloop = 0
	$.currbank = 0
	$.topattern(1)

	for ( ch=1; ch<=$.chans; ch++ ) {
		$.typo_init(ch)
	}
	$.topattern(1)

	$.charproc = 0
	$.shiftisdown = 0
	$.incisdown = 0
	$.decisdown = 0
	$.forwardisdown = 0
	$.backwardisdown = 0
	$.quit = 0
	$.timer = -1
	$.nextpattern = -1
	$.lastfract = ''

	if ( fname != "" )
		$.typo_restore(fname)
}

method init_section(n) {
	$.loop[n] = []
	$.loop[n]["phrase"] = []
	$.loop[n]["beats"] = []
	$.loop[n]["pulse"] = []
	$.loop[n]["began"] = []
	$.loop[n]["start"] = []
	$.loop[n]["chan"] = []
	$.loop[n]["mute"] = []
	$.loop[n]["finished"] = []
	$.loop[n]["quant"] = []
	$.loop[n]["flyquant"] = []
	$.loop[n]["nloops"] = 0
}

method setnloops(n) {
	# print("SETNLOOPS n=",n)
	$.loop[$.currsect]["nloops"] = n
	$.nloops = n
}

method set_sect_vars(n) {
	# print("SETTING SECTION VARS for n=",n)
	$.loop_phrase = $.loop[n]["phrase"]
	$.loop_beats = $.loop[n]["beats"]
	$.loop_pulse = $.loop[n]["pulse"]
	$.loop_began = $.loop[n]["began"]
	$.loop_start = $.loop[n]["start"]
	$.loop_chan = $.loop[n]["chan"]
	$.loop_mute = $.loop[n]["mute"]
	$.loop_finished = $.loop[n]["finished"]
	$.loop_quant = $.loop[n]["quant"]
	$.loop_flyquant = $.loop[n]["flyquant"]
	$.nloops = $.loop[n]["nloops"]
}

method init_loop_stuff() {
	$.pulse_offset = 0
	$.pulse_time = 2b

	$.currsect = 1
	$.nextsect = 0
	$.armed_newsection = 0
	$.loop = []
	$.undo = []

	$.init_section(1)
	$.set_sect_vars(1)

	$.loop_tid = []

	$.init_one_loop(1)

	$.tap_times = []
	for ( n=0; n<4; n++ ) {
		$.tap_times[n] = 0
	}
	$.tap_index = 0
	$.overdubbing = 1
	$.armed = 1
}

method init_one_loop(n) {
	$.loop_chan[n] = $.defaultchan
	$.loop_pulse[n] = 0
	$.loop_start[n] = 0

	$.loop_began[n] = 0
	$.loop_finished[n] = 0
	$.loop_beats[n] = 0
	$.loop_phrase[n] = []
	$.loop_quant[n] = 0
	$.loop_flyquant[n] = 0
	$.loop_mute[n] = 0
	$.loop_tid[n] = -1
}

method got_addbeat(c,nw) {
	$.loop_beats[$.currloop]++
	$.fill_blanks($.currloop)
	$.got_info(c,nw)
}
method got_subbeat(c,nw) {
	if ( $.loop_beats[$.currloop] > 1 ) {
		$.loop_beats[$.currloop]--
		$.got_info(c,nw)
	} else {
		print("Can't go below 1 beat")
	}
}
method got_shuffle(c,nw) {
	ch = $.currloop
	nb = $.loop_beats[ch]
	print("SHUFFLE!")
	for ( b=0; b<nb; b++ ) {
		b2 = rand(b)
		if ( b2 != b ) {
			t = $.loop_phrase[ch][b]
			$.loop_phrase[ch][b] = $.loop_phrase[ch][b2]
			$.loop_phrase[ch][b2] = t
		}
	}
	$.got_info(c,nw)
}

method got_info(c,nw) {
	$.print_info()
}

method print_info {
	print("========")
	print("SECTION = ",$.currsect)
	# print("\nPULSE_TIME = ",$.pulse_time)
	if ( $.currloop == 0 || sizeof($.loop_beats) == 0 ) {
		print("NO loops yet...")
		return()
	} else for ( i in $.loop_beats ) {
		if ( $.loop_mute[i] )
			a = "MUTED"
		else
			a = "ACTIVE"
		if ( i == $.currloop )
			pre = "*"
		else
			pre = " "
		if ( $.loop_beats[i] != 0 ) {
			nnotes = 0
			if ( $.loop_mute[i] )
			 	muted = "MUTED"
			else
			 	muted = ""
			if ( ! ( i in $.loop_phrase ) ) {
				print("Hey, i=",i," not in loop_phrase = ",$.loop_phrase)
			} else for ( b in $.loop_phrase[i] ) {
				nnotes += sizeof($.loop_phrase[i][b])
			}
			print(pre,"Loop",i,", ",$.loop_beats[i]," beats, chan ",$.loop_chan[i],", ",nnotes," notes  ",muted)
		}
	}
	if ( $.shiftisdown ) {
		print("-------")
		ch = $.currloop
		print("Current loop = ",ch)
		nb = $.loop_beats[ch]
		for ( b=0; b<nb; b++ ) {
			print("Beat ",b," = ",$.loop_phrase[ch][b])
		}
	}
	print("========")
	for ( n=0; n<sizeof($.undo); n++ ) {
		print("undo ",n,"=",$.undo[n])
	}
	print("========")
}

method got_reset(c,nw) {
	print("GOT RESET!!")
	kill($.pulsetid)
	$.pulsetid = 0
	$.resetglobal()
	$.init_loop_stuff()
}

method got_tap(c,nw) {
	this_index = $.tap_index
	$.tap_times[this_index] = nw
	$.tap_index++
	if ( $.tap_index >= sizeof($.tap_times) ) {
		$.tap_index = 0
	}
	tot = 0
	n = $.tap_index
	tot = 0
	ntaps = 0
	maxdv = 0
	mindv = MAXCLICKS
	while ( 1 ) {
		v = $.tap_times[n]
		n++
		if ( n >= sizeof($.tap_times) )
			n = 0
		dv = v - $.tap_times[n]
		if ( dv < 0 )
			dv = -dv
		if ( dv > maxdv )
			maxdv = dv
		if ( dv < mindv )
			mindv = dv
		tot += dv
		ntaps++
		if ( n == this_index )
			break
	}
	# If the last few taps have been consistent,
	# set a new pulse time
	if ( (maxdv - mindv) < milliclicks(200) ) {
		if ( (nw-$.last_tap_set)<milliclicks(2000) ) {
			print("TOO SOON FOR ANOTHER TAP_SET")
			return()
		}
		if ( sizeof($.new_loop_phrase) != 0 ) {
			print("CAN'T SET ANOTHER NEW TAP POINT UNTIL LOOP ENDS")
			return()
		}
		$.last_tap_set = nw

		old_pulse_time = $.pulse_time
		avg = tot / ntaps

		if ( $.loop_beats[1] == 0 ) {
			# There's nothing in track 0, just set the pulse time
			$.pulse_time = avg
		} else {
			loop_leng = $.loop_beats[1] * $.pulse_time
			newbeats = integer((loop_leng / float(avg)) + 0.5)
			if ( $.forcefour ) {
				if ( newbeats > 1 && (newbeats % 4) == 1 ) {
					newbeats--
				}
				if ( newbeats > 1 && (newbeats % 4) == 3 ) {
					newbeats++
				}
			}
			print("\n*** NEW BEATS IN MASTER LOOP = ",newbeats)
			# print("Old Pulse Time = ",$.pulse_time)
			new_pulse_time = loop_leng / newbeats
			# print("New Pulse Time = ",new_pulse_time)
			new_loop_leng = newbeats * new_pulse_time
			# print("Old loop leng=",loop_leng,"  New leng=",new_loop_leng)

			# We have to go back through the loop's beat buckets
			# and re-place the notes within the new beat buckets
			$.new_loop_phrase = []
			$.new_loop_beats = []
			for ( ch in $.loop_beats ) {
				# print("ADJUSTING ch=",ch)
				oldbeats = $.loop_beats[ch]
				old_time = 0
				new_time = 0
				new_phrase = []
				for ( b=0; b<oldbeats; b++ ) {
					for ( nt in $.loop_phrase[ch][b] ) {
						old_time = b * old_pulse_time + nt.time
						newb = old_time / new_pulse_time
						newbt = old_time - newb * new_pulse_time
						if ( ! ( newb in new_phrase ) ) {
							new_phrase[newb] = ''
						}
						nt.time = newbt
						new_phrase[newb] |= nt
					}
				}

				if ( ! typeof($.new_loop_phrase) == "array" ) {
					print("Hey, new_loop_phrase isn't an array!")
				} else {
					$.new_loop_phrase[ch] = new_phrase
					$.new_loop_beats[ch] = newbeats
					$.fill_blanks(ch)
				}
			}

			$.new_pulse_time = new_pulse_time

			# $.loop_pulse[$.currloop] = 0 # force play right away
			# print("KILLING/RESTARTING PULSE_TASK, Now=",Now)
			# kill($.pulsetid)
			# $.pulsetid = task $.pulse_task(Now)
		}
		# print("PULSE TIME = ",$.pulse_time)
	}
}

method fill_blanks(ch) {
	nb = $.loop_beats[ch]
	# print("FILL_BLANKS ch=",ch,"  typeofloop_phfrase=",typeof($.loop_phrase))
	print("fill_blanks")
	print("loop_phrase = ",$.loop_phrase)
	if ( ! ( ch in $.loop_phrase ) ) {
		print("fill_blanks called with ch=",ch," not in loop_phrase!?")
		return()
	}
	for ( b=0; b<nb; b++ ) {
		if ( ! (b in $.loop_phrase[ch]) ) {
			# print("Filling in beat b=",b," with blank")
			$.loop_phrase[ch][b] = ''
		}
	}
}

method normalize(ch) {
	$.fill_blanks(ch)
	nb = $.loop_beats[ch]
	for ( b=0; b<nb; b++ ) {
		p = $.loop_phrase[ch][b]
		extra = cut(p,CUT_TIME,$.pulse_time)
		if ( sizeof(extra) != 0 ) {
			p -= extra
			$.loop_phrase[ch][b] = p
			nextb = b+1
			if ( nextb >= nb )
				nextb = 0
			extra.time -= $.pulse_time
			$.loop_phrase[ch][nextb] |= extra
		}
	}
}

method got_mute() {
	$.loop_mute[$.currloop] = 1 - $.loop_mute[$.currloop]
	if ( $.loop_mute[$.currloop] ) {
		print("Loop ",$.currloop," is now MUTED")
	} else {
		print("Loop ",$.currloop," is now ACTIVE")
	}
}

method got_undo(c,nw) {
	if ( $.loop_finished[$.currloop] == 0 ) {
		$.loop_finish($.currloop)
	}
	$.pop_undo()
}

method rmloop(loop) {
	if ( loop == 1 ) {
		print("You can't remove the first loop - use RESET to do that")
		return()
	}
	for ( ch = loop; ch <= ($.nloops-1); ch++ ) {
		$.loop_chan[ch] = $.loop_chan[ch+1]
		$.loop_beats[ch] = $.loop_beats[ch+1]
		$.loop_phrase[ch] = $.loop_phrase[ch+1]
		$.loop_mute[ch] = $.loop_mute[ch+1]
		$.loop_pulse[ch] = $.loop_pulse[ch+1]
		$.loop_start[ch] = $.loop_start[ch+1]
		$.loop_began[ch] = $.loop_began[ch+1]
	}
	delete $.loop_chan[$.nloops]
	delete $.loop_beats[$.nloops]
	delete $.loop_phrase[$.nloops]
	delete $.loop_mute[$.nloops]
	delete $.loop_pulse[$.nloops]
	delete $.loop_start[$.nloops]
	delete $.loop_began[$.nloops]

	$.setnloops($.nloops-1)
	$.currloop = loop
	if ( $.currloop > $.nloops )
		$.currloop = $.nloops
}

method got_shiftup(c,nw) {
	print("SHIFT UP")
}
method got_shiftdown(c,nw) {
	print("SHIFT DOWN")
}

method got_upchannel(c,nw) {
	$.chanchange(1)
}
method got_downchannel(c,nw) {
	$.chanchange(-1)
}

method chanchange(dir) {
	if ( $.currloop == 0 ) {
		print("No current loop")
		return()
	}
	ch = $.loop_chan[$.currloop]
	if ( dir > 0 ) {
		ch++
		if ( ch > 16 ) {
			print("Can't go above channel 16")
			ch = 16
		}
	} else {
		ch--
		if ( ch < 1 )
			ch = 1
	}
	lp = $.currloop
	$.loop_chan[lp] = ch
	for ( b in $.loop_phrase[lp] ) {
		p = $.loop_phrase[lp][b]
		p.chan = ch
		$.loop_phrase[lp][b] = p
	}
	print("MIDI Channel ",ch)
}

method loopchange(dir) {
	if ( $.loop_finished[$.currloop] == 0 ) {
		$.loop_finish($.currloop)
	}
	if ( dir > 0 ) {
		nl = $.currloop+1
		if ( ! (nl in $.loop_beats) ) {
			print("No higher loop")
		} else {
			$.currloop = nl
		}
	} else {
		nl = $.currloop-1
		if ( ! (nl in $.loop_beats) ) {
			print("No lower loop")
		} else {
			$.currloop = nl
		}
	}
	$.print_info()
}

method sectchange(dir) {
	if ( dir > 0 ) {
		nl = $.currsect+1
		if ( ! (nl in $.loop) ) {
			print("No higher sect")
			return()
		}
	} else {
		nl = $.currsect-1
		if ( ! (nl in $.loop) ) {
			print("No lower sect")
			return()
		}
	}
	$.kill_current_loop()
	$.currsect = nl
	$.currloop = 1
	$.set_sect_vars($.currsect)
	$.loop_pulse[$.currloop] = 0 # force start from beginning
	$.print_info()
}

method got_flyquant1(c,nw,keydown) {
	if ( keydown )
		$.loop_flyquant[$.currloop] = $.pulse_time / 4
	else
		$.loop_flyquant[$.currloop] = 0
}
method got_flyquant2(c,nw,keydown) {
	if ( keydown )
		$.loop_flyquant[$.currloop] = $.pulse_time / 2
	else
		$.loop_flyquant[$.currloop] = 0
}
method got_quant1(c,nw) {
	q = $.pulse_time / 4
	$.do_quant(c,nw,q)
}
method got_quant2(c,nw) {
	q = $.pulse_time / 2
	$.do_quant(c,nw,q)
}
method do_quant(c,nw,q) {
	print("Quantizing to ",q)
	for ( b in $.loop_phrase[$.currloop] ) {
		$.loop_phrase[$.currloop][b] =
			quantize($.loop_phrase[$.currloop][b],q) 
	}
	$.normalize($.currloop)
	$.loop_quant[$.currloop] = q
}

method got_purge(c,nw) {
	ch = $.currloop
	nb = $.loop_beats[ch]
	print("CLEARING channel ",ch)
	for ( b=0; b<nb; b++ ) {
		$.loop_phrase[ch][b] = ''
	}
}

method got_copy(c,nw) {
	$.new_loop_copy(c,nw)
	$.got_info(c,nw)
	print("COPY!  new channel = ",$.currloop)
}
method got_nudgeforward() {
	print("NUDGEFORWARD")
	ch = $.currloop
	nb = $.loop_beats[ch]
	t = $.pulse_time / 4
	t2 = $.pulse_time - $.pulse_time / 4
	print("t = ",t,"  t2=",t2)
	newbeats = []
	for ( b=0; b<nb; b++ ) {
		p = $.loop_phrase[ch][b]
		preb = b - 1
		if ( preb < 0 )
			preb = nb - 1
		prep = $.loop_phrase[ch][preb]
		part2 = cut(p,CUT_TIME,0,t2)
		part2.time += t
		part1 = cut(prep,CUT_TIME,t2)
		part1.time -= t2
		newbeats[b] = part1 | part2
	}
	for ( b=0; b<nb; b++ ) {
		$.loop_phrase[ch][b] = newbeats[b]
	}
}

method got_nudgebackward() {
	print("NUDGEBACKWARD")
	ch = $.currloop
	nb = $.loop_beats[ch]
	t = $.pulse_time / 4
	t2 = $.pulse_time - $.pulse_time / 4
	print("t = ",t,"  t2=",t2)
	newbeats = []
	for ( b=0; b<nb; b++ ) {
		p = $.loop_phrase[ch][b]
		postb = b + 1
		if ( postb >= nb )
			postb = 0
		postp = $.loop_phrase[ch][postb]
		part1 = cut(p,CUT_TIME,t)
		part1.time -= t
		part2 = cut(postp,CUT_TIME,0,t)
		part2.time += t2
		newbeats[b] = part1 | part2
	}
	for ( b=0; b<nb; b++ ) {
		$.loop_phrase[ch][b] = newbeats[b]
	}
}

method toggle_overdubbing(c,nw) {
	$.overdubbing =  1 - $.overdubbing
	if ( $.overdubbing )
		print("Overdubbing mode")
	else
		print("Standard mode")
}

method end_first_loop(nw) {
	$.setnloops(1)

# print("END_FIRST_LOOP, setting nloops to 1, nw=",nw,"  loop_start=",$.loop_start[$.currloop]," loop_began=",$.loop_began[$.currloop])

	old_pulse_time = $.pulse_time
	leng = nw - $.loop_start[$.currloop]
	if ( leng < 1 )
		leng = 1
	# print("LOOP_START=",$.loop_start[$.currloop],"  nw=",nw,"  LENG=",leng)
	beats = ( leng + $.pulse_time/2) / $.pulse_time
	if ( beats < 1 )
		beats = 1

	$.loop_beats[1] = beats
	$.fill_blanks(1)
	# print("BEATS = ",beats,"  leng=",leng,"  PULSE TIME WAS ",$.pulse_time)
	new_pulse_time = leng / beats
	# print("NEW PULSE TIME = ",new_pulse_time," NEW LENG = ",new_pulse_time*beats)

	# We have to go back through the loop's beat buckets
	# and re-place the notes within the new beat buckets
	old_time = 0
	new_time = 0
	new_phrase = []

	# The recorded input may have a bit of an
	# extra phrase in an extra beat bucket
	lastbeat = beats+1
	for ( b=0; b<lastbeat; b++ ) {
		if ( ! ( b in $.loop_phrase[1] ) ) {
			continue
		}
		for ( nt in $.loop_phrase[1][b] ) {
			old_time = b * old_pulse_time + nt.time
			newb = old_time / new_pulse_time
			newbt = old_time - newb * new_pulse_time
			if ( ! ( newb in new_phrase ) ) {
				new_phrase[newb] = ''
			}
			nt.time = newbt
			new_phrase[newb] |= nt
		}
	}

	$.loop_phrase[1] = new_phrase

	$.pulse_time = new_pulse_time
	$.fill_blanks($.currloop)
	# print("LOOP_PHRASE = ",$.loop_phrase[$.currloop])
	print("BEATS = ",$.loop_beats[$.currloop])

	# This value might be off a little, it might
	# be better as the old loop_start value + nbeats*pulse.
	$.loop_start[$.currloop] = nw
	$.loop_began[$.currloop] = nw

# print("END_FIRST_LOOP BBB, loop_start=",$.loop_start[$.currloop]," loop_began=",$.loop_began[$.currloop])

	$.loop_pulse[$.currloop] = 0 # force play right away

	# print("KILLING/RESTARTING PULSE_TASK, Now=",Now)
	kill($.pulsetid)
	$.pulsetid = task $.pulse_task(Now)
}

method new_loop_and_arm_for_end(c,nw) {
	# print("ARMING!!!  ADDING LOOP AND ARMING!!! ")
	$.newloop(nw,$.currloop,0)
	$.armed = 2
	$.recording = 1
	print("ARMED loop ",$.currloop)
}

method new_loop_copy(c,nw) {
	print("ADDING LOOP AND COPYING!!! ")
	$.newloop(nw,$.currloop,1)
	$.armed = 0
	$.recording = 1
	print("ARMED loop ",$.currloop)
}

method end_non_first_loop(nw) {
	leng = nw - $.loop_start[$.currloop]
	# print("LOOP_START=",$.loop_start[$.currloop],"  nw=",nw,"  LENG=",leng," last_pulse_time=",$.last_pulse_time)
	dt = nw - $.last_pulse_time
	# print("DT = ",dt)
	beats = leng / $.pulse_time
	mod = leng % ($.pulse_time)
	# print("leng=",leng," pulse_time=",$.pulse_time,"  beats=",beats,"  mod=",mod)
	if ( mod >= (($.pulse_time)/2) ) {
		# print("PAST HALF-WAY adding 1 beat")
		beats++
		# if ( $.currloop == 1 && $.loop_tid[$.currloop] > 0 )
		# 	$.pulse_adjust = -($.pulse_time - mod)
	} else {
		# if ( $.currloop == 1 && $.loop_tid[$.currloop] > 0 )
		# 	$.pulse_adjust = mod
	}
	if ( $.forcefour ) {
		if ( beats > 1 && (beats % 4) == 1 ) {
			beats--
		}
		if ( beats > 1 && (beats % 4) == 3 ) {
			beats++
		}
	}
	print("Current Loop ",$.currloop,", has",beats," beats")
	$.loop_beats[$.currloop] = beats
	$.fill_blanks($.currloop)
	# print("LOOP_PHRASE = ",$.loop_phrase[$.currloop])
	$.loop_pulse[$.currloop] = 0 # force play right away
	if ( dt >= 0 && dt < ($.pulse_time/2) ) {
		# print("Pulling off first beat...")
		realtime($.loop_phrase[$.currloop][0],$.last_pulse_time)
		$.loop_pulse[$.currloop]++
	} else if ( dt < 0 && dt > -($.pulse_time/2) ) {
		# print("DT IS NEGATIVE? =",dt,"  Pulling off first beat...")
		realtime($.loop_phrase[$.currloop][0],$.last_pulse_time)
		$.loop_pulse[$.currloop]++
	}
	# print("LOOP FINISHED for loop=",$.currloop," = 1")
}

method got_section(c,nw) {
	print("ARMING NEW SECTION")
	$.armed_newsection = 1
}

method add_undo(sect,loop,cmd) {
	n = sizeof($.undo)
	$.undo[n] = ["sect"=sect,"loop"=loop,"cmd"=cmd]
	# print("Adding undo = ",$.undo[n])
}
method pop_undo() {
	ui = sizeof($.undo) - 1
	if ( ui < 0 )
		return()
	u = $.undo[ui]
	# print("u=",u)
	ok = 1
	if ( u["cmd"] == "deleteloop" ) {
		lp = u["loop"]
		sect = u["sect"]
		print("Undo is deleting loop ",lp," in sect ",sect)
		$.rmloop(lp)
	} else {
		print("Unrecognized cmd in undo: ",u["cmd"])
		ok = 0
	}
	if ( ok )
		delete $.undo[ui]
}

method got_arm(c,nw) {
# print("GOT_ARM recording=",$.recording,"  nloops=",$.nloops," arm=",$.armed)
	if ( $.shiftisdown ) {
		$.toggle_overdubbing(c,nw)
		return()
	}
	if ( $.armed == 2 ) {
# print("ARMED is 2, we've just hit the end of the loop")
		if ( $.nloops <= 1 ) {
			# print("FIRST LOOP !!!")
			$.end_first_loop(nw)
		} else {
			$.end_non_first_loop(nw)
		}
		$.loop_finish($.currloop)
		$.armed = 0
		return()
	}
	if ( $.armed ) {
		print("got_arm when $.armed == ",$.armed,", do nothing")
		return()
	}
	# Armed is 0, so we arm for a new loop
	$.armed = 1

}

method got_notedown(c,nw) {
# print("NOTEDOWN currloop=",$.currloop,"  armed=",$.armed,"  loop_finished=",$.loop_finished[$.currloop])
	if ( $.currloop == 0 )
		c.chan = $.defaultchan
	else
		c.chan = $.loop_chan[$.currloop]
	realtime(c,nw)

	$.lastdown[c.pitch] = nw
	$.lastdownq[c.pitch] = nw
# print("SETTING LASTDOWN pitch=",c.pitch," = ",nw)
	if ( ! $.overdubbing )
		return()

# print("armed=",$.armed,"  armed-newsect=",$.armed_newsection)
	if ( $.armed_newsection ) {
		print("NOTEDOWN when ARMED for NEW SECTION, CREATING, armed=",$.armed)
		$.nsects++
		$.currsect = $.nsects + 1
		print("NEW CURRENT SECTION is ",$.currsect)
		$.init_section($.currsect)
		$.armed_newsection = 0

		print("SWITCHING TO SECTION ",$.currsect)
		$.set_sect_vars($.currsect)
		$.currloop = 0
		$.recording = 1

		print("NEW SECTION, creating initial new loop")
		$.newloop(nw,0,0)
		print("After calling newloop, currloop = ",$.currloop)

		if ( $.currloop == 1 ) {
			# print("loop ",$.currloop," LOOP START")
		} else {
			# print("Loop ",$.currloop," LOOP START nw=",nw,"  last_pulse_time=",$.last_pulse_time)
			# print("Loop ",$.currloop," LOOP START")
			nw -= $.last_pulse_time
			nw = numquant(nw,$.pulse_time)
			nw += $.last_pulse_time
			# print("QUANTIZED START tm to ",nw," SETTING LASTDOWNQ")
			$.lastdownq[c.pitch] = nw
		}

		$.loop_start[$.currloop] = nw
		$.loop_began[$.currloop] = nw
# print("XXX set loop_start to nw=",nw)

		# if ( $.currloop == 1 ) {
		# 	if ( $.pulsetid != 0 )
		# 		print("Hey, pulsetid != 0")
		# 	# print("STARTING PULSE_TASK AT nw=",nw)
		# 	$.pulsetid = task $.pulse_task(nw)
		# }

		$.armed = 2
		print("SET ARMED to 2")

		$.print_info()

		return()
	}
	# print("NOTEDOWN when ARMED=",$.armed)
	if ( $.armed == 1 ) {
		print("ARMED=1, creating new loop")
		$.newloop(nw,0,0)
		# print("After calling newloop, currloop = ",$.currloop)

		if ( $.currloop == 1 ) {
			# print("loop ",$.currloop," LOOP START")
		} else {
			# print("Loop ",$.currloop," LOOP START nw=",nw,"  last_pulse_time=",$.last_pulse_time)
			# print("Loop ",$.currloop," LOOP START")
			nw -= $.last_pulse_time
			nw = numquant(nw,$.pulse_time)
			nw += $.last_pulse_time
			# print("QUANTIZED START tm to ",nw," SETTING LASTDOWNQ")
			$.lastdownq[c.pitch] = nw
		}
		$.loop_start[$.currloop] = nw
		$.loop_began[$.currloop] = nw
# print("XXX AAA set loop_start and loop_began to nw=",nw)
		if ( $.currloop == 1 ) {
			if ( $.pulsetid != 0 )
				print("Hey, pulsetid != 0")
			# print("STARTING PULSE_TASK AT nw=",nw)
			$.pulsetid = task $.pulse_task(nw)
		}
		$.armed = 2
		# print("SET ARMED to 2")
	} else if ( $.armed == 0 ) {
		if ( $.loop_finished[$.currloop] != 0 ) {
# print("NEW LOOP AA, settings copied from current loop")
			$.newloop(nw,$.currloop,0)
			return()
		}
	} else if ( $.armed == 2 ) {
		# do nothing
	}
}

method newloop(nw,ch,copyphrase) {
	if ( nargs() < 3 ) 
		copyphrase = 0
	$.setnloops($.nloops+1)
	print("NEW loop ",$.currloop)
	ch2 = $.nloops
	$.init_one_loop(ch2)
	if ( ch <= 0 ) {
		# First loop
		$.loop_start[ch2] = nw
		$.loop_began[ch2] = nw
# print("NEWLOOP setting loop_start/began to nw=",nw)
	} else {
		$.loop_beats[ch2] = $.loop_beats[ch]
		if ( copyphrase )
			$.loop_phrase[ch2] = arraycopy($.loop_phrase[ch])
		else
			$.loop_phrase[ch2] = []
		$.loop_chan[ch2] = $.loop_chan[ch]
		$.loop_mute[ch2] = $.loop_mute[ch]
		$.loop_pulse[ch2] = $.loop_pulse[ch]
		$.loop_start[ch2] = $.loop_start[ch]
# print("SET TWO loop_start to previous loop_start = ",$.loop_start[ch])
		$.loop_began[ch2] = $.loop_began[ch]
	}
	$.currloop = ch2
	# print("NEWLOOP = ",$.currloop)
	# print("loop_beats = ",$.loop_beats)
}

method got_noteup(c,nw) {

	c.chan = $.loop_chan[$.currloop]
	realtime(c,nw)

# print("NOTEUP c=",c,"  armed=",$.armed,"  currloop=",$.currloop)
	if ( ! ( c.pitch in $.lastdown) || $.lastdown[c.pitch] == 0 ) {
		print("Lastdown for c.pitch=",c.pitch," is 0?")
		return()
	}
	if ( ! $.overdubbing ) {
		return()
	}
	if ( $.armed == 1 ) {
		print("GOT NOTE WHEN ARMED==1  nloops=",$.nloops)
		$.new_loop_and_arm_for_end(c,nw)
		return()
	}
# print("RECORDING noteup")
	if ( ! ( c.pitch in $.lastdownq) ) {
		print("Lastdownq for c.pitch=",c.pitch," doesn't exist!?")
		return()
	}
	lastdown = $.lastdown[c.pitch]
	lastdownq = $.lastdownq[c.pitch]
# print("lastdownq=",lastdownq,"  loop_start=",$.loop_start[$.currloop],"  loop_began=",$.loop_began[$.currloop])
	tmpdtq = lastdownq - $.loop_began[$.currloop]
# print("NOTEUP tmpdtq = ",tmpdtq)
	if ( tmpdtq < 0 ) {
		tmpdtq += $.loop_beats[$.currloop] * $.pulse_time
		# print("ADJUSTED NOTEUP tmpdtq = ",tmpdtq)
	}
# print("LOOP_PULSE of loop=",$.currloop," is ",$.loop_pulse[$.currloop])
	p = c
	p.time = tmpdtq
	d = nw - lastdown
	p.dur = nw - lastdown
	if ( d <= 0 )
		d = 1
	p.dur = d
	p.length = p.dur
	p.type = NOTE

	beat = p.time / $.pulse_time

	p.time -= beat * $.pulse_time

	if ( typeof($.loop_phrase) != "array" ) {
		print("Hey, loop_phrase isn't an array?")
	}
	if ( ! ( $.currloop in $.loop_phrase ) ) {
		print("Hey, currloop=",$.currloop," isn't in loop_phrase")
		return()
	}
	if ( beat in $.loop_phrase[$.currloop] ) {
		$.loop_phrase[$.currloop][beat] |= p
	} else {
		$.loop_phrase[$.currloop][beat] = p
	}
# print("beat = ",beat,"  P = ",p,"  loop_phrase[",$.currloop,"]=",$.loop_phrase[$.currloop][beat])
# print("beat=",beat," p=",p," ph=",$.loop_phrase[$.currloop][beat])
}

method got_nonnote(c,nw) {

	c.chan = $.currloop
	realtime(c,nw)

	if ( ! $.overdubbing ) {
		return()
	}
	tmpdtq = nw - $.loop_start[$.currloop]
	p = c
	p.time = tmpdtq

	beat = p.time / $.pulse_time

	p.time -= beat * $.pulse_time

	if ( beat in $.loop_phrase[$.currloop] ) {
		$.loop_phrase[$.currloop][beat] |= p
	} else {
		$.loop_phrase[$.currloop][beat] = p
	}
# print("beat=",beat," p=",p," ph=",$.loop_phrase[$.currloop][beat])
}

method inputtask(readfrom)
{
	# onexit(global(domethod),$,"final_cleanup")
	ignorenextup = 0

	ctrl = 0
	while ( $.quit == 0 ) {

		c = get(readfrom)

		nw = nextquant(Now,$.quant)
# print("INPUT c=",c," nw=",nw,"  Now=",Now,"  $.quant=",$.quant)

		ctype = typeof(c)

		if ( ctype == "array" ) {
			# It's a pad event
			print("ARRAY c=",c)
			j = c["j"]
			b = c["b"]
			v = c["v"]
			continue
		}

		if ( ctype == "integer" ) {
			$.currloop = c
			continue
		}
		if ( ctype == "phrase" ) {
			nonnote = 0
			if ( c.type == NOTEON )
				keydown = 1
			else if ( c.type == NOTEOFF )
				keydown = 0
			else {
				nonnote = 1
			}
			if ( c.chan == $.control_chan ) {
				if ( ! keydown ) {
					if ( c.pitch == $.control_flyquant1 )
						$.got_flyquant1(c,nw,keydown)
					else if ( c.pitch == $.control_flyquant2 )
						$.got_flyquant2(c,nw,keydown)
					continue
				}
				lock($)
				if ( c.pitch == $.control_arm) {
					$.got_arm(c,nw)
					unlock($)
					continue
				} else if ( c.pitch == $.control_tap ) {
					$.got_tap(c,nw)
					unlock($)
					continue
				} else if ( c.pitch == $.control_info ) {
					$.got_info(c,nw)
					unlock($)
					continue
				}

				# Everything below needs something
				# in the channel
				ch = $.currloop
				if ( ch==0 || $.loop_beats[ch] == 0 ) {
					print("There's nothing in channel ",ch)
					unlock($)
					continue
				}
			
				if ( c.pitch == $.control_purge )
					$.got_purge(c,nw)
				else if ( c.pitch == $.control_reset )
					$.got_reset(c,nw)
				else if ( c.pitch == $.control_info )
					$.got_info(c,nw)
				else if ( c.pitch == $.control_punchinout )
					$.got_punchinout(c,nw)
				else if ( c.pitch == $.control_addbeat )
					$.got_addbeat(c,nw)
				else if ( c.pitch == $.control_subbeat )
					$.got_subbeat(c,nw)
				else if ( c.pitch == $.control_shuffle )
					$.got_shuffle(c,nw)
				else if ( c.pitch == $.control_copy )
					$.got_copy(c,nw)
				else if ( c.pitch == $.control_mute )
					$.got_mute(c,nw)
				else if ( c.pitch == $.control_nudgeforward )
					$.got_nudgeforward(c,nw)
				else if ( c.pitch == $.control_nudgebackward )
					$.got_nudgebackward(c,nw)
				else if ( c.pitch == $.control_upchannel )
					$.got_upchannel(c,nw)
				else if ( c.pitch == $.control_downchannel )
					$.got_downchannel(c,nw)
				else if ( c.pitch == $.control_quant1 )
					$.got_quant1(c,nw)
				else if ( c.pitch == $.control_quant2 )
					$.got_quant2(c,nw)
				else if ( c.pitch == $.control_flyquant1 )
					$.got_flyquant1(c,nw,keydown)
				else if ( c.pitch == $.control_flyquant2 )
					$.got_flyquant2(c,nw,keydown)
				unlock($)
				continue
			}
	
			c.time = 0
			if ( nonnote )
				$.got_nonnote(c,nw)
			else if ( keydown )
				$.got_notedown(c,nw)
			else
				$.got_noteup(c,nw)
			continue
		}

		char1 = substr(c,1,1)

		# An initial "P" means that this input is
		# coming from a "play-only" device
		if ( char1 == "P" ) {
			c = substr(c,2)
			playonly = 1
		} else {
			playonly = 0
		}

		keydown = (substr(c,1,1) == "+" )
		c = substr(c,2)

		if ( keydown ) {
			$.lastdown[c] = nw
			$.lastdownq[c] = nw
# print("KEYDOWN SETTING LASTDOWN[",c," to ",nw," $.lastdown = ",$.lastdown)
		} else {
			if ( c == ignorenextup ) {
				ignorenextup = 0
				continue
			}
		}

		if ( ($.forwardisdown || $.backwardisdown) && keydown ) {
			if ( $.forwardisdown )
				p = $.next_in_sourcephr($.currloop)
			else
				p = $.prev_in_sourcephr($.currloop)
			if ( p != '' ) {
				$.phr[$.currloop][c] = p
			}
		}

		if ( playonly ) {
			f = $.mode[$.currloop]["func"]
			$.(f)(keydown,c,nw)
			continue
		}

		if ( c == "DEL" ) {
			if ( keydown ) {
				print("RESETTING LOOP")
				$.typo_restart()
			}
			continue
		}

		if ( c == "CTRL" ) {
			ctrl = keydown
			continue
		}

		if ( $.charproc != 0 ) {
			if ( keydown ) {
				f = $.charproc
				lock($)
				$.(f)(c,nw)
				unlock($)
				# The function might have changed the
				# function as a way to grab the next character
				# If so, leave it alone
				if ( $.charproc == f )
					$.charproc = 0
				ignorenextup = c
			}
			continue
		}

		if ( (c in Tnumbers) ) {
			if ( keydown ) {
				cn = ascii(c) - ascii("0")
				if ( cn == 0 )
					cn = 10
				if ( cn > 0 && cn <= $.chans ) {
					$.currloop = cn
					$.print_chan_line(cn,1)
					# if ( $.recording == 0 && $.always_record != 0 )
					# 	$.got_arm("r",Now)
				}
			}
			continue
		}


		if ( c == "SHIFT" ) {
			$.shiftisdown = keydown
			continue
		}
# print("c=",c," keydown=",keydown," ctrl=",ctrl)
		if ( c == "BS" ) {
			$.got_undo(c,nw)
		}

		if ( $.shiftisdown != 0 && (c in $.shift_immediate_list) ) {
			lock($)
			# Call it right away
			f = $.shift_immediate_list[c]
			$.(f)(0,nw)
			unlock($)
			ignorenextup = c
			continue
		}

		if ( c == "UPARROW" ) {	# used to be "."
			$.incisdown = keydown
			continue
		}
		if ( c == "DOWNARROW" ) {	# used to be ","
			$.decisdown = keydown
			continue
		}
		if ( c == "RIGHTARROW" ) {	# used to be "."
			$.forwardisdown = keydown
			continue
		}
		if ( c == "LEFTARROW" ) {	# used to be ","
			$.backwardisdown = keydown
			continue
		}
		if ( c == "END" ) {
			if ( keydown ) {
				print("Sending all-notes-off...")
				$.realtime(ano())
			}
			continue
		}	

		if ( $.incisdown || $.decisdown ) {
			if ( ! keydown )
				continue
			if ( (c in $.incdeclist) ) {
				f = $.incdeclist[c]
				# If both < and > are down, we set it to middle
				if ( $.incisdown && $.decisdown ) {
					v = INCDEC_MID
				} else {
					if ( $.shiftisdown ) {
						if ( $.incisdown )
							v = INCDEC_MAX
						else
							v = INCDEC_MIN
					} else {
						if ( $.incisdown )
							v = INCDEC_INC
						else
							v = INCDEC_DEC
					}
				}
				lock($)
				$.(f)(v)
				unlock($)
			}
			continue
		}

		if ( c in $.ctrl_immediate_list1 ) {
			# Call it right away
			f = $.ctrl_immediate_list1[c]
			lock($)
			$.(f)(0,nw)
			unlock($)
			ignorenextup = c
			continue
		}
		if ( c in $.ctrl_immediate_list2 ) {
			ch = $.currloop
			if ( ch==0 || $.loop_beats[ch] == 0 ) {
				print("There's nothing in channel ",ch)
				continue
			}
			
			# Call it right away
			f = $.ctrl_immediate_list2[c]
			lock($)
			$.(f)(0,nw)
			unlock($)
			ignorenextup = c
			continue
		}
		if ( c in $.ctrl_list ) {
			# print("CONTROL got char = ",c)
			# Call it afte we get the next character
			$.charproc = $.ctrl_list[c]
			ignorenextup = c
			continue
		}

	}
}

method initial_ctlr() {
	arr = []
	for ( i in $.controllers ) {
		arr[i] = $.controllers[i]
	}
	return(arr)
}

}

