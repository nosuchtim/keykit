# Simple demo of OSC support - a listener
# and a sender.  Arrays represent OSC messages.
# First element of array is the message string,
# subsequent elements are the values, which
# can be integers, strings, or floats.

function osc_listen(host,port) {
	if ( nargs() < 1 )
		host = "192.168.1.106"
	if ( nargs() < 2 )
		port = 12345
	s = string(port)+"@"+host
	f = open(s,"rA","osc_listen")
	if ( f < 0 )
		return()
	print("Now listening on ",s)
	while ( (d = get(f)) != Eof ) {
		print("OSC message:"+string(d))
	}
}
function beau_test1() {
	f = open("5555@127.0.0.1","wb","osc_send")
	a = [0="/bb",1="hello world",2=2222,3=3.333]
	print("Sending OSC message:",a)
	mdep("osc","send",f,a)
	close(f)
}
function beau_test2() {
	f = open("5555@192.168.1.","wb","osc_send")
	a = [0="/bb",1="hello world",2=2222,3=3.333]
	print("Sending OSC message:",a)
	mdep("osc","send",f,a)
	close(f)
}
function beau_listen2() {
	f = open("5555@127.0.0.1","rA","osc_listen")
	if ( f < 0 )
		return()
	while ( (d = get(f)) != Eof ) {
		print("beau_listen2 OSC message:",string(d))
	}
}
function hidserver_listen() {
	f = open("57120@127.0.0.1","rA","osc_listen")
	if ( f < 0 )
		return()
	while ( (d = get(f)) != Eof ) {
		print("hidserver message:",string(d))
	}
}
function simpleosc_listen() {
	f = open("9000@127.0.0.1","rA","osc_listen")
	if ( f < 0 )
		return()
	while ( (d = get(f)) != Eof ) {
		print("simpleosc message:",string(d))
	}
}
function nthevent_listen() {
	f = open("1384@127.0.0.1","rA","osc_listen")
	if ( f < 0 )
		return()
	while ( (d = get(f)) != Eof ) {
		print("nthevent message:",string(d))
	}
}
function hidserver_send() {
	f = open("57120@127.0.0.1","wb","osc_send")
	a = [0="/bb",1="hello world",2=2222,3=3.333]
	print("Sending OSC message:",a)
	mdep("osc","send",f,a)
	close(f)
}
function simpleosc_send() {
	f = open("9001@127.0.0.1","wb","osc_send")
	a = [0="/test",1="hello world",2=2222,3=3.333]
	print("Sending OSC message:",a)
	mdep("osc","send",f,a)
	close(f)
}
function freeframe_send() {
	f = open("1400@127.0.0.1","wb","osc_send")
	a = [0="/test",1="hello world",2=2222,3=3.333]
	print("Sending OSC message:",a)
	mdep("osc","send",f,a)
	close(f)
}
function max_send() {
	f = open("1384@192.168.1.104","wb","osc_send")
	a = [0="/bb",1="hello world",2=2222,3=3.333]
	print("Sending OSC message:",a)
	mdep("osc","send",f,a)
	close(f)
}
function osc_panto() {
	osc_send([0="/panto/hi",1=3.4],"127.0.0.1",55555)
}
function osc_send(msg,host,port) {
	if ( nargs() < 1 ) {
		msg = [0="/bb",1="hello world",2=2222,3=3.333]
	}
	if ( nargs() < 2 ) {
		host = "127.0.0.1"
	}
	if ( nargs() < 3 ) {
		port = 99999
	}
	addr = string(port)+"@"+string(host)
	# print("addr=",addr)
	f = open(addr,"wb","osc_send")
	print("Sending OSC message:",msg)
	mdep("osc","send",f,msg)
	close(f)
}
function osc_sendto(port) {
	f = open(string(port)+"@127.0.0.1","wb","osc_send")
	a = [0="/bb",1="hello world",2=2222,3=3.333]
	print("Sending OSC message:",a)
	mdep("osc","send",f,a)
	close(f)
}
function osc_sean() {
	f = open("5500@192.168.1.103","wb","osc_send")
	a = [0="/start",1="z",2=1]
	a = [0="/z",1="start",2=1]
	a = [0="z",1="start",2=1]
	print("Sending OSC message:",a)
	mdep("osc","send",f,a)
	close(f)
}
function oscgroup_send() {
	f = open("22244@zip","wb","osc_send")
	a = [0="/bb",1="hello world",2=2222,3=3.333]
	print("Sending OSC message:",a)
	mdep("osc","send",f,a)
	close(f)
}
function oscgroup_listen() {
	f = open("22245@127.0.0.1","rA","osc_listen")
	if ( f < 0 )
		return()
	while ( (d = get(f)) != Eof ) {
		print("GOT OSCGROUP message:",string(d))
	}
}
