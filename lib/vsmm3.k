#
# vsmm.k - Very Structured Melody Maker Version 3.0
# Composition tool and Automatic Music Generator
# Chordal and melody experiment
# incorporating a modified Group Tool requiring wsmmgroup.k
# for KeyKit 6.6d
#
# Copyright 2001 David Woolls
#

class vsmm3 { 
	method init { 
	$.w = new window() 
	$.inherit($.w) 

	$.firstpart=0
# Variable for dump/restore
	$.themes=8
	$.themeno=3
	$.hp=0
	$.tunesource="New"
	$.holdbars=[]
	$.totbars=0
	$.holdbars[$.totbars]=0
	$.showstartbars=[]
	$.showstartbars[0]="0"
	$.showstopbars=[]
	$.showstopbars[0]="0"
	$.barplay=1
	$.barstop=1
	$.barlen=32
	$.notebase=8
	$.harmonise=4
	$.reharmonise=3
	$.currmove=0
	$.currchord=0
	$.scale=0
	$.currkey=0
	$.editkey=0
	$.currtsig=0
	$.numbars=2
	$.nbrMeasures=4
	$.holdtsig="4/4"
	$.temp1=500000
	$.vel1=110
	$.vel2=105
	$.bpm1=12
	$.oct=0
	$.sections = 12
	$.currsect=3
$.mvol = 100 #start volume
$.mvolpos = 20  #start volume position in array
	$.tsbeat=24
	$.newvar=0
	$.anyvar=0

	$.dumpvars = arraylist("harmonise","reharmonise","scale","currkey","editkey","nbrMeasures","holdtsig","temp1","vel1","vel2","bpm1","oct","sections","mvol","mvolpos","currtsig","numbars","currsect","tsbeat","barplay","barstop","totbars","anyvar","newvar","notebase","barlen","tunesource","hp","themes","themeno")

# Arrays needed for dump
	$.ph1 = new wphrase()  # holds original
	$.chanpatches=[]
	for(n=1;n<=16;n++)$.chanpatches[n]=1
	$.chphr = []
	for(n=0;n<6;n++)$.chphr[n]=''
	$.ph2 = new wsmmgroup()  # holds current display
	$.inherit($.ph2)

#Operational variables not needed to dump
	$.makekey=0
	$.makescale=0
	$.smmtempo=''
	$.smmtsig=''
	$.smmksig=''
	$.smmvol=''
	$.isplaying=0
	$.starttime=0
	$.sig=44
	$.gens=4
	$.fullstring = ""
	$.fullmel=" "
	$.thetune= " "
	$.notesValue=0
	$.sumvalue=0
	$.first=1
	$.checkstr=""
	$.thestring = ""
	$.compound=0;
	$.lastpart=0
	$.bgen=0
	$.onauto=0
	$.lastnote=0
	$.octoffset = 3

#Arrays for music making
$.keys = [0 = "C",1 = "Db",2 = "D",3 = "Eb",4 = "E",5 = "F",6 = "F#",7 = "G",8 = "Ab/g#",9 = "A",10 = "Bb",11 = "B"]
	$.majorFullArray = [0="p55",1="p57",2="p59",3="p60",4="p62", 5="p64",6="p65",7="p67",8="p69",9="p71",10="p72",11="p74",12="p76"]
	$.minorFullArray = [0="p55",1="p57",2="p59",3="p60",4="p62", 5="p63",6="p65",7="p67",8="p68",9="p70",10="p72",11="p74",12="p75"]
	$.majorArray = [0="p60",1="p62",2="p64",3="p65",4="p67",5="p69",6="p71",7="p72"]
	$.minorArray = [0="p60",1="p62",2="p63",3="p65",4="p67",5="p68",6="p70",7="p72"]
	$.chromArray = [0="p57",1="p58",2="p59",3="p60",4="p61", 5="p62",6="p63",7="p64",8="p65",9="p66",10="p67",11="p68",12="p69",13="p70",14="p71",15="p72"]
	$.pentArray = [0="p61",1="p63",2="p66",3="p68",4="p70"]
	$.barArray = [0="1",1="2",2="4",3="8",4="12",5="16",6="20",7="24",8="32"]
	$.timesigs=[0="4/4",1="3/4",2="2/4",3="6/8",4="9/8",5="12/8",6="2/2",7="3/2",8="4/2",9="6/4",10="9/4",11="12/4",12="2/8",13="3/8",14="4/8",15="6/16",16="9/16",17="12/16",18="5/4",19="7/4",20="5/8",21="7/8"]
	$.ntnames3 = [2="s",3="s.",4="e",6="e.",8="q",12="q.",16="h",24="h."]
vels = []
	for ( n=0; n<128; n++ )
		vels[n] = string(n)
$.tempi = []
	for ( n=0; n<41; n++ )
		$.tempi[n] = string(((n+8)*5))
$.mvols = []
	for ( n=0; n<26; n++ )
		$.mvols[n] = string((n*5))
octs = []
	for ( n=0; n<7; n++ )
		octs[n] = string(n)

#Menu calling buttons
	$.bvel1 = new kvalbutton(vels,$,"vel1changed")
	$.bvel2 = new kvalbutton(vels,$,"vel2changed")
	$.bvol = new kvalbutton($.mvols,$,"volchanged")
	$.bbpm1 = new kvalbutton($.tempi,$,"bpm1changed")
	$.tempphr1= temponote(tempo())
	$.octbutton = new kvalbutton(octs,$,"octchanged")
	$.btime = new kvalbutton($.timesigs,$,"tsig")
	$.kbutt = new kvalbutton($.keys,$,"keychanged")
#$.scabutt = new kvalbutton($.keys,$,"movescale")
	$.editkeybutt = new kvalbutton($.keys,$,"editkeychanged")
	$.bbars = new kvalbutton($.barArray,$,"setNumBars")
	$.showsectbutt = new kvalbutton($.showstartbars,$,"showsection")
	$.stopsectbutt = new kvalbutton($.showstopbars,$,"stopsection")

#Value menu buttons
#	$.bgens = new kvalbutton([0="Melody", 1="2 Lines", 2="3 Lines",3="4 Lines"], $,"setGens")
	$.makesect = new kvalbutton([0="4", 1="8", 2="10",3="12",4="16",5="20"], $,"setSects")
	$.sethp = new kvalbutton([0="5ths", 1="3rds", 2="2nds"], $,"sethps")
	$.setthemes = new kvalbutton([0="T5", 1="T6", 2="T7",3="T8"], $,"setthemeno")

	$.bscale = new kvalbutton([0="Major", 1="Mel. Minor", 2="Harm. Minor", 3="Pentatonic", 4="Chromatic"], $,"setScale")
	$.bgtype = new kvalbutton([0="Improv",1="Triads",2="Mix Chords"],$,"bgchanged")
	$.bharm = new kvalbutton([0="As it comes", 1="H1 Harmonise",2="H2 Harmonise",3="H3 Harmonise",4="H4 Harmonise"] , $,"harmchanged")
	$.breharm = new kvalbutton([0="R1 Re-Harmonise", 1="R2 Re-Harmonise", 2="R3 Re-Harmonise",3="R4 Re-Harmonise"] , $,"newharmonise")
	$.bplay = new kvalbutton([0="T/V Off", 1="T/V ON"] , $,"playchanged")
	$.bfile = new kmenubutton("File","mkmenu_file",$)
	$.bmake = new kmenubutton("Make","mkmenu_make",$)


#Text fields
	$.octtext = new ktext("Octave")
	$.barstext = new ktext("Bars")
	$.keytext = new ktext("Key")
	$.scadjtext = new ktext("New Key")
#	$.transtext = new ktext("Transpose")
	$.bpm1text = new ktext("Bpm ")
	$.vel1text = new ktext("Beat")
	$.vel2text = new ktext("Off")
	$.veltext = new ktext("Velocity")
	$.voltext = new ktext("Vol")
	$.sectiontext = new ktext("Sections")
	$.title = new ktext("Very Structured Melody Maker - Version 3.0")
	$.vel1text.style(NOBORDER)
	$.vel2text.style(NOBORDER)
	$.barstext.style(NOBORDER)
#	$.keytext.style(NOBORDER)
	$.octtext.style(NOBORDER)
	$.sectiontext.style(NOBORDER) 

	$.isset = 0
	$.stoptids = []
#Push Buttons
#	$.segbutt = new kbutton(textfunc("Segment"),$,"gentype1")
#	$.autobutt = new kbutton(textfunc("AutoGen"),$,"autogen")
#	$.varbutt = new kbutton(textfunc("New Variation"),$,"variationa")
#	$.varbutt2 = new kbutton(textfunc("Current Var."),$,"variationb")
#	$.savebutt = new kbutton(textfunc("Save"),$,"writesmf")
#	$.appbutt = new kbutton(textfunc("Append"),$,"appendsmf")
	$.modbutt = new kbutton(textfunc("Modulate"),$,"movescale")
	$.transbutt = new kbutton(textfunc("Transpose"),$,"movekey")
#	$.breharm = new kbutton(textfunc("Re-Harmonise"),$,"reharmonise")
#$.readbutt = new kbutton(textfunc("Read"),$,"readfile")
$.snarfbutt = new kbutton(textfunc("Snarf"),$,"snarf")
$.playbarbutt = new kbutton(textfunc("Play"),$,"playbar")
$.viewbarbutt = new kbutton(textfunc("View"),$,"viewbar")
$.pickbarbutt = new kbutton(textfunc("Pick"),$,"pickbar")
$.nojumpsbutt = new kbutton(textfunc("Melodise"),$,"fnojumps")
			$.addchild($.ph2)
#			$.addchild($.segbutt)
			$.addchild($.snarfbutt)
#			$.addchild($.autobutt)
			$.addchild($.btime)
			$.addchild($.bbars)
			$.addchild($.bscale)
#			$.addchild($.bgens)
			$.addchild($.kbutt)
			$.addchild($.editkeybutt)
			$.addchild($.modbutt)
#			$.addchild($.scabutt)
			$.addchild($.transbutt)
	$.addchild($.octbutton)
	$.addchild($.title)
	$.addchild($.bgtype)
	$.addchild($.sethp)
#	$.addchild($.savebutt)
#	$.addchild($.appbutt)
#	$.addchild($.readbutt)
#	$.addchild($.varbutt)
#	$.addchild($.varbutt2)
	$.addchild($.bharm)
	$.addchild($.breharm)
	$.addchild($.bplay)
	$.addchild($.showsectbutt)
	$.addchild($.stopsectbutt)
	$.addchild($.playbarbutt)
	$.addchild($.viewbarbutt)
	$.addchild($.pickbarbutt)
	$.addchild($.bfile)
	$.addchild($.bmake)
	$.addchild($.nojumpsbutt)
	$.addchild($.setthemes)

	$.addchild($.barstext)
	$.addchild($.keytext)
	$.addchild($.octtext)
	$.addchild($.scadjtext)
#	$.addchild($.transtext)
	$.addchild($.bpm1text)
	$.addchild($.veltext)
	$.addchild($.sectiontext)
	$.addchild($.vel1text)
	$.addchild($.vel2text)
	$.addchild($.voltext)
	$.addchild($.bbpm1)
	$.addchild($.makesect)
	$.addchild($.bvel1)
	$.addchild($.bvel2)
	$.addchild($.bvol)

#Value menu default settings
	$.octbutton.set($.octoffset)
	$.bbpm1.set($.bpm1)
	$.bvel1.set($.vel1)
	$.bvel2.set($.vel2)
	$.bharm.set($.harmonise)
	$.breharm.set($.reharmonise)
	$.bplay.set($.isplaying)
	$.bvol.set($.mvolpos)
	$.bbars.set($.numbars)
	$.makesect.set($.currsect)
	$.sethp.set($.hp)
	$.setthemes.set($.themeno)
	        } 

method buttreset(){
	$.octbutton.set($.octoffset)
	$.btime.set($.currtsig)
	$.bbpm1.set($.bpm1)
	t=integer($.tempi[$.bpm1])
	bpm(t)
	$.bvel1.set($.vel1)
	$.bvel2.set($.vel2)
	$.bharm.set($.harmonise)
	$.breharm.set($.reharmonise)
	$.kbutt.set($.currkey)
	$.editkeybutt.set($.editkey)
	$.bvol.set($.mvolpos)
	$.bbars.set($.numbars)
	$.makesect.set($.currsect)
	$.sethp.set($.hp)
	$.bscale.set($.scale)
	$.showsectbutt.set($.barplay)
	$.stopsectbutt.set($.barstop)
	$.setthemes.set($.themeno)

}

method dump() {
	$.updatepatches()
	st = []
	for ( v in $.dumpvars )
		st[v] = $.(v)
	st["phrases"]=[]
	st["patches"]=[]
	st["bars"]=[]
	st["varbits"]=[]
	st["phrases"][1] = $.ph2.get()
	for(n=1;n<5;n++)
		st["patches"][n]=$.chanpatches[n]
	for(n=0;n<=$.totbars;n++)
		st["bars"][n]=$.holdbars[n]
	for(n=0;n < 6;n++)
		st["varbits"][n]=$.chphr[n]
	return(st)
}

method restore(st) {
	for ( v in $.dumpvars )
		$.(v) = st[v]
	$.buttreset()
	for(n=1;n<5;n++)
		$.chanpatches[n]=st["patches"][n]
	for(n=0;n<=$.totbars;n++)
		$.holdbars[n] = st["bars"][n]
	for(n=0;n < 6;n++)
		$.chphr[n] = st["varbits"][n] 
	$.resetbarplay()
	ph = st["phrases"][1]
	ph=$.reallocatesysex(ph)
	ph=$.setpatches(ph)
	$.ph2.setgroupname($.tunesource)
	$.compplay(ph)
	$.ph2.auditionall()
	$.resize()
}

method resetbarplay (){
	$.showstartbars=[]
	for(n=0;n<=$.totbars;n++)$.showstartbars[n]=string(n)+ " >"
	$.showsectbutt.setvals($.showstartbars)
	$.showsectbutt.set($.barplay)
	$.showsectbutt.redraw()
	$.showsectbutt.resize()
	$.showstopbars=[]
	for(n=0;n<=$.totbars;n++)$.showstopbars[n]="< " + string(n)
	$.stopsectbutt.setvals($.showstopbars)
	$.stopsectbutt.set($.barstop)
	$.stopsectbutt.redraw()
	$.stopsectbutt.resize()
}


method redraw {
	$.w.redraw()
	methodbroadcast();
}
method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	dx = ($.xmax()-$.xmin()) / 10
	y0 = $.ymin()+2
	y0aa = $.ymin() + $.textheight() + 4
	y0a = $.ymin() + 2*$.textheight() + 6
	y0b = $.ymin() + 3*$.textheight() + 8
	y0c = $.ymin() + 4*$.textheight() + 10
	y0d = $.ymin() + 5*$.textheight() + 12
	y0e = $.ymin() + 6*$.textheight() + 14
	y0f = $.ymin() + 7*$.textheight() + 16
	x0 = $.xmin() + 2
	x1 = $.xmax() - 2
	y1 = $.ymax() - 2
#line 1
	$.title.resize(xy($.xmin(),$.ymin(),$.xmax(),$.ymin()+$.textheight()+4))
#line2
	$.btime.resize(xy(x0,y0aa+1,x0+2*dx-3,y0a-1))
#	$.veltext.resize(xy(x0+2*dx+1,y0aa+1,x0+4*dx-3,y0a-1))
	$.vel1text.resize(xy(x0+2*dx+1,y0aa+1,x0+3*dx-3,y0a-1))
	$.bvel1.resize(xy(x0+3*dx+1,y0aa+1,x0+4*dx-3,y0a-1))
	$.bgtype.resize(xy(x0+4*dx+1,y0aa+1,x0+5*dx-3,y0a-1))
	$.bfile.resize(xy(x0+5*dx+1,y0aa+1,x0+6*dx-3,y0a-1))
	$.scadjtext.resize(xy(x0+6*dx+1,y0aa+1,x0+7*dx-3,y0a-1))
	$.editkeybutt.resize(xy(x0+7*dx+1,y0aa+1,x0+8*dx-3,y0a-1))
	$.nojumpsbutt.resize(xy(x0+8*dx+1,y0aa+1,x0+10*dx-3,y0a-1))

#line#3
	bx0 = x0
	bx1 = x0+7*dx
	dbx = (bx1-bx0)/8

	$.octtext.resize(xy(x0+0*dx+1,y0a+1,x0+1*dx-3,y0b))
	$.octbutton.resize(xy(x0+1*dx+1,y0a+1,x0+2*dx-3,y0b))
	$.vel2text.resize(xy(x0+2*dx+1,y0a+1,x0+3*dx-3,y0b))
	$.bvel2.resize(xy(x0+3*dx+1,y0a+1,x0+4*dx-3,y0b))
	$.bmake.resize(xy(x0+4*dx+1,y0a+1,x0+5*dx-3,y0b))
	$.snarfbutt.resize(xy(x0+5*dx+1,y0a+1,x0+6*dx-3,y0b))
#	$.varbutt2.resize(xy(x0+4*dx+1,y0a+1,x0+6*dx-3,y0b))
#	$.appbutt.resize(xy(x0+6*dx+1,y0a+1,x0+8*dx-3,y0b))
#	$.transtext.resize(xy(x0+8*dx+1,y0a+1,x0+10*dx-3,y0b))
	$.modbutt.resize(xy(x0+6*dx+1,y0a+1,x0+8*dx-3,y0b))
	$.bplay.resize(xy(x0+8*dx+1,y0a+1,x0+10*dx-3,y0b))
#line#4
#	$.bgens.resize(xy(x0+0*dx+1,y0b+1,x0+2*dx-3,y0c))
	$.barstext.resize(xy(x0+0*dx+1,y0b+1,x0+1*dx-3,y0c))

	$.bbars.resize(xy(x0+1*dx+1,y0b+1,x0+2*dx-3,y0c))
	$.sectiontext.resize(xy(x0+2*dx+1,y0b+1,x0+3*dx-3,y0c))
	$.makesect.resize(xy(x0+3*dx+1,y0b+1,x0+4*dx-3,y0c))
#	$.autobutt.resize(xy(x0+4*dx+1,y0b+1,x0+6*dx-3,y0c))
#	$.readbutt.resize(xy(x0+6*dx+1,y0b+1,x0+8*dx-3,y0c))
	$.transbutt.resize(xy(x0+6*dx+1,y0b+1,x0+8*dx-3,y0c))
	$.bpm1text.resize(xy(x0+8*dx+1,y0b+1,x0+9*dx-3,y0c))
	$.bbpm1.resize(xy(x0+9*dx+1,y0b+1,x0+10*dx-3,y0c))

#line#5
	$.keytext.resize(xy(x0+0*dx+1,y0c+1,x0+1*dx-3,y0d))
	$.kbutt.resize(xy(x0+1*dx+1,y0c+1,x0+2*dx-3,y0d))
	$.bscale.resize(xy(x0+2*dx+1,y0c+1,x0+4*dx-3,y0d))
	$.breharm.resize(xy(x0+6*dx+1,y0c+1,x0+8*dx-3,y0d))
	$.voltext.resize(xy(x0+8*dx+1,y0c+1,x0+9*dx-3,y0d))
	$.bvol.resize(xy(x0+9*dx+1,y0c+1,x0+10*dx-3,y0d))

#line#6
#	$.segbutt.resize(xy(x0+2*dx+1,y0d+1,x0+4*dx-3,y0e))
	$.bharm.resize(xy(x0+0*dx+1,y0d+1,x0+2*dx-3,y0e))
	$.sethp.resize(xy(x0+2*dx+1,y0d+1,x0+3*dx-3,y0e))
	$.setthemes.resize(xy(x0+3*dx+1,y0d+1,x0+4*dx-3,y0e))
	$.showsectbutt.resize(xy(x0+4*dx+1,y0d+1,x0+5*dx-3,y0e))
	$.stopsectbutt.resize(xy(x0+5*dx+1,y0d+1,x0+6*dx-3,y0e))
#line#7
	$.playbarbutt.resize(xy(x0+4*dx+1,y0e+1,x0+5*dx-3,y0f))
	$.viewbarbutt.resize(xy(x0+5*dx+1,y0e+1,x0+6*dx-3,y0f))
	$.pickbarbutt.resize(xy(x0+6*dx+1,y0e+1,x0+7*dx-3,y0f))

#phrase window
	$.ph2.resize(xy(x0,y0e+20,x1,y1))

}

method delete {
	killtids($.stoptids)
	$.stoptids = []
}

method get {
	return($.ph2.get())
}

method playbar {
	v=$.barplay
	if(v<1)v=1
	blowup=[]
	max=sizeof($.holdbars)-1
	blowup["x0"]=$.holdbars[v-1]*12
	end=$.barstop
	if(end<v)end=v+4
	if(end>max) end=max
	blowup["x1"]=$.holdbars[end]*12
	$.ph2.stop()
	$.ph2.smmauditionbars(blowup)
#	$.ph2.pickaud(0)
}

method viewbar {
	v=$.barplay
	if(v<1)v=1
	blowup=[]
	max=sizeof($.holdbars)-1
	blowup["x0"]=$.holdbars[v-1]*12
	end=$.barstop
	if(end<v)end=v+4
	if(end>max) end=max
	blowup["x1"]=$.holdbars[end]*12
	$.ph2.stop()
	$.ph2.smmzoompush(blowup)
	$.ph2.viewset(blowup)
	$.ph2.showall()

}
method pickbar {
	v=$.barplay
	if(v<1)v=1
	blowup=[]
	max=sizeof($.holdbars)-1
	blowup["x0"]=$.holdbars[v-1]*12
	end=$.barstop
	if(end<v)end=v+4
	if(end>max) end=max
	blowup["x1"]=$.holdbars[end]*12
	$.ph2.stop()
	$.ph2.smmpickbars(0,blowup)

}

method showsection(v){
	$.barplay=v
	
}
method stopsection(v){
	$.barstop=v
	
}


method playchanged (v) {
	if ( v== 0 || $.isplaying ){
		$.stop()
	}
	else {
			$.smmtempo = ''
			$.smmvol = ''
			bpt = temponote(tempo())
			bpt.time = 0
			$.smmtempo += bpt
			$.starttime = Now
			$.smmvol = ''
			vp = gvolchange($.mvol)
			realmidi(vp)
			vp.time = 0
			$.smmvol += vp
#			tid = $.ph2.play(nextquant(Now,1b))
#			$.stoptids[tid] = 1
			$.snarf()

	$.ph2.auditionall()
	$.ph2.playaudition()
	}
	$.isplaying = v	
}
method stop {
	$.ph2.stop()
	$.snarf()
}

method snarf { 
	p = $.ph2.get() 
	p |= $.smmtempo 
	p |= $.smmtsig 
	p |= $.smmksig
	p |= $.smmvol 
	Snarf = p
	return (p)
}

method keychanged (v)  {
 $.currkey=v
 $.makekey=v
 kcp=$.keymoved(v)
	 return (kcp)
}
method editkeychanged (v)  {
 $.editkey=v
	kcp=$.keymoved(v)
	 return (kcp)
}

method keymoved (v)  {
kp='' 
# keysigs = [0 = "C",1 = "Db",2 = "D",3 = "Eb",4 = "E",5 = "F",6 = "F#",7 = "G",8 = "Ab",9 = "A",10 = "Bb",11 = "B"]
majsharpflats = [0 = "0",1 = "-5",2 = "2",3 = "-3",4 = "4",5 = "-1",6 = "6",7 = "1",8 = "-4",9 = "3",10 = "-2",11 = "5"]
minsharpflats = [0 = "-3",1 = "4",2 = "-1",3 = "-6",4 = "1",5 = "-4",6 = "3",7 = "-2",8 = "5",9 = "0",10 = "-5",11 = "2"]
majmin="0"
if($.makescale == 0){
	kp=( phrase("'\"Keysig= " + majsharpflats[v] + "," + majmin + "\" '"))
}
if($.makescale == 1 || $.makescale==2){
majmin="1"
	kp=( phrase("'\"Keysig= " + minsharpflats[v] + "," + majmin + "\" '"))
}
	if($.makescale > 2)kp=''
	return (kp)
}

method set(ph){
	pnotes=cut(ph,CUT_TYPE,NOTE)
	rest=ph-pnotes
	$.smmtsigs =timesigsinfo(rest)
	$.smmksigs =keysigsinfo(rest)
	$.smmtempo =tempoinfo(rest)
	rest-=$.smmtsigs
	rest-=$.smmksigs
	rest-=$.smmtempo
	$.compplay(pnotes)

}

method octchanged (v) {	$.oct = v - $.octoffset }
method bpm1changed (v) {
	$.bpm1 = v 
	t=integer($.tempi[v])
	$.temp1=(1000000/((float(t)/60)))
	bpm(t)
	$.tempphr1=temponote(tempo())
	bpt=$.tempphr1
	if($.isplaying){
		bpt.time = Now - $.starttime
		$.smmtempo += bpt
	}
	else {
		bpt.time = 0
		$.smmtempo = bpt	
	}
	$.snarf()
}
method bpm2changed (v) {
	$.bpm2 = v 
	t=integer($.tempi[v])
	t1=(1000000/((float(t)/60)))
	$.tempphr2=temponote(t1)
}
method bpm3changed (v) {
	$.bpm3 = v 
	t=integer($.tempi[v])
	t1=(1000000/((float(t)/60)))
	$.tempphr3=temponote(t1)
}
method volchanged (v) {
	$.mvolpos = v 
	$.mvol=integer($.mvols[v])
	if ($.isplaying ){
		p = gvolchange($.mvol)
		realmidi(p)
		p.time = Now - $.starttime
		$.smmvol += p
		$.snarf()
	}
}
method harmchanged (v) {
$.harmonise = v 
}
method newharmonise (v) {
	$.stop()
	$.reharmonise=v
	sendscale=$.makescale
	if($.makescale>2)sendscale=0
	if(v==0)
		$.ph2.smmrealedit("smmharmonise1",sendscale,$.editkey)
	if(v==1)
		$.ph2.smmrealedit("smmharmonise2",sendscale,$.editkey)
	if(v==2)
		$.ph2.smmrealedit("smmharmonise3",$.currchord,sendscale,$.editkey)
	if(v==3)
		{
	$.ph2.smmrealedit("smmharmonise4",$.currchord,sendscale,$.editkey)
		}
	if($.barplay==1){
		ks = $.keymoved($.editkey)
		ks.time = 0
		$.smmksig = ks
	}
	$.snarf()
}
method fnojumps () {
	$.ph2.smmrealedit("smmnojumps",$.barlen*12*2)
	$.snarf()
}


#not used in current program.  Works on complete phrase
method phraseharmonise2 () {
	$.stop()
	ph=$.ph2.get()
	progs=cut(ph,CUT_TYPE,PROGRAM)
	ph=onlynotes(ph)
	ph=$.mychadjust3(ph)
	ph=$.modulate(ph)
	ph|=progs
	ks = $.keymoved($.editkey)
	ks.time = 0
	$.smmksig = ks
	$.compplay(ph)
}
method modulate(ph){
		if($.makescale==0){
			p2 = $.dwscadjust(ph,transpose(SMMscale_ionian(),$.makekey), $.makekey,0)
		}
		if($.makescale==1){
			p2 = $.dwscadjust(ph, transpose(SMMscale_aeolian(),$.makekey), $.makekey,1)
		}
		if($.makescale==2){
			p2 = $.dwscadjust(ph, transpose(SMMscale_harminor(),$.makekey), $.makekey,0)
		}
	return(p2)
}


method vel1changed (v) {$.vel1 = v }
method vel2changed (v) {$.vel2 = v }
method bgchanged (v) {$.bgen = v }

method movescale2 () {
	$.stop()
	tr= $.editkey 
	p1=$.ph1.get()
	progs=cut(p1,CUT_TYPE,PROGRAM)
	p1=onlynotes(p1)
	
	if($.makescale == 1)p1=$.dwscadjust(p1,transpose(SMMscale_aeolian(),tr),tr,1)
	if($.makescale == 2)p1=$.dwscadjust(p1,transpose(SMMscale_harminor(),tr),tr,0)
	if($.makescale == 0)p1=$.dwscadjust(p1,transpose(SMMscale_ionian(),tr),tr,0)
	p1|=progs
	$.snarf()
	$.compplay(p1)
}
method movescale () {
	$.stop()
	tr= $.editkey 
	$.ph2.edit("smmscadjust",$.makescale,tr) 
	$.snarf()
}

method movekey () {
	$.stop()
	tr= $.editkey - $.currkey 
ks = $.keymoved($.editkey)
ks.time = 0
$.smmksig = ks
	$.ph2.edit("transpose",tr)
	$.snarf()
}

method movekey2 () {
	$.stop()
	tr= $.editkey - $.currkey 
ks = $.keymoved($.editkey)
ks.time = 0
$.smmksig = ks
	p1=$.ph1.get()
	progs=cut(p1,CUT_TYPE,PROGRAM)
	p1=onlynotes(p1)

	p1 = transpose(p1,tr)
	$.ph2.set(p1,0)
	$.ph2.fitall()
	$.ph2.redraw()
	p1|=progs
	$.snarf()
	$.compplay(p1)
}


#picks up from the Time Signature
method tsig(t) {
	$.btime.set(t)
	$.currtsig=t
	$.holdtsig=$.timesigs[t]
	thistime=$.holdtsig
	len=sizeof(thistime)
	c=1
	$.compound=0
	nstr=""
	while(nstr != "/"){
		nstr=substr(thistime,c,1)
		c++
	}
	ntstr=substr(thistime,1,c-2)
	barstr=substr(thistime,c,len)
	nv=integer(ntstr)
	if(nv > 3 && nv % 3 == 0)$.compound=1
	bval=integer(barstr)
	if(bval==2)$.notebase=16
	else	{
		bx= bval/4
		$.notebase= 8 / bx
	}
	$.barlen=nv* $.notebase
	if($.compound) $.notebase*=3
	$.tsbeat=96/bval
#	$.smmtsig |= phrase("'\"Timesig="+$.holdtsig+","+string($.tsbeat)+",8\" '")
#print ($.holdtsig)
}

#picks up from the Scale button
method setScale(sc){
	$.bscale.set(sc)
	$.scale = sc
	$.makescale = sc
#	kcp=$.keymoved($.currkey)
#	 return (kcp)
}

#picks up number of parallel generations to do from the Gen button
method setGens(g){$.gens=g+1}

method setthemeno(h){
$.themes=h+5
$.themeno=h
}

method sethps(h){
$.hp=h
}

method setSects(g){
$.currsect=g
if(g==0)$.sections = 4
if(g==1)$.sections = 8
if(g==2)$.sections = 10
if(g==3)$.sections = 12
if(g==4)$.sections = 16
if(g==5)$.sections = 20
}

method gentype1 (){
	$.stop()
	$.emptybars()
	$.updatepatches()
	$.currchord=0
	$.setmake()
	$.ph2.set('')
	$.tunesource="New Segment"
	$.ph2.setgroupname($.tunesource)
	$.smmtempo=''
	t=integer($.tempi[$.bpm1])
	bpm(t)
	bpt = temponote(tempo())
	bpt.time = 0
	$.starttime = Now
	$.smmtempo = bpt
	$.smmtsig = phrase("'\"Timesig="+$.holdtsig+","+string($.tsbeat)+",8\" '") 	ks = $.keymoved($.currkey)
	ks.time = 0
	$.smmksig = ks
	p=$.segment($.bgen+1)
	$.setbars(0)
	p=$.setpatches(p)
	$.compplay(p)
}

method emptybars (){
	$.holdbars=[]
	$.totbars=0
	$.holdbars[$.totbars]=0

}

method setbars (v){
	numbars=$.nbrMeasures
	if(v==1)numbars *= $.sections
	for(n = 1; n <= numbars; n++){
		newlen=$.holdbars[n-1]+$.barlen 
		$.totbars++ 
		$.holdbars[n]=newlen
	}
	$.showstartbars=[]
	for(n=0;n<=$.totbars;n++)$.showstartbars[n]=string(n)+ " >"
	$.showsectbutt.setvals($.showstartbars)
	$.showsectbutt.set(1)
	$.showsectbutt.redraw()
	$.showsectbutt.resize()
	$.showstopbars=[]
	for(n=0;n<=$.totbars;n++)$.showstopbars[n]="< " + string(n)
	$.stopsectbutt.setvals($.showstopbars)
	$.stopsectbutt.set($.totbars)
	$.stopsectbutt.redraw()
	$.stopsectbutt.resize()
	$.barplay=1
	$.barstop=$.totbars

}

method variationa (){
	$.currchord=0
	$.stop()
	$.updatepatches()
	$.ph2.set('')
	$.emptybars()
	$.setmake()
	$.tunesource="New Variation"
	$.ph2.setgroupname($.tunesource)
	$.newvar=1
	$.anyvar=1
	$.variation()
	$.setbars(1)
}
method variationb (){
	$.currchord=0
	$.stop()
	$.updatepatches()
	$.ph2.set('')
	$.emptybars()
	$.setmake()
	$.tunesource="From Current Variation"
	$.ph2.setgroupname($.tunesource)
	$.newvar=0
	if(! $.anyvar)$.newvar=1
	$.variation()
	$.setbars(1)
}



method mychadjust1(p) {

	movers=[]
	p1=''
	p1|=p
	p2=''
	for (nt in p1){
		ntime=nt.time
		npitch=nt.pitch % 60
	
		ntch=nt.chan
		x=rand(2)
		third=4
#if($.makescale == 1 || $.makescale == 2) third=3
		if(x==0){
			x2=7
			x3=third
		}
		if(x==1){
			x2 = third
			x3 = 7
		}
		dir=rand(2)
		if(dir)x2-=12
		else	x3-=12
		movers[2]=x2
		movers[3]=x3
		movers[4]=0
		last=rand(3)
		if(last==1)movers[4]=third
		if(last==2)movers[4]=7
	
		r = ''
		scl = cut(p1,CUT_TIME,ntime,ntime,INCLUSIVE)
		c=2
		for (thisnote in scl){
			if(thisnote.chan != ntch){
				thisoct= integer( thisnote.pitch/12)
				newpitch =(npitch % 12) + movers[c] 
				if(newpitch>11)newpitch-=12
				newpitch +=(thisoct*12) 
				thisnote.pitch = newpitch 
				c++
				if(c>4)c=2
			}
			r |= thisnote
		}
		p1-=scl
		p2|=r
	}

	return(p2)
}


method ntadjust1OLD (nt,tr){
	np = nt.pitch
	mynote=''
	look="p"+string(np)
	if($.makescale==0){
		for(a=0;a<13;a++){
			if(look==$.majorFullArray[a])break
			}
		a+=tr
		if(a > 9)a-=7
		else{
			if (a < 0) a+=7
		}
		mynote=phrase("'"+$.majorFullArray[a]+"'")
		nt.pitch = mynote.pitch
	}
	if($.makescale==1 || $.makescale == 2){
		for(a=0;a<13;a++){
			if(look==$.minorFullArray[a])break
		}
		a+=tr
		if(a > 9)a-=7
		mynote=phrase("'"+$.minorFullArray[a]+"'")
		nt.pitch = mynote.pitch
	}

return (nt)
}

method ntadjust1 (nt,tr){
	np = nt.pitch
	mynote=''
	look="p"+string(np)
	if($.makescale==0){
		for(a=0;a<8;a++){
			if(look==$.majorArray[a])break
	}
	a+=tr
	if(a > 7)a-=7
	else{
		if (a < 0) a+=7
	}
	mynote=phrase("'"+$.majorArray[a]+"'")
	nt.pitch = mynote.pitch
	}
	if($.makescale==1 || $.makescale==2){
	for(a=0;a<8;a++){if(look==$.minorArray[a])break}
	a+=tr
	if(a > 7)a-=7
	mynote=phrase("'"+$.minorArray[a]+"'")
	nt.pitch = mynote.pitch
	}

return (nt)
}


method ntadjust (nt,tr){
	npb=0
	ch=0
	np = nt.pitch % 12
	if($.makescale==0){
		if(np==2||np==4||np==9||np==11)npb=1
		if(tr == 1){
			ch=7
			if(np==8 || np==11)ch--
		}
		if(tr == 2){
			ch=4
			if(npb)ch--
		}
	}
	if($.makescale==1 || $.makescale==2){
		if(np==3||np==8)npb=1
		if(tr == 1){
			ch=7
			if(np==11||np==2)ch--
			if(np==3)ch++
		}
		if(tr == 2){
			ch=3
			if(np==3||np==7||np==8)ch++
		}
	}

return (ch)
}

method compplay(p1){

	$.ph1.set(p1,0)
#p1|=$.smmtsig
#p1|=$.smmtempo
	$.ph2.set(p1)
	$.ph2.chansplit()
#	$.ph2.fitall()
#	$.ph2.redraw()
	$.snarf()
#	$.play()

}



#picks up from the Bars menu
method setNumBars(b){
	$.bbars.set(b)
	$.numbars=b
	$.nbrMeasures = integer($.barArray[b])
}


#Main program taken from javascript version
method CompBeat(howmany) {
$.checkstr=""
$.fullstring = ""
$.fullmel=" "
$.thetune= " "
$.notesValue=0
$.sumvalue=0
#$.notebase=8
$.first=1
$.thestring = ""
maxbeat = $.barlen
if(maxbeat >24)maxbeat=24
minbeat = 2 #sixteenth notes at present
#if(howmany>2)minbeat=$.notebase
#if(howmany+1 == $.sections)$.lastpart=1
# make sure you don't go outside the bar limit for note length
beatval = 0
mult=1.0
newbar=1
maxbeat++ #increment for rand purposes
picknote=0
# repeat for the number of measures required set at 4 at present
for (count=1; count<= $.nbrMeasures; count++) {
	direction=0
#	if($.lastpart && count+1 == $.nbrMeasures)minbeat=$.notebase
	$.sumvalue = $.barlen  #start with a full bar
	$.notesvalue = 0  #count the other way as well
	newbar=1
	while ($.sumvalue >= minbeat) {
		thebeat = 1000
		while(thebeat >maxbeat)thebeat=rand(1000)
		beatval = thebeat #choose a value
		mnv=$.notesvalue
		mnb=$.notebase
		modbit = mnv  % mnb 
		if(howmany>6)beatval=(rand($.barlen/$.notebase)+1)* $.notebase
#deal with simple or compound time differently
		if($.notebase==12){
			picknote = rand(3)+1
			if(modbit==10)beatval=2
			else
			if(modbit % 2 == 0)beatval=picknote*2
					
		}
		if( $.notebase==6){
			if(modbit==4)beatval=2
			if(modbit == 2){
				picknote = rand(2)+1
				beatval=picknote*2
			}
		}
		if($.notebase==24){
			if(modbit==2){
				beatval=2	
			}
			if(modbit==4){
				picknote = rand(2)+1
				beatval=picknote*2
			}
			if(modbit==6){
				beatval=6			
			}
			if(modbit>6 && modbit<17){
				picknote = rand(2)+1
				beatval=picknote*4
			}
			if(modbit>16){
				picknote = rand(2)+1
				beatval= picknote*2
			}
		}
		if($.notebase==8  || $.notebase == 16){
#			if($.notesvalue==8 && $.barlen==32 && beatval==16)beatval=8
			if($.notesvalue==10 && $.barlen==24 )beatval=2
			if(modbit==2){
				beatval=2			}
			if(modbit==4 || modbit==8){
				beatval=4			}
			if(($.barlen==24 || barlen=48 )&& beatval==16){
				picknote = rand(2)+1
				beatval= picknote*4
			}
			if(! $.compound && $.barlen==32 && beatval==16){
				picknote = rand(2)+1
				beatval= picknote*4
			}
			if(modbit==6 || modbit > 9 && barlen != 24){
				beatval=2
			}
		}
	# tidy up remainders
		if ($.sumvalue==4) beatval=4
		if ($.sumvalue==3) beatval=3
		if( beatval <= $.sumvalue){
			if (mnv % mnb ==0 ){
				if( beatval==2 || ($.compound && beatval==4)){
					holdbv=beatval
#					if($.barlen==24)holdbv=1
					bt=rand(100)
					if(howmany>3 || bt >80){
						beatval=$.notebase
					}
					hm=$.notebase / beatval
					direction=rand(2)+ 1
					for(nn = 0; nn <hm; nn++) {
						if(hm>1 && nn<hm-1 && bt < 50){
							beatval=holdbv*2
							nn++
						}
						newbar = $.MakeCompBeat(beatval,newbar,1,direction)
						beatval=holdbv
						bt=rand(100)
					}
				}
				else{
newbar = $.MakeCompBeat(beatval,newbar,0,direction)

				}
			}
			else{
newbar = $.MakeCompBeat(beatval,newbar,0,direction) 
			}
		}
	}
	$.fullmel+=$.thetune  # the melody so far
	$.fullstring+=$.thestring  # the rhythm so far	

	$.thestring=""  #clear for next bar
	$.thetune=""
}
#print($.fullstring)
kp=$.kphrase()  # turn it into a .k phrase
return (kp)
}

# Allocate notes 
method MakeCompBeat(beatval,newbar,multi,direction)
{
# allowed regular
	thisnote = " ";
	tnote=  " ";
        made = 1;
#	if(! $.compound && beatval==3)made=0  #only allow in compound time
	if(beatval==3 && $.notebase!=24)made=0  #never allow 
#	if(beatval==12 && $.notebase==16)made=0  #never allow in x/4
	if(beatval==6 && ($.notebase % 6 !=0))made=0  #only allow in x/16 and x/8 or compound/4
	if($.notebase == 16 && (beatval % 6)==0 )made=0  #never allow in x/2
	if($.notebase == 8 && ! $.compound && (beatval % 6)==0 )made=0  #never allow in 4/4 or 2/4
	if($.notebase == 4 && ! $.compound && (beatval % 6)==0 )made=0  #never allow in x/8
#	if($.notebase == 6 && (beatval % 8)==0 )made=0  #never allow in x/16
#	if($.notebase == 6 && $.barlen==18 && (beatval % 12)==0 )made=0  #never allow in x/16
	if($.compound && beatval==16)made=0	  # disallow in compound time
	if(made){
		if( beatval in $.ntnames3){thisnote=$.ntnames3[beatval]}
		else {made = 0 }

	}
 	if (made ) {
		if($.notesvalue==0 || $.notesvalue==($.barlen/2))newbar=1
		if($.notesvalue>0 && $.barlen % 3 == 0)newbar=0
	
		$.sumvalue -= beatval  #decrement bar length
		$.notesvalue += beatval  # increment note value in this bar
		if(newbar) {thisnote = $.UpperFirst(thisnote,newbar)}
		$.thestring +=  thisnote
	$.checkstr+=thisnote
		$.thetune+=$.MakeCompTuneOld(newbar, multi,beatval,direction)
		$.first=0  
		if(newbar)newbar=0
		# Catch tricky divisions and force repeat choice
		if($.compound == 1 && $.notesvalue<12 && beatval == 2){
			$.thestring+="s "
			$.sumvalue-=2
			$.notesvalue+=2
			$.thetune+=$.MakeCompTuneOld(newbar,multi,beatval,direction)
		}
		if($.compound ==1 && $.notesvalue<12 && beatval == 3){
			$.thestring+="s. "
			$.sumvalue-=3
			$.notesvalue+=3
			$.thetune+=$.MakeCompTuneOld(newbar,multi,beatval,direction)
		}
	}

	return (newbar)
#	return ($.thestring + "  " + $.thetune)
}


#Pick a note from the appropriate scale
method MakeCompTune(newbar,multi,beatval){
		note=17
		if($.makescale<3){
			if(multi || beatval <5){
				near=rand(2)+1
				dir=rand(2)
				if(dir){
					note=$.lastnote+near
					if(note  >7) 					note=$.lastnote-near 
					}
					
				else {
					note=$.lastnote-near 
					if(note < 0) 					note=$.lastnote+near
				}
			}
			else {
				while(note>7)note = rand(70)
				if (abs($.lastnote-note)>5){
					note = $.lastnote + note- 5
					if(note>7)note=7
					if(note<0)note=0
					}
			}
		}
		if($.makescale==3) note=rand(5)
		if($.makescale==4) {while(note>15)note = rand(70)}
		start =rand(5)
		if(start >0 || start < 4 )start=0
		if($.makescale==0){
			if($.first){  # force C or G
			anote = $.majorArray[start]
			$.lastnote=start
			}
			else {
			anote = $.majorArray[note]
			$.lastnote=note
			}
		}
		if($.makescale==1 || $.makescale==2){
			if($.first){  # force C or G
			anote = $.minorArray[start]
			$.lastnote=start
			}
			else {
			anote = $.minorArray[note]
			$.lastnote=note
			}
		}
		if($.makescale==3){
			note = rand(5)
			anote = $.pentArray[note]
		$.lastnote = note
		}
		if($.makescale==4){
			anote = $.chromArray[note]
		$.lastnote = note
		}
		# emphasise beat at start or in middle
		$.thetune +=  anote;
		$.checkstr+=anote;
}
#Pick a note from the appropriate scale
method MakeCompTuneOld(newbar,multi,beatval,direction){
		note=17
		if($.makescale<3){
			if(multi || beatval <5){
				if(direction==0){
					near=rand(2)+1
					dir=rand(2)
					if(dir){
						note=$.lastnote+near
						if(note > 12)note=11
					}
					else {
						note=$.lastnote-near
						if(note < 0 )note=1
					}
				}
				if(direction==1){
					note=$.lastnote+1
					if(note  >12 )note=11									}	
				if (direction==2){
					note=$.lastnote-1 
					if(note < 0)note=1
				}
			}
			else {
				while(note>12)note = rand(70)
				if (abs($.lastnote-note)>5){
					note = $.lastnote + note- 5
					if(note>12)note=12										if(note<0)note=0
					}
			}
		}
		if($.makescale==3) note=rand(5)
		if($.makescale==4) {while(note>15)note = rand(70)}
		start =rand(7)
		if(start >0 || start < 6 )start=3
		if($.makescale==0){
			if($.first){  # force C or G
			anote = $.majorFullArray[start]
			$.lastnote=start
			}
			else {
			anote = $.majorFullArray[note]
			$.lastnote=note
			}
		}
		if($.makescale==1 || $.makescale==2){
			if($.first){  # force C or G
			anote = $.minorFullArray[start]
			$.lastnote=start
			}
			else {
			anote = $.minorFullArray[note]
			$.lastnote=note
			}
		}
		if($.makescale==3){
			note = rand(5)
			anote = $.pentArray[note]
		$.lastnote = note
		}
		if($.makescale==4){
			anote = $.chromArray[note]
		$.lastnote = note
		}
		# emphasise beat at start or in middle
		$.thetune +=  anote
		$.checkstr+=anote
}

#Transform result into .k file
method kphrase(){
noteString = ""  # store notes
velString=""	#store velume
mel=""   #store melody
kpString="'"  # start with apostrophe
c=""
s=""
note=-1
len=sizeof($.fullstring)+1
for (i = 1; i < len; i++) {
	c=substr($.fullstring,i,1) 	
	# since dots always follow notes, the note is not written until here
	if(c == ".")note++  #notes run from 0 to 7.  Odd ones are dotted so add 1
	if(note >= 0){
		noteString +=string(note)
		velString+=string(vel)
	}
	note =- 1
	vel=0
	#velocity is allocated on case 
	if( c== "S"){
		vel=1
		note=0
		}
	if( c== "s")note=0
	if( c== "E"){
		vel=1
		note=2
		}
	if( c== "e")note=2
	if( c== "Q"){
		vel=1
		note=4
		}
	if( c== "q")note=4
	if( c== "H"){
		vel=1
		note=6
		}
	if( c== "h")note=6
	
}
#pick up the last note
	vel=1
	noteString +=string(note)
	velString+=string(vel)

#now work out the melody line
len=sizeof($.fullmel)+1
for (i = 1; i < len; i++){
	c=substr($.fullmel,i,1) 	
	if(c != " "){
	mel+=c
	}
}
len=sizeof(mel)/3 + 1
lastvel=0
lastdur=0
temposplit=0
#Stick it all together
j=1
for (i = 1; i < len; i++){
	if(i>1) {kpString +=","	}
		c=substr(mel,j,3) j+=3	
	kpString += c
	# how long is the note?
	c=substr(noteString,i,1) 	
	dur=$.durations(c)
	#avoid repeat duration
	if(dur != lastdur){
		kpString+="d"
		kpString+=string(dur)
	}
	lastdur=dur
	#how loud is the note?
	c=substr(velString,i,1) 	
	#avoid repeat velume
	if(c !=lastvel){
		kpString+="v"
	
		if(c=="0")kpString += string($.vel2) #off beat
		else kpString += string($.vel1)  #on beat
	}
	lastvel=c
}

kpString+="'"
return (kpString)

}
#what it says
method switchCase(c,up){
	num=ascii(c)
	if(! up && num <  96){num+=32}
	if(up && num >  95){num-=32}
	
return (ascii(num))
}
#likewise
method UpperFirst(c){
	len=sizeof(c)
	if(len>0){
	d=substr(c,1,1)
	num=ascii(d)
	if(num <  96){num+=32}
	if(num >  95){num-=32}
	
	out=ascii(num)
	if(len >1)out=out+substr(c,2,len)
	return(out)
	}
	else
	return(c)
}
#reallocate the notes
method CheckSharp(c){
	if (c== "A")c="a+"
	else
	if (c== "B")c="c"
	else
	if (c== "C")c="c+"
	else
	if (c== "D")c="d+"
	else
	if (c== "E")c="f"
	else
	if (c== "F")c="f+"
	else
	if (c== "G")c="g+"

return (c)
}
#set the durations  should be an array.
method durations(c){
	dur=24

	if(c=="0") dur=24
	else
	if(c=="1") dur=36
	else
	if(c=="2") dur=48
	else
	if(c=="3") dur=72
	else
	if(c=="4") dur=96
	else
	if(c=="5") dur=144
	else
	if(c=="6") dur=192
	else
	if(c=="7") dur=288
	
return (dur)
}

#Can be used by Variation and Autogen to move lower lines 
#around from generated theme
method choosenewnote(nt,tr)
{
				npb=0
				ch = 0
				np = nt.pitch % 12
				if($.makescale==0){
					if(np==2||np==4||np==9||np==11)npb=1
					if(tr == 1){
						ch=7
						if(np==11)ch--
				}
					if(tr == 2){
						ch=4
						if(npb)ch--
					}
				}
				if($.makescale==1 || $.makescale==2){
					if(np==3||np==8)npb=1
					if(tr == 1){
						ch=7
						if(np==11||np==2)ch--
						if(np==3)ch++
					}
					if(tr == 2){
						ch=3
						if(np==3||np==7||np==8)ch++
					}
				}

				if(ch >0)nt =transpose(nt,ch)
	return (nt)
}

# Used by Segment button 
#Controls the number of generations and applies chord and scale adjustments
method segment(v) {
	offset=$.oct
min = $.gens-$.octoffset
min++
p1=''
tpose1 = [0=0,1=2,2=4,3=0]
tpose2 = [0=0,1=4,2=2,3=0]

tpose3 = [0=0,1=2,2=0,3=4]
tpose4 = [0=0,1=4,2=0,3=2]

#	offset++
	if($.gens >1){
		offset++
		if(offset>4)offset=4
		
		if($.oct<-1 && ($.gens + $.oct) <= min) offset= min -1

	}
	howmany=0
	rand(-Now)

	offset--
	s= $.CompBeat(howmany)
	p1= phrase(s)
	pc=p1
#	p1= transpose(p1,$.currkey + (offset*12)) 
	howmany++
	p1.chan=howmany
#	print($.chanpatches[howmany+1])
#	p1 |= progchange($.chanpatches[howmany+1],howmany+1)
#	pc=p1
			if(v==2){
				t=rand(4)
				if (t==0)tpose=tpose1 
				if (t==1)tpose=tpose2 
				if (t==2)tpose=tpose3 
				if (t==3)tpose=tpose4 
			}
	while(howmany < $.gens){
		p=''
		if(howmany>1)offset--
		if(v==1){
			s= $.CompBeat(howmany)
			p= phrase(s)
#			p= transpose(p,$.currkey + (offset*12)) 
			if( howmany==3){
				pc=p
				v=5
			}
		}
		if(v<6 && howmany >0){
		      if(v == 2 || v ==3) p= pc 
			if(v == 4) p= p1 
			if(v == 5) p=pc
			r= ''
			for(nt in p){
				ch = 0
				rbit=3
				if(v!=2) {
					t=rand(4)
					if (t==0)tpose=tpose1 
					if (t==1)tpose=tpose2 
					if (t==2)tpose=tpose3 
					if (t==3)tpose=tpose4 
				}
				tr=tpose[howmany]
				if(v==1 && nt.dur < 49){
					tr=2
				}
#				if($.makescale < 3 && v<6)nt=$.ntadjust1OLD(nt,tr)
#				else
#					{				
					if($.makescale==4)ch=rand(12)
					if(ch >0)nt =transpose(nt,ch)
#				}
			r |= nt
			}
		p = r
#		if($.makescale < 3 )p= transpose(p,$.currkey + (offset*12)) 
		p= transpose(p,$.makekey + (offset*12)) 
		}
		howmany++ 
		p.chan=howmany
#		p |= progchange($.chanpatches[howmany+1],howmany+1)
		p1 |= p
	}
	      if($.harmonise==1 && v!=2)p1=$.mychadjust1(p1)
	      if($.harmonise==2 && v!=2)p1=$.mychadjust2(p1)
	      if($.harmonise==3 && v!=2)p1=$.mychadjust3(p1)
	      if($.harmonise==4 && v!=2)p4=$.mychadjust4(p1)
	if($.makescale < 3 && howmany > 1)p1=$.modulate(p1)
#	if(howmany > 1)p1=transpose(p1,$.currmove)
#	bpt = temponote(tempo())
#	bpt.time = 0
#	$.starttime = Now
#	$.smmtempo += bpt
	p1=$.nojumps(p1)
	return (p1)
}


# Controls the number of generations and applies chord and scale adjustments for Variation style
method variation() {
#	$.updatepatches()

	$.currchord=0
	$.smmtempo = ''
	t=integer($.tempi[$.bpm1])
	bpm(t)
	bpt = temponote(tempo())
	bpt.time = 0
	$.starttime = Now
	$.smmtempo += bpt
	ts = phrase("'\"Timesig="+$.holdtsig+","+string($.tsbeat)+",8\" '")
	ts.time=0
	$.smmtsig = ts
	ks = $.keymoved($.currkey)
	ks.time = 0
	$.smmksig = ks
	rand(-Now)
	$.lastpart=0
	offset = 0
	$.gens=4
	howmany=0
	trp=0
	tpose = []
	holdfull = []
	lastplay=0
	pickphr = 0
	pp=''
	if($.newvar){
		for (n=0;n<$.themes;n++){
			s= $.CompBeat(n)
			p1= phrase(s)
			$.chphr[n]= p1
		}
	}
	p2=''
	prepeat=301
	repeated=0
	rep = -1
	chosen=$.chooseharmseq()
	$.firstpart=1
	while(howmany < $.sections){
		if(howmany+1==$.sections){
			$.lastpart=1
			$.setmake()
		}
#		if(howmany>1 && ! $.lastpart)$.changemakekey(chosen)
#		print ($.keys[$.makekey] + "  " + string($.makescale)+ "S"+string(howmany+1))
		p4=''
		p=''
		offset=0
		v=100
		multiphr=1
		while(v > 10)v=rand(1000)
		if(v==0)p=$.chphr[0]
		if(howmany >0){
			prepeat=rand(1000)+1
		}
		p4=''
		if($.lastpart){prepeat=51 repeated=0}
		if(prepeat > 0 && prepeat <150){
			
			if(repeated){prepeat=301 repeated=0}
			else {p4=holdfull[0] repeated=1}
		}
		if(prepeat > 149 && prepeat <300){
			sectlen=($.barlen*$.nbrMeasures*2)
			if(repeated){ prepeat= 301 repeated=0}
			else {
				repeated=1
				if(p2.length+sectlen < ((sectlen/2)*$.sections)){
					if(p2.length < sectlen)start=0
					else start= p2.length-sectlen 
					p4=cut(p2,CUT_TIME, start ,p2.length)
				}
				else{
					if(p2.length <= sectlen)p4=p2	
					else p4=holdfull[0]
				}
			} 

		}
#		if(prepeat >800 && prepeat <901){
#			p4=$.segment(1)
#		}
		if(prepeat >900){
				if(howmany<2)p4=holdfull[0]
				else p4=holdfull[1]
				multiphr=0
		}
		if(prepeat> 299 && prepeat <901){
			lastpick=-2
			lastdiff=0
			firstpick=0
			for (n=0;n<4;n++){
				ot=0
				if (n>1)offset--
#				if(n==0)ot=7
#				if($.lastpart)pickphr=rand(3)+3				
#				else {
					if(n==0){
						pickphr=rand($.themes-2) 
						firstpick=pickphr
					}
					else pickphr=rand(2)+ $.themes-2
#				}	
				if(pickphr>=0 && !lastdiff && pickphr != lastpick)lastdiff=1
				if(n<2)lastpick=pickphr
				if(lastdiff){
					double=rand(5)
					if(double>1)pickphr=lastpick
					else pickphr=firstpick

				}
				if(n>0){gap=rand(10) if(gap<2)pickphr= -1 }
				if(pickphr==-1)p=''
				else{
				p= transpose($.chphr[pickphr],$.makekey + (offset*12)+ot)					

				}
			p.chan=n+1
#			if(p.chan==3)p.vol-=10 
#			if(p.chan==4)p.vol-=10
			p4 |= p
			}
		}
if(prepeat>299 && prepeat<901){
	      if($.harmonise==1)p4=$.mychadjust1(p4)
	      if($.harmonise==2)p4=$.mychadjust2(p4)
	      if($.harmonise==3)p4=$.mychadjust3(p4)
	      if($.harmonise==4)p4=$.mychadjust4(p4)
		if($.makescale < 3 && $.harmonise)p4=$.modulate(p4)
#		if($.harmonise)p4=transpose(p4,$.currmove)
}
		if(howmany==0)holdfull[0]=p4
		else holdfull[1]=p4
		p2+=p4
		howmany++ 
		$.firstpart=0
		
	}
	p2=$.nojumps(p2)
	p2=$.setpatches(p2)
	$.compplay(p2)

}


# Controls the number of generations and applies chord and scale adjustments for Autogen Style
method autogen() {
	$.stop()
	$.currchord=0
	$.emptybars()
	$.updatepatches()
	$.ph2.set('')
	$.tunesource="Auto Generation"
	$.ph2.setgroupname($.tunesource)
	$.setmake()
	$.smmtempo=''
	t=integer($.tempi[$.bpm1])
	bpm(t)
	bpt = temponote(tempo())
	bpt.time = 0
	$.starttime = Now
	$.smmtempo += bpt
	$.smmtsig = ''
	picktimesig=2000
	while(picktimesig > 20)picktimesig = rand(200)
	$.tsig(picktimesig)
	ts = phrase("'\"Timesig="+$.holdtsig+","+string($.tsbeat)+",8\" '")
	ts.time=0
$.smmtsig = ts
$.smmksig=''
ks = $.keymoved($.currkey)
ks.time = 0
$.smmksig = ks
	rand(-Now)
#	starttime=Now
	$.lastpart=0
	offset = 0
	$.gens=4
	if($.nbrMeasures > 8)$.nbrMeasures=8
	howmany=0
	trp=0
	tpose = []
#	chphr = []
	holdfull = []
	lastplay=0
	pickphr = 0
	p2=''
	prepeat=51
	currbar=0
	chosen=$.chooseharmseq()
	while(howmany < $.sections){
		p4=''
		p=''
		offset=0
		v=100
		multiphr=1
		newts=rand(15)
#		if(howmany>2 && howmany < $.sections-1)$.changemakekey(chosen)
		if(howmany == $.sections-1)$.setmake()
#		print ($.keys[$.makekey] + "  " + string($.makescale)+ "S"+string(howmany+1))
			
		if(newts < 8){
			picktimesig=2000
			while(picktimesig > 20)picktimesig = rand(200)
			$.tsig(picktimesig)
			p3 = phrase("'\"Timesig="+$.holdtsig+","+string($.tsbeat)+",8\" '")

			p3.time=currbar
			if(currbar>0)$.smmtsig |= p3
			else $.smmtsig=p3
		}
		if(howmany && newts>7)p3=''
		for (n=0;n<6;n++){
			s= $.CompBeat(n)
			p1= phrase(s)
			$.chphr[n]= p1
		}
		while(v > 10)v=rand(1000)
		if(v==0)p=$.chphr[0]
		if(v==2)tr=rand(4)
		if(howmany >0){
			prepeat=rand(1000)+1
		}
		p4=''
		if(prepeat > 0 && prepeat <50){
			p4=holdfull[0]
			if(! $.lastpart){
				trp=rand(4)
				if(trp == 1) p4=transpose(p4,2)
				if(trp == 2) p4=transpose(p4,4)
				if(trp == 3) p4=transpose(p4,7)
			}
		}
		if(prepeat >800 && prepeat <901){
			whch=rand(3)+1
			p4=$.segment(whch)
		}
		if(prepeat >900){
				if(howmany<2)p4=holdfull[0]
				else p4=holdfull[1]
				if(! $.lastpart){
					trp=rand(25)
					if(trp == 1) p4=transpose(p4,2)
					if(trp == 2) p4=transpose(p4,4)
					if(trp == 3) p4=transpose(p4,7)
					if(trp == 14) p4=reverse(p4)
#					if(trp == 19) p4=flip(p4)
#					if(trp == 23) p4=flip(reverse(p4))
				}
				multiphr=0
		}
		if(prepeat> 49 && prepeat <801){
			for (n=0;n<4;n++){
				ot=0
				if (n>1)offset--
				if(n==0)ot=7
				if($.lastpart)pickphr=rand(3)+3								else
				pickphr=rand(7)-1
				if(pickphr==-1)p=''
				else{
				p= transpose($.chphr[pickphr],$.makekey + (offset*12)+ot)					
				switch=rand(6)
				if(switch == 3) p=reverse(p)
				if(switch == 4) p=flip(p)
				if(switch == 5) p=flip(reverse(p))

				}
#				r= ''
#			for(nt in p){
#				rbit=5
#				if(nt.dur<49)rbit=3
#				if(v!=2) tpose[howmany]=rand(rbit)
#				tr=tpose[howmany]
#				nt=$.choosenewnote(nt,tr)
#				r |= nt
#				}
#				p = r
			p.chan=n+1
			p4 |= p
			}
		}
		sectbarlen=p4.length/$.nbrMeasures/12
		for(n=0;n<$.nbrMeasures;n++){
			newlen=$.holdbars[$.totbars]+sectbarlen
			$.totbars++ 
			$.holdbars[$.totbars]=newlen
		}
	      if($.harmonise==1 )p4=$.mychadjust1(p4)
	      if($.harmonise==2 )p4=$.mychadjust2(p4)
	      if($.harmonise==3 )p4=$.mychadjust3(p4)
	      if($.harmonise==4 )p4=$.mychadjust4(p4)
		if($.makescale < 3 && $.harmonise)p4=$.modulate(p4)
#		if($.harmonise)p4=transpose(p4,$.currmove)
		if(howmany==0)holdfull[0]=p4
		else holdfull[1]=p4
		p2+=p4
#		if(prepeat <801 || prepeat >900)p2|=p3
		howmany++ 
		currbar = p2.length
		
	}
	p2=$.nojumps(p2)
	p2=$.setpatches(p2)
	$.showstartbars=[]
	for(n=0;n<=$.totbars;n++)$.showstartbars[n]=string(n)+ " >"
	$.showsectbutt.setvals($.showstartbars)
	$.showsectbutt.set(1)
	$.showsectbutt.redraw()
	$.showsectbutt.resize()
	$.showstopbars=[]
	for(n=0;n<=$.totbars;n++)$.showstopbars[n]="< " + string(n)
	$.stopsectbutt.setvals($.showstopbars)
	$.stopsectbutt.set($.totbars)
	$.stopsectbutt.redraw()
	$.stopsectbutt.resize()
	$.compplay(p2)

}
method updatepatches (){
	ph = $.ph2.get()
	m=0
	if(sizeof(ph)>0){
		for(n=1;n<=4;n++){
			m++
			p=''
			p = cut(ph,CUT_CHANNEL,n)
			ps=(sizeof(p))
			if(ps > 0){
				patch = $.ph2.patchphrase(m)
				pnum = 1+integer(subbytes(patch,2,1))
				$.chanpatches[n]=pnum
			}
			else {
				m--
				$.chanpatches[n]=1
			}
		}
	}
}
method setpatches (ph){
	if(sizeof(ph)>0){
		ph=ph-cut(ph,CUT_TYPE,PROGRAM)
		for(n=1;n<=4;n++){
			ph |= progchange($.chanpatches[n],n)
		}
	}
	return (ph)
}

method writesmf(){
	p=$.snarf()
	stk=allsysextext(p)
	fname = browsefiles("MIDI File (*.MID)","*.mid",0)
	if ( fname == "" ) {
		print("No file specified")
		return()
	}
	arr = []
	arr[0] = stk
	for ( n=1; n<=4; n++ ) {
		p1 = cut(p,CUT_CHANNEL,n)
		stk= allsysextext(p1)
		p1 = p1-stk
		arr[n]=p1
	}
	midifile(arr,fname)
	$.ph2.setgroupname(fname)
	print(fname+" has been written.")
}
method appendsmf(){
	p=$.snarf()
	stk=allsysextext(p)
	fname = browsefiles("MIDI File (*.MID)","*.mid",0)
	if ( fname == "" ) {
		print("No file specified")
		return()
	}
	arrin = midifile(fname)
	nt = sizeof(arrin)
	pcheck=arrin[0]
	pcheck=onlynotes(pcheck)
	tks=5
	if(sizeof(pcheck)>0)tks=4
	if(nt>tks) {
		print("Too many tracks for SMM file (needs just 4)")
		return()
	}
	ph=''
for ( n=0; n<nt; n++ ) {
		ph |= arrin[n]
	}
	stk1=allsysextext(ph)
	arr = []
	arr[0] = (stk1 + stk)
	for ( n=1; n<=4; n++ ) {
		p1 = cut(p,CUT_CHANNEL,n)
		stk= allsysextext(p1)
		p1 = p1-stk
		arr[n]= (arrin[n] + p1 ) 
	}
	midifile(arr,fname)
	$.ph2.setgroupname(fname)
	print(fname+" has been written.")
}

method dwscadjust(mel,scale,tr,sc) {
	flatArray=[1=1,3=1,5=1,8=1,10=1]
	nmel = sizeof(mel)
	r = ''
	scarr = []
	mscarr = []
	melscale = ''
	lastpitch=0
	if(sc){
		melscale=transpose(SMMscale_melminor(),tr)
		for (nt in melscale)
			mscarr[canonic(nt)] = 1
	}
	for ( nt in scale )
		scarr[canonic(nt)] = 1
	for ( nt in mel ) {
		if ( nt.type & (NOTE|NOTEOFF|NOTEON) ) {
			inc = sign = 1
			if(sc && nt.pitch > lastpitch){
			while ( ! (canonic(nt) in mscarr) ) {
				if(tr in flatArray) nt.pitch -= (sign*inc)
				else nt.pitch += (sign*inc)
				
				inc = inc + 1
				sign = -sign
			}
			}
			else {
			while ( ! (canonic(nt) in scarr) ) {
				if(tr in flatArray) nt.pitch -= (sign*inc)
				else nt.pitch += (sign*inc)
				
				inc = inc + 1
				sign = -sign
			}
			}
		}
		r |= nt
		lastpitch = nt.pitch
	}
	return(r)
}

#Returns current bar length from a read file using a string Time Signature

method tsigbars(thistime) {
	len=sizeof(thistime)
	c=1
	$.compound=0
	nstr=""
	while(nstr != "/"){
		nstr=substr(thistime,c,1)
		c++
	}
	ntstr=substr(thistime,1,c-2)
	barstr=substr(thistime,c,len)
	nv=integer(ntstr)
	bval=integer(barstr)
	
	if(bval==2)notebase=16
		
	else	{
		bx= bval/4
		notebase= 8 / bx
	}
	barlen=nv* notebase * 12
	return (barlen)
}



method allocatesysex(ph){
	majkeysigs = ["0" = 0,"251" = 1,"2" = 2,"253" = 3,"4" = 4,"255" = 5,"6" = 6,"1" = 7,"252" = 8,"3" = 9,"254" = 10,"5" = 11]
	minkeysigs = ["0" = 9,"251" = 10,"2" = 11,"253" = 0,"4" = "1","255" = 2,"6" = 3,"1" = 4,"252" = 5,"3" = 6,"254" = 7,"5" = 8]
	sy=allsysextext(ph)
	ts=tsiginfo2(sy)
	t=0
	if(sizeof(ts)){
		for(t=0;t<sizeof($.timesigs);t++){
			if($.timesigs[t]==ts)break
		}
	}
	if(t>sizeof($.timesigs)-1)t=0
	$.currtsig=t
	$.tsig(t)
	bars=1
	$.holdbars=[]
	$.holdbars[0]=0
	$.smmtsig=timesigsinfo(sy)
	for(nt in $.smmtsig){
		thists=tsiginfo2(nt)
		barlen=$.tsigbars(thists)
		nextt = nexttime($.smmtsig,nt.time)
		# notes at the end of the phrase aren't touched
		if ( nextt >= 0 ) 
			sectlen  = nextt - nt.time
		else 
			sectlen = latest(onlynotes(ph)) - nt.time

		numbars=sectlen/barlen
		for(n=0; n<numbars; n++){
			$.holdbars[bars]=$.holdbars[bars-1]+(barlen/12)
			bars++
		}
	}
	$.barplay=1
	$.barstop = bars-1
	$.totbars = bars-1
	$.resetbarplay()
	$.btime.redraw()
	$.btime.resize()
	k=""
	k=ksinfo2(sy)
	kl=sizeof(k)
	$.currkey=0
	$.scale=0
	if(kl>0){
		b=substr(k,kl,1)
		kl-=2
		d=substr(k,1,kl)
		b=substr(b,1,1)
		c=integer(b)
		$.currkey=majkeysigs[d]
		if(c){
			$.scale=2
			$.currkey=minkeysigs[d]
		}
	}
	$.bscale.set($.scale)
	$.kbutt.set($.currkey)
	$.bscale.redraw()
	$.bscale.resize()
	$.kbutt.redraw()
	$.kbutt.resize()
	ph-=sy
	$.smmtempo=tempoinfo(sy)
#	$.smmtsig=timesigsinfo(sy)
	$.smmksig=keysigsinfo(sy)
	$.smmvol=volumenotes(ph)
	return (ph)

}
	
method reallocatesysex(ph){
	sy=allsysextext(ph)
	ph-=sy
	$.smmtempo=tempoinfo(sy)
	$.smmtsig=timesigsinfo(sy)
	$.smmksig=keysigsinfo(sy)
	$.smmvol=volumenotes(ph)
	return (ph)

}
	

method readfile(mid) {

	if ( nargs() < 1 )
		mid = 1
	if ( mid )
		fname = browsefiles("MIDI File (*.MID)","*.mid",1)
	else
		fname = browsefiles("Key File (*.K)","*.k",1)
	if ( fname == "" ) {
		print("No file specified")
		return()
	}
	if ( ! fileisreadable(fname) ) {
		print("File",fname,"doesn't exist!?")
		return()
	}
	fn = split(fname,"\\/")
	msg = new kmsg("Reading "+fn[sizeof(fn)-1]+" ...")

	msg.resize($.size())
	msg.redraw()

	# We lock the wgroup so that we don't get screwed up by having
	# the wgroup redrawn in the middle of changing the tracks.
	lock($)

	parts = split(fn[sizeof(fn)-1],".")
	suff = parts[1]
	if ( suff == "mid" || suff == "MID" ) {
		arr = midifile(fname)
		nt = sizeof(arr)
		pcheck=arr[0]
		pcheck=onlynotes(pcheck)
		tks=5
		if(sizeof(pcheck)>0)tks=4
		if(nt>tks) {
			print("Too many tracks for SMM file (needs just 4)")
			return()
		}
		ph=''
		for ( n=0; n<nt; n++ ) {
			ph |= arr[n]
		}
	}
	else if ( suff == "k" || suff == "K" ) {
		ph = readkey(fname)
		if ( sizeof(ph) <= 0 ) {
			print("That file's nonexistent or empty!?")
			unlock($)
			return()
		}
	}
	else {
		print("Unrecognized file name type!?")
		unlock($)
		return()
	}
	deleteobject(msg)
	unlock($)
	ph=$.allocatesysex(ph)
	$.tunesource=fname
	$.ph2.setgroupname(fname)
	$.compplay(ph)
}

method setmake(){
	$.makekey=$.currkey
	$.makescale=$.scale
}
method changemakekey1(){
	if($.scale==0)
	{
		if($.makescale==0){
			$.makescale=2
			move=3
			if(rand(2))$.makekey=$.currkey-move
			if($.makekey<0)$.makekey+=12
			if($.makekey>11)$.makekey-=12
		}
		else 	{
			if ($.makescale==2 || $.makescale==1){
				$.makescale=0
				$.makekey=$.currkey
			}
		}
	}	
	if($.scale==1 || $.scale==2)
	{
		if($.makescale==2 || $.makescale==1){
#			$.makescale=0
			move=3
			if(rand(2)){
				$.makekey=$.currkey+move
				$.makescale=0
			}
			if($.makekey<0)$.makekey+=12
			if($.makekey>11)$.makekey-=12
		}
		else 	{
			if ($.makescale==0){
				$.makescale=$.scale
				$.makekey=$.currkey
			}
		}
	}	
}

method chooseharmseq (){
	return (rand(2))
}
 method changemakekey(chosen){
	arr=[]
	arrmax=7
	trans=[0=0,1=5,2=0,3=7,4=9,5=5,6=2,7=11,8=0,9=2,10=4,11=9,12=2,13=7,14=0]
	trans1=[0=0,1=5,2=11,3=4,4=9,5=2,6=7,7=0]
	if(chosen==0)arr=trans
	if(chosen==1)arr=trans1
	max=sizeof(arr)-1
	minors = [2=1,4=1,9=1,11=1]
	move=arr[$.currmove]
	if ($.scale==0 && move in minors) $.makescale=2
	else $.makescale=0
	if (($.scale==1 || $.scale==2) && move in minors) $.makescale=0
	else $.makescale=$.scale
	if(move==2)$.makescale=2
	$.currmove++
	if($.currmove > max) $.currmove=0
	$.makekey=$.currkey+move
	if($.makekey<0)$.makekey+=12
	if($.makekey>11)$.makekey-=12
}
method mychadjust2(p) {
#	trans=[0=0,1=5,2=0,3=7,4=9,5=5,6=2,7=11,8=0,9=2,10=4,11=9,12=2,13=7,14=0]
	trans=[0=0,1=5,2=4,3=9,4=2,5=7,6=0]
#	trans=[0=0,1=5,2=7,3=0, 4=2,5=11,6=0]
	minors = [2=1,4=1,9=1,11=1]
	max=sizeof(trans)-1
	movers=[]
	p1=''
	p1|=p
	p2=''
	pp=""
	for (nt in p1){
		ntime=nt.time
#		npitch=nt.pitch % 60
		npitch=trans[$.currchord]
		rootoct=integer(nt.pitch /12)
#print (rootoct)
		ntch=nt.chan
		x=rand(2)
		fifth=7
		third=4
if($.scale==1 || $.scale==2)third=3
#if($.makescale == 1 || $.makescale == 2) third=3
	move=trans[$.currchord]
	if ($.scale==0 && move in minors) third=3
	if (($.scale==1 || $.scale==2) && move in minors) third=4
	if(move==2){
		third=3
		if($.scale>0)fifth=6
	}
	if(move==11 && $.scale ==0)fifth=6
		if(x==0){
			x2=fifth
			x3=third
		}
		if(x==1){
			x2 = third
			x3 = fifth
		}
		dir=rand(2)
		if(dir)x2-=12
		else	x3-=12
		movers[2]=x2
		movers[3]=x3
		movers[4]=0
		last=rand(3)
		if(last==1)movers[4]=third
		if(last==2)movers[4]=fifth
	
		r = ''
		scl = cut(p1,CUT_TIME,ntime,ntime,INCLUSIVE)
		c=2
		first=1
		for (thisnote in scl){
			if(sizeof(scl)>1 && thisnote.chan != ntch){
				thisoct= integer( thisnote.pitch/12)
				newpitch =(npitch % 12) + movers[c] 
				if(newpitch>11)newpitch-=12
				if(newpitch<0)newpitch+=12
				newpitch +=(thisoct*12) 

				thisnote.pitch = newpitch 
				c++
				if(c>4)c=2
			}
			else if (sizeof(scl)>1 && thisnote.chan == ntch){
				thisnote.pitch=npitch
				thisnote.pitch+=(rootoct*12)	
				$.currchord+=rand(3)+1
				if($.currchord > max)$.currchord=0
				first=0
			}
			r |= thisnote
		}
		p1-=scl
		p2|=r
	}
#print(pp)
	return(p2)
}
method mychadjust4(p) {
#	trans=[0=0,1=5,2=0,3=7,4=9,5=5,6=2,7=11,8=0,9=2,10=4,11=9,12=2,13=7,14=0]
#	trans=[0=0,1=5,2=4,3=9,4=2,5=7]
	trans5=[0=0,1=4,2=5,3=9,4=7]
#	trans=[0=0,1=5,2=7,3=0, 4=2,5=11,6=0]
#	trans5=[0=0,1=4,2=2,3=5,4=9,5=2,6=7]
	minors = [2=1,4=1,9=1,11=1]
	max=sizeof(trans5)-1
	movers=[]
	thischord=[]
	p1=''
	p1=onlynotes(p)
	phold=p-p1
	p2=''
	pp=""
	chords=0
	endt=latest(p1)
	ntime=0
	while(ntime>-1){
		scl = cut(p1,CUT_TIME,ntime,ntime,INCLUSIVE)
		if(sizeof(scl)>1){
			scl=smmattime(scl,ntime) 
			if(sizeof(scl)>1)chords++
		}
		ntime=nexttime(p1,ntime)
	}
	chcount=0
	ntime=0
	sevenx=8
	while(ntime>-1){
		r = ''
		scl = cut(p1,CUT_TIME,ntime,ntime,INCLUSIVE)
		impcad=0
		if(sizeof(scl>1)){
			scl=smmattime(scl,ntime) 
			ntime=nexttime(p1,ntime)
			if(sizeof(scl)>1){
				chcount++
				$.currchord+=rand(2)+1
				if($.currchord > max)$.currchord=rand(3)			
				rsize=7
				fnt=scl%1
				if(fnt.vol==$.vel1)rsize=4
				x=rand(rsize)+1
				if(chcount==chords-1){
					impcad=0
					if(! $.lastpart){
						if($.currchord==max )$.currchord=1 		
#						if($.currchord==2)$.currchord++
						impcad=rand(3)
					}
					if($.firstpart || impcad==0){
						$.currchord=max
						sevenx=rand(3)* 2 + 8
						x=sevenx
					}
				}
				if(chcount==chords){
					if(impcad)$.currchord=max
					else{
						$.currchord=0
						x=sevenx+1
					}
				}				
				thischord=$.smmsetchord()
				movers=thischord[x]	
				for(thisnote in scl){
					thisoct= integer( thisnote.pitch/12)
					d=thisnote.chan
					newpitch = movers[d] 
					newpitch +=(thisoct*12) 
					if(newpitch < 36)newpitch+=12
					if(newpitch > 90)newpitch-=12
					thisnote.pitch = newpitch 
					r |= thisnote
				}
			}
			else r=scl
		}
		else
			r=scl
		p2|=r
	}
	p2|=phold
	return(p2)
}

method smmsetchord () {
#	trans=[0=0,1=5,2=4,3=9,4=2,5=7]
	trans5=[0=0,1=4,2=5,3=9,4=7]
#	trans5=[0=0,1=4,2=2,3=5,4=9,5=2,6=7]
	trans3=[0=0,1=2,2=9,3=11,4=4]
	trans2=[0=0,1=7,2=11,3=5,4=2]
	minors = [2=1,4=1,9=1,11=1]
	if($.hp==0)move=trans5[$.currchord]
	if($.hp==1)move=trans3[$.currchord]
	if($.hp==2)move=trans2[$.currchord]
	root='p60'
	athird='p64'
	afifth='p67'
	aseventh='p70'
	if($.makescale==1 || $.makescale==2)athird='p63'
	if ($.makescale==0 && move in minors) athird='p63'
	if (($.makescale==1 || $.makescale==2) && move > 2 && move in minors ) athird='p64'
		if(move==2){
			athird='p63'
			if($.makescale>0)afifth='p66'
		}
		root.pitch+=move+$.currkey
		afifth.pitch+=move+$.currkey 
		athird.pitch+=move+$.currkey 
		aseventh.pitch+=move+$.currkey 
		root.pitch = root.pitch % 12
		afifth.pitch = afifth.pitch % 12
		athird.pitch = athird.pitch % 12
		aseventh.pitch = aseventh.pitch % 12
	nchords=[
	1=[1=root,2=athird,3=afifth,4=root],
	2=[1=afifth,2=root,3=athird,4=root],
	3=[1=athird,2=root,3=afifth,4=root],
	4=[1=athird,2=afifth,3=root,4=root],
	5=[1=root,2=athird,3=afifth,4=athird],
	6=[1=athird,2=afifth,3=root,4=athird],
	7=[1=afifth,2=athird,3=root,4=afifth],
	8=[1=athird,2=aseventh,3=afifth,4=root],
	9=[1=root,2=athird,3=root,4=root],
	10=[1=aseventh,2=afifth,3=afifth,4=root],
	11=[1=athird,2=root,3=root,4=root],
	12=[1=athird,2=aseventh,3=root,4=root],
	13=[1=root,2=athird,3=afifth,4=root]

]
return (nchords)		

}


method mychadjust3(p) {
#	trans=[0=0,1=5,2=0,3=7,4=9,5=5,6=2,7=11,8=0,9=2,10=4,11=9,12=2,13=7,14=0]
	trans=[0=0,1=5,2=11,3=4,4=9,5=2,6=7,7=0]
#	trans=[0=0,1=5,2=7,3=0, 4=2,5=11,6=0]
	minors = [2=1,4=1,9=1,11=1]
	max=sizeof(trans)-1
	movers=[]
	p1=''
	p1=onlynotes(p)
	phold=p-p1
	p2=''
	pp=""
	for (nt in p1){
		ntime=nt.time
#		npitch=nt.pitch % 60
		npitch=trans[$.currchord]
		rootoct=integer(nt.pitch /12)
#print (rootoct)
		ntch=nt.chan
		dir=rand(2)
		move=trans[$.currchord]
		afifth=7
		athird=4
		if($.makescale==1 || $.makescale==2)athird=3
		if ($.makescale==0 && move in minors) athird=3
		if (($.makescale==1 || $.makescale==2) && move > 2 && move in minors ) athird=4
		if(move==2){
			athird=3
			if($.makescale>0)afifth=6
		}
		if(move==11 && $.makescale ==0)afifth=6
		if(dir){
			fifth=npitch+afifth
			third=npitch+athird
		}
		else {
			fifth=npitch-12+afifth
			third=npitch-12+athird
		}
		x=rand(8)
		y=rand(3)+1
		if(x<4){
			movers[1]=npitch
			if(y>2)movers[1]=third
			movers[2]=npitch
			if(movers[1]==npitch){
				movers[2]=third
				if(y>2)movers[2]=fifth
			}
			movers[3]=third
			if(movers[2]==third && x >1)movers[3]=fifth
			movers[4]=npitch
		}
		if(x>3 && x < 7){
			movers[1]=npitch
			movers[2]=third
			movers[3]=fifth
			if(x <5 )movers[3]=npitch
			movers[4]=third		
		}
		if(x>6){
			movers[1]=fifth
			if(y<3)movers[2]=npitch
			else movers[2]=third
			movers[3]=third
			if(movers[2]==third )movers[3]=npitch
			movers[4]=fifth
		}
pdiff=(60+movers[1])-(60+movers[2])
if(abs(pdiff) >14){
	if(movers[1]>movers[2])movers[1]-=12
	else(movers[2]-=12)
}
pdiff=(60+movers[3])-(60+movers[4])
if(abs(pdiff)>14){
	if(movers[4]<movers[3])movers[4]-=12
	else(movers[3]-=12)
}
		r = ''
		scl = cut(p1,CUT_TIME,ntime,ntime,INCLUSIVE)
		for (thisnote in scl){
			if(sizeof(scl)>1){
				thisoct= integer( thisnote.pitch/12)
				d=thisnote.chan
				newpitch = movers[d] 
#				if(newpitch>9)newpitch-=12
#				if(newpitch<0)newpitch+=12
				newpitch +=(thisoct*12) 
#				if(d<3)newpitch+=60
#				if(d==3)newpitch+=48
#				if(d==4)newpitch+=36
if(newpitch < 36)newpitch+=12
if(newpitch > 90)newpitch-=12
				thisnote.pitch = newpitch 

			if (thisnote.chan == ntch){
				$.currchord+=rand(3)+1
					if($.currchord > max)$.currchord=0
				}
			}
			r |= thisnote
		}
		p1-=scl
		p2|=r
	}
#print(pp)
	p2|=phold
	return(p2)
}

method nojumps(p){
pnotes=onlynotes(p)
phold=p-pnotes
p1=''
r=''
for (n=1; n<5; n++){
	p1=cut(pnotes,CUT_CHANNEL,n)
	p2=''
	ncount=0
	ntlast=''
	ntlast.time=0
	for (nt in p1){
		max=9
		if(ncount){
			if(nt.time-ntlast.time < $.barlen*12*2){
				if(nt.chan==4)max=12
				while(abs(nt.pitch-ntlast.pitch)>max){
					if(nt.pitch>ntlast.pitch)nt.pitch-=12
					else nt.pitch+=12
				}
			}
		}
	p2|=nt
	ncount++
	ntlast=nt
	}
	r|=p2
}
r|=phold
return (r)
}


} #end of class



