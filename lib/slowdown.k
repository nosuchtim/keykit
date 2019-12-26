function slowdown(ph) {
	tm1 = ph%1.time
	sz = sizeof(ph)
	leng = ph%sz.time + ph%sz.dur - tm1
	start_factor = 1.0
	end_factor = 4.0
	df = end_factor - start_factor
	r = nonnotes(ph)
	ph = onlynotes(ph)
	for ( nt in ph ) {
		dt = nt.time - tm1
		thisfactor = start_factor + (dt/float(leng)) * df
		nt.time = tm1 + dt * thisfactor
		nt.dur *= thisfactor
		r |= nt;
	}
	return(r)
}
