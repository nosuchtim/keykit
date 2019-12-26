# This function checks to see if the keylib.k files (in each directory
# mentioned in Keypath) need updating, and updates them.

function updatelib(forceit,forcerekeylib,path,reread) {
	if ( nargs() < 1 )
		forceit = 0
	if ( nargs() < 2 )
		forcerekeylib = 0
	if ( nargs() < 3 )
		path = Keypath
	if ( nargs() < 4 )
		reread = 0
	dirs = split(path,Pathseparator)
	anyupdated = 0
	for ( i in dirs ) {
		dir = dirs[i]
		if ( dir == "" )
			continue
		keylibfn = dir + Dirseparator + "keylib.k"
		keylibtime = filetime(keylibfn)
		updateit = forceit
		files = lsdir(dir)
		seen = []
		# remove all the files we're not interested in
		for ( fn in files ) {
			if ( fn=="." || fn==".." || fn=="keylib.k" ) {
				delete files[fn]
				continue
			}
			lng = sizeof(fn)
			if ( lng<3 )
				suff = ""
			else
				suff = substr(fn,lng-1,2)
			if ( suff != ".k" && suff != ".K" )
				delete files[fn]
		}
		if ( sizeof(files) == 0 ) {
			continue
		}
		for ( fn in files ) {
			if ( fn=="." || fn==".." || fn=="keylib.k" )
				continue
			fullpath = dir + Dirseparator + fn
			if ( filetime(fullpath) > keylibtime ) {
				updateit = 1
				if ( reread ) {
					print("Rereading "+fullpath)
					eval "#include \""+fullpath+"\""
				}
			}
		}
		if ( updateit ) {
			anyupdated = 1
			klf = open(keylibfn,"w")
			for ( fn in files ) {
				fullpath = dir + Dirseparator + fn
				f = open(fullpath)
				if ( f == "" ) {
					print("Unable to open? dir=",dir," fullpath=",fullpath)
					exit(1)
					continue
				}
				while ( (ln=get(f)) != Eof ) {
					if ( substr(ln,1,8) == "function"
					 || substr(ln,1,5) == "class" ) {
						words = split(ln," \t({")
						w1 = words[1]
						if ( w1 in seen ) {
							print("Warning, "+words[1]+" defined in "+fn+", but was already seen in "+seen[w1]+" (directory="+dir+")")
						} else {
							seen[w1] = fn
						}
						put(klf,"#library "+fn+" "+w1+"\n")
					}
				}
				close(f)
			}
			close(klf)
		}
	}
	if ( anyupdated || forcerekeylib ) {
		# This is the built-in that rereads all the keylib.k files
		rekeylib()
		# Also reset Tooltypes so that menus (in tools*.lst files)
		# get re-read
		Tooltypes = 0
	}
}

# This can be used to read every single .k file, looking
# for syntax errors

function readeveryfile(path) {
	path = Keypath
	dirs = split(path,Pathseparator)
	print("READING all .k files, as a test...")
	for ( i in dirs ) {
		dir = dirs[i]
		if ( dir == "" )
			continue
		keylibfn = dir + Dirseparator + "keylib.k"
		keylibtime = filetime(keylibfn)
		files = lsdir(dir)
		seen = []
		# remove all the files we're not interested in
		for ( fn in files ) {
			if ( fn=="." || fn==".." || fn=="keylib.k" ) {
				delete files[fn]
				continue
			}
			lng = sizeof(fn)
			if ( lng<3 )
				suff = ""
			else
				suff = substr(fn,lng-1,2)
			if ( suff != ".k" && suff != ".K" )
				delete files[fn]
		}
		if ( sizeof(files) == 0 ) {
			continue
		}
		for ( fn in files ) {
			if ( fn=="." || fn==".." || fn=="keylib.k" )
				continue
			fullpath = dir + Dirseparator + fn
			# print("Rereading "+fullpath)
			eval "#include \""+fullpath+"\""
		}
	}
	print("DONE.")
}

function rereadlib() {
	updatelib(0,0,Keypath,1)
}
