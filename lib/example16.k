function example16(ph) {
	sz = sizeof(ph)
	for ( n=1; n<sz; n++ ) {
		if ( ph%(n+1).pitch == ph%n.pitch ) {
			ph%n.dur = ph%(n+1).time + ph%(n+1).dur - ph%(n).time
			ph%(n+1) = ''
		}
	}
	return(ph)
}
