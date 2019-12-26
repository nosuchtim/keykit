####################################################################################
# Miscelaneous Library Functions
####################################################################################





#########################################
# Interface
#########################################





#########################################
# Data structures
#########################################


# 







#########################################
# Functionality
#########################################




# Return a list of names from an array [1="bla",2="bob"]
function libArrayNames(arr,start) {

	if (nargs()==1)
		start=1

	save=Arraysort
	Arraysort=1

	names=[]
	for(nm in arr) {
		names[start]=nm
		start+=1
	}

	Arraysort=save
	return(names)
}


# Return a list of fields from an array [1="bla",2="bob"]
function libArrayFields(arr,field,start) {

	if (nargs()==1)
		start=1

	save=Arraysort
	Arraysort=1

	fields=[]
	for(nm in arr) {
		fields[start]=arr[nm][field]
		start+=1
	}

	Arraysort=save
	return(fields)
}





# Return a list of files
function libGetFiles(dir,mask) {

	files = lsdir(dir)
	save = Arraysort
	Arraysort = 1
	# remove all the files we're not interested in
	for ( fn in files ) {
		ext = libSplit(fn,".")
		ext = ext[sizeof(ext)-1]

		if ( fn=="." || fn==".." || ext!=mask) {
			delete files[fn]
			continue
		}
		files[fn] = filetime(dir + fn)
	}
	Arraysort = save
	return(files)
}



# libJoinIndex([1=2,3=4], " ") = "1 3"
function libJoinIndex(arr,delim) {
	str=""
	for(i in arr) {
		str+=string(i) + delim
	}
	return(str)
}



# libJoinValue([1=2,3=4], " ") = "2 4"
function libJoinValue(arr,delim) {
	str=""
	for(i in arr) {
		str+=string(arr[i]) + delim
	}
	return(str)
}


# libJoinValue(["nm"=2,"nm"=4], "nm", " ") = "2 4"
function libJoinField(arr,field,delim) {
	str=""
	for(i in arr) {
		str+=string(arr[i][field]) + delim
	}
	return(str)
}


# Return a new key for the array via version numbering 
#  ie. m.c, m.c1, m.c2...
function libNewName(arr, name) {
	# Strip trailing numbers

	ver = ""
	i = sizeof(name)
	while(1) {
		
		s = substr(name,i,1)
		a = ascii(s)
		
		if ((a<48) || (a>57)) 
			break

		ver = s + ver
		i--
	}

	if (sizeof(ver)) 
		n=integer(ver)
	else
		n=1

	nameroot = substr(name,1,i)
	while (name in arr) {
		name = nameroot + string(n)
		n++
	}

	return(name)
}



# Split a string into parts ie libSplit("bla.vla",".") = [1="bla",2="vla"]
function libSplit(str,delim) {
	len=sizeof(str)

	pos=0
	splits = []
	s=""
	for(i=1; i<=len; i++) {

		c = substr(str,i,1)

		# Do we have a match
		if (c == delim) {
			
			splits[pos]=s
			pos+=1
			s=""

		} else {
			s += c
		}
	}
	# Add last word
	if (sizeof(s)) {
		splits[pos]=s
	}
	return(splits)
}














####################################################################################
function awec(chan,ctrl,value) {

	value = integer(value)
	chcnt = 0xb0 | (chan - 1)

	msb = (value + 8192) / 128 
	lsb = (value + 8192) % 128 
	ph = midibytes(chcnt, 0x63, 127, chcnt, 0x62, ctrl, chcnt, 6, msb, chcnt, 38, lsb)
	return(ph)
}


function bb(dur) {
	SeqDur = dur
	registop(task task_bb())
}


# Return a phrase from a collection.
# Collection
function cg(col,name)
{
	if (typeof(col)=="string") {
		eval "Colsrc = " + col
	}
	else {
		Colsrc = col
	}
		
	for (i in Colsrc) {
		if (Colsrc[i]["name"] ==name)
			return(Colsrc[i]["phrase"])
	}
	return ()
}




# map = [name=def, ]
function csout1(fn,ph,map,i) {
	f = open(fn,"w")
#	put(f,"size "+string(1+latest(p))+" 128\r\n")
	for (n in ph) {
		s = "i " + string(n.chan)
		s += " " + string(n.time*1.0/Clicks)
		s += " " + string(n.dur*1.0/Clicks)
		s += " " + string(n.pitch)
		s += " " + string(n.vol) + "\r\n"
		put(f, s)
	}
	close(f)
}

function csnote(n) {
	s = "i " + string(n.chan)
	s += " " + string(n.time*1.0/Clicks)
	s += " " + string(n.dur*1.0/Clicks)
	s += " " + string(n.pitch)
	s += " " + string(n.vol) + "\r\n"
	return(s)
}



function cab(chan,ctl,a,b,steps,dur)
{
  p = ''
  gap = (b - a) / (steps * 1.0)
  for(i=0; i<steps; i++) {
    n = controller(chan,ctl,a+(gap*i))
    n.length = dur
    p += n
  }
  return(p)
}


function cadd(col, name, ph) {
	nc = sizeof(col)
	col[nc] = ["name"=name,"phrase"=ph]
	return(col[nc])
}




function cntrl(chan,ctl,value) {
	c = controller(chan,ctl,value)
	return(c)
}


function cvptd(ph,c,v,p,t,d) {
	r = ph
	r.chan = c
	r.vol *= v
	r.pitch += p
	r.time *= t
	r.dur *= d
	return (r)
}

function cvt(ph,c,v,t) {
	r = ph
	r.chan = c
	r.vol *= v
	r.time += t
	return (r)
}

function setc(ph,c) {
	r = ph
	r.chan = c
	return (r)
}

function createpage (nm) {
	page_new()
	millisleep(200)
	if (nm=="") {
		nm = newpagename()
	}
	Pages[Root] = nm
}



# Write a phrase as a csound score using mapping
# map = [name=def, ]
function csout2(fn,hp,map,i) {
	f = open(fn,"w")
#	put(f,"size "+string(1+latest(p))+" 128\r\n")
	for (n in ph) {
		s = "i " + string(n.chan)
		s = " " + string(n.time)
		s += " " + string(n.dur)
		s += " " + string(n.pitch)
		s += " " + string(n.vol) + "\r\n"
		put(f, s)
	}
	close(f)
}



function drm4(num,v) {
	r = drm(num,0,4b,1,0)
	r.vol*=v
	return (r)
}



function funcA(p0,p1,p2) {
	r = ''
	for ( i=p0; i<p1; i+= p2 ) {
		p = '';
		p |= makenote(i-12);
		p |= makenote(i);
		p |= makenote(i+12);
		p.length = 1b/8;
		p.dur = 1b/8
		r += p;
	}
	return(r)
}



function getarrstr(arr,sep) {
	s = ""
	for (i in arr) {
		s += arr[i] + sep
	}
	return (s)
}


function grab(chan,bank,prog,pitchA,pitchB,pitchStep,notelen,gate)
{

 p = ''
 p += controller(chan,0,81)
 p += controller(chan,32,bank)
 p += controller(chan,32,0)
 p += progchange(prog,chan)

 for (pitch=pitchA; pitch<=pitchB; pitch+=pitchStep)
 {
  n = makenote(pitch,1b*notelen,127)
  n.length = n.dur * gate
  p += n
 }
 p.chan=chan
 return(p)
}


function greedy(chan,bankA,bankB,progA,progB,pitchA,pitchB,pitchStep,notelen,gate)
{
 p=''
 for(bank=bankA; bank<=bankB; bank++)
 {
   for(prog=progA; prog<=progB; prog++)
   {
    p += grab(chan,bank,prog,pitchA,pitchB,pitchStep,notelen,gate)
   }
   p.length += 16b
 } 
 return(p)
}



function grc()
{
	name = browsefiles("Key Collection (*.kc)","*.kc",0)
	if ( name == "" )
		return()
	return (rc(name))
}



function getbpm()
{
    value = 60 / (tempo() / 1000000.0)
    return (value)
}


# Grab contents of named tool or return empty phrase if problem.
function gtool(name) {
	r = ''
	if (defined(Ws)) {
		o = Ws[name]
		if (typeof(o)=="object") {
			if (defined(o.get)) {
				r = o.get()
			}
		}
	}
	return (r)
}




function gwc(col)
{
	name = browsefiles("Key Collection (*.kc)","*.kc",0)
	if ( name == "" )
		return()
	wc(name, col)
}



function hmmmwin()
{
	if (defined(Lastmouse)) 
		WW = Root.childunder(Lastmouse)	
	else
		WW = Root

	if (!defined(WW.hmmm)) 
		return ()

	s=getastr("Window command?","")
	WW.hmmm(s)
}


function mparts(col) {
  r = []
  for (i in col) {
	ph = col[i]["phrase"]
	print(col[i]["name"] + " " + phinfo(ph))
	phsplit = psplit(ph)
	for (ph in phsplit) {	
		r[sizeof(r)] = phsplit[ph]
	}
  }	
  return(r)
}


function nrpn(chan,ctlhi,ctllo,value) {

	value = integer(value)
	chcnt = 0xb0 | (chan-1)

	ph = midibytes(chcnt, 0x63, ctlhi, chcnt, 0x62, ctllo, chcnt, 0x06, value)

	return(ph)
}






function patset(words,o) {
	if (!defined(o.set)) return ()
	ph=o.get()

	n = sizeof(words)

	if (n==1) {
		who="Snarf" 
		s = string(o) + ".set(" + who + ", 1)"
		eval(s)
		
	} else if (n==2) {
		who = words[1]
		s = string(o) + ".set(" + who + ", 1)"
		eval(s)

	} else if (n==3) {
		ph = cg(words[1], words[2])
		o.set(ph,1)
	}

}

function patget(words,o)
{
	if (!defined(o.get)) return ()
	ph=o.get()

	who=words[1]
	if (who=="") { 
		who="Snarf" 
	}
	s = who + " = " + string(o) + ".get()" 
#	print(s)
	eval(s)
}



function pg(page) {
		for (i in Pages)
			if (Pages[i] == page) {
				page_switch(i)
			}
}


function phinfo(ph)
{
	if (typeof(ph)!="phrase")
		return(s)

	s =  "Ch:" + string(ph.chan)
	s += " V:" + string(ph.vol)
	s += " L:" + string(ph.length / Clicks)

	return(s)
}



# Shift a pattern by a certain amount
function phshift(ph,pstep,count) {
	r = ''
	phnew = ph
	for(i=0; i<count; i++) {
		r += phnew
		phnew.pitch += pstep
	}
	return(r)
}




# Split a phrase into its constituent parts.
function psplit(ph) {
	arr = []

	for ( n in ph) {
		p = n.pitch

		if ( typeof(arr[p]) != "phrase" ) {
			arr[p] = n
		} else {
			arr[p] |= n
		}
	}
	for (p in arr)
		arr[p].length = ph.length

	return(arr)
}


function rc (name) 
{
	if (nargs()==1) {
		if ( name == "" )
			name = browsefiles("Key Collection (*.kc)","*.kc",0)
	} else {
		name = browsefiles("Key Collection (*.kc)","*.kc",0)
	}	

	if ( name == "" ) return()

	if ( ! fileexists(name) )
		error("Can't open collection file: ",name)

	eval "#include \""+name+"\""
	return (Collection)
}



function setbpm(newbpm)
{
	if (newbpm < 10) {
		print("BPM too low " + string(newbpm))
		return ()
	}
	tempo(60.0 / newbpm * 1000000.0)
}


function setch(chan, bankmsb, banklsb, prog)
{
  p = ''
  p |= progchange(prog,chan)
  p |= controller(chan,0,bankmsb)
  p |= controller(chan,32,banklsb)
  p |= progchange(prog,chan)
  realtime(p)
}


function setchmsg(chan, bankmsb, banklsb, prog)
{
  p = ''
  p |= progchange(prog,chan)
  p |= controller(chan,0,bankmsb)
  p |= controller(chan,32,banklsb)
  p |= progchange(prog,chan)
  return(p)
}


function task_bb() {
	t = numquant(Now,1b)
      bar = 1
	while ( 1 ) {
		ph = A | B | C | D
		Snarf = ph
		
		realtime(ph,t)

		t += SeqDur

		sleeptill(t - (1b/8))
            bar++
	}
}




function wc (name, col) 
{
	f = open(name,"w")
	nc = sizeof(col)
	put(f,"Collection = [\n")
	sep = ""
	for ( n=0; n<nc; n++ ) {
		put(f,sep+"\t"+string(n)+"=\n")
		put(f,"\t\t[\"name\"=\""+col[n]["name"]+"\",\n")

		sfn = col[n]["fn"]
		if (sfn == "") {
			delete col[n]["fn"]
		} else {
			put(f,"\t\t\"fn\"=\"" + sfn + "\",\n")
		}

		put(f,"\t\t\"phrase\"=")
		put(f,col[n]["phrase"])
		put(f,"]")
		sep = ",\n"
	}
	put(f,"\n]\n");
	close(f)
}



function wset(ph,play) {
	if (defined(WW)) {
		if (defined(WW.set)) {
			WW.set(ph)
			if (nargs()>1) {
				if (defined(WW.stop)) {
					WW.stop()
				}
				if (defined(WW.bang)) {
					WW.bang()
				}
			}
		}
	}
}



function wplay(win,ph) {
	if (!defined(Ws)) {
		print("No windows defined.")
		return ("")
	}

	w = Ws[win]
	if (defined(w.set)) {
		w.set(ph)
		if (defined(w.stop)) {
			w.stop()
		}
		if (defined(w.bang)) {
			w.bang()
		}
	}
}






function walki(ph,jumps,pfrom) {
	r = ''
	jstep = 0
	for (j in jumps) {
		jstep += j.pitch - pfrom
		print(jstep)
		r += transpose(ph, jstep)
	}
	return(r)
}


function walki2(ph,jumps,pfrom) {
	r = ''
	jstep = 0
	for (j in jumps) {
		jstep = j.pitch - pfrom
		print(jstep)
		r += transpose(ph, jstep)
	}
	return(r)
}





function libInclude(name)
{
	print("Reading",name)
	eval("#include " + name)
}



# Return value bounded by min and max 
function libGuardMinMax(val, min,max) {
	if (val < min) {
		val = min 
	} else if (val > max) {
		val = max
	}
	return(val)
}



function libMidiToDur(val) {
	return((1b/16)*val)
}







#====================================================================
# Under construction








function mysort(arr, i) { 
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







function findfiles(dirs,exts) {
	flist = []
	for ( i in dirs ) {
		dir = dirs[i]
		if ( dir == "" )
			continue

		files = lsdir(dir)

		# remove all the files we're not interested in
		for ( fn in files ) {
			if ( fn=="." || fn==".." ) {
				delete files[fn]
				continue
			}
			parts = split(fn,".")
			suff = parts[1]
			for (ext in exts) {
				if (ext == suff) {

					# add
					sfn = dir + Dirseparator +  fn
					newarr = ["nm" = fn, "dir"=dir]
			
					flist[sizeof(flist)] = newarr
					continue
				}
			}				
		}
	}
	return(flist)
}


function libDocLib(fname) {
	path = Keypath
	dirs = split(path,Pathseparator)
	klf = open(fname,"w")
	exts = ["k"=1,"K"=1]
	save=Arraysort
	files = findfiles(dirs,exts)
	Arraysort=1
	for (f in files) {
		libDocFile(klf,files[f])
	}
	Arraysort=save
	close(klf)
}


function libDocFile(fout, finfo) {
	sout = ""
	fullpath = finfo["dir"] + "/" + finfo["nm"]
	f = open(fullpath)
	if ( f == "" ) {
		print("Unable to open ",fullpath)
		return()
	}

	put(fout, finfo["nm"] + "\r\n")

	n = 0
	arr = []
	while ( (ln=get(f)) != Eof ) {

		if (substr(ln,1,5) == "class" ) {
			words = split(ln," \t({")
			arr["  Class: " + words[1] + " \n"]=1
		} else if ( substr(ln,1,8) == "function" ) {
			words = split(ln," \t({")
			arr["\tF: " + words[1] + "\r\n"]=1
			n++			
		} else if (substr(ln,1,6) == "method" ) {
			words = split(ln," \t({")
			arr["\tM: " + words[1] + "\r\n"]=1
			n++
		}
		if (n==7) {
			#put(fout, sout + "\"\\n\"\r\n")
			n=0
		}
	}
	for (i in arr)
		put(fout, i)

	put(fout,"\r\n")
	close(f)
}



#libDocLib("d:/keykit6.4/liblocal/Overview.txt")

