class wriffnames {
method init {
	$.w = new window()
	$.inherit($.w)

	$.ph = new wphrase()
	$.riffs = [0='c e g']
	arr = [0="C Chord"]
	$.b1 = new kvalbutton(arr,$,"change")
	$.b2 = new kmenubutton("More","mkmenu_riffnames_more",$)
	$.randbutt = new kbutton("Rand",$,"randomize")
	$.t2 = new ktoggle("Loop",$,"setvar","loop")
	$.addchild($.ph)
	$.addchild($.b1)
	$.addchild($.b2)
	$.addchild($.randbutt)
	$.addchild($.t2)

	$.startquant = 1
	$.loopquant = 1
	$.loop = 0
	$.factor = 1.0
	$.ison = 0
	$.leng = 0
	$.nexttranspose = 0
	$.stoptids = []
	$.riffnames_listentokey = 0
	$.basekey = 'c'
	$.currentkey = 'c'
	$.neverfit = 0

	$.realset($.riffs[0])
        
        $.loopall = 0
        
        $.playlist = [0=0]
        $.oldFilter = ""
    }

method getPlaylist(){
    return($.playlist)
}
method resetPlaylist(){
    $.playlist = [0=0]
}

method getNamelist(){
    return($.b1.getvals())
}
method clear {
	$.riffs = []
	$.b1.set(0)
	$.b1.setvals([])
	$.b1.redraw()
        $.ph.set('',1)
        $.playlist = [0=0]
}
method change(n) {
	p = $.riffs[n]
	$.realset(p,1)
}
method addnew {
	vals = $.b1.getvals()
	nv = sizeof(vals)
	nm = "riff_"+string(nv)
	vals[nv] = nm
	$.b1.setvals(vals)
	$.b1.set(nv)
	$.b1.redraw()
}
method viewset(...) { $.ph.viewset(...) }
method wayout { $.ph.wayout() }
method redraw { $.w.redraw() ; methodbroadcast(); }

method delete {
			killtids($.stoptids)
			$.stoptids = []
			}

method setname(name, curr) {
    names = $.b1.getvals()
    if ( nargs() < 2 ){
        curr = $.b1.get()}
    if ( nargs() < 1 )
        nm = getastr("Enter name:", names[curr] )
    else
        nm = name
    p = $.get()
    names[curr] = nm
    $.b1.setvals(names)
    $.riffs[curr] = p
    
    $.b1.set(curr)
    $.b1.redraw()
}

method setvar (v,m,nm) {
			if ( nm == "on" ) {
				if ( v ) $.play(); else $.stop()
			}
			$.(nm) = v
			return(99)
		}
method strip { $.set(strip($.ph.get()),1) }
method bang {
			if ( $.ison )
				$.stop()
			else
				$.play()
			}
method setstartquant (v) { $.startquant = v }
method setlooping (v) {
	$.loop = v
	$.t2.set(1)
}
method setloopquant (v) { $.loopquant = v }
method setfactor(f) {
	$.factor = f
	$.set($.get(),1)
}
method get {
	curr = $.b1.get()
	return($.riffs[curr])
}
method set (p,doredraw) {
	# A "set" adds a new named phrase - this may be a mistake,
	# but it's superficially convenient
	$.addnew()
	if ( nargs() < 2 )
		doredraw = 0
	$.realset(p,doredraw)
}
method realset (p,doredraw) {
	curr = $.b1.get()
	$.riffs[curr] = p
	if ( $.factor != 1.0 )
		p = scatimes(p,$.factor)
	if ( $.riffnames_listentokey != 0 ) {
		tr = canonic(Key)-canonic($.basekey)
		p = transpose($.riffs[curr],tr)
	}
	$.ph.set(p,0)
	$.leng = p.length
	if ( $.neverfit == 0 )
		$.ph.fitall()
	if ( nargs() > 1 && doredraw )
		$.redraw()
}
method mousedown (m) {
				if ( $.ph.contains(m) )
					$.bang()
				else {
					mouseforward(m,"mousedown")
				}
			}
method dump {
	arr = [
		"riffs" = arraycopy($.riffs),
		"names" = arraycopy($.b1.getvals()),
		"curr" = $.b1.get(),
               "loop" = $.loop,
               "playlist" = $.playlist
	]
	return(arr)
}
method restore (state) {
	names = state["names"]
	$.b1.setvals(names)
	curr = state["curr"]
	$.b1.set(curr)
	$.riffs = state["riffs"]
	$.loop = state["loop"]
        $.realset($.riffs[curr])
        $.playlist = state["playlist"]
}
method setriffnames_listentokey (v,k) { $.riffnames_listentokey = v; $.basekey = k }
method setneverfit (v) { $.neverfit = v; }
method loadrec (space,addit) {
	p = lastbunch(Recorded,space)
	p = syncphr(p)
	p = trimPhraseFront(p)
	if ( addit )
		$.addnew()
	$.realset(p,1)
}
method snarf { Snarf = $.ph.get() }

method loadsnarf(addit, phr) {
    if ( nargs() < 2){
        p = Snarf
    }
    else{
        p = phr
    }
    
    p.flags = 0
    p = syncphr(p)
    p = trimPhraseFront(p)
    if ( addit )
        $.addnew()
    p = resetLength(p)
    $.realset(p,1)
}
method loadfile(addit) {
	ph = browsephrase()
	if ( sizeof(ph) > 0 ) {
		if ( addit )
			$.addnew()
		$.realset(ph,1)
	}
}

method transpose(v) {
	$.nexttranspose += integer(v)
}
method play(stime) {
	$.ison = 1
	curr = $.b1.get()
	qnt = $.startquant
	if ( nargs() < 1 ) {
		if ( qnt == 1 )
			stime = Now
		else
			stime = nextquant(Now,qnt)
	}
	if ( $.nexttranspose != 0 ) {
		$.ph.transpose($.nexttranspose)
		$.nexttranspose = 0
		$.ph.fitall()
		$.ph.redraw()
	}
	if ( $.riffnames_listentokey != 0 && $.currentkey != Key ) {
		$.currentkey = Key
		$.realset($.riffs[curr],1)	# This will pay attention to Key
		tr = canonic(Key)-canonic($.basekey)
		p = transpose($.riffs[curr],tr)
		$.ph.set(p,0)
		$.leng = p.length
	}
	tid = $.ph.play(stime,qnt)
	$.stoptids[tid] = 1

	$.looplng = numquant($.leng, $.loopquant)
	if ( $.looplng == 0 )
		$.looplng = $.loopquant
	tid = task $.wriffnameschk(stime+$.looplng)
	$.stoptids[tid] = 1
}

method stop {
	killtids($.stoptids)
	$.stoptids = []
        $.setoff()
        if ( $.loopall == 1 ) {
            $.loop = 1
            $.loopall = 0
        }
        
}

method seton {
	if ( ! $.ison ) {
		$.play()
	}
}

method setoff {
	$.ison = 0
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	dx = ($.xmax()-$.xmin()) / 4
	y0 = $.ymin()+2
	y0a = $.ymin() + $.textheight() + 4
	x0 = $.xmin() + 2
	x1 = $.xmax() - 2
	y1 = $.ymax() - 2
	$.b1.resize(xy(x0,y0,x0+1*dx-1,y0a))
	$.randbutt.resize(xy(x0+1*dx+1,y0,x0+2*dx-1,y0a))
	$.b2.resize(xy(x0+2*dx+1,y0,x0+3*dx-1,y0a))
	$.t2.resize(xy(x0+3*dx+1,y0,x1,y0a))

	$.ph.resize(xy(x0,y0a+2,x1,y1))
}
method wriffnameschk(tm) {
	sleeptill(tm-milliclicks(50))
	if ( $.ison ) {
		if ( $.loop!=0 && $.looplng>0 ) {
			$.play(tm)
		}
		else {
			$.setoff()
		}
	}
}
method randomize {
	r = rand(sizeof($.riffs))
	$.b1.set(r)
	$.b1.redraw()
	$.realset($.riffs[r],1)
}
method fillfrom(typ,dt) {
	if ( typ == 0 ) {
		f = browsefiles("MIDI files (*.mid)","*.mid",1)
		if ( ! fileexists(f) ) {
			print("File "+f+" doesn't exist")
			return()
		}
		ph = readmf(f)
	} else if ( typ == 1 ) {
		ph = Snarf
	}
	ph = onlynotes(ph)
	t1 = 0
	t2 = dt
	n = 0
	while ( ph%1.time >= dt ) {
		ph.time -= dt
	}
	$.clear()
	print("Size is now ",sizeof($.riffs))
	while ( n++ < 8096 ) {
		p = cut(ph,CUT_TIME,t1,t2)
		if ( sizeof(p) == 0 )
			break
		p.time -= t1
		p.length = dt
		$.addnew()
		$.realset(p,1)
	print("after addnew Size is now ",sizeof($.riffs))
		t1 += dt
		t2 += dt
	}
    }

method fillfromDir() {
    filter = getastr("filter: ", $.oldFilter )
    $.oldFilter = filter
    fns = getFileNames(filter)
    for ( n in fns ) {
        $.addnew()
        ph = readmf(fns[n])
        $.realset(ph,1)
        name = substr(fns[n],1,sizeof(fns[n])-4)
        $.setname(name)
    }
}

method monoall() {
	curr = $.b1.get()
	for ( n in $.riffs ) {
		p = $.riffs[n]
		$.riffs[n] = mono(p)
	}
	p = $.riffs[curr]
	$.realset(p,1)
    }

method playall() {
    $.stop()
    tid = task $.playallaux(0)
    $.stoptids[tid]=1
}

method playallcont() {
    $.stop()
    tid = task $.playallaux($.b1.get())
    $.stoptids[tid]=1
}

method playone(n){
    $.b1.set(n)
    $.b1.redraw()
    $.realset($.riffs[n],1)
    $.play()
    sleeptill(Now+$.riffs[n].length+2b)
}


method playallaux(st) {
    vals = $.b1.getvals()
    nv = sizeof(vals)
    if ( $.loop == 1 ) {
        $.loop = 0
        $.loopall = 1
    }
    else
        $.loopall = 0
    
    for ( n=st; n<nv; n++ ) {
        $.playone(n)
    }    
    if ( $.loopall == 0 )
        $.stop()
    else {
        $.loop = 1
        $.playallaux(0)
    }
    
}

method save() {
    fname = browsefiles("Keykit File (*.k)","*.k",0)
    fw = open(fname,"w")
    state = $.dump()
    put(fw,string(state))
    close(fw)
    print("Riffs saved in "+fname)
}

method load(fname) {
    fname = browsefiles("Keykit File (*.k)","*.k",0)
    if ( fileisreadable(fname) ) {
        fr = open(fname,"r")
        statestring = get(fr)
        close(fr)
        #print(statestring)
        eval "TmpState = " + statestring
        state = TmpState
        #print(typeof(state))
        $.restore(state)
    }
    else 
        print("No such file!")
}

method advanceriff(d) {
    curr = $.b1.get()
    len = sizeof($.riffs)
    nw = curr + d
    if ( nw < 0 ) 
        nw = nw + len
    if ( nw >= len ) 
        nw = nw - len
    $.b1.set(nw)
    $.b1.redraw()
    $.realset($.riffs[nw],1)
}

method delriff() {
    if ( sizeof($.riffs) == 1 ) {
        print("Cannot delete the last riff!")
        return()
    }
    curr = $.b1.get()
    $.advanceriff(-1)

    vals = $.b1.getvals()
    len = sizeof(vals)
    
    riffs = $.riffs
    
    newvals = []
    newriffs = []
    for ( n in vals ) {
        if ( n < curr ) {
            newvals[n] = vals[n]
            newriffs[n] = riffs[n]
        }
        if ( n > curr ) {
            newvals[n-1] = vals[n]
            newriffs[n-1] = riffs[n]
        } }
    $.b1.setvals(newvals)
    $.riffs = newriffs
}
method playlistTask(n) {
    len = sizeof($.playlist)
    for ( i=n; i<len; i++)
        $.playone($.playlist[i])
}

method playlistplay(n){
    $.stop()
    tid = task $.playlistTask(n)
    $.stoptids[tid]=1
}    

method playlistremitem(n){
    newlist = []
    nv = sizeof($.playlist)
    if ( nv==1 )
        newlist = [0=0]
    else {
        for ( i=0; i<nv; i++){
            if ( i<n )
                newlist[i] = $.playlist[i]
            if ( i>n )
                newlist[i-1] = $.playlist[i]
        }
    }
    $.playlist = newlist
}


method playlistadditem(n,newone){
    newlist = []
    nv = sizeof($.playlist)
    if ( nargs() < 2 ){
        newone = $.playlist[n]}
    
    #print("nv = "+string(nv))
    for ( i=0; i<=nv; i++){
        if ( i<=n )
            newlist[i] = $.playlist[i]
        if ( i==n+1 )
            newlist[i] = newone
        if ( i>n+1 )
            newlist[i] = $.playlist[i-1]
    }
    $.playlist = newlist
}

method playlistaddNitems(ind,n){
    for ( i=0; i<n; i++ ){
        $.playlistadditem(ind)
    }
}

method playlistaddAllitems(ind){
    vals = $.getNamelist()
    nv = sizeof(vals)
    cnt = 0
    for ( i=0; i<nv; i++){
        nm = vals[i]
        nmstrt = substr( nm, 1, 5 )
        if ( nmstrt != "riff_" ){
            $.playlistadditem( ind + cnt, i )
            cnt++
        }
    }
    $.playlistremitem( ind )
}


method playlistsnarf(){
    ph = ''
    sp = ''
    sp.length = 200
    nv = sizeof($.playlist)
    for ( i=0; i<nv; i++) {
        newph = $.riffs[$.playlist[i]]
        ph += sp + newph }
    Snarf = ph
}

method setplaylistitem(m,n){
    $.playlist[m] = n
}

method fixLength() {
	p = $.get()
        p = resetLength(p)
        curr = $.b1.get()
        $.riffs[curr] = p
    }

method loadSnarfPieces(){
    phrlst = phraseToPhraseList(Snarf)
    len = sizeof(phrlst)
    for ( i = 0; i < len; i++){
        $.loadsnarf( 1, phrlst[i])
    }
}

method prefixNames(){
    vals = $.getNamelist()
    n = sizeof( vals )
    for ( i=0; i<n; i++ ){
        nm = vals[ i ]
        nmstrt = substr(nm, 1, 5)
        if ( nmstrt != "riff_" ){
            $.setname( "riff_" + nm, i )}
    }
}

method switchplaylistitems( x, y ){
    oldx = $.playlist[x]
    $.playlist[x] = $.playlist[y]
    $.playlist[y] = oldx
}

#copy + melds to chosen wriffnames
method saveMelds(){
    print("Point to the melds you want to copy.")
    mlds = wselect()
    if ( mlds.classof() != "wmeld" ){
        print( "Copy aborted: not a wmeld tool." )
        return() }
    for ( i=1; i<=10; i++ ){
        if ( mlds.getSkipList(i) == 0 ){
            phr =  mlds.getMeld(i)
            $.loadsnarf( 1, phr ) } }
}

}



function mkmenu_riffnames_listentokey(o,po) {
	o.menucmd("On",po,"setriffnames_listentokey",1,'c')
	o.menucmd("Off",po,"setriffnames_listentokey",0,'c')
}

function mkmenu_riffnamesqvals(o,po,meth) {
	o.menucmd("None",po,meth,1)
	o.menucmd("1b",po,meth,1b)
	o.menucmd("2b",po,meth,2b)
	o.menucmd("4b",po,meth,4b)
	o.menucmd("8b",po,meth,8b)
}
function mkmenu_riffnames_add(o,po,addit) {
	o.menucmd("From Rec (1b space)",po,"loadrec",1b,addit)
	o.menucmd("From Rec (4b space)",po,"loadrec",4b,addit)
	o.menucmd("From Snarf",po,"loadsnarf",addit)
	o.menucmd("Multiple From Snarf",po,"loadSnarfPieces")
	o.menucmd("From File",po,"loadfile",addit)
}
function mkmenu_riffnames_fill(o,po) {
	o.menucmd("From File (2b)",po,"fillfrom",0,2b)
        o.menucmd("From File (4b)",po,"fillfrom",0,4b)
        o.menucmd("From Directory",po,"fillfromDir")
	o.menucmd("From Snarf (2b)",po,"fillfrom",1,2b)
        o.menucmd("From Snarf (4b)",po,"fillfrom",1,4b)
        o.menucmd("From Melds     ",po,"saveMelds")
    }

function mkmenu_playall(o,po) {
        o.menucmd("from start",po,"playall")
        o.menucmd("from current",po,"playallcont")
}

function mkmenu_riffnamesPlaylist(o,po){
    o.submenu("List    ->","mkmenu_riffnamesPlayListItems",po)
    o.menucmd("Play All",po,"playlistplay",0)
    o.menucmd("Snarf List",po,"playlistsnarf")
}

function mkmenu_riffnamesPlayListItems(o,po){
    vals = po.getPlaylist()
    nv = sizeof(vals)
    #print("nv = "+string(nv))
    # if ( nv == 0 ){
    #     po.resetPlaylist()
    #     vals = po.getPlaylist()
    #     nv = sizeof(vals)
    # }
    nms = po.getNamelist()
    for ( i=0; i<nv; i++)
        o.submenu(string(i) + ": " + nms[vals[i]] + " ->","mkmenu_riffnamesList",po,i)
}

function mkmenu_playlistSwitch(o,po,itm){
    print("playlistSwitch called...")
    vals = po.getPlaylist()
    nv = sizeof(vals)
    nms = po.getNamelist()
    for ( i=0; i<nv; i++){
        nm = string(i) + ": " + nms[vals[i]]
        o.menucmd( nm, po, "switchplaylistitems", itm, i )
    }}



function mkmenu_riffnamesList(o,po,itm){
    vals = po.getNamelist()
    nv = sizeof(vals)
    for ( i=0; i<nv; i++){
        nm = string(i) + ": " + vals[i]
        nmstrt = substr( nm, 1, 5 )
        if ( nmstrt != "riff_" ){
            o.menucmd( nm, po, "setplaylistitem", itm, i )
        }}
    o.menucmd("Play",po,"playlistplay",itm)
    o.menucmd("Add",po,"playlistadditem",itm)
    o.menucmd("Add 5",po,"playlistaddNitems",itm,5)
    o.menucmd("Add All",po,"playlistaddAllitems",itm)
    o.submenu("Switch with   ->","mkmenu_playlistSwitch",po,itm)
    o.menucmd("Remove",po,"playlistremitem",itm)
    o.menucmd("Remove All",po,"resetPlaylist")
}
   

function mkmenu_riffnames_more(o,po) {
        o.menucmd("Save Riffs",po,"save")
        o.menucmd("Load Riffs",po,"load")
	o.submenu("Navigate      ->","mkmenu_riffnames_navigate",po)
	o.submenu("Add One       ->","mkmenu_riffnames_add",po,1)
	o.submenu("Play All      ->","mkmenu_playall",po)
        o.menucmd("Stop!",po,"stop")
	o.menucmd("Snarf",po,"snarf")
	o.submenu("Set Current   ->","mkmenu_riffnames_add",po,0)
	o.submenu("Fill From     ->","mkmenu_riffnames_fill",po)
	o.menucmd("Set Name",po,"setname")
        o.menucmd("Clear",po,"clear")
        o.submenu("Playlist      ->","mkmenu_riffnamesPlaylist",po)
        o.menucmd("Fix Length",po,"fixLength")
	o.submenu("Loop Quant    ->","mkmenu_riffnamesqvals",po,"setloopquant")
	o.submenu("Retrigger     ->","mkmenu_riffnames2",po)
	o.submenu("Listen to Key ->","mkmenu_riffnames_listentokey",po)
	o.submenu("Start Quant   ->","mkmenu_riffnamesqvals",po,"setstartquant")
	o.menucmd("Mono All",po,"monoall")
        o.menucmd("Strip",po,"strip")
        o.menucmd("Prefix Names",po,"prefixNames")
        o.menucmd("Delete Riff!",po,"delriff")
}

function getFileNames(strexp) {
    f = open("ls "+strexp,"r","pipe")
    fns = []
    for ( n=1; (v=get(f)) != Eof; n++ )
        fns[n] = v
    close(f)
    return(fns)
}

function mkmenu_riffnames_navigate(o,po) {
    o.menucmd("Previous",po,"advanceriff",-1)
    o.menucmd("Next",po,"advanceriff",1)
}

function getDirNames(strexp) {
    if ( nargs() < 1 )
        strexp = "*"

    f = open("ls -d "+ strexp + "*/","r","pipe")
    fns = []
    for ( n=1; (v=get(f)) != Eof; n++ )
        fns[n] = v
    close(f)
    return(fns)
}

function resetLength(phr) {
    #print("phrase length was ",phr.length)
    strt = (phr%1).time
    endt = strt
    for ( nt in phr ) {
        newt = nt.time + nt.dur
        if ( newt > endt ) 
            endt = newt
    }
    newphr = phr
    newphr.length = endt - strt
    #print("phrase length is now ",newphr.length)
    return(newphr)
}

function trimPhraseFront(phr){
    p = phr
    if ( (p%1).time > (Met.length/2) ) {
		p.time -= Met.length
		p.length -= Met.length
            }
    return(p)
}

function phraseToPhraseList(phr){
    phrlst = []
    indx = 0
    phr.flags = 0
    
    offset = (phr%1).time
    phr.time -= offset

    del = 100
    end = latest(phr) + 4*del
    previous = -1
    #intm = 0
    for ( t = del; t <= end; t += del ){
        if ( closeNoteQ( phr, t, 10*del ) || t + del > end ){
            #if ( intm == 1 ){
            newphr = phr{ ??.time > previous && ??.time < t}
            if ( newphr != ''){
                phrlst[indx++] = newphr  }
            previous = t
                #intm = 0
                #}
        } 
        # else {
        #     if ( intm == 0 ){
        #         intm = 1
        #     }
        #}
    }
    return( phrlst )
}

function closeNoteQ(phr, tm, del){
    phrstart = phr{ ??.time < tm }
    end = latest( phrstart )
    return( end + del < tm )
}


