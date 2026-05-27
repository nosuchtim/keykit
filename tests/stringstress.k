function check(label, got, want) {
	if ( got == want )
		print("ok",label)
	else
		print("FAIL",label,"got",got,"want",want)
}

function make_key(n) {
	return("key:" + sprintf("%04d",n) + ":" + substr("abcdefghijklmnopqrstuvwxyz",(n%17)+1,5))
}

function make_lookup_key(n) {
	k = make_key(n)
	return(substr("<<" + k + ">>",3,sizeof(k)))
}

function make_value(n) {
	return("value:" + sprintf("%04d",n) + ":" + substr("ZYXWVUTSRQPONMLKJIHGFEDCBA",(n%19)+1,6))
}

function literal_root(n) {
	s = "literal:alpha:beta:gamma"
	for ( i=0; i<n; i++ )
		s = substr("!" + s + "?",2,sizeof(s))
	return(s)
}

function shadow_task_value(seed,n) {
	return("task-shadow:" + seed + ":" + sprintf("%04d",n))
}

function shadow_task(seed) {
	local_table = []
	local_keep = shadow_task_value(seed,77)
	for ( n=0; n<140; n++ )
		local_table[shadow_task_value(seed,n)] = shadow_task_value(seed,139-n)
	garbcollect()
	Shadow_task_result = local_keep + ":" + local_table[shadow_task_value(seed,11)]
}

function shadow_fifo_value(n) {
	return("fifo-shadow:" + sprintf("%04d",n) + ":" + literal_root(6))
}

function shadow_reuse_value(n) {
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
		k = "object-key:" + sprintf("%04d",n) + ":" + literal_root(4)
		v = "object-value:" + sprintf("%04d",23-n) + ":" + make_value(n)
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

entries = 1600
table = []
expected_total = 0

for ( n=0; n<entries; n++ ) {
	k = make_key(n)
	v = make_value(n)
	table[k] = v
	expected_total += sizeof(v)
}
garbcollect()

check("populate-size",sizeof(table),entries)

missing = 0
mismatch = 0
total = 0
for ( n=entries-1; n>=0; n-- ) {
	k = make_lookup_key(n)
	if ( ! ( k in table ) )
		missing++
	else {
		v = table[k]
		if ( v != make_value(n) )
			mismatch++
		total += sizeof(v)
	}
}
check("lookup-missing",missing,0)
check("lookup-mismatch",mismatch,0)
check("lookup-bytes",total,expected_total)

for ( n=0; n<entries; n=n+2 )
	delete table[make_lookup_key(n)]
garbcollect()

check("delete-size",sizeof(table),entries/2)

mismatch = 0
survivor_total = 0
expected_survivor_total = 0
for ( n=1; n<entries; n=n+2 ) {
	k = make_lookup_key(n)
	if ( ! ( k in table ) )
		mismatch++
	else if ( table[k] != make_value(n) )
		mismatch++
	survivor_total += sizeof(table[k])
	expected_survivor_total += sizeof(make_value(n))
}
check("survivor-mismatch",mismatch,0)
check("survivor-bytes",survivor_total,expected_survivor_total)

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
check("attrib-count",n,attr_count)
check("attrib-mismatch",badattrs,0)

check("literal-root",literal_root(75),"literal:alpha:beta:gamma")
garbcollect()
check("post-gc-literal-root",literal_root(75),"literal:alpha:beta:gamma")

Shadow_task_result = ""
tid = task shadow_task("alpha")
wait(tid)
check("task-stack-root",Shadow_task_result,
	shadow_task_value("alpha",77) + ":" + shadow_task_value("alpha",128))
garbcollect()

f = open()
for ( n=0; n<24; n++ )
	put(f,shadow_fifo_value(n))
garbcollect()
fifo_failures = 0
for ( n=0; n<24; n++ ) {
	v = get(f)
	if ( v != shadow_fifo_value(n) )
		fifo_failures++
}
close(f)
check("fifo-shadow-values",fifo_failures,0)
garbcollect()

reuse_table = []
for ( n=0; n<220; n++ )
	reuse_table[n] = shadow_reuse_value(n)
delete reuse_table
garbcollect()
rescued = []
for ( n=0; n<220; n=n+17 )
	rescued[shadow_reuse_value(n)] = shadow_reuse_value(219-n)
garbcollect()
reuse_failures = 0
for ( n=0; n<220; n=n+17 ) {
	k = shadow_reuse_value(n)
	if ( rescued[k] != shadow_reuse_value(219-n) )
		reuse_failures++
}
check("quarantine-reuse",reuse_failures,0)
check("object-gc-values",stringstress_object_check(),0)
