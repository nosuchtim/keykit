# This is an example that reads text lines from a file and
# generates a phrase from them, and then puts the results 
# in a standard midifile.

function example10(infile,outfile) {
	f = open(infile)
	result = ''
	while ( (ln=get(f)) != Eof ) {
		# Assume the line is a series of comma-separated pitches.
		# Split them up and convert into notes, and add to result
		arr = split(ln,",")
		for ( i in arr ) {
			nt = makenote(arr[i])
			result += nt
		}
	}
	writemf(result,outfile)
	close(f)
}
