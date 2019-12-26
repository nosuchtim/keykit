function strbits(s) {

	lowa = ascii("a")
	lowz = ascii("z")
	upa = ascii("A")
	upz = ascii("Z")
	digit0 = ascii("0")
	digit9 = ascii("9")
	i = 1;
	total = ''
	for ( n=sizeof(s); n>0; n-- ) {
		c = substr(s,i++,1)
		cn = ascii(c)

		# get out when escape key is typed
		if ( cn == 27 )
			break;

		if ( cn >= digit0 && cn <= digit9 ) {
			ntimes = cn-digit0
			continue
		}
		# convert to lower case
		if ( cn >= upa && cn <= upz ) {
			cn = cn - upa + lowa
		}
		# ignore non-alpha
		if ( cn < lowa || cn > lowz )
			continue
		cn -= lowa;
		cn++

		p = 'c'
		# p.pitch += cn
		p.length = 48

		b = []
		# okay, cn is a value from 1 to 26 - construct an array of 5 bits
		b[0] = cn % 2
		b[1] = (cn/2) % 2
		b[2] = (cn/4) % 2
		b[3] = (cn/8) % 2
		b[4] = (cn/16) % 2

		r = bits2phrase(b,p)

		if ( b[0] != 0 )
			r = scatimes(r,0.5)
		else if ( b[1] != 0 )
			r = scatimes(r,0.25)
		else if ( b[2] != 0 )
			r = scatimes(r,2)
		else if ( b[3] != 0 )
			r = scatimes(r,4)
		total += r
	}
	return(total)
}

function alphafun() {

	print("Type away...")

	Consecho = 0	 # turn off automatic echoing of characters in Console
	lowa = ascii("a")
	lowz = ascii("z")
	upa = ascii("A")
	upz = ascii("Z")
	digit0 = ascii("0")
	digit9 = ascii("9")
	ntimes = -1
	for ( ;; ) {
		c = Root.waitforconsolekey()
		cn = ascii(c)

		# get out when escape key is typed
		if ( cn == 27 )
			break;

		if ( cn >= digit0 && cn <= digit9 ) {
			ntimes = cn-digit0
			continue
		}
		# convert to lower case
		if ( cn >= upa && cn <= upz ) {
			cn = cn - upa + lowa
		}
		# ignore non-alpha
		if ( cn < lowa || cn > lowz )
			continue
		cn -= lowa;
		cn++

		p = 'c'
		# p.pitch += cn
		p.length = 48

		b = char2bits(cn)
		r = bits2phrase(b,p)
		if ( ntimes > 0 ) {
			r = repeat(r,ntimes)
			ntimes = -1
		}
		realtime(r)
	}
	Consecho = 1
}

function char2bits(cn) {

	b = []

	# okay, cn is a value from 1 to 26 - construct an array of 5 bits
	b[0] = cn % 2
	b[1] = (cn/2) % 2
	b[2] = (cn/4) % 2
	b[3] = (cn/8) % 2
	b[4] = (cn/16) % 2

	return(b)
}

function bits2phrase(b,p) {

	r = ''
	rest = ''
	rest.length = p.length

	# find the first '1'
	for ( n=0; n<5; n++ ) {
		if ( b[n] != 0 )
			break;
	}
	for ( k=0; k<5; k++ ) {
		if ( b[n] == 0 )
			r += rest
		else
			r += p
		n++
		if ( n > 4 )
			n = 0;
	}
	return(r)
}

function alpha_back() {

	Midiin[$] = f = open()
	onexit(closemidi,$)
	phrases = []

	# Create an array (0 to 127) of phrases that will be triggered for
	# each received NOTEON.  The phrases we create here are just
	# an example - here we create a "reversed" keyboard.

	for ( n=0; n<128; n++ ) {
		phrases[n] = makenote(127-n)
		# You could, for example, read MIDI files into each phrase, like this
		# phrases[n] = readmf("phrase"+string(n)+".mid")
	}

	t = -1
	# Read MIDI input, triggering phrases on each NOTEON
	while ( (m=get(f)) != Eof ) {
		if ( m.type==NOTEON ) {
			p = phrases[m.pitch]

			# stop the previous one, if it exists
			if ( t >= 0 )
				kill(t)

			t = realtime(p)
		}
	}
}
