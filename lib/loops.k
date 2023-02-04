#name	consloop
#usage	consloop()
#desc	This is intended to be the one-and-only task that reads from
#desc	the Consinfifo, a special fifo that is automatically opened
#desc	whenever KeyKit is booted, and to which KeyKit sends any characters
#desc	typed on the console.  consloop() forwards the characters to whatever
#desc	task is supposed to be reading the console.  If Consgrabfifo is
#desc	set, it will send them there, otherwise it sends them to the
#desc	main command interpreter, which is reading from interpfifo.

function consloop() {
	onexit(consloop)
	while ( 1 ) {
		c = get(Consinfifo)
		Root.consolekey(c)
	}
}

function consoutloop() {
	onexit(consoutloop)
	while ( 1 ) {
		c = get(Consoutfifo)
		Console.printf("%s",string(c))
	}
}

#name	interploop
#usage	interploop()
#desc	This is the main command interpreter that executes the statements
#desc	that a user types interactively on the console.  It reads from
#desc	the interpfifo fifo, and characters are normally put on this fifo
#desc	by consloop().
#see	consloop

function interploop(interpfifoin,cons) {

	onexit(interploop,interpfifoin,cons)
	if( ! defined(Hist))		# passe � travers les erreurs/crashes...
	{	Hist = []
		Histindex = 0}
	if ( ! defined(History) )
		History = 0

	# Allow our invokers to control when the first prompt is printed
	lock("interploop") ; unlock("interploop")

	millisleep(200)	# wait a bit before putting out prompt
	if( ! defined(Modir))
		Modir = 0	# indicateur de mode direct (print syst�matique)

	for ( ;; ) {
		if ( Modir == 1) pm = ":" else pm = ""
		if ( History != 0 )
			prompt = "!"+string(Histindex)+pm+"> "
		else
			prompt = "key"+pm+"> "
		if ( Inputistty ) {
			cons.printf("%s",prompt)
		}

		cmd = ConsoleReadedit(interpfifoin,prompt,Hist)
		if ( cmd == Eof )
			exit(0)

		if ( cmd == Interrupt ) {
			print("<INTERRUPT>")
			continue
		}
		if ( cmd < 0 ) {
			continue
		}

                # History processing (revu et augment�...)
                if ( substr(cmd,1,1)=="!") {
                        theCmd = ""
                        if (cmd=="!!") {
					if (Histindex > 0)
					{
                                Histindex--
                                theCmd = Hist[Histindex]
					}
					else
					{
					   cons.printf("no history yet...\n")
					   theCmd = ""
					}
                        }
				else if (cmd=="!") { 				# liste
					
					if (Histindex > 0) for(hi = 0; hi < Histindex; hi++)
						cons.printf("%d: %s\n",hi,Hist[hi])
					else cons.printf("no history yet...\n")
					theCmd = ""
				}
				else if (cmd=="!!!") { 						# remise � z�ro
					Histindex = 0
					theCmd = ""
				}
				else if ((cmd=="!log") && Histindex > 0) {	# sauvegarde (KKlog.txt)
					logf = open(HFName,"w")
					for(hi = 0; hi < Histindex; hi++)
						put(logf, sprintf("%d: %s\n",hi,Hist[hi]))
					close(logf)
					cons.printf("%s\n",">>> History sauvegard�e sous "+HFName)
					theCmd = ""							
				}
				else {
                              which = split(cmd,"!")
                              which = integer(which[0])
                              if (which < 0)
                                    which = Histindex + which
                              if (which >= 0 && which <= Histindex) {
                                    theCmd = Hist[which]
                        }
                 }
                 if ( Inputistty && (theCmd != "") )
				cons.printf("%s\n",">>> "+theCmd)
                 cmd = theCmd
            }


		words = split(cmd," ")
		if ( sizeof(words) == 0 )
			continue

		Hist[Histindex++] = cmd

		if ( words[0] == "print" ) {
			rest = substr(cmd,6)
			cmd = "print("+rest+")"
			words = split(cmd," ")
		}
		if (words[0] == "::") {
			Modir = 1-Modir		# bascule du mode direct 
			cmd = "cmd"
		}
		else if ((substr(cmd,1,1) == ":")||(Modir)) {	
			rest = substr(cmd,2-Modir)
			if (substr(rest,1,1) != "#")
			{
				cmd = "print("+rest+")"
				words = split(cmd," ")
			}
		}
		if ( sizeof(split(cmd,"=")) > 1
			|| substr(cmd,1,5)=="print"
			|| words[0] == "delete"
			|| words[0] == "#define"
			|| words[0] == "#include" ) {
			eval cmd
		}
		else {
			Cmd___tmp = 0
			eval "Cmd___tmp = " + cmd
			if ( typeof(Cmd___tmp) == "phrase" ) {
				t = realmidi(Cmd___tmp,Now)
				registop(t)
				Conph = Cmd___tmp	# sorte de Snarf...
			}
		}
	}
}

#name	mouseloop
#usage	mouseloop()
#desc	This task is intended to be the one-and-only task that reads
#desc	directly from the Mousefifo, a special fifo that is opened
#desc	whenever KeyKit is rebooted, and to which KeyKit sends messages
#desc	about changes in the mouse state.  mouseloop() normally figures
#desc	out which window is underneath the mouse, and sends the message
#desc	to the Mousein fifo for that window.  If someone wants to grab the
#desc	mouse, they should set Mousegrabwind, and mouseloop() will instead
#desc	send the mouse messages to that window.  This procedure should be done
#desc	with the grabmouse() and ungrabmouse() functions.

function mouseloop() {
	onexit(mouseloop)
	# priority(gettid(),MAXPRIORITY-1)
	Mousegrabwind = -1
	Mousegrabfifo = -1

	Mouserecord = 0
	Mousehist = []
	Mousehistsize = 0

	while ( (m=get(Mousefifo)) != Eof ) {
		if ( Mouserecord ) {
			msave = arraycopy(m)
			msave["time"] = Now
			Mousehist[Mousehistsize++] = msave
		}
		if ( Mousebroadcast != $0 ) {
			Mousebroadcast.mousemessage(m)
		}
		mousedo(m)
	}
}

function mouserec(v) {
	if ( nargs() < 1 )
		v = 1 - Mouserecord
	if ( v == 1 ) {
		Mouserecord = 1
		Mousemoveevents = 1
		Mousehist = []
		Mousehistsize = 0
	}
	else if ( v == -1 ) {
		Mouserecord = 0
		Mousemoveevents = 0
		# Delete back to last mousedown (since the mousedown was the
		# thing that selected the menu item that turned off recording
		while ( Mousehistsize > 0 ) {
			Mousehistsize--
			t = Mousehist[Mousehistsize]["type"]
			delete Mousehist[Mousehistsize]
			if ( t == "mousedown")
				break
		}
	}
	else {
		Mouserecord = 0
		Mousemoveevents = 0
	}
}

function mousewritefile() {
	mouserec(0)
	fname = browsefiles("KeyKit Mouse File (*.KM)","*.km",0)
	if ( fname == "" )
		return()
	print("Writing mouse events to file: "+fname+" ...")
	f = open(fname,"w")
	if ( f < 0 )
		error("Unable to open file: "+fname)
	put(f,"Mousehistsize="+string(Mousehistsize)+"\n")
	put(f,"Mousehist="+string(Mousehist)+"\n")
	close(f)
	print("Done")
}

function mousereadfile() {
	mouserec(0)
	fname = browsefiles("KeyKit Mouse File (*.KM)","*.km",1)
	eval "#include \""+fname+"\""
}

function dodemo(fname) {
	page_new()
	mousedemo(fname)
}

function mousedemo(fname) {
	millisleep(1000)
	eval "#include \""+fname+"\""
	mouseplay()
}

function mouseplay() {
	task mouseplaytask()
}

function mouseplaytask() {
	if ( Mousehistsize <= 0 ) {
		print("There's no recorded Mouse events!?")
		return()
	}
	mouserec(0)
	Mousedisable = 1
	print("Now playing back saved Mouse events...")
	nowoff = Now - Mousehist[0]["time"]
	for ( n=0; n<Mousehistsize; n++ ) {
		m = Mousehist[n]
		sleeptill(nowoff + m["time"])
		mousewarp(m["x"],m["y"])
		mousedo(Mousehist[n])
	}
	Mousedisable = 0
}

function mousedo(m) {

	Lastmouse = m

	# If somebody's grabbed the mouse, give it to them
	if ( Mousegrabwind >= 0 ) {
		Mousegrabwind.(m["type"])(m)
		return()
	}
	if ( Mousegrabfifo >= 0 ) {
		put(Mousegrabfifo,m)
		return()
	}
	t = m["type"]
	o = Root.childunder(m)
	# The return value of Root.childunder may be Root (if there are no
	# children under the mouse), and that's okay - that's how the
	# Root's mouse methods get called.
	if ( defined(o.(t)) )
		o.(t)(m)
	return()
}

#name	midiloop
#usage	midiloop()
#desc	This is intended to be the one-and-only task which reads messages
#desc	from the Midiinfifo, a special fifo that is opened whenever KeyKit
#desc	is rebooted, and to which KeyKit sends messages containing
#desc	all MIDI input.  Any task wanting to read MIDI input should add
#desc	an entry to the Midiin array.  The index of the Midiin array
#desc	is normally the task id, and the value of the array element
#desc	is the fifo id.

function midiloop() {
	if ( Midiinfifo < 0 ) {
		print("Midiinfofo is < 0, midiloop() is disabled...")
		return()
	}
	if ( defined(Midiindisable) && Midiindisable!=0 ) {
		print("midiloop disabled by Midiindisable")
		return()
	}
	if ( ! defined(Midiingrab) ) {
		Midiingrab = -1
	}
	onexit(midiloop)
	for ( ;; ) {
		m = get(Midiinfifo)
		if ( Midiingrab >= 0 ) {
			put(Midiingrab,m)
			continue
		}
		for ( i in Midiin ) {
			if ( (typeof(i) == "object" && (i == $-1 || i == $0)) || typeof(Midiin[i]) != "integer" ) {
				# In case someone dies and doesn't clean up,
				# we remove the entry from Midiin.
				# Put it in a task, so if there's an error,
				# it doesn't kill the midiloop.
				task deletemidiin(i)
				continue
			}
			ff = Midiin[i]
			if ( ff == "" ) {
				print("Hey, Midiin[",i,"] is blank?")
				deletemidiin(i)
			} else {
				put(ff,m)
			}
		}
		if ( m.type == CONTROLLER ) {
			noticecontrollers(m,0)
		}
		else if ( m.type == PROGRAM ) {
			noticeprogram(m,0)
		}
	}
}

function deletemidiin(i) {
	# print("Deleting Midiin i=",i)
	delete Midiin[i]
}

# Typical use of this is with the onexit function
function closemidi(o) {
	if ( o in Midiin ) {
                t = Midiin[o]
                delete Midiin[o]
                close(t)
     }
}
