#name	remotecons
#usage	remotecons(port)
#desc	Starts a remote keykit console on the given port.
#desc	KEYALLOW environment variable is hostname of machine allowed to connect.

function remotecons(port) {
	if ( nargs() < 1 ) {
		print("Usage: remotecons(port)")
		return()
	}
	task remotecons_task(port)
}

function remotecons_task(port) {
	if ( nargs() > 0 )
		s = string(port)+"@127.0.0.1"
	else
		s = "keykit@127.0.0.1"
	a = open(s,"rf","tcpip_listen")
	if ( a == "" )
		error("Can't open tcpip_listen")
	while ( (x=get(a)) != Eof ) {
		task remotecons_loop(x)
	}
}

function remotecons_loop(x) {

	fifoctl(x["r"],"type","l")
	rc = new rconsole(x["r"],x["w"])

	while ( (d=get(x["r"])) != Eof ) {
		lng=sizeof(d)
		# if the last 2 chars are "\r\n", kill the last one
		if ( substr(d,lng-1,2) == "\r\n" )
			lng--
		for ( n=1; n<=lng; n++ ) {
			c = substr(d,n,1)
			rc.consolekey(c)
		}
	}
	close(x["r"])
	close(x["w"])

	kill(interpid)
}

class rconsole {
method init (rfifo,wfifo) {

	$.consfifo = open()
	$.wfifo = wfifo
	$.rfifo = rfifo
	Root.focus($)
	task interploop($.consfifo,$)
}
method printf(...) {
	s = sprintf(...)
	# if the output ends in just "\n", add a "\r"
	put($.wfifo,s)
	if ( substr(s,sizeof(s),1) == "\n" )
		put($.wfifo,"\r")
}
method consecho(c) {
	# I'm not sure this one is actually called
	put($.wfifo,string(c))
}
method consolekey (c) {
	Root.focus($)
	if ( $.consfifo >= 0 )
		put($.consfifo,c)
}
}
