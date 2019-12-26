class padmonitor {
method init {
	$.obj = $0
	joyinit()
	$.f = open("buttons","rl","joystick")
	$.tid = task $.monitor()
}
method monitor {

	padbutts = padbuttons()
	bynum = padbuttonsbynum()
	while ( 1 ) {
		p = get($.f)
		if ( p == Eof ) {
			print("Got Eof, padmonitor is quiting")
		}
		arr = split(p)
		nm = bynum[integer(arr[2])]
		if ( $.obj == $0 || $.obj == $-1 ) {
			sleeptill(Now+1b)
		} else {
			# We spawn it as a task, but synchornously, so
			# if there's an execution error in it, we don't
			# get killed
			t = task $.obj.padchanged(integer(arr[1]),nm,arr[3])
			wait(t)
		}
	}
}
method delete {
	close($.f)
	kill($.tid)
}
method notify(obj) {
	$.obj = obj
}
}
