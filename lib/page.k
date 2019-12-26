function page_new() {
	page_switchto(new wpage(),newpagename())
	Root.redraw()
}

function page_switchto(pgobj,pgname) {

	# This is the function that gets called whenever we
	# first come to a new page.

	if ( pgobj.classof() != "wpage" )  {
		print("Hey, pgobj=",pgobj," isn't a page?!")
		return()
	}

	if ( Root != $0 ) {
		# Turn everything (like kboom) off on current page
		if ( Stoponpageswitch != 0 ) {
			Root.stop()
			millisleep(100)	# give tools some time to stop tasks
		}
		Root.leave()
		# save current size of current page
		Pagesize[Root] = screen("size")
	}

	Root = pgobj
	if ( nargs() > 1 ) {
		Pages[Root] = pgname
		Pagesize[Root] = screen("size")
	}
	else if ( (Root in Pages) && (Root in Pagesize) ) {
		Oldrootsize = xy(0,0,
				Pagesize[Root]["x1"]-Pagesize[Root]["x0"]-1,
				Pagesize[Root]["y1"]-Pagesize[Root]["y0"]-1)
		screen("size",Pagesize[Root])
	}
	else {
		error("Unexpected Root not in Pages!?")
	}

	Root.enter()

	# force every page to have a console
	foc = Root.focus()
	if ( foc == $0 || foc == $-1 ) {
		s = Root.size()
		tw = Root.textwidth()
		th = Root.textheight()
		o = new wconsole()
		if ( defined(Consolesize) && typeof(Consolesize) == "function" ) {
			Root.addtool(o,Consolesize(s))
		} else {
			Root.addtool(o,xy(s["x0"]+tw,3*s["y1"]/4,
						s["x1"]-tw,s["y1"]-th/2))
		}
		o.redraw()
		foc = o
	}
	Root.focus(foc)	# Console gets set, among other things
	Root.update()
}

function newpagename() {
	n = 1
	found = 1
	while ( found == 1 ) {
		found = 0
		nm = "Page "+string(n)
		for ( o in Pages ) {
			if ( Pages[o] == nm ) {
				found = 1
				break
			}
		}
		n++
	}
	return(nm)
}

function page_switch(o) {
	page_switchto(o)
	Root.redraw()
}

function page_label() {
	nm = getastr("Enter new page name --> ","none")
	if ( nm != "none" )
		Pages[Root] = nm
	
}

function page_write(fname,pg,nm) {
	if ( nargs() < 1 ) {
		fname = browsefiles("Key Page (*.kp)","*.kp",0)
		if ( fname == "" ) {
			print("No file named, no page written.")
			return()
		}
		if ( ! ( fname ~~ ".*\\.kp" ) ) {
			fname = fname + ".kp"
		}
	}
	if ( nargs() < 2 )
		pg = Root
	if ( nargs() < 3 )
		nm = Pages[pg]

	f = open(fname,"w")
	if ( f < 0 ) {
		printf("Can't open %s!\n",fname)
		return()
	}

	printf("Dumping page to %s...\n",fname)

	put(f,"Pageobj="+string(pg)+"\n")
	put(f,"Pagenm=\""+nm+"\"\n")
	put(f,"Pagesz="+string(screen("size"))+"\n")
	put(f,"function keypage_create(r) {\n")
	# put(f,"screen(\"size\","+string(screen("size"))+")\n")

	s = pg.dump()
	put(f,"r.restore("+string(s)+")\n")

	for ( o in pg.children() ) {
		if ( ! defined(o.recreate) )
			continue
		s = o.recreate()
		if ( s == Nullstr )
			continue;
		put(f,"# recreate object "+string(o)+"\n")
		put(f,"o="+s+"\n")
		sz = string(o.size())
		if ( sz != "" )
			put(f,"r.addtool(o,"+sz+")\n")
		# Note that we only dump the state if it's recreateable
		if ( defined(o.dump) ) {
			s = o.dump()
			if ( typeof(s) != "array" )
				print("Hey, \"dump\" method of",o.classof(),"tool didn't return an array!?")
			else if ( sizeof(s) != 0 ) {
				put(f,"o.restore("+string(s)+")\n")
			}
		}
		put(f,"\n")
	}
	put(f,"}\n")
	close(f)
	printf("Done.\n")
}

# This is just so we can get an object id, in page_readnew
class dummyclass {
method init {
	}
}

function page_readnew(fname) {
	if ( nargs() < 1 ) {
		fname = browsefiles("Key Page (*.kp)","*.kp",1)
		if ( fname == "" ) {
			print("No file named, no page read.")
			return()
		}
	}
	if ( ! fileisreadable(fname) ) {
		print(fname,"isn't readable!?")
		# return()
	}

	# The file is expected to have a function named keypage_create(),
	# as well as values for Pageobj, etc.

	# First, we null out keypage_postcreate.  The .kp may define it
	# to be something if it wants to start something up after the
	# page is read.
	global keypage_postcreate
	keypage_postcreate = nullfunc

	Readingpage = 1

	tmpo = new dummyclass()
	Objectoffset = integer(tmpo)+1
	delete tmpo

	eval "#include \""+fname+"\""

	Objectoffset = 0

	if ( Pageobj in Pages ) {
		Readingpage = 0
		print("That page object ("+Pagenm+") already exists!?")
		return()
	}
	if ( lookup(Pages,Pagenm,-1) != -1  ) {
		Pagenm = newpagename()
		print("A page with that name already exists!?")
		print("A new name ("+Pagenm+") is being created for it...")
		millisleep(1000)
	}
	# create a new blank page
	Root = wpage(Pageobj)
	Pages[Root] = Pagenm
	Pagesize[Root] = Pagesz
	Oldrootsize = xy(0,0,
		Pagesize[Root]["x1"]-Pagesize[Root]["x0"]-1,
		Pagesize[Root]["y1"]-Pagesize[Root]["y0"]-1)
	screen("size",Pagesize[Root])
	Root.redraw()
	gotsize = screen("size")

	if ( gotsize["x1"] != Pagesz["x1"] ) {
		xfact = float(gotsize["x1"])/Pagesz["x1"]
		yfact = float(gotsize["y1"])/Pagesz["y1"]
		doresize = 1
	}
	else
		doresize = 0

	Root.redraw()

	km = new kmsg("Reading "+fname+"  -  please wait...")
	km.resize(Root.size())
	km.redraw()
	sync()

	lock("interploop")	# so it doesn't put out prompt right away
	Resizefix = 0
	keypage_create(Root)
	Resizefix = 1

	Readingpage = 0

	if ( doresize ) {
		for ( i in Root.children() ) {
			csz = i.size()
			csz["x0"] *= xfact
			csz["y0"] *= yfact
			csz["x1"] *= xfact
			csz["y1"] *= yfact
			i.resize(csz)
		}
	}
	# Make sure all the tool Holders notifyobj's get notified, so they
	# get updated (only possible after everything's loaded on the page)
	notifylist = []
	for ( h in Holder_obj2name ) {
		o = h.getnotifyobj()
		if ( o != $0 && o != $-1 && ! (o in notifylist) )
			notifylist[o] = h
	}
	for ( o in notifylist ) {
		o.notifyofchange(h)
	}

	deleteobject(km)

	Root.redraw()
	Root.update()

	unlock("interploop")

	task page_post(Root)
}

function page_post() {
	millisleep(300)		# to allow things to stabilize
	keypage_postcreate(Root)
}

function page_readmerge() {
	print("page_readmerge called")
}

function snapshot() {
	if ( ! defined(Snapnum) )
		Snapnum = 1
	while ( 1 ) {
		Snappage = "snap"+string(Snapnum++)
		Snapfile = Snappage+".kp"
		if ( ! fileexists(Snapfile) )
			break
	}
	page_write(Snapfile,Root,Snappage)
	print("This page has been written to ",Snapfile)
}


# This probably doesn't work anymore, but it may be resurrected someday
function restartconfig() {
	rereadlibs()
	oldroot = Root
	n=1
	for ( o in Pages ) {
		nm = "restart"+string(n)+".kp"
		page_write(nm,o)
		n++
	}
	bootvars()
	page_new()	# a new blank one, so we can get started
	for ( k=1; k<n; k++ ) {
		nm = "restart"+string(k)+".kp"
		page_readnew(nm)
	}
	page_switchto(oldroot)
}
