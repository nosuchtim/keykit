# For each section of phrase ph of width wid, repeat it num times

function stutter(ph,wid,num) {
	if ( nargs() != 3 ) {
		print("usage: stutter(phrase,width,num)")
		return('')
	}
	t = 0
	r = ''
	for (;;) {
		p = cut(ph,CUT_TIME,t,t+wid)
		# if no notes left, we're done
		if ( sizeof(p)==0 && sizeof(cut(ph,CUT_TIME,t+wid,MAXCLICKS))==0 )
			break
		p.time -= t
		p.length = wid
		for ( n=0; n<num; n++ )
			r += p
		t += wid
	}
	return(r)
}
# For each section (of random width, within a small range
# of possible widths) of phrase ph, repeat it

function stutterrand(ph) {
	if ( nargs() != 1 ) {
		print("usage: stutterrand(phrase)")
		return('')
	}
	t = 0
	r = ''
	for (;;) {
		n = rand(4)
		if ( n==0 ) wid=1b/2
		else if ( n==1 ) wid=1b
		else if ( n==2 ) wid=2b
		else if ( n==3 ) wid=4b
		p = cut(ph,CUT_TIME,t,t+wid)
		# if no notes left, we're done
		if ( sizeof(p)==0 && sizeof(cut(ph,CUT_TIME,t+wid,MAXCLICKS))==0 )
			break
		p.time -= t
		p.length = wid
		r += p
		r += p
		t += wid
		r.length = 2*t
	}
	return(r)
}

function strnotes(s) {
	lng = sizeof(s)
	r = ''
	for ( n=1; n<=lng; n++ ) {
		c = substr(s,n,1)
		nt = 'c'
		a = ascii(c) - ascii("a")
		if ( a < 0 )
			a = -a
		nt.pitch = 48 + a
		nt.dur = (1+a/12)*1b/2
		nt.length = nt.dur
		r += nt
	}
	return(r)
}
