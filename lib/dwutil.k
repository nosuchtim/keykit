# Some utilities by David Woolls
#
# Flat and Sharp key scadjusments

function dwscadjust(mel,scale,tr) {
	flatArray=[1=1,3=1,5=1,6=1,8=1,10=1]
	if ( nargs() == 0 ) {
		print("usage: scadjust(melody,scale)")
		return('')
	}
	nmel = sizeof(mel)
	if ( sizeof(scale) == 0 ) {
		print("Hey, scadjust() needs some notes in the scale!")
		return('')
	}
	r = ''
	scarr = []
	for ( nt in scale )
		scarr[canonic(nt)] = 1
	for ( nt in mel ) {
		if ( nt.type & (NOTE|NOTEOFF|NOTEON) ) {
			inc = sign = 1
			while ( ! (canonic(nt) in scarr) ) {
				if(tr in flatArray) nt.pitch -= (sign*inc)
				else nt.pitch += (sign*inc)
				inc = inc + 1
				sign = -sign
			}
		}
		r |= nt
	}
	return(r)
}



function dw2scadjust(mel,scale,tr,sc) {
	flatArray=[1=1,3=1,5=1,6=1,8=1,10=1]
	if ( nargs() == 0 ) {
		print("usage: scadjust(melody,scale)")
		return('')
	}
	nmel = sizeof(mel)
	if ( sizeof(scale) == 0 ) {
		print("Hey, scadjust() needs some notes in the scale!")
		return('')
	}
	r = ''
	scarr = []
	mscarr = []
	melscale = ''
	lastpitch=0
	if(sc){
		melscale=transpose(scale_melminor(),tr)
		for (nt in melscale)
			mscarr[canonic(nt)] = 1
	}
	for ( nt in scale )
		scarr[canonic(nt)] = 1
	for ( nt in mel ) {
		if ( nt.type & (NOTE|NOTEOFF|NOTEON) ) {
			inc = sign = 1
			if(sc && nt.pitch > lastpitch){
				while ( ! (canonic(nt) in mscarr) ) {
					if(tr in flatArray) nt.pitch -= (sign*inc)
					else nt.pitch += (sign*inc)
				
					inc = inc + 1
					sign = -sign
				}
			}
			else {
				while ( ! (canonic(nt) in scarr) ) {
					if(tr in flatArray) nt.pitch -= (sign*inc)
					else nt.pitch += (sign*inc)
				
					inc = inc + 1
					sign = -sign
				}
			}
		}
		r |= nt
		lastpitch = nt.pitch
	}
	return(r)
}


