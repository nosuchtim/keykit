function example12 {
	a = 'a,a,b,c,c'
	print("Before=",a)
	pending = ''
	r =  ''
	for ( nt in a ) {
		if ( pending.pitch == nt.pitch && pending.time+pending.dur == nt.time ) {
			pending.dur += nt.dur
		} else {
			r |= pending
			pending = nt
		}
	}
	r |= pending
	a = r
	a.length = latest(a)
	print("After=",a)
}
function example12b {
	a = 'c e g,c e g'
	print("Before=",a)
	r =  ''
	for ( nt in a ) {
		look = a { (??.time + ??.dur)==nt.time && ??.pitch==nt.pitch && ??.chan==nt.chan }
		if ( look == '' ) {
			r |= nt
			continue
		}
		look = head(look,1)
		r -= look
		look.dur += nt.dur
		r |= look
	}
	a = r
	a.length = latest(a)
	print("After=",a)
}
