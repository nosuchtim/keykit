#define xxx rereadlib();nosuchtouch()

function nosuchtouch() {
	host = "127.0.0.1"
	port = 7777
	s = string(port)+"@"+host
	f = open(s,"rA","osc_listen")
	if ( f < 0 ) {
		print("Unable to open ",s)
		return()
	}
	t = task m2t2listen(s,f)
        Root.waitforconsolekey()
        kill(t)
	close(f)
}

function m2t2listen(s,f) {
	print("Now listening on ",s)
	while ( (d = get(f)) != Eof ) {
		nmsg = d["elements"]
		for ( n=0; n<nmsg; n++ ) {
			msg = d[n]
			addr = msg[0]
			if ( addr != "/tuio/25Dcur" && addr != "/tuio/2Dcur" ) {
				continue
			}
			cmd = msg[1]
			if ( cmd != "set" ) {
				continue
			}
			ch = msg[2]/1000
			dx = msg[3]
			dy = msg[4]
			nt = makenote(rand(128))
			nt.pitch = 128 * dx
			nt.dur = 1b/16
			nt.chan = ch
			print("OSC message n=",n," msg="+string(msg)," nt=",nt)
			realtime(nt)
		}
	}
}
