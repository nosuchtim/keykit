#
# This file contains works in progress for the "call for algorithmic shorts"
#

# a=strnotes("algorhythm")
# a='co1,co2,co4,co3'
# 
# b = preecho(a,16,12,0.9)
# 
# b = arpeggio(b)
# b = step(b,1b/8)
# 
# Snarf = b

# Convert a number v into a phrase p, selecting the
# 8 notes in p with the binary bits in v

function octbits(v,p) {
	b = []
	r = ''
	for ( n=0; n<8; n++ ) {
		b[n] = (v>>n)&1
		if ( b[n] ) {
			# c = step(p%(n+1),1b/4)
			# r += c
			c = p%(n+1)
			r |= c
		}
	}
	return(r)
}


function b12(p) {
	# p = 'co0,co1,co2,co3,co4,co5,co3,co2'
	# p = repeat('c',8)
	# p = step(p,1b/4)
	r = ''
	for ( v=0; v<256; v+=2 ) {
		v1 = v
		v2 = v+1

		s1 = octbits(v1,p)
		s1.length = 8 * (1b/4)
		s1.chan = 1

		s2 = octbits(v2,p)
		s2.length = 8 * (1b/4)
		s2.pitch += 12
		s2.chan = 2

		r += (s1|s2)
	}
	return(r)
}

function binbits() {
	r = ''
	r |= b12(step(repeat('c',8),1b/4))
	r |= b12('co0,co1,co2,co3,co4,co5,co3,co2')
	# r |= b12(strip(onlynotes(readmf("bachinv1.mid"))))
	return(r)
}
