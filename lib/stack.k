class stack {
	method init {
		$.s = []
		$.n = 0
	}
	method push(v) {
		lock($)
		$.s[$.n] = v
		$.n++
		unlock($)
	}
	method updatetop(v) {
		lock($)
		if ( $.n > 0 ) {
			$.s[$.n-1] = v
		}
		unlock($)
	}
	method pop() {
		lock($)
		if ( $.n == 0 ) {
			v = Noval
		} else {
			$.n--
			v = $.s[$.n]
			delete $.s[$.n]
		}
		unlock($)
		return(v)
	}
	method peek() {
		lock($)
		if ( $.n == 0 ) {
			v = Noval
		} else {
			v = $.s[$.n-1]
		}
		unlock($)
		if ( defined(v) )
			return(v)
		else
			return(Noval)
	}
	method print(prefix) {
		print("==== TOP of ",prefix)
		for ( n=$.n-1; n>=0; n-- ) {
			print("[",n,"] = ",$.s[n])
		}
		print("==== BOTTOM of ",prefix)
	}
}
