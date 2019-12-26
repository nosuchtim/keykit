# This is the only function that opens the socket for listening

function keykithostname() {
	if ( KeyKitHost == "" ) {
		arr = mdep("tcpip","localaddresses")
		n = sizeof(arr)
		if ( n == 0 ) {
			print("Unable to get ANY local addresses!?  Using 127.0.0.1")
			KeyKitHost = "127.0.0.1"
		}
		else if ( n == 1 )
			KeyKitHost = arr[0]
		else if ( n > 1 ) {
			KeyKitHost = arr[0]
			print("Local host has multiple addresses!  Listening will be done on "+KeyKitHost)
		}
	}
	return(KeyKitHost)
}

function smtptest() {
	ports = open("25@ninja","rw","tcpip_connect")
	print("ports=",ports)
	r = ports["r"]
	fifoctl(r,"type","l")
	a=get(r)
	print("a=",a)
	a=get(r)
}
