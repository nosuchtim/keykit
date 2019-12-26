# Written by David Woolls, davidwoolls@copycatch.freeserve.co.uk

class wbargen3 { 
	method init { 
	$.w = new window() 
	$.inherit($.w) 
	$.scale=0
	$.sig=44
	$.gens=1
	$.currkey=0
	$.nbrMeasures=4
	$.barlen=32
	$.fullstring = ""
	$.fullmel=" "
	$.thetune= " "
	$.notesValue=0
	$.sumvalue=0
	$.notebase=8
	$.first=1
	$.checkstr=""
	$.thestring = ""
	$.holdtsig="4/4"
	$.temp1=500000
	$.compound=0;
	$.lastpart=0
	$.bgen=0
	$.onauto=0
	$.lastnote=0
$.keys = [0 = "C",1 = "C#",2 = "D",3 = "D#",4 = "E",5 = "F",6 = "F#",7 = "G",8 = "G#",9 = "A",10 = "A#",11 = "B"]
	$.majorArray = [0="p55",1="p57",2="p59",3="p60",4="p62", 5="p64",6="p65",7="p67",8="p69",9="p71",10="p72",11="p74",12="p76"]
	$.minorArray = [0="p55",1="p56",2="p59",3="p60",4="p62", 5="p63",6="p65",7="p67",8="p68",9="p71",10="p72",11="p74",12="p75"]
	$.chromArray = [0="p57",1="p58",2="p59",3="p60",4="p61", 5="p62",6="p63",7="p64",8="p65",9="p66",10="p67",11="p68",12="p69",13="p70",14="p71",15="p72"]

	$.pentArray = [0="p61",1="p63",2="p66",3="p68",4="p70"]
	$.barArray = [0="4",1="8",2="12",3="16",4="20",5="24",6="32"]
	$.timesigs=[0="4/4",1="3/4",2="2/4",3="6/8",4="9/8",5="12/8",6="2/2",7="3/2",8="4/2",9="6/4",10="9/4",11="12/4",12="2/8",13="3/8",14="4/8",15="6/16",16="9/16",17="12/16",18="5/4",19="7/4",20="5/8",21="7/8"]
	$.vol1=65

vols = []
	for ( n=0; n<128; n++ )
		vols[n] = string(n)
	$.bvol1 = new kvalbutton(vols,$,"vol1changed")
	$.vol2=60
	$.bvol2 = new kvalbutton(vols,$,"vol2changed")
	$.bpm1=12
$.tempi = []
	for ( n=0; n<41; n++ )
		$.tempi[n] = string(((n+8)*5))
	$.bbpm1 = new kvalbutton($.tempi,$,"bpm1changed")
	$.tempphr1= temponote(tempo())

	octs = []
	for ( n=0; n<7; n++ )
		octs[n] = string(n)
	$.oct=0
	$.octoffset = 3
	$.sections = 12
	$.octbutton = new kvalbutton(octs,$,"octchanged")
	$.octtext = new ktext("Oct")
	$.scaletext = new ktext("Oct")
	$.barstext = new ktext("Bars")
	$.keytext = new ktext("Key")
	$.scadjtext = new ktext("AdjK")
	$.transtext = new ktext("MoveK")
	$.bpm1text = new ktext("Bpm ")
	$.vol1text = new ktext("Beat")
	$.vol2text = new ktext("Off")
	$.volumetext = new ktext("Volume")
	$.sectiontext = new ktext("Sections")
	$.title = new ktext("Structured Melody Maker")
#	$.title.style(NOBORDER)

	$.scaletext.style(NOBORDER)
	$.barstext.style(NOBORDER)
	$.keytext.style(NOBORDER)
	$.octtext.style(NOBORDER)
#	$.scadjtext.style(NOBORDER)
#	$.transtext.style(NOBORDER)



	$.ph1 = new wphrase()  # holds original

	$.ph2 = new wphrase()  # holds current display
	$.isset = 0
	$.stoptids = []
	$.snarfbutt = new kbutton("Segment",$,"gentype1")
	$.autobutt = new kbutton("AutoGen",$,"dobeatv3")
	$.varbutt = new kbutton("Variation",$,"dobeatv2")
	$.savebutt = new kbutton("Save",$,"writesmf")
	$.appbutt = new kbutton("Append",$,"appendsmf")

	$.ntnames3 = [2="s",3="s.",4="e",6="e.",8="q",12="q.",16="h",24="h."]
	$.btime = new kvalbutton($.timesigs,$,"tsig")
	$.bgens = new kvalbutton([0="Melody", 1="2 Lines", 2="3 Lines",3="4 Lines"], $,"setGens")
$.kbutt = new kvalbutton($.keys,$,"keychanged")
$.scabutt = new kvalbutton($.keys,$,"movescale")
$.transbutt = new kvalbutton($.keys,$,"movekey")
	$.makesect = new kvalbutton([0="4", 1="8", 2="10",3="12",4="16",5="20"], $,"setSects")

	$.bscale = new kvalbutton([0="Major", 1="Minor", 2="Pentatonic", 3="Chromatic"], $,"setScale")
	$.bgtype = new kvalbutton([0="Improv",1="Triads",2="Mix Chords",3="Strong Chords"],$,"bgchanged")
	$.bbars = new kvalbutton($.barArray,$,"setNumBars")
			$.addchild($.ph2)
			$.addchild($.snarfbutt)
			$.addchild($.autobutt)
			$.addchild($.btime)
			$.addchild($.bbars)
			$.addchild($.bscale)
			$.addchild($.bgens)
			$.addchild($.kbutt)
			$.addchild($.scabutt)
			$.addchild($.transbutt)
	$.addchild($.octbutton)
	$.addchild($.title)
	$.addchild($.bgtype)
	$.addchild($.savebutt)
	$.addchild($.appbutt)
	$.addchild($.varbutt)

	$.addchild($.scaletext)
	$.addchild($.barstext)
	$.addchild($.keytext)
	$.addchild($.octtext)
	$.addchild($.scadjtext)
	$.addchild($.transtext)
	$.addchild($.bpm1text)
	$.addchild($.volumetext)
	$.addchild($.sectiontext)
	$.addchild($.vol1text)
	$.addchild($.vol2text)
	$.addchild($.bbpm1)
	$.addchild($.makesect)
	$.addchild($.bvol1)
	$.addchild($.bvol2)
	$.octbutton.set($.octoffset)
	$.bbpm1.set($.bpm1)
	$.bvol1.set($.vol1)
	$.bvol2.set($.vol2)
	$.makesect.set(3)
	        } 


method redraw {
	$.w.redraw()
	methodbroadcast();
#	$.w.text("Structured Melody maker",
#		xy($.xmin(),$.ymin(),$.xmax(),$.ymin()+$.textheight()+4))
#	xm = ($.xmax()-$.xmin())/4
#	tw = $.textwidth() * 3
#	t=$.textheight() + 4
#	$.kbutt.resize(xy($.xmax()-xm +tw, $.ymin()+1+t,$.xmax()-1, $.ymin() + (t*2)))
#	$.tbutt.resize(xy($.xmax()-xm +tw , $.ymin()+1+t + t,$.xmax()-1, $.ymin()+ (t*3)))
}
method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	dx = ($.xmax()-$.xmin()) / 11
	y0 = $.ymin()+2
	y0aa = $.ymin() + $.textheight() + 4
	y0a = $.ymin() + 2*$.textheight() + 6
	y0b = $.ymin() + 3*$.textheight() + 8
	y0c = $.ymin() + 4*$.textheight() + 10
	y0d = $.ymin() + 5*$.textheight() + 12
	x0 = $.xmin() + 2
	x1 = $.xmax() - 2
	y1 = $.ymax() - 2
#line 1
	$.title.resize(xy($.xmin(),$.ymin(),$.xmax(),$.ymin()+$.textheight()+4))
#line2
	$.btime.resize(xy(x0,y0aa+1,x0+2*dx-1,y0a-1))
	$.octtext.resize(xy(x0+2*dx+1,y0aa+1,x0+3*dx-1,y0a-1))
	$.bpm1text.resize(xy(x0+3*dx+3,y0aa+1,x0+4*dx-1,y0a-1))
	$.bbpm1.resize(xy(x0+4*dx+3,y0aa+1,x0+5*dx-1,y0a-1))
	$.bgtype.resize(xy(x0+5*dx+4,y0aa+1,x0+7*dx-1,y0a-1))
	$.savebutt.resize(xy(x0+7*dx+3,y0aa+1,x0+9*dx-2,y0a-1))
	$.scadjtext.resize(xy(x0+9*dx+1,y0aa+1,x0+10*dx-2,y0a-1))
	$.scabutt.resize(xy(x0+10*dx+1,y0aa+1,x0+11*dx-2,y0a-1))

#line#3
	bx0 = x0
	bx1 = x0+7*dx
	dbx = (bx1-bx0)/8

	$.bscale.resize(xy(x0+0*dx+1,y0a+1,x0+2*dx-1,y0b))
	$.octbutton.resize(xy(x0+2*dx+1,y0a+1,x0+3*dx-1,y0b))
	$.volumetext.resize(xy(x0+3*dx+2,y0a+1,x0+5*dx-1,y0b))
	$.snarfbutt.resize(xy(x0+5*dx+4,y0a+1,x0+7*dx-1,y0b))
	$.appbutt.resize(xy(x0+7*dx+3,y0a+1,x0+9*dx-2,y0b))
	$.transtext.resize(xy(x0+9*dx+1,y0a+1,x0+10*dx-2,y0b))
	$.transbutt.resize(xy(x0+10*dx+1,y0a+1,x0+11*dx-2,y0b))
#line#4
	$.bgens.resize(xy(bx0+0*dx+1,y0b+1,bx0+2*dx-1,y0c))
	$.keytext.resize(xy(bx0+2*dx+1,y0b+1,bx0+3*dx-1,y0c))
#	$.bbpm2.resize(xy(bx0+3*dx+3,y0b+1,bx0+4*dx-1,y0c))
	$.vol1text.resize(xy(bx0+3*dx+2,y0b+1,bx0+4*dx-1,y0c))
	$.bvol1.resize(xy(bx0+4*dx+1,y0b+1,bx0+5*dx-1,y0c))
	$.varbutt.resize(xy(bx0+5*dx+3,y0b+1,bx0+7*dx-1,y0c))
#	$.tbarbutt1.resize(xy(bx0+4*dx+3,y0b+1,bx0+5*dx-1,y0c))

#line#5
	$.barstext.resize(xy(bx0+0*dx+1,y0c+1,bx0+1*dx-1,y0d))

	$.bbars.resize(xy(bx0+1*dx+1,y0c+1,bx0+2*dx-1,y0d))
	$.kbutt.resize(xy(bx0+2*dx+1,y0c+1,bx0+3*dx-1,y0d))
	$.vol2text.resize(xy(bx0+3*dx+2,y0c+1,bx0+4*dx-1,y0d))
	$.bvol2.resize(xy(bx0+4*dx+1,y0c+1,bx0+5*dx-1,y0d))

#	$.bbpm3.resize(xy(bx0+3*dx+3,y0c+1,bx0+4*dx-1,y0d))
#	$.tbarbutt2.resize(xy(bx0+4*dx+3,y0c+1,bx0+5*dx-1,y0d))
	$.autobutt.resize(xy(bx0+5*dx+3,y0c+1,bx0+7*dx-2,y0d))
	$.sectiontext.resize(xy(bx0+9*dx+1,y0c+1,bx0+10*dx-2,y0d))
	$.makesect.resize(xy(bx0+10*dx+1,y0c+1,bx0+11*dx-2,y0d))

#phrase window
	$.ph2.resize(xy(x0,y0d+2,x1,y1))

}

method delete {
	killtids($.stoptids)
	$.stoptids = []
}

method get {
	return($.ph2.get())
}
method play (stime) {
	if ( $.ph2.isplaying() )
		$.stop()
	if ( nargs() < 1 ) {
		stime = nextquant(Now,1b)
	}
	tid = $.ph2.play(stime,1b)
	$.stoptids[tid] = 1
}
method stop {
	killtids($.stoptids)
	$.stoptids = []
	$.ph2.stop()
}
method mousedown (m) {
	if ( $.ph2.contains(m) ) {
		if ($.ph2.isplaying() )
			$.stop()
		else {
			tid = $.ph2.play(nextquant(Now,1b))
			$.stoptids[tid] = 1
		}
	}
	else {
		mouseforward(m,"mousedown")
	}
}
method snarf { Snarf = $.ph2.get() }

method keychanged (v)  { $.currkey=v }

method octchanged (v) {	$.oct = v - $.octoffset }
method bpm1changed (v) {
	$.bpm1 = v 
	t=integer($.tempi[v])
	$.temp1=(1000000/((float(t)/60)))
	
	$.tempphr1=temponote($.temp1)
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
method vol1changed (v) {$.vol1 = v }
method vol2changed (v) {$.vol2 = v }
method bgchanged (v) {$.bgen = v }

method movescale (v) {
	tr= v - $.currkey
	p1=$.ph1.get()
	if($.scale == 1)p1=scadjust(p1,transpose(scale_aeolian(),tr))
	else	p1=scadjust(p1,transpose(scale_ionian(),tr))
	$.ph2.set(p1,0)
	$.ph2.fitall()
	$.ph2.redraw()
	$.snarf(p1)
	$.play()
}

method movekey (v) {
	tr= v - $.currkey 
	p1=$.ph1.get()
	p1 = transpose(p1,tr)
	$.ph2.set(p1,0)
	$.ph2.fitall()
	$.ph2.redraw()
	$.snarf(p1)
	$.play()
}


#picks up from the Time Signature
method tsig(t) {
	$.btime.set(t)
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
	if($.compound && $.notebase == 4) $.notebase=12
	if($.compound && $.notebase == 2) $.notebase=6
}

#picks up from the Scale button
method setScale(sc){
	$.bscale.set(sc)
	$.scale = sc
}

#picks up number of parallel generations to do from the Gen button
method setGens(g){$.gens=g+1}

method setSects(g){
if(g==0)$.sections = 4
if(g==1)$.sections = 8
if(g==2)$.sections = 10
if(g==3)$.sections = 12
if(g==4)$.sections = 16
if(g==5)$.sections = 20
}

method gentype1 (){
	p=$.dobeatv1($.bgen+1)
	$.compplay(p)
}
method gentype (){
onauto=1
phr = ''
p=$.dobeatv1(3)
#p=cmd_removerand(p,4)
p1=$.dobeatv1(1)
p2=$.dobeatv1(3)
p3=$.dobeatv1(1)
p4=$.dobeatv1(2)
trup=rand(4)
if(trup == 1) p1t=transpose(p1,2)
if(trup == 2) p1t=transpose(p1,4)
if(trup == 3) p1t=transpose(p1,7)

phr+=p
phr+=p1
if(trup)phr+=p1t
if(trup==3){
	p1t2=transpose(p1,2)
	phr+=p1t2
}
else phr+=p1
#p4=cmd_removerand(p4,4)
phr+=p4
phr+=p
phr+=p3
phr+=p2
onauto=0
$.compplay(phr)
}
# Controls the number of generations and applies chord and scale adjustments
method dobeatv1(v) {
	offset=$.oct
min = $.gens-$.octoffset
min++
p1=''
#	offset++
	if($.gens >1){
		offset++
		if(offset>4)offset=4
		
		if($.oct<-1 && ($.gens + $.oct) <= min) offset= min -1

	}
	howmany=0

	offset--
	s= $.CompBeat(howmany)
	p1= phrase(s)
	pc=p1
	p1= transpose(p1,$.currkey + (offset*12)) 
	howmany++
	p1.chan=howmany
#	pc=p1
	while(howmany < $.gens){
		p=''
		if(howmany>1)offset--
		if(v==1){
			s= $.CompBeat(howmany)
			p= phrase(s)
			p= transpose(p,$.currkey + (offset*12)) 
			if(howmany==2){
				pc=p
				v=5
			}
		}
		if($.scale != 2 && howmany >0){
		      if(v == 2 || v ==3) p= transpose(pc,$.currkey + (offset*12)) 
			if(v == 4) p= transpose(p1,$.currkey + (offset*12)) 
			if(v == 5) p=pc
			r= ''
			if(v==2)tr=rand(3)
			for(nt in p){
				ch = 0
				if(v!=2)tr=rand(4)
				if(tr == 1)ch=7
				if(tr == 3)ch=5
				if(tr == 2  && $.scale != 1)ch=4
				else
				if(tr == 2)ch=3

				if(v >0)nt =transpose(nt,ch)
			r |= nt
			}
		p = r
		}
		howmany++ 
		p.chan=howmany
#		p |= progchange(12,howmany);
		p1 |= p
		
	}
	
#	print(s) 
#	out=printf("\n %s \n %s ", $.fullmel , $.fullstring)
#	print (out)
	if(howmany > 1){
		if($.scale==0){
			p1 = scadjust(p1,transpose(scale_ionian(),$.currkey))
			p1 = scafilt(p1, transpose(scale_ionian(),$.currkey))
		}
		if($.scale==1){
			p1 = scadjust(p1, transpose(scale_aeolian(),$.currkey))
			p1 = scafilt(p1, transpose(scale_aeolian(),$.currkey))
		}
	}	
		p2 = phrase("'\"Timesig="+$.holdtsig+",24,8\"   \"Tempo=" + string($.temp1)+"\"'")
# print (p2)
#	p1=''
#	p1+=$.tempphr1
p1|=p2
#p1=cmd_removerand(p1,4)

return (p1)
}

method compplay(p1){
	$.ph1.set(p1,0)
	$.ph2.set(p1,0)
	$.ph2.fitall()
	$.ph2.redraw()
	$.snarf(p1)
	$.play()

}



#picks up from the Bars menu
method setNumBars(b){
	$.bbars.set(b)
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
$.notebase=8
$.first=1
$.thestring = ""
maxbeat = $.barlen
if(howmany+1 == $.sections)$.lastpart=1
# make sure you don't go outside the bar limit for note length
minbeat = 2 #sixteenth notes at present
beatval = 0
mult=1.0
newbar=1
maxbeat++ #increment for rand purposes
picknote=0
# repeat for the number of measures required set at 4 at present
for (count=0; count< $.nbrMeasures; count++) {
	if($.lastpart && count+1 == $.nbrMeasures)minbeat=8
	$.sumvalue = $.barlen  #start with a full bar
	$.notesvalue = 0  #count the other way as well
	newbar=1
	while ($.sumvalue >= minbeat) {
		if(howmany>3)beatval=$.notebase
		thebeat = 1000
		while(thebeat >maxbeat)thebeat=rand(1000)
		beatval = thebeat #choose a value
		mnv=$.notesvalue
		mnb=$.notebase
		modbit = mnv  % mnb 
#deal with simple or compound time differently
		if($.notebase==12){
			picknote = rand(3)+1
			if(modbit==10)beatval=2
			else
			if(modbit % 2 == 0)beatval=picknote*2
					
		}
		if( $.notebase==6){
			if(modbit == 2)beatval=2
		}
		if($.notebase==8  || $.notebase == 16){
			if(modbit==2){
				picknote = rand(4)+1
				beatval=picknote*2
			}
			if(modbit==4){
				picknote = rand(3)+1
				beatval=picknote*2
			}
			if(modbit==6){
				beatval=2
			}
		}
	# tidy up remainders
		if ($.sumvalue==4) beatval=4
		if ($.sumvalue==3) beatval=3
		if( beatval <= $.sumvalue){
			if (mnv % mnb ==0 ){
				if( beatval==2 ){
					holdbv=beatval
					bt=rand(100)
					if(howmany>3 || bt <80){
						beatval=$.notebase
					}
					hm=$.notebase / beatval
					for(nn = 0; nn <hm; nn++) {
						if(hm>1 && nn<hm-1 && bt < 90){
							beatval=holdbv*2
							nn++
						}
						newbar = $.MakeCompBeat(beatval,newbar,1)
						beatval=holdbv
						bt=rand(100)
					}
				}
				else
					{newbar = $.MakeCompBeat(beatval,newbar,0)
				}
			}
			else
				{newbar = $.MakeCompBeat(beatval,newbar,0) 
			}
		}
	}
	$.fullmel+=$.thetune  # the melody so far
	$.fullstring+=$.thestring  # the rhythm so far	
	$.thestring=""  #clear for next bar
	$.thetune=""
}
kp=$.kphrase()  # turn it into a .k phrase
return (kp)
}

# Allocate notes 
method MakeCompBeat(beatval,newbar,multi)
{
# allowed regular
	thisnote = " ";
	tnote=  " ";
        made = 1;
#	if(! $.compound && beatval==3)made=0  #only allow in compound time
	if(beatval==3)made=0  #only allow in compound time
	if($.compound && beatval==16)made=0	  # disallow in compound time
	if(made){
		if( beatval in $.ntnames3){thisnote=$.ntnames3[beatval]}
		else made = 0
	}
 	if (made ) {
		if($.notebase == 12 && $.notesvalue % 12 == 0 )newbar=1  #uppercase beat
		if($.notebase == 8 && $.notesvalue % 8 == 0 )newbar=1
		
		$.sumvalue -= beatval  #decrement bar length
		$.notesvalue += beatval  # increment note value in this bar
 		if(newbar) {thisnote = $.UpperFirst(thisnote,newbar)}
		$.thestring +=  thisnote
	$.checkstr+=thisnote
		$.thetune+=$.MakeCompTune(newbar, multi,beatval);
		$.first=0  
		if(newbar)newbar=0
		# Catch tricky divisions and force repeat choice
		if($.compound == 1 && $.notesvalue<12 && beatval == 2){
			$.thestring+="s "
			$.sumvalue-=2
			$.notesvalue+=2
			$.thetune+=$.MakeCompTune(newbar,multi,beatval)
		}
		if($.compound ==1 && $.notesvalue<12 && beatval == 3){
			$.thestring+="s. "
			$.sumvalue-=3
			$.notesvalue+=3
			$.thetune+=$.MakeCompTune(newbar,multi,beatval)
		}
	}
	return (newbar)
#	return ($.thestring + "  " + $.thetune)
}


#Pick a note from the appropriate scale
method MakeCompTune(newbar,multi,beatval){
		note=17
		if($.scale<2){
			if(multi || beatval <5){
				near=rand(2)+1
				dir=rand(2)
				if(dir){
					note=$.lastnote+near
					if(note  >12 )note=12
					}
					
				else {
					note=$.lastnote-near 
					if(note < 0)note=0
				}
			}
			else {
				while(note>12)note = rand(70)
				if (abs($.lastnote-note)>5){
					note = $.lastnote + note- 5
					if(note>12)note=12
					if(note<0)note=0
					}
			}
		}
		if($.scale==2) note=rand(5)
		if($.scale==3) {while(note>15)note = rand(70)}
		start =rand(7)
		if(start >0 || start < 6 )start=3
		if($.scale==0){
			if($.first){  # force C or G
			anote = $.majorArray[start]
			$.lastnote=start
			}
			else {
			anote = $.majorArray[note]
			$.lastnote=note
			}
		}
		if($.scale==1){
			if($.first){  # force C or G
			anote = $.minorArray[start]
			$.lastnote=start
			}
			else {
			anote = $.minorArray[note]
			$.lastnote=note
			}
		}
		if($.scale==2){
			note = rand(5)
			anote = $.pentArray[note]
		$.lastnote = note
		}
		if($.scale==3){
			anote = $.chromArray[note]
		$.lastnote = note
		}
		# emphasise beat at start or in middle
#		if(newbar) {anote = $.UpperFirst(anote,newbar);}
		$.thetune +=  anote;
		$.checkstr+=anote;
# 		if($.scale ==3){
#			sharp = rand(5);
#			if (sharp > 3) $.thetune += "#";
#       			$.thetune += " ";
#		}
}

#Transform result into .k file
method kphrase(){
#fullstring="QeeQssss HE.sq Qs.s.sEeq"
#fullmel="CegGbagf g#d#ce GedcGec"
noteString = ""  # store notes
volString=""	#store volume
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
		volString+=string(vol)
	}
	vol=0;
	note =- 1
	#volume is allocated on case 
	if( c== "S"){
		vol=1
		note=0
		}
	if( c== "s")note=0
	if( c== "E"){
		vol=1
		note=2
		}
	if( c== "e")note=2
	if( c== "Q"){
		vol=1
		note=4
		}
	if( c== "q")note=4
	if( c== "H"){
		vol=1
		note=6
		}
	if( c== "h")note=6
	
}
#pick up the last note
#if(note >= 0){
	noteString +=string(note)
	volString+=string(vol)
#}

#now work out the melody line
len=sizeof($.fullmel)+1
for (i = 1; i < len; i++){
	c=substr($.fullmel,i,1) 	
	if(c != " "){
#		c = $.switchCase(c,0)  #we want lower
#		if(i < len) {
#			i++;
#			d=substr($.fullmel,i,1) 	
#			if(d=="#")c=$.switchCase(c,1)  #upper signals sharp
#			else i--
#		}
	mel+=c
	}
}
len=sizeof(mel)/3 + 1
lastvol=0
lastdur=0
temposplit=0
#Stick it all together
j=1
for (i = 1; i < len; i++){
	if(i>1) {kpString +=","	}
#	rest=rand(40)
#	if(rest<10)d="r"
#	else {
		c=substr(mel,j,3) j+=3	
#		d=$.CheckSharp(c)  #is it upper case?  This lowers it and adds the symbol
#	}
	kpString += c
#	kpString += d
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
	c=substr(volString,i,1) 	
	#avoid repeat volume
	if(c !=lastvol){
		kpString+="v"
	
		if(c=="0")kpString += string($.vol2) #off beat
		else kpString += string($.vol1)  #on beat
	}
	lastvol=c
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

# Controls the number of generations and applies chord and scale adjustments
method dobeatv2() {
	rand(-Now)
	$.lastpart=0
	offset = 0
	$.gens=4
#	$.nbrMeasures=4
#	$.sections=12
	howmany=0
	trp=0
	chphr = []
	holdfull = []
	lastplay=0
	pickphr = 0
#	picktimesig=2000
#	while(picktimesig > 20)picktimesig = rand(200)
#	$.tsig(picktimesig)
	pp=''
ppc=''
	for (n=0;n<6;n++){
		s= $.CompBeat(n)
		p1= phrase(s)
		chphr[n]= p1
ppc=p1
ppc.chan=n+1
pp|=ppc
	}
	arr=[]
arr[0]=pp
midifile(arr,"CompBeats.mid")
	p2=''
	prepeat=51
	while(howmany < $.sections){
		if(howmany+1==$.sections)$.lastpart=1
		p4=''
		p=''
		offset=0
		v=100
		multiphr=1
		while(v > 10)v=rand(1000)
		if(v==0)p=chphr[0]
		if(v==2)tr=rand(4)
		if(howmany >0){
			prepeat=rand(1000)+1
		}
		p4=''
		if($.lastpart)prepeat=51
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
			p4=$.dobeatv1(1)
		}
		if(prepeat >900){
				if(howmany<2)p4=holdfull[0]
				else p4=holdfull[1]
				if(! $.lastpart){
					trp=rand(25)
					if(trp == 1) p4=transpose(p4,2)
					if(trp == 2) p4=transpose(p4,4)
					if(trp == 3) p4=transpose(p4,7)
					if(trp == 16) p4=reverse(p4)
					if(trp == 22) p4=flip(p4)
					if(trp == 12) p4=flip(reverse(p4))
				}
				multiphr=0
		}
		if(prepeat> 49 && prepeat <801){
			for (n=0;n<4;n++){
				if (n>1)offset-
				if($.lastpart)pickphr=rand(3)+3								else
				pickphr=rand(7)-1
				if(pickphr==-1)p=''
				else{
				p= transpose(chphr[pickphr],$.currkey + (offset*12))					switch=rand(6)
#				if(switch == 3) p=reverse(p)
#				if(switch == 4) p=flip(p)
#				if(switch == 5) p=flip(reverse(p))

				}
				r= ''
				for(nt in p){
					ch = 0
					if(v!=2)tr=rand(25)
					if(tr == 1)ch=7
					if(tr == 3)ch=5
					if(tr == 2  && $.scale != 1)ch=4
					else
					if(tr == 2)ch=3

					if(ch >0)nt =transpose(nt,ch)
					r |= nt
				}
				p = r
			p.chan=n+1
			p4 |= p
			}
		}
		if(howmany==0)holdfull[0]=p4
		else holdfull[1]=p4
		p2+=p4
		howmany++ 
		
	}
	
#	print(s) 
#	out=printf("\n %s \n %s ", $.fullmel , $.fullstring)
#	print (out)
		if($.scale==0){
			p2 = scadjust(p2,transpose(scale_ionian(),$.currkey))
			p2 = scafilt(p2, transpose(scale_ionian(),$.currkey))
		}
		if($.scale==1){
			p2 = scadjust(p2, transpose(scale_aeolian(),$.currkey))
			p2 = scafilt(p2, transpose(scale_aeolian(),$.currkey))
		}
		p3 = phrase("'\"Timesig="+$.holdtsig+",24,8\"   \"Tempo=" + string($.temp1)+"\"'")
# print (p3)
#	p1=''
#	p1+=$.tempphr1
p2|=p3
#p1=cmd_removerand(p1,4)
$.compplay(p2)

#return (p1)
}


# Controls the number of generations and applies chord and scale adjustments
method dobeatv3() {
	rand(-Now)
	starttime=Now
	$.lastpart=0
	offset = 0
	$.gens=4
	if($.nbrMeasures > 8)$.nbrMeasures=8
#	$.nbrMeasures=4
#	$.sections=12
	howmany=0
	trp=0
	chphr = []
	holdfull = []
	lastplay=0
	pickphr = 0
	p2=''
	prepeat=51
	currbar=0
	while(howmany < $.sections){
		p4=''
		p=''
		offset=0
		v=100
		multiphr=1
		newts=rand(15)
		if(newts < 8){
			picktimesig=2000
			while(picktimesig > 20)picktimesig = rand(200)
			$.tsig(picktimesig)
		}
		p3 = phrase("'\"Timesig="+$.holdtsig+",24,8\"   \"Tempo=" + string($.temp1)+"\"'")
		p3.time=currbar
if(howmany && newts>7)p3=''
		currbar += $.nbrMeasures * $.barlen * 12
		for (n=0;n<6;n++){
			s= $.CompBeat(n)
			p1= phrase(s)
			chphr[n]= p1
		}
		while(v > 10)v=rand(1000)
		if(v==0)p=chphr[0]
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
			p4=$.dobeatv1(whch)
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
					if(trp == 19) p4=flip(p4)
					if(trp == 23) p4=flip(reverse(p4))
				}
				multiphr=0
		}
		if(prepeat> 49 && prepeat <801){
			for (n=0;n<4;n++){
				if (n>1)offset--
				pickphr=rand(7)-1
				if(pickphr==-1)p=''
				else{
				p= transpose(chphr[pickphr],$.currkey + (offset*12))					switch=rand(25)
				if(switch == 13) p=reverse(p)
				if(switch == 4) p=flip(p)
				if(switch == 17) p=flip(reverse(p))

				}
			
				r= ''
				for(nt in p){
					ch = 0
					if(v!=2)tr=rand(25)
					if(tr == 1)ch=7
					if(tr == 3)ch=5
					if(tr == 2  && $.scale != 1)ch=4
					else
					if(tr == 2)ch=3

					if(ch >0)nt =transpose(nt,ch)
					r |= nt
				}
				p = r
			p.chan=n+1
			p4 |= p
			}
		}
		if(howmany==0)holdfull[0]=p4
		else holdfull[1]=p4
		p2+=p4
		if(prepeat <801 || prepeat >900)p2|=p3
		howmany++ 
		
	}
	
#	print(s) 
#	out=printf("\n %s \n %s ", $.fullmel , $.fullstring)
#	print (out)
		if($.scale==0){
			p2 = scadjust(p2,transpose(scale_ionian(),$.currkey))
			p2 = scafilt(p2, transpose(scale_ionian(),$.currkey))
		}
		if($.scale==1){
			p2 = scadjust(p2, transpose(scale_aeolian(),$.currkey))
			p2 = scafilt(p2, transpose(scale_aeolian(),$.currkey))
		}
 print (p3)
#	p1=''
#	p1+=$.tempphr1
#p1=cmd_removerand(p1,4)
$.compplay(p2)

#return (p1)
}


method writesmf() {
	p=$.ph2.get()
	fname = browsefiles("MIDI File (*.MID)","*.mid",0)
	if ( fname == "" ) {
		print("No file specified")
		return()
	}
	arr = []
	arr[0] = p
	midifile(arr,fname)
	print(fname+" has been written.")
}
method appendsmf() {
	p=$.ph2.get()
	fname = browsefiles("MIDI File (*.MID)","*.mid",1)
	if ( fname == "" ) {
		print("No file specified")
		return()
	}
	if ( ! fileisreadable(fname) ) {
		print("File",fname,"doesn't exist!?")
		return()
	}
	fn = split(fname,"\\/")
#		msg = new kmsg("Reading "+fn[sizeof(fn)-1]+" ...")
		parts = split(fn[sizeof(fn)-1],".")
		suff = parts[1]
		p1=''
		if ( suff == "mid" || suff == "MID" ) {
			arr1 = midifile(fname)
			nt = sizeof(arr1)
			for ( n=0; n<nt; n++ ) {
				p2 = arr1[n]
				p1 |= p2
			}
		}
		p1+=p
	arr = []
	arr[0] = p1
	midifile(arr,fname)
	print(fname+" has been written.")
}


} #end of class


