#
# ergox_nslooperb
#

#define xx eval "#include nslooperb.k"
#define yy nslooperb()

INCDEC_MID = 0
INCDEC_MIN = -2
INCDEC_MAX = 2
INCDEC_INC = 1
INCDEC_DEC = -1
DebugOsc = 1
LcdDebug = 0

#define xxx rereadlib();nslooperb()

function nslooperb() {
	if ( SalvationOutput <= 0 ) {
		print("Hey, SalvationOutput needs to be set")
		return()
	}
	o = new nslooperobj()
	while (1) {
		c = Root.waitforconsolekey()
		if ( ascii(c) == 27 ) {
			break
		}
		print("ignoring c=",c)
	}
	deleteobject(o)
}

class nslooperobj {
method init {
	$.looperport = 8888
	$.looper = open(string($.looperport)+"@127.0.0.1","wb","osc_send")
	$.j = getjoymonitor()
	$.arr = joyinit()
	for ( jn in $.arr ) {
		$.j.notify($,jn)
	}
	$.randomizing = 0
	$.currloop = 0
	$.midval = 32767
	$.isplaying = [0=0,1=0,2=0,3=0]
}
method delete {
	for ( jn in $.arr ) {
		$.j.unnotify($,jn)
	}
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
			$.randomizing = 1 - $.randomizing
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
		mdep("osc","send",$.looper,m)
	}
}
}
