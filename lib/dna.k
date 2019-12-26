function dna(codes,iters) {
	rules = []
	leng = sizeof(codes)
	for ( n=0; n<leng; n++ ) {
		c = substr(codes,n+1,1)
		if ( n > 0 )
			pre = substr(codes,1,n)
		else
			pre = ""
		if ( n < (leng-1) )
			post = substr(codes,n+2)
		else
			post = ""
		rules[c] = pre+post
	}
	print("rules=",rules)
	# Start with initial code set and apply rules
	result = codes
	for ( k=0; k<iters; k++ ) {
		newresult = ""
		leng = sizeof(result)
		for ( n=0; n<leng; n++ ) {
			c = substr(result,n+1,1)
			newresult += rules[c]
		}
		result = newresult
	}
	return(result)
}
