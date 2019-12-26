FrescoDebug = 0

if ( ! defined(FrescoDevice) ) {
	FrescoDevice = 0
}

function fresco(fingdev) {
	if ( nargs() < 1 )
		fingdev = 0
	print("Play away... (restricted to dev="+fingdev+")")
	a = mdep("gesture","devices")
	limit = 7
	width = []
	height = []
	for ( i in a ) {
		width[i] = a[i]["width"]
		height[i] = a[i]["height"]
	}
	print("width=",width)
	print("height=",height)
	f = gesturefifo()
	initialized = 0
	mdep("gesture","clear")
	dt = 1b/4
	dt = 2
	nexttm = Now+dt
	while (1) {
		d = get(f)
		nc = d["contacts"]
		if ( initialized == 0 ) {
			if ( nc > limit ) {
				continue
			}
			initialized = 1
		}
		dev = d["device"]
		if ( dev != fingdev )
			continue
		if ( ! (dev in width) ) {
			print("Hey, dev=",dev," is not in width?")
			continue
		}
		wid = width[dev]
		hgt = height[dev]
		if ( wid <= 0 ) {
			print("wid for device = ",dev," is ",wid," ??")
			continue
		}
		nc = d["contacts"]
		if ( nc > limit )
			break
		if ( Now < nexttm )
			continue
		nexttm = Now+dt
		for ( n=0; n<nc; n++ ) {
			dd = d[n]
			if ( typeof(dd) != "array" ) {
				print("Hmmm, dd not an array?")
				continue
			}
			if ( ! ("x" in dd) ) {
				print("Hmmm, x not in dd?")
				continue
			}
			x = dd["x"]
			y = dd["y"]
			xp = integer( 5 * dd["proximity"] + ( 128 * x / wid) )
			yp = integer(128 * y / hgt)
			ch = 1
			nt = makenote(xp,1b/4,yp,ch)
			print("(",xp,",",dd["proximity"],") nt=",nt)
			realtime(nt)
		}
	}
}

function fresco2(dt,q,plimit,fingdev) {
	if ( nargs() == 0 ) {
		print("Usage: fresco2(chunkwidth, quant, plimit, fingdev)")
		return()
	}
	if ( nargs() < 1 )
		dt = 4b
	if ( nargs() < 2 )
		q = 1b/4
	if ( nargs() < 3 )
		plimit = 2
	if ( nargs() < 4 )
		fingdev = 0

	p = readmf("jsbach.mid")
	# p = readmf("joy6.mid")
	# p = readmf("c:\\local\\midi\\tjt\\state.mid")

	# p = arpeggio(p)
	# p = step(p,1b/4)

	f = new fresco2_obj(dt,q,fingdev,p,plimit)
	f.start()
	c = Root.waitforconsolekey()
	f.stop()
}

class fresco2_obj {
method init(dt,q,fingdev,p,plimit) {
	$.gridrows = 32
	$.gridcols = 32
	$.rowboundary1 = $.gridrows / 3
	$.rowboundary2 = 2 * $.gridrows / 3
	$.colboundary1 = $.gridcols / 3
	$.colboundary2 = 2 * $.gridcols / 3

	p = onlynotes(p)

	$.riffs = []
	$.playing = []
	t1 = 0
	t2 = dt
	for ( n=0; n<$.gridcols; n++ ) {
		x = cut(p,CUT_TIME,t1,t2)
		x.time -= x%1.time
		$.riffs[n] = x
		t1 = t2
		t2 += dt
	}
	$.curr = 0
	$.dt = dt
	$.quant = q
	$.fingdev = fingdev
	$.fingersdown = 0
	$.pnext = 0
	$.pfirst = 0
	$.plimit = plimit
}

method start() {
	gesturenotifyrc($,$.gridrows,$.gridcols)

}
method stop {
	print("Stopping fresco2")
	for ( uid in $.playing ) {
		kill($.playing[uid])
	}
	gestureunnotify($)
}

method gotgesturerc(t,dev,finger,r,c,prox) {

	uid = 100*dev + finger
	lastriff = sizeof($.riffs) - 1
	if ( FrescoDebug ) {
		print("fingdev=",dev);
	}
	if ( dev != $.fingdev )
		return()
	# print("dev=",dev," fing=",finger," rc=",r,c)
	if ( t == "fingerdown" ) {
		$.fingersdown++
		if ( $.fingersdown > 3 ) {
			print("KILLING ALL!")
			for ( uid in $.playing ) {
				kill($.playing[uid])
			}
			$.playing = []
			$.pnext = 0
			$.pfirst = 0
			return()
		}

		if ( c < $.colboundary1 ) {
			$.curr--
		} else if ( c > $.colboundary2 ) {
			$.curr++
		}
		if ( $.curr < 0 ) {
			$.curr = lastriff
		} else if ( $.curr > lastriff ) {
			$.curr = 0
		}
		if ( ! ($.curr in $.riffs) ) {
			print("Huh?  $.curr = ",$.curr," not in riffs?")
			return()
		}
		nq = nextquant(Now,$.quant)
		if ( $.pnext >= ($.pfirst + $.plimit) ) {
			kill($.playing[$.pfirst])
			delete $.playing[$.pfirst]
			$.pfirst++
		}
		$.playing[$.pnext] = realtime($.riffs[$.curr],nq)
		$.pnext++
	} else if ( t == "fingerup" ) {
		$.fingersdown--
		# if ( uid in $.playing ) {
		# 	kill($.playing[uid])
		# }
	}
}

}

function fresco3(dt,q,fingdev) {
	if ( nargs() < 1 )
		dt = 4b
	if ( nargs() < 2 )
		q = 1b/2
	if ( nargs() < 3 )
		fingdev = FrescoDevice

	f = new fresco3_obj(dt,q,fingdev)
	f.start()
	c = Root.waitforconsolekey()
	f.stop()
}

class fresco3_obj {
method init(dt,q,fingdev) {
	$.gridrows = 32
	$.gridcols = 32
	$.rowboundary1 = $.gridrows / 3 - 5
	$.rowboundary2 = 2 * $.gridrows / 3 + 2
	$.colboundary1 = $.gridcols / 3 - 1
	$.colboundary2 = 2 * $.gridcols / 3 - 1

	$.musictype = "scale"
	$.doquant = 1
	$.playing = []
	$.downtime = []
	$.dt = dt
	$.quant = q
	$.fingdev = fingdev
	$.scales = [
		0="newage",
		1="chromatic",
		2="fifths"
		# 3="aeolian",
		# 4="ionian",
		# 5="melminor",
		]
	$.currscale = 9999
	$.nextscale()

	$.offsets = [0=0,1=3,2=-2,3=5,4=-5,5=7,6=2]
	$.curroffset = 9999

	$.sounds = [0="normal",1="random"]
	$.currsound = 9999
	$.setsound(0)

	np = 0
	$.phrases = []
	# p = readmf("jsbach.mid")
	# p = scatimes(p,0.5)
	# $.phrases[np++] = $.makephrases(p,1b)
	# $.phrases[np++] = $.makephrases(p,2b)
	# $.phrases[np++] = $.makephrases2(p,0)
	# $.phrases[np++] = $.makephrases2(p,1)

	p = readmf("joy6.mid")
	p.pitch -= 16
	p.vol += 30
	# p = scatimes(p,0.5)
	$.phrases[np++] = $.makephrases(p,1b)
	$.phrases[np++] = $.makephrases(p,2b)
	$.phrases[np++] = $.makephrases(p,4b)
	# $.phrases[np++] = $.makephrases2(p,0)
	# $.phrases[np++] = $.makephrases2(p,1)

	# p = readmf("prelude.mid")
	p = readmf("bachinv1.mid")
	p.pitch -= 24
	p.vol += 20
	$.phrases[np++] = $.makephrases(p,1b)
	$.phrases[np++] = $.makephrases(p,2b)

	p = readmf("bachinv2.mid")
	p.pitch -= 24
	p.vol += 20
	$.phrases[np++] = $.makephrases(p,1b)
	$.phrases[np++] = $.makephrases(p,2b)

	p = readmf("bachinv3.mid")
	p.pitch -= 24
	p.vol += 20
	$.phrases[np++] = $.makephrases(p,1b)
	$.phrases[np++] = $.makephrases(p,2b)

	# $.phrases[np++] = $.makephrases2(p,0)
	# $.phrases[np++] = $.makephrases2(p,1)

	$.currphrase = 0
}

method makephrases(p,dt) {
	p = onlynotes(p)
	p.chan = 1
	phrases = []
	t1 = 0
	t2 = dt
	etime = latest(p)
	for ( r=0; r<$.gridrows; r++ ) {
		for ( c=0; c<$.gridcols; c++ ) {
			x = cut(p,CUT_TIME,t1,t2)
			x = $.normnote(x)
			phrases[r * $.gridcols + c] = x
			if ( t2 >= etime ) {
				t1 = 0
				t2 = dt
			} else {
				t1 = t2
				t2 += dt
			}
		}
	}
	return(phrases)
}

method makephrases2(p,domono) {
	p = onlynotes(p)
	p.chan = 1
	phrases = []
	pp = split(p)
	if ( domono ) {
		p = arpeggio(p)
	}
	n = 0
	for ( r=0; r<$.gridrows; r++ ) {
		for ( c=0; c<$.gridcols; c++ ) {
			x = pp[n]
			n++
			if ( n >= sizeof(pp) ) {
				n = 0
			}
			x = $.normnote(x)
			phrases[r * $.gridcols + c] = x
		}
	}
	return(phrases)
}

method normnote(x) {
	x.time -= x%1.time
	if ( x.dur < 24 ) {
		x.dur += (24 - x.dur)
	}
	x.length = latest(x)
	return(x)
}

method nextscale() {
	if ( $.musictype == "scale" ) {
		$.currscale++
		if ( $.currscale >= sizeof($.scales) ) {
			$.currscale = 0
		}
		print("Scale = ",$.scales[$.currscale])
		$.scl = makescale(scalenamed($.scales[$.currscale]))
	} else if ( $.musictype == "phrase" ) {
		$.currphrase++
		if ( $.currphrase >= sizeof($.phrases) ) {
			$.currphrase = 0
		}
		print("Phrase set = ",$.currphrase)
	}
}

method nextoffset() {
	$.curroffset++
	if ( $.curroffset >= sizeof($.offsets) ) {
		$.curroffset = 0
	}
	Offsetpitch = $.offsets[$.curroffset]
	print("Offset = ",Offsetpitch)
}

method setsound(dorand) {
	if ( dorand ) {
		p1 = 1+rand(128)
		p2 = 1+rand(128)
		p3 = 1+rand(128)
		p = progchange(p1,1) +
			progchange(p2,2) +
			progchange(p3,3)
		realtime(p)
		print("Sounds randomized, p1=",p1," p2=",p2," p3=",p3)
	} else {
		p = progchange(44,1) +
			progchange(23,2) +
			progchange(44,3)

			# progchange(105,3)
		realtime(ano())
		realtime(p)
		print("Sounds reset to normal")
	}
}

method start() {
	gesturenotifyrc($,$.gridrows,$.gridcols)
	$.miditid = task $.monitormidi()

}
method monitormidi() {
	Midiin[$] = f = open();
	while ( (n=get(f)) != Eof ) {
		# print("n=",n)
		if ( n.chan != 16 )
			continue
		if ( n.type != NOTEON )
			continue
		if ( n.pitch == 0 ) {
			# Change notes
			$.nextscale()
		} else if ( n.pitch == 1 ) {
			# Change pitch offset
			$.nextoffset()
		} else if ( n.pitch == 13 ) {
			print("RESET!")
			exit(1)
		} else if ( n.pitch == 22 ) {
			$.setsound(0)
		} else if ( n.pitch == 23 ) {
			$.setsound(1)
		} else if ( n.pitch == 24 ) {
			if ( $.musictype == "scale" ) {
				$.musictype = "phrase"
				$.doquant = 0
			} else {
				$.musictype = "scale"
				$.doquant = 1
			}
			print("Switching to musictype = ",$.musictype)
		} else if ( n.pitch == 25 ) {
			$.doquant = 1 - $.doquant
			print("Doquant = ",$.doquant)
		} else if ( n.pitch == 26 ) {
			tempo(tempo()/2)
			print("Tempo = ",tempo());
		} else if ( n.pitch == 27 ) {
			tempo(tempo()*2)
			print("Tempo = ",tempo());
		} else if ( n.pitch > 25 ) {
			print("Unrecognized Control pitch = ",n.pitch)
		}
	}
}
method stop {
	print("Stopping fresco3")
	kill($.miditid)
	for ( uid in $.playing ) {
		kill($.playing[uid])
	}
	gestureunnotify($)
}

method notefor(r,c,prox) {
	p = 30 + (r+c)%75
	v = prox * 40
	ch = 1
	if ( r > $.rowboundary1 )
		ch = 2
	if ( r > $.rowboundary2 )
		ch = 3
	nt = makenote(p,1b/2,v,ch)
	nt = scadjust(nt,$.scl)
	return(nt)
}
method phrasefor(r,c,prox) {
	p = 30 + (r+c)%75
	v = prox * 40
	ch = 1
	pp = $.phrases[$.currphrase]
	i = (r*$.gridcols + c) % sizeof(pp)
	nt = pp[i]
	# print("phrase szphrase=",sizeof(pp)," rc=",r,c," i=",i,"  =",nt)
	return(nt)
}
method gotgesturerc(t,dev,finger,r,c,prox) {

	uid = 100*dev + finger
	if ( FrescoDebug ) {
		print("fingdev=",dev);
	}
	if ( dev != $.fingdev )
		return()
	# print("dev=",dev," fing=",finger," rc=",r,c)
	if ( t == "fingerdown" ) {

		if ( $.doquant ) {
			nq = nextquant(Now,$.quant)
		} else {
			nq = Now
		}
		if ( $.musictype == "scale" ) {
			nt = $.notefor(r,c,prox)
			# nt.dur *= 4
			nt.velocity += 30
		} else if ( $.musictype == "phrase" ) {
			nt = $.phrasefor(r,c,prox)
			nt = repeat(nt,4)
			# nt.dur *= 16
		}
		# print("down nt=",nt)
		$.playing[uid] = realtime(nt,nq)
		$.downtime[uid] = nq

	} else if ( t == "fingerup" ) {
		if ( $.musictype == "phrase" ) {
			# print("fingerup fing=",finger)
			if ( uid in $.playing ) {
				kill($.playing[uid])
				# print("killing up")
			}
		}
	} else if ( t == "fingerdrag" ) {
		# print("fingerdrag fing=",finger," prox=",prox)
		if ( $.musictype == "scale" ) {
			nt = $.notefor(r,c,prox)
			thisq = $.quant
			if ( prox > 1.3 ) {
				thisq /= 2
			}
			if ( prox > 2.0 ) {
				thisq /= 2
			}
			nq = nextquant(Now,thisq)
			$.playing[uid] = realtime(nt,nq)
		} else if ( $.musictype == "phrase" ) {
			nt = $.phrasefor(r,c,prox)
			nt = repeat(nt,4)
			# nt.dur *= 16
			thisq = $.quant
			# thisq /= 2
			if ( prox > 1.3 ) {
				thisq /= 2
			}
			if ( uid in $.playing ) {
				# kill($.playing[uid])
				task $.killlater($.playing[uid],thisq*4)
				# print("killing drag, rc=",r,c)
			}
			nq = nextquant(Now,thisq)
			$.playing[uid] = realtime(nt,nq)
		}
	}
}

method killlater(id,tm) {
	sleeptill(tm)
	kill(id)
}

}
