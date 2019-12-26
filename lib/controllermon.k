function controllermon() {
	t = task task_controllermon()
	Root.waitforconsolekey()
	kill(t)
}

function task_controllermon() {
	Midiin[$] = f = open()
	onexit(closemidi,$)
	while ( (m=get(f)) != Eof ) {
		if ( m.type == CONTROLLER ) {
			ch = m.chan
			cnum = integer(subbytes(m,2,1))
			cval = integer(subbytes(m,3,1))
			print("CONTROLLER chan=",ch," ctrl=",cnum," val=",cval)
		}
	}
}
