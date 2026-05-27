function check(label, got, want) {
	if ( got == want )
		print("ok",label)
	else
		print("FAIL",label,"got",got,"want",want)
}

function check_min(label, got, want) {
	if ( got >= want )
		print("ok",label)
	else
		print("FAIL",label,"got",got,"want-at-least",want)
}

function soak_key(c,n) {
	return("soak:" + sprintf("%04d",c%10000) + ":" + sprintf("%04d",n) + ":" +
		substr("abcdefghijklmnopqrstuvwxyz0123456789",(n%24)+1,8))
}

function soak_lookup_key(c,n) {
	k = soak_key(c,n)
	return(substr("<<" + k + ">>",3,sizeof(k)))
}

function soak_value(c,n) {
	return("value:" + sprintf("%04d",c%10000) + ":" + sprintf("%04d",n) + ":" +
		substr("ZYXWVUTSRQPONMLKJIHGFEDCBA9876543210",(n%24)+1,9))
}

function bytecode_literal() {
	return("bytecode-literal-survives-garbcollect")
}

function soak_fifo_value(c,n) {
	return("fifo-soak:" + sprintf("%04d",c%10000) + ":" + sprintf("%03d",n) +
		":" + bytecode_literal())
}

function soak_task_value(c,n) {
	return("task-soak:" + sprintf("%04d",c%10000) + ":" + sprintf("%03d",n))
}

function soak_task(c) {
	local_table = []
	for ( n=0; n<48; n++ )
		local_table[soak_task_value(c,n)] = soak_task_value(c,47-n)
	garbcollect()
	Soak_task_result = local_table[soak_task_value(c,17)]
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

function soak_object_check(c) {
	failures = 0
	o = new stringsoak_object_holder()
	for ( n=0; n<8; n++ ) {
		k = "soak-object:" + sprintf("%04d",c%10000) + ":" + sprintf("%03d",n)
		v = soak_value(c,n) + ":object"
		o.put(k,v)
		garbcollect()
		if ( o.get(k) != (v + ":" + k + ":" + v) )
			failures++
	}
	delete o
	garbcollect()
	return(failures)
}

function check_parts(k,c,n) {
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

function run_cycle(c) {
	failures = 0
	batch = 224
	table = []
	roots = []
	total = 0
	expected_total = 0

	for ( n=0; n<batch; n++ ) {
		k = soak_key(c,n)
		v = soak_value(c,n)
		table[k] = v
		if ( n < 32 )
			roots[n] = substr("root:" + k + ":" + v,1)
		if ( check_parts(k,c,n) != 0 )
			failures++
		if ( substr("[" + v + "]",2,sizeof(v)) != v )
			failures++
		expected_total += sizeof(v)
	}

	garbcollect()

	if ( sizeof(table) != batch )
		failures++

	for ( n=batch-1; n>=0; n-- ) {
		k = soak_lookup_key(c,n)
		if ( ! ( k in table ) )
			failures++
		else if ( table[k] != soak_value(c,n) )
			failures++
		total += sizeof(table[k])
	}
	if ( total != expected_total )
		failures++

	for ( n=0; n<batch; n=n+3 )
		delete table[soak_lookup_key(c,n)]

	garbcollect()

	for ( n=0; n<batch; n++ ) {
		k = soak_lookup_key(c,n)
		if ( (n%3) == 0 ) {
			if ( k in table )
				failures++
		}
		else if ( table[k] != soak_value(c,n) )
			failures++
	}

	attrs = ""
	for ( n=0; n<40; n++ ) {
		if ( n > 0 )
			attrs += ","
		attrs += "c`soak_" + sprintf("%04d",c%10000) + "_" + sprintf("%02d",n) + "`"
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
	if ( bytecode_literal() != "bytecode-literal-survives-garbcollect" )
		failures++

	f = open()
	for ( n=0; n<10; n++ )
		put(f,soak_fifo_value(c,n))
	garbcollect()
	for ( n=0; n<10; n++ ) {
		if ( get(f) != soak_fifo_value(c,n) )
			failures++
	}
	close(f)

	if ( (c % 5) == 0 ) {
		Soak_task_result = ""
		tid = task soak_task(c)
		wait(tid)
		if ( Soak_task_result != soak_task_value(c,30) )
			failures++
		garbcollect()
	}

	failures += soak_object_check(c)

	return(failures)
}

min_ms = 60000
run_ms = 61000
start_ms = milliclock()
end_ms = start_ms + run_ms
cycles = 0
failures = 0

while ( milliclock() < end_ms ) {
	failures += run_cycle(cycles)
	cycles++
}

elapsed = milliclock() - start_ms
check_min("soak-cycles",cycles,1)
check("soak-integrity",failures,0)
check_min("soak-elapsed-ms",elapsed,min_ms)
