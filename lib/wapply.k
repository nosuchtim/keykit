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
	$.phrase = []
	$.nphrases = 4
	$.b = []
	for ( n=1; n<=5; n++ )
		$.phrase[n] = new wphrase()
	# create buttons
	for ( n=1; n<5; n++ )
		$.b[n] = new kmenubutton("PH"+string(n),"mkmenu_applyread",$,n)
	# 5th button is different
	$.b[5] = new kmenubutton("Apply","mkmenu_apply_attr",$)
	for ( n=1; n<=5; n++ ) {
		$.addchild($.phrase[n])
		$.addchild($.b[n])
	}
	$.isset = 0
	$.stoptids = []
	$.original = []
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
	btnheight=($.ymax()-$.ymin()-$.textheight() - 4 - 9)/5
	btnleft = $.xmin()+ 2
	btnright=$.xmin()+$.textwidth()*7
	xmid = ($.xmin()+$.xmax()) / 2
	if ( btnright > xmid )
		btnright = xmid
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
	$.b[1].resize(xy(btnleft,btn1top,btnright,btn1bottom))
	$.b[2].resize(xy(btnleft,btn2top,btnright,btn2bottom))
	$.b[3].resize(xy(btnleft,btn3top,btnright,btn3bottom))
	$.b[4].resize(xy(btnleft,btn4top,btnright,btn4bottom))
	$.b[5].resize(xy(btnleft,btn5top,btnright,btn5bottom+2))

	$.phrase[1].resize(xy(btnright +2,btn1top,$.xmax()-2,btn1bottom))
	$.phrase[2].resize(xy(btnright +2,btn2top,$.xmax()-2,btn2bottom))
	$.phrase[3].resize(xy(btnright +2,btn3top,$.xmax()-2,btn3bottom))
	$.phrase[4].resize(xy(btnright +2,btn4top,$.xmax()-2,btn4bottom))
	$.phrase[5].resize(xy(btnright +2,btn5top,$.xmax()-2,btn5bottom+2))

}

method delete {
	killtids($.stoptids)
	$.stoptids = []
}

#********************************************************************

method getn (n) {
	return($.phrase[n].get())
}

method setn (p,doredraw,n) {

	$.original[n] = p

	p = onlynotes(p)
	$.phrase[n].set(p,0)
	$.phrase[n].fitall()
	if ( nargs() > 1 && doredraw )
		$.phrase[n].redraw()
	$.isset = 0
}

# The target phrase is phrase 5
method settarget (p,doredraw) {
	$.target = p
	$.setn(p,doredraw,5)
}

#********************************************************************
#		PLAY


method get {
	return($.getn(5))
}
method play (stime) {
	if ( $.anyplaying() )
		$.stop()
	if ( nargs() < 1 ) {
		stime = nextquant(Now,1b)
	}
	tid = $.phrase[5].play(stime,1b)
	$.stoptids[tid] = 1
}
method stop {
	killtids($.stoptids)
	$.stoptids = []
	for ( n=1; n<=5; n++ )
		$.phrase[n].stop()
}
method anyplaying() {
	for ( n=1; n<=5; n++ ) {
		if ( $.phrase[n].isplaying() )
			return(1)
	}
	return(0)
}
method mousedown (m) {
	for ( n=1; n<=5; n++ ) {
		if ( $.phrase[n].contains(m) ) {
			if ( $.anyplaying() )
				$.stop()
			else {
				tid = $.phrase[n].play(nextquant(Now,1b))
				$.stoptids[tid] = 1
			}
			return()
		}
	}
	mouseforward(m,"mousedown")
}

method dump {
	st = []
	for ( n=1; n<=4; n++ ) {
		st["phrase"+string(n)] = $.getn(n)
	}
	st["target"] = $.getn(5)
	return(st)
}

method restore (state) {
	for ( n=1; n<=4; n++ ) {
		$.setn(state["phrase"+string(n)],0,n)
	}
	$.settarget(state["target"],0)
}

method snarf { Snarf = $.getn(5) }

#********************************************************************

#			LOADING

method loadsnarf(n) {
	p = Snarf
	p = syncphr(p)
	if ( (p%1).time > (Met.length/2) ) {
		p.time -= Met.length
		p.length -= Met.length
	}
	$.setn(p,1,n)
}

method loadtargetph(n) {
	$.loadtargetwith($.original[n])
}
method loadtargetsnarf {
	$.loadtargetwith(Snarf)
}
method loadtargetwith(p) {
	p= syncphr(p)
	if ( (p%1).time > (Met.length/2) ) {
		p.time -= Met.length
		p.length -= Met.length
	}
	$.settarget(p,1)
}

method loadfile(n) {
	$.stop()
	p= onlynotes(browsephrase())
	if ( sizeof(p) > 0 )
		$.setn(p,1,n)
}

method loadtargetmidi() {
	$.stop()
	p= onlynotes(browsephrase())
	if ( sizeof(p) > 0 )
		$.settarget(p,1)
}

#********************************************************************
#		APPLY

method apppitch(n) {
	p=apply($.target,$.original[n],PITCH)
	if ( sizeof(p) > 0 )
		$.settarget(p,1)
} 
method appdur(n) {
	p=apply($.target,$.original[n],DURATION)
	if ( sizeof(p) > 0 )
		$.settarget(p,1)
}
method apptime(n) {
	p=apply($.target,$.original[n],TIME)
	if ( sizeof(p) > 0 )
		$.settarget(p,1)
}
method appvel(n) {
	p=apply($.target,$.original[n],VOLUME)
	if ( sizeof(p) > 0 )
		$.settarget(p,1)
} 

#********************************************************************

method clearresult{
	$.settarget('',1)
	$.redraw()
}

method savetomid {
	p=$.phrase[5].get()
	fname = browsefiles("Midi files (*.mid)","*.mid",0)
	if (sizeof(fname )>0){
		writemf(p,fname )
		print ("Saved to : "+fname )
	}
	else
	print("Saving cancelled")
}

}

function mkmenu_applyread(o,po,n) {
	o.menucmd("Read Midi File",po,"loadfile",n)
	o.menucmd("Read Snarf",po,"loadsnarf",n)
}

function mkmenu_apply_attr(o,po) {
	o.submenu("Load               ->","mkmenu_loadtarget",po)
	o.submenu("Apply to Pitches   ->","mkmenu_apppitch",po)
	o.submenu("Apply to Durations ->","mkmenu_appdur",po)
	o.submenu("Apply to Timings   ->","mkmenu_apptime",po)
	o.submenu("Apply to Velocities->","mkmenu_appvel",po)
	o.menucmd("Clear",po,"clearresult")
	o.menucmd("Snarf",po,"snarf")
	o.menucmd("Write",po,"savetomid")
}

function mkmenu_loadtarget(o,po) {
	o.menucmd("Midi File",po,"loadtargetmidi",n)
	o.menucmd("Snarf",po,"loadtargetsnarf",n)
	for ( n=1; n<=4; n++ )
		o.menucmd("Phrase "+string(n),po,"loadtargetph",n)
}

function mkmenu_apppitch(o,po) {
	for ( n=1; n<=4; n++ )
		o.menucmd("Phrase "+string(n),po,"apppitch",n)
}

function mkmenu_appdur(o,po) {
	for ( n=1; n<=4; n++ )
		o.menucmd("Phrase "+string(n),po,"appdur",n)
}

function mkmenu_apptime(o,po) {
	for ( n=1; n<=4; n++ )
		o.menucmd("Phrase "+string(n),po,"apptime",n)
}

function mkmenu_appvel(o,po) {
	for ( n=1; n<=4; n++ )
		o.menucmd("Phrase "+string(n),po,"appvel",n)
}
