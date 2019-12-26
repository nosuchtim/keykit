#name	wsmmgroup
#usage	wsmmgroup()
#desc	Create a phrase group for multi-track editing.

class wsmmgroup {

method init {
	$.w = new window()
	$.inherit($.w)

	$.initall()
	$.setgroupname("New")

	$.addtrack()
	$.dispmore(0)
	$.makemerged(0)
	$.viewout()
	$.undoclear()
	$.zoomclear()
}

method initall() {

	$.dumpvars = arraylist("view","groupname")

	$.initbasicvars()

	# The buttonact array dimensions are button number (1,2)
	#			and modifier (0=normal, 1=control, 2=shift)
	$.buttonact = [ 1=[0=0,1=0,2=0],
			2=[0=0,1=0,2=0] ]

	$.autofit = 1
	$.autoviewpick = 1
	$.laststime = 0
	$.laststop = 0
	$.playoffset = 0
	$.arg = 0

	# arrays that control what the mouse buttons do.
	$.val2buttontype = $.makebuttonarray("type")
	$.val2controller = $.makebuttonarray("ctlr")
	$.val2notifymeth = $.makebuttonarray("meth")
	$.val2arg = $.makebuttonarray("arg")

#	$.b0 = new kmenubutton("File","mkmenu_group1",$)
	$.b1 = new kmenubutton("View","mkmenu_groupview",$)
	$.b2 = new kmenubutton("Edit","mkmenu_edit",$)
	$.b3 = new kvalbutton([0="Normal",1="Control",2="Shift"],
			$,"modchanged",REDRAW);
	$.buttmod = 0	# Normal

	$.buttvals = $.makebuttonarray("name")

	$.vb = []
	$.vb[1] = new kmsbutton( $, "buttchanged", 1 )
	$.vb[2] = new kmsbutton( $, "buttchanged", 2 )

#	$.addchild($.b0)
	$.addchild($.b1)
	$.addchild($.b2)
	$.addchild($.b3)
	$.addchild($.vb[1])
	$.addchild($.vb[2])
#	$.dontdelete = arraylist($.b0,$.b1,$.b2,$.b3,$.vb[1],$.vb[2])
	$.dontdelete = arraylist($.b1,$.b2,$.b3,$.vb[1],$.vb[2])

	# Initial settings of mouse buttons is determined by
	# the GroupActions array, which is a grotesque thing
	# filled with magic numbers that correspond to the
	# entries in the buttinfo array.

	# Defaults for Button 1
	# for normal mousedown (0=Aud sweep)
	# for control-mousedown (2=Pick sweep)
	# for shift-mousedown (42=Tool, 25=pluck)

	# Defaults for Button 2
	# for normal mousedown (1=Aud Play)
	# for control-mousedown (7=Drag Dur)
	# for shift-mousedown (6=Drag)

	if ( ! defined(GroupActions) ) {
		global GroupActions
		GroupActions = [ 1=[0=0,1=2,2=25], 2=[0=1,1=7,2=6] ]
	}

	for ( bn=1; bn<=2; bn++ ) {
		for ( mod=0; mod<3; mod++ )
			$.setbutton( GroupActions[bn][mod], bn, NOREDRAW, mod )
	}
	$.modchanged($.buttmod,NOREDRAW)

	# initialize patch map
	p = patchmap()
	psz = sizeof(p)
	$.pname = [0="None"]
	$.pnum = [0=0]
	for ( n=0; n<psz; n++ ) {
		$.pname[n+1] = p[n]["name"]
		$.pnum[n+1] = p[n]["num"]
	}
}

method auditionchanged (aud) { $.audition = aud }
method auditionall {
	p = $.getaudition()
	$.audition=["start"=p%1.time,"end"=latest(p)]
}
method smmauditionbars (v) {
	$.audition = ["start"=(v["x0"]),"end"=(v["x1"])]
	$.playaudition()
}
method auditionview {
	v = $.view
	$.audition = ["start"=v["x0"],"end"=v["x1"]]
}
method redrawtracks (trks) {
	if ( nargs() > 0 ) {
		for ( tn in trks )
			$.redrawtn(tn)
	}
	else {
		# redraw all displayed tracks
		for ( dn=0; dn<$.ndisp; dn++ )
			$.c[dn].redraw()
	}
}
method tracklabels { return(arraycopy($.tn2label)) }
method getaudition {
	return($.get())
}
method get {
	# This gets the audition notes, not the raw tools
	$.makemerged(0)
	return($.c[0].get())
}
method getraw() {
	r = ''
	for ( tn in $.trk ) {
		if ( tn == 0 )
			continue
		t = $.trk[tn]
		if ( t == $0 || t == $-1 ) {
			print("Track tn=",tn," is gone?!")
		} else {
			r |= $.trk[tn].get()
		}
	}
	return(r)
}
method reset {
	$.makemerged(0)
	$.viewout()
	$.undoclear()
	$.zoomclear()
	$.auditionall()
	$.resize()
	$.redraw()
}
method refit (doredraw,dofitpick,trks) {
	# return value tells whether we redrew 
	if ( nargs() < 2 )
		dofitpick = 1
	if ( nargs() < 3 )
		trks = 0	# do all tracks
	if ( dofitpick && $.autoviewpick ) {
		$.fitpick(0,1,trks)
	}
	if ( $.autofit ) {
		$.fitvert(doredraw,trks)
		return(doredraw)
	}
	return(0)
}
method fitvert (doredraw,trks) {
	if ( nargs() < 1 )
		doredraw = 0
	if ( nargs() < 2 )
		trks = 0	# means do all tracks
	for ( dn=0; dn<$.ndisp; dn++ ) {
		if ( trks != 0 ) {
			# only do the tracks in trks (and trk 0)
			tn = $.dn2tn[dn]
			if ( tn!=0 && !(tn in trks) || sizeof(trks[tn])==0 ) {
				continue
			}
		}
		$.c[dn].fitvert()
		if ( doredraw!=0 ) {
			$.c[dn].redraw()
		}
	}
}
method fitpick (doredraw,keepview,trks) {
	if ( nargs() < 2 )
		keepview = 0
	p = $.c[0].get()
	p = cut(p,CUT_FLAGS,1)
	lim = limitsof(p)
	if ( sizeof(p)==0 || sizeof(lim)==0 )
		return()
	gx0 = lim["earliest"]
	gx1 = lim["latest"]
	# provide some extra breathing room
	xinc = (gx1 - gx0)/16
	gx0 -= xinc
	gx1 += xinc
	if ( keepview ) {
		if ( gx0 > $.view["x0"] )
			gx0 = $.view["x0"]
		if ( gx1 < $.view["x1"] )
			gx1 = $.view["x1"]
	}
	v = xy(gx0,$.view["y0"],gx1,$.view["y1"])
	$.viewset(v)
	if ( $.autofit )
		$.fitvert(0)
	if ( doredraw )
		$.redraw()
}
method startzoominx {
	grabmouse($)
	setmouse(LEFTRIGHT)
	$.fifo = f = open()
	task $.task_dozoomin(f,"x")
}
method zoomback {
	if ( $.zoompop() )
		$.redraw()
}
method viewout (doredraw,outtype) {
	if ( nargs() == 0 ) {
		doredraw = 0
		outtype = 1	# default is out all
	}
	dorefit = 1
	if ( outtype == 0 ) {
		# out a bit (on both sides)
		v = $.view
		dx = v["x1"] - v["x0"]
		v["x0"] -= dx
		v["x1"] += dx
	}
	else if ( outtype == 1 ) {
		# view entire phrase
		g = $.getraw()
		lim = limitsof(g)
		if ( sizeof(g)==0 || sizeof(lim)==0 )
			return()
		gx0 = lim["earliest"]
		gx1 = lim["latest"]
		# provide some extra breathing room
		xinc = (gx1 - gx0)/16
		gx0 -= xinc
		gx1 += xinc
		v = xy(gx0,0,gx1,127)
	}
	else if ( outtype == 2 ) {
		# lengthen by a factor of 2
		v = $.view
		dx = v["x1"] - v["x0"]
		v["x1"] += dx
	}
	else if ( outtype == 3 ) {
		# full height
		v = $.view
		# if already there, don't redraw
		if ( v["y0"]==0 && v["y1"]==127 && doredraw==1 )
			doredraw = 0
		v["y0"] = 0
		v["y1"] = 127
		dorefit = 0
	}
	else
		error("Unknown outtype="+string(outtype))
	$.viewset(v)
	if ( dorefit )
		$.refit(doredraw,0)
	else if ( doredraw )
		$.redraw()
}
method zoompush {
	n = $.zoomnext
	$.zoomstart[n] = $.view
	if ( ++($.zoomnext) > Zoomlimit )
		$.zoomnext = 0
	if ( $.zoomnext == $.zoomlast ) {
		# we've wrapped around, eliminate oldest
		if ( ++($.zoomlast) > Zoomlimit )
			$.zoomlast = 0
	}
}
method smmzoompush (arr) {
	n = $.zoomnext
	$.zoomstart[n] = arr
	if ( ++($.zoomnext) > Zoomlimit )
		$.zoomnext = 0
	if ( $.zoomnext == $.zoomlast ) {
		# we've wrapped around, eliminate oldest
		if ( ++($.zoomlast) > Zoomlimit )
			$.zoomlast = 0
	}
}
method zoompop {
	if ( $.zoomnext == $.zoomlast ) {
		print("Can't zoom back any more!")
		return(0)
	}
	if ( --($.zoomnext) < 0 )
		$.zoomnext = Zoomlimit
	$.viewset($.zoomstart[$.zoomnext])
	$.refit(0,0)
	return(1)
}
method zoomclear {
	$.zoomstart = []
	$.zoomnext = 0
	$.zoomlast = 0
}
method redrawtn (tn) {
	dn = lookup($.dn2tn,tn,-1)
	if ( dn >= 0 )
		$.c[dn].redraw()
}
method setgroupname (name) { $.groupname = name }
method undoclear { methodbroadcast() }
method viewset (sz) {
	$.view = sz
	methodbroadcast(sz)
}
method smmviewset (sz) {
	$.view = sz
	methodbroadcast(sz)
#		$.refit(1,0)
#	$.redraw()
}
method phrasechanged { $.makemerged(0); $.redraw() }

method modchanged (mod,doredraw) {
	$.buttmod = mod
	$.setbutton( $.buttonact[1][mod], 1, doredraw, $.buttmod )
	$.setbutton( $.buttonact[2][mod], 2, doredraw, $.buttmod )
}

method buttchanged (v,b) {
	if ( ! (v in $.val2buttontype) )
	 	print("Unexpected value v=",v," in .valchanged!?")
	else {
		$.setbutton(v,b,REDRAW,$.buttmod)
	}
}

method settingchanged (v,dn) {
	$.setpatch($.pnum[v],$.dn2tn[dn])
}
method chanchanged (v,dn) {
	$.setchan(v,$.dn2tn[dn])
}
method setpatch (pn,tn) {
	$.tn2patch[tn] = pn
	if ( $.tn2chan[tn] == 0 )
		print("Warning, channel must be set for patch setting to matter!")
	realmidi($.patchphrase(tn))
	p=$.patchphrase(tn)
	ph=$.trk[tn].get()
	ph=ph-cut(ph,CUT_TYPE,PROGRAM)
	ph|=p
	$.trk[tn].set(ph)
}
method setchan (cn,tn) {
	$.tn2chan[tn] = cn
	$.trk[tn].setchan(cn)
	$.makemerged(0)
}
method patchphrase (tn) {
	p = ''
	if ( nargs() > 0 ) {
		ch = $.tn2chan[tn]
		patch = $.tn2patch[tn]
		if ( ch > 0 && patch > 0 ) {
	  		if (ACPATCHES)
				p |= PourAC(ACPat[patch]["lsb"],ACPat[patch]["pat"],ch)
			else
				p |= progchange(patch,ch)
		}
	}
	else {
		for ( tn=$.ntracks; tn>=1; tn-- ) {
			ch = $.tn2chan[tn]
			patch = $.tn2patch[tn]
			if ( ch > 0 && patch > 0 ) {
				if (ACPATCHES)
					p |= PourAC(ACPat[patch]["lsb"],ACPat[patch]["pat"],ch)
				else
					p |= progchange(patch,ch)
			}
		}
	}
	return(p)
}

method notifyaud (co,v){
	$.audition=["start"=v["x0"],"end"=v["x1"]]
}

method notifypickh (co,v) { $.notifypicksweep(co,v,0,"") }
method notifypickha (co,v) { $.notifypicksweep(co,v,0,"&") }
method notifypickhm (co,v) { $.notifypicksweep(co,v,0,"-") }
method notifypickhp (co,v) { $.notifypicksweep(co,v,0,"+") }

method notifypickv (co,v) { $.notifypicksweep(co,v,1,"") }
method notifypickva (co,v) { $.notifypicksweep(co,v,1,"&") }
method notifypickvm (co,v) { $.notifypicksweep(co,v,1,"-") }
method notifypickvp (co,v) { $.notifypicksweep(co,v,1,"+") }

method notifyadd1 (co,v) { $.adddel1(co,v,1) }
method notifydel1 (co,v) { $.adddel1(co,v,0) }
method notifyonly1 (co,v) { $.adddel1(co,v,2) }
method notifyopen (co,v) { $.doopenclose(v,0) }
method notifyclose (co,v) { $.doopenclose(v,1) }

method notifytool (co,v) {
	if ( (dn=lookup($.c,co,-1)) < 0 )
		error ("Bad co in notifytool!?")
	if ( dn == 0 ) {
		print("Can't create tools in the Merged track.\nYou must create them in a specific track!")
		return()
	}
	# We want to end up with just the new tool "picked"
	$.clearpick(0)
	co.addtool(v)
	$.c[dn].redraw()
}

method makebuttonarray(t) {
	butt = $.buttinfo()
	arr = []
	for ( n=0; n in butt; n++ ) {
		if ( t in butt[n] )
			arr[n] = butt[n][t]
	}
	return(arr)
}

method buttinfo() {
	# This magic array drives the creation and semantics of the
	# mouse button menus in the wgroup tool.

	# The order in this array is NOT the order in which they appear
	# in the menus.  That's controlled by kmsbutton_mkmenu().

	if ( ! defined(Buttinfo) ) {
	    Buttinfo = [
		0=["type"=LEFTRIGHT,"name"="Aud Sweep","meth"="notifyaud"],
		1=["type"=INVOKE,"name"="Aud Play","meth"="notifyplayaud"],
		2=["type"=LEFTRIGHT,"name"="Pick Sweep","meth"="notifypickh"],
		3=["type"=CLOSEST,"name"="Pick +1","meth"="notifyadd1"],
		4=["type"=CLOSEST,"name"="Pick -1","meth"="notifydel1"],
		5=["type"=INVOKE,"name"="Pick Play","meth"="notifyplaypick"],
		6=["type"=DRAG,"name"="Drag","meth"="notifydrag"],
		7=["type"=DRAG,"name"="Drag Dur","meth"="notifydragdur"],
		8=["type"=DRAG,"name"="Drag Pitch","meth"="notifydragpitch"],
		9=["type"=LEFTRIGHT,"name"="Open","meth"="notifyopen"],
		10=["type"=LEFTRIGHT,"name"="Close","meth"="notifyclose"],
		11=["type"=BRUSH,"name"="Brush","meth"="notifybrush"],
		12=["type"=POINT,"name"="Paste","meth"="notifypaste","arg"=0],
		13=["type"=CLOSEST,"name"="Info","meth"="notifyident"],
		14=["type"=POINT,"name"="Trigger","meth"="notifybang"],
		15=["type"=DRAG,"name"="Stretch","meth"="notifystretch"],
		16=["type"=UPDOWN,"name"="Pick Strip","meth"="notifypickv"],
		17=["type"=UPDOWN,"name"="Oct Shift","meth"="notifyoctshft"],
		18=["type"=DRAW,"name"="Volume","meth"="notifydrawctrl","ctlr"=0x07],
		19=["type"=DRAW,"name"="Modulation","meth"="notifydrawctrl","ctlr"=0x01],
		20=["type"=DRAW,"name"="Expression","meth"="notifydrawctrl","ctlr"=0x0b],
		21=["type"=DRAW,"name"="Pan","meth"="notifydrawctrl","ctlr"=0x0a],
		22=["type"=DRAW,"name"="Reverb","meth"="notifydrawctrl","ctlr"=0x5b],
		23=["type"=DRAW,"name"="Chorus","meth"="notifydrawctrl","ctlr"=0x5d],
		24=["type"=CLOSEST,"name"="Pick 1","meth"="notifyonly1"],
		25=["type"=CLOSEST,"name"="Pluck","meth"="notifypluck"],
		26=["type"=DRAW,"name"="Notes","meth"="notifydrawnotes"],
		27=["type"=INVOKE,"name"="Loop","meth"="notifyloop"],
		28=["type"=UPDOWN,"name"="Pick-Strip","meth"="notifypickvm"],
		29=["type"=UPDOWN,"name"="Pick&Strip","meth"="notifypickva"],
		30=["type"=UPDOWN,"name"="Pick+Strip","meth"="notifypickvp"],
		31=["type"=LEFTRIGHT,"name"="Pick-Sweep","meth"="notifypickhm"],
		32=["type"=LEFTRIGHT,"name"="Pick&Sweep","meth"="notifypickha"],
		33=["type"=LEFTRIGHT,"name"="Pick+Sweep","meth"="notifypickhp"],
		34=["type"=POINT,"name"="Last Rec (Note/Chord)","meth"="notifypaste","arg"=1],
		35=["type"=POINT,"name"="Last Rec (2b space)","meth"="notifypaste","arg"=2],
		36=["type"=POINT,"name"="Insert","meth"="notifypaste","arg"=100],
		37=["type"=POINT,"name"="Last Rec (Note/Chord)","meth"="notifypaste","arg"=101],
		38=["type"=POINT,"name"="Last Rec (2b space)","meth"="notifypaste","arg"=102],
		39=["type"=POINT,"name"="Snarf","meth"="notifyappend","arg"=100],
		40=["type"=POINT,"name"="Last Note/Chord","meth"="notifyappend","arg"=101],
		41=["type"=POINT,"name"="Last Rec (2b space)","meth"="notifyappend","arg"=102],
		42=["type"=LEFTRIGHT,"name"="Tool","meth"="notifytool"]
	    ]
	}
	return(Buttinfo)
}

method reinit() {

	# Remove all existing children
	for ( o in $.children() ) {
		if ( ! (o in $.dontdelete) ) {
			$.removechild(o)
# print("reinit removechild o=",o)
			# deleteobject(o)
		}
	}
	for ( n=0; n<=$.ntracks; n++ ) {
		if ( $.trk[n] != $-1 ) {
# print("reinit deleteobj on $.trk[n=",n,"]=",$.trk[n].trackname())
			deleteobject($.trk[n])
		}
	}
	$.initbasicvars()
}

method initbasicvars() {
	$.fifo = -1
	$.ndisp = 0
	$.ntracks = 0
	$.isplaying = 0
	$.islooping = 0
	$.audition = ["start"=0,"end"=0]
	$.undoindex = 0
	$.undolow = 0
	$.undoadd = []
	$.undosub = []
	$.stoptids = []
	$.trk = []	# index is tn
	$.tn2label = []	# index is tn
	$.tn2name = []	# index is tn
	$.tn2patch = []	# index is tn
	$.tn2chan = []	# index is tn
	$.tn2mute = []	# index is tn
	$.trkchan = []	# index is tn
	$.patch = []	# index is tn
	$.tn2tids = []	# index is tn

	$.c = []	# index is dn
	$.mute = []	# index is tn
	$.trkbutt = []	# index is dn
	$.solo = []	# index is dn
	$.dn2tn = []	# index is dn
	$.view = xy(-1b,0,9b,127)

	# initialize the merged track
	$.trk[0] = new wphrase()
	$.tn2name[0] = $.trk[0].trackname()
# print("initbasic, trkname=",$.tn2name[0])
	$.tn2label[0] = "Merged"
	$.tn2patch[0] = 0
	$.tn2chan[0] = 0
	$.tn2mute[0] = 0
}

method anypickedin(p) {
	return ( sizeof(cut(p,CUT_FLAGS,1)) > 0 )
}

method clearpick(dn,doredraw,dontredrawtn) {

	if ( nargs() < 2 )
		doredraw = 1
	if ( nargs() < 3 )
		dontredrawtn = -1
	if ( dn == 0 ) {
		# To clear merged track, clear all tracks
		for ( tn=1; tn<=$.ntracks; tn++ ) {
			anypicked = $.anypickedin($.trk[tn].get())
			$.trk[tn].clearpick()
			if ( doredraw && anypicked && tn != dontredrawtn )
				$.redrawtn(tn)
		}
	}
	else {
		tn = $.dn2tn[dn]
		anypicked = $.anypickedin($.trk[tn].get())
		$.trk[tn].clearpick()
		if ( doredraw && anypicked && tn != dontredrawtn )
			$.redrawtn(tn)
	}
	if ( dontredrawtn < 0 )
		$.makemerged(doredraw)
}

method setsolo(val,m,dn) {
	if ( val == 0 )
		return()
	nt = $.ntracks
	ndisp = $.ndisp
	# clear solo settings for other tracks
	for ( n=1; n<ndisp; n++ ) {
		if ( n == dn )
			continue
		issolo = $.solo[n].get()
		if ( issolo ) {
			$.solo[n].set(0)
			$.solo[n].redraw()
		}
	}
}

method setmute(val,m,dn) {
	tn = $.dn2tn[dn]
	$.tn2mute[tn] = val
	if ( ! $.isplaying )
		return()
	if ( tn in $.tn2tids ) {
		killtids($.tn2tids[tn])
		delete $.tn2tids[tn]
	}
	else if ( tn in $.pt ) {
		dt = Now - $.stime
		p = $.pt[tn]
		p = cut(p,CUT_TIME,$.playoffset+Now-$.stime,MAXCLICKS)
		tid = realmidi(p,$.stime - $.playoffset)
		$.stoptids[tid] = 1
		$.tn2tids[tn] = [tid=1]

		cp = $.trk[tn].get()
		if ( Phraseflashnotes == 1 ) {
			tid = $.c[dn].flashnotes(cp&p,$.stime,$.playoffset)
			$.stoptids[tid] = 1
			$.tn2tids[tn][tid] = 1
		}
	}
}

method dump() {
	st = []
	for ( v in $.dumpvars )
		st[v] = $.(v)
	st["ntracks"] = $.ntracks
	st["tn2label"] = arraycopy($.tn2label)
	st["tn2patch"] = arraycopy($.tn2patch)
	st["tn2chan"] = arraycopy($.tn2chan)
	st["tn2mute"] = arraycopy($.tn2mute)
	st["dn2tn"] = arraycopy($.dn2tn)
	st["phrases"] = []
	st["toolnotes"] = []
	tnotes = ''
	for ( tn=1; tn<=$.ntracks; tn++ ) {
		p = $.trk[tn].get()
		tp = toolnotes(p)
		p -= tp
		st["phrases"][tn] = p
		st["toolnotes"][tn] = toolnotesdump(tp)
	}
	# We really shouldn't duplicate the toolnotes - the restore
	# should just pull them out of the "phrases"

	st["buttonact"] = arraycopy($.buttonact)
	st["buttmod"] = $.buttmod
	return(st)
}

method setbutton(val,bn,doredraw,mod) {

	if ( bn == 1 ) {
		$.vb[1].settext($.buttvals[val])
		if ( doredraw )
			$.vb[1].redraw()
	}
	else {
		$.vb[2].settext($.buttvals[val])
		if ( doredraw )
			$.vb[2].redraw()
	}
	$.buttonact[bn][mod] = val

	btype = $.val2buttontype[val]
	meth = $.val2notifymeth[val]

	# This probably isn't needed anymore
	# for ( dn=0; dn<$.ndisp; dn++ )
	# 	$.c[dn].setbuttontype(btype,bn,meth)

	if ( val in $.val2controller ) {
		$.drawcontroller = $.val2controller[val]
	}
}

method restore(st) {
	$.reinit()
	$.groupname = st["groupname"]
	nt = st["ntracks"]
	for ( v in $.dumpvars )
		$.(v) = st[v]

	# to handle old versions
	if ( ! ("buttonact" in st) )
		st["buttonact"] = [ 1=[0=0,1=2,2=25], 2=[0=1,1=5,2=6] ]
	if ( ! ("buttmod" in st) )
		st["buttmod"] = 0

	$.buttmod = st["buttmod"]
	$.b3.set($.buttmod)

	$.buttonact = st["buttonact"]
	for ( bn=1; bn<=2; bn++ ) {
		for ( mod=0; mod<3; mod++ )
			$.setbutton( $.buttonact[bn][mod], bn, NOREDRAW, mod )
	}
	$.modchanged($.buttmod,NOREDRAW)

	for ( tn=1; tn<=nt; tn++ ) {
		pp = st["phrases"][tn]
		if ( "toolnotes" in st )
			newtn = $.addtrack(pp,st["toolnotes"][tn])
		else
			newtn = $.addtrack(pp)
		if ( newtn != tn )
			print("Out of sync in restore? newtn=",newtn," tn=",tn)
		$.tn2label[tn] = st["tn2label"][tn]
		if ( "tn2patch" in st )
			$.tn2patch[tn] = st["tn2patch"][tn]
		if ( "tn2chan" in st )
			$.tn2chan[tn] = st["tn2chan"][tn]
		if ( "tn2mute" in st )
			$.tn2mute[tn] = st["tn2mute"][tn]
	}
	$.dispmore(0)

	dn2tn = st["dn2tn"]
	for ( dn=1; dn in dn2tn; dn++ ) {
		# NOTE: this is purposely dn2tn, not $.dn2tn
		tn = dn2tn[dn]
		$.dispmore(tn)
		$.patch[dn].set($.tn2patch[tn])
		$.trkchan[dn].set($.tn2chan[tn])
		$.mute[dn].set($.tn2mute[tn])
	}

	$.viewset(st["view"])
	$.refit(0)
	$.makemerged(0)
	$.undoclear()
	$.zoomclear()
	$.auditionall()
	$.resize()
}

method bang() {
	if ( $.isplaying )
		$.stop()
	else
		$.playaudition()
}

method stop() {
	if ( $.isplaying ) {
		killtids($.stoptids)
		alloff()
		$.stoptids = []
		$.isplaying = 0
		$.islooping = 0
		$.laststop = Now
		methodbroadcast()
	}
}

method dispmore(tn,doredraw) {

	dn = lookup($.dn2tn,tn,-1)
	if ( dn != -1 )
		return()	# it's already shown

	dn = $.ndisp++

	$.c[dn] = $.trk[tn]
	trk = $.trk[tn]

	$.dn2tn[dn] = tn

	nm = $.tn2name[tn]
	trk.trackname(nm)

	trk.setnotify($)
	$.addchild(trk)

	$.trkbutt[dn] = new kmenubutton($.tn2label[tn],
					"mkmenu_trk",$,dn)
	$.addchild($.trkbutt[dn])

	if ( dn > 0 ) {
		o = $.solo[dn] = new ktoggle("S",$,"setsolo",dn)
		$.addchild(o)

		o = $.mute[dn] = new ktoggle("M",$,"setmute",dn)
		o.set($.tn2mute[tn])
		$.addchild(o)

		settinglist = $.pname
		o = $.patch[dn] = new kvalbutton(settinglist,$,"settingchanged",dn);
		o.set($.tn2patch[tn])
		$.addchild(o)

		o = $.trkchan[dn] = new kvalbutton(
			[0="X",1="1",2="2",3="3",4="4",5="5",6="6",7="7",8="8",9="9",
			10="10",11="11",12="12",13="13",14="14",15="15",16="16"],
			$, "chanchanged", dn);
		o.set($.tn2chan[tn])
		$.addchild(o)
	}

	# make sure it has the right view and sweep mode
	$.c[dn].viewset($.view,"x")

	if ( nargs() > 1 && doredraw ) {
		$.resize()
		$.redraw()
	}
}

method asknlabeldn(dn) {
	tn = $.dn2tn[dn]
	oldlbl = $.tn2label[tn]
	lbl = getastr("Enter new label of '"+oldlbl+"' --> ")
	$.tn2label[tn] = lbl
	$.trkbutt[dn].settext(lbl)
	$.trkbutt[dn].redraw()
}

method showall() {

	nt = $.ntracks
	for ( tn=1; tn<=nt; tn++ ) {
		dn = lookup($.dn2tn,tn,-1)
		if ( dn != -1 )
			continue	# it's already shown
		$.dispmore(tn)
	}
	$.resize()
	$.redraw()
}

method showactive() {
	nt = $.ntracks
	x0 = $.view["x0"]
	x1 = $.view["x1"]
	for ( tn=1; tn<=nt; tn++ ) {
		dn = lookup($.dn2tn,tn,-1)
		p = $.trk[tn].get()
		ismute = $.tn2mute[tn]
		if ( !ismute && sizeof(cut(p,CUT_TIME,x0,x1)) > 0 ) {
			# display it, if it's not already shown
			if ( dn < 0 )
				$.dispmore(tn)
		}
		else {
			# if it's shown, get rid of it
			if ( dn >= 0 )
				$.unshowdn(dn)
		}
	}
	$.resize()
	$.redraw()
}

method toolize(dn,w,tooltype,...) {
	if ( w == 0 ) {
		t1 = $.audition["start"]
		t2 = $.audition["end"]
		$.pickaud(dn)
		v = ["x0"=t1,"x1"=t2]
		$.edit("toolize",$.c[dn],t1,t2,tooltype,...)
	} else {
		print("Can't handle Pick yet")
	}
}

method unshowdn(dn,redraw) {
	if ( dn == 0 ) {
		print("Can't unshow the merged track!")
		return()
	}
	tn = $.dn2tn[dn]
	# Delete widgets (phrase, buttons, etc) for this display slot

	# shift other ones down
	ndisp = $.ndisp
	for ( n=dn+1; n < ndisp; n++ ) {
		$.dn2tn[n-1] = $.dn2tn[n]
		$.solo[n-1].set($.solo[n].get())
		$.mute[n-1].set($.mute[n].get())
		# The clear_ button doesn't need setting
	}

	$.ndisp--
	ndisp--
	delete $.dn2tn[ndisp]

	$.removechild($.trk[tn])

	$.removechild($.solo[ndisp])
	$.removechild($.mute[ndisp])
	$.removechild($.trkbutt[ndisp])
	$.removechild($.patch[ndisp])
	$.removechild($.trkchan[ndisp])

	# Delete the entry from the array, but DO NOT delete the object
	delete($.c[ndisp])

	deleteobject($.solo[ndisp])
	deleteobject($.mute[ndisp])
	deleteobject($.trkbutt[ndisp])
	deleteobject($.patch[ndisp])
	deleteobject($.trkchan[ndisp])

	# update the track names for each child phrase
	for ( dn=1; dn<ndisp; dn++ ) {
		tn = $.dn2tn[dn]
		nm = $.tn2name[tn]
		$.c[dn] = $.trk[tn]
		$.trkbutt[dn].settext($.tn2label[tn])
		$.trkbutt[dn].setargs($,dn,tn)
		$.patch[dn].set($.tn2patch[tn])
		$.trkchan[dn].set($.tn2chan[tn])
		$.mute[dn].set($.tn2mute[tn])
	}
	if ( nargs() > 1 && redraw>0 ) {
		$.resize()
		$.redraw()
	}
}

method deletetrackdn(dn) {
	if ( ! ( dn in $.dn2tn) )
		error("Bad dn="+string(dn)+" value given to deletetrackdn!?")
	tn = $.dn2tn[dn]
	$.deletetrack(tn)
}

method deletetrack(tn) {
	if ( tn == 0 ) {
		print("You can't delete the merged track!!")
		return()
	}
	if ( tn == 1 && $.ntracks == 1 ) {
		print("You can't delete the last track!!")
		return()
	}
	dn = lookup($.dn2tn,tn,-1)
	if ( dn > 0 )
		$.unshowdn(dn);

	# adjust values in dn2tn
	for ( n=tn+1; n<=$.ntracks; n++ ) {
		for ( ddn in $.dn2tn ) {
			if ( $.dn2tn[ddn] == n )
				$.dn2tn[ddn] = n-1
		}
	}
	deleteobject($.trk[tn])

	# Shift labels and names of tracks down
	for ( n=tn+1; n<=$.ntracks; n++ ) {
		$.tn2label[n-1] = $.tn2label[n]
		$.tn2patch[n-1] = $.tn2patch[n]
		$.tn2chan[n-1] = $.tn2chan[n]
		$.tn2mute[n-1] = $.tn2mute[n]
		$.tn2name[n-1] = $.tn2name[n]
		$.trk[n-1] = $.trk[n]
	}
	delete $.tn2label[$.ntracks]
	delete $.tn2patch[$.ntracks]
	delete $.tn2chan[$.ntracks]
	delete $.tn2mute[$.ntracks]
	delete $.tn2name[$.ntracks]
	$.ntracks--
	$.makemerged(0)
	$.resize()
	$.redraw()
}

method flagsndraw(tn,f) {
	if ( f == 0 || f == 1 )
		$.trk[tn].setflags(f)
	else if ( f == 2 ) {
		# Reverse flags - what's picked is not, what's not is picked
		r = ''
		p = $.trk[tn].get()
		for ( n in p ) {
			if ( n.flags )
				n.flags = 0
			else
				n.flags = 1
			r |= n
		}
		$.trk[tn].set(r)
	}
	else
		print("unexpected f=",f," in flagsndraw!?")
	$.redrawtn(tn)
}

method pickall(f,dn) {
	tn = $.dn2tn[dn]
	if ( nargs() > 1 && tn > 0 ) {
		if ( f == 1 ) {
			# clear picks on all other tracks first
			$.clearpick(0,1,tn) 	# and don't redraw track tn
		}
		$.flagsndraw(tn,f)
	}
	else {
		for ( tn=1; tn<=$.ntracks; tn++ ) {
			$.flagsndraw(tn,f)
		}
	}
	$.makemerged(1)
}

method pickaud(dn) {
	tn = $.dn2tn[dn]
	if ( tn > 0 ) {
		# clear picks on all *other* tracks first
		$.clearpick(0,1,tn) 	# and don't redraw track tn

		trk = $.trk[tn]
		phr = trk.get()
		phr.flags = 0

		t1 = $.audition["start"]
		t2 = $.audition["end"]
		np = cut(phr,CUT_TIME,t1,t2)

		phr -= np
		np.flags = 1
		phr |= np
		trk.set(phr)
		$.redrawtn(tn)
	}
	else {
		$.clearpick(0)	# clear all existing picks
		for ( tn=1; tn<=$.ntracks; tn++ ) {

			trk = $.trk[tn]
			phr = trk.get()
			phr.flags = 0

			t1 = $.audition["start"]
			t2 = $.audition["end"]
			np = cut(phr,CUT_TIME,t1,t2)

			phr -= np
			np.flags = 1
			phr |= np
			trk.set(phr)
			$.redrawtn(tn)
		}
	}
	$.makemerged(1)
}
method smmpickbars(dn,arr) {
	tn = $.dn2tn[dn]
	if ( tn > 0 ) {
		# clear picks on all *other* tracks first
		$.clearpick(0,1,tn) 	# and don't redraw track tn

		trk = $.trk[tn]
		phr = trk.get()
		phr.flags = 0

		t1 = arr["x0"]
		t2 = arr["x1"]
		np = cut(phr,CUT_TIME,t1,t2)

		phr -= np
		np.flags = 1
		phr |= np
		trk.set(phr)
		$.redrawtn(tn)
	}
	else {
		$.clearpick(0)	# clear all existing picks
		for ( tn=1; tn<=$.ntracks; tn++ ) {

			trk = $.trk[tn]
			phr = trk.get()
			phr.flags = 0

			t1 = arr["x0"]
			t2 = arr["x1"]
			np = cut(phr,CUT_TIME,t1,t2)

			phr -= np
			np.flags = 1
			phr |= np
			trk.set(phr)
			$.redrawtn(tn)
		}
	}
	$.makemerged(1)
}

method editpick(f,...) {
	pk = $.getpick()
	npk = []
	# make sure it all works before applying it
	f = efunction(f)
	for ( tn in pk ) {
		npk[tn] = f(pk[tn],...)
	}
	for ( tn in pk ) {
		np = npk[tn]
		if ( sizeof(pk[tn]) == 0 )	# pk, not npk
			continue
		trk = $.trk[tn]
		phr = trk.get()
		phr.flags = 0
		np.flags = 0
		phr -= np
		np.flags = 1
		phr |= np
		trk.set(phr)
		$.redrawtn(tn)
	}
	$.makemerged(1)
}

method anyinpick(pk) {
	any = 0
	for ( n in pk ) {
		if ( sizeof(pk[n]) != 0 )
			return(1)
	}
	return(0)
}

method edit(f,...) {
	$.realedit(0,f,...)
}

# editadd() is used for operations that take the current pick, process
# it, and generate new stuff that is added, without changing the
# current pick.  The only difference here (from edit())
# is that only the new stuff becomes the current pick.

method editadd(f,...) {
	$.realedit(1,f,...)
}

method realedit(onlypicknew,f,...) {
	$.stop()		# stop any current playing
	pk = $.getpick()
	npk = []
	if ( $.anyinpick(pk) == 0 ) {
		print("There's nothing in the Pick!?")
		return()
	}
	f = efunction(f)
	# make sure all edits work before going any further
	for ( tn in pk ) {
		if ( sizeof(pk[tn]) > 0 ) {
			npk[tn] = f(pk[tn],...)
			if ( onlypicknew ) {
				npk[tn].flags = 1
				tp = pk[tn]
				tp.flags = 0
				npk[tn] |= tp
			}
		}
		else
			npk[tn] = ''
	}
	lock($)
	$.applychange(pk,npk,0)
	unlock($)
	$.makemerged(0)
	if ( $.refit(1,1,pk) == 0 ) {
		$.redrawtracks(pk)
	}
}
method smmrealedit(f,...) {
	$.stop()		# stop any current playing
	pk = $.getpick()
	npk = []
	if ( $.anyinpick(pk) == 0 ) {
		print("There's nothing in the Pick!?")
		return()
	}
	f = efunction(f)
	# make sure all edits work before going any further
	npk = f(pk,...)
	lock($)
	$.applychange(pk,npk,0)
	unlock($)
	$.makemerged(0)
	if ( $.refit(1,1,pk) == 0 ) {
		$.redrawtracks(pk)
	}
}

method pastedubdn(dn) {
	$.pastedub($.dn2tn[dn])
}

method pastedub(tn) {
	p = $.lastoverdub()
	if ( sizeof(p) == 0 ) {
		print("There's no overdub!?")
		return()
	}
	$.paste(tn,p)
}

method pastegmreset(dn,...) {
	$.paste($.dn2tn[dn],gmresetall(),...);
}

method pastedn(dn,...) {
	$.paste($.dn2tn[dn],Snarf,...)
}

method paste(tn,ph,append) {
	if ( nargs() < 3 )
		append = 0
	if ( tn <= 0 ) {
		print("You can't do that into the merged track.  Do it on a specific track!")
		return()
	}
	if ( nargs() < 2 )
		ph = Snarf
	ph.flags = 1
	trk = $.trk[tn]
	phr = trk.get()
	if ( append ) {
		ph = strip(ph)
		ph.time += latest(phr)
	}
	phr |= ph
	if ( $.tn2chan[tn] > 0 ) {
		phr.chan = $.tn2chan[tn]
	}
	trk.set(phr)
	$.redrawtn(tn)
	$.makemerged(0)
	if ( $.refit(1) == 0 )
		$.redrawtracks()
	$.saveundo([tn=''],[tn=ph])
}

method copy() {
	pk = $.getpick()
	npk = []
	for ( tn in pk ) {
		if ( sizeof(pk[tn])==0 )
			continue
		npk[tn] = pk[tn]	# assume flags is 1
		trk = $.trk[tn]
		phr = trk.get()
		phr.flags = 0
		phr |= npk[tn]
		pk[tn] = ''	# so saveundo works as needed
		if ( $.tn2chan[tn] > 0 )
			phr.chan = $.tn2chan[tn]
		trk.set(phr)
		$.redrawtn(tn)
	}
	$.makemerged(1)
	$.saveundo(pk,npk)
}

method applychange(pk,npk,doredraw) {
	if ( nargs() < 3 )
		doredraw = 1
	for ( tn in pk ) {
		if ( sizeof(pk[tn])==0 && sizeof(npk[tn])==0 )
			continue
		# force changes to be on the selected channel
		trk = $.trk[tn]
		phr = trk.get()
		origphr = phr
		phr -= pk[tn]
		phr |= npk[tn]
		if ( $.tn2chan[tn] > 0 )
			phr.chan = $.tn2chan[tn]
		trk.set(phr)
		newphr = trk.get()
		# The set may have changed some of the toolholders, so
		# we recompute the difference between the new and the old one
		if ( trk.hastools() ) {
			npk[tn] = newphr-origphr
		}
		if ( doredraw )
			$.redrawtn(tn)
	}
	$.makemerged(doredraw)
	$.saveundo(pk,npk)
}

method saveundo(pk,npk) {
	ui = $.undoindex
	ul = $.undolow
	$.undoadd[ui] = arraycopy(pk)
	$.undosub[ui] = arraycopy(npk)
	if ( (ui-ul) >= Undolimit ) {
		delete $.undoadd[ul]
		delete $.undosub[ul]
		$.undolow++
	}
	$.undoindex++
}

method undo() {
	if ( $.undoindex <= $.undolow ) {
		print("Nothing more to undo in that group!")
		return()
	}
	lock($)
	$.undoindex--
	ui = $.undoindex
	pkadd = $.undoadd[ui]
	pksub = $.undosub[ui]
	for ( tn=1; tn<=$.ntracks; tn++ ) {
		if ( !(tn in pksub) || !(tn in pkadd) ) {
			continue
		}
		nm = $.tn2name[tn]

		# Ignore existing flags (which may or may not be set)
		pksub[tn].flags = 0
		pkadd[tn].flags = 1
		trk = $.trk[tn]
		phr = trk.get()
		phr.flags = 0

		if ( $.tn2chan[tn] > 0 ) {
			pksub[tn].chan = $.tn2chan[tn]
			pkadd[tn].chan = $.tn2chan[tn]
		}
		phr -= pksub[tn]
		phr |= pkadd[tn]
		trk.set(phr)
	}
	$.makemerged(0)
	if ( $.refit(1) == 0 )
		$.redrawtracks()
	unlock($)
}

method onpicked(f,...) {
	picked = $.getpick()
	if ( sizeof(picked) <= 0 ) {
		print("No tracks are picked, so there's nothing to do.")
		return()
	}
	for ( tn in picked ) {
		f = efunction(f)
		f(picked[tn],...)
	}
}

method showchan() {
	lock($)
	ndisp = $.ndisp
	msg = []
	for ( dn=0; dn<ndisp; dn++ ) {
		tn = $.dn2tn[dn]
		s = chaninfo($.trk[tn].get())
		msg[dn] = new kmsg(s)
		msg[dn].resize($.c[dn].size())
		msg[dn].redraw()
	}
	millisleep(3000)
	for ( dn=0; dn<ndisp; dn++ ) {
		deleteobject(msg[dn])
	}
	unlock($)
}

method chansplit() {
	lock($)
	ph = $.c[0].get()
	$.reinit()
	for ( n=1; n<=16; n++ ) {
		p = cut(ph,CUT_CHANNEL,n)
		nn = sizeof(p)
		if ( nn > 0 ) {
			tn = $.addtrack()
			$.trk[tn].set(p)
#
			patches = cut(p,CUT_TYPE,PROGRAM);
			sz = sizeof(patches)
			if ( sz > 1 ) {
				print("Warning, more than one patch change in track",tn,".")
print(patches)
			}
			else if ( sz == 1 ) {
				$.setchan(patches.chan,tn)
				pnum = 1+integer(subbytes(patches,2,1))
				$.setpatch(pnum,tn)
			}
#
		}
	}
	unlock($)
	$.dispmore(0)
	$.reset()
	$.showall()
}

method appendgroup() {
	w = wselect()
	if ( w == Root || w.classof() != "wgroup" ) {
		print("No group tool selected, no appending done.")
		return()
	}
	$.clearpick(0)	# clear all existing picks
	lock($)
	tmend1 = numquant(latest($.c[0].get()),1b)
	st = w.dump()
	nt = st["ntracks"]
	tmstart2 = 99999
	for ( tn=1; tn<=nt; tn++ ) {
		p = st["phrases"][tn]
		if ( p%1.time < tmstart2 )
			tmstart2 = p%1.time
	}
	tmstart2 = numquant(tmstart2,1b)
	for ( tn=1; tn<=nt; tn++ ) {
		p = st["phrases"][tn]
		p.time += tmend1 - tmstart2
		newtn = $.addtrack()
		p.flags = 1
		$.trk[newtn].set(p)
	}
	unlock($)
	$.dispmore(0)
	$.reset()
	$.showall()
}

method mergegroup() {
	w = wselect()
	if ( w == Root || w.classof() != "wgroup" ) {
		print("No group tool selected, no appending done.")
		return()
	}
	lock($)
	$.clearpick(0)	# clear all existing picks
	st = w.dump()
	nt = st["ntracks"]
	for ( tn=1; tn<=nt; tn++ ) {
		p = st["phrases"][tn]
		newtn = $.addtrack()
		p.flags = 1
		$.trk[newtn].set(p)
	}
	unlock($)
	$.dispmore(0)
	$.reset()
	$.showall()
}

method writesmf(addtempo) {
	fname = browsefiles("MIDI File (*.MID)","*.mid",0)
	if ( fname == "" ) {
		print("No file specified")
		return()
	}
	arr = []
	nt = $.ntracks
	i = 0
	if ( nargs() > 0 && addtempo!=0 ) {
		arr[i] = '"Timesig=4/4,24,8"'
		arr[i] += phrase("'\"Tempo="+string(tempo())+"\"'")
		i++
	}
	# If the beginning time of any of the tracks is < 0, we want to adjust
	# the times to be positive, since midifile() can't handle negative times.
	offset = 0
	for ( tn=1; tn<=nt; tn++ ) {
		# don't include muted tracks
		if ( $.tn2mute[tn] != 0 )
			continue
		tp = $.trk[tn].get()
		tm1 = tp%1.time
		if ( tm1 < offset )
			offset = tm1
	}
	if ( offset < 0 ) {
		print("First note has negative time (",offset,") !")
		print("All notes will be shifted forward by that amount.")
	}
	for ( tn=1; tn<=nt; tn++ ) {
		# don't include muted tracks
		if ( $.tn2mute[tn] != 0 )
			continue
		tp = $.trk[tn].get()
		tp.time -= offset
		tp.length = latest(tp)
		p = $.patchphrase(tn)
		p.time = 0
		arr[i++] = p | tp
	}
	midifile(arr,fname)
	print(fname+" has been written.")
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
		$.reinit()
		nt = sizeof(arr)
		for ( n=0; n<nt; n++ ) {
			tn = $.addtrack(arr[n])
			patches = cut(arr[n],CUT_TYPE,PROGRAM);
			sz = sizeof(patches)
			if ( sz > 1 ) {
				print("Warning, more than one patch change in track",tn,".")
			}
			else if ( sz == 1 ) {
				$.setchan(patches.chan,tn)
				pnum = 1+integer(subbytes(patches,2,1))
				$.setpatch(pnum,tn)
			}
		}
	}
	else if ( suff == "k" || suff == "K" ) {
		ph = readkey(fname)
		if ( sizeof(ph) <= 0 ) {
			print("That file's nonexistant or empty!?")
			unlock($)
			return()
		}
		$.reinit()
		$.addtrack(ph)
	}
	else {
		print("Unrecognized file name type!?")
		unlock($)
		return()
	}
	$.dispmore(0)
	deleteobject(msg)
	unlock($)
	$.reset()
}

method readrecorded(space) {
	ph = lastbunch(Recorded,space)
	if ( sizeof(ph) <= 0 ) {
		print("Nothing in Recorded!?")
		return()
	}
	ph = syncphr(ph)
	if ( ph%1.time > (Met.length/2) )
		ph.time -= Met.length
	$.set(ph)
}

method readsnarf() {
	$.set(Snarf)
}

method readconph() {
	$.set(Conph)
}

method set(ph) {
	$.reinit()
	$.addtrack(ph)
	$.dispmore(0)
	$.reset()
}

method notifyofchange(changedobj) {
	$.makemerged(1)
}

method makemerged(dodraw) {
	nt = $.ntracks
	p = ''
	for ( tn=1; tn<=nt; tn++ ) {
		t = $.trk[tn]
		if ( t == $0 || t == $-1 ) {
			print("Warning, track tn=",tn," is gone!?")
			continue
		}
		tp = t.getaudition()
		if ( typeof(tp) == "phrase" )
			p |= tp
		else
			print("Hey, track ",tn," isn't a phrase!?")
	}
	$.trk[0].set(p)
	if ( nargs() > 0 && dodraw )
		$.c[0].redraw()
}

method task_dozoomin(f,dir) {
	# First wait for the mouse to go down
	m = waitdown(f)
	co = $.childunder(m)
	if ( co <= 0 )
		return()
	if ( dir == "x" )
		sw = LEFTRIGHT
	else if ( dir == "y" )
		sw = UPDOWN
	else
		sw = SWEEP
	sz = co.sweep(f,sw,m)
	# If the area is too small, do nothing
	if ( (sz["x1"] - sz["x0"]) < 1b ) {
		print("Too small?!")
		return()
	}
	$.zoompush()
	$.viewset(sz)
	$.refit(0,0)
	$.redraw()
}

method notifydrag(...) {
	$.notifydragit("",...)
}
method notifydragdur(...) {
	$.notifydragit("dur",...)
}
method notifystretch(...) {
	$.notifydragit("stretch",...)
}
method notifydragpitch(...) {
	$.notifydragit("pitch",...)
}

method notifyoctshft(co,v) {
	$.edit("octavefence",v["y0"],v["y1"])
}

method notifydragit(dragtype,co,st,v,ov) {
	if ( st == 0 ) {
		# start of drag
		$.dragpk = $.getpick()
		if ( $.anyinpick($.dragpk) == 0 ) {
			print("There's nothing in the Pick!")
			$.dragpk = []	# disables dragging, essentially
		}
		$.lastx = v["x"]
	}
	else if ( st == 1 ) {
		if ( sizeof($.dragpk) == 0 )
			return()
		dx = v["x"] - $.lastx
		if ( dx >= Dragquant || dx <= -Dragquant )
			$.lastx = v["x"]
		else
			dx = 0
		dy = v["y"] - ov["y"]
		if ( (dragtype=="pitch"&&dy!=0)
			|| (dragtype!="pitch"&&dx != 0) ) {

			for ( tn in $.dragpk ) {
				p = $.dragpk[tn]
				np = p
				if ( dragtype == "dur" )
					np.dur += dx
				else if ( dragtype == "pitch" )
					np.pitch += dy
				else if ( dragtype == "stretch" ) {
					tm1 = np%1.time
					np.time -= tm1
					lt = latest(np)
					if ( lt>0 ) {
						ft = float(lt+dx)/lt
						if ( ft > 0 )
							np = scatimes(np,ft)
					}
					np.time += tm1
				}
				else if ( dragtype=="" || dragtype=="time" ) {
					np.time += numquant(dx,Dragquant)
				}
				else
					error("Unknown dragtype!? ("+dragtype+")")

				if ( defined($.trk[tn].validatechange) ) {
					np = $.trk[tn].validatechange(p,np)
				}

				dn = lookup($.dn2tn,tn,-1)
				if ( dn >= 0 ) {
					$.c[dn].drawphrase(p,CLEAR)
					$.c[dn].drawphrase(np,STORE)
				}
				# we don't want to drag tools in the
				# merged track
				$.c[0].drawphrase(p-toolnotes(p),CLEAR)
				$.c[0].drawphrase(np-toolnotes(np),STORE)
				$.dragpk[tn] = np
			}
		}
	}
	else if ( st == 2 ) {
		# end of drag
		if ( sizeof($.dragpk) == 0 )
			return()
		$.applychange($.getpick(),$.dragpk,0)
		doneredraw = 0
		if ( dragtype=="pitch" )
			doneredraw = $.refit(1)
		if ( ! doneredraw )
			$.redrawtracks()
	}
}

method notifybrush(co,state,newm,oldm) {
	if ( (dn=lookup($.c,co,-1)) < 0 )
		error ("Bad co in notifybrush!?")
	if ( state == 0 ) {
		# start of brush
		$.brushp = $.c[dn].get()
	}
	else if ( state == 1 ) {
		x1 = oldm["x"]
		x2 = newm["x"]
		p = cut($.brushp,CUT_TIME,x1,x2)
		p.time = 0
		realtime(p)
	}
	else if ( state == 2 ) {
		# end of brush
	}
}

method notifydrawctrl(co,state,newm,oldm) {
	if ( (dn=lookup($.c,co,-1)) < 0 )
		error ("Bad co in notifydrawctrl!?")
	if ( dn == 0 ) {
		print("Can't draw controllers in the Merged track.\nYou must draw in a specific track!")
		return()
	}
	if ( co.classof() != "wphrase" ) {
		print("You can only draw controllers in 'phrase' tracks.")
		return()
	}
	tn = $.dn2tn[dn]
	if ( state == 0 ) {			# start of draw
		$.drawph = ''
		$.c[dn].fullvert()
		$.drawx0 = newm["x"]
	}
	else if ( state == 1 ) {		# middle of draw
		x1 = oldm["x"]
		x2 = newm["x"]
		y1 = oldm["y"]
		y2 = newm["y"]
		y = (y1+y2)/2
		if ( y < 0 )
			y = 0
		else if ( y > 127 )
			y = 127
		# controller
		p = midibytes(0xb0 , $.drawcontroller, y)
		p.time = (x1+x2)/2
		$.drawph |= p
		$.c[dn].drawphrase(p,STORE)
	}
	else if ( state == 2 ) {		# end of draw
		if ( sizeof($.drawph) == 0 )
			return()
		$.clearpick(0)	# clear all existing picks
		x0 = $.drawx0
		x1 = newm["x"]
		# we remove the stuff we've overlapped, while adding new stuff
		oldp = cut($.c[dn].get(),CUT_TIME,x0,x1)
		oldp = cut(oldp,CUT_TYPE,CONTROLLER,$.drawcontroller)
		newp = thincontrol($.drawph,1b/16)
		newp.flags = 1
		$.applychange([tn=oldp],[tn=newp],1)
	}
}

method notifydrawnotes(co,state,newm,oldm) {
	if ( (dn=lookup($.c,co,-1)) < 0 )
		error ("Bad co in notifydrawnotes!?")
	if ( dn == 0 ) {
		print("Can't draw notes in the Merged track.\nYou must draw in a specific track!")
		return()
	}
	if ( co.classof() != "wphrase" ) {
		print("You can only draw notes in 'phrase' tracks.")
		return()
	}

	tn = $.dn2tn[dn]
	if ( state == 0 ) {			# start of draw
		$.drawph = ''
		# $.c[dn].fullvert()
		$.drawx0 = MAXCLICKS
		$.drawy0 = -1
	}
	else if ( state == 1 ) {		# middle of draw
		x = newm["x"]
		y = newm["y"]
		if ( y < 0 )
			y = 0
		else if ( y > 127 )
			y = 127
		dx = x - $.drawx0
		dy = y - $.drawy0
		if ( dy != 0 || dx < -1b || dx > 1b ) {
			$.drawy0 = y
			$.drawx0 = x
			p = 'a'
			p.time = x
			p.pitch = y
			p.length = 1b
			$.drawph |= p
			$.c[dn].drawphrase(p,STORE)
		}
	}
	else if ( state == 2 ) {		# end of draw
		if ( sizeof($.drawph) == 0 )
			return()
		$.clearpick(0)	# clear all existing picks
		newp = $.drawph
		newp.flags = 1
		$.applychange([tn=''],[tn=newp],1)
	}
}

method doopenclose(v,closeit) {
	x0 = v["x0"]
	dx = v["x1"] - x0
	if ( closeit )
		dx = -dx
	pk = []
	npk = []
	for ( tn=1; tn<=$.ntracks; tn++ ) {
		phr = $.trk[tn].get()
		pk[tn] = cut(phr,CUT_TIME,x0,MAXCLICKS)
		npk[tn] = delay(pk[tn],dx)
	}
	$.applychange(pk,npk,1)
}

method getpickphrase() {
	pk = $.getpick()
	p = ''
	for ( n in pk )
		p |= pk[n]
	return(p)
}

method addtrackandshow(ptype) {

	if ( ptype == "snarf" ) {
		p = Snarf
		if ( sizeof(p) == 0 ) {
			print("There's no Snarf!?")
			return()
		}
	}
	else if ( ptype == "pick" ) {
		p = $.getpickphrase()
		if ( sizeof(p) == 0 ) {
			print("There's no Pick!?")
			return()
		}
	}
	else if ( ptype == "blank" ) {
		p = ''
	}
	else if ( ptype == "overdub" ) {
		p = $.lastoverdub()
		if ( sizeof(p) == 0 ) {
			print("There's no overdub!?")
			return()
		}
	}
	else {
		print("Unrecognized ptype=",ptype," in addtrackandshow")
		return()
	}

	tn = $.addtrack(p)
	$.dispmore(tn)

	# If "pick", remove the pick'ed stuff from the original track.
	# This is done AFTER adding the track, so that the tools-within-tracks
	# stuff works better (otherwise the holder gets deleted before it
	# can be added in the new track).
	if ( ptype == "pick" ) {
		$.edit("cmd_null")
		phr = $.trk[tn].get()
		phr.flags = 1
		$.trk[tn].set(phr)
	}

	$.makemerged(0)
	$.resize()
	$.redraw()
	return(tn)
}

method addtrack(ph,tnotes) {

	$.ntracks = $.ntracks + 1
	tn = $.ntracks

	$.trk[tn] = new wphrase()

	if ( nargs() > 1 && sizeof(tnotes) > 0 ) {
		tnp = toolnotesrestore(tnotes,$.trk[tn])
		ph |= tnp
	}

	$.trk[tn].setnotify($)

	$.tn2name[tn] = $.trk[tn].trackname()

	$.tn2label[tn] = $.newtracklabel(tn)

	$.tn2patch[tn] = 0
	$.tn2chan[tn] = 0
	$.tn2mute[tn] = 0
	if ( nargs() > 0 ) {
		ph.flags = 0
		$.trk[tn].set(ph)
		$.makemerged(0)
	}
	return(tn)
}

method newtracklabel(t) {
	while ( 1 ) {
		s = string("Trk "+string(t))
		found = 0
		# make sure the name isn't already used
		for ( tn in $.tn2label ) {
			if ( s == $.tn2label[tn] ) {
				found = 1
				break
			}
		}
		if ( ! found )
			return(s)
		t++
	}
}

method mousedown(m) {
	lock($)	# make sure nobody else has it locked before we start
	unlock($)
	f = $.fifo
	if ( f >= 0 )
		put(f,m)
	else {
		if ( "modifier" in m )
			mod = m["modifier"]
		else
			mod = 0
		bn = m["button"]
		val = $.buttonact[bn][mod]

		btype = $.val2buttontype[val]
		meth = $.val2notifymeth[val]
		if ( val in $.val2controller )
			$.drawcontroller = $.val2controller[val]
		if ( val in $.val2arg )
			$.arg = $.val2arg[val]

		co = $.childunder(m)
		if ( co==$ ) {
			if ( btype == INVOKE )
				$.(meth)(-1,-1)
		}
		else {
			if ( defined(co.setbuttontype) ) {
				co.setbuttontype(btype,bn,meth)
			}
			mouseforward(m,"mousedown")
		}
	}
}

method notifypaste(co,v) {

	if ( (dn=lookup($.c,co,-1)) < 0 )
		error ("Bad co in notifypaste!?")
	if ( dn == 0 ) {
		print("You can't paste/insert into the Merged track!")
		print("Use 'View->Tracks->All' to view all tracks, if you need to,")
		print("and then paste/insert into a specific track.")
		return()
	}
	tn = $.dn2tn[dn]
	trk = $.trk[tn]
	phr = trk.get()
	phr.flags = 0
	
	if ( $.arg >= 100 ) {
		ptype = $.arg - 100
		doinsert = 1
	}
	else {
		ptype = $.arg
		doinsert = 0
	}
	if ( ptype == 0 )
		p = Snarf
	else if ( ptype == 1 ) {
		p = lastnotechord(Recorded)
	}
	else if ( ptype == 2 ) {
		p = lastbunch(Recorded,2b)
	}
	p = strip(p)
	leng = latest(p)
	p.flags = 1
	p.time += v["x"]
	if ( $.tn2chan[tn] > 0 )
		p.chan = $.tn2chan[tn]
	if ( doinsert == 1 ) {
		pk = [tn=cut(phr,CUT_TIME,v["x"],MAXCLICKS)]
		p2 = pk[tn]
		phr -= p2
		p2.time += leng
		phr |= p2
		phr |= p
		npk = [tn=(p|p2)]
	}
	else {
		phr |= p
		pk = [tn='']
		npk = [tn=p]
	}
	trk.set(phr)
	$.makemerged(0)
	if ( $.refit(1,1,npk) == 0 )
		$.redrawtracks()
	$.saveundo(pk,npk)
}

method notifyappend(co,v) {

	if ( (dn=lookup($.c,co,-1)) < 0 )
		error ("Bad co in notifyappend!?")
	if ( dn == 0 ) {
		print("You can't Append into the Merged track!")
		print("Use 'View->Tracks->All' to view all tracks, if you need to,")
		print("and then Append into a specific track.")
		return()
	}
	tn = $.dn2tn[dn]

	trk = $.trk[tn]
	phr = trk.get()
	phr.flags = 0
	
	ptype = $.arg - 100

	if ( ptype == 0 )
		p = Snarf
	else if ( ptype == 1 ) {
		p = lastnotechord(Recorded)
	}
	else if ( ptype == 2 ) {
		p = lastbunch(Recorded,2b)
	}
	p = strip(p)
	leng = latest(p)
	p.flags = 1
	tx = latest(phr)
	p.time += tx
	if ( $.tn2chan[tn] > 0 )
		p.chan = $.tn2chan[tn]
	phr |= p
	pk = [tn='']
	npk = [tn=p]
	trk.set(phr)
	$.makemerged(0)
	if ( $.refit(1,1,npk) == 0 )
		$.redrawtracks()
	$.saveundo(pk,npk)
}

method notifybang(co,m,rawm) {
	if ( (dn=lookup($.c,co,-1)) < 0 )
		error ("Bad co in notifybang!?")
	if ( dn == 0 ) {
		print("Can't put a bang in the Merged track, point to a specific track!")
		return()
	}
	f = grabmousefifo()
	task $.task_bangset(dn,m,rawm,f)
}

method task_bangset(dn,gridm,rawm,f) {
	ln = ["x0"=rawm["x"],"y0"=rawm["y"],"x1"=rawm["x"],"y1"=rawm["y"]]
	Root.line(ln,XOR)
	while ( (m=get(f)) != Eof ) {
		if ( m["button"] == 0 )
			break
		Root.line(ln,XOR)
		ln["x1"] = m["x"]
		ln["y1"] = m["y"]
		Root.line(ln,XOR)
	}
	ungrabmousefifo(f)

	Root.line(ln,XOR)
	o = Root.childunder(xy(m["x"],m["y"]))
	if ( o == $ ) {
		# Can't bang yourself!
		return()
	}

	tn = $.dn2tn[dn]
	trk = $.trk[tn]
	phr = trk.get()
	phr.flags = 0
	if ( defined(o.classof) )
		name = " " + string(o.classof())
	else
		name = ""
	s = "'\"{$" + string(o) + ".bang()} #label=!" + name + ":\"'"
	p = phrase(s)
	p = strip(p)
	p.flags = 1
	p.time += gridm["x"]
	if ( $.tn2chan[tn] > 0 )
		p.chan = $.tn2chan[tn]
	phr |= p
	pk = [tn='']
	npk = [tn=p]
	trk.set(phr)
	$.redrawtn(tn)
	$.makemerged(1)
	$.saveundo(pk,npk)
}

method adddel1(co,p,f) {
	if ( (dn=lookup($.c,co,-1)) < 0 )
		error ("Bad co in adddel1!?")
	tn = $.dn2tn[dn]
	if ( tn == 0 ) {
		# find first track that contains the note
		for ( tn=1; tn<=$.ntracks; tn++ ) {
			if ( sizeof( ($.trk[tn].get()) & p) > 0 )
				break
		}
		if ( tn > $.ntracks )
			error("Didn't find note in any track!?")
	}
	phr = $.trk[tn].get()
	phr -= p
	if ( f == 0 ) {		# delete 1
		p.flags = 0
	}
	else if ( f == 1 ) {	# add 1
		p.flags = 1
	}
	else if ( f == 2 ) {	# only 1
		$.clearpick(0)
		p.flags = 1
	}
	phr |= p
	$.trk[tn].set(phr)
	$.redrawtn(tn)
	$.makemerged(1)
}

method notifyident(co,v) {
	if ( (dn=lookup($.c,co,-1)) < 0 )
		error ("Bad co in notifyident!?")
	task $.c[dn].flash(v)
	print(v)
}

method notifypluck(co,v) {
	if ( (dn=lookup($.c,co,-1)) < 0 )
		error ("Bad co in notifypluck!?")
	task $.c[dn].flash(v)
	print(v)
	v.time = 0
	realmidi(v)
}

method notifypicksweep(co,v,dir,pktype) {

	# dir is 0 for horizontal (time-oriented) sweep
	# dir is 1 for vertical (pitch-oriented) sweep

	# pktype is "" for normal (exclusive, clear existing pick) pick
	# pktype is "&" for doing intersection with existing pick
	# pktype is "-" for deleting from existing pick
	# pktype is "+" for adding to existing pick

	if ( nargs() < 4 )
		pktype = ""

	if ( (dn=lookup($.c,co,-1)) < 0 ) {
		error ("Bad co in notifypicksweep!?")
	}
	tn = $.dn2tn[dn]
	if ( pktype == "" ) {
		$.clearpick(0,1,tn)
	}
	if ( tn>0 ) {
		# Set pick only in the one track
		phr = $.trk[tn].get()
		if ( dir ) {
			p1 = phr { ??.pitch >= v["y0"] && ??.pitch < v["y1"] }
		}
		else {
			p1 = cut(phr,CUT_TIME,v["x0"],v["x1"])
		}

		if ( pktype == "&" )
			p1 = cut(p1,CUT_FLAGS,1)
		else if ( pktype == "-" )
			p1 = cut(phr,CUT_FLAGS,1) - p1
		else if ( pktype == "+" ) {
			p1a = cut(phr,CUT_FLAGS,1) - p1
			p1 |= p1a
		}

		phr -= p1
		phr.flags = 0
		p1.flags = 1
		phr |= p1
		$.trk[tn].set(phr)
		$.c[dn].redraw()
	}
	else {
		# for track 0 (the merged track), set pick in all tracks
		for ( tn=1; tn<=$.ntracks; tn++ ) {
			phr = $.trk[tn].get()
			if ( dir )
				p1 = phr { ??.pitch >= v["y0"] && ??.pitch < v["y1"] }
			else
				p1 = cut(phr,CUT_TIME,v["x0"],v["x1"])

			if ( pktype == "&" )
				p1 = cut(p1,CUT_FLAGS,1)
			else if ( pktype == "-" )
				p1 = cut(phr,CUT_FLAGS,1) - p1
			else if ( pktype == "+" ) {
				p1a = cut(phr,CUT_FLAGS,1) - p1
				p1 |= p1a
			}

			# We continue even if p1 is empty, so that
			# stuff currently picked in a track is reset
			phr -= p1
			phr.flags = 0
			p1.flags = 1
			phr |= p1
			$.trk[tn].set(phr)
			$.redrawtn(tn)
		}
	}
	$.makemerged(1)
}

method notifyplaypick() {
	if ( $.isplaying )
		$.stop()
	else
		$.playpick()
}

method notifyplayaud() {
	if ( $.isplaying )
		$.stop()
	else
		$.playaudition()
}

method notifyloop {
	if ( $.isplaying ) {
		$.islooping = 0
		$.stop()
	}
	else {
		$.islooping = 1
		$.playaudition()
	}
}

method sweepnotify(v,cw,m) {
	dn = lookup($.c,cw,-1)
	if ( dn < 0 )
		error("Bad cw=",cw," in sweepnotify!?")
	tn = $.dn2tn[dn]

	b = m["button"]
	if ( b != 1 && b != 2 )
		error("Unexpected m[button] value in sweepnotify!?")
	if ( "modifier" in m )
		mod = m["modifier"]
	else
		mod = 0
	stype = $.buttonact[b][mod]
	meth = $.val2notifymeth[stype]
	$.(meth)(dn,v)
}

method mousedrag(m) {
	f = $.fifo
	if ( f >= 0 )
		put(f,m)
	else
		mouseforward(m,"mousedrag")
}

method mouseup(m) {
	f = $.fifo
	if ( f >= 0 ) {
		put(f,m)
		close(f)
		$.fifo = -1
		setmouse(ARROW)
		ungrabmouse($)
	}
	else
		mouseforward(m,"mouseup")
}

method pan() {
	grabmouse($)
	setmouse(LEFTRIGHT)
	$.fifo = f = open()
	task $.task_panit(f)
}

method task_panit(f) {
	mergedw = $.c[0]
	m = waitdown(f)
	oldm = mergedw.scaletogrid(m)
	totdiffd = 0
	while ( (m=get(f)) != Eof ) {
		if ( m["button"] == 0 )
			break
		if ( fifosize(f) > 1 )
			continue
		newm = mergedw.scaletogrid(m)
		diffd = newm["x"] - oldm["x"]
		if ( diffd != 0 ) {
			ndisp = $.ndisp
			for ( dn=0; dn<ndisp; dn++ ) {
				$.c[dn].viewshift(diffd,0)
				if ( ! defined($.c[dn].redraw) ) {
					print("Hey! $.c=",$.c)
				}
				else {
					$.c[dn].redraw()
				}
			}
			totdiffd += diffd
		}
	}

	$.view["x0"] -= totdiffd
	$.view["x1"] -= totdiffd
	$.refit(1,0)
}

method redraw() {

	# It's important that the tracks not be changing when we're redrawing.
	# Hence the lock.
	lock($)

	$.w.redraw()
	th = $.textheight()
	tw = $.textwidth()
	y0 = $.ymin()+1
	y0a = y0 + th + 6
	xmid = ($.xmin()+$.xmax())/2
	tx1 = $.xmin() + 17*tw
	if ( tx1 > xmid )
		tx1 = xmid
	$.textleft("Name: "+$.groupname+"   # Tracks: "+string($.ntracks),
		xy(tx1,y0a+2,$.xmax()-1,y0a+th+2))
	$.line(xy($.xmin(),y0a-1,$.xmax(),y0a-1))

	# execute redraw method on all visible children
	for ( o in $.children() ) {
		if ( defined(o.redraw) ) {
			o.redraw()
		}
	}
	unlock($)
}

method resize(sz) {

	if ( nargs() > 0 )
		$.w.resize(sz)

	if ( $.ndisp <= 0 )	# e.g. when busy splitting on channels
		return()
	th = $.textheight()
	tw = $.textwidth()
	ndisp = $.ndisp

	y0 = $.ymin()
	y1 = $.ymax()
	x0 = $.xmin()
	x1 = $.xmax()
	xmid = (x1+x0)/2

	y0a = y0 + th + 8
	dy = (y1-y0a)/(ndisp)
	$.dy = dy

	# The buttons accross the top
	dx = (xmid-x0-6)/3
	if ( dx > 6*tw )
		dx = 6*tw
#	$.b0.resize(xy(x0+2,y0+2,x0+dx,y0a-4))
	$.b1.resize(xy(x0+2+dx,y0+2,x0+2*dx,y0a-4))
	$.b2.resize(xy(x0+2+2*dx,y0+2,x0+3*dx,y0a-4))

	dx2 = (x1-xmid)/3
	if ( dx2 > (16*tw) )
		dx2 = 16*tw
	$.b3.resize(xy(x1-3*dx2,y0+2,x1-2*dx2-1,y0a-4))
	$.vb[1].resize(xy(x1-2*dx2+1,y0+2,x1-dx2-1,y0a-4))
	$.vb[2].resize(xy(x1-dx2+1,y0+2,x1-2,y0a-4))

	xa = x0 + 10*tw
	for ( dn=0; dn<ndisp; dn++ ) {
		yaa = y0a+dn*dy
		if ( dn == ndisp-1 )
			yb = y1
		else
			yb = yaa+dy
		if ( dy < th )
			ya = yaa + dy/2
		else
			ya = yaa + th
		phheight = (yb-2)-(ya+2)
		tn = $.dn2tn[dn]

		phrasexy = xy(x0+2,ya+4,x1-2,yb-2)

		if ( (xa+tw*23) > x1 ) {
			# not enough room for normal resize, just split it up
			ddx = (x1-x0)/9
			trkxy = xy(x0+2,yaa,x0+3*ddx-1,ya+2)
			soloxy = xy(x0+1+3*ddx,yaa,x0+4*ddx-1,ya+2)
			mutexy = xy(x0+1+4*ddx,yaa,x0+5*ddx-1,ya+2)
			trkchanxy = xy(x0+1+5*ddx,yaa,x0+7*ddx-1,ya+2)
			patchxy = xy(x0+1+7*ddx,yaa,x1-2,ya+2)
		}
		else {
			# normal resize
			trkxy = xy(x0+2,yaa,xa-1,ya+2)
			soloxy = xy(xa+tw,yaa,xa+tw*3-1,ya+2)
			mutexy = xy(xa+tw*3+1,yaa,xa+tw*5-1,ya+2)
			trkchanxy = xy(xa+tw*5+1,yaa,xa+tw*9-1,ya+2)
			patchxy = xy(xa+tw*9+1,yaa,xa+tw*23,ya+2)
		}

		$.c[dn].resize(phrasexy)
		$.trkbutt[dn].resize(trkxy)
		if ( $.autofit )
			$.c[dn].fitvert(0)
		if ( dn == 0 )
			continue

		$.solo[dn].resize(soloxy)
		$.mute[dn].resize(mutexy)
		$.patch[dn].resize(patchxy)
		$.trkchan[dn].resize(trkchanxy)
	}
}

method viewchanged(newview) {
	# One of the track phrases has notified us that their view has changed
	oldview = $.view
	if ( oldview["x0"] == newview["x0"] && oldview["x1"] == newview["x1"] )
		return()
	$.viewset(newview)
	$.refit(0)
}

method playaudition(dopick,startnow) {
	if ( $.isplaying && ! $.islooping ) {
		print("Can't start playing, it's already playing!?")
		return()
	}
	if ( nargs() < 1 )
		dopick = 0

	nt = $.ntracks
	ndisp = $.ndisp

	Lastobj = $

	$.pt = []
	firstnt = ''
	if ( dopick ) {
		pk = $.getpick()
		all = ''
		for ( tn in pk ) {
			p = pk[tn]
			firstnt |= p%1
			$.pt[tn] = p
			all |= p
		}
		lim = limitsof(all)
		t1 = lim["earliest"]
		t2 = lim["latest"]
	}
	else {
		t1 = $.audition["start"]
		t2 = $.audition["end"]
		# get values of solo buttons
		solos = []
		for ( dn=1; dn<ndisp; dn++ ) {
			if ( $.solo[dn].get() ) {
				tn = $.dn2tn[dn]
				solos[tn] = dn
			}
		}
		nsolos = sizeof(solos)
		if ( nsolos == 0 || (0 in solos) ) {
			for ( tn=1; tn<=nt; tn++ ) {
				if ( $.tn2mute[tn] )
					continue
				p = $.trk[tn].getaudition(t1,t2)
				firstnt |= p%1
				if ( $.tn2chan[tn] > 0 )
					p.chan = $.tn2chan[tn]
				$.pt[tn] = p
			}
		}
		else {
			for ( tn in solos ) {
				p = $.trk[tn].getaudition(t1,t2)
				firstnt |= p%1
				if ( $.tn2chan[tn] > 0 )
					p.chan = $.tn2chan[tn]
				$.pt[tn] = p
			}
		}
	}

	# construct phrase to play in merged track
	$.pt[0] = ''
	for ( tn in $.pt )
		$.pt[0] |= $.pt[tn]

	# We now have the phrase we want to play (per track, in $.pt)
	# First figure out when it'll start.
	# Then go through each displayed track
	# and arrange for flashing the notes.

	if ( nargs() < 2 )
		startnow = Now

	$.stime = nextquant(startnow,Playquant)
	tmppick = syncphr(firstnt)

	$.playoffset = (firstnt%1).time - (tmppick%1).time
	dt = $.stime - $.playoffset

	# Get realtime MIDI output going right away
	$.tn2tids = []
	for ( tn in $.pt ) {
		if ( tn == 0 ) {		# merged track
			$.tn2tids[tn] = []
			continue
		}
		ptch = $.patchphrase(tn)
		if ( ptch != '' ) {
			realmidi(ptch)
		}

		p = $.pt[tn]

		# There was something wrong here, so instead of
		# 	tid = realmidi(p,dt)
		# 	$.stoptids[tid] = 1
		# we now expand it inline to:
		tida = realtime(p,dt)
		$.stoptids[tida] = 1
		tidb = task noticecontrollers(p,dt)
		$.stoptids[tidb] = 1
		if (!ACPATCHES) {
			tidc = task noticeprogram(p,dt)
			$.stoptids[tidc] = 1
		}
		tid2 = realexpr(p,dt)
		$.stoptids[tid2] = 1

		if (ACPATCHES)
			$.tn2tids[tn] = [tida=1,tid2=1,tidb=1]
		else
			$.tn2tids[tn] = [tida=1,tid2=1,tidb=1,tidc=1]
	}
	$.isplaying = 1
	$.laststime = $.stime

	etime = $.stime + (t2-t1) + tmppick%1.time
	if ( ! $.islooping ) {
		tid = task waitnmethod(etime,$,"stop")
		$.stoptids[tid] = 1
	}
	if ( $.islooping ) {
		tid = task waitnmethod($.stime+(t2-t1)-1b,$,"checkloop",$.stime+(t2-t1))
		$.stoptids[tid] = 1
	}

	for ( tn in $.pt ) {
		dn = lookup($.dn2tn,tn,-1)
		if ( dn < 0 )
			continue

		trk = $.trk[tn]
		cp = trk.get()	# not getaudition, so tools don't get evaluated

		# We don't flash tools
		if ( trk.hastools() )
			cp -= toolnotes(cp)

		# This is needed because we might just be playing the pick
		cp2 = cp & ($.pt[tn])

		if ( Phraseflashnotes == 1 ) {
			tid = $.c[dn].flashnotes(cp2,$.stime,$.playoffset)
			$.stoptids[tid] = 1
			$.tn2tids[tn][tid] = 1
		}
	}
}

method checkloop (tm) {
	if ( $.islooping ) {
		$.playaudition(0,tm)
	}
	else {
		millisleep(Playquant)
		print("checkloop calling stop")
		$.stop()
	}
} 

method playpick() {
	$.playaudition(1)
}

method lastoverdub() {
	if ( $.laststop < $.laststime )
		$.laststop = Now
	ph = cut(Recorded,CUT_TIME,$.laststime,$.laststop)
	ph.time -= $.laststime
	ph.time += $.playoffset
	return(ph)
}

method snarfdn(dn) {
	tn = $.dn2tn[dn]
# print("wgroup, snarfdn, dn=",dn)
	if ( dn == 0 ) {
		Snarf = $.getraw()
	} else {
		Snarf = $.trk[tn].get()
	}
}

method snarf(tn) {
	if ( nargs() > 0 ) {
# print("wgroup, snarf, tn=",tn)
		Snarf = $.trk[tn].get()
	}
	else {
# print("wgroup, snarf, no arg")
		Snarf = $.getraw()
	}
}

method snarfpickdn(dn) {
	$.snarfpick($.dn2tn[dn])
}

method snarfauddn(dn) {
	tn = $.dn2tn[dn]
	t1 = $.audition["start"]
	t2 = $.audition["end"]
	p = $.trk[tn].getaudition(t1,t2)
	p.time -= t1
	p.length = t2 - t1
	Snarf = p
}

method snarfpick(tn) {
	pk = $.getpick()
	if ( nargs() > 0 && tn > 0 )
		Snarf = pk[tn]
	else {
		Snarf = ''
		for ( tn in pk )
			Snarf |= pk[tn]
	}
}

method getpick() {
	pk = []
	for ( tn=1; tn<=$.ntracks; tn++ ) {
		p = $.trk[tn].get()
		pk[tn] = cut(p,CUT_FLAGS,1)
	}
	return(pk)
}

method showpicked() {
	nt = $.ntracks
	for ( tn=1; tn<=nt; tn++ ) {
		dn = lookup($.dn2tn,tn,-1)
		p = $.trk[tn].get()
		if ( sizeof(cut(p,CUT_FLAGS,1)) > 0 ) {
			# display it, if it's not already shown
			if ( dn < 0 )
				$.dispmore(tn)
		}
		else {
			# if it's shown, get rid of it
			if ( dn >= 0 )
				$.unshowdn(dn)
		}
	}
	$.resize()
	$.redraw()
}

method showonlydn(dn) {
	for ( dn2=$.ndisp-1; dn2>0; dn2-- ) {
		if ( dn2 != dn )
			$.unshowdn(dn2)
	}
	$.resize()
	$.redraw()
}
}


