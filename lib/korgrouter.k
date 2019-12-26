# Routing things


function korgrouteron() {
	korg_router()
	ergo()
	hoops1c()
}

function korg_router_stop() {
	print("korg_router_stop called")
	if ( KorgRouter >= 0 )
		kill(KorgRouter)
}
function korg_router_cleanup() {
	print("korg_router_cleanup!")
	korg_native_off()
	KorgRouter = -1
}

function korg_router() {
	if ( defined(KorgRouter) && KorgRouter >= 0 ) {
		print("Hey, korg_router is already running!?  Killing ",KorgRouter)
		kill(KorgRouter)
		sleeptill(Now+6)  # wait for kill and cleanup
		KorgRouter = task task_korg_router()
	} else {
		KorgRouter = task task_korg_router()
	}
}

function task_korg_router() {

	f = open()
	k = korgcontrol()
	k.sendtofifo(f)
	onexit(korg_router_cleanup)

	isdown = []

	modelist = [0="HOOPS",1="ERGO",2="CTRL"]
	currmodei = 0
	currmode = modelist[currmodei]
	k.setlabel("main",currmode)

	while ( (n=get(f)) != Eof ) {
		print("Korg router got n=",n)
		s = typeof(n)
		if ( s == "string" ) {
			words = split(n)
			if ( words[0] == "padon" && words[1] == 13 ) {
				currmodei++
				if ( ! (currmodei in modelist) ) {
					currmodei = 0
				}
				currmode = modelist[currmodei]
				k.setlabel("main",currmode)
			} else {
				router_send(currmode,n)
			}
			continue
		}
		found = 0
		for ( m in isdown ) {
			if ( isdown[m] != 0 ) {
				found = 1
				c = canonic(n.pitch)
				if ( n.type == NOTEON ) {
					if ( c in modelist[m] ) {
						v = modelist[m][c]
						if ( typeof(v) == "string") {
							currmode[m] = modelist[m][c]
							print("SWITCHED ",m," mode to ",currmode[m])
						} else if ( typeof(v) == "phrase" ) {
							print("playing v=",v)
							realtime(v)
						}
					}
				}
			}
		}
		if ( found == 0 ) {
			router_send(currmode,n)
		}
	}
}

function router_send(currmode,n) {
	if ( currmode == "HOOPS" ) {
		if ( defined(Hoops) ) {
			Hoops.midi_feed(n)
		} else {
			print("Hoops isn't running!?")
		}
	} else if ( currmode == "ERGO" ) {
		if ( defined(Ergo) ) {
			Ergo.midi_feed(n)
		} else {
			print("Hoops isn't running!?")
		}
	} else if ( currmode == "CTRL" ) {
	}
}

