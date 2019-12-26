# Routing things


function midirouter() {
	if ( defined(MidiRouter) && MidiRouter >= 0 ) {
		print("Hey, midirouter is already running!?  Killing ",MidiRouter)
		kill(MidiRouter)
		sleeptill(Now+6)  # wait for kill and cleanup
		MidiRouter = task task_midirouter()
	} else {
		MidiRouter = task task_midirouter()
	}
}

function midirouter_cleanup() {
	MidiRouter = -1
	Merge = OldMerge
	print("restoring Merge to ",Merge)
	closemidi("midirouter")
}

function task_midirouter() {

	OldMerge = Merge
	Merge = 0
	
	Midiin["midirouter"] = f = open()
	onexit(midirouter_cleanup)

	isdown = []

	modelist = [0="HOOPS",1="ERGO"]
	initialmode = 1

	currmodei = []
	currmode = []
	controldown = []
	if ( ! defined(Routerin) ) {
		Routerin = []
	}
	for ( r in Routerin ) {
		currmodei[r] = initialmode
		currmode[r] = modelist[initialmode]
		controldown[r] = 0
	}

	while ( (n=get(f)) != Eof ) {
		prt = n.port
		if ( ! ( prt in Routerin ) ) {
			print("midirouter not routing n=",n)
		} else if ( controldown[prt] ) {
			if ( n.type == NOTEOFF ) {
				if ( n.chan == 16 && n.pitch == 16 ) {
					controldown[prt] = 0
				}
				continue
			}
			c = canonic(n)
			if ( c in modelist ) {
				currmode[prt] = modelist[c]
				currmodei[prt] = c
				print("MODE for port",prt,"is now ",currmode[prt])
			} else {
				print("There is no mode: ",c)
			} 
		} else if ( n.type==NOTEON && n.chan == 16 && n.pitch == 16 ) {
			controldown[prt] = 1
		} else if ( currmode[prt] == "HOOPS" ) {
			if ( defined(Hoops) ) {
				Hoops.midi_feed(n)
			} else {
				print("Hoops isn't running!?")
			}
		} else if ( currmode[prt] == "ERGO" ) {
			if ( defined(Ergo) ) {
				# ALL input routed directly to Ergo is	
				# considered to be on the control channel
				n.chan = 16
				Ergo.midi_feed(n)
			} else {
				print("Ergo isn't running!?")
			}
		}
	}
	print("midirouter end!?")
}

