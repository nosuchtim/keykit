function strindex(s1,s2) {
	lng1 = sizeof(s1)
	lng2 = sizeof(s2)
	# substr starting values start at 1, not 0
	for ( n=1; n<=lng1; n++ ) {
		if ( substr(s1,n,lng2) == s2 )
			return(n)
	}
	return(-1)
}

function debugfile(s) {
	f = open("key.tmp","a")
	put(f,s)
	put(f,"\n")
	close(f)
}

function controllerlist(noextra) {
	if ( nargs() < 1 || noextra == 0 ) {
		c = [
			0 = ["name"="Volume (07)","value"=0x07],
			1 = ["name"="Express(0b)","value"=0x0b],
			2 = ["name"="Modulat(01)","value"=0x01],
			3 = ["name"="Pan    (0a)","value"=0x0a],
			4 = ["name"="Reverb (5b)","value"=0x5b],
			5 = ["name"="Chorus (5d)","value"=0x5d]
		]
	} else {
		c = []
	}
	# We want to add all the other controller numbers.
	for ( n=0; n<128; n++ ) {
		i = sizeof(c)
		s = "#"+string(n)
		if ( n == 1 )
			s += ",Mod"
		else if ( n == 2 )
			s += ",Breath"
		else if ( n == 4 )
			s += ",Foot"
		else if ( n == 5 )
			s += ",PortTm"
		else if ( n == 7 )
			s += ",Vol"
		else if ( n == 11 )
			s += ",Expr"
		else if ( n == 10 )
			s += ",Pan"
		else if ( n == 65 )
			s += ",Port"
		else if ( n == 66 )
			s += ",Sosten"
		else if ( n == 67 )
			s += ",SftPdl"
		else if ( n == 91 )
			s += ",Reverb"
		else if ( n == 93 )
			s += ",Chorus"
		else if ( n == 95 )
			s += ",Phaser"
		else if ( n == 96 )
			s += ",Data+"
		else if ( n == 97 )
			s += ",Data-"
		c[i] = ["name"=s,"value"=n]
	}
	return(c)
}

function toolnotes(p) {
	return ( p { ??.attrib != "" && ( "H" in attribarray(??.attrib) ) } )
}

function makeholdernote(x0,x1,h) {
	dx = x1 - x0
	p = 'a'
	p.pitch = 0
	p.time = x0
	p.dur = dx
	p.length = dx
	p.vol = 0
	# The value of the attribute is a constant object reference
	# (as a string)
	p.attrib = "H="+h.getholdername()
	return(p)
}

function note2holder(nt) {
	a = nt.attrib
	if ( a == "" )
		return($0)
	arr = attribarray(a)
	# holders have "H" attributes, but other notes
	# can have attributes, too.
	if ( ! ( "H" in arr ) ) {
		return($0)
	}
	holdername = arr["H"]
	if ( ! (holdername in Holder_name2obj) ) {
		print("No Holder_name2obj named '"+holdername+"'")
		h = $0
	} else {
		h = Holder_name2obj[holdername]
	}
	return(h)
}

function permutations(phr,stepit) {
	if ( typeof(phr) != "phrase" ) {
		print("usage: permutations(phrase [,stepit])")
		return()
	}
	if ( nargs() < 2 )
		stepit = 0
	phr = strip(phr)
	nn = sizeof(phr)
	values = []
	for ( i=0; i<nn; i++ )
		values[i] = 0
	results = []
	permutations_visit(0,nn,values,-1,phr,results,stepit)
	return(results)
}

function permutations_visit(k,nn,values,level,phr,results,stepit) {
	values[k] = ++level
	if ( level == nn ) {
		# Generate one permutation phrase
		r = ''
		for ( i=0; i<nn; i++ ) {
			nt = phr%(values[i])
			nt.time = 0
			if ( stepit ) {
				nt.length = 1b
				nt.dur = 1b
			} else {
				nt.length = nt.dur
			}
			r += nt
		}
		results[sizeof(results)] = r
	} else {
		for ( i=0; i<nn; i++ ) {
			if ( values[i] == 0 )
				permutations_visit(i,nn,values,level,
					phr,results,stepit)
		}
	}
	level--
	values[k] = 0
}

# The port functions and bpm function below were contributed
# by Nato Welch, nato@spintheweb.com

#name	listports
#usage	listports()
#desc	A simple utility that lists the available MIDI ports to the console.

function listports () {

	old = Arraysort
	Arraysort = 1
	print("\nINPUTS:")
	inlist = midi("input","list")
	for ( nx in inlist ) {
		if ( midi("input","isopen",nx) )
			nk = "*" 
		else
			nk = "" 
		print(string(nx) + "= "+ inlist[nx] + nk)
	}
	print("\nOUTPUTS:")
	outlist = midi("output","list")
	for ( nx in outlist ) {
		if ( midi("output","isopen",nx) )
			nk = "*" 
		else
			nk = "" 
		print(string(nx) + "= "+ outlist[nx] + nk)
	}
	Arraysort = old
}

#name	inport
#usage	inport(port)
#desc	Open a MIDI input port

function inport (port) {
	return(lookforandopen("input",port))
}

#name	outport
#usage	outport(port)
#desc	Opena a MIDI output port

function outport (port) {
	return(lookforandopen("output",port))
}

function mapport(ip,op) {
	for ( c=1; c<=16; c++ ) {
		midi("portmap",ip,c,op)
	}
}

function portsopened() {
	old = Arraysort
	Arraysort = 1
	opened = [0="default"]
	outlist = midi("output","list")
	nout = 1
	for ( nx in outlist ) {
		if ( midi("output","isopen",nx) )
			opened[nout++] = outlist[nx]
	}
	Arraysort = old
	return(opened)
}

function lookforandopen(iotype,port,verbose) {
	if ( nargs() < 3 )
		verbose = 1
	arr = midi(iotype,"list")
	if ( typeof(port) == "string" ) {
		found = lookforport(iotype,port)
		if ( found < 0 ) {
			if ( verbose ) {
				print("No "+iotype+" port named: "+string(port))
			}
			return(-1)
		}
		port = found
	}
	if ( midi(iotype,"isopen",port) ) {
		if ( verbose )
			print("Port is already open!  ("+iotype+" "+string(port)+", "+arr[port]+")")
	} else {
		midi(iotype,"open",port)
	}
	return(port)
} 

function lookforport(iotype,port) {
	if ( typeof(port) == "string" ) {
		arr = midi(iotype,"list")
		if ( substr(port,1,1) == "^" ) {
			matchexpr = port + ".*"
		} else {
			matchexpr = ".*" + port + ".*";
		}
		found = -1
		old = Arraysort
		Arraysort = 1
		for ( i in arr ) {
			if ( arr[i] ~~ matchexpr ) {
				found = i
				break
			}
		}
		Arraysort = old
		if ( found < 0 ) {
			return(-1)
		}
		port = found
	}
	return(port)
} 

#name	bpm
#usage	bpm(beatsperminute)
#desc	Changes the tempo based on beats per minute,
#desc	rather than microseconds per beat

function bpm(bpm) {
	tempo(1000000/(float(bpm)/60))
	return( 60/( float(tempo( ))/1000000) ) 
}


#name	gcd2
#usage	gcd2(n1,n2)
#desc	Returns the greatest common divisor of two integers

function gcd2(n1,n2) {
	while ( (n1 % n2) > 0 ) {
		t = n1 % n2
		n1 = n2;
		n2 = t;
	}
	return(n2)
}

function lcm(...){
	if (nargs()==0) return(1)
	if (nargs()==1) return(argv(0))
	if (nargs()==2) return(argv(0)*argv(1)/gcd(argv(0),argv(1)))
	if (nargs()>2)  return(lcm(lcm(varg(argv(1,nargs()))),argv(0)))
}

#name	gcd
#usage	gcd(n1,...)
#desc	Returns the greatest common divisor of all of its arguments

function gcd(...) {
	n = nargs()
	if (n==0) return(1)
	if (n==1) return(argv(0))
	if (n==2) return(gcd2(argv(0),argv(1)))
	if (n>2)  return(gcd2(gcd(varg(argv(1,n))),argv(0)))
}

#name	pathescape
#usage	pathescape(s)
#desc	Takes a file pathname, and returns a version of
#desc	the string that can be safely printed to a file and re-read.
function pathescape(s) {
	r = ""
	for ( n=1; n<=sizeof(s); n++ ) {
		c = substr(s,n,1)
		if ( c == "\\" )
			r += "\\"
		r += c
	}
	return(r)
}

#name	evalstring
#usage	evalstring(s)
#desc	Takes a string and evals it.  Useful when you want to
#desc	put something in the background - you just "task evalstring(...)"
function evalstring(s) {
	eval s;
}

#name	limitval
#usage	limitval(v,minv,maxv)
#desc	Takes a number and limits it to the specified range.
function limitval(v,minv,maxv) {
	if ( v < minv )
		v = minv
	else if ( v > maxv )
		v = maxv
	return(v)
}

#name	fxy
function fxy(fx0,fy0,fx1,fy1) {
	n = nargs()
	if ( n == 4 )
		return(["x0"=fx0,"y0"=fy0,"x1"=fx1,"y1"=fy1])
	else if ( n == 2 )
		return(["x0"=fx0,"y0"=fy0])
	execerror("Bad number of arguments to fxy()")
}

function setdefaultchancolormap() {
	# set channel colors to default setup (not very carefully chosen)
	colors = [
		1= ["r"=65535,"g"=0,"b"=0],
		2= ["r"=0,"g"=65535,"b"=0],
		3= ["r"=0,"g"=0,"b"=65535],
		4= ["r"=65535,"g"=65535,"b"=0],
		5= ["r"=65535,"g"=0,"b"=65535],
		6= ["r"=0,"g"=65535,"b"=65535],
		7= ["r"=65535,"g"=20000,"b"=0],
		8= ["r"=20000,"g"=65535,"b"=0],
		9= ["r"=20000,"g"=0,"b"=65535],
		10= ["r"=65535,"g"=65535,"b"=20000],
		11= ["r"=65535,"g"=20000,"b"=65535],
		12= ["r"=20000,"g"=65535,"b"=65535],
		13= ["r"=65535,"g"=40000,"b"=20000],
		14= ["r"=40000,"g"=65535,"b"=20000],
		15= ["r"=40000,"g"=20000,"b"=65535],
		16= ["r"=65535,"g"=65535,"b"=40000]
		]
	for ( ch=1; ch<=16; ch++ ) {
		colornum = ch + 16
		colormix(colornum,colors[ch]["r"],colors[ch]["g"],colors[ch]["b"])
		Chancolormap[ch] = colornum
	}
}

function chancolortestphrase() {
	p = ''
	for ( ch=1; ch<=16; ch++ ) {
		p += makenote(64,1b,64,ch)
	}
	return(p)
}

function forwardmidi(port1,port2) {
	Midiin[$] = f = open()
	onexit(closemidi,$)

	while ( (n=get(f)) != Eof ) {
		print("MIDI IN! N = ",n)
	}
}

function getenv(variable) {
	value=mdep("env","get",variable)
	if ( !defined(value) ) {
		value = ""
	}
	return(value)
}
