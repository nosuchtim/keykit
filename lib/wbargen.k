# Written by David Woolls, davidwoolls@copycatch.freeserve.co.uk

class wbargen { 
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
	$.thestring = ""
	$.compound=0;
$.keys = [0 = "C",1 = "C#",2 = "D",3 = "D#",4 = "E",5 = "F",6 = "F#",7 = "G",8 = "G#",9 = "A",10 = "A#",11 = "B"]

	$.notesArray = [0="a",1="b",2="c",3="d",4="e",5="f",6="g"]
	$.majorArray = [0="c",1="d",2="e",3="f",4="g",5="a",6="b"]
	$.minorArray = [0="c",1="d",2="d#",3="f",4="g",5="g#",6="b"]
	$.pentArray = [0="c#",1="d#",2="f#",3="g#",4="a#"]
	$.barArray = [0="4",1="8",2="12",3="16",4="20",5="24",6="32"]
	$.timesigs=[0="4/4",1="3/4",2="2/4",3="6/8",4="9/8",5="12/8",6="2/2",7="3/2",8="4/2",9="6/4",10="9/4",11="12/4",12="2/8",13="3/8",14="4/8",15="6/16",16="9/16",17="12/16",18="5/4",19="7/4",20="5/8",21="7/8"]
	$.vol1=100
bars = []
	for ( n=0; n<33; n++ )
		bars[n] = string(n+1)
	$.tbarbutt1 = new kvalbutton(bars,$,"tb1changed")
	$.tbarbutt2 = new kvalbutton(bars,$,"tb2changed")

vols = []
	for ( n=0; n<128; n++ )
		vols[n] = string(n)
	$.bvol1 = new kvalbutton(vols,$,"vol1changed")
	$.vol2=60
	$.bvol2 = new kvalbutton(vols,$,"vol2changed")
	$.bpm1=16
$.tempi = []
	for ( n=0; n<41; n++ )
		$.tempi[n] = string(((n+8)*5))
	$.bbpm1 = new kvalbutton($.tempi,$,"bpm1changed")
	$.bpm2=16
	$.bbpm2 = new kvalbutton($.tempi,$,"bpm2changed")
	$.bpm3=16
	$.bbpm3 = new kvalbutton($.tempi,$,"bpm3changed")
	$.tempphr1= temponote(tempo())
	$.tempphr2= temponote(tempo())
	$.tempphr3= temponote(tempo())
	$.tbar2=1
	$.tbar3=1

	octs = []
	for ( n=0; n<7; n++ )
		octs[n] = string(n)
	$.oct=0
	$.octoffset = 3
	$.octbutton = new kvalbutton(octs,$,"octchanged")
	$.octtext = new ktext("Oct")
	$.scaletext = new ktext("Oct")
	$.barstext = new ktext("Bars")
	$.keytext = new ktext("Key")
	$.scadjtext = new ktext("Adj.To")
	$.transtext = new ktext("MoveTo")
	$.bpm1text = new ktext("Bpm | Bar")
	$.vol1text = new ktext("Beat")
	$.vol2text = new ktext("Off")
	$.volumetext = new ktext("Volume")
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
	$.snarfbutt = new kbutton("Gen",$,"dobeat")

	$.ntnames3 = [2="s",3="s.",4="e",6="e.",8="q",12="q.",16="h",24="h."]
#	$.btime = new kmenubutton("Time Sig.","mkmenu_selectTsig",$)
	$.btime = new kvalbutton($.timesigs,$,"tsig")
	$.bgens = new kvalbutton([0="Melody", 1="2 Lines", 2="3 Lines",3="4 Lines"], $,"setGens")
$.kbutt = new kvalbutton($.keys,$,"keychanged")
$.scabutt = new kvalbutton($.keys,$,"movescale")
$.transbutt = new kvalbutton($.keys,$,"movekey")

	$.bscale = new kvalbutton([0="Major", 1="Minor", 2="Pentatonic", 3="Chromatic"], $,"setScale")
	$.bbars = new kvalbutton($.barArray,$,"setNumBars")
			$.addchild($.ph2)
			$.addchild($.snarfbutt)
			$.addchild($.btime)
			$.addchild($.bbars)
			$.addchild($.bscale)
			$.addchild($.bgens)
			$.addchild($.kbutt)
			$.addchild($.scabutt)
			$.addchild($.transbutt)
	$.addchild($.octbutton)
	$.addchild($.title)

	$.addchild($.scaletext)
	$.addchild($.barstext)
	$.addchild($.keytext)
	$.addchild($.octtext)
	$.addchild($.scadjtext)
	$.addchild($.transtext)
	$.addchild($.bpm1text)
	$.addchild($.volumetext)
	$.addchild($.vol1text)
	$.addchild($.vol2text)
	$.addchild($.bbpm1)
	$.addchild($.bbpm2)
	$.addchild($.bbpm3)
	$.addchild($.bvol1)
	$.addchild($.bvol2)
	$.addchild($.tbarbutt1)
	$.addchild($.tbarbutt2)
	$.octbutton.set($.octoffset)
	$.bbpm1.set($.bpm1)
	$.bbpm2.set($.bpm2)
	$.bbpm3.set($.bpm3)
	$.bvol1.set($.vol1)
	$.bvol2.set($.vol2)
	$.tbarbutt1.set(0)
	$.tbarbutt2.set(0)
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
	$.bpm1text.resize(xy(x0+3*dx+3,y0aa+1,x0+5*dx-1,y0a-1))
	$.volumetext.resize(xy(x0+5*dx+2,y0aa+1,x0+7*dx-1,y0a-1))
	$.snarfbutt.resize(xy(x0+7*dx+4,y0aa+1,x0+9*dx-1,y0b-1))
	$.scadjtext.resize(xy(x0+9*dx+1,y0aa+1,x0+11*dx-2,y0a-1))

#line#3
	bx0 = x0
	bx1 = x0+7*dx
	dbx = (bx1-bx0)/8

	$.bscale.resize(xy(x0+0*dx+1,y0a+1,x0+2*dx-1,y0b))
	$.octbutton.resize(xy(x0+2*dx+1,y0a+1,x0+3*dx-1,y0b))
	$.bbpm1.resize(xy(bx0+3*dx+3,y0a+1,bx0+4*dx-1,y0b))
	$.vol1text.resize(xy(bx0+5*dx+2,y0a+1,bx0+6*dx-1,y0b))
	$.bvol1.resize(xy(bx0+6*dx+1,y0a+1,bx0+7*dx-1,y0b))
	$.scabutt.resize(xy(x0+10*dx+1,y0a+1,x0+11*dx-2,y0b))
#line#4
	$.bgens.resize(xy(bx0+0*dx+1,y0b+1,bx0+2*dx-1,y0c))
	$.keytext.resize(xy(bx0+2*dx+1,y0b+1,bx0+3*dx-1,y0c))
	$.bbpm2.resize(xy(bx0+3*dx+3,y0b+1,bx0+4*dx-1,y0c))
	$.tbarbutt1.resize(xy(bx0+4*dx+3,y0b+1,bx0+5*dx-1,y0c))
	$.vol2text.resize(xy(bx0+5*dx+2,y0b+1,bx0+6*dx-1,y0c))
	$.bvol2.resize(xy(bx0+6*dx+1,y0b+1,bx0+7*dx-1,y0c))
	$.transtext.resize(xy(bx0+9*dx+1,y0b+1,bx0+11*dx-2,y0c))

#line#5
	$.barstext.resize(xy(bx0+0*dx+1,y0c+1,bx0+1*dx-1,y0d))

	$.bbars.resize(xy(bx0+1*dx+1,y0c+1,bx0+2*dx-1,y0d))
	$.kbutt.resize(xy(bx0+2*dx+1,y0c+1,bx0+3*dx-1,y0d))

	$.bbpm3.resize(xy(bx0+3*dx+3,y0c+1,bx0+4*dx-1,y0d))
	$.tbarbutt2.resize(xy(bx0+4*dx+3,y0c+1,bx0+5*dx-1,y0d))
	$.transbutt.resize(xy(bx0+10*dx+1,y0c+1,bx0+11*dx-2,y0d))

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
	t1=(1000000/((float(t)/60)))
	$.tempphr1=temponote(t1)
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
method tb1changed (v) {$.tbar2 = v +1}
method tb2changed (v) {$.tbar3 = v +1}

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
	thistime=$.timesigs[t]
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

# Controls the number of generations and applies chord and scale adjustments
method dobeat () {
	offset=$.oct
min = $.gens-$.octoffset
min++

	offset++
	if($.gens >1){
		offset++
		if(offset>4)offset=4
		
		if($.oct<-1 && ($.gens + $.oct) <= min) offset= min -1

	}
	howmany=0
	p1=''
	p1+=$.tempphr1
	if($.tbar2 <= $.nbrMeasures && $.tbar2 > 1 && $.bpm2 != $.bpm1){
		tsplit=($.tbar2-1)*$.barlen*12
		q=$.tempphr2 
		q.time=tsplit
		p1+=q
		if($.tbar3 <= $.nbrMeasures && $.tbar3 > $.tbar2 && $.bpm3 != $.bpm2){
			tsplit=($.tbar3-1)*$.barlen*12
			q=$.tempphr3 
			q.time=tsplit
			p1+=q
			
		}
	}
	while(howmany < $.gens){
		offset--
		s= $.CompBeat()
		p= phrase(s)
		p= transpose(p,$.currkey + (offset*12)) 
		if($.scale != 2 && howmany >0){
			r= ' '
			for(nt in p){
				v = 0
				tr=rand(3)
				if(tr == 1)v=7
				if(tr == 2  && $.scale != 1)v=4
				if(tr == 2  && $.scale != 1)v=3

				if(v >0)nt =transpose(nt,v)
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
			p1 = scadjust(p1,scale_ionian())
			p1 = scafilt(p1,scale_ionian())
		}
		if($.scale==1){
			p1 = scadjust(p1,scale_aeolian())
			p1 = scafilt(p1,scale_aeolian())
		}
	}	
	$.ph1.set(p1,0)
	$.ph2.set(p1,0)
	$.ph2.fitall()
	$.ph2.redraw()
	$.snarf(p1)
	$.play()

}

# Not used  generated phrase and allow it to be played
method dobeatv1() {
	howmany=0
	p1='rd10'
	while(howmany < $.gens){
		s= $.CompBeat()
		p= phrase(s)
		p= transpose(p,$.currkey + ($.oct*12)) 
		p1 |= p
		howmany++ 
	}
#	out=printf("\n %s \n %s ", $.fullmel , $.fullstring)
#	print (out)
	if(howmany > 1){
		if($.scale==0){
			p1 = scadjust(p1,scale_ionian())
			p1 = scafilt(p1,scale_ionian())
		}
		if($.scale==1){
			p1 = scadjust(p1,scale_aeolian())
			p1 = scafilt(p1,scale_aeolian())
		}
	}	
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
method CompBeat() {

$.fullstring = ""
$.fullmel=" "
$.thetune= " "
$.notesValue=0
$.sumvalue=0
$.notebase=8
$.first=1
$.thestring = ""
maxbeat = $.barlen  
# make sure you don't go outside the bar limit for note length
minbeat = 2 #sixteenth notes at present
beatval = 0
mult=1.0
newbar=1
maxbeat++ #increment for rand purposes
picknote=0
# repeat for the number of measures required set at 4 at present
for (count=0; count< $.nbrMeasures; count++) {
	$.sumvalue = $.barlen  #start with a full bar
	$.notesvalue = 0  #count the other way as well
	newbar=1
	while ($.sumvalue >= minbeat) {
		beatval = rand(maxbeat) #choose a value
mnv=$.notesvalue
mnb=$.notebase
		modbit = mnv  % mnb 
#deal with simple or compound time differently
		if($.notebase==12){
			picknote = rand(3)
			if(modbit==10)beatval=2
			else
			if(modbit % 2 == 0)beatval=picknote*2
					
		}
		if( $.notebase==6){
			if(modbit == 2)beatval=2
		}
		if($.notebase==8  || $.notebase == 16){
			if(modbit==2){
				picknote = rand(4)
				beatval=picknote*2
			}
			if(modbit==4){
				picknote = rand(3)
				beatval=picknote*2
			}
			if(modbit==6){
				beatval=2
			}
		}
	# tidy up remainders
		if ($.sumvalue==4) beatval=4
		if ($.sumvalue==3) beatval=3
		if( beatval <= $.sumvalue) {newbar = $.MakeCompBeat(beatval,newbar)}
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
method MakeCompBeat(beatval,newbar)
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
		$.thetune+=$.MakeCompTune(newbar,0);
		$.first=0  
		if(newbar)newbar=0
		# Catch tricky divisions and force repeat choice
		if($.compound == 1 && $.notesvalue<12 && beatval == 2){
			$.thestring+="s "
			$.sumvalue-=2
			$.notesvalue+=2
			$.thetune+=$.MakeCompTune(newbar)
		}
		if($.compound ==1 && $.notesvalue<12 && beatval == 3){
			$.thestring+="s. "
			$.sumvalue-=3
			$.notesvalue+=3
			$.thetune+=$.MakeCompTune(newbar)
		}
	}
	return (newbar)
#	return ($.thestring + "  " + $.thetune)
}


#Pick a note from the appropriate scale
method MakeCompTune(newbar){

 	note = rand(7)
 	start =rand(5)
	if(start < 4 )start=0
	if($.scale==0){
		if($.first)  # force C or G
		anote = $.majorArray[start]
		else
		anote = $.majorArray[note]
	}
	if($.scale==1){
		if($.first)
		anote = $.minorArray[start]
		else
		anote = $.minorArray[note]
	}
	if($.scale==2){
		note = rand(5)
		anote = $.pentArray[note]
	}
	if($.scale==3){
		anote = $.notesArray[note]
	}
	# emphasise beat at start or in middle
	if(newbar) {anote = $.UpperFirst(anote,newbar);}
	$.thetune +=  anote;
 	if($.scale ==3){
		sharp = rand(5);
		if (sharp > 3) $.thetune += "#";
       		$.thetune += " ";
	}
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
if(note >= 0){
	noteString +=string(note)
	volString+=string(vol)
}

#now work out the melody line
len=sizeof($.fullmel)+1
for (i = 1; i < len; i++){
	c=substr($.fullmel,i,1) 	
	if(c != " "){
		c = $.switchCase(c,0)  #we want lower
		if(i < len) {
			i++;
			d=substr($.fullmel,i,1) 	
			if(d=="#")c=$.switchCase(c,1)  #upper signals sharp
			else i--
		}
	mel+=c
	}
}
len=sizeof(mel)+1
lastvol=0
lastdur=0
temposplit=0
#Stick it all together
for (i = 1; i < len; i++){
	if(i>1) {kpString +=","	}
	c=substr(mel,i,1) 	
	d=$.CheckSharp(c)  #is it upper case?  This lowers it and adds the symbol
	kpString += d
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


} #end of class


