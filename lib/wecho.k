class wecho {
method init {
	$.w = new window()
	$.inherit($.w)

	$.timestep = 1b/4
	$.tid = -1

	$.val_time = 4
	$.val_trans = 0
	$.val_vol = 90
	$.val_ntimes = 1

	$.c = []
	$.c["slider_time"] = new kslider(0,16,$.val_time,
			$,"callback","time")
	$.c["slider_trans"] = new kslider(-12,12,$.val_trans,
			$,"callback","trans")
	$.c["slider_vol"] = new kslider(0,100,$.val_vol,
			$,"callback","vol")
	$.c["slider_ntimes"] = new kslider(1,8,$.val_ntimes,
			$,"callback","ntimes")
	$.c["on"] = new ktoggle("On",$,"setonoff")

	$.c["text_time"] = new ktext("")
	$.c["text_vol"] = new ktext("")
	$.c["text_ntimes"] = new ktext("")
	$.c["text_trans"] = new ktext("")
	for ( t in $.c )
		$.addchild($.c[t])

	# text (containing values) gets initialized
	for ( i in arraylist("time","trans","vol","ntimes") )
		$.set($.("val_"+i),i)
}
method set(v,nm) {
	$.("val_"+nm) = v
	if ( nm == "time" )
		t="time\n"+sprintf("%.2f",(($.val_time)*($.timestep))/float(1b))
	else if ( nm == "trans" )
		t = "trans\n"+string($.val_trans)
	else if ( nm == "vol" )
		t = "vol%\n"+string($.val_vol)
	else if ( nm == "ntimes" )
		t = "ntimes\n"+string($.val_ntimes)
	# set contents of text widget
	$.c["text_"+nm].set(t)
}
method on (doredraw) {
	$.tid = task $.task_echomidi()
	$.c["on"].set(1)
	if ( nargs() < 1 || doredraw!=0 )
		$.c["on"].redraw()
}
method off {
	if ( $.tid < 0 )
		error("Hey, tid<0 in wecho_off!?")
	kill($.tid)
	$.tid = -1
	$.c["on"].set(0)
	$.c["on"].redraw()
}
method setonoff (v,m) {
	if (v)
		$.on()
	else
		$.off()
}
method bang {
	if ( $.tid < 0 )
		$.on()
	else
		$.off()
}
method redraw {
	$.w.redraw()
	methodbroadcast()
}
method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)

	th = $.textheight()
	x0 = $.xmin()+2
	y0 = $.ymin()+1
	x1 = $.xmax()-1
	y2 = $.ymax()-2
	dy = y2-y0
	if ( dy < (5*th) ) {
		y0a = y0 + dy/3
		y0b = y0 + 2*dy/3
	}
	else {
		y0a = y0+th+5
		y0b = $.ymax() - 2*th-5
	}
	dx = ($.xmax()-$.xmin()) / 4

	$.c["slider_time"].resize(xy(x0,y0a,x0+dx,y0b-2))
	$.c["slider_trans"].resize(xy(x0+2+dx,y0a,x0+2*dx-1,y0b-2))
	$.c["slider_vol"].resize(xy(x0+1+2*dx,y0a,x0+3*dx-1,y0b-2))
	$.c["slider_ntimes"].resize(xy(x0+1+3*dx,y0a,x1-1,y0b-2))
	$.c["on"].resize(xy(x0,y0+1,x1-1,y0a-2))

	$.c["text_time"].resize(xy(x0,y0b,x0+dx,y2))
	$.c["text_trans"].resize(xy(x0+2+dx,y0b,x0+2*dx-1,y2))
	$.c["text_vol"].resize(xy(x0+1+2*dx,y0b,x0+3*dx-1,y2))
	$.c["text_ntimes"].resize(xy(x0+1+3*dx,y0b,$.xmax()-2,y2))
}
method delete {
	delete Midiin[$]
}
method dump {
	return([
		"time"=$.val_time,
		"trans"=$.val_trans,
		"vol"=$.val_vol,
		"ntimes"=$.val_ntimes,
		"ison"=($.tid!=-1)
		])
}
method restore(state) {
	for ( i in arraylist("time","trans","vol","ntimes") ) {
		$.set(state[i],i)
		$.c["slider_"+i].set(state[i])
	}
	if ( state["ison"] )
		$.on(0)
}
method callback (v,valtype) {
	$.set(v,valtype)
	$.c["text_"+valtype].redraw()
}
method task_echomidi() {
	Midiin[$] = f = open()
	while ( (nt=get(f)) != Eof ) {
		for ( n=$.val_ntimes; n>0; n-- ) {
			if ( nt.type & (NOTE|NOTEOFF|NOTEON) ) {
				nt.time += ($.val_time * $.timestep)
				nt.pitch += $.val_trans
				nt.vol = (nt.vol*$.val_vol)/100
				realtime(nt,0)
			}
		}
	}
}
}

