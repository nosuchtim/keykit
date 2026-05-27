#name	stringtest
#usage	stringtest([milliseconds [,verbose]])
#desc	Runs an on-demand stress test of string construction, lookup,
#desc	substrings, split fields, phrase attributes, and garbage collection.

function stringtest_note(label, ok, got, want) {
	if ( ok )
		return(0)
	print("STRINGTEST FAIL",label,"got",got,"want",want)
	return(1)
}

function stringtest_min(label, got, want) {
	return(stringtest_note(label,got>=want,got,want))
}

function stringtest_copy(s) {
	return(substr("[" + s + "]",2,sizeof(s)))
}

function stringtest_key(c,n) {
	return("st:" + sprintf("%04d",c%10000) + ":" + sprintf("%04d",n) + ":" +
		substr("abcdefghijklmnopqrstuvwxyz0123456789",(n%24)+1,9))
}

function stringtest_lookup_key(c,n) {
	k = stringtest_key(c,n)
	return(stringtest_copy(k))
}

function stringtest_value(c,n) {
	return("value:" + sprintf("%04d",c%10000) + ":" + sprintf("%04d",n) + ":" +
		substr("ZYXWVUTSRQPONMLKJIHGFEDCBA9876543210",(n%24)+1,10))
}

function stringtest_literal() {
	return("stringtest-bytecode-literal-survives-gc")
}

function stringtest_padded_literal(n) {
	s = "literal:alpha:beta:gamma"
	for ( i=0; i<n; i++ )
		s = substr("!" + s + "?",2,sizeof(s))
	return(s)
}

class stringtest_object_holder {
method init {
	$.bag = []
	$.label = ""
	$.value = ""
}
method put(k,v) {
	$.label = stringtest_copy(k)
	$.value = stringtest_copy(v)
	$.bag[$.label] = $.value
}
method get(k) {
	kk = stringtest_copy(k)
	return($.bag[kk] + ":" + $.label + ":" + $.value)
}
}

function stringtest_check_parts(k,c,n) {
	parts = split(k,":")
	if ( sizeof(parts) != 4 )
		return(1)
	if ( parts[0] != "st" )
		return(1)
	if ( parts[1] != sprintf("%04d",c%10000) )
		return(1)
	if ( parts[2] != sprintf("%04d",n) )
		return(1)
	return(0)
}

function stringtest_long_string(c) {
	s = "long:" + sprintf("%04d",c%10000)
	for ( i=0; i<96; i++ )
		s += ":" + sprintf("%04d",i) + ":" +
			substr("abcdefghijklmnopqrstuvwxyz0123456789",(i%24)+1,12)

	copy = stringtest_copy(s)
	failures = 0
	failures += stringtest_note("long-copy",copy==s,sizeof(copy),sizeof(s))
	failures += stringtest_note("long-prefix",substr(copy,1,5)=="long:",substr(copy,1,5),"long:")
	failures += stringtest_note("long-suffix",
		substr(copy,sizeof(copy)-3,4)==substr(s,sizeof(s)-3,4),
		substr(copy,sizeof(copy)-3,4),substr(s,sizeof(s)-3,4))

	a = []
	a[copy] = sizeof(copy)
	failures += stringtest_note("long-array-key",a[stringtest_copy(s)]==sizeof(s),
		a[stringtest_copy(s)],sizeof(s))
	delete a[stringtest_copy(s)]
	failures += stringtest_note("long-delete",!(copy in a),copy,"deleted")
	return(failures)
}

function stringtest_attr_phrase(c,count) {
	attrs = ""
	for ( n=0; n<count; n++ ) {
		if ( n > 0 )
			attrs += ","
		attrs += "c`stringtest_" + sprintf("%04d",c%10000) + "_" +
			sprintf("%03d",n) + "`"
	}
	attrs += ","

	phr = phrase(attrs)
	failures = 0
	n = 0
	for ( nt in phr ) {
		want = "stringtest_" + sprintf("%04d",c%10000) + "_" + sprintf("%03d",n)
		if ( nt.attrib != want )
			failures += stringtest_note("attrib-value",0,nt.attrib,want)
		n++
	}
	failures += stringtest_note("attrib-count",n==count,n,count)
	return(failures)
}

function stringtest_edge_cases(c) {
	a = []
	failures = 0
	empty = ""
	spaced = "space key " + sprintf("%04d",c%10000)
	punct = "punct:/=;|," + sprintf("%04d",c%10000)
	a[empty] = "empty"
	a[spaced] = "spaced"
	a[punct] = "punct"
	failures += stringtest_note("empty-key",a[""]=="empty",a[""],"empty")
	failures += stringtest_note("space-key",a[stringtest_copy(spaced)]=="spaced",
		a[stringtest_copy(spaced)],"spaced")
	failures += stringtest_note("punct-key",a[stringtest_copy(punct)]=="punct",
		a[stringtest_copy(punct)],"punct")
	delete a[stringtest_copy(spaced)]
	failures += stringtest_note("space-delete",!(spaced in a),spaced,"deleted")
	return(failures)
}

function stringtest_object_cases(c) {
	o = new stringtest_object_holder()
	failures = 0
	for ( n=0; n<12; n++ ) {
		k = "obj:" + sprintf("%04d",c%10000) + ":" + sprintf("%03d",n)
		v = stringtest_value(c,n) + ":object"
		o.put(k,v)
		garbcollect()
		want = v + ":" + k + ":" + v
		got = o.get(stringtest_copy(k))
		failures += stringtest_note("object-string-value",got==want,got,want)
	}
	delete o
	garbcollect()
	return(failures)
}

function stringtest_cycle(c,batch) {
	failures = 0
	table = []
	roots = []
	total = 0
	expected_total = 0

	for ( n=0; n<batch; n++ ) {
		k = stringtest_key(c,n)
		v = stringtest_value(c,n)
		table[k] = v
		if ( n < 48 )
			roots[n] = stringtest_copy("root:" + k + ":" + v)
		if ( stringtest_check_parts(k,c,n) != 0 )
			failures++
		if ( stringtest_copy(v) != v )
			failures++
		expected_total += sizeof(v)
	}

	garbcollect()

	failures += stringtest_note("populate-size",sizeof(table)==batch,sizeof(table),batch)

	for ( n=batch-1; n>=0; n-- ) {
		k = stringtest_lookup_key(c,n)
		if ( ! ( k in table ) )
			failures += stringtest_note("lookup-missing",0,k,"present")
		else if ( table[k] != stringtest_value(c,n) )
			failures += stringtest_note("lookup-value",0,table[k],stringtest_value(c,n))
		total += sizeof(table[k])
	}
	failures += stringtest_note("lookup-bytes",total==expected_total,total,expected_total)

	for ( n=0; n<batch; n=n+3 )
		delete table[stringtest_lookup_key(c,n)]
	garbcollect()

	for ( n=0; n<batch; n++ ) {
		k = stringtest_lookup_key(c,n)
		if ( (n%3) == 0 ) {
			if ( k in table )
				failures += stringtest_note("delete-survivor",0,k,"deleted")
		}
		else if ( table[k] != stringtest_value(c,n) )
			failures += stringtest_note("survivor-value",0,table[k],stringtest_value(c,n))
	}

	failures += stringtest_attr_phrase(c,72)
	failures += stringtest_long_string(c)
	failures += stringtest_edge_cases(c)
	failures += stringtest_object_cases(c)

	garbcollect()

	failures += stringtest_note("literal",stringtest_literal()=="stringtest-bytecode-literal-survives-gc",
		stringtest_literal(),"stringtest-bytecode-literal-survives-gc")
	failures += stringtest_note("padded-literal",stringtest_padded_literal(80)=="literal:alpha:beta:gamma",
		stringtest_padded_literal(80),"literal:alpha:beta:gamma")

	return(failures)
}

function stringtest(ms,verbose) {
	if ( nargs() < 1 )
		ms = 60000
	if ( nargs() < 2 )
		verbose = 0
	if ( ms < 1 )
		ms = 1

	print("STRINGTEST start",ms,"ms")
	if ( verbose )
		debug("str")
	debug("strcheck")

	start_ms = milliclock()
	end_ms = start_ms + ms
	cycles = 0
	failures = 0

	while ( milliclock() < end_ms ) {
		failures += stringtest_cycle(cycles,320)
		cycles++
		if ( verbose && (cycles%5) == 0 )
			print("STRINGTEST cycles",cycles,"elapsed",milliclock()-start_ms)
	}

	elapsed = milliclock() - start_ms
	debug("strcheck")
	if ( verbose )
		debug("strgc")

	failures += stringtest_min("cycles",cycles,1)
	failures += stringtest_min("elapsed-ms",elapsed,ms)

	if ( failures == 0 )
		print("STRINGTEST PASS",cycles,"cycles",elapsed,"ms")
	else
		print("STRINGTEST FAILURES",failures,"cycles",cycles,"ms",elapsed)
	return(failures)
}
