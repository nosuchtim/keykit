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
