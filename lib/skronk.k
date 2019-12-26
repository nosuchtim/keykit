function skronk(p) {
	if ( nargs() < 1 ) {
		p = readmf("c:\\tmp\\actionseries.mid")
	}



	p = strip(p)
	print("Phrase length=",p.length / 1b)
	s = new skronk_obj(p)
	s.startmidi()
	s.startgesture()

	s.setstartquant(0)
	s.setstartquant(1b/4)

	s.setretrigger(0)
	s.setstrip(1)

	Root.waitforconsolekey()

	deleteobject(s)
}

class skronk_obj {
method init(p) {

	$.gesturerows = 14
	$.gesturecols = 14

	$.startquant = 1b
	$.nsect = 0
	$.loopquant = 1
	$.retrigger = 1
	$.maxsect = 1b
	$.repeat = 0
	$.loop = 0
	$.leng = 0
	$.strip = 0
	$.step = 0
	$.scaleit = 0
	$.nexttranspose = 0
	$.ison = 1
	$.initrange = 0
	$.lownote = 0
	$.highnote = 127
	$.lastid = -1
	$.playingid = -1
	$.stoptids = []
	$.gesturedevmap = []
	for ( n=0; n<8; n++ ) {
		$.gesturedevmap[n] = -1
	}
	$.ngesturedevs = 0
	$.setscale("fifths")
	print("Turning Merge off...")
	Merge=0
	$.loadphrase(p)
}

method startmidi() {
	t = task $.task_wsect_midi()
	$.stoptids[t] = 1
}

method delete {
	gestureunnotify($)
	killtids($.stoptids)
	$.stoptids = []
	print("Turning Merge back on...")
	Merge=1
}

method task_wsect_midi() {
	Midiin[$] = f = open()
	onexit(closemidi,$)
	while ( (m=get(f)) != Eof ) {
		# ph = $.phrase
		if ( m.type==NOTEON && m.chan == 1 ) {
			if ( $.initrange==1 ) {
				$.lownote = m.pitch
				$.initrange = 2
				continue
			}
			if ( $.initrange==2 ) {
				$.highnote = m.pitch
				$.resection()
				$.initrange = 0
				continue
			}
			n = m.pitch - $.lownote
			if ( n < 0 || n >= $.nsect ) {
				print("not in range?  m=",m)
				realtime(m,0)		# play things that aren't in the range
			} else {
				task $.playsection(n,m.vol)
			}
		}
		else if ( m.type==CONTROLLER ) {
			b0 = integer(subbytes(m,1,1))
			b1 = integer(subbytes(m,2,1))
			b2 = integer(subbytes(m,3,1))
			if ( b0 == 0xbe ) {
				if ( b1 == 0x46 ) {
					if ( b2 == 0x00 ) {
						$.setstartquant($.getstartquant()*2)
					} else {
						$.setstartquant($.getstartquant()/2)
					}
					print("quant = ",$.getstartquant())
				} else if ( b1 == 0x47 ) {
					if ( b2 == 0x00 ) {
						$.step = 0
					} else {
						$.step = 1
					}
					print("step = ",$.step)
				} else if ( b1 == 0x48 ) {
					if ( b2 == 0x00 ) {
						$.scaleit = 0
					} else {
						$.scaleit = 1
					}
					print("scaleit = ",$.scaleit)
				}
			} else if ( b0 == 0xbf ) {
				if ( b1 == 0x00 ) {
					arr = [0=0,1=1b/8,2=1b/4,3=1b/2,4=1b,5=2b,6=4b,7=8b]
					q = arr[integer(b2/16)]
					$.setstartquant(q)
				}
			} else if ( b1 == 0x40 ) {
				if ( b2 == 0x00 )
					$.repeat = 0
				else
					$.repeat = 1
			}
		}
		else
				realtime(m,0)
	}
}

method startgesture() {
	if ( gesturedevices() == 0 ) {
		print("Hey, no gesture pads are connected!")
		return()
	}
	gestureclear()
	gesturenotifyrc($,$.gesturerows,$.gesturecols)
}

method gotgesturerc(t,d,f,r,c,prox) {
	if ( $.gesturedevmap[d] == -1 ) {
		$.gesturedevmap[d] = $.ngesturedevs++
	}
	d = $.gesturedevmap[d]
	if ( t == "fingerdown" || t == "fingerdrag" ) {
		n = r*$.gesturecols + c
		v = integer(prox * 60)
		if ( v > 127 )
			v = 127
		print("got t=",t," rc=",r,c," prox=",prox," n=",n," nsect=",$.nsect)
		# n = m.pitch - $.lownote
		if ( n >= $.nsect ) {
			# print("n=",n," more than nsect...")
			n = n % ($.nsect)
		}
		print("Playing v=",v," d=",d)
		task $.playsection(n,v,d+1)
	}
}

method setmaxsect (v) { $.maxsect = v }
method setstartquant (v) { $.startquant = v }
method getstartquant (v) { return($.startquant) }
method set (p) {
	$.phr = p
	$.leng = p.length
	$.arr = []
	$.resection()
}
method resection() {
	narr = $.highnote - $.lownote
	print("high=",$.highnote," low=",$.lownote," narr=",narr)
	s1 = $.leng / narr
	if ( s1 <= 0 ) {
		s1 = 1
	}
	qnt = 2b
	$.sectsize = numquant( s1 , qnt )
	while ( $.sectsize <= 0 ) {
		qnt /= 2
		if ( qnt == 0 ) {
			print("Bad news in resection!?")
			break
		}
		$.sectsize = numquant( s1 , qnt )
	}
	if ( $.sectsize > $.maxsect )
		$.sectsize = $.maxsect
	$.nsect = $.leng / $.sectsize
	print("$.sectsize = ",$.sectsize, " beats=",$.sectsize/1b,"  nsect=",$.nsect)
	p = $.phr
	for ( n=0; n < $.nsect; n++ ) {
		p2 = cut(p,CUT_TIME,n*$.sectsize,n*$.sectsize+$.sectsize)
		p2 -= nonnotes(p2)
		p2.time -= numquant(p2%1.time,$.sectsize)
		if ( p2%1.time < 0 )
			p2.time += $.sectsize
		if ( $.strip ) {
			p2 = strip(p2)
		}
		# if ( $.step ) {
		#	p2 = arpeggio(p2)
		#	p2 = step(p2,1b/4)
		# }
		$.arr[n] = p2
	}
}
method playsection(n,v,ch) {
	t = nextquant(Now,$.startquant)
	# we don't want to kill the existing one till the new one starts
	sleeptill(t)
	lock($)
	if ( $.retrigger ) {
		kill($.lastid)
		kill($.playingid)
	}
	p = $.arr[n]
	if ( nargs() > 1 ) {
		p.vol = v
	}
	if ( nargs() > 2 ) {
		p.chan = ch
	}
	$.lastid = task $.playit(p,t)
	unlock($)
}
method playit(p,t) {
	while ( 1 ) {
		p = transpose(p,canonic(Key)-canonic('c'))
		if ( $.step ) {
			p = arpeggio(p)
			p = step(p,$.startquant)
		}
		if ( $.scaleit ) {
			p = scadjust(p,$.scale)
		}
		# print("playit = ",p," t=",t," Now=",Now)
		$.playingid = realtime(p,t)
		t += $.sectsize
		sleeptill(t)
		if ( $.repeat == 0 )
			break;
	}
}
method setretrigger (v) { $.retrigger = v }
method setrepeat (v) { $.repeat = v }
method loadphrase(p) {
	p = syncphr(p)
	if ( (p%1).time > (Met.length/2) ) {
		p.time -= Met.length
		p.length -= Met.length
	}
	$.set(p,1)
}

method transpose(v) {
	$.nexttranspose += integer(v)
}

method startinitrange() {
	$.initrange = 1
}
method setstrip(v) {
	$.strip = v
	for ( n=0; n < $.nsect; n++ ) {
		$.arr[n] = strip($.arr[n])
	}
}
method setstep(v) {
	$.step = v
}

method setscale(sc) {
	print("scale=",sc)
	$.scale = makescale(scalenamed(sc))
	for ( n=0; n < $.nsect; n++ ) {
		$.arr[n] = scadjust($.arr[n],s)
	}
}
}

# function mkmenu_sect2(o,po) {
# 	o.menucmd("On",po,"setretrigger",1)
# 	o.menucmd("Off",po,"setretrigger",0)
# }
# function mkmenu_sect3(o,po) {
# 	o.menucmd("On",po,"setrepeat",1)
# 	o.menucmd("Off",po,"setrepeat",0)
# }
# 
# function mkmenu_wrquantvals(o,po,meth) {
# 	o.menucmd("None",po,meth,1)
# 	o.menucmd("1b/4",po,meth,1b/4)
# 	o.menucmd("1b/2",po,meth,1b/2)
# 	o.menucmd("1b",po,meth,1b)
# 	o.menucmd("2b",po,meth,2b)
# 	o.menucmd("4b",po,meth,4b)
# 	o.menucmd("8b",po,meth,8b)
# }
# 
# function mkmenu_wrsectvals(o,po,meth) {
# 	o.menucmd("None",po,meth,1)
# 	o.menucmd("1b/4",po,meth,1b/4)
# 	o.menucmd("1b/2",po,meth,1b/2)
# 	o.menucmd("1b",po,meth,1b)
# 	o.menucmd("2b",po,meth,2b)
# 	o.menucmd("4b",po,meth,4b)
# }
# function mkmenu_sectscales(o,po) {
# 	o.menucmd("None",po,"setscale","none")
# 	o.menucmd("Newage",po,"setscale","newage")
# 	o.menucmd("Fifths",po,"setscale","fifths")
# }
# function mkmenu_setstrip(o,po) {
# 	o.menucmd("Off",po,"setstrip",0)
# 	o.menucmd("On",po,"setstrip",1)
# }
# function mkmenu_setstep(o,po) {
# 	o.menucmd("Off",po,"setstep",0)
# 	o.menucmd("On",po,"setstep",1)
# }
# 
# function mkmenu_sect1(o,po) {
# 	o.menucmd("Load from File",po,"loadfile")
# 	o.menucmd("Load from Snarf",po,"loadsnarf")
# 	o.menucmd("Init Range",po,"startinitrange")
# 	o.submenu("Retrigger    ->","mkmenu_sect2",po)
# 	o.submenu("Repeat       ->","mkmenu_sect3",po)
# 	o.submenu("Start Quant  ->","mkmenu_wrquantvals",po,"setstartquant")
# 	o.submenu("Maximum Sect ->","mkmenu_wrsectvals",po,"setmaxsect")
# 	o.submenu("Scale        ->","mkmenu_sectscales",po)
# 	o.submenu("Strip        ->","mkmenu_setstrip",po)
# 	o.submenu("Step         ->","mkmenu_setstep",po)
# }
# 
