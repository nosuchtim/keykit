function sc7turnon(...) {
	r = ''
	for ( n=0; n<nargs(); n++ ) {
		chnum = argv(n)
		# turns on a particular channel by setting the RX channel to itself
		cn = sc7strangemap()[chnum]
		v = chnum-1
		cksum = sc7chksum(0x01,cn,0x00,v)
		r += midibytes(0xf0,0x41,0x10,0x56,0x12,
				0x01,cn,0x00,v,
				cksum,0xf7)
	}
	return(r)
}

function sc7turnoff(...) {
	# turns off particular channels by setting the RX channel to 0x10
	r = ''
	for ( n=0; n<nargs(); n++ ) {
		chnum = argv(n)
		cn = sc7strangemap()[chnum]
		cksum = sc7chksum(0x01,cn,0x00,0x10)
		r += midibytes(0xf0,0x41,0x10,0x56,0x12,
				0x01,cn,0x00,0x10,
				cksum,0xf7)
	}
	return(r)
}

function sc7strangemap() {
	return( [10=0,1=1,2=2,3=3,4=4,5=5,6=6,7=7,8=8,9=9,
			11=10,12=11,13=12,14=13,15=14,16=15] )
}

function sc7only(chnum) {
	r = ''
	for ( c=1; c<=16; c++ ) {
		if ( c != chnum )
			r += sc7turnoff(c)
		else
			r += sc7turnon(c)
	}
	return(r)
}

function sc7chksum(...) {
	sum = 0
	for ( n=0; n<nargs(); n++ ) {
		sum += argv(n)
	}
	while ( sum > 128 )
		sum -= 128

	return(128-sum)
}

function sc7voicereserve() {
	# this function isn't finished!!!!
	ch = []
	for ( n=0; n<16; n++ )
		ch[n] = 8
	# ch[chnum-1] = 28
	cksum = sc7chksum(0x40,0x01,0x10,
		ch[0],ch[1],ch[2],ch[3],ch[4],ch[5],ch[6],ch[7],
		ch[8],ch[9],ch[10],ch[11],ch[12],ch[13],ch[14],ch[15])

	p = midibytes(0xf0,0x41,0x10,0x42,0x12,0x40,0x01,0x10,
		ch[0],ch[1],ch[2],ch[3],ch[4],ch[5],ch[6],ch[7],
		ch[8],ch[9],ch[10],ch[11],ch[12],ch[13],ch[14],ch[15],
		cksum,0xf7);
	return(p)
}
