# VizCamp2015
#

#define xxx rereadlib();vizcamp()

function vizcamp() {

	t = new vizcamp_master()
	t.start()
	print("RUNNING!")
	t.waittilldone()
	t.stop()
}

class vizcamp_master {

method init() {

	$.oldMerge = Merge
	$.quit = 0
	Merge = 0
}

method waittilldone {
	wait($.constid)
}

method realano() {
	realtime(ano(),Now)
}

method start() { 

	Consecho = 0
	Consupdown = 1

	$.current_sound = 0
	$.current_visuals = 0

	$.constid = task $.cons_task()

	Midiin[$] = f = open()
	$.miditid = task $.midi_task(Midiin[$])
}

method stop {
	$.stopme = 1
	kill($.miditid)
	kill($.constid)

	Typos = -1
	if ( $.consf >= 0 ) {
		Consupdown = 0
		# print("Setting Consecho to 1")
		Consecho = 1
		Root.releaseconsole()
	}
	Merge = $.oldMerge
}

method cons_task() {
	$.consf = Root.grabconsole()
	global linnloop_resetconsole
	onexit(linnloop_resetconsole,$)
	while ( $.quit == 0 && (c=get($.consf)) != Eof ) {
		# print("GOT c=",c," from console")
		$.handle_console(c)
	}
}

method midi_task(f) {
	global linnloop_midi_restart
	onexit(linnloop_midi_restart,$)

	while ( (nt=get(f)) != Eof ) {
		print("got nt=",nt)
		if ( nt.type == CONTROLLER ) {
			ctrlnum = integer(subbytes(nt,2,1))
			ctrlval = integer(subbytes(nt,3,1))
			# These are intercepted to control sound/visuals
			if ( ctrlnum == 105 ) {
				q = (ctrlval / 16) % 8
				# q is now 0-7
				print("Slider F1 val=",ctrlval," q=",q)
				if ( $.current_sound != q ) {
					$.current_sound = q
					$.ano()
				}
				continue
			} else if ( ctrlnum == 106 ) {
				q = (ctrlval / 16) % 8
				# q is now 0-7
				print("Slider F2 val=",ctrlval," q=",q)
				if ( $.current_visuals != q ) {
					$.current_visuals = q
					$.set_visuals($.current_visuals)
				}
				continue
			}
			# other controller messages are passed through
		}
			
		nt.time = 0
		nt.chan = $.current_sound + 1
		nt.port = Synth[0]
		realtime(nt)
		if ( MidiVizPort >= 0 ) {
			nt.port = MidiVizPort
			realtime(nt)
		}
	}
	print("HEY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! midi_task finishes?!?")
}

method set_visuals(v) {
	$.visualpatch = v
	print("Set Visuals = ",$.visualpatch)
	$.toffff = open("3333@127.0.0.1","wb","osc_send")
	patch = "viz_"+string($.visualpatch+1)
	msg = [0="/api",1="ffff.loadpipeline",2="{\"filename\":\""+patch+"\"}"]
	print("Sending osc msg=",msg)
	mdep("osc","send",$.toffff,msg)
}

method midi_restart() {
	if ( $.stopme ) {
		closemidi($)
	} else {
		print("RESTARTING midi_task!!")
		$.miditid = task $.midi_task(Midiin[$])
	}
}

method putline(f,s) {
	put(f,s)
	put(f,"\n")
}

method ano() {
	realtime(ano())
}

method reset() {
	$.ano()
}

method handle_console(c) {

	keydown = (substr(c,1,1) == "+" )
	c = substr(c,2)
	if ( ! keydown ) {
		return()
	}
	if ( c == "ESC" || c == "Q" ) {
		print("quit!")
		$.quit = 1
	} else if ( c == "C" ) {
		$.current_sound = ( $.current_sound + 1 ) % 8
		print("SOUND = ",$.current_sound)
	} else if ( c == "V" ) {
		$.current_visuals = ( $.current_visuals + 1 ) % 8
		print("VISUALS = ",$.current_visuals)
		$.set_visuals($.current_visuals)
	}
}

}
