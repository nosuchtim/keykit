FakeLCD = 1

# Global parameters:
# Fading
# Tempo
# Keychanges
# LoopLength

class wmonolith {
method init {
	$.w = new window()
	$.inherit($.w)

	$.tid = -1
	$.nextstep_tm = Now

	$.default_noteset = [
		0=[0='ao1',1='bo1',2='co1',3='do1'],
		1=[0='ao2',1='bo2',2='co2',3='do2'],
		2=[0='ao3',1='bo3',2='co3',3='do3'],
		3=[0='ao4',1='bo4',2='co4',3='do4']
		]

	$.noteset = arraycopy($.default_noteset)

	$.current_noteset = 0

	$.vst_names = [
	    0=[
		0="Bass 1a",
		1="Bass 2a",
		2="Bass 3a",
		3="Bass 4a",
		4="Lead 1a",
		5="Lead 2a",
		6="Lead 3a",
		7="Lead 4a",
		8="Pad 1a",
		9="Pad 2a",
		10="Pad 3a",
		11="Pad 4a",
		12="Drum 1a",
		13="Drum 2a",
		14="Drum 3a",
		15="Drum 4a"
	    ],
	    1=[
		0="Bass 1b",
		1="Bass 2b",
		2="Bass 3b",
		3="Bass 4b",
		4="Lead 1b",
		5="Lead 2b",
		6="Lead 3b",
		7="Lead 4b",
		8="Pad 1b",
		9="Pad 2b",
		10="Pad 3b",
		11="Pad 4b",
		12="Drum 1b",
		13="Drum 2b",
		14="Drum 3b",
		15="Drum 4b"
	    ]
	]

	$.gamebutton_name = [
		"A4"="CLR",
		"A3"="LNG",
		"A2"="NXT",
		"A1"="DSP",
		"M4"="XXX",
		"M3"="ENT",
		"M2"="NXT",
		"M1"="BCK",
		"T4"="RFF",
		"T3"="SND",
		"T2"="NTS",
		"T1"="REC",
		"G1"="NTS",
		"G2"="RPT",
		"G3"="EF1",
		"G4"="EF1"
		]

	$.side_buttons = [
		"A4"=1,
		"A3"=1,
		"A2"=1,
		"A1"=1,
		"T4"=1,
		"T3"=1,
		"T2"=1,
		"T1"=1,
		"G1"=1,
		"G2"=1,
		"G3"=1,
		"G4"=1
		]

	$.track_vst = [
		0=[0=-1,1=-1,2=-1,3=-1],
		1=[0=-1,1=-1,2=-1,3=-1]
		]

	nplay = ["tid"=-1,"phr"='']
	$.track_currently_playing = [
		0=[0=nplay,1=nplay,2=nplay,3=nplay],
		1=[0=nplay,1=nplay,2=nplay,3=nplay]
		]

	$.track_currently_paddown = [
		0=[0=-1,1=-1,2=-1,3=-1],
		1=[0=-1,1=-1,2=-1,3=-1]
		]

	$.lcd_labels = [
		0=[0="one",1="two",2="three",3="four"],
		1=[0="oneB",1="twoB",2="threeB",3="fourB"]
		]

	$.reset_button_history()

	$.grab_next_note = [0=0,1=0]

	$.is_recording = [0=0,1=0]
	$.is_selectingsound = [0=0,1=0]
	$.is_selectingnotes = [0=0,1=0]
	$.is_selectingriff = [0=0,1=0]

	$.vst_enabled = []

	port1 = lookforandopen("output","Yoke.*1",0)
	port2 = lookforandopen("output","Yoke.*2",0)
	$.side_port = [0=port1,1=port2]

	for ( s=0; s<2; s++ ) {
		$.vst_enabled[s] = []
		for ( e=0; e<16; e++ ) {
			$.vst_enabled[s][e] = 0
		}
	}

	$.set_track_vst(0,0,3)
	$.set_track_vst(0,1,5)
	$.set_track_vst(0,2,10)
	$.set_track_vst(0,3,15)
	$.set_track_vst(1,0,2)
	$.set_track_vst(1,1,4)
	$.set_track_vst(1,2,9)
	$.set_track_vst(1,3,14)

	$.update_vst_enabled(0)
	$.update_vst_enabled(1)
	$.sendenabled()

	$.menus = [
		0=[
			0=["label"="Save ...","submenu"=1],
			1=["label"="Load ...","submenu"=2],
			2=["label"="Dummy1 ...","submenu"=3],
			3=["label"="Dummy2 ...","submenu"=4]
		],
		1=[
			0=["label"="Save Notes","cmd"="savenotes"],
			1=["label"="","cmd"=""],
			2=["label"="","cmd"=""],
			3=["label"="","cmd"=""]
		],
		2=[
			0=["label"="Menu 2.1","cmd"=""],
			1=["label"="Menu 2.2","cmd"=""],
			2=["label"="Menu 2.3","cmd"=""],
			3=["label"="Menu 2.4","cmd"=""]
		],
		3=[
			0=["label"="Menu 3.1","cmd"=""],
			1=["label"="Menu 3.2","cmd"=""],
			2=["label"="Menu 3.3","cmd"=""],
			3=["label"="Menu 3.4","cmd"=""]
		],
		4=[
			0=["label"="Menu 4.1","cmd"=""],
			1=["label"="Menu 4.2","cmd"=""],
			2=["label"="Menu 4.3","cmd"=""],
			3=["label"="Menu 4.4","cmd"=""]
		]
	]
	$.current_menu = 0
	$.current_menuitem = 0
	$.menu_history = []
	$.menu_history_level = -1

	$.c = []

	$.c["masterlcd"] = new ktext("LCD text\n12345678901234567890\n3\n4")
	$.c["masterlcd"].setjust("left")
	mnames = [1="BCK",2="NXT",3="ENT",4="XXX"]
	for ( n=1; n<=4; n++ ) {
		anm = "M" + string(n)
		nm = anm
		$.c[nm] = new kmoment(mnames[n],$,"gamebutton",anm,99)
	}

	for ( s=0; s<2; s++ ) {
		sn = string(s)
		anames = [1="DSP",2="NXT",3="LNG",4="CLR"]
		for ( n=1; n<=4; n++ ) {
			anm = "A" + string(n)
			nm = sn + anm
			$.c[nm] = new kmoment(anames[n],$,"gamebutton",anm,s)
		}
		tnames = [1="REC",2="NTS",3="SND",4="RFF"]
		gnames = [1="NTS",2="RPT",3="EF1",4="EF3"]
		for ( n=1; n<=4; n++ ) {
			anm = "T" + string(n)
			nm = sn + anm
			$.c[nm] = new kmoment(tnames[n],$,"gamebutton",anm,s)
			anm = "G" + string(n)
			nm = sn + anm
			$.c[nm] = new kmoment(gnames[n],$,"gamebutton",anm,s)
		}
		$.c[sn+"lcd"] = new ktext("LCD text\n12345678901234567890\n3\n4")
		gridname = sn + "grid"
		$.c[gridname] = new wgrid(4,4)
		$.c[gridname].setborder(1)
		$.c[gridname].setcallbackdown($,"fakegriddown",s)
		$.c[gridname].setcallbackup($,"fakegridup",s)
		gesturename = sn + "gesture"
		$.c[gesturename] = new wgrid(1,1)
		$.c[gesturename].setborder(1)
		$.c[gesturename].setcallbackdown($,"fakegesturedown",s)
	}

	for ( t in $.c )
		$.addchild($.c[t])

	$.miditid = task $.task_monolith_midi()
	$.joy = getjoymonitor()
	$.joy.notify($,-1)
	gesturenotify($)

	Offsetfilter = 0

	# tempo(500000)

	if ( ! defined(SalvationOutput) ) {
		SalvationOutput = -1
	}

	print("Setting dragthreshold to 0...")
	Gesturedragthreshold = 0.0
	GestureDraglimit = 60

	$.tid = -1
	$.defaultnsteps = 64
	$.defaultntracks = 4
	$.steptm = 1b/4
	$.nsteps = []
	$.ntracks = []
	$.currstep = []
	$.currtrack = []
	$.stepvals = []
	for ( s=0; s<2; s++ ) {
		$.nsteps[s] = $.defaultnsteps
		$.ntracks[s] = $.defaultntracks
		$.currstep[s] = 0
		$.currtrack[s] = 0
		$.stepvals[s] = []
		for ( n=0; n<$.nsteps[s]; n++ ) {
			$.stepvals[s][n] = []
			for ( t=0; t<$.ntracks[s]; t++ ) {
				$.stepvals[s][n][t] = ''
			}
		}
	}

	$.allupdatetracklabels()
	$.redrawlcds()
	$.redrawcurrentmenu()

	$.start()

	# t.waittilldone()
	# t.stop()
}

method reset_button_history() {
	$.button_history = []
	for ( s=0; s<2; s++ ) {
		$.button_history[s] = []
		for ( b in $.side_buttons ) {
			$.button_history[s] = [0=0,1=0,2=0]
		}
	}
}

method set_track_vst(s,trk,vstnum) {
	$.track_vst[s][trk] = vstnum
	# print("Setting track_vst s=",s," trk=",trk," to vstnum=",vstnum)
}

method vst_for_track(s,trk) {
	return($.track_vst[s][trk])
}

method update_vst_enabled(side) {
	# zero them all out
	for ( vstnum=0; vstnum<16; vstnum++ ) {
		$.vst_enabled[side][vstnum] = 0
	}
	# then enable the vsts used in each track
	for ( t=0; t<4; t++ ) {
		vstnum = $.track_vst[side][t]
		$.vst_enabled[side][vstnum] = 1
	}
}

method allupdatetracklabels {
	for ( s=0; s<2; s++ ) {
		$.updatetracklabels(s)
	}
}
method updatetracklabels(s) {
	for ( t=0; t<4; t++ ) {
		$.updatetracklabel(s,t)
	}
}

method updatetracklabel(s,t) {
	v = $.track_vst[s][t]
	if ( v < 0 ) {
		vn = "Empty"
	} else {
		vn = $.vst_names[s][v]
	}
	# print("v=",v," vn=",vn)
	nn = $.valsintrack(s,t)
	str = sprintf("Trk %d %d %8s ",t,nn,vn)
	$.lcd_labels[s][t] = str
}
method redrawcurrentindicator(s) {
	t = $.currtrack[s]
	# to avoid flashing real lcd, just update << part
	for ( r=0; r<4; r++ ) {
		if ( t == r ) {
			cs = "<<"
		} else {
			cs = "  "
		}
		mdep("lcd","write",s,cs,r,18)
	}
	$.redrawfakelcd(s)
}

method redrawlcds {
	for ( s=0; s<2; s++ ) {
		$.redrawlcd(s)
	}
}

method trackline(s,t) {
	c = $.currtrack[s]
	if ( c == t ) {
		cs = "<<"
	} else {
		cs = "  "
	}
	lbl = $.lcd_labels[s][t]+cs
	return(lbl)
}

method redrawlcd(s) {
	$.redrawreallcd(s)
	$.redrawfakelcd(s)
}

method redrawlcdtrack(s,trk) {
	$.redrawfakelcd(s)  # just redraw all of them
	$.redrawreallcdtrack(s,trk)
}

method redrawfakelcd(s) {
	if ( FakeLCD == 0 )
		return()
	t = $.c[string(s)+"lcd"]
	lbl = $.trackline(s,0)+"\n"
		+$.trackline(s,1)+"\n"
		+$.trackline(s,2)+"\n"
		+$.trackline(s,3)
	t.set(lbl)
	t.redraw()
}

method redrawcurrentmenu {
	if ( FakeLCD == 0 )
		return()
	t = $.c["masterlcd"]
	m = $.menus[$.current_menu]
	lbl = ""
	for ( r=0; r<4; r++ ) {
		s = m[r]["label"]
		if ( r == $.current_menuitem )
			arrow = "<<"
		else
			arrow = "  "
		lbl += sprintf("  %-15s %2s",s,arrow)
		if ( r<3 )
			lbl += "\n"
	}
	t.set(lbl)
	t.redraw()

	lcdnum = 2
	mdep("lcd","clear",lcdnum)
	mdep("lcd","backlight",lcdnum,0)
	for ( r=0; r<4; r++ ) {
		lbl = m[r]["label"]
		if ( r == $.current_menuitem )
			lbl += "<<"
		mdep("lcd","write",lcdnum,lbl,r,0)
	}
}

method redrawreallcd(s) {
	mdep("lcd","clear",s)
	mdep("lcd","backlight",s,0)
	for ( r=0; r<4; r++ ) {
		$.redrawreallcdtrack(s,r)
	}
}
method redrawreallcdtrack(s,trk) {
	mdep("lcd","write",s,$.trackline(s,trk),trk,0)
}

method delete {
	kill($.miditid)
	delete Midiin[$]
	$.joy.unnotify($,-1)
	gestureunnotify($)
	$.stop()
}

method sendenabled {
	for ( s=0; s<2; s++ ) {
		$.sendenabled_side(s)
	}
}

method sendenabled_side(side) {
	for ( vstnum=0; vstnum<16; vstnum++ ) {
		if ( $.vst_enabled[side][vstnum] == 0 ) {
			v = 40
		} else {
			v = 0
		}
		# print("Sending v=",v," for side=",side," vstnum=",vstnum)
		p = controller(1 + vstnum,111,v)
		p.port = $.side_port[side]
		$.realtime_now(p)
	}
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
	x00 = x0 = $.xmin()+2
	y00 = y0 = $.ymin()+2 + 5*th
	x01 = x1 = $.xmax()-2
	y01 = y1 = $.ymax()-2
	xmid = (x0+x1)/2
	ymid = (y00+y01)/2
	dx = (x1-x0) / 28
	dy = (y01-y00) / 24

	lcdx0 = xmid-11*tw
	lcdx1 = xmid+11*tw
	lcdy0 = $.ymin()+dy+4
	lcdy1 = $.ymin()+5*dy
	lcdym = (lcdy0+lcdy1)/2
	for ( n=1; n<=2; n++ ) {
		$.c["M"+string(n)].resize(xy(lcdx0-(3-n)*dx-2,lcdym-th,lcdx0-(2-n)*dx-2,lcdym+th))
	}
	for ( n=3; n<=4; n++ ) {
		$.c["M"+string(n)].resize(xy(lcdx1+(n-3)*dx+2,lcdym-th,lcdx1+(n-2)*dx+2,lcdym+th))
	}
	$.c["masterlcd"].resize(xy(lcdx0,lcdy0,lcdx1,lcdy1))

	for ( s=0; s<2; s++ ) {
		sn = string(s)
		if ( s == 0 ) {
			x0 = x00
			x1 = xmid-2
		} else {
			x0 = xmid+2
			x1 = x01
		}
		xm = (x0+x1)/2
		ym = (y0+y1)/2
		lcdx0 = xm-11*tw
		lcdx1 = xm+11*tw
		lcdy0 = y0+1*dy+4
		lcdy1 = y0+5*dy
		lcdym = (lcdy0+lcdy1)/2
		for ( n=1; n<=2; n++ ) {
			$.c[sn+"A"+string(n)].resize(xy(lcdx0-(3-n)*dx-2,lcdym-th,lcdx0-(2-n)*dx-2,lcdym+th))
		}
		for ( n=3; n<=4; n++ ) {
			$.c[sn+"A"+string(n)].resize(xy(lcdx1+(n-3)*dx+2,lcdym-th,lcdx1+(n-2)*dx+2,lcdym+th))
		}

		for ( n=1; n<=4; n++ ) {
			$.c[sn+"T"+string(n)].resize(xy(x0+4+(n-1)*dx,y1-2,x0+(n)*dx,y1-2-dy))
		}
		for ( n=1; n<=4; n++ ) {
			$.c[sn+"G"+string(n)].resize(xy(x1-(5-n)*dx,y1-2,x1-4-(4-n)*dx,y1-2-dy))
		}
		$.c[sn+"lcd"].resize(xy(lcdx0,y0+1*dy+4,lcdx1,y0+5*dy))
		$.c[sn+"grid"].resize(xy(x0+4,y0+7*dy+4,xm-4*tw,y1-4-dy))
		$.c[sn+"gesture"].resize(xy(xm+4*tw,y0+7*dy+4,x1-4,y1-4-dy))
	}

}
method dump {
	return([])
}
method restore(state) {
}

method noteset_fname(n) {
	return("noteset_"+string(n)+".mnn")
}
method savenotes() {
	fn = $.noteset_fname($.current_noteset)
	print("SAVENOTES called!  fn=",fn)
	f = open(fn,"w")
	for ( r=0; r<4; r++ ) {
		for ( c=0; c<4; c++ ) {
			ps = string($.noteset[r][c])
			put(f,sprintf("%d %d %s\n",r,c,ps))
		}
	}
	close(f)
}
method gamebutton(v,bnm,side) {

	nm = $.gamebutton_name[bnm]
	# print("gamebutton v=",v," bnm=",bnm," side=",side," nm=",nm)

	v = (v!=0)  # make sure it's 1 or 0

	if ( side == 99 ) {
		if ( v == 0 )
			return()
		# it's a master button
		print("Master button bnm=",bnm," nm=",nm)
		if ( nm == "BCK" ) {
			if ( $.menu_history_level >= 0 ) {
				$.menu_history_level--
				if ( $.menu_history_level < 0 )
					$.current_menu = 0
				else
					$.current_menu = $.menu_history[$.menu_history_level]
			}
			$.redrawcurrentmenu()
		} else if ( nm == "NXT" ) {
			while (1) {
				$.current_menuitem++
				if ( $.current_menuitem >= 4 )
					$.current_menuitem = 0
				if ( $.menus[$.current_menu][$.current_menuitem]["label"] != "" )
					break
			}
			$.redrawcurrentmenu()
		} else if ( nm == "ENT" ) {
			m = $.menus[$.current_menu][$.current_menuitem]
			print("m=",m)
			if ( "submenu" in m ) {
				$.menu_history_level++
				$.menu_history[$.menu_history_level] = $.current_menu
				$.current_menu = m["submenu"]
				$.redrawcurrentmenu()
			} else if ( "cmd" in m ) {
				cmd = m["cmd"]
				if ( cmd != "" )
					$.(cmd)()
			} else {
				print("No cmd or submenu !?")
			}
		}
		return()
	}

	if ( nm == "REC" ) {
		$.is_recording[side] = v
		# print("is_recording = ",$.is_recording)
	} else if ( nm == "NTS" ) {
		$.is_selectingnotes[side] = v
	} else if ( nm == "SND" ) {
		$.is_selectingsound[side] = v
	} else if ( nm == "RFF" ) {
		$.is_selectingriff[side] = v
	}

	if ( v == 0 )
		return()

	# It's a side button, down

	hist = $.button_history[side]
	hist[2] = hist[1]
	hist[1] = hist[0]
	hist[0] = Now

	# print("hist = ",hist)
	threeclicks = 0
	if ( (hist[0] - hist[2]) < milliclicks(1000) ) {
		threeclicks = 1
	}

	if ( nm == "NTS" && threeclicks ) {
		print("THREE CLICKS, now click on cell you want to set!")
		$.grab_next_note[side] = 1
		return()
	} else if ( nm == "CLR" ) {
		if ( threeclicks ) {
			for ( trk=0; trk<4; trk++ ) {
				$.clearonetrack(side,trk)
			}
		} else {
			$.clearonetrack(side,$.currtrack[side])
		}
	} else if ( nm == "NXT" ) {
		$.nexttrack(side)
		$.redrawcurrentindicator(side)
	}
}
method clearonetrack(side,trk) {
	# print("Clearing track=",trk," on side=",side)
	$.cleartrack(side,trk)
	$.updatetracklabel(side,trk)
	$.redrawlcdtrack(side,trk)
}
method buttonchange(jn,nm,v) {
	print("button change jn=",jn," nm=",nm," v=",v)
}
method analogchange(jn,nm,v) {
	print("analog change jn=",jn," nm=",nm," v=",v)
}
method fakegesturedown(m,v,s) {
	print("fakegesturedown m=",m," s=",s)
}
method chanfortrack(side,trk) {
	vstnum = $.vst_for_track(side,trk)
	return(1+vstnum)
}
method fakegriddown(m,vol,side) {
	col = m["col"]
	row = m["row"]
	trk = $.currtrack[side]

	# print("fakegriddown r/c=",row,"/",col," trk=",trk," vol=",vol," side=",side)
	# print("fakegriddown r/c=",row,"/",col," Now=",Now," nextstep_tm=",$.nextstep_tm)

	if ( $.grab_next_note[side] ) {
		$.grab_next_note[side] = 0
		p = lastbunch(Recorded,1b)
		p = strip(p)
		p.chan = $.chanfortrack(side,trk)
		$.noteset[row][col] = p

		# p.port = $.side_port[side]
		# $.realtime_now(p)

		print("Assigned ",row,"/",col," = ",p)
		return()
	}
	if ( $.is_selectingsound[side] ) {
		soundnum = row * 4 + col
		# print("Selecting sound = ",soundnum)

		$.set_track_vst(side,trk,soundnum)
		$.update_vst_enabled(side)
		$.sendenabled_side(side)

		$.updatetracklabel(side,trk)
		$.redrawlcdtrack(side,trk)
		$.sendenabled()
		return()
	}
	if ( $.is_selectingnotes[side] ) {
		ns = row * 4 + col
		$.current_noteset = ns
		fn = $.noteset_fname(ns)
		f = open(fn,"r")
		if ( f < 0 ) {
			print("No saved note set ",ns)
			$.noteset = arraycopy($.default_noteset)
		} else {
			while ( (ln=get(f)) != Eof ) {
				s1 = strindex(ln,"'")
				if ( s1 < 0 ) {
					print("Bad line: ",ln)
					continue
				}
				rc = substr(ln,1,s1-1)
				ph = substr(ln,s1)
				w = split(rc)
				r = integer(w[0])
				c = integer(w[1])
				$.noteset[r][c] = phrase(ph)
			}
			close(f)
			print("noteset = ",$.noteset)
		}
		return()
	}

	lock($)

	cstep = $.currstep[side]
	ns = $.step_after(side,cstep)
	# print("fakedown rc=",row,col," step=",cstep," ns=",ns)

	$.track_currently_paddown[side][trk] = ns
	# print("Setting paddown ns=",ns)

	if ( $.is_recording[side] ) {

		$.addtostep(ns,side,row,col,vol,NOTEON)

		# THIS SHOULD BE CHANGED TO JUST REDRAW NNOTES VALUE
		$.updatetracklabel(side,trk)
		$.redrawlcdtrack(side,trk)
	} else {
		# print("fakegrid calling noteon")
		$.track_noteon(side,trk,row,col,vol)
	}
	unlock($)
}
method fakegridup(m,v,side) {
	col = m["col"]
	row = m["row"]
	# print("fakegridup m=",m," v=",v," side=",side)

	if ( $.grab_next_note[side] ) {
		$.grab_next_note[side] = 0
		return()
	}
	if ( $.is_selectingsound[side] ) {
		return()
	}

	lock($)
	trk = $.currtrack[side]

	ntype = NOTEOFF

	nstep = $.nextstep(side)
	if ( $.track_currently_paddown[side][trk] == nstep ) {
		# nstep = $.step_after(side,nstep)
		# print("updown same step, NEW nstep=",nstep)
		# print("updown same step, setting ntype to NOTE")
		ntype = NOTE
	}

	$.track_currently_paddown[side][trk] = -1

	if ( $.is_recording[side] ) {
		$.addtostep(nstep,side,row,col,v,ntype)
	} else {
		$.track_noteoff(side,trk,row,col)
	}
	unlock($)
	# print("end fakegridup m=",m," v=",v," side=",side)
}
method track_noteon(side,trk,row,col,vol) {
	cplaying = $.track_currently_playing[side][trk]
	oldp = cplaying["phr"]
	if ( oldp != '' ) {
		# print("track_noteon, something already playing!  oldp=",oldp)
		# print("About to kill cplaying=",cplaying)
		kill(cplaying["tid"])
		oldp.type = NOTEOFF
		$.realtime_now1(oldp)
	} 
	p = $.noteset[row][col]
	p.chan = $.chanfortrack(side,trk)
	p.vol = vol
	p.port = $.side_port[side]
	p.type = NOTEON
	# print("track noteon p=",p)
	tid = $.realtime_nextstep(p)
	$.track_currently_playing[side][trk] = ["tid"=tid,"phr"=p]
}
method track_note(side,trk,row,col,vol) {
	cplaying = $.track_currently_playing[side][trk]
	oldp = cplaying["phr"]
	if ( oldp != '' ) {
		# print("track_note, something already playing!  oldp=",oldp)
		kill(cplaying["tid"])
		oldp.type = NOTEOFF
		$.realtime_now1(oldp)
	} 
	p = $.noteset[row][col]
	p.chan = $.chanfortrack(side,trk)
	p.vol = vol
	p.port = $.side_port[side]
	p.type = NOTE
	p.dur = $.steptm/2
	# print("track note! p=",p)
	$.realtime_nextstep(p)
	$.track_currently_playing[side][trk] = ["tid"=-1,"phr"='']
}
method track_noteoff(side,trk,row,col) {
	cplaying = $.track_currently_playing[side][trk]
	oldp = cplaying["phr"]
	# print("track noteoff trk=",trk," row/col=",row,"/",col," oldp=",oldp)
	if ( oldp == '' ) {
		# print("track_noteoff, wasn't playing?!  trk=",trk,"  Doing nothing...")
		return()
	} 

	oldp.type = NOTEOFF
	# print("track noteoff! oldp=",oldp)
	$.realtime_nextstep(oldp)
	$.track_currently_playing[side][trk] = ["tid"=-1,"phr"='']
}
method realtime_nextstep(p) {
	# print("realtime_nextstep p=",p," Now=",Now," nextstep_tm=",$.nextstep_tm," dt=",($.nextstep_tm - Now))
	return(realtime(p,$.nextstep_tm))
}
method realtime_now(p) {
	return(realtime(p))
}
method realtime_now1(p) {
	return(realtime(p,Now+1b/8))
}
method gotgesture(d) {
	print("gotgesture d=",d)
}
method gotgesturerc(type,dev,f,r,c,prox,rawx,rawy) {
	print("gotgesturerc ",type," dev=",dev," f=",f," prox=",prox," rc=",r,c," rawx=",rawx," rawy=",rawy)
}
method task_monolith_midi() {
	Midiin[$] = f = open()
	while ( (nt=get(f)) != Eof ) {
		side = 0
		nt.chan = $.chanfortrack(side,$.currtrack[side])
		nt.time = 0
		# print("monolith midi=",nt)
		nt.port = $.side_port[side]
		$.realtime_now(nt)
	}
}

method start() {
	$.savemerge = Merge
	Merge = 0
	if ( $.tid >= 0 ) {
		print("Can't start masterslooper twice!?")
		return()
	}
	$.keepgoing = 1
	$.tid = task $.playloop()
}
method stop() {
	kill($.tid)
	$.tid = -1
	Merge = $.savemerge

	a = ano()
	a.port = $.side_port[0]
	realtime(a)
	a.port = $.side_port[1]
	realtime(a)
}
method playloop() {
	$.nextstep_tm = nextquant(Now,1b)
	while ( $.keepgoing ) {
		lock($)
		for ( side=0; side<2; side++ ) {
			$.play_nextstep(side)
		}
		$.nextstep_tm += $.steptm
		unlock($)

		sleeptill($.nextstep_tm-4)
	}
}

method cleartrack(side,trk) {
	lock($)
	for ( n=0; n<$.nsteps[side]; n++ ) {
		$.stepvals[side][n][trk] = ''
	}
	ch = $.chanfortrack(side,$.currtrack[side])
	$.track_currently_playing[side][trk] = ["tid"=-1,"phr"='']
	unlock($)

	sleeptill(Now+$.steptm)
	p = ano(ch)
	p.port = $.side_port[side]
	$.realtime_now(p)
}

method nextstep(side) {
	return($.step_after(side,$.currstep[side]))
}

method step_after(side,s) {
	s++
	if ( s >= $.nsteps[side] )
		s = 0
	return(s)
}

method addtostep(cstep,side,row,col,velo,ntype) {

	# print("Addtostep step=",cstep," ntype=",ntype)
	trk = $.currtrack[side]

	p = makenote(row*4+col)
	p.vol = velo
	p.type = ntype
	$.stepvals[side][cstep][trk] = p

	# print("Added to step=",cstep," trk=",trk," p=",p," side=",side)
}

method play_nextstep(side) {
	r = ''
	ntrks = $.ntracks[side]

	$.currstep[side]++
	if ( $.currstep[side] >= $.nsteps[side] )
		$.currstep[side] = 0

	cstep = $.currstep[side]
	# print("Playing step=",cstep)
	for ( trk=0; trk<ntrks; trk++ ) {
		pdown = $.track_currently_paddown[side][trk]
		if ( pdown >= 0 && ( pdown != cstep || $.is_recording[side] == 0 )) {
			if ( $.is_recording[side] ) {
				# print("Pad down for trk=",trk," recording is on, clearing step! cstep=",cstep," pdown=",pdown)
				$.stepvals[side][cstep][trk] = ''
			} else {
				# print("Pad down for trk=",trk," ignoring step")
			}
			continue
		}
		p = $.stepvals[side][cstep][trk]
		if ( p != '' ) {
			# print("Playing in nextstep, pdown=",pdown," cstep=",cstep)
			# vstnum = $.vst_for_track(side,trk)
			ptch = p.pitch
			row = ptch / 4
			col = ptch % 4
			vol = p.vol
			if ( p.type == NOTEON )
				$.track_noteon(side,trk,row,col,vol)
			else if ( p.type == NOTEOFF )
				$.track_noteoff(side,trk,row,col,vol)
			else {
				# print("STEP ",cstep," has NOTE!")
				$.track_note(side,trk,row,col,vol)
			}
		}
	}
	return(r)
}
method valsintrack(s,t) {
	nnotes = 0
	ns = $.nsteps[s]
	for ( st=0; st<ns; st++ ) {
		sv = $.stepvals[s][st][t]
		if ( sv != '' && sv.type != NOTEOFF ) {
			nnotes++
		}
	}
	return(nnotes)
}
method nexttrack(s) {
	$.currtrack[s]++
	if ( $.currtrack[s] >= $.ntracks[s] )
		$.currtrack[s] = 0
}

}
