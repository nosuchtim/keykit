#name	gridinit
#usage	gridinit()
#desc	This is the code that initializes the graphics mode of KeyKit.
#desc	It starts up things like the mouseloop() task, which handles
#desc	mouse input, and sets up the screen with the initial tool set
#desc	by calling toolrc().

#define WMODIFY(w,expr) if(premodify(w)){expr;postmodify(w)}
#define MODIFY(expr) if(premodify(w)){expr;postmodify(w)}
#define WADD(w,expr) if(preadd(w)){expr;postadd(w)}
#define ADD(expr) if(preadd(w)){expr;postadd(w)}

constant()

Flashlimit = 200

function griderr() {
	priority(-1,Defpriority)
	setmouse(ARROW)
}

function gridinit() {

	Pickfilter=""

	setmouse(BUSY)

	Errorfunc = griderr

	Snarftoolclass = ""
	setsnarf('')
	Timeval = ["Whole"=4b,"Half"=2b,"Quarter"=1b,"Eighth"=1b/2,
		"Sixteenth"=1b/4,"Thirtysecond"=1b/8,"Sixtyfourth"=1b/16]
	Konnect = $0
	Kboomtool = $0
	Grindertool = $0
	Mousebroadcast = $0
	definecontrol()

	# Create the first page
	Root = $0

	pg = ""
	# Initconfig is the name of the initial page
	if ( defined(Initconfig) && Initconfig != "" ) {
		pg = Initconfig
	}
	if ( pg != "" ) {
		pagepath = pathsearch(pg)
		if ( pagepath == "" ) {
			pagepath = "./" + pg
		}
		if ( fileisreadable(pagepath) ) {
			page_readnew(pagepath)
		} else {
			print("Can't find page '"+pagepath+"', using default page.")
			pg = "" # use the default page
		}
	}
	if ( pg == "" ) {
		# Create a new default page
		o = new wpage()
		page_switchto(o,newpagename())
	}

	Oldrootsize = screen("size");

	Redrawfunc = global(normredraw)
	Resizefunc = global(normresize)
	Exitfunc = global(normexit)

	if ( findtask("mouseloop") < 0 )
		task mouseloop()

	if ( defined(Nobrowsefiles) ) {
		browsefiles = global(fakebrowsefiles)
		if ( typeof(browsefiles) != "function" )
			browsefiles = nullfunc
	}

	Activemenu = $0
	Lastobj = $0
	initfunkeys()

	setmouse(ARROW)

	if ( defined(Inittask) && Inittask != "" ) {
		task initial_task(Inittask)
	}
}

function initial_task(s) {
	# delay just a bit, let things settle down
	sleeptill(Now+1b)
	# If it's just a function name, add parens
	if ( ! ( s ~~ "(" ) )
		s = s + "()"
	cmd = "Itaskid = task "+s
	eval cmd
}


function toolhelp(toolname) {
	fn = pathsearch(toolname+".html")
	if ( fn == "" ) {
		print("No help for "+toolname)
	} else {
		cmd = Browser+" "+fn
		system(cmd)
	}
}

function mainhelp() {
	cmd = Browser+" "+Keyroot+Dirseparator+"index.html"
	print("cmd=",cmd)
	system(cmd)
}

function f1func() {
	o = Root.childunder(Lastmouse)
	if ( defined(Browser) ) {
		if ( o == Root )
			mainhelp()
		else
			toolhelp(o.classof())
	} else {
		if ( o == Root )
			help("contents","tools")
		else
			help(o.classof(),"tools")
	}
}

function initfunkeys() {
	funkey(1,f1func)
}
