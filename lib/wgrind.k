INCDEC_MID = 0
INCDEC_MIN = -2
INCDEC_MAX = 2
INCDEC_INC = 1
INCDEC_DEC = -1

Grindochords = [0="sus",1="min7",2="major",3="minor"]

class wgrind {

method init() {

	$.w = new window()
	$.inherit($.w)

	$.nopatches = []

	$.pmap = []
	$.pnames = []

	defouts = midi("portmap")[0]
	outnames = midi("output","list")
	for ( n=1; n<=10; n++ ) {
		out = defouts[n]
		if ( out in Port2Patchmap )
			$.pmap[n] = Port2Patchmap[out]
		else
			$.pmap[n] = patchmap_gm()
		$.pnames[n] = patchmapnames($.pmap[n])
	}

	$.grindo = []

	arr = []
	for ( n=0; n<16; n++ )
		arr[n] = string(n+1)
	$.b0 = new kbutton("Resync",$,"resync")
	$.b2 = new kmenubutton("More","mkmenu_grind1",$)
	$.buttonoff = new ktoggle("On",$,"onoff")
	$.buttcons = new ktoggle("Cn",$,"consonoff")
	$.nsliders = 2
	$.slidernames = [
		0 = "Vol",
		1 = "Rev",
		2 = "Cho"
		]
	$.slidertypes = [
		0 = "V",
		1 = "R",
		2 = "C"
		]
	$.slidertype = []
	for ( n=0; n<$.nsliders; n++ ) {
		$.slidertype[n] = new kvalbutton($.slidernames,$,"slidertypechanged",n)
		$.addchild($.slidertype[n])
		$.slidertype[n].set(n)
	}

	$.addchild($.b0)
	$.addchild($.b2)
	$.addchild($.buttonoff)
	$.addchild($.buttcons)
	$.sleeptime = 2b

	$.startquant = 1
	$.stoptids = []
	$.ph = []
	$.uph = []
	$.patchbutt = []
	$.speedof = []
	$.label = []
	$.speedmax = 4b
	$.randbutt = []
	$.slider = []
	$.mutebutt = []
	$.solobutt = []
	$.lastdone = -1
	$.sweepinc = 2

	$.ntracks = 0
	$.foffset = 0

	$.setntracks(10)
	$.buttonoff.set(0)
	$.buttcons.set(0)

	$.constid = -1
	$.realtid = -1
	$.miditid = -1
	$.flashtid = -1
	$.isplaying = 0

	$.grindo_start()

	for ( bn=1; bn<=$.ntracks; bn++ ) {
		# $.ph[bn].set('')
		$.ph[bn].redraw()
	}

	$.currlength = 0
	$.setlength(48b)
	$.setallmute(0)
	$.hightrk = -1
	$.sethigh(1)
}

method mousedown (m) {
	for ( bn=1; bn<=$.ntracks; bn++ ) {
		if ( $.ph[bn].contains(m) ) {
			$.setcurrchan(bn)
			return()
		}
	}
	mouseforward(m,"mousedown")
}
method sethigh(i) {
	if ( $.hightrk > 0 )
		$.drawhigh($.hightrk,CLEAR)
	$.hightrk = i
	$.drawhigh(i,STORE)
}

method drawhigh(i,mode) {
	x = $.ph[i].size()
	x["x0"]--
	x["y0"]--
	x["x1"]++
	x["y1"]++
	$.rectangle(x,mode)
}

method consonoff (v) {
	if ( v > 0 ) {
		$.startconsmidi()
	} else {
		$.cleanupconsmidi()
	}
}
method setallmute(v) {
	for ( bn=1; bn<=$.ntracks; bn++ ) {
		$.mutebutt[bn].set(v)
		$.mutebutt[bn].redraw()
	}
}
method delete() {
	for ( ch=1; ch<=$.nchans; ch++ ) {
		$.ph[ch].stop()
	}
	kill($.realtid)
	kill($.flashtid)

	$.cleanupconsmidi()
}

method startconsmidi() {
	$.consfifo = Root.grabconsole()
	Consecho = 0
	Consupdown = 1
	$.constid = task $.consoletask()
	$.miditid = task $.miditask()
	Merge = 0
}

method cleanupconsmidi() {
	if ( $.constid >= 0 )
		kill($.constid)
	if ( $.miditid >= 0 )
		kill($.miditid)
	Consupdown = 0
	Consecho = 1
	Root.releaseconsole()
	Merge = 1

	$.constid = -1
	$.miditid = -1
}

method edittrack(trk,p) {
	if ( trk<=0 || trk > $.ntracks ) {
		print("Can't set track ",trk)
		return()
	}
	$.ph[trk].killflashnotes()
	nun = sizeof($.uph[trk])
	$.uph[trk][nun] = $.ph[trk].get()
	$.settrack(trk,p)
}
method settrack(trk,p,dodraw) {
	if ( nargs() < 3 )
		dodraw = 1
	$.ph[trk].set(p)
	$.ph[trk].fitvert()
	if ( dodraw )
		$.ph[trk].redraw()
}
method onoff(v) {
	if ( nargs() == 0 ) {
		if ( $.isplaying )
			v = 0
		else
			v = 1
	}
	if ( v )
		$.play()
	else
		$.stop()
}
method setstartquant (v) {
	$.startquant = v
}
method setrecquant (v) {
	$.recquant = v
}
method play (bn) {
	stime = Now     # so they all start in sync
	if ( $.startquant > 1 )
		stime = nextquant(stime,$.startquant)
	$.realtid = task $.realtimetask(stime)
	$.flashtid = task $.flashtask(stime)
	$.buttonoff.set(1)
	$.buttonoff.redraw()
	$.isplaying = 1
}

method realtimetask(stime,loopleng) {

	tm = stime
	checktime = 1b

	loopleng = $.currlength
	if ( loopleng <= 0) {
		print("Non-positive loop leng? ",loopleng)
		return()
	}

	for ( ;; ) {
		# sleeptill(tm-1b/4)
		sleeptill(tm)

		# There's a loop playing

		# Keep track of when each loop starts,
		# so we know how to record new stuff
		$.loopstart = tm

		# See if any solo buttons are set
		anysolo = 0
		for ( i=1; i<=$.ntracks; i++ ) {
			if ( $.solobutt[i].get() == 1 ) {
				anysolo = 1
				break
			}
		}
		for ( i=1; i<=$.ntracks; i++ ) {
			if ( anysolo ) {
				if ( $.solobutt[i].get() ) {
					$.ph[i].play(tm,1,0,0)
				}
			} else {
				if ( $.mutebutt[i].get() == 0 ) {
					$.ph[i].play(tm,1,0,0)
				}
			}
		}
		tm += loopleng

		# Don't really need this loop until we
		# start to allow interrupting it, do we?
		while ( (Now+checktime) < (tm-2) ) {
			sleeptill(Now+checktime)
		}
	}
}

method miditask() {

	Midiin[$] = f = open()
	onexit(closemidi,$)

	last = []
	while ( (n=get(f)) != Eof ) {

		# Don't map volume controller messages
		if ( n.type == CONTROLLER && subbytes(n,2,1) == 7 ) {
			n.port = 0
			realtime(n,0)
			continue
		}
		n.chan = $.currchan
		n.port = 0
		realtime(n,0)
		if ( $.shiftisdown ) {
			# record it
			if ( n.type == NOTEON ) {
				last[n.pitch] = n.time
			} else if ( n.type == NOTEOFF ) {
				if ( ! ( n.pitch in last ) ) {
					print("Hey, n.pitch=",n.pitch," is not in last, last=",last)
				} else {
					nw = n.time
					n.type = NOTE
					n.time = 0
					n.port = 0
					$.recordnoteoff(last[n.pitch],nw,n)
				}
			} else if ( n.type == CHANPRESSURE ) {
			} else if ( n.type == CONTROLLER ) {
			} else if ( n.type == CONTROLLER ) {
			} else {
			}
		}
	}
}

method clearallflash() {
	$.fillrectangle(xy($.phx0,$.y0+2,$.phx1,$.ym1-2),CLEAR)
}

method flashtask(stime){

	tm = stime

	onexit(global(domethod),$,"clearallflash")
	loopleng = $.currlength

	nsteps = loopleng / 1b

	fy0 = $.y0+2
	fy1 = $.ym1-2
	dx = ($.phx1 - $.phx0) / nsteps
	for ( ;; ) {
		sleeptill(tm)

		fx0 = $.phx0
		fx1 = fx0 + dx

		for ( n=0; n<nsteps; n++ ) {
			$.fillrectangle(xy(fx0,fy0,fx1,fy1),STORE)
			tm += 1b
			sleeptill(tm)
			$.fillrectangle(xy(fx0,fy0,fx1,fy1),CLEAR)
			fx0 = fx1
			fx1 = fx0 + dx
		}
	}
}

method stop {
	# but don't kill console or midi tasks
	for ( i=1; i<=$.ntracks; i++ )
		$.ph[i].stop()
	kill($.realtid)
	kill($.flashtid)
	$.realtid = -1
	$.flashtid = -1
	$.buttonoff.set(0)
	$.buttonoff.redraw()
	$.isplaying = 0
}

method resync() {
	$.stop()
	$.play()
}
method dump {
	st = []
	st["ph"] = []
	st["patchbutt"] = []
	st["slider"] = []
	for ( n=1; n<=$.ntracks; n++ ) {
		st["ph"][n] = $.ph[n].get()
		st["patchbutt"][n] = $.patchbutt[n].get()
		st["slider"][n] = []
		for ( k=0; k<$.nsliders; k++ ) {
			st["slider"][n][k] = $.slider[n][k].get()
		}
	}
	return ( st )
}
method restore (state) {
	$.setntracks(sizeof(state["ph"]))
	$.resize()
	for ( n in state["ph"] ) {
		d = state["ph"][n]
		$.ph[n].set(d)
		bn = state["patchbutt"][n]
		$.patchbutt[n].set(bn)
		$.patchvalchanged(bn,n)
		for ( k=0; k<$.nsliders; k++ ) {
			$.slider[n][k].set(state["slider"][n][k])
		}
	}
	$.redraw()
}
method nbchanged (n) {
	$.setntracks(n)
	$.resize()
	$.redraw()
}

method randpatch(n) {
	if ( n == 10 ) {
		arr = patchmap_drums_rand($.currchan)
	} else {
		arr = patchmap_rand_real($.currchan,$.pmap[$.currchan])
	}
	$.sendpatch(arr)
	$.setpatch($.currchan,arr,1)
}

method setpatch(ch,arr,setbutton) {
	$.tp["sound"][ch] = arraycopy(arr)
	if ( setbutton ) {
		# Find the name in the kvalbutton and set it
		$.patchbutt[ch].setbyval(arr["name"])
		$.patchbutt[ch].redraw()
	}
}

method patchvalchanged(bn,trk) {
	# print("patchvalchanged bn=",bn," trk=",trk)
	arr = patch_lookup($.pnames[trk][bn],trk,$.pmap[trk])
	# print("arr=",arr)
	if ( arr == [] || arr == 0 ) {
		print("Unable to find patch=",$.pnames[trk][bn]," bn=",bn)
	} else {
		$.sendpatch(arr)
		$.setpatch(trk,arr,0)
	}
}

method setntracks (needed) {
	if ( needed < 0 )
		error("Bad needed value ("+string(needed)+") in setntracks")
	while ( needed > $.ntracks ) {
		# The index values in all the arrays (for tracks)
		# is the channel number, i.e. it starts at 1
		trk = 1 + $.ntracks

		$.ph[trk] = new wphrase()
		$.uph[trk] = []
		$.addchild($.ph[trk])

		$.patchbutt[trk] = new kvalbutton($.pnames[trk],$,"patchvalchanged",trk)
		$.addchild($.patchbutt[trk])
		$.patchbutt[trk].setbyval("None")

		$.label[trk] = new ktext(string(trk))
		$.addchild($.label[trk])

		$.speedof[trk] = $.speedmax/2

		$.randbutt[trk] = new kbutton("Rand",$,"randpatch",trk)
		$.addchild($.randbutt[trk])

		$.slider[trk] = []
		for ( n=0; n<$.nsliders; n++ ) {
			$.slider[trk][n] = new kslider(0,127,80,$,"sliderchanged",n,trk)
			$.addchild($.slider[trk][n])
		}

		$.mutebutt[trk] = new ktoggle("M")
		$.addchild($.mutebutt[trk])
		$.solobutt[trk] = new ktoggle("S")
		$.addchild($.solobutt[trk])

		$.ntracks++
	}
	while ( needed < $.ntracks ) {
		trk = $.ntracks - 1
		$.removechild($.ph[trk]) ; deleteobject($.ph[trk])
		$.removechild($.patchbutt[trk]) ; deleteobject($.patchbutt[trk])
		$.removechild($.label[trk]) ; deleteobject($.label[trk])
		$.removechild($.randbutt[trk]) ; deleteobject($.randbutt[trk])
		for ( n=0; n<$.nsliders; n++ ) {
			$.removechild($.slider[trk][n]) ; deleteobject($.slider[trk][n])
		}
		$.removechild($.mutebutt[trk]) ; deleteobject($.mutebutt[trk])
		$.removechild($.solobutt[trk]) ; deleteobject($.solobutt[trk])
		$.ntracks--
	}
}

method slidertypechanged(v,sn,ch) {
	print("slidertypechanged v=",v," sn=",sn)
}

method sliderchanged(v,sn,ch) {
	stn = $.slidertype[sn].get()
	if ( ! ( stn in $.slidertypes ) ) {
		print("stn=",stn," not in slidertypes?")
		return()
	}
	st = $.slidertypes[stn]
	if ( st == "V" ) {
		$.grindo_set_controller(v,Grindocontrollerletters["V"],ch)
	} else if ( st == "R" ) {
		$.grindo_set_controller(v,Grindocontrollerletters["R"],ch)
	} else if ( st == "C" ) {
		$.grindo_set_controller(v,Grindocontrollerletters["C"],ch)
	}
}

method gettrk(trk) {
	p = $.ph[trk].get()
	p.length = $.currlength
	return(p)
}

method get {
	r = ''
	rc = ''
	for ( trk=1; trk<=$.ntracks; trk++ ) {
		p = $.gettrk(trk)
		if ( p != '' )
			r |= p
		# Even if the phrase is blank, keep going and get patches, etc.
		if ( trk in $.nopatches )
			continue
		# for ( ctlr in Grindocontrollers ) {
		# 	rc |= controller(trk,ctlr,$.tp["ctlr"][trk][ctlr])
		# }
		if ( trk in $.tp["sound"] ) {
			rc |= $.tp["sound"][trk]["patch"]
		}
		if ( trk in $.tp["pan"] ) {
			rc |= pannote(trk,$.tp["pan"][trk])
		}
	}
	rc |= r
	rc.length = $.currlength
	return(rc)
}

method sendpatches {
	rc = ''
	for ( trk=1; trk<=$.ntracks; trk++ ) {
		# Even if the phrase is blank, keep going and get patches, etc.
		if ( trk in $.nopatches )
			continue
		if ( trk in $.tp["sound"] ) {
print("Sending patch trk=",trk)
			$.sendpatch($.tp["sound"][trk])
		}
	}
}

method set(ph) {
	for ( trk=1; trk<=$.ntracks; trk++ ) {
		q = ph{??.chan == trk}
		$.settrack(trk,q)

		# Look for program changes
		if ( ! defined(Patchunmap) )
			continue
		pnts = nonnotes(q)

		for ( n in pnts ) {
			# See is n is a patch message
			arr = Patchunmap(n,trk)
			if ( arr == 0 )
				continue
			if ( sizeof(arr) == 0 )
				continue
			p = patchmap_phrase(arr,trk)
			if ( p != '' ) {
				a = ["patch"=p,"name"=arr["name"]]
				$.setpatch(trk,a,1)
			} else {
				print("Couldn't find phrase for arr=",arr)
			}
		}
	}

}

method setlength (len,repit) {
	oldlen = $.currlength
	$.currlength = len
	if ( nargs() < 2 )
		repit = 1
	for ( bn=1; bn<=$.ntracks; bn++ ) {
		if ( repit ) {
			p = $.ph[bn].get()
			if ( p != '' ) {
				p.length = oldlen
				p = repleng(p,len)
				p = $.ph[bn].set(p)
			}
		}
		$.ph[bn].viewset(["x0"=0,"x1"=len],"x","no")
		$.ph[bn].fitvert()
		$.ph[bn].redraw()
	}
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	$.y0 = $.ymin()+2
	$.y1 = $.ymax() - 2
	$.x0 = $.xmin() + 2
	$.x1 = $.xmax() - 2
	th = $.textheight()
	tw = $.textwidth()
	$.ym1 = $.ymin() + th + 5

	$.ym2 = $.ymin() + 2*th + 8

	dx = ($.x1-$.x0)/10
	$.xm1 = $.x0 + 4*dx
	$.xm1b = $.x0 + 5*dx
	$.xm2 = $.x0 + 9*dx

	# buttons at the top - the fit between $.xm2 and $.x1
	bdx = ($.x1 - $.xm2) / 4
	$.buttonoff.resize(xy($.xm2,$.y0,$.xm2+bdx-1,$.ym1-2))
	$.buttcons.resize(xy($.xm2+bdx+1,$.y0,$.xm2+2*bdx-1,$.ym1-2))
	$.b0.resize(xy($.xm2+2*bdx+1,$.y0,$.xm2+3*bdx-1,$.ym1-2))
	$.b2.resize(xy($.xm2+3*bdx+1,$.y0,$.x1,$.ym1-2))

	bw = tw*2
	prebw = tw*4
	ty1 = $.ym1

	# x dimensions of phrase area
	$.phx0 = $.xm1b + 2
	$.phx1 = $.xm2 - bw - 4

	sdx = ($.xm1b-$.xm1)/2
	for ( k=0; k<$.nsliders; k++ ) {
		$.slidertype[k].resize(xy($.xm1+1+k*sdx,$.y0,$.xm1+(k+1)*sdx,$.ym1-2))
	}

	for ( n=1; n<=$.ntracks; n++ ) {
		ty0 = ty1
		ty1 = $.ym1 + (((n)*($.y1-$.ym1))/$.ntracks)
		tymid = (ty0+ty1)/2

		# sweep left/right
		$.label[n].resize(xy($.x0,ty0+1,$.x0+tw*3-1,ty1-1))

		$.randbutt[n].resize(xy($.x0+prebw+1,ty0+1,$.x0+prebw+bw,ty1-1))
		$.patchbutt[n].resize(xy($.x0+prebw+bw+2,ty0+1,$.xm1-1,ty1-1))

		for ( k=0; k<$.nsliders; k++ ) {
			$.slider[n][k].resize(xy($.xm1+1+k*sdx,ty0+1,$.xm1+(k+1)*sdx,ty1-1))
		}

		# upbutton
		$.mutebutt[n].resize(xy($.xm2-bw,ty0+1,$.xm2,tymid-1))
		# downbutton
		$.solobutt[n].resize(xy($.xm2-bw,tymid+1,$.xm2,ty1-1))


		$.ph[n].resize(xy($.phx0,ty0+1,$.phx1,ty1-1))
	}
}

method redraw {
	$.w.redraw()
	$.textleft("Grinder",xy($.x0,$.y0,$.xm1,$.ym1))
	methodbroadcast();
	if ( $.hightrk > 0 )
		$.drawhigh($.hightrk,STORE)
}

method setcurrchan(cn) {
	$.currchan = cn
	$.sethigh(cn)
}

method consoletask()
{
	ignorenextup = 0
	ctrl = 0
	while ( $.quit == 0 ) {

		c = get($.consfifo)

		keydown = (substr(c,1,1) == "+" )
		c = substr(c,2)

		nw = prevquant(Now,$.recquant)
		if ( keydown ) {
			$.lastdown[c] = nw
		} else {
			if ( c == ignorenextup ) {
				ignorenextup = 0
				continue
			}
		}

		# Pressing ESC will get you out
		# if ( c == "ESC" ) {
		# 	# wait for ESC keyup
		# 	if ( keydown )
		# 		continue
		# 	else
		# 		break
		# }

		if ( c == "CTRL" ) {
			ctrl = keydown
			continue
		}

		if ( $.charproc != "" ) {
			if ( keydown ) {
				f = $.charproc
				$.(f)(c,nw)
				# The function might have changed the
				# function as a way to grab the next character
				# If so, leave it alone
				if ( $.charproc == f )
					$.charproc = ""
				ignorenextup = c
			}
			continue
		}

		if ( ctrl ) {
			if ( c == "SHIFT" ) {
				if ( keydown ) {
					if ( $.shiftisdown ) {
						print("NOT RECORDING")
						$.shiftisdown = 0
					} else {
						print("RECORDING")
						$.shiftisdown = 1
					}
				}
			}
			if ( c in GrindoCtrlImmediate ) {
				# Call it right away
				f = GrindoCtrlImmediate[c]
				$.(f)(0,nw)
			} else if ( c in GrindoCtrlList ) {
				# Call it afte we get the next character
				$.charproc = GrindoCtrlList[c]
			}
			ignorenextup = c
			continue
		}

		if ( c == "SHIFT" ) {
			$.shiftisdown = keydown
			continue
		}
		if ( c == "." ) {
			# We assume ">" is shift-.
			$.inc_is_down = keydown
			continue
		}
		if ( c == "," ) {
			# We assume "<" is shift-,
			$.dec_is_down = keydown
			continue
		}
		if ( c == "END" ) {
			if ( keydown ) {
				print("Sending all-notes-off...")
				realtime(ano())
			}
			continue
		}	
		if ( c == "SPACE" ) {
			if ( keydown ) {
				if ( $.isplaying )
					$.onoff(0)
				$.onoff(1)
			}
			continue
		}
		if ( c == "MINUS" ) {
			if ( keydown ) {
				for ( m in GrindoModeList ) {
					if ( "func" in GrindoModeList[m] ) {
						f = GrindoModeList[m]["func"]
						$.(f)(keydown,"STOP",nw)
					}
				}
			}
			continue
		}	
		if ( c in GrindoTnumbers ) {
			if ( keydown ) {
				cn = ascii(c) - ascii("0")
				if ( cn == 0 )
					cn = 10
				if ( cn > 0 && cn <= $.nchans ) {
					$.setcurrchan(cn)
				}
			}
			continue
		}
		if ( $.inc_is_down || $.dec_is_down ) {
			if ( ! keydown )
				continue
			if ( (c in IncDecList) ) {
				f = IncDecList[c]
				# If both < and > are down, we set it to middle
				if ( $.inc_is_down && $.dec_is_down ) {
					v = INCDEC_MID
				} else {
					if ( $.shiftisdown ) {
						if ( $.inc_is_down )
							v = INCDEC_MAX
						else
							v = INCDEC_MIN
					} else {
						if ( $.inc_is_down )
							v = INCDEC_INC
						else
							v = INCDEC_DEC
					}
				}
				$.(f)(v)
			}
			continue
		}
		# Otherwise, we pass the key to whatever the current func is
		f = $.tp["mode"][$.currchan]["func"]
		# f is the name of the method we want
		$.(f)(keydown,c,nw)

	}
}

method grindo_dump(fname) {
	f = open(fname,"w")
	put(f,"Grindo ="+string(Grindo))
	close(f)
}

method grindo_nextinscale(p,sc) {
	p.pitch++
	p1 = p
	while ( p.pitch < 127 ) {
		if ( p in sc )
			return(p)
		p.pitch++
	}
	return(p1)
}

method grindo_rescale(ch,tp,sc,nm) {
	$.scale = $.grindo_completescale(sc,nm)
	p0 = 'p28'
	for ( cp=1; ; cp++ ) {
		c = substr(GrindoKeyOrder,cp,1)
		if ( c == "" )
			break
		np0 = $.grindo_nextinscale(p0,$.scale)
		tp[ch][c] = makenote(np0,$.playquant,'a'.vol,ch)
		p0 = np0
	}
	# space bar is a rest
	tp[ch]["SPACE"] = 'r'
	tp[ch]["SPACE"].length = $.playquant
}

method grindo_readmid(ch,p,tp,ioffset) {

print("grindo_readmid ioffset=",ioffset)

	p = onlynotes(p)
	p = step(p,1b/4)
	p.chan = ch
	arr = split(p)
	i = ioffset
	for ( cp=1; ; cp++ ) {
		c = substr(GrindoKeyOrder,cp,1)
		if ( c == "" )
			break
		if ( ! ( i in arr ) )
			i = 0
		x = strip(arr[i])
		tp[ch][c] = x
		i++
	}
	# space bar is a rest
	tp[ch]["SPACE"] = 'r'
	tp[ch]["SPACE"].length = $.playquant
	return(i)
}

# Each thing assigned to a key gets a chord
method grindo_assign_bs(ch,tp) {
	for ( cp=1; ; cp++ ) {
		c = substr(GrindoKeyOrder,cp,1)
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
method grindo_assign_inversions(ch,tp) {
	for ( cp=1; ; cp++ ) {
		c = substr(GrindoKeyOrder,cp,1)
		if ( c == "" )
			break
		p = tp[ch][c]
		
		cn = Grindochords[rand(sizeof(Grindochords))]
		p2 = transpose(chordnamed(cn),p)
		p2 = scadjust(p2,makescale('c,e-,g,b-'))
		p2.chan = p.chan
		p2.vol = p.vol
		p2.dur = p.dur

		tp[ch][c] = p2
	}
}

# Each thing assigned to a key gets a chord
method grindo_assign_chord(ch,tp) {
	for ( cp=1; ; cp++ ) {
		c = substr(GrindoKeyOrder,cp,1)
		if ( c == "" )
			break
		p = tp[ch][c]
		
		cn = Grindochords[rand(sizeof(Grindochords))]
		p2 = transpose(chordnamed(cn),p)
		p2 = scadjust(p2,makescale('c,e,g'))
		p2.chan = p.chan
		p2.vol = p.vol
		p2.dur = p.dur

		tp[ch][c] = p2
	}
}

# Each thing assigned to a key gets an octave-transposed copy added
method grindo_assign_octaves(ch,tp) {
	for ( cp=1; ; cp++ ) {
		c = substr(GrindoKeyOrder,cp,1)
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
method grindo_assign_rand(ch,tp) {
	for ( cp=1; ; cp++ ) {
		c = substr(GrindoKeyOrder,cp,1)
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

method grindo_completescale(c,nm) {
	p = scalenamed(nm)
	cp = canonic(c)
	p.pitch += cp
	r = p
	while ( p.pitch < 116 ) {
		r |= p
		p.pitch += 12
	}
	return(r)
}

method grindo_apply_mods(p) {
	p.pitch += (12*$.tp["octshift"][$.currchan])
	p.vol += $.tp["velocity"][$.currchan]

	if ( $.currchan in $.tp["immediate"] ) {
		i = $.tp["immediate"][$.currchan]
		if ( i != "" ) {
			p = $.(i)(p)
		}
	}
	return(p)
}

method grindo_mode_looper(keydown,c,nw) {
	if ( c == "START" ) {
		$.tp["loopmute"][$.currchan] = 0
		return()
	}
	if ( c == "STOP" ) {
		$.settrack($.currchan,'')

		$.tp["loopmute"][$.currchan] = 1
		for ( ch=1; ch<=$.nchans; ch++ ) {
			$.ph[ch].stop()
		}
		return()
	}
	if ( keydown ) {
		# key just went down
		if ( c == "TAB" ) {
			$.tp["loopmute"][$.currchan] = 1 - $.tp["loopmute"][$.currchan]
			if ( $.tp["loopmute"][$.currchan] == 0 )
				$.ph[$.currchan].stop()
			return()
		}
		if ( c == "RETURN" ) {
			return()
		}
		# If shift is down, then we're recording, so we set
		# the start of the loop if it's not set already
		if ( $.shiftisdown && $.loopstart == 0 ) {
			$.loopstart = prevquant(nw,$.loopquant)
		}
		# When the key goes down, we just play it.
		# It doesn't get added to the loop until it's let up.
		if ( c in $.tp["phrase"][$.currchan] ) {
			p = $.tp["phrase"][$.currchan][c]
			p = $.grindo_apply_mods(p)
			p.type = NOTEON
			realtime(p,nw)
			return()
		}
	} else {
		# the key has just been let up
		if ( c == "BS" ) {
			# backspace clears the track
			$.edittrack($.currchan,'')
			$.ph[$.currchan].stop()
			return()
		}
		if ( c in $.tp["phrase"][$.currchan] ) {
			if ( ! ( c in $.lastdown ) ) {
				print("Hmm, c=",c," not in $.lastdown?")
				return()
			}
			lstdwn = $.lastdown[c]
			p = $.tp["phrase"][$.currchan][c]
			p = $.grindo_apply_mods(p)
			if ( ! $.shiftisdown ) {
				# p.time = 0
				p.type = NOTEOFF
				if ( nw == lstdwn ) {
					nw += $.playquant/2
				}
				realtime(p,nw)
				return()
			}

			# If shift is down, then we're recording
			$.recordnoteoff(lstdwn,nw,p)

			p.time = 0
			p.type = NOTEOFF
			realtime(p,nw)
			return()
		}
	}
}

method recordnoteoff(lstdwn,nw,p) {
	if ( lstdwn < $.loopstart ) {
		p.time = $.currlength - ($.loopstart - lstdwn)
		d = nw-lstdwn
		if ( d <= 0 )
			d = 1
		p.dur = d
	} else {
		p.time += nextquant(lstdwn - $.loopstart,$.recquant)
		d = nw-lstdwn
		if ( d <= 0 )
			d = 1
		p.dur = d
	}
	p.length = p.dur
	p2 = $.gettrk($.currchan) | p

	$.edittrack($.currchan,p2)
}

method grindo_repeater_task(p,nw,q) {
	while (1) {
		realtime(p,nw)
		nw += q
		sleeptill(nw-2)
	}
}

method grindo_mode_repeater(keydown,c,nw) {
	if ( ! defined(RepeaterTask) ) {
		RepeaterTask = []
	}
	if ( c == "START" ) {
		RepeaterTask = []
	}
	if ( c == "STOP" ) {
		for ( t in RepeaterTask ) {
			kill(RepeaterTask[t])
			delete(RepeaterTask[t])
		}
	}
	if ( c in $.tp["phrase"][$.currchan] ) {
		p = $.tp["phrase"][$.currchan][c]
		p = $.grindo_apply_mods(p)
		if ( keydown ) {
			p = step(p,$.playquant)
			RepeaterTask[c] = task $.grindo_repeater_task(p,nw,$.playquant)
		} else {
			if ( c in RepeaterTask ) {
				kill(RepeaterTask[c])
				delete(RepeaterTask[c])
			}
		}
		return()
	}
}

method grindo_ctrl_exec(c,nw) {
	if ( c == "Q" ) {
		$.quit = 1
	} else if ( c == "O" ) {
		$.buttonoff.bang()
	} else if ( c == "C" ) {
		$.buttcons.bang()
	} else if ( c == "T" ) {
	}
}

method grindo_ctrl_grabber(c,nw) {
	if ( c in $.tp["phrase"][$.currchan] ) {
		p = lastbunch(Recorded,1b)
		p = quantize(p,Grindograbquant)
		p = strip(p)
		if ( p == '' ) {
			print("Nothing in Recorded to grab...")
			return()
		}
		p.length = numquant(latest(p),Grindograbquant)
		# If all the notes are at the same time, assume it's
		# a note or chord, and fix the duration
		if ( p.time == 0 ) {
			p.dur = 1b
		}
		$.tp["phrase"][$.currchan][c] = p
		print("Character ",c," now plays ",sizeof(p)," notes.")
		return()
	}
}

method grindo_assign_write(p) {
	print("Write file with assignments...")
	fname = browsefiles("grinder files (*.gpa)","*.gpa",0)
	if ( fname != "" && ! ( fname ~~ ".gpa" ) ) {
		fname = fname + ".gpa"
	}
	if ( fname == "" ) {
		print("No file written");
	} else {
		f = open(fname,"w")
		if ( f < 0 ) {
			print("Can't open file: ",fname)
		}else {
			put(f,string(p))
			close(f)
			print("File ",fname," written.")
		}
	}
}

method grindo_assign_read() {
	print("Read file with assignments...")
	fname = browsefiles("grinder files (*.gpa)","*.gpa",0)
	if ( fname != "" && ! ( fname ~~ ".gpa" ) ) {
		fname = fname + ".gpa"
	}
	if ( fname == "" ) {
		print("No file read");
	} else {
		f = open(fname,"r")
		if ( f < 0 ) {
			print("Can't open file: ",fname)
		} else {
			a = get(f)
			eval ("Grindoph__="+a)
			close(f)
			print("File ",fname," read.")
			$.tp["phrase"] = arraycopy(Grindoph__)
		}
	}
}

method grindo_ctrl_ano(c,nw) {
	print("Sending all-notes-off...")
	realtime(ano())
}

method grindo_ctrl_scale(c,nw) {
	if ( c in GrindoScales ) {
		$.grindo_rescale($.currchan,$.tp["phrase"],'c',GrindoScales[c])
		print("Switching to scale: ",GrindoScales[c])
	} else {
		print("No such scale: ",c,"   Scales are:")
		for ( n in GrindoScales )
			print(n," - ",GrindoScales[n])
	}
}

method grindo_ctrl_assign(c,nw) {
	if ( c == "S" ) {
		$.charproc = "grindo_ctrl_scale"
	} else if ( c == "C" ) {
		$.grindo_assign_chord($.currchan,$.tp["phrase"])
	} else if ( c == "I" ) {
		$.grindo_assign_inversions($.currchan,$.tp["phrase"])
	} else if ( c == "B" ) {
		$.grindo_assign_bs($.currchan,$.tp["phrase"])
	} else if ( c == "P" ) {
		$.grindo_assign_rand($.currchan,$.tp["phrase"])
	} else if ( c == "R" ) {
		$.grindo_assign_read()
	} else if ( c == "W" ) {
		$.grindo_assign_write($.tp["phrase"])
	} else if ( c == "K" ) {
		# We Want to sent the next character to grindo_ctrl_scale
		$.charproc = "grindo_ctrl_scale"
	} else if ( c == "A" ) {
		# We Want to sent the next character to grindo_ctrl_assignall
		$.charproc = "grindo_ctrl_assignall"
	} else if ( c == "Y" ) {
		# We Want to sent the next character to grindo_ctrl_assigncopy
		$.charproc = "grindo_ctrl_assigncopy"
	} else {
		print("Unrecognized char - ",c)
	}
}

method grindo_ctrl_assignall(c,nw) {
	a = ascii(c) - ascii("0")
	if ( a >= 0 && a < 10 ) {
		print("Copying key assignments from channel ",a," to all chans")
		for ( ch=1; ch<=$.nchans; ch++ ) {
			if ( ch == c )
				continue
			$.tp["phrase"][ch] = arraycopy($.tp["phrase"][a])
			for ( i in $.tp["phrase"][ch] ) {
				tmp = $.tp["phrase"][ch]
				tmp[i].chan = ch
			}
		}
	}
}

method grindo_ctrl_assigncopy(c,nw) {
	a = ascii(c) - ascii("0")
	if ( a >= 0 && a < 10 ) {
		print("Copying key assignments from channel ",a," to chan ",$.currchan)
		if ( $.currchan != a ) {
			$.tp["phrase"][$.currchan] = arraycopy($.tp["phrase"][a])
			for ( i in $.tp["phrase"][$.currchan] ) {
				tmp = $.tp["phrase"][$.currchan]
				tmp[i].chan = $.currchan
			}
		}
	}
}

method grindo_ctrl_sound(c,nw) {

	if ( $.currchan in $.nopatches ) {
		print("No patch changes on channel ",$.currchan)
		return()
	}

	nm = ""
	arr = []
	if ( $.currchan == 10 ) {
		arr = patchmap_drums_rand($.currchan)
	} else if ( c == "A" ) {
		arr = patchmap_rand_real($.currchan,$.pmap[$.currchan])
	} else if ( c == "R" || c == "S" ) {
		# r = rand(sizeof(Grindopatches["all"]))
		# nm = Grindopatches["all"][r]
		print("ctrl_sound SS needs work")
		arr = patchmap_rand_real($.currchan,$.pmap[$.currchan])
	} else if ( c == "P" ) {
		nm = Grindopatches["pad"][rand(sizeof(Grindopatches["pad"]))]
	} else if ( c == "H" ) {
		nm = Grindopatches["hard"][rand(sizeof(Grindopatches["hard"]))]
	} else if ( c == "B" ) {
		nm = Grindopatches["bass"][rand(sizeof(Grindopatches["bass"]))]
	} else if ( c == "C" ) {
		nm = Grindopatches["perc"][rand(sizeof(Grindopatches["perc"]))]
	} else if ( c == "V" ) {
		nm = Grindopatches["vocal"][rand(sizeof(Grindopatches["vocal"]))]
	} else if ( c == "D" ) {
		nm = Grindopatches["drum"][rand(sizeof(Grindopatches["drum"]))]
	} else {
		print("Unrecognized char - ",c)
		return()
	}

	if ( nm != "" && sizeof(arr) == 0 ) {
		arr = patch_lookup(nm,$.currchan,$.pmap[$.currchan])
		if ( sizeof(arr) == 0 ) {
			print("Hmm, no patch named ",nm)
			return()
		}
	}
	if ( ! defined(arr) || ! ( "patch" in arr ) ) {
		print("Hmm, no value for arr in grindo_ctrl_sound ?  c=",c," nm=",nm)
		return()
	}
	$.sendpatch(arr)

	$.setpatch($.currchan,arr,1)
}

method sendpatch(arr) {
	p = arr["patch"]
	realtime(p)
}

method grindo_ctrl_mode(c,nw) {

	# Don't send stop - you must do that
	# explicitly with DEL, so loops will keep
	# going even if you switch modes

	if ( c in GrindoModeList ) {
		$.tp["mode"][$.currchan] = GrindoModeList[c]
		print("Switching to mode: ",$.tp["mode"][$.currchan]["name"])
		f = $.tp["mode"][$.currchan]["func"]
		$.(f)(1,"START",nw)
	} else {
		print("No such mode: ",c)
	}
}

method grindo_ctrl_pan(c,nw) {
	if ( c == "L" ) {
		v = 0
	} else if ( c == "R" ) {
		v = 127
	} else if ( c == "C" ) {
		v = 64
	}
	p = pannote($.currchan,v)
	realtime(p)
	$.tp["pan"][$.currchan] = v
}

method grindo_change_offset(o) {
	if ( o == Offsetpitch )
		return()
	print("Changing Offsetpitch to ",o)
	Offsetpitch = o
	realtime(ano())
}

method grindo_ctrl_offset(c,nw) {
	# The keys A-Z will map to offsets -12 to 12.
	a = ascii(c) - ascii("A")
	if ( a >= 0 && a < 26 ) {
		$.grindo_change_offset( -12 + a )
	}
}

method grindo_imm_echo(p) {
	p = echo(p,3,1b/4,0.85)
	return(p)
}

method grindo_imm_fract(p) {
	if ( sizeof($.lastfract) >= 3 ) {
		# It's 3 notes long, take off the first
		# one and append new one
		$.lastfract = strip(tail($.lastfract,2))
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
	p = scadjust(p,$.scale)
	return(p)
}

method shiftleftby(p,amount) {
	leng = p.length
	if ( amount > 0 ) {
		toleft = 1
		dir = 1
		mid = amount
	} else {
		toleft = 0
		dir = -1
		amount = -amount
		mid = leng-amount
	}
	for ( bn=1; bn<=$.ntracks; bn++ ) {
		p = $.gettrk(bn)
		p1 = cut(p,CUT_TIME,0,mid)
		p2 = cut(p,CUT_TIME,mid,leng)
		if ( dir > 0 ) {
			p1.time += (leng - amount)
			p2.time -= amount
		} else {
			p1.time += amount
			p2.time += (amount-leng)
		}
		p = p1 | p2
		$.edittrack(bn,p)
	}
}

method grindo_ctrl_edit(c,nw) {
	if ( c in GrindoEditMethods ) {
		e = GrindoEditMethods[c]
		p = $.gettrk($.currchan)
		p = $.(e)(p)
		p = cut(p,CUT_TIME,0,$.currlength)
		$.edittrack($.currchan,p)
	} else {
		print "Unknown edit character: c"
	}
}

method edit_quant(p) {
	return( quantize(p,1b/4) )
}
method edit_echo(p) {
	r = rand(6)
	if ( r == 0 ) {
		p = preecho(p,5,1b/8,0.8)
	} else if ( r == 1 ) {
		p = echo(p,3,1b/4,0.85)
	} else if ( r == 2 ) {
		p = echo(p,2,1b,1.0)
	} else if ( r == 3 ) {
		p = echo(p,4,1b/8,0.8)
	} else {
		p = echo(p,2,1b/2,1.0)
	}
	return(p)
}

method edit_comb(p) {
	return ( p{rand(2) == 0} )
}
method edit_arpeggio(p) {
	return ( arpeggio(p,1b/8) )
}
method edit_scale(p) {
	return ( scadjust(p,makescale(scalenamed("newage"))))
}
method edit_scale_grabbed(p) {
	sc = scale_last()
	p = scadjust(p,sc)
	return (p)
}

method edit_fractal(p) {

	# limit the size, to avoid huge phrases
	p = head(p,16)

	leng = $.currlength
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

	return(p)
}

method edit_ornament(p) {
	return ( $.edit_ornament_it(p,0) )
}
method edit_ornament_pleasing(p) {
	return ( $.edit_ornament_it(p,1) )
}

method edit_ornament_it(p,scaleit) {
	pk = Grindoornament[rand(sizeof(Grindoornament))]
	p = ornament(p,pk)
	if ( scaleit ) {
		p = scadjust(p,makescale(scalenamed("newage")))
	}
	return(p)
}

method edit_undo() {
	trk = $.currchan
	nun = sizeof($.uph[trk])
	if ( nun == 0 ) {
		print("Nothing more to undo in that track!")
		return()
	}
	p = $.uph[trk][nun-1]
	delete $.uph[trk][nun-1]
	$.ph[trk].set(p)
	$.ph[trk].fitvert()
	$.ph[trk].redraw()
}

# This one no longer works
method edit_strip(p) {
	if ( p == '' )
		return()
	nt = p%1
	space1 = nt.time
	if ( sizeof(p) <= 1 ) {
		space2 = MAXCLICKS
	} else {
		lastnt = tail(p,1)
		space2 = $.currlength - lastnt.time
	}
	if ( space1 < space2 ) {
		$.shiftleftby(space1)
	} else {
		$.shiftleftby(-space2)
	}
}

method grindo_ctrl_immediate(c,nw) {
	# Set the 'immediate' processor for played notes
	if ( c == "E" ) {
		$.tp["immediate"][$.currchan] = "grindo_imm_echo"
	} else if ( c == "F" ) {
		$.tp["immediate"][$.currchan] = "grindo_imm_fract"
	} else {
		print("Unknown Immediate character: ",c)
	}
}

method grindo_fractal_chan(ch) {
	leng = $.currlength
	p = $.ph[ch].get()
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
}

method grindo_spaces(p,leng) {
	if ( nargs() < 2 )
		leng = latest(p)
	for ( n=0; n<4; n++ ) {
		b1 = rand(leng-1b)
		p2 = cut(p,CUT_TIME,b1,b1+1b)
		p = p - p2
	}
	return(p)
}

method grindo_stutter(p) {
	p = stutterrand(p)
	return(p)
}
method grindo_chords(p) {
	q = p{ rand(2) == 0 }
	p -= q
	cn = Grindochords[rand(sizeof(Grindochords))]
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

method grindo_ctrl_drumpatt(c,nw) {
	# The keys 0-9 will map to patterns
	p = ''
	if ( c == "R" ) {
		p = bsgmdrum8()
	} else if ( c == "F" ) {
		p = bsgmdrum8()
		p = p{rand(5)==0||isnearbeat(??,1b,0)}
	} else if ( c == "G" ) {
		p = bsgmdrum8()
		p = p{rand(3)==0||isnearbeat(??,1b,0)}
	} else if ( c == "V" ) {
		p = bsgmdrum8()
		p = p{rand(5)==0||isnearbeat(??,1b/2,0)}
	} else if ( c == "B" ) {
		p = bsgmdrum8()
		p = p{rand(3)==0||isnearbeat(??,1b/2,0)}
	} else {
		if ( c in Grindodrumpatts ) {
			p = Grindodrumpatts[c]
		}
	}
	if ( p != '' ) {
		p = repleng(p,$.currlength)
		# make sure first beat is emphasized
		p |= gmdrumnamed("Bass Drum 1")
		$.edittrack($.currchan,p)
	}
}

method grindo_ctrl_quant(c,nw) {
	# The keys A-Z will map to offsets -12 to 12.
	q = 1
	if ( c == "H" ) {
		q = 2b
	} else if ( c == "Q" ) {
		q = 1b
	} else if ( c == "E" ) {
		q = 1b/2
	} else if ( c == "S" ) {
		q = 1b/4
	} else if ( c == "T" ) {
		q = 1b/8
	} else if ( c == "N" ) {
		q = 1
	}
	p = $.ph[$.currchan].get()
	p = quantize(p,q)
	$.edittrack($.currchan,p)
}

method grindo_inc_vol(v) {
	$.grindo_inc_controller(v,Grindocontrollerletters["V"])
}
method grindo_inc_express(v) {
	$.grindo_inc_controller(v,Grindocontrollerletters["E"])
}
method grindo_inc_chorus(v) {
	$.grindo_inc_controller(v,Grindocontrollerletters["C"])
}
method grindo_inc_reverb(v) {
	$.grindo_inc_controller(v,Grindocontrollerletters["R"])
}
method grindo_inc_reverbtime(v) {
	$.grindo_inc_controller(v,Grindocontrollerletters["T"])
}
method grindo_inc_bright(v) {
	$.grindo_inc_controller(v,Grindocontrollerletters["B"])
}
method grindo_inc_octave(v) {
	if ( v == INCDEC_MID )
		$.tp["octshift"][$.currchan] = 0
	else if ( v == INCDEC_MIN )
		$.tp["octshift"][$.currchan] = -3
	else if ( v == INCDEC_MAX )
		$.tp["octshift"][$.currchan] = 3
	else if ( v == INCDEC_INC )
		$.tp["octshift"][$.currchan]++
	else if ( v == INCDEC_DEC )
		$.tp["octshift"][$.currchan]--
}
method grindo_inc_velocityinc(v) {
	if ( v == INCDEC_MID )
		$.tp["velocity"][$.currchan] = Grindodefaultvelocityinc
	else if ( v == INCDEC_MIN )
		$.tp["velocity"][$.currchan] = -999
	else if ( v == INCDEC_MAX )
		$.tp["velocity"][$.currchan] = 999
	else if ( v == INCDEC_INC )
		$.tp["velocity"][$.currchan] += 10
	else if ( v == INCDEC_DEC )
		$.tp["velocity"][$.currchan] -= 10
}

method grindo_inc_controller(v,ctlr) {
	ov = $.tp["ctlr"][$.currchan][ctlr]
	if ( v == INCDEC_MID )
		ov = 64
	else if ( v == INCDEC_MIN )
		ov = 0
	else if ( v == INCDEC_MAX )
		ov = 127
	else if ( v == INCDEC_INC )
		ov += GrindoControllerInc
	else if ( v == INCDEC_DEC )
		ov -= GrindoControllerInc
	if ( ov > 127 )
		ov = 127
	if ( ov < 0 )
		ov = 0
	$.tp["ctlr"][$.currchan][ctlr] = ov
	if ( ctlr == 0x5c )
		p = gm2reverbtime(ov)
	else
		p = controller($.currchan,ctlr,ov)
	realtime(p)
}

method grindo_set_controller(v,ctlr,ch) {
	if ( v > 127 )
		v = 127
	if ( v < 0 )
		v = 0
	$.tp["ctlr"][ch][ctlr] = v
	p = controller(ch,ctlr,v)
	realtime(p)
}

method grindo_init_arrays() {
	$.loopstart = 0
	$.loopquant = 4b

	$.tp = []
	$.tp["loopmute"] = []
	for ( c=1; c<=$.nchans; c++ ) {
		$.tp["loopmute"][c] = 0
	}
	$.tp["ctlr"] = []
	for ( c=1; c<=$.nchans; c++ ) {
		$.tp["ctlr"][c] = $.grindo_initial_ctlr()
	}
	$.tp["sound"] = []
	$.tp["pan"] = []
	for ( c=1; c<=$.nchans; c++ ) {
		$.tp["pan"][c] = 64
	}
	$.tp["immediate"] = []
	for ( c=1; c<=$.nchans; c++ ) {
		$.tp["immediate"][c] = ""
	}
	$.tp["octshift"] = []
	for ( c=1; c<=$.nchans; c++ ) {
		$.tp["octshift"][c] = 0
	}
	$.tp["velocity"] = []
	for ( c=1; c<=$.nchans; c++ ) {
		$.tp["velocity"][c] = 0
	}
	$.tp["mode"] = []
	for ( c=1; c<=$.nchans; c++ ) {
		$.tp["mode"][c] = GrindoModeList[Grindodefaultmode]
	}
	$.tp["phrase"] = []
	for ( c=1; c<=$.nchans; c++ ) {
		$.tp["phrase"][c] = []
		$.grindo_rescale(c,$.tp["phrase"],'c',"newage")
	}
}

method readfile() {
	fname = browsefiles("Midi file (*.mid)","*.mid",0)
	if ( fname == "" ) {
		print("No file")
		return()
	}
	$.fname = fname
	$.fphrase = readmf($.fname)
	$.next_part()
}

method next_part() {
print("Next part")
	$.tp["phrase"] = []
	for ( c=1; c<=$.nchans; c++ ) {
		$.tp["phrase"][c] = []
		lastoffset = $.grindo_readmid(c,$.fphrase,
					$.tp["phrase"],$.foffset)
	}
	$.foffset = lastoffset
}

method global_defaults() {

	Grindograbquant = 1b/4
	Grindodefaultmode = "L"
	GrindoKeyOrder = "QAZWSXEDCRFVTGBYHNUJMIKOLP";
	Grindodebug = 0
	GrindoControllerInc = 5
	Grindodefaultvelocityinc = 20
	Grindotransmultiple = 1
	Grindopatches = []
	Grindopatches["pad"] = (patchtypes_for_chan(1))("pad");
	Grindopatches["hard"] = (patchtypes_for_chan(1))("hard");
	Grindopatches["bass"] = (patchtypes_for_chan(1))("bass");
	Grindopatches["perc"] = (patchtypes_for_chan(1))("perc");
	Grindopatches["drum"] = (patchtypes_for_chan(1))("drum");
	Grindopatches["vocal"] = (patchtypes_for_chan(1))("vocal");

	all = []
	n = 0
	for ( i in Grindopatches ) {
		for ( k in Grindopatches[i] ) {
			all[n++] = Grindopatches[i][k]
		}
	}
	Grindopatches["all"] = all

	Grindoornament = [
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
		]

	# The pattern here are the defaults for patterns 1,2,...
	Grindodrumpatts = [
		"0" = 'l96',
		"1" = scaleng(gmdrumnamed("Bass Drum 1"),8b),
		"2" = scaleng(gmdrumnamed("Closed Hi-Hat"),4b),
		"3" = scaleng(gmdrumnamed("Closed Hi-Hat"),8b),
		"4" = readmf("patt0.mid"),
		"5" = readmf("patt1.mid"),
		"6" = readmf("patt2.mid"),
		"7" = readmf("patt3.mid"),
		"8" = readmf("patt4.mid"),
		"9" = readmf("patt5.mid")
		]


	for ( i in Grindodrumpatts ) {
		Grindodrumpatts[i].length = nextquant(Grindodrumpatts[i].length,2b)
	}

	GrindoTnumbers = ["0"=0,"1"=1,"2"=2,"3"=3,"4"=4,"5"=5,"6"=6,"7"=7,"8"=8,"9"=9]

	GrindoCtrlImmediate = [
		# "F" = "grindo_ctrl_ano"
		"U" = "edit_undo",		# Undo
		"N" = "next_part"		# Next Part
		]

	GrindoEditMethods = [
		"S" = "edit_scale",
		"G" = "edit_scale_grabbed",
		"Q" = "edit_quant",
		"E" = "edit_echo",
		"F" = "edit_fractal",
		"C" = "edit_comb",
		"A" = "edit_arpeggio",
		"O" = "edit_ornament",
		"P" = "edit_ornament_pleasing"
		]

	GrindoCtrlList = [
		"D" = "grindo_ctrl_drumpatt",		# Drums
		"M" = "grindo_ctrl_mode",		# Mode
		"O" = "grindo_ctrl_offset",		# Offset
		"N" = "grindo_ctrl_pan",		# Pan
		"Q" = "grindo_ctrl_quant",		# Quant
		"A" = "grindo_ctrl_assign",		# Assign (to keys)
		"S" = "grindo_ctrl_sound",		# Sound
		"X" = "grindo_ctrl_exec",		# Xecute
		"I" = "grindo_ctrl_immediate",		# Immediate
		"E" = "grindo_ctrl_edit",		# Edit
		"G" = "grindo_ctrl_grabber"		# Grab
	]

	IncDecList = [
		"L" = "grindo_inc_vol",
		"E" = "grindo_inc_express",
		"C" = "grindo_inc_chorus",
		"O" = "grindo_inc_octave",
		"V" = "grindo_inc_velocityinc",
		"B" = "grindo_inc_bright",
		"R" = "grindo_inc_reverb",
		"T" = "grindo_inc_reverbtime"
	]

	Grindofuncmap = [
		"grindo_mode_looper" = "grindo_mode_looper",
		"grindo_mode_repeater" = "grindo_mode_repeater"
	]

	# The values here are the default controller values
	if ( ! defined(Grindocontrollers) ) {
		Grindocontrollers = [
			0x07 = 80,	# vol
			0x0b = 127,	# expression
			0x5b = 40,	# reverb
			0x5c = 40,	# reverbtime (non-standard)
			0x5d = 40,	# chorus
			0x4a = 64	# brightness
		]
		Grindocontrollerletters = [
			"V" = 0x07,	# vol
			"E" = 0x0b,	# expression
			"R" = 0x5b,	# reverb
			"T" = 0x5c,	# reverbtime (non-standard)
			"C" = 0x5d,	# chorus
			"B" = 0x4a	# brightness
		]
	}

	GrindoScales = [
		"N" = "newage",
		"I" = "ionian",
		"L" = "lydian",
		"A" = "aeolian",
		"F" = "fifths",
		"H" = "harminor",
		"M" = "melminor"
	]

	GrindoModeList = [
		"L" = ["name"="Looper","func"="grindo_mode_looper"],
		"R" = ["name"="Repeater","func"="grindo_mode_repeater"]
	]

}

method grindo_start() {

	# Constants and setup

	$.nchans = 10
	$.playquant = 1b/4

	$.recquant = 1b/8
	$.recquant = 1

	$.global_defaults()

	$.lastdown = []	# one per letter/key - records the last
			# time it was pressed, so when it comes
			# up you can get a duration if you want

	$.grindo_init_arrays()
	$.currchan = 1

	$.loopstart = 0
	for ( ch=1; ch<=$.nchans; ch++ ) {
		$.tp["loopmute"][ch] = 0
		$.tp["ctlr"][ch] = $.grindo_initial_ctlr()
		$.tp["octshift"][ch] = 0
		$.tp["velocity"][ch] = Grindodefaultvelocityinc
	}

	$.charproc = ""
	$.shiftisdown = 0
	$.inc_is_down = 0
	$.dec_is_down = 0
	$.quit = 0
	$.lastfract = ''

}

method grindo_initial_ctlr() {
	arr = []
	for ( i in Grindocontrollers ) {
		arr[i] = Grindocontrollers[i]
	}
	return(arr)
}

method snarf {
	Snarf = $.get()
}

}

function mkmenu_grind1(o,po) {
	o.submenu("Length      ->","mkmenu_grindleng",po)
	o.submenu("# of Kbooms ->","mkmenu_grindnum",po)
	o.submenu("Start Quant ->","mkmenu_wrquantvals",po,"setstartquant")
	o.submenu("Record Quant ->","mkmenu_wrquantvals",po,"setrecquant")
	o.menucmd("Snarf",po,"snarf")
	o.menucmd("Send Patches",po,"sendpatches")
	o.menucmd("Read File",po,"readfile")
}

function mkmenu_grindleng(o,po) {
	o.menucmd("4b",po,"setlength",4b)
	o.menucmd("8b",po,"setlength",8b)
	o.menucmd("16b",po,"setlength",16b)
	o.menucmd("32b",po,"setlength",32b)
	o.menucmd("48b",po,"setlength",48b)
	o.menucmd("64b",po,"setlength",64b)
	o.menucmd("96b",po,"setlength",96b)
}

function mkmenu_grindnum(o,po) {
	for ( n=2; n<=16; n++ )
		o.menucmd(string(n),po,"nbchanged",n)
}

