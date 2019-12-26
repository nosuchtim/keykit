#########################################
# Pattern Library
#########################################



# A simple library for accessing static 
# or dynamic pattern libraries




#########################################
# Interface
#########################################


# patInit
# patAddFn
# patGet
# patSet
# patGetF
# patSetF
# patGetPh
# patSetPh
# patLibInit
# patLibAdd
# patLibRead
# patLibWrite
# patLibGetNames
# patLibFindAll
# patLibSaveAll
# patSetActive
# patPlay
# patStop
# patToolDisplay



 

#########################################
# Data structures
#########################################

#  Pat["a.d"] = ["fn"="ph","ph"='c,d,e']

#  PatLib["a"] = ["a.d"=1, "a.d2"=modified]

#  PatFuncs = ["ph"= myfunction]
 

  

#########################################
# Functionality
#########################################


# Initialise the pattern handling functionality
function patInit(libdir) {
	
	global patFnPh

	# Reset patterns
	Pat=[]

	# Reset libraries
	PatLib=[]


	PatData = [
		"libdir" = libdir,
		"take" = "u.1",
		"active" = ""
	]


	# Store a list of functions to generate phrases 
	PatFuncs=[]

	patAddFn("ph", patFnPh)
	patAddFn("grv", function ? (pat) { return(grvFnGen(pat)) } )

}



# Add a pattern to the handler list
# func must behave like
#  ph=func(pat)
function patAddFn(name, func) {
	PatFuncs[name] = func
}



###############################################################################
# Return the pattern array data
# Returns an empty array if problem
# reporterror is a string containing the location of the request. If there is a problem
# and reporterror is not blank then it prints an error
function patGet(name, reporterror) {
	if (nargs()==1)
		reporterror="Get"

	pat=[]
	if (name in Pat) {
		pat = Pat[name]
		if (typeof(pat) != "array") {
			pat=[]
			if (reporterror) 
				print("Cannot find pattern: " + name)
		}
	} else {
		if (sizeof(reporterror)) 
			print("Cannot find pattern(" + reporterror + "): " + name)
	}
	
	# print("patGetPh", name, pat)
	return (pat)
}



# Set a pattern
function patSet(name, data) {

	Pat[name] = data

	patLibAdd(name)

}



# Set a pattern. Create a new name via version increment
function patSetTake(name, data) {

	name = libNewName(Pat,name)

	patSet(name, data)
}



# Get a field
function patGetF(name, field, reporterror) {
	if (nargs()==2)
		reporterror="GetF"

	pat = patGet(name, reporterror)
	if (sizeof(pat)) {
		return( pat[field] )
	}
}



# Set a field
function patSetF(name, field, value, reporterror) {
	if (nargs()==3)
		reporterror="SetF"
	pat = patGet(name,reporterror)
	if (sizeof(pat)) {
		pat[field] = value
	} 
}



# Return the phrase
function patGetPh(name, reporterror) {
	if (nargs()==1)
		reporterror="GetPh"

	pat = patGet(name,1)

	if (sizeof(pat)) {
		fn = pat["fn"]
		
		if (fn in PatFuncs) {
			
			func=PatFuncs[fn]

			ph = func(pat)	
			if (typeof(ph)=="phrase") 
				return(ph)
			else
				return('')
		}
	} else
		return('')
}



# Set a static phrase
function patSetPh(name,ph) {
	
	pat = ["fn"="ph","ph"=ph]
	
	patSet(name,pat)

}




###############################################################################
# Play a pattern
function patPlay(name,loop,update) {
	
	pat = patGet(name)

	if (sizeof(pat)) {

		ph = patGetPh(name)
		
		tid = realmidi(ph)
		pat["tid"] = tid
		
		if (loop) {
			# Schedule another play 
			len = ph.length
#			t = task
		}
	}
}




# Stop a playing pattern
function patStop(name) {
}



#@@ Display a phrase in a tool
function patToolDisplay(pat) {

	g=kmGetGroup()

	ph=patGetPh(pat)

	if (sizeof(g) && sizeof(ph)) {
		tool=g[0]
		tool.stop()
		tool.set(ph)
		tool.notifyloop() 
	}
}


###############################################################################
# Initialise a library
function patLibInit(libname) {
	PatLib[libname] = []
}



# Add a library entry for this pattern
function patLibAdd(name) {

	# Get both parts of the name
	namelist=patLibSplitName(name)
	
	lnm=namelist[0]

	# Does the library exist already?
	if (lnm in PatLib) {
		lib = PatLib[lnm]
	} else {
		lib=[]
		PatLib[lnm]=lib
	}
	lib[name]=1
}


# Return pattern name split into 
function patLibSplitName(name) {
	names = split("name",".")
	return(names)
}




# Read a library
function patLibRead(libname) {
	print("Reading " + libname + ".p")
	eval("#include " + libname + ".p")
}




# Write a library
function patLibWrite(libname) {
	
	if (!libname in PatLib) {
		print("Cannot find library(patLibWrite): " + libname)
		return()
	}

	lib = PatLib[libname]

	fname=PatData["libdir"] + libname + ".p"

	print("Writing library: " + libname + ".p")
	f = open(fname,"w")

	border="######################################################################"
	put(f, border + "\n# Pattern Library: " + libname + "\n")
	
	# Print pattern list
	names = ""
	Arraysort = 1
	for (nm in lib) {
		names += " " + nm
	}
	put(f, "# Patterns: " + names + "\n")

	put(f, border+"\n")	

	put(f, "\npatLibInit(\"" + libname + "\")\n")

	for (nm in lib) {
		patLibWritePat(f, nm)
	}
	close(f)
}



# Write a pattern to an open library
function patLibWritePat(f, name) {
	
	pat = patGet(name)
	
	if (sizeof(pat)) {
		pat = arraycopy(pat) 
		delete pat["tid"]
		put(f, "patSet(\"" + name + "\", " + string(pat) + ")")
		put(f, "\n")
	}
}



# Return a sorted list of pattern names in the library ie [1="bla.3",2="vsd.w"]
# Return from all libraries if libname=""
function patLibGetNames(libname) {
	if (libname=="") {
		names = libArrayNames(Pat)
	} else {
		if (libname in PatLib) 
			names = libArrayNames(PatLib[libname]) 
		else {
			names=[]
			print("Cannot find library(LibGetNames): " + libname)
		}
	}
	return(names)
}



# Find all .p files in the pattern directory
function patLibFindAll() {
	dir = PatData["libdir"]
	names = libGetFiles(dir, "p")
	return(names)
}



# Save all modified libraries
function patLibSaveAll() {
	for (pat in PatLib) {
		print("Saving " + pat)
	}
}



# Import a collection file
function patLibImportColl(fname, libname) {
	eval "#include \""+fname+"\""
	
	patLibInit(libname)

	for (i in Collection) {
		cpat = Collection[i]
		
		pat = [
			"fn"="ph",
			"info"=cpat["name"],
			"ph"=cpat["phrase"]
		]

		patSet(libname + "." + string(i), pat)
	}

	print("Imported", i, "patterns from " + fname)
}




########################################################################################


# Handler to return a simple pattern
function patFnPh(pat) {
	ph = pat["ph"]
	return(ph)
}



# Define a pattern menu
kmAddMenu("pat", 
	"Pattern menu\nt test  i init  d debug  p play",
	"",
	[
		"i" = function ? () { patInit("../liblocal/") },
		"d" = function ? () { patDebug() },
		"p" = function ? () { patPlay("m.c",1) },
		"x" = function ? () { pat = kmChoosePattern(); kmDisplayMenu() },
		"t" = function ? () { patTest() }
	]
)


########################################################################################
# Test pattern and library functionality
function patTest() {
	print("patTest")
	
	patInit("../liblocal/")
	
#	patLibInit("m")

	nm = "m.c"
	
	print(patLibFindAll())
	patLibRead("m")
	
#	patSetPh(nm, 'c')	
#	patSetF(nm+"4", "ph", 'd')	
#	patSetF(nm, "ph", 'd')	
 #   print(patGetPh(nm))

#	patPlay(nm,1,1)
	print(patLibGetNames("m"))
	patLibImportColl("drums1.kc","e")	
	patLibWrite("e")
#	patLibSaveAll()
}



# Display data structures
function patDebug() {
	print("Pat ",Pat)
	print("PatLib ",PatLib)
	print("PatFuncs ",PatFuncs)
	print("PatData ",PatData)
}





########################################################################################


function patPlayTask(name,update,loop) {

	t = numquant(Now,1b)

    bar = 1

	while ( 1 ) {
		ph = 
		realtime(ph,t)

		t += SeqDur

		sleeptill(t - (1b/8))
            bar++
	}
}




# Set the active pattern
function patSetActive(name) {
	if (sizeof(patGet(name,"SetActive"))) 
		PatData["active"] = name
}



# Return active pattern or empty list
function patGetActive() {
	name = PatData["active"]

	if (name in Pat) 
		return(Pat[name])
	else
	    return([])
}

