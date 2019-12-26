#########################################
# KeyMenu 
#########################################

# A menu has a description
# A menu owns keyed actions
# An action contains an array with a "type" field
# A menu can be built on the fly ie. pattern names


#@@ Add functionality to allow a menu create a dynamic status line ie
# >> Channel:10  Pattern:m.dr4  




#########################################
# Interface
#########################################





#########################################
# Data structures
#########################################



# KMData is data used by this system to run the menu
#	tid - Task used to run console mapping
#	last - Last menu name
#	allblank - Big list of backspaces! 



# KMMenu stores the menu descriptions and action lists
#	descr - Description
#	?actions - 










#########################################
# Nearly New Features
#########################################

# User definable menus via commands 
#  ie. F2(keymenu) l(learn) c realtime('c')\n  u(usermenu) c('c' plays)
#  ie. F2(keymenu) l(learn) c realtime('c')\n  u(usermenu) c('c' plays)

# kmLearn() 
#   Print available user menus
#   Use kmRead to ask for menu name, key and command
#   Create action in parent menu


# Take the actions from another menu 
#  kmPoachActions("newmenu", "root", "1234567890!@#$%^&*() ")

# Output all controllers for a track. track = -1 gets all
# If activemsgs is true then the msg must be in activemsg list
#  ph = kmGetTrackMsgs(track, activemsgs)

# A menu can be laid out in rows with shift indicator via a call to :
#	["x"=3,"y"=4, "sh"=0] = kmKeyToXY(x)






#########################################
# Functionality
#########################################



PatCons = [
	"bpm"=1,
	"ph"=1,
	"pat"=1,
	"tra"=1,
	"cut"=1,
	"off"=1,
	"len"=1,
	"sca"=1,
	"dur"=1,
	"rep"=1
]



# Initialise the keymenu structure and bind it to a function key
function kmInit (fnkey, startup) {
	global kmToggle
	
	# Bind the kmOn function to 
	# the specified key
	funkey(fnkey, kmToggle)

	
	funkey(3, function ? () { print("bla3") } )
	
	# Setup any data needed
	KMData = [
		"track" = 10,
		"tool" = "",
		"playtid" = -1,
		"constid" = -1,
		"active" = startup
	]

	
	# Generate the AllBlank backspace whizzo string
	AllBlank = "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
	AllBlank += AllBlank
	AllBlank += AllBlank


	# Setup the actions list
	KMData["actions"] = [
		"C" = function ? (c,action) { kmActionControl(c,action) },
		"M" = function ? (c,action) { kmActionSwitchTo(c,action) },
		"W" = function ? (c,action) { kmActionWindow(c,action) },
		"T" = function ? (c,action) { kmActionTrack(c,action) }
	]

	# Functions to handle generating midi messages 
	KMMsgFuncs = [
		0 = function ? (msgdata,ch,val) { return(controller(ch, msgdata["c"], val)) },
		8 = function ? (msgdata,ch,val) { return(progchange(val, ch)) }
	]

#		1 = function ? (msgdata,ch,val) { return (nrpn(ch+1, msgdata["msb"], msgdata["lsb"], val) )) }
#		16 = function ? (msgdata,ch,val) { return(awec(ch, msgdata["c"], val)) }


	KMEval = [
	]

	# Setup the tools list
	KMTools = []

	# Setup the global keyboard list
	KMData["globals"] = [
		" " = function ? () { print("\nStop!"); stop() },
		"[" = function ? () { kmMoveConInc(-1) },
		"]" = function ? () { kmMoveConInc(1) },
		"\\" = function ? () { reload(); kmDisplayMenu() },
		"`" = function ? () { kmSwitchTo("root") },
		"~" = function ? () { kmDisplayMenu() },
		"?" = function ? () { kmEval() },
		"/" = function ? () { kmGrabTool() },
		"|" = function ? () { kmSetBpm() },

		"-" = ["type"="T", "track"=0],
		"0" = ["type"="T", "track"=10],
		"1" = ["type"="T", "track"=1],
		"2" = ["type"="T", "track"=2],
		"3" = ["type"="T", "track"=3],
		"4" = ["type"="T", "track"=4],
		"5" = ["type"="T", "track"=5],
		"6" = ["type"="T", "track"=6],
		"7" = ["type"="T", "track"=7],
		"8" = ["type"="T", "track"=8],
		"9" = ["type"="T", "track"=9]
	]

	kmSetupXYMap()

	if (!defined ConChan) {
		msgInit()
	}

}


# Add an array of key to x,y,shift into KMData["xysmap"]
# This is used by 
function kmSetupXYMap() {

	# Anyone made a foreign keyboard map? please mail it to me please please please please please 
	s  = "` 0 1 0  ~ 0 1 1 "
	s += "1 1 1 0  2 2 1 0  3 3 1 0  4 4 1 0  5 5 1 0  6 6 1 0  7 7 1 0  8 8 1 0  9 9 1 0  0 10 1 0  - 11 1 0  = 12 1 0  \\ 13 1 0 "
	s += "q 1 2 0  w 2 2 0  e 3 2 0  r 4 2 0  t 5 2 0  y 6 2 0  u 7 2 0  i 8 2 0  o 9 2 0  p 10 2 0  [ 11 2 0  ] 12 2 0 "
	s += "a 1 3 0  s 2 3 0  d 3 3 0  f 4 3 0  g 5 3 0  h 6 3 0  j 7 3 0  k 8 3 0  l 9 3 0  ; 10 3 0  ' 11 3 0 "
	s += "z 1 4 0  x 2 4 0  c 3 4 0  v 4 4 0  b 5 4 0  n 6 4 0  m 7 4 0  , 8 4 0  . 9 4 0  / 10 4 0 "

	s += "! 1 1 1  @ 2 1 1  # 3 1 1  $ 4 1 1  % 5 1 1  ^ 6 1 1  & 7 1 1  * 8 1 1  ( 9 1 1  ) 10 1 1  _ 11 1 1  + 12 1 1  | 13 1 1 "
	s += "Q 1 2 1  W 2 2 1  E 3 2 1  R 4 2 1  T 5 2 1  Y 6 2 1  U 7 2 1  I 8 2 1  O 9 2 1  P 10 2 1  { 11 2 1  } 12 2 1 "
	s += "A 1 3 1  S 2 3 1  D 3 3 1  F 4 3 1  G 5 3 1  H 6 3 1  J 7 3 1  K 8 3 1  L 9 3 1  : 10 3 1  \" 11 3 1 "
	s += "Z 1 4 1  X 2 4 1  C 3 4 1  V 4 4 1  B 5 4 1  N 6 4 1  M 7 4 1  < 8 4 1  > 9 4 1  ? 10 4 1"

	# split the key map into [key x y shift key x y shift] groups
 	a = split(s)

	map = []
	alen = sizeof(a)

	# Loop thru key x y shift
	for (i=0; i<alen; i+=4) {
		map[a[i]] = ["x"= integer(a[i+1]),"y" = integer(a[i+2]),"s"= integer(a[i+3])]
	}
	
	# Add CR
	map[ a[ascii(13)] ] = ["x"=12,"y"=2,"s"=0]

	KMData["xysmap"] = map
}



# Return the keyboard data shifted
function kmKeyToXYS(c) {
	if (c in KMData["xysmap"]) {
		
		key = KMData["xysmap"][c]
		return(key)

	} else {

		# Unkown key
		print(ascii(c))
		key = ["x"=-1,"y"=-1,"s"=-1]
		return( key )

	}
}



# Turn the keyboard monitor on
function kmOn () {
	if ( KMData["constid"] < 0 )
		KMData["constid"] = task kmConsTask()
}




# Stop the task
function kmOff () {
	if ( KMData["constid"] >= 0 ) {
		kill(KMData["constid"])
	}
}



# Switch the keyboard monitor on and off
function kmToggle() {

	if ( KMData["constid"] < 0 )
		kmOn()
	else {
		kmOff()
	}
}




function kmConsTask() {
	global kmConsDone

	# Setup an exit handler for when the task dies
	onexit(kmConsDone)

	# Stop any keystrokes printing to console
	Consecho = 0

	# Display a welcome message
	kmSwitchTo(KMData["active"]) 

	# Loop until killed or escape
	# Pressing function key again should kill it off.
	while ( 1 ) {
		
		KMActive = KMMenu[KMData["active"]]

		# Grab the keyboard fifo but 
		# promise to give it back
		f = kmGetFifo()

		# Read a character (string)
		c = get(f)

		# Press escape to quit
		if (ascii(c)==27) {
			break
		}

		# Call keyboard handler here
		kmKeyPress(c)

	}
}





# Keyboard handler
function kmKeyPress(c) {
	
	#print(">>>>",KMData["fifo"])

	# Determine first if it is in the menu's actions
	if (c in KMActive["actions"]) {
		
		action = KMActive["actions"][c]
#	print(KMActive["name"],c,"+++a")
		
	# Now try the menu's default handler
	} else {
#		print(KMActive["name"],c,"+f")

		func=KMActive["fndefault"]

		# Can the func handle it?
		if (func(c)) {
#			print(KMActive["name"],c,"+f1")
			return()

		# No we've got to go global...
		} else {
	
#			print(KMActive["name"],c,"+g")

			# Now look in the global list
			if (c in KMData["globals"]) {

				action = KMData["globals"][c]

			} else {
				# Nobody wants me? i give up!
				return()
			}
		}
	}


	# Run the specified action
	kmRun(c, action)
#	print("rundone")
}



function kmRun(c, action) {

	actiontype = typeof(action)

	# If it is a function then just run it directly
	if (actiontype == "function") {
	
		action()

	} else if ((actiontype == "array") && ("type" in action)) {

		# If it is an array then determine its type 
		t = action["type"]

		# If you can find the handler then run with it
		if ( t in KMData["actions"]) {

			# Run function definition for specific action type
			func = KMData["actions"][t]
			func(c,action)
		}
	}
}



function kmRead(prompt,default) {
	if (nargs()==1) 
		default=""

	save = Consecho 
	Consecho = 1
	
	f = kmGetFifo()

	cmd = kmReadEdit(f, prompt, default)

	Consecho = save

	return(cmd)
}



# Return key index of item chosen thru scroll list
function kmChoose(prompt,arr,start) {

	if (nargs()==2) 
		start = 1

	if (!sizeof(arr)) 
		return(-1)

	prompt = AllBlank + prompt 
	
	f = kmGetFifo()
	
	choice = start
	size = sizeof(arr) 
	if (start==0) 
		size--

	while (1) {
		value = arr[choice]
		printf(prompt + value)

		c = get(f)
		
		if (c==ascii(13)) 
			break
		else if (c==ascii(27)) { 
			choice=-1
			break
		} else if ((c==" ") && (value in Pat)) {
			patPlay(value,0,1)
		} else if ((c=="g") && (value in Pat)) {

			ph = patGetPh(value)
		 	g=kmGetGroup()

			if (sizeof(g) && sizeof(ph)) 
				g[0].set(ph)

		} else if (c==",")
			choice -= 1
		else if (c==".")
			choice += 1
		else {
			xys=kmKeyToXYS(c)
			if (xys["y"]==1)
				choice += 1
			else if (xys["y"]==2) 
				choice -= 1
		}
		
		choice = libGuardMinMax(choice,start,size)

		value = arr[choice]
		if (value in Pat) {
			ph = patGetPh(value)
		 	g=kmGetGroup()

			if (sizeof(g) && sizeof(ph)) 
				g[0].set(ph)
		}
	}

	return(choice)
}


function kmReadEdit(f,prompt,default) {
	if (nargs()<3)
		s = ""
	else
		s=default

	printf(AllBlank + prompt + s)
	
	esc = ascii(27)
	for ( ;; ) {
		c = get(f)
		if ( c == Interrupt || c == Eof )
			return(c)
		if ( c == "\n" || c == "\r") {
			break
		}
		if ( c == esc) {
			s = ""
			break
		}
		if ( c == Erasechar ) {
			s = substr(s,1,sizeof(s)-1)
			#printf("%s%s%s",Allblank,prompt,s)
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







# Clean up console task
function kmConsDone() {
	# Retype on the keyboard
	Consecho = 1
	Root.releaseconsole()

	# Give back task
	KMData["constid"] = -1

	# Put the prompt back
	printf("\nkey>")
}




# Handle a controller message
function kmActionControl(c,action) {
	# Get active channel
	ch = KMData["track"]

	if ("ch" in action) {
	# Override active channel
		ch=action["ch"]
	}

	inc = 1
	if ("inc" in action) {
	# Override active channel
		inc=action["inc"]
	}

	nm = action["name"]
	if (!nm in ConChan) {
		print("Cannot find msg:",name)
		return()
	}

	# Read value from an array of [Control][Channel]
	if (ch in ConChan[nm]) {
  	   val = ConChan[nm][ch]
	} else {
	   val = 63
    }

	# Keep the value within bounds
	val = libGuardMinMax(val + (inc * ConInc),0,127)
	
	printf("%sch:%d %s:%d", AllBlank, ch,nm,val)

	kmControlSet(nm,ch,val)

	# Generate message
	ph = kmOutMsg(nm,ch,val)

}



# Set a controller to a value
# Output message to device
function kmControlSet(connm,ch,val) {

	# Update value in memory
	ConChan[connm][ch] = val
	
}



# Move the increment up or down
function kmMoveConInc(direction) {
	if (direction == 1) {

		if (ConInc < 16) {
			ConInc *= 2
		} else {
			ConInc = 1
		}
	} else {
		if (ConInc > 1) {
			ConInc /=  2
		} else {
			ConInc = 16
		}
	}

	printf("%sController Increment: %d", AllBlank, ConInc)
}



# Switch to a named menu
function kmSwitchTo(name) {

	if (name in KMMenu) {
		KMActive = KMMenu[name]

		# Store the name for next time
		KMData["active"] = name
		
		kmDisplayMenu()

	}
	
}



# Handle a menu switch
function kmActionSwitchTo(c,action) {
	if ("name" in action) {
		kmSwitchTo(action["name"])
	}
}



# Display active menus description
function kmDisplayMenu() {

	# Take a new copy of the menu
	name = KMData["active"]
	KMActive = KMMenu[name]

	print(AllBlank + ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	print(AllBlank + KMActive["descr"])
}




# Set menu definitions
function kmAddMenu(name, descr, controllers, actions, fndefault) {

	# Add controllers
	clist = split(controllers)

	clen = sizeof(clist)
	for(i=0; i<clen; i+=2) {

		# Get key-controller pairs
		# Skip menu markers
		if (clist[i]==">>") 
			i++
		key = clist[i]
		cname = clist[i+1]

		# Add up
		action = ["type"="C", "name"=cname, "inc"=1]
		actions[key] = action

		# Add down
		ucase=ascii(ascii(key)-32)
		action = ["type"="C", "name"=cname, "inc"=-1]
		actions[ucase] = action
	}

	# Create menu structure if you need to
	if (!defined KMMenu) 
		KMMenu = []

	menu = [
		"name"=name,
		"descr"= descr + "  " + controllers,
		"actions"=actions
	]

	# Supply a default handler for keys. 
	if (nargs() > 4) {
		menu["fndefault"] = fndefault
	} else {
		menu["fndefault"] = function ? () { return(0) }
	}

	KMMenu[name] = menu
}






#  Dump controller map
function kmShowValues() {
			
	print("Controller Map")
	Arraysort = 1
	for (c in ConChan) {
		if (sizeof(ConChan[c])) {
			print(c,ConChan[c])
		}
	}
	Arraysort = 0
}



#  Show tracks controller map
function kmShowTrackValues(track) {
			
	printf("%sch:%d> ", AllBlank, track)
	Arraysort=1
	for (c in ConChan) {
		if (typeof(ConChan[c])=="array") {
			if (track in ConChan[c]) {
				printf("%s: %d  ", c, ConChan[c][track])
			}
		}
	}
	Arraysort=0

	print("")
}




# Change the active channel
function kmActionTrack(c,action) {

	# Check it is a valid message
	if ("track" in action) {
		track = action["track"]

		if ((track > -1) && (track < 17)) {

			KMData["track"] = track

			kmShowTrackValues(track)
		}
	}
}




# Return a midi message for this channel and value
function kmGetMsg(nm,ch,v) {

	ph = ''

	# If you can find the controller
	if (nm in MsgMap) {

		msgdata = MsgMap[nm]
		fn = msgdata["fn"]
		
		# Find a handler
		if (fn in KMMsgFuncs) {
			func = KMMsgFuncs[fn]

			# Execute handler to return a phrase
			ph = func(msgdata,ch,v)
		}
	}

	return(ph)
}



# Generate and output a message
function kmOutMsg(nm,ch,v) {

	ph = msgGet(nm,ch,v)

	# Add a stoppable task
	tid = realmidi(ph)
	registop(tid)
}



# Generate a patch message with prog,
function kmGetPatchMsg(ch) {
	
	ph = kmGetMsg("msb",ch,v)
	ph += kmGetMsg("lsb",ch,v)
	ph += kmGetMsg("prg",ch,v)

	return(ph)

}










# Choose a pattern from the pattern collection
function kmChoosePattern() {

	# Print patterns

	# Loop until the user is happy
	patlast = ""
	while (1) {
		pat = kmRead(AllBlank + "pat: ")

		if (pat == "=") {
			patSetActive(patlast)
			break
		}

		if (pat == "") {
			break
		}

		
		ph = patGetPh(pat)

		# Ahh the cycle of life
		# Out with the old....
		kill(KMData["playtid"])

		# ... and in with the new
		tid = realtime(ph)
		KMData["playtid"] = tid

		registop(tid)

		patlast = pat
	}

	return(pat)
}


# Return [or grab] a handle to the fifo
function kmGetFifo1() {

	fifo = KMData["fifo"]

	if (typeof(fifo) != "integer") {
	
		print ("<",fifo,typeof(fifo))
		fifo = Root.grabconsole()
		KMData["fifo"] = fifo
	
	} else {
		print (">",fifo,typeof(fifo))
	}
	return(fifo)

}


# Return [or grab] a handle to the fifo
function kmGetFifo() {
	Root.releaseconsole()

	fifo = Root.grabconsole()
#	print(fifo)

	KMData["fifo"] = fifo

	return(fifo)

}



# Sweep a window
function kmActionWindow(c,action) {

	# Sweep the tool requested
	if ("name" in action) {
		name = action["name"]
		print(AllBlank + "Sweeping: " + name)
		sweeptool(name)
	}
}




############################################################################



# Grab a tool and store it in the tools list
function kmGrabTool() {
	
	nm=kmRead("Tool name(blank=active):")

	o = wselect()

	if ( o == Root )
		return()

	if (sizeof(nm)) 
		KMTools[nm]=o
	else {
		T = o
		KMTools[""]=o	
	}
}



function kmGrabToolActive() {
	
	print(AllBlank + "Point to window to grab as active")

	o = wselect()

	if ( o == Root )
		return()
	
	KMTools[""]=o
}



# Set the bpm via key input 
function kmSetBpm() {
	bpm = kmRead("Bpm: ")
	if (sizeof(bpm)) {
		bpm=float(bpm)
		setbpm(bpm)
	} else 
		print("Bpm:" + string(getbpm()))		
}



# Write a page
function kmPageWrite() {

	name = kmRead("Page: ")

	if (sizeof(name)) 
		page_write(name)
}


# Create a new tool from a scrollable list
function kmToolChoose(type) {
	
	arr = tooltypes(type)
	names = libArrayFields(arr, "class", 0)

	tool = kmChoose("Tool:", names, 0)

	if(tool!=-1) {
		sweeptool(arr[tool]["class"])
	}

	kmDisplayMenu()
}




# Clear eval history
function kmEvalClear() {
	
	del=sizeof(KMEval)-99

	if (del > 0) {
		i=0
		for(i in KMEval) {
			# Delete old entries
			delete KMEval[i]
			i++
			if (i==del) 
				break
		}
	}
}


	 
# Evaluate a string
function kmEval() {
	
	# Delete old entries
	kmEvalClear()

	default = ""
	while (1) {

		# Get the users choice
		str = kmRead("Eval: ",default)
		default=""

		if (str=="") 
			break
		else if (str=="\\") {
			reload()
		} else if (str==",") {
			default = kmHist()
		} else if (str==".") {
			str = kmHist()
			
			kmEvalRun(str)
		} else {
			kmEvalRun(str)

			# Store the choice for a later date
			key = sprintf("%09d",Now)
			KMEval[key] = str
		}
	}
	kmDisplayMenu()
}



# Run the suggested code
function kmEvalRun(str){
	
	if (!sizeof(str))
		return()

	strexec = "print(" + str + ")"

	tid = task kmEvalTask(strexec)
	wait(tid)

}



# Choose a history item
function kmHist() {
	l=[]
	n=sizeof(KMEval)
	for(i in KMEval) {
		l[n]=KMEval[i]
		n--
	}
	print(n)
	x=kmChoose("Hist: ",l,0)
	print()
	return(l[x])
}


function kmEvalTask(s) {
	eval(s)
}




# Set the active pattern
function kmSetActivePat1() {
	
	names = patLibGetNames("")
	
	pat = kmChoose("Patterns:", names)
	
	if (pat!=-1) 
		patSetActive(names[pat])
	
	kmDisplayMenu()
}


# Set the active pattern
function kmSetActivePat2() {
	pat = kmChoosePattern()
	if (sizeof(pat)) 
		patSetActive(pat)
	kmDisplayMenu()
}



########################################################


# A quick toy for playing with patterns
function mcPatToy(c) {

	xys = kmKeyToXYS(c)

	x = xys["x"]

	if ((x>11) || (x<1)) {
		return(0)

	} else {
		print(xys)
		
		v = kmRead("age")
		nm = kmChoosePattern()
		return(1)
	}
}




kmAddMenu("cmap", 
	">> 0-9 channel",
	"\n>> q aa  w ad  e as  r ar  t al  y lfo  u rev  i del  o efx  p pan  \n>> a fa  s fd  d fs  f fr  g fl  h hzc  j prg  k lsb  l vol\n>> z pa  x pd  c ps  v pr  b pl  n fil  m res",
	[
	]
)



kmAddMenu("bla", 
	">> bla de bla its a toy.\n>> Press a key",
	"",
	[
	], 
	mcPatToy
	#function ? (c,action) { return(mcPatToy(c,action)) }
)



kmAddMenu("user", 
	"",
	"",
	[
	] 
)










############################################################################
kmAddMenu("root", 
	">> b bla  c cmap  g group  q quikgroove  w win\n" +
	">> zx choosepat \n" +
	">> tT wtool  m wmove  r wresize  s wswap  d wdelete \" \" wsnarf\n" +
	">> ,play  .stop  <> moveSong  ;' moveA  :\" moveB  ", 
	"", # "\nh hzc  f fil  v vol", 
	[
		# Menu links
		"q" = ["type"="M", "name"="grv"],
		"g" = ["type"="M", "name"="group"],
		"p" = ["type"="M", "name"="pat"],
		"w" = ["type"="M", "name"="win"],
		"c" = ["type"="M", "name"="cmap"],

		# Pattern
		"z" = function ? () { kmSetActivePat1() },
		"x" = function ? () { kmSetActivePat2() },

		# Song
		"i"  = function ? () { songInit(Song1, "bla", 4, 4) },
		";" = function ? () { },
		"'" = function ? () { },
		":" = function ? () { },
		"\"" = function ? () { },
		"<" = function ? () { },
		">" = function ? () { },
		"," = function ? () { },
		"." = function ? () { },

		"y" = function ? () { grvTest() },
		"t" = function ? () { kmToolChoose(1) },		
		"T" = function ? () { kmToolChoose(2) },		

		# Window functionality
		"s" = wswap,
		"r" = function ? () { print("Point to window to resize"); wresize() },
		"d" = function ? () { print("Point to window to delete"); wdelete() },
		"m" = function ? () { print("Point to window to move"); wmove() },
		" " = function ? () { print("Point to window to Snarf"); wsnarf() },

		# Misc
		"k" = function ? () { print(msgGetFade("vol",1,16b,16,"1 2 3 4 1 6 7 2"))},
		"k" = function ? () { kmInit(2, "root") }
#		"m" = function ? () { togglemet() },
	]  
)



kmAddMenu("win", 
	">> \" \" redraw  hv warrange  HV wmax  - activetool  = grabtool  \n>> [ pageread  ] pagewrite  r resize  d delete  \n>> Create: c chord  g  group  k kboom  v values",
	"",
	[
		" " = function ? () { Root.redraw() },
		"d" = wdelete,
		"r" = wresize,
		"d" = wdelete,
		"=" = kmGrabTool,
		"-" = kmGrabToolActive,
		"[" = kmPageRead,
		"]" = kmPageWrite,

		"H" = function ? () { wmax("x") },
		"V" = function ? () { wmax("y") },
		"h" = function ? () { warrange("x") },
		"v" = function ? () { warrange("y") },

		"k" = ["type"="W", "name"="wkboom"],
		"c" = ["type"="W", "name"="wchord"],

		"g" = ["type"="W", "name"="wgroup"]
	]
)


