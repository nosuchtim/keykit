class wechox {
method init {
	$.w = new window()
	$.inherit($.w)

	$.origmerge = Merge
	$.merge = 1
	$.timestep = 1b/4
	$.tid = -1
	$.outport = 0
	$.outch = 1
	$.quant = 0
	$.key = 0
	$.invert = 0
	$.inverton = 0
	$.quanton = 0
	$.autosave = 1
	$.remap = 0
	$.rest = 0
	$.currentkey = -1
	$.currentscale = -1
	$.merge = 1
	$.inch = 0

	$.timeslidersteps = 100
	$.timesliderstepsperbeat = 16
	$.val_time = $.timesliderstepsperbeat
	$.val_trans = 0
	$.val_vol = 90
	$.val_ntimes = 1

	$.c = []
	$.c["slider_time"] = new kslider(0,$.timeslidersteps,$.val_time,
			$,"callback","time")
	$.c["slider_trans"] = new kslider(-12,12,$.val_trans,
			$,"callback","trans")
	$.c["slider_vol"] = new kslider(0,100,$.val_vol,
			$,"callback","vol")
	$.c["slider_ntimes"] = new kslider(0,16,$.val_ntimes,
			$,"callback","ntimes")
	$.c["on"] = new ktoggle("On",$,"setonoff")

	$.c["text_time"] = new ktext("")
	$.c["text_vol"] = new ktext("")
	$.c["text_ntimes"] = new ktext("")
	$.c["text_trans"] = new ktext("")
	for ( t in $.c )
		$.addchild($.c[t])

	# text (containing values) gets initialized
	for ( i in arraylist("time","trans","vol","ntimes") )
		$.set($.("val_"+i),i,0)

	# Channel button
	charr = []
	for ( n=1; n<=16; n++ )
		charr[n-1] = "Out "+string(n)
	$.outchanbutt = new kvalbutton(charr,$,"chanchanged")
	$.addchild($.outchanbutt)

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
	$.patchbutt.setbyval($.patchcurrent)

	$.patchnewbutt = new kbutton("New",$,"patchnew")
	$.addchild($.patchnewbutt)

	$.patchrevertbutt = new kbutton("Revert",$,"patchrevertcurrent")
	$.addchild($.patchrevertbutt)

	$.patchsavebutt = new kbutton("Save",$,"patchsavecurrent")
	$.addchild($.patchsavebutt)

	portarr = wechox_outputs()
	$.portvarr = portarr["vals"]
	$.portnarr = portarr["names"]
	$.portbutt = new kvalbutton($.portnarr,$,"outportchanged")
	$.addchild($.portbutt)

	$.getpnames()
	$.progbutt = new kvalbutton($.pnames,$,"progchanged",n)
	$.addchild($.progbutt)
	$.progbutt.setbyval("None")
	$.progv = 128

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

	$.autosavearr = [0="AutoSave Off",1="AutoSave On"]
	$.autosavebutt = new kvalbutton($.autosavearr,$,"autosavechanged")
	$.addchild($.autosavebutt)

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

	$.title = new ktext("EchoX")
	$.title.style(NOBORDER)
	$.title.setjust("left")
	$.addchild($.title)

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
		"outch" = "Out 1",
		"port" = 0,
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

	if ( $.autosave )
		$.patchsavecurrent()
	nm = $.patchnames[v]
	$.patchgoto(nm)
	$.redraw()
}
method currentarr() {
	return( [
		"time"= $.val_time,
		"trans"= $.val_trans,
		"vol"= $.val_vol,
		"ntimes"= $.val_ntimes,
		"outch" = $.outchanbutt.getvalue(),
		"port" = $.portbutt.getvalue(),
		"prog" = $.progbutt.getvalue(),
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

method progchanged(v) {
	$.progv = v
	$.sendprogram()
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
method autosavechanged(v) {
	$.autosave = v
}
method restchanged(v) {
	$.rest = v	# 0 to 10
}


method outportchanged (v,name) {
	$.outport = $.portvarr[v]
}

method keychanged(v) {
	$.key = v
}

method chanchanged(v) {
	$.outch = v+1
	$.sendprogram()
}
method inchanchanged(v) {
	$.inch = v
}
method set(v,nm,doslider) {
	$.("val_"+nm) = v
	if ( nm == "time" ) {
		dv = $.val_time - $.timesliderstepsperbeat
		$.time_tot = 1.0 + float(dv) / $.timesliderstepsperbeat
		t="time\n"+sprintf("%.4f",(($.time_tot)))
	}
	else if ( nm == "trans" )
		t = "trans\n"+string($.val_trans)
	else if ( nm == "vol" )
		t = "vol%\n"+string($.val_vol)
	else if ( nm == "ntimes" )
		t = "ntimes\n"+string($.val_ntimes)
	# set contents of text widget
	$.c["text_"+nm].set(t)
	$.c["slider_"+nm].set(v)
}
method sendprogram {
	arr = patchmap_bynum_pmap($.progv,$.outch,$.pmap)
	$.realtime(arr["patch"],Now)
}
method on (doredraw) {

	lock($)
	$.setrealmerge()
	$.sendprogram()

	$.tid = task $.task_echomidi()
	$.c["on"].set(1)
	if ( nargs() < 1 || doredraw!=0 )
		$.c["on"].redraw()
	unlock($)
}
method realtime(p,tm) {
	p.port = $.outport
	realtime(p,tm)
}
method off {
	lock($)
	Merge = $.origmerge

	if ( $.tid < 0 )
		error("Hey, tid<0 in wechox_off!?")
	kill($.tid)
	$.tid = -1
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
	x0 = $.xmin()+2
	x0a = x0 + 12*$.textwidth()
	y0 = $.ymin()+1
	y0a = $.ymin()+2*th+2
	x1 = $.xmax()-1
	y2 = $.ymax()-2
	dy = y2-y0
	if ( dy < (5*th) ) {
		y0a = y0 + dy/3
		y0b = y0 + 2*dy/3
	}
	else {
		y0a = y0+th+5
		y0b = $.ymax() - 2*th-5
	}
	dx = ($.xmax()-x0a) / 4
	dy = $.textheight()+6
	if ( dy > ((y2-y0a)/14) ) {
		dy = ((y2-y0a)/14)
	}

	$.title.resize(xy(x0,y0,x0a-2,y0a-2))
	layout_vertical(
		xy(x0,y0a,x0a-2,y2),
		$.patchbutt,
		$.patchrevertbutt,
		$.patchnewbutt,
		$.patchsavebutt,
		$.autosavebutt,
		$.inchanbutt,
		$.outchanbutt,
		$.portbutt,
		$.progbutt,
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

	$.c["slider_time"].resize(xy(x0a,y0a,x0a+dx,y0b-2))
	$.c["slider_trans"].resize(xy(x0a+2+dx,y0a,x0a+2*dx-1,y0b-2))
	$.c["slider_vol"].resize(xy(x0a+1+2*dx,y0a,x0a+3*dx-1,y0b-2))
	$.c["slider_ntimes"].resize(xy(x0a+1+3*dx,y0a,x1-1,y0b-2))
	$.c["on"].resize(xy(x0a,y0+1,x1-1,y0a-2))

	$.c["text_time"].resize(xy(x0a,y0b,x0a+dx,y2))
	$.c["text_trans"].resize(xy(x0a+2+dx,y0b,x0a+2*dx-1,y2))
	$.c["text_vol"].resize(xy(x0a+1+2*dx,y0b,x0a+3*dx-1,y2))
	$.c["text_ntimes"].resize(xy(x0a+1+3*dx,y0b,$.xmax()-2,y2))
}
method delete {
	delete Midiin[$]
	Merge = $.origmerge
}
method dump {
	if ( $.autosave )
		$.patchsavecurrent()
	return([
		"ison" = ($.tid >= 0),
		"autosave" = $.autosave,
		"patch" = $.patchcurrent
		])
}
method restore(state) {
	for ( i in arraylist("time","trans","vol","ntimes") ) {
		$.set(state[i],i,1)
		$.c["slider_"+i].set(state[i])
	}
	nm = state["patch"]
	$.patchbutt.setbyval(nm)
	$.patchgoto(nm)
	$.redraw()

	if ( state["ison"] )
		$.on(0)

	if ( ! "autosave" in state )
		$.autosave = 0
	else
		$.autosave = state["autosave"]
	$.autosavebutt.set($.autosave)


}
method patchgoto(nm) {

	$.patchcurrent = nm

	if ( ! (nm in $.patches) ) {
		print("Hey, nm=",nm," not in $.patches?")
		return()
	}
	arr = $.patches[nm]
	for ( i in arraylist("time","trans","vol","ntimes") ) {
		$.set(arr[i],i,1)
	}
	$.outchanbutt.setbyval(arr["outch"],1)
	$.portbutt.setbyval(arr["port"],1)
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
	$.progbutt.setbyval(arr["prog"],1)
}

method callback (v,valtype) {
	$.set(v,valtype)
	$.c["text_"+valtype].redraw()
}
method task_echomidi() {
	Midiin[$] = f = open()
	laston = []
	while ( (nt=get(f)) != Eof ) {
		if ( $.inch > 0 && $.inch != nt.chan )
			continue
		nt.chan = $.outch
		nt.port = $.outport
		if ( $.merge==0 || $.merge==3 ) {
			if ( $.merge == 3 ) {
				# Adjust vol on very first note
				nt.vol = (nt.vol*$.val_vol)/100
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
			$.realtime(tmpnt,0)
		}
		for ( n=$.val_ntimes; n>0; n-- ) {
			if ( nt.type & (NOTE|NOTEOFF|NOTEON) ) {
				nt.time += ($.time_tot * 1b)
				if ( ( $.quanton != 0) && ($.quant != 0 ) ) {
					nt.time = nextquant(nt.time,$.quantvals[$.quant])
				}
				nt.pitch += $.val_trans
				nt.vol = (nt.vol*$.val_vol)/100

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
				if ( $.rest > 0 && nt.type != NOTEOFF ) {
					if ( rand(100) < (10*$.rest) ) {
						continue
					}
				}
				tmpnt = nt
				if ( $.inverton ) {
					tmpnt.pitch = $.invert - (nt.pitch - $.invert)
				}
				$.realtime(tmpnt,0)
			}
		}
	}
}
}

function wechox_outputs() {
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
