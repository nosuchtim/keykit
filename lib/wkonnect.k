class wkonnect {

method init(textonly,dbg,emailto) {

	if ( nargs() < 1 )
		$.textonly = 0
	else
		$.textonly = textonly
	if ( nargs() < 2 )
		$.debug = 0	# default debug level
	else
		$.debug = dbg
	if ( nargs() < 3 )
		$.emailto = ""
	else
		$.emailto = emailto

	$.w = new window()
	$.inherit($.w)

	if ( $.textonly == 0 ) {
		$.consw = new wconsole(-1,nullfunc,1)
		$.addchild($.consw)

		$.f = open()
		$.cmdw = new wconsole($.f,nullfunc,0) # mouse can't scroll this one
		$.i = task konnectinterp($.f, $.cmdw, $)
		$.addchild($.cmdw)

		$.b1 = new kmenubutton("More","mkmenu_konnectmore",$)
		$.b2 = new ktoggle("Send",$,"setcontinuous")
		$.b3 = new ktoggle("Record",$,"setrecord")
		$.addchild($.b1)
		$.addchild($.b2)
		$.addchild($.b3)
	}

	if ( defined(Hostname) ) {
		$.myname = Hostname
	} else {
		$.myname = "127.0.0.1"
		a = mdep("tcpip","localaddresses")
		if ( defined(a) ) {
			if ( typeof(a) == "array" ) {
				if ( 0 in a ) {
					$.myname = a[0]
				}
			}
		}
	}


	$.clients = []
	$.clientoffset = []
	$.realoffset = []
	$.tid_tomaster = -1
	$.tid_listener = -1
	$.continuous = -1
	$.messagelines = 3
	$.ports_tomaster = []
	$.extralag = 3b
	$.extralag2 = 4b
	$.quantguarantee = 4b
	$.continuousstep = 1b
	$.record = 0
	$.nt = 0 		# nt = number of text lines down
	$.sendnextoffset = 0
	$.resized = 0
	$.rebroadcast = 1
	$.master = ""
	$.allowtools = 0

	$.status = "unconnected"

	fifoctl("default","type","l")	# to guarantee that fifos
					# returned by reading listenport
					# are set to "l" from the very start

	$.tid_listener = task $.task_listener()

	Konnect = $

	# Debatable whether it should start out in this mode
	if ( $.textonly == 0 ) {
		Consechoobj = $.cmdw
		Consecho = 0
	}

	if ( defined(KonnectServer) && KonnectServer != "" ) {
		task $.delayedconnect(KonnectServer)
	}
}

method delayedconnect(s) {
	sleeptill(Now+milliclicks(1000))
	$.connect(s)
}

method delete {
	$.disconnect()
}

method resize (sz) {

	if ( nargs() > 0 ) {
		minx1 = $.xmin() + 30*$.textwidth()
		miny1 = $.ymin() + 6*$.textheight() + 4
		if ( sz["y1"] < miny1 )
			sz["y1"] = miny1
		if ( sz["x1"] < minx1 )
			sz["x1"] = minx1
		$.w.resize(sz)
	}

	$.xmid = $.xmin() + ($.xmax() - $.xmin())/3
	$.th = $.textheight()+2
	$.dy0 = $.th+2
	$.dy = 2*$.th+4
	nb = 3
	dx = ($.xmax() - $.xmin())/nb

	$.nt = ($.ymax()-($.ymin()+$.dy))/($.th)

	$.dy2 = ($.ymax()-($.ymin()+$.dy))/$.nt
	$.y0 = $.ymin() + $.dy0
	$.ymid = $.ymin() + $.dy + 4

	$.b1.resize(xy($.xmin()+2,$.y0, $.xmin()+dx,$.y0+2+$.th))
	$.b2.resize(xy($.xmin()+2+1*dx,$.y0, $.xmin()+2*dx,$.y0+2+$.th))
	$.b3.resize(xy($.xmin()+2+2*dx,$.y0, $.xmax()-2,$.y0+2+$.th))

	$.yc = $.ymax()-4-$.th-8
	$.consw.resize(xy($.xmin()+2,$.ymid, $.xmax()-2,$.yc-2))
	$.cmdw.resize(xy($.xmin()+2,$.yc+1, $.xmax()-2,$.ymax()-2))
	$.resized = 1
}

method redraw {
	if ( ! $.resized )
		return()
	$.w.redraw()
	y0 = $.ymin() + $.textheight() + 2
	$.w.textcenter("Konnect",xy($.xmin(),$.ymin(),$.xmax(),y0))
	methodbroadcast()
}

method set(p) {
	if ( $.checkconnected() ) {
		if ( p != '' ) {
			$.toeveryone("broadcastphrase "+string(p)+"\n")
			$.message("Sent "+string(sizeof(p))+" notes...")
		}
	}
}

method setdebug(v) {
	$.debug = v
	$.message("debug set to "+string(v))
}

method settoolbroadcast(v) {
	$.allowtools = v;
}

method setrecord(val) {
	$.record = val
}

method setcontinuous(val) {
	if ( val )
		$.startcontinuous()
	else
		$.stopcontinuous()
	# In case the startcontinuous failed to start it
	if ( $.continuous < 0 ) {
		$.b2.set(0)
		$.b2.redraw()
	}
}

method setconnect(val) {
	if ( ! $.isconnected() ) {
		$.connect()
		if ( ! $.isconnected() ) {
			$.b1.set(0)
			$.b1.redraw()
		}
	}
	else
		$.disconnect()
}

method message(s) {
	if ( $.textonly ) {
		print(s)
	} else {
		$.consw.printf("\n%s",s)
	}
}

method connect(konnect) {
	if ( $.tid_tomaster >= 0 ) {
		$.message("Already connected to a master!")
		return()
	}
	if ( nargs() < 1 ) {
		if ( ! defined(KonnectServer) || KonnectServer == "" ) {
			konnect = getastr("Enter name of a konnect -> ","")
			if ( konnect == "" ) {
				$.message("You must supply a host name.")
				return()
			}
			KonnectServer = konnect
		}
	}
	from = ""
	k = KeyKitRemotePort-1
	for ( i=0; i<12; i++ ) {
		k++
		servicename = string(k) + "@"+string(KonnectServer)
		if ( KonnectServer in $.clientports ) {
			$.message(KonnectServer+" is one of your clients, you can't connect to it.")
			return()
		}
		$.message("Attempting connection to "+servicename)
		ports = open(servicename,"rw","tcpip_connect")
		if ( typeof(ports) != "array" ) {
			$.message("Unable to open servicename="+servicename+" !?")
			continue
		}

		$.ports_tomaster = ports

		put(ports["w"],"mynameis "+$.myname+"\n")
		r = get(ports["r"])
		if ( r == Eof ) {
			$.message("Got early Eof, connection will be closed!")
			close(ports["r"])
			close(ports["w"])
			return()
		}
		if ( r == Interrupt ) {
			$.message("Port"+string(k)+"doesn't answer...")
			continue
		}
		words = split(r)
		if ( words[0] != "mynameis" ) {
			$.message("Didn't get 'mynameis' as first line!?  response="+string(r))
			$.message("Connection will be closed!")
			close(ports["r"])
			close(ports["w"])
			continue
		}
		from = words[1]
		break
	}

	if ( from == "" ) {
		$.message("Unable to connect!")
		return()
	}

	$.message("Connected to "+from+" !")
	$.master = from

	$.tid_tomaster = task $.task_talk_to_master(ports,from)
}

method isconnected {
	if ( $.tid_tomaster >= 0 )
		return(1)
	else if ( sizeof($.clientports) > 0 )
		return(1)
	else
		return(0)
}
method disconnect() {
	if ( ! $.isconnected() ) {
		# $.message("Already disconnected!")
		return()
	}
	if ( $.tid_tomaster >= 0 ) {
		kill($.tid_tomaster)
		$.close_tomaster()
	}
	if ( sizeof($.clientports) > 0 ) {
		for ( nm in $.clientports ) {
			ports = $.clientports[nm]
			close(ports["r"])
			close(ports["w"])
		}
		$.clientports = []
	}
}
method close_tomaster {
	if ( "r" in $.ports_tomaster )
		close($.ports_tomaster["r"])
	if ( "w" in $.ports_tomaster )
		close($.ports_tomaster["w"])
	$.ports_tomaster = []
	$.tid_tomaster = -1
	$.stopmousecontinuous()
}

method checkconnected {
	if ( $.isconnected() )
		return(1)
	else {
		$.message("There are no connections!?")
		return(0)
	}
}
method sendbroadcastmessage(msg) {
	if ( msg != "" ) {
		$.message("["+$.myname+"] "+msg)
		$.toeveryone("broadcasttext "+msg+"\n")
	}
}
method setmyname(po) {
	msg = getastr("My name is -> ","") 
	if ( msg != "" ) {
		$.myname = msg;
	}
}
method sendbroadcastrecorded(space) {
	if ( $.checkconnected() ) {
		p = lastbunch(Recorded,space)
		if ( p != '' )
			$.toeveryone("broadcastphrase "+string(p)+"\n")
	}
}
method sendsnarf() {
	if ( $.checkconnected() ) {
		if ( Snarf != '' )
			$.toeveryone("broadcastphrase "+string(Snarf)+"\n")
	}
}
method stopcontinuous {
	if ( $.continuous < 0 )
		$.message("No continuous broadcast active!?")
	else {
		kill($.continuous)
		$.continous = -1
	}
}
method startcontinuous() {
	if ( $.checkconnected() ) {
		$.continuous = task $.task_continuous()
	}
}

method startmousecontinuous() {
	if ( $.checkconnected() ) {
		Mousebroadcast = $
		Mousemoveevents = 1
	}
}

method mousemessage(m) {
	print("m=",m)
	$.toeveryone("broadcastmouse "+m["type"]+" "+m["button"]+" "+m["x"]+" "+m["y"]+"\n")
}

method stopmousecontinuous() {
	Mousebroadcast = $0
	Mousemoveevents = 0
}

method receivemousecontinuous() {
	$.message("receivemousecontinuous needs work")
}

method sendoffseteverysooften() {
	# broadcast offset every so often
	if ( Now > $.sendnextoffset ) {
		$.sendonebroadcastoffset()
		$.sendnextoffset = Now + 32b
	}
}
method sendphrase(p) {
	$.sendoffseteverysooften()
	$.toeveryone("broadcastphraseoff "+string(p)+"\n")
}
method sendtempo(t) {
	if ( $.continuous >= 0 ) {
		$.toeveryone("broadcasttempo "+string(t)+"\n")
	}
}
method sendkboomcell(sn,dn,dy,cm) {
	$.toeveryone("broadcastkboomcell "
		+string(sn)
		+" "+string(dn)
		+" "+string(dy)
		+" "+string(cm)
		+"\n")
}
method sendtool(o) {
	if ( ! defined(o.recreate) ) {
		$.message("recreate method not there!?")
		return()
	}
	s = o.recreate()
	if ( s == Nullstr ) {
		$.message("recreate returns nothing!?")
		return()
	}
	savesplit = Printsplit
	Printsplit = 0
	msg = "Tooltype=\""+o.classof()+"\";"
	sz = string(o.size())
	if ( sz != "" )
		msg += "Toolsize="+sz+";"
	if ( defined(o.dump) ) {
		s = o.dump()
		if ( typeof(s) != "array" ) {
			$.message("Hey, \"dump\" method of"+o.classof()+"tool didn't return an array!?")
			return()
		}
		else if ( sizeof(s) != 0 ) {
			msg += "Tooldump = "+string(s)+";"
		}
	}
	$.toeveryone("broadcasttool "+msg+"\n")
	Printsplit = savesplit
}
method toeveryone(msg,exceptfrom,prepend) {
	if ( ! $.isconnected() ) {
		$.message("Error, toeveryone() called when not connected!");
		return()
	}
	if ( nargs() < 2 )
		exceptfrom = ""
	if ( nargs() < 3 ) {
		# Assumes prepend is 0 when 3rd arg given
		msg = $.myname+" "+msg
	}
	if ( $.debug > 1 )
		$.message("toeveryone, msg="+msg)
	if ( exceptfrom != $.master && "w" in $.ports_tomaster )
		put($.ports_tomaster["w"],msg)
	for ( nm in $.clientports ) {
		if ( nm != exceptfrom ) {
			ports = $.clientports[nm]
			put(ports["w"],msg)
		}
	}
}
method tomaster(msg) {
	if ( $.debug )
		$.message("tomaster, msg="+msg)
	if ( "w" in $.ports_tomaster )
		put($.ports_tomaster["w"],msg)
}
method sendonebroadcastoffset {
	myoffset = nextquant(Now+$.extralag,$.quantguarantee)
	$.toeveryone("broadcastoffset "+string(myoffset)+"\n")
	if ( $.debug > 1 )
		$.message("sending offset, myoff="+string(myoffset))
}
method task_continuous {

	$.sendonebroadcastoffset()

	Monitorfifo = mf = open()
	tid = task $.every(mf,$.continuousstep)

	global closenkill
	onexit(closenkill,$,tid)

	p = ''
	np = 0
	while ( (m=get(mf)) != Eof ) {
		if ( typeof(m) == "phrase" ) {
			p |= m
			np++
		}
		if ( np > 10 || (typeof(m) != "phrase" && np > 0 ) ) {
			$.sendphrase(p)
			p = ''
			np = 0
		}
	}
}
method every(f,tm) {
	while (1) {
		sleeptill(Now+tm)
		put(f,"tick")
	}
	
}
method dump { return(["master"=$.master]) }
method restore (state) { 
	# if ( "master" in state ) {
	# 	$.connect(state["masger"])
	# }
}
method update() { }

method consolekey(c) {
	$.grabcons()
}

method grabcons() {
	if ( Root.focus() != $ ) {
		Root.focus($)
	}
	if ( Consechoobj != $.cmdw ) {
		Root.setconsgrabfifo($.f)
		Consechoobj = $.cmdw
		Consecho = 0
	}
}

method mousedown (m) {
	w = $.childunder(m)
	if ( w == $.consw || w == $.cmdw ) {
		if ( Consupdown == 1 ) {
			$.message("Consupdown is 1...");
			$.message("Quit typo if you want to type a message...");
			return()
		}
		$.grabcons()
		$.consw.mousedo(m)
	} else {
		mouseforward(m,"mousedown")
	}
}

method task_talk_to_client(ports,from) {
	$.talk(ports,from)
}

method task_talk_to_master(ports,from) {
	$.talk(ports,from)
	$.tid_tomaster = -1
}

method talk(ports,from) {
	f = ports["r"]
	while ( (line=get(f)) != Eof ) {

		if ( $.debug )
			$.message("line="+line)
		# Each line begins with a command word, then args

		words = split(line)
		if ( sizeof(words) == 0 ) {
			$.message("Empty message!?")
			continue
		}
		realfrom = words[0]
		cmd = words[1]
		nchars = sizeof(realfrom)+1+sizeof(cmd)+2
		rest = substr(line,nchars,sizeof(line)-nchars)

		if ( $.debug )
			$.message("Rcvd "+cmd+" from="+from+"  realfrom="+realfrom)

		if ( $.rebroadcast ) {
			# Send the message back out "raw"
			$.toeveryone(line,from,0)
		}

		if ( cmd == "ping" ) {
			# Send a response - include the requestor
			$.toeveryone("pingresponse "+realfrom+" "+string(Now)+"\n","")
		}
		else if ( cmd == "pingresponse" ) {
			aa = split(rest)
			# Only print pingresponses if you are the requestor
			if ( aa[0] == $.myname )
				$.message("ping response ["+realfrom+"] "+rest)
		}
		else if ( cmd == "broadcasttext" ) {
			$.message("["+realfrom+"] "+rest)
		}
		else if ( cmd == "broadcasttempo" ) {
			t = integer(words[2])
			tempo(t)
			$.message("TEMPO: realfrom "+realfrom+" t="+string(t))
		}
		else if ( cmd == "broadcastkboomcell" ) {
			if ( $.debug )
				$.message("got broadcastkboomcell")
			if ( defined(Kboomtool) && Kboomtool != $0 ) {
				if ( $.debug )
					$.message("GOT KBOOMCELL: "+words[2]+" "+words[3]+" "+words[4]+" "+words[5])
				w2 = integer(words[2])
				w3 = integer(words[3])
				w4 = integer(words[4])
				w5 = words[5]
				Kboomtool.konnecthitcell(w2,w3,w4,w5)
			}
		}
		else if ( cmd == "broadcastoffset" ) {
			coff = integer(words[2])
			$.clientoffset[realfrom] = coff
			myoff = nextquant(Now+$.extralag,$.quantguarantee)
			ro = myoff - coff
			ro += $.extralag2
			$.realoffset[realfrom] = ro
			if ( $.debug ) {
				$.message("broadcastoffset realfrom="+realfrom)
				$.message("  myoff="+string(myoff))
				$.message("  clientoffset="+string(coff))
				$.message("  final realoffset="+string(ro))
			}
		}
		else if ( cmd == "broadcastphraseoff" ) {
			p = phrase(rest)
			if ( (p != '') && (realfrom in $.realoffset) ) {
				if ( $.debug ) {
					$.message("playing phrase, p="+string(p))
					$.message("  realfrom="+realfrom+" realoff="+string($.realoffset[realfrom]))
				}
				p.time += $.realoffset[realfrom]

				if ( $.debug )
					$.message("   Now="+string(Now)+" updated p="+string(p))
				if ( $.debug > 1 )
					$.message("playing phrase, size="+string(sizeof(p)))
				realtime(p,0,0,0)	# 4th arg says "don't monitor"
				if ( $.record )
					Recorded |= p
			}
		}
		else if ( cmd == "broadcastmouse" ) {
			aa = split(rest)
			Slavemousemessage = [ "type" = aa[0], "button" = aa[1],
				"x" = aa[2], "y" = aa[3] ]
			mousewarp(Slavemousemessage["x"],
					Slavemousemessage["y"])
			mousedo(Slavemousemessage)
		}
		else if ( cmd == "broadcasttool" ) {
			if ( $.allowtools == 0 ) {
				$.message("Broadcast of tool is rejected!")
			} else {
				Tooltype = ""
				Tooldump = ""
				Toolsize = ""
				eval rest;
				if ( Tooltype=="" || Tooldump == "" || Toolsize == "" ) {
					$.message("Bad tool broadcast!?  rest="+rest)
				}
				else {
					cmd = "Newtool=new "+Tooltype+"(); Root.addtool(Newtool,Toolsize);Newtool.restore(Tooldump);Newtool.redraw();"
					eval cmd
				}
			}
		}
		else if ( cmd == "broadcastphrase" ) {
			p = phrase(rest)
			if ( p != '' ) {
				if ( $.debug > 1 )
					$.message("playing phrase, size="+string(sizeof(p)))
				p = syncphr(p)
				realtime(p,Now,0,0)	# 4th arg says "don't monitor"
				if ( $.record ) {
					p.time += Now
					Recorded |= p
				}
			}
		}
	}
	$.message("["+from+"] DISCONNECTED!")
	close(ports["r"])	# it's already closed because of Eof?
	close(ports["w"])
	if ( $.emailto != "" ) {
		sendmail($.emailto,
			"Keykit konnect server DISCONNECT from "+from,
			"Disconnected from "+from
			)
	}
}

method task_listener() {

	if ( KeyKitPort < 0 || KeyKitHost == "" ) {
		error("You must set KeyKitHost and KeyKitPort in your prerc.k file!")
		return()
	}
	k = KeyKitPort
	for ( i=0; i<12; i++ ) {
		myport = string(k)+"@"+KeyKitHost
		a = open(myport,"rf","tcpip_listen")
		if ( a != Eof && typeof(a) == "integer" )
			break
		$.message("Can't use port "+string(k))
		k++
	}
	$.status = "started"

	# Sleep a bit so we can get resized/redrawn the first time
	sleeptill(Now+1b/2)

	$.redraw()
	$.message("Listening on "+string(myport))
	$.clientports = []
	while ( (ports=get(a)) != Eof ) {
		put(ports["w"],"mynameis "+$.myname+"\n")
		r = get(ports["r"])
		if ( r == Eof ) {
			$.message("wtask_listener got early Eof, connection will be closed!")
			close(ports["r"])
			close(ports["w"])
			continue
		}
		words = split(r)
		if ( words[0] != "mynameis" ) {
			$.message("Didn't get 'mynameis' as first line!?  response="+string(r))
			$.message("Connection will be closed!")
			close(ports["r"])
			close(ports["w"])
			continue
		}
		from = words[1]
		$.message("["+from+"] NEW CONNECTION!")
		$.clientports[from] = ports
		task $.task_talk_to_client(ports,from)
		if ( $.emailto != "" ) {
			sendmail($.emailto,
				"Keykit konnect server NEW CONNECTION from "+from,
				"New connection from "+from
				)
		}
	}
}

method closem {
	Monitorfifo = -1
}

method command(cmd) {
	if ( substr(cmd,1,1) == "!" ) {
		cmd = substr(cmd,2)
		if ( cmd == "pingresponse" ) {
			$.message("Sending pingresponse request")
			$.toeveryone("pingresponse\n")
		} else if ( cmd == "ping" ) {
			$.message("Sending ping request")
			$.toeveryone("ping\n")
		} else {
			$.message("Not implemented: "+cmd)
		}
	} else {
		if ( ! $.isconnected() ) {
			$.message("Not connected!");
		} else {
			$.sendbroadcastmessage(cmd);
		}
	}
	$.cmdw.textleft("");
	$.cmdw.redraw();
}

}

function mkmenu_konnectmore(o,po) {
	o.menucmd("Connect",po,"connect")
	o.menucmd("Set My Name",po,"setmyname")
	# o.menucmd("Send Message",po,"sendbroadcastmessage")
	o.menucmd("Send Snarf",po,"sendsnarf")
	o.menucmd("Send Last Recorded (2b space)",po,"sendbroadcastrecorded",2b)
	o.menucmd("Send Last Recorded (8b space)",po,"sendbroadcastrecorded",8b)
	# o.submenu("Send Mouse Continuous        ->","mkmenu_konnectmouse",po)
	o.submenu("Tool Broadcasting            ->","mkmenu_toolbroadcast",po)
	o.submenu("Debug                        ->","mkmenu_konnectdebug",po)
}

function mkmenu_konnectdebug(o,po) {
	o.menucmd("Debug All On",po,"setdebug",2)
	o.menucmd("Debug Some On",po,"setdebug",1)
	o.menucmd("Debug Off",po,"setdebug",0)
}

function mkmenu_toolbroadcast(o,po) {
	o.menucmd("Allow",po,"settoolbroadcast",1)
	o.menucmd("Disallow",po,"toolbroadcast",0)
}

function mkmenu_konnectmouse(o,po) {
	o.menucmd("Send On",po,"startmousecontinuous")
	o.menucmd("Send Off",po,"stopmousecontinuous")
	o.menucmd("Receive On",po,"receivemousecontinuous")

}

function closenkill(o,tid) {
	o.closem();
	kill(tid)
}

function kerror() {
	print("Error!  Attempting to continue on...\n")
}

function kserver(prt,dbg) {
	Errorfunc = kerror
	keyrc()
	if ( nargs() > 0 )
		KeyKitPort = prt
	else
		KeyKitPort = 3333
	if ( nargs() < 2 )
		dbg = 0
	KeyKitHost = "www.nosuch.com"
	SmtpServer = "127.0.0.1"
	Nonotice = 1
	# Mailto is "tjt"
	a = new wkonnect(1,dbg,"tjt");
}

function konnectinterp(interpfifo,cons,o) {

	sleeptill(Now+milliclicks(1000))
	for ( ;; ) {
		cmd = ConsoleReadedit(interpfifo,"",Hist)
		if ( cmd == Eof )
			return()

		if ( cmd == Interrupt ) {
			o.printf("<INTERRUPT>")
			continue
		}
		o.command(cmd)
	}
}
