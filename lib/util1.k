function argvlist() {
	return(argv(0,nargs()))
}

function arraycopy(origarr, copyarr,i) {
	if ( typeof(origarr) != "array")
		error("arraycopy() expects an array argument, got: "+typeof(origarr))
	copyarr = []
	for ( i in origarr ) {
		if ( typeof(origarr[i]) == "array" )
			copyarr[i] = arraycopy(origarr[i])
		else
			copyarr[i] = origarr[i]
	}
	return(copyarr)
}

function arraysortonindex(arr, i) {
	if ( typeof(arr) != "array")
		error("arraysortindex() expects an array argument, got: "+typeof(arr))
	iarr = []
	ni = 0
	for ( i in arr )
		iarr[ni++] = i
	# bubble, sorry
	for ( n1=ni-1; n1>0; n1-- ) {
		for ( n2=0; n2<n1; n2++ ) {
			if ( iarr[n2] > iarr[n2+1] ) {
				t = iarr[n2]
				iarr[n2] = iarr[n2+1]
				iarr[n2+1] = t
			}
		}
	}
	return(iarr)
}

#name	arraysort
#usage	arraysort
#desc	Sorts the elements in the given array,
#desc	and returns the sorted array.

function arraysort(arr) {
	if ( typeof(arr) != "array")
		error("arraysort() expects an array argument, got: "+typeof(arr))
	# silly bubble sort
	sz = sizeof(arr)
	for ( n=sz; n>0; n-- ) {
		for ( k=1; k<n; k++ ) {
			if ( arr[k-1] > arr[k] ) {
				t = arr[k-1]
				arr[k-1] = arr[k]
				arr[k] = t
			}
		}
	}
	return(arr)
}

# arraylist - a utility for generating an array with elements
#        whose indicies are specified.  I.e. arraylist("hi","there")
#        will return a 2 element array - the indicies will be
#        "hi" and "there" - the element values will all be 1.

function arraylist() {
	lsize = nargs()
	arr = []
	for ( ln=0; ln<lsize; ln++ )
		arr[argv(ln)] = 1
	return(arr)
}

# arraylistordered - a utility for generating an array with elements
#        whose indicies are 0-n and whose values are specified.
#        I.e. arraylistordered("hi","there") will return a 2 element array
#        - the indicies will be 0 and 1, and the element values
#        will be "hi" and "there".

function arraylistordered() {
	lsize = nargs()
	arr = []
	for ( ln=0; ln<lsize; ln++ )
		arr[ln] = argv(ln)
	return(arr)
}

#name	arrayprint
#usage	arrayprint(array)
#desc	Prints all the elements in the given array.
#desc	Works for arrays of any dimension.

function arrayprint(arr,pre) {
	if ( nargs() < 2 )
		pre = ""
	for ( i in arr ) {
		if ( typeof(arr[i]) == "array" )
			arrayprint(arr[i],string(pre)+"[ "+string(i)+" ] ")
		else
			print(pre+"[",i,"] =",arr[i])
	}
}

#name	constant
#usage	constant()
#desc	This function initializes various constants that
#desc	are needed by other funcitons.

function constant() {
	if ( ! defined(PITCH) )
		PITCH = 1
	if ( ! defined(VOLUME) )
		VOLUME = 2
	if ( ! defined(TIME) )
		TIME = 4
	if ( ! defined(DURATION) )
		DURATION = 8
	if ( ! defined(CHANNEL) )
		CHANNEL = 16
	if ( ! defined(SCADJUST) )
		SCADJUST = 32
	if ( ! defined(SCAFILT) )
		SCAFILT = 64
	if ( ! defined(EXACTTIME) )
		EXACTTIME = 128
	if ( ! defined(RELATIVE) )
		RELATIVE = 256
	if ( ! defined(OCTAVE) )
		OCTAVE = 512
	if ( ! defined(REDRAW) )
		REDRAW = 1
	if ( ! defined(NOREDRAW) )
		NOREDRAW = 0
	# These values are negative so they don't conflict with
	# things like CONTROLLER, etc.
	if ( ! defined(SUSTAIN) )
		SUSTAIN = -1
	if ( ! defined(VOLUMECONTROLLERS) )
		VOLUMECONTROLLERS = -2
	if ( ! defined(EXPRESSION) )
		EXPRESSION = -4
	if ( ! defined(MODULATION) )
		MODULATION = -8
	if ( ! defined(TOOLNOTES) )
		TOOLNOTES = -16
	if ( ! defined(PAN) )
		PAN = -32
}

#name	setdefaults
#usage	setdefaults()
#desc	This function sets various global default values.
function setdefaults() {
}

#name	findtask
#usage	findtask(function_name)
#desc	This function looks for a running task that is executing
#desc	the named function (which is specified as a string, not as
#desc	a function value).  If found, the task id is returned.
#desc	If not found, the return value is -1.

function findtask(funcname) {
	lookfor = funcname + "()"
	for ( t in taskinfo("list") ) {
		s = taskinfo(t,"trace")
		if ( typeof(s)=="string" && (s ~~ lookfor) )
			return(t)
	}
	return(-1)
}

function fileisreadable(fname) {
	# We base it on being able to get the file time.  Not really right,
	# but close enough for the moment.
	ft = filetime(fname)
	if ( ft >= 0 )
		return(1)
	else
		return(0)
}

function togglemet() {
	if ( Metid >= 0 ) {
		kill(Metid)
		Metid = -1
	}
	else if ( defined(Met) && Met.length>0 ) {
		tm = nextquant(Now,1b)
		Metid = realtime(Met,tm,Met.length)
	}
	else
		print("No value for Met?!")
}

#name	isonbeat
#usage	isonbeat(note [,beat_interval] )
#desc	Returns true (non-zero) if the given note lands on the beat.
#desc	The default beat interval is 1b; a second argument can specify an
#desc	different interval (e.g. isonbeat(note,4b) would return
#desc	true if the note fell on any 4-beat mark).

function isonbeat(p,tm) {
	if ( sizeof(p) != 1 ) {
		print("isonbeat() expects a single-note phrase!")
		return(0)
	} 
	if ( nargs() < 1 || nargs() > 2 ) {
		print("usage: isonbeat(single-note-phrase [,interval] )")
		return(0)
	}
	if ( nargs() < 2 )
		tm = 1b
	if ( (p.time % tm) == 0 )
		return(1)
	else
		return(0)
}

#name	isnearbeat
#usage	isnearbeat(note ,beat_interval, tolerance )

function isnearbeat(p,tm,tol) {
	if ( sizeof(p) != 1 ) {
		print("isnearbeat() expects a single-note phrase!")
		return(0)
	} 
	if ( nargs() < 3 ) {
		print("usage: isnearbeat(single-note-phrase,interval,tolerance)")
		return(0)
	}
	delta = p.time % tm
	if ( delta < 0 )
		delta = -delta
	return ( delta <= tol || delta >= (tm-tol) )
}

function isinarea(x,y,area) {
	if ( typeof(area) != "array" || sizeof(area) != 4 ) {
		print("isinarea() was given bad area array!")
		return(0)
	}
	if ( x >= area["x0"] && x <= area["x1"]
		&& y >= area["y0"] && y <= area["y1"] ) {
		return(1)
	}
	else {
		return(0)
	}
}

#name	isinscale
#usage	isinscale(note,scale)
#desc	Return true (non-zero) if the specified note exists in the
#desc	specified scale.  The scale phrase need only specify a give pitch
#desc	once - it is assumed to be duplicated over all octaves.

function isinscale(nt,ph, cnt) {
	cnt = canonic(nt)
	if ( sizeof( ph{ canonic(??) == cnt } ) > 0 )
		return(1)
	return(0)
}

#name	millisleep
#usage	millisleep(milli)
#desc	Sleep (i.e. pause the task which calls this function)
#desc	for the specified number of milliseconds.

function millisleep(milli) {
	sleeptill(Now+((milli*1000*1b)/tempo()))
}

function lookup(arr,val,undef, i) {
	if ( nargs() < 3 )
		undef = Nullstr
	for ( i in arr ) {
		if ( arr[i] == val )
			return(i)
	}
	return(undef)
}

function writephr(ph,fname) {
	if ( nargs() < 2 ) {
		print("Usage: writephr(phrase,filename)")
		return()
	}
	f = open(fname,"w")
	put(f,sprintf("%p\n",ph))
	close(f)
}

function writemf(ph,fname) {
	if ( nargs() < 2 ) {
		print("Usage: writemf(phrase,filename)")
		return()
	}
	midifile([0=ph],fname)
}

#name	uniqnum
#usage	uniqnum()
#desc	This function returns a new unique number.  Useful for inventing
#desc	id numbers for menus, or for any other purpose.

Unum = 1	# don't start at 0, top-level menu gets that
function uniqnum() {
	return(Unum++)
}

#name	nextquant
#usage	nextquant(number,quantize)
#desc	This function quantizes the specified number using the specified
#desc	quantize value, and returns the result.  The result is guaranteed to
#desc	be greater than the original number; if quantization would produce
#desc	a smaller number, it is increased by the quantize value.  This is
#desc	typically used when you want to quantize a time value, and want to
#desc	guarantee that the result will refer to some time in the future,
#desc	not in the past.
#see	numquant

function nextquant(t,q, rem,tq) {
	if ( q <= 1 )
		return(t)
	if ( nargs() != 2 )
		error("usage: nextquant(time,quant)")
	tq = t
	rem = tq % q
	if ( (rem*2) > q )
		tq += (q-rem);
	else
		tq -= rem;
	if ( tq < t )
		tq += q
	return(tq)
}

#name	prevquant
#usage	prevquant(number,quantize)
#desc	This function quantizes the specified number using the specified
#desc	quantize value, and returns a result that is equal to or less than
#desc	the original number.

function prevquant(t,q) {
	if ( q <= 1 )
		return(t)
	if ( nargs() != 2 ) {
		print("usage: prevquant(time,quant)")
		return()
	}
	tq = t
	rem = tq % q
	if ( (rem*2) > q )
		tq += (q-rem);
	else
		tq -= rem;
	if ( tq > t )
		tq -= q
	return(tq)
}

# registop - Register a task in a list,
#            To kill them all, execute registop(-1)

function registop(tid) {
	if ( nargs() != 1 ) {
		print("usage: registop(tid)")
		return()
	}
	if ( ! defined(Stopids) )
		Stopids = []
	if ( tid == -1 ) {
		for ( tid in Stopids )
			kill(tid)
		Stopids = []
	}
	else
		Stopids[tid] = 1
}

function stop() {
	registop(-1)
	finishoff()
}

function incpriority() {
	t = gettid()
	cp = priority(t)
	if ( cp < MAXPRIORITY )
		priority(t,cp+1)
	else
		error("incpriority can't increase the priority, it's already MAXPRIORITY!")
}

function decpriority() {
	t = gettid()
	cp = priority(t)
	if ( cp > 0 )
		priority(t,cp-1)
	else
		error("decpriority can't decrease the priority, it's already 0!")
}

function regicontrol(o) {
	if ( nargs() != 1 ) {
		print("usage: regicontrol(o)")
		return()
	}
	Controlwinds[o] = 1
}
function unregicontrol(o) {
	delete Controlwinds[o]
}

function definecontrol() {
	if ( ! defined(Controlwinds) || typeof(Controlwinds) != "array" ) {
		Controlwinds = []
		Controlvals = []
		for ( i=0; i<16; i++ )
			Controlvals[i] = []
	}
}

function broadcastcontrol(ch,cn,cv) {
	incpriority()
	if ( ! (ch-1) in Controlvals )
		print("Hey, ch-1=",ch-1," isn't in Controlvals!?")
	if ( typeof(Controlvals[ch-1]) != "array" )
		print("Hey, ch-1=",ch-1," isn't an array in Controlvals!?")
	Controlvals[ch-1][cn] = cv
	for ( o in Controlwinds ) {
		if ( o == $0 || o == $-1 ) {
			print("Bad object in Controlwinds!?")
			delete Controlwinds[o]
		}
		else
			o.force(cn,ch,cv)
	}
	decpriority()
}

function querycontrol(ch,cn) {
	return(Controlvals[ch-1][cn])
}

function regiprogram(o) {
	if ( nargs() != 1 ) {
		print("usage: regiprogram(o)")
		return()
	}
	defineprogram()
	Programwinds[o] = 1
}

function unregiprogram(o) {
	if ( o in Programwinds )
		delete Programwinds[o]
}

function defineprogram() {
	if ( ! defined(Programwinds) ) {
		Programwinds = []
		Programvals = []
	}
}

function broadcastprogram(ch,pn) {
	# no broadcast otherwise (conflicts)! ## Stef ##
	if ((pn-1) in Patchmap) {
		incpriority()
		defineprogram()
		Programvals[ch-1] = pn-1
		for ( oo in Programwinds ) {
			oo.force(ch,pn)
		}
		decpriority()
	}
}

function queryprogram(ch) {
	return(Programvals[ch-1])
}

#name	status
#usage	status([str])
#desc	When called with no arguments, this function prints a list of all
#desc	currently-running tasks.  If a string argument is given, the list
#desc	will only contain those tasks whose stacktrace (the output of
#desc	taskinfo(tid,"trace")) contains that string.

function status(s, t,n,str) {
	for ( t in taskinfo("list") ) {
		if ( nargs() > 0 ) {
			if ( typeof(s) == "string" ) {
				str = taskinfo(t,"trace")
				if ( str==Nullval || !(str ~~ s) )
					continue
			}
			else if ( typeof(s) == "integer" ) {
				if ( string(t) != string(s) )
					continue
			}
			else {
				print("Bad parameter to status()!?")
				continue
			}
		}
		if ( (n=taskinfo(t,"status")) == Nullval )
			continue
		printf("task=%d stat=%s",t,n)
		if ( (n=taskinfo(t,"parent")) != Nullval )
			printf(" prnt=%d",n)
		if ( (n=taskinfo(t,"count")) != Nullval )
			printf(" cnt=%d",n)
		if ( (n=taskinfo(t,"schedtime")) != Nullval )
			printf(" sch=%d",n)
		if ( (n=taskinfo(t,"schedcount")) != Nullval )
			printf(" scnt=%d",n)
		if ( (n=taskinfo(t,"wait")) != Nullval )
			printf(" wt=%d",n)
		if ( (n=taskinfo(t,"blocked")) != Nullval )
			printf(" blk=%d",n)
		if ( (n=taskinfo(t,"line")) != Nullval )
			printf(" lin=%d",n)
		# if ( (n=taskinfo(t,"file")) != Nullval )
		# 	printf(" fil=%s",n)
		# if ( (n=taskinfo(t,"priority")) != 0 )
		# 	printf(" pri=%d",n)
		if ( (n=taskinfo(t,"trace")) != Nullval )
			printf(" trc=%s",taskinfo(t,"trace"))
		printf("\n")
	}
}

# getastr(prompt,default)
#
# Get a line from the Console, with a prompt.
# None of the arguments are required - if none are
# given, the default values are equivalent to getastr("","").
#
# The prompt is the prompt (is the prompt), and a line
# is read from the Console.  If default is given, then
# a blank reponse will be replaced with that value.
# (This means that a default value of "" will permit a blank response.)
# If no default is given, a blank response will re-issue the prompt.

function getastr(pr,def,firstchar) {
	if ( nargs() == 0 ) {
		pr = ""
		def = ""
		dodef = 1
	}
	else if ( nargs() == 1 )
		dodef = 0
	else
		dodef = 1
	ans = ""

	oldfocus = Root.focus()
	oldecho = Consecho
	oldechoobj = Consechoobj
	Consecho = 1
	Consechoobj = $0

	f = open()
	o = new wconsole(f,nullfunc)

	# if ( nargs() >= 3 )
	# 	put(f,firstchar)

	rxmin = Root.xmin()
	rxmax = Root.xmax()
	xmid = (rxmin + rxmax)/2
	ymid = (Root.ymin() + Root.ymax())/2
	th = Root.textheight()
	tw = Root.textwidth()
	xsz = ((sizeof(pr) + 60) * tw)
	xlim = rxmax - rxmin - 3*tw
	if ( xsz > xlim )
		xsz = xlim
	Root.addtool(o,xy(xmid - (xsz/2),ymid - th,xmid + (xsz/2), ymid + th))
	Root.focus(o)
	o.redraw()

	while ( ans == "" ) {
		if ( pr != "" )
			printf(pr)
		ans = readedit(f,pr)
		if ( ans == Eof )
			return(Eof)
		if ( ans=="" && dodef!=0 ) {
			ans = def
			break
		}
	}
	Root.focus(oldfocus)
	Consecho = oldecho
	Consechoobj = oldechoobj
	Root.deletetool(o)
	return(ans)
}

#name	numquant
#usage	numquant(number,quantize)
#desc	This function quantizes the specified number using the specified
#desc	quantize value, and returns the result.  The result may be less
#desc	than the original number.  If you want to guarantee that the
#desc	result is not less than the original (which is typical when you are
#desc	quantizing a time value and want to guarantee that the result is
#desc	some time in the future), use nextquant().
#see	nextquant

function numquant(v,q,nonzero) {
	if ( nargs() != 2 ) {
		print("usage: numquant(value,quantization[,nonzero])")
		return()
	}
	if ( v < 0 ) {
		rem = -v % q
		if ( (rem*2) > q )
			v -= (q-rem);
		else
			v += rem;
	}
	else {
		rem = v % q
		if ( (rem*2) > q )
			v += (q-rem);
		else
			v -= rem;
	}
	if ( nargs() > 2 ) {
		if ( nonzero!=0 && v==0 )
			v = q
	}
	return(v)
}

#name	abs
function abs(n) {
	if ( n < 0 )
		n = -n
	return(n)
}

#name	xystr
#usage	xystr(xyarray)
#desc	This function is used when you want to print(the value of an xyarray.
#desc	It returns a string version of the specified xyarray.
#desc	For example, xystr(xy(0,0,4,4)) would equal "0,0,4,4".
#desc	It works for 2-element xyarrays (i.e. with subscripts "x" and "y")
#desc	as well as 4-element xyarrays ("x0", "y0", "x1", "y1").

function xystr(sz) {
	if ( "x1" in sz ) {
		return(string(sz["x0"])+","+string(sz["y0"])
			+","+string(sz["x1"])+","+string(sz["y1"]) )
	}
	else if ( "x0" in sz ) {
		return(string(sz["x0"])+","+string(sz["y0"]))
	}
	else if ( "x" in sz ) {
		return(string(sz["x"])+","+string(sz["y"]))
	}
	else {
		print("Bad size given to xystr()!?")
		return("0,0")
	}
}

function fileexists(fname) {
	return( filetime(fname) >= 0 )
}

function filecat(fname) {
	f = open(fname,"r")
	fifoctl(f,"type","b");
	while ( (c=get(f)) != Eof ) {
		print("c=",c);
	}
	close(f)
}

function gettid() {
	return(taskinfo("id"))
}

function definelocks() {
	if ( ! defined(Locks) )
		Locks = []
}

# utility for use with onexit, mainly
function domethod(o,meth,...) {
	# We fail silently if the object has gone away
	if ( o != $-1 ) {
		o.(meth)(...)
	}
}

function waitnput(tmout,f,v) {
	millisleep(tmout)
	put(f,v)
}

function waitncall(tm,f,...) {
	sleeptill(tm)
	f(...)
}

function waitnmethod(tm,o,meth,...) {
	sleeptill(tm)
	# Avoid error messages if the object has gone away
	if ( o != $-1 ) {
		o.(meth)(...)
	}
}

function waitneval(tm,s) {
	sleeptill(tm)
	eval s
}

function tail(ph,n, lim) {
	if ( nargs() == 0 ) {
		print("usage: tail(phrase,number-of-notes)")
		return('')
	}
	if ( nargs() == 1 )
		n = 10
	lim = sizeof(ph)-n
	return(ph{??.number > lim})
}

function head(ph,n) {
	if ( nargs() == 0 ) {
		print("usage: head(phrase,number-of-notes)")
		return('')
	}
	if ( nargs() == 1 )
		n = 10
	return(ph{??.number<=n})
}

function methodforward2first(...) {
	m = taskinfo("method")
	for ( o in $.children() ) {
		# execute method of first child that we find it in
		if ( defined(o.(m)) )
			return(o.(m)(...))
	}
}

function methodbroadcast(...) {
	m = taskinfo("method")
	# execute method on all children that have it
	for ( o in $.children() ) {
		if ( typeof(o) != "object" )
			print("Hey, o=",o," isn't an object. $ is ",$,"  children=",$.children())
		else if ( defined(o.(m)) ) {
			o.(m)(...)
		}
	}
}

function mouseforward(m,mtype) {
	if ( $ == $0 || $ == $-1 ) {
		print("mouseforward found dollar is 0")
	}
	if ( $$ == $0 || $$ == $-1 ) {
		print("mouseforward found dollar2 is 0")
	}
	o = $$.childunder(m)
	if ( o != $$ && defined(o.(mtype)) ) {
		o.(mtype)(m)
		return(1)
	}
	return(0)
}

# Print rhythmic information about a phrase.  Gives the 'beat' on
# which each note falls (or is closest to, with an offset).

function beatinfo(ph) {
	for ( nt in ph ) {
		t=nt.time
		m = nt.time / 4b
		b = nt.time / 1b
		d = nt.time - b*1b
		b -= 4*m
		if ( d > 1b/2 ) {
			b++
			if ( b > 3 ) {
				b = 0;
				m++
			}
			d -= 1b
		}
		print("measure ",m," beat ",b," offset ",d)
	}
}

# textfunc - Return a pointer to a function that will draw text in a window.
#            Typically used as the 'drawfunc' when calling kbutton().
#            The function is dynamically created (ah, the escape hatch
#            of "eval").  The array indexed by gettid() is clumsy - 
#            there must be a better way.
#
#            2/20/2002 - I finally modified most things to not require
#            textfunc.  I've left it in place, for upward compatibility
#            with old things.  The calling convention of the function it
#            creates has been changed, but as long as someone hasn't
#            redefined kbutton, etc, it will still work.

Textfuncnum = 0
function textfunc(str,just) {
	if ( nargs() < 2 )
		just = "center"
	# name of function starts with upper-case, so refunc() won't touch it.
	funcname = "Textfunc"+string(Textfuncnum++)
	estr = "function "+funcname+"(o,v) { if(nargs()<2)v=STORE;$.text"+just+"(\""+str+"\",$.size(),v);}"
	eval estr
	return(function(funcname))
}

#name	normredraw
#usage	normredraw()
#desc	This function is intended to be the default value of Redrawfunc,
#desc	which KeyKit calls whenever the screen must be redrawn.
#desc	It redraws the root window (i.e. erasing the screen), and
#desc	then sends a redraw message to all children windows (i.e. all
#desc	the active tools).

function normredraw() {
	lock("redrawresize")
	Root.redraw()
	unlock("redrawresize")
}

#name	normexit
#usage	normexit()

function normexit() {
	if ( defined(Keypagepersistent) && Keypagepersistent != "" ) {
		page_write(Keypagepersistent)
	}
	exit(0)
}

#name	normresize
#usage	normresize()
#desc	This function is intended to be the default value of Resizefunc,
#desc	which KeyKit calls whenever the screen is resized.  Normally
#desc	this function does nothing.  By setting the variable Autoresize
#desc	to 1 (e.g. in liblocal/prerc.k), you can cause this function to
#desc	automatically resize all the active tools to fit within the new
#desc	screen size.

function normresize() {
	lock("redrawresize")
	if ( ! defined(Oldrootsize) ) {
		Oldrootsize = screen("size")
	}
	sz = screen("size");
	if ( Autoresize ) {
		dxnew = float(sz["x1"]-sz["x0"])
		dxold = float(Oldrootsize["x1"]-Oldrootsize["x0"])
		xfact = dxnew / dxold

		# The extra textheight subtraction here is to try to
		# account for window title bar, sigh - there's a fundamental
		# problem with the fact that Root.size() != screen("size")
		yfudge = 1
		if ( Machine == "win" ) {
			yfudge += 2*Root.textheight()
		}
		dynew = float(sz["y1"]-sz["y0"]-yfudge)
		dyold = float(Oldrootsize["y1"]-Oldrootsize["y0"]-yfudge)
		yfact = dynew / dyold
		for ( i in Root.children() ) {
			csz = i.size()
			csz["x0"] *= xfact
			csz["y0"] *= yfact
			csz["x1"] *= xfact
			if ( csz["x1"] > sz["x1"] )
				csz["x1"]  = sz["x1"] - 1
			csz["y1"] *= yfact
			if ( csz["y1"] > sz["y1"] )
				csz["y1"]  = sz["y1"] - 1
			i.resize(csz)
		}
		Root.redraw()
	}
	Oldrootsize = sz
	unlock("redrawresize")
}

#name	canonic
#usage	canonic(note)
#desc	Returns the canonical pitch of a note,
#desc	ie. a number between 0 and 11.

function canonic(nt) {
	if ( typeof(nt) == "phrase" )
		return(nt.pitch % 12)
	else
		return(nt%12)
}

#name	milliclicks
#usage	milliclicks(milli)
#desc	Returns the number of clicks equivalent to the specified
#desc	number of milliseconds.  Note that this is dependent upon
#desc	the current tempo().
Millibeat = 1000.0 * 1b
function milliclicks(milli) {
	# Make sure to use floating point to avoid integer overflow.
	return( integer((milli*Millibeat)/tempo()) )
}

#name	seconds
#usage	seconds(secs)
#desc	Returns the number of clicks in a given number of seconds.
function seconds(secs) {
	# Make sure to use floating point to avoid integer overflow.
	return( integer((secs*1000000.0*1b)/tempo())  )
}

#name	millisince
#usage	millisince(tm)
#desc	Returns the number of milliseconds since a given time
function millisince(tm) {
	dc = Now - tm
	millisecs = (1000*dc) / milliclicks(1000)
	return(millisecs)
}

function killtids(arr) {
	mytid = gettid()
	for ( n=0; n<nargs(); n++ ) {
		a = argv(n)
		t = typeof(a)
		if ( t == "array" ) {
			for ( tid in a ) {
				if ( tid != mytid ) {
					kill(tid)
				}
			}
		}
		else if ( t == "integer" ) {
			if ( a != mytid ) {
				kill(a)
			}
		}
	}
}

function deleteobject(o) {
	if ( o == $-1 || o == $0 )
		return()
	if ( defined(o.delete) ) {
		o.delete()
	}
	for ( co in o.children() )
		deleteobject(co)
	for ( co in o.inherited() ) {
		deleteobject(co)
	}
	delete o
}

function rereadlibs() {
	print("Undefining all (or most) user-defined functions...")
	refunc()
	rekeylib()
	print("Done.")
}

function fulltrace() {
	print(taskinfo(gettid(),"fulltrace"))
}

function dprint(s) {
	f = open("tmp.dbg","a")
	put(f,s)
	put(f,"\n")
	put(f,string(taskinfo(gettid(),"fulltrace")))
	put(f,"\n")
	close(f)
}

function fib(n) {
	if ( n < 2 )
		return(n)
	return(fib(n-1)+fib(n-2))
}

function tension(na,nb) {
	majarr = [
		0=0.0,
		1=4.0,
		2=3.0,
		3=4.0,
		4=1.0,
		5=2.0,
		6=4.0,
		7=1.0,
		8=4.0,
		9=2.0,
		10=3.0,
		11=4.0,
		12=0.0
		]
	num = 0
	tot = 0.0
	for ( n1 in na ) {
		n1 = canonic(n1)
		for ( n2 in nb ) {
			n2 = canonic(n2)
			if ( n1 > n2 ) {
				t = n1
				n1 = n2
				n2 = t
			}
			n2 -= n1
			tot += majarr[n2]
			num++
		}
	}
	if ( num == 0 )
		error("In tension, num==0 !?")
	return(tot / num)
}

function fullinfo(iph) {
	for ( c=1; c<=16; c++ ) {
		ph = cut(iph,CUT_CHANNEL,c)
		if ( sizeof(ph) == 0 )
			continue;
		printf("Channel %d:   #notes=%d",c,sizeof(ph))

		n = ph.pitch
		if ( sizeof(ph{??.pitch!=n}) != 0 ) m=" (avg)" ; else m=""
		nt = 'a' ; nt.pitch = n
		printf("   pitch=%d ("+string(nt)+")"+m,n)

		n = ph.vol
		if ( sizeof(ph{??.vol!=n}) != 0 ) m = " (avg)" ; else m = ""
		printf("   vol=%d"+m,n)

		n = ph.dur
		if ( sizeof(ph{??.dur!=n}) != 0 ) m = " (avg)" ; else m = ""
		printf("   dur=%d"+m,n)

		printf("\n")
	}
}

function iserasechar(c) {
	return ( c == Erasechar || c == "\b" )
}

#name	readedit
#usage	readedit(fifo,prompt [,history] )
#desc	This function reads from a fifo, allowing line editing.
#desc	When a complete line has been entered, it is returned.
#desc	The optional third argument lets you access and maintain
#desc	a history of previous lines (this feature is not yet implemented).

# read from a fifo, allowing line editing
function readedit(f,prompt,history) {
	s = ""
	if ( nargs() < 3 )
		history = []
	for ( ;; ) {
		c = get(f)
		if ( c == Interrupt || c == Eof )
			return(c)
		# When we use Consupdown, we get a leftover -RETURN (keyup)
		if ( c == "-RETURN" )
			continue
		if ( Consechoobj != $0 )
			Consechoobj.consecho(c)
		if ( c == "\n" || c == "\r" )
			break
		# if ( c == "\004" ) {
		# 	if ( sizeof(s) == 0 )
		# 		return(Eof)
		# 	break
		# }
		if ( iserasechar(c) ) {
			s = substr(s,1,sizeof(s)-1)
			continue
		}
		if ( c == Killchar ) {
			for ( n=sizeof(s)+sizeof(prompt)+1; n>0; n-- )
				printf("\b")
			printf("%s",prompt)
			s = ""
			continue
		}
		s += c
	}
	return(s)
}

#name	readedit2			
#usage	readedit2(fifo,prompt)
#desc	This is a variation of readedit that allows you to press ESC
#desc	and get put into "notepad" on the history.  To activate,
#desc	set ConsoleReadedit=readedit2 in your liblocal/postrc.k
#desc	When you're done writing your script in the text editor, save the file,
#desc	close the editor (optional), then press ESC again. The whole KeyKit code
#desc	you edited will be evaluated as a single line (so take care to end your 
#desc   lines with a ";")
#desc	
#desc   Another feature of readedit2 is the TAB key which recalls previous
#dest	commands (you are first prompted for an index value in the Hist array,
#dest	but if you go on pressing TAB you will have the commands recalled
#dest	from the most recent to the oldest one)

function readedit2(f,prompt,history) {
	s = ""
	if ( nargs() < 3 )
		history = []
	if ( ! defined(MAT) ) {
		MAT = "c:\\"
	}
	for ( ;; ) {
		c = get(f)
		if ( c == Interrupt || c == Eof )
			return(c)

		histnum = -1
		if (c == ascii(9) && History)	{		# premier TAB
			Console.printf("!edit:")
			numero = ""
			c = get(f)
			while (( c ~~ "[0123456789]") || (c==""))
			{
				numero += c
				c = get(f)
				if ( iserasechar(c) ) {
					numero = substr(numero,1,sizeof(numero)-1); c=""
				}
			}
			if (numero != "")
			{
				c = ""
				histnum = integer(numero)
			}
		}

		retour = 0
		while (( c == ascii(9) && History)
			|| (histnum >= 0))	{	# TAB suivant

			if ((histnum == -1) || (histnum > Histindex)) 
				{retour += 1 ; Console.printf("\n")} 
			else {retour = Histindex-histnum}
			histnum = -1
			if (retour > Histindex) {retour = Histindex}
			Console.printf("!%d>%s", Histindex, s = Hist[Histindex-retour])
			c = get(f)
		}

		if ( c == ascii(27)) {		# ESC (l'artillerie lourde !)
			tempf = open(MAT+"temp.txt","w")
			put(tempf, s)
			put(tempf, Eol+Eol+Eol+"# (History, for easy cut & paste:)"+Eol)
			for (hn = 0; hn < Histindex; hn++)
				put(tempf, "# "+string(hn)+": "+Hist[hn]+Eol)
			close (tempf) 
			system("notepad "+MAT+"temp.txt")

			while ((c = get(f)) != ascii(27)) {}

			s = ""
			tempf = open(MAT+"temp.txt")
	        while ((ls = get(tempf))!=Eof)
				if (substr(ls,1,1)!="#")
					s += split(ls,Eol)[0]
			close (tempf)

			Console.printf("\n-->"+s+"\n")
			break
		}		

		if ( c == "\n" || c == "\r" )
			break

		# if ( c == "\004" ) {
		# 	if ( sizeof(s) == 0 )
		# 		return(Eof)
		# 	break
		# }
		if ( iserasechar(c) ) {
			s = substr(s,1,sizeof(s)-1)
			continue
		}
		if ( c == Killchar ) {
			for ( n=sizeof(s)+sizeof(prompt)+1; n>0; n-- )
				printf("\b")
			printf("%s",prompt)
			s = ""
			continue
		}
		s += c
	}
	return(s)
}



function chansplit(ph) {
	arr = []
	for ( n=1; n<=16; n++ ) {
		p = cut(ph,CUT_CHANNEL,n)
		if ( sizeof(p) > 0 )
			arr[n] = p
	}
	return(arr)
}

function spliteven(ph,leng) {
	if ( nargs() < 2 )
		leng = 4b
	if ( leng <= 0 ) {
		print("Invalid length (",leng,") given to spliteven")
		return([])
	}
	arr = []
	narr = 0
	curr = ''
	t0 = 0
	t1 = leng
	arr[narr] = ''
	for ( n in ph ) {
		# Advance to whatever slot we fit in
		while ( ! (n.time >= t0 && n.time < t1) ) {
			# advance to next slot
			narr++
			arr[narr] = ''
			t0 += leng
			t1 += leng
		}
		n.time -= t0
		arr[narr] |= n
	}
	for ( i in arr )
		arr[i].length = leng
	return(arr)
	
}

# splitonstarts has changed - the original version was buggy,
# but some algorithm results may depend on it, so keep it around
# in case we need it
function splitonstarts_orig(ph,minlength,fixedsize) {
	if ( nargs() < 2 )
		minlength = 0
	if ( nargs() < 3 )
		fixedsize = 0
	arr = []
	narr = 0
	curr = ''
	currtm = 0
	currleng = 0
	currsize = 0
	for ( n in ph ) {
		if ( curr == '' ) {
			curr = n
			currtm = n.time
			currleng = 0
		} else {
			# If we have a note at the same time as the last one,
			# add it to the curr phrase
			if ( n.time == currtm ) {
				curr |= n
				currleng = n.time - currtm
				continue
			}

			currsize++

			addit = 0
			if ( minlength>0 && currleng < minlength
					&& (n.time-currtm)<minlength ) {
				addit = 1
			}
			
			if ( fixedsize > 0 && currsize < fixedsize ) {
				addit = 1
			}

			if ( addit ) {
				curr |= n
				currleng = n.time - currtm
			} else {
				arr[narr] = curr
				arr[narr].time -= currtm
				arr[narr].length = n.time - currtm
				narr++
				curr = n
				currtm = n.time
				currleng = 0
				currsize = 0
			}
		}
	}
	if ( curr != '' ) {
		arr[narr] = curr
		arr[narr].time -= currtm
		arr[narr].length = ph.length - currtm
		narr++
	}
	return(arr)
}

function splitonstarts(ph,minlength,fixedsize) {
	if ( nargs() < 2 )
		minlength = 0
	if ( nargs() < 3 )
		fixedsize = 0
	arr = []
	narr = 0
	curr = ''
	lasttm = 0
	currsize = 0
	for ( n in ph ) {
		# print("*** N=",n,"  lasttm=",lasttm)
		if ( curr == '' ) {
			curr = n
			lasttm = n.time
		} else {
			# If we have a note at the same time as the last one,
			# add it to the curr phrase
			if ( n.time == lasttm ) {
				# print("n=",n,"  time same (",lasttm,"), adding")
				curr |= n
				continue
			} else {
				currsize++
				# print("NEW TIME, currsize is now ",currsize)
			}
			lasttm = n.time

			addit = 0
			if ( minlength>0 && latest(curr) < minlength ) {
				addit = 1
			}
			
			if ( fixedsize > 0 && currsize < fixedsize ) {
				addit = 1
			}

			# print("n=",n,"  currsize=",currsize,"  addit=",addit," lasttm=",lasttm)

			if ( addit ) {
				curr |= n
			} else {
				# print("ADDED ENTRY narr=",narr," = ",curr)
				arr[narr] = curr
				narr++
				curr = n
				lasttm = n.time
				currsize = 0
			}
		}
	}
	if ( curr != '' ) {
		arr[narr] = curr
		narr++
	}
	for ( i in arr ) {
		arr[i] = strip(arr[i])
	}
	return(arr)
}

function setsnarf(ph,txt) {
	Snarf = ph
	if ( nargs() < 2 )
		Snarftext = ""
	else
		Snarftext = txt
}

function nullfunction() {
}

function efunction(f) {
	t = typeof(f)
	if ( t == "function" )
		return(f)
	if ( t != "string" )
		error("efunction() expects a string, but got a "+t)
	nf = function(f)
	if ( ! defined(nf) ) {
		print("efunction() can't find a function named '"+f+"'")
		nf = nullfunction
	}
	return(nf)
}

# noiseval(type,amount) - get random values, centered around 0.
#     type == -1  : resets everything
#     type == 0   : 1/f**0   white noise
#     type == 1   : 1/f**1   1/f noise
#     type == 2   : 1/f**2   brownian
# The return values will range from -amount to +amount.

# Lastnoise = -1
Noisereset = 1

function noiseval(type,amount) {
	if ( type < 0 ) {
		Noisereset = 1
		return()
	}
	origamount = amount
	amount = amount*2+1
	if ( type == 0 ) {
		r = rand(amount) - origamount
	}
	else if ( type == 1 ) {
		top = 1024
		if ( Noisereset != 0 ) {
			Noisereset = 0
			Lastnoise = top / 2
		}
		Lastnoise = oneovrf(Lastnoise,top)
		r = (Lastnoise * amount ) / top - origamount
	}
	else if ( type == 2 ) {
		if ( Noisereset ) {
			Noisereset = 0
			Lastnoise = 0
		}
		r = round(origamount*gauss())
		r += Lastnoise
		Lastnoise = r
	}
	return(integer(r))
}

# Return a random number with gaussian distribution, with
# mean 0.0 and standard deviation 1.0

Gauss_phase = 0
Gauss_v2 = 0.0
Gauss_fac = 0.0

function gauss() {
	if ( nargs() > 0 ) {
		print("usage: gauss()")
		return(0.0)
	}
	if ( Gauss_phase ) {
		z = Gauss_v2 * Gauss_fac
	} else {
		while (1) {
			u1 = float(rand(0xfffffff+1))/0xfffffff
			u2 = float(rand(0xfffffff+1))/0xfffffff
			v1 = 2 * u1 - 1
			Gauss_v2 = 2 * u2 - 1
			s = v1 * v1 + Gauss_v2 * Gauss_v2
			if ( s < 1 )
				break
		}
		Gauss_fac = sqrt(-2 * log(s) / s)
		z = v1 * Gauss_fac
	}
	Gauss_phase = 1 - Gauss_phase
	return(z)
}

function testrand(lim) {
	tot = 0.0
	for ( n=0; n<lim; n++ ) {
		tot += rand(0,1)
	}
	avg = float(tot) / lim
	print("tot=",tot," lim=",lim," avg=",avg)
}
function testgauss(lim) {
	tot = 0.0
	for ( n=0; n<lim; n++ ) {
		tot += gauss()
	}
	avg = float(tot) / lim
	print("tot=",tot," lim=",lim," avg=",avg)
}
function test1f() {
	tt = 0
	for(n=0;n<100;n++) {
		nt = oneovrf(tt,1024)
		print("last=",tt," new=",nt)
		tt = nt
	}
}
function testnoiseval() {
	for(n=0;n<1000;n++) {
		nt = noiseval(1,128)
		if ( integer(nt/100) == nt/100.0 )
			print("noise=",nt)
	}
}

# oneovrf(last,amount) - return sequence of 1/f numbers
#      Taken from pg. 290 of Computer Music by Dodge & Jerse.
#      This algorithm only works for powers of two.

function oneovrf(last,amount) {
	# Check to make sure it's a power of two
	chk = amount
	while ( chk > 1 ) {
		if ( (chk & 1) != 0 )
			break
		chk = chk >> 1
	}
	if ( chk != 1 ) {
		print("oneovrf: only works on powers of two!")
		return(0)
	}

	n = 0.0
	k = amount/2.0
	l = float(last)
	probit = 1.0/amount
	while ( 1 ) {
		j = integer(l/k)
		if ( j == 1 )
			l -= k
		u = rand(10001)/10000.0		# between 0 and 1
		if ( u < probit )
			j = 1.0 - j
		n += j*k
		k /= 2.0
		probit *= 2.0
		if ( k < 1 )
			break
	}
	return(n)
}

function fakebrowsefiles(lbl,expr,mustexist) {
	fn = getastr("Enter filename for '"+lbl+"' --> ","")
	if ( fileexists(mfn = pathsearch(fn,Musicpath)) )
		return(mfn)
	if ( fileexists(mfn = pathsearch(fn,Keypath)) )
		return(mfn)
	return(fn)
}

function linesout(p,fn) {
	f = open(fn,"w")
	put(f,"size "+string(1+latest(p))+" 128\n")
	for ( n in p ) {
		ys = string(127-n.pitch)
		put(f,"line "+string(n.time)+" "+ys+" "
				+string(n.time+n.dur)+" "+ys+"\n")
	}
	close(f)
}

function docmd(cmd) {
	t = cmd["type"]
	o = cmd["obj"]
	a = cmd["args"]
	m = cmd["meth"]
	if ( typeof(o) == "function" ) {
		task o(varg(a))
	}
	else if ( typeof(o) == "string" ) {
		f = efunction(o)
		task f(varg(a))
	}
	else if ( typeof(o) == "object" ) {
		if ( defined(o.(m)) )
			task o.(m)(varg(a))
		else if ( integer(o) == -1 )
			print("The recipient of that command has been deleted!?")
		else
			print("Something's wrong, method \""+m+"\" isn't defined for object",o,"!?")
	}
}

function logit(s) {
	f = open("key.log","a")
	put(f,string(s))
	put(f,"\n")
	close(f)
}

# Return value of global variable whose name is nm
function globalvalue(nm) {
	eval ("Tmp___ = "+string(nm))
	return(Tmp___)
}

function rectresize(arr,inc) {
	arr["x0"] += inc
	arr["y0"] += inc
	arr["x1"] -= inc
	arr["y1"] -= inc
	return(arr)
}

function haschannel(nt) {
	if ( nt != MIDIBYTES )
		return(1)
	else
		return(0)
}

function fakekeyboardinput(s) {
	if ( Machine != "win" ) {
		print("fakekeyboardinput() only works on Windows, sorry!")
		return()
	}
	leng = sizeof(s)
	for ( n=0; n<leng; n++ ) {
		c = ascii(substr(s,n+1,1))
		if ( c >= ascii("a") && c <= ascii("z") ) {
			c += (ascii("A")-ascii("a"))
			mdep("sendinput","keyboard",c,0)
			mdep("sendinput","keyboard",c,1)
		} else if ( c >= ascii("0") && c <= ascii("9") ) {
			mdep("sendinput","keyboard",c,0)
			mdep("sendinput","keyboard",c,1)
		} else if ( c >= ascii("A") && c <= ascii("Z") ) {
			mdep("sendinput","keyboard",0x10,0)
			mdep("sendinput","keyboard",c,0)
			mdep("sendinput","keyboard",c,1)
			mdep("sendinput","keyboard",0x10,1)
		} else if ( c == ascii(" ") ) {
			mdep("sendinput","keyboard",c,0)
			mdep("sendinput","keyboard",c,1)
		} else {
			print("Sorry, fakekeyboardinput doesn't yet handle a character of value: ",c)
		}
	}
}

function eval_number(s) {
	global EvalNumber
	eval "EvalNumber="+string(s)
	return(EvalNumber)
}
