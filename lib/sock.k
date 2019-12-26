function test_listen(port) {
	if ( nargs() > 0 )
		s = string(port)+"@127.0.0.1"
	else
		s = "keykit@127.0.0.1"
	a = open(s,"rf","tcpip_listen")
	if ( a == "" )
		error("Can't open tcpip_listen")
	print("test_listen a=",a)
	while ( (x=get(a)) != Eof ) {
		print("Got CONNECTION!!! x=",x);
		task test_loop(x)
	}
	print("GOT EOF from LISTEN FIFO!");
}
function test_loop(x) {
	print("test_loop on x=",x)
	fifoctl(x["r"],"type","l")
	while ( (d=get(x["r"])) != Eof ) {
		print("GOT d=",d)
		if ( substr(d,1,1) == "'" ) {
			print("p length=",sizeof(d))
			p = phrase(d)
			realtime(p)
		}
	}
	print("GOT EOF from test_loop on x=",x)
	close(x["r"])
	close(x["w"])
	print("after closing them")
}
function test_connect() {
	Tcp = open("80@127.0.0.1","rw","tcpip_connect")
	if ( typeof(Tcp) != "array" )
		error("Can't open tcpip_connect")
	print("test_connect: open returns Tcp=",Tcp)
}

#
# This is a basic test of socket support.  Note that a get() on a
# tcpip_listen port returns a pair of fifos for the new accepted connection.
#

function http_client() {
	a = open("80@nosuch.com","rw","tcpip_connect")
	if ( typeof(a) != "array" )
		error("Can't open tcpip_connect")
	print("http_client: open returns a=",a)
	f = a["r"]
	fifoctl(f,"type","l")
	put(a["w"],"GET /\n\n")
	while ( (s=get(f)) != Eof ) {
		if ( s == Interrupt ) {
			print("INTERRUPT!!!!")
			break;
		}
		print("s=",s)
	}
	print("END OF FILE RECEIVED! 2\n");
	close(a["w"])
	close(a["r"])
}

function sock_client(port) {
	a = open(string(port)+"@127.0.0.1","rw","tcpip_connect")
	if ( typeof(a) != "array" )
		error("Can't open tcpip_connect")
	print("sock_client: open returns a=",a)

	put(a["w"],"A message from sock_client")

	s = ""
	while ( (x=get(a["r"])) != Eof ) {
		s += ascii(x)
	}
	printf("sock_client: got s=%s\n",s);
	close(a["w"])
	close(a["r"])
	Socktest = 1
}

function sock_server(port) {
	print("sock starts")
	f = open(string(port)+"@127.0.0.1","rf","tcpip_listen")
	# This gets a pair of fifo values, in an array
	a = get(f)

	# We need to block on the first one, since fifosize is 0
	x = get(a["r"])
	s = ascii(x)
	while ( fifosize(a["r"]) > 0 && (x=get(a["r"])) != Eof ) {
		s += ascii(x)
	}
	printf("sock_server got s=%s\n",s);
	put(a["w"],"A message from sock_server")
	close(a["w"])
	close(a["r"])
	close(f)
}

function sock_test(port) {
	if ( nargs() < 1 )
		port = 5862
	Socktest = 0
	task sock_server(port)
	millisleep(500)
	task sock_client(port)
	for ( n=0; n<10 && Socktest==0; n++ ) {
		millisleep(1000)
	}
	if ( Socktest == 1 ) {
		print("SOCK_TEST SUCCEEDED!")
	} else {
		print("SOCK_TEST FAILED!")
	}

}
function udp_listen() {
	f = open("keyecho@trill","r","udp_listen")
	print("f="+string(f)+"\n")
	while ( (d = get(f)) != Eof ) {
		print("d="+string(d))
	}
}
function udp_listen2() {
	f = open("3001@192.168.1.5","r","udp_listen")
	print("f="+string(f)+"\n")
	while ( (d = get(f)) != Eof ) {
		print("d="+string(d))
	}
}
function udp_test_send() {
	f = open("1234@192.168.1.202","wb","udp_send")
	print("f="+string(f)+"\n")
	# put(f,"Hello")
	put(f,'/')
	put(f,'a')
	put(f,'a')
}
