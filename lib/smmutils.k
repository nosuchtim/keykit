#Set of utilities developed by David Woolls 
#for use with Structured Melody Maker 
# aka wbargenX.k
#The sysextext stuff can be used with any file via the Snarf
#The SMM stuff will work with any four channel piece 
#also via the Snarf

#returns only at exact time, for chord modification
function smmattime(ph,tm) {
	return ( ph { ??.time == tm && (??.time+??.dur) > tm } )

}

SMMScales = [
	"ionian" = 'p0,p2,p4,p5,p7,p9,p11',
	"harminor" = 'p0,p2,p3,p5,p7,p8,p11',
	"melminor" = 'p0,p2,p3,p5,p7,p9,p11',
	"aeolian" = 'p0,p2,p3,p5,p7,p8,p10',
	"pentatonic" = 'p0,p2,p5,p7,p9',
	"chromatic" = 'p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11'
	]

function SMMscale_ionian() { return(SMMScales["ionian"]) }
function SMMscale_aeolian() { return(SMMScales["aeolian"]) }
function SMMscale_harminor() { return(SMMScales["harminor"]) }
function SMMscale_melminor() { return(SMMScales["melminor"]) }
function SMMscale_pentatonic() { return(SMMScales["pentatonic"]) }
function SMMscale_chromatic() { return(SMMScales["chromatic"]) }

# name: allsysextext(ph)
# desc: return all Sysextext in a phrase
function allsysextext(ph) {
	return(cut(ph,CUT_TYPE,SYSEXTEXT))
}


# name: stripsysextext(ph, t)
# desc: returns the Sysextext of a given type in a phrase
function stripsystext (ph,t){
	systext= allsysextext(ph)
	textphr=''
	for(nt in systext){
		ttext=substr(string(nt),3,3)
		if(ttext==t)textphr|=nt
	}
return(textphr)
}

# name: timesigsinfo(ph)
# desc: return only the Time Signature Sysextext in a phrase
function timesigsinfo(ph) {
	return(stripsystext(ph,"Tim"))
}

# name: keysigsinfo(ph)
# desc: return only the Key Signature Sysextext in a phrase
function keysigsinfo(ph) {
	return(stripsystext(ph,"Key"))
}

# name: tempoinfo(ph)
# desc: return only the Tempo Setting Sysextext in a phrase
function tempoinfo(ph) {

	return(stripsystext(ph,"Tem"))
	
}

# name: bpinfo(ph)
# desc: returns the Tempo Setting as BPM in a phrase
# 		illustrative rather than operational.
function bpinfo(ph) {
	bpmphr=''
	bpmall=''
	p = stripsystext(ph,"Tem")
	for(nt in p){
		strnt=string(nt)
		c=9
		b=""
		a=substr(strnt,c,1)
		while(ascii(a) > 47 && ascii(a) < 58 ){
			b+=a
			c++
			a=substr(strnt,c,1)
		}
		t=integer(b)
		bp=integer(60/(float(t))*1000000)
		bpmphr = phrase("'\" "+string(bp)+"\" '")
		bpmphr.time = nt.time
		bpmall+=bpmphr

	}

	return(bpmall)
}
# name: bpmnum(ph)
# desc: returns the Tempo Setting as BPM in a phrase
# 		illustrative rather than operational.
function bpmnum(ph) {
	bp=0
	p = stripsystext(ph,"Tem")
	for(nt in p){
		strnt=string(nt)
		c=9
		b=""
		a=substr(strnt,c,1)
		while(ascii(a) > 47 && ascii(a) < 58 ){
			b+=a
			c++
			a=substr(strnt,c,1)
		}
		t=integer(b)
		bp=integer(60/(float(t))*1000000)

	}

	return(bp)
}


# name: tsiginfo(ph)
# desc: returns the  Time Signature(s) only in a phrase
# 		
function tsiginfo(ph) {
	tsphr=''
	tsall=''
	if(nargs()<2)n=0
	p = stripsystext(ph,"Tim")
	for(nt in p){
		strnt=string(nt)
		c=11
		ts=""
		a=substr(strnt,c,1)
		while(ascii(a) != 44){
			ts+=a
			c++
			a=substr(strnt,c,1)
		}
		tsphr = phrase("'\" "+ts+"\" '")
		tsphr.time = nt.time
		tsall+=tsphr

	}
	return(tsall)

}
# name: tsiginfo2(ph)
# desc: returns the first Time Signature as a string
# 		for searching the position in an array of TS
function tsiginfo2(ph) {
	tsphr=''
	ts=""
	p = stripsystext(ph,"Tim")
	for(nt in p){
		strnt=string(nt)
		c=11
		a=substr(strnt,c,1)
		while(ascii(a) != 44){
			ts+=a
			c++
			a=substr(strnt,c,1)
		}
		break
	}
	return(ts)
}

# name: ksinfo(ph)
# desc: returns the Key Signatures in a phrase
function ksinfo(ph) {
#	sharpflats = [0 = 0,1 = -5,2 = 2,3 = -3,4 = 4,5 = -1,6 = 6,7 = 1,8 = -4,9 = 3,10 = -2,11 = 5]
majkeysigs = ["0" = "C","251" = "Db","2" = "D","253" = "Eb","4" = "E","255" = "F","6" = "F#","1" = "G","252" = "Ab","3" = "A","254" = "Bb","5" = "B"]
minkeysigs = ["0" = "A","251" = "Bb","2" = "B","253" = "C","4" = "C#","255" = "D","6" = "D#","1" = "E","252" = "F","3" = "F#","254" = "G","5" = "G#"]
	ksphr=''
	ksall=''
	minor="minor"
	mm=0
	p = stripsystext(ph,"Key")
	for(nt in p){
		strnt=string(nt)
		c=10
		b=""
		a=substr(strnt,c,1)
		while(ascii(a) > 47 && ascii(a) < 58 ){
			b+=a
			c++
			a=substr(strnt,c,1)
		}
		c++
		d=substr(strnt,c,1)
		mm=integer(d)	
		ks=majkeysigs[b]
		if(mm){
			ks=minkeysigs[b]
			ks+=minor
		}
		ksphr = phrase("'\" " + ks + "\" '")
		ksphr.time = nt.time
		ksall+=ksphr

	}

	return(ksall)
}

# name: ksinfo2(ph)
# desc: returns the Key Signatures in a phrase
function ksinfo2(ph) {
	p = stripsystext(ph,"Key")
	a=""
	b=""
	for(nt in p){
		strnt=string(nt)
		c=10
		a=substr(strnt,c,1)
		while(ascii(a) > 47 && ascii(a) < 58 ){
			b+=a
			c++
			a=substr(strnt,c,1)
		}
		c++
		d=substr(strnt,c,1)
		b = b + a + d
		break	
	
	}
	return(b)
}


function mkmenu_file(o,po) {
	o.menucmd("Save",po,"writesmf")
	o.menucmd("Append",po,"appendsmf")
	o.menucmd("Read",po,"readfile")
}

function mkmenu_make(o,po) {
	o.menucmd("Segment",po,"gentype1")
	o.menucmd("New Variation",po,"variationa")
	o.menucmd("Current Variation",po,"variationb")
	o.menucmd("Autogen",po,"autogen")
}

function smmscadjust(mel,scale,tr) {
	flatArray=[1=1,3=1,5=1,8=1,10=1]
	sc=0
	if(scale == 1){
mainscale=transpose(SMMscale_aeolian(),tr)
sc=1
	}
	if(scale == 2)mainscale=transpose(SMMscale_harminor(),tr)
	if(scale == 0)mainscale=transpose(SMMscale_ionian(),tr)
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
	for ( nt in mainscale )
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

function smmharmonise2(p,scale,tr) {
#	trans=[0=0,1=5,2=0,3=7,4=9,5=5,6=2,7=11,8=0,9=2,10=4,11=9,12=2,13=7,14=0]
	trans=[0=0,1=5,2=4,3=9,4=2,5=7,6=0]
#	trans=[0=0,1=5,2=7,3=0, 4=2,5=11,6=0]
	minors = [2=1,4=1,9=1,11=1]
	max=sizeof(trans)-1
	trchan=[]
	movers=[]
	pk=[]
	p1=''
	for(n=1;n<=sizeof(p);n++){
		trchan[n]=p[n].chan
		p1|=p[n]
	}
	p3=onlynotes(p1)
	phold=p1-p3
	currchord=0
	p2=''
	for (nt in p3){
		ntime=nt.time
		npitch=trans[currchord]
		rootoct=integer(nt.pitch /12)
		ntch=nt.chan
		x=rand(2)
		fifth=7
		third=4
		if(scale==1 || scale==2)third=3
		move=trans[currchord]
		if (scale==0 && move in minors) third=3
		if ((scale==1 || scale==2) && move in minors) third=4
		if(move==2){
			third=3
			if(scale>0)fifth=6
		}
		if(move==11 && scale ==0)fifth=6
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
		scl = cut(p3,CUT_TIME,ntime,ntime,INCLUSIVE)
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
				currchord+=rand(3)+1
				if(currchord > max)currchord=0
				first=0
			}
			r |= thisnote
		}
		p3-=scl
		p2|=r
	}
	p2=smmscadjust(p2,scale,tr)
	p2|=phold
	for(n=1;n<=sizeof(p);n++){
		pk[n]=cut(p2,CUT_CHANNEL,trchan[n])
	}
#print(pp)
	return(pk)
}


function smmharmonise4(p, currchord, scale,tr) {
#	trans=[0=0,1=5,2=0,3=7,4=9,5=5,6=2,7=11,8=0,9=2,10=4,11=9,12=2,13=7,14=0]
	trans=[0=0,1=5,2=4,3=9,4=2,5=7]
#	trans=[0=0,1=5,2=7,3=0, 4=2,5=11,6=0]
	minors = [2=1,4=1,9=1,11=1]
	max=sizeof(trans)-1
	trchan=[]
	movers=[]
	pk=[]
	p1=''
	for(n=1;n<=sizeof(p);n++){
		trchan[n]=p[n].chan
		p1|=p[n]
	}
	p3=onlynotes(p1)
	phold=p1-p3
	p2=''
	pp=""
	ntime=0
	chords=0
	while(ntime>-1){
		scl = cut(p3,CUT_TIME,ntime,ntime,INCLUSIVE)
		if(sizeof(scl)>1){
		chords++
#		print (smmattime(scl,ntime))
		}
		ntime=nexttime(p3,ntime)
	}
	chcount=0
	ntime=0
	while(ntime>-1){
		seventh=0
		s7=rand(10)
		if(s7>6)seventh=1
#		ntime=nt.time
#		npitch=nt.pitch % 60
#		if(chcount==chords-2){
#			currchord=5
#			seventh=1
#		}
#		if(chcount==chords-1){
#			$.currchord=6
#			seventh=0
#		}
		npitch=trans[currchord]
		move=trans[currchord]
		dir=rand(2)
		
		afifth=7
		athird=4
		if(scale==1 || scale==2)athird=3
		if (scale==0 && move in minors) athird=3
		if ((scale==1 || scale==2) && move > 2 && move in minors ) athird=4
		if(move==2){
			athird=3
			if(scale>0)afifth=6
		}
		if(move==11 && scale ==0)afifth=6
#		if(seventh)afifth=10
		fifth=npitch+afifth
		third=npitch+athird
		if(fifth>11)fifth-=12
		if(third>11)third-=12
		x=rand(9)
		y=rand(3)+1
		if(x<2){
			movers[1]=npitch
			movers[2]=third
			movers[3]=fifth
			movers[4]=npitch
		}
		if(x>1 && x<4){
			movers[1]=fifth
			movers[2]=npitch
			movers[3]=third
			movers[4]=npitch
		}
		if(x>3 && x < 6){
			movers[1]=npitch
			movers[2]=third
			movers[3]=fifth
			movers[4]=third		
		}
		if(x>5 && x < 8){
			movers[2]=third
			movers[3]=fifth
			movers[1]=npitch
			movers[4]=third		
		}
		if(x>7){
			movers[1]=npitch
			movers[2]=third
			movers[3]=npitch
			movers[4]=fifth 
			if(seventh) movers[4]=npitch 
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
		scl = cut(p3,CUT_TIME,ntime,ntime,INCLUSIVE)
		if(sizeof(scl>1)){
			chcount++
#			currchord+=rand(2)
			currchord+=rand(2)+1
			if(currchord > max)currchord=rand(3)							scl=smmattime(scl,ntime) 
			
			ntime=nexttime(p3,ntime)
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
		else
			r=scl
		p2|=r
	}
	p2=smmscadjust(p2,scale,tr)
	p2|=phold
	for(n=1;n<=sizeof(p);n++){
		pk[n]=cut(p2,CUT_CHANNEL,trchan[n])
	}
#print(pp)
	return(pk)
}
function smmharmonise3(p, currchord, scale,tr) {
#	trans=[0=0,1=5,2=0,3=7,4=9,5=5,6=2,7=11,8=0,9=2,10=4,11=9,12=2,13=7,14=0]
	trans=[0=0,1=5,2=4,3=9,4=2,5=7,6=0]
#	trans=[0=0,1=5,2=7,3=0, 4=2,5=11,6=0]
	minors = [2=1,4=1,9=1,11=1]
	max=sizeof(trans)-1
	trchan=[]
	movers=[]
	pk=[]
	p1=''
	for(n=1;n<=sizeof(p);n++){
		trchan[n]=p[n].chan
		p1|=p[n]
	}
	p3=onlynotes(p1)
	phold=p1-p3
	p2=''
	pp=""
	ntime=0
	chords=0
	while(ntime>-1){
		scl = cut(p3,CUT_TIME,ntime,ntime,INCLUSIVE)
		if(sizeof(scl)>1){
		chords++
#		print (smmattime(scl,ntime))
		}
		ntime=nexttime(p3,ntime)
	}
	chcount=0
	ntime=0
	while(ntime>-1){
		seventh=0
		s7=rand(10)
#		if(s7>6)seventh=1
#		ntime=nt.time
#		npitch=nt.pitch % 60
		if(chcount==chords-2){
			currchord=5
			seventh=1
		}
		if(chcount==chords-1){
			$.currchord=6
			seventh=0
		}
		npitch=trans[currchord]
		move=trans[currchord]
		dir=rand(2)
		
		afifth=7
		athird=4
		if(scale==1 || scale==2)athird=3
		if (scale==0 && move in minors) athird=3
		if ((scale==1 || scale==2) && move > 2 && move in minors ) athird=4
		if(move==2){
			athird=3
			if(scale>0)afifth=6
		}
		if(move==11 && scale ==0)afifth=6
		if(seventh)afifth=10
		fifth=npitch+afifth
		third=npitch+athird
		if(fifth>11)fifth-=12
		if(third>11)third-=12
		x=rand(8)
		y=rand(3)+1
		if(x<4){
			movers[1]=npitch
			if(y>2)movers[1]=third
			movers[2]=npitch
			if(movers[1]==npitch){
				movers[2]=third
				if(seventh || y>2)movers[2]=fifth
			}
			if(seventh)movers[2]=fifth
			movers[3]=third
			if(movers[2]==third && x >1)movers[3]=fifth
			movers[4]=npitch
		}
		if(x>3 && x < 7){
			movers[1]=npitch
			movers[2]=third
			movers[3]=fifth
			if(! seventh && x <5 )movers[3]=npitch
			movers[4]=third		
		}
		if(x>6){
			movers[1]=fifth
			if(y<3)movers[2]=npitch
			else movers[2]=third
			movers[3]=third
			if(! seventh && movers[2]==third )movers[3]=npitch
			movers[4]=fifth 
			if(seventh) movers[4]=npitch 
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
		scl = cut(p3,CUT_TIME,ntime,ntime,INCLUSIVE)
		if(sizeof(scl>1)){
			chcount++
			currchord+=rand(3)+1
			if(currchord > max)currchord=0
			scl=smmattime(scl,ntime) 
			
			ntime=nexttime(p3,ntime)
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
		else
			r=scl
		p2|=r
	}
	p2=smmscadjust(p2,scale,tr)
	p2|=phold
	for(n=1;n<=sizeof(p);n++){
		pk[n]=cut(p2,CUT_CHANNEL,trchan[n])
	}
#print(pp)
	return(pk)
}

function smmharmonise1(p, scale,tr) {

	trchan=[]
	movers=[]
	pk=[]
	p1=''
	for(n=1;n<=sizeof(p);n++){
		trchan[n]=p[n].chan
		p1|=p[n]
	}
	p3=onlynotes(p1)
	phold=p1-p3
	p2=''
	for (nt in p3){
		ntime=nt.time
		npitch=nt.pitch % 60
	
		ntch=nt.chan
		x=rand(2)
		third=4
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
		scl = cut(p3,CUT_TIME,ntime,ntime,INCLUSIVE)
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
		p3-=scl
		p2|=r
	}
	p2=smmscadjust(p2,scale,tr)
	p2|=phold
	for(n=1;n<=sizeof(p);n++){
		pk[n]=cut(p2,CUT_CHANNEL,trchan[n])
	}
#print(pp)
	return(pk)
}

function smmnojumps(p,bargap){
	trchan=[]
	movers=[]
	pk=[]
	pgroup=''
	for(n=1;n<=sizeof(p);n++){
		trchan[n]=p[n].chan
		pgroup|=p[n]
	}
pnotes=onlynotes(pgroup)
phold=pgroup-pnotes
p1=''
r=''
for (n=1; n<5; n++){
	p1=cut(pnotes,CUT_CHANNEL,n)
	p2=''
	ncount=0
	ntlast=''
	ntlast.time=0
	for (nt in p1){
		if(ncount){
			if(nt.time-ntlast.time < bargap){
				while(abs(nt.pitch-ntlast.pitch)>7){
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
	for(n=1;n<=sizeof(p);n++){
		pk[n]=cut(r,CUT_CHANNEL,trchan[n])
	}
return (pk)
}
function smmsetchord (thischord,scale,key) {
	trans=[0=0,1=5,2=4,3=9,4=2,5=7]
	minors = [2=1,4=1,9=1,11=1]
	move=trans[thischord]
	root='p60'
	athird='p64'
	afifth='p67'
	aseventh='p70'
	if(scale==1 || scale==2)athird='p63'
	if (scale==0 && move in minors) athird='p63'
	if ((scale==1 || scale==2) && move > 2 && move in minors ) athird='p64'
		if(move==2){
			athird='p63'
			if(scale>0)afifth='p66'
		}
		root.pitch+=move+key
		afifth.pitch+=move+key 
		athird.pitch+=move+key 
		aseventh.pitch+=move+key 
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

