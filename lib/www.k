
function alg_a(word) {
	r=bswww(word)
	return(r)
}

function alg_b(word,leng) {
	if ( nargs() < 2 ) {
		print("usage: alg_b(word,number-of-beats)")
		return('')
	}
	s=word
	x=echovariety(strnotes(s))
	w=polishit(x)
	w=strip(w)
	r = cutitdown(w,leng*1b)
	return(r)
}

function wwwalg1(word,leng) {
	s=word
	x=echovariety(strnotes(s))
	w=polishit(x)
	r = cutitdown(w,leng*1b)
	writemf(r,"www.mid")
	writelines(r,"www.lines")
}

function wwwalg2(word) {
	r=bswww(word)
	writemf(r,"www.mid")
	writelines(r,"www.lines")
}

function cutitdown(w,desired) {
	while ( 1 ) {
		m = 0
		r = ''
		lng = 0
		n = 0
		mod=2
# print("w= head=",head(w),"  tail=",tail(w),"  w.length=",w.length)
		while ( 1 ) {
			p = cut(w,CUT_TIME,m*4b,(m+1)*4b)
# print("loop p size=",sizeof(p))
			if ( sizeof(p) == 0 )
				break
			p.time -= m*4b
			if ( n == 0 ) {
				r += p
				lng += 4b
				r.length = lng
			}
			m++
			n++
			if ( n >= mod )
				n = 0
		}
		if ( r.length <= desired )
			break
		# otherwise cut it some more
		w = r
	}
	return(r)
}

function bswww(str,majmin) {

	if ( nargs() < 2 )
		majmin = 0

	bskey = 'e-o-2'
	bsmajor = []
	bsmajor[ 1 ]= 'e-o-2'
	bsmajor[ 2 ]= 'e-o-2,f,g,b-'
	bsmajor[ 3 ]= 'e-o-2,b-'
	bsmajor[ 4 ]= 'e-o-2,b-'
	bsmajor[ 5 ]= 'e-o-2,f,g,b-'
	bsmajor[ 6 ]= 'e-o-2,b-'
	bsmajor[ 7 ]= 'e-o-2,f,g,b-'
	bsmajor[ 8 ]= 'e-o-2,b-'
	bsminor = []
	bsminor[ 1 ]= 'e-o-2'
	bsminor[ 2 ]= 'e-o-2,f,g-,b-'
	bsminor[ 3 ]= 'e-o-2,b-'
	bsminor[ 4 ]= 'e-o-2,b-'
	bsminor[ 5 ]= 'e-o-2,f,g-,b-'
	bsminor[ 6 ]= 'e-o-2,b-'
	bsminor[ 7 ]= 'e-o-2,f,g-,b-'
	bsminor[ 8 ]= 'e-o-2,b-'
	
	ntimes = 8
	p0 = strnotes(str)
	dodetense = 1
	if ( dodetense == 0 ) {
		p1 = p0
	}
	else {
		p1 = ''
		for ( n in p0 ) {
			if ( p1 == '' )
				p1 = lastn = n
			else {
				while ( tension(n,lastn) > 3 )
					n.pitch++
			}
			p1 |= n
		}
	}
	p = scatimes(p1,8)

	guide = shuffle(repeat(p1,3*ntimes))
	guide = guide { isonbeat(??,3b) }
	guide =  octavefence(guide,72,72)

	p2 = bsguide(majmin==0?bsmajor:bsminor,bskey,p,guide,1b/4,p.length)

	pend = latest(p2)
	p2a = p2 { isonbeat(??,2b) }
	p2b = gradinclude(p2,0.0,1.0,0)
	p2 = dedup(p2a | p2b)
	p2 = octavefence(p2,52,88)

	p2r = reverse(p2)
	p2rev = ''
	c = 4b
	for ( n=0; ; n=n+2 ) {
		z = cut(p2r,CUT_TIME,n*c,(n+1)*c)
		if ( sizeof(z) == 0 )
			break
		z.time -= n*c
		z.length = c
		p2rev += z
	}
	p2 = p2 + p2rev
	p2.chan = 1	# main melody


	p2x = makerootevery(p2,1b)
	p2x = gradinclude(p2x,0.0,1.0)
	p2x = octavefence(p2x,46,58)
	p2x.chan = 2	# piano
	p2 |= p2x
	l = latest(p2)
	p2ya = makerootevery(cut(p2,CUT_TIME,0,l/4),4b)
	p2yb = makerootevery(cut(p2,CUT_TIME,l/4,l/2),2b)
	p2yc = makerootevery(cut(p2,CUT_TIME,l/2,3*l/4),1b)
	p2yd = makerootevery(cut(p2,CUT_TIME,3*l/4,l),2b)
	p2y = p2ya | p2yb | p2yc | p2yd
	p2y = octavefence(p2y,34,46)
	p2y.chan = 3	# bass
	p2 |= p2y

	# final little gliss, based on last note in bass
	lastnt = p2y%sizeof(p2y)
	lastnt.time = 0
	lastnt.dur = 4b
	pf = bsguide(majmin==0?bsmajor:bsminor,bskey,
				lastnt,
		'co1d48,co2,co3,co4,co5',1b/4,2b+1b/4)
	pf.chan = 1
	p2 += pf

	# proot = octavefence(p,36,50)
	# proot = proot | transpose(proot,4) | transpose(proot,-5)
	
	sus = sussect(2b)
	susp = sus
	while ( susp.length < p2.length )
		susp += sus
	susp.chan = 1
	# patches =  progchange(1,1)
	# 		| progchange(1,2)
	# 		|  progchange(1,3)
	patches =  progchange(47,1)
			| progchange(47,2)
			|  progchange(33,3)
	p3 = patches | p2 | susp
	return(p3)
}

function oldwritelines(p,fn) {
        f = open(fn,"w")
        xsize1 = string(1+latest(p))
        put(f,"size "+xsize1+" 128\n")
        xsize = string(latest(p))
	put(f,"line 0 0 "+xsize+" 0\n")		# top
	put(f,"line "+xsize+" 0 "+xsize+" 127\n")	# right
	put(f,"line 0 127 "+xsize+" 127\n")	# bottom
	put(f,"line 0 0 0 127\n")
        for ( n in p ) {
		if ( n.type != NOTE )
			continue
                ys = string(127-n.pitch)
                put(f,"line "+string(n.time)+" "+ys+" "
                                +string(n.time+n.dur)+" "+ys+"\n")
        }
        close(f)
}

function echovariety(w) {
	w2 = addrootevery(w,2b)
# print("echovariety  0 size=",sizeof(w2))
	w3 = arpeggio(w2)

# print("echovariety  A size=",sizeof(w3))
	w4 = echo(w3,2,4b)
# print("echovariety  B size=",sizeof(w4))
	w4b = echo(w4,2,2b)
# print("echovariety  C size=",sizeof(w4b))
	w5 = echo(w4b,4,1b/8)
# print("echovariety  D size=",sizeof(w5))
	w6 = echo(w5,4,1b/16)
# print("echovariety  E size=",sizeof(w6))

	w7 = arpeggio(w6)
# print("echovariety  E w7 size=",sizeof(w7))
	w8 = transposeseqinplace(w7,w2)
# print("echovariety  F w8 size=",sizeof(w8))
	w9 = octavefence(w8,54,90)
# print("echovariety  G w9 size=",sizeof(w9))
	w10 = addrootevery(w9,4b)
# print("echovariety  H w10 size=",sizeof(w10))
	w11 = addrootevery(w10,2b)
# print("echovariety  I w11 size=",sizeof(w11))
	w12 = scatimes(w11,0.5)
# print("echovariety  J w12 size=",sizeof(w12))
	return(w12)
}
function polishit(w) {
	leng = latest(w)
	m = mono(w,2)	# random priority
	m2 = octavefence(m,74,100)
# print("polishit m2=",sizeof(m2));
	m2.chan=2
	m2b = echo(m2{??.number%4==0},4,1b/4,0.80)
# print("polishit m2=",sizeof(m2));
	m2c1 = cut(m2|m2b,CUT_TIME,leng/4,leng/3){rand(4)==0}
# print("polishit m2c1=",sizeof(m2c1));
	m2c2 = cut(m2|m2b,CUT_TIME,leng/3,leng/2){rand(3)==0}
# print("polishit m2c2=",sizeof(m2c2));
	m2c3 = cut(m2|m2b,CUT_TIME,leng/2,leng)
# print("polishit m2c3=",sizeof(m2c3));
	m2c = m2c1 | m2c2 | m2c3
# print("polishit m2c=",sizeof(m2c));
	# add some roots to melody toward end
	m2final = m2c | makerootevery(cut(m2c,CUT_TIME,2*leng/3),4b)
# print("polishit m2final=",sizeof(m2final));

# return(m2final);

	# drums
	m3 = octavefence(m,54,64)
	m3.chan = 10
	m4 = m3{??.number%2==0}
	m5 = m3{??.number%3==0}
	m6 = m3{??.number%4==0}
	m7 = quantize(cut(m3{??.number%3==0},CUT_TIME,3*leng/4,leng),1b)
	m4.pitch = 61
	m5.pitch = 60
	m6.pitch = 64
	m7.pitch = 70
	m4 = quantize(m4,1b)
	m5b = echo(m5{??.number%9==0},4,1b/4,0.80)
	m6b = echo(m6{??.number%7==0},4,1b/4,0.80)
	m7b = echo(m7{??.number%3==0},4,1b/4,0.80)
	m7b1 = cut(m7b,CUT_TIME,0,7*leng/8)
	m7b2 = echo(cut(m7b,CUT_TIME,7*leng/8,leng),4,1b/4,0.95)
	m7b = m7b1 | m7b2
	drumsfinal = cut(m4|m5|m6|m7|m5b|m6b|m7b,CUT_TIME,leng/2,leng)
	drumsfinal.vol *= 0.8

	nnotes = sizeof(w)
	www = echo(w%nnotes,16,1b/4,0.95)
	www2 = www
	www2.chan = 2

	return(m2final|drumsfinal|w|www|www2)
}
function finalwein() {
	x = echovariety(strnotes("weinstock"))
	w = polishit(x)
	return(p+w)
}
function finalneil() {
	x = echovariety(strnotes("neil"))
	w = polishit(x)
	return(p+w)
}
