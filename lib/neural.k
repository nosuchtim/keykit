#
# ergox_neural - playing with letters and fingers
#

#define xx eval "#include neural.k"
#define yy neural()

INCDEC_MID = 0
INCDEC_MIN = -2
INCDEC_MAX = 2
INCDEC_INC = 1
INCDEC_DEC = -1
TypoDebug = 0
DebugOsc = 1
LcdDebug = 0

#define xxx rereadlib();bbq()

function neural() {

	if ( ! defined(Osclisten) ) {
		Osclisten = 1384
	}

	# if ( ! defined(CherryControl) ) {
	# 	print("Hey, CherryControl not defined!")
	# 	return()
	# }

	tempo(500000)

	if ( Machine != "win" ) {
		print("ergox_neural() only works on Windows, sorry!")
		return()
	}

	if ( ! defined(SalvationOutput) ) {
		SalvationOutput = -1
	}

	global GestureDevMap
	GestureDevMap = []

	print("Setting dragthreshold to 0...")
	Gesturedragthreshold = 0.0
	GestureDraglimit = 60

	patchprefix = "patch"

	t = new ergox_neural_mastertypo(patchprefix)
	t.waittilldone()
	t.stop()
}

class ergox_neural_mastertypo {

method init(patchprefix) {

	$.oldMerge = Merge
	Merge = 0

	$.initdone = 0
	$.dir = "."

	$.anycherry = 0

	$.fneural = -1
	$.fneural = open("999@127.0.0.1","wb","osc_send")

	$.dragisdown = 1
	$.stopme = 0
	$.ignore_up = [0=0,1=0]
	$.refresh_on_up = [0=0,1=0]

	$.gesturepads = 1

	$.finger_does_graphics = 1

	# $.chord = 'c'
	# $.curr_scale = completescalephrase($.chord)
	# $.nextchord = ''

	$.vidmode = 0
	$.selectA = 1
	$.selectB = 2

	$.gridrows = 3
	$.gridcols = 3

	$.gridrows = 20
	$.gridcols = 20

	$.gridrows = 7
	$.gridcols = 20

	$.nphrases = $.gridrows * $.gridcols

	$.quit = 0
	$.debug = 0
	$.lasttouchwarn = 0

	$.fifos = []

	$.charproc = 0
	$.ignorenextup = 0
	$.ctrl = 0

	$.currpad = 0

	$.lastvol = []
	$.lastprox = []

	$.finger2osc = ["fingerup"="/touchup","fingerdown"="/touchdown","fingerdrag"="/touchdrag"]
	$.oscclients = []
	$.oscf = open(string(Osclisten)+"@127.0.0.1","rA","osc_listen")
	if ( $.oscf < 0 ) {
		print("Unable to listen on ",Osclisten," !?")
		$.osctid = -1
	} else {
		$.osctid = task $.osctask()
	}

	$.reset()

	Consecho = 0
	Consupdown = 1
	$.constid = task $.cons_task()

	if ( gesturedevices() == 0 ) {
		print("Warning, no gesture pads are connected!")
	} else {
		gestureclear()
		gesturenotifyrc($,$.gridrows,$.gridcols)
	}

	print("Please touch iGesture pad #1")
	tenth = milliclicks(1000)
	while ( sizeof(GestureDevMap) < 1 ) {
		sleeptill(Now+tenth)
	}
	if ( $.gesturepads > 1 ) {
		print("Please touch iGesture pad #2")
		while ( sizeof(GestureDevMap) < 2 ) {
			sleeptill(Now+tenth)
		}
	}
	$.initdone = 1
}

method osctask() {
	while ( (d=get($.oscf)) != Eof ) {

		if ( $.initdone == 0 ) {
			print("Ignoring osc messages till initdone...")
			continue
		}

		# print("osctask got d=",d)
		addr = d[0]
		if ( addr == "/registerclient" ) {
			$.registerclient(d[1],d[2])
		} else if ( addr == "/unregisterclient" ) {
			$.registerclient(d[1],d[2])
		} else if ( addr == "/collision" ) {
			scaledx = d[5]
			scaledy = d[6]
			chan1 = d[7]
			chan2 = d[8]
			radius1 = d[9]
			radius2 = d[10]
			# print("/COLLISION chan1=",chan1," chan2=",chan2)
			p = $.collision_note(scaledx,scaledy,chan1,chan2,radius1,radius2)
			q = $.val2quant($.CollQnt)
			tm = nextquant(Now,q)
			$.realtime(p,tm)
		} else {
			print("osctask got d=",d)
		}
	}
}

method registerclient(host,port) {
	portaddr = string(port)+"@"+host
	for ( f2 in $.oscclients ) {
		if ( $.oscclients[f2] == portaddr ) {
			# print("Already registered, ignoring re-register")
			return()
		}
	}
	f = open(portaddr,"wb","osc_send")
	$.oscclients[f] = portaddr
	print("OSC CLIENT REGISTERED! portaddr=",portaddr)
	print("NOT DOING RESET!")
	# $.reset()
}

method sendneural(msg) {
	if ( $.fneural >= 0 ) {
		print("SENDING to nueral, msg=",msg)
		mdep("osc","send",$.fneural,msg)
	} else {
		print("No neural connection!")
	}
}

method sendosc(msg) {
	for ( f in $.oscclients ) {
		if ( DebugOsc > 1 )
			print("Sending msg=",msg," to oscclient f=",f)
		mdep("osc","send",f,msg)

		# m2 = [0="/setimagedecay",1=0.9]
		# if ( DebugOsc )
		# 	print("Sending m2=",m2," to oscclient f=",f)
		# mdep("osc","send",f,m2)
	}
}

method waittilldone {
	wait($.constid)
}

method stop {
	if ( gesturedevices() != 0 ) {
		gestureunnotify($)
	}
	$.stopme = 1
	kill($.constid)
	kill($.osctid)
	print("Closing oscf=",$.oscf)
	close($.oscf)
	for ( f in $.oscclients ) {
		close(f)
	}

	Typos = -1
	if ( $.consf >= 0 ) {
		Consupdown = 0
		Consecho = 1
		Root.releaseconsole()
	}
	Merge = $.oldMerge
}

method cons_task() {
	$.consf = Root.grabconsole()
	global ergox_neural_resetconsole
	onexit(ergox_neural_resetconsole,$)
	while ( $.quit == 0 && (c=get($.consf)) != Eof ) {
		if ( c == "-ESC" ) {
			return()
		}
	}
}

method gotgesturerc(t,d,f,r,c,prox,rawx,rawy) {
	# print("gotgesturerc rc=",r,c," prox=",prox)
	if ( ! (d in GestureDevMap) && t == "fingerup" ) {
		n = sizeof(GestureDevMap)
		GestureDevMap[d] = n
		# print("GESTUREDEVMAP of d=",d," is now ",n)
	}
	if ( $.initdone == 0 ) {
		print("Waiting for all pads to be touched...")
		return()
	}
	
	d = GestureDevMap[d]
	arr = ["type"=t,"row"=r,"col"=c,"prox"=prox,"device"=d,"finger"=f]
	# print("got arr=",arr)

	$.handle_finger(t,r,c,prox,d,f,rawx,rawy)
}

method reset() {
	$.prox_max = 4.0
	$.prox_min = 1.0
	$.expert_mode = 0
}

method fingeruid(pad,finger) {
	return( pad * 100 + finger )
}
				
method realtime(p,tm) {
	print("REALTIME A p=",p," tm=",tm)
	realtime(p,tm)
}
method map_prox(prox) {
	if ( prox > $.prox_max )
		prox = $.prox_max
	prox = prox - $.prox_min
	return ( prox / ($.prox_max-$.prox_min))
}
method randomall(x,y) {
	print("RANDOMALL!! x=",x," y=",y)
	for ( i=0; i<8; i++ ) {
		for ( k=0; k<8; k++ ) {
			f = (rand(1000)/500.0) - 1.0
			msg = [0=sprintf("/control/%d/feedback",i),1=k,2=f]
			$.sendneural(msg)
		}

		freq = 5000.0 * rand(1000)/1000.0
		freq *= x
		msg = [0=sprintf("/oscil/%d/freq",i),1=freq]
		$.sendneural(msg)
	}
}
method handle_finger(ft,row,col,prox,padi,finger,rawx,rawy) {

	fid = $.fingeruid(padi,finger)
	orient = 0.0
	eccent = 0.0
	xvel = 0.0
	yvel = 0.0

	osc1 = ( rawx / 0.125 ) % 8
	osc2 = ( rawy / 0.125 ) % 8
	amp = rawx
	amp = prox / 2.0
	amp -= 1.0
	freq = prox * 1000.0

	print("ft=",ft)
	if ( ft == "fingerdown" ) {
		fi = fid % 4
		msg = [0=sprintf("/control/%d/start",fi)]
		$.sendneural(msg)

		$.randomall(rawx,rawy)


	} else if ( ft == "fingerdrag" ) {

		# fid = rand(10)
		# fi = fid % 4
		# msg = [0=sprintf("/control/%d/start",fi)]
		# $.sendneural(msg)

		# ray = (prox * 10.0) - 5.0
		# msg = [0=sprintf("/oscil/%d/rayleigh",osc1),1=ray]
		# $.sendneural(msg)

		msg = [0=sprintf("/oscil/%d/feedback",osc1),1=osc2,2=amp]
		$.sendneural(msg)

		# msg = [0=sprintf("/oscil/%d/freq",osc1),1=freq]
		# $.sendneural(msg)
	}
	return()
}

method ctrl_exec(c,nw) {
	if ( c == "Q" ) {
		print("NOT saving patches...")
		$.quit = 1
	} else if ( c == "V" ) {
		$.verbose = 1 - $.verbose
	}
}

}



function ergox_neural_resetconsole(o) {
	o.stop()
}

