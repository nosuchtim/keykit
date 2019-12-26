class wcurve {

method init {
	$.w = new window()
	$.inherit($.w)

	$.notifyobj = $0

	$.timestep = 1b/4

	$.val_from = 16
	$.val_mid = 127
	$.val_to = 110

	# The list of controllers is copied from the
	# controllerlist() array.
	cl = controllerlist()
	$.valtypes = []
	$.cvalues = []
	for ( i in cl ) {
		$.valtypes[i] = cl[i]["name"]
		$.cvalues[i] = cl[i]["value"]
	}
	$.linetypes = [0="Line",1="UpDown"]
	$.linetype = 0
	$.minvchange = 2

	$.c = []
	$.c["valtype"] = new kvalbutton($.valtypes,$,"valtypechanged")
	$.c["more"] = new kmenubutton("More","mkmenu_curvemore",$)

	for ( t in $.c )
		$.addchild($.c[t])
}

method getlinetypes() {
	return($.linetypes)
}

method setnotify(o) {
	$.notifyobj = o
}

method mousedown(m) {
	if ( areacontains($.area,m) ) {
		$.mousehit(m)
	} else {
		mouseforward(m,"mousedown")
	}
}

method mousedrag(m) {
	if ( areacontains($.area,m) ) {
		$.mousehit(m)
	} else {
		mouseforward(m,"mousedrag")
	}
}

method mousehit(m) {
	mx = m["x"]
	my = m["y"]
	dy = $.area["y1"] - $.area["y0"]
	lt = $.linetype
	x0 = $.area["x0"]
	x1 = $.area["x1"]

	# the values along the y axis go from 0 to 127
	yv = ($.area["y1"]-my)*127/dy

	if ( lt == 0 ) {
		# Line
		xmid = (x0 + x1)/2
		if ( mx < xmid )
			$.val_from = yv
		else
			$.val_to = yv
	} else if ( lt == 1 ) {
		# UpDown

		dx = x1-x0
		# Detection is *not* split in even thirds.
		# You have to be closer to the middle to grab it.
		xmid1 = x0 + 3*dx/7
		xmid2 = x0 + 4*dx/7
		if ( mx < xmid1 )
			$.val_from = yv
		else if ( mx > xmid2 )
			$.val_to = yv
		else
			$.val_mid = yv
	}
	$.ihavechanged()
	$.drawit()
}

method ihavechanged() {
	if ( $.notifyobj != $0 && $.notifyobj != $-1 ) {
		$.notifyobj.notifyofchange($)
	}
}

method drawit() {
	$.fillrectangle($.area,CLEAR)
	lt = $.linetype
	y0 = $.area["y0"]
	y1 = $.area["y1"]
	x0 = $.area["x0"]
	x1 = $.area["x1"]
	dy = y1 - y0
	if ( lt == 0 ) {
		# Line
		yv1 = y1 - ($.val_from*dy)/127
		yv2 = y1 - ($.val_to*dy)/127
		$.line(xy(x0,yv1,x1,yv2))
	} else if ( lt == 1 ) {
		# UpDown
		yv1 = y1 - ($.val_from*dy)/127
		yvm = y1 - ($.val_mid*dy)/127
		yv2 = y1 - ($.val_to*dy)/127
		xmid = (x0 + x1)/2
		$.line(xy(x0,yv1,xmid,yvm))
		$.line(xy(xmid,yvm,x1,yv2))
	} else {
		print("Unknown line type: ",lt)
	}
}

method valtypechanged(v) {
}

method changeminvchange(v) {
	$.minvchange = v
	$.drawit()
	$.ihavechanged()
}

method changetype(v) {
	$.linetype = v
	$.drawit()
	$.ihavechanged()
}

method get(desiredlength) {
	if ( nargs() < 1 )
		desiredlength = 1b
	cv = $.cvalues[$.c["valtype"].get()]

	ch = 1
	ndiv = desiredlength / (1b/16)

	result = ''
	lt = $.linetype
	if ( lt == 0 ) {
		# Line
		result = $.generate($.val_from,$.val_to,cv,ch,desiredlength,ndiv)
	} else if ( lt == 1 ) {
		# UpDown
		result = $.generate($.val_from,$.val_mid,
			cv,ch,desiredlength/2,ndiv/2)
		result.length = desiredlength/2
		result += $.generate($.val_mid,$.val_to,
			cv,ch,desiredlength/2,ndiv/2)
	}
	result.length = desiredlength
	return(result)
}

method generate(vfrom,vto,cv,ch,desiredlength,ndiv) {
	dval = vto - vfrom
	r = ''
	lastv = -1
	lasttime = -1
	for ( n=0; n<=ndiv; n++ ) {
		v = vfrom + (dval * n)/ndiv
		if ( v == lastv || abs(v-lastv) < $.minvchange )
			continue
		p = controller(ch,cv,v)
		p.time = (desiredlength*n)/ndiv
		r |= p
		lastv = v
		lasttime = p.time
	}
	if ( lasttime != desiredlength ) {
		p = controller(ch,cv,vto)
		p.time = desiredlength
		r |= p
	}
	return(r)
}

method set(v,nm,doredraw) {
	$.("val_"+nm) = v
	if ( nargs() > 2 && doredraw == 1 )
		$.redraw()
}
method redraw {
	$.w.redraw()
	$.drawit()
	methodbroadcast()
}
method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)

	th = $.textheight()
	tw = $.textwidth()
	x0 = $.xmin()+2
	x1 = $.xmax()-2
	y0 = $.ymin()+2
	y2 = $.ymax()-2
	dy = y2-y0
	dx = ($.xmax()-$.xmin()) / 4
	if ( dx > (3*tw) )
		dx = 3*tw
	if ( dy < (2*th) )
		ym1 = y0 + 2*dy/3
	else
		ym1 = y2-th-6

	$.area = xy(x0,y0,x1,ym1)

	$.xmid = ($.area["x0"] + $.area["x1"])/2

	$.c["valtype"].resize(xy($.area["x0"],$.area["y1"]+2,$.xmid-1,y2))
	$.c["more"].resize(xy($.xmid+1,$.area["y1"]+2,$.area["x1"],y2))
}
method delete {
}
method dump {
	return([
		"from"=$.val_from,
		"to"=$.val_to,
		"mid"=$.val_mid,
		"valtype"=$.c["valtype"].get(),
		"linetype"=$.linetype,
		"minvchange"=$.minvchange
		])
}
method restore(state) {
	for ( i in arraylist("from","to","mid") ) {
		$.set(state[i],i)
	}
	$.c["valtype"].set(state["valtype"])
	$.linetype = state["linetype"]
	$.minvchange = state["minvchange"]
}
method callback (v,valtype) {
	$.set(v,valtype,1)
}
method task_echomidi() {
	for ( n=$.val_to; n>0; n-- ) {
	}
}
}

function mkmenu_curvemore(o,po) {
	o.submenu("Type    ->","mkmenu_curvetype",po)
	o.submenu("Density ->","mkmenu_curvedensity",po)
}

function mkmenu_curvetype(o,po) {
	types = po.getlinetypes()
	ntypes = sizeof(types)
	for ( n=0; n<ntypes; n++ ) {
		o.menucmd(types[n],po,"changetype",n)
	}
}

function mkmenu_curvedensity(o,po) {
	o.menucmd("Continuous",po,"changeminvchange",1)
	o.menucmd("Every 2",po,"changeminvchange",2)
	o.menucmd("Every 4",po,"changeminvchange",4)
	o.menucmd("Every 8",po,"changeminvchange",8)
}
