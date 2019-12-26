#name	readkey
#usage	readkey(filename)
#desc	This function reads a phrase from the specified file, which is
#desc	is expected to contain a phrase in KeyKit format, i.e. the
#desc	same as a phrase constant in the KeyKit language.

function readkey(fname) {
	a = readphr(fname)
	n = sizeof(a)
	if ( n == 0 ) {
		print("File \""+fname+"\" is either empty, doesn't contain")
		print("a phrase, or is non-existent!  Perhaps you need to set")
		print("Musicpath?  (it's current value is",Musicpath,")")
	}
	else
		print("File \""+fname+"\" read - ",n,"notes")
	return(a)
}

#name	readfile
#usage	readfile(filename)
#desc	This function reads an entire file (all lines of it)
#desc	and returns it as a single string.
#desc   NOTE: might or might not read the newlines at the end of lines
#desc   Currently it gets rid of the newlines, but that's not good.
#desc   I'm reluctant to change it without checking whether it breaks something.

function readfile(fname) {
	f = open(fname)
	if ( f < 0 ) {
		return("")
	}
	r = ""
	while ( (s=get(f)) != Eof ) {
		r += s
	}
	close(f)
	return(r)
}

#name	readraw
#usage	readraw(filename)

function readraw(fname) {
	f = open(fname,"r")
	fifoctl(f,"type","b")
	r = ''
	while ( (c=get(f)) != Eof ) {
		if ( c < 0 )
			print("Hey, c<0 = ",c)
		r = midibytes(r,c)
	}
	close(f)
	return(r)
}

#name	filetopitches
#usage	filetopitches(filename)

function filetopitches(fname) {
	fn = pathsearch(fname)
	if ( ! fileexists(fn) ) {
		print("Can't find file: ",fn)
		return('')
	}
	f = open(fn,"r")
	fifoctl(f,"type","b")
	r = ''
	a = 'a'
	a.dur = 1b/8
	a.length = 1b/8
	while ( (c=get(f)) != Eof ) {
		if ( c < 0 )
			print("Hey, c<0 = ",c)
		a.pitch = c%128
		r += a
	}
	close(f)
	return(r)
}

function readrawplay(fname) {
	f = open(fname,"r")
	fifoctl(f,"type","b")
	while ( (c=get(f)) != Eof ) {
		realtime(midibytes(c))
		millisleep(10)
	}
	close(f)
}

#name	readmf
#usage	readmf(filename)
#desc	Reads the specified Standard MIDI File and returns its
#desc	contents as a single phrase (with all tracks merged).

function readmf(fname,verbose) {
	mfarr = midifile(fname)
	r = ''
	for ( i in mfarr )
		r |= mfarr[i]
	if ( nargs() > 1 ) {
		n = sizeof(r)
		if ( n == 0 ) {
			print("File \""+fname+"\" is either empty or non-existent!")
			print("Perhaps you need to set Musicpath?  (it's current value is",Musicpath,")")
		}
		else
			print("File \""+fname+"\" read - ",n,"notes")
	}
	return (r)
}
function readmid(fname) {
	return(readmf(fname))
}
# Read a Standard MIDI File and split each track onto a separate channel
         
function readmfchan(fname, a,n,r,mfarr,i,x) {
	mfarr = midifile(fname)
	r = ''  
	for ( i in mfarr ) {
		x=onlynotes(mfarr[i])
		r |= setchan(x,i)
	}
	n = sizeof(r)
	if ( n == 0 ) {
		print("File \""+fname+"\" is either empty or non-existent.")
		print("Perhaps you need to set Musicpath?  (it's current value is "+Musicpath+")")
	}
	else
		print("File \""+fname+"\" read - ",n,"notes")
	return (r) 
}                       

function suffixof(fname) {
	parts = split(fname,".")
	return (parts[sizeof(parts)-1])
}

function browsephrase() {
	fname = browsefiles("Music (*.MID,*.K,*.KG)","*.mid;*.k;*.kg",1)
	if ( ! fileisreadable(fname) ) {
		print("File",fname,"doesn't exist!?")
		return('')
	}
	suff = suffixof(fname)
	if ( suff == "mid" || suff == "MID" )
		ph = readmf(fname)
	else if ( suff == "k" || suff == "K" )
		ph = readkey(fname)
	else {
		print("Unrecognized file name type!?")
		return('')
	}
	if ( sizeof(ph) <= 0 ) {
		print("That file's nonexistant or empty!?")
		return('')
	}
	if ( ph.length <= 0 )
		ph.length = numquant(latest(ph),Met.length)
	if ( (ph%1).time > (Met.length/2) ) {
		ph.time -= Met.length
		ph.length -= Met.length
	}
	return(ph)
}

function browsesyx() {
	fname = browsefiles("Sysex (*.mid,*.syx)","*.syx;*.mid",1)
	if ( ! fileisreadable(fname) ) {
		print("File",fname,"doesn't exist!?")
		return('')
	}
	suff = suffixof(fname)
	if ( suff == "mid" || suff == "MID" )
		a = readmf(fname)
	else if ( suff == "syx" || suff == "SYX" )
		a = readraw(fname)
	else {
		print("Unrecognized file type!?")
		return('')
	}
	if ( sizeof(a) <= 0 )
		print("That file's nonexistant or empty!?")
	return(a)
}
