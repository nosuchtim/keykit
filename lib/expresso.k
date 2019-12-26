# Expresso
#
# This code takes an expression, parses it, and then mutates it.
#
# The transformations are normally taken from a *.exp file (see default.exp
# for the default set of transformations).
#
# It involves a recursive descent parser, and a lot of uncommented code.
#

ExpressoLimit = 5000

function webexpresso(gen,ntracks,patches,seed1,fn,x,...) {
	initialargs = 6
	scalem = 1
	ntrans = nargs() - initialargs
	transforms = []
	for ( n=0; n<ntrans; n++ ) {
		transforms[argv(initialargs+n)] = 1
	}
	if ( fn != "" ) {
		p = readmf(fn);
		# how many notes we want to pick
		howmany = 20
		p = onlynotes(p);
		lng1 = sizeof(p);
		if ( lng1 > howmany ) {
			rnd1 = rand(lng1-howmany)
			p = p{??.number >= rnd1}
			p = strip(head(p,howmany))
		}
	} else {
		p = phrase("'"+x+"'")
	}

	r = expressomix(transforms,gen,seed1,p,ntracks,patches,scalem,1)

	writemf(r,"www.mid")
	writelines(r,"www.lines")
}

function web_xpress(nbars,gen,ntracks,patches,seed1,factor) {
	r = xpress(nbars,gen,ntracks,patches,seed1,factor)
	writemf(r,"www.mid")
	writelines(r,"www.lines")
}

function xpress2() {
	a=xpress(2,12,3)
	b=xpress(2,12,3)
	b.pitch += 7
	c=xpress(2,12,3)
	c.pitch += 5
	d=xpress(2,12,3)
	d.pitch += 3
	return(a+b+c+d)
}

function xpress(nbars,gen,ntracks,patches,seed1,factor) {

	scalem = 1
	verbose = 0
	autostep = -1
	autoapply = 0
	p = ''

	if ( nargs() < 1 )
		nbars = 10
	if ( nargs() < 2 )
		gen = 10
	if ( nargs() < 3 )
		ntracks = 4
	if ( nargs() < 4 )
		patches = "yes"
	if ( nargs() < 5 )
		seed1 = milliclock()
	if ( nargs() < 6 )
		factor = 2
	
	while ( nbars-- > 0 ) {

		tr = rand(4)
		if ( tr == 0 ) pinit = 'co3,g,co4,co5'
		if ( tr == 1 ) pinit = 'c'
		if ( tr == 2 ) pinit = 'co3 fo4 co5'
		if ( tr == 3 ) pinit = 'co5,fo4,co3'

		aleng = factor * 4b
		q = total_expresso("default",gen,seed1,
			pinit,ntracks,patches,
			scalem,verbose,autostep,autoapply,aleng)
		p += q
		seed1 += 1101	#
	}
	seq = ''
	while ( seq.length < p.length ) {
		seq += 'cc15,c,c,c,g,g,f,f,e-,e-,e-,e-,a-,a-,b-,b-'
	}
	# p = transposeseqinplace(p,seq)
	p = scadjustseqinplace(p,seq)
	d = ''
	while ( d.length < p.length ) {
		d += bsgmdrum4()
		d += 'p35c10,p37,p35,p37'
	}
	# d = d{isonbeat(??,1b)||rand(3)==0}
	d.vol -= 20
	d = cut(d,CUT_TIME,0,p.length,TRUNCATE)
	p |= d
	return(p)
}

function step_32_4b(p) {
	p = step(arpeggio(p),1b/8)
	p = cut(p,CUT_TIME,0,4b)
	p.length = 4b
	return(p)
}

function total_expresso(transforms,gen,seed1,p,ntracks,patches,
		scalem,verbose,autostep,autoapply,autolength,applyphr) {

	p = expressomix(transforms,gen,seed1,p,
		ntracks,patches,scalem,verbose)

	# Remove program changes before applying anything
	p2 = progchangenotes(p)
	p -= p2
	
	astep = autostep
	if ( astep < 0 )
		astep = rand(3) + 1

	if ( astep == 1 ) {
		p = step(arpeggio(p),1b/4)
	} else if ( astep == 2 ) {
		p = step(arpeggio(p),1b/8)
	} else if ( astep == 3 ) {
		p = applyfunc(p,4b,global(step_32_4b))
	} else if ( astep == 4 ) {
		p = arpeggio(p)
	} else if ( astep == 5 ) {
		p = step(arpeggio(p),1b/4)
		tmp2 = onlynotes(p{rand(2)==0})
		p -= tmp2
		tmp2.dur = 1b/2
		p |= tmp2
		p = arpeggio(p)
	}

	if ( autoapply < 0 )
		autoapply = rand(3) + 1


	if ( autoapply == 0 ) {
		# do nothing
	} else if ( autoapply == 1 ) {
		p = scadjust(p,scale_last())
	} else if ( autoapply == 2 ) {
		p = applyfunc(p,4b,global(scadjust_last))
	} else if ( autoapply == 3 ) {
		p = applyfunc(p,4b,global(mono))
	} else if ( autoapply == 4 ) {
		p = scadjust(p,makescale(applyphr))
	} else if ( autoapply == 5 ) {
		r = ''
		if ( applyphr == '' ) {
			print("Empty applyphr")
		} else {
			p = scalevertical(p,lowest(applyphr),highest(applyphr))
			for ( nt in p ) {
				r |= closestmap(nt,applyphr)
			}
			p = r
		}
	} else {
		print("Unrecognized value of autoapply =",autoapply)
	}

	alength = autolength
	if ( alength < 0 ) {
		r = rand(2)
		if ( r == 0 ) alength = 4b
		else alength = 8b
	}

	# Add back program changes
	p |= p2
	if ( alength != 0 ) {
		p = cut(p,CUT_TIME,0,alength,TRUNCATE)
		p.length = alength
	}
	return(p)
}

function expressomix(transforms,gen,seed1,p,ntracks,patches,scalem,verbose) {

	origp = p

	if ( nargs() < 8 )
		verbose = 0
	if ( nargs() < 7 )
		scalem = 1
	if ( nargs() < 6 )
		patches = "no"	# not random

	patchnums = [
			1=1,	# piano
			2=12,	# vibes
			3=28,	# bass
			4=25	# guitar
			];

	# The seed1 will reset randomization in the first track
	trks = []
	maxleng = 0
	for ( trknum=1; trknum <= ntracks; trknum++ ) {
		# seed only gets applied on the first one
		if ( trknum > 1 )
			seed1 = 0
		p = expresso(transforms,gen,seed1,origp)
		if ( verbose )
			print("EXPR = ",Gexpr,"<br><font size=-2><i>random seed used was",seed1,"</i></font>")

		psize = sizeof(p)
		if ( psize > ExpressoLimit ) {
			if ( verbose )
				print("<p>NOTE: Generated phrase was too large (",psize,"), it has been truncated at ",ExpressoLimit," notes.")
			p = head(p,ExpressoLimit)
		}
		p.length = latest(p);
		if ( p.length > maxleng ) {
			maxleng = p.length;
		}
		trks[trknum] = p
	}

	r = ''
	for ( trknum=1; trknum <= ntracks; trknum++ ) {
		p = trks[trknum]
		if ( scalem ) {
			p = strip(p)
			p = scaleng(p,maxleng);
		}
		p.chan = trknum
		if ( patches == "yes" ) {
			pn = rand(127)+1;
			p |= progchange(pn,trknum);
		} else if ( patches == "no" ) {
			pn = patchnums[trknum];
			p |= progchange(pn,trknum);
		}
		r |= p
	}
	# r = scafilt(r,transpose(scale_aeolian(),'c'))
	return(r)
}

function webexpresso_perc(gen,ntracks,patches,seed1,fn,x,...) {
	initialargs = 6
	ntrans = nargs() - initialargs
	transforms = []
	for ( n=0; n<ntrans; n++ ) {
		transforms[argv(initialargs+n)] = 1
	}
	if ( fn != "" ) {
		p = readmf(fn);
		# how many notes we want to pick
		howmany = 20
		p = onlynotes(p);
		lng1 = sizeof(p);
		if ( lng1 > howmany ) {
			rnd1 = rand(lng1-howmany)
			p = p{??.number >= rnd1}
			p = strip(head(p,howmany))
		}
	} else {
		p = phrase("'"+x+"'")
	}

	origp = p

	# The seed1 will reset randomization in the first track
	trks = []
	maxleng = 0
	for ( trknum=1; trknum <= ntracks; trknum++ ) {
		# seed only gets applied on the first one
		if ( trknum > 1 )
			seed1 = 0
		p = expresso(transforms,gen,seed1,origp)
		print("EXPR = ",Gexpr,"<br><font size=-2><i>random seed used was",seed1,"</i></font>")

		psize = sizeof(p)
		if ( psize > ExpressoLimit ) {
			print("<p>NOTE: Generated phrase was too large (",psize,"), it has been truncated at ",ExpressoLimit," notes.")
			p = head(p,ExpressoLimit)
		}
		p.length = latest(p);
		if ( p.length > maxleng ) {
			maxleng = p.length;
		}
		trks[trknum] = p
	}

	r = ''
	for ( trknum=1; trknum <= ntracks; trknum++ ) {
		p = trks[trknum]
		p.chan = 10
		r |= p
	}
	if ( r%1.time < 0 ) {
		print("<p>NOTE: Negative start time adjusted.")
		r.time -= r%1.time
	}
	writemf(r,"www.mid")
	writelines(r,"www.lines")
}

function etest(p) {
	if ( nargs() <= 0 ) {
		p = 'c,e,g'
	}
	return(expresso("default",10,currtime(),p))
	# print ("xx=",xx)
	# print("EXPR = ",Gexpr)
}

function expresso(transforms,gen,seed1,x) {

	if ( typeof(transforms) == "string" ) {
		fname = transforms
		if ( ! ( fname ~~ ".*\\.exp" ) ) {
			fname = fname + ".exp"
		}
		fn = pathsearch(fname)
		if ( fn == "" ) {
			print("Can't find file "+fname)
			return('')
		}
		transforms = read_transforms(fn)
	}
	if ( seed1 != 0 ) {
		rand(-seed1)
	}

	p = gen_expresso(transforms,gen,x,1)
	if ( p%1.time < 0 )
		p.time -= p%1.time
	return(p)
}


Gtokes = []
Gtypes = []
GEN_EOF = -1
GEN_NOTHING = 0
GEN_NUMBER = "number"
GEN_STRING = "string"
GEN_WORD = "word"
GEN_BINOP = "binop"
GEN_UNOP = "unop"
GEN_PUNCT = "punct"

function gen_init_transforms(transforms) {
	n = 0;
	Gtrans_from = []
	Gtrans_to = []
	for ( k in transforms ) {
		b = split(k,"=")
		Gtrans_from[n] = gen_parsexp(b[0])
		Gtrans_to[n] = gen_parsexp(b[1])
		n++
	}
}

function read_transforms(fname) {
	arr = []
	f = open(fname)
	fifoctl(f,"type","l")	# read line-at-a-time
	while ( (ln=get(f)) != Eof ) {
		if ( substr(ln,1,1) != "#" ) {
			arr[ln] = 1
		}
	}
	close(f)
	return(arr)
}

function gran(transforms,g) {
	if ( nargs() < 1 )
		g = 10
	r = ''
	for ( n=0; n<g; n++ ) {
		r += gen_expresso(transforms,10,'cd12,c',0)
	}
	return(r)
}

function gen_expresso(transforms,ng,x,verbose) {

	if ( nargs() < 1 )
		ng = 3
	if ( nargs() < 2 )
		x='cd12,co4,c,c'
	if ( nargs() < 3 )
		verbose = 1

	gen_init_transforms(transforms)
	Gexpr = "X"
	pn = gen_parsexp(Gexpr)

	for ( i=0; i<ng; i++ ) {
		pn = gen_mutate(pn)
	}

	Gexpr = gen_sprint(pn)
	X=x
	eval "GEN="+Gexpr
	return(GEN)
}
function gen_parsexp(s) {
	gen_tokens(s)
	Gpeekn = 0
	gen_peek();	# to prime Glookahead
	return(gen_binopexpr())
}

function gen_isbinop(c) {
	return ( c ~~ "[-+*/|&]" );
}

function gen_subvar(oldvarname,subvarname,subexpr) {
	pn = [];
	op = subexpr["op"]
	if ( op == "var" ) {
		pn["op"] = op
		if ( subexpr["var"] == subvarname ) {
			pn["var"] = oldvarname
		} else {
			pn["var"] = subexpr["var"]
		}
	} else if ( gen_isbinop(op) ) {
		pn["op"] = op
		pn["operand1"] = gen_subvar(oldvarname,subvarname,subexpr["operand1"])
		pn["operand2"] = gen_subvar(oldvarname,subvarname,subexpr["operand2"])

	} else if ( op == "func" ) {
		pn["op"] = op
		pn["func"] = subexpr["func"]
		i = 1
		as = "arg"+string(i)
		while ( as in subexpr ) {
			pn[as] = gen_subvar(oldvarname,subvarname,subexpr[as])
			as = "arg"+string(++i)
		}
	} else if ( op == "number" || op == "string") {
		pn = arraycopy(subexpr)
	} else {
print("WARNING: gen_subvar isn't handling subexpr[op]=",subexpr["op"],", using original var")
		pn["op"] = subexpr["op"]
		pn["var"] = oldvarname
	}
	return(pn)
}

function gen_mutate(pn) {
	if ( typeof(pn) != "array" ) {
		printf("NONARRAY(",pn,")")
	} else if ( pn["op"] == "var" ) {

		# Look through the transformations to see how many
		# "var" ones we have
		nv = 0
		for ( k in Gtrans_from ) {
			pf = Gtrans_from[k]
			if ( pf["op"] == "var" )
				nv++
		}
if ( nv != sizeof(Gtrans_from) ) { print("Gtrans size != nv=",nv,"  non var trans?") }
		prob = 100/nv;
		for ( k in Gtrans_from ) {
			pf = Gtrans_from[k]
			if ( pf["op"] == "var" && (rand(100) < prob) ) {
				# apply it - save the old variable name
				oldvarname = pn["var"]
				subvarname = pf["var"]
				# delete the original array
				for ( i in pn )
					delete(pn[i])
				# copy the transformation, replacing
				# all the instances of subvarname with
				# the oldvarname
				pn = gen_subvar(oldvarname,subvarname,Gtrans_to[k])
				break;
			}
		}

	} else if ( pn["op"] == "number" ) {
		# printf(pn["number"])
	} else if ( pn["op"] == "func" ) {
		# gen_mutate(pn["func"])
		for ( n=1; ; n++ ) {
			a = "arg"+string(n)
			if ( a in pn ) {
				pn[a] = gen_mutate(pn[a])
			} else {
				break
			}
		}
	} else if ( gen_isbinop(pn["op"]) ) {
		# op = pn["op"]
		# if ( op == "+" )
		# 	pn["op"] = "-"
		# else if ( op == "-" )
		# 	pn["op"] = "+"
		pn["operand1"] = gen_mutate(pn["operand1"])
		pn["operand2"] = gen_mutate(pn["operand2"])
	} else {
		# printf(pn["op"])
	}
	return(pn)
}

function gen_sprint(pn) {
	if ( typeof(pn) != "array" ) {
		return("RAW("+pn+")")
	} else if ( pn["op"] == "!" ) {
		return("!("+gen_sprint(pn["operand1"])+")")
	} else if ( pn["op"] == "var" ) {
		return(pn["var"])
	} else if ( pn["op"] == "number" ) {
		return(pn["number"])
	} else if ( pn["op"] == "func" ) {
		r = pn["func"]+"("
		sep = ""
		for ( n=1; ; n++ ) {
			a = "arg"+string(n)
			if ( a in pn ) {
				if ( sep != "" )
					r += sep
				r += gen_sprint(pn[a])
			} else {
				break
			}
			sep = ","
		}
		r += ")"
		return(r)
	} else if ( gen_isbinop(pn["op"]) ) {
		return("("
			+gen_sprint(pn["operand1"])
			+pn["op"]
			+gen_sprint(pn["operand2"])
			+")")
	} else if ( pn["op"] == "string" ) {
		return(pn["string"])
	} else {
		return("(RAWOP=pn="+string(pn)+")")
	}
}

function gen_peek() {
	if ( Gpeekn < sizeof(Gtokes) ) {
		Glookahead = Gtokes[Gpeekn]
		Glookaheadtype = Gtypes[Gpeekn]
	} else {
		Glookahead = EOF
		Glookaheadtype = GEN_EOF
	}
}

function gen_eat() {
	w = Gtokes[Gpeekn++]
	gen_peek()
	return(w)
	
}


function gen_binopexpr() {
	t1 = gen_val_expr();
	while ( Glookaheadtype == GEN_BINOP ) {
		op = gen_eat()
		t2 = gen_val_expr();
		tree = []
		tree["op"] = op
		tree["operand1"] = t1
		tree["operand2"] = t2
		t1 = tree
	}
	return(t1)
}

function gen_val_expr() {
	tree = []
	if ( Glookahead == "(" ) {
		gen_match("(");
		n = gen_binopexpr();
		gen_match(")");
		return(n)
	}
	if ( Glookaheadtype == GEN_UNOP ) {
		tree["op"] = gen_eat()
		tree["operand1"] = gen_binopexpr();
		return(tree)
	}
	if ( Glookaheadtype == GEN_NUMBER ) {
		tree["op"] = "number"
		tree["number"] = gen_eat()
		return(tree)
	}
	if ( Glookaheadtype == GEN_STRING ) {
		tree["op"] = "string"
		tree["string"] = gen_eat()
		return(tree)
	}
	if ( Glookaheadtype == GEN_WORD ) {
		w1 = gen_eat()
		if ( Glookahead == "(" ) {
			gen_eat()
			tree["op"] = "func"
			tree["func"] = w1;
			na = 0;
			if ( Glookahead != ")" ) {
			    while ( 1 ) {
				n2 = gen_binopexpr();
				na++
				tree["arg"+string(na)] = n2
				if ( Glookahead == "," ) {
					gen_match(",")
				} else if ( Glookahead == ")" ) {
					gen_match(")")
					break;
				} else {
					print("Unexpected input: "+Glookahead)
					return([])
				}
			    }
			}
		} else {
			tree["op"] = "var"
			tree["var"] = w1
		}
		return(tree)
	}
	return(tree)
}

function gen_match(c) {
	if ( Gtokes[Gpeekn] == c ) {
		Gpeekn++
		Glookahead = Gtokes[Gpeekn];
		Glookaheadtype = Gtypes[Gpeekn];
	} else {
		print("Didn't find expected token: ",c);
	}
}

function gen_tokens(s) {
	current = ""
	lng = sizeof(s)
	Gtokes = []
	Gtypes = []
	ntokes = 0
	inside = 0

	WORD_CHARS_FIRST = "[a-zA-Z_]"
	WORD_CHARS_REST = "[a-zA-Z0-9_]"

	for ( n=0; n<lng; n++ ) {
		c = substr(s,n+1,1)
		if ( inside == GEN_STRING ) {
			current += c
			if ( c == substr(current,1,1) ) {
				Gtokes[ntokes] = current
				ntokes++
				inside = GEN_NOTHING
				current = ""
			}
			continue
		}

		if ( inside == GEN_NUMBER ) {
			if ( c ~~ "[0123456789.]" ) {
				current += c
				continue
			}
			Gtokes[ntokes] = current
			ntokes++
		}

		if ( inside == GEN_WORD ) {
			if ( c ~~ WORD_CHARS_REST ) {
				current += c
				continue
			}
			Gtokes[ntokes] = current
			ntokes++
		}

		inside = GEN_NOTHING
		current = ""

		if ( c == "(" || c == ")" || c == "," ) {
			Gtypes[ntokes] = GEN_PUNCT
			Gtokes[ntokes] = c
			ntokes++
			current = ""
		} else if ( c == "!" ) {
			Gtypes[ntokes] = GEN_UNOP
			Gtokes[ntokes] = c
			ntokes++
			current = ""
		} else if ( c == "-" ) {
			cnext = substr(s,n+2,1)
			if ( cnext ~~ "[0123456789]" ) {
				Gtypes[ntokes] = GEN_NUMBER
				inside = GEN_NUMBER
				current = "-"+cnext
				n++
			} else {
				Gtypes[ntokes] = GEN_UNOP
				Gtokes[ntokes] = c
				ntokes++
			}
		} else if ( gen_isbinop(c) ) {
			Gtypes[ntokes] = GEN_BINOP
			Gtokes[ntokes] = c
			ntokes++
			current = ""
		} else if ( c ~~ "[0123456789]" ) {
			Gtypes[ntokes] = GEN_NUMBER
			inside = GEN_NUMBER
			current = c
		} else if ( c ~~ WORD_CHARS_FIRST ) {
			Gtypes[ntokes] = GEN_WORD
			inside = GEN_WORD
			current = c
		} else if ( c ~~ "\"" || c ~~ "'" ) {
			current = c
			Gtypes[ntokes] = GEN_STRING
			inside = GEN_STRING
		} else {
			current += c
		}
			
	}
	if ( current != "" )
		Gtokes[ntokes++] = current
	return()
}

function randominclude(a,m,n) {
	return(a{rand(n)<m})
}
