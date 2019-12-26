class lyre_player_looper {
method init (burn) {
	if ( defined(Lyre2003) ) {
		$.perconly = 0
	} else {
		$.perconly = 1
	}
	$.inherit(new lyre_player(burn))
	$.adv = []
	$.advinc = []
	$.advlimit = 2
	$.lastselect = []
	$.laststart = []
	$.startcount = []
	$.commandmode = []
	$.commandpad = []
	$.pmap = []
	$.chanA = []
	$.chanB = []
	$.chanC = []
	$.ch = []
	for ( c=1; c<=16; c++ ) {
		$.pmap[c] = patchmap_for_chan(c)
	}
	for ( pn=0; pn<4; pn++ ) {

		# chanA is 1-4, chanB is 5-8, chanC is 11-14
		$.chanA[pn] = pn+1
		$.chanB[pn] = pn+5
		$.chanC[pn] = pn+11
		$.ch[pn] = $.chanA[pn]

		$.adv[pn] = 0
		$.advinc[pn] = 1
		$.lastselect[pn] = 0
		$.laststart[pn] = 0
		$.startcount[pn] = 0
		$.commandmode[pn] = 0
		$.commandpad[pn] = 0
	}

	$.transitions = [
			"X"="0",
			"UP"="1",
			"CIRCLE"="2",
			"LEFT"="3",
			"RIGHT"="4",
			"DOWN"="5",
			"SQUARE"="6"
			]
	n = 0
	$.patches = []
	$.patches[0] = []
	$.patches[1] = []

	n=0
	$.patches[0][n++] = ["name"="Noo Tongs","vol"=90]
	$.patches[0][n++] = ["name"="SequencedSaw","vol"=95,"octave"=2]
	$.patches[0][n++] = ["name"="Rust Set","vol"=110,"nooffset"=1,"chan"=10]
	$.patches[0][n++] = ["name"="Muted Gt","vol"=100]
	if ( ! $.perconly )
		$.patches[0][n++] = ["name"="Jazz Gt","vol"=120]
	$.patches[0][n++] = ["name"="Voice Oohs 2","vol"=90,"octave"=1]
	$.patches[0][n++] = ["name"="Analog2 Set","vol"=110,"nooffset"=1,"chan"=10]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Slow Strings","vol"=110]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Techno Set","vol"=120,"nooffset"=1,"chan"=10]

	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Slap Bass 1","vol"=105]
	$.patches[0][n++] = ["name"="Enh.Gut Gt","vol"=100]
	$.patches[0][n++] = ["name"="Marimba","vol"=90]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Bottle Blow","vol"=100]
	if ( ! $.perconly ) 
	$.patches[0][n++] = ["name"="Vibraphone","vol"=95]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Pan Flute","vol"=100]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Celesta","vol"=100]
	$.patches[0][n++] = ["name"="Voice Oohs 2","vol"=90,"octave"=1]
	$.patches[0][n++] = ["name"="Fingered Bs","vol"=125]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Xylophone","vol"=100]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Gated Power","vol"=120,"nooffset"=1,"chan"=10]
	$.patches[0][n++] = ["name"="Enh.Gut Gt","vol"=100]
	$.patches[0][n++] = ["name"="Brush Set 2","vol"=120,"nooffset"=1,"chan"=10]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Kalimba","vol"=110]
	$.patches[0][n++] = ["name"="Koto","vol"=82]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Steel Drums","vol"=90]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="St.Slow Str","vol"=110]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Melo.Tom 1","vol"=90]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Yangqin","vol"=90]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Jazz Set 2","vol"=110,"nooffset"=1,"chan"=10]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Harp 2","vol"=110]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Fretless Bs2","vol"=100]
	$.patches[0][n++] = ["name"="SequencedSaw","vol"=95]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Fingered Bs2","vol"=100]

	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Syn Mallet 2","vol"=100]
	$.patches[0][n++] = ["name"="Noo Tongs","vol"=90]
	$.patches[0][n++] = ["name"="Jazz Slap","vol"=100]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Marimba 2","vol"=110]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Flute 2","vol"=125]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Atmostrings","vol"=80]
	if ( ! $.perconly )
		$.patches[0][n++] = ["name"="Jazz Organ 2","vol"=100]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Phase Halo","vol"=80]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Space Pad","vol"=100]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="FM E.Piano","vol"=120]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Phase Voice","vol"=80]
	$.patches[0][n++] = ["name"="St.Jazz","vol"=120,"nooffset"=1,"chan"=10]
	$.patches[0][n++] = ["name"="St.Brush","vol"=120,"nooffset"=1,"chan"=10]

	if ( ! $.perconly ) 
	$.patches[0][n++] = ["name"="Syn Mallet 3","vol"=100]
	if ( ! $.perconly ) 
		$.patches[0][n++] = ["name"="Brite FM EP2","vol"=110]
	$.patches[0][n++] = ["name"="Fingered Bs","vol"=125]


	n=0
	$.patches[1][n++] = "Train"
	$.patches[1][n++] = "Burst Noise"
	$.patches[1][n++] = "Siren"
	$.patches[1][n++] = "Door"
	$.patches[1][n++] = "Door"
	$.patches[1][n++] = "Car-Pass"
	$.patches[1][n++] = "Footsteps"
	$.patches[1][n++] = "Jetplane"

	$.currpatches = $.patches[0]
	$.currpatchindex = []
	for ( pn=0; pn<4; pn++ )
		$.currpatchindex[pn] = 0

	$.pad2index = ["X"=0,"UP"=1,"CIRCLE"=2,"LEFT"=3,
			"RIGHT"=4,"TRIANGLE"=5,"DOWN"=6,"SQUARE"=7]
}
method activate {
	$.t = $.burn.gettypo()
	$.start()
}
method isrunning {
	return($.t.isrunning())
}
method start {
	lock($)
	tempo(500000)

	# default things
	$.t.setlength(8b)
	$.t.setfade(2)
	$.t.set_octave(0)
	$.t.setrealnotify($.burn,1)
	$.t.setloopnotify($)
	$.t.setoffsetnotify($.burn)
	if ( ! $.t.isrunning() ) {
		$.t.start(0)
	}
	$.t.input("+SHIFT")

	$.set_transitions("2")
	realtime(sd80_nativeon())

	$.laststart = []
	for ( pn=0; pn<4; pn++ )
		$.laststart[pn] = 0

	# Give the sd80_nativeon a chance to sink in
	sleeptill(Now+1b)

	$.initialpatches(1)
	realtime('cd24o3v80t96,co4,co5')
	unlock($)
}
method indexofpatch(nm) {
	for ( i in $.currpatches ) {
		if ( $.currpatches[i]["name"] == nm ) {
			return(i)
		}
	}
	return(0)
}
method initialpatches(silent) {
	if ( $.perconly ) {
		$.currpatchindex[0] = $.indexofpatch("Sequenced Saw")
		$.currpatchindex[1] = $.indexofpatch("Noo Tongs")
		$.currpatchindex[2] = $.indexofpatch("Syn Mallet 2")
		$.currpatchindex[3] = $.indexofpatch("Kalimba")
	} else {
		$.currpatchindex[0] = $.indexofpatch("Muted Gt")
		$.currpatchindex[1] = $.indexofpatch("Slap Bass 1")
		$.currpatchindex[2] = $.indexofpatch("Syn Mallet 2")
		$.currpatchindex[3] = $.indexofpatch("Kalimba")
	}

	for ( pn=0; pn<4; pn++ ) {
		ch = pn+1
		$.burn.reset_assign(ch)
		$.setpatch($.currpatches[$.currpatchindex[pn]],ch,silent)
		$.t.setnotes(2)
	}
}
method run() {
}
method stop() {
	lock($)
	$.t.killrealtime()
	realtime(ano())
	realtime(allsusoff())
	unlock($)
}
method delete() {
	$.t.stop()
}
method assignchange(fn) {
	# switch to channel 1
	$.t.input(1)
	$.t.ctrl_assign_read_tpa(fn)
	# Copy assignments to all channels
	$.t.ctrl_assignall()
}
method setpatch(parr,ch,silent) {
	if ( nargs() < 3 )
		silent = 0
	pnm = parr["name"]
	arr = patch_lookup(pnm,ch,$.pmap[ch])
	if ( sizeof(arr) == 0 ) {
		print("No patch named ",pnm," in channel ",ch)
	} else {
		print("ch=",ch,"  PATCH ",pnm)
		realtime(arr["patch"],Now+4)
	}
	realtime(chanvolchange(ch,40))
	if ( "nooffset" in parr ) {
		Offsetfilter |= (1<<(ch-1))
	} else {
		Offsetfilter &= (65535 ^ (1<<(ch-1)))
	}
	if ( !silent ) {
		$.t.input(ch)
		$.t.buttonchange(0,"X",1)
		$.t.buttonchange(0,"X",0)
	}
	# Let the note play before we adjust the volume back
	sleeptill(Now+1b/2)
	realtime(chanvolchange(ch,parr["vol"]))
}
method kill_chan(ch) {
	realtime(ano(ch))
	$.t.input(ch,"+BS","-BS")
}
method pad_start(padnum) {

	# Kill notes on all channels of this pad
	$.kill_chan($.ch[padnum])	# In case it's 10
	$.kill_chan($.chanA[padnum])
	$.kill_chan($.chanB[padnum])
	$.kill_chan($.chanC[padnum])

	ls = $.laststart[padnum]
	if ( ls > 0 ) {
		ds = millisince(ls)
		if ( ds < 500 ) {
			$.killallpads()
		}
	}
	$.laststart[padnum] = Now
}
method killallpads {
	
	for ( ch=1; ch<=16; ch++ ) {
		$.kill_chan(ch)
	}

	# for ( pn=0; pn<4; pn++ ) {
	# 	$.kill_chan($.ch[pn])	# In case it's 10
	# 	$.kill_chan($.chanA[pn])
	# 	$.kill_chan($.chanB[pn])
	# 	$.kill_chan($.chanC[pn])
	# }
	$.burn.alloff()
}
method pad_select(padnum) {
	ch = $.ch[padnum]
	$.t.input(ch)
	$.adv[padnum]++
	if ( ch == 10 ) {
		$.burn.advance_assign(ch)
		$.adv[padnum] = 0
		$.t.setnotes(1)
		return()
	}
	v = $.adv[padnum]
	if ( v == 1 ) {
		$.t.setnotes(3)
	} else if ( v == 2 ) {
		$.t.setnotes(4)
		$.t.set_octave(1)

	} else if ( v == 3 ) {
		$.t.setnotes(1)
		$.t.set_octave(2)
	} else if ( v == 4 ) {
		$.burn.advance_assign(ch)
		$.t.set_octave(0)
		$.adv[padnum] = 0
		$.t.setnotes(2)
	}
}

method pad_select2(padnum) {
	oldch = $.ch[padnum]
	ch = oldch

	# cycle through 3 channels, so switching patches
	# doesn't kill the existing stuff

	if ( ch == $.chanA[padnum] ) {
		ch = $.chanB[padnum]
	} else if ( ch == $.chanB[padnum] ) {
		ch = $.chanC[padnum]
	} else {
		ch = $.chanA[padnum]
	}
	$.t.input(ch,"+BS","-BS")
	$.ch[padnum] = ch

	$.currpatchindex[padnum]++
	if ( ! $.currpatchindex[padnum] in $.currpatches )
		$.currpatchindex[padnum] = 0

	pi = $.currpatchindex[padnum]
	arr = $.currpatches[pi]
	if ( "chan" in arr ) {
		ch = arr["chan"]
		$.ch[padnum] = ch
	}
	if ( "octave" in arr ) {
		$.t.set_octave(arr["octave"])
	}

	# when switching in or out of drums, we have to
	# reassign things to the pads
	reassign = ( ch == 10 || oldch == 10 )
	if ( reassign ) {
		$.burn.reset_assign(oldch)
		$.burn.reset_assign(ch)
	}

	$.setpatch(arr,ch)
	$.t.setnotes(2)
}
method pad_select_start(padnum) {
	print("PAD_SELECT_START padnum=",padnum)
}
method set_transitions(tr) {
	$.t.input("+CTRL","+T","-T","+"+tr,"-"+tr,"-CTRL")
}
method pad_command(padnum,cmd,arg,cmode) {
	print("PAD_COMMAND_DO cmd=",cmd," arg=",arg," cmode=",cmode)
	if ( cmd == "TRIANGLE" ) {
		if ( arg in $.transitions ) {
			tr = $.transitions[arg]
			$.set_transitions(tr)
		}
	} else if ( cmd == "X" && arg == "X" ) {
		$.burn.switch()
	} else if ( cmd == "DOWN" && arg == "DOWN" ) {
		exit(0)
	}
}
method padfunc(padnum,nm,updown) {

	ch = $.ch[padnum]
	$.t.input(ch)
	$.t.buttonchange(padnum,nm,updown)

}
}
