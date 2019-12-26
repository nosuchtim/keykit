# An example of writing the bytes of a sysex message to a file
function example13 {
	msg = 'xf000010203'      # random sysex message
	f = open("tmp.syx","w")
	fifoctl(f,"type","b")    # says you want to write binary data
	for ( k=1; (nt=subbytes(msg,k,1)) != ''; k++ ) {
		put(f,integer(nt))
	}
	close(f)
}
