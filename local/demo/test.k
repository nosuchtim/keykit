function randnotes(numnotes,pickfrom) {
	p=''
	for(n=0;n<100;n++) {
		nt = makenote(pickfrom%(1+rand(sizeof(pickfrom))),
				1b/8*(1+rand(12)))
		nt.pitch += 12*(rand(6)-2)
		p += nt
	}
	return(p)
}
