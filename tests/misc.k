if ( defined(Clicks) ) print "yes"
if ( defined(cut) ) print "yes"
if ( ! defined(xyzzy) ) print "yes"
xyzzy=5
if ( defined(xyzzy) ) print "yes"
undefine(xyzzy)
if ( ! defined(xyzzy) ) print "yes"
a="print a"
eval a
a="for (n="+"0;n<10;n++) print "+" n"
print "a is ",a
eval a
function ngs(a,b,c) { print nargs() }
ngs(1)
ngs(2)
ngs(1,2)
ngs(1,2,'a')
print sizeof("abcde")
print sizeof('a,b,c')
print sizeof('a b c')
arr = []
arr[0] = 1
for ( i in arr ) delete arr[i]
for ( n=10; n>0; n-- ) arr[n] = rand(20)
for ( n=20; n>10; n-- ) arr[n] = makenote(n)
print sizeof(arr)
print typeof(arr[2]),typeof(arr[12])
if ( 'a,b'.type == NOTE ) print "yes"
if ( '+a,+b'.type == NOTEON ) print "yes"
if ( '-a,-b'.type == NOTEOFF ) print "yes"
if ( 'xfe'.type == MIDIBYTES ) print "yes"
if ( 'a,xf3,-b'.type == MIDIBYTES ) print "yes"
a='a,b'
if ( a == phrase("'a,b'") ) print "yes"
if ( typeof(string(a)) == "string" ) print "yes"
arr = []
for ( n=0; n<100; n++ ) arr[n] = 100-n
for ( n=100; n>=0; n-- ) if ( ! (n in arr) )
	print "no" ; else print "yes"
if ( typeof(float("4.55")+integer("4")) != "float" )
	print "no" ; else print "yes"
if ( phrase(string("'a,xfff7'")) != 'a,xfff7')
	print "no" ; else print "yes"
print float("4.5")+integer(3.8)*float(3)
