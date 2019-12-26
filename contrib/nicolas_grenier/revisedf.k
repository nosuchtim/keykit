function bpm2(bpm) {
	tempo(1000000/(float(bpm)/60))
	return(phrase("'"+"\""+"Tempo="+string(1000000/(float(bpm)/60))+"\""+"'"))
}


#name	legato2
#usage	legato2(phrase)
#desc	Extends the duration of each note to abutt the start of the next note.
#desc	Modifies the duration of the last note using the length of ph.

function legato2(ph) {
	r = ''
	non = nonnotes(ph)
	ph -= non
	for ( nt in ph ) {
		nextt = nexttime(ph,nt.time)
		# here, notes at the end of the phrase aren't touched
		if ( nextt >= 0 )
			nt.dur = nextt - nt.time
		r |= nt
	}
	# here, notes at the end of the phrase are touched
	a=r{??.time==(r%sizeof(r)).time} r-=a a.dur=(ph%1.time+ph.length-a%sizeof(a).time) r|=a
	r.length=ph.length
	return(r|non)
}

function flip2(ph){
	l=lowest(ph) h=highest(ph) out=''
	for(n in onlynotes(ph)){ a=n x=a.pitch x=(h-(x-l)) a.pitch=x out|=a}
	out.length=ph.length
	out|=nonnotes(ph)
	return(out)
}


