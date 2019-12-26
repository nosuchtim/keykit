function trans_twotimes(X) { return( X + X ) }
function trans_double(X) { return( X | X ) }

function select_everyother(X) { return( X{??.number%2==0} ) }
function select_secondhalf(X) { return( cut(X,CUT_TIME,X.length/2) ) }

Transforms = [
	0 = "trans_twotimes",
	1 = "trans_double"
];

Selectors = [
	0 = "select_everyother",
	1 = "select_secondhalf"
];

function selectx(gen) {
	e = "X";
	for ( n=0; n<gen; n++ ) {
		t = Transforms[rand(sizeof(Transforms))]
		s = Selectors[rand(sizeof(Selectors))]
		e = substitute_rand1(e,"X","applyto(X,"+s+","+t+")")
	}
	return(e)
}

function substitute(s,s1,s2) {
	i = strindex(s,s1)
	return ( substr(s,1,i-1) + s2 + substr(s,i+sizeof(s1)) )
}
function substitute_all(s,s1,s2) {
	r = ""
	while ( (i=strindex(s,s1)) > 0 ) {
		r += substr(s,1,i-1) + s2
		s = substr(s,i+sizeof(s1))
	}
	r += s
	return(r)
}
function substitute_rand(s,s1,s2,rn) {
	r = ""
	while ( (i=strindex(s,s1)) > 0 ) {
		if ( rand(rn) == 0 ) {
			r += substr(s,1,i-1) + s2
		} else {
			r += substr(s,1,i-1) + s1
		}
		s = substr(s,i+sizeof(s1))
	}
	r += s
	return(r)
}
function substitute_rand1(s,s1,s2,rn) {
	nfound = 0
	origs = s
	while ( (i=strindex(s,s1)) > 0 ) {
		nfound++
		s = substr(s,i+sizeof(s1))
	}
	r = ""
	s = origs
	tochange = rand(nfound)
	for ( k=0; (i=strindex(s,s1)) > 0; k++ ) {
		if ( tochange == k ) {
			r += substr(s,1,i-1) + s2
		} else {
			r += substr(s,1,i-1) + s1
		}
		s = substr(s,i+sizeof(s1))
	}
	r += s
	return(r)
}

function seltest() {
	s = "thisXabc"
	print ( substitute(s,"X","zzz") )
	s = "thisXabcXabc"
	print ( substitute_rand1(s,"X","zzz") )
	s = "thisXabcXabc"
	print ( substitute_rand1(s,"X","zzz") )
	s = "thisXabcXabc"
	print ( substitute_rand1(s,"X","zzz") )
}
