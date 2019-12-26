function skronk2(p) {
	if ( nargs() < 1 ) {
		p = readmf("c:\\tmp\\actionseries.mid")
	}
	if ( ! defined(GestureDevMap) ) {
		global GestureDevMap
		GestureDevMap = [0=0,1=1,2=2,3=3]
	}
	Gesturedragthreshold = 0.0

	p = strip(p)
	print("Phrase length=",p.length / 1b)
	s = new skronk2_obj()
	s.startmidi()
	s.startgesture()

	# t = task s.waitforinit()
	# wait(t)

	s.loadphrase(p)
	s.enable(1)

	s.setstartquant(0)
	s.setstartquant(1b/4)

	s.setretrigger(0)
	s.setstrip(1)

	Root.waitforconsolekey()

	deleteobject(s)
}

class skronk2_obj {
method init() {

	$.gridrows = 8
	$.gridcols = 8

	$.chanplay = 1
	$.changrab = 2
	$.chaninstantiate = 3

	$.enabled = 0

	$.grabclearnext = 1
	$.grabphrase = ''

	$.devplay = 0
	$.devgrab = 1
	$.devinstantiate = 2

	$.grabmode = "paintgrab"
	$.midimode = "playngrab"

	$.startquant = 1b
	$.nsect = 0
	$.loopquant = 1
	$.retrigger = 0
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
	$.lownote = 36
	$.highnote = 96
	$.lastid = -1
	$.playingid = -1
	$.stoptids = []
	# Each entry here is an r,c pair, value is the phrase
	$.ngesturedevs = 0
	$.setscale("fifths")

	# print("Turning Merge off...")
	# Merge=0
}

method enable(v) {
	$.enabled = v
}

method waitforinit() {
	print("Press pads in order - play/grab/loop - and press low/high MIDI notes")
	while($.ngesturedevs < 3 || $.lownote < 0 || $.highnote < 0 ) {
		sleeptill(Now+1b)
	}
	if ( $.lownote > $.highnote ) {
		t = $.lownote
		$.lownote = $.highnote
		$.highnote = t
	}
	print("Okay, you're good to go")
}

method startmidi() {
	t = task $.task_wsect_midi()
	$.stoptids[t] = 1
}

method delete {
	gestureunnotify($)
	killtids($.stoptids)
	$.stoptids = []
	# print("Turning Merge back on...")
	# Merge=1
}

method task_wsect_midi() {
	Midiin[$] = f = open()
	onexit(closemidi,$)
	while ( (m=get(f)) != Eof ) {
		print("wsect_midi m=",m)
		if ( ! $.enabled ) {
			if ( m.type == NOTEON ) {
				if ( $.lownote < 0 ) {
					$.lownote = m.pitch
					print("Setting lownote to ",$.lownote)
				} else if ( $.highnote < 0 ) {
					$.highnote = m.pitch
					print("Setting highnote to ",$.highnote)
				}
			}
			continue
		}
		if ( m.port == FakeButtonDevice ) {
			pad = -1
			if ( m.pitch == 41 ) {
				pad = 1 ; butt = 1
			} else if ( m.pitch == 43 ) {
				pad = 1 ; butt = 2
			} else if ( m.pitch == 45 ) {
				pad = 1 ; butt = 3
			} else if ( m.pitch == 47 ) {
				pad = 1 ; butt = 4
			} else if ( m.pitch == 48 ) {
				pad = 1 ; butt = 5
			} else if ( m.pitch == 50 ) {
				pad = 2 ; butt = 1
			} else if ( m.pitch == 52 ) {
				pad = 2 ; butt = 2
			} else if ( m.pitch == 53 ) {
				pad = 2 ; butt = 3
			} else if ( m.pitch == 55 ) {
				pad = 2 ; butt = 4
			} else if ( m.pitch == 57 ) {
				pad = 2 ; butt = 5
			} else if ( m.pitch == 59 ) {
				pad = 3 ; butt = 1
			} else if ( m.pitch == 60 ) {
				pad = 3 ; butt = 2
			} else if ( m.pitch == 62 ) {
				pad = 3 ; butt = 3
			} else if ( m.pitch == 64 ) {
				pad = 3 ; butt = 4
			} else if ( m.pitch == 65 ) {
				pad = 3 ; butt = 5
			}
			if ( pad != -1 ) {
				gotbutton(pad,butt,m.type == NOTEON)
			}
			continue
		}
		if ( $.midimode == "playngrab" ) {
			$.handle_playnote(m)
		} else {
			print("midimode = ",$.midimode," not implemented")
		}
	}
}

method handle_playnote(m) {
	if ( m.type==NOTEON && m.chan == 1 ) {
		if ( $.initrange==1 ) {
			$.lownote = m.pitch
			$.initrange = 2
			return()
		}
		if ( $.initrange==2 ) {
			$.highnote = m.pitch
			$.resection()
			$.initrange = 0
			return()
		}
		n = m.pitch - $.lownote
		if ( n < 0 || n >= $.nsect ) {
			print("not in range?  m=",m)
			realtime(m,0)		# play things that aren't in the range
		} else {
			r = ( n / $.gridcols ) % ($.gridrows)
			c = n % ($.gridcols)
			print("n=",n," rc=",r,c)
			task $.playsection(r,c,m.vol)
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
			} else if ( b1 == 0x49 ) {
				if ( b2 == 0x00 ) {
					$.retrigger = 0
				} else {
					$.retrigger = 1
				}
				print("retrigger = ",$.retrigger)
			}
		} else if ( b0 == 0xbd ) {
			if ( b1 == 0x00 ) {
				if ( b2 > 0 ) {
					$.do_loop_arm(0)
				} else {
					$.do_loop_end(0)
				}
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
	else {
		realtime(m,0)
	}
}

method startgesture() {
	if ( gesturedevices() == 0 ) {
		print("Hey, no gesture pads are connected!")
		return()
	}
	gestureclear()
	gesturenotifyrc($,$.gridrows,$.gridcols)
}

method gotbutton(pad,butt,down) {
	print("Pad ",pad,"butt ",butt,"down=",down)
}

method setgrabphrase(p,r,c) {
	$.grabbed[r][c] = p
	$.resetgrabbed()
}

method resetgrabbed() {
	print("RESETGRABBED")
	# for each entry in $.cell
	for ( r=0; r<$.gridrows; r++ ) {
	    for ( c=0; c<$.gridcols; c++ ) {

		# find out which grabbed is the closest
		mindist = 9999
		minr = -1
		minc = -1
		for ( gr=0; gr<$.gridrows; gr++ ) {
		    for ( gc=0; gc<$.gridcols; gc++ ) {
			if ( gc in $.grabbed[gr] ) {
				# print("looking at grabbed, gr,gc=",gr,gc," = ",$.grabbed[gr][gc])
				dr = abs(gr - r)
				dc = abs(gc - c)
				dist = sqrt(dr*dr + dc*dc)
				if ( dist < mindist ) {
					mindist = dist
					minr = gr
					minc = gc
				}
			}
		    }
		}
		$.cell[r][c] = strip($.grabbed[minr][minc])
		# print("closest for rc=",r,c," is ",minr,minc)
	    }
	}
	ng = 0
	for ( gr=0; gr<$.gridrows; gr++ ) {
	    for ( gc=0; gc<$.gridcols; gc++ ) {
		if ( gc in $.grabbed[gr] ) {
			ng++
		}
	    }
	}
	print("There are ",ng," grabbed cells")
}

method gotgesturerc(t,d,f,r,c,prox) {
	d = GestureDevMap[d]
	print("gotgesturerc, t=",t,"  rc=",r,c," d=",d)
	if ( d == $.devgrab ) {
		if ( $.grabmode == "paintgrab" ) {
			print("Grab mode is paint, unimplemented")
		}
	} else if ( d == $.devplay ) {
		if ( t == "fingerdown" || t == "fingerdrag" ) {
			v = integer(prox * 60)
			if ( v > 127 )
				v = 127
			print("got t=",t,"rc=",r,c,"prox=",prox,"nsect=",$.nsect)
			print("Playing v=",v," d=",d)
			task $.playsection(r,c,v,d+1)
		}
	} else if ( d == $.devinstantiate ) {
	} else {
		print("Ignoring dev=",d)
	}
}

method setmaxsect (v) { $.maxsect = v }
method setstartquant (v) { $.startquant = v }
method getstartquant (v) { return($.startquant) }
method set(p) {
	$.phr = p
	$.leng = p.length
	$.cell = []
	$.grabbed = []
	for ( r=0; r<$.gridrows; r++ ) {
		$.grabbed[r] = []
		$.cell[r] = []
	}
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
	r = 0
	c = 0
	n = 0
	for ( r=0; r<$.gridrows; r++ ) {
	    for ( c=0; c<$.gridcols; c++ ) {
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
		print("cell r=",r," c=",c," p=",p2)
		$.cell[r][c] = p2
		n++
		if ( n >= $.nsect ) {
			n = 0
		}
	    }
	}
}
method playsection(r,c,v,ch) {
	t = nextquant(Now,$.startquant)
	# we don't want to kill the existing one till the new one starts
	sleeptill(t)
	lock($)
	print("retrigger=",$.retrigger)
	if ( $.retrigger ) {
		kill($.lastid)
		kill($.playingid)
	}
	if ( r >= $.gridrows ) {
		print("Hey, r=",r," and gridrows=",$.gridrows)
		r = $.gridrows-1
	}
	if ( c >= $.gridcols ) {
		print("Hey, c=",r," and gridcols=",$.gridcols)
		c = $.gridcols-1
	}
	p = $.cell[r][c]
	if ( nargs() > 2 ) {
		p.vol = v
	}
	if ( nargs() > 3 ) {
		p.chan = ch
	}
	print("rc=",r,c," playing ",p)
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
	for ( r=0; r<$.gridrows; r++ ) {
		for ( c=0; c<$.gridcols; c++ ) {
			$.cell[r][c] = strip($.cell[r][c])
		}
	}
}
method setstep(v) {
	$.step = v
}

method setscale(sc) {
	print("scale=",sc)
	$.scale = makescale(scalenamed(sc))
	for ( n=0; n < $.nsect; n++ ) {
		$.cell[n] = scadjust($.cell[n],s)
	}
}
}
