#
# This is a simulator for the "Dancing under the Stars of Lyra" installation.
#

class wburn {

method init () {

	$.w = new window()
	$.inherit($.w)

	$.lighter = $0
	$.player = $0
	$.lyredir = Keyroot + Dirseparator + "lib"

	$.dochanging = 0
	$.changertid = -1
	$.autoadvance = 1
	$.lastpress = Now
	if ( defined(Lyre2003) )
		$.loopidle = 120
	else
		$.loopidle = 60 * 60 * 24 * 7
	$.playidle = 120
	$.musicname = "sngchild.mid"

	$.musicdir = "..\\music"
	$.defplayer = "looper"		# default player
	$.deflighter = "pitch_modulo"	# default lighter

	$.filetype = "hard"
	$.filetype = "med"
	$.filetype = "soft"

	$.mode = $.defplayer

	if ( fileexists("c:\\burn") ) {
		$.musicdir = "c:\\burn\\midi\\lyre"
	}

	$.default_avoidchans = [10=1]
	$.avoidchans = $.default_avoidchans
	$.default_vol = 127
	$.default_expr = 100

	$.lighterquant = 1b/4
	$.low = 0
	$.high = 127
	$.dolyre = 1

	$.startcmode = 'dc10d12'
	$.endcmode = 'ec10d12v50'

	$.lseq = []
	i = 0
	$.lseq[i++] = ["duration"=16b,"name"="pitch_modulo"]
	$.lseq[i++] = ["duration"=2b,"name"="sections_4b"]
	$.lseq[i++] = ["duration"=6b,"name"="pitch_modulo"]
	$.lseq[i++] = ["duration"=2b,"name"="scan2"]

	$.lseq[i++] = ["duration"=16b,"name"="pitch_modulo"]
	$.lseq[i++] = ["duration"=2b,"name"="sections_8b"]
	$.lseq[i++] = ["duration"=4b,"name"="pitch_modulo"]
	$.lseq[i++] = ["duration"=2b,"name"="sections_8bm"]
	$.lseq[i++] = ["duration"=2b,"name"="pitch_modulo"]
	$.lseq[i++] = ["duration"=2b,"name"="sections_8bm"]
	$.lseq[i++] = ["duration"=2b,"name"="scan3"]
	$.lseq[i++] = ["duration"=4b,"name"="pitch_modulo"]
	$.lseq[i++] = ["duration"=4b,"name"="sections_8bm"]

	$.lseq[i++] = ["duration"=8b,"name"="pitch_modulo"]
	$.lseq[i++] = ["duration"=2b,"name"="scan4"]

	$.lseq[i++] = ["duration"=8b,"name"="pitch_modulo"]

	$.lseq[i++] = ["duration"=2b,"name"="sections_4b"]
	$.lseq[i++] = ["duration"=2b,"name"="scan3b"]
	$.lseq[i++] = ["duration"=2b,"name"="pitch_modulo"]
	$.lseq[i++] = ["duration"=2b,"name"="scan4"]
	$.lseq[i++] = ["duration"=2b,"name"="pitch_modulo"]
	$.lseq[i++] = ["duration"=4b,"name"="sections_8b"]
	$.lseq[i++] = ["duration"=4b,"name"="pitch_modulo"]
	$.lseq[i++] = ["duration"=4b,"name"="sections_8bm"]

	$.lighterindex = 0
	$.lighteroffset = 0

	$.cycle = []
	n = 0
	$.cycle[n++] = [
		"atts"="soft","fname"="shin-tak.mid","expr"=70
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="linuslucy.mid","expr"=80,
		"tempo"=340000
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="siilentnight.mid","expr"=110,
		"show"=[7=1],"lighteroffset"=12
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="chinesedance.mid","expr"=110
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="russiandance.mid","expr"=110
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="sugarplum.mid","expr"=110
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="drinking.mid","expr"=110
		]
	$.cycle[n++] = [
		"atts"="short,soft","fname"="fqueen.mid","vol"=90,
		"prep"='xc02e,xc12e'
		]
	$.cycle[n++] = [
		"atts"="short,soft","fname"="petalsonthesnow.mid","expr"=90,
		"prep"='xc06b'
		]
	$.cycle[n++] = [
		"atts"="hard","fname"="the_barbarien2.mid","expr"=90,"tempo"=413000,
		"show"=[4=1,1=1]
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="sngchild.mid"
		]
	$.cycle[n++] = [
		"atts"="med","fname"="wtmaple.mid","expr"=70
		]
	$.cycle[n++] = [
		"atts"="hard","fname"="twinkle.mid","expr"=70,
		"show"=[1=1,5=1,6=1,3=1,8=1,12=1,13=1,16=1]
		]
	$.cycle[n++] = [
		"atts"="med","fname"="stardust.mid",
		"prep"='xc000,xc100'
		]
	$.cycle[n++] = [
		"atts"="hard","fname"="tarkusg4.mid","vol"=110,"expr"=100,
		"show"=[3=1,4=1,7=1,2=1]
		]
	$.cycle[n++] = [
		"atts"="hard","fname"="roundbou.mid","show"=[9=1,5=1,4=1,1=1]
		]
	$.cycle[n++] = [
		"atts"="med","fname"="nitefunk.mid","expr"=110
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="pburke.mid","expr"=110,
		"prep"='xc02e,xc12e'
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="jsb1013a.mid"
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="jsb1013d.mid"
		]
	$.cycle[n++] = [
		"atts"="med","fname"="gmblues.mid","expr"=60
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="dmagg.mid","expr"=110,"tempo"=297000,
		"prep"='xc049,xc149'
		]
	$.cycle[n++] = [
		"atts"="hard","fname"="fzpeach.mid","expr"=70,
		"show"=[3=1,5=1,8=1,11=1]
		]
	$.cycle[n++] = [
		"atts"="med","fname"="drkshore.mid"
		]
	$.cycle[n++] = [
		"atts"="med","fname"="entertanr.mid","expr"=80
		]
	$.cycle[n++] = [
		"atts"="med","fname"="cybrbeat3.mid","type"="native","expr"=120
		]
	$.cycle[n++] = [
		"atts"="med","fname"="23shots.mid","expr"=120
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="bjsfncp2.mid","show"=[1=1],"expr"=60
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="bjsfnem2.mid","show"=[1=1],"expr"=60
		]
	$.cycle[n++] = [
		"atts"="hard","fname"="6wives.mid","expr"=90
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="BachCPE_Solfeggio.mid","vol"=80,
		"prep"='xc02e,xc12e'
		]
	$.cycle[n++] = [
		"atts"="short,soft","fname"="cntryjig2.mid","expr"=110,
		"prep"='xc02e,xc12e'
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="Sermisy1.mid","expr"=90
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="1-allegrobrillante.mid","expr"=50
		]
	$.cycle[n++] = [
		"atts"="med","fname"="cjamblus.mid"
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="Handel_Gigue_in_G.mid","expr"=80
		]
	$.cycle[n++] = [
		"atts"="hard","fname"="MASAHIRO_ANDOH__Control_From_Natural.mid"
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="craitele.mid"
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="en_harpa_2.mid","expr"=70,
		"prep"='xc02e,xc12e'
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="good_harp_3.mid","show"=[1=1],"expr"=110
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="harp_1b.mid","show"=[1=1],"tempo"=570000
		]
	$.cycle[n++] = [
		"atts"="soft","fname"="jsbach.mid","tempo"=400000
		]
	$.cycle[n++] = [
		"atts"="med","fname"="bumble.mid","expr"=85
		]
	$.cycle[n++] = [
		"atts"="med","fname"="Spain.mid","expr"=110
		]
	$.cycle[n++] = [
		"atts"="hard","fname"="karnevil9.mid"
		# "atts"="hard","fname"="karn_evil_9_1st_impression.mid","expr"=50,"vol"=50
		]

	$.cyclepos = 0
	for ( n in $.cycle ) {
		if ( ! ("type" in $.cycle[n]) )
			$.cycle[n]["type"] = "gm2"
		if ( ! ("tempo" in $.cycle[n]) )
			$.cycle[n]["tempo"] = 500000
	}

	$.pad = []
	for ( n=0; n<4; n++ ) {
		$.pad[n] = new wdancepad(n)
		$.addchild($.pad[n])
		$.pad[n].setnotify($)
	}

	$.nstrings = 24
	$.lyre = new wlyre($.nstrings)
	# $.lyre.setextra(1b/8)
	$.addchild($.lyre)
	$.lyre.setmode(CLEAR)

	$.title = new ktext("Stars of Lyra","left")
	$.title.style(NOBORDER)
	$.addchild($.title)
	$.playertitle = new ktext("Player","left")
	$.playertitle.style(NOBORDER)
	$.addchild($.playertitle)
	$.lightertitle = new ktext("Lighter","left")
	$.lightertitle.style(NOBORDER)
	$.addchild($.lightertitle)
	$.musictitle = new ktext("Music","left")
	$.musictitle.style(NOBORDER)
	$.addchild($.musictitle)
	$.typotitle = new ktext("Typo","left")
	$.typotitle.style(NOBORDER)
	$.addchild($.typotitle)

	$.menubutt = new kmenubutton("More","mkmenu_burn",$)
	$.addchild($.menubutt)

	$.typo = new typob_object()

	$.curr_assign = []
	$.typo_assign_setup()

	$.playernames = []
	$.lighternames = []
	$.players = []
	$.lighters = []

	$.playernames[0] = "looper"
	$.players["looper"] = new lyre_player_looper($)
	$.playernames[1] = "playfile"
	$.players["playfile"] = new lyre_player_playfile($)

	$.getplugins()
	$.getmusicfiles()
	$.gettpafiles()

	$.playerbutt = new kvalbutton($.playernames,$,"playerchange")
	$.addchild($.playerbutt)
	$.lighterbutt = new kvalbutton($.lighternames,$,"lighterchange")
	$.addchild($.lighterbutt)
	$.filebutt = new kvalbutton($.files,$,"filechange")
	$.addchild($.filebutt)
	$.typofilebutt = new kvalbutton($.typofiles,$,"typofilechange")
	$.addchild($.typofilebutt)

	$.setdefaultplayers(0)

	# cf = $.cycle[$.cyclepos]["fname"]
	# $.filebutt.setbyval(cf)

	$.ptid = task $.permatask()

	$.joy = getjoymonitor()
	$.joy.notify($,-1)

	$.activatecurrent()

	$.reset4looper()

	for ( ch=1; ch<=16; ch++ ) {
		$.curr_assign[ch] = 0
		$.set_assign(ch)
	}
	$.changeon()
}

method set_assign(ch) {
	if ( ch != 10 ) {
		if ( ! ( $.curr_assign[ch] in $.assign_norm ) ) {
			$.curr_assign[ch] = 0
		}
	} else {
		if ( ! ( $.curr_assign[ch] in $.assign_drum ) ) {
			$.curr_assign[ch] = 0
		}
	}
	ca = $.curr_assign[ch]
	if ( ch != 10 )
		$.typo.ctrl_assign_set_tpa_arr_chan($.assign_norm[ca],ch)
	else {
		$.typo.ctrl_assign_set_tpa_arr_chan($.assign_drum[ca],ch)
	}
}

method nextmusic {
	if ( $.mode == "playfile" )
		$.player.nextmusic()
	else
		print("Not in playfile mode")
}
method reset_assign(ch) {
	$.curr_assign[ch] = 0
	$.set_assign(ch)
	$.typo.set_octave(0)
}
method advance_assign(ch) {
	$.curr_assign[ch]++
	$.set_assign(ch)
}
method typo_assign_setup {
	$.assign_norm = []
	$.assign_drum= []
	na = 0
	$.assign_norm[na++] = [
		"Q"='cd24,g',
		"A"='dd24,d',
		"Z"='go3d24,b-',
		"W"='fd48,c',
		"S"='gd24,b-',		# not used
		"X"='b-o3d24,c',
		"E"='co4d96,g',
		"D"='do4d24,b-o3',
		"C"='fo4d96,c'
		]
	$.assign_norm[na++] = [
		"Q"='co2,go2,go3',
		"A"='fo2,fo3,g',
		"Z"='b-o2d12,b-o3,co4',
		"W"='co3d24,e-',
		"S"='e-o3d48 g,b-',	# not used
		"X"='e-o3d48,b-',
		"E"='fo3d48,co3',
		"D"='go3,b- do4,e-',
		"C"='b-o3d48,e-o3'
		]
	$.assign_norm[na++] = [
		"Q"='g,go2,b-',
		"A"='b-,f,b-',
		"Z"='co4,co3,e-',
		"W"='do4,b-,e-o4',
		"S"='fo3,fo4,g',
		"X"='co3,e-,g',
		"E"='go3 co4 do4,b-o3,co4',
		"D"='fo4,g,co5',
		"C"='co4 f g,a'
		]
	$.assign_norm[na++] = [
		"Q"='go2,b-',
		"A"='e-o2d48,g,b-',
		"Z"='co3d24,co3,e-',
		"W"='b-o2d48,g,e-o4',
		"S"='fo2,fo3,g',
		"X"='co2,e-,g',
		"E"='b-o2,b-o2,co4',
		"D"='fo3d48,g,co5',
		"C"='e-o3d24,e-o4,f'
		]
	$.assign_norm[na++] = [
		"Q"='co3',
		"A"='do3',
		"Z"='e-o3',
		"W"='fo3',
		"S"='go3',
		"X"='co4',
		"E"='b-o3',
		"D"='do4',
		"C"='go4'
		]

	nd = 0
	$.assign_drum[nd++] = [
		"Q"='p35v110',
		"A"='p38v80',
		"Z"='p41v90',
		"W"='p47v80',
		"S"='p38',	# not used
		"X"='p43v100',
		"E"='p50v90',
		"D"='p54v45',
		"C"='p65'
		]
	$.assign_drum[nd++] = [
		"Q"='p36v100',
		"A"='p41v90',
		"Z"='p40',
		"W"='p46v80',
		"S"='p38',	# not used
		"X"='p61v80',
		"E"='p42v100',
		"D"='p60',
		"C"='p48v100'
		]
	v = 110
	for ( ni in $.assign_norm ) {
		letts = $.assign_norm[ni]
		for ( letter in letts ) {
			letts[letter].vol = v
			letts[letter].pitch -= 19
		}
	}
	for ( i in $.assign_norm ) {
		$.typo.ctrl_assign_fix_tpa_arr1($.assign_norm[i])
	}
	for ( i in $.assign_drum ) {
		$.typo.ctrl_assign_fix_tpa_arr1($.assign_drum[i])
	}
}

method reset4looper() {
	realtime(gvolchange(110))
	realtime(gexpressionchange(110))
	$.avoidchans = []
}

method feedback {
	realtime(repeat($.startcmode,2))
}

method restartmusicfile() {
	$.nextmusicfile(-1,$.musicname)
}

method nextmusicfile(pos,nm) {
	nochange = 0
	if ( nargs() > 1 ) {
		cs = sizeof($.cycle)
		for ( n=0; n<cs; n++ ) {
			if ( $.cycle[n]["fname"] == nm )
				break
		}
		if ( n >= cs ) {
			arr = ["fname"=nm,"type"="gm2","tempo"=500000]
		} else {
			arr = $.cycle[n]
		}
	} else {
		if ( nargs() > 0 ) {
			$.cyclepos = pos
		} else {
			$.cyclepos++
		}
		if ( $.cyclepos < 0 || $.cyclepos >= sizeof($.cycle) )
			$.cyclepos = 0

		arr = $.cycle[$.cyclepos]
		while ( ! ( arr["atts"] ~~ (".*"+$.filetype+".*") ) ) {
			$.cyclepos++
			if ( $.cyclepos >= sizeof($.cycle) )
				$.cyclepos = 0
			arr = $.cycle[$.cyclepos]
		}
	}

	fn = arr["fname"]
	t = arr["type"]

	$.musicname = fn
	print("MUSIC = ",$.musicname)

	rp = ''
	if ( t == "gm2" ) {
		rp = gm2on()
	} else if ( t == "native" ) {
		rp = sd80_nativeon()
	} else if ( t == "gs" ) {
		rp = gs_reset()
	} else {
		print("Unrecognized type=",t," for fn=",fn)
	}
	realtime(rp)
	realtime(resetall())

	Offsetfilter = (1<<9)
	Offsetpitch = 0

	if ( "tempo" in arr ) {
		tempo(arr["tempo"])
	} else {
		tempo(500000)
	}
	if ( "show" in arr ) {
		$.avoidchans = []
		show = arr["show"]
		for ( ch=1; ch<=16; ch++ ) {
			if ( ! ( ch in show ) ) {
				$.avoidchans[ch] = 1
			}
		}
	} else {
		$.avoidchans = $.default_avoidchans
	}
	if ( "lighteroffset" in arr ) {
		$.lighteroffset = arr["lighteroffset"]
	} else {
		$.lighteroffset = 0
	}

	if ( "expr" in arr ) {
		e = arr["expr"]
	} else {
		e = $.default_expr
	}
	if ( "vol" in arr ) {
		v = arr["vol"]
	} else {
		v = $.default_vol
	}
	sleeptill(Now+1b/4)
	realtime(gvolchange(v))
	realtime(gexpressionchange(e))
	if ( "prep" in arr ) {
		realtime(arr["prep"])
	}
	sleeptill(Now+1b/4)

	$.filebutt.setbyval(fn)
	$.filebutt.redraw()

	if ( nochange == 0 && $.player != $0 )
		$.player.musicchange()
}

method setdefaultplayers(redraw) {
	$.playerbutt.setbyval($.defplayer)	# default player
	$.lighterbutt.setbyval($.deflighter)	# default lighter
	if ( redraw ) {
		$.playerbutt.redraw()
		$.lighterbutt.redraw()
	}
}

method activatecurrent() {
	if ( sizeof($.playernames) > 0 )
		$.activateplayer($.playerbutt.get())
	else
		print("No players found?")

	if ( sizeof($.lighters) > 0 )
		$.activatelighter($.lighterbutt.get())
	else
		print("No lighters found?")
}

method verboseon {
	$.typo.setverbose(1)
}
method verboseoff {
	$.typo.setverbose(0)
}
method displayoff {
	$.lyre.setdrawing(0)
}
method displayon {
	$.lyre.setdrawing(1)
}
method killchanging {
	if ( $.changertid != -1 )
		kill($.changertid)
	$.changertid = -1
}
method changeoff {
	$.dochanging = 0
	$.killchanging()
	nm = $.deflighter
	$.activatelighter($.indexoflighter(nm))
}
method changeon {
	$.dochanging = 1
	$.killchanging()
	$.changertid = task $.changer()
}

method gettypo {
	return($.typo)
}

method notifyoffset() {
	# print("WBURN notifyoffset! calling lyre.alloff Offsetpitch=",Offsetpitch)
	if ( $.dolyre )
		$.lyre.alloff(1)
}
method notify(p,tm) {
	if ( $.dolyre ) {
		if ( nargs() < 2 )
			$.tolighter(p)
		else
			$.tolighter(p,tm)
	}
}

method tolighter(p,tm) {
	for ( n in p ) {
		if ( n.chan in $.avoidchans ) {
			continue
		}
		if ( (n.type==NOTE || n.type==NOTEON || n.type==NOTEOFF) ) {
			if ( $.lighteroffset != 0 )
				n.pitch += $.lighteroffset
			$.lighter.notefunc(n,tm)
		}
	}
}

method getmusic {
	v = $.filebutt.getvalue()
	return($.file2music[v])
}

method reread() {
	$.getplugins()
	$.lighterbutt.setvals($.lighternames)
	$.playerbutt.setvals($.playernames)

	$.getmusicfiles()
	$.filebutt.setvals($.files)
}

method getlyre { return($.lyre) }
method getlow { return($.low) }
method gethigh { return($.high) }

method getmusicfiles {
	$.files = []
	$.file2music = []
	n = 0
	files = lsdir($.musicdir)
	for ( fn in files ) {
		if ( fn ~~ ".*\\.mid$" ) {
			$.files[n++] = fn
			$.file2music[fn] = $.readmusic(fn)
		}
	}
	$.files = arraysort($.files)
}
method gettpafiles {
	$.typofiles = []
	n = 0
	files = lsdir($.musicdir)
	for ( fn in files ) {
		if ( fn ~~ ".*\\.tpa$" ) {
			$.typofiles[n++] = fn
		}
	}
	$.typofiles = arraysort($.typofiles)
}

method getplugins() {
	path = Keypath
	dirs = split(path,Pathseparator)
	for ( i in dirs ) {
		dir = dirs[i]
		if ( dir == "" )
			continue
		lighterprefix = "lyre_lighter_"
		playerprefix = "lyre_player_"
		files = lsdir($.lyredir)
		# remove all the files we're not interested in
		BurnObj = $
		for ( fn in files ) {
			if ( fn ~~ (lighterprefix+".*\\.k$") ) {
				nm = substr(fn,sizeof(lighterprefix)+1)
				nm = substr(nm,1,sizeof(nm)-2)
				$.lighternames[sizeof($.lighternames)] = nm
				fp = $.lyredir + Dirseparator + fn
				# print("Reading "+fp)
				eval "#include \""+fp+"\""

				cmd = "t=global(lyre_lighter_"+nm+");__PTMP=new t(BurnObj);"
				eval cmd
				$.lighters[nm] = global(__PTMP)
			}
		}
	}
}

method delete {
	print("burn being deleted")
	kill($.ptid)
	$.joy.unnotify($.typo,-1)
	$.stop(0)
	$.typoquit()
	deleteobject($.typo)
}
method typoquit {
	$.typoinput("+CTRL")
	$.typoinput("+X")
	$.typoinput("-X")
	$.typoinput("-CTRL")
	$.typoinput("+Q")
	$.typoinput("-Q")
	$.typo.final_cleanup()
}
method stop(drawit) {
	if ( nargs() < 1 )
		drawit = 1
	$.alloff(drawit)

	$.lighter.stoptids()
	$.player.stoptids()

	$.killchanging()
}
method restart {
	print("WBURN RESTART")
	$.stop()
	$.setdefaultplayers(1)
	$.activatecurrent()
	$.player.initmusic()
	$.player.start()
	$.lighter.start()
}
method notifystart(tm) {
	lock($)
 	$.alloff(1)
 	$.lighter.start(tm)
	$.killchanging()
	if ( $.dochanging )
		$.changertid = task $.changer(tm)
	unlock($)
}
method indexoflighter(ln) {
	for ( i in $.lighternames ) {
		if ( ln == $.lighternames[i] )
			return(i)
	}
	return(0)
}
method changer(tm) {
	if ( nargs() < 1 )
		tm = nextquant(Now,$.lighterquant)
	nm = $.lseq[$.lighterindex]["name"]
	$.activatelighter($.indexoflighter(nm))
	sleeptill(tm)
	while (1) {
		tm += $.lseq[$.lighterindex]["duration"]
		sleeptill(tm)
# print("changer tm=",tm)

		$.lighterindex++
		if ( ! $.lighterindex in $.lseq )
			$.lighterindex = 0

		nm = $.lseq[$.lighterindex]["name"]
		$.activatelighter($.indexoflighter(nm))
	}
}
method notifybeat(tm) {
 	$.lighter.beatfunc(tm)
}
method notifystop() {
	$.stop()
}
method switch {
	lock($)
	$.lastpress = Now
	v = $.playerbutt.get()
	if ( v == 0 ) {
		# switching from looper to playfile
print("\nSWITCHING to playfile")

		$.stop()

		$.player.killallpads()

		Offsetfilter = (1<<9)
		Offsetpitch = 0

		$.mode = "playfile"
		$.playerbutt.setbyval($.mode)
		$.playerbutt.redraw()

		$.activateplayer(1)

		$.restartmusicfile()
		$.player.start()
print("END of SWITCHING to playfile")
	} else {
		# switching from playfile to looper
print("\nSWITCHING to looper")

		$.avoidchans = []

		$.stop()

		Offsetfilter = (1<<9)
		Offsetpitch = 0

print("Sleeping in switch");sleeptill(Now+2b)

		$.mode = "looper"
		$.playerbutt.setbyval($.mode)
		$.playerbutt.redraw()

		$.activateplayer(0)

		realtime(gvolchange($.default_vol))
		realtime(gexpressionchange($.default_expr))
		$.player.initialpatches(1)
		# $.player.start()

		# YES, there are two activate player calls here.
		# $.activateplayer(0)

		$.player.killallpads()

		$.reset4looper()
print("END of SWITCHING to looper")
	}
	unlock($)
}
method permatask {
	while ( 1 ) {
		sleeptill(Now+4b)
		if ( $.mode == "playfile" ) {
			dt = (Now - $.lastpress)
			if ( dt > milliclicks(1000*$.playidle)) {
				print("Player has been idle for ",$.playidle," secs")
				$.lastpress = Now
			}
		} else {
			dt = (Now - $.lastpress)
			if ( dt > milliclicks(1000*$.loopidle)) {
				print("Looper has been idle for ",$.loopidle," secs")
				$.lastpress = Now
				task $.switch()
			}
		}
	}
}
method notifyloop() {
	print("NOTIFYLOOP in wburn")
}
method notifyend() {
	if ( $.autoadvance ) {
		$.nextmusicfile()
		sleeptill(Now+2b)
		$.player.start()
	}
}
method activatelighter(ln) {
	if ( ! (ln in $.lighternames) ) {
		print("Hey, no lighter number ",ln)
		return()
	}
	if ( $.lighter != $0 ) {
		$.lighter.stop()
	}
	if ( $.dolyre )
		$.lyre.alloff(1)
	nm = $.lighternames[ln]
	if ( ! (nm in $.lighters) ) {
		print("No lighter named ",nm)
		return()
	}
	$.lighter = $.lighters[nm]
	$.lighter.activate()
	if ( $.player.isrunning() )
		$.lighter.start()
}

method activateplayer(pn) {
	if ( ! (pn in $.playernames) ) {
		print("Hey, no player number ",pn)
		return()
	}
	$.resetpads()
	if ( $.player != $0 ) {
		$.player.stop()
		if ( $.dolyre ) {
			$.lyre.alloff(1)
		}
	}
	nm = $.playernames[pn]
	if ( ! (nm in $.players) ) {
		print("No player named ",nm)
		return()
	}
	$.player = $.players[nm]
	$.player.activate()
}

method getquant {
	return($.lighterquant)
}
method readmusic(fn) {
	if ((fn ~~ ":")||(fn ~~ "\\")||(fn ~~ "/")) {
		p = readmf(fn)
	} else {
		p = readmf($.musicdir+Dirseparator+fn)
	}

	# print("READMUSIC fn=",fn,"      latest=",latest(p)/1b)

	# p = quantizefirst(p,$.lighterquant)

	# reduce duration so notes that end when another
	# one starts won't cause un-lit strings
	# p.dur -= 2

	return(p)
}
method pitchrange(low,high) {
	$.low = low
	$.high = high
}

method analogchange(padnum,nm,updown) {
}
method buttonchange(padnum,nm,updown) {
	$.lastpress = Now
	$.padfunc(padnum,nm,updown)
	$.lighter.padfunc(padnum,nm,updown)
}
method resetpad(n) {
	$.commandmode[n] = 0
	$.commandpad[n] = 0
	$.upcount[n] = 0
	$.lastselect[n] = 0
	$.selectisdown[n] = 0
}
method resetpads {
	$.commandmode = []
	$.commandpad = []
	$.upcount = []
	$.lastselect = []
	$.selectisdown = []
	$.resetpad(0)
	$.resetpad(1)
	$.resetpad(2)
	$.resetpad(3)
}
method padfunc(padnum,nm,updown) {

	cmode = $.commandmode[padnum]
	if ( cmode && nm == "SELECT" && updown == 0) {
		$.resetpad(padnum)
		realtime(repeat($.endcmode,$.commandmode[padnum]))
		return()
	}

	if ( cmode && nm != "SELECT" && nm != "START" ) {
		c = $.commandpad[padnum]

		# "UP" can't be the first one of a command pair,
		# since it's the one that puts you into command mode

		if ( updown == 1 && (c != 0 || nm!="UP") ) {
			if ( c == 0 ) {
				$.commandpad[padnum] = nm
			} else {
				$.player.pad_command(padnum,c,nm,cmode)
				$.commandpad[padnum] = 0
			}
		}
		return()
	}
	select = $.selectisdown[padnum]
	if ( select != 0 && nm == "UP" ) {
		if ( updown == 1 ) {
			# If SELECT has been held down for > 3 seconds, look
			# for UP presses.  The number of up presses
			# will indicate the command mode
			ds = millisince($.lastselect[padnum])
			if ( ds > 3000 ) {
				$.upcount[padnum]++
				if ( $.upcount[padnum] > 2 ) {
					$.commandmode[padnum]++
					realtime(repeat($.startcmode,$.commandmode[padnum]))
				}
			}
		}
		return()
	}

	$.upcount[padnum] = 0	# any other press resets up count

	if ( nm == "SELECT" ) {
		if ( updown == 1 ) {
			lastsel = $.lastselect[padnum]
			if ( lastsel > 0 && millisince(lastsel) < 1000 ) {
				$.player.pad_select2(padnum)
				$.lastselect[padnum] = 0
			} else {
				$.player.pad_select(padnum)
				$.lastselect[padnum] = Now
			}
			$.selectisdown[padnum] = 1
		} else {
			$.selectisdown[padnum] = 0
		}
		return()
	}
	if ( nm == "START" ) {
		if ( updown == 1 ) {
			if ( select != 0 )
				$.player.pad_select_start(padnum)
			else
				$.player.pad_start(padnum)
		}
		return()
	}

	$.player.padfunc(padnum,nm,updown)
}
method play(p,t0) {

	# prognotes = progchangenotes(p)
	# if ( prognotes != '' ) {
	# 	print("prognotes=",prognotes)
	# }
	# volnotes = volumenotes(p)
	# if ( volnotes != '' ) {
	# 	print("volnotes=",volnotes)
	# }
	# enotes = expressionnotes(p)
	# if ( enotes != '' ) {
	# 	print("expressionnotes=",enotes)
	# }

	realtime(p,t0)
	if ( $.dolyre ) {
		if ( ( t0 % 1b ) == 0 ) {
			$.lighter.beatfunc(t0)
		}
		$.tolighter(p,t0)
	}
}
method lighterchange(v) {
	$.activatelighter(v)
	if ( $.dolyre )
		$.lyre.alloff(1)
}
method playerchange(v) {
print("Calling activateplayer v=",v)
	$.activateplayer(v)
	if ( v == 1 ) {
		$.nextmusicfile(0)
	}
}
method typofilechange(v) {
	$.loadtypo($.typofiles[v])
}
method loadtypo(fn) {
	fn = $.musicdir+Dirseparator+fn
	if ( $.player != $0 )
		$.player.assignchange(fn)
}
method filechange(v) {

print("filechange nm=",nm)
	$.stop()
	if ( $.player != $0 )
		$.player.stop()
	sleeptill(Now+2b)

	if ( $.player != $0 ) {
		nm = $.files[v]
print("filechange nm=",nm)
		$.nextmusicfile(-1,nm)
		$.player.start()
		$.lighter.start()
	} else {
print("Couldn't find v=",v," in filechange")
	}
	
}
method typobuttonchange(padnum,nm,updown) {
	$.typo.buttonchange(padnum,nm,updown)
}
method typoinput(s) {
	$.typo.input(s)
}
method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	else
		sz = $.w.size()
	$.th = $.textheight()
	$.tw = $.textwidth()
	$.x0 = sz["x0"]+3
	$.y0 = sz["y0"]+1
	$.y0a = sz["y0"]+$.th+6
	$.y0b = sz["y0"]+2*$.th+10
	$.y0c = sz["y0"]+4*$.th
	$.x1 = sz["x1"]-3
	$.y1 = sz["y1"]-3
	$.mx = $.x0 + ($.x1-$.x0)/2
	$.my1 = $.y0c + ($.y1-$.y0c)/3 - $.th
	$.my2 = $.y0c + 2*($.y1-$.y0c)/3
	$.pad[0].resize(xy($.x0,$.y0c,$.mx,$.my1))
	$.pad[1].resize(xy($.mx+2,$.y0c,$.x1,$.my1))
	$.pad[2].resize(xy($.x0,$.my2+2+$.th/2,$.mx,$.y1))
	$.pad[3].resize(xy($.mx+2,$.my2+2+$.th/2,$.x1,$.y1))

	$.lx = $.textwidth()
	$.ly = $.textheight()/2
	$.xtopleft = $.x0+4*$.lx
	$.ytop = $.my1+2+3*$.ly
	$.ybot = $.my2-2
	$.xtopright = $.x1-4*$.lx
	$.lyre.resize(xy($.xtopleft,$.ytop,$.xtopright,$.my2-2))

	$.dx = ($.x1 - $.x0) / 16
	$.menubutt.resize(xy($.x0+0*$.dx+2,$.y0a,$.x0+3*$.dx,$.y0b-2))

	$.title.resize(xy($.x0+2,$.y0,$.x0+3*$.dx,$.y0a-1))
	$.playertitle.resize(xy($.x0+4*$.dx+2,$.y0,$.x0+7*$.dx,$.y0a-1))
	$.musictitle.resize(xy($.x0+7*$.dx+2,$.y0,$.x0+10*$.dx,$.y0a-1))
	$.typotitle.resize(xy($.x0+10*$.dx+2,$.y0,$.x0+13*$.dx,$.y0a-1))
	$.lightertitle.resize(xy($.x0+13*$.dx+2,$.y0,$.x0+16*$.dx,$.y0a-1))

	$.playerbutt.resize(xy($.x0+4*$.dx+2,$.y0a,$.x0+7*$.dx,$.y0b-2))
	$.filebutt.resize(xy($.x0+7*$.dx+2,$.y0a,$.x0+10*$.dx,$.y0b-2))
	$.typofilebutt.resize(xy($.x0+10*$.dx+2,$.y0a,$.x0+13*$.dx,$.y0b-2))
	$.lighterbutt.resize(xy($.x0+13*$.dx+2,$.y0a,$.x0+16*$.dx,$.y0b-2))
}
method redraw {
	$.w.redraw()

	$.w.fillrectangle(xy($.x0,$.my1,$.x1,$.my2+$.th/2-2),STORE)

	$.w.line(xy($.xtopleft,$.ytop,$.xtopleft,$.ytop-$.ly),CLEAR)
	$.w.line(xy($.xtopleft,$.ytop-$.ly,$.xtopleft-$.lx,$.ytop-2*$.ly),CLEAR)
	$.w.line(xy($.xtopleft-$.lx,$.ytop-2*$.ly,$.xtopleft-2*$.lx,$.ytop-2*$.ly),CLEAR)
	$.w.line(xy($.xtopleft-2*$.lx,$.ytop-2*$.ly,$.xtopleft-3*$.lx,$.ytop-$.ly),CLEAR)
	$.w.line(xy($.xtopleft-3*$.lx,$.ytop-$.ly,$.xtopleft-3*$.lx,$.ytop),CLEAR)
	$.w.line(xy($.xtopleft-3*$.lx,$.ytop,$.xtopleft-2.5*$.lx,$.ytop+0.5*$.ly),CLEAR)
	$.w.line(xy($.xtopleft-2.5*$.lx,$.ytop+0.5*$.ly,$.xtopleft-2*$.lx,$.ytop+0.5*$.ly),CLEAR)
	$.w.line(xy($.xtopleft-2*$.lx,$.ytop+0.5*$.ly,$.xtopleft-1.5*$.lx,$.ytop),CLEAR)
	$.w.line(xy($.xtopleft,$.ytop,$.xtopleft-2*$.lx,$.ybot-4*$.ly),CLEAR)
	$.w.line(xy($.xtopleft-2*$.lx,$.ybot-4*$.ly,$.xtopleft-2*$.lx,$.ybot-2*$.ly),CLEAR)
	$.w.line(xy($.xtopleft-2*$.lx,$.ybot-2*$.ly,$.xtopleft,$.ybot),CLEAR)


	$.w.line(xy($.xtopright,$.ytop,$.xtopright,$.ytop-$.ly),CLEAR)
	$.w.line(xy($.xtopright,$.ytop-$.ly,$.xtopright+$.lx,$.ytop-2*$.ly),CLEAR)
	$.w.line(xy($.xtopright+$.lx,$.ytop-2*$.ly,$.xtopright+2*$.lx,$.ytop-2*$.ly),CLEAR)
	$.w.line(xy($.xtopright+2*$.lx,$.ytop-2*$.ly,$.xtopright+3*$.lx,$.ytop-$.ly),CLEAR)
	$.w.line(xy($.xtopright+3*$.lx,$.ytop-$.ly,$.xtopright+3*$.lx,$.ytop),CLEAR)
	$.w.line(xy($.xtopright+3*$.lx,$.ytop,$.xtopright+2.5*$.lx,$.ytop+0.5*$.ly),CLEAR)
	$.w.line(xy($.xtopright+2.5*$.lx,$.ytop+0.5*$.ly,$.xtopright+2*$.lx,$.ytop+0.5*$.ly),CLEAR)
	$.w.line(xy($.xtopright+2*$.lx,$.ytop+0.5*$.ly,$.xtopright+1.5*$.lx,$.ytop),CLEAR)
	$.w.line(xy($.xtopright,$.ytop,$.xtopright+2*$.lx,$.ybot-4*$.ly),CLEAR)
	$.w.line(xy($.xtopright+2*$.lx,$.ybot-4*$.ly,$.xtopright+2*$.lx,$.ybot-2*$.ly),CLEAR)
	$.w.line(xy($.xtopright+2*$.lx,$.ybot-2*$.ly,$.xtopright,$.ybot),CLEAR)

	methodbroadcast()

}
method alloff(...) {
	realtime(ano())
	realtime(allsusoff())
	if ( $.dolyre )
		$.lyre.alloff(...)
}
method addfile {
	fn = browsefiles("Midi files (*.mid)","*.mid",1)
	if ( fn == "" )
		return()
	$.file2music[fn] = $.readmusic(fn)
	$.files[sizeof($.files)] = fn
	$.filebutt.setvals($.files)
}
}

################# BASE CLASS FOR LIGHTER ###################

class lyre_lighter {
method init (burn) {
	$.burn = burn
	$.lyre = burn.getlyre()
	$.tids = []
	$.low = burn.getlow()
	$.high = burn.gethigh()
}
method activate {
}
method start {
}
method stop {
}
method stoptids {
	for ( t in $.tids )
		kill(t)
	$.tids = []
}
method addtid(t) {
	$.tids[t] = 1
}
method padfunc(padnum,nm,updown) {
}
method notefunc(n,t0) {
}
method beatfunc() {
}
}

################# BASE CLASS FOR PLAYER ###################

class lyre_player {
method init (burn) {
	$.burn = burn
	$.tids = []
}
method delete {
	$.stop()
}
method isrunning {
	return(1)
}
method initmusic {
}
method musicchange {
}
method assignchange {
}
method pad_start {
}
method pad_select_start {
}
method pad_select {
}
method pad_select2 {
}
method pad_command {
}
method stoptids {
	for ( t in $.tids )
		kill(t)
	$.tids = []
}
method addtid(t) {
	$.tids[t] = 1
}
}

##########################################################

function mkmenu_burn(o,po) {
	o.menucmd("Switch Mode",	po,"switch")
	o.menucmd("Next Music",		po,"nextmusic")
	o.menucmd("All Lights Off",	po,"alloff")
	o.menucmd("Changing Off",	po,"changeoff")
	o.menucmd("Changing On",	po,"changeon")
	o.menucmd("Screen Off",		po, "displayoff")
	o.menucmd("Screen On",		po,"displayon")
	o.menucmd("Stop",		po,"stop")
	o.menucmd("Restart",		po,"restart")
	o.menucmd("Add File",		po,"addfile")
	o.menucmd("Verbose On",		po,"verboseon")
	o.menucmd("Verbose Off",	po,"verboseoff")
	o.menucmd("Reread plugins/music",	po,"reread")
}
