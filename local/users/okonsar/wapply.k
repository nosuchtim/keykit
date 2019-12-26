#********************************************************************

#	WAPPLY 
#	by
#	Mehmet Okonsar
#	mokonsar@dominet.in.com.tr
#	Graphical Implementation of the function:
#	apply() by Tim Thompson
#	USAGE:
#	"PH1" : Load a midi file or the snarf contents to serve as 
#		source for applying its attributes
#	"PH2 - 4" : idem
#	"Apply" : Load still another phrase/file as the target
#		Apply to attributes:
#			pitches ; durations ; timings ; velocity 
#				anything from the sources 1, 2, 3 or 4
#		Clear : clear the resulting phrase
#		Write midi or Snarf as you wish

#*********************************************************************
class wapply {
method init {
	$.w = new window()
	$.inherit($.w)
	$.phrase1 = new wphrase()
	$.phrase2 = new wphrase()
	$.phrase3 = new wphrase()
	$.phrase4 = new wphrase()
	$.phrase5 = new wphrase()
	$.addchild($.phrase1)
	$.addchild($.phrase2)
	$.addchild($.phrase3)
	$.addchild($.phrase4)
	$.addchild($.phrase5)
	$.b1 = new kmenubutton("PH1","mkmenu_read1",$)
	$.b2 = new kmenubutton("PH2","mkmenu_read2",$)
	$.b3 = new kmenubutton("PH3","mkmenu_read3",$)
	$.b4 = new kmenubutton("PH4","mkmenu_read4",$)
	$.b5 = new kmenubutton("Apply","mkmenu_apply_attr",$)
	$.addchild($.b1)
	$.addchild($.b2)
	$.addchild($.b3)
	$.addchild($.b4)
	$.addchild($.b5)
	$.isset = 0
	$.stoptids = []
}
method redraw {
	$.w.redraw()
	methodbroadcast();
	$.w.text("Apply Phrase Attributes",
		xy($.xmin(),$.ymin(),$.xmax(),$.ymin()+$.textheight()))
}
method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	btnwidth = ($.xmax()-$.xmin()) / 10 # button width
	btnleft = $.xmin()+ 2
	btnheight=($.ymax()-$.ymin()-$.textheight() - 4 - 9)/5
	btnright=$.xmin()+(($.xmax()-$.xmin())/10)
	btn1top=$.ymin()+$.textheight()+4
	btn1bottom=btn1top+btnheight
	btn2top=btn1bottom+2
	btn2bottom=btn2top+btnheight
	btn3top=btn2bottom+2
	btn3bottom=btn3top+btnheight	
	btn4top=btn3bottom+2
	btn4bottom=btn4top+btnheight	
	btn5top=btn4bottom+2
	btn5bottom=btn5top+btnheight	
	$.b1.resize(xy(btnleft,btn1top,btnright,btn1bottom))
	$.b2.resize(xy(btnleft,btn2top,btnright,btn2bottom))
	$.b3.resize(xy(btnleft,btn3top,btnright,btn3bottom))
	$.b4.resize(xy(btnleft,btn4top,btnright,btn4bottom))
	$.b5.resize(xy(btnleft,btn5top,btnright,btn5bottom+2))

	$.phrase1.resize(xy(btnleft+btnwidth +2,btn1top,$.xmax()-2,btn1bottom))
	$.phrase2.resize(xy(btnleft+btnwidth +2,btn2top,$.xmax()-2,btn2bottom))
	$.phrase3.resize(xy(btnleft+btnwidth +2,btn3top,$.xmax()-2,btn3bottom))
	$.phrase4.resize(xy(btnleft+btnwidth +2,btn4top,$.xmax()-2,btn4bottom))
	$.phrase5.resize(xy(btnleft+btnwidth +2,btn5top,$.xmax()-2,btn5bottom+2))

}

method delete {
	killtids($.stoptids)
	$.stoptids = []
}

#********************************************************************

method set1 (p,doredraw) {
	p = onlynotes(p)
	$.phrase1.set(p,0)
	$.phrase1.fitall()
	if ( nargs() > 1 && doredraw )
		$.phrase1.redraw()
	$.isset = 0
}
method set2 (p,doredraw) {
	p = onlynotes(p)
	$.phrase2.set(p,0)
	$.phrase2.fitall()
	if ( nargs() > 1 && doredraw )
		$.phrase2.redraw()
	$.isset = 0
}
method set3 (p,doredraw) {
	p = onlynotes(p)
	$.phrase3.set(p,0)
	$.phrase3.fitall()
	if ( nargs() > 1 && doredraw )
		$.phrase3.redraw()
	$.isset = 0
}
method set4 (p,doredraw) {
	p = onlynotes(p)
	$.phrase4.set(p,0)
	$.phrase4.fitall()
	if ( nargs() > 1 && doredraw )
		$.phrase4.redraw()
	$.isset = 0
}

method set5 (p,doredraw) {
	RESTOREPHRASE=$.phrase5
	p = onlynotes(p)
	$.phrase5.set(p,0)
	$.phrase5.fitall()
	if ( nargs() > 1 && doredraw )
		$.phrase5.redraw()
	$.isset = 0
}

#********************************************************************
#		PLAY


method get {
	return($.phrase5.get())
}
method play (stime) {
	if ( $.phrase1.isplaying() || $.phrase2.isplaying() || $.phrase3.isplaying() || $.phrase4.isplaying()|| $.phrase5.isplaying())
		$.stop()
	if ( nargs() < 1 ) {
		stime = nextquant(Now,1b)
	}
	tid = $.phrase2.play(stime,1b)
	$.stoptids[tid] = 1
}
method stop {
	killtids($.stoptids)
	$.stoptids = []
	$.phrase1.stop()
	$.phrase2.stop()
	$.phrase3.stop()
	$.phrase4.stop()
	$.phrase5.stop()
}
method mousedown (m) {
	if ( $.phrase1.contains(m) ) {
		if ( $.phrase1.isplaying() || $.phrase2.isplaying() || $.phrase3.isplaying() || $.phrase4.isplaying()|| $.phrase5.isplaying())
			$.stop()
		else {
			tid = $.phrase1.play(nextquant(Now,1b))
			$.stoptids[tid] = 1
		}
	}
	else if ( $.phrase2.contains(m) ) {
		if ( $.phrase1.isplaying() || $.phrase2.isplaying() || $.phrase3.isplaying() || $.phrase4.isplaying()|| $.phrase5.isplaying())
			$.stop()
		else {
			tid = $.phrase2.play(nextquant(Now,1b))
			$.stoptids[tid] = 1
		}
	}
	else if ( $.phrase3.contains(m) ) {
		if ( $.phrase1.isplaying() || $.phrase2.isplaying() || $.phrase3.isplaying() || $.phrase4.isplaying()|| $.phrase5.isplaying())
			$.stop()
		else {
			tid = $.phrase3.play(nextquant(Now,1b))
			$.stoptids[tid] = 1
		}
	}
	else if ( $.phrase4.contains(m) ) {
		if ( $.phrase1.isplaying() || $.phrase2.isplaying() || $.phrase3.isplaying() || $.phrase4.isplaying()|| $.phrase5.isplaying())
			$.stop()
		else {
			tid = $.phrase4.play(nextquant(Now,1b))
			$.stoptids[tid] = 1
		}
	}
	else if ( $.phrase5.contains(m) ) {
		if ( $.phrase1.isplaying() || $.phrase2.isplaying() || $.phrase3.isplaying() || $.phrase4.isplaying()|| $.phrase5.isplaying())
			$.stop()
		else {
			tid = $.phrase5.play(nextquant(Now,1b))
			$.stoptids[tid] = 1
		}
	}
	else {
		mouseforward(m,"mousedown")
	}
}
method dump {
	return ( [ "phrase" = $.phrase1.get() ] )
	return ( [ "phrase" = $.phrase2.get() ] )
	return ( [ "phrase" = $.phrase3.get() ] )
	return ( [ "phrase" = $.phrase4.get() ] )
	return ( [ "phrase" = $.phrase5.get() ] )
}
method restore (state) { $.set(state["phrase"]) }

method snarf { Snarf = $.phrase5.get() }

#********************************************************************

#			LOADING

method loadsnarf1 {
	ORIGINALPHRASE1= Snarf
	ORIGINALPHRASE1= syncphr(ORIGINALPHRASE1)
	if ( (ORIGINALPHRASE1%1).time > (Met.length/2) ) {
		ORIGINALPHRASE1.time -= Met.length
		ORIGINALPHRASE1.length -= Met.length
	}
	$.set1(ORIGINALPHRASE1,1)
}
method loadsnarf2 {
	ORIGINALPHRASE2= Snarf
	ORIGINALPHRASE2= syncphr(ORIGINALPHRASE2)
	if ( (ORIGINALPHRASE2%1).time > (Met.length/2) ) {
		ORIGINALPHRASE2.time -= Met.length
		ORIGINALPHRASE2.length -= Met.length
	}
	$.set2(ORIGINALPHRASE2,1)
}
method loadsnarf3 {
	ORIGINALPHRASE3= Snarf
	ORIGINALPHRASE3= syncphr(ORIGINALPHRASE3)
	if ( (ORIGINALPHRASE3%1).time > (Met.length/2) ) {
		ORIGINALPHRASE3.time -= Met.length
		ORIGINALPHRASE3.length -= Met.length
	}
	$.set3(ORIGINALPHRASE3,1)
}
method loadsnarf4 {
	ORIGINALPHRASE4= Snarf
	ORIGINALPHRASE4= syncphr(ORIGINALPHRASE4)
	if ( (ORIGINALPHRASE4%1).time > (Met.length/2) ) {
		ORIGINALPHRASE4.time -= Met.length
		ORIGINALPHRASE4.length -= Met.length
	}
	$.set4(ORIGINALPHRASE4,1)
}

method loadtargetsnarf {
	TARGETPHRASE= Snarf
	TARGETPHRASE= syncphr(TARGETPHRASE)
	if ( (TARGETPHRASE%1).time > (Met.length/2) ) {
		TARGETPHRASE.time -= Met.length
		TARGETPHRASE.length -= Met.length
	}
	$.set5(TARGETPHRASE,1)
}

method loadfile1 {
	$.stop()
	ORIGINALPHRASENOTES1= 0
	ORIGINALPHRASE1= onlynotes(browsephrase())
	oph = ORIGINALPHRASE1
	if ( sizeof(ORIGINALPHRASE1) > 0 )
		$.set1(ORIGINALPHRASE1,1)
	for ( nt in oph ) 
		ORIGINALPHRASENOTES1++
	print ("Phrase 1 ; Notes : "+string(ORIGINALPHRASENOTES1))
}
method loadfile2 {
	$.stop()
	ORIGINALPHRASENOTES2 = 0
	ORIGINALPHRASE2 = onlynotes(browsephrase())
	oph = ORIGINALPHRASE2
	if ( sizeof(ORIGINALPHRASE2) > 0 )
		$.set2(ORIGINALPHRASE2,1)
	for ( nt in oph ) 
		ORIGINALPHRASENOTES2++
	print ("Phrase 2 ; Notes : "+string(ORIGINALPHRASENOTES2))
}
method loadfile3 {
	$.stop()
	ORIGINALPHRASENOTES3 = 0
	ORIGINALPHRASE3 = onlynotes(browsephrase())
	oph = ORIGINALPHRASE3
	if ( sizeof(ORIGINALPHRASE3) > 0 )
		$.set3(ORIGINALPHRASE3,1)
	for ( nt in oph ) 
		ORIGINALPHRASENOTES3++
	print ("Phrase 3 ; Notes : "+string(ORIGINALPHRASENOTES3))
}
method loadfile4 {
	$.stop()
	ORIGINALPHRASENOTES4 = 0
	ORIGINALPHRASE4 = onlynotes(browsephrase())
	oph = ORIGINALPHRASE4
	if ( sizeof(ORIGINALPHRASE4) > 0 )
		$.set4(ORIGINALPHRASE4,1)
	for ( nt in oph ) 
		ORIGINALPHRASENOTES4 ++
	print ("Phrase 4 ; Notes : "+string(ORIGINALPHRASENOTES4 ))
}

method loadtargetmidi{
	$.stop()
	TARGETPHRASENOTES= 0
	TARGETPHRASE= onlynotes(browsephrase())
	oph = TARGETPHRASE
	if ( sizeof(TARGETPHRASE) > 0 )
		$.set5(TARGETPHRASE,1)
	for ( nt in oph ) 
		TARGETPHRASENOTES++
	print ("Phrase target ; Notes : "+string(TARGETPHRASENOTES))
}

#********************************************************************
#		APPLY

method apppitch1 {
	TARGETPHRASE=apply(TARGETPHRASE,ORIGINALPHRASE1,PITCH)
	if ( sizeof(TARGETPHRASE) > 0 )
		$.set5(TARGETPHRASE,1)
} 
method apppitch2 {
	TARGETPHRASE=apply(TARGETPHRASE,ORIGINALPHRASE2,PITCH)
	if ( sizeof(TARGETPHRASE) > 0 )
		$.set5(TARGETPHRASE,1)
} 
method apppitch3 {
	TARGETPHRASE=apply(TARGETPHRASE,ORIGINALPHRASE3,PITCH)
	if ( sizeof(TARGETPHRASE) > 0 )
		$.set5(TARGETPHRASE,1)
} 
method apppitch4 {
	TARGETPHRASE=apply(TARGETPHRASE,ORIGINALPHRASE4,PITCH)
	if ( sizeof(TARGETPHRASE) > 0 )
		$.set5(TARGETPHRASE,1)
} 

method appdur1 {
	TARGETPHRASE=apply(TARGETPHRASE,ORIGINALPHRASE1,DURATION)
	if ( sizeof(TARGETPHRASE) > 0 )
		$.set5(TARGETPHRASE,1)
} 
method appdur2 {
	TARGETPHRASE=apply(TARGETPHRASE,ORIGINALPHRASE2,DURATION)
	if ( sizeof(TARGETPHRASE) > 0 )
		$.set5(TARGETPHRASE,1)
} 
method appdur3 {
	TARGETPHRASE=apply(TARGETPHRASE,ORIGINALPHRASE3,DURATION)
	if ( sizeof(TARGETPHRASE) > 0 )
		$.set5(TARGETPHRASE,1)
} 
method appdur4 {
	TARGETPHRASE=apply(TARGETPHRASE,ORIGINALPHRASE4,DURATION)
	if ( sizeof(TARGETPHRASE) > 0 )
		$.set5(TARGETPHRASE,1)
} 

method apptime1 {
	TARGETPHRASE=apply(TARGETPHRASE,ORIGINALPHRASE1,TIME)
	if ( sizeof(TARGETPHRASE) > 0 )
		$.set5(TARGETPHRASE,1)
} 
method apptime2 {
	TARGETPHRASE=apply(TARGETPHRASE,ORIGINALPHRASE2,TIME)
	if ( sizeof(TARGETPHRASE) > 0 )
		$.set5(TARGETPHRASE,1)
} 
method apptime3 {
	TARGETPHRASE=apply(TARGETPHRASE,ORIGINALPHRASE3,TIME)
	if ( sizeof(TARGETPHRASE) > 0 )
		$.set5(TARGETPHRASE,1)
} 
method apptime4 {
	TARGETPHRASE=apply(TARGETPHRASE,ORIGINALPHRASE4,TIME)
	if ( sizeof(TARGETPHRASE) > 0 )
		$.set5(TARGETPHRASE,1)
} 

method appvel1 {
	TARGETPHRASE=apply(TARGETPHRASE,ORIGINALPHRASE1,VOLUME)
	if ( sizeof(TARGETPHRASE) > 0 )
		$.set5(TARGETPHRASE,1)
} 
method appvel2 {
	TARGETPHRASE=apply(TARGETPHRASE,ORIGINALPHRASE2,VOLUME)
	if ( sizeof(TARGETPHRASE) > 0 )
		$.set5(TARGETPHRASE,1)
} 
method appvel3 {
	TARGETPHRASE=apply(TARGETPHRASE,ORIGINALPHRASE3,VOLUME)
	if ( sizeof(TARGETPHRASE) > 0 )
		$.set5(TARGETPHRASE,1)
} 
method appvel4 {
	TARGETPHRASE=apply(TARGETPHRASE,ORIGINALPHRASE4,VOLUME)
	if ( sizeof(TARGETPHRASE) > 0 )
		$.set5(TARGETPHRASE,1)
} 

#********************************************************************

method clearresult{
	$.set5('',1)
	$.redraw()
}

method savetomid {
	p=$.phrase5
	fname = browsefiles("Midi files (*.mid)","*.mid",1)
	if (sizeof(fname )>0){
		writemf(p,fname )
		print ("Saved to : "+fname )
	}
	else
	print("Saving cancelled")
}

}

function mkmenu_read1(o,po) {
	o.menucmd("Read Midi File",po,"loadfile1")
	o.menucmd("Read Snarf",po,"loadsnarf1")
}

function mkmenu_read2(o,po) {
	o.menucmd("Read Midi File",po,"loadfile2")
	o.menucmd("Read Snarf",po,"loadsnarf2")
}
function mkmenu_read3(o,po) {
	o.menucmd("Read Midi File",po,"loadfile3")
	o.menucmd("Read Snarf",po,"loadsnarf3")
}
function mkmenu_read4(o,po) {
	o.menucmd("Read Midi File",po,"loadfile4")
	o.menucmd("Read Snarf",po,"loadsnarf4")
}

function mkmenu_apply_attr(o,po) {
	o.submenu("Load ->","mkmenu_loadtarget",po)
	o.submenu("Apply to Pitches ->","mkmenu_apppitch",po)
	o.submenu("Apply to Durations ->","mkmenu_appdur",po)
	o.submenu("Apply to Timings ->","mkmenu_apptime",po)
	o.submenu("Apply to Velocities ->","mkmenu_appvel",po)
	o.menucmd("Clear",po,"clearresult")
	o.menucmd("Snarf",po,"snarf")
	o.menucmd("Write",po,"savetomid")
}

function mkmenu_loadtarget(o,po) {
	o.menucmd("Midi File",po,"loadtargetmidi",n)
	o.menucmd("Snarf",po,"loadtargetsnarf",n)
}

function mkmenu_apppitch(o,po) {
	o.menucmd("Phrase 1",po,"apppitch1",n)
	o.menucmd("Phrase 2",po,"apppitch2",n)
	o.menucmd("Phrase 3",po,"apppitch3",n)
	o.menucmd("Phrase 4",po,"apppitch4",n)
}

function mkmenu_appdur(o,po) {
	o.menucmd("Phrase 1",po,"appdur1",n)
	o.menucmd("Phrase 2",po,"appdur2",n)
	o.menucmd("Phrase 3",po,"appdur3",n)
	o.menucmd("Phrase 4",po,"appdur4",n)
}

function mkmenu_apptime(o,po) {
	o.menucmd("Phrase 1",po,"apptime1",n)
	o.menucmd("Phrase 2",po,"apptime2",n)
	o.menucmd("Phrase 3",po,"apptime3",n)
	o.menucmd("Phrase 4",po,"apptime4",n)
}

function mkmenu_appvel(o,po) {
	o.menucmd("Phrase 1",po,"appvel1",n)
	o.menucmd("Phrase 2",po,"appvel2",n)
	o.menucmd("Phrase 3",po,"appvel3",n)
	o.menucmd("Phrase 4",po,"appvel4",n)
}
