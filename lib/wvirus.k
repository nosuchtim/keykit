class wvirus {

method init {
	$.w = new window()
	$.inherit($.w)
	# The list of controllers is copied from the controllerlist array
	cl = controllerlist()
	$.slide = []
	$.togg1 = []
	$.togg2 = []
	$.butt2 = new kmenubutton("More","mkmenu_wvirusmore",$)
	$.addchild($.butt2)
	for ( n=1; n<=3; n++ ) {
		$.slide[n] = new kslider(0,64,32,$,"valchanged",n)
		$.togg1[n] = new ktoggle(nullfunc,$,"tooutput",1,n)
		$.togg2[n] = new ktoggle(nullfunc,$,"tooutput",2,n)
		$.addchild($.slide[n])
		$.addchild($.togg1[n])
		$.addchild($.togg2[n])
	}
}

method partmessage(grp,v) {
	# The value coming is is 1 (top toggle),
	# 2 (lower toggle) and 3 (neither toggle)
	if ( v == 1 )
		v = 4	# output 2 R+L
	else if ( v == 2 )
		v = 1	# output 1 R+L
	else if ( v == 3 )
		v = 7	# output 3 R+L
	global(virus_partoutput)
	return($.groupmessage(grp,v,virus_partoutput))
}

method volmessage(grp,v) {
	global(virus_partvolume)
	return($.groupmessage(grp,v,virus_partvolume))
}

method groupmessage(grp,v,f) {
	# The three groups are:
	#     	channels 7,8,9
	#	channels 11,12,13
	#	channels 14,15,16

	# Make sure it goes to the right port
	defouts = midi("portmap")[0]

	if ( grp == 1 ) {
		c1 = 7 ; c2 = 8 ; c3 = 9
	} else if ( grp == 2 ) {
		c1 = 11 ; c2 = 12 ; c3 = 13
	} else if ( grp == 3 ) {
		c1 = 14 ; c2 = 15 ; c3 = 16
	}
	pa = f(c1,v) ; pa.port = defouts[c1]
	pb = f(c2,v) ; pb.port = defouts[c2]
	pc = f(c3,v) ; pc.port = defouts[c3]
	p = pa + pb + pc
	return(p)
}

method valchanged(v,grp) {
	p = $.volmessage(grp,v)
	realtime(p,Now)
}

method tooutput(v,m,pt,g) {
	if ( pt == 2 && v == 1 ) {
		# When we switch to output 2, we set the
		# volume up so we can hear it right away
		$.slide[g].set(50,1,1)
		tinc = 0

		$.togg1[g].set(0)
		$.togg1[g].redraw()
	} else if ( pt == 1 && v == 1 ) {
		# When we switch on output 1, we set the
		# volume down so it isn't heard until
		# the slider is used
		$.slide[g].set(0,1,1)

		# We increment the time a bit so
		# that the slider setting (to adjust the
		# volume) will have time to happen
		# before the output switches
		tinc = 1b

		$.togg2[g].set(0)
		$.togg2[g].redraw()
	}
	p = $.get_tooutput(g)
	realtime(p,Now+tinc)
}
method get_vol(g) {
	p = $.volmessage(g,$.slide[g].get())
	return(p)
}
method get_tooutput(g) {
	if ( $.togg1[g].get() )
		p = $.partmessage(g,1)
	else if ( $.togg2[g].get() )
		p = $.partmessage(g,2)
	else
		p = $.partmessage(g,3)
	return(p)
}

method get {
	r = ''
	for ( g=1; g<=3; g++ ) {
		r += $.get_tooutput(g)
		r += $.get_vol(g)
	}
	return(r)
}
method dump {
	st = []
	for ( n=1; n<=3; n++ ) {
		st[n] = $.slide[n].get()
		st["togg1_"+string(n)] = $.togg1[n].get()
		st["togg2_"+string(n)] = $.togg2[n].get()
	}
	return(st)
}
method restore (st) {
	for ( n=1; n<=3; n++ ) {
		$.slide[n].set(st[n])
		t = "togg1_"+string(n)
		if ( t in st )
			$.togg1[n].set(st[t])
		t = "togg2_"+string(n)
		if ( t in st )
			$.togg2[n].set(st[t])
	}
}
method update {
	$.send()
}
method send {
	p = $.get()
	realtime(p,Now)
}	
method redraw() {
	$.w.redraw()
	th = $.textheight()
	tw = $.textwidth()
	y0 = $.ymin() ; y1 = y0+th+4 ; y2 = y1+th+4; y3 = $.ymax()-4
	x0 = $.xmin()+2 ; xn = $.xmax()-2
	$.text("Virus Groups",xy(x0,y0,x0+2*$.dxa,y1))
	# for ( n=1; n<=3; n++ ) {
	# 	$.text(string(n),xy(x0+(n-1)*$.dxb,y1,xn-(3-n)*$.dxb,y2))
	# }
	methodbroadcast()
}

method resize(sz) {
	th = $.textheight()
	tw = $.textwidth()
	if ( nargs() > 0 )
		$.w.resize(sz)
	y0 = $.ymin() ; y1 = y0+th+4
	y2a = y1 + 2*th/3
	y2 = y2a + 2*th/3
	y3 = y2 + th + 4 ; y4 = $.ymax()-2
	x0 = $.xmin()+2 ; xn = $.xmax()-1
	$.dxa = (xn-x0)/3
	$.dxb = (xn-x0)/3.0
	$.butt2.resize(xy(x0+2*$.dxa,y0+1,xn,y0+th+2))
	for ( n=1; n<=3; n++ ) {
		$.togg1[n].resize(xy(x0+(n-1)*$.dxb+1,y1,xn-(3-n)*$.dxb-1,y2a-1))
		$.togg2[n].resize(xy(x0+(n-1)*$.dxb+1,y2a+1,xn-(3-n)*$.dxb-1,y2-2))
		$.slide[n].resize(xy(x0+(n-1)*$.dxb+1,y2,xn-(3-n)*$.dxb-1,y4))
	}
}
}

function mkmenu_wvirusmore(o,po) {
	o.menucmd("Send",po,"send")
	o.menucmd("Snarf",po,"snarf")
	o.menucmd("All Min",po,"setallmin")
	o.menucmd("All Mid",po,"setallmid")
	o.menucmd("All Max",po,"setallmax")
}
