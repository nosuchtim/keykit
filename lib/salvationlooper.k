#
# ergox_salvationlooper
#

#define xx eval "#include salvationlooper.k"
#define yy salvationlooper()

INCDEC_MID = 0
INCDEC_MIN = -2
INCDEC_MAX = 2
INCDEC_INC = 1
INCDEC_DEC = -1
DebugOsc = 1
LcdDebug = 0

#define xxx rereadlib();salvationlooper()

function salvationlooper() {
	sleeptill(Now+4b)
	print("STARTING ATA LOOPER...")
	if ( SalvationOutput <= 0 ) {
		print("Hey, SalvationOutput needs to be set")
		return()
	}
	o = new salvationlooperobj()
	while (1) {
		c = Root.waitforconsolekey()
		if ( ascii(c) == 27 ) {
			break
		}
		print("ignoring c=",c)
	}
	deleteobject(o)
}

class salvationlooperobj {
method init {
	$.looperport = 8888
	$.looper = open(string($.looperport)+"@127.0.0.1","wb","osc_send")
	$.j = getjoymonitor()
	$.arr = joyinit()
	for ( jn in $.arr ) {
		$.j.notify($,jn)
	}
	$.lastosc = 0
	$.randomizing = 0
	$.currloop = 0
	$.midval = 32767
	$.isplaying = [0=0,1=0,2=0,3=0]

	m = [0="/looper/displayquadrants",1=1]
	$.sendosc(m)
	for ( loop=0; loop<4; loop++ ) {
		m = [0="/looper/play",1=loop,2=0]
		$.sendosc(m)
	}

	$.osclistenport = 1337
	s = string($.osclistenport)+"@"+Hostname
	$.oscf = open(s,"rA","osc_listen")
	if ( $.oscf < 0 ) {
		print("Unable to listen on ",Osclisten," !?")
		$.osctid = -1
	} else {
		print("Listening for OSC on ",s," ...")
		$.osctid = task $.osctask()
	}
	$.autotid = task $.autoloop()
}
method recordloop(loopnum,tm) {
	lock($)
	print("RECORDLOOP loopnum=",loopnum," tm=",tm)
	m = [0="/looper/record",1=loopnum,2=1]
	$.sendosc(m)
	sleeptill(Now+tm)
	m = [0="/looper/record",1=loopnum,2=0]
	$.sendosc(m)
	unlock($)
	clicks_to_wait = milliclicks(10 * 1000) # 10 seconds
	if ( $.lastosc > 0 && (Now-$.lastosc) < clicks_to_wait ) {
		print("OSC SEEN!!! waiting for idle time of 10 secs")
		while ( (Now-$.lastosc) < clicks_to_wait ) {
			sleeptill(Now+1b)
		}
		print("IDLE !!! continuing with autoloop")
	}
}
method stoploop(loopnum) {
	m = [0="/looper/play",1=loopnum,2=0]
	$.sendosc(m)
}
method sendosc(m) {
	print("Sending OSC m=",m)
	mdep("osc","send",$.looper,m)
}
method effects(onoff) {
	$.randomizing = onoff
	$.dorandomizing()
}
method quadrants(onoff) {
	m = [0="/looper/displayquadrants",1=(onoff>0)]
	$.sendosc(m)
}
method slowstop() {
	shortdt = 2b
	$.stoploop(3)
	sleeptill(Now+shortdt)
	$.stoploop(2)
	sleeptill(Now+shortdt)
	$.stoploop(1)
	sleeptill(Now+shortdt)
	$.stoploop(0)
	sleeptill(Now+shortdt)
}
method autoloop() {
	dt = 8b
	$.quadrants(1)
	$.effects(0)
	sleeptill(Now+dt)
	while ( 1 ) {

		$.quadrants(1)
		$.effects(0)
		$.recordloop(0,dt)
		$.recordloop(1,dt)
		$.recordloop(2,dt)
		$.recordloop(3,dt)
		sleeptill(Now+2*dt)
		$.quadrants(0)
		sleeptill(Now+2*dt)
		$.quadrants(1)
		sleeptill(Now+2*dt)

		$.slowstop()

		$.quadrants(1)
		$.effects(1)
		$.recordloop(0,dt)
		$.recordloop(1,dt)
		$.recordloop(2,dt)
		$.recordloop(3,dt)
		sleeptill(Now+2*dt)
		$.quadrants(0)
		sleeptill(Now+2*dt)
		$.quadrants(1)
		sleeptill(Now+2*dt)

		$.slowstop()
	}
}
method osctask() {
	while ( (d=get($.oscf)) != Eof ) {

		print("osctask got d=",d)
		addr = d[0]
		v = d[1]
		m = []
		lock($)
		if ( addr ~~ "/mrmr/pushbutton/0/.*" ) {
			$.currloop = 0
			m = [0="/looper/record",1=$.currloop,2=(v>0)]
		} else if ( addr ~~ "/mrmr/pushbutton/1/.*" ) {
			$.currloop = 1
			m = [0="/looper/record",1=$.currloop,2=(v>0)]
		} else if ( addr ~~ "/mrmr/pushbutton/2/.*" ) {
			$.currloop = 3
			m = [0="/looper/record",1=$.currloop,2=(v>0)]
		} else if ( addr ~~ "/mrmr/pushbutton/3/.*" ) {
			$.currloop = 2
			m = [0="/looper/record",1=$.currloop,2=(v>0)]
		} else if ( addr ~~ "/mrmr/pushbutton/4/.*" ) {
			if ( v > 0 ) {
				$.randomizing = 1
			} else {
				$.randomizing = 0
			}
			$.dorandomizing()
		} else if ( addr ~~ "/mrmr/pushbutton/5/.*" ) {
			print("pushbutton 5? v=",v)
			m = [0="/looper/displayquadrants",1=(v==0)]
		}

		if ( sizeof(m) > 0 ) {
			$.sendosc(m)
		}
		$.lastosc = Now
		unlock($)
			
	}
}

method delete {
	for ( jn in $.arr ) {
		$.j.unnotify($,jn)
	}
	close($.oscf)
	close($.looper)
	kill($.autotid)
	kill($.osctid)
}
method analogchange(jn,nm,v) {

	# Control current loop with D-pad

	if ( nm == "Y" && v < $.midval ) {	# up
		$.currloop = 0
	} else if ( nm == "X" && v > $.midval ) {  # right
		$.currloop = 1
	} else if ( nm == "Y" && v > $.midval ) {  # down
		$.currloop = 2
	} else if ( nm == "X" && v < $.midval ) {  # left
		$.currloop = 3
	}
	print("Analogchange, jn=",jn," nm=",nm," v=",v,"  currloop=",$.currloop)
}

method togglerandomizing() {
	$.randomizing = 1 - $.randomizing
	$.dorandomizing()
}

method dorandomizing() {
	p = controller(1,3,127 * $.randomizing)
	p.port = SalvationOutput
	# print("sending to salvation p=",p)
	realtime(p)
	if ( $.randomizing ) {
		print("Randomizing is ON")
	} else {
		print("Randomizing is OFF")
	}
}

method buttonchange(jn,nm,v) {
	m = []
	if ( nm == "R1" ) {
		m = [0="/looper/record",1=$.currloop,2=(v==1)]
	}
	else if ( nm == "R2" ) {
		m = [0="/looper/recordoverlay",1=$.currloop,2=(v==1)]
	}
	else if ( nm == "L1" ) {
		m = [0="/looper/displaytoggle",1=(v==1)]
	}
	else if ( nm == "L2" ) {
		# m = [0="/looper/randomtoggle",1=(v==1)]
		if ( v == 1 ) {
			$.togglerandomizing()

		}
	}
	else if ( nm == "X" ) {
		if ( v > 0 ) {
			m = [0="/looper/truncate",1=$.currloop]
		}
	}
	else if ( nm == "CIRCLE" ) {
		if ( v > 0 ) {
			m = [0="/looper/restart",1=$.currloop]
		}
	}
	else if ( nm == "SQUARE" ) {

		if ( v > 0 ) {
			# start playing
			m = [0="/looper/play",1=$.currloop,2=1]
			$.isplaying[$.currloop] = 1

			# Toggle playing on/off
			# if ( v > 0 ) {
			# 	p = $.isplaying[$.currloop]
			# 	p = 1 - p
			# 	m = [0="/looper/play",1=$.currloop,2=p]
			# 	$.isplaying[$.currloop] = p
		}
	}
	else if ( nm == "TRIANGLE" ) {
		if ( v > 0 ) {
			# stop playing
			m = [0="/looper/play",1=$.currloop,2=0]
			$.isplaying[$.currloop] = 0
		}
	}
	else {
		print("No action for nm=",nm)
	}
	if ( sizeof(m) > 0 ) {
		print("Sending m=",m," to oscclient $.looper=",$.looper)
		$.sendosc(m)
	}
}
}
