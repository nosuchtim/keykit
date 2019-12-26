#-*-keykit-*-

class wmeld {
method init {
    $.w = new window()
    $.inherit($.w)
                    # Add a slider widget as a child
#    $.spslider = new khslider(0,20,10,$,"spchange")
#    $.addchild($.spslider)
    
    $.scaleInc = 1
#    print("scaleInc = ",string(scaleInc))
    $.rightChan = 1
    
    $.phrasewinL = new wphrase()
    $.addchild($.phrasewinL)
    $.phrasewinR = new wphrase()
    $.addchild($.phrasewinR)
    $.phrasewinM = new wphrase()
    $.addchild($.phrasewinM)
#    print(string($.phrasewin))
    
    $.meldbutt = new kbutton("Meld",$,"meld")
    $.addchild($.meldbutt)
    $.tweakbutt = new kbutton("Tweak",$,"tweak")
    $.addchild($.tweakbutt)
    $.recyclebutt = new kbutton("Recycle",$,"recycle")
    $.addchild($.recyclebutt)
    $.switchbutt = new kbutton("Switch",$,"switch")
    $.addchild($.switchbutt)
    $.shearbutt = new kbutton("Shear",$,"shear")
    $.addchild($.shearbutt)
    $.combinebutt = new kbutton("Combine",$,"combine")
    $.addchild($.combinebutt)
    $.skipbutt = new kbutton("Skip",$,"skip")
    $.addchild($.skipbutt)
    $.scaleIncbutt = new kvalbutton([1="1",2="2",3="3"],$,"setScaleInc")
    $.addchild($.scaleIncbutt)

    $.setLbutt = new kbutton("SetLeft",$,"setleft")
    $.addchild($.setLbutt)
    $.setRbutt = new kbutton("SetRight",$,"setright")
    $.addchild($.setRbutt)
    
    $.upbutt = new kbutton("Up",$,"transposeRight",1)
    $.downbutt = new kbutton("Down",$,"transposeRight",-1)
    $.addchild($.upbutt)
    $.addchild($.downbutt)

    $.exportbutt = new kbutton("Snarf",$,"export")
    $.addchild($.exportbutt)
    
      $.meldList = new kvalbutton([0="alts",1="1",2="2",3="3",4="4",5="5",6="6",7="7",8="8",9="9",10="10",11="Play All",12="Play All Repeat",13="All Down",14="All Up"],$,"selectmeld",REDRAW)
    $.addchild($.meldList)
    
    $.reflectbutt = new kvalbutton([0="unreflected",1="invert",2="all"],$,"setReflectStr",REDRAW)
    $.tweakOptsButt = new kvalbutton([0="lmtd",1="unlmtd",2="dual"],$,"setTweakOpts",REDRAW)
    $.addchild($.reflectbutt)
    $.addchild($.tweakOptsButt)
    $.reflectStr = "nil"
    $.tweakOpts = "lmtd"
    
    $.stretchbutt = new kvalbutton([0="1/2",
                                    1="1/3",
                                    2="1/4",
                                    3="1/5",
                                    6="1/8"],$,
                                   "setStretchStr",REDRAW)
    $.addchild($.stretchbutt)
    $.stretchStr = "1.5"
    
    $.numsubstrbutt = new kvalbutton([0="0",
                                      1="1",
                                      2="2",
                                      3="3",
                                      4="4"],$,
                                     "setNumSubStrStr",REDRAW)
    $.addchild($.numsubstrbutt)
    $.numSubStrStr = "0"
    
    # $.serialOpButt = new kvalbutton([0="Flip",
    #                                  1="Retro"],$,
    #                                 "serialOp",REDRAW)
    
    $.serialOpButt = new kmenubutton("Ops","mkmenu_Ops",$)
    
    $.addchild($.serialOpButt)
    
    $.rchanbutt = new kvalbutton([1="1",2="2",3="3",4="4",5="5",6="6",7="7",8="8",9="9",10="10",11="11",12="12",13="13",14="14",15="15",16="16"],$,"setrchan",REDRAW)
    $.addchild($.rchanbutt)
    $.rchanbutt.invoke(1)
    
    $.melds = [0='']

    $.ison = 0
    $.stoptids = []
    $.loop = 0
    
    $.skipList = []
    $.initSkipList()
    
    #$.parent = 0
}

method setRChanLabels( chLbl ){
    oldLabels = $.rchanbutt.getvals()
    newLabels = oldLabels
    for ( i in chLbl ){
        newLabels[i] = chLbl[i] }
    $.rchanbutt.setvals( newLabels ) }

method meldItemName(n){
    res = string(n)
    if ( $.skipList[n] == 2){
        res += "-"}
    else if ( $.skipList[n] == 0 ){
        res += "+"}
    else if ( $.skipList[n] == 1 ){
        res += " "}
    return(res)
}

method updateMeldList(){
    vals = $.meldList.getvals()
    cur = $.meldList.get()
    for ( i=1; i<=10; i++ ){
        # print( "i: " +  vals[i] )
        # print( "new: " + $.meldItemName(i))
        vals[i] = $.meldItemName(i)}
    $.meldList.setvals(vals)
    $.meldList.set(cur)
    $.meldList.redraw()
}


method initSkipList(){
    $.skipList = [1=1,2=1,3=1,4=1,5=1,6=1,7=1,8=1,9=1,10=1]
    $.updateMeldList()
}


method setScaleInc(i){
    $.scaleInc = i
}



method transposeRight(n) {
    phr = $.getphr("r")
    phr.pitch += n
    $.setphr("r",phr)
}

method setrchan(n) {
    if ( nargs() < 1 )
        n = $.rchanbutt.get()
    rchan = baseChan($.getphr("r")%1.chan,$.scaleInc)
    diff = n - rchan
    #$.rchan = n
    phr = $.getphr("r")
    res = ''
    top = rchan + $.scaleInc
    for ( c = rchan; c < top; c++){
        curphr = phr{ ??.chan == c }
        newch = c + diff
        curphr.chan = newch
        res |= curphr
    }
    $.setphr("r",res)
    $.rightChan = n
}

method serialOp(n) {
    cmd = ""
    arg = ""
    if ( n == 0 ) 
        cmd = "flip2"
    else if ( n == 1 ) 
        cmd = "reverse"
    else if ( n == 2 ){
        cmd = "cmd_timescale"
        arg = 1.024
    }
    else if ( n == 3){
        cmd = "cmd_timescale"
        arg = 0.9765625
    }
    
    #print("cmd = ", cmd)
    cmd = efunction(cmd)
    if ( n <= 1 )
        $.setphr("r",cmd($.getphr("r"), $.scaleInc))
    else 
        $.setphr("r",cmd($.getphr("r"), arg))
}




method setStretchStr(n) {
    $.stretchStr = string(1+1.0/(n+2))
}

method setNumSubStrStr(n) {
    $.numSubStrStr = string(n)
}

method setReflectStr(n) {
    if ( n==0 ) 
        $.reflectStr = "nil"
    else if ( n==1 )
        $.reflectStr = "#'reflectPhraseInv"
    else if ( n==2 )
        $.reflectStr = "#'reflectPhrase"
}
method setTweakOpts(n) {
    if ( n==0 ) 
        $.tweakOpts = "lmtd"
    else if ( n==1 )
        $.tweakOpts = "unlmtd"
    else if ( n==2)
        $.tweakOpts = "dual"
}

method selectmeld(n) {
    if ( n == 11 ){
        tid = task $.playAll()
        $.stoptids[tid] = 1
        return()
    }
    if ( n == 12 ){
        tid = task $.playAllRepeat()
        $.stoptids[tid] = 1
        return()        
    }
    if ( n == 13 ){
       for (i=1;i<=10;i+=1){
       	   $.skipList[i] = min( 2, $.skipList[i] + 1 ) }
       $.updateMeldList()
       return() }
    if ( n == 14 ){
       for (i=1;i<=10;i+=1){
       	   $.skipList[i] = max( 0, $.skipList[i] - 1 ) }
       $.updateMeldList()
       return() }    
	   
    res = $.melds[n]
    if ( res == "" ){
        print("Empty phrase.")
    } else {
        $.setphr("m",res)
    }    
}

method playAllRepeat(){
        $.playAll()
        $.playAllRepeat()
}


method playAll(){
    for ( i = 1; i <= 10; i++ ){
        if ( $.melds[i] != "" && $.skipList[i] == 1 ){
            $.meldList.invoke(i)
            $.play("m")
            sleeptill(Now + $.melds[i].length + 5b)
        }
    }
}


method getphr(w) {
    win = $.whichwin(w)
    return(win.get())
}

method setleft() {
    $.load("l")
}

method setright() {
    $.load("r")
}

method export() {
    Snarf = $.phrasewinM.get()
}

method play(w) {
    $.ison = 1
    win = $.whichwin(w)
    tid = win.play()
    $.stoptids[tid] = 1	
    
    tm = win.get().length
    #print("length = ",tm)
    tid = task $.playchk(tm,w)
    $.stoptids[tid] = 1
}

method mousedown (m) {
    if ( $.phrasewinL.contains(m) )
        $.bang("l")
    else if ( $.phrasewinR.contains(m) )
        $.bang("r")
    else if ( $.phrasewinM.contains(m) )
        $.bang("m")
    else {
        mouseforward(m,"mousedown")
    }
			}

method bang(w) {
			if ( $.ison )
				$.stop()
			else
				$.play(w)
                    }

method stop {
	killtids($.stoptids)
	$.stoptids = []
        $.setoff()
    }

method seton(w) {
	if ( ! $.ison ) {
		$.play(w)
	}
}
method setoff {
    $.ison = 0
    #print("off")
    }

method playchk(tm,w) {
	sleeptill(Now+tm-milliclicks(50))
	if ( $.ison ) {
		if ( $.loop!=0 ) {
			$.play(w)
		}
		else {
			$.setoff()
		}
	}
}
method redraw {
    $.w.redraw()
    methodbroadcast()
}

method resize(sz) {
    if ( nargs() > 0 )
        $.w.resize(sz)
    x0 = $.xmin() + 2
    y0 = $.ymin() + 1
    x1 = $.xmax() - 1
    y1 = $.ymax() - 2
    dy = y1 - y0
    dx = x1 - x0
    
    y01 = y0 + .45*dy
    y02 = y01 +.05*dy
    y03 = y02 +.05*dy
    
    x01 = x0 + .5*dx
    xnd = x1 - .1*dx


    $.phrasewinL.resize(xy(x0,y0,x01,y01))
    $.phrasewinR.resize(xy(x01+1,y0,x1,y01))
    $.phrasewinM.resize(xy(x0,y03+1,x1,y1))
    
    $.meldbutt.resize(xy(x0,y02+1,x0+.1*dx,y03-1))
    $.tweakbutt.resize(xy(x0+.4*dx+1,y02+1,x0+.5*dx,y03-1))
    $.shearbutt.resize(xy(x0+.3*dx+1,y02+1,x0+.4*dx,y03-1))
    $.combinebutt.resize(xy(x0+.1*dx+1,y01+1,x0+.2*dx,y02-1))
    $.skipbutt.resize(xy(x0+.2*dx+1,y02+1,x0+.3*dx,y03-1))
    $.scaleIncbutt.resize(xy(x0+.2*dx+1,y01+1,x0+.3*dx,y02-1))
    $.recyclebutt.resize(xy(x0+.4*dx+1,y01+1,x0+.5*dx,y02-1))
    $.switchbutt.resize(xy(x0+.3*dx+1,y01+1,x0+.4*dx,y02-1))
    $.exportbutt.resize(xy(xnd,y02+1,x1,y03-1))
    $.setLbutt.resize(xy(x0,y01+1,x0+.1*dx,y02-1))
    $.setRbutt.resize(xy(xnd,y01+1,x1,y02-1))
    
    $.reflectbutt.resize(xy(x01+1,y01+1,x01+.1*dx,y02-1))
    $.tweakOptsButt.resize(xy(x01+1,y02+1,x01+.1*dx,y03-1))
    $.stretchbutt.resize(xy(x01+.1*dx+1,y01+1,x01+.2*dx,y02-1))
    $.numsubstrbutt.resize(xy(x01+.1*dx+1,y02+1,x01+.2*dx,y03-1))
    $.upbutt.resize(xy(x01+.2*dx+1,y01+1,x01+.3*dx,y02-1))
    $.downbutt.resize(xy(x01+.2*dx+1,y02+1,x01+.3*dx,y03-1))
    $.serialOpButt.resize(xy(x01+.3*dx+1,y01+1,x01+.4*dx,y02-1))
    $.rchanbutt.resize(xy(x01+.3*dx+1,y02+1,x01+.4*dx,y03-1))
    
    $.meldList.resize(xy(x0+.1*dx+1,y02+1,x0+.2*dx,y03-1))
}

method whichwin(w) {
    win = $.phrasewinL
    if ( w == "r" )
        win = $.phrasewinR
    else if ( w == "m" )
        win = $.phrasewinM
    return(win)
    }

method setphr(w,ph) {
    win = $.whichwin(w)
    win.set(ph)
    win.fitall()
    win.redraw()
}


method load(w, phr) {
    if ( nargs() < 2 )
        phr = Snarf
    del = phr%1.time - 96
    newphr = ''
    for ( nt in phr ) {
        newnt = nt
        newnt.time -= del
        newphr |= newnt
    }
    newphr.flags = 0
    $.setphr(w,newphr)
#    print(string($.get()))
    if ( w == "r" ){
#        phr.chan = $.rchanbutt.get()
        $.setrchan()
    }
}

method sendcmd(cmd){
    shcmd = "echo \"" + cmd + "\" > /home/dabrowsa/lisp/fifo/in"
    shellCmdStr(shcmd)
    getcmd = "cat < /home/dabrowsa/lisp/fifo/out"
    res = shellCmdArray(getcmd)
    return(res)
}

method meld() {
    pbase = $.phrasewinL.get()
    padd  = $.phrasewinR.get()
    #padd.chan = $.rchan
    pbasel = phraseToLisp(pbase,$.scaleInc)
    paddl  = phraseToLisp(padd,$.scaleInc)
    cmd = "(callFCP '" + pbasel + " '" + paddl + " :reflect " + $.reflectStr + " :stretch " + $.stretchStr + " :numsubstr " + $.numSubStrStr + " :lenbase " + string(pbase.length) + ")"
    ress = $.sendcmd(cmd)
    
    $.initSkipList()
    $.fillMeldList(ress)
}

method dump() { 
    meldcur = $.meldList.get()
    if ( meldcur < 1 || meldcur > 10 ){
        meldcur = 1}
    return(["phrL"=$.phrasewinL.get(),
                        "phrR"=$.phrasewinR.get(),
                        "melds"=$.melds,
                        "meldcur"=meldcur,
                        "rchan"=$.rchanbutt.get(),
                        "scaleInc"=$.scaleInc,
                        "rightChan"=$.rightChan,
                        "skipList" = $.skipList
                        ])
            }

method restore(state) { 
    $.setphr("l",state["phrL"]) 
    $.setphr("r",state["phrR"])
    $.melds = state["melds"]
    $.meldList.invoke(state["meldcur"])
    $.setphr("m",$.melds[state["meldcur"]])
    $.rchanbutt.invoke(state["rchan"])
    $.scaleIncbutt.invoke(state["scaleInc"])
    $.rightChan = state["rightChan"]
    $.skipList = state["skipList"]
    #$.setRChanLabels( $.getParent().chToLbl() )
    $.updateMeldList()
}

method tweak() {
    fname = ""
    keyarg = ""
    if ( $.tweakOpts == "lmtd" ){
        fname = "callTweakSingle"
        keyarg = ":limited t"
    }
    else if ( $.tweakOpts == "unlmtd" ){
        fname = "callTweakSingle"
        keyarg = ":limited nil"
    }
    else 
        fname = "callTweakDual"

    pbase = $.phrasewinL.get()
    padd  = $.phrasewinR.get()
    #padd.chan = $.rchan
    pbasel = phraseToLisp(pbase,$.scaleInc)
    paddl  = phraseToLisp(padd,$.scaleInc)
    cmd = "(" + fname + " '" + pbasel + " '" + paddl + " " + keyarg + ")"
    ress = $.sendcmd(cmd)
    
    $.fillMeldList(ress,1)
}

method fillMeldList(lst, unoverlap){
    if ( nargs() < 2 ){
        unoverlap = 0
    }
    
    phrlst = []
    for ( i in lst ) {
        p = "'" + lst[i] + "'"
        #print("phrase = ",i)
        
        if ( unoverlap ){
            phrlst[i] = unpreempt(phrase(p))
        } else {
            phrlst[i] = phrase(p)
        } 
    }
    $.melds = phrlst
    $.melds[0] = ''
    $.setphr("m",phrlst[1])
    $.meldList.invoke(1)
}

method recycle(){
    mphr = $.getphr("m")
    rchan = $.rchanbutt.get()
    newrphr = ''
    for ( i=0; i<$.scaleInc; i++ ){
        newrphr |= mphr{ ??.chan == rchan + i }
    }
    newlphr = mphr - newrphr
    $.setphr("r",newrphr)
    $.setphr("l",newlphr)
}

method switch(){
    rphr = $.getphr("r")
    lphr = $.getphr("l")
    $.setphr("r",lphr)
    $.setphr("l",rphr)
    $.rchanbutt.set(baseChan(lphr%1.chan, $.scaleInc))
    $.redraw()
}
method shear() {
    pbase = $.phrasewinL.get()
    padd  = $.phrasewinR.get()
    #padd.chan = $.rchan
    pbasel = phraseToLisp(pbase,$.scaleInc)
    paddl  = phraseToLisp(padd,$.scaleInc)
    cmd = "(callShear '" + pbasel + " '" + paddl + ")"
    ress = $.sendcmd(cmd)
    
    $.fillMeldList(ress,1)
}

method combine(){
    $.setphr("m",$.getphr("l") | $.getphr("r"))
}

#toggles skipping
method skip(){
    cur = $.meldList.get()
    $.skipList[cur] = ( 1 + $.skipList[cur] ) % 3
    $.updateMeldList()
}

method getSkipList(i){
    return( $.skipList[i] ) }

method getMeld(i){
    return( $.melds[i] ) }

# method setParent(p) {
#     $.parent = p }
# method getParent() {
#     return( $.parent ) }
}

function baseChan(ch, scaleInc){
    c = ch - 1
    if ( ch > 10 )
        c -= 1
    bend = c % scaleInc
    res = c - bend + 1
    if ( res > 9 )
        res += 1
    return(res)
}

function mkmenu_Ops(o,po){
    o.menucmd("Flip", po, "serialOp", 0)
    o.menucmd("Retro",po, "serialOp", 1)
    o.menucmd("Expnd",po, "serialOp", 2)
    o.menucmd("Cntrc",po, "serialOp", 3)
}
