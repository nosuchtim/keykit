#
# Hoops - Herb's Loops

INCDEC_MID = 0
INCDEC_MIN = -2
INCDEC_MAX = 2
INCDEC_INC = 1
INCDEC_DEC = -1


function hc2() {
	while ( 1 ) {
		hoops2()
		rereadlib()
	}
}

function hoops2_server() {

	if ( ! defined(Syncport) )
		Syncport = -1

	t = new hoops2_object()

	t.start()
	t.starttasks()
}

function hoops2() {

	if ( Machine != "win" ) {
		print("hoops2() probably only works on Windows, sorry!")
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

	t = new hoops2_object()

	t.start()
	t.starttasks()

	if ( standalone ) {
		t.waittilldone()

		Merge = oldMerge
		print("Hoops2 done.")
	}
}

class hoops2_object {

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
	if ( defined(HoopsPorts) ) {
		$.ports = HoopsPorts
	}
	else {
		$.ports = midi("input","list")
	}
	$.nsects = 0
	$.constid = -1
	$.miditid = -1
	$.startphrase = ''
	$.clockphrase = ''
	$.stopphrase = ''
	$.chord_time = 1b/16
	$.always_record = 1
	$.forcefour = 0
	$.defmultiple = 3
	$.transmultiple = $.defmultiple
	# $.tid = -1
	$.inputtid = -1
	$.inputf = -1
	$.verbose = 0
	$.consf = -1
	$.notifyobj = $0
	$.initial_tempo = tempo()
	if ( defined(Notranspose) )
		$.notranspose = Notranspose
	else
		$.notranspose = []

	if ( ! defined(HoopsPassThru) ) {
		print("Hey, HoopsPassThru needs to be defined!")
	}

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
method getportn(n) {
	return($.loop_port[n])
}
method getmuten(n) {
	return($.loop_mute[n])
}
method getcurrsect() {
	return($.currsect)
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
	prt = $.loop_port[n]
	qnt = $.chan_quant[prt*100+lc]
	wrp = $.loop_phrase_w[n]
	warptype = $.loop_warptype[n]
	# print("getloopn, n=",n," qnt=",qnt," warptype=",warptype,"  loop_phrase = ",$.loop_phrase[n])
	prt = $.loop_port[n]
	for ( b=0; b<nb; b++ ) {
		if ( b in $.loop_phrase[n]) {
			if ( warptype ) {
				q = $.loop_phrase_w[n][b]
			} else if ( qnt > 0 ) {
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
	# kill($.tid)
	# $.tid = -1
	kill($.inputtid)
	unlock($)
}

# method isrunning {
# 	return($.tid >= 0 )
# }
# method stop {
# 	lock($)
# 	kill($.tid)
# 	$.tid = -1
# 	unlock($)
# }

method start() {

	lock($)
	# kill($.tid)
	# $.tid = task $.realtimetask()

	if ( $.verbose )
		print("Hoops2 away ...  (control-X Q will quit)")

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
		print("Hoops2 is alive... (standalone)")
	else
		print("Hoops2 is alive... (routed)")

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
	$.send_ano()
}

method printmode(f) {
	print("\nMODE:  ",f)
	if ( f in $.helpfor ) {
		print($.helpfor[f])
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

method realtime(p) {
	if ( defined(Ergo) && Ergo != $-1 ) {
		if ( p.chan != 16 || p.port in Ergoin ) {
			# print("realtime sending p=",p," to Ergo")
			task Ergo.play(p)
		}
	}
	return(realtime(p))
}

method realtime2(p,tm) {
	if ( defined(Ergo) && Ergo != $-1 ) {
		if ( p.chan != 16 || p.port in Ergoin ) {
			# print("realtime2 sending p=",p," to Ergo")
			task Ergo.play2(p)
		}
	}
	return(realtime(p,tm))
}

method realtimetask() {

	if ( $.verbose ) {
		print("TYPO realtimetask() start $=",$)
	}
	print("REALTIMETASK is being disabled")
	return()

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

method init_chan(ch,initpatch) {

	$.settrack(ch,'')
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

method killrealtime() {
	lock($)
	# kill($.tid)
	# $.tid = -1
	if ( typeof($.looptask) == "array" ) {
		for ( ch in $.looptask )
			kill($.looptask[ch])
	}
	unlock($)
}

method dump {
	return ([
		"typo" = string($.typo) 
		])
}
method restore(st) {
	$.typo = st["typo"]
	$.finish_restore()
}
method typo_dump(fname) {
	f = open(fname,"w")
# print("Dumping, typo[1][sourcephr]=",$.typo[1]["sourcephr"])
	put(f,"Typo ="+string($.typo))
	close(f)
}

method finish_restore {
# print("FINISH_RESTORE, typo[0]=",$.typo[0]["sourcephr"])
	for ( n=0; n<$.npatterns; n++ ) {
		$.init_pattern(n)
		$.typo[n]["loopstart"] = 0
	}
	$.topattern(1)
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

method portarray(v) {
	a = []
	for ( prt in $.ports ) { a[prt] = v }
	return(a)
}

method portarrayarray() {
	a = []
	for ( prt in $.ports ) { a[prt] = [] }
	return(a)
}

method resetglobal() {
	$.resetnnotes()

	$.undo_firstcnt = 3

	$.currchan = $.portarray(1)
	$.wait_for_tap = $.portarray(0)
	$.recording = $.portarray(0)
	$.armed = $.portarray(0)

	$.undo = $.portarrayarray()

	$.overdubbing = $.portarray(1)
	$.currloop = $.portarray(0)

	$.last_tap_set = 0
	$.last_toosoon = 0
	$.tap_port = -1

	$.new_pulse_time = 0
	$.new_loop_phrase = []
	$.new_loop_beats = []

	$.CHAN_down = $.portarray(0)
	$.WARP_down = $.portarray(0)
	$.RESYNC_down = $.portarray(0)
	$.SECT_down = $.portarray(0)
	$.UNDO_down = $.portarray(0)
	$.UNDO_done = $.portarray(0)
	$.TRANS_down = $.portarray(0)
	$.TRANS_count = $.portarray(0)
	$.TRANS_all = $.portarray(0)
	$.TRANS_val = $.portarray(0)
	$.GO_down = $.portarray(0)
	$.COPY_down = $.portarray(0)
	# $.EXTERN1_down = $.portarray(0)
	$.BEAT_down = $.portarray(0)
	$.BEAT_count = $.portarray(0)
	$.BEAT_all = $.portarray(0)
	$.BEAT_val = $.portarray(0)
	$.QUANT_down = $.portarray(0)
	$.NUDGE_down = $.portarray(0)
	$.MUTE_down = $.portarray(0)
	$.RAND_down = $.portarray(0)
	$.RAND_notes = $.portarray('')
}

method resetstuff() {
	$.resetglobal()
}

method allnotesoff(ch,prt) {
	p = ''
	for ( pt=0; pt<=127; pt++ ) {
		nt = makenote(pt)
		nt.type = NOTEOFF
		p |= nt
	}
	p.chan = ch
	p.port = $.ports[prt]
	$.realtime(p)
}

method reset_level(level) {
	for ( prt in $.ports ) {

		p = ano()
		p.port = $.ports[prt]
		$.realtime(p)

		p = resetall()
		p.port = $.ports[prt]
		$.realtime(p)

		# if ( level > 1 ) {
		# 	for ( ch=1; ch<=16; ch++ ) {
		# 		$.allnotesoff(ch,prt)
		# 	}
		# }
	}
}

method send_ano(level) {
	if ( nargs() < 1 )
		level = 0
	if ( level > 0 ) {
		print("Sending RESET level=",level)
		task $.reset_level(level)
	} else {
		print("Sending All-Notes-Off")
		for ( prt in $.ports ) {
			p = ano()
			p.port = $.ports[prt]
			$.realtime(p)
		}
	}
}

method print_chan_line(c,always) {
	p = $.loopphrase[c]
	atts = " "
	if ( sizeof(p) > 0 ) {
		print("Chan(",c,") ",nm,atts,"  looped notes=",sizeof(p))
	} else if ( always ) {
		# print("Chan(",c,") ",atts,"  no sound assigned")
		print("Loop ",c)
	}
}

method setlength(v) {
	Tp["length"] = v
}

method topattern(n) {

	# XXX - should I be looking at $.lastplayed and turning things off?

	$.currpatt = n

	Tp = $.typo[n]

	# Careful - these global variables should not be altered
	# by any other code, the arrays they point to must not
	# be re-allocated, they must be the values in $.typo[]
	$.loopphrase = Tp["loopphrase"]
	if ( "loopquant" in Tp )
		$.loopquant = Tp["loopquant"]
	else
		$.loopquant = $.defaultloopquant
	$.mode = Tp["mode"]
	$.looptask = Tp["looptask"]
	$.phr = Tp["phrase"]
	$.sourcephr = Tp["sourcephr"]

# print("TOPATTERN, sourcephr size is",sizeof($.sourcephr)," sourcephr=",$.sourcephr)
	$.sourcepos = Tp["sourcepos"]

	# print("Switching to Pattern = ",n,"   length = ",Tp["length"])

	$.lastplayed = []	# index is key(character)
	if ( $.verbose ) {
		task $.ctrl_info()
	}
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
	print("\nCURRENT: Pattern=",$.currpatt,"  Loop=",$.currloop[prt],"  Loop=",Tp["length"]/1b,"beats ",atts)
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
		print("Chan(",c,") ",nm,atts,"  looped notes=",sizeof(p))
	} else if ( (c in $.sound) || (c in $.nopatches) ) {
		print("Chan(",c,") ",nm,atts)
	} else if ( always ) {
		# print("Chan(",c,") ",atts,"  no sound assigned")
		print("Loop ",c)
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

method do_quant(qv,ch,ports) {
	# print("do_quant qv=",qv," ch=",ch," ports=",ports)
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
	print("QUANTIZING channel",ch,"to",s," ports=",ports)
	for ( c=1; c<=$.nloops; c++ ) {
		# print("LOOP ",c)
		if ( $.loop_chan[c] != ch )
			continue
		if ( ! ( ports == 0 || ports == $.loop_port[c]) )
			continue
		
		if ( $.loop_mute[c] )
			continue
		# print("WE'RE ACTUALLY QUANTIZING LOOP c=",c)
		nb = $.loop_beats[c]
		$.loop_phrase_q[c] = []
		if ( typeof($.loop_phrase[c]) != "array" ) {
			print("Hey, loop_phrase for loop=",c," isn't an array")
			continue
		}
		for ( b in $.loop_phrase[c] ) {
			$.loop_phrase_q[c][b] = ''
		}
		# print("LOOP_PHRASE c=",c," = ",$.loop_phrase[c])
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
		# print("FINAL c=",c," phrase_q = ",$.loop_phrase_q[c])
	}
	$.send_notify("quant")
}

method trans_it(loop_phrase,t,lp,b) {
	pq = loop_phrase[lp][b]
	if ( typeof(pq) != "phrase" ) {
		print("Hey, loop_phrase lp=",lp," b=",b," is not a phrase")
		return()
	}
	if ( t == 999 ) {
		pq = transpose(pq,-$.loop_trans[lp])
	} else {
		pq = transpose(pq,t)
	}
	loop_phrase[lp][b] = pq
}

method do_trans(t,allchans,prt) {
	if ( t == 999 ) {
		tp = "UNDOING transpose"
	} else {
		tp = "DOING transpose "+string(t)
	}
	if ( allchans )
		print(tp,"of ALL CHANNELS")
	else
		print(tp,"of channel",$.currchan[prt])
	if ( typeof($.loop_chan) != "array" ) {
		print("In do_trans, loop_chan is not array?")
		return()
	}
	if ( typeof($.notranspose) != "array" ) {
		print("In do_trans, notranspose is not array?")
		return()
	}
	if ( typeof($.currchan) != "array" ) {
		print("In do_trans, currchan is not array?")
		return()
	}
	lock($)
	for ( lp=1; lp<=$.nloops; lp++ ) {
		lc = $.loop_chan[lp]
		if ( lc in $.notranspose )
			continue
		if ( allchans == 0 && lc != $.currchan[prt] )
			continue
		for ( b in $.loop_phrase[lp] ) {

			$.trans_it($.loop_phrase,t,lp,b)

			if ( $.chan_quant[prt*100+lc] > 0 ) {
				$.trans_it($.loop_phrase_q,t,lp,b)
			}
		}
		if ( t == 999 )
			$.loop_trans[lp] = 0
		else
			$.loop_trans[lp] += t
	}
	unlock($)
}

method advance_loop_pulse(c,nextpulse,inc) {
	# Only works for inc = +1 and inc = -1
	if ( $.loop_beats[c] <= 0 )
		return()
	$.loop_pulse[c] += inc
	b = $.loop_pulse[c]
	checkpulse = 0
	if ( b < 0 ) {
		$.loop_pulse[c] = $.loop_beats[c] - 1
		if ( $.loop_pulse[c] == 0 )
			$.loop_began[c] = $.nextpulse
		checkpulse = 1
	} else if ( b >= $.loop_beats[c] ) {
		# Loop back to the beginning of this loop
		if ( $.loop_finished[c] == 0 ) {
			$.loop_finish(c)
		}
		$.loop_pulse[c] = 0
		$.loop_began[c] = $.nextpulse
		checkpulse = 1
	}
	if ( checkpulse ) {
		# print("BACK TO BEGINNING, loop=",c,"  finished=",$.loop_finished[c],"  began=",$.loop_began[c],"  Now=",Now)
		if ( $.new_pulse_time != 0 ) {

			print("PULSE IS CHANGING, beats is now",$.new_loop_beats[1])
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

method add_undo1(prt,cmd,v1,v2) {
	if ( nargs() < 4 )
		v2 = 0
	u = []
	$.collect_undo(u,prt,cmd,v1,v2)
	$.add_undo(u)
}

method loop_finish(lp) {
	if ( $.debug ) { print("FINISHED UP loop ",lp) }
	$.loop_finished[lp] = 1
	$.add_undo1($.loop_port[lp],"deleteloop",lp)
	$.fill_blanks(lp)

	$.loop_warptype[lp] = 0
	$.loop_warpval[lp] = 1

	ch = $.loop_chan[lp]
	prt = $.loop_port[lp]
	$.chan_quant[prt*100+ch] = 0
	$.send_notify("enable")
	$.send_notify("loopchange")
}

method typo_setup() {

	# Constants and setup

	if ( $.verbose )
		print("Hoops2 Initializing...")
	$.chans = 16
	$.nletters = 0

	$.global_defaults()
	$.resetglobal()

	Tnumbers = ["0"=0,"1"=1,"2"=2,"3"=3,"4"=4,"5"=5,"6"=6,"7"=7,"8"=8,"9"=9]

	$.lastdown = $.portarrayarray()	# one per letter/key - records the last
				# time it was pressed, so when it comes
				# up you can get a duration if you want
	$.lastdownq = $.portarrayarray()

	# The values here are the default controller values

	$.init_loop_stuff()

	# Per-pattern stuff

	$.typo = []

	# Should this start at 1?
	for ( n=0; n<$.npatterns; n++ ) {
		$.init_pattern(n)
	}

	# $.currloop = $.portarray(0)
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

method set_sect_vars(n) {
	$.loop_phrase = $.loop[n]["phrase"]
	$.loop_phrase_q = $.loop[n]["phrase_q"]
	$.loop_phrase_w = $.loop[n]["phrase_w"]
	$.loop_warptype = $.loop[n]["warptype"]
	$.loop_warpval = $.loop[n]["warpval"]
	$.loop_beats = $.loop[n]["beats"]
	$.loop_pulse = $.loop[n]["pulse"]
	$.loop_began = $.loop[n]["began"]
	$.loop_start = $.loop[n]["start"]
	$.loop_chan = $.loop[n]["chan"]
	$.loop_port = $.loop[n]["port"]
	$.loop_trans = $.loop[n]["trans"]
	$.loop_mute = $.loop[n]["mute"]
	$.chan_quant = $.loop[n]["quant"]
	$.loop_finished = $.loop[n]["finished"]
	$.nloops = $.loop[n]["nloops"]
}

method set_pulse_time(tm) {
	$.pulse_time = tm
	$.send_notify("newpulsetime")
}
method init_one_loop(n,prt) {
	$.loop_chan[n] = $.currchan[prt]
	$.loop_port[n] = prt
	$.loop_trans[n] = 0
	$.loop_pulse[n] = 0
	$.loop_start[n] = 0
	$.loop_mute[n] = 0

	$.loop_began[n] = 0
	$.loop_finished[n] = 0
	$.loop_beats[n] = 0
	$.loop_phrase[n] = []
	$.loop_phrase_q[n] = []
	$.loop_phrase_w[n] = []
	$.loop_tid[n] = -1
}

method got_info(c,nw,keydown) {
	if ( keydown )
		$.print_info()
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
	if ( ! ("loopmode" in $.typo[n]) ) {
		$.typo[n]["loopmode"] = []
		for ( c=1; c<=$.chans; c++ ) {
			$.typo[n]["loopmode"][c] = 0
		}
	}
}

method global_defaults() {

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

	# These are the MIDI note numbers
	if ( ! defined(HoopsNotes) ) {
		print("Hey, HoopsNotes needs to be defined...")
		return()
	}
	$.control = HoopsNotes
	$.control_chan = 16  
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


method fill_blanks(lp) {
	nb = $.loop_beats[lp]
	# print("FILL_BLANKS lp=",lp,"  typeofloop_phfrase=",typeof($.loop_phrase))
	if ( typeof($.loop_phrase) != "array" ) {
		print("Unexpected, loop_phrase is not an array? in fill_blanks")
		return()
	}
	if ( ! ( lp in $.loop_phrase ) ) {
		print("fill_blanks called with lp=",lp," not in loop_phrase!?")
		return()
	}
	phr = $.loop_phrase[lp]
	if ( typeof(phr) != "array" ) {
		print("loop_phrase lp=",lp," isn't an array?")
		return()
	}
	phrq = $.loop_phrase_q[lp]
	if ( typeof(phrq) != "array" ) {
		print("loop_phrase_q lp=",lp," isn't an array?")
		return()
	}
	phrw = $.loop_phrase_w[lp]
	if ( typeof(phrw) != "array" ) {
		print("loop_phrase_w lp=",lp," isn't an array?")
		return()
	}
	warptype = $.loop_warptype[lp]
	for ( b=0; b<nb; b++ ) {
		if ( ! (b in phr) ) {
			# print("Filling in beat b=",b," with blank")
			phr[b] = ''
		}
		if ( ! (b in phrq) ) {
			# print("Filling in beat b=",b," with blank")
			phrq[b] = ''
		}
		if ( warptype > 0 && ( ! (b in phrw) ) ) {
			# print("Filling in beat b=",b," with blank")
			phrw[b] = ''
		}
	}
}

method got_UNDO(c,nw,keydown) {
	prt = c.port
	if ( $.debug && keydown ) print("got_UNDO")
	if ( $.UNDO_down[prt] && ! $.UNDO_done[prt] && !keydown ) {
		if ( $.loop_finished[$.currloop[prt]] == 0 ) {
			$.loop_finish($.currloop[prt])
		}
		$.pop_undo(prt)
	}
	$.UNDO_down[prt] = keydown
	if ( $.UNDO_down[prt] )
		$.UNDO_done[prt] = 0
	return()

	if ( !keydown ) {
		return()
	}
	$.last_undo_down = nw
	if ( $.debug ) print("got_UNDO")
	if($.MUTE_down[prt]) {
		print("UNMUTING ALL!")
		for ( lp=1; lp<=$.nloops; lp++ ) {
			$.loop_mute[lp] = 0
		}
		return()
	}
	if ( $.loop_finished[$.currloop[prt]] == 0 ) {
		$.loop_finish($.currloop[prt])
	}
	$.pop_undo(prt)
}

method got_WARP(c,nw,keydown) {
	prt = c.port
	if ( $.debug && keydown ) print("got_WARP")
	$.WARP_down[prt] = keydown
}

method got_RESYNC(c,nw,keydown) {
	prt = c.port
	if ( $.debug && keydown ) print("got_RESYNC")
	$.RESYNC_down[prt] = keydown
}

method got_SECT(c,nw,keydown) {
	prt = c.port
	if ( $.debug && keydown ) print("got_SECT")
	$.SECT_down[prt] = keydown
}

method got_CHAN(c,nw,keydown) {
	prt = c.port
	if ( $.debug && keydown ) print("got_CHAN")
	$.CHAN_down[prt] = keydown
}

method got_MUTE(c,nw,keydown) {
	prt = c.port
	$.MUTE_down[prt] = keydown
	if ( $.debug && keydown ) print("got_MUTE")
	if($.GO_down[prt]) {
		print("MUTING ALL CHANNELS on port ",prt)
		for ( lp=1; lp<=$.nloops; lp++ ) {
			if ( $.loop_port[lp] == prt )
				$.loop_mute[lp] = 1
		}
		return()
	} else if ($.CHAN_down[prt]) {
		print("MUTING ALL CHANNELS ALL PORTS!")
		for ( lp=1; lp<=$.nloops; lp++ ) {
			$.loop_mute[lp] = 1
		}
	}
}

method got_NUDGE(c,nw,keydown) {
	prt = c.port
	if ( $.debug && keydown ) print("got_NUDGE")
	$.NUDGE_down[prt] = keydown
}

method got_QUANT(c,nw,keydown) {
	prt = c.port
	$.QUANT_down[prt] = keydown
	if ( $.debug && keydown ) print("got_QUANT")
	if ( keydown ) {
		$.last_quant_nw = nw
	} else {
		if ( $.GO_down[prt] || $.CHAN_down[prt] ) {
			chans = []
			for ( k=1; k <= $.nloops; k++ ) {
				chans[$.loop_chan[k]] = 1
			}
			if ( $.CHAN_down[prt] )
				ports = 0
			else
				ports = prt
			if ( ports == 0 )
				print("DOING QUANT ON ALL CHANNELS ALL PORTS!")
			else
				print("DOING QUANT ON ALL CHANNELS prt=",prt)
		} else {
			print("DOING QUANT ON CHANNEL ",$.currchan[prt]," prt=",prt)
			chans = arraylist($.currchan[prt])
			ports = prt
		}
		u = []
# print("BEFORE QUANT....")
# for(ll=1;ll<=2;ll++){
# 	print("LOOP ll=",ll,"=",$.loop_phrase[ll])
# }
		for ( ch in chans ) {
			qv = $.chan_quant[prt*100+ch]
			if ( qv < 3 ) {
				$.collect_undo(u,prt,"setquant",ch,qv,ports)
				qv++
			}
			$.do_quant(qv,ch,ports)
			$.chan_quant[prt*100+ch] = qv
		}
# print("AFTER QUANT....")
# for(ll=1;ll<=2;ll++){
# 	print("LOOP ll=",ll,"=",$.loop_phrase[ll])
# }
		$.add_undo(u)
		if ( sizeof(chans) == 1 ) {
			print("QUANT on chan,",$.currchan[prt],"is now",$.quant_name_of(qv))
		} else {
			print("QUANT on all channels is now",$.quant_name_of(qv))
		}
	}
}

method got_TRANS(c,nw,keydown) {
	prt = c.port
	if($.debug)print("got_TRANS keydown=",keydown)
	$.TRANS_down[prt] = keydown
	if ( $.TRANS_down[prt] ) {
		$.TRANS_count[prt] = 0
		$.TRANS_all[prt] = 0
		$.TRANS_val[prt] = 0
	}
}

method got_GO(c,nw,keydown) {
	prt = c.port
	$.GO_down[prt] = keydown
	if ( !keydown ) return()

	if($.debug)print("got GO!")

}

method got_BEAT(c,nw,keydown) {
	prt = c.port
	$.BEAT_down[prt] = keydown
	if ( $.BEAT_down[prt] ) {
		$.BEAT_count[prt] = 0
		$.BEAT_all[prt] = 0
		$.BEAT_val[prt] = 0
	}
}

method got_COPY(c,nw,keydown) {
	prt = c.port
	$.COPY_down[prt] = keydown
	if ( keydown && $.SECT_down[prt] ) {

		olds = $.currsect
		$.nsects++
		news = $.nsects
		$.init_section(news)

		print("COPYING TO NEW SECTION ",$.currsect)

		$.loop[news] = arraycopy($.loop[olds])

		$.currsect = news
		$.set_sect_vars($.currsect)

		$.send_notify("loopchange")
		$.send_notify("sectchange",$.currsect)
		$.send_notify("redraw")
		# $.send_notify("disable")

	}
}

# method got_EXTERN1(c,nw,keydown) {
# 	prt = c.port
# 	$.EXTERN1_down[prt] = keydown
# }

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
	prt = c.port
	$.RAND_down[prt] = keydown
	$.RAND_notes[prt] = ''
}


method rmloop(loop,fromprt) {
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
	$.currloop[fromprt] = loop
	if ( $.currloop[fromprt] > $.nloops )
		$.currloop[fromprt] = $.nloops
}

method loopchange(dir) {
	if ( $.loop_finished[$.currloop[prt]] == 0 ) {
		$.loop_finish($.currloop[prt])
	}
	if ( dir > 0 ) {
		nl = $.currloop[prt]+1
		if ( ! (nl in $.loop_beats) ) {
			print("No higher loop")
		} else {
			$.currloop[prt] = nl
		}
	} else {
		nl = $.currloop[prt]-1
		if ( ! (nl in $.loop_beats) ) {
			print("No lower loop")
		} else {
			$.currloop[prt] = nl
		}
	}
	$.print_info()
}

method do_nudgeforward(nudge,prt) {
	if($.debug)print("NUDGEFORWARD = ",nudge)

	t = nudge
	t2 = $.pulse_time - nudge

	for ( c=1; c<=$.nloops; c++ ) {
		if ( $.loop_chan[c] != $.currchan[prt] )
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

method do_nudgebackward(nudge,prt) {
	if($.debug)print("NUDGEBACKWARD = ",nudge)

	t = nudge
	t2 = $.pulse_time - nudge

	for ( c=1; c<=$.nloops; c++ ) {
		if ( $.loop_chan[c] != $.currchan[prt] )
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

method end_first_loop(nw,prt,newsection) {
	# print("END FIRST LOOP, newsection = ",newsection)
	$.setnloops(1)

# print("END_FIRST_LOOP, setting nloops to 1, nw=",nw,"  loop_start=",$.loop_start[$.currloop[prt]]," loop_began=",$.loop_began[$.currloop[prt]])

	old_pulse_time = $.pulse_time
	leng = nw - $.loop_start[$.currloop[prt]]
	if ( leng < 1 )
		leng = 1
	# print("LOOP_START=",$.loop_start[$.currloop[prt]],"  nw=",nw,"  LENG=",leng)
	beats = round(( leng ) / float($.pulse_time))
	if ( beats < 1 )
		beats = 1

	$.loop_beats[1] = beats
	$.fill_blanks(1)
	# print("BEATS = ",beats,"  leng=",leng,"  PULSE TIME WAS ",$.pulse_time)
	new_pulse_time = float(leng) / beats
	print("NEW PULSE = ",new_pulse_time,"  old leng=",leng," new leng = ",new_pulse_time*beats)

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
		# print("b=",b," loop_phrase[1][b]=",$.loop_phrase[1][b])
		for ( nt in $.loop_phrase[1][b] ) {
			old_time = b * old_pulse_time + nt.time
			newb = integer(old_time / new_pulse_time)
			newbt = old_time - newb * new_pulse_time
			if ( ! ( newb in new_phrase ) ) {
				new_phrase[newb] = ''
			}
			# print("old_time=",old_time," newb=",newb," newbt=",newbt)
			nt.time = newbt
			new_phrase[newb] |= nt
		}
	}

	$.loop_phrase[1] = new_phrase

	$.set_pulse_time(new_pulse_time)
	$.fill_blanks($.currloop[prt])
	# print("LOOP_PHRASE = ",$.loop_phrase[$.currloop[prt]])
	# print("BEATS = ",$.loop_beats[$.currloop[prt]])

	# This value might be off a little, it might
	# be better as the old loop_start value + nbeats*pulse.
	$.loop_start[$.currloop[prt]] = nw
	$.loop_began[$.currloop[prt]] = nw

# print("END_FIRST_LOOP BBB, loop_start=",$.loop_start[$.currloop[prt]]," loop_began=",$.loop_began[$.currloop[prt]])

	$.loop_pulse[$.currloop[prt]] = 0 # force play right away

	# print("KILLING/RESTARTING PULSE_TASK, Now=",Now)
	kill($.pulsetid)
	$.pulsetid = task $.pulse_task(Now)

	if ( $.nsects == 1 ) {
		$.wait_for_tap[prt] = 1
	} else {
		$.wait_for_tap[prt] = 0
	}

	# print("FINISHED FIRST LOOP")
	$.send_notify("firstloop")
}

method end_non_first_loop(nw,prt) {
	leng = nw - $.loop_start[$.currloop[prt]]
	# print("LOOP_START=",$.loop_start[$.currloop[prt]],"  nw=",nw,"  LENG=",leng," last_pulse_time=",$.last_pulse_time)
	dt = nw - $.last_pulse_time
	# print("DT = ",dt)
	beats = round(leng / float($.pulse_time))
	print("END NON FIRST LOOP BEATS = ",beats,"  leng=",leng," pulse_time=",$.pulse_time,"  leng/pulse=",(leng/float($.pulse_time)))
	if ( beats == 0 ) {
		print("ZERO BEATS!?  end_non_first_loop is being ignored...")
		return(1)
	}
	# mod = leng % ($.pulse_time)
	# # print("leng=",leng," pulse_time=",$.pulse_time,"  beats=",beats,"  mod=",mod)
	# if ( mod >= (($.pulse_time)/2) ) {
	# 	# print("PAST HALF-WAY adding 1 beat")
	# 	beats++
	# }
	if ( $.forcefour ) {
		if ( beats > 1 && (beats % 4) == 1 ) {
			beats--
		}
		if ( beats > 1 && (beats % 4) == 3 ) {
			beats++
		}
	}
	if ( typeof($.loop_phrase) != "array" ) {
		print("Hey, loop_phrase isn't an array? prt=",prt," currloop=",$.currloop)
		return(0)
	}
	if ( typeof($.loop_phrase[$.currloop[prt]]) != "array" ) {
		print("Hey, loop_phrase of loop ",$.currloop[prt]," prt=",prt," isn't an array")
		return(0)
	}
	if ( 0 in $.loop_phrase[$.currloop[prt]] ) {
		if ( $.firstnote != '' ) {
			print("DOING CUT on firstnote??!!!!!!")
			pp = $.loop_phrase[$.currloop[prt]][0]
			if ( sizeof(pp) > 0 ) {
				t1 = pp%1.time
				tp = cut(pp,CUT_TIME,0,t1+$.chord_time)
				pp -= tp
				tp.time = 0
				pp |= tp
				$.loop_phrase[$.currloop[prt]][0] = pp
			}
		}
	}

	print("FINISHED NEW LOOP with ",beats," beats")
	$.loop_beats[$.currloop[prt]] = beats
	$.fill_blanks($.currloop[prt])
	# print("SETTING NEW LOOP to port ",$.ports[prt],"  (prt=",prt,")")
	for ( b=0; b<beats; b++ ) {
		p = $.loop_phrase[$.currloop[prt]][b]
		p.port = $.ports[prt]
		$.loop_phrase[$.currloop[prt]][b] = p
	}
	# print("NEW LOOP = ",$.loop_phrase[$.currloop[prt]])
	$.loop_pulse[$.currloop[prt]] = 0 # force play right away
	if ( dt >= 0 && dt < ($.pulse_time/2) ) {
		# print("Pulling off first beat...")
		$.realtime2($.loop_phrase[$.currloop[prt]][0],$.last_pulse_time)
		$.loop_pulse[$.currloop[prt]]++
	} else if ( dt < 0 && dt > -($.pulse_time/2) ) {
		# print("DT IS NEGATIVE? =",dt,"  Pulling off first beat...")
		$.realtime2($.loop_phrase[$.currloop[prt]][0],$.last_pulse_time)
		$.loop_pulse[$.currloop[prt]]++
	}
	print("LOOP FINISHED loop=",$.currloop[prt])
	return(0)
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

method do_nudge(nudge,prt) {
	nv = $.nudge_val_of(nudge)
	print("NUDGING",$.nudge_name_of(nudge))
	if ( nv > 0 ) {
		$.do_nudgeforward(nv,prt)
	} else {
		$.do_nudgebackward(-nv,prt)
	}
	$.send_notify("loopchange")
}

method resync_loops() {
	print("resync_loops...")
# 	while ( $.loop_pulse[1] != 0 ) {
# 		for ( lp=1; lp <= $.nloops; lp++ ) {
# 			$.advance_loop_pulse(lp,$.nextpulse,1)
# 		}
# 	}
	for ( lp=1; lp <= $.nloops; lp++ ) {
		$.loop_pulse[lp] = 0
		$.loop_began[lp] = $.nextpulse
	}
}

method pulse_task(nextpulse) {
	$.nextpulse = nextpulse
	$.last_pulse_time = nextpulse
	# print("PULSE_TASK START")
	$.startwassent = 0
	$.startshouldbesent = 0
	while ( 1 ) {
		sleeptill($.nextpulse-4)
		lock($)

		if ( $.sendclock ) {
			realtime($.clockphrase,$.nextpulse)
		}
		if ( $.nextsect > 0 ) {
			$.currsect = $.nextsect
			$.nextsect = 0
			print("SWITCHING TO SECTION ",$.currsect)
			$.set_sect_vars($.currsect)
			$.currloop = $.portarray(0)
			$.recording = $.portarray(0)
			$.resync_loops()
			# $.armed = 1	# Ready for ending of loop
			$.send_notify("loopchange")
		}

		thispulse = $.nextpulse
		$.last_pulse_time = thispulse
		$.nextpulse += $.pulse_time
		for ( c=1; c<=$.nloops; c++ ) {
			ch = $.loop_chan[c]
			if ( $.loop_mute[c] ) {
				# The current pulse of muted things
				# is still advanced
				$.advance_loop_pulse(c,$.nextpulse,1)
				continue
			}
			if ( $.loop_beats[c] <= 0 )
				continue
			prt = $.loop_port[c]
			if ( $.loop_warptype[c] > 0 ) {
				phr = $.loop_phrase_w[c]
			}
			else if ( $.chan_quant[prt*100+ch] > 0 )
				phr = $.loop_phrase_q[c]
			else
				phr = $.loop_phrase[c]
			# print("pulse_task loop=",c," phr=",phr)
			if ( prt <= 0 ) {
				print("Hmmm, prt=",prt," for loop=",c," in pulse_task")
			}
			b = $.loop_pulse[c]
			if ( c == 1 && b == 0 ) {
				if ( $.startphrase != '' && $.startwassent == 0 && $.startshouldbesent == 1 ) {
					print("SENDING START")
					realtime($.startphrase)
					$.startwassent = 1
				}
			}
			if ( typeof(phr) != "array" ) {
				print("phr is not array?")
				phr = []
			}
			if ( b in phr ) {
				p = phr[b]
				if ( typeof(p) != "phrase" ) {
					print("Hmmm, b=",b," in phr=",phr," is not a phrase")
					p = ''
					phr[b] = p
				}
				if ( p != '' ) {

					if ( ch == $.currchan[prt] && $.RAND_down[prt]!=0 && $.RAND_notes[prt] != '' ) {
						rnts = p{??.port==99}
						p -= rnts

# print("$.RAND_notes[prt] = ",$.RAND_notes[prt])
						rnts = $.RAND_notes[prt]
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
					ppp = p
					ppp.port = $.ports[prt]
					# print("Realtime2 sending ",ppp," thispulse=",thispulse)
					$.loop_tid[c] = $.realtime2(ppp,thispulse)
				}
			}

			$.advance_loop_pulse(c,$.nextpulse,1)
		}
		unlock($)
		$.send_notify("pulse")
	}
}

method add_undo(u) {
	if ( nargs() < 4 )
		v2 = 0
	n = sizeof($.undo)
	$.undo[n] = arraycopy(u)
	# print("Adding n=",n," undo = ",$.undo[n])
	$.undo_firstcnt = 3
}

method pop_undo(fromprt) {
	ui = sizeof($.undo) - 1
	if ( ui < 0 )
		return()
	arr = $.undo[ui]
	# print("pop_undo arr=",arr)
	sz = sizeof(arr)
	for ( n=0; n<sz; n++ ) {
		u = arr[n]
		# print("pop_undo u=",u)
		ok = 1
		if ( u["cmd"] == "deleteloop" ) {
			lp = u["v1"]
			ch = u["v2"]
			if ( lp == 1 ) {
				if ( $.tap_port >= 0 && $.tap_port != fromprt ) {
					print("Only port ",$.tap_port," can delete the last loop!")
				} else if ( $.undo_firstcnt-- == 0 ) {
					print("undo_firstcnt == 0, doing got_reset")
					$.got_reset()
				} else {
					print("Keep pressing UNDO if you REALLY want to reset")
				}
				return()
			} else {
				print("Undo is deleting loop ",lp)
				$.rmloop(lp,fromprt)
				$.send_notify("loopchange")
			}
			if ( ch > 0 )
				$.currchan[prt] = ch
			$.armed[fromprt] = 0
			$.recording[fromprt] = 0
		} else if ( u["cmd"] == "setchan" ) {
			ch = u["v1"]
			$.changechan(ch,fromprt)
		} else if ( u["cmd"] == "setquant" ) {
			ch = u["v1"]
			qv = u["v2"]
			ports = u["v3"]
			$.chan_quant[ports*100+ch] = qv
			if ( qv > 0 )
				$.do_quant(qv,ch,ports)
			$.chan_quant[ports*100+ch] = qv
			# print("QUANT of channel",ch,"is now",$.quant_name_of(qv))
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
	prt = c.port
	newsection = 0
	if ( keydown ) {
		if ( $.UNDO_down[prt] ) {
			print("REC/UNDO, doing reset!")
			$.got_reset()
			$.UNDO_done[prt] = 1
			return() 
		}
		if ( $.GO_down[prt] || $.SECT_down[prt] ) {
			print("ARMING NEW SECTION")
			$.armed_newsection = 1
			# Keep going and arm recording
			newsection = 1
		}
	}
	if ( !keydown ) return()
# print("GOT_REC/ARM recording[prt]=",$.recording[prt],"  nloops=",$.nloops," armed=",$.armed[prt])
	if ( $.armed[prt] == 2 ) {
# print("ARMED is 2, we've just hit the end of the loop")
		if ( $.nloops <= 1 ) {
			# print("FIRST LOOP !!!")
			$.end_first_loop(nw,prt,newsection)
		} else {
			if ( $.end_non_first_loop(nw,prt) != 0 ) {
				print("end_non_first is ignored.")
				return()
			}
		}
		$.loop_finish($.currloop[prt])
		# print("Set armed and recording to 0")
		$.armed[prt] = 0
		$.recording[prt] = 0
		if ( $.tap_port < 0 ) {
			$.tap_port = prt
			# print("SETTING tap_port to prt=",prt)
		}
		return()
	}
	if ( $.armed[prt] ) {
		if ( $.nloops < 1 )
			print("RECORDING OF FIRST LOOP IS ALREADY ARMED")
		else
			print("RECORDING OF NEXT LOOP IS ALREADY ARMED")
		return()
	}
	# Armed is 0, so we arm for a new loop
	$.armed[prt] = 1
	if ( $.nloops < 1 )
		print("RECORDING OF FIRST LOOP IS ARMED")
	else
		print("RECORDING OF NEXT LOOP IS ARMED")
	$.recording[prt] = 1

}

method mutechan(c,prt) {
	for ( lp=1; lp <= $.nloops; lp++ ) {
		if ( $.loop_chan[lp] != c )
			continue
		if ( $.loop_port[lp] != prt )
			continue
		$.loop_mute[lp] = 1 - $.loop_mute[lp]
		if ( $.loop_mute[lp] ) {
			print("Loop",lp," Port",prt," Channel ",c," is now MUTED")
		} else {
			print("Loop",lp," Port",prt," Channel ",c," is now ACTIVE")
		}
		$.send_notify("muteloop",lp,$.loop_mute[lp])
	}
}

method beatadjust(bc,allchan,prt) {
	print("beatadjust, prt=",prt)
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
		print(s+" all channels, port ",prt)
	else
		print(s+" chan ",$.currchan[prt]," port ",prt)
	for ( c=1; c <= $.nloops; c++ ) {
		if ( allchan == 0 && $.loop_chan[c] != $.currchan[prt] )
			continue
		if ( prt != $.loop_port[c] )
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

	# print("got_notedown, c=",c)
	prt = c.port
	if ( $.RAND_down[prt] ) {
		$.RAND_notes[prt] |= makenote(c)
		return()
	}
	if ( $.GO_down[prt] && $.NUDGE_down[prt] ) {
		newc = canonic(c)
		dir = 1
		if ( newc > 6 ) {
			dir = -1
			newc = 12 - newc
		}
		# print("Calling adjust_beats = ",dir * newc)
		if ( newc != 0 ) {
			$.adjust_beats(dir * newc )
		}
		return()
	}
	if ( $.GO_down[prt] && $.BEAT_down[prt] ) {
		newc = canonic(c)
		$.nextpulse = $.last_pulse_time + $.pulse_time
		print("ADVANCING ",newc," pulses")
		if ( newc <= 0 )
			return()
		dir = 1
		if ( newc > 6 ) {
			dir = -1
			newc = 12 - newc
		}
		print("newc = ",newc)
		for ( n=0; n<newc; n++ ) {
			for ( lp=1; lp <= $.nloops; lp++ ) {
				$.advance_loop_pulse(lp,$.nextpulse,dir)
			}
		}
		return()
	}
	if ( $.RESYNC_down[prt] ) {
		newc = canonic(c)
		if ( newc >= 0 && newc < 10 ) {
			if ( newc == 0 ) {
				$.send_ano(0)
			} else if ( newc == 1 ) {
				$.send_ano(1)
			} else if ( newc == 2 ) {
				$.send_ano(2)
			} else if ( newc == 3 ) {
				$.resync_loops()
			} else {
				print("Note ",newc," doesn't do anything there")
			}
		}
		return()
	}
	if ( $.SECT_down[prt] ) {
		newc = canonic(c)
		if ( newc >= 0 && newc < 10 ) {
			newc++
			if ( newc > $.nsects ) {
				print("There is no section numbered ",newc)
			} else {
				$.nextsect = newc
			}
		}
		return()
	}
	if ( $.WARP_down[prt] ) {
		if ( $.GO_down[prt] ) {
			chans = []
			print("WARP ON ALL CHANNELS")
			for ( k=1; k <= $.nloops; k++ ) {
				chans[$.loop_chan[k]] = 1
			}
		} else {
			chans = arraylist($.currchan[prt])
		}
		newc = canonic(c)
		if ( newc >= 0 && newc < 10 ) {
			$.warpstart(chans,newc,prt)
		}
		$.send_notify("loopchange")
		return()
	}
	if ( $.GO_down[prt] &&
		! ( $.COPY_down[prt]
			# || $.EXTERN1_down[prt]
			|| $.UNDO_down[prt]
			|| $.CHAN_down[prt]
			|| $.MUTE_down[prt]
			|| $.TRANS_down[prt]
			|| $.BEAT_down[prt]
			|| $.NUDGE_down[prt]
			|| $.QUANT_down[prt]
			)
		) {
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
		} else {
			print("Restoring initial tempo")
			t = $.initial_tempo
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
	if ( $.COPY_down[prt] ) {
		newc = canonic(c)
		if ( $.SECT_down[prt] == 0 && newc >= 0 && newc < 10 ) {
			$.newloop(nw,$.currchan[prt],1+newc,prt)
			nl = $.getnloops()
		}
		$.send_notify("loopchange")
		return()
	}
	# if ( $.EXTERN1_down[prt] ) {
	# 	newc = canonic(c)
	# 	if ( defined(Ergo) ) {
	# 		nt = makenote(1+newc,1b,64,16)
	# 		Ergo.play(nt)
	# 	}
	# 	return()
	# }
	if ( $.UNDO_down[prt] ) {
		newc = canonic(c)
		if ( newc >= 0 && newc < 10 ) {
			ch = 1 + newc
			$.clearchan(ch,prt)
			$.UNDO_done[prt] = 1
		}
		return()
	}
	if ( $.CHAN_down[prt] ) {
		newc = canonic(c)
		if ( newc >= 0 && newc < 10 ) {
			$.changechan(1+newc,prt)
		}
		return()
	}
	if ( $.MUTE_down[prt] ) {
		newc = canonic(c)
		if ( newc >= 0 && newc < 10 ) {
			$.mutechan(1+newc,prt)
		}
		return()
	}
	if ( $.TRANS_down[prt] ) {
		$.TRANS_count[prt]++
		return()
	}
	if ( $.BEAT_down[prt] ) {
		$.BEAT_count[prt]++
		return()
	}
	if ( $.NUDGE_down[prt] ) {
		p = canonic(c)
		if ( p == 0 )
			return()
		if ( p > 0 && p <=3 )
			tr = p
		else if ( p >=9 && p <= 11 )
			tr = p - 12
		else
			return()
		$.do_nudge(tr,prt)
		return()
	}
	if ( $.QUANT_down[prt] ) {
		return()
	}
# print("NOTEDOWN currloop[prt]=",$.currloop[prt],"  armed=",$.armed[prt],"  loop_finished=",$.loop_finished[$.currloop[prt]])

	# See if current channel is muted
	for ( lp=1; lp<=$.nloops; lp++ ) {
		if ( $.loop_chan[lp] == $.currchan[prt] && $.loop_mute[lp] ) {
			print("Current channel is MUTED!")
			return()
		}
	}

	c.chan = $.currchan[prt]
	cccc = c
	cccc.port = $.ports[prt]
	# print("notedown sending c=",c," to port ",cccc.port)
	$.realtime2(cccc,nw)

	$.lastdown[prt][c.pitch] = nw
	$.lastdownq[prt][c.pitch] = nw

	if ( ! $.overdubbing[prt] )
		return()
	if ( ! $.recording[prt] ) {
		# print("notedown not recording")
		return()
	}

# print("armed=",$.armed,"  armed-newsect=",$.armed_newsection)
	if ( $.armed_newsection ) {
		lock($)
		$.nsects++
		$.currsect = $.nsects
		$.init_section($.currsect)
		$.armed_newsection = 0

		print("STARTING NEW SECTION ",$.currsect)
		$.set_sect_vars($.currsect)
		$.currloop = $.portarray(0)
		$.recording = $.portarray(0)
		$.recording[prt] = 1

		$.send_notify("loopchange")
		$.send_notify("redraw")
		$.send_notify("disable")

		$.newloop(nw,0,0,prt)

		if ( $.currloop[prt] != 1 ) {
			nw -= $.last_pulse_time
			nw = numquant(nw,$.pulse_time)
			nw += $.last_pulse_time
			$.lastdownq[prt][c.pitch] = nw
		}

		$.loop_start[$.currloop[prt]] = nw
		$.loop_began[$.currloop[prt]] = nw

		$.armed[prt] = 2

		# $.print_info()
		unlock($)

		return()
	}

# print("NOTEDOWN armed=",$.armed[prt])
	if ( $.armed[prt] == 1 ) {
		if($.debug>1)print("ARMED=1, creating new loop")

		$.start_newloop(nw,c,prt)
	} else if ( $.armed[prt] == 0 ) {
		if ( $.currloop[prt] > 0 && $.loop_finished[$.currloop[prt]] != 0 ) {
print("OLD CODE?? NEW LOOP AA, settings copied from current loop, currloop[prt]=",$.currloop[prt]," armed=",$.armed," recording=",$.recording)
			return()
		}
	} else if ( $.armed[prt] == 2 ) {
		# do nothing
	}
}

method warptypename(n) {
	Warptypes = [
		0="nothing",
		1="echo 1*pulse/4",
		2="echo 3*pulse/3",
		3="echo 1*pulse",
		4="reverse",
		5="comb",
		6="fractal1",
		7="arpeggio1",
		8="arpeggio2",
		9="arpeggio3",
		10="shuffle"
	]
	return(Warptypes[n])
}

method unpack_phrase(p,warped,nb) {
	for ( b=0; b<nb; b++ ) {
		t1 = round(b*$.pulse_time)
		t2 = round((b+1)*$.pulse_time)
		q = cut(p,CUT_TIME,t1,t2)
		q.time -= t1
		warped[b] = q
	}
}
method pack_phrase(loop_phrase,nb) {
	p = ''
	for ( b=0; b<nb; b++ ) {
		q = loop_phrase[b]
		q.time = round(b * $.pulse_time)
		p |= q
	}
	p.length = round(nb * $.pulse_time)
	return(p)
}
method dowarp(loop_phrase,wt,wv) {
	warped = []
	# print("dowarp, loop_phrase = ",loop_phrase)

	nb = sizeof(loop_phrase)
	p = $.pack_phrase(loop_phrase,nb)

	if ( wt == 0 ) {
		for ( b in loop_phrase ) {
			warped[b] = ''
		}
	} else if ( wt == 1 ) {
		for ( b in loop_phrase ) {
			p = loop_phrase[b]
			warped[b] = echo(p,1,1 * $.pulse_time/4,0.9)
		}
	} else if ( wt == 2 ) {
		for ( b in loop_phrase ) {
			p = loop_phrase[b]
			warped[b] = echo(p,3,1 * $.pulse_time/3,0.9)
		}
	} else if ( wt == 3 ) {
		for ( b in loop_phrase ) {
			p = loop_phrase[b]
			warped[b] = echo(p,1,$.pulse_time,0.9)
		}
	} else if ( wt == 4 ) {
		# reverse the buckets
		p = reverse(p)
		$.unpack_phrase(p,warped,nb)
	} else if ( wt == 5 ) {
		# comb
		nb = sizeof(loop_phrase)
		for ( b=0; b<nb; b++ ) {
			warped[b] = (loop_phrase[b]){rand(2)==0}
		}
	} else if ( wt == 6 ) {
		p = fractal(p)
		if ( p != '' ) {
			p = head(p,16)
			p.length = latest(p)
			p = scaleng(p,nb*$.pulse_time)
			p = quantize(p,$.pulse_time/4)
			$.unpack_phrase(p,warped,nb)
		}
	} else if ( wt == 7 ) {
		p = step(arpeggio(p),round($.pulse_time/4))
		p.length = latest(p)
		p = repleng(p,nb*$.pulse_time)
		$.unpack_phrase(p,warped,nb)
	} else if ( wt == 8 ) {
		p = step(arpeggio(p),round($.pulse_time/2))
		p.length = latest(p)
		p = repleng(p,nb*$.pulse_time)
		$.unpack_phrase(p,warped,nb)
	} else if ( wt == 9 ) {
		p = step(arpeggio(p),round($.pulse_time))
		p.length = latest(p)
		p = repleng(p,nb*$.pulse_time)
		$.unpack_phrase(p,warped,nb)
	} else if ( wt == 10) {
		p = shuffle(p)
		$.unpack_phrase(p,warped,nb)
	}
	return(warped)
}

method warpstart(chans,warptype,prt) {
	# print("WARP chan chans=",chans)
	print("WARP = "+$.warptypename(warptype))
	for ( lp=1; lp<=$.nloops; lp++ ) {
		ch = $.loop_chan[lp]
		# print("LOOP ",lp,"  chan=",ch)
		if ( ! ( ch in chans) || $.loop_port[lp] != prt )
			continue
		if ( $.loop_mute[lp] )
			continue
		nb = $.loop_beats[lp]
		warpval = 1

		# print("BEFORE WARP, loop_phrase[lp=",lp,"] is ",$.loop_phrase[lp])
		# print("BEFORE WARP, loop_phrase_w[lp=",lp,"] is ",$.loop_phrase_w[lp])
		if ( $.loop_warptype[lp] ) {
			warped = $.dowarp($.loop_phrase_w[lp],warptype,warpval)
		} else if ( $.chan_quant[prt*100+$.loop_chan[lp]] > 0 ) {
			warped = $.dowarp($.loop_phrase_q[lp],warptype,warpval)
		} else {
			warped = $.dowarp($.loop_phrase[lp],warptype,warpval)
		}
		# print("WARPED=",warped)

		if ( sizeof(warped) == 0 ) {
			print("Sizeof warped is zero? ?")
			# continue
		}

		$.loop_warptype[lp] = warptype
		$.loop_warpval[lp] = warpval

		for ( b in $.loop_phrase[lp] ) {
			$.loop_phrase_w[lp][b] = ''
		}
		for ( b in $.loop_phrase[lp] ) {

			p = warped[b]

			$.loop_phrase_w[lp][b] |= p
			extra = cut(p,CUT_TIME,$.pulse_time)
			# print("b=",b,"  p=",p," extra=",extra)
			if ( sizeof(extra) != 0 ) {
				p -= extra
				$.loop_phrase_w[lp][b] -= extra
				nextb = b+1
				if ( nextb >= nb )
					nextb = 0
				extra.time -= $.pulse_time
				# print("nextb = ",nextb)
				$.loop_phrase_w[lp][nextb] |= extra
			}
		}
		# print("loop_phrase_w[lp=",lp,"] is now ",$.loop_phrase_w[lp])
	}
}

method setnloops(n) {
	# print("SETNLOOPS n=",n)
	$.loop[$.currsect]["nloops"] = n
	$.nloops = n
}

method set_pulse_time(tm) {
	$.pulse_time = tm
	$.send_notify("newpulsetime")
}
method init_loop_stuff() {
	$.pulse_time = 2b

	$.currsect = 1
	$.nsects = 1
	$.nextsect = 0
	$.armed_newsection = 0

	$.loop = []

	$.init_section(1)

	$.set_sect_vars(1)

	$.loop_tid = []

	$.init_one_loop(1,0)

	$.tap_times = []
	for ( n=0; n<4; n++ ) {
		$.tap_times[n] = 0
	}
	$.tap_index = 0
}

method chanarray() {
	a = []
	for ( c=1; c<=$.chans; c++ )
		a[c] = 0
	return(a)
}

method init_section(n) {
	$.loop[n] = []
	$.loop[n]["phrase"] = []
	$.loop[n]["phrase_q"] = []
	$.loop[n]["phrase_w"] = []
	$.loop[n]["warptype"] = []
	$.loop[n]["warpval"] = []
	$.loop[n]["beats"] = []
	$.loop[n]["mute"] = []
	$.loop[n]["pulse"] = []
	$.loop[n]["began"] = []
	$.loop[n]["start"] = []
	$.loop[n]["chan"] = []
	$.loop[n]["port"] = []
	$.loop[n]["trans"] = []
	$.loop[n]["finished"] = []
	$.loop[n]["nloops"] = 0

	$.loop[n]["mute"] = $.chanarray()
	$.loop[n]["quant"] = $.chanarray()
}

method got_info(c,nw,keydown) {
	if ( keydown )
		$.print_info()
}

method print_info(printverbose) {
	if ( nargs() == 0 )
		printverbose = 0
	print("======== CURRCHAN = ",$.currchan[prt])
	# print("\nPULSE_TIME = ",$.pulse_time)
	if ( $.currloop[prt] == 0 || sizeof($.loop_beats) == 0 ) {
		print("NO loops yet...")
		return()
	} else for ( i in $.loop_beats ) {
		if ( $.loop_mute[i] )
			a = "MUTED"
		else
			a = "ACTIVE"
		if ( i == $.currloop[prt] )
			pre = "*"
		else
			pre = " "
		pls = "pulse="+string($.loop_pulse[i])
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
			print(pre,"Loop",i,", ",$.loop_beats[i]," beats, chan ",$.loop_chan[i],", ",nnotes," notes  ",muted,pls)
		}
	}
	if ( printverbose ) {
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
	$.send_ano()
	$.pulsetid = 0
	$.resetglobal()
	$.init_loop_stuff()
	$.send_notify("reset")
}

method send_notify(...) {
	if ( $.notifyobj != $-1 ) {
		if ( $.notifyobj != $0 ) {
			task $.notifyobj.notify_event(...)
		}
	}
}

method rework_buckets(old_pulse_time,new_pulse_time,newnbeats) {
	if ( $.new_pulse_time != 0 ) {
		print("rework_buckets called when new_pulse_time != 0, ignoring")
		return(0)
	}
	print("REWORK oldpulse=",old_pulse_time," newpulse=",new_pulse_time," newnbeats = ",newnbeats)
	# We have to go back through the loop's beat buckets
	# and re-place the notes within the new beat buckets
	$.new_loop_phrase = []
	$.new_loop_beats = []
	for ( lp in $.loop_beats ) {
		oldbeats = $.loop_beats[lp]
		old_time = 0
		new_time = 0
		new_phrase = []
		# print("old phrase = ",$.loop_phrase[lp])
		for ( b=0; b<oldbeats; b++ ) {
			lphr = $.loop_phrase[lp]
			if ( typeof(lphr) != "array" ) {
				print("In rework, loop_phrase lp=",lp," isn't array")
				continue
			}
			for ( nt in lphr[b] ) {
				old_time = b * old_pulse_time + nt.time
				newb = integer(old_time / new_pulse_time)
				newbt = old_time - newb * new_pulse_time
				if ( ! ( newb in new_phrase ) ) {
					new_phrase[newb] = ''
				}
				nt.time = newbt
				new_phrase[newb] |= nt
			}
		}
		# print("new phrase = ",new_phrase)

		if ( ! typeof($.new_loop_phrase) == "array" ) {
			print("Hey, new_loop_phrase isn't an array!")
		} else {
			$.new_loop_phrase[lp] = new_phrase
			$.new_loop_beats[lp] = newnbeats
			$.fill_blanks(lp)
		}
	}
	return(1)
}

method adjust_beats(binc) {

	old_nbeats = $.loop_beats[1]
	old_pulse_time = $.pulse_time
	loop_leng = old_nbeats * old_pulse_time

	new_nbeats = old_nbeats + binc
	# print("Old nbeats=",old_nbeats,"  new nbeats=",new_nbeats)
	new_pulse_time = float(loop_leng) / new_nbeats
	# print("new_pulse_time = ",new_pulse_time)

	if ( $.rework_buckets(old_pulse_time,new_pulse_time,new_nbeats) ) {
		$.new_pulse_time = new_pulse_time
	}
}

method got_TAP(c,nw,keydown) {
	prt = c.port
	cp = c.pitch
	if ( !keydown ) return()
	if ( $.recording[prt] ) {
		$.start_newloop(nw,'',prt)
		return()
	}
	prt = c.port
	if ( $.tap_port > -1 && prt != $.tap_port ) {
		print("TAPS can only come in on port: ",$.tap_port)
		return()
	}
	this_index = $.tap_index
	$.tap_times[this_index] = nw
	# print("Setting tap_times[",this_index,"] to ",nw)
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
	if ( ntaps > 0 )
		avg = float(tot) / ntaps
	else
		avg = 0
	if ( avg > 0 && (maxdv - mindv) < milliclicks(200) ) {
		if ( (nw-$.last_tap_set)<milliclicks(2000) ) {
			if ( (nw-$.last_toosoon)>milliclicks(2000) ) {
				print("TOO SOON FOR ANOTHER TAP_SET")
				$.last_toosoon = nw
			}
			return()
		}
		if ( sizeof($.new_loop_phrase) != 0 ) {
			print("CAN'T SET ANOTHER NEW TAP POINT UNTIL LOOP ENDS")
			return()
		}
		$.last_tap_set = nw

		old_pulse_time = $.pulse_time

		if ( $.loop_beats[1] == 0 ) {
			# There's nothing in track 0, just set the pulse time
			$.set_pulse_time(avg)
		} else {
			loop_leng = $.loop_beats[1] * $.pulse_time
			# print("ORIGINAL loop_leng = ",loop_leng)
			newnbeats = integer((loop_leng / float(avg)) + 0.5)
			print("BEATS IN MASTER LOOP = ",newnbeats)
			$.wait_for_tap[prt] = 0
			new_pulse_time = float(loop_leng) / newnbeats
			# print("new_pulse_time = ",new_pulse_time)

			if ( $.rework_buckets(old_pulse_time,new_pulse_time,newnbeats) ) {
				$.new_pulse_time = new_pulse_time
			}
			# print("NEW loop_leng = ",$.new_pulse_time * newnbeats)
		}

	}
}

method start_newloop(nw,c,prt) {

	$.newloop(nw,0,0,prt)

	if ( $.currloop[prt] == 1 ) {
		# print("loop ",$.currloop[prt]," LOOP START")
	} else {
		# print("Loop ",$.currloop[prt]," LOOP START nw=",nw,"  last_pulse_time=",$.last_pulse_time)
		# print("Loop ",$.currloop[prt]," LOOP START")
		nw -= $.last_pulse_time
		nw = numquant(nw,$.pulse_time)
		nw += $.last_pulse_time
	}
	$.firstnote = c
	$.loop_start[$.currloop[prt]] = nw
	$.loop_began[$.currloop[prt]] = nw
	if($.debug)print("START LOOP loop_start/loop_began =",nw)
	if ( $.currloop[prt] == 1 ) {
		if ( $.pulsetid != 0 )
			print("Hey, pulsetid != 0")
		# print("STARTING PULSE_TASK AT nw=",nw)
		$.pulsetid = task $.pulse_task(nw)
	}
	$.armed[prt] = 2
	$.recording[prt] = 1
}

method collect_undo(arr,prt,cmd,v1,v2,v3) {
	if ( nargs() < 5 )
		v2 = 0
	sz = sizeof(arr)
	arr[sz] = ["port"=prt,"cmd"=cmd,"v1"=v1,"v2"=v2]
	if ( nargs() > 5 )
		arr[sz]["v3"] = v3
# print("collect_undo, prt=",prt,"  arr=",arr)
	return(arr)
}

method clearchan(ch,prt) {
	for ( lp=1; lp<=$.nloops; lp++ ) {
		if ( $.loop_chan[lp] != ch  || $.loop_port[lp] != prt )
			continue
		if ( lp != 1 ) {
			$.rmloop(lp,prt)
			lp--
		} else {
			print("First loop is not being cleared!")
		}
	}
	$.send_notify("loopchange")
}

method set_chan(ppp,to_ch) {
	for ( bb in ppp ) {
		pp = ppp[bb]
		pp.chan = to_ch
		ppp[bb] = pp
	}
}

method newloop(nw,from_ch,to_ch,prt) {

	# print("NEWLOOP from_ch =",from_ch," to_ch=",to_ch)

	if ( from_ch == 0 ) {

		# Just add a new loop, nothing else
		$.setnloops($.nloops+1)
		# print("NEW loop ",$.currloop[prt])
		lp2 = $.nloops
		$.init_one_loop(lp2,prt)

		# First loop
		$.loop_start[lp2] = nw
		$.loop_began[lp2] = nw

		$.currloop[prt] = lp2

	} else {
		# Copy all loops on from_ch to to_ch
		u = []
		for ( lp=1; lp<=$.nloops; lp++ ) {
			if ( $.loop_chan[lp] != from_ch )
				continue

			$.setnloops($.nloops+1)
			lp2 = $.nloops
			# print("lp is ",lp,"  lp2 is ",lp2)
			$.init_one_loop(lp2,prt)

			$.loop_mute[lp2] = 1	# loops are all muted initially
			$.loop_beats[lp2] = $.loop_beats[lp]

			$.loop_phrase[lp2] = arraycopy($.loop_phrase[lp])
			# print("lp phrase=",$.loop_phrase[lp],"  lp2 phrase=",$.loop_phrase[lp2])
			$.set_chan($.loop_phrase[lp2],to_ch)

			$.loop_phrase_w[lp2] = arraycopy($.loop_phrase_w[lp])
			$.set_chan($.loop_phrase_w[lp2],to_ch)

			$.loop_phrase_q[lp2] = arraycopy($.loop_phrase_q[lp])
			$.set_chan($.loop_phrase_q[lp2],to_ch)

			$.loop_warptype[lp2] = $.loop_warptype[lp]
			$.loop_warpval[lp2] = $.loop_warpval[lp]

			$.loop_pulse[lp2] = $.loop_pulse[lp]
			$.loop_start[lp2] = $.loop_start[lp]
			$.loop_began[lp2] = $.loop_began[lp]

			$.loop_chan[lp2] = to_ch
			$.loop_finished[lp2] = $.loop_finished[lp]

			$.collect_undo(u,prt,"deleteloop",lp2)
			$.currloop[prt] = lp2
			# print("FINAL lp2 phrase=",$.loop_phrase[lp2])
		}
		$.add_undo(u)

	}
}

method got_noteup(c,nw) {

	prt = c.port
	currloop = $.currloop[prt]
	# print("got_noteup, c=",c)
	if ( $.RAND_down[prt] ) {
		pre = $.RAND_notes[prt]
		$.RAND_notes[prt] -= makenote(c)
		return()
	}
	if ( $.TRANS_down[prt] && ! $.GO_down[prt] ) {
		p = canonic(c)
		$.TRANS_count[prt]--
		# C will make it transpose all channels
		if ( p == 0 )
			$.TRANS_all[prt] = 1
		else
			$.TRANS_val[prt] = p
		if ( $.TRANS_count[prt] > 0 )
			return()
		if ( $.TRANS_val[prt] >= 0 && $.TRANS_val[prt] <=6 )
			tr = $.TRANS_val[prt]
		else 
			tr = $.TRANS_val[prt] - 12
		if ( tr == 0 )
			tr = 999
		$.do_trans(tr,$.TRANS_all[prt],prt)
		return()
	}
	if ( $.BEAT_down[prt] && ! $.GO_down[prt] ) {
		p = canonic(c)
		$.BEAT_count[prt]--
		# C will make it do all channels
		if ( p == 0 )
			$.BEAT_all[prt] = 1
		else
			$.BEAT_val[prt] = p
		if ( $.BEAT_count[prt] > 0 )
			return()
		if ( $.BEAT_val[prt] >= 0 && $.BEAT_val[prt] <=6 )
			v = $.BEAT_val[prt]
		else 
			v = $.BEAT_val[prt] - 12
		if ( v == 0 )
			return()
		$.beatadjust(v,$.BEAT_all[prt],prt)
		return()
	}
	if ( $.WARP_down[prt] ) {
		return()
	}
	if ( $.RESYNC_down[prt] ) {
		return()
	}
	if ( $.QUANT_down[prt] ) {
		return()
	}
	if ( $.NUDGE_down[prt] ) {
		return()
	}
	# if ( $.EXTERN1_down[prt] ) {
	# 	return()
	# }

	# print("got_noteup, mid 1 c=",c)
	if ( currloop != 0 && $.loop_mute[currloop] ) {
		return()
	}

	c.chan = $.currchan[prt]
	cccc = c
	cccc.port = $.ports[prt]
	# print("got_noteup sending c=",c," to port ",cccc.port)
	$.realtime2(cccc,nw)

	if ( ! ( c.pitch in $.lastdown[prt]) || ($.lastdown[prt][c.pitch] == 0) ) {
		if($.debug) print("Lastdown for c.pitch=",c.pitch," is 0?")
		return()
	}
	if ( ! $.overdubbing[prt] ) {
		return()
	}
	if ( $.recording[prt] == 0 ) {
		# print("noteup not recording")
		return()
	}
	if ( $.armed[prt] == 1 ) {
		print("OLD CODE?? GOT NOTE WHEN ARMED==1  nloops=",$.nloops)
		return()
	}
	if ( ! ( c.pitch in $.lastdownq[prt]) ) {
		print("Lastdownq for c.pitch=",c.pitch," doesn't exist!?")
		return()
	}
	lastdown = $.lastdown[prt][c.pitch]
	lastdownq = $.lastdownq[prt][c.pitch]
# print("lastdownq=",lastdownq,"  loop_start=",$.loop_start[currloop],"  loop_began=",$.loop_began[currloop])
	tmpdtq = lastdownq - $.loop_began[currloop]
# print("NOTEUP tmpdtq = ",tmpdtq)
	if ( tmpdtq < 0 ) {
		tmpdtq += $.loop_beats[currloop] * $.pulse_time
		# print("ADJUSTED NOTEUP tmpdtq = ",tmpdtq)
	}
# print("LOOP_PULSE of loop=",currloop," is ",$.loop_pulse[currloop])
	p = c
	p.time = tmpdtq
	d = nw - lastdown
	p.dur = nw - lastdown
	if ( d <= 0 )
		d = 1
	p.dur = d
	p.length = p.dur
	p.type = NOTE

	beat = integer(p.time / $.pulse_time)

	p.time = round(p.time - beat * $.pulse_time)

	if ( typeof($.loop_phrase) != "array" ) {
		print("Hey, loop_phrase isn't an array?")
	}
	if ( ! ( currloop in $.loop_phrase ) ) {
		print("Hey, currloop[prt]=",currloop," isn't in loop_phrase, noteup")
		return()
	}
	if ( typeof($.loop_phrase[currloop]) != "array" ) {
		print("Hey, loop_phrase[currloop[prt]] (",currloop,") isn't an array?")
		return()
	}
	if ( beat in $.loop_phrase[currloop] ) {
		$.loop_phrase[currloop][beat] |= p
	} else {
		$.loop_phrase[currloop][beat] = p
	}
# print("beat = ",beat,"  P = ",p,"  loop_phrase[",currloop,"]=",$.loop_phrase[currloop][beat])
# print("beat=",beat," p=",p," ph=",$.loop_phrase[currloop][beat])
# print("loop_phrase = ",$.loop_phrase)
}

method got_nonnote(c,nw) {

	prt = c.port
	if ( $.NUDGE_down[prt] && c.type == PITCHBEND ) {
		print("Got NUDGE pitchbend, c=",c)
		return()
	}

	c.chan = $.currchan[prt]

	# A hack for remapping controllers 0x65-0x6c on channel 16 into
	# to volume controller messsages for channels 1-16.

	if ( (prt in HoopsControlRemap) && c.type == CONTROLLER ) {
		num = integer(subbytes(c,2,1))
		val = integer(subbytes(c,3,1))
		if ( num >= 0x65 && num <= 0x6c ) {
			ch = num - 0x65 + 1
			c = controller(ch,0x07,val)
		}
	}

	cccc = c
	cccc.port = $.ports[prt]

	$.realtime2(cccc,nw)

	if ( ! $.overdubbing ) {
		return()
	}
	if ( $.recording[prt] == 0 ) {
		return()
	}
	# print("non note recording, armed = ",$.armed[prt])
	tmpdtq = nw - $.loop_start[$.currloop[prt]]
	p = c
	p.time = tmpdtq

	beat = integer(p.time / $.pulse_time)
	# print("non note beat=",beat)

	p.time -= beat * $.pulse_time

	if ( ! ($.currloop[prt] in $.loop_phrase) )
		return()
	if ( (beat in $.loop_phrase[$.currloop[prt]]) ) {
		$.loop_phrase[$.currloop[prt]][beat] |= p
	} else {
		$.loop_phrase[$.currloop[prt]][beat] = p
	}
# print("beat=",beat," p=",p," ph=",$.loop_phrase[$.currloop[prt]][beat])
}

method changechan(cn,prt) {
	$.currchan[prt] = cn
	print("CURRCHAN is now",$.currchan[prt]," for port=",prt)
	$.send_notify("chanchange",$.currchan[prt])
}

method check_control(c,nw,keydown) {
	cp = c.pitch
	prt = c.port
	# print("check_control, c=",c," control=",$.control[prt])
	if ( cp == $.control[prt]["RAND"] ) {
		$.got_RAND(c,nw,keydown)
		return(1)
	}
	if ( $.RAND_down[prt] ) {
		if ( keydown ) {
			nnn = makenote(c)
			nnn.chan = $.control_chan
			$.RAND_notes[prt] |= nnn
		} else {
			nnn = makenote(c)
			nnn.chan = $.control_chan
			$.RAND_notes[prt] -= nnn
		}
		return(1)
	}

	if ( cp == $.control[prt]["REC"]) {
		$.got_REC(c,nw,keydown)
		return(1)
	} else if ( cp == $.control[prt]["SECT"] ) {
		$.got_SECT(c,nw,keydown)
		return(1)
	} else if ( cp == $.control[prt]["WARP"] ) {
# print("DEBUG QUANT....")
# for(ll=1;ll<=2;ll++){
# 	print("LOOP ll=",ll,"=",$.loop_phrase[ll])
# 	print("LOOP_Q ll=",ll,"=",$.loop_phrase_q[ll])
# }
		$.got_WARP(c,nw,keydown)
		return(1)
	} else if ( cp == $.control[prt]["RESYNC"] ) {
		$.got_RESYNC(c,nw,keydown)
		return(1)
	} else if ( cp == $.control[prt]["UNDO"] ) {
		$.got_UNDO(c,nw,keydown)
		return(1)
	} else if ( cp == $.control[prt]["TAP"] ) {
		$.got_TAP(c,nw,keydown)
		return(1)
	} else if ( cp == $.control[prt]["CHAN"] ) {
		# print("GOT CHANNNNNNNNNNNNNNNNNNNNN")
		$.got_CHAN(c,nw,keydown)
		return(1)
	} else if ( cp == $.control[prt]["QUANT"] ) {
		$.got_QUANT(c,nw,keydown)
		return(1)
	} else if ( cp == $.control[prt]["TRANS"] ) {
		$.got_TRANS(c,nw,keydown)
		return(1)
	} else if ( cp == $.control[prt]["NUDGE"] ) {
		$.got_NUDGE(c,nw,keydown)
		return(1)
	} else if ( cp == $.control[prt]["GO"] ) {
		$.got_GO(c,nw,keydown)
		return(1)
	} else if ( cp == $.control[prt]["MUTE"] ) {
		$.got_MUTE(c,nw,keydown)
		return(1)
	} else if ( cp == $.control[prt]["BEAT"] ) {
		$.got_BEAT(c,nw,keydown)
		return(1)
	} else if ( cp == $.control[prt]["COPY"] ) {
		$.got_COPY(c,nw,keydown)
		return(1)
	} else if ( cp == $.control[prt]["KLOCK"] ) {
		$.got_KLOCK(c,nw,keydown)
		return(1)
	# } else if ( cp == $.control[prt]["EXTERN1"] ) {
	# 	$.got_EXTERN1(c,nw,keydown)
	# 	return(1)
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
				$.check_control(makenote(pnum),nw,1)
				unlock($)
			} else if ( words[0] == "padoff" ) {
				pnum = words[1]
				lock($)
				$.check_control(makenote(pnum),nw,0)
				unlock($)
			} else if ( words[0] == "slider" ) {
				ch = integer(words[1])
				if ( ch > 0 && ch < 9 ) {
					newc = controller(ch,0x07,integer(words[2]))
					# don't send to ergo
					realtime(newc)
				}
			} else if ( words[0] == "-K" ) {
				$.got_KLOCK(0,0,1)
			} else if ( words[0] == "-ESC" ) {
				print("Should be quiting...")
				$.exit = 1
			} else {
				# print("Hoops is ignoring c=",c)
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
			$.currloop[prt] = c
			continue
		}
		if ( ctype == "phrase" ) {
			prt = c.port
			nonnote = 0
			# print("RAW NOTE INPUT: c=",c)
			if ( c.type == NOTEON )
				keydown = 1
			else if ( c.type == NOTEOFF )
				keydown = 0
			else {
				nonnote = 1
			}

			# print("prt=",prt," HoopsPassThru=",HoopsPassThru)
			if ( (prt in HoopsPassThru) && (c.chan in HoopsPassThru[prt]) ) {
				c.port = $.ports[prt]
				c.time = 0
				print("Passing through c=",c)
				$.realtime(c)
				continue
			}

			if ( $.wait_for_tap[prt] != 0 ) {
				ignore = 0
				if ( c.chan != $.control_chan ) {
					ignore = 1
				}
				if ( c.chan == $.control_chan
					&& c.pitch != $.control[prt]["UNDO"]
					&& c.pitch != $.control[prt]["TAP"]
					&& c.pitch != $.control[prt]["REC"]
					) {
					ignore = 1
				}
				if ( c.chan == $.control_chan
					&& c.pitch == $.control[prt]["REC"]
					&& $.UNDO_down[prt] == 0 ) {
					ignore = 1
				}
				if ( ignore ) {
					if ( keydown )
						print("YOU MUST TAP IN THE TEMPO!")
					continue
				}
			}

			if ( c.chan == $.control_chan ) {
				lock($)

				# print("control chan c=",c)

				if ( $.check_control(c,nw,keydown) ) {
					unlock($)
					continue
				}

				# Everything below needs something
				# in the channel
				ch = $.currloop[prt]
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

}

