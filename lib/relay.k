function relayscan(){
	a=''
	for ( n=0; n<32; n++ ) {
		a += relay(n)
	}
	return(step(a,1b/16))
}
function relays(n1,n2){
	if ( n1 > n2 ) {
		t = n1
		n1 = n2
		n2 = t
	}
	p=''
	for(n=n1;n<=n2;n++)
		p += relay(n)
	return(p)
}
function relay(n){
	st = 68
	# WE ASSUME THE RELAY BOARD IS ON CHANNEL 1 !
	p = makenote(st+n)
	if ( defined(Relayport) && Relayport >= 0 ) {
		p.port = Relayport
		return(p)
	} else {
		return('')
	}
}
