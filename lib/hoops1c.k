#
# Hoops - Herb's Loops

INCDEC_MID = 0
INCDEC_MIN = -2
INCDEC_MAX = 2
INCDEC_INC = 1
INCDEC_DEC = -1

function hc() {
	while ( 1 ) {
		hoops1c()
		rereadlib()
	}
}

function hoops1c_server() {

	if ( ! defined(Syncport) )
		Syncport = -1

	t = new hoops1c_object()

	t.start()
	t.starttasks()
}

function hoops1c() {

	if ( Machine != "win" ) {
		print("hoops1c() probably only works on Windows, sorry!")
		return()
	}

	if ( defined(Hoopsisrouted) && Hoopsisrouted == 1 )
		standalone = 0
	else
		standalone = 1

	if ( standalone ) {
		oldMerge = Merge
		Merge = 0
	}
	if ( ! defined(Syncport) )
		Syncport = -1

	t = new hoops1c_object()

	t.start()
	t.starttasks()

	if ( standalone ) {
		t.waittilldone()

		Merge = oldMerge
		print("Hoops done.")
	}
}

class hoops1c_object {

method init() {

	if ( defined(Hoopsisrouted) && Hoopsisrouted == 1 )
		$.standalone = 0
	else
		$.standalone = 1

	if ( $.standalone ) {
		$.grabconsole = 1
		$.grabmidiin = 1
	} else {
		$.grabconsole = 0
		$.grabmidiin = 0
	}
	$.constid = -1
	$.miditid = -1
	$.startphrase = ''
	$.clockphrase = ''
	$.stopphrase = ''
	$.chord_time = 1b/16
	$.longpress = 2b
	$.always_record = 1
	$.forcefour = 0
	$.defmultiple = 3
	$.transmultiple = $.defmultiple
	$.tid = -1
	$.inputtid = -1
	$.inputf = -1
	$.verbose = 0
	$.consf = -1
	$.nsects = 0
	$.notifyobj = $0
	$.last_rec = 0
	$.initial_tempo = tempo()
	if ( defined(Notranspose) )
		$.notranspose = Notranspose
	else
		$.notranspose = []

	$.gm = 0

	# if ( defined(TypoGM) && TypoGM == 1 )
	# 	$.gm = 1
	# else
	#	$.gm = 0

	$.typo_setup()
}

method setnotify(obj) {
	$.notifyobj = obj
}

method getnloops {
	nl = 0
	for ( c=1; c<=$.nloops; c++ ) {
		if ( $.loop_finished[c] )
			nl++
	}
	return(nl)
}
method getpulse {
	return($.pulse_time)
}
method getbeatsn(n) {
	return($.loop_beats[n])
}
method getchann(n) {
	return($.loop_chan[n])
}
method getmuten(n) {
	return($.chan_mute[$.loop_chan[n]])
}
method getcurrbeat(n) {
	np = $.loop_pulse[n] - 1
	if ( np < 0 )
		np = $.loop_beats[n] - 1
	# print("getcurrbeat of n=",n," is ",np,"  pulse=",$.loop_pulse[n])
	return(np)
}
method getloopn(n) {
	nb = $.loop_beats[n]
	p = ''
	lc = $.loop_chan[n]
	qnt = $.chan_quant[lc]
	for ( b=0; b<nb; b++ ) {
		if ( b in $.loop_phrase[n]) {
			if ( qnt > 0 ) {
				q = $.loop_phrase_q[n][b]
			} else {
				q = $.loop_phrase[n][b]
			}
			q.length = $.pulse_time
			p += q
		}
	}
	return(p)
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
method start() {

	lock($)
	kill($.tid)
	$.tid = task $.realtimetask()

	if ( $.verbose )
		print("Hoops away ...  (control-X Q will quit)")

	$.lr_change_func = []
	$.pad_change_func = []
	$.startdown = []
	$.selectdown = []
	$.inputf = open()
	kill($.inputtid)
	$.inputtid = task $.inputtask($.inputf)
	unlock($)
}

method starttasks() { 
	if ( $.grabconsole ) {
		Consecho = 0
		Consupdown = 1
		$.consf = Root.grabconsole()
		$.constid = task $.cons_task($.consf,$.inputf)
	}
	if ( $.grabmidiin ) {
		$.miditid = task $.midi_task($.inputf)
	}
	$.pulsetid = 0
	if ( $.standalone )
		print("Hoops is alive... (standalone)")
	else
		print("Hoops is alive... (routed)")

	if ( ! $.standalone )
		Hoops = $
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

	if ( $.inputf >= 0 ) {
		close($.inputf)
		$.inputf = -1
	}

	$.killrealtime()
	if ( $.consf >= 0 ) {
		kill($.constid)
		Consupdown = 0
		Consecho = 1
		Root.releaseconsole()
	}
	kill($.pulsetid)
	if ( $.miditid >= 0 )
		kill($.miditid)
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

method realtime(p) {
	if ( defined(Ergo) ) {
		task Ergo.play(p)
	}
	return(realtime(p))
}

method realtime2(p,tm) {
	if ( defined(Ergo) ) {
		task Ergo.play2(p)
	}
	return(realtime(p,tm))
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
			print("REALTIMETASK CALLING topattern")
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

# 		# Not working
# 		if ( $.playprev != 0 ) {
# 			$.play_loop($.playprev)
# 			tm = $.playprev + loopleng
# 			$.playprev = 0
# 		} else {
# 			$.play_loop(tm)
# 			tm += loopleng
# 		}

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
	return(p)
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
	$.undo_firstcnt = 3

	$.wait_for_tap = 0
	$.beat_pending = 0
	$.go_beat_pending = 0
	$.last_nudge_val = 0
	$.nudge_pending = 0
	$.go_nudge_pending = 0
	$.trans_pending = 0
	$.go_trans_pending = 0
	$.quant_pending = 0
	$.last_quant_val = 0
	$.go_quant_pending = 0
	$.loopfade = 0
	$.recording = 0
	$.armed = 0
	$.nsects = 0
	$.overdubbing = 1
	$.pulse_adjust = 0
	$.currloop = 0
	$.last_tap_set = 0
	$.new_pulse_time = 0
	$.new_loop_phrase = []
	$.new_loop_beats = []

	$.shiftisdown = 0
	$.incisdown = 0
	$.decisdown = 0

	$.CHAN_down = 0
	$.UNDO_down = 0
	$.UNDO_done = 0
	$.TRANS_down = 0
	$.TRANS_count = 0
	$.TRANS_all = 0
	$.TRANS_val = 0
	$.GO_down = 0
	$.COPY_down = 0
	$.EXTERN1_down = 0
	$.BEAT_down = 0
	$.BEAT_count = 0
	$.BEAT_all = 0
	$.QUANT_down = 0
	$.NUDGE_down = 0
	$.MUTE_down = 0
	$.RAND_down = 0
	$.RAND_notes = ''

	$.forwardisdown = 0
	$.backwardisdown = 0
}

method resetstuff() {

	$.resetglobal()

	$.typo[$.currpatt]["tonality"] = 0

	for ( c=1; c<=$.chans; c++ ) {
		$.typo[$.currpatt]["ctlr"][c] = $.initial_ctlr()
		$.typo[$.currpatt]["octshift"][c] = 0
		$.typo[$.currpatt]["durscale"][c] = 1
		$.typo[$.currpatt]["velocity"][c] = 0
	}
}

method ctrl_exec(c,nw) {
	if ( c == "Q" ) {
		$.exit = 1
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

method print_bank(b) {
	for ( n=0; n<10; n++ ) {
		if ( n in $.banks[b] ) {
			any = 1
			print("Bank ",b," Sound slot",n,"is",$.banks[b][n])
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

# print("TOPATTERN called n=",n)
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
	$.durscale = Tp["durscale"]
	$.velocityinc = Tp["velocity"]
	$.looprestep = Tp["looprestep"]
	$.phr = Tp["phrase"]
	$.banks = Tp["banks"]
	$.assigns = Tp["assigns"]
	$.changes = Tp["changes"]
	$.sourcephr = Tp["sourcephr"]

# print("TOPATTERN, sourcephr size is",sizeof($.sourcephr)," sourcephr=",$.sourcephr)
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

	$.go_mode = 0

	$.sendclock = 0
	if ( defined(Hoopsclock) )
		$.sendclock = Hoopsclock

	clock1 = 'xf8'
	clock1.length = 16
	# print("CLOCK is ",clock1)
	$.clockphrase = repeat(clock1,24)
	if ( defined(Clockports) ) {
		p = $.clockphrase
		p2 = 'xfa'
		p3 = 'xfc'
		r = ''
		r2 = ''
		r3 = ''
		for ( prt in Clockports ) {
			p.port = prt
			p2.port = prt
			p3.port = prt
			r |= p
			r2 |= p2
			r3 |= p3
		}
		$.clockphrase = r
		$.startphrase = r2
		$.stopphrase = r3
		# print("clockphrase=",$.clockphrase)
	}
	$.grabquant = 1b/4
	$.npatterns = 10
	$.warpall = 0
	$.defaultmode = "L"
	$.keyorder   = "QAZWSXEDCRFVTGBYHNUJMIK,OL.123456789";
	$.keyinherit = "QAZWSXEDCQAZWSXEDCQAZWSXEDCQAZWSXEDC";
	if ( defined(HoopsDebug) )
		$.debug = HoopsDebug
	else
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
	$.currchan = $.defaultchan

	$.defaultbeats = 8


	# These are the MIDI note numbers
	if ( defined(HoopNotes) ) {
		$.control_REC = HoopNotes["REC"]		# R
		$.control_UNDO = HoopNotes["UNDO"]		# U
		$.control_CHAN = HoopNotes["CHAN"]		# C
		$.control_TAP = HoopNotes["TAP"]		# T
		$.control_QUANT = HoopNotes["QUANT"]		# Q
		$.control_TRANS = HoopNotes["TRANS"]		# X
		$.control_NUDGE = HoopNotes["NUDGE"]		# N
		$.control_GO = HoopNotes["GO"]		# G
		$.control_MUTE = HoopNotes["MUTE"]		# M
		$.control_BEAT = HoopNotes["BEAT"]		# B
		$.control_COPY = HoopNotes["COPY"]		# P
		$.control_KLOCK = HoopNotes["KLOCK"]		# K
		if ( "RAND" in HoopNotes) {
			$.control_RAND = HoopNotes["RAND"]	# A
		} else {
			$.control_RAND = $.control_KLOCK
		}
			
		$.control_EXTERN1 = HoopNotes["EXTERN1"]		#
	} else {
		$.control_REC = 9		# R
		$.control_UNDO = 4		# U
		$.control_CHAN = 5		# C
		$.control_TAP = 12		# T
		$.control_QUANT = 3		# Q
		$.control_TRANS = 2		# X
		$.control_NUDGE = 6		# N
		$.control_GO = 1		# G
		$.control_MUTE = 11		# M
		$.control_BEAT = 7		# B
		$.control_COPY = 8		# P
		$.control_KLOCK = 10		# K
		$.control_RAND = 10		# K
		$.control_EXTERN1 = 9		# E
	}
	# print("control_EXTERN1=",$.control_EXTERN1)

	$.control_chan = 16  

	# $.control_purge = 14 
	# $.control_reset = 15
	# $.control_shuffle = 12
	# $.control_info = 55
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
		if ( Syncport >= 0 && n.port == Syncport )
			continue
		put(tof,n)
	}
}

method midi_feed(n) {
	if ( Syncport >= 0 && typeof(n) == "phrase" && n.port == Syncport )
		return()
	put($.inputf,n)
}

method quant_name_of(qv) {
	if ( qv == 1 ) {
		s = "1/4 pulse"
	}
	else if ( qv == 2 ) {
		s = "1/2 pulse"
	}
	else {
		s = "1 pulse"
	}
	return(s)
}

method do_quant(qv,ch) {
	if ( qv == 1 ) {
		q = $.pulse_time / 4
	}
	else if ( qv == 2 ) {
		q = $.pulse_time / 2
	}
	else {
		q = $.pulse_time
	}
	s = $.quant_name_of(qv)
	print("QUANTIZING channel",ch,"to",s)
	for ( c=1; c<=$.nloops; c++ ) {
		if ( $.loop_chan[c] != ch )
			continue
		if ( $.chan_mute[$.loop_chan[c]] )
			continue
		nb = $.loop_beats[c]
		$.loop_phrase_q[c] = []
		for ( b in $.loop_phrase[c] ) {
			$.loop_phrase_q[c][b] = ''
		}
		for ( b in $.loop_phrase[c] ) {
			p = $.loop_phrase[c][b]
			p = quantize(p,q)
			$.loop_phrase_q[c][b] |= p
			extra = cut(p,CUT_TIME,$.pulse_time)
			if ( sizeof(extra) != 0 ) {
				p -= extra
				$.loop_phrase_q[c][b] -= extra
				nextb = b+1
				if ( nextb >= nb )
					nextb = 0
				extra.time -= $.pulse_time
				$.loop_phrase_q[c][nextb] |= extra
			}
		}
		# print("FINAL phrase_q = ",$.loop_phrase_q[c])
	}
	$.send_notify("quant")
}

method do_trans(t,allchans) {
	if ( t == 999 ) {
		tp = "UNDOING transpose"
	} else {
		tp = "DOING transpose "+string(t)
	}
	if ( allchans )
		print(tp,"of ALL CHANNELS")
	else
		print(tp,"of channel",$.currchan)
	for ( c=1; c<=$.nloops; c++ ) {
		lc = $.loop_chan[c]
		if ( lc in $.notranspose )
			continue
		if ( allchans == 0 && lc != $.currchan )
			continue
		for ( b in $.loop_phrase[c] ) {

			p = $.loop_phrase[c][b]
			if ( typeof(p) != "phrase" ) {
				print("Hey, loop_phrase c=",c," b=",b," is not a phrase?")
				continue
			}
			if ( t == 999 ) {
				p = transpose(p,-$.loop_trans[c])
			} else {
				p = transpose(p,t)
			}
			$.loop_phrase[c][b] = p

			if ( $.chan_quant[lc] > 0 ) {
				pq = $.loop_phrase_q[c][b]
				if ( t == 999 ) {
					pq = transpose(pq,-$.loop_trans[c])
				} else {
					pq = transpose(pq,t)
				}
				$.loop_phrase_q[c][b] = pq
			}
		}
		if ( t == 999 )
			$.loop_trans[c] = 0
		else
			$.loop_trans[c] += t
	}
}

method nudge_name_of(nv) {
	if ( nv < 0 ) {
		nv = -nv
		s = "backward"
	} else {
		s = "forward"
	}
	if ( nv == 1 ) {
		s = s + " 1/4 pulse"
	}
	else if ( nv == 2 ) {
		s = s + " 1/2 pulse"
	}
	else if ( nv == 3 ) {
		s = s + " 1 pulse"
	}
	return(s)
}

method nudge_val_of(nv) {
	if ( nv < 0 ) {
		nv = -nv
		dir = -1
	} else {
		dir = 1
	}
	if ( nv == 1 ) {
		s =  dir * $.pulse_time / 4
	}
	else if ( nv == 2 ) {
		s =  dir * $.pulse_time / 2
	}
	else if ( nv == 3 ) {
		s =  dir * $.pulse_time
	}
	return(s)
}

method do_nudge(nudge) {
	nv = $.nudge_val_of(nudge)
	print("NUDGING",$.nudge_name_of(nudge))
	if ( nv > 0 ) {
		$.do_nudgeforward(nv)
	} else {
		$.do_nudgebackward(-nv)
	}
	$.send_notify("loopchange")
}

method pulse_task(nextpulse) {
	$.last_pulse_time = nextpulse
	# print("PULSE_TASK START")
	$.startwassent = 0
	$.startshouldbesent = 0
	while ( 1 ) {
		# print("TOP OF PULSE_TASK nextpulse=",nextpulse)
		sleeptill(nextpulse-4)
		lock($)

		if ( $.sendclock ) {
			realtime($.clockphrase,nextpulse)
		}
		if ( $.nextsect > 0 ) {
			$.currsect = $.nextsect
			$.nextsect = 0
			print("PULSE_TASK IS SWITCHING TO SECTION ",$.currsect)
			$.set_sect_vars($.currsect)
			$.currloop = 0
			$.recording = 0
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
		if ( $.go_trans_pending != 0 ) {
			$.do_trans($.go_trans_pending,0)
			$.go_trans_pending = 0
		}
		if ( $.go_nudge_pending != 0 ) {
			if($.debug)print("DOING NUDGE = ",$.go_nudge_pending)
			$.do_nudge($.go_nudge_pending)
			$.go_nudge_pending = 0
		}
		if ( $.go_quant_pending != 0 ) {
			if($.debug)print("QUANTIZING by ",$.go_quant_pending," pulse_time =",$.pulse_time)
			for ( c=1; c<=$.nloops; c++ ) {
				if ( $.loop_chan[c] != $.currchan )
					continue
				if ( $.chan_mute[$.loop_chan[c]] )
					continue
				nb = $.loop_beats[c]
				for ( b in $.loop_phrase[c] ) {
					p = $.loop_phrase[c][b]
					p = quantize(p,$.go_quant_pending)
					$.loop_phrase[c][b] = p
					extra = cut(p,CUT_TIME,$.pulse_time)
					if ( sizeof(extra) != 0 ) {
						p -= extra
						$.loop_phrase[c][b] = p
						nextb = b+1
						if ( nextb >= nb )
							nextb = 0
						extra.time -= $.pulse_time
						$.loop_phrase[c][nextb] |= extra
					}
				}
			}
			$.go_quant_pending = 0
		}
		for ( c=1; c<=$.nloops; c++ ) {
			ch = $.loop_chan[c]
			if ( $.chan_mute[ch] ) {
				# The current pulse of muted things
				# is still advanced
				$.advance_loop_pulse(c,nextpulse)
				continue
			}
			if ( $.loop_beats[c] <= 0 )
				continue
			if ( $.chan_quant[ch] > 0 )
				phr = $.loop_phrase_q[c]
			else
				phr = $.loop_phrase[c]
			b = $.loop_pulse[c]
			if ( c == 1 && b == 0 ) {
				if ( $.startphrase != '' && $.startwassent == 0 && $.startshouldbesent == 1 ) {
					print("SENDING START")
					realtime($.startphrase)
					$.startwassent = 1
				}
			}
			if ( b in phr ) {
				p = phr[b]
				if ( typeof(p) != "phrase" ) {
					print("Hmmm, b=",b," in phr=",phr," is not a phrase")
				} else if ( p != '' ) {

					if ( ch == $.currchan && $.RAND_down!=0 && $.RAND_notes != '' ) {
						rnts = p{??.port==99}
						p -= rnts

# print("$.RAND_notes = ",$.RAND_notes)
						rnts = $.RAND_notes
						rnts.port = 99
						p |= rnts
						phr[b] = p
					}
					rnts = p{??.port==99}
					if ( rnts != '' ) {
# print("rnts = ",rnts)
						p -= rnts
						rr = p
						result = ''
						for ( nt in rr ) {
							ri = 1+rand(sizeof(rnts))
							rn = rnts%ri
							if ( rn.chan == $.control_chan ) {
								# remove note
							} else {
								nt.pitch = rn.pitch
								result |= nt
							}
						}
						p = result
					}
					# print("HEY!! CHAN=",c,"  PLAYING LOOP (b=",b,") ",p," Now=",Now," thispulse=",thispulse)
					$.loop_tid[c] = $.realtime2(p,thispulse)
				}
			}

			$.advance_loop_pulse(c,nextpulse)
		}
		unlock($)
		$.send_notify("pulse")
	}
}

method advance_loop_pulse(c,nextpulse) {
	$.loop_pulse[c]++
	b = $.loop_pulse[c]
	if ( $.loop_beats[c] > 0 && b >= $.loop_beats[c] ) {
		# Loop back to the beginning of this loop
		if ( $.loop_finished[c] == 0 ) {
			$.loop_finish(c)
		}

		$.loop_pulse[c] = 0
		$.loop_began[c] = nextpulse
		# print("BACK TO BEGINNING, loop=",c,"  finished=",$.loop_finished[c],"  began=",$.loop_began[c],"  Now=",Now)
		if ( $.new_pulse_time != 0 ) {

			print("PULSE IS CHANGING")
			if ( c == 1 ) {
				$.startshouldbesent = 1
			}
			for ( k=1; k <= $.nloops; k++ ) {
				$.loop_phrase[k] = $.new_loop_phrase[k]
				if ( $.loop_beats[k] != 0 ) {
					$.loop_beats[k] = $.new_loop_beats[k]
					# print("New beats for k=",k," is ",$.loop_beats[k])
				}
				$.fill_blanks(k)
			}
			$.set_pulse_time($.new_pulse_time)
			$.new_pulse_time = 0
			$.new_loop_phrase = []
			$.new_loop_beats = []
		}
		# kill($.loop_tid[c])
	}
}

method add_undo1(sect,cmd,v1,v2) {
	if ( nargs() < 4 )
		v2 = 0
	u = []
	$.collect_undo(u,sect,cmd,v1,v2)
	$.add_undo(u)
}

method loop_finish(lp) {
	if ( $.debug ) { print("FINISHED UP loop ",lp) }
	$.loop_finished[lp] = 1
	$.add_undo1($.currsect,"deleteloop",lp)
	$.fill_blanks(lp)

	ch = $.loop_chan[lp]
	$.chan_quant[ch] = 0
	$.send_notify("loopchange")
}

method typo_setup() {

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
		"R" = "got_REC",
		"U" = "got_UNDO",
		"C" = "got_CHAN",
		"T" = "got_TAP",
		"Q" = "got_QUANT",
		"X" = "got_TRANS",
		"N" = "got_NUDGE",
		"G" = "got_GO",
		"M" = "got_MUTE",
		"B" = "got_BEAT",
		"P" = "got_COPY",
		"K" = "got_KLOCK",
		"E" = "got_EXTERN1",
		"." = "got_EXIT",
		";" = "got_DEBUG",
		"=" = "got_info"		# Info
		]

	# These need a valid/current channel
	$.ctrl_immediate_list2 = [

# 		"S" = "got_section",
# 		"N" = "got_nudgeforward",
# 		"B" = "got_nudgebackward",
# 		"F" = "got_shuffle",

		# "D" = "got_downchannel"
		# "F" = "ctrl_ano"
		]
	$.shift_immediate_list = [
		"U" = "got_shiftup",
		"D" = "got_shiftdown"
		]

	$.ctrl_list = [
		# O" = "ctrl_offset",		# Offset
		# N" = "ctrl_pan",		# Pan
		"." = "ctrl_note",		# Note
		# P" = "ctrl_pattern",		# Pattern
		# R" = "ctrl_pattern_reset",	# Pattern (reset on next loop)
		# S" = "ctrl_sound",		# Sound
		# T" = "ctrl_transitions",	# Transitions
		# "L" = "ctrl_length",		# Length
		# "W" = "ctrl_warp",		# Warp
		# "I" = "ctrl_immediate",		# Immediate
		"X" = "ctrl_exec"		# Xecute
	]

	$.incdeclist = [
		"A" = "inc_loopfade",
		"S" = "inc_sect",
		"V" = "inc_vol",
		"E" = "inc_express",
		"O" = "inc_octave",
		"D" = "inc_durscale",
		"Y" = "inc_tonality",
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
	$.exit = 0
	$.nextpattern = -1
	$.lastfract = ''
}

method init_section(n) {
	$.loop[n] = []
	$.loop[n]["phrase"] = []
	$.loop[n]["phrase_q"] = []
	$.loop[n]["beats"] = []
	$.loop[n]["pulse"] = []
	$.loop[n]["began"] = []
	$.loop[n]["start"] = []
	$.loop[n]["chan"] = []
	$.loop[n]["trans"] = []
	$.loop[n]["finished"] = []
	$.loop[n]["nloops"] = 0

	$.loop[n]["mute"] = []
	for ( c=1; c<=$.chans; c++ )
		$.loop[n]["mute"][c] = 0
	$.loop[n]["quant"] = []
	for ( c=1; c<=$.chans; c++ )
		$.loop[n]["quant"][c] = 0
}

method setnloops(n) {
	# print("SETNLOOPS n=",n)
	$.loop[$.currsect]["nloops"] = n
	$.nloops = n
}

method set_sect_vars(n) {
	# print("SETTING SECTION VARS for n=",n)
	$.loop_phrase = $.loop[n]["phrase"]
	$.loop_phrase_q = $.loop[n]["phrase_q"]
	$.loop_beats = $.loop[n]["beats"]
	$.loop_pulse = $.loop[n]["pulse"]
	$.loop_began = $.loop[n]["began"]
	$.loop_start = $.loop[n]["start"]
	$.loop_chan = $.loop[n]["chan"]
	$.loop_trans = $.loop[n]["trans"]
	$.chan_mute = $.loop[n]["mute"]
	$.chan_quant = $.loop[n]["quant"]
	$.loop_finished = $.loop[n]["finished"]
	$.nloops = $.loop[n]["nloops"]
}

method set_pulse_time(tm) {
	$.pulse_time = tm
	$.send_notify("newpulsetime")
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
	$.armed = 0
}

method init_one_loop(n) {
	$.loop_chan[n] = $.currchan
	$.loop_trans[n] = 0
	$.loop_pulse[n] = 0
	$.loop_start[n] = 0

	$.loop_began[n] = 0
	$.loop_finished[n] = 0
	$.loop_beats[n] = 0
	$.loop_phrase[n] = []
	$.loop_phrase_q[n] = []
	$.loop_tid[n] = -1
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
	$.got_info(c,nw,1)
}

method got_info(c,nw,keydown) {
	if ( keydown )
		$.print_info()
}

method print_info {
	print("======== CURRCHAN = ",$.currchan)
	# print("SECTION = ",$.currsect)
	# print("\nPULSE_TIME = ",$.pulse_time)
	if ( $.currloop == 0 || sizeof($.loop_beats) == 0 ) {
		print("NO loops yet...")
		return()
	} else for ( i in $.loop_beats ) {
		if ( $.chan_mute[$.loop_chan[i]] )
			a = "MUTED"
		else
			a = "ACTIVE"
		if ( i == $.currloop )
			pre = "*"
		else
			pre = " "
		pls = "pulse="+string($.loop_pulse[i])
		if ( $.loop_beats[i] != 0 ) {
			nnotes = 0
			if ( $.chan_mute[$.loop_chan[i]] )
			 	muted = "MUTED"
			else
			 	muted = ""
			if ( ! ( i in $.loop_phrase ) ) {
				print("Hey, i=",i," not in loop_phrase = ",$.loop_phrase)
			} else for ( b in $.loop_phrase[i] ) {
				nnotes += sizeof($.loop_phrase[i][b])
			}
			print(pre,"Loop",i,", ",$.loop_beats[i]," beats, chan ",$.loop_chan[i],", ",nnotes," notes  ",muted,pls)
		}
	}
	if ( $.shiftisdown ) {
		print("-------")
		ch = $.currloop
		print("Current loop = ",ch)
		nb = $.loop_beats[ch]
		for ( b=0; b<nb; b++ ) {
			print("Beat",b,"=",$.loop_phrase[ch][b])
		}
		for ( b=0; b<nb; b++ ) {
			if ( (ch in $.loop_phrase_q) && (b in $.loop_phrase_q[ch]) ) {
				print("Q Beat",b,"=",$.loop_phrase_q[ch][b])
			}
		}
		print("========")
		for ( n=0; n<sizeof($.undo); n++ ) {
			print("undo ",n,"=",$.undo[n])
		}
		print("========")
		print("PULSE_TIME = ",$.pulse_time)
	}
	print("========")
}

method reset() {
	$.got_reset()
}
method got_reset() {
	print("===== RESET =====")
	$.realtime($.stopphrase)
	kill($.pulsetid)
	$.realtime(ano())
	$.pulsetid = 0
	$.resetglobal()
	$.init_loop_stuff()
	$.send_notify("reset")
}

method send_notify(...) {
	if ( $.notifyobj != $-1 ) {
		if ( $.notifyobj != $0 ) {
			$.notifyobj.notify_event(...)
		}
	}
}

method got_TAP(c,nw,keydown) {
	if ( !keydown ) return()
	if ( $.recording ) {
		$.start_newloop(nw,'')
		return()
	}
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
			$.set_pulse_time(avg)
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
			print("BEATS IN MASTER LOOP = ",newbeats)
			$.wait_for_tap = 0
			# print("Old Pulse Time = ",$.pulse_time)
			new_pulse_time = loop_leng / newbeats
			# print("New Pulse Time = ",new_pulse_time)
			new_loop_leng = newbeats * new_pulse_time
			# print("Old loop leng=",loop_leng,"  New leng=",new_loop_leng)

			# We have to go back through the loop's beat buckets
			# and re-place the notes within the new beat buckets
			$.new_loop_phrase = []
			$.new_loop_beats = []
			for ( lp in $.loop_beats ) {
				# print("ADJUSTING lp=",lp)
				oldbeats = $.loop_beats[lp]
				old_time = 0
				new_time = 0
				new_phrase = []
				for ( b=0; b<oldbeats; b++ ) {
					for ( nt in $.loop_phrase[lp][b] ) {
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
					$.new_loop_phrase[lp] = new_phrase
					$.new_loop_beats[lp] = newbeats
					$.fill_blanks(lp)
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

method fill_blanks(lp) {
	nb = $.loop_beats[lp]
	# print("FILL_BLANKS lp=",lp,"  typeofloop_phfrase=",typeof($.loop_phrase))
	# print("fill_blanks")
	# print("loop_phrase = ",$.loop_phrase)
	if ( ! ( lp in $.loop_phrase ) ) {
		print("fill_blanks called with lp=",lp," not in loop_phrase!?")
		return()
	}
	phr = $.loop_phrase[lp]
	phrq = $.loop_phrase_q[lp]
	for ( b=0; b<nb; b++ ) {
		if ( ! (b in phr) ) {
			# print("Filling in beat b=",b," with blank")
			phr[b] = ''
		}
		if ( ! (b in phrq) ) {
			# print("Filling in beat b=",b," with blank")
			phrq[b] = ''
		}
	}
}

# method normalize(ch) {
# 	$.fill_blanks(ch)
# 	nb = $.loop_beats[ch]
# 	phr = $.loop_phrase[ch]
# 	for ( b=0; b<nb; b++ ) {
# 		p = phr[b]
# 		extra = cut(p,CUT_TIME,$.pulse_time)
# 		if ( sizeof(extra) != 0 ) {
# 			p -= extra
# 			phr[b] = p
# 			nextb = b+1
# 			if ( nextb >= nb )
# 				nextb = 0
# 			extra.time -= $.pulse_time
# 			phr[nextb] |= extra
# 		}
# 	}
# }

method got_UNDO(c,nw,keydown) {
	if ( $.debug && keydown ) print("got_UNDO")
	if ( $.UNDO_down && ! $.UNDO_done && !keydown ) {
		if ( $.loop_finished[$.currloop] == 0 ) {
			$.loop_finish($.currloop)
		}
		$.pop_undo()
	}
	$.UNDO_down = keydown
	if ( $.UNDO_down )
		$.UNDO_done = 0
	return()

	if ( !keydown ) {
		dt = nw - $.last_undo_down
		if ( dt > $.longpress ) {
			print("Long UNDO press is doing a RESET...")
			$.got_reset()
		}
		return()
	}
	$.last_undo_down = nw
	if ( $.debug ) print("got_UNDO")
	if($.MUTE_down) {
		print("UNMUTING ALL!")
		for ( ch=1; ch<=$.chans; ch++ ) {
			$.chan_mute[ch] = 0
		}
		return()
	}
	if ( $.loop_finished[$.currloop] == 0 ) {
		$.loop_finish($.currloop)
	}
	$.pop_undo()
}

method got_CHAN(c,nw,keydown) {
	if ( $.debug && keydown ) print("got_CHAN")
	$.CHAN_down = keydown
}

method got_MUTE(c,nw,keydown) {
	$.MUTE_down = keydown
	if ( $.debug && keydown ) print("got_MUTE")
}

method got_NUDGE(c,nw,keydown) {
	if ( $.debug && keydown ) print("got_NUDGE")
	$.NUDGE_down = keydown
}

method got_QUANT(c,nw,keydown) {
	$.QUANT_down = keydown
	if ( $.debug && keydown ) print("got_QUANT")
	if ( keydown ) {
		$.last_quant_nw = nw
	} else {
		dt = nw - $.last_quant_nw
		if ( dt > $.longpress ) {
			print("QUANT for channel ",$.currchan," has been reset")
			$.add_undo1($.currsect,"setquant",$.currchan,$.chan_quant[$.currchan])
			$.chan_quant[$.currchan] = 0
		} else {
			qv = $.chan_quant[$.currchan]
			if ( qv < 3 ) {
				$.add_undo1($.currsect,"setquant",$.currchan,qv)
				qv++
		
			}
			$.do_quant(qv,$.currchan)
			$.chan_quant[$.currchan] = qv
		}
	}
}

method got_TRANS(c,nw,keydown) {
	if($.debug)print("got_TRANS keydown=",keydown)
	$.TRANS_down = keydown
	if ( $.TRANS_down ) {
		$.TRANS_count = 0
		$.TRANS_all = 0
		$.TRANS_val = 0
	}
}

method got_GO(c,nw,keydown) {
	$.GO_down = keydown
	if ( !keydown ) return()

	if($.debug)print("got GO!")

	if($.MUTE_down) {
		print("MUTING ALL!")
		for ( ch=1; ch<=$.chans; ch++ ) {
			$.chan_mute[ch] = 1
		}
		return()
	}

	if ( $.nudge_pending ) {
		$.go_nudge_pending = $.nudge_pending
		$.nudge_pending = 0
	}
	if ( $.trans_pending ) {
		$.go_trans_pending = $.trans_pending
		$.trans_pending = 0
	}
	if ( $.quant_pending ) {
		$.go_quant_pending = $.quant_pending
		$.quant_pending = 0
	}
}

method got_MUTE(c,nw,keydown) {
	if ( !keydown ) return()
	print("got_MUTE keydown=",keydown)
}

method got_BEAT(c,nw,keydown) {
	$.BEAT_down = keydown
	if ( $.BEAT_down ) {
		$.BEAT_count = 0
		$.BEAT_all = 0
		$.BEAT_val = 0
	}
}

method got_COPY(c,nw,keydown) {
	$.COPY_down = keydown
}

method got_EXTERN1(c,nw,keydown) { $.EXTERN1_down = keydown }

method got_EXIT(c,nw,keydown) {
	if ( !keydown ) return()
	$.exit = 1
}

method got_DEBUG(c,nw,keydown) {
	if ( !keydown ) return()
	$.debug = 1 - $.debug
	print("debug = ",$.debug)
}

method got_KLOCK(c,nw,keydown) {
	if ( !keydown ) return()
	$.sendclock = 1 - $.sendclock
	if ( $.sendclock )
		print("SENDING CLOCK")
	else
		print("NOT SENDING CLOCK")
}

method got_RAND(c,nw,keydown) {
	$.RAND_down = keydown
	$.RAND_notes = ''
}


method rmloop(loop) {
	if ( loop == 1 ) {
		print("You can't remove the first loop - use RESET to do that")
		return()
	}
	for ( ch = loop; ch <= ($.nloops-1); ch++ ) {
		$.loop_chan[ch] = $.loop_chan[ch+1]
		$.loop_trans[ch] = $.loop_trans[ch+1]
		$.loop_beats[ch] = $.loop_beats[ch+1]
		$.loop_phrase[ch] = $.loop_phrase[ch+1]
		$.loop_pulse[ch] = $.loop_pulse[ch+1]
		$.loop_start[ch] = $.loop_start[ch+1]
		$.loop_began[ch] = $.loop_began[ch+1]
	}
	delete $.loop_chan[$.nloops]
	delete $.loop_trans[$.nloops]
	delete $.loop_beats[$.nloops]
	delete $.loop_phrase[$.nloops]
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

method do_nudgeforward(nudge) {
	if($.debug)print("NUDGEFORWARD = ",nudge)

	t = nudge
	t2 = $.pulse_time - nudge

	for ( c=1; c<=$.nloops; c++ ) {
		if ( $.loop_chan[c] != $.currchan )
			continue

		nb = $.loop_beats[c]
		newbeats = []
		for ( b=0; b<nb; b++ ) {
			p = $.loop_phrase[c][b]
			preb = b - 1
			if ( preb < 0 )
				preb = nb - 1
			prep = $.loop_phrase[c][preb]
			part2 = cut(p,CUT_TIME,0,t2)
			part2.time += t
			part1 = cut(prep,CUT_TIME,t2)
			part1.time -= t2
			newbeats[b] = part1 | part2
		}
		for ( b=0; b<nb; b++ ) {
			$.loop_phrase[c][b] = newbeats[b]
		}
	}
}

method do_nudgebackward(nudge) {
	if($.debug)print("NUDGEBACKWARD = ",nudge)

	t = nudge
	t2 = $.pulse_time - nudge

	for ( c=1; c<=$.nloops; c++ ) {
		if ( $.loop_chan[c] != $.currchan )
			continue

		nb = $.loop_beats[c]
		newbeats = []

		for ( b=0; b<nb; b++ ) {
			p = $.loop_phrase[c][b]
			postb = b + 1
			if ( postb >= nb )
				postb = 0
			postp = $.loop_phrase[c][postb]
			part1 = cut(p,CUT_TIME,t)
			part1.time -= t
			part2 = cut(postp,CUT_TIME,0,t)
			part2.time += t2
			newbeats[b] = part1 | part2
		}
		for ( b=0; b<nb; b++ ) {
			$.loop_phrase[c][b] = newbeats[b]
		}
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
		if ( typeof($.loop_phrase) != "array" ) {
			print("Unexpected, loop_phrase is not an array?")
			continue
		}
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

	$.set_pulse_time(new_pulse_time)
	$.fill_blanks($.currloop)
	# print("LOOP_PHRASE = ",$.loop_phrase[$.currloop])
	# print("BEATS = ",$.loop_beats[$.currloop])

	# This value might be off a little, it might
	# be better as the old loop_start value + nbeats*pulse.
	$.loop_start[$.currloop] = nw
	$.loop_began[$.currloop] = nw

# print("END_FIRST_LOOP BBB, loop_start=",$.loop_start[$.currloop]," loop_began=",$.loop_began[$.currloop])

	$.loop_pulse[$.currloop] = 0 # force play right away

	# print("KILLING/RESTARTING PULSE_TASK, Now=",Now)
	kill($.pulsetid)
	$.pulsetid = task $.pulse_task(Now)

	$.wait_for_tap = 1

	# print("FINISHED FIRST LOOP")
	$.send_notify("firstloop")
}

method new_loop_and_arm_for_end(c,nw) {
	print("OLD CODE?  ADDING LOOP AND ARMING!!! ")
	$.newloop(nw,$.currloop,0)
	$.armed = 2
	$.recording = 1
	if($.debug)print("ARMED loop ",$.currloop)
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
	if ( 0 in $.loop_phrase[$.currloop] ) {
		if ( $.firstnote != '' ) {
			pp = $.loop_phrase[$.currloop][0]
			if ( sizeof(pp) > 0 ) {
				t1 = pp%1.time
				tp = cut(pp,CUT_TIME,0,t1+$.chord_time)
				pp -= tp
				tp.time = 0
				pp |= tp
				$.loop_phrase[$.currloop][0] = pp
			}
		}
	}

	if ($.debug) print("FINISHED NEW LOOP with ",beats," beats")
	$.loop_beats[$.currloop] = beats
	$.fill_blanks($.currloop)
	# print("LOOP_PHRASE = ",$.loop_phrase[$.currloop])
	$.loop_pulse[$.currloop] = 0 # force play right away
	if ( dt >= 0 && dt < ($.pulse_time/2) ) {
		# print("Pulling off first beat...")
		$.realtime2($.loop_phrase[$.currloop][0],$.last_pulse_time)
		$.loop_pulse[$.currloop]++
	} else if ( dt < 0 && dt > -($.pulse_time/2) ) {
		# print("DT IS NEGATIVE? =",dt,"  Pulling off first beat...")
		$.realtime2($.loop_phrase[$.currloop][0],$.last_pulse_time)
		$.loop_pulse[$.currloop]++
	}
	# print("END OF LOOP FINISHED for loop=",$.currloop)
}

method got_section(c,nw) {
	print("ARMING NEW SECTION")
	$.armed_newsection = 1
}

method add_undo(u) {
	if ( nargs() < 4 )
		v2 = 0
	n = sizeof($.undo)
	$.undo[n] = arraycopy(u)
	# print("Adding undo = ",$.undo[n])
	$.undo_firstcnt = 3
}

method pop_undo() {
	ui = sizeof($.undo) - 1
	if ( ui < 0 )
		return()
	arr = $.undo[ui]
	sz = sizeof(arr)
	for ( n=0; n<sz; n++ ) {
		u = arr[n]
		ok = 1
		if ( u["cmd"] == "deleteloop" ) {
			lp = u["v1"]
			ch = u["v2"]
			sect = u["sect"]
			if ( lp == 1 ) {
				if ( $.undo_firstcnt-- == 0 ) {
					$.got_reset()
				} else {
					print("Keep pressing UNDO if you REALLY want to reset")
				}
				return()
			} else {
				print("Undo is deleting loop ",lp," in sect ",sect)
				$.rmloop(lp)
				$.send_notify("loopchange")
			}
			if ( ch > 0 )
				$.currchan = ch
		} else if ( u["cmd"] == "setchan" ) {
			ch = u["v1"]
			$.changechan(ch)
		} else if ( u["cmd"] == "setquant" ) {
			ch = u["v1"]
			qv = u["v2"]
			$.chan_quant[ch] = qv
			if ( qv > 0 )
				$.do_quant(qv,ch)
			$.chan_quant[ch] = qv
			print("QUANT of channel",ch,"is now",$.quant_name_of(qv))
		} else {
			print("Unrecognized cmd in undo: ",u["cmd"])
			ok = 0
		}
		if ( ok )
			delete $.undo[ui][n]
	}
	delete $.undo[ui]
}

method got_REC(c,nw,keydown) {
	if ( keydown ) {
		$.last_rec = nw
		if ( $.UNDO_down ) {
			$.got_reset()
			$.UNDO_done = 1
			return() 
		}
	} else {
		dt = nw - $.last_rec
		if ( dt > $.longpress ) {
			# print("LONG REC, calling reset")
			$.got_reset()
			return() 
		}
	}
	if ( !keydown ) return()
# print("GOT_REC/ARM recording=",$.recording,"  nloops=",$.nloops," arm=",$.armed)
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
		# print("Set armed and recording to 0")
		$.armed = 0
		$.recording = 0
		return()
	}
	if ( $.armed ) {
		print("RECORDING OF NEXT LOOP IS ALREADY ARMED")
		return()
	}
	# Armed is 0, so we arm for a new loop
	$.armed = 1
	print("RECORDING OF NEXT LOOP IS ARMED")
	$.recording = 1

}

method mutechan(c) {
	$.chan_mute[c] = 1 - $.chan_mute[c]
	if ( $.chan_mute[c] ) {
		print("Channel ",c," is now MUTED")
	} else {
		print("Channel ",c," is now ACTIVE")
	}
	$.send_notify("mutechan",c,$.chan_mute[c])
}

method beatadjust(bc,allchan) {
	if ( bc < 0 ) {
		if ( bc == -1 )
			s = "Subtracting 1 beat from"
		else
			s = "Subtracting "+-bc+" beats from"
	} else {
		if ( bc == 1 )
			s = "Adding 1 beat to"
		else
			s = "Adding "+bc+" beats to"
	}
	if ( allchan )
		print(s+" all channels")
	else
		print(s+" chan ",$.currchan)
	for ( c=1; c <= $.nloops; c++ ) {
		if ( allchan == 0 && $.loop_chan[c] != $.currchan )
			continue
		if ( bc>0 ) {
			for ( i=0; i<bc; i++ ) {
				$.loop_beats[c]++
			}
			$.fill_blanks(c)
		} else {
			for ( i=0; i<(-bc); i++ ) {
				if ( $.loop_beats[c] > 2 )
					$.loop_beats[c]--
			}
		}
		if($.debug)print("LOOP",c,"now has",$.loop_beats[c],"beats")
	}
	$.send_notify("loopchange")
}

method got_notedown(c,nw) {

	if ( $.RAND_down ) {
		$.RAND_notes |= makenote(c)
		return()
	}
	if ( $.GO_down ) {
		# C turns ON, C# turns off
		p = canonic(c)
		f = [
			1=1.0/1.05,2=1.0/1.50,3=1.0/1.75,4=1.0/2.0,
			-1=1.05,-2=1.50,-3=1.75,-4=2.0
			]
		if ( p == 0 ) {
			print("Restoring initial tempo")
			t = $.initial_tempo
		} else if ( p > 0 && p <=4 ) {
			t = tempo()*f[p]
		} else if ( p >=8 && p <= 11 ) {
			p = ( p - 12 )
			t = tempo()*f[p]
		}
		t = integer(t+0.5)
		m = t % 10
		if ( m >= 5 )
			t = t + (10-m)
		else
			t = t - m
		tempo(t)
		print("Tempo is now ",(60*1000000/tempo())," beats per minute")
		return()
	}
	if ( $.COPY_down ) {
		newc = canonic(c)
		if ( newc >= 0 && newc < 10 ) {
			$.newloop(nw,$.currchan,1+newc)
			print("AFTER NEWLOOP nloops=",$.getnloops())
		}
		$.send_notify("loopchange")
		return()
	}
	if ( $.EXTERN1_down ) {
		newc = canonic(c)
		if ( defined(Ergo) ) {
			nt = makenote(1+newc,1b,64,16)
			Ergo.play(nt)
		}
		return()
	}
	if ( $.UNDO_down ) {
		newc = canonic(c)
		if ( newc >= 0 && newc < 10 ) {
			ch = 1 + newc
			$.clearchan(ch)
			$.UNDO_done = 1
		}
		return()
	}
	if ( $.CHAN_down ) {
		newc = canonic(c)
		if ( newc >= 0 && newc < 10 ) {
			$.changechan(1+newc)
		}
		return()
	}
	if ( $.MUTE_down ) {
		newc = canonic(c)
		if ( $.go_mode ) {
			print("GO mode for MUTE is not implemented yet")
		}
		if ( newc >= 0 && newc < 10 ) {
			$.mutechan(1+newc)
		}
		return()
	}
	if ( $.TRANS_down ) {
		$.TRANS_count++
		return()
	}
	if ( $.BEAT_down ) {
		$.BEAT_count++
		return()
	}
	if ( $.NUDGE_down ) {
		p = canonic(c)
		if ( p == 0 )
			return()
		if ( p > 0 && p <=3 )
			tr = p
		else if ( p >=9 && p <= 11 )
			tr = p - 12
		else
			return()
		if ( $.go_mode ) {
			$.nudge_pending = tr
			if($.debug)print("nudge_pending = ",tr)
		} else {
			$.do_nudge(tr)
		}
		return()
	}
	if ( $.QUANT_down ) {
		return()
	}
	if ( $.NUDGE_down ) {
		return()
	}
# print("NOTEDOWN currloop=",$.currloop,"  armed=",$.armed,"  loop_finished=",$.loop_finished[$.currloop])

	if ( $.chan_mute[$.currchan] ) {
		print("Current channel is MUTED!")
		return()
	}

	c.chan = $.currchan
	$.realtime2(c,nw)

	$.lastdown[c.pitch] = nw
	$.lastdownq[c.pitch] = nw
	if ( ! $.overdubbing )
		return()
	if ( ! $.recording ) {
		# print("notedown not recording")
		return()
	}

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
		if($.debug>1)print("ARMED=1, creating new loop")

		$.start_newloop(nw,c)
	} else if ( $.armed == 0 ) {
		if ( $.currloop > 0 && $.loop_finished[$.currloop] != 0 ) {
print("OLD CODE?? NEW LOOP AA, settings copied from current loop, currloop=",$.currloop," armed=",$.armed," recording=",$.recording)
			# $.newloop(nw,$.currloop,0)
			return()
		}
	} else if ( $.armed == 2 ) {
		# do nothing
	}
}

method start_newloop(nw,c) {

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
		# NEW CHANGE
		# $.lastdownq[c.pitch] = nw
	}
	$.firstnote = c
	$.loop_start[$.currloop] = nw
	$.loop_began[$.currloop] = nw
	if($.debug)print("START LOOP loop_start/loop_began =",nw)
	if ( $.currloop == 1 ) {
		if ( $.pulsetid != 0 )
			print("Hey, pulsetid != 0")
		# print("STARTING PULSE_TASK AT nw=",nw)
		$.pulsetid = task $.pulse_task(nw)
	}
	$.armed = 2
	$.recording = 1
}

method collect_undo(arr,sect,cmd,v1,v2) {
	if ( nargs() < 5 )
		v2 = 0
	sz = sizeof(arr)
	arr[sz] = ["sect"=sect,"cmd"=cmd,"v1"=v1,"v2"=v2]
	return(arr)
}

method clearchan(ch) {
	for ( lp=1; lp<=$.nloops; lp++ ) {
		if ( $.loop_chan[lp] != ch )
			continue
		if ( lp != 1 ) {
			$.rmloop(lp)
			lp--
		} else {
			print("First loop is not being cleared!")
		}
	}
	$.send_notify("loopchange")
}

method newloop(nw,from_ch,to_ch) {

	# print("NEWLOOP from_ch =",from_ch," to_ch=",to_ch)

	if ( from_ch == 0 ) {

		# Just add a new loop, nothing else
		$.setnloops($.nloops+1)
		# print("NEW loop ",$.currloop)
		lp2 = $.nloops
		$.init_one_loop(lp2)

		# First loop
		$.loop_start[lp2] = nw
		$.loop_began[lp2] = nw

		$.currloop = lp2

	} else {
		# Copy all loops on from_ch to to_ch
		$.chan_mute[to_ch] = 1
		u = []
		for ( lp=1; lp<=$.nloops; lp++ ) {
			if ( $.loop_chan[lp] != from_ch )
				continue

			$.setnloops($.nloops+1)
			lp2 = $.nloops
			$.init_one_loop(lp2)

		
			$.loop_beats[lp2] = $.loop_beats[lp]
			$.loop_phrase[lp2] = arraycopy($.loop_phrase[lp])
			for ( bb in $.loop_phrase[lp2] ) {
				pp = $.loop_phrase[lp2][bb]
				pp.chan = to_ch
				$.loop_phrase[lp2][bb] = pp
			}
			$.loop_pulse[lp2] = $.loop_pulse[lp]
			$.loop_start[lp2] = $.loop_start[lp]
			$.loop_began[lp2] = $.loop_began[lp]

			$.loop_chan[lp2] = to_ch
			$.loop_finished[lp2] = $.loop_finished[lp]

			$.collect_undo(u,$.currsect,"deleteloop",lp2)
			$.currloop = lp2
		}
		# $.currchan = to_ch
		# $.collect_undo(u,$.currsect,"setchan",from_ch)
		# print("CURRENT channel is now ",to_ch)

		$.add_undo(u)

	}
}

method got_noteup(c,nw) {

	if ( $.RAND_down ) {
		pre = $.RAND_notes
		$.RAND_notes -= makenote(c)
		return()
	}
	if ( $.TRANS_down ) {
		p = canonic(c)
		$.TRANS_count--
		# C will make it transpose all channels
		if ( p == 0 )
			$.TRANS_all = 1
		else
			$.TRANS_val = p
		if ( $.TRANS_count > 0 )
			return()
		if ( $.TRANS_val >= 0 && $.TRANS_val <=6 )
			tr = $.TRANS_val
		else 
			tr = $.TRANS_val - 12
		if ( tr == 0 )
			tr = 999
		if ( $.go_mode ) {
			$.trans_pending = tr
			if($.debug)print("trans_pending = ",tr)
		} else {
			$.do_trans(tr,$.TRANS_all)
		}
		return()
	}
	if ( $.BEAT_down ) {
		p = canonic(c)
		$.BEAT_count--
		# C will make it do all channels
		if ( p == 0 )
			$.BEAT_all = 1
		else
			$.BEAT_val = p
		if ( $.BEAT_count > 0 )
			return()
		if ( $.BEAT_val >= 0 && $.BEAT_val <=6 )
			v = $.BEAT_val
		else 
			v = $.BEAT_val - 12
		if ( v == 0 )
			return()
		$.beatadjust(v,$.BEAT_all)
		return()
	}
	if ( $.QUANT_down ) {
		return()
	}
	if ( $.NUDGE_down ) {
		return()
	}
	if ( $.EXTERN1_down ) {
		return()
	}

	if ( $.chan_mute[$.currchan] ) {
		return()
	}

	# c.chan = $.loop_chan[$.currloop]
	c.chan = $.currchan
	$.realtime2(c,nw)

# print("NOTEUP c=",c,"  armed=",$.armed,"  currloop=",$.currloop)
	if ( ! ( c.pitch in $.lastdown) || $.lastdown[c.pitch] == 0 ) {
		if($.debug) print("Lastdown for c.pitch=",c.pitch," is 0?")
		return()
	}
	if ( ! $.overdubbing ) {
		return()
	}
	if ( $.recording == 0 ) {
		# print("noteup not recording")
		return()
	}
	if ( $.armed == 1 ) {
		print("OLD CODE?? GOT NOTE WHEN ARMED==1  nloops=",$.nloops)
		# $.new_loop_and_arm_for_end(c,nw)
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
		print("Hey, currloop=",$.currloop," isn't in loop_phrase, noteup")
		return()
	}
	if ( typeof($.loop_phrase[$.currloop]) != "array" ) {
		print("Hey, loop_phrase[currloop] isn't an array?")
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

	if ( $.NUDGE_down && c.type == PITCHBEND ) {
		print("Got NUDGE pitchbend, c=",c)
		return()
	}

	c.chan = $.currchan
	$.realtime2(c,nw)

	if ( ! $.overdubbing ) {
		return()
	}
	if ( $.recording == 0 ) {
		return()
	}
	print("non note recording, armed = ",$.armed)
	tmpdtq = nw - $.loop_start[$.currloop]
	p = c
	p.time = tmpdtq

	beat = p.time / $.pulse_time

	p.time -= beat * $.pulse_time

	if ( ! ($.currloop in $.loop_phrase) )
		return()
	if ( (beat in $.loop_phrase[$.currloop]) ) {
		$.loop_phrase[$.currloop][beat] |= p
	} else {
		$.loop_phrase[$.currloop][beat] = p
	}
# print("beat=",beat," p=",p," ph=",$.loop_phrase[$.currloop][beat])
}

method changechan(cn) {
	$.currchan = cn
	print("CURRCHAN is now",$.currchan)
	$.send_notify("chanchange",$.currchan)
}

method check_control(cp,nw,keydown) {
	c = makenote(cp)
	if ( cp == $.control_RAND ) {
		$.got_RAND(c,nw,keydown)
		return(1)
	}
	if ( $.RAND_down ) {
		if ( keydown ) {
			nnn = makenote(c)
			nnn.chan = $.control_chan
			$.RAND_notes |= nnn
		} else {
			nnn = makenote(c)
			nnn.chan = $.control_chan
			$.RAND_notes -= nnn
		}
		return(1)
	}

	if ( cp == $.control_REC) {
		$.got_REC(c,nw,keydown)
		return(1)
	} else if ( cp == $.control_UNDO ) {
		$.got_UNDO(c,nw,keydown)
		return(1)
	} else if ( cp == $.control_TAP ) {
		$.got_TAP(c,nw,keydown)
		return(1)
	} else if ( cp == $.control_CHAN ) {
		$.got_CHAN(c,nw,keydown)
		return(1)
	} else if ( cp == $.control_QUANT ) {
		$.got_QUANT(c,nw,keydown)
		return(1)
	} else if ( cp == $.control_TRANS ) {
		$.got_TRANS(c,nw,keydown)
		return(1)
	} else if ( cp == $.control_NUDGE ) {
		$.got_NUDGE(c,nw,keydown)
		return(1)
	} else if ( cp == $.control_GO ) {
		$.got_GO(c,nw,keydown)
		return(1)
	} else if ( cp == $.control_MUTE ) {
		$.got_MUTE(c,nw,keydown)
		return(1)
	} else if ( cp == $.control_BEAT ) {
		$.got_BEAT(c,nw,keydown)
		return(1)
	} else if ( cp == $.control_COPY ) {
		$.got_COPY(c,nw,keydown)
		return(1)
	} else if ( cp == $.control_KLOCK ) {
		$.got_KLOCK(c,nw,keydown)
		return(1)
	} else if ( cp == $.control_EXTERN1 ) {
		$.got_EXTERN1(c,nw,keydown)
		return(1)
	}
	return(0)
}

method inputtask(readfrom)
{
	# onexit(global(domethod),$,"final_cleanup")
	ignorenextup = 0

	ctrl = 0
	while ( $.exit == 0 ) {

		c = get(readfrom)

		nw = nextquant(Now,$.quant)

		ctype = typeof(c)

		if ( ctype == "string" ) {
			words = split(c)
			newc = ''
			if ( words[0] == "padon" ) {
				pnum = words[1]
				lock($)
				$.check_control(pnum,nw,1)
				unlock($)
			} else if ( words[0] == "padoff" ) {
				pnum = words[1]
				lock($)
				$.check_control(pnum,nw,0)
				unlock($)
			} else if ( words[0] == "slider" ) {
				ch = integer(words[1])
				if ( ch > 0 && ch < 9 ) {
					newc = controller(ch,0x07,integer(words[2]))
					# don't send to ergo
					realtime(newc)
				}
			} else {
				print("Hoops is ignoring c=",c)
			}
			continue
		} else if ( ctype == "array" ) {
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

			if ( $.wait_for_tap &&
				(c.chan != $.control_chan || (c.pitch == $.control_REC && ! $.UNDO_down ) ) &&
				(c.chan != $.control_chan || (c.pitch != $.control_TAP && c.pitch != $.control_UNDO) )
				) {
				if ( keydown )
					print("YOU MUST TAP IN THE TEMPO!")
				continue
			}

			if ( c.chan == $.control_chan ) {
				lock($)

				if ( $.check_control(c.pitch,nw,keydown) ) {
					unlock($)
					continue
				}

				# Everything below needs something
				# in the channel
				ch = $.currloop
				if ( ch==0 || $.loop_beats[ch] == 0 ) {
					print("B There's nothing in channel ",ch)
					unlock($)
					continue
				}
			
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

		print("Unexpected ctype in hoops? ",ctype)
		continue


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

