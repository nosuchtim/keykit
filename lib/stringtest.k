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

function stringstress_check(label, got, want) {
	if ( got == want ) {
		print("ok",label)
		return(0)
	}
	print("FAIL",label,"got",got,"want",want)
	return(1)
}

function stringstress_make_key(n) {
	return("key:" + sprintf("%04d",n) + ":" +
		substr("abcdefghijklmnopqrstuvwxyz",(n%17)+1,5))
}

function stringstress_lookup_key(n) {
	k = stringstress_make_key(n)
	return(substr("<<" + k + ">>",3,sizeof(k)))
}

function stringstress_value(n) {
	return("value:" + sprintf("%04d",n) + ":" +
		substr("ZYXWVUTSRQPONMLKJIHGFEDCBA",(n%19)+1,6))
}

function stringstress_literal_root(n) {
	s = "literal:alpha:beta:gamma"
	for ( i=0; i<n; i++ )
		s = substr("!" + s + "?",2,sizeof(s))
	return(s)
}

function stringstress_task_value(seed,n) {
	return("task-shadow:" + seed + ":" + sprintf("%04d",n))
}

function stringstress_task(seed) {
	local_table = []
	local_keep = stringstress_task_value(seed,77)
	for ( n=0; n<140; n++ )
		local_table[stringstress_task_value(seed,n)] =
			stringstress_task_value(seed,139-n)
	garbcollect()
	Stringstress_task_result = local_keep + ":" +
		local_table[stringstress_task_value(seed,11)]
}

function stringstress_fifo_value(n) {
	return("fifo-shadow:" + sprintf("%04d",n) + ":" +
		stringstress_literal_root(6))
}

function stringstress_reuse_value(n) {
	return("quarantine-shadow:" + sprintf("%04d",n) + ":" +
		substr("abcdefghijklmnopqrstuvwxyz",(n%12)+1,8))
}

class stringstress_object_holder {
method init {
	$.bag = []
	$.label = ""
	$.value = ""
}
method put(k,v) {
	$.label = k
	$.value = v
	$.bag[$.label] = $.value
}
method get(k) {
	kk = substr("[" + k + "]",2,sizeof(k))
	return($.bag[kk] + ":" + $.label + ":" + $.value)
}
}

function stringstress_object_check() {
	failures = 0
	o = new stringstress_object_holder()
	for ( n=0; n<24; n++ ) {
		k = "object-key:" + sprintf("%04d",n) + ":" +
			stringstress_literal_root(4)
		v = "object-value:" + sprintf("%04d",23-n) + ":" +
			stringstress_value(n)
		o.put(k,v)
		garbcollect()
		got = o.get(k)
		want = v + ":" + k + ":" + v
		if ( got != want )
			failures++
	}
	delete o
	garbcollect()
	return(failures)
}

function stringstress() {
	entries = 1600
	table = []
	expected_total = 0
	failures = 0

	for ( n=0; n<entries; n++ ) {
		k = stringstress_make_key(n)
		v = stringstress_value(n)
		table[k] = v
		expected_total += sizeof(v)
	}
	garbcollect()

	failures += stringstress_check("populate-size",sizeof(table),entries)

	missing = 0
	mismatch = 0
	total = 0
	for ( n=entries-1; n>=0; n-- ) {
		k = stringstress_lookup_key(n)
		if ( ! ( k in table ) )
			missing++
		else {
			v = table[k]
			if ( v != stringstress_value(n) )
				mismatch++
			total += sizeof(v)
		}
	}
	failures += stringstress_check("lookup-missing",missing,0)
	failures += stringstress_check("lookup-mismatch",mismatch,0)
	failures += stringstress_check("lookup-bytes",total,expected_total)

	for ( n=0; n<entries; n=n+2 )
		delete table[stringstress_lookup_key(n)]
	garbcollect()

	failures += stringstress_check("delete-size",sizeof(table),entries/2)

	mismatch = 0
	survivor_total = 0
	expected_survivor_total = 0
	for ( n=1; n<entries; n=n+2 ) {
		k = stringstress_lookup_key(n)
		if ( ! ( k in table ) )
			mismatch++
		else if ( table[k] != stringstress_value(n) )
			mismatch++
		survivor_total += sizeof(table[k])
		expected_survivor_total += sizeof(stringstress_value(n))
	}
	failures += stringstress_check("survivor-mismatch",mismatch,0)
	failures += stringstress_check("survivor-bytes",survivor_total,
		expected_survivor_total)

	attr_count = 96
	attrs = ""
	for ( n=0; n<attr_count; n++ ) {
		if ( n > 0 )
			attrs += ","
		attrs += "c`attr_" + sprintf("%03d",n) + "`"
	}
	attrs += ","
	phr = phrase(attrs)
	garbcollect()

	n = 0
	badattrs = 0
	for ( nt in phr ) {
		want = "attr_" + sprintf("%03d",n)
		if ( nt.attrib != want )
			badattrs++
		n++
	}
	failures += stringstress_check("attrib-count",n,attr_count)
	failures += stringstress_check("attrib-mismatch",badattrs,0)

	failures += stringstress_check("literal-root",
		stringstress_literal_root(75),"literal:alpha:beta:gamma")
	garbcollect()
	failures += stringstress_check("post-gc-literal-root",
		stringstress_literal_root(75),"literal:alpha:beta:gamma")

	Stringstress_task_result = ""
	tid = task stringstress_task("alpha")
	wait(tid)
	failures += stringstress_check("task-stack-root",
		Stringstress_task_result,
		stringstress_task_value("alpha",77) + ":" +
			stringstress_task_value("alpha",128))
	garbcollect()

	f = open()
	for ( n=0; n<24; n++ )
		put(f,stringstress_fifo_value(n))
	garbcollect()
	fifo_failures = 0
	for ( n=0; n<24; n++ ) {
		v = get(f)
		if ( v != stringstress_fifo_value(n) )
			fifo_failures++
	}
	close(f)
	failures += stringstress_check("fifo-shadow-values",fifo_failures,0)
	garbcollect()

	reuse_table = []
	for ( n=0; n<220; n++ )
		reuse_table[n] = stringstress_reuse_value(n)
	delete reuse_table
	garbcollect()
	rescued = []
	for ( n=0; n<220; n=n+17 )
		rescued[stringstress_reuse_value(n)] =
			stringstress_reuse_value(219-n)
	garbcollect()
	reuse_failures = 0
	for ( n=0; n<220; n=n+17 ) {
		k = stringstress_reuse_value(n)
		if ( rescued[k] != stringstress_reuse_value(219-n) )
			reuse_failures++
	}
	failures += stringstress_check("quarantine-reuse",reuse_failures,0)
	failures += stringstress_check("object-gc-values",
		stringstress_object_check(),0)
	return(failures)
}

function stringsoak_check(label, got, want) {
	if ( got == want ) {
		print("ok",label)
		return(0)
	}
	print("FAIL",label,"got",got,"want",want)
	return(1)
}

function stringsoak_check_min(label, got, want) {
	if ( got >= want ) {
		print("ok",label)
		return(0)
	}
	print("FAIL",label,"got",got,"want-at-least",want)
	return(1)
}

function stringsoak_key(c,n) {
	return("soak:" + sprintf("%04d",c%10000) + ":" + sprintf("%04d",n) +
		":" + substr("abcdefghijklmnopqrstuvwxyz0123456789",(n%24)+1,8))
}

function stringsoak_lookup_key(c,n) {
	k = stringsoak_key(c,n)
	return(substr("<<" + k + ">>",3,sizeof(k)))
}

function stringsoak_value(c,n) {
	return("value:" + sprintf("%04d",c%10000) + ":" + sprintf("%04d",n) +
		":" + substr("ZYXWVUTSRQPONMLKJIHGFEDCBA9876543210",(n%24)+1,9))
}

function stringsoak_literal() {
	return("bytecode-literal-survives-garbcollect")
}

function stringsoak_fifo_value(c,n) {
	return("fifo-soak:" + sprintf("%04d",c%10000) + ":" +
		sprintf("%03d",n) + ":" + stringsoak_literal())
}

function stringsoak_task_value(c,n) {
	return("task-soak:" + sprintf("%04d",c%10000) + ":" + sprintf("%03d",n))
}

function stringsoak_task(c) {
	local_table = []
	for ( n=0; n<48; n++ )
		local_table[stringsoak_task_value(c,n)] =
			stringsoak_task_value(c,47-n)
	garbcollect()
	Stringsoak_task_result = local_table[stringsoak_task_value(c,17)]
}

class stringsoak_object_holder {
method init {
	$.bag = []
	$.label = ""
	$.value = ""
}
method put(k,v) {
	$.label = k
	$.value = v
	$.bag[$.label] = $.value
}
method get(k) {
	kk = substr("[" + k + "]",2,sizeof(k))
	return($.bag[kk] + ":" + $.label + ":" + $.value)
}
}

function stringsoak_object_check(c) {
	failures = 0
	o = new stringsoak_object_holder()
	for ( n=0; n<8; n++ ) {
		k = "soak-object:" + sprintf("%04d",c%10000) + ":" +
			sprintf("%03d",n)
		v = stringsoak_value(c,n) + ":object"
		o.put(k,v)
		garbcollect()
		if ( o.get(k) != (v + ":" + k + ":" + v) )
			failures++
	}
	delete o
	garbcollect()
	return(failures)
}

function stringsoak_check_parts(k,c,n) {
	parts = split(k,":")
	if ( sizeof(parts) != 4 )
		return(1)
	if ( parts[0] != "soak" )
		return(1)
	if ( parts[1] != sprintf("%04d",c%10000) )
		return(1)
	if ( parts[2] != sprintf("%04d",n) )
		return(1)
	return(0)
}

function stringsoak_cycle(c) {
	failures = 0
	batch = 224
	table = []
	roots = []
	total = 0
	expected_total = 0

	for ( n=0; n<batch; n++ ) {
		k = stringsoak_key(c,n)
		v = stringsoak_value(c,n)
		table[k] = v
		if ( n < 32 )
			roots[n] = substr("root:" + k + ":" + v,1)
		if ( stringsoak_check_parts(k,c,n) != 0 )
			failures++
		if ( substr("[" + v + "]",2,sizeof(v)) != v )
			failures++
		expected_total += sizeof(v)
	}

	garbcollect()

	if ( sizeof(table) != batch )
		failures++

	for ( n=batch-1; n>=0; n-- ) {
		k = stringsoak_lookup_key(c,n)
		if ( ! ( k in table ) )
			failures++
		else if ( table[k] != stringsoak_value(c,n) )
			failures++
		total += sizeof(table[k])
	}
	if ( total != expected_total )
		failures++

	for ( n=0; n<batch; n=n+3 )
		delete table[stringsoak_lookup_key(c,n)]

	garbcollect()

	for ( n=0; n<batch; n++ ) {
		k = stringsoak_lookup_key(c,n)
		if ( (n%3) == 0 ) {
			if ( k in table )
				failures++
		}
		else if ( table[k] != stringsoak_value(c,n) )
			failures++
	}

	attrs = ""
	for ( n=0; n<40; n++ ) {
		if ( n > 0 )
			attrs += ","
		attrs += "c`soak_" + sprintf("%04d",c%10000) + "_" +
			sprintf("%02d",n) + "`"
	}
	attrs += ","
	phr = phrase(attrs)
	n = 0
	for ( nt in phr ) {
		want = "soak_" + sprintf("%04d",c%10000) + "_" + sprintf("%02d",n)
		if ( nt.attrib != want )
			failures++
		n++
	}
	if ( n != 40 )
		failures++

	garbcollect()
	if ( stringsoak_literal() != "bytecode-literal-survives-garbcollect" )
		failures++

	f = open()
	for ( n=0; n<10; n++ )
		put(f,stringsoak_fifo_value(c,n))
	garbcollect()
	for ( n=0; n<10; n++ ) {
		if ( get(f) != stringsoak_fifo_value(c,n) )
			failures++
	}
	close(f)

	if ( (c % 5) == 0 ) {
		Stringsoak_task_result = ""
		tid = task stringsoak_task(c)
		wait(tid)
		if ( Stringsoak_task_result != stringsoak_task_value(c,30) )
			failures++
		garbcollect()
	}

	failures += stringsoak_object_check(c)

	return(failures)
}

function stringsoak(run_ms,min_ms) {
	na = nargs()
	if ( na < 1 ) {
		run_ms = 61000
		min_ms = 60000
	}
	else if ( na < 2 )
		min_ms = run_ms
	if ( run_ms < 1 )
		run_ms = 1
	if ( min_ms < 1 )
		min_ms = 1

	start_ms = milliclock()
	end_ms = start_ms + run_ms
	cycles = 0
	failures = 0

	while ( milliclock() < end_ms ) {
		failures += stringsoak_cycle(cycles)
		cycles++
	}

	elapsed = milliclock() - start_ms
	cycle_failures = failures
	failures += stringsoak_check_min("soak-cycles",cycles,1)
	failures += stringsoak_check("soak-integrity",cycle_failures,0)
	failures += stringsoak_check_min("soak-elapsed-ms",elapsed,min_ms)
	return(failures)
}
