#********************************************************************

#	WWWTOOLS 
#	by
#	Mehmet Okonsar
#	mokonsar@dominet.in.com.tr
#	Graphical Implementation of the algorithms:
#	BSWW, ECHOVARIETY, POLISHIT by Tim Thompson
#	USAGE:
#	"Word" : Enter a string for generating algorithms. One may also read a text file (*.txt). Long strings may produce (very) long sequences !..
#	"BSW" : Here you may enter various options for key notes, key phrases and guide phrases.
#	"ROOT" : this is for root notes patterns.You may enter patterns (as time in clicks or beat) or you may cancel the entry to have the default values : 4b-2b-1b-2b. Select "None" to not have any root added.
#	"GEN" :  here you "compose" by selecting the algorithms :
#	"Algorithm I" ; requires a string (referred to it as "WORD") and uses BSWWW with the options previously selected
#	"Algorithm II" ;  requires a string and reads the first slider at left :LENGTH uses ECHOVARIETY and POLISHIT algos (by Tim Thompson)
#	"Algorithm III" ;  requires a string and reads the first slider at left :LENGTH uses ECHOVARIETY only
#	"Rework phrase"; this gives the option of transforming by ECHOVARIETY and/or POLISHIT any phrase from the Snarf, or from a file
#	"Snarf" : snarf the resulting phrase (shown in the bottom window)
#	"Write" : writes the resulting phrase (shown in the bottom window) as standard midi file
#	SLIDERS
#	from left to right:
#		1.	Length of the total sequence 
#		2.	Number of echoes for the first generator
#		3.	Delay of the echoes for the first generator
#			idem for 2d. , 3rd., and 4th. ones

#*********************************************************************
class wwwtools {
	method init {
	RESULTPHRASE=''
	PLAYING=0
	WORD=""
	LENGTH=24
	
	E1NUM=2
	E1DEL=384
	E2NUM=2
	E2DEL=384
	E3NUM=2
	E3DEL=384
	E4NUM=2
	E4DEL=384

	NOROOT=0
	MAKEROOT1=4b
	MAKEROOT2=2b
	MAKEROOT3=1b
	MAKEROOT4=2b

	BSGUIDEPHRASE=''
	BSKEY='e-o-2'
	BSKEYOCTAVE="o3"

	BSMAJ1='e-o-2'
	BSMAJ2='e-o-2,f,g,b-'
	BSMAJ3='e-o-2,b-'
	BSMAJ4='e-o-2,b-'
	BSMAJ5='e-o-2,f,g,b-'
	BSMAJ6='e-o-2,b-'
	BSMAJ7='e-o-2,f,g,b-'
	BSMAJ8='e-o-2,b-'
	BSMIN1='e-o-2'
	BSMIN2='e-o-2,f,g-,b-'
	BSMIN3='e-o-2,b-'
	BSMIN4='e-o-2,b-'
	BSMIN5='e-o-2,f,g-,b-'
	BSMIN6='e-o-2,b-'
	BSMIN7='e-o-2,f,g-,b-'
	BSMIN8='e-o-2,b-'
	NTIMES=8

	$.w = new window()
	$.inherit($.w)
	$.generatebtn = new kmenubutton("Gen","mkmenu_generate",$)
	$.wordbtn = new kmenubutton("Word","mkmenu_getword",$)
	$.bswwwbtn = new kmenubutton("BSW","mkmenu_bswww",$)
	$.writebtn = new kbutton("Write",$,"writemidi")
	$.snarfbtn = new kbutton("Snarf",$,"snarfit")
	$.addrootbtn= new kmenubutton("Root","mkmenu_wwwaddroot",$)

	$.resultphrase=new wphrase()

	$.lengthsl = new kslider(0,100,24,$,"updatelength")

	$.echo1numsl = new kslider(0,100,2,$,"echo1num")
	$.echo1delaysl = new kslider(0,1000,384,$,"echo1delay")
	$.echo2numsl = new kslider(0,100,2,$,"echo2num")
	$.echo2delaysl = new kslider(0,1000,384,$,"echo2delay")
	$.echo3numsl = new kslider(0,100,2,$,"echo3num")
	$.echo3delaysl = new kslider(0,1000,384,$,"echo3delay")
	$.echo4numsl = new kslider(0,100,2,$,"echo4num")
	$.echo4delaysl = new kslider(0,1000,384,$,"echo4delay")

	$.addchild($.resultphrase)
	$.addchild($.generatebtn)
	$.addchild($.wordbtn)
	$.addchild($.bswwwbtn)
	$.addchild($.writebtn)
	$.addchild($.snarfbtn)
	$.addchild($.addrootbtn)
	$.addchild($.lengthsl)
	$.addchild($.echo1numsl )
	$.addchild($.echo1delaysl)
	$.addchild($.echo2numsl)
	$.addchild($.echo2delaysl)
	$.addchild($.echo3numsl)
	$.addchild($.echo3delaysl)
	$.addchild($.echo4numsl)
	$.addchild($.echo4delaysl)

	$.isset = 0
	$.stoptids = []
	}

method redraw {
	$.w.redraw()
	methodbroadcast();
	$.w.text("WWW Tools",
		xy($.xmin(),$.ymin(),$.xmax(),$.ymin()+$.textheight()))
	}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)

	upbuttonswidth=($.xmax()-$.xmin()-16)/6
	upbuttonstop=$.ymin()+$.textheight()+4
	upbuttonsheight=($.ymax()-$.ymin()-$.textheight() - 4)/8
	
	resphleft=$.xmin()+2
	resphheigh=($.ymax()-$.ymin()-upbuttonsheight)/5
	resphtop=($.ymax()-2)-resphheigh
	resphright=$.xmax()-2
	resphbottom=$.ymax()-2

	sliderwidth=($.xmax()-$.xmin()-4)/11
	slidergroupdist=sliderwidth/2
	slidertop=upbuttonstop+upbuttonsheight+2
	sliderbottom=$.ymax()-resphheigh-4

	lengthsleft=$.xmin()+2
	lengthsright=lengthsleft+sliderwidth

	echo1numslleft=lengthsright+slidergroupdist
	echo1numslright=echo1numslleft+sliderwidth
	echo1delayslleft=echo1numslright
	echo1delayslright=echo1delayslleft+sliderwidth

	echo2numslleft=echo1delayslright+slidergroupdist
	echo2numslright=echo2numslleft+sliderwidth
	echo2delayslleft=echo2numslright
	echo2delayslright=echo2delayslleft+sliderwidth

	echo3numslleft=echo2delayslright+slidergroupdist
	echo3numslright=echo3numslleft+sliderwidth
	echo3delayslleft=echo3numslright
	echo3delayslright=echo3delayslleft+sliderwidth

	echo4delayslright=$.xmax()-2
	echo4delayslleft=echo4delayslright-sliderwidth
	echo4numslright=echo4delayslleft
	echo4numslleft=echo4numslright-sliderwidth
	
	$.wordbtn.resize(xy($.xmin()+2,upbuttonstop,$.xmin()+2+upbuttonswidth,upbuttonstop+upbuttonsheight))
	$.bswwwbtn.resize(xy($.xmin()+upbuttonswidth+4,upbuttonstop,$.xmin()+upbuttonswidth+4+upbuttonswidth,upbuttonstop+upbuttonsheight))
	$.addrootbtn.resize(xy($.xmin()+(upbuttonswidth*2)+6,upbuttonstop,$.xmin()+(upbuttonswidth*2)+6+upbuttonswidth,upbuttonstop+upbuttonsheight))
	$.generatebtn.resize(xy($.xmin()+(upbuttonswidth*3)+8,upbuttonstop,$.xmin()+(upbuttonswidth*3)+8+upbuttonswidth,upbuttonstop+upbuttonsheight))
	$.snarfbtn.resize(xy($.xmin()+(upbuttonswidth*4)+10,upbuttonstop,$.xmin()+(upbuttonswidth*4)+10+upbuttonswidth,upbuttonstop+upbuttonsheight))
	$.writebtn.resize(xy($.xmin()+(upbuttonswidth*5)+12,upbuttonstop,$.xmax()-2,upbuttonstop+upbuttonsheight))

	$.lengthsl.resize(xy(lengthsleft,slidertop,lengthsright,sliderbottom))

	$.echo1numsl.resize(xy(echo1numslleft,slidertop,echo1numslright,sliderbottom))
	$.echo1delaysl.resize(xy(echo1delayslleft,slidertop,echo1delayslright,sliderbottom))
	
	$.echo2numsl.resize(xy(echo2numslleft,slidertop,echo2numslright,sliderbottom))
	$.echo2delaysl.resize(xy(echo2delayslleft,slidertop,echo2delayslright,sliderbottom))

	$.echo3numsl.resize(xy(echo3numslleft,slidertop,echo3numslright,sliderbottom))
	$.echo3delaysl.resize(xy(echo3delayslleft,slidertop,echo3delayslright,sliderbottom))

	$.echo4numsl.resize(xy(echo4numslleft,slidertop,echo4numslright,sliderbottom))
	$.echo4delaysl.resize(xy(echo4delayslleft,slidertop,echo4delayslright,sliderbottom))

	$.resultphrase.resize(xy(resphleft,resphtop,resphright,resphbottom))

	}

method delete {
	killtids($.stoptids)
	$.stoptids = []
}

method get {
	return($.resultphrase.get())
}

#*******************************************************************

method setresph (p,doredraw) {
	p = onlynotes(p)
	$.resultphrase.set(p,0)
	$.resultphrase.fitall()
	if ( nargs() > 1 && doredraw )
		$.resultphrase.redraw()
	$.isset = 0
}

method play (stime) {
	if ( $.resultphrase.isplaying())
		$.stop()
	if ( nargs() < 1 ) {
		stime = nextquant(Now,1b)
	}
	tid = $.resultphrase.play(stime,1b)
	$.stoptids[tid] = 1
}
method stop {
	killtids($.stoptids)
	$.stoptids = []
	$.resultphrase.stop()
}
method mousedown (m) {
	if ( $.resultphrase.contains(m) ) {
		if ( $.resultphrase.isplaying())
			$.stop()
		else {
			tid = $.resultphrase.play(nextquant(Now,1b))
			$.stoptids[tid] = 1
		}
	}
	else mouseforward(m,"mousedown")
}
method dump {
	return ( [ "phrase" = $.resultphrase.get() ] )
}
method set (p,doredraw) {
	p = onlynotes(p)
	$.resultphrase.set(p,0)
	$.resultphrase.fitall()
	if ( nargs() > 1 && doredraw )
		$.resultphrase.redraw()
	$.isset = 0
}
method restore (state) { $.set(state["phrase"]) }

#*******************************************************************
#				ALGORITHMS
#*******************************************************************

method algo1{
	print("Algorithm I (requires WORD): uses BSWWW")
	if (WORD!="") {
		print("working on Algorithm I with ("+WORD+")")
		RESULTPHRASE=bswwwmodif(WORD)
		print("..Algorithm I done")
		$.resultphrase.set(RESULTPHRASE,0)
		$.resultphrase.fitall()
		$.resultphrase.redraw() 
		}
	else
	print ("No WORD is given")
	}

method algo2{
	print("Algorithm II (requires WORD&LENGTH): uses ECHOVARIETY and POLISHIT")
	if (WORD!="" && LENGTH>0) {
		print("working on Algorithm II with ("+WORD+") length :"+string(LENGTH))
		s=WORD
		x=wwwechovariety(strnotes(s))
		w=wwwpolishit(x)
		w=strip(w)
		r = cutitdown(w,LENGTH*1b)
		RESULTPHRASE=r
		print("..Algorithm II done")
		$.resultphrase.set(RESULTPHRASE,0)
		$.resultphrase.fitall()
		$.resultphrase.redraw() 
		}
	else
	print ("No WORD is given")
	}

method algo3{
	print("Algorithm III (requires WORD&LENGTH): uses ECHOVARIETY only")
	if (WORD!="" && LENGTH>0) {
		print("working on Algorithm III with ("+WORD+") length :"+string(LENGTH))
		s=WORD
		x=wwwechovariety(strnotes(s))
		w=strip(x)
		r = cutitdown(w,LENGTH*1b)
		RESULTPHRASE=r
		print("..Algorithm III done")
		$.resultphrase.set(RESULTPHRASE,0)
		$.resultphrase.fitall()
		$.resultphrase.redraw() 
		}
	else
	print ("No WORD is given")
	}

method algo4 {
	print("ECHOVARIETY  : put the selected phrase through ECHOVARIETY")
	print("working on ECHOVARIETY ..")
	if (sizeof(RESULTPHRASE)>0) {
		RESULTPHRASE=wwwechovariety(RESULTPHRASE)
		print("..Algorithm ECHOVARIETY done")
		$.resultphrase.set(RESULTPHRASE,0)
		$.resultphrase.fitall()
		$.resultphrase.redraw() 
		}
	else 	print ("No phrase given")
	}

method algo5 {
	print("POLISHIT : put the selected phrase through POLISHIT")
	print("working on POLISHIT..")
	if (sizeof(RESULTPHRASE)>0) {
		RESULTPHRASE=wwwpolishit(RESULTPHRASE)
		print("..Algorithm POLISHIT done")
		$.resultphrase.set(RESULTPHRASE,0)
		$.resultphrase.fitall()
		$.resultphrase.redraw() 
		}
	else 	print ("No phrase given")
	}

#********************************************************************
#			READING and WRITING
#********************************************************************

method getmidifile1 {
	fname = browsefiles("Midi files (*.mid)","*.mid",1)
	RESULTPHRASE= onlynotes(readmf(fname))
	nnt=0
	for ( nt in RESULTPHRASE) 
		nnt++
	print (fname+" ~ Notes : "+string(nnt))
	print("working on ECHOVARIETY ..")
	RESULTPHRASE=wwwechovariety(RESULTPHRASE)
	print("..Algorithm ECHOVARIETY done")
	}

method getmidifile2 {
	fname = browsefiles("Midi files (*.mid)","*.mid",1)
	RESULTPHRASE= onlynotes(readmf(fname))
	nnt=0
	for ( nt in RESULTPHRASE) 
		nnt++
	print (fname+" ~ Notes : "+string(nnt))
	print("working on POLISHIT ..")
	RESULTPHRASE=wwwpolishit(RESULTPHRASE)
	print("..Algorithm POLISHIT done")
	}

method getphrasefile1 {
	fname = browsefiles("K phrase files (*.k)","*.k",1)
	RESULTPHRASE= readkey(fname)
	nnt=0
	for ( nt in RESULTPHRASE) 
		nnt++
	print (fname+" ~ Notes : "+string(nnt))
	print("working on ECHOVARIETY ..")
	RESULTPHRASE=wwwechovariety(RESULTPHRASE)
	print("..Algorithm ECHOVARIETY done")
	}

method getphrasefile2 {
	fname = browsefiles("K phrase files (*.k)","*.k",1)
	RESULTPHRASE= readkey(fname)
	nnt=0
	for ( nt in RESULTPHRASE) 
		nnt++
	print (fname+" ~ Notes : "+string(nnt))
	print("working on POLISHIT ..")
	RESULTPHRASE=wwwpolishit(RESULTPHRASE)
	print("..Algorithm POLISHIT done")
	}

method getsnarf1 {
	if (Snarf=='')
		print("Nothing in the snarf ..")
	else {
		ph = syncphr(Snarf)
		print("working on ECHOVARIETY with Snarf..")
		RESULTPHRASE = wwwechovariety(ph)
		print("..Algorithm ECHOVARIETY done")
		$.resultphrase.set(RESULTPHRASE,0)
		$.resultphrase.fitall()
		$.resultphrase.redraw() 
		}
	}
method getsnarf2 {
	if (Snarf=='')
		print("Nothing in the snarf ..")
	else {
		ph= syncphr(Snarf)
		print("working on POLISHIT with Snarf..")
		RESULTPHRASE=wwwpolishit(ph)
		print("..Algorithm POLISHIT done")
		$.resultphrase.set(RESULTPHRASE,0)
		$.resultphrase.fitall()
		$.resultphrase.redraw() 
		}
	}

method getstring {
	WORD=getastr("Enter the string ->","")
	if (WORD=="")
		print("No string given ?..")
	else
		print("String : " + WORD)
}

method readtextfile {
	WORD=""
	fname = ""
	w1=[]
	fname = browsefiles("Text files (*.txt)","*.txt",1)
	if (fname!= "") {
		f = open(fname) 
		print("READING ..")
		for ( nwords=1; (w1[nwords]=get(f)) != Eof; nwords++ ) 
			print("(" + string(nwords) + ") = " + w1[nwords]) 
		close(f) 
		for (i=1; i<nwords; i++) WORD=WORD+string(w1[i])
			print("WORD : "+WORD)
	}
	else
		print("Reading aborted")
}	

method writemidi{
	fname = browsefiles("Midi files (*.mid)","*.mid",1)
	if (sizeof(fname)>0) {
		writemf(RESULTPHRASE,string(fname ))
		print ("Saved to : "+fname )
	}
	else
	print("Saving cancelled")
	}

method snarfit { 
	print("Snarfing the resulting phrase ..")
	Snarf=RESULTPHRASE
	print(".. done.")
}

#******************************************************************
#				BSWW OPTIONS
#******************************************************************

method bskeyoctave(ntstr,octstr){
	ntstr="'"+ntstr+octstr+"'"
	BSKEY=phrase(ntstr)
	print("Key note for BSWW :"+string(ntstr))
	}
method bsguidereadmidifile {
	fname = browsefiles("Midi files (*.mid)","*.mid",1)
	BSGUIDEPHRASE= onlynotes(readmf(fname))
	nnt=0
	for ( nt in BSGUIDEPHRASE) 
		nnt++
	print (fname+" ~ Notes : "+string(nnt))
	}
method bsguidereadphrasefile {
	fname = browsefiles("K phrase files (*.k)","*.k",1)
	BSGUIDEPHRASE= readkey(fname)
	nnt=0
	for ( nt in BSGUIDEPHRASE) 
		nnt++
	print (fname+" ~ Notes : "+string(nnt))
	}
method bsguidereadsnarf {
	if (Snarf=='')
		print("Nothing in the snarf ..")
	else {
		BSGUIDEPHRASE= Snarf
		BSGUIDEPHRASE= syncphr(BSGUIDEPHRASE)
		for ( nt in BSGUIDEPHRASE) nnt++
		print ("Snarf notes : "+string(nnt))
		}
	}
method bsguidephrase{
	phstr=getastr("Enter guide phrase ->","")
	if (sizeof(phstr)>0){
		BSGUIDEPHRASE=phrase("'"+phstr+"'")
		print ("Guide phrase for BS =" + string(BSGUIDEPHRASE))
		}
	else
	print("No guide phrase given.\n It will be created by the algorithm.")
	}

method bskeynotesMAJ {
	maj1Str=""
	maj2Str=""
	maj3Str=""
	maj4Str=""
	maj5Str=""
	maj6Str=""
	maj7Str=""
	maj8Str=""
	print("Enter BS Major Key phrases..Cancel to have default Key phrases")
	maj1Str=getastr("BS Maj. 1 ->","")
	if (maj1Str!="") {
		BSMAJ1=phrase("'"+maj1Str+"'")
		maj2Str=getastr("BS Maj. 2 ->","") 
		if (maj2Str!="") {
			BSMAJ2=phrase("'"+maj2Str+"'")
			maj3Str=getastr("BS Maj. 3 ->","") 
			}
		if (maj3Str!="") {
			BSMAJ3=phrase("'"+maj3Str+"'")
			maj4Str=getastr("BS Maj. 4 ->","") 
			}
		if (maj4Str!="") {
			BSMAJ4=phrase("'"+maj4Str+"'")
			maj5Str=getastr("BS Maj. 5 ->","") 
			}
		if (maj5Str!="") {
			BSMAJ5=phrase("'"+maj5Str+"'")
			maj6Str=getastr("BS Maj. 6 ->","") 
			}
		if (maj6Str!="") {
			BSMAJ6=phrase("'"+maj6Str+"'")
			maj7Str=getastr("BS Maj. 7 ->","") 
			}
		if (maj7Str!="") {
			BSMAJ7=phrase("'"+maj7Str+"'")
			maj8Str=getastr("BS Maj. 8 ->","") 
			}
		if (maj8Str!="") {
			BSMAJ8=phrase("'"+maj8Str+"'")
			print("BS MAJOR KEY NOTES :")
			print("BSMAJ1 = "+string(BSMAJ1))
			print("BSMAJ2 = "+string(BSMAJ2))
			print("BSMAJ3 = "+string(BSMAJ3))
			print("BSMAJ4 = "+string(BSMAJ4))
			print("BSMAJ5 = "+string(BSMAJ5))
			print("BSMAJ6 = "+string(BSMAJ6))
			print("BSMAJ7 = "+string(BSMAJ7))
			print("BSMAJ8 = "+string(BSMAJ8))
			}					
		}
		
	}

method bskeynotesMIN {
	min1Str=""
	min2Str=""
	min3Str=""
	min4Str=""
	min5Str=""
	min6Str=""
	min7Str=""
	min8Str=""
	print("Enter BS Minor Key phrases..Cancel to have default Key phrases")
	min1Str=getastr("BS MIN. 1 ->","")
	if (min1Str!="") {
		BSMIN1=phrase("'"+min1Str+"'")
		min2Str=getastr("BS MIN. 2 ->","") 
		if (min2Str!="") {
			BSMIN2=phrase("'"+min2Str+"'")
			min3Str=getastr("BS MIN. 3 ->","") 
			}
		if (min3Str!="") {
			BSMIN3=phrase("'"+min3Str+"'")
			min4Str=getastr("BS MIN. 4 ->","") 
			}
		if (min4Str!="") {
			BSMIN4=phrase("'"+min4Str+"'")
			min5Str=getastr("BS MIN. 5 ->","") 
			}
		if (min5Str!="") {
			BSMIN5=phrase("'"+min5Str+"'")
			min6Str=getastr("BS MIN. 6 ->","") 
			}
		if (min6Str!="") {
			BSMIN6=phrase("'"+min6Str+"'")
			min7Str=getastr("BS MIN. 7 ->","") 
			}
		if (min7Str!="") {
			BSMIN7=phrase("'"+min7Str+"'")
			min8Str=getastr("BS MIN. 8 ->","") 
			}
		if (min8Str!="") {
			BSMIN8=phrase("'"+min8Str+"'")
			print("BS MINOR KEY NOTES :")
			print("BSMIN1 = "+string(BSmin1))
			print("BSMIN2 = "+string(BSmin2))
			print("BSMIN3 = "+string(BSmin3))
			print("BSMIN4 = "+string(BSmin4))
			print("BSMIN5 = "+string(BSmin5))
			print("BSMIN6 = "+string(BSmin6))
			print("BSMIN7 = "+string(BSmin7))
			print("BSMIN8 = "+string(BSmin8))
			}					
		}
		
	}

method addrootpatt {
	NOROOT=0
	print("Enter timings for adding root notes")
	rootstr1=getastr("I ->","")
	if (rootstr1=="") {
		MAKEROOT1=4b
		MAKEROOT2=2b
		MAKEROOT3=1b
		MAKEROOT4=2b		
		print("Default root timings [4b-2b-1b-2b] will be used")
		}
	else {
		MAKEROOT1=integer(rootstr1)	
		rootstr2=getastr("II ->","")
		if (rootstr2=="") {
			MAKEROOT2=2b
			MAKEROOT3=1b
			MAKEROOT4=2b			
			print("Default root timings [2b-1b-2b]will be used for remaining slots")
			}
		else {
			MAKEROOT2=integer(rootstr2)	
			rootstr3=getastr("III ->","")
			if (rootstr3=="") {
				MAKEROOT3=1b
				MAKEROOT4=2b			
				print("Default root timings [1b-2b]will be used for remaining slots")
				}
			else {
				MAKEROOT3=integer(rootstr3)
				rootstr4=getastr("IV ->","")
				if (rootstr4=="") {
					MAKEROOT4=2b
					print("Default root timing [2b]will be used for the remaining slot")
					}
				else MAKEROOT4=integer(rootstr4)
				}
			}
		print ("Root timing pattern : \n I ->" + string(MAKEROOT1) + "\n II ->" + string(MAKEROOT2)+"\n III ->" + string(MAKEROOT3) + "\n IV ->"+string(MAKEROOT4))
		}
	}

method addrootnone {NOROOT=1}

#******************************************************************
#					SLIDERS
#******************************************************************

method updatelength(v) {
	print("Length : "+string(v))
	LENGTH=$.lengthsl.get()
}

method echo1num(v) {
	print("Echoes(1) : "+string(v))
	E1NUM=$.echo1numsl.get()

}
method echo1delay(v) {
	print("Delay (1) : "+string(v))
	E1DEL=$.echo1delaysl.get()
}

method echo2num(v) {
	print("Echoes(2) : "+string(v))
	E2NUM=$.echo2numsl.get()
}
method echo2delay(v) {
	print("Delay (2): "+string(v))
	E2DEL=$.echo2delaysl.get()
}

method echo3num(v) {
	print("Echoes(3): "+string(v))
	E3NUM=$.echo3numsl.get()
}
method echo3delay(v) {
	print("Delay (3): "+string(v))
	E3DEL=$.echo3delaysl.get()
}

method echo4num(v) {
	print("Echoes(4): "+string(v))
	E4NUM=$.echo4numsl.get()
}
method echo4delay(v) {
	print("Delay (4): "+string(v))
	E4DEL=$.echo4delaysl.get()
}
}

#********************************************************************
#					MENUS
#********************************************************************

function mkmenu_generate(o,po) {
	o.menucmd("Algorithm I",po,"algo1")
	o.menucmd("Algorithm II",po,"algo2")
	o.menucmd("Algorithm III",po,"algo3")
	o.submenu("Rework phrase ->","mkmenu_reworkphrase",po)
}	

function mkmenu_reworkphrase(o,po) {
	o.submenu("Echovariety->","mkmenu_selectphrase1",po)
	o.submenu("Polishit->","mkmenu_selectphrase2",po)
}
function mkmenu_selectphrase1(o,po) {
	o.menucmd("Midi file",po,"getmidifile1")
	o.menucmd("Phrase file IV",po,"getphrasefile1")
	o.menucmd("Snarf",po,"getsnarf1")
}
function mkmenu_selectphrase2(o,po) {
	o.menucmd("Midi file",po,"getmidifile2")
	o.menucmd("Phrase file",po,"getphrasefile2")
	o.menucmd("Snarf",po,"getsnarf2")
}
function mkmenu_getword(o,po) {
	o.menucmd("Input string",po,"getstring")
	o.menucmd("Read file",po,"readtextfile")
}
function mkmenu_bswww (o,po) {
	o.submenu("Key note->","mkmenu_bskeynote",po,1)
	o.menucmd("Key Phrases Major",po,"bskeynotesMAJ")
	o.menucmd("Key Phrases Minor",po,"bskeynotesMIN")
	o.submenu("Guide phrase ->","mkmenu_bskeyguide",po)
}
function mkmenu_bskeynote(o,po,ntstr) {
	o.submenu("C->","mkmenu_bskeyoctave",po,"c")
	o.submenu("C#->","mkmenu_bskeyoctave",po,"c+")
	o.submenu("D->","mkmenu_bskeyoctave",po,"d")
	o.submenu("D#->","mkmenu_bskeyoctave",po,"d+")
	o.submenu("E->","mkmenu_bskeyoctave",po,"e")
	o.submenu("F->","mkmenu_bskeyoctave",po,"f")
	o.submenu("F#->","mkmenu_bskeyoctave",po,"f+")
	o.submenu("G->","mkmenu_bskeyoctave",po,"g")
	o.submenu("G#->","mkmenu_bskeyoctave",po,"g+")
	o.submenu("A->","mkmenu_bskeyoctave",po,"a")
	o.submenu("A#->","mkmenu_bskeyoctave",po,"a+")
	o.submenu("B->","mkmenu_bskeyoctave",po,"b")
}
function mkmenu_bskeyoctave (o,po,ntstr,octstr) {
	o.menucmd("0 (Mid C)",po,"bskeyoctave",ntstr,"o3")
	o.menucmd("+1",po,"bskeyoctave",ntstr,"o4")
	o.menucmd("+2",po,"bskeyoctave",ntstr,"o5")
	o.menucmd("+3",po,"bskeyoctave",ntstr,"o6")
	o.menucmd("+4",po,"bskeyoctave",ntstr,"o7")
	o.menucmd("-1",po,"bskeyoctave",ntstr,"o2")
	o.menucmd("-2",po,"bskeyoctave",ntstr,"o1")
	o.menucmd("-3",po,"bskeyoctave",ntstr,"o0")
	o.menucmd("-4",po,"bskeyoctave",ntstr,"o-1")
}
function mkmenu_bskeyguide (o,po) {
	o.menucmd("Input phrase",po,"bsguidephrase")
	o.menucmd("Read midi file",po,"bsguidereadmidifile")
	o.menucmd("Read phrase file",po,"bsguidereadphrasefile")
	o.menucmd("Read snarf",po,"bsguidereadsnarf")
}
function mkmenu_bsguideinput (o,po) {
	o.submenu("Notes ->","mkmenu_bsguidenotes",po)
}

function mkmenu_wwwaddroot (o,po) {
	o.menucmd("Pattern",po,"addrootpatt")
	o.menucmd("None",po,"addrootnone")
}

#********************************************************************

#				MODIFIED ALGORITHMS

#				 B S W W M O D I F

#********************************************************************

function bswwwmodif(str,majmin) {

	if ( nargs() < 2 )
		majmin = 0

	bskey = BSKEY
	bsmajor = []
	bsmajor[ 1 ]= BSMAJ1
	bsmajor[ 2 ]= BSMAJ2
	bsmajor[ 3 ]= BSMAJ3
	bsmajor[ 4 ]= BSMAJ4
	bsmajor[ 5 ]= BSMAJ5
	bsmajor[ 6 ]= BSMAJ6
	bsmajor[ 7 ]= BSMAJ7
	bsmajor[ 8 ]= BSMAJ8
	bsminor = []
	bsminor[ 1 ]= BSMIN1
	bsminor[ 2 ]= BSMIN2
	bsminor[ 3 ]= BSMIN3
	bsminor[ 4 ]= BSMIN4
	bsminor[ 5 ]= BSMIN5
	bsminor[ 6 ]= BSMIN6
	bsminor[ 7 ]= BSMIN7
	bsminor[ 8 ]= BSMIN8
	
	ntimes = NTIMES
	p0 = strnotes(str)
	dodetense = 1
	if ( dodetense == 0 ) {
		p1 = p0
	}
	else {
		p1 = ''
		for ( n in p0 ) {
			if ( p1 == '' )
				p1 = lastn = n
			else {
				while ( tension(n,lastn) > 3 )
					n.pitch++
			}
			p1 |= n
		}
	}
	p = scatimes(p1,8)
	
	if (sizeof(BSGUIDEPHRASE)==0){
		guide = shuffle(repeat(p1,3*ntimes))
		guide = guide { isonbeat(??,3b) }
		guide =  octavefence(guide,72,72)
		}
	else guide=BSGUIDEPHRASE

	p2 = bsguide(majmin==0?bsmajor:bsminor,bskey,p,guide,1b/4,p.length)

	pend = latest(p2)
	p2a = p2 { isonbeat(??,2b) }
	p2b = gradinclude(p2,0.0,1.0,0)
	p2 = dedup(p2a | p2b)
	p2 = octavefence(p2,52,88)

	p2r = reverse(p2)
	p2rev = ''
	c = 4b
	for ( n=0; ; n=n+2 ) {
		z = cut(p2r,CUT_TIME,n*c,(n+1)*c)
		if ( sizeof(z) == 0 )
			break
		z.time -= n*c
		z.length = c
		p2rev += z
	}
	p2 = p2 + p2rev
	p2.chan = 1	# main melody


	p2x = makerootevery(p2,1b)
	p2x = gradinclude(p2x,0.0,1.0)
	p2x = octavefence(p2x,46,58)
	p2x.chan = 2	# piano
	p2 |= p2x
	l = latest(p2)
	if (NOROOT==0) {
		p2ya = makerootevery(cut(p2,CUT_TIME,0,l/4),MAKEROOT1)
		p2yb = makerootevery(cut(p2,CUT_TIME,l/4,l/2),MAKEROOT2)
		p2yc = makerootevery(cut(p2,CUT_TIME,l/2,3*l/4),MAKEROOT3)
		p2yd = makerootevery(cut(p2,CUT_TIME,3*l/4,l),MAKEROOT4)
		p2y = p2ya | p2yb | p2yc | p2yd
		}
	else	p2y = p2
	p2y = octavefence(p2y,34,46)
	p2y.chan = 3	# bass
	p2 |= p2y
	
	sus = sussect(2b)
	susp = sus
	while ( susp.length < p2.length )
		susp += sus
	susp.chan = 1
	patches =  progchange(47,1)
			| progchange(47,2)
			|  progchange(33,3)
	p3 = patches | p2 | susp
	return(p3)
}

#**************************************************************
#				ECHOVARIETY
#**************************************************************

function wwwechovariety(w) {
	w2 = addrootevery(w,MAKEROOT1)
	print("Echovariety <addroot 1> [Step:1/12] done ..")
	w3 = arpeggio(w2)
	print("Echovariety <arpeggio 1> [Step:2/12] done ..")
	w4 = echo(w3,E1NUM,E1DEL)
	print("Echovariety <echo 1> [Step:3/12] done ..")
	w4b = echo(w4,E2NUM,E2DEL)
	print("Echovariety <echo 2> [Step:4/12] done ..")
	w5 = echo(w4b,E3NUM,E3DEL)
	print("Echovariety <echo 3> [Step:5/12] done ..")
	w6 = echo(w5,4,E4NUM,E4DEL)
	print("Echovariety <echo 4> [Step:6/12] done ..")
	w7 = arpeggio(w6)
	print("Echovariety <arpeggio 2> [Step:7/12] done ..")
	w8 = transposeseqinplace(w7,w2)
	print("Echovariety <transposeseqinplace> [Step:8/12] done ..")
	w9 = octavefence(w8,54,90)
	print("Echovariety <octavefence> [Step:9/12] done ..")
	w10 = addrootevery(w9,MAKEROOT2)
	print("Echovariety <addroot 2> [Step:10/12] done ..")
	w11 = addrootevery(w10,MAKEROOT3)
	print("Echovariety <addroot 3>  [Step:11/12] done ..")
	w12 = scatimes(w11,0.5)
	print("Echovariety <scatimes> [Step:12/12] done ..")
	return(w12)
}

#**************************************************************
#				POLISHIT
#**************************************************************

function wwwpolishit(w) {
	leng = latest(w)
	m = mono(w,2)	# random priority
	m2 = octavefence(m,74,100)
	m2.chan=2
	m2b = echo(m2{??.number%4==0},4,1b/4,0.80)
	m2c1 = cut(m2|m2b,CUT_TIME,leng/4,leng/3){rand(4)==0}
	m2c2 = cut(m2|m2b,CUT_TIME,leng/3,leng/2){rand(3)==0}
	m2c3 = cut(m2|m2b,CUT_TIME,leng/2,leng)
	m2c = m2c1 | m2c2 | m2c3
	m2final = m2c | makerootevery(cut(m2c,CUT_TIME,2*leng/3),4b)
	m3 = octavefence(m,54,64)
	m3.chan = 10
	m4 = m3{??.number%2==0}
	m5 = m3{??.number%3==0}
	m6 = m3{??.number%4==0}
	m7 = quantize(cut(m3{??.number%3==0},CUT_TIME,3*leng/4,leng),1b)
	m4.pitch = 61
	m5.pitch = 60
	m6.pitch = 64
	m7.pitch = 70
	m4 = quantize(m4,1b)
	m5b = echo(m5{??.number%9==0},E1NUM,E1DEL,0.80)
	m6b = echo(m6{??.number%7==0},E2NUM,E2DEL,0.80)
	m7b = echo(m7{??.number%3==0},E3NUM,E3DEL,0.80)
	m7b1 = cut(m7b,CUT_TIME,0,7*leng/8)
	m7b2 = echo(cut(m7b,CUT_TIME,7*leng/8,leng),E4NUM,E4DEL,0.95)
	m7b = m7b1 | m7b2
	drumsfinal = cut(m4|m5|m6|m7|m5b|m6b|m7b,CUT_TIME,leng/2,leng)
	drumsfinal.vol *= 0.8

	nnotes = sizeof(w)
	www = echo(w%nnotes,16,1b/4,0.95)
	www2 = www
	www2.chan = 2

	return(m2final|drumsfinal|w|www|www2)
}
