function var1(p) {
	r = ''
	for ( n in p ) {
		pt = progchange(n.pitch,n.chan)
		pt.time = n.time
		r |= pt
	}
	return(r)
}
function var2(p) {
	r = ''
	minp = lowest(p)
	maxp = highest(p)
	for ( n=-minp+1; n<(maxp-1); n++ ) {
		p2 = p
		p2.pitch += n
		p2 |= var1(p2)
		r += p2
	}
	return(r)
}
function var3(p,...) {
	if ( nargs() < 3 )
		error("var3: bad usage")
	if ( sizeof(p) == 0 )
		return(p)
	mx = 0
	# find max value in sequence list
	for ( n=1; n<nargs(); n++ ) {
		if ( argv(n) > mx )
			mx = argv(n)
	}
	while ( sizeof(p) < mx )
		p += p
	r = ''
	for ( n=1; n<nargs(); n++ ) {
		i = argv(n)
		pi = p%i
		pi.time = 0
		pi.length = pi.dur
		r += pi
	}
	return(r)
}
function var4(p) {
	return(var3(p,1,2,1,2,3,1,2,3,4,1,2,3,4,5,1,2))
}
function var5(p) {
	return(var3(p,1,1,1,1,1,1,1,2,1,3,1,2,1,4,3,2))
}
function var5b(p) {
	a = repeat(var3(p,1,2,3,4),4)
	b = repeat(var3(p,3,4,5,6),4)
	c = repeat(var3(p,5,6,7,8),4)
	d = repeat(var3(p,7,8,9,10),4)
	return(a+b+c+d)
}
function var4b(p) {
	return(var3(p,1,2,1,3,1,2,1,3,4,5,4,6,4,5,4,6))
}
function leasttense(p,t) {
	r = ''
	mintense = 999
	for ( n in p ) {
		if ( canonic(n) == canonic(t) )
			continue
		tns = tension(n,t)
		if ( tns < mintense ) {
			mintense = tns
			r = n
		}
	}
	return(r)
}
function var6(p,nnotes) {
	n1 = p%1
	sz = sizeof(p)
	p -= n1
	r = n1
	while ( --nnotes > 0 ) {
		n2 = leasttense(p,n1)
		p -= n2
		r |= n2
	}
	return(r)
}
function var7b(p) {
	r = ''
	while ( sizeof(p) >= 3 ) {
		ch1 = var6(p,3)
		p -= ch1
		ch1.time = 0
		ch1.dur = minduration(ch1)
		ch1.length = ch1.dur
		r += ch1
	}
	return(r)
}
function var7(p) {
	r = ''
	while ( sizeof(p) >= 4 ) {
		ch1 = var6(p,4)
		p -= ch1
		ch1.time = 0
		ch1.dur = minduration(ch1)
		ch1.length = ch1.dur
		r += ch1
	}
	return(r)
}
function var8(p) {
	r = ''
	while ( sizeof(p) >= 3 ) {
		ch1 = var6(p,2)
		p -= ch1
		ch1.time = 0
		ch1.dur = minduration(ch1)
		ch1.length = ch1.dur
		r += ch1
	}
	return(r)
}
function var9(str) {
	ntarr = [
		"a" = 'a',
		"b" = 'b',
		"c" = 'c',
		"d" = 'd',
		"e" = 'e',
		"f" = 'f',
		"g" = 'g',
		"h" = 'a',
		"i" = 'b',
		"j" = 'c',
		"k" = 'd',
		"l" = 'e',
		"m" = 'f',
		"n" = 'g',
		"o" = 'a',
		"p" = 'b',
		"q" = 'c',
		"r" = 'd',
		"s" = 'e',
		"t" = 'f',
		"u" = 'g',
		"v" = 'h',
		"w" = 'i',
		"x" = 'j',
		"y" = 'k',
		"z" = 'l'
		]
	sz = sizeof(str)
	r = ''
	for ( n=1; n<=sz; n++ ) {
		ch = substr(str,n,1)
		if ( ch in ntarr )
			r += ntarr[ch]
	}
	return(r)
}
function var10(str) {
	ntarr = [
		"a" = 'a',
		"b" = 'a+',
		"c" = 'b',
		"d" = 'c',
		"e" = 'c+',
		"f" = 'd',
		"g" = 'd+',
		"h" = 'e',
		"i" = 'f',
		"j" = 'f+',
		"k" = 'g',
		"l" = 'g+',
		"m" = 'a',
		"n" = 'a+',
		"o" = 'b',
		"p" = 'c',
		"q" = 'c+',
		"r" = 'd',
		"s" = 'd+',
		"t" = 'e',
		"u" = 'f',
		"v" = 'f+',
		"w" = 'g',
		"x" = 'g+',
		"y" = 'a',
		"z" = 'a+'
		]
	sz = sizeof(str)
	r = ''
	for ( n=1; n<=sz; n++ ) {
		ch = substr(str,n,1)
		if ( ch in ntarr )
			r += ntarr[ch]
	}
	return(r)
}
