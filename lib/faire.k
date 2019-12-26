function faire(scale,low,high,minvol,maxvol) {
	if ( nargs() < 1 ) {
		scale = "newage"
	}
	if ( nargs() < 3 ) {
		low = 43
		high = 99
	}
	if ( nargs() < 5 ) {
		minvol = 0
		maxvol = 120
	}

	d = new faire_dispatch()

	a = new faire1(low,high,minvol,maxvol,scale)
	d.set_process(1,a)

	b = new faire2(low,high,minvol,maxvol,scale)
	d.set_process(2,b)

	c = new faire3(36,53,40,127,"chromatic")
	d.set_process(3,c)

	d.start()

	Root.waitforconsolekey()

	d.stop()
}

class faire_dispatch {
	method init() {
		$.verbose = verbose

		$.fing = []
		$.process = []
		$.devmap = []  # maps real devices to the 1,2,3 we want
		$.nextdevnum = 1
	}
	method set_process(dev,obj) {
		$.process[dev] = obj
	}

	method start() {
		gesturenotifyrc($,128,128)
	}
	method stop() {
		gestureunnotify($)
		print "Should be deleting objects"
		for ( i in $.process ) {
			print("process i=",i," = ",$.process[i])
			deleteobject($.process[i])
		}
	}
	method findex(dev,finger) {
		return (100 * dev + finger)
	}
	method gotgesturerc(gtype,dev,finger,r,c,prox) {
		if ( ! ( dev in $.devmap ) ) {
			print("NEW DEVICE, dev=",dev," will be ",$.nextdevnum)
			$.devmap[dev] = $.nextdevnum++
		}
		dev = $.devmap[dev]
			
		i = $.findex(dev,finger)
		if ( ! (dev in $.process ) ) {
			print("Dev ",dev," doesn't have a processor!")
			return()
		}
		proc = $.process[dev]
		if ( gtype == "fingerdown" ) {
			proc.dofingerdown(i,r,c,prox)
		} else if ( gtype == "fingerup" ) {
			proc.dofingerup(i,r,c,prox)
		} else { # drag
			proc.dofingerdrag(i,r,c,prox)
		}
	}
}

class faire1 {
	method init(lowpitch,highpitch,minvol,maxvol,scale) {
		$.verbose = verbose
		$.scl = completescale('c',scale)
		$.scl = $.scl{??.pitch >= lowpitch && ??.pitch <= highpitch}
		$.sclsize = sizeof($.scl)
		$.fing = []
		$.minvol = minvol
		$.maxvol = maxvol
		$.ch = 1
		print("I am ",$,"  scale=",$.scl)
	}
	method delete {
		print("Hi from FAIRE1 DELETE!")
	}
	method rcnote(r,c,prox) {
		scalent = $.scl % (1+((( c % 128 ) * ($.sclsize / 128.0 )) % ($.sclsize)))
		p = scalent.pitch

		v = $.minvol + integer((prox * 48.0) % ($.maxvol-$.minvol))
		if ( v == 0 ) {
			print ("WHAT?,  vel = 0 when prox = ",prox,"\n\n")
			v = $.minvol
		}
		nt = makenote(p)
		nt.vol = v
		nt.type = NOTEON
		nt.chan = $.ch
		# print("pitch = ",p,"  rcnote = ",nt)
		return(nt)
	}
	method dofingerdown(i,r,c,prox) {
		# print("FAIRE1 GOT down i=",i," rc=",r,c," prox=",prox)
		# print("status=",gesturestatus())
		if ( i in $.fing ) {
			print("Hey, unexpected, i=",i," in notes")
			$.dofingerup(i,r,c,prox)
			return()
		}
		nt = $.rcnote(r,c,prox)
		realtime(nt)
		# print("FRESH NOTE = ",nt)
		$.fing[i] = ["note"=nt,"r"=r,"c"=c]
	}
	method dofingerdrag(i,r,c,prox) {
		# print("GOT drag i=",i," rc=",r,c," prox=",prox)
		if ( ! ( i in $.fing ) ) {
			print("Hey, unexpected, i=",i," NOT in notes")
			return()
		}
		f = $.fing[i]
		oldr = f["r"]
		oldc = f["c"]
		oldnote = f["note"]
		if ( oldr == r && oldc == c ) {
			return()
		}
		newnt = $.rcnote(r,c,prox)
		if ( oldnote.pitch != newnt.pitch || oldnote.chan != newnt.chan ) {
			oldnote.type = NOTEOFF
			# print("OLD NOTE = ",oldnote)
			realtime(oldnote)
			realtime(newnt)
			# print("NEW NOTE = ",newnt)
			$.fing[i] = ["note"=newnt,"r"=r,"c"=c]
		}
	}
	method dofingerup(i,r,c,prox) {
		# print("GOT up i=",i," rc=",r,c," prox=",prox)
		if ( ! ( i in $.fing ) ) {
			print("Hey, unexpected, i=",i," NOT in notes")
			realtime(ano())
			return()
		}
		nt = $.fing[i]["note"]
		nt.type = NOTEOFF
		realtime(nt)
		# print("ENDED NOTE = ",nt)
		delete $.fing[i]
	}
}

class faire2 {
	method init(lowpitch,highpitch,minvol,maxvol,scale) {
		$.verbose = verbose
		$.scl = completescale('c',scale)
		$.scl = $.scl{??.pitch >= lowpitch && ??.pitch <= highpitch}
		$.sclsize = sizeof($.scl)
		$.fing = []
		$.minvol = minvol
		$.maxvol = maxvol
		$.ch = 2
		print("scale=",$.scl)
	}
	method delete {
		print("Hi from FAIRE2 DELETE!")
	}
	method rcnote(r,c,prox) {
		scalent = $.scl % (1+((( c % 128 ) * ($.sclsize / 128.0 )) % ($.sclsize)))
		p = scalent.pitch

		v = $.minvol + integer((prox * 48.0) % ($.maxvol-$.minvol))
		if ( v == 0 ) {
			print ("WHAT?,  vel = 0 when prox = ",prox,"\n\n")
			v = $.minvol
		}
		nt = makenote(p)
		nt.vol = v
		nt.type = NOTEON
		nt.chan = $.ch
		# print("pitch = ",p,"  rcnote = ",nt)
		return(nt)
	}
	method dofingerdown(i,r,c,prox) {
		# print("FAIRE2 GOT down i=",i," rc=",r,c," prox=",prox)
		# print("status=",gesturestatus())
		if ( i in $.fing ) {
			print("Hey, unexpected, i=",i," in notes")
			$.dofingerup(i,r,c,prox)
			return()
		}
		nt = $.rcnote(r,c,prox)
		realtime(nt)
		# print("FRESH NOTE = ",nt)
		$.fing[i] = ["note"=nt,"r"=r,"c"=c]
	}
	method dofingerdrag(i,r,c,prox) {
		# print("GOT drag i=",i," rc=",r,c," prox=",prox)
		if ( ! ( i in $.fing ) ) {
			print("Hey, unexpected, i=",i," NOT in notes")
			return()
		}
		f = $.fing[i]
		oldr = f["r"]
		oldc = f["c"]
		oldnote = f["note"]
		if ( oldr == r && oldc == c ) {
			return()
		}
		newnt = $.rcnote(r,c,prox)
		if ( oldnote.pitch != newnt.pitch || oldnote.chan != newnt.chan ) {
			oldnote.type = NOTEOFF
			# print("OLD NOTE = ",oldnote)
			realtime(oldnote)
			realtime(newnt)
			# print("NEW NOTE = ",newnt)
			$.fing[i] = ["note"=newnt,"r"=r,"c"=c]
		}
	}
	method dofingerup(i,r,c,prox) {
		# print("GOT up i=",i," rc=",r,c," prox=",prox)
		if ( ! ( i in $.fing ) ) {
			print("Hey, unexpected, i=",i," NOT in notes")
			realtime(ano())
			return()
		}
		nt = $.fing[i]["note"]
		nt.type = NOTEOFF
		realtime(nt)
		# print("ENDED NOTE = ",nt)
		delete $.fing[i]
	}
}

# This one is for drums

class faire3 {
	method init(lowpitch,highpitch,minvol,maxvol,scale) {
		$.verbose = verbose
		$.scl = completescale('c',scale)
		$.scl = $.scl{??.pitch >= lowpitch && ??.pitch <= highpitch}
		$.sclsize = sizeof($.scl)
		$.fing = []
		$.minvol = minvol
		$.maxvol = maxvol
		$.ch = 3
		# print("scale=",$.scl)
		$.beater = task $.task_beatme()
	}
	method task_beatme() {
		beat = 1b/8
		nextbeat = nextquant(Now,beat)
		beatnum = 0
		while (1) {
			sleeptill(nextbeat-2)
			for ( i in $.fing ) {
				f = $.fing[i]
				# print("fing i=",i," bf=",f["beatfactor"])
				# print("fing i=",i," f=",f)
				bf = f["beatfactor"]
				if ( (beatnum % bf) == 0 ) {
					nt = f["note"]
					nt.type = NOTE
					nt.dur = 1b/8
					# print("playing beatnum=",beatnum," i=",i," bf=",bf," note=",nt)
					realtime(nt)
				}
			}
			nextbeat += beat
			beatnum++
		}
	}
	method delete {
		print("Hi from FAIRE3 DELETE!")
		kill($.beater)
	}
	method beatfactor(prox) {
		bf = 1
		if ( prox < 1.5 )
			bf = 8
		else if ( prox < 2.0 )
			bf = 4
		else if ( prox < 2.5 )
			bf = 2
		else if ( prox < 3.0 )
			bf = 1
		# print("BEATFACTOR prox=",prox," bf=",bf)
		
		return(bf)
	}
	method rcnote(r,c,prox) {
		scalent = $.scl % (1+((( c % 128 ) * ($.sclsize / 128.0 )) % ($.sclsize)))
		p = scalent.pitch

		v = $.minvol + integer((prox * 48.0) % ($.maxvol-$.minvol))
		if ( v == 0 ) {
			print ("WHAT?,  vel = 0 when prox = ",prox,"\n\n")
			v = $.minvol
		}
		nt = makenote(p)
		nt.vol = v
		nt.type = NOTEON
		nt.chan = $.ch
		# print("pitch = ",p,"  rcnote = ",nt)
		return(nt)
	}
	method dofingerdown(i,r,c,prox) {
		# print("FAIRE3 GOT down i=",i," rc=",r,c," prox=",prox)
		# print("status=",gesturestatus())
		if ( i in $.fing ) {
			print("Hey, unexpected, i=",i," in notes")
			$.dofingerup(i,r,c,prox)
			return()
		}
		nt = $.rcnote(r,c,prox)
		realtime(nt)
		# print("FRESH NOTE = ",nt)
		$.fing[i] = ["note"=nt,"r"=r,"c"=c,"beatfactor"=$.beatfactor(prox)]
	}
	method dofingerdrag(i,r,c,prox) {
		# print("GOT drag i=",i," rc=",r,c," prox=",prox)
		if ( ! ( i in $.fing ) ) {
			print("Hey, unexpected, i=",i," NOT in notes")
			return()
		}
		f = $.fing[i]

		# update the beat factor no matter what
		bf = $.beatfactor(prox)
		if ( bf != f["beatfactor"] ) {
			# print ("Changing beatfactor to ",bf," prox=",prox)
			f["beatfactor"] = bf
		}

		oldr = f["r"]
		oldc = f["c"]
		oldnote = f["note"]
		if ( oldr == r && oldc == c ) {
			return()
		}
		newnt = $.rcnote(r,c,prox)
		if ( oldnote.pitch != newnt.pitch || oldnote.chan != newnt.chan ) {
			oldnote.type = NOTEOFF
			# print("OLD NOTE = ",oldnote)
			realtime(oldnote)
			realtime(newnt)
			# print("NEW NOTE = ",newnt)
			$.fing[i] = ["note"=newnt,"r"=r,"c"=c,"beatfactor"=$.beatfactor(prox)]
		}
	}
	method dofingerup(i,r,c,prox) {
		# print("FAIRE3 GOT up i=",i," rc=",r,c," prox=",prox)
		if ( ! ( i in $.fing ) ) {
			print("Hey, unexpected, i=",i," NOT in notes")
			realtime(ano())
			return()
		}
		nt = $.fing[i]["note"]
		nt.type = NOTEOFF
		realtime(nt)
		# print("ENDED NOTE = ",nt)
		# print("Deleted $.fing for i=",i)
		delete $.fing[i]
	}
}

