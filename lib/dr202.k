function dr202presetkit(ch,n) {
	if ( nargs() < 1 )
		ch = 10
	return(midibytes(bankselect(ch,81,0),progchange(n,ch)))
}
function dr202userkit(ch,n) {
	if ( nargs() < 1 )
		ch = 10
	return(midibytes(bankselect(ch,85,0),progchange(n,ch)))
}

# dr202decode - decode a phrase with note attributes:
#
#	"C" - cutoff
#	"R" - resonance
#	"D" - decay
#
function dr202decode(ph) {
	currentval = []
	r = ''
	for ( nt in ph ) {
		a = nt.attrib
		if ( a == "" ) {
			r |= nt
			continue
		}
		atts = attribarray(a)
		pre = ''
		p = nt.pitch
		if ( ! ( p in currentval ) )
			currentval[p] = []
		cvarr = currentval[p]
		for ( s in atts ) {
			mv = atts[s]
			if ( cvarr[s] == mv ) {
				continue
			}
			cvarr[s] = mv
			if ( s == "C" ) {
				mv += 0x0e
				mm = midibytes(nrpn(nt.chan,0x15,p),
					datamsg(nt.chan,mv,mv))
				pre += mm;
			} else if ( s == "R" ) {
				mv += 0x0e
				mm = midibytes(nrpn(nt.chan,0x16,p),
					datamsg(nt.chan,mv,mv))
				pre += mm;
			} else if ( s == "D" ) {
				mv += 0x0e
				mm = midibytes(nrpn(nt.chan,0x17,p),
					datamsg(nt.chan,mv,mv))
				pre += mm;
			} else {
				
			}
		}
		pre.time = nt.time
		r |= pre
		nt.attrib = ""
		r |= nt
	}
	return(r)
}

# This is used in Kboom 2
function dr202map() {
	return([
		0=["note"='p36c10',"name"="Kick 1"],
		1=["note"='p35c10',"name"="Kick 2"],
		2=["note"='p38c10',"name"="Snare 1"],
		3=["note"='p40c10',"name"="Snare 2"],
		4=["note"='p42c10',"name"="Closed HH"],
		5=["note"='p46c10',"name"="Open HH"],
		6=["note"='p51c10',"name"="Ride"],
		7=["note"='p49c10',"name"="Crash"],
		8=["note"='p50c10',"name"="Hit 1"],
		9=["note"='p47c10',"name"="Hit 2"],
		10=["note"='p43c10',"name"="Hit 3"],
		11=["note"='p60c10',"name"="Perc 1"],
		12=["note"='p61c10',"name"="Perc 2"],
		13=["note"=dr202presetkit(10,1),"name"="Pre Kit 1"],
		14=["note"=dr202presetkit(10,2),"name"="Pre Kit 2"],
		15=["note"=dr202presetkit(10,3),"name"="Pre Kit 3"],
		16=["note"=dr202userkit(10,1),"name"="User Kit 1"]
		])
}

