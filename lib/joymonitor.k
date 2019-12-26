function getjoymonitor {
	if ( ! defined(JoyMonitor) || JoyMonitor == $0 || JoyMonitor == $-1 )
		JoyMonitor = new joymonitor()
	return(JoyMonitor)
}

class joymonitor {
method init {
	$.joys = joyinit()
	$.obj = []
	for ( j in $.joys ) {
		$.obj[j] = []
	}
	$.seen = []
	$.f = open("buttons","rl","joystick")
	$.tid = task $.monitor()
}
method devices {
	return($.joys)
}
method monitor {

	bynum = padbuttonsbynum()
	while ( 1 ) {
		p = get($.f)
		if ( p == Eof ) {
			print("Got Eof, joymonitor is quiting!?")
		}
		arr = split(p)
		jn = integer(arr[1])
		if ( ! ( jn in $.obj ) ) {
			print("joymonitor got event for jn=",jn," which isn't in obj?")
			sleeptill(Now+1b)
			continue
		}
		if ( sizeof($.obj[jn]) == 0 ) {
			sleeptill(Now+1b)
			continue
		}
		for ( nobj in $.obj[jn] ) {
			if ( nobj == $0 ) {
				print("joymonitor detects $0 notify obj? uh oh")
				delete $.obj[jn][nobj]
				continue
			}
			if ( nobj == $-1 ) {
				print("joymonitor detects deleted notify obj, uh oh")
				delete $.obj[jn][nobj]
				continue
			}
			if ( arr[0] == "button" ) {
				nm = bynum[integer(arr[2])]
				# We spawn it as a task, but synchornously, so
				# if there's an execution error in it, we don't
				# get killed
				t = task nobj.buttonchange(jn,nm,arr[3])
				wait(t)
			} else {
				# Ignore the first one we get
				# on all the analog inputs, to avoid the
				# initial burst.
				tt = string(jn) + string(arr[2])
				if ( tt in $.seen ) {
					t = task nobj.analogchange(jn,arr[2],arr[3])
					wait(t)
				} else {
					$.seen[tt] = 1
				}
			}
		}
	}
}
method delete {
	close($.f)
	kill($.tid)
}
method notify(obj,jn) {
	if ( nargs() < 2 ) {
		print("joymonitor.notify - needs 2 arguments")
		return()
	}

	if ( ! defined(obj.buttonchange) )
		print("notify object should have a buttonchange method")
	if ( ! defined(obj.analogchange) )
		print("notify object should have a analogchange method")

	if ( jn < 0 ) {
		for ( jn in $.obj ) {
			$.obj[jn][obj] = 1
		}
	} else {
		if ( ! ( jn in $.obj ) ) {
			print("joymonitor was given a joystick (",jn,") that doesn't exist! - joys=",$.joys)
		} else {
			$.obj[jn][obj] = 1
		}
	}
}
method unnotify(obj,jn) {
	if ( nargs() < 2 ) {
		print("joymonitor.unnotify - needs 2 arguments")
		return()
	}
	if ( jn < 0 ) {
		for ( jn in $.obj ) {
			delete $.obj[jn][obj]
		}
	} else {
		if ( ! ( jn in $.obj ) ) {
			print("joymonitor was given a joystick (",jn,") that doesn't exist! - joys=",$.joys)
		} else {
			delete $.obj[jn][obj]
		}
	}
}
}
