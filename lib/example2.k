function testit() {
	r = ''
	for ( i=30; i<100; i++ ) {
		p = '';
		p |= makenote(i-12);
		p |= makenote(i);
		p |= makenote(i+12);
		p.length = 1b/8;
		r += p;
	}
	return(r)
}

function fiverandomfiles() {
	# create an array with 5 phrases read from 5 files
	f = []

	# f[0] = readmf("file1.mid");
	# f[1] = readmf("file2.mid");
	# f[2] = readmf("file3.mid");
	# f[3] = readmf("file4.mid");
	# f[4] = readmf("file5.mid");

	f[0] = 'a'
	f[1] = 'b'
	f[2] = 'c'
	f[3] = 'd'
	f[4] = 'e'
	t = Now
	while ( 1 ) {
		r = rand(5)
		realtime(f[r],t)
		t += f[r].length
		sleeptill(t)
	}
}

function rand20() {
     r = ''
     for ( n=0; n<20; n++ ) {
          # See basic1.k for the definition of the makenote function.
          # The arguments are pitch and duration
          r += makenote(rand(127),1b/8)
     }
     return(r)
}
# A function which returns chromatic notes
function chromatic(n1,n2) {
     r = ''
     for ( n=n1; n<=n2; n++ ) {
          r += makenote(n,1b/8)
     }
     return(r)
}

function stackhack(n) {
	a = 1
	b = 2
	c = 3
	d = 4
	e = 5
	if ( n <= 0 )
		return()
	stackhack(n-1)
}
