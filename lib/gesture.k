Gesturefifo = -1
Gestureid = -1
Gesturein = []
Gesturedebug = 0
Gesturedragthreshold = 0.02
Gestureproximitydragthreshold = 0.05
GestureProximityThreshold = 0.1
GestureGrabChan = 1
GestureGrabMinTime = 1b/4
GestureQuant = 1b/8

function gesturefifo() {
	if ( Gesturefifo < 0 )
		Gesturefifo = open("contacts","rA","gesture")
	while ( fifosize(Gesturefifo) > 0 )
		get(Gesturefifo)
	return(Gesturefifo)
}
function gesturedevices() {
	a = mdep("gesture","devices")
	return(sizeof(a))
}
function gestureclear() {
	mdep("gesture","clear")
}

function gesturestart() {
	if ( Gestureid >= 0 )
		gesturestop()
	Gestureid = task gesturenotifytask(3)
}
function gesturestop() {
	kill(Gestureid)
	Gestureid = -1
}
function gesturenotify(obj) {
	if ( Gestureid < 0 )
		gesturestart()
	if ( ! defined(obj.gotgesture) )
		print("No method gotgesture in obj=",obj)
	else
		Gesturein[obj] = 0
}
function gesturenotifyrc(obj,r,c) {
	if ( Gestureid < 0 )
		gesturestart()
	if ( ! defined(obj.gotgesturerc) )
		print("No method gotgesturerc in obj=",obj)
	else
		Gesturein[obj] = ["r"=r,"c"=c]
}
function gestureunnotify(obj) {
	delete Gesturein[obj]
	if ( sizeof(Gesturein) == 0 ) {
		gesturestop()
	}
}

function gesturestatus() {
	global Fing_down
	return(Fing_down)
}

function gesture_status_for_dev(dev) {
	f = []
	for ( i in Fing_down ) {
		idev = i / 100
		if ( idev != dev )
			continue
		fing = i % 100
		f[fing] = arraycopy(Fing_down[i])
	}
	return(f)
}

function gesturenotifytask(queuelimit) {
	if ( ! defined(GestureFifolimit) ) {
		GestureFifolimit = 30
	}
	if ( ! defined(GestureDraglimit) ) {
		GestureDraglimit = 20
	}
	gf = gesturefifo()
	if ( nargs() < 2 )
		queuelimit = 0

	gestureclear()

	a = mdep("gesture","devices")
	width = []
	height = []
	for ( i in a ) {
		width[i] = a[i]["width"]
		height[i] = a[i]["height"]
	}

	curry = 0
	global Fing_down
	Fing_down = []
	fing_tm = []
	ndown = 0
	lastfingerdown = -1

	while (1) {
		d = get(gf)
		# print("gfifo=",fifosize(gf)," d=",d)
		if ( fifosize(gf) > GestureFifolimit ) {
			if ( Gesturedebug )
				print("CLEARING GESTURE FIFO!")
			gestureclear()
			continue
		}
		if ( Gesturedebug > 1 )
			print("GESTURE EVENT = ",d)
		# get rid of stale things in Gesturein
		for ( obj in Gesturein ) {
			if ( obj == $0 || obj == $-1 ) {
				delete Gesturein[obj]
			}
		}
		if ( queuelimit > 0 ) {
			ne = fifosize(f)
			if ( ne > queuelimit ) {
				print("throwing away gesture... ne=",ne)
				continue
			}
		}
		ng = sizeof(Gesturein)
		for ( obj in Gesturein ) {
			t = Gesturein[obj]
			if ( typeof(t) == "integer" ) {
				obj.gotgesture(d)
				ng--
			}
		}
		if ( ng <= 0 )
			continue

		# Someone wants row/col notification
		# print("TJT DEBUG A")

		nc = d["contacts"]
		# print(d)
		dev = d["device"]
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
		# see what's down now
		# print("TJT DEBUG contacts=",nc)
		nowdown = []
		for ( n=0; n<nc; n++ ) {
			contact = d[n]
			# print("TJTDEBUG contact=",contact)
			if ( typeof(contact) != "array" ) {
				print("Hey, d[n=",n,"]=",contact," is not an array?")
				continue
			}
			if ( ! ("finger" in contact) ) {
				print("Hey, finger is not in contact=",contact)
				continue
			}
			finger = contact["finger"]
			# print("contact=",contact)
			if ( finger == 0 ) {
				# print("IGNORING finger=0 d=",d)
				continue
			}
			nowdown[finger+dev*100] = 1
		}
		if ( Gesturedebug > 1 )
			print("GESTURE EVENT B = ",d)
		# print("TJT DEBUG B nowdown=",nowdown)
		# print("MID nowdown=",nowdown," Fing_down=",Fing_down)
		# Update down, do noteoff for anything that's no longer down
		for ( i in Fing_down ) {
			idev = i / 100
			if ( idev != dev )
				continue
			if ( ! ( i in nowdown ) ) {
				arr = Fing_down[i]
				delete Fing_down[i]
				for ( obj in Gesturein ) {
					t = Gesturein[obj]
					if ( typeof(t) != "array" )
						continue
					xf = arr["x"]
					yf = arr["y"]
					prox = arr["proximity"]
					f = i % 100
					r = integer(t["r"] * yf)
					c = integer(t["c"] * xf)
					if ( Gesturedebug )
						print("FINGERUP xy=",xf,yf," f=",f," dev=",dev," i=",i," rc=",r,c)
					tt = task obj.gotgesturerc("fingerup",dev,f,r,c,0.0,xf,yf)
					wait(tt)
					
				}
				# delete Fing_down[i]
			}
		}
		for ( n=0; n<nc; n++ ) {
			contact = d[n]
			if ( typeof(contact) != "array" ) {
				print("Hey, d[n=",n,"]=",contact," is not an array?")
				continue
			}
			finger = contact["finger"]
			if ( finger == 0 )
				continue
			if ( contact["proximity"] < GestureProximityThreshold )
				continue

			# print("CONTACT = ",contact," wid=",wid," hgt=",hgt)

			xf = contact["x"] / wid
			yf = contact["y"] / hgt
			proxf = contact["proximity"]
			fval = finger + dev*100
			if ( fval in Fing_down ) {
				oldxf = Fing_down[fval]["x"]
				oldyf = Fing_down[fval]["y"]
				dxf = abs(oldxf - xf)
				dyf = abs(oldyf - yf)
				dist = sqrt((dxf*dxf)+(dyf*dyf))
				dprox = abs(Fing_down[fval]["prox"]-proxf)
				if ( dist > Gesturedragthreshold || dprox > Gestureproximitydragthreshold ) {
					if ( Gesturedebug )
						print("FINGERDRAG xy=",xf,yf," f=",finger," dev=",dev," i=",i)
					# print("dragged finger=",finger," Fing_down=",Fing_down[fval]," contact=",contact)
					if ( fifosize(gf) < GestureDraglimit ) {
						togesturein("fingerdrag",xf,yf,contact,dev,finger)
					} else {
						# if ( Gesturedebug )
						print("overflow gf=",fifosize(gf)," skipping fingerdrag callback")
					}
					Fing_down[fval] = ["x"=xf,"y"=yf,"prox"=proxf]
				}
				continue
			}
			Fing_down[fval] = ["x"=xf,"y"=yf,"prox"=proxf]
			togesturein("fingerdown",xf,yf,contact,dev,finger)
		}
	}
}

function togesturein(gtype,xf,yf,contact,dev,finger) {
	for ( obj in Gesturein ) {
		t = Gesturein[obj]
		if ( typeof(t) != "array" )
			continue
		r = integer(t["r"] * yf)
		c = integer(t["c"] * xf)
		prox = contact["proximity"]
		if ( Gesturedebug )
			print("FINGER type=",gtype," xy=",xf,yf," rc=",r,c," finger=",finger," d=",dev," prox=",prox)
		tt = task obj.gotgesturerc(gtype,dev,finger,r,c,prox,xf,yf)
		wait(tt)
	}
}

function gesturemon(verbose,full) {
	if ( nargs() < 1 )
		verbose = 0
	if ( nargs() < 2 ) {
		full = 0
	}
	print(mdep("gesture","devices"))
	g = new gesturemon_obj(verbose,full)
	gesturenotify(g)
	Root.waitforconsolekey()
	gestureunnotify(g)
	deleteobject(g)
}
function gesturemonrc(r,c,verbose,full) {
	if ( nargs() < 2 ) {
		r = 8
		c = 8
	}
	if ( nargs() < 3 ) {
		verbose = 0
	}
	if ( nargs() < 4 ) {
		full = 0
	}
	print(mdep("gesture","devices"))
	g = new gesturemon_obj(verbose,full)
	gesturenotifyrc(g,r,c)
	Root.waitforconsolekey()
	gestureunnotify(g)
	deleteobject(g)
}

class gesturemon_obj {
	method init(verbose,full) {
		if ( nargs() < 1 )
			verbose = 1
		if ( nargs() < 2 )
			full = 0
		$.verbose = verbose
		$.full = full
		$.lastx = 0.0
		$.lastp = 0.0
		$.tm0 = milliclock()
		$.icount = 0
	}
	method gotgesture(d) {
		if ( $.verbose == 3 ) {
			# print("gesture 2 raw =",d)
			tm1 = milliclock()
			$.icount++
			if ( (tm1 - $.tm0) > 1000 ) {
				$.tm0 = tm1
				print("Got ",$.icount)
				$.icount = 0
			}
			return()
		}
		if ( $.verbose == 2 ) {
			for ( c in d ) {
				cn = integer(c)
				if ( ! defined(cn) )
					continue
				dcn = d[cn]
				x=dcn["x"]
				p=dcn["proximity"]
				dx = x - $.lastx
				dp = p - $.lastp
				print("x=",x," prox=",p," dx=",dx," dp=",dp)
				$.lastx = x
				$.lastp = p
			}
			return()
		}
		if ( $.verbose == 1 ) {
			print("gesture raw =",d)
			return()
		}

		for ( c in d ) {
			cn = integer(c)
			if ( ! defined(cn) )
				continue
			printf("contact cn="+string(cn))
			printf(" d="+string(d["device"]))
			printf(" h="+string(d[cn]["hand"]))
			printf(" f="+string(d[cn]["finger"]))
			printf(" x="+string(d[cn]["x"]))
			printf(" y="+string(d[cn]["y"]))
			printf("\n")
		}
	}
	method gotgesturerc(type,dev,f,r,c,prox,rawx,rawy) {
		print("gesture ",type," dev=",dev," f=",f," prox=",prox," rc=",r,c," rawx=",rawx," rawy=",rawy)
		arr = gesturestatus()
		msg = [0="/fingerstatus"]
		i = 1
		for ( fid in arr ) {
			n = fid % 100
			msg[i++] = float(fid % 100)
			msg[i++] = arr[fid]["x"]
			msg[i++] = arr[fid]["y"]
			msg[i++] = arr[fid]["prox"]
		}
		print("msg=",msg)
	}
}
function beam_send(msg) {
	osc_send(msg,"127.0.0.1",12345)
}
function gesturebeam(verbose,full) {
	if ( nargs() < 1 )
		verbose = 0
	if ( nargs() < 2 ) {
		full = 0
	}

	Gesturedragthreshold = 0.002
	Gestureproximitydragthreshold = 0.01
	GestureProximityThreshold = 0.1

	print(mdep("gesture","devices"))
	g = new gesturebeam_obj(verbose,full)
	gesturenotifyrc(g,8,8)
	c = ""
	while ( c != "q" ) {
		c = Root.waitforconsolekey()
		print("C = ",c)
		if ( c == "c" )
			beam_send([0="/beam/clear"])
		else if ( c == "r" )
			beam_send([0="/beam/run"])
		else if ( c == "s" )
			beam_send([0="/beam/stop"])
		else if ( c == "l" )
			beam_send([0="/beam/list"])
		else if ( c == "1" )
			beam_send([0="/beam/square",1="x=0.5",2="y=0.5"])
	}
	gestureunnotify(g)
	deleteobject(g)

}
class gesturebeam_obj {
	method init(verbose,full) {
		$.verbose = verbose
		$.full = full
		$.lastx = 0.0
		$.lastp = 0.0
		$.tm0 = milliclock()
		$.icount = 0
	}
	method gotgesturerc(type,dev,f,r,c,prox,rawx,rawy) {
		# print("gesturebeam ",type," dev=",dev," f=",f," prox=",prox," rc=",r,c," rawx=",rawx," rawy=",rawy)
		i = 0
		msg = []
		msg[i++] = "/"+type
		msg[i++] = integer(f)
		msg[i++] = rawx
		msg[i++] = rawy
		msg[i++] = prox
		# print("msg=",msg)
		osc_send(msg,"127.0.0.1",12345)
	}
}
function task_gesturemon() {
	f = gesturefifo()
	gestureclear()
	while ( fifosize(f) > 0 )
		get(f)
	while (1) {
		d = get(f)
		print(d)
	}
}

function gplay() {
	print("Play away...")
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
	while (1) {
		d = get(f)
		nc = d["contacts"]
		if ( initialized == 0 ) {
			if ( nc > limit ) {
				continue
			}
			initialized = 1
		}
		# print(d)
		dev = d["device"]
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
		for ( n=0; n<nc; n++ ) {
			dd = d[n]
			x = dd["x"]
			y = dd["y"]
			# xp = integer( 5 * dd["proximity"] + ( 128 * x / wid) )
			xp = integer(128 * dd["x"] / wid)
			yp = integer(128 * y / hgt)
			nt = makenote(xp,1b/4,yp,GestureGrabChan)
			print("(",xp,",",dd["proximity"],dd["finger"],") nt=",nt)
			realtime(nt)
		}
	}
}

function gscale(...) {
	t = task task_gscale(...)
	Root.waitforconsolekey()
	print("GOT CONSOLE KEY, killing gscale...")
	kill(t)
	realtime(ano())
}

function task_gscale(key,scalename) {
	if ( nargs() < 2 ) {
		scalename = "newage"
	}
	if ( nargs() < 1 ) {
		key = 'c'
	}
	print("Play away...")
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
	mdep("gesture","clear")
	sc = completescale(key,scalename)
	scsize = sizeof(sc)
	curry = 0
	print("sc=",sc)
	fing_down = []
	fing_currx = []
	fing_scpos = []
	ndown = 0
	lastfingerdown = -1
	lastxdown = 64
	lastscpos = scsize/2
	while (1) {
		d = get(f)
		nc = d["contacts"]
		# print(d)
		dev = d["device"]
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
		# see what's down now
		nowdown = []
		for ( n=0; n<nc; n++ ) {
			contact = d[n]
			finger = contact["finger"]
			# print("contact=",contact)
			if ( finger == 0 )
				continue
			nowdown[finger] = 1
		}
		# Update down, do noteoff for anything that's no longer down
		for ( i in fing_down ) {
			if ( ! ( i in nowdown ) ) {
				# print("finger i=",i," no longer down")
				nt = fing_down[i]
				nt.type = NOTEOFF
				print("Now=",Now," OFF finger=",i," pitch=",nt.pitch," nt=",nt)
				nt.time = 0
				realtime(nt)
				delete fing_down[i]
				delete fing_currx[i]
				delete fing_scpos[i]
				if ( lastfingerdown == i ) {
					if ( sizeof(fing_down) == 0 )
						lastfingerdown = -1
					else {
						for ( ff in fing_down ) {
							lastfingerdown = ff
							break
						}
					}
				}
			}
		}
		for ( n=0; n<nc; n++ ) {
			contact = d[n]
			finger = contact["finger"]
			if ( finger == 0 )
				continue
			if ( contact["proximity"] < GestureProximityThreshold )
				continue
			# print("contact=",contact)

			x = integer((128 * contact["x"]) / wid)
			if ( finger in fing_down ) {
				# If last finger down moves, update currx
				if ( lastfingerdown == finger ) {
					fing_currx[finger] = x
					lastxdown = x
				}
				continue
			}
			print("")
			if ( sizeof(fing_down) == 0 ) {
				print("First finger, nothing done... x=",x)
				scpos = lastscpos
				currx = lastxdown
				lastfingerdown = finger
			} else {
				scpos = fing_scpos[lastfingerdown]
				currx = fing_currx[lastfingerdown]
				print("finger ",finger," went down x=",x," last currx = ",currx," last scpos=",scpos," for lsatfinger=",lastfingerdown)
			}
			if ( x > currx ) {
				dx = x - currx
				dc = integer(dx/12)
				print("dc=",dc," dx=",dx)
				nscpos = scpos+dc
			}
			else if ( x < currx ) {
				dx = currx - x
				dc = integer(dx/12)
				print("dc=",dc," dx=",dx)
				nscpos = scpos-dc
			}
			if ( dc == 0 ) {
				print("finger=",finger," dc==0, NO CHANGE, no update to scpos or currx")
			}
			if ( ! ( nscpos < 1 || nscpos > scsize ) ) {
				scpos = nscpos
			}
			nt = sc%scpos
			for ( ff in fing_down ) {
				if ( nt.pitch == fing_down[ff].pitch ) {
					print("Duplicate pitch ?  nt.pitch=",nt.pitch)
					# nt = ''
					break
				}
			}
			if ( nt == '' )
				continue
			nt = makenote(nt.pitch,1b/4,100)
			nt.type = NOTEON
			nt.time = nextquant(Now,1b/4) - Now
			print("Now=",Now," ON finger=",finger," pitch=",nt.pitch,"  nt=",nt)
			realtime(nt)
			fing_down[finger] = nt
			fing_scpos[finger] = scpos
			fing_currx[finger] = x
			lastxdown = x
			lastscpos = scpos
			lastfingerdown = finger
		}
	}
}

function glinn(...) {
	t = task task_glinn(...)
	Root.waitforconsolekey()
	print("GOT CONSOLE KEY, killing gscale...")
	kill(t)
	realtime(ano())
}

function task_glinn(key,scalename) {
	if ( nargs() < 2 ) {
		scalename = "newage"
	}
	if ( nargs() < 1 ) {
		key = 'c'
	}
	print("Play away...")
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
	mdep("gesture","clear")
	sc = completescale(key,scalename)
	scsize = sizeof(sc)
	curry = 0
	print("sc=",sc)
	fing_down = []
	fing_prox = []
	ndown = 0
	while (1) {
		d = get(f)
		nc = d["contacts"]
		# print(d)
		dev = d["device"]
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
		# see what's down now
		nowdown = []
		for ( n=0; n<nc; n++ ) {
			contact = d[n]
			finger = contact["finger"]
			# print("contact=",contact)
			if ( finger == 0 )
				continue
			nowdown[finger] = 1
		}
		# Update down, do noteoff for anything that's no longer down
		for ( i in fing_down ) {
			if ( ! ( i in nowdown ) ) {
				# print("finger i=",i," no longer down")
				nt = fing_down[i]
				nt.type = NOTEOFF
				print("Now=",Now," OFF finger=",i," pitch=",nt.pitch," nt=",nt)
				nt.time = 0
				realtime(nt)
				delete fing_down[i]
				delete fing_prox[i]
			}
		}
		for ( n=0; n<nc; n++ ) {
			contact = d[n]
			finger = contact["finger"]
			if ( finger == 0 )
				continue
			prox = contact["proximity"]
			if ( prox < GestureProximityThreshold )
				continue
			if ( finger in fing_down ) {
				print("Already down, finger=",finger," prox=",prox)
				dprox = prox - fing_prox[finger]
				fing_prox[finger] = prox
				continue
			}
			# print("contact=",contact)

			x = integer((128 * contact["x"]) / wid)
			nt = 'a'
			nt = makenote(nt.pitch,1b/4,100)
			nt.type = NOTEON
			nt.time = 0
			realtime(nt)
			fing_down[finger] = nt
			fing_prox[finger] = prox
			print("FINGER DOWN =",finger," nt=",nt," prox=",prox)
		}
	}
}

function ggrab(...) {
	t = task task_ggrab(...)
	Root.waitforconsolekey()
	print("GOT CONSOLE KEY, killing ggrab...")
	kill(t)
	realtime(ano())
	f = open("last.kg","w")
	put(f,"Ggrab=")
	put(f,Ggrab)
	close(f)
}

function task_ggrab() {
	Ggrab = []
	print("Grab away...")
	a = mdep("gesture","devices")
	width = []
	height = []
	for ( i in a ) {
		width[i] = a[i]["width"]
		height[i] = a[i]["height"]
	}
	f = gesturefifo()
	mdep("gesture","clear")
	curry = 0
	fing_down = []
	fing_currx = []
	ndown = 0
	lastfingerdown = -1
	lastxdown = 64
	while (1) {
		d = get(f)
		nc = d["contacts"]
		# print(d)
		dev = d["device"]
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
		# see what's down now
		nowdown = []
		for ( n=0; n<nc; n++ ) {
			contact = d[n]
			finger = contact["finger"]
			# print("contact=",contact)
			if ( finger == 0 )
				continue
			nowdown[finger] = 1
		}
		# Update down, do noteoff for anything that's no longer down
		for ( i in fing_down ) {
			if ( ! ( i in nowdown ) ) {
				print("Now=",Now," OFF finger=",i)
				delete fing_down[i]
			}
		}
		for ( n=0; n<nc; n++ ) {
			contact = d[n]
			finger = contact["finger"]
			if ( finger == 0 )
				continue
			if ( contact["proximity"] < GestureProximityThreshold )
				continue
			# print("contact=",contact)

			x = integer((128 * contact["x"]) / wid)
			y = integer((128 * contact["y"]) / hgt)
			if ( finger in fing_down ) {
				continue
			}
			fing_down[finger] = 1
			ng = sizeof(Ggrab)
			p = lastnotechord()
			p = strip(p)
			Ggrab[ng] = ["x"=x,"y"=y,"p"=p]
			print("ng=",ng," Grab=",Ggrab[ng])
		}
	}
}

function ggrabset(p,gsize,delta,onstarts) {
	if ( nargs() < 2 )
		gsize = 32
	if ( nargs() < 3 )
		delta = 1b
	if ( nargs() < 4 )
		onstarts = 1
	p = onlynotes(p)
	if ( onstarts )
		arr = splitonstarts(p,delta,3)
	else
		arr = spliteven(p,delta)
	for ( i in arr ) {
		arr[i] = strip(arr[i])
	}
	pn=0
	arrsize = sizeof(arr)
	if ( arrsize == 0 ) {
		print("No phrase?")
		return()
	}
	Ggrab = []
	dx = 128 / gsize
	dy = 128 / gsize
	for ( x=0; x<128; x++) {
		Ggrab[x] = []
		for ( y=0; y<128; y++ ) {
			p = ''
			limit = 0
			while ( p == '' && limit++ < 100 ) {
				if ( pn >= arrsize )
					pn = 0
				p = arr[pn++]
			}
			Ggrab[x][y] = p
		}
	}
}
function ggrabplay(sz) {
	if ( nargs() < 1 )
		sz = 16
	t = new ggrabplay_obj(sz,sz)
	Root.waitforconsolekey()
	print("GOT CONSOLE KEY, killing ggrabplay...")
	deleteobject(t)
	realtime(ano())
}

class ggrabplay_obj {

method init(r,c) {
	$.fing_down = []
	$.fing_tm = []
	$.min_time = GestureGrabMinTime
	$.lastfingerdown = -1
	if ( nargs() > 0 ) {
		$.nrows = r
		$.ncols = c
	} else {
		$.nrows = 16
		$.ncols = 16
	}
	gesturenotifyrc($,$.nrows,$.ncols)
	print("Play away...")
}
method delete {
	gestureunnotify($)
}

method gotgesturerc(type,dev,finger,r,c,prox) {
	i = 100 * dev + finger
	if ( Gesturedebug )
		print("type=",type," i=",i)
	if ( type == "fingerup" ) {
		if ( ! ( i in $.fing_down ) ) {
			print("i=",i," not in fing_down?")
			return()
		}
		p = $.fing_down[i]
		p.type = NOTEOFF
		t = $.fing_tm[i]
		# print("Now=",Now," OFF finger=",i," p=",p)
		if ( Now < (t+$.min_time) ) {
			# print("adding min_time")
			p.time += $.min_time
		} else {
			t = Now
			p.time += (Now - t) + 2
		}
		realtime(p,0)
		# print("p=",p)
		delete $.fing_down[i]
		delete $.fing_tm[i]
	} else if ( type == "fingerdown" ) {
		r = r % ($.nrows)
		c = c % ($.ncols)
		if ( ! ( c in Ggrab ) || ! ( r in Ggrab[c] ) ) {
			if ( Gesturedebug ) {
				print("Ggrab c=",c," r=",r," doesn't exist")
				return()
			}
		}
		p = Ggrab[c][r]
		p.type = NOTEON
		if ( prox > 4.0 )
			p.vol += 60
		else if ( prox > 3.0 )
			p.vol += 40
		else if ( prox > 2.0 )
			p.vol += 20
		else if ( prox < 1.0 )
			p.vol -= 20
		t = nextquant(Now,GestureQuant)
		p.time += t
		realtime(p,0)
		# print("p=",p)
		$.fing_down[i] = p
		$.fing_tm[i] = t
	}
}
}

function ginterval(...) {
	t = task task_ginterval(...)
	Root.waitforconsolekey()
	kill(t)
	realtime(ano())
}
function task_ginterval(key,scalename) {
	if ( nargs() < 2 ) {
		scalename = "newage"
	}
	if ( nargs() < 1 ) {
		key = 'c'
	}
	print("Play away...")
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
	sc = completescale(key,scalename)
	scsize = sizeof(sc)
	curr = sizeof(sc)/2
	currx = 0
	curry = 0
	print("sc=",sc)
	print("curr nt = ",sc%curr)
	down = []
	for ( n=0; n<10; n++ ) {
		down[n] = 0
		# currx[n] = 0
	}
	ndown = 0
	while (1) {
		d = get(f)
		nc = d["contacts"]
		if ( initialized == 0 ) {
			if ( nc > limit ) {
				continue
			}
			initialized = 1
		}
		# print(d)
		dev = d["device"]
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
		for ( n=0; n<nc; n++ ) {
			contact = d[n]
			x = integer((128 * contact["x"]) / wid)
			if ( currx == x )
				continue
			print("x=",x)
			if ( x > currx ) {
				dx = x - currx
				dc = integer(dx/12)
				print("dc=",dc," dx=",dx)
				ncurr = curr+dc
			}
			else if ( x < currx ) {
				dx = currx - x
				dc = integer(dx/12)
				print("dc=",dc," dx=",dx)
				ncurr = curr-dc
			}
			if ( ncurr < 1 || ncurr > scsize ) {
				# do nothing
			} else {
				curr = ncurr
			}
			currx = x
			nt = sc%curr
			nt = makenote(nt.pitch,1b/4,100)
			print("nt=",nt)
			realtime(nt)
		}
	}
}

function gdrum_task() {
	tm = Now+1b
	cnt = 0
	while (1) {
		sleeptill(tm)
		tm += 1b/4
	}
}
function gdrum() {
	Gpitch=[0=40,1=41,2=42,3=43]
	Gcol=[0=0,1=0,2=0,3=0]
	Gstart=[0=0,1=0,2=0,3=0]
	print("Play away...")
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
	while (1) {
		d = get(f)
		nc = d["contacts"]
		if ( initialized == 0 ) {
			if ( nc > limit ) {
				continue
			}
			initialized = 1
		}
		# print(d)
		dev = d["device"]
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
		for ( n=0; n<nc; n++ ) {
			dd = d[n]
			x = dd["x"]
			y = dd["y"]
			row = integer(5 * y / hgt)
			xp = integer( 5 * dd["proximity"] + ( 128 * x / wid) )
			yp = integer(128 * y / hgt)
			print("(",xp,",",dd["proximity"],dd["finger"],")")
			nt = makenote(xp,1b/4,yp,dd["finger"])
			realtime(nt)
		}
	}
}

function ggrabdemo5(stepit) {
	a = completescale('c',"newage")
	a = step(a,1b/4)
	a.chan = GestureGrabChan
	a.vol -= 20
	if ( nargs() < 1 )
		stepit = 1b/2
	a = step(a,stepit)
	Ggrabphrase = a
	Ggrabstepit = stepit
	sz = 8
	ggrabset(a,sz,stepit)
	ggrabplay(sz)
}
function ggrabdemo4(stepit) {
	a = readmf("jsbach.mid")
	a = scadjust(a,makescale(scalenamed("newage")))
	a.chan = GestureGrabChan
	a.vol -= 20
	if ( nargs() > 0 )
		a = step(a,stepit)
	ggrabset(a,8,1b)
	ggrabplay(8)
}
function ggrabdemo3() {
	a = readmf("prelude.mid")
	a.chan = GestureGrabChan
	ggrabset(a,16,1b)
	ggrabplay()
}
function ggrabdemo2() {
	a = readmf("c:\\local\\midi\\tjt\\state.mid")
	a = a - a{??.chan==10}
	a.chan = GestureGrabChan
	ggrabset(a,16,1b/2)
	ggrabplay()
}
function ggrabdemo1() {
	a = readmf("c:\\local\\midi\\tjt\\autograp.mid")
	a = a - a{??.chan==10}
	a.chan = GestureGrabChan
	ggrabset(a,16,1b)
	ggrabplay()
}
