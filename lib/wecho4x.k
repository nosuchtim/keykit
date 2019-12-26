class wecho4x {
method init {
	$.w = new window()
	$.inherit($.w)

	$.origmerge = Merge
	$.merge = 1
	$.timestep = 1b/4
	$.tid = -1
	$.constid = -1
	$.gestureon = 0
	$.gesturenotesdev = -1
	$.gesturecontroldev = -1
	$.outport = []
	$.outch = []
	$.progv = []
	for ( n=0; n<4; n++ ) {
		$.outch[n] = 1
		$.outport[n] = 0
		$.progv[n] = 0
	}
	$.quant = 0
	$.key = 0
	$.invert = 0
	$.inverton = 0
	$.quanton = 0
	# $.autosave = 1
	$.remap = 0
	$.rest = 0
	$.currentkey = -1
	$.currentscale = -1
	$.merge = 1
	$.inch = 0

	$.timevals = [
		0 = 0,
		1 = 1b/32,
		2 = 1b/16,
		3 = 1b/8,
		4 = 1b/4,
		5 = 3b/8,
		6 = 1b/2,
		7 = 3b/4,
		8 = 1b,
		9 = 12b/8,
		10 = 2b,
		11 = 3b,
		12 = 4b]
	$.timeslidersteps = sizeof($.timevals)
	$.timesliderstepsperbeat = 16

	$.time_tot = []

	$.val = []
	$.val["time"] = []
	$.val["trans"] = []
	$.val["vol"] = []
	$.val["ntimes"] = []
	for ( n=0; n<4; n++ ) {
		$.val["time"][n] = $.timesliderstepsperbeat
		$.val["trans"][n] = 0
		$.val["vol"][n] = 90
		$.val["ntimes"][n] = (n==0 ? 1 : 0)
	}

	$.c = []

	$.c["slider_time"] = []
	$.c["slider_trans"] = []
	$.c["slider_vol"] = []
	$.c["slider_ntimes"] = []
	$.c["text_time"] = []
	$.c["text_trans"] = []
	$.c["text_vol"] = []
	$.c["text_ntimes"] = []
	for ( n=0; n<4; n++ ) {
		$.c["slider_time"][n] = new kslider(0,$.timeslidersteps,
			$.val["time"][n], $,"callback","time",n)
		$.c["slider_trans"][n] = new kslider(-12,12,$.val["trans"][n],
			$,"callback","trans",n)
		$.c["slider_vol"][n] = new kslider(0,100,$.val["vol"][n],
			$,"callback","vol",n)
		$.c["slider_ntimes"][n] = new kslider(0,16,$.val["ntimes"][n],
			$,"callback","ntimes",n)
		$.c["text_time"][n] = new ktext("")
		$.c["text_vol"][n] = new ktext("")
		$.c["text_ntimes"][n] = new ktext("")
		$.c["text_trans"][n] = new ktext("")
	}
	for ( t in $.c ) {
		for ( n=0; n<4; n++ ) {
			$.addchild($.c[t][n])
		}
	}

	$.c["on"] = new ktoggle("On",$,"setonoff")
	$.addchild($.c["on"])
	$.c["conson"] = new ktoggle("Cons",$,"consonoff")
	$.addchild($.c["conson"])
	$.c["gestureon"] = new ktoggle("Gest",$,"gestureonoff")
	$.addchild($.c["gestureon"])

	# text (containing values) gets initialized
	for ( i in arraylist("time","trans","vol","ntimes") ) {
		for ( n=0; n<4; n++ ) {
			$.set($.val[i][n],i,n)
		}
	}


	# In Channel button
	incharr = [0="In Omni"]
	for ( n=1; n<=16; n++ )
		incharr[n] = "In "+string(n)
	$.inchanbutt = new kvalbutton(incharr,$,"inchanchanged")
	$.addchild($.inchanbutt)

	$.patches = []
	$.get_patches()
	$.patchnames = $.get_patches_names()

	$.patchbutt = new kvalbutton($.patchnames,$,"patchchanged")
	$.addchild($.patchbutt)
	$.patchcurrent = $.patchnames[0]

	$.patchnewbutt = new kbutton("Save As",$,"patchnew")
	$.addchild($.patchnewbutt)

	$.patchrevertbutt = new kbutton("Revert",$,"patchrevertcurrent")
	$.addchild($.patchrevertbutt)

	$.patchsavebutt = new kbutton("Save",$,"patchsavecurrent")
	$.addchild($.patchsavebutt)

	portarr = wecho4x_outputs()
	$.portvarr = portarr["vals"]
	$.portnarr = portarr["names"]

	$.getpnames()
	$.progbutt = []
	$.portbutt = []
	$.outchanbutt = []
	charr = []
	for ( n=1; n<=16; n++ )
		charr[n-1] = "Out "+string(n)
	for ( n=0; n<4; n++ ) {
		$.outchanbutt[n] = new kvalbutton(charr,$,"chanchanged",n)
		$.addchild($.outchanbutt[n])
		$.portbutt[n] = new kvalbutton($.portnarr,$,"outportchanged",n)
		$.addchild($.portbutt[n])
		$.progbutt[n] = new kvalbutton($.pnames,$,"progchanged",n)
		$.addchild($.progbutt[n])
	}

	$.row2quantval = [0=4,1=3,2=2,3=1]

	$.quantnames = [ 0="1 click", 1="32nd", 2="16th", 3="Eighth", 4="Quarter", 5="Half" ]
	$.quantvals = [0=1, 1=1b/8, 2=1b/4, 3=1b/2, 4=1b, 5=1b*2 ] 
	$.quantbutt = new kvalbutton($.quantnames,$,"quantchanged")
	$.addchild($.quantbutt)
	$.quantbutt.set($.quant)

	$.invertonarr = [0="Invert Off",1="Invert On"]
	$.invertonbutt = new kvalbutton($.invertonarr,$,"invertonchanged")
	$.addchild($.invertonbutt)

	$.quantonarr = [0="Quant Off",1="Quant On"]
	$.quantonbutt = new kvalbutton($.quantonarr,$,"quantonchanged")
	$.addchild($.quantonbutt)

	# $.autosavearr = [0="AutoSave Off",1="AutoSave On"]
	# $.autosavebutt = new kvalbutton($.autosavearr,$,"autosavechanged")
	# $.addchild($.autosavebutt)

	$.invertarr = []
	n = 0
	for ( p=1; p<127; p++ ) {
		nt = makenote(p)
		$.invertarr[n++] = string("Invert "+string(nt))
	}
	$.invertbutt = new kvalbutton($.invertarr,$,"invertchanged")
	$.addchild($.invertbutt)

	$.remaparr = [0="Map Off",1="Map On"]
	$.remapbutt = new kvalbutton($.remaparr,$,"remapchanged")
	$.addchild($.remapbutt)

	$.mergearr = [0="Process 1st note",
		1="Don't touch 1st note",
		2="Eliminate 1st note",
		3="Process 1st note w/vol"]
	$.mergebutt = new kvalbutton($.mergearr,$,"mergechanged")
	$.addchild($.mergebutt)
	$.mergebutt.set(1)

	$.restarr = [0="Rest Off"]
	for ( r=1; r<=10; r+=1 ) {
		$.restarr[r] = "Rest "+string(r*10)+"%"
	}
	$.restbutt = new kvalbutton($.restarr,$,"restchanged")
	$.addchild($.restbutt)

	$.keys = [0="C",1="C#",2="D",3="D#",4="E",5="F",
		6="F#",7="G",8="G#",9="A",10="A#",11="B"]
	$.keybutt = new kvalbutton($.keys,$,"keychanged")
	$.addchild($.keybutt)

	$.scales = []
	n = 0
	initial = 0
	for ( i in allscales() ) {
		if ( i == "newage" )
			initial = n
		$.scales[n++] = string(i)
	}
	
	$.scalebutt = new kvalbutton($.scales,$,"scalechanged")
	$.addchild($.scalebutt)
	$.scale = $.scales[initial]
	$.scalebutt.set(initial)

	$.title = new ktext("Echo4X")
	$.title.style(NOBORDER)
	$.title.setjust("left")
	$.addchild($.title)

	$.patchtitle = new ktext("Patch:")
	$.patchtitle.style(NOBORDER)
	$.patchtitle.setjust("right")
	$.addchild($.patchtitle)

}

method get_patches_names {
	arr = []
	i = 0
	for ( n in $.patches ) {
		arr[i++] = n
	}
	return(arr)
}
method get_patches {
	arr = []
	n = 0
	global __EchoxArr
	arr["default"] = [
		"outch" = [0="Out 1",1="Out 1",2="Out 1",3="Out 1"],
		"port" = [0=0,1=0,2=0,3=0],
		"prog" = "Clav",
		"quanton" = "Quant On",
		"quant" = "1 click",
		"remap" = "Map On",
		"key" = "C",
		"scale" = "newage",
		"rest" = "Rest Off",
		"inverton" = "Invert Off",
		"invert" = "Invert 'c'",
		"merge" = "Don't touch 1st note",
		"inch" = "In Omni"
		]
	path = Keypath
	dirs = split(path,Pathseparator)
	for ( i in dirs ) {
		dir = dirs[i]
		if ( dir == "" )
			continue
		files = lsdir(dir)
		for ( fn in files ) {
			if ( fn ~~ (".*\\.ep$") ) {
				eval "#include \""+fn+"\""
				parr = __EchoxArr
				nm = substr(fn,1,sizeof(fn)-3)
				$.patches[nm] = parr
			}
		}
	}
	return(arr)
}

method patchchanged(v) {

	# if ( $.autosave )
	# 	$.patchsavecurrent()
	nm = $.patchnames[v]
	$.patchgoto(nm)
	$.redraw()
}
method currentarr() {
	outcharr = []
	outportarr = []
	progarr = []
	for ( n=0; n<4; n++ ) {
		outcharr[n] = $.outchanbutt[n].getvalue()
		outportarr[n] = $.portbutt[n].getvalue()
		progarr[n] = $.progbutt[n].getvalue()
	}
	return( [
		"time"= $.val["time"],
		"trans"= $.val["trans"],
		"vol"= $.val["vol"],
		"ntimes"= $.val["ntimes"],
		"outch" = outcharr,
		"port" = outportarr,
		"prog" = progarr,
		"quanton" = $.quantonbutt.getvalue(),
		"quant" = $.quantbutt.getvalue(),
		"remap" = $.remapbutt.getvalue(),
		"key" = $.keybutt.getvalue(),
		"scale" = $.scalebutt.getvalue(),
		"rest" = $.restbutt.getvalue(),
		"inverton" = $.invertonbutt.getvalue(),
		"invert" = $.invertbutt.getvalue(),
		"merge" = $.mergebutt.getvalue(),
		"inch" = $.inchanbutt.getvalue()
		]
		)
}
method writeep(nm,parr) {
	f = open(nm+".ep","w")
	put(f,"__EchoxArr=")
	put(f,parr)
	close(f)
}
method patchnew(v) {
	nm = getastr("Enter patch name --> ")
	parr = $.currentarr()
	$.writeep(nm,parr)
	$.patches[nm] = parr
	$.patchnames[sizeof($.patchnames)] = nm
	$.patchbutt.setvals($.patchnames)
	$.patchbutt.setbyval(nm)
	$.patchbutt.redraw()
	$.patchcurrent = nm
}
method patchsavecurrent() {
	nm = $.patchcurrent
	parr = $.currentarr()
	$.writeep(nm,parr)
	$.patches[nm] = parr
}
method patchrevertcurrent() {
	$.patchgoto($.patchcurrent)
	$.redraw()
}

method getpnames() {
	defouts = midi("portmap")[0]
	outnames = midi("output","list")

	out = defouts[$.outch]
	if ( out in Port2Patchmap )
		$.pmap = Port2Patchmap[out]
	else
		$.pmap = patchmap_gm()
	$.pnames = patchmapnames($.pmap)
}

method scalechanged(v) {
	$.scale = $.scales[v]
}

method progchanged(v,n) {
	$.progv[n] = v
	$.sendprogram(n)
}
method remapchanged(v) {
	$.remap = v
}
method mergechanged(v) {
	$.merge = v
	$.setrealmerge()
}
method setrealmerge() {
	if ( $.merge == 0 || $.merge == 2 || $.merge == 3)
		Merge = 0
	else
		Merge = 1
}

method quantchanged(v) {
	$.quant = v
}

method invertchanged(v) {
	$.invert = v+1
}
method invertonchanged(v) {
	$.inverton = v
}
method quantonchanged(v) {
	$.quanton = v
}
# method autosavechanged(v) {
# 	$.autosave = v
# }
method restchanged(v) {
	$.rest = v	# 0 to 10
}


method outportchanged (v,n) {
	$.outport[n] = $.portvarr[v]
}

method keychanged(v) {
	$.key = v
}

method chanchanged(v,n) {
	$.outch[n] = v+1
	$.sendprogram(n)
}
method inchanchanged(v) {
	$.inch = v
}
method set(v,nm,n) {
	$.val[nm][n] = v
	if ( nm == "time" ) {
		dv = $.val["time"][n] - $.timesliderstepsperbeat
		$.time_tot[n] = 1.0 + float(dv) / $.timesliderstepsperbeat
		t="time\n"+sprintf("%.4f",(($.time_tot[n])))
	}
	else if ( nm == "trans" )
		t = "trans\n"+string($.val["trans"][n])
	else if ( nm == "vol" )
		t = "vol%\n"+string($.val["vol"][n])
	else if ( nm == "ntimes" )
		t = "ntimes\n"+string($.val["ntimes"][n])
	# set contents of text widget
	$.c["text_"+nm][n].set(t)
	$.c["slider_"+nm][n].set(v)
}
method sendprogram(n) {
	arr = patchmap_bynum_pmap($.progv[n],$.outch[n],$.pmap)
	$.realtime(arr["patch"],Now,n)
}
method consonoff {
	lock($)
	if ( $.constid < 0 ) {
		$.constid  = task $.task_cons()
	} else {
		kill($.constid)
		$.constid = -1
	}
	unlock($)
}
method gestureonoff(v) {
	lock($)
	$.gestureon = v
	if ( $.gestureon ) {
		gesturenotifyrc($,4,128)
	} else {
		gestureunnotify($)
	}
	unlock($)
}
method gotgesturerc(type,dev,finger,r,c) {
	# print("gesture type=",type," dev=",dev," finger=",finger," rc=",r,c)
	if ( $.gesturenotesdev < 0 ) {
		$.gesturenotesdev = dev
		print("Setting gesturenotesdev to ",dev)
	}
	if ( dev != $.gesturenotesdev ) {
		if ( $.gesturecontroldev < 0 ) {
			$.gesturecontroldev = dev
			print("Setting gesturecontroldev to ",dev)
		}
	}
	if ( dev == $.gesturenotesdev ) {
		q = $.row2quantval[r]
		if ( q != $.quant ) {
			$.quantbutt.setbyval($.quantnames[q],1)
			$.quantbutt.redraw()
		}

		nt = makenote(c)
		if ( type == "fingerdown" )
			nt.type = NOTEON
		else
			nt.type = NOTEOFF
		nt.time = Now
		put(Midiin[$],nt)
	} else if ( dev == $.gesturecontroldev ) {
		if ( r == 0 || r == 1) {
			# It's the key
			k = c/12
			$.keychanged(k)
			$.keybutt.set(k)
			$.keybutt.redraw(1)
			q = r / 4
		} else if ( r == 2 || r == 3 ) {
			# It's the scale
			sv = c/sizeof($.scales)
			$.scalechanged(sv)
			$.scalebutt.set(sv)
			$.scalebutt.redraw(1)
		}
	} else {
		print("gesture dev=",dev," is being ignored.")
	}
}
method on (doredraw) {

	lock($)
	$.setrealmerge()
	for ( n=0; n<4; n++ )
		$.sendprogram(n)

	$.tid = task $.task_echomidi()
	$.c["on"].set(1)
	if ( nargs() < 1 || doredraw!=0 )
		$.c["on"].redraw()
	unlock($)
}
method realtime(p,tm,n) {
	p.port = $.outport[n]
	realtime(p,tm)
}
method off {
	lock($)
	Merge = $.origmerge

	if ( $.tid < 0 )
		error("Hey, tid<0 in wecho4x_off!?")
	kill($.tid)
	$.tid = -1
	closemidi($)
	$.c["on"].set(0)
	$.c["on"].redraw()
	unlock($)
}
method setonoff (v,m) {
	if (v)
		$.on()
	else
		$.off()
}
method bang {
	if ( $.tid < 0 )
		$.on()
	else
		$.off()
}
method redraw {
	$.w.redraw()
	methodbroadcast()
}
method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)

	th = $.textheight()
	tw = $.textwidth()
	th2 = 2*th + 3
	x0 = $.xmin()+2
	x0a = x0 + 12*tw
	x0aa = x0 + 15*tw
	y0 = $.ymin()+2
	y0a = $.ymin()+2*th+2
	x1 = $.xmax()-1
	y2 = $.ymax()-2

	dy = y2-y0
	y0a = y0+th+6

	dy = $.textheight()+6
	if ( dy > ((y2-y0a)/14) ) {
		dy = ((y2-y0a)/14)
	}

	layout_horizontal(
		xy(x0,y0,x0aa,y0a-2),
		$.title,
		$.c["on"],
		$.c["conson"],
		$.c["gestureon"])
	layout_horizontal(
		xy(x0aa+2,y0,$.xmax()-2,y0a-2),
		$.patchtitle,
		$.patchbutt,
		$.patchsavebutt,
		$.patchnewbutt,
		$.patchrevertbutt)

	# $.patchtitle.resize(xy(x0a,y0,x0a+tw*5,y0a-2))
	# $.patchbutt.resize(xy(x0a+tw*5,y0,x0a+tw*10,y0a-2))
	# $.patchsavebutt.resize(xy(x0a+tw*10,y0,x0a+tw*15,y0a-2))

	layout_vertical(
		xy(x0,y0a,x0a-2,y2),
		# $.autosavebutt,
		$.inchanbutt,
		$.quantonbutt,
		$.quantbutt,
		$.remapbutt,
		$.keybutt,
		$.scalebutt,
		$.restbutt,
		$.invertonbutt,
		$.invertbutt,
		$.mergebutt
		)

	dx = $.xmax()-x0a
	x0a2 = x0a+dx/2
	x0a3 = $.xmax()-2

	dy2 = 3 * th + 4
	ymid = (y0a+$.ymax()-2)/2
	y0b = $.ymax() - dy2
	y0a2 = ymid - dy2

	layout_horizontal(
		xy(x0a,y0a,x0a2,y0a2-th2),
		$.c["slider_time"][0],
		$.c["slider_trans"][0],
		$.c["slider_vol"][0],
		$.c["slider_ntimes"][0])
	layout_horizontal(
		xy(x0a,y0a2-th2,x0a2,y0a2),
		$.c["text_time"][0],
		$.c["text_trans"][0],
		$.c["text_vol"][0],
		$.c["text_ntimes"][0])
	layout_vertical(
		xy(x0a,y0a2,x0a2,ymid),
		$.portbutt[0],
		$.outchanbutt[0],
		$.progbutt[0])

	layout_horizontal(
		xy(x0a2+2,y0a,x0a3,y0a2-th2),
		$.c["slider_time"][1],
		$.c["slider_trans"][1],
		$.c["slider_vol"][1],
		$.c["slider_ntimes"][1])
	layout_horizontal(
		xy(x0a2+2,y0a2-th2,x0a3,y0a2),
		$.c["text_time"][1],
		$.c["text_trans"][1],
		$.c["text_vol"][1],
		$.c["text_ntimes"][1])
	layout_vertical(
		xy(x0a2+2,y0a2,x0a3,ymid),
		$.portbutt[1],
		$.outchanbutt[1],
		$.progbutt[1])

	layout_horizontal(
		xy(x0a,ymid+2,x0a2,y0b-2-th2),
		$.c["slider_time"][2],
		$.c["slider_trans"][2],
		$.c["slider_vol"][2],
		$.c["slider_ntimes"][2])
	layout_horizontal(
		xy(x0a,y0b-2-th2,x0a2,y0b-2),
		$.c["text_time"][2],
		$.c["text_trans"][2],
		$.c["text_vol"][2],
		$.c["text_ntimes"][2])
	layout_vertical(
		xy(x0a,y0b-2,x0a2,$.ymax()-2),
		$.portbutt[2],
		$.outchanbutt[2],
		$.progbutt[2])

	layout_horizontal(
		xy(x0a2+2,ymid+2,x0a3,y0b-2-th2),
		$.c["slider_time"][3],
		$.c["slider_trans"][3],
		$.c["slider_vol"][3],
		$.c["slider_ntimes"][3])
	layout_horizontal(
		xy(x0a2+2,y0b-2-th2,x0a3,y0b-2),
		$.c["text_time"][3],
		$.c["text_trans"][3],
		$.c["text_vol"][3],
		$.c["text_ntimes"][3])
	layout_vertical(
		xy(x0a2+2,y0b-2,x0a3,$.ymax()-2),
		$.portbutt[3],
		$.outchanbutt[3],
		$.progbutt[3])

}
method delete {
	if ( $.constid >= 0 )
		$.consonoff()
	gestureunnotify($)
	closemidi($)
	Merge = $.origmerge
}
method dump {
	# if ( $.autosave )
	# 	$.patchsavecurrent()
	return([
		"ison" = ($.tid >= 0),
		"patch" = $.patchcurrent
		])
}
method restore(state) {
	nm = state["patch"]
	$.patchbutt.setbyval(nm)
	$.patchgoto(nm)
	$.redraw()

	if ( state["ison"] )
		$.on(0)

	# if ( ! "autosave" in state )
	# 	$.autosave = 0
	# else
	# 	$.autosave = state["autosave"]
	# $.autosavebutt.set($.autosave)


}
method patchgoto(nm) {

	$.patchcurrent = nm

	if ( ! (nm in $.patches) ) {
		print("Hey, nm=",nm," not in $.patches?")
		return()
	}
	arr = $.patches[nm]
	for ( i in arraylist("time","trans","vol","ntimes") ) {
		for ( n=0; n<4; n++ ) {
			$.set(arr[i][n],i,n)
		}
	}
	for ( n=0; n<4; n++ ) {
		$.outchanbutt[n].setbyval(arr["outch"][n],1)
		$.portbutt[n].setbyval(arr["port"][n],1)
		$.progbutt[n].setbyval(arr["prog"][n],1)
	}
	$.quantonbutt.setbyval(arr["quanton"],1)
	$.quantbutt.setbyval(arr["quant"],1)
	$.remapbutt.setbyval(arr["remap"],1)
	$.keybutt.setbyval(arr["key"],1)
	$.scalebutt.setbyval(arr["scale"],1)
	$.restbutt.setbyval(arr["rest"],1)
	$.invertonbutt.setbyval(arr["inverton"],1)
	$.invertbutt.setbyval(arr["invert"],1)
	$.mergebutt.setbyval(arr["merge"],1)
	$.inchanbutt.setbyval(arr["inch"],1)
}

method callback (v,valtype,n) {
	$.set(v,valtype,n)
	$.c["text_"+valtype][n].redraw()
}
method task_cons() {
	$.consfifo = Root.grabconsole()
	Consecho = 0
	onexit(global(domethod),$,"task_cons_finish")
	while ( 1 ) {
		c = get($.consfifo)
		if ( $ in Midiin ) {
			nt = '+a'
			nt.time = Now
			put(Midiin[$],nt)
			sleeptill(Now+1b/2)
			nt = '-a'
			nt.time = Now
			put(Midiin[$],nt)
		}
	}
}
method task_cons_finish {
	Consecho = 1
	Root.releaseconsole()
}
method task_echomidi() {
	Midiin[$] = f = open()
	laston = []
	while ( (nt=get(f)) != Eof ) {
	    # print("ECHOMIDI GOT nt=",nt)
	    if ( $.inch > 0 && $.inch != nt.chan )
			continue
	    orignt = nt
	    for ( t=0; t<4; t++ ) {
		nt = orignt
	        nt.chan = $.outch[t]
	        nt.port = $.outport[t]
		if ( $.merge==0 || $.merge==3 ) {
			if ( $.merge == 3 ) {
				# Adjust vol on very first note
				nt.vol = (nt.vol*$.val["vol"][t])/100
			}
			if ( $.remap ) {
				# When key or scale changes,
				# recompute list of allowed notes
				if ( $.currentkey != $.key
					|| $.currentscale != $.scale ) {
					$.scalenotes = allnotesin($.scale,$.key)
					$.currentkey = $.key
					$.currentscale = $.scale
				}
				nt = pitch_allowed_remap(nt,$.scalenotes)
			}
			if ( ( $.quanton != 0) && ($.quant != 0 ) ) {
				nt.time = nextquant(nt.time,$.quantvals[$.quant])
			}
			if ( nt.type == NOTEON ) {
				laston[nt.pitch] = nt.time
			} else if ( nt.type == NOTEOFF ) {
				if ( nt.pitch in laston ) {
					lasttm = laston[nt.pitch]
					if ( nt.time < lasttm ) {
						nt.time = lasttm
					}
					delete(laston[nt.pitch])
				}
			}
			tmpnt = nt
			if ( $.inverton ) {
				tmpnt.pitch = $.invert - (nt.pitch - $.invert)
			}
			$.realtime(tmpnt,0,t)
		}
		for ( n=$.val["ntimes"][t]; n>0; n-- ) {
			if ( nt.type & (NOTE|NOTEOFF|NOTEON) ) {
				nt.time += ($.time_tot[t] * 1b)
				if ( ( $.quanton != 0) && ($.quant != 0 ) ) {
					nt.time = nextquant(nt.time,$.quantvals[$.quant])
				}
				nt.pitch += $.val["trans"][t]
				nt.vol = (nt.vol*$.val["vol"][t])/100

				tmpnt = nt
				if ( $.remap ) {
					# When key or scale changes,
					# recompute list of allowed notes
					if ( $.currentkey != $.key
						|| $.currentscale != $.scale ) {
						$.scalenotes = allnotesin($.scale,$.key)
						$.currentkey = $.key
						$.currentscale = $.scale
					}
					tmpnt = pitch_allowed_remap(tmpnt,$.scalenotes)
					# print("remapped nt=",nt)
				}
				if ( $.rest > 0 && nt.type != NOTEOFF ) {
					if ( rand(100) < (10*$.rest) ) {
						continue
					}
				}
				# tmpnt = nt
				if ( $.inverton ) {
					tmpnt.pitch = $.invert - (nt.pitch - $.invert)
				}
				$.realtime(tmpnt,0,t)
				# print("realtime tmpnt=",tmpnt," t=",t)
			}
		}
	    }
	}
}
}

function wecho4x_outputs() {
	list = midi("output","list");
	names = []
	vals = []
	i = 0;
	old = Arraysort
	Arraysort = 1
	for ( n in list ) {
		if ( midi("output","isopen",n) ) {
			names[i] = list[n]
			vals[i] = n
			i++
		}
	}
	Arraysort = old
	if ( i == 0 ) {
		names[i] = "No outputs are open (use Port Enabler tool)"
		vals[i] = -1
		i++;
	}
	return( ["names" = names, "vals" = vals] )
}
