#name	keyrc
#usage	keyrc()
#desc	This is the very first function called by KeyKit,
#desc	unless the -r option is specified when KeyKit is invoked.
#desc	This function must initialize everything necessary
#desc	for the proper running of KeyKit.  This is normally done
#desc	by calling normboot() to set up the command interpreter and
#desc	start other primary tasks.

function keyrc() {

	global(prerc)	# bug workaround
	global(postrc)	# bug workaround
	Prercfuncs = []
	Postrcfuncs = []

	prelocaldefaults()

	# Guarantee that prerc is first
	if ( defined(prerc) ) {
		addprerc(prerc)
	}

	dokeylocal()

	updatelib(0,1)	# Update the keylib.k files, if anything's changed.
			# The second argument (1) forces a rekeylib()
			# to be executed no matter what.  This is important,
			# because even though keylib.k files may not be
			# updated, the Keypath may have been (and usually is)
			# changed in prerc(), so we need to reread all the
			# keylib.k files.

	# Guarantee that postrc is last
	if ( defined(postrc) ) {
		addpostrc(postrc)
	}

	for ( i in Prercfuncs ) {
		(Prercfuncs[i])()
	}

	rcdefaults()

	rekeylib()	# needed if Keypath has changed

	normboot()
	Rebootfunc = normboot

	rcpostboot()

	for ( i in Postrcfuncs ) {
		(Postrcfuncs[i])()
	}
}

function addprerc(f) {
	Prercfuncs[sizeof(Prercfuncs)] = f
}
function addpostrc(f) {
	Postrcfuncs[sizeof(Postrcfuncs)] = f
}

#name	dokeylocal
#desc	Set up input/output ports.  Look for a file keylocal.k first,
#desc	and if that doesn't exist, use some defaults
function dokeylocal() {

	if ( defined(Keylocal) ) {
		eval "#include "+Keylocal
		keylocal()
		return()
	}

	if ( fileexists("keylocal.k") ) {
		eval "#include keylocal.k"
		keylocal()
		return()
	}

	# See if it's in some global place
	if ( Machine == "win" ) {
		if ( fileexists("c:\\keylocal.k") ) {
			eval "#include c:\\keylocal.k"
			keylocal()
			return()
		}
		if ( fileexists("\\keylocal.k") ) {
			eval "#include \\keylocal.k"
			keylocal()
			return()
		}
	}
	if ( Machine == "mac" ) {
		if ( fileexists("/keylocal.k") ) {
			eval "#include /keylocal.k"
			keylocal()
			return()
		}
	}


	fname = pathsearch("keylocal.k")
	if ( fname != "" ) {
		eval "#include \""+fname+"\""
		keylocal()
		return()
	} else {
		if ( Machine == "win" ) {
			# For convenience, let's open MIDI MAPPER by default
			m = outport("MAPPER")
			# and map the default port to it
			mapport(0,m)
		}
		if ( Machine == "linux" ) {
			# m = outport("alsa")
			# mapport(0,m)
			# inport("alsa")
			outports = midi("output","list")
			for ( i in outports ) {
				if ( outports[i] ~~ "alsa" ) {
					midi("output","open",i)
				}
			}
			inports = midi("input","list")
			for ( i in inports ) {
				if ( inports[i] ~~ "alsa" ) {
					midi("input","open",i)
				}
			}
		}
		if ( Machine == "mac" ) {
			m = outport("QuickTime")
			mapport(0,m)
		}
	}
}

#name	prelocaldefaults
#usage	prelocaldefaults()
#desc	This sets any default values before keylocal.k is called.

function prelocaldefaults() {
	Drummapdefault = "gm"
	Browser = ""
	ACPATCHES = 0
	KeyKitHost = ""
	SmtpServer = ""
	if ( defined(Hostname) )
		KeyKitHost = Hostname
	else
		KeyKitHost = "localhost"
	
	Patchmap = patchmap_gm()
	Patchmap_types = global(patchmap_types_gm)
	KeyKitPort = 3333
	KeyKitRemotePort = 3333

	##############################################################
	## This is the name of the file that is
	## loaded, by default, in the kboom tool.
	KboomDrumkit = "drums.kbm"

	# This one puts "Pluck" (25) on the Shift-Left button
	GroupActions =  [ 1=[0=0,1=2,2=25], 2=[0=1,1=7,2=6] ]

	MatrixSnarf = 0

	Port2Patchmap = []
	Port2Patchtypes = []
	Port2Drummap = []
	Port2Drumtypes = []

	setdefaultchancolormap()
}

#name	rcdefaults
#usage	rcdefaults()
#desc	This sets any default values for which it is intended that
#desc	they can be overridden by postrc().

function rcdefaults() {
	Met = 'p40d24v56c10,l96'
	Metid = -1
	Playquant = 1b
	Menuscrollwidth = 20
	Debug=0
	Default_chan = 1	# used by tools that want to abide by it

	if ( ! defined(Contribdir) )
		Contribdir = "../contrib"

	# many of these are only used in graphical mode, but
	# we still want to be able to override them
	Sweepquant = 1b/4	# 16th note
	Dragquant = 1b/4	# 16th note
	Stepquant = 1b/4	# 16th note
	Kboomquantmin = 1b/8	# minimum quant when reading things into
				# kboom tool, 32nd note
	Kboomquant = 4b
	Kboomsteps = 16

	Flashquick = 1
	Playmode = 2
	Zoomlimit = 8
	Winminwidth = 10
	Winminheight = 10
	Whistory = -1
	Toosmallx = 16
	Toosmally = 16
	Undolimit = 32
	Autoresize = 1
	Stoponpageswitch = 1
	Phraseflashnotes = 1
	Readingpage = 0
	Keybase = 'c'
	Key = 'c'
	Scale = "ionian"
	Mapto = "ionian"
	ConsoleReadedit = global(readedit)
	GrabNoSwitch = 0
	Conph = ''
	Nonotice = 0
	Sliderspeed = 100 # milliseconds per y increment/decrement

	# Clocks will still control things if Sync==1, but this
	# value of Filter will prevent them from being seen
	# when you read MIDI input from the Midiinfifo.
	Filter = CLOCK


	rcdefaults_mdep()
}

#name	rcpostboot
function rcpostboot() {
	if ( defined(Root) && Root != $0 )
		Root.redraw()
}

#name	rcdefaults_mdep
#desc	Machine-dependent rcdefault things

function rcdefaults_mdep() {
	if ( ! defined(Eol) ) {
		Eol = "\n"
		if ( Machine == "win" )
			Eol = "\r\n"
	}
	if ( ! defined(MdepPriority) )
		MdepPriority = "high"
	if ( Machine == "win" ) {
		mdep("priority",MdepPriority)
	}

	if ( Machine == "mac" ) {
		# start up task to watch for "OpenDocuments" Apple event
		task fileWatch()
		# start up task to watch for "Do Script" Apple event
		task scriptWatch()
	}
}

#name	normboot
#usage	normboot()
#desc	This is intended to be the default function that gets called
#desc	when KeyKit initially boots or reboots.  KeyKit calls
#desc	Rebootfunc() when it reboots, so in order for this function
#desc	to be used, the statement "Rebootfunc=normboot" should be
#desc	included in keyrc().  Any tasks that must always be
#desc	active (for example, the loops that monitor mouse and
#desc	console input) should be started here.  To register a
#desc	function that will be automatically restarted upon a reboot, 
#desc	you should add it to the Rebootfuncs array.
#see	addbootfunc

function bootvars() {
	Midiin = []
	Mousein = []
	Pages = []
	Pagesize = []
	Tool = []
	Holder_name2obj = []
	Holder_obj2name = []
	Wphrase = []
	Intrfunc = global(normintr)
	Consgrabfifo = -1
	Miditask = -1
	Controlwinds = 0
	Consechoobj = $0
	Syncport = -1
}

function consoleprintf(...) {
	Console.printf(...)
}

function normboot() {

	if ( ! defined(Rebootfuncs) ) {
		Rebootfuncs = []
		Nbootfuncs = 0
	}
	bootvars()

	if ( Graphics ) {
		gridinit()
		task consloop()
		task consoutloop()
		Miditask = task midiloop()
		Popup = printf
		printf = consoleprintf
	}

	for ( f in Rebootfuncs )
		Rebootfuncs[f]()
}

#name	addbootfunc
#usage	addbootfunc(func)
#desc	Adds a function to the list of functions that will be
#desc	automatically invoked when KeyKit is rebooted.

function addbootfunc(f) {
	Rebootfuncs[Nbootfuncs++] = f
}

#name	normintr
#usage	normintr()
#desc	This function is intended to be the default value of Intrfunc,
#desc	which KeyKit calls when an interrupt is received, typically
#desc	when the user presses the interrupt character on the console.
#desc	This function forces a reboot.  If graphics mode is enabled,
#desc	an attempt is made to save the current tool configuration
#desc	in the file "keydump.lst", which will then be restored after
#desc	the reboot.  In this way, a fairly clean restart is performed.

function normintr() {
	page_write("normintr.kp")
	# reboot()
}
